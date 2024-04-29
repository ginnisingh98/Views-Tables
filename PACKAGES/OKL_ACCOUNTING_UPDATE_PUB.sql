--------------------------------------------------------
--  DDL for Package OKL_ACCOUNTING_UPDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNTING_UPDATE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPAEUS.pls 115.0 2002/04/28 12:58:55 pkm ship       $ */

G_FALSE		CONSTANT VARCHAR2(1) := OKL_API.G_FALSE;
G_TRUE		CONSTANT VARCHAR2(1) := OKL_API.G_TRUE;
G_PKG_NAME  CONSTANT VARCHAR2(200) := 'OKL_ACCOUNTING_UPDATE_PUB';
G_APP_NAME  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

--------------------------------------------------------------------------------
-- ERRORS AND EXCEPTIONS
--------------------------------------------------------------------------------
G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR			CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR	CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;
G_EXCEPTION_ERROR				 EXCEPTION;
G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;

SUBTYPE  aelv_rec_type  IS OKL_ACCT_EVENT_PUB.aelv_rec_type;

PROCEDURE  UPDATE_ACCT_ENTRIES(p_api_version        IN       NUMBER,
                               p_init_msg_list      IN       VARCHAR2,
                               x_return_status      OUT      NOCOPY VARCHAR2,
                               x_msg_count          OUT      NOCOPY NUMBER,
                               x_msg_data           OUT      NOCOPY VARCHAR2,
                               p_aelv_rec           IN       aelv_rec_type,
                               x_aelv_rec           OUT      NOCOPY aelv_rec_type);

END OKL_ACCOUNTING_UPDATE_PUB;

 

/
