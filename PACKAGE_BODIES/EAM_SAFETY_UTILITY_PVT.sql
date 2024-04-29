--------------------------------------------------------
--  DDL for Package Body EAM_SAFETY_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_SAFETY_UTILITY_PVT" AS
/* $Header: EAMVSAUB.pls 120.0.12010000.1 2010/03/19 01:15:34 mashah noship $ */

/*********************************************************************
* Procedure     : QUERY_SAFFETY_ASSOCIATION_ROWS
* Purpose       : Procedure will query the database record
                  and return with those records.
 ***********************************************************************/

PROCEDURE QUERY_SAFFETY_ASSOCIATION_ROWS
        		( p_source_id           IN  NUMBER
        		 , p_organization_id    IN  NUMBER
             , p_association_type   IN NUMBER
             , x_safety_association_rec OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type
       		   , x_return_status       OUT NOCOPY VARCHAR2
         		 )IS

             l_safety_association_rec EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type ;
BEGIN
                  SELECT
                       SAFETY_ASSOCIATION_ID
                      ,SOURCE_ID
                      ,TARGET_REF_ID
                      ,ASSOCIATION_TYPE
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
                      ,CREATION_DATE
                      ,CREATED_BY

                  INTO
                       l_safety_association_rec.SAFETY_ASSOCIATION_ID
                      ,l_safety_association_rec.SOURCE_ID
                      ,l_safety_association_rec.TARGET_REF_ID
                      ,l_safety_association_rec.ASSOCIATION_TYPE
                      ,l_safety_association_rec.ATTRIBUTE_CATEGORY
                      ,l_safety_association_rec.ATTRIBUTE1
                      ,l_safety_association_rec.ATTRIBUTE2
                      ,l_safety_association_rec.ATTRIBUTE3
                      ,l_safety_association_rec.ATTRIBUTE4
                      ,l_safety_association_rec.ATTRIBUTE5
                      ,l_safety_association_rec.ATTRIBUTE6
                      ,l_safety_association_rec.ATTRIBUTE7
                      ,l_safety_association_rec.ATTRIBUTE8
                      ,l_safety_association_rec.ATTRIBUTE9
                      ,l_safety_association_rec.ATTRIBUTE10
                      ,l_safety_association_rec.ATTRIBUTE11
                      ,l_safety_association_rec.ATTRIBUTE12
                      ,l_safety_association_rec.ATTRIBUTE13
                      ,l_safety_association_rec.ATTRIBUTE14
                      ,l_safety_association_rec.ATTRIBUTE15
                      ,l_safety_association_rec.ATTRIBUTE16
                      ,l_safety_association_rec.ATTRIBUTE17
                      ,l_safety_association_rec.ATTRIBUTE18
                      ,l_safety_association_rec.ATTRIBUTE19
                      ,l_safety_association_rec.ATTRIBUTE20
                      ,l_safety_association_rec.ATTRIBUTE21
                      ,l_safety_association_rec.ATTRIBUTE22
                      ,l_safety_association_rec.ATTRIBUTE23
                      ,l_safety_association_rec.ATTRIBUTE24
                      ,l_safety_association_rec.ATTRIBUTE25
                      ,l_safety_association_rec.ATTRIBUTE26
                      ,l_safety_association_rec.ATTRIBUTE27
                      ,l_safety_association_rec.ATTRIBUTE28
                      ,l_safety_association_rec.ATTRIBUTE28
                      ,l_safety_association_rec.ATTRIBUTE30
                      ,l_safety_association_rec.CREATION_DATE
                      ,l_safety_association_rec.CREATED_BY

                  FROM EAM_SAFETY_ASSOCIATIONS esa
                  WHERE esa.SOURCE_ID = p_source_id
                  AND   esa.organization_id = p_organization_id
                  AND   esa.ASSOCIATION_TYPE = p_association_type;

                x_return_status  := EAM_PROCESS_WO_PVT.G_RECORD_FOUND;
                x_safety_association_rec     := l_safety_association_rec;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND;
         x_safety_association_rec     := l_safety_association_rec;

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_safety_association_rec     := l_safety_association_rec;


END QUERY_SAFFETY_ASSOCIATION_ROWS;





/********************************************************************
* Procedure     : INSERT_ SAFFETY_ASSOCIATION _ROW
* Purpose       : Procedure will perfrom an insert into the table
*********************************************************************/

PROCEDURE INSERT_SAFFETY_ASSOCIATION_ROW
       		 ( p_safety_association_rec   IN  EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type
            , p_association_type        IN NUMBER
            , x_mesg_token_Tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
            , x_return_Status           OUT NOCOPY VARCHAR2
            )IS

            l_organization_id NUMBER;
            l_effective_from DATE :=null;
            l_effective_to DATE  :=null;
            l_enabled varchar (3) :=null;

BEGIN
     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Inserting Safety Association Row'); END IF;

          select organization_id
          into l_organization_id
          from wip_discrete_jobs
          where wip_entity_id = p_safety_association_rec.TARGET_REF_ID;


      INSERT INTO EAM_SAFETY_ASSOCIATIONS(
                       SAFETY_ASSOCIATION_ID
                      ,SOURCE_ID
                      ,TARGET_REF_ID
                      ,ASSOCIATION_TYPE
                      ,ORGANIZATION_ID
                      ,EFFECTIVE_FROM
                      ,EFFECTIVE_TO
                      ,ENABLED
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
                      ,LAST_UPDATE_DATE
                      ,LAST_UPDATED_BY
                      ,CREATION_DATE
                      ,CREATED_BY
                      ,LAST_UPDATE_LOGIN )
                  VALUES
                      ( p_safety_association_rec.SAFETY_ASSOCIATION_ID
                      ,p_safety_association_rec.SOURCE_ID
                      ,p_safety_association_rec.TARGET_REF_ID
                      ,p_safety_association_rec.ASSOCIATION_TYPE
                      ,l_organization_id
                      ,l_effective_from
                      ,l_effective_to
                      ,l_enabled
                      ,p_safety_association_rec.ATTRIBUTE_CATEGORY
                      ,p_safety_association_rec.ATTRIBUTE1
                      ,p_safety_association_rec.ATTRIBUTE2
                      ,p_safety_association_rec.ATTRIBUTE3
                      ,p_safety_association_rec.ATTRIBUTE4
                      ,p_safety_association_rec.ATTRIBUTE5
                      ,p_safety_association_rec.ATTRIBUTE6
                      ,p_safety_association_rec.ATTRIBUTE7
                      ,p_safety_association_rec.ATTRIBUTE8
                      ,p_safety_association_rec.ATTRIBUTE9
                      ,p_safety_association_rec.ATTRIBUTE10
                      ,p_safety_association_rec.ATTRIBUTE11
                      ,p_safety_association_rec.ATTRIBUTE12
                      ,p_safety_association_rec.ATTRIBUTE13
                      ,p_safety_association_rec.ATTRIBUTE14
                      ,p_safety_association_rec.ATTRIBUTE15
                      ,p_safety_association_rec.ATTRIBUTE16
                      ,p_safety_association_rec.ATTRIBUTE17
                      ,p_safety_association_rec.ATTRIBUTE18
                      ,p_safety_association_rec.ATTRIBUTE19
                      ,p_safety_association_rec.ATTRIBUTE20
                      ,p_safety_association_rec.ATTRIBUTE21
                      ,p_safety_association_rec.ATTRIBUTE22
                      ,p_safety_association_rec.ATTRIBUTE23
                      ,p_safety_association_rec.ATTRIBUTE24
                      ,p_safety_association_rec.ATTRIBUTE25
                      ,p_safety_association_rec.ATTRIBUTE26
                      ,p_safety_association_rec.ATTRIBUTE27
                      ,p_safety_association_rec.ATTRIBUTE28
                      ,p_safety_association_rec.ATTRIBUTE29
                      ,p_safety_association_rec.ATTRIBUTE30
                      ,SYSDATE
                      ,FND_GLOBAL.user_id
                      ,SYSDATE
                      ,FND_GLOBAL.user_id
                      ,FND_GLOBAL.login_id);

                      x_return_status := FND_API.G_RET_STS_SUCCESS;

END INSERT_SAFFETY_ASSOCIATION_ROW;




/********************************************************************
* Procedure     : UPDATE_ SAFFETY_ASSOCIATION _ROW
* Purpose       : Procedure will perform an update on the table
*********************************************************************/


PROCEDURE UPDATE_SAFFETY_ASSOCIATION_ROW
        		( p_safety_association_rec  IN  EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type
              , p_association_type      IN NUMBER
              , x_mesg_token_Tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
              , x_return_Status         OUT NOCOPY VARCHAR2
       		   )IS


BEGIN
     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Updating Safety Association Row'); END IF;

        UPDATE EAM_SAFETY_ASSOCIATIONS
        SET
                      TARGET_REF_ID             =p_safety_association_rec.TARGET_REF_ID
                      ,ATTRIBUTE_CATEGORY       =p_safety_association_rec.ATTRIBUTE_CATEGORY
                      ,ATTRIBUTE1               =p_safety_association_rec.ATTRIBUTE1
                      ,ATTRIBUTE2               =p_safety_association_rec.ATTRIBUTE2
                      ,ATTRIBUTE3               =p_safety_association_rec.ATTRIBUTE3
                      ,ATTRIBUTE4               =p_safety_association_rec.ATTRIBUTE4
                      ,ATTRIBUTE5               =p_safety_association_rec.ATTRIBUTE5
                      ,ATTRIBUTE6               =p_safety_association_rec.ATTRIBUTE6
                      ,ATTRIBUTE7               =p_safety_association_rec.ATTRIBUTE7
                      ,ATTRIBUTE8               =p_safety_association_rec.ATTRIBUTE8
                      ,ATTRIBUTE9               =p_safety_association_rec.ATTRIBUTE9
                      ,ATTRIBUTE10              =p_safety_association_rec.ATTRIBUTE10
                      ,ATTRIBUTE11              =p_safety_association_rec.ATTRIBUTE11
                      ,ATTRIBUTE12              =p_safety_association_rec.ATTRIBUTE12
                      ,ATTRIBUTE13              =p_safety_association_rec.ATTRIBUTE13
                      ,ATTRIBUTE14              =p_safety_association_rec.ATTRIBUTE14
                      ,ATTRIBUTE15              =p_safety_association_rec.ATTRIBUTE15
                      ,ATTRIBUTE16               =p_safety_association_rec.ATTRIBUTE16
                      ,ATTRIBUTE17              =p_safety_association_rec.ATTRIBUTE17
                      ,ATTRIBUTE18              =p_safety_association_rec.ATTRIBUTE18
                      ,ATTRIBUTE19              =p_safety_association_rec.ATTRIBUTE19
                      ,ATTRIBUTE20              =p_safety_association_rec.ATTRIBUTE20
                      ,ATTRIBUTE21              =p_safety_association_rec.ATTRIBUTE21
                      ,ATTRIBUTE22              =p_safety_association_rec.ATTRIBUTE22
                      ,ATTRIBUTE23              =p_safety_association_rec.ATTRIBUTE23
                      ,ATTRIBUTE24              =p_safety_association_rec.ATTRIBUTE24
                      ,ATTRIBUTE25              =p_safety_association_rec.ATTRIBUTE25
                      ,ATTRIBUTE26              =p_safety_association_rec.ATTRIBUTE26
                      ,ATTRIBUTE27              =p_safety_association_rec.ATTRIBUTE27
                      ,ATTRIBUTE28              =p_safety_association_rec.ATTRIBUTE28
                      ,ATTRIBUTE29              =p_safety_association_rec.ATTRIBUTE29
                      ,ATTRIBUTE30              =p_safety_association_rec.ATTRIBUTE30
                      ,LAST_UPDATE_DATE         =SYSDATE
                      ,LAST_UPDATED_BY          =FND_GLOBAL.user_id
                      ,LAST_UPDATE_LOGIN        =FND_GLOBAL.login_id

        WHERE SAFETY_ASSOCIATION_ID=p_safety_association_rec.SAFETY_ASSOCIATION_ID
        AND ASSOCIATION_TYPE=p_safety_association_rec.ASSOCIATION_TYPE;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

END UPDATE_SAFFETY_ASSOCIATION_ROW;




/********************************************************************
* Procedure     : DELETE SAFFETY_ASSOCIATION _ROW
* Purpose       : This will perform delete on the table
*********************************************************************/

PROCEDURE DELETE_SAFFETY_ASSOCIATION_ROW
        		( p_safety_association_rec IN  EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type
              , p_association_type      IN NUMBER
              , x_mesg_token_Tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
              , x_return_Status         OUT NOCOPY VARCHAR2
       		)IS
BEGIN
     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Deleting Safety Association Row'); END IF;

       DELETE FROM EAM_SAFETY_ASSOCIATIONS
       WHERE SAFETY_ASSOCIATION_ID =p_safety_association_rec.SAFETY_ASSOCIATION_ID
       AND ASSOCIATION_TYPE = p_association_type;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
        x_return_status :=  FND_API.G_RET_STS_ERROR;

END DELETE_SAFFETY_ASSOCIATION_ROW;



/********************************************************************
* Procedure     : WRITE  SAFFETY_ASSOCIATION _ROW
* Purpose       : This is the only procedure that the user will have
                  access to when he/she needs to perform any kind of writes to the table.
*********************************************************************/

PROCEDURE WRITE_SAFFETY_ASSOCIATION_ROW
           ( p_safety_association_rec IN  EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type
            , p_association_type      IN NUMBER
            , x_mesg_token_Tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
            , x_return_Status          OUT NOCOPY VARCHAR2
            ) IS

             l_return_status    VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
BEGIN
     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing Safety Association Row'); END IF;

      IF p_safety_association_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                        INSERT_SAFFETY_ASSOCIATION_ROW
                        (  p_safety_association_rec  => p_safety_association_rec
                        , p_association_type         => p_association_type
                         , x_mesg_token_Tbl          => x_mesg_token_Tbl
                         , x_return_Status           => l_return_status
                         );
                ELSIF p_safety_association_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                THEN
                        UPDATE_SAFFETY_ASSOCIATION_ROW
                        ( p_safety_association_rec  => p_safety_association_rec
                        , p_association_type         => p_association_type
                         , x_mesg_token_Tbl          => x_mesg_token_Tbl
                         , x_return_Status           => l_return_status
                         );
                ELSIF p_safety_association_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE
                THEN
                        DELETE_SAFFETY_ASSOCIATION_ROW
                        ( p_safety_association_rec  => p_safety_association_rec
                        , p_association_type         => p_association_type
                         , x_mesg_token_Tbl          => x_mesg_token_Tbl
                         , x_return_Status           => l_return_status
                         );
      END IF;

      x_return_status := l_return_status;

END WRITE_SAFFETY_ASSOCIATION_ROW;

END EAM_SAFETY_UTILITY_PVT;

/
