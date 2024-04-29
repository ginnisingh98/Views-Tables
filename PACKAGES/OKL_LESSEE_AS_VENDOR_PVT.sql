--------------------------------------------------------
--  DDL for Package OKL_LESSEE_AS_VENDOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LESSEE_AS_VENDOR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLVPS.pls 115.0 2003/10/09 00:48:56 cklee noship $ */
 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
 G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'OKL_LESSEE_AS_VENDOR_PVT';
 G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

 G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
 G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
 G_RET_STS_ERROR		       CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
 G_EXCEPTION_ERROR		 EXCEPTION;
 G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;

 G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
 G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

 G_NOT_UNIQUE                 CONSTANT VARCHAR2(30) := 'OKL_LLA_NOT_UNIQUE';
 G_REQUIRED_VALUE             CONSTANT VARCHAR2(30) := 'OKL_REQUIRED_VALUE';
 G_LLA_RANGE_CHECK            CONSTANT VARCHAR2(30) := 'OKL_LLA_RANGE_CHECK';
 G_INVALID_VALUE              CONSTANT VARCHAR2(30) := OKL_API.G_INVALID_VALUE;
 G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30) := OKL_API.G_COL_NAME_TOKEN;

 G_EXC_NAME_OTHERS	      CONSTANT VARCHAR2(6) := 'OTHERS';
 G_API_TYPE	                  CONSTANT VARCHAR(4) := '_PVT';

 G_UPDATE_MODE                CONSTANT VARCHAR2(30) := 'UPDATE_MODE';
 G_INSERT_MODE                CONSTANT VARCHAR2(30) := 'INSERT_MODE';


 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
  subtype ppydv_rec_type is OKL_PYD_pvt.ppydv_rec_type;
  subtype ppydv_tbl_type is OKL_PYD_pvt.ppydv_tbl_type;

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
-- Procedure Name  : create_lessee_as_vendor
-- Description     : wrapper api for create party payment details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_lessee_as_vendor(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  OKC_K_HEADERS_B.ID%TYPE
   ,p_ppydv_rec                    IN  ppydv_rec_type
   ,x_ppydv_rec                    OUT NOCOPY ppydv_rec_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_lessee_as_vendor
-- Description     : wrapper api for update party payment details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_lessee_as_vendor(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_ppydv_rec                    IN  ppydv_rec_type
   ,x_ppydv_rec                    OUT NOCOPY ppydv_rec_type
 );


END OKL_LESSEE_AS_VENDOR_PVT;

 

/
