--------------------------------------------------------
--  DDL for Package JAI_JAR_TL_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_JAR_TL_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_jar_tl_t.pls 120.1 2007/02/26 17:27:05 sacsethi ship $ */

  t_rec  JAI_AR_TRX_LINES%rowtype ;

  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_JAR_TL_TRIGGER_PKG ;

/
