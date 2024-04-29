--------------------------------------------------------
--  DDL for Package Body IGI_CIS2007_IGIPSUPR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS2007_IGIPSUPR_PKG" AS
-- $Header: igipsupb.pls 120.0.12000000.2 2007/07/18 13:06:27 vensubra noship $

  FUNCTION beforereport RETURN BOOLEAN IS
  BEGIN
    pwhereclause := ' grp.group_id (+) = pov.awt_group_id
	 AND grp_tax.group_id (+) = grp.group_id
	 AND tax_codes.name (+) = grp_tax.tax_name
	 AND tax_codes.enabled_flag (+) = ''Y''
	 AND nvl(IGI_CIS2007_IGIPSUPR_PKG.check_active(tax_codes.START_DATE,tax_codes.inactive_date),''A'') = ''A''
	 AND tax.tax_name (+) = tax_codes.name
	 AND nvl(tax.rate_type,''X'') NOT IN (''CERTIFICATE'',''EXCEPTION'')
	 AND nvl(IGI_CIS2007_IGIPSUPR_PKG.check_active(tax.START_DATE,
																	 tax.END_DATE),''A'') = ''A''
	 AND pov.cis_enabled_flag = ''Y''';

  -- Changes made by arvind on 15-09-2006
  /*  IF (p_report = 'IGIPVERR') THEN
      pwhereclause := pwhereclause ||
                      ' AND decode(igi_cis2007_igipverp_pkg.igi_cis_is_vendor_paid(pov.vendor_id),
                 ''NOTPAID'',
                 nvl(pov.cis_verification_date,add_months(SYSDATE, -25)),
                 add_months(SYSDATE, -25)) < add_months(SYSDATE, -24)';
    END IF; */

    IF p_report = 'IGIPVERR' THEN
      pwhereclause := pwhereclause  ||
                      ' AND nvl(trunc(cis_verification_date),trunc(sysdate)) <= trunc(sysdate)';
    END IF;

  -- End Changes

    IF (p_report = 'IGIPSUPR') THEN
      p_active := 'A';
    END IF;

    IF (p_active IS NOT NULL) THEN
      pwhereclause := pwhereclause ||
                      ' AND IGI_CIS2007_IGIPSUPR_PKG.check_active(pov.START_DATE_ACTIVE,
																	 pov.END_DATE_ACTIVE) = ' || '''' ||
                      p_active || '''';
    END IF;

    IF (p_supplier_from IS NOT NULL) THEN
      pwhereclause := pwhereclause || ' AND pov.vendor_name >= ' || '''' ||
                      p_supplier_from || '''';
    END IF;

    IF (p_supplier_to IS NOT NULL) THEN
      pwhereclause := pwhereclause || ' AND pov.vendor_name <= ' || '''' ||
                      p_supplier_to || '''';
    END IF;

    porderclause := ' order by ';

    IF (p_report = 'IGIPVERR') THEN
      porderclause := porderclause || 'VERIFY_STATUS, ';
    END IF;

    IF (p_sort_by IS NOT NULL) THEN
      porderclause := porderclause || p_sort_by;
    ELSE
      porderclause := porderclause || 'VENDOR_NAME';
    END IF;

    RETURN(TRUE);

  END beforereport;

  FUNCTION get_p_supplier_from RETURN VARCHAR2 IS
  BEGIN
    RETURN(p_supplier_from);
  END get_p_supplier_from;

  FUNCTION get_p_supplier_to RETURN VARCHAR2 IS
  BEGIN
    RETURN(p_supplier_to);
  END get_p_supplier_to;

  FUNCTION get_p_report_title RETURN VARCHAR2 IS
    l_report_title igi_lookups.meaning%TYPE := NULL;
  BEGIN
    BEGIN
      SELECT meaning
        INTO l_report_title
        FROM igi_lookups
       WHERE lookup_type = 'IGI_CIS2007_NEW_REPORTS'
         AND lookup_code = p_report;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN(l_report_title);

  END get_p_report_title;

  FUNCTION get_p_org_name RETURN VARCHAR2 IS
    l_org_id   hr_operating_units.organization_id%TYPE := NULL;
    l_org_name hr_operating_units.NAME%TYPE := NULL;
  BEGIN
    BEGIN
      l_org_id := MO_GLOBAL.get_current_org_id;

      SELECT NAME
        INTO l_org_name
        FROM hr_operating_units
       WHERE organization_id = l_org_id;

    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN(l_org_name);
  END get_p_org_name;

  FUNCTION get_p_active RETURN VARCHAR2 IS
    l_active_meaning igi_lookups.meaning%TYPE := NULL;
  BEGIN
    BEGIN
      SELECT meaning
        INTO l_active_meaning
        FROM igi_lookups
       WHERE lookup_type = 'IGI_CIS2007_ACTIVE_TYPE'
         AND lookup_code = p_active;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN(l_active_meaning);
  END get_p_active;

  FUNCTION get_p_sortby RETURN VARCHAR2 IS
    l_sortby_meaning igi_lookups.meaning%TYPE := NULL;
    l_lookup_type    igi_lookups.lookup_type%TYPE := NULL;
  BEGIN
    BEGIN
      IF (p_report = 'IGIPVERR') THEN
        l_lookup_type := 'IGI_CIS2007_VERR_SORT_COLS';
      ELSIF (p_report = 'IGIPSUPR') THEN
        l_lookup_type := 'IGI_CIS2007_SUPR_SORT_COLS';
      END IF;

      SELECT meaning
        INTO l_sortby_meaning
        FROM igi_lookups
       WHERE lookup_type = l_lookup_type
         AND lookup_code = p_sort_by;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN(l_sortby_meaning);
  END get_p_sortby;

  FUNCTION check_active
  (
    p_start_date DATE,
    p_end_date   DATE
  ) RETURN VARCHAR2 IS

    l_active_flag VARCHAR2(1) := NULL;
  BEGIN
    BEGIN
      SELECT decode(sign(trunc(nvl(p_start_date, SYSDATE)) - trunc(SYSDATE)),
                    1,
                    'I',
                    decode(sign(trunc(nvl(p_end_date, SYSDATE)) -
                                trunc(SYSDATE)),
                           -1,
                           'I',
                           'A'))
        INTO l_active_flag
        FROM dual;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN(l_active_flag);

  END check_active;

  FUNCTION igi_cis_is_vendor_verified (l_vendor_id NUMBER)
        RETURN VARCHAR2
    AS
        verify_status VARCHAR2(20);
    BEGIN

        SELECT 'VERIFIED'
            INTO verify_status
        FROM ap_suppliers
            WHERE vendor_id = l_vendor_id
            AND cis_verification_date > add_months(sysdate,-24)
            AND rownum = 1;

        RETURN 'VERIFIED';
    EXCEPTION
        WHEN no_data_found THEN
            RETURN 'NOTVERIFIED';

    END igi_cis_is_vendor_verified;

    FUNCTION igi_cis_is_vendor_paid (l_vendor_id NUMBER,verify_date DATE DEFAULT SYSDATE)
        RETURN VARCHAR2
    AS
        tax_year_start DATE;
        paid_status VARCHAR2(20);
    BEGIN

        IF to_date(to_char(verify_date, 'dd-mm') || '2005', 'dd-mm-yyyy') >
            to_date('05-04-2005', 'dd-mm-yyyy')
        THEN
            tax_year_start := to_date('06-04-' || to_char(verify_date, 'YYYY'),'DD-MM-YYYY');
        ELSE
            tax_year_start := add_months(to_date('06-04-' ||
                                        to_char(verify_date, 'YYYY'),'DD-MM-YYYY'),
                                        - 12);
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

    FUNCTION igi_cis_new_verified(l_vendor_id NUMBER)
        RETURN BOOLEAN
        --VARCHAR2
    AS
        verify_status VARCHAR2(20);
    BEGIN

        SELECT 'VERIFIED'
            INTO verify_status
        FROM ap_suppliers
            WHERE vendor_id = l_vendor_id
            AND cis_verification_date > add_months(sysdate,-24)
            AND rownum = 1;

        RETURN TRUE;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN FALSE;

    END igi_cis_new_verified;

     FUNCTION is_paid (p_vendor_id number,
                       p_start_date date,
                       p_end_date date) RETURN boolean
     AS
       paid_status varchar2(8);
     Begin
        SELECT 'PAID'
            INTO paid_status
        FROM ap_checks ac,
             ap_invoice_payments pay,
             ap_invoices inv,
             ap_supplier_sites pvs
        WHERE ac.vendor_id = p_vendor_id
            AND ac.void_date IS NULL
            AND pay.check_id = ac.check_id
            AND accounting_date between p_start_date and p_end_date
            AND inv.invoice_id = pay.invoice_id
            AND pvs.vendor_id = inv.vendor_id
            AND pvs.vendor_site_id = inv.vendor_site_id
            AND pvs.allow_awt_flag = 'Y'
            AND rownum = 1;
        RETURN true;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN false;
    End is_paid;

    FUNCTION is_there_in_monthly_return(p_vendor_id number,
                       p_start_date date,
                       p_end_date date) RETURN boolean
     AS
       v_tmp  number(1);
     Begin
         select 1 into v_tmp
         from igi_cis_mth_ret_hdr_h hdr, igi_cis_mth_ret_lines_h line
         where hdr.header_id = line.header_id
         and line.vendor_id = p_vendor_id
         and hdr.period_ending_date between p_start_date and p_end_date
         and rownum = 1;
         Return true;
     Exception
        when no_data_found then
        Return false;
     End is_there_in_monthly_return;

     FUNCTION is_details_available(p_vendor_id number) RETURN boolean
     AS
      cursor cert is
      select upper(certificate_type) cert_type,nvl(end_date,sysdate) edt
      from ap_awt_tax_rates
      where vendor_id = p_vendor_id
      and upper(certificate_type) in ('CIS4T','CIS5','CIS6','CIS4P');
      first_cis_txyr_start date := to_date('06-04-2007','DD-MM-YYYY');
     Begin
         For i in cert loop
             If i.cert_type = 'CIS4P' Then
                 Return true;
             End if;
             If i.cert_type in ('CIS4T','CIS5','CIS6')
                and i.edt >= first_cis_txyr_start Then
                 Return true;
             End if;
         End loop;
         Return false;
     End is_details_available;

     FUNCTION verification_status (p_vendor_id NUMBER) RETURN VARCHAR2
     AS
          first_cis_txyr_start date := to_date('06-04-2007','DD-MM-YYYY');
          first_cis_txyr_end   date;
          curr_cis_txyr_start  date;
          curr_cis_txyr_end    date;
          prev_cis_txyr_start1 date;
          prev_cis_txyr_end1   date;
          prev_cis_txyr_start2 date;
          prev_cis_txyr_end2   date;
          v_check_list1 boolean;
          v_check_list2 boolean;
          v_check_list3 boolean;
     Begin
          first_cis_txyr_end   := add_months(first_cis_txyr_start,12) - 1;
          If sysdate between to_date('06-04-' || to_char(sysdate,'YYYY'),'DD-MM-YYYY')
             and to_date('31-12-' || to_char(sysdate,'YYYY'),'DD-MM-YYYY') Then
              curr_cis_txyr_start := to_date('06-04-' || to_char(sysdate,'YYYY'),'DD-MM-YYYY');
          else
              curr_cis_txyr_start := to_date('06-04-' || to_char(to_number(to_char(sysdate,'YYYY'))-1),'DD-MM-YYYY');
          end if;
          curr_cis_txyr_end    := add_months(curr_cis_txyr_start,12) - 1;
          prev_cis_txyr_start1 := add_months(curr_cis_txyr_start,-12);
          prev_cis_txyr_end1   := add_months(prev_cis_txyr_start1,12) - 1;
          prev_cis_txyr_start2 := add_months(curr_cis_txyr_start,-24);
          prev_cis_txyr_end2 := add_months(prev_cis_txyr_start2,12) - 1;

          /*dbms_output.put_line('first_cis_txyr_start = ' || first_cis_txyr_start);
          dbms_output.put_line('first_cis_txyr_end = ' || first_cis_txyr_end);
          dbms_output.put_line('curr_cis_txyr_start = ' || curr_cis_txyr_start);
          dbms_output.put_line('curr_cis_txyr_end = ' || curr_cis_txyr_end);
          dbms_output.put_line('prev_cis_txyr_start1 = ' || prev_cis_txyr_start1);
          dbms_output.put_line('prev_cis_txyr_end1 = ' || prev_cis_txyr_end1);
          dbms_output.put_line('prev_cis_txyr_start2 = ' || prev_cis_txyr_start2);
          dbms_output.put_line('prev_cis_txyr_end2 = ' || prev_cis_txyr_end2);*/

	   If igi_cis_new_verified(p_vendor_id)  THEN
                  RETURN 'VERIFIED';
           END IF;

          --Check whether vendor paid during current tax year or not.
          If is_paid(p_vendor_id,curr_cis_txyr_start,curr_cis_txyr_end) Then
             --dbms_output.put_line('Paid in current year so verified');
             Return 'VERIFIED';
          End if;
          --dbms_output.put_line('Not Paid in current year');

          --Check whether vendor paid during previous two tax years or not.
          --If is_paid(p_vendor_id,prev_cis_txyr_start1,prev_cis_txyr_end2) Then
          If is_paid(p_vendor_id,prev_cis_txyr_start2,prev_cis_txyr_end1) Then
             --dbms_output.put_line('Paid in during last two year');
             --Check whether either of previous year is before
             --first cis tax start year
             If prev_cis_txyr_end1 < first_cis_txyr_start or
                prev_cis_txyr_end2 < first_cis_txyr_start Then
                --Check whether vendor is paid during first cis tax year
                --dbms_output.put_line('either of previous year is before');
                --If is_paid(p_vendor_id,first_cis_txyr_start,first_cis_txyr_end) Then
                --If vendor paid during first cis tax year then
                --need to satisfy following conditions
                     --dbms_output.put_line('vendor is paid during first cis tax year');
                     --1. Check Vendor is there in monthly return of first cis tax year
                     v_check_list1 := is_there_in_monthly_return(p_vendor_id,first_cis_txyr_start,first_cis_txyr_end);
                     --2. Check Vendor is paid for last two years from first cis start date
                     v_check_list2 := is_paid(p_vendor_id,add_months(first_cis_txyr_start,-24),sysdate);
                     --3. Check whether vendor details available
                     v_check_list3 := is_details_available(p_vendor_id);
                     /*If v_check_list1 then
                        dbms_output.put_line('check list 1 = true');
                     end if;

                     If v_check_list2 = true then
                     dbms_output.put_line('check list 2 = true');
                     end if;
                     If v_check_list3 = true then
                     dbms_output.put_line('check list 3 = true');
                     end if;*/

                     If v_check_list1 = true or
                        (v_check_list2 = true and
                        v_check_list3 = true) Then
                        Return 'VERIFIED';
                     End If;
                 --If vendor does not satify check list then
                 --requires verification
                 --dbms_output.put_line('vendor does not satify check list - Not verified');
                 --Return 'NOTVERIFIED';
                --End if;
                --If vendor is not paid during first cis tax year then
                --requires verification
                 --dbms_output.put_line('vendor is not paid during first cis tax year - Not verified');
                Return 'NOTVERIFIED';
             End If;
             --If none of the previous tax year is before first cis tax year
             --then vendor is verified
             Return 'VERIFIED';
          End if;
          --If vendor is not paid during previous two tax years then requires Verification.
          --dbms_output.put_line('vendor is not paid during previous two tax years - Not verified');
          Return 'NOTVERIFIED';
     end verification_status;

     FUNCTION igi_cis_is_verify_required (l_vendor_id NUMBER)
        RETURN VARCHAR2
    AS
    BEGIN
	/*IF igi_cis_is_vendor_paid(l_vendor_id) = 'NOTPAID' AND
	   igi_cis_is_vendor_verified(l_vendor_id) = 'NOTVERIFIED'
	THEN
	   return 'NOTVERIFIED';
	ELSE
	   return 'VERIFIED';
	END IF;*/
    	return verification_status(l_vendor_id);

    END igi_cis_is_verify_required;

END igi_cis2007_igipsupr_pkg;

/
