--------------------------------------------------------
--  DDL for Package JL_AR_AUTOINV_MASTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AR_AUTOINV_MASTER_PKG" AUTHID CURRENT_USER as
/* $Header: jlarrams.pls 120.3.12010000.2 2008/12/15 18:44:03 vspuli ship $ */

PROCEDURE submit_request (
  errbuf                      OUT NOCOPY varchar2,
  retcode                     OUT NOCOPY number,
  p_num_of_instances          IN varchar2 ,
  p_organization              in varchar2,
  p_batch_source_id           IN ra_batch_sources.batch_source_id%TYPE,
  p_batch_source_name         IN varchar2  ,
  p_default_date              IN varchar2  ,
  p_trans_flexfield           IN varchar2  ,
  p_trans_type                IN ra_cust_trx_types.name%TYPE  ,
  p_low_bill_to_cust_num      IN hz_cust_accounts.account_number%TYPE  ,
  p_high_bill_to_cust_num     IN hz_cust_accounts.account_number%TYPE ,
  p_low_bill_to_cust_name     IN hz_parties.party_name%TYPE ,
  p_high_bill_to_cust_name    IN hz_parties.party_name%TYPE  ,
  p_low_gl_date               IN VARCHAR2,
  p_high_gl_date              IN VARCHAR2,
  p_low_ship_date             IN VARCHAR2,
  p_high_ship_date            IN VARCHAR2,
  p_low_trans_number          IN ra_interface_lines.trx_number%TYPE,
  p_high_trans_number         IN ra_interface_lines.trx_number%TYPE ,
  p_low_sales_order_num       IN ra_interface_lines.sales_order%TYPE ,
  p_high_sales_order_num      IN ra_interface_lines.sales_order%TYPE,
  p_low_invoice_date          IN VARCHAR2,
  p_high_invoice_date         IN VARCHAR2,
  p_low_ship_to_cust_num      IN hz_cust_accounts.account_number%TYPE ,
  p_high_ship_to_cust_num     IN hz_cust_accounts.account_number%TYPE ,
  p_low_ship_to_cust_name     IN hz_parties.party_name%TYPE ,
  p_high_ship_to_cust_name    IN hz_parties.party_name%TYPE,
  p_base_due_date_on_trx_date IN fnd_lookups.meaning%TYPE ,
  p_due_date_adj_days         IN number );

END JL_AR_AUTOINV_MASTER_PKG;

/
