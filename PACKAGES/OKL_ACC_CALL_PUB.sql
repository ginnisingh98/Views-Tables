--------------------------------------------------------
--  DDL for Package OKL_ACC_CALL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACC_CALL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPACCS.pls 120.2 2007/07/04 09:35:04 vpanwar ship $ */

  SUBTYPE bpd_acc_rec_type  	IS Okl_Acc_Call_Pvt.bpd_acc_rec_type;
  SUBTYPE bpd_acc_tbl_type  	IS Okl_Acc_Call_Pvt.bpd_acc_tbl_type;

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'Okl_Acc_Call_Pub';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

  PROCEDURE create_acc_trans(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
  	,p_bpd_acc_rec  				IN  bpd_acc_rec_type
	);

  PROCEDURE create_acc_trans(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
  	,p_bpd_acc_tbl  				IN  bpd_acc_tbl_type
	);


  PROCEDURE create_acc_trans_new(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
  	,p_bpd_acc_rec 					IN  bpd_acc_rec_type
    ,x_tmpl_identify_rec            OUT NOCOPY Okl_Account_Dist_Pub.TMPL_IDENTIFY_REC_TYPE
    ,x_dist_info_rec                OUT NOCOPY Okl_Account_Dist_Pub.DIST_INFO_REC_TYPE
    ,x_ctxt_val_tbl                 OUT NOCOPY Okl_Account_Dist_Pub.CTXT_VAL_TBL_TYPE
    ,x_acc_gen_primary_key_tbl      OUT NOCOPY Okl_Account_Dist_Pub.ACC_GEN_PRIMARY_KEY
	);

END Okl_Acc_Call_Pub;

/
