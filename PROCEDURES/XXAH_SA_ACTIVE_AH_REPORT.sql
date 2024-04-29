--------------------------------------------------------
--  DDL for Procedure XXAH_SA_ACTIVE_AH_REPORT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."XXAH_SA_ACTIVE_AH_REPORT" 
(
  ERRBUF OUT VARCHAR2 
, RETCODE OUT NUMBER 
) AS 
    i               NUMBER := 1;
    j               NUMBER := 1;
    p_to            VARCHAR2(100) := 'robotic0193@aholddelhaize.com';--'ginni.singh@ah.nl';--
    lv_smtp_server  VARCHAR2(100) := 'vmebsdblpwe01.retail.ah.eu-int-aholddelhaize.com';
    lv_domain       VARCHAR2(100);
    lv_from         VARCHAR2(100) := 'EBSPROD@ah.nl';
    v_connection    utl_smtp.connection;
    c_mime_boundary CONSTANT VARCHAR2(256) := '--AAAAA000956--';
    v_clob          CLOB;
    ln_len          INTEGER;
    ln_index        INTEGER;
    ln_count        NUMBER;
    ln_code         VARCHAR2(10);
    ln_counter      NUMBER := 0;
    lv_instance     VARCHAR2(100);
    ln_cnt          NUMBER;
    ld_date         DATE;

BEGIN
    ld_date := sysdate;
    lv_domain := lv_smtp_server;
    --EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'''; --comma(1,5)
    --EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS=''.,'''; --decimal(1.5)
    
    BEGIN
        v_clob :=   'MAIN_CATEGORY'
                  || ','
                  || 'SUB_CATEGORY'
                  || ','
                  || 'CON_CATEGORY'
                  || ','
                  || 'SALES_REP_HEADER'
                  || ','
                  || 'CUSTOMER'
                  || ','
                  || 'PS_NUMBER'
                  || ','
                  || 'AGREEMENT_TYPE'
                  || ','
                  || 'SALES_AGREEMENT_NR'
                  || ','
                  || 'MAIN_AGREEMENT_NR'
                  || ','
                  || 'STATUS'
                  || ','
                  || 'CMT_EMPLOYEE'
                  || ','
                  || 'CREATION_DATE'
                  || ','
                  || 'WF_SUBMISSION_DATE'
                  || ','
                  || 'WF_PENDING_DATE'
                  || ','
                  || 'ACTUAL_ACTIVE_DATE'
                  || ','
                  || 'LINE_NR'
                  || ','
                  || 'AGREEMENT_LINE_ID'
                  || ','
                  || 'VA_TYPE'
                  || ','
                  || 'VA_TYPE_DESC'
                  || ','
                  || 'BENEFICIARY'
                  || ','
                  || 'AMOUNT'
                  || ','
                  || 'SALES_REP_LINE'
                  || ','
                  || 'LINE_DESCRIPTION'
                  || ','
                  || 'LINE_START_DATE'
                  || ','
                  || 'LINE_END_DATE'
                  || ','
                  || 'AUTO_ACCRUAL'
                  || ','
                  || 'PURCHASE_VALUE'
                  || ','
                  || 'VOLUME'
                  || ','
                  || 'COSTCENTER'
                  || ','
                  || 'BILLTYPE'
                  || ','
                  || 'PREV_BILL_DATE'
                  || ','
                  || 'PREV_BILL_AMOUNT'
                  || ','
                  || 'NEXT_BILL_DATE'
                  || ','
                  || 'NEXT_BILL_AMOUNT'
                  || ','
                  || 'ORG_ID'
                  || ','
                  || 'LEAD_SOURCING'
                  || ','
                  || 'BPA_NUMBER'
                  || ','
                  || 'PS_SUPPLIER_NR'
                  || ','
                  || 'PAYMENT_DAYS'
                  || ','
                  || 'PAYMENT_PERCENTAGE'
                  || ','
                  || 'HEADER_START_DATE'
                  || ','
                  || 'HEADER_END_DATE'
                  || ','
                  || 'BRAND_INDICATOR'
                  || ','
                  || 'INVOICE_AMOUNT'
                  || ','
                  || 'ACCRUAL_AMOUNT'
                  || ','
                  || 'PROMO_PRICE_START_DAY'
                  || ','
                  || 'PROMO_PRICE_START_WEEK'
                  || utl_tcp.crlf;

        v_connection := utl_smtp.open_connection(lv_smtp_server); --To open the connection      
        UTL_SMTP.helo (v_connection, lv_domain);
        utl_smtp.helo(v_connection, lv_smtp_server);
        utl_smtp.mail(v_connection, lv_from);
        utl_smtp.rcpt(v_connection, p_to); -- To send mail to valid receipent
        utl_smtp.open_data(v_connection);
        utl_smtp.write_data(v_connection, 'From: '
                                          || lv_from
                                          || utl_tcp.crlf);
        IF TRIM(p_to) IS NOT NULL THEN
            utl_smtp.write_data(v_connection, 'To: '
                                              || p_to
                                              || utl_tcp.crlf);
        END IF;

        utl_smtp.write_data(v_connection, 'Subject: XXAH_SA_ACTIVE_AH_Report' || utl_tcp.crlf);
        utl_smtp.write_data(v_connection, 'MIME-Version: 1.0' || utl_tcp.crlf);
        utl_smtp.write_data(v_connection, 'Content-Type: multipart/mixed; boundary="'
                                          || c_mime_boundary
                                          || '"'
                                          || utl_tcp.crlf);

        utl_smtp.write_data(v_connection, utl_tcp.crlf);
        utl_smtp.write_data(v_connection, 'This is a multi-part message in MIME format.' || utl_tcp.crlf);
        utl_smtp.write_data(v_connection, '--'
                                          || c_mime_boundary
                                          || utl_tcp.crlf);
        utl_smtp.write_data(v_connection, 'Content-Type: text/plain' || utl_tcp.crlf);
        ln_cnt := 1;

        /*Condition to check for the creation of csv attachment*/
        IF ( ln_cnt <> 0 ) THEN
            utl_smtp.write_data(v_connection, 'Content-Disposition: attachment; filename="'
                                              || 'XXAH_SA_ACTIVE_AH_REPORT'
                                              || to_char(ld_date, 'dd-mon-rrrr hh:mi')
                                              || '.csv'
                                              || '"'
                                              || utl_tcp.crlf);
        END IF;

        utl_smtp.write_data(v_connection, utl_tcp.crlf);
        FOR i IN (
            SELECT
                --opco,
                main_category,
                sub_category,
                con_category,
                sales_rep_header,
                customer,
                ps_number,
                agreement_type,
                --status,
                sales_agreement_nr,
                main_agreement_nr,
                status,
                cmt_employee,
                cmt_creation_date,
                wf_submission_date,
                wf_pending_date,
                actual_active_date,
                line_nr,
                agreement_line_id,
                va_type,
                va_type_desc,
                beneficiary,
                amount,
                sales_rep_line,
                substr(replace(replace(replace(replace(replace(line_description, '&', '&amp;'),
                                                       CHR(10),
                                                       ''),
                                               CHR(13),
                                               ''),
                                       CHR(09),
                                       ''),
                               '>',
                               '&gt;'),
                       1,
                       200) line_description,
                line_start_date,
                line_end_date,
                auto_accrual,
                purchase_value,
                volume,
                costcenter,
                billtype,
                prev_bill_date,
                prev_bill_amount,
                next_bill_date,
                next_bill_amount,
                org_id,
                lead_sourcing,
                bpa_number,
                ps_supplier_nr,
                payment_days,
                payment_percentage,
                header_start_date,
                header_end_date,
                brand_indicator,
                invoice_amount,
                accrual_amount,
                promo_price_start_day,
                promo_price_start_week
            FROM
                (
                    SELECT
                        '"'
                        || ou.name
                        || '"'                                          opco,
                        bh.order_number,
                        bl.line_number,
                        ble.start_date_active,
                        ble.end_date_active,
                        '"'
                        || mc.segment1
                        || '"'                                          main_category,
                        mc.segment2                                     sub_category,
                        mc.segment1
                        || '.'
                        || mc.segment2                                  con_category,
                        '"'
                        || (
                            SELECT DISTINCT
                                pap.full_name
                            FROM
                                per_all_people_f pap,
                                jtf_rs_salesreps rs
                            WHERE
                                    bh.salesrep_id = rs.salesrep_id
                                AND rs.person_id = pap.person_id
                                AND pap.effective_start_date <= sysdate
                                AND nvl(pap.effective_end_date, sysdate + 10) >= sysdate
                                AND bh.org_id = rs.org_id
                        )
                        || '"'                                          sales_rep_header,
                        '"' || p.party_name || '"'                                                                        customer,
                        substr(cas.orig_system_reference, 1, 9)         ps_number,
                        (
                            SELECT
                                tt.name
                            FROM
                                oe_transaction_types_tl tt
                            WHERE
                                tt.transaction_type_id = bh.order_type_id
                        )                                               agreement_type,
                        bh.order_number                                 sales_agreement_nr,
                        bh.attribute12                                  main_agreement_nr,
                        bh.flow_status_code                             status,
                        '"'
                        || bh.attribute14
                        || '"'                                          cmt_employee,
                        substr(bh.attribute15, 1, 10)                   cmt_creation_date,
                        to_char(wflas.va_submission_date, 'DD-MM-YYYY') wf_submission_date,
                        to_char(wflpc.va_pending_ca_date, 'DD-MM-YYYY') wf_pending_date,
                        substr(bh.attribute13, 1, 10)                   actual_active_date,
                        bl.line_number                                  line_nr,
                        bl.line_id                                      agreement_line_id,
                        bl.ordered_item                                 va_type,
/*(select ctva.description from mtl_item_categories icva , mtl_categories_b cbva , mtl_categories_tl ctva where si.inventory_item_id = icva.inventory_item_id and icva.category_id = cbva.category_id and cbva.category_id = ctva.category_id and icva.organization_id = si.organization_id and cbva.structure_id = 50332)*/ 
--commented STHAMKE 30-AUG-16 
                        '"'
                        || si.description
                        || '"'                                          va_type_desc --Added STHAMKE 30-AUG-16 
                        ,
                        (
                            SELECT
                                cbbf.segment1
                            FROM
                                mtl_item_categories icbf,
                                mtl_categories_b    cbbf
                            WHERE
                                    si.inventory_item_id = icbf.inventory_item_id
                                AND icbf.category_id = cbbf.category_id
                                AND icbf.organization_id = si.organization_id
                                AND cbbf.structure_id = 50331
                        )                                               beneficiary,
                        ble.blanket_line_min_amount                     amount,
                        '"'
                        || (
                            SELECT DISTINCT
                                pap2.full_name
                            FROM
                                per_all_people_f pap2,
                                jtf_rs_salesreps rs2
                            WHERE
                                    bl.salesrep_id = rs2.salesrep_id
                                AND bl.header_id = bh.header_id
                                AND rs2.person_id = pap2.person_id
                                AND pap2.effective_start_date <= sysdate
                                AND nvl(pap2.effective_end_date, sysdate + 10) >= sysdate
                                AND rs2.org_id = bl.org_id
                        )
                        || '"'                                          sales_rep_line,
                        '"'
                        || bl.attribute5
                        || '"'                                          line_description,
                        to_char(ble.start_date_active, 'DD-MM-YYYY')    line_start_date,
                        to_char(ble.end_date_active, 'DD-MM-YYYY')      line_end_date 
-- , bh.attribute10 header_auto_accrual -- , bl.attribute2 line_autoaccrual
                        ,
                        decode(bh.attribute10,
                               'N',
                               'N',
                               nvl(bl.attribute2, 'Y'))                 auto_accrual,
                        bl.attribute1                                   purchase_value,
                        bl.attribute3                                   volume,
                        bl.attribute4                                   costcenter,
                        bl.attribute6                                   billtype,
                        to_char(indv.prev_inv_date, 'DD-MM-YYYY')       prev_bill_date,
                        indv.prev_inv_amount                            prev_bill_amount,
                        to_char(indv2.next_inv_date, 'DD-MM-YYYY')      next_bill_date,
                        indv2.next_inv_amount                           next_bill_amount,
                        bl.org_id                                       org_id,
                        '"' || decode(bh.attribute4,
                               NULL,
                               'NA',
                               nvl(bpad.lead_sourcing_manager, 'NF')) || '"'                  lead_sourcing,
                        decode(bh.attribute4,
                               NULL,
                               'NA',
                               nvl(bpad.bpa_number, 'NF'))              bpa_number,
                        decode(bh.attribute4,
                               NULL,
                               'NA',
                               nvl(bpad.ps_supplier_nr, 'NF'))          ps_supplier_nr,
                        decode(bh.attribute4,
                               NULL,
                               'NA',
                               nvl(bpad.payment_days, 'NF'))            payment_days,
                        '"' || decode(bh.attribute4,
                               NULL,
                               'NA',
                               nvl(bpad.payment_percentage, 'NF')) || '"'      payment_percentage,
                        to_char(bhe.start_date_active, 'DD-MM-YYYY')    header_start_date,
                        to_char(bhe.end_date_active, 'DD-MM-YYYY')      header_end_date,
                        bl.attribute9                                   brand_indicator,
                        bh.attribute16                                  promo_price_start_day,
                        '"' || bh.attribute17 || '"'                                  promo_price_start_week 
--,ooha.* 
                    FROM
                        oe_blanket_lines_all      bl,
                        oe_blanket_lines_ext      ble,
                        oe_blanket_headers_all    bh,
                        oe_blanket_headers_ext    bhe,
                        mtl_system_items_b        si,
                        mtl_categories_b          mc,
                        hr_all_organization_units ou,
                        hz_cust_site_uses_all     su,
                        hz_cust_acct_sites_all    cas,
                        hz_cust_accounts          ca,
                        hz_parties                p,
                        bom_exception_sets        inc,
                        (
                            SELECT
                                ind.exception_date prev_inv_date,
                                ind.attribute1     prev_inv_amount,
                                ind.exception_set_id
                            FROM
                                bom_exception_set_dates ind
                            WHERE
                                ind.exception_date = (
                                    SELECT
                                        MAX(ind2.exception_date)
                                    FROM
                                        bom_exception_set_dates ind2
                                    WHERE
                                            sysdate >= ind2.exception_date
                                        AND ind.exception_set_id = ind2.exception_set_id
                                )
                        )                         indv,
                        (
                            SELECT
                                ind.exception_date next_inv_date,
                                ind.attribute1     next_inv_amount,
                                ind.exception_set_id
                            FROM
                                bom_exception_set_dates ind
                            WHERE
                                ind.exception_date = (
                                    SELECT
                                        MIN(ind2.exception_date)
                                    FROM
                                        bom_exception_set_dates ind2
                                    WHERE
                                            sysdate < ind2.exception_date
                                        AND ind.exception_set_id = ind2.exception_set_id
                                )
                        )                         indv2,
                        (
                            SELECT
                                wfs.item_key va_header,
                                wfs.end_date va_submission_date
                            FROM
                                wf_item_activity_statuses wfs
                            WHERE
                                    wfs.item_type = 'OENH'
                                AND wfs.activity_result_code = 'SUBMIT_DRAFT'
                        )                         wflas,
                        (
                            SELECT
                                wfs2.item_key va_header,
                                wfs2.end_date va_pending_ca_date
                            FROM
                                wf_item_activity_statuses wfs2
                            WHERE
                                    wfs2.item_type = 'OENH'
                                AND wfs2.activity_result_code = 'APPROVE'
                        )                         wflpc,
                        (
                            SELECT
                                pha.po_header_id       bpa_header_id,
                                pha.segment1           bpa_number,
                                asp.vendor_name        supplier,
                                papf.full_name         lead_sourcing_manager,
                                pha.attribute2         related_va_agreements,
                                pha.attribute15        payment_days,
                                pha.attribute14        payment_percentage,
                                assa.global_attribute2 ps_supplier_nr
                            FROM
                                po_headers_all        pha,
                                ap_suppliers          asp,
                                ap_supplier_sites_all assa,
                                per_all_people_f      papf
                            WHERE
                                    pha.vendor_id = asp.vendor_id
                                AND assa.vendor_site_id = pha.vendor_site_id
                                AND asp.attribute13 = papf.person_id (+)
                                AND trunc(sysdate) BETWEEN papf.effective_start_date AND papf.effective_end_date
                        )                         bpad --,oe_order_headers_all ooha 
                    WHERE
                            bl.header_id = bh.header_id
                        AND bh.order_number = bhe.order_number --and ooha.blanket_number=bh.order_number
                        AND bl.line_id = ble.line_id
                        AND bl.ordered_item = si.segment1
                        AND si.inventory_item_id = bl.inventory_item_id --Added STHAMKE 30-AUG-16 
                        AND si.organization_id = 84
                        AND bl.org_id = ou.organization_id
                        AND bh.ship_to_org_id = su.site_use_id
                        AND su.cust_acct_site_id = cas.cust_acct_site_id
                        AND cas.cust_account_id = ca.cust_account_id
                        AND ca.party_id = p.party_id
                        AND bh.attribute2 = mc.category_id
                        AND mc.structure_id = 201
                        AND to_char(bl.line_id) = inc.attribute10 (+)
                        AND inc.exception_set_id = indv.exception_set_id (+)
                        AND inc.exception_set_id = indv2.exception_set_id (+)
                        AND wflas.va_header (+) = bh.header_id
                        AND wflpc.va_header (+) = bh.header_id
                        AND bpad.bpa_header_id (+) = bh.attribute4
                ) sa,
                (
                    SELECT
                        CASE
                            WHEN ottl.name = 'AES Accrual'
                                 OR ottl.name = 'AH Accrual'
                                 OR ottl.name = 'Etos Accrual'
                                 OR ottl.name = 'Gall Accrual' THEN
                                '"' || SUM(fulfilled_quantity * unit_selling_price) || '"'
                        END AS accrual_amount,
                        CASE
                            WHEN ottl.name = 'AES Invoice'
                                 OR ottl.name = 'AH Invoice'
                                 OR ottl.name = 'Etos Invoice'
                                 OR ottl.name = 'Gall Invoice' THEN
                                '"' || SUM(fulfilled_quantity * unit_selling_price) || '"'
                        END AS invoice_amount,
                        oola.blanket_line_number,
                        ooha.blanket_number
                    FROM
                        oe_order_headers_all    ooha,
                        oe_order_lines_all      oola,
                        oe_transaction_types_tl ottl
                    WHERE
                            ooha.header_id = oola.header_id
                        AND ooha.order_type_id = ottl.transaction_type_id
                    GROUP BY
                        name,
                        oola.blanket_line_number,
                        ooha.blanket_number
                ) amt
            WHERE
                    sa.order_number = amt.blanket_number (+)
                AND sa.line_number = amt.blanket_line_number (+)
                AND sales_agreement_nr <> 124075 
--AND start_date_active >= fnd_date.canonical_to_date (:p_start_date) AND end_date_active <= fnd_date.canonical_to_date (:p_end_date) AND org_id = NVL (:p_org_id, org_id) ORDER BY org_id, sales_agreement_nr, line_nr 
    --AND org_id = nvl(:p_org_id, org_id)
                AND status = 'ACTIVE'
                AND org_id = 150
      AND start_date_active >= to_date('01/01/2023','mm/dd/yyyy')
    --AND trunc(start_date_active) >= TO_DATE(:p_start_date, 'DD-MON-YYYY')
    --AND trunc(end_date_active) <= TO_DATE(:p_end_date, 'DD-MON-YYYY')
            ORDER BY
                org_id,
                sales_agreement_nr,
                line_nr
        ) LOOP
            ln_counter := ln_counter + 1;
            IF ln_counter = 1 THEN
                utl_smtp.write_data(v_connection, v_clob); --To avoid repeation of column heading in csv file
            END IF;
            BEGIN
                v_clob := '='
                          || i.main_category
                          || ','
                          || i.sub_category
                          || ','
                          || i.con_category
                          || ','
                          || i.sales_rep_header
                          || ','
                          || i.customer
                          || ','
                          || i.ps_number
                          || ','
                          || i.agreement_type
                          || ','
                          || i.sales_agreement_nr
                          || ','
                          || i.main_agreement_nr
                          || ','
                          || i.status
                          || ','
                          || i.cmt_employee
                          || ','
                          || i.cmt_creation_date
                          || ','
                          || i.wf_submission_date
                          || ','
                          || i.wf_pending_date
                          || ','
                          || i.actual_active_date
                          || ','
                          || i.line_nr
                          || ','
                          || i.agreement_line_id
                          || ','
                          || i.va_type
                          || ','
                          || i.va_type_desc
                          || ','
                          || i.beneficiary
                          || ','
                          || i.amount
                          || ','
                          || i.sales_rep_line
                          || ','
                          || i.line_description
                          || ','
                          || i.line_start_date
                          || ','
                          || i.line_end_date
                          || ','
                          || i.auto_accrual
                          || ','
                          || i.purchase_value
                          || ','
                          || i.volume
                          || ','
                          || i.costcenter
                          || ','
                          || i.billtype
                          || ','
                          || i.prev_bill_date
                          || ','
                          || i.prev_bill_amount
                          || ','
                          || i.next_bill_date
                          || ','
                          || i.next_bill_amount
                          || ','
                          || i.org_id
                          || ','
                          || i.lead_sourcing
                          || ','
                          || i.bpa_number
                          || ','
                          || i.ps_supplier_nr
                          || ','
                          || i.payment_days
                          || ','
                          || i.payment_percentage
                          || ','
                          || i.header_start_date
                          || ','
                          || i.header_end_date
                          || ','
                          || i.brand_indicator
                          || ','
                          || i.invoice_amount
                          || ','
                          || i.accrual_amount
                          || ','
                          || i.promo_price_start_day
                          || ','
                          || i.promo_price_start_week
                          || utl_tcp.crlf;
            EXCEPTION
                WHEN OTHERS THEN
                    fnd_file.put_line(fnd_file.log, sqlerrm);
            END;

            utl_smtp.write_data(v_connection, v_clob); --Writing data in csv attachment.
        END LOOP;

        utl_smtp.write_data(v_connection, utl_tcp.crlf);
        utl_smtp.close_data(v_connection);
        utl_smtp.quit(v_connection);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log, sqlerrm);
    END;

END;
--NULL;
--END XXAH_SA_ACTIVE_AH_REPORT;

/
