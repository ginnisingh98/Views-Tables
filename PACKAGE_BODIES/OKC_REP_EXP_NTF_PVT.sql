--------------------------------------------------------
--  DDL for Package Body OKC_REP_EXP_NTF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_EXP_NTF_PVT" AS
/* $Header: OKCVREPEXNTFB.pls 120.1.12010000.2 2011/02/15 10:59:52 nvvaidya ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PARTY_TYPE_INTERNAL        CONSTANT   VARCHAR2(12) := 'INTERNAL_ORG';
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_REP_EXP_NTF_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKC';
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';

  G_RETURN_CODE_SUCCESS     CONSTANT NUMBER := 0;
  G_RETURN_CODE_WARNING     CONSTANT NUMBER := 1;
  G_RETURN_CODE_ERROR       CONSTANT NUMBER := 2;

  ---------------------------------------------------------------------------
  -- START: Procedures and Functions
  ---------------------------------------------------------------------------

-- Start of comments
--API name      : contract_expiration_notifier
--Type          : Private.
--Function      : Iterates through contracts that are about to expire
--                and calls repository_notifier() procedure
--                for all of them. This procedure will send notifications
--                to all contract contacts.
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
PROCEDURE contract_expiration_notifier(
  p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2)

  IS

    l_api_version NUMBER;
    l_api_name    VARCHAR2(32);

    CURSOR EXPIRING_CONTRACTS IS
    SELECT
      contract_id,
      contract_number,
      contract_version_num,
      DECODE(SIGN(MONTHS_BETWEEN(contract_expiration_date, trunc(sysdate))),
        1, 'N', 'Y') AS expired_flag,
      notify_contact_role_id
    FROM  okc_rep_contracts_all
    WHERE contract_expiration_date is not null
    AND   contract_status_code = 'SIGNED'
    AND   expire_ntf_flag = 'Y'
    AND   contract_expiration_date <= trunc(sysdate) + expire_ntf_period
    AND   wf_exp_ntf_item_key IS NULL
      UNION ALL
    SELECT
      v.contract_id,
      v.contract_number,
      v.contract_version_num,
      DECODE(SIGN(MONTHS_BETWEEN(v.contract_expiration_date, trunc(sysdate))),
        1, 'N', 'Y') AS expired_flag,
      v.notify_contact_role_id
    FROM  okc_rep_contract_vers v ,okc_rep_contracts_all v2
    WHERE v.contract_status_code = 'SIGNED'
    AND   v2.contract_id = v.contract_id
    AND   v2.contract_status_code  NOT IN('SIGNED','TERMINATED','APPROVED')
    AND   v.expire_ntf_flag = 'Y'
    AND   v.contract_expiration_date <= trunc(sysdate) + v.expire_ntf_period
    AND   v.wf_exp_ntf_item_key IS NULL
    AND   v.contract_version_num = (
      SELECT  DISTINCT MAX(v1.contract_version_num)
      OVER (PARTITION BY v1.contract_id)
      FROM  okc_rep_contract_vers v1
      WHERE  v1.contract_id = v.contract_id)
      AND NOT EXISTS(
        SELECT  1
        FROM    okc_rep_contracts_all c1
        WHERE   c1.contract_id = v.contract_id
        AND     c1.contract_status_code = 'SIGNED'
        AND     c1.expire_ntf_flag = 'Y'
        AND     c1.contract_expiration_date <= TRUNC(SYSDATE) + c1.expire_ntf_period
        AND     c1.wf_exp_ntf_item_key IS NULL
      );
  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE||l_api_name,
        'Entering OKC_REP_EXP_NTF_PVT.contract_expiration_notifier');
    END IF;

    l_api_name    := 'contract_expiration_notifier';
    l_api_version := 1.0;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    FOR expiring_contracts_rec IN EXPIRING_CONTRACTS LOOP
      OKC_REP_CONTRACT_PROCESS_PVT.repository_notifier(
        p_contract_id      => expiring_contracts_rec.contract_id,
        p_contract_number  => expiring_contracts_rec.contract_number,
        p_contract_version => expiring_contracts_rec.contract_version_num,
        p_expired_flag     => expiring_contracts_rec.expired_flag,
        p_notify_contact_role_id => expiring_contracts_rec.notify_contact_role_id,
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        x_msg_data         => x_msg_data,
        x_msg_count        => x_msg_count,
        x_return_status    => x_return_status
      );
    END LOOP;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Leaving OKC_REP_EXP_NTF_PVT.contract_expiration_notifier');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(
          FND_LOG.LEVEL_EXCEPTION,
          G_MODULE || l_api_name,
          'Leaving contract_expiration_notifier:FND_API.G_EXC_ERROR Exception');
      END IF;
      --close cursors
      IF (EXPIRING_CONTRACTS%ISOPEN) THEN
        CLOSE EXPIRING_CONTRACTS ;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(
          FND_LOG.LEVEL_EXCEPTION,
          G_MODULE || l_api_name,
          'Leaving contract_expiration_notifier:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      --close cursors
      IF (EXPIRING_CONTRACTS%ISOPEN) THEN
        CLOSE EXPIRING_CONTRACTS ;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
      );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(
          FND_LOG.LEVEL_EXCEPTION,
          G_MODULE || l_api_name,
          'Leaving contract_expiration_notifier because of EXCEPTION: ' || sqlerrm);
      END IF;
      Okc_Api.Set_Message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_UNEXPECTED_ERROR,
        p_token1       => G_SQLCODE_TOKEN,
        p_token1_value => SQLCODE,
        p_token2       => G_SQLERRM_TOKEN,
        p_token2_value => SQLERRM);

      --close cursors
      IF (EXPIRING_CONTRACTS%ISOPEN) THEN
        CLOSE EXPIRING_CONTRACTS ;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
      );

END contract_expiration_notifier;

-- Start of comments
--API name      : contract_expiration_manager
--Type          : Private.
--Function      : Called from Concurrent Manager to send
--                notifications to contract contacts for
--                contracts that are about to expire
--Pre-reqs      : None.
--Parameters    :
--OUT           : errbuf  OUT NOCOPY VARCHAR2
--              : retcode OUT NOCOPY VARCHAR2
--Note          :
-- End of comments

  PROCEDURE contract_expiration_manager(
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2)
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
        'Entering OKC_REP_EXP_NTF_PVT.contract_expiration_manager');
    END IF;

    l_api_name    := 'contract_expiration_manager';
    l_api_version   := 1.0;
    l_init_msg_list := FND_API.G_FALSE;

    contract_expiration_notifier(
      p_api_version   => l_api_version,
      p_init_msg_list => l_init_msg_list,
      x_msg_data      => l_msg_data,
      x_msg_count     => l_msg_count,
      x_return_status => l_return_status
    );

    retcode := G_RETURN_CODE_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        FND_LOG.LEVEL_PROCEDURE,
        G_MODULE||l_api_name,
        'Leaving OKC_REP_EXP_NTF_PVT.contract_expiration_manager');
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(
            FND_LOG.LEVEL_EXCEPTION,
            G_MODULE || l_api_name,
            'Leaving contract_expiration_manager because of EXCEPTION: ' || SQLERRM);
          errbuf := substr(SQLERRM, 1, 200);
        END IF;

  END contract_expiration_manager;

END OKC_REP_EXP_NTF_PVT;

/
