--------------------------------------------------------
--  DDL for Package JAI_AR_GLDIST_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_GLDIST_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ar_gldist_t.pls 120.0 2005/11/10 13:32:01 brathod noship $ */

  t_rec  RA_CUST_TRX_LINE_GL_DIST_ALL%rowtype ;

  PROCEDURE BRI_T1 ( pr_old t_rec%type
                   , pr_new t_rec%type
                   , pv_action varchar2
                   , pv_return_code out nocopy varchar2
                   , pv_return_message out nocopy varchar2
                   ) ;

END JAI_AR_GLDIST_TRIGGER_PKG ;
 

/
