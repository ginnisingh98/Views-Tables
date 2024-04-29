--------------------------------------------------------
--  DDL for Package Body JAI_CMN_ST_FORMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_ST_FORMS_PKG" AS
/* $Header: jai_cmn_st_forms.plb 120.6.12010000.4 2008/11/19 10:00:33 nprashar ship $ */

/* --------------------------------------------------------------------------------------
Filename: jai_cmn_st_forms.plb

Change History:
Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005              Version 116.2 jai_cmn_st_forms -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                         as required for CASE COMPLAINCE.

13-Jun-2005  4428980     File Version: 116.3
                         Ramananda for bug#4428980. Removal of SQL LITERALs is done

24-Jun-2005  4454818     Ramananda for bug#4454818  File Version: 116.4
                         ST Forms Impact: Uptake of ap_invoice_lines_all

10-May-2006  4949400     Sanjikum for Bug#4929400, File Version 120.2
                         1) Modified the cursor - c_get_not_validated_count
                         2) Changed the definition of variable - v_not_validated_count from number to VARCHAR2(1)
02-Jul-2007  6118321     brathod,File Version 120.5
                         FP: 11.5.9 - 12.0:FORWARD PORTING FROM 115 BUG 5763527
--------------------------------------------------------------------------------------*/

PROCEDURE generate_ap_forms
(
p_err_buf OUT NOCOPY varchar2,
P_ret_code OUT NOCOPY varchar2,
p_org_id                                IN              number,
p_vendor_id                             IN              number,
p_vendor_site_id                        IN              number,
p_invoice_from_date                     IN              date,
p_invoice_to_date                       IN              date,
P_reprocess                                     IN      varchar2
)
is

        cursor c_get_distrib_tax_details (p_invoice_id number, p_line_number number) IS /* p_distribution_no --uptake of ap_invoice_lines_all */
        select tax_id, line_location_id, po_header_id, po_line_id, tax_amount,
         parent_invoice_line_number --parent_invoice_distribution_id /* uptake of ap_invoice_lines_all */
         ,recoverable_flag -- 5763527
        from   JAI_AP_MATCH_INV_TAXES
        where  invoice_id = p_invoice_id
        and    invoice_line_number =  p_line_number;  /* uptake of ap_invoice_lines_all */
        /* and    distribution_line_number =  p_distribution_no;*/

        cursor c_get_tax_details (p_tax_id number) is
        select tax_type, tax_rate, stform_type
              , mod_cr_percentage             -- 5763527
        from   JAI_CMN_TAXES_ALL
        where  tax_id = p_tax_id;

        v_mod_cr_pctg         JAI_CMN_TAXES_ALL.mod_cr_percentage%type ;-- 5763527
        lv_recoverable_flag   JAI_AP_MATCH_INV_TAXES.recoverable_flag%type ;-- 5763527


        cursor c_get_ven_info(p_invoice_id number) is
        select vendor_id, vendor_site_id, org_id
        from   ap_invoices_all
        where  invoice_id = p_invoice_id;

        cursor c_get_st_hdr_id(p_stform_type varchar2, p_vendor_id  number, p_vendor_site_id number, p_org_id number) is
        select st_hdr_id
        from   JAI_CMN_STFORM_HDRS_ALL
        where  party_type_flag = 'V'
        and    party_id = p_vendor_id
        and    party_site_id = p_vendor_site_id
        and    form_type = p_stform_type
        and    org_id = p_org_id;

        cursor c_get_po_num(p_po_header_id number) is
        select segment1, type_lookup_code
        from   po_headers_all
        where  po_header_id = p_po_header_id;

        cursor c_get_focus_id(p_line_location_id  number, p_line_id number) is
        select line_focus_id
        from   JAI_PO_LINE_LOCATIONS
        where  line_location_id = p_line_location_id
        and    po_line_id       = p_line_id;

        cursor c_get_tax_ln_no_receipt (p_rcv_transaction_id number, p_tax_id number) is
        select  tax_line_no
        from    JAI_RCV_LINE_TAXES
        where   (shipment_header_id, shipment_line_id)
                        in
                        (select shipment_header_id, shipment_line_id
                         from   rcv_transactions
                         where  transaction_id = p_rcv_transaction_id
                         )
        and     tax_id = p_tax_id;

        cursor get_tax_ln_no_po(p_po_line_location_id number, p_tax_id number) is
        select tax_line_no
        from   JAI_PO_TAXES
        where  tax_id = p_tax_id
        and    line_location_id = p_po_line_location_id;

        cursor c_get_match_org_loc(p_po_line_location_id number) is
        select  match_option, ship_to_organization_id, ship_to_location_id
        from    po_line_locations_all
        where   line_location_id = p_po_line_location_id;

        /* Modified by Ramananda for bug# due to uptake of ap_invoice_lines_all  */
        cursor c_get_rcv_transaction_id(p_invoice_id number, p_po_distribution_id number, cp_lt_lookup_code ap_invoice_lines_all.line_type_lookup_code%type ) is
        select rcv_transaction_id
        from   ap_invoice_lines_all --ap_invoice_distributions_all  /* uptake of ap_invoice_lines_all */
        where  invoice_id = p_invoice_id
        and    line_type_lookup_code = cp_lt_lookup_code --'ITEM'
        and    po_distribution_id = p_po_distribution_id;

        cursor c_get_not_validated_count (p_invoice_id number) is
        /*select count(1)
        from   ap_invoice_distributions_all
        where  invoice_id = p_invoice_id
        and    nvl(match_status_flag, 'N') <> 'A';*/
        --commented the above and added the below by Sanjikum for Bug#4929400
        SELECT  'Y'
        FROM    dual
        WHERE   exists (select  '1'
                        from    ap_invoice_distributions_all
                        where   invoice_id = p_invoice_id
                        and     nvl(match_status_flag, 'N') <> 'A');



        v_tax_id              JAI_CMN_TAXES_ALL.tax_id%type;
        v_tax_type            JAI_CMN_TAXES_ALL.tax_type%type;
        v_tax_rate            JAI_CMN_TAXES_ALL.tax_rate%type;
        v_stform_type         JAI_CMN_TAXES_ALL.stform_type%type;

        v_vendor_id           ap_invoices_all.vendor_id%type;
        v_vendor_site_id      ap_invoices_all.vendor_site_id%type;
        v_org_id              ap_invoices_all.org_id%type;

/*
   Variable declaration changed by aiyer for the bug #3249375.
   Changed the variable declaration from reference to ja_in_po_st_forms_hdr.form_issue_id to JAI_CMN_STFORM_HDRS_ALL.st_hdr_id.
   This was required as the table ja_in_po_st_forms_hdr has been obsoleted.
*/
        v_st_hdr_id                JAI_CMN_STFORM_HDRS_ALL.st_hdr_id%type;
        v_po_line_location_id      JAI_AP_MATCH_INV_TAXES.line_location_id%type;
        v_po_header_id             JAI_AP_MATCH_INV_TAXES.po_header_id%type;
        v_po_num                   po_headers_all.segment1%type;
        v_po_line_id               JAI_AP_MATCH_INV_TAXES.po_line_id%type;
        v_tax_line_no              JAI_PO_TAXES.tax_line_no%type;
        v_match_option             po_line_locations_all.match_option%type;
        v_ship_to_organization_id  po_line_locations_all.ship_to_organization_id%type;
        v_ship_to_location_id      po_line_locations_all.ship_to_location_id%type;
        v_type_lookup_code         po_headers_all.type_lookup_code%type;
        v_tax_amount               JAI_AP_MATCH_INV_TAXES.tax_amount%type;
        v_doc_type                 varchar2(10);
        v_tax_target_amount        number;
        v_st_dtl_id                number;
        v_rcv_transaction_id       ap_invoice_distributions_all.rcv_transaction_id%type;
        v_parent_distribution_id   ap_invoice_distributions_all.invoice_distribution_id%type;
        v_debug                    char(1); -- := 'Y'; --Ramananda for File.Sql.35
        v_uid                      number;

        v_invoice_error_flag       char(1);
        v_error_flag               char(1);

        v_processed_inv_cnt        number;
        v_error_inv_cnt            number;
        v_st_lines_for_inv         number;
        v_error_message            varchar2(300);

        --v_not_validated_count      number;
        --commented the above and added the below by Sanjikum
        v_not_validated_count      VARCHAR2(1);

        v_invoice_process_flag     char(1);
        v_not_processed_inv_cnt    number;

        lv_lt_lookup_code ap_invoice_distributions_all.line_type_lookup_code%type ;
        v_parent_invoice_line_number JAI_AP_MATCH_INV_TAXES.parent_invoice_line_number%type ;


        function getSTformsTaxBaseAmount     /* uptake of ap_invoice_lines_all*/
        (
        p_invoice_id                    number,
        p_line_number                   number,  --p_invoice_distribution_id     number,
        p_tax_id                        number,
        p_tax_amount                    number, -- bug#3094025
        p_tax_rate                      number  -- bug#3094025
        )
        return number is

                v_po_distribution_id    number;
                v_po_line_location_id   number;
                v_po_header_id                  number;
                v_po_line_id                    number;
                v_rcv_transaction_id    number;
                v_precedence_1                  number;
                v_precedence_2                  number;
                v_precedence_3                  number;
                v_precedence_4                  number;
                v_precedence_5                  number;
                v_precedence_0                  number;
                v_precedence_non_0      number;

                v_tax_base_amt                  number;

                v_set_of_books_id       ap_invoices_all.set_of_books_id%type;
                v_invoice_currency_code ap_invoices_all.invoice_currency_code%type;
                v_exchange_date         ap_invoices_all.exchange_date%type;
                v_exchange_rate_type    ap_invoices_all.exchange_rate_type%type;
                v_exchange_rate         ap_invoices_all.exchange_rate%type;

                v_invoice_distribution_id ap_invoice_distributions_all.invoice_distribution_id%type;

                v_line_number ap_invoice_lines_all.line_number%type ;

                cursor c_get_invoice_currency_dtl is
                select set_of_books_id, invoice_currency_code,exchange_date, exchange_rate_type, exchange_rate
                from   ap_invoices_all
                where  invoice_id = p_invoice_id;

                /* uptake of ap_invoice_lines_all */
                cursor c_get_inv_dist_details is
                select line_number, po_distribution_id, rcv_transaction_id, amount  /* invoice_distribution_id*/
                from   ap_invoice_lines_all  --ap_invoice_distributions_all
                where  invoice_id = p_invoice_id
                and    line_number = p_line_number ;
                /* and    invoice_distribution_id = p_invoice_distribution_id ; */

                cursor c_get_po_details (p_po_distribution_id number) is
                select po_header_id, po_line_id, line_location_id
                from   po_distributions_all
                where  po_distribution_id = p_po_distribution_id;

                -- precedences are always available in po taxes only (receipt taxes does not have it)
                cursor c_get_tax_precedence (p_po_line_location_id number) is
                select  precedence_1, precedence_2 , precedence_3, precedence_4, precedence_5
                from    JAI_PO_TAXES
                where   tax_id = p_tax_id
                and     line_location_id = p_po_line_location_id;

                /* Modified by Ramananda for bug# due to uptake of ap_invoice_lines_all */
               cursor c_get_non_zero_precedence_amt
                (
                p_precedence_1                  number,
                p_precedence_2                  number,
                p_precedence_3                  number,
                p_precedence_4                  number,
                p_precedence_5                  number,
                p_po_header_id                  number,
                p_po_line_id                    number,
                p_line_location_id              number,
                p_po_distribution_id            number,
                p_parent_line_number            number
                )
                is
                select sum(amount)
                from   ap_invoice_lines_all
                where  invoice_id = p_invoice_id
                and    line_number in
                           ( select  invoice_line_number
                                from   JAI_AP_MATCH_INV_TAXES
                                where  invoice_id = p_invoice_id
                                and  po_header_id = p_po_header_id
                                and  po_line_id = p_po_line_id
                                and  line_location_id = p_line_location_id
                                and  po_distribution_id = p_po_distribution_id
                                and  parent_invoice_line_number = p_parent_line_number
                                and  tax_id
                                           in
                                           (
                                                select tax_id
                                                from   JAI_PO_TAXES
                                                where  line_location_id = p_line_location_id
                                                and    tax_line_no in
                                                           (p_precedence_1, p_precedence_2, p_precedence_3, p_precedence_4, p_precedence_5)
                                                )
                                );

                /*Cursor added by nprashar for bug  #6043559, FP changes of bug # 5999535*/
                CURSOR c_receipt_base_amt	(  c_invoice_id NUMBER,
	                                                         c_invoice_distribution_id	NUMBER,
                                                                                    c_po_header_id	NUMBER,
			       c_po_line_id	NUMBER,
                                                                                      c_line_location_id                NUMBER,
                                                                                      c_po_distribution_id             NUMBER)
				IS
					select 	SUM(base_amount)
						from 		jai_ap_match_inv_taxes
					                          where    	                          invoice_id = c_invoice_id
						and 		parent_invoice_distribution_id = c_invoice_distribution_id
						and 	 	po_header_id = c_po_header_id
						and 		po_line_id = c_po_line_id
						and 		line_location_id = c_line_location_id
						and 		po_distribution_id = c_po_distribution_id;

                begin
                Fnd_File.put_line(Fnd_File.LOG, '  Start of getSTformsTaxBaseAmount');

                open c_get_inv_dist_details;
                fetch c_get_inv_dist_details into v_line_number, v_po_distribution_id, v_rcv_transaction_id, v_precedence_0;
                --fetch c_get_inv_dist_details into v_invoice_distribution_id, v_po_distribution_id, v_rcv_transaction_id, v_precedence_0;
                close c_get_inv_dist_details;

                Fnd_File.put_line(Fnd_File.LOG, '  0 precedence amount : ' || v_precedence_0 );


                open c_get_po_details(v_po_distribution_id);
                fetch c_get_po_details into v_po_header_id, v_po_line_id, v_po_line_location_id;
                close c_get_po_details;

                open c_get_tax_precedence(v_po_line_location_id);
                fetch c_get_tax_precedence into
                v_precedence_1, v_precedence_2, v_precedence_3, v_precedence_4, v_precedence_5;
                close c_get_tax_precedence;

                /* uptake of ap_invoice_lines_all  */
                open c_get_non_zero_precedence_amt
                (v_precedence_1, v_precedence_2, v_precedence_3, v_precedence_4, v_precedence_5,
                 v_po_header_id, v_po_line_id, v_po_line_location_id, v_po_distribution_id,
                  v_line_number); --v_invoice_distribution_id);

                fetch c_get_non_zero_precedence_amt into v_precedence_non_0;
                close c_get_non_zero_precedence_amt;

                -- following if was added by Aparajita while fixing bug#3094025.
                -- It was observed that the 0 precedence amount was getting added always to tax base even if precedence 0 does
                -- not exist.

                if v_precedence_1 = 0 or v_precedence_2 = 0 or  v_precedence_3 = 0  or v_precedence_4 = 0 or v_precedence_5 = 0 then
                        v_tax_base_amt := nvl(v_precedence_0, 0);
                end if;

                v_tax_base_amt := v_tax_base_amt  + nvl(v_precedence_non_0, 0);

                open c_get_invoice_currency_dtl;
                fetch c_get_invoice_currency_dtl into
                          v_set_of_books_id, v_invoice_currency_code, v_exchange_date, v_exchange_rate_type, v_exchange_rate;
                close c_get_invoice_currency_dtl;

                if v_invoice_currency_code <> 'INR' then
                        v_exchange_rate := jai_cmn_utils_pkg.currency_conversion(v_set_of_books_id, v_invoice_currency_code,
                                                                                        v_exchange_date, v_exchange_rate_type, v_exchange_rate);

                        v_tax_base_amt := v_tax_base_amt * v_exchange_rate;

                end if;

                v_tax_base_amt  := round(v_tax_base_amt, 2);

                --start  addded by Aparajita for bug#3094025
                if  nvl(v_tax_base_amt, 0) = 0 then
                        -- the tax may no be there at po, have to calculate back if it is from receipt.
                        -- as precedence is not available
                        /*Commenting Starts Fnd_File.put_line(Fnd_File.LOG, '  Calculated tax base backward from tax amount and rate as PO tax details not found ');
                        v_tax_base_amt := ((p_tax_amount * 100) / p_tax_rate);  Commenting Ends*/
                         /*Code added by nprashar for bug  #6043559, FP changes of bug # 5999535*/
                          OPEN c_receipt_base_amt   (c_invoice_id => p_invoice_id,
			       c_invoice_distribution_id => p_line_number,
			       c_po_header_id=> v_po_header_id,
			       c_po_line_id => v_po_line_id,
			       c_line_location_id	=> v_po_line_location_id,
			       c_po_distribution_id	 => v_po_distribution_id);
		FETCH c_receipt_base_amt INTO v_tax_base_amt;
		CLOSE c_receipt_base_amt;
                        Fnd_File.put_line(Fnd_File.LOG, '  Calculated tax base from receipt taxes '); /*Ends here*/
                        end if;
                --End  addded by Aparajita for bug#3094025


                Fnd_File.put_line(Fnd_File.LOG, '  End of getSTformsTaxBaseAmount : ' || v_tax_base_amt);
                return v_tax_base_amt;

                exception
                when others then
                        Fnd_File.put_line(Fnd_File.LOG, '   Error in getting tax base amount for ST forrms :' || sqlerrm);
                        Fnd_File.put_line(Fnd_File.LOG, '   Populated st forms tax target amount as 0');
                        return 0;
        end getSTformsTaxBaseAmount;
        -- end added by Aparajita for bug#3038566;



begin -- main

/*------------------------------------------------------------------------------------------
FILENAME: jai_cmn_st_forms_pkg.generate_ap_forms_p.sql
CHANGE HISTORY:

S.No      Date          Author and Details
1         17-oct-03     Aparajita for bug#3193849. Version#616.1

                        Created this procedure.

                        This procedure processes the invoices in the given period and
                        populates the ST forms records wherever applicable.

                        It checks the invoice distribution lines of type 'MISCLEEANEOUS'
                        for tax lines by localization for sales tax of having forms attached.

                        All the invoices as per the criteria provided are considered. If an invoice is
                        cancelled, this program does not process the invoice. Program checks for processed
                        line if any for such invoice, if found and if no form has been issued for such a line,
                        the line is deleted. Similar processing is also done for an invoice that is not validated.

                        If the option of re-process is given as Yes, every invoice is checked for already
                        processed line that is not issued and is deleted and processed again.


                        The distribution lines which are reversed are not considered. Only the lines processed
                        by localization are considered for this processing.


2.         11-Nov-2003  Aiyer  - Bug #3249375 File Version 617.1
                         Changed the variable declaration from reference to ja_in_po_st_forms_hdr.form_issue_id to JAI_CMN_STFORM_HDRS_ALL.st_hdr_id.
                         This was required as the table ja_in_po_st_forms_hdr has been obsoleted.
                         As this table does not exist in the database any more, post application of IN60105D1 patchset hence deleting
             the reference .

                       Dependency Due to This Bug:-
                        Can be applied only post application of IN60105D1.

3.	29-JULY-2008	JMEENA for bug#7214273
					Added NVL with variable v_not_validated_count and reset to N before processing.

4.         19-Nov-2008      Changes by nprashar for bug # 6043559, FP changes of bug 5999535.
                                    Changes done in procedure - process_ar_st_forms.process_ap_st_forms
                                    Here added a new cursor - c_receipt_base_amt and added the code to open/fetch/close the same

Future Dependencies For the release Of this Object:-
==================================================
(Please add a row in the section below only if your bug introduces a dependency due to
 spec change/A new call to a object/A datamodel change)

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files          Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
jai_cmn_st_forms_pkg.generate_ap_forms
----------------------------------------------------------------------------------------------------------------------------------------------------

617.1                  3249375       IN60105D1                                    Aiyer     11/Nov/2003  Can be applied only after IN60105D1 patchset
                                                                                                        has been applied.


------------------------------------------------------------------------------------------------------- */
        v_debug := jai_constants.yes ; --Ramananda for File.Sql.35

    if v_debug = 'Y' then
                Fnd_File.put_line(Fnd_File.LOG, '**** ========================================== ****');
                Fnd_File.put_line(Fnd_File.LOG, '**** Start procedure - jai_cmn_st_forms_pkg.generate_ap_forms ****');
        end if;

        v_uid := fnd_global.USER_ID;

        v_error_flag := 'N';

        v_processed_inv_cnt := 0;
        v_error_inv_cnt := 0;
        v_not_processed_inv_cnt := 0;

        for c_invoices in
        (
         select invoice_id, invoice_num, cancelled_date
         from   ap_invoices_all a
         where  invoice_date between trunc(p_invoice_from_date) and trunc(p_invoice_to_date)
         and    ( (p_org_id is null) or (p_org_id is not null and org_id = p_org_id) )
         and    ( (p_vendor_id is null) or (p_vendor_id is not null and vendor_id = p_vendor_id) )
         and    ( (p_vendor_site_id is null)
                  or
                  (p_vendor_site_id is not null and vendor_site_id = p_vendor_site_id)
                 )
         and    exists (select  '1'
                        from    JAI_AP_MATCH_INV_TAXES
                        where   invoice_id = a.invoice_id
                        and     tax_id in (select tax_id  from JAI_CMN_TAXES_ALL where stform_type is not null)
                        ) -- to ensure that loc taxes exists for the invoice and are of st forms type.

         order by invoice_date asc
        )
        loop

                begin

                        if v_debug = 'Y' then
                                Fnd_File.put_line(Fnd_File.LOG, ' ** Processing invoice (id) :  '
                                                                                                || c_invoices.invoice_num || '('
                                                                                                || c_invoices.invoice_id  || '}' );
                        end if;

                        v_invoice_process_flag := 'Y'; -- by default consider that invoice should be processed.

                        if c_invoices.cancelled_date is not null then

                                -- invoice is cancelled, delete any not issued ST forms record for the invoice.

                                v_invoice_process_flag := 'N'; -- this invoice should not be processed.
                                v_not_processed_inv_cnt := v_not_processed_inv_cnt + 1;

                                if v_debug = 'Y' then
                                        Fnd_File.put_line(Fnd_File.LOG, '    Invoice is Cancelled - not processing' );
                                end if;


                                delete JAI_CMN_ST_FORM_DTLS a
                                where  invoice_id = c_invoices.invoice_id
                                and    issue_receipt_flag = 'I'
                                and    not exists (select '1'
                                                                   from   JAI_CMN_ST_MATCH_DTLS
                                                                   where  st_hdr_id = a.st_hdr_id
                                                                   and    st_dtl_id = a.st_dtl_id
                                                                   );

                                if v_debug = 'Y' then
                                        Fnd_File.put_line(Fnd_File.LOG,
                                                          '    No of unmatched records deleetd from st forms for this invoice :'
                                                                          ||  to_char(sql%rowcount) );
                                end if;

                                goto continue_with_next_inv;

                        end if ; -- invoice is cancelled.



                        -- control comes here only if invoice is not processed.
                        -- check if invoice is not validated.

                       --v_not_validated_count := 0; --commented by Sanjikum for Bug#4929400
			v_not_validated_count:= 'N'; --Added for bug#7214273
                        open c_get_not_validated_count(c_invoices.invoice_id );
                        fetch c_get_not_validated_count into v_not_validated_count;
                        close c_get_not_validated_count;

                        --if v_not_validated_count > 0 then
                        --commented the above and added the below by Sanjikum for Bug#4929400
                        if NVL(v_not_validated_count,'N') = 'Y' then   --Added NVL for bug#7214273

                                -- invoice is not validated

                                v_invoice_process_flag := 'N'; -- this invoice should not be processed.
                                v_not_processed_inv_cnt := v_not_processed_inv_cnt + 1;

                                if v_debug = 'Y' then
                                        Fnd_File.put_line(Fnd_File.LOG, '    Invoice is not validated - not processing' );
                                end if;


                                delete JAI_CMN_ST_FORM_DTLS a
                                where  invoice_id = c_invoices.invoice_id
                                and    issue_receipt_flag = 'I'
                                and    not exists (select '1'
                                                                   from   JAI_CMN_ST_MATCH_DTLS
                                                                   where  st_hdr_id = a.st_hdr_id
                                                                   and    st_dtl_id = a.st_dtl_id
                                                                   );

                                if v_debug = 'Y' then
                                        Fnd_File.put_line(Fnd_File.LOG,
                                                          '    No of unmatched records deleted from st forms for this invoice :'
                                                                          ||  to_char(sql%rowcount) );
                                end if;

                                goto continue_with_next_inv;

                        end if;  -- invoice is not validated


                        -- control comes here only if the invoice is not cancelled and is in a validated stage.
                        -- check if re-process option has been chosen.

                        if p_reprocess = 'Y' then

                                -- program should re - process all invoices as per the given input.
                                -- if invoice has already been processed then flush the st form records
                                -- for the invoice where no matching has been done.

                                delete JAI_CMN_ST_FORM_DTLS a
                                where  invoice_id = c_invoices.invoice_id
                                and    issue_receipt_flag = 'I'
                                and    not exists (select '1'
                                                                   from   JAI_CMN_ST_MATCH_DTLS
                                                                   where  st_hdr_id = a.st_hdr_id
                                                                   and    st_dtl_id = a.st_dtl_id
                                                                   );

                                if v_debug = 'Y' then
                                        Fnd_File.put_line(Fnd_File.LOG,
                                                          '    Re-Process : No of unmatched records purged from st forms for this invoice :'
                                                                          ||  to_char(sql%rowcount) );
                                end if;

                        end if; -- p_reprocess = 'Y'


                        v_st_lines_for_inv := 0;
                        v_error_message := null;

                        lv_lt_lookup_code := 'MISCELLANEOUS' ;

                        /* uptake of ap_invoice_lines_all */
                        for c_inv_distributions in
                        (
                        select  invoice_id,
                                line_number,  --distribution_line_number
                                --invoice_distribution_id,
                                po_distribution_id,
                                rcv_transaction_id
                        from    ap_invoice_lines_all b --ap_invoice_distributions_all b
                        where   invoice_id = c_invoices.invoice_id
                        and     line_type_lookup_code = lv_lt_lookup_code --'MISCELLANEOUS' -- only tax lines  /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
                       /*  and     nvl(reversal_flag, 'N') <> 'Y' */
                        and     po_distribution_id is not null
                        and     not exists
                                        (select '1'
                                         from   JAI_CMN_ST_FORM_DTLS
                                         where  invoice_id = b.invoice_id
                                         and    invoice_line_number =  b.line_number
                                         --where  invoice_distribution_id =  b.invoice_distribution_id
                                         and    issue_receipt_flag = 'I'
                                        ) -- to ensure that the line is not processed twice.
                                          -- This should not happen as the invoice is already checked for prior processing.
                        and     exists
                                        (select '1'
                                         from   JAI_AP_MATCH_INV_TAXES
                                         where  invoice_id =  b.invoice_id
                                         --and    distribution_line_number  = b.distribution_line_number
                                         and    invoice_line_number  = b.line_number
                                         and     tax_id  in (select tax_id  from JAI_CMN_TAXES_ALL where stform_type is not null)
                                        ) -- to ensure that the line is an india local tax line for a st form type tax
                        order by   line_number --distribution_line_number
                        )
                        loop

                                v_invoice_error_flag := 'N';


                                begin

                                        -- get the tax id for the distribution line from table JAI_AP_MATCH_INV_TAXES

                                        v_tax_id := null;
                                        v_tax_type := null;
                                        v_tax_rate := null;
                                        v_stform_type:= null;
                                        v_po_line_location_id := null;
                                        v_po_header_id := null;
                                        v_tax_amount := null;

                                        /* uptake of ap_invoice_lines_all */
                                      open c_get_distrib_tax_details( c_inv_distributions.invoice_id,
                                                                        c_inv_distributions.line_number);
                                       --c_inv_distributions.distribution_line_number);

                                        fetch  c_get_distrib_tax_details into v_tax_id, v_po_line_location_id,
                                                        v_po_header_id, v_po_line_id, v_tax_amount, v_parent_invoice_line_number
                                                       ,lv_recoverable_flag; -- 5763527
                                         --v_parent_distribution_id;

                                        close c_get_distrib_tax_details;

                                        if v_tax_id is null then
                                                goto continue_with_next_dist;
                                        end if;

                                        open c_get_tax_details(v_tax_id);
                                        fetch c_get_tax_details into v_tax_type, v_tax_rate, v_stform_type
                                                                   , v_mod_cr_pctg; -- 5763527;

                                        close c_get_tax_details;

                                        if v_tax_type is null then
                                                goto continue_with_next_dist;
                                        end if;

                                        -- control comes here only when tax details exists .
                                        -- check if st forms entry should have been done.

                                        if  (   v_tax_type IN ('CST', 'Sales Tax') and
                                                        v_stform_type is not null
                                                        -- and NVL(v_tax_rate,0) <> 0
                                                )
                                        then

                                                open c_get_ven_info(c_inv_distributions.invoice_id);
                                                fetch c_get_ven_info into v_vendor_id, v_vendor_site_id, v_org_id;
                                                close c_get_ven_info;

                                                v_st_hdr_id := null;

                                                open c_get_st_hdr_id(v_stform_type, v_vendor_id, v_vendor_site_id, v_org_id);
                                                fetch c_get_st_hdr_id into v_st_hdr_id;
                                                close c_get_st_hdr_id;


                                                if v_st_hdr_id is null then

                                                        --select  JAI_CMN_STFORM_HDRS_ALL_S.nextval into    v_st_hdr_id from    dual;

                                                        insert into JAI_CMN_STFORM_HDRS_ALL
                                                        (
                                                        st_hdr_id,
                                                        party_id,
                                                        party_site_id,
                                                        form_type,
                                                        org_id,
                                                        party_type_flag,
                                                        creation_date,
                                                        created_by,
                                                        last_update_date,
                                                        last_updated_by
                                                        )
                                                        values
                                                        (
                                                        --v_st_hdr_id,
                                                        JAI_CMN_STFORM_HDRS_ALL_S.nextval,
                                                        v_vendor_id,
                                                        v_vendor_site_id,
                                                        v_stform_type,
                                                        v_org_id,
                                                        'V',
                                                        sysdate,
                                                        v_uid,
                                                        sysdate,
                                                        v_uid
                                                        ) returning st_hdr_id into v_st_hdr_id ;
                                                end if;


                                                -- enter ST forms details
                                                -- no need to check if details exist as it has been checked in the first cursor.

                                                v_po_num := null;
                                                v_type_lookup_code := null;
                                                open c_get_po_num(v_po_header_id);
                                                fetch c_get_po_num into v_po_num, v_type_lookup_code;
                                                close c_get_po_num;


                                                v_match_option := null;
                                                open c_get_match_org_loc(v_po_line_location_id);
                                                fetch c_get_match_org_loc into
                                                v_match_option, v_ship_to_organization_id, v_ship_to_location_id;
                                                close c_get_match_org_loc;

                                                v_doc_type  := null;
                                                if v_match_option = 'R' then
                                                        v_doc_type := 'RECEIPT';
                                                else
                                                        if  v_type_lookup_code = 'STANDARD' then
                                                                v_doc_type := 'STANDARD';
                                                        elsif v_type_lookup_code = 'BLANKET' then
                                                                v_doc_type := 'BLANKET';
                                                        else
                                                                v_doc_type := 'PLANNED';
                                                        end if;
                                                end if;


                                                v_tax_line_no := null;

                                                if c_inv_distributions.rcv_transaction_id is null then
                                                        open get_tax_ln_no_po(v_po_line_location_id, v_tax_id);
                                                        fetch get_tax_ln_no_po into v_tax_line_no;
                                                        close get_tax_ln_no_po ;
                                                else
                                                        open c_get_tax_ln_no_receipt(c_inv_distributions.rcv_transaction_id, v_tax_id);
                                                        fetch c_get_tax_ln_no_receipt into v_tax_line_no;
                                                        close c_get_tax_ln_no_receipt;
                                                end if;

                                                /* uptake of ap_invoice_lines_all */
                                                 v_tax_target_amount :=
                                                getSTformsTaxBaseAmount
                                                (
                                                c_inv_distributions.invoice_id,
                                                v_parent_invoice_line_number, --v_parent_distribution_id,
                                                v_tax_id,
                                                v_tax_amount,
                                                v_tax_rate
                                                );


                                                --
                                                -- 5763527
                                                -- For partially recoverable taxes tax_target_amount needs to be apportioned
                                                -- because there will be two lines one for recoverable and one for non recoverable
                                                -- and for both the tax lines getSTFormsTaxBaseAmount will return same base amount
                                                --
                                                Fnd_File.put_line(Fnd_File.LOG, 'v_tax_target_amount='||v_tax_target_amount||',v_mod_cr_pctg='||v_mod_cr_pctg||',lv_recoverable_flag='||lv_recoverable_flag);
                                                if v_mod_cr_pctg > 0 and v_mod_cr_pctg < 100 then
                                                  Fnd_File.put_line(Fnd_File.LOG, 'INSIDE IF1');
                                                  if lv_recoverable_flag = jai_constants.YES then
                                                    v_tax_target_amount := (v_tax_target_amount) * (v_mod_cr_pctg/100);
                                                  elsif lv_recoverable_flag = jai_constants.NO then
                                                    v_tax_target_amount := v_tax_target_amount * (1 - (v_mod_cr_pctg/100));
                                                  end if;

                                                end if;
                                                -- End 5763527
                                                /* select JAI_CMN_ST_FORM_DTLS_S.nextval into   v_st_dtl_id from   dual; */

                                                v_rcv_transaction_id := null;


                                                if c_inv_distributions.rcv_transaction_id is null then
                                                        open c_get_rcv_transaction_id(c_inv_distributions.invoice_id, c_inv_distributions.po_distribution_id, 'ITEM');
                                                        fetch c_get_rcv_transaction_id into v_rcv_transaction_id;
                                                        close c_get_rcv_transaction_id;
                                                else
                                                        v_rcv_transaction_id := c_inv_distributions.rcv_transaction_id;
                                                end if;


                                                insert into JAI_CMN_ST_FORM_DTLS
                                                (
                                                st_hdr_id,
                                                st_dtl_id,
                                                issue_receipt_flag,
                                                header_id,
                                                line_id,
                                                tax_line_no,
                                                tax_id,
                                                po_num,
                                                doc_type,
                                                tax_target_amount,
                                                po_line_location_id,
                                                rcv_transaction_id,
                                                invoice_id,
                                                invoice_line_number, --invoice_distribution_id,
                                                organization_id,
                                                location_id,
                                                creation_date,
                                                created_by,
                                                last_update_date,
                                                last_updated_by,
                                                last_update_login
                                                )
                                                values
                                                (
                                                v_st_hdr_id,
                                                --v_st_dtl_id,
                                                JAI_CMN_ST_FORM_DTLS_S.nextval,
                                                'I',
                                                v_po_header_id,
                                                v_po_line_id,
                                                v_tax_line_no,
                                                v_tax_id,
                                                v_po_num,
                                                v_doc_type,
                                                v_tax_target_amount,
                                                v_po_line_location_id,
                                                v_rcv_transaction_id,  -- c_inv_distributions.rcv_transaction_id,
                                                c_inv_distributions.invoice_id,
                                                c_inv_distributions.line_number, --c_inv_distributions.invoice_distribution_id,
                                                v_ship_to_organization_id,
                                                v_ship_to_location_id,
                                                sysdate,
                                                v_uid,
                                                sysdate,
                                                v_uid,
                                                v_uid
                                                ) returning st_dtl_id into v_st_dtl_id;

                                                v_st_lines_for_inv := v_st_lines_for_inv + 1;

                                        else

                                                goto continue_with_next_dist;

                                        end if;


                                        << continue_with_next_dist >>
                                        null;

                                exception
                                        when others then
                                                v_invoice_error_flag := 'Y';
                                                v_error_message := sqlerrm;
                                                goto continue_with_next_inv;
                                end;

                        end loop; -- c_inv_distributions


                        << continue_with_next_inv >>

                        if v_invoice_process_flag = 'N' then

                                commit;

                        elsif v_invoice_error_flag = 'Y' then

                                rollback;
                                if v_debug = 'Y' then
                                        Fnd_File.put_line(Fnd_File.LOG,' Error :' || v_error_message);
                                end if;
                                v_error_inv_cnt := v_error_inv_cnt + 1;
                                v_error_flag := 'Y';

                        else

                                commit;
                                if v_debug = 'Y' then
                                        Fnd_File.put_line(Fnd_File.LOG,'   Successful : No of ST forms lines created for the invoice - '
                                                          || to_char(v_st_lines_for_inv) );
                                end if;
                                v_processed_inv_cnt := v_processed_inv_cnt + 1;

                        end if;

                end;

        end loop; -- c_invoices


        Fnd_File.put_line(Fnd_File.LOG, '**** ======================= S U M M A R Y ======================= ****');
        Fnd_File.put_line(Fnd_File.LOG, '**** No of invoices processed successfully :'
                                        || to_char(v_processed_inv_cnt) );

        if v_not_processed_inv_cnt > 0 then
                Fnd_File.put_line(Fnd_File.LOG, '**** No of invoices not processed for status - cancelled /not validated status :'
                                                || to_char(v_not_processed_inv_cnt) );
        end if;


        if v_error_inv_cnt > 0 then

                Fnd_File.put_line(Fnd_File.LOG, '**** No of invoices for which error is encountered :'
                                  || to_char(v_error_inv_cnt) );

                p_ret_code := 1;
                p_err_buf := 'Please check the detailed log. '
                             || 'Invoice processed successfully - ' || to_char(v_processed_inv_cnt)
                             || '. Invoice errord out - ' || to_char(v_error_inv_cnt);
        end if;

        exception

        when others then
                p_ret_code := 2;
                p_err_buf := sqlerrm;
                Fnd_File.put_line(Fnd_File.LOG, '**** Exception from procedure ja_in_ap_populate_st_forms:' || sqlerrm);

end generate_ap_forms;

PROCEDURE generate_forms( errbuf OUT NOCOPY varchar2                ,
                ret_code OUT NOCOPY varchar2                ,
                p_from_date           VARCHAR2,                        -- default SYSDATE , -- Added global variable gd_from_date in package spec. by Ramananda for File.Sql.35
                p_to_date             VARCHAR2,                        -- default SYSDATE , -- Added global variable gd_to_date in package spec. by Ramananda for File.Sql.35
                p_all_orgs            varchar2                ,
                p_org_id              number                  ,
                p_party_type          varchar2                ,
                p_party_id            number  default null    ,
                p_party_site_id       number  default null    ,
                p_reprocess           varchar2,                     -- default 'N'    , Added global variable gv_reprocess  in package spec. by Ramananda for File.Sql.35
                P_Enable_Trace        varchar2
                )
is
  v_errbuf         varchar2(255);
  v_ret_code       varchar2(255);
  v_invoice_id     ra_customer_trx_all.customer_trx_id%type;
  v_sp_org_id      number; -- used to indicate whether to run concurrent program for a particular org id or all org ids


   -- trace generation logic
  CURSOR c_program_id(p_request_id IN NUMBER) IS
  SELECT concurrent_program_id, nvl(enable_trace,'N')
  FROM FND_CONCURRENT_REQUESTS
  WHERE REQUEST_ID = p_request_id;

  CURSOR get_audsid IS
  SELECT a.sid, a.serial#, b.spid FROM v$session a,v$process b
  WHERE audsid = userenv('SESSIONID')
  AND a.paddr = b.addr;

  CURSOR get_dbname IS
  SELECT name FROM v$database;

  v_enable_trace    FND_CONCURRENT_PROGRAMS.enable_trace%TYPE;
  v_program_id      FND_CONCURRENT_PROGRAMS.concurrent_program_id%TYPE;
  audsid NUMBER; -- := userenv('SESSIONID'); --Ramananda for File.Sql.35
  sid NUMBER;
  serial NUMBER;
  spid VARCHAR2(9);
  name1 VARCHAR2(25);
   -- trc gen

   /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_st_forms_pkg.generate_forms';
  ld_from_date DATE ;
  ld_to_date   DATE ;

  /* --------------------------------------------------------------------------------------------------------------------

   Change History:

   1.    21/10/2003    ssumaith - Bug # 3138194. Version#616.1

                       created the procedure and attached it with 'India ST forms Receipt processing'
                       This procedure calls the AP procedure or AR procedure internally based on
                       the party_type_flag being 'C' or 'V'

   2.    19/03/2004    ssumaith - bug# 3360432. Version#619.1

                       when st forms receipt processing concurrent program is called, calling the procedure
                       which does the processing for ISO orders also. Call to the procedure - jai_cmn_st_forms_pkg.generate_iso_forms
                       is made as part of this fix when the party_type parameter is 'C' in addition to the call made
                       for ST forms receipt - jai_cmn_st_forms_pkg.generate_ar_forms.

    3.    05-Jul-2006  Aiyer for the bug 5369250, Version  120.3
                       Issue:-
                         The concurrent failes with the following error :-
                         "FDPSTP failed due to ORA-01861: literal does not match format string ORA-06512: at line 1 "

                       Reason:-
                         The procedure generate_forms has two parameters p_from_date and p_to_date which are of type date , however the concurrent program
                         passes it in the canonical format and hence the failure.

                       Fix:-
                        Modified the procedure generate_forms.
                        Changed the datatype of p_from_date and p_to_date from date to varchar2 as this parameter.
                        Also added the new parameters ld_start_date and ld_end_date. The values in p_from_date and p_to_date would be converted to date format and
                        stored in these local variables

                       Dependency due to this fix:-
                        None

    4.   25-JUL-2006   Ramananda for bug#5376622, File Version 120.4
                       Issue:-
                        ST Form request has performance problem. The Request takes exceptionally long time when
                        customer Name is not given in parameter
                       Fix:-
                        Cursor c_fetch_records in generate_ar_forms procedure has high cost. Query doesn't have
                        a Localization table jai_ar_trxs. After adding a table jai_ar_trxs, cost is reduced,
                        thus improving the performance


   ---------------------------------------------------------------------------------------------------------------- */
begin
  /*
  ||aiyer for the bug 5369250
  ||convert from canonical to date
  */
  ld_from_date := fnd_date.canonical_to_date(p_from_date);
  ld_to_date   := fnd_date.canonical_to_date(p_to_date)  ;

  audsid := userenv('SESSIONID'); --Ramananda for File.Sql.35

  fnd_file.put_line(FND_FILE.LOG,'Entering Procedure - jai_cmn_st_forms_pkg.generate_forms');
  fnd_file.put_line(FND_FILE.LOG,'Parameters - p_org_id : '|| p_org_id ||' Process All orgs ' || p_all_orgs ||  ' p_party_type :' || p_party_type );
  fnd_file.put_line(FND_FILE.LOG,'Parameters - p_party_id : ' || p_party_id || ' p_party_site_id : ' || p_party_site_id);
  fnd_file.put_line(FND_FILE.LOG,'Parameters - p_from_date :' || p_from_date ||' p_to_date ' || p_to_date || ' Trace ' || P_Enable_Trace);

  if P_Enable_Trace = 'Y' or P_Enable_Trace = 'y' then
     execute immediate 'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''' ;

     OPEN c_program_id(FND_GLOBAL.CONC_REQUEST_ID);
     FETCH c_program_id INTO v_program_id, v_enable_trace;
     CLOSE c_program_id;

     fnd_file.put_line(FND_FILE.LOG, 'v_program_id -> '||v_program_id
                   ||', v_enable_trace -> '||v_enable_trace
                   ||', request_id -> '||FND_GLOBAL.CONC_REQUEST_ID);

     if v_enable_trace = 'Y' THEN
         OPEN get_audsid;
         FETCH get_audsid INTO sid, serial, spid;
         CLOSE get_audsid;

         OPEN get_dbname;
         FETCH get_dbname INTO name1;
         CLOSE get_dbname;

         fnd_file.put_line(FND_FILE.LOG,'TraceFile Name = '||lower(name1)||'_ora_'||spid||'.trc');
     end if;

      -- trx gen ends here
  end if;

  if p_all_orgs = 'Y' or p_all_orgs = 'y' then
     v_sp_org_id := NULL;
  else
     v_sp_org_id := p_org_id;
  end if;

  /*
   At this point, if the parameter is to run for all org ids , then passing null as the parameter to the inner
   procedure. Otherwise passing the particular org id to be processed.
  */

  if p_party_type = 'C' or p_party_type = 'c' then

      jai_cmn_st_forms_pkg.generate_ar_forms(
                               errbuf            ,
                               ret_code          ,
                               v_sp_org_id       ,
                               'C'               ,
                               p_party_id        ,
                               p_party_site_id   ,
                               ld_from_date      ,
                               ld_to_date
                              );

      jai_cmn_st_forms_pkg.generate_iso_forms(  -- Bug#3360432
                               errbuf            ,
                               ret_code          ,
                               v_sp_org_id       ,
                               p_party_type      ,
                               p_party_id        ,
                               p_party_site_id   ,
                               ld_from_date       ,
                               ld_to_date
                             );

  elsif p_party_type = 'V' or p_party_type = 'V' then
     jai_cmn_st_forms_pkg.generate_ap_forms(
                               errbuf            ,
                               ret_code          ,
                               v_sp_org_id       ,
                               p_party_id        ,
                               p_party_site_id   ,
                               ld_from_date      ,
                               ld_to_date        ,
                               p_reprocess
                             );
  end if;

  if errbuf is not null then
     fnd_file.put_line(FND_FILE.LOG,'Encountered the Error ' || errbuf);
  end if;

   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      errbuf  := null;
      ret_code := null;

      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

end generate_forms;

PROCEDURE generate_iso_forms(
                 errbuf OUT NOCOPY varchar2                ,
                 ret_code OUT NOCOPY varchar2                ,
                 p_org_id              number                  ,
                 p_party_type          varchar2                ,
                 p_party_id            number  default null    ,
                 p_party_site_id       number  default null    ,
                 p_from_date           date,                    --    default SYSDATE , -- Added global variable gd_from_date in package spec. by Ramananda for File.Sql.35
                 p_to_date             date                     --    default SYSDATE   -- Added global variable gd_to_date in package spec. by Ramananda for File.Sql.35
                 )
as

 cursor c_check_hdr_record_exists(
                                  p_party_id        number  ,
                                  p_party_site_id   number  ,
                                  p_form_type       varchar2 ,
                                  p_org_id          number
                                 )
 is
 select st_hdr_id
 from   JAI_CMN_STFORM_HDRS_ALL
 where  party_id        = p_party_id
 and    party_site_id   = p_party_site_id
 and    form_type       = p_form_type
 and    org_id          = p_org_id
 and    party_type_flag = 'C';

 cursor c_get_order_line_info(
                              p_delivery_detail_id number
                             )
 is
 select order_line_id   ,
        order_header_id ,
        organization_id ,
        location_id
 from   JAI_OM_WSH_LINES_ALL
 where  delivery_detail_id = p_delivery_detail_id;

 cursor c_get_order_info(
                         p_order_header_id number
                        )
 is
 select order_number
 from   oe_order_headers_all
 where  header_id = p_order_header_id;

 cursor c_check_duplicate(p_delivery_id Number)
 is
 select 1
 from   JAI_CMN_STFORM_HDRS_ALL hdr ,
        JAI_CMN_ST_FORM_DTLS dtl
 where  hdr.st_hdr_id       = dtl.st_hdr_id
 and    dtl.invoice_id      = p_delivery_id
 and    hdr.party_type_flag = 'C';


 cursor c_fetch_records is
 SELECT wnd.delivery_id                            ,
        wdd.org_id                                 ,
        wdd.source_header_number                   ,
        wdd.source_header_type_id                  ,
        wdd.source_header_type_name                ,
        oeh.sold_to_org_id         customer_id     ,
        oeh.ship_to_org_id         customer_site_id,
        jspl.excise_invoice_no
 FROM   wsh_new_deliveries         wnd   ,
        wsh_delivery_details       wdd   ,
        JAI_OM_WSH_LINES_ALL     jspl  ,
        oe_order_headers_all       oeh
 WHERE  jspl.delivery_id            = wnd.delivery_id
 AND    wdd.delivery_Detail_id      = jspl.delivery_detail_id
 AND    wdd.source_header_id        = oeh.header_id
 AND    oeh.source_document_type_id = 10
 AND    wdd.org_id                  = p_org_id
 AND    oeh.sold_to_org_id          = nvl(p_party_id,oeh.sold_to_org_id)
 AND    oeh.ship_to_org_id          = nvl(p_party_site_id,oeh.ship_to_org_id)
 AND    trunc(jspl.creation_date) between  p_from_date  and p_to_date
 AND    EXISTS
 (SELECT 1
  FROM   JAI_OM_WSH_LINE_TAXES jsptl ,
         JAI_CMN_TAXES_ALL            jtc
  WHERE  jtc.tax_id = jsptl.tax_id
  AND    jsptl.delivery_detail_id = jspl.delivery_detail_id
  AND    jtc.tax_type IN ( jai_constants.tax_type_sales, jai_constants.tax_type_cst) --('Sales Tax','CST') /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
  AND    jtc.stform_type IS NOT NULL
 )
 AND NOT EXISTS
  (SELECT 1
   FROM   JAI_CMN_ST_FORM_DTLS jstd
   WHERE  jstd.header_id  = oeh.header_id
   AND    jstd.invoice_id = wnd.delivery_id
   AND    jstd.line_id    = jspl.order_line_id
   AND    jstd.order_flag = 'O'
  )
 GROUP BY wnd.delivery_id              ,
          wdd.org_id                   ,
          wdd.source_header_number     ,
          wdd.source_header_type_id    ,
          wdd.source_header_type_name  ,
          oeh.sold_to_org_id           ,
          oeh.ship_to_org_id,
          jspl.excise_invoice_no;

 cursor c_get_taxes(p_delivery_id number)
 is
 select
       jsptl.TAX_LINE_NO                ,
       jsptl.delivery_detail_ID         ,
       jsptl.PRECEDENCE_1               ,
       jsptl.PRECEDENCE_2               ,
       jsptl.PRECEDENCE_3               ,
       jsptl.PRECEDENCE_4               ,
       jsptl.PRECEDENCE_5               ,
       jsptl.TAX_ID                     ,
       jsptl.TAX_RATE                   ,
       jsptl.QTY_RATE                   ,
       jsptl.UOM                        ,
       jsptl.TAX_AMOUNT                 ,
       jsptl.base_tax_amount            ,
       jtc.stform_type
 from   JAI_OM_WSH_LINE_TAXES  jsptl ,
        JAI_CMN_TAXES_ALL             jtc
 where  delivery_detail_id in
        (
         select  delivery_detail_id
         from    JAI_OM_WSH_LINES_ALL
         where   delivery_id = p_delivery_id
        )
 and  jtc.tax_id = jsptl.tax_id
 and  jtc.tax_type in ( jai_constants.tax_type_sales, jai_constants.tax_type_cst) --('Sales Tax','CST') /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
 and  jtc.stform_type is not null;

 v_hdr_record_exists      number;
 v_st_hdr_id              number;
 v_st_line_id             number;
 v_order_line_id          number;
 v_order_hdr_id           number;
 v_order_num              number;
 v_trx_number             number;
 v_trx_type_id            number;
 v_base_tax_amt           number;
 v_record_exists          number;
 v_ret_code               number;
 v_errbuf                 varchar2(255);
 v_sqlerrm                varchar2(255);
 v_some_errors            char(1); -- := '0'; -- used to identify if all was successful --Ramananda for File.Sql.35
 v_orgn_id                number;
 v_locn_id                number;
 v_order_flag             char(1); -- := 'O'; --Ramananda for File.Sql.35

 v_excise_invoice_no JAI_OM_WSH_LINES_ALL.excise_invoice_no%type;

 /*
 the purpose of the following function is to calculate the base tax amounts
 This needs to be specifically used in cases such as 0%tax added manually.
 Need to pass the delivery_detail_id of the shipment line to which the tax is attached
 and the tax id for which the tax calculation needs to be done.
 */

 function get_base_tax_amount(p_delivery_Detail_id number ,
                              p_tax_id number) return number is
      cursor c_tax_amount (p_p1 number,p_p2 number,p_p3 number,p_p4 number,p_p5 number)is
      SELECT SUM(tax_amount)
      FROM   JAI_OM_WSH_LINE_TAXES
      WHERE  delivery_detail_id = p_delivery_Detail_id
      AND    tax_line_no IN (p_p1,p_p2,p_p3,p_p4,p_p5);

      cursor c_get_precedences
      is
      select precedence_1,
      precedence_2,
      precedence_3,
      precedence_4,
      precedence_5
      from  JAI_OM_WSH_LINE_TAXES
      where delivery_detail_id = p_delivery_Detail_id
      and   tax_id = p_tax_id;

      cursor c_get_line_amount
      is
      select selling_price * quantity  line_amount
      from   JAI_OM_WSH_LINES_ALL
      where  delivery_detail_id = p_delivery_Detail_id;

      v_prec_rec c_get_precedences%rowtype;

      v_tax_amount  number;
      v_line_amount number;

      begin


          open c_get_precedences;
          fetch c_get_precedences into v_prec_rec;
          close c_get_precedences;

          open  c_tax_amount(v_prec_rec.precedence_1,
                             v_prec_rec.precedence_2,
                             v_prec_rec.precedence_3,
                             v_prec_rec.precedence_4,
                             v_prec_rec.precedence_5);
          fetch c_tax_amount into v_tax_amount;
          close c_tax_amount;

          if v_prec_rec.precedence_1 = 0 or v_prec_rec.precedence_2 = 0 or v_prec_rec.precedence_3 = 0
          or v_prec_rec.precedence_4 = 0 or v_prec_rec.precedence_5 = 0 then
             open  c_get_line_amount;
             fetch c_get_line_amount into v_line_amount;
             close c_get_line_amount;
          end  if;
          return (nvl(v_line_amount,0) + nvl(v_tax_amount,0));

     end get_base_tax_amount ;

BEGIN

/*-----------------------------------------------------------------------------------------------------------------
   Change history for jai_cmn_st_forms_pkg.generate_iso_forms  procedure

SlNo  dd/mm/yyyy      Author and Description of Changes
-------------------------------------------------------------------------------------------------------------------
1.    13/10/2003      ssumaith  bug # 3360432 , FileVersion: 619.1
                       this procedure does the actual population of ST form related data into the revised tables
                       when processed for ISO orders post shipment.
                       This procedure will be called from the wrapper program - jai_cmn_st_forms_pkg.generate_forms
                       when party_type parameter = 'C'

                       Doc_Type field in the JAI_CMN_ST_FORM_DTLS is set to 'ISO'

                       Grouping in the form will be done based on excise invoice number, where excise invoice number is
                       generated for the iso order. Delivery id in is used for this grouping, in case excise invoice
                       number is not generated.
-----------------------------------------------------------------------------------------------------------------*/

 v_some_errors            := '0'; -- used to identify if all was successful --Ramananda for File.Sql.35
 v_order_flag             := 'O'; --Ramananda for File.Sql.35

 fnd_file.put_line(FND_FILE.LOG,'1 Entering procedure  : jai_cmn_st_forms_pkg.generate_iso_forms' );
 fnd_file.put_line(FND_FILE.LOG,'Parameters - p_org_id -> : '|| p_org_id || ' p_party_type -> :' || p_party_type );
 fnd_file.put_line(FND_FILE.LOG,'Parameters - p_party_id -> : ' || p_party_id || ' p_party_site_id -> : ' || p_party_site_id);
 fnd_file.put_line(FND_FILE.LOG,'Parameters - p_from_date -> :' || p_from_date ||' p_to_date -> :' || p_to_date);

 FOR st_forms_rec IN c_fetch_records
 LOOP

   /* duplicate check */
   fnd_file.put_line(FND_FILE.LOG,'1.0 Processing delivery  : ' || st_forms_rec.delivery_id);

   v_record_exists := null;

   open  c_check_duplicate(st_forms_rec.delivery_id);
   fetch c_check_duplicate into v_record_exists;
   close c_check_duplicate;

   if v_record_exists is null then
      -- only if there are no records already retreived
      -- for the delivery do the processing

     /*
       If the control comes here , it is assumed that the delivery which is being looped has st forms
       related taxes no check done here again.
       need to insert records into the st forms hdr and st forms detail tables.
       JAI_CMN_STFORM_HDRS_ALL
       JAI_CMN_ST_FORM_DTLS
     */
     fnd_file.put_line(FND_FILE.LOG,'1.1 Delivery : ' || st_forms_rec.delivery_id || ' not present in St form tables, hence processing.' );

     FOR tax_rec IN c_get_taxes(st_forms_rec.delivery_id)
     LOOP
      BEGIN

        v_hdr_record_exists := null;
        v_order_line_id     := null;
        v_order_hdr_id      := null;
        v_order_num         := null;
        v_base_tax_amt      := null;

        open c_check_hdr_record_exists(
                                        st_forms_rec.customer_id          ,
                                        st_forms_rec.customer_site_id     ,
                                        tax_rec.stform_type               ,
                                        st_forms_rec.org_id
                                      );
        fetch c_check_hdr_record_exists into v_hdr_record_exists;
        close c_check_hdr_record_exists;


         if v_hdr_record_exists is null then

           /* no record exists in the st forms hdr table (JAI_CMN_STFORM_HDRS_ALL) for the combination of
              party , party site , form_type , org_id and party type.
           */


           INSERT INTO JAI_CMN_STFORM_HDRS_ALL(
                    st_hdr_id                      ,
                    party_id                       ,
                    party_site_id                  ,
                    form_type                      ,
                    creation_date                  ,
                    created_by                     ,
                    last_update_date               ,
                    last_updated_by                ,
                    last_update_login              ,
                    org_id                         ,
                    party_type_flag
            ) values (
                    JAI_CMN_STFORM_HDRS_ALL_S.nextval   ,
                    st_forms_rec.customer_id       ,
                    st_forms_rec.customer_site_id  ,
                    tax_rec.stform_type            ,
                    sysdate                        ,
                    fnd_global.user_id             ,
                    sysdate                        ,
                    fnd_global.user_id             ,
                    fnd_global.login_id            ,
                    st_forms_rec.org_id            ,
                    'C'
            ) RETURNING st_hdr_id INTO v_st_hdr_id;
            fnd_file.put_line(FND_FILE.LOG,' inserting into JAI_CMN_STFORM_HDRS_ALL table with header id '|| v_st_hdr_id);
        ELSE

           v_st_hdr_id := v_hdr_record_exists;
           fnd_file.put_line(FND_FILE.LOG,'header record found . Header id is : ' ||v_st_hdr_id);


        END IF;


          open   c_get_order_line_info(tax_rec.delivery_detail_id);
          fetch  c_get_order_line_info into v_order_line_id, v_order_hdr_id,v_orgn_id , v_locn_id;
          close  c_get_order_line_info;

          open   c_get_order_info (v_order_hdr_id);
          fetch  c_get_order_info into v_order_num;
          close  c_get_order_info;

          v_order_flag := 'O';


        /*if tax_rec.tax_rate > 0 and tax_rec.base_tax_amount is not null then
           v_base_tax_amt := (tax_rec.tax_amount * 100) / tax_rec.tax_rate;
        end if;
        */

        IF tax_rec.base_tax_amount IS NULL THEN
           v_base_tax_amt := get_base_tax_amount(tax_rec.delivery_detail_id, tax_rec.tax_id);
           IF v_base_tax_amt IS NULL THEN
               v_base_tax_amt :=0;
           end if;
        END IF;



        INSERT INTO JAI_CMN_ST_FORM_DTLS(
                ST_HDR_ID                           ,
                ST_DTL_ID                           ,
                HEADER_ID                           , -- order header id
                LINE_ID                             , -- order line id
                TAX_ID                              ,
                TAX_LINE_NO                         ,
                INVOICE_ID                          , -- delivery id
                ISSUE_RECEIPT_FLAG                  ,
                TAX_TARGET_AMOUNT                   ,
                MATCHED_AMOUNT                      ,
                ORDER_FLAG                          , -- 'O'
                ORDER_NUMBER                        , -- sales order number
                TRX_TYPE_ID                         ,
                TRX_NUMBER                          , -- excise invoice number, if null then delivery
                organization_id                     ,
                location_id                         ,
                doc_type                            , -- Hard coded Value 'ISO' passed
                CREATION_DATE                       ,
                CREATED_BY                          ,
                LAST_UPDATE_DATE                    ,
                LAST_UPDATED_BY                     ,
                LAST_UPDATE_LOGIN
        ) values (
                v_st_hdr_id                         ,
                JAI_CMN_ST_FORM_DTLS_S.nextval        ,
                v_order_hdr_id                      ,
                v_order_line_id                     ,
                tax_rec.tax_id                      ,
                tax_rec.tax_line_no                 ,
                st_forms_rec.delivery_id            ,
                'R'                                 ,
                nvl(tax_rec.base_tax_amount
                    ,v_base_tax_amt)                ,
                NULL                                , -- matched amount
                v_order_flag                        ,
                v_order_num                         ,
                st_forms_rec.source_header_type_id  ,
                nvl(st_forms_rec.excise_invoice_no, st_forms_rec.delivery_id)                       , -- need to confirm it after discussion
                v_orgn_id                           ,
                v_locn_id                           ,
                'ISO'                               ,
                sysdate                             ,
                fnd_global.user_id                  ,
                sysdate                             ,
                fnd_global.user_id                  ,
                fnd_global.login_id

        ) RETURNING st_dtl_id INTO v_st_line_id;
        fnd_file.put_line(FND_FILE.LOG,' inserting into JAI_CMN_ST_FORM_DTLS table with detail id :' ||v_st_line_id );
        v_base_tax_amt :=NULL;

      EXCEPTION
        WHEN OTHERS THEN
           fnd_file.put_line(FND_FILE.LOG,'Encountered Error when processing Delivery : ' || st_forms_Rec.delivery_id );
           fnd_file.put_line(FND_FILE.LOG,'Error reported is  : ' || sqlerrm );
           v_some_errors := '1';
           rollback;
           EXIT;        -- So that this delivery_id is not processed further
      END;

     END LOOP; -- tax loop

   END IF;

   v_orgn_id := Null;
   v_locn_id := Null;

   COMMIT; -- commit for every delivery

 END LOOP; -- delivery loop

 if v_some_errors = '1' then
      v_ret_code := '1'; -- signal completion with warnings -- some deliveries could not be processed successfully
      ret_code := v_ret_code;
 else
      v_Ret_code := '0' ;-- signal normal completion.
      ret_code := v_ret_code;
 end if;

EXCEPTION
  WHEN OTHERS THEN
       v_sqlerrm  := substr(sqlerrm,1,255);
       errbuf   := v_sqlerrm;
       v_ret_code := 2; -- signal error
       ret_code := v_ret_code;
end generate_iso_forms;

procedure generate_ar_forms(
errbuf OUT NOCOPY varchar2                ,
ret_code OUT NOCOPY varchar2                ,
p_org_id              number                  ,
p_party_type          varchar2                ,
p_party_id            number  default null    ,
p_party_site_id       number  default null    ,
p_from_date           date,                    --    default SYSDATE , -- Added global variable gd_from_date in package spec. by Ramananda for File.Sql.35
p_to_date             date                     --    default SYSDATE   -- Added global variable gd_to_date in package spec. by Ramananda for File.Sql.35
)
as

 cursor c_check_hdr_record_exists(
                                  p_party_id        number  ,
                                  p_party_site_id   number  ,
                                  p_form_type       varchar2 ,
                                  p_org_id          number
                                 )
 is
 select st_hdr_id
 from   JAI_CMN_STFORM_HDRS_ALL
 where  party_id        = p_party_id
 and    party_site_id   = p_party_site_id
 and    form_type       = p_form_type
 and    org_id          = p_org_id
 and    party_type_flag = 'C';

 cursor c_get_order_line_info(
                              p_customer_trx_line_id number
                             )
 is
 select interface_line_attribute6
 from   ra_customer_trx_lines_all
 where  customer_Trx_line_id = p_customer_trx_line_id;

 cursor c_get_order_hdr(
                         p_order_line_id number
                       )
 is
 select  header_id
 from    oe_order_lines_all
 where   line_id = p_order_line_id;

 cursor c_get_order_info(
                         p_order_header_id number
                        )
 is
 select order_number
 from   oe_order_headers_all
 where  header_id = p_order_header_id;

 cursor c_check_duplicate(p_invoice_id Number)
 is
 select 1
 from   JAI_CMN_STFORM_HDRS_ALL hdr ,
        JAI_CMN_ST_FORM_DTLS dtl
 where  hdr.st_hdr_id       = dtl.st_hdr_id
 and    dtl.invoice_id      = p_invoice_id
 and    hdr.party_type_flag = 'C';


 cursor c_fetch_records is
 select trx.customer_trx_id , trx.org_id , trx.trx_number , trx.cust_trx_type_id , trx.created_from,
        nvl(trx.bill_to_customer_id,trx.ship_to_customer_id) customer_id, nvl(trx.bill_to_site_use_id,trx.ship_to_site_use_id) customer_site_id,
		decode( trx_types.TYPE ,'INV','Invoice','CM','Credit Memo','DM','Debit Memo',trx_types.TYPE ) document_type  /*JMEENA for bug#4932256( FP 4913641)*/
 from   ra_customer_Trx_all       trx ,
        ra_cust_trx_types_all     trx_types ,
        jai_ar_trxs               jtrx         /* Added for bug#5376622 */
 where
        trx.customer_trx_id = jtrx.customer_trx_id AND
     (trx.bill_to_customer_id = nvl(p_party_id,trx.bill_to_customer_id)
       OR
       trx.ship_to_customer_id = nvl(p_party_id,trx.ship_to_customer_id))      AND
     (trx.bill_to_site_use_id = nvl(p_party_site_id,trx.bill_to_site_use_id)
       OR
      trx.ship_to_site_use_id = nvl(p_party_site_id,trx.ship_to_site_use_id))  AND
      trx.org_id = nvl(p_org_id,trx.org_id)                                                   AND
      NOT EXISTS
      (SELECT 1
       FROM    JAI_CMN_ST_FORM_DTLS a ,
               JAI_CMN_STFORM_HDRS_ALL b
       WHERE   b.party_id = nvl(p_party_id,b.party_id)                                AND
               b.party_site_id = nvl(p_party_site_id,b.party_site_id)                 AND
               b.party_type_flag = 'C'                                                AND
               a.st_hdr_id = b.st_hdr_id                                              AND
               a.invoice_id = trx.customer_trx_id
      )                                                  AND
      EXISTS
      (SELECT 1
       FROM   JAI_AR_TRX_LINES trx_lines
       WHERE  customer_trx_id = trx.customer_trx_id      AND
       EXISTS
       (SELECT 1
        FROM   JAI_AR_TRX_TAX_LINES tax_lines ,
               JAI_CMN_TAXES_ALL             jtc
        WHERE  link_to_cust_trx_line_id = trx_lines.customer_trx_line_id              AND
               tax_type IN ( jai_constants.tax_type_sales, jai_constants.tax_type_cst) --('Sales Tax','CST') /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
               AND jtc.tax_id = tax_lines.tax_id                                          AND
               jtc.stform_type IS NOT NULL
       )
       and trx.complete_flag ='Y'
       AND trx_date between p_from_date and p_to_date
       and trx_types.type in ('INV' ,'CM','DM')/*JMEENA for bug#4932256 (FP 4913641) . Added CM and DM*/
       and trx_types.cust_Trx_type_id = trx.cust_trx_type_id
       and trx_types.org_id = trx.org_id
      );


 cursor c_get_taxes(p_invoice_id number)
 is
 select
       jtxn.TAX_LINE_NO                ,
       jtxn.CUSTOMER_TRX_LINE_ID       ,
       jtxn.LINK_TO_CUST_TRX_LINE_ID   ,
       jtxn.PRECEDENCE_1               ,
       jtxn.PRECEDENCE_2               ,
       jtxn.PRECEDENCE_3               ,
       jtxn.PRECEDENCE_4               ,
       jtxn.PRECEDENCE_5               ,
       jtxn.TAX_ID                     ,
       jtxn.TAX_RATE                   ,
       jtxn.QTY_RATE                   ,
       jtxn.UOM                        ,
       jtxn.TAX_AMOUNT                 ,
       jtxn.INVOICE_CLASS              ,
       jtxn.base_tax_amount            ,
       jtc.stform_type
 from   JAI_AR_TRX_TAX_LINES jtxn ,
        JAI_CMN_TAXES_ALL             jtc
 where  link_to_cust_Trx_line_id in
        (
         select  customer_Trx_line_id
         from    JAI_AR_TRX_LINES
         where   customer_trx_id = p_invoice_id
        )
 and  jtc.tax_id = jtxn.tax_id
 and  jtc.tax_type in ( jai_constants.tax_type_sales, jai_constants.tax_type_cst) --('Sales Tax','CST') /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
 and  jtc.stform_type is not null;

 cursor c_orgn_locn (p_invoice_id number)
 is
 select organization_id , location_id
 from   JAI_AR_TRXS
 where  customer_trx_id = p_invoice_id;

 cursor c_trx_type(p_cust_trx_type_id number) is
 select type
 from   ra_cust_trx_types_all
 where  cust_trx_type_id = p_cust_trx_type_id;

 v_hdr_record_exists      number;
 v_st_hdr_id              number;
 v_st_line_id             number;
 v_order_line_id          number;
 v_order_hdr_id           number;
 v_order_num              number;
 v_trx_number             number;
 v_trx_type_id            number;
 v_base_tax_amt           number;
 v_record_exists          number;
 v_ret_code               number;
 v_errbuf                 varchar2(255);
 v_sqlerrm                varchar2(255);
 v_created_from           ra_customer_trx_all.created_from%type;
 const_manual   constant  ra_customer_trx_all.created_from%type  := 'ARXTWMAI';
 const_autoinv  constant  ra_customer_trx_all.created_from%type  := 'RAXTRX';
 v_some_errors            char(1); -- := '0'; -- used to identify if all was successful --Ramananda for File.Sql.35
 v_orgn_id                number;
 v_locn_id                number;
 v_trx_type               ra_cust_trx_types_all.type%type;
 v_order_flag             char(1); --:= 'O'; --Ramananda for File.Sql.35

 /*
 the purpose of the following function is to calculate the base tax amounts
 This needs to be specifically used in cases such as 0%tax added manually.
 Need to pass the Customer_trx_line_id of the invoice line to which the tax is attached
 and the tax id for which the tax calculation needs to be done.
 */
 function get_base_tax_amount(p_Link_to_line_id number , p_tax_id number) return number is
     cursor c_tax_amount is
     SELECT SUM(tax_amount)
     FROM   JAI_AR_TRX_TAX_LINES
     WHERE  link_to_cust_trx_line_id = p_Link_to_line_id
     AND    tax_line_no IN
     (
     SELECT  precedence_1
     FROM    JAI_AR_TRX_TAX_LINES
     WHERE    link_to_cust_trx_line_id = p_Link_to_line_id
     and      precedence_1 is not null
     AND     tax_id = p_tax_id
     UNION
     SELECT  precedence_2
     FROM    JAI_AR_TRX_TAX_LINES
     WHERE    link_to_cust_trx_line_id = p_Link_to_line_id
     AND     tax_id = p_tax_id
     and      precedence_1 is not null
     UNION
     SELECT  precedence_3
     FROM    JAI_AR_TRX_TAX_LINES
     WHERE    link_to_cust_trx_line_id = p_Link_to_line_id
     AND     tax_id = p_tax_id
     and      precedence_1 is not null
     UNION
     SELECT  precedence_4
     FROM    JAI_AR_TRX_TAX_LINES
     WHERE    link_to_cust_trx_line_id = p_Link_to_line_id
     and      precedence_1 is not null
     AND     tax_id = p_tax_id
     UNION
     SELECT  precedence_5
     FROM    JAI_AR_TRX_TAX_LINES
     WHERE    link_to_cust_trx_line_id = p_Link_to_line_id
     and      precedence_1 is not null
     AND     tax_id = p_tax_id
     );

     cursor c_get_precedences
     is
     select precedence_1,
     precedence_2,
     precedence_3,
     precedence_4,
     precedence_5
     from  JAI_AR_TRX_TAX_LINES
     where link_to_cust_trx_line_id = p_Link_to_line_id
     and   tax_id = p_tax_id;

     cursor c_get_line_amount
     is select line_amount
     from JAI_AR_TRX_LINES
     where  customer_trx_line_id = p_link_to_line_id;

     v_prec_rec c_get_precedences%rowtype;

     v_tax_amount  number;
     v_line_amount number;
     begin


                 open  c_tax_amount;
         fetch c_tax_amount into v_tax_amount;
         close c_tax_amount;

         open c_get_precedences;
         fetch c_get_precedences into v_prec_rec;
         close c_get_precedences;

         if v_prec_rec.precedence_1 = 0 or v_prec_rec.precedence_2 = 0 or v_prec_rec.precedence_3 = 0
         or v_prec_rec.precedence_4 = 0 or v_prec_rec.precedence_5 = 0 then
            open  c_get_line_amount;
            fetch c_get_line_amount into v_line_amount;
            close c_get_line_amount;
         end  if;
         return (nvl(v_line_amount,0) + nvl(v_tax_amount,0));
    end;


BEGIN

/*-----------------------------------------------------------------------------------------------------------------
   Change history for jai_cmn_st_forms_pkg.generate_ar_forms procedure

SlNo  dd/mm/yyyy      Author and Description of Changes
-------------------------------------------------------------------------------------------------------------------
1.    13/10/2003      ssumaith  bug # 3138194, FileVersion: 616.1
                       this procedure does the actual population of ST form related data into the revised tables
                       when processed for an AR invoice which is in a completed state.

2.    13/02/2004      Vijay Shankar for bug # 3441533, FileVersion: 618.1
                       v_hdr_record_exists variable which is used to check whether header is inserted or not is retaining its value
                       in the loop. This is fixed by assigning NULL at the start of the loop so that it wont retain its value.
                       Also the code SELECT <sequence_name>.nextval INTO <var> FROM DUAL is modified to populate <var> during INSERT
                       Statement. Usage of v_success variable is removed

3.  18/11/2008 JMEENA for bug#4932256 (FP 4913641)
			 Issue: Debit Notes and Credit Notes are not considered for AR ST Forms tracking in AR
			Fix: Modified the cursor c_fetch_records to fetch CM and DM also
-----------------------------------------------------------------------------------------------------------------*/

 v_some_errors            := '0'; -- used to identify if all was successful --Ramananda for File.Sql.35
 v_order_flag             := 'O'; --Ramananda for File.Sql.35

 fnd_file.put_line(FND_FILE.LOG,'1 Entering procedure  : jai_cmn_st_forms_pkg.generate_ar_forms' );
 fnd_file.put_line(FND_FILE.LOG,'Parameters - p_org_id -> : '|| p_org_id || ' p_party_type -> :' || p_party_type );
 fnd_file.put_line(FND_FILE.LOG,'Parameters - p_party_id -> : ' || p_party_id || ' p_party_site_id -> : ' || p_party_site_id);
 fnd_file.put_line(FND_FILE.LOG,'Parameters - p_from_date -> :' || p_from_date ||' p_to_date -> :' || p_to_date);

 FOR st_forms_rec IN c_fetch_records
 LOOP

   /* duplicate check */
   fnd_file.put_line(FND_FILE.LOG,'1.0 Processing invoice : '||st_forms_rec.document_type||':' || st_forms_rec.customer_trx_id);

   v_record_exists := null;

   open  c_check_duplicate(st_forms_rec.customer_trx_id);
   fetch c_check_duplicate into v_record_exists;
   close c_check_duplicate;

   if v_record_exists is null then
      -- only if there are no records already retreived
      -- for the invoice do the processing

     /*
       If the control comes here , it is assumed that the invoice which is being looped has st forms related taxes
       no check done here again.
       need to insert records into the st forms hdr and st forms detail tables.
       JAI_CMN_STFORM_HDRS_ALL
       JAI_CMN_ST_FORM_DTLS
     */
     fnd_file.put_line(FND_FILE.LOG,'1.1 Invoice : '||st_forms_rec.document_type||':' || st_forms_rec.customer_trx_id || ' not present in St form tables, hence processing.' );

     FOR tax_rec IN c_get_taxes(st_forms_rec.customer_trx_id)
     LOOP
      BEGIN

        --Start, Vijay Shankar for bug # 3441533
        v_hdr_record_exists := null;
        v_order_line_id := null;
        v_order_hdr_id := null;
        v_order_num := null;
        v_base_tax_amt := null;
        --End, Vijay Shankar for bug # 3441533

         open c_check_hdr_record_exists(
                                        st_forms_rec.customer_id          ,
                                        st_forms_rec.customer_site_id     ,
                                        tax_rec.stform_type               ,
                                        st_forms_rec.org_id
                                       );
         fetch c_check_hdr_record_exists into v_hdr_record_exists;
         close c_check_hdr_record_exists;


         if v_hdr_record_exists is null then

           /* no record exists in the st forms hdr table (JAI_CMN_STFORM_HDRS_ALL) for the combination of
              party , party site , form_type , org_id and party type.
           */

           fnd_file.put_line(FND_FILE.LOG,'before inserting into JAI_CMN_STFORM_HDRS_ALL table');
           INSERT INTO JAI_CMN_STFORM_HDRS_ALL(
                    st_hdr_id                      ,
                    party_id                       ,
                    party_site_id                  ,
                    form_type                      ,
                    creation_date                  ,
                    created_by                     ,
                    last_update_date               ,
                    last_updated_by                ,
                    last_update_login              ,
                    org_id                         ,
                    party_type_flag
            ) values (
                    JAI_CMN_STFORM_HDRS_ALL_S.nextval    ,
                    st_forms_rec.customer_id        ,
                    st_forms_rec.customer_site_id   ,
                    tax_rec.stform_type             ,
                    sysdate                         ,
                    fnd_global.user_id              ,
                    sysdate                         ,
                    fnd_global.user_id              ,
                    fnd_global.login_id             ,
                    st_forms_rec.org_id             ,
                    'C'
            ) RETURNING st_hdr_id INTO v_st_hdr_id;

        ELSE

           v_st_hdr_id := v_hdr_record_exists;

        END IF;

        if st_forms_Rec.created_from = const_Autoinv then

          /* fetching order details for autoinvoice. */
          open   c_get_order_line_info(tax_rec.link_to_cust_trx_line_id);
          fetch  c_get_order_line_info into v_order_line_id;
          close  c_get_order_line_info;

          open   c_get_order_hdr(v_order_line_id);
          fetch  c_get_order_hdr into v_order_hdr_id;
          close  c_get_order_hdr;

          open   c_get_order_info (v_order_hdr_id);
          fetch  c_get_order_info into v_order_num;
          close  c_get_order_info;

          v_order_flag := 'O';

        elsif st_forms_Rec.created_from = const_manual then

          v_order_hdr_id  := st_forms_Rec.customer_Trx_id;
          v_order_line_id := tax_rec.customer_trx_line_id;

          v_order_flag := 'I';
          v_order_num := NULL;

        end if;

        v_order_line_id := tax_rec.link_to_cust_trx_line_id;
        -- based on input from NPAI
        -- either from Autoinvoiced invoice or a manual ar invoice ,
        -- we need to populate customer trx line id of the line to which the  Tax is attached from
        -- JAI_AR_TRX_TAX_LINES

        if tax_rec.tax_rate > 0 and tax_rec.base_tax_amount is not null then
           v_base_tax_amt := (tax_rec.tax_amount * 100) / tax_rec.tax_rate;
        end if;

        IF v_base_tax_amt IS NULL THEN
           v_base_tax_amt := get_base_tax_amount(tax_rec.link_to_cust_trx_line_id, tax_rec.tax_id);
           IF v_base_tax_amt IS NULL THEN
               v_base_tax_amt :=0;
           end if;
        END IF;

        if v_orgn_id is null then
           open  c_orgn_locn(st_forms_rec.customer_trx_id);
           fetch c_orgn_locn into v_orgn_id , v_locn_id;
           close c_orgn_locn;
        end if;

        fnd_file.put_line(FND_FILE.LOG,'before inserting into JAI_CMN_ST_FORM_DTLS table');

        INSERT INTO JAI_CMN_ST_FORM_DTLS(
                ST_HDR_ID                      ,
                ST_DTL_ID                      ,
                HEADER_ID                      , -- order header id
                LINE_ID                        , -- order line id
                TAX_ID                         ,
                TAX_LINE_NO                    ,
                INVOICE_ID                     , -- customer trx id
                ISSUE_RECEIPT_FLAG             ,
                TAX_TARGET_AMOUNT              ,
                MATCHED_AMOUNT                 ,
                ORDER_FLAG                     , -- 'O'
                ORDER_NUMBER                   , -- sales order number
                TRX_TYPE_ID                    ,
                TRX_NUMBER                     , -- invoice num
                organization_id                ,
                location_id                    ,
                CREATION_DATE                  ,
                CREATED_BY                     ,
                LAST_UPDATE_DATE               ,
                LAST_UPDATED_BY                ,
                LAST_UPDATE_LOGIN
        ) values (
                v_st_hdr_id                    ,
                JAI_CMN_ST_FORM_DTLS_S.nextval   ,
                v_order_hdr_id                 ,
                v_order_line_id                ,
                tax_rec.tax_id                 ,
                tax_rec.tax_line_no            ,
                st_forms_rec.customer_Trx_id   ,
                'R'                            ,
                nvl(tax_rec.base_tax_amount
                    ,v_base_tax_amt)        ,
                NULL                           , -- matched amount
                v_order_flag                   ,
                v_order_num                    ,
                st_forms_rec.cust_trx_type_id  ,
                st_forms_rec.trx_number        ,
                v_orgn_id                      ,
                v_locn_id                      ,
                sysdate                        ,
                fnd_global.user_id             ,
                sysdate                        ,
                fnd_global.user_id             ,
                fnd_global.login_id

        ) RETURNING st_dtl_id INTO v_st_line_id;

        v_base_tax_amt :=NULL;

      EXCEPTION
        WHEN OTHERS THEN
           fnd_file.put_line(FND_FILE.LOG,'Encountered Error when processing Invoice : ' ||st_forms_rec.document_type||':'|| st_forms_Rec.customer_Trx_id );
           fnd_file.put_line(FND_FILE.LOG,'Error reported is  : ' || sqlerrm );
           v_some_errors := '1';
           rollback;
           EXIT;        -- So that this CUSTOMER_TRX_ID is not processed further
      END;

     END LOOP; -- tax loop

   END IF;

   v_orgn_id := Null;
   v_locn_id := Null;

   COMMIT; -- commit for every invoice

 END LOOP; -- invoice loop

 if v_some_errors = '1' then
      v_ret_code := '1'; -- signal completion with warnings -- some invoices could not be processed successfully
      ret_code := v_ret_code;
 else
      v_Ret_code := '0' ;-- signal normal completion.
      ret_code := v_ret_code;
 end if;

EXCEPTION
  WHEN OTHERS THEN
       v_sqlerrm  := substr(sqlerrm,1,255);
       errbuf   := v_sqlerrm;
       v_ret_code := 2; -- signal error
       ret_code := v_ret_code;
end generate_ar_forms;


END jai_cmn_st_forms_pkg ;

/
