--------------------------------------------------------
--  DDL for Package Body OKL_CREATE_KLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREATE_KLE_PUB" as
/* $Header: OKLPKLLB.pls 115.9 2004/04/13 10:51:16 rnaik noship $ */

-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_NO_PARENT_RECORD            CONSTANT  VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC  CONSTANT  VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED	        CONSTANT  VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED	        CONSTANT  VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED    CONSTANT  VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE               CONSTANT  VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	        CONSTANT  VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	        CONSTANT  VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED	        CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UPPERCASE_REQ';
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PUB';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PUB';

 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------
  G_FIN_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_MODEL_LINE_LTY_CODE                   OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ITEM';
  G_ADDON_LINE_LTY_CODE                   OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ADD_ITEM';
  G_FA_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FIXED_ASSET';
  G_INST_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM2';
  G_IB_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'INST_ITEM';
  G_ID2                         CONSTANT  VARCHAR2(200) := '#';
  G_TLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'TLS';
  G_SLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'SLS';

-------------------------------------------------------------------------------------------------------
---------------------- Main Process for Updating of Financial Asset Line ------------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE Update_fin_cap_cost(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type) IS

    l_clev_fin_rec                clev_rec_type;
    l_klev_fin_rec                klev_rec_type;

    l_api_name               CONSTANT VARCHAR2(30) := 'UPDATE_FIN_CAP_COST';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint Update_fin_cap_cost_pub;
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
    l_klev_fin_rec := p_klev_rec;
    l_clev_fin_rec := p_clev_rec;
    g_klev_fin_rec := l_klev_fin_rec;
    g_clev_fin_rec := l_clev_fin_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_CREATE_KLE_PVT.Update_fin_cap_cost(p_api_version   => p_api_version,
                                       p_init_msg_list => p_init_msg_list,
                                       x_return_status => x_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data,
                                       P_New_YN        => P_new_yn,
                                       p_asset_number  => p_asset_number,
                                       p_clev_rec      => l_clev_fin_rec,
                                       p_klev_rec      => l_klev_fin_rec,
                                       x_clev_rec      => x_clev_rec,
                                       x_klev_rec      => x_klev_rec);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_klev_fin_rec := x_klev_rec;
    l_clev_fin_rec := x_clev_rec;
    g_klev_fin_rec := l_klev_fin_rec;
    g_clev_fin_rec := l_clev_fin_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR then
      ROLLBACK TO Update_fin_cap_cost_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO Update_fin_cap_cost_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK  TO Update_fin_cap_cost_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_CREATE_KLE_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
  END Update_fin_cap_cost;

-------------------------------------------------------------------------------------------------------
---------------------------- Main Process for Creation of Add on Line ---------------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE create_add_on_line(p_api_version   IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
                              p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
                              p_clev_tbl       IN  clev_tbl_type,
                              p_klev_tbl       IN  klev_tbl_type,
                              p_cimv_tbl       IN  cimv_tbl_type,
                              x_clev_tbl       OUT NOCOPY clev_tbl_type,
                              x_klev_tbl       OUT NOCOPY klev_tbl_type,
                              x_fin_clev_rec   OUT NOCOPY clev_rec_type,
                              x_fin_klev_rec   OUT NOCOPY klev_rec_type,
                              x_cimv_tbl       OUT NOCOPY cimv_tbl_type) IS
    l_klev_tbl                        klev_tbl_type;
    l_clev_tbl                        clev_tbl_type;
    l_cimv_tbl                        cimv_tbl_type;
    l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_ADD_ON_LINE';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint Create_add_on_line_pub;
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
    l_klev_tbl := p_klev_tbl;
    l_clev_tbl := p_clev_tbl;
    l_cimv_tbl := p_cimv_tbl;
    g_klev_tbl := l_klev_tbl;
    g_clev_tbl := l_clev_tbl;
    g_cimv_tbl := l_cimv_tbl;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_CREATE_KLE_PVT.create_add_on_line(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          P_New_YN        => P_new_yn,
                                          p_asset_number  => p_asset_number,
                                          p_clev_tbl      => l_clev_tbl,
                                          p_klev_tbl      => l_klev_tbl,
                                          p_cimv_tbl      => l_cimv_tbl,
                                          x_clev_tbl      => x_clev_tbl,
                                          x_klev_tbl      => x_klev_tbl,
                                          x_fin_clev_rec  => x_fin_clev_rec,
                                          x_fin_klev_rec  => x_fin_klev_rec,
                                          x_cimv_tbl      => x_cimv_tbl);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_klev_tbl := x_klev_tbl;
    l_clev_tbl := x_clev_tbl;
    l_cimv_tbl := x_cimv_tbl;
    g_klev_tbl := l_klev_tbl;
    g_clev_tbl := l_clev_tbl;
    g_cimv_tbl := l_cimv_tbl;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR then
      ROLLBACK TO Create_add_on_line_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO Create_add_on_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK  TO Create_add_on_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_CREATE_KLE_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
  END create_add_on_line;
-------------------------------------------------------------------------------------------------------
---------------------------- Main Process for Update of Add on Line ---------------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE update_add_on_line(p_api_version   IN NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
                              p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
                              p_clev_tbl       IN  clev_tbl_type,
                              p_klev_tbl       IN  klev_tbl_type,
                              p_cimv_tbl       IN  cimv_tbl_type,
                              x_clev_tbl       OUT NOCOPY clev_tbl_type,
                              x_klev_tbl       OUT NOCOPY klev_tbl_type,
                              x_cimv_tbl       OUT NOCOPY cimv_tbl_type,
                              x_fin_clev_rec   OUT NOCOPY clev_rec_type,
                              x_fin_klev_rec   OUT NOCOPY klev_rec_type) IS
    i                        NUMBER := 0;
    j                        NUMBER := 0;
    k                        NUMBER := 0;
    l_klev_tbl                        klev_tbl_type;
    l_clev_tbl                        clev_tbl_type;
    l_cimv_tbl                        cimv_tbl_type;
    l_fin_clev_rec                    clev_rec_type;
    l_fin_klev_rec                    klev_rec_type;
    l_api_name               CONSTANT VARCHAR2(30) := 'UPDATE_ADD_ON_LINE';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint Update_add_on_line_pub;
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
    l_klev_tbl := p_klev_tbl;
    l_clev_tbl := p_clev_tbl;
    l_cimv_tbl := p_cimv_tbl;
    g_klev_tbl := l_klev_tbl;
    g_clev_tbl := l_clev_tbl;
    g_cimv_tbl := l_cimv_tbl;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    IF p_clev_tbl.COUNT > 0 THEN
       j := p_clev_tbl.FIRST;
       LOOP
         l_clev_tbl(j).id                     := p_clev_tbl(j).id;
         l_clev_tbl(j).object_version_number  := p_clev_tbl(j).object_version_number;
         EXIT WHEN (j = p_clev_tbl.LAST);
         j := p_clev_tbl.NEXT(j);
       END LOOP;
    ELSE
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF p_klev_tbl.COUNT > 0 THEN
       k := p_klev_tbl.FIRST;
       LOOP
         l_klev_tbl(k).id                     := p_klev_tbl(k).id;
         l_klev_tbl(k).object_version_number  := p_klev_tbl(k).object_version_number;
         EXIT WHEN (k = p_klev_tbl.LAST);
         k := p_klev_tbl.NEXT(k);
       END LOOP;
    ELSE
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF p_cimv_tbl.COUNT > 0 THEN
       i := p_cimv_tbl.FIRST;
       LOOP
         l_cimv_tbl(i).id                     := p_cimv_tbl(i).id;
         l_cimv_tbl(i).object_version_number  := p_cimv_tbl(i).object_version_number;
         EXIT WHEN (i = p_cimv_tbl.LAST);
         i := p_cimv_tbl.NEXT(i);
       END LOOP;
    ELSE
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    OKL_CREATE_KLE_PVT.Update_add_on_line(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          P_New_YN        => P_new_yn,
                                          p_asset_number  => p_asset_number,
                                          p_clev_tbl      => l_clev_tbl,
                                          p_klev_tbl      => l_klev_tbl,
                                          p_cimv_tbl      => l_cimv_tbl,
                                          x_clev_tbl      => x_clev_tbl,
                                          x_klev_tbl      => x_klev_tbl,
                                          x_cimv_tbl      => x_cimv_tbl,
                                          x_fin_clev_rec  => x_fin_clev_rec,
                                          x_fin_klev_rec  => x_fin_klev_rec);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_klev_tbl := x_klev_tbl;
    l_clev_tbl := x_clev_tbl;
    l_cimv_tbl := x_cimv_tbl;
    l_fin_clev_rec := x_fin_clev_rec;
    l_fin_klev_rec := x_fin_klev_rec;
    g_klev_tbl := l_klev_tbl;
    g_clev_tbl := l_clev_tbl;
    g_cimv_tbl := l_cimv_tbl;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR then
      ROLLBACK  TO Update_add_on_line_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR then
      ROLLBACK  TO Update_add_on_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS then
      ROLLBACK TO Update_add_on_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_CREATE_KLE_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END update_add_on_line;
-------------------------------------------------------------------------------------------------------
---------------------------- Main Process for Delete of Add on Line ---------------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE delete_add_on_line(p_api_version   IN NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
                              p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
                              p_clev_tbl       IN  clev_tbl_type,
                              p_klev_tbl       IN  klev_tbl_type,
                              x_fin_clev_rec   OUT NOCOPY clev_rec_type,
                              x_fin_klev_rec   OUT NOCOPY klev_rec_type) IS
    i                        NUMBER := 0;
    j                        NUMBER := 0;
    k                        NUMBER := 0;
    l_klev_tbl                        klev_tbl_type;
    l_clev_tbl                        clev_tbl_type;
    l_fin_clev_rec                    clev_rec_type;
    l_fin_klev_rec                    klev_rec_type;
    l_api_name               CONSTANT VARCHAR2(30) := 'DELETE_ADD_ON_LINE';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint delete_add_on_line_pub;
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
    l_klev_tbl := p_klev_tbl;
    l_clev_tbl := p_clev_tbl;
    g_klev_tbl := l_klev_tbl;
    g_clev_tbl := l_clev_tbl;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    IF p_clev_tbl.COUNT > 0 THEN
       j := p_clev_tbl.FIRST;
       LOOP
         l_clev_tbl(j).id                     := p_clev_tbl(j).id;
         l_clev_tbl(j).object_version_number  := p_clev_tbl(j).object_version_number;
         EXIT WHEN (j = p_clev_tbl.LAST);
         j := p_clev_tbl.NEXT(j);
       END LOOP;
    ELSE
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF p_klev_tbl.COUNT > 0 THEN
       k := p_klev_tbl.FIRST;
       LOOP
         l_klev_tbl(k).id                     := p_klev_tbl(k).id;
         l_klev_tbl(k).object_version_number  := p_klev_tbl(k).object_version_number;
         EXIT WHEN (k = p_klev_tbl.LAST);
         k := p_klev_tbl.NEXT(k);
       END LOOP;
    ELSE
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    OKL_CREATE_KLE_PVT.delete_add_on_line(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          P_New_YN        => P_new_yn,
                                          p_asset_number  => p_asset_number,
                                          p_clev_tbl      => l_clev_tbl,
                                          p_klev_tbl      => l_klev_tbl,
                                          x_fin_clev_rec  => x_fin_clev_rec,
                                          x_fin_klev_rec  => x_fin_klev_rec);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_fin_clev_rec := x_fin_clev_rec;
    l_fin_klev_rec := x_fin_klev_rec;
    g_klev_tbl := l_klev_tbl;
    g_clev_tbl := l_clev_tbl;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR then
      ROLLBACK  TO delete_add_on_line_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR then
      ROLLBACK  TO delete_add_on_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS then
      ROLLBACK TO delete_add_on_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_CREATE_KLE_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END delete_add_on_line;
-----------------------------------------------------------------------------------------------
--------------------------- Main Process for All Line Creation---------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Create_all_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_fin_rec   IN  clev_rec_type,
            p_klev_fin_rec   IN  klev_rec_type,
            p_cimv_model_rec IN  cimv_rec_type,
            p_clev_fa_rec    IN  clev_rec_type,
            p_cimv_fa_rec    IN  cimv_rec_type,
            p_talv_fa_rec    IN  talv_rec_type,
            p_itiv_ib_tbl    IN  itiv_tbl_type,
            x_clev_fin_rec   OUT NOCOPY clev_rec_type,
            x_clev_model_rec OUT NOCOPY clev_rec_type,
            x_clev_fa_rec    OUT NOCOPY clev_rec_type,
            x_clev_ib_rec    OUT NOCOPY clev_rec_type) IS

    l_clev_fin_rec               clev_rec_type;
    l_klev_fin_rec               klev_rec_type;
    l_clev_model_rec             clev_rec_type;
    l_cimv_model_rec             cimv_rec_type;
    l_clev_fa_rec                clev_rec_type;
    l_clev_ib_rec                clev_rec_type;
    l_cimv_fa_rec                cimv_rec_type;
    l_talv_fa_rec                talv_rec_type;
    l_itiv_ib_tbl                itiv_tbl_type;
    l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_ALL_LINE';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint Create_all_line_pub;
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
    l_clev_fin_rec    := p_clev_fin_rec;
    l_klev_fin_rec    := p_klev_fin_rec;
    l_cimv_model_rec  := p_cimv_model_rec;
    l_clev_fa_rec     := p_clev_fa_rec;
    l_cimv_fa_rec     := p_cimv_fa_rec;
    l_talv_fa_rec     := p_talv_fa_rec;
    l_itiv_ib_tbl     := p_itiv_ib_tbl;
    g_clev_fin_rec    := l_clev_fin_rec;
    g_klev_fin_rec    := l_klev_fin_rec;
    g_cimv_model_rec  := l_cimv_model_rec;
    g_clev_fa_rec     := l_clev_fa_rec;
    g_cimv_fa_rec     := l_cimv_fa_rec;
    g_talv_fa_rec     := l_talv_fa_rec;
    g_itiv_ib_tbl     := l_itiv_ib_tbl;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_CREATE_KLE_PVT.Create_all_line(p_api_version    => p_api_version,
                                       p_init_msg_list  => p_init_msg_list,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       P_new_yn         => P_new_yn,
                                       p_asset_number   => p_asset_number,
                                       p_clev_fin_rec   => l_clev_fin_rec,
                                       p_klev_fin_rec   => l_klev_fin_rec,
                                       p_cimv_model_rec => l_cimv_model_rec,
                                       p_clev_fa_rec    => l_clev_fa_rec,
                                       p_cimv_fa_rec    => l_cimv_fa_rec,
                                       p_talv_fa_rec    => l_talv_fa_rec,
                                       p_itiv_ib_tbl    => l_itiv_ib_tbl,
                                       x_clev_fin_rec   => x_clev_fin_rec,
                                       x_clev_model_rec => x_clev_model_rec,
                                       x_clev_fa_rec    => x_clev_fa_rec,
                                       x_clev_ib_rec    => x_clev_ib_rec);
    IF (x_return_status = FND_API.G_RET_STS_ERROR)  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_clev_fin_rec   := x_clev_fin_rec;
    l_clev_model_rec := x_clev_model_rec;
    l_clev_fa_rec    := x_clev_fa_rec;
    l_clev_ib_rec    := x_clev_ib_rec;

    g_clev_fin_rec   := l_clev_fin_rec;
    g_clev_model_rec := l_clev_model_rec;
    g_clev_fa_rec    := l_clev_fa_rec;
    g_clev_ib_rec    := l_clev_ib_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR then
      ROLLBACK TO Create_all_line_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR then
      ROLLBACK TO Create_all_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS then
      ROLLBACK  TO Create_all_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_CREATE_KLE_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
  END Create_all_line;
-----------------------------------------------------------------------------------------------
--------------------------- Main Process for All Line Updating---------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Update_all_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_fin_rec   IN  clev_rec_type,
            p_klev_fin_rec   IN  klev_rec_type,
            p_clev_model_rec IN  clev_rec_type,
            p_cimv_model_rec IN  cimv_rec_type,
            p_clev_fa_rec    IN  clev_rec_type,
            p_cimv_fa_rec    IN  cimv_rec_type,
            p_talv_fa_rec    IN  talv_rec_type,
            p_clev_ib_rec    IN  clev_rec_type,
            p_itiv_ib_rec    IN  itiv_rec_type,
            x_clev_fin_rec   OUT NOCOPY clev_rec_type,
            x_clev_model_rec OUT NOCOPY clev_rec_type,
            x_clev_fa_rec    OUT NOCOPY clev_rec_type,
            x_clev_ib_rec    OUT NOCOPY clev_rec_type) IS

    l_clev_fin_rec               clev_rec_type;
    l_klev_fin_rec               klev_rec_type;
    l_clev_model_rec             clev_rec_type;
    l_cimv_model_rec             cimv_rec_type;
    l_clev_fa_rec                clev_rec_type;
    l_clev_ib_rec                clev_rec_type;
    l_cimv_fa_rec                cimv_rec_type;
    l_talv_fa_rec                talv_rec_type;
    l_itiv_ib_rec                itiv_rec_type;
    l_api_name               CONSTANT VARCHAR2(30) := 'UPDATE_ALL_LINE';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint update_all_line_pub;
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
    l_clev_fin_rec    := p_clev_fin_rec;
    l_klev_fin_rec    := p_klev_fin_rec;
    l_clev_model_rec  := p_clev_model_rec;
    l_cimv_model_rec  := p_cimv_model_rec;
    l_clev_fa_rec     := p_clev_fa_rec;
    l_cimv_fa_rec     := p_cimv_fa_rec;
    l_talv_fa_rec     := p_talv_fa_rec;
    l_clev_ib_rec     := p_clev_ib_rec;
    l_itiv_ib_rec     := p_itiv_ib_rec;

    g_clev_fin_rec    := l_clev_fin_rec;
    g_klev_fin_rec    := l_klev_fin_rec;
    g_clev_model_rec  := l_clev_model_rec;
    g_cimv_model_rec  := l_cimv_model_rec;
    g_clev_fa_rec     := l_clev_fa_rec;
    g_cimv_fa_rec     := l_cimv_fa_rec;
    g_talv_fa_rec     := l_talv_fa_rec;
    g_clev_ib_rec     := l_clev_ib_rec;
    g_itiv_ib_rec     := l_itiv_ib_rec;

    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_CREATE_KLE_PVT.update_all_line(p_api_version    => p_api_version,
                                       p_init_msg_list  => p_init_msg_list,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       P_new_yn         => P_new_yn,
                                       p_asset_number   => p_asset_number,
                                       p_clev_fin_rec   => l_clev_fin_rec,
                                       p_klev_fin_rec   => l_klev_fin_rec,
                                       p_clev_model_rec => l_clev_model_rec,
                                       p_cimv_model_rec => l_cimv_model_rec,
                                       p_clev_fa_rec    => l_clev_fa_rec,
                                       p_cimv_fa_rec    => l_cimv_fa_rec,
                                       p_talv_fa_rec    => l_talv_fa_rec,
                                       p_clev_ib_rec    => l_clev_ib_rec,
                                       p_itiv_ib_rec    => l_itiv_ib_rec,
                                       x_clev_fin_rec   => x_clev_fin_rec,
                                       x_clev_model_rec => x_clev_model_rec,
                                       x_clev_fa_rec    => x_clev_fa_rec,
                                       x_clev_ib_rec    => x_clev_ib_rec);
    IF (x_return_status = FND_API.G_RET_STS_ERROR)  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_clev_fin_rec   := x_clev_fin_rec;
    l_clev_model_rec := x_clev_model_rec;
    l_clev_fa_rec    := x_clev_fa_rec;
    l_clev_ib_rec    := x_clev_ib_rec;

    g_clev_fin_rec   := l_clev_fin_rec;
    g_clev_model_rec := l_clev_model_rec;
    g_clev_fa_rec    := l_clev_fa_rec;
    g_clev_ib_rec    := l_clev_ib_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR then
      ROLLBACK TO update_all_line_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR then
      ROLLBACK TO update_all_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS then
      ROLLBACK  TO update_all_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_update_KLE_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
  END update_all_line;
-----------------------------------------------------------------------------------------------
--------------------- Main Process for Creating Instance and IB Line---------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE create_ints_ib_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_current_units  IN  OKL_TXL_ASSETS_V.CURRENT_UNITS%TYPE,
            p_clev_ib_rec    IN  clev_rec_type,
            p_itiv_ib_tbl    IN  itiv_tbl_type,
            x_clev_ib_tbl    OUT NOCOPY clev_tbl_type,
            x_itiv_ib_tbl    OUT NOCOPY itiv_tbl_type,
            x_clev_fin_rec   OUT NOCOPY clev_rec_type,
            x_klev_fin_rec   OUT NOCOPY klev_rec_type,
            x_cimv_model_rec OUT NOCOPY cimv_rec_type,
            x_cimv_fa_rec    OUT NOCOPY cimv_rec_type,
            x_talv_fa_rec    OUT NOCOPY talv_rec_type) IS

    l_clev_ib_rec                clev_rec_type;
    l_itiv_ib_tbl                itiv_tbl_type;

    l_clev_ib_tbl                clev_tbl_type;
    l_clev_fin_rec               clev_rec_type;
    l_klev_fin_rec               klev_rec_type;
    l_cimv_model_rec             cimv_rec_type;
    l_cimv_fa_rec                cimv_rec_type;
    l_talv_fa_rec                talv_rec_type;

    l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_INST_IB_LINE';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint create_inst_ib_line_pub;
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
    l_clev_ib_rec     := p_clev_ib_rec;
    l_itiv_ib_tbl     := p_itiv_ib_tbl;

    g_clev_ib_rec     := l_clev_ib_rec;
    g_itiv_ib_tbl     := l_itiv_ib_tbl;

    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_CREATE_KLE_PVT.create_ints_ib_line(p_api_version    => p_api_version,
                                           p_init_msg_list  => p_init_msg_list,
                                           x_return_status  => x_return_status,
                                           x_msg_count      => x_msg_count,
                                           x_msg_data       => x_msg_data,
                                           P_new_yn         => P_new_yn,
                                           p_asset_number   => p_asset_number,
                                           p_current_units  => p_current_units,
                                           p_clev_ib_rec    => l_clev_ib_rec,
                                           p_itiv_ib_tbl    => l_itiv_ib_tbl,
                                           x_clev_ib_tbl    => x_clev_ib_tbl,
                                           x_itiv_ib_tbl    => x_itiv_ib_tbl,
                                           x_clev_fin_rec   => x_clev_fin_rec,
                                           x_klev_fin_rec   => x_klev_fin_rec,
                                           x_cimv_model_rec => x_cimv_model_rec,
                                           x_cimv_fa_rec    => x_cimv_fa_rec,
                                           x_talv_fa_rec    => x_talv_fa_rec);
    IF (x_return_status = FND_API.G_RET_STS_ERROR)  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_clev_ib_tbl    := x_clev_ib_tbl;
    l_itiv_ib_tbl    := x_itiv_ib_tbl;
    l_clev_fin_rec   := x_clev_fin_rec;
    l_klev_fin_rec   := x_klev_fin_rec;
    l_cimv_model_rec := x_cimv_model_rec;
    l_cimv_fa_rec    := x_cimv_fa_rec;
    l_talv_fa_rec    := x_talv_fa_rec;

    g_clev_ib_tbl    := l_clev_ib_tbl;
    g_itiv_ib_tbl    := l_itiv_ib_tbl;
    g_clev_fin_rec   := l_clev_fin_rec;
    g_klev_fin_rec   := l_klev_fin_rec;
    g_cimv_model_rec := l_cimv_model_rec;
    g_cimv_fa_rec    := l_cimv_fa_rec;
    g_talv_fa_rec    := l_talv_fa_rec;

    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR then
      ROLLBACK TO create_inst_ib_line_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR then
      ROLLBACK TO create_inst_ib_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS then
      ROLLBACK  TO create_inst_ib_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_update_KLE_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
  END create_ints_ib_line;

-----------------------------------------------------------------------------------------------
--------------------- Main Process for Updating Instance and IB Line---------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE update_ints_ib_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_top_line_id    IN  OKC_K_LINES_V.ID%TYPE,
            p_dnz_chr_id     IN  OKC_K_HEADERS_V.ID%TYPE,
            p_itiv_ib_tbl    IN  itiv_tbl_type,
            x_clev_ib_tbl    OUT NOCOPY clev_tbl_type,
            x_itiv_ib_tbl    OUT NOCOPY itiv_tbl_type) IS

    l_clev_ib_tbl                clev_tbl_type;
    lx_clev_ib_tbl               clev_tbl_type;
    l_itiv_ib_tbl                itiv_tbl_type;

    l_api_name               CONSTANT VARCHAR2(30) := 'UPDATE_INST_IB_LINE';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint update_ints_ib_line_pub;
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
    l_itiv_ib_tbl     := p_itiv_ib_tbl;
    g_itiv_ib_tbl     := l_itiv_ib_tbl;

    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_CREATE_KLE_PVT.update_ints_ib_line(p_api_version    => p_api_version,
                                           p_init_msg_list  => p_init_msg_list,
                                           x_return_status  => x_return_status,
                                           x_msg_count      => x_msg_count,
                                           x_msg_data       => x_msg_data,
                                           P_new_yn         => P_new_yn,
                                           p_asset_number   => p_asset_number,
                                           p_top_line_id    => p_top_line_id,
                                           p_dnz_chr_id     => p_dnz_chr_id,
                                           p_itiv_ib_tbl    => l_itiv_ib_tbl,
                                           x_clev_ib_tbl    => x_clev_ib_tbl,
                                           x_itiv_ib_tbl    => x_itiv_ib_tbl);
    IF (x_return_status = FND_API.G_RET_STS_ERROR)  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_clev_ib_tbl     := x_clev_ib_tbl;
    l_itiv_ib_tbl     := x_itiv_ib_tbl;
    g_clev_ib_tbl     := l_clev_ib_tbl;
    g_itiv_ib_tbl     := l_itiv_ib_tbl;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR then
      ROLLBACK TO update_ints_ib_line_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR then
      ROLLBACK TO update_ints_ib_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS then
      ROLLBACK  TO update_ints_ib_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_update_KLE_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
  END update_ints_ib_line;
-----------------------------------------------------------------------------------------------
--------------------- Main Process for Deleting Instance and IB Line---------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE delete_ints_ib_line(
            p_api_version         IN  NUMBER,
            p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_count           OUT NOCOPY NUMBER,
            x_msg_data            OUT NOCOPY VARCHAR2,
            P_new_yn              IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number        IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_ib_tbl         IN  clev_tbl_type,
            x_clev_fin_rec        OUT NOCOPY clev_rec_type,
            x_klev_fin_rec        OUT NOCOPY klev_rec_type,
            x_cimv_model_rec      OUT NOCOPY cimv_rec_type,
            x_cimv_fa_rec         OUT NOCOPY cimv_rec_type,
            x_talv_fa_rec         OUT NOCOPY talv_rec_type) IS

    l_clev_ib_tbl                clev_tbl_type;

    l_clev_fin_rec               clev_rec_type;
    l_klev_fin_rec               klev_rec_type;
    l_cimv_model_rec             cimv_rec_type;
    l_cimv_fa_rec                cimv_rec_type;
    l_talv_fa_rec                talv_rec_type;

    l_api_name               CONSTANT VARCHAR2(30) := 'DELETE_INST_IB_LINE';
    l_api_version            CONSTANT NUMBER := 1;
  BEGIN
    savepoint delete_inst_ib_line_pub;
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
    l_clev_ib_tbl     := p_clev_ib_tbl;
    g_clev_ib_tbl     := l_clev_ib_tbl;

    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_CREATE_KLE_PVT.delete_ints_ib_line(p_api_version    => p_api_version,
                                           p_init_msg_list  => p_init_msg_list,
                                           x_return_status  => x_return_status,
                                           x_msg_count      => x_msg_count,
                                           x_msg_data       => x_msg_data,
                                           P_new_yn         => P_new_yn,
                                           p_asset_number   => p_asset_number,
                                           p_clev_ib_tbl    => l_clev_ib_tbl,
                                           x_clev_fin_rec   => x_clev_fin_rec,
                                           x_klev_fin_rec   => x_klev_fin_rec,
                                           x_cimv_model_rec => x_cimv_model_rec,
                                           x_cimv_fa_rec    => x_cimv_fa_rec,
                                           x_talv_fa_rec    => x_talv_fa_rec);
    IF (x_return_status = FND_API.G_RET_STS_ERROR)  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_clev_fin_rec   := x_clev_fin_rec;
    l_klev_fin_rec   := x_klev_fin_rec;
    l_cimv_model_rec := x_cimv_model_rec;
    l_cimv_fa_rec    := x_cimv_fa_rec;
    l_talv_fa_rec    := x_talv_fa_rec;

    g_clev_fin_rec   := l_clev_fin_rec;
    g_klev_fin_rec   := l_klev_fin_rec;
    g_cimv_model_rec := l_cimv_model_rec;
    g_cimv_fa_rec    := l_cimv_fa_rec;
    g_talv_fa_rec    := l_talv_fa_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR then
      ROLLBACK TO delete_inst_ib_line_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR then
      ROLLBACK TO delete_inst_ib_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS then
      ROLLBACK  TO delete_inst_ib_line_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_update_KLE_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
  END delete_ints_ib_line;
-----------------------------------------------------------------------------------------------
------------------------ Main Process for Create Party Roles-----------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Create_party_roles_rec(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cplv_rec       IN  cplv_rec_type,
            x_cplv_rec       OUT NOCOPY cplv_rec_type) IS

    l_cplv_rec                      cplv_rec_type;
    l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_PARTY_ROLE';
    l_api_version          CONSTANT NUMBER := 1;
  BEGIN
    savepoint Create_party_roles_pub;
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
    l_cplv_rec := p_cplv_rec;
    g_cplv_rec := l_cplv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_CREATE_KLE_PVT.Create_party_roles_rec(p_api_version   => p_api_version,
                                              p_init_msg_list => p_init_msg_list,
                                              x_return_status => x_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data,
                                              p_cplv_rec      => l_cplv_rec,
                                              x_cplv_rec      => x_cplv_rec);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_cplv_rec := x_cplv_rec;
    g_cplv_rec := l_cplv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO Create_party_roles_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO Create_party_roles_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK  TO Create_party_roles_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_CREATE_KLE_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
  END Create_party_roles_rec;
-----------------------------------------------------------------------------------------------
------------------------ Main Process for Update Party Roles-----------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Update_party_roles_rec(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cplv_rec       IN  cplv_rec_type,
            x_cplv_rec       OUT NOCOPY cplv_rec_type) IS
    l_cplv_rec                      cplv_rec_type;
    l_api_name             CONSTANT VARCHAR2(30) := 'UPDATE_PARTY_ROLE';
    l_api_version          CONSTANT NUMBER := 1;
  BEGIN
    savepoint Update_party_roles_pub;
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
    l_cplv_rec := p_cplv_rec;
    g_cplv_rec := l_cplv_rec;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    l_cplv_rec.id                    := p_cplv_rec.id;
    l_cplv_rec.object_version_number := p_cplv_rec.object_version_number;
    OKL_CREATE_KLE_PVT.Update_party_roles_rec(p_api_version   => p_api_version,
                                              p_init_msg_list => p_init_msg_list,
                                              x_return_status => x_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data,
                                              p_cplv_rec      => l_cplv_rec,
                                              x_cplv_rec      => x_cplv_rec);
    IF (x_return_status = FND_API.G_RET_STS_ERROR)  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_cplv_rec := x_cplv_rec;
    g_cplv_rec := l_cplv_rec;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK  TO Update_party_roles_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK  TO Update_party_roles_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK  TO Update_party_roles_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_CREATE_KLE_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
  END update_party_roles_rec;
-----------------------------------------------------------------------------------------------
--------------------- Main Process for Create Transaction Asset Details------------------------
-----------------------------------------------------------------------------------------------
-- Procedure Name  : Create_asset_line_details
-- Description     : creates Transaction Asset Line details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE Create_asset_line_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txdv_tbl                     IN txdv_tbl_type,
    x_txdv_tbl                     OUT NOCOPY txdv_tbl_type) IS

    l_txdv_tbl                           txdv_tbl_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_TXD_ASSET_DEF';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint Create_asset_line_details_pub;
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
    l_txdv_tbl := p_txdv_tbl;
    g_txdv_tbl := l_txdv_tbl;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    OKL_CREATE_KLE_PVT.Create_asset_line_details(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_txdv_tbl      => l_txdv_tbl,
                                            x_txdv_tbl      => x_txdv_tbl);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_txdv_tbl := x_txdv_tbl;
    g_txdv_tbl := l_txdv_tbl;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO Create_asset_line_details_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO Create_asset_line_details_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO Create_asset_line_details_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'Create_asset_line_details_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END Create_asset_line_details;

-----------------------------------------------------------------------------------------------
--------------------- Main Process for update Transaction Asset Details------------------------
-----------------------------------------------------------------------------------------------
-- Procedure Name  : update_asset_line_details
-- Description     : update Transaction Asset Line details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_asset_line_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_txdv_tbl                     IN txdv_tbl_type,
    x_txdv_tbl                     OUT NOCOPY txdv_tbl_type) IS

    l_txdv_tbl                           txdv_tbl_type;
    l_return_status                      VARCHAR2(3)  := FND_API.G_RET_STS_SUCCESS;
    l_api_name                  CONSTANT VARCHAR2(30) := 'UPDATE_TXD_ASSET_DEF';
    l_api_version	              CONSTANT NUMBER := 1;
  BEGIN
    savepoint update_asset_line_details_pub;
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
    l_txdv_tbl := p_txdv_tbl;
    g_txdv_tbl := l_txdv_tbl;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    OKL_CREATE_KLE_PVT.update_asset_line_details(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_txdv_tbl      => l_txdv_tbl,
                                            x_txdv_tbl      => x_txdv_tbl);
    IF (l_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    l_txdv_tbl := x_txdv_tbl;
    g_txdv_tbl := l_txdv_tbl;
    --	Verticle industry post- processing section
    --  Customer post processing  section
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
	When  FND_API.G_EXC_ERROR  then
		ROLLBACK  TO update_asset_line_details_pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  FND_API.G_EXC_UNEXPECTED_ERROR  then
		ROLLBACK  TO update_asset_line_details_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                             FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                                        p_data  => x_msg_data);
	When  OTHERS  then
		ROLLBACK  TO update_asset_line_details_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'update_asset_line_details_pub');
                             FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                                        p_count   => x_msg_count,
                                                        p_data    => x_msg_data);
  END update_asset_line_details;



End OKL_CREATE_KLE_PUB;

/
