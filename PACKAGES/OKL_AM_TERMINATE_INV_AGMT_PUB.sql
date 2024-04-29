--------------------------------------------------------
--  DDL for Package OKL_AM_TERMINATE_INV_AGMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_TERMINATE_INV_AGMT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTIAS.pls 115.2 2003/10/20 22:14:40 rmunjulu noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_CODE';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AM_TERMINATE_INV_AGMT_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_APP_NAME_1          CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR       CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_SUCCESS     CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_TRUE                CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_FALSE               CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;
  G_EXCEPTION_ERROR EXCEPTION;

  SUBTYPE ia_rec_type IS OKL_AM_TERMINATE_INV_AGMT_PVT.ia_rec_type;
  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

  -- This Procedure is used to terminate investor agreement
  PROCEDURE terminate_investor_agreement(
                    p_api_version    IN   NUMBER,
                    p_init_msg_list  IN   VARCHAR2 DEFAULT G_FALSE,
                    x_return_status  OUT  NOCOPY VARCHAR2,
                    x_msg_count      OUT  NOCOPY NUMBER,
                    x_msg_data       OUT  NOCOPY VARCHAR2,
                    p_ia_rec         IN   ia_rec_type,
                    p_control_flag   IN   VARCHAR2 DEFAULT NULL);

  -- This procedure is called by concurrent manager to terminate ended investor agreements.
  PROCEDURE concurrent_expire_inv_agrmt(
                    errbuf           OUT NOCOPY VARCHAR2,
                    retcode          OUT NOCOPY VARCHAR2,
                    p_api_version    IN  VARCHAR2,
                	p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                    p_ia_id          IN  VARCHAR2 DEFAULT NULL,
                    p_date           IN  VARCHAR2 DEFAULT NULL);

END OKL_AM_TERMINATE_INV_AGMT_PUB;

 

/
