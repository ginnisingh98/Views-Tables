--------------------------------------------------------
--  DDL for Package Body OKL_VERSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VERSION_PUB" as
/* $Header: OKLPVERB.pls 115.6 2002/12/02 04:57:21 arajagop noship $ */

  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PUB';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PUB';
  G_PKG_NAME	                CONSTANT  VARCHAR2(200) := 'OKL_VERSION_PUB';
  G_APP_NAME		        CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

-----------------------------------------------------------------------------------------------
------------------------------ Main Process for Version Contract-------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE version_contract(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cvmv_rec       IN  cvmv_rec_type,
            x_cvmv_rec       OUT NOCOPY cvmv_rec_type,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE)  IS
    l_api_name               CONSTANT VARCHAR2(30) := 'VERSION_CONTRACT';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint version_contract_pub;
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
    OKL_VERSION_PVT.version_contract(p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_cvmv_rec      => p_cvmv_rec,
                                     x_cvmv_rec      => x_cvmv_rec,
                                     p_commit        => p_commit);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO version_contract_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO version_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO version_contract_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_COPY_ASSET_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END version_contract;
-----------------------------------------------------------------------------------------------
------------------------------ Main Process for Version Contract-------------------------------
-----------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : version_contract
-- Description     : creates new version of a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE version_contract(p_api_version    IN NUMBER,
                             p_init_msg_list  IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data	      OUT NOCOPY VARCHAR2,
                             p_cvmv_tbl       IN cvmv_tbl_type,
                             p_commit         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_cvmv_tbl        OUT NOCOPY cvmv_tbl_type) IS
    i			    NUMBER := 0;
    l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_cvmv_tbl.COUNT > 0 THEN
      i := p_cvmv_tbl.FIRST;
      LOOP
       	version_contract(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => l_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_cvmv_rec      => p_cvmv_tbl(i),
			 p_commit     	 => p_commit,
                         x_cvmv_rec      => x_cvmv_tbl(i));
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
              x_return_status := l_return_status;
              RAISE FND_API.G_EXC_ERROR;
           ELSE
              x_return_status := l_return_status;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
       	EXIT WHEN (i = p_cvmv_tbl.LAST);
       	i := p_cvmv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO version_contract_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO version_contract_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO version_contract_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'version_contract_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END Version_Contract;
-----------------------------------------------------------------------------------------------
------------------------------ Main Process for Save Version ----------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE save_version(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE)  IS
    l_api_name               CONSTANT VARCHAR2(30) := 'SAVE_VERSION';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint save_version_pub;
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
    OKL_VERSION_PVT.save_version(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_chr_id        => p_chr_id,
                                 p_commit        => p_commit);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO save_version_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO save_version_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO save_version_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_COPY_ASSET_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END save_version;

-----------------------------------------------------------------------------------------------
------------------------- Main Process for Erase Saved Version --------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE erase_saved_version(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE)  IS
    l_api_name               CONSTANT VARCHAR2(30) := 'ERASE_SAVED_VERSION';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint erase_saved_version_pub;
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
    OKL_VERSION_PVT.erase_saved_version(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_chr_id        => p_chr_id,
                                 p_commit        => p_commit);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO erase_saved_version_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO erase_saved_version_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO erase_saved_version_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_COPY_ASSET_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END erase_saved_version;

-----------------------------------------------------------------------------------------------
---------------------------- Main Process for Restore Version ---------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE restore_version(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_commit         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE)  IS
    l_api_name               CONSTANT VARCHAR2(30) := 'RESTORE_VERSION';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint restore_version_pub;
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
    OKL_VERSION_PVT.restore_version(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_chr_id        => p_chr_id,
                                 p_commit        => p_commit);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO restore_version_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO restore_version_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO restore_version_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_COPY_ASSET_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END restore_version;
END OKL_VERSION_PUB;

/
