--------------------------------------------------------
--  DDL for Package OKL_GENERATE_PV_RENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_GENERATE_PV_RENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTPVS.pls 120.0 2008/01/10 08:19:08 rajnisku noship $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_GENERATE_PV_RENT_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 G_commit_after_records CONSTANT NUMBER := 500;
 G_commit_count         NUMBER := 0;
 ------------------------------------------------------------------------------
 -- Record Type
 ------------------------------------------------------------------------------

TYPE asset_id_rec_type IS RECORD (
id                    okc_k_lines_b.id%TYPE,
stream_type_purpose   okl_strm_type_b.stream_type_purpose%TYPE,
capital_amount        NUMBER,
residual_value        NUMBER
);

TYPE asset_id_tbl_type IS TABLE OF asset_id_rec_type
        INDEX BY BINARY_INTEGER;


TYPE cash_flow_rec IS RECORD (
                             cf_number  NUMBER,
                             cf_amount  NUMBER,
                             cf_date    DATE,
                             cf_days    NUMBER,
                             cf_arrears VARCHAR2(1),
                             cf_stub    VARCHAR2(1),
                             cf_purpose VARCHAR2(256),
                             cf_dpp     NUMBER,
                             cf_ppy     NUMBER,
			     kleId      NUMBER
                              );

TYPE cash_flow_tbl IS TABLE OF cash_flow_rec INDEX BY BINARY_INTEGER;


---------------------------------------------------------------------------
 -- Procedures AND Functions
 ---------------------------------------------------------------------------

PROCEDURE generate_total_pv_rent
        (p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,p_khr_id               IN  NUMBER
        ,x_total_pv_rent      	OUT NOCOPY      NUMBER
        ,x_return_status	OUT NOCOPY      VARCHAR2
	,x_msg_count		OUT NOCOPY      NUMBER
	,x_msg_data	        OUT NOCOPY      VARCHAR2
        );


PROCEDURE generate_asset_rent
        (p_api_version          IN  NUMBER
        ,p_init_msg_list        IN  VARCHAR2
        ,p_khr_id               IN  NUMBER
        ,p_kle_id               IN  NUMBER
        ,p_contract_start_date  IN DATE
        ,p_day_convention_month IN VARCHAR2
        ,p_day_convention_year  IN VARCHAR2
        ,p_arrears_pay_dates_option IN VARCHAR2
        ,p_total_rent_inflow_tbl IN  OKL_GENERATE_PV_RENT_PVT.cash_flow_tbl
        ,x_total_rent_inflow_tbl OUT NOCOPY     OKL_GENERATE_PV_RENT_PVT.cash_flow_tbl
        ,x_dpp                  OUT NOCOPY      NUMBER
        ,x_ppy                  OUT NOCOPY      NUMBER
        ,x_return_status        OUT NOCOPY      VARCHAR2
        ,x_msg_count            OUT NOCOPY      NUMBER
        ,x_msg_data             OUT NOCOPY      VARCHAR2
        );


PROCEDURE generate_stream_elements( p_start_date       IN      DATE,
                                 p_periods             IN      NUMBER,
                                 p_frequency           IN      VARCHAR2,
                                 p_structure           IN      VARCHAR2,
                                 p_arrears_yn          IN      VARCHAR2,
                                 p_amount              IN      NUMBER,
                                 p_stub_days           IN      NUMBER,
                                 p_stub_amount         IN      NUMBER,
                                 p_khr_id              IN      NUMBER,
                                 p_kle_id              IN      NUMBER,
                                 p_purpose_code        IN      VARCHAR2,
                                 p_recurrence_date     IN      DATE,
                                 p_dpp                 IN      NUMBER,
                                 p_ppy                 IN      NUMBER,
                                 p_months_factor       IN      NUMBER,
                                 p_contract_start_date IN      DATE,
                                 p_day_convention_month IN     VARCHAR2,
                                 p_day_convention_year  IN     VARCHAR2,
                                 p_arrears_pay_dates_option IN VARCHAR2,
                                 p_rent_inflow_tbl     IN     OKL_GENERATE_PV_RENT_PVT.cash_flow_tbl,
                                 x_rent_inflow_tbl     OUT     NOCOPY OKL_GENERATE_PV_RENT_PVT.cash_flow_tbl,
                                 x_return_status       OUT     NOCOPY VARCHAR2,
                                 x_msg_count           OUT     NOCOPY NUMBER,
                                 x_msg_data            OUT     NOCOPY VARCHAR2
);


PROCEDURE compute_iir (p_khr_id             IN      NUMBER,
                       p_cash_in_flows_tbl  IN      OKL_GENERATE_PV_RENT_PVT.cash_flow_tbl,
                       p_cash_out_flows     IN      NUMBER,
                       p_initial_iir        IN      NUMBER,
                       p_precision          IN      NUMBER,
                       x_iir                OUT NOCOPY NUMBER,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2
);



END OKL_GENERATE_PV_RENT_PVT;

/
