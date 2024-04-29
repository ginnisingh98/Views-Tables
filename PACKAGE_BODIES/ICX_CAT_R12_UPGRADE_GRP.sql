--------------------------------------------------------
--  DDL for Package Body ICX_CAT_R12_UPGRADE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_R12_UPGRADE_GRP" AS
/* $Header: ICXG12UB.pls 120.2 2006/08/24 00:36:46 sudsubra noship $*/

-- Constants
G_PKG_NAME      CONSTANT VARCHAR2(30):='ICX_CAT_R12_UPGRADE_GRP';

PROCEDURE updatePOHeaderId
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_interface_header_id   IN              DBMS_SQL.NUMBER_TABLE
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'updatePOHeaderId';
l_api_version                   CONSTANT NUMBER         := 1.0;
l_err_loc                       PLS_INTEGER;

BEGIN
  l_err_loc := 100;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_err_loc := 200;
  -- Standard Start of API savepoint
  SAVEPOINT updatePOHeaderId_sp;

  l_err_loc := 300;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
    l_err_loc := 400;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_err_loc := 500;
  ICX_CAT_UTIL_PVT.setCommitParameter(p_commit);

  l_err_loc := 600;
  ICX_CAT_R12_UPGRADE_PVT.updatePOHeaderId(p_interface_header_id);

  -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    l_err_loc := 700;
    COMMIT;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          '; Commit done.');
    END IF;
  ELSE
    l_err_loc := 800;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          '; Commit not done.' );
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO updatePOHeaderId_sp;
    EXCEPTION
      WHEN OTHERS THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                         ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                         'ROLLBACK TO the savepoint caused the exception -->'
                         || SQLERRM);
        END IF;
        NULL;
    END;
    raise;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END updatePOHeaderId;

PROCEDURE updatePOLineId
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_interface_line_id     IN              DBMS_SQL.NUMBER_TABLE
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'updatePOLineId';
l_api_version                   CONSTANT NUMBER         := 1.0;
l_err_loc                       PLS_INTEGER;

BEGIN
  l_err_loc := 100;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_err_loc := 200;
  -- Standard Start of API savepoint
  SAVEPOINT updatePOLineId_sp;

  l_err_loc := 300;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
    l_err_loc := 400;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_err_loc := 500;
  ICX_CAT_UTIL_PVT.setCommitParameter(p_commit);

  l_err_loc := 600;
  ICX_CAT_R12_UPGRADE_PVT.updatePOLineId(p_interface_line_id);

  l_err_loc := 700;
  -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    l_err_loc := 800;
    COMMIT;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          '; Commit done.');
    END IF;
  ELSE
    l_err_loc := 900;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          '; Commit not done.');
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO updatePOLineId_sp;
    EXCEPTION
      WHEN OTHERS THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                         ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                         'ROLLBACK TO the savepoint caused the exception -->'
                         || SQLERRM);
        END IF;
        NULL;
    END;
    raise;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END updatePOLineId;

-- Start of comments
--      API name        : createR12UpgradeJob
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : inserts a job in icx_cat_r12_upgrade_jobs
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_TRUE
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_job_type                      IN VARCHAR2     Required
--                                      Type of job to be created
--                              p_audsid                        IN NUMBER       Required
--                                      audsid for the job to be created
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE createR12UpgradeJob
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_job_type              IN              VARCHAR2,
        p_audsid                IN              NUMBER
)
IS

l_api_name                      CONSTANT VARCHAR2(30)   := 'createR12UpgradeJob';
l_api_version                   CONSTANT NUMBER         := 1.0;
l_err_loc                       PLS_INTEGER;
l_upgrade_job_number            PLS_INTEGER;


BEGIN
  l_err_loc := 100;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_err_loc := 200;
  -- Standard Start of API savepoint
  SAVEPOINT createR12UpgradeJob_sp;

  l_err_loc := 300;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
    l_err_loc := 400;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_err_loc := 500;
  ICX_CAT_UTIL_PVT.setCommitParameter(p_commit);

  l_err_loc := 600;

  l_upgrade_job_number := ICX_CAT_UTIL_PVT.getR12UpgradeJobNumber;

  l_err_loc := 620;
  -- gUserId is used in created_by which should be -12 to identify the rows created by r12 upgrade
  ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id := ICX_CAT_UTIL_PVT.g_upgrade_user;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id := ICX_CAT_UTIL_PVT.getNextSequenceForWhoColumns;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id := l_upgrade_job_number;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id := l_upgrade_job_number;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id := l_upgrade_job_number;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id := l_upgrade_job_number;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id := l_upgrade_job_number;

  l_err_loc := 630;
  ICX_CAT_UTIL_PVT.g_job_type := p_job_type;
  ICX_CAT_UTIL_PVT.g_job_number := l_upgrade_job_number;

  l_err_loc := 640;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' g_job_type:' || ICX_CAT_UTIL_PVT.g_job_type ||
        ' g_job_number:' || ICX_CAT_UTIL_PVT.g_job_number);
  END IF;

  l_err_loc := 650;
  ICX_CAT_R12_UPGRADE_PVT.createR12UpgradeJob(p_audsid);

  l_err_loc := 700;
  -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    l_err_loc := 800;
    COMMIT;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          '; Commit done.');
    END IF;
  ELSE
    l_err_loc := 900;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          '; Commit not done.');
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO createR12UpgradeJob_sp;
    EXCEPTION
      WHEN OTHERS THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                         ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                         'ROLLBACK TO the savepoint caused the exception -->'
                         || SQLERRM);
        END IF;
        NULL;
    END;
    raise;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END createR12UpgradeJob;

-- Start of comments
--      API name        : updateR12UpgradeJob
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : updates a job in icx_cat_r12_upgrade_jobs
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_TRUE
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_job_status                      IN VARCHAR2     Required
--                                      New status of the job
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE updateR12UpgradeJob
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_job_status            IN              VARCHAR2
)
IS

l_api_name                      CONSTANT VARCHAR2(30)   := 'updateR12UpgradeJob';
l_api_version                   CONSTANT NUMBER         := 1.0;
l_err_loc                       PLS_INTEGER;

BEGIN
  l_err_loc := 100;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_err_loc := 200;
  -- Standard Start of API savepoint
  SAVEPOINT updateR12UpgradeJob_sp;

  l_err_loc := 300;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (  l_api_version           ,
                                        p_api_version           ,
                                        l_api_name              ,
                                        G_PKG_NAME )
  THEN
    l_err_loc := 400;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_err_loc := 500;
  ICX_CAT_UTIL_PVT.setCommitParameter(p_commit);

  l_err_loc := 600;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' g_job_type:' || ICX_CAT_UTIL_PVT.g_job_type ||
        ' g_job_number:' || ICX_CAT_UTIL_PVT.g_job_number ||
        ' p_job_status:' || p_job_status);
  END IF;

  IF (p_job_status = g_job_complete_status) THEN
    ICX_CAT_UTIL_PVT.g_job_complete_date := SYSDATE;
  ELSE
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
  END IF;

  l_err_loc := 2400;
  ICX_CAT_R12_UPGRADE_PVT.updateR12UpgradeJob(p_job_status);

  l_err_loc := 700;
  -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    l_err_loc := 800;
    COMMIT;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          '; Commit done.');
    END IF;
  ELSE
    l_err_loc := 900;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          '; Commit not done.');
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK TO updateR12UpgradeJob_sp;
    EXCEPTION
      WHEN OTHERS THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                         ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                         'ROLLBACK TO the savepoint caused the exception -->'
                         || SQLERRM);
        END IF;
        NULL;
    END;
    raise;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END updateR12UpgradeJob;


END ICX_CAT_R12_UPGRADE_GRP;

/
