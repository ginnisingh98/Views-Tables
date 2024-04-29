--------------------------------------------------------
--  DDL for Package JL_AR_AUTOINV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AR_AUTOINV_PKG" AUTHID CURRENT_USER as
/* $Header: jlarrans.pls 120.2.12010000.2 2009/08/13 14:18:09 rsaini ship $ */

PROCEDURE submit_request (
  errbuf                      OUT NOCOPY varchar2,
  retcode                     OUT NOCOPY number,
  p_parallel_module_name      IN varchar2 ,
  p_running_mode              IN varchar2 ,
  p_batch_source_id           IN ra_batch_sources.batch_source_id%TYPE,
  p_batch_source_name         IN varchar2  ,
  p_default_date              IN varchar2  ,
  p_trans_flexfield           IN varchar2  ,
  p_trans_type                IN ra_cust_trx_types.name%TYPE  ,
  p_low_bill_to_cust_num      IN hz_cust_accounts.account_number%TYPE  ,
  p_high_bill_to_cust_num     IN hz_cust_accounts.account_number%TYPE ,
  p_low_bill_to_cust_name     IN hz_parties.party_name%TYPE ,
  p_high_bill_to_cust_name    IN hz_parties.party_name%TYPE  ,
  p_low_gl_date               IN VARCHAR2 ,
  p_high_gl_date              IN VARCHAR2 ,
  p_low_ship_date             IN VARCHAR2 ,
  p_high_ship_date            IN VARCHAR2,
  p_low_trans_number          IN ra_interface_lines.trx_number%TYPE,
  p_high_trans_number         IN ra_interface_lines.trx_number%TYPE ,
  p_low_sales_order_num       IN ra_interface_lines.sales_order%TYPE ,
  p_high_sales_order_num      IN ra_interface_lines.sales_order%TYPE,
  p_low_invoice_date          IN VARCHAR2 ,
  p_high_invoice_date         IN VARCHAR2 ,
  p_low_ship_to_cust_num      IN hz_cust_accounts.account_number%TYPE ,
  p_high_ship_to_cust_num     IN hz_cust_accounts.account_number%TYPE ,
  p_low_ship_to_cust_name     IN hz_parties.party_name%TYPE ,
  p_high_ship_to_cust_name    IN hz_parties.party_name%TYPE,
  p_call_from_master_flag     IN varchar2 ,
  p_base_due_date_on_trx_date IN fnd_lookups.meaning%TYPE ,
  p_due_date_adj_days         IN number );

  PROCEDURE UPDATE_BATCH_SOURCE(p_invoice_date_from IN DATE,
                                p_invoice_date_to   IN DATE,
                                p_gl_date_from      IN DATE,
                                p_gl_date_to        IN DATE,
                                p_ship_date_from    IN DATE,
                                p_ship_date_to      IN DATE,
                                p_default_date      IN DATE);

  PROCEDURE JL_AR_AR_UPDATE_BATCH_SOURCE(
  errbuf                      OUT NOCOPY varchar2,
  retcode                     OUT NOCOPY number,
  p_low_gl_date               IN VARCHAR2 ,
  p_high_gl_date              IN VARCHAR2 ,
  p_low_ship_date             IN VARCHAR2 ,
  p_high_ship_date            IN VARCHAR2,
  p_low_invoice_date          IN VARCHAR2 ,
  p_high_invoice_date         IN VARCHAR2,
  p_default_date              IN VARCHAR2) ;
END JL_AR_AUTOINV_PKG;

/
