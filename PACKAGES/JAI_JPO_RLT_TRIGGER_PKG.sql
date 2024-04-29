--------------------------------------------------------
--  DDL for Package JAI_JPO_RLT_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_JPO_RLT_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_jpo_rlt_t.pls 120.0 2005/09/01 12:26:22 rallamse noship $ */

  t_rec  JAI_PO_REQ_LINE_TAXES%rowtype ;

  PROCEDURE BRU_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_JPO_RLT_TRIGGER_PKG ;
 

/
