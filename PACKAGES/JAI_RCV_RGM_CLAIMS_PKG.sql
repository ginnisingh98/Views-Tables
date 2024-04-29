--------------------------------------------------------
--  DDL for Package JAI_RCV_RGM_CLAIMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_RGM_CLAIMS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_rgm_clm.pls 120.4 2007/05/28 10:10:39 sacsethi ship $ */
/****************************************************************************************************************************************************************************************

 Change History -
 1. 27-Jan-2005   Sanjikum for Bug #4248727 Version #115.0
                  New Package created for creating VAT Processing

 2. 04/04/2005   Sanjikum for Bug #4279050 Version #115.1
                 Problem
                 -------
                 In the Procedure update_rcv_lines, For setting the flag lv_process_status_flag, first Partial Claim is checked and then Full Claimed,
                 which is creating the problem in case of full claim happens in the first installment

                 Fix
                 ---
                 1) In the procedure - update_rcv_lines, added one more parameter - p_shipment_header_id

3. 10/05/2005   Vijay Shankar for Bug#4346453. Version: 116.1
                 Code is modified due to the Impact of Receiving Transactions DFF Elimination

              * High Dependancy for future Versions of this object *

4.             08-Jun-2005  Version 116.1 jai_rcv_rgm_clm -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

5	28-05-2007	SACSETHI for bug 6071533 file Version 120.4

			VAT CLAIM ACCOUNTING ENTRY IS NOT GETTING GENERATED FOR RECEIPTS

                        Dependncies - jai_rcv_rgm_clm.pls , jai_rcv_rgm_clm.plb

Future Dependencies For the release Of this Object:-
 (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
  A datamodel change )

============================================================================================================
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Current Version       Current Bug    Dependent           Files                                  Version     Author   Date         Remarks
  Of File                              On Bug/Patchset    Dependent On
  jai_ap_interface_pkg_s.sql
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  115.0                 4248727        4245089                                                                                      This is Part of VAT Enhancement, so dependent on VAT Enhancement
  115.1                 4279050        4279050            jai_rcv_rgm_claims_b.sql                115.3       Sanjikum 07/04/2005
  115.1                 4279050        4279050            ja_in_create_4279050.sql                115.0       Sanjikum 07/04/2005
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
****************************************************************************************************************************************************************************************/

  gv_debug CONSTANT BOOLEAN := TRUE;

  gv_invoice_no_dflt CONSTANT VARCHAR2(5) := '-X9X'; --File.Sql.35 Cbabu
  gd_invoice_date_dflt CONSTANT DATE := to_date('01/01/1900','DD/MM/YYYY');

  CURSOR c_trx(cp_transaction_id IN NUMBER)
  IS
  SELECT  *
  FROM    JAI_RCV_TRANSACTIONS
  WHERE   transaction_id = cp_transaction_id;

  CURSOR c_base_trx(cp_transaction_id IN NUMBER) IS
  SELECT  shipment_header_id,
          shipment_line_id,
          transaction_id,
          transaction_type,
          quantity,
          unit_of_measure,
          uom_code,
          parent_transaction_id,
          organization_id,
          location_id,
          subinventory,
          currency_conversion_rate,
          routing_header_id,
          /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. attribute_category attr_cat,
          nvl(attribute5, 'XX') rma_type,
          nvl(attribute4, 'N') generate_excise_invoice,
          attribute3  online_claim_flag,
          */
          source_document_code,
          po_header_id,
          vendor_id,
          vendor_site_id,
          transaction_date
          --,attribute_category,
          --attribute4
  FROM    rcv_transactions
  WHERE   transaction_id = cp_transaction_id;

  PROCEDURE get_location(
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE,
                p_location_id         OUT NOCOPY  hr_locations_all.location_id%TYPE,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2);

  PROCEDURE generate_schedule(
                p_term_id             IN          jai_rgm_terms.term_id%TYPE DEFAULT NULL,
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE DEFAULT NULL,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE DEFAULT NULL,
                p_tax_type            IN          JAI_CMN_TAXES_ALL.tax_type%TYPE DEFAULT NULL,
                p_tax_id              IN          JAI_CMN_TAXES_ALL.tax_id%TYPE DEFAULT NULL,
                p_override            IN          VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'N',
                p_process_status      OUT         NOCOPY  VARCHAR2,
                p_process_message     OUT         NOCOPY  VARCHAR2,
                /*Bug 5096787. Added by Lakshmi Gopalsami  */
                p_simulate_flag       IN          VARCHAR2 DEFAULT 'N'  -- Date 28/05/2007 sacsethi for bug 6071533 Change default value from null to N
                );

  PROCEDURE insert_rcv_lines(
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE,
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE,
                p_regime_code         IN          JAI_RGM_DEFINITIONS.regime_code%TYPE,
                p_simulate_flag       IN          VARCHAR2, --File.Sql.35 Cbabu   DEFAULT 'N',
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2);

  PROCEDURE update_rcv_lines(
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_receipt_num         IN          JAI_RCV_LINES.receipt_num%TYPE DEFAULT NULL,
                p_recoverable_amount  IN          jai_rcv_rgm_lines.recoverable_amount%TYPE DEFAULT NULL,
                p_recovered_amount    IN          jai_rcv_rgm_lines.recovered_amount%TYPE DEFAULT NULL,
                p_term_id             IN          jai_rgm_terms.term_id%TYPE DEFAULT -999,
                p_invoice_no          IN          JAI_RCV_TRANSACTIONS.vat_invoice_no%TYPE, --File.Sql.35 Cbabu  DEFAULT '-X9X',
                p_invoice_date        IN          JAI_RCV_TRANSACTIONS.vat_invoice_date%TYPE, --File.Sql.35 Cbabu  DEFAULT TO_DATE('01/01/1900','DD/MM/YYYY'),
                p_vendor_id           IN          po_vendors.vendor_id%TYPE DEFAULT -999,
                p_vendor_site_id      IN          po_vendor_sites_all.vendor_site_id%TYPE DEFAULT NULL,
                p_correct_receive_qty IN          jai_rcv_rgm_lines.correct_receive_qty%TYPE DEFAULT NULL,
                p_rtv_qty             IN          jai_rcv_rgm_lines.rtv_qty%TYPE DEFAULT NULL,
                p_correct_rtv_qty     IN          jai_rcv_rgm_lines.correct_rtv_qty%TYPE DEFAULT NULL,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2);

  PROCEDURE process_vat(
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2);


  PROCEDURE process_claim(
                p_regime_id           IN          JAI_RGM_DEFINITIONS.regime_id%TYPE,
                p_regime_regno        IN          VARCHAR2 DEFAULT NULL,
                p_organization_id     IN          hr_all_organization_units.organization_id%TYPE DEFAULT NULL,
                p_location_id         IN          hr_locations_all.location_id%TYPE DEFAULT NULL,
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE DEFAULT NULL,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_batch_id            IN          jai_rcv_rgm_lines.batch_num%TYPE DEFAULT NULL,
                p_force               IN          VARCHAR2 DEFAULT NULL,
                p_invoice_no          IN          JAI_RCV_TRANSACTIONS.vat_invoice_no%TYPE,
                p_invoice_date        IN          JAI_RCV_TRANSACTIONS.vat_invoice_date%TYPE,
                p_called_from         IN          VARCHAR2,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2);


  PROCEDURE process_no_claim(
                p_shipment_header_id  IN           rcv_shipment_headers.shipment_header_id%TYPE DEFAULT NULL,
                p_shipment_line_id    IN           rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_batch_id            IN           jai_rcv_rgm_lines.batch_num%TYPE DEFAULT NULL,
                p_regime_regno        IN           VARCHAR2 DEFAULT NULL,
                p_organization_id     IN           hr_all_organization_units.organization_id%TYPE DEFAULT NULL,
                p_location_id         IN           hr_locations_all.location_id%TYPE DEFAULT NULL,
                p_process_status      OUT NOCOPY   VARCHAR2,
                p_process_message     OUT NOCOPY   VARCHAR2,
                /* Bug 5096787. Added by Lakshmi Gopalsami */
                p_regime_id           IN           JAI_RGM_DEFINITIONS.regime_id%TYPE DEFAULT NULL );

  PROCEDURE process_batch(
                errbuf                OUT NOCOPY  VARCHAR2,
                retcode               OUT NOCOPY  VARCHAR2,
                p_regime_id           IN          JAI_RGM_DEFINITIONS.regime_id%TYPE,
                p_regime_regno        IN          VARCHAR2 DEFAULT NULL,
                p_organization_id     IN          hr_all_organization_units.organization_id%TYPE DEFAULT NULL,
                p_location_id         IN          hr_locations_all.location_id%TYPE DEFAULT NULL,
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE DEFAULT NULL,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_batch_id            IN          jai_rcv_rgm_lines.batch_num%TYPE DEFAULT NULL,
                p_force               IN          VARCHAR2 DEFAULT NULL,
                p_commit_switch       IN          VARCHAR2,
                p_invoice_no          IN          JAI_RCV_TRANSACTIONS.vat_invoice_no%TYPE,
                pv_invoice_date        IN          VARCHAR2,  /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
                p_called_from         IN          VARCHAR2);

  PROCEDURE do_rtv_accounting(
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE,
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE,
                p_called_from         IN          VARCHAR2,
                p_invoice_no          IN          JAI_RCV_TRANSACTIONS.vat_invoice_no%TYPE,
                p_invoice_date        IN          JAI_RCV_TRANSACTIONS.vat_invoice_date%TYPE,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2);

  PROCEDURE do_rma_accounting(
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2);

END jai_rcv_rgm_claims_pkg;

/
