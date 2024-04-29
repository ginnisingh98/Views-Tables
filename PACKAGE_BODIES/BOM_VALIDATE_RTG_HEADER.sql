--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE_RTG_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE_RTG_HEADER" AS
/* $Header: BOMLRTGB.pls 120.1.12000000.3 2007/04/24 07:43:00 kjonnala ship $*/
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLRTGB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate_Rtg_Header
--
--  NOTES
--
--  HISTORY
--
--  07-AUG-00 Biao Zhang Initial Creation
--
****************************************************************************/
        G_PKG_NAME      VARCHAR2(30) := 'BOM_Validate_Rtg_Header';
        g_token_tbl     Error_Handler.Token_Tbl_Type;

        l_sub_locator_control         NUMBER;
        l_locator_control             NUMBER;
        l_org_locator_control         NUMBER;
        l_item_locator_control        NUMBER;
        l_item_loc_restricted         NUMBER; -- 1,Locator is Restricted,else 2


        /*******************************************************************
        * Procedure     : Check_Existence
        * Returns       : None
        * Parameters IN : Rtg Header Exposed Record
        *                 Rtg Header Unexposed Record
        * Parameters out: Old Rtg Header exposed Record
        *                 Old Rtg Header Unexposed Record
        *                 Mesg Token Table
        *                 Return Status
        * Purpose       : Procedure will query the routing header
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
        (  p_rtg_header_rec         IN  Bom_Rtg_Pub.rtg_header_Rec_Type
         , p_rtg_header_unexp_rec     IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
         , x_old_rtg_header_rec     IN OUT NOCOPY Bom_Rtg_Pub.rtg_header_Rec_Type
         , x_old_rtg_header_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status          IN OUT NOCOPY VARCHAR2
        )
        IS
                l_token_tbl      Error_Handler.Token_Tbl_Type;
                l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
                l_return_status  VARCHAR2(1);
                l_err_text       VARCHAR2(2000);

        BEGIN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Quering Routing . . . ')  ;
     Error_Handler.Write_Debug('Assembly item :  ' ||  to_char(p_rtg_header_unexp_rec.assembly_item_id));
     Error_Handler.Write_Debug('Org Id :  ' ||  to_char(p_rtg_header_unexp_rec.organization_id ));
     Error_Handler.Write_Debug('Alternate :  ' || p_rtg_header_rec.alternate_routing_code );
END IF;


                Bom_Rtg_Header_Util.Query_Row
                (  p_assembly_item_id   =>
                        p_rtg_header_unexp_rec.assembly_item_id
                 , p_alternate_routing_code     =>
                        p_rtg_header_rec.alternate_routing_code
                 , p_organization_id    =>
                        p_rtg_header_unexp_rec.organization_id
                 , x_rtg_header_rec     => x_old_rtg_header_rec
                 , x_rtg_header_unexp_rec => x_old_rtg_header_unexp_rec
                 , x_return_status      => l_return_status
                 );

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Query Row Returned with : ' || l_return_status);
END IF;

                IF l_return_status = BOM_Rtg_Globals.G_RECORD_FOUND AND
                   p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                        Error_Handler.Add_Error_Token
                        (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name  => 'BOM_RTG_ALREADY_EXISTS'
                         , p_token_tbl     => l_token_tbl
                         );
                        l_return_status := FND_API.G_RET_STS_ERROR;

                ELSIF l_return_status = BOM_Rtg_Globals.G_RECORD_NOT_FOUND AND
                      p_rtg_header_rec.transaction_type IN
                         (BOM_Rtg_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
                THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                        Error_Handler.Add_Error_Token
                        (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name  => 'BOM_RTG_DOESNOT_EXISTS'
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
                         'Assembly item '||
                         p_rtg_header_rec.assembly_item_name
                         , p_token_tbl          => l_token_tbl
                         );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS
                THEN
                       l_return_status := FND_API.G_RET_STS_SUCCESS;
                END IF;

                x_return_status := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;


       EXCEPTION
           WHEN OTHERS THEN

              l_err_text := G_PKG_NAME || ' Validation (Check Existnece) '
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


        END Check_Existence;


        /*******************************************************************
        * Procedure     : Check_Access
        * Returns       : None
        * Parameters IN : Assembly_Item_Id
        *                 Organization_Id
        *                 Alternate_rtg_Designator
        * Parameters out: Return Status
        *                 Message Token Table
        * Purpose       : This procedure will check if the user has access
        *                 to the Assembly Item's BOM Item Type.
        *                 If not then an appropriate message and a error status
        *                 will be returned back.
        *********************************************************************/
        PROCEDURE Check_Access
                  (  p_assembly_item_name IN  VARCHAR2
                   , p_assembly_item_id   IN  NUMBER
                   , p_alternate_rtg_code IN  VARCHAR2
                   , p_organization_id    IN  NUMBER
                   , p_mesg_token_tbl     IN  Error_Handler.Mesg_Token_Tbl_Type
                   , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
                   , x_return_status      IN OUT NOCOPY VARCHAR2
                   )
        IS
                l_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
                l_Mesg_Token_Tbl   Error_Handler.Mesg_Token_Tbl_Type :=
                                        p_mesg_token_tbl;
                l_err_text         VARCHAR2(2000);

                l_bom_item_type    NUMBER;
                l_assembly_type    NUMBER;
                l_eam_item_type    NUMBER;
                l_token_tbl        Error_Handler.Token_Tbl_Type;

        BEGIN

                --
                -- If user is trying to update an Engineering Item from RTG
                -- Business Object, the user should not be allowed.
                --

                -- Added eam_item_type for eAM enhancement
                -- by MK 04/20/2001
                SELECT bom_item_type
                     , decode(eng_item_flag, 'N', 1, 2)
                     , NVL(eam_item_type, 0 )
                  INTO l_bom_item_type
                     , l_assembly_type
                     , l_eam_item_type
                  FROM mtl_system_items
                 WHERE inventory_item_id = p_assembly_item_id
                   AND organization_id   = p_organization_id;

		/* Commented for bug 3277905
                IF l_assembly_type = 2  Engineering Item
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_name       => 'BOM_ASSEMBLY_TYPE_ENG'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        l_return_status := FND_API.G_RET_STS_ERROR;
                END IF; */

                IF BOM_Rtg_Globals.Get_STD_Item_Access IS NULL AND
                   BOM_Rtg_Globals.Get_PLN_Item_Access IS NULL AND
                   BOM_Rtg_Globals.Get_MDL_Item_Access IS NULL AND
                   BOM_Rtg_Globals.Get_OC_Item_Access  IS NULL
                THEN
                        --
                        -- Get respective profile values
                        --
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Checking item type access . . . ');
END IF;

                        IF fnd_profile.value('BOM:STANDARD_ITEM_ACCESS') = '1'
                        THEN
                                BOM_Rtg_Globals.Set_STD_Item_Access
                                ( p_std_item_access     => 4);
                        ELSE

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('No access to Std Items');
END IF;
                                BOM_Rtg_Globals.Set_STD_Item_Access
                                (p_std_item_access      => NULL);
                        END IF;

                        IF fnd_profile.value('BOM:MODEL_ITEM_ACCESS') = '1'
                        THEN
                                BOM_Rtg_Globals.Set_MDL_Item_Access
                                ( p_mdl_item_access     => 1);
                                BOM_Rtg_Globals.Set_OC_Item_Access
                                ( p_oc_item_access      => 2);

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Model/OC items are accessible');
END IF;

                        ELSE
                                BOM_Rtg_Globals.Set_MDL_Item_Access
                                ( p_mdl_item_access     => NULL);
                                BOM_Rtg_Globals.Set_OC_Item_Access
                                ( p_oc_item_access      => NULL);

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('No access to Model/OC items ');
END IF;
                        END IF;

                        IF fnd_profile.value('BOM:PLANNING_ITEM_ACCESS') = '1'
                        THEN
                                BOM_Rtg_Globals.Set_PLN_Item_Access
                                ( p_pln_item_access     => 3);

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Planning item accessible');
END IF;
                        ELSE
                                BOM_Rtg_Globals.Set_PLN_Item_Access
                                ( p_pln_item_access     => NULL);

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('No access to Planning items ');
END IF;

                        END IF;
                END IF;

                --
                -- Use BOM Item Type of the Assembly Item that is queried above
                -- to check if user has access to it.
                --
                IF l_Bom_Item_Type NOT IN
                      ( NVL(BOM_Rtg_Globals.Get_STD_Item_Access, 0),
                        NVL(BOM_Rtg_Globals.Get_PLN_Item_Access, 0),
                        NVL(BOM_Rtg_Globals.Get_OC_Item_Access, 0) ,
                        NVL(BOM_Rtg_Globals.Get_MDL_Item_Access, 0)
                       )
                AND l_Bom_Item_Type <>  5
                THEN
                        l_Token_Tbl(1).Token_Name := 'BOM_ITEM_TYPE';
                        l_Token_Tbl(1).Translate  := TRUE;
                        IF l_Bom_Item_Type = 1
                        THEN
                                l_Token_Tbl(1).Token_Value := 'BOM_MODEL';
                        ELSIF l_Bom_Item_Type = 2
                        THEN
                                l_Token_Tbl(1).Token_Value:='BOM_OPTION_CLASS';
                        ELSIF l_Bom_Item_Type = 3
                        THEN
                                l_Token_Tbl(1).Token_Value := 'BOM_PLANNING';
                        ELSIF l_Bom_Item_Type = 4
                        THEN
                                l_Token_Tbl(1).Token_Value := 'BOM_STANDARD';
                        END IF;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_RTG_AITEM_ACCESS_DENIED'
                         , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                         , p_Token_Tbl          => l_token_tbl
                        );
                        l_return_status := FND_API.G_RET_STS_ERROR ;

                ELSIF l_Bom_Item_Type = 3
                THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=  p_assembly_item_name ;


                        Error_Handler.Add_Error_Token
                        (  p_Message_name       => 'BOM_RTG_AITEM_PLANNING_ITEM'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         , p_Token_Tbl          => l_token_tbl
                         );
                        l_return_status := FND_API.G_RET_STS_ERROR;


                END IF;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check if this item is Asset Item for Enterprise Asset Management. . .');
END IF;
                -- for eAM enhancement,
                -- If eam item type is 1 : Asset Group  or 3 : Rebuildable Component
                -- User cannnot create any type of routings

              /*  IF l_eam_item_type IN ( BOM_Rtg_Globals.G_ASSET_GROUP ,
                                        BOM_Rtg_Globals.G_REBUILDABLE )
                THEN
              */
                /* Fix for bug 5903026 - Allow routings to be created for items with eam_item_type=3 (i.e.)Rebuildable
                   Commented the earlier IF condition. Now we disallow only for G_ASSET_GROUP
                */
                IF l_eam_item_type = BOM_Rtg_Globals.G_ASSET_GROUP
                THEN
                    l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                    l_token_tbl(1).token_value :=  p_assembly_item_name ;


                    Error_Handler.Add_Error_Token
                    (  p_Message_name       => 'BOM_EAM_ITEM_TYPE_INVALID'
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_mesg_token_tbl     => l_mesg_token_tbl
                     , p_Token_Tbl          => l_token_tbl
                    );
                    l_return_status := FND_API.G_RET_STS_ERROR;

                END IF ;

                -- Set Eam Item Type to System Info Record.
                BOM_Rtg_Globals.Set_Eam_Item_Type(p_eam_item_type => l_eam_item_type) ;

                x_return_status   := l_return_status;
                x_mesg_token_tbl  := l_mesg_token_tbl;


       EXCEPTION
           WHEN OTHERS THEN

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


        END Check_Access;

        /*******************************************************************
        * Procedure     : Check_Flow_Routing_Operability
        * Returns       : None
        * Parameters IN : cfm_routing_flag
        * Parameters out: Return Status
        *                 Message Token Table
        * Purpose       : This procedure will check
        *                 If not then an appropriate message and a error status
        *                 will be returned back.
        *********************************************************************/
        PROCEDURE Check_Flow_Routing_Operability
        (  p_assembly_item_name    IN  VARCHAR2
         , p_cfm_routing_flag      IN  NUMBER
         , p_organization_code     IN  VARCHAR2
         , p_organization_id       IN  NUMBER
         , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         IN OUT NOCOPY VARCHAR2
        )
        IS

            l_errorNumber             NUMBER;
            l_OrgIsWsmEnabled         NUMBER;
            l_err_text                VARCHAR2(200) := NULL;
            l_errorMessage            VARCHAR2(200) := NULL;
            l_Mesg_Token_Tbl          Error_Handler.Mesg_Token_Tbl_Type;
            l_Token_Tbl               Error_Handler.Token_Tbl_Type;
            x_install_cfm             BOOLEAN;
            x_status                  VARCHAR2(50);
            x_industry                VARCHAR2(50);
            x_schema                  VARCHAR2(50);

        BEGIN

           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(
                 'Within Routing Header Check flow routing operability . . . ');
           END IF;

           IF     NVL(p_cfm_routing_flag ,2) NOT IN ( 1, 2 ,3)
           AND    p_cfm_routing_flag <> FND_API.G_MISS_NUM
           THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_assembly_item_name;
                        l_token_tbl(2).token_name  := 'CFM_ROUTING_FLAG';
                        l_token_tbl(2).token_value :=
                                       NVL(p_cfm_routing_flag ,2) ;
                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'BOM_RTG_CFM_FLAG_INVALID'
                         , p_token_tbl          => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );

                    x_return_status := FND_API.G_RET_STS_ERROR;


            ELSIF  NVL(p_cfm_routing_flag , 2) =   1
            THEN
                x_install_cfm :=
                 Fnd_Installation.Get_App_Info
                         (application_short_name => 'FLM',
                          status                 => x_status,
                          industry               => x_industry,
                          oracle_schema          => x_schema);

                IF (x_status <> 'I' or x_status is NULL)
                THEN
                           l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                           l_token_tbl(1).token_value :=
                                        p_assembly_item_name;
                           Error_Handler.Add_Error_Token
                           (  p_message_name       => 'BOM_RTG_FLOW_RTG_INVALID'
                            , p_token_tbl          => l_token_tbl
                            , p_mesg_token_tbl     => l_mesg_token_tbl
                            , x_mesg_token_tbl     => l_mesg_token_tbl
                             );

                         x_return_status := FND_API.G_RET_STS_ERROR;

                END IF;

            ELSIF  NVL(p_cfm_routing_flag , 2) =   3
            THEN
            --- WSM (OSFM) Enhancement
            --- For Lot Based Routings, need to check if the Org is WSM Enabled.

                l_OrgIsWsmEnabled := WSMPUTIL.CHECK_WSM_ORG(
                                   p_organization_id => p_organization_id,
                                   x_err_code      => l_errorNumber,
                                   x_err_msg       => l_errorMessage);

                IF (l_OrgIsWsmEnabled = 0)
                THEN l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                     l_token_tbl(1).token_value :=
                                        p_assembly_item_name;
                     l_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                     l_token_tbl(2).token_value := p_organization_code ;

                     Error_Handler.Add_Error_Token
                     (  p_message_name    => 'BOM_RTG_WSM_ORG_INVALID'
                      , p_token_tbl       => l_token_tbl
                      , p_mesg_token_tbl  => l_mesg_token_tbl
                      , x_mesg_token_tbl  => l_mesg_token_tbl
                     );

                     x_return_status := FND_API.G_RET_STS_ERROR;

                END IF;

          END IF;

            -- for eAM enhancement,
            -- If eam item type is 1 : Asset Group and 2 : Asset Activity
            -- Cfm Routing Flag should be 2 : Standard
            -- then Check if org is eam enabled and eam has been installed.
            -- (this validation might not be necessary because
            --  user cannot enter eam item type if eAM is not available. )
            -- If eam item type is null,
            -- Cfm Routing Flag is 1,2  or 3

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check maintenance routings operability for eAM . . .');
END IF;
            IF BOM_Rtg_Globals.Get_Eam_Item_Type = BOM_Rtg_Globals.G_ASSET_ACTIVITY
            THEN
                -- Check cfm routig flag.
                -- the value should be Null or 2
                IF NVL(p_cfm_routing_flag , 2) <> 2
                THEN

                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_assembly_item_name;
                        l_token_tbl(2).token_name  := 'CFM_ROUTING_FLAG';
                        l_token_tbl(2).token_value :=
                                       NVL(p_cfm_routing_flag ,2) ;
                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'BOM_EAM_CFM_FLAG_INVALID'
                         , p_token_tbl          => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );

                        x_return_status := FND_API.G_RET_STS_ERROR;

                ELSE    -- CFM Routing Flag is OK

                        -- Check if eAM has been installed
                        --
                        IF Bom_Eamutil.Enabled <> 'Y'
                        THEN

                           l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                           l_token_tbl(1).token_value :=
                                        p_assembly_item_name;
                           Error_Handler.Add_Error_Token
                           (  p_message_name       => 'BOM_EAM_INVALID'
                            , p_token_tbl          => l_token_tbl
                            , p_mesg_token_tbl     => l_mesg_token_tbl
                            , x_mesg_token_tbl     => l_mesg_token_tbl
                             );

                           x_return_status := FND_API.G_RET_STS_ERROR;

                        END IF ;

                        --- For Lot Based Routings, need to check if the Org is EAM Enabled.
                        IF BOM_EAMUTIL.OrgIsEamEnabled(p_org_id => p_organization_id)
                            <> 'Y'
                        THEN

                            l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                            l_token_tbl(1).token_value :=
                                               p_assembly_item_name;
                            l_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                            l_token_tbl(2).token_value := p_organization_code ;

                            Error_Handler.Add_Error_Token
                            (  p_message_name    => 'BOM_EAM_ORG_INVALID'
                             , p_token_tbl       => l_token_tbl
                             , p_mesg_token_tbl  => l_mesg_token_tbl
                             , x_mesg_token_tbl  => l_mesg_token_tbl
                            );

                            x_return_status := FND_API.G_RET_STS_ERROR;
                         END IF ;

                 END IF ;

             END IF ;

             -- Set Cfm Routing Flag to System Info Record.
             BOM_Rtg_Globals.Set_CFM_Rtg_Flag(p_cfm_rtg_type =>
                                              NVL(p_cfm_routing_flag, 2) ) ;

             x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

        EXCEPTION
           WHEN OTHERS THEN

              l_err_text := G_PKG_NAME || ' Validation (Check Flow Routing Operability) '
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

        END Check_Flow_Routing_Operability ;

        /********************************************************************
        * Procedure     : Check_Attributes
        * Parameters IN : Revised Item Exposed Column record
        *                 Revised Item Unexposed Column record
        *                 Old Revised Item Exposed Column record
        *                 Old Revised Item unexposed column record
        * Parameters out: Return Status
        *                 Mesg Token Table
        * Purpose       : Check_Attrbibutes procedure will validate every
        *                 revised item attrbiute in its entirety.
        **********************************************************************/
        PROCEDURE Check_Attributes
        (  x_return_status          IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , p_rtg_header_Rec         IN  Bom_Rtg_Pub.rtg_header_Rec_Type
         , p_rtg_header_unexp_rec   IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
         , p_old_rtg_header_rec     IN  Bom_Rtg_Pub.rtg_header_Rec_Type
         , p_old_rtg_header_unexp_rec  IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
        )
        IS
        l_err_text              VARCHAR2(2000) := NULL;
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;


        BEGIN

                x_return_status := FND_API.G_RET_STS_SUCCESS;

IF BOM_Rtg_Globals.Get_Debug = 'Y'THEN
    Error_Handler.Write_Debug('Within Rtg Header Check Attributes . . . ');
END IF;

                IF p_rtg_header_rec.eng_routing_flag IS NOT NULL AND
                   p_rtg_header_rec.eng_routing_flag <> FND_API.G_MISS_NUM AND
                   p_rtg_header_rec.eng_routing_flag NOT IN (1,2)
                THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                        Error_Handler.Add_Error_Token
                        (  p_message_name  => 'BOM_RTG_ENG_RTG_TYPE_INVALID'
                         , p_token_tbl     => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                IF p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
                THEN
                    IF  p_rtg_header_rec.eng_routing_flag = FND_API.G_MISS_NUM
                    THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                        Error_Handler.Add_Error_Token
                        (  p_message_name  => 'BOM_RTG_ENG_RTG_TYPE_MISSING'
                         , p_token_tbl     => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                     END IF ;
                END IF;


                IF p_rtg_header_rec.mixed_model_map_flag IS NOT NULL AND
                   p_rtg_header_rec.mixed_model_map_flag
                                            <> FND_API.G_MISS_NUM AND
                   p_rtg_header_rec.mixed_model_map_flag NOT IN (1,2)
                THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                        Error_Handler.Add_Error_Token
                        (  p_message_name  =>'BOM_FLM_RTG_MXDMDL_MAP_INVALID'
                         , p_token_tbl     => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                IF p_rtg_header_rec.ctp_flag IS NOT NULL AND
                   p_rtg_header_rec.ctp_flag <> FND_API.G_MISS_NUM AND
                   p_rtg_header_rec.ctp_flag NOT IN (1,2)
                THEN
                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                        Error_Handler.Add_Error_Token
                        (  p_message_name  => 'BOM_RTG_CTP_INVALID'
                         , p_token_tbl     => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;



                IF p_rtg_header_rec.cfm_routing_flag IS NOT NULL AND
                p_rtg_header_rec.cfm_routing_flag <> FND_API.G_MISS_NUM  AND
                p_old_rtg_header_rec.cfm_routing_flag <> FND_API.G_MISS_NUM  AND
                p_rtg_header_rec.cfm_routing_flag <>
                p_old_rtg_header_rec.cfm_routing_flag
                THEN

                        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                        Error_Handler.Add_Error_Token
                        (  p_message_name  => 'BOM_RTG_CFM_NOT_UPDATABLE'
                         , p_token_tbl     => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;


                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

       EXCEPTION
           WHEN OTHERS THEN

              l_err_text := G_PKG_NAME || ' Validation (Check Attributes) '
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

        /*********************************************************************
        * Procedure     : Check_Required
        * Parameters IN : Rtg Header Exposed column record
        * Parameters out: Mesg Token Table
        *                 Return_Status
        * Purpose       :
        **********************************************************************/
        PROCEDURE Check_Required
        (  x_return_status          IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , p_rtg_header_rec         IN  Bom_Rtg_Pub.rtg_header_Rec_Type
         , p_rtg_header_unexp_rec   IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
         )
        IS
                l_err_text              VARCHAR2(2000);
                l_mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_Token_Tbl             Error_Handler.Token_Tbl_Type;
        BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                IF (  p_rtg_header_unexp_rec.common_routing_sequence_id
                         IS NULL
                      OR
                      p_rtg_header_unexp_rec.common_routing_sequence_id <>
                                                        FND_API.G_MISS_NUM
                    ) AND
                    (  p_rtg_header_rec.common_assembly_item_name IS NOT NULL
                       AND p_rtg_header_rec.common_assembly_item_name =
                                                        FND_API.G_MISS_CHAR
                     )
                THEN
                        --
                        -- If common assembly name is given,
                        -- the common routing sequence is required.
                        --
                        l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                p_rtg_header_rec.assembly_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_message_name   => 'BOM_RTG_COMMON_RTG_REQUIRED'
                         , p_token_tbl      => l_Token_tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         );

                        x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                IF (  p_rtg_header_rec.cfm_routing_flag = 1) AND
                   (  p_rtg_header_unexp_rec.line_id IS NULL OR
                      p_rtg_header_unexp_rec.line_id = FND_API.G_MISS_NUM
                     )
                THEN
                        --
                        -- If the routing is flow routing the line id required.
                        --
                        l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                p_rtg_header_rec.assembly_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_message_name => 'BOM_FLM_RTG_LINE_ID_REQUIRED'
                         , p_token_tbl          => l_Token_tbl
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         );

                        x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;


       EXCEPTION
           WHEN OTHERS THEN

              l_err_text := G_PKG_NAME || ' Validation (Check Required) '
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


        END Check_Required;

        /*****************************************************************
        * Function     : Control (Local function)
        * Parameter IN : Org Level Control
        *                Subinventory Level Control
        *                Item Level Control
        * Returns      : Number
        * Purpose      : Control procedure will take the various level control
        *                values and decide if the Locator is controlled at the
        *                org,subinventory or item level. It will also decide
        *                if the locator is pre-specified or dynamic.
        *******************************************************************/
        FUNCTION CONTROL(org_control      IN    number,
                    sub_control      IN    number,
                    item_control     IN    number )
                    RETURN NUMBER
        IS
                locator_control number;
        BEGIN

                IF (org_control = 1) then
                        locator_control := 1;
                ELSIF (org_control = 2) then
                        locator_control := 2;
                ELSIF (org_control = 3) then
                        locator_control := 3;
                ELSIF (org_control = 4) then
                        IF (sub_control = 1) then
                                locator_control := 1;
                        ELSIF (sub_control = 2) then
                                locator_control := 2;
                        ELSIF (sub_control = 3) then
                                locator_control := 3;
                        ELSIF (sub_control = 5) then
                                IF (item_control = 1) then
                                        locator_control := 1;
                                ELSIF (item_control = 2) then
                                        locator_control := 2;
                                ELSIF (item_control = 3) then
                                        locator_control := 3;
                                ELSIF (item_control IS NULL) then
                                        locator_control := sub_control;
                                END IF;
                        END IF;
                END IF;

                RETURN locator_control;

        END CONTROL;


        /*********************************************************************
        -- Check if Subinventory Exists
        *********************************************************************/
        FUNCTION Check_SubInv_Exists(  p_organization_id  IN  NUMBER
                                     , p_subinventory     IN VARCHAR2 )
        RETURN BOOLEAN
        IS

           -- cursor for checking subinventory exsiting
           CURSOR l_subinv_csr         ( p_organization_id NUMBER
                                       , p_subinventory    VARCHAR2)
           IS
              SELECT 'SubInv exists'
              FROM   SYS.DUAL
              WHERE  NOT EXISTS ( SELECT  null
                                  FROM mtl_secondary_inventories
                                  WHERE organization_id =  p_organization_id
                                  AND secondary_inventory_name = p_subinventory
                                 );


                l_ret_status BOOLEAN := TRUE ;

        BEGIN

            FOR l_subinv_rec  IN l_subinv_csr  ( p_organization_id
                                       , p_subinventory )
            LOOP
                l_ret_status := FALSE ;
            END LOOP ;
                RETURN l_ret_status ;

        END Check_SubInv_Exists ;



        /*********************************************************************
        --  Get Restrict Subinventory Flag and Inventory Asset Flag for the Item
        *********************************************************************/
        PROCEDURE Get_SubInv_Flag (     p_assembly_item_id IN  NUMBER
                                      , p_organization_id  IN  NUMBER
                                      , x_rest_subinv_code IN OUT NOCOPY VARCHAR2
                                      , x_inv_asset_flag   IN OUT NOCOPY VARCHAR2 )
        IS

           -- cursor for checking subinventory exsiting
           CURSOR l_subinv_flag_csr  ( p_organization_id  NUMBER
                                     , p_assembly_item_id NUMBER)
           IS
               SELECT   DECODE(restrict_subinventories_code, 1, 'Y', 'N')
                         restrict_code
                      , inventory_asset_flag
               FROM   MTL_SYSTEM_ITEMS
               WHERE  inventory_item_id = p_assembly_item_id
               AND    organization_id   = p_organization_id  ;


        BEGIN

            FOR l_subinv_flag_rec  IN l_subinv_flag_csr  ( p_organization_id
                                                         , p_assembly_item_id )
            LOOP
                x_rest_subinv_code := l_subinv_flag_rec.restrict_code ;
                x_inv_asset_flag   := l_subinv_flag_rec.inventory_asset_flag ;
            END LOOP ;

        END Get_SubInv_Flag ;


        /*********************************************************************
        -- Check Locator
        *********************************************************************/
        -- Local function to verify locators
        FUNCTION Check_Locators (  p_organization_id  IN NUMBER
                                 , p_assembly_item_id IN NUMBEr
                                 , p_locator_id       IN NUMBER
                                 , p_subinventory     IN VARCHAR2 )
        RETURN BOOLEAN
        IS
            Cursor CheckDuplicate is
            SELECT 'checking for duplicates' dummy
            FROM sys.dual
            WHERE EXISTS (
                           SELECT null
                           FROM mtl_item_locations
                           WHERE organization_id = p_organization_id
                           AND   inventory_location_id = p_locator_id
                           AND   subinventory_code <>  p_subinventory
                          );

            x_control   NUMBER;
            l_success   BOOLEAN;
            l_dummy     VARCHAR2(20) ;

        BEGIN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Check Locators. . .Locator Id is ' || to_char(p_locator_id));
END IF;

           l_org_locator_control := 0 ;
           l_item_locator_control := 0;


           -- Get Value of Org_Locator and item_Locator.
           SELECT stock_locator_control_code
           INTO l_org_locator_control
           FROM mtl_parameters
           WHERE organization_id = p_organization_id;

           -- Get Value of Item Locator
           SELECT location_control_code
           INTO l_item_locator_control
           FROM mtl_system_items
           WHERE organization_id = p_organization_id
           AND inventory_item_id = p_assembly_item_id ;

           -- Get if locator is restricted or unrestricted
           SELECT RESTRICT_LOCATORS_CODE
           INTO l_item_loc_restricted
           FROM mtl_system_items
           WHERE organization_id = p_organization_id
           AND inventory_item_id = p_assembly_item_id ;


IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Org - Stock Locator Control : '|| to_char(l_org_locator_control)  );
    Error_Handler.Write_Debug('Item - Location Control : '|| to_char(l_item_locator_control)  );
    Error_Handler.Write_Debug('Item - Restrict Locator : '|| to_char(l_item_loc_restricted)  );
END IF;

        /**************************************
        -- Locator_Control_Code
        -- 1 : No Locator Control
        -- 2 : Prespecified Locator Control
        -- 3 : Dynamic Entiry Locator Control
        -- 4 : Determined by Sub Inv Level
        -- 5 : Determined at Item Level
        ***************************************/
/* Commented this for BUG 3872490
           --
           -- Locator cannot be NULL is if locator restricted
           --
           IF p_locator_id IS NULL
           AND l_item_loc_restricted = 1
           THEN
               l_locator_control := 4;
               RETURN FALSE;
           ELSIF p_locator_id IS NULL
           AND l_item_loc_restricted = 2
           THEN
               RETURN TRUE;
           END IF;
*/
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Sub Inv - Loc Control : '|| to_char(l_sub_locator_control)  );
END IF;



           IF l_org_locator_control  is not null AND
              l_sub_locator_control  is not null AND
              l_item_locator_control is not null
           THEN

                  x_control := BOM_Validate_Rtg_Header.Control
                  (  Org_Control  => l_org_locator_control,
                     Sub_Control  => l_sub_locator_control,
                     Item_Control => l_item_locator_control
                  );

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Calling BOM_Validate_Rtg_Header.Control. Loc Control '||
                              to_char(x_control)  );
END IF;
                  l_locator_control := x_control;
                  -- Variable to identify if the dynamic loc.
                  -- Message must be logged.

                  IF x_Control = 1 THEN  -- No Locator Control
			-- Added following If for BUG 3872490
		     If p_locator_id is NOT NULL
			AND p_subinventory is NOT NULL
		     Then
                      RETURN FALSE;      -- No Locator and Locator Id is
                                         -- supplied then raise Error
		     Else
			Return TRUE;
		     End If;            -- End of BUG 3872490
                  ELSIF x_Control = 2   -- PRESPECIFIED
                     OR x_Control = 3   -- DYNAMIC ENTRY -- bug 3761854
                  THEN
                     BEGIN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Checking when x_control returned 2 and ' ||
                                ' item locator is ' ||
                                to_char(l_item_locator_control));
END IF;

			--BUG 3872490
            		-- Locator cannot be NULL is if locator control is prespecified
            		IF p_locator_id IS NULL
            		AND p_subinventory is NOT NULL
            		THEN
                		l_locator_control := 4;
                		RETURN FALSE;
            		END IF;
           -- If restrict locators is Y then check in
           -- mtl_secondary_locators if the item is
           -- assigned to the subinventory/location
           -- combination If restrict locators is N then
           -- check that the locator exists
           -- and is assigned to the subinventory and this
           -- combination is found in mtl_item_locations.

                       IF l_item_loc_restricted = 1 -- Restrict Locators  = YES
                       THEN
                           -- Check for restrict Locators YES
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Before Checking for restrict Locators Yes. ' );
END IF;
                           SELECT 'Valid'
                           INTO l_dummy
                           FROM mtl_item_locations mil,
                                mtl_secondary_locators msl
                           WHERE msl.inventory_item_id = p_assembly_item_id
                           AND msl.organization_id     = p_organization_id
                           AND msl.subinventory_code   = p_subinventory
                           AND msl.secondary_locator   = p_locator_id
                           AND mil.inventory_location_id = msl.secondary_locator
                           AND mil.organization_id     =   msl.organization_id
                           AND NVL(mil.disable_date, SYSDATE+1) > SYSDATE ;

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Restrict locators is Y . ' ||
                                'Sub Inv :  ' || p_subinventory || 'Comp Loc : ' || to_char(p_locator_id )
                                || ' are valid.'  );
END IF;

                           -- If no exception is raised then the
                           -- Locator is Valid
                           RETURN TRUE;

                       ELSE
                           -- Check for restrict Locators NO

                           SELECT 'Valid'
                           INTO l_dummy
                           FROM mtl_item_locations mil
                           WHERE mil.subinventory_code = p_subinventory
                           AND   mil.inventory_location_id = p_locator_id
                           AND    mil.organization_id      = p_organization_id
                           AND NVL(mil.DISABLE_DATE, SYSDATE+1) > SYSDATE;

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Restrict locators is No . ' ||
                                'Sub Inv :  ' || p_subinventory || 'Comp Loc : ' || to_char(p_locator_id )
                                || ' are valid.'  );
END IF;

                           -- If no exception is raised then the
                           -- Locator is Valid
                           RETURN TRUE;

                       END IF;

                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Locator is invlaid . ' );
END IF ;

                          RETURN FALSE;
                    END; -- x_control=2 Ends

            /*     ELSIF x_Control = 3 THEN
                    -- DYNAMIC LOCATORS ARE NOT ALLOWED IN OI.
                    -- Dynamic locators are not allowed in open
                    -- interface, so raise an error if the locator
                    -- control is dynamic.
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug  ('Dynamic Locator Control. ' ) ;
END IF ;
                    l_locator_control := 3;


                    RETURN FALSE;
            */   ELSE
                    -- dbms_output.put_line
                    -- ('Finally returing a true value . . .');
                    RETURN TRUE;

                 END IF; -- X_control Checking Ends

              ELSE
                 RETURN TRUE;
              END IF;  -- If Locator Control check Ends.

        END Check_Locators;


        /********************************************************************
        * Procedure     : Check_Entity
        * Parameters IN : Rtg Header Exposed column record
        *                 Rtg Header Unexposed column record
        *                 Old Rtg Header exposed column record
        *                 Old Rtg Header unexposed column record
        * Parameters out: Message Token Table
        *                 Return Status
        * Purpose       : This procedure will perform the business logic
        *                 validation for the BOM Header Entity. It will perform
        *                 any cross entity validations and make sure that the
        *                 user is not entering values which may disturb the
        *                 integrity of the data.
        *********************************************************************/
        PROCEDURE Check_Entity
        ( p_rtg_header_rec           IN OUT NOCOPY Bom_Rtg_Pub.rtg_header_Rec_Type
        , p_rtg_header_unexp_rec     IN OUT NOCOPY Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
        , p_old_rtg_header_rec       IN  Bom_Rtg_Pub.rtg_header_Rec_Type
        , p_old_rtg_header_unexp_rec IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
        , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        , x_return_status            IN OUT NOCOPY VARCHAR2
         )
        IS
                l_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
                l_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type;
                l_Token_Tbl      Error_Handler.Token_Tbl_Type;
                l_dummy          VARCHAR2(1);
                l_HasOps         BOOLEAN := FALSE;

                l_bom_item_type    NUMBER;
                l_pto_flag         VARCHAR2(1);
                l_eng_item_flag    VARCHAR2(1);
                l_bom_enabled_flag VARCHAR2(1);
                l_ser_num_control_code MTL_SYSTEM_ITEMS.SERIAL_NUMBER_CONTROL_CODE%TYPE;

                l_sub_inv_exists            BOOLEAN := FALSE;
                l_allow_expense_to_asset    VARCHAR2(10);
                l_rest_subinv_code          VARCHAR2(1);
                l_inv_asset_flag            VARCHAR2(1);


                l_err_text            VARCHAR2(2000);

                -- cursor for selecting assembly item attributes
                CURSOR   c_item(
                  p_org_id  NUMBER,
                  p_item_id NUMBER
                )
                IS
                SELECT   bom_item_type
                       , pick_components_flag
                       , bom_enabled_flag
                       , eng_item_flag
                       , serial_number_control_code
                FROM MTL_SYSTEM_ITEMS
                WHERE organization_id   = p_org_id
                AND   inventory_item_id = p_item_id;

                -- cursor for checking common assembly chain
                CURSOR c_CheckCommon(
                  P_assembly_item_id       NUMBER,
                  P_org_id                 NUMBER,
                  P_alt_routing_code       VARCHAR2
                  )
                IS
                SELECT NVL(common_routing_sequence_id, routing_sequence_id)
                         common_routing,  routing_sequence_id
                FROM bom_operational_routings
                WHERE assembly_item_id = P_assembly_item_id
                AND organization_id  = P_org_id
                AND NVL(alternate_routing_designator,'XXXX') =
                                           NVL(P_alt_routing_code, 'XXXX');

                -- cursor for verifying common routing attributes
                CURSOR c_VerifyCommonRtg(
                  P_cmn_rtg_id    NUMBER,
                  P_rtg_type      NUMBER,
                  P_item_id       NUMBER,
                  P_org_id        NUMBER,
                  p_cfm_rtg_flag  NUMBER,
                  P_alt_desg    VARCHAR2) is
                SELECT 1 dummy
                FROM sys.dual
                WHERE not exists (
                    SELECT NULL
                    FROM bom_operational_routings bor
                    WHERE bor.routing_sequence_id = P_cmn_rtg_id
                    AND NVL(bor.alternate_routing_designator,
                    'Primary Alternate') = NVL(P_alt_desg, 'Primary Alternate')
                    AND bor.common_routing_sequence_id =
                        bor.routing_sequence_id
                    AND   bor.assembly_item_id <> P_item_id
                    AND   bor.organization_id = P_org_id
                    AND   nvl(bor.cfm_routing_flag, 2) = p_cfm_rtg_flag
                    AND   bor.routing_type =
                          decode(P_rtg_type, 1, 1, bor.routing_type));

                -- cursor for checking operaitons exist for the current routing.
                CURSOR c_check_Ops(
                p_routing_sequence_id NUMBER)
                IS
                SELECT 'Y' has_ops
                FROM sys.dual
                WHERE exists ( Select null
                FROM Bom_Operation_Sequences
                WHERE  routing_sequence_id =
                                  p_routing_sequence_id );

                -- CTP flag check for routing type
                CURSOR c_check_ctp_rtg(
                  p_assembly_item_id       NUMBER,
                  p_organization_id        NUMBER,
                  p_common_routing_sequence_id NUMBER
                  )
                IS
                SELECT 'Y'
                FROM sys.dual
                WHERE exists ( Select null
                               FROM bom_operational_routings
                               WHERE  common_routing_sequence_id <>
                                              p_common_routing_sequence_id
                               AND    CTP_flag = 1
                               AND    organization_id =  p_organization_id
                               AND    assembly_item_id = p_assembly_item_id ) ;


                -- cursor for checking if Flow Routing and referring
                --  common routing has active operation sequences
                CURSOR c_check_active_ops(
                   p_routing_sequence_id    NUMBER
                )
                IS
                SELECT 'Y'
                FROM sys.dual
                WHERE exists ( Select null
                FROM  Bom_Operation_Sequences
                WHERE   routing_sequence_id =p_routing_sequence_id
                AND    NVL(disable_date, trunc(sysdate) + 1)
                         >   trunc(sysdate)
                );


                -- cursor for verifying if Routing for Same Item
                -- with active Mixed Model Map Flag does not exist
                CURSOR c_check_active_mixed(
                   P_assembly_item_id       NUMBER,
                   P_organization_id        NUMBER,
                   p_line_id                NUMBER,
                   p_common_routing_sequence_id NUMBER
                )
                IS
                SELECT 'Y'
                FROM sys.dual
                WHERE exists ( Select null
                   FROM Bom_Operational_Routings
                   WHERE  organization_id = P_organization_id
                   AND    assembly_item_id = P_assembly_item_id
                   AND    mixed_model_map_flag = 1
                   AND    line_id = p_line_id
                   AND    common_routing_sequence_id
                        <> p_common_routing_sequence_id );

                --cursor for check the priority for standard routing
                CURSOR c_check_priority(
                   p_assembly_item_id       NUMBER,
                   p_organization_id        NUMBER,
                   p_priority               NUMBER,
                   p_common_routing_sequence_id NUMBER
                )
                IS
                SELECT 'Y'
                FROM sys.dual
                WHERE  exists ( Select null
                  FROM Bom_Operational_Routings
                  WHERE organization_id =  p_organization_id
                  AND Assembly_Item_Id = p_assembly_item_id
                  AND priority = p_priority
                  AND common_routing_sequence_id <>
                          p_common_routing_sequence_id
                );


                -- cursors for completion_subinventory check
                CURSOR c_Restrict_SubInv_Asset IS
                SELECT locator_type
                FROM mtl_item_sub_ast_trk_val_v
                WHERE inventory_item_id =p_rtg_header_unexp_rec.assembly_item_id
                AND organization_id = p_rtg_header_unexp_rec.organization_id
                AND secondary_inventory_name =
                        p_rtg_header_rec.completion_subinventory;

                CURSOR c_Restrict_SubInv_Trk IS
                SELECT locator_type
                FROM mtl_item_sub_trk_val_v
                WHERE inventory_item_id = p_rtg_header_unexp_rec.assembly_item_id
                AND organization_id   = p_rtg_header_unexp_rec.organization_id
                AND secondary_inventory_name =
                        p_rtg_header_rec.completion_subinventory;
                CURSOR c_SubInventory_Asset IS
                SELECT locator_type
                FROM mtl_sub_ast_trk_val_v
                WHERE organization_id = p_rtg_header_unexp_rec.organization_id
                AND secondary_inventory_name =
                        p_rtg_header_rec.completion_subinventory;

                CURSOR c_Subinventory_Tracked IS
                SELECT locator_type
                FROM mtl_subinventories_trk_val_v
                WHERE organization_id = p_rtg_header_unexp_rec.organization_id
                AND secondary_inventory_name =
                        p_rtg_header_rec.completion_subinventory;

		CURSOR c_Check_BOM IS
		SELECT NULL from dual
		WHERE exists
		(SELECT 1	/* Checking for the BOM components operation seq. num. for alternate */
		FROM BOM_BILL_OF_MATERIALS BOM, BOM_COMPONENT_OPERATIONS BCO
		WHERE BOM.ORGANIZATION_ID = p_rtg_header_unexp_rec.organization_id
		AND BOM.ASSEMBLY_ITEM_ID = p_rtg_header_unexp_rec.assembly_item_id
		AND BOM.ALTERNATE_BOM_DESIGNATOR = p_rtg_header_rec.alternate_routing_code
		AND BOM.BILL_SEQUENCE_ID = BCO.BILL_SEQUENCE_ID)
		OR exists
		(SELECT 1	/* Checking for the BOM components operation seq. num. for alternate */
		FROM BOM_BILL_OF_MATERIALS BOM, BOM_INVENTORY_COMPONENTS BIC
		WHERE BOM.ORGANIZATION_ID = p_rtg_header_unexp_rec.organization_id
		AND BOM.ASSEMBLY_ITEM_ID = p_rtg_header_unexp_rec.assembly_item_id
		AND BOM.ALTERNATE_BOM_DESIGNATOR = p_rtg_header_rec.alternate_routing_code
		AND BOM.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
		AND BIC.OPERATION_SEQ_NUM > 1)
		;
       BEGIN

       --
       -- Performing Entity Validation in routing header
       --
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Performing Entitity Validation for Rtg header. . .') ;
       END IF;


                --
                -- Check Assembly item attributes.
                --
                FOR l_item_rec IN c_item(
                           p_org_id  => p_rtg_header_unexp_rec.organization_id
                         , p_item_id => p_rtg_header_unexp_rec.assembly_item_id
                             )
                LOOP
                   l_bom_item_type    := l_item_rec.bom_item_type ;
                   l_pto_flag         := l_item_rec.pick_components_flag ;
                   l_eng_item_flag    := l_item_rec.eng_item_flag ;
                   l_bom_enabled_flag := l_item_rec.bom_enabled_flag ;
                   l_ser_num_control_code := l_item_rec.serial_number_control_code;
                END LOOP ;

                --bug:5235647 Allow routing creation for items having
                --serial control as 'None' or 'Pre-Defined' only.
		/* Fix for bug 5962485 - Network routings are allowed only for
		   lot controlled items having serial control as 'None' or 'Pre-Defined' only.
		   Lot control check is done in BOMRPVTB.pls, serial control check is done here.
		   Modified If condition to check for Network Routings only (i.e.)cfm_routing_flag = 3 */

		IF  ( p_rtg_header_rec.cfm_routing_flag = 3 AND
				( ( l_ser_num_control_code <> 1 ) AND ( l_ser_num_control_code <> 2 ) ) )
		THEN
			Error_Handler.Add_Error_Token
			(  p_message_name   => 'BOM_ASSEMBLY_NOT_SERIAL'
			, p_mesg_token_tbl => l_Mesg_Token_Tbl
			, x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
			, p_token_tbl      => g_token_tbl
			);

			l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

                --
                -- Item Attribute: BOM Allowed must be set Yes for the item
                -- you are creating routing for.
                --
                IF l_bom_enabled_flag <> 'Y'
                THEN
                  g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                  g_token_tbl(1).token_value :=
                                       p_rtg_header_rec.assembly_item_name;

                  Error_Handler.Add_Error_Token
                  (  p_message_name   => 'BOM_RTG_AITEM_BOM_NOT_ALLOWED'
                   , p_mesg_token_tbl => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , p_token_tbl      => g_token_tbl
                  );

                  l_return_status := FND_API.G_RET_STS_ERROR;

                END IF ;

                --
                -- User must not create routing for pick to order items.
                -- pick_components_flag  must be Yes.
                --
                IF l_pto_flag <>  'N'
                THEN
                    g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                    g_token_tbl(1).token_value :=
                                    p_rtg_header_rec.assembly_item_name;

                    Error_Handler.Add_Error_Token
                    (  p_message_name   => 'BOM_RTG_AITEM_PTO_ITEM'
                      , p_mesg_token_tbl => l_Mesg_Token_Tbl
                      , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                      , p_token_tbl      => g_token_tbl
                     );

                    l_return_status := FND_API.G_RET_STS_ERROR;
                END IF ;

                /*************************************************
                -- Current Release, User cannot create Engineering
                -- Routing throught Routing BO.
                --
                -- If eng_routing_flag 2 (routing_type = 1 : Mfg),
                -- then Item Attribute :  Eng_Item_Flag must be No.
                -- If eng_routing_flag 1 (routing_type 2 : Eng)
                -- then Eng_Item_Flag must be Yes or No.
                --
                IF  p_rtg_header_unexp_rec.routing_type = 1 -- Mfg Routing
                AND l_eng_item_flag <> 'N'
                THEN
                    g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                    g_token_tbl(1).token_value :=
                                       p_rtg_header_rec.assembly_item_name;

                     Error_Handler.Add_Error_Token
                     (  p_message_name   => 'BOM_RTG_AITEMORRTG_TYP_INVALID'
                      , p_mesg_token_tbl => l_Mesg_Token_Tbl
                      , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                      , p_token_tbl      => g_token_tbl
                     );
                    l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                IF  p_rtg_header_unexp_rec.routing_type = 2  -- Eng Routing
                AND l_eng_item_flag not in ( 'N', 'Y')
                THEN
                    g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                    g_token_tbl(1).token_value :=
                                       p_rtg_header_rec.assembly_item_name;

                    Error_Handler.Add_Error_Token
                    (  p_message_name   => 'BOM_RTG_AITEMORRTG_TYP_INVALID'
                     , p_mesg_token_tbl => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_token_tbl      => g_token_tbl
                    );

                   l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
                *************************************************/

                --  User is not allowed to create Eng Routing throgh
                --  Routing BO in this release.
                --  Hence Engineering Item is errored out in Check Access.
                --  Also missmach between routing type and Eng Itme Flag
                --  should be errored-out here.

                -- Bug 4240258 Now enabling the creation of Eng Routing for
                -- Mfg Item.So commenting the OR part.

                IF  (p_rtg_header_unexp_rec.routing_type = 1  -- Mfg Routing
                     AND l_eng_item_flag <>  'N')             -- Eng Item
                --OR  (p_rtg_header_unexp_rec.routing_type = 2  -- Eng Routing
                 --    AND l_eng_item_flag <> 'Y' )             -- Mfg Item
                THEN
                    g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                    g_token_tbl(1).token_value :=
                                       p_rtg_header_rec.assembly_item_name;

                    Error_Handler.Add_Error_Token
                    (  p_message_name   => 'BOM_RTG_AITRTG_TYPE_MISSMATCH'
                     , p_mesg_token_tbl => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_token_tbl      => g_token_tbl
                    );

                   l_return_status := FND_API.G_RET_STS_ERROR;
                END IF;


                --
                -- User must not create routing for planning item
                -- Bom_Item_Type = 3.
                IF l_bom_item_type =  3
                THEN
                    g_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
                    g_token_tbl(1).token_value :=
                                    p_rtg_header_rec.assembly_item_name;

                    Error_Handler.Add_Error_Token
                    (  p_message_name   => 'BOM_RTG_AITEM_PLANING_ITEM'
                     , p_mesg_token_tbl => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                     , p_token_tbl      => g_token_tbl
                     );

                    l_return_status := FND_API.G_RET_STS_ERROR;
                END IF ;


                --
                -- If alternate routing code is NOT NULL, then Primary routing
                -- must exist if the user is trying to create an Alternate
                --
                IF p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                AND  p_rtg_header_rec.alternate_routing_code IS NOT NULL
                AND p_rtg_header_rec.alternate_routing_code <>
                         FND_API.G_MISS_CHAR
                THEN
                    BEGIN
                        SELECT '1'
                          INTO l_dummy
                          FROM bom_operational_routings
                         WHERE  alternate_routing_designator IS NULL
                           AND assembly_item_id =
                                        p_rtg_header_unexp_rec.assembly_item_id
                           AND organization_id =
                                        p_rtg_header_unexp_rec.organization_id;

                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        l_return_status :=
                                                        FND_API.G_RET_STS_ERROR;
					l_token_tbl(1).token_name :=
                                                'ASSEMBLY_ITEM_NAME';
                                        l_token_tbl(1).token_value :=
                                            p_rtg_header_rec.assembly_item_name;
                                        Error_Handler.Add_Error_Token
                                        (  p_message_name    =>
                                                'BOM_RTG_CANNOT_ADD_ALTERNATE'
                                         , p_token_tbl       => l_token_tbl
                                         , p_mesg_token_tbl  => l_mesg_token_tbl
                                         , x_mesg_token_tbl  => l_mesg_token_tbl
                                         );
                    END;

		-- Added for switch routing project for patchset I
		-- When creating alternate routings, check if there are BOMs
		-- having references to the primary routing of the assembly
		-- which may become invalid once an alternate is created

		    FOR rec1 IN c_Check_BOM LOOP
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
                            Error_Handler.Add_Error_Token
			    (p_message_name => 'BOM_ALT_RTG_REF_BOM'
			    , p_token_tbl   => l_token_tbl
			    , p_mesg_token_tbl  => l_mesg_token_tbl
			    , x_mesg_token_tbl  => l_mesg_token_tbl
			    , p_message_type    => 'W'
			    );
			END IF;
		    END LOOP;
                END IF;

                --Bug:4293475 Checking for the disable date before creating an
                --alternate for a routing.If the alternate is disabled then
                --throwing an error.

                IF       p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                    AND  p_rtg_header_rec.alternate_routing_code IS NOT NULL
                    AND  p_rtg_header_rec.alternate_routing_code <> FND_API.G_MISS_CHAR
                THEN
                  BEGIN
                    SELECT '1'
                    INTO l_dummy
                    FROM bom_alternate_designators
                    WHERE
                        alternate_designator_code = p_rtg_header_rec.alternate_routing_code
                    AND organization_id = p_rtg_header_unexp_rec.organization_id
                    AND disable_date is not null
                    AND disable_date <= sysdate;

                    l_return_status := FND_API.G_RET_STS_ERROR;
                    l_token_tbl.delete;
                    l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                    l_token_tbl(1).token_value := p_rtg_header_rec.assembly_item_name;
                    l_token_tbl(2).token_name := 'ALTERNATE_ROUTING_CODE';
                    l_token_tbl(2).token_value := p_rtg_header_rec.alternate_routing_code;

                    Error_Handler.Add_Error_Token
                                          (  p_message_name   => 'BOM_RTG_ALTERNATE_DISABLED'
                                          , p_token_tbl       => l_token_tbl
                                          , p_mesg_token_tbl  => l_mesg_token_tbl
                                          , x_mesg_token_tbl  => l_mesg_token_tbl
                                          );
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        NULL; -- No Error
                  END;
                END IF;
                --Bug:4293475 ends

                -- Common Routing Validation
                IF  p_rtg_header_unexp_rec.common_routing_sequence_id <>
                    p_rtg_header_unexp_rec.routing_sequence_id
                THEN

                -- Common routing's alt must be same as current routing's alt
                -- Common routing cannot have same assembly_item_id as current routing
                -- Common routing must have the same org id as current routing
                -- Common routing must be mfg routing if current routing is a mfg routing
                -- Common routing must have same CFM type as current routing

                    FOR l_Common_rec in c_VerifyCommonRtg
                    ( p_cmn_rtg_id => p_rtg_header_unexp_rec.common_routing_sequence_id,
                      p_rtg_type   => p_rtg_header_unexp_rec.routing_type,
                      p_item_id    => p_rtg_header_unexp_rec.assembly_item_id,
                      P_org_id     => p_rtg_header_unexp_rec.organization_id,
                      p_cfm_rtg_flag  => p_rtg_header_rec.cfm_routing_flag,
                      p_alt_desg   => p_rtg_header_rec.alternate_routing_code)
                    LOOP
                        l_token_tbl.delete;
                        l_token_tbl(1).token_name :='COMMON_ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                p_rtg_header_rec.common_assembly_item_name;
                        l_token_tbl(2).token_name := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(2).token_value :=
                                p_rtg_header_rec.assembly_item_name;

                        Error_Handler.Add_Error_Token
                        (  p_message_name       =>
                                        'BOM_RTG_ASSY_COMMON_RRG_SEQ'
                         , p_token_tbl          => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                        );
                        l_return_status := FND_API.G_RET_STS_ERROR;
                    END LOOP ;-- validate common


                    --
                    -- If the user is assigning a common assembly to the current
                    -- routing then the common assembly must not already have a
                    -- common assembly. i.e User cannot create a chain of common
                    -- routing
                    BEGIN
                        SELECT '1'
                        INTO l_dummy
                        FROM bom_operational_routings
                        WHERE routing_sequence_id =
                              p_rtg_header_unexp_rec.common_routing_sequence_id
                        AND    NVL(common_routing_sequence_id,
                                  routing_sequence_id) <> routing_sequence_id;

                        l_token_tbl.delete;
                        l_token_tbl(1).token_name :='COMMON_ASSEMBLY_ITEM_NAME';
                        l_token_tbl(1).token_value :=
                                p_rtg_header_rec.common_assembly_item_name;
                        l_token_tbl(2).token_name := 'ASSEMBLY_ITEM_NAME';
                        l_token_tbl(2).token_value :=
                                p_rtg_header_rec.assembly_item_name;
                        Error_Handler.Add_Error_Token
                        (  p_message_name       =>
                                'BOM_RTG_ASSY_COMMON_OTHER_ASSY'
                         , p_token_tbl          => l_token_tbl
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        l_return_status := FND_API.G_RET_STS_ERROR;

                    EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                        NULL;

                    END;


                    --
                    -- Common_assembly_item_id check
                    -- If Routing already has its child operation sequences, User
                    -- cannnot assign Common_Assembly_Item_Id.
                    --
                    IF  p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
                    THEN

                        FOR l_Operation in c_check_ops(
                           p_routing_sequence_id =>
                           p_rtg_header_unexp_rec.routing_sequence_id)
                        LOOP

                           l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                           l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                                Error_Handler.Add_Error_Token
                                (  p_message_name       =>
                                        'BOM_RTG_COMMON_RTG_NOUPDATABLE'
                                 , p_token_tbl          => l_token_tbl
                                 , p_mesg_token_tbl     => l_mesg_token_tbl
                                 , x_mesg_token_tbl     => l_mesg_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;

                        END LOOP;
                    END IF ;

                END IF ;  -- End of Common Routing Valdiation

                --
                -- If the user is trying to perform an update, and the routing
                -- is referencing another routing as common, then this routing
                -- is not updateable.
                --
/* This check is not required as we should be able to update the routing details even for
   a routing referencing another routing as common -- bug 2923716
		IF  p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
                THEN

                    FOR l_checkCommon IN c_CheckCommon
                    (  P_assembly_item_id => p_rtg_header_unexp_rec.assembly_item_id
                     , P_org_id          => p_rtg_header_unexp_rec.organization_id
                     , P_alt_routing_code=>p_rtg_header_rec.alternate_routing_code)
                    LOOP
                        IF l_CheckCommon.common_routing <>
                           l_CheckCommon.routing_sequence_id
                        THEN
                            l_token_tbl.delete;
                            l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                            l_token_tbl(1).token_value :=
                                               p_rtg_header_rec.assembly_item_name;
                            Error_Handler.Add_Error_Token
                            (  p_message_name       =>
                                        'BOM_RTG_ASSY_COMMON_REF_COMMON'
                             , p_token_tbl          => l_token_tbl
                             , p_mesg_token_tbl     => l_mesg_token_tbl
                             , x_mesg_token_tbl     => l_mesg_token_tbl
                            );
                           l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;

                    END LOOP;
                END IF ;
*/
                --
                -- CTP flag check
                -- If the CTP Flag is 1:Yes,  Verify if Routing for
                -- Same Item with active CTP Flag does not exist.

                IF    p_rtg_header_rec.ctp_flag = 1
                AND ( p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                       OR  ( p_rtg_header_rec.transaction_type
                                      = BOM_Rtg_Globals.G_OPR_UPDATE
                             AND  p_rtg_header_rec.ctp_flag <>
                                        p_old_rtg_header_rec.ctp_flag )
                      )
                THEN

                     -- for flow routing type, CFM routing flag = 1;
                     FOR CTP_Rtg_rec in C_check_CTP_Rtg
                         (  p_assembly_item_id =>
                              p_rtg_header_unexp_rec.assembly_item_id
                          , p_organization_id  =>
                                p_rtg_header_unexp_rec.organization_id
                          , p_common_routing_sequence_id =>
                             p_rtg_header_unexp_rec.common_routing_sequence_id
                          )
                     LOOP
                           l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                           l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                           Error_Handler.Add_Error_Token
                                (  p_message_name       =>
                                        'BOM_RTG_CTP_ALREADY_EXISTS'
                                 , p_token_tbl          => l_token_tbl
                                 , p_mesg_token_tbl     => l_mesg_token_tbl
                                 , x_mesg_token_tbl     => l_mesg_token_tbl
                                 );
                           l_return_status := FND_API.G_RET_STS_ERROR;
                     END LOOP ;

                END IF;

                --
                -- For UPDATEs, conditionally non updatable Column Check.If Flow
                -- Routing and referring common routing has active operation
                -- sequences, user cannot update line code.
                --
                IF  p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
                AND p_rtg_header_rec.cfm_routing_flag = 1
                AND p_rtg_header_unexp_rec.line_id
                                <> p_old_rtg_header_unexp_rec.line_id
                THEN

                      FOR l_active_ops_rec in c_check_active_ops(
                           p_routing_sequence_id =>
                           p_rtg_header_unexp_rec.common_routing_sequence_id)
                      LOOP

                           l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                           l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                           Error_Handler.Add_Error_Token
                           (  p_message_name       =>
                                        'BOM_FLM_RTG_LINED_NO_UPDATABLE'
                            , p_token_tbl          => l_token_tbl
                            , p_mesg_token_tbl     => l_mesg_token_tbl
                            , x_mesg_token_tbl     => l_mesg_token_tbl
                           );
                           l_return_status := FND_API.G_RET_STS_ERROR;

                      END LOOP;
                END IF;

                --
                -- If Mixed Model Map Flag is 1: Yes, verify if Routing for Same
                -- item with active Mixed Model Map  Flag does not exist.
                --
                IF  p_rtg_header_rec.mixed_model_map_flag = 1
                AND ( p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                       OR  ( p_rtg_header_rec.transaction_type
                                      = BOM_Rtg_Globals.G_OPR_UPDATE
                             AND  p_rtg_header_rec.mixed_model_map_flag <>
                                        p_old_rtg_header_rec.mixed_model_map_flag )
                      )
                THEN

                       FOR l_active_mixed_rec in c_check_active_mixed(
                           P_assembly_item_id  =>
                                p_rtg_header_unexp_rec.assembly_item_id
                         , P_organization_id   =>
                                p_rtg_header_unexp_rec.organization_id
                         , p_line_id           =>
                                p_rtg_header_unexp_rec.line_id
                         , p_common_routing_sequence_id
                                               =>
                            p_rtg_header_unexp_rec.common_routing_sequence_id
                             )
                       LOOP

                           l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                           l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                                Error_Handler.Add_Error_Token
                                (  p_message_name       =>
                                        'BOM_FLM_RTG_MMMF_ALRDY_EXISTS'
                                 , p_token_tbl          => l_token_tbl
                                 , p_mesg_token_tbl     => l_mesg_token_tbl
                                 , x_mesg_token_tbl     => l_mesg_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;

                      END LOOP;
                 END IF;

                 -- Unique priority check.
                 IF  p_rtg_header_rec.priority IS NOT NULL
                 AND p_rtg_header_rec.priority  <> FND_API.G_MISS_NUM
                 AND ( p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                       OR  ( p_rtg_header_rec.transaction_type
                                      = BOM_Rtg_Globals.G_OPR_UPDATE
                             AND  p_rtg_header_rec.priority <>
                                        NVL(p_old_rtg_header_rec.priority
                                          , FND_API.G_MISS_NUM  ) )
                      )
                 THEN
                     FOR l_priority_rec in c_check_priority(
                           p_assembly_item_id  =>
                                p_rtg_header_unexp_rec.assembly_item_id
                         , p_organization_id   =>
                                p_rtg_header_unexp_rec.organization_id
                         , p_priority          =>
                                p_rtg_header_rec.priority
                         , p_common_routing_sequence_id
                                               =>
                           p_rtg_header_unexp_rec.common_routing_sequence_id
                      )
                      LOOP
                           l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                           l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                                Error_Handler.Add_Error_Token
                                (  p_message_name       =>
                                        'BOM_RTG_PRIORITY_DUPLICATE'
                                 , p_token_tbl          => l_token_tbl
                                 , p_mesg_token_tbl     => l_mesg_token_tbl
                                 , x_mesg_token_tbl     => l_mesg_token_tbl
                                 );
                                l_return_status := FND_API.G_RET_STS_ERROR;

                      END LOOP;

                END IF ;


                IF p_rtg_header_rec.completion_subinventory IS  NULL
                OR p_rtg_header_rec.completion_subinventory =  FND_API.G_MISS_CHAR
                THEN
                   IF p_rtg_header_unexp_rec.completion_locator_id IS NOT NULL
                   AND p_rtg_header_unexp_rec.completion_locator_id
                                  <>  FND_API.G_MISS_NUM

                   THEN
                       l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME' ;
                       l_token_tbl(1).token_value :=
                                         p_rtg_header_rec.assembly_item_name;

                       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                       THEN

                                    Error_Handler.Add_Error_Token
                                   (  p_message_name       =>
                                      'BOM_RTG_LOCATOR_MUST_BE_NULL'
                                    , p_token_tbl          => l_token_tbl
                                    , p_mesg_token_tbl     => l_mesg_token_tbl
                                    , x_mesg_token_tbl     => l_mesg_token_tbl
                                   );
                       END IF ;

                       l_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;

                END IF;


                IF   p_rtg_header_rec.Completion_Subinventory IS NOT NULL
                AND  p_rtg_header_rec.Completion_Subinventory
                                  <>  FND_API.G_MISS_CHAR
                AND ( p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                       OR  ( p_rtg_header_rec.transaction_type
                                      = BOM_Rtg_Globals.G_OPR_UPDATE
                             AND  p_rtg_header_rec.Completion_Subinventory <>
                                     NVL( p_old_rtg_header_rec.Completion_Subinventory
                                         ,FND_API.G_MISS_CHAR  )
                           )
                     )
                THEN
                    IF NOT Check_SubInv_Exists
                           ( p_organization_id     =>
                                p_rtg_header_unexp_rec.organization_id
                           , p_subinventory
                                 =>p_rtg_header_rec.Completion_Subinventory
                       )
                    THEN
                           l_token_tbl(1).token_name := 'ASSEMBLY_ITEM_NAME';
                           l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                           l_token_tbl(2).token_name :=  'COMPLETION_SUBINVENTORY';
                           l_token_tbl(2).token_value :=
                                        p_rtg_header_rec.completion_subinventory;
                           Error_Handler.Add_Error_Token
                                (  p_message_name       =>
                                        'BOM_RTG_SUBINV_NAME_INVALID'
                                 , p_token_tbl          => l_token_tbl
                                 , p_mesg_token_tbl     => l_mesg_token_tbl
                                 , x_mesg_token_tbl     => l_mesg_token_tbl
                                 );
                           l_return_status := FND_API.G_RET_STS_ERROR;
                    ELSE
                         l_sub_inv_exists := TRUE ;

                    END IF ;

                 END IF;


                 IF l_sub_inv_exists THEN

-- check completeion subinventory
IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
     ('Performing completeion subinventory check. . .') ;
END IF;
                     l_allow_expense_to_asset := fnd_profile.value
                                    ('INV:EXPENSE_TO_ASSET_TRANSFER');


                     Get_SubInv_Flag
                     (    p_assembly_item_id  =>  p_rtg_header_unexp_rec.assembly_item_id
                       ,  p_organization_id   =>  p_rtg_header_unexp_rec.organization_id
                       ,  x_rest_subinv_code  =>  l_rest_subinv_code
                       ,  x_inv_asset_flag    =>  l_inv_asset_flag ) ;


IF BOM_Rtg_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('Get Sub Inv Flag . . . ');
     error_handler.write_debug('Expense to asset transfer : '||  l_allow_expense_to_asset );
     error_handler.write_debug('Restrict Sub Inv Code : ' || l_rest_subinv_code );
     error_handler.write_debug('Inv Asset Flag : '||  l_inv_asset_flag );

END IF;

                     IF l_rest_subinv_code = 'Y' THEN
                         IF l_allow_expense_to_asset = '1' THEN

IF BOM_Rtg_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('Before  OPEN c_Restrict_SubInv_Trk');
END IF;

                                OPEN c_Restrict_SubInv_Trk;
                                FETCH c_Restrict_SubInv_Trk INTO
                                        l_Sub_Locator_Control;

                                IF c_Restrict_SubInv_Trk%NOTFOUND THEN
                                    CLOSE c_Restrict_SubInv_Trk;
                                    l_token_tbl(1).token_name :=
                                                        'ASSEMBLY_ITEM_NAME';
                                    l_token_tbl(1).token_value :=
                                         p_rtg_header_rec.assembly_item_name;
                                    l_token_tbl(2).token_name :=
                                                   'COMPLETION_SUBINVENTORY';
                                    l_token_tbl(2).token_value :=
                                         p_rtg_header_rec.completion_subinventory;

                                    Error_Handler.Add_Error_Token
                                   (  p_message_name       =>
                                      'BOM_RTG_SINV_RSTRCT_EXPASST'
                                    , p_token_tbl          => l_token_tbl
                                    , p_mesg_token_tbl     => l_mesg_token_tbl
                                    , x_mesg_token_tbl     => l_mesg_token_tbl
                                   );
                                   l_return_status := FND_API.G_RET_STS_ERROR;
                                ELSE
                                    CLOSE  c_Restrict_SubInv_Trk;

                                END IF;

                         ELSE  -- l_allow_expense_to_asset <>  '1'
                             IF l_inv_asset_flag = 'Y'   THEN

                                 OPEN c_Restrict_SubInv_Asset;
                                 FETCH c_Restrict_SubInv_Asset INTO
                                        l_Sub_Locator_Control;
                                 IF c_Restrict_SubInv_Asset%NOTFOUND THEN
                                    CLOSE c_Restrict_SubInv_Asset;

                                    l_token_tbl(1).token_name :=
                                                        'ASSEMBLY_ITEM_NAME';
                                    l_token_tbl(1).token_value :=
                                    p_rtg_header_rec.assembly_item_name;
                                    l_token_tbl(2).token_name :=
                                                'COMPLETION_SUBINVENTORY';
                                    l_token_tbl(2).token_value :=
                                    p_rtg_header_rec.completion_subinventory;
                                    Error_Handler.Add_Error_Token
                                     (  p_message_name       =>
                                       'BOM_RTG_SINV_RSTRCT_INVASST'
                                       , p_token_tbl      => l_token_tbl
                                       , p_mesg_token_tbl => l_mesg_token_tbl
                                       , x_mesg_token_tbl => l_mesg_token_tbl
                                     );
                                    l_return_status :=
                                                       FND_API.G_RET_STS_ERROR;
                                 ELSE
                                     CLOSE  c_Restrict_SubInv_Asset ;
                                 END IF;

                             ELSE  -- l_inv_asset_flag <>  'Y'

                                 OPEN c_Restrict_SubInv_Trk;
                                 FETCH c_Restrict_SubInv_Trk INTO
                                                l_Sub_Locator_Control;
                                 IF c_Restrict_SubInv_Trk%NOTFOUND THEN
                                    CLOSE c_Restrict_SubInv_Trk;
                                    l_token_tbl(1).token_name :=
                                                   'ASSEMBLY_ITEM_NAME';
                                    l_token_tbl(1).token_value :=
                                        p_rtg_header_rec.assembly_item_name;
                                    l_token_tbl(2).token_name :=
                                        'COMPLETION_SUBINVENTORY';
                                    l_token_tbl(2).token_value :=
                                        p_rtg_header_rec.completion_subinventory;
                                    Error_Handler.Add_Error_Token
                                    (  p_message_name       =>
                                            'BOM_RTG_SINV_RSTRCT_NOASST'
                                      , p_token_tbl      => l_token_tbl
                                      , p_mesg_token_tbl => l_mesg_token_tbl
                                      , x_mesg_token_tbl => l_mesg_token_tbl
                                    );
                                    l_return_status :=
                                                     FND_API.G_RET_STS_ERROR;

                                ELSE
                                     CLOSE c_Restrict_SubInv_Trk;
                                END IF;
                            END IF;  -- End of l_inv_asset_flag
                        END IF;  -- End of l_allow_expense_to_asset


                     ELSE  -- l_rest_subinv_code <> 'Y'
                        IF l_allow_expense_to_asset = '1' THEN

                            OPEN c_SubInventory_Tracked;
                            FETCH c_SubInventory_Tracked INTO
                                        l_Sub_Locator_Control;
                            IF c_SubInventory_Tracked%NOTFOUND THEN
                                  CLOSE c_SubInventory_Tracked;
                                  l_token_tbl(1).token_name :=
                                                    'ASSEMBLY_ITEM_NAME';
                                  l_token_tbl(1).token_value :=
                                  p_rtg_header_rec.assembly_item_name;
                                  l_token_tbl(2).token_name :=
                                            'COMPLETION_SUBINVENTORY';
                                  l_token_tbl(2).token_value :=
                                  p_rtg_header_rec.completion_subinventory;
                                  Error_Handler.Add_Error_Token
                                  (  p_message_name       =>
                                        'BOM_RTG_SINV_NOTRSTRCT_EXPASST'
                                     , p_token_tbl      => l_token_tbl
                                     , p_mesg_token_tbl => l_mesg_token_tbl
                                     , x_mesg_token_tbl => l_mesg_token_tbl
                                   );
                                  l_return_status :=
                                                       FND_API.G_RET_STS_ERROR;
                            ELSE
                                 CLOSE c_SubInventory_Tracked;
                            END IF;

                        ELSE  -- l_allow_expense_to_asset <>  '1'
                            IF l_inv_asset_flag = 'Y' THEN

                                OPEN c_SubInventory_Asset;
                                FETCH c_SubInventory_Asset INTO
                                                       l_Sub_Locator_Control;
                                IF c_SubInventory_Asset%NOTFOUND THEN
                                    CLOSE c_SubInventory_Asset;
                                    l_token_tbl(1).token_name :=
                                                 'ASSEMBLY_ITEM_NAME';
                                    l_token_tbl(1).token_value :=
                                      p_rtg_header_rec.assembly_item_name;
                                    l_token_tbl(2).token_name :=
                                            'COMPLETION_SUBINVENTORY';
                                    l_token_tbl(2).token_value :=
                                          p_rtg_header_rec.completion_subinventory;
                                    Error_Handler.Add_Error_Token
                                      (  p_message_name       =>
                                               'BOM_RTG_SINV_NOTRSTRCT_ASST'
                                          , p_token_tbl      => l_token_tbl
                                          , p_mesg_token_tbl => l_mesg_token_tbl
                                          , x_mesg_token_tbl => l_mesg_token_tbl
                                       );
                                    l_return_status :=
                                                       FND_API.G_RET_STS_ERROR;
                                ELSE
                                    CLOSE c_SubInventory_Asset;
                                END IF;

                            ELSE  -- l_inv_asset_flag <> 'Y'

                                OPEN c_Subinventory_Tracked;
                                FETCH c_Subinventory_Tracked INTO
                                                l_Sub_Locator_Control;
                                IF c_SubInventory_Tracked%NOTFOUND THEN
                                   CLOSE c_Subinventory_Tracked;
                                   l_token_tbl(1).token_name :=
                                                         'ASSEMBLY_ITEM_NAME';
                                   l_token_tbl(1).token_value :=
                                          p_rtg_header_rec.assembly_item_name;
                                   l_token_tbl(2).token_name :=
                                            'COMPLETION_SUBINVENTORY';
                                   l_token_tbl(2).token_value :=
                                     p_rtg_header_rec.completion_subinventory;
                                   Error_Handler.Add_Error_Token
                                   (  p_message_name       =>
                                     'BOM_RTG_SINV_NOTRSTRCT_NOASST'
                                     , p_token_tbl      => l_token_tbl
                                     , p_mesg_token_tbl => l_mesg_token_tbl
                                     , x_mesg_token_tbl => l_mesg_token_tbl
                                    );
                                          l_return_status :=
                                                       FND_API.G_RET_STS_ERROR;
                                ELSE
                                    CLOSE c_Subinventory_Tracked;
                                END IF;
                            END IF ; -- End of l_inv_asset_flag = 'Y'
                        END IF;  -- End of l_allow_expense_to_asset
                     END IF;  -- End of -- l_rest_subinv_code = 'Y'
                 END IF ;

                 /********************************************************************
                 --
                 -- Check Locators
                 --
                 ********************************************************************/
                 -- check completion locator

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
    ('Performing completion locator. . .') ;
END IF;

                 IF   (( p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_UPDATE
                 AND     NVL(p_rtg_header_unexp_rec.completion_locator_id , 0) <>
                         NVL(p_rtg_header_unexp_rec.completion_locator_id , 0)
                        )
                      OR (p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
			  AND  p_rtg_header_rec.completion_subinventory is not null            --BUG 3872490
                          AND p_rtg_header_rec.completion_subinventory <> FND_API.G_MISS_CHAR) --BUG 3872490
                      )
                 AND  NOT Check_Locators( p_organization_id => p_rtg_header_unexp_rec.organization_id
                                        , p_assembly_item_id=> p_rtg_header_unexp_rec.assembly_item_id
                                        , p_locator_id      => p_rtg_header_unexp_rec.completion_locator_id
                                        , p_subinventory    => p_rtg_header_rec.completion_subinventory )
                 THEN


                     IF l_locator_control = 4 THEN
                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                            l_token_tbl(1).token_name :='ASSEMBLY_ITEM_NAME';
                            l_token_tbl(1).token_value :=
                                          p_rtg_header_rec.assembly_item_name;
                            Error_Handler.Add_Error_Token
                            (  p_message_name       => 'BOM_RTG_LOCATOR_REQUIRED'
                             , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                             , p_Token_Tbl          => g_Token_Tbl
                            );
                        END IF;

                     ELSIF l_locator_control = 3 THEN
                     -- Log the Dynamic locator control message.
                         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                         THEN
                             l_token_tbl(1).token_name :='ASSEMBLY_ITEM_NAME';
                             l_token_tbl(1).token_value :=
                                          p_rtg_header_rec.assembly_item_name;
                             Error_Handler.Add_Error_Token
                             ( p_message_name   => 'BOM_RTG_LOC_CANNOT_BE_DYNAMIC'
                             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                             , p_Token_Tbl      => g_Token_Tbl
                             );
                         END IF;

                     ELSIF l_locator_control = 2 THEN
                         IF  l_item_loc_restricted  = 1 THEN
                         -- if error occured when item_locator_control was
                         -- restrcited
                            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                            THEN
                               l_token_tbl(1).token_name :='ASSEMBLY_ITEM_NAME';
                               l_token_tbl(1).token_value :=
                                          p_rtg_header_rec.assembly_item_name;
                               l_token_tbl(2).token_name :=
                                          'COMPLETION_SUBINVENTORY';
                               l_token_tbl(2).token_value :=
                                          p_rtg_header_rec.completion_subinventory;


                               Error_Handler.Add_Error_Token
                               (  p_message_name =>
                                            'BOM_RTG_ITEM_LOC_RESTRICTED'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl      => g_Token_Tbl
                               );
                            END IF;
                         ELSE
                            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                            THEN
                                l_token_tbl(1).token_name :='ASSEMBLY_ITEM_NAME';
                                l_token_tbl(1).token_value :=
                                          p_rtg_header_rec.assembly_item_name;
                                Error_Handler.Add_Error_Token
                                (  p_message_name   => 'BOM_RTG_LOCATOR_NOT_IN_SUBINV'
                                 , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                 , p_Token_Tbl      => g_Token_Tbl
                                );
                            END IF;
                         END IF ;

                     ELSIF l_locator_control = 1 THEN
                         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                         THEN
                             Error_Handler.Add_Error_Token
                             (  p_message_name  =>
                                           'BOM_RTG_ITEM_NO_LOC_CONTROL'
                              , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                              , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                              , p_Token_Tbl      => g_Token_Tbl
                              );
                         END IF;

                     END IF;

                     l_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;  ---end of locator check

		 IF p_rtg_header_rec.transaction_type IN (BOM_Rtg_Globals.G_OPR_UPDATE) AND -- Added for SSOS (bug 2689249)
		    p_rtg_header_rec.ser_start_op_seq IS NOT NULL AND
		    l_bom_item_type IN (1,2) THEN -- If the item is a model/option class item routing
		      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN
                        Error_Handler.Add_Error_Token
                        (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'BOM_SER_OP_CONFIG_RTG_EXISTS'
                         , p_token_tbl      => l_token_tbl
                         , p_message_type   => 'W'
                         );
                     END IF ;
		 END IF;

       x_return_status := l_return_status;
       x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug('Routing header : Entity Validation done . . . Return Status is ' || l_return_status);
END IF ;

       EXCEPTION

                WHEN FND_API.G_EXC_ERROR THEN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Expected Error in routing header Entity Validation . . .'); END IF;

                        x_return_status := FND_API.G_RET_STS_ERROR;
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Unexpected Error in routing header Entity Validation . . .'); END IF;

                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        IF FND_MSG_PUB.Check_Msg_Level
                                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                l_err_text := G_PKG_NAME ||
                                                ' : (Entity Validation) ' ||
                                                substrb(SQLERRM,1,200);
                                Error_Handler.Add_Error_Token
                                ( p_Message_Text => l_err_text
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                );
                        END IF;
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

                WHEN OTHERS THEN
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(SQLERRM || ' ' || TO_CHAR(SQLCODE)); END IF;
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        IF FND_MSG_PUB.Check_Msg_Level
                                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                l_err_text := G_PKG_NAME ||
                                                ' : (Entity Validation) ' ||
                                                substrb(SQLERRM,1,200);
                                Error_Handler.Add_Error_Token
                                ( p_Message_Text => l_err_text
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                );
                        END IF;
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

       END Check_Entity;


       PROCEDURE Check_Entity_Delete
       ( x_return_status       IN OUT NOCOPY VARCHAR2
        , x_Mesg_Token_Tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        , p_rtg_header_rec      IN  Bom_Rtg_Pub.rtg_header_Rec_Type
        , p_rtg_header_Unexp_Rec IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
        , x_rtg_header_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
        )
       IS
                l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_rtg_header_unexp_rec  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
                                        := p_rtg_header_Unexp_Rec;
                l_err_text              VARCHAR2(2000);

                Cursor CheckGroup is
                SELECT description,
                       delete_group_sequence_id,
                       delete_type
                  FROM bom_delete_groups
                 WHERE delete_group_name = p_rtg_header_rec.Delete_Group_Name
                   AND organization_id = p_rtg_header_Unexp_Rec.organization_id;

       BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
                l_rtg_header_unexp_rec := p_rtg_header_unexp_rec;

                IF p_rtg_header_rec.Delete_Group_Name IS NULL OR
                   p_rtg_header_rec.Delete_Group_Name = FND_API.G_MISS_CHAR
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'BOM_DG_NAME_MISSING'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => x_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RETURN;
                END IF;

                For c_CheckGroup in CheckGroup
                LOOP
                        If c_CheckGroup.delete_type <> 3  /* Bill */ then
                                Error_Handler.Add_Error_Token
                             (  p_message_name => 'BOM_DUPLICATE_DELETE_GROUP'
                              , p_mesg_token_tbl=>l_mesg_token_tbl
                              , x_mesg_token_tbl=>x_mesg_token_tbl
                              );
                              x_return_status := FND_API.G_RET_STS_ERROR;
                              RETURN;
                        End if;


                        l_rtg_header_unexp_rec.DG_description :=
                                        c_Checkgroup.description;
                        l_rtg_header_unexp_rec.DG_sequence_id :=
                                        c_Checkgroup.delete_group_sequence_id;

--                        RETURN;

                END LOOP;
/* -- not necessary (bug 2774997)
                IF l_rtg_header_unexp_rec.DG_sequence_id IS NULL
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'NEW_DELETE_GROUP'
                         , p_message_type       => 'W'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , x_mesg_token_tbl     => x_mesg_token_tbl
                         );

                        l_rtg_header_unexp_rec.DG_new := TRUE;
                        l_rtg_header_unexp_rec.DG_description :=
                                p_rtg_header_rec.DG_description;
                END IF;
*/

                IF l_rtg_header_unexp_rec.Routing_Type IS NULL -- Added for bug 2774997
		THEN
                    SELECT DECODE(p_rtg_header_rec.eng_routing_flag, 1, 2, 1)
                    INTO  l_rtg_header_unexp_rec.routing_type
                    FROM SYS.DUAL ;
		END IF;
		-- Return the unexposed record
                x_rtg_header_unexp_rec := l_rtg_header_unexp_rec;

       EXCEPTION
           WHEN OTHERS THEN

              l_err_text := G_PKG_NAME || ' Validation (Check Entity Delete) '
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

              x_rtg_header_unexp_rec := l_rtg_header_unexp_rec;

       END Check_Entity_Delete;

       PROCEDURE Check_SSOS -- Added for SSOS (bug 2689249)
        ( p_rtg_header_rec	     IN  Bom_Rtg_Pub.rtg_header_Rec_Type
        , p_rtg_header_unexp_rec     IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
        , x_mesg_token_tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        , x_return_status            IN OUT NOCOPY VARCHAR2
	) IS
	Cursor check_ssos_cur IS
	Select 'IsNotValid'
	from dual
	where p_rtg_header_rec.ser_start_op_seq NOT IN
	   (select bos.OPERATION_SEQ_NUM
	    from bom_operation_sequences bos
	    where bos.ROUTING_SEQUENCE_ID = p_rtg_header_unexp_rec.routing_sequence_id
	    and   nvl(bos.OPERATION_TYPE,1) = 1
	    and   nvl(bos.EFFECTIVITY_DATE, sysdate-1) <= sysdate
	    and   nvl(bos.disable_date , sysdate + 1) >= sysdate
	    and   bos.OPTION_DEPENDENT_FLAG = 2
	    and   bos.count_point_type = 1)
	;

	BEGIN
		FOR check_ssos_rec in check_ssos_cur LOOP
			IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
                            Error_Handler.Add_Error_Token
			    (  p_message_name       => 'BOM_SSOS_INVALID'
			    , p_mesg_token_tbl     => x_mesg_token_tbl
			    , x_mesg_token_tbl     => x_mesg_token_tbl
			    );
			 END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('SSOS is invalid....'); END IF;
                        x_return_status := FND_API.G_RET_STS_ERROR;
		END LOOP;
	END Check_SSOS;


  PROCEDURE Check_lot_controlled_item   --for bug 3132425
         (  p_assembly_item_id    IN  NUMBER
          , p_organization_id     IN  NUMBER
          , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
          , x_return_status       IN OUT NOCOPY VARCHAR2
         )
         IS

    CURSOR lot_check is
           select lot_control_code
           from mtl_system_items m
           where m.organization_id = p_organization_id
           and m.inventory_item_id = p_assembly_item_id;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug(
          'Within Routing Header Check lot controlled item . . . ');
    END IF;

    if BOM_Rtg_Globals.Get_CFM_Rtg_Flag = BOM_Rtg_Globals.G_Lot_Rtg then
      FOR cur_count IN lot_check LOOP
        if cur_count.lot_control_code = 1
        then x_return_status := FND_API.G_RET_STS_ERROR;
        end if;
      END LOOP;
    end if;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Check_lot_controlled_item;

  PROCEDURE Validate_SSOS
    (  p_routing_sequence_id  IN  NUMBER
     , p_ser_start_op_seq     IN  NUMBER
     , p_validate_from_table  IN  BOOLEAN
     , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status        IN OUT NOCOPY VARCHAR2
    )
  IS

    l_cfm_routing_flag        BOM_OPERATIONAL_ROUTINGS.CFM_ROUTING_FLAG%TYPE;
    l_ser_num_control_code    MTL_SYSTEM_ITEMS_B.SERIAL_NUMBER_CONTROL_CODE%TYPE;
    l_ser_start_op_seq        BOM_OPERATIONAL_ROUTINGS.SERIALIZATION_START_OP%TYPE;
    l_nw_opern_count          NUMBER;
    l_retval                  INTEGER;
    l_start_op_seq_id         NUMBER;
    l_errcode                 NUMBER;
    l_errmsg                  VARCHAR2(2000);

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT  COUNT(1)
    INTO    l_nw_opern_count
    FROM    BOM_OPERATION_SEQUENCES bos,
            BOM_OPERATION_NETWORKS bon
    WHERE
            bon.FROM_OP_SEQ_ID = bos.OPERATION_SEQUENCE_ID
    AND     bos.ROUTING_SEQUENCE_ID = p_routing_sequence_id;

    -- validate SSOS only when network exists
    IF ( l_nw_opern_count > 0 ) THEN

      SELECT  bor.CFM_ROUTING_FLAG,
              bor.SERIALIZATION_START_OP,
              msib.SERIAL_NUMBER_CONTROL_CODE
      INTO    l_cfm_routing_flag,
              l_ser_start_op_seq,
              l_ser_num_control_code
      FROM BOM_OPERATIONAL_ROUTINGS bor, MTL_SYSTEM_ITEMS_B msib
      WHERE
          bor.ASSEMBLY_ITEM_ID = msib.INVENTORY_ITEM_ID
      AND bor.ORGANIZATION_ID = msib.ORGANIZATION_ID
      AND bor.ROUTING_SEQUENCE_ID = p_routing_sequence_id;

      IF ( ( l_ser_num_control_code = 2 ) AND ( NVL(l_cfm_routing_flag, 2) IN (2, 3) ) )
      THEN

        IF ( p_validate_from_table = FALSE ) THEN
          l_ser_start_op_seq := p_ser_start_op_seq;
        END IF;

        -- SSOS is required for standard/network routing of serial controlled item.
        IF ( ( l_ser_start_op_seq IS NULL ) OR ( l_ser_start_op_seq = FND_API.G_MISS_NUM ) ) THEN

          IF ( FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) )
          THEN
            Error_Handler.Add_Error_Token
              (  p_message_name       => 'WSM_NTWK_SERIAL_START_OP'
              , p_mesg_token_tbl     => x_mesg_token_tbl
              , x_mesg_token_tbl     => x_mesg_token_tbl
              );
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;

        ELSE
          -- SSOS should be on primary path of network.
          l_retval := WSMPUTIL.PRIMARY_PATH_IS_EFFECTIVE_TILL
                            ( p_routing_sequence_id => p_routing_sequence_id,
                              p_routing_rev_date    => SYSDATE,
                              p_start_op_seq_id     => l_start_op_seq_id,
                              p_op_seq_num          => l_ser_start_op_seq,
                              x_err_code            => l_errcode,
                              x_err_msg             => l_errmsg
                            );

          IF (l_retval = 0) THEN
            IF ( FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) )
            THEN
              Error_Handler.Add_Error_Token
                (  p_message_name       => 'WSM_NTWK_SERIAL_START_OP'
                , p_mesg_token_tbl     => x_mesg_token_tbl
                , x_mesg_token_tbl     => x_mesg_token_tbl
                );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF; -- end if (l_retval = 0)

        END IF; -- end if ( l_ser_start_op_seq IS NULL )
      END IF; -- end if ( ( l_ser_num_control_code = 2 ) AND ( NVL(l_cfm_routing_flag, 2) IN (2, 3) ) )

    END IF; -- ( l_nw_opern_count > 0 )

  EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Validate_SSOS;

END BOM_Validate_Rtg_Header;

/
