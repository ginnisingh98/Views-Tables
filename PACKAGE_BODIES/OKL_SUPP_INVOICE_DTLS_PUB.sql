--------------------------------------------------------
--  DDL for Package Body OKL_SUPP_INVOICE_DTLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUPP_INVOICE_DTLS_PUB" as
/* $Header: OKLPSIDB.pls 115.3 2004/04/13 11:07:30 rnaik noship $ */


-- Start of comments
--
-- Procedure Name  : CREATE_SUP_INV_DTLS
-- Description     : creates Supplier Invoice Details for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_sup_inv_dtls(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_sidv_rec      IN         sidv_rec_type,
                                 x_sidv_rec      OUT NOCOPY sidv_rec_type) IS

    l_sidv_rec                           sidv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_SUP_INV_DTLS';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint create_sup_inv_pub;
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
    l_sidv_rec := p_sidv_rec;
    g_sidv_rec := l_sidv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_sidv_rec.id := p_sidv_rec.id;
    l_sidv_rec.object_version_number := p_sidv_rec.object_version_number;
    OKL_SUPP_INVOICE_DTLS_PVT.Create_sup_inv_dtls(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_sidv_rec      => l_sidv_rec,
                                            x_sidv_rec      => x_sidv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_sidv_rec := x_sidv_rec;
    g_sidv_rec := l_sidv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO create_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO create_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO create_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'create_sup_inv_dtls_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END create_sup_inv_dtls;

-- Start of comments
--
-- Procedure Name  : CREATE_SUP_INV_DTLS
-- Description     : creates txl itm insts for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE create_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type,
    x_sidv_tbl                     OUT NOCOPY sidv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_sidv_tbl.COUNT > 0 THEN
      i := p_sidv_tbl.FIRST;
      LOOP
        create_sup_inv_dtls(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_sidv_rec      => p_sidv_tbl(i),
                             x_sidv_rec      => x_sidv_tbl(i));
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
        EXIT WHEN (i = p_sidv_tbl.LAST);
        i := p_sidv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO create_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO create_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO create_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'create_sup_inv_dtls_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END create_sup_inv_dtls;

-- Start of comments
--
-- Procedure Name  : UPDATE_SUP_INV_DTLS
-- Description     : updates txl itm insts for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_sup_inv_dtls(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_sidv_rec      IN         sidv_rec_type,
                                 x_sidv_rec      OUT NOCOPY sidv_rec_type) IS

    l_sidv_rec                           sidv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'UPDATE_SUP_INV_DTLS';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint update_sup_inv_pub;
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
    l_sidv_rec := p_sidv_rec;
    g_sidv_rec := l_sidv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_sidv_rec.id := p_sidv_rec.id;
    l_sidv_rec.object_version_number := p_sidv_rec.object_version_number;
    OKL_SUPP_INVOICE_DTLS_PVT.update_sup_inv_dtls(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_sidv_rec      => l_sidv_rec,
                                            x_sidv_rec      => x_sidv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_sidv_rec := x_sidv_rec;
    g_sidv_rec := l_sidv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO update_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO update_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO update_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'update_sup_inv_dtls_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END update_sup_inv_dtls;

-- Start of comments
--
-- Procedure Name  : UPDATE_SUP_INV_DTLS
-- Description     : updates txl itm insts for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE update_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type,
    x_sidv_tbl                     OUT NOCOPY sidv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_sidv_tbl.COUNT > 0 THEN
      i := p_sidv_tbl.FIRST;
      LOOP
        update_sup_inv_dtls(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_sidv_rec      => p_sidv_tbl(i),
                             x_sidv_rec      => x_sidv_tbl(i));
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
        EXIT WHEN (i = p_sidv_tbl.LAST);
        i := p_sidv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO update_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO update_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO update_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'update_sup_inv_dtls_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END update_sup_inv_dtls;

-- Start of comments
--
-- Procedure Name  : DELETE_SUP_INV_DTLS
-- Description     : deletes txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_sup_inv_dtls(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_sidv_rec      IN         sidv_rec_type) IS

    l_sidv_rec                           sidv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'DELETE_SUP_INV_DTLS';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint delete_sup_inv_pub;
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
    l_sidv_rec := p_sidv_rec;
    g_sidv_rec := l_sidv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_sidv_rec.id := p_sidv_rec.id;
    l_sidv_rec.object_version_number := p_sidv_rec.object_version_number;
    OKL_SUPP_INVOICE_DTLS_PVT.delete_sup_inv_dtls(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_sidv_rec      => l_sidv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_sidv_rec := l_sidv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO delete_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO delete_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO delete_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'delete_sup_inv_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END delete_sup_inv_dtls;

-- Start of comments
--
-- Procedure Name  : DELETE_SUP_INV_DTLS
-- Description     : deletes txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE delete_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_sidv_tbl.COUNT > 0 THEN
      i := p_sidv_tbl.FIRST;
      LOOP
        delete_sup_inv_dtls(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_sidv_rec      => p_sidv_tbl(i));
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
        EXIT WHEN (i = p_sidv_tbl.LAST);
        i := p_sidv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO delete_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO delete_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO delete_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'delete_sup_inv_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END delete_sup_inv_dtls;


-- Start of comments
--
-- Procedure Name  : VALIDATE_SUP_INV_DTLS
-- Description     : validates txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_sup_inv_dtls(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_sidv_rec      IN         sidv_rec_type) IS

    l_sidv_rec                           sidv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'VALIDATE_SUP_INV_DTLS';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint validate_sup_inv_pub;
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
    l_sidv_rec := p_sidv_rec;
    g_sidv_rec := l_sidv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_sidv_rec.id := p_sidv_rec.id;
    l_sidv_rec.object_version_number := p_sidv_rec.object_version_number;
    OKL_SUPP_INVOICE_DTLS_PVT.validate_sup_inv_dtls(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_sidv_rec      => l_sidv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_sidv_rec := l_sidv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO validate_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO validate_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO validate_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'validate_sup_inv_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END validate_sup_inv_dtls;

-- Start of comments
--
-- Procedure Name  : VALIDATE_SUP_INV_DTLS
-- Description     : validates txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE validate_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_sidv_tbl.COUNT > 0 THEN
      i := p_sidv_tbl.FIRST;
      LOOP
        validate_sup_inv_dtls(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_sidv_rec      => p_sidv_tbl(i));
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
        EXIT WHEN (i = p_sidv_tbl.LAST);
        i := p_sidv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO validate_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO validate_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO validate_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'validate_sup_inv_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END validate_sup_inv_dtls;


-- Start of comments
--
-- Procedure Name  : LOCK_SUP_INV_DTLS
-- Description     : locks txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_sup_inv_dtls(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_sidv_rec      IN         sidv_rec_type) IS

    l_sidv_rec                           sidv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'LOCK_SUP_INV_DTLS';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint lock_sup_inv_pub;
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
    l_sidv_rec := p_sidv_rec;
    -- Business API call  section
    l_sidv_rec.id := p_sidv_rec.id;
    l_sidv_rec.object_version_number := p_sidv_rec.object_version_number;
    OKL_SUPP_INVOICE_DTLS_PVT.lock_sup_inv_dtls(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_sidv_rec      => l_sidv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_sidv_rec := l_sidv_rec;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO lock_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO lock_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO lock_sup_inv_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'lock_sup_inv_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END lock_sup_inv_dtls;

-- Start of comments
--
-- Procedure Name  : LOCK_SUP_INV_DTLS
-- Description     : locks txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE lock_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_sidv_tbl.COUNT > 0 THEN
      i := p_sidv_tbl.FIRST;
      LOOP
        lock_sup_inv_dtls(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_sidv_rec      => p_sidv_tbl(i));
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
        EXIT WHEN (i = p_sidv_tbl.LAST);
        i := p_sidv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO lock_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO lock_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO lock_sup_inv_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'lock_sup_inv_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END lock_sup_inv_dtls;

END OKL_SUPP_INVOICE_DTLS_PUB;


/
