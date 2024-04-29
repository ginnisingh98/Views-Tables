--------------------------------------------------------
--  DDL for Package JAI_OPM_GMD_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_OPM_GMD_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_opm_gmd_t.pls 120.0 2005/09/02 09:02:10 rallamse noship $ */

  t_rec  GME_MATERIAL_DETAILS%rowtype ;

  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_OPM_GMD_TRIGGER_PKG ;
 

/
