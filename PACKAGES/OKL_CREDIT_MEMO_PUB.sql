--------------------------------------------------------
--  DDL for Package OKL_CREDIT_MEMO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREDIT_MEMO_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCRMS.pls 120.10 2008/02/29 10:51:51 asawanka noship $ */
/*#
 * Credit Memo API creates credit memos in the transaction tables.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Credit Memo
 * @rep:category BUSINESS_ENTITY AR_CREDIT_MEMO
 * @rep:lifecycle active
 * @rep:compatibility S
 */


  ------------------------------------------------------------------------------
  -- Global Constants
  ------------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT   VARCHAR2(30)  := 'OKL_CREDIT_MEMO_PUB';
  G_APP_NAME                    CONSTANT   VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR            CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN               CONSTANT   VARCHAR2(200) := 'ERROR_CODE';


  ------------------------------------------------------------------------------
  -- Data Structures
  ------------------------------------------------------------------------------
  SUBTYPE credit_tbl      IS    okl_credit_memo_pvt.credit_tbl;
  SUBTYPE taiv_rec_type   IS    okl_credit_memo_pvt.taiv_rec_type;
  SUBTYPE taiv_tbl_type   IS    okl_credit_memo_pvt.taiv_tbl_type;


  ------------------------------------------------------------------------------
  -- Program Units
  ------------------------------------------------------------------------------
/*#
 *Credit Memo API allows users to create a credit memo based on an existing
 * invoice. The credit memo is created in internal transaction tables.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param p_tld_id Invoice identifier to be reversed
 * @param p_credit_amount Amount to be credited
 * @param p_credit_sty_id Stream type identifier
 * @param p_credit_desc Description.
 * @param p_credit_date Date for the Credit Memo.
 * @param p_try_id Transaction identifier
 * @param p_transaction_source Transaction Source
 * @param p_source_trx_number Source Transaction Number
 * @param x_tai_id Invoice identifier
 * @param x_taiv_rec Table of records of  invoice details
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @rep:displayname Create Credit Memo
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_COLLECTION
 */
  PROCEDURE insert_request(p_api_version     IN          NUMBER,
                           p_init_msg_list   IN          VARCHAR2 DEFAULT OKL_API.G_FALSE,
                           --p_lsm_id          IN          NUMBER,
                           p_tld_id          IN          NUMBER,-- 5897792
                           p_credit_amount   IN          NUMBER,
                           p_credit_sty_id   IN          NUMBER   DEFAULT NULL,
                           p_credit_desc     IN          VARCHAR2 DEFAULT NULL,
			   p_credit_date     IN          DATE DEFAULT SYSDATE,
                           p_try_id          IN          NUMBER   DEFAULT NULL,
                           p_transaction_source IN VARCHAR2 DEFAULT NULL,--5897792
                           p_source_trx_number  IN VARCHAR2 DEFAULT NULL,
                           x_tai_id          OUT NOCOPY  NUMBER,
                           x_taiv_rec        OUT NOCOPY  taiv_rec_type,
                           x_return_status   OUT NOCOPY  VARCHAR2,
                           x_msg_count       OUT NOCOPY  NUMBER,
                           x_msg_data        OUT NOCOPY  VARCHAR2);


  PROCEDURE insert_request(p_api_version     IN          NUMBER,
                           p_init_msg_list   IN          VARCHAR2 DEFAULT OKL_API.G_FALSE,
                           --p_lsm_id          IN          NUMBER,
                           p_tld_id          IN          NUMBER,-- 5897792
                           p_credit_amount   IN          NUMBER,
                           p_credit_sty_id   IN          NUMBER   DEFAULT NULL,
                           p_credit_desc     IN          VARCHAR2 DEFAULT NULL,
                           p_credit_date     IN          DATE     DEFAULT SYSDATE,
                           p_try_id          IN          NUMBER   DEFAULT NULL,
                           p_transaction_source IN VARCHAR2 DEFAULT NULL,--5897792
                           p_source_trx_number  IN VARCHAR2 DEFAULT NULL,
                           x_tai_id          OUT NOCOPY  NUMBER,
                           x_return_status   OUT NOCOPY  VARCHAR2,
                           x_msg_count       OUT NOCOPY  NUMBER,
                           x_msg_data        OUT NOCOPY  VARCHAR2);

--rkuttiya added for bug # 4341480
  PROCEDURE insert_on_acc_cm_request(p_api_version IN    NUMBER,
                           p_init_msg_list   IN          VARCHAR2 DEFAULT OKL_API.G_FALSE,
                           --p_lsm_id          IN          NUMBER,
                           p_tld_id          IN          NUMBER,-- 5897792
                           p_credit_amount   IN          NUMBER,
                           p_credit_sty_id   IN          NUMBER   DEFAULT NULL,
                           p_credit_desc     IN          VARCHAR2 DEFAULT NULL,
                           p_credit_date     IN          DATE DEFAULT SYSDATE,
                           p_try_id          IN          NUMBER   DEFAULT NULL,
                           p_transaction_source IN VARCHAR2 DEFAULT NULL,--5897792
                           p_source_trx_number  IN VARCHAR2 DEFAULT NULL,
                           x_tai_id          OUT NOCOPY  NUMBER,
                           x_taiv_rec        OUT NOCOPY  taiv_rec_type,
                           x_return_status   OUT NOCOPY  VARCHAR2,
                           x_msg_count       OUT NOCOPY  NUMBER,
                           x_msg_data        OUT NOCOPY  VARCHAR2);
--end changes for bug #4341480



/*#
 * Credit Memo API allows users to create a credit memo based on an existing
 * invoice. The credit memo is created in internal transaction tables.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message stack
 * @param p_credit_list Table of records of  credit memo details
 * @param p_transaction_source Transaction Source
 * @param p_source_trx_number Source Transaction Number
 * @param x_taiv_tbl Table of records of  invoice details
 * @param x_return_status Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data Message data error message
 * @rep:displayname Create Credit Memo
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_COLLECTION
 */
  PROCEDURE insert_request(p_api_version             IN          NUMBER,
                           p_init_msg_list           IN          VARCHAR2 DEFAULT OKL_API.G_FALSE,
                           p_credit_list             IN          credit_tbl,
                           p_transaction_source IN VARCHAR2 DEFAULT NULL,--5897792
                           p_source_trx_number  IN VARCHAR2 DEFAULT NULL,
                           x_taiv_tbl                OUT NOCOPY  taiv_tbl_type,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2);


END okl_credit_memo_pub;

/
