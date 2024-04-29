--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_BALANCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_BALANCES_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLRCBLS.pls 120.0 2005/09/29 06:24:42 dkagrawa noship $ */
  SUBTYPE okl_cblv_rec is okl_cbl_pvt.cblv_rec_type;
  SUBTYPE okl_cblv_tbl is okl_cbl_pvt.cblv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME       CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_BALANCES_PVT';
  G_APP_NAME       CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE       CONSTANT VARCHAR2(30)  := '_PVT';

  PROCEDURE create_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_rec         IN         okl_cblv_rec
                       , x_cblv_rec         OUT NOCOPY okl_cblv_rec);

  PROCEDURE create_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_tbl         IN         okl_cblv_tbl
                       , x_cblv_tbl         OUT NOCOPY okl_cblv_tbl);

  PROCEDURE update_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_rec         IN         okl_cblv_rec
                       , x_cblv_rec         OUT NOCOPY okl_cblv_rec);

  PROCEDURE update_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_tbl         IN         okl_cblv_tbl
                       , x_cblv_tbl         OUT NOCOPY okl_cblv_tbl);

  PROCEDURE delete_contract_balances(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_tbl         IN         okl_cblv_tbl);

  PROCEDURE validate_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_rec         IN         okl_cblv_rec);

  PROCEDURE validate_contract_balance(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_cblv_tbl         IN         okl_cblv_tbl);

END OKL_CONTRACT_BALANCES_PVT; -- End of package Body

 

/
