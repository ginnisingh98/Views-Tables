--------------------------------------------------------
--  DDL for Package Body OKL_TXL_ITM_INSTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXL_ITM_INSTS_PUB" as
/* $Header: OKLPITIB.pls 115.7 2004/05/08 00:09:37 dedey noship $ */


-- Start of comments
--
-- Procedure Name  : CREATE_TXL_ITM_INSTS
-- Description     : creates txl itm insts for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_txl_itm_insts(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_iipv_rec      IN         iipv_rec_type,
                                 x_iipv_rec      OUT NOCOPY iipv_rec_type) IS

    l_iipv_rec                           iipv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_TXL_ITM_INSTS';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint create_txl_iti_pub;
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
    l_iipv_rec := p_iipv_rec;
    g_iipv_rec := l_iipv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_iipv_rec.id := p_iipv_rec.id;
    l_iipv_rec.object_version_number := p_iipv_rec.object_version_number;
    OKL_TXL_ITM_INSTS_PVT.Create_txl_itm_insts(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_iivv_rec      => l_iipv_rec,
                                            x_iivv_rec      => x_iipv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_iipv_rec := x_iipv_rec;
    g_iipv_rec := l_iipv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO create_txl_iti_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO create_txl_iti_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO create_txl_iti_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'create_txl_itm_insts_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END create_txl_itm_insts;

-- Start of comments
--
-- Procedure Name  : CREATE_TXL_ITM_INSTS
-- Description     : creates txl itm insts for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE create_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_tbl                     IN iipv_tbl_type,
    x_iipv_tbl                     OUT NOCOPY iipv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_iipv_tbl.COUNT > 0 THEN
      i := p_iipv_tbl.FIRST;
      LOOP
        create_txl_itm_insts(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_iipv_rec      => p_iipv_tbl(i),
                             x_iipv_rec      => x_iipv_tbl(i));
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
        EXIT WHEN (i = p_iipv_tbl.LAST);
        i := p_iipv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO create_txl_iti_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO create_txl_iti_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO create_txl_iti_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'create_txl_itm_insts_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END create_txl_itm_insts;

-- Start of comments
--
-- Procedure Name  : UPDATE_TXL_ITM_INSTS
-- Description     : updates txl itm insts for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_txl_itm_insts(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_iipv_rec      IN         iipv_rec_type,
                                 x_iipv_rec      OUT NOCOPY iipv_rec_type) IS

    l_iipv_rec                           iipv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'UPDATE_TXL_ITM_INSTS';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint update_txl_iti_pub;
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
    l_iipv_rec := p_iipv_rec;
    g_iipv_rec := l_iipv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_iipv_rec.id := p_iipv_rec.id;
    l_iipv_rec.object_version_number := p_iipv_rec.object_version_number;
    OKL_TXL_ITM_INSTS_PVT.update_txl_itm_insts(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_iivv_rec      => l_iipv_rec,
                                            x_iivv_rec      => x_iipv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_iipv_rec := x_iipv_rec;
    g_iipv_rec := l_iipv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO update_txl_iti_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO update_txl_iti_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO update_txl_iti_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'update_txl_itm_insts_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END update_txl_itm_insts;

-- Start of comments
--
-- Procedure Name  : UPDATE_TXL_ITM_INSTS
-- Description     : updates txl itm insts for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE update_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_tbl                     IN iipv_tbl_type,
    x_iipv_tbl                     OUT NOCOPY iipv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_iipv_tbl.COUNT > 0 THEN
      i := p_iipv_tbl.FIRST;
      LOOP
        update_txl_itm_insts(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_iipv_rec      => p_iipv_tbl(i),
                             x_iipv_rec      => x_iipv_tbl(i));
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
        EXIT WHEN (i = p_iipv_tbl.LAST);
        i := p_iipv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO update_txl_iti_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO update_txl_iti_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO update_txl_iti_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'update_txl_itm_insts_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END update_txl_itm_insts;

-- Start of comments
--
-- Procedure Name  : DELETE_TXL_ITM_INSTS
-- Description     : deletes txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_txl_itm_insts(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_iipv_rec      IN         iipv_rec_type) IS

    l_iipv_rec                           iipv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'DELETE_TXL_ITM_INSTS';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint delete_txl_itm_insts_pub;
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
    l_iipv_rec := p_iipv_rec;
    g_iipv_rec := l_iipv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_iipv_rec.id := p_iipv_rec.id;
    l_iipv_rec.object_version_number := p_iipv_rec.object_version_number;
    OKL_TXL_ITM_INSTS_PVT.delete_txl_itm_insts(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_iivv_rec      => l_iipv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_iipv_rec := l_iipv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO delete_txl_itm_insts_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO delete_txl_itm_insts_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO delete_txl_itm_insts_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'delete_txl_itm_insts_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END delete_txl_itm_insts;

-- Start of comments
--
-- Procedure Name  : DELETE_TXL_ITM_INSTS
-- Description     : deletes txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE delete_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_tbl                     IN iipv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_iipv_tbl.COUNT > 0 THEN
      i := p_iipv_tbl.FIRST;
      LOOP
        delete_txl_itm_insts(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_iipv_rec      => p_iipv_tbl(i));
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
        EXIT WHEN (i = p_iipv_tbl.LAST);
        i := p_iipv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO delete_txl_itm_insts_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO delete_txl_itm_insts_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO delete_txl_itm_insts_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'delete_txl_itm_insts_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END delete_txl_itm_insts;


-- Start of comments
--
-- Procedure Name  : VALIDATE_TXL_ITM_INSTS
-- Description     : validates txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_txl_itm_insts(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_iipv_rec      IN         iipv_rec_type) IS

    l_iipv_rec                           iipv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'VALIDATE_TXL_ITM_INSTS';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint validate_txl_itm_insts_pub;
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
    l_iipv_rec := p_iipv_rec;
    g_iipv_rec := l_iipv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_iipv_rec.id := p_iipv_rec.id;
    l_iipv_rec.object_version_number := p_iipv_rec.object_version_number;
    OKL_TXL_ITM_INSTS_PVT.validate_txl_itm_insts(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_iivv_rec      => l_iipv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_iipv_rec := l_iipv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO validate_txl_itm_insts_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO validate_txl_itm_insts_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO validate_txl_itm_insts_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'validate_txl_itm_insts_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END validate_txl_itm_insts;

-- Start of comments
--
-- Procedure Name  : VALIDATE_TXL_ITM_INSTS
-- Description     : validates txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE validate_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_tbl                     IN iipv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_iipv_tbl.COUNT > 0 THEN
      i := p_iipv_tbl.FIRST;
      LOOP
        validate_txl_itm_insts(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_iipv_rec      => p_iipv_tbl(i));
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
        EXIT WHEN (i = p_iipv_tbl.LAST);
        i := p_iipv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO validate_txl_itm_insts_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO validate_txl_itm_insts_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO validate_txl_itm_insts_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'validate_txl_itm_insts_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END validate_txl_itm_insts;


-- Start of comments
--
-- Procedure Name  : LOCK_TXL_ITM_INSTS
-- Description     : locks txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_txl_itm_insts(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_iipv_rec      IN         iipv_rec_type) IS

    l_iipv_rec                           iipv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'LOCK_TXL_ITM_INSTS';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint lock_txl_itm_insts_pub;
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
    l_iipv_rec := p_iipv_rec;
    -- Business API call  section
    l_iipv_rec.id := p_iipv_rec.id;
    l_iipv_rec.object_version_number := p_iipv_rec.object_version_number;
    OKL_TXL_ITM_INSTS_PVT.lock_txl_itm_insts(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_iivv_rec      => l_iipv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_iipv_rec := l_iipv_rec;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO lock_txl_itm_insts_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO lock_txl_itm_insts_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO lock_txl_itm_insts_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'lock_txl_itm_insts_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END lock_txl_itm_insts;

-- Start of comments
--
-- Procedure Name  : LOCK_TXL_ITM_INSTS
-- Description     : locks txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE lock_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iipv_tbl                     IN iipv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_iipv_tbl.COUNT > 0 THEN
      i := p_iipv_tbl.FIRST;
      LOOP
        lock_txl_itm_insts(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_iipv_rec      => p_iipv_tbl(i));
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
        EXIT WHEN (i = p_iipv_tbl.LAST);
        i := p_iipv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO lock_txl_itm_insts_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO lock_txl_itm_insts_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO lock_txl_itm_insts_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'lock_txl_itm_insts_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END lock_txl_itm_insts;

  -- Start of comments
  -- Procedure Name  : reset_item_srl_number
  --
  -- Description     : This API resets non-serialized item's
  --                   serial number to NULL.
  --
  -- Business Rules  : Blank out serial numbers from an asset
  --                   for which associated item is not serialized.
  --
  --                   In case p_asset_line_id is NULL, the program
  --                   will update serial number(s) to NULL for all
  --                   asset line(s) having non-serialized item.
  --                   Assets with Serialized items will be ignored.
  --
  --                   In case p_asset_line_id is NOT NULL and the item
  --                   associated to it is serialized, the program
  --                   will raise an error and will not update
  --                   serial number(s).
  --
  -- Parameters      : p_chr_id - Contract ID (Must be not null)
  --                            - Contract must not be BOOKED
  --                   p_asset_line_id - Asset Top Line ID
  --                                   - Either provide a valid line ID
  --                                     or NULL for all assets
  --
  -- Version         : 1.0, dedey
  -- End of comments

   PROCEDURE reset_item_srl_number(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_chr_id                       IN NUMBER,
     p_asset_line_id                IN NUMBER
   ) IS

   l_api_name          CONSTANT VARCHAR2(30) := 'RESET_ITEM_SRL_NUMBER';
   l_return_status     VARCHAR2(1);

   BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- Call start_activity to create savepoint, check compatibility
     -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status);
     -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     okl_txl_itm_insts_pvt.reset_item_srl_number (
                                       p_api_version      =>  p_api_version,
                                       p_init_msg_list    =>  p_init_msg_list,
                                       x_return_status    =>  x_return_status,
                                       x_msg_count        =>  x_msg_count,
                                       x_msg_data         =>  x_msg_data,
                                       p_chr_id           =>  p_chr_id,
                                       p_asset_line_id    =>  p_asset_line_id
                                      );

     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

     OKC_API.END_ACTIVITY (x_msg_count
                           ,x_msg_data );

   EXCEPTION

     WHEN OKC_API.G_EXCEPTION_ERROR THEN
     x_return_status := OKC_API.HANDLE_EXCEPTIONS
					 (l_api_name,
					 G_PKG_NAME,
					 'OKC_API.G_RET_STS_ERROR',
					 x_msg_count,
					 x_msg_data,
					 '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                (l_api_name,
					G_PKG_NAME,
					'OKC_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count,
					x_msg_data,
					'_PUB');
     WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                 (l_api_name,
	                                  G_PKG_NAME,
					  'OTHERS',
					  x_msg_count,
					  x_msg_data,
					  '_PUB');
   END reset_item_srl_number;

END OKL_TXL_ITM_INSTS_PUB;


/
