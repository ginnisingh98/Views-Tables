--------------------------------------------------------
--  DDL for Package OKL_LOSS_PROV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LOSS_PROV_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPLPVS.pls 120.3 2005/10/30 04:25:52 appldev noship $*/

  SUBTYPE glpv_rec_type     IS okl_loss_prov_pvt.glpv_rec_type;
  SUBTYPE slpv_rec_type     IS okl_loss_prov_pvt.slpv_rec_type;
  SUBTYPE slpv_tbl_type     IS okl_loss_prov_pvt.slpv_tbl_type;

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_LOSS_PROV_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 ------------------------------------------------------------------------------

  -- this function is used to calculate capital balance for a contract and deal type
  FUNCTION calculate_capital_balance(p_cntrct_id IN  NUMBER
                                ,p_deal_type IN VARCHAR2) RETURN NUMBER;

  -- this function is used to calculate total reserve amt for a contract
  FUNCTION calculate_cntrct_rsrv_amt (
        p_cntrct_id       IN  NUMBER) RETURN NUMBER;

   -- this function is used to calculate general loss provision and create a transaction
  FUNCTION SUBMIT_GENERAL_LOSS(
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_glpv_rec IN glpv_rec_type) RETURN NUMBER;

   -- this procedure is used create a transaction for specific loss provision
  PROCEDURE SPECIFIC_LOSS_PROVISION (
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_slpv_rec             IN slpv_rec_type);

  PROCEDURE SPECIFIC_LOSS_PROVISION (
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_khr_id               IN  NUMBER
             ,p_reverse_flag         IN  VARCHAR2
             ,p_slpv_tbl             IN  slpv_tbl_type);

End OKL_LOSS_PROV_PUB;

 

/
