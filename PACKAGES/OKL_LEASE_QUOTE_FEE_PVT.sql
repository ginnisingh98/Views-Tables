--------------------------------------------------------
--  DDL for Package OKL_LEASE_QUOTE_FEE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_QUOTE_FEE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRQUFS.pls 120.4 2005/10/27 03:29:52 rravikir noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LEASE_QUOTE_FEE_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(30)  := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_USER_ID              CONSTANT NUMBER        := FND_GLOBAL.USER_ID;
  G_LOGIN_ID             CONSTANT NUMBER        := FND_GLOBAL.LOGIN_ID;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_DB_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_DB_ERROR';
  G_PKG_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'PKG_NAME';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(30)  := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLERRM';


  ------------------
  -- DATA STRUCTURES
  ------------------
  subtype fee_rec_type is okl_fee_pvt.feev_rec_type;
  subtype assoc_asset_tbl_type is okl_lre_pvt.lrev_tbl_type;
  subtype cashflow_hdr_rec_type is okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
  subtype cashflow_level_tbl_type is okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;

  subtype cf_object_rec_type is okl_cfo_pvt.cfov_rec_type;
  subtype cf_header_rec_type is okl_caf_pvt.cafv_rec_type;
  subtype cf_level_tbl_type is okl_cfl_pvt.cflv_tbl_type;

  subtype lr_tbl_type is okl_lre_pvt.lrev_tbl_type;

  TYPE line_relation_rec_type IS RECORD (
     id                             okl_line_relationships_b.id%TYPE
    ,object_version_number          okl_line_relationships_b.object_version_number%TYPE
    ,source_line_type               okl_line_relationships_b.source_line_type%TYPE
    ,source_line_id                 okl_line_relationships_b.source_line_id%TYPE
    ,related_line_type              okl_line_relationships_b.related_line_type%TYPE
    ,related_line_id                okl_line_relationships_b.related_line_id%TYPE
    ,amount                         okl_line_relationships_b.amount%TYPE
    ,short_description              okl_line_relationships_tl.short_description%TYPE
    ,description                    okl_line_relationships_tl.description%TYPE
    ,comments                       okl_line_relationships_tl.comments%TYPE
    ,record_mode		            varchar2(10));

  TYPE line_relation_tbl_type IS TABLE OF line_relation_rec_type INDEX BY PLS_INTEGER;
  ----------------
  -- PROGRAM UNITS
  ----------------
  PROCEDURE create_fee (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_fee_rec                 IN  fee_rec_type
    ,p_assoc_asset_tbl         IN  line_relation_tbl_type
    ,p_payment_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_payment_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,p_expense_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_expense_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,x_fee_id                  OUT NOCOPY NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );

  PROCEDURE update_fee (
    p_api_version             IN  NUMBER
   ,p_init_msg_list           IN  VARCHAR2
   ,p_transaction_control     IN  VARCHAR2
   ,p_fee_rec                 IN  fee_rec_type
   ,p_sync_fee_header	  	  IN  VARCHAR2 DEFAULT 'Y'
   ,p_sync_line_relations	  IN  VARCHAR2 DEFAULT 'N'
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,x_msg_data                OUT NOCOPY VARCHAR2 );

  PROCEDURE update_fee (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_fee_rec                 IN  fee_rec_type
    ,p_assoc_asset_tbl         IN  line_relation_tbl_type
    ,p_payment_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_payment_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,p_expense_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_expense_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );


  PROCEDURE duplicate_fee (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_source_fee_id           IN  NUMBER
    ,p_fee_rec                 IN  fee_rec_type
    ,p_assoc_asset_tbl         IN  line_relation_tbl_type
    ,p_payment_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_payment_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,p_expense_header_rec      IN  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type
    ,p_expense_level_tbl       IN  okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type
    ,x_fee_id                  OUT NOCOPY NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );

  PROCEDURE duplicate_fee (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_source_fee_id           IN  NUMBER
    ,p_target_quote_id         IN  NUMBER
    ,x_fee_id                  OUT NOCOPY NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );


  PROCEDURE delete_fee (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_fee_id                  IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );

END OKL_LEASE_QUOTE_FEE_PVT;

 

/
