--------------------------------------------------------
--  DDL for Package CN_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ADJUSTMENTS_PKG" AUTHID CURRENT_USER AS
-- $Header: cntradjs.pls 120.4.12000000.2 2007/08/07 14:36:28 apink ship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   cn_adjustments_pkg
-- Purpose
--   Package spec for notifying orders
-- History
--   11/17/98   JPENDYAL        Created
TYPE TabcommId IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

  tab_mass_update_comm TabcommId;


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
 	split_status			varchar2(30) 	:= fnd_api.g_miss_char);
  TYPE adj_tbl_type IS
     TABLE OF adj_rec_type INDEX BY BINARY_INTEGER ;
--
TYPE cust_info_rec IS RECORD(
   CUSTOMER_ID			NUMBER(15),
   CUSTOMER_NUMBER		VARCHAR2(30),
   CUSTOMER_NAME		VARCHAR2(255),
   BILL_TO_ADDRESS_ID		NUMBER,
   BILL_TO_ADDRESS1		VARCHAR2(240),
   BILL_TO_ADDRESS2		VARCHAR2(240),
   BILL_TO_ADDRESS3		VARCHAR2(240),
   BILL_TO_ADDRESS4		VARCHAR2(240),
   BILL_TO_CITY			VARCHAR2(60),
   BILL_TO_POSTAL_CODE		VARCHAR2(60),
   BILL_TO_STATE		VARCHAR2(60),
   SHIP_TO_ADDRESS_ID		NUMBER,
   SHIP_TO_ADDRESS1		VARCHAR2(240),
   SHIP_TO_ADDRESS2		VARCHAR2(240),
   SHIP_TO_ADDRESS3		VARCHAR2(240),
   SHIP_TO_ADDRESS4		VARCHAR2(240),
   SHIP_TO_CITY			VARCHAR2(60),
   SHIP_TO_POSTAL_CODE		VARCHAR2(60),
   SHIP_TO_STATE		VARCHAR2(60),
   BILL_TO_CONTACT_ID		NUMBER,
   BILL_TO_CONTACT		VARCHAR2(301),
   SHIP_TO_CONTACT_ID		NUMBER,
   SHIP_TO_CONTACT		VARCHAR2(301));
--
TYPE cust_info_tbl IS
TABLE OF cust_info_rec INDEX BY BINARY_INTEGER ;
--


  PROCEDURE mass_adjust_build_query
    ( x_where_clause VARCHAR2
      );

PROCEDURE api_negate_record(
  		x_comm_lines_api_id  	IN	NUMBER,
		x_adjusted_by		IN	VARCHAR2,
                x_adjust_comments    	IN	VARCHAR2,
		x_salesrep_number	IN	VARCHAR2 DEFAULT NULL);
   --
   PROCEDURE mass_update_values(
        x_adj_data                     	cn_get_tx_data_pub.adj_tbl_type,
	x_adj_rec			cn_get_tx_data_pub.adj_rec_type,
        x_mass_adj_type			VARCHAR2,
        x_proc_comp		OUT NOCOPY    VARCHAR2);
   --
   PROCEDURE deal_split(
	x_source_salesrep_id   	NUMBER,
	x_salesrep_id		NUMBER,
	x_split_percent   	NUMBER,
        x_revenue_type		VARCHAR2,
	x_invoice_number	VARCHAR2,
	x_order_number		NUMBER,
	x_adjusted_by		VARCHAR2,
        x_adjust_comments	VARCHAR2);
   --
   PROCEDURE deal_assign(
	x_from_salesrep_id	NUMBER,
	x_to_salesrep_id   	NUMBER,
	x_invoice_number	VARCHAR2,
	x_order_number		NUMBER,
	x_adjusted_by		VARCHAR2,
        x_adjust_comments	VARCHAR2);
   --
   PROCEDURE get_cust_info(
   	p_comm_lines_api_id	IN	NUMBER,
	p_load_status		IN	VARCHAR2,
	x_cust_info_rec		OUT NOCOPY    cust_info_rec);
   --
   /*--------------------------------------------------------------------------
     API name	: update_credit_credentials
     Type	: Public
     Pre-reqs	:
     Usage	:
     Desc 	: This procedure is called to validate the transactions after an update
                depending on whether the transaction is collected or credited.
     Parameters
     IN		: p_comm_lines_api_id
       		: p_terr_id
            : p_org_id
            : p_adjusted_by
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE update_credit_credentials(
   p_comm_lines_api_id IN NUMBER,
   p_terr_id IN NUMBER,
   p_org_id IN NUMBER,
   p_adjusted_by IN VARCHAR2
    );
   --

END cn_adjustments_pkg;


 

/
