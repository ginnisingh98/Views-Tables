--------------------------------------------------------
--  DDL for Package CN_MASS_ADJUST_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_MASS_ADJUST_UTIL" AUTHID CURRENT_USER AS
-- $Header: cnvmutls.pls 120.3 2005/08/10 03:48:38 hithanki noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+

--
-- Package Name
--   CN_MASS_ADJUST_UTIL
-- Purpose
--   Package Body for Mass Adjustments Package (JSP Version)
-- History
--   08/27/01   Rao.Chenna         Created
   /*
   PROCEDURE my_debug(
      i_value		IN	VARCHAR2); */
   /*--------------------------------------------------------------------------
     API name	: find_functional_amount
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: This API converts foreign currency to functional currency
                  and vice versa.
     Parameters
     IN		: p_from_currency - Source Currency Code.
       		: p_to_currency - Target Currency Code.
		: p_conversion_date - Conversion Date
		: p_conversion_type - Conversion Type
		: p_from_amount - Source Transaction Amount
     OUT NOCOPY 	: x_to_amount - Target Transaction Amount
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE  find_functional_amount(
   	p_from_currency		IN 	VARCHAR2,
   	p_to_currency		IN	VARCHAR2,
   	p_conversion_date	IN	DATE,
   	p_conversion_type	IN 	VARCHAR2 := fnd_profile.value('CN_CONVERSION_TYPE'),
   	p_from_amount		IN	NUMBER,
   	x_to_amount	 OUT NOCOPY NUMBER,
   	x_return_status       OUT NOCOPY     VARCHAR2);
   /*--------------------------------------------------------------------------
     API name	: search_result
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: This API provides the list of transactions match with the
                  search criteria.
     Parameters
     IN		: p_salesrep_id - From the transaction summary search page.
       		: p_pr_date_to - From the transaction summary search page.
		: p_pr_date_from - From the transaction summary search page.
		: p_calc_status - From the transaction summary search page.
		: p_order_num - From the transaction summary search page.
		: p_srch_attr_rec - This record type stores the attribute
		                    columns from the advanced search option.
     OUT NOCOPY 	: x_adj_tbl - This PL/SQL table holds the resultset based
                  on the search criteria given.
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE search_result (
   	p_salesrep_id    	IN   	NUMBER 	:= FND_API.G_MISS_NUM,
   	p_pr_date_to      	IN 	DATE 	:= FND_API.G_MISS_DATE,
   	p_pr_date_from    	IN  	DATE	:= FND_API.G_MISS_DATE,
   	p_calc_status  		IN 	VARCHAR2:= FND_API.G_MISS_CHAR,
        p_adj_status  		IN 	VARCHAR2:= FND_API.G_MISS_CHAR,
        p_load_status  		IN 	VARCHAR2:= FND_API.G_MISS_CHAR,
   	p_invoice_num     	IN  	VARCHAR2:= FND_API.G_MISS_CHAR,
   	p_order_num       	IN 	NUMBER	:= FND_API.G_MISS_NUM,
	p_org_id		IN	NUMBER 	:= FND_API.G_MISS_NUM,
   	p_srch_attr_rec      	IN      cn_get_tx_data_pub.adj_rec_type,
   	x_return_status     OUT NOCOPY  	VARCHAR2,
   	x_adj_tbl           OUT NOCOPY  	cn_get_tx_data_pub.adj_tbl_type,
   	x_source_counter    OUT NOCOPY 	NUMBER);
   /*--------------------------------------------------------------------------
     API name	: convert_rec_to_tbl
     Type	: Private
     Pre-reqs	:
     Usage	:
     Desc 	: Currently attribute column values from the Advanced Search
                  JSP are stored in a PL/SQL record type. But it is very
		  difficult to add dynamically these attributes columns in the
		  search criteria. So this API converts the record type to
		  PL/SQL table type. Check the search_result body about how
		  this PL/SQL table is being used.
     Parameters
     IN		: p_srch_attr_rec - A PL/SQL record which holds attribute column
                  values
     OUT NOCOPY 	: x_attribute_tbl - A PL/SQL table which holds the same
		  attribute column values
     Notes	:
   --------------------------------------------------------------------------*/
   PROCEDURE convert_rec_to_tbl(
   	p_srch_attr_rec      	IN      cn_get_tx_data_pub.adj_rec_type,
   	x_attribute_tbl	 OUT NOCOPY cn_get_tx_data_pub.attribute_tbl);

   PROCEDURE convert_rec_to_gmiss(
   	p_rec      	IN      cn_get_tx_data_pub.adj_rec_type,
   	x_api_rec	    OUT NOCOPY cn_get_tx_data_pub.adj_rec_type);

   --
END;

 

/
