--------------------------------------------------------
--  DDL for Package OKL_SPLIT_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SPLIT_CONTRACT_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPSKHS.pls 115.6 2004/01/24 00:53:38 rravikir noship $ */

  subtype ktl_tbl_type is OKL_SPLIT_CONTRACT_PVT.KTL_TBL_TYPE;

  PROCEDURE cancel_split_process (p_api_version      IN  NUMBER,
                                  p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  x_return_status    OUT NOCOPY VARCHAR2,
                                  x_msg_count        OUT NOCOPY NUMBER,
                                  x_msg_data         OUT NOCOPY VARCHAR2,
                                  p_contract_id      IN  OKC_K_HEADERS_V.ID%TYPE);

  PROCEDURE check_split_process (p_api_version      IN  NUMBER,
                                 p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2,
                                 x_process_action   OUT NOCOPY VARCHAR2,
                                 x_transaction_id   OUT NOCOPY OKL_TRX_CONTRACTS.ID%TYPE,
                                 x_child_chrid1     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE,
                                 x_child_chrid2     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE,
                                 p_contract_id      IN  OKC_K_HEADERS_V.ID%TYPE);

  Procedure create_split_contract(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_old_contract_number  IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE,
            p_new_khr_top_line     IN  ktl_tbl_type,
            x_new_khr_top_line     OUT NOCOPY ktl_tbl_type);

  PROCEDURE set_context(
            p_api_version      IN  NUMBER,
            p_init_msg_list    IN  VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_resp_id          IN  NUMBER,
            p_appl_id          IN  NUMBER,
            p_user_id          IN  NUMBER,
            x_return_status    OUT NOCOPY VARCHAR2);

  PROCEDURE post_split_contract(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_commit               IN  VARCHAR2 DEFAULT OKL_API.G_TRUE,
            p_new1_contract_id     IN  OKC_K_HEADERS_V.ID%TYPE,
            p_new2_contract_id     IN  OKC_K_HEADERS_V.ID%TYPE,
            x_trx1_number          OUT NOCOPY NUMBER,
            x_trx1_status          OUT NOCOPY VARCHAR2,
            x_trx2_number          OUT NOCOPY NUMBER,
            x_trx2_status          OUT NOCOPY VARCHAR2);

End OKL_SPLIT_CONTRACT_PUB;

 

/
