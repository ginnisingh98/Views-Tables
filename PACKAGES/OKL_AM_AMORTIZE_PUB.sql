--------------------------------------------------------
--  DDL for Package OKL_AM_AMORTIZE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_AMORTIZE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTATS.pls 120.6 2008/02/29 10:48:24 asawanka ship $ */


---------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
   G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := okc_api.G_REQUIRED_VALUE;
   G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := okc_api.G_COL_NAME_TOKEN;
   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_AMORTIZE_PUB';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

   SUBTYPE   thpv_rec_type    IS  okl_am_amortize_pvt.thpv_rec_type;
   SUBTYPE   tlpv_rec_type    IS  okl_am_amortize_pvt.tlpv_rec_type;

   SUBTYPE   thpv_tbl_type    IS  okl_am_amortize_pvt.thpv_tbl_type;
   SUBTYPE   tlpv_tbl_type    IS  okl_am_amortize_pvt.tlpv_tbl_type;

   --  The main body of okl_am_amortize_pvt
   PROCEDURE create_offlease_asset_trx( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_kle_id                IN   NUMBER DEFAULT OKL_API.G_MISS_NUM,
                             p_early_termination_yn  IN   VARCHAR2,
                             p_quote_eff_date        IN   DATE DEFAULT NULL,  -- rmunjulu EDAT Added parameter
                             p_quote_accpt_date      IN   DATE DEFAULT NULL); -- rmunjulu EDAT Added parameter

   PROCEDURE create_offlease_asset_trx(
                             p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_contract_id           IN   NUMBER  DEFAULT OKL_API.G_MISS_NUM,
                             p_early_termination_yn  IN   VARCHAR2,
                             p_quote_eff_date        IN   DATE DEFAULT NULL,  -- rmunjulu EDAT Added parameter
                             p_quote_accpt_date      IN   DATE DEFAULT NULL); -- rmunjulu EDAT Added parameter



   PROCEDURE update_offlease_asset_trx( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_header_rec            IN   thpv_rec_type,
                             p_lines_rec             IN   tlpv_rec_type);

   PROCEDURE update_offlease_asset_trx( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_header_tbl            IN   thpv_tbl_type,
                             p_lines_tbl             IN   tlpv_tbl_type,
                             x_record_status         OUT  NOCOPY VARCHAR2);

   -- RMUNJULU  3608615
   SUBTYPE deprn_rec_type IS OKL_AM_AMORTIZE_PVT.deprn_rec_type;

   -- RMUNJULU  3608615


   PROCEDURE update_depreciation(
                             p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_deprn_rec             IN   deprn_rec_type);

END OKL_AM_AMORTIZE_PUB;

/
