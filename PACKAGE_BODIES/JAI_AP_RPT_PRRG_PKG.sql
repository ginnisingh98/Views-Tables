--------------------------------------------------------
--  DDL for Package Body JAI_AP_RPT_PRRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_RPT_PRRG_PKG" AS
/* $Header: jai_ap_rpt_prrg.plb 120.7.12010000.6 2009/01/08 05:34:21 nprashar ship $ */

  /* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005    Version 116.1 jai_ap_rpt_prrg -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

14-Jun-2005    rchandan for bug#4428980, Version 116.2
               Modified the object to remove literals from DML statements and CURSORS.
	       As part OF R12 Initiative Inventory conversion the OPM code is commented

09-Dec-2005  4866533  Added by Lakshmi Gopalsami Version 120.3
                      Added WHO columns in insert to jai_po_rep_prrg_t


01/11/2006  SACSETHI for bug 5228046, File version 120.4
            Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
            This bug has datamodel and spec changes.

01/17/2008  Kevin Cheng for Inclusive Tax calculation
            Add query criteria to eliminate Inclusive taxes from results.

25-FEB-2008  Changes done by nprashar for bug # 6803557.
Added a column invoice_distribution-id in cursor definition c_get_tax_from_ap also
changed the cursor c_get_tax_type.Added a parameter to cursor c_get_misc_tax_line_amt , p_invoice_distribution_id.

8-july-2008 Changes by nprashar for bug # 7225946. Changes in defintion of cursor c_inv_select_cursor,c_inv_item_lines.

05-Nov-2008 Modified by JMEENA for bug#7621541
			Removed the input parameter 'ITEM' from cursor c_inv_select_cursor,c_inv_item_lines.
*/

PROCEDURE process_report
  (
  p_invoice_date_from             IN  date,
  p_invoice_date_to               IN  date,
  p_vendor_id                     IN  number,
  p_vendor_site_id                IN  number,
  p_org_id                      IN  NUMBER,
  p_run_no OUT NOCOPY number,
  p_error_message OUT NOCOPY varchar2
  ) IS

    cursor c_get_run_no is
    select JAI_PO_REP_PRRG_T_RUNNO_S.nextval
    from dual;

   cursor c_inv_select_cursor is /*Signature change of cursor by nprahsar for bug # 7225946*/ --rchandan for bug#4428980
    select invoice_id, invoice_num, org_id, vendor_id, vendor_site_id, invoice_date,
      invoice_currency_code, nvl(exchange_rate,1) exchange_rate, voucher_num
    from   ap_invoices_all  aia
    where  cancelled_date is null
    and    (p_vendor_id is null or vendor_id = p_vendor_id)
    and    (p_vendor_site_id is null or vendor_site_id = p_vendor_site_id)
    and    (p_org_id is null or org_id = p_org_id)
    and    exists
         (select '1'
        from   ap_invoice_distributions_all
        where  invoice_id = aia.invoice_id
        and    line_type_lookup_code in ('ITEM','ACCRUAL')--nprahsar for bug # 7225946*/
        and    po_distribution_id is not null
        and    nvl(reversal_flag, 'N') <> 'Y'
        and    accounting_date >= p_invoice_date_from /* Modified by Ramananda for bug:4071409 */
        and    accounting_date <= p_invoice_date_to /* Modified by Ramananda for bug:4071409 */
         );

    cursor c_inv_item_lines(p_invoice_id number) is /*Signature change of cursor by nprashar for bug # 7225946*/ --rchandan for bug#4428980
    select
      distribution_line_number,
      po_distribution_id,
      rcv_transaction_id,
      amount,
      invoice_distribution_id,
      invoice_line_number
      /*
        In the above cursor added invoice_line_number by  Brathod, for Bug#4510143 to pass invoice_line_number
        as parameter to jai_ap_utils_pkg.get_apportion_factor
      */
    from ap_invoice_distributions_all
    where invoice_id = p_invoice_id
    and    line_type_lookup_code in ('ITEM','ACCRUAL')
    and    po_distribution_id is not null
    and    nvl(reversal_flag, 'N') <> 'Y'
    and    accounting_date >= p_invoice_date_from /* Modified by Ramananda for bug:4071409 */
    and    accounting_date <= p_invoice_date_to;    /* Modified by Ramananda for bug:4071409 */




    cursor c_get_po_details(p_po_distribution_id number) is
    select
      po_header_id,
      segment1,
      trunc(creation_date) po_date
    from   po_headers_all
    where  po_header_id =
      ( select  po_header_id
        from    po_distributions_all
        where   po_distribution_id = p_po_distribution_id);

    cursor c_get_po_release (p_po_distribution_id number) is
    select  release_num, release_date
    from    po_releases_all
    where   po_release_id in
      (
        select po_release_id
        from po_line_locations_all
        where  (po_header_id, po_line_id, line_location_id ) in
            (
              select  po_header_id, po_line_id, line_location_id
              from    po_distributions_all
              where   po_distribution_id = p_po_distribution_id
            )
      );



    cursor c_get_receipt_num(p_transaction_id number) is
    select receipt_num, trunc(creation_date) receipt_date
    from   rcv_shipment_headers
    where  shipment_header_id =
      ( select  shipment_header_id
        from    rcv_transactions
        where   transaction_id = p_transaction_id);

cursor c_get_tax_from_ap (
      p_invoice_id number,
      p_parent_distribution_id number,
      p_po_distribution_id number) is
    select distribution_line_number, tax_id,invoice_distribution_id /*Changed by nprashar for bug # 6803557 */
    from   JAI_AP_MATCH_INV_TAXES
    where  invoice_id = p_invoice_id
    and    parent_invoice_distribution_id = p_parent_distribution_id
    and    po_distribution_id = p_po_distribution_id
    union
    select distribution_line_number, tax_id,invoice_distribution_id /*Changed by nprashar for bug # 6803557 */
    from   JAI_AP_MATCH_INV_TAXES
    where  invoice_id = p_invoice_id
    and    parent_invoice_distribution_id is null
    and    po_distribution_id is null
    and    (po_header_id, po_line_id, line_location_id)
         in
         (
        select po_header_id, po_line_id, line_location_id
        from   po_distributions_all
        where  po_distribution_id = p_po_distribution_id
        );

   cursor c_get_tax_type(p_tax_id number) is
    select  UPPER(tax_type) tax_type /*Changes by nprashar for bug  7678389, replaced initcap by Upper function Changes by nprashar for bug # 6803557 */
    from    JAI_CMN_TAXES_ALL
    where   tax_id = p_tax_id;

    cursor c_get_misc_tax_line_amt (p_invoice_id number, p_distribution_line_number number, p_invoice_distribution_id number ) is
    select amount
    from   ap_invoice_distributions_all
    where  invoice_id = p_invoice_id
    and    distribution_line_number = p_distribution_line_number
    and    invoice_distribution_id = p_invoice_distribution_id /*Added by nprashar for Bug # 6803557*/
    and    accounting_date >= p_invoice_date_from /* Modified by Ramananda for bug:4071409 */
    and    accounting_date <= p_invoice_date_to;    /* Modified by Ramananda for bug:4071409 */


    cursor c_get_tax_from_receipt
        (
        p_invoice_id                number,
        p_parent_distribution_id    number,
        p_po_distribution_id        number,
        p_rcv_transaction_id        number
        ) is
    select A.tax_id, upper(A.tax_type) tax_type, A.currency, A.tax_amount
    from   JAI_RCV_LINE_TAXES A, JAI_CMN_TAXES_ALL B -- Added by Kevin Cheng for Inclusive Tax
    where (A.shipment_header_id, A.shipment_line_id)
           in
         (select shipment_header_id, shipment_line_id
          from   rcv_transactions
        where  transaction_id = p_rcv_transaction_id)
    and    A.tax_id not in
        (
          select tax_id
          from   JAI_AP_MATCH_INV_TAXES
          where  invoice_id = p_invoice_id
          and    parent_invoice_distribution_id = p_parent_distribution_id
          and    po_distribution_id = p_po_distribution_id
          union
          select tax_id
          from   JAI_AP_MATCH_INV_TAXES
          where  invoice_id = p_invoice_id
          and    parent_invoice_distribution_id is null
          and    po_distribution_id is null
          and      (po_header_id, po_line_id, line_location_id)
               in
               (
              select po_header_id, po_line_id, line_location_id
              from   po_distributions_all
              where  po_distribution_id = p_po_distribution_id
              )
        )
    AND A.tax_id = B.tax_id -- Added by Kevin Cheng for Inclusive Tax
    AND nvl(B.inclusive_tax_flag, 'N') = 'N' -- Added by Kevin Cheng for Inclusive Tax
        ;



    cursor c_get_tax_from_po
        (
        p_invoice_id                number,
        p_parent_distribution_id    number,
        p_po_distribution_id        number,
        p_rcv_transaction_id        number
        ) is
    select A.tax_id, upper(A.tax_type) tax_type, A.currency, A.tax_amount
    from   JAI_PO_TAXES A, JAI_CMN_TAXES_ALL B -- Added by Kevin Cheng for Inclusive Tax
    where  (A.po_header_id, A.po_line_id, A.line_location_id)
         in
         (select po_header_id, po_line_id, line_location_id
        from   po_distributions_all
        where  po_distribution_id = p_po_distribution_id)
    and    A.tax_id not in
        (
          select tax_id
          from   JAI_AP_MATCH_INV_TAXES
          where  invoice_id = p_invoice_id
          and    parent_invoice_distribution_id = p_parent_distribution_id
          and    po_distribution_id = p_po_distribution_id
          union
          select tax_id
          from   JAI_AP_MATCH_INV_TAXES
          where  invoice_id = p_invoice_id
          and    parent_invoice_distribution_id is null
          and    po_distribution_id is null
          and      (po_header_id, po_line_id, line_location_id)
               in
               (
              select po_header_id, po_line_id, line_location_id
              from   po_distributions_all
              where  po_distribution_id = p_po_distribution_id
              )
        )
    AND A.tax_id = B.tax_id -- Added by Kevin Cheng for Inclusive Tax
    AND nvl(B.inclusive_tax_flag, 'N') = 'N'; -- Added by Kevin Cheng for Inclusive Tax



    v_run_no            number;
    v_po_header_id      po_headers_all.po_header_id%type;
    v_po_number         po_headers_all.segment1%type;
    v_po_date           date;
    v_receipt_num       rcv_shipment_headers.receipt_num%type;
    v_receipt_date      date;
    v_tax_type          JAI_CMN_TAXES_ALL.tax_type%type;
    v_po_release_num    po_releases_all.release_num%type;
    v_po_release_date   date;

    v_excise_ap         number;
    v_customs_ap        number;
    v_cvd_ap            number;
    v_cst_ap            number;
    v_lst_ap            number;
    v_freight_ap        number;
    v_octroi_ap         number;
    v_others_ap         number;

    v_excise_po         number;
    v_customs_po        number;
    v_cvd_po            number;
    v_cst_po            number;
    v_lst_po            number;
    v_freight_po        number;
    v_octroi_po         number;
    v_others_po         number;

    v_tax_amt           number;

    v_conversion_factor number;

    v_statement_id      number:=0;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI
-- START BUG 5228046

	v_addcvd_ap     NUMBER;
        v_addcvd_po     NUMBER;

-- END BUG 5228046

-- Date 24-Nov-2006 forward porting Bug 5671126  added by Balaji
--start
	v_vat_ap     	NUMBER;
	v_turnover_ap   NUMBER;
	v_entry_ap      NUMBER;
	v_pur_ap        NUMBER;
	v_vat_po        NUMBER;
	v_turnover_po   NUMBER;
	v_entry_po      NUMBER;
	v_pur_po        NUMBER;
	v_service_ap    NUMBER;
	v_service_po    NUMBER;
--end


  BEGIN

  /* -----------------------------------------------------------------------------
   FILENAME: process_report_p.sql
   CHANGE HISTORY:

   S.No      Date          Author and Details
   1         14/06/2004    Created by Aparajita for bug#3633078. Version#115.0.

                           This procedure populates temporary table JAI_PO_REP_PRRG_T,
                           to be used by the purchase register report.

                           Depending on the input parameter, all invoices are selected.
                           Taxes that have been already brought over to payable invoice
                           as 'miscellaneous' distribution lines are considered by their tax
                           type.

                           For each line the taxes from the corresponding Receipt / PO are
                           again considered for any tax that is not brought over to AP. This is
                           possible as third party taxes and taxes like cvd and customs are not brought
                           over to AP. These taxes are also grouped by their tax type. These taxes
                           from purchasing side are checked for apportion factor for changes in Quantity,
                           Price and UOM for each line. Each tax line's currency is also compared against
                           invoice currency and is converted to invoice currency if required.

                           Taxes are grouped as follows,

                excise
                customs
                cvd
                cst
                lst
                freight
                octroi
                others

   2         31/12/2004   Created by Ramananda for bug#4071409. Version#115.1

             Issue:-
                           The report JAINPRRG.rdf calls this procedure process_report.
                           A set of from and to dates are being passed to this report.Currently the report
                           picks up the invoices based on these parameters and the details of these
                           picked up invoices are displayed in the report
             Reason:-
                           Invoice date is checked against the input date parameters to pick the invoices
             Fix:-
                           Accounting date is used against the input date parameters to pick the invoices
             Dependency due to this bug:-
       None


   Future Dependencies For the release Of this Object:-
   ==================================================
   Please add a row in the section below only if your bug introduces a dependency
   like,spec change/ A new call to a object/A datamodel change.

   --------------------------------------------------------------------------------
   Version       Bug       Dependencies (including other objects like files if any)
   --------------------------------------------------------------------------------
   115.0       3633078    Datamodel dependencies

  --------------------------------------------------------------------------------- */

    -- get the run_no
    v_statement_id:= 1;
    open c_get_run_no;
    fetch c_get_run_no into v_run_no;
    close c_get_run_no;

    v_statement_id:= 2;
	 --JMEENA for bug#7621541, Removed Input parameter 'ITEM' from c_inv_select_cursor
    for c_inv_select_rec in c_inv_select_cursor LOOP  --rchandan for bug#4428980

      v_statement_id:= 3;

      -- check and loop through all the eligible item lines and populate the temp table
	  --JMEENA for bug#7621541, Removed Input parameter 'ITEM' from c_inv_item_lines
      for c_item_lines_rec in c_inv_item_lines(c_inv_select_rec.invoice_id) loop

        v_statement_id:= 4;

        v_po_header_id  := null;
        v_po_number     := null;
        v_receipt_num   := null;
        v_receipt_date  := null;
        v_po_date       := null;
        v_po_release_num := null;
        v_po_release_date := null;


        v_excise_ap     := 0;
        v_customs_ap    := 0;
        v_cvd_ap        := 0;
        v_cst_ap        := 0;
        v_lst_ap        := 0;
        v_freight_ap    := 0;
        v_octroi_ap     := 0;
        v_others_ap     := 0;

        v_excise_po     := 0;
        v_customs_po    := 0;
        v_cvd_po        := 0;
        v_cst_po        := 0;
        v_lst_po        := 0;
        v_freight_po    := 0;
        v_octroi_po     := 0;
        v_others_po     := 0;
-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI
-- START BUG 5228046
         v_addcvd_ap  := 0;
         v_addcvd_po  := 0;
-- END BUG 5228046
         -- End , Added by Girish w.r.t BUG#5143906( for Additional CVD)

      -- Date 24-Nov-2006 forward porting Bug 5671126  added by Balaji
      --start
		        v_vat_ap     := 0;
			v_turnover_ap:= 0;
			v_entry_ap   := 0;
			v_pur_ap     := 0;
			v_vat_po     := 0;
			v_turnover_po:= 0;
			v_entry_po   := 0;
			v_pur_po     := 0;
			v_service_ap := 0;
			v_service_po := 0;
			--end
        v_conversion_factor := 1;

        v_statement_id:= 5;
        -- get the PO reference for the item line
        open c_get_po_details(c_item_lines_rec.po_distribution_id);
        fetch c_get_po_details into  v_po_header_id, v_po_number, v_po_date;
        close c_get_po_details;

        v_statement_id:= 6;
        open c_get_po_release(c_item_lines_rec.po_distribution_id);
        fetch c_get_po_release into v_po_release_num, v_po_release_date;
        close c_get_po_release;


        -- get the receipt reference
        if c_item_lines_rec.rcv_transaction_id is not null then
          v_statement_id:= 7;
          open c_get_receipt_num(c_item_lines_rec.rcv_transaction_id);
          fetch c_get_receipt_num into v_receipt_num, v_receipt_date;
          close c_get_receipt_num;
        end if;


        -- get tax from payables side
        for c_get_tax_from_ap_rec in
          c_get_tax_from_ap
          (
          c_inv_select_rec.invoice_id,
          c_item_lines_rec.invoice_distribution_id,
          c_item_lines_rec.po_distribution_id)
        loop

          v_statement_id:= 8;

          v_tax_type := null;
          v_tax_amt := 0;

          open c_get_tax_type(c_get_tax_from_ap_rec.tax_id);
          fetch c_get_tax_type into v_tax_type;
          close c_get_tax_type;

          v_statement_id:= 9;

         open c_get_misc_tax_line_amt
          (c_inv_select_rec.invoice_id, c_get_tax_from_ap_rec.distribution_line_number,
           c_get_tax_from_ap_rec.invoice_distribution_id); /*Added by nprashar for bug # 6803557 */
          fetch c_get_misc_tax_line_amt into v_tax_amt;
          close c_get_misc_tax_line_amt;

          v_statement_id:= 10;

          if v_tax_type in (UPPER(jai_constants.tax_type_exc_additional), UPPER(jai_constants.tax_type_excise),UPPER(jai_constants.tax_type_exc_other)) then
            v_excise_ap := v_excise_ap + v_tax_amt;
          elsif v_tax_type = UPPER(jai_constants. tax_type_cst) then
            v_cst_ap := v_cst_ap + v_tax_amt;
          elsif v_tax_type = UPPER(jai_constants.tax_type_sales) then
            v_lst_ap := v_lst_ap + v_tax_amt;
          elsif v_tax_type= UPPER(jai_constants.tax_type_customs)  then
            v_customs_ap := v_customs_ap + v_tax_amt;
          elsif v_tax_type = UPPER(jai_constants.tax_type_cvd) then
            v_cvd_ap := v_cvd_ap + v_tax_amt;
	-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI
	-- START BUG 5228046
	  elsif v_tax_type = UPPER(jai_constants.tax_type_add_cvd) then
            v_addcvd_ap := v_addcvd_ap + v_tax_amt;
	-- END BUG 5228046
	-- Date 24-Nov-2006 Forward porting Bug 5671126 added by Balaji
	--start
	   elsif v_tax_type = UPPER(jai_constants.tax_type_value_added) then
	  		    v_vat_ap := v_vat_ap + v_tax_amt;
           elsif v_tax_type = UPPER(jai_constants.tax_type_purchase) then
	  		    v_pur_ap := v_pur_ap + v_tax_amt;
           elsif v_tax_type = UPPER(jai_constants.tax_type_turnover) then
	  		    v_turnover_ap := v_turnover_ap + v_tax_amt;
           elsif v_tax_type= UPPER(jai_constants.tax_type_entry) then
	  		    v_entry_ap := v_entry_ap + v_tax_amt;
	   elsif v_tax_type= UPPER(jai_constants.tax_type_service) then
	  		    v_service_ap := v_service_ap + v_tax_amt;
	    --end
          elsif v_tax_type = UPPER(jai_constants.tax_type_freight)  then
            v_freight_ap := v_freight_ap + v_tax_amt;
          elsif v_tax_type= UPPER(jai_constants.tax_type_octroi) then
            v_octroi_ap := v_octroi_ap + v_tax_amt;
          else
            v_others_ap := v_others_ap + v_tax_amt;
          end if;

        end loop; --c_get_tax_from_ap_rec

        -- Get taxes from source doc PO / Receipt that are not brought over to AP

        -- get the conversion factor considering UOM, Quantity and Price change
        v_statement_id:= 11;
        v_conversion_factor := jai_ap_utils_pkg.get_apportion_factor(c_inv_select_rec.invoice_id, c_item_lines_rec.invoice_line_number);

        if nvl(v_conversion_factor, 0) = 0  then
          v_conversion_factor := 1;
        end if;


        -- If invoice currency and tax currency are different then conversion is required.

        if c_item_lines_rec.rcv_transaction_id is not null then

          v_statement_id:= 12;
            -- get from receipt.

          for c_receipt_tax_rec in c_get_tax_from_receipt
          (
          c_inv_select_rec.invoice_id,
          c_item_lines_rec.invoice_distribution_id,
          c_item_lines_rec.po_distribution_id,
          c_item_lines_rec.rcv_transaction_id
          )
          loop

            v_statement_id:= 13;
            v_tax_type := c_receipt_tax_rec.tax_type;
            v_tax_amt :=  c_receipt_tax_rec.tax_amount;


            v_tax_amt := v_tax_amt * v_conversion_factor;

            v_statement_id:= 14;
            if c_inv_select_rec.invoice_currency_code <> c_receipt_tax_rec.currency then
              v_tax_amt := v_tax_amt / c_inv_select_rec.exchange_rate;
            end if;


            if v_tax_type in (UPPER(jai_constants.tax_type_exc_additional), UPPER(jai_constants.tax_type_excise) ,UPPER(jai_constants.tax_type_exc_other)) then
              v_excise_po := v_excise_po + v_tax_amt;
            elsif v_tax_type= UPPER(jai_constants. tax_type_cst) then
              v_cst_po := v_cst_po + v_tax_amt;
            elsif v_tax_type = UPPER(jai_constants.tax_type_sales) then
              v_lst_po := v_lst_po + v_tax_amt;
            elsif v_tax_type = UPPER(jai_constants.tax_type_customs)  then
              v_customs_po := v_customs_po + v_tax_amt;
            elsif v_tax_type = UPPER(jai_constants.tax_type_cvd) then
              v_cvd_po := v_cvd_po + v_tax_amt;
	-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI
	-- START BUG 5228046
	    elsif v_tax_type = UPPER(jai_constants.tax_type_add_cvd) then
              v_addcvd_po :=v_addcvd_po + v_tax_amt;
	-- END BUG 5228046
	-- Date 24-Nov-2006 Forward porting Bug 5671126 added by Balaji
	--start
	      elsif v_tax_type = UPPER(jai_constants.tax_type_value_added) then
	  		    v_vat_po := v_vat_po + v_tax_amt;
	      elsif v_tax_type = UPPER(jai_constants.tax_type_purchase) then
	  		    v_pur_po := v_pur_po + v_tax_amt;
	      elsif v_tax_type = UPPER(jai_constants.tax_type_turnover) then
	  		    v_turnover_po := v_turnover_po + v_tax_amt;
	      elsif v_tax_type= UPPER(jai_constants.tax_type_entry) then
	  		    v_entry_po := v_entry_po + v_tax_amt;
	      elsif v_tax_type= UPPER(jai_constants.tax_type_service) then
	  		    v_service_po := v_service_po + v_tax_amt;
	      --end
            elsif v_tax_type= UPPER(jai_constants.tax_type_freight) then
              v_freight_po := v_freight_po + v_tax_amt;
            elsif v_tax_type = UPPER(jai_constants.tax_type_octroi) then
              v_octroi_po := v_octroi_po + v_tax_amt;
            else
              v_others_po := v_others_po + v_tax_amt;
            end if;

            v_statement_id:= 15;

          end loop; -- c_receipt_tax_rec

        else
          -- get from po

          for c_get_tax_from_po_rec in c_get_tax_from_po
          (
          c_inv_select_rec.invoice_id,
          c_item_lines_rec.invoice_distribution_id,
          c_item_lines_rec.po_distribution_id,
          c_item_lines_rec.rcv_transaction_id
          )

          loop

            v_statement_id:= 16;

            v_tax_type := c_get_tax_from_po_rec.tax_type;
            v_tax_amt :=  c_get_tax_from_po_rec.tax_amount;

            v_tax_amt := v_tax_amt * v_conversion_factor;

            v_statement_id:= 17;

            if c_inv_select_rec.invoice_currency_code <> c_get_tax_from_po_rec.currency then
              v_tax_amt := v_tax_amt / c_inv_select_rec.exchange_rate;
            end if;

            if v_tax_type in (UPPER(jai_constants.tax_type_exc_additional), UPPER(jai_constants.tax_type_excise) ,UPPER(jai_constants.tax_type_exc_other)) then
              v_excise_po := v_excise_po + v_tax_amt;
            elsif v_tax_type = UPPER(jai_constants. tax_type_cst) then
              v_cst_po := v_cst_po + v_tax_amt;
            elsif v_tax_type=UPPER(jai_constants.tax_type_sales) then
              v_lst_po := v_lst_po + v_tax_amt;
            elsif v_tax_type= UPPER(jai_constants.tax_type_customs)  then
              v_customs_po := v_customs_po + v_tax_amt;
            elsif v_tax_type = UPPER(jai_constants.tax_type_cvd) then
              v_cvd_po := v_cvd_po + v_tax_amt;
            elsif v_tax_type = UPPER(jai_constants.tax_type_add_cvd) then
              v_addcvd_po := v_addcvd_po + v_tax_amt ;
            elsif v_tax_type = UPPER(jai_constants.tax_type_freight) then
              v_freight_po := v_freight_po + v_tax_amt;
            elsif v_tax_type= UPPER(jai_constants.tax_type_octroi) then
              v_octroi_po := v_octroi_po + v_tax_amt;

            -- Date 24-Nov-2006 Forward porting Bug 5671126 added by Balaji
           --start

             elsif v_tax_type = upper(jai_constants.tax_type_value_added) then
                 v_vat_po := v_vat_po + v_tax_amt;
             elsif v_tax_type= upper(jai_constants.tax_type_purchase) then
                 v_pur_po := v_pur_po + v_tax_amt;
             elsif v_tax_type = upper(jai_constants.tax_type_turnover) then
                 v_turnover_po := v_turnover_po + v_tax_amt;
             elsif v_tax_type = upper(jai_constants.tax_type_entry) then
                 v_entry_po := v_entry_po + v_tax_amt;
             elsif v_tax_type = upper(jai_constants.tax_type_service) then
                 v_service_po := v_service_po + v_tax_amt;
             --end
            else
              v_others_po := v_others_po + v_tax_amt;
            end if;

            v_statement_id:= 18;

          end loop; -- c_get_tax_from_po_rec

        end if;

        v_statement_id:= 19;
        /* Modified the following insert statement to insert VAT amounts for bug#5096880, Ramesh.B.K, 23/03/2006 */
        -- Date 24-Nov-2006 Forward porting Bug 5671126 added by Balaji
        -- insert into the temp table with all the values.

        insert into JAI_PO_REP_PRRG_T
        (
        run_no,
        org_id,
        vendor_id,
        vendor_site_id,
        invoice_id,
        invoice_num,
        invoice_date,
        invoice_currency_code,
        exchange_rate,
        voucher_num,
        distribution_line_number,
        po_number,
        po_header_id,
        po_creation_date,
        po_distribution_id,
        po_release_num,
        receipt_number,
        receipt_date,
        rcv_transaction_id,
        line_amount,
        excise,
        customs,
        cvd,
	additional_cvd  , -- Date 01/11/2006 Bug 5228046 added by SACSETHI
        cst,
        lst,
        freight,
        octroi,
        -- Date 24-Nov-2006 Forward porting Bug 5671126 added by Balaji
        --start
        vat,
        service_tax,
	--end
        others,
        /* Bug 4866533. Added by Lakshmi gopalsami
        Added WHO columns */
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE
        )
        values
        (
        v_run_no,
        c_inv_select_rec.org_id  ,
        c_inv_select_rec.vendor_id,
        c_inv_select_rec.vendor_site_id,
        c_inv_select_rec.invoice_id,
        c_inv_select_rec.invoice_num,
        c_inv_select_rec.invoice_date,
        c_inv_select_rec.invoice_currency_code,
        c_inv_select_rec.exchange_rate,
        c_inv_select_rec.voucher_num,
        c_item_lines_rec.distribution_line_number,
        v_po_number,
        v_po_header_id,
        nvl(v_po_release_date, v_po_date),
        c_item_lines_rec.po_distribution_id,
        nvl(v_po_release_num, 0),
        v_receipt_num,
        v_receipt_date,
        c_item_lines_rec.rcv_transaction_id,
        c_item_lines_rec.amount,
        v_excise_ap +  v_excise_po,
        v_customs_ap + v_customs_po,
        v_cvd_ap + v_cvd_po,
        v_addcvd_ap + v_addcvd_po ,  -- Date 01/11/2006 Bug 5228046 added by SACSETHI
	v_cst_ap + v_cst_po,
        v_lst_ap + v_lst_po,
        v_freight_ap + v_freight_po,
        v_octroi_ap + v_octroi_po,
        -- Date 24-Nov-2006 Forward porting Bug 5671126 added by Balaji
        --start
        (NVL(v_vat_ap,0) + NVL(v_vat_po,0) +
	 NVL(v_turnover_ap,0) +
	 NVL(v_turnover_po,0) +
	 NVL(v_pur_ap,0)  +
	 NVL(v_pur_po,0) +
	 NVL(v_entry_ap,0)    +
	 NVL(v_entry_po,0)),
         v_service_ap  + v_service_po,
        --end
        v_others_ap + v_others_po,
        /* Bug 4866533. Added by Lakshmi Gopalsami
           Added WHO columns
        */
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate
        );


        v_statement_id:= 19;

      end loop; -- c_item_lines_rec

      v_statement_id:= 20;

    end loop;-- c_inv_select_cursor

    p_run_no := v_run_no;

  EXCEPTION
      when others then
          p_error_message := 'Error from Proc process_report(Statement id):'
                    || '(' || v_statement_id || ')' || sqlerrm;

  END process_report;
END jai_ap_rpt_prrg_pkg;

/
