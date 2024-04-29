--------------------------------------------------------
--  DDL for Package JAI_CMN_RGM_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RGM_PROCESSING_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rgm_prc.pls 120.4.12010000.2 2010/04/16 21:26:44 haoyang ship $ */

  /*----------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for FILENAME: jai_rgm_trx_processing_pkg_s.sql
  S.No  dd/mm/yyyy   Author and Details
  ------------------------------------------------------------------------------------------------------------------------------
  1     26/07/2004   Vijay Shankar for Bug# 4068823, Version:115.0

                Package that Starts Service Tax Processing of both AP and AR transactions based on the inputs
                provided through request of "India - Service Tax Processing" concurrent
  2     12/04/2005    Brathod, for Bug# 4286646, Version 115.1
                Issue :-
      Because of change in Valueset from JA_IN_DATE to FND_STANDARD_DATE Concurrent was resulting
      in error because JA_IN_DATE uses normal date format while FND_STANDARD_DATE uses NLS_DATE format
      and it is passed as character value.
    Fix :-
      Procedure signature modified to convert p_trx_from_date, p_trx_from_date from date to
      pv_trx_from_date, pv_trx_from_date varchar2.
  DEPENDANCY:
  -----------
  IN60106  + 4068823

3.    08-Jun-2005  Version 116.1 jai_cmn_rgm_prc -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
       as required for CASE COMPLAINCE.

4.    05-Jul-2006  Aiyer for the bug 5369250, Version  120.3
                 Issue:-
                 --------
                   The concurrent failes with the following error :-
                   "FDPSTP failed due to ORA-01861: literal does not match format string ORA-06512: at line 1 "

                 Reason:-
                ---------
                   The procedure PROCESS had a parameters p_override_invoice_date of type date , however the concurrent program
                   passes it in the canonical format and hence the failure.

                 Fix:-
                -----------
                  Modified the procedure process.
                  Changed the datatype of p_override_invoice_date from date to varchar2 as this parameter.
                  Also added the new parameter ld_override_invoice_date . The value in p_override_invoice_date would be converted to date format and
                  stored in the local variable ld_override_invoice_date.

                 Dependency due to this fix:-
                  None

5.     02-Apr-2010  Allen Yang for bug bug 9485355 (12.1.3 non-shippable Enhancement)
                    added a cursor variable MainRec_Cur and two parameters for procedure 'process'.
  ----------------------------------------------------------------------------------------------------------------------------*/

  g_debug   VARCHAR2(1); --File.Sql.35 by Brathod
  gv_called_from_dflt CONSTANT VARCHAR2(10) := 'Batch';  -- File.Sql.35 by Brathod

  -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
  TYPE MainRecord IS RECORD (delivery_id          JAI_RGM_INVOICE_GEN_T.delivery_id%TYPE
                          , delivery_date        JAI_RGM_INVOICE_GEN_T.delivery_date%TYPE
                          , organization_id      JAI_RGM_INVOICE_GEN_T.organization_id%TYPE
                          , location_id          JAI_RGM_INVOICE_GEN_T.location_id%TYPE
                          , vat_invoice_no       JAI_RGM_INVOICE_GEN_T.vat_invoice_no%TYPE
                          , party_id             JAI_RGM_INVOICE_GEN_T.party_id%TYPE
                          , party_site_id        JAI_RGM_INVOICE_GEN_T.party_site_id%TYPE
                          , party_type           JAI_RGM_INVOICE_GEN_T.party_type%TYPE
                          , vat_inv_gen_status   JAI_RGM_INVOICE_GEN_T.vat_inv_gen_status%TYPE
                          , vat_acct_status      JAI_RGM_INVOICE_GEN_T.vat_acct_status%TYPE
                          , order_line_id        JAI_RGM_INVOICE_GEN_T.order_line_id%TYPE
                          , order_number          JAI_RGM_INVOICE_GEN_T.order_number%TYPE);

  TYPE MainRec_Cur IS REF CURSOR;
  -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end

  PROCEDURE process_batch(
    errbuf                    OUT NOCOPY VARCHAR2,
    retcode                   OUT NOCOPY VARCHAR2,
    p_regime_id               IN         NUMBER,
    p_rgm_registration_num    IN         VARCHAR2,
    pv_trx_from_date          IN         VARCHAR2,
    pv_trx_till_date          IN         VARCHAR2,
    p_called_from             IN         VARCHAR2,  -- DEFAULT 'Batch' File.Sql.35 by Brathod
    p_debug                   IN         VARCHAR2,  -- DEFAULT 'Y'     File.Sql.35 by Brathod
    p_trace_switch            IN         VARCHAR2,   -- DEFAULT 'N'     File.Sql.35 by Brathod
 p_organization_id          IN         NUMBER default null --Added by kunkumar for bug#6066813
 );

  PROCEDURE process_payments(
    p_regime_id               IN         NUMBER,
    p_organization_type       IN         VARCHAR2,
    p_trx_from_date           IN         DATE,
    p_trx_to_date             IN         DATE,
    p_org_id                  IN         NUMBER,
    p_batch_id                IN         NUMBER,
    p_debug                   IN         VARCHAR2,
    p_process_flag            OUT NOCOPY VARCHAR2,
    p_process_message         OUT NOCOPY VARCHAR2,
   p_organization_id          IN         NUMBER default null --Added by kunkumar for bug#6066813
  );

  PROCEDURE insert_request_details(
    p_batch_id OUT NOCOPY NUMBER,
    p_regime_id               IN  NUMBER,
    p_rgm_registration_num    IN  VARCHAR2,
    p_trx_from_date           IN  DATE,
    p_trx_till_date           IN  DATE
  );

  FUNCTION get_item_line_id(
    p_invoice_id              IN  NUMBER,
    p_po_distribution_id      IN  NUMBER,
    p_rcv_transaction_id      IN  NUMBER
  ) RETURN NUMBER;

/*
CREATED BY       : ssumaith
CREATED DATE     : 15-MAR-2005
ENHANCEMENT BUG  : 4245053
PURPOSE          : wrapper program to interpret the input parameters and suitably call program to
                   generate vat imvoice number and pass accounting during shipment
CALLED FROM      : Concurrent program JAIVATP
*/
  PROCEDURE process (
                     retcode OUT NOCOPY VARCHAR2,
                     errbuf OUT NOCOPY VARCHAR2,
                     p_regime_id                     JAI_RGM_DEFINITIONS.REGIME_ID%TYPE,
                     p_registration_num              JAI_RGM_TRX_RECORDS.REGIME_PRIMARY_REGNO%TYPE,
                     p_organization_id               JAI_OM_WSH_LINES_ALL.ORGANIZATION_ID%TYPE,
                     p_location_id                   JAI_OM_WSH_LINES_ALL.LOCATION_ID%TYPE,
                     -- added by Allen Yang  for bug 9485355 (12.1.3 non-shippable Enhancement), begin
                     p_order_number_from            OE_ORDER_HEADERS_ALL.ORDER_NUMBER%TYPE,
                     p_order_number_to              OE_ORDER_HEADERS_ALL.ORDER_NUMBER%TYPE,
                     -- added by Allen Yang  for bug 9485355 (12.1.3 non-shippable Enhancement), end
                     p_delivery_id_from              JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE,
                     p_delivery_id_to                JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE,
                     pv_delivery_date_from            VARCHAR2, --DATE, Harshita for Bug 4918870
                     pv_delivery_date_to              VARCHAR2, --DATE, Harshita for Bug 4918870
                     p_process_action                VARCHAR2,
                     p_single_invoice_num            VARCHAR2,
                     p_override_invoice_date         VARCHAR2    , /* aiyer for the bug 5369250 */
                     p_debug                         VARCHAR2
                    );


END jai_cmn_rgm_processing_pkg;

/
