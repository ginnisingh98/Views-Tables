--------------------------------------------------------
--  DDL for Package OKL_LEASE_QUOTE_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_QUOTE_PRICING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRQUPS.pls 120.4 2005/11/23 06:30:10 asawanka noship $ */

    SUBTYPE cashflow_hdr_rec_type   IS okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    SUBTYPE cashflow_level_tbl_type IS okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;

    SUBTYPE lease_qte_rec_type IS okl_lsq_pvt.lsqv_rec_type;
    SUBTYPE lease_qte_tbl_type IS okl_lsq_pvt.lsqv_tbl_type;

    SUBTYPE fee_rec_type   is okl_fee_pvt.feev_rec_type;
    SUBTYPE asset_rec_type is okl_ass_pvt.assv_rec_type;

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LEASE_QUOTE_PRICING_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(30)  := OKL_API.G_APP_NAME;
  G_API_TYPE             CONSTANT VARCHAR2(30)  := '_PVT';
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_USER_ID              CONSTANT NUMBER        := FND_GLOBAL.USER_ID;
  G_LOGIN_ID             CONSTANT NUMBER        := FND_GLOBAL.LOGIN_ID;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_UNEXPECTED_ERROR	    CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_DB_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_DB_ERROR';
  G_PKG_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'PKG_NAME';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(30)  := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLERRM';

  ----------------
  -- PROGRAM UNITS
  ----------------
  PROCEDURE validate (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_quote_id                IN  NUMBER
    ,x_qa_result               OUT NOCOPY VARCHAR2
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );

  PROCEDURE price (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_quote_id                IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );

  PROCEDURE calculate_tax(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_quote_id                IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) ;

  PROCEDURE create_update_payment (
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_lease_qte_rec           IN lease_qte_rec_type
    ,p_payment_header_rec      IN cashflow_hdr_rec_type
    ,p_payment_level_tbl       IN cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );

  PROCEDURE create_update_payment (
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_lease_qte_rec           IN lease_qte_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );

  PROCEDURE create_update_line_payment (
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_fee_rec                 IN fee_rec_type
    ,p_asset_rec               IN asset_rec_type
    ,p_payment_header_rec      IN cashflow_hdr_rec_type
    ,p_payment_level_tbl       IN cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );

  PROCEDURE create_update_line_payment (
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_fee_rec                 IN fee_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );

  PROCEDURE create_update_line_payment (
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_asset_rec               IN asset_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );
  PROCEDURE delete_line_payment(
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_source_object_code      IN  VARCHAR2
    ,p_source_object_id        IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) ;
  PROCEDURE handle_parent_object_status(
     p_api_version             IN NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_parent_object_code      IN  VARCHAR2
    ,p_parent_object_id        IN  NUMBER
    );
  FUNCTION get_periods(
     p_casflow_id              IN  NUMBER)
  RETURN VARCHAR2 ;

  FUNCTION get_amount(
     p_casflow_id              IN  NUMBER)
  RETURN VARCHAR2 ;

END OKL_LEASE_QUOTE_PRICING_PVT;

 

/
