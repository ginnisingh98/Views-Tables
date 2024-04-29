--------------------------------------------------------
--  DDL for Package Body AP_AUTOSELECT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AUTOSELECT_PKG" AS
/* $Header: appbselb.pls 120.53.12010000.45 2010/05/31 13:22:07 mayyalas ship $ */

   G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_AUTOSELECT_PKG';
   G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
   G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
   G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
   G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
   G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

   G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
   G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
   G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
   G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
   G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
   G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
   G_MODULE_NAME           CONSTANT VARCHAR2(80) := 'AP.PLSQL.AP_AUTOSELECT_PKG';



/* bug 8691645 */
PROCEDURE check_ccr_status( p_checkrun_id  varchar2 ,
                            p_calling_sequence VARCHAR2) IS


 TYPE invoice_id_t IS TABLE OF AP_INVOICES.INVOICE_ID%TYPE INDEX BY BINARY_INTEGER;
 TYPE vendor_id_t IS TABLE OF AP_INVOICES.VENDOR_ID%TYPE INDEX BY BINARY_INTEGER;
 TYPE vendor_site_id_t IS TABLE OF AP_INVOICES.VENDOR_SITE_ID%TYPE INDEX BY BINARY_INTEGER;
 TYPE remit_to_supplier_site_id_t IS TABLE OF AP_INVOICES.REMIT_TO_SUPPLIER_SITE_ID%TYPE INDEX BY BINARY_INTEGER;

 TYPE ccr_rec_type IS RECORD (
     invoice_id_tab                   invoice_id_t
    ,vendor_id_tab                    vendor_id_t
    ,vendor_site_id_tab               vendor_site_id_t
    ,remit_to_supplier_site_id_tab    remit_to_supplier_site_id_t
   );

 ccr_rec_info ccr_rec_type;
 ccr_rec_list ccr_rec_type;
 l_ind                        NUMBER :=1;
 l_Vendor_Site_Reg_Expired    VARCHAR2(1) :='N';
 l_system_user                NUMBER :=5;
 l_holds                      AP_APPROVAL_PKG.HOLDSARRAY;
 l_hold_count                 AP_APPROVAL_PKG.COUNTARRAY;
 l_release_count              AP_APPROVAL_PKG.COUNTARRAY;
 l_calling_sequence           VARCHAR2(2000);
 l_debug_info                 varchar2(2000);


CURSOR selected_inv(p_checkrun_id  varchar2) IS
SELECT asi.invoice_id
        ,asi.vendor_id
        ,asi.vendor_site_id
        ,asi.remit_to_supplier_site_id
FROM   ap_selected_invoices_all asi,ap_invoices_all ai
WHERE  ai.invoice_id=asi.invoice_id
AND    ai.invoice_type_lookup_code in ('STANDARD','PREPAYMENT')
AND    AP_UTILITIES_PKG.GET_CCR_STATUS(asi.vendor_id,'S') <> 'F'
AND    asi.checkrun_id=p_checkrun_id;

BEGIN

 l_calling_sequence := p_calling_sequence || 'CHECK_CCR_STATUS';


  l_debug_info := 'Start of check_ccr_status';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

OPEN  selected_inv(p_checkrun_id);
LOOP
FETCH selected_inv
BULK  COLLECT INTO  ccr_rec_info.invoice_id_tab
                  ,ccr_rec_info.vendor_id_tab
                  ,ccr_rec_info.vendor_site_id_tab
                  ,ccr_rec_info.remit_to_supplier_site_id_tab

LIMIT 1000;

l_debug_info := 'CALLING AP_APPROVAL_PKG.CHECK_CCR_VENDOR ';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

for i in 1 .. ccr_rec_info.invoice_id_tab.count loop

  AP_APPROVAL_PKG.CHECK_CCR_VENDOR(
              P_INVOICE_ID                => ccr_rec_info.invoice_id_tab(i),
              P_VENDOR_ID                 => ccr_rec_info.vendor_id_tab(i),
              P_VENDOR_SITE_ID            => ccr_rec_info.vendor_site_id_tab(i),
              P_REMIT_TO_SUPPLIER_SITE_ID => ccr_rec_info.remit_to_supplier_site_id_tab(i),
              P_SYSTEM_USER               => l_system_user ,
              P_HOLDS                     => l_holds,
              P_HOLDS_COUNT               => l_hold_count,
              P_RELEASE_COUNT             => l_release_count,
              P_VENDOR_SITE_REG_EXPIRED   => l_Vendor_Site_Reg_Expired,
              P_CALLING_SEQUENCE          => l_calling_sequence);

   l_debug_info := 'vendor_id '||ccr_rec_info.vendor_id_tab(i)||' returned ccr reg status ' ||l_Vendor_Site_Reg_Expired ;
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
   END IF;

   IF(l_Vendor_Site_Reg_Expired <>'N') then
     ccr_rec_list.invoice_id_tab(l_ind) := ccr_rec_info.invoice_id_tab(i);
     ccr_rec_list.vendor_id_tab(l_ind)  := ccr_rec_info.vendor_id_tab(i);
     ccr_rec_list.vendor_site_id_tab(l_ind) :=ccr_rec_info.vendor_site_id_tab(i);
     ccr_rec_list.remit_to_supplier_site_id_tab(l_ind) :=ccr_rec_info.remit_to_supplier_site_id_tab(i);


     l_ind :=l_ind+1;

   END IF ;

END LOOP;



if (ccr_rec_list.invoice_id_tab.count >0) then

 l_debug_info := 'rejecting the invoices of inactive ccr status sites';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

FORALL i IN ccr_rec_list.invoice_id_tab.first .. ccr_rec_list.invoice_id_tab.LAST
UPDATE    Ap_Selected_Invoices_All ASI
   SET    ASI.ok_to_pay_flag = 'N',
          ASI.dont_pay_reason_code =  'CCR_REG_EXPIRED'
 WHERE    ASI.checkrun_id = p_checkrun_id
   AND    ASI.invoice_id=ccr_rec_list.invoice_id_tab(i);

end if ;

EXIT WHEN selected_inv%NOTFOUND;
END LOOP;
CLOSE selected_inv;



 l_debug_info := 'End of check_ccr_status';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

EXCEPTION

WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_checkrun_id: '||
                                           to_char(p_checkrun_id));

    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;


END check_ccr_status;


--Bug6459578

PROCEDURE awt_special_rounding(p_checkrun_name in varchar2,p_calling_sequence in varchar2) IS

l_debug_info    VARCHAR2(200);
l_current_calling_sequence  VARCHAR2(2000);

BEGIN
  -- Update the calling sequence

     l_current_calling_sequence := p_calling_sequence || '<-awt_special_rounding';
     l_debug_info := 'Call AP_CUSTOM_WITHHOLDING_PKG.AP_SPECIAL_ROUNDING';


     AP_CUSTOM_WITHHOLDING_PKG.AP_SPECIAL_ROUNDING(p_checkrun_name);


EXCEPTION
    WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_checkrun_name: '||
                                           p_checkrun_name);

    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END;


PROCEDURE calculate_interest (p_checkrun_id in number,
                              p_checkrun_name in varchar2,
                              p_check_date in date,
                              p_calling_sequence in varchar2) is


CURSOR interest_cursor IS
SELECT   ASI.invoice_id, ASI.payment_num, ASI.vendor_id,
         ASI.vendor_site_id, ASI.vendor_num, ASI.vendor_name,
         ASI.vendor_site_code, ASI.address_line1, ASI.address_line2,
         ASI.address_line3, ASI.address_line4, ASI.city, ASI.state, ASI.zip,
         ASI.invoice_num, ASI.voucher_num,
         -- ASI.payment_priority,   -- Bug 5139574
         nvl(ASI.payment_priority, 99), ASI.province,
         ASI.country, ASI.withholding_status_lookup_code,
         ASI.attention_ar_flag, ASI.set_of_books_id,
         ASI.invoice_exchange_rate, ASI.payment_cross_rate,
         ASI.customer_num, asi.external_bank_account_id, ASI.ok_to_pay_flag,
         round(LEAST(TRUNC(P_check_date),ADD_MONTHS(TRUNC(due_date),12))
               - TRUNC(due_date)), /*Bug 5124784 */
         annual_interest_rate,
         AI.invoice_currency_code,
         ASI.payment_currency_code,
         /* bug 5233279. For Federal Installation Exclusive payment Flag is required */
         decode(Ap_Payment_Util_Pkg.is_federal_installed(AI.org_id),
                'Y', AI.exclusive_payment_flag, 'N'),
         asp.interest_accts_pay_ccid,
         ai.org_id
FROM     ap_interest_periods,
         ap_invoices AI, --Bug6040657. Changed from ap_invoices_all to ap_invoices
         ap_selected_invoices_all ASI,
         po_vendors pov,
         ap_system_parameters_all asp
WHERE  ASI.checkrun_id = P_checkrun_id
AND    ASP.auto_calculate_interest_flag = 'Y'
AND    ASP.org_id = asi.org_id
AND    TRUNC(P_check_date) > TRUNC(due_date)
AND    (trunc(due_date)+1) BETWEEN trunc(start_date) AND trunc(end_date)
AND    (NVL(payment_amount,0) *
            POWER(1 + (annual_interest_rate/(12 * 100)),
                  TRUNC((LEAST(P_check_date,
                               ADD_MONTHS(due_date,12))
                        - due_date) / 30))
            *
            (1 + ((annual_interest_rate/(360 * 100)) *
                  MOD((LEAST(P_check_date,
                             ADD_MONTHS(due_date,12))
                      - due_date)
                      , 30))))
            - NVL(payment_amount,0) >= NVL(asp.interest_tolerance_amount,0)
AND    ASI.vendor_id = pov.vendor_id
AND    pov.auto_calculate_interest_flag = 'Y'
AND    AI.invoice_id = ASI.invoice_id
AND    AI.invoice_type_lookup_code <> 'PAYMENT REQUEST';


  l_address_line1            po_vendor_sites_all.address_line1%TYPE;
  l_address_line2            po_vendor_sites_all.address_line2%TYPE;
  l_address_line3            po_vendor_sites_all.address_line3%TYPE;
  l_address_line4            po_vendor_sites_all.address_line4%TYPE;
  l_amount_remaining         NUMBER;
  l_attention_ar_flag        VARCHAR2(1);
  l_awt_status_lookup_code   VARCHAR2(25);
  l_city                     ap_selected_invoices_all.city%type; --6708281
  l_country                  ap_selected_invoices_all.country%type; --6708281
--  l_city                     VARCHAR2(25);
--  l_country                  VARCHAR2(25);
  l_current_calling_sequence varchar2(2000);
  l_customer_num             VARCHAR2(25);
  l_debug_info               varchar2(200);
  l_discount_available       NUMBER;
  l_discount_taken           NUMBER;
  l_due_date                 date;
  l_exclusive_payment_flag   VARCHAR2(1);
  l_existing_interest_count  NUMBER;
  l_external_bank_account_id number;
  l_int_invoice_amt          NUMBER;
  l_int_invoice_days         NUMBER;
  l_int_invoice_no           varchar2(50);
  l_int_invoice_num          VARCHAR2(50);
  l_int_invoice_rate         NUMBER;
  l_int_vendor_name          po_vendors.vendor_name%TYPE;
  l_int_vendor_num           VARCHAR2(30);
  l_interest_ap_ccid         number;
  l_inv_curr_int_amt         NUMBER;
  l_invoice_currency_code    VARCHAR2(15);
  l_invoice_exchange_rate    NUMBER;
  l_invoice_id               number;
  l_nls_days                 ap_lookup_codes.displayed_field%TYPE;
  l_nls_int                  ap_lookup_codes.displayed_field%TYPE;
  l_nls_interest             ap_lookup_codes.displayed_field%TYPE;
  l_nls_percent              ap_lookup_codes.displayed_field%TYPE;
  l_ok_to_pay_flag           VARCHAR2(1);
  l_org_id                   number;
  l_pay_currency_code        VARCHAR2(15);
  l_payment_amount           NUMBER;
  l_payment_cross_rate       NUMBER;
  l_payment_num              number;
  l_payment_priority         NUMBER(2);
  l_proposed_interest_count  NUMBER;
  l_province                 VARCHAR2(150);
  l_set_of_books_id          number;
  l_site_code                po_vendor_sites_all.vendor_site_code%TYPE;
  l_site_id                  NUMBER(15);
  l_state                    VARCHAR2(150);
  l_vendor_id                number;
  l_voucher_num              VARCHAR2(50);
--  l_zip                      VARCHAR2(20);
  l_zip                      ap_selected_invoices_all.zip%type;  --6708281


BEGIN

  l_debug_info := 'Perform Interest calculations';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  l_current_calling_sequence := p_calling_sequence || '<-calculate_interest';


  SELECT   substrb(l1.displayed_field, 1, 25),
           substrb(l2.displayed_field, 1, 10),
           substrb(l3.displayed_field, 1, 5),
           substrb(l4.displayed_field, 1, 25)
  INTO     l_nls_interest,
           l_nls_days,
           l_nls_percent,
           l_nls_int
  FROM     ap_lookup_codes l1,
           ap_lookup_codes l2,
           ap_lookup_codes l3,
           ap_lookup_codes l4
  WHERE  l1.lookup_type = 'NLS TRANSLATION'
  AND    l1.lookup_code = 'INTEREST'
  AND    l2.lookup_type = 'NLS TRANSLATION'
  AND    l2.lookup_code = 'DAYS'
  AND    l3.lookup_type = 'NLS TRANSLATION'
  AND    l3.lookup_code = 'PERCENT'
  AND    l4.lookup_type = 'NLS TRANSLATION'
  AND    l4.lookup_code = 'INT';





--interest calculations

  OPEN interest_cursor;

  LOOP

    FETCH  interest_cursor
    INTO     l_invoice_id, l_payment_num, l_vendor_id,
             l_site_id, l_int_vendor_num, l_int_vendor_name,
             l_site_code, l_address_line1, l_address_line2,
             l_address_line3, l_address_line4, l_city, l_state, l_zip, l_int_invoice_num,
             l_voucher_num, l_payment_priority, l_province,
             l_country, l_awt_status_lookup_code,
             l_attention_ar_flag,
             l_set_of_books_id,
             l_invoice_exchange_rate,
             l_payment_cross_rate,
             l_customer_num,
             l_external_bank_account_id,
             l_ok_to_pay_flag,
             l_int_invoice_days,
             l_int_invoice_rate,
             l_invoice_currency_code,
             l_pay_currency_code,
             l_exclusive_payment_flag,
             l_interest_ap_ccid,
             l_org_id;

    EXIT WHEN interest_cursor%NOTFOUND or interest_cursor%NOTFOUND is NULL;



    SELECT nvl(payment_amount,0), nvl(amount_remaining,0),
           nvl(discount_amount,0),nvl(discount_amount_remaining,0)
    INTO   l_payment_amount, l_amount_remaining,
           l_discount_taken, l_discount_available
    FROM   ap_selected_invoices_all asi
    WHERE  asi.invoice_id = l_invoice_id
    AND    asi.payment_num = l_payment_num
    and    asi.checkrun_id = p_checkrun_id;



    l_debug_info := 'Calling ap_interest_invoice_pkg';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;



    ap_interest_invoice_pkg.ap_calculate_interest(
         P_INVOICE_ID                    =>l_invoice_id,
         P_SYS_AUTO_CALC_INT_FLAG        =>'Y',  --should always be "Y" b/c of cursor where clause
         P_AUTO_CALCULATE_INTEREST_FLAG  =>'Y',  --should always be "Y" b/c of cursor where clause
         P_CHECK_DATE                    =>P_check_date,
         P_PAYMENT_NUM                   =>l_payment_num,
         P_AMOUNT_REMAINING              =>l_amount_remaining,
         P_DISCOUNT_TAKEN                =>l_discount_taken,
         P_DISCOUNT_AVAILABLE            =>l_discount_available,
         P_CURRENCY_CODE                 =>l_pay_currency_code,
         P_INTEREST_AMOUNT               =>l_int_invoice_amt,
         P_DUE_DATE                      =>l_due_date,
         P_INTEREST_INVOICE_NUM          =>l_int_invoice_no,
         P_PAYMENT_AMOUNT                =>l_payment_amount,
         P_CALLING_SEQUENCE              =>l_current_calling_sequence);

    l_debug_info := 'interest invoice amount = '||to_char(l_int_invoice_amt);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;


    IF (l_int_invoice_amt <> 0) THEN

      SELECT count(*)
      INTO   l_existing_interest_count
      FROM   ap_invoice_relationships
      WHERE  original_invoice_id = l_invoice_id;


      SELECT count(*)
      INTO   l_proposed_interest_count
      FROM   ap_selected_invoices
      WHERE  original_invoice_id = to_char(l_invoice_id); --4388916


      l_inv_curr_int_amt := ap_utilities_pkg.ap_round_currency(
                               l_int_invoice_amt / l_payment_cross_rate,
                               l_invoice_currency_code);

      INSERT INTO ap_selected_invoices_all
           (checkrun_name,
            invoice_id,
            vendor_id,
            vendor_site_id,
            vendor_num,
            vendor_name,
            vendor_site_code,
            address_line1,
            address_line2,
            address_line3,
            address_line4,
            city,
            state,
            zip,
            invoice_num,
            voucher_num,
            ap_ccid,
            payment_priority,
            province,
            country,
            withholding_status_lookup_code,
            attention_ar_flag,
            set_of_books_id,
            invoice_exchange_rate,
            payment_cross_rate,
            customer_num,
            payment_num,
            last_update_date,
            last_updated_by,
            invoice_date,
            invoice_amount,
            amount_remaining,
            amount_paid,
            discount_amount_taken,
            due_date,
            invoice_description,
            discount_amount_remaining,
            payment_amount,
            proposed_payment_amount,
            discount_amount,
            ok_to_pay_flag,
            always_take_discount_flag,
            amount_modified_flag,
            original_invoice_id,
            original_payment_num,
            creation_date,
            created_by,
            exclusive_payment_flag,
            org_id,
            external_bank_account_id,
            checkrun_id,
            payment_currency_code)
      SELECT
            P_checkrun_name,
            ap_invoices_s.NEXTVAL,
            l_vendor_id,
            l_site_id,
            l_int_vendor_num,
            l_int_vendor_name,
            l_site_code,
            l_address_line1,
            l_address_line2,
            l_address_line3,
            l_address_line4,
            l_city,
            l_state,
            l_zip,
            SUBSTRB(SUBSTRB(l_int_invoice_num,
                     1,(50 - LENGTHB('-' || l_nls_int ||
                                     TO_CHAR(l_existing_interest_count +
                                             l_proposed_interest_count + 1))))
             || '-' || l_nls_int || TO_CHAR(l_existing_interest_count +
                                            l_proposed_interest_count + 1),1,50),
            l_voucher_num,
            l_interest_ap_ccid,
            l_payment_priority,
            l_province,
            l_country,
            l_awt_status_lookup_code,
            l_attention_ar_flag,
            l_set_of_books_id,
            l_invoice_exchange_rate,
            l_payment_cross_rate,
            l_customer_num,
            1,
            SYSDATE,
            -- Bug 7383484 (Base bug 7296715)
            -- The User Id is hardcoded to 5 (APPSMGR). It is changed to populate correct value.
            -- '5',
            FND_GLOBAL.USER_ID,
            p_check_date,
            l_inv_curr_int_amt,
            l_int_invoice_amt,
            0,
            0,
            p_check_date,
            SUBSTRB(l_nls_interest|| ' ' || to_char(l_int_invoice_days)
                    || ' ' || l_nls_days || to_char(l_int_invoice_rate)
                    || l_nls_percent,1,50),
            0,
            l_int_invoice_amt,
            l_int_invoice_amt,
            0,
            l_ok_to_pay_flag,
            'N',
            'N',
            l_invoice_id,
            l_payment_num,
            SYSDATE,
            -- Bug 7383484 (Base bug 7296715)
            --'5',
            FND_GLOBAL.USER_ID,
            l_exclusive_payment_flag,
            l_org_id,
            l_external_bank_account_id,
            p_checkrun_id,
            l_pay_currency_code
      FROM sys.dual;

    END IF;

  END LOOP;

  CLOSE interest_cursor;

exception
    WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_checkrun_id: '||
                                           to_char(p_checkrun_id));

    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END;





PROCEDURE remove_all_invoices (p_checkrun_id in number,
                               p_calling_sequence in varchar2) IS
l_debug_info varchar2(2000);
l_current_calling_sequence varchar2(2000);

begin

  l_current_calling_sequence := p_calling_sequence || '<- remove_all_invoices';
  l_debug_info := 'delete unselected invoices';

  delete from ap_unselected_invoices_all
  where checkrun_id = p_checkrun_id;


  l_debug_info := 'deleted selected invoices';

  delete from ap_selected_invoices_all
  where checkrun_id = p_checkrun_id;


  l_debug_info := 'update payment schedules';

  update ap_payment_schedules_all
  set checkrun_id = null
  where checkrun_id = p_checkrun_id;


exception
    WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_checkrun_id: '||
                                           to_char(p_checkrun_id));

    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
end;







PROCEDURE remove_invoices (p_checkrun_id in number,
                           p_calling_sequence in varchar2) IS

cursor c_dont_pay_invoices (p_checkrun_id number) is
--make sure we seed dont pay reason codes
  select invoice_id, payment_num, dont_pay_reason_code, org_id
  from ap_selected_invoices_all
  where checkrun_id = p_checkrun_id
  and ok_to_pay_flag = 'N';

l_debug_info varchar2(2000);
l_current_calling_sequence varchar2(2000);
TYPE r_remove_invoices IS RECORD (invoice_id number(15),
                                  payment_num number(15),
                                  dont_pay_reason_code varchar2(25),
                                  org_id number(15));

type t_remove_invoices is table of r_remove_invoices index by binary_integer;
l_remove_invoices t_remove_invoices;


begin



  l_current_calling_sequence := p_calling_sequence || '<-remove invoices';


  l_debug_info := 'Start of remove_invoices';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;



  OPEN  c_dont_pay_invoices(p_checkrun_id);
  FETCH c_dont_pay_invoices BULK COLLECT INTO l_remove_invoices;
  CLOSE c_dont_pay_invoices;




  if l_remove_invoices.count > 0 then
    for i in l_remove_invoices.first .. l_remove_invoices.last loop

      insert into ap_unselected_invoices_all(
        checkrun_id,
        invoice_id,
        payment_num,
        dont_pay_reason_code,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        org_id)
      values(
        p_checkrun_id,
        l_remove_invoices(i).invoice_id,
        l_remove_invoices(i).payment_num ,
        l_remove_invoices(i).dont_pay_reason_code,
        sysdate,
        5,
        5,
        sysdate,
        l_remove_invoices(i).org_id);



      update ap_payment_schedules_all
      set checkrun_id = null
      where invoice_id = l_remove_invoices(i).invoice_id
      and payment_num = l_remove_invoices(i).payment_num
      and checkrun_id = p_checkrun_id;

      delete from ap_selected_invoices_all
      where invoice_id = l_remove_invoices(i).invoice_id
      and payment_num = l_remove_invoices(i).payment_num
      and checkrun_id = p_checkrun_id;

    end loop;
  end if;
exception
    WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_checkrun_id: '||
                                           to_char(p_checkrun_id));

    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
end;







PROCEDURE insert_unselected(p_payment_process_request_name   in      VARCHAR2,
                            p_hi_payment_priority            in      number,
                            p_low_payment_priority           in      number,
                            p_invoice_batch_id               in      number,
                            p_inv_vendor_id                  in      number,
                            p_inv_exchange_rate_type         in      varchar2,
                            p_payment_method                 in      varchar2,
                            p_supplier_type                  in      varchar2,
                            p_le_group_option                in      varchar2,
                            p_ou_group_option                in      varchar2,
                            p_currency_group_option          in      varchar2,
                            p_pay_group_option               in      varchar2,
                            p_zero_invoices_allowed          in      varchar2,
                            p_check_date                     in      date,
                            p_checkrun_id                    in      number,
                            p_current_calling_sequence       in      varchar2,
                            p_party_id                       in      number
                            ) IS


l_invoice_id number;
l_payment_num number;
l_invoice_status varchar2(50);
l_approval_status   varchar2(50);
l_ps_hold_flag varchar2(1);
l_hold_all_payments_flag varchar2(1);
l_current_calling_sequence varchar2(2000);
l_debug_info varchar2(2000);
l_org_id number(15);
l_due_date date;
l_discount_amount_available number;
l_discount_date date;

 -- DYNAMIC SQL (bug8637005)
l_hint                     VARCHAR2(100);
l_sql_stmt                 LONG;
TYPE refcurtyp     IS      REF CURSOR;
refcur                     REFCURTYP;




BEGIN


  l_current_calling_sequence := p_current_calling_sequence||'<- insert unselected';

  l_debug_info := 'open unselected_invoices';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

    -- Setting the hint string, bug8637005
  IF p_pay_group_option <> 'ALL' THEN
     l_hint := ' /*+ index(inv AP_INVOICES_N3) */ ';
  ELSE
     l_hint := ' ';
  END IF;

  /**************************************************************************/
  /* Bug8637005                                                             */
  /* -----------                                                            */
  /* The query for unselected invoices has been made dynamic for            */
  /* performance improvements, using native dynamic sqls and ref            */
  /* cursors.                                                               */
  /*                                                                        */
  /* Since use of native sql requires a knowledge of the using              */
  /* clause and hence the number of binds before hand, please make          */
  /* sure that any modifications to the sql string, ensures that            */
  /* the number of binds remain constant for all cases of input             */
  /* parameters (selection criteria)                                        */
  /*                                                                        */
  /* Currently this has been achieved using:                                */
  /*    nvl(bind, -9999) = -9999                                            */
  /*                                                                        */
  /* If for some reason it is not feasible to achieve a constant number     */
  /* for a later change please connsider                                    */
  /*   a. Eliminating binds, by joing to ap_invoice_selection_criteria_all  */
  /*   b. Using DBMS_SQL                                                    */
  /**************************************************************************/



  l_sql_stmt :=
        '       SELECT  '||l_hint||' '||
        '              ai.invoice_id, '||
        '              ps.payment_num, '||
        '              ps.hold_flag, '||
        '              sites.hold_all_payments_flag, '||
        '              ap_utilities_pkg.get_invoice_status(ai.invoice_id, null), '||
        '              ai.wfapproval_status, '||
        '              ai.org_id, '||
        '              ps.due_date, '||
        '              ps.discount_amount_available, '||
        '              ps.discount_date '||
        '       FROM   ap_supplier_sites_all sites, '||
        '              ap_invoices ai,  '||       /* inv,  '|| Commented for bug#9182499 GSCC Error File.Sql.6 Bug6040657. Changed from ap_invoices_all to ap_invoices */
        '              ap_payment_schedules ps, '||
        '              ap_suppliers suppliers, '||
        '              hz_parties hz '||
        '       where  ai.invoice_id = ps.invoice_id '||
        '       AND    sites.vendor_site_id(+) = ai.vendor_site_id '||
        '       AND    suppliers.vendor_id(+) = ai.vendor_id '||
        '       AND    ai.party_id = hz.party_id '||
        '       AND    ps.payment_status_flag BETWEEN ''N'' AND ''P'' '||
        '       AND    ai.payment_status_flag BETWEEN ''N'' AND ''P'' '||
        '       AND    NVL(ps.payment_priority, 99) BETWEEN :p_hi_payment_priority '||
        '                                              AND :p_low_payment_priority '||
        '       AND    ai.cancelled_date is null ';
                -- Bug 5649608
                --AND    nvl(inv.batch_id,-99) = nvl(p_invoice_batch_id,-99)

  IF p_invoice_batch_id IS NOT NULL THEN
     l_sql_stmt := l_sql_stmt||'              AND  ai.batch_id = :p_inv_batch_id ';
  ELSE
     l_sql_stmt := l_sql_stmt||'              AND  nvl(:p_inv_batch_id, -9999) = -9999 ';
  END IF;

  IF p_inv_vendor_id IS NOT NULL THEN
     l_sql_stmt := l_sql_stmt||'       AND    ai.vendor_id = :p_inv_vendor_id  ';
  ELSE
     l_sql_stmt := l_sql_stmt||'       AND    nvl(:p_inv_vendor_id, -9999) = -9999 ';
  END IF;

  IF p_party_id IS NOT NULL THEN
     l_sql_stmt := l_sql_stmt||'       AND    ai.party_id = :p_party_id ';
  ELSE
     l_sql_stmt := l_sql_stmt||'       AND    nvl(:p_party_id, -9999) = -9999 ';
  END IF;

                -- Bug 5507013 hkaniven start --
  l_sql_stmt := l_sql_stmt||
        '       AND    (( :p_inv_exchange_rate_type = ''IS_USER'' AND NVL(ai.exchange_rate_type,''NOT USER'') = ''User'' ) '||
        '               OR (:p_inv_exchange_rate_type = ''IS_NOT_USER'' AND NVL(ai.exchange_rate_type,''NOT USER'') <> ''User'') '||
        '               OR (:p_inv_exchange_rate_type IS NULL)) '||
                -- Bug 5507013 hkaniven end --
        '       AND    ps.payment_method_code = nvl(:p_payment_method, ps.payment_method_code) '||
        '       AND    nvl(suppliers.vendor_type_lookup_code,-99) = '||
        '                   nvl(:p_supplier_type, nvl(suppliers.vendor_type_lookup_code,-99)) '||
        '       AND    (ai.legal_entity_id in (select /*+ push_subq */ legal_entity_id '||
        '                                       from   ap_le_group '||
        '                                       where  checkrun_id = :p_checkrun_id) '||
        '               or :p_le_group_option = ''ALL'') '||
        '       AND    (ai.org_id in (select /*+ push_subq */ org_id '||
        '                              from   AP_OU_GROUP '||
        '                              where  checkrun_id = :p_checkrun_id) '||
        '               or :p_ou_group_option = ''ALL'') '||
        '       AND    (ai.payment_currency_code in (select /*+ push_subq */ currency_code '||
        '                                             from   AP_CURRENCY_GROUP '||
        '                                             where  checkrun_id = :p_checkrun_id) '||
        '               or :p_currency_group_option = ''ALL'') ';

  IF p_pay_group_option <> 'ALL' THEN
     l_sql_stmt := l_sql_stmt||
         /* Commented for Bug#9182499 Start
         '       AND    inv.pay_group_lookup_code in (select / *+ leading(apg) cardinality(apg 1) * / vendor_pay_group '||
         '                                            from   AP_PAY_GROUP apg'||     --bug9087739, added alias for  AP_PAY_GROUP
         '                                            where  checkrun_id BETWEEN :p_checkrun_id AND :p_checkrun_id) ';
         Commented for Bug#9182499 End */
         /* Added for Bug#9182499 Start */
         '       AND (ai.pay_group_lookup_code, ai.org_id) in '||
         '                       ( select /*+ leading(apg) cardinality(apg 1) */ '||
         '                                apg.vendor_pay_group, mo.ORGANIZATION_ID '||
         '                           from AP_PAY_GROUP apg, MO_GLOB_ORG_ACCESS_TMP mo '||
         '                          where checkrun_id BETWEEN :p_checkrun_id AND :p_checkrun_id) ';
         /* Added for Bug#9182499 End */

  ELSE
     l_sql_stmt := l_sql_stmt||
         '       AND    :p_checkrun_id = :p_checkrun_id   ';
  END IF;

  l_sql_stmt := l_sql_stmt||
        '       AND    ((:p_zero_invoices_allowed = ''N'' AND ps.amount_remaining <> 0) OR '||
        '                :p_zero_invoices_allowed = ''Y'') '||
        '       and     ps.checkrun_id is null ';


  OPEN refcur FOR l_sql_stmt USING p_hi_payment_priority,
                                   p_low_payment_priority,
                                   p_invoice_batch_id,
                                   p_inv_vendor_id,
                                   p_party_id,
                                   p_inv_exchange_rate_type,
                                   p_inv_exchange_rate_type,
                                   p_inv_exchange_rate_type,
                                   p_payment_method,
                                   p_supplier_type,
                                   p_checkrun_id,
                                   p_le_group_option,
                                   p_checkrun_id,
                                   p_ou_group_option,
                                   p_checkrun_id,
                                   p_currency_group_option,
                                   p_checkrun_id,
                                   p_checkrun_id,
                                   p_zero_invoices_allowed,
                                   p_zero_invoices_allowed;
  loop
    fetch refcur into l_invoice_id,
                                   l_payment_num,
                                   l_ps_hold_flag,
                                   l_hold_all_payments_flag,
                                   l_invoice_status,
                                   l_approval_status,
                                   l_org_id,
                                   l_due_date,
                                   l_discount_amount_available,
                                   l_discount_date;


    exit when refcur%notfound;


    --Needs Invoice Validation
    if l_invoice_status in ('NEVER APPROVED', 'UNAPPROVED')  then

      insert into ap_unselected_invoices_all(
        checkrun_id,
        invoice_id,
        payment_num,
        dont_pay_reason_code,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        org_id)
      values(
        p_checkrun_id,
        l_invoice_id,
        l_payment_num ,
        'NEEDS_INVOICE_VALIDATION',
        sysdate,
        5,
        5,
        sysdate,
        l_org_id);

    end if;


    --Failed Invoice Validation
    if l_invoice_status = 'NEEDS REAPPROVAL' then

      insert into ap_unselected_invoices(
        checkrun_id,
        invoice_id,
        payment_num,
        dont_pay_reason_code,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        org_id)
      values(
        p_checkrun_id,
        l_invoice_id,
        l_payment_num ,
        'FAILED_INVOICE_VALIDATION',
        sysdate,
        5,
        5,
        sysdate,
        l_org_id);

    end if;


    --Needs Approval
    if l_approval_status in ('INITIATED','REQUIRED','NEEDS WFREAPPROVAL') then


      insert into ap_unselected_invoices(
        checkrun_id,
        invoice_id,
        payment_num,
        dont_pay_reason_code,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        org_id)
      values(
        p_checkrun_id,
        l_invoice_id,
        l_payment_num ,
        'NEEDS_APPROVAL',
        sysdate,
        5,
        5,
        sysdate,
        l_org_id);

    end if;




    --Approver Rejected
    if l_approval_status = 'REJECTED' then

      insert into ap_unselected_invoices(
        checkrun_id,
        invoice_id,
        payment_num,
        dont_pay_reason_code,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        org_id)
      values(
        p_checkrun_id,
        l_invoice_id,
        l_payment_num ,
        'APPROVER_REJECTED',
        sysdate,
        5,
        5,
        sysdate,
        l_org_id);
    end if;

    --Scheduled Payment Hold
    if l_ps_hold_flag = 'Y' then

      insert into ap_unselected_invoices(
        checkrun_id,
        invoice_id,
        payment_num,
        dont_pay_reason_code,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        org_id)
      values(
        p_checkrun_id,
        l_invoice_id,
        l_payment_num ,
        'SCHEDULED_PAYMENT_HOLD',
        sysdate,
        5,
        5,
        sysdate,
        l_org_id);
    end if;



    --Supplier Site Hold
    if l_hold_all_payments_flag = 'Y' then

      insert into ap_unselected_invoices(
        checkrun_id,
        invoice_id,
        payment_num,
        dont_pay_reason_code,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        org_id)
      values(
        p_checkrun_id,
        l_invoice_id,
        l_payment_num ,
        'SUPPLIER_SITE_HOLD',
        sysdate,
        5,
        5,
        sysdate,
        l_org_id);
    end if;


    --Discount Rate Too Low
      --4745133, can't call the ebd check in the cursor so doing it here.
      insert into ap_unselected_invoices(
        checkrun_id,
        invoice_id,
        payment_num,
        dont_pay_reason_code,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        org_id)
      select
        p_checkrun_id,
        l_invoice_id,
        l_payment_num ,
        'DISCOUNT_RATE_TOO_LOW',
        sysdate,
        5,
        5,
        sysdate,
        l_org_id
      from dual
       where fv_econ_benf_disc.ebd_check(p_payment_process_request_name, l_invoice_id,
                                         p_check_date, l_due_date, l_discount_amount_available, l_discount_date) = 'N';


  end loop;

  close refcur;



EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_payment_process_request_name: '||
                                           p_payment_process_request_name);


    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END INSERT_UNSELECTED;



--this procedure groups invoices AP wants to ensure get paid together.
--it follows the grouping logic Oracle Payments currently has

PROCEDURE group_interest_credits (p_checkrun_id                    IN      VARCHAR2,
                                  p_current_calling_sequence       IN      VARCHAR2
                                  ) IS



cursor c_documents (p_checkrun_id number) is
select nvl(asi.exclusive_payment_flag,'N')exclusive_payment_flag,
       asi.org_id,
       asi.payment_amount,
       asi.vendor_site_id,
       ai.party_id,
       ai.party_site_id,
       asi.payment_currency_code,
       aps.payment_method_code,
       nvl(aps.external_bank_account_id,-99) external_bank_account_id,
       -- As per the discussion with Omar/Jayanta, we will only
       -- have payables payment function and no more employee expenses
       -- payment function.
       nvl(ai.payment_function, 'PAYABLES_DISB') payment_function,
       nvl(ai.pay_proc_trxn_type_code, decode(ai.invoice_type_lookup_code,'EXPENSE REPORT',
                                           'EMPLOYEE_EXP','PAYABLES_DOC')) pay_proc_trxn_type_code,
       asi.invoice_id,
       asi.payment_num,
       asi.payment_grouping_number,
       NVL(asi.ok_to_pay_flag,'Y') ok_to_pay_flag,
       asi.proposed_payment_amount,
       fv.beneficiary_party_id,  --5017076
       ipm.support_bills_payable_flag,   -- Bug 5357689, 5479979
       (trunc(aps.due_date) + nvl(ipm.maturity_date_offset_days,0)) due_date -- Bug 5357689
                                  --Bug 543942 added NVL in the above scenario
from   ap_selected_invoices_all asi,
       ap_invoices ai, --Bug6040657. Changed from ap_invoices_all to ap_invoices
       ap_inv_selection_criteria_all aisc,
       ap_payment_schedules_all aps,
       fv_tpp_assignments_v fv, --5017076
       iby_payment_methods_vl ipm -- Bug 5357689
where  asi.invoice_id = ai.invoice_id
and    aps.invoice_id = asi.invoice_id
and    aps.payment_num = asi.payment_num
and    asi.checkrun_name = aisc.checkrun_name
and    nvl(asi.ok_to_pay_flag,'Y') = 'Y'
and    aisc.checkrun_id= p_checkrun_id
and    asi.original_invoice_id is null
and    fv.beneficiary_supplier_id(+) = ai.vendor_id
and    fv.beneficiary_supplier_site_id(+) = ai.vendor_site_id
and    ipm.payment_method_code = aps.payment_method_code -- Bug 5357689
/* order by asi.exclusive_payment_flag, */  -- bug8440703
order by nvl(asi.exclusive_payment_flag,'N'), -- bug8440703
       asi.org_id,
       asi.vendor_site_id,
       ai.party_id,
       ai.party_site_id,
       asi.payment_currency_code,
       aps.payment_method_code,
       aps.external_bank_account_id,
       payment_function,
       pay_proc_trxn_type_code,
       fv.beneficiary_party_id,
       SIGN(asi.invoice_amount) DESC,  --this will make credit memos last per group
       asi.due_date,   -- Bug 5479979
         /*  DECODE(SIGN(asi.invoice_amount),
                -1, TO_CHAR(asi.due_date,'YYYYMMDD'),
                asi.invoice_num), */
       asi.payment_num;



TYPE r_documents IS RECORD (exclusive_payment_flag varchar2(1),
                            org_id number(15),
                            payment_amount number,
                            vendor_site_id number(15),
                            party_id number(15),
                            party_site_id number(15),
                            payment_currency_code varchar2(15),
                            payment_method varchar2(30),
                            external_bank_account_id number(15),
                            payment_function varchar2(30),
                            pay_proc_trxn_type_code varchar2(30),
                            invoice_id number(15),
                            payment_num number(15),
                            payment_grouping_number number(15),
                            ok_to_pay_flag varchar2(1),
                            proposed_payment_amount number,
                            beneficiary_party_id number,  --5017076
                            support_bills_payable_flag varchar2(1),  -- Bug 5357689
                            due_date date);  -- Bug 5357689

type t_documents is table of r_documents index by binary_integer;
l_documents t_documents;


l_prev_exclusive_payment_flag varchar2(1);
l_prev_org_id number(15);
l_prev_payment_amount number;
l_prev_vendor_site_id number(15);
l_prev_party_id number(15);
l_prev_party_site_id number(15);
l_prev_payment_currency_code varchar2(15);
l_prev_payment_method varchar2(30);
l_prev_ext_bank_acct_id number(15);
l_prev_payment_function varchar2(30);
l_prev_pay_proc_trxn_type_code varchar2(30);
l_prev_grouping_number number;
l_prev_beneficiary_party_id number;
l_prev_bills_payable_flag varchar2(1);  -- Bug 5357689
l_prev_due_date date;                   -- Bug 5357689

l_grouping_number number;
l_payment_sum number := 0;
l_remove_cm_flag varchar2(1);
l_current_calling_sequence varchar2(2000);
l_debug_info varchar2(2000);

l_maximize_credits_flag varchar2(1); --5007819
l_payment_profile_id number; -- Added for bug 9089243
l_group_by_due_date_flag varchar2(1); -- Added for bug 9089243


BEGIN
  l_current_calling_sequence := p_current_calling_sequence||'<-group interest credits';
  l_debug_info := 'open c_documents';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  OPEN  c_documents(p_checkrun_id);
  FETCH c_documents BULK COLLECT INTO l_documents;
  CLOSE c_documents;

  if l_documents.count = 0 then
    return;
  end if;

  l_grouping_number := 1;
  l_remove_cm_flag := 'N';

  --5007819
  select nvl(zero_amounts_allowed,'N'), payment_profile_id
  into l_maximize_credits_flag, l_payment_profile_id -- Added for bug 9089243
  from ap_inv_selection_criteria_all
  where checkrun_id = p_checkrun_id;

  -- Added for bug 9089243
  if (l_payment_profile_id is not null) then
    select nvl(ibcr.group_by_due_date_flag,'N')
    into l_group_by_due_date_flag
    from  iby_acct_pmt_profiles_b ibpp, IBY_PMT_CREATION_RULES ibcr
    where ibpp.system_profile_code = ibcr.system_profile_code
    and ibpp.payment_profile_id = l_payment_profile_id;
  else
    l_group_by_due_date_flag := 'N';
  end if;

  l_debug_info := 'Group_by_due_date flag :'||l_group_by_due_date_flag;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  -- Bug 9089243 ends

  l_debug_info := 'group all documents';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  --initialize the previous variables

    l_prev_org_id := l_documents(1).org_id;
    l_prev_exclusive_payment_flag := l_documents(1).exclusive_payment_flag;
    l_prev_payment_amount := l_documents(1).payment_amount;
    l_prev_vendor_site_id := l_documents(1).vendor_site_id;
    l_prev_party_id := l_documents(1).party_id;
    l_prev_party_site_id := l_documents(1).party_site_id;
    l_prev_payment_currency_code := l_documents(1).payment_currency_code;
    l_prev_payment_method := l_documents(1).payment_method;
    l_prev_ext_bank_acct_id := l_documents(1).external_bank_account_id;
    l_prev_payment_function := l_documents(1).payment_function;
    l_prev_pay_proc_trxn_type_code := l_documents(1).pay_proc_trxn_type_code;
    l_prev_beneficiary_party_id := l_documents(1).beneficiary_party_id;
    l_prev_bills_payable_flag   := l_documents(1).support_bills_payable_flag;  -- Bug 5357689
    l_prev_due_date  := l_documents(1).due_date;  -- Bug 5357689

  for i in l_documents.first .. l_documents.last loop

    if l_documents(i).exclusive_payment_flag = 'Y' or
       l_prev_exclusive_payment_flag = 'Y' or
       l_prev_org_id <> l_documents(i).org_id or
       nvl(l_prev_vendor_site_id,-1) <> nvl(l_documents(i).vendor_site_id,-1) or
       l_prev_party_id <>l_documents(i).party_id or
       l_prev_party_site_id <> l_documents(i).party_site_id or
       l_prev_payment_currency_code <> l_documents(i).payment_currency_code or
       l_prev_payment_method <> l_documents(i).payment_method or
       nvl(l_prev_ext_bank_acct_id,-1) <> nvl(l_documents(i).external_bank_account_id,-1) or
       l_prev_payment_function <> l_documents(i).payment_function or
       --l_prev_pay_proc_trxn_type_code <> l_documents(i).pay_proc_trxn_type_code or
       /*Commented by zrehman for bug#7427845 on 20-Oct-2008*/
       nvl(l_prev_beneficiary_party_id,-1) <> nvl(l_documents(i).beneficiary_party_id,-1) or
       /* Bug 5357689 , 5479979 */
       ((l_documents(i).support_bills_payable_flag = 'Y') and
        (l_documents(i).payment_amount >= 0) and
        (trunc(l_prev_due_date)  <> trunc(l_documents(i).due_date)) and
	(l_group_by_due_date_flag = 'Y')) -- Added for bug 9089243
    then

       l_grouping_number := l_grouping_number + 1;
       l_payment_sum := 0;
       l_remove_cm_flag := 'N';
     end if;

     l_documents(i).payment_grouping_number := l_grouping_number;

     l_prev_org_id := l_documents(i).org_id;
     l_prev_exclusive_payment_flag := l_documents(i).exclusive_payment_flag;
     l_prev_payment_amount := l_documents(i).payment_amount;
     l_prev_vendor_site_id := l_documents(i).vendor_site_id;
     l_prev_party_id := l_documents(i).party_id;
     l_prev_party_site_id :=  l_documents(i).party_site_id;
     l_prev_payment_currency_code :=  l_documents(i).payment_currency_code;
     l_prev_payment_method :=  l_documents(i).payment_method;
     l_prev_ext_bank_acct_id :=  l_documents(i).external_bank_account_id;
     l_prev_payment_function :=  l_documents(i).payment_function;
     l_prev_pay_proc_trxn_type_code := l_documents(i).pay_proc_trxn_type_code;
     l_prev_beneficiary_party_id := l_documents(i).beneficiary_party_id;
     l_prev_bills_payable_flag   := l_documents(i).support_bills_payable_flag;  -- Bug 5357689
     l_prev_due_date  := l_documents(i).due_date; -- Bug 5357689

  end loop;


  --5007819
  if l_maximize_credits_flag = 'Y' then

    l_debug_info := 'reduce credit memo amounts';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;

    --now everything should be grouped, let's go through and determine which
    --credit memos need to be reduced or set to not pay

    --initialize the previous grouping number
    l_prev_grouping_number := l_documents(1).payment_grouping_number;

    for i in l_documents.first .. l_documents.last loop
      --Bug 7371792 --
      l_documents(i).payment_amount := l_documents(i).proposed_payment_amount;

      if l_documents(i).payment_grouping_number = l_prev_grouping_number then

        l_payment_sum := l_payment_sum + l_documents(i).payment_amount;

        if l_payment_sum < 0 then
          if l_remove_cm_flag <> 'Y' then
           --if are here we have a credit memo that just took
           --the total payment amount below zero
           --the code below will set the proposed payment amount for the credit memo
           --so that the total for this grouping_number is zero
           l_documents(i).proposed_payment_amount := l_documents(i).payment_amount - l_payment_sum;


           --4688545 this will handle the case where the very first record
           --in the pl/sql table is is a credit memo
           if l_documents(i).proposed_payment_amount = 0 then
             l_documents(i).ok_to_pay_flag := 'N';
           end if;

           l_remove_cm_flag := 'Y';
           l_payment_sum := 0;

          else
            l_documents(i).ok_to_pay_flag := 'N';
          end if;
        end if;


      else
        --we are at a new payment, reset the sum
        --and if just a single credit memo then set it's ok to pay flag to 'N'
        l_payment_sum := l_documents(i).payment_amount;  -- Bug 5479979

        if l_documents(i).payment_amount < 0 then
          l_documents(i).ok_to_pay_flag := 'N';
          --bug 8511962 if the first document of the group is a credit
          --memo, we need to set the l_remove_cm_flag to Y so that if
          --there are subsequent credit memos in the group they get
          --removed as well. If this is the only document in the group
          --the flag will get reset for the next group on the next
          --iteration in the else immediately following.
          l_remove_cm_flag := 'Y';
        else
          --bug 8511962 l_remove_cm_flag needs to be reset for each payment
          l_remove_cm_flag := 'N';
        end if;

      end if;

      l_prev_grouping_number := l_documents(i).payment_grouping_number;

    end loop;

  end if; --5007819


  l_debug_info := 'update grouping numbers, ok to pay flags, and amounts';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;




  --IBY isn't using proposed_payment_amount so we need to set the payment
  --amount here
  -- 7371792 proposed_payment_amount contains original
  -- payment_amount. Later we reset the payment_amount

  for i in l_documents.first .. l_documents.last loop
    /* Added the hint INDEX(AP_SELECTED_INVOICES_ALL,AP_SELECTED_INVOICES_N1) for bug#8368922 */
    update /*+ INDEX(AP_SELECTED_INVOICES_ALL,AP_SELECTED_INVOICES_N1) */ ap_selected_invoices_all
    set    payment_grouping_number = l_documents(i).payment_grouping_number,
           ok_to_pay_flag = l_documents(i).ok_to_pay_flag,
           -- proposed_payment_amount = l_documents(i).proposed_payment_amount, 7371792
           payment_amount = l_documents(i).proposed_payment_amount,
           dont_pay_reason_code = decode(l_documents(i).ok_to_pay_flag,'N',
                                         'CREDIT TOO LOW',null),
           last_update_date = sysdate,
           -- Bug 7383484 (Base bug 7296715)
           -- last_updated_by = 5
           last_updated_by = FND_GLOBAL.USER_ID,
           due_date = l_documents(i).due_date  -- Bug 5357689
    where  invoice_id  = l_documents(i).invoice_id
    and    payment_num = l_documents(i).payment_num
    and    checkrun_id= p_checkrun_id;
  end loop;



  --handle interest invoices where federal is not installed
  --bug 5233279
  update ap_selected_invoices_all asi
  set payment_grouping_number =
    (select asi2.payment_grouping_number
     from ap_selected_invoices_all asi2
     where asi2.invoice_id = asi.original_invoice_id
     and asi2.payment_num = asi.original_payment_num
     and asi2.checkrun_id = p_checkrun_id)
  where asi.checkrun_id = p_checkrun_id
  and asi.original_invoice_id is not null
  and Ap_Payment_Util_Pkg.is_federal_installed(asi.org_id) = 'N';



  --5007819
  --Bug 5277604. Selected Invoices will
  --will be only unselected table if total payment
  --amount goes below zero.
  if l_maximize_credits_flag <> 'Y' then
    update ap_selected_invoices_all asi
    set ok_to_pay_flag = 'N',
        dont_pay_reason_code = 'CREDIT TOO LOW',
        last_update_date = sysdate,
        -- Bug 7383484 (Base bug 7296715)
        -- last_updated_by = 5
        last_updated_by = FND_GLOBAL.USER_ID
    where checkrun_id = p_checkrun_id
    and payment_grouping_number in
      (select asi2.payment_grouping_number
       from ap_selected_invoices_all asi2
       where asi2.checkrun_id = p_checkrun_id
       group by asi2.payment_grouping_number
       having sum(asi2.payment_amount) < 0);
  end if;


 --now remove the grouping numbers where no interest invoice is involved
  --or no credit memo is involved
  --Bug 8275467 added HASH_AJ hint

  UPDATE Ap_Selected_Invoices_All ASI
  SET    payment_grouping_number = null
  WHERE  payment_grouping_number NOT IN (
    SELECT /*+ HASH_AJ */ payment_grouping_number
    FROM   Ap_Selected_Invoices_All ASI2
    WHERE  (ASI2.original_invoice_id is not null or
            ASI2.payment_amount < 0)
    AND    ASI2.ok_to_pay_flag = 'Y'
    AND    ASI2.checkrun_id = p_checkrun_id
    AND    ASI2.payment_grouping_number IS NOT NULL)
  AND  ASI.checkrun_id = p_checkrun_id
  AND  ASI.payment_grouping_number IS NOT NULL;

  --Bug 5646890, Following Update is replaed by updated above as per performance team
  --now remove the grouping numbers where no interest invoice is involved
  --or no credit memo is involved
  /*update ap_selected_invoices_all asi
  set payment_grouping_number = null
  where payment_grouping_number not in (
    select payment_grouping_number
    from ap_selected_invoices_all asi2
    where (asi2.original_invoice_id is not null or
           asi2.payment_amount < 0)
    and asi2.ok_to_pay_flag = 'Y'
    and checkrun_id = p_checkrun_id)
  and checkrun_id = p_checkrun_id; */

  --now remove the grouping numbers where  interest invoice is involved
  --but federal is installed. Bug 5233279.
  -- Bug 5645890, Added extra condition payment_grouping_number is not null

  update ap_selected_invoices_all asi
  set payment_grouping_number = null
  where  asi.checkrun_id = p_checkrun_id
  and    asi.payment_grouping_number is not null
  and Ap_Payment_Util_Pkg.is_federal_installed(asi.org_id) = 'Y'
  and exists (
    select /*+NO_UNNEST */ NULL
    from ap_selected_invoices_all asi2
    where asi2.original_invoice_id is not null
    and asi2.original_invoice_id = asi.invoice_id
    and asi2.ok_to_pay_flag = 'Y'
    and asi2.checkrun_id = p_checkrun_id);


  --bug 5233279. Now set the pay alone flag to 'N' for all invoices
  --when federal is not installed  and has related interest invoice
  -- Bug 5645890, Added the hint
  update ap_selected_invoices_all asi
  set exclusive_payment_flag = 'N'
  where asi.checkrun_id = p_checkrun_id
  and Ap_Payment_Util_Pkg.is_federal_installed(asi.org_id) = 'N'
  and exists (
    select  NULL
    from ap_selected_invoices_all asi2
    where asi2.original_invoice_id is not null
    and asi2.original_invoice_id = asi.invoice_id
    and asi2.ok_to_pay_flag = 'Y'
    and asi2.checkrun_id = p_checkrun_id);


EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END GROUP_INTEREST_CREDITS;


Procedure create_checkrun   (p_checkrun_id                  out nocopy number,
                             p_template_id                  in number,
                             p_payment_date                 in date,
                             p_pay_thru_date                in date,
                             p_pay_from_date                in date,
                             p_current_calling_sequence     in varchar2) is



  l_current_calling_sequence varchar2(2000);
  l_debug_info varchar2(2000);

begin

  l_current_calling_sequence := p_current_calling_sequence || '<-create_checkrun';

  l_debug_info := 'select checkrun_id';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;


  select ap_inv_selection_criteria_s.nextval
  into p_checkrun_id
  from dual;



  l_debug_info := 'insert into ap_inv_selection_criteria_all';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  insert into ap_inv_selection_criteria_all(
           check_date,
           pay_thru_date,
           hi_payment_priority,
           low_payment_priority,
           pay_only_when_due_flag,
           status,
           zero_amounts_allowed,  --uncommented for Bug 8899870
           zero_invoices_allowed,
           vendor_id,
           checkrun_id,
           pay_from_date,
           inv_exchange_rate_type,
           exchange_rate_type, --Bug6829191
           payment_method_code,
           vendor_type_lookup_code,
           CREATE_INSTRS_FLAG,
           PAYMENT_PROFILE_ID,
           bank_account_id,
           checkrun_name,
           ou_group_option,
           le_group_option,
           currency_group_option,
           pay_group_option,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           template_flag,
           template_id,
           payables_review_settings,
           payments_review_settings,
           document_rejection_level_code,
           payment_rejection_level_code,
           party_id,
           request_id, --4737467
           payment_document_id, --7315136
           transfer_priority, --7315136
           ATTRIBUTE_CATEGORY, -- begin 8935712
           ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15 -- end 8935712
           )
  select   nvl(p_payment_date,sysdate), --4681989
           nvl(p_pay_thru_date, sysdate + ADDL_PAY_THRU_DAYS),--4681989
           hi_payment_priority,
           low_payment_priority,
           pay_only_when_due_flag,
           'UNSTARTED',
           zero_amounts_allowed,  --uncommented for Bug 8899870
           ZERO_INV_ALLOWED_FLAG,
           vendor_id,
           p_checkrun_id,
           nvl(p_pay_from_date, sysdate - ADDL_PAY_FROM_DAYS), --4681989
           inv_exchange_rate_type,
           payment_exchange_rate_type, --Bug6829191
           payment_method_code,
           vendor_type_lookup_code,
           CREATE_INSTRS_FLAG,
           PAYMENT_PROFILE_ID,
           BANK_ACCOUNT_ID,
           template_name ||'-'||to_char(sysdate, 'DD-MON-RRRR HH24:MI:SS'),
           ou_group_option,
           le_group_option,
           currency_group_option,
           pay_group_option,
           sysdate,
           last_updated_by,
           last_update_login,
           sysdate,
           created_by,
           'Y',
           p_template_id,
           payables_review_settings,
           payments_review_settings,
           document_rejection_level_code,
           payment_rejection_level_code,
           party_id,
           fnd_global.conc_request_id,  --4737467
           payment_document_id, --7315136
           transfer_priority, --7315136
           ATTRIBUTE_CATEGORY, -- begin 8885918
           ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15 -- end 8885918
  from     AP_PAYMENT_TEMPLATES
  where    template_id = p_template_id;


  l_debug_info := 'insert into ap_le_group';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  insert into ap_le_group (
           legal_entity_id,
           checkrun_id,
           LE_GROUP_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
  select   legal_entity_id,
           p_checkrun_id,
           AP_LE_GROUP_S.nextval,
           sysdate,
           alg.created_by,
           sysdate,
           alg.last_updated_by
  from     ap_le_group alg,
           ap_payment_templates appt
  where    alg.template_id = p_template_id
  and      alg.template_id = appt.template_id
  and      appt.le_group_option = 'SPECIFY';


  l_debug_info := 'insert into AP_OU_GROUP';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  insert into AP_OU_GROUP (
           org_id,
           checkrun_id,
           OU_GROUP_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
  select   aog.org_id,
           p_checkrun_id,
           AP_OU_GROUP_S.nextval,
           sysdate,
           aog.created_by,
           sysdate,
           aog.last_updated_by
  from     ap_ou_group aog,
           ap_payment_templates appt
  where    aog.template_id = p_template_id
  and      aog.template_id = appt.template_id
  and      appt.ou_group_option = 'SPECIFY';

  l_debug_info := 'insert into AP_CURRENCY_GROUP';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;


  insert into AP_CURRENCY_GROUP (
           currency_code,
           checkrun_id,
           CURRENCY_GROUP_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
  select   currency_code,
           p_checkrun_id,
           AP_CURRENCY_GROUP_S.nextval,
           sysdate,
           acg.created_by,
           sysdate,
           acg.last_updated_by
  from     AP_CURRENCY_GROUP acg,
           ap_payment_templates appt
  where    acg.template_id = p_template_id
  and      acg.template_id = appt.template_id
  and      appt.currency_group_option = 'SPECIFY';--Bug6926344

  l_debug_info := 'insert into AP_PAY_GROUP';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  insert into AP_PAY_GROUP (
           vendor_pay_group,
           checkrun_id,
           PAY_GROUP_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
  select   vendor_pay_group,
           p_checkrun_id,
           AP_PAY_GROUP_S.nextval,
           sysdate,
           apg.created_by,
           sysdate,
           apg.last_updated_by
  from     AP_PAY_GROUP apg,
           ap_payment_templates appt
  where    apg.template_id = p_template_id
  and      apg.template_id = appt.template_id
  and      appt.pay_group_option = 'SPECIFY'; --Bug6926344



EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_template_id= '||
                                           to_char(p_template_id));


    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

end create_checkrun;









PROCEDURE select_invoices   (errbuf             OUT NOCOPY VARCHAR2,
                             retcode            OUT NOCOPY NUMBER,
                             p_checkrun_id      in            varchar2,
                             P_template_id      in            varchar2,
                             p_payment_date     in            varchar2,
                             p_pay_thru_date    in            varchar2,
                             p_pay_from_date    in            varchar2)  IS

  l_abort                    varchar2(1);
  l_api_name                 CONSTANT  VARCHAR2(100) := 'SELECT_INVOICES';
  l_base_currency_code       varchar2(15);
  l_batch_exchange_rate_type varchar2(30);
  l_batch_status             varchar2(30);
  l_bank_account_id          number; --4710933
  l_check_date               date;
  l_check_date_char          VARCHAR2(100);
  l_checkrun_id              number;
  l_count_inv_selected       number;
  l_create_instrs_flag       varchar2(1);
  l_currency_group_option    varchar2(10);
  l_current_calling_sequence   VARCHAR2(2000);
  l_debug_info               VARCHAR2(2000);
  l_disc_pay_thru_date       date;
  l_disc_pay_thru_char       VARCHAR2(100);
  l_doc_rejection_level_code varchar2(30);
  l_encumbrance_flag         number;
  l_hi_payment_priority      number;
  l_inv_exchange_rate_type   varchar2(30);
  l_inv_vendor_id            number;
  l_invoice_batch_id         number;
  l_le_group_option          varchar2(10);
  l_log_module               varchar2(240);
  l_low_payment_priority     number;
  l_max_payment_amount       number;
  l_min_check_amount         number;
  l_missing_rates_count      number;
  l_ou_group_option          varchar2(10);
  l_party_id                 number(15);
  l_pay_from_date            date;
  l_pay_from_date_char       VARCHAR2(100);
  l_pay_group_option         varchar2(10);
  l_pay_rejection_level_code varchar2(30);
  l_pay_review_settings_flag varchar2(1);
  l_pay_thru_date            date;
  l_pay_thru_date_char       VARCHAR2(100);
  l_payables_review_settings varchar2(1);
  l_payment_date             date;
  l_payment_document_id      number(15); --4939405
  l_payment_method           varchar2(30);
  l_payment_process_request_name varchar2(240);
  l_payment_profile_id       number;
  l_req_id                   number;
  l_set_of_books_name        varchar2(30);
  l_supplier_type            varchar2(30);
  l_template_id              number;
  l_zero_amounts_allowed     varchar2(1);
  l_zero_invoices_allowed    varchar2(1);
  SELECTION_FAILURE          EXCEPTION;
  l_xml_output               BOOLEAN;
  l_iso_language             FND_LANGUAGES.iso_language%TYPE;
  l_iso_territory            FND_LANGUAGES.iso_territory%TYPE;
  l_template_code       Fnd_Concurrent_Programs.template_code%TYPE; -- Bug 6969710
  /*bug 7519277*/
  l_ATTRIBUTE_CATEGORY       VARCHAR2(150);
  l_ATTRIBUTE1               VARCHAR2(150);
  l_ATTRIBUTE2               VARCHAR2(150);
  l_ATTRIBUTE3               VARCHAR2(150);
  l_ATTRIBUTE4               VARCHAR2(150);
  l_ATTRIBUTE5               VARCHAR2(150);
  l_ATTRIBUTE6               VARCHAR2(150);
  l_ATTRIBUTE7               VARCHAR2(150);
  l_ATTRIBUTE8               VARCHAR2(150);
  l_ATTRIBUTE9               VARCHAR2(150);
  l_ATTRIBUTE10              VARCHAR2(150);
  l_ATTRIBUTE11              VARCHAR2(150);
  l_ATTRIBUTE12              VARCHAR2(150);
  l_ATTRIBUTE13              VARCHAR2(150);
  l_ATTRIBUTE14              VARCHAR2(150);
  l_ATTRIBUTE15              VARCHAR2(150);
  /*bug 7519277*/
  l_icx_numeric_characters   VARCHAR2(30); --for bug#7435751
  l_return_status   boolean; --for bug#7435751
  l_inv_awt_exists_flag      VARCHAR2(1); -- Bug 7492768

  -- DYNAMIC SQL (bug8637005)
  l_hint                     VARCHAR2(100);
  l_sql_stmt                 LONG;
  TYPE refcurtyp     IS      REF CURSOR;
  refcur                     REFCURTYP;
  -- Bug 5646890.  Performance changes
    TYPE checkrun_name_t IS TABLE OF AP_SELECTED_INVOICES_ALL.checkrun_name%TYPE INDEX BY BINARY_INTEGER;
    TYPE checkrun_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.checkrun_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE invoice_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.invoice_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE payment_num_t IS TABLE OF  AP_SELECTED_INVOICES_ALL.payment_num%TYPE INDEX BY BINARY_INTEGER;
    TYPE last_update_date_t IS TABLE OF AP_SELECTED_INVOICES_ALL.last_update_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE last_updated_by_t IS TABLE OF AP_SELECTED_INVOICES_ALL.last_updated_by%TYPE INDEX BY BINARY_INTEGER;
    TYPE creation_date_t IS TABLE OF AP_SELECTED_INVOICES_ALL.creation_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE created_by_t IS TABLE OF  AP_SELECTED_INVOICES_ALL.created_by%TYPE INDEX BY BINARY_INTEGER;
    TYPE last_update_login_t IS TABLE OF AP_SELECTED_INVOICES_ALL.last_update_login%TYPE INDEX BY BINARY_INTEGER;
    TYPE vendor_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.vendor_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE vendor_site_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.vendor_site_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE vendor_num_t IS TABLE OF AP_SELECTED_INVOICES_ALL.vendor_num%TYPE INDEX BY BINARY_INTEGER;
    TYPE vendor_name_t IS TABLE OF AP_SELECTED_INVOICES_ALL.vendor_name%TYPE INDEX BY BINARY_INTEGER;
    TYPE vendor_site_code_t IS TABLE OF AP_SELECTED_INVOICES_ALL.vendor_site_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE address_line1_t IS TABLE OF AP_SELECTED_INVOICES_ALL.address_line1%TYPE INDEX BY BINARY_INTEGER;
    TYPE city_t IS TABLE OF AP_SELECTED_INVOICES_ALL.city%TYPE INDEX BY BINARY_INTEGER;
    TYPE state_t IS TABLE OF AP_SELECTED_INVOICES_ALL.state%TYPE INDEX BY BINARY_INTEGER;
    TYPE zip_t IS TABLE OF AP_SELECTED_INVOICES_ALL.zip%TYPE INDEX BY BINARY_INTEGER;
    TYPE province_t IS TABLE OF AP_SELECTED_INVOICES_ALL.province%TYPE INDEX BY BINARY_INTEGER;
    TYPE country_t IS TABLE OF AP_SELECTED_INVOICES_ALL.country%TYPE INDEX BY BINARY_INTEGER;
    TYPE attention_ar_flag_t IS TABLE OF AP_SELECTED_INVOICES_ALL.attention_ar_flag%TYPE INDEX BY BINARY_INTEGER;
    TYPE withholding_status_lookup_t IS TABLE OF AP_SELECTED_INVOICES_ALL.withholding_status_lookup_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE invoice_num_t IS TABLE OF AP_SELECTED_INVOICES_ALL.invoice_num%TYPE INDEX BY BINARY_INTEGER;
    TYPE invoice_date_t IS TABLE OF AP_SELECTED_INVOICES_ALL.invoice_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE voucher_num_t IS TABLE OF AP_SELECTED_INVOICES_ALL.voucher_num%TYPE INDEX BY BINARY_INTEGER;
    TYPE ap_ccid_t IS TABLE OF AP_SELECTED_INVOICES_ALL.ap_ccid%TYPE INDEX BY BINARY_INTEGER;
    TYPE due_date_t IS TABLE OF AP_SELECTED_INVOICES_ALL.due_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE discount_date_t IS TABLE OF AP_SELECTED_INVOICES_ALL.discount_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE invoice_description_t IS TABLE OF AP_SELECTED_INVOICES_ALL.invoice_description%TYPE INDEX BY BINARY_INTEGER;
    TYPE payment_priority_t IS TABLE OF AP_SELECTED_INVOICES_ALL.payment_priority%TYPE INDEX BY BINARY_INTEGER;
    TYPE ok_to_pay_flag_t IS TABLE OF AP_SELECTED_INVOICES_ALL.ok_to_pay_flag%TYPE INDEX BY BINARY_INTEGER;
    TYPE always_take_disc_flag_t IS TABLE OF AP_SELECTED_INVOICES_ALL.always_take_discount_flag%TYPE INDEX BY BINARY_INTEGER;
    TYPE amount_modified_flag_t IS TABLE OF AP_SELECTED_INVOICES_ALL.amount_modified_flag%TYPE INDEX BY BINARY_INTEGER;
    TYPE invoice_amount_t IS TABLE OF  AP_SELECTED_INVOICES_ALL.invoice_amount%TYPE INDEX BY BINARY_INTEGER;
    TYPE payment_cross_rate_t IS TABLE OF AP_SELECTED_INVOICES_ALL.payment_cross_rate%TYPE INDEX BY BINARY_INTEGER;
    TYPE invoice_exchange_rate_t IS TABLE OF AP_SELECTED_INVOICES_ALL.invoice_exchange_rate%TYPE INDEX BY BINARY_INTEGER;
    TYPE set_of_books_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.set_of_books_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE customer_num_t IS TABLE OF AP_SELECTED_INVOICES_ALL.customer_num%TYPE INDEX BY BINARY_INTEGER;
    TYPE future_pay_due_date_t IS TABLE OF AP_SELECTED_INVOICES_ALL.future_pay_due_date%TYPE INDEX BY BINARY_INTEGER;
    TYPE exclusive_payment_flag_t IS TABLE OF AP_SELECTED_INVOICES_ALL.exclusive_payment_flag%TYPE INDEX BY BINARY_INTEGER;
    TYPE attribute1_t IS TABLE OF AP_SELECTED_INVOICES_ALL.attribute1%TYPE INDEX BY BINARY_INTEGER;
    TYPE attribute_category_t IS TABLE OF AP_SELECTED_INVOICES_ALL.attribute_category%TYPE INDEX BY BINARY_INTEGER;
    TYPE org_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.org_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE payment_currency_code_t IS TABLE OF AP_SELECTED_INVOICES_ALL.payment_currency_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE external_bank_account_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.external_bank_account_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE legal_entity_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.legal_entity_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE global_attribute1_t IS TABLE OF AP_SELECTED_INVOICES_ALL.global_attribute1%TYPE INDEX BY BINARY_INTEGER;
    TYPE global_attribute_category_t IS TABLE OF AP_SELECTED_INVOICES_ALL.global_attribute_category%TYPE  INDEX BY BINARY_INTEGER;
    TYPE amount_paid_t IS TABLE OF AP_SELECTED_INVOICES_ALL.amount_paid%TYPE INDEX BY BINARY_INTEGER;
    TYPE discount_amount_taken_t IS TABLE OF AP_SELECTED_INVOICES_ALL.discount_amount_taken%TYPE INDEX BY BINARY_INTEGER;
    TYPE amount_remaining_t IS TABLE OF AP_SELECTED_INVOICES_ALL.amount_remaining%TYPE INDEX BY BINARY_INTEGER;
    TYPE discount_amount_remaining_t IS TABLE OF AP_SELECTED_INVOICES_ALL.discount_amount_remaining%TYPE INDEX BY BINARY_INTEGER;
    TYPE payment_amount_t IS TABLE OF AP_SELECTED_INVOICES_ALL.payment_amount%TYPE INDEX BY BINARY_INTEGER;
    TYPE discount_amount_t IS TABLE OF AP_SELECTED_INVOICES_ALL.discount_amount%TYPE INDEX BY BINARY_INTEGER;
    TYPE sequence_num_t IS TABLE OF AP_SELECTED_INVOICES_ALL.sequence_num%TYPE INDEX BY BINARY_INTEGER;
    TYPE dont_pay_reason_code_t IS TABLE OF AP_SELECTED_INVOICES_ALL.dont_pay_reason_code%TYPE INDEX BY BINARY_INTEGER;
    TYPE check_number_t IS TABLE OF AP_SELECTED_INVOICES_ALL.check_number%TYPE INDEX BY BINARY_INTEGER;
    TYPE bank_account_type_t IS TABLE OF AP_SELECTED_INVOICES_ALL.bank_account_type%TYPE INDEX BY BINARY_INTEGER;
    TYPE original_invoice_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.original_invoice_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE original_payment_num_t IS TABLE OF AP_SELECTED_INVOICES_ALL.original_payment_num%TYPE INDEX BY BINARY_INTEGER;
    TYPE bank_account_num_t IS TABLE OF AP_SELECTED_INVOICES_ALL.bank_account_num%TYPE INDEX BY BINARY_INTEGER;
    TYPE bank_num_t IS TABLE OF AP_SELECTED_INVOICES_ALL.bank_num%TYPE INDEX BY BINARY_INTEGER;
    TYPE proposed_payment_amount_t IS TABLE OF AP_SELECTED_INVOICES_ALL.proposed_payment_amount%TYPE INDEX BY BINARY_INTEGER;
    TYPE pay_selected_check_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.pay_selected_check_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE print_selected_check_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.print_selected_check_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE withholding_amount_t IS TABLE OF AP_SELECTED_INVOICES_ALL.withholding_amount%TYPE INDEX BY BINARY_INTEGER;
    TYPE invoice_payment_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.invoice_payment_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE dont_pay_description_t IS TABLE OF AP_SELECTED_INVOICES_ALL.dont_pay_description%TYPE INDEX BY BINARY_INTEGER;
    TYPE transfer_priority_t IS TABLE OF AP_SELECTED_INVOICES_ALL.transfer_priority%TYPE INDEX BY BINARY_INTEGER;
    TYPE iban_number_t IS TABLE OF AP_SELECTED_INVOICES_ALL.iban_number%TYPE INDEX BY BINARY_INTEGER;
    TYPE payment_grouping_number_t IS TABLE OF AP_SELECTED_INVOICES_ALL.payment_grouping_number%TYPE INDEX BY BINARY_INTEGER;
    TYPE payment_exchange_rate_t IS TABLE OF AP_SELECTED_INVOICES_ALL.payment_exchange_rate%TYPE INDEX BY BINARY_INTEGER;
    TYPE payment_exchange_rate_type_t IS TABLE OF AP_SELECTED_INVOICES_ALL.payment_exchange_rate_type%TYPE INDEX BY BINARY_INTEGER;
    TYPE payment_exchange_date_t IS TABLE OF AP_SELECTED_INVOICES_ALL.payment_exchange_date%TYPE INDEX BY BINARY_INTEGER;
     -- Start of 8217641
    TYPE remit_to_supplier_name_t IS TABLE OF AP_SELECTED_INVOICES_ALL.remit_to_supplier_name%TYPE INDEX BY BINARY_INTEGER;
    TYPE remit_to_supplier_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.remit_to_supplier_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE remit_to_supplier_site_t IS TABLE OF AP_SELECTED_INVOICES_ALL.remit_to_supplier_site%TYPE INDEX BY BINARY_INTEGER;
    TYPE remit_to_supplier_site_id_t IS TABLE OF AP_SELECTED_INVOICES_ALL.remit_to_supplier_site_id%TYPE INDEX BY BINARY_INTEGER;
   --End 8217641




  TYPE sel_inv_rec_type IS RECORD (
    checkrun_name_l                   checkrun_name_t
   ,checkrun_id_l                     checkrun_id_t
   ,invoice_id_l                      invoice_id_t
   ,payment_num_l                     payment_num_t
   ,last_update_date_l                last_update_date_t
   ,last_updated_by_l                 last_updated_by_t
   ,creation_date_l                   creation_date_t
   ,created_by_l                      created_by_t
   ,last_update_login_l               last_update_login_t
   ,vendor_id_l                       vendor_id_t
   ,vendor_site_id_l                  vendor_site_id_t
   ,vendor_num_l                      vendor_num_t
   ,vendor_name_l                     vendor_name_t
   ,vendor_site_code_l                vendor_site_code_t
   ,address_line1_l                   address_line1_t
   ,address_line2_l                   address_line1_t
   ,address_line3_l                   address_line1_t
   ,address_line4_l                   address_line1_t
   ,city_l                            city_t
   ,state_l                           state_t
   ,zip_l                             zip_t
   ,province_l                        province_t
   ,country_l                         country_t
   ,attention_ar_flag_l               attention_ar_flag_t
   ,withholding_status_lookup_l       withholding_status_lookup_t
   ,invoice_num_l                     invoice_num_t
   ,invoice_date_l                    invoice_date_t
   ,voucher_num_l                     voucher_num_t
   ,ap_ccid_l                         ap_ccid_t
   ,due_date_l                        due_date_t
   ,discount_date_l                   discount_date_t
   ,invoice_description_l             invoice_description_t
   ,payment_priority_l                payment_priority_t
   ,ok_to_pay_flag_l                  ok_to_pay_flag_t
   ,always_take_disc_flag_l           always_take_disc_flag_t
   ,amount_modified_flag_l            amount_modified_flag_t
   ,invoice_amount_l                  invoice_amount_t
   ,payment_cross_rate_l              payment_cross_rate_t
   ,invoice_exchange_rate_l           invoice_exchange_rate_t
   ,set_of_books_id_l                 set_of_books_id_t
   ,customer_num_l                    customer_num_t
   ,future_pay_due_date_l             future_pay_due_date_t
   ,exclusive_payment_flag_l          exclusive_payment_flag_t
   ,attribute1_l                      attribute1_t
   ,attribute2_l                      attribute1_t
   ,attribute3_l                      attribute1_t
   ,attribute4_l                      attribute1_t
   ,attribute5_l                      attribute1_t
   ,attribute6_l                      attribute1_t
   ,attribute7_l                      attribute1_t
   ,attribute8_l                      attribute1_t
   ,attribute9_l                      attribute1_t
   ,attribute10_l                     attribute1_t
   ,attribute11_l                     attribute1_t
   ,attribute12_l                     attribute1_t
   ,attribute13_l                     attribute1_t
   ,attribute14_l                     attribute1_t
   ,attribute15_l                     attribute1_t
   ,attribute_category_l              attribute_category_t
   ,org_id_l                          org_id_t
   ,payment_currency_code_l           payment_currency_code_t
   ,external_bank_account_id_l        external_bank_account_id_t
   ,legal_entity_id_l                 legal_entity_id_t
   ,global_attribute1_l               global_attribute1_t
   ,global_attribute2_l               global_attribute1_t
   ,global_attribute3_l               global_attribute1_t
   ,global_attribute4_l               global_attribute1_t
   ,global_attribute5_l               global_attribute1_t
   ,global_attribute6_l               global_attribute1_t
   ,global_attribute7_l               global_attribute1_t
   ,global_attribute8_l               global_attribute1_t
   ,global_attribute9_l               global_attribute1_t
   ,global_attribute10_l              global_attribute1_t
   ,global_attribute11_l              global_attribute1_t
   ,global_attribute12_l              global_attribute1_t
   ,global_attribute13_l              global_attribute1_t
   ,global_attribute14_l              global_attribute1_t
   ,global_attribute15_l              global_attribute1_t
   ,global_attribute16_l              global_attribute1_t
   ,global_attribute17_l              global_attribute1_t
   ,global_attribute18_l              global_attribute1_t
   ,global_attribute19_l              global_attribute1_t
   ,global_attribute20_l              global_attribute1_t
   ,global_attribute_category_l       global_attribute_category_t
   ,amount_paid_l                     amount_paid_t
   ,discount_amount_taken_l           discount_amount_taken_t
   ,amount_remaining_l                amount_remaining_t
   ,discount_amount_remaining_l       discount_amount_remaining_t
   ,payment_amount_l                  payment_amount_t
   ,discount_amount_l                 discount_amount_t
   ,sequence_num_l                    sequence_num_t
   ,dont_pay_reason_code_l            dont_pay_reason_code_t
   ,check_number_l                    check_number_t
   ,bank_account_type_l               bank_account_type_t
   ,original_invoice_id_l             original_invoice_id_t
   ,original_payment_num_l            original_payment_num_t
   ,bank_account_num_l                bank_account_num_t
   ,bank_num_l                        bank_num_t
   ,proposed_payment_amount_l         proposed_payment_amount_t
   ,pay_selected_check_id_l           pay_selected_check_id_t
   ,print_selected_check_id_l         print_selected_check_id_t
   ,withhloding_amount_l              withholding_amount_t
   ,invoice_payment_id_l              invoice_payment_id_t
   ,dont_pay_description_l            dont_pay_description_t
   ,transfer_priority_l               transfer_priority_t
   ,iban_number_l                     iban_number_t
   ,payment_grouping_number_l         payment_grouping_number_t
   ,payment_exchange_rate_l           payment_exchange_rate_t
   ,payment_exchange_rate_type_l      payment_exchange_rate_type_t
   ,payment_exchange_date_l           payment_exchange_date_t
    --Start 8217641
    ,remit_to_supplier_name_l         remit_to_supplier_name_t
    ,remit_to_supplier_id_l           remit_to_supplier_id_t
    ,remit_to_supplier_site_l         remit_to_supplier_site_t
    ,remit_to_supplier_site_id_l      remit_to_supplier_site_id_t
     --End 8217641
   );

  sel_inv_list    sel_inv_rec_type;

  /* Added for bug#8461050 Start */
  l_schema             VARCHAR2(30);
  l_status             VARCHAR2(1);
  l_industry           VARCHAR2(1);
  /* Added for bug#8461050 End */

  BEGIN



  l_current_calling_sequence := 'select invoices';

  l_debug_info := 'Check to see if creating checkrun from template';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;



  ---if this is a repeating request call a procedure to insert into ap_inv_selection_criteria_all
  --the hld says to validate the parameters, but this should probably be done
  --in the value sets or setup for the pay process request


  --l_checkrun_id will be assigned from create_checkrun if this is a
  --repeating request
  l_checkrun_id := to_number(p_checkrun_id);


  if p_template_id is not null then

    l_template_id  := to_number(p_template_id);
    l_payment_date := FND_DATE.CANONICAL_TO_DATE(P_payment_date);
    l_pay_thru_date := FND_DATE.CANONICAL_TO_DATE(P_pay_thru_date);
    l_pay_from_date  := FND_DATE.CANONICAL_TO_DATE(P_pay_from_date);

    create_checkrun(l_checkrun_id,
                    l_template_id,
                    L_payment_date,
                    L_pay_thru_date,
                    L_pay_from_date,
                    l_current_calling_sequence);

  end if;



  --get data from ap_inv_selection_criteria


  l_debug_info := 'Select data from ap_invoice_selection_criteria';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  BEGIN
      -- Bug 5460584. Added trun for check_date, pay_thru_date, pay_from_date
      --
      -- Bug8637005, added a few more columns to fetch date parameters in
      -- 'DD-MM-YYYY' format, for dynamic sql binds
      --
    SELECT
        trunc(check_date),
        to_char(check_date, 'DD-MM-YYYY'),
        trunc(pay_thru_date),
        to_char(pay_thru_date, 'DD-MM-YYYY'),
        NVL(hi_payment_priority,1),
        NVL(low_payment_priority,99),
        DECODE(pay_only_when_due_flag,'Y',
                  to_date('01/01/80','MM/DD/RR'),
                  trunc(pay_thru_date)),
        DECODE(pay_only_when_due_flag,'Y',
               '01-01-1980',
               to_char(pay_thru_date, 'DD-MM-YYYY')),
        DECODE(status,'SELECTING','N','Y'),
        nvl(zero_amounts_allowed,'N'),
        nvl(zero_invoices_allowed,'N'),
        invoice_batch_id,
        vendor_id,
        checkrun_name,
        trunc(pay_from_date),
        to_char(pay_from_date, 'DD-MM-YYYY'),
        inv_exchange_rate_type,
        payment_method_code,
        vendor_type_lookup_code,
        ou_group_option,
        le_group_option,
        currency_group_option,
        pay_group_option,
        exchange_rate_type,
        payables_review_settings,
        bank_account_id, --4710933
        payment_profile_id,
        max_payment_amount,
        min_check_amount,
        payments_review_settings,
        --decode(payment_profile_id,null,'N',nvl(create_instrs_flag,'N')),
	nvl(create_instrs_flag,'N'),  -- Commented and added for bug 8925444
        party_id,
        payment_document_id,
        /*bug 7519277*/
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15
        /*bug 7519277*/
    INTO
        l_check_date,
        l_check_date_char,
        l_pay_thru_date,
        l_pay_thru_date_char,
        l_hi_payment_priority,
        l_low_payment_priority,
        l_disc_pay_thru_date,
        l_disc_pay_thru_char,
        l_abort,
        l_zero_amounts_allowed,
        l_zero_invoices_allowed,
        l_invoice_batch_id,
        l_inv_vendor_id,
        l_payment_process_request_name,
        l_pay_from_date,
        l_pay_from_date_char,
        l_inv_exchange_rate_type,
        l_payment_method,
        l_supplier_type,
        l_ou_group_option,
        l_le_group_option,
        l_currency_group_option,
        l_pay_group_option,
        l_batch_exchange_rate_type,
        l_payables_review_settings,
        l_bank_account_id ,
        l_payment_profile_id,
        l_max_payment_amount,
        l_min_check_amount,
        l_pay_review_settings_flag,
        l_create_instrs_flag,
        l_party_id,
        l_payment_document_id,
                /* bug 7519277*/
                l_ATTRIBUTE_CATEGORY,
                l_ATTRIBUTE1,
                l_ATTRIBUTE2,
                l_ATTRIBUTE3,
                l_ATTRIBUTE4,
                l_ATTRIBUTE5,
                l_ATTRIBUTE6,
                l_ATTRIBUTE7,
                l_ATTRIBUTE8,
                l_ATTRIBUTE9,
                l_ATTRIBUTE10,
                l_ATTRIBUTE11,
                l_ATTRIBUTE12,
                l_ATTRIBUTE13,
                l_ATTRIBUTE14,
                l_ATTRIBUTE15
    FROM   ap_inv_selection_criteria_all
    WHERE  checkrun_id  = l_checkrun_id
    AND    status = 'UNSTARTED';

  EXCEPTION
     WHEN NO_DATA_FOUND then
      l_debug_info := 'Could not find the payment process';
      raise SELECTION_FAILURE;
  END;

  -- Setting the hint string(bug8637005)
  IF l_pay_group_option <> 'ALL' THEN
     l_hint := ' /*+ index(inv AP_INVOICES_N3) */ ';
  ELSE
     l_hint := ' ';
  END IF;

  /* Bug 9750106 - updating check_date and pay_thru_date as done in bug6764140 */
  UPDATE ap_inv_selection_criteria_all
  set status = 'SELECTING',
      check_date = TRUNC(check_date),
      pay_thru_date = TRUNC(pay_thru_date),
      -- Bug 7492768 We need to reset the inv_awt_exists_flag which indicates if the
      -- check run contains invoice that has awt.
      inv_awt_exists_flag = 'N'
  where checkrun_id = l_checkrun_id;



  l_debug_info := 'l_checkrun_id = '|| to_char(l_checkrun_id);
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  l_debug_info := 'See if encumbrances are turned on';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  SELECT count(*)
  INTO   l_encumbrance_flag
  FROM   financials_system_parameters
  WHERE  nvl(purch_encumbrance_flag,'N') = 'Y'
  AND    (org_id in (select org_id
                     from   AP_OU_GROUP
                     where  checkrun_id = l_checkrun_id)
          or l_ou_group_option = 'ALL')
  AND    rownum=1;



  -- Bug 5646890. Cursor processing with FORALL to make sure update and insert
  -- only do one one pass to the tables
  -- Based on encumbrances two different cursor will be opened and data will be
  -- processed.
  --

  /**************************************************************************/
  /* Bug8637005                                                             */
  /* -----------                                                            */
  /* The selection queries for Autoselect have been made dynamic for        */
  /* performance improvements, using native dynamic sqls and ref            */
  /* cursors.                                                               */
  /*                                                                        */
  /* Since use of native sql requires a knowledge of the using              */
  /* clause and hence the number of binds before hand, please make          */
  /* sure that any modifications to the sql string, ensures that            */
  /* the number of binds remain constant for all cases of input             */
  /* parameters (selection criteria)                                        */
  /*                                                                        */
  /* Currently this has been achieved using:                                */
  /*    nvl(bind, -9999) = -9999                                            */
  /*                                                                        */
  /* If for some reason it is not feasible to achieve a constant number     */
  /* for a later change please consider                                    */
  /*   a. Eliminating binds, by joing to ap_invoice_selection_criteria_all  */
  /*   b. Using DBMS_SQL                                                    */
  /**************************************************************************/

  if l_encumbrance_flag = 1 then

    l_debug_info := 'Open payment schedules cursor - encumbrances are on';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;

    l_sql_stmt :=
        '   SELECT  '||l_hint||
        '         :p_checkrun_name                                             checkrun_name '||
        '        ,:p_checkrun_id                                               checkrun_id '||
        '        ,ps.invoice_id                                               invoice_id '||
        '        ,payment_num                                                 payment_num '||
        '        ,SYSDATE                                                     last_update_date '||
                 -- Bug 7296715
                 -- The User Id is hardcoded to 5 (APPSMGR). It is changed to populate correct value.
                 -- ,5                                                           last_updated_by
        '        ,FND_GLOBAL.USER_ID                                          last_updated_by     '||
        '        ,SYSDATE                                                     creation_date '||
                 -- Bug 7296715
                 -- ,5                                                           created_by
        '        ,FND_GLOBAL.USER_ID                                          created_by '||
        '        ,NULL                                                        last_update_login '||
        '        ,ai.vendor_id                                               vendor_id '||
        '        ,ai.vendor_site_id                                          vendor_site_id '||
        '        ,suppliers.segment1                                          vendor_num '||
                 /* Bug 5620285, Added the following decode */
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzp.party_name, suppliers.vendor_name)               vendor_name '||
        '        ,sites.vendor_site_code                                      vendor_site_code '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.address1, sites.address_line1)                   address_line1 '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.address2, sites.address_line2)                   address_line2 '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.address3, sites.address_line3)                   address_line3 '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.address4, sites.address_line4)                   address_line4 '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.city, sites.city)                                city '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.state, sites.state)                              state '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.postal_code, sites.zip)                          zip '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.province, sites.province)                        province '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.country, sites.country)                          country '||
        '        ,sites.attention_ar_flag                                     attention_ar_flag '||
        '        ,suppliers.withholding_status_lookup_code                    withholding_status_lookup_code '||
        '        ,ai.invoice_num                                             invoice_num '||
        '        ,ai.invoice_date                                            invoice_date '||
        '        ,DECODE(ai.doc_sequence_id, '||
        '                   '''', ai.voucher_num, '||
        '                   ai.doc_sequence_value)                           voucher_num '||
        '        ,ai.accts_pay_code_combination_id                           ap_ccid '||
        '        ,TRUNC(ps.due_date)                                          due_date '||
        '        ,DECODE(sites.always_take_disc_flag, '||
        '                   ''Y'', TRUNC(ps.due_date), '||
        '                   DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'') '||
        '                               - NVL(ps.discount_date, '||
        '                                     to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                          -1, ps.discount_date, '||
        '                          DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'') '||
        '                                      -NVL(ps.second_discount_date, '||
        '                                           to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                                 -1, ps.second_discount_date, '||
        '                                 DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'') '||
        '                                             -NVL(ps.third_discount_date, '||
        '                                                    to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                                        -1, ps.third_discount_date, '||
        '                                        TRUNC(ps.due_date)))))      discount_date '||
        '        ,SUBSTRB(ai.description,1,50)                              invoice_description '||
        '        ,nvl(ps.payment_priority, 99)                               payment_priority '||
        '        ,''Y''                                                        ok_to_pay_flag '||
        '        ,sites.always_take_disc_flag                                always_take_discount_flag '||
        '        ,''N''                                                        amount_modified_flag '||
        '        ,ai.invoice_amount                                         invoice_amount '||
        '        ,ai.payment_cross_rate                                     payment_cross_rate '||
        '        ,DECODE(ai.exchange_rate, '||
        '                   NULL, DECODE(ai.invoice_currency_code, '||
        '                                asp.base_currency_code, 1, '||
        '                                NULL), '||
        '                   ai.exchange_rate)                               invoice_exchange_rate '||
        '        ,ai.set_of_books_id                                        set_of_books_id '||
        '        ,sites.customer_num                                         customer_num '||
        '        ,ps.future_pay_due_date                                     future_pay_due_date '||
        '        ,ai.exclusive_payment_flag                                 exclusive_payment_flag '||
        '        ,ps.attribute1                                              attribute1 '||
        '        ,ps.attribute2                                              attribute2 '||
        '        ,ps.attribute3                                              attribute3 '||
        '        ,ps.attribute4                                              attribute4 '||
        '        ,ps.attribute5                                              attribute5 '||
        '        ,ps.attribute6                                              attribute6 '||
        '        ,ps.attribute7                                              attribute7 '||
        '        ,ps.attribute8                                              attribute8 '||
        '        ,ps.attribute9                                              attribute9 '||
        '        ,ps.attribute10                                             attribute10 '||
        '        ,ps.attribute11                                             attribute11 '||
        '        ,ps.attribute12                                             attribute12 '||
        '        ,ps.attribute13                                             attribure13 '||
        '        ,ps.attribute14                                             attribute14 '||
        '        ,ps.attribute15                                             attribute15 '||
        '        ,ps.attribute_category                                      attribute_category '||
        '        ,ai.org_id                                                 org_id '||
        '        ,ai.payment_currency_code                                  payment_currency_code '||
        '        ,ps.external_bank_account_id                                external_bank_account_id '||
        '        ,ai.legal_entity_id                                        legal_entity_id '||
                 /* Bug 5192018 we will insert global attribute values from ap_invoices table */
        '        ,ai.global_attribute1                                      global_attribute1 '||
        '        ,ai.global_attribute2                                      global_attribute2 '||
        '        ,ai.global_attribute3                                      global_attribute3 '||
        '        ,ai.global_attribute4                                      global_attribute4 '||
        '        ,ai.global_attribute5                                      global_attribute5 '||
        '        ,ai.global_attribute6                                      global_attribute6 '||
        '        ,ai.global_attribute7                                      global_attribute7 '||
        '        ,ai.global_attribute8                                      global_attribute8 '||
        '        ,ai.global_attribute9                                      global_attribute9 '||
        '        ,ai.global_attribute10                                     global_attribute10 '||
        '        ,ai.global_attribute11                                     global_attribute11 '||
        '        ,ai.global_attribute12                                     global_attribute12 '||
        '        ,ai.global_attribute13                                     global_attribute13 '||
        '        ,ai.global_attribute14                                     global_attribute14 '||
        '        ,ai.global_attribute15                                     global_attribute15 '||
        '        ,ai.global_attribute16                                     global_attribute16 '||
        '        ,ai.global_attribute17                                     global_attribute17 '||
        '        ,ai.global_attribute18                                     global_attribute18 '||
        '        ,ai.global_attribute19                                     global_attribute19 '||
        '        ,ai.global_attribute20                                     global_attribute20 '||
        '        ,ai.global_attribute_category                              global_attribute_category '||-- end of bug 5192018
        '        ,Null                                                       amount_paid '||
        '        ,Null                                                       discount_amount_taken '||
        '        ,Null                                                       amount_remaining '||
        '        ,Null                                                       discount_amount_remaining '||
        '        ,Null                                                       payment_amount '||
        '        ,Null                                                       discount_amount  '||
        '        ,Null                                                       sequence_num    '||
        '        ,Null                                                       done_pay_reason_code '||
        '        ,Null                                                       check_number   '||
        '        ,Null                                                       bank_account_type  '||
        '        ,Null                                                       original_invoice_id '||
        '        ,Null                                                       original_payment_num '||
        '        ,Null                                                       bank_account_num '||
        '        ,Null                                                       bank_num '||
        '        ,Null                                                       proposed_payment_amount '||
        '        ,Null                                                       pay_selected_check_id '||
        '        ,Null                                                       print_selected_check_id '||
        '        ,Null                                                       withholding_amount '||
        '        ,Null                                                       invoice_payment_id '||
        '        ,Null                                                       dont_pay_description '||
        '        ,Null                                                       transfer_priority '||
        '        ,Null                                                       iban_number '||
        '        ,Null                                                       payment_grouping_number '||
        '        ,Null                                                       payment_exchange_rate '||
        '        ,Null                                                       payment_exchange_rate_type '||
        '        ,Null                                                       payment_exchange_date '||
                  -- Start of 8217641
        '        ,ps.remit_to_supplier_name                                  remit_to_supplier_name                      '||
        '        ,ps.remit_to_supplier_id                                    remit_to_supplier_id '||
        '        ,ps.remit_to_supplier_site                                  remit_to_supplier_site '||
        '        ,ps.remit_to_supplier_site_id                               remit_to_supplier_site_id '||
                 --End 8217641
        '   FROM   ap_supplier_sites_all sites, '||
        '          ap_suppliers suppliers, '||
        '          ap_invoices ai, '||               /* inv, '||Commented for bug#9182499 --Bug6040657. Changed from ap_invoices_all to ap_invoices */
        '          ap_payment_schedules_all ps, '||
        '          ap_system_parameters_all asp, '||
        '          hz_parties hzp, '||
        '          hz_party_sites hzps,          '||-- Bug 5620285
        '          hz_locations   hzl            '||-- Bug 5620285
        '   WHERE  ps.checkrun_id is null        '||-- Bug 5705276. Regression
        '      AND ((due_date <= to_date(:p_pay_thru_date, ''DD-MM-YYYY'') +0/24 and '||--Bug 8708165
        '               due_date >= nvl(to_date(:p_pay_from_date, ''DD-MM-YYYY'') + 0/24,due_date)) '||
        '              OR '||
        '               DECODE(NVL(sites.pay_date_basis_lookup_code,''DISCOUNT''), '||
        '                    ''DISCOUNT'', '||
        '                    DECODE(sites.always_take_disc_flag, '||
        '                           ''Y'', ps.discount_date, '||
        '                           DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'') '||
        '                                  -NVL(ps.discount_date, '||
        '                                       to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                                  -1, ps.discount_date, '||
        '                                  DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'') '||
        '                                              -NVL(ps.second_discount_date, '||
        '                                                   to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                                         -1, ps.second_discount_date, '||
        '                                         DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'') '||
        '                                                     -NVL(ps.third_discount_date, '||
        '                                                         to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                                                -1, ps.third_discount_date, '||
        '                                                TRUNC(ps.due_date))))), '||
        '                    TRUNC(due_date)) '||
        '                    BETWEEN DECODE(sites.always_take_disc_flag,''Y'', '||
        '                                    nvl(to_date(:p_pay_from_date, ''DD-MM-YYYY''), TO_DATE(''1901'',''YYYY'')), '||
        '                                    to_date(:p_check_date, ''DD-MM-YYYY'')) '||
        '                            AND to_date(:p_disc_pay_thru_date, ''DD-MM-YYYY'')) '||
        '       AND    ps.payment_status_flag BETWEEN ''N'' AND ''P'' '||
        '       AND    ai.payment_status_flag BETWEEN ''N'' AND ''P'' '||
        '       AND    nvl(ai.force_revalidation_flag, ''N'') = ''N''     '||--bug7244642
        '       AND    NVL(ps.payment_priority, 99) BETWEEN :p_hi_payment_priority '||
        '                                              AND :p_lo_payment_priority '||
        '       AND    ai.cancelled_date is null '||
                -- Bug 7167192 Added decode and outer join
                -- hzp and hzps data is required only for Payment Requests.
        '       AND    hzp.party_id(+) = decode(ai.invoice_type_lookup_code,  '||
        '                                       ''PAYMENT REQUEST'', ai.party_id '||
        '                                                        , -99) '||
        '       AND    NVL(ps.hold_flag, ''N'') = ''N'' '||
        '       AND    NVL(sites.hold_all_payments_flag, ''N'') = ''N'' '||
        '       AND    ai.invoice_id = ps.invoice_id '||
        '       AND    sites.vendor_id(+) = ai.vendor_id '||
        '       AND    sites.vendor_site_id(+) = ai.vendor_site_id '||
        '       AND    suppliers.vendor_id(+) = ai.vendor_id '||
        '       AND    asp.org_id = ai.org_id '||
        '       AND    hzp.party_id = hzps.party_id (+)   '||-- Bug 5620285
                --Bug 5929034: An employee does not have a hz_party_site, modifying query to reflect the same
                --   AND    nvl(hzps.party_site_id,-99)  = decode(suppliers.vendor_type_lookup_code,''EMPLOYEE'',-99,nvl(inv.party_site_id, hzps.party_site_id))  -- Bug 5620285
                -- Bug 6662382
                -- Bug 7167192 - Query condition is now based on whether the Invoice
                --               is a Payment Request. Supplier type does not matter.
                --AND    NVL(hzps.party_site_id,-99)  = DECODE(suppliers.vendor_type_lookup_code,''EMPLOYEE'', COALESCE(inv.party_site_id, hzps.party_site_id,-99),
                --                                             NVL(inv.party_site_id, hzps.party_site_id))
        '       AND    NVL(hzps.party_site_id,-99) = NVL(decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', ai.party_site_id, -99), NVL(hzps.party_site_id,-99)) '||
                -- Bug 7167192
        '       AND    nvl(hzps.location_id,-99) = hzl.location_id (+) '||-- Bug 5620285
                --End of 5929034
        '       AND    fv_econ_benf_disc.ebd_check(:p_checkrun_name, ai.invoice_id, '||
        '                                   to_date(:p_check_date, ''DD-MM-YYYY''), due_date, ps.discount_amount_available, ps.discount_date) = ''Y'' ';

                -- Bug 7265013 starts
                -- AND    AP_INVOICES_PKG.get_wfapproval_status(inv.invoice_id, inv.org_id) in
                --         (''NOT REQUIRED'',''WFAPPROVED'',''MANUALLY APPROVED'')*/
                 -- Bug 7265013 ends

     IF l_invoice_batch_id IS NOT NULL THEN
          l_sql_stmt := l_sql_stmt||'              AND  ai.batch_id = :p_inv_batch_id ';
     ELSE
          l_sql_stmt := l_sql_stmt||'              AND  nvl(:p_inv_batch_id, -9999) = -9999 ';
     END IF;

     IF l_inv_vendor_id IS NOT NULL THEN
          l_sql_stmt := l_sql_stmt||'       AND    ai.vendor_id = :p_inv_vendor_id  ';
     ELSE
          l_sql_stmt := l_sql_stmt||'       AND    nvl(:p_inv_vendor_id, -9999) = -9999 ';
     END IF;

     IF l_party_id IS NOT NULL THEN
           l_sql_stmt := l_sql_stmt||'       AND    ai.party_id = :p_party_id ';
     ELSE
           l_sql_stmt := l_sql_stmt||'       AND    nvl(:p_party_id, -9999) = -9999 ';
     END IF;

                -- Bug 5507013 hkaniven start --
     l_sql_stmt := l_sql_stmt||
        '       AND    (( :p_inv_exc_rate_type = ''IS_USER'' AND NVL(ai.exchange_rate_type,''NOT USER'') = ''User'' ) '||
        '               OR (:p_inv_exc_rate_type = ''IS_NOT_USER'' AND NVL(ai.exchange_rate_type,''NOT USER'') <> ''User'') '||
        '               OR (:p_inv_exc_rate_type IS NULL)) '||
                -- Bug 5507013 hkaniven end --
        '       AND    ps.payment_method_code = nvl(:p_payment_method, ps.payment_method_code) '||
        '       AND    nvl(suppliers.vendor_type_lookup_code,-99) = '||
        '                   nvl(:p_supplier_type, nvl(suppliers.vendor_type_lookup_code,-99)) '||
        '       AND    (ai.legal_entity_id in (select /*+ push_subq */ legal_entity_id '||
        '                                       from   ap_le_group '||
        '                                       where  checkrun_id = :p_checkrun_id) '||
        '               or :p_le_group_option = ''ALL'') '||
        '       AND    (ai.org_id in (select /*+ push_subq */ org_id '||
        '                              from   AP_OU_GROUP '||
        '                              where  checkrun_id = :p_checkrun_id) '||
        '               or :p_ou_group_option = ''ALL'') '||
        '       AND    (ai.payment_currency_code in (select /*+ push_subq */ currency_code '||
        '                                            from   AP_CURRENCY_GROUP '||
        '                                            where  checkrun_id = :p_checkrun_id) '||
        '               or :p_curr_group_option = ''ALL'') ';

     IF l_pay_group_option <> 'ALL' THEN
          l_sql_stmt := l_sql_stmt||
            /* Commented for Bug#9182499 Start
            '       AND    inv.pay_group_lookup_code in (select / *+ leading(apg) cardinality(apg 1) * / vendor_pay_group '||
            '                                            from   AP_PAY_GROUP apg'|| --bug9087739, added alias for  AP_PAY_GROUP
            '                                            where  checkrun_id BETWEEN :p_checkrun_id AND :p_checkrun_id) ';
            Commented for Bug#9182499 End */
            /* Added for Bug#9182499 Start */
            '       AND (ai.pay_group_lookup_code, ai.org_id) in '||
            '                       ( select /*+ leading(apg) cardinality(apg 1) */ '||
            '                                apg.vendor_pay_group, mo.ORGANIZATION_ID '||
            '                           from AP_PAY_GROUP apg, MO_GLOB_ORG_ACCESS_TMP mo '||
            '                          where checkrun_id BETWEEN :p_checkrun_id AND :p_checkrun_id) ';
            /* Added for Bug#9182499 End */

     ELSE
          l_sql_stmt := l_sql_stmt||
            '       AND    :p_checkrun_id = :p_checkrun_id   ';
     END IF;

     l_sql_stmt := l_sql_stmt||
        '       AND    ((:p_zero_inv_allowed = ''N'' AND ps.amount_remaining <> 0) OR '||
        '                :p_zero_inv_allowed = ''Y'') '||
                --Bug 6342390 Added the clause below.
                --Commented the fix for the bug6342390, bug6365720
                 /* AND NOT EXISTS (SELECT ''Invoice is not fully approved''
                                FROM ap_invoice_distributions_all D2
                                WHERE D2.invoice_id = inv.invoice_id
                                AND NVL(D2.match_status_flag, ''N'') in (''N'', ''S''))*/
                --bug6365720
                -- Bug 7265013 starts
        '       AND EXISTS ( '||
        '       SELECT 1 '||
        '       FROM   sys.dual '||
        '       WHERE  AP_INVOICES_PKG.get_wfapproval_status(ai.invoice_id, ai.org_id) in '||
        '               (''NOT REQUIRED'',''WFAPPROVED'',''MANUALLY APPROVED'') '||
        '       ) '||
                -- Bug 7265013 ends
        '       AND NOT EXISTS (SELECT /*+ push_subq */ ''Unreleased holds exist'' '||
        '                       FROM ap_holds H '||
        '                       WHERE H.invoice_id = ai.invoice_id '||
        '                       AND H.release_lookup_code is null) '||
        '       AND NOT EXISTS (SELECT /*+ push_subq */ ''Invoice is not fully approved''  '||
        '                       FROM ap_invoices_derived_v AIDV '||
        '                       WHERE AIDV.invoice_id = ai.invoice_id '||
        '                       AND AIDV.approval_status_lookup_code IN  '||
        '                               (''NEVER APPROVED'', ''NEEDS REAPPROVAL'', ''UNAPPROVED'')) '||
        '       AND EXISTS (SELECT /*+ push_subq */ ''Distributions exist'' '||
        '                   FROM   ap_invoice_distributions D4 '||
        '                   WHERE  D4.invoice_id = ai.invoice_id) ';
                -- bug 6456537
        /*     AND NOT EXISTS (SELECT ''CCR EXPIRED''
                               FROM FV_TPP_ASSIGNMENTS_V TPP
                               WHERE TPP.beneficiary_party_id = inv.party_id
                               AND TPP.beneficiary_party_site_id = inv.party_site_id
                             AND NVL(TPP.fv_tpp_pay_flag, ''Y'') = ''N'') ; bug8691645 */
                -- 6456537 Checking the validity of CCR of the Third Party for
                -- supplier. If the CCR is Invalid then the invoice document
                -- is not consider for the Payment(Auto Select)

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    OPEN refcur FOR l_sql_stmt USING
                                    l_payment_process_request_name,
                                    l_checkrun_id,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_pay_thru_date_char,
                                    l_pay_from_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_pay_from_date_char,
                                    l_check_date_char,
                                    l_disc_pay_thru_char,
                                    l_hi_payment_priority,
                                    l_low_payment_priority,
                                    l_payment_process_request_name,
                                    l_check_date_char,
                                    l_invoice_batch_id,
                                    l_inv_vendor_id,
                                    l_party_id,
                                    l_inv_exchange_rate_type,
                                    l_inv_exchange_rate_type,
                                    l_inv_exchange_rate_type,
                                    l_payment_method,
                                    l_supplier_type,
                                    l_checkrun_id,
                                    l_le_group_option,
                                    l_checkrun_id,
                                    l_ou_group_option,
                                    l_checkrun_id,
                                    l_currency_group_option,
                                    l_checkrun_id,
                                    l_checkrun_id,
                                    l_zero_invoices_allowed,
                                    l_zero_invoices_allowed;
      LOOP
        FETCH refcur
        BULK COLLECT INTO
               sel_inv_list.checkrun_name_l
              ,sel_inv_list.checkrun_id_l
              ,sel_inv_list.invoice_id_l
              ,sel_inv_list.payment_num_l
              ,sel_inv_list.last_update_date_l
              ,sel_inv_list.last_updated_by_l
              ,sel_inv_list.creation_date_l
              ,sel_inv_list.created_by_l
              ,sel_inv_list.last_update_login_l
              ,sel_inv_list.vendor_id_l
              ,sel_inv_list.vendor_site_id_l
              ,sel_inv_list.vendor_num_l
              ,sel_inv_list.vendor_name_l
              ,sel_inv_list.vendor_site_code_l
              ,sel_inv_list.address_line1_l
              ,sel_inv_list.address_line2_l
              ,sel_inv_list.address_line3_l
              ,sel_inv_list.address_line4_l
              ,sel_inv_list.city_l
              ,sel_inv_list.state_l
              ,sel_inv_list.zip_l
              ,sel_inv_list.province_l
              ,sel_inv_list.country_l
              ,sel_inv_list.attention_ar_flag_l
              ,sel_inv_list.withholding_status_lookup_l
              ,sel_inv_list.invoice_num_l
              ,sel_inv_list.invoice_date_l
              ,sel_inv_list.voucher_num_l
              ,sel_inv_list.ap_ccid_l
              ,sel_inv_list.due_date_l
              ,sel_inv_list.discount_date_l
              ,sel_inv_list.invoice_description_l
              ,sel_inv_list.payment_priority_l
              ,sel_inv_list.ok_to_pay_flag_l
              ,sel_inv_list.always_take_disc_flag_l
              ,sel_inv_list.amount_modified_flag_l
              ,sel_inv_list.invoice_amount_l
              ,sel_inv_list.payment_cross_rate_l
              ,sel_inv_list.invoice_exchange_rate_l
              ,sel_inv_list.set_of_books_id_l
              ,sel_inv_list.customer_num_l
              ,sel_inv_list.future_pay_due_date_l
              ,sel_inv_list.exclusive_payment_flag_l
              ,sel_inv_list.attribute1_l
              ,sel_inv_list.attribute2_l
              ,sel_inv_list.attribute3_l
              ,sel_inv_list.attribute4_l
              ,sel_inv_list.attribute5_l
              ,sel_inv_list.attribute6_l
              ,sel_inv_list.attribute7_l
              ,sel_inv_list.attribute8_l
              ,sel_inv_list.attribute9_l
              ,sel_inv_list.attribute10_l
              ,sel_inv_list.attribute11_l
              ,sel_inv_list.attribute12_l
              ,sel_inv_list.attribute13_l
              ,sel_inv_list.attribute14_l
              ,sel_inv_list.attribute15_l
              ,sel_inv_list.attribute_category_l
              ,sel_inv_list.org_id_l
              ,sel_inv_list.payment_currency_code_l
              ,sel_inv_list.external_bank_account_id_l
              ,sel_inv_list.legal_entity_id_l
              ,sel_inv_list.global_attribute1_l
              ,sel_inv_list.global_attribute2_l
              ,sel_inv_list.global_attribute3_l
              ,sel_inv_list.global_attribute4_l
              ,sel_inv_list.global_attribute5_l
              ,sel_inv_list.global_attribute6_l
              ,sel_inv_list.global_attribute7_l
              ,sel_inv_list.global_attribute8_l
              ,sel_inv_list.global_attribute9_l
              ,sel_inv_list.global_attribute10_l
              ,sel_inv_list.global_attribute11_l
              ,sel_inv_list.global_attribute12_l
              ,sel_inv_list.global_attribute13_l
              ,sel_inv_list.global_attribute14_l
              ,sel_inv_list.global_attribute15_l
              ,sel_inv_list.global_attribute16_l
              ,sel_inv_list.global_attribute17_l
              ,sel_inv_list.global_attribute18_l
              ,sel_inv_list.global_attribute19_l
              ,sel_inv_list.global_attribute20_l
              ,sel_inv_list.global_attribute_category_l
              ,sel_inv_list.amount_paid_l
              ,sel_inv_list.discount_amount_taken_l
              ,sel_inv_list.amount_remaining_l
              ,sel_inv_list.discount_amount_remaining_l
              ,sel_inv_list.payment_amount_l
              ,sel_inv_list.discount_amount_l
              ,sel_inv_list.sequence_num_l
              ,sel_inv_list.dont_pay_reason_code_l
              ,sel_inv_list.check_number_l
              ,sel_inv_list.bank_account_type_l
              ,sel_inv_list.original_invoice_id_l
              ,sel_inv_list.original_payment_num_l
              ,sel_inv_list.bank_account_num_l
              ,sel_inv_list.bank_num_l
              ,sel_inv_list.proposed_payment_amount_l
              ,sel_inv_list.pay_selected_check_id_l
              ,sel_inv_list.print_selected_check_id_l
              ,sel_inv_list.withhloding_amount_l
              ,sel_inv_list.invoice_payment_id_l
              ,sel_inv_list.dont_pay_description_l
              ,sel_inv_list.transfer_priority_l
              ,sel_inv_list.iban_number_l
              ,sel_inv_list.payment_grouping_number_l
              ,sel_inv_list.payment_exchange_rate_l
              ,sel_inv_list.payment_exchange_rate_type_l
              ,sel_inv_list.payment_exchange_date_l
               --Start of 8217641
              ,sel_inv_list.remit_to_supplier_name_l
              ,sel_inv_list.remit_to_supplier_id_l
              ,sel_inv_list.remit_to_supplier_site_l
              ,sel_inv_list.remit_to_supplier_site_id_l
              --End 8217641
              LIMIT 1000;


          l_debug_info := 'Update ap_payment_schedules_all: encumbrances are on';
          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line(FND_FILE.LOG,l_debug_info);
          END IF;

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;


          FORALL i IN sel_inv_list.invoice_id_l.FIRST .. sel_inv_list.invoice_id_l.LAST
            UPDATE Ap_Payment_Schedules_All
            SET    checkrun_id = sel_inv_list.checkrun_id_l(i)
            WHERE  invoice_id = sel_inv_list.invoice_id_l(i)
            AND    payment_num = sel_inv_list.payment_num_l(i)
            AND    checkrun_id IS NULL --bug 6788730
            ;


          l_debug_info := 'Insert into ap_selected_invoices_all: encumbrances are on';
          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line(FND_FILE.LOG,l_debug_info);
          END IF;

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;


          FORALL i IN sel_inv_list.invoice_id_l.FIRST .. sel_inv_list.invoice_id_l.LAST
            INSERT INTO ap_selected_invoices_all
              (checkrun_name
              ,checkrun_id
              ,invoice_id
              ,payment_num
              ,last_update_date
              ,last_updated_by
              ,creation_date
              ,created_by
              ,vendor_id
              ,vendor_site_id
              ,vendor_num
              ,vendor_name
              ,vendor_site_code
              ,address_line1
              ,address_line2
              ,address_line3
              ,address_line4
              ,city
              ,state
              ,zip
              ,province
              ,country
              ,attention_ar_flag
              ,withholding_status_lookup_code
              ,invoice_num
              ,invoice_date
              ,voucher_num
              ,ap_ccid
              ,due_date
              ,discount_date
              ,invoice_description
              ,payment_priority
              ,ok_to_pay_flag
              ,always_take_discount_flag
              ,amount_modified_flag
              ,invoice_amount
              ,payment_cross_rate
              ,invoice_exchange_rate
              ,set_of_books_id
              ,customer_num
              ,future_pay_due_date
              ,exclusive_payment_flag
              ,attribute1
              ,attribute2
              ,attribute3
              ,attribute4
              ,attribute5
              ,attribute6
              ,attribute7
              ,attribute8
              ,attribute9
              ,attribute10
              ,attribute11
              ,attribute12
              ,attribute13
              ,attribute14
              ,attribute15
              ,attribute_category
              ,org_id
              ,payment_currency_code
              ,external_bank_account_id
              ,legal_entity_id
              ,global_attribute1
              ,global_attribute2
              ,global_attribute3
              ,global_attribute4
              ,global_attribute5
              ,global_attribute6
              ,global_attribute7
              ,global_attribute8
              ,global_attribute9
              ,global_attribute10
              ,global_attribute11
              ,global_attribute12
              ,global_attribute13
              ,global_attribute14
              ,global_attribute15
              ,global_attribute16
              ,global_attribute17
              ,global_attribute18
              ,global_attribute19
              ,global_attribute20
              ,global_attribute_category
                --Start of 8217641
              ,remit_to_supplier_name
              ,remit_to_supplier_id
              ,remit_to_supplier_site
              ,remit_to_supplier_site_id
              --End 8217641
              )
            --bug 6788730 Changed this to SELECT
            --VALUES
              (
              SELECT /*+ INDEX(AP_PAYMENT_SCHEDULES_ALL,AP_PAYMENT_SCHEDULES_U1) */
               sel_inv_list.checkrun_name_l(i)
              ,sel_inv_list.checkrun_id_l(i)
              ,sel_inv_list.invoice_id_l(i)
              ,sel_inv_list.payment_num_l(i)
              ,sel_inv_list.last_update_date_l(i)
              ,sel_inv_list.last_updated_by_l(i)
              ,sel_inv_list.creation_date_l(i)
              ,sel_inv_list.created_by_l(i)
              ,sel_inv_list.vendor_id_l(i)
              ,sel_inv_list.vendor_site_id_l(i)
              ,sel_inv_list.vendor_num_l(i)
              ,sel_inv_list.vendor_name_l(i)
              ,sel_inv_list.vendor_site_code_l(i)
              ,sel_inv_list.address_line1_l(i)
              ,sel_inv_list.address_line2_l(i)
              ,sel_inv_list.address_line3_l(i)
              ,sel_inv_list.address_line4_l(i)
              ,sel_inv_list.city_l(i)
              ,sel_inv_list.state_l(i)
              ,sel_inv_list.zip_l(i)
              ,sel_inv_list.province_l(i)
              ,sel_inv_list.country_l(i)
              ,sel_inv_list.attention_ar_flag_l(i)
              ,sel_inv_list.withholding_status_lookup_l(i)
              ,sel_inv_list.invoice_num_l(i)
              ,sel_inv_list.invoice_date_l(i)
              ,sel_inv_list.voucher_num_l(i)
              ,sel_inv_list.ap_ccid_l(i)
              ,sel_inv_list.due_date_l(i)
              ,sel_inv_list.discount_date_l(i)
              ,sel_inv_list.invoice_description_l(i)
              ,sel_inv_list.payment_priority_l(i)
              ,sel_inv_list.ok_to_pay_flag_l(i)
              ,sel_inv_list.always_take_disc_flag_l(i)
              ,sel_inv_list.amount_modified_flag_l(i)
              ,sel_inv_list.invoice_amount_l(i)
              ,sel_inv_list.payment_cross_rate_l(i)
              ,sel_inv_list.invoice_exchange_rate_l(i)
              ,sel_inv_list.set_of_books_id_l(i)
              ,sel_inv_list.customer_num_l(i)
              ,sel_inv_list.future_pay_due_date_l(i)
              ,sel_inv_list.exclusive_payment_flag_l(i)
              ,sel_inv_list.attribute1_l(i)
              ,sel_inv_list.attribute2_l(i)
              ,sel_inv_list.attribute3_l(i)
              ,sel_inv_list.attribute4_l(i)
              ,sel_inv_list.attribute5_l(i)
              ,sel_inv_list.attribute6_l(i)
              ,sel_inv_list.attribute7_l(i)
              ,sel_inv_list.attribute8_l(i)
              ,sel_inv_list.attribute9_l(i)
              ,sel_inv_list.attribute10_l(i)
              ,sel_inv_list.attribute11_l(i)
              ,sel_inv_list.attribute12_l(i)
              ,sel_inv_list.attribute13_l(i)
              ,sel_inv_list.attribute14_l(i)
              ,sel_inv_list.attribute15_l(i)
              ,sel_inv_list.attribute_category_l(i)
              ,sel_inv_list.org_id_l(i)
              ,sel_inv_list.payment_currency_code_l(i)
              ,sel_inv_list.external_bank_account_id_l(i)
              ,sel_inv_list.legal_entity_id_l(i)
              ,sel_inv_list.global_attribute1_l(i)
              ,sel_inv_list.global_attribute2_l(i)
              ,sel_inv_list.global_attribute3_l(i)
              ,sel_inv_list.global_attribute4_l(i)
              ,sel_inv_list.global_attribute5_l(i)
              ,sel_inv_list.global_attribute6_l(i)
              ,sel_inv_list.global_attribute7_l(i)
              ,sel_inv_list.global_attribute8_l(i)
              ,sel_inv_list.global_attribute9_l(i)
              ,sel_inv_list.global_attribute10_l(i)
              ,sel_inv_list.global_attribute11_l(i)
              ,sel_inv_list.global_attribute12_l(i)
              ,sel_inv_list.global_attribute13_l(i)
              ,sel_inv_list.global_attribute14_l(i)
              ,sel_inv_list.global_attribute15_l(i)
              ,sel_inv_list.global_attribute16_l(i)
              ,sel_inv_list.global_attribute17_l(i)
              ,sel_inv_list.global_attribute18_l(i)
              ,sel_inv_list.global_attribute19_l(i)
              ,sel_inv_list.global_attribute20_l(i)
              ,sel_inv_list.global_attribute_category_l(i)
               --Start of 8217641
              ,sel_inv_list.remit_to_supplier_name_l(i)
              ,sel_inv_list.remit_to_supplier_id_l(i)
              ,sel_inv_list.remit_to_supplier_site_l(i)
              ,sel_inv_list.remit_to_supplier_site_id_l(i)
              --End 8217641
            FROM Ap_Payment_Schedules_All
            WHERE  invoice_id = sel_inv_list.invoice_id_l(i)
            AND    payment_num = sel_inv_list.payment_num_l(i)
            AND    checkrun_id = sel_inv_list.checkrun_id_l(i)
            --bug 6788730
            );

        EXIT WHEN refcur%NOTFOUND;
      END LOOP;

      COMMIT;

    CLOSE refcur;


  else  --no encumbrances used

    l_debug_info := 'Open payment schedules cursor- encumbrances are off';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;

    l_sql_stmt :=
        '   SELECT '||l_hint||
        '         :p_checkrun_name                                            checkrun_name '||
        '        ,:p_checkrun_id                                              checkrun_id '||
        '        ,ps.invoice_id                                               invoice_id '||
        '        ,ps.payment_num                                              payment_num '||
        '        ,SYSDATE                                                     last_update_date '||
                -- Bug 7296715
                -- The User Id is hardcoded to 5 (APPSMGR). It is changed to populate correct value.
                -- ,5                                                           last_updated_by
        '        ,FND_GLOBAL.USER_ID                                          last_updated_by '||
        '        ,SYSDATE                                                     creation_date '||
                  -- Bug 7296715
                  -- ,5                                                           created_by
        '        ,FND_GLOBAL.USER_ID                                          created_by '||
        '        ,NULL                                                        last_update_login '||
        '        ,ai.vendor_id                                               vendor_id '||
        '        ,ai.vendor_site_id                                          vendor_site_id '||
        '        ,suppliers.segment1                                          vendor_num '||
                 -- Bug 5620285, Added the following decode */
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzp.party_name, suppliers.vendor_name)               vendor_name '||
        '        ,sites.vendor_site_code                                      vendor_site_code '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.address1, sites.address_line1)                   address_line1 '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.address2, sites.address_line2)                   address_line2 '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.address3, sites.address_line3)                   address_line3 '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.address4, sites.address_line4)                   address_line4 '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.city, sites.city)                                city '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.state, sites.state)                              state '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.postal_code, sites.zip)                          zip '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.province, sites.province)                        province '||
        '        ,decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', '||
        '                hzl.country, sites.country)                          country '||
        '        ,sites.attention_ar_flag                                     attention_ar_flag '||
        '        ,suppliers.withholding_status_lookup_code                    withholding_status_lookup_code '||
        '        ,ai.invoice_num                                             invoice_num '||
        '        ,ai.invoice_date                                            invoice_date '||
        '        ,DECODE(ai.doc_sequence_id, '||
        '                   '''', ai.voucher_num, '||
        '                   ai.doc_sequence_value)                           voucher_num '||
        '        ,ai.accts_pay_code_combination_id                           ap_ccid '||
        '        ,TRUNC(ps.due_date)                                          due_date '||
        '        ,DECODE(sites.always_take_disc_flag, '||
        '                   ''Y'', TRUNC(ps.due_date), '||
        '                   DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'')  '||
        '                               - NVL(ps.discount_date, '||
        '                                     to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                          -1, ps.discount_date, '||
        '                          DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'') '||
        '                                      -NVL(ps.second_discount_date, '||
        '                                           to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                                 -1, ps.second_discount_date, '||
        '                                 DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'') '||
        '                                             -NVL(ps.third_discount_date, '||
        '                                                    to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                                        -1, ps.third_discount_date, '||
        '                                        TRUNC(ps.due_date)))))      discount_date '||
        '        ,SUBSTRB(ai.description,1,50)                              invoice_description '||
        '        ,nvl(ps.payment_priority, 99)                               payment_priority '||
        '        ,''Y''                                                        ok_to_pay_flag '||
        '        ,sites.always_take_disc_flag                                always_take_discount_flag '||
        '        ,''N''                                                        amount_modified_flag '||
        '        ,ai.invoice_amount                                         invoice_amount '||
        '        ,ai.payment_cross_rate                                     payment_cross_rate '||
        '        ,DECODE(ai.exchange_rate, '||
        '                   NULL, DECODE(ai.invoice_currency_code, '||
        '                                asp.base_currency_code, 1, '||
        '                                NULL), '||
        '                   ai.exchange_rate)                               invoice_exchange_rate '||
        '        ,ai.set_of_books_id                                        set_of_books_id '||
        '        ,sites.customer_num                                         customer_num '||
        '        ,ps.future_pay_due_date                                     future_pay_due_date '||
        '        ,ai.exclusive_payment_flag                                 exclusive_payment_flag '||
        '        ,ps.attribute1                                              attribute1 '||
        '        ,ps.attribute2                                              attribute2 '||
        '        ,ps.attribute3                                              attribute3 '||
        '        ,ps.attribute4                                              attribute4 '||
        '        ,ps.attribute5                                              attribute5 '||
        '        ,ps.attribute6                                              attribute6 '||
        '        ,ps.attribute7                                              attribute7 '||
        '        ,ps.attribute8                                              attribute8 '||
        '        ,ps.attribute9                                              attribute9 '||
        '        ,ps.attribute10                                             attribute10 '||
        '        ,ps.attribute11                                             attribute11 '||
        '        ,ps.attribute12                                             attribute12 '||
        '        ,ps.attribute13                                             attribure13 '||
        '        ,ps.attribute14                                             attribute14 '||
        '        ,ps.attribute15                                             attribute15 '||
        '        ,ps.attribute_category                                      attribute_category '||
        '        ,ai.org_id                                                 org_id '||
        '        ,ai.payment_currency_code                                  payment_currency_code '||
        '        ,ps.external_bank_account_id                                external_bank_account_id '||
        '        ,ai.legal_entity_id                                        legal_entity_id '||
                 -- Bug 5192018 we will insert global attribute values from ap_invoices table */
        '        ,ai.global_attribute1                                      global_attribute1 '||
        '        ,ai.global_attribute2                                      global_attribute2 '||
        '        ,ai.global_attribute3                                      global_attribute3 '||
        '        ,ai.global_attribute4                                      global_attribute4 '||
        '        ,ai.global_attribute5                                      global_attribute5 '||
        '        ,ai.global_attribute6                                      global_attribute6 '||
        '        ,ai.global_attribute7                                      global_attribute7 '||
        '        ,ai.global_attribute8                                      global_attribute8 '||
        '        ,ai.global_attribute9                                      global_attribute9 '||
        '        ,ai.global_attribute10                                     global_attribute10 '||
        '        ,ai.global_attribute11                                     global_attribute11 '||
        '        ,ai.global_attribute12                                     global_attribute12 '||
        '        ,ai.global_attribute13                                     global_attribute13 '||
        '        ,ai.global_attribute14                                     global_attribute14 '||
        '        ,ai.global_attribute15                                     global_attribute15 '||
        '        ,ai.global_attribute16                                     global_attribute16 '||
        '        ,ai.global_attribute17                                     global_attribute17 '||
        '        ,ai.global_attribute18                                     global_attribute18 '||
        '        ,ai.global_attribute19                                     global_attribute19 '||
        '        ,ai.global_attribute20                                     global_attribute20 '||
        '        ,ai.global_attribute_category                              global_attribute_category  '|| -- end of bug 5192018
        '        ,Null                                                       amount_paid '||
        '        ,Null                                                       discount_amount_taken '||
        '        ,Null                                                       amount_remaining '||
        '        ,Null                                                       discount_amount_remaining '||
        '        ,Null                                                       payment_amount '||
        '        ,Null                                                       discount_amount '||
        '        ,Null                                                       sequence_num '||
        '        ,Null                                                       done_pay_reason_code '||
        '        ,Null                                                       check_number '||
        '        ,Null                                                       bank_account_type '||
        '        ,Null                                                       original_invoice_id '||
        '        ,Null                                                       original_payment_num '||
        '        ,Null                                                       bank_account_num '||
        '        ,Null                                                       bank_num '||
        '        ,Null                                                       proposed_payment_amount '||
        '        ,Null                                                       pay_selected_check_id '||
        '        ,Null                                                       print_selected_check_id '||
        '        ,Null                                                       withholding_amount '||
        '        ,Null                                                       invoice_payment_id '||
        '        ,Null                                                       dont_pay_description '||
        '        ,Null                                                       transfer_priority '||
        '        ,Null                                                       iban_number '||
        '        ,Null                                                       payment_grouping_number '||
        '        ,Null                                                       payment_exchange_rate '||
        '        ,Null                                                       payment_exchange_rate_type '||
        '        ,Null                                                       payment_exchange_date '||
                 --Start of 8217641
        '        ,ps.remit_to_supplier_name                                  remit_to_supplier_name '||
        '        ,ps.remit_to_supplier_id                                    remit_to_supplier_id '||
        '        ,ps.remit_to_supplier_site                                  remit_to_supplier_site '||
        '        ,ps.remit_to_supplier_site_id                               remit_to_supplier_site_id '||
                --End 8217641
        '   FROM   ap_supplier_sites_all sites, '||
        '          ap_suppliers suppliers, '||
        '          ap_invoices ai,  '||             /* inv,  '||  Commented for bug#9182499 GSCC Error File.Sql.6 --Bug6040657. Changed from ap_invoices_all to ap_invoices */
        '          ap_payment_schedules_all ps, '||
        '          ap_system_parameters_all asp, '||
        '          hz_parties hzp, '||
        '          hz_party_sites hzps,           '|| -- Bug 5620285
        '          hz_locations   hzl             '|| -- Bug 5620285
        '   WHERE   ps.checkrun_id is null        '|| -- Bug 5705276. Regression
        '       AND ((due_date <= to_date(:p_pay_thru_date, ''DD-MM-YYYY'') +0/24 and  '|| --Bug 8708165
        '               due_date >= nvl(to_date(:p_pay_from_date, ''DD-MM-YYYY'') + 0/24,due_date)) '||
        '              OR '||
        '               DECODE(NVL(sites.pay_date_basis_lookup_code,''DISCOUNT''), '||
        '                    ''DISCOUNT'', '||
        '                    DECODE(sites.always_take_disc_flag, '||
        '                           ''Y'', ps.discount_date, '||
        '                           DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'') '||
        '                                  -NVL(ps.discount_date, '||
        '                                       to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                                  -1, ps.discount_date, '||
        '                                  DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'') '||
        '                                              -NVL(ps.second_discount_date, '||
        '                                                   to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                                         -1, ps.second_discount_date, '||
        '                                         DECODE(SIGN(to_date(:p_check_date, ''DD-MM-YYYY'') '||
        '                                                     -NVL(ps.third_discount_date, '||
        '                                                         to_date(:p_check_date, ''DD-MM-YYYY'')+1)-1), '||
        '                                                -1, ps.third_discount_date, '||
        '                                                TRUNC(ps.due_date))))), '||
        '                    TRUNC(due_date)) '||
        '                    BETWEEN DECODE(sites.always_take_disc_flag,''Y'', '||
        '                                    nvl(to_date(:p_pay_from_date, ''DD-MM-YYYY''), TO_DATE(''1901'',''YYYY'')), '||
        '                                    to_date(:p_check_date, ''DD-MM-YYYY'') ) '||
        '                            AND to_date(:p_disc_pay_thru_date, ''DD-MM-YYYY'') ) '||
        '       AND    ps.payment_status_flag BETWEEN ''N'' AND ''P'' '||
        '       AND    nvl(ai.force_revalidation_flag, ''N'') = ''N''  '||  --bug7244642
        '       AND    ai.payment_status_flag BETWEEN ''N'' AND ''P'' '||
        '       AND    NVL(ps.payment_priority, 99) BETWEEN :p_hi_payment_priority '||
        '                                              AND :p_lo_payment_priority '||
        '       AND    ai.cancelled_date is null '||
               -- Bug 7167192 Added decode
               -- hzp and hzps data is required only for Payment Requests.
        '       AND    hzp.party_id(+) = decode(ai.invoice_type_lookup_code, '||
        '                                       ''PAYMENT REQUEST'', ai.party_id '||
        '                                                        , -99) '||
        '       AND    NVL(ps.hold_flag, ''N'') = ''N'' '||
        '       AND    NVL(sites.hold_all_payments_flag, ''N'') = ''N'' '||
        '       AND    ai.invoice_id = ps.invoice_id '||
        '       AND    sites.vendor_id(+) = ai.vendor_id '||
        '       AND    sites.vendor_site_id(+) = ai.vendor_site_id '||
        '       AND    suppliers.vendor_id(+) = ai.vendor_id '||
        '       AND    asp.org_id = ai.org_id '||
        '       AND    hzp.party_id = hzps.party_id (+)  '|| -- Bug 5620285
               -- Bug  5929034: An employee does not have a hz_party_site changing query to reflect the same
               -- AND  nvl(hzps.party_site_id,-99)  = decode(suppliers.vendor_type_lookup_code,'EMPLOYEE',-99,nvl(inv.party_site_id, hzps.party_site_id))  -- Bug 5620285
               -- Bug  6662382
               -- Bug  7167192 - Query condition is now based on whether the Invoice
               --               is a Payment Request. Supplier type does not matter.
               -- AND  NVL(hzps.party_site_id,-99)  = DECODE(suppliers.vendor_type_lookup_code,'EMPLOYEE', COALESCE(inv.party_site_id, hzps.party_site_id,-99),
               --                                          NVL(inv.party_site_id, hzps.party_site_id))
        '       AND    NVL(hzps.party_site_id,-99) = NVL(decode(ai.invoice_type_lookup_code, ''PAYMENT REQUEST'', ai.party_site_id, -99), hzps.party_site_id) '||
               -- Bug 7167192
        '       AND    nvl(hzps.location_id,-99) = hzl.location_id(+)  '|| -- Bug 5620285
               --End Bug 5929034
        '       AND    fv_econ_benf_disc.ebd_check(:p_checkrun_name, ai.invoice_id, '||
        '                                  to_date(:p_check_date, ''DD-MM-YYYY''), due_date, ps.discount_amount_available, ps.discount_date) = ''Y'' ';
               -- Bug 7265013 starts
               -- AND    AP_INVOICES_PKG.get_wfapproval_status(inv.invoice_id, inv.org_id) in
               --             ('NOT REQUIRED','WFAPPROVED','MANUALLY APPROVED')
               -- Bug 7265013 ends



        IF l_invoice_batch_id IS NOT NULL THEN
          l_sql_stmt := l_sql_stmt||'              AND  ai.batch_id = :p_inv_batch_id ';
        ELSE
          l_sql_stmt := l_sql_stmt||'              AND  nvl(:p_inv_batch_id, -9999) = -9999 ';
        END IF;

        IF l_inv_vendor_id IS NOT NULL THEN
          l_sql_stmt := l_sql_stmt||'       AND    ai.vendor_id = :p_inv_vendor_id  ';
        ELSE
          l_sql_stmt := l_sql_stmt||'       AND    nvl(:p_inv_vendor_id, -9999) = -9999 ';
        END IF;

        IF l_party_id IS NOT NULL THEN
           l_sql_stmt := l_sql_stmt||'       AND    ai.party_id = :p_party_id ';
        ELSE
           l_sql_stmt := l_sql_stmt||'       AND    nvl(:p_party_id, -9999) = -9999 ';
        END IF;


               -- Bug 5507013 hkaniven start --
        l_sql_stmt := l_sql_stmt||
           '       AND    (( :p_inv_exc_rate_type = ''IS_USER'' AND NVL(ai.exchange_rate_type,''NOT USER'') = ''User'' ) '||
           '               OR (:p_inv_exc_rate_type = ''IS_NOT_USER'' AND NVL(ai.exchange_rate_type,''NOT USER'') <> ''User'') '||
           '               OR (:p_inv_exc_rate_type IS NULL)) '||
                  -- Bug 5507013 hkaniven end --
           '       AND    ps.payment_method_code = nvl(:p_payment_method, ps.payment_method_code) '||
           '       AND    nvl(suppliers.vendor_type_lookup_code,-99) = '||
           '                   nvl(:p_supplier_type, nvl(suppliers.vendor_type_lookup_code,-99)) '||
           '       AND    (ai.legal_entity_id in (select /*+ push_subq */ legal_entity_id '||
           '                                       from   ap_le_group '||
           '                                       where  checkrun_id = :p_checkrun_id) '||
           '               or :p_le_group_option = ''ALL'') '||
           '       AND    (ai.org_id in (select /*+ push_subq */ org_id '||
           '                              from   AP_OU_GROUP '||
           '                              where  checkrun_id = :p_checkrun_id) '||
           '               or :p_ou_group_option = ''ALL'') '||
           '       AND    (ai.payment_currency_code in (select /*+ push_subq */ currency_code '||
           '                                            from   AP_CURRENCY_GROUP '||
           '                                            where  checkrun_id = :p_checkrun_id) '||
           '               or :p_curr_group_option = ''ALL'') ';

        IF l_pay_group_option <> 'ALL' THEN
          l_sql_stmt := l_sql_stmt||
            /* Commented for Bug#9182499 Start
            '       AND    inv.pay_group_lookup_code in (select / *+ leading(apg) cardinality(apg 1) * / vendor_pay_group '||
            '                                            from   AP_PAY_GROUP apg'||   --bug9087739, added alias for  AP_PAY_GROUP
            '                                            where  checkrun_id BETWEEN :p_checkrun_id AND :p_checkrun_id) ';
            Commented for Bug#9182499 End */
            /* Added for Bug#9182499 Start */
            '       AND (ai.pay_group_lookup_code, ai.org_id) in '||
            '                       ( select /*+ leading(apg) cardinality(apg 1) */ '||
            '                                apg.vendor_pay_group, mo.ORGANIZATION_ID '||
            '                           from AP_PAY_GROUP apg, MO_GLOB_ORG_ACCESS_TMP mo '||
            '                          where checkrun_id BETWEEN :p_checkrun_id AND :p_checkrun_id) ';
            /* Added for Bug#9182499 End */

        ELSE
          l_sql_stmt := l_sql_stmt||
            '       AND    :p_checkrun_id = :p_checkrun_id   ';
        END IF;

        l_sql_stmt := l_sql_stmt||
           '       AND    ((:p_zero_inv_allowed = ''N'' AND ps.amount_remaining <> 0) OR '||
           '                :p_zero_inv_allowed = ''Y'') '||
                  -- Bug 7265013 starts
           '       AND EXISTS ( '||
           '         SELECT 1 '||
           '         FROM   sys.dual '||
           '         WHERE  AP_INVOICES_PKG.get_wfapproval_status(ai.invoice_id, ai.org_id) in '||
           '                 (''NOT REQUIRED'',''WFAPPROVED'',''MANUALLY APPROVED'') '||
           '       ) '||
                  -- Bug 7265013 ends
           '       AND NOT EXISTS (SELECT /*+ push_subq */  ''Unreleased holds exist'' '||
           '                       FROM   ap_holds_all H '||
           '                       WHERE  H.invoice_id = ai.invoice_id '||
           '                       AND    H.release_lookup_code is null) '||
           '       AND NOT EXISTS (SELECT /*+ push_subq */  ''Invoice is not fully approved'' '||
           '                       FROM ap_invoice_distributions_all D2 '||
           '                       WHERE D2.invoice_id = ai.invoice_id '||
           '                       AND NVL(D2.match_status_flag, ''N'') in (''N'', ''S'')) '||
           '       AND EXISTS (SELECT /*+ push_subq */  ''Distributions exist'' '||
           '                   FROM   ap_invoice_distributions_all D4 '||
           '                   WHERE  D4.invoice_id = ai.invoice_id) ';
                  -- bug 6456537
           /*      AND NOT EXISTS (SELECT ''CCR EXPIRED''
                                  FROM FV_TPP_ASSIGNMENTS_V TPP
                                  WHERE TPP.beneficiary_party_id = inv.party_id
                                  AND TPP.beneficiary_party_site_id = inv.party_site_id
                                  AND NVL(TPP.fv_tpp_pay_flag, ''Y'') = ''N'') bug8691645 */
        -- 6456537 Checking the validity of CCR of the Third Party for
        -- supplier. If the CCR is Invalid then the invoice document
        -- is not consider for the Payment(Auto Select)

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        OPEN refcur FOR l_sql_stmt USING
                                    l_payment_process_request_name,
                                    l_checkrun_id,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_pay_thru_date_char,
                                    l_pay_from_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_check_date_char,
                                    l_pay_from_date_char,
                                    l_check_date_char,
                                    l_disc_pay_thru_char,
                                    l_hi_payment_priority,
                                    l_low_payment_priority,
                                    l_payment_process_request_name,
                                    l_check_date_char,
                                    l_invoice_batch_id,
                                    l_inv_vendor_id,
                                    l_party_id,
                                    l_inv_exchange_rate_type,
                                    l_inv_exchange_rate_type,
                                    l_inv_exchange_rate_type,
                                    l_payment_method,
                                    l_supplier_type,
                                    l_checkrun_id,
                                    l_le_group_option,
                                    l_checkrun_id,
                                    l_ou_group_option,
                                    l_checkrun_id,
                                    l_currency_group_option,
                                    l_checkrun_id,
                                    l_checkrun_id,
                                    l_zero_invoices_allowed,
                                    l_zero_invoices_allowed;
        LOOP
        FETCH refcur BULK COLLECT INTO
               sel_inv_list.checkrun_name_l
              ,sel_inv_list.checkrun_id_l
              ,sel_inv_list.invoice_id_l
              ,sel_inv_list.payment_num_l
              ,sel_inv_list.last_update_date_l
              ,sel_inv_list.last_updated_by_l
              ,sel_inv_list.creation_date_l
              ,sel_inv_list.created_by_l
              ,sel_inv_list.last_update_login_l
              ,sel_inv_list.vendor_id_l
              ,sel_inv_list.vendor_site_id_l
              ,sel_inv_list.vendor_num_l
              ,sel_inv_list.vendor_name_l
              ,sel_inv_list.vendor_site_code_l
              ,sel_inv_list.address_line1_l
              ,sel_inv_list.address_line2_l
              ,sel_inv_list.address_line3_l
              ,sel_inv_list.address_line4_l
              ,sel_inv_list.city_l
              ,sel_inv_list.state_l
              ,sel_inv_list.zip_l
              ,sel_inv_list.province_l
              ,sel_inv_list.country_l
              ,sel_inv_list.attention_ar_flag_l
              ,sel_inv_list.withholding_status_lookup_l
              ,sel_inv_list.invoice_num_l
              ,sel_inv_list.invoice_date_l
              ,sel_inv_list.voucher_num_l
              ,sel_inv_list.ap_ccid_l
              ,sel_inv_list.due_date_l
              ,sel_inv_list.discount_date_l
              ,sel_inv_list.invoice_description_l
              ,sel_inv_list.payment_priority_l
              ,sel_inv_list.ok_to_pay_flag_l
              ,sel_inv_list.always_take_disc_flag_l
              ,sel_inv_list.amount_modified_flag_l
              ,sel_inv_list.invoice_amount_l
              ,sel_inv_list.payment_cross_rate_l
              ,sel_inv_list.invoice_exchange_rate_l
              ,sel_inv_list.set_of_books_id_l
              ,sel_inv_list.customer_num_l
              ,sel_inv_list.future_pay_due_date_l
              ,sel_inv_list.exclusive_payment_flag_l
              ,sel_inv_list.attribute1_l
              ,sel_inv_list.attribute2_l
              ,sel_inv_list.attribute3_l
              ,sel_inv_list.attribute4_l
              ,sel_inv_list.attribute5_l
              ,sel_inv_list.attribute6_l
              ,sel_inv_list.attribute7_l
              ,sel_inv_list.attribute8_l
              ,sel_inv_list.attribute9_l
              ,sel_inv_list.attribute10_l
              ,sel_inv_list.attribute11_l
              ,sel_inv_list.attribute12_l
              ,sel_inv_list.attribute13_l
              ,sel_inv_list.attribute14_l
              ,sel_inv_list.attribute15_l
              ,sel_inv_list.attribute_category_l
              ,sel_inv_list.org_id_l
              ,sel_inv_list.payment_currency_code_l
              ,sel_inv_list.external_bank_account_id_l
              ,sel_inv_list.legal_entity_id_l
              ,sel_inv_list.global_attribute1_l
              ,sel_inv_list.global_attribute2_l
              ,sel_inv_list.global_attribute3_l
              ,sel_inv_list.global_attribute4_l
              ,sel_inv_list.global_attribute5_l
              ,sel_inv_list.global_attribute6_l
              ,sel_inv_list.global_attribute7_l
              ,sel_inv_list.global_attribute8_l
              ,sel_inv_list.global_attribute9_l
              ,sel_inv_list.global_attribute10_l
              ,sel_inv_list.global_attribute11_l
              ,sel_inv_list.global_attribute12_l
              ,sel_inv_list.global_attribute13_l
              ,sel_inv_list.global_attribute14_l
              ,sel_inv_list.global_attribute15_l
              ,sel_inv_list.global_attribute16_l
              ,sel_inv_list.global_attribute17_l
              ,sel_inv_list.global_attribute18_l
              ,sel_inv_list.global_attribute19_l
              ,sel_inv_list.global_attribute20_l
              ,sel_inv_list.global_attribute_category_l
              ,sel_inv_list.amount_paid_l
              ,sel_inv_list.discount_amount_taken_l
              ,sel_inv_list.amount_remaining_l
              ,sel_inv_list.discount_amount_remaining_l
              ,sel_inv_list.payment_amount_l
              ,sel_inv_list.discount_amount_l
              ,sel_inv_list.sequence_num_l
              ,sel_inv_list.dont_pay_reason_code_l
              ,sel_inv_list.check_number_l
              ,sel_inv_list.bank_account_type_l
              ,sel_inv_list.original_invoice_id_l
              ,sel_inv_list.original_payment_num_l
              ,sel_inv_list.bank_account_num_l
              ,sel_inv_list.bank_num_l
              ,sel_inv_list.proposed_payment_amount_l
              ,sel_inv_list.pay_selected_check_id_l
              ,sel_inv_list.print_selected_check_id_l
              ,sel_inv_list.withhloding_amount_l
              ,sel_inv_list.invoice_payment_id_l
              ,sel_inv_list.dont_pay_description_l
              ,sel_inv_list.transfer_priority_l
              ,sel_inv_list.iban_number_l
              ,sel_inv_list.payment_grouping_number_l
              ,sel_inv_list.payment_exchange_rate_l
              ,sel_inv_list.payment_exchange_rate_type_l
              ,sel_inv_list.payment_exchange_date_l
                 --Start of 8217641
              ,sel_inv_list.remit_to_supplier_name_l
              ,sel_inv_list.remit_to_supplier_id_l
              ,sel_inv_list.remit_to_supplier_site_l
              ,sel_inv_list.remit_to_supplier_site_id_l
              --End 8217641
              LIMIT 1000;

          l_debug_info := 'Update ap_payment_schedules_all: encumbrances are off';
          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line(FND_FILE.LOG,l_debug_info);
          END IF;

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;


          FORALL i IN sel_inv_list.invoice_id_l.FIRST .. sel_inv_list.invoice_id_l.LAST
            UPDATE Ap_Payment_Schedules_All
            SET    checkrun_id = sel_inv_list.checkrun_id_l(i)
            WHERE  invoice_id = sel_inv_list.invoice_id_l(i)
            AND    payment_num = sel_inv_list.payment_num_l(i)
            AND    checkrun_id IS NULL --bug 6788730
            ;


          l_debug_info := 'Insert into ap_selected_invoices_all: encumbrances are off';
          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line(FND_FILE.LOG,l_debug_info);
          END IF;

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;


          FORALL i IN sel_inv_list.invoice_id_l.FIRST .. sel_inv_list.invoice_id_l.LAST
            INSERT INTO ap_selected_invoices_all
              (checkrun_name
              ,checkrun_id
              ,invoice_id
              ,payment_num
              ,last_update_date
              ,last_updated_by
              ,creation_date
              ,created_by
              ,vendor_id
              ,vendor_site_id
              ,vendor_num
              ,vendor_name
              ,vendor_site_code
              ,address_line1
              ,address_line2
              ,address_line3
              ,address_line4
              ,city
              ,state
              ,zip
              ,province
              ,country
              ,attention_ar_flag
              ,withholding_status_lookup_code
              ,invoice_num
              ,invoice_date
              ,voucher_num
              ,ap_ccid
              ,due_date
              ,discount_date
              ,invoice_description
              ,payment_priority
              ,ok_to_pay_flag
              ,always_take_discount_flag
              ,amount_modified_flag
              ,invoice_amount
              ,payment_cross_rate
              ,invoice_exchange_rate
              ,set_of_books_id
              ,customer_num
              ,future_pay_due_date
              ,exclusive_payment_flag
              ,attribute1
              ,attribute2
              ,attribute3
              ,attribute4
              ,attribute5
              ,attribute6
              ,attribute7
              ,attribute8
              ,attribute9
              ,attribute10
              ,attribute11
              ,attribute12
              ,attribute13
              ,attribute14
              ,attribute15
              ,attribute_category
              ,org_id
              ,payment_currency_code
              ,external_bank_account_id
              ,legal_entity_id
              ,global_attribute1
              ,global_attribute2
              ,global_attribute3
              ,global_attribute4
              ,global_attribute5
              ,global_attribute6
              ,global_attribute7
              ,global_attribute8
              ,global_attribute9
              ,global_attribute10
              ,global_attribute11
              ,global_attribute12
              ,global_attribute13
              ,global_attribute14
              ,global_attribute15
              ,global_attribute16
              ,global_attribute17
              ,global_attribute18
              ,global_attribute19
              ,global_attribute20
              ,global_attribute_category
              --Start of 8217641
              ,remit_to_supplier_name
              ,remit_to_supplier_id
              ,remit_to_supplier_site
              ,remit_to_supplier_site_id
              --End 8217641
              )
        --bug 6788730 Changed this to SELECT
        --
        --  VALUES
              (
              SELECT /*+ INDEX(AP_PAYMENT_SCHEDULES_ALL,AP_PAYMENT_SCHEDULES_U1) */
               sel_inv_list.checkrun_name_l(i)
              ,sel_inv_list.checkrun_id_l(i)
              ,sel_inv_list.invoice_id_l(i)
              ,sel_inv_list.payment_num_l(i)
              ,sel_inv_list.last_update_date_l(i)
              ,sel_inv_list.last_updated_by_l(i)
              ,sel_inv_list.creation_date_l(i)
              ,sel_inv_list.created_by_l(i)
              ,sel_inv_list.vendor_id_l(i)
              ,sel_inv_list.vendor_site_id_l(i)
              ,sel_inv_list.vendor_num_l(i)
              ,sel_inv_list.vendor_name_l(i)
              ,sel_inv_list.vendor_site_code_l(i)
              ,sel_inv_list.address_line1_l(i)
              ,sel_inv_list.address_line2_l(i)
              ,sel_inv_list.address_line3_l(i)
              ,sel_inv_list.address_line4_l(i)
              ,sel_inv_list.city_l(i)
              ,sel_inv_list.state_l(i)
              ,sel_inv_list.zip_l(i)
              ,sel_inv_list.province_l(i)
              ,sel_inv_list.country_l(i)
              ,sel_inv_list.attention_ar_flag_l(i)
              ,sel_inv_list.withholding_status_lookup_l(i)
              ,sel_inv_list.invoice_num_l(i)
              ,sel_inv_list.invoice_date_l(i)
              ,sel_inv_list.voucher_num_l(i)
              ,sel_inv_list.ap_ccid_l(i)
              ,sel_inv_list.due_date_l(i)
              ,sel_inv_list.discount_date_l(i)
              ,sel_inv_list.invoice_description_l(i)
              ,sel_inv_list.payment_priority_l(i)
              ,sel_inv_list.ok_to_pay_flag_l(i)
              ,sel_inv_list.always_take_disc_flag_l(i)
              ,sel_inv_list.amount_modified_flag_l(i)
              ,sel_inv_list.invoice_amount_l(i)
              ,sel_inv_list.payment_cross_rate_l(i)
              ,sel_inv_list.invoice_exchange_rate_l(i)
              ,sel_inv_list.set_of_books_id_l(i)
              ,sel_inv_list.customer_num_l(i)
              ,sel_inv_list.future_pay_due_date_l(i)
              ,sel_inv_list.exclusive_payment_flag_l(i)
              ,sel_inv_list.attribute1_l(i)
              ,sel_inv_list.attribute2_l(i)
              ,sel_inv_list.attribute3_l(i)
              ,sel_inv_list.attribute4_l(i)
              ,sel_inv_list.attribute5_l(i)
              ,sel_inv_list.attribute6_l(i)
              ,sel_inv_list.attribute7_l(i)
              ,sel_inv_list.attribute8_l(i)
              ,sel_inv_list.attribute9_l(i)
              ,sel_inv_list.attribute10_l(i)
              ,sel_inv_list.attribute11_l(i)
              ,sel_inv_list.attribute12_l(i)
              ,sel_inv_list.attribute13_l(i)
              ,sel_inv_list.attribute14_l(i)
              ,sel_inv_list.attribute15_l(i)
              ,sel_inv_list.attribute_category_l(i)
              ,sel_inv_list.org_id_l(i)
              ,sel_inv_list.payment_currency_code_l(i)
              ,sel_inv_list.external_bank_account_id_l(i)
              ,sel_inv_list.legal_entity_id_l(i)
              ,sel_inv_list.global_attribute1_l(i)
              ,sel_inv_list.global_attribute2_l(i)
              ,sel_inv_list.global_attribute3_l(i)
              ,sel_inv_list.global_attribute4_l(i)
              ,sel_inv_list.global_attribute5_l(i)
              ,sel_inv_list.global_attribute6_l(i)
              ,sel_inv_list.global_attribute7_l(i)
              ,sel_inv_list.global_attribute8_l(i)
              ,sel_inv_list.global_attribute9_l(i)
              ,sel_inv_list.global_attribute10_l(i)
              ,sel_inv_list.global_attribute11_l(i)
              ,sel_inv_list.global_attribute12_l(i)
              ,sel_inv_list.global_attribute13_l(i)
              ,sel_inv_list.global_attribute14_l(i)
              ,sel_inv_list.global_attribute15_l(i)
              ,sel_inv_list.global_attribute16_l(i)
              ,sel_inv_list.global_attribute17_l(i)
              ,sel_inv_list.global_attribute18_l(i)
              ,sel_inv_list.global_attribute19_l(i)
              ,sel_inv_list.global_attribute20_l(i)
              ,sel_inv_list.global_attribute_category_l(i)
               --Start of 8217641
              ,sel_inv_list.remit_to_supplier_name_l(i)
              ,sel_inv_list.remit_to_supplier_id_l(i)
              ,sel_inv_list.remit_to_supplier_site_l(i)
              ,sel_inv_list.remit_to_supplier_site_id_l(i)
              --End 8217641
            FROM Ap_Payment_Schedules_All
            WHERE  invoice_id = sel_inv_list.invoice_id_l(i)
            AND    payment_num = sel_inv_list.payment_num_l(i)
            AND    checkrun_id = sel_inv_list.checkrun_id_l(i)
            --bug 6788730
            );


        EXIT WHEN refcur%NOTFOUND;
      END LOOP;

      COMMIT;
    CLOSE refcur;


  end if;


  --COMMIT;


  l_debug_info := 'Done Inserting Into Ap_Selected_Invoices_AlL';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  -- Bug 5646890. Added l_checkrun_id condition for performance reason
  UPDATE Ap_Payment_Schedules_All aps
  SET    checkrun_id = null
  WHERE  checkrun_id = l_checkrun_id
  AND    NOT EXISTS (SELECT /*+HASH_AJ */ 'no row in asi'
                     FROM  ap_selected_invoices_all asi
                     WHERE asi.invoice_id = aps.invoice_id
                     AND   asi.payment_num = aps.payment_num
                     AND   asi.checkrun_id = l_checkrun_id);

   --for payment date, reject if itn's not in an open period
   --for payment date < system date and allow pre-date payables option is disabled
   -- Bug 5646890. Rewrite the following two update as per Performance team
   --Bug#8236818 As per the Documentation; Payables does not allow payment entry or
   --payment voiding in a Future period.The date must be in an open accounting period.

  UPDATE AP_SELECTED_INVOICES_ALL ASI
  SET    OK_TO_PAY_FLAG   = 'N',
         DONT_PAY_REASON_CODE = 'PERIOD CLOSED'
  WHERE  CHECKRUN_ID          = l_checkrun_id
    AND EXISTS
        (SELECT  NULL
         FROM    AP_SELECTED_INVOICES_ALL ASI2
         WHERE   ASI.INVOICE_ID   =ASI2.INVOICE_ID
         AND     ASI.PAYMENT_NUM  = ASI2.PAYMENT_NUM
         AND     ASI2.CHECKRUN_ID = l_checkrun_id
         AND NOT EXISTS
         (SELECT  NULL
          FROM    GL_PERIOD_STATUSES GLPS
          WHERE   TRUNC(l_check_date) BETWEEN GLPS.START_DATE AND GLPS.END_DATE
          AND     GLPS.CLOSING_STATUS  = 'O' --For Payment Only Open Periods are allowed
          AND     GLPS.APPLICATION_ID  = 200
          AND     GLPS.SET_OF_BOOKS_ID = ASI2.SET_OF_BOOKS_ID));


  UPDATE Ap_Selected_Invoices_All ASI
  SET    ok_to_pay_flag = 'N',
         dont_pay_reason_code =  'PRE DATE NOT ALLOWED'
  WHERE  checkrun_id = l_checkrun_id
  AND    Exists (SELECT /*+NO_UNNEST */ NULL
                FROM  Ap_Selected_Invoices_All ASI2,
                      Ap_System_Parameters_All ASP
                WHERE ASI.invoice_id = ASI2.invoice_id
                AND   ASI.payment_num = ASI2.payment_num
                AND   ASI2.checkrun_id = l_checkrun_id
                AND   ASI2.org_id    = ASP.org_id
                AND   ASI2.set_of_books_id = ASP.set_of_books_id
                AND   NVL(ASP.post_dated_payments_flag, 'N') = 'N'
                AND   trunc(l_check_date) < trunc(sysdate));

--Start of 8217641

UPDATE AP_SELECTED_INVOICES_ALL ASI
  SET    OK_TO_PAY_FLAG   = 'N',
         DONT_PAY_REASON_CODE = 'INVALID REMIT SUPPLIER'
  WHERE  CHECKRUN_ID          = l_checkrun_id
    AND EXISTS
        (SELECT  NULL
         FROM    AP_SELECTED_INVOICES_ALL ASI2
         WHERE   ASI.INVOICE_ID   =ASI2.INVOICE_ID
         AND     ASI.PAYMENT_NUM  = ASI2.PAYMENT_NUM
         AND     ASI2.CHECKRUN_ID = l_checkrun_id
         --introduced for 8403042/8404650
         AND EXISTS
         (SELECT 1
          FROM AP_INVOICES_ALL AI
          WHERE AI.INVOICE_ID = ASI2.INVOICE_ID
           AND   NVL(AI.RELATIONSHIP_ID,-1) <> -1)
        --end of 8403042/8404650
         AND NOT EXISTS
         (SELECT  NULL
          FROM  iby_ext_payee_relationships irel
          WHERE irel.party_id = (select party_id
                                 from ap_suppliers
                                                       where vendor_id = ASI2.vendor_id)
           AND irel.supplier_site_id =ASI2.vendor_site_id
                 AND irel.remit_party_id =  (select party_id
                                            from ap_suppliers
                                                                    where vendor_id = ASI2.remit_to_supplier_id)
           AND irel.remit_supplier_site_id = ASI2.remit_to_supplier_site_id
           AND irel.active = 'Y'
           AND to_char(l_check_date,'YYYY-MM-DD HH24:MI:SS')
                    BETWEEN(to_char(irel.from_date, 'YYYY-MM-DD')||' 00:00:00')
                       AND(to_char(nvl(irel.to_date,l_check_date),'YYYY-MM-DD') || ' 23:59:59')));


 --End 8217641

  /*BUG :8691645 */

  l_debug_info := 'Calling check_ccr_status ';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

check_ccr_status  (l_checkrun_id
                  ,l_current_calling_sequence);



/* BUG:8691645 */


  l_debug_info := 'Calling Remove_Invoices';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  remove_invoices(l_checkrun_id,l_current_calling_sequence);

  l_debug_info := 'Calling Insert_UnselectedL';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  insert_unselected(  l_payment_process_request_name,
                      l_hi_payment_priority,
                      l_low_payment_priority,
                      l_invoice_batch_id,
                      l_inv_vendor_id,
                      l_inv_exchange_rate_type,
                      l_payment_method,
                      l_supplier_type,
                      l_le_group_option,
                      l_ou_group_option,
                      l_currency_group_option,
                      l_pay_group_option,
                      l_zero_invoices_allowed,
                      l_check_date,
                      l_checkrun_id,
                      l_current_calling_sequence,
                      l_party_id);



  l_debug_info := 'Update amounts in ap_selected_invoices';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  --PM has said payment request should not take discounts

  UPDATE ap_selected_invoices_all asi
  SET      (amount_remaining,
            discount_amount_remaining,
            payment_amount,
            proposed_payment_amount,
            discount_amount)
            =
     (SELECT
        PS.amount_remaining,
        0,
        decode(ai.invoice_type_lookup_code,'PAYMENT REQUEST',
         ps.amount_remaining,
         PS.amount_remaining
          - (DECODE(PS.GROSS_AMOUNT,
                   0, 0,
                   DECODE(asi.ALWAYS_TAKE_DISCOUNT_FLAG,
                          'Y', NVL(PS.DISCOUNT_AMOUNT_AVAILABLE,0),
                          GREATEST(DECODE(SIGN(l_check_date
                                               - NVL(PS.DISCOUNT_DATE,
                                                     TO_DATE('01/01/1901',
                                                             'MM/DD/YYYY'))),
                                          1, 0,
                                          NVL(ABS(PS.DISCOUNT_AMOUNT_AVAILABLE),0)),
                                   DECODE(SIGN(l_check_date
                                               - NVL(PS.SECOND_DISCOUNT_DATE,
                                                     TO_DATE('01/01/1901',
                                                             'MM/DD/YYYY'))),
                                          1, 0,
                                          NVL(ABS(PS.SECOND_DISC_AMT_AVAILABLE),0)),
                                   DECODE(SIGN(l_check_date
                                               - NVL(PS.THIRD_DISCOUNT_DATE,
                                                     TO_DATE('01/01/1901',
                                                             'MM/DD/YYYY'))),
                                          1, 0,
                                          NVL(ABS(PS.THIRD_DISC_AMT_AVAILABLE),0)),
                                   0)  * DECODE(SIGN(ps.gross_amount),-1,-1,1))
                          * (PS.AMOUNT_REMAINING / DECODE(PS.GROSS_AMOUNT,
                                                          0, 1,
                                                          PS.GROSS_AMOUNT))))),
        decode(ai.invoice_type_lookup_code,'PAYMENT REQUEST',
         ps.amount_remaining,
         PS.amount_remaining
         - (DECODE(PS.GROSS_AMOUNT,
                   0, 0,
                   DECODE(asi.ALWAYS_TAKE_DISCOUNT_FLAG,
                          'Y', NVL(PS.DISCOUNT_AMOUNT_AVAILABLE,0),
                          GREATEST(DECODE(SIGN(l_check_date
                                               - NVL(PS.DISCOUNT_DATE,
                                                     TO_DATE('01/01/1901',
                                                             'MM/DD/YYYY'))),
                                          1, 0,
                                          NVL(ABS(PS.DISCOUNT_AMOUNT_AVAILABLE),0)),
                                   DECODE(SIGN(l_check_date
                                               - NVL(PS.SECOND_DISCOUNT_DATE,
                                                     TO_DATE('01/01/1901',
                                                             'MM/DD/YYYY'))),
                                          1, 0,
                                          NVL(ABS(PS.SECOND_DISC_AMT_AVAILABLE),0)),
                                   DECODE(SIGN(l_check_date
                                               - NVL(PS.THIRD_DISCOUNT_DATE,
                                                     TO_DATE('01/01/1901',
                                                             'MM/DD/YYYY'))),
                                          1, 0,
                                          NVL(ABS(PS.THIRD_DISC_AMT_AVAILABLE),0)),
                                   0)  * DECODE(SIGN(ps.gross_amount),-1,-1,1))
                          * (PS.AMOUNT_REMAINING / DECODE(PS.GROSS_AMOUNT,
                                                          0, 1,
                                                          PS.GROSS_AMOUNT))))),
        decode(ai.invoice_type_lookup_code,'PAYMENT REQUEST',
         0,
         DECODE(PS.GROSS_AMOUNT,
               0, 0,
               DECODE(asi.ALWAYS_TAKE_DISCOUNT_FLAG,
                      'Y', NVL(PS.DISCOUNT_AMOUNT_AVAILABLE,0),
                      GREATEST(DECODE(SIGN(l_check_date
                                           - NVL(PS.DISCOUNT_DATE,
                                                 TO_DATE('01/01/1901',
                                                         'MM/DD/YYYY'))),
                                      1, 0,
                                      NVL(ABS(PS.DISCOUNT_AMOUNT_AVAILABLE),0)),
                               DECODE(SIGN(l_check_date
                                           - NVL(PS.SECOND_DISCOUNT_DATE,
                                                 TO_DATE('01/01/1901',
                                                         'MM/DD/YYYY'))),
                                       1, 0,
                                       NVL(ABS(PS.SECOND_DISC_AMT_AVAILABLE),0)),
                               DECODE(SIGN(l_check_date
                                           - NVL(PS.THIRD_DISCOUNT_DATE,
                                                 TO_DATE('01/01/1901',
                                                         'MM/DD/YYYY'))),
                                       1, 0,
                                       NVL(ABS(PS.THIRD_DISC_AMT_AVAILABLE),0)),
                                0)   * DECODE(SIGN(ps.gross_amount),-1,-1,1))
                      * (PS.AMOUNT_REMAINING / DECODE(PS.GROSS_AMOUNT,
                                                      0, 1,
                                                      PS.GROSS_AMOUNT))))
    FROM  ap_payment_schedules_all PS,
          ap_invoices ai --Bug6040657. Changed from ap_invoices_all to ap_invoices
    WHERE PS.invoice_id = asi.invoice_id
    AND   PS.payment_num = asi.payment_num
    and   ai.invoice_id = ps.invoice_id)
  WHERE checkrun_id = l_checkrun_id;



  l_debug_info := 'Round amounts in ap_selected_invoices';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


    --round the values we just updated
  UPDATE ap_selected_invoices_all ASI
  SET    payment_amount = ap_utilities_pkg.ap_round_currency
                    (payment_amount,payment_currency_code),
         proposed_payment_amount = ap_utilities_pkg.ap_round_currency
                    (proposed_payment_amount,payment_currency_code) ,
         discount_amount = ap_utilities_pkg.ap_round_currency
                    (discount_amount,payment_currency_code)
  WHERE  checkrun_id= l_checkrun_id;


  --get rid of $0 invoices if not allowed
  update ap_selected_invoices_all
  set ok_to_pay_flag = 'N',
  dont_pay_reason_code = 'ZERO INVOICE'
  WHERE checkrun_id = l_checkrun_id
  AND   l_zero_invoices_allowed = 'N'
  AND   amount_remaining = 0;

  l_debug_info := 'Calling Calculate_Interest';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  calculate_interest (l_checkrun_id,
                      l_payment_process_request_name,
                      l_check_date,
                      l_current_calling_sequence);

  l_debug_info := 'updating exchange rate info';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  if l_batch_exchange_rate_type = 'User' then

    update ap_selected_invoices_all asi
    set (payment_exchange_rate_type, payment_exchange_rate) =
         (select 'User', exchange_rate
          from ap_user_exchange_rates auer,
               ap_system_parameters_all asp
          where asp.org_id = asi.org_id
          and   asi.payment_currency_code = auer.payment_currency_code
          and   asp.base_currency_code = auer.ledger_currency_code
          and   asp.base_currency_code <> asi.payment_currency_code
          and   auer.checkrun_id = l_checkrun_id)
    where checkrun_id = l_checkrun_id
    and (invoice_id, payment_num) in
         (select invoice_id, payment_num
          from ap_selected_invoices_all asi2,
               ap_system_parameters_all asp2
          where asp2.org_id = asi2.org_id
          and   asp2.base_currency_code <> asi2.payment_currency_code
          and   asi2.checkrun_id = l_checkrun_id);

  else
  --update for all other exchange rate types

    update ap_selected_invoices asi
    set (payment_exchange_rate_type, payment_exchange_rate) =
         (select l_batch_exchange_rate_type,
                 ap_utilities_pkg.get_exchange_rate(
                         asi.payment_currency_code,
                         asp.base_currency_code,
                         l_batch_exchange_rate_type,
                         l_check_date,
                         'AUTOSELECT')
          from ap_system_parameters_all asp
          where asp.org_id = asi.org_id
          and asp.base_currency_code <> asi.payment_currency_code)
    where checkrun_id = l_checkrun_id
    and (invoice_id, payment_num) in
         (select invoice_id, payment_num
          from ap_selected_invoices_all asi2,
               ap_system_parameters_all asp2
          where asp2.org_id = asi2.org_id
          and   asp2.base_currency_code <> asi2.payment_currency_code
          and   asi2.checkrun_id = l_checkrun_id);  --Bug 5123855



  end if;

  select count(*)
  into l_missing_rates_count
  from ap_selected_invoices_all asi,
       ap_system_parameters_all asp
  where asi.org_id = asp.org_id
  and asi.checkrun_id = l_checkrun_id
  and asi.payment_currency_code <> asp.base_currency_code
  and asi.payment_exchange_rate is null
  and ((l_batch_exchange_rate_type <> 'User'
       and asp.make_rate_mandatory_flag = 'Y') OR
       l_batch_exchange_rate_type = 'User')
  and rownum = 1;


--need to pause the request if payables options requires exchange rates
--and none were found or we are using 'user'exchange rate type

  if l_missing_rates_count > 0 then
    update ap_inv_selection_criteria_all
    set status = 'MISSING RATES'
    where checkrun_id = l_checkrun_id;

    if l_batch_exchange_rate_type = 'User' then
      insert into ap_user_exchange_rates auer
       (checkrun_id,
        payment_currency_code,
        ledger_currency_code,
        creation_date,
        created_by,  --Bug 5123855
        last_update_date,
        last_updated_by,
        last_update_login)
      (select l_checkrun_id,
               asi.payment_currency_code,
               asp.base_currency_code,
               SYSDATE,
               FND_GLOBAL.user_id,
               SYSDATE,
               FND_GLOBAL.user_id,
               FND_GLOBAL.login_id
        from ap_selected_invoices_all asi,
             ap_system_parameters_all asp
        where asi.payment_exchange_rate is null
        and asp.org_id = asi.org_id
        and asp.base_currency_code <> asi.payment_currency_code
        and asi.checkrun_id = l_checkrun_id
        group by asi.payment_currency_code,   /* bug 5447896 */
                 asp.base_currency_code);
    end if;
  end if;


  l_debug_info := 'Grouping selected invoices';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  group_interest_credits(l_checkrun_id, l_current_calling_sequence);

  /* Code Added for bug#8461050 Start */
  /* Need to gather table stat for ap_selected_invoices_all Since all insert/ update has
     already been done on the table */
  IF (   FND_INSTALLATION.GET_APP_INFO('SQLAP', l_status, l_industry, l_schema)
     AND nvl( fnd_profile.value('AP_GATHER_PPR_TABLE_STATS'), 'N') = 'Y'
     )
  THEN
     IF l_schema IS NOT NULL    THEN
        FND_STATS.GATHER_TABLE_STATS(l_schema, 'AP_SELECTED_INVOICES_ALL');
     END IF;
  END IF;

  remove_invoices (l_checkrun_id, l_current_calling_sequence );


  /* Bug 7683143: Moved the Withholding creation towards the end so that
     Withholding invoices is created only for the invoices which have
     been finally selected for the PPR, and not for Invoices which
     have been de-selected from the PPR. */

  l_debug_info := 'Calling ap_withholding_pkg';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  AP_WITHHOLDING_PKG.AP_WITHHOLD_AUTOSELECT(
                        l_payment_process_request_name,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.LOGIN_ID,
                        FND_GLOBAL.PROG_APPL_ID,
                        FND_GLOBAL.CONC_PROGRAM_ID,
                        FND_GLOBAL.CONC_REQUEST_ID,
                        l_checkrun_id);

--Bug6459578
  l_debug_info := 'Calling ap_custom_withholding_pkg';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  Awt_special_rounding(l_checkrun_id,l_current_calling_sequence);

--Bug6459578

--Overpayment Prevention, Bug 9440897
  mark_overpayments(l_checkrun_id, l_payment_process_request_name, l_current_calling_sequence);

  remove_invoices (l_checkrun_id, l_current_calling_sequence);

  --the rejection levels can be changed in our awt code, hence they need to be
  --retrieved after the call above
  -- Bug 7492768 Start
  -- We need to retrieve inv_awt_exists_flag that determines whether
  -- the PPR contains invoices that have AWT.
  -- If the flag is set then the invoice contains AWT and we must pass the
  -- rejection level code as REQUEST to IBY apis. Otherwise we can pass the same
  -- value defined by the user.
  select document_rejection_level_code,
         payment_rejection_level_code,
         inv_awt_exists_flag
  into   l_doc_rejection_level_code,
         l_pay_rejection_level_code,
         l_inv_awt_exists_flag
  from   ap_inv_selection_criteria_all
  where  checkrun_id = l_checkrun_id;

  -- Bug 8746215 If flag is Y then set rejection levels as PAYEE if they are not REQUEST.
  IF NVL(l_inv_awt_exists_flag, 'N') = 'Y' THEN
    IF l_doc_rejection_level_code <> 'REQUEST' THEN
      l_doc_rejection_level_code := 'PAYEE';
    END IF;
    IF l_pay_rejection_level_code <> 'REQUEST' THEN
      l_pay_rejection_level_code := 'PAYEE';
    END IF;
    -- Bug 8746215 End
  END IF;
  -- Bug 7492768 End


  --4745133, moved the code below to this position
  --as we could have removed invoices in the ppr
  --after they have been inserted into asi

  select count(*)
  into l_count_inv_selected
  from ap_selected_invoices_all
  where checkrun_id = l_checkrun_id
  and rownum = 1;


  if l_count_inv_selected = 0 then

    update ap_inv_selection_criteria_all
    set status = 'CANCELLED NO PAYMENTS'
    where checkrun_id = l_checkrun_id;

    commit;

    fnd_file.put_line(FND_FILE.LOG, 'No scheduled payments matched the invoice selection criteria');

    l_debug_info :=  'No scheduled payments matched the invoice selection criteria';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

   -- Bug 5111495
   -- app_exception.raise_exception;

    return;
  end if;




  --5007587
  declare

  l_init_msg_list varchar2(2000);
  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(2000);
  l_msg_index_out number;

  begin

    FV_FEDERAL_PAYMENT_FIELDS_PKG.SUBMIT_CASH_POS_REPORT(
      p_init_msg_list => l_init_msg_list,
      p_org_id        => null,
      p_checkrun_id   => l_checkrun_id,
      x_request_id    => l_req_id,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      IF l_msg_count > 0 THEN
          FOR i in 1..l_msg_count LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index_out);
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
      end if;
    end if;
  end;
  --end 5007857





  update ap_inv_selection_criteria_all
  set status = decode(l_payables_review_settings,'Y','REVIEW','SELECTED')
  where status = 'SELECTING'
  and checkrun_id = l_checkrun_id;

  -- Bug 4681857
  SELECT lower(iso_language),iso_territory
    INTO l_iso_language,l_iso_territory
    FROM FND_LANGUAGES
   WHERE language_code = USERENV('LANG');

   --Bug 6969710
   SELECT nvl(template_code, 'APINVSEL' )
     INTO l_template_code
     FROM Fnd_Concurrent_Programs
     WHERE concurrent_program_name = 'APINVSEL'; --Bug 6969710


  l_xml_output:=  fnd_request.add_layout(
                        template_appl_name  => 'SQLAP',
                        template_code       => l_template_code ,   --Bug 6969710
                        template_language   => l_iso_language,
                        template_territory  => l_iso_territory,
                        output_format       => 'PDF'
                            );

   --below code added for bug#7435751 as we need to set the current nls character setting
   fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
   l_return_status:= FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);

  --submit the selected payment schedules report
  l_req_id := FND_REQUEST.SUBMIT_REQUEST(
                  'SQLAP',
                  'APINVSEL',
                  '',
                  '',
                  FALSE,
                  to_char(l_checkrun_id),
                  chr(0));

  select status
  into l_batch_status
  from ap_inv_selection_criteria_all
  where checkrun_id = l_checkrun_id;

  if l_batch_status = 'SELECTED' and l_payables_review_settings <> 'Y' then

    l_debug_info := 'Submitting Oracle Payments Build';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;

    l_req_id := FND_REQUEST.SUBMIT_REQUEST(
                  'IBY',
                  'IBYBUILD',
                  '',
                  '',
                  FALSE,
                  '200',
                  l_payment_process_request_name,
                  to_char(l_bank_account_id),
                  to_char(l_payment_profile_id),
                  l_zero_invoices_allowed, -- Bug 6523501,
                  to_char(l_max_payment_amount),
                  to_char(l_min_check_amount),
                  l_doc_rejection_level_code,
                  l_pay_rejection_level_code,
                  l_pay_review_settings_flag,
                  l_create_instrs_flag,
                  l_payment_document_id,
                  /* bug 7519277*/
                l_ATTRIBUTE_CATEGORY,
                l_ATTRIBUTE1,
                l_ATTRIBUTE2,
                l_ATTRIBUTE3,
                l_ATTRIBUTE4,
                l_ATTRIBUTE5,
                l_ATTRIBUTE6,
                l_ATTRIBUTE7,
                l_ATTRIBUTE8,
                l_ATTRIBUTE9,
                l_ATTRIBUTE10,
                l_ATTRIBUTE11,
                l_ATTRIBUTE12,
                l_ATTRIBUTE13,
                l_ATTRIBUTE14,
                l_ATTRIBUTE15,
        /*bug 7519277*/
                  chr(0));

    l_debug_info := 'request_id ='||to_char(l_req_id);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line(FND_FILE.LOG,l_debug_info);
    END IF;

  end if;

  COMMIT;

EXCEPTION

    WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS','p_checkrun_id '||p_checkrun_id
                            ||',P_template_id '||P_template_id
                            ||',p_payment_date '||p_payment_date
                            ||',p_pay_thru_date '||p_pay_thru_date
                            ||',p_pay_from_date '||p_pay_from_date);



    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END SELECT_INVOICES;


PROCEDURE recalculate (errbuf             OUT NOCOPY VARCHAR2,
                       retcode            OUT NOCOPY NUMBER,
                       p_checkrun_id      in         varchar2,
                       p_submit_to_iby    in  varchar2 default 'N') is

  l_debug_info               varchar2(2000);
  l_checkrun_name            ap_inv_selection_criteria_all.checkrun_name%type;-- bug# 6643035
  l_check_date               date;
  l_bank_account_id          number; --4710933
  l_payment_profile_id       number;
  l_req_id                   number;
  l_zero_amounts_allowed     varchar2(1);
  l_zero_invoices_allowed    varchar2(1); -- Bug 6523501
  l_max_payment_amount       number;
  l_min_check_amount         number;
  l_doc_rejection_level_code varchar2(30);
  l_pay_rejection_level_code varchar2(30);
  l_pay_review_settings_flag varchar2(1);
  l_create_instrs_flag       varchar2(1);
  l_missing_rates_count      number;
  l_batch_exchange_rate_type varchar2(30);
  l_batch_status             varchar2(30);
  l_payment_document_id      number(15); --4939405
  l_xml_output               BOOLEAN;
  l_iso_language             FND_LANGUAGES.iso_language%TYPE;
  l_iso_territory            FND_LANGUAGES.iso_territory%TYPE;
  l_template_code      Fnd_Concurrent_Programs.template_code%TYPE; --Bug 6969710
   /*bug 7519277*/
  l_ATTRIBUTE_CATEGORY       VARCHAR2(150);
  l_ATTRIBUTE1               VARCHAR2(150);
  l_ATTRIBUTE2               VARCHAR2(150);
  l_ATTRIBUTE3               VARCHAR2(150);
  l_ATTRIBUTE4               VARCHAR2(150);
  l_ATTRIBUTE5               VARCHAR2(150);
  l_ATTRIBUTE6               VARCHAR2(150);
  l_ATTRIBUTE7               VARCHAR2(150);
  l_ATTRIBUTE8               VARCHAR2(150);
  l_ATTRIBUTE9               VARCHAR2(150);
  l_ATTRIBUTE10              VARCHAR2(150);
  l_ATTRIBUTE11              VARCHAR2(150);
  l_ATTRIBUTE12              VARCHAR2(150);
  l_ATTRIBUTE13              VARCHAR2(150);
  l_ATTRIBUTE14              VARCHAR2(150);
  l_ATTRIBUTE15              VARCHAR2(150);
  /*bug 7519277*/
  l_icx_numeric_characters   VARCHAR2(30); --for bug#7435751
  l_return_status   boolean; --for bug#7435751



  CURSOR c_all_sel_invs  IS
    SELECT invoice_id
    ,      vendor_id
    ,      payment_num
    ,      checkrun_id         	--bug 8888311
    ,      withholding_amount 	--bug 8888311
    FROM   ap_SELECTed_invoices_all ASI,
           ap_system_parameters_all asp
    WHERE  checkrun_name = l_checkrun_name
      AND  original_invoice_id IS NULL
      AND  asp.org_id = asi.org_id
      and  checkrun_id = p_checkrun_id
       AND  decode(nvl(ASP.allow_awt_flag, 'N'), 'Y',
                  decode(ASP.create_awt_dists_type,'BOTH','Y','PAYMENT',
                         'Y', decode(ASP.create_awt_invoices_type,'BOTH','Y','PAYMENT',
                                     'Y', 'N'),
                         'N'),
                  'N') = 'Y'; --Bug6660355
  rec_all_sel_invs c_all_sel_invs%ROWTYPE;

  l_current_calling_sequence varchar2(2000);



BEGIN


--in 11.5 we can do the undo and re-do of awt all at the same time
--but if I am to handle interest here instead of the front end then
--this cannot be done, we have to do interest calculations after awt
--is undone

  --4676790, since this code runs as a concurrent request the calling
  --code should update the status.


  l_current_calling_sequence := 'ap_autoselect_pkg.recalculate';
  l_debug_info:= 'delete interest invoices';


  delete from ap_selected_invoices_all
  where checkrun_id = p_checkrun_id
  and original_invoice_id is not null;

  SELECT
        checkrun_name,
        check_date,
        nvl(zero_amounts_allowed,'N'),
        nvl(zero_invoices_allowed,'N'), -- Bug 6523501
        bank_account_id, --4710933
        payment_profile_id,
        max_payment_amount,
        min_check_amount,
        payments_review_settings,
        --decode(payment_profile_id,null,'N',nvl(create_instrs_flag,'N')),
	nvl(create_instrs_flag,'N'),    -- Commented and added for bug 8925444
        document_rejection_level_code,
        payment_rejection_level_code,
        exchange_rate_type,
        payment_document_id,
        /*bug 7519277*/
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15
        /*bug 7519277*/
  INTO  l_checkrun_name,
        l_check_date,
        l_zero_amounts_allowed,
        l_zero_invoices_allowed, -- Bug 6523501
        l_bank_account_id,
        l_payment_profile_id,
        l_max_payment_amount,
        l_min_check_amount,
        l_pay_review_settings_flag,
        l_create_instrs_flag,
        l_doc_rejection_level_code,
        l_pay_rejection_level_code,
        l_batch_exchange_rate_type,
        l_payment_document_id,
        /* bug 7519277*/
                l_ATTRIBUTE_CATEGORY,
                l_ATTRIBUTE1,
                l_ATTRIBUTE2,
                l_ATTRIBUTE3,
                l_ATTRIBUTE4,
                l_ATTRIBUTE5,
                l_ATTRIBUTE6,
                l_ATTRIBUTE7,
                l_ATTRIBUTE8,
                l_ATTRIBUTE9,
                l_ATTRIBUTE10,
                l_ATTRIBUTE11,
                l_ATTRIBUTE12,
                l_ATTRIBUTE13,
                l_ATTRIBUTE14,
                l_ATTRIBUTE15
        /*bug 7519277*/
  FROM   ap_inv_selection_criteria_all
  WHERE  checkrun_id  = p_checkrun_id;




--undo awt, this is essentially the same code as in ap_withholding_pkg

  OPEN c_all_sel_invs;

  LOOP
    l_debug_info := 'Fetch CURSOR for all SELECTed invoices';
    FETCH c_all_sel_invs INTO rec_all_sel_invs;
    EXIT WHEN c_all_sel_invs%NOTFOUND;

    DECLARE
      undo_output VARCHAR2(2000);
    BEGIN
	  /* Added below update for bug 8888311 */

	    UPDATE ap_awt_temp_distributions_all aatd
		   SET withholding_amount = rec_all_sel_invs.withholding_amount
		 WHERE invoice_id    = rec_all_sel_invs.invoice_id
           AND payment_num   = rec_all_sel_invs.payment_num
           AND checkrun_id   = rec_all_sel_invs.checkrun_id
		   AND nvl(rec_all_sel_invs.withholding_amount,0) = 0;

        AP_WITHHOLDING_PKG.Ap_Undo_Temp_Withholding
                     (P_Invoice_Id             => rec_all_sel_invs.invoice_id
                     ,P_VENDor_Id              => rec_all_sel_invs.vendor_id
                     ,P_Payment_Num            => rec_all_sel_invs.payment_num
                     ,P_Checkrun_Name          => l_Checkrun_Name
                     ,P_Undo_Awt_Date          => SYSDATE
                     ,P_Calling_Module         => 'AUTOSELECT'
                     ,P_Last_Updated_By        => FND_GLOBAL.USER_ID
                     ,P_Last_Update_Login      => FND_GLOBAL.LOGIN_ID
                     ,P_Program_Application_Id => FND_GLOBAL.PROG_APPL_ID
                     ,P_Program_Id             => FND_GLOBAL.CONC_PROGRAM_ID
                     ,P_Request_Id             => FND_GLOBAL.CONC_REQUEST_ID
                     ,P_Awt_Success            => undo_output
                     ,P_checkrun_id            => p_checkrun_id );

    END;
  END LOOP;

  l_debug_info := 'CLOSE CURSOR for all SELECTed invoices';
  CLOSE c_all_sel_invs;



  update ap_selected_invoices_all
  set payment_grouping_number = null
  where checkrun_id = p_checkrun_id;

  -- Bug 7492768 We need to reset the inv_awt_exists_flag which indicates if the
  -- check run contains invoice that has awt.
  update ap_inv_selection_criteria_all
  set inv_awt_exists_flag = 'N'
  where checkrun_id = p_checkrun_id;

--redo interest
  calculate_interest (p_checkrun_id,
                      l_checkrun_name,
                      l_check_date,
                      l_current_calling_sequence);

  -- Bug 9255192 Exchange rate updation should occur before calculating awt
  -- Moved the following code before AP_WITHHOLDING_PKG.AP_WITHHOLD_AUTOSELECT
  -- Code flow should be same as mentioned in Procedure Select_Invoices

   l_debug_info := 'Recalculate: Updating Exchage rate info';
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_file.put_line(FND_FILE.LOG,l_debug_info);
   END IF;

   l_debug_info := 'Recalculate: Exchange Rate type is :'||l_batch_exchange_rate_type;
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_file.put_line(FND_FILE.LOG,l_debug_info);
   END IF;

  if l_batch_exchange_rate_type = 'User' then

    update ap_selected_invoices_all asi
    set (payment_exchange_rate_type, payment_exchange_rate) =
         (select 'User', exchange_rate
          from ap_user_exchange_rates auer,
               ap_system_parameters_all asp
          where asp.org_id = asi.org_id
          and   asi.payment_currency_code = auer.payment_currency_code
          and   asp.base_currency_code = auer.ledger_currency_code
          and   asp.base_currency_code <> asi.payment_currency_code
          and   auer.checkrun_id = p_checkrun_id)  --Bug 5123855
    where checkrun_id = p_checkrun_id
    and (invoice_id, payment_num) in
         (select invoice_id, payment_num
          from ap_selected_invoices_all asi2,
               ap_system_parameters_all asp2
          where asp2.org_id = asi2.org_id
          and   asp2.base_currency_code <> asi2.payment_currency_code
          and   asi2.checkrun_id = p_checkrun_id);

  else
  --update for all other exchange rate types

    update ap_selected_invoices asi
    set (payment_exchange_rate_type, payment_exchange_rate) =
         (select l_batch_exchange_rate_type,
                 ap_utilities_pkg.get_exchange_rate(
                         asi.payment_currency_code,
                         asp.base_currency_code,
                         l_batch_exchange_rate_type,
                         l_check_date,
                         'AUTOSELECT')
          from ap_system_parameters_all asp
          where asp.org_id = asi.org_id
          and asp.base_currency_code <> asi.payment_currency_code)
    where checkrun_id = p_checkrun_id
    and (invoice_id, payment_num) in
         (select invoice_id, payment_num
          from ap_selected_invoices_all asi2,
               ap_system_parameters_all asp2
          where asp2.org_id = asi2.org_id
          and   asp2.base_currency_code <> asi2.payment_currency_code
          and   asi2.checkrun_id = p_checkrun_id);

  end if;

  select count(*)
  into l_missing_rates_count
  from ap_selected_invoices_all asi,
       ap_system_parameters_all asp
  where asi.org_id = asp.org_id
  and asi.checkrun_id = p_checkrun_id
  and asi.payment_currency_code <> asp.base_currency_code
  and asi.payment_exchange_rate is null
  and ((l_batch_exchange_rate_type <> 'User'
       and asp.make_rate_mandatory_flag = 'Y') OR
       l_batch_exchange_rate_type = 'User')
  and rownum = 1;


  if l_missing_rates_count > 0 then

    update ap_inv_selection_criteria_all
    set status = 'MISSING RATES'
    where checkrun_id = p_checkrun_id;

    if l_batch_exchange_rate_type = 'User' then
      insert into ap_user_exchange_rates auer
       (checkrun_id,
        payment_currency_code,
        ledger_currency_code,
        creation_date,  --Bug 5123855
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
       (select p_checkrun_id,
               asi.payment_currency_code,
               asp.base_currency_code,
               SYSDATE,
               FND_GLOBAL.user_id,
               SYSDATE,
               FND_GLOBAL.user_id,
               FND_GLOBAL.login_id
        from ap_selected_invoices_all asi,
             ap_system_parameters_all asp
        where asi.payment_exchange_rate is null
        and asp.org_id = asi.org_id
        and asp.base_currency_code <> asi.payment_currency_code
        and asi.checkrun_id = p_checkrun_id
        and not exists (select 'row already in auer'
                        from ap_user_exchange_rates auer2
                        where auer2.checkrun_id = asi.checkrun_id
                        and   auer2.payment_currency_code = asi.payment_currency_code
                        and   auer2.ledger_currency_code = asp.base_currency_code));

    end if;
  end if;

--Bug 9255311 Regroup should occur before withholding so that orphans are not
--left in ap_awt_temp_distributions_all
--regroup

  group_interest_credits(p_checkrun_id, l_current_calling_sequence);

--Overpayment Prevention, Bug 9440897
  mark_overpayments(p_checkrun_id, l_checkrun_name, l_current_calling_sequence);

  remove_invoices (p_checkrun_id, l_current_calling_sequence );

--redo awt
  AP_WITHHOLDING_PKG.AP_WITHHOLD_AUTOSELECT(
                        l_checkrun_name,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.LOGIN_ID,
                        FND_GLOBAL.PROG_APPL_ID,
                        FND_GLOBAL.CONC_PROGRAM_ID,
                        FND_GLOBAL.CONC_REQUEST_ID,
                        p_checkrun_id);

  -- Start Bug 6743242

  l_debug_info := 'Calling ap_custom_withholding_pkg';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'.recalculate',l_debug_info);
  END IF;

  awt_special_rounding(p_checkrun_id,l_current_calling_sequence);

  -- End Bug 6743242

  -- Bug 7492768 start
  -- Bug 8746215 If inv_awt_exists is Y, then set rejection level as PAYEE if rejection level is not REQUEST.
  select decode(nvl(inv_awt_exists_flag, 'N'), 'Y', decode(document_rejection_level_code,'REQUEST',document_rejection_level_code,'PAYEE'), document_rejection_level_code) document_rejection_level_code,
       decode(nvl(inv_awt_exists_flag, 'N'), 'Y', decode(payment_rejection_level_code,'REQUEST',payment_rejection_level_code,'PAYEE'), payment_rejection_level_code) payment_rejection_level_code
  --Bug 8746215 End
  into l_doc_rejection_level_code,
       l_pay_rejection_level_code
  FROM   ap_inv_selection_criteria_all
  WHERE  checkrun_id  = p_checkrun_id;
  -- Bug 7492768 End

  remove_invoices (p_checkrun_id, l_current_calling_sequence );

-- Commented the following code for bug 9255192
-- Now exchange rate will be calculated before calling WITHHOLDING pkg
/*
  if l_batch_exchange_rate_type = 'User' then

    update ap_selected_invoices_all asi
    set (payment_exchange_rate_type, payment_exchange_rate) =
         (select 'User', exchange_rate
          from ap_user_exchange_rates auer,
               ap_system_parameters_all asp
          where asp.org_id = asi.org_id
          and   asi.payment_currency_code = auer.payment_currency_code
          and   asp.base_currency_code = auer.ledger_currency_code
          and   asp.base_currency_code <> asi.payment_currency_code
          and   auer.checkrun_id = p_checkrun_id)  --Bug 5123855
    where checkrun_id = p_checkrun_id
    and (invoice_id, payment_num) in
         (select invoice_id, payment_num
          from ap_selected_invoices_all asi2,
               ap_system_parameters_all asp2
          where asp2.org_id = asi2.org_id
          and   asp2.base_currency_code <> asi2.payment_currency_code
          and   asi2.checkrun_id = p_checkrun_id);

  else
  --update for all other exchange rate types

    update ap_selected_invoices asi
    set (payment_exchange_rate_type, payment_exchange_rate) =
         (select l_batch_exchange_rate_type,
                 ap_utilities_pkg.get_exchange_rate(
                         asi.payment_currency_code,
                         asp.base_currency_code,
                         l_batch_exchange_rate_type,
                         l_check_date,
                         'AUTOSELECT')
          from ap_system_parameters_all asp
          where asp.org_id = asi.org_id
          and asp.base_currency_code <> asi.payment_currency_code)
    where checkrun_id = p_checkrun_id
    and (invoice_id, payment_num) in
         (select invoice_id, payment_num
          from ap_selected_invoices_all asi2,
               ap_system_parameters_all asp2
          where asp2.org_id = asi2.org_id
          and   asp2.base_currency_code <> asi2.payment_currency_code
          and   asi2.checkrun_id = p_checkrun_id);



  end if;

  select count(*)
  into l_missing_rates_count
  from ap_selected_invoices_all asi,
       ap_system_parameters_all asp
  where asi.org_id = asp.org_id
  and asi.checkrun_id = p_checkrun_id
  and asi.payment_currency_code <> asp.base_currency_code
  and asi.payment_exchange_rate is null
  and ((l_batch_exchange_rate_type <> 'User'
       and asp.make_rate_mandatory_flag = 'Y') OR
       l_batch_exchange_rate_type = 'User')
  and rownum = 1;



  if l_missing_rates_count > 0 then

    update ap_inv_selection_criteria_all
    set status = 'MISSING RATES'
    where checkrun_id = p_checkrun_id;

    if l_batch_exchange_rate_type = 'User' then
      insert into ap_user_exchange_rates auer
       (checkrun_id,
        payment_currency_code,
        ledger_currency_code,
        creation_date,  --Bug 5123855
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
       (select p_checkrun_id,
               asi.payment_currency_code,
               asp.base_currency_code,
               SYSDATE,
               FND_GLOBAL.user_id,
               SYSDATE,
               FND_GLOBAL.user_id,
               FND_GLOBAL.login_id
        from ap_selected_invoices_all asi,
             ap_system_parameters_all asp
        where asi.payment_exchange_rate is null
        and asp.org_id = asi.org_id
        and asp.base_currency_code <> asi.payment_currency_code
        and asi.checkrun_id = p_checkrun_id
        and not exists (select 'row already in auer'
                        from ap_user_exchange_rates auer2
                        where auer2.checkrun_id = asi.checkrun_id
                        and   auer2.payment_currency_code = asi.payment_currency_code
                        and   auer2.ledger_currency_code = asp.base_currency_code));

    end if;
  end if;
*/




  --5007587
  declare

  l_init_msg_list varchar2(2000);
  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(2000);
  l_msg_index_out number;

  begin

    FV_FEDERAL_PAYMENT_FIELDS_PKG.SUBMIT_CASH_POS_REPORT(
      p_init_msg_list => l_init_msg_list,
      p_org_id        => null,
      p_checkrun_id   => p_checkrun_id,
      x_request_id    => l_req_id,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      IF l_msg_count > 0 THEN
          FOR i in 1..l_msg_count LOOP
            FND_MSG_PUB.Get( p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index_out);
            FND_FILE.Put_Line(FND_FILE.Log,l_msg_data);
          End LOOP;
      end if;
    end if;
  end;
  --end 5007857






  select status
  into l_batch_status
  from ap_inv_selection_criteria_all
  where checkrun_id = p_checkrun_id;





  if p_submit_to_iby = 'Y' and l_batch_status = 'CALCULATING' then

    update ap_inv_selection_criteria_all
    set status = 'SELECTED'
    where checkrun_id = p_checkrun_id;

    SELECT lower(iso_language),iso_territory
    INTO l_iso_language,l_iso_territory
    FROM FND_LANGUAGES
    WHERE language_code = USERENV('LANG');

    -- Bug 4681857

    --Bug 6969710
    SELECT nvl(template_code, 'APINVSEL' )
          INTO l_template_code
          FROM Fnd_Concurrent_Programs
          WHERE concurrent_program_name = 'APINVSEL';  --Bug 6969710

    l_xml_output:=  fnd_request.add_layout(
                        template_appl_name  => 'SQLAP',
                        template_code       => l_template_code , --Bug 6969710
                        template_language   => l_iso_language,
                        template_territory  => l_iso_territory,
                        output_format       => 'PDF'
                            );

   --below code added for bug#7435751 as we need to set the current nls character setting
   fnd_profile.get('ICX_NUMERIC_CHARACTERS',l_icx_numeric_characters);
   l_return_status:= FND_REQUEST.SET_OPTIONS( numeric_characters => l_icx_numeric_characters);

    --submit the selected payment schedules report
    l_req_id := FND_REQUEST.SUBMIT_REQUEST(
                  'SQLAP',
                  'APINVSEL',
                  '',
                  '',
                  FALSE,
                  to_char(p_checkrun_id),
                  chr(0));

    l_req_id := FND_REQUEST.SUBMIT_REQUEST(
                  'IBY',
                  'IBYBUILD',
                  '',
                  '',
                  FALSE,
                  '200',
                  l_checkrun_name,
                  to_char(l_bank_account_id),
                  to_char(l_payment_profile_id),
                  l_zero_invoices_allowed, -- Bug 6523501,
                  to_char(l_max_payment_amount),
                  to_char(l_min_check_amount),
                  l_doc_rejection_level_code,
                  l_pay_rejection_level_code,
                  l_pay_review_settings_flag,
                  l_create_instrs_flag,
                  l_payment_document_id,
                  /*bug 7519277*/
                                  l_ATTRIBUTE_CATEGORY,
                                  l_ATTRIBUTE1,
                                  l_ATTRIBUTE2,
                                  l_ATTRIBUTE3,
                                  l_ATTRIBUTE4,
                                  l_ATTRIBUTE5,
                                  l_ATTRIBUTE6,
                                  l_ATTRIBUTE7,
                                  l_ATTRIBUTE8,
                                  l_ATTRIBUTE9,
                                  l_ATTRIBUTE10,
                                  l_ATTRIBUTE11,
                                  l_ATTRIBUTE12,
                                  l_ATTRIBUTE13,
                                  l_ATTRIBUTE14,
                                  l_ATTRIBUTE15,
                                /*bug 7519277*/
                  chr(0));
  --4676790
  elsif p_submit_to_iby = 'N' and l_batch_status = 'CALCULATING' then

    update ap_inv_selection_criteria_all
    set status = 'REVIEW'
    where checkrun_id = p_checkrun_id;

  end if;

  commit;


exception
    WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_checkrun_id: '||
                                           to_char(p_checkrun_id));

    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;



END recalculate;



PROCEDURE cancel_batch (errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_checkrun_id      in         varchar2) is

l_debug_info varchar2(2000);
l_current_calling_sequence varchar2(2000);
l_checkrun_name ap_inv_selection_criteria_all.checkrun_name%type;-- bug# 6643035
l_psr_id number;
l_return_status varchar2(1);

begin

  l_current_calling_sequence := 'ap_autoselect_pkg.cancel_batch';

  select checkrun_name
  into l_checkrun_name
  from ap_inv_selection_criteria_all
  where checkrun_id = p_checkrun_id;


  begin

    select PAYMENT_SERVICE_REQUEST_ID
    into l_psr_id
    from iby_pay_service_requests
    where calling_app_id = 200
    and CALL_APP_PAY_SERVICE_REQ_CODE = l_checkrun_name;
  exception
    when no_data_found then null;
  end;

  if l_psr_id is not null then

    IBY_DISBURSE_UI_API_PUB_PKG.terminate_pmt_request (
      l_psr_id,
      'TERMINATED',
      l_return_status);

  else

    update ap_inv_selection_criteria_all
    set status = 'CANCELING'
    where checkrun_id = p_checkrun_id;

    commit;


    l_debug_info := 'delete unselected invoices';

    delete from ap_unselected_invoices_all
    where checkrun_id = p_checkrun_id;

    l_debug_info := 'undo awt';

    AP_WITHHOLDING_PKG.AP_WITHHOLD_CANCEL(l_checkrun_name,
                     FND_GLOBAL.USER_ID,
                     FND_GLOBAL.LOGIN_ID,     -- Bug 5478602
                     FND_GLOBAL.PROG_APPL_ID,
                     FND_GLOBAL.CONC_PROGRAM_ID,
                     FND_GLOBAL.CONC_REQUEST_ID,
                     p_checkrun_id,
                     null,
                     null);


    l_debug_info := 'delete selected invoices';

    delete from ap_selected_invoices_all
    where checkrun_id = p_checkrun_id;


    l_debug_info := 'update payment schedules';

    update ap_payment_schedules_all
    set checkrun_id = null
    where checkrun_id = p_checkrun_id;

    update ap_inv_selection_criteria_all
    set status = 'CANCELED' --seeded with one L
    where checkrun_id = p_checkrun_id;

  end if;


exception
    WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_checkrun_id: '||
                                           to_char(p_checkrun_id));

    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
end cancel_batch;


PROCEDURE selection_criteria_report(
                        errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_checkrun_id      in         varchar2)is

l_qryCtx                   DBMS_XMLGEN.ctxHandle;
l_result_clob              CLOB;
l_current_calling_sequence varchar2(2000);
l_debug_info               varchar2(200);

begin

  l_current_calling_sequence := 'ap_autoselect_pkg.selection_criteria_report';
  l_debug_info:= 'select from ap_inv_selection_criteria_all';

  fnd_file.put_line(fnd_file.output, '<SELECTION_CRITERIA_RPT>');

  l_qryCtx := DBMS_XMLGEN.newContext(
    'select aisc.checkrun_name, aisc.pay_from_date, aisc.pay_thru_date,
            aisc.hi_payment_priority, aisc.low_payment_priority,
            aisc.pay_only_when_due_flag, aisc.zero_amounts_allowed,
            aisc.zero_invoices_allowed, ab.batch_name,
            vndr.meaning supplier_type, hz.party_name,
            iby.payment_method_name, rate.displayed_field document_exchange_rate_type,
            apt.template_name
      from ap_inv_selection_criteria_all aisc,
           ap_batches_all ab,
           iby_payment_methods_vl iby,
           fnd_lookups vndr,
           hz_parties hz,
           ap_lookup_codes rate,
           ap_payment_templates apt
     where checkrun_id ='|| p_checkrun_id ||'
     and apt.template_id(+) = aisc.template_id
     and aisc.invoice_batch_id = ab.batch_id(+)
     and aisc.payment_method_code = iby.payment_method_code(+)
     and aisc.vendor_type_lookup_code = vndr.lookup_code(+)
     and vndr.lookup_type(+) = ''VENDOR TYPE''
     and aisc.party_id = hz.party_id(+)
     and rate.lookup_type(+) = ''INVOICE_EXCHANGE_RATE_TYPE''
     and aisc.inv_exchange_rate_type = rate.lookup_code(+)');

  DBMS_XMLGEN.setRowSetTag(l_qryCtx,'CRITERIA');
  DBMS_XMLGEN.setRowTag(l_qryCtx, 'SELECTION_CRITERIA');
  l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
  l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);
  DBMS_XMLGEN.closeContext(l_qryCtx);
  ap_utilities_pkg.clob_to_file(l_result_clob);


  l_debug_info := 'select pay group';


  l_qryCtx := DBMS_XMLGEN.newContext('SELECT vendor_pay_group '||
                                     'FROM ap_pay_group '||
                                     'WHERE checkrun_id = '||to_char(p_checkrun_id));
  DBMS_XMLGEN.setRowSetTag(l_qryCtx,'PAY');
  DBMS_XMLGEN.setRowTag(l_qryCtx, 'PAY_GROUP');
  l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
  l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);
  DBMS_XMLGEN.closeContext(l_qryCtx);
  ap_utilities_pkg.clob_to_file(l_result_clob);


  l_debug_info := 'select currency group';

  l_qryCtx := DBMS_XMLGEN.newContext('SELECT currency_code '||
                                     'FROM AP_CURRENCY_GROUP '||
                                     'WHERE checkrun_id = '||to_char(p_checkrun_id));
  DBMS_XMLGEN.setRowSetTag(l_qryCtx,'CURRENCY');
  DBMS_XMLGEN.setRowTag(l_qryCtx, 'CURRENCY_GROUP');
  l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
  l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);
  DBMS_XMLGEN.closeContext(l_qryCtx);
  ap_utilities_pkg.clob_to_file(l_result_clob);



  l_debug_info:= 'select le group';

  l_qryCtx := DBMS_XMLGEN.newContext('SELECT name legal_entity_name '||
                                     'FROM ap_le_group aleg, xle_entity_profiles xle '||
                                     'WHERE aleg.legal_entity_id = xle.legal_entity_id '||
                                     'AND checkrun_id = '||to_char(p_checkrun_id));
  DBMS_XMLGEN.setRowSetTag(l_qryCtx,'LEGAL_ENTITY');
  DBMS_XMLGEN.setRowTag(l_qryCtx, 'LE_GROUP');
  l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
  l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);
  DBMS_XMLGEN.closeContext(l_qryCtx);
  ap_utilities_pkg.clob_to_file(l_result_clob);


  l_debug_info := 'select ou group';

  l_qryCtx := DBMS_XMLGEN.newContext('SELECT name organization_name '||
                                     'FROM AP_OU_GROUP AOG, HR_OPERATING_UNITS HR '||
                                     'WHERE hr.organization_id = aog.org_id '||
                                     'AND checkrun_id = '||to_char(p_checkrun_id));
  DBMS_XMLGEN.setRowSetTag(l_qryCtx,'ORGANIZATION');
  DBMS_XMLGEN.setRowTag(l_qryCtx, 'OU_GROUP');
  l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
  l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);
  DBMS_XMLGEN.closeContext(l_qryCtx);
  ap_utilities_pkg.clob_to_file(l_result_clob);

  fnd_file.put_line(fnd_file.output, '</SELECTION_CRITERIA_RPT>');

EXCEPTION

    WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS','p_checkrun_id '||p_checkrun_id);



    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;


END selection_criteria_report;

 --Overpayment Prevention, Bug 9440897

FUNCTION get_prepay_with_tax(p_invoice_id in number)
        RETURN NUMBER IS
 	l_prepay_with_tax NUMBER;
    BEGIN
        SELECT  ((0 - SUM(NVL(ail.amount,0)))*ai.payment_cross_rate)
        INTO l_prepay_with_tax
        FROM ap_invoice_lines_all ail,ap_invoices_all ai
        WHERE ail.invoice_id = p_invoice_id
	  AND ail.invoice_id=ai.invoice_id
          AND ail.prepay_invoice_id is not null
          AND   ail.line_type_lookup_code in ('TAX', 'PREPAY')
          AND   NVL(ail.invoice_includes_prepay_flag, 'N') = 'N'
        GROUP BY ai.payment_cross_rate;
        return l_prepay_with_tax;
    END get_prepay_with_tax;

/*
   This procedure will check for invoices that would be
   overpaid by the selected invoices records created.
   If any are found it will mark the selected invoices
   ok_to_pay_flag as N and remove any related awt
   temp distributions.

   This should be called after all processing that would
   change a payment amount is complete.

   The remove_invoices procedure should be called after
   this procedure
*/
PROCEDURE mark_overpayments ( p_checkrun_id in number,
                              p_checkrun_name in varchar2,
			      p_calling_sequence in varchar2) IS

    l_debug_info                  varchar2(2000);
    l_current_calling_sequence    varchar2(2000);

    CURSOR c_invs_to_remove_with_awt IS
    select si.invoice_id
    , si.vendor_id
    , si.payment_num
    from ap_selected_invoices_all si
    , ap_awt_temp_distributions_all atd
    where si.ok_to_pay_flag = 'N'
    and dont_pay_reason_code = 'OVERPAYMENT'
    and si.invoice_id = atd.invoice_id
    and si.payment_num = atd.payment_num
    and si.checkrun_id = p_checkrun_id
    and si.checkrun_name = atd.checkrun_name;
    --May have to use checkrun name for Quick payments
    rec_invs_to_remove_with_awt   c_invs_to_remove_with_awt%ROWTYPE;

BEGIN

l_current_calling_sequence := p_calling_sequence || '<-mark_overpayments ';
l_debug_info := 'Inside mark overpayments';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line(FND_FILE.LOG,l_debug_info);
  END IF;

    update ap_selected_invoices_all si
    set ok_to_pay_flag = 'N',
    dont_pay_reason_code = 'OVERPAYMENT'
    WHERE si.checkrun_id = p_checkrun_id
    AND si.invoice_id in
       (select si2.invoice_id
       from ap_selected_invoices_all si2
       , ap_invoices_all i
       where si2.checkrun_id = p_checkrun_id
       and si2.invoice_id = i.invoice_id
       and si2.original_invoice_id is null
       group by si2.invoice_id,i.invoice_amount, decode(i.net_of_retainage_flag, 'Y', 0,
               nvl(AP_INVOICES_UTILITY_PKG.GET_RETAINED_TOTAL(si2.invoice_id, si2.org_id),0)),i.payment_cross_rate
       having abs((nvl(i.invoice_amount,0) - nvl(sum(si2.withholding_amount),0)
               - nvl(AP_INVOICES_UTILITY_PKG.get_amount_withheld(si2.invoice_id),0)
               + decode(i.net_of_retainage_flag, 'Y', 0,
		   nvl(AP_INVOICES_UTILITY_PKG.GET_RETAINED_TOTAL(si2.invoice_id, si2.org_id),0)))*i.payment_cross_rate
               /* retainage is returned as a negative */
            )
             < abs( nvl(sum(si2.discount_amount),0)  + nvl(sum(si2.payment_amount),0)
	       + nvl(get_prepay_with_tax(si2.invoice_id),0)
               /* Bug 9570635 */
               + nvl((select sum(nvl(p.amount,0)) + sum(nvl(p.discount_taken,0))
                                from ap_invoice_payments_all p
                                where p.invoice_id = si2.invoice_id),0)));

/*
  undo awt for invoices to be removed, this is essentially the same code as in ap_withholding_pkg
  Since this procedure is called after awt is calculated and before
  remove_invoices we have to handle temp awt undo here._
*/
    OPEN c_invs_to_remove_with_awt;

    LOOP
      l_debug_info := 'Fetch CURSOR for selected invoices marked for removal that have awt';
      FETCH c_invs_to_remove_with_awt INTO rec_invs_to_remove_with_awt;
      EXIT WHEN c_invs_to_remove_with_awt%NOTFOUND;
           DECLARE
             undo_output VARCHAR2(2000);
           BEGIN
               AP_WITHHOLDING_PKG.Ap_Undo_Temp_Withholding
                            (P_Invoice_Id             => rec_invs_to_remove_with_awt.invoice_id
                            ,P_vendor_Id              => rec_invs_to_remove_with_awt.vendor_id
                            ,P_Payment_Num            => rec_invs_to_remove_with_awt.payment_num
                            ,P_Checkrun_Name          => p_checkrun_name
                            ,P_Undo_Awt_Date          => SYSDATE
                            ,P_Calling_Module         => 'AUTOSELECT'
                            ,P_Last_Updated_By        => FND_GLOBAL.USER_ID
                            ,P_Last_Update_Login      => FND_GLOBAL.LOGIN_ID
                            ,P_Program_Application_Id => FND_GLOBAL.PROG_APPL_ID
                            ,P_Program_Id             => FND_GLOBAL.CONC_PROGRAM_ID
                            ,P_Request_Id             => FND_GLOBAL.CONC_REQUEST_ID
                            ,P_Awt_Success            => undo_output
                            ,P_checkrun_id            => p_checkrun_id );

           END;
    END LOOP;
    CLOSE c_invs_to_remove_with_awt;

EXCEPTION
    WHEN OTHERS then

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence );
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
      FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_checkrun_id: '||
                                           to_char(p_checkrun_id));
   END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;

END mark_overpayments;


END AP_AUTOSELECT_PKG;

/
