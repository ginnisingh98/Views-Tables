--------------------------------------------------------
--  DDL for Package Body OKL_SPLIT_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SPLIT_CONTRACT_PUB" as
/* $Header: OKLPSKHB.pls 115.7 2004/01/24 00:54:12 rravikir noship $ */
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PUB';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PUB';
  G_PKG_NAME	                CONSTANT  VARCHAR2(200) := 'OKL_SPLIT_CONTRACT_PUB';
  G_APP_NAME		        CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

-----------------------------------------------------------------------------------------------
------------------------ Main Process for Split Contract Contract------------------------------
-----------------------------------------------------------------------------------------------
  Procedure create_split_contract(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_old_contract_number  IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE,
            p_new_khr_top_line     IN  ktl_tbl_type,
            x_new_khr_top_line     OUT NOCOPY ktl_tbl_type)  IS
    l_api_name               CONSTANT VARCHAR2(30) := 'SPLIT_CONTRACT';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint create_split_contract_pub;
    x_return_status     := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to check for call compatibility.
    IF NOT (FND_API.Compatible_API_Call (l_api_version,
	                                 p_api_version,
			                 l_api_name,
		                         G_PKG_NAME)) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF (FND_API.to_Boolean( p_init_msg_list )) THEN
       FND_MSG_PUB.initialize;
    END IF;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_SPLIT_CONTRACT_PVT.create_split_contract(p_api_version         => p_api_version,
                                                 p_init_msg_list       => p_init_msg_list,
                                                 x_return_status       => x_return_status,
                                                 x_msg_count           => x_msg_count,
                                                 x_msg_data            => x_msg_data,
                                                 p_old_contract_number => p_old_contract_number,
                                                 p_new_khr_top_line    => p_new_khr_top_line,
                                                 x_new_khr_top_line    => x_new_khr_top_line);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO create_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO create_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO create_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_SPLIT_CONTRACT_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END create_split_contract;
-----------------------------------------------------------------------------------------------
------------------------- Main Process for post split of Contract -----------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE post_split_contract(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_commit               IN  VARCHAR2 DEFAULT OKL_API.G_TRUE,
            p_new1_contract_id     IN  OKC_K_HEADERS_V.ID%TYPE,
            p_new2_contract_id     IN  OKC_K_HEADERS_V.ID%TYPE,
            x_trx1_number          OUT NOCOPY NUMBER,
            x_trx1_status          OUT NOCOPY VARCHAR2,
            x_trx2_number          OUT NOCOPY NUMBER,
            x_trx2_status          OUT NOCOPY VARCHAR2) IS
    l_api_name               CONSTANT VARCHAR2(30) := 'SPLIT_CONTRACT';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint post_split_contract_pub;
    x_return_status     := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to check for call compatibility.
    IF NOT (FND_API.Compatible_API_Call (l_api_version,
	                                 p_api_version,
			                 l_api_name,
		                         G_PKG_NAME)) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF (FND_API.to_Boolean( p_init_msg_list )) THEN
       FND_MSG_PUB.initialize;
    END IF;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_SPLIT_CONTRACT_PVT.post_split_contract(
                               p_api_version         => p_api_version,
                               p_init_msg_list       => p_init_msg_list,
                               x_return_status       => x_return_status,
                               x_msg_count           => x_msg_count,
                               x_msg_data            => x_msg_data,
                               p_commit              => p_commit,
                               p_new1_contract_id    => p_new1_contract_id,
                               p_new2_contract_id    => p_new2_contract_id,
                               x_trx1_number         => x_trx1_number,
                               x_trx1_status         => x_trx1_status,
                               x_trx2_number         => x_trx2_number,
                               x_trx2_status         => x_trx2_status);

    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_SPLIT_CONTRACT_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END post_split_contract;
-----------------------------------------------------------------------------------------------
------------------------- Set the context for Split contract process --------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE set_context(
            p_api_version          IN  NUMBER,
            p_init_msg_list    IN  VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_resp_id          IN  NUMBER,
            p_appl_id          IN  NUMBER,
            p_user_id          IN  NUMBER,
            x_return_status    OUT NOCOPY VARCHAR2) IS
    l_api_name               CONSTANT VARCHAR2(30) := 'SPLIT_CONTRACT';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint post_split_contract_pub;
    x_return_status     := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to check for call compatibility.
    IF NOT (FND_API.Compatible_API_Call (l_api_version,
	                                     p_api_version,
			                             l_api_name,
		                                 G_PKG_NAME)) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF (FND_API.to_Boolean( p_init_msg_list )) THEN
       FND_MSG_PUB.initialize;
    END IF;

    OKL_SPLIT_CONTRACT_PVT.set_context (
                               p_api_version    => p_api_version,
                               p_init_msg_list  => p_init_msg_list,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_resp_id        => p_resp_id,
                               p_appl_id        => p_appl_id,
                               p_user_id        => p_user_id,
                               x_return_status  => x_return_status);

    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_SPLIT_CONTRACT_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
  END set_context;
-----------------------------------------------------------------------------------------------
------------------------- Main Process for checking Split contract process --------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE check_split_process (
            p_api_version      IN  NUMBER,
            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            x_process_action   OUT NOCOPY VARCHAR2,
            x_transaction_id   OUT NOCOPY OKL_TRX_CONTRACTS.ID%TYPE,
            x_child_chrid1     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE,
            x_child_chrid2     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE,
            p_contract_id      IN  OKC_K_HEADERS_V.ID%TYPE) IS
    l_api_name               CONSTANT VARCHAR2(30) := 'SPLIT_CONTRACT';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint post_split_contract_pub;
    x_return_status     := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to check for call compatibility.
    IF NOT (FND_API.Compatible_API_Call (l_api_version,
	                                     p_api_version,
			                             l_api_name,
		                                 G_PKG_NAME)) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF (FND_API.to_Boolean( p_init_msg_list )) THEN
       FND_MSG_PUB.initialize;
    END IF;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_SPLIT_CONTRACT_PVT.check_split_process (
                               p_api_version      => p_api_version,
                               p_init_msg_list    => p_init_msg_list,
                               x_return_status    => x_return_status,
                               x_msg_count        => x_msg_count,
                               x_msg_data         => x_msg_data,
                               x_process_action   => x_process_action,
                               x_transaction_id   => x_transaction_id,
                               x_child_chrid1     => x_child_chrid1,
                               x_child_chrid2     => x_child_chrid2,
                               p_contract_id      => p_contract_id);

    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_SPLIT_CONTRACT_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END check_split_process;
-----------------------------------------------------------------------------------------------
------------------------- Main Process for canceling Split contract process --------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE cancel_split_process (
                              p_api_version      IN  NUMBER,
                              p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status    OUT NOCOPY VARCHAR2,
                              x_msg_count        OUT NOCOPY NUMBER,
                              x_msg_data         OUT NOCOPY VARCHAR2,
                              p_contract_id      IN  OKC_K_HEADERS_V.ID%TYPE) IS
    l_api_name               CONSTANT VARCHAR2(30) := 'SPLIT_CONTRACT';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint post_split_contract_pub;
    x_return_status     := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to check for call compatibility.
    IF NOT (FND_API.Compatible_API_Call (l_api_version,
	                                     p_api_version,
			                             l_api_name,
		                                 G_PKG_NAME)) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF (FND_API.to_Boolean( p_init_msg_list )) THEN
       FND_MSG_PUB.initialize;
    END IF;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_SPLIT_CONTRACT_PVT.cancel_split_process (
                               p_api_version      => p_api_version,
                               p_init_msg_list    => p_init_msg_list,
                               x_return_status    => x_return_status,
                               x_msg_count        => x_msg_count,
                               x_msg_data         => x_msg_data,
                               p_contract_id      => p_contract_id);

    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO post_split_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_SPLIT_CONTRACT_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END cancel_split_process;
END OKL_SPLIT_CONTRACT_PUB;

/
