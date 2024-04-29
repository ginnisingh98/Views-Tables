--------------------------------------------------------
--  DDL for Package CN_GET_TX_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GET_TX_DATA_PUB" AUTHID CURRENT_USER AS
-- $Header: cnpxadjs.pls 120.1.12000000.2 2007/08/07 14:24:35 apink ship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+

--
-- Package Name
--   cn_get_tx_data_pub
-- Purpose
--   Package Body for Mass Adjustments Package
-- History
--+ 08/08/2005 Hithanki R12 Version
--

TYPE adj_rec_type IS RECORD(
	commission_header_id         	number		:= fnd_api.g_miss_num,
	direct_salesrep_number          varchar2(30) 	:= fnd_api.g_miss_char,
	direct_salesrep_name            varchar2(360) 	:= fnd_api.g_miss_char,
	direct_salesrep_id              number 		:= fnd_api.g_miss_num,
	processed_period_id             number 		:= fnd_api.g_miss_num,
	processed_period                varchar2(30) 	:= fnd_api.g_miss_char,
	processed_date                  date 		:= fnd_api.g_miss_date,
	rollup_date                     date 		:= fnd_api.g_miss_date,
	transaction_amount              number 		:= fnd_api.g_miss_num,
	transaction_amount_orig		number 		:= fnd_api.g_miss_num,
	quantity                        number 		:= fnd_api.g_miss_num,
	discount_percentage             number 		:= fnd_api.g_miss_num,
	margin_percentage               number 		:= fnd_api.g_miss_num,
	orig_currency_code              varchar2(15) 	:= fnd_api.g_miss_char,
	exchange_rate                   number 		:= fnd_api.g_miss_num,
	status_disp                     varchar2(80) 	:= fnd_api.g_miss_char,
	status                          varchar2(30) 	:= fnd_api.g_miss_char,
	trx_type_disp                   varchar2(80) 	:= fnd_api.g_miss_char,
	trx_type                        varchar2(30) 	:= fnd_api.g_miss_char,
	reason                          varchar2(80) 	:= fnd_api.g_miss_char,
	reason_code                     varchar2(30) 	:= fnd_api.g_miss_char,
	comments                        varchar2(1800) 	:= fnd_api.g_miss_char,
	trx_batch_id                    number 		:= fnd_api.g_miss_num,
	created_by                      number 		:= fnd_api.g_miss_num,
	creation_date                   date 		:= fnd_api.g_miss_date,
	last_updated_by                 number 		:= fnd_api.g_miss_num,
	last_update_login               number 		:= fnd_api.g_miss_num,
	last_update_date                date 		:= fnd_api.g_miss_date,
	attribute_category              varchar2(30) 	:= fnd_api.g_miss_char,
	attribute1			varchar2(240)	:= fnd_api.g_miss_char,
	attribute2			varchar2(240)	:= fnd_api.g_miss_char,
	attribute3			varchar2(240)	:= fnd_api.g_miss_char,
	attribute4			varchar2(240)	:= fnd_api.g_miss_char,
	attribute5			varchar2(240)	:= fnd_api.g_miss_char,
	attribute6			varchar2(240)	:= fnd_api.g_miss_char,
	attribute7			varchar2(240)	:= fnd_api.g_miss_char,
	attribute8			varchar2(240)	:= fnd_api.g_miss_char,
	attribute9			varchar2(240)	:= fnd_api.g_miss_char,
	attribute10			varchar2(240)	:= fnd_api.g_miss_char,
	attribute11			varchar2(240)	:= fnd_api.g_miss_char,
	attribute12			varchar2(240)	:= fnd_api.g_miss_char,
	attribute13			varchar2(240)	:= fnd_api.g_miss_char,
	attribute14			varchar2(240)	:= fnd_api.g_miss_char,
	attribute15			varchar2(240)	:= fnd_api.g_miss_char,
	attribute16			varchar2(240)	:= fnd_api.g_miss_char,
	attribute17			varchar2(240)	:= fnd_api.g_miss_char,
	attribute18			varchar2(240)	:= fnd_api.g_miss_char,
	attribute19			varchar2(240)	:= fnd_api.g_miss_char,
	attribute20			varchar2(240)	:= fnd_api.g_miss_char,
	attribute21			varchar2(240)	:= fnd_api.g_miss_char,
	attribute22			varchar2(240)	:= fnd_api.g_miss_char,
	attribute23			varchar2(240)	:= fnd_api.g_miss_char,
	attribute24			varchar2(240)	:= fnd_api.g_miss_char,
	attribute25			varchar2(240)	:= fnd_api.g_miss_char,
	attribute26			varchar2(240)	:= fnd_api.g_miss_char,
	attribute27			varchar2(240)	:= fnd_api.g_miss_char,
	attribute28			varchar2(240)	:= fnd_api.g_miss_char,
	attribute29			varchar2(240)	:= fnd_api.g_miss_char,
	attribute30			varchar2(240)	:= fnd_api.g_miss_char,
	attribute31			varchar2(240)	:= fnd_api.g_miss_char,
	attribute32			varchar2(240)	:= fnd_api.g_miss_char,
	attribute33			varchar2(240)	:= fnd_api.g_miss_char,
	attribute34			varchar2(240)	:= fnd_api.g_miss_char,
	attribute35			varchar2(240)	:= fnd_api.g_miss_char,
	attribute36			varchar2(240)	:= fnd_api.g_miss_char,
	attribute37			varchar2(240)	:= fnd_api.g_miss_char,
	attribute38			varchar2(240)	:= fnd_api.g_miss_char,
	attribute39			varchar2(240)	:= fnd_api.g_miss_char,
	attribute40			varchar2(240)	:= fnd_api.g_miss_char,
	attribute41			varchar2(240)	:= fnd_api.g_miss_char,
	attribute42			varchar2(240)	:= fnd_api.g_miss_char,
	attribute43			varchar2(240)	:= fnd_api.g_miss_char,
	attribute44			varchar2(240)	:= fnd_api.g_miss_char,
	attribute45			varchar2(240)	:= fnd_api.g_miss_char,
	attribute46			varchar2(240)	:= fnd_api.g_miss_char,
	attribute47			varchar2(240)	:= fnd_api.g_miss_char,
	attribute48			varchar2(240)	:= fnd_api.g_miss_char,
	attribute49			varchar2(240)	:= fnd_api.g_miss_char,
	attribute50			varchar2(240)	:= fnd_api.g_miss_char,
	attribute51			varchar2(240)	:= fnd_api.g_miss_char,
	attribute52			varchar2(240)	:= fnd_api.g_miss_char,
	attribute53			varchar2(240)	:= fnd_api.g_miss_char,
	attribute54			varchar2(240)	:= fnd_api.g_miss_char,
	attribute55			varchar2(240)	:= fnd_api.g_miss_char,
	attribute56			varchar2(240)	:= fnd_api.g_miss_char,
	attribute57			varchar2(240)	:= fnd_api.g_miss_char,
	attribute58			varchar2(240)	:= fnd_api.g_miss_char,
	attribute59			varchar2(240)	:= fnd_api.g_miss_char,
	attribute60			varchar2(240)	:= fnd_api.g_miss_char,
	attribute61			varchar2(240)	:= fnd_api.g_miss_char,
	attribute62			varchar2(240)	:= fnd_api.g_miss_char,
	attribute63			varchar2(240)	:= fnd_api.g_miss_char,
	attribute64			varchar2(240)	:= fnd_api.g_miss_char,
	attribute65			varchar2(240)	:= fnd_api.g_miss_char,
	attribute66			varchar2(240)	:= fnd_api.g_miss_char,
	attribute67			varchar2(240)	:= fnd_api.g_miss_char,
	attribute68			varchar2(240)	:= fnd_api.g_miss_char,
	attribute69			varchar2(240)	:= fnd_api.g_miss_char,
	attribute70			varchar2(240)	:= fnd_api.g_miss_char,
	attribute71			varchar2(240)	:= fnd_api.g_miss_char,
	attribute72			varchar2(240)	:= fnd_api.g_miss_char,
	attribute73			varchar2(240)	:= fnd_api.g_miss_char,
	attribute74			varchar2(240)	:= fnd_api.g_miss_char,
	attribute75			varchar2(240)	:= fnd_api.g_miss_char,
	attribute76			varchar2(240)	:= fnd_api.g_miss_char,
	attribute77			varchar2(240)	:= fnd_api.g_miss_char,
	attribute78			varchar2(240)	:= fnd_api.g_miss_char,
	attribute79			varchar2(240)	:= fnd_api.g_miss_char,
	attribute80			varchar2(240)	:= fnd_api.g_miss_char,
	attribute81			varchar2(240)	:= fnd_api.g_miss_char,
	attribute82			varchar2(240)	:= fnd_api.g_miss_char,
	attribute83			varchar2(240)	:= fnd_api.g_miss_char,
	attribute84			varchar2(240)	:= fnd_api.g_miss_char,
	attribute85			varchar2(240)	:= fnd_api.g_miss_char,
	attribute86			varchar2(240)	:= fnd_api.g_miss_char,
	attribute87			varchar2(240)	:= fnd_api.g_miss_char,
	attribute88			varchar2(240)	:= fnd_api.g_miss_char,
	attribute89			varchar2(240)	:= fnd_api.g_miss_char,
	attribute90			varchar2(240)	:= fnd_api.g_miss_char,
	attribute91			varchar2(240)	:= fnd_api.g_miss_char,
	attribute92			varchar2(240)	:= fnd_api.g_miss_char,
	attribute93			varchar2(240)	:= fnd_api.g_miss_char,
	attribute94			varchar2(240)	:= fnd_api.g_miss_char,
	attribute95			varchar2(240)	:= fnd_api.g_miss_char,
	attribute96			varchar2(240)	:= fnd_api.g_miss_char,
	attribute97			varchar2(240)	:= fnd_api.g_miss_char,
	attribute98			varchar2(240)	:= fnd_api.g_miss_char,
	attribute99			varchar2(240)	:= fnd_api.g_miss_char,
	attribute100			varchar2(240)	:= fnd_api.g_miss_char,
	quota_id                        number 		:= fnd_api.g_miss_num,
	quota_name                      varchar2(80) 	:= fnd_api.g_miss_char,
	revenue_class_id                number 		:= fnd_api.g_miss_num,
	revenue_class_name              varchar2(30) 	:= fnd_api.g_miss_char,
	trx_batch_name                  varchar2(30) 	:= fnd_api.g_miss_char,
	source_trx_number               varchar2(80) 	:= fnd_api.g_miss_char,
	trx_sales_line_id		number		:= fnd_api.g_miss_num,
	trx_line_id			number		:= fnd_api.g_miss_num,
	trx_id				number		:= fnd_api.g_miss_num,
	comm_lines_api_id               number 		:= fnd_api.g_miss_num,
	source_doc_type                 varchar2(80) 	:= fnd_api.g_miss_char,
	upside_amount                   number 		:= fnd_api.g_miss_num,
	upside_quantity                 number 		:= fnd_api.g_miss_num,
	uom_code                        varchar2(3) 	:= fnd_api.g_miss_char,
	forecast_id                     number 		:= fnd_api.g_miss_num,
	program_id                      number 		:= fnd_api.g_miss_num,
	request_id                      number 		:= fnd_api.g_miss_num,
	program_application_id          number 		:= fnd_api.g_miss_num,
	program_update_date             date 		:= fnd_api.g_miss_date,
	adj_comm_lines_api_id           number 		:= fnd_api.g_miss_num,
	invoice_number			varchar2(20)	:= fnd_api.g_miss_char,
	invoice_date			date		:= fnd_api.g_miss_date,
	order_number			number		:= fnd_api.g_miss_num,
	order_date			date		:= fnd_api.g_miss_date,
	line_number                     number 		:= fnd_api.g_miss_num,
	customer_id                     number 		:= fnd_api.g_miss_num,
	bill_to_address_id		number		:= fnd_api.g_miss_num,
	ship_to_address_id		number		:= fnd_api.g_miss_num,
	bill_to_contact_id		number		:= fnd_api.g_miss_num,
	ship_to_contact_id		number		:= fnd_api.g_miss_num,
	load_status                     varchar2(30) 	:= fnd_api.g_miss_char,
	revenue_type_disp               varchar2(80) 	:= fnd_api.g_miss_char,
	revenue_type                    varchar2(15) 	:= fnd_api.g_miss_char,
	adjust_rollup_flag              varchar2(1) 	:= fnd_api.g_miss_char,
	adjust_date                     date 		:= fnd_api.g_miss_date,
	adjusted_by                     varchar2(100) 	:= fnd_api.g_miss_char,
	adjust_status_disp              varchar2(80) 	:= fnd_api.g_miss_char,
	adjust_status                   varchar2(20) 	:= fnd_api.g_miss_char,
	adjust_comments                 varchar2(2000) 	:= fnd_api.g_miss_char,
	type                            varchar2(80) 	:= fnd_api.g_miss_char,
	pre_processed_code              varchar2(30) 	:= fnd_api.g_miss_char,
	comp_group_id                   number 		:= fnd_api.g_miss_num,
	srp_plan_assign_id              number 		:= fnd_api.g_miss_num,
	role_id                         number 		:= fnd_api.g_miss_num,
	sales_channel                   varchar2(30) 	:= fnd_api.g_miss_char,
	object_version_number		number 		:= fnd_api.g_miss_num,
	split_pct			number 		:= fnd_api.g_miss_num,
	split_status			varchar2(30) 	:= fnd_api.g_miss_char,
	commission_amount		number		:= fnd_api.g_miss_num,
	role_name			varchar2(60)	:= fnd_api.g_miss_char,
	comp_group_name			varchar2(60)	:= fnd_api.g_miss_char,
	pre_processed_code_disp		varchar2(80) 	:= fnd_api.g_miss_char,
	customer_name			varchar2(50)	:= fnd_api.g_miss_char,
	customer_number			varchar2(30)	:= fnd_api.g_miss_char,
	inventory_item_id               number          := fnd_api.g_miss_num,
	source_trx_id			number          := fnd_api.g_miss_num,
	source_trx_line_id		number          := fnd_api.g_miss_num,
	source_trx_sales_line_id	number          := fnd_api.g_miss_num,
	org_id 				number		:= fnd_api.g_miss_num,
    terr_id             number      := fnd_api.g_miss_num,
    preserve_credit_override_flag varchar2(1) := fnd_api.g_miss_char,
    terr_name           varchar2(2000)        := fnd_api.g_miss_char);

  TYPE adj_tbl_type IS
     TABLE OF adj_rec_type INDEX BY BINARY_INTEGER ;
--
TYPE tx_core_data_rec IS RECORD(
   salesrep_id			NUMBER(15),
   employee_number		VARCHAR2(30),
   salesrep_name		VARCHAR2(360),
   processed_date		DATE,
   processed_period_id		NUMBER(15),
   comm_lines_api_id		NUMBER(15),
   commission_header_id		NUMBER,
   load_status			VARCHAR2(30),
   adjust_status		VARCHAR2(20),
   revenue_type			VARCHAR2(15),
   order_number			NUMBER,
   order_date			DATE,
   invoice_number		VARCHAR2(20),
   invoice_date			DATE,
   transaction_amount		NUMBER);
--
TYPE tx_adj_data_tbl IS TABLE OF tx_core_data_rec
INDEX BY BINARY_INTEGER;
--
TYPE split_data_rec IS RECORD(
	salesrep_id		NUMBER(15),
	salesrep_number		VARCHAR2(30),
	revenue_type		VARCHAR2(15),
	split_pct		NUMBER,
	split_amount		NUMBER);
--
TYPE split_data_tbl IS TABLE OF split_data_rec
INDEX BY BINARY_INTEGER;
--
TYPE trx_line_rec IS RECORD(
   commission_line_id		NUMBER(15),
   commission_header_id		NUMBER(15),
   credited_salesrep_id		NUMBER(15),
   credited_salesrep_name	VARCHAR2(360), -- For Rosetta Purpose
   credited_salesrep_number	VARCHAR2(30),  -- For Rosetta Purpose
   processed_period_id    	NUMBER(15),
   processed_date		DATE,
   plan_element			VARCHAR2(80),
   payment_uplift		NUMBER,
   quota_uplift			NUMBER,
   commission_amount		NUMBER,
   commission_rate		NUMBER,  -- Changed From NUMBER(10,5) To number
                                    	 -- Bug Fix : 3560705 Hitesh M Thanki
   created_during		VARCHAR2(30),
   pay_period			VARCHAR2(30),
   accumulation_period		VARCHAR2(30),
   perf_achieved		NUMBER,
   posting_status		VARCHAR2(30),
   pending_status		VARCHAR2(30),
   trx_status			VARCHAR2(80),
   payee			VARCHAR2(360));
--
TYPE trx_line_tbl IS TABLE OF trx_line_rec
INDEX BY BINARY_INTEGER;
--
TYPE cust_info_rec IS RECORD(
   customer_id			NUMBER(15),
   customer_number		VARCHAR2(30),
   customer_name		VARCHAR2(255),
   bill_to_address_id		NUMBER,
   bill_to_address1		VARCHAR2(240),
   bill_to_address2		VARCHAR2(240),
   bill_to_address3		VARCHAR2(240),
   bill_to_address4		VARCHAR2(240),
   bill_to_city			VARCHAR2(60),
   bill_to_postal_code		VARCHAR2(60),
   bill_to_state		VARCHAR2(60),
   ship_to_address_id		NUMBER,
   ship_to_address1		VARCHAR2(240),
   ship_to_address2		VARCHAR2(240),
   ship_to_address3		VARCHAR2(240),
   ship_to_address4		VARCHAR2(240),
   ship_to_city			VARCHAR2(60),
   ship_to_postal_code		VARCHAR2(60),
   ship_to_state		VARCHAR2(60),
   bill_to_contact_id		NUMBER,
   bill_to_contact		VARCHAR2(301),
   ship_to_contact_id		NUMBER,
   ship_to_contact		VARCHAR2(301));
--
TYPE cust_info_tbl IS
TABLE OF cust_info_rec INDEX BY BINARY_INTEGER ;
--
TYPE attribute_rec IS RECORD(
   attribute_name		VARCHAR2(60),
   attribute_value		VARCHAR2(60));
--
TYPE attribute_tbl IS TABLE OF attribute_rec
INDEX BY BINARY_INTEGER;
--
   /*--------------------------------------------------------------------------
     API name	: get_api_data
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: This api get the record information either from the
                  cn_commission_headers or cn_comm_lines_api table based on
		  the api_id given as input parameter.
     Parameters
     IN		: p_comm_lines_api_id - To fetch the record based on this ID.
     OUT NOCOPY 	: x_adj_tbl - This PL/SQL table holds the resultset based
                  on the p_comm_lines_api_id.
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE get_api_data(
	p_comm_lines_api_id	IN	NUMBER,
	x_adj_tbl        OUT NOCOPY     adj_tbl_type);
   /*--------------------------------------------------------------------------
     API name	: get_adj
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: Get the transaction details based on the search criteria
                  given.
     Parameters
     IN		: p_salesrep_id - From the transaction summary search page.
       		: p_pr_date_to - From the transaction summary search page.
		: p_pr_date_from - From the transaction summary search page.
		: p_calc_status - From the transaction summary search page.
		: p_order_num - From the transaction summary search page.
		: p_srch_attr_rec - This record type stores the attribute
		                    columns from the advanced search option.
		: p_first - For the page navigation
		: p_last - For the page navigation
     OUT NOCOPY 	: x_adj_tbl - This PL/SQL table holds the resultset based
                  on the search criteria given.
   	        : x_adj_count - This will give the total number of records
		  of the resultset.
     Notes	: This API is used to get the transactions information based
                  on the search criteria given in the cntxsum.jsp.
   --------------------------------------------------------------------------*/
   PROCEDURE get_adj (
   	p_api_version            IN        NUMBER,
   	p_init_msg_list          IN        VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level       IN        VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_org_id	         IN        NUMBER 	:= FND_API.G_MISS_NUM,
   	p_salesrep_id            IN        NUMBER 	:= FND_API.G_MISS_NUM,
   	p_pr_date_to             IN        DATE 	:= FND_API.G_MISS_DATE,
   	p_pr_date_from           IN        DATE		:= FND_API.G_MISS_DATE,
   	p_calc_status            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
        p_adj_status            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
        p_load_status            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
   	p_invoice_num            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
   	p_order_num              IN        NUMBER	:= FND_API.G_MISS_NUM,
	p_srch_attr_rec          IN        adj_rec_type,
	p_first			 IN    	   NUMBER,
   	p_last                   IN        NUMBER,
   	x_return_status          OUT NOCOPY       VARCHAR2,
   	x_msg_count              OUT NOCOPY       NUMBER,
   	x_msg_data               OUT NOCOPY       VARCHAR2,
   	x_loading_status         OUT NOCOPY       VARCHAR2,
   	x_adj_tbl                OUT NOCOPY       adj_tbl_type,
   	x_adj_count   		 OUT NOCOPY       NUMBER,
        x_valid_trx_count        OUT NOCOPY       NUMBER);
   PROCEDURE get_split_data(
   	p_api_version   	IN	NUMBER,
     	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
     	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
     	p_comm_lines_api_id     IN      NUMBER 		DEFAULT NULL,
	p_load_status		IN	VARCHAR2        DEFAULT NULL,
	x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
     	x_loading_status        OUT NOCOPY     VARCHAR2,
	x_adj_tbl               OUT NOCOPY     adj_tbl_type,
     	x_adj_count             OUT NOCOPY     NUMBER);
   /*--------------------------------------------------------------------------
     API name	: insert_api_record
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: This API is being called from Insert Transaction Screen
                  (cnnewtx.jsp) to create a new record in the API table. It is
		  also being called from other APIs of Adjustment Module.
     Parameters
     IN		: p_newtx_rec - This PL/SQL record hold the transaction data
                  to be inserted.
     OUT NOCOPY 	: x_api_id - comm_lines_api_id assigned for the above data.
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE insert_api_record(
   	p_api_version   	IN	NUMBER,
     	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
     	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_action             	IN	VARCHAR2	DEFAULT NULL,
	p_newtx_rec           	IN     	adj_rec_type,
	x_api_id	 OUT NOCOPY NUMBER,
	x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
     	x_loading_status        OUT NOCOPY     VARCHAR2);
   /*--------------------------------------------------------------------------
     API name	: call_mass_update
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: This API is being called from Move Credits Screen
                  (cnmvcr.jsp) to move the resultset to a different salesrep.
     Parameters
     IN		: p_salesrep_id - From the transaction summary search page.
       		: p_pr_date_to - From the transaction summary search page.
		: p_pr_date_from - From the transaction summary search page.
		: p_calc_status - From the transaction summary search page.
		: p_order_num - From the transaction summary search page.
		: p_srch_attr_rec - This record type stores the attribute
		                    columns from the advanced search option.
		: p_mass_adj_type - Obsoleted Functionality.
		: p_adj_rec - PL/SQL record to customize the target records.
     OUT NOCOPY 	:
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE call_mass_update (
   	p_api_version            IN        NUMBER,
   	p_init_msg_list          IN        VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level       IN        VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_org_id                 IN        NUMBER 	:= FND_API.G_MISS_NUM,
   	p_salesrep_id            IN        NUMBER 	:= FND_API.G_MISS_NUM,
   	p_pr_date_to             IN        DATE 	:= FND_API.G_MISS_DATE,
   	p_pr_date_from           IN        DATE		:= FND_API.G_MISS_DATE,
   	p_calc_status            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
        p_adj_status             IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
        p_load_status            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
   	p_invoice_num            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
   	p_order_num              IN        NUMBER	:= FND_API.G_MISS_NUM,
	p_srch_attr_rec		 IN        adj_rec_type,
	p_mass_adj_type          IN	   VARCHAR2	DEFAULT NULL,
	p_adj_rec           	 IN        adj_rec_type,
   	x_return_status          OUT NOCOPY       VARCHAR2,
   	x_msg_count              OUT NOCOPY       NUMBER,
   	x_msg_data               OUT NOCOPY       VARCHAR2,
   	x_loading_status         OUT NOCOPY       VARCHAR2);
   /*--------------------------------------------------------------------------
     API name	: call_deal_assign
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: Obsoleted Functionality (Deal Move has been removed)
     Parameters
     IN		:
     OUT NOCOPY 	:
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE call_deal_assign(
	p_api_version           IN      NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_from_salesrep_id	IN	NUMBER		:= FND_API.G_MISS_NUM,
	p_to_salesrep_id   	IN	NUMBER		:= FND_API.G_MISS_NUM,
	p_invoice_number	IN	VARCHAR2	:= FND_API.G_MISS_CHAR,
	p_order_number		IN	NUMBER  	:= FND_API.G_MISS_NUM,
	p_adjusted_by		IN	VARCHAR2	:= FND_GLOBAL.USER_NAME,
        p_adjust_comments	IN	VARCHAR2	:= FND_API.G_MISS_CHAR,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2);
   /*--------------------------------------------------------------------------
     API name	: call_split
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: This API is being called from Split/Deal Split JSP.
     Parameters
     IN		: p_split_type - Tells Deal Split or Transaction Split
                : p_comm_lines_api_id - Used for the Transaction Split
		: p_invoice_number - Used for the Deal Split
		: p_order_number - Used for the Deal Split
		: p_transaction_amount - Not Used.
		: p_adjusted_by	- Login User
                : p_adjust_comments - Adjustment Comments.
		: p_split_data_tbl - This PL/SQL table holds the split
		  transaction information.
     OUT NOCOPY 	:
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE call_split(
	p_api_version           IN      NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_split_type		IN	VARCHAR2,
	p_from_salesrep_id	IN	NUMBER		:= FND_API.G_MISS_NUM,
        p_split_data_tbl	IN	split_data_tbl,
	p_comm_lines_api_id	IN	NUMBER		:= FND_API.G_MISS_NUM,
	p_invoice_number	IN	VARCHAR2	:= FND_API.G_MISS_CHAR,
	p_order_number		IN	NUMBER  	:= FND_API.G_MISS_NUM,
	p_transaction_amount	IN	NUMBER,
	p_adjusted_by		IN	VARCHAR2	:= FND_GLOBAL.USER_NAME,
        p_adjust_comments	IN	VARCHAR2	:= FND_API.G_MISS_CHAR,
        p_org_id 		IN	NUMBER 		:= FND_API.G_MISS_NUM,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2);
   /*--------------------------------------------------------------------------
     API name	: get_trx_lines
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: This API is being called from Update Transaction JSP. In the
                  Update Transaction JSP, when user selects Transaction Lines
		  from the dropdown box, this API populate the transaction
		  lines data.
     Parameters
     IN		: p_header_id - To populate the data from cn_commission_lines
                  this ID is needed.
     OUT NOCOPY 	: x_trx_line_tbl - This PL/SQL table holds the transaction
		  line information.
		  x_tbl_count - Record Count
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE get_trx_lines(
   	p_api_version            IN        NUMBER,
   	p_init_msg_list          IN        VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level       IN        VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
   	p_header_id              IN        NUMBER	:= FND_API.G_MISS_NUM,
   	x_return_status          OUT NOCOPY       VARCHAR2,
   	x_msg_count              OUT NOCOPY       NUMBER,
   	x_msg_data               OUT NOCOPY       VARCHAR2,
   	x_loading_status         OUT NOCOPY       VARCHAR2,
   	x_trx_line_tbl           OUT NOCOPY       trx_line_tbl,
   	x_tbl_count              OUT NOCOPY       NUMBER);
   /*--------------------------------------------------------------------------
     API name	: get_trx_history
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: This API is being called from Update Transaction JSP. In the
                  Update Transaction JSP, when user selects Transaction Hisotry
		  from the dropdown box, this API populate the transaction
		  history data.
     Parameters
     IN		: p_adj_comm_lines_api_id - To populate the data from API and
                  header tables this ID is being used.
     OUT NOCOPY 	: x_adj_tbl - This PL/SQL table holds the transaction history
		  information.
		  x_tbl_count - Record Count
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE get_trx_history(
   	p_api_version            IN        NUMBER,
   	p_init_msg_list          IN        VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level       IN        VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
   	p_adj_comm_lines_api_id  IN        NUMBER	:= FND_API.G_MISS_NUM,
   	x_return_status          OUT NOCOPY       VARCHAR2,
   	x_msg_count              OUT NOCOPY       NUMBER,
   	x_msg_data               OUT NOCOPY       VARCHAR2,
   	x_loading_status         OUT NOCOPY       VARCHAR2,
   	x_adj_tbl                OUT NOCOPY       adj_tbl_type,
   	x_adj_count              OUT NOCOPY       NUMBER);
   /*--------------------------------------------------------------------------
     API name	: get_cust_info
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: This API is being called from Update Transaction JSP. In the
                  Update Transaction JSP, when user selects Customer Address
		  from the dropdown box, this API populate the Customer
		  Address Information
     Parameters
     IN		: p_comm_lines_api_id - To populate the data from API and
                  header tables this ID is being used.
     OUT NOCOPY 	: x_cust_info_rec - This PL/SQL record holds the Customer
		  information.
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE get_cust_info(
   	p_api_version           IN      NUMBER,
   	p_init_msg_list         IN      VARCHAR2 := FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
   	p_comm_lines_api_id	IN	NUMBER,
	p_load_status		IN	VARCHAR2,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2,
	x_cust_info_rec	 OUT NOCOPY     cust_info_rec);
   /*--------------------------------------------------------------------------
     API name	: update_api_record
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: This API is being called from Update Transaction JSP to
                  update a transaction based on the changes made by the user.
     Parameters
     IN		: p_newtx_rec - This PL/SQL record holds the data needed to
                  create a new transaction in the cn_comm_lines_api table.
     OUT NOCOPY 	: x_api_id - comm_lines_api_id assigned for the above data.
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE update_api_record(
		p_api_version   		IN	NUMBER,
		p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
		p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
		p_newtx_rec           	IN     	adj_rec_type,
		x_api_id	 			OUT NOCOPY NUMBER,
		x_return_status         OUT NOCOPY     VARCHAR2,
		x_msg_count             OUT NOCOPY     NUMBER,
		x_msg_data              OUT NOCOPY     VARCHAR2,
		x_loading_status        OUT NOCOPY     VARCHAR2);
   /*--------------------------------------------------------------------------
     API name	: call_load
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: This API is a wrapper for cn_transaction_load_pub package and
                  it is being called from Load Transactions JSP.
     Parameters
     IN		: p_salesrep_id - From the Load Transactions page.
       		: p_pr_date_to - From the Load Transactions page.
		: p_pr_date_from - From the Load Transactions page.
		: p_cls_rol_flag - Classification Rollup Flag.
		: p_load_method - Concurrent/Online
     OUT NOCOPY 	: x_process_audit_id - Status of the LOAD program.
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE call_load(
   	p_api_version   	IN	NUMBER,
     	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
	p_commit	        IN      VARCHAR2 	:= FND_API.G_FALSE,
     	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
   	p_salesrep_id           IN      NUMBER 		:= FND_API.G_MISS_NUM,
	p_pr_date_from          IN      DATE,
   	p_pr_date_to            IN      DATE,
	p_cls_rol_flag		IN	CHAR,
	p_load_method		IN	VARCHAR2,
        p_org_id		IN	NUMBER,
	x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
     	x_loading_status        OUT NOCOPY     VARCHAR2,
	x_process_audit_id      OUT NOCOPY     NUMBER);
   --
END cn_get_tx_data_pub;

 

/
