--------------------------------------------------------
--  DDL for Package OKL_STRM_GEN_TEMPLATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STRM_GEN_TEMPLATE_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPTSGS.pls 120.4 2005/11/15 11:52:47 rgooty noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(30)  := 'OKL_STRM_GEN_TEMPLATE_PUB';

  G_MISS_NUM			CONSTANT NUMBER   	:=  OKL_API.G_MISS_NUM;
  G_MISS_CHAR			CONSTANT VARCHAR2(1)	:=  OKL_API.G_MISS_CHAR;
  G_MISS_DATE			CONSTANT DATE   	:=  OKL_API.G_MISS_DATE;
  G_TRUE			CONSTANT VARCHAR2(1)	:=  OKL_API.G_TRUE;
  G_FALSE			CONSTANT VARCHAR2(1)	:=  OKL_API.G_FALSE;

  G_DEFAULT_MODE		CONSTANT VARCHAR2(10) := 'DUPLICATE';

  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6)   := 'OTHERS';

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

  SUBTYPE error_msgs_tbl_type IS okl_strm_gen_template_pvt.error_msgs_tbl_type;

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

End  okl_strm_gen_template_pub;

 

/
