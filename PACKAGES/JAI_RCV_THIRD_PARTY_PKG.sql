--------------------------------------------------------
--  DDL for Package JAI_RCV_THIRD_PARTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_THIRD_PARTY_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_3p_prc.pls 120.3 2006/03/27 14:24:54 hjujjuru ship $ */
/* --------------------------------------------------------------------------------------
Filename: jai_rcv_third_party_pkg_s.sql

Change History:

slno  Date         Bug         Remarks
----  ---------    ----------  -------------------------------------------------------------

1.    14/04/2005   4284505     sumaith - file version 115.1

                               Code added for service tax support for 3rd party taxes in a receipt.

                               In the package spec , a procedure -populate_tp_invoice_id has been added
                               which updates the invoice id in the jai_rcv_tp_invoices table.

                               This patch creates dependency by addition of a new table - jai_rcv_tp_inv_Details
                               and addition of new column (invoice_id) in the table jai_Rcv_tp_invoices table.

2. 08-Jun-2005  Version 116.1 jai_rcv_3p_prc -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.


Dependency Section
========== =======

Date         Bug          Remarks
---------    ----------   -------------------------------------------------------------
17-oct-04    Bug#3940741  This is a part of correction ER, done in phases. This obsoletes
                          the third party code in the old receiving, namely the procedures,
                          Ja_In_Con_Ap_Req and ja_in_receipt_ap_interface.

                          Here procedure Process_pending_receipts is attached to the concurrent
                          for generating third party invoices and it calls the procedure
                          process_receipt for each pending shipment_header_id.

13-Aug-2005              rchandan for bug#4551623. File version 120.2.
                         Changed the order of parameters of process_batch and added a default NULL to p_simulation.


----------------------------------------------------------------------------------------- */
/*  */


  procedure process_batch
  (
    errbuf                                    out nocopy varchar2,
    retcode                                   out nocopy varchar2,
    p_batch_name                              in         varchar2,
    /* Bug 5096787. Added by LGOPALSA
       Added parameter p_org_id */
    p_org_id                                 in          number,
    p_simulation                              in         varchar2 default null,
    p_debug                                   in         number    default 1
  );

  procedure process_receipt
  (
    p_batch_id                                in         number,
    p_shipment_header_id                      in         number,
    p_process_flag                            out nocopy varchar2,
    p_process_message                         out nocopy varchar2,
    p_debug                                   in         number    default 1,
    p_simulation                              in         varchar2
  );

  procedure populate_tp_invoice_id
  (
  p_invoice_id                                in         ap_invoices_all.invoice_id%TYPE,
  p_invoice_num                               in         ap_invoices_all.invoice_num%TYPE,
  p_vendor_id                                 in         ap_invoices_all.vendor_id%TYPE,
  p_vendor_site_id                            in         ap_invoices_all.vendor_site_id%TYPE,
  p_process_flag                              out nocopy VARCHAR2,
  p_process_message                           out nocopy VARCHAR2
  );

end jai_rcv_third_party_pkg;
 

/
