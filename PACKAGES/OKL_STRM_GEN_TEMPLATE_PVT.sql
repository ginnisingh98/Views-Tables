--------------------------------------------------------
--  DDL for Package OKL_STRM_GEN_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STRM_GEN_TEMPLATE_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRTSGS.pls 120.6 2005/11/15 11:50:36 rgooty noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_VERSION_OVERLAPS		CONSTANT VARCHAR2(200) := 'OKL_VERSION_OVERLAPS';
  G_DATES_MISMATCH		CONSTANT VARCHAR2(200) := 'OKL_DATES_MISMATCH';
  G_PAST_RECORDS	  	CONSTANT VARCHAR2(200) := 'OKL_PAST_RECORDS';
  G_START_DATE			CONSTANT VARCHAR2(200) := 'OKL_START_DATE';
  G_END_DATE			CONSTANT VARCHAR2(200) := 'OKL_END_DATE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(100) := OKL_API.G_COL_NAME_TOKEN;

  G_OKL_ST_STRM_ONE_PRI_PURPOSE  CONSTANT VARCHAR2(30) := 'OKL_ST_STRM_ONE_PRI_PURPOSE';
  G_OKL_ST_MANDATORY_PRI_PURPOSE CONSTANT VARCHAR2(30) := 'OKL_ST_MANDATORY_PRI_PURPOSE';
  G_OKL_ST_ALL_INS_PURPOSES 	 CONSTANT VARCHAR2(30) := 'OKL_ST_ALL_INS_PURPOSES';
  G_OKL_ST_MANDATORY_DEP_PURPOSE CONSTANT VARCHAR2(30) := 'OKL_ST_MANDATORY_DEP_PURPOSE';
  G_OKL_ST_UNIQUE_DEP_PURPOSES	 CONSTANT VARCHAR2(30) := 'OKL_ST_UNIQUE_DEP_PURPOSES';
  G_OKL_ST_INVALID_PURPOSES 	 CONSTANT VARCHAR2(30) := 'OKL_ST_INVALID_PURPOSES';
  G_OKL_STRM_BILL_FLAG_YN        CONSTANT VARCHAR2(30) := 'OKL_STRM_BILL_FLAG_YN';
  G_OKL_IC_RR_PRC_ENG_EXT        CONSTANT VARCHAR2(30) := 'OKL_IC_RR_PRC_ENG_EXT';
  G_OKL_IC_RR_METH_FOR_LS        CONSTANT VARCHAR2(30) := 'OKL_IC_RR_METH_FOR_LS';
  G_OKL_DAY_CONVEN_VAL_EXT       CONSTANT VARCHAR2(30) := 'OKL_DAY_CONVEN_VAL_EXT';
  G_OKL_DAY_CONVEN_VAL_INT       CONSTANT VARCHAR2(30) := 'OKL_DAY_CONVEN_VAL_INT';


  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(30)  := 'OKL_STRM_GEN_TEMPLATE_PVT';

  G_MISS_NUM			CONSTANT NUMBER   	:=  OKL_API.G_MISS_NUM;
  G_MISS_CHAR			CONSTANT VARCHAR2(1)	:=  OKL_API.G_MISS_CHAR;
  G_MISS_DATE			CONSTANT DATE   	:=  OKL_API.G_MISS_DATE;
  G_TRUE			CONSTANT VARCHAR2(1)	:=  OKL_API.G_TRUE;
  G_FALSE			CONSTANT VARCHAR2(1)	:=  OKL_API.G_FALSE;

  G_OKL_INV_PRIMARY_PURPOSES   CONSTANT VARCHAR2(30) := 'OKL_INV_PRIMARY_PURPOSES';
  G_OKL_FIN_PRIMARY_PURPOSES   CONSTANT VARCHAR2(30) := 'OKL_FIN_PRIMARY_PURPOSES';
  G_OKL_FIN_DEPENDENT_PURPOSES CONSTANT VARCHAR2(30) := 'OKL_FIN_DEPENDENT_PURPOSES';
  G_OKL_STREAM_TYPE_PURPOSE    CONSTANT VARCHAR2(30) := 'OKL_STREAM_TYPE_PURPOSE';
  G_OKL_STREAM_ALL_BOOK_CLASS  CONSTANT VARCHAR2(30) := 'OKL_STREAM_ALL_BOOK_CLASS';

  G_INVESTOR_PRODUCT   CONSTANT VARCHAR2(30) := 'INVESTOR';
  G_STATUS_COMPLETE    CONSTANT VARCHAR2(30) := 'COMPLETE';
  G_STATUS_INCOMPLETE  CONSTANT VARCHAR2(30) := 'INCOMPLETE';
  G_STATUS_ACTIVE      CONSTANT VARCHAR2(30) := 'ACTIVE';
  G_LEASEDF_DEAL_TYPE  CONSTANT VARCHAR2(30) := 'LEASEDF';
  G_LEASEST_DEAL_TYPE  CONSTANT VARCHAR2(30) := 'LEASEST';
  G_LEASEOP_DEAL_TYPE  CONSTANT VARCHAR2(30) := 'LEASEOP';
  G_LOAN_DEAL_TYPE     CONSTANT VARCHAR2(30) := 'LOAN';
  G_LOAN_REV_DEAL_TYPE CONSTANT VARCHAR2(30) := 'LOAN-REVOLVING';

  G_INIT_VERSION		CONSTANT NUMBER := 1.0;
  G_INIT_TMPT_STATUS		CONSTANT VARCHAR2(100) := 'NEW';
  G_VERSION_MAJOR_INCREMENT	CONSTANT NUMBER := 1.0;
  G_VERSION_FORMAT		CONSTANT VARCHAR2(100) := 'FM999.0999';
  G_INIT_PRIMARY_YN_YES         CONSTANT VARCHAR2(1) := 'Y';
  G_INIT_PRIMARY_YN_NO          CONSTANT VARCHAR2(1) := 'N';
  G_DEFAULT_MODE                CONSTANT VARCHAR2(10) := 'DUPLICATE';


  G_PURPOSE_TOKEN		CONSTANT VARCHAR2(10) := 'PURPOSE';
  G_DEP_PURPOSE_TOKEN		CONSTANT VARCHAR2(10) := 'DEPPURPOSE';
  G_DEAL_TYPE_TOKEN		CONSTANT VARCHAR2(10) := 'DEAL_TYPE';
  G_TYPE_ERROR			CONSTANT VARCHAR2(12) := 'E';
  G_TYPE_WARNING		CONSTANT VARCHAR2(12) := 'W';
  G_CP_SET_OUTCOME		CONSTANT VARCHAR2(30) := 'CP_SET_OUTCOME';

  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;

  G_EXCEPTION_HALT_PROCESSING 	EXCEPTION;
  G_EXCEPTION_ERROR		EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;

  -- Stream Generation Template Set
  SUBTYPE gttv_rec_type IS okl_gtt_pvt.gttv_rec_type;
  SUBTYPE gttv_tbl_type IS okl_gtt_pvt.gttv_tbl_type;

  -- Stream Generation Template
  SUBTYPE gtsv_rec_type IS okl_gts_pvt.gtsv_rec_type;
  SUBTYPE gtsv_tbl_type IS okl_gts_pvt.gtsv_tbl_type;

  -- Stream Generation Template Pricing Parameters
  SUBTYPE gtpv_rec_type IS okl_gtp_pvt.gtpv_rec_type;
  SUBTYPE gtpv_tbl_type IS okl_gtp_pvt.gtpv_tbl_type;

  -- Stream Generation Template Stream Types
  SUBTYPE gtlv_rec_type IS okl_gtl_pvt.gtlv_rec_type;
  SUBTYPE gtlv_tbl_type IS okl_gtl_pvt.gtlv_tbl_type;

  TYPE error_msg_rec  IS RECORD (
      error_message    VARCHAR2(2500) DEFAULT OKL_API.G_MISS_CHAR
     ,error_type_code  VARCHAR2(30)   DEFAULT OKL_API.G_MISS_CHAR
     ,error_type_meaning VARCHAR2(30) DEFAULT OKL_API.G_MISS_CHAR
  );
  TYPE error_msgs_tbl_type IS TABLE OF error_msg_rec
       INDEX BY BINARY_INTEGER;

Procedure create_strm_gen_template(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtsv_rec                IN  gtsv_rec_type
                    ,p_gttv_rec                IN  gttv_rec_type
                    ,p_gtpv_tbl                IN  gtpv_tbl_type
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
                    ,x_gttv_rec                OUT NOCOPY gttv_rec_type  -- Return the Template Info
      );

Procedure update_strm_gen_template(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtsv_rec                IN  gtsv_rec_type
                    ,p_gttv_rec                IN  gttv_rec_type
                    ,p_gtpv_tbl                IN  gtpv_tbl_type
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
                    ,x_gttv_rec                OUT NOCOPY gttv_rec_type  -- Return the Template Info
      );

Procedure update_dep_strms(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtt_id                  IN  OKL_ST_GEN_TEMPLATES.ID%type
                    ,p_pri_sty_id              IN  OKL_ST_GEN_TMPT_LNS.PRIMARY_STY_ID%TYPE
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
                    ,x_missing_deps            OUT NOCOPY VARCHAR2
                    ,x_show_warn_flag          OUT NOCOPY VARCHAR2
      );

Procedure create_version_duplicate(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		    ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		    ,p_mode                    IN  VARCHAR2 DEFAULT G_DEFAULT_MODE
                    ,x_gttv_rec                OUT NOCOPY gttv_rec_type  -- Return the Template Info
      );

Procedure delete_tmpt_prc_params(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtpv_tbl                IN  gtpv_tbl_type
      );

Procedure delete_pri_tmpt_lns(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
      );
Procedure delete_dep_tmpt_lns(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
      );

Procedure validate_template(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		    ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		    ,x_error_msgs_tbl          OUT NOCOPY error_msgs_tbl_type
		    ,x_return_tmpt_status      OUT NOCOPY VARCHAR2
		    ,p_during_upd_flag         IN  VARCHAR2
      );

Procedure activate_template(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		    ,p_gtt_id                  IN  okl_st_gen_templates.id%type
      );

Procedure validate_for_warnings(
                    p_api_version             IN   NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		    ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		    ,x_wrn_msgs_tbl            OUT NOCOPY error_msgs_tbl_type
		    ,p_during_upd_flag         IN  VARCHAR
		    ,x_pri_purpose_list        OUT NOCOPY VARCHAR
      );

 PROCEDURE update_pri_dep_of_sgt(
              p_api_version             IN  NUMBER
             ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
             ,x_return_status           OUT NOCOPY VARCHAR2
             ,x_msg_count               OUT NOCOPY NUMBER
             ,x_msg_data                OUT NOCOPY VARCHAR2
             ,p_gtsv_rec                IN  gtsv_rec_type
             ,p_gttv_rec                IN  gttv_rec_type
             ,p_gtpv_tbl                IN  gtpv_tbl_type
             ,p_pri_gtlv_tbl            IN  gtlv_tbl_type
             ,p_del_dep_gtlv_tbl        IN  gtlv_tbl_type
             ,p_ins_dep_gtlv_tbl        IN  gtlv_tbl_type
             ,x_gttv_rec                OUT NOCOPY gttv_rec_type
             ,x_pri_purpose_list        OUT NOCOPY VARCHAR2);

End  okl_strm_gen_template_pvt;

 

/
