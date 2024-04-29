--------------------------------------------------------
--  DDL for Package OKL_CSBRW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CSBRW_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRFBRS.pls 115.1 2002/11/30 08:47:29 spillaip noship $ */
 ---------------------------------------------------------------------------
   -- GLOBAL MESSAGE CONSTANTS
   ---------------------------------------------------------------------------
   G_FND_APP			      CONSTANT VARCHAR2(200) := okl_api.G_FND_APP;
   G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
   G_INVALID_VALUE		      CONSTANT VARCHAR2(200) := okl_api.G_INVALID_VALUE;
   G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
   G_COL_NAME1_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME1';
   G_COL_NAME2_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME2';
   G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
   G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
   G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
   ---------------------------------------------------------------------------
   -- GLOBAL VARIABLES
   ---------------------------------------------------------------------------
   G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_CSBRW_PVT';
   G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
    ---------------------------------------------------------------------------
   -- GLOBAL EXCEPTION
   ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  FUNCTION cust_amount_info(  p_api_version                  IN NUMBER,
     			             p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2,
                              p_cust_account_id              IN  NUMBER,
                              x_amnt_applied   	     OUT NOCOPY NUMBER,
                              x_amnt_outstanding   	     OUT NOCOPY NUMBER
        		    ) RETURN VARCHAR2;

END OKL_CSBRW_PVT;

 

/
