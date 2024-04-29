--------------------------------------------------------
--  DDL for Package JAI_RCV_DELIVER_RTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_DELIVER_RTR_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_del_rtr.pls 120.1 2005/07/20 12:59:03 avallabh ship $ */

  cenvat_costed_flag    CONSTANT VARCHAR2(30) := 'CENVAT_COSTED_FLAG';

  CURSOR c_base_trx(cp_transaction_id IN NUMBER) IS
  SELECT  source_document_code, -- attribute_category, attribute5 rma_type, Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.
            quantity, unit_of_measure, source_doc_unit_of_measure, source_doc_quantity
  from    rcv_transactions
  where   transaction_id = cp_transaction_id;

 /* Procedure Declaration sections */
  PROCEDURE process_transaction
  (
      p_transaction_id                IN       NUMBER,
      p_simulate                      IN       VARCHAR2, --File.Sql.35 Cbabu   DEFAULT 'N',
      p_codepath                      IN OUT NOCOPY VARCHAR2,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      -- Vijay Shankar for Bug#4068823. RECEIPTS DELUG
      p_process_special_source        IN       VARCHAR2  DEFAULT NULL,
      p_process_special_amount        IN       NUMBER    DEFAULT NULL
  );


  PROCEDURE deliver_rtr_reco_nonexcise
  (
      p_transaction_id               IN        NUMBER,
      p_transaction_date             IN        DATE,
      p_organization_id              IN        NUMBER,
      p_transaction_type             IN        VARCHAR2,
      p_parent_transaction_type      IN        VARCHAR2,
      p_receipt_num                  IN        VARCHAR2,
      p_shipment_line_id             IN        NUMBER,
      p_currency_conversion_rate     IN        NUMBER,
      p_apportion_factor             IN        NUMBER,
      p_receiving_account_id         IN        NUMBER,
      p_accounting_type              IN        VARCHAR2,
      p_simulate                     IN        VARCHAR2,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                     IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_tax_amount_breakup
  (
      p_shipment_line_id             IN        NUMBER,
      p_transaction_id               IN        NUMBER,
      p_curr_conv_rate               IN        NUMBER,
      p_excise_amount OUT NOCOPY NUMBER,
      p_non_modvat_amount OUT NOCOPY NUMBER,
      p_other_modvat_amount OUT NOCOPY NUMBER,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                     IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE opm_costing
  (
      p_transaction_id               IN        NUMBER,
      p_transaction_date             IN        DATE,
      p_organization_id              IN        NUMBER,
      p_costing_amount               IN        NUMBER,
      p_receiving_account_id         IN        NUMBER,
      p_rcv_unit_of_measure          IN        VARCHAR2, /*Indicates UOM of RECEIVE Line */
      p_rcv_source_unit_of_measure   IN        VARCHAR2, /*Indicates Source UOM of RECEIVE Line */
      p_rcv_quantity                 IN        NUMBER,   /*Indicates Quantity of RECEIVE Line */
      p_source_doc_quantity          IN        NUMBER,   /*Indicates Source doc Quantity of RECEIVE Line */
      p_source_document_code         IN        VARCHAR2,
      p_po_distribution_id           IN        NUMBER,
      p_subinventory_code            IN        VARCHAR2,
      p_simulate                     IN        VARCHAR2,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                     IN OUT NOCOPY VARCHAR2,
      p_process_special_source       IN        VARCHAR2,
      p_currency_conversion_rate      IN      NUMBER    /* added by Vijay Shankar for Bug#4229164 */
 );

  PROCEDURE expense_accounting
  (
     p_transaction_id            IN            NUMBER,
     p_transaction_date          IN            DATE,
     p_organization_id           IN            NUMBER,
     p_transaction_type          IN            VARCHAR2,
     p_parent_transaction_type   IN            VARCHAR2,
     p_receipt_num               IN            VARCHAR2,
     p_shipment_line_id          IN            NUMBER,
     p_subinventory_code         IN            VARCHAR2,
     p_accounted_amount          IN            NUMBER,
     p_receiving_account_id      IN            NUMBER,
     p_source_document_code      IN            VARCHAR2,
     p_po_distribution_id        IN            NUMBER,
     p_po_line_location_id       IN            NUMBER,
     p_inventory_item_id         IN            NUMBER,
     p_accounting_type           IN            VARCHAR2,
     p_simulate                  IN            VARCHAR2,
     p_process_message OUT NOCOPY VARCHAR2,
     p_process_status OUT NOCOPY VARCHAR2,
     p_codepath                  IN OUT NOCOPY VARCHAR2,
     p_process_special_source    IN            VARCHAR2
 );

  PROCEDURE average_costing
  (
      p_transaction_id            IN            NUMBER,
      p_transaction_date          IN            DATE,
      p_organization_id           IN            NUMBER,
      p_parent_transaction_type   IN            VARCHAR2,
      p_transaction_type          IN            VARCHAR2,
      p_subinventory_code         IN            VARCHAR2,
      p_costing_amount            IN            NUMBER,
      p_receiving_account_id      IN            NUMBER,
      p_source_document_code      IN            VARCHAR2,
      p_po_distribution_id        IN            NUMBER,
      p_unit_of_measure           IN            VARCHAR2,
      p_inventory_item_id         IN            NUMBER,
      p_accounting_type           IN            VARCHAR2,
      p_simulate                  IN            VARCHAR2,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                  IN OUT NOCOPY VARCHAR2,
      p_process_special_source    IN            VARCHAR2
  );

  PROCEDURE standard_costing
  (
      p_transaction_id            IN            NUMBER,
      p_transaction_date          IN            DATE,
      p_organization_id           IN            NUMBER,
      p_parent_transaction_type   IN            VARCHAR2,
      p_transaction_type          IN            VARCHAR2,
      p_costing_amount            IN            NUMBER,
      p_receiving_account_id      IN            NUMBER,
      p_accounting_type           IN            VARCHAR2,
      p_simulate                  IN            VARCHAR2,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                  IN OUT NOCOPY VARCHAR2,
      p_process_special_source    IN            VARCHAR2
  );

  FUNCTION receiving_account
  (
      p_organization_id           IN             NUMBER,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                  IN OUT NOCOPY VARCHAR2
  )
  RETURN NUMBER;

  FUNCTION expense_account
  (
     p_transaction_id             IN             NUMBER,
     p_organization_id            IN             NUMBER,
     p_subinventory_code          IN             VARCHAR2,
     p_po_distribution_id         IN             NUMBER,
     p_po_line_location_id        IN             NUMBER,
     p_item_id                    IN             NUMBER,
     p_process_message OUT NOCOPY VARCHAR2,
     p_process_status OUT NOCOPY VARCHAR2,
     p_codepath                   IN OUT NOCOPY VARCHAR2
  )
  RETURN NUMBER;

  FUNCTION ppv_account
  (
      p_organization_id           IN             NUMBER,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                  IN OUT NOCOPY VARCHAR2
  )
  RETURN NUMBER;

  FUNCTION material_account
  (
      p_organization_id           IN             NUMBER,
      p_source_document_code      IN             VARCHAR2,
      p_po_distribution_id        IN             NUMBER,
      p_subinventory              IN             VARCHAR2,
      p_process_message OUT NOCOPY VARCHAR2,
      p_process_status OUT NOCOPY VARCHAR2,
      p_codepath                  IN OUT NOCOPY VARCHAR2
  )
  RETURN NUMBER;

  FUNCTION include_cenvat_in_costing
  (
     p_transaction_id             IN             NUMBER,
     p_process_message OUT NOCOPY VARCHAR2,
     p_process_status OUT NOCOPY VARCHAR2,
     p_codepath                   IN OUT NOCOPY VARCHAR2
  )
  RETURN VARCHAR2;

END jai_rcv_deliver_rtr_pkg;
 

/
