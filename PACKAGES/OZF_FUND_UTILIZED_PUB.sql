--------------------------------------------------------
--  DDL for Package OZF_FUND_UTILIZED_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUND_UTILIZED_PUB" AUTHID CURRENT_USER AS
/* $Header: OZFPFUTS.pls 120.4.12010000.4 2010/03/18 05:59:10 bkunjan ship $ */
/*#
* Use this package to create manual adjustments of types Decrease Committed and Earned Amounts,
* Decrease Committed Amount, Decrease Earned Amount, Increase Earned Amount, Decrease Paid Amount
* and Increase Paid Amount in Oracle Trade Management.
* @rep:scope public
* @rep:product OZF
* @rep:lifecycle active
* @rep:displayname Budget Adjustment Public API
* @rep:compatibility S
* @rep:businessevent None
* @rep:category BUSINESS_ENTITY OZF_BUDGET
*/

/*flag to indicate whether the Account Generator Workflow gets called or not
'F' to call OZF Account Generator worflow
'T' to bypass OZF Account Generator worflow */
 --ER:9382547
--g_skip_acct_gen_flag VARCHAR2(1);

TYPE adjustment_rec_type IS RECORD
(fund_id                NUMBER
,fund_number            VARCHAR2(30)
,adjustment_type        VARCHAR2(30)
,adjustment_type_id     NUMBER
,amount                 NUMBER
,currency_code          VARCHAR2(30)
--nirprasa,12.2 nirprasa   ER 8399134
--plan_amount = amount in activity currency or amount in document currency for null currency offers.
--plan_currency_code = activity currency or document currency for null currency offers.
,plan_amount            NUMBER
,plan_currency_code     VARCHAR2(30)
,adjustment_date        DATE
,gl_date                DATE
,activity_type          VARCHAR2(4)
,activity_id            NUMBER
,offer_code             VARCHAR2(30)
,camp_schedule_id       NUMBER
,customer_type          VARCHAR2(20)
,cust_id                NUMBER
,cust_account_id        NUMBER
,bill_to_site_use_id    NUMBER
,ship_to_site_use_id    NUMBER
,document_type          VARCHAR2(30)
,document_number        NUMBER
,scan_type_id           NUMBER
,product_level_type     VARCHAR2(10)
,product_name           VARCHAR2(50)
,product_id             NUMBER
,justification          VARCHAR2(100)
,orig_utilization_id    NUMBER
,gl_account_credit      NUMBER
,gl_account_debit       NUMBER
,approver_id            NUMBER
,org_id                 NUMBER
 --ER:9382547 - Removed the column
--,skip_acct_gen_flag     VARCHAR2(1)
--DFF/order_line_id added for ER-6858324
,order_line_id          NUMBER
,exchange_rate_date     DATE --bug 8532055
,attribute_category     VARCHAR2(30)
,attribute1             VARCHAR2(150)
,attribute2             VARCHAR2(150)
,attribute3             VARCHAR2(150)
,attribute4             VARCHAR2(150)
,attribute5             VARCHAR2(150)
,attribute6             VARCHAR2(150)
,attribute7             VARCHAR2(150)
,attribute8             VARCHAR2(150)
,attribute9             VARCHAR2(150)
,attribute10            VARCHAR2(150)
,attribute11            VARCHAR2(150)
,attribute12            VARCHAR2(150)
,attribute13            VARCHAR2(150)
,attribute14            VARCHAR2(150)
,attribute15            VARCHAR2(150)
);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Fund_Adjustment
--
-- PURPOSE
--    Create fund adjustment.
--
-- PARAMETERS
--    p_adj_rec: the new record to be inserted
--
-- HISTORY
--    04/05/2005  kdass Created
---------------------------------------------------------------------
/*#
* This procedure creates a fund adjustment.
* @param p_api_version      Indicates the API version.
* @param p_init_msg_list    Indicates whether to initialize the message stack.
* @param p_commit           Indicates whether to commit within the program.
* @param p_validation_level Indicates the validation level.
* @param p_adj_rec          Identifies the new record to be inserted.
* @param x_return_status    Indicates the status of the program.
* @param x_msg_data         Returns messages by the program
* @param x_msg_count        Indicates the number of messages the program returned.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Fund Adjustment
* @rep:compatibility S
* @rep:businessevent None
*/
PROCEDURE Create_Fund_Adjustment(
   p_api_version        IN              NUMBER
  ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  ,p_commit             IN              VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN              NUMBER   := fnd_api.g_valid_level_full
  ,p_adj_rec            IN              OZF_FUND_UTILIZED_PUB.adjustment_rec_type
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  );

END OZF_FUND_UTILIZED_PUB;

/
