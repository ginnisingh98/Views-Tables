--------------------------------------------------------
--  DDL for Package CN_SCA_CREDITS_ONLINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCA_CREDITS_ONLINE_PUB" AUTHID CURRENT_USER AS
-- $Header: cnpscaos.pls 120.2 2005/09/07 17:54:51 rchenna noship $
/*#
 * This package is accessed by the users of the Sales Credit Allocation module
 * as an online API interface to the SCA Credit Rules engine. The package implements
 * procedures which accept sales transaction information via global temporary tables
 * and return back sales credit allocation percentages for the resources who
 * participate in the transaction via the Global temporary table cn_sca_lines_output_gtt.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Get Sales Credits Public Application Program Interface(Online)
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

   G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SCA_CREDITS_ONLINE_PUB';


/*#
 * The get_sales_credits procedure in cn_sca_credits_online_pub is used for determining the
 * distribution of sales credit allocation percentages among the different resources and
 * role combinations who took part in the sales transaction. The information about
 * transaction is input to the API via a Global Temporary table cn_sca_headers_interface_gtt.
 * The information about the roles and resources who took part in the transaction is input
 * via the global temporary table cn_sca_lines_interface_gtt. The API determines the
 * revenue/nonrevenue allocation percentages based on the Credit Rules setup and outputs
 * the allocation percentage information.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param x_batch_id Unique number which identifies the different batches of transactions
 * sent to the online API for processing. Should be taken from the sequence CN_SCA_BATCH_S.
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Sales Credits (Online Mode)
 */

PROCEDURE get_sales_credits(
          p_api_version              IN           number,
          p_init_msg_list            IN           varchar2  := fnd_api.g_false,
          x_batch_id                 IN           number,
	  p_org_id		     IN		  number,
          x_return_status            OUT NOCOPY   varchar2,
          x_msg_count                OUT NOCOPY   number,
          x_msg_data                 OUT NOCOPY   varchar2);

END cn_sca_credits_online_pub;
 

/
