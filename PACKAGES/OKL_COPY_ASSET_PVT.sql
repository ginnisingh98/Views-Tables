--------------------------------------------------------
--  DDL for Package OKL_COPY_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_COPY_ASSET_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRCALS.pls 120.1 2005/09/29 22:45:50 ramurt noship $ */


  subtype klev_tbl_type is OKL_CONTRACT_PUB.klev_tbl_type;

  Procedure copy_asset_lines(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
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

End okl_copy_asset_pvt;

 

/
