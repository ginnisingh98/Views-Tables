--------------------------------------------------------
--  DDL for Package Body EAM_RES_USAGE_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_RES_USAGE_UTILITY_PVT" AS
/* $Header: EAMVRUUB.pls 120.2 2005/10/06 02:01:14 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRUUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_RES_USAGE_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_RES_USAGE_UTILITY_PVT';


        /********************************************************************
        * Procedure     : Add Usage
        * Parameters IN :
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an insert into the
        *                 wip_operation_resource_usage table.
        *********************************************************************/

        PROCEDURE Add_Usage
         ( p_eam_res_usage_rec  IN  EAM_PROCESS_WO_PUB.eam_res_usage_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Writing Resource Usage for ' || p_eam_res_usage_rec.resource_seq_num); END IF;

        -- bug no 3444091
	if p_eam_res_usage_rec.start_date > p_eam_res_usage_rec.completion_date then
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('EAM','EAM_WO_RU_DT_ERR');
                return;
	end if;


             INSERT INTO WIP_OPERATION_RESOURCE_USAGE
                     (   wip_entity_id
                       , operation_seq_num
                       , resource_seq_num
                       , organization_id
		       , instance_id
		       , serial_number
                       , start_date
                       , completion_date
                       , assigned_units
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
                      (  p_eam_res_usage_rec.wip_entity_id
                       , p_eam_res_usage_rec.operation_seq_num
                       , p_eam_res_usage_rec.resource_seq_num
                       , p_eam_res_usage_rec.organization_id
		       , p_eam_res_usage_rec.instance_id
		       , p_eam_res_usage_rec.serial_number
                       , p_eam_res_usage_rec.start_date
                       , p_eam_res_usage_rec.completion_date
                       , p_eam_res_usage_rec.assigned_units
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , FND_GLOBAL.login_id
                       , p_eam_res_usage_rec.request_id
                       , p_eam_res_usage_rec.program_application_id
                       , p_eam_res_usage_rec.program_id
                       , SYSDATE);


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Creating new Resource Usage') ; END IF;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION
            WHEN OTHERS THEN
                        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||' :Inserting Record ' || SQLERRM
                         , x_mesg_token_Tbl     => x_mesg_token_tbl
                        );

                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Add_Usage;

        /********************************************************************
        * Procedure     : Delete_Usage
        * Parameters IN :
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Delete on the
        *                 wip_operation_resource_usage table.
        *********************************************************************/

        PROCEDURE Delete_Usage
        ( p_wip_entity_id      IN NUMBER
        , p_organization_id    IN NUMBER
        , p_operation_seq_num  IN NUMBER
        , p_resource_seq_num   IN NUMBER
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Deleting Resource Usage: '|| p_resource_seq_num); END IF;

                DELETE FROM WIP_OPERATION_RESOURCE_USAGE
                WHERE    wip_entity_id     = p_wip_entity_id
                  AND    organization_id   = p_organization_id
                  AND    operation_seq_num = p_operation_seq_num
                  AND    resource_seq_num  = p_resource_seq_num;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

        END Delete_Usage;


        FUNCTION NUM_OF_ROW
        ( p_eam_res_usage_tbl  IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        , p_wip_entity_id      IN NUMBER
        , p_organization_id    IN NUMBER
        , p_operation_seq_num  IN NUMBER
        , p_resource_seq_num   IN NUMBER
        ) RETURN BOOLEAN
        IS

        l_count    NUMBER := 0;

        l_eam_res_usage_rec      EAM_PROCESS_WO_PUB.eam_res_usage_rec_type ;
        l_eam_res_usage_tbl      EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;

        BEGIN

           l_eam_res_usage_tbl  := p_eam_res_usage_tbl ;

           FOR I IN 1..l_eam_res_usage_tbl.COUNT LOOP

           l_eam_res_usage_rec  := l_eam_res_usage_tbl(I);

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Return status validation passed') ; END IF ;

             IF ( l_eam_res_usage_rec.wip_entity_id     = p_wip_entity_id      and
                  l_eam_res_usage_rec.organization_id   = p_organization_id    and
                  l_eam_res_usage_rec.operation_seq_num = p_operation_seq_num  and
                  l_eam_res_usage_rec.resource_seq_num  = p_resource_seq_num
                ) THEN

                l_count := l_count + 1;

             END IF;

           END LOOP;

             IF (l_count > 0) THEN
                RETURN FALSE;
             ELSE
                RETURN TRUE;
             END IF;

        END NUM_OF_ROW;


END EAM_RES_USAGE_UTILITY_PVT;

/
