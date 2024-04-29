--------------------------------------------------------
--  DDL for Package OKL_COPY_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_COPY_ASSET_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPCALS.pls 115.4 2002/11/30 08:32:41 spillaip noship $ */

  subtype klev_tbl_type is OKL_COPY_ASSET_PVT.klev_tbl_type;

  g_from_cle_id            OKC_K_LINES_V.CLE_ID%TYPE;
  g_from_cle_id_tbl        klev_tbl_type;
  g_to_cle_id              OKC_K_LINES_V.CLE_ID%TYPE;
  g_to_chr_id              OKC_K_LINES_V.CHR_ID%TYPE;
  g_to_template_yn	   VARCHAR2(3);
  g_copy_reference	   VARCHAR2(30);
  g_copy_line_party_yn     VARCHAR2(3);
  g_renew_ref_yn           VARCHAR2(3);


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
            x_cle_id             OUT NOCOPY NUMBER);

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
            x_cle_id_tbl         OUT NOCOPY klev_tbl_type);

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
            x_cle_id_tbl         OUT NOCOPY klev_tbl_type);

End okl_copy_asset_pub;

 

/
