--------------------------------------------------------
--  DDL for Package Body JAI_PO_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_HOOK_PKG" AS
/* $Header: jai_po_hook_pkg.plb 120.15.12010000.5 2010/02/26 11:53:45 srjayara ship $ */
  /*----------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY:             FILENAME: jai_po_hook_pkg.plb
  S.No    Date        Author and Details
  ------------------------------------------------------------------------------------------------------------------------
  1     18/04/2007    rchandan for bug#5961325, File Version 115.17
                      Issue: If the ASBN line is in foreign currency and the tax is in INR, the tax calculation
                             is not happening properly.
                        Fix: Modified calc_taxes procedure. Modified the cursor c_asbn_cur to include the currency
                             related fields.
                             Commented the call to ja_in_Calc_tax procedure and called ja_in_po_calc_tax procedure
 2      16-07-2007     iSupplier forward porting
                        Changed shipment_num to shipment_number
                             excise_inv_num to excise_inv_number in jai_cmn_lines table

 3      20-09-2007     iProcurement 6066485
                        Commented the currency conversion for ln_assessable_value

 4      27-11-2007     Jason Liu
                       Added two functions for iProcurement and iSupplier of Inclusive Tax

 5      03-APR-2009    Bug 8400813
                       In iSupplier - ASN related procedures, modified the logic to use header_interface_id
                       in addition to / instead of shipment number. This is being done to support the use of
                       same shipment number in different orgs.

 6     07-AUG-2009   Bug 8322323  File version 120.15.12010000.3 / 120.17
                                Issue - ASBN Tax Calculation goes wrong when UOM is changed during ASBN creation.
                                Fix - Added UOM conversion logic while populating JAI_CMN_LINES table. The changes are
                                        done in procedure populate_cmn_lines

 7     29-SEP-2009  Bug 8894051 File version 120.15.12010000.4 / 120.18
                    Issue - ASBN Tax calculation goes wrong if excise / vat assessable price is defined
		            for the item.
                    Cause - Assessable price was passed to the tax calculation procedure which expects
		            the assessable value (price * quantity) to be passed.
		    Fix - Multiplied the assessable price with quantity before calling the jai_po_tax_pkg.calc_tax
		          procedure.

 8      26-FEB-2010    Bug 9402712
                       Modified the gettax function - added quantity apportioning factor for document type 'RECEIPTS',
                       so that receipt corrections and returns will be considered while displaying the receipt tax
                       amount in PO details form.

  -------------------------------------------------------------------------------------------------------------------------*/

PROCEDURE calc_taxes
  (
    p_document_type IN VARCHAR2,
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    Errbuf          OUT NOCOPY VARCHAR2,
    RetCode         OUT NOCOPY VARCHAR2
  ) IS
    CURSOR reqn_cur IS
      SELECT *
        FROM po_requisition_lines_all
       WHERE requisition_header_id = p_header_id;

    CURSOR c_uom(pv_unit_of_measure VARCHAR2) IS
      SELECT uom_code
        FROM mtl_units_of_measure
       WHERE unit_of_measure = pv_unit_of_measure;

    CURSOR c_vend_cur(p_sugg_vendor_name IN VARCHAR2) IS
      SELECT vendor_id
        FROM po_vendors
       WHERE vendor_name = p_sugg_vendor_name;

    CURSOR c_vend_site_cur(p_sugg_vendor_loc IN VARCHAR2, p_vendor_id IN NUMBER, p_org_id IN NUMBER) IS
      SELECT Vendor_Site_Id
        FROM Po_Vendor_Sites_All A
       WHERE A.Vendor_Site_Code = p_sugg_vendor_loc
         AND A.Vendor_Id = p_vendor_id
         AND NVL(A.Org_Id, 0) = p_org_id;

    CURSOR c_sob(cp_org_id IN NUMBER) IS
      SELECT set_of_books_id
        FROM hr_operating_units
       WHERE organization_id = cp_org_id;

    CURSOR c_hdr_info IS
      SELECT *
        FROM Po_Requisition_Headers_V
       WHERE requisition_header_id = p_header_id;

    CURSOR rcpt_cur IS
      SELECT *
        FROM RCV_TRANSACTIONS
       WHERE shipment_header_id = p_header_id
         AND shipment_line_id = p_line_id
         AND transaction_type = 'RECEIVE';

    CURSOR c_rcpt_hdr IS
      SELECT *
        FROM RCV_SHIPMENT_HEADERS
       WHERE shipment_header_id = p_header_id;

    CURSOR c_rcpt_sob(p_inv_orgn_id NUMBER) IS
      SELECT operating_unit, set_of_books_id
        FROM org_organization_definitions
       WHERE organization_id = p_inv_orgn_id;

    CURSOR c_rcpt_line(p_line_id NUMBER) IS
      SELECT * FROM RCV_SHIPMENT_LINES WHERE shipment_line_id = p_line_id;

    -- pramasub start
    CURSOR c_asbn_cur(cp_hdr_intf_id IN NUMBER, cp_cmn_line_id IN NUMBER) IS
    SELECT lines.cmn_line_id,
           lines.header_interface_id,
           lines.interface_transaction_id transaction_id,
           lines.po_unit_price,
           lines.quantity,
           lines.item_id,
           rtxns.unit_of_measure,
           rtxns.vendor_id,
           rtxns.vendor_site_id,
           rtxns.creation_date,
           rtxns.po_header_id, /*rchandan for 5961325*/
           poll.price_override,
           --lines.CURRENCY_CODE,             /*rchandan for 5961325*/
--		  		 rtxns.CURRENCY_CONVERSION_TYPE,  /*rchandan for 5961325*/
--					 rtxns.CURRENCY_CONVERSION_RATE,  /*rchandan for 5961325*/
--           rtxns.CURRENCY_CONVERSION_DATE,  /*rchandan for 5961325*/
           poll.org_id                      /*rchandan for 5961325*/
      FROM JAI_CMN_LINES              lines,
           RCV_TRANSACTIONS_INTERFACE rtxns,
           po_line_locations_all      poll
     WHERE lines.interface_transaction_id =
           rtxns.interface_transaction_id
       AND lines.HEADER_INTERFACE_ID = rtxns.HEADER_INTERFACE_ID
       AND lines.po_line_location_id = poll.line_location_id
       AND lines.HEADER_INTERFACE_ID = cp_hdr_intf_id
       AND lines.CMN_LINE_ID = cp_cmn_line_id;

    -- pramasub end

    r_rcpt_line          c_rcpt_line%ROWTYPE;
    r_rcpt_hdr           c_rcpt_hdr%ROWTYPE;
    r_doc_hdr            c_hdr_info%ROWTYPE;
    r_rcpt_sob           c_rcpt_sob%ROWTYPE;
    ln_header_id         NUMBER;
    ln_line_id           NUMBER;
    ln_line_amount       NUMBER;
    lv_uom_code          VARCHAR2(20);
    ln_assessable_value  NUMBER;
    ln_vat_assess_value  NUMBER;
    ln_inventory_item_id NUMBER;
    ln_conv_rate         NUMBER;
    ln_vendor_id         NUMBER;
    ln_Vendor_site_id    NUMBER;
    ln_tax_amount        NUMBER;
    lv_line_currency     VARCHAR2(15);
    lv_rate_type         VARCHAR2(30);
    ln_gl_set_of_bks_id  NUMBER;
    ld_rate_date         DATE;
    lv_hdr_curr          VARCHAR2(15);
    ln_orig_line_amt     NUMBER;
    lv_document_type     VARCHAR2(100);
    ln_transaction_id    NUMBER;
    ln_unit_price        NUMBER;

    /*rchandan for 5961325..start*/

    CURSOR c_func_curr(cp_sob_id IN NUMBER) IS
    SELECT currency_code
    FROM   gl_sets_of_books
    WHERE  set_of_books_id = cp_sob_id;

    CURSOR cur_asbn_hdr(cp_header_id NUMBER) IS
    SELECT *
      FROM po_headers_all
     WHERE po_header_id = cp_header_id;

    asbn_hdr_rec    cur_asbn_hdr%ROWTYPE;


    ln_set_of_books_id   NUMBER;
    lv_func_curr         VARCHAR2(15);

    /*rchandan for 5961325..end*/

  BEGIN

    lv_document_type := p_document_type;

    IF lv_document_type = 'REQUISITION' THEN

      /*
      || Loop through each of the lines of the header.
      */

      OPEN c_hdr_info;
      FETCH c_hdr_info
        INTO r_doc_hdr;
      CLOSE c_hdr_info;

      lv_hdr_curr := r_doc_hdr.currency_code;

      FOR r_reqn_cur IN reqn_cur
      LOOP

        ln_header_id      := r_reqn_cur.requisition_header_id;
        ln_line_id        := r_reqn_cur.requisition_line_id;
        ln_line_amount    := NVL(r_reqn_cur.currency_unit_price,
                                 r_reqn_cur.unit_price) *
                             r_reqn_cur.quantity;
        ln_orig_line_amt  := NVL(r_reqn_cur.currency_unit_price,
                                 r_reqn_cur.unit_price) *
                             r_reqn_cur.quantity;
        lv_uom_code       := r_reqn_cur.unit_meas_lookup_code;
        ln_vendor_id      := r_reqn_cur.vendor_id;
        ln_vendor_site_id := r_reqn_cur.vendor_site_id;

        OPEN c_uom(r_reqn_cur.unit_meas_lookup_code);
        FETCH c_uom
          INTO lv_uom_code;
        CLOSE c_uom;

        /*
        || If the vendor Id and Vendor Site id populated in the table are null,
        || derive the values based on the suggested_Vendor_name and
        || suggested_vendor_location values.
        */

        IF ln_vendor_id IS NULL THEN
          OPEN c_vend_cur(r_reqn_cur.suggested_vendor_name);
          FETCH c_vend_Cur
            INTO ln_Vendor_id;
          CLOSE c_vend_cur;
        END IF;

        IF ln_vendor_site_id IS NULL THEN
          OPEN c_vend_site_cur(r_reqn_cur.suggested_vendor_location,
                               ln_Vendor_id,
                               r_reqn_cur.org_id);
          FETCH c_vend_site_cur
            INTO ln_Vendor_site_id;
          CLOSE c_vend_site_cur;
        END IF;

        lv_line_currency := r_reqn_cur.currency_code;
        lv_rate_type     := r_reqn_cur.rate_type;
        ld_rate_date     := r_reqn_cur.rate_date;
        ln_conv_rate     := r_reqn_cur.rate;

        OPEN c_sob(r_reqn_cur.org_id);
        FETCH c_sob
          INTO ln_gl_set_of_bks_id;
        CLOSE c_sob;

        lv_line_currency := NVL(lv_line_currency, lv_hdr_curr);

        IF NVL(lv_line_currency, '$') = NVL(lv_hdr_curr, '$') THEN
          ln_conv_rate := 1;
        ELSE
          IF lv_rate_type = 'User' THEN
            ln_conv_rate := ln_conv_rate;
          ELSE
            ln_conv_rate := jai_cmn_utils_pkg.currency_conversion(ln_gl_set_of_bks_id,
                                         lv_line_currency,
                                         ld_rate_date,
                                         lv_rate_type,
                                         ln_conv_rate);
          END IF;
        END IF;

        /*
        || For each of the line, calculate the Vat assessable value and excise assessable value.
        */

        ln_vat_assess_value := jai_general_pkg.ja_in_vat_assessable_value(P_PARTY_ID          => ln_vendor_id,
                                                                            P_PARTY_SITE_ID     => ln_vendor_site_id,
                                                                            P_INVENTORY_ITEM_ID => r_reqn_cur.item_id,
                                                                            P_UOM_CODE          => lv_uom_code,
                                                                            P_DEFAULT_PRICE     => ln_line_amount,
                                                                            P_ASS_VALUE_DATE    => r_reqn_cur.creation_date,
                                                                            P_PARTY_TYPE        => 'V');

        ln_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value(P_VENDOR_ID      => ln_vendor_id,
                                                            P_VENDOR_SITE_ID => ln_vendor_site_id,
                                                            P_INV_ITEM_ID    => r_reqn_cur.item_id,
                                                            P_LINE_UOM       => lv_uom_code);

        /*
        commented the next 2 lines - Internal QA issue
        */
        /*ln_assessable_value := NVL(ln_assessable_value, ln_line_amount) *
                               ln_conv_rate;
        ln_vat_assess_value := ln_vat_assess_value * ln_conv_rate;*/

        /*
        Call the routine that calculates the tax.
        */
        /*
                   ja_in_cal_tax
                   (
                    lv_document_type      ,     --   IN      P_TYPE
                    ln_header_id          ,     --   IN      P_HEADER_ID
                    ln_line_id            ,     --   IN      P_LINE_ID
                    -999                  ,     --   IN      P_LINE_LOC_ID
                    r_reqn_cur.quantity   ,     --   IN      P_LINE_QUANTITY
                    ln_line_amount        ,     --   IN      P_PRICE
                    lv_uom_code           ,     --   IN      P_LINE_UOM_CODE
                    ln_line_amount        ,     --   IN OUT  P_TAX_AMOUNT
                    ln_assessable_value   ,     --   IN      P_ASSESSABLE_VALUE
                    ln_vat_assess_value   ,     --   IN      P_VAT_ASSESS_VALUE
                    r_reqn_cur.item_id    ,     --   IN      P_ITEM_ID
                    ln_conv_rate                --   IN      P_CONV_RATE
                   );
        */

        jai_po_tax_pkg.calc_tax(p_type             => lv_document_type,
                          p_header_id        => ln_header_id,
                          P_line_id          => ln_line_id,
                          p_line_location_id => NULL,
                          p_line_focus_id    => NULL,
                          p_line_quantity    => r_reqn_cur.quantity,
                          p_base_value       => ln_line_amount,
                          p_line_uom_code    => lv_uom_code,
                          p_tax_amount       => ln_tax_amount,
                          p_assessable_value => ln_assessable_value,
                          p_vat_assess_value => ln_vat_assess_value,
                          p_item_id          => r_reqn_cur.item_id,
                          p_conv_rate        => ln_conv_rate,
                          p_po_curr          => lv_line_currency,
                          p_func_curr        => lv_hdr_curr);

        ln_tax_amount := ln_line_amount;

        UPDATE JAI_PO_REQ_LINES
           SET Last_Update_Date  = SYSDATE,
               tax_amount        = ln_tax_amount,
               total_amount      = ln_tax_amount + ln_orig_line_amt,
               Last_Updated_By   = r_reqn_cur.last_updated_by,
               Last_Update_Login = r_reqn_cur.last_update_login
         WHERE Requisition_Line_Id = ln_line_id
           AND Requisition_Header_Id = ln_header_id;

      END LOOP;

    ELSIF lv_document_type = 'RECEIPTS' THEN

      OPEN c_rcpt_hdr;
      FETCH c_rcpt_hdr
        INTO r_rcpt_hdr;
      CLOSE c_rcpt_hdr;

      lv_hdr_curr := r_rcpt_hdr.currency_code;

      FOR r_rcpt_cur IN rcpt_cur
      LOOP

        OPEN c_rcpt_line(r_rcpt_cur.shipment_line_id);
        FETCH c_rcpt_line
          INTO r_rcpt_line;
        CLOSE c_rcpt_line;

        ln_header_id      := r_rcpt_cur.shipment_header_id;
        ln_line_id        := r_rcpt_cur.shipment_line_id;
        ln_transaction_id := r_rcpt_cur.transaction_id;
        ln_line_amount    := r_rcpt_cur.po_unit_price * r_rcpt_cur.quantity;
        ln_orig_line_amt  := r_rcpt_cur.po_unit_price * r_rcpt_cur.quantity;
        lv_uom_code       := r_rcpt_cur.unit_of_measure;
        ln_vendor_id      := r_rcpt_cur.vendor_id;
        ln_vendor_site_id := r_rcpt_cur.vendor_site_id;

        lv_line_currency := r_rcpt_cur.currency_code;
        lv_rate_type     := r_rcpt_cur.currency_conversion_type;
        ld_rate_date     := r_rcpt_cur.currency_conversion_date;
        ln_conv_rate     := r_rcpt_cur.currency_conversion_rate;

        OPEN c_rcpt_sob(r_rcpt_cur.organization_id);
        FETCH c_rcpt_sob
          INTO r_rcpt_sob;
        CLOSE c_rcpt_sob;

        OPEN c_uom( r_rcpt_cur.unit_of_measure);
        FETCH c_uom
        INTO lv_uom_code;
        CLOSE c_uom;

        lv_line_currency := NVL(lv_line_currency, lv_hdr_curr);

        IF NVL(lv_line_currency, '$') = NVL(lv_hdr_curr, '$') THEN
          ln_conv_rate := 1;
        ELSE
          IF lv_rate_type = 'User' THEN
            ln_conv_rate := 1 / ln_conv_rate;
          ELSE
            ln_conv_rate := 1 / jai_cmn_utils_pkg.currency_conversion(r_rcpt_sob.set_of_books_id,
                                             lv_line_currency,
                                             ld_rate_date,
                                             lv_rate_type,
                                             ln_conv_rate);
          END IF;
        END IF;

        /*
        || For each of the line, calculate the Vat assessable value and excise assessable value.
        */

        ln_vat_assess_value := jai_general_pkg.ja_in_vat_assessable_value(P_PARTY_ID          => ln_vendor_id,
                                                                            P_PARTY_SITE_ID     => ln_vendor_site_id,
                                                                            P_INVENTORY_ITEM_ID => r_rcpt_line.item_id,
                                                                            P_UOM_CODE          => lv_uom_code,
                                                                            P_DEFAULT_PRICE     => ln_line_amount,
                                                                            P_ASS_VALUE_DATE    => r_rcpt_cur.creation_date,
                                                                            P_PARTY_TYPE        => 'V');

        ln_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value(P_VENDOR_ID      => ln_vendor_id,
                                                            P_VENDOR_SITE_ID => ln_vendor_site_id,
                                                            P_INV_ITEM_ID    => r_rcpt_line.item_id,
                                                            P_LINE_UOM       => lv_uom_code);

        /* This conversion is not required
        ln_assessable_value := NVL(ln_assessable_value, ln_line_amount) *
                               ln_conv_rate;
        ln_vat_assess_value := ln_vat_assess_value * ln_conv_rate;
     */
        /*
        Call the routine that calculates the tax.
        */

        jai_po_tax_pkg.calculate_tax(lv_document_type, --   IN      P_TYPE
                      ln_header_id, --   IN      P_HEADER_ID
                      ln_line_id, --   IN      P_LINE_ID
                      -999, --   IN      P_LINE_LOC_ID
                      r_rcpt_cur.quantity, --   IN      P_LINE_QUANTITY
                      ln_line_amount, --   IN      P_PRICE
                      lv_uom_code, --   IN      P_LINE_UOM_CODE
                      ln_line_amount, --   IN OUT  P_TAX_AMOUNT
                      ln_assessable_value, --   IN      P_ASSESSABLE_VALUE
                      ln_vat_assess_value, --   IN      P_VAT_ASSESS_VALUE
                      r_rcpt_line.item_id, --   IN      P_ITEM_ID
                      ln_conv_rate --   IN      P_CONV_RATE
                      );

        ln_tax_amount := ln_line_amount;

        UPDATE JAI_RCV_LINES
           SET Last_Update_Date  = SYSDATE,
               tax_amount        = ln_tax_amount,
               Last_Updated_By   = r_rcpt_line.last_updated_by,
               Last_Update_Login = r_rcpt_line.last_update_login
         WHERE shipment_Line_Id = ln_line_id
           AND shipment_Header_Id = ln_header_id;

      END LOOP;
      -- pramasub start
    ELSIF lv_document_type = 'ASBN' THEN

      /*OPEN   c_rcpt_hdr;
      FETCH  c_rcpt_hdr INTO r_rcpt_hdr;
      CLOSE  c_rcpt_hdr;

      lv_hdr_curr := r_rcpt_hdr.currency_code;*/

      FOR r_asbn_cur IN c_asbn_cur(p_header_id, p_line_id)
      LOOP

        IF nvl(r_asbn_cur.po_unit_price, 0) = 0 THEN
          ln_unit_price := r_asbn_cur.price_override;
        ELSE
          ln_unit_price := r_asbn_cur.po_unit_price;
        END IF;

        OPEN c_uom(r_asbn_cur.unit_of_measure);
        FETCH c_uom
          INTO lv_uom_code;
        CLOSE c_uom;

        ln_header_id      := r_asbn_cur.header_interface_id;
        ln_line_id        := r_asbn_cur.cmn_line_id;
        ln_transaction_id := r_asbn_cur.transaction_id;
        ln_line_amount    := ln_unit_price; /*bug 8894051*/
        ln_orig_line_amt  := ln_unit_price * r_asbn_cur.quantity;
        --lv_uom_code       := r_asbn_cur.unit_of_measure;
        ln_vendor_id      := r_asbn_cur.vendor_id;
        ln_vendor_site_id := r_asbn_cur.vendor_site_id;

        /*rchandan for 5961325...start*/

        OPEN  cur_asbn_hdr(r_asbn_cur.po_header_id);
        FETCH cur_asbn_hdr INTO asbn_hdr_rec;
        CLOSE cur_asbn_hdr;

        lv_line_currency  := asbn_hdr_rec.currency_code;
        lv_rate_type      := 'Corporate';
        ld_rate_date      := trunc(sysdate);
        ln_conv_rate      := asbn_hdr_rec.rate;

				OPEN c_sob(r_asbn_cur.org_id);
				FETCH c_sob INTO ln_set_of_books_id;
				CLOSE c_sob;

				OPEN c_func_curr(ln_set_of_books_id);
				FETCH c_func_curr INTO lv_func_curr;
				CLOSE c_func_curr;

        IF NVL(lv_line_currency,'$') = NVL(lv_func_curr,'$') THEN
           ln_conv_rate := 1;
        ELSE
           IF lv_rate_type = 'User' THEN
              ln_conv_rate := 1/ln_conv_rate;
           ELSE
              ln_conv_rate := 1/jai_cmn_utils_pkg.currency_conversion( ln_set_of_books_id, lv_line_currency, ld_rate_date, lv_rate_type, ln_conv_rate );
           END IF;
        END IF;

        /*rchandan for 5961325...end*/

        /*lv_line_currency     := r_rcpt_cur.currency_code ;
        lv_rate_type         := r_rcpt_cur.currency_conversion_type;
        ld_rate_date         := r_rcpt_cur.currency_conversion_date;
        ln_conv_rate         := r_rcpt_cur.currency_conversion_rate;

        OPEN   c_rcpt_sob (r_rcpt_cur.organization_id);
        FETCH  c_rcpt_sob into r_rcpt_sob;
        CLOSE  c_rcpt_sob;

        lv_line_currency := NVL(lv_line_currency,lv_hdr_curr);

        IF NVL(lv_line_currency,'$') = NVL(lv_hdr_curr,'$') THEN
           ln_conv_rate := 1;
        ELSE
           IF lv_rate_type = 'User' THEN
              ln_conv_rate := 1/ln_conv_rate;
           ELSE
              ln_conv_rate := 1/Ja_Curr_Conv( r_rcpt_sob.set_of_books_id, lv_line_currency, ld_rate_date, lv_rate_type, ln_conv_rate );
           END IF;
        END IF;*/

        /*
        || For each of the line, calculate the Vat assessable value and excise assessable value.
        */

        ln_vat_assess_value := jai_general_pkg.ja_in_vat_assessable_value(P_PARTY_ID          => ln_vendor_id,
                                                                            P_PARTY_SITE_ID     => ln_vendor_site_id,
                                                                            P_INVENTORY_ITEM_ID => r_asbn_cur.item_id,
                                                                            P_UOM_CODE          => lv_uom_code,
                                                                            P_DEFAULT_PRICE     => ln_line_amount,
                                                                            P_ASS_VALUE_DATE    => r_asbn_cur.creation_date,
                                                                            P_PARTY_TYPE        => 'V');

        ln_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value(P_VENDOR_ID      => ln_vendor_id,
                                                            P_VENDOR_SITE_ID => ln_vendor_site_id,
                                                            P_INV_ITEM_ID    => r_asbn_cur.item_id,
                                                            P_LINE_UOM       => lv_uom_code);

        --ln_assessable_value := NVL(ln_assessable_value ,ln_line_amount) * ln_conv_rate;
        --ln_vat_assess_value := ln_vat_assess_value * ln_conv_rate;
        ln_assessable_value := NVL(ln_assessable_value, ln_line_amount) * r_asbn_cur.quantity; /*bug 8894051*/
        ln_vat_assess_value := ln_vat_assess_value * r_asbn_cur.quantity; /*bug 8894051*/
	ln_line_amount := ln_line_amount * r_asbn_cur.quantity; /*bug 8894051*/
        /*
        Call the routine that calculates the tax.
        */
        /*
        ja_in_cal_tax(lv_document_type, --   IN      P_TYPE
                      ln_header_id, --   IN      P_HEADER_ID
                      ln_line_id, --   IN      P_LINE_ID
                      -999, --   IN      P_LINE_LOC_ID
                      r_asbn_cur.quantity, --   IN      P_LINE_QUANTITY
                      ln_line_amount, --   IN      P_PRICE
                      lv_uom_code, --   IN      P_LINE_UOM_CODE
                      ln_line_amount, --   IN OUT  P_TAX_AMOUNT
                      ln_assessable_value, --   IN      P_ASSESSABLE_VALUE
                      ln_vat_assess_value, --   IN      P_VAT_ASSESS_VALUE
                      r_asbn_cur.item_id, --   IN      P_ITEM_ID
                      --ln_conv_rate                --   IN      P_CONV_RATE
                      1);*//*commented by rchandan for 5961325 and added call to ja_in_po_calc_tax*/

        jai_po_tax_pkg.calc_tax(p_type             => lv_document_type,
                          p_header_id        => ln_header_id,
                          P_line_id          => ln_line_id,
                          p_line_location_id => NULL,
                          p_line_focus_id    => NULL,
                          p_line_quantity    => r_asbn_cur.quantity,
                          p_base_value       => ln_line_amount,
                          p_line_uom_code    => lv_uom_code,
                          p_tax_amount       => ln_tax_amount,
                          p_assessable_value => ln_assessable_value,
                          p_vat_assess_value => ln_vat_assess_value,
                          p_item_id          => r_asbn_cur.item_id,
                          p_conv_rate        => ln_conv_rate,
                          p_po_curr          => lv_line_currency,
                          p_func_curr        => NULL);

        --ln_tax_amount := ln_line_amount;

      /*UPDATE JAI_RCV_LINES
                                                                                                                                                                 SET    Last_Update_Date      = sysdate,
                                                                                                                                                                        tax_amount            = ln_tax_amount ,
                                                                                                                                                                        Last_Updated_By       = r_rcpt_line.last_updated_by,
                                                                                                                                                                        Last_Update_Login     = r_rcpt_line.last_update_login
                                                                                                                                                                 WHERE  shipment_Line_Id      = ln_line_id
                                                                                                                                                                 AND    shipment_Header_Id    = ln_header_id;*/

      END LOOP;
      -- pramasub end
    END IF;
    errbuf  := NULL;
    RetCode := '0';

  EXCEPTION
    WHEN OTHERS THEN
      Errbuf  := SQLERRM;
      RetCode := '2';
  END calc_taxes;

  PROCEDURE update_rcv_trxs(P_transaction_id IN NUMBER) IS
  BEGIN
    UPDATE rcv_transactions
       SET attribute4 = 'Y', attribute_category = 'India Return to Vendor'
     WHERE transaction_id = P_transaction_id;

  END update_rcv_trxs;

  PROCEDURE update_cmn_lines
  (
    p_shipment_num IN VARCHAR2,
    p_ex_inv_num   IN VARCHAR2,
    p_ex_inv_date  IN date,
    p_header_interface_id IN NUMBER DEFAULT NULL,  /*bug 8400813*/
    errbuf         OUT NOCOPY VARCHAR2,
    retcode        OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    UPDATE jai_cmn_lines
       SET excise_inv_number = p_ex_inv_num, excise_inv_date = p_ex_inv_date
     WHERE shipment_number = p_shipment_num
       AND (p_header_interface_id IS NULL OR  /*bug 8400813*/
           (p_header_interface_id IS NOT NULL AND header_interface_id = p_header_interface_id));

    errbuf  := NULL;
    retcode := '0';

  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := SQLERRM;
      retcode := '2';
  END update_cmn_lines;

  PROCEDURE update_jrcv_flags
  (
    P_transaction_id IN NUMBER,
    p_process_Action VARCHAR2
  ) IS

    lv_process_flag VARCHAR2(1);
  BEGIN

    IF p_process_Action = 'Y' THEN
      lv_process_flag := 'N';
    ELSIF p_process_Action = 'N' THEN
      lv_process_flag := 'P';
    END IF;

    UPDATE JAI_RCV_TRANSACTIONS
       SET process_status      = lv_process_flag,
           cenvat_rg_status    = lv_process_flag,
           cenvat_rg_message = NULL,
           process_vat_status  = lv_process_flag
     WHERE transaction_id = P_transaction_id;
  END update_jrcv_flags;

  PROCEDURE PROCESS_RECEIPT
  (
    p_shipment_header_id IN NUMBER,
    p_transaction_id     IN NUMBER DEFAULT NULL,
    p_process_Action     IN VARCHAR2 DEFAULT NULL,
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2
  ) IS

    lv_errbuf          VARCHAR2(4000);
    lv_retCode         VARCHAR2(100);
    ln_organization_id NUMBER;

    CURSOR c_rcpt_cur IS
      SELECT *
        FROM JAI_RCV_LINES
       WHERE shipment_header_id = p_shipment_header_id;

    r_rcpt_rec  c_rcpt_cur%ROWTYPE;
    ln_batch_id NUMBER;

    lv_called_from VARCHAR2(30);

  BEGIN

    OPEN c_rcpt_cur;
    FETCH c_rcpt_cur
      INTO r_rcpt_rec;
    CLOSE c_rcpt_cur;

    lv_called_from := 'JAINPORE';

    IF p_process_Action = 'Y'
       AND p_transaction_id IS NOT NULL THEN
      lv_called_from := 'RECEIPT_TAX_INSERT_TRG';
      update_rcv_trxs(p_transaction_id);
      update_jrcv_flags(p_transaction_id, p_process_Action);
    ELSIF p_process_Action = 'N'
          AND p_transaction_id IS NOT NULL THEN
      update_jrcv_flags(p_transaction_id, p_process_Action);
      lv_called_from := 'RECEIPT_TAX_INSERT_TRG';
    END IF;

    jai_rcv_trx_processing_pkg.process_batch(ERRBUF               => lv_errbuf,
                                                 RETCODE              => lv_retCode,
                                                 P_ORGANIZATION_ID    => r_rcpt_rec.organization_id,
                                                 PV_TRANSACTION_FROM   => NULL,
                                                 PV_TRANSACTION_TO     => NULL,
                                                 P_TRANSACTION_TYPE   => NULL,
                                                 P_PARENT_TRX_TYPE    => NULL,
                                                 P_SHIPMENT_HEADER_ID => p_shipment_header_id,
                                                 P_RECEIPT_NUM        => NULL,
                                                 P_SHIPMENT_LINE_ID   => NULL,
                                                 P_TRANSACTION_ID     => p_transaction_id,
                                                 P_COMMIT_SWITCH      => 'Y',
                                                 P_CALLED_FROM        => lv_called_from,
                                                 P_SIMULATE_FLAG      => 'N',
                                                 P_TRACE_SWITCH       => NULL,
                                                 P_REQUEST_ID         => NULL,
                                                 P_GROUP_ID           => NULL);

    IF lv_errbuf IS NOT NULL THEN
      /* Error Reported */
      errbuf  := lv_errbuf;
      retCode := lv_retCode;
    ELSE
      errbuf  := NULL;
      retCode := '0';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := SQLERRM;
      retCode := '2';

  END PROCESS_RECEIPT;

  PROCEDURE populate_cmn_taxes
  (
    p_po_header_id     IN NUMBER,
    p_line_location_id IN NUMBER,
    p_hdr_intf_id      IN NUMBER,
    p_cmn_line_id      IN NUMBER,
    p_quantity         IN NUMBER,
    p_tot_quantity     IN NUMBER
  ) IS

    CURSOR c_tax_codes(cp_tax_id IN NUMBER) IS
      SELECT * FROM JAI_CMN_TAXES_ALL WHERE tax_id = cp_tax_id;

    CURSOR c_conv_rate_rfq(cp_header_id IN NUMBER) IS
      SELECT rate, currency_code
        FROM po_headers_all
       WHERE po_header_id = cp_header_id;

    r_taxes          c_tax_codes%ROWTYPE;
    ln_conv_rate     NUMBER;
    lv_line_currency VARCHAR2(20);
    ln_func_Tax_amt  NUMBER;
    ln_rnd_factor    NUMBER;
    ln_tax_Amount    NUMBER;

  BEGIN
    ln_rnd_factor := 0;
    ln_tax_Amount := -1;
    OPEN c_conv_rate_rfq(p_po_header_id);
    FETCH c_conv_rate_rfq
      INTO ln_conv_rate, lv_line_currency;
    CLOSE c_conv_rate_rfq;

    IF ln_conv_rate IS NULL THEN
      ln_conv_rate := 1;
    END IF;

    FOR j_po_ll_rec IN (SELECT *
                          FROM JAI_PO_TAXES
                         WHERE line_location_id = p_line_location_id)
    LOOP
      OPEN c_tax_codes(j_po_ll_rec.TAX_ID);
      FETCH c_tax_codes
        INTO r_taxes;
      CLOSE c_tax_codes;

      IF r_taxes.rounding_factor IS NOT NULL THEN
        ln_rnd_factor := r_taxes.rounding_factor;
      END IF;
      IF p_tot_quantity > 0 THEN
        ln_tax_Amount := round((p_quantity / p_tot_quantity *
                               j_po_ll_rec.TAX_AMOUNT),
                               ln_rnd_factor);
      END IF;

      IF NVL(lv_line_currency, '$$$') <> NVL(j_po_ll_rec.CURRENCY, '$$$') THEN
        ln_func_Tax_amt := j_po_ll_rec.TAX_AMOUNT * ln_conv_rate;
      END IF;

      INSERT INTO JAI_CMN_DOCUMENT_TAXES
        (DOC_TAX_ID,
         TAX_LINE_NO,
         TAX_ID,
         TAX_TYPE,
         CURRENCY_CODE,
         TAX_RATE,
         QTY_RATE,
         UOM,
         TAX_AMT,
         FUNC_TAX_AMT,
         MODVAT_FLAG,
         TAX_CATEGORY_ID,
         SOURCE_DOC_TYPE,
         SOURCE_DOC_ID,
         SOURCE_DOC_LINE_ID,
         SOURCE_TABLE_NAME,
         ADHOC_FLAG,
         PRECEDENCE_1,
         PRECEDENCE_2,
         PRECEDENCE_3,
         PRECEDENCE_4,
         PRECEDENCE_5,
         PRECEDENCE_6,
         PRECEDENCE_7,
         PRECEDENCE_8,
         PRECEDENCE_9,
         PRECEDENCE_10,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         VENDOR_ID)
      VALUES
        (JAI_CMN_DOCUMENT_TAXES_s.NEXTVAL,
         j_po_ll_rec.TAX_LINE_NO,
         j_po_ll_rec.TAX_ID,
         j_po_ll_rec.TAX_TYPE,
         j_po_ll_rec.CURRENCY,
         j_po_ll_rec.TAX_RATE,
         j_po_ll_rec.QTY_RATE,
         j_po_ll_rec.UOM,
         ln_tax_Amount,
         ln_func_Tax_amt,
         j_po_ll_rec.MODVAT_FLAG,
         j_po_ll_rec.TAX_CATEGORY_ID,
         'ASBN',
         p_hdr_intf_id,
         p_cmn_line_id,
         'JAI_PO_TAXES',
         r_taxes.adhoc_flag,
         j_po_ll_rec.PRECEDENCE_1,
         j_po_ll_rec.PRECEDENCE_2,
         j_po_ll_rec.PRECEDENCE_3,
         j_po_ll_rec.PRECEDENCE_4,
         j_po_ll_rec.PRECEDENCE_5,
         j_po_ll_rec.PRECEDENCE_6,
         j_po_ll_rec.PRECEDENCE_7,
         j_po_ll_rec.PRECEDENCE_8,
         j_po_ll_rec.PRECEDENCE_9,
         j_po_ll_rec.PRECEDENCE_10,
         SYSDATE,
         fnd_global.user_id,
         SYSDATE,
         fnd_global.user_id,
         fnd_global.login_id,
         j_po_ll_rec.VENDOR_ID);
    END LOOP;

    /*   errbuf := NULL;
    RetCode := '0';
    EXCEPTION
      WHEN OTHERS THEN
        Errbuf := sqlerrm;
        RetCode := '2';*/
  END populate_cmn_taxes;

  PROCEDURE Populate_cmn_lines
  (
    p_hdr_intf_id  IN NUMBER,
    p_invoice_num  IN VARCHAR2,
    p_invoice_date IN DATE,
    errbuf         OUT NOCOPY VARCHAR2,
    retcode        OUT NOCOPY VARCHAR2
  ) IS
    CURSOR c_txns_interface(cp_hdr_intf_id IN NUMBER) IS
    /*select  *
                                                                                                          from    rcv_transactions_interface
                                                                                                          where   HEADER_INTERFACE_ID = cp_hdr_intf_id;*/
      SELECT rtxn.*,
             (SELECT currency_code
                FROM po_headers_all
               WHERE po_header_id = rtxn.po_header_id) CUR_CODE,
             (SELECT quantity
                FROM po_line_locations_all
               WHERE LINE_LOCATION_ID = rtxn.PO_LINE_LOCATION_ID) TOT_QUANTITY
        FROM rcv_transactions_interface rtxn
       WHERE rtxn.HEADER_INTERFACE_ID = cp_hdr_intf_id;

    CURSOR c_hdr_interface(cp_hdr_intf_id IN NUMBER) IS
      SELECT shipment_num
        FROM rcv_headers_interface
       WHERE HEADER_INTERFACE_ID = cp_hdr_intf_id;

    CURSOR c_po_hdr_currency(cp_po_header_id IN NUMBER) IS
      SELECT CURRENCY_CODE
        FROM PO_HEADERS
       WHERE PO_HEADER_ID = cp_po_header_id;

    CURSOR c_po_line_loc_details(cp_line_location_id IN NUMBER) IS
      SELECT *
        FROM po_line_locations_all
       WHERE line_location_id = cp_line_location_id;

    r_line_locations c_po_line_loc_details%ROWTYPE;

    --r_txns c_txns_interface%rowtype;
    r_hdrs         c_hdr_interface%ROWTYPE;
    ln_cmn_line_id NUMBER;
    lv_ship_num    VARCHAR2(30);
    lv_errbuf      VARCHAR2(2000);
    lv_retcode     VARCHAR2(200);

    /*bug 8322323*/
    CURSOR c_uom(pv_unit_of_measure VARCHAR2) IS
    SELECT uom_code
    FROM mtl_units_of_measure
    WHERE unit_of_measure = pv_unit_of_measure;

    lv_po_uom VARCHAR2(10);
    lv_asbn_uom VARCHAR2(10);
    ln_uom_conv_factor NUMBER;
    /*end bug 8322323*/

  BEGIN
    OPEN c_hdr_interface(p_hdr_intf_id);
    FETCH c_hdr_interface
      INTO r_hdrs;
    CLOSE c_hdr_interface;

    lv_ship_num := r_hdrs.shipment_num;

    FOR r_txns IN c_txns_interface(p_hdr_intf_id)
    LOOP
      /*ln_cmn_line_id := JAI_CMN_LINES_S.nextval;*/
      SELECT JAI_CMN_LINES_S.NEXTVAL INTO ln_cmn_line_id FROM DUAL;

      OPEN c_po_line_loc_details(r_txns.po_line_location_id);
      FETCH c_po_line_loc_details
        INTO r_line_locations;
      CLOSE c_po_line_loc_details;

      /*bug 8322323*/
      ln_uom_conv_factor := 1;
      OPEN c_uom(r_line_locations.unit_meas_lookup_code);
      FETCH c_uom INTO lv_po_uom;
      CLOSE c_uom;

      OPEN c_uom(r_txns.unit_of_measure);
      FETCH c_uom INTO lv_asbn_uom;
      CLOSE c_uom;

      ln_uom_conv_factor := inv_convert.inv_um_convert(r_txns.item_id, lv_po_uom, lv_asbn_uom);
      /*end bug 8322323*/

      INSERT INTO JAI_CMN_LINES
        (CMN_LINE_ID,
         SHIPMENT_NUMBER,
         PO_HEADER_ID,
         PO_LINE_ID,
         PO_LINE_LOCATION_ID,
         PO_NUMBER,
         LINE_NUM,
         SHIPMENT_LINE_NUM,
         HEADER_INTERFACE_ID,
         SHIPMENT_HEADER_ID,
         INTERFACE_TRANSACTION_ID,
         SHIPMENT_LINE_ID,
         ITEM_ID,
         QUANTITY,
         EXCISE_INV_NUMBER,
         EXCISE_INV_DATE,
         CURRENCY_CODE,
         PO_UNIT_PRICE,
         UOM_CODE)  /*bug 8322323*/
         VALUES (ln_cmn_line_id,
         lv_ship_num,
         --r_txns.SHIPMENT_NUM,
         r_txns.PO_HEADER_ID,
         r_txns.PO_LINE_ID,
         r_txns.PO_LINE_LOCATION_ID,
         r_txns.DOCUMENT_NUM,
         r_txns.DOCUMENT_LINE_NUM,
         r_txns.DOCUMENT_SHIPMENT_LINE_NUM,
         r_txns.HEADER_INTERFACE_ID,
         r_txns.SHIPMENT_HEADER_ID,
         r_txns.INTERFACE_TRANSACTION_ID,
         r_txns.SHIPMENT_LINE_ID,
         r_txns.ITEM_ID,
         r_txns.QUANTITY,
         p_invoice_num,
         p_invoice_date,
         r_txns.CUR_CODE,
         nvl(r_txns.PO_UNIT_PRICE, r_line_locations.price_override) / ln_uom_conv_factor,   /*bug 8322323*/
         lv_asbn_uom);  /*bug 8322323*/

      JAI_PO_HOOK_PKG.populate_cmn_taxes(r_txns.PO_HEADER_ID,
                                         r_txns.PO_LINE_LOCATION_ID,
                                         r_txns.HEADER_INTERFACE_ID,
                                         ln_cmn_line_id,
                                         r_txns.QUANTITY,
                                         r_txns.TOT_QUANTITY*ln_uom_conv_factor);  /*bug 8322323*/

     -- following call added by ssumaith - bug#3637364
     -- it was done so that the taxes are re-calculated after the insert is done
     JAI_PO_HOOK_PKG.calc_taxes('ASBN',r_txns.HEADER_INTERFACE_ID,ln_cmn_line_id,lv_errbuf,lv_retcode);

    END LOOP;
    errbuf  := NULL;
    RetCode := '0';

  EXCEPTION
    WHEN OTHERS THEN
      Errbuf  := SQLERRM;
      RetCode := '2';
  END Populate_cmn_lines;

  PROCEDURE POPULATE_CMN_LINES_ON_UPLOAD
(
 p_hdr_intf_id  IN NUMBER,
 errbuf         OUT NOCOPY VARCHAR2,
 retcode        OUT NOCOPY VARCHAR2
) IS
CURSOR c_hdr_intf(cp_grp_id IN NUMBER) IS
 select shipment_num, asn_type, header_interface_id
 from rcv_headers_interface
 where group_id = cp_grp_id;

 lv_errbuf1      VARCHAR2(2000);
 lv_retcode1     VARCHAR2(200);
 lv_errbuf      VARCHAR2(2000);
 lv_retcode     VARCHAR2(200);
 e1 exception;
 e2 exception;
BEGIN
 For r_hdr in c_hdr_intf(p_hdr_intf_id)
 Loop
   JAI_PO_HOOK_PKG.POPULATE_CMN_LINES(r_hdr.header_interface_id,NULL,NULL,lv_errbuf,lv_retcode);
   IF lv_retcode <> '0' THEN
	 raise e1;
   END IF;
   --IF r_hdr.asn_type = 'ASBN' THEN
	 JAI_PO_HOOK_PKG.UPDATE_ASBN_MODE(r_hdr.shipment_num,'PENDING',r_hdr.header_interface_id,lv_errbuf1,lv_retcode1);  /*bug 8400813*/
   --end if;
   IF lv_retcode1 <> '0' THEN
	 raise e2;
   END IF;
 End loop;
   errbuf  := NULL;
   RetCode := '0';

 EXCEPTION
   WHEN e1 THEN
	 Errbuf  := lv_errbuf;
	 RetCode := '2';
   WHEN e2 THEN
	 Errbuf  := lv_errbuf1;
	 RetCode := '2';
   WHEN OTHERS THEN
	 Errbuf  := SQLERRM;
	 RetCode := '2';
END POPULATE_CMN_LINES_ON_UPLOAD;


  PROCEDURE UPDATE_RCV_TXN
  (
    P_transaction_id IN NUMBER,
    p_invoice_num    IN VARCHAR2,
    P_invoice_date   IN VARCHAR2,
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY VARCHAR2
  ) IS
    lv_attr_categ VARCHAR2(30) := 'India Receipt';
  BEGIN
    UPDATE RCV_TRANSACTIONS_INTERFACE
       SET ATTRIBUTE_CATEGORY = lv_attr_categ,
           ATTRIBUTE1         = p_invoice_num,
           ATTRIBUTE2         = P_invoice_date
     WHERE INTERFACE_TRANSACTION_ID = P_transaction_id;

    errbuf  := NULL;
    RetCode := '0';
  EXCEPTION
    WHEN OTHERS THEN
      Errbuf  := SQLERRM;
      RetCode := '2';
  END UPDATE_RCV_TXN;




  FUNCTION gettax
  (
    p_document_type IN VARCHAR2,
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER
  ) RETURN NUMBER IS
    /* Get the requisition tax amount for each requisition line currency code wise*/
    CURSOR c_reqn_tax_amt IS
      SELECT rtl.requisition_line_id, rtl.currency, rtl.tax_amount, nvl(tax.rounding_factor, 0) rnd_factor
        FROM JAI_PO_REQ_LINE_TAXES rtl, JAI_CMN_TAXES_ALL tax , po_requisition_lines_all porl
       WHERE rtl.requisition_header_id = p_header_id
         AND (rtl.requisition_line_id = p_line_id OR p_line_id IS NULL)
         AND porl.requisition_line_id = rtl.requisition_line_id
	 AND tax.tax_id = rtl.tax_id
       ORDER BY rtl.currency;
    /* Get the receipt tax amount for each shipment line currency code wise*/
    CURSOR c_rcpt_tax_amt IS
      SELECT shipment_line_id, currency, SUM(tax_amount) tax_amount
        FROM JAI_RCV_LINE_TAXES
       WHERE shipment_header_id = p_header_id
         AND (shipment_line_id = p_line_id OR p_line_id IS NULL)
       GROUP BY shipment_line_id, currency;
    /* Get the conversion rate for the  currency code for the requisition line */
    CURSOR c_conv_Rate(cp_reqn_line_id NUMBER) IS
      SELECT rate, currency_code, cancel_flag, org_id
        FROM po_requisition_lines_all
       WHERE requisition_line_id = cp_reqn_line_id;
    /* Get the conversion rate for the  currency code for the receipt shipment line */
    CURSOR c_conv_rate_rcpt(cp_shipment_line_id IN NUMBER) IS
      SELECT currency_conversion_rate, currency_code
        FROM rcv_transactions
       WHERE shipment_line_id = cp_shipment_line_id
         AND transaction_type = 'RECEIVE';
    /* Get the RFQ / PO / BPA  tax amount for each line location currency code wise*/
    CURSOR c_po_rfq IS
      SELECT line_location_id, currency, SUM(tax_amount) tax_amount
        FROM JAI_PO_TAXES
       WHERE po_header_id = p_header_id
         AND (line_location_id = p_line_id OR p_line_id IS NULL)
       GROUP BY line_location_id, currency;

    /* Get the conversion rate for the  currency code for the PO / RFQ */
    CURSOR c_conv_rate_rfq(cp_header_id IN NUMBER) IS
      SELECT rate, currency_code
        FROM po_headers
       WHERE po_header_id = cp_header_id;

    -- pramasub start
    CURSOR c_conv_rate_inv(cp_header_id IN NUMBER, cp_line_id IN NUMBER) IS
      SELECT exchange_rate, currency_code
        FROM JAI_AP_MATCH_INV_TAXES
       WHERE  invoice_id = cp_header_id
       And parent_invoice_distribution_id = cp_line_id;
    -- pramasub end


    CURSOR c_inv_amt IS
      SELECT SUM(amount)
        FROM ap_invoice_distributions_all
       WHERE invoice_id = p_header_id
         AND line_type_lookup_code = 'MISCELLANEOUS';

    CURSOR c_sob_curr(cp_org_id NUMBER) IS
      SELECT currency_code
        FROM gl_sets_of_booKs
       WHERE set_of_books_id IN
             (SELECT set_of_books_id
                FROM hr_operating_units
               WHERE organization_id = cp_org_id);

    /*bug 9402712*/
    CURSOR c_qty_factor(cp_shipment_line_id NUMBER) IS
    SELECT Nvl(quantity_received,1)/Nvl(quantity_shipped,1)
    FROM rcv_shipment_lines
    WHERE shipment_line_id = cp_shipment_line_id;

    ln_qty_factor NUMBER;
    /*end bug 9402712*/

    -- pramasub start
    CURSOR c_cmn_doc_taxes(cp_cmn_line_id IN NUMBER, cp_doc_type IN VARCHAR2) IS
      SELECT source_doc_line_id, currency_code, SUM(tax_amt) tax_amount
        FROM JAI_CMN_DOCUMENT_TAXES
       WHERE source_doc_line_id = cp_cmn_line_id
         AND source_doc_type = cp_doc_type
       GROUP BY source_doc_line_id, currency_code;
    -- pramasub end

    CURSOR c_conv_rate_asbn(cp_cmn_line_id IN NUMBER) IS
      SELECT PHA.rate, PHA.currency_code
        FROM PO_HEADERS_ALL PHA
       WHERE PHA.PO_HEADER_ID =
             (SELECT PO_HEADER_ID
                FROM JAI_CMN_LINES
               WHERE CMN_LINE_ID = cp_cmn_line_id);

    ln_Tax_amt       NUMBER;
    lv_curr_tax_amt  NUMBER;
    ln_conv_rate     NUMBER;
    lv_line_Currency VARCHAR2(15);
    lv_cancel_flag   VARCHAR2(1);
    lv_func_currency VARCHAR2(15);
    ln_org_id        NUMBER;

  BEGIN

    ln_tax_amt := 0;
    IF p_document_Type = 'REQUISITION' THEN

      FOR r_reqn_rec IN c_reqn_tax_amt
      LOOP

        OPEN c_conv_Rate(r_reqn_rec.requisition_line_id);
        FETCH c_conv_Rate
          INTO ln_conv_rate, lv_line_Currency, lv_cancel_flag, ln_org_id;
        CLOSE c_conv_Rate;

        IF ln_org_id IS NOT NULL THEN
          /* just fetch it once*/
          OPEN c_sob_curr(ln_org_id);
          FETCH c_sob_curr
            INTO lv_func_currency;
          CLOSE c_sob_curr;
        END IF;

        IF nvl(lv_cancel_flag, '$') <> 'Y' THEN

          IF p_line_id IS NOT NULL THEN

            /*
            || Tax currency not same as line currency means tax currency = func currency
            */
            IF NVL(r_reqn_rec.currency, '$$$') <>
               NVL(lv_line_currency, '$$$') THEN
              IF ln_conv_rate IS NULL THEN
                ln_conv_rate := 1;
              END IF;
            ELSE
              ln_conv_rate := 1;
            END IF;

            /*
            || being called at line level . need to show tax in line currency.
            || if tax amt is in func curr , then the conv rate will be a actual value
            || hence divide would cause the tax to show in po currency

            || if tax amt is in func curr , then the conv rate = 1
            */
            ln_tax_amt := nvl(ln_tax_amt, 0) +
                          round(((r_reqn_rec.tax_amount) / ln_conv_rate),r_reqn_rec.rnd_factor);
          ELSE
            /*
            || being called from header - need to show the tax in func currency.
            || tax currency same as func currency
            */
            IF NVL(r_reqn_rec.currency, '$$$') =
               NVL(lv_func_currency, '$$$') THEN
              ln_tax_amt := nvl(ln_tax_amt, 0) + (r_reqn_rec.tax_amount);
            ELSE
              ln_tax_amt := nvl(ln_tax_amt, 0) +
                            round((r_reqn_rec.tax_amount *nvl( ln_conv_Rate,1)),r_reqn_rec.rnd_factor); -- nvl correction made by pramasub #6066485
            END IF;
          END IF;

        END IF;

      END LOOP;

    ELSIF p_document_type = 'RECEIPTS' THEN

      FOR r_rcpt_rec IN c_rcpt_tax_amt

      LOOP
        OPEN c_conv_rate_rcpt(r_rcpt_rec.shipment_line_id);
        FETCH c_conv_rate_rcpt
          INTO ln_conv_rate, lv_line_currency;
        CLOSE c_conv_rate_rcpt;

        /*bug 9402712*/
        OPEN c_qty_factor(r_rcpt_rec.shipment_line_id);
        FETCH c_qty_factor INTO ln_qty_factor;
        CLOSE c_qty_factor;
        /*end bug 9402712*/

        IF NVL(r_rcpt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$') THEN
          IF ln_conv_rate IS NULL THEN
            ln_conv_rate := 1;
          END IF;
        ELSE
          ln_conv_rate := 1;
        END IF;

        ln_tax_amt := nvl(ln_tax_amt, 0) +
                      ( (r_rcpt_rec.tax_amount * ln_qty_factor /*for bug 9402712*/) / ln_conv_rate);
      END LOOP;

    ELSIF p_document_Type IN ('RFQ', 'PO', 'BPA') THEN

      OPEN c_conv_rate_rfq(p_header_id);
      FETCH c_conv_rate_rfq
        INTO ln_conv_rate, lv_line_currency;
      CLOSE c_conv_rate_rfq;

      FOR r_rfq_po_rec IN c_po_rfq
      LOOP
        IF NVL(r_rfq_po_rec.currency, '$$$') <>
           NVL(lv_line_currency, '$$$') THEN
          IF ln_conv_rate IS NULL THEN
            ln_conv_rate := 1;
          END IF;
        ELSE
          ln_conv_rate := 1;
        END IF;

        ln_tax_amt := nvl(ln_tax_amt, 0) +
                      (ln_conv_rate * (r_rfq_po_rec.tax_amount));

      END LOOP;

    ELSIF p_document_Type IN ('SHIPMENT', 'RELEASE', 'PO_LINE') THEN

      /*
      || p_document_type = 'RELEASE'  - p_header_id = po_header_id , po_line_id = release_id
      || p_document_type = 'SHIPMENT' - p_header_id = po_header_id , po_line_id = p_line_location_id
      || p_document_type = 'PO_LINE'  - p_header_id = po_header_id , po_line_id = p_line_id
      */

      OPEN c_conv_rate_rfq(p_header_id);
      FETCH c_conv_rate_rfq
        INTO ln_conv_rate, lv_line_currency;
      CLOSE c_conv_rate_rfq;

      IF p_document_Type = 'SHIPMENT' THEN

        /*
        || We would have got the po_header_id and line_location_id
        || we will get the details from the JAI_PO_TAXES table.
        */

        ln_tax_amt := 0;

        FOR r_shipment_rec IN (SELECT currency, SUM(tax_amount) tax_amount
                                 FROM JAI_PO_TAXES
                                WHERE line_location_id = p_line_id
                                GROUP BY currency)
        LOOP

          IF NVL(r_shipment_rec.currency, '$$$') <>
             NVL(lv_line_currency, '$$$') THEN
            IF ln_conv_rate IS NULL THEN
              ln_conv_rate := 1;
            END IF;
          ELSE
            ln_conv_rate := 1;
          END IF;

          ln_tax_amt := nvl(ln_tax_amt, 0) +
                        (ln_conv_rate * (r_shipment_rec.tax_amount));

        END LOOP;

        RETURN(ln_tax_amt);

      ELSIF p_document_Type = 'RELEASE' THEN

        ln_tax_amt := 0;

        /*
        || we would have the po_header_id and po_release_id
        || from the po_release_id we should get the line_location_id
        || for a release the po_line_locations_table will have all the details
        */
        FOR r_release_rec IN (SELECT currency, SUM(tax_amount) tax_amount
                                FROM JAI_PO_TAXES a,
                                     po_line_locations_all        b
                               WHERE b.po_header_id = p_header_id
                                 AND b.po_release_id = p_line_id
                                 AND a.po_header_id = b.po_header_id
                                 AND a.po_line_id = b.po_line_id
                                 AND a.line_location_id = b.line_location_id
                               GROUP BY currency)
        LOOP

          IF NVL(r_release_rec.currency, '$$$') <>
             NVL(lv_line_currency, '$$$') THEN
            IF ln_conv_rate IS NULL THEN
              ln_conv_rate := 1;
            END IF;
          ELSE
            ln_conv_rate := 1;
          END IF;

          ln_tax_amt := nvl(ln_tax_amt, 0) +
                        (ln_conv_rate * (r_release_rec.tax_amount));

        END LOOP;

        RETURN(ln_tax_amt);

      ELSIF p_document_Type = 'PO_LINE' THEN

        /*
        || we would get the po_header_id and po_line_id
        || we would get the tax amounts from the JAI_PO_TAXES table.
        */

        FOR r_po_line_rec IN (SELECT currency, SUM(tax_amount) tax_amount
                                FROM JAI_PO_TAXES a
                               WHERE po_header_id = p_header_id
                                 AND po_line_id = p_line_id
                               GROUP BY currency)
        LOOP

          IF NVL(r_po_line_rec.currency, '$$$') <>
             NVL(lv_line_currency, '$$$') THEN
            IF ln_conv_rate IS NULL THEN
              ln_conv_rate := 1;
            END IF;
          ELSE
            ln_conv_rate := 1;
          END IF;

          ln_tax_amt := nvl(ln_tax_amt, 0) +
                        (ln_conv_rate * (r_po_line_rec.tax_amount));

        END LOOP;

        RETURN(ln_tax_amt);

      END IF;

    ELSIF p_document_Type = 'INVOICE' THEN

      ln_tax_amt := 0;
      if p_line_id is null then
        OPEN c_inv_amt;
        FETCH c_inv_amt
          INTO ln_tax_amt;
        CLOSE c_inv_amt;
      Else
        For r_ap_in_dist in (SELECT currency_code, SUM(tax_amount) tax_amount
                              FROM JAI_AP_MATCH_INV_TAXES
                              where invoice_id = p_header_id
                              And parent_invoice_distribution_id = p_line_id
                              GROUP BY currency_code)
        Loop
          OPEN c_conv_rate_inv(p_header_id, p_line_id);
          FETCH c_conv_rate_inv
            INTO ln_conv_rate, lv_line_currency;
          CLOSE c_conv_rate_inv;

          IF NVL(r_ap_in_dist.currency_code, '$$$') <>
             NVL(lv_line_currency, '$$$') THEN
            IF ln_conv_rate IS NULL THEN
              ln_conv_rate := 1;
            END IF;
          ELSE
            ln_conv_rate := 1;
          END IF;

          ln_tax_amt := nvl(ln_tax_amt, 0) +
                        ((r_ap_in_dist.tax_amount) / ln_conv_rate );
        End loop;
      End if;

      RETURN(ln_tax_amt);

    ELSIF p_document_Type = 'ASBN' THEN

      FOR r_cmn_doc_tax IN c_cmn_doc_taxes(p_line_id, p_document_Type)
      LOOP
        OPEN c_conv_rate_asbn(r_cmn_doc_tax.source_doc_line_id);
        FETCH c_conv_rate_asbn
          INTO ln_conv_rate, lv_line_currency;
        CLOSE c_conv_rate_asbn;

        IF NVL(r_cmn_doc_tax.currency_code, '$$$') <>
           NVL(lv_line_currency, '$$$') THEN
          IF ln_conv_rate IS NULL THEN
            ln_conv_rate := 1;
          END IF;
        ELSE
          ln_conv_rate := 1;
        END IF;

        ln_tax_amt := nvl(ln_tax_amt, 0) +
                      ( (r_cmn_doc_tax.tax_amount) / ln_conv_rate );

      END LOOP;

    END IF;

    RETURN(ln_tax_amt);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(-1);
  END gettax;

  FUNCTION get_taxes_inr
  (
    p_document_id  IN VARCHAR2,
    p_header_id    IN NUMBER,
    p_line_id      IN NUMBER
  ) RETURN NUMBER IS
   /* Get the requisition tax amount for each requisition line currency code wise*/
      CURSOR c_reqn_tax_amt IS
      SELECT requisition_line_id, currency, SUM(tax_amount) tax_amount
        FROM JAI_PO_REQ_LINE_TAXES
       WHERE requisition_header_id = p_header_id
         AND requisition_line_id = p_line_id
       GROUP BY requisition_line_id, currency;
  /* Get the conversion rate for the  currency code for the requisition line */
      CURSOR c_conv_Rate(cp_reqn_line_id NUMBER) IS
      SELECT rate, currency_code, cancel_flag, org_id
        FROM po_requisition_lines_all
       WHERE requisition_line_id = cp_reqn_line_id;

      CURSOR c_sob_curr(cp_org_id NUMBER) IS
      SELECT currency_code
        FROM gl_sets_of_booKs
       WHERE set_of_books_id IN
             (SELECT set_of_books_id
                FROM hr_operating_units
               WHERE organization_id = cp_org_id);

      ln_tax_amt     NUMBER ;
      ln_conv_rate   NUMBER ;
      ln_org_id      NUMBER ;
      lv_cancel_flag VARCHAR2(16);
      lv_func_currency VARCHAR2(16);
      lv_line_currency VARCHAR2(16);

  BEGIN

    ln_tax_amt := 0;

    IF p_document_id = 'REQUISITION' THEN
      FOR r_reqn_rec IN c_reqn_tax_amt
      LOOP

        OPEN c_conv_Rate(r_reqn_rec.requisition_line_id);
        FETCH c_conv_Rate
          INTO ln_conv_rate, lv_line_Currency, lv_cancel_flag, ln_org_id;
        CLOSE c_conv_Rate;

        IF ln_org_id IS NOT NULL THEN
          /* just fetch it once*/
          OPEN c_sob_curr(ln_org_id);
          FETCH c_sob_curr
           INTO lv_func_currency;
          CLOSE c_sob_curr;
        END IF;

        IF nvl(lv_cancel_flag, '$') <> 'Y' THEN

            IF NVL(r_reqn_rec.currency, '$$$') =
               NVL(lv_func_currency, '$$$') THEN
              ln_tax_amt := nvl(ln_tax_amt, 0) + (r_reqn_rec.tax_amount);
            ELSE
              ln_tax_amt := nvl(ln_tax_amt, 0) +
                            (r_reqn_rec.tax_amount * ln_conv_Rate);
            END IF;
        END IF;


      END LOOP;
    END IF;

    RETURN(ln_tax_amt);
  EXCEPTION
  WHEN OTHERS THEN
    RETURN -1;
  END get_taxes_inr;

  FUNCTION gettax
  (
    p_document_type     IN VARCHAR2,
    p_header_id         IN NUMBER,
    p_line_id           IN NUMBER,
    p_shipment_line_num IN NUMBER
  ) RETURN NUMBER IS
    CURSOR c_line_location IS
      SELECT line_location_id
        FROM po_line_locations_all
       WHERE po_line_id = p_line_id
         AND shipment_num = p_shipment_line_num;

    ln_line_location_id NUMBER;
  BEGIN
    IF p_shipment_line_num IS NULL THEN
      RETURN(-1);
    ELSIF p_document_type IS NULL
          OR p_header_id IS NULL
          OR p_line_id IS NULL THEN
      RETURN(-2);
    ELSE
      OPEN c_line_location;
      FETCH c_line_location
        INTO ln_line_location_id;
      CLOSE c_line_location;

      IF ln_line_location_id IS NOT NULL THEN
        RETURN(gettax(p_document_type, p_header_id, ln_line_location_id));
      ELSE
        RETURN(-4);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(-8);
  END gettax;

  FUNCTION get_profile_value(cp_profile_name VARCHAR2) RETURN VARCHAR2 IS
    CURSOR c_iproc_profile IS
      SELECT fnd_profile.VALUE(cp_profile_name) FROM DUAL;

    lv_iproc_profile VARCHAR2(100);

  BEGIN

    IF cp_profile_name IS NOT NULL THEN
      OPEN c_iproc_profile;
      FETCH c_iproc_profile
        INTO lv_iproc_profile;
      CLOSE c_iproc_profile;
    END IF;

    IF NVL(lv_iproc_profile, '2') = '2' THEN
      lv_iproc_profile := 'N';
    ELSE
      lv_iproc_profile := 'Y';
    END IF;

    RETURN(lv_iproc_profile);
  EXCEPTION
    WHEN OTHERS THEN
      lv_iproc_profile := 'N';
      RETURN(lv_iproc_profile);
  END get_profile_value;

  PROCEDURE UPDATE_ASBN_MODE
  (
    p_shipment_num IN VARCHAR2,
    p_mode         IN VARCHAR2,
    p_header_interface_id IN NUMBER DEFAULT NULL,  /*bug 8400813*/
    errbuf         OUT NOCOPY VARCHAR2,
    retcode        OUT NOCOPY VARCHAR2
  ) IS
    lv_header_id NUMBER;

  BEGIN
    /*bug 8400813*/
    lv_header_id := p_header_interface_id;

    IF p_header_interface_id IS NULL
    THEN
    SELECT header_interface_id
      INTO lv_header_id
      FROM rcv_headers_interface
     WHERE shipment_num = p_shipment_num;
    END IF;
    /*bug 8400813*/

    IF (p_mode = 'PENDING') THEN

      UPDATE rcv_headers_interface
         SET PROCESSING_STATUS_CODE = 'IL_PENDING'
       WHERE header_interface_id = lv_header_id
         AND PROCESSING_STATUS_CODE = 'PENDING';

      UPDATE RCV_TRANSACTIONS_INTERFACE
         SET PROCESSING_STATUS_CODE = 'IL_PENDING'
       WHERE header_interface_id = lv_header_id
         AND PROCESSING_STATUS_CODE = 'PENDING';

    ELSIF p_mode = 'IL_PENDING' THEN

      UPDATE rcv_headers_interface
         SET PROCESSING_STATUS_CODE = 'PENDING'
       WHERE header_interface_id = lv_header_id
         AND PROCESSING_STATUS_CODE = 'IL_PENDING';

      UPDATE RCV_TRANSACTIONS_INTERFACE
         SET PROCESSING_STATUS_CODE = 'PENDING'
       WHERE header_interface_id = lv_header_id
         AND PROCESSING_STATUS_CODE = 'IL_PENDING';

    END IF;

    errbuf  := NULL;
    retcode := '0';

  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := SQLERRM;
      retcode := '2';
  END UPDATE_ASBN_MODE;


  /*Function added by srjayara for iSupplier pages*/
  FUNCTION gettaxisp
  (
    p_document_type IN VARCHAR2,
    p_header_id     IN NUMBER,
    p_line_id       IN NUMBER,
    p_release_id    IN NUMBER
  ) RETURN NUMBER IS


    /* Get the RFQ / PO / BPA  tax amount for each line location currency code wise*/
    CURSOR c_po_rfq IS
      SELECT line_location_id, currency, SUM(tax_amount) tax_amount
        FROM JAI_PO_TAXES
       WHERE po_header_id = p_header_id
         AND (line_location_id = p_line_id OR p_line_id IS NULL)
       GROUP BY line_location_id, currency;

           -- commented out by pramasub
    CURSOR c_po_ppo IS
         SELECT a.line_location_id, currency, SUM(tax_amount) tax_amount
        FROM JAI_PO_TAXES a,
        po_line_locations_all b
       WHERE a.po_header_id = p_header_id
       AND a.po_header_id = b.po_header_id
       AND a.po_line_id = b.po_line_id
       AND a.line_location_id = b.line_location_id
       and b.po_release_id is null
         --AND (line_location_id = :p_line_id OR :p_line_id IS NULL)
       GROUP BY a.line_location_id, a.currency;

    CURSOR c_po_bpa IS
         SELECT a.line_location_id, currency, SUM(tax_amount) tax_amount
        FROM JAI_PO_TAXES a,
        po_line_locations_all b
       WHERE a.po_header_id = p_header_id
       AND a.po_header_id = b.po_header_id
       AND a.po_line_id = b.po_line_id
       AND a.line_location_id = b.line_location_id
       and b.po_release_id is null
       AND (a.po_line_id = p_line_id OR p_line_id IS NULL)
       GROUP BY a.line_location_id, a.currency;

      -- pramasub changes end here

    /* Get the conversion rate for the  currency code for the PO / RFQ */
    CURSOR c_conv_rate_rfq(cp_header_id IN NUMBER) IS
      SELECT rate, currency_code
        FROM po_headers_all
       WHERE po_header_id = cp_header_id;

    /* Get Invoice amount*/
    CURSOR c_inv_amt IS
      SELECT SUM(amount)
        FROM ap_invoice_distributions_all
       WHERE invoice_id = p_header_id
         AND line_type_lookup_code = 'MISCELLANEOUS';

    /* Get the set of books currency (function currency)*/
    CURSOR c_sob_curr(cp_org_id NUMBER) IS
      SELECT currency_code
        FROM gl_sets_of_booKs
       WHERE set_of_books_id IN
             (SELECT set_of_books_id
                FROM hr_operating_units
               WHERE organization_id = cp_org_id);

    -- pramasub start /*for asn/asbn*/
    CURSOR c_cmn_doc_taxes(cp_cmn_line_id IN NUMBER, cp_doc_type IN VARCHAR2) IS
      SELECT SUM(tax_amt) tax_amount, currency_code
        FROM JAI_CMN_DOCUMENT_TAXES
       WHERE source_doc_line_id = cp_cmn_line_id
         AND source_doc_type = cp_doc_type
       GROUP BY currency_code;
    -- pramasub end

    ln_Tax_amt       NUMBER;
    lv_curr_tax_amt  NUMBER;
    ln_conv_rate     NUMBER;
    lv_line_Currency VARCHAR2(15);
    lv_cancel_flag   VARCHAR2(1);
    lv_func_currency VARCHAR2(15);
    ln_org_id        NUMBER;

  BEGIN

    ln_tax_amt := 0;

    IF p_document_type = 'PO_RECEIPT_ALL' THEN

    FOR rec in (select shipment_header_id,shipment_line_id
                  from rcv_shipment_lines
                 WHERE po_line_location_id IN (select line_Location_id
                                                 from po_line_locations_all
                                                where po_header_id=p_header_id)
                   AND (po_release_id = p_release_id or p_release_id is null)
                )
      LOOP
         ln_tax_amt := ln_tax_amt + gettax('RECEIPTS',rec.shipment_header_id,rec.shipment_line_id);
      END LOOP;
      RETURN (ln_tax_amt);
    END IF;

    IF p_document_type = 'PO_INVOICE_ALL' THEN

    FOR rec in (select distinct invoice_id
                  from ap_invoice_lines_all
                 where po_line_location_id IN (select line_Location_id
                                                    from po_line_locations_all
                                                   where po_header_id=p_header_id)
                   AND (po_release_id = p_release_id or p_release_id is null)
                )
      LOOP
         ln_tax_amt := ln_tax_amt + gettax('INVOICE', rec.invoice_id,null);
      END LOOP;
      RETURN (ln_tax_amt);
    END IF;


    IF p_document_type = 'PO_RECEIPT' THEN

    FOR rec in (select shipment_header_id,shipment_line_id from rcv_shipment_lines where po_line_location_id = p_line_id)
      LOOP
         ln_tax_amt := ln_tax_amt + gettax('RECEIPTS',rec.shipment_header_id,rec.shipment_line_id);
      END LOOP;
      RETURN (ln_tax_amt);
    END IF;

    IF p_document_type = 'PO_INVOICE' THEN

    FOR rec in (select distinct invoice_id from ap_invoice_lines_all where po_line_location_id = p_line_id)
      LOOP
         ln_tax_amt := ln_tax_amt + gettax('INVOICE', rec.invoice_id,null);
      END LOOP;
      RETURN (ln_tax_amt);
    END IF;

    IF p_document_Type = 'GBA_ALL' Then
        FOR r_po_rec IN
                (SELECT po_header_id FROM po_lines_all WHERE from_header_id = p_header_id)
        LOOP
                ln_tax_amt := ln_tax_amt + gettaxisp('PO',r_po_rec.po_header_id,null,null);
        END LOOP;
	RETURN (ln_tax_amt);
    END IF;

    IF p_document_Type = 'GBA' Then
/*
 * This Code is Commented : GBA should display only its taxes
 *  its should not display taxes of releases
  IF p_line_id IS NOT NULL THEN
          FOR r_po_rec IN
                  (SELECT po_header_id, po_line_id FROM po_lines_all WHERE from_header_id = p_header_id AND from_line_id = p_line_id)
          LOOP
                  ln_tax_amt := ln_tax_amt + gettaxisp('PO_LINE',r_po_rec.po_header_id,r_po_rec.po_line_id,null);
          END LOOP;
	ELSE
          FOR r_po_rec IN
                  (SELECT po_header_id FROM po_lines_all WHERE from_header_id = p_header_id)
          LOOP
                  ln_tax_amt := ln_tax_amt + gettaxisp('PO',r_po_rec.po_header_id,null,null);
          END LOOP;
	END IF;
*/
	IF p_line_id IS NOT NULL THEN
          FOR r_po_rec IN
                  (SELECT po_header_id, po_line_id FROM po_lines_all WHERE po_header_id = p_header_id AND po_line_id = p_line_id)
          LOOP
                  ln_tax_amt := ln_tax_amt + gettaxisp('PO_LINE',r_po_rec.po_header_id,r_po_rec.po_line_id,null);
          END LOOP;
	ELSE
          FOR r_po_rec IN
                  (SELECT po_header_id FROM po_lines_all WHERE po_header_id = p_header_id)
          LOOP
                  ln_tax_amt := ln_tax_amt + gettaxisp('PO',r_po_rec.po_header_id,null,null);
          END LOOP;
	END IF;
	RETURN (ln_tax_amt);
    END IF;

    IF p_document_Type IN ('RFQ', 'PO') THEN


      FOR r_rfq_po_rec IN c_po_rfq
      LOOP

      OPEN c_conv_rate_rfq(p_header_id);
      FETCH c_conv_rate_rfq
        INTO ln_conv_rate, lv_line_currency;
      CLOSE c_conv_rate_rfq;

        IF NVL(r_rfq_po_rec.currency, '$$$') <>
           NVL(lv_line_currency, '$$$') THEN
          IF ln_conv_rate IS NULL THEN
            ln_conv_rate := 1;
          END IF;
        ELSE
          ln_conv_rate := 1;
        END IF;

        ln_tax_amt := nvl(ln_tax_amt, 0) +
                      ((r_rfq_po_rec.tax_amount) / ln_conv_rate);

      END LOOP;

    ELSIF p_document_Type = 'PPO' then
      FOR r_rfq_po_rec IN c_po_ppo
      LOOP
        OPEN c_conv_rate_rfq(p_header_id);
        FETCH c_conv_rate_rfq
          INTO ln_conv_rate, lv_line_currency;
        CLOSE c_conv_rate_rfq;

        IF NVL(r_rfq_po_rec.currency, '$$$') <>
           NVL(lv_line_currency, '$$$') THEN
          IF ln_conv_rate IS NULL THEN
            ln_conv_rate := 1;
          END IF;
        ELSE
          ln_conv_rate := 1;
        END IF;

        ln_tax_amt := nvl(ln_tax_amt, 0) +
                      ((r_rfq_po_rec.tax_amount) / ln_conv_rate);
      END LOOP;

    ELSIF p_document_Type = 'BPA' then
      FOR r_rfq_po_rec IN c_po_bpa
      LOOP
        OPEN c_conv_rate_rfq(p_header_id);
        FETCH c_conv_rate_rfq
          INTO ln_conv_rate, lv_line_currency;
        CLOSE c_conv_rate_rfq;

        IF NVL(r_rfq_po_rec.currency, '$$$') <>
           NVL(lv_line_currency, '$$$') THEN
          IF ln_conv_rate IS NULL THEN
            ln_conv_rate := 1;
          END IF;
        ELSE
          ln_conv_rate := 1;
        END IF;

        ln_tax_amt := nvl(ln_tax_amt, 0) +
                      ((r_rfq_po_rec.tax_amount) / ln_conv_rate);
      END LOOP;

    ELSIF p_document_Type IN ('SHIPMENT', 'RELEASE', 'PO_LINE', 'RELEASE_TOT') THEN

      /*
      || p_document_type = 'RELEASE'  - p_header_id = po_header_id , po_line_id = p_line_id, po_release_id = p_release_id
      || p_document_type = 'SHIPMENT' - p_header_id = po_header_id , po_line_id = p_line_location_id
      || p_document_type = 'PO_LINE'  - p_header_id = po_header_id , po_line_id = p_line_id
      */


      IF p_document_Type = 'SHIPMENT' THEN

        /*
        || We would have got the po_header_id and line_location_id
        || we will get the details from the JAI_PO_TAXES table.
        */

        ln_tax_amt := 0;

        FOR r_shipment_rec IN (SELECT currency, SUM(tax_amount) tax_amount
                                 FROM JAI_PO_TAXES
                                WHERE line_location_id = p_line_id
                                GROUP BY currency)
        LOOP

      OPEN c_conv_rate_rfq(p_header_id);
      FETCH c_conv_rate_rfq
        INTO ln_conv_rate, lv_line_currency;
      CLOSE c_conv_rate_rfq;


          IF NVL(r_shipment_rec.currency, '$$$') <>
             NVL(lv_line_currency, '$$$') THEN
            IF ln_conv_rate IS NULL THEN
              ln_conv_rate := 1;
            END IF;
          ELSE
            ln_conv_rate := 1;
          END IF;

          ln_tax_amt := nvl(ln_tax_amt, 0) +
                        ((r_shipment_rec.tax_amount) / ln_conv_rate);

        END LOOP;

        RETURN(ln_tax_amt);

      ELSIF p_document_Type = 'RELEASE' THEN

        ln_tax_amt := 0;

        /*
        || we would have the po_header_id and po_release_id (and po_line_id -optional)
        || from the po_release_id we should get the line_location_id
        || for a release the po_line_locations_table will have all the details
        */
        FOR r_release_rec IN (SELECT currency, SUM(tax_amount) tax_amount
                                FROM JAI_PO_TAXES a,
                                     po_line_locations_all        b
                               WHERE b.po_header_id = p_header_id
                                 AND b.po_release_id = p_release_id
								 AND (p_line_id IS NULL OR b.po_line_id = p_line_id)
                                 AND a.po_header_id = b.po_header_id
                                 AND a.po_line_id = b.po_line_id
                                 AND a.line_location_id = b.line_location_id
                               GROUP BY currency)
        LOOP

      OPEN c_conv_rate_rfq(p_header_id);
      FETCH c_conv_rate_rfq
        INTO ln_conv_rate, lv_line_currency;
      CLOSE c_conv_rate_rfq;


          IF NVL(r_release_rec.currency, '$$$') <>
             NVL(lv_line_currency, '$$$') THEN
            IF ln_conv_rate IS NULL THEN
              ln_conv_rate := 1;
            END IF;
          ELSE
            ln_conv_rate := 1;
          END IF;

          ln_tax_amt := nvl(ln_tax_amt, 0) +
                        ((r_release_rec.tax_amount) / ln_conv_rate);

        END LOOP;

        RETURN(ln_tax_amt);
      ELSIF p_document_Type = 'RELEASE_TOT' THEN

        ln_tax_amt := 0;

	        /*
	        || we would have the po_header_id and po_release_id (and po_line_id -optional)
	        || from the po_release_id we should get the line_location_id
	        || for a release the po_line_locations_table will have all the details
	        */
        FOR r_release_rec IN (SELECT currency, SUM(tax_amount) tax_amount
                                FROM JAI_PO_TAXES a,
                                     po_line_locations_all        b,
                                     po_releases_all  c -- added by pramasub #6441185
                               WHERE b.po_header_id = p_header_id
                                 AND b.po_release_id is not null
                                 AND a.po_header_id = b.po_header_id
                                 AND a.po_line_id = b.po_line_id
                                 AND a.line_location_id = b.line_location_id
                                 AND c.po_release_id = b.po_release_id -- added by pramasub #6441185
                                 AND c.approved_flag = 'Y' -- added by pramasub #6441185
                               GROUP BY currency)
        LOOP

	      OPEN c_conv_rate_rfq(p_header_id);
	      FETCH c_conv_rate_rfq
	        INTO ln_conv_rate, lv_line_currency;
	      CLOSE c_conv_rate_rfq;


          IF NVL(r_release_rec.currency, '$$$') <>
             NVL(lv_line_currency, '$$$') THEN
            IF ln_conv_rate IS NULL THEN
              ln_conv_rate := 1;
            END IF;
          ELSE
            ln_conv_rate := 1;
          END IF;

          ln_tax_amt := nvl(ln_tax_amt, 0) +
                        ((r_release_rec.tax_amount) / ln_conv_rate);

        END LOOP;

        RETURN(ln_tax_amt);

      ELSIF p_document_Type = 'PO_LINE' THEN

        /*
        || we would get the po_header_id and po_line_id
        || we would get the tax amounts from the JAI_PO_TAXES table.
        */

        FOR r_po_line_rec IN (SELECT currency, SUM(tax_amount) tax_amount
                                FROM JAI_PO_TAXES a
                               WHERE po_header_id = p_header_id
                                 AND po_line_id = p_line_id
                               GROUP BY currency)
        LOOP

      OPEN c_conv_rate_rfq(p_header_id);
      FETCH c_conv_rate_rfq
        INTO ln_conv_rate, lv_line_currency;
      CLOSE c_conv_rate_rfq;


          IF NVL(r_po_line_rec.currency, '$$$') <>
             NVL(lv_line_currency, '$$$') THEN
            IF ln_conv_rate IS NULL THEN
              ln_conv_rate := 1;
            END IF;
          ELSE
            ln_conv_rate := 1;
          END IF;

          ln_tax_amt := nvl(ln_tax_amt, 0) +
                        ((r_po_line_rec.tax_amount) / ln_conv_rate);

        END LOOP;

        RETURN(ln_tax_amt);

      END IF;

    ELSIF p_document_Type = 'INVOICE' THEN

      OPEN c_inv_amt;
      FETCH c_inv_amt
        INTO ln_tax_amt;
      CLOSE c_inv_amt;

      RETURN(ln_tax_amt);

    ELSIF p_document_Type = 'ASBN' THEN

      FOR r_cmn_doc_tax IN c_cmn_doc_taxes(p_line_id, p_document_Type)
      LOOP
        ln_tax_amt := r_cmn_doc_tax.tax_amount;
      END LOOP;

    END IF;

    RETURN(ln_tax_amt);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(-1);
  END gettaxisp;

--==========================================================================
--  PROCEDURE NAME:
--
--    Get_InAndEx_Tax_Total                        Public
--
--  DESCRIPTION:
--
--    to calculate the inclusive and exclusive tax amount
--
--  PARAMETERS:
--      In:  pv_document_type      document type
--           pn_header_id          header id
--           pn_line_id            line id
--           pv_inclusive_tax_flag inclusive tax flag
--
--  DESIGN REFERENCES:
--    Inclusive Tax Technical Design.doc
--
--  CHANGE HISTORY:
--
--           20-NOV-2007   Jason Liu  created
FUNCTION Get_InAndEx_Tax_Total
( pv_document_type      IN VARCHAR2
, pn_header_id          IN NUMBER
, pn_line_id            IN NUMBER
, pv_inclusive_tax_flag IN VARCHAR2
)
RETURN NUMBER
IS

CURSOR sob_curr_csr(pn_org_id NUMBER) IS
SELECT currency_code
FROM gl_sets_of_booKs
WHERE set_of_books_id IN
                        (SELECT set_of_books_id
                         FROM hr_operating_units
                         WHERE organization_id = pn_org_id);

--Get the requisition tax amount for each requisition line currency code
CURSOR reqn_tax_amt_csr IS
SELECT
  rtl.requisition_line_id
, rtl.currency
, rtl.tax_amount
, NVL(tax.rounding_factor, 0) rnd_factor
FROM
  jai_po_req_line_taxes    rtl
, jai_cmn_taxes_all        tax
, po_requisition_lines_all prla
WHERE rtl.requisition_header_id = pn_header_id
  AND (rtl.requisition_line_id = pn_line_id OR pn_line_id IS NULL)
  AND prla.requisition_line_id = rtl.requisition_line_id
  AND tax.tax_id = rtl.tax_id
  AND NVL(tax.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
ORDER BY rtl.currency;

--Get the conversion rate for the currency code for the requisition line
CURSOR conv_rate_reqn_csr(cp_reqn_line_id NUMBER) IS
SELECT
  rate
, currency_code
, cancel_flag
, org_id
FROM po_requisition_lines_all
WHERE requisition_line_id = cp_reqn_line_id;

--Get the receipt tax amount for each shipment line currency code
CURSOR rcpt_tax_amt_csr IS
SELECT
  jrlt.shipment_line_id
, jrlt.currency
, SUM(jrlt.tax_amount) tax_amount
FROM
  jai_rcv_line_taxes jrlt
, jai_cmn_taxes_all  jcta
WHERE jrlt.shipment_header_id = pn_header_id
  AND (jrlt.shipment_line_id = pn_line_id OR pn_line_id IS NULL)
  AND jcta.tax_id = jrlt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY
  jrlt.shipment_line_id
, jrlt.currency;

--Get the conversion rate for the  currency code for the receipt shipment line
CURSOR conv_rate_rcpt_csr(pn_shipment_line_id IN NUMBER) IS
SELECT
  currency_conversion_rate
, currency_code
FROM rcv_transactions
WHERE shipment_line_id = pn_shipment_line_id
  AND transaction_type = 'RECEIVE';

--Get the RFQ / PO / BPA  tax amount for each line location currency code
CURSOR po_rfq_tax_amt_csr IS
SELECT
  jpt.line_location_id
, jpt.currency
, SUM(jpt.tax_amount) tax_amount
FROM
  jai_po_taxes      jpt
, jai_cmn_taxes_all jcta
WHERE jpt.po_header_id = pn_header_id
  AND (jpt.line_location_id = pn_line_id OR pn_line_id IS NULL)
  AND jcta.tax_id = jpt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY
  jpt.line_location_id
, jpt.currency;

--Get the conversion rate for the currency code for the PO / RFQ / BPA / SHIPMENT/ RELEASE / PO_LINE
CURSOR conv_rate_rfq_csr(pn_csr_header_id IN NUMBER) IS
SELECT
  rate
, currency_code
FROM po_headers
WHERE po_header_id = pn_csr_header_id;

--Get the invoice tax amount for each distribution currency code
CURSOR inv_tax_amt_csr IS
SELECT
  jamit.currency_code
, SUM(jamit.tax_amount) tax_amount
FROM
  jai_ap_match_inv_taxes jamit
, jai_cmn_taxes_all      jcta
WHERE jamit.invoice_id = pn_header_id
  AND (jamit.parent_invoice_distribution_id = pn_line_id OR pn_line_id IS NULL)
  AND jcta.tax_id = jamit.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY jamit.currency_code;

--Get the conversion rate for the currency code for the INVOICE
CURSOR conv_rate_inv_csr
( pn_csr_header_id IN NUMBER
, pn_csr_line_id IN NUMBER
)
IS
SELECT
  exchange_rate
, currency_code
FROM jai_ap_match_inv_taxes
WHERE invoice_id = pn_csr_header_id
  AND parent_invoice_distribution_id = pn_csr_line_id;

-- Get the shipments tax amount
CURSOR shipments_tax_amt_csr IS
SELECT
  jpt.currency
, SUM(jpt.tax_amount) tax_amount
FROM
  jai_po_taxes      jpt
, jai_cmn_taxes_all jcta
WHERE jpt.line_location_id = pn_line_id
  AND jcta.tax_id = jpt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY jpt.currency;

-- Get the release tax amount
CURSOR release_tax_amt_csr IS
SELECT
  jpt.currency
, SUM(jpt.tax_amount) tax_amount
FROM
  jai_po_taxes          jpt
, po_line_locations_all plla
, jai_cmn_taxes_all     jcta
WHERE plla.po_header_id = pn_header_id
  AND plla.po_release_id = pn_line_id
  AND jpt.po_header_id = plla.po_header_id
  AND jpt.po_line_id = plla.po_line_id
  AND jpt.line_location_id = plla.line_location_id
  AND jcta.tax_id = jpt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY jpt.currency;

-- Get the PO_lINE tax amount
CURSOR po_line_tax_amt_csr IS
SELECT
  jpt.currency
, SUM(jpt.tax_amount) tax_amount
FROM
  jai_po_taxes      jpt
, jai_cmn_taxes_all jcta
WHERE po_header_id = pn_header_id
  AND po_line_id = pn_line_id
  AND jcta.tax_id = jpt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY jpt.currency;

-- Get ASBN tax amount
CURSOR asbn_tax_amt_csr
( cp_cmn_line_id IN NUMBER
, cp_doc_type IN VARCHAR2
)
IS
SELECT
  jcdt.source_doc_line_id
, jcdt.currency_code
, SUM(jcdt.tax_amt) tax_amount
FROM
  jai_cmn_document_taxes jcdt
, jai_cmn_taxes_all      jcta
WHERE jcdt.source_doc_line_id = cp_cmn_line_id
  AND jcdt.source_doc_type = cp_doc_type
  AND jcta.tax_id = jcdt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY
  jcdt.source_doc_line_id
, jcdt.currency_code;

--Get the conversion rate for the currency code for the ASBN
CURSOR conv_rate_asbn_csr(cp_cmn_line_id IN NUMBER) IS
SELECT
  pha.rate
, pha.currency_code
FROM po_headers_all pha
WHERE pha.po_header_id =
                        (SELECT po_header_id
                         FROM jai_cmn_lines
                         WHERE cmn_line_id = cp_cmn_line_id);


ln_tax_amt        NUMBER;
ln_conv_rate      NUMBER;
lv_line_currency  VARCHAR2(15);
lv_cancel_flag    VARCHAR2(1);
lv_func_currency  VARCHAR2(15);
ln_org_id         NUMBER;
lv_procedure_name VARCHAR2(40):='Get_InAndEx_Tax_Total';
ln_dbg_level      NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER:=FND_LOG.LEVEL_PROCEDURE;
BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter function'
                  );
  END IF; --l_proc_level>=l_dbg_level

  ln_tax_amt := 0;
  IF (pv_document_type = 'REQUISITION')
  THEN
    FOR reqn_tax_amt_rec IN reqn_tax_amt_csr
    LOOP
      OPEN conv_rate_reqn_csr(reqn_tax_amt_rec.requisition_line_id);
      FETCH conv_rate_reqn_csr
      INTO
        ln_conv_rate
      , lv_line_Currency
      , lv_cancel_flag
      , ln_org_id;
      CLOSE conv_rate_reqn_csr;

      IF (ln_org_id IS NOT NULL)
      THEN
        OPEN sob_curr_csr(ln_org_id);
        FETCH sob_curr_csr
        INTO lv_func_currency;
        CLOSE sob_curr_csr;
      END IF; --(ln_org_id IS NOT NULL)

      IF (NVL(lv_cancel_flag, '$') <> 'Y')
      THEN
        IF (pn_line_id IS NOT NULL)
        THEN
          IF (NVL(reqn_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))
          THEN
            IF (ln_conv_rate IS NULL)
            THEN
              ln_conv_rate := 1;
            END IF; --(ln_conv_rate IS NULL)
          ELSE
            ln_conv_rate := 1;
          END IF; --(NVL(reqn_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))

          ln_tax_amt := NVL(ln_tax_amt, 0) +
                          ROUND(((reqn_tax_amt_rec.tax_amount) / ln_conv_rate),reqn_tax_amt_rec.rnd_factor);
        ELSE
          IF (NVL(reqn_tax_amt_rec.currency, '$$$') =
             NVL(lv_func_currency, '$$$'))
          THEN
             ln_tax_amt := NVL(ln_tax_amt, 0) + (reqn_tax_amt_rec.tax_amount);
          ELSE
            ln_tax_amt := NVL(ln_tax_amt, 0) +
                          round((reqn_tax_amt_rec.tax_amount * NVL( ln_conv_Rate,1)),reqn_tax_amt_rec.rnd_factor); -- nvl correction made by pramasub #6066485
          END IF; --(NVL(reqn_tax_amt_rec.currency, '$$$')=NVL(lv_func_currency, '$$$'))
        END IF; --(pn_line_id IS NOT NULL)
      END IF; --(NVL(lv_cancel_flag, '$') <> 'Y')
    END LOOP; --reqn_tax_amt_rec IN reqn_tax_amt_csr

  ELSIF (pv_document_type = 'RECEIPTS')
  THEN
    FOR r_rcpt_rec IN rcpt_tax_amt_csr
    LOOP
      OPEN conv_rate_rcpt_csr(r_rcpt_rec.shipment_line_id);
      FETCH conv_rate_rcpt_csr
      INTO
        ln_conv_rate
      , lv_line_currency;
      CLOSE conv_rate_rcpt_csr;

      IF (NVL(r_rcpt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))
      THEN
        IF (ln_conv_rate IS NULL) THEN
          ln_conv_rate := 1;
        END IF; --(ln_conv_rate IS NULL)
      ELSE
        ln_conv_rate := 1;
      END IF; --(NVL(r_rcpt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))

      ln_tax_amt := NVL(ln_tax_amt, 0) +
                    ((r_rcpt_rec.tax_amount) / ln_conv_rate);
    END LOOP; --(r_rcpt_rec IN rcpt_tax_amt_csr)

  ELSIF pv_document_type IN ('RFQ', 'PO', 'BPA')
  THEN
    OPEN conv_rate_rfq_csr(pn_header_id);
    FETCH conv_rate_rfq_csr
    INTO
      ln_conv_rate
    , lv_line_currency;
    CLOSE conv_rate_rfq_csr;

    FOR po_rfq_rec IN po_rfq_tax_amt_csr
    LOOP
      IF (NVL(po_rfq_rec.currency, '$$$') <>  NVL(lv_line_currency, '$$$'))
      THEN
        IF (ln_conv_rate IS NULL) THEN
          ln_conv_rate := 1;
        END IF; --(ln_conv_rate IS NULL)
      ELSE
        ln_conv_rate := 1;
      END IF; --(NVL(po_rfq_rec.currency, '$$$') <>  NVL(lv_line_currency, '$$$'))

      ln_tax_amt := NVL(ln_tax_amt, 0) +
                      (ln_conv_rate * (po_rfq_rec.tax_amount));

    END LOOP;

  ELSIF pv_document_type IN ('SHIPMENT', 'RELEASE', 'PO_LINE')
  THEN
    OPEN conv_rate_rfq_csr(pn_header_id);
    FETCH conv_rate_rfq_csr
    INTO
      ln_conv_rate
    , lv_line_currency;
    CLOSE conv_rate_rfq_csr;

    IF pv_document_type = 'SHIPMENT'
    THEN
      ln_tax_amt := 0;

      FOR shipments_tax_amt_rec IN shipments_tax_amt_csr
      LOOP

        IF NVL(shipments_tax_amt_rec.currency, '$$$') <>
           NVL(lv_line_currency, '$$$')
        THEN
          IF ln_conv_rate IS NULL
          THEN
            ln_conv_rate := 1;
          END IF;
        ELSE
          ln_conv_rate := 1;
        END IF;

        ln_tax_amt := NVL(ln_tax_amt, 0) +
                      (ln_conv_rate * (shipments_tax_amt_rec.tax_amount));

      END LOOP;

      RETURN ln_tax_amt;

    ELSIF pv_document_type = 'RELEASE'
    THEN

      ln_tax_amt := 0;
      FOR release_tax_amt_rec IN release_tax_amt_csr
      LOOP

        IF (NVL(release_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))
        THEN
          IF (ln_conv_rate IS NULL)
          THEN
            ln_conv_rate := 1;
          END IF; --(ln_conv_rate IS NULL)
        ELSE
          ln_conv_rate := 1;
        END IF; --(NVL(release_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))

        ln_tax_amt := NVL(ln_tax_amt, 0) +
                      (ln_conv_rate * (release_tax_amt_rec.tax_amount));

      END LOOP; --release_tax_amt_rec IN release_tax_amt_csr

      RETURN ln_tax_amt;

    ELSIF pv_document_type = 'PO_LINE'
    THEN
      FOR po_line_tax_amt_rec IN po_line_tax_amt_csr
      LOOP
        IF (NVL(po_line_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))
        THEN
          IF (ln_conv_rate IS NULL)
          THEN
            ln_conv_rate := 1;
          END IF; --(ln_conv_rate IS NULL)
        ELSE
          ln_conv_rate := 1;
        END IF; --(NVL(po_line_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))

        ln_tax_amt := NVL(ln_tax_amt, 0) +
                      (ln_conv_rate * (po_line_tax_amt_rec.tax_amount));

      END LOOP;

      RETURN ln_tax_amt;
    END IF;

  ELSIF (pv_document_Type = 'INVOICE')
  THEN
    FOR inv_tax_amt_rec IN inv_tax_amt_csr
    LOOP
      OPEN conv_rate_inv_csr( pn_header_id
                             , pn_line_id
                             );
      FETCH conv_rate_inv_csr
      INTO
        ln_conv_rate
      , lv_line_currency;
      CLOSE conv_rate_inv_csr;

      IF (NVL(inv_tax_amt_rec.currency_code, '$$$') <> NVL(lv_line_currency, '$$$'))
      THEN
        IF (ln_conv_rate IS NULL)
        THEN
          ln_conv_rate := 1;
        END IF; --(ln_conv_rate IS NULL)
      ELSE
        ln_conv_rate := 1;
      END IF; --(NVL(inv_tax_amt_rec.currency_code, '$$$') <> NVL(lv_line_currency, '$$$'))

      ln_tax_amt := NVL(ln_tax_amt, 0) +
                  ((inv_tax_amt_rec.tax_amount) / ln_conv_rate );
    END LOOP; --inv_tax_amt_rec IN inv_tax_amt_csr

    RETURN(ln_tax_amt);
  ELSIF pv_document_Type = 'ASBN'
  THEN
    FOR asbn_tax_amt_rec IN asbn_tax_amt_csr(pn_line_id, pv_document_type)
    LOOP
      OPEN conv_rate_asbn_csr(asbn_tax_amt_rec.source_doc_line_id);
      FETCH conv_rate_asbn_csr
      INTO
        ln_conv_rate
      , lv_line_currency;
      CLOSE conv_rate_asbn_csr;

      IF (NVL(asbn_tax_amt_rec.currency_code, '$$$') <> NVL(lv_line_currency, '$$$'))
      THEN
        IF (ln_conv_rate IS NULL)
        THEN
          ln_conv_rate := 1;
        END IF; --(ln_conv_rate IS NULL)
      ELSE
        ln_conv_rate := 1;
      END IF; --(NVL(asbn_tax_amt_rec.currency_code, '$$$') <> NVL(lv_line_currency, '$$$'))

      ln_tax_amt := NVL(ln_tax_amt, 0) +
                    ( (asbn_tax_amt_rec.tax_amount) / ln_conv_rate );

    END LOOP; --asbn_tax_amt_rec IN asbn_tax_amt_csr(pn_line_id, pv_document_type)
  END IF;

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Exit function'
                  );
  END IF; --l_proc_level>=l_dbg_level

  RETURN ln_tax_amt;
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RETURN (-1);
END Get_InAndEx_Tax_Total;

--==========================================================================
--  PROCEDURE NAME:
--
--    Get_Isp_InAndEx_Tax_Total                        Public
--
--  DESCRIPTION:
--
--    to calculate the inclusive and exclusive tax amount
--
--  PARAMETERS:
--      In:  pv_document_type      document type
--           pn_header_id          header id
--           pn_line_id            line id
--           pn_release_id         release id
--           pv_inclusive_tax_flag inclusive tax flag
--
--  DESIGN REFERENCES:
--    Inclusive Tax Technical Design.doc
--
--  CHANGE HISTORY:
--
--           20-NOV-2007   Jason Liu  created

FUNCTION Get_Isp_InAndEx_Tax_Total
( pv_document_type      IN VARCHAR2
, pn_header_id          IN NUMBER
, pn_line_id            IN NUMBER
, pn_release_id         IN NUMBER
, pv_inclusive_tax_flag IN VARCHAR2
)
RETURN NUMBER
IS

--Get the RFQ / PO / BPA  tax amount for each line location currency code wise
CURSOR po_rfq_tax_amt_csr IS
SELECT
  jpt.line_location_id
, jpt.currency
, SUM(jpt.tax_amount) tax_amount
FROM
  JAI_PO_TAXES      jpt
, jai_cmn_taxes_all jcta
WHERE jpt.po_header_id = pn_header_id
  AND (jpt.line_location_id = pn_line_id OR pn_line_id IS NULL)
  AND jcta.tax_id = jpt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY jpt.line_location_id, jpt.currency;


CURSOR ppo_tax_amt_csr IS
SELECT
  jpt.line_location_id
, jpt.currency
, SUM(jpt.tax_amount) tax_amount
FROM
  JAI_PO_TAXES          jpt
, po_line_locations_all plla
, jai_cmn_taxes_all     jcta
WHERE jpt.po_header_id = pn_header_id
  AND jpt.po_header_id = plla.po_header_id
  AND jpt.po_line_id = plla.po_line_id
  AND jpt.line_location_id = plla.line_location_id
  AND plla.po_release_id IS NULL
  AND jcta.tax_id = jpt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY
  jpt.line_location_id
, jpt.currency;

CURSOR bpa_tax_amt_csr IS
SELECT
  jpt.line_location_id
, jpt.currency
, SUM(jpt.tax_amount) tax_amount
FROM
  jai_po_taxes          jpt
, po_line_locations_all plla
, jai_cmn_taxes_all     jcta
WHERE jpt.po_header_id = pn_header_id
  AND jpt.po_header_id = plla.po_header_id
  AND jpt.po_line_id = plla.po_line_id
  AND jpt.line_location_id = plla.line_location_id
  AND plla.po_release_id IS NULL
  AND (jpt.po_line_id = pn_line_id OR pn_line_id IS NULL)
  AND jcta.tax_id = jpt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY
  jpt.line_location_id
, jpt.currency;

--Get the conversion rate for the  currency code for the PO / RFQ */
CURSOR conv_rate_rfq_csr(pn_header_id IN NUMBER) IS
SELECT
  rate
, currency_code
FROM po_headers_all
WHERE po_header_id = pn_header_id;

-- Get the shipments tax amount
CURSOR shipments_tax_amt_csr IS
SELECT
  jpt.currency
, SUM(jpt.tax_amount) tax_amount
FROM
  jai_po_taxes      jpt
, jai_cmn_taxes_all jcta
WHERE jpt.line_location_id = pn_line_id
  AND jcta.tax_id = jpt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY jpt.currency;

-- Get the release tax amount
CURSOR release_tax_amt_csr IS
SELECT
  jpt.currency
, SUM(jpt.tax_amount) tax_amount
FROM
  jai_po_taxes          jpt
, po_line_locations_all plla
, jai_cmn_taxes_all     jcta
WHERE plla.po_header_id = pn_header_id
  AND plla.po_release_id = pn_release_id
  AND (pn_line_id IS NULL OR plla.po_line_id = pn_line_id)
  AND jpt.po_header_id = plla.po_header_id
  AND jpt.po_line_id = plla.po_line_id
  AND jpt.line_location_id = plla.line_location_id
  AND jcta.tax_id = jpt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY jpt.currency;

-- Get the PO_lINE tax amount
CURSOR po_line_tax_amt_csr IS
SELECT
  jpt.currency
, SUM(jpt.tax_amount) tax_amount
FROM
  jai_po_taxes      jpt
, jai_cmn_taxes_all jcta
WHERE jpt.po_header_id = pn_header_id
  AND jpt.po_line_id = pn_line_id
  AND jcta.tax_id = jpt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY jpt.currency;

--Get the RELEASE_TOT tax amount
CURSOR release_tot_tax_amt_csr IS
SELECT
  jpt.currency
, SUM(jpt.tax_amount) tax_amount
FROM
  JAI_PO_TAXES          jpt
, po_line_locations_all plla
, po_releases_all       pra
, jai_cmn_taxes_all     jcta
WHERE plla.po_header_id = pn_header_id
  AND plla.po_release_id IS NOT NULL
  AND jpt.po_header_id = plla.po_header_id
  AND jpt.po_line_id = plla.po_line_id
  AND jpt.line_location_id = plla.line_location_id
  AND pra.po_release_id = plla.po_release_id
  AND pra.approved_flag = 'Y'
  AND jcta.tax_id = jpt.tax_id
  AND NVL(jcta.inclusive_tax_flag, 'N') = pv_inclusive_tax_flag
GROUP BY jpt.currency;


ln_tax_amt       NUMBER;
lv_curr_tax_amt  NUMBER;
ln_conv_rate     NUMBER;
lv_line_Currency VARCHAR2(15);
lv_cancel_flag   VARCHAR2(1);
lv_func_currency VARCHAR2(15);
ln_org_id        NUMBER;
lv_procedure_name VARCHAR2(40):='Get_InAndEx_Tax_Total';
ln_dbg_level      NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER:=FND_LOG.LEVEL_PROCEDURE;
BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter function'
                  );
  END IF; --l_proc_level>=l_dbg_level

  ln_tax_amt := 0;

  IF (pv_document_type = 'GBA_ALL')
  THEN
    FOR r_po_rec IN
                   (SELECT po_header_id
                    FROM po_lines_all
                    WHERE from_header_id = pn_header_id)
    LOOP
      ln_tax_amt := ln_tax_amt + Get_Isp_InAndEx_Tax_Total('PO',r_po_rec.po_header_id,null,null, pv_inclusive_tax_flag);
    END LOOP; --r_po_rec IN

    RETURN ln_tax_amt;
  END IF; --(pv_document_type = 'GBA_ALL')

  IF (pv_document_type = 'GBA')
  THEN
	  IF (pn_line_id IS NOT NULL)
    THEN
      FOR r_po_rec IN (SELECT
                         po_header_id
                       , po_line_id
                       FROM po_lines_all
                       WHERE po_header_id = pn_header_id
                         AND po_line_id = pn_line_id)
      LOOP
        ln_tax_amt := ln_tax_amt + Get_Isp_InAndEx_Tax_Total('PO_LINE',r_po_rec.po_header_id,r_po_rec.po_line_id,null,pv_inclusive_tax_flag);
      END LOOP; -- r_po_rec IN
	  ELSE
      FOR r_po_rec IN (SELECT po_header_id
                       FROM po_lines_all
                       WHERE po_header_id = pn_header_id)
      LOOP
        ln_tax_amt := ln_tax_amt + Get_Isp_InAndEx_Tax_Total('PO',r_po_rec.po_header_id,null,null,pv_inclusive_tax_flag);
      END LOOP; --r_po_rec IN
	  END IF; --(pn_line_id IS NOT NULL)
	  RETURN ln_tax_amt;
  END IF; --(pv_document_type = 'GBA')

  IF (pv_document_type IN ('RFQ', 'PO'))
  THEN
    FOR po_rfq_tax_amt_rec IN po_rfq_tax_amt_csr
    LOOP
      OPEN conv_rate_rfq_csr(pn_header_id);
      FETCH conv_rate_rfq_csr
      INTO
        ln_conv_rate
      , lv_line_currency;
      CLOSE conv_rate_rfq_csr;

      IF (NVL(po_rfq_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))
      THEN
        IF (ln_conv_rate IS NULL)
        THEN
          ln_conv_rate := 1;
        END IF; --(ln_conv_rate IS NULL)
      ELSE
        ln_conv_rate := 1;
      END IF; --(NVL(r_rfq_po_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))

      ln_tax_amt := NVL(ln_tax_amt, 0) +
                      ((po_rfq_tax_amt_rec.tax_amount) / ln_conv_rate);

    END LOOP; -- po_rfq_tax_amt_rec IN po_rfq_tax_amt_csr

  ELSIF pv_document_type = 'PPO'
  THEN
    FOR ppo_tax_amt_rec IN ppo_tax_amt_csr
    LOOP
      OPEN conv_rate_rfq_csr(pn_header_id);
      FETCH conv_rate_rfq_csr
      INTO
        ln_conv_rate
      , lv_line_currency;
      CLOSE conv_rate_rfq_csr;

      IF (NVL(ppo_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))
      THEN
        IF (ln_conv_rate IS NULL)
        THEN
          ln_conv_rate := 1;
        END IF; --(ln_conv_rate IS NULL)
      ELSE
        ln_conv_rate := 1;
      END IF; --(NVL(ppo_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))

      ln_tax_amt := NVL(ln_tax_amt, 0) +
                    ((ppo_tax_amt_rec.tax_amount) / ln_conv_rate);
    END LOOP;

  ELSIF pv_document_type = 'BPA'
  THEN
    FOR bpa_tax_amt_rec IN bpa_tax_amt_csr
    LOOP
      OPEN conv_rate_rfq_csr(pn_header_id);
      FETCH conv_rate_rfq_csr
      INTO
        ln_conv_rate
      , lv_line_currency;
      CLOSE conv_rate_rfq_csr;

      IF (NVL(bpa_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))
      THEN
        IF (ln_conv_rate IS NULL)
        THEN
          ln_conv_rate := 1;
        END IF; --(ln_conv_rate IS NULL)
      ELSE
        ln_conv_rate := 1;
      END IF; --(NVL(bpa_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))

      ln_tax_amt := NVL(ln_tax_amt, 0) +
                    ((bpa_tax_amt_rec.tax_amount) / ln_conv_rate);
    END LOOP; --bpa_tax_amt_rec IN bpa_tax_amt_csr

  ELSIF pv_document_type IN ('SHIPMENT', 'RELEASE', 'PO_LINE', 'RELEASE_TOT')
  THEN
    IF (pv_document_type = 'SHIPMENT')
    THEN
      ln_tax_amt := 0;

      FOR shipments_tax_amt_rec IN shipments_tax_amt_csr
      LOOP
        OPEN conv_rate_rfq_csr(pn_header_id);
        FETCH conv_rate_rfq_csr
        INTO
          ln_conv_rate
        , lv_line_currency;
        CLOSE conv_rate_rfq_csr;

        IF (NVL(shipments_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))
        THEN
          IF (ln_conv_rate IS NULL)
          THEN
            ln_conv_rate := 1;
          END IF; --(ln_conv_rate IS NULL)
        ELSE
          ln_conv_rate := 1;
        END IF; --(NVL(shipments_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))

        ln_tax_amt := NVL(ln_tax_amt, 0) +
                      ((shipments_tax_amt_rec.tax_amount) / ln_conv_rate);

      END LOOP;

      RETURN ln_tax_amt;

    ELSIF pv_document_type = 'RELEASE'
    THEN
      ln_tax_amt := 0;

      FOR release_tax_amt_rec IN release_tax_amt_csr
      LOOP
        OPEN conv_rate_rfq_csr(pn_header_id);
        FETCH conv_rate_rfq_csr
        INTO
          ln_conv_rate
        , lv_line_currency;
        CLOSE conv_rate_rfq_csr;

        IF (NVL(release_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))
        THEN
          IF (ln_conv_rate IS NULL)
          THEN
            ln_conv_rate := 1;
          END IF; --(ln_conv_rate IS NULL)
        ELSE
          ln_conv_rate := 1;
        END IF; --(NVL(release_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))

        ln_tax_amt := NVL(ln_tax_amt, 0) +
                      ((release_tax_amt_rec.tax_amount) / ln_conv_rate);

      END LOOP;

      RETURN(ln_tax_amt);
    ELSIF pv_document_type = 'PO_LINE'
    THEN
      FOR po_line_tax_amt_rec IN po_line_tax_amt_csr
      LOOP
        OPEN conv_rate_rfq_csr(pn_header_id);
        FETCH conv_rate_rfq_csr
        INTO
          ln_conv_rate
        , lv_line_currency;
        CLOSE conv_rate_rfq_csr;

        IF (NVL(po_line_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))
        THEN
          IF (ln_conv_rate IS NULL)
          THEN
            ln_conv_rate := 1;
          END IF; --(ln_conv_rate IS NULL)
        ELSE
          ln_conv_rate := 1;
        END IF; --(NVL(po_line_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))

        ln_tax_amt := NVL(ln_tax_amt, 0) +
                      ((po_line_tax_amt_rec.tax_amount) / ln_conv_rate);

      END LOOP;

      RETURN ln_tax_amt;

    ELSIF pv_document_Type = 'RELEASE_TOT'
    THEN
      ln_tax_amt := 0;

      FOR release_tot_tax_amt_rec IN release_tot_tax_amt_csr
      LOOP
        OPEN conv_rate_rfq_csr(pn_header_id);
        FETCH conv_rate_rfq_csr
        INTO
          ln_conv_rate
        , lv_line_currency;
        CLOSE conv_rate_rfq_csr;

        IF (NVL(release_tot_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))
        THEN
          IF (ln_conv_rate IS NULL)
          THEN
            ln_conv_rate := 1;
          END IF; --(ln_conv_rate IS NULL)
        ELSE
          ln_conv_rate := 1;
        END IF; --(NVL(release_tot_tax_amt_rec.currency, '$$$') <> NVL(lv_line_currency, '$$$'))

        ln_tax_amt := NVL(ln_tax_amt, 0) +
                      ((release_tot_tax_amt_rec.tax_amount) / ln_conv_rate);

      END LOOP;

      RETURN ln_tax_amt;
    END IF; --(pv_document_type = 'SHIPMENT')
  END IF; --(pv_document_type IN ('RFQ', 'PO'))

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Exit function'
                  );
  END IF; --l_proc_level>=l_dbg_level

  RETURN ln_tax_amt;
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    RETURN (-1);
  END Get_Isp_InAndEx_Tax_Total;

END JAI_PO_HOOK_PKG;

/
