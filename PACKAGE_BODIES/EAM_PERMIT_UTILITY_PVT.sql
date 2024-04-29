--------------------------------------------------------
--  DDL for Package Body EAM_PERMIT_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PERMIT_UTILITY_PVT" AS
/* $Header: EAMVWPUB.pls 120.0.12010000.2 2010/04/20 10:32:14 vboddapa noship $ */

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'EAM_PERMIT_UTILITY_PVT';
G_FILE_NAME      CONSTANT VARCHAR2(12) := 'EAMVWPUB.pls';


/*********************************************************************
* Procedure     : QUERY_ROW
* Purpose       : Procedure will query the database record
                  and return with those records.
***********************************************************************/
PROCEDURE QUERY_ROW
        				( p_work_permit_id       IN  NUMBER
                  , p_organization_id         IN  NUMBER
                  , x_work_permit_header_rec OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                  , x_Return_status       OUT NOCOPY VARCHAR2
         				) IS

                l_work_permit_header_rec EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;
BEGIN


                  SELECT
                      ewp.PERMIT_ID
                      ,ewp.PERMIT_NAME
                      ,ewp.DESCRIPTION
                      ,ewp.ORGANIZATION_ID
                      ,ewp.PERMIT_TYPE
                      ,ewp.VALID_FROM
                      ,ewp.VALID_TO
                      ,ewp.PENDING_FLAG
                      ,ewp.COMPLETION_DATE
                      ,ewp.USER_DEFINED_STATUS_ID
                      ,ewp.STATUS_TYPE
                      ,ewp.ATTRIBUTE_CATEGORY
                      ,ewp.ATTRIBUTE1
                      ,ewp.ATTRIBUTE2
                      ,ewp.ATTRIBUTE3
                      ,ewp.ATTRIBUTE4
                      ,ewp.ATTRIBUTE5
                      ,ewp.ATTRIBUTE6
                      ,ewp.ATTRIBUTE7
                      ,ewp.ATTRIBUTE8
                      ,ewp.ATTRIBUTE9
                      ,ewp.ATTRIBUTE10
                      ,ewp.ATTRIBUTE11
                      ,ewp.ATTRIBUTE12
                      ,ewp.ATTRIBUTE13
                      ,ewp.ATTRIBUTE14
                      ,ewp.ATTRIBUTE15
                      ,ewp.ATTRIBUTE16
                      ,ewp.ATTRIBUTE17
                      ,ewp.ATTRIBUTE18
                      ,ewp.ATTRIBUTE19
                      ,ewp.ATTRIBUTE20
                      ,ewp.ATTRIBUTE21
                      ,ewp.ATTRIBUTE22
                      ,ewp.ATTRIBUTE23
                      ,ewp.ATTRIBUTE24
                      ,ewp.ATTRIBUTE25
                      ,ewp.ATTRIBUTE26
                      ,ewp.ATTRIBUTE27
                      ,ewp.ATTRIBUTE28
                      ,ewp.ATTRIBUTE29
                      ,ewp.ATTRIBUTE30
                      ,ewp.APPROVED_BY
                      ,ewp.CREATION_DATE
                      ,ewp.CREATED_BY

                  INTO
                       l_work_permit_header_rec.PERMIT_ID
                      ,l_work_permit_header_rec.PERMIT_NAME
                      ,l_work_permit_header_rec.DESCRIPTION
                      ,l_work_permit_header_rec.ORGANIZATION_ID
                      ,l_work_permit_header_rec.PERMIT_TYPE
                      ,l_work_permit_header_rec.VALID_FROM
                      ,l_work_permit_header_rec.VALID_TO
                      ,l_work_permit_header_rec.PENDING_FLAG
                      ,l_work_permit_header_rec.COMPLETION_DATE
                      ,l_work_permit_header_rec.USER_DEFINED_STATUS_ID
                      ,l_work_permit_header_rec.STATUS_TYPE
                      ,l_work_permit_header_rec.ATTRIBUTE_CATEGORY
                      ,l_work_permit_header_rec.ATTRIBUTE1
                      ,l_work_permit_header_rec.ATTRIBUTE2
                      ,l_work_permit_header_rec.ATTRIBUTE3
                      ,l_work_permit_header_rec.ATTRIBUTE4
                      ,l_work_permit_header_rec.ATTRIBUTE5
                      ,l_work_permit_header_rec.ATTRIBUTE6
                      ,l_work_permit_header_rec.ATTRIBUTE7
                      ,l_work_permit_header_rec.ATTRIBUTE8
                      ,l_work_permit_header_rec.ATTRIBUTE9
                      ,l_work_permit_header_rec.ATTRIBUTE10
                      ,l_work_permit_header_rec.ATTRIBUTE11
                      ,l_work_permit_header_rec.ATTRIBUTE12
                      ,l_work_permit_header_rec.ATTRIBUTE13
                      ,l_work_permit_header_rec.ATTRIBUTE14
                      ,l_work_permit_header_rec.ATTRIBUTE15
                      ,l_work_permit_header_rec.ATTRIBUTE16
                      ,l_work_permit_header_rec.ATTRIBUTE17
                      ,l_work_permit_header_rec.ATTRIBUTE18
                      ,l_work_permit_header_rec.ATTRIBUTE19
                      ,l_work_permit_header_rec.ATTRIBUTE20
                      ,l_work_permit_header_rec.ATTRIBUTE21
                      ,l_work_permit_header_rec.ATTRIBUTE22
                      ,l_work_permit_header_rec.ATTRIBUTE23
                      ,l_work_permit_header_rec.ATTRIBUTE24
                      ,l_work_permit_header_rec.ATTRIBUTE25
                      ,l_work_permit_header_rec.ATTRIBUTE26
                      ,l_work_permit_header_rec.ATTRIBUTE27
                      ,l_work_permit_header_rec.ATTRIBUTE28
                      ,l_work_permit_header_rec.ATTRIBUTE29
                      ,l_work_permit_header_rec.ATTRIBUTE30
                      ,l_work_permit_header_rec.APPROVED_BY
                      ,l_work_permit_header_rec.CREATION_DATE
                      ,l_work_permit_header_rec.CREATED_BY

                  FROM EAM_WORK_PERMITS ewp
                  WHERE ewp.permit_id = p_work_permit_id
                  AND   ewp.organization_id = p_organization_id;

                x_return_status  := EAM_PROCESS_WO_PVT.G_RECORD_FOUND;
                x_work_permit_header_rec     := l_work_permit_header_rec;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND;
        x_work_permit_header_rec := l_work_permit_header_rec;

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_work_permit_header_rec     := l_work_permit_header_rec;

END QUERY_ROW;

/********************************************************************
* Procedure     : INSERT_ROW
* Purpose       : Procedure will perfrom an insert into the table
*********************************************************************/
PROCEDURE INSERT_ROW
       				 (p_work_permit_header_rec    IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                 , x_return_Status      OUT NOCOPY VARCHAR2
        				 )
                IS

BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Writing Permit rec for ' || p_work_permit_header_rec.PERMIT_NAME); END IF;


              INSERT INTO EAM_WORK_PERMITS(
                      PERMIT_ID
                      ,PERMIT_NAME
                      ,DESCRIPTION
                      ,ORGANIZATION_ID
                      ,PERMIT_TYPE
                      ,VALID_FROM
                      ,VALID_TO
                      ,PENDING_FLAG
                      ,COMPLETION_DATE
                      ,USER_DEFINED_STATUS_ID
                      ,STATUS_TYPE
                      ,ATTRIBUTE_CATEGORY
                      ,ATTRIBUTE1
                      ,ATTRIBUTE2
                      ,ATTRIBUTE3
                      ,ATTRIBUTE4
                      ,ATTRIBUTE5
                      ,ATTRIBUTE6
                      ,ATTRIBUTE7
                      ,ATTRIBUTE8
                      ,ATTRIBUTE9
                      ,ATTRIBUTE10
                      ,ATTRIBUTE11
                      ,ATTRIBUTE12
                      ,ATTRIBUTE13
                      ,ATTRIBUTE14
                      ,ATTRIBUTE15
                      ,ATTRIBUTE16
                      ,ATTRIBUTE17
                      ,ATTRIBUTE18
                      ,ATTRIBUTE19
                      ,ATTRIBUTE20
                      ,ATTRIBUTE21
                      ,ATTRIBUTE22
                      ,ATTRIBUTE23
                      ,ATTRIBUTE24
                      ,ATTRIBUTE25
                      ,ATTRIBUTE26
                      ,ATTRIBUTE27
                      ,ATTRIBUTE28
                      ,ATTRIBUTE29
                      ,ATTRIBUTE30
                      ,APPROVED_BY
                      ,LAST_UPDATE_DATE
                      ,LAST_UPDATED_BY
                      ,CREATION_DATE
                      ,CREATED_BY
                      ,LAST_UPDATE_LOGIN)
                  VALUES
                      ( p_work_permit_header_rec.PERMIT_ID
                      ,p_work_permit_header_rec.PERMIT_NAME
                      ,p_work_permit_header_rec.DESCRIPTION
                      ,p_work_permit_header_rec.ORGANIZATION_ID
                      ,p_work_permit_header_rec.PERMIT_TYPE
                      ,p_work_permit_header_rec.VALID_FROM
                      ,p_work_permit_header_rec.VALID_TO
                      ,decode(p_work_permit_header_rec.PENDING_FLAG,FND_API.G_MISS_CHAR, NULL, p_work_permit_header_rec.PENDING_FLAG)
                      ,p_work_permit_header_rec.COMPLETION_DATE
                      ,p_work_permit_header_rec.USER_DEFINED_STATUS_ID
                      ,p_work_permit_header_rec.STATUS_TYPE
                      ,p_work_permit_header_rec.ATTRIBUTE_CATEGORY
                      ,p_work_permit_header_rec.ATTRIBUTE1
                      ,p_work_permit_header_rec.ATTRIBUTE2
                      ,p_work_permit_header_rec.ATTRIBUTE3
                      ,p_work_permit_header_rec.ATTRIBUTE4
                      ,p_work_permit_header_rec.ATTRIBUTE5
                      ,p_work_permit_header_rec.ATTRIBUTE6
                      ,p_work_permit_header_rec.ATTRIBUTE7
                      ,p_work_permit_header_rec.ATTRIBUTE8
                      ,p_work_permit_header_rec.ATTRIBUTE9
                      ,p_work_permit_header_rec.ATTRIBUTE10
                      ,p_work_permit_header_rec.ATTRIBUTE11
                      ,p_work_permit_header_rec.ATTRIBUTE12
                      ,p_work_permit_header_rec.ATTRIBUTE13
                      ,p_work_permit_header_rec.ATTRIBUTE14
                      ,p_work_permit_header_rec.ATTRIBUTE15
                      ,p_work_permit_header_rec.ATTRIBUTE16
                      ,p_work_permit_header_rec.ATTRIBUTE17
                      ,p_work_permit_header_rec.ATTRIBUTE18
                      ,p_work_permit_header_rec.ATTRIBUTE19
                      ,p_work_permit_header_rec.ATTRIBUTE20
                      ,p_work_permit_header_rec.ATTRIBUTE21
                      ,p_work_permit_header_rec.ATTRIBUTE22
                      ,p_work_permit_header_rec.ATTRIBUTE23
                      ,p_work_permit_header_rec.ATTRIBUTE24
                      ,p_work_permit_header_rec.ATTRIBUTE25
                      ,p_work_permit_header_rec.ATTRIBUTE26
                      ,p_work_permit_header_rec.ATTRIBUTE27
                      ,p_work_permit_header_rec.ATTRIBUTE28
                      ,p_work_permit_header_rec.ATTRIBUTE29
                      ,p_work_permit_header_rec.ATTRIBUTE30
                      ,decode(p_work_permit_header_rec.APPROVED_BY, FND_API.G_MISS_CHAR, NULL, p_work_permit_header_rec.APPROVED_BY)
                      ,SYSDATE
                      ,FND_GLOBAL.user_id
                      ,SYSDATE
                      ,FND_GLOBAL.user_id
                      ,FND_GLOBAL.login_id);

                      x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_error;

END INSERT_ROW;

/********************************************************************
* Procedure     : UPDATE_ROW
* Purpose       : Procedure will perform an update on the table
*********************************************************************/

PROCEDURE UPDATE_ROW
        				( p_work_permit_header_rec    IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                 , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                 , x_return_Status      OUT NOCOPY VARCHAR2
       				  ) IS

BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Updating Permit rec for ' || p_work_permit_header_rec.PERMIT_NAME); END IF;


               UPDATE EAM_WORK_PERMITS
               SET      DESCRIPTION             =p_work_permit_header_rec.DESCRIPTION
                     --,PERMIT_TYPE	              =p_work_permit_header_rec.PERMIT_TYPE--
                      ,VALID_FROM               =p_work_permit_header_rec.VALID_FROM
                      ,VALID_TO	                =p_work_permit_header_rec.VALID_TO
                      ,PENDING_FLAG             =p_work_permit_header_rec.PENDING_FLAG
		      ,APPROVED_BY              =p_work_permit_header_rec.APPROVED_BY
                      ,COMPLETION_DATE          =p_work_permit_header_rec.COMPLETION_DATE
                      ,STATUS_TYPE              =p_work_permit_header_rec.STATUS_TYPE
                      ,USER_DEFINED_STATUS_ID   =p_work_permit_header_rec.USER_DEFINED_STATUS_ID
                      ,ATTRIBUTE_CATEGORY       =p_work_permit_header_rec.ATTRIBUTE_CATEGORY
                      ,ATTRIBUTE1               =p_work_permit_header_rec.ATTRIBUTE1
                      ,ATTRIBUTE2               =p_work_permit_header_rec.ATTRIBUTE2
                      ,ATTRIBUTE3               =p_work_permit_header_rec.ATTRIBUTE3
                      ,ATTRIBUTE4               =p_work_permit_header_rec.ATTRIBUTE4
                      ,ATTRIBUTE5               =p_work_permit_header_rec.ATTRIBUTE5
                      ,ATTRIBUTE6               =p_work_permit_header_rec.ATTRIBUTE6
                      ,ATTRIBUTE7               =p_work_permit_header_rec.ATTRIBUTE7
                      ,ATTRIBUTE8               =p_work_permit_header_rec.ATTRIBUTE8
                      ,ATTRIBUTE9               =p_work_permit_header_rec.ATTRIBUTE9
                      ,ATTRIBUTE10              =p_work_permit_header_rec.ATTRIBUTE10
                      ,ATTRIBUTE11              =p_work_permit_header_rec.ATTRIBUTE11
                      ,ATTRIBUTE12              =p_work_permit_header_rec.ATTRIBUTE12
                      ,ATTRIBUTE13              =p_work_permit_header_rec.ATTRIBUTE13
                      ,ATTRIBUTE14              =p_work_permit_header_rec.ATTRIBUTE14
                      ,ATTRIBUTE15              =p_work_permit_header_rec.ATTRIBUTE15
                      ,ATTRIBUTE16              =p_work_permit_header_rec.ATTRIBUTE16
                      ,ATTRIBUTE17              =p_work_permit_header_rec.ATTRIBUTE17
                      ,ATTRIBUTE18              =p_work_permit_header_rec.ATTRIBUTE18
                      ,ATTRIBUTE19              =p_work_permit_header_rec.ATTRIBUTE19
                      ,ATTRIBUTE20              =p_work_permit_header_rec.ATTRIBUTE20
                      ,ATTRIBUTE21              =p_work_permit_header_rec.ATTRIBUTE21
                      ,ATTRIBUTE22              =p_work_permit_header_rec.ATTRIBUTE22
                      ,ATTRIBUTE23              =p_work_permit_header_rec.ATTRIBUTE23
                      ,ATTRIBUTE24              =p_work_permit_header_rec.ATTRIBUTE24
                      ,ATTRIBUTE25              =p_work_permit_header_rec.ATTRIBUTE25
                      ,ATTRIBUTE26              =p_work_permit_header_rec.ATTRIBUTE26
                      ,ATTRIBUTE27              =p_work_permit_header_rec.ATTRIBUTE27
                      ,ATTRIBUTE28              =p_work_permit_header_rec.ATTRIBUTE28
                      ,ATTRIBUTE29              =p_work_permit_header_rec.ATTRIBUTE29
                      ,ATTRIBUTE30              =p_work_permit_header_rec.ATTRIBUTE30
                    --  ,APPROVED_BY              =p_work_permit_header_rec.APPROVED_BY
                      ,LAST_UPDATE_DATE         =SYSDATE
                      ,LAST_UPDATED_BY          =FND_GLOBAL.user_id
                      ,LAST_UPDATE_LOGIN        =FND_GLOBAL.login_id
                WHERE permit_id = p_work_permit_header_rec.permit_id
                AND   organization_id = p_work_permit_header_rec.organization_id;

            x_return_status := FND_API.G_RET_STS_SUCCESS;

END UPDATE_ROW;


/********************************************************************
* Procedure     : PERFORM_WRITES
* Purpose       : This is the only procedure that the user will have
                  access to when he/she needs to perform any kind of writes to the table.
*********************************************************************/

PROCEDURE PERFORM_WRITES
                ( p_work_permit_header_rec    IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
                  , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                  , x_return_Status      OUT NOCOPY VARCHAR2
                )IS
                l_msg_data        VARCHAR2(240);
                l_return_status    VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
BEGIN

     IF p_work_permit_header_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                        Insert_Row
                        (  p_work_permit_header_rec         => p_work_permit_header_rec
                         , x_return_Status     => l_return_status
                         );

                ELSIF p_work_permit_header_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                THEN
                        Update_Row
                        (  p_work_permit_header_rec         => p_work_permit_header_rec
                         , x_mesg_token_Tbl          => x_mesg_token_Tbl
                         , x_return_Status     => l_return_status
                         );

      END IF;

      x_return_status := l_return_status;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_error;


END PERFORM_WRITES;

/********************************************************************
* Procedure     : CHANGE_WORK_PERMIT_STATUS
* Purpose       : This procedure performs different validations for status changes.
*********************************************************************/
PROCEDURE CHANGE_WORK_PERMIT_STATUS
                (    p_permit_id            IN  NUMBER
                  ,  p_organization_id      IN  NUMBER
                  ,  p_to_status_type       IN  NUMBER
                  ,  p_user_id              IN  NUMBER
                  ,  p_responsibility_id    IN  NUMBER
                  ,  p_transaction_type     IN  NUMBER
                  ,  x_return_status        OUT NOCOPY           VARCHAR2
                  ,  x_Mesg_Token_Tbl       OUT NOCOPY           EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                 )IS

                 l_permit_id                NUMBER := 0;
                 l_current_status           NUMBER := 0;
                 l_to_status_type           NUMBER := 0;
                 l_organization_id          NUMBER := 0;
                 l_final_status             NUMBER := 0; -- this status will be updated in WDJ
                 l_user_id                  NUMBER :=0;
                 l_responsibility_id        NUMBER :=0;

                 CHANGE_STATUS_NOT_POSSIBLE    EXCEPTION;
                 CHNGE_ST_FRM_TO_NOT_PSSBLE    EXCEPTION;
                 INVALID_RELEASE               EXCEPTION;
                 INVALID_UNRELEASE             EXCEPTION;
BEGIN

 SAVEPOINT CHANGE_WORK_PERMIT_STATUS;

  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Inside CHANGE_WORK_PERMIT_STATUS '); END IF;

                l_permit_id          := p_permit_id;
                 l_organization_id   := p_organization_id;
                 l_to_status_type    := p_to_status_type;
                 l_user_id           := p_user_id;
                 l_responsibility_id := p_responsibility_id;

   IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating Status'); END IF;
                 -- Validate status_id

        IF l_to_status_type NOT IN (WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.COMP_CHRG,WIP_CONSTANTS.COMP_NOCHRG,
                                       WIP_CONSTANTS.CANCELLED, WIP_CONSTANTS.DRAFT)
                 THEN

                     raise fnd_api.g_exc_unexpected_error;

        END IF;
      -- Update status in permits table
      IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Update status in permits table'); END IF;
        BEGIN

						     UPDATE  EAM_WORK_PERMITS
						     SET     STATUS_TYPE = l_to_status_type
						     WHERE   ORGANIZATION_ID = l_organization_id
						     AND     permit_id = l_permit_id;

                 EXCEPTION
						 WHEN OTHERS THEN
						     raise fnd_api.g_exc_unexpected_error;
            END;

EXCEPTION
        WHEN fnd_api.g_exc_error THEN
           ROLLBACK TO CHANGE_WORK_PERMIT_STATUS;
           x_return_status := fnd_api.g_ret_sts_error;


        WHEN OTHERS THEN
          ROLLBACK TO CHANGE_WORK_PERMIT_STATUS;
          x_return_status := fnd_api.g_ret_sts_unexp_error;

END CHANGE_WORK_PERMIT_STATUS;



PROCEDURE INSERT_PERMIT_HISTORY_ROW
                (   p_object_id           IN NUMBER
                  , p_object_name         IN VARCHAR2
                  , p_object_type         IN NUMBER :=3
                  , p_event               IN VARCHAR2
                  , p_status              IN VARCHAR2
                  , p_details             IN VARCHAR2
                  , p_user_id             IN NUMBER
                  , x_mesg_token_Tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
                  , x_return_Status       OUT NOCOPY VARCHAR2
                )IS
BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Inside INSERT_PERMIT_HISTORY_ROW '); END IF;

END INSERT_PERMIT_HISTORY_ROW;


END EAM_PERMIT_UTILITY_PVT;


/
