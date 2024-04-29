--------------------------------------------------------
--  DDL for Package Body EAM_OP_NETWORK_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OP_NETWORK_UTILITY_PVT" AS
/* $Header: EAMVONUB.pls 115.1 2002/11/25 00:07:44 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVONUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_OP_NETWORK_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_OP_NETWORK_UTILITY_PVT';

        /*********************************************************************
        * Procedure     : Query_Row
        * Parameters IN : wip entity id
        *                 organization Id
        *                 prior operation
        *                 next operation
        * Parameters OUT NOCOPY: Operation Networks column record
        *                 Mesg token Table
        *                 Return Status
        * Purpose       : Procedure will query the database record
        *                 and return with those records.
        ***********************************************************************/

        PROCEDURE Query_Row
        (  p_wip_entity_id       IN  NUMBER
         , p_organization_id     IN  NUMBER
         , p_prior_operation     IN  NUMBER
         , p_next_operation      IN  NUMBER
         , x_eam_op_network_rec  OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_Return_status       OUT NOCOPY VARCHAR2
        )
        IS
                l_eam_op_network_rec    EAM_PROCESS_WO_PUB.eam_op_network_rec_type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
                l_dummy                 varchar2(10);
        BEGIN

                SELECT
                         wip_entity_id
                       , organization_id
                       , prior_operation
                       , next_operation
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
                INTO
                         l_eam_op_network_rec.wip_entity_id
                       , l_eam_op_network_rec.organization_id
                       , l_eam_op_network_rec.prior_operation
                       , l_eam_op_network_rec.next_operation
                       , l_eam_op_network_rec.attribute_category
                       , l_eam_op_network_rec.attribute1
                       , l_eam_op_network_rec.attribute2
                       , l_eam_op_network_rec.attribute3
                       , l_eam_op_network_rec.attribute4
                       , l_eam_op_network_rec.attribute5
                       , l_eam_op_network_rec.attribute6
                       , l_eam_op_network_rec.attribute7
                       , l_eam_op_network_rec.attribute8
                       , l_eam_op_network_rec.attribute9
                       , l_eam_op_network_rec.attribute10
                       , l_eam_op_network_rec.attribute11
                       , l_eam_op_network_rec.attribute12
                       , l_eam_op_network_rec.attribute13
                       , l_eam_op_network_rec.attribute14
                       , l_eam_op_network_rec.attribute15
                FROM  wip_operation_networks won
                WHERE won.wip_entity_id   = p_wip_entity_id
                AND   won.organization_id = p_organization_id
                AND   won.prior_operation  = p_prior_operation
                AND   won.next_operation  = p_next_operation;

                x_return_status  := EAM_PROCESS_WO_PVT.G_RECORD_FOUND;
                x_eam_op_network_rec     := l_eam_op_network_rec;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND;
                        x_eam_op_network_rec    := l_eam_op_network_rec;

                WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_eam_op_network_rec    := l_eam_op_network_rec;

        END Query_Row;


        /********************************************************************
        * Procedure     : Insert_Row
        * Parameters IN : Operation Networks column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an insert into the
        *                 wip_operation_networks table.
        *********************************************************************/

        PROCEDURE Insert_Row
        (  p_eam_op_network_rec IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Writing Operation Networks rec for ' || p_eam_op_network_rec.prior_operation); END IF;

                INSERT INTO WIP_OPERATION_NETWORKS
                       ( wip_entity_id
                       , organization_id
                       , prior_operation
                       , next_operation
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
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , last_update_login
                       )
                VALUES
                       ( p_eam_op_network_rec.wip_entity_id
                       , p_eam_op_network_rec.organization_id
                       , p_eam_op_network_rec.prior_operation
                       , p_eam_op_network_rec.next_operation
                       , p_eam_op_network_rec.attribute_category
                       , p_eam_op_network_rec.attribute1
                       , p_eam_op_network_rec.attribute2
                       , p_eam_op_network_rec.attribute3
                       , p_eam_op_network_rec.attribute4
                       , p_eam_op_network_rec.attribute5
                       , p_eam_op_network_rec.attribute6
                       , p_eam_op_network_rec.attribute7
                       , p_eam_op_network_rec.attribute8
                       , p_eam_op_network_rec.attribute9
                       , p_eam_op_network_rec.attribute10
                       , p_eam_op_network_rec.attribute11
                       , p_eam_op_network_rec.attribute12
                       , p_eam_op_network_rec.attribute13
                       , p_eam_op_network_rec.attribute14
                       , p_eam_op_network_rec.attribute15
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , FND_GLOBAL.login_id
                       );


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Creating new Operation Networks') ; END IF;

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
        * Parameters IN : Operation Networks column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Update on the
        *                 wip_operation_networks table.
        *********************************************************************/

        PROCEDURE Update_Row
        (  p_eam_op_network_rec IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Updating Operation Networks '|| p_eam_op_network_rec.prior_operation); END IF;

      UPDATE WIP_OPERATION_NETWORKS
                SET      prior_operation             = p_eam_op_network_rec.prior_operation
                       , next_operation              = p_eam_op_network_rec.next_operation
                       , attribute_category          = p_eam_op_network_rec.attribute_category
                       , attribute1                  = p_eam_op_network_rec.attribute1
                       , attribute2                  = p_eam_op_network_rec.attribute2
                       , attribute3                  = p_eam_op_network_rec.attribute3
                       , attribute4                  = p_eam_op_network_rec.attribute4
                       , attribute5                  = p_eam_op_network_rec.attribute5
                       , attribute6                  = p_eam_op_network_rec.attribute6
                       , attribute7                  = p_eam_op_network_rec.attribute7
                       , attribute8                  = p_eam_op_network_rec.attribute8
                       , attribute9                  = p_eam_op_network_rec.attribute9
                       , attribute10                 = p_eam_op_network_rec.attribute10
                       , attribute11                 = p_eam_op_network_rec.attribute11
                       , attribute12                 = p_eam_op_network_rec.attribute12
                       , attribute13                 = p_eam_op_network_rec.attribute13
                       , attribute14                 = p_eam_op_network_rec.attribute14
                       , attribute15                 = p_eam_op_network_rec.attribute15
                       , last_update_date            = SYSDATE
                       , last_updated_by             = FND_GLOBAL.user_id
                       , last_update_login           = FND_GLOBAL.login_id
                WHERE    organization_id   = p_eam_op_network_rec.organization_id
                  AND    wip_entity_id     = p_eam_op_network_rec.wip_entity_id
                  AND    prior_operation   = p_eam_op_network_rec.prior_operation;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

        END Update_Row;



        /********************************************************************
        * Procedure     : Delete_Row
        * Parameters IN : Operation Networks column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Delete on the
        *                 wip_operation_networks table.
        *********************************************************************/

        PROCEDURE Delete_Row
        (  p_eam_op_network_rec IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Deleting Operation Networks '|| p_eam_op_network_rec.prior_operation); END IF;

      DELETE FROM WIP_OPERATION_NETWORKS
                WHERE    organization_id   = p_eam_op_network_rec.organization_id
                  AND    wip_entity_id     = p_eam_op_network_rec.wip_entity_id
                  AND    prior_operation   = p_eam_op_network_rec.prior_operation
                  AND    next_operation    = p_eam_op_network_rec.next_operation;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

        END Delete_Row;



        /*********************************************************************
        * Procedure     : Perform_Writes
        * Parameters IN : Operation Networks Record
        * Parameters OUT NOCOPY: Messgae Token Table
        *                 Return Status
        * Purpose       : This is the only procedure that the user will have
        *                 access to when he/she needs to perform any kind of
        *                 writes to the wip_operations.
        *********************************************************************/

        PROCEDURE Perform_Writes
        (  p_eam_op_network_rec IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
        )
        IS
                l_Mesg_Token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        BEGIN

                IF p_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                        Insert_Row
                        (  p_eam_op_network_rec => p_eam_op_network_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                ELSIF p_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                THEN
                        Update_Row
                        (  p_eam_op_network_rec => p_eam_op_network_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );

                ELSIF p_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE
                THEN
                        Delete_Row
                        (  p_eam_op_network_rec => p_eam_op_network_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );

                END IF;

                x_return_status := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Perform_Writes;

END EAM_OP_NETWORK_UTILITY_PVT;

/
