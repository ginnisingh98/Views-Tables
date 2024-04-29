--------------------------------------------------------
--  DDL for Package Body IGI_CIS2007_IGIPMTHR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS2007_IGIPMTHR_PKG" AS
-- $Header: igipmthrb.pls 120.7.12010000.22 2017/03/01 09:48:48 yanasing ship $

  --==========================================================================
  ----Logging Declarations
  --==========================================================================
  C_STATE_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_STATEMENT;
  C_PROC_LEVEL  CONSTANT  NUMBER     :=  FND_LOG.LEVEL_PROCEDURE;
  C_EVENT_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_EVENT;
  C_EXCEP_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_EXCEPTION;
  C_ERROR_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_ERROR;
  C_UNEXP_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_UNEXPECTED;
  g_log_level   CONSTANT NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_path_name   CONSTANT VARCHAR2(100)  := 'igi.plsql.igipmthrb.IGI_CIS2007_IGIPMTHR_PKG';

  PROCEDURE log
  (
    p_level             IN NUMBER,
    p_procedure_name    IN VARCHAR2,
    p_debug_info        IN VARCHAR2
  )
  IS

  BEGIN
    IF (p_level >= g_log_level ) THEN
      FND_LOG.STRING(p_level, p_procedure_name, p_debug_info);
    END IF;
  END log;

  PROCEDURE init
  IS
    l_procedure_name       VARCHAR2(100) :='.init';
  BEGIN
    log(C_STATE_LEVEL, l_procedure_name, 'Package Information');
    log(C_STATE_LEVEL, l_procedure_name, '$Header: igipmthrb.pls 120.7.12010000.22 2017/03/01 09:48:48 yanasing ship $');
  END;

PROCEDURE Populate_Vendors(p_in_vendor_from IN VARCHAR2,
                                p_in_vendor_to IN VARCHAR2,
                                p_in_period    in varchar2,
                                p_in_start_date in varchar2,
                                p_in_end_date  in varchar2,
                                p_out_no_of_rows out nocopy integer)
   IS
    l_procedure_name         VARCHAR2(100):='.Populate_Vendors';

  -- vendorFrom varchar2(240) := p_in_vendor_from;
  -- vendorTo varchar2(240) := p_in_vendor_to;
   ret_count integer := 0;
   l_start_date date;
   l_end_date date;

 /*  cursor c1 is
   select vendor_id
   from  po_vendors pov
   where pov.cis_enabled_flag = 'Y'
   -- And vendor_type_lookup_code in ('PARTNERSHIP','SOLETRADER','COMPANY','TRUST') bug 5620621
   AND pov.cis_parent_vendor_id is null;*/
   /*AND pov.vendor_id NOT IN
  (SELECT audit_lines.vendor_id
   FROM igi_cis_mth_ret_hdr_h audit_hdr,
     igi_cis_mth_ret_lines_h audit_lines
   WHERE audit_hdr.header_id = audit_lines.header_id
   AND audit_hdr.request_status_code = 'C'
   AND audit_hdr.period_name = p_in_period
   UNION all
   SELECT audit_lines_t.vendor_id
   FROM igi_cis_mth_ret_hdr_t audit_hdr_t,
     igi_cis_mth_ret_lines_t audit_lines_t
   WHERE audit_hdr_t.header_id = audit_lines_t.header_id
   AND audit_hdr_t.request_status_code = 'R'
   AND audit_hdr_t.period_name = p_in_period)
   AND upper(pov.vendor_name)
   between upper(vendorFrom) and upper(vendorTo);*/

  TYPE payment_details_rec IS RECORD (
   child_id    AP_SUPPLIERS.vendor_id%type,
   parent_id   AP_SUPPLIERS.parent_vendor_id%type,
   invoice_id  ap_invoices.invoice_id%type,
   payment_id  ap_invoice_payments.invoice_payment_id%type,
   invoice_payment_amount ap_invoice_payments.amount%type,
   discount_amount ap_invoice_payments.discount_taken%type);

   TYPE all_payments IS TABLE OF payment_details_rec INDEX BY BINARY_INTEGER;
   all_payment_list all_payments;

   --Cursor c2 modified for bug # 6069932
   -- CIS Out Of Scope ER
   cursor c2 is
   SELECT /*+ leading(ACA) */ pov1.vendor_id child_id,
        decode(pov1.cis_parent_vendor_id,null, pov1.vendor_id,
        decode(nvl(pov.cis_enabled_flag,'N'), 'N', pov1.vendor_id,pov1.cis_parent_vendor_id)) parent_id,
        aia.invoice_id invoice_id,
        aipa.invoice_payment_id payment_id,
        aipa.amount invoice_payment_amount,
        aipa.discount_taken discount_amount
    FROM ap_invoices aia,
         ap_invoice_payments aipa,
         ap_checks aca,
         AP_SUPPLIERS pov,
         AP_SUPPLIERS pov1,
         -- Bug 5647413 Start
         ap_supplier_sites pvs
         -- Bug 5647413 End
    WHERE aia.invoice_id = aipa.invoice_id
      AND aca.check_id = aipa.check_id
      AND aca.void_date IS NULL
      And aca.check_number is not null
     -- Bug 5647413 Start
    and pov.vendor_id(+) = pov1.cis_parent_vendor_id
    and pvs.vendor_id = pov1.vendor_id
    and (pov.cis_enabled_flag = 'Y' or pov1.cis_enabled_flag = 'Y')
    and pvs.allow_awt_flag = 'Y'
    and aia.vendor_site_id = pvs.vendor_site_id
    -- Bug 5647413 End
     --AND aia.invoice_type_lookup_code = 'STANDARD'
     AND aia.vendor_id = pov1.vendor_id
    AND trunc(aca.check_date) BETWEEN l_start_date AND l_end_date		/*Added for bug 13028312*/
		    AND EXISTS( select 1 from ap_invoice_distributions aida
	            where aida.invoice_id = aia.invoice_id
	            and (aida.awt_group_id is not null OR aida.pay_awt_group_id is not null));

    --c1_rec_info c1%rowtype;
    --c2_rec_info c2%rowtype;
    l_lab_cost number;
    l_mat_cost number;
    l_awt_amnt number;
    l_temp_pay_amount number;
    l_cis_tax number;
   BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    log(C_STATE_LEVEL, l_procedure_name, 'p_in_vendor_from='||p_in_vendor_from);
    log(C_STATE_LEVEL, l_procedure_name, 'p_in_vendor_to='||p_in_vendor_to);
    log(C_STATE_LEVEL, l_procedure_name, 'p_in_period='||p_in_period);
    log(C_STATE_LEVEL, l_procedure_name, 'p_in_start_date='||p_in_start_date);
    log(C_STATE_LEVEL, l_procedure_name, 'p_in_end_date='||p_in_end_date);

      l_lab_cost := 0;
      l_mat_cost := 0;
      l_awt_amnt := 0;
      l_temp_pay_amount := 0;
      l_start_date := to_date(p_in_start_date, 'DD-MM-YYYY');
      l_end_date := to_date(p_in_end_date,'DD-MM-YYYY');
      delete from IGI_CIS_MTH_RET_PAY_GT;
    /*  if p_in_vendor_from is null then
        select min(vendor_name) , max(vendor_name)
        into vendorFrom,  vendorTo
        From po_vendors;
      end if; */
        open c2;
        fetch c2 bulk collect into all_payment_list;
        close c2;

        for i in 1 .. all_payment_list.count
        loop
            l_temp_pay_amount := all_payment_list(i).invoice_payment_amount;
            log(C_STATE_LEVEL, l_procedure_name, 'l_temp_pay_amount='||l_temp_pay_amount);
            log(C_STATE_LEVEL, l_procedure_name, 'Calling GET_PAYMENT_CIS_DETAILS');
            GET_PAYMENT_CIS_DETAILS(
               all_payment_list(i).payment_id,--C_payments_rec.invoice_payment_id,
               all_payment_list(i).invoice_id,--C_payments_rec.invoice_id,
               l_start_date,--l_start_date,
               l_end_date,--l_end_date,
               l_temp_pay_amount,-- bug 5609552
               --c2_rec_info.invoice_payment_amount,--C_payments_rec.amount,
               all_payment_list(i).discount_amount,--C_payments_rec.discount_taken,
               l_lab_cost,
               l_mat_cost,
               l_awt_amnt,
               l_cis_tax);

            log(C_STATE_LEVEL, l_procedure_name, 'Insertint into IGI_CIS_MTH_RET_PAY_GT');
            log(C_STATE_LEVEL, l_procedure_name, 'VENDOR_ID='||all_payment_list(i).parent_id);
            log(C_STATE_LEVEL, l_procedure_name, 'CHILD_VENDOR_ID='||all_payment_list(i).child_id);
            log(C_STATE_LEVEL, l_procedure_name, 'INVOICE_ID='||all_payment_list(i).invoice_id);
            log(C_STATE_LEVEL, l_procedure_name, 'INVOICE_PAYMENT_ID='||all_payment_list(i).payment_id);
            log(C_STATE_LEVEL, l_procedure_name, 'AMOUNT='||l_temp_pay_amount);
            log(C_STATE_LEVEL, l_procedure_name, 'LABOUR_COST='||l_lab_cost);
            log(C_STATE_LEVEL, l_procedure_name, 'MATERIAL_COST='||l_mat_cost);
            log(C_STATE_LEVEL, l_procedure_name, 'TOTAL_DEDUCTIONS='||l_awt_amnt);
            log(C_STATE_LEVEL, l_procedure_name, 'DISCOUNT_AMOUNT='||all_payment_list(i).discount_amount);
            log(C_STATE_LEVEL, l_procedure_name, 'CIS_TAX='||l_cis_tax);
            insert into IGI_CIS_MTH_RET_PAY_GT(
	    VENDOR_ID,
	    CHILD_VENDOR_ID,
	    INVOICE_ID,
	    INVOICE_PAYMENT_ID,
	    AMOUNT,
            LABOUR_COST,
            MATERIAL_COST,
            TOTAL_DEDUCTIONS,
	    DISCOUNT_AMOUNT,
      CIS_TAX)
            values
            (all_payment_list(i).parent_id,
            all_payment_list(i).child_id,
            all_payment_list(i).invoice_id,
            all_payment_list(i).payment_id,
            --c2_rec_info.invoice_payment_amount,
            l_temp_pay_amount, -- bug 5609552
            l_lab_cost,
            l_mat_cost,
            l_awt_amnt,
	        all_payment_list(i).discount_amount,
                l_cis_tax);
            ret_count := ret_count +1;
         end loop;
         /*insert into IGI_CIS_MTH_RET_PAY_GT
         values
         (c1_rec_info.vendor_id,
          c1_rec_info.vendor_id,
          null,
          null,
          null);*/
       p_out_no_of_rows := ret_count;
    log(C_STATE_LEVEL, l_procedure_name, 'END');
       EXCEPTION
         WHEN OTHERS THEN
    log(C_STATE_LEVEL, l_procedure_name, 'ERROR='||SQLERRM);
/*           IF c1%ISOPEN THEN
               CLOSE c1;
            END IF;*/
           IF c2%ISOPEN THEN
               CLOSE c2;
            END IF;
    log(C_STATE_LEVEL, l_procedure_name, 'END EXCEPTION');
   END Populate_Vendors;

  PROCEDURE GET_PAYMENT_CIS_DETAILS(
     p_inv_pay_id in number, --igi_cis_mth_ret_pay_t.invoice_payment_id%Type,
     p_inv_id in number,
     p_tax_mth_start_date in date,
     p_tax_mth_end_date in date,
     p_pay_amount in out nocopy number, --igi_cis_mth_ret_pay_t.payment_amount%Type,
     p_discount_amount in number,
     p_labour_cost out nocopy number, --igi_cis_mth_ret_pay_t.labour_cost%Type,
     p_material_cost out nocopy number, --igi_cis_mth_ret_pay_t.material_cost%Type,
     p_awt_amount out nocopy number,--igi_cis_mth_ret_pay_t.total_deductions%Type
     p_cis_tax out nocopy number --igi_cis_mth_ret_pay_t.vat_amount%Type,
     )
     IS
    l_procedure_name         VARCHAR2(100):='.GET_PAYMENT_CIS_DETAILS';
     -- Fetch the invoice_amount
     Cursor C_invoice_amount is
     Select invoice_amount invoice_amount
     From ap_invoices
     Where invoice_id = p_inv_id;
     -- Fetch the total labour cost for an invoice.
     Cursor C_labour_cost is
     Select nvl(sum(amount),0) labour_cost
     From ap_invoice_distributions
     where line_type_lookup_code in ('ITEM' , 'ACCRUAL' , 'IPV' , 'ERV' , 'RETAINAGE', 'PREPAY')
--   and awt_group_id is not null
     and IGI_CIS2007_UTIL_PKG.get_payables_option_based_awt(NULL,NULL,awt_group_id,pay_awt_group_id) is not null      /* Bug 7218825 */
     and invoice_id = p_inv_id;
     -- Fetch the total material cost for an invoice.
     Cursor C_material_cost is
     Select nvl(sum(amount),0) material_cost
     From ap_invoice_distributions
     where line_type_lookup_code in ('ITEM' , 'ACCRUAL' , 'IPV' , 'ERV' , 'RETAINAGE', 'PREPAY')
--   and awt_group_id is null
     and IGI_CIS2007_UTIL_PKG.get_payables_option_based_awt(NULL,NULL,awt_group_id,pay_awt_group_id) is null      /* Bug 7218825 */
     and invoice_id = p_inv_id;
     -- Start 5609552
     -- Fetch the total vat cost for an invoice.
     Cursor C_vat_cost is
     Select nvl(sum(amount),0) vat_cost
     From ap_invoice_distributions
--     where line_type_lookup_code = 'TAX'
     where line_type_lookup_code IN ('TAX','REC_TAX','NONREC_TAX','TRV','TERV','TIPV')   -- Bug 8464796
     --and awt_group_id is null
     and IGI_CIS2007_UTIL_PKG.get_payables_option_based_awt(NULL,NULL,awt_group_id,pay_awt_group_id) is null      /* Bug 7218825 */
     and invoice_id = p_inv_id;
     -- End 5609552

     Cursor C_ret_prepay_amt is
     Select nvl(sum(amount),0) ret_prepay_amt
     From ap_invoice_distributions d,
          ap_invoices_all i
     where  ((i.invoice_type_lookup_code NOT IN ('RETAINAGE RELEASE') AND
             d.line_type_lookup_code IN ('RETAINAGE', 'PREPAY')) OR
            (i.invoice_type_lookup_code IN ('RETAINAGE RELEASE') AND
            d.line_type_lookup_code IN ('PREPAY')))
     and i.invoice_id = p_inv_id
     and i.invoice_id = d.invoice_id;

     -- Find out the number of Witholding lines for the invoice payment
     Cursor C_pay_awt_lines_count is
     Select count(*) line_count
     From ap_invoice_distributions
     where line_type_lookup_code = 'AWT'
     and invoice_id = p_inv_id
     and awt_invoice_payment_id = p_inv_pay_id;
     -- Find out the number of Witholding lines for the tax period.
     -- If the payables options is set to Apply Withholding Tax
     -- at Invoice Validation Time, the AWT Tax line(s) generated on
     -- invoice validation are never linked to the invoice payment.
     Cursor C_inv_awt_lines_count is
     Select count(*) line_count
     From ap_invoice_distributions
     where line_type_lookup_code = 'AWT'
     and invoice_id = p_inv_id
     and awt_invoice_payment_id is null;
     -- This condition is requried to select only the withholding tax lines
     -- for the tax period
    -- and trunc(accounting_date) between trunc(p_tax_mth_start_date)
    -- and trunc(p_tax_mth_end_date);
     -- Fetch the withholding tax amount generated for the
     -- invoice payment.
     -- If the payables options is set to Apply Withholding Tax
     -- at Payment Time, the AWT Tax line(s) generated on payment
     -- are always linked to the invoice payment.
     Cursor C_pay_awt_amount is
     Select nvl(sum(amount),0) awt_amount
     From ap_invoice_distributions
     where line_type_lookup_code = 'AWT'
     and invoice_id = p_inv_id
     and awt_invoice_payment_id = p_inv_pay_id;
     -- Fetch the withholding tax amount generated for the invoice.
     -- If the payables options is set to Apply Withholding Tax
     -- at Invoice Validation Time, the AWT Tax line(s) generated on
     -- invoice validation are never linked to the invoice payment.
     Cursor C_inv_awt_amount is
     Select nvl(sum(amount),0) awt_amount
     From ap_invoice_distributions
     where line_type_lookup_code = 'AWT'
     and invoice_id = p_inv_id
     and awt_invoice_payment_id is null;
     -- This condition is requried to select only the withholding tax lines
     -- for the tax period
    -- and trunc(accounting_date) between trunc(p_tax_mth_start_date)
    -- and trunc(p_tax_mth_end_date);
     -- Define local variables
     --Calculating the cis related tax amounts
     -- when the WHT is applied at the payment level
    Cursor C_pay_cis_tax is
     Select nvl(sum(amount),0) awt_amount
     From ap_invoice_distributions a
     where line_type_lookup_code = 'AWT'
     and invoice_id = p_inv_id
     and awt_invoice_payment_id = p_inv_pay_id
     and exists ( SELECT /*+ no_unneset */ 1 from
               AP_AWT_TAX_RATES_ALL b
               WHERE a.AWT_TAX_RATE_ID=b.tax_rate_id
               and exists  ( SELECT  /*+ no_unneset */ 1 from
               aP_TAX_CODES_ALL c
               WHERE b.TAX_NAME=c.NAME and c.AWT_VENDOR_ID = FND_PROFILE.VALUE
 ( 'IGI_CIS2007_TAX_AUTHORITY' ) ) ) ;
    --when the WHT is applied at the invoice validation level
        Cursor C_inv_cis_tax is
     Select nvl(sum(amount),0) awt_amount
     From ap_invoice_distributions a
     where line_type_lookup_code = 'AWT'
     and invoice_id = p_inv_id
     and awt_invoice_payment_id is null
      and exists ( SELECT /*+ no_unneset */ 1 from
               AP_AWT_TAX_RATES_ALL b
               WHERE a.AWT_TAX_RATE_ID=b.tax_rate_id
               and exists  ( SELECT  /*+ no_unneset */ 1 from
               aP_TAX_CODES_ALL c
               WHERE b.TAX_NAME=c.NAME and c.AWT_VENDOR_ID = FND_PROFILE.VALUE
 ( 'IGI_CIS2007_TAX_AUTHORITY' ) ) ) ;
     l_inv_amount number;
     l_inv_labour_amount number; --igi_cis_mth_ret_pay_t.labour_cost%Type;
     l_inv_material_amount number; --igi_cis_mth_ret_pay_t.material_cost%Type;
     l_awt_amount number; --igi_cis_mth_ret_pay_t.total_deductions%Type;
     l_material_amount number; --igi_cis_mth_ret_pay_t.material_cost%Type;
     l_labour_amount number; --igi_cis_mth_ret_pay_t.labour_cost%Type;
     -- Start 5609552
     l_vat_amount number; ---bug fix for 5609552
     l_inv_vat_amount number; ---bug fix for 5609552
     -- End 5609552
     l_pay_awt_lines_count number;
     l_inv_awt_lines_count number;
     l_cis_tax number;
     l_ret_prepay_amount number;
  Begin
    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    log(C_STATE_LEVEL, l_procedure_name, 'p_inv_pay_id='||p_inv_pay_id);
    log(C_STATE_LEVEL, l_procedure_name, 'p_inv_id='||p_inv_id);
    log(C_STATE_LEVEL, l_procedure_name, 'p_tax_mth_start_date='||p_tax_mth_start_date);
    log(C_STATE_LEVEL, l_procedure_name, 'p_tax_mth_end_date='||p_tax_mth_end_date);
    log(C_STATE_LEVEL, l_procedure_name, 'p_pay_amount='||p_pay_amount);
    log(C_STATE_LEVEL, l_procedure_name, 'p_discount_amount='||p_discount_amount);
    log(C_STATE_LEVEL, l_procedure_name, 'p_inv_pay_id='||p_inv_pay_id);
    log(C_STATE_LEVEL, l_procedure_name, 'p_inv_pay_id='||p_inv_pay_id);
    log(C_STATE_LEVEL, l_procedure_name, 'p_inv_pay_id='||p_inv_pay_id);

     -- Initialise local variables
     l_inv_amount := 0;
     l_inv_labour_amount := 0;
     l_inv_material_amount := 0;
     l_awt_amount := 0;
     l_material_amount := 0;
     l_labour_amount := 0;
     -- Start 5609552
     l_vat_amount := 0;
     l_inv_vat_amount := 0;
    l_cis_tax := 0;
    l_ret_prepay_amount := 0;
     -- End 5609552
     -- Fetch the invoice amount
     For C_invoice_amount_rec in  C_invoice_amount Loop
        l_inv_amount :=  C_invoice_amount_rec.invoice_amount;
     End Loop;
    log(C_STATE_LEVEL, l_procedure_name, 'l_inv_amount='||l_inv_amount);
     -- Fetch the total labour cost for an invoice.
     For C_labour_cost_rec in C_labour_cost Loop
        l_inv_labour_amount := C_labour_cost_rec.labour_cost;
     End Loop;
    log(C_STATE_LEVEL, l_procedure_name, 'l_inv_labour_amount='||l_inv_labour_amount);
     -- Fetch the total material cost for an invoice.
     For C_material_cost_rec in C_material_cost Loop
        l_inv_material_amount := C_material_cost_rec.material_cost;
     End Loop;
    log(C_STATE_LEVEL, l_procedure_name, 'l_inv_material_amount='||l_inv_material_amount);
     -- Start 5609552
     -- Fetch the vat cost for an invoice.
     For C_vat_cost_rec in C_vat_cost Loop
        l_inv_vat_amount := C_vat_cost_rec.vat_cost;
     End Loop;
    log(C_STATE_LEVEL, l_procedure_name, 'l_inv_vat_amount='||l_inv_vat_amount);
     -- End 5609552

     For C_ret_prepay_rec in C_ret_prepay_amt Loop
        l_ret_prepay_amount := -1*C_ret_prepay_rec.ret_prepay_amt;
     End Loop;
    log(C_STATE_LEVEL, l_procedure_name, 'l_ret_prepay_amount='||l_ret_prepay_amount);

     -- Find out the number of Witholding lines generated for the
     --  invoice payment
     For C_pay_awt_lines_count_rec in C_pay_awt_lines_count Loop
        l_pay_awt_lines_count := C_pay_awt_lines_count_rec.line_count;
     End Loop;
    log(C_STATE_LEVEL, l_procedure_name, 'l_pay_awt_lines_count='||l_pay_awt_lines_count);
     -- Find out the number of Witholding lines generated for the
     -- tax period.
     -- If the payables options is set to Apply Withholding Tax
     -- at Invoice Validation Time, the AWT Tax line(s) generated on
     -- invoice validation are never linked to the invoice payment.
     For C_inv_awt_lines_count_rec in C_inv_awt_lines_count Loop
        l_inv_awt_lines_count := C_inv_awt_lines_count_rec.line_count;
     End Loop;
    log(C_STATE_LEVEL, l_procedure_name, 'l_inv_awt_lines_count='||l_inv_awt_lines_count);
     -- If no witholding tax lines are found at all
     If l_pay_awt_lines_count = 0 and l_inv_awt_lines_count = 0 Then
        log(C_STATE_LEVEL, l_procedure_name, 'l_pay_awt_lines_count and l_inv_awt_lines_count are 0');
        l_awt_amount := 0;
        If ((p_pay_amount + p_discount_amount + l_ret_prepay_amount) < l_inv_amount) Then
           log(C_STATE_LEVEL, l_procedure_name, 'partial payment logic');
           -- It's a partial payment
           l_labour_amount := ((l_inv_labour_amount/l_inv_amount) *
                                (p_pay_amount + p_discount_amount));
           l_material_amount := ((l_inv_material_amount/l_inv_amount) *
                                (p_pay_amount + p_discount_amount));
           -- Start 5609552
           l_vat_amount := ((l_inv_vat_amount/l_inv_amount) *
                            (p_pay_amount + p_discount_amount));
           -- End 5609552
           log(C_STATE_LEVEL, l_procedure_name, 'l_labour_amount='||l_labour_amount);
           log(C_STATE_LEVEL, l_procedure_name, 'l_material_amount='||l_material_amount);
           log(C_STATE_LEVEL, l_procedure_name, 'l_vat_amount='||l_vat_amount);
        Else
           log(C_STATE_LEVEL, l_procedure_name, 'full payment logic');
           -- It's a full payment
           IF (NVL(p_discount_amount,0) = 0) THEN
             log(C_STATE_LEVEL, l_procedure_name, 'No Discount');
             l_labour_amount := l_inv_labour_amount;
             l_material_amount := l_inv_material_amount;
             l_vat_amount := l_inv_vat_amount; -- bug 5609552
           ELSE
             log(C_STATE_LEVEL, l_procedure_name, 'Consider Discount');
             l_labour_amount := l_inv_labour_amount - (l_inv_labour_amount*p_discount_amount)/(l_inv_labour_amount+l_inv_material_amount+l_inv_vat_amount);
             l_material_amount := l_inv_material_amount - (l_inv_material_amount*p_discount_amount)/(l_inv_labour_amount+l_inv_material_amount+l_inv_vat_amount);
             l_vat_amount := l_inv_vat_amount - (l_inv_vat_amount*p_discount_amount)/(l_inv_labour_amount+l_inv_material_amount+l_inv_vat_amount);
           END IF;
           log(C_STATE_LEVEL, l_procedure_name, 'l_labour_amount='||l_labour_amount);
           log(C_STATE_LEVEL, l_procedure_name, 'l_material_amount='||l_material_amount);
           log(C_STATE_LEVEL, l_procedure_name, 'l_vat_amount='||l_vat_amount);
        End If;
     Else
        log(C_STATE_LEVEL, l_procedure_name, 'there are withholding tax lines');
        -- Witholding tax lines are found
        -- Witholding tax lines can either be associated with the invoice
        -- payment or not
        If l_pay_awt_lines_count > 0 Then
          log(C_STATE_LEVEL, l_procedure_name, 'l_pay_awt_lines_count is > 0');
          -- Fetch the withholding tax amount generated for the
          -- invoice payment.
          -- Applicable only if the payables options is set to Apply
          -- Withholding Tax at Payment Time
           For C_pay_awt_amount_rec in C_pay_awt_amount Loop
              -- Fetch Withholding Tax Amount
              -- No need to proportion this since this is already done
              -- by the Payables AWT Tax Engine
              l_awt_amount :=  - C_pay_awt_amount_rec.awt_amount ;
              For C_pay_cis_tax_rec in C_pay_cis_tax Loop
                l_cis_tax :=  - C_pay_cis_tax_rec.awt_amount ;
              end loop;
           End Loop;
           log(C_STATE_LEVEL, l_procedure_name, 'l_awt_amount='||l_awt_amount);
           log(C_STATE_LEVEL, l_procedure_name, 'l_cis_tax='||l_cis_tax);
           -- Check if it is partial or full payment
           If ((p_pay_amount + l_awt_amount + p_discount_amount + l_ret_prepay_amount) < l_inv_amount) Then
             log(C_STATE_LEVEL, l_procedure_name, 'partial payment logic');
              -- it's a partial payment.
              -- Compute the proportionate Labour Cost
              l_labour_amount := ((l_inv_labour_amount / l_inv_amount) *
                 ( p_pay_amount + l_awt_amount + p_discount_amount));
              -- Compute the proportionate Material Cost
              l_material_amount := ((l_inv_material_amount / l_inv_amount) *
                 (p_pay_amount + l_awt_amount + p_discount_amount));
              -- compute the proportionate vat cost bug 5609552
              -- Start 5609552
              l_vat_amount := ((l_inv_vat_amount/l_inv_amount) *
                 (p_pay_amount + l_awt_amount + p_discount_amount));
              -- End 5609552
             log(C_STATE_LEVEL, l_procedure_name, 'l_labour_amount='||l_labour_amount);
             log(C_STATE_LEVEL, l_procedure_name, 'l_material_amount='||l_material_amount);
             log(C_STATE_LEVEL, l_procedure_name, 'l_vat_amount='||l_vat_amount);
           Else
             log(C_STATE_LEVEL, l_procedure_name, 'full payment logic');
              -- it's a full payment or overpayment.
             IF (NVL(p_discount_amount,0) = 0) THEN
               log(C_STATE_LEVEL, l_procedure_name, 'No Discount');
               l_labour_amount := l_inv_labour_amount;
               l_material_amount := l_inv_material_amount;
               l_vat_amount := l_inv_vat_amount; -- bug 5609552
             ELSE
               log(C_STATE_LEVEL, l_procedure_name, 'Consider Discount');
               l_labour_amount := l_inv_labour_amount - (l_inv_labour_amount*p_discount_amount)/(l_inv_labour_amount+l_inv_material_amount+l_inv_vat_amount);
               l_material_amount := l_inv_material_amount - (l_inv_material_amount*p_discount_amount)/(l_inv_labour_amount+l_inv_material_amount+l_inv_vat_amount);
               l_vat_amount := l_inv_vat_amount - (l_inv_vat_amount*p_discount_amount)/(l_inv_labour_amount+l_inv_material_amount+l_inv_vat_amount);
             END IF;
             log(C_STATE_LEVEL, l_procedure_name, 'l_labour_amount='||l_labour_amount);
             log(C_STATE_LEVEL, l_procedure_name, 'l_material_amount='||l_material_amount);
             log(C_STATE_LEVEL, l_procedure_name, 'l_vat_amount='||l_vat_amount);
           End If;
        Else
          log(C_STATE_LEVEL, l_procedure_name, 'l_pay_awt_lines_count is not > 0');
           -- Compute the proportionate Withholding tax, Labour cost
           -- and Material cost for the invoice payment.
           -- Applicable only if the payables options is set to Apply
           -- Withholding Tax at Invoice Validation Time
           For C_inv_awt_amount_rec in C_inv_awt_amount Loop
             l_awt_amount :=  - C_inv_awt_amount_rec.awt_amount ;
              For C_inv_cis_tax_rec in C_inv_cis_tax Loop
                l_cis_tax :=   -C_inv_cis_tax_rec.awt_amount ;
              End Loop;
           End Loop;
           log(C_STATE_LEVEL, l_procedure_name, 'l_awt_amount='||l_awt_amount);
           log(C_STATE_LEVEL, l_procedure_name, 'l_cis_tax='||l_cis_tax);
           -- Check if it is partial or full payment
           If ((p_pay_amount + l_awt_amount + p_discount_amount + l_ret_prepay_amount) < l_inv_amount) Then
              log(C_STATE_LEVEL, l_procedure_name, 'partial payment logic');
              -- it's a part payment.
              -- compute the proportionate awt first.
              l_awt_amount := ((l_awt_amount/(l_inv_amount-l_awt_amount)) *
                 (p_pay_amount + p_discount_amount));

             log(C_STATE_LEVEL, l_procedure_name, 'l_awt_amount='||l_awt_amount);
              l_cis_tax :=  ((l_cis_tax/(l_inv_amount-l_awt_amount)) *
                 (p_pay_amount + p_discount_amount));
             log(C_STATE_LEVEL, l_procedure_name, 'l_cis_tax='||l_cis_tax);

              -- Compute the proportionate Labour Cost using the awt calculated
              -- in the previous step.
              l_labour_amount := ((l_inv_labour_amount / l_inv_amount) *
                 (p_pay_amount + p_discount_amount + l_awt_amount));
              -- Compute the proportionate Material Cost
              l_material_amount := ((l_inv_material_amount / l_inv_amount) *
                 (p_pay_amount + p_discount_amount + l_awt_amount));
              -- compute the proportionate vat cost bug 5609552
              -- Start 5609552
              l_vat_amount := ((l_inv_vat_amount/l_inv_amount) *
                 (p_pay_amount + l_awt_amount + p_discount_amount));
              -- End 5609552
              -- discarded the old way of computation.
              /*-- Compute the proportionate Withholding Tax Amount
              -- Need to proportionate this since this is not done by
              -- by the Payables AWT Tax Engine
              l_awt_amount := ((l_labour_amount  / l_inv_labour_amount) *
                 l_awt_amount );*/
             log(C_STATE_LEVEL, l_procedure_name, 'l_labour_amount='||l_labour_amount);
             log(C_STATE_LEVEL, l_procedure_name, 'l_material_amount='||l_material_amount);
             log(C_STATE_LEVEL, l_procedure_name, 'l_vat_amount='||l_vat_amount);
            Else
             log(C_STATE_LEVEL, l_procedure_name, 'full payment logic');
              -- it's a full payment or overpayment.
             IF (NVL(p_discount_amount,0) = 0) THEN
               log(C_STATE_LEVEL, l_procedure_name, 'No Discount');
               l_labour_amount := l_inv_labour_amount;
               l_material_amount := l_inv_material_amount;
               l_vat_amount := l_inv_vat_amount; -- bug 5609552
             ELSE
               log(C_STATE_LEVEL, l_procedure_name, 'Consider Discount');
               l_labour_amount := l_inv_labour_amount - (l_inv_labour_amount*p_discount_amount)/(l_inv_labour_amount+l_inv_material_amount+l_inv_vat_amount);
               l_material_amount := l_inv_material_amount - (l_inv_material_amount*p_discount_amount)/(l_inv_labour_amount+l_inv_material_amount+l_inv_vat_amount);
               l_vat_amount := l_inv_vat_amount - (l_inv_vat_amount*p_discount_amount)/(l_inv_labour_amount+l_inv_material_amount+l_inv_vat_amount);
             END IF;
             log(C_STATE_LEVEL, l_procedure_name, 'l_labour_amount='||l_labour_amount);
             log(C_STATE_LEVEL, l_procedure_name, 'l_material_amount='||l_material_amount);
             log(C_STATE_LEVEL, l_procedure_name, 'l_vat_amount='||l_vat_amount);
           End If;
        End If;
     End If;
     log(C_STATE_LEVEL, l_procedure_name, 'Finally');
     log(C_STATE_LEVEL, l_procedure_name, 'l_labour_amount='||l_labour_amount);
     log(C_STATE_LEVEL, l_procedure_name, 'l_material_amount='||l_material_amount);
     log(C_STATE_LEVEL, l_procedure_name, 'l_vat_amount='||l_vat_amount);
     p_labour_cost := round(l_labour_amount,2);
     p_material_cost := round(l_material_amount,2);
     p_awt_amount := round(l_awt_amount,2);
     p_cis_tax := round(l_cis_tax,2);
    -- Start 5609552
     p_pay_amount := round((p_pay_amount - l_vat_amount),2);
     log(C_STATE_LEVEL, l_procedure_name, 'p_labour_cost='||p_labour_cost);
     log(C_STATE_LEVEL, l_procedure_name, 'p_material_cost='||p_material_cost);
     log(C_STATE_LEVEL, l_procedure_name, 'p_awt_amount='||p_awt_amount);
     log(C_STATE_LEVEL, l_procedure_name, 'p_cis_tax='||p_cis_tax);
     log(C_STATE_LEVEL, l_procedure_name, 'p_pay_amount='||p_pay_amount);
    --- End 5609552
    log(C_STATE_LEVEL, l_procedure_name, 'END');

  Exception
     When Others Then
     log(C_STATE_LEVEL, l_procedure_name, 'ERROR='||SQLERRM);
        --dbms_output.put_line('Error in processing ' || sqlerrm);
	p_labour_cost := -1;
	p_material_cost := -1;
	p_awt_amount := -1;
  p_cis_tax := -1;
    log(C_STATE_LEVEL, l_procedure_name, 'END EXCEPTION');
  End Get_Payment_CIS_Details;
  --
  -- Procedure for 11.5.8 which will only populate history table
  -- Modified for ER6137652
   Procedure POPULATE_MTH_RET_DETAILS(
      errbuf OUT NOCOPY VARCHAR2,
      retcode OUT NOCOPY NUMBER,
      p_nil_return_flag IN varchar2,
      p_info_crct_flag IN varchar2,
      p_subcont_verify_flag IN varchar2,
      p_emp_status_flag IN varchar2,
      p_inact_indicat_flag IN varchar2,
      p_period_name IN varchar2,
      p_mth_ret_mode IN varchar2,
      p_mth_ret_amt_type IN varchar2,
      p_mth_report_template IN varchar2,
      p_mth_report_format IN varchar2,
      p_mth_sort_by IN varchar2)
      is
    l_procedure_name         VARCHAR2(100):='.POPULATE_MTH_RET_DETAILS';
         -- get all the payments info
      /*cursor C_pay_info is
      select vendor_id, child_vendor_id, invoice_id,
      invoice_payment_id, amount, labour_cost, material_cost,
      total_deductions, discount_amount from igi_cis_mth_ret_pay_gt;*/
      -- get the reporting entity information
      Cursor C_rep_entity is
      Select UNIQUE_TAX_REFERENCE_NUM,ACCOUNTS_OFFICE_REFERENCE,
      TAX_OFFICE_NUMBER,PAYE_REFERENCE,fnd_profile.value('ORG_ID') ORG_ID,
      CIS_SENDER_ID
      From AP_REPORTING_ENTITIES
      Where UNIQUE_TAX_REFERENCE_NUM is not null;
      Cursor C_prev_return is
      select nvl(sum(decode(X.nil_return_flag,'Y',1,0)),0) nil_ret_count,
      nvl(sum(decode(X.nil_return_flag,'N',1,0)),0) non_nil_ret_count
      from
      (Select hdr_h.Nil_return_flag nil_return_flag
      from IGI_CIS_MTH_RET_HDR_H hdr_h
      where hdr_h.period_name = p_period_name
      and hdr_h.request_status_code = 'C') X;

      -- Group the payments according to parent subcontractors
      Cursor C_non_nil_ret_lines_info is
      select --:org_id ORG_ID,:header_id HEADER_ID,
      pov.vendor_id VENDOR_ID,
      -- Commented for bug 5671997 and add decode to get partnership name in case BT= partnership
      --pov.vendor_name VENDOR_NAME,
      decode(pov.vendor_type_lookup_code,'PARTNERSHIP',pov.partnership_name,pov.vendor_name) VENDOR_NAME,
      pov.vendor_type_lookup_code VENDOR_TYPE_LOOKUP_CODE,
      pov.first_name FIRST_NAME,
      pov.second_name SECOND_NAME,
      pov.last_name LAST_NAME,
      pov.salutation SALUTATION,
      pov.trading_name TRADING_NAME,
      pov.match_status_flag UNMATCHED_TAX_FLAG,
      --pov.unique_tax_reference_num UNIQUE_TAX_REFERENCE_NUM,
      decode(pov.vendor_type_lookup_code,'PARTNERSHIP',pov.partnership_utr,
                                         pov.unique_tax_reference_num)
                                         UNIQUE_TAX_REFERENCE_NUM,
      pov.company_registration_number COMPANY_REGISTRATION_NUMBER,
      pov.national_insurance_number NATIONAL_INSURANCE_NUMBER,
      pov.verification_number VERIFICATION_NUMBER,
      sum(nvl(pay.amount, 0)) TOTAL_PAYMENTS,
      sum(nvl(pay.TOTAL_DEDUCTIONS, 0)) TOTAL_DEDUCTIONS,
      sum(nvl(pay.MATERIAL_COST, 0)) MATERIAL_COST,
      sum(nvl(pay.LABOUR_COST, 0)) LABOUR_COST,
      sum(nvl(pay.DISCOUNT_AMOUNT, 0)) DISCOUNT_AMOUNT,
      sum(nvl(pay.CIS_TAX,0)) CIS_TAX
      from AP_SUPPLIERS pov, IGI_CIS_MTH_RET_PAY_GT pay
      where pov.vendor_id = pay.vendor_id
      group by pov.vendor_id,
      -- Commented for bug 5671997 and add decode to get partnership name in case BT= partnership
      -- pov.vendor_name,
      decode(pov.vendor_type_lookup_code,'PARTNERSHIP',pov.partnership_name,pov.vendor_name),
      pov.vendor_type_lookup_code,
      pov.first_name,
      pov.second_name,
      pov.last_name,
      pov.salutation,
      pov.trading_name,
      pov.match_status_flag,
      --pov.unique_tax_reference_num,
      decode(pov.vendor_type_lookup_code,'PARTNERSHIP',pov.partnership_utr,
                                         pov.unique_tax_reference_num),
      pov.company_registration_number,
      pov.national_insurance_number,
      pov.verification_number
      order by upper(VENDOR_NAME) asc;

      -- nil ret lines info
      Cursor C_nil_ret_lines_info is
      Select vendors.vendor_id VENDOR_ID,
      -- Commented for bug 5671997 and add decode to get partnership name in case BT= partnership
      -- vendors.vendor_name VENDOR_NAME,
      decode(vendors.vendor_type_lookup_code,'PARTNERSHIP',vendors.partnership_name,vendors.vendor_name) VENDOR_NAME,
      vendors.vendor_type_lookup_code VENDOR_TYPE_LOOKUP_CODE,
      vendors.first_name FIRST_NAME,
      vendors.second_name SECOND_NAME,
      vendors.last_name LAST_NAME,
      vendors.salutation SALUTATION,
      vendors.trading_name TRADING_NAME,
      vendors.match_status_flag UNMATCHED_TAX_FLAG,
      --vendors.unique_tax_reference_num UNIQUE_TAX_REFERENCE_NUM,
      decode(vendors.vendor_type_lookup_code,'PARTNERSHIP',vendors.partnership_utr,
                                         vendors.unique_tax_reference_num)
                                         UNIQUE_TAX_REFERENCE_NUM,
      vendors.company_registration_number COMPANY_REGISTRATION_NUMBER,
      vendors.national_insurance_number NATIONAL_INSURANCE_NUMBER,
      vendors.verification_number VERIFICATION_NUMBER,
      0 TOTAL_PAYMENTS,
      0 TOTAL_DEDUCTIONS,
      0 MATERIAL_COST,
      0 LABOUR_COST,
      0 DISCOUNT_AMOUNT,
      0 CIS_TAX
      from  AP_SUPPLIERS vendors
      where vendors.cis_enabled_flag = 'Y'
      --And vendor_type_lookup_code in ('PARTNERSHIP','SOLETRADER','COMPANY','TRUST') bug 5620621
      and vendors.cis_parent_vendor_id is null
      order by upper(VENDOR_NAME) asc;
      --

--Fix 5743166

      Cursor C_period_validator is
      select count(1) period_allowed
      From AP_OTHER_PERIODS aop,
     (SELECT decode(SIGN(to_number(to_char(sysdate,   'DD')) -6),   -1,   add_months(to_date(('05-' || to_char(sysdate,   'MM-YYYY')),   'DD-MM-YYYY'),   3),
     add_months(to_date(('05-' || to_char(sysdate,   'MM-YYYY')),'DD-MM-YYYY'), 4)) end_date_criteria  from dual) temp
     where aop.period_type =
     fnd_profile.value('IGI_CIS2007_CALENDAR')
     and aop.period_year <= 2099
     and aop.end_date between to_date('05-05-2007',    'DD-MM-YYYY')
     AND
     temp.end_date_criteria
     and period_name = p_period_name;

--Fix 5743166
    ---
      -- local variables declaration
      --
      l_pay_count number;
      l_period_allowed number;
      l_nil_ret_count number;
      l_non_nil_ret_count number;
      l_header_id number;
      l_org_id number;
      l_period_start_date date;
      l_period_end_date date;
      e_validation_exception Exception;
      l_err_all_msg varchar2(1000);
      l_err_msg varchar2(500);
      l_err_count number;
      l_rep_ent_exist number;
      -- particulars to call deduction report
      l_request_id number;
      l_appln_name  varchar2(10) := 'IGI';
      l_con_cp      varchar2(15) := 'IGIPMTHR_XMLP';
      l_con_cp_desc varchar2(200) := 'IGI : CIS2007 Monthly Returns Report';
      e_request_submit_error exception;
      l_xml_layout boolean;
      -- variables after design change
      l_prelim_count number;
      l_prelim_hdr_id number;
      e_param_mismatch_error exception;
      e_prelim_mand_error exception;
      e_rep_ent_not_found_error exception;
      l_latest_version NUMBER:=1;

    Begin
      l_procedure_name := g_path_name || l_procedure_name;
      log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
      log(C_STATE_LEVEL, l_procedure_name, 'p_nil_return_flag='||p_nil_return_flag);
      log(C_STATE_LEVEL, l_procedure_name, 'p_info_crct_flag='||p_info_crct_flag);
      log(C_STATE_LEVEL, l_procedure_name, 'p_subcont_verify_flag='||p_subcont_verify_flag);
      log(C_STATE_LEVEL, l_procedure_name, 'p_emp_status_flag='||p_emp_status_flag);
      log(C_STATE_LEVEL, l_procedure_name, 'p_inact_indicat_flag='||p_inact_indicat_flag);
      log(C_STATE_LEVEL, l_procedure_name, 'p_period_name='||p_period_name);
      log(C_STATE_LEVEL, l_procedure_name, 'p_mth_ret_mode='||p_mth_ret_mode);
      log(C_STATE_LEVEL, l_procedure_name, 'p_mth_ret_amt_type='||p_mth_ret_amt_type);
      log(C_STATE_LEVEL, l_procedure_name, 'p_mth_report_template='||p_mth_report_template);
      log(C_STATE_LEVEL, l_procedure_name, 'p_mth_report_format='||p_mth_report_format);
      log(C_STATE_LEVEL, l_procedure_name, 'p_mth_sort_by='||p_mth_sort_by);
      log(C_STATE_LEVEL, l_procedure_name, 'l_latest_version='||l_latest_version);

    FND_FILE.PUT_LINE(FND_FILE.LOG,'*********** l_latest_version -> '|| l_latest_version);

      l_period_allowed := 0;
      l_pay_count := 0;
      l_header_id := 0;
      l_org_id := 0;
      l_nil_ret_count := 0;
      l_non_nil_ret_count := 0;
      l_err_msg := '';
      l_err_all_msg := '';
      l_err_count := 0;
      l_prelim_count := 0;
      l_rep_ent_exist := 0;

      -- information correct has to be 'Yes'.
        if p_info_crct_flag = 'N' then
          FND_MESSAGE.SET_NAME('IGI','IGI_CIS2007_SUB_VER_MAND_CP');
          l_err_msg := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_err_msg);
          l_err_all_msg := l_err_all_msg ||' '|| l_err_msg;
          l_err_count := l_err_count + 1;
        end if;
        -- Subcontractor verification is mandatory
        if p_nil_return_flag = 'N' and p_subcont_verify_flag is null then
          FND_MESSAGE.SET_NAME('IGI','IGI_CIS2007_SUB_VER_MAND_CP');
          l_err_msg := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_err_msg);
          l_err_all_msg := l_err_all_msg ||' '|| l_err_msg;
          l_err_count := l_err_count + 1;
        end if;
        -- Employment Status declaration is mandatory
        if p_nil_return_flag = 'N' and p_emp_status_flag is null then
          FND_MESSAGE.SET_NAME('IGI','IGI_CIS2007_EMP_STAT_MAND_CP');
          l_err_msg := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_err_msg);
          l_err_all_msg := l_err_all_msg ||' '|| l_err_msg;
          l_err_count := l_err_count + 1;
          --IGI_CIS2007_EMP_STAT_MAND_CP
        end if;

        if l_err_count > 0 then
          raise e_validation_exception;
        end if;
        --
        -- verify if Period is beyond 3 future months.
        --
        For C_period_validator_rec in C_period_validator loop
          l_period_allowed := C_period_validator_rec.period_allowed;
          log(C_STATE_LEVEL, l_procedure_name, 'l_period_allowed='||l_period_allowed);
        End loop;

        if l_period_allowed = 0 then
          FND_MESSAGE.SET_NAME('IGI','IGI_CIS2007_MTH_RET_NA');
          FND_MESSAGE.SET_TOKEN('PERIOD', p_period_name);
          l_err_msg := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_err_msg);
          l_err_all_msg := l_err_all_msg ||' '|| l_err_msg;
          raise e_validation_exception;
        End if;

        -- get the start_date and end_date from ap_other_periods
        select start_date,end_date
        into l_period_start_date,l_period_end_date
        from ap_other_periods
        where period_type = fnd_profile.value('IGI_CIS2007_CALENDAR')
        and period_name = p_period_name;

        log(C_STATE_LEVEL, l_procedure_name, 'l_period_start_date='||l_period_start_date);
        log(C_STATE_LEVEL, l_procedure_name, 'l_period_end_date='||l_period_end_date);

        -- Throw error if there is a nil return already.
        For C_prev_return_rec in C_prev_return loop
          l_nil_ret_count := C_prev_return_rec.nil_ret_count;
          l_non_nil_ret_count := C_prev_return_rec.non_nil_ret_count;
          log(C_STATE_LEVEL, l_procedure_name, 'l_nil_ret_count='||l_nil_ret_count);
          log(C_STATE_LEVEL, l_procedure_name, 'l_non_nil_ret_count='||l_non_nil_ret_count);
        End loop;
        If l_nil_ret_count > 0 then
          FND_MESSAGE.SET_NAME('IGI','IGI_CIS2007_NIL_RET_EXISTS');
          FND_MESSAGE.SET_TOKEN('PERIOD_NAME', p_period_name);
          l_err_msg := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_err_msg);
          l_err_all_msg := l_err_all_msg ||' '|| l_err_msg;
          raise e_validation_exception;
        End if;
        --
        -- Throw error if there is a Non nil return already.
        --
        If l_non_nil_ret_count > 0 then
          FND_MESSAGE.SET_NAME('IGI','IGI_CIS2007_MTH_RET_EXISTS');
          FND_MESSAGE.SET_TOKEN('PERIOD_NAME', p_period_name);
          l_err_msg := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_err_msg);
          l_err_all_msg := l_err_all_msg ||' '|| l_err_msg;
          raise e_validation_exception;
        End if;
        -- Procedure call to calculate the payments
        log(C_STATE_LEVEL, l_procedure_name, 'Calling igi_cis2007_igipmthr_pkg.Populate_Vendors');
        igi_cis2007_igipmthr_pkg.Populate_Vendors(null, --p_in_vendor_from IN VARCHAR2,
                         null, --p_in_vendor_to IN VARCHAR2,
                         p_period_name, -- p_in_period    in varchar2,
                         to_char(l_period_start_date,'DD-MM-YYYY'),--p_in_start_date in varchar2,
                         to_char(l_period_end_date,'DD-MM-YYYY'),--p_in_end_date  in varchar2,
                         l_pay_count--p_out_no_of_rows out nocopy integer
                         );
          log(C_STATE_LEVEL, l_procedure_name, 'l_pay_count='||l_pay_count);
        --
        -- throw error if there are payments for nil return
        --
        if l_pay_count > 0 and p_nil_return_flag = 'Y' then
          FND_MESSAGE.SET_NAME('IGI','IGI_CIS2007_VENDORS_PAID');
          FND_MESSAGE.SET_TOKEN('PERIOD', p_period_name);
          l_err_msg := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_err_msg);
          l_err_all_msg := l_err_all_msg ||' '|| l_err_msg;
          raise e_validation_exception;
        end if;
        --
        -- throw error if there are no payments for non-nil return
        --
        if l_pay_count = 0 and p_nil_return_flag = 'N' then
          FND_MESSAGE.SET_NAME('IGI','IGI_CIS2007_NO_VENDORS_PAID');
          FND_MESSAGE.SET_TOKEN('PERIOD', p_period_name);
          l_err_msg := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_err_msg);
          l_err_all_msg := l_err_all_msg ||' '|| l_err_msg;
          raise e_validation_exception;
        end if;
        --
        -- get the next header id
        --
        SELECT IGI_CIS_MTH_RET_HDR_T_S.nextval
        INTO l_header_id
        FROM dual;
        log(C_STATE_LEVEL, l_procedure_name, 'l_header_id='||l_header_id);
        --
        -- populate the header_table
        --
        For C_rep_entity_rec in C_rep_entity loop
          l_org_id := C_rep_entity_rec.ORG_ID;
          log(C_STATE_LEVEL, l_procedure_name, 'l_org_id='||l_org_id);
          log(C_STATE_LEVEL, l_procedure_name, 'cis_sender_id='||C_rep_entity_rec.cis_sender_id);
          log(C_STATE_LEVEL, l_procedure_name, 'tax_office_number='||C_rep_entity_rec.tax_office_number);
          log(C_STATE_LEVEL, l_procedure_name, 'PAYE_REFERENCE='||C_rep_entity_rec.PAYE_REFERENCE);
          log(C_STATE_LEVEL, l_procedure_name, 'UNIQUE_TAX_REFERENCE_NUM='||C_rep_entity_rec.UNIQUE_TAX_REFERENCE_NUM);
          log(C_STATE_LEVEL, l_procedure_name, 'ACCOUNTS_OFFICE_REFERENCE='||C_rep_entity_rec.ACCOUNTS_OFFICE_REFERENCE);
          log(C_STATE_LEVEL, l_procedure_name, 'cis_sender_id='||C_rep_entity_rec.cis_sender_id);
          log(C_STATE_LEVEL, l_procedure_name, 'cis_sender_id='||C_rep_entity_rec.cis_sender_id);
          log(C_STATE_LEVEL, l_procedure_name, 'cis_sender_id='||C_rep_entity_rec.cis_sender_id);
          -- for debugging

          log(C_STATE_LEVEL, l_procedure_name, 'insert into igi_cis_mth_ret_hdr_t');
          insert into igi_cis_mth_ret_hdr_t(
          HEADER_ID,
          ORG_ID,
          CIS_SENDER_ID,
          TAX_OFFICE_NUMBER,
          PAYE_REFERENCE,
          REQUEST_ID,
          REQUEST_STATUS_CODE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_LOGIN_ID,
          UNIQUE_TAX_REFERENCE_NUM,
          ACCOUNTS_OFFICE_REFERENCE,
          PERIOD_NAME,
          PERIOD_ENDING_DATE,
          NIL_RETURN_FLAG,
          EMPLOYMENT_STATUS_FLAG,
          SUBCONT_VERIFY_FLAG,
          INFORMATION_CORRECT_FLAG,
          INACTIVITY_INDICATOR,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          CREATION_DATE,
          CREATED_BY,
          VERSION_NUM
          )
          values(
          l_header_id,
          l_org_id,
          C_rep_entity_rec.cis_sender_id,
          C_rep_entity_rec.tax_office_number,
          C_rep_entity_rec.PAYE_REFERENCE,
          FND_GLOBAL.CONC_REQUEST_ID(), -- REQUEST_ID
          'P', -- REQUEST_STATUS_CODE
          FND_GLOBAL.PROG_APPL_ID(), -- PROGRAM_APPLICATION_ID
          FND_GLOBAL.CONC_PROGRAM_ID(), -- PROGRAM_ID
          FND_GLOBAL.CONC_LOGIN_ID(), -- PROGRAM_LOGIN_ID
          C_rep_entity_rec.UNIQUE_TAX_REFERENCE_NUM,
          C_rep_entity_rec.ACCOUNTS_OFFICE_REFERENCE,
          p_period_name,
          l_period_end_date,
          p_nil_return_flag,
          p_emp_status_flag,
          p_subcont_verify_flag,
          p_info_crct_flag,
          nvl(p_inact_indicat_flag,'N'),
          sysdate,
          FND_GLOBAL.USER_ID(),
          FND_GLOBAL.LOGIN_ID(),
          sysdate,
          FND_GLOBAL.USER_ID(),
          l_latest_version
          );
          l_rep_ent_exist := 1;
        end loop;
        -- for debugging
        log(C_STATE_LEVEL, l_procedure_name, 'l_rep_ent_exist='||l_rep_ent_exist);
        if l_rep_ent_exist <> 1 then
          l_err_msg := 'Reporting Entites Not Found';
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_err_msg);
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_err_msg);
          raise e_rep_ent_not_found_error;
        End if;
        --
        -- populate the lines table
        --
        if p_nil_return_flag = 'Y' then
          log(C_STATE_LEVEL, l_procedure_name, 'p_nil_return_flag is Y');
          For C_nil_ret_rec in C_nil_ret_lines_info loop
            log(C_STATE_LEVEL, l_procedure_name, '================');
            log(C_STATE_LEVEL, l_procedure_name, 'VENDOR_ID='||C_nil_ret_rec.VENDOR_ID);
            log(C_STATE_LEVEL, l_procedure_name, 'VENDOR_NAME='||C_nil_ret_rec.VENDOR_NAME);
            log(C_STATE_LEVEL, l_procedure_name, 'VENDOR_TYPE_LOOKUP_CODE='||C_nil_ret_rec.VENDOR_TYPE_LOOKUP_CODE);
            log(C_STATE_LEVEL, l_procedure_name, 'FIRST_NAME='||C_nil_ret_rec.FIRST_NAME);
            log(C_STATE_LEVEL, l_procedure_name, 'SECOND_NAME='||C_nil_ret_rec.SECOND_NAME);
            log(C_STATE_LEVEL, l_procedure_name, 'LAST_NAME='||C_nil_ret_rec.LAST_NAME);
            log(C_STATE_LEVEL, l_procedure_name, 'SALUTATION='||C_nil_ret_rec.SALUTATION);
            log(C_STATE_LEVEL, l_procedure_name, 'TRADING_NAME='||C_nil_ret_rec.TRADING_NAME);
            log(C_STATE_LEVEL, l_procedure_name, 'UNMATCHED_TAX_FLAG='||C_nil_ret_rec.UNMATCHED_TAX_FLAG);
            log(C_STATE_LEVEL, l_procedure_name, 'UNIQUE_TAX_REFERENCE_NUM='||C_nil_ret_rec.UNIQUE_TAX_REFERENCE_NUM);
            log(C_STATE_LEVEL, l_procedure_name, 'COMPANY_REGISTRATION_NUMBER='||C_nil_ret_rec.COMPANY_REGISTRATION_NUMBER);
            log(C_STATE_LEVEL, l_procedure_name, 'NATIONAL_INSURANCE_NUMBER='||C_nil_ret_rec.NATIONAL_INSURANCE_NUMBER);
            log(C_STATE_LEVEL, l_procedure_name, 'VERIFICATION_NUMBER='||C_nil_ret_rec.VERIFICATION_NUMBER);
            log(C_STATE_LEVEL, l_procedure_name, 'TOTAL_PAYMENTS='||C_nil_ret_rec.TOTAL_PAYMENTS);
            log(C_STATE_LEVEL, l_procedure_name, 'LABOUR_COST='||C_nil_ret_rec.LABOUR_COST);
            log(C_STATE_LEVEL, l_procedure_name, 'MATERIAL_COST='||C_nil_ret_rec.MATERIAL_COST);
            log(C_STATE_LEVEL, l_procedure_name, 'TOTAL_DEDUCTIONS='||C_nil_ret_rec.TOTAL_DEDUCTIONS);
            log(C_STATE_LEVEL, l_procedure_name, 'DISCOUNT_AMOUNT='||C_nil_ret_rec.DISCOUNT_AMOUNT);
            log(C_STATE_LEVEL, l_procedure_name, 'CIS_TAX='||C_nil_ret_rec.CIS_TAX);
            log(C_STATE_LEVEL, l_procedure_name, '================');
            log(C_STATE_LEVEL, l_procedure_name, 'insert into igi_cis_mth_ret_lines_t');
           insert into igi_cis_mth_ret_lines_t(
           HEADER_ID,
           ORG_ID,
           VENDOR_ID,
           VENDOR_NAME,
           VENDOR_TYPE_LOOKUP_CODE,
           FIRST_NAME,
           SECOND_NAME,
           LAST_NAME,
           SALUTATION,
           TRADING_NAME,
           UNMATCHED_TAX_FLAG,
           UNIQUE_TAX_REFERENCE_NUM,
           COMPANY_REGISTRATION_NUMBER,
           NATIONAL_INSURANCE_NUMBER,
           VERIFICATION_NUMBER,
           TOTAL_PAYMENTS,
           LABOUR_COST,
           MATERIAL_COST,
           TOTAL_DEDUCTIONS,
           DISCOUNT_AMOUNT,
           CIS_TAX,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           CREATION_DATE,
           CREATED_BY,
           version_num)
           values(
           l_header_id,
           l_org_id,
           C_nil_ret_rec.VENDOR_ID,
           C_nil_ret_rec.VENDOR_NAME,
           C_nil_ret_rec.VENDOR_TYPE_LOOKUP_CODE,
           C_nil_ret_rec.FIRST_NAME,
           C_nil_ret_rec.SECOND_NAME,
           C_nil_ret_rec.LAST_NAME,
           C_nil_ret_rec.SALUTATION,
           C_nil_ret_rec.TRADING_NAME,
           C_nil_ret_rec.UNMATCHED_TAX_FLAG,
           C_nil_ret_rec.UNIQUE_TAX_REFERENCE_NUM,
           C_nil_ret_rec.COMPANY_REGISTRATION_NUMBER,
           C_nil_ret_rec.NATIONAL_INSURANCE_NUMBER,
           C_nil_ret_rec.VERIFICATION_NUMBER,
           C_nil_ret_rec.TOTAL_PAYMENTS,
           C_nil_ret_rec.LABOUR_COST,
           C_nil_ret_rec.MATERIAL_COST,
           C_nil_ret_rec.TOTAL_DEDUCTIONS,
           C_nil_ret_rec.DISCOUNT_AMOUNT,
           C_nil_ret_rec.CIS_TAX,
           sysdate,
           FND_GLOBAL.USER_ID(),
           FND_GLOBAL.LOGIN_ID(),
           sysdate,
           FND_GLOBAL.USER_ID(),
           l_latest_version
           );
          End loop;
        Elsif p_nil_return_flag = 'N' then
          log(C_STATE_LEVEL, l_procedure_name, 'p_nil_return_flag is not Y');
          For C_n_nil_ret_rec in C_non_nil_ret_lines_info loop
              log(C_STATE_LEVEL, l_procedure_name, '================');
              log(C_STATE_LEVEL, l_procedure_name, 'VENDOR_ID='||C_n_nil_ret_rec.VENDOR_ID);
              log(C_STATE_LEVEL, l_procedure_name, 'VENDOR_NAME='||C_n_nil_ret_rec.VENDOR_NAME);
              log(C_STATE_LEVEL, l_procedure_name, 'VENDOR_TYPE_LOOKUP_CODE='||C_n_nil_ret_rec.VENDOR_TYPE_LOOKUP_CODE);
              log(C_STATE_LEVEL, l_procedure_name, 'FIRST_NAME='||C_n_nil_ret_rec.FIRST_NAME);
              log(C_STATE_LEVEL, l_procedure_name, 'SECOND_NAME='||C_n_nil_ret_rec.SECOND_NAME);
              log(C_STATE_LEVEL, l_procedure_name, 'LAST_NAME='||C_n_nil_ret_rec.LAST_NAME);
              log(C_STATE_LEVEL, l_procedure_name, 'SALUTATION='||C_n_nil_ret_rec.SALUTATION);
              log(C_STATE_LEVEL, l_procedure_name, 'TRADING_NAME='||C_n_nil_ret_rec.TRADING_NAME);
              log(C_STATE_LEVEL, l_procedure_name, 'UNMATCHED_TAX_FLAG='||C_n_nil_ret_rec.UNMATCHED_TAX_FLAG);
              log(C_STATE_LEVEL, l_procedure_name, 'UNIQUE_TAX_REFERENCE_NUM='||C_n_nil_ret_rec.UNIQUE_TAX_REFERENCE_NUM);
              log(C_STATE_LEVEL, l_procedure_name, 'COMPANY_REGISTRATION_NUMBER='||C_n_nil_ret_rec.COMPANY_REGISTRATION_NUMBER);
              log(C_STATE_LEVEL, l_procedure_name, 'NATIONAL_INSURANCE_NUMBER='||C_n_nil_ret_rec.NATIONAL_INSURANCE_NUMBER);
              log(C_STATE_LEVEL, l_procedure_name, 'VERIFICATION_NUMBER='||C_n_nil_ret_rec.VERIFICATION_NUMBER);
              log(C_STATE_LEVEL, l_procedure_name, 'TOTAL_PAYMENTS='||C_n_nil_ret_rec.TOTAL_PAYMENTS);
              log(C_STATE_LEVEL, l_procedure_name, 'LABOUR_COST='||C_n_nil_ret_rec.LABOUR_COST);
              log(C_STATE_LEVEL, l_procedure_name, 'MATERIAL_COST='||C_n_nil_ret_rec.MATERIAL_COST);
              log(C_STATE_LEVEL, l_procedure_name, 'TOTAL_DEDUCTIONS='||C_n_nil_ret_rec.TOTAL_DEDUCTIONS);
              log(C_STATE_LEVEL, l_procedure_name, 'DISCOUNT_AMOUNT='||C_n_nil_ret_rec.DISCOUNT_AMOUNT);
              log(C_STATE_LEVEL, l_procedure_name, 'CIS_TAX='||C_n_nil_ret_rec.CIS_TAX);
              log(C_STATE_LEVEL, l_procedure_name, '================');
              log(C_STATE_LEVEL, l_procedure_name, 'insert into igi_cis_mth_ret_lines_t');
            insert into igi_cis_mth_ret_lines_t(
           HEADER_ID,
           ORG_ID,
           VENDOR_ID,
           VENDOR_NAME,
           VENDOR_TYPE_LOOKUP_CODE,
           FIRST_NAME,
           SECOND_NAME,
           LAST_NAME,
           SALUTATION,
           TRADING_NAME,
           UNMATCHED_TAX_FLAG,
           UNIQUE_TAX_REFERENCE_NUM,
           COMPANY_REGISTRATION_NUMBER,
           NATIONAL_INSURANCE_NUMBER,
           VERIFICATION_NUMBER,
           TOTAL_PAYMENTS,
           LABOUR_COST,
           MATERIAL_COST,
           TOTAL_DEDUCTIONS,
           DISCOUNT_AMOUNT,
           CIS_TAX,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           CREATION_DATE,
           CREATED_BY,
           version_num)
           values(
           l_header_id,
           l_org_id,
           C_n_nil_ret_rec.VENDOR_ID,
           C_n_nil_ret_rec.VENDOR_NAME,
           C_n_nil_ret_rec.VENDOR_TYPE_LOOKUP_CODE,
           C_n_nil_ret_rec.FIRST_NAME,
           C_n_nil_ret_rec.SECOND_NAME,
           C_n_nil_ret_rec.LAST_NAME,
           C_n_nil_ret_rec.SALUTATION,
           C_n_nil_ret_rec.TRADING_NAME,
           C_n_nil_ret_rec.UNMATCHED_TAX_FLAG,
           C_n_nil_ret_rec.UNIQUE_TAX_REFERENCE_NUM,
           C_n_nil_ret_rec.COMPANY_REGISTRATION_NUMBER,
           C_n_nil_ret_rec.NATIONAL_INSURANCE_NUMBER,
           C_n_nil_ret_rec.VERIFICATION_NUMBER,
           C_n_nil_ret_rec.TOTAL_PAYMENTS,
           C_n_nil_ret_rec.LABOUR_COST,
           C_n_nil_ret_rec.MATERIAL_COST,
           C_n_nil_ret_rec.TOTAL_DEDUCTIONS,
           C_n_nil_ret_rec.DISCOUNT_AMOUNT,
           C_n_nil_ret_rec.CIS_TAX,
           sysdate,
           FND_GLOBAL.USER_ID(),
           FND_GLOBAL.LOGIN_ID(),
           sysdate,
           FND_GLOBAL.USER_ID(),
           l_latest_version
           );
          End loop;
        End if;
        --
        -- populate the payments table
        --
        log(C_STATE_LEVEL, l_procedure_name, 'insert into igi_cis_mth_ret_pay_t');
        insert into igi_cis_mth_ret_pay_t
        (
        HEADER_ID,
        ORG_ID,
        VENDOR_ID,
        CHILD_VENDOR_ID,
        INVOICE_ID,
        INVOICE_PAYMENT_ID,
        AMOUNT,
        LABOUR_COST,
        MATERIAL_COST,
        TOTAL_DEDUCTIONS,
        DISCOUNT_AMOUNT,
        CIS_TAX,--11699868
        LAST_UPDATE_DATE,--date
        LAST_UPDATED_BY, -- num
        LAST_UPDATE_LOGIN,-- num
        CREATION_DATE,--date
        CREATED_BY, --num
        VERSION_NUM
        )
        Select
        l_header_id,
        l_org_id,
        VENDOR_ID,
        CHILD_VENDOR_ID,
        INVOICE_ID,
        INVOICE_PAYMENT_ID,
        AMOUNT,
        LABOUR_COST,
        MATERIAL_COST,
        TOTAL_DEDUCTIONS,
        DISCOUNT_AMOUNT,
        CIS_TAX,--11699868
        sysdate,
        FND_GLOBAL.USER_ID(),
        FND_GLOBAL.LOGIN_ID(),
        sysdate,
        FND_GLOBAL.USER_ID(),
        l_latest_version
        from igi_cis_mth_ret_pay_gt;
        -- for debugging
        FND_FILE.PUT_LINE(FND_FILE.LOG,'igi_cis_mth_ret_pay_t populate with '||SQL%ROWCOUNT);
        commit;
        --
        -- submit the CP request to run the subcontractor deduction report
        --
        IF p_mth_ret_mode = 'P' then
            log(C_STATE_LEVEL, l_procedure_name, 'p_mth_ret_mode is P');
            IF (p_mth_report_template is NULL OR p_mth_report_format is NULL) THEN
		l_xml_layout := FND_REQUEST.ADD_LAYOUT(l_appln_name,'IGIPMTHR','en','US','PDF');
            ELSE
	        l_xml_layout := FND_REQUEST.ADD_LAYOUT(l_appln_name,p_mth_report_template,'en','US',p_mth_report_format);
	    END IF;
	   fnd_request.set_org_id(l_org_id);
	   IF p_mth_sort_by IS NULL then
              log(C_STATE_LEVEL, l_procedure_name, 'p_mth_sort_by IS NULL');
              l_request_id := fnd_request.submit_request(application => l_appln_name,
                                                    program     => l_con_cp,
                                                    description => l_con_cp_desc,
                                                    start_time  => NULL,
                                                    sub_request => FALSE,
                                                    argument1   => p_period_name,
                                                    argument2   => NULL,
                                                    argument3   => NULL,
                                                    argument4   => 'D', -- Original
                                                    argument5   => 'VENDOR_NAME', -- sort
                                                    argument6   => 'P', -- prelim
                                                    argument7   => 'N', -- del rows
                                                    argument8   => 'D', -- detail
                                                    argument9   => p_mth_ret_amt_type, -- amount type
                                                    argument10   => chr(0));
           ELSE
              log(C_STATE_LEVEL, l_procedure_name, 'p_mth_sort_by IS NOT NULL');
	       l_request_id := fnd_request.submit_request(application => l_appln_name,
                                                    program     => l_con_cp,
                                                    description => l_con_cp_desc,
                                                    start_time  => NULL,
                                                    sub_request => FALSE,
                                                    argument1   => p_period_name,
                                                    argument2   => NULL,
                                                    argument3   => NULL,
                                                    argument4   => 'D', -- Original
                                                    argument5   => p_mth_sort_by, -- sort
                                                    argument6   => 'P', -- prelim
                                                    argument7   => 'N', -- del rows
                                                    argument8   => 'D', -- detail
                                                    argument9   => p_mth_ret_amt_type, -- amount type
                                                    argument10   => chr(0));
           END IF;

	   IF l_request_id = 0 THEN
             RAISE e_request_submit_error;
           END IF;
        -- bug 5620621 start
        -- Added line below while testing 11.5.8
           IF (p_mth_report_template is NULL OR p_mth_report_format is NULL) then
		l_xml_layout := FND_REQUEST.ADD_LAYOUT(l_appln_name,'IGIPMTHR','en','US','PDF');
	   ELSE
	        l_xml_layout := FND_REQUEST.ADD_LAYOUT(l_appln_name,p_mth_report_template,'en','US',p_mth_report_format);
           END IF;
           fnd_request.set_org_id(l_org_id);
           IF p_mth_sort_by IS NULL then
		l_request_id := fnd_request.submit_request(application => l_appln_name,
                                                    program     => l_con_cp,
                                                    description => l_con_cp_desc,
                                                    start_time  => NULL,
                                                    sub_request => FALSE,
                                                    argument1   => p_period_name,
                                                    argument2   => NULL,
                                                    argument3   => NULL,
                                                    argument4   => 'D', -- Original
                                                    argument5   => 'VENDOR_NAME', -- sort
                                                    argument6   => 'P', -- prelim
                                                    argument7   => 'Y', -- del rows
                                                    argument8   => 'S', -- summary
                                                    argument9   =>  p_mth_ret_amt_type, -- amount type
                                                    argument10   => chr(0));
            ELSE
		l_request_id := fnd_request.submit_request(application => l_appln_name,
                                                    program     => l_con_cp,
                                                    description => l_con_cp_desc,
                                                    start_time  => NULL,
                                                    sub_request => FALSE,
                                                    argument1   => p_period_name,
                                                    argument2   => NULL,
                                                    argument3   => NULL,
                                                    argument4   => 'D', -- Original
                                                    argument5   => p_mth_sort_by, -- sort
                                                    argument6   => 'P', -- prelim
                                                    argument7   => 'Y', -- del rows
                                                    argument8   => 'S', -- summary
                                                    argument9   =>  p_mth_ret_amt_type, -- amount type
                                                    argument10   => chr(0));
            END IF;
        IF l_request_id = 0 THEN
          RAISE e_request_submit_error;
        END IF;
        -- bug 5620621 end
        retcode := 0; -- CP completed successfully
     end if;

     l_prelim_hdr_id := l_header_id;
     --update the status to C and update who columns
     update IGI_CIS_MTH_RET_HDR_T
          set --REQUEST_STATUS_CODE = 'C',
          PROGRAM_ID = FND_GLOBAL.CONC_PROGRAM_ID(),
          PROGRAM_APPLICATION_ID = FND_GLOBAL.PROG_APPL_ID(),
          PROGRAM_LOGIN_ID = FND_GLOBAL.CONC_LOGIN_ID()
          where HEADER_ID = l_prelim_hdr_id;
          --call the procedure to mov recods
          -- mov the records and then commit
   FND_FILE.PUT_LINE(FND_FILE.LOG,'*********** BEFORE FIN AL MODE ');
       if p_mth_ret_mode = 'F' then
          MOVE_TO_HISTORY(l_prelim_hdr_id, 'C');
          --- commit and run the report
          commit;
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Records moved to History tables successfully ');
          --
          -- submit the CP request to run the subcontractor deduction report
          --
          IF (p_mth_report_template is NULL OR p_mth_report_format is NULL) THEN
		l_xml_layout := FND_REQUEST.ADD_LAYOUT(l_appln_name,'IGIPMTHR','en','US','PDF');
	  ELSE
	        l_xml_layout := FND_REQUEST.ADD_LAYOUT(l_appln_name,p_mth_report_template,'en','US',p_mth_report_format);
	  END IF;
          fnd_request.set_org_id(l_org_id);
	  IF p_mth_sort_by is NULL then
		l_request_id := fnd_request.submit_request(application => l_appln_name,
                                                      program     => l_con_cp,
                                                      description => l_con_cp_desc,
                                                      start_time  => NULL,
                                                      sub_request => FALSE,
                                                      argument1   => p_period_name,
                                                      argument2   => NULL,
                                                      argument3   => NULL,
                                                      argument4   => 'O', -- Original
                                                      argument5   => 'VENDOR_NAME', -- sort
                                                      argument6   => 'F',
                                                      argument7   => 'Y', --delete temp
                                                      argument8   => 'S',
                                                      argument9   => p_mth_ret_amt_type, --amount type
                                                      argument10   => chr(0));
	  ELSE
	        l_request_id := fnd_request.submit_request(application => l_appln_name,
                                                      program     => l_con_cp,
                                                      description => l_con_cp_desc,
                                                      start_time  => NULL,
                                                      sub_request => FALSE,
                                                      argument1   => p_period_name,
                                                      argument2   => NULL,
                                                      argument3   => NULL,
                                                      argument4   => 'O', -- Original
                                                      argument5   => p_mth_sort_by, -- sort
                                                      argument6   => 'F',
                                                      argument7   => 'Y', --delete temp
                                                      argument8   => 'S',
                                                      argument9   => p_mth_ret_amt_type, --amount type
                                                      argument10   => chr(0));
	  END IF;
          IF l_request_id = 0 THEN
            RAISE e_request_submit_error;
          END IF;
          retcode := 0; -- CP completed successfully
       end if;
     --
     -- handling exception
     --
    log(C_STATE_LEVEL, l_procedure_name, 'END');
     Exception
      when e_request_submit_error then
        errbuf := 'Error while calling the deduction report';
        retcode := 2;
    log(C_STATE_LEVEL, l_procedure_name, 'END EXCEPTION 1='||errbuf);
      when e_validation_exception then
        -- setting out parameters
        errbuf := l_err_all_msg;
        retcode := 2;
    log(C_STATE_LEVEL, l_procedure_name, 'END EXCEPTION 2='||errbuf);
      when e_prelim_mand_error then
        errbuf := l_err_msg ;
        retcode := 2;
    log(C_STATE_LEVEL, l_procedure_name, 'END EXCEPTION 3='||errbuf);
      when e_param_mismatch_error then
        errbuf := l_err_msg;
        retcode := 2;
    log(C_STATE_LEVEL, l_procedure_name, 'END EXCEPTION 4='||errbuf);
      when e_rep_ent_not_found_error then
        errbuf := l_err_msg;
        retcode := 2;
    log(C_STATE_LEVEL, l_procedure_name, 'END EXCEPTION 5='||errbuf);
      when others then
        -- for debugging
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in processing' || sqlerrm);
        -- rollback the insert and updates
        rollback;
        errbuf := sqlerrm;
        retcode := 2;
    log(C_STATE_LEVEL, l_procedure_name, 'END EXCEPTION 6='||errbuf);
  end POPULATE_MTH_RET_DETAILS;

  PROCEDURE MOVE_TO_HISTORY(p_header_id IN number,
                            p_request_status_code IN varchar2)
  is
  Begin

      insert into igi_cis_mth_ret_hdr_h
        (HEADER_ID,
               ORG_ID,
               CIS_SENDER_ID,
               TAX_OFFICE_NUMBER,
               PAYE_REFERENCE,
               REQUEST_ID,
               REQUEST_STATUS_CODE,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_LOGIN_ID,
               UNIQUE_TAX_REFERENCE_NUM,
               ACCOUNTS_OFFICE_REFERENCE,
               PERIOD_NAME,
               PERIOD_ENDING_DATE,
               NIL_RETURN_FLAG,
               EMPLOYMENT_STATUS_FLAG,
               SUBCONT_VERIFY_FLAG,
               INFORMATION_CORRECT_FLAG,
               INACTIVITY_INDICATOR,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               CREATION_DATE,
               CREATED_BY,
               VERSION_NUM,
               STATUS)
        select HEADER_ID,
               ORG_ID,
               CIS_SENDER_ID,
               TAX_OFFICE_NUMBER,
               PAYE_REFERENCE,
               REQUEST_ID,
               p_request_status_code,--REQUEST_STATUS_CODE,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_LOGIN_ID,
               UNIQUE_TAX_REFERENCE_NUM,
               ACCOUNTS_OFFICE_REFERENCE,
               PERIOD_NAME,
               PERIOD_ENDING_DATE,
               NIL_RETURN_FLAG,
               EMPLOYMENT_STATUS_FLAG,
               SUBCONT_VERIFY_FLAG,
               INFORMATION_CORRECT_FLAG,
               INACTIVITY_INDICATOR,
               sysdate, --LAST_UPDATE_DATE
               FND_GLOBAL.USER_ID(),--LAST_UPDATED_BY
               FND_GLOBAL.LOGIN_ID(),--LAST_UPDATE_LOGIN
               sysdate, --CREATION_DATE
               FND_GLOBAL.USER_ID(), --CREATED_BY
               nvl(VERSION_NUM,1),
               'FINAL'
          from  igi_cis_mth_ret_hdr_t
          where HEADER_ID  = p_header_id ;

      insert into igi_cis_mth_ret_lines_h
          (HEADER_ID,
                 ORG_ID,
                 VENDOR_ID,
                 VENDOR_NAME,
                 VENDOR_TYPE_LOOKUP_CODE,
                 FIRST_NAME,
                 SECOND_NAME,
                 LAST_NAME,
                 SALUTATION,
                 TRADING_NAME,
                 UNMATCHED_TAX_FLAG,
                 UNIQUE_TAX_REFERENCE_NUM,
                 COMPANY_REGISTRATION_NUMBER,
                 NATIONAL_INSURANCE_NUMBER,
                 VERIFICATION_NUMBER,
                 TOTAL_PAYMENTS,
                 LABOUR_COST,
                 MATERIAL_COST,
                 TOTAL_DEDUCTIONS,
                 DISCOUNT_AMOUNT,
                 CIS_TAX,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 CREATION_DATE,
                 CREATED_BY,
                 VERSION_NUM)
          select HEADER_ID,
                 ORG_ID,
                 VENDOR_ID,
                 VENDOR_NAME,
                 VENDOR_TYPE_LOOKUP_CODE,
                 FIRST_NAME,
                 SECOND_NAME,
                 LAST_NAME,
                 SALUTATION,
                 TRADING_NAME,
                 UNMATCHED_TAX_FLAG,
                 UNIQUE_TAX_REFERENCE_NUM,
                 COMPANY_REGISTRATION_NUMBER,
                 NATIONAL_INSURANCE_NUMBER,
                 VERIFICATION_NUMBER,
                 TOTAL_PAYMENTS,
                 LABOUR_COST,
                 MATERIAL_COST,
                 TOTAL_DEDUCTIONS,
                 DISCOUNT_AMOUNT,
                 CIS_TAX,
                 sysdate, --LAST_UPDATE_DATE
                 FND_GLOBAL.USER_ID(),--LAST_UPDATED_BY
                 FND_GLOBAL.LOGIN_ID(),--LAST_UPDATE_LOGIN
                 sysdate, --CREATION_DATE
                 FND_GLOBAL.USER_ID(), --CREATED_BY
                nvl(VERSION_NUM,1)
            from igi_cis_mth_ret_lines_t
            where HEADER_ID  = p_header_id ;

      insert into igi_cis_mth_ret_pay_h
            (HEADER_ID,
                   ORG_ID,
                   VENDOR_ID,
                   CHILD_VENDOR_ID,
                   INVOICE_ID,
                   INVOICE_PAYMENT_ID,
                   AMOUNT,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   CREATION_DATE,
                   CREATED_BY,
                   LABOUR_COST,
                   MATERIAL_COST,
                   TOTAL_DEDUCTIONS,
                   DISCOUNT_AMOUNT,
                   CIS_TAX,
                   VERSION_NUM)
            Select HEADER_ID,
                   ORG_ID,
                   VENDOR_ID,
                   CHILD_VENDOR_ID,
                   INVOICE_ID,
                   INVOICE_PAYMENT_ID,
                   AMOUNT,
                   sysdate, --LAST_UPDATE_DATE
                   FND_GLOBAL.USER_ID(),--LAST_UPDATED_BY
                   FND_GLOBAL.LOGIN_ID(),--LAST_UPDATE_LOGIN
                   sysdate, --CREATION_DATE
                   FND_GLOBAL.USER_ID(), --CREATED_BY
                   LABOUR_COST,
                   MATERIAL_COST,
                   TOTAL_DEDUCTIONS,
                   DISCOUNT_AMOUNT,
                   CIS_TAX,
                   nvl(VERSION_NUM,1)
              from igi_cis_mth_ret_pay_t
              where HEADER_ID  = p_header_id;
            -- delete the records from interface tables
            delete from igi_cis_mth_ret_hdr_t where header_id = p_header_id;
            delete from igi_cis_mth_ret_lines_t where header_id = p_header_id;
            delete from igi_cis_mth_ret_pay_t where header_id = p_header_id;
  End MOVE_TO_HISTORY;

 PROCEDURE RUN_MTH_RET_REPORT(p_period_name IN varchar2,
                              p_orig_dub IN varchar2,
                              p_sort_by IN varchar2,
                              p_ret_mode IN varchar2,
                              p_del_preview IN varchar2,
                              p_report_lev IN varchar2,--bug 5620621
                              p_request_id OUT NOCOPY integer)
  is
    l_procedure_name         VARCHAR2(100):='.RUN_MTH_RET_REPORT';
      l_request_id number;
      l_appln_name  varchar2(10) := 'IGI';
      l_con_cp      varchar2(15) := 'IGIPMTHR_XMLP';
      l_con_cp_desc varchar2(200) := 'IGI : CIS2007 Monthly Returns Report';
      l_xml_layout boolean;

   Begin
          l_xml_layout := FND_REQUEST.ADD_LAYOUT(l_appln_name,'IGIPMTHR','en','US','PDF');
          fnd_request.set_org_id(mo_global.get_current_org_id);
          l_request_id := fnd_request.submit_request(application => l_appln_name,
                                                      program     => l_con_cp,
                                                      description => l_con_cp_desc,
                                                      start_time  => NULL,
                                                      sub_request => FALSE,
                                                      argument1   => p_period_name,
                                                      argument2   => NULL,
                                                      argument3   => NULL,
                                                      argument4   => p_orig_dub, -- Original
                                                      argument5   => p_sort_by, -- sort
                                                      argument6   => p_ret_mode,
                                                      argument7   => p_del_preview,
                                                      argument8   => p_report_lev, --'S',bug 5620621
                                                      argument9   => 'P', --Positive amount ER6137652
                                                      argument10   => chr(0));
          p_request_id := l_request_id;
  End RUN_MTH_RET_REPORT;

/* PROCEDURE POST_REPORT_DELETE(p_request_id in number,
                                p_header_id in number)
  is
    l_phase          VARCHAR2(100);
    l_status         VARCHAR2(100);
    l_dev_phase      VARCHAR2(100);
    l_dev_status     VARCHAR2(100);
    l_message        VARCHAR2(1000);
    e_request_wait_error exception;
  Begin
      IF NOT fnd_concurrent.wait_for_request(p_request_id,
                                             20, -- interval seconds
                                             0, -- max wait seconds
                                             l_phase,
                                             l_status,
                                             l_dev_phase,
                                             l_dev_status,
                                             l_message) THEN
        RAISE e_request_wait_error;
      END IF;
      IF l_dev_phase = 'COMPLETE' THEN
       -- delete records
       delete from igi_cis_mth_ret_hdr_t where header_id = p_header_id;
       delete from igi_cis_mth_ret_lines_t where header_id = p_header_id;
       delete from igi_cis_mth_ret_pay_t where header_id = p_header_id;
       commit;
      END IF;
  End POST_REPORT_DELETE;*/
BEGIN
  init;
END IGI_CIS2007_IGIPMTHR_PKG;

/
