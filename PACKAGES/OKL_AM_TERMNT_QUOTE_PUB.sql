--------------------------------------------------------
--  DDL for Package OKL_AM_TERMNT_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_TERMNT_QUOTE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTNQS.pls 120.6 2008/02/29 10:16:47 veramach ship $ */
/*#
 * Terminate Quote API allows users to create, update and approve termination
 * quotes.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Termination Quote API
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 * @rep:businessevent oracle.apps.okl.am.sendquote
 * @rep:lifecycle active
 * @rep:compatibility S
 */



  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_TERMNT_QUOTE_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

  SUBTYPE term_rec_type IS OKL_AM_TERMNT_QUOTE_PVT.term_rec_type;
  SUBTYPE term_tbl_type IS OKL_AM_TERMNT_QUOTE_PVT.term_tbl_type;
  SUBTYPE clev_tbl_type IS OKL_AM_TERMNT_QUOTE_PVT.clev_tbl_type;
  SUBTYPE qte_ln_dtl_tbl IS OKL_AM_TERMNT_QUOTE_PVT.qte_ln_dtl_tbl;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  -- terminates the quote.
  -- checks if accepted_yn is set to 'Y' then calls the terminate contract
  --Bug #3921591: pagarg +++ Rollover +++
  -- additional parameter has been added to the call, to identify the acceptance source
  PROCEDURE terminate_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_term_rec                      IN term_rec_type,
    x_term_rec                      OUT NOCOPY term_rec_type,
    x_err_msg                       OUT NOCOPY VARCHAR2,
    p_acceptance_source             IN  VARCHAR2 DEFAULT null);

  -- terminates the quote for a input of tbl type
  --Bug #3921591: pagarg +++ Rollover +++
  -- additional parameter has been added to the call, to identify the acceptance source
  PROCEDURE terminate_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_term_tbl                      IN term_tbl_type,
    x_term_tbl                      OUT NOCOPY term_tbl_type,
    x_err_msg                       OUT NOCOPY VARCHAR2,
    p_acceptance_source             IN  VARCHAR2 DEFAULT null);

  -- calls send quote workflow
/*#
 * Submit for Approval API submits the termination quote for approval.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_term_rec Record type for termination quote details
 * @param x_term_rec Record type for termination quote details.
 * @rep:displayname Submit Termination Quote for Approval
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 */
  PROCEDURE submit_for_approval(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_term_rec                      IN term_rec_type,
    x_term_rec                      OUT NOCOPY term_rec_type);

  -- Checks If the given asset line is serialized or not
  FUNCTION check_asset_sno(p_asset_line IN OKL_K_LINES.ID%TYPE,
                           x_sno_yn     OUT NOCOPY VARCHAR2,
                           x_clev_tbl   OUT NOCOPY clev_tbl_type) RETURN VARCHAR2;

  --  Create records in Quote Line details after proper validation

/*#
 * Quote Line Details API creates the quote line details for the termination
 * quote.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_qld_tbl Table of Records of termination quote line details
 * @rep:displayname Create Termination Quote Line Details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 */
  PROCEDURE quote_line_dtls(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_qld_tbl          IN OUT NOCOPY qte_ln_dtl_tbl);


  -- RMUNJULU 23-DEC-02 2667636 Added 2 new Subtypes and 4 new procedures for
  -- inserting and updating quote lines table

  SUBTYPE tqlv_rec_type IS OKL_TXL_QUOTE_LINES_PUB.tqlv_rec_type;
  SUBTYPE tqlv_tbl_type IS OKL_TXL_QUOTE_LINES_PUB.tqlv_tbl_type;
  G_FALSE VARCHAR2(1) := OKC_API.G_FALSE;

  -- Creates quote line
/*#
 * Create Quote Line API creates the quote lines for the termination quote.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_tqlv_rec Record type for termination quote line details
 * @param x_tqlv_rec Record type for  termination quote line details
 * @rep:displayname Create Termination Quote Line
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 */
  PROCEDURE create_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type,
               x_tqlv_rec       OUT NOCOPY tqlv_rec_type);


  -- Creates multiple quote lines
/*#
 * Create Quote Line API creates the quote lines for the termination quote.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_tqlv_tbl Table of Records of termination quote line details
 * @param x_tqlv_tbl Table of Records of termination quote line details
 * @rep:displayname Create Termination Quote Line
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 */
  PROCEDURE create_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type,
               x_tqlv_tbl       OUT NOCOPY tqlv_tbl_type);


  -- Updates quote line
/*#
 * Update Quote Line API updates the quote lines for the termination quote.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_tqlv_rec Record type for termination quote line details
 * @param x_tqlv_rec Record type for termination quote line details
 * @rep:displayname Update Termination Quote Line
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 */
  PROCEDURE update_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type,
               x_tqlv_rec       OUT NOCOPY tqlv_rec_type);


  -- Updates multiple quote lines
/*#
 * Update Quote Line API updates the quote lines for the termination quote.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_tqlv_tbl Table of Records of termination quote line details
 * @param x_tqlv_tbl Table of Records of termination quote line details
 * @rep:displayname Update Termination Quote Line
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 */
  PROCEDURE update_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type,
               x_tqlv_tbl       OUT NOCOPY tqlv_tbl_type);


  -- RMUNJULU 16-JAN-03 2754574 Added delete procedures
  -- deletes quote line
  PROCEDURE delete_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type);

  -- deletes multiple quote lines
  PROCEDURE delete_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type);


END OKL_AM_TERMNT_QUOTE_PUB;

/
