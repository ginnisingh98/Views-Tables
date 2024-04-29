--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_BOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_BOOK_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPBKGS.pls 120.7 2008/02/29 10:49:07 asawanka ship $ */
/*#
 *Contract Booking API allows users to book a lease contract.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Contract Booking API
 * @rep:category BUSINESS_ENTITY  OKL_CONTRACT
 * @rep:lifecycle active
 * @rep:compatibility S
 */


-- Global variables for user hooks
  G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_BOOK_PUB';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  Procedure execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    x_msg_tbl                      OUT NOCOPY OKL_QA_CHECK_PUB.msg_tbl_type);

/*#
 * Generate streams.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Error message data
 * @param p_chr_id Contract identifier
 * @param p_generation_context Context used for stream generation
 * @rep:displayname Generate Streams
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_ORIGINATION
 */
  Procedure generate_streams(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            p_chr_id             IN  VARCHAR2,
            p_generation_context IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2);

  PROCEDURE generate_journal_entries(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_draft_yn         IN  VARCHAR2 DEFAULT Okc_Api.G_TRUE,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2);

/*#
 * Submit for Approval.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Error message data
 * @param p_chr_id Contract identifier
 * @rep:displayname Submit for Approval
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_ORIGINATION
 */
  Procedure submit_for_approval(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2);

  Procedure activate_contract(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2);


 ----------------------------------------------------------------
 --Bug# 3556674 : validate contract api to be called as an api to
 --               run qa check list
 -----------------------------------------------------------------

/*#
 * Validate lease contract.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Error message data
 * @param p_qcl_id Quality assurance checklist identifier
 * @param p_chr_id Contract identifier
 * @param x_msg_tbl Quality assurance check results table
 * @rep:displayname Validate Lease Contract
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_ORIGINATION
 */

 Procedure validate_contract(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    x_msg_tbl                      OUT NOCOPY OKL_QA_CHECK_PUB.msg_tbl_type);

 ----------------------------------------------------------------
 --Bug# 3556674 : generate_draft_accounting to be called  as an api to
 --               generate draft 'Booking' accounting entries
 -----------------------------------------------------------------

 Procedure generate_draft_accounting(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER);
End okl_contract_book_PUB;

/
