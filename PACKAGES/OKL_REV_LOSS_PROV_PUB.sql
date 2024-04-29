--------------------------------------------------------
--  DDL for Package OKL_REV_LOSS_PROV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REV_LOSS_PROV_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRPVS.pls 120.3 2005/10/30 03:34:28 appldev noship $ */

  SUBTYPE lprv_rec_type      IS okl_rev_loss_prov_pvt.lprv_rec_type;
  SUBTYPE lprv_tbl_type      IS okl_rev_loss_prov_pvt.lprv_tbl_type;

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_REV_LOSS_PROV_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
 G_INVALID_VALUE        CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;

 G_NO_DATA_FOUND        CONSTANT VARCHAR2(200) := 'OKL_NOT_FOUND';
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
 ------------------------------------------------------------------------------

   -- this procedure reverses loss provision transactions
  PROCEDURE REVERSE_LOSS_PROVISIONS (
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_lprv_rec              IN  lprv_rec_type);

  PROCEDURE REVERSE_LOSS_PROVISIONS(
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_lprv_tbl             IN  lprv_tbl_type);

End OKL_REV_LOSS_PROV_PUB;

 

/
