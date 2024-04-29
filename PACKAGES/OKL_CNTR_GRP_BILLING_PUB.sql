--------------------------------------------------------
--  DDL for Package OKL_CNTR_GRP_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CNTR_GRP_BILLING_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCLBS.pls 115.1 2002/07/12 19:05:31 sanahuja noship $ */



 SUBTYPE cntr_bill_rec_type IS OKL_CNTR_GRP_BILLING_PVT.cntr_bill_rec_type;
 SUBTYPE cntr_bill_tbl_type IS OKL_CNTR_GRP_BILLING_PVT.cntr_bill_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CNTR_GRP_BILLING_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

 PROCEDURE calculate_cntgrp_bill_amt(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cntr_bill_tbl                     IN  cntr_bill_tbl_type
    ,x_cntr_bill_tbl                     OUT  NOCOPY cntr_bill_tbl_type);

 PROCEDURE calculate_cntgrp_bill_amt(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cntr_bill_rec                     IN  cntr_bill_rec_type
    ,x_cntr_bill_rec                     OUT  NOCOPY cntr_bill_rec_type);

 PROCEDURE insert_cntr_grp_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cntr_bill_tbl                     IN  cntr_bill_tbl_type
    ,x_cntr_bill_tbl                     OUT  NOCOPY cntr_bill_tbl_type);

 PROCEDURE insert_cntr_grp_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cntr_bill_rec                     IN  cntr_bill_rec_type
    ,x_cntr_bill_rec                     OUT  NOCOPY cntr_bill_rec_type);

end OKL_CNTR_GRP_BILLING_PUB;

 

/
