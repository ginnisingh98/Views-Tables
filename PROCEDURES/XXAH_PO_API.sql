--------------------------------------------------------
--  DDL for Procedure XXAH_PO_API
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."XXAH_PO_API" (errbuf    OUT VARCHAR2,
                                         retcode   OUT NUMBER)
AS
    ---To Import data from Interface to Base Tables - Import Standard Purchase Orders
    -- please do the following: to see the errors
    -- Run the program - Purchasing Interface Errors Report
    -- choose parameter : PO_DOCS_OPEN_INTERFACE
    -- po_interface_errors

    l_currency_code         fnd_currencies_vl.currency_code%TYPE;
    l_verify_flag           VARCHAR2 (10) := NULL;
    l_error_message         VARCHAR2 (4000);
    l_vendor_id             po_vendors.vendor_id%TYPE;
    l_vendor_site_id        po_vendor_sites_all.vendor_site_id%TYPE;
    l_ship_to               hr_locations.location_id%TYPE;
    l_bill_to               hr_locations.location_id%TYPE;
    l_inventory_item_id     mtl_system_items_b.inventory_item_id%TYPE;
    l_agent_id              xxah_po_headers_interface.agent_id%TYPE;
    l_person_id             per_all_people_f.person_id%TYPE;
    l_terms_id              xxah_po_headers_interface.terms_id%TYPE;
    l_legacy_ponum          NUMBER (20) := 0;
    l_batch_id              NUMBER (3);
    l_resp_id               VARCHAR2 (10) := 0;
    v_request_id            VARCHAR2 (20) := 0;
    l_interface_header_id   xxah_po_headers_interface.interface_header_id%TYPE
        := 0;
    new_po_line_id          xxah_po_lines_interface.interface_line_id%TYPE
                                := 0;
    l_int_po_header_id      NUMBER;
    l_int_po_line_id        NUMBER;
    vs_process_code varchar2(10);
    lc_phase            VARCHAR2(50);
    lc_status           VARCHAR2(50);
    lc_dev_phase        VARCHAR2(50);
    lc_dev_status       VARCHAR2(50);
    lc_message          VARCHAR2(50);
    l_req_return_status BOOLEAN;

    CURSOR c_po_header IS
          SELECT DISTINCT
                 interface_header_id,
                 org_id,
                 NVL (currency_code, 'EUR')
                     currency_code,
                 agent_name,
                 vendor_name,
                 vendor_site_id,
                 vendor_contact_id,
                 acceptance_due_date,
                 freight_carrier,
                 fob,
                 ship_to_location,
                 bill_to_location,
                 payment_terms || ' Days'
                     payment_terms,
                 freight_terms,
                 approval_status,
                 --DECODE (approval_status,  'U', 'Approved',  'I', 'Incomplete')
                 'Approved'
                     status,
                 comments,
                 acceptance_required_flag,
                 amount_agreed,
                 amount_limit,
                 min_release_amount,
                 effective_date,
                 expiration_date,
                 --TO_CHAR (TO_DATE (attribute1, 'YYYY/MM/DD HH24:MI:SS'),'YYYY/MM/DD HH24:MI:SS') ATTRIBUTE1,
                 attribute1,                        --    supplierAcceptedDate
                 attribute2,                --    relatedVendorAllowanceNumber
                 attribute3,                             --    foreignCurrency
                 attribute4,
                 DECODE (attribute5,  'false', 'N',  'true', 'Y',  'N')
                     attribute5,                 --    combinedBpaApprovalFlag
                 attribute6,             --    commitedValueLinearDepreciation
                 attribute7,                            --    previousContract
                 attribute8,                                   --    sourcedBy
                 attribute9,                              --    parentContract
                 attribute10,                               --    termOfNotice
                 attribute11,                                 --    controller
                 attribute12,                    --    amountInForeignCurrency
                 attribute13,                         --    commitedValueFixed
                 attribute14,                          --    payTermPercentage
                 attribute15,                              --    payTermInDays
                 DECODE (pay_on_code,  'false', 'N',  'true', 'Y',  'N')
                     pay_on_code
            FROM xxah_po_headers_interface
           WHERE flow_status = 'NEW'
        ORDER BY interface_header_id;

    CURSOR c_po_lines (p_interface_header_id NUMBER)
    IS
          SELECT interface_line_id,
                 interface_header_id,
                 line_num,
                 line_type,
                 category,
                 item_description,
                 unit_of_measure,
                 committed_amount,
                 unit_price,
                 organization_id,
                 expiration_date
            FROM xxah_po_lines_interface
           WHERE (interface_header_id) = (p_interface_header_id)
        ORDER BY interface_header_id, interface_line_id;

    CURSOR c_org IS
        SELECT DISTINCT org_id
          FROM po_headers_interface
         WHERE process_code = 'PENDING';

    CURSOR c_blanket IS
        SELECT DISTINCT a.interface_header_id,
                        b.interface_line_id,
                        a.process_code,
                        a.po_header_id,
                        --b.interface_header_id,
                        b.po_line_id
          FROM po_headers_interface            a,
               po_lines_interface              b,
               xxah_po_blanket_info_interface  c
         WHERE     a.interface_header_id = b.interface_header_id
               AND b.interface_header_id = c.new_po_header_id
               AND b.interface_line_id = c.new_po_line_id
               AND a.process_code = 'ACCEPTED'
               AND c.flow_status = 'NEW';
BEGIN
    BEGIN
        l_legacy_ponum := 0;
        fnd_file.put_line (fnd_file.LOG,
                           'Starting the process .. execution curson H1'); ----------

        FOR h1 IN c_po_header
        LOOP
            l_verify_flag := 'NEW';
            l_error_message := NULL;
            fnd_file.put_line (
                fnd_file.LOG,
                   'After executin H1, running process for Interface_header_id '
                || h1.interface_header_id);                          ---------

            BEGIN
                SELECT vendor_id
                  INTO l_vendor_id
                  FROM po_vendors
                 WHERE UPPER (vendor_name) = UPPER (h1.vendor_name);
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_verify_flag := 'Error';
                    l_error_message :=
                           'Exception while deriving responsibility id - '
                        || SQLERRM;
                    xxah_debug_log (h1.interface_header_id,
                                    l_verify_flag,
                                    l_error_message);
            END;

            fnd_file.put_line (fnd_file.LOG, 'l_vendor_id ' || l_vendor_id); ---------

            BEGIN
                SELECT agent_id
                  INTO l_agent_id
                  FROM po_agents pa, per_all_people_f ppl
                 WHERE     1 = 1
                       AND pa.agent_id = ppl.person_id
                       AND UPPER (ppl.full_name) = UPPER (h1.agent_name)
                       AND ppl.effective_end_date >= SYSDATE;
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_verify_flag := 'Error';
                    l_error_message :=
                           l_error_message
                        || 'Agent is not Existing...'
                        || SQLERRM;
                    xxah_debug_log (h1.interface_header_id,
                                    l_verify_flag,
                                    l_error_message);
            END;

            fnd_file.put_line (fnd_file.LOG, 'l_agent_id ' || l_vendor_id); ---------

            BEGIN
                SELECT person_id
                  INTO l_person_id
                  FROM per_all_people_f ppl
                 WHERE     1 = 1
                       AND UPPER (ppl.full_name) = UPPER (h1.attribute11)
                       AND ppl.effective_end_date >= SYSDATE;
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_verify_flag := 'Error';
                    l_error_message :=
                           l_error_message
                        || 'Controller is not Existing...'
                        || SQLERRM;
                    xxah_debug_log (h1.interface_header_id,
                                    l_verify_flag,
                                    l_error_message);
            END;

            fnd_file.put_line (fnd_file.LOG, 'l_person_id ' || l_vendor_id); ---------

            BEGIN
                SELECT location_id
                  INTO l_ship_to
                  FROM hr_locations
                 WHERE UPPER (location_code) =
                       UPPER (TRIM (h1.ship_to_location));
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_verify_flag := 'Error';
                    l_error_message :=
                           l_error_message
                        || 'Ship To Location is not Existing...'
                        || SQLERRM;
                    xxah_debug_log (h1.interface_header_id,
                                    l_verify_flag,
                                    l_error_message);
            END;

            fnd_file.put_line (fnd_file.LOG, 'l_ship_to ' || l_ship_to); ---------

            BEGIN
                SELECT location_id
                  INTO l_bill_to
                  FROM hr_locations
                 WHERE UPPER (location_code) =
                       UPPER (TRIM (h1.bill_to_location));
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_verify_flag := 'Error';
                    l_error_message :=
                           l_error_message
                        || 'Bill To Location is not Existing...'
                        || SQLERRM;
                    xxah_debug_log (h1.interface_header_id,
                                    l_verify_flag,
                                    l_error_message);
            END;

            fnd_file.put_line (fnd_file.LOG, 'l_bill_to ' || l_bill_to); ---------

            BEGIN
                SELECT term_id
                  INTO l_terms_id
                  FROM ap_terms
                 WHERE name = (h1.payment_terms);
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_verify_flag := 'Error';
                    l_error_message :=
                           l_error_message
                        || 'Terms is not Existing...'
                        || SQLERRM;
                    xxah_debug_log (h1.interface_header_id,
                                    l_verify_flag,
                                    l_error_message);
            END;

            fnd_file.put_line (fnd_file.LOG, 'H1.status ' || h1.status); ---------

            IF h1.status = 'Approved'
            THEN
                l_batch_id := 100;
            ELSIF h1.status = 'Incomplete'
            THEN
                l_batch_id := 101;
            ELSE
                l_verify_flag := 'Error';
                l_error_message :=
                    l_error_message || 'Status is not valid...' || SQLERRM;
                xxah_debug_log (h1.interface_header_id,
                                l_verify_flag,
                                l_error_message);
            END IF;

            l_legacy_ponum := TRIM (h1.interface_header_id);
            fnd_file.put_line (fnd_file.LOG,
                               'l_legacy_ponum ' || l_legacy_ponum); ---------

            fnd_file.put_line (fnd_file.LOG,
                               'l_verify_flag ' || l_verify_flag);   ---------

            IF l_verify_flag <> 'Error'
            THEN
                l_int_po_header_id := po_headers_interface_s.NEXTVAL;
                fnd_file.put_line (
                    fnd_file.LOG,
                       'Processing for  l_int_po_header_id'
                    || l_int_po_header_id);

                INSERT INTO po.po_headers_interface (
                                interface_header_id,
                                batch_id,
                                process_code,
                                action,
                                org_id,
                                document_type_code,
                                currency_code,
                                agent_id,
                                vendor_id,
                                vendor_site_id,
                                ship_to_location_id,
                                bill_to_location_id,
                                --ATTRIBUTE1,
                                --APPROVAL_STATUS,
                                --vendor_contact_id,
                                pay_on_code,
                                acceptance_due_date,
                                freight_carrier,
                                fob,
                                creation_date,
                                terms_id,
                                freight_terms,
                                comments,
                                acceptance_required_flag,
                                amount_agreed,
                                amount_limit,
                                min_release_amount,
                                effective_date,
                                expiration_date,
                                attribute_category,
                                attribute1,  --    detail.supplierAcceptedDate
                                attribute2, --    detail.relatedVendorAllowanceNumber
                                attribute3,       --    detail.foreignCurrency
                                attribute4, --detaails.date contract send to supplier
                                attribute5, --    detail.combinedBpaApprovalFlag
                                attribute6, --    detail.commitedValueLinearDepreciation
                                attribute7,      --    detail.previousContract
                                attribute8,                    --    sourcedBy
                                attribute9,        --    detail.parentContract
                                attribute10,         --    detail.termOfNotice
                                attribute11,           --    detail.controller
                                attribute12, --    detail.amountInForeignCurrency
                                attribute13,   --    detail.commitedValueFixed
                                attribute14,    --    detail.payTermPercentage
                                attribute15         --    detail.payTermInDays
                                                                --,PAY_ON_CODE
                                )
                     VALUES (l_int_po_header_id,   ---    INTERFACE_HEADER_ID,
                             l_batch_id,
                             'PENDING',                    ---   PROCESS_CODE,
                             'ORIGINAL',                         ---   ACTION,
                             h1.org_id,
                             'BLANKET',              ---   DOCUMENT_TYPE_CODE,
                             h1.currency_code,            ---   CURRENCY_CODE,
                             l_agent_id,
                             l_vendor_id,
                             h1.vendor_site_id,
                             l_ship_to,
                             l_bill_to,
                             --l_attribute1,
                             --H1.APPROVAL_STATUS,
                             --H1.vendor_contact_id,
                             h1.pay_on_code,
                             h1.acceptance_due_date,
                             h1.freight_carrier,
                             h1.fob,
                             SYSDATE,
                             l_terms_id,
                             h1.freight_terms,
                             h1.comments,
                             h1.acceptance_required_flag,
                             h1.amount_agreed,
                             h1.amount_limit,
                             h1.min_release_amount,
                             h1.effective_date,
                             h1.expiration_date,
                             'BLANKET',
                             h1.attribute1,
                             h1.attribute2,                   --H1.ATTRIBUTE2,
                             h1.attribute3,
                             h1.attribute4,
                             h1.attribute5,                   --H1.ATTRIBUTE5,
                             h1.attribute6,
                             h1.attribute7,
                             h1.attribute8,
                             h1.attribute9,
                             h1.attribute10,
                             l_person_id, --13791, --13985,                              --H1.ATTRIBUTE11,
                             h1.attribute12,
                             h1.attribute13,
                             h1.attribute14,
                             h1.attribute15);

                FND_FILE.PUT_LINE (
                    FND_FILE.LOG,
                       'Inserted '
                    || SQL%ROWCOUNT
                    || ' rows into po_headers_interface table');

                COMMIT;


                fnd_file.put_line (fnd_file.LOG,
                                   '1.headers==>' || l_int_po_header_id); -----------------------

                FND_FILE.PUT_LINE (
                    FND_FILE.LOG,
                       'Begin  po_lines_interface for  l_legacy_ponum  '
                    || l_legacy_ponum);

                FOR l1 IN c_po_lines (l_legacy_ponum)
                LOOP
                    l_int_po_line_id := po_lines_interface_s.NEXTVAL;
                    FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                           'Getting Next squence  for l_int_po_line_id  '
                        || l_int_po_line_id);

                    INSERT INTO po.po_lines_interface (
                                    interface_line_id,
                                    interface_header_id,
                                    action,
                                    line_num,
                                    line_type,
                                    category,
                                    item_description,
                                    --UOM_CODE,
                                    unit_of_measure,
                                    committed_amount,
                                    unit_price,
                                    organization_id,
                                    ship_to_organization_id,
                                    ship_to_location_id,
                                    -- NEED_BY_DATE,
                                    --PROMISED_DATE,
                                    creation_date,
                                    line_loc_populated_flag,
                                    expiration_date)
                         VALUES (l_int_po_line_id,   ---    INTERFACE_LINE_ID,
                                 l_int_po_header_id, ---    INTERFACE_HEADER_ID,
                                 'ADD',                     ---        ACTION,
                                 l1.line_num,
                                 'Goods',
                                 l1.category,
                                 l1.item_description,
                                 -- l_uom_code,
                                 l1.unit_of_measure,
                                 l1.committed_amount,
                                 l1.unit_price,
                                 l1.organization_id,
                                 l1.organization_id, ---        SHIP_TO_ORGANIZATION_ID,
                                 l1.organization_id, ---    SHIP_TO_LOCATION_ID,
                                 --SYSDATE,                            ---    NEED_BY_DATE,
                                 --SYSDATE,                           ---    PROMISED_DATE,
                                 SYSDATE,                ---    CREATION_DATE,
                                 'Y',
                                 l1.expiration_date);

                    fnd_file.put_line (
                        fnd_file.LOG,
                           '1.Lines || Headers==> 
                        l_int_po_line_id : '
                        || l_int_po_line_id
                        || 'l_int_po_line_id :'
                        || l_int_po_header_id);                       --------

                    FND_FILE.PUT_LINE (
                        FND_FILE.LOG,
                           'Inserted '
                        || SQL%ROWCOUNT
                        || ' rows into po_lines_interface table for line_id '
                        || l_int_po_line_id);

                    COMMIT;

                    UPDATE xxah_po_blanket_info_interface
                       SET new_po_header_id = l_int_po_header_id,
                           new_po_line_id = l_int_po_line_id,
                           flow_status = 'NEW'
                     WHERE     po_line_id = l1.interface_line_id
                           AND po_header_id = l1.interface_header_id;

                    fnd_file.put_line (
                        fnd_file.LOG,
                        'Updating l_int_po_header_id ' || l_int_po_header_id); ----------
                    fnd_file.put_line (
                        fnd_file.LOG,
                        'Updating l_int_po_line_id' || l_int_po_line_id); ----------
                END LOOP;

                fnd_file.put_line (fnd_file.LOG,
                                   'Updating XXAH_PO_BLANKET_INFO_Interface'); ----------

                UPDATE xxah_po_headers_interface
                   SET flow_status = 'Success',
                       error_message = NULL,
                       po_header_id = l_int_po_header_id
                 WHERE interface_header_id = l_legacy_ponum;

                fnd_file.put_line (fnd_file.LOG,
                                   'Updating xxah_po_headers_interface'); ------------

                COMMIT;
            --xxah_debug_log (l_legacy_ponum, 'Success', NULL);
            ELSE
                l_verify_flag := 'Error';
                l_error_message := l_error_message;
                xxah_debug_log (l_legacy_ponum,
                                l_verify_flag,
                                l_error_message);
            END IF;
        -- COMMIT;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            l_verify_flag := 'Error';
            l_error_message := l_error_message || SQLERRM;
            xxah_debug_log (l_legacy_ponum, l_verify_flag, l_error_message);
    END;

    BEGIN
        FOR o1 IN c_org
        LOOP
            l_resp_id := 0;
            v_request_id := 0;

            BEGIN
                SELECT DECODE (o1.org_id,
                               150, '50980',
                               151, '51028',
                               152, '51020',
                               83, '20707',
                               430, '51317')
                  INTO l_resp_id
                  FROM DUAL;
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_verify_flag := 'Error';
                    fnd_file.put_line (
                        fnd_file.LOG,
                           'Error ==>'
                        || 'Org Id is not Existing... '
                        || SQLERRM);
            END;

            fnd_global.apps_initialize ('0', l_resp_id, '201');
            mo_global.init ('PO');
            mo_global.set_policy_context ('S', o1.org_id);
            fnd_request.set_org_id (o1.org_id);
            v_request_id :=
                fnd_request.submit_request ('PO',
                                            'POXPDOI',
                                            'Import Price Catalogs',
                                            SYSDATE,
                                            FALSE,
                                            NULL,
                                            'BLANKET',
                                            NULL,
                                            'N',
                                            'N',
                                            'INCOMPLETE',
                                            NULL,
                                            '100',                 -- batch id
                                            o1.org_id,    -- operating unit ID
                                            'N',
                                            NULL,
                                            NULL);

            fnd_file.put_line (
                fnd_file.LOG,
                'Import Price Catalog Request id: ' || v_request_id);
            COMMIT;
            IF v_request_id > 0 THEN
    LOOP
--
      --To make process execution to wait for 1st program to complete
      --
         l_req_return_status :=
            fnd_concurrent.wait_for_request (request_id      => v_request_id
                                            ,interval        => 5 --interval Number of seconds to wait between checks
                                            ,max_wait        => 60 --Maximum number of seconds to wait for the request completion
                                             -- out arguments
                                            ,phase           => lc_phase
                                            ,status          => lc_status
                                            ,dev_phase       => lc_dev_phase
                                            ,dev_status      => lc_dev_status
                                            ,message         => lc_message
                                            );						
      EXIT
    WHEN UPPER (lc_phase) = 'COMPLETED' OR UPPER (lc_status) IN ('CANCELLED', 'ERROR', 'TERMINATED');
    END LOOP;
    end if;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            fnd_file.put_line (
                fnd_file.LOG,
                   'Error ==>'
                || 'Error in Import price Catalog CP  '
                || SQLERRM);
    END;
    fnd_file.put_line (
                fnd_file.LOG,
                'current system time' || sysdate);
                select process_code into vs_process_code from po_headers_interface where Interface_header_id = l_int_po_header_id ; 
                      fnd_file.put_line (
                fnd_file.LOG,
                'Process_Code before starting insert into custom blanket PO information ' || vs_process_code);

    BEGIN
        new_po_line_id := 0;


        FOR b1 IN c_blanket
        LOOP
            FND_FILE.PUT_LINE (
                FND_FILE.LOG,
                ' total returned by B1 Cursor' || c_blanket%ROWCOUNT);
            new_po_line_id := b1.interface_line_id;
            fnd_file.put_line (fnd_file.LOG,
                               'New PO Line Id: ' || new_po_line_id);

            INSERT INTO xxah_po_blanket_info (year,
                                              po_header_id,
                                              po_line_id,
                                              description,
                                              savings_type,
                                              opco,
                                              estimated_savings,
                                              created_by,
                                              last_updated_by,
                                              last_update_login,
                                              creation_date,
                                              last_update_date)
                SELECT c.year,
                       a.po_header_id,
                       b.po_line_id,
                       c.description,
                       c.savings_type,
                       c.opco,
                       c.estimated_savings,
                       NULL,
                       NULL,
                       NULL,
                       SYSDATE,
                       NULL
                  FROM po_headers_interface            a,
                       po_lines_interface              b,
                       xxah_po_blanket_info_interface  c
                 WHERE     a.interface_header_id = b.interface_header_id
                       AND b.interface_header_id = c.new_po_header_id
                       AND b.interface_line_id = c.new_po_line_id
                       AND c.new_po_line_id = b1.interface_line_id
                UNION
                SELECT DISTINCT year,
                                a.po_header_id,
                                b.po_line_id,
                                '',
                                'SLA',
                                'AH',
                                80,
                                NULL,
                                NULL,
                                NULL,
                                SYSDATE,
                                NULL
                  FROM po_headers_interface            a,
                       po_lines_interface              b,
                       xxah_po_blanket_info_interface  c
                 WHERE     a.interface_header_id = b.interface_header_id
                       AND b.interface_header_id = c.new_po_header_id
                       AND b.interface_line_id = c.new_po_line_id
                       AND c.new_po_line_id = b1.interface_line_id;

            FND_FILE.PUT_LINE (FND_FILE.LOG,
                               'Inserted ' || SQL%ROWCOUNT || ' rows');
            COMMIT;

            UPDATE xxah_po_blanket_info_interface
               SET flow_status = 'SUCCESS'
             WHERE new_po_line_id = new_po_line_id;

            fnd_file.put_line (
                fnd_file.LOG,
                'Updating XXAH_PO_BLANKET_INFO_Interface' || new_po_line_id); ---------------

            COMMIT;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            --handle exception
            fnd_file.put_line (fnd_file.LOG,
                               'Error ==>' || l_error_message || SQLERRM);

            UPDATE xxah_po_blanket_info_interface
               SET flow_status = 'Error'
             WHERE new_po_line_id = new_po_line_id;
    --END LOOP;
    END;
EXCEPTION
    WHEN OTHERS
    THEN
        l_verify_flag := 'Error';
        fnd_file.put_line (fnd_file.LOG,
                           'Error ==>' || l_error_message || SQLERRM);
END xxah_po_api;

/
