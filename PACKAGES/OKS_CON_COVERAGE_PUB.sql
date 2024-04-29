--------------------------------------------------------
--  DDL for Package OKS_CON_COVERAGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CON_COVERAGE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPACCS.pls 120.0 2005/05/25 18:30:34 appldev noship $ */
/*#
 * Package containing APIs to retrieve Coverage information, specifically,
 * apply_contract_coverage, which retrieves the discount amount for a
 * Business Process, and get_bp_pricelist, which returns all the Business Processes
 * and their respective Price List for a given Contract Line.
 * @rep:scope public
 * @rep:product OKS
 * @rep:displayname Coverage utility procedures
 * @rep:category BUSINESS_ENTITY OKS_COVERAGE
 * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
*/

  -- GLOBAL VARIABLES
  -------------------------------------------------------------------------------
  G_PKG_NAME	               CONSTANT VARCHAR2(200) := 'OKS_CON_COVERAGE_PUB';
  G_APP_NAME	               CONSTANT VARCHAR2(3)   :=  'OKC';
  -------------------------------------------------------------------------------

  -- procedure apply_contract_coverage ------------------------------------

  TYPE ser_rec_type IS RECORD
	(charges_line_number Number,
       estimate_detail_id  Number,
       contract_line_id    Number,
       txn_group_id        Number,
       business_process_id NUMBER,
       request_date        DATE ,
       billing_type_id     Number,
       charge_amount       Number);

  TYPE ser_tbl_type IS TABLE OF ser_rec_type INDEX BY BINARY_INTEGER;

  TYPE cov_rec_type IS RECORD
	(charges_line_number Number,
       estimate_detail_id  Number,
       contract_line_id    Number,
       txn_group_id        Number,
       business_process_id number,
       request_date        date ,
       billing_type_id     Number,
       discounted_amount   Number,
       status              Varchar2(1));

  TYPE cov_tbl_type IS TABLE OF cov_rec_type INDEX BY BINARY_INTEGER;

 /*#
  * Returns the discounted charge amount for a given business process.  This procedure returns the calculated
  * amount for a Service or Extended Warranty based up on the Discount Amount and Percentage
  * Covered, which are specified in the Service Contract coverage terms for a given business process.
  * @param  p_api_version  Version numbers of incoming calls must match this number.
  * @param  p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if API initializes message list.
  * @param  p_est_amt_tbl  Array of charge line records.
  * @param  x_return_status Possible returns are 'S'uccess, 'E'rror, or 'U'nexpected error.
  * @param  x_msg_count	Returns number of messages in API message list.
  * @param  x_msg_data  If x_msg_count is 1 then the message data is encoded.
  * @param  x_est_discounted_amt_tbl Array of estimated discounts for charge lines
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Apply Contract Coverage
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */

  PROCEDURE apply_contract_coverage
	(p_api_version	        IN  Number
	,p_init_msg_list	        IN  Varchar2
    ,p_est_amt_tbl            IN  ser_tbl_type
	,x_return_status 	        OUT NOCOPY Varchar2
	,x_msg_count	        OUT NOCOPY Number
	,x_msg_data		        OUT NOCOPY Varchar2
	,x_est_discounted_amt_tbl OUT NOCOPY cov_tbl_type);

-- procedure apply_contract_coverage ------------------------------------

-- procedure get_bp_pricelist ------------------------------------



  TYPE pricing_rec_type IS RECORD
	(  contract_line_id                  Number,
       business_process_id               NUMBER,
       BP_Price_list_id                  NUMBER,
       BP_Discount_id                    NUMBER,
       BP_start_date                     DATE,
       BP_end_date                       DATE,
       Contract_Price_list_Id            NUMBER );


  TYPE pricing_tbl_type IS TABLE OF pricing_rec_type INDEX BY BINARY_INTEGER;


 /*#
  * Returns the Price List for each Business Process in a given contract line.
  * The calling program must specify a Contract Line, a Business Process or both.  If a Contract Line
  * (and only a Contract Line) is passed, then all Price Lists associated to the Contract Line's Business
  * Processes are returned.  If a Contract Line and a Business Process are passed then only the Price List
  * associated with the Business Process is returned.  Additionally, in both cases, the default Contract Price
  * List and the discount breaks are included in the return parameter.
  * @param  p_api_version Version numbers of incoming calls must match this number.
  * @param  p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if API initializes message list.
  * @param  p_contract_line_id Unique Identifier for Contract Line
  * @param  p_business_process_id  Unique Identifier for covered Business Process
  * @param  p_request_date Date on which the transaction is requested
  * @param  x_return_status Possible returns are 'S'uccess, 'E'rror, or 'U'nexpected error.
  * @param  x_msg_count	Returns number of messages in API message list.
  * @param  x_msg_data	If x_msg_count is 1 then the message data is encoded.
  * @param  x_pricing_tbl Array of Price List records
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Business Process Price List
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */

  PROCEDURE get_bp_pricelist
	(p_api_version	        IN  Number
	,p_init_msg_list	        IN  Varchar2
    ,p_Contract_line_id		IN NUMBER
    ,p_business_process_id  IN NUMBER
    ,p_request_date         IN DATE  -- default sysdate -- GSCC warning file.sql.35
	,x_return_status 	        OUT NOCOPY Varchar2
	,x_msg_count	        OUT NOCOPY Number
	,x_msg_data		        OUT NOCOPY Varchar2
	,x_pricing_tbl		OUT NOCOPY PRICING_TBL_TYPE );

-- procedure get_bp_pricelist ------------------------------------

-- procedure get_bill_rates ------------------------------------

  TYPE input_br_rec IS RECORD
    (  contract_line_id                 Number,        --REQUIRED
       Business_process_id              number,         --REQUIRED
       txn_billing_type_id              number,         --REQUIRED
       request_date                     date           -- default to SYSDATE
    );

  TYPE labor_sch_rec_type IS RECORD
    (  start_datetime                   DATE,   --REQUIRED
       end_datetime                     DATE,   --REQUIRED
       Holiday_flag                     VARCHAR2(1)  --Y or, N can be passed , defaults to 'N'
    );

  TYPE labor_sch_tbl_type IS TABLE OF labor_sch_rec_type INDEX BY BINARY_INTEGER;

  TYPE bill_rate_rec_type IS RECORD
   (  start_datetime          DATE,
      End_datetime            DATE,
      labor_item_id           number,
      labor_item_org_id       number,
      Bill_rate_code          VARCHAR2(30),
      Flat_rate               NUMBER,
      Flat_rate_uom_code      VARCHAR2(30),
      Percent_over_listprice  NUMBER);

  TYPE bill_rate_tbl_type IS TABLE OF bill_rate_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE get_bill_rates
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,P_input_br_rec         IN INPUT_BR_REC
    ,P_labor_sch_tbl        IN LABOR_SCH_TBL_TYPE
    ,x_return_status        OUT NOCOPY Varchar2
    ,x_msg_count            OUT NOCOPY Number
    ,x_msg_data             OUT NOCOPY Varchar2
    ,X_bill_rate_tbl        OUT NOCOPY BILL_RATE_TBL_TYPE );

-- procedure get_bill_rates ------------------------------------

END OKS_CON_COVERAGE_PUB;

 

/
