--------------------------------------------------------
--  DDL for Package Body JL_AR_AUTOINV_MASTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_AR_AUTOINV_MASTER_PKG" as
/* $Header: jlarramb.pls 120.5.12010000.2 2008/12/15 18:44:40 vspuli ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE submit_request (
  errbuf                      OUT NOCOPY varchar2,
  retcode                     OUT NOCOPY number,
  p_num_of_instances          IN varchar2 ,
  p_organization              in varchar2, -- Bug#7642995
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
  p_due_date_adj_days         IN number ) IS

  X_req_id    NUMBER(38);
  call_status BOOLEAN;
  rphase      VARCHAR2(30);
  rstatus     VARCHAR2(30);
  dphase      VARCHAR2(30);
  dstatus     VARCHAR2(30);
  message     VARCHAR2(240);
  l_org_id    NUMBER := null;

  BEGIN

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('submit_request: ' || 'JL Submitting Autoinvoice');
       END IF;
       -- Bug#7642995 Start
       if p_organization <> '-99' then
       FND_REQUEST.SET_ORG_ID(p_organization);
       end if;
      -- Bug#7642995 End

       X_req_id := FND_REQUEST.SUBMIT_REQUEST(
			  'AR' ,
			  'RAXMTR',
			  'Autoinvoice Master Program',
			  SYSDATE ,
                          FALSE,
			  p_num_of_instances,
			  p_organization, -- Bug#7642995
  			  p_batch_source_id   ,
			  p_batch_source_name   ,
			  p_default_date   ,
			  p_trans_flexfield   ,
			  p_trans_type   ,
			  p_low_bill_to_cust_num   ,
			  p_high_bill_to_cust_num   ,
			  p_low_bill_to_cust_name  ,
			  p_high_bill_to_cust_name  ,
			  p_low_gl_date  ,
  			  p_high_gl_date  ,
			  p_low_ship_date  ,
			  p_high_ship_date  ,
			  p_low_trans_number  ,
			  p_high_trans_number  ,
			  p_low_sales_order_num  ,
			  p_high_sales_order_num  ,
			  p_low_invoice_date  ,
			  p_high_invoice_date  ,
			  p_low_ship_to_cust_num  ,
  			  p_high_ship_to_cust_num  ,
			  p_low_ship_to_cust_name  ,
			  p_high_ship_to_cust_name  ,
			  p_base_due_date_on_trx_date  ,
			  p_due_date_adj_days);

  END SUBMIT_REQUEST;

END JL_AR_AUTOINV_MASTER_PKG;

/
