--------------------------------------------------------
--  DDL for Package Body JAI_AP_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_UTILS_PKG" AS
/* $Header: jai_ap_utils.plb 120.19.12010000.6 2010/02/10 13:14:34 srjayara ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date            Remarks
------------------------------------------------------------------------------------------------------
08-Jun-2005     File Version 116.3. Object is Modified to refer to New DB Entity names in
                place of Old DB Entity Names as required for CASE COMPLAINCE.

14-Jun-2005     rchandan for bug#4428980, Version 116.4
                Modified the object to remove literals from DML statements and CURSORS.

23-Jun-2005     Brathod , File Version 112.0 , Bug# 4445989
                -  Signature for procedure get_aportion_factor is modified to use invoice_id and
                   invoice_line_number
                -  Code modified to fetch the details from ap_invoice_lines_all
                   instead of ap_invoice_distributions_all

02-Sep-2005    Ramananda for Bug#4584221, File Version 120.2
               Added the new function get_tds_invoice_batch
               In the form regime registrations (JAIREGIM.fmb) attribute_value field is a free flowing text.
               In function get_tds_invoice_batch we have considered the values to be 'YES' or 'Y' to get the batch name

               Dependency (Functional)
               ----------------------
                jai_ap_utils.pls   (120.2)
                jai_ap_tds_old.plb (120.3)
                jai_ap_tds_gen.plb (120.8)
                jai_constants.pls  (120.3)
                jaiorgdffsetup.sql (120.2)
                jaivmlu.ldt

3    07/12/2005   Hjujjuru for Bug 4870243, File version 120.5
                    Issue : Invoice Import Program is rejecting the Invoices.
                    Fix   : Commented the voucher_num insert into the ap_invoices_interface table
4    23/02/2007   bduvarag for Bug#4990941, File version 120.8
                Forward porting the changes done in 11i bug 4709459
5    04/11/2007   bduvarag for Bug#5607160, File version 120.9
                Forward porting the changes done in 11i bug#5591827
6    04/17/2007  vkaranam for Bug#5989740, File version 120.10
                Forward porting the changes done in 11i bug#5583832

7    04-Jul-2007 kukumar for bug# 5593895, File version 120.12,120.13 ( brathod changed for 120.11 )
            Projects changes are not included in this checkin and GSCC error resolved.

8    04-Jul-2007 Forward porting iSupplier changes
                 Forward porting the changes done in 11i bug#5961325  bug#3637364

9    17-DEC-2007  Jia Li for Tax inclusive computation

10   24-Jan-2008    Modifed by Jason Liu for retroactive price

11   14-APR-2008  Kevin Cheng for bug#6962018
                  change return value from 1 to ratio of AP invoice quantity to PO item quantity for
                  partially recoverable issue.
---------------------------------------------------------------------------------------------------------
*/
  GV_MODULE_PREFIX     CONSTANT VARCHAR2(30) := 'jai_ap_utils_pkg'; -- -- Added by Jia Li for tax inclusive computation on 2007/12/26

PROCEDURE create_pla_invoice(P_PLA_ID IN NUMBER,
                    P_SET_OF_BOOK_ID IN NUMBER, P_ORG_ID IN NUMBER) AS


CURSOR counter_cur(inv_id NUMBER) IS
   SELECT NVL(MAX(line_number),0) + 1 line_num
   FROM   ap_invoice_lines_interface
   WHERE  invoice_id = inv_id;

CURSOR for_accounting_date(id NUMBER) IS
   SELECT jibh.tr6_date
   FROM   JAI_CMN_RG_PLA_HDRS jibh,
          PO_VENDORS pv,
          PO_VENDOR_SITES_ALL pvs
   WHERE  jibh.PLA_ID = id
   AND    pvs.vendor_site_id (+)= jibh.vendor_site_id
   AND    pv.vendor_id = jibh.vendor_id;

CURSOR for_invoice_num IS
   SELECT 'PLA/Invoice/'||TO_CHAR(p_org_id) inv_num
   FROM   DUAL;

/* Bug 4928860. Added by Lakshmi Gopalsami
   Removed select and added cursor.
*/
CURSOR multi_org_installed is
SELECT decode(multi_org_flag, 'Y', 1,0) multi_org_cnt
  FROM fnd_product_groups;

p_rep_head_id           NUMBER;
p_currency_code         VARCHAR2(15);
cnt_rec                 NUMBER;
inv_interface_id        NUMBER;
modvat                  NUMBER;
counter_cur_rec         counter_cur%ROWTYPE;
inv_line_interface_id   NUMBER;
for_accounting_date_rec for_accounting_date%ROWTYPE;
for_invoice_num_rec     for_invoice_num%ROWTYPE;
count_orgs              NUMBER :=0 ; -- Bug 4928860
v_org_id                NUMBER;
lv_source               AP_INVOICES_INTERFACE.source%TYPE ;
lv_lookup_type_code     ap_invoices_interface.invoice_type_lookup_code%TYPE; --rchandan for bug#4428980
lv_description          ap_invoices_interface.description%type;  --rchandan for bug#4428980

/* start additions by ssumaith - bug# 4448789 */
ln_legal_entity_id      NUMBER;
lv_legal_entity_name    VARCHAR2(240);
lv_return_status        VARCHAR2(100);
ln_msg_count            NUMBER;
ln_msg_data             VARCHAR2(1000);
 /*  ends additions by ssumaith - bug# 4448789*/

/*-------------------------------------------------------------------------------------------------------------------------
FILENAME: ja_in_ins_aplah_aplal_pla_p.sql
CHANGE HISTORY:

S.No      Date          Author and Details
----------------------------------------------
1         24-oct-2002   Aparajita Das for bug # 2639278
                        Populating the siource in ap_invoices_header as "EXTERNAL" instead of "External".

-------------------------------------------------------------------------------------------------------------------------*/

BEGIN

/*  Bug 4928860. Added by Lakshmi Gopalsami
    Removed the count(distinct(org_id) from ap_invoices_all
    and added the cursor on fnd_product_groups to find out whether
    multi-org is enabled or not.
*/
OPEN multi_org_installed;
  FETCH multi_org_installed INTO count_orgs;
CLOSE multi_org_installed;

IF count_orgs = 0 THEN
   v_org_id := '' ;
ELSE
  v_org_id := p_org_id;
END IF;

Select ap_invoices_interface_s.nextval
Into   inv_interface_id
From   dual;

SELECT ap_invoice_lines_interface_s.NEXTVAL
INTO   inv_line_interface_id
FROM   DUAL;

Select currency_code
Into   p_currency_code
From   gl_sets_of_books
Where  set_of_books_id = P_SET_OF_BOOK_ID;

OPEN  for_invoice_num;
FETCH for_invoice_num INTO for_invoice_num_rec;
CLOSE for_invoice_num;

/* start additions by ssumaith - bug# 4448789 */
jai_cmn_utils_pkg.GET_LE_INFO(
P_API_VERSION            =>  NULL ,
P_INIT_MSG_LIST          =>  NULL ,
P_COMMIT                 =>  NULL ,
P_LEDGER_ID              =>  P_SET_OF_BOOK_ID,
P_BSV                    =>  NULL,
P_ORG_ID                 =>  v_ORG_ID,
X_RETURN_STATUS          =>  lv_return_status ,
X_MSG_COUNT              =>  ln_msg_count,
X_MSG_DATA               =>  ln_msg_data,
X_LEGAL_ENTITY_ID        =>  ln_legal_entity_id ,
X_LEGAL_ENTITY_NAME      =>  lv_legal_entity_name
);
 /*  ends additions by ssumaith - bug# 4448789*/

 /* Bug 5359044. Added by Lakshmi Gopalsami
  * Changed the 'EXTERNAL' TO 'INDIA - BOE/PLA INVOICES'
  */
lv_source :='INDIA - BOE/PLA INVOICES';

Insert into AP_INVOICES_INTERFACE
(
invoice_id ,
invoice_num,
invoice_date,
vendor_id,
vendor_site_id,
invoice_amount,
invoice_currency_code,
accts_pay_code_combination_id,
source,
org_id,
legal_entity_id , /*added by ssumaith - bug# 4448789 */
created_by,
creation_date,
last_updated_by,
last_update_date
)
SELECT
   inv_interface_id ,                 -- REPORT_HEADER_ID,
   for_invoice_num_rec.inv_num||'/'||jibh.PLA_ID,                          -- INVOICE_NUM,
   jibh.TR6_DATE,                   -- (Invoice Date ) WEEK_END_DATE,
   jibh.VENDOR_ID,                       -- VENDOR_ID,
   jibh.VENDOR_SITE_ID,                  -- VENDOR_SITE_ID,
   jibh.PLA_AMOUNT,                      -- TOTAL,
   p_currency_code,                      -- DEFAULT_CURRENCY_CODE,
   -- Bug 5141305. Added by Lakshmi Gopalsami
   -- Removed the reference to accts_pay_code_combination_id of po_vendors
   pvs.ACCTS_PAY_CODE_COMBINATION_ID,
   lv_source,
   v_ORG_ID,                          -- ORG_ID
   ln_legal_entity_id                  , -- LEGAL_ENTITY_ID
   jibh.CREATED_BY,                      -- CREATED_BY,
   jibh.CREATION_DATE,                   -- CREATION_DATE,
   jibh.LAST_UPDATED_BY,                 -- LAST_UPDATED_BY,
   jibh.LAST_UPDATE_DATE                -- LAST_UPDATE_DATE
FROM JAI_CMN_RG_PLA_HDRS jibh,
     PO_VENDORS pv,
     PO_VENDOR_SITES_ALL pvs
WHERE jibh.PLA_ID = P_PLA_ID
AND   pvs.vendor_site_id (+)= jibh.vendor_site_id
AND   pv.vendor_id = jibh.vendor_id
AND   NVL(pvs.org_id, 0)  =  NVL(v_org_id, 0);

SELECT  count(*)
into    cnt_rec
FROM    JAI_CMN_RG_PLA_HDRS jibh,
        JAI_CMN_INVENTORY_ORGS org
WHERE   jibh.PLA_ID = P_PLA_ID
AND     org.organization_id = jibh.organization_id
AND     org.location_id = jibh.location_id;

OPEN  counter_cur(inv_interface_id);
FETCH counter_cur INTO counter_cur_rec;
CLOSE counter_cur;

OPEN  for_accounting_date(p_pla_id);
FETCH for_accounting_date INTO for_accounting_date_rec;
CLOSE for_accounting_date;

if cnt_rec = 0 then
      lv_lookup_type_code := 'ITEM';     --rchandan for bug#4428980
      lv_description := 'Line for Invoice no ' || P_PLA_ID; --rchandan for bug#4428980
      INSERT INTO ap_invoice_lines_interface
      (
      invoice_id,
      invoice_line_id,
      line_number,
      line_type_lookup_code,
      amount,
      accounting_date,
      description,
      dist_code_combination_id,
      org_id,
      amount_includes_tax_flag,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
      )
      SELECT
        inv_interface_id,                         -- REPORT_HEADER_ID,
        inv_line_interface_id,
        counter_cur_rec.line_num,
        lv_lookup_type_code,                                -- LINE_TYPE_LOOKUP_CODE,    --rchandan for bug#4428980
        jibh.PLA_AMOUNT,                       -- AMOUNT,
        for_accounting_date_rec.tr6_date,
        lv_description,    -- ITEM_DESCRIPTION,   --rchandan for bug#4428980
        org.MODVAT_PLA_ACCOUNT_ID,           -- ACCTS_PAY_CODE_COMBINATION_ID,
        v_ORG_ID,                              -- ORG_ID,
        'N',                                    -- AMOUNT_INCLUDES_TAX_FLAG,
        jibh.CREATED_BY,                       -- CREATED_BY,
        jibh.CREATION_DATE,                    -- CREATION_DATE,
        jibh.LAST_UPDATED_BY,                  -- LAST_UPDATED_BY,
        jibh.LAST_UPDATE_DATE,                 -- LAST_UPDATE_DATE,
        NULL                                  -- LAST_UPDATE_LOGIN
      FROM JAI_CMN_RG_PLA_HDRS jibh,
           JAI_CMN_INVENTORY_ORGS org
      WHERE jibh.PLA_ID = P_PLA_ID
      AND   org.organization_id = jibh.organization_id
      AND   org.location_id = 0 ;

else
     lv_lookup_type_code := 'ITEM';--rchandan for bug#4428980
      lv_description := 'Line for Invoice no ' || P_PLA_ID;--rchandan for bug#4428980
     INSERT INTO ap_invoice_lines_interface
     (
     invoice_id,
     invoice_line_id,
     line_number,
     line_type_lookup_code,
     amount,
     accounting_date,
     description,
     dist_code_combination_id,
     org_id,
     amount_includes_tax_flag,
     created_by,
     creation_date,
     last_updated_by,
     last_update_date,
     last_update_login
     )
     SELECT
          inv_interface_id,                         -- REPORT_HEADER_ID,
          inv_line_interface_id,
          counter_cur_rec.line_num,
          lv_lookup_type_code,                                -- LINE_TYPE_LOOKUP_CODE,          --rchandan for bug#4428980
          jibh.PLA_AMOUNT,                       -- AMOUNT,
          for_accounting_date_rec.tr6_date,
          lv_description,    -- ITEM_DESCRIPTION,   --rchandan for bug#4428980
          org.MODVAT_PLA_ACCOUNT_ID,           -- ACCTS_PAY_CODE_COMBINATION_ID,
          v_ORG_ID,                              -- ORG_ID,
          'N',                                    -- AMOUNT_INCLUDES_TAX_FLAG,
          jibh.CREATED_BY,                       -- CREATED_BY,
          jibh.CREATION_DATE,                    -- CREATION_DATE,
          jibh.LAST_UPDATED_BY,                  -- LAST_UPDATED_BY,
          jibh.LAST_UPDATE_DATE,                 -- LAST_UPDATE_DATE,
          NULL                                  -- LAST_UPDATE_LOGIN
     FROM JAI_CMN_RG_PLA_HDRS jibh,
          JAI_CMN_INVENTORY_ORGS org
     WHERE jibh.PLA_ID = P_PLA_ID
     AND   org.organization_id = jibh.organization_id
     AND  org.location_id = jibh.location_id;

end if;

END create_pla_invoice;

PROCEDURE create_boe_invoice
(
P_BOE_ID             IN     NUMBER,
P_SET_OF_BOOK_ID     IN     NUMBER,
P_ORG_ID             IN     NUMBER
)
IS

CURSOR counter_cur(inv_id NUMBER) IS
  SELECT NVL(MAX(line_number),0) + 1 line_num
  FROM   ap_invoice_lines_interface
  WHERE  invoice_id = inv_id;

CURSOR for_invoice_num IS
  SELECT 'BOE/Invoice/'||TO_CHAR(p_org_id)||'/'||TO_CHAR(P_BOE_ID) inv_num
  FROM   DUAL;  --Added on 21-Feb-2002

/* Bug 4928860. Added by Lakshmi Gopalsami
   Removed select and added cursor.
*/
CURSOR multi_org_installed is
SELECT decode(multi_org_flag, 'Y', 1,0) multi_org_cnt
  FROM fnd_product_groups;


inv_interface_id        NUMBER;
inv_line_interface_id   NUMBER;
p_currency_code         VARCHAR(15);
cnt_rec                 NUMBER;
counter_cur_rec         counter_cur%ROWTYPE;
for_invoice_num_rec     for_invoice_num%ROWTYPE;
count_orgs              NUMBER :=0 ; -- Bug 4928860
v_org_id                NUMBER;
lv_description                ap_invoices_interface.description%type;  -- Ravi for literal removal
lv_lookup_type_code           ap_invoices_interface.invoice_type_lookup_code%TYPE; --Ravi for literal removal
lv_source                     ap_invoices_interface.source%type; --Ravi for literal removal

/* start additions by ssumaith - bug# 4448789 */
ln_legal_entity_id      NUMBER;
lv_legal_entity_name    VARCHAR2(240);
lv_return_status        VARCHAR2(100);
ln_msg_count            NUMBER;
ln_msg_data             VARCHAR2(1000);
 /*  ends additions by ssumaith - bug# 4448789*/


BEGIN


/*------------------------------------------------------------------------------------------------------------------
FILENAME: ja_ins_aerha_aerla_p.sql
CHANGE HISTORY:

S.No      Date          Author and Details
----------------------------------------------
1         21-Feb-2002   RPK:. Version#610.1
                        for the issue of the BOE invoice nums getting stuck up in the interfaces
                        with the reason 'duplicate invoice nums'.

2         08-MAY-2002   Aparajita for bug 2361769. Version#614.1
                        voucher number field of BOE invoice was not getting populated, populated it with the
                        same value as invoice number.

3         24-oct-2002   Aparajita Das for bug # 2639278. Version#615.1
                        Populating the source in ap_invoices_header as "EXTERNAL" instead of "External".

4         22/07/2003    Vijay Shankar for bug#3049198. Version#616.1

                        Accounting date for Invoice distributions should be the IMPORT_DATE instead of bol_date.
                        GL_DATE of INVOICE should be populated with IMPORT_DATE which is not happening previously
                        Also INVOICE_DATE of the Invoice is populated with IMPORT_DATE
                        - Removed the definition of cursor for_accounting_date as it was not required.
5	10/04/2007	bduvarag for bug#5607160,File version 120.9
			Forward porting the changes done in 11i bug#5591827

6      09-JAN-2009      Bug 6503442 (FP for bug 6282935) - File version 120.19.12010000.3
                        Included logic to populate the invoice_num field in jai_cmn_boe_hdrs.
                        This fix involves the addition of new column in jai_cmn_boe_hdrs, and will
                        be a dependency for all future fixes.
-------------------------------------------------------------------------------------------------------------------*/

   /*  Bug 4928860. Added by Lakshmi Gopalsami
       Removed the count(distinct(org_id) from ap_invoices_all
       and added the cursor on fnd_product_groups to find out whether
       multi-org is enabled or not.
   */

  OPEN multi_org_installed;
    FETCH multi_org_installed INTO count_orgs;
  CLOSE multi_org_installed;

  IF count_orgs = 0 THEN
    v_org_id := '' ;
  ELSE
    v_org_id := p_org_id;
  END IF;

  SELECT ap_invoices_interface_s.NEXTVAL
  INTO   inv_interface_id
  FROM   dual;

  SELECT ap_invoice_lines_interface_s.NEXTVAL
  INTO   inv_line_interface_id
  FROM   DUAL;

  SELECT currency_code
  INTO   p_currency_code
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = p_set_of_book_id;

  OPEN  for_invoice_num;
  FETCH for_invoice_num INTO for_invoice_num_rec;
  CLOSE for_invoice_num;



  /* start additions by ssumaith - bug# 4448789 */
  jai_cmn_utils_pkg.GET_LE_INFO(
  P_API_VERSION            =>  NULL ,
  P_INIT_MSG_LIST          =>  NULL ,
  P_COMMIT                 =>  NULL ,
  P_LEDGER_ID              =>  P_SET_OF_BOOK_ID,
  P_BSV                    =>  NULL,
  P_ORG_ID                 =>  v_ORG_ID,
  X_RETURN_STATUS          =>  lv_return_status ,
  X_MSG_COUNT              =>  ln_msg_count,
  X_MSG_DATA               =>  ln_msg_data,
  X_LEGAL_ENTITY_ID        =>  ln_legal_entity_id ,
  X_LEGAL_ENTITY_NAME      =>  lv_legal_entity_name
  );
 /*  ends additions by ssumaith - bug# 4448789*/

 /* Bug 5359044. Added by Lakshmi Gopalsami
  * Changed the 'EXTERNAL' TO 'INDIA - BOE/PLA INVOICES'
  */

  lv_source := 'INDIA - BOE/PLA INVOICES';

  INSERT INTO AP_INVOICES_INTERFACE
  (
  invoice_id,
  invoice_num,
  -- voucher_num,  -- added by Aparajita on 08-may-2002 bug 2361769  Harshita for Bug 4870243
  invoice_date,
  vendor_id,
  vendor_site_id,
  invoice_amount,
  invoice_currency_code,
  accts_pay_code_combination_id,
  --set_of_books_id,
  source,
  gl_date,  -- Vijay Shankar for bug#3049198
  --accounting_date,
  org_id,
  legal_entity_id ,
  created_by,
  creation_date,
  last_updated_by,
  last_update_date
  )
  SELECT
    inv_interface_id, -- invoice_interface_header_id,
    for_invoice_num_rec.inv_num, -- invoice_num,  --added on 21-feb-2002
    -- for_invoice_num_rec.inv_num, -- added for voucher number, same as invoice number by aparajita  Harshita for Bug 4870243
    -- trunc(jibh.bol_date),
    trunc(jibh.import_date),        -- Vijay Shankar for bug#3049198
    jibh.vendor_id,
    jibh.vendor_site_id,
    round(jibh.boe_amount), -- total,/*Bug 5607160 bduvarag*/
    p_currency_code, -- default_currency_code,
    -- Bug 5141305. Added by Lakshmi Gopalsami
    -- Removed the reference to accts_pay_code_combination_id of po_vendors
    pvs.ACCTS_PAY_CODE_COMBINATION_ID,
    lv_source,
    trunc(jibh.import_date),        -- Vijay Shankar for bug#3049198
    v_org_id ,  -- org_id,
    ln_legal_entity_id , -- LEGAL_ENTITY_ID
    jibh.created_by,
    trunc(jibh.creation_date),
    jibh.last_updated_by,
    trunc(jibh.last_update_date)
  FROM
    JAI_CMN_BOE_HDRS jibh,
    po_vendors pv,
    po_vendor_sites_all pvs
  where jibh.boe_id = p_boe_id
  and   pvs.vendor_site_id (+)= jibh.vendor_site_id
  and   pv.vendor_id = jibh.vendor_id
  and   nvl(pvs.org_id, 0)  =  nvl(v_org_id, 0);

   /*bug 6503442 - FP of bug 6282935*/
     UPDATE jai_cmn_boe_hdrs
     SET invoice_num = for_invoice_num_rec.inv_num
     WHERE boe_id = p_boe_id;
   /*end bug 6503442*/

  select count(*)
  into   cnt_rec
  from   JAI_CMN_BOE_HDRS jibh,
         JAI_CMN_INVENTORY_ORGS org
  where  jibh.boe_id = p_boe_id
  and    org.organization_id = jibh.organization_id
  and    org.location_id = jibh.location_id;

  open  counter_cur(inv_interface_id);
  fetch counter_cur into counter_cur_rec;
  close counter_cur;

  IF cnt_rec = 0 THEN
    lv_lookup_type_code := 'ITEM'; --rchandan for bug#4428980
    lv_description := 'line for invoice no ' || p_boe_id;     --rchandan for bug#4428980

    insert into ap_invoice_lines_interface
    (
    invoice_id,
    invoice_line_id,
    line_number,
    line_type_lookup_code,
    amount,
    accounting_date,
    description,
    dist_code_combination_id,
    org_id,
    amount_includes_tax_flag,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
    )
    SELECT
      inv_interface_id,  -- report_header_id,
      inv_line_interface_id,
      counter_cur_rec.line_num,
      lv_lookup_type_code,  -- line_type_lookup_code,     --rchandan for bug#4428980
      round(jibh.boe_amount),  -- amount,/*Bug 5607160 bduvarag*/
      jibh.import_date, -- bug#3049198
      lv_description, -- item_description, --rchandan for bug#4428980
      org.boe_account_id,
      v_org_id,  -- org_id,
      'N' , -- amount_includes_tax_flag,
      jibh.created_by,
      trunc(jibh.creation_date),
      jibh.last_updated_by,
      jibh.last_update_date,
      null  -- last_update_login
    from  JAI_CMN_BOE_HDRS jibh,
          JAI_CMN_INVENTORY_ORGS org
    where jibh.boe_id = p_boe_id
    and   org.organization_id = jibh.organization_id
    AND   org.location_id  = 0 ;

  ELSE
     lv_lookup_type_code := 'ITEM'; --rchandan for bug#4428980
    lv_description := 'Line for Invoice no ' || P_BOE_ID;        --rchandan for bug#4428980

    insert into ap_invoice_lines_interface
    (
    invoice_id,
    invoice_line_id,
    line_number,
    line_type_lookup_code,
    amount,
    accounting_date,
    description,
    dist_code_combination_id,
    org_id,
    amount_includes_tax_flag,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
    )
    select
      inv_interface_id, -- report_header_id,
      inv_line_interface_id,
      counter_cur_rec.line_num,
      lv_lookup_type_code, -- line_type_lookup_code,       --rchandan for bug#4428980
      round(jibh.boe_amount),/*Bug 5607160 bduvarag*/
      jibh.import_date, -- bug#3049198
      lv_description, -- item_description,       --rchandan for bug#4428980
      org.boe_account_id,
      v_org_id,  -- org_id,
      'N', -- amount_includes_tax_flag,
      jibh.created_by,
      trunc(jibh.creation_date),
      jibh.last_updated_by,
      jibh.last_update_date,
      null -- last_update_login
    from
      JAI_CMN_BOE_HDRS jibh,
      JAI_CMN_INVENTORY_ORGS org
    where
      jibh.boe_id = p_boe_id
    and   org.organization_id = jibh.organization_id
    and   org.location_id  = jibh.location_id;

  end if;

END create_boe_invoice;

PROCEDURE insert_ap_inv_interface(
                p_jai_source                      IN  VARCHAR2,
                p_invoice_id OUT NOCOPY ap_invoices_interface.INVOICE_ID%TYPE,
                p_invoice_num                     IN  ap_invoices_interface.INVOICE_NUM%TYPE DEFAULT NULL,
                p_invoice_type_lookup_code        IN  ap_invoices_interface.INVOICE_TYPE_LOOKUP_CODE%TYPE DEFAULT NULL,
                p_invoice_date                    IN  ap_invoices_interface.INVOICE_DATE%TYPE DEFAULT NULL,
                p_po_number                       IN  ap_invoices_interface.PO_NUMBER%TYPE DEFAULT NULL,
                p_vendor_id                       IN  ap_invoices_interface.VENDOR_ID%TYPE DEFAULT NULL,
                p_vendor_num                      IN  ap_invoices_interface.VENDOR_NUM%TYPE DEFAULT NULL,
                p_vendor_name                     IN  ap_invoices_interface.VENDOR_NAME%TYPE DEFAULT NULL,
                p_vendor_site_id                  IN  ap_invoices_interface.VENDOR_SITE_ID%TYPE DEFAULT NULL,
                p_vendor_site_code                IN  ap_invoices_interface.VENDOR_SITE_CODE%TYPE DEFAULT NULL,
                p_invoice_amount                  IN  ap_invoices_interface.INVOICE_AMOUNT%TYPE DEFAULT NULL,
                p_invoice_currency_code           IN  ap_invoices_interface.INVOICE_CURRENCY_CODE%TYPE DEFAULT NULL,
                p_exchange_rate                   IN  ap_invoices_interface.EXCHANGE_RATE%TYPE DEFAULT NULL,
                p_exchange_rate_type              IN  ap_invoices_interface.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL,
                p_exchange_date                   IN  ap_invoices_interface.EXCHANGE_DATE%TYPE DEFAULT NULL,
                p_terms_id                        IN  ap_invoices_interface.TERMS_ID%TYPE DEFAULT NULL,
                p_terms_name                      IN  ap_invoices_interface.TERMS_NAME%TYPE DEFAULT NULL,
                p_description                     IN  ap_invoices_interface.DESCRIPTION%TYPE DEFAULT NULL,
                p_awt_group_id                    IN  ap_invoices_interface.AWT_GROUP_ID%TYPE DEFAULT NULL,
                p_awt_group_name                  IN  ap_invoices_interface.AWT_GROUP_NAME%TYPE DEFAULT NULL,
                p_last_update_date                IN  ap_invoices_interface.LAST_UPDATE_DATE%TYPE DEFAULT NULL,
                p_last_updated_by                 IN  ap_invoices_interface.LAST_UPDATED_BY%TYPE DEFAULT NULL,
                p_last_update_login               IN  ap_invoices_interface.LAST_UPDATE_LOGIN%TYPE DEFAULT NULL,
                p_creation_date                   IN  ap_invoices_interface.CREATION_DATE%TYPE DEFAULT NULL,
                p_created_by                      IN  ap_invoices_interface.CREATED_BY%TYPE DEFAULT NULL,
                --Added below the attribute category and attribute parameters for Bug #3841637
                p_attribute_category              IN  ap_invoices_interface.ATTRIBUTE_CATEGORY%TYPE DEFAULT NULL,
                p_attribute1                      IN  ap_invoices_interface.ATTRIBUTE1%TYPE DEFAULT NULL,
                p_attribute2                      IN  ap_invoices_interface.ATTRIBUTE2%TYPE DEFAULT NULL,
                p_attribute3                      IN  ap_invoices_interface.ATTRIBUTE3%TYPE DEFAULT NULL,
                p_attribute4                      IN  ap_invoices_interface.ATTRIBUTE4%TYPE DEFAULT NULL,
                p_attribute5                      IN  ap_invoices_interface.ATTRIBUTE5%TYPE DEFAULT NULL,
                p_attribute6                      IN  ap_invoices_interface.ATTRIBUTE6%TYPE DEFAULT NULL,
                p_attribute7                      IN  ap_invoices_interface.ATTRIBUTE7%TYPE DEFAULT NULL,
                p_attribute8                      IN  ap_invoices_interface.ATTRIBUTE8%TYPE DEFAULT NULL,
                p_attribute9                      IN  ap_invoices_interface.ATTRIBUTE9%TYPE DEFAULT NULL,
                p_attribute10                     IN  ap_invoices_interface.ATTRIBUTE10%TYPE DEFAULT NULL,
                p_attribute11                     IN  ap_invoices_interface.ATTRIBUTE11%TYPE DEFAULT NULL,
                p_attribute12                     IN  ap_invoices_interface.ATTRIBUTE12%TYPE DEFAULT NULL,
                p_attribute13                     IN  ap_invoices_interface.ATTRIBUTE13%TYPE DEFAULT NULL,
                p_attribute14                     IN  ap_invoices_interface.ATTRIBUTE14%TYPE DEFAULT NULL,
                p_attribute15                     IN  ap_invoices_interface.ATTRIBUTE15%TYPE DEFAULT NULL,
                p_status                          IN  ap_invoices_interface.STATUS%TYPE DEFAULT NULL,
                p_source                          IN  ap_invoices_interface.SOURCE%TYPE DEFAULT NULL,
                p_group_id                        IN  ap_invoices_interface.GROUP_ID%TYPE DEFAULT NULL,
                p_request_id                      IN  ap_invoices_interface.REQUEST_ID%TYPE DEFAULT NULL,
                p_payment_cross_rate_type         IN  ap_invoices_interface.PAYMENT_CROSS_RATE_TYPE%TYPE DEFAULT NULL,
                p_payment_cross_rate_date         IN  ap_invoices_interface.PAYMENT_CROSS_RATE_DATE%TYPE DEFAULT NULL,
                p_payment_cross_rate              IN  ap_invoices_interface.PAYMENT_CROSS_RATE%TYPE DEFAULT NULL,
                p_payment_currency_code           IN  ap_invoices_interface.PAYMENT_CURRENCY_CODE%TYPE DEFAULT NULL,
                p_workflow_flag                   IN  ap_invoices_interface.WORKFLOW_FLAG%TYPE DEFAULT NULL,
                p_doc_category_code               IN  ap_invoices_interface.DOC_CATEGORY_CODE%TYPE DEFAULT NULL,
                p_voucher_num                     IN  ap_invoices_interface.VOUCHER_NUM%TYPE DEFAULT NULL,
                p_payment_method_lookup_code      IN  ap_invoices_interface.PAYMENT_METHOD_LOOKUP_CODE%TYPE DEFAULT NULL,
                p_pay_group_lookup_code           IN  ap_invoices_interface.PAY_GROUP_LOOKUP_CODE%TYPE DEFAULT NULL,
                p_goods_received_date             IN  ap_invoices_interface.GOODS_RECEIVED_DATE%TYPE DEFAULT NULL,
                p_invoice_received_date           IN  ap_invoices_interface.INVOICE_RECEIVED_DATE%TYPE DEFAULT NULL,
                p_gl_date                         IN  ap_invoices_interface.GL_DATE%TYPE DEFAULT NULL,
                p_accts_pay_ccid                  IN  ap_invoices_interface.ACCTS_PAY_CODE_COMBINATION_ID%TYPE DEFAULT NULL,
                p_ussgl_transaction_code          IN  ap_invoices_interface.USSGL_TRANSACTION_CODE%TYPE DEFAULT NULL,
                p_exclusive_payment_flag          IN  ap_invoices_interface.EXCLUSIVE_PAYMENT_FLAG%TYPE DEFAULT NULL,
                p_org_id                          IN  ap_invoices_interface.ORG_ID%TYPE DEFAULT NULL,
                p_amount_applicable_to_dis        IN  ap_invoices_interface.AMOUNT_APPLICABLE_TO_DISCOUNT%TYPE DEFAULT NULL,
                p_prepay_num                      IN  ap_invoices_interface.PREPAY_NUM%TYPE DEFAULT NULL,
                p_prepay_dist_num                 IN  ap_invoices_interface.PREPAY_DIST_NUM%TYPE DEFAULT NULL,
                p_prepay_apply_amount             IN  ap_invoices_interface.PREPAY_APPLY_AMOUNT%TYPE DEFAULT NULL,
                p_prepay_gl_date                  IN  ap_invoices_interface.PREPAY_GL_DATE%TYPE DEFAULT NULL,
                -- Bug4240179. Added by LGOPALSA. Changed the data type
                -- for the following 4 fields.
                p_invoice_includes_prepay_flag    IN  VARCHAR2 DEFAULT NULL,
                p_no_xrate_base_amount            IN  NUMBER DEFAULT NULL,
                p_vendor_email_address            IN  VARCHAR2 DEFAULT NULL,
                p_terms_date                      IN  DATE DEFAULT NULL,
                p_requester_id                    IN  NUMBER DEFAULT NULL,
                p_ship_to_location                IN  VARCHAR2 DEFAULT NULL,
                p_external_doc_ref                IN  VARCHAR2 DEFAULT NULL,
                -- Bug 7109056. Added by Lakshmi Gopalsami
                p_payment_method_code             IN  VARCHAR2 DEFAULT NULL
               ) IS

  lv_object_name VARCHAR2(61); -- := 'jai_ap_utils_pkg.insert_ap_inv_interface'; /* Added by Ramananda for bug#4407165 */


  /* start additions by ssumaith - bug# 4448789 */
  ln_legal_entity_id      NUMBER;
  lv_legal_entity_name    VARCHAR2(240);
  lv_return_status        VARCHAR2(100);
  ln_msg_count            NUMBER;
  ln_msg_data             VARCHAR2(1000);
   /*  ends additions by ssumaith - bug# 4448789*/





  BEGIN
-- #****************************************************************************************************************************************************************************************
-- #
-- # Change History -
-- # 1. 27-Jan-2005   Sanjikum for Bug #4059774 Version #115.0
-- #                  New Package created for creating AP Invoice Header and lines
-- #
-- # 2. 17-Feb-2005   Sanjikum for Bug #4183001 Version #115.1
-- #
-- #                  Issue -
-- #                  In Base version 11.5.3, 3 columns are not present in tables ap_invoices_interface and insert_ap_inv_lines_interface
-- #
-- #                  Fix -
-- #                  a) In the Definition of Procedure insert_ap_inv_interface, changed the type of 3 parameters -
-- #                     p_requester_id, p_ship_to_location, p_external_doc_ref
-- #                  b) In the Insert statement in procedure insert_ap_inv_interface, commented the insert for 3 columns -
-- #                     requester_id, ship_to_location, external_doc_ref
-- #                  c) In the Definition of Procedure insert_ap_inv_lines_interface, changed the type of 3 parameters -
-- #                     p_taxable_flag, p_price_correct_inv_num, p_external_doc_line_ref
-- #                  d) In the Insert statement in procedure insert_ap_inv_lines_interface, commented the insert for 3 columns -
-- #                     taxable_flag, price_correct_inv_num, external_doc_line_ref
-- #
-- # 3. 25-Mar-2005   Sanjikum for Bug #3841637 Version 115.4
-- #                  Added the Attribute category and 15 attributes columns
-- #
-- # Future Dependencies For the release Of this Object:-
-- # (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
-- #  A datamodel change )
--==============================================================================================================
-- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- #  Current Version       Current Bug    Dependent           Files                                  Version     Author   Date         Remarks
-- #  Of File                              On Bug/Patchset    Dependent On
-- #  jai_ap_interface_pkg_b.sql
-- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- # ****************************************************************************************************************************************************************************************

  lv_object_name := 'jai_ap_utils_pkg.insert_ap_inv_interface'; /* Added by Ramananda for bug#4407165 */


  /* start additions by ssumaith - bug# 4448789 */
  jai_cmn_utils_pkg.GET_LE_INFO(
  P_API_VERSION            =>  NULL ,
  P_INIT_MSG_LIST          =>  NULL ,
  P_COMMIT                 =>  NULL ,
  P_LEDGER_ID              =>  NULL,
  P_BSV                    =>  NULL,
  P_ORG_ID                 =>  p_org_id,
  X_RETURN_STATUS          =>  lv_return_status ,
  X_MSG_COUNT              =>  ln_msg_count,
  X_MSG_DATA               =>  ln_msg_data,
  X_LEGAL_ENTITY_ID        =>  ln_legal_entity_id ,
  X_LEGAL_ENTITY_NAME      =>  lv_legal_entity_name
  );
 /*  ends additions by ssumaith - bug# 4448789*/


    INSERT INTO ap_invoices_interface(
                INVOICE_ID,
                INVOICE_NUM,
                INVOICE_TYPE_LOOKUP_CODE,
                INVOICE_DATE,
                PO_NUMBER,
                VENDOR_ID,
                VENDOR_NUM,
                VENDOR_NAME,
                VENDOR_SITE_ID,
                VENDOR_SITE_CODE,
                INVOICE_AMOUNT,
                INVOICE_CURRENCY_CODE,
                EXCHANGE_RATE,
                EXCHANGE_RATE_TYPE,
                EXCHANGE_DATE,
                TERMS_ID,
                TERMS_NAME,
                DESCRIPTION,
                AWT_GROUP_ID,
                AWT_GROUP_NAME,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                CREATION_DATE,
                CREATED_BY,
                --Added below the attribute category and attribute columns for Bug #3841637
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
                ATTRIBUTE15,
                STATUS,
                SOURCE,
                GROUP_ID,
                REQUEST_ID,
                PAYMENT_CROSS_RATE_TYPE,
                PAYMENT_CROSS_RATE_DATE,
                PAYMENT_CROSS_RATE,
                PAYMENT_CURRENCY_CODE,
                WORKFLOW_FLAG,
                DOC_CATEGORY_CODE,
                -- VOUCHER_NUM,  Harshita for Bug 4870243
                PAYMENT_METHOD_CODE, -- Bug 7109056. added by Lakshmi gopalsami
                PAY_GROUP_LOOKUP_CODE,
                GOODS_RECEIVED_DATE,
                INVOICE_RECEIVED_DATE,
                GL_DATE,
                ACCTS_PAY_CODE_COMBINATION_ID,
                USSGL_TRANSACTION_CODE,
                EXCLUSIVE_PAYMENT_FLAG,
                ORG_ID,
                LEGAL_ENTITY_ID , /* added by ssumaith - bug# 4448789*/
                AMOUNT_APPLICABLE_TO_DISCOUNT,
                PREPAY_NUM,
                PREPAY_DIST_NUM,
                PREPAY_APPLY_AMOUNT,
                PREPAY_GL_DATE
                /* , Bug4240179. Added by LGOPALSA
                Commented the following 4 fields*/
                --INVOICE_INCLUDES_PREPAY_FLAG,
                --NO_XRATE_BASE_AMOUNT,
                --VENDOR_EMAIL_ADDRESS,
                --TERMS_DATE
                /*,
                REQUESTER_ID,
                SHIP_TO_LOCATION,
                EXTERNAL_DOC_REF*/)--commented by Sanjikum for Bug#4183001
    VALUES(
                ap_invoices_interface_s.NEXTVAL,
                p_invoice_num,
                p_invoice_type_lookup_code,
                p_invoice_date,
                p_po_number,
                p_vendor_id,
                p_vendor_num,
                p_vendor_name,
                p_vendor_site_id,
                p_vendor_site_code,
                p_invoice_amount,
                p_invoice_currency_code,
                p_exchange_rate,
                p_exchange_rate_type,
                p_exchange_date,
                p_terms_id,
                p_terms_name,
                p_description,
                p_awt_group_id,
                p_awt_group_name,
                p_last_update_date,
                p_last_updated_by,
                p_last_update_login,
                p_creation_date,
                p_created_by,
                --Added below the attribute category and attribute columns for Bug #3841637
                p_attribute_category,
                p_attribute1,
                p_attribute2,
                p_attribute3,
                p_attribute4,
                p_attribute5,
                p_attribute6,
                p_attribute7,
                p_attribute8,
                p_attribute9,
                p_attribute10,
                p_attribute11,
                p_attribute12,
                p_attribute13,
                p_attribute14,
                p_attribute15,
                p_status,
                p_source,
                p_group_id,
                p_request_id,
                p_payment_cross_rate_type,
                p_payment_cross_rate_date,
                p_payment_cross_rate,
                p_payment_currency_code,
                p_workflow_flag,
                p_doc_category_code,
                -- p_voucher_num, Harshita for Bug 4870243
                p_payment_method_code, -- Bug 7109056. Added by Lakshmi Gopalsami
                p_pay_group_lookup_code,
                p_goods_received_date,
                p_invoice_received_date,
                p_gl_date,
                p_accts_pay_ccid,
                p_ussgl_transaction_code,
                p_exclusive_payment_flag,
                p_org_id,
                ln_legal_entity_id , /* added by ssumaith - bug# 4448789*/
                p_amount_applicable_to_dis,
                p_prepay_num,
                p_prepay_dist_num,
                p_prepay_apply_amount,
                p_prepay_gl_date
                /* , Bug4240179. Added by LGOPALSA
                Commented the following 4 fields*/
                --p_invoice_includes_prepay_flag,
                --p_no_xrate_base_amount,
                --p_vendor_email_address,
                --p_terms_date
                /*,
                p_requester_id,
                p_ship_to_location,
                p_external_doc_ref*/) --commented by Sanjikum for Bug#4183001
    RETURNING invoice_id INTO p_invoice_id;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    p_invoice_id  := null;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

  END insert_ap_inv_interface;

  PROCEDURE insert_ap_inv_lines_interface(
                p_jai_source                      IN  VARCHAR2,
                p_invoice_id                      IN  ap_invoice_lines_interface.INVOICE_ID%TYPE,
                p_invoice_line_id OUT NOCOPY ap_invoice_lines_interface.INVOICE_LINE_ID%TYPE,
                p_line_number                     IN  ap_invoice_lines_interface.LINE_NUMBER%TYPE DEFAULT NULL,
                p_line_type_lookup_code           IN  ap_invoice_lines_interface.LINE_TYPE_LOOKUP_CODE%TYPE DEFAULT NULL,
                p_line_group_number               IN  ap_invoice_lines_interface.LINE_GROUP_NUMBER%TYPE DEFAULT NULL,
                p_amount                          IN  ap_invoice_lines_interface.AMOUNT%TYPE DEFAULT NULL,
                p_accounting_date                 IN  ap_invoice_lines_interface.ACCOUNTING_DATE%TYPE DEFAULT NULL,
                p_description                     IN  ap_invoice_lines_interface.DESCRIPTION%TYPE DEFAULT NULL,
                p_amount_includes_tax_flag        IN  ap_invoice_lines_interface.AMOUNT_INCLUDES_TAX_FLAG%TYPE DEFAULT NULL,
                p_prorate_across_flag             IN  ap_invoice_lines_interface.PRORATE_ACROSS_FLAG%TYPE DEFAULT NULL,
                p_tax_code                        IN  ap_invoice_lines_interface.TAX_CODE%TYPE DEFAULT NULL,
                p_final_match_flag                IN  ap_invoice_lines_interface.FINAL_MATCH_FLAG%TYPE DEFAULT NULL,
                p_po_header_id                    IN  ap_invoice_lines_interface.PO_HEADER_ID%TYPE DEFAULT NULL,
                p_po_number                       IN  ap_invoice_lines_interface.PO_NUMBER%TYPE DEFAULT NULL,
                p_po_line_id                      IN  ap_invoice_lines_interface.PO_LINE_ID%TYPE DEFAULT NULL,
                p_po_line_number                  IN  ap_invoice_lines_interface.PO_LINE_NUMBER%TYPE DEFAULT NULL,
                p_po_line_location_id             IN  ap_invoice_lines_interface.PO_LINE_LOCATION_ID%TYPE DEFAULT NULL,
                p_po_shipment_num                 IN  ap_invoice_lines_interface.PO_SHIPMENT_NUM%TYPE DEFAULT NULL,
                p_po_distribution_id              IN  ap_invoice_lines_interface.PO_DISTRIBUTION_ID%TYPE DEFAULT NULL,
                p_po_distribution_num             IN  ap_invoice_lines_interface.PO_DISTRIBUTION_NUM%TYPE DEFAULT NULL,
                p_po_unit_of_measure              IN  ap_invoice_lines_interface.PO_UNIT_OF_MEASURE%TYPE DEFAULT NULL,
                p_inventory_item_id               IN  ap_invoice_lines_interface.INVENTORY_ITEM_ID%TYPE DEFAULT NULL,
                p_item_description                IN  ap_invoice_lines_interface.ITEM_DESCRIPTION%TYPE DEFAULT NULL,
                p_quantity_invoiced               IN  ap_invoice_lines_interface.QUANTITY_INVOICED%TYPE DEFAULT NULL,
                p_ship_to_location_code           IN  ap_invoice_lines_interface.SHIP_TO_LOCATION_CODE%TYPE DEFAULT NULL,
                p_unit_price                      IN  ap_invoice_lines_interface.UNIT_PRICE%TYPE DEFAULT NULL,
                p_distribution_set_id             IN  ap_invoice_lines_interface.DISTRIBUTION_SET_ID%TYPE DEFAULT NULL,
                p_distribution_set_name           IN  ap_invoice_lines_interface.DISTRIBUTION_SET_NAME%TYPE DEFAULT NULL,
                p_dist_code_concatenated          IN  ap_invoice_lines_interface.DIST_CODE_CONCATENATED%TYPE DEFAULT NULL,
                p_dist_code_combination_id        IN  ap_invoice_lines_interface.DIST_CODE_COMBINATION_ID%TYPE DEFAULT NULL,
                p_awt_group_id                    IN  ap_invoice_lines_interface.AWT_GROUP_ID%TYPE DEFAULT NULL,
                p_awt_group_name                  IN  ap_invoice_lines_interface.AWT_GROUP_NAME%TYPE DEFAULT NULL,
                p_last_updated_by                 IN  ap_invoice_lines_interface.LAST_UPDATED_BY%TYPE DEFAULT NULL,
                p_last_update_date                IN  ap_invoice_lines_interface.LAST_UPDATE_DATE%TYPE DEFAULT NULL,
                p_last_update_login               IN  ap_invoice_lines_interface.LAST_UPDATE_LOGIN%TYPE DEFAULT NULL,
                p_created_by                      IN  ap_invoice_lines_interface.CREATED_BY%TYPE DEFAULT NULL,
                p_creation_date                   IN  ap_invoice_lines_interface.CREATION_DATE%TYPE DEFAULT NULL,
                --Added below the attribute category and attribute parameters for Bug #3841637
                p_attribute_category              IN  ap_invoices_interface.ATTRIBUTE_CATEGORY%TYPE DEFAULT NULL,
                p_attribute1                      IN  ap_invoices_interface.ATTRIBUTE1%TYPE DEFAULT NULL,
                p_attribute2                      IN  ap_invoices_interface.ATTRIBUTE2%TYPE DEFAULT NULL,
                p_attribute3                      IN  ap_invoices_interface.ATTRIBUTE3%TYPE DEFAULT NULL,
                p_attribute4                      IN  ap_invoices_interface.ATTRIBUTE4%TYPE DEFAULT NULL,
                p_attribute5                      IN  ap_invoices_interface.ATTRIBUTE5%TYPE DEFAULT NULL,
                p_attribute6                      IN  ap_invoices_interface.ATTRIBUTE6%TYPE DEFAULT NULL,
                p_attribute7                      IN  ap_invoices_interface.ATTRIBUTE7%TYPE DEFAULT NULL,
                p_attribute8                      IN  ap_invoices_interface.ATTRIBUTE8%TYPE DEFAULT NULL,
                p_attribute9                      IN  ap_invoices_interface.ATTRIBUTE9%TYPE DEFAULT NULL,
                p_attribute10                     IN  ap_invoices_interface.ATTRIBUTE10%TYPE DEFAULT NULL,
                p_attribute11                     IN  ap_invoices_interface.ATTRIBUTE11%TYPE DEFAULT NULL,
                p_attribute12                     IN  ap_invoices_interface.ATTRIBUTE12%TYPE DEFAULT NULL,
                p_attribute13                     IN  ap_invoices_interface.ATTRIBUTE13%TYPE DEFAULT NULL,
                p_attribute14                     IN  ap_invoices_interface.ATTRIBUTE14%TYPE DEFAULT NULL,
                p_attribute15                     IN  ap_invoices_interface.ATTRIBUTE15%TYPE DEFAULT NULL,
                p_po_release_id                   IN  ap_invoice_lines_interface.PO_RELEASE_ID%TYPE DEFAULT NULL,
                p_release_num                     IN  ap_invoice_lines_interface.RELEASE_NUM%TYPE DEFAULT NULL,
                p_account_segment                 IN  ap_invoice_lines_interface.ACCOUNT_SEGMENT%TYPE DEFAULT NULL,
                p_balancing_segment               IN  ap_invoice_lines_interface.BALANCING_SEGMENT%TYPE DEFAULT NULL,
                p_cost_center_segment             IN  ap_invoice_lines_interface.COST_CENTER_SEGMENT%TYPE DEFAULT NULL,
                p_project_id                      IN  ap_invoice_lines_interface.PROJECT_ID%TYPE DEFAULT NULL,
                p_task_id                         IN  ap_invoice_lines_interface.TASK_ID%TYPE DEFAULT NULL,
                p_expenditure_type                IN  ap_invoice_lines_interface.EXPENDITURE_TYPE%TYPE DEFAULT NULL,
                p_expenditure_item_date           IN  ap_invoice_lines_interface.EXPENDITURE_ITEM_DATE%TYPE DEFAULT NULL,
                p_expenditure_organization_id     IN  ap_invoice_lines_interface.EXPENDITURE_ORGANIZATION_ID%TYPE DEFAULT NULL,
                p_project_accounting_context      IN  ap_invoice_lines_interface.PROJECT_ACCOUNTING_CONTEXT%TYPE DEFAULT NULL,
                p_pa_addition_flag                IN  ap_invoice_lines_interface.PA_ADDITION_FLAG%TYPE DEFAULT NULL,
                p_pa_quantity                     IN  ap_invoice_lines_interface.PA_QUANTITY%TYPE DEFAULT NULL,
                p_ussgl_transaction_code          IN  ap_invoice_lines_interface.USSGL_TRANSACTION_CODE%TYPE DEFAULT NULL,
                p_stat_amount                     IN  ap_invoice_lines_interface.STAT_AMOUNT%TYPE DEFAULT NULL,
                p_type_1099                       IN  ap_invoice_lines_interface.TYPE_1099%TYPE DEFAULT NULL,
                p_income_tax_region               IN  ap_invoice_lines_interface.INCOME_TAX_REGION%TYPE DEFAULT NULL,
                p_assets_tracking_flag            IN  ap_invoice_lines_interface.ASSETS_TRACKING_FLAG%TYPE DEFAULT NULL,
                p_price_correction_flag           IN  ap_invoice_lines_interface.PRICE_CORRECTION_FLAG%TYPE DEFAULT NULL,
                p_org_id                          IN  ap_invoice_lines_interface.ORG_ID%TYPE DEFAULT NULL,
                p_receipt_number                  IN  ap_invoice_lines_interface.RECEIPT_NUMBER%TYPE DEFAULT NULL,
                p_receipt_line_number             IN  ap_invoice_lines_interface.RECEIPT_LINE_NUMBER%TYPE DEFAULT NULL,
                p_match_option                    IN  ap_invoice_lines_interface.MATCH_OPTION%TYPE DEFAULT NULL,
                p_packing_slip                    IN  ap_invoice_lines_interface.PACKING_SLIP%TYPE DEFAULT NULL,
                p_rcv_transaction_id              IN  ap_invoice_lines_interface.RCV_TRANSACTION_ID%TYPE DEFAULT NULL,
                p_pa_cc_ar_invoice_id             IN  ap_invoice_lines_interface.PA_CC_AR_INVOICE_ID%TYPE DEFAULT NULL,
                p_pa_cc_ar_invoice_line_num       IN  ap_invoice_lines_interface.PA_CC_AR_INVOICE_LINE_NUM%TYPE DEFAULT NULL,
                p_reference_1                     IN  ap_invoice_lines_interface.REFERENCE_1%TYPE DEFAULT NULL,
                p_reference_2                     IN  ap_invoice_lines_interface.REFERENCE_2%TYPE DEFAULT NULL,
                p_pa_cc_processed_code            IN  ap_invoice_lines_interface.PA_CC_PROCESSED_CODE%TYPE DEFAULT NULL,
                p_tax_recovery_rate               IN  ap_invoice_lines_interface.TAX_RECOVERY_RATE%TYPE DEFAULT NULL,
                p_tax_recovery_override_flag      IN  ap_invoice_lines_interface.TAX_RECOVERY_OVERRIDE_FLAG%TYPE DEFAULT NULL,
                p_tax_recoverable_flag            IN  ap_invoice_lines_interface.TAX_RECOVERABLE_FLAG%TYPE DEFAULT NULL,
                p_tax_code_override_flag          IN  ap_invoice_lines_interface.TAX_CODE_OVERRIDE_FLAG%TYPE DEFAULT NULL,
                p_tax_code_id                     IN  ap_invoice_lines_interface.TAX_CODE_ID%TYPE DEFAULT NULL,
                p_credit_card_trx_id              IN  ap_invoice_lines_interface.CREDIT_CARD_TRX_ID%TYPE DEFAULT NULL,
                -- Bug 4240179. Changed data for vendor_item_num and award_id
                -- Added by LGOPALSA
                p_award_id                        IN  NUMBER DEFAULT NULL,
                p_vendor_item_num                 IN  VARCHAR2 DEFAULT NULL,
                p_taxable_flag                    IN  VARCHAR2 DEFAULT NULL,
                p_price_correct_inv_num           IN  VARCHAR2 DEFAULT NULL,
                p_external_doc_line_ref           IN  VARCHAR2 DEFAULT NULL)
  IS
lv_object_name VARCHAR2(61);
  BEGIN

    lv_object_name := 'jai_ap_utils_pkg.insert_ap_inv_lines_interface'; /* Added by Ramananda for bug#4407165 */

    INSERT INTO ap_invoice_lines_interface(
                INVOICE_ID,
                INVOICE_LINE_ID,
                LINE_NUMBER,
                LINE_TYPE_LOOKUP_CODE,
                LINE_GROUP_NUMBER,
                AMOUNT,
                ACCOUNTING_DATE,
                DESCRIPTION,
                AMOUNT_INCLUDES_TAX_FLAG,
                PRORATE_ACROSS_FLAG,
                TAX_CODE,
                FINAL_MATCH_FLAG,
                PO_HEADER_ID,
                PO_NUMBER,
                PO_LINE_ID,
                PO_LINE_NUMBER,
                PO_LINE_LOCATION_ID,
                PO_SHIPMENT_NUM,
                PO_DISTRIBUTION_ID,
                PO_DISTRIBUTION_NUM,
                PO_UNIT_OF_MEASURE,
                INVENTORY_ITEM_ID,
                ITEM_DESCRIPTION,
                QUANTITY_INVOICED,
                SHIP_TO_LOCATION_CODE,
                UNIT_PRICE,
                DISTRIBUTION_SET_ID,
                DISTRIBUTION_SET_NAME,
                DIST_CODE_CONCATENATED,
                DIST_CODE_COMBINATION_ID,
                AWT_GROUP_ID,
                AWT_GROUP_NAME,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
                CREATED_BY,
                CREATION_DATE,
                --Added below the attribute category and attribute columns for Bug #3841637
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
                ATTRIBUTE15,
                PO_RELEASE_ID,
                RELEASE_NUM,
                ACCOUNT_SEGMENT,
                BALANCING_SEGMENT,
                COST_CENTER_SEGMENT,
                PROJECT_ID,
                TASK_ID,
                EXPENDITURE_TYPE,
                EXPENDITURE_ITEM_DATE,
                EXPENDITURE_ORGANIZATION_ID,
                PROJECT_ACCOUNTING_CONTEXT,
                PA_ADDITION_FLAG,
                PA_QUANTITY,
                USSGL_TRANSACTION_CODE,
                STAT_AMOUNT,
                TYPE_1099,
                INCOME_TAX_REGION,
                ASSETS_TRACKING_FLAG,
                PRICE_CORRECTION_FLAG,
                ORG_ID,
                RECEIPT_NUMBER,
                RECEIPT_LINE_NUMBER,
                MATCH_OPTION,
                PACKING_SLIP,
                RCV_TRANSACTION_ID,
                PA_CC_AR_INVOICE_ID,
                PA_CC_AR_INVOICE_LINE_NUM,
                REFERENCE_1,
                REFERENCE_2,
                PA_CC_PROCESSED_CODE,
                TAX_RECOVERY_RATE,
                TAX_RECOVERY_OVERRIDE_FLAG,
                TAX_RECOVERABLE_FLAG,
                TAX_CODE_OVERRIDE_FLAG,
                TAX_CODE_ID,
                CREDIT_CARD_TRX_ID
                --, Bug 4240179. Commented by LGOPALSA
                -- AWARD_ID,
                -- VENDOR_ITEM_NUM
                /*,
                TAXABLE_FLAG,
                PRICE_CORRECT_INV_NUM,
                EXTERNAL_DOC_LINE_REF*/)--commented by Sanjikum for Bug#4183001
  VALUES(
                p_invoice_id,
                ap_invoice_lines_interface_s.NEXTVAL,
                p_line_number,
                p_line_type_lookup_code,
                p_line_group_number,
                p_amount,
                p_accounting_date,
                p_description,
                p_amount_includes_tax_flag,
                p_prorate_across_flag,
                p_tax_code,
                p_final_match_flag,
                p_po_header_id,
                p_po_number,
                p_po_line_id,
                p_po_line_number,
                p_po_line_location_id,
                p_po_shipment_num,
                p_po_distribution_id,
                p_po_distribution_num,
                p_po_unit_of_measure,
                p_inventory_item_id,
                p_item_description,
                p_quantity_invoiced,
                p_ship_to_location_code,
                p_unit_price,
                p_distribution_set_id,
                p_distribution_set_name,
                p_dist_code_concatenated,
                p_dist_code_combination_id,
                p_awt_group_id,
                p_awt_group_name,
                p_last_updated_by,
                p_last_update_date,
                p_last_update_login,
                p_created_by,
                p_creation_date,
                --Added below the attribute category and attribute columns for Bug #3841637
                p_attribute_category,
                p_attribute1,
                p_attribute2,
                p_attribute3,
                p_attribute4,
                p_attribute5,
                p_attribute6,
                p_attribute7,
                p_attribute8,
                p_attribute9,
                p_attribute10,
                p_attribute11,
                p_attribute12,
                p_attribute13,
                p_attribute14,
                p_attribute15,
                p_po_release_id,
                p_release_num,
                p_account_segment,
                p_balancing_segment,
                p_cost_center_segment,
                p_project_id,
                p_task_id,
                p_expenditure_type,
                p_expenditure_item_date,
                p_expenditure_organization_id,
                p_project_accounting_context,
                p_pa_addition_flag,
                p_pa_quantity,
                p_ussgl_transaction_code,
                p_stat_amount,
                p_type_1099,
                p_income_tax_region,
                p_assets_tracking_flag,
                p_price_correction_flag,
                p_org_id,
                p_receipt_number,
                p_receipt_line_number,
                p_match_option,
                p_packing_slip,
                p_rcv_transaction_id,
                p_pa_cc_ar_invoice_id,
                p_pa_cc_ar_invoice_line_num,
                p_reference_1,
                p_reference_2,
                p_pa_cc_processed_code,
                p_tax_recovery_rate,
                p_tax_recovery_override_flag,
                p_tax_recoverable_flag,
                p_tax_code_override_flag,
                p_tax_code_id,
                p_credit_card_trx_id
                --, Bug 4240179. Commented by LGOPALSA
                --p_award_id,
                --p_vendor_item_num
               /*,
                p_taxable_flag,
                p_price_correct_inv_num,
                p_external_doc_line_ref*/)--commented by Sanjikum for Bug#4183001
    RETURNING invoice_line_id INTO p_invoice_line_id;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    p_invoice_line_id  := null;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

  END insert_ap_inv_lines_interface;

/* Brathod, For Bug# 4445989, get_apportion_factor signature is modified to use invoice_id and line_number*/
FUNCTION get_apportion_factor(
                             -- p_invoice_distribution_id in number
                               pn_invoice_id  AP_INVOICE_LINES_ALL.INVOICE_ID%TYPE
                             , pn_invoice_line_number AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE,
                             --added the following parameter by vkaranam for bug #5989740
                             p_factor_type varchar2 default null
                             ) return number
is
    /* Modified cursor to use ap_invoice_lines_all for Bug# 4445989 */
    cursor c_get_inv_details is
    select quantity_invoiced, unit_price, po_distribution_id, rcv_transaction_id,invoice_id
    from   ap_invoice_lines_all
    where  invoice_id = pn_invoice_id
    AND    line_number = pn_invoice_line_number;

    cursor c_get_uoms_po_receipt(p_rcv_transaction_id number) is
    select unit_of_measure receipt_uom,
           source_doc_unit_of_measure po_uom,
	   po_unit_price /*Bug 4990941 bduvarag*/
    from   rcv_transactions
    where  transaction_id = p_rcv_transaction_id;

   /* cursor c_get_po_qty_price(p_po_distribution_id number) is
    select price_override, quantity
    from   po_line_locations_all
    where  (po_header_id, po_line_id, line_location_id ) in
            (
                select  po_header_id, po_line_id, line_location_id
                from    po_distributions_all
                where   po_distribution_id = p_po_distribution_id
            ); */
    /*bug 9346307*/
    cursor c_get_po_qty_price is
    select price_override, quantity
    from   po_line_locations_all
    where  (po_header_id, po_line_id, line_location_id ) in
            (
                select  po_header_id, po_line_id, po_line_location_id
                from    ap_invoice_lines_all
                where   invoice_id = pn_invoice_id
                AND     line_number = pn_invoice_line_number
            );

    cursor c_get_receipt_qty(p_rcv_transaction_id number) is
    select qty_received
    from   JAI_RCV_LINES
    where  (shipment_header_id, shipment_line_id)
            in
            (
                select shipment_header_id, shipment_line_id
                from   rcv_transactions
                where  transaction_id = p_rcv_transaction_id
            );

    cursor c_get_uom_code(p_unit_of_measure in varchar2) is
    select uom_code
    from   mtl_units_of_measure
    where  unit_of_measure = p_unit_of_measure;

    cursor c_get_item (p_transaction_id number) is
    select item_id
    from   rcv_shipment_lines
    where  shipment_line_id = (select shipment_line_id
                               from   rcv_transactions
                               where  transaction_id = p_transaction_id);

   -- iSupplier porting
   CURSOR c_inv(inv_id NUMBER) IS
       SELECT source
       FROM   ap_invoices_all
       WHERE  invoice_id = inv_id;
   -- iSupplier porting


    v_invoice_quantity      ap_invoice_distributions_all.quantity_invoiced%type;
    v_invoice_price         ap_invoice_distributions_all.unit_price%type;
    v_invoice_id          ap_invoice_distributions_all.invoice_id%type; --iSuppleir porting
    v_source              ap_invoices_all.source%type; --iSuppleir porting

    v_po_uom                rcv_transactions.source_doc_unit_of_measure%type;
    v_receipt_price       rcv_transactions.po_unit_price%type ;   /*Bug 4990941 bduvarag*/
    v_receipt_uom           rcv_transactions.unit_of_measure%type;

    v_receipt_quantity      JAI_RCV_LINES.qty_received%type;

    v_po_price              po_line_locations_all.price_override%type;
    v_po_quantity           po_line_locations_all.quantity%type;

    v_po_distribution_id    ap_invoice_distributions_all.po_distribution_id%type;
    v_rcv_transaction_id    ap_invoice_distributions_all.rcv_transaction_id%type;

    v_uom_conv_factor       number;


    v_po_uom_code           mtl_units_of_measure.uom_code%type;
    v_receipt_uom_code      mtl_units_of_measure.uom_code%type;

    v_item_id               rcv_shipment_lines.item_id%type;

    v_statement_id          number:=0;


begin

/* -----------------------------------------------------------------------------
 FILENAME: jai_ap_utils_pkg.get_apportion_factor.sql
 CHANGE HISTORY:

 S.No      Date          Author and Details
 1         14/06/2004    Created by Aparajita for bug#3633078. Version#115.0

                         This function computes the factor by which tax on
                         Receipt or PO should be apportioned to be taken over
                         to Payable Invoice. This factor considers the changes in
                         quantity, UOM and Price.

                         Quantity can be changed at every stage like,
                         between PO and Receipt, Receipt and Invoice, and PO and
                         Invoice also.

                         UOM can be changed between PO and Receipt only.

                         Price can be changed between PO and Invoice.

                         Invoice can refer to either a Receipt / PO.

                         Only apportion not handled here is the currency of tax
                         and invoice and apportionment if required by exchange rate.
                         This is so because, that would depend on each tax and current
                         apportion factor is for all taxes attached to a line.



 Future Dependencies For the release Of this Object:-
 ==================================================
 Please add a row in the section below only if your bug introduces a dependency
 like,spec change/ A new call to a object/A datamodel change.

 --------------------------------------------------------------------------------
 Version       Bug       Dependencies (including other objects like files if any)
 --------------------------------------------------------------------------------


--------------------------------------------------------------------------------- */
    -- Added by Jason Liu for retroactive price on 2008/01/24
    ----------------------------------------------------------------------
    OPEN c_inv(pn_invoice_id);
    FETCH c_inv INTO v_source;
    CLOSE c_inv;

    --Comment out by Kevin Cheng for bug#6962018 Apr 14, 2008
    /*IF(v_source = 'PPA')
    THEN
      RETURN 1;
    END IF; --(v_source = 'PPA') */
    ----------------------------------------------------------------------

    v_statement_id := 1;
    open c_get_inv_details;
    fetch c_get_inv_details into
        v_invoice_quantity, v_invoice_price, v_po_distribution_id, v_rcv_transaction_id, v_invoice_id;
    close c_get_inv_details;

    v_statement_id := 2;
    open c_get_po_qty_price;  /*bug 9346307*/
    fetch c_get_po_qty_price into v_po_price, v_po_quantity;
    close c_get_po_qty_price;

    v_statement_id := 3;

    if v_rcv_transaction_id is not null then

        v_statement_id := 4;
        open c_get_uoms_po_receipt(v_rcv_transaction_id);
        fetch c_get_uoms_po_receipt into v_receipt_uom, v_po_uom,v_receipt_price;/*bug 4990941 bduvarag*/
        close c_get_uoms_po_receipt;

        open c_get_receipt_qty(v_rcv_transaction_id);
        fetch c_get_receipt_qty into v_receipt_quantity;
        close c_get_receipt_qty;

        if v_receipt_uom = v_po_uom then
            v_statement_id := 5;
            v_uom_conv_factor := 1;
        else
            v_statement_id := 6;
            open c_get_uom_code(v_receipt_uom);
            fetch c_get_uom_code into v_receipt_uom_code;
            close c_get_uom_code;

            open c_get_uom_code(v_po_uom);
            fetch c_get_uom_code into v_po_uom_code;
            close c_get_uom_code;

            open c_get_item(v_rcv_transaction_id);
            fetch c_get_item into  v_item_id;
            close c_get_item;

            v_statement_id := 7;
            Inv_Convert.Inv_Um_Conversion
            (
            v_receipt_uom_code,
            v_po_uom_code,
            v_item_id,
            v_uom_conv_factor
            );

            if nvl(v_uom_conv_factor, 0) <= 0 then
                v_uom_conv_factor := 1;
            end if;


        end if;-- v_receipt_uom = v_po_uom t

    end if;-- v_rcv_transaction_id is not null



    if v_rcv_transaction_id is null then

        v_statement_id:=8;

    --Add by Kevin Cheng for bug#6962018 Apr 14, 2008
    -------------------------------------------------
    IF(v_source = 'PPA')
    THEN
      RETURN v_invoice_quantity/v_po_quantity;
    END IF; --(v_source = 'PPA')
    -------------------------------------------------

    --added the following if condition by vkaranam for bug #5989740
    if p_factor_type is null then

        -- iSupplier porting
        open c_inv(v_invoice_id);
          fetch c_inv into v_source;
        close c_inv;
        -- iSupplier porting

         if nvl(v_po_quantity , 0) = 0 or nvl(v_po_price, 0) = 0
                or v_source = 'ASBN' then
            return 1;
         end if;

         return ( (v_invoice_quantity / v_po_quantity) * (v_invoice_price / v_po_price) );
   else
      -- Begin Bug# 5989740
      if p_factor_type = 'QUANTITY' then

        if nvl(v_po_quantity , 0) = 0 then

          return 1 ;

        else

          return (v_invoice_quantity / v_po_quantity);

        end if;

      elsif p_factor_type = 'PRICE' then

        if nvl(v_po_price , 0) = 0 then

          return 1 ;

        else

          return (v_invoice_price / v_po_price);

        end if;

      end if; --> p_factor_type = 'QUANTITY'

    end if; --> p_factor_type is null
    -- End Bug# 5989740


    else

        v_statement_id:=9;

    --Add by Kevin Cheng for bug#6962018 Apr 14, 2008
    -------------------------------------------------
    IF(v_source = 'PPA')
    THEN
      RETURN v_invoice_quantity/v_receipt_quantity;
    END IF; --(v_source = 'PPA')
    -------------------------------------------------

     if p_factor_type is null then --bug 5989740
        if nvl(v_receipt_quantity, 0) = 0 or nvl(v_po_price, 0) = 0
            or nvl(v_uom_conv_factor, 0) = 0 then

            return 1;

        end if;
/*Bug 4990941 bduvarag*/
        return (    (v_invoice_quantity / v_receipt_quantity) *
                    (v_invoice_price / NVL(v_receipt_price,v_po_price)) *
                    (1/ v_uom_conv_factor)
                );
  else  -- Begin Bug# 5989740

      if p_factor_type = 'QUANTITY' then

        if nvl(v_receipt_quantity, 0) = 0 or nvl(v_uom_conv_factor, 0) = 0 then

          return 1;
        else

          return (v_invoice_quantity / v_receipt_quantity) * (1/ v_uom_conv_factor);

        end if;

      elsif p_factor_type = 'PRICE' then

        if nvl(v_po_price, 0) = 0 or v_receipt_price = 0 then

          return 1;

        else

          return (v_invoice_price / NVL(v_receipt_price,v_po_price));

        end if;

      end if; --> p_factor_type = 'QUANTITY'

    end if;  --> p_factor_type is null

  end if; -->  v_rcv_transaction_id
  -- End Bug# 5989740




end get_apportion_factor;

PROCEDURE submit_pla_boe_for_approval
(
ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY VARCHAR2,
p_boe_id          In  VARCHAR2,
p_set_of_books_id In  Number,
p_prv_req_id      In  Number,
p_vendor_id       In  Number
)
is
  request_id     Number;
  result         Boolean;
  v_invoice_id   NUmber;
  req_status     Boolean := TRUE;
  v_phase        Varchar2(100);
  v_status       Varchar2(100);
  v_dev_phase    Varchar2(100);
  v_dev_status   Varchar2(100);
  v_message      Varchar2(100);
  v_prv_req_id   Number;

/*-------------------------------------------------------------------------------------------------------------------
 FILENAME: Ja_In_Auto_Invoice_p.sql

 CHANGE HISTORY:
 S.No      Date          Author and Details
 ------------------------------------------
 1.        29/10/2002    Aparajita for bug # 2645196
                         When the parent request for importing fails then this request for approval of
                         PLA/BOE invoices should error out. While polling the status of teh parent request there
                         should be a delay of 60 seconds between polling.

                         Also added exception handling to the main procedure and to the sql that fetches
                         from ap_invoices_all.

                         Since the procedure was revamped with the new approach, deleted the old code.
--------------------------------------------------------------------------------------------------------------------*/
Begin
  v_prv_req_id := p_prv_req_id;

  -- start added by Aparajita on  29/10/2002 for bug # 2645196
  req_status := Fnd_concurrent.wait_for_request(    v_prv_req_id,
                                                    60, -- default value - sleep time in secs
                                                    0,  -- default value - max wait in secs
                                                    v_phase,
                                                    v_status,
                                                    v_dev_phase,
                                                    v_dev_status,
                                                    v_message );

  IF v_dev_phase = 'COMPLETE' THEN

      IF v_dev_status <> 'NORMAL' THEN

          Fnd_File.put_line(Fnd_File.LOG, 'Exiting with warning as parent request not completed with normal status');
          Fnd_File.put_line(Fnd_File.LOG, 'Message from parent request :' || v_message);
          retcode := 1;
          errbuf := 'Exiting with warningr as parent request not completed with normal status';
          RETURN;

      END IF;

  END IF;

  -- end  added by Aparajita on  29/10/2002 for bug # 2645196

  IF v_dev_phase = 'COMPLETE' or v_dev_phase = 'INACTIVE' Then

      IF v_dev_status = 'NORMAL' Then

          begin

            Select invoice_id
            into   v_invoice_id
            from   ap_invoices_all
            Where  invoice_num = p_boe_id
            And    vendor_id = p_vendor_id;

            result := Fnd_request.set_mode(TRUE);
	    /* Bug 5378544. Added by Lakshmi Gopalsami
	     * Included org_id and commit size.
	     */
           request_id := FND_REQUEST.SUBMIT_REQUEST
                         (
                         'SQLAP',
                         'APPRVL',
                         'Payables Approval Localization',
                         NULL,
                         FALSE,
                         '', -- org_id
			 'All', '','','','','', to_char(v_invoice_id),
                         '', to_char(p_set_of_books_id), 'N',
			 '' ); -- commit size
          exception
            when no_data_found then
              Fnd_File.put_line(Fnd_File.LOG, 'Exiting with warning as the PLA/BOE invoice has not got imported ');
              Fnd_File.put_line(Fnd_File.LOG, 'PLA/BOE invoice num :' || p_boe_id );
              retcode := 1;
              errbuf := 'Exiting with warning as the PLA/BOE invoice to approve has not been imported ';
              RETURN;
          end;

      End If;


  End If;

  Fnd_File.put_line(Fnd_File.LOG, 'PLA/BOE invoice num :' || p_boe_id || ', approval request submitted ');

exception
 when others then
  Fnd_File.put_line(Fnd_File.LOG, 'Exception encountered in procedure jai_ap_utils_pkg.submit_pla_boe_for_approval');
  Fnd_File.put_line(Fnd_File.LOG, SQLERRM);
  retcode := 2;
  errbuf := SQLERRM;
  RETURN;
End submit_pla_boe_for_approval;


--As part OF R12 Inititive Inventory conversion the following code IS commented BY Ravi

/*FUNCTION get_opm_assessable_value(p_item_id number,p_qty number,p_exted_price number,P_Cust_Id Number Default 0 ) RETURN NUMBER IS
    Cursor C_Item_Dtl IS
        Select excise_calc_base -- , assessable_value (Commented as Assessable Value is picked by other conditions now )
        From JAI_OPM_ITM_MASTERS
        Where item_id = p_item_id;

---Added For OPM Localization By A.Raina on 22-02-2000
---Code Added For Fetching the Assessable_value at the customer level

    Cursor C_Price_list_id is
    Select Pricelist_Id
      From JAI_OPM_CUSTOMERS
     Where Cust_id = p_cust_id ;

    Cursor C_Cust_Ass_Value ( p_Pricelist_Id In Number ) is
    Select a.Base_Price
      From Op_Prce_Itm a ,op_prce_eff b
     Where a.pricelist_id = b.pricelist_id
       And a.Pricelist_Id = p_Pricelist_id
       And a.Item_Id      = p_item_id
       And sysdate between nvl(start_date, sysdate) and nvl(end_date, sysdate) ;

    CURSOR C_item_Ass_Value IS
    Select assessable_value
      From JAI_OPM_ITM_MASTERS
     Where item_id = p_item_id;

    v_pricelist_id  Number;
    v_assessable_flag char(1) ;
--End Addition
    l_assessable_val number;
    l_excise_cal varchar2(1);
  BEGIN

---Added For OPM Localization By A.Raina on 22-02-2000
---Code Added For Fetching the Assessable_value at the customer level

     OPEN C_Price_list_id ;
    FETCH C_Price_list_id into v_pricelist_id;
    CLOSE C_Price_list_id ;

    l_assessable_val := Null ;
   IF v_pricelist_id is Not Null Then
     OPEN  C_Cust_Ass_Value (v_pricelist_id ) ;
     FETCH C_Cust_Ass_Value into l_assessable_val ;
     CLOSE C_Cust_Ass_Value ;
   End If;
   IF l_assessable_val Is Null Then
     OPEN  C_item_Ass_Value ;
     FETCH C_item_Ass_Value into l_assessable_val ;
     CLOSE C_item_Ass_Value ;
   End If;

---End Addition

    OPEN C_Item_Dtl;
    FETCH C_Item_Dtl  INTO l_excise_cal ; -- l_assessable_val (Commented as Assessable Value is picked by other conditions now )
    CLOSE C_Item_Dtl ;

    IF NVL(l_excise_cal,'N') = 'Y' THEN
      Return(l_assessable_val*p_qty);
    ELSE
      Return(p_exted_price);
    END IF;
  END get_opm_assessable_value;*/


PROCEDURE Print_Log
        (
        P_debug                 IN      VARCHAR2,
        P_string                IN      VARCHAR2
        ) IS

stemp    VARCHAR2(1000);
nlength  NUMBER := 1;

BEGIN

  IF (P_Debug = 'Y') THEN
     WHILE(length(P_string) >= nlength)
     LOOP

        stemp := substrb(P_string, nlength, 80);
        fnd_file.put_line(FND_FILE.LOG, stemp);
        nlength := (nlength + 80);

     END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Print_log;


Procedure pan_update ( P_errbuf      OUT NOCOPY varchar2,
                       P_return_code OUT NOCOPY varchar2,
                       P_vendor_id    IN         PO_VENDORS.vendor_id%TYPE,
                       P_old_pan_num  IN   JAI_AP_TDS_VENDOR_HDRS.pan_no%TYPE,
                       P_new_pan_num  IN   JAI_AP_TDS_VENDOR_HDRS.pan_no%TYPE,
                       P_debug_flag   IN         varchar2) is


/* Cursor to lock the jai_ap_tds_thhold_grps */

Cursor C_lock_thhold_grps is
 select threshold_grp_id,
        vendor_id,
        org_tan_num,
        vendor_pan_num,
        section_type,
        section_code,
        fin_year,
        total_invoice_amount,
        total_invoice_cancel_amount,
        total_invoice_apply_amount,
        total_invoice_unapply_amount,
        total_tax_paid,
        total_thhold_change_tax_paid,
        current_threshold_slab_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
   from jai_ap_tds_thhold_grps
  where vendor_id = P_vendor_id
    and vendor_pan_num = p_old_pan_num
  order by vendor_id,threshold_grp_id
  for UPDATE of threshold_grp_id NOWAIT;



/* Update the tables in the following order

(1) JAI_AP_TDS_VENDOR_HDRS
(2) jai_ap_tds_thhold_grps
(3) jai_ap_tds_thhold_xceps

*/

lv_vendor_site_id_updated varchar2(1000) ;
lv_thhold_grp_id_updated varchar2(1000) ;
lv_thhold_xcep_id_updated varchar2(1000) ;
ln_request_id number;
lv_debug_flag varchar2(30);
lv_debug_msg varchar2(4000) ;


begin

 lv_debug_flag := nvl(p_debug_flag, 'N');

 lv_vendor_site_id_updated  := '';
 lv_thhold_grp_id_updated   := '';
 lv_thhold_xcep_id_updated  := '';

 fnd_file.put_line(FND_FILE.LOG, 'START OF Procedure ');

  ln_request_id := FND_GLOBAL.conc_request_id;

  lv_debug_msg := ' A. Report Parameters';

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  lv_debug_msg := ' B. request id '|| ln_request_id ;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  lv_debug_msg := ' C. debug flag ' || lv_debug_flag;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  lv_debug_msg := ' D. old pan ' || P_old_pan_num ;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  lv_debug_msg := ' E. new pan ' || P_new_pan_num ;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  lv_debug_msg :='  F. vendor id '|| P_vendor_id;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

 -- Update the jai_ap_tds_thhold_grps

  lv_debug_msg := ' 1. Update jai_ap_tds_thhold_grps';

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  for  thhold_grps in C_lock_thhold_grps
   loop

     lv_debug_msg := ' 2. Going to update jai_ap_tds_thhold_grps';

      If lv_debug_flag = 'Y' then
        Print_log(lv_debug_flag, lv_debug_msg);
      End if;

      update jai_ap_tds_thhold_grps
         set vendor_pan_num = P_new_pan_num
       where vendor_id = P_vendor_id
         and vendor_pan_num = P_old_pan_num
         and threshold_grp_id = thhold_grps.threshold_grp_id;

      lv_debug_msg := ' 3. Done with update of '|| thhold_grps.threshold_grp_id;

      If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag, lv_debug_msg);
      End if;

      lv_thhold_grp_id_updated := lv_thhold_grp_id_updated || '-' || thhold_grps.threshold_grp_id;

      lv_debug_msg := ' 4. Value of lv_thhold_grp_id_updated '|| lv_thhold_grp_id_updated;

      If lv_debug_flag = 'Y' then
        Print_log(lv_debug_flag, lv_debug_msg);
      End if;


   end loop;


 -- Update the JAI_AP_TDS_VENDOR_HDRS
  lv_debug_msg := ' 5. Update JAI_AP_TDS_VENDOR_HDRS';

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  for vndr_tds_hdr in (select vthdr.*
                           from JAI_AP_TDS_VENDOR_HDRS vthdr
                          where vthdr.vendor_id = P_vendor_id
                            and vthdr.pan_no = P_old_pan_num)
    loop

     lv_debug_msg := ' 6. Going to update JAI_AP_TDS_VENDOR_HDRS';

     If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag, lv_debug_msg);
     End if;

      update JAI_AP_TDS_VENDOR_HDRS
         set pan_no = P_new_pan_num
       where vendor_id = vndr_tds_hdr.vendor_id
         and vendor_site_id = vndr_tds_hdr.vendor_site_id
         and pan_no = P_old_pan_num;


     lv_debug_msg := ' 7. Done with update of vendor '|| vndr_tds_hdr.vendor_id;
     lv_debug_msg := lv_debug_msg || ' site '|| vndr_tds_hdr.vendor_site_id ;

     If lv_debug_flag = 'Y' then
      Print_log(lv_debug_flag, lv_debug_msg);
     End if;

      If vndr_tds_hdr.vendor_site_id <> 0 Then
        lv_vendor_site_id_updated := lv_vendor_site_id_updated || ' - '||vndr_tds_hdr.vendor_site_id;
      End if;

      lv_debug_msg := ' 8. Value of lv_vendor_site_id_updated '|| lv_vendor_site_id_updated;


      If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag, lv_debug_msg);
      End if;

    end loop;


 -- jai_ap_tds_thhold_xceps

  lv_debug_msg := ' 9. Update jai_ap_tds_thhold_xceps';

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

  for thhold_xceps in (select tdsxps.*
                          from jai_ap_tds_thhold_xceps tdsxps
                         where tdsxps.vendor_id = P_vendor_id
                           and vendor_pan = P_old_pan_num)
   loop

     lv_debug_msg := ' 10. Going to update jai_ap_tds_thhold_xceps';

     If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag, lv_debug_msg);
     End if;

     Update jai_ap_tds_thhold_xceps
        set vendor_pan = P_new_pan_num
      where vendor_id = P_vendor_id
        and vendor_pan = P_old_pan_num;

     lv_debug_msg := ' 11. Done with update of vendor'||P_vendor_id ;

     If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag, lv_debug_msg);
     End if;

     lv_thhold_xcep_id_updated := lv_thhold_xcep_id_updated || '-' || thhold_xceps.threshold_exception_id;

     lv_debug_msg := ' 12. Value of lv_thhold_xcep_id_updated '|| lv_thhold_xcep_id_updated;

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

   end loop;


 -- insert a record in jai_ap_tds_pan_changes
 -- This help us to keep track of PAN changes for the given vendor


  lv_debug_msg := ' 13. Inside insert -  ';

  If lv_debug_flag = 'Y' then
   Print_log(lv_debug_flag, lv_debug_msg);
  End if;

   Insert into jai_ap_tds_pan_changes
    ( pan_change_id,
      vendor_id,
      old_pan_num,
      new_pan_num,
      request_id,
      request_date,
      vendor_site_id_updated,
      thhold_grp_id_updated,
      thhold_xcep_id_updated,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    )
   values
    ( jai_ap_tds_pan_changes_s.nextval,
      P_vendor_id,
      P_old_pan_num,
      P_new_pan_num,
      ln_request_id,
      sysdate,
      lv_vendor_site_id_updated,
      lv_thhold_grp_id_updated,
      lv_thhold_xcep_id_updated,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id
    );


   commit;

Exception
    When others then

     IF (SQLCODE < 0) then

      If lv_debug_flag = 'Y' then
         Print_log(lv_debug_flag,lv_debug_msg);
         Print_log(lv_debug_flag,SQLERRM);
      End if;
     END IF;

    IF (SQLCODE = -54) then
      If lv_debug_flag = 'Y' then
       Print_log(lv_debug_flag,'(Pan update :Exception) Vendor to be updated by this process are locked');
      end if;
    END IF;

End pan_update;

/*
|| Added function get_tds_invoice_batch by Ramananda for bug#4584221
*/
FUNCTION get_tds_invoice_batch(p_invoice_id IN  NUMBER,
                               p_org_id number default null)   --added org_id parameter for bug#9149941
    RETURN VARCHAR2 IS

    lv_same_tds_batch   VARCHAR2(1);
    lv_batch_name       ap_batches_all.batch_name%TYPE;
    ln_regime_id        JAI_RGM_DEFINITIONS.regime_id%type ;
    lv_attribute_value  JAI_RGM_ORG_REGNS_V.attribute_Value%type ;

    CURSOR c_regime_cur IS
    SELECT regime_id
    FROM   JAI_RGM_DEFINITIONS
    WHERE  regime_code = jai_constants.tds_regime;

    CURSOR c_attribute_value_cur(P_regime_id IN NUMBER, p_org_id number) is    --added org_id parameter for bug#9149941
    SELECT attribute_Value
    FROM   JAI_RGM_ORG_REGNS_V
    WHERE  regime_id = P_regime_id
    AND    attribute_type_code = jai_constants.regn_type_others
    AND    attribute_code = jai_constants.regn_type_tds_batch
	and    organization_id = nvl(p_org_id, organization_id);  --added for Bug#9149941

    CURSOR c_batch_name(cp_invoice_id NUMBER)
    IS
    SELECT  b.batch_name
    FROM    ap_invoices_all a,
            ap_batches_all b
    WHERE   a.batch_id = b.batch_id
    AND     a.invoice_id = cp_invoice_id;

  BEGIN

    OPEN  c_regime_cur ;
    FETCH c_regime_cur INTO ln_regime_id ;
    CLOSE c_regime_cur ;

    OPEN c_attribute_value_cur(ln_regime_id, p_org_id) ;   --added org_id parameter for bug#9149941
    FETCH c_attribute_value_cur INTO lv_attribute_value ;
    CLOSE c_attribute_value_cur ;

    IF upper(lv_attribute_value) in ('YES' , 'Y') THEN

      OPEN c_batch_name(p_invoice_id);
      FETCH c_batch_name INTO lv_batch_name;
      CLOSE c_batch_name;

    END IF;

    IF UPPER(NVL(lv_attribute_value,'N')) in ('NO','N')
         OR lv_batch_name IS NULL THEN
      lv_batch_name := 'TDS'||TO_CHAR(TRUNC(SYSDATE));
    END IF;

    RETURN lv_batch_name;
 END get_tds_invoice_batch;

 /*------------------------------------------------------------------------------------------------------------*/
 -- Begin 4579729
 /*------------------------------------------------------------------------------------------------------------*/

procedure jai_calc_ipv_erv (P_errmsg OUT NOCOPY VARCHAR2,
                            P_retcode OUT NOCOPY Number,
          P_invoice_id in number,
          P_po_dist_id in number,
          P_invoice_distribution_id IN NUMBER,
          P_amount IN NUMBER,
          P_base_amount IN NUMBER,
          P_rcv_transaction_id IN NUMBER,
          P_invoice_price_variance IN NUMBER,
          P_base_invoice_price_variance IN NUMBER,
          P_price_var_ccid IN NUMBER,
          P_Exchange_rate_variance IN NUMBER,
          P_rate_var_ccid IN NUMBER
                           )
as

/* Cursors  */

Cursor check_rec_tax ( ln_tax_id number) is
select tax_name,
        tax_account_id,
        mod_cr_percentage,
        adhoc_flag,
        nvl(tax_rate, 0) tax_rate,
        tax_type
from  JAI_CMN_TAXES_ALL
where  tax_id = ln_tax_id;


Cursor get_misc_lines (ln_dist_line_number in number,
                       ln_invoice_id in number ) is
select *
  from ap_invoice_distributions_all
 where invoice_id = ln_invoice_id
   and distribution_line_number = ln_dist_line_number;


/* precision */
Cursor get_prec (lv_currency_code varchar2) is
select precision
from  fnd_currencies
where currency_code = lv_currency_code;


/* Local Variables */
ln_tax_ipv number;
ln_tax_bipv number;
ln_price_var_ccid number;

ln_tax_erv number;

lv_inv_curr_code varchar2(15);
lv_base_curr_code varchar2(15);

ln_inv_pre number;
ln_base_pre number;

r_get_misc_lines get_misc_lines%ROWTYPE;



Begin


   fnd_file.put_line(FND_FILE.LOG, ' inside procedure ');

   lv_base_curr_code := 'INR';

   Begin
     Select invoice_currency_code
       into lv_inv_curr_code
       from ap_invoices_all
      where invoice_id = p_invoice_id;

   Exception
      When others then
        null;
   End;

   If lv_inv_curr_code = 'INR' Then
     open get_prec(lv_base_curr_code);
      Fetch get_prec into ln_base_pre;
     Close get_prec;

     ln_inv_pre := ln_base_pre;

   Else
     open get_prec(lv_inv_curr_code);
      Fetch get_prec into ln_inv_pre;
     Close get_prec;

     open get_prec(lv_base_curr_code);
      Fetch get_prec into ln_base_pre;
     Close get_prec;

   End if;

   fnd_file.put_line(FND_FILE.LOG, ' invoice id '|| p_invoice_id);
   fnd_file.put_line(FND_FILE.LOG, ' po dist  id '|| p_po_dist_id);

   for Misc_loop in ( select *
                          from JAI_AP_MATCH_INV_TAXES
                         where invoice_id = p_invoice_id
         and parent_invoice_distribution_id = p_invoice_distribution_id
                      )
     loop


       fnd_file.put_line(FND_FILE.LOG,' inside loop -- 2 ' );

       /* For later use if necessary to check the tax type. now education cess will not be
     created at invoice level if it is available in PO/Receipt level

         for tax_loop in check_rec_tax (select tax_id
             from ja_in_ap_tax_distributions
                 where invoice_id = misc_loop.invoice_id
              and distribution_line_number = misc_loop.distribution_line_number)
         loop

         Service and Education cess are recoverable taxes and
         IPV should not be calculated on these lines
      If  not (tax_loop.tax_type like '%EDUCATION_CESS') Then

       */

       Open get_misc_lines(misc_loop.distribution_line_number, misc_loop.invoice_id);
         Fetch get_misc_lines into r_get_misc_lines;
       Close get_misc_lines;

       If nvl(p_amount ,0) <> 0 Then

         fnd_file.put_line(FND_FILE.LOG,' Inside item amount not zero ' || p_amount);

         If nvl(r_get_misc_lines.amount , 0 ) <> 0 Then

         fnd_file.put_line(FND_FILE.LOG,' Inside Tax amount not zero ' || r_get_misc_lines.amount);

   IF nvl(p_invoice_price_variance,0 ) <> 0 Then

           ln_tax_ipv := r_get_misc_lines.amount * (nvl(p_invoice_price_variance,0) /p_amount);

         End if;

   IF nvl(p_exchange_rate_variance,0 ) <> 0 Then

           ln_tax_erv := r_get_misc_lines.amount * (nvl(p_exchange_rate_variance,0)/p_amount);

         End if;

         fnd_file.put_line(FND_FILE.LOG,' IPV '|| ln_tax_ipv);
         fnd_file.put_line(FND_FILE.LOG,' ERV '|| ln_tax_erv);

         /* IPV */

         If nvl(ln_tax_ipv,0) <> 0   then

          fnd_file.put_line(FND_FILE.LOG,' Inside IPV not zero '|| ln_tax_ipv);

           ln_tax_bipv := ln_tax_ipv * nvl(r_get_misc_lines.exchange_rate,1);

                 update ap_invoice_distributions_all
                    set invoice_price_variance = round(ln_tax_ipv,ln_inv_pre),
                         base_invoice_price_variance = round(ln_tax_bipv, ln_base_pre),
                         price_var_code_combination_id = P_price_var_ccid
                  where invoice_distribution_id = r_get_misc_lines.invoice_distribution_id;
         End if;

         /* ERV */


         If nvl(ln_tax_erv,0) <> 0   then

          fnd_file.put_line(FND_FILE.LOG,' Inside ERV not zero '|| ln_tax_erv);
          fnd_file.put_line(FND_FILE.LOG,' rate var CCID '|| P_rate_var_ccid);

                 update ap_invoice_distributions_all
                    set exchange_rate_variance = round(ln_tax_erv,ln_inv_pre),
                        rate_var_code_combination_id = P_rate_var_ccid
                  where invoice_distribution_id = r_get_misc_lines.invoice_distribution_id;
        End if;


        Else

         /* update ipv and bipv to 0. no need to update Var CCID */

               update ap_invoice_distributions_all
                    set invoice_price_variance = 0,
                        base_invoice_price_variance = 0,
      exchange_rate_variance = 0
               where invoice_distribution_id = r_get_misc_lines.invoice_distribution_id;
         End if;
   /*  r_get_misc_lines.amount <> 0  */

        End if; /* p_amount <> 0 */

       -- end loop;  -- End tax_loop
     end loop;       -- End misc_loop

   p_errmsg :=NULL;
   p_retcode := NULL;


Exception
  When others then
      P_errmsg := SQLERRM;
      P_retcode := 2;
      Fnd_File.put_line(Fnd_File.LOG, 'EXCEPTION END PROCEDURE - JAI_CALC_IPV ');
      Fnd_File.put_line(Fnd_File.LOG, 'Error : ' || P_errmsg);
End jai_calc_ipv_erv;

-- added, Harshita for Bug 5553150

FUNCTION fetch_tax_target_amt
( p_invoice_id          IN NUMBER      ,
  p_line_location_id    IN NUMBER ,
  p_transaction_id      IN NUMBER ,
  p_parent_dist_id      IN NUMBER,
  p_tax_id              IN NUMBER
)
RETURN NUMBER
IS

  TYPE TAX_CUR IS RECORD
  (
    P_1   JAI_PO_TAXES.precedence_1%type,
    P_2   JAI_PO_TAXES.precedence_2%type,
    P_3   JAI_PO_TAXES.precedence_3%type,
    P_4   JAI_PO_TAXES.precedence_4%type,
    P_5   JAI_PO_TAXES.precedence_5%type,
    P_6   JAI_PO_TAXES.precedence_6%type,
    P_7   JAI_PO_TAXES.precedence_7%type,
    P_8   JAI_PO_TAXES.precedence_8%type,
    P_9   JAI_PO_TAXES.precedence_9%type,
    P_10  JAI_PO_TAXES.precedence_10%type
   ) ;

   TYPE tax_cur_type IS REF CURSOR RETURN TAX_CUR;
   c_tax_cur TAX_CUR_TYPE;
   rec     c_tax_cur%ROWTYPE;
   ln_base_amt number ;


    FUNCTION fetch_line_amt(p_precedence_value IN NUMBER)
    RETURN NUMBER
    IS
      cursor c_line_amt
      is
      select NVL(tax_amount,-1)  -- 5763527, Added by kunkumar for Bug#5593895
      from JAI_AP_MATCH_INV_TAXES
      where invoice_id = p_invoice_id
      AND parent_invoice_distribution_id = p_parent_dist_id   /*bug 9346307*/
      and   line_no = p_precedence_value ;

      cursor c_base_inv_amt
      is
      select amount
      from ap_invoice_distributions_all
      where  invoice_distribution_id = p_parent_dist_id
      and invoice_id = p_invoice_id ;

      ln_line_amt number ;

    BEGIN
      if p_precedence_value = -1 then
        return 0 ;
      elsif p_precedence_value = 0 then
        open c_base_inv_amt ;
        fetch c_base_inv_amt into ln_line_amt ;
        close c_base_inv_amt ;
        return nvl(ln_line_amt,0) ;
      else
        open c_line_amt ;
        fetch c_line_amt into ln_line_amt ;
        close c_line_amt ;
        return nvl(ln_line_amt,0) ;
      end if ;

    END fetch_line_amt;

  BEGIN

    IF p_line_location_id is not null then
      OPEN c_tax_cur FOR
      select Precedence_1 P_1,
             Precedence_2 P_2,
             Precedence_3 P_3,
             Precedence_4 P_4,
             Precedence_5 P_5,
             Precedence_6 P_6,
             Precedence_7 P_7,
             Precedence_8 P_8,
             Precedence_9 P_9,
             Precedence_10 P_10
     from JAI_PO_TAXES
     where line_location_id = p_line_location_id
     and tax_id = p_tax_id ;
    ELSE
      OPEN c_tax_cur FOR
      select Precedence_1 P_1,
             Precedence_2 P_2,
             Precedence_3 P_3,
             Precedence_4 P_4,
             Precedence_5 P_5,
             Precedence_6 P_6,
             Precedence_7 P_7,
             Precedence_8 P_8,
             Precedence_9 P_9,
             Precedence_10 P_10
     from JAI_RCV_LINE_TAXES
     where shipment_line_id IN
           ( select shipment_line_id
             from JAI_RCV_LINE_TAXES
             where  transaction_id = p_transaction_id
           )
     and tax_id = p_tax_id ;

    END IF ;

    FETCH c_tax_cur INTO rec;
    ln_base_amt  := fetch_line_amt(nvl(rec.P_1,-1))  + fetch_line_amt(nvl(rec.P_2,-1)) + fetch_line_amt(nvl(rec.P_3,-1))
                      + fetch_line_amt(nvl(rec.P_4,-1)) + fetch_line_amt(nvl(rec.P_5,-1)) + fetch_line_amt(nvl(rec.P_6,-1))
		      + fetch_line_amt(nvl(rec.P_7,-1)) + fetch_line_amt(nvl(rec.P_8,-1)) + fetch_line_amt(nvl(rec.P_9,-1))
		      + fetch_line_amt(nvl(rec.P_10,-1)) ;
    CLOSE c_tax_cur ;
    return ln_base_amt ;


  END fetch_tax_target_amt ;
  -- ended, Harshita for Bug 5553150
 /*------------------------------------------------------------------------------------------------------------*/
 -- End 4579729
 /*------------------------------------------------------------------------------------------------------------*/


-- Added by Jia Li for Tax inclusive computation on 2007/12/17, Begin
--==========================================================================
--  FUNCTION NAME:
--
--    get_tax_account_id                        Private
--
--  DESCRIPTION:
--
--    This function is get tax account ccid
--
--  PARAMETERS:
--      In:  pn_tax_id
--           pn_tax_type
--           pn_org_id
--
--  DESIGN REFERENCES:
--    Inclusive Tax Technical Design V1.4.doc
--
--  CHANGE HISTORY:
--
--           20-DEC-2007   Jia Li  created
--==========================================================================
FUNCTION get_tax_account_id
( pn_tax_id    IN NUMBER
, pv_tax_type  IN VARCHAR2
, pn_org_id    IN NUMBER
)
RETURN NUMBER
IS
ln_tax_def_acc_id NUMBER;
ln_tax_rgm_acc_id NUMBER;
ln_tax_acc_id     NUMBER;
lv_procedure_name VARCHAR2(40):='get_tax_account_id';
ln_dbg_level      NUMBER:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER:=FND_LOG.LEVEL_PROCEDURE;

CURSOR cur_tax_acc IS
  SELECT
    tax_account_id
  FROM
    jai_cmn_taxes_all
  WHERE tax_id = pn_tax_id;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.parameter'
                  , 'Org_id = ' || pn_org_id
                  );
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.parameter'
                  , 'Tax_id = '|| pn_tax_id ||' Tax_type = ' || pv_tax_type
                  );
  END IF; --ln_proc_level>=l_dbg_level

  -- Get tax_account_id from tax defination
  OPEN cur_tax_acc;
  FETCH cur_tax_acc INTO ln_tax_def_acc_id;
  CLOSE cur_tax_acc;

  -- Get tax_account_id from rgm setup for SERVICE and VAT tax.
  BEGIN
    SELECT
      TO_NUMBER(acc_rgm.attribute_value)
    INTO
      ln_tax_rgm_acc_id
    FROM
      jai_rgm_definitions   rgm_def
    , jai_rgm_registrations tax_rgm
    , jai_rgm_registrations acc_rgm
    WHERE regime_code IN (jai_constants.service_regime,jai_constants.vat_regime)
      AND tax_rgm.regime_id = rgm_def.regime_id
      AND tax_rgm.registration_type = jai_constants.regn_type_tax_types
      AND tax_rgm.attribute_code = pv_tax_type
      AND tax_rgm.regime_id = acc_rgm.regime_id
      AND acc_rgm.registration_type = jai_constants.regn_type_accounts
      AND acc_rgm.attribute_code = jai_constants.recovery_interim
      AND acc_rgm.parent_registration_id = tax_rgm.registration_id;

    ln_tax_acc_id := ln_tax_rgm_acc_id;
  EXCEPTION
    WHEN no_data_found THEN
      ln_tax_acc_id := ln_tax_def_acc_id;
    WHEN OTHERS THEN
      ln_tax_acc_id := -1;
  END;

  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.result'
                  , 'Tax Account ID = ' || ln_tax_acc_id
                  );
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Enter procedure'
                  );
  END IF;  -- ln_proc_level >= ln_dbg_level

  RETURN ln_tax_acc_id;

END get_tax_account_id;


--==========================================================================
--  PROCEDURE NAME:
--
--    insert_gl_interface                       Private
--
--  DESCRIPTION:
--
--    This function is insert inclusive data into gl_interface
--
--  PARAMETERS:
--      In:  pn_set_of_books_id               the set of books id
--           pd_accounting_date               GL date of the invoice
--           pv_currency_code                 currency code
--           pn_enter_cr                      credit amount
--           pn_enter_dr                      debit amount
--           pd_transaction_date              invoice date
--           pn_code_combination_id           code_combination_id
--           pd_currency_conversion_date      the column values can be retreived from the invoice
--           pv_currency_conversion_type      the column values can be retreived from the invoice
--           pv_currency_conversion_rate      the column values can be retreived from the invoice
--           pv_reference1                    inventory organization code,base on organization_id from PO/Receipt from where it's matched
--           pv_reference10                   'India Localization Entry for accounting inclusive taxes for invoice'||lv_invoice_num
--           pv_reference23                   procedure name that makes the insert into gl_interface hard code string
--           pv_reference26                   value of invoice_id
--           pv_reference27                   organization id of the inventory organization id
--
--  DESIGN REFERENCES:
--    Inclusive Tax Technical Design V1.4.doc
--
--  CHANGE HISTORY:
--
--           20-DEC-2007   Jia Li  created
--==========================================================================
PROCEDURE insert_gl_interface
( pn_set_of_books_id               IN NUMBER
, pd_accounting_date               IN DATE
, pv_currency_code                 IN VARCHAR2
, pn_enter_cr                      IN NUMBER DEFAULT NULL
, pn_enter_dr                      IN NUMBER DEFAULT NULL
, pd_transaction_date              IN DATE
, pn_code_combination_id           IN NUMBER
, pd_currency_conversion_date      IN DATE
, pv_currency_conversion_type      IN VARCHAR2
, pv_currency_conversion_rate      IN VARCHAR2
, pv_reference1                    IN VARCHAR2
, pv_reference10                   IN VARCHAR2
, pv_reference23                   IN VARCHAR2
, pv_reference26                   IN VARCHAR2
, pv_reference27                   IN VARCHAR2
)
IS
BEGIN
  INSERT INTO gl_interface
    ( status
    , set_of_books_id
    , user_je_source_name
    , user_je_category_name
    , accounting_date
    , currency_code
    , date_created
    , created_by
    , actual_flag
    , entered_cr
    , entered_dr
    , transaction_date
    , code_combination_id
    , currency_conversion_date
    , user_currency_conversion_type
    , currency_conversion_rate
    , reference1
    , reference10
    , reference22
    , reference23
    , reference24
    , reference25
    , reference26
    , reference27
    )
  VALUES
    ( 'NEW'                                   -- 'NEW'
    , pn_set_of_books_id
    , 'Payables India'                        -- je source name 'Payables India'
    , 'Register India'                        -- je category name 'Register India'
    , pd_accounting_date
    , pv_currency_code
    , sysdate                                 -- standard who column
    , TO_NUMBER(fnd_profile.value('USER_ID')) -- standard who column
    , 'A'                                     -- 'A'
    , pn_enter_cr
    , pn_enter_cr
    , pd_transaction_date
    , pn_code_combination_id
    , pd_currency_conversion_date
    , pv_currency_conversion_type
    , pv_currency_conversion_rate
    , pv_reference1
    , 'India Localization Entry for accounting inclusive taxes for invoice'||pv_reference10
    , 'India Localization Entry'             -- 'India Localization Entry'
    , pv_reference23
    , 'AP_INVOICES_ALL'                      -- 'AP_INVOICES_ALL'
    , 'INVOICE_ID'                           -- 'INVOICE_ID'
    , pv_reference26
    , pv_reference27
    );
END insert_gl_interface;


--==========================================================================
--  PROCEDURE NAME:
--
--    acct_inclu_taxes                        Public
--
--  DESCRIPTION:
--
--    This procedure is written that would pass GL entries for inclusive taxes in GL interface
--
--  PARAMETERS:
--      In:  pn_invoice_id                 pass the invoice id for which the accounting needs to done
--           pn_invoice_distribution_id    pass the invoice distribution id for the item line which the accounting needs to done
--     OUt:  xv_process_flag               Indicates the process flag, 'SS' for success
--                                                                     'EE' for expected error
--                                                                     'UE' for unexpected error
--           xv_process_message           Indicates the process message
--
--
--  DESIGN REFERENCES:
--    Inclusive Tax Technical Design V1.4.doc
--
--  CHANGE HISTORY:
--
--           17-DEC-2007   Jia Li  created
--==========================================================================
PROCEDURE acct_inclu_taxes
( pn_invoice_id              IN  NUMBER
, pn_invoice_distribution_id IN NUMBER
, xv_process_flag            OUT NOCOPY VARCHAR2
, xv_process_message         OUT NOCOPY VARCHAR2
)
IS
ln_org_id                ap_invoices_all.org_id%TYPE;
ld_gl_date               ap_invoices_all.gl_date%TYPE;
lv_invoice_num           ap_invoices_all.invoice_num%TYPE;
ld_invoice_date          ap_invoices_all.invoice_date%TYPE;
lv_invoice_currency_code ap_invoices_all.invoice_currency_code%TYPE;
ln_exchange_rate         ap_invoices_all.exchange_rate%TYPE;
lv_exchange_rate_type    ap_invoices_all.exchange_rate_type%TYPE;
ld_exchange_date         ap_invoices_all.exchange_date%TYPE;

ln_inventory_item_id     ap_invoice_lines_all.inventory_item_id %TYPE;
ld_accounting_date       ap_invoice_lines_all.accounting_date%TYPE;
lv_match_type            ap_invoice_lines_all.match_type%TYPE;
ln_set_of_books_id       ap_invoice_lines_all.set_of_books_id%TYPE;
ln_po_dist_id            ap_invoice_lines_all.po_distribution_id%TYPE;
ln_po_loc_id             ap_invoice_lines_all.po_line_location_id%TYPE;
ln_item_line_amt         ap_invoice_lines_all.amount%TYPE;

ln_invoice_line_num      ap_invoice_distributions_all.invoice_line_number%TYPE;
lv_inclu_tax_flag        jai_ap_tds_years.inclusive_tax_flag%TYPE;
ln_inv_org_id             mtl_parameters.organization_id%TYPE;
lv_inv_org_code           mtl_parameters.organization_code%TYPE;

lv_accrue_on_receipt_flag VARCHAR2(10);
ln_tax_account_id         NUMBER;
ln_invoice_post_num       NUMBER;
ln_total_inclu_tax_amt    NUMBER;
ln_cr_line_amt            NUMBER;
ln_total_cr_line_amt      NUMBER;

lv_procedure_name VARCHAR2(40):='acct_inclu_taxes';
ln_dbg_level      NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
ln_proc_level     NUMBER := FND_LOG.LEVEL_PROCEDURE;

CURSOR match_inclu_tax_cur
( pn_invoice_line_num NUMBER
)
IS
  SELECT
    tax_line.tax_id          tax_id
  , tax.tax_type             tax_type
  , SUM(tax_line.tax_amount) tax_amount
  FROM
    jai_ap_match_inv_taxes  tax_line
  , jai_cmn_taxes_all       tax
  WHERE NVL(tax.inclusive_tax_flag,'N') = 'Y'
    AND tax_line.invoice_id = pn_invoice_id
    AND tax_line.parent_invoice_line_number = pn_invoice_line_num
    AND tax_line.tax_id = tax.tax_id
  GROUP BY
    tax_line.tax_id
  , tax.tax_type;

CURSOR standalone_inclu_tax_cur
( pn_invoice_line_num NUMBER
)
IS
  SELECT
    tax_line.tax_id        tax_id
  , tax.tax_type           tax_type
  , SUM(tax_line.tax_amt)  tax_amount
  FROM
    jai_cmn_document_taxes tax_line
  , jai_cmn_taxes_all      tax
  WHERE NVL(tax.inclusive_tax_flag,'N') = 'Y'
    AND tax_line.source_doc_type = jai_constants.G_AP_STANDALONE_INVOICE
    AND tax_line.source_doc_id = pn_invoice_id
    AND tax_line.source_doc_parent_line_no = pn_invoice_line_num
    AND tax_line.tax_id = tax.tax_id
  GROUP BY
    tax_line.tax_id
  , tax.tax_type;

CURSOR item_line_dist_cur
( pn_invoice_line_num NUMBER
)
IS
  SELECT
    dist_code_combination_id
  , amount
  FROM
    ap_invoice_distributions_all
  WHERE invoice_id = pn_invoice_id
    AND invoice_line_number = pn_invoice_line_num;

BEGIN
  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.begin'
                  , 'Enter procedure'
                  );
  END IF; --ln_proc_level>=l_dbg_level

  -- Init variable
  ln_total_inclu_tax_amt := 0;
  ln_cr_line_amt         := 0;
  ln_total_cr_line_amt   := 0;
  ln_invoice_post_num    := 0;

  -- Get invoice info
  SELECT
    org_id
  , gl_date
  , invoice_num
  , invoice_date
  , invoice_currency_code
  , exchange_rate
  , exchange_rate_type
  , exchange_date
  INTO
    ln_org_id
  , ld_gl_date
  , lv_invoice_num
  , ld_invoice_date
  , lv_invoice_currency_code
  , ln_exchange_rate
  , lv_exchange_rate_type
  , ld_exchange_date
  FROM
    ap_invoices_all
  WHERE invoice_id = pn_invoice_id;

  -- Check whether inclusive taxes needs to be accounted separately
  BEGIN
    SELECT
      NVL(ja.inclusive_tax_flag, 'N')  inclusive_tax_flag
    INTO
      lv_inclu_tax_flag
    FROM
      jai_ap_tds_years ja
    WHERE ja.legal_entity_id = ln_org_id
      AND sysdate BETWEEN ja.start_date AND ja.end_date;
  EXCEPTION
    WHEN OTHERS THEN
      lv_inclu_tax_flag := 'N';
  END;

  -- If the user has setup to account inclusive aeparately,  inclusive taxes need insert into GL Interface table.
  IF lv_inclu_tax_flag = 'Y'
  THEN

    -- According pn_invoice_distribution_id to get ITEM line num .
    BEGIN
      SELECT
        aila.line_number
      INTO
        ln_invoice_line_num
      FROM
        ap_invoice_distributions_all aida
      , ap_invoice_lines_all aila
      WHERE aida.invoice_distribution_id = pn_invoice_distribution_id
        AND aila.line_number = aida.invoice_line_number
        AND aila.invoice_id = pn_invoice_id
        AND aila.line_type_lookup_code = 'ITEM';
    EXCEPTION
      WHEN OTHERS THEN
        ln_invoice_line_num := 0;
    END;

    IF ln_invoice_line_num > 0
    THEN
      -- Get item invoice line info
      SELECT
        inventory_item_id
      , set_of_books_id
      , match_type
      , po_distribution_id
      , po_line_location_id
      , amount
      INTO
        ln_inventory_item_id
      , ln_set_of_books_id
      , lv_match_type
      , ln_po_dist_id
      , ln_po_loc_id
      , ln_item_line_amt
      FROM
        ap_invoice_lines_all
      WHERE invoice_id = pn_invoice_id
        AND line_number = ln_invoice_line_num;

      -- Get inv_organization_id and inv_organization_code
      IF ln_po_dist_id IS NULL
      THEN
        lv_match_type := jai_constants.G_AP_STANDALONE_INVOICE;
        ln_inv_org_id := NULL;
        lv_inv_org_code := '';
      ELSE
        SELECT
          ploc.ship_to_organization_id
        , mp.organization_code
        INTO
          ln_inv_org_id
        , lv_inv_org_code
        FROM
          po_line_locations_all ploc
        , mtl_parameters mp
        WHERE ploc.line_location_id = ln_po_loc_id
          AND ploc.ship_to_organization_id = mp.organization_id;
      END IF; -- ln_po_dist_id IS NULL

      -- According item invoice line num to get distribution quantity that has been transfer to gl
      SELECT
        COUNT(invoice_distribution_id)
      INTO
        ln_invoice_post_num
      FROM
        ap_invoice_distributions_all aida
      WHERE aida.invoice_id = pn_invoice_id
        AND aida.invoice_line_number = ln_invoice_line_num
        AND aida.posted_flag = 'Y';

      -- if only one distribution line has been transfer to GL, then insert inclusive data into GL interface
      IF ln_invoice_post_num = 1
      THEN
        IF lv_match_type = jai_constants.G_AP_STANDALONE_INVOICE
        THEN
          -- Get inclusive tax info from jai_cmn_document_taxes
          -- and insert debit inclusive taxes into GL interface table.
          FOR standalone_inclu_tax_csr IN standalone_inclu_tax_cur(ln_invoice_line_num)
          LOOP
            ln_tax_account_id := get_tax_account_id
                                   ( pn_tax_id   => standalone_inclu_tax_csr.tax_id
                                   , pv_tax_type => standalone_inclu_tax_csr.tax_type
                                   , pn_org_id   => ln_org_id
                                   );
            insert_gl_interface( pn_set_of_books_id               => ln_set_of_books_id
                               , pd_accounting_date               => ld_gl_date
                               , pv_currency_code                 => lv_invoice_currency_code
                               , pn_enter_dr                      => standalone_inclu_tax_csr.tax_amount
                               , pd_transaction_date              => ld_invoice_date
                               , pn_code_combination_id           => ln_tax_account_id
                               , pd_currency_conversion_date      => ld_exchange_date
                               , pv_currency_conversion_type      => lv_exchange_rate_type
                               , pv_currency_conversion_rate      => ln_exchange_rate
                               , pv_reference1                    => lv_inv_org_code
                               , pv_reference10                   => lv_invoice_num
                               , pv_reference23                   => lv_procedure_name
                               , pv_reference26                   => pn_invoice_id
                               , pv_reference27                   => ln_inv_org_id
                               ) ;

            ln_total_inclu_tax_amt := ln_total_inclu_tax_amt + standalone_inclu_tax_csr.tax_amount;
            IF (ln_proc_level >= ln_dbg_level)
            THEN
              FND_LOG.STRING( ln_proc_level
                            , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.debug'
                            , 'Inclusive tax account = '|| ln_tax_account_id
                            );
              FND_LOG.STRING( ln_proc_level
                            , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.debug'
                            , 'Inclusive tax amount = '|| standalone_inclu_tax_csr.tax_amount
                            );
            END IF; --ln_proc_level>=l_dbg_level
          END LOOP; -- for standalone_inclu_tax_cur cursor
        ELSE
          -- Get inclusive tax info from jai_ap_match_inv_taxes
          -- and insert debit inclusive taxes into GL interface table.
          FOR match_inclu_tax_csr IN match_inclu_tax_cur(ln_invoice_line_num)
          LOOP
            ln_tax_account_id := get_tax_account_id
                                   ( pn_tax_id   => match_inclu_tax_csr.tax_id
                                   , pv_tax_type => match_inclu_tax_csr.tax_type
                                   , pn_org_id   => ln_org_id
                                   );
            insert_gl_interface( pn_set_of_books_id               => ln_set_of_books_id
                               , pd_accounting_date               => ld_gl_date
                               , pv_currency_code                 => lv_invoice_currency_code
                               , pn_enter_dr                      => match_inclu_tax_csr.tax_amount
                               , pd_transaction_date              => ld_invoice_date
                               , pn_code_combination_id           => ln_tax_account_id
                               , pd_currency_conversion_date      => ld_exchange_date
                               , pv_currency_conversion_type      => lv_exchange_rate_type
                               , pv_currency_conversion_rate      => ln_exchange_rate
                               , pv_reference1                    => lv_inv_org_code
                               , pv_reference10                   => lv_invoice_num
                               , pv_reference23                   => lv_procedure_name
                               , pv_reference26                   => pn_invoice_id
                               , pv_reference27                   => ln_inv_org_id
                               ) ;

            ln_total_inclu_tax_amt := ln_total_inclu_tax_amt + match_inclu_tax_csr.tax_amount;
            IF (ln_proc_level >= ln_dbg_level)
            THEN
              FND_LOG.STRING( ln_proc_level
                            , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.debug'
                            , 'Inclusive tax account = '|| ln_tax_account_id
                            );
              FND_LOG.STRING( ln_proc_level
                            , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.debug'
                            , 'Inclusive tax amount = '|| match_inclu_tax_csr.tax_amount
                            );
            END IF; --ln_proc_level>=l_dbg_level
          END LOOP; -- for match_inclu_tax_cur cursor
        END IF; -- lv_match_type = 'STANDALONE_INVOICE'

        -- Get item distribution line dist_code_combination_id and amount.
        -- and insert credit data into GL interface table.
        FOR item_line_dist_csr IN item_line_dist_cur(ln_invoice_line_num)
        LOOP
          IF ln_item_line_amt <> 0
          THEN
            ln_cr_line_amt := ( item_line_dist_csr.amount / ln_item_line_amt )
                               * ln_total_inclu_tax_amt;

            insert_gl_interface( pn_set_of_books_id               => ln_set_of_books_id
                               , pd_accounting_date               => ld_gl_date
                               , pv_currency_code                 => lv_invoice_currency_code
                               , pn_enter_cr                      => ln_cr_line_amt
                               , pd_transaction_date              => ld_invoice_date
                               , pn_code_combination_id           => item_line_dist_csr.dist_code_combination_id
                               , pd_currency_conversion_date      => ld_exchange_date
                               , pv_currency_conversion_type      => lv_exchange_rate_type
                               , pv_currency_conversion_rate      => ln_exchange_rate
                               , pv_reference1                    => lv_inv_org_code
                               , pv_reference10                   => lv_invoice_num
                               , pv_reference23                   => lv_procedure_name
                               , pv_reference26                   => pn_invoice_id
                               , pv_reference27                   => ln_inv_org_id
                               ) ;
            ln_total_cr_line_amt := ln_total_cr_line_amt + ln_cr_line_amt;
          END IF; -- ln_item_line_amt <> 0
        END LOOP; -- for item_line_dist_cur cursor

      END IF; -- ln_invoice_post_num = 1

    END IF; -- ln_invoice_line_num > 0

    xv_process_flag := 'SS';
    xv_process_message := 'Inclusive taxes have successed into GL Interface';
  ELSE
    xv_process_flag := 'SS';
    xv_process_message := 'Inclusive taxes not be separately';
  END IF; -- lv_inclu_tax_flag = 'Y'

  --logging for debug
  IF (ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                  , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.end'
                  , 'Exit procedure'
                  );
  END IF; -- (ln_proc_level>=ln_dbg_level)

EXCEPTION
  WHEN OTHERS THEN
    xv_process_flag    := 'UE';
    xv_process_message := 'Exception error in acct_inclu_taxes procedure';

    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                    , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Other_Exception '
                    , Sqlcode||Sqlerrm);
    END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)

END acct_inclu_taxes;

-- Added by Jia Li on tax inclusive computation on 2007/12/17, End

END jai_ap_utils_pkg ;

/
