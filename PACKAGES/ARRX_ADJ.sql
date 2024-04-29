--------------------------------------------------------
--  DDL for Package ARRX_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_ADJ" AUTHID CURRENT_USER as
/* $Header: ARRXADJS.pls 120.6 2005/12/14 04:39:58 salladi ship $  */

procedure aradj_rep (
   request_id                 in   number,
   p_reporting_level          in   number,
   p_reporting_entity         in   number,
   p_sob_id                   in   number,
   p_coa_id		      in   number,
   p_co_seg_low               in   varchar2,
   p_co_seg_high              in   varchar2,
   p_gl_date_low              in   date,
   p_gl_date_high             in   date,
   p_currency_code_low        in   varchar2,
   p_currency_code_high       in   varchar2,
   p_trx_date_low             in   date,
   p_trx_date_high            in   date,
   p_due_date_low             in   date,
   p_due_date_high            in   date,
   p_invoice_type_low         in   varchar2,
   p_invoice_type_high        in   varchar2,
   p_adj_type_low             in   varchar2,
   p_adj_type_high            in   varchar2,
   p_doc_seq_name	      in   varchar2,
   p_doc_seq_low	      in   number,
   p_doc_seq_high	      in   number,
   retcode                    out NOCOPY  number,
   errbuf                     out NOCOPY  varchar2);

procedure aradj_before_report;
procedure aradj_bind(c in integer);
procedure aradj_after_fetch;

-- eliminate reporting details from ar_distributions table
function dist_details(
   adj_id in NUMBER,
   coa_id in NUMBER,
   rep_id in NUMBER,
   ret_type in VARCHAR2)
RETURN NUMBER;

function dist_ccid(
   adj_id in NUMBER,
   coa_id in NUMBER,
   rep_id in NUMBER)
RETURN NUMBER;

type var_t is record (
			request_id                 		number,
                        p_reporting_level                       VARCHAR2(30),
                        p_reporting_entity_id                   NUMBER,
                        p_sob_id                                NUMBER,
			p_coa_id			        number,
   			p_currency_code_low          		varchar2(15),
   			p_currency_code_high         		varchar2(15),
   			p_invoice_type_low           		varchar2(50),
   			p_invoice_type_high          		varchar2(50),
   			p_trx_date_low               		date,
   			p_trx_date_high              		date,
   			p_due_date_low               		date,
   			p_due_date_high              		date,
   			p_co_seg_low                 		varchar2(30),
   			p_co_seg_high                		varchar2(30),
   			p_adj_acct_low             		varchar2(240),
   			p_adj_acct_high				varchar2(240),
   			p_adj_type_low               		varchar2(30),
   			p_adj_type_high              		varchar2(30),
   			p_gl_date_low                		date,
   			p_gl_date_high				date,
			p_doc_seq_name				varchar2(30),
   			p_doc_seq_low				number,
   			p_doc_seq_high				number,
			organization_name                       varchar2(50),
		 	functional_currency_code                varchar2(15),
 			postable                                varchar2(15),
 			adj_currency_code                       varchar2(15),
 			cons                                    varchar2(15),
 			sortby                                  varchar2(30),
 			adj_type                                varchar2(30),
 			trx_number                              varchar2(36),--bug4612433
 			due_date                                date,
 			gl_date                                 date,
 			adj_number                              varchar2(20),
 			adj_class                               varchar2(30),
 			adj_type_code                           varchar2(30),
 			adj_type_meaning                        varchar2(30),
			adj_name				varchar2(30),
			adj_amount				number,
 			customer_name                           varchar2(50),
 			customer_number                         varchar2(30),
			customer_id				number,
 			trx_date                                date,
 			acctd_adj_amount                        number,
			books_id				number,
			chart_of_accounts_id			number,
			org_name				varchar2(50),
			currency_code				varchar2(20),
			d_or_i					varchar2(6),
			account_code_combination_id		varchar(240),
			debit_account				varchar(240),
			debit_account_desc			varchar(240),
  			debit_balancing   			varchar(240),
   			debit_balancing_desc			varchar(240),
   			debit_natacct		      		varchar(240),
   			debit_natacct_desc			varchar(240),
			doc_seq_value				number,
			doc_seq_name				varchar(30)
			);

var var_t;



END ARRX_ADJ;

 

/
