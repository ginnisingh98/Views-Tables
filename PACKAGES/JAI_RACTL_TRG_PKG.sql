--------------------------------------------------------
--  DDL for Package JAI_RACTL_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RACTL_TRG_PKG" AUTHID CURRENT_USER as
/* $Header: jai_ractl_trg.pls 120.0 2006/03/27 13:56:15 hjujjuru noship $ */

 procedure default_taxes
             (   r_new         in         ra_customer_trx_lines_all%rowtype
             ,   r_old         in         ra_customer_trx_lines_all%rowtype
             ,   pv_action     in         varchar2
             ,   pv_context    in         varchar2
             ,   pv_err_msg OUT NOCOPY varchar2
             ,   pv_err_flg OUT NOCOPY varchar2
             ) ;

 procedure sync_ar_deletion
       (         r_new         in         ra_customer_trx_lines_all%rowtype
             ,   r_old         in         ra_customer_trx_lines_all%rowtype
             ,   pv_action     in         varchar2
             ,   pv_err_msg OUT NOCOPY varchar2
             ,   pv_err_flg OUT NOCOPY varchar2
       );

 procedure recalculate_taxes
       (   r_new         in         ra_customer_trx_lines_all%rowtype
       ,   r_old         in         ra_customer_trx_lines_all%rowtype
       ,   pv_action     in         varchar2
       ,   pv_context    in         varchar2
       ,   pv_err_msg OUT NOCOPY varchar2
       ,   pv_err_flg OUT NOCOPY varchar2
       ) ;

 procedure default_imp_inv_taxes
          (       r_new         in         ra_customer_trx_lines_all%rowtype
              ,   r_old         in         ra_customer_trx_lines_all%rowtype
              ,   pv_action     in         varchar2
              ,   pv_err_msg OUT NOCOPY varchar2
              ,   pv_err_flg OUT NOCOPY varchar2
          );

 procedure default_imp_cm_taxes
         (       r_new         in         ra_customer_trx_lines_all%rowtype
             ,   r_old         in         ra_customer_trx_lines_all%rowtype
             ,   pv_action     in         varchar2
             ,   pv_err_msg OUT NOCOPY varchar2
             ,   pv_err_flg OUT NOCOPY varchar2
         );

end jai_ractl_trg_pkg;
 

/
