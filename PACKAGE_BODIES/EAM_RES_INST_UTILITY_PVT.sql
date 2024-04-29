--------------------------------------------------------
--  DDL for Package Body EAM_RES_INST_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_RES_INST_UTILITY_PVT" AS
/* $Header: EAMVRIUB.pls 120.2 2006/06/19 22:55:59 cboppana noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRIUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_RES_INST_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_RES_INST_UTILITY_PVT';

        /*********************************************************************
        * Procedure     : Query_Row
        * Parameters IN : wip entity id
        *                 organization Id
        *                 operation_seq_num
        *                 resource_seq_num
        *                 instance_id
        * Parameters OUT NOCOPY: Resource Instances column record
        *                 Mesg token Table
        *                 Return Status
        * Purpose       : Procedure will query the database record
        *                 and return with those records.
        ***********************************************************************/

        PROCEDURE Query_Row
        (  p_wip_entity_id       IN  NUMBER
         , p_organization_id     IN  NUMBER
         , p_operation_seq_num   IN  NUMBER
         , p_resource_seq_num    IN  NUMBER
         , p_instance_id         IN  NUMBER
         , p_serial_number       IN  VARCHAR2
         , x_eam_res_inst_rec    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , x_Return_status       OUT NOCOPY VARCHAR2
        )
        IS
                l_eam_res_inst_rec      EAM_PROCESS_WO_PUB.eam_res_inst_rec_type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
                l_dummy                 varchar2(10);
        BEGIN

          IF p_serial_number is null THEN

                SELECT
                         start_date
                       , completion_date
                       , batch_id
                INTO
                         l_eam_res_inst_rec.start_date
                       , l_eam_res_inst_rec.completion_date
                       , l_eam_res_inst_rec.top_level_batch_id
                FROM     wip_op_resource_instances
                WHERE    wip_entity_id     = p_wip_entity_id
                  AND    organization_id   = p_organization_id
                  AND    operation_seq_num = p_operation_seq_num
                  AND    resource_seq_num  = p_resource_seq_num
                  AND    instance_id       = p_instance_id
                  AND    serial_number     IS null;

                x_return_status  := EAM_PROCESS_WO_PVT.G_RECORD_FOUND;
                x_eam_res_inst_rec     := l_eam_res_inst_rec;

          ELSE

                SELECT
                         serial_number
                       , start_date
                       , completion_date
                       , batch_id
                INTO
                         l_eam_res_inst_rec.serial_number
                       , l_eam_res_inst_rec.start_date
                       , l_eam_res_inst_rec.completion_date
                       , l_eam_res_inst_rec.top_level_batch_id
                FROM     wip_op_resource_instances
                WHERE    wip_entity_id     = p_wip_entity_id
                  AND    organization_id   = p_organization_id
                  AND    operation_seq_num = p_operation_seq_num
                  AND    resource_seq_num  = p_resource_seq_num
                  AND    instance_id       = p_instance_id
                  AND    serial_number     = p_serial_number;

                x_return_status  := EAM_PROCESS_WO_PVT.G_RECORD_FOUND;
                x_eam_res_inst_rec     := l_eam_res_inst_rec;

          END IF;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND;
                        x_eam_res_inst_rec    := l_eam_res_inst_rec;

                WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_eam_res_inst_rec    := l_eam_res_inst_rec;

        END Query_Row;


        /********************************************************************
        * Procedure     : Insert_Row
        * Parameters IN : Resource Instances column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an insert into the
        *                 win_op_resource_instances table.
        *********************************************************************/

        PROCEDURE Insert_Row
        (  p_eam_res_inst_rec   IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Writing Resource Instance rec for ' || p_eam_res_inst_rec.instance_id); END IF;

	-- bug no 3444091
	if p_eam_res_inst_rec.start_date > p_eam_res_inst_rec.completion_date then
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('EAM','EAM_WO_RS_IN_DT_ERR');
                return;
	end if;

                INSERT INTO WIP_OP_RESOURCE_INSTANCES
                       ( wip_entity_id
                       , organization_id
                       , operation_seq_num
                       , resource_seq_num
                       , instance_id
                       , serial_number
                       , start_date
                       , completion_date
                       , batch_id
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , last_update_login
                       )
                VALUES
                       ( p_eam_res_inst_rec.wip_entity_id
                       , p_eam_res_inst_rec.organization_id
                       , p_eam_res_inst_rec.operation_seq_num
                       , p_eam_res_inst_rec.resource_seq_num
                       , p_eam_res_inst_rec.instance_id
                       , p_eam_res_inst_rec.serial_number
                       , p_eam_res_inst_rec.start_date
                       , p_eam_res_inst_rec.completion_date
                       , p_eam_res_inst_rec.top_level_batch_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , FND_GLOBAL.login_id
                       );


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Creating new Resource Instances') ; END IF;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION
            WHEN OTHERS THEN
                        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||' :Inserting Record ' || SQLERRM
                         , x_mesg_token_Tbl     => x_mesg_token_tbl
                        );

                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Insert_Row;

        /********************************************************************
        * Procedure     : Update_Row
        * Parameters IN : Resource Instances column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Update on the
        *                 wip_op_resource_instances table.
        *********************************************************************/

        PROCEDURE Update_Row
        (  p_eam_res_inst_rec   IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Updating Resource Instance: '|| p_eam_res_inst_rec.instance_id); END IF;

	-- bug no 3444091
	if p_eam_res_inst_rec.start_date > p_eam_res_inst_rec.completion_date then
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('EAM','EAM_WO_RS_IN_DT_ERR');
                return;
	end if;

                UPDATE WIP_OP_RESOURCE_INSTANCES
                SET      serial_number               = p_eam_res_inst_rec.serial_number
                       , start_date                  = p_eam_res_inst_rec.start_date
                       , completion_date             = p_eam_res_inst_rec.completion_date
                       , batch_id                    = p_eam_res_inst_rec.top_level_batch_id
                       , last_update_date            = SYSDATE
                       , last_updated_by             = FND_GLOBAL.user_id
                       , last_update_login           = FND_GLOBAL.login_id
                WHERE    wip_entity_id     = p_eam_res_inst_rec.wip_entity_id
                  AND    organization_id   = p_eam_res_inst_rec.organization_id
                  AND    operation_seq_num = p_eam_res_inst_rec.operation_seq_num
                  AND    resource_seq_num  = p_eam_res_inst_rec.resource_seq_num
                  AND    instance_id       = p_eam_res_inst_rec.instance_id
		  AND    (serial_number IS NULL OR (serial_number = p_eam_res_inst_rec.serial_number));


                x_return_status := FND_API.G_RET_STS_SUCCESS;

        END Update_Row;

        /********************************************************************
        * Procedure     : Delete_Row
        * Parameters IN : Resource Instances column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Update on the
        *                 wip_op_resource_instances table.
        *********************************************************************/

        PROCEDURE Delete_Row
        (  p_eam_res_inst_rec   IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Deleting Resource Instance: '|| p_eam_res_inst_rec.instance_id); END IF;

                DELETE FROM WIP_OP_RESOURCE_INSTANCES
                WHERE    wip_entity_id     = p_eam_res_inst_rec.wip_entity_id
                  AND    organization_id   = p_eam_res_inst_rec.organization_id
                  AND    operation_seq_num = p_eam_res_inst_rec.operation_seq_num
                  AND    resource_seq_num  = p_eam_res_inst_rec.resource_seq_num
                  AND    instance_id       = p_eam_res_inst_rec.instance_id
		  AND    (serial_number IS NULL OR (serial_number=p_eam_res_inst_rec.serial_number));

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Deleting Resource Instance Usages: '|| p_eam_res_inst_rec.instance_id); END IF;

		IF p_eam_res_inst_rec.serial_number is NULL THEN
			DELETE FROM WIP_OPERATION_RESOURCE_USAGE
			WHERE    wip_entity_id     = p_eam_res_inst_rec.wip_entity_id
			  AND    organization_id   = p_eam_res_inst_rec.organization_id
			  AND    operation_seq_num = p_eam_res_inst_rec.operation_seq_num
			  AND    resource_seq_num  = p_eam_res_inst_rec.resource_seq_num
			  AND    instance_id       = p_eam_res_inst_rec.instance_id;
		ELSE
			DELETE FROM WIP_OPERATION_RESOURCE_USAGE
			WHERE    wip_entity_id     = p_eam_res_inst_rec.wip_entity_id
			  AND    organization_id   = p_eam_res_inst_rec.organization_id
			  AND    operation_seq_num = p_eam_res_inst_rec.operation_seq_num
			  AND    resource_seq_num  = p_eam_res_inst_rec.resource_seq_num
			  AND    instance_id       = p_eam_res_inst_rec.instance_id
			  AND    serial_number	   = p_eam_res_inst_rec.serial_number;
		END IF;


                x_return_status := FND_API.G_RET_STS_SUCCESS;

        END Delete_Row;


        /*********************************************************************
        * Procedure     : Perform_Writes
        * Parameters IN : Resource Instances Column Record
        * Parameters OUT NOCOPY: Messgae Token Table
        *                 Return Status
        * Purpose       : This is the only procedure that the user will have
        *                 access to when he/she needs to perform any kind of
        *                 writes to the wip_operations.
        *********************************************************************/

        PROCEDURE Perform_Writes
        (  p_eam_res_inst_rec   IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
        )
        IS
                l_Mesg_Token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        BEGIN

                IF p_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                        Insert_Row
                        (  p_eam_res_inst_rec   => p_eam_res_inst_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                ELSIF p_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                THEN
                        Update_Row
                        (  p_eam_res_inst_rec   => p_eam_res_inst_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                ELSIF p_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE
                THEN
                        Delete_Row
                        (  p_eam_res_inst_rec   => p_eam_res_inst_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );

                END IF;

                x_return_status := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Perform_Writes;

END EAM_RES_INST_UTILITY_PVT;

/
