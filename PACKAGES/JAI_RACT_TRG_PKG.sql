--------------------------------------------------------
--  DDL for Package JAI_RACT_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RACT_TRG_PKG" AUTHID CURRENT_USER as
/* $Header: jai_ract_trg.pls 120.0 2006/03/27 13:55:59 hjujjuru noship $ */

  procedure incomplete_invoice
            (   r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
            ) ;

  procedure redefault_taxes
            (   r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pn_row_id   in         rowid
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
            ) ;

  procedure create_header
            (   r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pn_row_id   in         rowid
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
            ) ;
  procedure sync_ar_trx_num_upd
           (    r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pn_row_id   in         rowid
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
            ) ;

  procedure validate_rg_balances
           (    r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pn_row_id   in         rowid
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
           ) ;

  procedure vat_invoice_generation
          (     r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
          ) ;

  procedure copy_invoice
          (  r_new       in    ra_customer_trx_all%rowtype
           , pv_action   in    varchar2
           , pv_err_msg OUT NOCOPY varchar2
           , pv_err_flg OUT NOCOPY varchar2
          ) ;

  procedure generate_tax_invoice
            (  r_new       in    ra_customer_trx_all%rowtype
            ,  pv_action   in    varchar2
            ,  pv_err_msg OUT NOCOPY varchar2
            ,  pv_err_flg OUT NOCOPY varchar2
            ) ;

end jai_ract_trg_pkg;
 

/
