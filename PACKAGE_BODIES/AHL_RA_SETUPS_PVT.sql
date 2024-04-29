--------------------------------------------------------
--  DDL for Package Body AHL_RA_SETUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RA_SETUPS_PVT" AS
/* $Header: AHLVRASB.pls 120.13 2006/02/16 01:59 sagarwal noship $*/

 G_PKG_NAME      CONSTANT    VARCHAR2(30)    := 'AHL_RA_SETUPS_PVT';
 G_DML_CREATE    CONSTANT    VARCHAR2(1)     := 'C';
 G_DML_UPDATE    CONSTANT    VARCHAR2(1)     := 'U';
 G_DML_DELETE    CONSTANT    VARCHAR2(1)     := 'D';

    --  Start of Comments  --
    --
    --  Procedure name      : CREATE_SETUP_DATA
    --  Type                : Private
    --  Function            : This API would create the setup data for Reliability Framework in AHL_RA_SETUPS table
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  CREATE_SETUP_DATA Parameters :
    --      p_x_setup_data_rec          IN OUT  RA_SETUP_DATA_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE CREATE_SETUP_DATA (
        p_api_version         IN               NUMBER,
        p_init_msg_list       IN               VARCHAR2,
        p_commit              IN               VARCHAR2,
        p_validation_level    IN               NUMBER,
        p_module_type         IN               VARCHAR2,
        x_return_status       OUT      NOCOPY  VARCHAR2,
        x_msg_count           OUT      NOCOPY  NUMBER,
        x_msg_data            OUT      NOCOPY  VARCHAR2,
        p_x_setup_data_rec    IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_SETUP_DATA_REC_TYPE) IS

        l_api_name      CONSTANT    VARCHAR2(30)    := 'CREATE_SETUP_DATA';
        l_api_version   CONSTANT    NUMBER          := 1.0;
        l_full_name     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||g_pkg_name || '.' || l_api_name;

        l_setup_data_rec            AHL_RA_SETUPS_PVT.RA_SETUP_DATA_REC_TYPE DEFAULT p_x_setup_data_rec;
        l_dummy                     VARCHAR2(1);
        l_code                      VARCHAR2(30); -- dummy variable used for token storage.

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT CREATE_SETUP_DATA_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version,p_api_version, l_api_name, G_PKG_NAME) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- CREATE_SETUP_DATA -------BEGIN-----------');
        END IF;

        -- Validate input setup data in p_x_setup_data_rec
        -- Note :: l_setup_data_rec has been defaulted to p_x_setup_data_rec in declaration
        -- A. SETUP_CODE Cannot be NULL
        -- B. SETUP_CODE should be either ITEM_STATUS or REMOVAL_CODE
        -- B. If SETUP_CODE = ITEM_STATUS then STATUS_ID must be passed
        -- C. If SETUP_CODE = REMOVAL_CODE then REMOVAL_CODE must be passed
        -- D. OPERATIONS_FLAG should be C
        IF ((l_setup_data_rec.SETUP_CODE IS NULL) OR
            (l_setup_data_rec.SETUP_CODE NOT IN ('ITEM_STATUS','REMOVAL_CODE')) OR
            (l_setup_data_rec.SETUP_CODE = 'ITEM_STATUS' AND l_setup_data_rec.STATUS_ID IS NULL) OR
            (l_setup_data_rec.SETUP_CODE = 'REMOVAL_CODE' AND l_setup_data_rec.REMOVAL_CODE IS NULL) OR
            ((l_setup_data_rec.OPERATION_FLAG IS NULL) OR (l_setup_data_rec.OPERATION_FLAG <> G_DML_CREATE))) THEN

             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_setup_data_rec.SETUP_CODE -- '||l_setup_data_rec.SETUP_CODE);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_setup_data_rec.STATUS_ID -- '||l_setup_data_rec.STATUS_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_setup_data_rec.REMOVAL_CODE -- '||l_setup_data_rec.REMOVAL_CODE);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_setup_data_rec.OPERATION_FLAG -- '||l_setup_data_rec.OPERATION_FLAG);
             END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_SETUP_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

        -- Check for duplicate Setup Data in AHL_RA_SETUPS
        BEGIN
             SELECT 'X'
               INTO l_dummy
               FROM DUAL
              WHERE EXISTS (SELECT 1
                              FROM AHL_RA_SETUPS
                             WHERE SETUP_CODE = l_setup_data_rec.SETUP_CODE
                               AND nvl(STATUS_ID,'-1') = nvl(DECODE(l_setup_data_rec.SETUP_CODE,'ITEM_STATUS',l_setup_data_rec.STATUS_ID,STATUS_ID),'-1')
                               AND nvl(REMOVAL_CODE,'-1') = nvl(DECODE(l_setup_data_rec.SETUP_CODE,'REMOVAL_CODE',l_setup_data_rec.REMOVAL_CODE,REMOVAL_CODE),'-1'));

             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string(fnd_log.level_statement,l_full_name,'-- Duplicate Data exists -- ERROR ... ');
                 fnd_log.string(fnd_log.level_statement,l_full_name,'-- Fetch Code for Message Token ... ');
             END IF;

             IF l_setup_data_rec.SETUP_CODE = 'ITEM_STATUS' THEN
                 BEGIN
                     SELECT STATUS_CODE
                       INTO l_code
                       FROM MTL_MATERIAL_STATUSES_VL
                      WHERE STATUS_ID = l_setup_data_rec.STATUS_ID;

                     FND_MESSAGE.Set_Name('AHL','AHL_RA_DUP_STATUS_CODE');
                     FND_MESSAGE.Set_Token('ITEM_STATUS',l_code);
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                              fnd_log.string(fnd_log.level_statement,l_full_name,'-- MTL STATUS Data Corruption -- ERROR ... ');
                          END IF;
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END;

             ELSIF l_setup_data_rec.SETUP_CODE = 'REMOVAL_CODE' THEN
                 BEGIN
                     SELECT MEANING
                       INTO l_code
                       FROM FND_LOOKUPS
                      WHERE LOOKUP_TYPE = 'AHL_REMOVAL_CODE'
                        AND LOOKUP_CODE = l_setup_data_rec.REMOVAL_CODE;

                     FND_MESSAGE.Set_Name('AHL','AHL_RA_DUP_REMOVAL_CODE');
                     FND_MESSAGE.Set_Token('REMOVAL_CODE',l_code);
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                              fnd_log.string(fnd_log.level_statement,l_full_name,'-- AHL LOOKUP Data Corruption -- ERROR ... ');
                          END IF;
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END;
             END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string(fnd_log.level_statement,l_full_name,'-- Duplicate Data does not exists -- CONTINUE ... ');
                 END IF;
                 NULL;
        END;

        IF l_setup_data_rec.SETUP_CODE = 'ITEM_STATUS' THEN
           -- Initialise removal_code to NULL .. to avoid any data corruption
           l_setup_data_rec.REMOVAL_CODE := NULL;
           -- Validate l_setup_data_rec.STATUS_ID passed to be a valid value
           BEGIN
                SELECT 'X'
                  INTO l_dummy
                  FROM DUAL
                 WHERE EXISTS (SELECT 1
                                 FROM MTL_MATERIAL_STATUSES_VL
                                WHERE STATUS_ID = l_setup_data_rec.STATUS_ID);

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Valid Status Id Passed. -- CONTINUE ... ' || l_setup_data_rec.STATUS_ID);
                END IF;

           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                         fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Status Id Passed -- ERROR ... ' || l_setup_data_rec.STATUS_ID);
                     END IF;
                     FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
                     FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_SETUP_DATA');
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;

        ELSIF l_setup_data_rec.SETUP_CODE = 'REMOVAL_CODE' THEN

           -- Initialise status_id to NULL .. to avoid any data corruption
           l_setup_data_rec.STATUS_ID := NULL;

           -- Validate l_setup_data_rec.REMOVAL_CODE passed to be a valid value
           BEGIN
                SELECT 'X'
                  INTO l_dummy
                  FROM DUAL
                 WHERE EXISTS (SELECT 1
                                 FROM FND_LOOKUPS
                                WHERE LOOKUP_TYPE = 'AHL_REMOVAL_CODE'
                                  AND LOOKUP_CODE = l_setup_data_rec.REMOVAL_CODE);

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Valid Removal Code Passed. -- CONTINUE ... ' || l_setup_data_rec.REMOVAL_CODE);
                END IF;

           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                         fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Removal Code Passed -- ERROR ... ' || l_setup_data_rec.REMOVAL_CODE);
                     END IF;
                     FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
                     FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_SETUP_DATA');
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;

        END IF;

        -- Initialize RA_SETUP_ID to sequence next val for insert
        SELECT AHL_RA_SETUPS_S.NEXTVAL INTO l_setup_data_rec.RA_SETUP_ID FROM DUAL;

        -- Initialize object version number to 1
        l_setup_data_rec.OBJECT_VERSION_NUMBER := 1;

        -- Intialize who column info
        l_setup_data_rec.LAST_UPDATED_BY := fnd_global.USER_ID;
        l_setup_data_rec.LAST_UPDATE_LOGIN := fnd_global.LOGIN_ID;
        l_setup_data_rec.CREATED_BY := fnd_global.user_id;
        l_setup_data_rec.CREATION_DATE := sysdate;
        l_setup_data_rec.LAST_UPDATE_DATE := sysdate;

        -- Initialize security group id
        l_setup_data_rec.SECURITY_GROUP_ID := null;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Derived ra_setup_id -- ' || l_setup_data_rec.RA_SETUP_ID);
        END IF;

        -- INSERT Setup data in AHL_RA_SETUPS
        INSERT INTO AHL_RA_SETUPS(RA_SETUP_ID,SETUP_CODE,STATUS_ID,REMOVAL_CODE,OBJECT_VERSION_NUMBER,SECURITY_GROUP_ID,
                                  CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,ATTRIBUTE_CATEGORY,
                                  ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,
                                  ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15)
        VALUES(
                 l_setup_data_rec.RA_SETUP_ID          --    RA_SETUP_ID
                ,l_setup_data_rec.SETUP_CODE           --    SETUP_CODE
                ,l_setup_data_rec.STATUS_ID            --    STATUS_ID
                ,l_setup_data_rec.REMOVAL_CODE         --    REMOVAL_CODE
                ,l_setup_data_rec.OBJECT_VERSION_NUMBER--    OBJECT_VERSION_NUMBER
                ,l_setup_data_rec.SECURITY_GROUP_ID    --    SECURITY_GROUP_ID
                ,l_setup_data_rec.CREATION_DATE        --    CREATION_DATE
                ,l_setup_data_rec.CREATED_BY           --    CREATED_BY
                ,l_setup_data_rec.LAST_UPDATE_DATE     --    LAST_UPDATE_DATE
                ,l_setup_data_rec.LAST_UPDATED_BY      --    LAST_UPDATED_BY
                ,l_setup_data_rec.LAST_UPDATE_LOGIN    --    LAST_UPDATE_LOGIN
                ,l_setup_data_rec.ATTRIBUTE_CATEGORY   --    ATTRIBUTE_CATEGORY
                ,l_setup_data_rec.ATTRIBUTE1           --    ATTRIBUTE1
                ,l_setup_data_rec.ATTRIBUTE2           --    ATTRIBUTE2
                ,l_setup_data_rec.ATTRIBUTE3           --    ATTRIBUTE3
                ,l_setup_data_rec.ATTRIBUTE4           --    ATTRIBUTE4
                ,l_setup_data_rec.ATTRIBUTE5           --    ATTRIBUTE5
                ,l_setup_data_rec.ATTRIBUTE6           --    ATTRIBUTE6
                ,l_setup_data_rec.ATTRIBUTE7           --    ATTRIBUTE7
                ,l_setup_data_rec.ATTRIBUTE8           --    ATTRIBUTE8
                ,l_setup_data_rec.ATTRIBUTE9           --    ATTRIBUTE9
                ,l_setup_data_rec.ATTRIBUTE10          --    ATTRIBUTE10
                ,l_setup_data_rec.ATTRIBUTE11          --    ATTRIBUTE11
                ,l_setup_data_rec.ATTRIBUTE12          --    ATTRIBUTE12
                ,l_setup_data_rec.ATTRIBUTE13          --    ATTRIBUTE13
                ,l_setup_data_rec.ATTRIBUTE14          --    ATTRIBUTE14
                ,l_setup_data_rec.ATTRIBUTE15          --    ATTRIBUTE15
        );

        -- Set the Out Param
           p_x_setup_data_rec := l_setup_data_rec;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- CREATE_SETUP_DATA -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','Return Status = ' || x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            ROLLBACK TO CREATE_SETUP_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO CREATE_SETUP_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO CREATE_SETUP_DATA_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'CREATE_SETUP_DATA',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END CREATE_SETUP_DATA;

    --  Start of Comments  --
    --
    --  Procedure name      : DELETE_SETUP_DATA
    --  Type                : Private
    --  Function            : This API would dalete the setup data for Reliability Framework in AHL_RA_SETUPS table
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  DELETE_SETUP_DATA Parameters :
    --       p_setup_data_rec               IN      RA_SETUP_DATA_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE DELETE_SETUP_DATA (
        p_api_version         IN         NUMBER,
        p_init_msg_list       IN         VARCHAR2,
        p_commit              IN         VARCHAR2,
        p_validation_level    IN         NUMBER,
        p_module_type         IN         VARCHAR2,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2,
        p_setup_data_rec      IN         AHL_RA_SETUPS_PVT.RA_SETUP_DATA_REC_TYPE)    IS

        l_api_name      CONSTANT    VARCHAR2(30)    := 'DELETE_SETUP_DATA';
        l_api_version   CONSTANT    NUMBER          := 1.0;
        L_FULL_NAME     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME;

        l_dummy                     VARCHAR2(1);
        l_obj_version_num           AHL_RA_SETUPS.OBJECT_VERSION_NUMBER%TYPE;

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT DELETE_SETUP_DATA_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- DELETE_SETUP_DATA -------BEGIN-----------');
        END IF;


        -- Validate input setup data in p_setup_data_rec
        -- A. p_setup_data_rec.RA_SETUP_ID Cannot be NULL
        -- B. OPERATIONS_FLAG should be D
        -- C. Object Version Number should not be NULL
        IF ((p_setup_data_rec.RA_SETUP_ID IS NULL) OR
            ((p_setup_data_rec.OPERATION_FLAG IS NULL) OR (p_setup_data_rec.OPERATION_FLAG <> G_DML_DELETE)) OR
            (p_setup_data_rec.OBJECT_VERSION_NUMBER IS NULL))THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- RA SETUP ID :' || p_setup_data_rec.RA_SETUP_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- OP FLAG :' || p_setup_data_rec.OPERATION_FLAG);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- OVN :' || p_setup_data_rec.OBJECT_VERSION_NUMBER);
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.D_SETUP_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        BEGIN
            SELECT OBJECT_VERSION_NUMBER
              INTO l_obj_version_num
              FROM AHL_RA_SETUPS
             WHERE RA_SETUP_ID = p_setup_data_rec.RA_SETUP_ID
               FOR UPDATE OF object_version_number NOWAIT;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- OBJECT VERSION NUMBER IN DB : ' || l_obj_version_num);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string(fnd_log.level_statement,l_full_name,'-- DATA DOES NOT EXISTS -- ERROR ... ' || p_setup_data_rec.RA_SETUP_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        -- Validate input setup data in p_setup_data_rec
        -- A. RECORD MUST NOT HAVE CHANGED. i.e. object_version_number should not change.
        -- Note that currently(30/05/2005) UPDATE feature is NOT AVAILABLE to the user from the Self Service pages for RA setup Data.
        -- However this might be taken up later.
        IF p_setup_data_rec.OBJECT_VERSION_NUMBER <> l_obj_version_num THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Record has changed : OVN passed : ' || p_setup_data_rec.OBJECT_VERSION_NUMBER);
           END IF;
           FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Delete Record from AHL_RA_SETUPS
        DELETE AHL_RA_SETUPS
         WHERE RA_SETUP_ID = p_setup_data_rec.RA_SETUP_ID;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- DELETE_SETUP_DATA -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','Return Status = ' || x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            ROLLBACK TO DELETE_SETUP_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO DELETE_SETUP_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO DELETE_SETUP_DATA_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'DELETE_SETUP_DATA',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END DELETE_SETUP_DATA;

    --  Start of Comments  --
    --
    --  Procedure name      : CREATE_RELIABILITY_DATA
    --  Type                : Private
    --  Function            : This API would create the setup data for Reliability Framework in AHL_RA_DEFINITION_HDR
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  CREATE_RELIABILITY_DATA Parameters :
    --      p_x_reliability_data_rec        IN OUT  RA_DEFINITION_HDR_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE CREATE_RELIABILITY_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_reliability_data_rec    IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE)
    IS

        l_api_name          CONSTANT    VARCHAR2(30)    := 'CREATE_RELIABILITY_DATA';
        l_api_version       CONSTANT    NUMBER          := 1.0;
        L_FULL_NAME         CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME;
        l_ra_def_hdr_rec                AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE DEFAULT p_x_reliability_data_rec;
        l_dummy                         VARCHAR2(1);

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT CREATE_RELIABILITY_DATA_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- CREATE_RELIABILITY_DATA -------BEGIN-----------');
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Parameters Passed --');
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_hdr_rec.OPERATION_FLAG -- '||l_ra_def_hdr_rec.OPERATION_FLAG);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_hdr_rec.MC_HEADER_ID -- '||l_ra_def_hdr_rec.MC_HEADER_ID);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_hdr_rec.INVENTORY_ITEM_ID -- '||l_ra_def_hdr_rec.INVENTORY_ITEM_ID);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_hdr_rec.ITEM_REVISION -- '||l_ra_def_hdr_rec.ITEM_REVISION);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_hdr_rec.INVENTORY_ORG_ID -- '||l_ra_def_hdr_rec.INVENTORY_ORG_ID);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_hdr_rec.RELATIONSHIP_ID -- '||l_ra_def_hdr_rec.RELATIONSHIP_ID);
        END IF;

        IF ((l_ra_def_hdr_rec.OPERATION_FLAG IS NULL) OR (l_ra_def_hdr_rec.OPERATION_FLAG <> G_DML_CREATE)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - OP Flag-');
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_COM_INVALID_DML_REC');
            FND_MESSAGE.Set_Token('FIELD',l_ra_def_hdr_rec.OPERATION_FLAG);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Validate input  reliability data in l_ra_def_hdr_rec
        /*
        A. MC_HEADER_ID Cannot be NULL
        B. INVENTORY_ITEM_ID cannot be NULL
        C. INVENTORY_ORG_ID cannot be NULL
        D. RELATIONSHIP_ID cannot be NULL
        */
        IF((l_ra_def_hdr_rec.MC_HEADER_ID IS NULL) OR
           (l_ra_def_hdr_rec.INVENTORY_ITEM_ID IS NULL) OR
           (l_ra_def_hdr_rec.INVENTORY_ORG_ID IS NULL) OR
           (l_ra_def_hdr_rec.RELATIONSHIP_ID IS NULL)) THEN

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
            END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_RA_DEF_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Validate MC_HEADER_ID
        BEGIN
            SELECT 'Y'
              INTO l_dummy
              FROM dual
             WHERE EXISTS( SELECT 'X'
                             FROM ahl_mc_headers_b
                            WHERE mc_header_id = l_ra_def_hdr_rec.MC_HEADER_ID);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation successful: MR_HEADER_ID --');
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation Failed: MR_HEADER_ID --');
            END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_RA_DEF_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        --Validate RELATIONSHIP_ID
        BEGIN
            SELECT 'Y'
              INTO l_dummy
              FROM dual
             WHERE EXISTS(SELECT 'X'
                            FROM ahl_mc_relationships
                           WHERE mc_header_id = l_ra_def_hdr_rec.MC_HEADER_ID
                             AND relationship_id = l_ra_def_hdr_rec.RELATIONSHIP_ID);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation successful: RELATIONSHIP_ID --');
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation Failed: RELATIONSHIP_ID --');
            END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_RA_DEF_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        --Validate INVENTORY_ITEM_ID, INVENTORY_ORG_ID, ITEM_REVISION from AHL_ITEM_ASSOCIATIONS_B
        BEGIN
            SELECT 'Y'
              INTO l_dummy
              FROM dual
             WHERE EXISTS(SELECT 'X'
                            FROM ahl_mc_relationships mcr, ahl_item_associations_b ia
                           WHERE mcr.relationship_id = l_ra_def_hdr_rec.RELATIONSHIP_ID
                             AND mcr.item_group_id = ia.item_group_id
                             AND ia.inventory_item_id = l_ra_def_hdr_rec.INVENTORY_ITEM_ID
                             AND ia.inventory_org_id = l_ra_def_hdr_rec.INVENTORY_ORG_ID
                             AND nvl(ia.revision,FND_API.G_MISS_CHAR) = nvl(l_ra_def_hdr_rec.ITEM_REVISION,FND_API.G_MISS_CHAR));


            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation successful: Item --');
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation Failed: Item --');
            END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_RA_DEF_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        --Uniquness Check for MC_HEADER_ID, RELATIONSHIP_ID, INVENTORY_ITEM_ID, INVENTORY_ORG_ID, ITEM_REVISION
        BEGIN
            SELECT 'Y'
              INTO l_dummy
              FROM dual
             WHERE EXISTS(SELECT 'X'
                            FROM ahl_ra_definition_hdr
                           WHERE mc_header_id = l_ra_def_hdr_rec.MC_HEADER_ID
                             AND relationship_id = l_ra_def_hdr_rec.RELATIONSHIP_ID
                             AND inventory_item_id = l_ra_def_hdr_rec.INVENTORY_ITEM_ID
                             AND inventory_org_id = l_ra_def_hdr_rec.INVENTORY_ORG_ID
                             AND nvl(item_revision,FND_API.G_MISS_CHAR) = nvl(l_ra_def_hdr_rec.ITEM_REVISION,FND_API.G_MISS_CHAR));

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation Failed: Uniqnuess Check --');
            END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_REL_DEF_EXISTS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation successful: Uniqnuess Check --');
            END IF;
        END;

        -- Initialize RA_DEFINITION_HDR_ID to sequence next val for insert
        SELECT AHL_RA_DEFINITION_HDR_S.NEXTVAL into l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID from dual;

        -- Initialize object version number to 1
        l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER := 1;

        -- Intialize who column info
        l_ra_def_hdr_rec.LAST_UPDATED_BY := fnd_global.USER_ID;
        l_ra_def_hdr_rec.LAST_UPDATE_LOGIN := fnd_global.LOGIN_ID;
        l_ra_def_hdr_rec.CREATED_BY := fnd_global.user_id;
        l_ra_def_hdr_rec.CREATION_DATE := sysdate;
        l_ra_def_hdr_rec.LAST_UPDATE_DATE := sysdate;

        -- Initialize security group id
        l_ra_def_hdr_rec.SECURITY_GROUP_ID := null;

        INSERT INTO AHL_RA_DEFINITION_HDR
        (
            RA_DEFINITION_HDR_ID,
            MC_HEADER_ID,
            INVENTORY_ITEM_ID,
            INVENTORY_ORG_ID,
            ITEM_REVISION,
            RELATIONSHIP_ID,
            OBJECT_VERSION_NUMBER,
            SECURITY_GROUP_ID,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
        )
        VALUES
        (
            l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID,      -- RA_DEFINITION_HDR_ID
            l_ra_def_hdr_rec.MC_HEADER_ID,              -- MC_HEADER_ID
            l_ra_def_hdr_rec.INVENTORY_ITEM_ID,         -- INVENTORY_ITEM_ID
            l_ra_def_hdr_rec.INVENTORY_ORG_ID,          -- INVENTORY_ORG_ID
            l_ra_def_hdr_rec.ITEM_REVISION,             -- ITEM_REVISION
            l_ra_def_hdr_rec.RELATIONSHIP_ID,           -- RELATIONSHIP_ID
            l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER,     -- OBJECT_VERSION_NUMBER
            l_ra_def_hdr_rec.SECURITY_GROUP_ID,         -- SECURITY_GROUP_ID
            l_ra_def_hdr_rec.ATTRIBUTE_CATEGORY,        -- ATTRIBUTE_CATEGORY
            l_ra_def_hdr_rec.ATTRIBUTE1,                -- ATTRIBUTE1
            l_ra_def_hdr_rec.ATTRIBUTE2,                -- ATTRIBUTE2
            l_ra_def_hdr_rec.ATTRIBUTE3,                -- ATTRIBUTE3
            l_ra_def_hdr_rec.ATTRIBUTE4,                -- ATTRIBUTE4
            l_ra_def_hdr_rec.ATTRIBUTE5,                -- ATTRIBUTE5
            l_ra_def_hdr_rec.ATTRIBUTE6,                -- ATTRIBUTE6
            l_ra_def_hdr_rec.ATTRIBUTE7,                -- ATTRIBUTE7
            l_ra_def_hdr_rec.ATTRIBUTE8,                -- ATTRIBUTE8
            l_ra_def_hdr_rec.ATTRIBUTE9,                -- ATTRIBUTE9
            l_ra_def_hdr_rec.ATTRIBUTE10,               -- ATTRIBUTE10
            l_ra_def_hdr_rec.ATTRIBUTE11,               -- ATTRIBUTE11
            l_ra_def_hdr_rec.ATTRIBUTE12,               -- ATTRIBUTE12
            l_ra_def_hdr_rec.ATTRIBUTE13,               -- ATTRIBUTE13
            l_ra_def_hdr_rec.ATTRIBUTE14,               -- ATTRIBUTE14
            l_ra_def_hdr_rec.ATTRIBUTE15,               -- ATTRIBUTE15
            l_ra_def_hdr_rec.CREATION_DATE,             -- CREATION_DATE
            l_ra_def_hdr_rec.CREATED_BY,                -- CREATED_BY
            l_ra_def_hdr_rec.LAST_UPDATE_DATE,          -- LAST_UPDATE_DATE
            l_ra_def_hdr_rec.LAST_UPDATED_BY,           -- LAST_UPDATED_BY
            l_ra_def_hdr_rec.LAST_UPDATE_LOGIN          -- LAST_UPDATE_LOGIN
        );

        p_x_reliability_data_rec := l_ra_def_hdr_rec;
        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- CREATE_RELIABILITY_DATA -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','Return Status = ' || x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            ROLLBACK TO CREATE_RELIABILITY_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO CREATE_RELIABILITY_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO CREATE_RELIABILITY_DATA_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'CREATE_RELIABILITY_DATA',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END CREATE_RELIABILITY_DATA;

    --  Start of Comments  --
    --
    --  Procedure name      : DELETE_RELIABILITY_DATA
    --  Type                : Private
    --  Function            : This API would delete the setup data for Reliability Framework in AHL_RA_DEFINITION_HDR
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  DELETE_RELIABILITY_DATA Parameters :
    --      p_reliability_data_rec        IN OUT  RA_DEFINITION_HDR_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE DELETE_RELIABILITY_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2,
        p_commit                    IN               VARCHAR2,
        p_validation_level          IN               NUMBER,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_reliability_data_rec      IN               AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE)    IS

        l_api_name      CONSTANT    VARCHAR2(30)    := 'DELETE_RELIABILITY_DATA';
        l_api_version   CONSTANT    NUMBER          := 1.0;
        L_FULL_NAME     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME;

        l_obj_version_num               AHL_RA_DEFINITION_HDR.OBJECT_VERSION_NUMBER%TYPE;

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT DELETE_RELIABILITY_DATA_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- DELETE_RELIABILITY_DATA -------BEGIN-----------');
        END IF;

        IF ((p_reliability_data_rec.OPERATION_FLAG IS NULL) OR (p_reliability_data_rec.OPERATION_FLAG <> G_DML_DELETE)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_COM_INVALID_DML_REC');
            FND_MESSAGE.Set_Token('FIELD', p_reliability_data_rec.OPERATION_FLAG);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Validate input data in p_reliability_data_rec
        -- A. p_reliability_data_rec. RA_DEFINITION_HDR_ID Cannot be NULL
        -- C. Object Version Number should not be NULL
        IF ((p_reliability_data_rec.RA_DEFINITION_HDR_ID IS NULL) OR
            (p_reliability_data_rec.OBJECT_VERSION_NUMBER IS NULL)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- RA_DEFINITION_HDR_ID :' || p_reliability_data_rec.RA_DEFINITION_HDR_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- OVN :' || p_reliability_data_rec.OBJECT_VERSION_NUMBER);
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.D_RA_DEF_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Delete counter-MTBF records for RA_DEFINITION_HDR_ID -- ' || p_reliability_data_rec.RA_DEFINITION_HDR_ID);
        END IF;

        -- Check for existence of record and fetch OVN for change record validation
        BEGIN
            SELECT OBJECT_VERSION_NUMBER
              INTO l_obj_version_num
              FROM AHL_RA_DEFINITION_HDR
             WHERE RA_DEFINITION_HDR_ID = p_reliability_data_rec.RA_DEFINITION_HDR_ID
               FOR UPDATE OF object_version_number NOWAIT;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- OBJECT VERSION NUMBER IN DB : ' || l_obj_version_num);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string(fnd_log.level_statement,l_full_name,'-- DATA DOES NOT EXISTS -- ERROR ... ' || p_reliability_data_rec.RA_DEFINITION_HDR_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        -- Validate input data in p_reliability_data_rec
        -- A. RECORD SHOULD NOT HAVE CHANGED. i.e. object_version_number should not change.
        -- Child Locking Check is implemented for Setup Data - When Child Is edited/inserted/deleted OVN of Master is bumped up
        IF l_obj_version_num <> p_reliability_data_rec.OBJECT_VERSION_NUMBER THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Record has changed : OVN passed : ' || p_reliability_data_rec.OBJECT_VERSION_NUMBER);
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Record has changed : OVN in db : ' || l_obj_version_num);
           END IF;
           FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Delete the child records before deleting the master record.
        DELETE AHL_RA_DEFINITION_DTLS
        WHERE RA_DEFINITION_HDR_ID = p_reliability_data_rec.RA_DEFINITION_HDR_ID;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Child Records have been deleted --');
        END IF;

        --Delete the master record.
        DELETE AHL_RA_DEFINITION_HDR
         WHERE RA_DEFINITION_HDR_ID = p_reliability_data_rec.RA_DEFINITION_HDR_ID;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Master Record has been deleted --');
        END IF;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
           COMMIT;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- DELETE_RELIABILITY_DATA -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','Return Status = ' || x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            ROLLBACK TO DELETE_RELIABILITY_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO DELETE_RELIABILITY_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO DELETE_RELIABILITY_DATA_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'DELETE_RELIABILITY_DATA',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END DELETE_RELIABILITY_DATA;


    --  Start of Comments  --
    --
    --  Procedure name      : CREATE_MTBF_DATA
    --  Type                : Private
    --  Function            : This API would create the setup data for Reliability Framework in AHL_RA_DEFINITION_DTLS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  CREATE_MTBF_DATA Parameters :
    --      p_x_mtbf_data_rec               IN OUT  RA_DEFINITION_DTLS_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE CREATE_MTBF_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2,
        p_commit                    IN               VARCHAR2,
        p_validation_level          IN               NUMBER,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_reliability_data_rec    IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE,
        p_x_mtbf_data_rec           IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_DTLS_REC_TYPE)    IS

        l_api_name      CONSTANT    VARCHAR2(30)    := 'CREATE_MTBF_DATA';
        l_api_version   CONSTANT    NUMBER          := 1.0;
        L_FULL_NAME     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME;

        l_ra_def_hdr_rec            AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE DEFAULT p_x_reliability_data_rec;
        l_ra_def_dtl_rec            AHL_RA_SETUPS_PVT.RA_DEFINITION_DTLS_REC_TYPE DEFAULT p_x_mtbf_data_rec;
        l_m_obj_version_num         AHL_RA_DEFINITION_HDR.OBJECT_VERSION_NUMBER%TYPE;
        l_cou_name                  CSI_COUNTER_TEMPLATE_VL.NAME%TYPE;
        l_dummy                     VARCHAR2(1);

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT CREATE_MTBF_DATA_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- CREATE_MTBF_DATA -------BEGIN-----------');
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Parameters Passed --');
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID -- '||l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_dtl_rec.COUNTER_ID -- '||l_ra_def_dtl_rec.COUNTER_ID);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_dtl_rec.MTBF_VALUE -- '||l_ra_def_dtl_rec.MTBF_VALUE);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_dtl_rec.OPERATION_FLAG -- '||l_ra_def_dtl_rec.OPERATION_FLAG);
        END IF;

        IF ((l_ra_def_dtl_rec.OPERATION_FLAG IS NULL) OR (l_ra_def_dtl_rec.OPERATION_FLAG <> G_DML_CREATE)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_COM_INVALID_DML_REC');
            FND_MESSAGE.Set_Token('FIELD',l_ra_def_dtl_rec.OPERATION_FLAG);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Mandatory validations for CounterId and RA_DEFINITION_HDR_ID
        IF ((l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID IS NULL AND l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID IS NULL) OR
            (l_ra_def_dtl_rec.COUNTER_ID IS NULL) OR
            (l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER IS NULL)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - RA_DEFINITION_HDR_ID -'||l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - COUNTER_ID -'||l_ra_def_dtl_rec.COUNTER_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - RA_DEFINITION_HDR_ID -'||l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - OBJECT_VERSION_NUMBER -'||l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER);
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_RA_DEF_DTL_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF ((l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID IS NOT NULL AND l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID IS NOT NULL) AND
            (l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID <> l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - RA_DEFINITION_HDR_ID MASTER-'||l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - RA_DEFINITION_HDR_ID CHILD-'||l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID);
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_RA_DEF_DTL_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Default RA_DEFINITION_HDR_ID in child rec from header rec and vice-versa- if passed as null. -- ');
        END IF;

        -- Default RA_DEFINITION_HDR_ID in child rec from header rec - if passed as null.
        IF l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID IS NULL THEN
           l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID := l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID;
        ELSE
           l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID := l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID;
        END IF;

        --Validate CounterId passed
        BEGIN
            -- Bug 4913954 : Perf Fixes.
            -- Since we are using reference to cs_counter_groups with a join condition TEMPLATE_FLAG = 'Y'
            -- i.e only counter templates, direct reference to cs_csi_counter_groups can be used here.
            SELECT templates.name
              INTO l_cou_name
              FROM cs_csi_counter_groups cg,
                   csi_counter_template_vl templates,
                   csi_ctr_item_associations csia,
                   ahl_ra_definition_hdr rdh
             WHERE templates.counter_id = l_ra_def_dtl_rec.COUNTER_ID
               AND cg.template_flag = 'Y'
               AND templates.group_id = cg.counter_group_id
               AND csia.group_id = cg.counter_group_id
               AND csia.inventory_item_id = rdh.inventory_item_id
               --Added the following on 13-sep-2005 after the feedback from csi team
               AND nvl(csia.associated_to_group,'N') = 'Y'
               AND csia.counter_id is null
               --mpothuku end
               AND rdh.RA_DEFINITION_HDR_ID = l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID
               AND trunc(sysdate) < trunc(nvl(templates.end_date_active,sysdate+1))
               AND trunc(sysdate) < trunc(nvl(csia.end_date_active,sysdate+1));
                   --Did not add the start date check above as this is setup and we might want to
                   --define associations for counters that might get activated in future.

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- COUNTER_ID Validated Successfully--');
            END IF;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - COUNTER_ID -' || l_ra_def_dtl_rec.COUNTER_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
                 FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_RA_DEF_DTL_DATA');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        --MTBF should be >= 0 if not null
        IF(l_ra_def_dtl_rec.MTBF_VALUE IS NOT NULL and  l_ra_def_dtl_rec.MTBF_VALUE < 0) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - MTBF_VALUE -'||l_ra_def_dtl_rec.MTBF_VALUE);
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_RA_MTBF_INV');
            FND_MESSAGE.Set_Token('COUNTER',l_cou_name);
            FND_MESSAGE.Set_Token('MTBF', l_ra_def_dtl_rec.MTBF_VALUE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Uniqueness Check for the counterId
        BEGIN
            SELECT 'Y'
              INTO l_dummy
              FROM dual
             WHERE EXISTS(SELECT 'X'
                            FROM AHL_RA_DEFINITION_DTLS
                           WHERE COUNTER_ID = l_ra_def_dtl_rec.COUNTER_ID
                             AND RA_DEFINITION_HDR_ID = l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Duplicate exists  - COUNTER_ID -' || l_ra_def_dtl_rec.COUNTER_ID);
            END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_REL_DTL_EXISTS');
            FND_MESSAGE.Set_Token('COUNTER',l_cou_name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Duplicate does not exist-- COUNTER_ID Validated Successfully--');
                END IF;
        END;

        -- Check for existence of record and fetch OVN of Master Rec for change record validation and bump up
        BEGIN
            SELECT OBJECT_VERSION_NUMBER
              INTO l_m_obj_version_num
              FROM AHL_RA_DEFINITION_HDR
             WHERE RA_DEFINITION_HDR_ID = l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID
               FOR UPDATE OF object_version_number NOWAIT;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- OBJECT VERSION NUMBER IN DB OF MASTER: ' || l_m_obj_version_num);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string(fnd_log.level_statement,l_full_name,'-- DATA DOES NOT EXISTS -- ERROR ... ' || l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
                 FND_MSG_PUB.ADD;
                 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        -- Validate input data in p_x_reliability_data_rec
        -- A. RECORD SHOULD NOT HAVE CHANGED. i.e. object_version_number should not change.
        -- Child Locking Check is implemented for Setup Data - When Child Is edited/inserted/deleted OVN of Master is bumped up
        IF l_m_obj_version_num <> l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Record has changed : OVN passed : ' || l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER);
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Record has changed : OVN in db : ' || l_m_obj_version_num);
           END IF;
           FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize RA_DEFINITION_DTL_ID to sequence next val for insert
        SELECT AHL_RA_DEFINITION_DTLS_S.NEXTVAL into l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID from dual;

        -- Initialize object version number to 1
        l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER := 1;

        -- Intialize who column info
        l_ra_def_dtl_rec.LAST_UPDATED_BY := fnd_global.USER_ID;
        l_ra_def_dtl_rec.LAST_UPDATE_LOGIN := fnd_global.LOGIN_ID;
        l_ra_def_dtl_rec.CREATED_BY := fnd_global.user_id;
        l_ra_def_dtl_rec.CREATION_DATE := sysdate;
        l_ra_def_dtl_rec.LAST_UPDATE_DATE := sysdate;

        -- Initialize security group id
        l_ra_def_dtl_rec.SECURITY_GROUP_ID := null;

        --Insert the record into AHL_RA_DEFINITION_DTLS
        INSERT INTO AHL_RA_DEFINITION_DTLS
        (
            RA_DEFINITION_DTL_ID,
            RA_DEFINITION_HDR_ID,
            COUNTER_ID,
            MTBF_VALUE,
            OBJECT_VERSION_NUMBER,
            SECURITY_GROUP_ID,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
        )
        VALUES
        (
            l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID,
            l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID,
            l_ra_def_dtl_rec.COUNTER_ID,
            l_ra_def_dtl_rec.MTBF_VALUE,
            l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER,
            l_ra_def_dtl_rec.SECURITY_GROUP_ID,
            l_ra_def_dtl_rec.ATTRIBUTE_CATEGORY,
            l_ra_def_dtl_rec.ATTRIBUTE1,
            l_ra_def_dtl_rec.ATTRIBUTE2,
            l_ra_def_dtl_rec.ATTRIBUTE3,
            l_ra_def_dtl_rec.ATTRIBUTE4,
            l_ra_def_dtl_rec.ATTRIBUTE5,
            l_ra_def_dtl_rec.ATTRIBUTE6,
            l_ra_def_dtl_rec.ATTRIBUTE7,
            l_ra_def_dtl_rec.ATTRIBUTE8,
            l_ra_def_dtl_rec.ATTRIBUTE9,
            l_ra_def_dtl_rec.ATTRIBUTE10,
            l_ra_def_dtl_rec.ATTRIBUTE11,
            l_ra_def_dtl_rec.ATTRIBUTE12,
            l_ra_def_dtl_rec.ATTRIBUTE13,
            l_ra_def_dtl_rec.ATTRIBUTE14,
            l_ra_def_dtl_rec.ATTRIBUTE15,
            l_ra_def_dtl_rec.CREATION_DATE,
            l_ra_def_dtl_rec.CREATED_BY,
            l_ra_def_dtl_rec.LAST_UPDATE_DATE,
            l_ra_def_dtl_rec.LAST_UPDATED_BY,
            l_ra_def_dtl_rec.LAST_UPDATE_LOGIN
        );

        p_x_mtbf_data_rec := l_ra_def_dtl_rec;

        l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER := l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER + 1;

        -- Update Object Version Number of Master Record are Inserting child record.
        UPDATE AHL_RA_DEFINITION_HDR
        SET OBJECT_VERSION_NUMBER = l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER
        WHERE RA_DEFINITION_HDR_ID = l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID;

        p_x_reliability_data_rec := l_ra_def_hdr_rec;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- CREATE_MTBF_DATA -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','At the start of PLSQL procedure');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            ROLLBACK TO CREATE_MTBF_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO CREATE_MTBF_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO CREATE_MTBF_DATA_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'CREATE_MTBF_DATA',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END CREATE_MTBF_DATA;


    --  Start of Comments  --
    --
    --  Procedure name      : UPDATE_MTBF_DATA
    --  Type                : Private
    --  Function            : This API would update the setup data for Reliability Framework in AHL_RA_DEFINITION_DTLS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  UPDATE_MTBF_DATA Parameters :
    --      p_x_mtbf_data_rec                 IN OUT  RA_DEFINITION_DTLS_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE UPDATE_MTBF_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_reliability_data_rec    IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE,
        p_x_mtbf_data_rec           IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_DTLS_REC_TYPE)    IS

    CURSOR get_mtbf_data_cur(p_ra_definition_dtl_id IN NUMBER) IS
        SELECT RA_DEFINITION_DTL_ID,
               RA_DEFINITION_HDR_ID,
               COUNTER_ID,
               MTBF_VALUE,
               OBJECT_VERSION_NUMBER
          FROM AHL_RA_DEFINITION_DTLS
         WHERE RA_DEFINITION_DTL_ID = p_ra_definition_dtl_id
           FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    l_api_name      CONSTANT    VARCHAR2(30)    := 'UPDATE_MTBF_DATA';
    l_api_version   CONSTANT    NUMBER          := 1.0;
    L_FULL_NAME     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME || ' : ';
    l_mtbf_data_old_rec         get_mtbf_data_cur%ROWTYPE;
    l_ra_def_dtl_rec            AHL_RA_SETUPS_PVT.RA_DEFINITION_DTLS_REC_TYPE DEFAULT p_x_mtbf_data_rec;
    l_ra_def_hdr_rec            AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE DEFAULT p_x_reliability_data_rec;
    l_m_obj_version_num         AHL_RA_DEFINITION_HDR.OBJECT_VERSION_NUMBER%TYPE;
    l_cou_name                  CSI_COUNTER_TEMPLATE_VL.NAME%TYPE;

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT UPDATE_MTBF_DATA_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- UPDATE_MTBF_DATA -------BEGIN-----------');
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Parameters Passed --');
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID -- '||l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID -- '||l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_dtl_rec.COUNTER_ID -- '||l_ra_def_dtl_rec.COUNTER_ID);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_dtl_rec.MTBF_VALUE -- '||l_ra_def_dtl_rec.MTBF_VALUE);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_ra_def_dtl_rec.OPERATION_FLAG -- '||l_ra_def_dtl_rec.OPERATION_FLAG);
        END IF;

        IF ((l_ra_def_dtl_rec.OPERATION_FLAG IS NULL) OR (l_ra_def_dtl_rec.OPERATION_FLAG <> G_DML_UPDATE)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
            FND_MESSAGE.Set_Name('AHL','AHL_COM_INVALID_DML_REC');
            FND_MESSAGE.Set_Token('FIELD',l_ra_def_dtl_rec.OPERATION_FLAG);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        --RA_DEFINITION_DTL_ID and OBJECT_VERSION_NUMBER are mandatory
        IF( l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID IS NULL OR
            l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID = FND_API.G_MISS_NUM OR
            l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER IS NULL OR
            l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM OR
            l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID = FND_API.G_MISS_NUM OR
            l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID = FND_API.G_MISS_NUM OR
            (l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID IS NULL AND l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID IS NULL)) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.U_RA_DEF_DTL_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Check that both the HDR_ID is same in both the master and child records.
        IF ((l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID IS NOT NULL AND l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID IS NOT NULL) AND
            (l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID <> l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - RA_DEFINITION_HDR_ID MASTER-'||l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - RA_DEFINITION_HDR_ID CHILD-'||l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID);
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.U_RA_DEF_DTL_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Default RA_DEFINITION_HDR_ID in child rec from header rec and vice-versa- if passed as null. -- ');
        END IF;

        -- Default RA_DEFINITION_HDR_ID in child rec from header rec - if passed as null.
        IF l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID IS NULL THEN
           l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID := l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID;
        ELSE
           l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID := l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID;
        END IF;


        --get current mtbf record
        OPEN get_mtbf_data_cur(l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID);
        FETCH get_mtbf_data_cur INTO l_mtbf_data_old_rec;
        IF(get_mtbf_data_cur%NOTFOUND) THEN
            CLOSE get_mtbf_data_cur;
            FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE get_mtbf_data_cur;

        IF(l_mtbf_data_old_rec.OBJECT_VERSION_NUMBER <> l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER) THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Record has changed : OVN passed : ' || l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER);
           END IF;
           FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Default missing and unchanged attributes.
        IF (p_module_type <> 'OAF') THEN

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement, l_full_name, 'default_unchanged_attributes for update operation. Module type is '||p_module_type);
            END IF;

            -- Default RA_DEFINITION_HDR_ID
            /* RA_DEFINITION_HDR_ID cannot be defaulted to null as it is the forigen key reference hence cannot be passed as G_MISS_NUM */

            IF (l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID IS NULL) THEN
                l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID := l_mtbf_data_old_rec.RA_DEFINITION_HDR_ID;
            END IF;

            -- Default COUNTER_ID
            IF (l_ra_def_dtl_rec.COUNTER_ID IS NULL) THEN
                l_ra_def_dtl_rec.COUNTER_ID := l_mtbf_data_old_rec.COUNTER_ID;
            ELSIF l_ra_def_dtl_rec.COUNTER_ID = FND_API.G_MISS_NUM THEN
                l_ra_def_dtl_rec.COUNTER_ID := NULL;
            END IF;

            -- Default MTBF_VALUE
            IF (l_ra_def_dtl_rec.MTBF_VALUE IS NULL) THEN
                l_ra_def_dtl_rec.MTBF_VALUE := l_mtbf_data_old_rec.MTBF_VALUE;
            ELSIF l_ra_def_dtl_rec.MTBF_VALUE = FND_API.G_MISS_NUM THEN
                l_ra_def_dtl_rec.MTBF_VALUE := NULL;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement, l_full_name, 'defaulting completed successfully');
            END IF;

        END IF; --( p_module_type <> 'OAF' )

        --Validate CounterId passed
        BEGIN
            -- Bug 4913954 : Perf Fixes.
            -- Since we are using reference to cs_counter_groups with a join condition TEMPLATE_FLAG = 'Y'
            -- i.e only counter templates, direct reference to cs_csi_counter_groups can be used here.
            SELECT templates.name
              INTO l_cou_name
              FROM cs_csi_counter_groups cg,
                   csi_counter_template_vl templates,
                   csi_ctr_item_associations csia,
                   ahl_ra_definition_hdr rdh
             WHERE templates.counter_id = l_ra_def_dtl_rec.COUNTER_ID
               AND cg.template_flag = 'Y'
               AND templates.group_id = cg.counter_group_id
               AND csia.group_id = cg.counter_group_id
               AND csia.inventory_item_id = rdh.inventory_item_id
               --Added the following on 13-sep-2005 after the feedback from csi team
               AND nvl(csia.associated_to_group,'N') = 'Y'
               AND csia.counter_id is null
               --mpothuku end
               AND rdh.RA_DEFINITION_HDR_ID = l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID
               AND trunc(sysdate) < trunc(nvl(templates.end_date_active,sysdate+1))
               AND trunc(sysdate) < trunc(nvl(csia.end_date_active,sysdate+1));
                   --Did not add the start date check above as this is setup and we might want to
                   --define associations for counters that might get activated in future.

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- COUNTER_ID Validated Successfully--');
            END IF;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - COUNTER_ID -' || l_ra_def_dtl_rec.COUNTER_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
                 FND_MESSAGE.Set_Token('NAME','SETUP_PVT.U_RA_DEF_DTL_DATA');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        --MTBF should be >= 0 if not null
        IF(l_ra_def_dtl_rec.MTBF_VALUE IS NOT NULL AND  l_ra_def_dtl_rec.MTBF_VALUE < 0) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_RA_MTBF_INV');
            FND_MESSAGE.Set_Token('COUNTER',l_cou_name);
            FND_MESSAGE.Set_Token('MTBF', l_ra_def_dtl_rec.MTBF_VALUE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Check for existence of record and fetch OVN of Master Rec for change record validation and bump up
        BEGIN
            SELECT OBJECT_VERSION_NUMBER
              INTO l_m_obj_version_num
              FROM AHL_RA_DEFINITION_HDR
             WHERE RA_DEFINITION_HDR_ID = l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID
               FOR UPDATE OF object_version_number NOWAIT;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- OBJECT VERSION NUMBER IN DB OF MASTER: ' || l_m_obj_version_num);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string(fnd_log.level_statement,l_full_name,'-- Master DATA DOES NOT EXISTS -- ERROR ... ' || l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        -- Validate input data in p_x_reliability_data_rec
        -- A. RECORD SHOULD NOT HAVE CHANGED. i.e. object_version_number should not change.
        -- Child Locking Check is implemented for Setup Data - When Child Is edited/inserted/deleted OVN of Master is bumped up
        IF l_m_obj_version_num <> l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Master Record has changed : OVN passed : ' || l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER);
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Master Record has changed : OVN in db : ' || l_m_obj_version_num);
           END IF;
           FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
           Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Increment object version number
        l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER := l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER + 1;

        -- Intialize who column info
        l_ra_def_dtl_rec.LAST_UPDATED_BY := fnd_global.USER_ID;
        l_ra_def_dtl_rec.LAST_UPDATE_LOGIN := fnd_global.LOGIN_ID;
        l_ra_def_dtl_rec.LAST_UPDATE_DATE := sysdate;
        l_ra_def_dtl_rec.CREATED_BY := fnd_global.user_id;
        l_ra_def_dtl_rec.CREATION_DATE := sysdate;

        UPDATE AHL_RA_DEFINITION_DTLS
        SET
            RA_DEFINITION_HDR_ID    = l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID,
            COUNTER_ID              = l_ra_def_dtl_rec.COUNTER_ID,
            MTBF_VALUE              = l_ra_def_dtl_rec.MTBF_VALUE,
            OBJECT_VERSION_NUMBER   = l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER,
            SECURITY_GROUP_ID       = l_ra_def_dtl_rec.SECURITY_GROUP_ID,
            ATTRIBUTE_CATEGORY      = l_ra_def_dtl_rec.ATTRIBUTE_CATEGORY,
            ATTRIBUTE1              = l_ra_def_dtl_rec.ATTRIBUTE1,
            ATTRIBUTE2              = l_ra_def_dtl_rec.ATTRIBUTE2,
            ATTRIBUTE3              = l_ra_def_dtl_rec.ATTRIBUTE3,
            ATTRIBUTE4              = l_ra_def_dtl_rec.ATTRIBUTE4,
            ATTRIBUTE5              = l_ra_def_dtl_rec.ATTRIBUTE5,
            ATTRIBUTE6              = l_ra_def_dtl_rec.ATTRIBUTE6,
            ATTRIBUTE7              = l_ra_def_dtl_rec.ATTRIBUTE7,
            ATTRIBUTE8              = l_ra_def_dtl_rec.ATTRIBUTE8,
            ATTRIBUTE9              = l_ra_def_dtl_rec.ATTRIBUTE9,
            ATTRIBUTE10             = l_ra_def_dtl_rec.ATTRIBUTE10,
            ATTRIBUTE11             = l_ra_def_dtl_rec.ATTRIBUTE11,
            ATTRIBUTE12             = l_ra_def_dtl_rec.ATTRIBUTE12,
            ATTRIBUTE13             = l_ra_def_dtl_rec.ATTRIBUTE13,
            ATTRIBUTE14             = l_ra_def_dtl_rec.ATTRIBUTE14,
            ATTRIBUTE15             = l_ra_def_dtl_rec.ATTRIBUTE15,
            CREATION_DATE           = l_ra_def_dtl_rec.CREATION_DATE,
            CREATED_BY              = l_ra_def_dtl_rec.CREATED_BY,
            LAST_UPDATE_DATE        = l_ra_def_dtl_rec.LAST_UPDATE_DATE,
            LAST_UPDATED_BY         = l_ra_def_dtl_rec.LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN       = l_ra_def_dtl_rec.LAST_UPDATE_LOGIN
            WHERE
            RA_DEFINITION_DTL_ID    = l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID;

        -- Set the Out Param
        p_x_mtbf_data_rec := l_ra_def_dtl_rec;

        l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER := l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER + 1;

        -- Update Object Version Number of Master Record are Inserting child record.
        UPDATE AHL_RA_DEFINITION_HDR
        SET OBJECT_VERSION_NUMBER = l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER
        WHERE RA_DEFINITION_HDR_ID = l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID;

        p_x_reliability_data_rec := l_ra_def_hdr_rec;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- UPDATE_MTBF_DATA -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','Return Status = ' || x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to UPDATE_MTBF_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to UPDATE_MTBF_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to UPDATE_MTBF_DATA_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'UPDATE_MTBF_DATA',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END UPDATE_MTBF_DATA;


    --  Start of Comments  --
    --
    --  Procedure name      : DELETE_MTBF_DATA
    --  Type                : Private
    --  Function            : This API would delete the setup data for Reliability Framework in AHL_RA_DEFINITION_DTLS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  DELETE_MTBF_DATA Parameters :
    --      p_mtbf_data_rec                IN OUT  RA_DEFINITION_DTLS_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE DELETE_MTBF_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_reliability_data_rec    IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE,
        p_mtbf_data_rec             IN               AHL_RA_SETUPS_PVT.RA_DEFINITION_DTLS_REC_TYPE)    IS

        l_api_name      CONSTANT    VARCHAR2(30)    := 'DELETE_MTBF_DATA';
        l_api_version   CONSTANT    NUMBER          := 1.0;
        L_FULL_NAME     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME;

        l_obj_version_num           AHL_RA_CTR_ASSOCIATIONS.OBJECT_VERSION_NUMBER%TYPE;
        l_ra_def_hdr_rec            AHL_RA_SETUPS_PVT.RA_DEFINITION_HDR_REC_TYPE DEFAULT p_x_reliability_data_rec;
        l_ra_def_dtl_rec            AHL_RA_SETUPS_PVT.RA_DEFINITION_DTLS_REC_TYPE DEFAULT p_mtbf_data_rec;
        l_m_obj_version_num         AHL_RA_DEFINITION_HDR.OBJECT_VERSION_NUMBER%TYPE;

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT DELETE_MTBF_DATA_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- DELETE_MTBF_DATA -------BEGIN-----------');
        END IF;

        --Validate the Operation Flag
        IF ((l_ra_def_dtl_rec.OPERATION_FLAG IS NULL) OR (l_ra_def_dtl_rec.OPERATION_FLAG <> G_DML_DELETE)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
            FND_MESSAGE.Set_Name('AHL','AHL_COM_INVALID_DML_REC');
            FND_MESSAGE.Set_Token('FIELD',l_ra_def_dtl_rec.OPERATION_FLAG);
            FND_MSG_PUB.ADD;
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        -- Validate input data in l_ra_def_dtl_rec
        -- A. l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID Cannot be NULL
        -- C. Object Version Number should not be NULL
        IF ((l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID IS NULL) OR
            (l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER IS NULL) OR
            (l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID is null AND l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID is null))THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- RA_DEFINITION_DTL_ID :' || l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- OVN :' || l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- Master RA_DEFINITION_HDR_ID :' || l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- Detail RA_DEFINITION_HDR_ID:' || l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID);
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.D_RA_DEF_DET_DATA');
            FND_MSG_PUB.ADD;
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Check that both the HDR_ID is same in both the master and child records.
        IF ((l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID is not null AND l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID IS NOT NULL) AND
            (l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID <> l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - RA_DEFINITION_HDR_ID MASTER-'||l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - RA_DEFINITION_HDR_ID CHILD-'||l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID);
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.D_RA_DEF_DTL_DATA');
            FND_MSG_PUB.ADD;
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Default RA_DEFINITION_HDR_ID in child rec from header rec and vice-versa- if passed as null. -- ');
        END IF;

        -- Default RA_DEFINITION_HDR_ID in child rec from header rec - if passed as null.
        IF l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID IS NULL THEN
           l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID := l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID;
        ELSE
           l_ra_def_hdr_rec.RA_DEFINITION_HDR_ID := l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID;
        END IF;

        -- Check for existence of record and fetch OVN for change record validation
        BEGIN
            SELECT OBJECT_VERSION_NUMBER
              INTO l_obj_version_num
              FROM AHL_RA_DEFINITION_DTLS
             WHERE RA_DEFINITION_DTL_ID = l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID
               FOR UPDATE OF object_version_number NOWAIT;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- OBJECT VERSION NUMBER IN DB : ' || l_obj_version_num);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string(fnd_log.level_statement,l_full_name,'-- DATA DOES NOT EXISTS -- ERROR ... ' || l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
                 FND_MSG_PUB.ADD;
                 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        -- Validate input data in l_ra_def_dtl_rec
        -- A. RECORD MUST NOT HAVE CHANGED. i.e. object_version_number should not change.
        IF l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER <> l_obj_version_num THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Record has changed : OVN passed : ' || l_ra_def_dtl_rec.OBJECT_VERSION_NUMBER);
           END IF;
           FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
           Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Check for existence of record and fetch OVN of Master Rec for change record validation and bump up
        BEGIN
            SELECT OBJECT_VERSION_NUMBER
              INTO l_m_obj_version_num
              FROM AHL_RA_DEFINITION_HDR
             WHERE RA_DEFINITION_HDR_ID = l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID
               FOR UPDATE OF object_version_number nowait;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- OBJECT VERSION NUMBER IN DB OF MASTER: ' || l_m_obj_version_num);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string(fnd_log.level_statement,l_full_name,'-- Master DATA DOES NOT EXISTS -- ERROR ... ' || l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
                 FND_MSG_PUB.ADD;
                 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        -- Validate input data in p_x_reliability_data_rec
        -- A. RECORD SHOULD NOT HAVE CHANGED. i.e. object_version_number should not change.
        -- Child Locking Check is implemented for Setup Data - When Child Is edited/inserted/deleted OVN of Master is bumped up
        IF l_m_obj_version_num <> l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Master Record has changed : OVN passed : ' || l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER);
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Master Record has changed : OVN in db : ' || l_m_obj_version_num);
           END IF;
           FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
           Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Delete Record from AHL_RA_DEFINITION_DTLS
        DELETE AHL_RA_DEFINITION_DTLS
        WHERE RA_DEFINITION_DTL_ID = l_ra_def_dtl_rec.RA_DEFINITION_DTL_ID;

        l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER := l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER + 1;

        -- Update Object Version Number of Master Record are Inserting child record.
        UPDATE AHL_RA_DEFINITION_HDR
        SET OBJECT_VERSION_NUMBER = l_ra_def_hdr_rec.OBJECT_VERSION_NUMBER
        WHERE RA_DEFINITION_HDR_ID = l_ra_def_dtl_rec.RA_DEFINITION_HDR_ID;

        p_x_reliability_data_rec := l_ra_def_hdr_rec;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;

       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- DELETE_MTBF_DATA -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','Return Status = ' || x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to DELETE_MTBF_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to DELETE_MTBF_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to DELETE_MTBF_DATA_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'DELETE_MTBF_DATA',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END DELETE_MTBF_DATA;



    --  Start of Comments  --
    --
    --  Procedure name      : CREATE_COUNTER_ASSOC
    --  Type                : Private
    --  Function            : This API would create the setup data for Reliability Framework in AHL_RA_CTR_ASSOCIATIONS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  CREATE_COUNTER_ASSOC Parameters :
    --      p_x_counter_assoc_rec               IN OUT  RA_COUNTER_ASSOC_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE CREATE_COUNTER_ASSOC (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_counter_assoc_rec       IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_COUNTER_ASSOC_REC_TYPE)    IS

        l_api_name      CONSTANT    VARCHAR2(30)    := 'CREATE_COUNTER_ASSOC';
        l_api_version   CONSTANT    NUMBER          := 1.0;
        L_FULL_NAME     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME;

        l_counter_assoc_rec         AHL_RA_SETUPS_PVT.RA_COUNTER_ASSOC_REC_TYPE DEFAULT p_x_counter_assoc_rec;
        l_dummy                     VARCHAR2(1);
        l_new_cou_name              CSI_COUNTER_TEMPLATE_VL.NAME%TYPE := NULL;
        l_overhaul_cou_name         CSI_COUNTER_TEMPLATE_VL.NAME%TYPE := NULL;
        l_new_cou_uom               CSI_COUNTER_TEMPLATE_VL.UOM_CODE%TYPE := NULL;
        l_overhaul_cou_uom          CSI_COUNTER_TEMPLATE_VL.UOM_CODE%TYPE := NULL;

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT CREATE_COUNTER_ASSOC_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- CREATE_COUNTER_ASSOC -------BEGIN-----------');
        END IF;


        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Parameters Passed --');
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_counter_assoc_rec.OPERATION_FLAG -- '||l_counter_assoc_rec.OPERATION_FLAG);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_counter_assoc_rec.SINCE_NEW_COUNTER_ID -- '||l_counter_assoc_rec.SINCE_NEW_COUNTER_ID);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID -- '||l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID);
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_counter_assoc_rec.DESCRIPTION -- '||l_counter_assoc_rec.DESCRIPTION);
        END IF;

        IF ((l_counter_assoc_rec.OPERATION_FLAG IS NULL) OR (l_counter_assoc_rec.OPERATION_FLAG <> G_DML_CREATE)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_COM_INVALID_DML_REC');
            FND_MESSAGE.Set_Token('FIELD',l_counter_assoc_rec.OPERATION_FLAG);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Mandatory validation for the Since New Counter
        IF(l_counter_assoc_rec.SINCE_NEW_COUNTER_ID is null) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_COU_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        --Validate value of the since new counter passed
        BEGIN
            -- Bug 4913954 : Perf Fixes.
            -- Since we are using reference to cs_counter_groups with a join condition TEMPLATE_FLAG = 'Y'
            -- i.e only counter templates, direct reference to cs_csi_counter_groups can be used here.
            SELECT templates.name,
                   templates.uom_code
              INTO l_new_cou_name,
                   l_new_cou_uom
              FROM cs_csi_counter_groups cg,
                   csi_counter_template_vl templates
             WHERE templates.counter_id = l_counter_assoc_rec.SINCE_NEW_COUNTER_ID
               AND cg.template_flag = 'Y'
               AND templates.group_id = cg.counter_group_id
               AND trunc(sysdate) < trunc(nvl(templates.end_date_active,sysdate+1));
             --Did not add the start date check above as this is setup and we might want to
             --define associations for counters that might get activated in future.

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- SINCE_NEW_COUNTER_ID Validated Successfully--');
            END IF;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - SINCE_NEW_COUNTER_ID -' || l_counter_assoc_rec.SINCE_NEW_COUNTER_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
                 FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_COU_DATA');
                 FND_MSG_PUB.ADD;
                 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        --Validate Since overhaul counter id passed
        IF(l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID IS NOT NULL) THEN
        BEGIN
            -- Bug 4913954 : Perf Fixes.
            -- Since we are using reference to cs_counter_groups with a join condition TEMPLATE_FLAG = 'Y'
            -- i.e only counter templates, direct reference to cs_csi_counter_groups can be used here.
            SELECT templates.name,
                   templates.uom_code
              INTO l_overhaul_cou_name,
                   l_overhaul_cou_uom
              FROM cs_csi_counter_groups cg,
                   csi_counter_template_vl templates
             WHERE templates.counter_id = l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID
               AND cg.template_flag = 'Y'
               AND templates.group_id = cg.counter_group_id
               AND trunc(sysdate) < trunc(nvl(templates.end_date_active,sysdate+1));
            --Did not add the start date check above as this is setup and we might want to
            --define associations for counters that might get activated in future.

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- SINCE_OVERHAUL_COUNTER_ID Validated Successfully--');
            END IF;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - SINCE_OVERHAUL_COUNTER_ID -' || l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
                 FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_COU_DATA');
                 FND_MSG_PUB.ADD;
                 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        END IF;


        --A since counter cannot be declared new and overhaul at the same time
        IF(l_counter_assoc_rec.SINCE_NEW_COUNTER_ID IS NOT NULL AND l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID IS NOT NULL) THEN
            IF(l_counter_assoc_rec.SINCE_NEW_COUNTER_ID = l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_RA_NEW_OHAUL_COU_SAME');
                FND_MESSAGE.Set_Token('COUNTER', l_new_cou_name);
                FND_MSG_PUB.ADD;
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        --UOM of Since New and Since Overhaul Counters should be same
        --The check below makes sense only when there is a overhaul counter defined in the association.
        IF(l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID IS NOT NULL) THEN
            IF(l_new_cou_uom IS NOT NULL and l_overhaul_cou_uom IS NOT NULL) THEN
                IF(l_new_cou_uom <> l_overhaul_cou_uom) THEN
                    FND_MESSAGE.Set_Name('AHL','AHL_RA_NEW_OHAUL_UOM_DIFF');
                    FND_MESSAGE.Set_Token('NEW_COUNTER', l_new_cou_name);
                    FND_MESSAGE.Set_Token('OHAUL_COUNTER', l_overhaul_cou_name);
                    FND_MESSAGE.Set_Token('NEW_COU_UOM', l_new_cou_uom);
                    FND_MESSAGE.Set_Token('OHAUL_COU_UOM', l_overhaul_cou_uom);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END IF;

        --A since New Counter should not have been previously declared as overhaul counter.
        BEGIN
            SELECT 'Y'
              INTO l_dummy
              FROM dual
             WHERE EXISTS(SELECT 'X'
                            FROM AHL_RA_CTR_ASSOCIATIONS
                           WHERE since_overhaul_counter_id = l_counter_assoc_rec.SINCE_NEW_COUNTER_ID);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'Validation Failure: This since new counter is already declared as overhaul - SINCE_NEW_COUNTER_ID -' || l_counter_assoc_rec.SINCE_NEW_COUNTER_ID);
            END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_NEW_COU_DEF_OHAUL');
            FND_MESSAGE.Set_Token('COUNTER', l_new_cou_name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                   fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation Sucess: This since new counter is not declared as an overhaul counter already --' || l_counter_assoc_rec.SINCE_NEW_COUNTER_ID);
                END IF;
        END;

        --A since Overhaul Counter should not have been declared previously as a new counter.
        IF(l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID IS NOT NULL) THEN
            BEGIN
                SELECT 'Y'
                  INTO l_dummy
                  FROM dual
                 WHERE EXISTS(SELECT 'X'
                                FROM AHL_RA_CTR_ASSOCIATIONS
                               WHERE since_new_counter_id = l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID);

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'--Validation Failure: This since new counter is already declared as overhaul - SINCE_OVERHAUL_COUNTER_ID -' || l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID);
                END IF;

                FND_MESSAGE.Set_Name('AHL','AHL_RA_OHAUL_COU_DEF_NEW');
                FND_MESSAGE.Set_Token('COUNTER', l_overhaul_cou_name);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                       fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation Sucess: This since ohaul counter is not declared as a new counter previously --' || l_counter_assoc_rec.SINCE_NEW_COUNTER_ID);
                    END IF;
            END;
        END IF;


        --Duplicate record validation
        BEGIN
            SELECT 'Y'
              INTO l_dummy
              FROM dual
             WHERE EXISTS(SELECT 'X'
                            FROM AHL_RA_CTR_ASSOCIATIONS counters
                           WHERE SINCE_NEW_COUNTER_ID = l_counter_assoc_rec.SINCE_NEW_COUNTER_ID
                             AND nvl(SINCE_OVERHAUL_COUNTER_ID,-1) = nvl(l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID,-1));

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation Failuure: Duplicate Counter Association exists-- SINCE_NEW_COUNTER_NAME - '|| l_new_cou_name  ||'- SINCE_OVERHAUL_COUNTER_NAME -' || l_overhaul_cou_name);
            END IF;

             FND_MESSAGE.Set_Name('AHL','AHL_RA_DUP_COU_ASSOC');
             FND_MESSAGE.Set_Token('NEW_COUNTER',l_new_cou_name );
             FND_MESSAGE.Set_Token('OHAUL_COUNTER', l_overhaul_cou_name);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                         fnd_log.string(fnd_log.level_statement,l_full_name,'-- Validation Successful: No Duplicate Counter Associations--');
                     END IF;
        END;

        -- Initialize RA_COUNTER_ASSOCIATION_ID to sequence next val for insert
        SELECT AHL_RA_CTR_ASSOCIATIONS_S.NEXTVAL into l_counter_assoc_rec.RA_COUNTER_ASSOCIATION_ID from dual;

        -- Initialize object version number to 1
        l_counter_assoc_rec.OBJECT_VERSION_NUMBER := 1;

        -- Intialize who column info
        l_counter_assoc_rec.LAST_UPDATED_BY := fnd_global.USER_ID;
        l_counter_assoc_rec.LAST_UPDATE_LOGIN := fnd_global.LOGIN_ID;
        l_counter_assoc_rec.CREATED_BY := fnd_global.user_id;
        l_counter_assoc_rec.CREATION_DATE := sysdate;
        l_counter_assoc_rec.LAST_UPDATE_DATE := sysdate;

        -- Initialize security group id
        l_counter_assoc_rec.SECURITY_GROUP_ID := null;

        --Insert the record into AHL_RA_CTR_ASSOCIATIONS
        INSERT INTO AHL_RA_CTR_ASSOCIATIONS
        (
            RA_COUNTER_ASSOCIATION_ID,
            SINCE_NEW_COUNTER_ID,
            SINCE_OVERHAUL_COUNTER_ID,
            DESCRIPTION,
            OBJECT_VERSION_NUMBER,
            SECURITY_GROUP_ID,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15
        )
        VALUES
        (
            l_counter_assoc_rec.RA_COUNTER_ASSOCIATION_ID,
            l_counter_assoc_rec.SINCE_NEW_COUNTER_ID,
            l_counter_assoc_rec.SINCE_OVERHAUL_COUNTER_ID,
            l_counter_assoc_rec.DESCRIPTION,
            l_counter_assoc_rec.OBJECT_VERSION_NUMBER,
            l_counter_assoc_rec.SECURITY_GROUP_ID,
            l_counter_assoc_rec.CREATION_DATE,
            l_counter_assoc_rec.CREATED_BY,
            l_counter_assoc_rec.LAST_UPDATE_DATE,
            l_counter_assoc_rec.LAST_UPDATED_BY,
            l_counter_assoc_rec.LAST_UPDATE_LOGIN,
            l_counter_assoc_rec.ATTRIBUTE_CATEGORY,
            l_counter_assoc_rec.ATTRIBUTE1,
            l_counter_assoc_rec.ATTRIBUTE2,
            l_counter_assoc_rec.ATTRIBUTE3,
            l_counter_assoc_rec.ATTRIBUTE4,
            l_counter_assoc_rec.ATTRIBUTE5,
            l_counter_assoc_rec.ATTRIBUTE6,
            l_counter_assoc_rec.ATTRIBUTE7,
            l_counter_assoc_rec.ATTRIBUTE8,
            l_counter_assoc_rec.ATTRIBUTE9,
            l_counter_assoc_rec.ATTRIBUTE10,
            l_counter_assoc_rec.ATTRIBUTE11,
            l_counter_assoc_rec.ATTRIBUTE12,
            l_counter_assoc_rec.ATTRIBUTE13,
            l_counter_assoc_rec.ATTRIBUTE14,
            l_counter_assoc_rec.ATTRIBUTE15
        );

        -- Set the Out Param
        p_x_counter_assoc_rec := l_counter_assoc_rec;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;


        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- CREATE_COUNTER_ASSOC --END--');
        END IF;


        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','Return Status = ' || x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to CREATE_COUNTER_ASSOC_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to CREATE_COUNTER_ASSOC_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to CREATE_COUNTER_ASSOC_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'CREATE_COUNTER_ASSOC',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END CREATE_COUNTER_ASSOC;

    --  Start of Comments  --
    --
    --  Procedure name      : DELETE_COUNTER_ASSOC
    --  Type                : Private
    --  Function            : This API would delete the setup data for Reliability Framework in AHL_RA_CTR_ASSOCIATIONS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  DELETE_COUNTER_ASSOC Parameters :
    --      p_counter_assoc_rec                IN OUT  RA_COUNTER_ASSOC_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE DELETE_COUNTER_ASSOC (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_counter_assoc_rec         IN               AHL_RA_SETUPS_PVT.RA_COUNTER_ASSOC_REC_TYPE)    IS

        l_api_name      CONSTANT    VARCHAR2(30)    := 'DELETE_COUNTER_ASSOC';
        l_api_version   CONSTANT    NUMBER          := 1.0;
        L_FULL_NAME     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME;

        l_obj_version_num           AHL_RA_CTR_ASSOCIATIONS.OBJECT_VERSION_NUMBER%TYPE;

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT DELETE_COUNTER_ASSOC_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- DELETE_COUNTER_ASSOC -------BEGIN-----------');
        END IF;

        IF ((p_counter_assoc_rec.OPERATION_FLAG IS NULL) OR (p_counter_assoc_rec.OPERATION_FLAG <> G_DML_DELETE)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_COM_INVALID_DML_REC');
            FND_MESSAGE.Set_Token('FIELD',p_counter_assoc_rec.OPERATION_FLAG);
            FND_MSG_PUB.ADD;
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Validate input data in p_counter_assoc_rec
        -- A. p_counter_assoc_rec.RA_COUNTER_ASSOCIATION_ID Cannot be NULL
        -- C. Object Version Number should not be NULL
        IF ((p_counter_assoc_rec.RA_COUNTER_ASSOCIATION_ID IS NULL) OR
            (p_counter_assoc_rec.OBJECT_VERSION_NUMBER IS NULL))THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- RA_COUNTER_ASSOCIATION_ID :' || p_counter_assoc_rec.RA_COUNTER_ASSOCIATION_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- OVN :' || p_counter_assoc_rec.OBJECT_VERSION_NUMBER);
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.D_COU_DATA');
            FND_MSG_PUB.ADD;
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Check for existence of record and fetch OVN for change record validation
        BEGIN
            SELECT OBJECT_VERSION_NUMBER
              INTO l_obj_version_num
              FROM AHL_RA_CTR_ASSOCIATIONS
             WHERE RA_COUNTER_ASSOCIATION_ID = p_counter_assoc_rec.RA_COUNTER_ASSOCIATION_ID
               FOR UPDATE OF object_version_number NOWAIT;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- OBJECT VERSION NUMBER IN DB : ' || l_obj_version_num);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string(fnd_log.level_statement,l_full_name,'-- DATA DOES NOT EXISTS -- ERROR ... ' || p_counter_assoc_rec.RA_COUNTER_ASSOCIATION_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
                 FND_MSG_PUB.ADD;
                 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        -- Validate input data in p_counter_assoc_rec
        -- A. RECORD MUST NOT HAVE CHANGED. i.e. object_version_number should not change.
        IF p_counter_assoc_rec.OBJECT_VERSION_NUMBER <> l_obj_version_num THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Record has changed : OVN passed : ' || p_counter_assoc_rec.OBJECT_VERSION_NUMBER);
           END IF;
           FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
           Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Delete Record from AHL_RA_CTR_ASSOCIATIONS
        DELETE AHL_RA_CTR_ASSOCIATIONS
         WHERE RA_COUNTER_ASSOCIATION_ID = p_counter_assoc_rec.RA_COUNTER_ASSOCIATION_ID;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- DELETE_COUNTER_ASSOC -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','At the start of PLSQL procedure');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to DELETE_COUNTER_ASSOC_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to DELETE_COUNTER_ASSOC_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to DELETE_COUNTER_ASSOC_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'DELETE_COUNTER_ASSOC',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END DELETE_COUNTER_ASSOC;

    --  Start of Comments  --
    --
    --  Procedure name      : CREATE_FCT_ASSOC_DATA
    --  Type                : Private
    --  Function            : This API would create the setup data for Reliability Framework in AHL_RA_FCT_ASSOCIATIONS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  CREATE_FCT_ASSOC_DATA Parameters :
    --      p_x_fct_assoc_rec               IN OUT  RA_FCT_ASSOC_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE CREATE_FCT_ASSOC_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_fct_assoc_rec           IN  OUT  NOCOPY  AHL_RA_SETUPS_PVT.RA_FCT_ASSOC_REC_TYPE)    IS

        l_api_name      CONSTANT    VARCHAR2(30)    := 'CREATE_FCT_ASSOC_DATA';
        l_api_version   CONSTANT    NUMBER          := 1.0;
        L_FULL_NAME     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME;

        l_fct_assoc_rec             AHL_RA_SETUPS_PVT.RA_FCT_ASSOC_REC_TYPE DEFAULT p_x_fct_assoc_rec;
        l_dummy                     VARCHAR2(1);

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT CREATE_FCT_ASSOC_DATA_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- CREATE_FCT_ASSOC_DATA -------BEGIN-----------');
        END IF;

        -- Validate input fct association data in p_x_fct_assoc_rec
        -- Note :: l_fct_assoc_rec has been defaulted to p_x_fct_assoc_rec in declaration
        -- A. ASSOCIATION_TYPE_CODE Cannot be NULL
        -- B. ASSOCIATION_TYPE_CODE should be in ('ASSOC_HISTORICAL','ASSOC_MTBF')
        -- C. ORGANIZATION_ID cannot be NULL
        -- D. FORECAST_DESIGNATOR cannot be NULL
        -- E. If ASSOCIATION_TYPE_CODE = ASSOC_HISTORICAL then PROBABILITY_FROM and PROBABILITY_TO are mandatory.
        -- F. OPERATIONS_FLAG should be C

        IF ((l_fct_assoc_rec.ASSOCIATION_TYPE_CODE IS NULL) OR
            (l_fct_assoc_rec.ASSOCIATION_TYPE_CODE NOT IN ('ASSOC_HISTORICAL','ASSOC_MTBF')) OR
            (l_fct_assoc_rec.ORGANIZATION_ID IS NULL) OR
            (l_fct_assoc_rec.FORECAST_DESIGNATOR IS NULL) OR
            ((l_fct_assoc_rec.OPERATION_FLAG IS NULL) OR (l_fct_assoc_rec.OPERATION_FLAG <> G_DML_CREATE))) THEN

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.FORECAST_DESIGNATOR ---- '||l_fct_assoc_rec.FORECAST_DESIGNATOR);
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.ORGANIZATION_ID -------- '||l_fct_assoc_rec.ORGANIZATION_ID);
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.ASSOCIATION_TYPE_CODE -- '||l_fct_assoc_rec.ASSOCIATION_TYPE_CODE);
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.OPERATION_FLAG --------- '||l_fct_assoc_rec.OPERATION_FLAG);
            END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_FCT_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

        IF (l_fct_assoc_rec.ASSOCIATION_TYPE_CODE = 'ASSOC_HISTORICAL' AND (l_fct_assoc_rec.PROBABILITY_FROM IS NULL OR
                                                                             l_fct_assoc_rec.PROBABILITY_TO IS NULL)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_FROM ------- '||l_fct_assoc_rec.PROBABILITY_FROM);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_TO --------- '||l_fct_assoc_rec.PROBABILITY_TO);
            END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_HIST_PROB_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;


        -- Validate value of ORGANIZATION_ID passed
        -- Bug 4913954 : Perf Fix
        -- Removed non-required reference to ORG_ORGANIZATION_DEFINTIONS below
        -- See earlier Query in 120.11
        BEGIN
            SELECT 'Y'
              INTO l_dummy
              FROM DUAL
             WHERE EXISTS(SELECT 'X'
                            FROM MTL_PARAMETERS MP
                           WHERE MP.ORGANIZATION_ID = l_fct_assoc_rec.ORGANIZATION_ID
                             AND MP.EAM_ENABLED_FLAG='Y');

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- ORGANIZATION_ID Validated Successfully--');
            END IF;


        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - ORGANIZATION_ID -' || l_fct_assoc_rec.ORGANIZATION_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
                 FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_FCT_DATA');
                 FND_MSG_PUB.ADD;
                 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        -- Validate value of FORECAST_DESIGNATOR passed
        BEGIN
            SELECT 'Y'
              INTO l_dummy
              FROM DUAL
             WHERE EXISTS(SELECT 'X'
                            FROM mrp_forecast_designators_v MRP
                           WHERE MRP.FORECAST_DESIGNATOR = l_fct_assoc_rec.FORECAST_DESIGNATOR
                             AND MRP.ORGANIZATION_ID = l_fct_assoc_rec.ORGANIZATION_ID
                             AND MRP.FORECAST_SET IS NOT NULL);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- FORECAST_DESIGNATOR Validated Successfully--');
            END IF;


        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - FORECAST_DESIGNATOR -' || l_fct_assoc_rec.FORECAST_DESIGNATOR);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
                 FND_MESSAGE.Set_Token('NAME','SETUP_PVT.C_FCT_DATA');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;


        -- When ASSOCIATION_TYPE_CODE = 'ASSOC_HISTORICAL'
        -- Validate PROBABILITY_FROM and PROBABILITY_TO passed
        -- 1. Neither PROBABILITY_FROM nor PROBABILITY_TO can be passed less than zero or greater than 100
        -- 2. PROBABILITY_TO should be >= PROBABILITY_FROM
        -- 3. records with Overlapping values of probablities should not exist for the Org Id and forecast designator in AHL_RA_FCT_ASSOCIATIONS
        IF (l_fct_assoc_rec.ASSOCIATION_TYPE_CODE = 'ASSOC_HISTORICAL') THEN

            -- 1. Neither PROBABILITY_FROM nor PROBABILITY_TO can be passed less than zero or greater than 100
            IF (l_fct_assoc_rec.PROBABILITY_FROM < 0 OR
                l_fct_assoc_rec.PROBABILITY_FROM > 100 OR
                l_fct_assoc_rec.PROBABILITY_TO < 0 OR
                l_fct_assoc_rec.PROBABILITY_TO > 100) THEN

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - less than zero or greater than 100 -');
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_FROM ------- '||l_fct_assoc_rec.PROBABILITY_FROM);
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_TO --------- '||l_fct_assoc_rec.PROBABILITY_TO);
                END IF;

                FND_MESSAGE.Set_Name('AHL','AHL_RA_PROB_VALID_RANGE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- 2. PROBABILITY_TO should be >= PROBABILITY_FROM
            IF (NOT(l_fct_assoc_rec.PROBABILITY_FROM <= l_fct_assoc_rec.PROBABILITY_TO)) THEN

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - PROBABILITY_TO should be >= PROBABILITY_FROM -');
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_FROM ------- '||l_fct_assoc_rec.PROBABILITY_FROM);
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_TO --------- '||l_fct_assoc_rec.PROBABILITY_TO);
                END IF;

                FND_MESSAGE.Set_Name('AHL','AHL_RA_PROB_RELATIONSHIP');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- 3. records with Overlapping values of probablities should not exist for the Org Id in AHL_RA_FCT_ASSOCIATIONS
            BEGIN
                SELECT 'Y'
                  INTO l_dummy
                  FROM DUAL
                 WHERE EXISTS (SELECT 'X'
                                 FROM AHL_RA_FCT_ASSOCIATIONS
                                WHERE ORGANIZATION_ID = l_fct_assoc_rec.ORGANIZATION_ID
                                  -- Bug 4998568 :: Probability Values Should not overlap irrespective of the Fct Designator
                                  -- AND FORECAST_DESIGNATOR = l_fct_assoc_rec.FORECAST_DESIGNATOR
                                  AND ASSOCIATION_TYPE_CODE = l_fct_assoc_rec.ASSOCIATION_TYPE_CODE
                                  AND ((PROBABILITY_FROM = l_fct_assoc_rec.PROBABILITY_FROM) OR
                                       (PROBABILITY_FROM > l_fct_assoc_rec.PROBABILITY_FROM AND PROBABILITY_FROM < l_fct_assoc_rec.PROBABILITY_TO) OR
                                       (PROBABILITY_FROM <= l_fct_assoc_rec.PROBABILITY_FROM AND PROBABILITY_TO >= l_fct_assoc_rec.PROBABILITY_TO) OR
                                       (PROBABILITY_TO > l_fct_assoc_rec.PROBABILITY_FROM AND PROBABILITY_TO < l_fct_assoc_rec.PROBABILITY_TO) OR
                                       (PROBABILITY_FROM = 100 AND l_fct_assoc_rec.PROBABILITY_TO = 100) OR -- if <> to 100 is defined .. then 100 to 100 is not allowed
                                       (PROBABILITY_TO = 100 AND l_fct_assoc_rec.PROBABILITY_FROM = 100)));  -- if 100 to 100 is defined .. then <> to 100 is not allowed


                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - Probability Overlap -');
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_FROM ------- '||l_fct_assoc_rec.PROBABILITY_FROM);
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_TO --------- '||l_fct_assoc_rec.PROBABILITY_TO);
                END IF;

                FND_MESSAGE.Set_Name('AHL','AHL_RA_PROB_OVERLAP');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                         fnd_log.string(fnd_log.level_statement,l_full_name,'- HISTORICAL - No OverLap -- SUCCESS -- ');
                     END IF;
            END;

        ELSIF (l_fct_assoc_rec.ASSOCIATION_TYPE_CODE = 'ASSOC_MTBF') THEN
        -- Elsif When ASSOCIATION_TYPE_CODE = 'ASSOC_MTBF'
        -- Validate for Duplicate records in AHL_RA_FCT_ASSOCIATIONS since only one MTBF Association
        -- Record can be created for each Organization - irrespective of the Forecast Selected.
            BEGIN
                SELECT 'Y'
                  INTO l_dummy
                  FROM DUAL
                 WHERE EXISTS (SELECT 'X'
                                 FROM AHL_RA_FCT_ASSOCIATIONS
                                WHERE ORGANIZATION_ID = l_fct_assoc_rec.ORGANIZATION_ID
                                  AND ASSOCIATION_TYPE_CODE = l_fct_assoc_rec.ASSOCIATION_TYPE_CODE);

                IF (fnd_log.leVEL_STATEMENT >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.stRING(FND_LOG.Level_statement,l_full_name,'-- Invalid Param Passed - DUPLICATE FOUNT - MTBF -');
                    fnd_log.stRING(FND_LOG.Level_statement,l_full_name,'-- l_fct_assoc_rec.ORGANIZATION_ID ------- '||l_fct_assoc_rec.ORGANIZATION_ID);
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.FORECAST_DESIGNATOR --------- '||l_fct_assoc_rec.FORECAST_DESIGNATOR);
                END IF;

                FND_MESSAGE.Set_Name('AHL','AHL_RA_FCT_ASSOC_MTBF_DUP');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            EXCEPTION
                WHEN No_Data_Found THEN
                     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                         fnd_log.string(fnd_log.level_statement,l_full_name,'- MTBF - No Duplicate -- SUCCESS -- ');
                     END IF;
            END;

            -- Explicitly Null out PROBABILITY_FROM and PROBABILITY_TO
            l_fct_assoc_rec.PROBABILITY_FROM := NULL;
            l_fct_assoc_rec.PROBABILITY_TO := NULL;

        END IF;

        -- Initialize RA_FCT_ASSOCIATION_ID to sequence next val for insert
        SELECT AHL_RA_FCT_ASSOCIATIONS_S.NEXTVAL INTO l_fct_assoc_rec.RA_FCT_ASSOCIATION_ID FROM DUAL;

        -- Initialize object version number to 1
        l_fct_assoc_rec.OBJECT_VERSION_NUMBER := 1;

        -- Intialize who column info
        l_fct_assoc_rec.LAST_UPDATED_BY := fnd_global.USER_ID;
        l_fct_assoc_rec.LAST_UPDATE_LOGIN := fnd_global.LOGIN_ID;
        l_fct_assoc_rec.CREATED_BY := fnd_global.user_id;
        l_fct_assoc_rec.CREATION_DATE := sysdate;
        l_fct_assoc_rec.LAST_UPDATE_DATE := sysdate;

        -- Initialize security group id
        l_fct_assoc_rec.SECURITY_GROUP_ID := NULL;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'-- Derived RA_FCT_ASSOCIATION_ID -- ' || l_fct_assoc_rec.RA_FCT_ASSOCIATION_ID);
        END IF;

        -- INSERT Forecast Associations Data in AHL_RA_FCT_ASSOCIATIONS
        INSERT INTO AHL_RA_FCT_ASSOCIATIONS(RA_FCT_ASSOCIATION_ID,FORECAST_DESIGNATOR,ASSOCIATION_TYPE_CODE,ORGANIZATION_ID,PROBABILITY_FROM, PROBABILITY_TO,
                                  OBJECT_VERSION_NUMBER,SECURITY_GROUP_ID,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,
                                  LAST_UPDATE_LOGIN,ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,
                                  ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15)
        VALUES(
                 l_fct_assoc_rec.RA_FCT_ASSOCIATION_ID     --    RA_FCT_ASSOCIATION_ID
                ,l_fct_assoc_rec.FORECAST_DESIGNATOR       --    FORECAST_DESIGNATOR
                ,l_fct_assoc_rec.ASSOCIATION_TYPE_CODE     --    ASSOCIATION_TYPE_CODE
                ,l_fct_assoc_rec.ORGANIZATION_ID           --    ORGANIZATION_ID
                ,l_fct_assoc_rec.PROBABILITY_FROM          --    PROBABILITY_FROM
                ,l_fct_assoc_rec.PROBABILITY_TO            --    PROBABILITY_TO
                ,l_fct_assoc_rec.OBJECT_VERSION_NUMBER     --    OBJECT_VERSION_NUMBER
                ,l_fct_assoc_rec.SECURITY_GROUP_ID         --    SECURITY_GROUP_ID
                ,l_fct_assoc_rec.CREATION_DATE             --    CREATION_DATE
                ,l_fct_assoc_rec.CREATED_BY                --    CREATED_BY
                ,l_fct_assoc_rec.LAST_UPDATE_DATE          --    LAST_UPDATE_DATE
                ,l_fct_assoc_rec.LAST_UPDATED_BY           --    LAST_UPDATED_BY
                ,l_fct_assoc_rec.LAST_UPDATE_LOGIN         --    LAST_UPDATE_LOGIN
                ,l_fct_assoc_rec.ATTRIBUTE_CATEGORY        --    ATTRIBUTE_CATEGORY
                ,l_fct_assoc_rec.ATTRIBUTE1                --    ATTRIBUTE1
                ,l_fct_assoc_rec.ATTRIBUTE2                --    ATTRIBUTE2
                ,l_fct_assoc_rec.ATTRIBUTE3                --    ATTRIBUTE3
                ,l_fct_assoc_rec.ATTRIBUTE4                --    ATTRIBUTE4
                ,l_fct_assoc_rec.ATTRIBUTE5                --    ATTRIBUTE5
                ,l_fct_assoc_rec.ATTRIBUTE6                --    ATTRIBUTE6
                ,l_fct_assoc_rec.ATTRIBUTE7                --    ATTRIBUTE7
                ,l_fct_assoc_rec.ATTRIBUTE8                --    ATTRIBUTE8
                ,l_fct_assoc_rec.ATTRIBUTE9                --    ATTRIBUTE9
                ,l_fct_assoc_rec.ATTRIBUTE10               --    ATTRIBUTE10
                ,l_fct_assoc_rec.ATTRIBUTE11               --    ATTRIBUTE11
                ,l_fct_assoc_rec.ATTRIBUTE12               --    ATTRIBUTE12
                ,l_fct_assoc_rec.ATTRIBUTE13               --    ATTRIBUTE13
                ,l_fct_assoc_rec.ATTRIBUTE14               --    ATTRIBUTE14
                ,l_fct_assoc_rec.ATTRIBUTE15               --    ATTRIBUTE15
        );

        -- Set the Out Param
           p_x_fct_assoc_rec := l_fct_assoc_rec;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- CREATE_FCT_ASSOC_DATA -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','Return Status = ' || x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            ROLLBACK TO CREATE_FCT_ASSOC_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO CREATE_FCT_ASSOC_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO CREATE_FCT_ASSOC_DATA_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'CREATE_FCT_ASSOC_DATA',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END CREATE_FCT_ASSOC_DATA;



    --  Start of Comments  --
    --
    --  Procedure name      : UPDATE_FCT_ASSOC_DATA
    --  Type                : Private
    --  Function            : This API would update the setup data for Reliability Framework in AHL_RA_FCT_ASSOCIATIONS
    --                        Update Logic to be used - NULL         : Do not update
    --                                                  G_MISS_XXXX  : Nullify
    --                                                  Valid Values : Update
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  UPDATE_FCT_ASSOC_DATA Parameters :
    --      p_x_fct_assoc_rec                 IN OUT  RA_FCT_ASSOC_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE UPDATE_FCT_ASSOC_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_x_fct_assoc_rec           IN OUT   NOCOPY  AHL_RA_SETUPS_PVT.RA_FCT_ASSOC_REC_TYPE)    IS

        l_api_name      CONSTANT    VARCHAR2(30)    := 'UPDATE_FCT_ASSOC_DATA';
        l_api_version   CONSTANT    NUMBER          := 1.0;
        L_FULL_NAME     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME;

        l_fct_assoc_rec             AHL_RA_SETUPS_PVT.RA_FCT_ASSOC_REC_TYPE DEFAULT p_x_fct_assoc_rec;
        l_obj_version_num           AHL_RA_FCT_ASSOCIATIONS.OBJECT_VERSION_NUMBER%TYPE;
        l_dummy                     varchar2(1);

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT UPDATE_FCT_ASSOC_DATA_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- UPDATE_FCT_ASSOC_DATA -------BEGIN-----------');
        END IF;

        -- Instead of FND_API.G_MISS_NUM, "-1001" is being passed from UI to indicate nullifying of Probability from
        -- and Probability To Columns. Translation being done below.
        IF (l_fct_assoc_rec.PROBABILITY_FROM  = -1001) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Translating -1001 to G_MISS_NUM - FROM');
            END IF;
            l_fct_assoc_rec.PROBABILITY_FROM := FND_API.G_MISS_NUM;
        END IF;

        IF (l_fct_assoc_rec.PROBABILITY_TO  = -1001) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Translating -1001 to G_MISS_NUM - TO');
            END IF;
            l_fct_assoc_rec.PROBABILITY_TO := FND_API.G_MISS_NUM;
        END IF;

        -- Validate input data in l_fct_assoc_rec
        -- A. l_fct_assoc_rec.RA_FCT_ASSOCIATION_ID Cannot be NULL
        -- B. OPERATIONS_FLAG should be U
        -- C. Object Version Number should not be NULL
        IF ((l_fct_assoc_rec.RA_FCT_ASSOCIATION_ID IS NULL) OR
            ((l_fct_assoc_rec.OPERATION_FLAG IS NULL) OR (l_fct_assoc_rec.OPERATION_FLAG <> G_DML_UPDATE)) OR
            (l_fct_assoc_rec.OBJECT_VERSION_NUMBER IS NULL OR l_fct_assoc_rec.OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM))THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- RA_FCT_ASSOCIATION_ID :' || l_fct_assoc_rec.RA_FCT_ASSOCIATION_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- OP FLAG :' || l_fct_assoc_rec.OPERATION_FLAG);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- OVN :' || l_fct_assoc_rec.OBJECT_VERSION_NUMBER);
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.U_FCST_DATA');
            FND_MSG_PUB.ADD;
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Check for existence of record and fetch details for change record validation and data defaulting
        BEGIN
            SELECT OBJECT_VERSION_NUMBER
                  ,DECODE(l_fct_assoc_rec.FORECAST_DESIGNATOR,FND_API.G_MISS_CHAR,NULL
                                                             ,NULL,FORECAST_DESIGNATOR
                                                             ,l_fct_assoc_rec.FORECAST_DESIGNATOR)
                  ,DECODE(l_fct_assoc_rec.ASSOCIATION_TYPE_CODE,FND_API.G_MISS_CHAR,NULL
                                                             ,NULL,ASSOCIATION_TYPE_CODE
                                                             ,l_fct_assoc_rec.ASSOCIATION_TYPE_CODE)
                  ,DECODE(l_fct_assoc_rec.ORGANIZATION_ID,FND_API.G_MISS_NUM,NULL
                                                             ,NULL,ORGANIZATION_ID
                                                             ,l_fct_assoc_rec.ORGANIZATION_ID)
                  ,DECODE(l_fct_assoc_rec.PROBABILITY_FROM,FND_API.G_MISS_NUM,NULL
                                                             ,NULL,PROBABILITY_FROM
                                                             ,l_fct_assoc_rec.PROBABILITY_FROM)
                  ,DECODE(l_fct_assoc_rec.PROBABILITY_TO,FND_API.G_MISS_NUM,NULL
                                                             ,NULL,PROBABILITY_TO
                                                             ,l_fct_assoc_rec.PROBABILITY_TO)
              INTO l_obj_version_num
                  ,l_fct_assoc_rec.FORECAST_DESIGNATOR
                  ,l_fct_assoc_rec.ASSOCIATION_TYPE_CODE
                  ,l_fct_assoc_rec.ORGANIZATION_ID
                  ,l_fct_assoc_rec.PROBABILITY_FROM
                  ,l_fct_assoc_rec.PROBABILITY_TO
              FROM AHL_RA_FCT_ASSOCIATIONS
             WHERE RA_FCT_ASSOCIATION_ID = l_fct_assoc_rec.RA_FCT_ASSOCIATION_ID
               FOR UPDATE OF object_version_number NOWAIT;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- OBJECT VERSION NUMBER IN DB : ' || l_obj_version_num);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string(fnd_log.level_statement,l_full_name,'-- DATA DOES NOT EXISTS -- ERROR ... ' || l_fct_assoc_rec.RA_FCT_ASSOCIATION_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;


        -- Validate input data in p_x_fct_assoc_rec
        -- A. RECORD MUST NOT HAVE CHANGED. i.e. object_version_number should not change.
        IF l_fct_assoc_rec.OBJECT_VERSION_NUMBER <> l_obj_version_num THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Record has changed : OVN passed : ' || l_fct_assoc_rec.OBJECT_VERSION_NUMBER);
           END IF;
           FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Due to the decode statements used above the l_fct_assoc_rec record will not contain the final state to data that will exist in the db.
        -- Validate input fct association data in l_fct_assoc_rec
        -- A. ASSOCIATION_TYPE_CODE Cannot be NULL
        -- B. If ASSOCIATION_TYPE_CODE should be in ('ASSOC_HISTORICAL','ASSOC_MTBF')
        -- C. ORGANIZATION_ID cannot be NULL
        -- D. FORECAST_DESIGNATOR cannot be NULL
        -- E. If ASSOCIATION_TYPE_CODE = ASSOC_HISTORICAL then PROBABILITY_FROM and PROBABILITY_TO are mandatory.
        -- F. OPERATIONS_FLAG should be U

        IF (l_fct_assoc_rec.ASSOCIATION_TYPE_CODE = 'ASSOC_HISTORICAL' AND (l_fct_assoc_rec.PROBABILITY_FROM IS NULL OR
                                                                            l_fct_assoc_rec.PROBABILITY_TO IS NULL)) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_FROM ------- '||l_fct_assoc_rec.PROBABILITY_FROM);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_TO --------- '||l_fct_assoc_rec.PROBABILITY_TO);
            END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_HIST_PROB_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

        IF ((l_fct_assoc_rec.ASSOCIATION_TYPE_CODE IS NULL) OR
            (l_fct_assoc_rec.ASSOCIATION_TYPE_CODE NOT IN ('ASSOC_HISTORICAL','ASSOC_MTBF')) OR
            (l_fct_assoc_rec.ORGANIZATION_ID IS NULL) OR
            (l_fct_assoc_rec.FORECAST_DESIGNATOR IS NULL) OR
            ((l_fct_assoc_rec.OPERATION_FLAG IS NULL) OR (l_fct_assoc_rec.OPERATION_FLAG <> G_DML_UPDATE))) THEN

             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed --');
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_FROM ------- '||l_fct_assoc_rec.PROBABILITY_FROM);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_TO --------- '||l_fct_assoc_rec.PROBABILITY_TO);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.FORECAST_DESIGNATOR ---- '||l_fct_assoc_rec.FORECAST_DESIGNATOR);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.ORGANIZATION_ID -------- '||l_fct_assoc_rec.ORGANIZATION_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.ASSOCIATION_TYPE_CODE -- '||l_fct_assoc_rec.ASSOCIATION_TYPE_CODE);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.OPERATION_FLAG --------- '||l_fct_assoc_rec.OPERATION_FLAG);
             END IF;

            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.U_FCT_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

        -- Validate value of ORGANIZATION_ID passed
        BEGIN
            -- Bug 4913954 : Perf Fix
            -- Removed non-required reference to ORG_ORGANIZATION_DEFINTIONS below
            -- See earlier Query in 120.11
            SELECT 'Y'
              INTO l_dummy
              FROM DUAL
             WHERE EXISTS(SELECT 'X'
                            FROM MTL_PARAMETERS MP
                           WHERE MP.ORGANIZATION_ID = l_fct_assoc_rec.ORGANIZATION_ID
                             AND MP.EAM_ENABLED_FLAG='Y');

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- ORGANIZATION_ID Validated Successfully--');
            END IF;


        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - ORGANIZATION_ID -' || l_fct_assoc_rec.ORGANIZATION_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
                 FND_MESSAGE.Set_Token('NAME','SETUP_PVT.U_FCT_DATA');
                 FND_MSG_PUB.ADD;
                 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        -- Validate value of FORECAST_DESIGNATOR passed
        BEGIN
            SELECT 'Y'
              INTO l_dummy
              FROM DUAL
             WHERE EXISTS(SELECT 'X'
                            FROM mrp_forecast_designators_v MRP
                           WHERE MRP.FORECAST_DESIGNATOR = l_fct_assoc_rec.FORECAST_DESIGNATOR
                             AND MRP.ORGANIZATION_ID = l_fct_assoc_rec.ORGANIZATION_ID
                             AND MRP.FORECAST_SET IS NOT NULL);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- FORECAST_DESIGNATOR Validated Successfully--');
            END IF;


        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - FORECAST_DESIGNATOR -' || l_fct_assoc_rec.FORECAST_DESIGNATOR);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
                 FND_MESSAGE.Set_Token('NAME','SETUP_PVT.U_FCT_DATA');
                 FND_MSG_PUB.ADD;
                 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END;


        -- When ASSOCIATION_TYPE_CODE = 'ASSOC_HISTORICAL'
        -- Validate PROBABILITY_FROM and PROBABILITY_TO passed
        -- 1. Neither PROBABILITY_FROM nor PROBABILITY_TO can be passed less than zero or greater than 100
        -- 2. PROBABILITY_TO should be >= PROBABILITY_FROM
        -- 3. records with Overlapping values of probablities should not exist for the Org Id in AHL_RA_FCT_ASSOCIATIONS
        IF (l_fct_assoc_rec.ASSOCIATION_TYPE_CODE = 'ASSOC_HISTORICAL') THEN

            -- 1. Neither PROBABILITY_FROM nor PROBABILITY_TO can be passed less than zero or greater than 100
            IF (l_fct_assoc_rec.PROBABILITY_FROM < 0 OR
                l_fct_assoc_rec.PROBABILITY_FROM > 100 OR
                l_fct_assoc_rec.PROBABILITY_TO < 0 OR
                l_fct_assoc_rec.PROBABILITY_TO > 100) THEN

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - less than zero or greater than 100 -');
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_FROM ------- '||l_fct_assoc_rec.PROBABILITY_FROM);
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_TO --------- '||l_fct_assoc_rec.PROBABILITY_TO);
                END IF;

                FND_MESSAGE.Set_Name('AHL','AHL_RA_PROB_VALID_RANGE');
                FND_MSG_PUB.ADD;
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- 2. PROBABILITY_TO should be >= PROBABILITY_FROM
            IF (NOT(l_fct_assoc_rec.PROBABILITY_FROM <= l_fct_assoc_rec.PROBABILITY_TO)) THEN

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - PROBABILITY_TO should be >= PROBABILITY_FROM -');
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_FROM ------- '||l_fct_assoc_rec.PROBABILITY_FROM);
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_TO --------- '||l_fct_assoc_rec.PROBABILITY_TO);
                END IF;

                FND_MESSAGE.Set_Name('AHL','AHL_RA_PROB_RELATIONSHIP');
                FND_MSG_PUB.ADD;
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- 3. records with Overlapping values of probablities should not exist for the Org Id and forecast designator in AHL_RA_FCT_ASSOCIATIONS
            BEGIN
                SELECT 'Y'
                  INTO l_dummy
                  FROM DUAL
                 WHERE EXISTS (SELECT 'X'
                                 FROM AHL_RA_FCT_ASSOCIATIONS
                                WHERE ORGANIZATION_ID = l_fct_assoc_rec.ORGANIZATION_ID
                                  -- Bug 4998568 :: Probability Values Should not overlap irrespective of the Fct Designator
                                  -- AND FORECAST_DESIGNATOR = l_fct_assoc_rec.FORECAST_DESIGNATOR
                                  AND ASSOCIATION_TYPE_CODE = l_fct_assoc_rec.ASSOCIATION_TYPE_CODE
                                  AND ((PROBABILITY_FROM = l_fct_assoc_rec.PROBABILITY_FROM) OR
                                       (PROBABILITY_FROM > l_fct_assoc_rec.PROBABILITY_FROM AND PROBABILITY_FROM < l_fct_assoc_rec.PROBABILITY_TO) OR
                                       (PROBABILITY_FROM <= l_fct_assoc_rec.PROBABILITY_FROM AND PROBABILITY_TO >= l_fct_assoc_rec.PROBABILITY_TO) OR
                                       (PROBABILITY_TO > l_fct_assoc_rec.PROBABILITY_FROM AND PROBABILITY_TO < l_fct_assoc_rec.PROBABILITY_TO) OR
                                       (PROBABILITY_FROM = 100 AND l_fct_assoc_rec.PROBABILITY_TO = 100) OR-- if <> to 100 is defined .. then 100 to 100 is not allowed
                                       (PROBABILITY_TO = 100 AND l_fct_assoc_rec.PROBABILITY_FROM = 100)) -- if 100 to 100 is defined .. then <> to 100 is not allowed
                                  AND RA_FCT_ASSOCIATION_ID <> l_fct_assoc_rec.RA_FCT_ASSOCIATION_ID); -- Update of the ame record to bump OVN is allowed


                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed - Probability Overlap -');
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_FROM ------- '||l_fct_assoc_rec.PROBABILITY_FROM);
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.PROBABILITY_TO --------- '||l_fct_assoc_rec.PROBABILITY_TO);
                END IF;

                FND_MESSAGE.Set_Name('AHL','AHL_RA_PROB_OVERLAP');
                FND_MSG_PUB.ADD;
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                         fnd_log.string(fnd_log.level_statement,l_full_name,'- HISTORICAL - No OverLap -- SUCCESS -- ');
                     END IF;
            END;

        ELSIF (l_fct_assoc_rec.ASSOCIATION_TYPE_CODE = 'ASSOC_MTBF') THEN
        -- Elsif When ASSOCIATION_TYPE_CODE = 'ASSOC_MTBF'
        -- Validate for Duplicate records in AHL_RA_FCT_ASSOCIATIONS since only one MTBF Association
        -- Record can be created for each Organization - irrespective of the Forecast Selected.
            BEGIN
                SELECT 'Y'
                  INTO l_dummy
                  FROM DUAL
                 WHERE EXISTS (SELECT 'X'
                                 FROM AHL_RA_FCT_ASSOCIATIONS
                                WHERE ORGANIZATION_ID = l_fct_assoc_rec.ORGANIZATION_ID
                                  AND ASSOCIATION_TYPE_CODE = l_fct_assoc_rec.ASSOCIATION_TYPE_CODE
                                  AND RA_FCT_ASSOCIATION_ID <> l_fct_assoc_rec.RA_FCT_ASSOCIATION_ID); -- Update of the ame record to bump OVN is allowed


                IF (fnd_log.leVEL_STATEMENT >= fnd_log.g_current_runtime_level)THEN
                    fnd_log.stRING(FND_LOG.Level_statement,l_full_name,'-- Invalid Param Passed - DUPLICATE FOUNT - MTBF -');
                    fnd_log.stRING(FND_LOG.Level_statement,l_full_name,'-- l_fct_assoc_rec.ORGANIZATION_ID ------- '||l_fct_assoc_rec.ORGANIZATION_ID);
                    fnd_log.string(fnd_log.level_statement,l_full_name,'-- l_fct_assoc_rec.FORECAST_DESIGNATOR --------- '||l_fct_assoc_rec.FORECAST_DESIGNATOR);
                END IF;

                FND_MESSAGE.Set_Name('AHL','AHL_RA_FCT_ASSOC_MTBF_DUP');
                FND_MSG_PUB.ADD;
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;

            EXCEPTION
                When No_Data_Found then
                     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                         fnd_log.string(fnd_log.level_statement,l_full_name,'- MTBF - No Duplicate -- SUCCESS -- ');
                     END IF;
            END;

            -- Explicitly Null out PROBABILITY_FROM and PROBABILITY_TO
            l_fct_assoc_rec.PROBABILITY_FROM := NULL;
            l_fct_assoc_rec.PROBABILITY_TO := NULL;

        END IF;

        -- Increment object version number
        l_fct_assoc_rec.OBJECT_VERSION_NUMBER := l_fct_assoc_rec.OBJECT_VERSION_NUMBER + 1;

        -- Intialize who column info
        l_fct_assoc_rec.LAST_UPDATED_BY := fnd_global.USER_ID;
        l_fct_assoc_rec.LAST_UPDATE_LOGIN := fnd_global.LOGIN_ID;
        l_fct_assoc_rec.LAST_UPDATE_DATE := sysdate;
        l_fct_assoc_rec.CREATED_BY := fnd_global.user_id;
        l_fct_assoc_rec.CREATION_DATE := sysdate;

        -- INSERT Forecast Associations Data in AHL_RA_FCT_ASSOCIATIONS
        UPDATE AHL_RA_FCT_ASSOCIATIONS
        SET     FORECAST_DESIGNATOR         = l_fct_assoc_rec.FORECAST_DESIGNATOR       --    FORECAST_DESIGNATOR
                ,ASSOCIATION_TYPE_CODE      = l_fct_assoc_rec.ASSOCIATION_TYPE_CODE     --    ASSOCIATION_TYPE_CODE
                ,ORGANIZATION_ID            = l_fct_assoc_rec.ORGANIZATION_ID           --    ORGANIZATION_ID
                ,PROBABILITY_FROM           = l_fct_assoc_rec.PROBABILITY_FROM          --    PROBABILITY_FROM
                ,PROBABILITY_TO             = l_fct_assoc_rec.PROBABILITY_TO            --    PROBABILITY_TO
                ,OBJECT_VERSION_NUMBER      = l_fct_assoc_rec.OBJECT_VERSION_NUMBER     --    OBJECT_VERSION_NUMBER
                ,SECURITY_GROUP_ID          = l_fct_assoc_rec.SECURITY_GROUP_ID         --    SECURITY_GROUP_ID
                ,LAST_UPDATE_DATE           = l_fct_assoc_rec.LAST_UPDATE_DATE          --    LAST_UPDATE_DATE
                ,LAST_UPDATED_BY            = l_fct_assoc_rec.LAST_UPDATED_BY           --    LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN          = l_fct_assoc_rec.LAST_UPDATE_LOGIN         --    LAST_UPDATE_LOGIN
                ,ATTRIBUTE_CATEGORY         = l_fct_assoc_rec.ATTRIBUTE_CATEGORY        --    ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1                 = l_fct_assoc_rec.ATTRIBUTE1                --    ATTRIBUTE1
                ,ATTRIBUTE2                 = l_fct_assoc_rec.ATTRIBUTE2                --    ATTRIBUTE2
                ,ATTRIBUTE3                 = l_fct_assoc_rec.ATTRIBUTE3                --    ATTRIBUTE3
                ,ATTRIBUTE4                 = l_fct_assoc_rec.ATTRIBUTE4                --    ATTRIBUTE4
                ,ATTRIBUTE5                 = l_fct_assoc_rec.ATTRIBUTE5                --    ATTRIBUTE5
                ,ATTRIBUTE6                 = l_fct_assoc_rec.ATTRIBUTE6                --    ATTRIBUTE6
                ,ATTRIBUTE7                 = l_fct_assoc_rec.ATTRIBUTE7                --    ATTRIBUTE7
                ,ATTRIBUTE8                 = l_fct_assoc_rec.ATTRIBUTE8                --    ATTRIBUTE8
                ,ATTRIBUTE9                 = l_fct_assoc_rec.ATTRIBUTE9                --    ATTRIBUTE9
                ,ATTRIBUTE10                = l_fct_assoc_rec.ATTRIBUTE10               --    ATTRIBUTE10
                ,ATTRIBUTE11                = l_fct_assoc_rec.ATTRIBUTE11               --    ATTRIBUTE11
                ,ATTRIBUTE12                = l_fct_assoc_rec.ATTRIBUTE12               --    ATTRIBUTE12
                ,ATTRIBUTE13                = l_fct_assoc_rec.ATTRIBUTE13               --    ATTRIBUTE13
                ,ATTRIBUTE14                = l_fct_assoc_rec.ATTRIBUTE14               --    ATTRIBUTE14
                ,ATTRIBUTE15                = l_fct_assoc_rec.ATTRIBUTE15               --    ATTRIBUTE15
         WHERE RA_FCT_ASSOCIATION_ID = l_fct_assoc_rec.RA_FCT_ASSOCIATION_ID;

        -- Set the Out Param
        p_x_fct_assoc_rec := l_fct_assoc_rec;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- UPDATE_FCT_ASSOC_DATA -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','Return Status = ' || x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Rollback to UPDATE_FCT_ASSOC_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to UPDATE_FCT_ASSOC_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            Rollback to UPDATE_FCT_ASSOC_DATA_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'UPDATE_FCT_ASSOC_DATA',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END UPDATE_FCT_ASSOC_DATA;



    --  Start of Comments  --
    --
    --  Procedure name      : DELETE_FCT_ASSOC_DATA
    --  Type                : Private
    --  Function            : This API would delete the setup data for Reliability Framework in AHL_RA_FCT_ASSOCIATIONS
    --  Pre-reqs            :
    --
    --  Standard IN  Parameters :
    --      p_api_version                   IN      NUMBER                Required
    --      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
    --      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
    --
    --  Standard OUT Parameters :
    --      x_return_status                 OUT     VARCHAR2              Required
    --      x_msg_count                     OUT     NUMBER                Required
    --      x_msg_data                      OUT     VARCHAR2              Required
    --
    --  DELETE_FCT_ASSOC_DATA Parameters :
    --      p_fct_assoc_rec                IN OUT  RA_FCT_ASSOC_REC_TYPE  Required
    --
    --  Version :
    --      Initial Version   1.0
    --
    --  End of Comments  --
    PROCEDURE DELETE_FCT_ASSOC_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_fct_assoc_rec             IN               AHL_RA_SETUPS_PVT.RA_FCT_ASSOC_REC_TYPE)    IS

        l_api_name      CONSTANT    VARCHAR2(30)    := 'DELETE_FCT_ASSOC_DATA';
        l_api_version   CONSTANT    NUMBER          := 1.0;
        L_FULL_NAME     CONSTANT    VARCHAR2(60)    := 'ahl.plsql.'||G_PKG_NAME || '.' || L_API_NAME;

        l_obj_version_num           AHL_RA_FCT_ASSOCIATIONS.OBJECT_VERSION_NUMBER%TYPE;

    BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
        END IF;

        -- Standard start of API savepoint
        SAVEPOINT DELETE_FCT_ASSOC_DATA_SP;

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.To_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.Initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- DELETE_FCT_ASSOC_DATA -------BEGIN-----------');
        END IF;

        -- Validate input data in p_fct_assoc_rec
        -- A. p_fct_assoc_rec.RA_FCT_ASSOCIATION_ID Cannot be NULL
        -- B. OPERATIONS_FLAG should be D
        -- C. Object Version Number should not be NULL
        IF ((p_fct_assoc_rec.RA_FCT_ASSOCIATION_ID IS NULL) OR
            ((p_fct_assoc_rec.OPERATION_FLAG IS NULL) OR (p_fct_assoc_rec.OPERATION_FLAG <> G_DML_DELETE)) OR
            (p_fct_assoc_rec.OBJECT_VERSION_NUMBER IS NULL))THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- RA_FCT_ASSOCIATION_ID :' || p_fct_assoc_rec.RA_FCT_ASSOCIATION_ID);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- OP FLAG :' || p_fct_assoc_rec.OPERATION_FLAG);
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- Invalid Param Passed -- OVN :' || p_fct_assoc_rec.OBJECT_VERSION_NUMBER);
            END IF;
            FND_MESSAGE.Set_Name('AHL','AHL_RA_INV_PARAM_PASSED');
            FND_MESSAGE.Set_Token('NAME','SETUP_PVT.D_FCST_DATA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Check for existence of record and fetch OVN for change record validation
        BEGIN
            SELECT OBJECT_VERSION_NUMBER
              INTO l_obj_version_num
              FROM AHL_RA_FCT_ASSOCIATIONS
             WHERE RA_FCT_ASSOCIATION_ID = p_fct_assoc_rec.RA_FCT_ASSOCIATION_ID
               FOR UPDATE OF object_version_number NOWAIT;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                fnd_log.string(fnd_log.level_statement,l_full_name,'-- OBJECT VERSION NUMBER IN DB : ' || l_obj_version_num);
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string(fnd_log.level_statement,l_full_name,'-- DATA DOES NOT EXISTS -- ERROR ... ' || p_fct_assoc_rec.RA_FCT_ASSOCIATION_ID);
                 END IF;
                 FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_DELETED');
                 FND_MSG_PUB.ADD;
                 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

        -- Validate input data in p_fct_assoc_rec
        -- A. RECORD MUST NOT HAVE CHANGED. i.e. object_version_number should not change.
        IF p_fct_assoc_rec.OBJECT_VERSION_NUMBER <> l_obj_version_num THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
               fnd_log.string(fnd_log.level_statement,l_full_name,'-- Record has changed : OVN passed : ' || p_fct_assoc_rec.OBJECT_VERSION_NUMBER);
           END IF;
           FND_MESSAGE.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Delete Record from AHL_RA_FCT_ASSOCIATIONS
        DELETE AHL_RA_FCT_ASSOCIATIONS
         WHERE RA_FCT_ASSOCIATION_ID = p_fct_assoc_rec.RA_FCT_ASSOCIATION_ID;

        -- Standard check for p_commit
        IF FND_API.To_Boolean (p_commit) THEN
            COMMIT;
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement,l_full_name,'DS -- PVT -- DELETE_FCT_ASSOC_DATA -------END-----------');
        END IF;

        -- Standard call to get message count and if count is 1, get message
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data,
            p_encoded => fnd_api.g_false);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
            fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','Return Status = ' || x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            ROLLBACK TO DELETE_FCT_ASSOC_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO DELETE_FCT_ASSOC_DATA_SP;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO DELETE_FCT_ASSOC_DATA_SP;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                                        p_procedure_name => 'DELETE_FCT_ASSOC_DATA',
                                        p_error_text     => SUBSTR(SQLERRM,1,240));
            END IF;
            FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                                       p_data  => x_msg_data,
                                       p_encoded => fnd_api.g_false);

    END DELETE_FCT_ASSOC_DATA;

END AHL_RA_SETUPS_PVT;

/
