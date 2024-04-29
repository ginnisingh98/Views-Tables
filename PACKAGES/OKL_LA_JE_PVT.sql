--------------------------------------------------------
--  DDL for Package OKL_LA_JE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_JE_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRJNLS.pls 120.1 2005/07/13 19:07:51 pdevaraj noship $ */

  G_DRAFT_YN   CONSTANT VARCHAR2(200) := 'OKL_LLA_DRAFT_YN';
-- Global variables for user hooks
  G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_LA_JE_PVT';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

PROCEDURE generate_journal_entries(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_transaction_date IN  DATE,
                      p_draft_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_TRUE,
                      p_memo_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE generate_journal_entries(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_draft_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_TRUE,
                      p_memo_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2);

-- START - Introduced as part of Sales Tax Project to return transaction record
SUBTYPE tcnv_rec_type IS okl_trx_contracts_pvt.tcnv_rec_type;
PROCEDURE generate_journal_entries(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_transaction_date IN  DATE,
                      p_draft_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_TRUE,
                      p_memo_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2,
                      x_trxH_rec         OUT NOCOPY tcnv_rec_type);
-- END - Introduced as part of Sales Tax Project to return transaction record

End OKL_LA_JE_PVT;

 

/
