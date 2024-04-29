--------------------------------------------------------
--  DDL for Package OKL_AM_AMORTIZE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_AMORTIZE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTATS.pls 120.6 2006/07/11 10:03:57 dkagrawa noship $ */

   SUBTYPE   thpv_rec_type    IS  okl_trx_assets_pub.thpv_rec_type;
   SUBTYPE   tlpv_rec_type    IS  okl_txl_assets_pub.tlpv_rec_type;

   SUBTYPE   thpv_tbl_type    IS  okl_trx_assets_pub.thpv_tbl_type;
   SUBTYPE   tlpv_tbl_type    IS  okl_txl_assets_pub.tlpv_tbl_type;

  ---------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------- -----
   G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := okc_api.G_REQUIRED_VALUE;
   G_INVALID_VALUE              CONSTANT VARCHAR2(200) := okc_api.G_INVALID_VALUE;
   G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) := okc_api.G_COL_NAME_TOKEN;
   G_PKG_NAME                   CONSTANT VARCHAR2(200) := 'OKL_AM_AMORTIZE_PVT';
   G_APP_NAME                   CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
   G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
   G_NET_INVESTMENT_FORMULA     CONSTANT VARCHAR2(150) := 'LINE_ASSET_NET_INVESTMENT';


   --  create off-lease transaction
   PROCEDURE create_offlease_asset_trx( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_kle_id                IN   NUMBER  DEFAULT OKL_API.G_MISS_NUM,
                             p_early_termination_yn  IN   VARCHAR2,
                             p_quote_eff_date        IN   DATE DEFAULT NULL,  -- rmunjulu EDAT Added parameter
                             p_quote_accpt_date      IN   DATE DEFAULT NULL); -- rmunjulu EDAT Added parameter

                             --  create off-lease transaction
   PROCEDURE create_offlease_asset_trx( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_contract_id           IN   NUMBER  DEFAULT OKL_API.G_MISS_NUM,
                             p_early_termination_yn  IN   VARCHAR2,
                             p_quote_eff_date        IN   DATE DEFAULT NULL,  -- rmunjulu EDAT Added parameter
                             p_quote_accpt_date      IN   DATE DEFAULT NULL); -- rmunjulu EDAT Added parameter


   -- update off-lease transaction
   PROCEDURE update_offlease_asset_trx( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_header_rec            IN   thpv_rec_type,
                             p_lines_rec             IN   tlpv_rec_type);

  -- update off-lease transaction
   PROCEDURE update_offlease_asset_trx( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_header_tbl            IN   thpv_tbl_type,
                             p_lines_tbl             IN   tlpv_tbl_type,
                             x_record_status         OUT  NOCOPY VARCHAR2);

   -- RMUNJULU  3608615
   -- new rec type for depreciation info
   TYPE deprn_rec_type IS RECORD (
          p_tas_id                   OKL_TRX_ASSETS.id%TYPE,
          p_tal_id                   OKL_TXL_ASSETS_V.id%TYPE,
          p_dep_method               OKL_TXL_ASSETS_V.deprn_method%TYPE,
          p_life_in_months           OKL_TXL_ASSETS_V.life_in_months%TYPE,
          --SECHAWLA 28-MAY-04 3645574 : Added deprn_rate
          p_deprn_rate_percent       OKL_TXL_ASSETS_V.deprn_rate%TYPE, -- SECHAWLA 03-JUN-04 3657624 : changed p_deprn_rate to p_deprn_rate_percent
          p_date_trns_occured        OKL_TRX_ASSETS.date_trans_occurred%TYPE,
          p_salvage_value            OKL_TXL_ASSETS_V.salvage_value%TYPE);

   -- RMUNJULU  3608615
   -- update off-lease transaction
   PROCEDURE update_depreciation(
                             p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_deprn_rec             IN   deprn_rec_type);



END OKL_AM_AMORTIZE_PVT;

/
