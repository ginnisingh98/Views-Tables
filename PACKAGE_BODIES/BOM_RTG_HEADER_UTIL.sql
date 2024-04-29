--------------------------------------------------------
--  DDL for Package Body BOM_RTG_HEADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_HEADER_UTIL" AS
/* $Header: BOMURTGB.pls 120.1 2005/08/17 03:27:54 bbpatel noship $*/
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      ENGURTGB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Rtg_Header_Util
--
--  NOTES
--
--  HISTORY
--  02-AUGL-2000 Biao Zhang     Initial Creation
****************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'BOM_Rtg_Header_Util';

        /*********************************************************************
        * Procedure     : Query_Row
        * Parameters IN : Assembly item id
        *                 Organization Id
        *                 Alternate_Rtg_Code
        * Parameters out: Rtg header exposed column record
        *                 Rtg Header unexposed column record
        *                 Mesg token Table
        *                 Return Status
        * Purpose       : Procedure will query the database record, seperate the
        *                 values into exposed columns and unexposed columns and
        *                 return with those records.
        ***********************************************************************/
        PROCEDURE Query_Row
        (  p_assembly_item_id    IN  NUMBER
         , p_organization_id     IN  NUMBER
         , p_alternate_routing_code  IN VARCHAR2
         , x_rtg_header_rec      IN OUT NOCOPY Bom_Rtg_Pub.rtg_header_Rec_Type
         , x_rtg_header_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.rtg_header_unexposed_Rec_Type
         , x_Return_status       IN OUT NOCOPY VARCHAR2
        )
        IS
                l_rtg_header_rec        Bom_Rtg_Pub.Rtg_header_Rec_Type;
                l_rtg_header_unexp_rec  Bom_Rtg_Pub.Rtg_header_Unexposed_Rec_Type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
                l_dummy                 varchar2(10);
        BEGIN

                SELECT  assembly_item_id
                ,       organization_id
                ,       alternate_routing_designator
                ,       routing_sequence_id
                ,       routing_type
                ,       common_assembly_item_id
                ,       common_routing_sequence_id
                ,       routing_comment
                ,       completion_subinventory
                ,       completion_locator_id
                ,       line_id
                ,       cfm_routing_flag
                ,       mixed_model_map_flag
                ,       priority
                ,       ctp_flag
		,	serialization_start_op -- Added for SSOS (bug 2689249)
                ,       attribute_category
                ,       attribute1
                ,       attribute2
                ,       attribute3
                ,       attribute4
                ,       attribute5
                ,       attribute6
                ,       attribute7
                ,       attribute8
                ,       attribute9
                ,       attribute10
                ,       attribute11
                ,       attribute12
                ,       attribute13
                ,       attribute14
                ,       attribute15
                INTO    l_rtg_header_unexp_rec.assembly_item_id
                ,       l_rtg_header_unexp_rec.organization_id
                ,       l_rtg_header_rec.alternate_routing_code
                ,       l_rtg_header_unexp_rec.routing_sequence_id
                ,       l_rtg_header_unexp_rec.routing_type
                ,       l_rtg_header_unexp_rec.common_assembly_item_id
                ,       l_rtg_header_unexp_rec.common_routing_sequence_id
                ,       l_rtg_header_rec.routing_comment
                ,       l_rtg_header_rec.completion_subinventory
                ,       l_rtg_header_unexp_rec.completion_locator_id
                ,       l_rtg_header_unexp_rec.line_id
                ,       l_rtg_header_rec.cfm_routing_flag
                ,       l_rtg_header_rec.mixed_model_map_flag
                ,       l_rtg_header_rec.priority
                ,       l_rtg_header_rec.ctp_flag
		,	l_rtg_header_rec.ser_start_op_seq -- Added for SSOS (bug 2689249)
                ,       l_rtg_header_rec.attribute_category
                ,       l_rtg_header_rec.attribute1
                ,       l_rtg_header_rec.attribute2
                ,       l_rtg_header_rec.attribute3
                ,       l_rtg_header_rec.attribute4
                ,       l_rtg_header_rec.attribute5
                ,       l_rtg_header_rec.attribute6
                ,       l_rtg_header_rec.attribute7
                ,       l_rtg_header_rec.attribute8
                ,       l_rtg_header_rec.attribute9
                ,       l_rtg_header_rec.attribute10
                ,       l_rtg_header_rec.attribute11
                ,       l_rtg_header_rec.attribute12
                ,       l_rtg_header_rec.attribute13
                ,       l_rtg_header_rec.attribute14
                ,       l_rtg_header_rec.attribute15
                FROM   bom_operational_routings
                WHERE  assembly_item_id = p_assembly_item_id
                  AND  organization_id  = p_organization_id
                  AND  NVL(alternate_routing_designator, FND_API.G_MISS_CHAR )
                       = NVL( p_alternate_routing_code, FND_API.G_MISS_CHAR )
                  ;


                x_return_status  := BOM_Rtg_Globals.G_RECORD_FOUND;
                x_rtg_header_rec  := l_rtg_header_rec;
                x_rtg_header_unexp_rec := l_rtg_header_unexp_rec;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := BOM_Rtg_Globals.G_RECORD_NOT_FOUND;
                        x_rtg_header_rec := l_rtg_header_rec;
                        x_rtg_header_unexp_rec := l_rtg_header_unexp_rec;
                WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_rtg_header_rec := l_rtg_header_rec;
                        x_rtg_header_unexp_rec := l_rtg_header_unexp_rec;

        END Query_Row;

        /********************************************************************
        * Procedure     : Insert_Row
        * Parameters IN : rtg Header exposed column record
        *                 rtg Header unexposed column record
        * Parameters out: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an insert into the
        *                 rtg_Bill_Of_Materials table thus creating a new bill
        *********************************************************************/
        PROCEDURE Insert_Row
        (  p_rtg_header_rec     IN  Bom_Rtg_Pub.rtg_header_Rec_Type
         , p_rtg_header_unexp_rec IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
         , x_mesg_token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_Status      IN OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

             IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing Rtg Header rec for ' || p_rtg_header_rec.assembly_item_name); END IF;

                --bug:3254815 Update request id, prog id, prog appl id and prog update date.
                INSERT INTO bom_operational_routings
                (  assembly_item_id
                 , organization_id
                 , alternate_routing_designator
                 , common_assembly_item_id
                 , routing_type
                 , routing_sequence_id
                 , common_routing_sequence_id
                 , completion_subinventory
                 , completion_locator_id
                 , line_id
                 , cfm_routing_flag
                 , mixed_model_map_flag
                 , priority
                 , ctp_flag
                 , total_product_cycle_time
                 , routing_comment
		 , serialization_start_op -- Added for SSOS (bug 2689249)
                 , attribute_category
                 , attribute1
                 , attribute2
                 , attribute3
                 , attribute4
                 , attribute5
                 , attribute6
                 , attribute7
                 , attribute8
                 , attribute9
                 , attribute10
                 , attribute11
                 , attribute12
                 , attribute13
                 , attribute14
                 , attribute15
                 , creation_date
                 , created_by
                 , last_update_date
                 , last_updated_by
                 , last_update_login
                 , original_system_reference
                 , request_id
                 , program_id
                 , program_application_id
                 , program_update_date
                 )
                VALUES
                (  p_rtg_header_unexp_rec.assembly_item_id
                 , p_rtg_header_unexp_rec.organization_id
                 , p_rtg_header_rec.alternate_routing_code
                 , p_rtg_header_unexp_rec.common_assembly_item_id
                 , p_rtg_header_unexp_rec.routing_type
                 , p_rtg_header_unexp_rec.routing_sequence_id
                 , p_rtg_header_unexp_rec.common_routing_sequence_id
                 , p_rtg_header_rec.completion_subinventory
                 , p_rtg_header_unexp_rec.completion_locator_id
                 , p_rtg_header_unexp_rec.line_id
                 , p_rtg_header_rec.cfm_routing_flag
                 , p_rtg_header_rec.mixed_model_map_flag
                 , p_rtg_header_rec.priority
                 , p_rtg_header_rec.ctp_flag
                 , p_rtg_header_rec.total_cycle_time
                 , p_rtg_header_rec.routing_comment
		 , p_rtg_header_rec.ser_start_op_seq  -- Added for SSOS (bug 2689249)
                 , p_rtg_header_rec.attribute_category
                 , p_rtg_header_rec.attribute1
                 , p_rtg_header_rec.attribute2
                 , p_rtg_header_rec.attribute3
                 , p_rtg_header_rec.attribute4
                 , p_rtg_header_rec.attribute5
                 , p_rtg_header_rec.attribute6
                 , p_rtg_header_rec.attribute7
                 , p_rtg_header_rec.attribute8
                 , p_rtg_header_rec.attribute9
                 , p_rtg_header_rec.attribute10
                 , p_rtg_header_rec.attribute11
                 , p_rtg_header_rec.attribute12
                 , p_rtg_header_rec.attribute13
                 , p_rtg_header_rec.attribute14
                 , p_rtg_header_rec.attribute15
                 , SYSDATE
                 , BOM_Rtg_Globals.Get_User_Id
                 , SYSDATE
                 , BOM_Rtg_Globals.Get_User_Id
                 , BOM_Rtg_Globals.Get_Login_Id
                 , p_rtg_header_rec.original_system_reference
                 , Fnd_Global.Conc_Request_Id
                 , Fnd_Global.Conc_Program_Id
                 , Fnd_Global.Prog_Appl_Id
                 , SYSDATE
                );


                IF  p_rtg_header_rec.alternate_routing_code IS NULL
		AND nvl(Bom_Globals.get_caller_type(),'') <> 'MIGRATION'  -- Bug 2871039
                THEN
                      -- Create a new routing revision for the created primary routing
                      INSERT INTO MTL_RTG_ITEM_REVISIONS
                       (  inventory_item_id
                        , organization_id
                        , process_revision
                        , implementation_date
                        , last_update_date
                        , last_updated_by
                        , creation_date
                        , created_by
                        , last_update_login
                        , effectivity_date
                        , request_id
                        , program_id
                        , program_application_id
                        , program_update_date
                        )
                        SELECT
                          p_rtg_header_unexp_rec.assembly_item_id
                        , p_rtg_header_unexp_rec.organization_id
                        , mp.starting_revision
                        , SYSDATE
                        , SYSDATE
                        , BOM_Rtg_Globals.Get_User_Id
                        , SYSDATE
                        , BOM_Rtg_Globals.Get_User_Id
                        , BOM_Rtg_Globals.Get_Login_Id
                        , SYSDATE
                        , Fnd_Global.Conc_Request_Id
                        , Fnd_Global.Conc_Program_Id
                        , Fnd_Global.Prog_Appl_Id
                        , SYSDATE
                        FROM MTL_PARAMETERS mp
                        WHERE mp.organization_id = p_rtg_header_unexp_rec.organization_id
                        AND   NOT EXISTS( SELECT NULL
                                          FROM MTL_RTG_ITEM_REVISIONS
                                          WHERE implementation_date IS NOT NULL
                                          AND   organization_id   = p_rtg_header_unexp_rec.organization_id
                                          AND   inventory_item_id = p_rtg_header_unexp_rec.assembly_item_id
                        ) ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Creating new routing revision for the created primary routing for the revised item . . . ') ;
END IF;

                END IF ;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION
            WHEN OTHERS THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||
                                                  ' :Inserting Record ' ||
                                                  SQLERRM
                         , x_mesg_token_Tbl     => x_mesg_token_tbl
                        );
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Insert_Row;

        /********************************************************************
        * Procedure     : Update_Row
        * Parameters IN : RTG Header exposed column record
        *                 RTG Header unexposed column record
        * Parameters out: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Update into the
        *                 rtg_Bill_Of_Materials table.
        *********************************************************************/
        PROCEDURE Update_Row
        (  p_RTG_header_rec     IN  Bom_Rtg_Pub.RTG_Header_Rec_Type
         , p_RTG_header_unexp_rec IN  Bom_Rtg_Pub.RTG_Header_Unexposed_Rec_Type
         , x_mesg_token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_Status      IN OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

                --
                -- The only fields that are updateable in RTG Header are the
                -- CTP, Priority, completion subinventory, completion_locator,
                -- comcommon routing information, cfm_routing_flag,  mixed_model
                -- map_flag
                --
                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
                        Error_Handler.Write_Debug('Updating routing seq '
                       || p_rtg_header_unexp_rec.routing_sequence_id);
                END IF;

                UPDATE bom_operational_routings
                   SET common_assembly_item_id    =
                                  p_rtg_header_unexp_rec.common_assembly_item_id
                     , common_routing_sequence_id =
                                  p_rtg_header_unexp_rec.common_routing_sequence_id
                     , ctp_flag = p_rtg_header_rec.ctp_flag
                     , priority = p_rtg_header_rec.priority
                     , line_id  = p_rtg_header_unexp_rec.line_id
                     , cfm_routing_flag = p_rtg_header_rec.cfm_routing_flag
                     , mixed_model_map_flag =
                                  p_rtg_header_rec.mixed_model_map_flag
                     , completion_subinventory =
                                  p_rtg_header_rec.completion_subinventory
                     , completion_locator_id =
                                  p_rtg_header_unexp_rec.completion_locator_id
                     , routing_comment       =
                                  p_rtg_header_rec.routing_comment
                     , total_product_cycle_time  =
                                  p_rtg_header_rec.total_cycle_time
                     , serialization_start_op =
				  p_rtg_header_rec.ser_start_op_seq  -- Added for SSOS (bug 2689249)
		     , last_update_date   = SYSDATE
                     , last_updated_by    = BOM_Rtg_Globals.Get_User_Id
                     , last_update_login  = BOM_Rtg_Globals.Get_Login_Id
                     , attribute_category = p_rtg_header_rec.attribute_category
                     , attribute1 = p_rtg_header_rec.attribute1
                     , attribute2 = p_rtg_header_rec.attribute2
                     , attribute3 = p_rtg_header_rec.attribute3
                     , attribute4 = p_rtg_header_rec.attribute4
                     , attribute5 = p_rtg_header_rec.attribute5
                     , attribute6 = p_rtg_header_rec.attribute6
                     , attribute7 = p_rtg_header_rec.attribute7
                     , attribute8 = p_rtg_header_rec.attribute8
                     , attribute9 = p_rtg_header_rec.attribute9
                     , attribute10= p_rtg_header_rec.attribute10
                     , attribute11= p_rtg_header_rec.attribute11
                     , attribute12= p_rtg_header_rec.attribute12
                     , attribute13= p_rtg_header_rec.attribute13
                     , attribute14= p_rtg_header_rec.attribute14
                     , attribute15= p_rtg_header_rec.attribute15
                     , original_system_reference = p_rtg_header_rec.original_system_reference
                     , request_id = Fnd_Global.Conc_Request_Id
                     , program_id = Fnd_Global.Conc_Program_Id
                     , program_application_id = Fnd_Global.Prog_Appl_Id
                     , program_update_date = SYSDATE
                WHERE  routing_sequence_id =
                             p_rtg_header_unexp_rec.routing_sequence_id
                     ;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

        END Update_Row;


        /********************************************************************
        * Procedure     : Delete_Row
        * Parameters IN : rtg Header exposed column record
        *                 rtg Header unexposed column record
        * Parameters out: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Delete from the
        *                 rtg_Bill_Of_Materials by creating a delete Group.
        *********************************************************************/
        PROCEDURE Delete_Row
        (  p_rtg_header_rec     IN  Bom_Rtg_Pub.rtg_header_Rec_Type
         , p_rtg_header_unexp_rec IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
         , x_mesg_token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_Status      IN OUT NOCOPY VARCHAR2
         )
        IS
                Cursor CheckGroup is
                SELECT description,
                       delete_group_sequence_id,
                       delete_type
                 FROM bom_delete_groups
                WHERE delete_group_name = p_rtg_header_rec.delete_group_name
                  AND organization_id = p_rtg_header_unexp_rec.organization_id;

                l_rtg_header_unexp_rec  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
                                           := p_rtg_header_unexp_rec;
                l_rtg_header_rec        Bom_Rtg_Pub.rtg_header_Rec_Type
                                           := p_rtg_header_rec;
                l_dg_sequence_id        NUMBER;
                l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;

        BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                FOR DG IN CheckGroup
                LOOP
                        IF DG.delete_type <> 3 /* Routing */ then
                                Error_Handler.Add_Error_Token
                                (  p_message_name =>
                                                'BOM_DUPLICATE_DELETE_GROUP'
                                 , p_mesg_token_tbl =>
                                        l_mesg_token_Tbl
                                 , x_mesg_token_tbl =>
                                        l_mesg_token_tbl
                                 );
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                x_mesg_token_tbl := l_mesg_token_tbl;
                                RETURN;
                        END IF;

                        l_rtg_header_unexp_rec.DG_Sequence_Id :=
                                DG.delete_group_sequence_id;
                        l_rtg_header_rec.DG_Description := DG.description;

                END LOOP;

                IF l_rtg_header_unexp_rec.DG_Sequence_Id <> FND_API.G_MISS_NUM
                THEN
                   l_dg_sequence_id := l_rtg_header_unexp_rec.DG_Sequence_Id;
                ELSE
                        l_dg_sequence_id := NULL;
                        Error_Handler.Add_Error_Token
                         (  p_message_name => 'NEW_DELETE_GROUP'
                          , p_mesg_token_tbl => l_mesg_token_Tbl
                          , x_mesg_token_tbl => l_mesg_token_tbl
                          , p_message_type   => 'W' /* Warning */
                         );
                END IF;


IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
       Error_Handler.Write_Debug('Calling MODAL_DELETE.DELETE_MANAGER  ') ;
       Error_Handler.Write_Debug('Rtg_Seq ID ' || to_char(l_rtg_header_unexp_rec.routing_sequence_id) ) ;
       Error_Handler.Write_Debug('Alt '|| l_rtg_header_rec.alternate_routing_code ) ;
       Error_Handler.Write_Debug('Routing Type '|| to_char(l_rtg_header_unexp_rec.routing_type) ) ;
       Error_Handler.Write_Debug('Org'|| to_char(l_rtg_header_unexp_rec.organization_id) ) ;

END IF;



                l_dg_sequence_id :=
                MODAL_DELETE.DELETE_MANAGER
                (  new_group_seq_id  => l_dg_sequence_id,
                   name              => l_rtg_header_rec.Delete_Group_Name,
                   group_desc        => l_rtg_header_rec.dg_description,
                   org_id            => l_rtg_header_unexp_rec.organization_id,
                   bom_or_eng        => l_rtg_header_unexp_rec.routing_type,
                   del_type          => 3 /* routing */,
                   ent_bill_seq_id   => NULL,
                   ent_rtg_seq_id    => l_rtg_header_unexp_rec.routing_sequence_id,
                   ent_inv_item_id   => l_rtg_header_unexp_rec.assembly_item_id,
                   ent_alt_designator=>
                                    l_rtg_header_rec.alternate_routing_code,
                   ent_comp_seq_id   => NULL,
                   ent_op_seq_id     => NULL,
                   user_id           => BOM_Rtg_Globals.Get_User_Id
                );

                x_mesg_token_tbl := l_mesg_token_tbl;

        END Delete_Row;

        /*********************************************************************
        * Procedure     : Perform_Writes
        * Parameters IN : Rtg Header Exposed Column Record
        *                 Rtg Header Unexposed column record
        * Parameters out: Messgae Token Table
        *                 Return Status
        * Purpose       : This is the only procedure that the user will have
        *                 access to when he/she needs to perform any kind of
        *                 writes to the bom_operational_routings.
        *********************************************************************/
        PROCEDURE Perform_Writes
        (  p_rtg_header_rec     IN  Bom_Rtg_Pub.rtg_header_Rec_Type
         , p_rtg_header_unexp_rec IN  Bom_Rtg_Pub.rtg_header_Unexposed_Rec_Type
         , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      IN OUT NOCOPY VARCHAR2
        )
        IS
                l_Mesg_Token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        BEGIN
                IF p_rtg_header_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                THEN
                        Insert_Row
                        (  p_rtg_header_rec     => p_rtg_header_rec
                         , p_rtg_header_unexp_rec => p_rtg_header_unexp_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                ELSIF p_rtg_header_rec.transaction_type =
                                                        BOM_Rtg_Globals.G_OPR_UPDATE
                THEN
                        Update_Row
                        (  p_rtg_header_rec     => p_rtg_header_rec
                         , p_rtg_header_unexp_rec => p_rtg_header_unexp_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );

                ELSIF p_rtg_header_rec.transaction_type =
                                                       BOM_Rtg_Globals.G_OPR_DELETE
                THEN
                        Delete_Row
                        (  p_rtg_header_rec     => p_rtg_header_rec
                         , p_rtg_header_unexp_rec => p_rtg_header_unexp_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                END IF;

                x_return_status := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Perform_Writes;


END BOM_Rtg_Header_Util;

/
