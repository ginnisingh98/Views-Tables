--------------------------------------------------------
--  DDL for Package OKL_INTEREST_IMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTEREST_IMP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRITFS.pls 115.1 2002/02/06 20:32:06 pkm ship       $ */



SUBTYPE ivev_rec_type         IS OKL_INDICES_PUB.ivev_rec_type;
SUBTYPE ivev_tbl_type         IS OKL_INDICES_PUB.ivev_tbl_type;

SUBTYPE idxv_rec_type         IS OKL_INDICES_PUB.idxv_rec_type;
SUBTYPE idxv_tbl_type         IS OKL_INDICES_PUB.idxv_tbl_type;

SUBTYPE idiv_rec_type         IS OKL_INDEX_INTERFACES_PUB.idiv_rec_type;
SUBTYPE idiv_tbl_type         IS OKL_INDEX_INTERFACES_PUB.idiv_tbl_type;



PROCEDURE INT_RATE_IMPORT(p_api_version                 IN   NUMBER,
                         p_init_msg_list               IN   VARCHAR2,
                         x_return_status               OUT  NOCOPY VARCHAR2,
                         x_msg_count                   OUT  NOCOPY NUMBER,
                         x_msg_data                    OUT  NOCOPY VARCHAR2);





G_PKG_NAME CONSTANT VARCHAR2(200)      := 'OKL_INTEREST_IMP_PVT' ;
G_APP_NAME CONSTANT VARCHAR2(3)        :=  OKL_API.G_APP_NAME;

G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
G_UPPERCASE_REQUIRED             CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

END;

 

/
