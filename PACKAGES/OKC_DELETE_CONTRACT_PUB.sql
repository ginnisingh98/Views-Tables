--------------------------------------------------------
--  DDL for Package OKC_DELETE_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DELETE_CONTRACT_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPDELS.pls 120.0 2005/05/25 19:24:33 appldev noship $ */

G_EXCEPTION_HALT_PROCESSING           EXCEPTION;
G_APP_NAME	    CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
G_UNEXPECTED_ERROR CONSTANT   varchar2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN    CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
G_SQLCODE_TOKEN    CONSTANT   varchar2(200) := 'ERROR_CODE';
G_PKG_NAME         CONSTANT   varchar2(200) := 'OKC_DELETE_CONTRACT_PUB';

--Procedures pertaining to deleting a contract

PROCEDURE delete_contract(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_chrv_rec		IN OKC_CONTRACT_PUB.chrv_rec_type);

PROCEDURE delete_contract(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_chrv_tbl		IN OKC_CONTRACT_PUB.chrv_tbl_type);

END OKC_DELETE_CONTRACT_PUB;

 

/
