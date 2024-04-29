--------------------------------------------------------
--  DDL for Package OKL_REVERSE_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REVERSE_CONTRACT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRVKS.pls 120.1 2005/10/30 03:34:51 appldev noship $ */

G_FALSE		CONSTANT VARCHAR2(1) := OKL_API.G_FALSE;
G_TRUE		CONSTANT VARCHAR2(1) := OKL_API.G_TRUE;

G_PKG_NAME      CONSTANT VARCHAR2(200) := 'OKL_REVERSE_CONTRACT_PUB';
G_APP_NAME      CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

--------------------------------------------------------------------------------
-- ERRORS AND EXCEPTIONS
--------------------------------------------------------------------------------
G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR			CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;

G_EXCEPTION_ERROR		EXCEPTION;
G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;

PROCEDURE Reverse_Contract (p_api_version         IN   NUMBER,
                            p_init_msg_list       IN   VARCHAR2,
                            x_return_status       OUT  NOCOPY VARCHAR2,
                            x_msg_count           OUT  NOCOPY NUMBER,
                            x_msg_data            OUT  NOCOPY VARCHAR2,
                            p_contract_id         IN   NUMBER,
                            p_transaction_date    IN   DATE );


END OKL_REVERSE_CONTRACT_PUB;

 

/
