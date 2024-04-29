--------------------------------------------------------
--  DDL for Package Body EAM_RES_INST_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_RES_INST_DEFAULT_PVT" AS
/* $Header: EAMVRIDB.pls 120.1 2006/07/10 08:32:34 smrsharm noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRIDB.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_RES_INST_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_RES_INST_DEFAULT_PVT';


        /*********************************************************************
        * Procedure     : Attribute_Defaulting
        * Parameters IN : Resource Instance exposed record
        * Parameters OUT NOCOPY: Resource Instance record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Attribute Defaulting will default the necessary null
        *                 attribute with appropriate values.
        **********************************************************************/

        PROCEDURE Attribute_Defaulting
        (  p_eam_res_inst_rec        IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , x_eam_res_inst_rec        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

                x_eam_res_inst_rec := p_eam_res_inst_rec;
--                x_eam_res_inst_rec := p_eam_res_inst_rec;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                -- Defaulting start_date
                IF (p_eam_res_inst_rec.start_date IS NULL OR
                    p_eam_res_inst_rec.start_date = FND_API.G_MISS_DATE) AND
                   p_eam_res_inst_rec.wip_entity_id is not null AND
                   p_eam_res_inst_rec.organization_id is not null AND
                   p_eam_res_inst_rec.operation_seq_num is not null AND
                   p_eam_res_inst_rec.resource_seq_num is not null
                THEN
                   select start_date into x_eam_res_inst_rec.start_date
                     from wip_operation_resources where
                     wip_entity_id = p_eam_res_inst_rec.wip_entity_id
                     and organization_id = p_eam_res_inst_rec.organization_id
                     and operation_seq_num = p_eam_res_inst_rec.operation_seq_num
                     and resource_seq_num = p_eam_res_inst_rec.resource_seq_num;
                END IF;

                -- Defaulting completion_date
                IF (p_eam_res_inst_rec.completion_date IS NULL OR
                    p_eam_res_inst_rec.completion_date = FND_API.G_MISS_DATE) AND
                   p_eam_res_inst_rec.wip_entity_id is not null AND
                   p_eam_res_inst_rec.organization_id is not null AND
                   p_eam_res_inst_rec.operation_seq_num is not null AND
                   p_eam_res_inst_rec.resource_seq_num is not null
                THEN
                   select completion_date into x_eam_res_inst_rec.completion_date
                     from wip_operation_resources where
                     wip_entity_id = p_eam_res_inst_rec.wip_entity_id
                     and organization_id = p_eam_res_inst_rec.organization_id
                     and operation_seq_num = p_eam_res_inst_rec.operation_seq_num
                     and resource_seq_num = p_eam_res_inst_rec.resource_seq_num;
                END IF;

             EXCEPTION
                WHEN OTHERS THEN
                     EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                     (  p_message_name       => NULL
                      , p_message_text       => G_PKG_NAME || SQLERRM
                      , x_mesg_token_Tbl     => x_mesg_token_tbl
                     );

                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Attribute_Defaulting;


        /******************************************************************
        * Procedure     : Populate_Null_Columns
        * Parameters IN : Resource Instance column record
        *                 Old Resource Instance Column Record
        * Parameters OUT NOCOPY: Resource Instance column record after populating
        * Purpose       : This procedure will look at the columns that the user
        *                 has not filled in and will assign those columns a
        *                 value from the old record.
        *                 This procedure is not called for CREATE
        ********************************************************************/
        PROCEDURE Populate_Null_Columns
        (  p_eam_res_inst_rec        IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , p_old_eam_res_inst_rec    IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , x_eam_res_inst_rec        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
        )
        IS
        BEGIN
                x_eam_res_inst_rec := p_eam_res_inst_rec;
                x_eam_res_inst_rec := p_eam_res_inst_rec;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing null columns prior update'); END IF;

                IF p_eam_res_inst_rec.serial_number IS NULL OR
                   p_eam_res_inst_rec.serial_number = FND_API.G_MISS_CHAR
                THEN
                    x_eam_res_inst_rec.serial_number := p_old_eam_res_inst_rec.serial_number;
                END IF;

                IF p_eam_res_inst_rec.start_date IS NULL OR
                   p_eam_res_inst_rec.start_date = FND_API.G_MISS_DATE
                THEN
                    x_eam_res_inst_rec.start_date := p_old_eam_res_inst_rec.start_date;
                END IF;

                IF p_eam_res_inst_rec.completion_date IS NULL OR
                   p_eam_res_inst_rec.completion_date = FND_API.G_MISS_DATE
                THEN
                    x_eam_res_inst_rec.completion_date := p_old_eam_res_inst_rec.completion_date;
                END IF;

                IF p_eam_res_inst_rec.top_level_batch_id IS NULL OR
                   p_eam_res_inst_rec.top_level_batch_id = FND_API.G_MISS_NUM
                THEN
                    x_eam_res_inst_rec.top_level_batch_id := p_old_eam_res_inst_rec.top_level_batch_id;
                END IF;



IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Done processing null columns prior update'); END IF;

        END Populate_Null_Columns;

END EAM_RES_INST_DEFAULT_PVT;

/
