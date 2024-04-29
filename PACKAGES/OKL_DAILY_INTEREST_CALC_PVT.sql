--------------------------------------------------------
--  DDL for Package OKL_DAILY_INTEREST_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DAILY_INTEREST_CALC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRDICS.pls 120.2 2005/09/30 05:26:06 dkagrawa noship $ */
 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_DAILY_INTEREST_CALC_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

 ------------------------------------------------------------------------------
 -- Record Type
 ------------------------------------------------------------------------------
 SUBTYPE receipt_tbl_type IS OKL_VARIABLE_INTEREST_PVT.receipt_tbl_type;
 SUBTYPE principal_balance_tbl_typ IS OKL_VARIABLE_INTEREST_PVT.principal_balance_tbl_typ;

 ---------------------------------------------------------------------------
 -- Procedures and Functions
 ---------------------------------------------------------------------------

 --procedure for calculating daily interest
 --creates accrual streams for actual interest and actual principal
 PROCEDURE daily_interest(p_api_version		IN  NUMBER
  	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKL_API.G_FALSE
  	,x_return_status	OUT NOCOPY VARCHAR2
  	,x_msg_count		OUT NOCOPY NUMBER
  	,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_khr_id IN NUMBER DEFAULT NULL);

 --returns cash applications towards loan payment, variable loan payment and unscheduled loan payment
 PROCEDURE receipt_date_range(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    p_contract_id        IN  NUMBER,
    p_start_date         IN  DATE,
    p_due_date           IN  DATE,
    x_principal_balance  OUT NOCOPY NUMBER,
    x_receipt_tbl        OUT NOCOPY receipt_tbl_type);

 --wrapper procedure for calculating daily interest will be called from Daily Interest Calculation CP
 PROCEDURE calculate_daily_interest(
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY NUMBER,
    p_contract_number IN VARCHAR2
    );

END OKL_DAILY_INTEREST_CALC_PVT;

 

/
