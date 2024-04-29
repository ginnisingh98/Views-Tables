--------------------------------------------------------
--  DDL for Package OKL_VIEW_CONCURRENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VIEW_CONCURRENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRVCPS.pls 115.3 2002/12/18 12:52:16 kjinger noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
-- Record type which holds the account generator rule lines.
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_VIEW_CONCURRENT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
  G_EXCEPTION_ERROR		 EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE Get_Url_Diagnostics_Text
				(p_api_version      IN  NUMBER
                 ,p_init_msg_list   IN  VARCHAR2
                 ,x_return_status   OUT NOCOPY VARCHAR2
                 ,x_msg_count       OUT NOCOPY NUMBER
                 ,x_msg_data        OUT NOCOPY VARCHAR2
	             ,p_request_id      IN  NUMBER
	             ,p_log_url		    OUT NOCOPY VARCHAR2
	             ,p_output_url	    OUT NOCOPY VARCHAR2
	             ,p_diagnostices OUT NOCOPY VARCHAR2);

END OKL_VIEW_CONCURRENT_PVT;


 

/
