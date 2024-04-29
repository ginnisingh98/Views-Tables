--------------------------------------------------------
--  DDL for Package Body OKL_VERSION_FA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VERSION_FA_PUB" as
/* $Header: OKLPVFAB.pls 115.3 2004/04/13 11:26:44 rnaik noship $ */


-- Start of comments
--
-- Procedure Name  : CREATE_SUP_INV_DTLS
-- Description     : creates version FA for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_version_fa(p_api_version      IN  NUMBER,
                                 p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_vfav_rec      IN  vfav_rec_type,
                                 x_vfav_rec      OUT NOCOPY vfav_rec_type) IS

    l_vfav_rec                           vfav_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_VERSION_FA';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint create_version_fa_pub;
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
    l_vfav_rec := p_vfav_rec;
    g_vfav_rec := l_vfav_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_vfav_rec.id := p_vfav_rec.id;
    l_vfav_rec.object_version_number := p_vfav_rec.object_version_number;
    OKL_VERSION_FA_PVT.Create_version_fa(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_vfav_rec      => l_vfav_rec,
                                            x_vfav_rec      => x_vfav_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_vfav_rec := x_vfav_rec;
    g_vfav_rec := l_vfav_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO create_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO create_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO create_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'create_version_fa_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END create_version_fa;

-- Start of comments
--
-- Procedure Name  : CREATE_VERSION_FA
-- Description     : creates txl itm insts for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE create_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type,
    x_vfav_tbl                     OUT NOCOPY vfav_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_vfav_tbl.COUNT > 0 THEN
      i := p_vfav_tbl.FIRST;
      LOOP
        create_version_fa(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_vfav_rec      => p_vfav_tbl(i),
                             x_vfav_rec      => x_vfav_tbl(i));
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
        EXIT WHEN (i = p_vfav_tbl.LAST);
        i := p_vfav_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO create_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO create_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO create_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'create_version_fa_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END create_version_fa;

-- Start of comments
--
-- Procedure Name  : UPDATE_VERSION_FA
-- Description     : updates txl itm insts for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_version_fa(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_vfav_rec      IN         vfav_rec_type,
                                 x_vfav_rec      OUT NOCOPY vfav_rec_type) IS

    l_vfav_rec                           vfav_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'UPDATE_VERSION_FA';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint update_version_fa_pub;
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
    l_vfav_rec := p_vfav_rec;
    g_vfav_rec := l_vfav_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_vfav_rec.id := p_vfav_rec.id;
    l_vfav_rec.object_version_number := p_vfav_rec.object_version_number;
    OKL_VERSION_FA_PVT.update_version_fa(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_vfav_rec      => l_vfav_rec,
                                            x_vfav_rec      => x_vfav_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_vfav_rec := x_vfav_rec;
    g_vfav_rec := l_vfav_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO update_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO update_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO update_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'update_version_fa_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END update_version_fa;

-- Start of comments
--
-- Procedure Name  : UPDATE_VERSION_FA
-- Description     : updates txl itm insts for contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE update_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type,
    x_vfav_tbl                     OUT NOCOPY vfav_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_vfav_tbl.COUNT > 0 THEN
      i := p_vfav_tbl.FIRST;
      LOOP
        update_version_fa(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_vfav_rec      => p_vfav_tbl(i),
                             x_vfav_rec      => x_vfav_tbl(i));
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
        EXIT WHEN (i = p_vfav_tbl.LAST);
        i := p_vfav_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO update_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO update_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO update_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'update_version_fa_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END update_version_fa;

-- Start of comments
--
-- Procedure Name  : DELETE_VERSION_FA
-- Description     : deletes txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_version_fa(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_vfav_rec      IN         vfav_rec_type) IS

    l_vfav_rec                           vfav_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'DELETE_VERSION_FA';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint delete_version_fa_pub;
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
    l_vfav_rec := p_vfav_rec;
    g_vfav_rec := l_vfav_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_vfav_rec.id := p_vfav_rec.id;
    l_vfav_rec.object_version_number := p_vfav_rec.object_version_number;
    OKL_VERSION_FA_PVT.delete_version_fa(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_vfav_rec      => l_vfav_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_vfav_rec := l_vfav_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO delete_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO delete_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO delete_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'delete_version_fa_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END delete_version_fa;

-- Start of comments
--
-- Procedure Name  : DELETE_VERSION_FA
-- Description     : deletes txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE delete_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_vfav_tbl.COUNT > 0 THEN
      i := p_vfav_tbl.FIRST;
      LOOP
        delete_version_fa(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_vfav_rec      => p_vfav_tbl(i));
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
        EXIT WHEN (i = p_vfav_tbl.LAST);
        i := p_vfav_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO delete_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO delete_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO delete_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'delete_version_fa_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END delete_version_fa;


-- Start of comments
--
-- Procedure Name  : VALIDATE_VERSION_FA
-- Description     : validates txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_version_fa(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_vfav_rec      IN         vfav_rec_type) IS

    l_vfav_rec                           vfav_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'VALIDATE_VERSION_FA';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint validate_version_fa_pub;
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
    l_vfav_rec := p_vfav_rec;
    g_vfav_rec := l_vfav_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_vfav_rec.id := p_vfav_rec.id;
    l_vfav_rec.object_version_number := p_vfav_rec.object_version_number;
    OKL_VERSION_FA_PVT.validate_version_fa(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_vfav_rec      => l_vfav_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_vfav_rec := l_vfav_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO validate_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO validate_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO validate_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'validate_version_fa_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END validate_version_fa;

-- Start of comments
--
-- Procedure Name  : VALIDATE_VERSION_FA
-- Description     : validates txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE validate_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_vfav_tbl.COUNT > 0 THEN
      i := p_vfav_tbl.FIRST;
      LOOP
        validate_version_fa(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_vfav_rec      => p_vfav_tbl(i));
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
        EXIT WHEN (i = p_vfav_tbl.LAST);
        i := p_vfav_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO validate_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO validate_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO validate_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'validate_version_fa_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END validate_version_fa;


-- Start of comments
--
-- Procedure Name  : LOCK_VERSION_FA
-- Description     : locks txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_version_fa(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_vfav_rec      IN         vfav_rec_type) IS

    l_vfav_rec                           vfav_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'LOCK_VERSION_FA';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint lock_version_fa_pub;
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
    l_vfav_rec := p_vfav_rec;
    -- Business API call  section
    l_vfav_rec.id := p_vfav_rec.id;
    l_vfav_rec.object_version_number := p_vfav_rec.object_version_number;
    OKL_VERSION_FA_PVT.lock_version_fa(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_vfav_rec      => l_vfav_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_vfav_rec := l_vfav_rec;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO lock_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO lock_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO lock_version_fa_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'lock_version_fa_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END lock_version_fa;

-- Start of comments
--
-- Procedure Name  : LOCK_VERSION_FA
-- Description     : locks txl itm insts for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE lock_version_fa(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_vfav_tbl.COUNT > 0 THEN
      i := p_vfav_tbl.FIRST;
      LOOP
        lock_version_fa(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_vfav_rec      => p_vfav_tbl(i));
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
        EXIT WHEN (i = p_vfav_tbl.LAST);
        i := p_vfav_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO lock_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO lock_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO lock_version_fa_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'lock_version_fa_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END lock_version_fa;

END OKL_VERSION_FA_PUB;


/
