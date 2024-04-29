--------------------------------------------------------
--  DDL for Package Body OKL_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RELEASE_PUB" as
/* $Header: OKLPREKB.pls 120.3 2005/10/30 03:33:47 appldev noship $ */
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PUB';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PUB';
  G_PKG_NAME	                CONSTANT  VARCHAR2(200) := 'OKL_RELEASE_PUB';
  G_APP_NAME		        CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

-----------------------------------------------------------------------------------------------
------------------------ Main Process for Create Release Contract------------------------------
-----------------------------------------------------------------------------------------------
 --Bug 3948361
  Procedure create_release_contract(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_chr_id               IN  OKC_K_HEADERS_B.ID%TYPE,
            p_release_reason_code  IN  VARCHAR2,
            p_release_description  IN  VARCHAR2,
            p_trx_date             IN  DATE,
            p_source_trx_id        IN  NUMBER,
            p_source_trx_type      IN  VARCHAR2,
            x_tcnv_rec             OUT NOCOPY tcnv_rec_type,
            x_release_chr_id       OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE)  IS
    l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_RELEASE_CONTRACT';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint create_release_contract_pub;
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

    --Bug# 3948361

    OKL_RELEASE_PVT.create_release_contract(p_api_version         => p_api_version,
                                            p_init_msg_list       => p_init_msg_list,
                                            x_return_status       => x_return_status,
                                            x_msg_count           => x_msg_count,
                                            x_msg_data            => x_msg_data,
                                            p_chr_id              => p_chr_id,
                                            p_release_reason_code  => p_release_reason_code,
                                            p_release_description  => p_release_description,
                                            p_trx_date             => p_trx_date,
                                            p_source_trx_id        => p_source_trx_id,
                                            p_source_trx_type      => p_source_trx_type,
                                            x_tcnv_rec             => x_tcnv_rec,
                                            x_release_chr_id       => x_release_chr_id
                                            );
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO create_release_contract_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO create_release_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO create_release_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_COPY_ASSET_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END create_release_contract;


-----------------------------------------------------------------------------------------------
------------------------ Main Process for Activate Release Contract------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE activate_release_contract(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_chr_id             IN  OKC_K_HEADERS_B.ID%TYPE)  IS
    l_api_name               CONSTANT VARCHAR2(30) := 'ACTIVATE_RELEASE_CONTRACT';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint activate_release_contract_pub;
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
    OKL_RELEASE_PVT.activate_release_contract(p_api_version   => p_api_version,
                                              p_init_msg_list => p_init_msg_list,
                                              x_return_status => x_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data,
                                              p_chr_id        => p_chr_id);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO activate_release_contract_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO activate_release_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO activate_release_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_COPY_ASSET_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END activate_release_contract;

End OKL_RELEASE_PUB;

/
