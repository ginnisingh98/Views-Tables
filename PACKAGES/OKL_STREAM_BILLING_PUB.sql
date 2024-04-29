--------------------------------------------------------
--  DDL for Package OKL_STREAM_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAM_BILLING_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPBSTS.pls 120.6 2008/02/29 10:12:50 veramach ship $ */
/*#
 * Stream Billing API extracts eligible stream elements and
 * creates billing transactions in Lease Management.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Stream Billing API
 * @rep:category BUSINESS_ENTITY  OKL_ORIGINATION
 * @rep:lifecycle active
 * @rep:compatibility S
 */

  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'OKL_STREAM_BILLING_PUB';

  PROCEDURE bill_streams_conc  (
                errbuf  OUT NOCOPY VARCHAR2 ,
                retcode OUT NOCOPY NUMBER,
		p_ia_contract_type     IN  VARCHAR2	DEFAULT NULL,  --modified by zrehman for Bug#6788005 on 01-Feb-2008
                p_from_bill_date  IN VARCHAR2,
                p_to_bill_date  IN VARCHAR2,
                p_contract_number  IN VARCHAR2,
                p_cust_acct_id     IN NUMBER,
                p_inv_cust_acct_id      IN NUMBER    DEFAULT NULL,  --modified by zrehman for Bug#6788005 on 01-Feb-2008
		p_assigned_process IN VARCHAR2
                );

/*#
 * Create billing streams.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status Return status from the API
 * @param x_msg_count Message count if error messages are encountered
 * @param x_msg_data Error message data
 * @param p_contract_number  Contract number to be billed
 * @param p_from_bill_date Billing start date
 * @param p_to_bill_date Billing end date
 * @rep:displayname Create Billing Streams
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_ORIGINATION
 */
  PROCEDURE bill_streams
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,p_ia_contract_type     IN  VARCHAR2	DEFAULT NULL  --modified by zrehman for Bug#6788005 on 01-Feb-2008
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_from_bill_date	IN  DATE	DEFAULT NULL
	,p_to_bill_date		IN  DATE	DEFAULT NULL
    ,p_cust_acct_id     IN  NUMBER      DEFAULT NULL
    ,p_inv_cust_acct_id      IN NUMBER    DEFAULT NULL  --modified by zrehman for Bug#6788005 on 01-Feb-2008
    ,p_assigned_process IN  VARCHAR2    DEFAULT NULL);

END okl_stream_billing_pub;

/
