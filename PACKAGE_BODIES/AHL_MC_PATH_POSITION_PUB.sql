--------------------------------------------------------
--  DDL for Package Body AHL_MC_PATH_POSITION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_PATH_POSITION_PUB" AS
/* $Header: AHLPPOSB.pls 120.0 2008/02/20 23:32:29 jaramana noship $ */

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'AHL_MC_PATH_POSITION_PUB';

------------------------------------------------------------------------------------
-- Local API Declaration
------------------------------------------------------------------------------------
PROCEDURE Convert_Path_Pos_Values_to_Id (
    p_x_path_position_tbl IN OUT NOCOPY    AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type
);

-------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Create_Position_ID
--  Type              : Public
--  Function          : Does user input validation and calls private API Create_Position_ID
--  Pre-reqs          :
--  Parameters        :
--
--  Create_Position_ID Parameters:
--       p_path_position_tbl  IN  AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type  Required
--
--  End of Comments
-------------------------------------------------------------------------------------------
PROCEDURE Create_Position_ID (
    p_api_version           IN           NUMBER,
    p_init_msg_list         IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_path_position_tbl     IN           AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type,
    p_position_ref_meaning  IN           VARCHAR2,
    p_position_ref_code     IN           VARCHAR2,
    x_position_id           OUT  NOCOPY  NUMBER,
    x_return_status         OUT  NOCOPY  VARCHAR2,
    x_msg_count             OUT  NOCOPY  NUMBER,
    x_msg_data              OUT  NOCOPY  VARCHAR2
) IS

--
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Create_Position_ID';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_path_position_tbl     AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type DEFAULT p_path_position_tbl;
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.begin', 'At the start of the API');
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Create_Position_ID_Pub;

    -- Initialize Procedure return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement, l_full_name,
                       'p_path_position_tbl.COUNT = '|| p_path_position_tbl.COUNT);
    END IF;

    -- check for path position table
    IF (p_path_position_tbl.COUNT < 1) THEN
        -- input is NULL
        FND_MESSAGE.Set_Name('AHL', 'AHL_MC_PATH_POS_TBL_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call Convert_Path_Pos_Values_to_Id
    Convert_Path_Pos_Values_to_Id(l_path_position_tbl);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement, l_full_name, 'Calling private API AHL_MC_PATH_POSITION_PVT.Create_Position_ID.');
    END IF;

    -- call the private API
    AHL_MC_PATH_POSITION_PVT.Create_Position_ID(
        p_api_version          => p_api_version,
        p_init_msg_list        => p_init_msg_list,
        p_commit               => FND_API.G_FALSE,      -- Pass false and commit at the end if needed
        p_validation_level     => p_validation_level,
        p_path_position_tbl    => l_path_position_tbl,
        p_position_ref_meaning => FND_API.G_MISS_CHAR,  -- This Public API is not to be used for copying. Hence passing G_MISS
        p_position_ref_code    => FND_API.G_MISS_CHAR,  -- This Public API is not to be used for copying. Hence passing G_MISS
        x_position_id          => x_position_id,
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data
    );

    -- check for the return status
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_full_name,
                           'Raising exception with x_return_status = ' || x_return_status);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement, l_full_name, 'AHL_MC_PATH_POSITION_PVT.Create_Position_ID returned x_return_status as ' || x_return_status);
    END IF;

    -- Standard check of p_commit
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get
    ( p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE
    );

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.end', 'End of the API');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        Rollback to Create_Position_ID_Pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Rollback to Create_Position_ID_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        Rollback to Create_Position_ID_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

END Create_Position_ID;

-----------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Convert_Path_Pos_Values_to_Id
--  Type              : Local
--  Function          : Does user input validation and value to id conversion
--  Pre-reqs          :
--  Parameters        :
--
--  Convert_Path_Pos_Values_to_Id Parameters:
--       p_x_path_position_tbl IN OUT AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type
--
--  End of Comments
-----------------------------------------------------------------------------------------------
PROCEDURE Convert_Path_Pos_Values_to_Id (
    p_x_path_position_tbl IN OUT NOCOPY    AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type
) IS

CURSOR chk_mc_id_csr (p_mc_id NUMBER) IS
    SELECT 'X'
    FROM   AHL_MC_HEADERS_B
    WHERE  mc_id = p_mc_id;

CURSOR chk_mc_name_csr (p_mc_name VARCHAR2) IS
    SELECT mc_id
    FROM   AHL_MC_HEADERS_B
    WHERE  name = p_mc_name;

CURSOR chk_mc_ver_no_csr (p_mc_id NUMBER, p_ver_no NUMBER) IS
    SELECT 'X'
    FROM   AHL_MC_HEADERS_B
    WHERE  version_number = p_ver_no
    AND    mc_id          = p_mc_id;

CURSOR chk_mc_revision_csr (p_mc_id NUMBER, p_revision VARCHAR2) IS
    SELECT version_number
    FROM   AHL_MC_HEADERS_B
    WHERE  revision = p_revision
    AND    mc_id    = p_mc_id;
--
l_api_name     CONSTANT  VARCHAR2(30) := 'Convert_Path_Pos_Values_to_Id';
l_full_name    CONSTANT  VARCHAR2(90) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_mc_id                  NUMBER;
l_ver_no                 NUMBER;
l_path_position_tbl      AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type DEFAULT p_x_path_position_tbl;
l_dummy                  VARCHAR2(1);
l_validation_failed_flag VARCHAR2(1)  := 'N';
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.begin', 'At the start of the API');
    END IF;

    FOR i IN l_path_position_tbl.FIRST..l_path_position_tbl.LAST LOOP
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_full_name,
                           'i = ' || i ||
                           ', l_path_position_tbl(i).mc_id = ' || l_path_position_tbl(i).mc_id||
                           ', l_path_position_tbl(i).mc_name = ' || l_path_position_tbl(i).mc_name||
                           ', l_path_position_tbl(i).mc_revision = ' || l_path_position_tbl(i).mc_revision||
                           ', l_path_position_tbl(i).version_number = ' || l_path_position_tbl(i).version_number||
                           ', l_path_position_tbl(i).position_key = ' || l_path_position_tbl(i).position_key);
        END IF;

        -- check for mc_id
        IF (l_path_position_tbl(i).mc_id IS NULL) THEN
            -- check for mc_name
            IF (l_path_position_tbl(i).mc_name IS NULL) THEN
                -- input is NULL
                FND_MESSAGE.Set_Name('AHL', 'AHL_MC_RULE_MC_ID_NULL');
                FND_MSG_PUB.ADD;
                l_validation_failed_flag := 'Y';
            ELSE
                OPEN chk_mc_name_csr(l_path_position_tbl(i).mc_name);
                FETCH chk_mc_name_csr INTO l_mc_id;

                IF (chk_mc_name_csr%NOTFOUND) THEN
                    -- input is invalid
                    FND_MESSAGE.Set_Name('AHL', 'AHL_MC_RULE_MC_ID_NAME_INV');
                    FND_MESSAGE.Set_Token('MC_NAME', l_path_position_tbl(i).mc_name);
                    FND_MSG_PUB.ADD;
                    l_validation_failed_flag := 'Y';
                END IF;

                -- set the mc_id
                l_path_position_tbl(i).mc_id := l_mc_id;
                CLOSE chk_mc_name_csr;
            END IF;
        ELSE
            -- check with mc_id
            OPEN chk_mc_id_csr (l_path_position_tbl(i).mc_id);
            FETCH chk_mc_id_csr INTO l_dummy;

            IF (chk_mc_id_csr%NOTFOUND) THEN
                -- input is invalid
                FND_MESSAGE.Set_Name('AHL', 'AHL_MC_RULE_MC_ID_INV');
                FND_MESSAGE.Set_Token('MC_ID', l_path_position_tbl(i).mc_id);
                FND_MSG_PUB.ADD;
                l_validation_failed_flag := 'Y';
            END IF;

            CLOSE chk_mc_id_csr;
        END IF;

        -- if mc_id is not null; i.e. mc_id has been derived/validated
        -- check for version_number
        IF (l_path_position_tbl(i).mc_id IS NOT NULL) THEN
            IF (l_path_position_tbl(i).version_number IS NULL) THEN
                -- check for revision
                IF (l_path_position_tbl(i).mc_revision IS NOT NULL) THEN
                    OPEN chk_mc_revision_csr(l_path_position_tbl(i).mc_id, l_path_position_tbl(i).mc_revision);
                    FETCH chk_mc_revision_csr INTO l_ver_no;

                    IF (chk_mc_revision_csr%NOTFOUND) THEN
                        -- input is invalid
                        FND_MESSAGE.Set_Name('AHL', 'AHL_MC_RULE_MC_REV_INV');
                        FND_MESSAGE.Set_Token('MC_ID', l_path_position_tbl(i).mc_id);
                        FND_MESSAGE.Set_Token('MC_REV', l_path_position_tbl(i).mc_revision);
                        FND_MSG_PUB.ADD;
                        l_validation_failed_flag := 'Y';
                    END IF;

                    -- set the version_number
                    l_path_position_tbl(i).version_number := l_ver_no;
                    CLOSE chk_mc_revision_csr;
                END IF;
            ELSE
                -- check with version_number
                OPEN chk_mc_ver_no_csr (l_path_position_tbl(i).mc_id, l_path_position_tbl(i).version_number);
                FETCH chk_mc_ver_no_csr INTO l_dummy;

                IF (chk_mc_ver_no_csr%NOTFOUND) THEN
                    -- input is invalid
                    FND_MESSAGE.Set_Name('AHL', 'AHL_MC_RULE_MC_VER_NO_INV');
                    FND_MESSAGE.Set_Token('MC_ID', l_path_position_tbl(i).mc_id);
                    FND_MESSAGE.Set_Token('MC_VER_NO', l_path_position_tbl(i).version_number);
                    FND_MSG_PUB.ADD;
                    l_validation_failed_flag := 'Y';
                END IF;

                CLOSE chk_mc_ver_no_csr;
            END IF;
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_full_name,
                           'i = '|| i ||
                           ', l_path_position_tbl(i).mc_id = ' || l_path_position_tbl(i).mc_id ||
                           ', l_path_position_tbl(i).mc_name = ' || l_path_position_tbl(i).mc_name ||
                           ', l_path_position_tbl(i).mc_revision = ' || l_path_position_tbl(i).mc_revision ||
                           ', l_path_position_tbl(i).version_number = ' || l_path_position_tbl(i).version_number ||
                           ', l_path_position_tbl(i).position_key = ' || l_path_position_tbl(i).position_key);
        END IF;

        -- raise the exception if some error occurred
        IF (l_validation_failed_flag = 'Y') THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END LOOP;

    -- return changed record
    p_x_path_position_tbl := l_path_position_tbl;

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure, l_full_name || '.end', 'End of the API');
    END IF;

END Convert_Path_Pos_Values_to_Id;

End AHL_MC_PATH_POSITION_PUB;

/
