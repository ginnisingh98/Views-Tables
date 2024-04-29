--------------------------------------------------------
--  DDL for Package OKL_ACCOUNTING_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNTING_UPDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAEUS.pls 115.0 2002/04/28 12:59:13 pkm ship       $ */


SUBTYPE  aelv_rec_type  IS OKL_ACCT_EVENT_PUB.aelv_rec_type;

PROCEDURE  UPDATE_ACCT_ENTRIES(p_api_version        IN       NUMBER,
                               p_init_msg_list      IN       VARCHAR2,
                               x_return_status      OUT      NOCOPY VARCHAR2,
                               x_msg_count          OUT      NOCOPY NUMBER,
                               x_msg_data           OUT      NOCOPY VARCHAR2,
                               p_aelv_rec           IN       aelv_rec_type,
                               x_aelv_rec           OUT      NOCOPY aelv_rec_type);


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_ACCOUNTING_UPDATE' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;
g_sysdate DATE := SYSDATE;


G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) :=  OKC_API.G_COL_NAME_TOKEN;
G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';


END OKL_ACCOUNTING_UPDATE_PVT;

 

/
