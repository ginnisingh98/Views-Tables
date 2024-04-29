--------------------------------------------------------
--  DDL for Package OKL_LEASE_QUOTE_CASHFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_QUOTE_CASHFLOW_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRQUCS.pls 120.6 2006/02/10 07:52:43 asawanka noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LEASE_QUOTE_CASHFLOW_PVT';
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


  -----------------
  -- RECORD TYPES
  -----------------
  subtype cafv_rec_type is OKL_CAF_PVT.cafv_rec_type;
  subtype cfov_rec_type is OKL_CFO_PVT.cfov_rec_type;
  subtype cflv_tbl_type is OKL_CFL_PVT.cflv_tbl_type;

  ------------------
  -- DATA STRUCTURES
  ------------------
  TYPE contract_details_rec_type IS RECORD (
     currency_code            VARCHAR2(15)
    ,start_date               DATE
    ,term                     NUMBER
    ,pricing_method_code      VARCHAR2(30)    );

  TYPE cashflow_header_rec_type IS RECORD (
     type_code                VARCHAR2(30)    -- mandatory.  Allowable values: 'INFLOW' 'OUTFLOW'
    ,stream_type_id           NUMBER          -- optional for quick quotes only
    ,status_code              VARCHAR2(30)    -- status code for cashflow
    ,arrears_flag             VARCHAR2(1)     -- mandatory
    ,frequency_code           VARCHAR2(1)     -- mandatory
    ,dnz_periods              VARCHAR2(80)    -- used for possible display in lease quote UI (TBD)
    ,dnz_periodic_amount      VARCHAR2(80)    -- used for possible display in lease quote UI (TBD)
    ,parent_object_code       VARCHAR2(30)    -- mandatory (see 'insert_rows' procedure for possible values)
    ,parent_object_id         NUMBER          -- mandatory
    ,quote_type_code          VARCHAR2(30)    -- mandatory  Allowable values: 'LQ' 'QQ' 'LA'
    ,quote_id                 NUMBER          -- mandatory
    ,cashflow_header_id       NUMBER          -- mandatory for update (okl_cash_flows)
    ,cashflow_object_id       NUMBER          -- mandatory for update (okl_cash_flow_objects)
    ,cashflow_header_ovn      NUMBER          -- mandatory for update
    );

  TYPE cashflow_level_rec_type IS RECORD (
     cashflow_level_id        NUMBER          -- mandatory during update
    ,start_date               DATE
    ,rate                     NUMBER
    ,stub_amount              NUMBER
    ,stub_days                NUMBER
    ,periods                  NUMBER
    ,periodic_amount          NUMBER
    ,cashflow_level_ovn       NUMBER          -- mandatory in update call.
    ,record_mode              VARCHAR2(10)    -- mandatory in update call.  Allowable values: 'CREATE' 'UPDATE'
    ,missing_pmt_flag         varchar2(3)
    );

  TYPE cashflow_level_tbl_type IS TABLE OF cashflow_level_rec_type INDEX BY PLS_INTEGER;

  ----------------
  -- PROGRAM UNITS
  ----------------
  PROCEDURE create_cashflow (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_cashflow_header_rec     IN  OUT NOCOPY cashflow_header_rec_type
    ,p_cashflow_level_tbl      IN  OUT NOCOPY cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2    );


  PROCEDURE update_cashflow (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_cashflow_header_rec     IN  OUT NOCOPY cashflow_header_rec_type
    ,p_cashflow_level_tbl      IN  OUT NOCOPY cashflow_level_tbl_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2    );


-- All duplicate and delete procedures is WIP...


  PROCEDURE duplicate_cashflows (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_source_object_code      IN  VARCHAR2
    ,p_source_object_id        IN  NUMBER
    ,p_target_object_id        IN  NUMBER
    ,p_quote_id        IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_target_object_code      IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE delete_cashflows (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_source_object_code      IN  VARCHAR2
    ,p_source_object_id        IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2    );

  PROCEDURE delete_cashflow (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_cashflow_header_id      IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2    );

  PROCEDURE delete_cashflow_level (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_cashflow_level_id       IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2    );

  PROCEDURE process_quote_pricing_reset (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_quote_id                IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2 );

  PROCEDURE copy_pmts_from_est_to_quote (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_estimate_id             IN  NUMBER
    ,p_quote_id                IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    );

END OKL_LEASE_QUOTE_CASHFLOW_PVT;

/
