--------------------------------------------------------
--  DDL for Package Body OKL_TXL_ASSETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXL_ASSETS_PUB" as
/* $Header: OKLPTALB.pls 115.8 2004/04/13 11:23:34 rnaik noship $ */

-- Start of comments
--
-- Procedure Name  : CREATE_TXL_ASSET_LINE
-- Description     : creates txl ass h for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_txl_asset_Def(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_tlpv_rec      IN         tlpv_rec_type,
                                 x_tlpv_rec      OUT NOCOPY tlpv_rec_type) IS

    l_tlpv_rec                           tlpv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_TXL_ASSET_LINE';
    l_api_version	        CONSTANT NUMBER := 1;
  BEGIN
    savepoint create_txl_asset_Def_pub;
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
    l_tlpv_rec := p_tlpv_rec;
    g_tlpv_rec := l_tlpv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_tlpv_rec.id := p_tlpv_rec.id;
    l_tlpv_rec.object_version_number := p_tlpv_rec.object_version_number;
    OKL_TXL_ASSETS_PVT.create_txl_asset_Def(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_talv_rec      => l_tlpv_rec,
                                            x_talv_rec      => x_tlpv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_tlpv_rec := x_tlpv_rec;
    g_tlpv_rec := l_tlpv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO create_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO create_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO create_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'create_txl_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END create_txl_asset_Def;

-- Start of comments
--
-- Procedure Name  : CREATE_TXL_ASSET_LINE
-- Description     : creates selected product option value for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE create_txl_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tlpv_tbl                     IN tlpv_tbl_type,
    x_tlpv_tbl                     OUT NOCOPY tlpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_tlpv_tbl.COUNT > 0 THEN
      i := p_tlpv_tbl.FIRST;
      LOOP
        create_txl_asset_Def(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_tlpv_rec      => p_tlpv_tbl(i),
                             x_tlpv_rec      => x_tlpv_tbl(i));
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
        EXIT WHEN (i = p_tlpv_tbl.LAST);
        i := p_tlpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO create_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO create_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO create_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'create_txl_asset_Def_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END create_txl_asset_Def;

-- Start of comments
--
-- Procedure Name  : UPDATE_TXL_ASSET_LINE
-- Description     : updates txl ass h for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_txl_asset_Def(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_tlpv_rec      IN         tlpv_rec_type,
                                 x_tlpv_rec      OUT NOCOPY tlpv_rec_type) IS

    l_tlpv_rec                           tlpv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'UPDATE_TXL_ASSET_LINE';
    l_api_version	        CONSTANT NUMBER := 1;
  BEGIN
    savepoint update_txl_asset_Def_pub;
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
    l_tlpv_rec := p_tlpv_rec;
    g_tlpv_rec := l_tlpv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_tlpv_rec.id := p_tlpv_rec.id;
    l_tlpv_rec.object_version_number := p_tlpv_rec.object_version_number;
    OKL_TXL_ASSETS_PVT.update_txl_asset_Def(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_talv_rec      => l_tlpv_rec,
                                            x_talv_rec      => x_tlpv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_tlpv_rec := x_tlpv_rec;
    g_tlpv_rec := l_tlpv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO update_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO update_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO update_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'update_txl_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END update_txl_asset_Def;

-- Start of comments
--
-- Procedure Name  : UPDATE_TXL_ASSET_LINE
-- Description     : updates selected product option value for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE update_txl_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tlpv_tbl                     IN tlpv_tbl_type,
    x_tlpv_tbl                     OUT NOCOPY tlpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_tlpv_tbl.COUNT > 0 THEN
      i := p_tlpv_tbl.FIRST;
      LOOP
        update_txl_asset_Def(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_tlpv_rec      => p_tlpv_tbl(i),
                             x_tlpv_rec      => x_tlpv_tbl(i));
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
        EXIT WHEN (i = p_tlpv_tbl.LAST);
        i := p_tlpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO update_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO update_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO update_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'update_txl_asset_Def_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END update_txl_asset_Def;


-- Start of comments
--
-- Procedure Name  : DELETE_TXL_ASSET_LINES
-- Description     : deletes txl asset lines for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_txl_asset_Def(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_tlpv_rec      IN         tlpv_rec_type) IS

    l_tlpv_rec                           tlpv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'DELETE_TXL_ASSET_LINES';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint delete_txl_asset_Def_pub;
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
    l_tlpv_rec := p_tlpv_rec;
    g_tlpv_rec := l_tlpv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_tlpv_rec.id := p_tlpv_rec.id;
    l_tlpv_rec.object_version_number := p_tlpv_rec.object_version_number;
    OKL_TXL_ASSETS_PVT.delete_txl_asset_def(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_talv_rec      => l_tlpv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_tlpv_rec := l_tlpv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO delete_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO delete_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO delete_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'delete_txl_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END delete_txl_asset_Def;

-- Start of comments
--
-- Procedure Name  : DELETE_TXL_ASSET_LINES
-- Description     : deletes txl asset lines for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE delete_txl_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tlpv_tbl                     IN tlpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_tlpv_tbl.COUNT > 0 THEN
      i := p_tlpv_tbl.FIRST;
      LOOP
        delete_txl_asset_Def(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_tlpv_rec      => p_tlpv_tbl(i));
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
        EXIT WHEN (i = p_tlpv_tbl.LAST);
        i := p_tlpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO delete_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO delete_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO delete_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'delete_txl_asset_Def_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END delete_txl_asset_Def;


-- Start of comments
--
-- Procedure Name  : VALIDATE_TXL_ASSET_LINES
-- Description     : validates txl asset lines for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_txl_asset_Def(p_api_version   IN         NUMBER,
                                   p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2,
                                   p_tlpv_rec      IN         tlpv_rec_type) IS

    l_tlpv_rec                           tlpv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'VALIDATE_TXL_ASSET_LINES';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint validate_txl_asset_Def_pub;
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
    l_tlpv_rec := p_tlpv_rec;
    g_tlpv_rec := l_tlpv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_tlpv_rec.id := p_tlpv_rec.id;
    l_tlpv_rec.object_version_number := p_tlpv_rec.object_version_number;
    OKL_TXL_ASSETS_PVT.validate_txl_asset_def(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_talv_rec      => l_tlpv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_tlpv_rec := l_tlpv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO validate_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO validate_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO validate_txl_asset_Def_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'validate_txl_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END validate_txl_asset_Def;

-- Start of comments
--
-- Procedure Name  : VALIDATE_TXL_ASSET_LINES
-- Description     : validates txl asset lines for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE validate_txl_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tlpv_tbl                     IN tlpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_tlpv_tbl.COUNT > 0 THEN
      i := p_tlpv_tbl.FIRST;
      LOOP
        validate_txl_asset_Def(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_tlpv_rec      => p_tlpv_tbl(i));
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
        EXIT WHEN (i = p_tlpv_tbl.LAST);
        i := p_tlpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO validate_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO validate_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO validate_txl_asset_Def_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'validate_txl_asset_Def_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END validate_txl_asset_Def;


-- Start of comments
--
-- Procedure Name  : LOCK_TXL_ASSET_LINE
-- Description     : locks txl asset Lines for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_txl_asset_Def(p_api_version   IN         NUMBER,
                                 p_init_msg_list IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_tlpv_rec      IN         tlpv_rec_type) IS

    l_tlpv_rec                           tlpv_rec_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'LOCK_TXL_ASSET_LINE';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint lock_txl_ass_pub;
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
    -- Business API call  section
    l_tlpv_rec.id := p_tlpv_rec.id;
    l_tlpv_rec.object_version_number := p_tlpv_rec.object_version_number;
    OKL_TXL_ASSETS_PVT.lock_txl_asset_def(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_talv_rec      => l_tlpv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    g_tlpv_rec := l_tlpv_rec;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO lock_txl_ass_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO lock_txl_ass_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO lock_txl_ass_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'lock_txl_asset_Def_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END lock_txl_asset_Def;

-- Start of comments
--
-- Procedure Name  : LOCK_TXL_ASSET_LINE
-- Description     : locks selected product option value for a contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE lock_txl_asset_Def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tlpv_tbl                     IN tlpv_tbl_type) IS
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_tlpv_tbl.COUNT > 0 THEN
      i := p_tlpv_tbl.FIRST;
      LOOP
        lock_txl_asset_Def(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => l_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_tlpv_rec      => p_tlpv_tbl(i));
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
        EXIT WHEN (i = p_tlpv_tbl.LAST);
        i := p_tlpv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN  FND_API.G_EXC_ERROR  THEN
    ROLLBACK  TO lock_txl_ass_pub;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    ROLLBACK  TO lock_txl_ass_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                               p_data  => x_msg_data);
    WHEN  OTHERS  then
    ROLLBACK  TO lock_txl_ass_pub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'lock_txl_asset_Def_pub');
    FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);
  END lock_txl_asset_Def;

END OKL_TXL_ASSETS_PUB;


/
