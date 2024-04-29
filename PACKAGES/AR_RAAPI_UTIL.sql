--------------------------------------------------------
--  DDL for Package AR_RAAPI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAAPI_UTIL" AUTHID CURRENT_USER AS
/*$Header: ARXRAAUS.pls 120.6.12010000.5 2010/01/29 01:58:48 nproddut ship $*/
  g_system_cache_flag        VARCHAR2(1) := 'N';

  g_set_of_books_id          NUMBER;
  g_rev_transfer_clear_ccid  NUMBER;
  g_sales_credit_pct_limit   NUMBER;
  g_ar_app_id                NUMBER;
  g_inv_org_id               NUMBER;
  g_chart_of_accounts_id     NUMBER;
  g_set_of_books_currency    VARCHAR2(15);
  g_set_of_books_precision   NUMBER;
  g_min_acc_unit             NUMBER;
  g_cost_ctr_number          NUMBER;
  g_category_set_id          NUMBER;
  g_category_structure_id    NUMBER;
  g_ea_meaning               VARCHAR2(80);
  g_un_meaning               VARCHAR2(80);
  g_sa_meaning               VARCHAR2(80);
  g_ll_meaning               VARCHAR2(80);
  g_nr_meaning               VARCHAR2(80);

  g_customer_trx_id          NUMBER;
  g_last_customer_trx_id     NUMBER;
  g_cust_trx_type_id         NUMBER;
  g_trx_date                 DATE;
  g_invoicing_rule_id        NUMBER;
  g_trx_currency             VARCHAR2(15);
  g_trx_curr_format          VARCHAR2(30);
  g_exchange_rate            NUMBER;
  g_trx_precision            NUMBER;

  g_from_salesrep_id         NUMBER;
  g_to_salesrep_id           NUMBER;
  g_from_salesgroup_id       NUMBER;
  g_to_salesgroup_id         NUMBER;
  g_from_category_id         NUMBER;
  g_to_category_id           NUMBER;
  g_from_inventory_item_id   NUMBER;
  g_to_inventory_item_id     NUMBER;
  g_from_cust_trx_line_id    NUMBER;
  g_to_cust_trx_line_id      NUMBER;

  g_gl_date                  DATE;

  g_called_from              VARCHAR2(30);

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

  PROCEDURE Constant_System_Values;

  PROCEDURE Initialize_Globals;

  PROCEDURE Constant_Trx_Values
     (p_customer_trx_id       IN  NUMBER);

  FUNCTION Get_Salesrep_Cost_Ctr
    (p_salesrep_id  IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION Get_Cost_Ctr
    (p_code_combination_id  IN NUMBER)
  RETURN VARCHAR2;

  PROCEDURE Validate_Parameters
        (p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_rev_adj_rec         IN OUT NOCOPY AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
        ,p_validation_level    IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
        ,x_return_status       IN OUT NOCOPY VARCHAR2
        ,x_msg_count           OUT NOCOPY NUMBER
        ,x_msg_data            OUT NOCOPY VARCHAR2);

  PROCEDURE Validate_Transaction
        (p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_rev_adj_rec           IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
        ,p_validation_level      IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
        ,x_return_status         IN OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2);

  PROCEDURE Validate_Salesreps
        (p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_rev_adj_rec           IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
        ,x_return_status         IN OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2);

  PROCEDURE Validate_Category
        (p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_rev_adj_rec           IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
        ,x_return_status         IN OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2);

  PROCEDURE Validate_Item
        (p_init_msg_list          IN  VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_rev_adj_rec            IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
        ,x_return_status          IN OUT NOCOPY VARCHAR2
        ,x_msg_count              OUT NOCOPY NUMBER
        ,x_msg_data               OUT NOCOPY VARCHAR2);

  PROCEDURE Validate_Line
        (p_init_msg_list          IN  VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_rev_adj_rec            IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
        ,x_return_status          IN OUT NOCOPY VARCHAR2
        ,x_msg_count              OUT NOCOPY NUMBER
        ,x_msg_data               OUT NOCOPY VARCHAR2);

  FUNCTION Validate_GL_Date
        (p_gl_date                IN  DATE)
  RETURN DATE;

  FUNCTION bump_gl_date_if_closed
        (p_gl_date                IN DATE)
  RETURN DATE;

  PROCEDURE Validate_Other
        (p_init_msg_list          IN  VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_rev_adj_rec            IN  AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type
        ,x_return_status          IN OUT NOCOPY VARCHAR2
        ,x_msg_count              OUT NOCOPY NUMBER
        ,x_msg_data               OUT NOCOPY VARCHAR2);

  PROCEDURE Validate_Sales_Credits
          (p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
          ,p_customer_trx_id       IN  NUMBER
          ,p_sales_credit_type     IN  VARCHAR2
          ,p_salesrep_id           IN  NUMBER
          ,p_salesgroup_id         IN  NUMBER DEFAULT NULL
          ,p_customer_trx_line_id  IN  NUMBER
          ,p_item_id               IN  NUMBER
          ,p_category_id           IN  NUMBER
          ,x_return_status         IN OUT NOCOPY VARCHAR2
          ,x_msg_count             OUT NOCOPY NUMBER
          ,x_msg_data              OUT NOCOPY VARCHAR2);

  FUNCTION Total_Selected_Line_Value
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_item_id               IN NUMBER
     ,p_category_id           IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_salesgroup_id         IN NUMBER DEFAULT NULL
     ,p_sales_credit_type     IN VARCHAR2)
  RETURN NUMBER;

  FUNCTION Adjustable_Revenue
     (p_customer_trx_line_id  IN NUMBER
     ,p_adjustment_type       IN VARCHAR2
     ,p_customer_trx_id       IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_salesgroup_id         IN NUMBER DEFAULT NULL
     ,p_sales_credit_type     IN VARCHAR2
     ,p_item_id               IN NUMBER
     ,p_category_id           IN NUMBER
     ,p_revenue_adjustment_id IN NUMBER := NULL
     ,p_line_count_out        OUT NOCOPY NUMBER
     ,p_acctd_amount_out      OUT NOCOPY NUMBER)
  RETURN NUMBER;

  FUNCTION Adjustable_Revenue_Total
     (p_customer_trx_line_id  IN NUMBER
     ,p_customer_trx_id       IN NUMBER
     ,p_adjustment_type       IN VARCHAR2
     ,p_revenue_adjustment_id IN NUMBER DEFAULT NULL)
  RETURN NUMBER;


  PROCEDURE Validate_Amount
     (p_init_msg_list         IN VARCHAR2 DEFAULT FND_API.G_FALSE
     ,p_customer_trx_line_id  IN NUMBER
     ,p_adjustment_type       IN VARCHAR2
     ,p_amount_mode           IN VARCHAR2
     ,p_customer_trx_id       IN NUMBER
     ,p_salesrep_id           IN NUMBER
     ,p_salesgroup_id         IN NUMBER DEFAULT NULL
     ,p_sales_credit_type     IN VARCHAR2
     ,p_item_id               IN NUMBER
     ,p_category_id           IN NUMBER
     ,p_revenue_amount_in     IN NUMBER
     ,p_revenue_percent       IN NUMBER
     ,p_revenue_adjustment_id IN NUMBER := NULL
     ,p_revenue_amount_out    OUT NOCOPY NUMBER
     ,p_adjustable_amount_out OUT NOCOPY NUMBER
     ,p_line_count_out        OUT NOCOPY NUMBER
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2);

  FUNCTION Revalidate_GL_Dates
       (p_customer_trx_id       IN NUMBER
       ,p_revenue_adjustment_id IN NUMBER
       ,x_msg_count             OUT NOCOPY NUMBER
       ,x_msg_data              OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION Deferred_GL_Date (p_start_date    IN  DATE,
                             p_period_seq_no IN NUMBER)
  RETURN DATE;

  /* 7454302 */
  FUNCTION unearned_zero_lines(p_customer_trx_id IN NUMBER,
                               p_customer_trx_line_id IN NUMBER DEFAULT NULL,
                               p_check_line_amt IN VARCHAR DEFAULT 'Y')
  RETURN BOOLEAN;

  --
  -- Read only functions to allow client access to globals
  --
  FUNCTION G_RET_STS_SUCCESS
  RETURN VARCHAR2;

  FUNCTION G_RET_STS_ERROR
  RETURN VARCHAR2;

  FUNCTION G_TRUE
  RETURN VARCHAR2;

  FUNCTION G_FALSE
  RETURN VARCHAR2;

  FUNCTION G_VALID_LEVEL_NONE
  RETURN VARCHAR2;

  FUNCTION G_VALID_LEVEL_FULL
  RETURN VARCHAR2;

  FUNCTION chart_of_accounts_id
  RETURN NUMBER;

  FUNCTION set_of_books_id
  RETURN NUMBER;

  FUNCTION application_id
  RETURN NUMBER;

  FUNCTION un_meaning
  RETURN VARCHAR2;

  FUNCTION ea_meaning
  RETURN VARCHAR2;

  FUNCTION sa_meaning
  RETURN VARCHAR2;

  FUNCTION nr_meaning
  RETURN VARCHAR2;

  FUNCTION ll_meaning
  RETURN VARCHAR2;

  FUNCTION cost_ctr_number
  RETURN VARCHAR2;

  FUNCTION category_set_id
  RETURN VARCHAR2;

  FUNCTION category_structure_id
  RETURN VARCHAR2;

  FUNCTION inv_org_id
  RETURN VARCHAR2;

END AR_RAAPI_UTIL;

/
