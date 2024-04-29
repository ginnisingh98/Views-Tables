--------------------------------------------------------
--  DDL for Package Body OKC_REP_CONTRACT_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_CONTRACT_SEARCH_PVT" AS
/* $Header: OKCVREPSRCHB.pls 120.1 2005/08/22 10:01:22 dzima noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_REP_CONTRACT_SEARCH_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKC';
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';

  -- Contract Statuses
  G_STATUS_PENDING_APPROVAL    CONSTANT   VARCHAR2(30) :=  'PENDING_APPROVAL';
  G_STATUS_SIGNED              CONSTANT   VARCHAR2(30) :=  'SIGNED';
  G_STATUS_TERMINATED          CONSTANT   VARCHAR2(30) :=  'TERMINATED';
  G_ACTION_SUBMITTED           CONSTANT   VARCHAR2(30) :=  'SUBMITTED';

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';

  G_APPROVAL_ITEM_TYPE         CONSTANT   VARCHAR2(200) := 'OKCREPAP';
  G_APPROVAL_PROCESS           CONSTANT   VARCHAR2(200) := 'REP_CONTRACT_APPROVAL';
  G_APPLICATION_ID			       CONSTANT   NUMBER := 510;

  G_RETURN_CODE_SUCCESS     CONSTANT NUMBER := 0;
  G_RETURN_CODE_WARNING     CONSTANT NUMBER := 1;
  G_RETURN_CODE_ERROR       CONSTANT NUMBER := 2;

  G_CONTRACTS_ALL_INDEX     CONSTANT VARCHAR2(32) := G_APP_NAME || '.okc_rep_contracts_all_ctx';
  G_CONTRACT_VERS_INDEX     CONSTANT VARCHAR2(32) := G_APP_NAME || '.okc_rep_contract_vers_ctx';

  ------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ------------------------------------------------------------------------------
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

-- Start of comments
--API name      : update_text_index
--Type          : Private.
--Function      : Updates Repository text index.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments

  PROCEDURE update_text_index(
  p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2)
  IS
    l_api_version NUMBER;
    l_api_name    VARCHAR2(32);
  BEGIN
    x_return_status := FND_API.G_RET_STS_ERROR;

    l_api_name    := 'update_text_index';
    l_api_version := 1.0;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE||l_api_name,
        'Entering OKC_REP_CONTRACT_SEARCH_PVT.update_text_index');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    ad_ctx_ddl.set_effective_schema(G_APP_NAME);

    ad_ctx_ddl.sync_index(G_CONTRACTS_ALL_INDEX);
    ad_ctx_ddl.sync_index(G_CONTRACT_VERS_INDEX);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE||l_api_name,
        'Leaving OKC_REP_CONTRACT_SEARCH_PVT.syncronize_text_index');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(
          FND_LOG.LEVEL_EXCEPTION,
          G_MODULE || l_api_name,
          'Leaving update_text_index because of EXCEPTION: ' || SQLERRM);
      END IF;
      Okc_Api.Set_Message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_UNEXPECTED_ERROR,
        p_token1       => G_SQLCODE_TOKEN,
        p_token1_value => SQLCODE,
        p_token2       => G_SQLERRM_TOKEN,
        p_token2_value => SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
      );
  END;

-- Start of comments
--API name      : optimize_text_index
--Type          : Private.
--Function      : Optimizes Repository text index.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments

  PROCEDURE optimize_text_index(
  p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2)
  IS
    l_api_version NUMBER;
    l_api_name    VARCHAR2(32);
  BEGIN
    l_api_name    := 'optimize_text_index';
    l_api_version := 1.0;
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE||l_api_name,
        'Entering OKC_REP_CONTRACT_SEARCH_PVT.optimize_text_index');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    ad_ctx_ddl.set_effective_schema(G_APP_NAME);

    ad_ctx_ddl.optimize_index (
        idx_name => G_CONTRACTS_ALL_INDEX,
        optlevel => ad_ctx_ddl.OPTLEVEL_FULL,
        maxtime  => ad_ctx_ddl.MAXTIME_UNLIMITED
    );
     ad_ctx_ddl.optimize_index (
        idx_name => G_CONTRACT_VERS_INDEX,
        optlevel => ad_ctx_ddl.OPTLEVEL_FULL,
        maxtime  => ad_ctx_ddl.MAXTIME_UNLIMITED
    );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE||l_api_name,
        'Leaving OKC_REP_CONTRACT_SEARCH_PVT.optimize_text_index');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(
          FND_LOG.LEVEL_EXCEPTION,
          G_MODULE || l_api_name,
          'Leaving optimize_text_index because of EXCEPTION: ' || SQLERRM);
      END IF;
      Okc_Api.Set_Message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_UNEXPECTED_ERROR,
        p_token1       => G_SQLCODE_TOKEN,
        p_token1_value => SQLCODE,
        p_token2       => G_SQLERRM_TOKEN,
        p_token2_value => SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
      );
  END;

-- Start of comments
--API name      : update_text_index_ctx
--Type          : Private.
--Function      : Called from Concurrent Manager to update
--                Repository text index
--Pre-reqs      : None.
--Parameters    :
--OUT           : errbuf  OUT NOCOPY VARCHAR2
--              : retcode OUT NOCOPY VARCHAR2
--Note          :
-- End of comments

  PROCEDURE update_text_index_ctx(
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER
  )
  IS
    l_api_version   NUMBER;
    l_api_name      VARCHAR2(32);
    l_init_msg_list VARCHAR2(2000);
    l_msg_data      VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_return_status VARCHAR2(2000);
  BEGIN
    retcode := G_RETURN_CODE_ERROR;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE||l_api_name,
        'Entering OKC_REP_CONTRACT_SEARCH_PVT.update_text_index_ctx');
    END IF;

    l_api_name    := 'update_text_index_ctx';
    l_api_version   := 1.0;
    l_init_msg_list := FND_API.G_FALSE;

    update_text_index(
      p_api_version   => l_api_version,
      p_init_msg_list => l_init_msg_list,
      x_msg_data      => l_msg_data,
      x_msg_count     => l_msg_count,
      x_return_status => l_return_status
    );

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      retcode := G_RETURN_CODE_SUCCESS;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE||l_api_name,
        'Leaving OKC_REP_CONTRACT_SEARCH_PVT.update_text_index_ctx');
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(
            FND_LOG.LEVEL_EXCEPTION,
            G_MODULE || l_api_name,
            'Leaving update_text_index_ctx because of EXCEPTION: ' || SQLERRM);
          errbuf := substr(SQLERRM, 1, 200);
        END IF;
  END;

-- Start of comments
--API name      : optimize_text_index_ctx
--Type          : Private.
--Function      : Called from Concurrent Manager to optimize
--                Repository text index
--Pre-reqs      : None.
--Parameters    :
--OUT           : errbuf  OUT NOCOPY VARCHAR2
--              : retcode OUT NOCOPY VARCHAR2
--Note          :
-- End of comments

  PROCEDURE optimize_text_index_ctx(
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER
  )
  IS
    l_api_version   NUMBER;
    l_api_name      VARCHAR2(32);
    l_init_msg_list VARCHAR2(2000);
    l_msg_data      VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_return_status VARCHAR2(2000);
  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE||l_api_name,
        'Entering OKC_REP_CONTRACT_SEARCH_PVT.optimize_text_index_ctx');
    END IF;

    retcode := G_RETURN_CODE_ERROR;

    l_api_name    := 'optimize_text_index_ctx';
    l_api_version   := 1.0;
    l_init_msg_list := FND_API.G_FALSE;

    optimize_text_index(
      p_api_version   => l_api_version,
      p_init_msg_list => l_init_msg_list,
      x_msg_data      => l_msg_data,
      x_msg_count     => l_msg_count,
      x_return_status => l_return_status
    );

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      retcode := G_RETURN_CODE_SUCCESS;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE||l_api_name,
        'Leaving OKC_REP_CONTRACT_SEARCH_PVT.optimize_text_index_ctx');
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(
            FND_LOG.LEVEL_EXCEPTION,
            G_MODULE || l_api_name,
            'Leaving optimize_text_index_ctx because of EXCEPTION: ' || SQLERRM);
          errbuf := substr(SQLERRM, 1, 200);
        END IF;
  END;

END;


/
