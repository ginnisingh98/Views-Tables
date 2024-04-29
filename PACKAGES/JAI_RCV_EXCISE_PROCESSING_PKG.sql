--------------------------------------------------------
--  DDL for Package JAI_RCV_EXCISE_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_EXCISE_PROCESSING_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_exc_prc.pls 120.4.12010000.3 2009/08/14 13:05:33 vkaranam ship $ */

/*
OPEN ISSUES:
  1) Partial Delivery of CGIN items to NonBonded Delivery then what should we do the second claim of RECEIVE
*/

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.1 jai_rcv_exc_prc -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
	     as required for CASE COMPLAINCE.

06-Jul-2005  Ramananda for bug#4477004. File Version: 116.2
             GL Sources and GL Categories got changed. Refer bug for the details


30/10/2006  SACSETHI for bug 5228046, File version 120.2
            Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
            This bug has datamodel and spec changes.

16/04/2007 Vkarnaam for bug #5989740 File version 120.3
           Forward Porting the changes in 115 bug 5907436(Enh:handling Secondary and Higher Education Cess).

18/11/2008 vumaasha
           Forward porting the changes in the 115bug 4545776
		   Changed the cursor c_source_orgn_loc to fetch shipment_num (
		   rcv_shipment_headers )
		   or delivery_id ( wsh_new_deliveries ) based on whether delivery_id is
		   number or character value respectively.
14-aug-2009 vkaranam for bug#4750798
	    fwdported the changes done in 115 bug 4619176   /7229349
	    I havent considered shcess changes in 7229349 fix as all shcess changes are not fped.
--------------------------------------------------------------------------------------
*/

  lb_rg_debug       CONSTANT BOOLEAN       := true;
  gn_cenvat_rnd     CONSTANT NUMBER        := 0;

  gv_source_name    CONSTANT VARCHAR2(25)  := 'Purchasing India';
  gv_category_name  CONSTANT VARCHAR2(25)  := 'Receiving India';


  CENVAT_CREDIT     CONSTANT     VARCHAR2(2)   := 'Cr';
  CENVAT_DEBIT      CONSTANT     VARCHAR2(2)   := 'Dr';
  SECOND_50PTG_CLAIM    CONSTANT VARCHAR2(15)  := '2nd 50% Claim';

  /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
  CGIN_FIRST_CLAIM      CONSTANT VARCHAR2(10) := '1st Claim';
  CGIN_SECOND_CLAIM     CONSTANT VARCHAR2(10) := '2nd Claim';

  TYPE tax_breakup IS RECORD(
    basic_excise      NUMBER   := 0,
    addl_excise       NUMBER   := 0,
    other_excise      NUMBER   := 0,
    cvd               NUMBER   := 0,
    non_cenvat        NUMBER   := 0,
    excise_edu_cess   NUMBER   := 0,
    cvd_edu_cess      NUMBER   := 0,
    addl_cvd          NUMBER   := 0, -- Date 30/10/2006 Bug 5228046 added by SACSETHI
   /*added the following by vkaranam for budget 07 impact - bug#5907436*/
    sh_exc_edu_cess   NUMBER   := 0,
    sh_cvd_edu_cess   NUMBER   := 0

  );

  CURSOR c_trx(cp_transaction_id IN NUMBER) IS
    SELECT *
    FROM JAI_RCV_TRANSACTIONS
    WHERE transaction_id = cp_transaction_id;

  CURSOR c_base_trx(cp_transaction_id IN NUMBER) IS
    SELECT shipment_header_id, requisition_line_id, primary_quantity, uom_code, unit_of_measure,
      po_header_id, po_line_id, po_line_location_id, transaction_id, subinventory,
      vendor_id, vendor_site_id, customer_id, customer_site_id, oe_order_line_id,
      transaction_type, destination_type_code, source_document_code, quantity
      -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. ,attribute_category attr_cat, attribute1, attribute2, attribute3, attribute4, attribute5 rma_type
    FROM rcv_transactions
    WHERE transaction_id = cp_transaction_id;

  /* Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
  CURSOR c_jai_receipt_line(cp_shipment_line_id IN NUMBER) IS
    select rma_type
    from JAI_RCV_LINES
    where shipment_line_id = cp_shipment_line_id;

  CURSOR c_orgn_info(cp_organization_id IN NUMBER, cp_location_id IN NUMBER) IS
    SELECT modvat_rm_account_id, modvat_cg_account_id, modvat_pla_account_id, cenvat_rcvble_account,
          excise_in_rg23d, excise_23d_account, excise_rcvble_account,
          ssi_unit_flag, pref_rg23a, pref_rg23c, pref_pla, nvl(ssi_unit_flag, 'N') allow_negative_pla,
          excise_edu_cess_rm_account, excise_edu_cess_cg_account, excise_edu_cess_rcvble_accnt  -- Vijay Shankar for Bug#3940588
          , cess_paid_payable_account_id    -- Vijay Shankar for Bug#4211045
          , rtv_account_flag, rtv_expense_account_id    ,-- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh.. SSI Func.
           /*added the following columns  by vkaranam for budget 07 impact - bug#5989740*/
	   sh_cess_cg_account_id,sh_cess_paid_payable_acct_id,sh_cess_rcvble_acct_id,sh_cess_rm_account,sh_cess_rnd_account_id

    FROM JAI_CMN_INVENTORY_ORGS
    WHERE organization_id = cp_organization_id
    AND location_id = cp_location_id;

  CURSOR c_rcv_params(cp_organization_id IN NUMBER) IS
    SELECT receiving_account_id
    FROM rcv_parameters
    WHERE organization_id = cp_organization_id;


	  /*
	    || vumaasha  bug#5749963. Added decode statement for shipment_num.
	  */


  CURSOR c_source_orgn_loc(cp_shipment_hdr_id IN NUMBER, cp_req_line_id IN NUMBER) IS
    SELECT organization_id, location_id
    FROM JAI_OM_WSH_LINES_ALL
    WHERE delivery_id = ( SELECT
	decode(ltrim(translate(shipment_num,'0123456789','~'),'~'),NULL,rsh.shipment_num,
	            (select delivery_id
				from wsh_new_deliveries
				where name=rsh.shipment_num
				)

			)
	from rcv_shipment_headers rsh
	where shipment_header_id = cp_shipment_hdr_id
    )
    AND order_line_id IN ( select line_id
      from oe_order_lines_all
      where source_document_type_id = 10  -- 10 corresponds to 'Internal' document type
      and source_document_line_id = cp_req_line_id
    );

 --start additions for bug 4750798
    PROCEDURE get_excise_tax_rounding_factor(
   p_transaction_id IN NUMBER,
   p_Excise_rf OUT NOCOPY NUMBER,
   p_Excise_edu_cess_rf OUT NOCOPY NUMBER,
   p_Excise_she_cess_rf OUT NOCOPY NUMBER
   );

--end bug 4750798


  PROCEDURE do_cenvat_rounding(
    p_transaction_id            IN        NUMBER,
    pr_tax                      IN OUT NOCOPY TAX_BREAKUP,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE process_transaction(
    p_transaction_id            IN        NUMBER,
    p_cenvat_claimed_ptg        IN OUT NOCOPY VARCHAR2,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag             IN        VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2,
    -- following parameters introduced for second claim of receive transaction
    p_process_special_reason    IN        VARCHAR2    DEFAULT NULL,
    p_process_special_qty       IN        NUMBER      DEFAULT NULL
  );

  PROCEDURE rg_i_entry(
    p_transaction_id            IN        NUMBER,
    pr_tax                      IN        TAX_BREAKUP,
    p_register_entry_type       IN        VARCHAR2,
    p_register_id OUT NOCOPY NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag             IN        VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE rg23_part_i_entry(
    p_transaction_id            IN        NUMBER,
    pr_tax                      IN        TAX_BREAKUP,
    p_register_entry_type       IN        VARCHAR2,
    p_register_id OUT NOCOPY NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag             IN        VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE rg23_d_entry(
    p_transaction_id            IN        NUMBER,
    pr_tax                      IN        TAX_BREAKUP,
    p_register_entry_type       IN        VARCHAR2,
    p_register_id OUT NOCOPY NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag             IN        VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE rg23_part_ii_entry(
    p_transaction_id            IN        NUMBER,
    pr_tax                      IN        TAX_BREAKUP,
    p_part_i_register_id        IN        NUMBER,
    p_register_entry_type       IN        VARCHAR2,
    p_reference_num             IN        VARCHAR2,
    p_register_id OUT NOCOPY NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag             IN        VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE pla_entry(
    p_transaction_id            IN        NUMBER,
    pr_tax                      IN        TAX_BREAKUP,
    p_register_entry_type       IN        VARCHAR2,
    p_register_id OUT NOCOPY NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag             IN        VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

	  PROCEDURE accounting_entries(
	    p_transaction_id            IN        NUMBER,
	    pr_tax                      IN        TAX_BREAKUP,
	    p_cgin_code                 IN        VARCHAR2,
	    p_cenvat_accounting_type    IN        VARCHAR2,
	    p_amount_register           IN        VARCHAR2,
	    p_cenvat_account_id OUT NOCOPY NUMBER,
	    p_process_status OUT NOCOPY VARCHAR2,
	    p_process_message OUT NOCOPY VARCHAR2,
	    p_simulate_flag             IN        VARCHAR2,
	    p_codepath                  IN OUT NOCOPY VARCHAR2
    , pv_retro_reference          IN VARCHAR2 DEFAULT NULL --Added by Eric on Jan 18,2008 for retro
	  );

  PROCEDURE derive_cgin_scenario(
    p_transaction_id            IN        NUMBER,
    p_cgin_code OUT NOCOPY VARCHAR2,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE update_registers(
    p_quantity_register_id      IN        NUMBER,
    p_quantity_register         IN        VARCHAR2,
    p_payment_register_id       IN        NUMBER,
    p_payment_register          IN        VARCHAR2,
    p_charge_account_id         IN        NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag             IN        VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE validate_transaction(
    p_transaction_id            IN        NUMBER,
    p_validation_type           IN        VARCHAR2,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_simulate_flag             IN        VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE generate_excise_invoice(
    p_transaction_id            IN        NUMBER,
    p_organization_id           IN        NUMBER,
    p_location_id               IN        NUMBER,
    p_excise_invoice_no OUT NOCOPY VARCHAR2,
    p_excise_invoice_date OUT NOCOPY DATE,
    p_simulate_flag             IN        VARCHAR2,
    p_errbuf OUT NOCOPY VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

  FUNCTION get_receive_claimed_ptg(
    p_transaction_id            IN        NUMBER,
    p_shipment_line_id          IN        NUMBER,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  ) RETURN NUMBER;

  PROCEDURE get_tax_amount_breakup(
    p_shipment_line_id          IN        NUMBER,
    p_transaction_id            IN        NUMBER,
    p_curr_conv_rate            IN        NUMBER,
    pr_tax OUT NOCOPY TAX_BREAKUP,
    p_breakup_type              IN        VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE other_cenvat_rg_recording(
    p_source_register           IN        VARCHAR2,
    p_source_register_id        IN        NUMBER,
    p_tax_type                  IN        VARCHAR2,
    p_credit                    IN        NUMBER,
    p_debit                     IN        NUMBER,
    p_process_status OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2
  );

  PROCEDURE check_cenvat_balances(
    p_organization_id           IN        NUMBER,
    p_location_id               IN        NUMBER,
    p_transaction_amount        IN        NUMBER,
    p_register_type             IN        VARCHAR2,
    p_process_flag OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2
  );

  PROCEDURE derive_duty_registers(
    p_organization_id           IN        NUMBER,
    p_location_id               IN        NUMBER,
    p_item_class                IN        VARCHAR2,
    pr_tax                      IN        TAX_BREAKUP,
    p_cenvat_register_type OUT NOCOPY VARCHAR2,
    -- p_edu_cess_register_type        OUT   VARCHAR2,
    p_process_flag OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_codepath                  IN OUT NOCOPY VARCHAR2
  );

  procedure rtv_processing_for_ssi(
    pn_transaction_id                 NUMBER,
    pv_codepath         in out nocopy varchar2,
    pv_process_status   out nocopy    varchar2,
    pv_process_message  out nocopy    varchar2
  );

END jai_rcv_excise_processing_pkg;

/
