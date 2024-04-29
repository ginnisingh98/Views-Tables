--------------------------------------------------------
--  DDL for Package JAI_AP_TDS_CANCELLATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_TDS_CANCELLATION_PKG" 
/* $Header: jai_ap_tds_can.pls 120.1 2005/07/20 12:54:43 avallabh ship $ */
AUTHID CURRENT_USER AS
/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_tds_cancellation_pkg_s.sql

 Created By    : Aparajita

 Created Date  : 06-mar-2005

 Bug           :

 Purpose       : Implementation of Cancellation  functionality for TDS.

 Called from   : Trigger ja_in_ap_aia_after_trg
                 Trigger ja_in_ap_aida_after_trg

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
 1.        03/03/2005   Aparajita for bug#4088186. version#115.0. TDS Clean Up.

                        Created this package for implementing the TDS Calcellation
                        functionality onto AP invoice.

2         08-Jun-2005  Version 116.1 jai_ap_tds_can -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

---------------------------------------------------------------------------- */

 procedure process_invoice
  (
    errbuf                               out    nocopy     varchar2,
    retcode                              out    nocopy     varchar2,
    p_invoice_id                         in                number
  );

END jai_ap_tds_cancellation_pkg;
 

/
