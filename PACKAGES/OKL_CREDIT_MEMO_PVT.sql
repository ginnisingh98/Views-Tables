--------------------------------------------------------
--  DDL for Package OKL_CREDIT_MEMO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREDIT_MEMO_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCRMS.pls 120.4 2007/04/20 19:08:57 apaul noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  --Added credit_date as an addtnl parameter to the table of records.
  TYPE credit_rec IS RECORD (lsm_id          NUMBER,
                             -- 5897792 Start
                             transaction_source       VARCHAR2(50),
                             source_trx_number        VARCHAR2(50),
                             -- 5897792 End
                             credit_amount   NUMBER,
                             credit_sty_id   NUMBER,
                             credit_try_name VARCHAR2(150) DEFAULT 'Credit Memo',
                             credit_desc     VARCHAR2(2000),
			     credit_date     DATE DEFAULT SYSDATE,
			     currency_code   VARCHAR2(30));

  TYPE credit_tbl IS TABLE OF credit_rec INDEX BY BINARY_INTEGER;


  SUBTYPE taiv_rec_type   IS    okl_trx_ar_invoices_pub.taiv_rec_type;
  SUBTYPE taiv_tbl_type   IS    okl_trx_ar_invoices_pub.taiv_tbl_type;


  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT   VARCHAR2(200) := 'OKL_CREDIT_MEMO_PVT';
  G_APP_NAME			CONSTANT   VARCHAR2(3)   := 'OKL';
  G_UNEXPECTED_ERROR            CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN               CONSTANT   VARCHAR2(200) := 'ERROR_CODE';


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE insert_request(p_api_version             IN          NUMBER,
                           p_init_msg_list           IN          VARCHAR2,
                           --p_lsm_id                  IN          NUMBER,
                           p_tld_id                  IN          NUMBER,
                           p_credit_amount           IN          NUMBER,
                           p_credit_sty_id           IN          NUMBER,
                           p_credit_desc             IN          VARCHAR2,
                           p_credit_date             IN          DATE,
                           p_try_id                  IN          NUMBER,
-- Bug 5897792 Start
                  p_transaction_source      IN          VARCHAR2 DEFAULT NULL,
                  p_source_trx_number       IN          VARCHAR2 DEFAULT NULL,
--  Bug 5897792 End
                           x_tai_id                  OUT NOCOPY  NUMBER,
                           x_taiv_rec                OUT NOCOPY  taiv_rec_type,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2);


  PROCEDURE insert_request(p_api_version             IN          NUMBER,
                           p_init_msg_list           IN          VARCHAR2,
                           p_credit_list             IN          credit_tbl,
-- Bug 5897792 Start
                  p_transaction_source      IN          VARCHAR2 DEFAULT NULL,
                  p_source_trx_number       IN          VARCHAR2 DEFAULT NULL,
--  Bug 5897792 End
                           x_taiv_tbl                OUT NOCOPY  taiv_tbl_type,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2);

  --rkuttiya added for bug #4341480
   PROCEDURE insert_on_acc_cm_request(p_api_version   IN          NUMBER,
                           p_init_msg_list           IN          VARCHAR2,
-- Bug 5897792 Start
                           --p_lsm_id                  IN          NUMBER,
                           p_tld_id                  IN          NUMBER,
--  Bug 5897792 End
                           p_credit_amount           IN          NUMBER,
                           p_credit_sty_id           IN          NUMBER,
                           p_credit_desc             IN          VARCHAR2,
                           p_credit_date             IN          DATE,
                           p_try_id                  IN          NUMBER,
-- Bug 5897792 Start
                  p_transaction_source      IN          VARCHAR2 DEFAULT NULL,
                  p_source_trx_number       IN          VARCHAR2 DEFAULT NULL,
--  Bug 5897792 End
                           x_tai_id                  OUT NOCOPY  NUMBER,
                           x_taiv_rec                OUT NOCOPY  taiv_rec_type,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2);
-- end fix for bug #4341480

END okl_credit_memo_pvt;

/
