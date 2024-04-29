--------------------------------------------------------
--  DDL for Package Body JAI_PO_RA_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_RA_TRIGGER_PKG" AS
/* $Header: jai_po_ra_t.plb 120.2 2007/06/01 11:27:28 bgowrava ship $ */

/*
  REM +======================================================================+
  REM NAME          ARU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_PO_RA_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_PO_RA_ARU_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  BEGIN
	NULL;
  END ARU_T1 ;

END JAI_PO_RA_TRIGGER_PKG ;

/
