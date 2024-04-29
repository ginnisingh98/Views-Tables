--------------------------------------------------------
--  DDL for Package Body XXAH_VA_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_VA_INTERFACE_PKG" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_VA_INTERFACE_PKG.pkb 68 2015-04-29 07:56:51Z marc.smeenge@oracle.com $
 * DESCRIPTION  : Contains functionality for the Vendor Allowance Integration
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 5-NOV-2010  Joost Voordouw    Initial
 * 24-NOV-2010 Joost Voordouw    Updated gc_order_type_acc / gc_order_type_inv
 *
 * 7-DEC-2010  Joost Voordouw    Taxcode null 'G' to 'NA'
 * 7-DEC-2010  Joost Voordouw    mcr.attribute1/2/3/4 updated
 * 7-DEC-2010  Joost Voordouw    gc_order_type_inv / gc_order_type_acc updated
 * 2-JANUARI-2011 Joost Voordouw Tax updated
 * 28-MAART-2011 Joost Voordouw  r_line.blanket_number -- changed --> r_line.order_number  (p_product_id)
 * 15-MAR-2012 Richard Velden    Added a 2 minute delay for scheduling the concurrent request
 * 18-Apr-2014  Vema Reddy       Added columns abt Department name,Contract year based on RFC-AES005
 * 12-Dec-2014 Marc Smeenge      New units and tax functionality
 * 18-May-2016 Vema Reddy        Added Volume,Price and Chartfield2 based n RFC EBS001.
 * 04-Jul-2016 Vema Reddy        Commented Note1 in invoices and added upload reference.
 * 14-09-2016  Sunil Thamke      Added  New Calendar Name as per the 445 calendar project.
 * 20-02-2018  Menaka Kumar(TCS  EBS002        Added EOF variable declaration)
 * 17-05-2-22  Karthick B(TCS)	 RFCC19-455-Bill to location info in export file

 *************************************************************************/

  -- ----------------------------------------------------------------------
  -- Private types
  -- ----------------------------------------------------------------------

  -- ----------------------------------------------------------------------
  -- Private constants
  -- ----------------------------------------------------------------------
  gc_package_name              CONSTANT VARCHAR2(30) := 'XXAH_VA_INTERFACE_PKG';
  gc_interface_dir             CONSTANT VARCHAR2(100) := fnd_profile.value('XXAH_VA_INTERFACE_DIR');
  gc_ftp_server                CONSTANT VARCHAR2(100) := fnd_profile.value('XXAH_VA_FTP_SERVER');
  gc_ftp_user                  CONSTANT VARCHAR2(100) := fnd_profile.value('XXAH_VA_FTP_USER');
  gc_ftp_password              CONSTANT VARCHAR2(100) := fnd_profile.value('XXAH_VA_FTP_PASSWORD');
  va_period_name                CONSTANT VARCHAR2(100):=fnd_profile.value('XXAH_VA_PERIOD_NAME');
  va_old_period_name           CONSTANT VARCHAR2(100):=fnd_profile.value('XXAH_VA_OLD_PERIOD_NAME');
  v_sysdate       CONSTANT date:=to_date(fnd_profile.value('XXAH_PERIOD_DATE'),'DD-MM-YYYY');
  -- existing invoice types:
  gc_order_type_inv            CONSTANT VARCHAR2(30) := 'INVOICE';
  -- existing accrual types:
  gc_order_type_acc            CONSTANT VARCHAR2(30) := 'ACCRUAL';
  gc_file_extention            CONSTANT VARCHAR2(3)  := 'dat';
  gc_file_extention_ok         CONSTANT VARCHAR2(2)  := 'ok';
  -- this BTW code is used to indicate that no BTW code should be included
  gc_tax_null_code             CONSTANT VARCHAR2(2)  := 'NA';
  g_intfc_line_num NUMBER := 0;
  --
  TYPE v_id_lookup IS TABLE OF fnd_lookup_values.meaning%TYPE INDEX BY fnd_lookup_values.lookup_code%TYPE;
  --
  v_lookup v_id_lookup;
  -- ----------------------------------------------------------------------
  -- Private variables
  -- ----------------------------------------------------------------------
  g_iface_filename         VARCHAR2(100);
  g_iface_filename_ok      VARCHAR2(100);
  g_interface_filename     VARCHAR2(100);
  -- ----------------------------------------------------------------------
  -- Private exceptions
  -- ----------------------------------------------------------------------
  e_invalid_data EXCEPTION;
  e_no_data_found EXCEPTION;
  --
  CURSOR c_inv_and_acc_lines
  ( b_header_id oe_order_headers_all.header_id%TYPE)
  IS
  SELECT o.blanket_number                                 blanket_number
  ,      o.order_number                                   order_number
  ,      hoi.org_information19                            business_unit
  ,      hoi.org_information20                            journal_id
  ,      (CASE WHEN o.ordered_date > sysdate then to_char(sysdate,'MMDDYYYY')
              ELSE TO_CHAR(o.ordered_date, 'MMDDYYYY')
              END)              journal_date
  ,      substr(acs.orig_system_reference,1,9)            bill_to_cust_id
  ,      o.transactional_curr_code                        bi_currency_cd
  ,      l.unit_selling_price_per_pqty                    unit_amt
  ,      DECODE(l.line_category_code, 'RETURN'
                    , -1*l.ordered_quantity
                    , l.ordered_quantity)                 qty
  ,       l.unit_selling_price_per_pqty * l.ordered_quantity     amount
  ,       -1* l.unit_selling_price_per_pqty *l.ordered_quantity  amount_negative
  ,      cur.precision                                           cur_precision
  ,      TO_CHAR(SYSDATE, 'DD-MM-YYYY')                          converted_sysdate
  ,      l.tax_code                                              tax_code
  ,      l.attribute3                                            cost_center
  ,      l.attribute4                                            open_item
  ,      l.attribute5                                            bill_type
  ,      substr(l.attribute7,1,10)                               chartfield3
  ,      substr(l.attribute8,1,60)                               Upload_Reference
  ,      l.attribute9                                            Volume
  ,      replace(l.attribute10 ,',','.')                         Price
  ,      substr(l.attribute11,1,10)                              chartfield2
  ,(select fu.user_name from fnd_user fu
where fu.user_id=decode(o.last_updated_by,0,o.created_by,o.last_updated_by)) User_Name
  ,      /*ltrim(substr(i.description,1,1),'#')||substr(i.description,2)||
         '-'||*/
         --l.attribute2||'|'||l.attribute6      description
         decode(l.attribute6,'',l.attribute2,decode(l.attribute2,'',l.attribute6,l.attribute2||'|'||l.attribute6)) description
  ,      (SELECT entered_period_name
          FROM  gl_periods_v
          WHERE user_period_type =va_period_name
          AND   o.ordered_date BETWEEN start_date AND end_date)  accrual_description
  ,      o.blanket_number                      ||'|'||  -- contract ID (max 15, in de praktijk 8)
         TO_CHAR(o.ordered_date, 'YYYY')       ||'|'||  -- year
         hoi.org_information19                 ||'|'||  -- department (Engels: Unit) (maximum allowed length: 7)
         l.line_id                             ||'|'||  -- max 15, in de praktijk 8
         l.blanket_line_number
                         journal_line_description  -- max 30
  ,      'H' hdr_or_line_note
  ,      mcr.attribute_category              attribute_category  -- this will always be 'Vendor Allowance' -- 7/12/2010 JV
  ,      mcr.attribute1                      gener_acct_acc -- 7/12/2010 JV
  ,      mcr.attribute2                      benef_acct_acc -- 7/12/2010 JV
  ,      mcr.attribute3                      gener_acct_inv -- 7/12/2010 JV
  ,      mcr.attribute4                      benef_acct_inv -- 7/12/2010 JV
  ,      TO_CHAR(o.ordered_date, 'YYYY')     year
  ,      ordered_date                        ordered_date
  ,    (select PERIOD_YEAR
            from gl_periods_v pv
            ,oe_blanket_lines_ext oble
         where oble.start_date_active  BETWEEN pv.start_date AND pv.end_date
         and pv.user_period_type = decode(greatest(oble.start_date_active,v_sysdate),v_sysdate,va_old_period_name,va_period_name)
         and oble.order_number=o.blanket_number
               AND l.blanket_line_number=oble.line_number) Contract_Year
  ,      (SELECT haou.attribute1
          FROM   oe_blanket_lines_ext oble
          ,      jtf_rs_salesreps rs
          ,      per_all_assignments_f paaf
          ,      hr_all_organization_units  haou
          WHERE oble.order_number=o.blanket_number
          AND l.blanket_line_number=oble.line_number
          AND rs.salesrep_id=o.salesrep_id
          AND HAOU.ORGANIZATION_ID=paaf.ORGANIZATION_ID
          AND paaf.person_id=rs.person_id
          AND oble.start_date_active BETWEEN paaf.effective_start_date AND paaf.effective_end_date) department_name
  ,      mcr.cross_reference                 beneficiary         -- (product / opco - beneficiary)
  ,      rbs.name                            order_type_name  -- 7/12/2010 JV
  FROM   oe_order_headers_all       o
  ,      hz_cust_site_uses_all      site -- uses of customer addresses
  ,      HZ_CUST_ACCT_SITES_ALL     acs  -- customer addresses
  ,      oe_order_lines_all         l
  ,      hr_all_organization_units  u
  ,      hz_cust_accounts           c    -- customer accounts
  ,      mtl_system_items_tl        i
  ,      mtl_system_items_b         b
  ,      hr_organization_information  hoi
  ,      mtl_cross_references_v     mcr
  ,      mtl_categories             mc
  ,      mtl_item_categories        mic
  ,      mtl_category_sets          mcs
  ,      ra_batch_sources_all       rbs
  ,      oe_transaction_types_all   tta
  ,      gl_currencies              cur
  WHERE  o.header_id             = b_header_id
  AND    o.header_id             = l.header_id
  AND    l.org_id                = u.organization_id
  AND    l.org_id                = hoi.organization_id
  AND    l.inventory_item_id     = i.inventory_item_id
  AND    l.inventory_item_id     = b.inventory_item_id
  AND    i.organization_id       = b.organization_id
  AND    i.organization_id       = l.ship_from_org_id
  AND    mic.organization_id     = i.organization_id
  AND    o.invoice_to_org_id        = site.site_use_id    -- or o.ship_to_org_id
  AND    site.cust_acct_site_id  = acs.cust_acct_site_id
  AND    acs.cust_account_id     = c.cust_account_id
  AND    i.language              = 'US'
  AND    hoi.org_information_context = 'Operating Unit Information'
  AND    hoi.org_information19   = mcr.cross_reference_type
  AND    l.inventory_item_id     = mcr.inventory_item_id
  AND    mcs.CATEGORY_SET_NAME   = 'BENEFICIARY'
  AND    mcs.CATEGORY_SET_ID     = mic.CATEGORY_SET_ID
  AND    mic.INVENTORY_ITEM_ID   = i.INVENTORY_ITEM_ID
  AND    mc.CATEGORY_ID          = mic.CATEGORY_ID
  and    tta.transaction_type_id (+) = o.order_type_id
  and    tta.invoice_source_id    = rbs.batch_source_id
  AND    tta.org_id = rbs.org_id
  AND    o.transactional_curr_code = cur.currency_code
  AND    cur.enabled_flag        = 'Y'
  ORDER BY l.line_number
           , beneficiary
           , year
  ;

  PROCEDURE log
  ( p_message IN VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    fnd_file.put_line
    ( fnd_file.log
    , to_char(systimestamp, 'HH24:MI:SS.FF2 ') || p_message
    );

    fnd_log.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT, MODULE => gc_package_name, MESSAGE =>  p_message );
  END log;
  --
  FUNCTION Get_account(p_lookup_code IN fnd_lookup_values.lookup_code%TYPE)
    RETURN fnd_lookup_values.meaning%TYPE IS
    TYPE charTab IS TABLE OF fnd_lookup_values.meaning%TYPE;
    v_code    charTab;
    v_meaning charTab;
    v_type CONSTANT fnd_lookup_values.lookup_type%TYPE := 'XXAH_OPCO_MAPPING';
  BEGIN
    IF v_lookup.COUNT = 0 THEN
      SELECT flv.lookup_code, flv.meaning BULK COLLECT
        INTO v_code, v_meaning
        FROM fnd_lookup_values flv
       WHERE flv.lookup_type = v_type
         AND flv.LANGUAGE = userenv('LANG')
         AND flv.view_application_id = 665
         AND flv.security_group_id = 0
         AND flv.enabled_flag = 'Y'
         AND sysdate BETWEEN nvl(flv.start_date_active,sysdate-1)
                         AND nvl(flv.end_date_active,sysdate+1);
      FOR i IN v_code.FIRST .. v_code.LAST LOOP
        v_lookup(v_code(i)) := v_meaning(i);
      END LOOP;
      v_code.DELETE;
      v_meaning.DELETE;
    END IF;
    RETURN v_lookup(p_lookup_code);
  EXCEPTION
    WHEN others THEN
      RETURN p_lookup_code;
  END Get_account;
  --
  PROCEDURE out_line ( p_message IN VARCHAR2 DEFAULT NULL
             , p_filename IN VARCHAR2)
  IS
  BEGIN


    fnd_file.put_line
    ( fnd_file.OUTPUT
    , p_message);


  EXCEPTION
  WHEN OTHERS THEN
    log('******************** ERROR IN THE FTP INTERFACE: **************************');
    log('SQLERRM: '||SQLERRM);
    raise_application_error(-20101, 'Error in the FTP interface. SQLCODE: '||SQLCODE || '   SQLERRM: '||SQLERRM);
  END out_line;

  PROCEDURE out_line ( p_message IN VARCHAR2 DEFAULT NULL)
  IS
  BEGIN





    out_line( p_message  => p_message
      , p_filename => gc_interface_dir||'/'||g_interface_filename
      );






  END out_line;

  -- check if order type is invoice
  FUNCTION is_invoice
  ( p_order_type_name    IN oe_transaction_types_tl.name%TYPE
  ) RETURN BOOLEAN
  IS BEGIN
    -- 7/12/2010 JV
    RETURN p_order_type_name LIKE '%'||gc_order_type_inv||'%';
  END is_invoice;

  -- check if order type is accrual
  FUNCTION is_accrual
  ( p_order_type_name    IN oe_transaction_types_tl.name%TYPE
  ) RETURN BOOLEAN
  IS BEGIN
    -- 7/12/2010 JV
    RETURN p_order_type_name LIKE '%'||gc_order_type_acc||'%';
  END is_accrual;

   -- convert to format that AccountingPlaza can accept.
  FUNCTION amount_to_char
  ( p_amount   IN NUMBER
    , p_precision IN NUMBER
  ) RETURN VARCHAR
  IS
    l_amount VARCHAR(128);
  BEGIN
    l_amount := trim(to_char(p_amount, '999999990d'|| lpad('0', p_precision, '0')
                    , 'NLS_NUMERIC_CHARACTERS=.,'));
    RETURN l_amount;
  END amount_to_char;


  FUNCTION get_invoice_line
  ( p_interface_seq_num  IN VARCHAR2 DEFAULT NULL
  , p_intfc_line_num     IN VARCHAR2 DEFAULT NULL
  , p_trans_type_bi      IN VARCHAR2 DEFAULT NULL
  , p_trans_type_bi_seq  IN VARCHAR2 DEFAULT NULL
  , p_acct_entry_type    IN VARCHAR2 DEFAULT NULL
  , p_business_unit      IN VARCHAR2 DEFAULT NULL
  , p_bill_to_cust_id    IN VARCHAR2 DEFAULT NULL
  , p_address_seq_num    IN VARCHAR2 DEFAULT NULL
  , p_bill_type_id       IN VARCHAR2 DEFAULT NULL
  , p_bill_by_id         IN VARCHAR2 DEFAULT NULL
  , p_pymnt_terms_cd     IN VARCHAR2 DEFAULT NULL
  , p_bi_currency_cd     IN VARCHAR2 DEFAULT NULL
  , p_invoice_dt         IN VARCHAR2 DEFAULT NULL
  , p_line_type          IN VARCHAR2 DEFAULT NULL
  , p_unit_of_measure    IN VARCHAR2 DEFAULT NULL
  , p_qty                IN NUMBER DEFAULT NULL
  , p_unit_amt           IN NUMBER DEFAULT NULL
  , p_tax_cd             IN VARCHAR2 DEFAULT NULL
  , p_gross_extended_amt IN NUMBER DEFAULT NULL
  , p_account            IN VARCHAR2 DEFAULT NULL
  , p_deptid             IN VARCHAR2 DEFAULT NULL
  , p_product            IN VARCHAR2 DEFAULT NULL
  , p_amount             IN VARCHAR2 DEFAULT NULL
  , p_po_ref             IN VARCHAR2 DEFAULT NULL
  , p_hdr_or_line_note   IN VARCHAR2 DEFAULT NULL
  , p_text254            IN VARCHAR2 DEFAULT NULL
  , p_product_id         IN VARCHAR2 DEFAULT NULL
  , p_order_no           IN VARCHAR2 DEFAULT NULL
  , p_precision          IN NUMBER
  , p_chartfield2        IN VARCHAR2 DEFAULT NULL
  , p_chartfield3        IN VARCHAR2 DEFAULT NULL
  , p_chartfield4        IN VARCHAR2 DEFAULT NULL
  , p_upload_reference    IN VARCHAR2 DEFAULT NULL
  )
  RETURN VARCHAR2 IS

    l_gross_extended_amt_conv      VARCHAR(128) := amount_to_char(p_gross_extended_amt, p_precision);
    l_qty_conv                     VARCHAR(128) := amount_to_char(p_qty, p_precision);
    l_unit_amt_conv                VARCHAR(128) := amount_to_char(p_unit_amt, p_precision);
    l_amount_conv                  VARCHAR(128) := amount_to_char(p_amount, p_precision);
    v_open_item VARCHAR2(35);
    v_po_ref VARCHAR2(100);
    v_line_desc VARCHAR2(100);
  BEGIN
    IF p_product_id = 'XXAH##' THEN
      v_open_item := NULL;
    ELSE
      IF p_product_id IS NOT NULL THEN
        v_open_item := rpad(nvl(p_product_id,' '),30) || rpad(' ', 5);
      ELSE
        v_open_item := rpad(nvl(p_product_id,' '),10)        || -- PRODUCT_ID 606
                       rpad(nvl(p_order_no,' '),10)          || -- ORDER_NO 616
                       rpad(' ', 15);
      END IF;
    END IF;
    IF p_trans_type_bi = 'LINE' THEN
      v_po_ref := p_po_ref;
      v_line_desc := NULL;
    ELSE
      v_po_ref := NULL;
      v_line_desc := p_po_ref;
    END IF;

  RETURN
     rpad(nvl('1',' '),8)  || -- INTFC_ID, always 1 for new version of peoplesoft.
     rpad(nvl(p_intfc_line_num,' '),8)     || -- INTFC_LINE_NUM 9
     rpad(nvl(p_trans_type_bi,' '),4)      || -- TRANS_TYPE_BI 17
     rpad(nvl(p_trans_type_bi_seq,' '),3)  || -- TRANS_TYPE_BI_SEQ 21
     rpad(nvl(p_acct_entry_type,' '),3)    || -- ACCT_ENTRY_TYPE 24
     rpad(' ', 5)                          || -- ENTRY_TYPE 27
     rpad(' ', 5)                          || -- ENTRY_REASON 32
     rpad(nvl(p_business_unit,' '),5)      || -- BUSINESS_UNIT 37
     rpad(nvl(p_bill_to_cust_id,' '),15)   || -- BILL_TO_CUST_ID 42
     rpad(nvl(p_address_seq_num,' '),3)    || -- ADDRESS_SEQ_NUM 57
     rpad(' ', 10)                         || -- BILL_SOURCE_ID 60
     rpad(nvl(p_bill_type_id,' '),3)       || -- BILL_TYPE_ID 70
     rpad(' ', 10)                         || -- BILL_CYCLE_ID 73
     rpad(nvl(p_bill_by_id,' '),10)        || -- BILL_BY_ID 83
     rpad(' ', 3)                          || -- PAYMENT_METHOD 93
     rpad(nvl(p_pymnt_terms_cd,' '),5)     || -- PYMNT_TERMS_CD 96
     rpad(nvl(p_bi_currency_cd,' '),3)     || -- BI_CURRENCY_CD 101
     rpad(' ', 3)                          || -- BASE_CURRENCY 104
     rpad(nvl(p_invoice_dt,' '),10)        || -- INVOICE_DT 107
     rpad(' ', 22)                         || -- INVOICE 117
     rpad(nvl(p_line_type,' '),4)          || -- LINE_TYPE 139
     rpad(nvl(p_tax_cd,' '), 18)           || -- IDENTIFIER 143
     rpad(nvl(p_unit_of_measure,' '),3)    || -- UNIT_OF_MEASURE 161
     rpad(nvl(l_qty_conv,' '),17)          || -- QTY 164
     rpad(nvl(l_unit_amt_conv,' '),17)     || -- UNIT_AMT 181
     rpad(' ',8)                           || -- TAX_CD 198
     rpad(nvl(l_gross_extended_amt_conv,' '),28) || -- GROSS_EXTENDED_AMT 206
     rpad(' ', 10)                         || -- DST_ID 234
     rpad(nvl(p_account,' '), 10)          || -- ACCOUNT 244
     rpad(' ', 8)                          || -- OPERATING_UNIT 254
     rpad(nvl(NULL,' '), 10)           || -- DEPTID empty for PS 9.1 262
     rpad(nvl(p_product,' '), 6)           || -- PRODUCT empty for PS 9.1 272
     rpad(' ', 15)                         || -- PROJECT_ID 278
     rpad(nvl(l_amount_conv,' '),28)       || -- AMOUNT 293
     rpad(nvl(v_po_ref,' '),30)            || -- PO_REF 321
     rpad(nvl(p_hdr_or_line_note,' '),1)   || -- HDR_OR_LINE_NOTE 351
     rpad(nvl(p_text254,' '),254)          || -- TEXT254 352
     rpad(nvl(v_open_item,' '),35)        || -- PRODUCT_ID 606 and order no and ship to cust id...
     rpad(' ', 3)                          || -- SHIP_TO_ADDR_NUM 641
     rpad(' ', 15)                         || -- SOLD_TO_CUST_ID 644
     rpad(' ', 3)                          || -- SOLD_TO_ADDR_NUM 659
     rpad(' ', 10)                         || -- ORDER_DATE 662
     rpad(' ', 10)                         || -- FREIGHT_TERMS 672
     rpad(' ', 10)                         || -- USER_DT1 682
     rpad(' ', 28)                         || -- USER_AMT1 692
     rpad(' ', 28)                         || -- USER_AMT2 720
     rpad(' ', 22)                         || -- TARGET_INVOICE 748
     rpad(' ', 55)                         || -- ADDRESS1 770
     rpad(' ', 55)                         || -- ADDRESS2 825
     rpad(' ', 55)                         || -- ADDRESS3 880
     rpad(' ', 55)                         || -- ADDRESS4 935
     rpad(' ', 12)                         || -- POSTAL 990
     rpad(' ', 30)                         || -- CITY 1002
     rpad(' ', 10)                         || -- CHART1 1032
     rpad(nvl(get_account(p_chartfield2),' '), 10)      || -- CHART2 1042
     rpad(nvl(p_chartfield3,' '), 10)                   || -- CHART3 1052
     rpad(nvl(v_line_desc,' '),30)                      ||  -- LINE_DESC       1082
     rpad(nvl(p_chartfield4,' '),10)                    ||  -- chartfield2     1092   -- On Salese Order Lines displaying as Chartfield2
     rpad(nvl(p_upload_reference,' '),60);              -- upload Reference     1102
  END get_invoice_line;
  /* Get AVS Invoice lines */

  FUNCTION get_avs_invoice_line
  ( p_interface_seq_num  IN VARCHAR2 DEFAULT NULL
  , p_intfc_line_num     IN VARCHAR2 DEFAULT NULL
  , p_trans_type_bi      IN VARCHAR2 DEFAULT NULL
  , p_trans_type_bi_seq  IN VARCHAR2 DEFAULT NULL
  , p_acct_entry_type    IN VARCHAR2 DEFAULT NULL
  , p_business_unit      IN VARCHAR2 DEFAULT NULL
  , p_bill_to_cust_id    IN VARCHAR2 DEFAULT NULL
  , p_address_seq_num    IN VARCHAR2 DEFAULT NULL
  , p_bill_type_id       IN VARCHAR2 DEFAULT NULL
  , p_bill_by_id         IN VARCHAR2 DEFAULT NULL
  , p_pymnt_terms_cd     IN VARCHAR2 DEFAULT NULL
  , p_bi_currency_cd     IN VARCHAR2 DEFAULT NULL
  , p_invoice_dt         IN VARCHAR2 DEFAULT NULL
  , p_line_type          IN VARCHAR2 DEFAULT NULL
  , p_unit_of_measure    IN VARCHAR2 DEFAULT NULL
  , p_qty                IN NUMBER DEFAULT NULL
  , p_unit_amt           IN NUMBER DEFAULT NULL
  , p_tax_cd             IN VARCHAR2 DEFAULT NULL
  , p_gross_extended_amt IN NUMBER DEFAULT NULL
  , p_account            IN VARCHAR2 DEFAULT NULL
  , p_deptid             IN VARCHAR2 DEFAULT NULL
  , p_product            IN VARCHAR2 DEFAULT NULL
  , p_amount             IN VARCHAR2 DEFAULT NULL
  , p_volume             IN VARCHAR2 DEFAULT NULL
  , p_price              IN VARCHAR2 DEFAULT NULL
  , p_chartfield4        IN VARCHAR2 DEFAULT NULL
  , p_upload_reference   IN VARCHAR2 DEFAULT NULL
  , p_po_ref             IN VARCHAR2 DEFAULT NULL
  , p_hdr_or_line_note   IN VARCHAR2 DEFAULT NULL
  , p_text254            IN VARCHAR2 DEFAULT NULL
  , p_product_id         IN VARCHAR2 DEFAULT NULL
  , p_order_no           IN VARCHAR2 DEFAULT NULL
  , p_precision          IN NUMBER
  , p_chartfield2        IN VARCHAR2 DEFAULT NULL
  , p_chartfield3        IN VARCHAR2 DEFAULT NULL
  )
  RETURN VARCHAR2 IS

    l_gross_extended_amt_conv      VARCHAR(128) := amount_to_char(p_gross_extended_amt, p_precision);
    l_qty_conv                     VARCHAR(128) := amount_to_char(p_qty, p_precision);
    l_unit_amt_conv                VARCHAR(128) := amount_to_char(p_unit_amt, p_precision);
    l_amount_conv                  VARCHAR(128) := amount_to_char(p_amount, p_precision);
    v_open_item VARCHAR2(35);
    v_po_ref VARCHAR2(100);
    v_line_desc VARCHAR2(100);
  BEGIN
    IF p_product_id = 'XXAH##' THEN
      v_open_item := NULL;
    ELSE
      IF p_product_id IS NOT NULL THEN
        v_open_item := rpad(nvl(p_product_id,' '),30) || rpad(' ', 5);
      ELSE
        v_open_item := rpad(nvl(p_product_id,' '),10)        || -- PRODUCT_ID 606
                       rpad(nvl(p_order_no,' '),10)          || -- ORDER_NO 616
                       rpad(' ', 15);
      END IF;
    END IF;
    IF p_trans_type_bi = 'LINE' THEN
      v_po_ref := p_po_ref;
      v_line_desc := NULL;
    ELSE
      v_po_ref := NULL;
      v_line_desc := p_po_ref;
    END IF;

  RETURN
     rpad(nvl('1',' '),8)  || -- INTFC_ID, always 1 for new version of peoplesoft.
     rpad(nvl(p_intfc_line_num,' '),8)     || -- INTFC_LINE_NUM 9
     rpad(nvl(p_trans_type_bi,' '),4)      || -- TRANS_TYPE_BI 17
     rpad(nvl(p_trans_type_bi_seq,' '),3)  || -- TRANS_TYPE_BI_SEQ 21
     rpad(nvl(p_acct_entry_type,' '),3)    || -- ACCT_ENTRY_TYPE 24
     rpad(' ', 5)                          || -- ENTRY_TYPE 27
     rpad(' ', 5)                          || -- ENTRY_REASON 32
     rpad(nvl(p_business_unit,' '),5)      || -- BUSINESS_UNIT 37
     rpad(nvl(p_bill_to_cust_id,' '),15)   || -- BILL_TO_CUST_ID 42
     rpad(nvl(p_address_seq_num,' '),3)    || -- ADDRESS_SEQ_NUM 57
     rpad(' ', 10)                         || -- BILL_SOURCE_ID 60
     rpad(nvl(p_bill_type_id,' '),3)       || -- BILL_TYPE_ID 70
     rpad(' ', 10)                         || -- BILL_CYCLE_ID 73
     rpad(nvl(p_bill_by_id,' '),10)        || -- BILL_BY_ID 83
     rpad(' ', 3)                          || -- PAYMENT_METHOD 93
     rpad(nvl(p_pymnt_terms_cd,' '),5)     || -- PYMNT_TERMS_CD 96
     rpad(nvl(p_bi_currency_cd,' '),3)     || -- BI_CURRENCY_CD 101
     rpad(' ', 3)                          || -- BASE_CURRENCY 104
     rpad(nvl(p_invoice_dt,' '),10)        || -- INVOICE_DT 107
     rpad(' ', 22)                         || -- INVOICE 117
     rpad(nvl(p_line_type,' '),4)          || -- LINE_TYPE 139
     rpad(nvl(p_tax_cd,' '), 18)           || -- IDENTIFIER 143
     rpad(nvl(p_unit_of_measure,' '),3)    || -- UNIT_OF_MEASURE 161
     rpad(nvl(l_qty_conv,' '),17)          || -- QTY 164
     rpad(nvl(l_unit_amt_conv,' '),17)     || -- UNIT_AMT 181
     rpad(' ',8)                           || -- TAX_CD 198
     rpad(nvl(l_gross_extended_amt_conv,' '),28) || -- GROSS_EXTENDED_AMT 206
     rpad(' ', 10)                         || -- DST_ID 234
     rpad(nvl(p_account,' '), 10)          || -- ACCOUNT 244
     rpad(' ', 8)                          || -- OPERATING_UNIT 254
     rpad(nvl(NULL,' '), 10)           || -- DEPTID empty for PS 9.1 262
     rpad(nvl(p_product,' '), 6)           || -- PRODUCT empty for PS 9.1 272
     rpad(' ', 15)                         || -- PROJECT_ID 278
     rpad(nvl(l_amount_conv,' '),28)       || -- AMOUNT 293
     rpad(nvl(v_po_ref,' '),30)            || -- PO_REF 321
     rpad(nvl(p_hdr_or_line_note,' '),1)   || -- HDR_OR_LINE_NOTE 351
     rpad(nvl(p_text254,' '),254)          || -- TEXT254 352
     rpad(nvl(v_open_item,' '),35)        || -- PRODUCT_ID 606 and order no and ship to cust id...
     rpad(' ', 3)                          || -- SHIP_TO_ADDR_NUM 641
     rpad(' ', 15)                         || -- SOLD_TO_CUST_ID 644
     rpad(' ', 3)                          || -- SOLD_TO_ADDR_NUM 659
     rpad(' ', 10)                         || -- ORDER_DATE 662
     rpad(' ', 10)                         || -- FREIGHT_TERMS 672
     rpad(' ', 10)                         || -- USER_DT1 682
     rpad(' ', 28)                         || -- USER_AMT1 692
     rpad(' ', 28)                         || -- USER_AMT2 720
     rpad(' ', 22)                         || -- TARGET_INVOICE 748
     rpad(' ', 55)                         || -- ADDRESS1 770
     rpad(' ', 55)                         || -- ADDRESS2 825
     rpad(' ', 55)                         || -- ADDRESS3 880
     rpad(' ', 55)                         || -- ADDRESS4 935
     rpad(' ', 12)                         || -- POSTAL 990
     rpad(' ', 30)                         || -- CITY 1002
     rpad(' ', 10)                         || -- CHART1 1032
     rpad(nvl(get_account(p_chartfield2),' '), 10)      || -- CHART2 1042
     rpad(nvl(p_chartfield3,' '), 10)                   || -- CHART3 1052
     rpad(nvl(v_line_desc,' '),30)                      ||  -- LINE_DESC  1082
     rpad(nvl(p_chartfield4,' '),10)                     ||  -- Chartfield2 1092  On Salese Order Lines displaying as Chartfield2
     rpad(nvl(p_upload_reference,' '),60)                ||  -- upload Reference  1102
     rpad(nvl(p_volume,' '),28)                          ||  -- Volume     1162
     rpad(nvl(p_price,' '),28);                              -- Price          1190

  END get_avs_invoice_line;

  /*
    * write_invoice_file
    */
  PROCEDURE write_invoice_file
  ( p_header_id          oe_order_headers_all.header_id%TYPE
  , p_interface_seq_num  NUMBER
  )
  IS
    CURSOR c_bt(b_bill_type fnd_flex_values.flex_value%TYPE) IS
    SELECT fd.past_y_n past
    FROM   fnd_flex_values_dfv fd
    ,      fnd_flex_values fv
    ,      fnd_flex_value_sets fs
    WHERE  fs.flex_value_set_name = 'XXAH_BILL_TYPE'
    AND    fs.flex_value_set_id = fv.flex_value_set_id
    AND    fv.flex_value = b_bill_type
    AND    fv.rowid = fd.row_id
    ;
    l_procedure VARCHAR2(128) := 'write_invoice_file';
    l_line VARCHAR2(4096);
    -- each combination of deptid (year) and product (beneficiary) should be unique:
    l_year VARCHAR2(4):= '0000';
    l_product mtl_cross_references_v.cross_reference%TYPE := '';
    l_suffix1 VARCHAR2(1)   := '_';
    l_suffix2 NUMBER        := 1;
    l_tax_perc  NUMBER      := 0;
    -- update JV2/1/2010
    l_tax_code_first_line VARCHAR(128);
    v_ordered_date DATE;
    v_invoice_date VARCHAR2(10);
    v_past fnd_flex_values_dfv.past_y_n%TYPE;
  BEGIN
    log(l_procedure||': BEGIN ***');
    log(l_procedure||': p_header_id: ' || p_header_id);
    ------------------------------------
    -- LOOP for each sales order line --
    ------------------------------------
    FOR r_line IN c_inv_and_acc_lines(b_header_id => p_header_id) LOOP
      /*
       * fields are fetched twice in the cursor, and not consistantly.
       */




      r_line.amount := r_line.qty*r_line.unit_amt;
      r_line.amount_negative := -1*r_line.amount;

      -- each combination of deptid (year) and product (beneficiary) should be unique:
      IF l_year = r_line.year AND l_product = r_line.beneficiary THEN
        -- same as previous row, so update l_suffix1
        l_suffix2 := l_suffix2 + 1;
      ELSE
        -- year AND product are different; reset l_suffix2; reset year and product
        l_suffix2 := 0;
        l_year := r_line.year;
        l_product := r_line.beneficiary;
      END IF;

      -- increase the line number
      g_intfc_line_num := g_intfc_line_num + 1;

      log(l_procedure||': ----- sales order line number: ' || g_intfc_line_num || ' --------------');
      log(l_procedure||': p_interface_seq_num =>' || p_interface_seq_num);
      log(l_procedure||': business_unit =>' || r_line.business_unit);
      log(l_procedure||': bill_to_cust_id =>' || r_line.bill_to_cust_id);
      log(l_procedure||': bi_currency_cd =>' || r_line.bi_currency_cd);
      log(l_procedure||': converted_sysdate =>' || r_line.converted_sysdate);
      log(l_procedure||': qty =>' || r_line.qty);
      log(l_procedure||': tax_code =>' || r_line.tax_code);
      log(l_procedure||': benef_acct_inv =>' || r_line.benef_acct_inv);
      log(l_procedure||': gener_acct_inv =>' || r_line.gener_acct_inv);
      log(l_procedure||': amount =>' || r_line.amount);
      log(l_procedure||': hdr_or_line_note =>' || r_line.hdr_or_line_note);
      log(l_procedure||': beneficiary =>' || r_line.beneficiary);
      log(l_procedure||': journal_line_description =>' || r_line.journal_line_description);
      log(l_procedure||': blanket_number =>' || r_line.blanket_number);
      log(l_procedure||': Volume =>' || r_line.volume);
      log(l_procedure||': Price =>' || r_line.price);
      log(l_procedure||': Chartfield2 =>' || r_line.chartfield2);
      log(l_procedure||': Upload_reference =>' || r_line.upload_reference);
      log(l_procedure||': User_Name =>' || r_line.user_name);

      IF r_line.business_unit           IS NULL THEN
        log('business_unit is empty');
        RAISE e_invalid_data;
      ELSIF r_line.bill_to_cust_id      IS NULL THEN
        log('bill_to_cust_id is empty');
        RAISE e_invalid_data;
      ELSIF r_line.bi_currency_cd       IS NULL THEN
        log('bi_currency_cd is empty');
        RAISE e_invalid_data;
      ELSIF r_line.converted_sysdate    IS NULL THEN
        log('converted_sysdate is empty');
        RAISE e_invalid_data;
      ELSIF r_line.qty                  IS NULL THEN
        log('qty is empty');
        RAISE e_invalid_data;
      ELSIF r_line.benef_acct_inv              IS NULL THEN
        log('benef_acct_inv is empty');
        RAISE e_invalid_data;
      ELSIF r_line.gener_acct_inv          IS NULL THEN
        log('gener_acct_inv is empty');
        RAISE e_invalid_data;
      ELSIF r_line.amount               IS NULL THEN
        log('amount is empty');
        RAISE e_invalid_data;
      ELSIF r_line.journal_line_description               IS NULL THEN
        log('journal_line_description is empty');
        RAISE e_invalid_data;
      ELSIF r_line.order_number               IS NULL THEN
        log('order_number is empty');
        RAISE e_invalid_data;
      ELSIF r_line.tax_code               IS NULL THEN
        log('Tax code is empty');
        RAISE e_invalid_data;
      END IF;

      log(l_procedure||': --- start writing invoice file ---');
      --
      -- determine invoice date
      --
      IF trunc(r_line.ordered_date) < trunc(sysdate) THEN
        OPEN c_bt(r_line.bill_type);
        FETCH c_bt INTO v_past;
        CLOSE c_bt;
        IF v_past = 'Y' THEN
          v_invoice_date := to_char(r_line.ordered_date, 'DD-MM-YYYY');
        ELSE
          v_invoice_date := r_line.converted_sysdate;
        END IF;
      ELSE
        v_invoice_date := to_char(r_line.ordered_date, 'DD-MM-YYYY');
      END IF;

      IF r_line.bill_type='AVS' THEN
        IF r_line.volume           IS NULL THEN
        log('volume is empty');
        RAISE e_invalid_data;
        ELSIF r_line.PRICE   IS NULL THEN
        log('Price is empty');
        RAISE e_invalid_data;
      END IF;
      --------------------------
      -- write LINE line      --
      --------------------------
      l_line := get_avs_invoice_line
      ( p_interface_seq_num => p_interface_seq_num
      , p_intfc_line_num    => g_intfc_line_num
      , p_trans_type_bi     => 'LINE'
      , p_trans_type_bi_seq => '1'
      , p_business_unit     => r_line.business_unit
      , p_bill_to_cust_id   => r_line.bill_to_cust_id
      , p_bill_type_id      => r_line.bill_type
      , p_bill_by_id        => r_line.user_name--'IDENTIFIER'
      , p_bi_currency_cd    => r_line.bi_currency_cd
      , p_invoice_dt        => v_invoice_date
      , p_line_type         => 'REV'
      , p_qty               => r_line.qty
      , p_unit_amt          => r_line.unit_amt
      , p_volume            => r_line.volume
      , p_price             => r_line.price
      , p_chartfield4       => r_line.chartfield2
      , p_upload_reference   => r_line.upload_reference
      -- update JV28/12/2010
      , p_tax_cd            => r_line.tax_code
      , p_gross_extended_amt=> r_line.amount
      , p_po_ref            => r_line.journal_line_description
      , p_order_no          => r_line.order_number
      , p_precision         => r_line.cur_precision
       );

      log(l_procedure||': write ''LINE'' line (see output)');
      out_line(l_line);
      ---------------------------------------
      -- write AR accounting entry line    --
      ---------------------------------------
      l_line := get_avs_invoice_line
      ( p_interface_seq_num => p_interface_seq_num
      , p_intfc_line_num    => g_intfc_line_num
      , p_trans_type_bi     => 'AE'
      , p_trans_type_bi_seq => '1'
      , p_acct_entry_type   => 'AR'
      , p_business_unit     => r_line.business_unit
      , p_account           => r_line.benef_acct_inv
      , p_deptid            => r_line.year
                   || l_suffix1
                   || to_char(l_suffix2)
      , p_product           => r_line.cost_center
      , p_po_ref            => r_line.journal_line_description
      , p_product_id        => 'XXAH##' --r_line.open_item
      , p_amount            => r_line.amount_negative
      , p_precision         => r_line.cur_precision
      , p_chartfield2       => r_line.beneficiary
      , p_chartfield4       => r_line.chartfield2
      , p_chartfield3       => r_line.chartfield3
      );
      log(l_procedure||': write AR line (see output)');
      out_line(l_line);

      -------------------------------------------------
      -- write RR accounting entry line [= RR x -1]  --
      -------------------------------------------------
      l_line := get_avs_invoice_line
      ( p_interface_seq_num => p_interface_seq_num
      , p_intfc_line_num    => g_intfc_line_num
      , p_trans_type_bi     => 'AE'
      , p_trans_type_bi_seq => '2'
      , p_acct_entry_type   => 'RR'
      , p_business_unit     => r_line.business_unit
      , p_account           => r_line.gener_acct_inv
      , p_deptid            => r_line.year
                   || l_suffix1
                   || to_char(l_suffix2)
      , p_product           => r_line.cost_center
      , p_po_ref            => r_line.journal_line_description
      , p_product_id        => r_line.open_item
      , p_amount            => r_line.amount
      , p_precision         => r_line.cur_precision
      , p_chartfield2       => r_line.beneficiary
      , p_chartfield4       => r_line.chartfield2
      , p_chartfield3       => r_line.chartfield3
      );
      log(l_procedure||': write RR line (see output)');
      out_line(l_line);


      ---------------------------------------------------------
      -- write NOTE line, only if attribute 4 has a value    --
      ---------------------------------------------------------
      IF (r_line.hdr_or_line_note = 'H') THEN
        l_line := get_avs_invoice_line
        ( p_interface_seq_num => p_interface_seq_num
        , p_intfc_line_num    => g_intfc_line_num
        , p_trans_type_bi     => 'NOTE'  -- r_line.upload_reference commented as per the request from Genpact on 04-Jul-2016.
        , p_trans_type_bi_seq => '1' --commented as per the request from Genpact on 04-Jul-2016.
        , p_business_unit     => r_line.business_unit
        , p_hdr_or_line_note  => r_line.hdr_or_line_note
        , p_text254           => r_line.description
        , p_precision         => r_line.cur_precision
        , p_upload_reference   => r_line.upload_reference
        );

        log(l_procedure||': write NOTE line (see output)');
        out_line(l_line);
      END IF;

      ELSE
      l_line := get_invoice_line
      ( p_interface_seq_num => p_interface_seq_num
      , p_intfc_line_num    => g_intfc_line_num
      , p_trans_type_bi     => 'LINE'
      , p_trans_type_bi_seq => '1'
      , p_business_unit     => r_line.business_unit
      , p_bill_to_cust_id   => r_line.bill_to_cust_id
      , p_bill_type_id      => r_line.bill_type
      , p_bill_by_id        => r_line.user_name--'IDENTIFIER'
      , p_bi_currency_cd    => r_line.bi_currency_cd
      , p_invoice_dt        => v_invoice_date
      , p_line_type         => 'REV'
      , p_qty               => r_line.qty
      , p_unit_amt          => r_line.unit_amt
      , p_chartfield4       => r_line.chartfield2
      , p_upload_reference   => r_line.upload_reference
      -- update JV28/12/2010
      , p_tax_cd            => r_line.tax_code
      , p_gross_extended_amt=> r_line.amount
      , p_po_ref            => r_line.journal_line_description
      , p_order_no          => r_line.order_number
      , p_precision         => r_line.cur_precision
       );

      log(l_procedure||': write ''LINE'' line (see output)');
      out_line(l_line);
      ---------------------------------------
      -- write AR accounting entry line    --
      ---------------------------------------
      l_line := get_invoice_line
      ( p_interface_seq_num => p_interface_seq_num
      , p_intfc_line_num    => g_intfc_line_num
      , p_trans_type_bi     => 'AE'
      , p_trans_type_bi_seq => '1'
      , p_acct_entry_type   => 'AR'
      , p_business_unit     => r_line.business_unit
      , p_account           => r_line.benef_acct_inv
      , p_deptid            => r_line.year
                   || l_suffix1
                   || to_char(l_suffix2)
      , p_product           => r_line.cost_center
      , p_po_ref            => r_line.journal_line_description
      , p_product_id        => 'XXAH##' --r_line.open_item
      , p_amount            => r_line.amount_negative
      , p_precision         => r_line.cur_precision
      , p_chartfield2       => r_line.beneficiary
      , p_chartfield4       => r_line.chartfield2
      , p_chartfield3       => r_line.chartfield3
      );
      log(l_procedure||': write AR line (see output)');
      out_line(l_line);

      -------------------------------------------------
      -- write RR accounting entry line [= RR x -1]  --
      -------------------------------------------------
      l_line := get_invoice_line
      ( p_interface_seq_num => p_interface_seq_num
      , p_intfc_line_num    => g_intfc_line_num
      , p_trans_type_bi     => 'AE'
      , p_trans_type_bi_seq => '2'
      , p_acct_entry_type   => 'RR'
      , p_business_unit     => r_line.business_unit
      , p_account           => r_line.gener_acct_inv
      , p_deptid            => r_line.year
                   || l_suffix1
                   || to_char(l_suffix2)
      , p_product           => r_line.cost_center
      , p_po_ref            => r_line.journal_line_description
      , p_product_id        => r_line.open_item
      , p_amount            => r_line.amount
      , p_precision         => r_line.cur_precision
      , p_chartfield2       => r_line.beneficiary
      , p_chartfield4       => r_line.chartfield2
      , p_chartfield3       => r_line.chartfield3
      );
      log(l_procedure||': write RR line (see output)');
      out_line(l_line);


      ---------------------------------------------------------
      -- write NOTE line, only if attribute 4 has a value    --
      ---------------------------------------------------------
      IF (r_line.hdr_or_line_note = 'H') THEN
        l_line := get_invoice_line
        ( p_interface_seq_num => p_interface_seq_num
        , p_intfc_line_num    => g_intfc_line_num
        , p_trans_type_bi     => 'NOTE'
        , p_trans_type_bi_seq => '1'
         --, p_trans_type_bi     => r_line.upload_reference--'NOTE'  commented as per the request from Genpact on 04-Jul-2016.
        --, p_trans_type_bi_seq => '1' --commented as per the request from Genpact on 04-Jul-2016.
        , p_business_unit     => r_line.business_unit
        , p_hdr_or_line_note  => r_line.hdr_or_line_note
        , p_text254           => r_line.description
        , p_precision         => r_line.cur_precision
        , p_upload_reference   => r_line.upload_reference
        );

        log(l_procedure||': write NOTE line (see output)');
        out_line(l_line);
      END IF;















      END IF;
    log(l_procedure||': -----------------------------------------------------');
    log('');
    END LOOP;

    log(l_procedure||': END ***');
  END write_invoice_file;
  /*
   *  write_accounting_file
   */
  PROCEDURE write_accounting_file
  ( p_header_id       oe_order_headers_all.header_id%TYPE
  , p_interface_seq_num  NUMBER
  ) IS
    l_line VARCHAR2(4096);
    l_header_already_printed BOOLEAN := FALSE;
    l_accrual_seq_number NUMBER := 0;
    l_procedure VARCHAR2(128) := 'write_accounting_file';
  BEGIN
    -------------------------------------------
    -- LOOP for each accrual accounting line --
    -------------------------------------------
    FOR r_line IN c_inv_and_acc_lines(b_header_id => p_header_id) LOOP
      -- increase the line number
      /*
       * fields are fetched twice in the cursor, and not consistantly.
       */
      r_line.amount := r_line.qty*r_line.unit_amt;
      r_line.amount_negative := -1*r_line.amount;
      g_intfc_line_num := g_intfc_line_num + 1;


      log('----- sales order line number: ' || g_intfc_line_num || ' --------------');
      log('p_interface_seq_num =>' || p_interface_seq_num);
      log('business_unit =>' || r_line.business_unit);
      log('journal_id =>' || r_line.journal_id);
      log('journal_date =>' || r_line.journal_date);
      log('accrual_description =>' || r_line.accrual_description);
      log('bi_currency_cd =>' || r_line.bi_currency_cd);
      log('gener_acct_acc =>' || r_line.gener_acct_acc);
      log('amount =>' || r_line.amount);
      log('journal_line_description =>' || r_line.journal_line_description);
      log('benef_acct_acc =>' || r_line.benef_acct_acc);
      log('beneficiary =>' || r_line.beneficiary);

      IF r_line.business_unit           IS NULL THEN
        log('business_unit is empty');
        RAISE e_invalid_data;
      ELSIF r_line.journal_id           IS NULL THEN
        log('journal_id is empty');
        RAISE e_invalid_data;
      ELSIF r_line.journal_date         IS NULL THEN
        log('journal_date is empty');
        RAISE e_invalid_data;
      ELSIF r_line.accrual_description  IS NULL THEN
        log('accrual_description is empty');
        RAISE e_invalid_data;
      ELSIF r_line.bi_currency_cd       IS NULL THEN
        log('bi_currency_cd is empty');
        RAISE e_invalid_data;
      ELSIF r_line.amount               IS NULL THEN
        log('amount is empty');
        RAISE e_invalid_data;
      ELSIF r_line.journal_line_description    IS NULL THEN
        log('journal_line_description is empty');
        RAISE e_invalid_data;
      ELSIF r_line.beneficiary   IS NULL THEN
        log('beneficiary is empty');
        RAISE e_invalid_data;
      ELSIF r_line.Department_name   IS NULL THEN
        log('Department Name(NFR/COGS) is empty');
        RAISE e_invalid_data;
      END IF;
      --
      ---------------------------------
      -- write JOURNAL HEADER line   --
      ---------------------------------
      -- header not printed yet?

      IF NOT l_header_already_printed THEN
        log(l_procedure||':write journal HEADER line');

        l_accrual_seq_number := XXAH.XXAH_VA_ACCRUAL_SEQ.NextVal;

        l_line := rpad('H', 1)                           || -- Record Type
            rpad(nvl(r_line.business_unit,' '),5)  || -- Business Unit 2
            'EBS'||rpad(nvl(to_char(l_accrual_seq_number),' '),7)    || -- Journal ID
            rpad(nvl(r_line.journal_date,' '),8)   || -- Journal Date
            rpad(' ', 4)                           || -- NULL (4 spaces)
            rpad('ACTUALS', 10)                    || -- Ledger Group
            rpad('N', 1)                           || -- Reversal Code
            rpad(' ', 8)                           || -- Reversal Date
            rpad(nvl(r_line.user_name,' ') ,8)              || -- Source  modified from EBS to User name based RFC
            rpad(' ', 8)                           || -- Transaction Reference number
            rpad(nvl(r_line.accrual_description,' '), 30) ||  -- Description
            rpad(nvl(r_line.bi_currency_cd,' '), 3) || -- Default Cur Code
            rpad('CRRNT', 5)                       || -- Default Cur Rate Type
            rpad(' ', 8)                           || -- Default Cur Exch Date
            rpad(' ', 16)                          || -- Default Cur Exch Rate
            rpad(' ', 8)                           || -- Doc Type
            rpad(' ', 12)                          || -- Doc Seq number
            rpad(' ', 8)                           || -- ADB_Date
            rpad(' ', 3);                             -- System Source

        out_line(l_line);
        -- now the header is printed:
        l_header_already_printed := TRUE;
      END IF;

      -----------------------------------------------
      -- write JOURNAL LINE line  -- GENERAL LINE  --
      -----------------------------------------------

          log(l_procedure||':write journal LINE line');
      l_line := rpad('L', 1)                           || -- Record Type
          rpad(nvl(r_line.business_unit,' '),5)  || -- Business Unit 2
          rpad(' ', 9)                           || -- Journal Line Number 7
          rpad('ACTUALS', 10)                    || -- Ledger 16
          rpad(nvl(r_line.gener_acct_acc,' '),10)    || -- Account 26
          rpad(' ', 10)                          || -- Alternate Account 36
          rpad(' ', 8)                           || -- Operating Unit 46
          rpad(nvl(NULL,' '),10)          || -- Department ID removed PS 9.1 54
          rpad(nvl(r_line.cost_center,' '),6)    || -- Product 64
          rpad(' ', 15)                          || -- Project ID 70
          rpad(' ', 5)                           || -- Affiliate 85
          rpad(' ', 10)                          || -- Scenario 90
          rpad(' ', 3)                           || -- Statistics Code 100
          rpad(' ', 3)                           || -- Trans Cur COde 103
          rpad(nvl(amount_to_char(r_line.amount, r_line.cur_precision),' '),27)        || -- Tr Mon Amount 106
          rpad(' ', 16)                          || -- Stat. Amount 133
          rpad(r_line.Department_name||'_'||r_line.contract_year, 10)      || -- Journal Line Ref. 149
          rpad(nvl(r_line.journal_line_description,' '),30)  || -- Journal Line Desc. 159
          rpad(' ', 5)                           || -- Foreign Rate Cur Type 189
          rpad('0', 16)                          || -- Foreign Cur Exch. Rate 194
          rpad(' ', 27)                          || -- Base Curr Amount 210
          rpad(' ', 1)                           || -- Movement Flag 237
          rpad(nvl(r_line.open_item,' '),30)     ||  -- Open Item Key 238
          rpad(' ', 10)                           || -- CHART1 268
          rpad(nvl(get_account(r_line.beneficiary),' '),10)    || -- CHART2 278
          rpad(nvl(r_line.chartfield3,' '), 10)   ||         -- CHART3 288
          rpad(nvl(r_line.Chartfield2,' '),10)             ||                      -- Chartfield2 298
          rpad(nvl(r_line.upload_reference,' '),60);                     -- upload_reference   308


      out_line(l_line);
      ---------------------------------------------------
      -- write JOURNAL LINE line  -- BENEFICIARY LINE  --
      ---------------------------------------------------
      log(l_procedure||':write journal BENEFICIARY line');
      l_line := rpad('L', 1)                           || -- Record Type
          rpad(nvl(r_line.business_unit,' '),5)  || -- Business Unit
          rpad(' ', 9)                           || -- Journal Line Number
          rpad('ACTUALS', 10)                    || -- Ledger
          rpad(nvl(r_line.benef_acct_acc,' '),10)    || -- Account
          rpad(' ', 10)                          || -- Alternate Account
          rpad(' ', 8)                           || -- Operating Unit
          rpad(nvl(NULL,' '),10)          || -- Department ID removed PS 9.1
          rpad(nvl(r_line.cost_center,' '),6)    || -- Product 64
          rpad(' ', 15)                          || -- Project ID
          rpad(' ', 5)                           || -- Affiliate
          rpad(' ', 10)                          || -- Scenario
          rpad(' ', 3)                           || -- Statistics Code
          rpad(' ', 3)                           || -- Trans Cur COde
          rpad(nvl(amount_to_char(r_line.amount_negative, r_line.cur_precision),' '),27)        || -- Tr Mon Amount
          rpad(' ', 16)                          || -- Stat. Amount
          rpad(' ', 10)                          || -- Journal Line Ref.
          rpad(nvl(r_line.journal_line_description,' '),30)  || -- Journal Line Desc.
          rpad(' ', 5)                           || -- Foreign Rate Cur Type
          rpad(' ', 16)                          || -- Foreign Cur Exch. Rate
          rpad(' ', 27)                          || -- Base Curr Amount
          rpad(' ', 1)                           || -- Movement Flag
          rpad(nvl(r_line.open_item,' '),30)     ||  -- Open Item Key 238
          rpad(' ', 10)                           || -- CHART1
          rpad(nvl(get_account(r_line.beneficiary),' '),10)    || -- CHART2
          rpad(nvl(r_line.chartfield3,' '), 10)   ||      -- CHART3 288
          rpad(nvl(r_line.Chartfield2,' '),10)             ||           -- Chartfield2  298
          rpad(nvl(r_line.upload_reference,' '),60 );                     -- upload_reference 308

      out_line(l_line);
      log('-----------------------------------------------------');
      log('');
    END LOOP;
  END write_accounting_file;

  /*
   * order booked
   * main function being called from the event subscription.
   */

  FUNCTION order_booked
  ( p_subscription_guid IN RAW
  , p_event             IN OUT NOCOPY WF_EVENT_T
  ) RETURN VARCHAR2
  IS
    CURSOR c_user(b_header_id oe_order_headers_all.header_id%TYPE) IS
    SELECT last_updated_by
    FROM   oe_order_headers_all
    WHERE  header_id = b_header_id
    ;
    CURSOR c_order(b_header_id IN xxah_booked_orders.header_id%TYPE) IS
    SELECT 1
    FROM   xxah_booked_orders
    WHERE  header_id = b_header_id
    AND    status  = 'N'
    ;
    l_procedure VARCHAR2(128) := gc_package_name||'.'||'order_booked';
    l_request_id  NUMBER;
    v_user fnd_user.user_id%TYPE;
    v_dummy VARCHAR2(1);
    v_found BOOLEAN;
  BEGIN
    log(l_procedure || ':**** BEGIN: p_event.EVENT_KEY"='||p_event.EVENT_KEY || ' ****');
    log(l_procedure || ':p_subscription_guid:'||p_subscription_guid);
    --
    OPEN c_user(to_number(p_event.EVENT_KEY));
    FETCH c_user INTO v_user;
    CLOSE c_user;
    --
    OPEN c_order(to_number(p_event.EVENT_KEY));
    FETCH c_order INTO v_dummy;
    v_found := c_order%FOUND;
    CLOSE c_order;
    IF NOT v_found THEN
      INSERT INTO xxah_booked_orders
      (header_id
      ,status
      ,request_id
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date)
      VALUES
      (to_number(p_event.EVENT_KEY)
      ,'N'
      ,NULL
      ,v_user
      ,sysdate
      ,v_user
      ,sysdate
      );
    END IF;
    log('order_booked. Inserted='||l_request_id);
    RETURN 'SUCCES';
  END order_booked;
  /*
   * order
   * Main function being called from the Standard Report Submission (Concurrent Program.)
   */

  PROCEDURE order_booked_cp
  ( errbuf          OUT VARCHAR2
  , retcode         OUT NUMBER
  , p_header_id     IN oe_order_headers_all.header_id%TYPE
  )
  IS
    -- variables
    CURSOR c_order(b_header_id IN xxah_booked_orders.header_id%TYPE) IS
    SELECT 1
    FROM   xxah_booked_orders
    WHERE  header_id = b_header_id
    AND    status IN ('N','R')
    ;
    CURSOR c_type(b_request_id xxah_booked_orders.request_id%TYPE) IS
    SELECT xbo.status, count(*)
    FROM   xxah_booked_orders xbo
    WHERE  xbo.request_id = b_request_id
    GROUP BY xbo.status
    ;
    l_procedure VARCHAR2(128) := 'order_booked_cp';
    --
    v_request_id fnd_concurrent_requests.request_id%TYPE;
    v_order_type VARCHAR2(1);
    v_dummy VARCHAR2(1);
    v_found BOOLEAN;
    BEGIN
      log('**** BEGIN:order_booked_cp ****');
      --
      IF p_header_id IS NOT NULL THEN
        OPEN c_order(p_header_id);
        FETCH c_order INTO v_dummy;
        v_found := c_order%FOUND;
        CLOSE c_order;
        IF NOT v_found THEN
          INSERT INTO xxah_booked_orders
          (header_id
          ,status
          ,request_id
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date)
          VALUES
          (p_header_id
          ,'N'
          ,NULL
          ,fnd_global.user_id
          ,sysdate
          ,fnd_global.user_id
          ,sysdate
          );
        END IF;
      END IF;
      --
      UPDATE xxah_booked_orders xbo
      SET xbo.request_id = fnd_global.conc_request_id
      WHERE ((xbo.status = 'N' AND xbo.request_id IS NULL)
        OR (xbo.status = 'R'))
      AND xbo.header_id = nvl(p_header_id,xbo.header_id)
      AND EXISTS
        (SELECT 1
         FROM oe_order_headers ooh
         WHERE ooh.header_id = xbo.header_id)
      ;
      commit;
      --
      UPDATE xxah_booked_orders xbo
      SET xbo.status = 'A'
      WHERE xbo.request_id = fnd_global.conc_request_id
      AND header_id = nvl(p_header_id,header_id)
      AND EXISTS
      (SELECT 1
       FROM   oe_order_headers ooh
       ,      Oe_Transaction_Types_All tta
       ,      ra_batch_sources_all rbs
       WHERE  xbo.header_id = ooh.header_id
       AND    ooh.order_type_id = tta.transaction_type_id
       AND    rbs.batch_source_id = tta.invoice_source_id
       AND    rbs.name LIKE '%'||gc_order_type_acc||'%')
      ;
      UPDATE xxah_booked_orders xbo
      SET xbo.status = 'I'
      WHERE xbo.request_id = fnd_global.conc_request_id
      AND header_id = nvl(p_header_id,header_id)
      AND EXISTS
      (SELECT 1
       FROM   oe_order_headers ooh
       ,      Oe_Transaction_Types_All tta
       ,      ra_batch_sources_all rbs
       WHERE  xbo.header_id = ooh.header_id
       AND    ooh.order_type_id = tta.transaction_type_id
       AND    rbs.batch_source_id = tta.invoice_source_id
       AND    rbs.name LIKE '%'||gc_order_type_inv||'%')
      ;
      --
      FOR v_type IN c_type(fnd_global.conc_request_id) LOOP
        -- Now start interface per type
        v_request_id := fnd_request.submit_request
                            (application => 'XXAH'
                            ,program     => 'XXAH_PSFT_INTERFACE'
                            ,description => 'XXAH: Peoplesoft Interface'
                            ,start_time  => NULL
                            ,sub_request => FALSE
                            ,argument1   => v_type.status
                            ,argument2   => fnd_global.conc_request_id
                            ,argument3   => chr(0)
                             );
      END LOOP;
    log('END:order_booked_cp');
  END order_booked_cp;
  --
  PROCEDURE order_xface_cp
  ( errbuf       OUT VARCHAR2
  , retcode      OUT NUMBER
  , p_type       IN VARCHAR2
  , p_request_id IN fnd_concurrent_requests.request_id%TYPE
  ) IS
    CURSOR c_order(b_request_id xxah_booked_orders.request_id%TYPE
                  ,b_org_id oe_order_headers_all.org_id%TYPE
                  ,b_status xxah_booked_orders.status%TYPE) IS
    SELECT xbo.header_id
    ,      xbo.status
    ,      ooh.order_number
    FROM   xxah_booked_orders xbo
    ,      oe_order_headers_all ooh
    WHERE  xbo.request_id = b_request_id
    AND    xbo.status = b_status
    AND    xbo.header_id = ooh.header_id
    AND    ooh.org_id = b_org_id
    FOR UPDATE OF xbo.status
    NOWAIT
    ;
    CURSOR c_add_info(b_org_id hr_organization_information.org_information19%TYPE) IS
    SELECT hoi.org_information19
    FROM   hr_organization_information  hoi
    WHERE  hoi.org_information_context = 'Operating Unit Information'
    AND    hoi.organization_id = b_org_id
    ;
    l_procedure VARCHAR2(128) := 'order_booked_cp';
    l_order_type_name            oe_transaction_types_tl.name%TYPE;

    l_interface_number           NUMBER;
    l_c_inv_and_acc_lines_rec    c_inv_and_acc_lines%ROWTYPE;
    l_interface_filename_generic VARCHAR2(100);
    l_file_1_prefix              VARCHAR2(3) := 'ps_';
    --
    l_file_2_bu                  VARCHAR(5);
    l_file_3_sup_sys             VARCHAR2(2) := 'bs';
    l_file_4_data_type           VARCHAR(1);
    l_file_5_sequence            VARCHAR(5);
    l_file_6_underscore          VARCHAR(1) := '_';
    l_file_7_date                VARCHAR2(8);
    c_data_type_invoice          CONSTANT VARCHAR2(1) := 'k';
    c_data_type_journal          CONSTANT VARCHAR2(1) := 'j';
    v_request_id fnd_concurrent_requests.request_id%TYPE;
    v_success NUMBER := 0;
    v_found BOOLEAN;
    l_eof_line   varchar2(10) :='EOF'; -- EBS002 Added EOF
  BEGIN
    g_intfc_line_num := 0;
    --
    UPDATE xxah_booked_orders xbo
    SET   request_id = fnd_global.conc_request_id
    WHERE status = p_type
    AND   request_id = p_request_id
    AND EXISTS
    (SELECT 1
     FROM oe_order_headers_all ooh
     WHERE xbo.header_id = ooh.header_id
     AND    ooh.org_id = fnd_global.org_id)
    ;
    commit;
    /*
     * determine filenames.
     */
    OPEN c_add_info(fnd_global.org_id);
    FETCH c_add_info INTO l_file_2_bu;
    v_found := c_add_info%FOUND;
    CLOSE c_add_info;
    -- initialize l_file_4_data_type
    IF p_type = 'A' THEN
      l_file_4_data_type := c_data_type_journal;
    ELSE
      l_file_4_data_type := c_data_type_invoice;
    END IF;
    --
    l_interface_number := XXAH_VA_INTERFACE_SEQ.NextVal;
    l_file_5_sequence := LTRIM(TO_CHAR(XXAH.XXAH_VA_FILE_SEQ.NextVal, '0000'));
    l_file_7_date := TO_CHAR(SYSDATE, 'YYYYMMDD');
    --
    g_interface_filename :=
      l_file_1_prefix     ||
      l_file_2_bu         ||
      l_file_3_sup_sys    ||
      l_file_4_data_type  ||
      l_file_5_sequence   ||
      l_file_6_underscore ||
      l_file_7_date
      ;
    g_iface_filename_ok := g_interface_filename || '.' || gc_file_extention_ok;
    g_iface_filename := g_interface_filename || '.' ||   gc_file_extention;
    --
    FOR v_order IN c_order(fnd_global.conc_request_id
                          ,fnd_global.org_id
                          ,p_type) LOOP
      BEGIN
        /* For either accrual or invoice sales order:
         * open file and write information.
         */
        IF p_type = 'A' THEN
          -- Type is journal -> write accounting file
          write_accounting_file
          ( p_header_id   => v_order.header_id
          , p_interface_seq_num => l_interface_number
          );
        ELSE
          -- Type is invoice -> write invoice file
          write_invoice_file
          ( p_header_id   => v_order.header_id
          , p_interface_seq_num => l_interface_number
          );
        END IF;

        -- if we have reached this position, everything went ok -->
        -- update attribute1 from oe_order_headers_all to sysdate to reflect ok status in database.
        log(l_procedure||': Update attribute1 from oe_order_headers_all to: ' || to_char( trunc(sysdate), 'YYYY/MM/DD HH24:MI:SS'));
        log(l_procedure||': Update attribute5 from oe_order_headers_all to: ' || g_iface_filename);

        UPDATE oe_order_headers_all
        SET attribute1 = to_char( sysdate, 'YYYY/MM/DD HH24:MI:SS')
          , attribute5 = g_iface_filename
        WHERE header_id = v_order.header_id;
        --
        v_success := v_success + 1;
        UPDATE xxah_booked_orders
        SET status = 'S'
        WHERE CURRENT OF c_order;
      EXCEPTION
        WHEN e_invalid_data THEN
          UPDATE xxah_booked_orders
          SET status = 'R'
          WHERE CURRENT OF c_order;
          retcode := 1;
          log('Invalid data for order '||v_order.order_number);
        WHEN e_no_data_found THEN
          UPDATE xxah_booked_orders
          SET status = 'R'
          WHERE CURRENT OF c_order;
          retcode := 1;
          log('No data found for order '||v_order.order_number);
        WHEN OTHERS THEN
          UPDATE xxah_booked_orders
          SET status = 'R'
          WHERE CURRENT OF c_order;
          log('Order '||v_order.order_number||' errored with error '||sqlerrm);
          retcode := 1;
      END;
    END LOOP;

    out_line(l_eof_line); -- EBS002 Addedd EOF EBS002

    DELETE FROM xxah_booked_orders
    WHERE status IN ('S') -- removed R, not sure why that was added in the first place...
    AND request_id = fnd_global.conc_request_id
    ;

    -- Now start the copy CP to move the output to the ftp directory

    IF v_success > 0 THEN
      v_request_id := fnd_request.submit_request
                        (application => 'XXAH'
                        ,program     => 'XXAH_COPY_OUTPUT'
                        ,description => 'XXAH: Copy Output'
                        ,start_time  => NULL
                        ,sub_request => FALSE
                        ,argument1   => fnd_global.conc_request_id
                        ,argument2   => g_iface_filename
                        ,argument3   => g_iface_filename_ok
                        ,argument4   => gc_interface_dir
                        ,argument5   => chr(0)
                         );
    END IF;

  END order_xface_cp;

END XXAH_VA_INTERFACE_PKG;

/
