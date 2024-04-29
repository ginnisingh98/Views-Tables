--------------------------------------------------------
--  DDL for Package Body AHL_MC_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_RULE_PUB" AS
/* $Header: AHLPMCRB.pls 120.0.12010000.1 2008/11/26 14:18:19 sathapli noship $ */

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'AHL_MC_RULE_PUB';

------------------------------------------------------------------------------------
-- Local API Declaration
------------------------------------------------------------------------------------
PROCEDURE Convert_Rule_Values_to_Id (
    p_x_rule_rec         IN OUT NOCOPY    AHL_MC_RULE_PVT.Rule_Rec_Type,
    p_operation_flag     IN               VARCHAR2
);

PROCEDURE Convert_Rule_Stmt_Values_to_Id (
    p_x_ui_rule_stmt_tbl IN OUT NOCOPY    AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type,
    p_operation_flag     IN               VARCHAR2
);

------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Insert_Rule
--  Type              : Public
--  Function          : Does user input validation and calls private API Insert_Rule
--  Pre-reqs          :
--  Parameters        :
--
--  Insert_Rule Parameters:
--       p_x_rule_rec    IN OUT NOCOPY AHL_MC_RULE_PVT.Rule_Rec_Type         Required
--	 p_rule_stmt_tbl IN            AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type Required
--
--  End of Comments

PROCEDURE Insert_Rule (
    p_api_version         IN               NUMBER,
    p_init_msg_list       IN               VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN               VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module		  IN               VARCHAR2  := 'JSP',
    p_rule_stmt_tbl       IN               AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type,
    p_x_rule_rec 	  IN OUT NOCOPY    AHL_MC_RULE_PVT.Rule_Rec_Type,
    x_return_status       OUT    NOCOPY    VARCHAR2,
    x_msg_count           OUT    NOCOPY    NUMBER,
    x_msg_data            OUT    NOCOPY    VARCHAR2
) IS

--
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Insert_Rule';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_rule_stmt_tbl         AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type DEFAULT p_rule_stmt_tbl;
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Insert_Rule_Pub;

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
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_x_rule_rec.mc_header_id => '||p_x_rule_rec.mc_header_id||
                       ' p_x_rule_rec.mc_name => '||p_x_rule_rec.mc_name||
                       ' p_x_rule_rec.mc_revision => '||p_x_rule_rec.mc_revision||
                       ' p_x_rule_rec.rule_name => '||p_x_rule_rec.rule_name||
                       ' p_x_rule_rec.rule_type_code => '||p_x_rule_rec.rule_type_code||
                       ' p_x_rule_rec.rule_type_meaning => '||p_x_rule_rec.rule_type_meaning||
                       ' p_rule_stmt_tbl.COUNT => '||p_rule_stmt_tbl.COUNT);
    END IF;

    -- call Convert_Rule_Values_to_Id
    Convert_Rule_Values_to_Id(p_x_rule_rec, 'I');

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_x_rule_rec.mc_header_id => '||p_x_rule_rec.mc_header_id||
                       ' p_rule_rec.mc_name => '||p_x_rule_rec.mc_name||
                       ' p_rule_rec.mc_revision => '||p_x_rule_rec.mc_revision||
                       ' p_x_rule_rec.rule_name => '||p_x_rule_rec.rule_name||
                       ' p_x_rule_rec.rule_type_code => '||p_x_rule_rec.rule_type_code||
                       ' p_x_rule_rec.rule_type_meaning => '||p_x_rule_rec.rule_type_meaning||
                       ' p_rule_stmt_tbl.COUNT => '||p_rule_stmt_tbl.COUNT);
    END IF;

    -- check for UI rule stmt table
    IF (p_rule_stmt_tbl.COUNT < 1) THEN
        -- input is NULL
        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call Convert_Rule_Stmt_Values_to_Id
    Convert_Rule_Stmt_Values_to_Id(l_rule_stmt_tbl, 'I');

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'Calling private API.');
    END IF;

    -- call the private API
    AHL_MC_RULE_PVT.Insert_Rule(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        p_module              => p_module,
        p_rule_stmt_tbl       => l_rule_stmt_tbl,
        p_x_rule_rec          => p_x_rule_rec,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data
    );

    -- check for the return status
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,
                           'Raising exception with x_return_status => '||x_return_status);
        END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'After call to private API.');
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
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        Rollback to Insert_Rule_Pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Rollback to Insert_Rule_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        Rollback to Insert_Rule_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

END Insert_Rule;

------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Update_Rule
--  Type              : Public
--  Function          : Does user input validation and calls private API Update_Rule
--  Pre-reqs          :
--  Parameters        :
--
--  Update_Rule Parameters:
--       p_rule_rec      IN            AHL_MC_RULE_PVT.Rule_Rec_Type         Required
--	 p_rule_stmt_tbl IN            AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type Required
--
--  End of Comments

PROCEDURE Update_Rule (
    p_api_version         IN            NUMBER,
    p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module		  IN            VARCHAR2  := 'JSP',
    p_rule_rec            IN            AHL_MC_RULE_PVT.Rule_Rec_Type,
    p_rule_stmt_tbl       IN            AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type,
    x_return_status       OUT    NOCOPY VARCHAR2,
    x_msg_count           OUT    NOCOPY NUMBER,
    x_msg_data            OUT    NOCOPY VARCHAR2
) IS

--
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Update_Rule';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_rule_rec              AHL_MC_RULE_PVT.Rule_Rec_Type         DEFAULT p_rule_rec;
l_rule_stmt_tbl         AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type DEFAULT p_rule_stmt_tbl;
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Update_Rule_Pub;

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
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_rule_rec.rule_id => '||p_rule_rec.rule_id||
                       ' p_rule_rec.rule_name => '||p_rule_rec.rule_name||
                       ' p_rule_rec.object_version_number => '||p_rule_rec.object_version_number||
                       ' p_rule_rec.mc_header_id => '||p_rule_rec.mc_header_id||
                       ' p_rule_rec.mc_name => '||p_rule_rec.mc_name||
                       ' p_rule_rec.mc_revision => '||p_rule_rec.mc_revision||
                       ' p_rule_stmt_tbl.COUNT => '||p_rule_stmt_tbl.COUNT);
    END IF;

    -- check input parameters
    IF (p_rule_rec.object_version_number IS NULL) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_OBJ_VER_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call Convert_Rule_Values_to_Id
    Convert_Rule_Values_to_Id(l_rule_rec, 'U');

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_rule_rec.rule_id => '||l_rule_rec.rule_id||
                       ' p_rule_rec.rule_name => '||l_rule_rec.rule_name||
                       ' p_rule_rec.object_version_number => '||l_rule_rec.object_version_number||
                       ' p_rule_rec.mc_header_id => '||l_rule_rec.mc_header_id||
                       ' p_rule_rec.mc_name => '||l_rule_rec.mc_name||
                       ' p_rule_rec.mc_revision => '||l_rule_rec.mc_revision||
                       ' p_rule_stmt_tbl.COUNT => '||p_rule_stmt_tbl.COUNT);
    END IF;

    -- check for UI rule stmt table
    IF (p_rule_stmt_tbl.COUNT < 1) THEN
        -- input is NULL
        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call Convert_Rule_Stmt_Values_to_Id
    Convert_Rule_Stmt_Values_to_Id(l_rule_stmt_tbl, 'U');

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'Calling private API.');
    END IF;

    -- call the private API
    AHL_MC_RULE_PVT.Update_Rule(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        p_module              => p_module,
        p_rule_rec            => l_rule_rec,
        p_rule_stmt_tbl       => l_rule_stmt_tbl,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data
    );

    -- check for the return status
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,
                           'Raising exception with x_return_status => '||x_return_status);
        END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'After call to private API.');
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
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        Rollback to Update_Rule_Pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Rollback to Update_Rule_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        Rollback to Update_Rule_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

END Update_Rule;

------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Delete_Rule
--  Type              : Public
--  Function          : Does user input validation and calls private API Delete_Rule
--  Pre-reqs          :
--  Parameters        :
--
--  Delete_Rule Parameters:
--       p_rule_rec.rule_id                 IN    NUMBER     Required
--                                          or
--       p_rule_rec.rule_name               IN    VARCHAR2   Required
--       p_rule_rec.mc_header_id            IN    NUMBER     Required
--       (                                  or
--       p_rule_rec.mc_name                 IN    VARCHAR2   Required
--       p_rule_rec.mc_revision             IN    NUMBER     Required)
--
--	 p_rule_rec.object_version_number   IN    NUMBER     Required
--
--  End of Comments

PROCEDURE Delete_Rule (
    p_api_version         IN             NUMBER,
    p_init_msg_list       IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_rule_rec            IN             AHL_MC_RULE_PVT.Rule_Rec_Type,
    x_return_status       OUT    NOCOPY  VARCHAR2,
    x_msg_count           OUT    NOCOPY  NUMBER,
    x_msg_data            OUT    NOCOPY  VARCHAR2
) IS

--
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Rule';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_rule_rec              AHL_MC_RULE_PVT.Rule_Rec_Type DEFAULT p_rule_rec;
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Delete_Rule_Pub;

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
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_rule_rec.rule_id => '||p_rule_rec.rule_id||
                       ' p_rule_rec.object_version_number => '||p_rule_rec.object_version_number||
                       ' p_rule_rec.rule_name => '||p_rule_rec.rule_name||
                       ' p_rule_rec.mc_header_id => '||p_rule_rec.mc_header_id||
                       ' p_rule_rec.mc_name => '||p_rule_rec.mc_name||
                       ' p_rule_rec.mc_revision => '||p_rule_rec.mc_revision);
    END IF;

    -- check input parameters
    IF (p_rule_rec.object_version_number IS NULL) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_OBJ_VER_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call Convert_Rule_Values_to_Id
    Convert_Rule_Values_to_Id(l_rule_rec, 'D');

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_rule_rec.rule_id => '||l_rule_rec.rule_id||
                       ' p_rule_rec.object_version_number => '||l_rule_rec.object_version_number||
                       ' p_rule_rec.rule_name => '||l_rule_rec.rule_name||
                       ' p_rule_rec.mc_header_id => '||l_rule_rec.mc_header_id||
                       ' p_rule_rec.mc_name => '||l_rule_rec.mc_name||
                       ' p_rule_rec.mc_revision => '||l_rule_rec.mc_revision);
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'Calling private API.');
    END IF;

    -- call the private API
    AHL_MC_RULE_PVT.Delete_Rule(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        p_rule_rec            => l_rule_rec,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data
    );

    -- check for the return status
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,
                           'Raising exception with x_return_status => '||x_return_status);
        END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'After call to private API.');
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
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        Rollback to Delete_Rule_Pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Rollback to Delete_Rule_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        Rollback to Delete_Rule_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

END Delete_Rule;

------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Copy_Rules_For_MC
--  Type              : Public
--  Function          : Does user input validation and calls private API Copy_Rules_For_MC
--  Pre-reqs          :
--  Parameters        :
--
--  Copy_Rules_For_MC Parameters:
--       p_from_mc_header_id   IN    NUMBER     Required
--                             or
--       p_to_mc_name          IN    VARCHAR2   Required
--       p_to_revision         IN    NUMBER     Required
--
--	 p_to_mc_header_id     IN    NUMBER     Required
--                             or
--       p_from_mc_name        IN    VARCHAR2   Required
--       p_from_revision       IN    NUMBER     Required
--
--  End of Comments

PROCEDURE Copy_Rules_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_from_mc_header_id	  IN           NUMBER,
    p_to_mc_header_id	  IN           NUMBER,
    p_from_mc_name        IN           VARCHAR2,
    p_from_revision         IN           VARCHAR2,
    p_to_mc_name          IN           VARCHAR2,
    p_to_revision           IN           VARCHAR2,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2
) IS

CURSOR chk_mc_header_id_csr (p_mc_header_id NUMBER) IS
    SELECT 'X'
    FROM   AHL_MC_HEADERS_B
    WHERE  mc_header_id = p_mc_header_id;

CURSOR chk_mc_name_csr (p_mc_name VARCHAR2, p_revision VARCHAR2) IS
    SELECT mc_header_id
    FROM   AHL_MC_HEADERS_B
    WHERE  name     = p_mc_name
    AND    revision = p_revision;
--
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Copy_Rules_For_MC';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_from_mc_header_id     NUMBER;
l_to_mc_header_id       NUMBER;
l_dummy                 VARCHAR2(1);
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Copy_Rules_For_MC_Pub;

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
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_from_mc_header_id => '||p_from_mc_header_id||
                       ' p_to_mc_header_id => '||p_to_mc_header_id||
                       ' p_from_mc_name => '||p_from_mc_name||
                       ' p_to_mc_name => '||p_to_mc_name||
                       ' p_from_revision => '||p_from_revision||
                       ' p_to_revision => '||p_to_revision);
    END IF;

    -- check input parameters
    -- checking for from MC
    IF (p_from_mc_header_id IS NULL) THEN
        -- check with mc_name and revision
        IF (p_from_mc_name IS NULL) OR (p_from_revision IS NULL) THEN
            -- input is NULL
            FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            OPEN chk_mc_name_csr(p_from_mc_name, p_from_revision);
            FETCH chk_mc_name_csr INTO l_from_mc_header_id;

            IF (chk_mc_name_csr%NOTFOUND) THEN
                CLOSE chk_mc_name_csr;
                -- input is invalid
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NAME_INV');
                FND_MESSAGE.Set_Token('MC_NAME',p_from_mc_name);
                FND_MESSAGE.Set_Token('MC_REV',p_from_revision);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE chk_mc_name_csr;
        END IF;
    ELSE
        -- check with mc_header_id
        OPEN chk_mc_header_id_csr(p_from_mc_header_id);
        FETCH chk_mc_header_id_csr INTO l_dummy;

        IF (chk_mc_header_id_csr%NOTFOUND) THEN
            CLOSE chk_mc_header_id_csr;
            -- input is invalid
            FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_HDR_ID_INV');
            FND_MESSAGE.Set_Token('MC_ID',p_from_mc_header_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_from_mc_header_id := p_from_mc_header_id;
        CLOSE chk_mc_header_id_csr;
    END IF;

    -- checking for to MC
    IF (p_to_mc_header_id IS NULL) THEN
        -- check with mc_name and revision
        IF (p_to_mc_name IS NULL) OR (p_to_revision IS NULL) THEN
            -- input is NULL
            FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            OPEN chk_mc_name_csr(p_to_mc_name, p_to_revision);
            FETCH chk_mc_name_csr INTO l_to_mc_header_id;

            IF (chk_mc_name_csr%NOTFOUND) THEN
                CLOSE chk_mc_name_csr;
                -- input is invalid
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NAME_INV');
                FND_MESSAGE.Set_Token('MC_NAME',p_to_mc_name);
                FND_MESSAGE.Set_Token('MC_REV',p_to_revision);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE chk_mc_name_csr;
        END IF;
    ELSE
        -- check with mc_header_id
        OPEN chk_mc_header_id_csr(p_to_mc_header_id);
        FETCH chk_mc_header_id_csr INTO l_dummy;

        IF (chk_mc_header_id_csr%NOTFOUND) THEN
            CLOSE chk_mc_header_id_csr;
            -- input is invalid
            FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_HDR_ID_INV');
            FND_MESSAGE.Set_Token('MC_ID',p_to_mc_header_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_to_mc_header_id := p_to_mc_header_id;
        CLOSE chk_mc_header_id_csr;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_from_mc_header_id => '||l_from_mc_header_id||
                       ' p_to_mc_header_id => '||l_to_mc_header_id||
                       ' p_from_mc_name => '||p_from_mc_name||
                       ' p_to_mc_name => '||p_to_mc_name||
                       ' p_from_revision => '||p_from_revision||
                       ' p_to_revision => '||p_to_revision);
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'Calling private API.');
    END IF;

    -- call the private API
    AHL_MC_RULE_PVT.Copy_Rules_For_MC(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        p_from_mc_header_id   => l_from_mc_header_id,
        p_to_mc_header_id     => l_to_mc_header_id,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data
    );

    -- check for the return status
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,
                           'Raising exception with x_return_status => '||x_return_status);
        END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'After call to private API.');
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
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        Rollback to Copy_Rules_For_MC_Pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Rollback to Copy_Rules_For_MC_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        Rollback to Copy_Rules_For_MC_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

END Copy_Rules_For_MC;

--------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Delete_Rules_For_MC
--  Type              : Public
--  Function          : Does user input validation and calls private API Delete_Rules_For_MC
--  Pre-reqs          :
--  Parameters        :
--
--  Delete_Rules_For_MC Parameters:
--       p_mc_header_id   IN    NUMBER     Required
--                        or
--       p_mc_name        IN    VARCHAR2   Required
--       p_revision       IN    NUMBER     Required
--
--  End of Comments

PROCEDURE Delete_Rules_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_mc_header_id	  IN 	       NUMBER,
    p_mc_name             IN           VARCHAR2,
    p_revision              IN           VARCHAR2,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2
) IS

CURSOR chk_mc_header_id_csr (p_mc_header_id NUMBER) IS
    SELECT 'X'
    FROM   AHL_MC_HEADERS_B
    WHERE  mc_header_id = p_mc_header_id;

CURSOR chk_mc_name_csr (p_mc_name VARCHAR2, p_revision VARCHAR2) IS
    SELECT mc_header_id
    FROM   AHL_MC_HEADERS_B
    WHERE  name     = p_mc_name
    AND    revision = p_revision;
--
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Rules_For_MC';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_mc_header_id          NUMBER;
l_dummy                 VARCHAR2(1);
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Delete_Rules_For_MC_Pub;

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
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_mc_header_id => '||p_mc_header_id||
                       ' p_mc_name => '||p_mc_name||
                       ' p_revision => '||p_revision);
    END IF;

    -- check input parameters
    IF (p_mc_header_id IS NULL) THEN
        -- check with mc_name and revision
        IF (p_mc_name IS NULL) OR (p_revision IS NULL) THEN
            -- input is NULL
            FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            OPEN chk_mc_name_csr(p_mc_name, p_revision);
            FETCH chk_mc_name_csr INTO l_mc_header_id;

            IF (chk_mc_name_csr%NOTFOUND) THEN
                CLOSE chk_mc_name_csr;
                -- input is invalid
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NAME_INV');
                FND_MESSAGE.Set_Token('MC_NAME',p_mc_name);
                FND_MESSAGE.Set_Token('MC_REV',p_revision);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE chk_mc_name_csr;
        END IF;
    ELSE
        -- check with mc_header_id
        OPEN chk_mc_header_id_csr(p_mc_header_id);
        FETCH chk_mc_header_id_csr INTO l_dummy;

        IF (chk_mc_header_id_csr%NOTFOUND) THEN
            CLOSE chk_mc_header_id_csr;
            -- input is invalid
            FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_HDR_ID_INV');
            FND_MESSAGE.Set_Token('MC_ID',p_mc_header_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_mc_header_id := p_mc_header_id;
        CLOSE chk_mc_header_id_csr;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_mc_header_id => '||l_mc_header_id||
                       ' p_mc_name => '||p_mc_name||
                       ' p_revision => '||p_revision);
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'Calling private API.');
    END IF;

    -- call the private API
    AHL_MC_RULE_PVT.Delete_Rules_For_MC(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        p_mc_header_id        => l_mc_header_id,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data
    );

    -- check for the return status
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,
                           'Raising exception with x_return_status => '||x_return_status);
        END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'After call to private API.');
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
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        Rollback to Delete_Rules_For_MC_Pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Rollback to Delete_Rules_For_MC_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        Rollback to Delete_Rules_For_MC_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

END Delete_Rules_For_MC;

-----------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Get_Rules_For_Position
--  Type              : Public
--  Function          : Does user input validation and calls private API Get_Rules_For_Position
--  Pre-reqs          :
--  Parameters        :
--
--  Get_Rules_For_Position Parameters:
--       p_encoded_path          IN  VARCHAR2                       Required
--
--	 p_mc_header_id	         IN  NUMBER                         Required
--                               or
--       p_mc_name               IN  VARCHAR2                       Required
--       p_revision              IN  NUMBER                         Required
--
--       x_rule_tbl              OUT AHL_MC_RULE_PVT.Rule_Tbl_Type  Required
--
--  End of Comments

PROCEDURE Get_Rules_For_Position (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_mc_header_id        IN           NUMBER,
    p_encoded_path        IN           VARCHAR2,
    p_mc_name             IN           VARCHAR2,
    p_revision              IN           VARCHAR2,
    x_rule_tbl		  OUT  NOCOPY  AHL_MC_RULE_PVT.Rule_Tbl_Type,
    x_return_status       OUT  NOCOPY  VARCHAR2,
    x_msg_count           OUT  NOCOPY  NUMBER,
    x_msg_data            OUT  NOCOPY  VARCHAR2
) IS

CURSOR chk_mc_header_id_csr (p_mc_header_id NUMBER) IS
    SELECT 'X'
    FROM   AHL_MC_HEADERS_B
    WHERE  mc_header_id = p_mc_header_id;

CURSOR chk_mc_name_csr (p_mc_name VARCHAR2, p_revision VARCHAR2) IS
    SELECT mc_header_id
    FROM   AHL_MC_HEADERS_B
    WHERE  name     = p_mc_name
    AND    revision = p_revision;
--
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Get_Rules_For_Position';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_mc_header_id          NUMBER;
l_dummy                 VARCHAR2(1);
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT Get_Rules_For_Position_Pub;

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
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_mc_header_id => '||p_mc_header_id||
                       ' p_encoded_path => '||p_encoded_path||
                       ' p_mc_name => '||p_mc_name||
                       ' p_revision => '||p_revision);
    END IF;

    -- check input parameters
    IF (p_encoded_path IS NULL) THEN
        -- encoded path cant be NULL
        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_PATH_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (p_mc_header_id IS NULL) THEN
        -- check with mc_name and revision
        IF (p_mc_name IS NULL) OR (p_revision IS NULL) THEN
            -- input is NULL
            FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            OPEN chk_mc_name_csr(p_mc_name, p_revision);
            FETCH chk_mc_name_csr INTO l_mc_header_id;

            IF (chk_mc_name_csr%NOTFOUND) THEN
                CLOSE chk_mc_name_csr;
                -- input is invalid
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NAME_INV');
                FND_MESSAGE.Set_Token('MC_NAME',p_mc_name);
                FND_MESSAGE.Set_Token('MC_REV',p_revision);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE chk_mc_name_csr;
        END IF;
    ELSE
        -- check with mc_header_id
        OPEN chk_mc_header_id_csr(p_mc_header_id);
        FETCH chk_mc_header_id_csr INTO l_dummy;

        IF (chk_mc_header_id_csr%NOTFOUND) THEN
            CLOSE chk_mc_header_id_csr;
            -- input is invalid
            FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_HDR_ID_INV');
            FND_MESSAGE.Set_Token('MC_ID',p_mc_header_id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_mc_header_id := p_mc_header_id;
        CLOSE chk_mc_header_id_csr;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_mc_header_id => '||l_mc_header_id||
                       ' p_encoded_path => '||p_encoded_path||
                       ' p_mc_name => '||p_mc_name||
                       ' p_revision => '||p_revision);
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'Calling private API.');
    END IF;

    -- call the private API
    AHL_MC_RULE_PVT.Get_Rules_For_Position(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        p_mc_header_id        => l_mc_header_id,
        p_encoded_path	      => p_encoded_path,
        x_rule_tbl            => x_rule_tbl,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data
    );

    -- check for the return status
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,
                           'Raising exception with x_return_status => '||x_return_status);
        END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,'After call to private API.');
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' x_rule_tbl.COUNT => '||x_rule_tbl.COUNT);
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
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        Rollback to Get_Rules_For_Position_Pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Rollback to Get_Rules_For_Position_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        Rollback to Get_Rules_For_Position_Pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

END Get_Rules_For_Position;

-----------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Convert_Rule_Values_to_Id
--  Type              : Local
--  Function          : Does user input validation and value to id conversion
--  Pre-reqs          :
--  Parameters        :
--
--  Convert_Rule_Values_to_Id Parameters:
--       p_x_rule_rec        IN OUT    AHL_MC_RULE_PVT.Rule_Rec_Type
--
--  End of Comments

PROCEDURE Convert_Rule_Values_to_Id (
    p_x_rule_rec          IN OUT NOCOPY  AHL_MC_RULE_PVT.Rule_Rec_Type,
    p_operation_flag      IN             VARCHAR2
) IS

CURSOR chk_mc_header_id_csr (p_mc_header_id NUMBER) IS
    SELECT 'X'
    FROM   AHL_MC_HEADERS_B
    WHERE  mc_header_id = p_mc_header_id;

CURSOR chk_mc_name_csr (p_mc_name VARCHAR2, p_revision VARCHAR2) IS
    SELECT mc_header_id
    FROM   AHL_MC_HEADERS_B
    WHERE  name     = p_mc_name
    AND    revision = p_revision;

CURSOR chk_rule_id_csr (p_rule_id NUMBER) IS
    SELECT 'X'
    FROM   AHL_MC_RULES_B
    WHERE  rule_id = p_rule_id;

CURSOR chk_rule_name_csr (p_rule_name VARCHAR2, p_mc_header_id NUMBER) IS
    SELECT rule_id
    FROM   AHL_MC_RULES_B
    WHERE  rule_name    = p_rule_name
    AND    mc_header_id = p_mc_header_id;

CURSOR chk_lookup_code_csr (p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS
    SELECT 'X'
    FROM   FND_LOOKUPS
    WHERE  lookup_type = p_lookup_type
    AND    lookup_code = p_lookup_code;
--
l_api_name     CONSTANT VARCHAR2(30) := 'Convert_Rule_Values_to_Id';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_rule_rec              AHL_MC_RULE_PVT.Rule_Rec_Type DEFAULT p_x_rule_rec;
l_rule_id               NUMBER;
l_mc_header_id          NUMBER;
l_rule_type_code        FND_LOOKUPS.LOOKUP_CODE%TYPE;
l_return_val            BOOLEAN;
l_dummy                 VARCHAR2(1);
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_statement,l_full_name,
                       ' p_operation_flag => '||p_operation_flag);
    END IF;

    -- for insertion
    IF (p_operation_flag = 'I')THEN
        -- check for mc_header_id
        IF (l_rule_rec.mc_header_id IS NULL) THEN
            -- check with mc_name and revision
            IF (l_rule_rec.mc_name IS NULL) OR (l_rule_rec.mc_revision IS NULL) THEN
                -- input is NULL
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NULL');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                OPEN chk_mc_name_csr(l_rule_rec.mc_name, l_rule_rec.mc_revision);
                FETCH chk_mc_name_csr INTO l_mc_header_id;

                IF (chk_mc_name_csr%NOTFOUND) THEN
                    CLOSE chk_mc_name_csr;
                    -- input is invalid
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NAME_INV');
                    FND_MESSAGE.Set_Token('MC_NAME',l_rule_rec.mc_name);
                    FND_MESSAGE.Set_Token('MC_REV',l_rule_rec.mc_revision);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- set the mc_header_id
                l_rule_rec.mc_header_id := l_mc_header_id;
                CLOSE chk_mc_name_csr;
            END IF;
        ELSE
            -- check with mc_header_id
            OPEN chk_mc_header_id_csr(l_rule_rec.mc_header_id);
            FETCH chk_mc_header_id_csr INTO l_dummy;

            IF (chk_mc_header_id_csr%NOTFOUND) THEN
                CLOSE chk_mc_header_id_csr;
                -- input is invalid
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_HDR_ID_INV');
                FND_MESSAGE.Set_Token('MC_ID',l_rule_rec.mc_header_id);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE chk_mc_header_id_csr;
        END IF;

        -- check for rule_type_code
        IF (l_rule_rec.rule_type_code IS NULL) THEN
            -- check for rule_type_meaning
            IF (l_rule_rec.rule_type_meaning IS NULL) THEN
                -- input is NULL
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_TYPE_NULL');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                -- convert the meaning into code
                AHL_UTIL_MC_PKG.Convert_To_LookupCode(
                    p_lookup_type    => 'AHL_MC_RULE_TYPES',
                    p_lookup_meaning => l_rule_rec.rule_type_meaning,
                    x_lookup_code    => l_rule_type_code,
                    x_return_val     => l_return_val
                );

                IF (l_return_val) THEN
                    -- set the rule_type_code
                    l_rule_rec.rule_type_code := l_rule_type_code;
                ELSE
                    -- input is invalid
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_TYPE_INV');
                    FND_MESSAGE.Set_Token('RULE_TYPE',l_rule_rec.rule_type_meaning);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;
        ELSE
            -- check with rule_type_code
            OPEN chk_lookup_code_csr('AHL_MC_RULE_TYPES', l_rule_rec.rule_type_code);
            FETCH chk_lookup_code_csr INTO l_dummy;

            IF (chk_lookup_code_csr%NOTFOUND) THEN
                CLOSE chk_lookup_code_csr;
                -- input is invalid
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_TYPE_INV');
                FND_MESSAGE.Set_Token('RULE_TYPE',l_rule_rec.rule_type_code);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE chk_lookup_code_csr;
        END IF;
    END IF;

    -- for updation and deletion
    IF (p_operation_flag = 'D') OR (p_operation_flag = 'U') THEN
        -- check for rule_id
        IF (l_rule_rec.rule_id IS NULL) THEN
            -- check with rule_name and mc_header_id
            IF (l_rule_rec.rule_name IS NOT NULL) THEN
                -- check for mc_header_id
                IF (l_rule_rec.mc_header_id IS NOT NULL) THEN
                    OPEN chk_rule_name_csr(l_rule_rec.rule_name, l_rule_rec.mc_header_id);
                    FETCH chk_rule_name_csr INTO l_rule_id;

                    IF (chk_rule_name_csr%NOTFOUND) THEN
                        CLOSE chk_rule_name_csr;
                        -- input is invalid
                        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_RL_NAME_INV');
                        FND_MESSAGE.Set_Token('RULE_NAME',l_rule_rec.rule_name);
                        FND_MESSAGE.Set_Token('MC_ID',l_rule_rec.mc_header_id);
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    -- set the rule_id
                    l_rule_rec.rule_id := l_rule_id;
                    CLOSE chk_rule_name_csr;
                ELSE
                    -- check with mc_name and revision
                    IF (l_rule_rec.mc_name IS NULL) OR (l_rule_rec.mc_revision IS NULL) THEN
                        -- input is NULL
                        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NULL');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    ELSE
                        OPEN chk_mc_name_csr(l_rule_rec.mc_name, l_rule_rec.mc_revision);
                        FETCH chk_mc_name_csr INTO l_mc_header_id;

                        IF (chk_mc_name_csr%NOTFOUND) THEN
                            CLOSE chk_mc_name_csr;
                            -- input is invalid
                            FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_NAME_INV');
                            FND_MESSAGE.Set_Token('MC_NAME',l_rule_rec.mc_name);
                            FND_MESSAGE.Set_Token('MC_REV',l_rule_rec.mc_revision);
                            FND_MSG_PUB.ADD;
                            RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        -- set the mc_header_id
                        l_rule_rec.mc_header_id := l_mc_header_id;
                        CLOSE chk_mc_name_csr;

                        -- get the rule_id from rule_name and mc_header_id
                        OPEN chk_rule_name_csr(l_rule_rec.rule_name, l_rule_rec.mc_header_id);
                        FETCH chk_rule_name_csr INTO l_rule_id;

                        IF (chk_rule_name_csr%NOTFOUND) THEN
                            CLOSE chk_rule_name_csr;
                            -- input is invalid
                            FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_RL_NAME_INV');
                            FND_MESSAGE.Set_Token('RULE_NAME',l_rule_rec.rule_name);
                            FND_MESSAGE.Set_Token('MC_ID',l_rule_rec.mc_header_id);
                            FND_MSG_PUB.ADD;
                            RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        -- set the rule_id
                        l_rule_rec.rule_id := l_rule_id;
                        CLOSE chk_rule_name_csr;
                    END IF;
                END IF;
            ELSE
                -- input is NULL
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_RL_NULL');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        ELSE
            -- check with rule_id
            OPEN chk_rule_id_csr(l_rule_rec.rule_id);
            FETCH chk_rule_id_csr INTO l_dummy;

            IF (chk_rule_id_csr%NOTFOUND) THEN
                CLOSE chk_rule_id_csr;
                -- input is invalid
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_RL_ID_INV');
                FND_MESSAGE.Set_Token('RULE_ID',l_rule_rec.rule_id);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE chk_rule_id_csr;
        END IF;
    END IF;

    -- return changed record
    p_x_rule_rec := l_rule_rec;

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

END Convert_Rule_Values_to_Id;

-----------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Convert_Rule_Stmt_Values_to_Id
--  Type              : Local
--  Function          : Does user input validation and value to id conversion
--  Pre-reqs          :
--  Parameters        :
--
--  Convert_Rule_Stmt_Values_to_Id Parameters:
--       p_x_ui_rule_stmt_tbl IN OUT    AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type
--
--  End of Comments

PROCEDURE Convert_Rule_Stmt_Values_to_Id (
    p_x_ui_rule_stmt_tbl IN OUT NOCOPY    AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type,
    p_operation_flag     IN               VARCHAR2
) IS

CURSOR chk_item_id_csr (p_item_id NUMBER) IS
    SELECT 'X'
    FROM   MTL_SYSTEM_ITEMS_B KFV
    WHERE  inventory_item_id = p_item_id
    AND    EXISTS
           (SELECT 'X'
            FROM   MTL_PARAMETERS MP
            WHERE  MP.master_organization_id = KFV.organization_id
            AND    MP.eam_enabled_flag       = 'Y');

CURSOR chk_item_name_csr (p_item_name VARCHAR2) IS
    SELECT inventory_item_id
    FROM   MTL_SYSTEM_ITEMS_KFV KFV
    WHERE  concatenated_segments = p_item_name
    AND    EXISTS
           (SELECT 'X'
            FROM   MTL_PARAMETERS MP
            WHERE  MP.master_organization_id = KFV.organization_id
            AND    MP.eam_enabled_flag       = 'Y');

CURSOR chk_mc_id_csr (p_mc_id NUMBER) IS
    SELECT 'X'
    FROM   AHL_MC_HEADERS_B
    WHERE  mc_id = p_mc_id;

CURSOR chk_mc_name_csr (p_mc_name VARCHAR2) IS
    SELECT mc_id
    FROM   AHL_MC_HEADERS_B
    WHERE  name = p_mc_name;

CURSOR chk_rule_stmt_id_csr (p_rule_stmt_id NUMBER) IS
    SELECT 'X'
    FROM   AHL_MC_RULE_STATEMENTS
    WHERE  rule_statement_id = p_rule_stmt_id;

CURSOR chk_lookup_code_csr (p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS
    SELECT 'X'
    FROM   FND_LOOKUPS
    WHERE  lookup_type = p_lookup_type
    AND    lookup_code = p_lookup_code;
--
l_api_name     CONSTANT VARCHAR2(30) := 'Convert_Rule_Stmt_Values_to_Id';
l_full_name    CONSTANT VARCHAR2(60) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

l_item_id               NUMBER;
l_mc_id                 NUMBER;
l_ui_rule_stmt_tbl      AHL_MC_RULE_PVT.UI_Rule_Stmt_Tbl_Type DEFAULT p_x_ui_rule_stmt_tbl;
l_rule_operator         FND_LOOKUPS.LOOKUP_CODE%TYPE;
l_rule_rule_operator    FND_LOOKUPS.LOOKUP_CODE%TYPE;
l_rule_object_type      FND_LOOKUPS.LOOKUP_CODE%TYPE;
l_return_val            BOOLEAN;
l_dummy                 VARCHAR2(1);
l_flag                  VARCHAR2(1)  := 'N';
--

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    FOR i IN l_ui_rule_stmt_tbl.FIRST..l_ui_rule_stmt_tbl.LAST LOOP
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,
                           ' i => '||i||
                           ' l_ui_rule_stmt_tbl(i).rule_statement_id => '||l_ui_rule_stmt_tbl(i).rule_statement_id||
                           ' l_ui_rule_stmt_tbl(i).rule_stmt_obj_ver_num => '||l_ui_rule_stmt_tbl(i).rule_stmt_obj_ver_num||
                           ' l_ui_rule_stmt_tbl(i).operator => '||l_ui_rule_stmt_tbl(i).operator||
                           ' l_ui_rule_stmt_tbl(i).operator_meaning => '||l_ui_rule_stmt_tbl(i).operator_meaning||
                           ' l_ui_rule_stmt_tbl(i).rule_operator => '||l_ui_rule_stmt_tbl(i).rule_operator||
                           ' l_ui_rule_stmt_tbl(i).rule_operator_meaning => '||l_ui_rule_stmt_tbl(i).rule_operator_meaning||
                           ' l_ui_rule_stmt_tbl(i).object_type => '||l_ui_rule_stmt_tbl(i).object_type||
                           ' l_ui_rule_stmt_tbl(i).object_type_meaning => '||l_ui_rule_stmt_tbl(i).object_type_meaning||
                           ' l_ui_rule_stmt_tbl(i).object_id => '||l_ui_rule_stmt_tbl(i).object_id||
                           ' l_ui_rule_stmt_tbl(i).object_meaning => '||l_ui_rule_stmt_tbl(i).object_meaning);
        END IF;

        -- for updation, check for rule stmt id and object version number
        IF (p_operation_flag = 'U')THEN
            IF (l_ui_rule_stmt_tbl(i).rule_statement_id IS NULL) THEN
                -- input is NULL
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_ID_NULL');
                FND_MSG_PUB.ADD;
                l_flag := 'Y';
            ELSE
                -- check with the rule stmt id
                OPEN chk_rule_stmt_id_csr(l_ui_rule_stmt_tbl(i).rule_statement_id);
                FETCH chk_rule_stmt_id_csr INTO l_dummy;

                IF (chk_rule_stmt_id_csr%NOTFOUND) THEN
                    -- input is invalid
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_ID_INV');
                    FND_MESSAGE.Set_Token('RULE_STMT_ID',l_ui_rule_stmt_tbl(i).rule_statement_id);
                    FND_MSG_PUB.ADD;
                    l_flag := 'Y';
                END IF;

                CLOSE chk_rule_stmt_id_csr;
            END IF;

            IF (l_ui_rule_stmt_tbl(i).rule_stmt_obj_ver_num IS NULL) THEN
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_OBJ_VER_NULL');
                FND_MSG_PUB.ADD;
                l_flag := 'Y';
            END IF;
        END IF;

        -- check for operator
        IF (l_ui_rule_stmt_tbl(i).operator IS NULL) THEN
            -- check for operator_meaning
            IF (l_ui_rule_stmt_tbl(i).operator_meaning IS NULL) THEN
                -- input is NULL
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_STMT_OPER_NULL');
                FND_MSG_PUB.ADD;
                l_flag := 'Y';
            ELSE
                -- convert the meaning into code
                AHL_UTIL_MC_PKG.Convert_To_LookupCode(
                    p_lookup_type    => 'AHL_MC_RULE_ALL_OPERATORS',
                    p_lookup_meaning => l_ui_rule_stmt_tbl(i).operator_meaning,
                    x_lookup_code    => l_rule_operator,
                    x_return_val     => l_return_val
                );

                IF (l_return_val) THEN
                    -- set the operator
                    l_ui_rule_stmt_tbl(i).operator := l_rule_operator;
                ELSE
                    -- input is invalid
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_OPR_INV');
                    FND_MESSAGE.Set_Token('OPR',l_ui_rule_stmt_tbl(i).operator_meaning);
                    FND_MSG_PUB.ADD;
                    l_flag := 'Y';
                END IF;
            END IF;
        ELSE
            -- check with operator
            OPEN chk_lookup_code_csr('AHL_MC_RULE_ALL_OPERATORS', l_ui_rule_stmt_tbl(i).operator);
            FETCH chk_lookup_code_csr INTO l_dummy;

            IF (chk_lookup_code_csr%NOTFOUND) THEN
                -- input is invalid
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_OPR_INV');
                FND_MESSAGE.Set_Token('OPR',l_ui_rule_stmt_tbl(i).operator);
                FND_MSG_PUB.ADD;
                l_flag := 'Y';
            END IF;

            CLOSE chk_lookup_code_csr;
        END IF;

        -- check for rule_operator
        IF (l_ui_rule_stmt_tbl(i).rule_operator IS NULL) THEN
            -- check for rule_operator_meaning
            IF (l_ui_rule_stmt_tbl(i).rule_operator_meaning IS NOT NULL) THEN
                -- convert the meaning into code
                AHL_UTIL_MC_PKG.Convert_To_LookupCode(
                    p_lookup_type    => 'AHL_MC_RULE_OPERATORS',
                    p_lookup_meaning => l_ui_rule_stmt_tbl(i).rule_operator_meaning,
                    x_lookup_code    => l_rule_rule_operator,
                    x_return_val     => l_return_val
                );

                IF (l_return_val) THEN
                    -- set the rule_operator
                    l_ui_rule_stmt_tbl(i).rule_operator := l_rule_rule_operator;
                ELSE
                    -- input is invalid
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_RL_OPR_INV');
                    FND_MESSAGE.Set_Token('RL_OPR',l_ui_rule_stmt_tbl(i).rule_operator_meaning);
                    FND_MSG_PUB.ADD;
                    l_flag := 'Y';
                END IF;
            END IF;
        ELSE
            -- check with rule_operator
            OPEN chk_lookup_code_csr('AHL_MC_RULE_OPERATORS', l_ui_rule_stmt_tbl(i).rule_operator);
            FETCH chk_lookup_code_csr INTO l_dummy;

            IF (chk_lookup_code_csr%NOTFOUND) THEN
                -- input is invalid
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_RL_OPR_INV');
                FND_MESSAGE.Set_Token('RL_OPR',l_ui_rule_stmt_tbl(i).rule_operator);
                FND_MSG_PUB.ADD;
                l_flag := 'Y';
            END IF;

            CLOSE chk_lookup_code_csr;
        END IF;

        -- check for object_type
        IF (l_ui_rule_stmt_tbl(i).object_type IS NULL) THEN
            -- check for object_type_meaning
            IF (l_ui_rule_stmt_tbl(i).object_type_meaning IS NOT NULL) THEN
                -- convert the meaning into code
                AHL_UTIL_MC_PKG.Convert_To_LookupCode(
                    p_lookup_type    => 'AHL_MC_RULE_OBJECT_TYPES',
                    p_lookup_meaning => l_ui_rule_stmt_tbl(i).object_type_meaning,
                    x_lookup_code    => l_rule_object_type,
                    x_return_val     => l_return_val
                );

                IF (l_return_val) THEN
                    -- set the object_type
                    l_ui_rule_stmt_tbl(i).object_type := l_rule_object_type;
                ELSE
                    -- input is invalid
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_OBJ_TYPE_INV');
                    FND_MESSAGE.Set_Token('OBJ_TYPE',l_ui_rule_stmt_tbl(i).object_type_meaning);
                    FND_MSG_PUB.ADD;
                    l_flag := 'Y';
                END IF;
            END IF;
        ELSE
            -- check with object_type
            OPEN chk_lookup_code_csr('AHL_MC_RULE_OBJECT_TYPES', l_ui_rule_stmt_tbl(i).object_type);
            FETCH chk_lookup_code_csr INTO l_dummy;

            IF (chk_lookup_code_csr%NOTFOUND) THEN
                -- input is invalid
                FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_OBJ_TYPE_INV');
                FND_MESSAGE.Set_Token('OBJ_TYPE',l_ui_rule_stmt_tbl(i).object_type);
                FND_MSG_PUB.ADD;
                l_flag := 'Y';
            END IF;

            CLOSE chk_lookup_code_csr;
        END IF;

        -- if object_type is 'ITEM'
        -- check for object_id
        IF (l_ui_rule_stmt_tbl(i).object_type = 'ITEM') THEN
            IF (l_ui_rule_stmt_tbl(i).object_id IS NULL) THEN
                -- check for object_meaning
                IF (l_ui_rule_stmt_tbl(i).object_meaning IS NULL) THEN
                    -- input is NULL
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_ITM_NULL');
                    FND_MSG_PUB.ADD;
                    l_flag := 'Y';
                ELSE
                    OPEN chk_item_name_csr(l_ui_rule_stmt_tbl(i).object_meaning);
                    FETCH chk_item_name_csr INTO l_item_id;

                    IF (chk_item_name_csr%NOTFOUND) THEN
                        -- input is invalid
                        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_ITM_NAME_INV');
                        FND_MESSAGE.Set_Token('ITM_NAME',l_ui_rule_stmt_tbl(i).object_meaning);
                        FND_MSG_PUB.ADD;
                        l_flag := 'Y';
                    END IF;

                    -- set the object_id
                    l_ui_rule_stmt_tbl(i).object_id := l_item_id;
                    CLOSE chk_item_name_csr;
                END IF;
            ELSE
                -- check with object_id
                OPEN chk_item_id_csr (l_ui_rule_stmt_tbl(i).object_id);
                FETCH chk_item_id_csr INTO l_dummy;

                IF (chk_item_id_csr%NOTFOUND) THEN
                    -- input is invalid
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_ITM_ID_INV');
                    FND_MESSAGE.Set_Token('ITM_ID',l_ui_rule_stmt_tbl(i).object_id);
                    FND_MSG_PUB.ADD;
                    l_flag := 'Y';
                END IF;

                CLOSE chk_item_id_csr;
            END IF;
        END IF;

        -- if object_type is 'CONFIGURATION'
        -- check for object_id
        IF (l_ui_rule_stmt_tbl(i).object_type = 'CONFIGURATION') THEN
            IF (l_ui_rule_stmt_tbl(i).object_id IS NULL) THEN
                -- check for object_meaning
                IF (l_ui_rule_stmt_tbl(i).object_meaning IS NULL) THEN
                    -- input is NULL
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_ID_NULL');
                    FND_MSG_PUB.ADD;
                    l_flag := 'Y';
                ELSE
                    OPEN chk_mc_name_csr(l_ui_rule_stmt_tbl(i).object_meaning);
                    FETCH chk_mc_name_csr INTO l_mc_id;

                    IF (chk_mc_name_csr%NOTFOUND) THEN
                        -- input is invalid
                        FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_ID_NAME_INV');
                        FND_MESSAGE.Set_Token('MC_NAME',l_ui_rule_stmt_tbl(i).object_meaning);
                        FND_MSG_PUB.ADD;
                        l_flag := 'Y';
                    END IF;

                    -- set the object_id
                    l_ui_rule_stmt_tbl(i).object_id := l_mc_id;
                    CLOSE chk_mc_name_csr;
                END IF;
            ELSE
                -- check with object_id
                OPEN chk_mc_id_csr (l_ui_rule_stmt_tbl(i).object_id);
                FETCH chk_mc_id_csr INTO l_dummy;

                IF (chk_mc_id_csr%NOTFOUND) THEN
                    -- input is invalid
                    FND_MESSAGE.Set_Name('AHL','AHL_MC_RULE_MC_ID_INV');
                    FND_MESSAGE.Set_Token('MC_ID',l_ui_rule_stmt_tbl(i).object_id);
                    FND_MSG_PUB.ADD;
                    l_flag := 'Y';
                END IF;

                CLOSE chk_mc_id_csr;
            END IF;
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement,l_full_name,
                           ' i => '||i||
                           ' l_ui_rule_stmt_tbl(i).rule_statement_id => '||l_ui_rule_stmt_tbl(i).rule_statement_id||
                           ' l_ui_rule_stmt_tbl(i).rule_stmt_obj_ver_num => '||l_ui_rule_stmt_tbl(i).rule_stmt_obj_ver_num||
                           ' l_ui_rule_stmt_tbl(i).operator => '||l_ui_rule_stmt_tbl(i).operator||
                           ' l_ui_rule_stmt_tbl(i).operator_meaning => '||l_ui_rule_stmt_tbl(i).operator_meaning||
                           ' l_ui_rule_stmt_tbl(i).rule_operator => '||l_ui_rule_stmt_tbl(i).rule_operator||
                           ' l_ui_rule_stmt_tbl(i).rule_operator_meaning => '||l_ui_rule_stmt_tbl(i).rule_operator_meaning||
                           ' l_ui_rule_stmt_tbl(i).object_type => '||l_ui_rule_stmt_tbl(i).object_type||
                           ' l_ui_rule_stmt_tbl(i).object_type_meaning => '||l_ui_rule_stmt_tbl(i).object_type_meaning||
                           ' l_ui_rule_stmt_tbl(i).object_id => '||l_ui_rule_stmt_tbl(i).object_id||
                           ' l_ui_rule_stmt_tbl(i).object_meaning => '||l_ui_rule_stmt_tbl(i).object_meaning);
        END IF;

        -- raise the exception if some error occurred
        IF (l_flag = 'Y') THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END LOOP;

    -- return changed record
    p_x_ui_rule_stmt_tbl := l_ui_rule_stmt_tbl;

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

END Convert_Rule_Stmt_Values_to_Id;

End AHL_MC_RULE_PUB;

/
