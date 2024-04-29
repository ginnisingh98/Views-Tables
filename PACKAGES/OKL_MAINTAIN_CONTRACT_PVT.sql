--------------------------------------------------------
--  DDL for Package OKL_MAINTAIN_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_MAINTAIN_CONTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRKHRS.pls 120.1 2005/11/11 23:24:54 rseela noship $ */
G_PKG_NAME                 CONSTANT VARCHAR2(30) := 'OKL_MAINTAIN_CONTRACT_PVT';
G_APP_NAME   		   CONSTANT VARCHAR2(200) := OKL_API.G_APP_NAME;
G_LLA_CHR_ID               CONSTANT VARCHAR2(30) := 'OKL_LLA_CHR_ID';
G_UNEXPECTED_ERROR         CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
G_SQLCODE_TOKEN            CONSTANT VARCHAR2(200) := 'SQLCODE';
G_SQLERRM_TOKEN            CONSTANT VARCHAR2(200) := 'SQLERRM';
--------------------------------------------------------------------------------
--start of comments
-- Description   : This api takes the contract id as input and returns the status of operation
-- IN Parameters : p_contract_id - ID of the Lease contract
--End of comments
--------------------------------------------------------------------------------
Procedure confirm_cancel_contract
                  (p_api_version          IN  NUMBER,
                   p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                   x_return_status        OUT NOCOPY VARCHAR2,
                   x_msg_count            OUT NOCOPY NUMBER,
                   x_msg_data             OUT NOCOPY VARCHAR2,
                   p_contract_id          IN  NUMBER,
				   p_new_contract_number  IN  VARCHAR2);
end okl_maintain_contract_pvt;

 

/
