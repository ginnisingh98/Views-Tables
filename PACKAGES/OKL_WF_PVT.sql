--------------------------------------------------------
--  DDL for Package OKL_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_WF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCWFS.pls 120.1 2005/10/30 04:02:28 appldev noship $ */

  G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_WF_PVT';
  G_API_TYPE	CONSTANT VARCHAR(4) := '_PVT';

  G_APP_NAME    CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_FND_APP     CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;

  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';

  G_RET_STS_SUCCESS		  CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR		  CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR		        CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
  G_EXCEPTION_ERROR		  EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;

  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

  PROCEDURE raise_event (p_api_version    IN  NUMBER,
                         p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         p_event_name     IN VARCHAR2,
                         p_event_key     IN VARCHAR2 DEFAULT NULL,
                         p_event_data IN clob DEFAULT NULL,
                         p_parameters IN wf_parameter_list_t DEFAULT NULL,
                         p_send_date  IN DATE DEFAULT NULL,
                         p_include_user_params IN VARCHAR2 DEFAULT OKL_API.G_TRUE);

END OKL_WF_PVT;

 

/
