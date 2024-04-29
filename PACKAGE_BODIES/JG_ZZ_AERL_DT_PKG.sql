--------------------------------------------------------
--  DDL for Package Body JG_ZZ_AERL_DT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_AERL_DT_PKG" AS
/*$Header: jgzzaerlb.pls 120.3.12010000.2 2009/04/14 08:02:55 pakumare ship $*/

  function cf_batch_name(trx_id in number, source in varchar2) return varchar2 as
  /*  This function will fetch batch name depending upon transaction source */
		cursor c_get_ar_batch_name
		is
		select rab.name
		from   ra_batches rab
		      ,ra_customer_trx ract
		where  rab.batch_id = ract.batch_id
		and    ract.customer_trx_id = trx_id;

		cursor c_get_ap_batch_name
		is
		select apb.batch_name
		from   ap_batches  apb
		      ,ap_invoices api
		where  apb.batch_id = api.batch_id
		and    api.invoice_id = trx_id;

  	cursor c_get_gl_batch_name
  	is
    select gjb.name
    from   gl_je_batches gjb
          ,gl_je_headers gljh
    where  gjb.je_batch_id = gljh.je_batch_id
    and    gljh.je_header_id = trx_id;

    lv_batch_name varchar2 (240);

  begin

  	if source = 'AR' then
			open  c_get_ar_batch_name;
			fetch c_get_ar_batch_name into lv_batch_name;
			close c_get_ar_batch_name;
  	elsif source = 'AP' then
  		open  c_get_ap_batch_name;
  		fetch c_get_ap_batch_name into lv_batch_name;
  		close c_get_ap_batch_name;
  	elsif source = 'GL' then
  		open  c_get_gl_batch_name;
  		fetch c_get_gl_batch_name into lv_batch_name;
  		close c_get_gl_batch_name;
		end if;
    return (lv_batch_name);

  end cf_batch_name;
  function get_financial_document_type(pn_trx_id in number,pn_trx_type_id in number, pv_source in varchar2 , pv_entity_code in varchar2) return varchar2 as
  /* This function will fetch Financial Document type to solve the bug 5550600*/
  lv_fin_doc_type varchar2(20);
  lv_sl_trx_type ce_statement_lines.trx_type%type;
  lv_cr_reversal_category ar_cash_receipts_all.reversal_category%type;
  begin
    fnd_file.put_line(fnd_file.log, '**Input Params:** ');
    fnd_file.put_line(fnd_file.log, '1. Trx_id: '||pn_trx_id);
    fnd_file.put_line(fnd_file.log, '2. Trx_type_id: '||pn_trx_type_id);
    fnd_file.put_line(fnd_file.log, '3. Source: '||pv_source);
    fnd_file.put_line(fnd_file.log, '4. Entity Code '||pv_entity_code);
    begin
        if pv_source = 'AP' then
            select invoice_type_lookup_code
                into lv_fin_doc_type
                    from ap_invoices_all
                        where invoice_id = pn_trx_id;
        elsif pv_source = 'AR' then
            if pv_entity_code = 'RECEIPTS' then
                select sl.trx_type  into lv_sl_trx_type
                    from ar_cash_receipt_history_all crh, ce_statement_reconcils_all sr,ce_statement_lines sl
                        where crh.cash_receipt_id = pn_trx_id
                            and	crh.cash_receipt_history_id = sr.reference_id
                            and	sr.statement_line_id = sl.statement_line_id
							and	crh.org_id = sr.org_id; -- Bug 8364296
                select cr.reversal_category into lv_cr_reversal_category
                    from ar_cash_receipts_all cr
                        where cr.cash_receipt_id = pn_trx_id
                        and   cr.type = 'MISC';
                if lv_sl_trx_type in ('CREDIT','MISC_CREDIT') then
                    if lv_cr_reversal_category = 'REV' then
                        lv_fin_doc_type := 'MISCREVR';
                    elsif lv_cr_reversal_category is null then
                        lv_fin_doc_type := 'MISCREC';
                    end if;
                elsif lv_sl_trx_type in ('DEBIT','MISC_DEBIT') then
                    if lv_cr_reversal_category = 'REV' then
                        lv_fin_doc_type := 'MISCREVP';
                    elsif lv_cr_reversal_category is null then
                        lv_fin_doc_type := 'MISCPAY';
                    end if;
                end if;
            elsif pv_entity_code = 'TRANSACTIONS' then
                select type
                    into lv_fin_doc_type
                        from ra_cust_trx_types --Modified the query for bug 6156524 Used ra_cust_trx_types table instead of ra_cust_trx_types_all table.
                            where cust_trx_type_id = pn_trx_type_id;
            end if;
        elsif pv_source = 'GL' then
            lv_fin_doc_type := 'N/A';
        end if;
    exception
      when others then
      -- Don't Error Out (Possible excp are Too_many_rows or No_data_Found)
      lv_fin_doc_type := null;
	fnd_file.put_line(fnd_file.log,'Logging the Error Message encountered: '||sqlerrm);
    end;
  fnd_file.put_line(fnd_file.log,'Document Type Returned: '||lv_fin_doc_type);
  return (lv_fin_doc_type);
  end get_financial_document_type;
END JG_ZZ_AERL_DT_PKG ;

/
