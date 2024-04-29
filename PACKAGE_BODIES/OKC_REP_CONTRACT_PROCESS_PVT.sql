--------------------------------------------------------
--  DDL for Package Body OKC_REP_CONTRACT_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_CONTRACT_PROCESS_PVT" AS
/* $Header: OKCVREPPROCSB.pls 120.15.12010000.18 2013/06/06 10:48:11 aksgoyal ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PARTY_TYPE_INTERNAL   CONSTANT   VARCHAR2(12) := 'INTERNAL_ORG';
  G_REP_CONTRACT   CONSTANT   VARCHAR2(30) := 'OKC_REP_CONTRACT';

  ---------------------------------------------------------------------------
  -- START: Procedures and Functions
  ---------------------------------------------------------------------------

-- Start of comments
--API name      : submit_contract_for_approval
--Type          : Private.
--Function      : Submits contract for approval
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract to be submitted for approval
--              : p_contract_version    IN NUMBER       Required
--                   Contract Version of the contract to be submitted for approval
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE submit_contract_for_approval(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2,
        p_contract_id                  IN NUMBER,
        p_contract_version             IN NUMBER,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2

  ) IS
    l_api_name      VARCHAR2(30);
    l_api_version       NUMBER;
    l_user_key        wf_items.user_key%TYPE;
    l_wf_sequence       wf_items.item_key%TYPE;
    l_contract_number   OKC_REP_CONTRACTS_ALL.contract_number%TYPE;

    CURSOR contract_csr IS
        SELECT contract_number
        FROM okc_rep_contracts_all
        WHERE contract_id = p_contract_id;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_WF_PVT.submit_contract');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
    END IF;
    l_api_name := 'submit_contract_for_approval';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT submit_contract_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT OKC_REP_WF_S.nextval INTO l_wf_sequence FROM dual;
    -- Get contract number
    OPEN contract_csr;
    FETCH contract_csr into l_contract_number;
    IF(contract_csr%NOTFOUND) THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| p_contract_id);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_contract_id));
        RAISE FND_API.G_EXC_ERROR;
        -- RAISE NO_DATA_FOUND;
    END IF;
    CLOSE contract_csr;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_UTIL_PVT.change_contract_status');
    END IF;
    -- Update the contract status and add a record in OKC_REP_CON_STATUS_HIST table.
    OKC_REP_UTIL_PVT.change_contract_status(
      p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_contract_id         => p_contract_id,
      p_contract_version    => p_contract_version,
      p_status_code         => G_STATUS_PENDING_APPROVAL,
      p_user_id             => fnd_global.user_id,
      p_note                => NULL,
    x_msg_data            => x_msg_data,
      x_msg_count           => x_msg_count,
      x_return_status       => x_return_status);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_UTIL_PVT.change_contract_status return status is: '
          || x_return_status);
    END IF;
    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------------------


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_UTIL_PVT.add_approval_hist_record');
    END IF;
  -- Add a record in ONC_REP_CON_APPROVALS table.
    OKC_REP_UTIL_PVT.add_approval_hist_record(
      p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_contract_id         => p_contract_id,
      p_contract_version    => p_contract_version,
      p_action_code         => G_ACTION_SUBMITTED,
      p_user_id             => fnd_global.user_id,
      p_note                => NULL,
    x_msg_data            => x_msg_data,
      x_msg_count           => x_msg_count,
      x_return_status       => x_return_status);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_UTIL_PVT.add_approval_hist_record return status is: '
          || x_return_status);
    END IF;
    -------------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------------------
  -- Get the user key
    l_user_key := l_contract_number || ':' || l_wf_sequence;
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling WF_ENGINE.createprocess');
    END IF;
    WF_ENGINE.createprocess (
                    itemtype => G_APPROVAL_ITEM_TYPE,
                    itemkey  => l_wf_sequence,
                    process  => G_APPROVAL_PROCESS);


  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling WF_ENGINE.SetItemUserKey');
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'User key Value is: ' || l_user_key);
    END IF;
    WF_ENGINE.SetItemUserKey (
                  itemtype => G_APPROVAL_ITEM_TYPE,
                    itemkey  => l_wf_sequence,
                    userkey  => l_user_key);

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling WF_ENGINE.SetItemOwner');
    END IF;
    WF_ENGINE.SetItemOwner (
                  itemtype => G_APPROVAL_ITEM_TYPE,
                    itemkey  => l_wf_sequence,
                    owner    => fnd_global.user_name);


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling WF_ENGINE.setitemattrnumber for CONTRACT_ID');
    END IF;
    WF_ENGINE.SetItemAttrText (
                    itemtype =>  G_APPROVAL_ITEM_TYPE,
                    itemkey  =>  l_wf_sequence,
                    aname    => 'CONTRACT_ID',
                    avalue   =>  p_contract_id);

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling WF_ENGINE.startprocess for REQUESTOR');
    END IF;
    WF_ENGINE.SetItemAttrText (
                    itemtype  => G_APPROVAL_ITEM_TYPE,
                    itemkey   => l_wf_sequence,
                    aname     => 'REQUESTER',
                    avalue    => fnd_global.user_name);


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling WF_ENGINE.startprocess');
    END IF;
    WF_ENGINE.startprocess (
                    itemtype => G_APPROVAL_ITEM_TYPE,
                    itemkey  =>  l_wf_sequence);



  -- Update WF columns in OKC_REP_CONTRACTS_ALL
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Updating workflow columns in OKC_REP_CONTRACTS_ALL');
    END IF;
    UPDATE OKC_REP_CONTRACTS_ALL
    SET wf_item_type = G_APPROVAL_ITEM_TYPE, wf_item_key = l_wf_sequence
    WHERE contract_id=p_contract_id;

    COMMIT WORK;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_WF_PVT.submit_contract');
    END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving check_contract_access:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO submit_contract_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving check_contract_access:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO submit_contract_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving check_contract_access because of EXCEPTION: ' || sqlerrm);
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO submit_contract_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

  END submit_contract_for_approval;


-- Start of comments
--API name      : delete_contacts
--Type          : Private.
--Function      : Deletes party contacts of a particular Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose contacts are to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_contacts(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2) IS

    l_api_name      VARCHAR2(30);
    l_api_version       NUMBER;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.delete_contacts');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || to_char(p_contract_id));
    END IF;
    l_api_name := 'delete_contacts';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT delete_contacts_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Delete the records. The records are locked in the delete_contract API.
    DELETE FROM OKC_REP_PARTY_CONTACTS
      WHERE CONTRACT_ID = p_CONTRACT_ID;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.delete_contacts');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_contacts:FND_API.G_EXC_ERROR Exception');
        END IF;
        ROLLBACK TO delete_contacts_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_contacts:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        ROLLBACK TO delete_contacts_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_contacts because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO delete_contacts_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END delete_contacts;


-- Start of comments
--API name      : delete_parties
--Type          : Private.
--Function      : Deletes parties of a particular Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose parties are to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_parties(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit            IN  VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2) IS

    l_api_name      VARCHAR2(30);
    l_api_version       NUMBER;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.delete_parties');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
    END IF;
    l_api_name := 'delete_parties';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT delete_parties_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Delete the records. The records are locked in the delete_contract API.
    DELETE FROM OKC_REP_CONTRACT_PARTIES
      WHERE CONTRACT_ID = p_CONTRACT_ID;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.delete_parties');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_parties:FND_API.G_EXC_ERROR Exception');
        END IF;
        ROLLBACK TO delete_parties_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_parties:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        ROLLBACK TO delete_parties_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_parties because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO delete_parties_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END delete_parties;


-- Start of comments
--API name      : delete_risks
--Type          : Private.
--Function      : Deletes risks of a particular Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose risks are to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_risks(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN  VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2) IS

    l_api_name      VARCHAR2(30);
    l_api_version       NUMBER;

    CURSOR contract_csr IS
      SELECT contract_type, contract_version_num
      FROM OKC_REP_CONTRACTS_ALL
      WHERE contract_id = p_contract_id;

  contract_rec       contract_csr%ROWTYPE;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.delete_risks');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
    END IF;
    l_api_name := 'delete_risks';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT delete_risks_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get contract_type and version of the contract.
    OPEN contract_csr;
    FETCH contract_csr INTO contract_rec;
    IF(contract_csr%NOTFOUND) THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| p_contract_id);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_contract_id));
          RAISE FND_API.G_EXC_ERROR;
          -- RAISE NO_DATA_FOUND;
    END IF;
    -- Delete the records. The records are locked in the delete_contract API.
    DELETE FROM OKC_CONTRACT_RISKS
      WHERE   BUSINESS_DOCUMENT_TYPE = contract_rec.contract_type
      AND   BUSINESS_DOCUMENT_ID = p_CONTRACT_ID
        AND   BUSINESS_DOCUMENT_VERSION = contract_rec.contract_version_num;
    -- Close cursor
    CLOSE contract_csr;
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.delete_risks');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_risks:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO delete_risks_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_risks:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO delete_risks_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_risks because of EXCEPTION: ' || sqlerrm);
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO delete_risks_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END delete_risks;


-- Start of comments
--API name      : delete_related_contracts
--Type          : Private.
--Function      : Deletes related contracts of a particular Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose related contracts are to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_related_contracts(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN  VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2) IS

    l_api_name      VARCHAR2(30);
    l_api_version       NUMBER;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.delete_related_contracts');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
    END IF;
    l_api_name := 'delete_related_contracts';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT delete_related_contracts_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Delete the records. The records are locked in the delete_related_contracts API.
    DELETE FROM OKC_REP_CONTRACT_RELS
      WHERE CONTRACT_ID = p_CONTRACT_ID;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.delete_related_contracts');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_related_contracts:FND_API.G_EXC_ERROR Exception');
        END IF;
        ROLLBACK TO delete_related_contracts_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_related_contracts:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        ROLLBACK TO delete_related_contracts_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_related_contracts because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO delete_related_contracts_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END delete_related_contracts;

-- Start of comments
--API name      : delete_ACL
--Type          : Private.
--Function      : Deletes parties of a particular Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose ACL is to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_ACL(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN  VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2) IS

    l_api_name      VARCHAR2(30);
    l_api_version       NUMBER;
    x_success           VARCHAR2(1);
    x_errcode           NUMBER;

    -- Query for the cursor
    CURSOR acl_csr IS
      SELECT
        fgrant.grantee_type       grantee_type,
        fgrant.grantee_key        grantee_key,
        fgrant.instance_type      instance_type,
        fgrant.instance_set_id    instance_set_id,
        fmenu.menu_name           menu_name,
        fgrant.program_name       program_name,
        fgrant.program_tag        program_tag
      FROM FND_GRANTS fgrant, FND_OBJECTS fobj, FND_MENUS fmenu
    WHERE fgrant.menu_id = fmenu.menu_id
          AND fgrant.object_id = fobj.object_id
          AND fobj.obj_name = 'OKC_REP_CONTRACT'
          AND fgrant.instance_pk1_value = to_char(p_contract_id);

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.delete_ACL');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
    END IF;
    l_api_name := 'delete_ACL';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT delete_ACL_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR acl_rec IN acl_csr LOOP
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'grantee_type is: ' || acl_rec.grantee_type);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'grantee_key is: ' || acl_rec.grantee_key);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'instance_type is: ' || acl_rec.instance_type);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'instance_set_id is: ' || acl_rec.instance_set_id);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'menu_name is: ' || acl_rec.menu_name);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'program_name is: ' || acl_rec.program_name);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'program_tag is: ' || acl_rec.program_tag);
      END IF;
    -- call FND_GRANT's delete api
    FND_GRANTS_PKG.delete_grant(
                       p_grantee_type        => acl_rec.grantee_type,  -- USER or GROUP
                       p_grantee_key         => acl_rec.grantee_key,   -- user_id or group_id
                       p_object_name         => G_REP_CONTRACT,
                       p_instance_type       => acl_rec.instance_type, -- INSTANCE or SET
                       p_instance_set_id     => acl_rec.instance_set_id, -- Instance set id.
                       p_instance_pk1_value  => to_char(p_contract_id), -- Object PK Value
                       p_menu_name           => acl_rec.menu_name,      -- Menu to be deleted.
                       p_program_name        => acl_rec.program_name,   -- name of the program that handles grant.
                       p_program_tag         => acl_rec.program_tag,    -- tag used by the program that handles grant.
                       x_success             => x_success,              -- return param. 'T' or 'F'
                       x_errcode             => x_errcode );
      -----------------------------------------------------
      IF (x_success = 'F' AND x_errcode < 0 ) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_success = 'F' AND x_errcode > 0) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------
    END LOOP;
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.delete_ACL');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_ACL:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursors
        IF (acl_csr%ISOPEN) THEN
          CLOSE acl_csr ;
        END IF;
        ROLLBACK TO delete_ACL_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_ACL:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        IF (acl_csr%ISOPEN) THEN
          CLOSE acl_csr ;
        END IF;
        ROLLBACK TO delete_ACL_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_ACL because of EXCEPTION: ' || sqlerrm);
        END IF;
        IF (acl_csr%ISOPEN) THEN
          CLOSE acl_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO delete_ACL_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END delete_ACL;


-- Start of comments
--API name      : delete_status_history
--Type          : Private.
--Function      : Deletes status history records of a contract version
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose status history is to be deleted
--              : p_contract_version    IN NUMBER       Required
--                   Contract version of the contract whose status history is to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_status_history(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_contract_id       IN  NUMBER,
      p_contract_version    IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2) IS

    l_api_name      VARCHAR2(30);
    l_api_version       NUMBER;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.delete_status_history');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || to_char(p_contract_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Version is: ' || to_char(p_contract_version));
    END IF;
    l_api_name := 'delete_status_history';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT delete_status_history_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Delete the records. The records are locked in the delete_contract API.
    DELETE FROM OKC_REP_CON_STATUS_HIST
      WHERE CONTRACT_ID = p_CONTRACT_ID
    AND CONTRACT_VERSION_NUM = p_contract_version;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.delete_status_history');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_status_history:FND_API.G_EXC_ERROR Exception');
        END IF;
        ROLLBACK TO delete_status_history_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_status_history:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        ROLLBACK TO delete_status_history_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_status_history because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO delete_status_history_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END delete_status_history;





-- Start of comments
--API name      : delete_approval_history
--Type          : Private.
--Function      : Deletes contract approval history records of a contract version
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose approval history is to be deleted
--              : p_contract_version    IN NUMBER       Required
--                   Contract version of the contract whose approval history is to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_approval_history(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_contract_id       IN  NUMBER,
      p_contract_version    IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2)IS

    l_api_name      VARCHAR2(30);
    l_api_version       NUMBER;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.delete_approval_history');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || to_char(p_contract_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Version is: ' || to_char(p_contract_version));
    END IF;
    l_api_name := 'delete_approval_history';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT delete_approval_history_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Delete the records. The records are locked in the delete_contract API.
    DELETE FROM OKC_REP_CON_APPROVALS
      WHERE CONTRACT_ID = p_CONTRACT_ID
    AND CONTRACT_VERSION_NUM = p_contract_version;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.delete_approval_history');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_approval_history:FND_API.G_EXC_ERROR Exception');
        END IF;
        ROLLBACK TO delete_approval_history_PVT;
        x_return_status :=FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_approval_history:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        ROLLBACK TO delete_approval_history_PVT;
        x_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_approval_history because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO delete_approval_history_PVT;
        x_return_status :=FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END delete_approval_history;

-- Start of comments
--API name      : delete_bookmarks
--Type          : Private.
--Function      : Deletes bookmarks for a given contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_type         IN VARCHAR2       Required
--                   Contract Type of the contract whose status history is to be deleted
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract whose status history is to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_bookmarks(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit            IN VARCHAR2,
      p_contract_type     IN  VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2) IS

     l_api_name             VARCHAR2(30);
     l_api_version          NUMBER;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.delete_bookmarks');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
    END IF;
    l_api_name := 'delete_bookmarks';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT delete_bookmarks_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;



    -- Delete the records. The records are locked in the delete_contract API.
    DELETE FROM OKC_REP_BOOKMARKS
      WHERE OBJECT_TYPE = p_contract_type
    AND OBJECT_ID = p_CONTRACT_ID
      AND BOOKMARK_TYPE_CODE = G_CONTRACT_BOOKMARK_TYPE;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.delete_bookmarks');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_bookmarks:FND_API.G_EXC_ERROR Exception');
        END IF;
        ROLLBACK TO delete_bookmarks_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_bookmarks:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        ROLLBACK TO delete_bookmarks_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_bookmarks because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO delete_bookmarks_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END  delete_bookmarks;


  ---------------------------------------------------------------------------
  -- PROCEDURE Lock_Row
  ---------------------------------------------------------------------------
  -----------------------------------
  -- Lock_Row for:OKC_REP_CONTRACTS_ALL --
  -----------------------------------
  FUNCTION Lock_Contract_Header(
    p_contract_id              IN NUMBER,
    p_object_version_number    IN NUMBER
  ) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);
    l_object_version_number       OKC_REP_CONTRACTS_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    l_api_name      VARCHAR2(30);

    CURSOR lock_csr (cp_contract_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_REP_CONTRACTS_ALL
     WHERE CONTRACT_ID = cp_contract_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_contract_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_REP_CONTRACTS_ALL
     WHERE CONTRACT_ID = cp_contract_id;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered Function OKC_REP_CONTRACT_PROCESS_PVT.Lock_Contract_Header');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Object Version is: ' || p_object_version_number);
    END IF;


    BEGIN
      l_api_name := 'lock_contract_header';
      OPEN lock_csr( p_contract_id, p_object_version_number );
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

     EXCEPTION
      WHEN E_Resource_Busy THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving Function Lock_Contract_Header:E_Resource_Busy Exception');
        END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.Set_Message(G_FND_APP,G_UNABLE_TO_RESERVE_REC);
        RETURN(FND_API.G_RET_STS_ERROR );
    END;

    IF ( l_row_notfound ) THEN
      l_return_status :=FND_API.G_RET_STS_ERROR;

      OPEN lchk_csr(p_contract_id);
      FETCH lchk_csr INTO l_object_version_number;
      l_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;

      IF (l_row_notfound) THEN
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_DELETED);
      ELSIF l_object_version_number > p_object_version_number THEN
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_CHANGED);
      ELSIF l_object_version_number = -1 THEN
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      ELSE -- it can be the only above condition. It can happen after restore version
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_CHANGED);
      END IF;
     ELSE
      l_return_status :=FND_API.G_RET_STS_SUCCESS;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving Function Lock_Contract_Header');
    END IF;

    RETURN( l_return_status );

  EXCEPTION
    WHEN OTHERS THEN

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      IF (lchk_csr%ISOPEN) THEN
        CLOSE lchk_csr;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving Function Lock_Contract_Header because of EXCEPTION: '||sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN(FND_API.G_RET_STS_UNEXP_ERROR );
  END Lock_Contract_Header;


-- Start of comments
--API name      : lock_contract_header
--Type          : Private.
--Function      : Locks a row in OKC_REP_CONTRACTS_ALL table
--Pre-reqs      : None.
--Parameters    :
--IN            : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract to be locked.
--              : p_object_version_number    IN NUMBER       Required
--                   Object version number of the contract to be locked
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE Lock_Contract_Header(
    p_contract_id              IN NUMBER,
    p_object_version_number    IN NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2
   ) IS

   l_api_name       VARCHAR2(30);

  BEGIN
    l_api_name := 'Lock_Contract_header';
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.Lock_Contract_Header');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Object Version is: ' || p_object_version_number);
    END IF;

    --------------------------------------------
    -- Call the LOCK_ROW
    --------------------------------------------
    x_return_status := Lock_Contract_Header(
      p_contract_id              => p_contract_id,
      p_object_version_number    => p_object_version_number
    );
    ---------------------------------------------------------
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    ----------------------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 g_module || l_api_name,
                 'Leaving Lock_Contract_Header');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving Lock_Contract_Header:FND_API.G_EXC_ERROR Exception');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving Lock_Contract_Header:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving Lock_Contract_Header because of EXCEPTION: '||sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

  END Lock_Contract_Header;


-- Start of comments
--API name      : delete_contract
--Type          : Private.
--Function      : Deletes a Contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Contract ID of the contract to be deleted
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE delete_contract(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit            IN  VARCHAR2,
      p_contract_id       IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2) IS

    l_api_name        VARCHAR2(30);
    l_api_version           NUMBER;
    l_contract_type         OKC_REP_CONTRACTS_ALL.CONTRACT_TYPE%TYPE;
    l_prev_version          OKC_REP_CONTRACTS_ALL.CONTRACT_VERSION_NUM%TYPE;
    l_prev_con_vers_status  OKC_REP_CONTRACTS_ALL.contract_status_code%TYPE;
    l_is_activated VARCHAR2(1);


  CURSOR contract_csr IS
      SELECT contract_type, contract_version_num
      FROM OKC_REP_CONTRACTS_ALL
      WHERE contract_id = p_contract_id;

  CURSOR prev_con_vers_status (p_contract_id IN NUMBER, p_con_version IN NUMBER) IS
    SELECT contract_status_code
    FROM okc_rep_contract_vers
    WHERE  contract_id = p_contract_id
    AND    contract_version_num = p_con_version - 1;

  contract_rec       contract_csr%ROWTYPE;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.delete_contract');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
    END IF;
    l_api_name := 'delete_contract';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT delete_contract_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Calling OKC_REP_CONTRACT_PROCESS_PVT.Lock_Contract_Header()');
    END IF;
    -- Lock the contract header
    Lock_Contract_Header(
        p_contract_id              => p_contract_id,
          p_object_version_number    => NULL,
          x_return_status            => x_return_status
          );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'OKC_REP_CONTRACT_PROCESS_PVT.Lock_Contract_Header return status is: '
      || x_return_status);
    END IF;
    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------------------

    -- The contract version
    -- Get contract_type and version required for deliverables and documents APIs
    OPEN contract_csr;
        FETCH contract_csr INTO contract_rec;
        IF(contract_csr%NOTFOUND) THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| p_contract_id);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_contract_id));
          RAISE FND_API.G_EXC_ERROR;
          -- RAISE NO_DATA_FOUND;
      END IF;


    if (contract_rec.contract_version_num = 1) THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_CONTRACT_PROCESS_PVT.delete_contacts()');
      END IF;
      delete_contacts(
          p_api_version       => 1.0,
          p_commit            => FND_API.G_FALSE,
          p_init_msg_list     => FND_API.G_FALSE,
          p_contract_id       => p_contract_id,
          x_msg_data          => x_msg_data,
          x_msg_count         => x_msg_count,
          x_return_status     => x_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_CONTRACT_PROCESS_PVT.delete_contacts return status is: '
          || x_return_status);
        END IF;
      -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      -----------------------------------------------------


      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_CONTRACT_PROCESS_PVT.delete_parties()');
      END IF;
      delete_parties(
          p_api_version       => 1.0,
          p_init_msg_list     => FND_API.G_FALSE,
          p_commit            => FND_API.G_FALSE,
          p_contract_id       => p_contract_id,
          x_msg_data          => x_msg_data,
          x_msg_count         => x_msg_count,
          x_return_status     => x_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_CONTRACT_PROCESS_PVT.delete_parties return status is: '
          || x_return_status);
        END IF;
      -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------------------------


      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_CONTRACT_PROCESS_PVT.delete_risks()');
      END IF;
      delete_risks(
          p_api_version       => 1.0,
          p_init_msg_list     => FND_API.G_FALSE,
          p_commit            => FND_API.G_FALSE,
          p_contract_id       => p_contract_id,
          x_msg_data          => x_msg_data,
          x_msg_count         => x_msg_count,
          x_return_status     => x_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_CONTRACT_PROCESS_PVT.delete_risks return status is: '
          || x_return_status);
        END IF;
      -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------------------------


      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_CONTRACT_PROCESS_PVT.delete_ACL()');
      END IF;
      delete_ACL(
          p_api_version       => 1.0,
          p_init_msg_list     => FND_API.G_FALSE,
          p_commit            => FND_API.G_FALSE,
          p_contract_id       => p_contract_id,
          x_msg_data          => x_msg_data,
          x_msg_count         => x_msg_count,
          x_return_status     => x_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_CONTRACT_PROCESS_PVT.delete_ACL return status is: '
          || x_return_status);
        END IF;
      -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------------------------


      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_CONTRACT_PROCESS_PVT.delete_related_contracts()');
      END IF;
      delete_related_contracts(
          p_api_version       => 1.0,
          p_init_msg_list     => FND_API.G_FALSE,
          p_commit            => FND_API.G_FALSE,
          p_contract_id       => p_contract_id,
          x_msg_data          => x_msg_data,
          x_msg_count         => x_msg_count,
          x_return_status     => x_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_CONTRACT_PROCESS_PVT.delete_related_contracts return status is: '
          || x_return_status);
        END IF;
      -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------------------------


      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_CONTRACT_PROCESS_PVT.delete_status_history()');
      END IF;
      delete_status_history(
          p_api_version       => 1.0,
          p_init_msg_list     => FND_API.G_FALSE,
          p_commit            => FND_API.G_FALSE,
          p_contract_id       => p_contract_id,
          p_contract_version  => contract_rec.contract_version_num,
          x_msg_data          => x_msg_data,
          x_msg_count         => x_msg_count,
          x_return_status     => x_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_CONTRACT_PROCESS_PVT.delete_status_history return status is: '
          || x_return_status);
        END IF;
      -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------------------------


      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_CONTRACT_PROCESS_PVT.delete_approval_history()');
      END IF;
      delete_approval_history(
          p_api_version       => 1.0,
          p_init_msg_list     => FND_API.G_FALSE,
          p_commit            => FND_API.G_FALSE,
          p_contract_id       => p_contract_id,
          p_contract_version  => contract_rec.contract_version_num,
          x_msg_data          => x_msg_data,
          x_msg_count         => x_msg_count,
          x_return_status     => x_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_CONTRACT_PROCESS_PVT.delete_approval_history return status is: '
          || x_return_status);
        END IF;
      -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------------------------


      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_CONTRACT_PROCESS_PVT.delete_bookmarks()');
      END IF;
      delete_bookmarks(
          p_api_version       => 1.0,
          p_init_msg_list     => FND_API.G_FALSE,
          p_commit            => FND_API.G_FALSE,
          p_contract_type     => contract_rec.contract_type,
          p_contract_id       => p_contract_id,
          x_msg_data          => x_msg_data,
          x_msg_count         => x_msg_count,
          x_return_status     => x_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_CONTRACT_PROCESS_PVT.delete_bookmarks return status is: '
          || x_return_status);
        END IF;
      -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------------------------

    END IF;   --   (contract_rec.contract_version_num = 1)

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_CONTRACT_DOCS_GRP.Delete_Ver_Attachments');
    END IF;
    -- Delete Contract Documents
    -- The following package call should be uncommented once the package is compiling.
    OKC_CONTRACT_DOCS_GRP.Delete_Ver_Attachments(
        p_api_version               => 1.0,
        p_business_document_type    => contract_rec.contract_type,
        p_business_document_id      => p_contract_id,
        p_business_document_version => G_CURRENT_VERSION,
    x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
        );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_CONTRACT_DOCS_GRP.Delete_Ver_Attachments return status is : '
            || x_return_status);
    END IF;
    -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------

    IF (contract_rec.contract_version_num > 1) THEN

      -- Call this API only if the contract has previous versions
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                      'Calling OKC_CONTRACT_DOCS_PVT.reset_bus_doc_ver_to_current');
      END IF;

      -- Bug 5044121
      -- The following API will change the business document version number attribute
      -- of all the documents of the previous version to the deleted version to -99
      -- so that the UI will show documents correctly
      x_return_status := OKC_CONTRACT_DOCS_PVT.reset_bus_doc_ver_to_current(
                          p_business_document_type    => contract_rec.contract_type,
                          p_business_document_id      => p_contract_id,
                          p_business_document_version => contract_rec.contract_version_num);

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'OKC_CONTRACT_DOCS_PVT.reset_bus_doc_ver_to_current return status is : '
                  || x_return_status);
      END IF;

      -----------------------------------------------------
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
      --------------------------------------------------------

    END IF;

	-- Repository Enhancement 12.1 (For Delete Action)
	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1000: Calling Ptivate API to Delete the 		doc');
	END IF;

-- If the contract has only one version, delete the terms.
-- Otherwise the only the terms versions have to be deleted.
-- For Bug# 6902073

    IF(contract_rec.contract_version_num = 1) THEN

	OKC_TERMS_UTIL_PVT.Delete_Doc(
	       x_return_status  => x_return_status,
	       p_doc_type       => contract_rec.contract_type,
	       p_doc_id         => p_contract_id
	     );
     --------------------------------------------
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	      RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

    ELSE

-- Restore the previous version's terms details from the history table to the base tables
	OKC_TERMS_VERSION_GRP.Restore_Doc_Version(
               p_api_version => 1.0,
	       x_return_status  => x_return_status,
               x_msg_data       => x_msg_data,
               x_msg_count      => x_msg_count,
	       p_doc_type       => contract_rec.contract_type,
	       p_doc_id         => p_contract_id,
	       p_version_number => contract_rec.contract_version_num - 1
	     );
     --------------------------------------------
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	      RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;
-- Deletes the previous version's terms details in the history table
	OKC_TERMS_VERSION_PVT.Delete_Doc_Version(
	       x_return_status  => x_return_status,
	       p_doc_type       => contract_rec.contract_type,
	       p_doc_id         => p_contract_id,
	       p_version_number => contract_rec.contract_version_num - 1
	     );
     --------------------------------------------
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
	      RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

-- Changes for Bug# 6902073 Ends
     END IF;
	-- Repository Enhancement 12.1 Ends(For Delete Action)


    IF(contract_rec.contract_version_num = 1) THEN

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                  'Calling OKC_DELIVERABLE_PROCESS_PVT.delete_deliverables');
      END IF;

      -- Delete Deliverables
      OKC_DELIVERABLE_PROCESS_PVT.deleteDeliverables (
                    p_api_version         => 1.0,
                    p_init_msg_list       => FND_API.G_FALSE,
                    p_bus_doc_id          => p_contract_id,
                    p_bus_doc_type        => contract_rec.contract_type,
                    p_bus_doc_version     => G_CURRENT_VERSION,
                    x_return_status       => x_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data);

    ELSE

      -- Get previous contract version status
      OPEN prev_con_vers_status(p_contract_id, contract_rec.contract_version_num);
      FETCH prev_con_vers_status INTO l_prev_con_vers_status;
      CLOSE prev_con_vers_status;

      IF (l_prev_con_vers_status = G_STATUS_SIGNED) THEN
        l_is_activated := 'Y';
      ELSE
        l_is_activated := 'N';
      END IF;

      OKC_DELIVERABLE_PROCESS_PVT.deleteDeliverables(
              p_api_version     => 1.0,
              p_init_msg_list   => FND_API.G_FALSE,
              p_bus_doc_id      => p_contract_id,
              p_bus_doc_type    => contract_rec.contract_type,
              p_bus_doc_version => contract_rec.contract_version_num,
              p_prev_del_active => l_is_activated,
              p_revert_dels     => 'Y',
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data);

    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'OKC_DELIVERABLE_PROCESS_PVT.deleteDeliverables return status is : '
            || x_return_status);
    END IF;

    -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Deleting Contract header record');
    END IF;
    -- Delete contract header from the main header table OKC_REP_CONTRACTS_ALL
    DELETE FROM OKC_REP_CONTRACTS_ALL
    WHERE contract_id = p_contract_id;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Deleted Contract header record');
    END IF;
    -- If Version > 1, copy the latest version from the archive table.
    if (contract_rec.contract_version_num > 1) THEN
        l_prev_version := contract_rec.contract_version_num - 1;
        INSERT INTO OKC_REP_CONTRACTS_ALL(
            CONTRACT_ID,
            CONTRACT_VERSION_NUM,
            CONTRACT_NUMBER,
            CONTRACT_TYPE,
            CONTRACT_STATUS_CODE,
            ORG_ID,
            OWNER_ID,
            SOURCE_LANGUAGE,
            CONTRACT_NAME,
            CONTRACT_DESC,
            VERSION_COMMENTS,
            AUTHORING_PARTY_CODE,
            CONTRACT_EFFECTIVE_DATE,
            CONTRACT_EXPIRATION_DATE,
            CURRENCY_CODE,
            AMOUNT,
            OVERALL_RISK_CODE,
            CANCELLATION_COMMENTS,
            CANCELLATION_DATE,
            TERMINATION_COMMENTS,
            TERMINATION_DATE,
            KEYWORDS,
            PHYSICAL_LOCATION,
            EXPIRE_NTF_FLAG,
            EXPIRE_NTF_PERIOD,
            NOTIFY_CONTACT_ROLE_ID,
            WF_EXP_NTF_ITEM_KEY,
            USE_ACL_FLAG,
            WF_ITEM_TYPE,
            WF_ITEM_KEY,
            PROGRAM_ID,
            PROGRAM_LOGIN_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            LATEST_SIGNED_VER_NUMBER,
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
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            CONTRACT_LAST_UPDATED_BY,
            CONTRACT_LAST_UPDATE_DATE,
            REFERENCE_DOCUMENT_TYPE,
	    REFERENCE_DOCUMENT_NUMBER)
      SELECT
            CONTRACT_ID,
            CONTRACT_VERSION_NUM,
            CONTRACT_NUMBER,
            CONTRACT_TYPE,
            CONTRACT_STATUS_CODE,
            ORG_ID,
            OWNER_ID,
            SOURCE_LANGUAGE,
            CONTRACT_NAME,
            CONTRACT_DESC,
            VERSION_COMMENTS,
            AUTHORING_PARTY_CODE,
            CONTRACT_EFFECTIVE_DATE,
            CONTRACT_EXPIRATION_DATE,
            CURRENCY_CODE,
            AMOUNT,
            OVERALL_RISK_CODE,
            CANCELLATION_COMMENTS,
            CANCELLATION_DATE,
            TERMINATION_COMMENTS,
            TERMINATION_DATE,
            KEYWORDS,
            PHYSICAL_LOCATION,
            EXPIRE_NTF_FLAG,
            EXPIRE_NTF_PERIOD,
            NOTIFY_CONTACT_ROLE_ID,
            WF_EXP_NTF_ITEM_KEY,
            USE_ACL_FLAG,
            WF_ITEM_TYPE,
            WF_ITEM_KEY,
            PROGRAM_ID,
            PROGRAM_LOGIN_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            LATEST_SIGNED_VER_NUMBER,
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
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            CONTRACT_LAST_UPDATED_BY,
            CONTRACT_LAST_UPDATE_DATE,
            REFERENCE_DOCUMENT_TYPE,
            REFERENCE_DOCUMENT_NUMBER
        FROM OKC_REP_CONTRACT_VERS
        WHERE contract_id = p_contract_id
              AND contract_version_num = l_prev_version;

        -- Also, we need to delete this history table record that has been copied to
        -- the main table
        DELETE FROM OKC_REP_CONTRACT_VERS
          WHERE contract_id = p_contract_id
              AND contract_version_num = l_prev_version;
    END IF;  --  (contract_rec.contract_version_num > 1)

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    CLOSE contract_csr;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.delete_contract');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_contract:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO delete_contract_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_contract:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO delete_contract_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving delete_contract because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO delete_contract_PVT;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END delete_contract;


-- Start of comments
--API name      : copy_contacts
--Type          : Private.
--Function      : Copies party contacts of source contract to target contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_source_contract_id         IN NUMBER       Required
--                   Id of the contract whose contacts are to be copied
--              : p_target_contract_id         IN NUMBER       Required
--                   Id of the contract to which source contacts are to be copied
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE copy_contacts(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_source_contract_id  IN  NUMBER,
      p_target_contract_id  IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2)  IS

    l_api_name        VARCHAR2(30);
    l_api_version           NUMBER;
    l_created_by            OKC_REP_PARTY_CONTACTS.CREATED_BY%TYPE;
    l_creation_date         OKC_REP_PARTY_CONTACTS.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_REP_PARTY_CONTACTS.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_REP_PARTY_CONTACTS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_REP_PARTY_CONTACTS.LAST_UPDATE_DATE%TYPE;

    -- Contact cursor.
    CURSOR contact_csr IS
      SELECT *
      FROM OKC_REP_PARTY_CONTACTS
      WHERE contract_id = p_source_contract_id;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.copy_contacts');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Source Contract Id is: ' || to_char(p_source_contract_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Target Contract Id is: ' || to_char(p_target_contract_id));
    END IF;
    l_api_name := 'copy_contacts';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT copy_contacts_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Populate who columns
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;

    FOR contact_rec IN contact_csr LOOP
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party Id is: ' || contact_rec.party_id);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party Role Code is: ' || contact_rec.party_role_code);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contact Id is: ' || contact_rec.contact_id);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contact Role Code is: ' || contact_rec.contact_role_id);
      END IF;
    -- INSERT THE NEW RECORDS into OKC_REP_PARTY_CONTACTS table

    INSERT INTO OKC_REP_PARTY_CONTACTS (
        CONTRACT_ID,
        PARTY_ID,
        PARTY_ROLE_CODE,
        CONTACT_ID,
        CONTACT_ROLE_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    VALUES(
        p_target_contract_id,
        contact_rec.PARTY_ID,
        contact_rec.PARTY_ROLE_CODE,
        contact_rec.CONTACT_ID,
        contact_rec.CONTACT_ROLE_ID,
        1,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login);
    END LOOP;
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.copy_contacts');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_contacts:FND_API.G_EXC_ERROR Exception');
        END IF;
        ROLLBACK TO copy_contacts_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_contacts:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        ROLLBACK TO copy_contacts_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_contacts because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO copy_contacts_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END copy_contacts;


-- Start of comments
--API name      : copy_parties
--Type          : Private.
--Function      : Copies parties of source contract to target contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_source_contract_id         IN NUMBER       Required
--                   Id of the contract whose parties are to be copied
--              : p_target_contract_id         IN NUMBER       Required
--                   Id of the contract to which source parties are to be copied
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE copy_parties(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_source_contract_id  IN  NUMBER,
      p_target_contract_id  IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2) IS

    l_api_name        VARCHAR2(30);
    l_api_version         NUMBER;
    l_created_by            OKC_REP_CONTRACT_PARTIES.CREATED_BY%TYPE;
    l_creation_date         OKC_REP_CONTRACT_PARTIES.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_REP_CONTRACT_PARTIES.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_REP_CONTRACT_PARTIES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_REP_CONTRACT_PARTIES.LAST_UPDATE_DATE%TYPE;

    -- Contact cursor.
    CURSOR party_csr IS
      SELECT *
      FROM OKC_REP_CONTRACT_PARTIES
      WHERE contract_id = p_source_contract_id;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.copy_parties');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Source Contract Id is: ' || to_char(p_source_contract_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Target Contract Id is: ' || to_char(p_target_contract_id));
    END IF;
    l_api_name := 'copy_parties';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT copy_parties_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Populate who columns
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;

    FOR party_rec IN party_csr LOOP
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party Id is: ' || party_rec.party_id);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party Role Code is: ' || party_rec.party_role_code);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Party Location ID is: ' || party_rec.party_location_id);
      END IF;
    -- INSERT THE NEW RECORDS into OKC_REP_CONTRACT_PARTIES table
    INSERT INTO OKC_REP_CONTRACT_PARTIES (
        CONTRACT_ID,
        PARTY_ID,
        PARTY_ROLE_CODE,
        PARTY_LOCATION_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    VALUES(
        p_target_contract_id,
        party_rec.PARTY_ID,
        party_rec.PARTY_ROLE_CODE,
        party_rec.PARTY_LOCATION_ID,
        1,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login);
    END LOOP;
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.copy_parties');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_parties:FND_API.G_EXC_ERROR Exception');
        END IF;
        ROLLBACK TO copy_parties_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_parties:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        ROLLBACK TO copy_parties_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_parties because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO copy_parties_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END copy_parties;


-- Start of comments
--API name      : copy_risks
--Type          : Private.
--Function      : Copies risks of source contract to target contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_source_contract_id         IN NUMBER       Required
--                   Id of the contract whose risks are to be copied
--              : p_target_contract_id         IN NUMBER       Required
--                   Id of the contract to which source contract risks are to be copied
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE copy_risks(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_source_contract_id  IN  NUMBER,
      p_target_contract_id  IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2) IS

     l_api_name         VARCHAR2(30);
    l_api_version            NUMBER;
    l_created_by            OKC_CONTRACT_RISKS.CREATED_BY%TYPE;
    l_creation_date         OKC_CONTRACT_RISKS.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_CONTRACT_RISKS.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_CONTRACT_RISKS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_CONTRACT_RISKS.LAST_UPDATE_DATE%TYPE;
    -- l_contract_risk_id      OKC_CONTRACT_RISKS.CONTRACT_RISK_ID%TYPE;


    -- Contact cursor.
    CURSOR risk_csr(doc_type VARCHAR2, doc_id NUMBER) IS
      SELECT *
      FROM OKC_CONTRACT_RISKS
      WHERE business_document_type = doc_type
      AND   business_document_id = doc_id;

    -- Contract cursor to get contract_type and version
    CURSOR contract_csr IS
      SELECT contract_type, contract_version_num
      FROM OKC_REP_CONTRACTS_ALL
      WHERE contract_id = p_source_contract_id;

  contract_rec       contract_csr%ROWTYPE;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.copy_risks');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Source Contract Id is: ' || to_char(p_source_contract_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Target Contract Id is: ' || to_char(p_target_contract_id));
    END IF;
    l_api_name := 'copy_risks';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT copy_risks_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Populate who columns
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;

    -- Get Contract type and version number columns
    -- Get effective dates and version of the contract.
    OPEN contract_csr;
    FETCH contract_csr INTO contract_rec;
    IF(contract_csr%NOTFOUND) THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| p_source_contract_id);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_source_contract_id));
          RAISE FND_API.G_EXC_ERROR;
          -- RAISE NO_DATA_FOUND;
    END IF;


    FOR risk_rec IN risk_csr(contract_rec.contract_type, p_source_contract_id) LOOP
      -- Get the id column.
      -- SELECT OKC_CONTRACT_RISKS_S.nextval INTO l_contract_risk_id FROM dual;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract Type is: ' || contract_rec.CONTRACT_TYPE);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract Id is: ' || risk_rec.BUSINESS_DOCUMENT_ID);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Contract Version is: ' || contract_rec.CONTRACT_VERSION_NUM);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Risk Event ID is: ' || risk_rec.RISK_EVENT_ID);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Probability code is: ' || risk_rec.PROBABILITY_CODE);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Impact Code is: ' || risk_rec.IMPACT_CODE);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Risk Occurred Flag is: ' || risk_rec.RISK_OCCURRED_FLAG);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Occurence Date is: ' || to_char(risk_rec.OCCURRENCE_DATE));
      END IF;
    -- INSERT THE NEW RECORDS into OKC_CONTRACT_RISKS table
    INSERT INTO OKC_CONTRACT_RISKS (
        -- CONTRACT_RISK_ID,
        BUSINESS_DOCUMENT_TYPE,
        BUSINESS_DOCUMENT_ID,
        BUSINESS_DOCUMENT_VERSION,
        RISK_EVENT_ID,
        PROBABILITY_CODE,
        IMPACT_CODE,
        COMMENTS,
        RISK_OCCURRED_FLAG,
        OCCURRENCE_DATE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
    VALUES(
        -- l_contract_risk_id,
        --risk_rec.CONTRACT_ID,
        contract_rec.contract_type,
        p_target_contract_id,
        risk_rec.BUSINESS_DOCUMENT_VERSION,
        risk_rec.RISK_EVENT_ID,
        risk_rec.PROBABILITY_CODE,
        risk_rec.IMPACT_CODE,
        risk_rec.COMMENTS,
        risk_rec.RISK_OCCURRED_FLAG,
        risk_rec.OCCURRENCE_DATE,
        1,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_date,
        l_last_update_login);
    END LOOP;
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.copy_risks');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_risks:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO copy_risks_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_risks:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO copy_risks_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_risks because of EXCEPTION: ' || sqlerrm);
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO copy_risks_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END copy_risks;


  -- Start of comments
--API name      : copy_ACL
--Type          : Private.
--Function      : Copies ACL records from source contract to target contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_source_contract_id         IN NUMBER       Required
--                   Id of the contract whose ACLs are to be copied
--              : p_target_contract_id         IN NUMBER       Required
--                   Id of the contract to which source contract ACL are to be copied
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE copy_ACL(
      p_api_version       IN  NUMBER,
      p_init_msg_list     IN  VARCHAR2,
      p_commit              IN VARCHAR2,
      p_source_contract_id  IN  NUMBER,
      p_target_contract_id  IN  NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2)IS

     l_api_name          VARCHAR2(30);
     l_api_version       NUMBER;
     x_success           VARCHAR2(1);
     x_errorcode         NUMBER;
     x_grant_guid        RAW(16);


    CURSOR acl_csr IS
      SELECT
        fgrant.grantee_type       grantee_type,
        fgrant.grantee_key        grantee_key,
        fgrant.instance_type      instance_type,
        fgrant.instance_set_id    instance_set_id,
        fmenu.menu_name           menu_name,
        fgrant.program_name       program_name,
        fgrant.program_tag        program_tag,
        fgrant.parameter1         parameter1,
        fgrant.parameter2         parameter2,
        fgrant.parameter3         parameter3
      FROM FND_GRANTS fgrant, FND_OBJECTS fobj, FND_MENUS fmenu
      WHERE fgrant.menu_id = fmenu.menu_id
          AND fgrant.object_id = fobj.object_id
          AND fobj.obj_name = 'OKC_REP_CONTRACT'
          AND fgrant.instance_pk1_value = to_char(p_source_contract_id);

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.copy_ACL');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Source Contract Id is: ' || p_source_contract_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Target Contract Id is: ' || p_target_contract_id);
    END IF;
    l_api_name := 'copy_ACL';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT copy_ACL_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR acl_rec IN acl_csr LOOP
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'grantee_type is: ' || acl_rec.grantee_type);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'grantee_key is: ' || acl_rec.grantee_key);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'instance_type is: ' || acl_rec.instance_type);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'instance_set_id is: ' || acl_rec.instance_set_id);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'menu_name is: ' || acl_rec.menu_name);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'program_name is: ' || acl_rec.program_name);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'program_tag is: ' || acl_rec.program_tag);
      END IF;
    -- call FND_GRANT's delete api
    FND_GRANTS_PKG.grant_function(
                       p_api_version         => 1.0,
                       p_menu_name           => acl_rec.menu_name, -- Menu to be deleted.
                       p_object_name         => G_REP_CONTRACT,
                       p_instance_type       => acl_rec.instance_type, -- INSTANCE or SET
                       p_instance_set_id     => acl_rec.instance_set_id, -- Instance set id.
                       p_instance_pk1_value  => to_char(p_target_contract_id), -- Object PK Value
                       p_grantee_type        => acl_rec.grantee_type,  -- USER or GROUP
                       p_grantee_key         => acl_rec.grantee_key,   -- user_id or group_id
                       p_start_date          => sysdate,
                       p_end_date            => null,
             p_program_name        => acl_rec.program_name,   -- name of the program that handles grant.
                       p_program_tag         => acl_rec.program_tag,    -- tag used by the program that handles grant.
                       p_parameter1          => acl_rec.parameter1,     -- resource type
                       p_parameter2          => acl_rec.parameter2,     -- resource id
                       p_parameter3          => acl_rec.parameter3,     -- access type
                       x_grant_guid          => x_grant_guid,
                       x_success             => x_success,              -- return param. 'T' or 'F'
                       x_errorcode             => x_errorcode );
      -----------------------------------------------------
      IF (x_success = 'F' AND x_errorcode < 0 ) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_success = 'F' AND x_errorcode > 0) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------
    END LOOP;
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.copy_ACL');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_ACL:FND_API.G_EXC_ERROR Exception');
        END IF;
        ROLLBACK TO copy_ACL_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_ACL:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        ROLLBACK TO copy_ACL_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_ACL because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO copy_ACL_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END copy_ACL;



-- Start of comments
--API name      : copy_contract_details
--Type          : Private.
--Function      : Copies contract details for duplication
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_source_contract_id          IN NUMBER       Required
--                   Id of the contract whose details are to be copied
--              : p_target_contract_id          IN NUMBER       Required
--                   Id of the contract to which source contract details are to be copied
--              : p_target_contract_number      IN VARCHAR2     Required
--                   Number of the contract to which source contract details are to be copied
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE copy_contract_details(
      p_api_version            IN  NUMBER,
      p_init_msg_list          IN  VARCHAR2,
      p_commit                   IN  VARCHAR2,
      p_source_contract_id       IN  NUMBER,
      p_target_contract_id       IN  NUMBER,
      p_target_contract_number   IN  VARCHAR2,
      x_msg_data               OUT NOCOPY  VARCHAR2,
      x_msg_count              OUT NOCOPY  NUMBER,
      x_return_status          OUT NOCOPY  VARCHAR2) IS

    l_api_name        VARCHAR2(30);
    l_api_version         NUMBER;
    l_internal_party_id            OKC_REP_CONTRACT_PARTIES.PARTY_ID%TYPE;

   -- Repository Enhancement 12.1  (For Duplicate Action)
    x_target_contract_id   OKC_REP_CONTRACTS_ALL.CONTRACT_ID%TYPE;
   G_TEMPLATE_MISS_REC          OKC_TERMS_TEMPLATES_PVT.template_rec_type;
   -- Repository Enhancement 12.1 ends


    CURSOR source_contract_csr IS
      SELECT contract_type, owner_id
      FROM OKC_REP_CONTRACTS_ALL
      WHERE contract_id = p_source_contract_id;

    source_contract_rec       source_contract_csr%ROWTYPE;

   -- Repository Enhancement 12.1(For Duplicate Action)
    x_target_contract_type    source_contract_rec.contract_type%TYPE;
   -- Repository Enhancement 12.1 ends (For Duplicate Action)


    CURSOR party_csr IS
      SELECT party_id
      FROM OKC_REP_CONTRACT_PARTIES
      WHERE contract_id = p_source_contract_id
      AND party_role_code = 'INTERNAL_ORG';


  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.copy_contract_details');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Source Contract Id is: ' || p_source_contract_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Target Contract Id is: ' || p_target_contract_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Target Contract Number is: ' || p_target_contract_number);
    END IF;
    l_api_name := 'copy_contract_details';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT copy_contract_details_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Calling OKC_REP_CONTRACT_PROCESS_PVT.copy_parties()');
    END IF;
    copy_parties(
      p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_FALSE,
      p_commit               => FND_API.G_FALSE,
      p_source_contract_id   => p_source_contract_id,
      p_target_contract_id   => p_target_contract_id,
      x_msg_data             => x_msg_data,
      x_msg_count            => x_msg_count,
      x_return_status        => x_return_status);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'OKC_REP_CONTRACT_PROCESS_PVT.copy_parties return status is: '
        || x_return_status);
    END IF;
    ----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------------------


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Calling OKC_REP_CONTRACT_PROCESS_PVT.copy_contacts()');
    END IF;
    copy_contacts(
      p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_FALSE,
      p_commit               => FND_API.G_FALSE,
      p_source_contract_id   => p_source_contract_id,
      p_target_contract_id   => p_target_contract_id,
      x_msg_data          => x_msg_data,
      x_msg_count         => x_msg_count,
      x_return_status     => x_return_status);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'OKC_REP_CONTRACT_PROCESS_PVT.copy_contacts return status is: '
      || x_return_status);
    END IF;
    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------------------

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Calling OKC_REP_CONTRACT_PROCESS_PVT.copy_risks()');
    END IF;
    copy_risks(
      p_api_version       => 1.0,
      p_init_msg_list        => FND_API.G_FALSE,
      p_commit               => FND_API.G_FALSE,
      p_source_contract_id   => p_source_contract_id,
      p_target_contract_id   => p_target_contract_id,
      x_msg_data          => x_msg_data,
      x_msg_count         => x_msg_count,
      x_return_status     => x_return_status);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'OKC_REP_CONTRACT_PROCESS_PVT.copy_risks return status is: '
            || x_return_status);
    END IF;
    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------------------

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
            'Calling OKC_REP_CONTRACT_PROCESS_PVT.copy_ACL()');
    END IF;
    copy_ACL(
      p_api_version       => 1.0,
      p_init_msg_list        => FND_API.G_FALSE,
      p_commit               => FND_API.G_FALSE,
      p_source_contract_id   => p_source_contract_id,
      p_target_contract_id   => p_target_contract_id,
      x_msg_data          => x_msg_data,
      x_msg_count         => x_msg_count,
      x_return_status     => x_return_status);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'OKC_REP_CONTRACT_PROCESS_PVT.copy_ACL return status is: '
      || x_return_status);
    END IF;
    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------------------
    -- Get contract_type of source contract, required for deliverables and documents APIs
    OPEN source_contract_csr;
    FETCH source_contract_csr INTO source_contract_rec;
    IF(source_contract_csr%NOTFOUND) THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| p_source_contract_id);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_source_contract_id));
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Get internal party_id. Needed for deliverables api
    OPEN party_csr;
    FETCH party_csr INTO l_internal_party_id;
    IF(party_csr%NOTFOUND) THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'No internal party for the contract');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_CONTRACT_DOCS_GRP.Copy_Attachments');
    END IF;
    OKC_CONTRACT_DOCS_GRP.Copy_Attachments(
        p_api_version               => 1,
        p_from_bus_doc_type         => source_contract_rec.contract_type,
        p_from_bus_doc_id           => p_source_contract_id,
        p_to_bus_doc_type           => source_contract_rec.contract_type,
        p_to_bus_doc_id             => p_target_contract_id,
        p_copy_by_ref               => 'N',
    x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
        );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_CONTRACT_DOCS_GRP.Copy_Attachments return status is : '
            || x_return_status);
    END IF;
    -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------

   -- Repository Enhancement 12.1(For Duplicate Action)


   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_TERMS_COPY_PVT.copy_tc');
    END IF;

  x_target_contract_type   := source_contract_rec.contract_type;
  x_target_contract_id := p_target_contract_id;
     OKC_TERMS_COPY_PVT.copy_tc(
                                   p_api_version            => 1,
                                   p_init_msg_list          => FND_API.G_FALSE,
                                   p_commit                 => FND_API.G_FALSE,
                                   p_source_doc_type        => source_contract_rec.contract_type,
                                     p_source_doc_id          => p_source_contract_id,
                                     p_target_doc_type        =>x_target_contract_type    ,
                                     p_target_doc_id          => x_target_contract_id,
                                     p_document_number  => p_target_contract_number,
                                     p_keep_version           => 'N',
                                     p_article_effective_date => SYSDATE,
                                     p_target_template_rec    => G_TEMPLATE_MISS_REC          ,
                                     x_return_status          => x_return_status,
                                     x_msg_data               => x_msg_data,
                                     x_msg_count              => x_msg_count);
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_TERMS_COPY_PVT.copy_tc, return status : '||x_return_status);
    END IF;

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
   -- Repository Enhancement 12.1 ends(For Duplicate Action)


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables');
    END IF;
  OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables (
      p_api_version         => 1.0,
      p_init_msg_list             => FND_API.G_FALSE,
      p_source_doc_id             => p_source_contract_id,
        p_source_doc_type           => source_contract_rec.contract_type,
        p_target_doc_id             => p_target_contract_id,
        p_target_doc_type           => source_contract_rec.contract_type,
        p_target_doc_number         => p_target_contract_number,
        p_internal_party_id         => l_internal_party_id,
        p_internal_contact_id       => source_contract_rec.owner_id,
        p_carry_forward_ext_party_yn => 'Y',
        p_carry_forward_int_contact_yn => 'Y',
        p_reset_fixed_date_yn       => 'Y',
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
        );
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables return status is : '
            || x_return_status);
     END IF;
     -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------

    -- close open cursors
    CLOSE source_contract_csr;
    CLOSE party_csr;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.copy_contract_details');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_contract_details:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursors
        IF (source_contract_csr%ISOPEN) THEN
          CLOSE source_contract_csr ;
        END IF;
        IF (party_csr%ISOPEN) THEN
          CLOSE party_csr ;
        END IF;
        ROLLBACK TO copy_contract_details_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_contract_details:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        --close cursors
        IF (source_contract_csr%ISOPEN) THEN
          CLOSE source_contract_csr ;
        END IF;
        IF (party_csr%ISOPEN) THEN
          CLOSE party_csr ;
        END IF;
        ROLLBACK TO copy_contract_details_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving copy_contract_details because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO copy_contract_details_PVT;
        --close cursors
        IF (source_contract_csr%ISOPEN) THEN
          CLOSE source_contract_csr ;
        END IF;
        IF (party_csr%ISOPEN) THEN
          CLOSE party_csr ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END copy_contract_details;


-- Start of comments
--API name      : version_contract_details
--Type          : Private.
--Function      : Copies deliverables and documents for versioning
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id          IN NUMBER       Required
--                   Id of the contract whose details are to be versioned
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE version_contract_details(
      p_api_version            IN  NUMBER,
      p_init_msg_list          IN  VARCHAR2,
      p_commit                   IN  VARCHAR2,
      p_contract_id              IN  NUMBER,

	 x_msg_data               OUT NOCOPY  VARCHAR2,
      x_msg_count              OUT NOCOPY  NUMBER,
      x_return_status          OUT NOCOPY  VARCHAR2) IS
      l_api_name        VARCHAR2(30);
    l_api_version             NUMBER;
    l_contract_type         OKC_REP_CONTRACTS_ALL.CONTRACT_TYPE%TYPE;
    l_contract_version      OKC_REP_CONTRACTS_ALL.CONTRACT_VERSION_NUM%TYPE;
-- Repository Enhancement 12.1 (For Create New Version Action)
    l_conterms_exist_flag     VARCHAR2(1);

    CURSOR contract_csr IS
      SELECT contract_type, contract_version_num, contract_status_code
      FROM OKC_REP_CONTRACTS_ALL
      WHERE contract_id = p_contract_id;

  contract_rec       contract_csr%ROWTYPE;
-- Repository Enhancement 12.1 (For Create New Version Action)
  CURSOR conterms_exist_csr is
  SELECT 'Y'   FROM   DUAL
  WHERE EXISTS (SELECT 'Y'
		FROM okc_template_usages
		WHERE DOCUMENT_ID = p_contract_id
		     AND DOCUMENT_TYPE= contract_rec.contract_type);
-- Repository Enhancement 12.1 Ends (For Create New Version Action)
   l_contract_source   VARCHAR2(30);  -- For Bug# 6902073
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.version_contract_details');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
    END IF;
    l_api_name := 'version_contract_details';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT version_contract_details_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Lock the contract header
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Calling OKC_REP_CONTRACT_PROCESS_PVT.Lock_Contract_Header()');
    END IF;
    -- Lock the contract header
    Lock_Contract_Header(
        p_contract_id              => p_contract_id,
          p_object_version_number    => NULL,
          x_return_status            => x_return_status
          );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'OKC_REP_CONTRACT_PROCESS_PVT.Lock_Contract_Header return status is: '
      || x_return_status);
    END IF;
    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------------------

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Populating contract header record in OKC_REP_CONTRACT_VERS');
    END IF;
    -- Copy the header record to versions table
    INSERT INTO OKC_REP_CONTRACT_VERS(
            CONTRACT_ID,
            CONTRACT_VERSION_NUM,
            CONTRACT_NUMBER,
            CONTRACT_TYPE,
            CONTRACT_STATUS_CODE,
            ORG_ID,
            OWNER_ID,
            SOURCE_LANGUAGE,
            CONTRACT_NAME,
            CONTRACT_DESC,
            VERSION_COMMENTS,
            AUTHORING_PARTY_CODE,
            CONTRACT_EFFECTIVE_DATE,
            CONTRACT_EXPIRATION_DATE,
            CURRENCY_CODE,
            AMOUNT,
            OVERALL_RISK_CODE,
            CANCELLATION_COMMENTS,
            CANCELLATION_DATE,
            TERMINATION_COMMENTS,
            TERMINATION_DATE,
            KEYWORDS,
            PHYSICAL_LOCATION,
            EXPIRE_NTF_FLAG,
            EXPIRE_NTF_PERIOD,
            NOTIFY_CONTACT_ROLE_ID,
            WF_EXP_NTF_ITEM_KEY,
            USE_ACL_FLAG,
            WF_ITEM_TYPE,
            WF_ITEM_KEY,
            PROGRAM_ID,
            PROGRAM_LOGIN_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            LATEST_SIGNED_VER_NUMBER,
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
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            CONTRACT_LAST_UPDATE_DATE,
            CONTRACT_LAST_UPDATED_BY,
	    REFERENCE_DOCUMENT_TYPE,
            REFERENCE_DOCUMENT_NUMBER,
            ORIG_SYSTEM_REFERENCE_CODE,
            ORIG_SYSTEM_REFERENCE_ID1,
            ORIG_SYSTEM_REFERENCE_ID2)
      SELECT
            CONTRACT_ID,
            CONTRACT_VERSION_NUM,
            CONTRACT_NUMBER,
            CONTRACT_TYPE,
            CONTRACT_STATUS_CODE,
            ORG_ID,
            OWNER_ID,
            SOURCE_LANGUAGE,
            CONTRACT_NAME,
            CONTRACT_DESC,
            VERSION_COMMENTS,
            AUTHORING_PARTY_CODE,
            CONTRACT_EFFECTIVE_DATE,
            CONTRACT_EXPIRATION_DATE,
            CURRENCY_CODE,
            AMOUNT,
            OVERALL_RISK_CODE,
            CANCELLATION_COMMENTS,
            CANCELLATION_DATE,
            TERMINATION_COMMENTS,
            TERMINATION_DATE,
            KEYWORDS,
            PHYSICAL_LOCATION,
            EXPIRE_NTF_FLAG,
            EXPIRE_NTF_PERIOD,
            NOTIFY_CONTACT_ROLE_ID,
            WF_EXP_NTF_ITEM_KEY,
            USE_ACL_FLAG,
            WF_ITEM_TYPE,
            WF_ITEM_KEY,
            PROGRAM_ID,
            PROGRAM_LOGIN_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            LATEST_SIGNED_VER_NUMBER,
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
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            CONTRACT_LAST_UPDATE_DATE,
            CONTRACT_LAST_UPDATED_BY,
            REFERENCE_DOCUMENT_TYPE,
            REFERENCE_DOCUMENT_NUMBER,
            ORIG_SYSTEM_REFERENCE_CODE,
            ORIG_SYSTEM_REFERENCE_ID1,
            ORIG_SYSTEM_REFERENCE_ID2
        FROM OKC_REP_CONTRACTS_ALL
        WHERE contract_id = p_contract_id;

    -- Get contract_type of the contract, required for deliverables and documents APIs
    OPEN contract_csr;
    FETCH contract_csr INTO contract_rec;
    IF(contract_csr%NOTFOUND) THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| p_contract_id);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_contract_id));
          RAISE FND_API.G_EXC_ERROR;
          -- RAISE NO_DATA_FOUND;
    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_CONTRACT_DOCS_GRP.Version_Attachments');
    END IF;

/*Bug 6957819: Added an additional parameter in the call for not copying the system generated attachment to the new version*/

    OKC_CONTRACT_DOCS_GRP.Version_Attachments(
        p_api_version                    => 1,
        p_business_document_type         => contract_rec.contract_type,
        p_business_document_id           => p_contract_id,
        p_business_document_version      => contract_rec.contract_version_num,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data,
        p_include_gen_attach        => 'N'
        );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_CONTRACT_DOCS_GRP.Version_Attachments return status is : '
            || x_return_status);
    END IF;
    -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------

-- Repository Enhancement 12.1 (For Create New Version Action)
  -- SQL What:Find out if contract terms exist
  -- SQL Why: Archive Contract Terms if needed
  l_conterms_exist_flag := 'N';
  OPEN conterms_exist_csr;
  FETCH conterms_exist_csr into l_conterms_exist_flag;
  CLOSE conterms_exist_csr;


  IF (l_conterms_exist_flag = 'Y') THEN
-- Code changes for Bug# 6902073 Begins
    l_contract_source := OKC_TERMS_UTIL_GRP.Get_Contract_Source_Code(
                            p_document_type    => contract_rec.contract_type,
                            p_document_id      => p_contract_id
                         );
    IF l_contract_source = 'STRUCTURED' THEN
      --------------------------------------------
      -- Call internal Version_Doc
      --------------------------------------------
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Call Private Version_Doc ');
      END IF;

      OKC_TERMS_VERSION_PVT.Version_Doc(
        x_return_status    => x_return_status,

        p_doc_type         => contract_rec.contract_type,
        p_doc_id           => p_contract_id,
        p_version_number   => contract_rec.contract_version_num
      );
      --------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

    ELSIF l_contract_source = 'ATTACHED' THEN

--Only need to version usages record in case of offline authoring
      --------------------------------------------
      -- Call Create_Version for template usages
      --------------------------------------------
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Call Create_Version for template usages');
      END IF;

      x_return_status := OKC_TEMPLATE_USAGES_PVT.Create_Version(
        p_doc_type         => contract_rec.contract_type,
        p_doc_id           => p_contract_id,
        p_major_version    => contract_rec.contract_version_num
      );
      --------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

    END IF;
-- Code changes for Bug# 6902073 Ends


  END IF; /*  IF(l_conterms_exist_flag = 'Y') */
-- Repository Enhancement 12.1 Ends(For Create New Version Action)


    -- If contract status not Signed, we need to version the deliverables as well
    -- Not in case of ACQ
    IF(contract_rec.contract_type <> 'REP_ACQ') THEN
    IF (contract_rec.contract_status_code <> G_STATUS_SIGNED) THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_DELIVERABLE_PROCESS_PVT.version_deliverables');
        END IF;
      OKC_DELIVERABLE_PROCESS_PVT.version_deliverables (
          p_api_version         => 1.0,
          p_init_msg_list             => FND_API.G_FALSE,
          p_doc_id                    => p_contract_id,
            p_doc_version               => contract_rec.contract_version_num,
            p_doc_type                  => contract_rec.contract_type,
          x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
            );
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_DELIVERABLE_PROCESS_PVT.version_deliverables return status is : '
            || x_return_status);
        END IF;
        -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
        --------------------------------------------------------
    END IF;  -- contract_rec.contract_status_code <> G_STATUS_SIGNED
    END IF;  -- contract_rec.contract_type <> 'REP_ACQ'

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_DELIVERABLE_PROCESS_PVT.clear_amendment_operation');
    END IF;
    OKC_DELIVERABLE_PROCESS_PVT.clear_amendment_operation (
       p_api_version               => 1.0,
       p_init_msg_list             => FND_API.G_FALSE,
       p_doc_id                    => p_contract_id,
       p_doc_type                  => contract_rec.contract_type,
       p_keep_summary              => 'N',
       x_return_status             => x_return_status,
       x_msg_count                 => x_msg_count,
       x_msg_data                  => x_msg_data
       );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_DELIVERABLE_PROCESS_PVT.clear_amendment_operation return status is : '
            || x_return_status);
    END IF;
    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------------------





    CLOSE contract_csr;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Delete contract header record.');
    END IF;

    -- Delete the header record
    DELETE FROM OKC_REP_CONTRACTS_ALL
          WHERE contract_id=p_contract_id;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.version_contract_details');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving version_contract_details:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO version_contract_details_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving version_contract_details:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO version_contract_details_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving version_contract_details because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO version_contract_details_PVT;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END version_contract_details;



-- Start of comments
--API name      : sign_contract
--Type          : Private.
--Function      : Changes contract status to SIGNED and calls delivarables
--                API to activate deliverables of that contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id          IN NUMBER       Required
--                   Id of the contract to be signed
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE sign_contract(
      p_api_version            IN  NUMBER,
      p_init_msg_list          IN  VARCHAR2,
      p_commit                   IN  VARCHAR2,
      p_contract_id              IN  NUMBER,
      x_msg_data               OUT NOCOPY  VARCHAR2,
      x_msg_count              OUT NOCOPY  NUMBER,
      x_return_status          OUT NOCOPY  VARCHAR2)
  IS
      l_api_name        VARCHAR2(30);
      l_api_version             NUMBER;
      l_activate_event_tbl      EVENT_TBL_TYPE;
      l_update_event_tbl        EVENT_TBL_TYPE;
      l_sync_flag               VARCHAR2(1);
      l_expiration_date_matches_flag VARCHAR2(1);
      l_effective_date_matches_flag  VARCHAR2(1);
      l_prev_signed_expiration_date OKC_REP_CONTRACTS_ALL.CONTRACT_EXPIRATION_DATE%TYPE;
      l_prev_signed_effective_date  OKC_REP_CONTRACTS_ALL.CONTRACT_EXPIRATION_DATE%TYPE;

    CURSOR contract_csr IS
      SELECT contract_type, contract_version_num, latest_signed_ver_number, contract_effective_date, contract_expiration_date
      FROM OKC_REP_CONTRACTS_ALL
      WHERE contract_id = p_contract_id;

    CURSOR arch_contract_csr (l_contract_version NUMBER) IS
      SELECT contract_effective_date, contract_expiration_date
      FROM OKC_REP_CONTRACT_VERS
      WHERE contract_id = p_contract_id
      AND contract_version_num = l_contract_version;

  contract_rec       contract_csr%ROWTYPE;
  arch_contract_rec  arch_contract_csr%ROWTYPE;

  BEGIN

    l_expiration_date_matches_flag := FND_API.G_FALSE;
    l_effective_date_matches_flag := FND_API.G_FALSE;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.sign_contract');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
    END IF;
    l_api_name := 'sign_contacts';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT sign_contract_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get effective dates and version of the contract.
    OPEN contract_csr;
    FETCH contract_csr INTO contract_rec;
    IF(contract_csr%NOTFOUND) THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| p_contract_id);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_contract_id));
          RAISE FND_API.G_EXC_ERROR;
          -- RAISE NO_DATA_FOUND;
    END IF;

    -- Lock the contract header
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Calling OKC_REP_CONTRACT_PROCESS_PVT.Lock_Contract_Header()');
    END IF;
    -- Lock the contract header
    Lock_Contract_Header(
        p_contract_id              => p_contract_id,
          p_object_version_number    => NULL,
          x_return_status            => x_return_status
          );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'OKC_REP_CONTRACT_PROCESS_PVT.Lock_Contract_Header return status is: '
      || x_return_status);
    END IF;
    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------------------

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_UTIL_PVT.change_contract_status');
        END IF;
        -- Update the contract status and add a record in OKC_REP_CON_STATUS_HIST table.
        OKC_REP_UTIL_PVT.change_contract_status(
          p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_FALSE,
          p_contract_id         => p_contract_id,
          p_contract_version    => contract_rec.contract_version_num,
          p_status_code         => G_STATUS_SIGNED,
          p_user_id             => fnd_global.user_id,
          p_note                => NULL,
        x_msg_data            => x_msg_data,
          x_msg_count           => x_msg_count,
          x_return_status       => x_return_status);
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Completed OKC_REP_UTIL_PVT.change_contract_status with return status: ' || x_return_status);
        END IF;
      -----------------------------------------------------
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    ------------------------------------------------------

    -- We need to first version the deliverables
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_DELIVERABLE_PROCESS_PVT.version_deliverables');
    END IF;
  OKC_DELIVERABLE_PROCESS_PVT.version_deliverables (
      p_api_version         => 1.0,
      p_init_msg_list             => FND_API.G_FALSE,
      p_doc_id                    => p_contract_id,
        p_doc_version               => contract_rec.contract_version_num,
        p_doc_type                  => contract_rec.contract_type,
      x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
        );
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_DELIVERABLE_PROCESS_PVT.version_deliverables return status is : '
            || x_return_status);
     END IF;
     -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Latest signed version number is : '
            || contract_rec.latest_signed_ver_number);
     END IF;
    -- Now we need to activate deliverables
    if (contract_rec.latest_signed_ver_number IS NULL) THEN
      l_sync_flag := FND_API.G_FALSE;
    ELSE
      l_sync_flag := FND_API.G_TRUE;
    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'l_sync_flag is : ' || l_sync_flag);
    END IF;
    l_activate_event_tbl(1).event_code := G_CONTRACT_EXPIRE_EVENT;
    l_activate_event_tbl(1).event_date := contract_rec.contract_expiration_date;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_MANAGE_DELIVERABLES_GRP.activateDeliverables');
    END IF;

    OKC_MANAGE_DELIVERABLES_GRP.activateDeliverables (
        p_api_version                 => 1.0,
        p_init_msg_list               => FND_API.G_FALSE,
        p_commit                    => FND_API.G_FALSE,
        p_bus_doc_id                  => p_contract_id,
        p_bus_doc_type                => contract_rec.contract_type,
        p_bus_doc_version             => contract_rec.contract_version_num,
        p_event_code                  => G_CONTRACT_EFFECTIVE_EVENT,
        p_event_date                  => contract_rec.contract_effective_date,
        p_sync_flag                   => l_sync_flag,
        p_bus_doc_date_events_tbl     => l_activate_event_tbl,
        x_msg_data                    => x_msg_data,
        x_msg_count                   => x_msg_count,
        x_return_status               => x_return_status);

     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_DELIVERABLE_PROCESS_PVT.activateDeliverables return status is : '
            || x_return_status);
     END IF;
     -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------

    -- Checking if we need to call deliverable's APIs for synch-ing
    IF (l_sync_flag = FND_API.G_TRUE) THEN
        -- Get the previous signed contract's expiration date
        -- Get effective dates and version of the contract.
        OPEN arch_contract_csr(contract_rec.latest_signed_ver_number);
        FETCH arch_contract_csr INTO arch_contract_rec;
        IF(contract_csr%NOTFOUND) THEN
            IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| p_contract_id);
            END IF;
            Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_contract_id));
            RAISE FND_API.G_EXC_ERROR;
            -- RAISE NO_DATA_FOUND;
        END IF;
        l_prev_signed_effective_date := arch_contract_rec.contract_effective_date;
        l_prev_signed_expiration_date := arch_contract_rec.contract_expiration_date;

        CLOSE arch_contract_csr;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                     'Before checking if we need to call updateDeliverable and disableDeliverable()');
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                     'Prev signed expiration date: ' || trunc(l_prev_signed_expiration_date));
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                     'Current version expiration date: ' || trunc(contract_rec.contract_expiration_date));
        END IF;
        l_update_event_tbl(1).event_code := G_CONTRACT_EFFECTIVE_EVENT;
        l_update_event_tbl(1).event_date := contract_rec.contract_effective_date;
        l_update_event_tbl(2).event_code := G_CONTRACT_EXPIRE_EVENT;
        l_update_event_tbl(2).event_date := contract_rec.contract_expiration_date;
        -- If last signed version's expiration date is different from the current version's expiration date
        -- we need to call deliverables API for synching previous signed deliverables.
        -- This logic is executed to handle the null date scenarios
        IF (trunc(l_prev_signed_expiration_date)=trunc(contract_rec.contract_expiration_date)) THEN
           l_expiration_date_matches_flag := FND_API.G_TRUE;
        END IF;

        IF (trunc(l_prev_signed_effective_date)=trunc(contract_rec.contract_effective_date)) THEN
           l_effective_date_matches_flag := FND_API.G_TRUE;
        END IF;

        IF ((l_expiration_date_matches_flag = FND_API.G_FALSE ) OR (l_effective_date_matches_flag = FND_API.G_FALSE)) THEN
             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables');
             END IF;
             OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables (
                p_api_version                 => 1.0,
                p_init_msg_list               => FND_API.G_FALSE,
                p_commit                    => FND_API.G_FALSE,
                p_bus_doc_id                  => p_contract_id,
                p_bus_doc_type                => contract_rec.contract_type,
                p_bus_doc_version             => contract_rec.contract_version_num,
                p_bus_doc_date_events_tbl     => l_update_event_tbl,
                x_msg_data                    => x_msg_data,
                x_msg_count                   => x_msg_count,
                x_return_status               => x_return_status);

             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'OKC_DELIVERABLE_PROCESS_PVT.updateDeliverables return status is : '
                  || x_return_status);
             END IF;
             -----------------------------------------------------
             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
               RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;
             --------------------------------------------------------
       END IF;  -- expiration date comparision
       -- Disable prev. version deliverables
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_MANAGE_DELIVERABLES_GRP.disableDeliverables');
       END IF;
       OKC_MANAGE_DELIVERABLES_GRP.disableDeliverables (
                p_api_version                 => 1.0,
                p_init_msg_list               => FND_API.G_FALSE,
                p_commit                    => FND_API.G_FALSE,
                p_bus_doc_id                  => p_contract_id,
                p_bus_doc_type                => contract_rec.contract_type,
                p_bus_doc_version             => contract_rec.latest_signed_ver_number,
                x_msg_data                    => x_msg_data,
                x_msg_count                   => x_msg_count,
                x_return_status               => x_return_status);

       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'OKC_DELIVERABLE_PROCESS_PVT.disableDeliverables return status is : '
                  || x_return_status);
       END IF;
       -----------------------------------------------------
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       --------------------------------------------------------
    END IF;  -- (l_sync_flag = 'Y')
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Updating latest_signed_ver_number column');
    END IF;
    UPDATE okc_rep_contracts_all
    SET latest_signed_ver_number = contract_rec.contract_version_num
    WHERE contract_id = p_contract_id;
    CLOSE contract_csr;
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.sign_contract');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving sign_contract:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        IF (arch_contract_csr%ISOPEN) THEN
          CLOSE arch_contract_csr ;
        END IF;
        ROLLBACK TO sign_contract_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving sign_contract:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        IF (arch_contract_csr%ISOPEN) THEN
          CLOSE arch_contract_csr ;
        END IF;
        ROLLBACK TO sign_contract_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving sign_contract because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO sign_contract_PVT;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        IF (arch_contract_csr%ISOPEN) THEN
          CLOSE arch_contract_csr ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END sign_contract;


 -- Start of comments
--API name      : terminate_contract
--Type          : Private.
--Function      : Changes contract status to TERMINATED and calls delivarables
--                API to cancel deliverables of that contract
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id          IN NUMBER       Required
--                   Id of the contract to be terminated
--              : p_termination_date     IN DATE       Required
--                   Date the contract is terminated
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
  PROCEDURE terminate_contract(
      p_api_version            IN  NUMBER,
      p_init_msg_list          IN  VARCHAR2,
      p_commit                   IN  VARCHAR2,
      p_contract_id              IN  NUMBER,
      p_termination_date         IN  DATE,
      x_msg_data               OUT NOCOPY  VARCHAR2,
      x_msg_count              OUT NOCOPY  NUMBER,
      x_return_status          OUT NOCOPY  VARCHAR2)
  IS

      l_api_name        VARCHAR2(30);
      l_api_version             NUMBER;
      l_cancel_event_tbl      EVENT_TBL_TYPE;
      l_update_event_tbl      EVENT_TBL_TYPE;



    CURSOR contract_csr IS
      SELECT contract_type, contract_version_num, latest_signed_ver_number, contract_effective_date,
           contract_expiration_date, termination_date
      FROM OKC_REP_CONTRACTS_ALL
      WHERE contract_id = p_contract_id;

  contract_rec       contract_csr%ROWTYPE;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.terminate_contract');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Termination date is: ' || to_char(p_termination_date));
    END IF;
    l_api_name := 'terminate_contacts';
    l_api_version := 1.0;
  -- Standard Start of API savepoint
    SAVEPOINT terminate_contract_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get effective dates and version of the contract.
    OPEN contract_csr;
    FETCH contract_csr INTO contract_rec;
    IF(contract_csr%NOTFOUND) THEN
          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| p_contract_id);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_contract_id));
          RAISE FND_API.G_EXC_ERROR;
          -- RAISE NO_DATA_FOUND;
    END IF;

    -- Lock the contract header
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'Calling OKC_REP_CONTRACT_PROCESS_PVT.Lock_Contract_Header()');
    END IF;
    -- Lock the contract header
    Lock_Contract_Header(
        p_contract_id              => p_contract_id,
          p_object_version_number    => NULL,
          x_return_status            => x_return_status
          );
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
        'OKC_REP_CONTRACT_PROCESS_PVT.Lock_Contract_Header return status is: '
      || x_return_status);
    END IF;
    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------------------
    IF (trunc(p_termination_date) <= trunc(sysdate)) THEN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_UTIL_PVT.change_contract_status');
      END IF;

        -- Update the contract status and add a record in OKC_REP_CON_STATUS_HIST table.
        OKC_REP_UTIL_PVT.change_contract_status(
          p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_FALSE,
          p_contract_id         => p_contract_id,
          p_contract_version    => contract_rec.contract_version_num,
          p_status_code         => G_STATUS_TERMINATED,
          p_user_id             => fnd_global.user_id,
          p_note                => NULL,
        x_msg_data            => x_msg_data,
          x_msg_count           => x_msg_count,
          x_return_status       => x_return_status);
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  g_module || l_api_name,
                  'Completed OKC_REP_UTIL_PVT.change_contract_status with return status: ' || x_return_status);
     END IF;
     -----------------------------------------------------
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
     ------------------------------------------------------

    END IF; -- (p_termination_date <= sysdate)

    -- We should call cancel_deliverables only for the first time
    IF (contract_rec.termination_date IS NULL) THEN
      l_cancel_event_tbl(1).event_code := G_CONTRACT_EFFECTIVE_EVENT;
      l_cancel_event_tbl(1).event_date := contract_rec.contract_effective_date;
      l_cancel_event_tbl(2).event_code := G_CONTRACT_EXPIRE_EVENT;
      l_cancel_event_tbl(2).event_date := contract_rec.contract_expiration_date;
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_MANAGE_DELIVERABLES_GRP.activateCloseOutDeliverables ');
      END IF;

      OKC_MANAGE_DELIVERABLES_GRP.activateCloseOutDeliverables (
        p_api_version                 => 1.0,
        p_init_msg_list               => FND_API.G_FALSE,
        p_commit                    => FND_API.G_FALSE,
        p_bus_doc_id                  => p_contract_id,
        p_bus_doc_type                => contract_rec.contract_type,
        p_bus_doc_version             => contract_rec.contract_version_num,
        p_event_code                  => G_CONTRACT_TERMINATED_EVENT,
        p_event_date                  => p_termination_date,
        p_bus_doc_date_events_tbl     => l_cancel_event_tbl,
        x_msg_data                    => x_msg_data,
        x_msg_count                   => x_msg_count,
        x_return_status               => x_return_status);

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_DELIVERABLE_PROCESS_PVT.activateCloseOutDeliverables return status is : '
            || x_return_status);
      END IF;
      -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------------------------
    ELSE
      IF (trunc(contract_rec.termination_date) <> trunc(p_termination_date)) THEN
        -- Update the deliverables
        l_update_event_tbl(1).event_code := G_CONTRACT_TERMINATED_EVENT;
        l_update_event_tbl(1).event_date := p_termination_date;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables ');
        END IF;
        OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables (
            p_api_version                 => 1.0,
            p_init_msg_list               => FND_API.G_FALSE,
            p_commit                      => FND_API.G_FALSE,
            p_bus_doc_id                  => p_contract_id,
            p_bus_doc_type                => contract_rec.contract_type,
            p_bus_doc_version             => contract_rec.contract_version_num,
            p_bus_doc_date_events_tbl     => l_update_event_tbl,
            x_msg_data                    => x_msg_data,
            x_msg_count                   => x_msg_count,
            x_return_status               => x_return_status);

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_DELIVERABLE_PROCESS_PVT.updateDeliverables return status is : '
            || x_return_status);
        END IF;
        -----------------------------------------------------
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        --------------------------------------------------------
      END IF; -- contract_rec.termination_date <> p_termination_date
    END IF; -- contract_rec.termination_date = null

    CLOSE contract_csr;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.terminate_contract');
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving terminate_contract:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO terminate_contract_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving terminate_contract:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO terminate_contract_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving terminate_contract because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO terminate_contract_PVT;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END terminate_contract;

   -- Start of comments
--API name      : repository_notifier
--Type          : Private.
--Function      : Sends notifications to contract's contacts if
--                the contract is about to expire or expired.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Id of the contract to be processed
--              : p_contract_number     IN NUMBER       Required
--                   Number of the contract to be processed
--              : p_contract_version    IN NUMBER       Required
--                   Version of the contract to be processed
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments

PROCEDURE repository_notifier(
      p_api_version       IN          NUMBER,
      p_init_msg_list     IN          VARCHAR2,
      p_contract_id       IN          NUMBER,
      p_contract_number   IN          VARCHAR2,
      p_contract_version  IN          NUMBER,
      p_expired_flag      IN          VARCHAR2,
      p_notify_contact_role_id IN     NUMBER,
      x_msg_data          OUT NOCOPY  VARCHAR2,
      x_msg_count         OUT NOCOPY  NUMBER,
      x_return_status     OUT NOCOPY  VARCHAR2)
     IS
      l_item_key                     NUMBER;
      l_item_type                    VARCHAR2(30);
      l_process_name                 VARCHAR2(30);
      l_contract_contacts_role_name  VARCHAR2(320);
      l_user_name                    VARCHAR2(4000);
      l_display_name                 VARCHAR2(4000);
      l_contract_contacts_all        VARCHAR2(4000);
      l_contract_contacts_role_desc  VARCHAR2(500);
      l_subject_text                 VARCHAR2(200);
      l_error_msg                    VARCHAR2(4000);
      l_api_name                     VARCHAR2(30);
      l_api_version                  NUMBER;
      l_item_contract_id             VARCHAR2(30);
      l_item_contract_number         VARCHAR2(30);
      l_item_contract_version        VARCHAR2(30);
      l_item_contract_contacts       VARCHAR2(30);
      l_item_message_subject         VARCHAR2(30);
      l_message_code_expired         VARCHAR2(32);
      l_message_code_about_to_expire VARCHAR2(32);
      l_message_token_con_number     VARCHAR2(30);
      l_message_token_con_version    VARCHAR2(30);
      l_app_name                     VARCHAR2(30);
      l_msg_code                     VARCHAR2(30);
      l_contact_role_name            okc_rep_contact_roles_tl.name%TYPE;
      l_email                        per_all_people_f.email_address%TYPE;

      CURSOR CONTRACT_CONTACTS(c_contract_id in number) IS
      SELECT  contact_id
      FROM    okc_rep_party_contacts
      WHERE   contract_id = c_contract_id
      AND     party_role_code = G_PARTY_TYPE_INTERNAL
      AND     contact_role_id = p_notify_contact_role_id;

      CURSOR CONTACT_ATTRIBUTES(c_contact_id in number) IS
      SELECT  email_address
      FROM    per_all_people_f
      WHERE   person_id = c_contact_id
      AND     effective_start_date = (SELECT MAX(effective_start_date)
                                      FROM   per_all_people_f
                                      WHERE  person_id = c_contact_id);

      contact_attributes_rec contact_attributes%ROWTYPE;

	 CURSOR  cur_contact_role
      is
      SELECT NAME FROM okc_rep_contact_roles_vl
      WHERE CONTACT_ROLE_ID = p_notify_contact_role_id;

	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);
    l_doc_type VARCHAR2(30);


    BEGIN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'Entered OKC_REP_CONTRACT_PROCESS_PVT.repository_notifier');
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'Contract Id is: ' || p_contract_id);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'Contract Number is: ' || p_contract_number);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'Expired flag is: ' || p_expired_flag);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'Contact Role Id is: ' || p_notify_contact_role_id);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
            'Contract Version is: ' || p_contract_version);
      END IF;

      --initialize variables
      l_app_name      := 'OKC';
      l_api_name      := 'repository_notifier';
      l_api_version   := 1.0;
      l_item_type     := 'OKCREPXN';
      l_process_name  := 'REP_CONTRACT_EXPIRATION_NTF';

      l_item_contract_id       := 'CONTRACT_ID';
      l_item_contract_number   := 'CONTRACT_NUMBER';
      l_item_contract_version  := 'CONTRACT_VERSION';
      l_item_contract_contacts := 'CONTRACT_CONTACTS';
      l_item_message_subject   := 'SUBJECT';

      l_message_code_expired         := 'OKC_REP_CONTRACT_EXPIRED';
      --Acq Plan Messages Cleanup
      --l_message_code_about_to_expire := 'OKC_REP_CON_ABOUT_TO_EXPIRE';
      l_message_code_about_to_expire := 'OKC_REP_CON_ABOUT_TO_EXPIRE';

      l_message_token_con_number  := 'CONTRACT_NUMBER';
      l_message_token_con_version := 'CONTRACT_VERSION';

      -- Standard Start of API savepoint
      SAVEPOINT repository_notifier_pvt;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;

	    -- Get contact role name
       OPEN cur_contact_role;
       FETCH cur_contact_role INTO l_contact_role_name;
       CLOSE cur_contact_role;

      FOR contract_contacts_rec in CONTRACT_CONTACTS(p_contract_id) LOOP

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'contract_contacts_rec.contact_id ' || contract_contacts_rec.contact_id);
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
               'Calling WF_DIRECTORY.GetUserName()');
        END IF;

        -- Get WF user name for the current contact
        WF_DIRECTORY.GetUserName(p_orig_system  => 'PER',
                                 p_orig_system_id => contract_contacts_rec.contact_id,
                                 p_name => l_user_name,
                                 p_display_name => l_display_name);

        IF (l_user_name IS NULL) THEN

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'Current contact does not have FND User');
          END IF;

          -- Get Email address of the current contact
          OPEN CONTACT_ATTRIBUTES(contract_contacts_rec.contact_id);
          FETCH CONTACT_ATTRIBUTES into l_email;
          CLOSE CONTACT_ATTRIBUTES;

          -- Create adhoc user only if the current contact has a email address
          IF (l_email IS NOT NULL)  THEN

            l_display_name := null;

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'Calling WF_DIRECTORY.CreateAdHocUser() with email ' || l_email);
            END IF;

            --create ad hoc user if user does not already exists
            WF_DIRECTORY.CreateAdHocUser(
              name            => l_user_name,
              display_name    => l_display_name,
              email_address   => l_email,
              description     => 'Repository Ad Hoc User',
              notification_preference => 'MAILHTML',
              expiration_date => SYSDATE + 1);

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'Adhoc User Name ' || l_user_name);
            END IF;

          ELSE

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Email address not available for the current contact');
            END IF;

          END IF;

        ELSE

          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
               'WF User Name ' || l_user_name);
          END IF;

        END IF;

        --build concatinated user name list
        IF (l_user_name IS NOT NULL) THEN

          IF (l_contract_contacts_all IS NULL) THEN
            l_contract_contacts_all := l_user_name;
          ELSE
            l_contract_contacts_all := l_contract_contacts_all || ',' || l_user_name;
          END IF;

        END IF;

      END LOOP;

      IF (l_contract_contacts_all IS NOT NULL) THEN

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'User names list ' || l_contract_contacts_all);
        END IF;

        --Get item key from sequence
        SELECT TO_CHAR(okc_wf_notify_s1.NEXTVAL) INTO l_item_key FROM DUAL;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Calling WF_DIRECTORY.createAdHocRole()');
        END IF;

		IF  InStr(l_contract_contacts_all,',') = 0 THEN
            l_contract_contacts_role_name   :=    l_user_name;
            l_contract_contacts_role_desc   :=    l_display_name;
       ELSE

             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Multiple Contacts exists, so creating adhoc role');
        END IF;



  	    l_contract_contacts_role_name  := l_contact_role_name||'_'||l_item_key;



		l_contract_contacts_role_desc :=l_contact_role_name;

        --create ad hoc workflow role
        WF_DIRECTORY.createAdHocRole( role_name => l_contract_contacts_role_name,
          role_display_name => l_contract_contacts_role_desc,
          role_description  => 'Repository Ad Hoc Role',
          notification_preference =>'MAILHTML',
          role_users        => l_contract_contacts_all,
          expiration_date   => SYSDATE + 1
        );
       END IF;

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Calling wf_engine.CreateProcess()');
        END IF;

        --Create the process
        wf_engine.CreateProcess(
          itemtype  => l_item_type,
          itemkey   => l_item_key,
          process   => l_process_name);

        --set standard parameter
        wf_engine.SetItemUserKey (
          itemtype  => l_item_type,
          itemkey   => l_item_key,
          userkey   => l_item_key);

        --set process owner
        wf_engine.SetItemOwner (
          itemtype  => l_item_type,
          itemkey   => l_item_key,
          owner     => fnd_global.user_name);

        --set contracts role parameter
        wf_engine.SetItemAttrText (
          itemtype  => l_item_type,
          itemkey   => l_item_key,
          aname     => l_item_contract_contacts,
          avalue    => l_contract_contacts_role_name);

        --set contract id parameter
        wf_engine.SetItemAttrText (
          itemtype  => l_item_type,
          itemkey   => l_item_key,
          aname     => l_item_contract_id,
          avalue    => p_contract_id);

        --set contract number parameter
        wf_engine.SetItemAttrText (
          itemtype  => l_item_type,
          itemkey   => l_item_key,
          aname     => l_item_contract_number,
          avalue    => p_contract_number);

        --set contract version parameter
        wf_engine.SetItemAttrText (
          itemtype  => l_item_type,
          itemkey   => l_item_key,
          aname     => l_item_contract_version,
          avalue    => p_contract_version);

        --set message text, one message for already expired contract
        --and one for contract about to expire
        IF (p_expired_flag = 'Y') THEN
          l_doc_type := OKC_API.get_contract_type(p_contract_id);
          l_resolved_msg_name := OKC_API.resolve_message(l_message_code_expired,l_doc_type);
          l_resolved_token := OKC_API.resolve_hdr_token(l_doc_type);

          l_msg_code := l_resolved_msg_name;
        ELSE
				  --Acq Plan Message Cleanup
          l_doc_type := OKC_API.get_contract_type(p_contract_id);
          l_resolved_msg_name := OKC_API.resolve_message(l_message_code_about_to_expire,l_doc_type);
          l_resolved_token := OKC_API.resolve_hdr_token(l_doc_type);
          --l_msg_code := l_message_code_about_to_expire;
          l_msg_code := l_resolved_msg_name;
        END IF;

        fnd_message.clear;
        --set message name
        fnd_message.set_name(
          application =>l_app_name,
          name        =>l_msg_code);
        --set message tokens
        fnd_message.set_token(
          token => 'HDR_TOKEN',
          value => l_resolved_token);

        fnd_message.set_token(
          token => l_message_token_con_number,
          value => p_contract_number);
        fnd_message.set_token(
          token => l_message_token_con_version,
          value => p_contract_version);

        --get fnd message
        l_subject_text := fnd_message.get;

        --set message subject
        wf_engine.SetItemAttrText (
          itemtype  => l_item_type,
          itemkey   => l_item_key,
          aname     => l_item_message_subject,
          avalue    => l_subject_text);

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Calling wf_engine.StartProcess()');
        END IF;

        --Start the process
        wf_engine.StartProcess(
            itemtype  => l_item_type,
            itemkey   => l_item_key);

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Updating okc_rep_contracts_all and okc_rep_contract_vers with wf_exp_ntf_item_key ' || l_item_key);
        END IF;

        --update contracts with sent notifications
        UPDATE okc_rep_contracts_all c
        SET    c.wf_exp_ntf_item_key = l_item_key
        WHERE  c.contract_id = p_contract_id
        AND    c.contract_version_num = p_contract_version;

        --update contract versions with sent notifications
        UPDATE okc_rep_contract_vers c
        SET    c.wf_exp_ntf_item_key = l_item_key
        WHERE  c.contract_id = p_contract_id
        AND    c.contract_version_num = p_contract_version;

        COMMIT;

      ELSE

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
               'No WF users found for contacts of this contract');
        END IF;

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data );

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(
          FND_LOG.LEVEL_PROCEDURE,
          G_MODULE||l_api_name,
          'Leaving OKC_REP_CONTRACT_PROCESS_PVT.repository_notifier');
      END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(
            FND_LOG.LEVEL_EXCEPTION,
            g_module || l_api_name,
            'Leaving repository_notifier:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursors
        IF (CONTRACT_CONTACTS%ISOPEN) THEN
          CLOSE CONTRACT_CONTACTS ;
        END IF;
        IF (CONTACT_ATTRIBUTES%ISOPEN) THEN
          CLOSE CONTACT_ATTRIBUTES ;
        END IF;
        ROLLBACK TO repository_notifier_pvt;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(
            FND_LOG.LEVEL_EXCEPTION,
            g_module || l_api_name,
            'Leaving repository_notifier:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        --close cursors
        IF (CONTRACT_CONTACTS%ISOPEN) THEN
          CLOSE CONTRACT_CONTACTS ;
        END IF;
        IF (CONTACT_ATTRIBUTES%ISOPEN) THEN
          CLOSE CONTACT_ATTRIBUTES ;
        END IF;
        ROLLBACK TO repository_notifier_pvt;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(
            FND_LOG.LEVEL_EXCEPTION,
            g_module || l_api_name,
            'Leaving repository_notifier because of EXCEPTION: ' || sqlerrm);
        END IF;
        Okc_Api.Set_Message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => SQLCODE,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => SQLERRM);

        --close cursors
        IF (CONTRACT_CONTACTS%ISOPEN) THEN
          CLOSE CONTRACT_CONTACTS ;
        END IF;
        IF (CONTACT_ATTRIBUTES%ISOPEN) THEN
          CLOSE CONTACT_ATTRIBUTES ;
        END IF;
        ROLLBACK TO repository_notifier_pvt;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data
        );

END repository_notifier;

--API name      : cancel_approval
--Type          : Private.
--Function      : Aborts the contract approval workflow process.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_id         IN NUMBER       Required
--                   Id of the contract to be processed
--              : p_contract_version    IN NUMBER       Required
--                   Version of the contract to be processed
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
PROCEDURE cancel_approval(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2,
        p_contract_id                  IN NUMBER,
        p_contract_version             IN NUMBER,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2

  ) IS
    l_api_name      VARCHAR2(30);
    l_api_version       NUMBER;
    l_wf_type  wf_item_activity_statuses.item_type%TYPE;
    l_wf_key   wf_item_activity_statuses.item_key%TYPE;
    l_contract_status okc_rep_contracts_all.contract_status_code%TYPE;
    l_contract_number okc_rep_contracts_all.contract_number%TYPE;

    CURSOR contract_csr IS
        SELECT wf_item_type, wf_item_key, contract_status_code, contract_number
        FROM okc_rep_contracts_all
        WHERE contract_id = p_contract_id;

    CURSOR csr_child_notification(chld_item_key VARCHAR2) IS
    SELECT ITEM_KEY FROM  wf_notifications WHERE ITEM_KEY LIKE Concat(chld_item_key,'\_%') ESCAPE '\'
    AND STATUS='OPEN';


  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_REP_CONTRACT_PROCESS_PVT.cancel_approval');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Id is: ' || p_contract_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Contract Version is: ' || p_contract_version);
    END IF;
    l_api_name := 'cancel_approval';
    l_api_version := 1.0;

    -- Standard Start of API savepoint
    SAVEPOINT submit_contract_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Get workflow information of the contract's approval process
    OPEN contract_csr;
    FETCH contract_csr into l_wf_type, l_wf_key, l_contract_status, l_contract_number;
    IF(contract_csr%NOTFOUND) THEN
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION ,
                    G_MODULE||l_api_name,
                                 'Invalid Contract Id: '|| p_contract_id);
        END IF;
        CLOSE contract_csr;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_CONTRACT_ID_MSG,
                            p_token1       => G_CONTRACT_ID_TOKEN,
                            p_token1_value => to_char(p_contract_id));
        RAISE FND_API.G_EXC_ERROR;
        -- RAISE NO_DATA_FOUND;
    END IF;
    CLOSE contract_csr;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Calling WF_ENGINE.AbortProcess');
    END IF;

    -- Check the status of the contract is Pending Approval before aborting the approval process
    IF (l_contract_status = G_STATUS_PENDING_APPROVAL) THEN

      -- Call WF API to abort the approval process
      WF_ENGINE.AbortProcess(
        itemtype => l_wf_type,
        itemkey  => l_wf_key,
        result    => 'COMPLETE:',
        verify_lock => false,
        cascade   => true);

      FOR rec_child_notification IN csr_child_notification(l_wf_key)
      LOOP
          WF_ENGINE.AbortProcess(
            itemtype => l_wf_type,
            itemkey  => rec_child_notification.ITEM_KEY,
            result    => 'COMPLETE:',
            verify_lock => false,
            cascade   => true);
      END LOOP;


    ELSE

      -- Show an error message
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_CANEL_APPROVAL_ERROR_MSG,
                          p_token1       => G_CONTRACT_NUM_TOKEN,
                          p_token1_value => l_contract_number);
      RAISE FND_API.G_EXC_ERROR;

    END IF;


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_UTIL_PVT.change_contract_status');
    END IF;

    -- Update the contract status and add a record in OKC_REP_CON_STATUS_HIST table.
    OKC_REP_UTIL_PVT.change_contract_status(
      p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_contract_id         => p_contract_id,
      p_contract_version    => p_contract_version,
      p_status_code         => G_STATUS_DRAFT,
      p_user_id             => fnd_global.user_id,
      p_note                => NULL,
      x_msg_data            => x_msg_data,
      x_msg_count           => x_msg_count,
      x_return_status       => x_return_status);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_UTIL_PVT.change_contract_status return status is: '
          || x_return_status);
    END IF;
    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------------------


    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Calling OKC_REP_UTIL_PVT.add_approval_hist_record');
    END IF;

    -- Add a record in ONC_REP_CON_APPROVALS table.
    OKC_REP_UTIL_PVT.add_approval_hist_record(
      p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_contract_id         => p_contract_id,
      p_contract_version    => p_contract_version,
      p_action_code         => G_ACTION_ABORTED,
      p_user_id             => fnd_global.user_id,
      p_note                => NULL,
      x_msg_data            => x_msg_data,
      x_msg_count           => x_msg_count,
      x_return_status       => x_return_status);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'OKC_REP_UTIL_PVT.add_approval_hist_record return status is: '
          || x_return_status);
    END IF;
    -------------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------------------

    COMMIT WORK;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Leaving OKC_REP_CONTRACT_PROCESS_PVT.cancel_approval');
    END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving cancel_approval:FND_API.G_EXC_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO submit_contract_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving cancel_approval:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        ROLLBACK TO submit_contract_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                 g_module || l_api_name,
                 'Leaving cancel_approval because of EXCEPTION: ' || sqlerrm);
        END IF;
        --close cursors
        IF (contract_csr%ISOPEN) THEN
          CLOSE contract_csr ;
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        ROLLBACK TO submit_contract_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

  END cancel_approval;

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- This following API is not used anywhere now but this will be used once we take up
-- the FND Document Sequence for auto generating contract number. Currently
-- it is not used because the FND Document Sequence is not supporting multi-org.
-------------------------------------------------------------------------
-------------------------------------------------------------------------
--API name      : get_next_contract_number
--Type          : Private.
--Function      : Gets next available number to use for a contract number
--                using FND Document Sequencing.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_contract_number     IN VARCHAR2     Optional
--                   Number of the contract
--              : p_org_id              IN NUMBER       Required
--                   Id of the contract organization
--              : p_info_only           IN VARCHAR2     Optional
--                   Default = 'N'
--OUT           : x_contract_number     OUT  NUMBER
--              : x_auto_number_enabled OUT  VARCHAR2(1)
--              : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
PROCEDURE get_next_contract_number(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      p_contract_number              IN VARCHAR2 := NULL,
      p_org_id                       IN NUMBER,
      p_info_only                    IN VARCHAR2,
      x_contract_number              OUT NOCOPY NUMBER,
      x_auto_number_enabled          OUT NOCOPY VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2)
  IS
    l_api_name      VARCHAR2(30);
    l_api_version       NUMBER;
    l_doc_category_code   FND_DOC_SEQUENCE_CATEGORIES.CODE%TYPE;
    l_set_Of_Books_id     NUMBER;
    l_db_sequence_name    FND_DOCUMENT_SEQUENCES.DB_SEQUENCE_NAME%TYPE;
    l_doc_sequence_type   FND_DOCUMENT_SEQUENCES.TYPE%TYPE;
    l_doc_sequence_name   FND_DOCUMENT_SEQUENCES.NAME%TYPE;
    l_seqassid            FND_DOC_SEQUENCE_ASSIGNMENTS.DOC_SEQUENCE_ASSIGNMENT_ID%TYPE;
    l_Prd_Tbl_Name        FND_DOCUMENT_SEQUENCES.TABLE_NAME%TYPE;
    l_Aud_Tbl_Name        FND_DOCUMENT_SEQUENCES.AUDIT_TABLE_NAME%TYPE;
    l_Msg_Flag            FND_DOCUMENT_SEQUENCES.MESSAGE_FLAG%TYPE;
    l_doc_sequence_value  NUMBER;
    l_doc_sequence_id     NUMBER;
    l_profile_doc_seq     VARCHAR2(1);
    l_result    NUMBER;
    l_row_notfound    BOOLEAN := FALSE;
    l_contract_number     OKC_REP_CONTRACTS_ALL.CONTRACT_NUMBER%TYPE;


    CURSOR l_get_sob_csr IS
      SELECT OI2.ORG_INFORMATION3 SET_OF_BOOKS_ID
      FROM  HR_ORGANIZATION_INFORMATION OI1,
            HR_ORGANIZATION_INFORMATION OI2,
            HR_ALL_ORGANIZATION_UNITS OU
      WHERE OI1.ORGANIZATION_ID = OU.ORGANIZATION_ID AND
            OI2.ORGANIZATION_ID = OU.ORGANIZATION_ID AND
            OI1.ORG_INFORMATION_CONTEXT = 'CLASS' AND
            OI2.ORG_INFORMATION_CONTEXT = 'Operating Unit Information' AND
            OI1.ORG_INFORMATION1 = 'OPERATING_UNIT'AND
            OI1.ORGANIZATION_ID = p_org_id;

    CURSOR l_ensure_unique_csr (p_contract_number IN VARCHAR2) IS
      SELECT CONTRACT_NUMBER
      FROM   OKC_REP_CONTRACTS_ALL
      WHERE  CONTRACT_NUMBER = p_contract_number
      AND    ROWNUM < 2;

    BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Entered OKC_REP_CONTRACT_PROCESS_PVT.get_next_contract_number');
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Org Id is: ' || p_org_id);
      END IF;
      l_api_name := 'get_next_contract_number';
      l_api_version := 1.0;

      -- Standard Start of API savepoint
      SAVEPOINT submit_contract_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Get value of the profile option "Sequential Numbering"
      l_profile_doc_seq :=  fnd_profile.value('UNIQUE:SEQ_NUMBERS');

      IF p_info_only = 'Y' AND
         l_profile_doc_seq = 'N' THEN
        x_auto_number_enabled := FND_API.G_FALSE;
        return;
      END IF;


      OPEN l_get_sob_csr;
      FETCH l_get_sob_csr into l_set_of_books_id;
      l_row_notfound := l_get_sob_csr%NOTFOUND;
      CLOSE l_get_sob_csr;

      IF l_row_notfound THEN
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'Set of book id not found');
        END IF;

        CLOSE l_get_sob_csr;
        RAISE FND_API.G_EXC_ERROR ;
      END IF;
      l_row_notfound    := FALSE;
      l_doc_category_code := substr(Fnd_Profile.Value('OKC_REP_CON_NUM_DOC_SEQ_CATEGORY'),1,30);

      l_result := fnd_seqnum.get_seq_info(
                     app_id   =>  510 ,
                     cat_code   =>  l_doc_category_code,
                     sob_id   =>  l_set_of_books_id,
                     met_code =>  NULL,
                     trx_date =>  sysdate,
                     docseq_id  =>  l_doc_sequence_id,
                     docseq_type  =>  l_doc_sequence_type,
                     docseq_name  =>  l_doc_sequence_name,
                     db_seq_name  =>  l_db_sequence_name,
                     seq_ass_id =>  l_seqassid,
                     prd_tab_name =>  l_Prd_Tbl_Name,
                     aud_tab_name =>  l_Aud_Tbl_Name,
                     msg_flag =>  l_msg_flag,
                     suppress_error =>  'N' ,
                     suppress_warn  =>  'Y');

      IF l_result <>  FND_SEQNUM.SEQSUCC   THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_info_only = 'Y'  THEN
        IF l_doc_sequence_type <> 'M' THEN
          x_auto_number_enabled := FND_API.G_TRUE;
        ELSE
          x_auto_number_enabled := FND_API.G_FALSE;
        END IF;
        return;
      END IF;


      IF ( l_doc_sequence_type <> 'M')  THEN
        l_result := fnd_seqnum.get_seq_val(
                         app_id        => 510,
                         cat_code      => l_doc_category_code,
                         sob_id        => l_set_of_books_id,
                         met_code      => null,
                         trx_date      => sysdate,
                         seq_val       => l_doc_sequence_value,
                         docseq_id    =>  l_doc_sequence_id);

        IF l_result <> 0   THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_contract_number := TO_CHAR(l_doc_sequence_value);
        END IF;

        OPEN l_ensure_unique_csr (x_contract_number);
        FETCH l_ensure_unique_csr into l_contract_number;
        l_row_notfound := l_ensure_unique_csr%NOTFOUND;
        CLOSE l_ensure_unique_csr;

        IF l_row_notfound THEN
           NULL;   -- dups do not exist.
        ELSE
           -- Show duplicate Contract number error message

           Okc_Api.Set_Message(p_app_name   => G_APP_NAME,
                               p_msg_name   => G_INVALID_CONTRACT_NUMBER_MSG);
           RAISE FND_API.G_EXC_ERROR;

        END IF;

      ELSIF (l_doc_sequence_type = 'M') THEN
        x_contract_number := p_contract_number;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                  'Leaving OKC_REP_CONTRACT_PROCESS_PVT.get_next_contract_number');
      END IF;

      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                   g_module || l_api_name,
                   'Leaving get_next_contract_number:FND_API.G_EXC_ERROR Exception');
          END IF;
          --close cursors
          IF (l_ensure_unique_csr%ISOPEN) THEN
            CLOSE l_ensure_unique_csr ;
          END IF;

          IF (l_get_sob_csr%ISOPEN) THEN
            CLOSE l_get_sob_csr ;
          END IF;

          ROLLBACK TO submit_contract_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data
          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                   g_module || l_api_name,
                   'Leaving get_next_contract_number:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
          END IF;
          --close cursors
          IF (l_ensure_unique_csr%ISOPEN) THEN
            CLOSE l_ensure_unique_csr ;
          END IF;

          IF (l_get_sob_csr%ISOPEN) THEN
            CLOSE l_get_sob_csr ;
          END IF;

          ROLLBACK TO submit_contract_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data
          );

        WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                   g_module || l_api_name,
                   'Leaving get_next_contract_number because of EXCEPTION: ' || sqlerrm);
          END IF;
          --close cursors
          IF (l_ensure_unique_csr%ISOPEN) THEN
            CLOSE l_ensure_unique_csr ;
          END IF;

          IF (l_get_sob_csr%ISOPEN) THEN
            CLOSE l_get_sob_csr ;
          END IF;

          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UNEXPECTED_ERROR,
                              p_token1       => G_SQLCODE_TOKEN,
                              p_token1_value => sqlcode,
                              p_token2       => G_SQLERRM_TOKEN,
                              p_token2_value => sqlerrm);
          ROLLBACK TO submit_contract_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data
          );

  END get_next_contract_number;



END OKC_REP_CONTRACT_PROCESS_PVT;

/
