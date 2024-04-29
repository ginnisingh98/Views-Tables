--------------------------------------------------------
--  DDL for Package Body IGI_CIS2007_IGIPVERP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS2007_IGIPVERP_PKG" AS
-- $Header: igipverb.pls 120.2.12010000.3 2008/12/19 13:43:28 gaprasad ship $

 /* PO API to update the CORE tables */
  PROCEDURE pr_po_core_update(p_header_id IN NUMBER) IS
    l_awt_group_id ap_suppliers.awt_group_id%TYPE;
    l_match_flag   ap_suppliers.match_status_flag%TYPE;
    l_request_id   ap_suppliers.verification_request_id%TYPE;
    CURSOR cur_igi_cis_verify_headers IS
      SELECT vendor_id,
             verification_number,
             match_status,
             tax_treatment_status,
             cis_verification_date
        FROM igi_cis_verify_lines_t
       WHERE header_id = p_header_id;
--Bug 5606118
   CURSOR c_req_id IS
   SELECT request_id
   FROM igi_cis_verify_headers_t
   WHERE header_id = p_header_id;
--Bug 5606118
  BEGIN
    /* Updating the PO tables */
--Bug 5606118

FOR c_req_id_rec in c_req_id LOOP

l_request_id := c_req_id_rec.request_id;

END LOOP;

--Bug 5606118

FOR cur_igi_cis_verify_headers_rec IN cur_igi_cis_verify_headers
    LOOP
      l_match_flag   := NULL;
      l_awt_group_id := NULL;
      /* Getting the AWT group id based on the tax treatment status */
      IF (cur_igi_cis_verify_headers_rec.tax_treatment_status = 'net') THEN
        l_awt_group_id := fnd_profile.VALUE('IGI_CIS2007_NET_WTH_GROUP');
      ELSIF (cur_igi_cis_verify_headers_rec.tax_treatment_status = 'gross') THEN
        l_awt_group_id := fnd_profile.VALUE('IGI_CIS2007_GROSS_WTH_GROUP');
      ELSIF (cur_igi_cis_verify_headers_rec.tax_treatment_status =
            'unmatched') THEN
        l_awt_group_id := fnd_profile.VALUE('IGI_CIS2007_UNMATCHED_WTH_GROUP');
      END IF;
      IF (l_awt_group_id IS NOT NULL) THEN
        /* AWT group id - Active / Inactive validation */
        SELECT g.group_id
          INTO l_awt_group_id
          FROM ap_awt_groups g
         WHERE g.group_id = l_awt_group_id
           AND nvl(g.inactive_date, SYSDATE + 1) > SYSDATE;
        SELECT lookup_code
          INTO l_match_flag
          FROM igi_lookups
         WHERE upper(meaning) =
               upper(cur_igi_cis_verify_headers_rec.match_status)
           AND lookup_type = 'IGI_CIS2007_MATCH_STATUS';

        /* calling to update certificates .. */
        /* Bug 5705187 */
         IGI_CIS2007_TAX_EFF_DATE.main (
         p_vendor_id      => cur_igi_cis_verify_headers_rec.vendor_id,
         p_vendor_site_id => NULL,
         p_tax_grp_id     => l_awt_group_id,
         p_pay_tax_grp_id => l_awt_group_id,                                    /* Bug 7218825 */
         p_source         => 'VERIFY',
         p_effective_date =>cur_igi_cis_verify_headers_rec.cis_verification_date
         );

        /* calling PO API to update PO tables - AP_SUPPLIERS, AP_SUPPLIER_SITES_ALL */
        pr_po_api(cur_igi_cis_verify_headers_rec.vendor_id,
                  cur_igi_cis_verify_headers_rec.verification_number,
                  l_match_flag,
                  cur_igi_cis_verify_headers_rec.cis_verification_date,
                  l_awt_group_id,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
		  l_request_id);
      END IF;
    END LOOP;
  END pr_po_core_update;
  /* API to UPDATE the HISTORY tables */
  PROCEDURE pr_audit_update(p_header_id IN NUMBER) IS
  BEGIN
    /* Populating the history tables */
    INSERT INTO igi_cis_verify_headers_h
      (header_id,
       request_id,
       unique_tax_reference_num,
       request_status_code,
       accounts_office_reference,
       program_id,
       program_application_id,
       program_login_id,
       program_update_date,
       last_update_date,
       last_updated_by,
       last_update_login,
       creation_date,
       created_by,
       cis_sender_id,
       tax_office_number,
       paye_reference)
      SELECT header_id,
             request_id,
             unique_tax_reference_num,
             request_status_code,
             accounts_office_reference,
             program_id,
             program_application_id,
             program_login_id,
             program_update_date,
             last_update_date,
             last_updated_by,
             last_update_login,
             creation_date,
             created_by,
             cis_sender_id,
             tax_office_number,
             paye_reference
        FROM igi_cis_verify_headers_t
       WHERE header_id = p_header_id;
    INSERT INTO igi_cis_verify_lines_h
      (header_id,
       action_indicator,
       vendor_type_lookup_code,
       vendor_id,
       vendor_name,
       vendor_site_id,
       vendor_site_code,
       first_name,
       second_name,
       last_name,
       salutation,
       trading_name,
       unique_tax_reference_num,
       work_reference,
       company_registration_number,
       national_insurance_number,
       verification_number,
       cis_verification_date,
       address_line1,
       address_line2,
       address_line3,
       address_line4,
       match_status,
       post_code,
       country,
       contact_number,
       tax_treatment_status,
       last_update_date,
       last_updated_by,
       last_update_login,
       creation_date,
       created_by,
       partnership_utr,
       partnership_name)
      SELECT header_id,
             action_indicator,
             vendor_type_lookup_code,
             vendor_id,
             vendor_name,
             vendor_site_id,
             vendor_site_code,
             first_name,
             second_name,
             last_name,
             salutation,
             trading_name,
             unique_tax_reference_num,
             work_reference,
             company_registration_number,
             national_insurance_number,
             verification_number,
             cis_verification_date,
             address_line1,
             address_line2,
             address_line3,
             address_line4,
             match_status,
             post_code,
             country,
             contact_number,
             tax_treatment_status,
             last_update_date,
             last_updated_by,
             last_update_login,
             creation_date,
             created_by,
             partnership_utr,
             partnership_name
        FROM igi_cis_verify_lines_t
       WHERE header_id = p_header_id;
    DELETE FROM igi_cis_verify_headers_t WHERE header_id = p_header_id;
    DELETE FROM igi_cis_verify_lines_t WHERE header_id = p_header_id;
  END pr_audit_update;
  /* Function used by Verification UI */
  FUNCTION igi_cis_is_vendor_paid
  (
    l_vendor_id NUMBER,
    verify_date DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 AS
    tax_year_start DATE;
    paid_status VARCHAR2(20);
  BEGIN
    IF to_date(to_char(verify_date, 'dd-mm') || '2005', 'dd-mm-yyyy') >
       to_date('05-04-2005', 'dd-mm-yyyy') THEN
      tax_year_start := to_date('06-04-' || to_char(verify_date, 'YYYY'),
                                'DD-MM-YYYY');
    ELSE
      tax_year_start := add_months(to_date('06-04-' ||
                                           to_char(verify_date, 'YYYY'),
                                           'DD-MM-YYYY'),
                                   -12);
    END IF;
    SELECT 'PAID'
      INTO paid_status
      FROM ap_checks ac,
           ap_invoice_payments pay,
           -- Bug 5642198 Start
           ap_invoices inv,
           ap_supplier_sites pvs
           -- Bug 5642198 End
     WHERE ac.vendor_id = l_vendor_id
       AND ac.void_date IS NULL
       AND pay.check_id = ac.check_id
       AND accounting_date > add_months(tax_year_start, -24)
       -- Bug 5642198 Start
       AND inv.invoice_id = pay.invoice_id
       AND pvs.vendor_id = inv.vendor_id
       AND pvs.vendor_site_id = inv.vendor_site_id
       AND upper(pvs.allow_awt_flag) = 'Y'
       -- Bug 5642198 End
       AND rownum = 1;
    RETURN 'PAID';
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'NOTPAID';
  END igi_cis_is_vendor_paid;
  /* PO API to update AP_SUPPLIERS and AP_SUPPLIER_SITES_ALL */
  PROCEDURE pr_po_api
  (
    p_vendor_id         IN NUMBER,
    p_verification_no   IN VARCHAR2,
    p_match_status      IN VARCHAR2,
    p_verification_date DATE,
    p_awt_group_id      IN NUMBER,
    p_utr_type          IN VARCHAR2,
    p_utr               IN NUMBER,
    p_sc_name           IN VARCHAR2,
    p_sc_ref_id         IN VARCHAR2,
    p_req_id            IN NUMBER     --Bug 5606118
  ) IS

/* Bug#7218825 - CIS WITHHOLDING PROJECT DUE TO AP ENHANCEMENT 6639866 ON 12.1 */

l_org_id                  ap_supplier_sites_all.org_id%TYPE;
l_create_awt_dists_type   ap_system_parameters_all.CREATE_AWT_DISTS_TYPE%TYPE;

Cursor c_povs_orgs(c_vendor_id NUMBER) is
select distinct org_id
from ap_supplier_sites_all
where vendor_id = c_vendor_id
and upper(allow_awt_flag) = 'Y';

Cursor c_awt_type(c_org_id NUMBER) is
select CREATE_AWT_DISTS_TYPE
from ap_system_parameters_all
where org_id = c_org_id
and upper(allow_awt_flag) = 'Y';

  BEGIN
    /* Updating the AWT Group id for the vendor */

    UPDATE ap_suppliers pov
       SET pov.verification_number         = decode(p_verification_no,
                                                    NULL,
                                                    pov.verification_number,
                                                    p_verification_no),
           pov.match_status_flag           = p_match_status,
           pov.cis_verification_date       = p_verification_date,
           pov.awt_group_id                = p_awt_group_id,
           pov.pay_awt_group_id            = p_awt_group_id,     /* Also Updating the PAY_AWT_GROUP_ID for Bug#7218825 */
           pov.allow_awt_flag              = 'Y',
           pov.partnership_utr             = decode(p_utr,
                                                    NULL,
                                                    pov.partnership_utr,
                                                    decode(p_utr_type,
                                                           'P',
                                                           p_utr,
                                                           decode(pov.vendor_type_lookup_code,
                                                                  'PARTNERSHIP',
                                                                  p_utr,
                                                                  pov.partnership_utr))),
           pov.verification_request_id                  = p_req_id,                               --Bug 5606118
           pov.unique_tax_reference_num    = decode(p_utr,
                                                    NULL,
                                                    pov.unique_tax_reference_num,
                                                    decode(p_utr_type,
                                                           'U',
                                                           p_utr,
                                                           decode(pov.vendor_type_lookup_code,
                                                                  'PARTNERSHIP',
                                                                  pov.unique_tax_reference_num,
                                                                  p_utr))),
 -- Start : Bug <5586655> Commented for change request
   /*        pov.trading_name                = decode(p_sc_name,
                                                    NULL,
                                                    pov.trading_name,
                                                    decode(substr(p_sc_name,
                                                                  1,
                                                                  1),
                                                           '*',
                                                           pov.trading_name,
                                                           p_sc_name)),
           pov.vendor_name                 = decode(p_sc_name,
                                                    NULL,
                                                    pov.vendor_name,
                                                    decode(substr(p_sc_name,
                                                                  1,
                                                                  1),
                                                           '*',
                                                           substr(p_sc_name,
                                                                  2,
                                                                  length(p_sc_name)),
                                                           pov.vendor_name)),
 */
 --  End : Bug <5586655>
           pov.national_insurance_number   = decode(p_sc_ref_id,
                                                    NULL,
                                                    pov.national_insurance_number,
                                                    decode(length(p_sc_ref_id),
                                                           9,
                                                           p_sc_ref_id,
                                                           pov.national_insurance_number)),
           pov.company_registration_number = decode(p_sc_ref_id,
                                                    NULL,
                                                    pov.company_registration_number,
                                                    decode(length(p_sc_ref_id),
                                                           9,
                                                           pov.company_registration_number,
                                                           p_sc_ref_id))
     WHERE pov.vendor_id = p_vendor_id;

    /* Updating the debt factor vendors of the parent vendor */
    UPDATE ap_suppliers pov
       SET pov.awt_group_id = p_awt_group_id,
           pov.pay_awt_group_id = p_awt_group_id,        /* Also Updating the PAY_AWT_GROUP_ID for Bug#7218825 */
           pov.allow_awt_flag = 'Y'
     WHERE pov.cis_parent_vendor_id = p_vendor_id
       AND pov.vendor_type_lookup_code NOT IN
           ('SOLETRADER', 'PARTNERSHIP', 'TRUST', 'COMPANY');

/* Bug#7218825 - CIS WITHHOLDING PROJECT DUE TO AP ENHANCEMENT 6639866 ON 12.1 */

       open c_povs_orgs(p_vendor_id);
        loop

           fetch c_povs_orgs into l_org_id;
           exit when c_povs_orgs%NOTFOUND;

         open c_awt_type(l_org_id);
          loop

           fetch c_awt_type into l_create_awt_dists_type;
           exit when c_awt_type%NOTFOUND;

           If l_create_awt_dists_type = 'APPROVAL'
           then

           /* Updating all the vendor sites of the vendor */

           UPDATE ap_supplier_sites_all povs
           SET povs.awt_group_id = p_awt_group_id, povs.allow_awt_flag = 'Y'
           WHERE povs.vendor_id = p_vendor_id
           AND povs.org_id = l_org_id
	     AND povs.allow_awt_flag = 'Y'; --Bug 5642191

          /* Updating all the vendor sites of the debt factor vendors */

           UPDATE ap_supplier_sites_all povs
           SET povs.awt_group_id = p_awt_group_id, povs.allow_awt_flag = 'Y'
           WHERE povs.vendor_id IN
             (SELECT pov.vendor_id
                FROM ap_suppliers pov
               WHERE pov.cis_parent_vendor_id = p_vendor_id
                 AND pov.vendor_type_lookup_code NOT IN
                     ('SOLETRADER', 'PARTNERSHIP', 'TRUST', 'COMPANY'))
                 AND povs.org_id = l_org_id
                 AND povs.allow_awt_flag='Y';  --Bug 5642191

           elsif l_create_awt_dists_type = 'PAYMENT'
           then

          /* Updating all the vendor sites of the vendor */

           UPDATE ap_supplier_sites_all povs
           SET povs.pay_awt_group_id = p_awt_group_id, povs.allow_awt_flag = 'Y'
           WHERE povs.vendor_id = p_vendor_id
           AND povs.org_id = l_org_id
	     AND povs.allow_awt_flag = 'Y'; --Bug 5642191

          /* Updating all the vendor sites of the debt factor vendors */

            UPDATE ap_supplier_sites_all povs
           SET povs.pay_awt_group_id = p_awt_group_id, povs.allow_awt_flag = 'Y'
           WHERE povs.vendor_id IN
             (SELECT pov.vendor_id
                FROM ap_suppliers pov
               WHERE pov.cis_parent_vendor_id = p_vendor_id
                 AND pov.vendor_type_lookup_code NOT IN
                     ('SOLETRADER', 'PARTNERSHIP', 'TRUST', 'COMPANY'))
                 AND povs.org_id = l_org_id
                 AND povs.allow_awt_flag='Y';  --Bug 5642191

           elsif l_create_awt_dists_type = 'BOTH'
           then

         /* Updating all the vendor sites of the vendor */

            UPDATE ap_supplier_sites_all povs
             SET povs.awt_group_id = p_awt_group_id,
                povs.pay_awt_group_id = p_awt_group_id,
                povs.allow_awt_flag = 'Y'
             WHERE povs.vendor_id = p_vendor_id
                 AND povs.org_id = l_org_id
	           AND povs.allow_awt_flag = 'Y'; --Bug 5642191

          /* Updating all the vendor sites of the debt factor vendors */

            UPDATE ap_supplier_sites_all povs
             SET povs.awt_group_id = p_awt_group_id,
                povs.pay_awt_group_id = p_awt_group_id,
                povs.allow_awt_flag = 'Y'
             WHERE povs.vendor_id IN
               (SELECT pov.vendor_id
                 FROM ap_suppliers pov
                 WHERE pov.cis_parent_vendor_id = p_vendor_id
                 AND pov.vendor_type_lookup_code NOT IN
                     ('SOLETRADER', 'PARTNERSHIP', 'TRUST', 'COMPANY'))
                 AND povs.org_id = l_org_id
                 AND povs.allow_awt_flag='Y';  --Bug 5642191

           end if;

         end loop;   /* Cursor c_awt_type */

       close c_awt_type;

      end loop;     /* Cursor c_povs_orgs */

    close c_povs_orgs;

/* Bug#7218825 - CIS WITHHOLDING PROJECT DUE TO AP ENHANCEMENT 6639866 ON 12.1 */

  END pr_po_api;
END igi_cis2007_igipverp_pkg;

/
