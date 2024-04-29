--------------------------------------------------------
--  DDL for Package Body OKL_COPY_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_COPY_ASSET_PUB" as
/* $Header: OKLPCALB.pls 115.7 2004/04/13 10:34:35 rnaik noship $ */
  subtype trxv_rec_type is OKL_TRX_ASSETS_PUB.thpv_rec_type;
  subtype trxv_tbl_type is OKL_TRX_ASSETS_PUB.thpv_tbl_type;
  subtype talv_rec_type is OKL_TXL_ASSETS_PUB.tlpv_rec_type;
  subtype talv_tbl_type is OKL_TXL_ASSETS_PUB.tlpv_tbl_type;
  subtype txdv_tbl_type is OKL_TXD_ASSETS_PUB.adpv_tbl_type;
  subtype itiv_rec_type is OKL_TXL_ITM_INSTS_PUB.iipv_rec_type;
  subtype itiv_tbl_type is OKL_TXL_ITM_INSTS_PUB.iipv_tbl_type;
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
-------------------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
-------------------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PUB';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PUB';
-------------------------------------------------------------------------------------------------
-- GLOBAL VARIABLES
-------------------------------------------------------------------------------------------------
  G_PKG_NAME	                CONSTANT  VARCHAR2(200) := 'OKL_COPY_ASSET_PUB';
  G_APP_NAME		        CONSTANT  VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_FIN_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_FA_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FIXED_ASSET';
  G_ID2                         CONSTANT  VARCHAR2(200) := '#';
  G_TLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'TLS';
  G_SLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'SLS';
-----------------------------------------------------------------------------------------------
--------------------------- Main Process for Copy of Asset Line -------------------------------
-----------------------------------------------------------------------------------------------
  Procedure copy_asset_lines(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            P_from_cle_id        IN  NUMBER,
            p_to_cle_id          IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
            p_to_chr_id          IN  NUMBER,
            p_to_template_yn	 IN  VARCHAR2,
            p_copy_reference	 IN  VARCHAR2,
            p_copy_line_party_yn IN  VARCHAR2,
            p_renew_ref_yn       IN  VARCHAR2,
            p_trans_type         IN  VARCHAR2,
            x_cle_id             OUT NOCOPY NUMBER)
  IS
    l_api_name               CONSTANT VARCHAR2(30) := 'COPY_ASSET_LINES';
    l_api_version            CONSTANT NUMBER := 1;
    l_from_cle_id            OKC_K_LINES_V.CLE_ID%TYPE;
    l_to_cle_id              OKC_K_LINES_V.CLE_ID%TYPE;
    l_to_chr_id              OKC_K_LINES_V.CHR_ID%TYPE;
    l_to_template_yn	     VARCHAR2(3);
    l_copy_reference	     VARCHAR2(30);
    l_copy_line_party_yn     VARCHAR2(3);
    l_renew_ref_yn           VARCHAR2(3);

  BEGIN
    savepoint copy_asset_lines_pub;
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
    l_from_cle_id        := p_from_cle_id;
    l_to_cle_id          := p_to_cle_id;
    l_to_chr_id          := p_to_chr_id;
    l_to_template_yn     := p_to_template_yn;
    l_copy_reference	 := p_copy_reference;
    l_copy_line_party_yn := p_copy_line_party_yn;
    l_renew_ref_yn       := p_renew_ref_yn;

    g_from_cle_id        := p_from_cle_id;
    g_to_cle_id          := p_to_cle_id;
    g_to_chr_id          := p_to_chr_id;
    g_to_template_yn     := p_to_template_yn;
    g_copy_reference	 := p_copy_reference;
    g_copy_line_party_yn := p_copy_line_party_yn;
    g_renew_ref_yn       := p_renew_ref_yn;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_COPY_ASSET_PVT.copy_asset_lines(p_api_version        => p_api_version,
                                        p_init_msg_list      => p_init_msg_list,
                                        x_return_status      => x_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data,
                                        P_from_cle_id        => P_from_cle_id,
                                        p_to_cle_id          => p_to_cle_id,
                                        p_to_chr_id          => p_to_chr_id,
                                        p_to_template_yn     => p_to_template_yn,
                                        p_copy_reference     => p_copy_reference,
                                        p_copy_line_party_yn => p_copy_line_party_yn,
                                        p_renew_ref_yn       => p_renew_ref_yn,
                                        p_trans_type         => p_trans_type,
                                        x_cle_id             => x_cle_id);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO copy_asset_lines_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO copy_asset_lines_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO copy_asset_lines_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_COPY_ASSET_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END copy_asset_lines;

-----------------------------------------------------------------------------------------------
--------------------------- Main Process for Copy of Asset Line -------------------------------
-----------------------------------------------------------------------------------------------
  Procedure copy_asset_lines(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_from_cle_id_tbl    IN  klev_tbl_type,
            p_to_cle_id          IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
            p_to_chr_id          IN  NUMBER,
            p_to_template_yn	 IN  VARCHAR2,
            p_copy_reference	 IN  VARCHAR2,
            p_copy_line_party_yn IN  VARCHAR2,
            p_renew_ref_yn       IN  VARCHAR2,
            p_trans_type         IN  VARCHAR2,
            x_cle_id_tbl         OUT NOCOPY klev_tbl_type)
  IS
    l_api_name               CONSTANT VARCHAR2(30) := 'COPY_ASSET_LINES';
    l_api_version            CONSTANT NUMBER := 1;
    i                              NUMBER := 0;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_from_cle_id_tbl.COUNT > 0 THEN
      i := p_from_cle_id_tbl.FIRST;
      LOOP
        copy_asset_lines(p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         P_from_cle_id        => p_from_cle_id_tbl(i).ID,
                         p_to_cle_id          => p_to_cle_id,
                         p_to_chr_id          => p_to_chr_id,
                         p_to_template_yn     => p_to_template_yn,
                         p_copy_reference     => p_copy_reference,
                         p_copy_line_party_yn => p_copy_line_party_yn,
                         p_renew_ref_yn       => p_renew_ref_yn,
                         p_trans_type         => p_trans_type,
                         x_cle_id             => x_cle_id_tbl(i).ID);
        EXIT WHEN (i = p_from_cle_id_tbl.LAST);
        i := p_from_cle_id_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO copy_asset_lines_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO copy_asset_lines_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO copy_asset_lines_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_COPY_ASSET_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END copy_asset_lines;
-----------------------------------------------------------------------------------------------
--------------------------- Main Process for Copy All Line ------------------------------------
-----------------------------------------------------------------------------------------------
  Procedure copy_all_lines(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_from_cle_id_tbl    IN  klev_tbl_type,
            p_to_cle_id          IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
            p_to_chr_id          IN  NUMBER,
            p_to_template_yn	 IN  VARCHAR2,
            p_copy_reference	 IN  VARCHAR2,
            p_copy_line_party_yn IN  VARCHAR2,
            p_renew_ref_yn       IN  VARCHAR2,
            p_trans_type         IN  VARCHAR2,
            x_cle_id_tbl         OUT NOCOPY klev_tbl_type)
  IS
    l_api_name               CONSTANT VARCHAR2(30) := 'COPY_ALL_LINES';
    l_api_version            CONSTANT NUMBER := 1;
    l_from_cle_id_tbl        klev_tbl_type;
    l_to_cle_id              OKC_K_LINES_V.CLE_ID%TYPE;
    l_to_chr_id              OKC_K_LINES_V.CHR_ID%TYPE;
    l_to_template_yn	     VARCHAR2(3);
    l_copy_reference	     VARCHAR2(30);
    l_copy_line_party_yn     VARCHAR2(3);
    l_renew_ref_yn           VARCHAR2(3);

  BEGIN
    savepoint copy_all_lines_pub;
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
    l_from_cle_id_tbl    := p_from_cle_id_tbl;
    l_to_cle_id          := p_to_cle_id;
    l_to_chr_id          := p_to_chr_id;
    l_to_template_yn     := p_to_template_yn;
    l_copy_reference	 := p_copy_reference;
    l_copy_line_party_yn := p_copy_line_party_yn;
    l_renew_ref_yn       := p_renew_ref_yn;

    g_from_cle_id_tbl    := p_from_cle_id_tbl;
    g_to_cle_id          := p_to_cle_id;
    g_to_chr_id          := p_to_chr_id;
    g_to_template_yn     := p_to_template_yn;
    g_copy_reference	 := p_copy_reference;
    g_copy_line_party_yn := p_copy_line_party_yn;
    g_renew_ref_yn       := p_renew_ref_yn;
    --  Customer pre processing  section
    -- 	Verticle industry pre- processing section
    -- Business API call  section
    OKL_COPY_ASSET_PVT.copy_all_lines(p_api_version        => p_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_from_cle_id_tbl    => l_from_cle_id_tbl,
                                      p_to_cle_id          => l_to_cle_id,
                                      p_to_chr_id          => l_to_chr_id,
                                      p_to_template_yn     => l_to_template_yn,
                                      p_copy_reference     => l_copy_reference,
                                      p_copy_line_party_yn => l_copy_line_party_yn,
                                      p_renew_ref_yn       => l_renew_ref_yn,
                                      p_trans_type         => p_trans_type,
                                      x_cle_id_tbl         => x_cle_id_tbl);
    IF (x_return_status = FND_API.G_RET_STS_ERROR )  THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --	Verticle industry post- processing section
    --  Customer post processing  section
  EXCEPTION
    When FND_API.G_EXC_ERROR  then
      ROLLBACK TO copy_all_lines_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When FND_API.G_EXC_UNEXPECTED_ERROR  then
      ROLLBACK TO copy_all_lines_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    When OTHERS  then
      ROLLBACK TO copy_all_lines_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'OKL_COPY_ASSET_PUB');
      FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END copy_all_lines;
End okl_copy_asset_PUB;

/
