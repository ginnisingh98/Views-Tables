--------------------------------------------------------
--  DDL for Package Body FUN_NET_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_NET_EXTRACT_PKG" AS
/* $Header: funntdeb.pls 120.1 2006/01/20 07:56:47 vgadde noship $ */

    PROCEDURE extract_data
        (errbuf  OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY VARCHAR2,
        p_batch_id IN fun_net_batches_all.batch_id%TYPE)
    IS

        CURSOR c_get_batch_details IS
        SELECT  batch_number,
                batch_name,
                agreement_id,
                transaction_due_date,
                settlement_date,
                org_id,
                batch_currency,
                total_netted_amt
        FROM fun_net_batches
        WHERE batch_id = p_batch_id;

        CURSOR c_get_agreement_details(cp_agreement_id fun_net_agreements_all.agreement_id%TYPE) IS
        SELECT agreement_name,
                agreement_start_date,
                agreement_end_date
        FROM fun_net_agreements
        WHERE agreement_id = cp_agreement_id;

        CURSOR c_get_functional_currency(cp_org_id fun_net_batches_all.org_id%TYPE) IS
        SELECT l.currency_code
        FROM gl_ledgers l,hr_operating_units ou
        WHERE ou.organization_id = cp_org_id
        AND ou.set_of_books_id = l.ledger_id;

        CURSOR c_get_ap_invoices(cp_agreement_id fun_net_agreements_all.agreement_id%TYPE) IS
        SELECT pv.vendor_name supplier ,
                pv.segment1 supplier_number ,
                pvs.vendor_site_code supplier_site ,
                ai.invoice_num invoice_number ,
                ai.invoice_date invoice_date ,
                ai.invoice_currency_code invoice_currency,
                ai.invoice_amount invoice_amount ,
                ai.base_amount  ledger_amount,
                nai.netted_amt  netted_amount
        FROM fun_net_ap_invs nai,
            ap_invoices_all ai,
            po_vendors pv,
            po_vendor_sites_all pvs,
            fun_net_suppliers_all ns
        WHERE nai.batch_id = p_batch_id
        AND nai.invoice_id = ai.invoice_id
        AND ai.vendor_id = pv.vendor_id
        AND ai.vendor_site_id = pvs.vendor_site_id
        AND ns.agreement_id = cp_agreement_id
        AND ns.supplier_id = ai.vendor_id
        AND nvl(ns.supplier_site_id,ai.vendor_site_id) = ai.vendor_site_id
        AND ns.org_id = ai.org_id
        AND nai.org_id = ai.org_id
        AND ai.org_id = pvs.org_id
        AND nai.netted_amt <> 0
        ORDER BY ns.supplier_priority, nai.ap_txn_rank;

        CURSOR c_get_ar_transactions(cp_agreement_id fun_net_agreements_all.agreement_id%TYPE) IS
        SELECT hp.party_name customer ,
                hca.account_number customer_number ,
                hcs.location location ,
                rct.trx_number transaction_number ,
                rct.trx_date transaction_date ,
                rct.invoice_currency_code transaction_currency,
                rctl.amount transaction_amount,
                rctl.acctd_amount ledger_amount,
                nat.netted_amt netted_amount
        FROM fun_net_ar_txns nat,
            ra_customer_trx_all rct,
            hz_parties hp,
            hz_cust_accounts_all hca,
            hz_cust_site_uses_all hcs,
            fun_net_customers_all nc,
            ra_cust_trx_line_gl_dist_all rctl
        WHERE nat.batch_id = p_batch_id
        AND nat.customer_trx_id = rct.customer_trx_id
        AND rct.bill_to_customer_id = hca.cust_account_id
        AND hca.party_id = hp.party_id
        AND rct.bill_to_site_use_id = hcs.site_use_id
        AND nc.agreement_id = cp_agreement_id
        AND nc.cust_account_id = rct.bill_to_customer_id
        AND nvl(nc.cust_site_use_id,rct.bill_to_site_use_id) = rct.bill_to_site_use_id
        AND nc.org_id = rct.org_id
        AND nat.org_id = rct.org_id
        AND nat.org_id = hcs.org_id
        AND nat.netted_amt <> 0
        AND rct.customer_trx_id = rctl.customer_trx_id
        AND rctl.account_class = 'REC'
        AND nvl(latest_rec_flag,'N') = 'Y'
        AND rct.org_id = rctl.org_id
        ORDER BY nc.cust_priority, nat.ar_txn_rank;

        l_batch_details     c_get_batch_details%ROWTYPE;
        l_agreement_details c_get_agreement_details%ROWTYPE;
        l_customer          hz_parties.party_name%TYPE;
        l_customer_number   hz_cust_accounts_all.account_number%TYPE;
        l_location          hz_cust_site_uses_all.location%TYPE;
        l_supplier          po_vendors.vendor_name%TYPE;
        l_supplier_number   po_vendors.segment1%TYPE;
        l_supplier_site          po_vendor_sites_all.vendor_site_code%TYPE;
        l_invoice_count     NUMBER;
        l_transaction_count NUMBER;
        l_output_string     VARCHAR2(2000);
        l_func_currency     gl_ledgers.currency_code%TYPE;
        l_ledger_id         gl_ledgers.ledger_id%TYPE;
        l_ledger_name       gl_ledgers.name%TYPE;

    BEGIN

        OPEN c_get_batch_details;
        FETCH c_get_batch_details INTO l_batch_details;
        CLOSE c_get_batch_details;

        OPEN c_get_agreement_details(l_batch_details.agreement_id);
        FETCH c_get_agreement_details INTO l_agreement_details;
        CLOSE c_get_agreement_details;

        MO_Utils.Get_Ledger_Info(
                    l_batch_details.org_id,
                    l_ledger_id,
                    l_ledger_name);

        SELECT currency_code
        INTO l_func_currency
        FROM gl_ledgers
        WHERE ledger_id = l_ledger_id;

        fnd_file.put_line(fnd_file.output,'Data Extract File');

        l_output_string := 'Netting Agreement:,,'||l_agreement_details.agreement_name;
        fnd_file.put_line(fnd_file.output,l_output_string);

        l_output_string := 'Start Date:,,'||to_char(l_agreement_details.agreement_start_date,'DD-MON-YY');
        fnd_file.put_line(fnd_file.output,l_output_string);

        l_output_string := 'End Date:,,';

        IF l_agreement_details.agreement_end_date IS NOT NULL THEN
            l_output_string := l_output_string||to_char(l_agreement_details.agreement_end_date,'DD-MON-YY');
        END IF;

        fnd_file.put_line(fnd_file.output,l_output_string);

        l_output_string := 'Transaction Due Date:,,'||to_char(l_batch_details.transaction_due_date,'DD-MON-YY');
        fnd_file.put_line(fnd_file.output,l_output_string);

        l_output_string := 'Settlement Date:,,'||to_char(l_batch_details.settlement_date,'DD-MON-YY');
        fnd_file.put_line(fnd_file.output,l_output_string);

        l_output_string := 'Deploying Company Currency:,,'|| l_batch_details.batch_currency;
        fnd_file.put_line(fnd_file.output,l_output_string);

        l_output_string := 'Supplier Netted Amount:,,'||l_batch_details.total_netted_amt;
        fnd_file.put_line(fnd_file.output,l_output_string);

        l_output_string := 'Customer Netted Amount:,,'||l_batch_details.total_netted_amt;
        fnd_file.put_line(fnd_file.output,l_output_string);

        l_output_string := ' ';
        fnd_file.put_line(fnd_file.output,l_output_string);
        fnd_file.put_line(fnd_file.output,l_output_string);

        l_output_string := 'Transactions Netted per Batch Number:,'|| l_batch_details.batch_number||',';
        l_output_string := l_output_string || 'Batch Name:,'|| l_batch_details.batch_name;
        fnd_file.put_line(fnd_file.output,l_output_string);

        l_invoice_count := 0;
        FOR l_invoice IN c_get_ap_invoices(l_batch_details.agreement_id) LOOP
            l_invoice_count := l_invoice_count + 1;

            IF l_invoice_count = 1 THEN
                l_supplier := l_invoice.supplier;
                l_supplier_number := l_invoice.supplier_number;
                l_supplier_site := l_invoice.supplier_site;

                l_output_string := ' ';
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Supplier:,'|| l_supplier;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Supplier Number:,'|| l_supplier_number;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Site:,'|| l_supplier_site;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := ' ';
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Invoice Number,Invoice Date,Invoice Currency,Invoice Amount,Ledger Currency,Ledger Amount, Netted Amount ('||l_batch_details.batch_currency||')';
                fnd_file.put_line(fnd_file.output,l_output_string);

            END IF;

            IF l_supplier <> l_invoice.supplier OR
                l_supplier_number <> l_invoice.supplier_number OR
                l_supplier_site <> l_invoice.supplier_site THEN

                l_supplier := l_invoice.supplier;
                l_supplier_number := l_invoice.supplier_number;
                l_supplier_site := l_invoice.supplier_site;

                l_output_string := ' ';
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Supplier:,'|| l_supplier;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Supplier Number:,'|| l_supplier_number;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Site:,'|| l_supplier_site;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := ' ';
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Invoice Number,Invoice Date,Invoice Currency,Invoice Amount,Ledger Currency,Ledger Amount, Netted Amount ('||l_batch_details.batch_currency||')';
                fnd_file.put_line(fnd_file.output,l_output_string);

            END IF;

            l_output_string := l_invoice.invoice_number||',';
            l_output_string := l_output_string || to_char(l_invoice.invoice_date,'DD-MON-YY') || ',';
            l_output_string := l_output_string || l_invoice.invoice_currency || ',';
            l_output_string := l_output_string || to_char(l_invoice.invoice_amount) || ',';
            l_output_string := l_output_string || l_func_currency || ',';
            IF l_invoice.ledger_amount IS NULL THEN
                l_invoice.ledger_amount := l_invoice.invoice_amount;
            END IF;
            l_output_string := l_output_string || to_char(l_invoice.ledger_amount) || ',';
            l_output_string := l_output_string || to_char(l_invoice.netted_amount);
            fnd_file.put_line(fnd_file.output,l_output_string);
        END LOOP;


        l_transaction_count := 0;
        FOR l_transaction IN c_get_ar_transactions(l_batch_details.agreement_id) LOOP
            l_transaction_count := l_transaction_count + 1;

            IF l_transaction_count = 1 THEN
                l_customer := l_transaction.customer;
                l_customer_number := l_transaction.customer_number;
                l_location := l_transaction.location;

                l_output_string := ' ';
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Customer:,'|| l_customer;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Customer Account Number:,'|| l_customer_number;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Location:,'|| l_location;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := ' ';
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Transaction Number,Transaction Date,Transaction Currency,Transaction Amount,Ledger Currency,Ledger Amount,Netted Amount ('||l_batch_details.batch_currency||')';
                fnd_file.put_line(fnd_file.output,l_output_string);

            END IF;

            IF l_customer <> l_transaction.customer OR
                l_customer_number <> l_transaction.customer_number OR
                l_location <> l_transaction.location THEN

                l_customer := l_transaction.customer;
                l_customer_number := l_transaction.customer_number;
                l_location := l_transaction.location;

                l_output_string := ' ';
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Customer:,'|| l_customer;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Customer Number:,'|| l_customer_number;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Location:,'|| l_location;
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := ' ';
                fnd_file.put_line(fnd_file.output,l_output_string);

                l_output_string := 'Transaction Number,Transaction Date,Transaction Currency,Transaction Amount,Ledger Currency,Ledger Amount,Netted Amount ('||l_batch_details.batch_currency||')';
                fnd_file.put_line(fnd_file.output,l_output_string);

            END IF;

            l_output_string := l_transaction.transaction_number||',';
            l_output_string := l_output_string || to_char(l_transaction.transaction_date,'DD-MON-YY') || ',';
            l_output_string := l_output_string || l_transaction.transaction_currency || ',';
            l_output_string := l_output_string || to_char(l_transaction.transaction_amount) || ',';
            l_output_string := l_output_string || l_func_currency || ',';
            l_output_string := l_output_string || to_char(l_transaction.ledger_amount) || ',';
            l_output_string := l_output_string || to_char(l_transaction.netted_amount);
            fnd_file.put_line(fnd_file.output,l_output_string);
        END LOOP;

        retcode := 0;
    EXCEPTION
        WHEN OTHERS THEN
            retcode := 2 ;
            errbuf := sqlerrm;
    END extract_data;

END FUN_NET_EXTRACT_PKG;

/
