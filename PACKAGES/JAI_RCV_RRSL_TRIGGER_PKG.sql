--------------------------------------------------------
--  DDL for Package JAI_RCV_RRSL_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_RRSL_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_rrsl_t.pls 120.0 2005/09/01 12:27:34 rallamse noship $ */

  t_rec  RCV_RECEIVING_SUB_LEDGER%rowtype ;

  PROCEDURE ARIU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) ;

END JAI_RCV_RRSL_TRIGGER_PKG ;
 

/
