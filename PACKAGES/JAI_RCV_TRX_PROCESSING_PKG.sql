--------------------------------------------------------
--  DDL for Package JAI_RCV_TRX_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_TRX_PROCESSING_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_trx_prc.pls 120.7.12010000.2 2009/07/22 11:39:28 srjayara ship $ */

  gv_func_curr CONSTANT  VARCHAR2(3) := 'INR';
  lb_debug      CONSTANT BOOLEAN     := TRUE;
  lv_debug      CONSTANT VARCHAR2(1)     := 'Y';

  /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
  INDIA_RMA_RECEIPT  CONSTANT           VARCHAR2(30) := 'India RMA Receipt';
  INDIA_RECEIPT      CONSTANT           VARCHAR2(30) := 'India Receipt';
  SOURCE_RMA         CONSTANT           VARCHAR2(30) := 'RMA';

  /* Excise/VAT Invoice generation Status for RTV */
  INV_GEN_STATUS_PENDING        CONSTANT VARCHAR2(30) := 'PENDING';
  INV_GEN_STATUS_NA             CONSTANT VARCHAR2(30) := 'NOT_APPLICABLE';
  INV_GEN_STATUS_GENERATE       CONSTANT VARCHAR2(30) := 'GENERATE';
  INV_GEN_STATUS_INV_NA         CONSTANT VARCHAR2(30) := 'INVOICE_NOT_APPLICABLE';
  INV_GEN_STATUS_INV_GENERATED  CONSTANT VARCHAR2(30) := 'INVOICE_GENERATED';

  CALLED_FROM_RCV_TRIGGER  CONSTANT VARCHAR2(30)  := 'RECEIPT_TAX_INSERT_TRG';
  CALLED_FROM_JAINPORE     CONSTANT VARCHAR2(30)  := 'JAINPORE';
  CALLED_FROM_JAINMVAT     CONSTANT VARCHAR2(30)  := 'JAINMVAT';
  CALLED_FROM_JAINRTVN     CONSTANT VARCHAR2(30)  := 'JAINRTVN';
  CALLED_FROM_JAITIGRTV    CONSTANT VARCHAR2(30)  := 'JAITIGRTV';
  CALLED_FROM_FND_REQUEST  CONSTANT VARCHAR2(30)  := 'Batch';

  /* MAPPING for JAI_RCV_TRANSACTIONS Attributes incase of transaction_type = 'RETURN TO VENDOR'
    attribute1 => EXCISE_INVOICE_GENERATION_ACTION
    attribute2 => VAT_INVOICE_GENERATION_ACTION
    attribute3 => EXCISE_INVOICE_GENERATION_BATCH_NO
    attribute4 => VAT_INVOICE_GENERATION_BATCH_NO
  */

  /* Vijay Shankar for Bug#4250171 */
  CALLED_FROM_OPM     CONSTANT VARCHAR2(15) := 'OPM';
  OPM_RECEIPT         CONSTANT VARCHAR2(15) := 'OPM RECEIPT';
  OPM_RETURNS         CONSTANT VARCHAR2(30) := 'OPM Receipt Correction';

  NO_ITEM_CLASS   CONSTANT VARCHAR2(4) := 'OTIN';    -- Vijay Shankar for Bug#4070938
  NO_SETUP   CONSTANT VARCHAR(1) := 'X';

  gv_shipment_header_id NUMBER ;  -- added, CSahoo for Bug 5344225
  gv_group_id 					NUMBER ;  -- added, CSahoo for Bug 5344225



  /*bgowrava for forward porting Bug#5756676..start*/
		lv_online_qty_flag     VARCHAR2(1);
		lv_qty_upd_event       VARCHAR2(30);
		lv_excise_flag         VARCHAR2(1);
		ln_part_i_register_id  NUMBER;
		lv_cgin_code           VARCHAR2(100);
		lv_register_type       VARCHAR2(1);
		lv_process_status      VARCHAR2(15);
		lv_process_message     VARCHAR2(4000);
		CURSOR cur_qty_setup( cp_organization_id NUMBER,
													cp_location_id     NUMBER
												 )
		IS
		SELECT quantity_register_update_event
			FROM JAI_CMN_INVENTORY_ORGS
		 WHERE organization_id = cp_organization_id
			 AND location_id     = cp_location_id ;

		CURSOR cur_item_excise_flag( cp_organization_id   NUMBER,
																 cp_inventory_item_id NUMBER
															 )
		IS
		SELECT excise_flag
			FROM JAI_INV_ITM_SETUPS
		 WHERE organization_id   = cp_organization_id
			 AND inventory_item_id = cp_inventory_item_id;

 /*bgowrava for forward porting Bug#5756676..end*/

  CURSOR c_trx(cp_transaction_id IN NUMBER) IS
    SELECT *
    FROM JAI_RCV_TRANSACTIONS
    WHERE transaction_id = cp_transaction_id;

  CURSOR c_base_trx(cp_transaction_id IN NUMBER) IS
    SELECT shipment_header_id, shipment_line_id, transaction_type, quantity, unit_of_measure, uom_code,
      parent_transaction_id, organization_id, location_id, subinventory, currency_conversion_rate
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. attribute_category attr_cat, nvl(attribute5, 'XX') rma_type, nvl(attribute4, 'N') generate_excise_invoice
      , routing_header_id   -- porting of Bug#3949109 (3927371)
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. , attribute3  online_claim_flag
      , source_document_code, po_header_id   -- Vijay Shankar for Bug#3940588
      , po_line_location_id --pramasub FP of Bug #4281841
      , po_distribution_id     /*added for bug 8538155 (FP for 8466620)*/
    FROM rcv_transactions
    WHERE transaction_id = cp_transaction_id;

  CURSOR c_excise_invoice_no(cp_shipment_line_id IN NUMBER) IS
    SELECT excise_invoice_no, excise_invoice_date, online_claim_flag
    FROM JAI_RCV_LINES
    WHERE shipment_line_id = cp_shipment_line_id;
    -- pramasub FP start
   /*
   || Start additions by ssumaith - Iprocurement Bug#4281841.
   */

   CURSOR check_rcpt_source(p_line_location_id IN NUMBER) IS
   SELECT apps_source_code
   FROM   po_requisition_headers_all
   WHERE  requisition_header_id IN
  (SELECT requisition_header_id
   FROM   po_requisition_lines_all
   WHERE  line_location_id = p_line_location_id
  );

   lv_apps_source_code  VARCHAR2(30);

   /*
   || End additions by ssumaith - Iprocurement Bug#4281841
   */
    -- pramasub FP end

  -- Constants that will be returned from functions or procedures. returned values should be compared with these values
  MFG_ORGN          CONSTANT  VARCHAR2(1) := 'M';
  TRADING_ORGN      CONSTANT  VARCHAR2(1) := 'T';
  BONDED_SUBINV     CONSTANT  VARCHAR2(1) := 'B';
  TRADING_SUBINV    CONSTANT  VARCHAR2(1) := 'T';

  -- added by Vijay Shankar for Bug#3940588.
  -- to support the deferred cenvat claim functionality. this is required because we obsoleted the old receipts code
  PROCEDURE process_deferred_cenvat_claim(
    p_batch_id            IN  NUMBER,
    p_called_from         IN  VARCHAR2,
    p_simulate_flag       IN  VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'N',
    p_process_flag OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2
  );

  PROCEDURE process_batch(
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_organization_id       IN  NUMBER,
    pv_transaction_from      IN  VARCHAR2, /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
    pv_transaction_to        IN  VARCHAR2, /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
    p_transaction_type      IN  VARCHAR2,
    p_parent_trx_type       IN  VARCHAR2,
    p_shipment_header_id    IN  NUMBER,     -- New parameter added by Vijay Shankar for Bug#3940588
    p_receipt_num           IN  VARCHAR2,
    p_shipment_line_id      IN  NUMBER,     -- New parameter added by Vijay Shankar for Bug#3940588
    p_transaction_id        IN  NUMBER,
    p_commit_switch         IN  VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'Y',
    p_called_from           IN  VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'Batch',
    p_simulate_flag         IN  VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'N',
    p_trace_switch          IN  VARCHAR2, --File.Sql.35 Cbabu  DEFAULT 'N'
    p_request_id            IN  NUMBER   DEFAULT NULL, -- CSahoo for Bug 5344225
    p_group_id              IN  NUMBER   DEFAULT NULL -- CSahoo for Bug 5344225
  );

  PROCEDURE process_transaction(
    p_transaction_id      IN      NUMBER,
    p_process_flag        IN OUT NOCOPY VARCHAR2,
    p_process_message     IN OUT NOCOPY VARCHAR2,
    p_cenvat_rg_flag      IN OUT NOCOPY VARCHAR2,
    p_cenvat_rg_message   IN OUT NOCOPY VARCHAR2,
    p_common_err_mesg OUT NOCOPY VARCHAR2,
    p_called_from         IN  VARCHAR2,
    p_simulate_flag       IN      VARCHAR2,
    p_codepath            IN OUT NOCOPY VARCHAR2,
    -- following parameters introduced for second claim of receive transaction
    p_process_special_reason    IN        VARCHAR2    DEFAULT NULL,
    p_process_special_qty       IN        NUMBER      DEFAULT NULL,
    /*Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.*/
    p_excise_processing_reqd    IN        VARCHAR2, --File.Sql.35 Cbabu     DEFAULT jai_constants.yes,
    p_vat_processing_reqd       IN        VARCHAR2 --File.Sql.35 Cbabu     DEFAULT jai_constants.yes
  );

  PROCEDURE populate_details(
    p_transaction_id      IN      NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag       IN      VARCHAR2,
    p_codepath            IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE validate_transaction(
    p_transaction_id      IN      NUMBER,
    p_process_flag        IN OUT NOCOPY VARCHAR2,
    p_process_message     IN OUT NOCOPY VARCHAR2,
    p_cenvat_rg_flag      IN OUT NOCOPY VARCHAR2,
    p_cenvat_rg_message   IN OUT NOCOPY VARCHAR2,
    /* following two flags introduced by Vijay Shankar for Bug#4250236(4245089). VAT Implementation */
    p_process_vat_flag    IN OUT NOCOPY VARCHAR2,
    p_process_vat_message IN OUT NOCOPY VARCHAR2,
    p_called_from         IN      VARCHAR2,
    p_simulate_flag       IN      VARCHAR2,
    p_codepath            IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE process_rtv(
    pv_errbuf OUT NOCOPY VARCHAR2,
    pv_retcode OUT NOCOPY VARCHAR2,
    pn_batch_num            IN  NUMBER,
    pn_min_transaction_id   IN  NUMBER,
    pn_max_transaction_id   IN  NUMBER,
    pv_called_from          IN  VARCHAR2, --File.Sql.35 Cbabu   DEFAULT 'Y',
    pv_commit_switch        IN  VARCHAR2, --File.Sql.35 Cbabu   DEFAULT 'Y',
    pv_debug_switch         IN  VARCHAR2 --File.Sql.35 Cbabu   DEFAULT 'N'
  );

  FUNCTION process_iso_transaction(
    p_transaction_id      IN NUMBER,
    p_shipment_line_id    IN NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_trxn_tax_amount(
    p_transaction_id      IN  NUMBER,
    p_shipment_line_id    IN  NUMBER,
    p_curr_conv_rate      IN  NUMBER,
    p_return_in_inr_curr  IN  VARCHAR2  --File.Sql.35 Cbabu  DEFAULT 'Y'
  ) RETURN NUMBER;

  FUNCTION get_trxn_cenvat_amount(
    p_transaction_id      IN  NUMBER,
    p_shipment_line_id    IN  NUMBER,
    p_organization_type   IN  VARCHAR2,
    p_curr_conv_rate      IN  NUMBER
  ) RETURN NUMBER;

  FUNCTION get_apportion_factor(
    p_transaction_id      IN NUMBER
  ) RETURN NUMBER;

  -- Vijay Shankar for Bug#3940588. RECEIPTS DEPLUG
  FUNCTION get_equivalent_qty_of_receive(
    p_transaction_id IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_message(
    p_message_code        IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION get_object_code(
    p_object_name         IN VARCHAR2,
    p_event_name          IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION get_ancestor_id(
    p_transaction_id      IN NUMBER,
    p_shipment_line_id    IN NUMBER,
    p_required_trx_type   IN VARCHAR2
  ) RETURN NUMBER;

  FUNCTION get_accrue_on_receipt(
    p_po_distribution_id  IN NUMBER,
    p_po_line_location_id IN  NUMBER DEFAULT NULL
  ) RETURN VARCHAR2;

END jai_rcv_trx_processing_pkg;

/
