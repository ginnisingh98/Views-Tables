--------------------------------------------------------
--  DDL for Package OKL_CS_TRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CS_TRANSACTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPBFNS.pls 120.2 2008/02/22 10:19:33 dkagrawa ship $ */

  ---------------------------------------------------------------------------
  -- DATA TYPES
  ---------------------------------------------------------------------------

  SUBTYPE SVF_INFO_REC          IS OKL_CS_TRANSACTIONS_PVT.SVF_INFO_REC;
  SUBTYPE SVF_INFO_TBL          IS OKL_CS_TRANSACTIONS_PVT.SVF_INFO_TBL;

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_APP_NAME                    CONSTANT VARCHAR2(3)   := 'OKL';
  G_PKG_NAME                    CONSTANT VARCHAR2(30)  := 'OKL_CS_TRANSACTIONS_PUB';
  G_API_NAME                    CONSTANT VARCHAR2(30)  := 'OKL_CS_TRANSACTIONS';
  G_API_VERSION                 CONSTANT NUMBER        := 1;
  G_COMMIT                      CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_INIT_MSG_LIST               CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_VALIDATION_LEVEL            CONSTANT NUMBER        := FND_API.G_VALID_LEVEL_FULL;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE get_totals (p_select          IN           VARCHAR2,
                        p_from            IN           VARCHAR2,
                        p_where           IN           VARCHAR2,
                        x_inv_total       OUT NOCOPY   NUMBER,
                        x_rec_total       OUT NOCOPY   NUMBER,
                        x_due_total       OUT NOCOPY   NUMBER,
			x_credit_total    OUT NOCOPY   NUMBER,
                        x_adjust_total    OUT NOCOPY   NUMBER,
                        x_row_count       OUT NOCOPY   NUMBER,
                        x_return_status   OUT NOCOPY   VARCHAR2,
                        x_msg_count       OUT NOCOPY   NUMBER,
                        x_msg_data        OUT NOCOPY   VARCHAR2);


  PROCEDURE get_svf_info (p_khr_id         IN  NUMBER,
                          p_svf_code       IN  VARCHAR2,
                          x_svf_info_rec   OUT NOCOPY svf_info_rec,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2);

  PROCEDURE get_credit_memo_info(p_khr_id          IN  NUMBER,
                                 p_tai_id          IN  NUMBER,
                                 x_trx_type        OUT NOCOPY VARCHAR2,
                                 x_inv_num         OUT NOCOPY NUMBER,
                                 x_trx_date        OUT NOCOPY DATE,
                                 x_trx_amount      OUT NOCOPY NUMBER,
                                 x_amnt_app        OUT NOCOPY NUMBER,
                                 x_amnt_due        OUT NOCOPY NUMBER,
                                 x_crd_amnt        OUT NOCOPY NUMBER,
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2);


  PROCEDURE check_process_template (p_ptm_code       IN VARCHAR2,
                                    x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count      OUT NOCOPY NUMBER,
                                    x_msg_data       OUT NOCOPY VARCHAR2);


  PROCEDURE get_pvt_label_email (p_khr_id         IN         NUMBER,
                                 x_email          OUT NOCOPY VARCHAR2,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2);


  PROCEDURE create_svf_invoice (p_khr_id            IN NUMBER,
                                p_sty_name          IN VARCHAR2,
                                p_svf_code          IN VARCHAR2,
                                p_svf_amount        IN NUMBER,
                                p_svf_desc          IN VARCHAR2 DEFAULT NULL,
                                p_syndication_code  IN VARCHAR2 DEFAULT NULL,
                                p_factoring_code    IN VARCHAR2 DEFAULT NULL,
                                x_tai_id            OUT NOCOPY NUMBER,
                                x_return_status     OUT NOCOPY VARCHAR2,
                                x_msg_count         OUT NOCOPY NUMBER,
                                x_msg_data          OUT NOCOPY VARCHAR2);


END okl_cs_transactions_pub;

/
