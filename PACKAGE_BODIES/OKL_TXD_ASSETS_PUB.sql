--------------------------------------------------------
--  DDL for Package Body OKL_TXD_ASSETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXD_ASSETS_PUB" as
/* $Header: OKLPASDB.pls 115.7 2004/04/13 10:31:43 rnaik noship $ */
-- Start of comments
--
-- Procedure Name  : create_txd_asset_Def
-- Description     : creates Transaction Asset Line details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_rec                     IN adpv_rec_type,
    x_adpv_rec                     OUT NOCOPY adpv_rec_type) IS

    l_adpv_rec                           adpv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_TXD_ASSET_DEF';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint create_txd_asset_Def_pub;
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
    l_adpv_rec := p_adpv_rec;
    g_adpv_rec := l_adpv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_adpv_rec.id := p_adpv_rec.id;
    l_adpv_rec.object_version_number := p_adpv_rec.object_version_number;
    OKL_TXD_ASSETS_PVT.create_txd_asset_Def(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_asdv_rec      => l_adpv_rec,
                                            x_asdv_rec      => x_adpv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_adpv_rec := x_adpv_rec;
    g_adpv_rec := l_adpv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO create_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO create_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO create_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'create_txd_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END create_txd_asset_Def;

-- Start of comments
--
-- Procedure Name  : create_txd_asset_Def
-- Description     : creates Transaction Asset Line details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE create_txd_asset_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_tbl                     IN adpv_tbl_type,
    x_adpv_tbl                     OUT NOCOPY adpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_adpv_tbl.COUNT > 0 THEN
      i := p_adpv_tbl.FIRST;
      LOOP
        create_txd_asset_Def(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_adpv_rec      => p_adpv_tbl(i),
                             x_adpv_rec      => x_adpv_tbl(i));
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
        EXIT WHEN (i = p_adpv_tbl.LAST);
        i := p_adpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO create_txd_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO create_txd_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO create_txd_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'create_txd_asset_Def_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END create_txd_asset_Def;
-- Start of comments
--
-- Procedure Name  : update_txd_asset_Def
-- Description     : Update Transaction Asset Lines
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_txd_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_rec                     IN adpv_rec_type,
    x_adpv_rec                     OUT NOCOPY adpv_rec_type) IS
  l_adpv_rec adpv_rec_type;
  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name CONSTANT VARCHAR2(30) := 'update_txd_asset_Def';
  l_api_version	CONSTANT NUMBER := 1;
  BEGIN
    savepoint update_txd_asset_Def_pub;
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
    l_adpv_rec := p_adpv_rec;
    g_adpv_rec := l_adpv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_adpv_rec.id := p_adpv_rec.id;
    l_adpv_rec.object_version_number := p_adpv_rec.object_version_number;
    OKL_TXD_ASSETS_PVT.update_txd_asset_Def(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_asdv_rec      => l_adpv_rec,
                                            x_asdv_rec      => x_adpv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_adpv_rec := x_adpv_rec;
    g_adpv_rec := l_adpv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO update_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO update_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO update_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'update_txd_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);

  END update_txd_asset_Def;

-- Start of comments
--
-- Procedure Name  : update_txd_asset_Def
-- Description     : Update Transaction Asset Line details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_txd_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_tbl                     IN adpv_tbl_type,
    x_adpv_tbl                     OUT NOCOPY adpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_adpv_tbl.COUNT > 0 THEN
      i := p_adpv_tbl.FIRST;
      LOOP
        update_txd_asset_Def(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_adpv_rec      => p_adpv_tbl(i),
          x_adpv_rec      => x_adpv_tbl(i));
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_adpv_tbl.LAST);
        i := p_adpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO update_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO update_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO update_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'update_txd_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END update_txd_asset_Def;

-- Start of comments
--
-- Procedure Name  : delete_txd_asset_Def
-- Description     : Delete Transaction Asset Line details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_txd_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_rec                     IN adpv_rec_type) IS

  l_adpv_rec adpv_rec_type;
  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name CONSTANT VARCHAR2(30) := 'delete_txd_asset_Def';
  l_api_version	CONSTANT NUMBER := 1;
  BEGIN
    savepoint delete_txd_asset_Def_pub;
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
    l_adpv_rec := p_adpv_rec;
    g_adpv_rec := l_adpv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_adpv_rec.id := p_adpv_rec.id;
    l_adpv_rec.object_version_number := p_adpv_rec.object_version_number;
    OKL_TXD_ASSETS_PVT.delete_txd_asset_Def(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_asdv_rec      => l_adpv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_adpv_rec := l_adpv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO delete_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO delete_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO delete_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'delete_txd_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END delete_txd_asset_Def;

-- Start of comments
--
-- Procedure Name  : delete_txd_asset_Def
-- Description     : Delete Transaction Asset Line details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_txd_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_tbl                     IN adpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_adpv_tbl.COUNT > 0 THEN
      i := p_adpv_tbl.FIRST;
      LOOP
        delete_txd_asset_Def(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_adpv_rec      => p_adpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_adpv_tbl.LAST);
        i := p_adpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO delete_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO delete_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO delete_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'delete_txd_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END delete_txd_asset_Def;

-- Start of comments
--
-- Procedure Name  : lock_txd_asset_Def
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure lock_txd_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_rec                     IN adpv_rec_type) IS
  l_adpv_rec adpv_rec_type;
  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name CONSTANT VARCHAR2(30) := 'lock_txd_asset_Def';
  l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint lock_txd_asset_Def_pub;
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
    l_adpv_rec := p_adpv_rec;
    -- Business API call  section
    l_adpv_rec.id := p_adpv_rec.id;
    l_adpv_rec.object_version_number := p_adpv_rec.object_version_number;
    OKL_TXD_ASSETS_PVT.lock_txd_asset_Def(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_asdv_rec      => l_adpv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_adpv_rec := l_adpv_rec;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO lock_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO lock_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO lock_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'lock_txd_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  end lock_txd_asset_Def;


-- Start of comments
--
-- Procedure Name  : lock_txd_asset_Def
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure lock_txd_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_tbl                     IN adpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_adpv_tbl.COUNT > 0 THEN
      i := p_adpv_tbl.FIRST;
      LOOP
        lock_txd_asset_Def(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_adpv_rec      => p_adpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_adpv_tbl.LAST);
        i := p_adpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO lock_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO lock_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO lock_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'lock_txd_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  end lock_txd_asset_Def;


-- Start of comments
--
-- Procedure Name  : validate_txd_asset_Def
-- Description     : Validate Transaction Asset Line details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure validate_txd_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_rec                     IN adpv_rec_type) IS
  l_adpv_rec adpv_rec_type;
  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name CONSTANT VARCHAR2(30) := 'validate_txd_asset_Def';
  l_api_version	CONSTANT NUMBER := 1;
  BEGIN
    savepoint validate_txd_asset_Def_pub;
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
    l_adpv_rec := p_adpv_rec;
    g_adpv_rec := l_adpv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_adpv_rec.id := p_adpv_rec.id;
    l_adpv_rec.object_version_number := p_adpv_rec.object_version_number;
    OKL_TXD_ASSETS_PVT.validate_txd_asset_Def(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_asdv_rec      => l_adpv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_adpv_rec := l_adpv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO validate_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO validate_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO validate_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'validate_txd_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  end validate_txd_asset_Def;


-- Start of comments
--
-- Procedure Name  : validate_txd_asset_Def
-- Description     : Validate Transaction Asset Line details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure validate_txd_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_adpv_tbl                     IN adpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_adpv_tbl.COUNT > 0 THEN
      i := p_adpv_tbl.FIRST;
      LOOP
        validate_txd_asset_Def(
          p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_adpv_rec      => p_adpv_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_adpv_tbl.LAST);
        i := p_adpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
        When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO validate_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO validate_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO validate_txd_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'validate_txd_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  end validate_txd_asset_Def;


END OKL_TXD_ASSETS_PUB;


/
