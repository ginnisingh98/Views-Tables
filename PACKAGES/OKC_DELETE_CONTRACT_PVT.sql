--------------------------------------------------------
--  DDL for Package OKC_DELETE_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DELETE_CONTRACT_PVT" AUTHID CURRENT_USER as
/* $Header: OKCRDELS.pls 120.0 2005/05/25 19:03:50 appldev noship $ */

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_DELETE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_CANNOT_DELETE		CONSTANT VARCHAR2(200)   :=  'OKC_CANNOT_DELETE';
  G_SQLERRM_TOKEN        CONSTANT   varchar2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT   varchar2(200) := 'SQLcode';
  G_TABLE_NAME_TOKEN     CONSTANT   varchar2(200) := 'TABLE_NAME';
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;
  ---------------------------------------------------------------------------

--Procedures pertaining to deleting a contract

PROCEDURE delete_contract(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_chrv_rec		IN OKC_CONTRACT_PUB.chrv_rec_type);

END OKC_DELETE_CONTRACT_PVT;

 

/
