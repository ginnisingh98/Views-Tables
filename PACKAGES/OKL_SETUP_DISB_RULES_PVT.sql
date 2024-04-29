--------------------------------------------------------
--  DDL for Package OKL_SETUP_DISB_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SETUP_DISB_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSDRS.pls 120.2 2007/06/25 13:29:58 gkhuntet noship $ */

  -------------------------------------------------------------------------------
  -- Global Variables
  -------------------------------------------------------------------------------
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'OKL_SETUP_DISB_RULES_PVT';
  G_APP_NAME CONSTANT VARCHAR2(3)  := OKL_API.G_APP_NAME;
  G_VALUE CONSTANT VARCHAR2(5) := 'VALUE';

  -- Messages
  G_OKL_ST_DISB_NAME_EXIST CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_NAME_EXIST';
  G_OKL_ST_DISB_RUL_STY_MISSING CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_RUL_STY_MISSING';
  G_OKL_ST_DISB_FEE_OPTION_REQ CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_FEE_OPTION_REQ';
  G_OKL_ST_DISB_FEE_AMNT_REQ CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_FEE_AMNT_REQ';
  G_OKL_ST_DISB_FEE_PERCENT_REQ CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_FEE_PERCENT_REQ';
  G_OKL_ST_DISB_FEE_PERCENT_ERR CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_FEE_PERCENT_ERR';
  G_OKL_ST_DISB_FREQ_REQ CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_FREQ_REQ';
  G_OKL_ST_DISB_DAY_MON_REQ CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_DAY_MON_REQ';
  G_OKL_ST_DISB_SCHED_MON_REQ CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_SCHED_MON_REQ';
  G_OKL_ST_DISB_SEQ_RANGE_ERR CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_SEQ_RANGE_ERR';
  G_OKL_ST_DISB_SEQ_OVERLAP CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_SEQ_OVERLAP';
  G_OKL_ST_DISB_EFF_DATE_ERR CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_EFF_DATE_ERR';
  G_OKL_ST_DISB_VSITE_DATE_ERR CONSTANT VARCHAR2(30) := 'OKL_ST_DISB_VSITE_DATE_ERR';
G_OKL_ST_START_SEQ_NO_REQ CONSTANT VARCHAR2(30) := 'OKL_ST_START_SEQ_NO_REQ';
  G_OKL_ST_END_SEQ_NO_LESS CONSTANT VARCHAR2(30) := 'OKL_ST_END_SEQ_NO_LESS';
  G_OKL_ST_START_SEQ_LOCK CONSTANT VARCHAR2(30) := 'OKL_ST_START_SEQ_LOCK';

  SUBTYPE drav_rec_type IS okl_dra_pvt.drav_rec_type;
  SUBTYPE drs_tbl_type IS okl_drs_pvt.drs_tbl_type;
  SUBTYPE drs_rec_type IS okl_drs_pvt.drs_rec_type;
  SUBTYPE drv_tbl_type IS okl_drv_pvt.drv_tbl_type;
  SUBTYPE drv_rec_type IS okl_drv_pvt.drv_rec_type;

  PROCEDURE create_disbursement_rule( p_api_version     IN  NUMBER
                                    , p_init_msg_list   IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                    , x_return_status   OUT NOCOPY VARCHAR2
                                    , x_msg_count       OUT NOCOPY NUMBER
                                    , x_msg_data        OUT NOCOPY VARCHAR2
                                    , p_drav_rec        IN  drav_rec_type
                                    , p_drs_tbl         IN  drs_tbl_type
                                    , p_drv_tbl         IN  drv_tbl_type
                                    , x_drav_rec        OUT NOCOPY drav_rec_type
                                    );

  PROCEDURE update_disbursement_rule( p_api_version     IN  NUMBER
                                    , p_init_msg_list   IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                    , x_return_status   OUT NOCOPY VARCHAR2
                                    , x_msg_count       OUT NOCOPY NUMBER
                                    , x_msg_data        OUT NOCOPY VARCHAR2
                                    , p_drav_rec        IN  drav_rec_type
                                    , p_drs_tbl         IN  drs_tbl_type
                                    , p_drv_tbl         IN  drv_tbl_type
                                    , x_drav_rec        OUT NOCOPY drav_rec_type
                                    );

  PROCEDURE validate_disbursement_rule( p_api_version     IN  NUMBER
                                      , p_init_msg_list   IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                      , x_return_status   OUT NOCOPY VARCHAR2
                                      , x_msg_count       OUT NOCOPY NUMBER
                                      , x_msg_data        OUT NOCOPY VARCHAR2
                                      , p_drav_rec        IN  drav_rec_type
                                      , p_drs_tbl         IN  drs_tbl_type
                                      , p_drv_tbl         IN  drv_tbl_type
                                      );

PROCEDURE create_v_disbursement_rule( p_api_version        IN  NUMBER
                                    , p_init_msg_list           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                    , x_return_status           OUT NOCOPY VARCHAR2
                                    , x_msg_count               OUT NOCOPY NUMBER
                                    , x_msg_data                OUT NOCOPY VARCHAR2
                                    , p_drv_tbl                 IN  drv_tbl_type
                                    , x_drv_tbl                 OUT NOCOPY drv_tbl_type
                                    );


END OKL_SETUP_DISB_RULES_PVT;

/
