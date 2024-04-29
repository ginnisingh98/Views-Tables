--------------------------------------------------------
--  DDL for Package AR_REVENUEADJUST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_REVENUEADJUST_PUB" AUTHID CURRENT_USER AS
/*$Header: ARXPRADS.pls 120.6 2006/06/29 17:34:03 mraymond ship $*/
/*#
 * Revenue Adjustment APIs allow users to recognize event-based revenue
 * such as unearning revenue, earning revenue, transferring sales
 * credits between salesreps, and adding non-revenue sales credits.
 * Users can defer revenue recognition and earn the revenue at a later
 * date using the API. Throughout the process, the API uses
 * AutoAccounting to determine the accounts to be debited/credited with * each operation.
 * @rep:scope public
 * @rep:metalink 236938.1 See OracleMetaLink note 236938.1
 * @rep:product AR
 * @rep:lifecycle active
 * @rep:displayname Revenue Adjustment API
 * @rep:category BUSINESS_ENTITY AR_REVENUE
 */

-----------------------------------------------------------------------
--	API name 	: Unearn_Revenue
--	Type		: Public
--	Function	: Transfers a specified amount of revenue from
--                        earned to unearned revenue account
--	Pre-reqs	: Sufficient earned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--				.
--				.
--	Version	: Current version	2.0
--				Initial version created 31-MAY-2000
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for both debits and credits
--

-----------------------------------------------------------------------
 /*#
 * Use this procedure to transfer a specified amount of revenue from
 * earned to unearned revenue account.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Transfer Earned Revenue to Unearned Revenue
 */


  PROCEDURE Unearn_Revenue
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,p_org_id                IN  NUMBER DEFAULT NULL
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2);

-----------------------------------------------------------------------
--	API name 	: Earn_Revenue
--	Type		: Public
--	Function	: Transfers a specified amount of revenue from
--                        unearned to earned revenue account
--	Pre-reqs	: Sufficient unearned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_rev_adj_rec           Rev_Adj_Rec_Type Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--				.
--				.
--	Version	: Current version	2.0
--				Initial version created 31-MAY-2000
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for both debits and credits
--
-----------------------------------------------------------------------
 /*#
 * Use this procedure to transfer a specified amount of revenue from
 * unearned to earned revenue account.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Transfer Unearned Revenue to Earned Revenue.
 */


 PROCEDURE Earn_Revenue
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,p_org_id                IN  NUMBER DEFAULT NULL
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2);

-----------------------------------------------------------------------
--	API name 	: Transfer_Sales_Credits
--	Type		: Public
--	Function	: Transfers revenue and/or non revenue sales credits
--                        between the specified salesreps. The associated
--                        earned revenue is transferred with revenue sales
--                        credits
--	Pre-reqs	: Sufficient earned revenue must exist for the salesrep
--                        from whom sales credits are being transferred.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_rev_adj_rec           Rev_Adj_Rec_Type Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--				Initial version created 31-MAY-2000
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for both debits and credits
--
-----------------------------------------------------------------------
 /*#
 * Use this procedure to transfer revenue and/or nonrevenue sales credits
 * between the specified salesreps. The associated  earned revenue is
 * transferred with revenue sales credits.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Transfer Sales Credits.
 */


  PROCEDURE Transfer_Sales_Credits
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,p_org_id                IN  NUMBER DEFAULT NULL
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2);

-----------------------------------------------------------------------
--	API name 	: Add_Non_Revenue_Sales_Credits
--	Type		: Public
--	Function	: Adds non revenue sales credits to the specified
--                        salesrep subject to any maximum limit of revenue
--                        and non revenue salsescredit per salesrep per line
--                        as defined in the sales credit percent limit in
--                        system options.
--	Pre-reqs	: None
--
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_rev_adj_rec           Rev_Adj_Rec_Type Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--				Initial version created 31-MAY-2000
--			  Initial version 	1.0
--
--	Notes		:
--

 /*#
 * Use this procedure to add non-revenue sales credits for salesrep to a transaction.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Non-Revenue Sales Credits.
 */

 PROCEDURE Add_Non_Revenue_Sales_Credits
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,p_org_id                IN  NUMBER DEFAULT NULL
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2);

-----------------------------------------------------------------------
--	API name 	: Record_Customer_Acceptance
--	Type		: Public
--	Function	: Records acceptance of customer_acceptance
--                        type contingencies for the specified
--                        transaction, line, or contingency.
--	Pre-reqs	: None
--
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_rev_adj_rec           Rev_Adj_Rec_Type Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--
--	Version	: Current version	2.0
--	          Initial version created 29-JUN-2006
--		  Initial version 	2.0
--
--	Notes		:
--

 /*#
 * Use this API to record acceptance for customer_acceptance type
 * contingencies on a transaction or line.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Record Customer Acceptance.
 */

 PROCEDURE Record_Customer_Acceptance
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
     ,p_org_id                IN  NUMBER DEFAULT NULL);

-----------------------------------------------------------------------
--	API name 	: Update_Contingency_Expirations
--	Type		: Public
--	Function	: Allows update of exiration_date on
--                        contingencies for a transaction or line.
--	Pre-reqs	: None
--
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--                        p_rev_adj_rec           Rev_Adj_Rec_Type Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--
--	Version	: Current version	2.0
--	          Initial version created 29-JUN-2006
--		  Initial version 	2.0
--
--	Notes		:
--

 /*#
 * Use this API to update the expiration date or days for
 * contingencies on a transaction or line.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Contingency Expirations.
 */

 PROCEDURE Update_Contingency_Expirations
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_org_id                IN  NUMBER DEFAULT NULL
     ,p_customer_trx_id       IN  ra_customer_trx.customer_trx_id%type
     ,p_customer_trx_line_id  IN  ra_customer_trx_lines.customer_trx_line_id%type DEFAULT NULL
     ,p_contingency_id        IN  ar_line_conts.contingency_id%type DEFAULT NULL
     ,p_expiration_date       IN  ar_line_conts.expiration_date%type DEFAULT NULL
     ,p_expiration_days       IN  ar_line_conts.expiration_days%type DEFAULT NULL);
END AR_RevenueAdjust_PUB;

 

/
