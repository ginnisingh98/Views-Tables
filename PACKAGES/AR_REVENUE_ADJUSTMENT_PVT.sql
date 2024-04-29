--------------------------------------------------------
--  DDL for Package AR_REVENUE_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_REVENUE_ADJUSTMENT_PVT" AUTHID CURRENT_USER AS
/*$Header: ARXVRADS.pls 120.11.12010000.4 2009/04/06 08:57:56 ankuagar ship $*/
  g_system_cache_flag        VARCHAR2(1) := 'N';

  TYPE RA_Dist_Tbl_Type IS TABLE OF ra_cust_trx_line_gl_dist%ROWTYPE
     INDEX BY BINARY_INTEGER;

  g_update_db_flag      VARCHAR2(1) := 'Y';

  TYPE Rev_Adj_Rec_Type IS RECORD
  ( CUSTOMER_TRX_ID                          NUMBER(15)
   ,TRX_NUMBER                               RA_CUSTOMER_TRX.trx_number%TYPE
   ,BATCH_SOURCE_NAME                        RA_BATCH_SOURCES.name%TYPE
   ,ADJUSTMENT_TYPE                          VARCHAR2(15) DEFAULT 'UN'
   ,FROM_SALESREP_ID                         NUMBER(15)
   ,FROM_SALESREP_NUMBER                     RA_SALESREPS.salesrep_number%TYPE
   ,TO_SALESREP_ID                           NUMBER(15)
   ,TO_SALESREP_NUMBER                       RA_SALESREPS.salesrep_number%TYPE
   ,FROM_SALESGROUP_ID			     jtf_rs_groups_b.group_id%TYPE
   ,TO_SALESGROUP_ID			     jtf_rs_groups_b.group_id%TYPE
   ,SALES_CREDIT_TYPE                        VARCHAR2(15) DEFAULT 'R'
   ,AMOUNT_MODE                              VARCHAR2(15) DEFAULT 'T'
   ,AMOUNT                                   NUMBER
   ,PERCENT                                  NUMBER
   ,LINE_SELECTION_MODE                      VARCHAR2(15) DEFAULT 'A'
   ,FROM_CATEGORY_ID                         NUMBER(15)
   ,FROM_CATEGORY_SEGMENT1                   VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT2                   VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT3                   VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT4                   VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT5                   VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT6                   VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT7                   VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT8                   VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT9                   VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT10                  VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT11                  VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT12                  VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT13                  VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT14                  VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT15                  VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT16                  VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT17                  VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT18                  VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT19                  VARCHAR2(40)
   ,FROM_CATEGORY_SEGMENT20                  VARCHAR2(40)
   ,TO_CATEGORY_ID                           NUMBER(15)
   ,TO_CATEGORY_SEGMENT1                     VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT2                     VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT3                     VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT4                     VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT5                     VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT6                     VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT7                     VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT8                     VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT9                     VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT10                    VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT11                    VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT12                    VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT13                    VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT14                    VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT15                    VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT16                    VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT17                    VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT18                    VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT19                    VARCHAR2(40)
   ,TO_CATEGORY_SEGMENT20                    VARCHAR2(40)
   ,FROM_INVENTORY_ITEM_ID                   NUMBER(15)
   ,FROM_ITEM_SEGMENT1                       VARCHAR2(40)
   ,FROM_ITEM_SEGMENT2                       VARCHAR2(40)
   ,FROM_ITEM_SEGMENT3                       VARCHAR2(40)
   ,FROM_ITEM_SEGMENT4                       VARCHAR2(40)
   ,FROM_ITEM_SEGMENT5                       VARCHAR2(40)
   ,FROM_ITEM_SEGMENT6                       VARCHAR2(40)
   ,FROM_ITEM_SEGMENT7                       VARCHAR2(40)
   ,FROM_ITEM_SEGMENT8                       VARCHAR2(40)
   ,FROM_ITEM_SEGMENT9                       VARCHAR2(40)
   ,FROM_ITEM_SEGMENT10                      VARCHAR2(40)
   ,FROM_ITEM_SEGMENT11                      VARCHAR2(40)
   ,FROM_ITEM_SEGMENT12                      VARCHAR2(40)
   ,FROM_ITEM_SEGMENT13                      VARCHAR2(40)
   ,FROM_ITEM_SEGMENT14                      VARCHAR2(40)
   ,FROM_ITEM_SEGMENT15                      VARCHAR2(40)
   ,FROM_ITEM_SEGMENT16                      VARCHAR2(40)
   ,FROM_ITEM_SEGMENT17                      VARCHAR2(40)
   ,FROM_ITEM_SEGMENT18                      VARCHAR2(40)
   ,FROM_ITEM_SEGMENT19                      VARCHAR2(40)
   ,FROM_ITEM_SEGMENT20                      VARCHAR2(40)
   ,TO_INVENTORY_ITEM_ID                     NUMBER(15)
   ,TO_ITEM_SEGMENT1                         VARCHAR2(40)
   ,TO_ITEM_SEGMENT2                         VARCHAR2(40)
   ,TO_ITEM_SEGMENT3                         VARCHAR2(40)
   ,TO_ITEM_SEGMENT4                         VARCHAR2(40)
   ,TO_ITEM_SEGMENT5                         VARCHAR2(40)
   ,TO_ITEM_SEGMENT6                         VARCHAR2(40)
   ,TO_ITEM_SEGMENT7                         VARCHAR2(40)
   ,TO_ITEM_SEGMENT8                         VARCHAR2(40)
   ,TO_ITEM_SEGMENT9                         VARCHAR2(40)
   ,TO_ITEM_SEGMENT10                        VARCHAR2(40)
   ,TO_ITEM_SEGMENT11                        VARCHAR2(40)
   ,TO_ITEM_SEGMENT12                        VARCHAR2(40)
   ,TO_ITEM_SEGMENT13                        VARCHAR2(40)
   ,TO_ITEM_SEGMENT14                        VARCHAR2(40)
   ,TO_ITEM_SEGMENT15                        VARCHAR2(40)
   ,TO_ITEM_SEGMENT16                        VARCHAR2(40)
   ,TO_ITEM_SEGMENT17                        VARCHAR2(40)
   ,TO_ITEM_SEGMENT18                        VARCHAR2(40)
   ,TO_ITEM_SEGMENT19                        VARCHAR2(40)
   ,TO_ITEM_SEGMENT20                        VARCHAR2(40)
   ,FROM_CUST_TRX_LINE_ID                    NUMBER(15)
   ,FROM_LINE_NUMBER                         NUMBER(15)
   ,TO_CUST_TRX_LINE_ID                      NUMBER(15)
   ,TO_LINE_NUMBER                           NUMBER(15)
   ,GL_DATE                                  DATE
   ,REASON_CODE                              VARCHAR2(15)
   ,COMMENTS                                 VARCHAR2(2000)
   ,ATTRIBUTE_CATEGORY                       VARCHAR2(30)
   ,ATTRIBUTE1                               VARCHAR2(150)
   ,ATTRIBUTE2                               VARCHAR2(150)
   ,ATTRIBUTE3                               VARCHAR2(150)
   ,ATTRIBUTE4                               VARCHAR2(150)
   ,ATTRIBUTE5                               VARCHAR2(150)
   ,ATTRIBUTE6                               VARCHAR2(150)
   ,ATTRIBUTE7                               VARCHAR2(150)
   ,ATTRIBUTE8                               VARCHAR2(150)
   ,ATTRIBUTE9                               VARCHAR2(150)
   ,ATTRIBUTE10                              VARCHAR2(150)
   ,ATTRIBUTE11                              VARCHAR2(150)
   ,ATTRIBUTE12                              VARCHAR2(150)
   ,ATTRIBUTE13                              VARCHAR2(150)
   ,ATTRIBUTE14                              VARCHAR2(150)
   ,ATTRIBUTE15                              VARCHAR2(150)
   ,SOURCE                                   VARCHAR2(30) DEFAULT NULL
);

  TYPE Segment_Rec_Type IS RECORD
  ( segment1                                 VARCHAR2(40)
   ,segment2                                 VARCHAR2(40)
   ,segment3                                 VARCHAR2(40)
   ,segment4                                 VARCHAR2(40)
   ,segment5                                 VARCHAR2(40)
   ,segment6                                 VARCHAR2(40)
   ,segment7                                 VARCHAR2(40)
   ,segment8                                 VARCHAR2(40)
   ,segment9                                 VARCHAR2(40)
   ,segment10                                VARCHAR2(40)
   ,segment11                                VARCHAR2(40)
   ,segment12                                VARCHAR2(40)
   ,segment13                                VARCHAR2(40)
   ,segment14                                VARCHAR2(40)
   ,segment15                                VARCHAR2(40)
   ,segment16                                VARCHAR2(40)
   ,segment17                                VARCHAR2(40)
   ,segment18                                VARCHAR2(40)
   ,segment19                                VARCHAR2(40)
   ,segment20                                VARCHAR2(40));

-----------------------------------------------------------------------
--	API name 	: Unearn_Revenue
--	Type		: Private
--	Function	: Transfers a specified amount of revenue from
--                        earned to unearned revenue account
--	Pre-reqs	: Sufficient earned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number    VARCHAR2
--				.
--				.
--	Version	: Current version	2.0
--                              IN parameters consolidated into new record type
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for both debits and credits
--

-----------------------------------------------------------------------
  PROCEDURE Unearn_Revenue
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_validation_level      IN   NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2);

-----------------------------------------------------------------------
--	API name 	: Earn_Revenue
--	Type		: Private
--	Function	: Transfers a specified amount of revenue from
--                        unearned to earned revenue account
--	Pre-reqs	: Sufficient unearned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number    VARCHAR2
--				.
--				.
--	Version	: Current version	2.0
--                              IN parameters consolidated into new record type
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for both debits and credits
--
-----------------------------------------------------------------------
  PROCEDURE Earn_Revenue
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_validation_level      IN   NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2);

-----------------------------------------------------------------------
--OVERLOADED EARN_REVENUE procedure
--
--NOTE : This procedure is not published and must not be used by customers
--
--	API name 	: Earn_Revenue
--	Type		: Private
--	Function	: Transfers a specified amount of revenue from
--                        unearned to earned revenue account
--	Pre-reqs	: Sufficient unearned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number    VARCHAR2
--                        x_ra_dist_tbl          RA_Dist_Tbl_Type
--				.
--				.
--	Version	: Current version	2.0
--                              IN parameters consolidated into new record type
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for both debits and credits
--                        Does not write to database, instead it passes
--                        new distribution data back to calling routine
--                        in a pl/sql table parameter
-----------------------------------------------------------------------
  PROCEDURE Earn_Revenue
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_validation_level      IN   NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2
     ,x_dist_count            OUT NOCOPY  NUMBER
     ,x_ra_dist_tbl           OUT NOCOPY RA_Dist_Tbl_Type);

  PROCEDURE earn_or_unearn
     (p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,p_validation_level      IN   NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2);

-----------------------------------------------------------------------
--	API name 	: Transfer_Sales_Credits
--	Type		: Private
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
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Required
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--                              IN parameters consolidated into new record type
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for both debits and credits
--
-----------------------------------------------------------------------

  PROCEDURE Transfer_Sales_Credits
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_validation_level      IN   NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2);

-----------------------------------------------------------------------
--	API name 	: Add_Non_Revenue_Sales_Credits
--	Type		: Private
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
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Optional
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number     VARCHAR2
--
--	Version	: Current version	2.0
--				IN parameters consolidated into new record type
--			  Initial version 	1.0
--
--	Notes		:
--
  PROCEDURE Add_Non_Revenue_Sales_Credits
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_validation_level      IN   NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2);

  PROCEDURE transfer_salesrep_revenue
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_sales_credit_id       IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_revenue_acctd_amount  IN NUMBER
     ,p_gl_date	              IN DATE
     ,p_ccid                  IN NUMBER
     ,p_last_salesrep_flag    IN VARCHAR2
     ,p_line_amount           IN NUMBER
     ,p_line_amount_acctd     IN NUMBER
     ,p_adjustment_id         IN NUMBER);

  PROCEDURE debit_credit
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_gl_date	              IN DATE
     ,p_credit_ccid           IN NUMBER
     ,p_inventory_item_id     IN NUMBER
     ,p_memo_line_id          IN NUMBER
     ,p_adjustment_id         IN NUMBER
     ,p_user_generated_flag   IN VARCHAR2 DEFAULT NULL);

  PROCEDURE no_rule_debit_credit
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_gl_date	              IN DATE
     ,p_credit_ccid           IN NUMBER
     ,p_inventory_item_id     IN NUMBER
     ,p_memo_line_id          IN NUMBER
     ,p_adjustment_id         IN NUMBER
     ,p_user_generated_flag   IN VARCHAR2 DEFAULT NULL);

  /* 5021530 - procedure that does not require salesreps
      on non-rule transactions */
  PROCEDURE no_rule_debit_credit_no_sr
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_gl_date	              IN DATE
     ,p_credit_ccid           IN NUMBER
     ,p_inventory_item_id     IN NUMBER
     ,p_memo_line_id          IN NUMBER
     ,p_adjustment_id         IN NUMBER
     ,p_user_generated_flag   IN VARCHAR2 DEFAULT NULL);


/* 3879222 - procedure for supporting override of autoacc */
  PROCEDURE dists_by_model
     (p_customer_trx_id       IN NUMBER DEFAULT NULL
     ,p_customer_trx_line_id  IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_adjustment_id         IN NUMBER
     ,p_user_generated_flag   IN VARCHAR2 DEFAULT NULL
     ,p_gl_date               IN DATE DEFAULT NULL
     ,p_original_gl_date      IN DATE DEFAULT NULL
     ,p_rule_start_date       IN DATE DEFAULT NULL
     ,p_deferred_revenue_flag IN VARCHAR2 DEFAULT NULL);

-----------------------------------------------------------------------
--	API name 	: Transfer_Revenue_Between_Lines
--	Type		: Private
--	Function	: Transfers a specified amount of revenue between
--                        specified transaction lines via a clearing account
--	Pre-reqs	: Sufficient earned revenue must exist.
--	Parameters	:
--	IN		: p_api_version        	  NUMBER       Required
--		 	  p_init_msg_list         VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_commit                VARCHAR2     Optional
--				Default = FND_API.G_FALSE
--			  p_validation_level	  NUMBER       Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_rev_adj_rec           Rev_Adj_Rec_Type  Optional
--	OUT NOCOPY		: x_return_status         VARCHAR2(1)
--                        x_msg_count             NUMBER
--                        x_msg_data              VARCHAR2(2000)
--                        x_adjustment_id         NUMBER
--                        x_adjustment_number    VARCHAR2
--				.
--				.
--	Version	: Current version	2.0
--				IN parameters consolidated into new record type
--			  Initial version 	1.0
--
--	Notes		: AutoAccounting used for revenue debits and credits
--

-----------------------------------------------------------------------
  PROCEDURE Transfer_Revenue_Between_Lines
  (   p_api_version           IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_commit	              IN   VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_validation_level      IN   NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_rev_adj_rec           IN   Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY  NUMBER
     ,x_adjustment_number     OUT NOCOPY  VARCHAR2);

  PROCEDURE reset_dist_percent
     (p_customer_trx_line_id  IN NUMBER);

  PROCEDURE create_adjustment
     (p_rev_adj_rec           IN  Rev_Adj_Rec_Type
     ,x_adjustment_id         OUT NOCOPY NUMBER
     ,x_adjustment_number     OUT NOCOPY VARCHAR2);

  PROCEDURE cr_target_line_unearned
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_revenue_amount        IN NUMBER
     ,p_gl_date	              IN DATE
     ,p_inventory_item_id     IN NUMBER
     ,p_memo_line_id          IN NUMBER
     ,p_adjustment_id         IN NUMBER);

  PROCEDURE insert_distribution (p_customer_trx_line_id      IN  NUMBER,
                                 p_ccid                      IN  NUMBER,
                                 p_percent                   IN  NUMBER,
                                 p_acctd_amount              IN  NUMBER,
                                 p_gl_date                   IN  DATE,
                                 p_orig_gl_date              IN  DATE,
                                 p_account_class             IN  VARCHAR2,
                                 p_amount                    IN  NUMBER,
                                 p_cust_trx_line_salesrep_id IN  NUMBER,
                                 p_customer_trx_id           IN  NUMBER,
                                 p_adjustment_id             IN  NUMBER,
				 p_user_generated_flag	     IN  VARCHAR2
                                           DEFAULT NULL,
                                 p_rounding_flag             IN  VARCHAR2
                                           DEFAULT NULL);

  PROCEDURE insert_sales_credit (p_customer_trx_id IN NUMBER,
                                p_salesrep_id      IN NUMBER,
                                p_salesgroup_id    IN NUMBER,
                                p_cust_trx_line_id IN NUMBER,
                                p_amount           IN NUMBER,
                                p_percent          IN NUMBER,
                                p_type             IN VARCHAR2,
                                p_sales_credit_id  IN OUT NOCOPY NUMBER,
                                p_adjustment_id    IN NUMBER,
                                p_gl_date          IN DATE);

  FUNCTION category_set_id
  RETURN VARCHAR2;

  FUNCTION inv_org_id
  RETURN VARCHAR2;

  PROCEDURE Record_Acceptance
       (p_customer_trx_id      IN  ra_customer_trx.customer_trx_id%TYPE,
        p_category_id          IN  mtl_categories.category_id%TYPE,
        p_inventory_item_id    IN  mtl_system_items.inventory_item_id%TYPE,
        p_customer_trx_line_id IN  ra_customer_trx_lines.customer_trx_line_id%TYPE,
        p_gl_date              IN  ra_cust_trx_line_gl_dist.gl_date%TYPE,
        p_comments             IN  ar_revenue_adjustments.comments%TYPE,
        p_ram_desc_flexfield   IN  ar_revenue_management_pvt.desc_flexfield,
        x_scenario             OUT NOCOPY NUMBER,
        x_first_rev_adj_id     OUT NOCOPY ar_revenue_adjustments.revenue_adjustment_id%TYPE,
        x_last_rev_adj_id      OUT NOCOPY ar_revenue_adjustments.revenue_adjustment_id%TYPE,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2);

END AR_Revenue_Adjustment_PVT;

/
