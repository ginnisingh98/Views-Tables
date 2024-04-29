--------------------------------------------------------
--  DDL for Package OKL_INTEREST_IMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTEREST_IMP_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPITFS.pls 115.1 2002/02/06 20:28:44 pkm ship       $ */



SUBTYPE ivev_rec_type         IS OKL_INTEREST_IMP_PVT.ivev_rec_type;
SUBTYPE ivev_tbl_type         IS OKL_INTEREST_IMP_PVT.ivev_tbl_type;

SUBTYPE idxv_rec_type         IS OKL_INTEREST_IMP_PVT.idxv_rec_type;
SUBTYPE idxv_tbl_type         IS OKL_INTEREST_IMP_PVT.idxv_tbl_type;

SUBTYPE idiv_rec_type         IS OKL_INTEREST_IMP_PVT.idiv_rec_type;
SUBTYPE idiv_tbl_type         IS OKL_INTEREST_IMP_PVT.idiv_tbl_type;


PROCEDURE INT_RATE_IMPORT(p_api_version                 IN   NUMBER,
                          p_init_msg_list               IN   VARCHAR2,
                          x_return_status               OUT  NOCOPY VARCHAR2,
                          x_msg_count                   OUT  NOCOPY NUMBER,
                          x_msg_data                    OUT  NOCOPY VARCHAR2);


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_INTEREST_IMP_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


END OKL_INTEREST_IMP_PUB;

 

/
