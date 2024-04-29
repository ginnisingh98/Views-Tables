--------------------------------------------------------
--  DDL for Package OKL_CREATE_ADJST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREATE_ADJST_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPOCAS.pls 120.6 2008/02/29 10:52:15 nikshah ship $ */
/*#
 * Create Adjustment API allows users to adjust an invoice balance in
 * Receivables.
 * @rep:scope internal
 * @rep:product OKL
 * @rep:displayname  Lease Adjustments
 * @rep:category BUSINESS_ENTITY OKL_COLLECTION
 * @rep:lifecycle active
 * @rep:compatibility S
 */
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CREATE_ADJST_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

/*#
 * Create adjustment.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message stack
 * @param x_return_status Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data Message data error message
 * @rep:displayname Create Adjustments
 * @rep:scope internal
 * @rep:lifecycle active
 */

 PROCEDURE create_adjustments_pub    ( p_api_version	      IN  NUMBER
 				                      ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                                      ,x_return_status        OUT NOCOPY VARCHAR2
                                      ,x_msg_count	          OUT NOCOPY NUMBER
                                      ,x_msg_data	          OUT NOCOPY VARCHAR2
                                     );

/*#
 * Create adjustment for a specific invoice.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message stack
 * @param p_commit_flag Commit flag
 * @param p_psl_id Payment schedule identifier
 * @param p_chk_approval_limits Check approval limit
 * @param x_new_adj_id Adjustment identifier
 * @param x_return_status Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data Message data error message
 * @rep:displayname Create Adjustments
 * @rep:scope internal
 * @rep:lifecycle active
 */
 PROCEDURE iex_create_adjustments_pub( p_api_version	      IN  NUMBER
  				                      ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                                      ,p_commit_flag          IN  VARCHAR2 DEFAULT OKL_API.G_TRUE
                                      ,p_psl_id               IN  NUMBER
                                      ,p_chk_approval_limits  IN  VARCHAR2 DEFAULT OKL_API.G_TRUE
                                      ,x_new_adj_id           OUT NOCOPY NUMBER
                                      ,x_return_status        OUT NOCOPY VARCHAR2
                                      ,x_msg_count	          OUT NOCOPY NUMBER
                                      ,x_msg_data	          OUT NOCOPY VARCHAR2
                                     );

 PROCEDURE create_adjustments_conc   ( errbuf  		          OUT NOCOPY VARCHAR2
                                      ,retcode 		          OUT NOCOPY NUMBER
	                                 );

END OKL_CREATE_ADJST_PUB; -- Package spec

/
