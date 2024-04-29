--------------------------------------------------------
--  DDL for Package OKL_CS_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CS_TRANSACTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRBFNS.pls 120.2 2008/02/22 10:00:50 dkagrawa ship $ */

  ---------------------------------------------------------------------------
  -- DATA TYPES
  ---------------------------------------------------------------------------

  TYPE SVF_INFO_REC IS RECORD (SVF_ID             NUMBER         := NULL,
                               SVF_NAME           VARCHAR2(80)   := NULL,
                               SVF_AMOUNT         NUMBER(14,3)   := NULL,
                               SVF_DESC           VARCHAR2(1995) := NULL);

  TYPE SVF_INFO_TBL IS TABLE OF SVF_INFO_REC INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT   VARCHAR2(200) := 'OKL_CS_TRANSACTIONS_PVT';
  G_APP_NAME			CONSTANT   VARCHAR2(3)   := 'OKL';
  G_UNEXPECTED_ERROR            CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN               CONSTANT   VARCHAR2(200) := 'ERROR_CODE';

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


END okl_cs_transactions_pvt;

/
