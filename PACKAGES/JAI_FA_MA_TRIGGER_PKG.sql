--------------------------------------------------------
--  DDL for Package JAI_FA_MA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_FA_MA_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_fa_ma_t.pls 120.0 2005/09/01 12:25:42 rallamse noship $ */

  t_rec  FA_MASS_ADDITIONS%rowtype ;

  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE BRI_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_FA_MA_TRIGGER_PKG ;
 

/
