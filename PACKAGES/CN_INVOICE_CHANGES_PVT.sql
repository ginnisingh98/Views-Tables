--------------------------------------------------------
--  DDL for Package CN_INVOICE_CHANGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_INVOICE_CHANGES_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvinvs.pls 120.2 2005/08/10 03:48:02 hithanki noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+

--
-- Package Name
--   cn_get_tx_data_pub
-- Purpose
--   Package Specification for Sun Enhancements (JSP Version)
-- History
--   08/07/01   Rao.Chenna         Created
   --
   TYPE invoice_rec IS RECORD(
      invoice_change_id		number(15),
      salesrep_id               number(15),
      invoice_number            varchar2(20),
      line_number               number,
      revenue_type              varchar2(15),
      split_pct                 number,
      direct_salesrep_number	varchar2(30),
      comm_lines_api_id		number(15),
      attribute_category        varchar2(30),
      attribute1                varchar2(150),
      attribute2                varchar2(150),
      attribute3                varchar2(150),
      attribute4                varchar2(150),
      attribute5                varchar2(150),
      attribute6                varchar2(150),
      attribute7                varchar2(150),
      attribute8                varchar2(150),
      attribute9                varchar2(150),
      attribute10               varchar2(150),
      attribute11               varchar2(150),
      attribute12               varchar2(150),
      attribute13               varchar2(150),
      attribute14               varchar2(150),
      attribute15               varchar2(150),
      creation_date             date,
      created_by                number(15),
      last_update_date          date,
      last_updated_by           number(15),
      last_update_login         number(15),
      object_version_number     number,
      org_id                    number(15));
   --
   TYPE invoice_tbl IS
   TABLE OF invoice_rec
   INDEX BY BINARY_INTEGER ;
   --
   TYPE deal_data_rec IS RECORD(
      comm_lines_api_id		number(15),
      invoice_number            varchar2(20),
      line_number               number);
   --
   TYPE deal_data_tbl IS
   TABLE OF deal_data_rec
   INDEX BY BINARY_INTEGER ;
   /*--------------------------------------------------------------------------
     API name	: convert_adj_to_api
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: most of the code for this module is based on cn_adjustment_v
                  view and adj_rec_type is a record corresponding to this view.
		  So we have to convert this record type to table handler
		  record type before we call the table handler.
     Parameters
     IN		: p_adj_rec - PL/SQL record corresponding to cn_adjustment_v
     OUT NOCOPY 	: x_api_rec - PL/SQL record corresponding to cn_comm_lines_api
                  table
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE convert_adj_to_api(
	p_adj_rec	IN	cn_get_tx_data_pub.adj_rec_type,
	x_api_rec OUT NOCOPY cn_comm_lines_api_pkg.comm_lines_api_rec_type);
   /*--------------------------------------------------------------------------
     API name	: prepare_api_record
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: In this module, so many places we have to compare the
                  transaction's old data with new data from the JSPs. Where
		  ever new data is not available, we have to take the data from
		  the old record. This API will do this task.
     Parameters
     IN		: p_newtx_rec - PL/SQL record corresponding to new data coming
                  from JSP
     		: p_old_adj_tbl - PL/SQL table contain old information.
     OUT NOCOPY 	: x_final_trx_rec - PL/SQL record filled with old and new data.
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE prepare_api_record(
	p_newtx_rec		IN	cn_get_tx_data_pub.adj_rec_type,
	p_old_adj_tbl		IN	cn_get_tx_data_pub.adj_tbl_type,
	x_final_trx_rec	 OUT NOCOPY cn_get_tx_data_pub.adj_rec_type,
	x_return_status	 OUT NOCOPY VARCHAR2);
   /*--------------------------------------------------------------------------
     API name	: update_invoice_changes
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: Sun Enhancements. This API is being used to create and delete
                  the records from cn_invoice_changes table that will track the
		  invoice transactions. Where ever we use this API, we have to
		  use twice. First to delete the records from cn_invoice_changes
		  table. After creating new records in cn_comm_lines_api table
		  call this API again to create records with new API_IDs
     Parameters
     IN		: p_existing_data - PL/SQL table correspond to data-to-be-deleted
                  from cn_invoice_changes table.
     		: p_new_data - PL/SQL table correspond to data-to-be-created
                  in cn_invoice_changes table.
		: p_exist_data_check - Used for first call
		: p_new_data_check - Used for the second call
     OUT NOCOPY 	:
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE update_invoice_changes(
      	p_api_version  		IN 	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 := FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
   	p_existing_data		IN	invoice_tbl,
	p_new_data		IN	invoice_tbl,
	p_exist_data_check	IN	VARCHAR2	DEFAULT NULL,
	p_new_data_check	IN	VARCHAR2	DEFAULT NULL,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2);
   /*--------------------------------------------------------------------------
     API name	: update_credit_memo
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: Sun Enhancements. This API is being used to delete existing
                  credit memos and payments and recreate with new split %s.
     Parameters
     IN		: p_existing_data - PL/SQL table correspond to data-to-be-negated
                  in cn_comm_lines_api and cn_commission_headers tables.
     		: p_new_data - PL/SQL table correspond to data-to-be-created in
                  cn_comm_lines_api and cn_commission_headers tables.
		: p_to_salesrep_id - It is being used when called from Move Credits.
	        : p_to_salesrep_number - It is being used when called from Move
		  Credits
     OUT NOCOPY 	:
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE update_credit_memo(
      	p_api_version  		IN 	NUMBER,
   	p_init_msg_list         IN      VARCHAR2:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2:= FND_API.G_VALID_LEVEL_FULL,
   	p_existing_data		IN	invoice_tbl,
	p_new_data		IN	invoice_tbl,
	p_to_salesrep_id	IN   	NUMBER 	:= FND_API.G_MISS_NUM,
	p_to_salesrep_number	IN   	VARCHAR2:= FND_API.G_MISS_CHAR,
	p_called_from		IN	VARCHAR2,
	p_adjust_status		IN	VARCHAR2,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2);
   /*--------------------------------------------------------------------------
     API name	: update_mass_invoices
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: Sun Enhancements. This API is being to identify the unique
                  invoices based on the search criteria and delete the records
		  from cn_invoice_changes table.
     Parameters
     IN		: p_salesrep_id - From the transaction summary search page.
       		: p_pr_date_to - From the transaction summary search page.
		: p_pr_date_from - From the transaction summary search page.
		: p_calc_status - From the transaction summary search page.
		: p_order_num - From the transaction summary search page.
		: p_srch_attr_rec - This record type stores the attribute
		                    columns from the advanced search option.
     OUT NOCOPY 	:
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE update_mass_invoices (
	p_api_version  		IN 	NUMBER,
   	p_init_msg_list         IN      VARCHAR2:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2:= FND_API.G_VALID_LEVEL_FULL,
   	p_salesrep_id    	IN   	NUMBER 	:= FND_API.G_MISS_NUM,
   	p_pr_date_to      	IN 	DATE 	:= FND_API.G_MISS_DATE,
   	p_pr_date_from    	IN  	DATE	:= FND_API.G_MISS_DATE,
   	p_calc_status  		IN 	VARCHAR2:= FND_API.G_MISS_CHAR,
   	p_invoice_num     	IN  	VARCHAR2:= FND_API.G_MISS_CHAR,
   	p_order_num       	IN 	NUMBER	:= FND_API.G_MISS_NUM,
	p_srch_attr_rec		IN      cn_get_tx_data_pub.adj_rec_type,
   	p_to_salesrep_id	IN   	NUMBER 	:= FND_API.G_MISS_NUM,
	p_to_salesrep_number	IN   	VARCHAR2:= FND_API.G_MISS_CHAR,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2,
	x_existing_data	 OUT NOCOPY invoice_tbl);
   /*--------------------------------------------------------------------------
     API name	: capture_deal_invoice
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: Sun Enhancements. This API is being used to collect the
                  distinct records for a given invoice number from api/header
		  table.
     Parameters
     IN		: p_trx_type - INVOICE/CM/PAYMENT
       		: p_invoice_number - Invoice Number
		: p_split_data_tbl - Split Information from the JSP
		: x_deal_data_tbl - PL/SQL table contain information to create
		  records in cn_comm_lines_api table
     OUT NOCOPY 	:
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE capture_deal_invoice(
	p_api_version  		IN 	NUMBER,
   	p_init_msg_list         IN      VARCHAR2:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2:= FND_API.G_VALID_LEVEL_FULL,
	p_trx_type		IN	VARCHAR2,
        p_split_nonrevenue_line IN	VARCHAR2,				  	       p_invoice_number	        IN	VARCHAR2,
	p_org_id		IN	NUMBER,
        p_split_data_tbl	IN	cn_get_tx_data_pub.split_data_tbl,
	x_deal_data_tbl	 OUT NOCOPY cn_invoice_changes_pvt.deal_data_tbl,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2);
   /*--------------------------------------------------------------------------
     API name	: invoice_split_batch
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: Sun Enhancements. This API should be run after COLLECTIONS.
                  This API collects all new INVOICE transactions information
		  and store them in CN_INVOICE_CHANGES table. Same changes are
		  applied to credit memo(CM) and payments (PMT).
     Parameters
     IN		:
     OUT NOCOPY 	:
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE invoice_split_batch(
	x_errbuf 	 OUT NOCOPY 	VARCHAR2,
        x_retcode 	 OUT NOCOPY 	NUMBER);
   --
END; -- Package spec

 

/
