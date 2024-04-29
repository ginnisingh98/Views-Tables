--------------------------------------------------------
--  DDL for Package OKL_ACCOUNT_DIST_MISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNT_DIST_MISC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRTDSS.pls 115.2 2002/02/18 20:12:48 pkm ship       $ */


  SUBTYPE tabv_rec_type IS OKL_TRNS_ACC_DSTRS_PUB.tabv_rec_type;
  SUBTYPE tabv_tbl_type IS OKL_TRNS_ACC_DSTRS_PUB.tabv_tbl_type;


PROCEDURE insert_updt_dstrs(p_api_version         IN  NUMBER,
                            p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2,
                            p_tabv_tbl            IN  tabv_tbl_type,
                            x_tabv_tbl            OUT NOCOPY tabv_tbl_type);

G_APP_NAME			    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_ACCOUNT_DIST_MISC_PVT';


END OKL_ACCOUNT_DIST_MISC_PVT;

 

/
