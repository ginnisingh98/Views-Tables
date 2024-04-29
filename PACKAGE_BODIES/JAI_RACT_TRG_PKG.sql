--------------------------------------------------------
--  DDL for Package Body JAI_RACT_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RACT_TRG_PKG" as
/* $Header: jai_ract_trg.plb 120.0 2006/03/27 13:56:07 hjujjuru noship $ */

  procedure incomplete_invoice
            (   r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
            )
  IS
  BEGIN
    null ;
  END ;

  procedure redefault_taxes
            (   r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pn_row_id   in         rowid
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
            )
  IS
  BEGIN
    null ;
  END ;

  procedure create_header
            (   r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pn_row_id   in         rowid
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
            )
  IS
  BEGIN
    null ;
  END ;

  procedure sync_ar_trx_num_upd
           (    r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pn_row_id   in         rowid
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
            )
  IS
  BEGIN
    null ;
  END ;

  procedure validate_rg_balances
           (    r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pn_row_id   in         rowid
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
           )
  IS
  BEGIN
    null ;
  END ;

  procedure vat_invoice_generation
          (     r_new       in         ra_customer_trx_all%rowtype
            ,   r_old       in         ra_customer_trx_all%rowtype
            ,   pv_action   in         varchar2
            ,   pv_err_msg OUT NOCOPY varchar2
            ,   pv_err_flg OUT NOCOPY varchar2
          )
  IS
  BEGIN
    null ;
  END ;

  procedure copy_invoice
          (  r_new       in    ra_customer_trx_all%rowtype
           , pv_action   in    varchar2
           , pv_err_msg OUT NOCOPY varchar2
           , pv_err_flg OUT NOCOPY varchar2
          )
  IS
  BEGIN
    null ;
  END ;

  procedure generate_tax_invoice
            (  r_new       in    ra_customer_trx_all%rowtype
            ,  pv_action   in    varchar2
            ,  pv_err_msg OUT NOCOPY varchar2
            ,  pv_err_flg OUT NOCOPY varchar2
            )
  IS
  BEGIN
    null ;
  END ;

end jai_ract_trg_pkg;

/
