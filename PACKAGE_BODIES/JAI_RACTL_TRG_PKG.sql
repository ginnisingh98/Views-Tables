--------------------------------------------------------
--  DDL for Package Body JAI_RACTL_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RACTL_TRG_PKG" 
/* $Header: jai_ractl_trg.plb 120.0 2006/03/27 13:56:23 hjujjuru noship $ */
AS

 procedure default_taxes
             (   r_new         in         ra_customer_trx_lines_all%rowtype
             ,   r_old         in         ra_customer_trx_lines_all%rowtype
             ,   pv_action     in         varchar2
             ,   pv_context    in         varchar2
             ,   pv_err_msg OUT NOCOPY varchar2
             ,   pv_err_flg OUT NOCOPY varchar2
             )
  IS
  BEGIN
    null ;
  END ;


 procedure sync_ar_deletion
       (         r_new         in         ra_customer_trx_lines_all%rowtype
             ,   r_old         in         ra_customer_trx_lines_all%rowtype
             ,   pv_action     in         varchar2
             ,   pv_err_msg OUT NOCOPY varchar2
             ,   pv_err_flg OUT NOCOPY varchar2
       )
  IS
  BEGIN
    null ;
  END ;

 procedure recalculate_taxes
       (   r_new         in         ra_customer_trx_lines_all%rowtype
       ,   r_old         in         ra_customer_trx_lines_all%rowtype
       ,   pv_action     in         varchar2
       ,   pv_context    in         varchar2
       ,   pv_err_msg OUT NOCOPY varchar2
       ,   pv_err_flg OUT NOCOPY varchar2
       )
  IS
  BEGIN
    null ;
  END ;

 procedure default_imp_inv_taxes
          (       r_new         in         ra_customer_trx_lines_all%rowtype
              ,   r_old         in         ra_customer_trx_lines_all%rowtype
              ,   pv_action     in         varchar2
              ,   pv_err_msg OUT NOCOPY varchar2
              ,   pv_err_flg OUT NOCOPY varchar2
          )
  IS
  BEGIN
    null ;
  END ;

 procedure default_imp_cm_taxes
         (       r_new         in         ra_customer_trx_lines_all%rowtype
             ,   r_old         in         ra_customer_trx_lines_all%rowtype
             ,   pv_action     in         varchar2
             ,   pv_err_msg OUT NOCOPY varchar2
             ,   pv_err_flg OUT NOCOPY varchar2
         )
  IS
  BEGIN
    null ;
  END ;

end jai_ractl_trg_pkg;

/
