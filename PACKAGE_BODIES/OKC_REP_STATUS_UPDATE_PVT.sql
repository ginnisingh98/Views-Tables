--------------------------------------------------------
--  DDL for Package Body OKC_REP_STATUS_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_STATUS_UPDATE_PVT" AS
/* $Header: OKCVREPSTATCHB.pls 120.1 2006/03/31 11:34:00 vamuru noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PARTY_TYPE_INTERNAL     CONSTANT VARCHAR2(12) := 'INTERNAL_ORG';
  G_PKG_NAME                CONSTANT VARCHAR2(200) := 'OKC_REP_CONTRACT_SEARCH_PVT';
  G_APP_NAME                CONSTANT VARCHAR2(3)   := 'OKC';
  G_MODULE                  CONSTANT VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';

  G_UNEXPECTED_ERROR        CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN           CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN           CONSTANT VARCHAR2(200) := 'ERROR_CODE';

  G_RETURN_CODE_SUCCESS     CONSTANT VARCHAR2(1) :='0';
  G_RETURN_CODE_WARNING     CONSTANT VARCHAR2(1) := '1';
  G_RETURN_CODE_ERROR       CONSTANT VARCHAR2(1) := '2';

  -- Contract status codes
  G_REP_CON_STATUS_SIGNED CONSTANT VARCHAR2(200) := 'SIGNED';
  G_REP_CON_STATUS_TERMINATED CONSTANT VARCHAR2(200) := 'TERMINATED';

  ---------------------------------------------------------------------------
  -- START: Procedures and Functions
  ---------------------------------------------------------------------------

-- Start of comments
--API name      : contract_status_updater
--Type          : Private.
--Function      : Updates status for contracts
--                reaching their termination date
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Required
--              : p_status              IN VARCHAR2     Required
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
PROCEDURE contract_status_updater(
  p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2,
  p_status        IN          VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2)

  IS

    l_api_version NUMBER;
    l_api_name    VARCHAR2(32);

    CURSOR contracts_cur IS
    SELECT
      contract_id, contract_version_num,
      contract_number,
      contract_name
    FROM  okc_rep_contracts_all
    WHERE termination_date is not null
    AND   contract_status_code = G_REP_CON_STATUS_SIGNED
    AND   trunc(termination_date) <= TRUNC(SYSDATE);

    CURSOR contract_vers_cur IS
    SELECT
      contract_id, contract_version_num,
      contract_number,
      contract_name
    FROM  okc_rep_contract_vers v
    WHERE termination_date IS NOT NULL
    AND   contract_status_code = G_REP_CON_STATUS_SIGNED
    AND   trunc(termination_date) <= trunc(SYSDATE);

    TYPE selected_contracts_tbl IS TABLE OF contracts_cur%ROWTYPE;
    TYPE selected_vers_contracts_tbl IS TABLE OF contract_vers_cur%ROWTYPE;
    TYPE NumList IS TABLE OF okc_rep_contracts_all.contract_id%TYPE NOT NULL
          INDEX BY PLS_INTEGER;
    TYPE VersionNumList IS TABLE OF okc_rep_contracts_all.contract_version_num%TYPE NOT NULL
          INDEX BY PLS_INTEGER;

    selected_contracts selected_contracts_tbl;
    selected_vers_contracts selected_vers_contracts_tbl;
    selected_contract_ids NumList;
    selected_vers_contract_ids NumList;
    selected_vers_contract_ver VersionNumList;

    l_batch_size number(4) := 1000;
    l_first_iteration VARCHAR2(1);
    l_count number;


  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '***** BEGIN contract_status_updater *****');

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_status = ' || p_status);

    l_api_name    := 'contract_status_updater';
    l_api_version := 1.0;
    l_first_iteration := 'Y';
    l_count := 0;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Update the status of the terminated contracts in the active contracts table
    OPEN contracts_cur;
    LOOP -- the following statement fetches 1000 rows or less in each iteration

      FETCH contracts_cur BULK COLLECT INTO selected_contracts
      LIMIT l_batch_size;

      EXIT WHEN selected_contracts.COUNT = 0;

      -- Show the text Contract Details only once
      IF (l_first_iteration = 'Y') THEN

        l_first_iteration := 'N';

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
        FND_FILE.PUT_LINE(FND_FILE.LOG, '');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_CONTRACT_DETAILS'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '================');
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_CONTRACT_DETAILS'));
        FND_FILE.PUT_LINE(FND_FILE.LOG, '================');

      END IF;


      FOR i IN 1..NVL(selected_contracts.LAST, -1) LOOP
        l_count := l_count + 1;

        -- Populate the current contract details into concurrent output and log files

        -- Add Contract Name
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_ATTR_CON_NAME') || '               : '|| selected_contracts(i).contract_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_ATTR_CON_NAME') || '               : '|| selected_contracts(i).contract_name);

        -- Add Contract Number
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_NUMBER') || '             : '|| selected_contracts(i).contract_number);
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_NUMBER') || '             : '|| selected_contracts(i).contract_number);

        -- Add Contract Version Number
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_VER_NUM') || '            : '|| selected_contracts(i).contract_version_num);
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_VER_NUM') || '            : '|| selected_contracts(i).contract_version_num);

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
        FND_FILE.PUT_LINE(FND_FILE.LOG, '');

        -- Prepare a number array of contract ids, this is required by the UPDATE
        -- statement under FORALL as it will not take selected_contracts(i).contract_id in the WHERE clause
        -- Getting the following compilation error
        -- PLS-00436: implementation restriction: cannot reference fields of BULK In-BIND table of records
        selected_contract_ids(i) := selected_contracts(i).contract_id;

      END LOOP;

      FORALL j IN NVL(selected_contract_ids.FIRST,0)..NVL(selected_contract_ids.LAST,-1)
        UPDATE okc_rep_contracts_all
        SET    contract_status_code = p_status,
               last_update_date = sysdate,
               last_updated_by = Fnd_Global.User_Id,
               last_update_login = Fnd_Global.Login_Id
        WHERE  contract_id = selected_contract_ids(j);

    END LOOP;

    IF contracts_cur%ISOPEN THEN
      CLOSE contracts_cur ;
    END IF;

    -- Update the status of the terminated contracts in the archived contracts table
    OPEN contract_vers_cur;
    LOOP -- the following statement fetches 1000 rows or less in each iteration

      FETCH contract_vers_cur BULK COLLECT INTO selected_vers_contracts
      LIMIT l_batch_size;

      EXIT WHEN selected_vers_contracts.COUNT = 0;

      -- Show the text Contract Details only once
      IF (l_first_iteration = 'Y') THEN

        l_first_iteration := 'N';

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
        FND_FILE.PUT_LINE(FND_FILE.LOG, '');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_CONTRACT_DETAILS'));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '================');
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_CONTRACT_DETAILS'));
        FND_FILE.PUT_LINE(FND_FILE.LOG, '================');

      END IF;

      FOR i IN 1..NVL(selected_vers_contracts.LAST, -1) LOOP

        l_count := l_count + 1;

        -- Populate the current contract details into concurrent output and log files

        -- Add Contract Name
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_ATTR_CON_NAME') || '               : '|| selected_vers_contracts(i).contract_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_ATTR_CON_NAME') || '               : '|| selected_vers_contracts(i).contract_name);

        -- Add Contract Number
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_NUMBER') || '             : '|| selected_vers_contracts(i).contract_number);
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_NUMBER') || '             : '|| selected_vers_contracts(i).contract_number);

        -- Add Contract Version Number
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_VER_NUM') || '            : '|| selected_vers_contracts(i).contract_version_num);
        FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_SW_ATTR_CON_VER_NUM') || '            : '|| selected_vers_contracts(i).contract_version_num);

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
        FND_FILE.PUT_LINE(FND_FILE.LOG, '');

        -- Prepare a number array of contract ids and version numbers, this is required by the UPDATE
        -- statement under FORALL as it will not take selected_vers_contracts(i).contract_id in the WHERE clause
        -- Getting the following compilation error
        -- PLS-00436: implementation restriction: cannot reference fields of BULK In-BIND table of records
        selected_vers_contract_ids(i) := selected_vers_contracts(i).contract_id;
        selected_vers_contract_ver(i) := selected_vers_contracts(i).contract_version_num;

      END LOOP;

      FORALL j IN NVL(selected_vers_contract_ids.FIRST,0)..NVL(selected_vers_contract_ids.LAST,-1)
        UPDATE okc_rep_contract_vers
        SET    contract_status_code = p_status,
               last_update_date = sysdate,
               last_updated_by = Fnd_Global.User_Id,
               last_update_login = Fnd_Global.Login_Id
        WHERE  contract_id = selected_vers_contract_ids(j)
        AND    contract_version_num = selected_vers_contract_ver(j);

    END LOOP;

    IF contract_vers_cur%ISOPEN THEN
      CLOSE contract_vers_cur ;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_UPD_STS_SUMMARY') || ' : ' || l_count);
    FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_UPD_STS_SUMMARY') || ' : ' || l_count);

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_UPD_STS_ERROR'));
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_UPD_STS_ERROR'));

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_UPD_STS_SYS_ERR') || ' ' || sqlerrm);
      FND_FILE.PUT_LINE(FND_FILE.LOG, OKC_TERMS_UTIL_PVT.get_message(G_APP_NAME, 'OKC_REP_UPD_STS_SYS_ERR') || ' ' || sqlerrm);

      ROLLBACK;

      --close cursors
      IF contracts_cur%ISOPEN THEN
        CLOSE contracts_cur ;
      END IF;
      IF contract_vers_cur%ISOPEN THEN
        CLOSE contract_vers_cur ;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      x_msg_count := 1;
      x_msg_data := substr(SQLERRM, 1, 200);

      Okc_Api.Set_Message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_UNEXPECTED_ERROR,
        p_token1       => G_SQLCODE_TOKEN,
        p_token1_value => SQLCODE,
        p_token2       => G_SQLERRM_TOKEN,
        p_token2_value => SQLERRM);

      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
      );

  END contract_status_updater;

-- Start of comments
--API name      : contract_status_update_manager
--Type          : Private.
--Function      : Called from Concurrent Manager to update
--                status for contract reaching their
--                termination date
--Pre-reqs      : None.
--Parameters    :
--IN            : p_status IN VARCHAR2 Required
--OUT           : errbuf  OUT NOCOPY VARCHAR2
--              : retcode OUT NOCOPY VARCHAR2
--Note          :
-- End of comments

  PROCEDURE contract_status_update_manager(
    p_status IN VARCHAR2,
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2)
  IS
    l_api_version   NUMBER;
    l_api_name      VARCHAR2(32);
    l_init_msg_list VARCHAR2(2000);
    l_msg_data      VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_return_status VARCHAR2(2000);
    l_status        VARCHAR2(32);

  BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG, '***** BEGIN contract_status_update_manager *****');

    l_api_name    := 'contract_status_update_manager';
    l_api_version   := 1.0;
    l_init_msg_list := FND_API.G_FALSE;
    l_status := 'NONE';

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_status = (' || p_status || ')');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_status = (' || l_status || ')');

    IF p_status IS NULL OR LENGTH(TRIM(p_status)) = 0 THEN
      l_status := G_REP_CON_STATUS_TERMINATED;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_status = (' || l_status || ')');

    contract_status_updater(
      p_api_version   => l_api_version,
      p_init_msg_list => l_init_msg_list,
      p_status        => l_status,
      x_msg_data      => l_msg_data,
      x_msg_count     => l_msg_count,
      x_return_status => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      retcode := G_RETURN_CODE_ERROR;
      errbuf := substr(FND_MSG_PUB.Get(), 1, 200);
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, '***** END contract_status_update_manager() *****');

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, '***** EXCEPTION OTHERS*****');
      FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);

      retcode := G_RETURN_CODE_ERROR;
      errbuf := substr(SQLERRM, 1, 200);

  END contract_status_update_manager;

END OKC_REP_STATUS_UPDATE_PVT;

/
