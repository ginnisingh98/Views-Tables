--------------------------------------------------------
--  DDL for Package OKL_LA_JE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_JE_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPJNLS.pls 115.1 2002/11/30 08:35:37 spillaip noship $ */

-- Global variables for user hooks
  G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_LA_JE_PUB';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;


PROCEDURE generate_journal_entries(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_draft_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_TRUE,
                      p_memo_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_TRUE,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2);


End OKL_LA_JE_PUB;

 

/
