--------------------------------------------------------
--  DDL for Package Body EAM_SUB_RESOURCE_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_SUB_RESOURCE_UTILITY_PVT" AS
/* $Header: EAMVSRUB.pls 115.4 2004/02/18 12:48:19 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVSRUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_SUB_RESOURCE_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_SUB_RESOURCE_UTILITY_PVT';

        /*********************************************************************
        * Procedure     : Query_Row
        * Parameters IN : wip entity id
        *                 organization Id
        *                 operation_seq_num
        *                 resource_seq_num
        *                 resource_id
        * Parameters OUT NOCOPY: Sub Resource column record
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
         , x_eam_sub_res_rec     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
         , x_Return_status       OUT NOCOPY VARCHAR2
        )
        IS
                l_eam_sub_res_rec           EAM_PROCESS_WO_PUB.eam_sub_res_rec_type;
                l_return_status             VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
                l_dummy                     VARCHAR2(10);
        BEGIN

                SELECT
                         resource_id
                       , uom_code
                       , basis_type
                       , usage_rate_or_amount
                       , activity_id
                       , scheduled_flag
                       , assigned_units
                       , autocharge_type
                       , standard_rate_flag
                       , applied_resource_units
                       , applied_resource_value
                       , start_date
                       , completion_date
                       , schedule_seq_num
                       , substitute_group_num
                       , replacement_group_num
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
                       , department_id
--                       , last_update_date
--                       , last_updated_by
--                       , creation_date
--                       , created_by
--                       , last_update_login
--                       , request_id
--                       , program_application_id
--                       , program_id
--                       , program_update_date
                INTO
                         l_eam_sub_res_rec.resource_id
                       , l_eam_sub_res_rec.uom_code
                       , l_eam_sub_res_rec.basis_type
                       , l_eam_sub_res_rec.usage_rate_or_amount
                       , l_eam_sub_res_rec.activity_id
                       , l_eam_sub_res_rec.scheduled_flag
                       , l_eam_sub_res_rec.assigned_units
                       , l_eam_sub_res_rec.autocharge_type
                       , l_eam_sub_res_rec.standard_rate_flag
                       , l_eam_sub_res_rec.applied_resource_units
                       , l_eam_sub_res_rec.applied_resource_value
                       , l_eam_sub_res_rec.start_date
                       , l_eam_sub_res_rec.completion_date
                       , l_eam_sub_res_rec.schedule_seq_num
                       , l_eam_sub_res_rec.substitute_group_num
                       , l_eam_sub_res_rec.replacement_group_num
                       , l_eam_sub_res_rec.attribute_category
                       , l_eam_sub_res_rec.attribute1
                       , l_eam_sub_res_rec.attribute2
                       , l_eam_sub_res_rec.attribute3
                       , l_eam_sub_res_rec.attribute4
                       , l_eam_sub_res_rec.attribute5
                       , l_eam_sub_res_rec.attribute6
                       , l_eam_sub_res_rec.attribute7
                       , l_eam_sub_res_rec.attribute8
                       , l_eam_sub_res_rec.attribute9
                       , l_eam_sub_res_rec.attribute10
                       , l_eam_sub_res_rec.attribute11
                       , l_eam_sub_res_rec.attribute12
                       , l_eam_sub_res_rec.attribute13
                       , l_eam_sub_res_rec.attribute14
                       , l_eam_sub_res_rec.attribute15
                       , l_eam_sub_res_rec.department_id
--                       , l_eam_sub_res_rec.last_update_date
--                       , l_eam_sub_res_rec.last_updated_by
--                       , l_eam_sub_res_rec.creation_date
--                       , l_eam_sub_res_rec.created_by
--                       , l_eam_sub_res_rec.last_update_login
--                       , l_eam_sub_res_rec.request_id
--                       , l_eam_sub_res_rec.program_application_id
--                       , l_eam_sub_res_rec.program_id
--                       , l_eam_sub_res_rec.program_update_date
                FROM     WIP_SUB_OPERATION_RESOURCES
                WHERE    wip_entity_id     = p_wip_entity_id
                  AND    organization_id   = p_organization_id
                  AND    operation_seq_num = p_operation_seq_num
                  AND    resource_seq_num  = p_resource_seq_num;

                x_return_status  := EAM_PROCESS_WO_PVT.G_RECORD_FOUND;
                x_eam_sub_res_rec     := l_eam_sub_res_rec;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND;
                        x_eam_sub_res_rec    := l_eam_sub_res_rec;

                WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_eam_sub_res_rec    := l_eam_sub_res_rec;

        END Query_Row;


        /********************************************************************
        * Procedure     : Insert_Row
        * Parameters IN : Sub Resource column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an insert into the
        *                 wip_sub_operation_resources table.
        *********************************************************************/

        PROCEDURE Insert_Row
        (  p_eam_sub_res_rec   IN  EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Writing Sub Resource rec for ' || p_eam_sub_res_rec.resource_seq_num); END IF;

 -- bug no 3444091
	if p_eam_sub_res_rec.start_date > p_eam_sub_res_rec.completion_date then
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('EAM','EAM_WO_SUBR_DT_ERR');
                return;
	end if;


             INSERT INTO WIP_SUB_OPERATION_RESOURCES
                       ( wip_entity_id
                       , organization_id
                       , operation_seq_num
                       , resource_seq_num
                       , resource_id
                       , uom_code
                       , basis_type
                       , usage_rate_or_amount
                       , activity_id
                       , scheduled_flag
                       , assigned_units
                       , autocharge_type
                       , standard_rate_flag
                       , applied_resource_units
                       , applied_resource_value
                       , start_date
                       , completion_date
                       , schedule_seq_num
                       , substitute_group_num
                       , replacement_group_num
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
                       , department_id
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , last_update_login
                       , request_id
                       , program_application_id
                       , program_id
                       , program_update_date)
                VALUES
                       ( p_eam_sub_res_rec.wip_entity_id
                       , p_eam_sub_res_rec.organization_id
                       , p_eam_sub_res_rec.operation_seq_num
                       , p_eam_sub_res_rec.resource_seq_num
                       , p_eam_sub_res_rec.resource_id
                       , p_eam_sub_res_rec.uom_code
                       , p_eam_sub_res_rec.basis_type
                       , p_eam_sub_res_rec.usage_rate_or_amount
                       , p_eam_sub_res_rec.activity_id
                       , p_eam_sub_res_rec.scheduled_flag
                       , p_eam_sub_res_rec.assigned_units
                       , p_eam_sub_res_rec.autocharge_type
                       , p_eam_sub_res_rec.standard_rate_flag
                       , p_eam_sub_res_rec.applied_resource_units
                       , p_eam_sub_res_rec.applied_resource_value
                       , p_eam_sub_res_rec.start_date
                       , p_eam_sub_res_rec.completion_date
                       , p_eam_sub_res_rec.schedule_seq_num
                       , p_eam_sub_res_rec.substitute_group_num
                       , p_eam_sub_res_rec.replacement_group_num
                       , p_eam_sub_res_rec.attribute_category
                       , p_eam_sub_res_rec.attribute1
                       , p_eam_sub_res_rec.attribute2
                       , p_eam_sub_res_rec.attribute3
                       , p_eam_sub_res_rec.attribute4
                       , p_eam_sub_res_rec.attribute5
                       , p_eam_sub_res_rec.attribute6
                       , p_eam_sub_res_rec.attribute7
                       , p_eam_sub_res_rec.attribute8
                       , p_eam_sub_res_rec.attribute9
                       , p_eam_sub_res_rec.attribute10
                       , p_eam_sub_res_rec.attribute11
                       , p_eam_sub_res_rec.attribute12
                       , p_eam_sub_res_rec.attribute13
                       , p_eam_sub_res_rec.attribute14
                       , p_eam_sub_res_rec.attribute15
                       , p_eam_sub_res_rec.department_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , FND_GLOBAL.login_id
                       , p_eam_sub_res_rec.request_id
                       , p_eam_sub_res_rec.program_application_id
                       , p_eam_sub_res_rec.program_id
                       , SYSDATE);



IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Creating new Sub Resource') ; END IF;

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
        * Parameters IN : Sub Resource column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Update on the
        *                 wip_sub_operation_resources table.
        *********************************************************************/

        PROCEDURE Update_Row
        (  p_eam_sub_res_rec   IN  EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Updating Sub Resource: '|| p_eam_sub_res_rec.resource_seq_num); END IF;

 -- bug no 3444091
	if p_eam_sub_res_rec.start_date > p_eam_sub_res_rec.completion_date then
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('EAM','EAM_WO_SUBR_DT_ERR');
                return;
	end if;

                UPDATE WIP_SUB_OPERATION_RESOURCES
                SET      resource_id                 = p_eam_sub_res_rec.resource_id
                       , uom_code                    = p_eam_sub_res_rec.uom_code
                       , basis_type                  = p_eam_sub_res_rec.basis_type
                       , usage_rate_or_amount        = p_eam_sub_res_rec.usage_rate_or_amount
                       , activity_id                 = p_eam_sub_res_rec.activity_id
                       , scheduled_flag              = p_eam_sub_res_rec.scheduled_flag
                       , assigned_units              = p_eam_sub_res_rec.assigned_units
                       , autocharge_type             = p_eam_sub_res_rec.autocharge_type
                       , standard_rate_flag          = p_eam_sub_res_rec.standard_rate_flag
                       , applied_resource_units      = p_eam_sub_res_rec.applied_resource_units
                       , applied_resource_value      = p_eam_sub_res_rec.applied_resource_value
                       , start_date                  = p_eam_sub_res_rec.start_date
                       , completion_date             = p_eam_sub_res_rec.completion_date
                       , schedule_seq_num            = p_eam_sub_res_rec.schedule_seq_num
                       , substitute_group_num        = p_eam_sub_res_rec.substitute_group_num
                       , replacement_group_num       = p_eam_sub_res_rec.replacement_group_num
                       , attribute_category          = p_eam_sub_res_rec.attribute_category
                       , attribute1                  = p_eam_sub_res_rec.attribute1
                       , attribute2                  = p_eam_sub_res_rec.attribute2
                       , attribute3                  = p_eam_sub_res_rec.attribute3
                       , attribute4                  = p_eam_sub_res_rec.attribute4
                       , attribute5                  = p_eam_sub_res_rec.attribute5
                       , attribute6                  = p_eam_sub_res_rec.attribute6
                       , attribute7                  = p_eam_sub_res_rec.attribute7
                       , attribute8                  = p_eam_sub_res_rec.attribute8
                       , attribute9                  = p_eam_sub_res_rec.attribute9
                       , attribute10                 = p_eam_sub_res_rec.attribute10
                       , attribute11                 = p_eam_sub_res_rec.attribute11
                       , attribute12                 = p_eam_sub_res_rec.attribute12
                       , attribute13                 = p_eam_sub_res_rec.attribute13
                       , attribute14                 = p_eam_sub_res_rec.attribute14
                       , attribute15                 = p_eam_sub_res_rec.attribute15
                       , last_update_date            = SYSDATE
                       , last_updated_by             = FND_GLOBAL.user_id
                       , last_update_login           = FND_GLOBAL.login_id
                       , request_id                  = p_eam_sub_res_rec.request_id
                       , program_application_id      = p_eam_sub_res_rec.program_application_id
                       , program_id                  = p_eam_sub_res_rec.program_id
                       , program_update_date         = SYSDATE
                WHERE    wip_entity_id     = p_eam_sub_res_rec.wip_entity_id
                  AND    organization_id   = p_eam_sub_res_rec.organization_id
                  AND    operation_seq_num = p_eam_sub_res_rec.operation_seq_num
                  AND    resource_seq_num  = p_eam_sub_res_rec.resource_seq_num;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

        END Update_Row;

        /********************************************************************
        * Procedure     : Delete_Row
        * Parameters IN : Sub Resource column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Update on the
        *                 wip_sub_operation_resources table.
        *********************************************************************/

        PROCEDURE Delete_Row
        (  p_eam_sub_res_rec   IN  EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
         , x_mesg_token_Tbl         OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status          OUT NOCOPY VARCHAR2
         )
        IS
                l_Mesg_Token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Deleting Sub Resource Usage') ; END IF;

                EAM_RES_USAGE_UTILITY_PVT.Delete_Usage
                ( p_wip_entity_id      => p_eam_sub_res_rec.wip_entity_id
                , p_organization_id    => p_eam_sub_res_rec.organization_id
                , p_operation_seq_num  => p_eam_sub_res_rec.operation_seq_num
                , p_resource_seq_num   => p_eam_sub_res_rec.resource_seq_num
                , x_mesg_token_Tbl     => l_mesg_token_Tbl
                , x_return_Status      => l_return_Status
                );

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Deleting Sub resources') ; END IF;

                DELETE FROM WIP_SUB_OPERATION_RESOURCES
                WHERE    wip_entity_id     = p_eam_sub_res_rec.wip_entity_id
                  AND    organization_id   = p_eam_sub_res_rec.organization_id
                  AND    operation_seq_num = p_eam_sub_res_rec.operation_seq_num
                  AND    resource_seq_num  = p_eam_sub_res_rec.resource_seq_num;

                x_return_status  := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;
--                x_return_status := FND_API.G_RET_STS_SUCCESS;

        END Delete_Row;


        /*********************************************************************
        * Procedure     : Perform_Writes
        * Parameters IN : Sub Resource Column Record
        * Parameters OUT NOCOPY: Messgae Token Table
        *                 Return Status
        * Purpose       : This is the only procedure that the user will have
        *                 access to when he/she needs to perform any kind of
        *                 writes to the wip_operations.
        *********************************************************************/

        PROCEDURE Perform_Writes
        (  p_eam_sub_res_rec   IN  EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
         , x_mesg_token_tbl         OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status          OUT NOCOPY VARCHAR2
        )
        IS
                l_Mesg_Token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        BEGIN

                IF p_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                        Insert_Row
                        (  p_eam_sub_res_rec        => p_eam_sub_res_rec
                         , x_mesg_token_Tbl         => l_mesg_token_tbl
                         , x_return_Status          => l_return_status
                         );
                ELSIF p_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                THEN
                        Update_Row
                        (  p_eam_sub_res_rec        => p_eam_sub_res_rec
                         , x_mesg_token_Tbl         => l_mesg_token_tbl
                         , x_return_Status          => l_return_status
                         );
                ELSIF p_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE
                THEN
                        Delete_Row
                        (  p_eam_sub_res_rec        => p_eam_sub_res_rec
                         , x_mesg_token_Tbl         => l_mesg_token_tbl
                         , x_return_Status          => l_return_status
                         );

                END IF;

                x_return_status := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Perform_Writes;

END EAM_SUB_RESOURCE_UTILITY_PVT;

/
