--------------------------------------------------------
--  DDL for Package Body ITG_SYNCSUPPLIERINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_SYNCSUPPLIERINBOUND_PVT" AS
/* ARCS: $Header: itgvssib.pls 120.16 2006/08/31 06:47:44 pvaddana noship $
 * CVS:  itgvssib.pls,v 1.32 2003/01/24 22:09:33 ecoe Exp
 */

  l_debug_level   NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'ITG_SyncSupplierInbound_PVT';
  l_address_style varchar2(20);
  g_action VARCHAR2(100);


  -- replace * with column listing
  PROCEDURE get_vendorsite_rec(
                                x IN OUT NOCOPY AP_VENDOR_PUB_PKG.r_vendor_site_rec_type,
                                p_vendorsite_id         IN NUMBER,
                                p_vendor_id     IN NUMBER) IS
  BEGIN

        g_action := 'vendor site details lookup';
        IF l_debug_level <= 1 then
                itg_debug_pub.add('Entering get_vendorsite_rec');
                itg_debug_pub.add('p_vendorsite_id ' || p_vendorsite_id);
                itg_debug_pub.add('p_vendor_id     ' || p_vendor_id);
        END IF;

        SELECT
        VENDOR_SITE_ID, VENDOR_ID,      VENDOR_SITE_CODE,
        ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
        ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
        ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
        ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
        ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
        ATTRIBUTE15, SHIP_TO_LOCATION_ID, SHIP_TO_LOCATION_CODE,
        BILL_TO_LOCATION_ID, BILL_TO_LOCATION_CODE, SHIP_VIA_LOOKUP_CODE,
        ADDRESS_LINE1, ADDRESS_LINE2,
        ADDRESS_LINE3, ADDRESS_LINE4, CITY,
        COUNTY, STATE, ZIP, COUNTRY, PROVINCE, AREA_CODE, PHONE,
        TELEX, FAX_AREA_CODE, FAX, LANGUAGE, INACTIVE_DATE,
        PURCHASING_SITE_FLAG, PAY_SITE_FLAG, RFQ_ONLY_SITE_FLAG,
        FOB_LOOKUP_CODE, FREIGHT_TERMS_LOOKUP_CODE, DISTRIBUTION_SET_ID, DISTRIBUTION_SET_NAME,
        ACCTS_PAY_CCID, PREPAY_CCID, ALWAYS_TAKE_DISC_FLAG,
        ATTENTION_AR_FLAG, PAY_DATE_BASIS_LOOKUP_CODE, PAY_GROUP_LOOKUP_CODE,
        HOLD_FUTURE_PAYMENTS_FLAG, HOLD_ALL_PAYMENTS_FLAG,
        HOLD_REASON, TERMS_DATE_BASIS, TAX_REPORTING_SITE_FLAG,
        TERMS_ID, TERMS_NAME, EXCLUDE_FREIGHT_FROM_DISC,
        HOLD_UNMATCHED_INV_FLAG, INVOICE_AMOUNT_LIMIT, CUSTOMER_NUM,
        PAYMENT_CURRENCY_CODE, PAYMENT_PRIORITY, INVOICE_CURRENCY_CODE,
        AWT_GROUP_ID, AWT_GROUP_NAME, ALLOW_AWT_FLAG,
        VALIDATION_NUMBER, CHECK_DIGITS, ADDRESS_STYLE, PAY_ON_CODE,
        DEFAULT_PAY_SITE_ID, PAY_ON_RECEIPT_SUMMARY_CODE, VENDOR_SITE_CODE_ALT, ADDRESS_LINES_ALT,
        BANK_CHARGE_BEARER, TP_HEADER_ID, GLOBAL_ATTRIBUTE_CATEGORY,
        GLOBAL_ATTRIBUTE1, GLOBAL_ATTRIBUTE2, GLOBAL_ATTRIBUTE3,
        GLOBAL_ATTRIBUTE4, GLOBAL_ATTRIBUTE5, GLOBAL_ATTRIBUTE6,
        GLOBAL_ATTRIBUTE7, GLOBAL_ATTRIBUTE8, GLOBAL_ATTRIBUTE9,
        GLOBAL_ATTRIBUTE10, GLOBAL_ATTRIBUTE11, GLOBAL_ATTRIBUTE12,
        GLOBAL_ATTRIBUTE13, GLOBAL_ATTRIBUTE14, GLOBAL_ATTRIBUTE15,
        GLOBAL_ATTRIBUTE16, GLOBAL_ATTRIBUTE17, GLOBAL_ATTRIBUTE18,
        GLOBAL_ATTRIBUTE19, GLOBAL_ATTRIBUTE20, ECE_TP_LOCATION_CODE,
        PCARD_SITE_FLAG, MATCH_OPTION, FUTURE_DATED_PAYMENT_CCID,
        CREATE_DEBIT_MEMO_FLAG, COUNTRY_OF_ORIGIN_CODE, SUPPLIER_NOTIF_METHOD, EMAIL_ADDRESS,
        PRIMARY_PAY_SITE_FLAG, ORG_ID
INTO
        x.VENDOR_SITE_ID, x.VENDOR_ID, x.VENDOR_SITE_CODE,
        x.ATTRIBUTE_CATEGORY, x.ATTRIBUTE1, x.ATTRIBUTE2,
        x.ATTRIBUTE3, x.ATTRIBUTE4, x.ATTRIBUTE5,
        x.ATTRIBUTE6, x.ATTRIBUTE7, x.ATTRIBUTE8,
        x.ATTRIBUTE9, x.ATTRIBUTE10, x.ATTRIBUTE11,
        x.ATTRIBUTE12, x.ATTRIBUTE13, x.ATTRIBUTE14,
        x.ATTRIBUTE15, x.SHIP_TO_LOCATION_ID, x.SHIP_TO_LOCATION_CODE,
        x.BILL_TO_LOCATION_ID, x.BILL_TO_LOCATION_CODE, x.SHIP_VIA_LOOKUP_CODE,
        x.ADDRESS_LINE1, x.ADDRESS_LINE2,
        x.ADDRESS_LINE3, x.ADDRESS_LINE4, x.CITY,
        x.COUNTY, x.STATE, x.ZIP, x.COUNTRY, x.PROVINCE, x.AREA_CODE, x.PHONE,
        x.TELEX, x.FAX_AREA_CODE, x.FAX, x.LANGUAGE, x.INACTIVE_DATE,
        x.PURCHASING_SITE_FLAG, x.PAY_SITE_FLAG, x.RFQ_ONLY_SITE_FLAG,
        x.FOB_LOOKUP_CODE, x.FREIGHT_TERMS_LOOKUP_CODE,x.DISTRIBUTION_SET_ID, x.DISTRIBUTION_SET_NAME,
        x.ACCTS_PAY_CODE_COMBINATION_ID, x.PREPAY_CODE_COMBINATION_ID, x.ALWAYS_TAKE_DISC_FLAG,
        x.ATTENTION_AR_FLAG, x.PAY_DATE_BASIS_LOOKUP_CODE, x.PAY_GROUP_LOOKUP_CODE,
        x.HOLD_FUTURE_PAYMENTS_FLAG, x.HOLD_ALL_PAYMENTS_FLAG,
        x.HOLD_REASON, x.TERMS_DATE_BASIS, x.TAX_REPORTING_SITE_FLAG,
        x.TERMS_ID, x.TERMS_NAME, x.EXCLUDE_FREIGHT_FROM_DISCOUNT,
        x.HOLD_UNMATCHED_INVOICES_FLAG, x.INVOICE_AMOUNT_LIMIT, x.CUSTOMER_NUM,
        x.PAYMENT_CURRENCY_CODE, x.PAYMENT_PRIORITY, x.INVOICE_CURRENCY_CODE,
        x.AWT_GROUP_ID, x.AWT_GROUP_NAME, x.ALLOW_AWT_FLAG,
        x.VALIDATION_NUMBER, x.CHECK_DIGITS, x.ADDRESS_STYLE, x.PAY_ON_CODE,
        x.DEFAULT_PAY_SITE_ID, x.PAY_ON_RECEIPT_SUMMARY_CODE, x.VENDOR_SITE_CODE_ALT, x.ADDRESS_LINES_ALT,
        x.BANK_CHARGE_BEARER, x.TP_HEADER_ID, x.GLOBAL_ATTRIBUTE_CATEGORY,
        x.GLOBAL_ATTRIBUTE1, x.GLOBAL_ATTRIBUTE2, x.GLOBAL_ATTRIBUTE3,
        x.GLOBAL_ATTRIBUTE4, x.GLOBAL_ATTRIBUTE5, x.GLOBAL_ATTRIBUTE6,
        x.GLOBAL_ATTRIBUTE7, x.GLOBAL_ATTRIBUTE8, x.GLOBAL_ATTRIBUTE9,
        x.GLOBAL_ATTRIBUTE10, x.GLOBAL_ATTRIBUTE11, x.GLOBAL_ATTRIBUTE12,
        x.GLOBAL_ATTRIBUTE13, x.GLOBAL_ATTRIBUTE14, x.GLOBAL_ATTRIBUTE15,
        x.GLOBAL_ATTRIBUTE16, x.GLOBAL_ATTRIBUTE17, x.GLOBAL_ATTRIBUTE18,
        x.GLOBAL_ATTRIBUTE19, x.GLOBAL_ATTRIBUTE20, x.ECE_TP_LOCATION_CODE,
        x.PCARD_SITE_FLAG, x.MATCH_OPTION, x.FUTURE_DATED_PAYMENT_CCID,
        x.CREATE_DEBIT_MEMO_FLAG, x.COUNTRY_OF_ORIGIN_CODE, x.SUPPLIER_NOTIF_METHOD, x.EMAIL_ADDRESS,
        x.PRIMARY_PAY_SITE_FLAG,x.ORG_ID
        FROM AP_VENDOR_SITES_V
        WHERE vendor_id = p_vendor_id
                and     vendor_site_id = p_vendorsite_id;

        IF l_debug_level <= 1 then
                itg_debug_pub.add('Exiting get_vendorsite_rec normal');
        END IF;
  EXCEPTION
         WHEN NO_DATA_FOUND THEN
            itg_msg.no_vendor_site(p_vendorsite_id);
            RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
                IF l_debug_level <= 1 THEN
                        itg_debug_pub.add('Error in get_vendorsite_rec ' || SQLCODE || ' - ' || SQLERRM,1);
                END IF;
                RAISE;
  END;

  -- replace * with column listing
  PROCEDURE get_vendor_rec(
                                x IN OUT NOCOPY AP_VENDOR_PUB_PKG.r_vendor_rec_type,
                                p_vendor_id      IN NUMBER) IS
  BEGIN
        g_action := 'vendor details lookup';
         IF l_debug_level <= 1 then
                itg_debug_pub.add('Entering get_vendor_rec');
                itg_debug_pub.add('p_vendor_id     ' || p_vendor_id);
         END IF;

        SELECT
                VENDOR_ID,  VENDOR_NAME,  VENDOR_NAME_ALT,  SUMMARY_FLAG,  ENABLED_FLAG,  EMPLOYEE_ID,
                                VENDOR_TYPE_LOOKUP_CODE,  CUSTOMER_NUM,  ONE_TIME_FLAG,  PARENT_VENDOR_ID,  MIN_ORDER_AMOUNT,
                                TERMS_ID,  SET_OF_BOOKS_ID,  ALWAYS_TAKE_DISC_FLAG,  PAY_DATE_BASIS_LOOKUP_CODE,
                                PAY_GROUP_LOOKUP_CODE,  PAYMENT_PRIORITY,  INVOICE_CURRENCY_CODE,  PAYMENT_CURRENCY_CODE,
                                INVOICE_AMOUNT_LIMIT,  HOLD_ALL_PAYMENTS_FLAG,  HOLD_FUTURE_PAYMENTS_FLAG,  HOLD_REASON,
                                TYPE_1099,  WITHHOLDING_STATUS_LOOKUP_CODE,  WITHHOLDING_START_DATE,
                                ORGANIZATION_TYPE_LOOKUP_CODE,  START_DATE_ACTIVE,  END_DATE_ACTIVE,
                                MINORITY_GROUP_LOOKUP_CODE,  WOMEN_OWNED_FLAG,  SMALL_BUSINESS_FLAG,  HOLD_FLAG,
                                PURCHASING_HOLD_REASON,  HOLD_BY,  HOLD_DATE,  TERMS_DATE_BASIS,  INSPECTION_REQUIRED_FLAG,
                                RECEIPT_REQUIRED_FLAG,  QTY_RCV_TOLERANCE,  QTY_RCV_EXCEPTION_CODE,
                                ENFORCE_SHIP_TO_LOCATION_CODE,  DAYS_EARLY_RECEIPT_ALLOWED,  DAYS_LATE_RECEIPT_ALLOWED,
                                RECEIPT_DAYS_EXCEPTION_CODE,  RECEIVING_ROUTING_ID,  ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
                                ALLOW_UNORDERED_RECEIPTS_FLAG,  HOLD_UNMATCHED_INVOICES_FLAG,  TAX_VERIFICATION_DATE,
                                NAME_CONTROL,  STATE_REPORTABLE_FLAG,  FEDERAL_REPORTABLE_FLAG,  ATTRIBUTE_CATEGORY,
                                ATTRIBUTE1,  ATTRIBUTE2,  ATTRIBUTE3,  ATTRIBUTE4,  ATTRIBUTE5,  ATTRIBUTE6,
                                ATTRIBUTE7,  ATTRIBUTE8,  ATTRIBUTE9,  ATTRIBUTE10,  ATTRIBUTE11,  ATTRIBUTE12,
                                ATTRIBUTE13,  ATTRIBUTE14,  ATTRIBUTE15,  AUTO_CALCULATE_INTEREST_FLAG,
                                VALIDATION_NUMBER,  EXCLUDE_FREIGHT_FROM_DISCOUNT,  TAX_REPORTING_NAME,  CHECK_DIGITS,
                                ALLOW_AWT_FLAG,  AWT_GROUP_ID,  AWT_GROUP_NAME,  GLOBAL_ATTRIBUTE1,  GLOBAL_ATTRIBUTE2,
                                GLOBAL_ATTRIBUTE3,  GLOBAL_ATTRIBUTE4,  GLOBAL_ATTRIBUTE5,  GLOBAL_ATTRIBUTE6,
                                GLOBAL_ATTRIBUTE7,  GLOBAL_ATTRIBUTE8,  GLOBAL_ATTRIBUTE9,  GLOBAL_ATTRIBUTE10,
                                GLOBAL_ATTRIBUTE11,  GLOBAL_ATTRIBUTE12,  GLOBAL_ATTRIBUTE13,  GLOBAL_ATTRIBUTE14,
                                GLOBAL_ATTRIBUTE15,  GLOBAL_ATTRIBUTE16,  GLOBAL_ATTRIBUTE17,  GLOBAL_ATTRIBUTE18,
                                GLOBAL_ATTRIBUTE19,  GLOBAL_ATTRIBUTE20,  GLOBAL_ATTRIBUTE_CATEGORY,  BANK_CHARGE_BEARER,
                                MATCH_OPTION,  CREATE_DEBIT_MEMO_FLAG,  TERMS_NAME,  NI_NUMBER
                INTO
                                x.VENDOR_ID,  x.VENDOR_NAME,  x.VENDOR_NAME_ALT,  x.SUMMARY_FLAG,  x.ENABLED_FLAG,  x.EMPLOYEE_ID,
                                x.VENDOR_TYPE_LOOKUP_CODE, x.CUSTOMER_NUM,  x.ONE_TIME_FLAG,  x.PARENT_VENDOR_ID,  x.MIN_ORDER_AMOUNT,
                                x.TERMS_ID,  x.SET_OF_BOOKS_ID,  x.ALWAYS_TAKE_DISC_FLAG,  x.PAY_DATE_BASIS_LOOKUP_CODE,
                                x.PAY_GROUP_LOOKUP_CODE,  x.PAYMENT_PRIORITY,  x.INVOICE_CURRENCY_CODE,  x.PAYMENT_CURRENCY_CODE,
                                x.INVOICE_AMOUNT_LIMIT,  x.HOLD_ALL_PAYMENTS_FLAG,  x.HOLD_FUTURE_PAYMENTS_FLAG,  x.HOLD_REASON,
                                x.TYPE_1099,  x.WITHHOLDING_STATUS_LOOKUP_CODE,  x.WITHHOLDING_START_DATE,
                                x.ORGANIZATION_TYPE_LOOKUP_CODE,  x.START_DATE_ACTIVE,  x.END_DATE_ACTIVE,
                                x.MINORITY_GROUP_LOOKUP_CODE,  x.WOMEN_OWNED_FLAG,  x.SMALL_BUSINESS_FLAG, x.HOLD_FLAG,
                                x.PURCHASING_HOLD_REASON, x.HOLD_BY,  x.HOLD_DATE,  x.TERMS_DATE_BASIS,  x.INSPECTION_REQUIRED_FLAG,
                                x.RECEIPT_REQUIRED_FLAG,  x.QTY_RCV_TOLERANCE,  x.QTY_RCV_EXCEPTION_CODE,
                                x.ENFORCE_SHIP_TO_LOCATION_CODE,  x.DAYS_EARLY_RECEIPT_ALLOWED,  x.DAYS_LATE_RECEIPT_ALLOWED,
                                x.RECEIPT_DAYS_EXCEPTION_CODE,  x.RECEIVING_ROUTING_ID,  x.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
                                x.ALLOW_UNORDERED_RECEIPTS_FLAG,  x.HOLD_UNMATCHED_INVOICES_FLAG,  x.TAX_VERIFICATION_DATE,
                                x.NAME_CONTROL,  x.STATE_REPORTABLE_FLAG,  x.FEDERAL_REPORTABLE_FLAG,  x.ATTRIBUTE_CATEGORY,
                                x.ATTRIBUTE1, x.ATTRIBUTE2,  x.ATTRIBUTE3,  x.ATTRIBUTE4, x.ATTRIBUTE5,  x.ATTRIBUTE6,
                                x.ATTRIBUTE7,  x.ATTRIBUTE8, x.ATTRIBUTE9,  x.ATTRIBUTE10,  x.ATTRIBUTE11,  x.ATTRIBUTE12,
                                x.ATTRIBUTE13,  x.ATTRIBUTE14,  x.ATTRIBUTE15,  x.AUTO_CALCULATE_INTEREST_FLAG,
                                x.VALIDATION_NUMBER,  x.EXCLUDE_FREIGHT_FROM_DISCOUNT,  x.TAX_REPORTING_NAME,  x.CHECK_DIGITS,
                                x.ALLOW_AWT_FLAG,  x.AWT_GROUP_ID,  x.AWT_GROUP_NAME,  x.GLOBAL_ATTRIBUTE1, x.GLOBAL_ATTRIBUTE2,
                                x.GLOBAL_ATTRIBUTE3,  x.GLOBAL_ATTRIBUTE4, x.GLOBAL_ATTRIBUTE5,  x.GLOBAL_ATTRIBUTE6,
                                x.GLOBAL_ATTRIBUTE7,  x.GLOBAL_ATTRIBUTE8,  x.GLOBAL_ATTRIBUTE9,  x.GLOBAL_ATTRIBUTE10,
                                x.GLOBAL_ATTRIBUTE11,  x.GLOBAL_ATTRIBUTE12,  x.GLOBAL_ATTRIBUTE13,  x.GLOBAL_ATTRIBUTE14,
                                x.GLOBAL_ATTRIBUTE15, x.GLOBAL_ATTRIBUTE16,  x.GLOBAL_ATTRIBUTE17,  x.GLOBAL_ATTRIBUTE18,
                                x.GLOBAL_ATTRIBUTE19,  x.GLOBAL_ATTRIBUTE20, x.GLOBAL_ATTRIBUTE_CATEGORY,  x.BANK_CHARGE_BEARER,
                                x.MATCH_OPTION,  x.CREATE_DEBIT_MEMO_FLAG,  x.TERMS_NAME,  x.NI_NUMBER
                FROM  ap_vendors_v
                WHERE  vendor_id = p_vendor_id ;

                IF l_debug_level <= 1 then
                        itg_debug_pub.add('Exiting get_vendor_rec normal');
                END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            itg_msg.vendor_not_found(p_vendor_id);
            RAISE FND_API.G_EXC_ERROR;
           WHEN OTHERS THEN
                IF l_debug_level <= 1 THEN
                        itg_debug_pub.add('Error in get_vendor_rec ' || SQLCODE || ' - ' || SQLERRM,1);
                END IF;
                RAISE;
      END;


  -- no change
  FUNCTION Is_vinfo_rec_Missing(
    p_vinfo_rec IN vinfo_rec_type
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN (p_vinfo_rec.syncind    IS NULL AND
            p_vinfo_rec.vendor_id  IS NULL AND
            p_vinfo_rec.currency   IS NULL AND
            p_vinfo_rec.paymethod  IS NULL AND
            p_vinfo_rec.terms_id   IS NULL AND
            p_vinfo_rec.vat_num    IS NULL AND
            p_vinfo_rec.ctl_date   IS NULL AND
            p_vinfo_rec.addr_style IS NULL);
  END Is_vinfo_rec_Missing;

   -- no change
   FUNCTION flag_value(p_flag BOOLEAN) RETURN VARCHAR2 IS
   BEGIN
      IF p_flag THEN
        RETURN 'Y';
      ELSE
        RETURN 'N';
      END IF;
   END;


  PROCEDURE validate_vendor_params(
    p_syncind          IN         VARCHAR2,          /* 'A', 'C', 'D' */
    p_name             IN         VARCHAR2,          /* name1 */
    p_onetime          IN         VARCHAR2 := NULL,  /* onetime */
    p_partnerid        IN         VARCHAR2 := NULL,  /* partnrid */
    p_active           IN         NUMBER   := NULL,  /* active */
    p_currency         IN         VARCHAR2 := NULL,  /* currency */
    p_dunsnumber       IN         VARCHAR2 := NULL,  /* dunsnumber */
    p_parentid         IN         NUMBER   := NULL,  /* parentid */
    p_paymethod        IN         VARCHAR2 := NULL,  /* paymethod */
    p_taxid            IN         VARCHAR2 := NULL,  /* taxid */
    p_termid           IN         VARCHAR2 := NULL,  /* termid */
    p_us_flag          IN         VARCHAR2 := 'Y',   /* userarea.ref_usflag */
    p_date             IN         DATE     := NULL,  /* controlarea.datetime */
    p_org              IN         VARCHAR2           /* MOAC */
  ) IS
        l_found       NUMBER;
      l_var         VARCHAR2(200);
      l_param_name  VARCHAR2(200);
      l_param_value VARCHAR2(200);
 BEGIN
    g_action := 'Sync-vendor parameter validation';

    IF (l_Debug_Level <= 1) THEN
       itg_debug_pub.Add(g_action,1);
    END IF;

    IF p_org IS NULL THEN                               -- MOAC
       itg_msg.invalid_org(p_org);
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF    NVL(UPPER(p_syncind), 'z') NOT IN ('A', 'C', 'D') THEN
       l_param_name  := 'SYNCIND';
       l_param_value := p_syncind;
    ELSIF p_name IS NULL THEN
       l_param_name  := 'NAME';
    END IF;

    IF l_param_name IS NOT NULL THEN
       ITG_MSG.missing_element_value(l_param_name, l_param_value);
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_paymethod IS NOT NULL THEN
       IF (l_Debug_Level <= 1) THEN
          itg_debug_pub.Add('SV- Checking paymethod', 1);
       END IF;


       BEGIN
          SELECT 1
          INTO   l_found
          FROM   ap_lookup_codes
          WHERE  upper(lookup_code) = upper(p_paymethod)
            AND  lookup_type = 'PAYMENT METHOD';
       EXCEPTION
              WHEN NO_DATA_FOUND THEN
                ITG_MSG.missing_element_value('PAYMETHOD', p_paymethod);
                RAISE FND_API.G_EXC_ERROR;
       END;
    END IF;

    IF p_termid IS NOT NULL THEN
       IF (l_Debug_Level <= 1) THEN
          itg_debug_pub.Add('SV- Checking termid', 1);
       END IF;

       BEGIN
          SELECT term_id
          INTO   l_var
          FROM   ap_terms
          WHERE  upper(name) = upper(p_termid);
       EXCEPTION
          WHEN OTHERs THEN
             ITG_MSG.missing_element_value('TERMID', p_termid);
             RAISE FND_API.G_EXC_ERROR;
       END;

    END IF;

    BEGIN
       l_var := to_number(p_onetime);
    EXCEPTION
       WHEN OTHERS THEN
          ITG_MSG.missing_element_value('ONETIME', p_onetime);
          RAISE FND_API.G_EXC_ERROR;
    END;

    IF UPPER(p_syncind) = 'A' THEN
       select count(*)
       into  l_var
       from ap_vendors_v
       Where upper(vendor_name) = upper(p_name);

       IF to_number(l_var) > 0 THEN
          itg_msg.dup_vendor;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF p_currency IS NOT NULL THEN

            select count(*)
            into   l_var
            from   fnd_currencies
            where  currency_code = nvl(p_currency,'USD');

            IF to_number(l_var) = 0 THEN
            ITG_MSG.missing_element_value('CURRENCY', p_currency);
                  RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

    select count(*)
    into   l_var
    from   HR_ALL_ORGANIZATION_UNITS
    where  organization_id = p_org;

    IF to_number(l_var) = 0 THEN
            ITG_MSG.missing_element_value('ORGID', p_org);
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- change
    select count(*)
    into   l_var
    from   ap_vendors_v
    where  nvl(vendor_number,'@@')   = nvl(to_char(p_partnerid),'@@')
    and    nvl(upper(p_name),'@@')   <> nvl(Upper(vendor_name),'@@');

    IF to_number(l_var) > 0 THEN
       itg_msg.sup_number_exists(p_partnerid);
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_Debug_Level <= 1) THEN
       itg_debug_pub.Add('Validation complete', 1);
    END IF;
 EXCEPTION
           WHEN OTHERS THEN
                IF l_debug_level <= 1 THEN
                        itg_debug_pub.add('Error in validate_vendor_params ' || SQLCODE || ' - ' || SQLERRM,1);
                END IF;
                RAISE;
 END;


PROCEDURE default_vendor_params
        (r_vendor_rec   IN OUT NOCOPY AP_VENDOR_PUB_PKG.r_vendor_rec_type,
       vinfo_rec                IN OUT NOCOPY vinfo_rec_type,
         x_org          IN OUT NOCOPY VARCHAR2)
IS
        l_dummy_char VARCHAR2(200);
        l_dummy_num  NUMBER;
        l_dummy_date DATE;
BEGIN
          g_action := 'defaulting vendor parameters';

          IF (l_Debug_Level <= 1) THEN
            itg_debug_pub.Add('SV - default vendor parameters', 1);
          END IF;

          AP_Apxvdmvd_PKG.Initialize(
            x_user_defined_vendor_num_code => l_dummy_char,
            x_manual_vendor_num_type       => l_dummy_char,
            x_rfq_only_site_flag           => l_dummy_char,
            x_ship_to_location_id          => l_dummy_char,
            x_ship_to_location_code        => l_dummy_char,
            x_bill_to_location_id          => l_dummy_char,
            x_bill_to_location_code        => l_dummy_char,
            x_fob_lookup_code              => l_dummy_char,
            x_freight_terms_lookup_code    => l_dummy_char,
            x_terms_id                     => l_dummy_num,
            x_terms_disp                   => l_dummy_char,
            x_always_take_disc_flag        => r_vendor_rec.always_take_disc_flag,
            x_invoice_currency_code        => l_dummy_char,
            x_org_id                       => x_org,
            x_set_of_books_id              => r_vendor_rec.set_of_books_id,
            x_short_name                   => l_dummy_char,
            x_payment_currency_code        => l_dummy_char,
            x_accts_pay_ccid               => l_dummy_char,
            x_future_dated_payment_ccid    => l_dummy_char,
            x_prepay_code_combination_id   => l_dummy_num,
            x_vendor_pay_group_lookup_code => l_dummy_char,
            x_sys_auto_calc_int_flag       => l_dummy_char,
            x_terms_date_basis             => r_vendor_rec.terms_date_basis,
            x_terms_date_basis_disp        => l_dummy_char,
            x_chart_of_accounts_id         => l_dummy_num,
            x_fob_lookup_disp              => l_dummy_char,
            x_freight_terms_lookup_disp    => l_dummy_char,
            x_vendor_pay_group_disp        => l_dummy_char,
            x_fin_require_matching         => l_dummy_char,
            x_sys_require_matching         => l_dummy_char,
            x_fin_match_option             => l_dummy_char,
            x_po_create_dm_flag            => r_vendor_rec.create_debit_memo_flag,
            x_exclusive_payment            => l_dummy_char,
            x_vendor_auto_int_default      => l_dummy_char,
            x_inventory_organization_id    => l_dummy_num,
            x_ship_via_lookup_code         => l_dummy_char,
            x_ship_via_disp                => l_dummy_char,
            x_sysdate                      => l_dummy_date,
            x_enforce_ship_to_loc_code     => r_vendor_rec.enforce_ship_to_location_code,
            x_receiving_routing_id         => r_vendor_rec.receiving_routing_id,
            x_qty_rcv_tolerance            => r_vendor_rec.qty_rcv_tolerance,
            x_qty_rcv_exception_code       => r_vendor_rec.qty_rcv_exception_code,
            x_days_early_receipt_allowed   => r_vendor_rec.days_early_receipt_allowed,
            x_days_late_receipt_allowed    => r_vendor_rec.days_late_receipt_allowed,
            x_allow_sub_receipts_flag      => r_vendor_rec.allow_substitute_receipts_flag,
            x_allow_unord_receipts_flag    => r_vendor_rec.allow_unordered_receipts_flag,
            x_receipt_days_exception_code  => r_vendor_rec.receipt_days_exception_code,
            x_enforce_ship_to_loc_disp     => l_dummy_char,
            x_qty_rcv_exception_disp       => l_dummy_char,
            x_receipt_days_exception_disp  => l_dummy_char,
            x_receipt_required_flag        => r_vendor_rec.receipt_required_flag,
            x_inspection_required_flag     => r_vendor_rec.inspection_required_flag,
            x_payment_method_lookup_code   => l_dummy_char,
            x_payment_method_disp          => l_dummy_char,
            x_pay_date_basis_lookup_code   => r_vendor_rec.pay_date_basis_lookup_code,
            x_pay_date_basis_disp          => l_dummy_char,
            x_receiving_routing_name       => l_dummy_char,
            x_AP_inst_flag                 => l_dummy_char,
            x_PO_inst_flag                 => l_dummy_char,
            x_home_country_code            => l_dummy_char,
            x_default_country_code         => l_dummy_char,
            x_default_country_disp         => l_dummy_char,
            x_default_awt_group_id         => l_dummy_num,
            x_default_awt_group_name       => l_dummy_char,
            x_allow_awt_flag               => r_vendor_rec.allow_awt_flag,
            x_base_currency_code           => l_dummy_char,
            x_address_style                => vinfo_rec.addr_style,
            x_use_bank_charge_flag         => l_dummy_char,
            x_bank_charge_bearer           => r_vendor_rec.bank_charge_bearer,
            x_calling_sequence             => 'APXVDMVD'
          );

          IF (l_Debug_Level <= 1) THEN
            itg_debug_pub.Add('Exiting default vendor parameters', 1);
          END IF;
 EXCEPTION
           WHEN OTHERS THEN
                IF l_debug_level <= 1 THEN
                        itg_debug_pub.add('Error in default_vendor_params ' || SQLCODE || ' - ' || SQLERRM,1);
                END IF;
                itg_msg.apicallret('AP_Apxvdmvd_PKG.Initialize','U',substr((SQLCODE || SQLERRM),1,200));
                RAISE FND_API.G_EXC_ERROR;
 END;



  PROCEDURE Sync_Vendor(
    x_return_status    OUT NOCOPY VARCHAR2,          /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,          /* VARCHAR2(2000) */

    p_syncind          IN         VARCHAR2,          /* 'A', 'C', 'D' */
    p_name             IN         VARCHAR2,          /* name1 */
    p_onetime          IN         VARCHAR2 := NULL,  /* onetime */
    p_partnerid        IN         VARCHAR2 := NULL,  /* partnrid */
    p_active           IN         NUMBER   := NULL,  /* active */
    p_currency         IN         VARCHAR2 := NULL,  /* currency */
    p_dunsnumber       IN         VARCHAR2 := NULL,  /* dunsnumber */
    p_parentid         IN         NUMBER   := NULL,  /* parentid */
    p_paymethod        IN         VARCHAR2 := NULL,  /* paymethod */
    p_taxid            IN         VARCHAR2 := NULL,  /* taxid */
    p_termid           IN         VARCHAR2 := NULL,  /* termid */
    p_us_flag          IN         VARCHAR2 := 'Y',   /* userarea.ref_usflag */
    p_date             IN         DATE     := NULL,  /* controlarea.datetime */
    p_org              IN         VARCHAR2,           /* MOAC */
    x_vinfo_rec        OUT NOCOPY vinfo_rec_type
  ) IS
    r_vendor_rec AP_VENDOR_PUB_PKG.r_vendor_rec_type;
    l_org_rec      HZ_PARTY_V2PUB.organization_rec_type; --To Fix Bug :5186022
    l_party_object_version_number  NUMBER;
    l_profile_id number;
    l_party_number   VARCHAR2(30);
    l_duns_number  VARCHAR2(30);
    l_syncind varchar2(200);
    l_term_id varchar2(200);
    l_ret_status varchar2(200);
    l_ret_count number;
    l_ret_msg  varchar2(2000);
    l_party_id number;
    l_num_1099 varchar2(200);
    l_org       varchar2(20);
    l_override_vendornum NUMBER;
 BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    g_action := 'Supplier synchronization';
    SAVEPOINT Sync_Vendor_PVT;

    -- now in wrapperFND_MSG_PUB.Initialize;
    IF (l_Debug_Level <= 1) THEN
        itg_debug_pub.Add('--- Parameters Obtained ---' ,1);
        itg_debug_pub.Add('SV - Top of procedure.' ,1);
        itg_debug_pub.Add('SV - p_syncind '     ||p_syncind,1);
        itg_debug_pub.Add('SV - p_name '        ||p_name,1);
        itg_debug_pub.Add('SV - p_onetime '     ||p_onetime,1);
        itg_debug_pub.Add('SV - p_partnerid '   ||p_partnerid,1);
        itg_debug_pub.Add('SV - p_active '      ||p_active,1);
        itg_debug_pub.Add('SV - p_currency '    ||p_currency,1);
        itg_debug_pub.Add('SV - p_dunsnumber '  ||p_dunsnumber,1);
        itg_debug_pub.Add('SV - p_parentid '    ||p_parentid,1);
        itg_debug_pub.Add('SV - p_paymethod'    ||p_paymethod,1);
        itg_debug_pub.Add('SV - p_taxid '       ||p_taxid,1);
        itg_debug_pub.Add('SV - p_termid '      ||p_termid,1);
        itg_debug_pub.Add('SV - p_us_flag '     ||p_us_flag,1);
        itg_debug_pub.Add('SV - p_date '        ||p_date,1);
        itg_debug_pub.Add('SV - org    '        ||p_org,1);
    END IF;

    BEGIN
       MO_GLOBAL.set_policy_context('S', p_org); -- MOAC
    EXCEPTION
       WHEN OTHERS THEN
          itg_msg.invalid_org(p_org);
          IF l_debug_level <= 6 THEN
             itg_debug_pub.Add('MO_GLOBAL.set_policy_context ' || SQLCODE || ' - ' || SQLERRM,6);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
    END;

    IF l_debug_level <= 1 THEN
       itg_debug_pub.add('Before sync vendor, parameter validation ',1);
    END IF;

    validate_vendor_params(
       p_syncind          =>    p_syncind,
       p_name             =>    p_name,
       p_onetime          =>    p_onetime,
       p_partnerid        =>    p_partnerid,
       p_active           =>    p_active,
       p_currency         =>    p_currency,
       p_dunsnumber       =>    p_dunsnumber,
       p_parentid         =>    p_parentid,
       p_paymethod        =>    p_paymethod,
       p_taxid            =>    p_taxid,
       p_termid           =>    p_termid,
       p_us_flag          =>    p_us_flag,
       p_date             =>    p_date,
       p_org              =>    p_org);

    IF l_debug_level <= 1 THEN
       itg_debug_pub.add('After sync vendor, parameter validation ',1);
    END IF;

    l_syncind := UPPER(p_syncind);
    IF p_termid IS NOT NULL THEN
            SELECT term_id
            INTO   l_term_id
            FROM   ap_terms
            WHERE  upper(name) = upper(p_termid);
    ELSE
        l_term_id := null;
    END IF;

    IF l_debug_level <= 1 THEN
       itg_debug_pub.add('SV - Termid - ' || l_term_id ,1);
    END IF;

    x_vinfo_rec.syncind     := UPPER(p_syncind);
    x_vinfo_rec.currency    := p_currency;
    x_vinfo_rec.paymethod   := p_paymethod;
    x_vinfo_rec.terms_id    := l_term_id;
    x_vinfo_rec.terms_name  := p_termid;
    x_vinfo_rec.ctl_date    := NVL(p_date, SYSDATE);

    IF p_us_flag = 'N' THEN
        x_vinfo_rec.vat_num  := p_taxid;
    ELSE
        x_vinfo_rec.vat_num  := NULL;
        l_num_1099           := p_taxid;
    END IF;

   IF l_syncind = 'A' THEN

     l_org := p_org;
     default_vendor_params(r_vendor_rec,x_vinfo_rec,l_org);

      IF l_debug_level <= 1 THEN
         itg_debug_pub.add('SV - Vendor params defaulted',1);
      END IF;

      r_vendor_rec.one_time_flag := flag_value(NVL(to_number(p_onetime), 0) <> 0);
      r_vendor_rec.summary_flag  := flag_value(NVL(p_parentid, 0) <> 0);
      r_vendor_rec.enabled_flag  := flag_value(NVL(p_active,   1) <> 0);
      r_vendor_rec.terms_id        := l_term_id;
      r_vendor_rec.terms_name      := p_termid;
      r_vendor_rec.invoice_currency_code    := p_currency;
      r_vendor_rec.payment_currency_code    := p_currency;
      r_vendor_rec.segment1                 :=  p_partnerid;
      r_vendor_rec.vendor_name              := p_name;
      r_vendor_rec.vendor_type_lookup_code  := 'VENDOR';
      r_vendor_rec.parent_vendor_id          := p_parentid;
      r_vendor_rec.payment_priority         := '1';
      r_vendor_rec.match_option             := 'P';
      r_vendor_rec.terms_date_basis         := NVL(r_vendor_rec.terms_date_basis, 'Goods Received');


      IF l_debug_level <= 1 THEN
         itg_debug_pub.add('Call to create vendor',1);
      END IF;

      ap_vendor_pub_pkg.Create_Vendor(
           p_api_version        => '1.0',
           x_return_status      => l_ret_status,
           x_msg_count          => l_ret_count,
           x_msg_data           => l_ret_msg,
           p_vendor_rec         => r_vendor_rec,
           x_vendor_id          => r_vendor_rec.vendor_id,
           x_party_id           => l_party_id);

      x_vinfo_rec.vendor_id  := r_vendor_rec.vendor_id;

      IF l_debug_level <= 1 THEN
         itg_debug_pub.add('Create vendor returns - ' || l_ret_status || ' - ' || l_ret_msg ,1);
         ITG_Debug_pub.add('SV - vendor_id ' || r_vendor_rec.vendor_id,1);
        END IF;

      IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_level <= 6 THEN
                        itg_debug_pub.add('Error occured in Create Vendor',6);
                END IF;
                itg_msg.apicallret('Ap_vendor_pub_pkg.Create_Vendor',l_ret_status,substr(l_ret_msg,1,200));
            RAISE FND_API.G_EXC_ERROR;
      END IF;

      g_action := 'verifying vendor_number';
        BEGIN
                SELECT vendor_number
                INTO     l_override_vendornum
                FROM    ap_vendors_v
                WHERE   vendor_id = r_vendor_rec.vendor_id;
                IF l_debug_level <= 1 THEN
                      itg_debug_pub.Add('SV - segment1    '|| l_override_vendornum ,1);
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        IF l_debug_level <= 6 THEN
                                itg_debug_pub.add('Error occured while retrieving vendor_number',6);
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
        END;

      itg_debug_pub.Add('SV - p_partnerid '||p_partnerid  ,1);

      IF l_override_vendornum <> p_partnerid THEN
         IF (l_Debug_Level <= 1) THEN
            itg_debug_pub.Add('SV - Segment1 automatically allocated, overriding.' ,1);
         END IF;
         l_syncind          := 'C';
      END IF;
   -- sync ind <> A (else) condtion block begins
   ELSE
      g_action := 'Vendor record update';

      IF (l_Debug_Level <= 1) THEN
         itg_debug_pub.Add('SV - Changing the vendor info.',1);
      END IF;

      BEGIN
         SELECT vendor_id
         INTO   r_vendor_rec.vendor_id
         FROM   ap_vendors_v
         WHERE  vendor_name = p_name;

         x_vinfo_rec.vendor_id  := r_vendor_rec.vendor_id;

         IF (l_Debug_Level <= 1) THEN
            itg_debug_pub.Add('x_vinfo_rec.vendor_id - '|| x_vinfo_rec.vendor_id,1);
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            itg_msg.vendor_not_found(p_name);
            RAISE FND_API.G_EXC_ERROR;
      END;
   END IF; -- syncind conidition block ends


   /*either direct syncid or syncind=c due to segment mismatch */
   IF l_syncind = 'C' THEN

      g_action := 'Vendor record update';

        get_vendor_rec(r_vendor_rec,x_vinfo_rec.vendor_id);

      IF (l_Debug_Level <= 1) THEN
        itg_debug_pub.Add('Obtained vendor details ',1);
      END IF;


      r_vendor_rec.one_time_flag := flag_value(NVL(to_number(p_onetime), 0) <> 0);
      r_vendor_rec.summary_flag  := flag_value(NVL(p_parentid, 0) <> 0);
      -- 5258978 r_vendor_rec.enabled_flag  := flag_value((p_active,   1) <> 0);
      r_vendor_rec.terms_id        := l_term_id;
      r_vendor_rec.terms_name      := p_termid;
      r_vendor_rec.invoice_currency_code := p_currency;
      r_vendor_rec.payment_currency_code := p_currency;
      r_vendor_rec.segment1      :=  NVL(p_partnerid, r_vendor_rec.segment1);
      r_vendor_rec.vendor_name   := p_name;
      r_vendor_rec.vendor_type_lookup_code  := 'VENDOR';
      r_vendor_rec.parent_vendor_id := NVL(p_parentid, r_vendor_rec.parent_vendor_id);
      r_vendor_rec.payment_priority := '1';
      r_vendor_rec.match_option := 'P';
      r_vendor_rec.terms_date_basis := NVL(r_vendor_rec.terms_date_basis, 'Goods Received');

      -- 5258978
      IF NVL(p_active,   1) = 0 THEN
            r_vendor_rec.enabled_flag    := 'N';
            r_vendor_rec.END_DATE_ACTIVE := sysdate;
      ELSE
            r_vendor_rec.END_DATE_ACTIVE := sysdate + 3560;
            r_vendor_rec.enabled_flag    := 'Y';
      END IF;

        IF l_override_vendornum IS NOT NULL THEN
                r_vendor_rec.segment1 := p_partnerid;
        END IF;


        IF (l_Debug_Level <= 1) THEN
        itg_debug_pub.Add('SV - vendor_id'||r_vendor_rec.vendor_id ,1);
      END IF;

        ap_vendor_pub_pkg.update_vendor(
           p_api_version        => '1.0',
           x_return_status      => l_ret_status,
           x_msg_count          => l_ret_count,
           x_msg_data           => l_ret_msg,
           p_vendor_rec         => r_vendor_rec,
           p_vendor_id          => r_vendor_rec.vendor_id
           );

      IF l_debug_level <= 1 THEN
         itg_debug_pub.add('Update vendor returns - ' || l_ret_status || ' - ' || l_ret_msg ,1);
         ITG_Debug_pub.add('SV - vendor_id ' || r_vendor_rec.vendor_id,1);
        END IF;

     /*Added following block to fix Bug :5186022  */

     BEGIN
        SELECT PARTY_ID
        into l_party_id
        FROM AP_SUPPLIERS
        WHERE VENDOR_ID=r_vendor_rec.vendor_id;

        select object_version_number,
        party_number,
        duns_number_c
        into l_party_object_version_number,
        l_party_number,
        l_duns_number
        from hz_parties
        where party_id=l_party_id;

        IF (l_Debug_Level <= 1) THEN
           itg_debug_pub.Add('party_id - '|| l_party_id,1);
           itg_debug_pub.Add('party_object_version_number - '|| l_party_object_version_number,1);
           itg_debug_pub.Add('party_number - '|| l_party_number,1);
           itg_debug_pub.Add('party_duns_number - '|| l_duns_number,1);

        END IF;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                IF (l_Debug_Level <= 1) THEN
                      itg_debug_pub.Add('Couldn''t find party_id  from ap_suppliers or obj_ver,party_num,duns_num from  hz_parties ');
               END IF;
             RAISE FND_API.G_EXC_ERROR;
          END;

    l_org_rec.duns_number_c := NVL(p_dunsnumber ,l_duns_number);
    l_org_rec.party_rec.party_number :=l_party_number;
    l_org_rec.party_rec.party_id := l_party_id;
      HZ_PARTY_V2PUB.update_organization (
           p_init_msg_list               => FND_API.G_FALSE,
           p_organization_rec            => l_org_rec,
           p_party_object_version_number => l_party_object_version_number,
           x_profile_id                  => l_party_id,
           x_return_status               => l_ret_status,
           x_msg_count                   => l_ret_count,
           x_msg_data                    => l_ret_msg
           );



      IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug_level <= 6 THEN
                        itg_debug_pub.add('Error occured in update Vendor or update organization',6);
                END IF;
            itg_msg.apicallret('ap_vendor_pub_pkg.Update_vendor or hz_party_v2pub.update_organization returns-',l_ret_status,substr(l_ret_msg,1,200));
            RAISE FND_API.G_EXC_ERROR;
      END IF;


   END IF;

   IF (l_Debug_Level <= 1) THEN
      itg_debug_pub.Add('Commiting work',1);
   END IF;

   COMMIT WORK;

   IF (l_Debug_Level <= 2) THEN
      itg_debug_pub.Add('EXITING  - Sync_Vendor.', 2);
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Sync_Vendor_PVT;
      COMMIT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      ITG_msg.checked_error(g_action);
      IF (l_Debug_Level <= 6) THEN
         itg_debug_pub.Add('EXITING  - Sync_Vendor:: ERROR', 6);
      END IF;

   WHEN OTHERS THEN
        ROLLBACK TO Sync_Vendor_PVT;
        COMMIT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        itg_debug.msg('Unexpected error (Vendor sync) - ' || substr(SQLERRM,1,255),true);
        ITG_msg.unexpected_error(g_action);
        IF (l_Debug_Level <= 6) THEN
          itg_debug_pub.Add('EXITING  - Sync_Vendor:: ERROR', 6);
        END IF;

      -- Removed FND_MSG_PUB.Count_And_Get
END Sync_Vendor;


  PROCEDURE validate_vendorsite_params(
    p_addrline1        IN         VARCHAR2 ,
    p_addrline2        IN         VARCHAR2 ,
    p_addrline3        IN         VARCHAR2 ,
    p_addrline4        IN         VARCHAR2 ,
    p_city             IN         VARCHAR2 ,
    p_country          IN         VARCHAR2 ,
    p_county           IN         VARCHAR2 ,
    p_site_code        IN         VARCHAR2 ,
    p_fax              IN         VARCHAR2 ,
    p_zip              IN         VARCHAR2 ,
    p_state            IN         VARCHAR2 ,
    p_phone            IN         VARCHAR2 ,
    p_org              IN         VARCHAR2 ,
    p_purch_site       IN         VARCHAR2 ,
    p_pay_site         IN         VARCHAR2 ,
    p_rfq_site         IN         VARCHAR2 ,
    p_pc_site          IN         VARCHAR2 ,
    p_vat_code         IN         VARCHAR2 ,
    p_vinfo_rec        IN         vinfo_rec_type
  )IS
        l_var   NUMBER;
        l_element       VARCHAR2(30);
        l_value         VARCHAR2(30);
  BEGIN
        g_action := 'vendor-site parameter validation';

        BEGIN
                SELECT count(*) INTO l_var
        FROM   FND_TERRITORIES
              WHERE  TERRITORY_CODE = p_country
        AND    OBSOLETE_FLAG = 'N';
        EXCEPTION
                WHEN OTHERS THEN
                        itg_msg.missing_element_value('COUNTRY',p_country);
                        RAISE FND_API.G_EXC_ERROR;

        END;

        l_element := null;

        IF  NVL(UPPER(p_purch_site),'@') NOT IN ('Y','N') THEN
                l_element       := 'ORACLEITG.PURSITE';
                l_value         := p_purch_site;
        ELSIF NVL(UPPER(p_pay_site),'@') NOT IN ('Y','N') THEN
                l_element       := 'ORACLEITG.PAYSITE';
                l_value := p_pay_site;
        ELSIF NVL(UPPER(p_rfq_site),'@') NOT IN ('Y','N') THEN
                l_element       := 'ORACLEITG.RFQSITE';
                l_value         := p_rfq_site;
        ELSIF NVL(UPPER(p_pc_site),'@') NOT IN ('Y','N') THEN
                l_element       := 'ORACLEITG.PCSITE';
                l_value         := p_pc_site;
      ELSIF p_site_code IS NULL THEN
                l_element   := 'SITECODE';
                l_value := 'null';
        END IF;

        IF l_element IS NOT NULL THEN
                itg_msg.missing_element_value(l_element,l_value);
                RAISE FND_API.G_EXC_ERROR;
        END IF;

    select count(*)
    into   l_var
    from   HR_ALL_ORGANIZATION_UNITS
    where  organization_id = p_org;

    IF to_number(l_var) = 0 THEN
            ITG_MSG.missing_element_value('ORGID', p_org);
          RAISE FND_API.G_EXC_ERROR;
    END IF;

  END;

  PROCEDURE Sync_VendorSite(

    x_return_status    OUT NOCOPY VARCHAR2,          /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,          /* VARCHAR2(2000) */

    /* TAG: address */
    p_addrline1        IN         VARCHAR2 := NULL,  /* addrline index=1 */
    p_addrline2        IN         VARCHAR2 := NULL,  /* addrline index=2 */
    p_addrline3        IN         VARCHAR2 := NULL,  /* addrline index=3 */
    p_addrline4        IN         VARCHAR2 := NULL,  /* addrline index=4 */
    p_city             IN         VARCHAR2 := NULL,  /* city */
    p_country          IN         VARCHAR2 := NULL,  /* country */
    p_county           IN         VARCHAR2 := NULL,  /* county */
    p_site_code        IN         VARCHAR2,          /* descriptn (key) */
    p_fax              IN         VARCHAR2 := NULL,  /* fax index=1 */
    p_zip              IN         VARCHAR2 := NULL,  /* postalcode */
    p_state            IN         VARCHAR2 := NULL,  /* stateprovn */
    p_phone            IN         VARCHAR2 := NULL,  /* telephone index=1 */
    p_org              IN         VARCHAR2 := NULL,
    p_purch_site       IN         VARCHAR2 := NULL,  /* userarea.ref_pursite */
    p_pay_site         IN         VARCHAR2 := NULL,  /* userarea.ref_paysite */
    p_rfq_site         IN         VARCHAR2 := NULL,  /* userarea.ref_rfqsite */
    p_pc_site          IN         VARCHAR2 := NULL,  /* userarea.ref_pcsite */
    p_vat_code         IN         VARCHAR2 := NULL,  /* userarea.ref_vatcode */

    p_vinfo_rec        IN         vinfo_rec_type
  ) IS
        l_vendor_found                  boolean;
        l_sob_found                     boolean;
        l_return_status                 varchar2(20);
        l_ret_msg                       varchar2(2000);
        l_msg_count                     NUMBER;
        l_vendor_site_id                NUMBER;
        l_party_id                      NUMBER;
        l_location_id                   NUMBER;
        l_ven_rec                       ap_vendors_v%ROWTYPE;
        l_api_name                      VARCHAR2(50);
        l_vendorsite_rec                ap_vendor_pub_pkg.r_vendor_site_rec_type;
        p_location_rec                  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
        p_object_version_number         NUMBER;
        l_ship_to_location_id           financials_system_params_all.ship_to_location_id%TYPE;
        l_bill_to_location_id           financials_system_params_all.bill_to_location_id%TYPE;
        l_ship_via_lookup_code          financials_system_params_all.ship_via_lookup_code%TYPE;
        l_freight_terms_lookup_code     financials_system_params_all.freight_terms_lookup_code%TYPE;
        l_fob_lookup_code               financials_system_params_all.fob_lookup_code%TYPE;
        l_accts_pay_code_comb_id        financials_system_params_all.accts_pay_code_combination_id%TYPE;
        l_prepay_code_comb_id           financials_system_params_all.prepay_code_combination_id%TYPE;
        l_future_dated_pay_ccid         NUMBER;


        CURSOR sob_csr(p_org VARCHAR2) IS
        SELECT set_of_books_id
        FROM   org_organization_definitions
        WHERE  organization_id = p_org;

        CURSOR fin_params_csr(p_sob_id NUMBER) IS
        SELECT  ship_to_location_id,
                bill_to_location_id,
                ship_via_lookup_code,
                freight_terms_lookup_code,
                fob_lookup_code,
                accts_pay_code_combination_id,
                prepay_code_combination_id
        FROM    financials_system_params_all
        WHERE   set_of_books_id = p_sob_id;

BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        g_action := 'Vendor-site sync';

        SAVEPOINT Sync_VendorSite_PVT;

        IF (l_Debug_Level <= 1) THEN
                itg_debug_pub.Add('Top of procedure.', 1);
                itg_debug_pub.Add('p_addrline1' ||p_addrline1, 1);
                itg_debug_pub.Add('p_addrline2' ||p_addrline2, 1);
                itg_debug_pub.Add('p_addrline3' ||p_addrline3, 1);
                itg_debug_pub.Add('p_addrline4' ||p_addrline4, 1);
                itg_debug_pub.Add('p_city'      ||p_city, 1    );
                itg_debug_pub.Add('p_country'   ||p_country, 1 );
                itg_debug_pub.Add('p_county'    ||p_county, 1);
                itg_debug_pub.Add('p_site_code' ||p_site_code, 1);
                itg_debug_pub.Add('p_fax'       ||p_fax, 1);
                itg_debug_pub.Add('p_zip'       ||p_zip, 1);
                itg_debug_pub.Add('p_state'     ||p_state, 1);
                itg_debug_pub.Add('p_phone'     ||p_phone, 1);
                itg_debug_pub.Add('p_purch_site'||p_purch_site, 1);
                itg_debug_pub.Add('p_pay_site'  ||p_pay_site, 1);
                itg_debug_pub.Add('p_pc_site'   ||p_pc_site, 1);
                itg_debug_pub.Add('p_rfq_site'  ||p_rfq_site, 1);
                itg_debug_pub.Add('p_vat_code'  ||p_vat_code, 1);
                itg_debug_pub.Add('p_org     '  ||p_org, 1);
        END IF;

        validate_vendorsite_params(
                p_addrline1        => p_addrline1,
                p_addrline2        => p_addrline2,
                p_addrline3        => p_addrline3,
                p_addrline4        => p_addrline4,
                p_city             => p_city,
                p_country          => p_country,
                p_county           => p_county,
                p_site_code        => p_site_code,
                p_fax              => p_fax,
                p_zip              => p_zip,
                p_state            => p_state,
                p_phone            => p_phone,
                p_org              => p_org,
                p_purch_site       => p_purch_site,
                p_pay_site         => p_pay_site,
                p_rfq_site         => p_rfq_site,
                p_pc_site          => p_pc_site,
                p_vat_code         => p_vat_code,
                p_vinfo_rec              => p_vinfo_rec);

        BEGIN
        IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('Retrieving vendor record - ' || p_vinfo_rec.vendor_id ,1);
                END IF;

                g_action := 'query vendor details';

                SELECT *
                INTO   l_ven_rec
                FROM   ap_vendors_v
                WHERE  vendor_id = p_vinfo_rec.vendor_id;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('Vendor not found - erroring out' ,1);
                        END IF;
                        itg_msg.vendor_not_found('vendorid:' ||p_vinfo_rec.vendor_id);
                        RAISE FND_API.G_EXC_ERROR;
        END;


        g_action := 'check for vendor site';
        BEGIN
                SELECT  vendor_site_id
                INTO    l_vendor_site_id
                FROM    ap_supplier_sites
                WHERE   vendor_id = p_vinfo_rec.vendor_id
                AND     upper(vendor_site_code) = UPPER(p_site_code);

                l_vendor_found := true;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.add('Vendor site obtained as - ' || l_vendor_site_id);
                END IF;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.add('Vendor site not found');
                        END IF;
                        l_vendor_found := false;
        END;

        IF p_org IS NOT NULL THEN
        IF (l_Debug_Level <= 1) THEN
                itg_debug_pub.Add('SVS - Looking up set_of_books_id',1);
                END IF;

                OPEN  sob_csr(p_org);
                FETCH sob_csr
                INTO  l_ven_rec.set_of_books_id;
                l_sob_found := sob_csr%FOUND;
                CLOSE sob_csr;


                IF l_sob_found THEN
                    IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('SVS - Looking up financial params' ,1);
                                itg_debug_pub.Add('SVS - set_of_books_id'||l_ven_rec.set_of_books_id,1);
                        END IF;

                        OPEN  fin_params_csr(p_sob_id => l_ven_rec.set_of_books_id);
                        FETCH fin_params_csr
                        INTO  l_ship_to_location_id,
                              l_bill_to_location_id,
                              l_ship_via_lookup_code,
                              l_freight_terms_lookup_code,
                              l_fob_lookup_code,
                              l_accts_pay_code_comb_id,
                              l_prepay_code_comb_id;
                        CLOSE fin_params_csr;
                END IF;
        END IF;



      IF NOT l_vendor_found THEN
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.add('Creating vendor record');
                END IF;

                g_action := 'vendor site creation';
                l_vendorsite_rec.vendor_site_code               :=      p_site_code;
                l_vendorsite_rec.PHONE                          :=      p_phone;
                l_vendorsite_rec.FAX                            :=      p_fax;
                l_vendorsite_rec.COUNTRY                        :=      p_country;
                l_vendorsite_rec.ADDRESS_LINE1                  :=      p_addrline1;
                l_vendorsite_rec.ADDRESS_LINE2                  :=      p_addrline2;
                l_vendorsite_rec.ADDRESS_LINE3                  :=      p_addrline3;
                l_vendorsite_rec.ADDRESS_LINE4                  :=      p_addrline4;
                l_vendorsite_rec.COUNTY                         :=      p_county;
                l_vendorsite_rec.CITY                           :=      p_city;
                l_vendorsite_rec.STATE                          :=      p_state;
                l_vendorsite_rec.ZIP                            :=      p_zip;
                l_vendorsite_rec.PURCHASING_SITE_FLAG           :=      p_purch_site;
                l_vendorsite_rec.RFQ_ONLY_SITE_FLAG             :=      p_rfq_site;
                l_vendorsite_rec.PAY_SITE_FLAG                  :=      p_pay_site;
                l_vendorsite_rec.PCARD_SITE_FLAG                :=      p_pc_site;
                l_vendorsite_rec.payment_priority               :=      2;
                l_vendorsite_rec.TERMS_DATE_BASIS               :=      NVL(l_ven_rec.terms_date_basis, 'Goods Received');
                l_vendorsite_rec.SHIP_TO_LOCATION_ID            :=      l_ship_to_location_id;
                l_vendorsite_rec.BILL_TO_LOCATION_ID            :=      l_bill_to_location_id;
                l_vendorsite_rec.SHIP_VIA_LOOKUP_CODE           :=      l_ship_via_lookup_code;
                l_vendorsite_rec.FREIGHT_TERMS_LOOKUP_CODE      :=      l_freight_terms_lookup_code;
                l_vendorsite_rec.FOB_LOOKUP_CODE                :=      l_fob_lookup_code;
                l_vendorsite_rec.ACCTS_PAY_CODE_COMBINATION_ID  :=      l_accts_pay_code_comb_id;
                l_vendorsite_rec.PREPAY_CODE_COMBINATION_ID     :=      l_prepay_code_comb_id;
                l_vendorsite_rec.PAY_GROUP_LOOKUP_CODE          :=      l_ven_rec.pay_group_lookup_code;
                l_vendorsite_rec.PAY_DATE_BASIS_LOOKUP_CODE     :=      l_ven_rec.pay_date_basis_lookup_code;
                l_vendorsite_rec.ALWAYS_TAKE_DISC_FLAG          :=      l_ven_rec.always_take_disc_flag;
                l_vendorsite_rec.BANK_CHARGE_BEARER             :=      l_ven_rec.bank_charge_bearer;
                l_vendorsite_rec.ALLOW_AWT_FLAG                 :=      l_ven_rec.allow_awt_flag;
                l_vendorsite_rec.FUTURE_DATED_PAYMENT_CCID      :=      l_future_dated_pay_ccid;
                l_vendorsite_rec.CREATE_DEBIT_MEMO_FLAG         :=      l_ven_rec.create_debit_memo_flag;
                l_vendorsite_rec.ADDRESS_STYLE                  :=      p_vinfo_rec.addr_style;
                l_vendorsite_rec.INVOICE_CURRENCY_CODE          :=      NVL(p_vinfo_rec.currency, l_ven_rec.invoice_currency_code);
                l_vendorsite_rec.PAYMENT_CURRENCY_CODE          :=      NVL(p_vinfo_rec.currency, l_ven_rec.payment_currency_code);
                l_vendorsite_rec.TERMS_ID                       :=      NVL(p_vinfo_rec.terms_id, l_ven_rec.terms_id);
                l_vendorsite_rec.TERMS_NAME                     :=      NVL(p_vinfo_rec.terms_name, l_ven_rec.terms_name);
                l_vendorsite_rec.match_option                   :=     'P';
                l_vendorsite_rec.vendor_id                      :=      p_vinfo_rec.vendor_id;
                l_vendorsite_rec.org_id                         :=      p_org;

                l_api_name := 'ap_vendor_pub_pkg.create_vendor_site';
                ap_vendor_pub_pkg.create_vendor_site
                (
                        p_api_version           => '1.0',
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_ret_msg,
                        p_vendor_site_rec       => l_vendorsite_rec,
                        x_vendor_site_id        => l_vendor_site_id,
                        x_party_site_id         => l_party_id,
                        x_location_id           => l_location_id
                );

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.add('return from ap_vendors_pub_pkg.create_vendor_site');
                        itg_debug_pub.add('l_return_status  ' || l_return_status);
                        itg_debug_pub.add('l_msg_count      ' || l_msg_count);
                        itg_debug_pub.add('l_ret_msg        ' || l_ret_msg);
                        itg_debug_pub.add('l_vendor_site_id ' || l_vendor_site_id);
                        itg_debug_pub.add('l_party_id       ' || l_party_id);
                        itg_debug_pub.add('l_location_id    ' || l_location_id);
                END IF;

        ELSE

                g_action := 'vendor site update';
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.add('Updating vendor record');
                END IF;

                g_action := 'Vendor-site info update';
                get_vendorsite_rec(l_vendorsite_rec,l_vendor_site_id,p_vinfo_rec.vendor_id);

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.add('Retrieved old vendor record information');
                END IF;
                l_vendorsite_rec.vendor_site_code                       :=      null;
                l_vendorsite_rec.PHONE                                  :=      NVL(p_phone, l_vendorsite_rec.phone);
                l_vendorsite_rec.FAX                                    :=      NVL(p_fax, l_vendorsite_rec.fax);
                l_vendorsite_rec.COUNTRY                                :=      NVL(p_country, l_vendorsite_rec.country);
                l_vendorsite_rec.ADDRESS_LINE1                          :=      NVL(p_addrline1, l_vendorsite_rec.address_line1);
                l_vendorsite_rec.ADDRESS_LINE2                          :=      NVL(p_addrline2, l_vendorsite_rec.address_line2);
                l_vendorsite_rec.ADDRESS_LINE3                          :=      NVL(p_addrline3, l_vendorsite_rec.address_line3);
                l_vendorsite_rec.ADDRESS_LINE4                          :=      NVL(p_addrline4, l_vendorsite_rec.address_line4);
                l_vendorsite_rec.COUNTY                                 :=      NVL(p_county, l_vendorsite_rec.county);
                l_vendorsite_rec.CITY                                   :=      NVL(p_city, l_vendorsite_rec.city);
                l_vendorsite_rec.STATE                                  :=      NVL(p_state, l_vendorsite_rec.state);
                l_vendorsite_rec.ZIP                                    :=      NVL(p_zip, l_vendorsite_rec.zip);
                l_vendorsite_rec.PURCHASING_SITE_FLAG                   :=      NVL(p_purch_site, l_vendorsite_rec.purchasing_site_flag);
                l_vendorsite_rec.RFQ_ONLY_SITE_FLAG                     :=      NVL(p_rfq_site, l_vendorsite_rec.rfq_only_site_flag);
                l_vendorsite_rec.PAY_SITE_FLAG                          :=      NVL(p_pay_site, l_vendorsite_rec.pay_site_flag);
                l_vendorsite_rec.PCARD_SITE_FLAG                        :=      NVL(p_pc_site, l_vendorsite_rec.pcard_site_flag);
                l_vendorsite_rec.payment_priority                       :=      2;
                l_vendorsite_rec.match_option                           :=      'P';
                l_vendorsite_rec.TERMS_ID                               :=      NVL(p_vinfo_rec.terms_id, l_vendorsite_rec.terms_id);
                l_vendorsite_rec.TERMS_NAME                             :=      NVL(p_vinfo_rec.terms_name, l_vendorsite_rec.terms_name);
                l_vendorsite_rec.PAYMENT_CURRENCY_CODE                  :=      NVL(p_vinfo_rec.currency, l_vendorsite_rec.invoice_currency_code);
                l_vendorsite_rec.INVOICE_CURRENCY_CODE                  :=      NVL(p_vinfo_rec.currency, l_vendorsite_rec.payment_currency_code);
                l_vendorsite_rec.org_id                                 :=      p_org;
                l_vendorsite_rec.vendor_site_id                         :=      l_vendor_site_id;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.add('Calling ap_vendors_pub_pkg.update_vendor_site');
                END IF;
                l_api_name := 'ap_vendor_pub_pkg.update_vendor_site';
                ap_vendor_pub_pkg.update_vendor_site
                (
                        p_api_version           => '1.0',
                        x_return_status         => l_return_status,
                        x_msg_count             => l_msg_count,
                        x_msg_data              => l_ret_msg,
                        p_vendor_site_rec       => l_vendorsite_rec,
                        p_vendor_site_id        => l_vendor_site_id
                );

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.add('Return from ap_vendors_pub_pkg.update_vendor_site');
                        itg_debug_pub.add('l_return_status  ' || l_return_status);
                        itg_debug_pub.add('l_msg_count      ' || l_msg_count);
                        itg_debug_pub.add('l_ret_msg        ' || l_ret_msg);
                        itg_debug_pub.add('l_vendor_site_id ' || l_vendor_site_id);
                END IF;

            /* Adding following block to Fix Bug: 5258874 to update supplier site address locations*/
          BEGIN
              select location_id into p_location_rec.location_id
              from  ap_supplier_sites
              where vendor_id = p_vinfo_rec.vendor_id and vendor_site_id = l_vendor_site_id;
               IF (l_Debug_Level <= 1) THEN
                       itg_debug_pub.Add('location_id - '|| p_location_rec.location_id,1);
               END IF;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                IF (l_Debug_Level <= 1) THEN
                      itg_debug_pub.Add('Couldn''t find location_id  ');
               END IF;
             RAISE FND_API.G_EXC_ERROR;
          END;


         BEGIN
              select object_version_number
              into p_object_version_number
              from hz_locations
              where location_id = p_location_rec.location_id;

          IF (l_Debug_Level <= 1) THEN
                       itg_debug_pub.Add('object_version_number - '|| p_object_version_number);
           END IF;

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 IF (l_Debug_Level <= 1) THEN
                      itg_debug_pub.Add('Couldn''t find object_version_number');
               END IF;
             RAISE FND_API.G_EXC_ERROR;

         END;

               p_location_rec.orig_system_reference := '';
               --p_location_rec.orig_system :=
               p_location_rec.country :=   NVL(p_country, l_vendorsite_rec.country);
               p_location_rec.address1 :=  NVL(p_addrline1, l_vendorsite_rec.address_line1);
               p_location_rec.address2 :=  NVL(p_addrline2, l_vendorsite_rec.address_line2);
               p_location_rec.address3 :=  NVL(p_addrline3, l_vendorsite_rec.address_line3);
               p_location_rec.address4 :=  NVL(p_addrline4, l_vendorsite_rec.address_line4);
               p_location_rec.city     :=  NVL(p_city, l_vendorsite_rec.city);
               p_location_rec.postal_code := NVL(p_zip, l_vendorsite_rec.zip);
               p_location_rec.state    :=  NVL(p_state, l_vendorsite_rec.state);
               p_location_rec.province := NVL(p_state, l_vendorsite_rec.state);
               p_location_rec.county :=    NVL(p_county, l_vendorsite_rec.county);

              IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.add('Calling hz_location_v2pub.update_location ');

               END IF;
              l_api_name := 'hz_location_v2pub.update_location';
              hz_location_v2pub.update_location
              (
              p_init_msg_list         => FND_API.G_FALSE,
              p_location_rec          => p_location_rec,
              p_object_version_number => p_object_version_number,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_ret_msg

              );
               IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.add('Return from hz_location_v2pub.update_location');
                        itg_debug_pub.add('l_return_status  ' || l_return_status);
                        itg_debug_pub.add('l_msg_count      ' || l_msg_count);
                        itg_debug_pub.add('l_ret_msg        ' || l_ret_msg);
                End if;
         END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.add('Create/Update_vendor_site/update_location API returns - ' || l_return_status || ' - ' || l_ret_msg);
                END IF;
                itg_msg.apicallret(l_api_name, l_return_status, l_ret_msg);
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_Debug_Level <= 1) THEN
                itg_debug_pub.Add('Commiting work',1);
        END IF;

        COMMIT WORK;

        IF (l_Debug_Level <= 2) THEN
                itg_debug_pub.Add('EXITING  - Sync_VendorSite.', 2);
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Sync_VendorSite_PVT;
                commit;
                x_return_status := FND_API.G_RET_STS_ERROR;
                ITG_msg.checked_error(g_action);
                itg_msg.vendor_site_only;
                IF (l_Debug_Level <= 6) THEN
                        itg_debug_pub.Add('EXITING  - Sync_VendorSite :ERROR', 6);
                END IF;


        WHEN OTHERS THEN
                ROLLBACK TO Sync_VendorSite_PVT;
                commit;
                ITG_msg.unexpected_error(g_action);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                itg_msg.vendor_site_only;
                itg_debug.msg('Unexpected error (VendorSite sync) - ' || substr(SQLERRM,1,255),true);
                IF (l_Debug_Level <= 6) THEN
                        itg_debug_pub.Add('EXITING  - Sync_VendorSite :ERROR', 6);
                END IF;


END Sync_VendorSite;


  PROCEDURE Sync_VendorContact(
    x_return_status    OUT NOCOPY VARCHAR2,         /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,         /* VARCHAR2(2000) */

    p_title            IN         VARCHAR2 := NULL, /* contcttype */
    p_first_name       IN         VARCHAR2 := NULL, /* name index=1 */
    p_middle_name      IN         VARCHAR2 := NULL, /* name index=2 */
    p_last_name        IN         VARCHAR2 := NULL, /* name index=3 */
    p_phone            IN         VARCHAR2 := NULL, /* telephone index=1 */
    p_site_code        IN         VARCHAR2,         /* userarea.ref_sitecode */

    p_vinfo_rec        IN         vinfo_rec_type
  ) IS
        r_vendor_contact_rec ap_vendor_pub_pkg.r_vendor_contact_rec_type;
        l_found                 Boolean;
        l_ret_status            varchar2(20);
        l_msg_data              varchar2(2000);
        l_ret_msg               varchar2(2000);
        l_msg_count             NUMBER;
        l_party_site_id         NUMBER;
        l_org_contact_id        NUMBER;
        l_rel_id                NUMBER;
        l_rel_party_id          NUMBER;
        l_per_party_id          NUMBER;
        l_vendor_contact_id     NUMBER;
        l_vsite_id              NUMBER;
        l_obj_ver_num           NUMBER;
        l_party_id              NUMBER;
        l_profile_id            NUMBER;
        l_party_rec             HZ_PARTY_V2PUB.party_rec_type;
        l_per_rec               HZ_PARTY_V2PUB.person_rec_type;
  BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        g_action := 'Vendor-contact parameter validation';

        IF (l_Debug_Level <= 2) THEN
                itg_debug_pub.Add('ENTERING  - Sync_VendorContact', 2);
                itg_debug_pub.Add('p_title              - ' || p_title, 2);
                itg_debug_pub.Add('p_first_name - ' || p_first_name, 2);
                itg_debug_pub.Add('p_middle_name        - ' || p_middle_name, 2);
                itg_debug_pub.Add('p_last_name  - ' || p_last_name, 2);
                itg_debug_pub.Add('p_phone              - ' || p_phone, 2);
                itg_debug_pub.Add('p_site_code  - ' || p_site_code, 2);
        END IF;

        -- sync vendor
        SAVEPOINT Sync_VendorContact_PVT;


        BEGIN

                g_action := 'Vendor-contact information sync';

            SELECT vendor_site_id
            INTO   l_vsite_id
            FROM   ap_supplier_sites
            WHERE  UPPER(vendor_site_code) = UPPER(p_site_code)
                AND    vendor_id           = p_vinfo_rec.vendor_id;

            IF (l_Debug_Level <= 1) THEN
                itg_debug_pub.Add('Getting vendor site ID - ' || l_vsite_id ,1);
                END IF;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                itg_msg.no_vendor_site('vendor-sitecode:' || p_site_code);
                RAISE FND_API.G_EXC_ERROR;
        END;

        BEGIN

                g_action := 'Vendor-contact information sync';

                select  h.party_id, h.object_version_number
                into            l_party_id,l_obj_ver_num
                from    HZ_PARTIES h, ap_supplier_contacts a
                where   a.per_party_id =  h.party_id
                        and     a.vendor_site_id = l_vsite_id
                AND    NVL(upper(person_first_name),  '1') = NVL(upper(p_first_name),  '1')
                  AND    NVL(upper(person_middle_name), '1') = NVL(upper(p_middle_name), '1')
                  AND    NVL(upper(person_last_name),   '1') = NVL(upper(p_last_name),   '1')
                  AND    ROWNUM = 1;

                l_found := true;

        IF (l_Debug_Level <= 1) THEN
                itg_debug_pub.Add('Contact party id             - ' || l_party_id ,1);
                itg_debug_pub.Add('Contact obj version  - ' || l_obj_ver_num ,1);
                END IF;


        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                IF (l_Debug_Level <= 5) THEN
                                itg_debug_pub.Add('SVC - Contact record not found, trying to add it' ,5);
                  END IF;
                 l_found := false;
        END;



        IF NOT l_found THEN
                g_action := 'Vendor-contact record creation';
                r_vendor_contact_rec.PERSON_FIRST_NAME          := p_first_name;
                r_vendor_contact_rec.PERSON_MIDDLE_NAME         := p_middle_name;
                r_vendor_contact_rec.PERSON_LAST_NAME           := p_last_name;
                r_vendor_contact_rec.PERSON_TITLE                       := p_title;
                r_vendor_contact_rec.PHONE                              := p_phone;
                r_vendor_contact_rec.VENDOR_SITE_CODE           := p_site_code;
                r_vendor_contact_rec.VENDOR_SITE_ID                     := l_vsite_id;
                r_vendor_contact_rec.VENDOR_ID                  := p_vinfo_rec.vendor_id;
                r_vendor_contact_rec.PERSON_TITLE                       := p_title;

                Ap_vendor_pub_pkg.Create_Vendor_Contact
                (
                        p_api_version           => 1.0,
                        x_return_status         => l_ret_status,
                        x_msg_count                     => l_msg_count,
                        x_msg_data                      => l_msg_data,
                        p_vendor_contact_rec    => r_vendor_contact_rec,
                        x_vendor_contact_id     => l_vendor_contact_id,
                        x_per_party_id          => l_per_party_id,
                        x_rel_party_id          => l_rel_party_id,
                        x_rel_id                        => l_rel_id,
                        x_org_contact_id                => l_org_contact_id,
                        x_party_site_id         => l_party_site_id
                );

                IF l_debug_level <= 1 THEN
                        itg_debug_pub.Add('Create_Vendor_Contact - ' || l_ret_status   || ' - '  || l_msg_data ,1);
                        itg_debug_pub.Add('l_per_party_id       - ' || l_per_party_id,1);
                        itg_debug_pub.Add('l_rel_party_id       - ' || l_rel_party_id,1);
                        itg_debug_pub.Add('l_rel_id             - ' || l_rel_id,1 );
                        itg_debug_pub.Add('l_org_contact_id - ' || l_org_contact_id,1 );
                        itg_debug_pub.Add('l_party_site_id      - ' || l_party_site_id,1 );
                END IF;

                IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                        itg_msg.apicallret('Ap_vendor_pub_pkg.Create_Vendor_Contact',l_ret_status,l_msg_data);
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        ELSE
                g_action := 'Vendor-contact record update';
                l_party_rec.party_id            := l_party_id;
                l_per_rec.person_first_name     := p_first_name;
                l_per_rec.person_middle_name    := p_middle_name;
                l_per_rec.person_last_name      := p_last_name;
                l_per_rec.person_title          := p_title;
                l_per_rec.created_by_module     := 'AP_SUPPLIERS_API';
                l_per_rec.application_id        := 200;
                l_per_rec.party_rec             := l_party_rec;

                 HZ_PARTY_V2PUB.update_person (
                        p_person_rec                       => l_per_rec,
                        p_party_object_version_number      => l_obj_ver_num,
                        x_profile_id                       => l_profile_id,
                        x_return_status                    => l_ret_status,
                        x_msg_count                        => l_msg_count,
                        x_msg_data                         => l_msg_data);

                IF l_debug_level <= 1 THEN
                        itg_debug_pub.Add('HZ_PARTY_V2PUB.update_person - ' || l_ret_status   || ' - '  || l_msg_data ,1);
                        itg_debug_pub.Add('l_obj_ver_num        - ' ||  l_msg_count,1);
                        itg_debug_pub.Add('l_profile_id - ' || l_obj_ver_num,1);
                        itg_debug_pub.Add('l_msg_count  - ' || l_profile_id,1 );

                END IF;

                IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
                    itg_msg.apicallret('HZ_PARTY_V2PUB.update_person',l_ret_status,l_msg_data);
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

        END IF;

        IF (l_Debug_Level <= 1) THEN
                itg_debug_pub.Add('Committing work' ,1);
        END IF;

        COMMIT WORK;

        IF (l_Debug_Level <= 2) THEN
                itg_debug_pub.Add('EXTING  - Sync_VendorContact', 2);
        END IF;


EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Sync_VendorContact_PVT;
                commit;
                x_return_status := FND_API.G_RET_STS_ERROR;
                ITG_msg.checked_error(g_action);
                itg_msg.vendor_contact_only;
                IF (l_Debug_Level <= 6) THEN
                  itg_debug_pub.Add('EXTING  - Sync_VendorContact :OTHER ERROR', 6);
                END IF;


      WHEN OTHERS THEN
                ROLLBACK TO Sync_VendorContact_PVT;
                commit;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                ITG_msg.unexpected_error(g_action);
                itg_msg.vendor_contact_only;
                itg_debug.msg('Unexpected error (VendorContact sync) - ' || substr(SQLERRM,1,255),true);
                IF (l_Debug_Level <= 6) THEN
                  itg_debug_pub.Add('EXTING  - Sync_VendorContact :OTHER ERROR', 6);
                END IF;

END Sync_VendorContact;

END ITG_SyncSupplierInbound_PVT;

/
