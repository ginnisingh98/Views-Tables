--------------------------------------------------------
--  DDL for Package OKL_TRANSFER_ASSUMPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRANSFER_ASSUMPTION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTNAS.pls 120.1 2005/10/30 03:17:31 appldev noship $ */
 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_TRANSFER_ASSUMPTION_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

 G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
 G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
 G_RET_STS_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
 G_EXCEPTION_ERROR		 EXCEPTION;
 G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;

 G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
 G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

 G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
 G_API_TYPE	CONSTANT VARCHAR(4) := '_PVT';

 G_INVALID_VALUE              CONSTANT VARCHAR2(30) := OKL_API.G_INVALID_VALUE;
 G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30) := OKL_API.G_COL_NAME_TOKEN;

 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------

 ----------------------------------------------------------------------------
 -- Global Exception
 ----------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ----------------------------------------------------------------------------
 -- Procedures and Functions
 ------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_full_tna_creditline
-- Description     : Calculate total Transfers and Assumption amount based on
--                   pass in contract ID and update correlated credit lines' tna amount
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_full_tna_creditline(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  okc_k_headers_b.id%type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_partial_tna_creditline
-- Description     : Calculate Transfers and Assumption amount for for the
--                   source and destination contract's asset and update correlated
--                   credit line's tna amount
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_partial_tna_creditline(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  okc_k_headers_b.id%type
 );


END OKL_TRANSFER_ASSUMPTION_PVT;

 

/
