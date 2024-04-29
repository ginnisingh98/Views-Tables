--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RG_MASTER_ORG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RG_MASTER_ORG_PKG" AS
/* $Header: jai_cmn_rg_mst.plb 120.2.12010000.4 2010/04/06 12:13:12 mbremkum ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Remarks
---------    -------------------------------------------------------------
08-Jun-2005  File Version 116.1 Object is Modified to refer to New DB Entity names
             in place of Old DB Entity Names as required for CASE COMPLAINCE.

14-Jun-2005  rchandan for bug#4428980, Version 116.2
             Modified the object to remove literals from DML statements and CURSORS.

02-Sep-2005  Ramananda for Bug#4589502, File version 120.2
             Proceudre CONSOLIDATE_RG_I
             ==========================
             Changed the statement for opening the cursor - balance_cur

06-Nov-2008  Bug 6118417 (FP for bug 6112850) File version 120.2.12010000.2 / 120.3
             Description : When doing consolidation, the rg23 part 2 records for master
	     organization gets inserted with the creation_date as sysdate. But the RG23
	     part II report is filtering the rows based on creation date. Due to this
	     the report output becomes wrong.
	     Resolution : When populating jai_cmn_rg_23ac_ii_trxs and jai_cmn_rg_others
	     table for the master org, creation_date (and other who columns) are copied from
	     the child org record instead of using the session values.
	     Following procedures are modified:
	     1. consolidate_rg23_part_ii
	     2. insert_rg23_others

Feb 18, 2010 Bug 9382720
             Added Additional CVD as it is not getting consolidated in the Master Org
             Inserted Addl CVD into JAI_CMN_RG_23AC_II_TRXS and JAI_CMN_RG_23AC_I_TRXS

Apr 06, 2010 Bug 9550254
 	         The opening balance for the RG23 Part I has been derived
 	         from the previous financial year closing balance,
 	         if no entries found for the current year.

--------------------------------------------------------------------------------------*/


PROCEDURE insert_rg23_others
(ERRBUF OUT NOCOPY VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2,
 p_previous_serial_no IN JAI_CMN_RG_23AC_II_TRXS.slno%TYPE,
 p_tax_type           IN JAI_CMN_RG_OTHERS.tax_type%TYPE,
 p_register_id        IN JAI_CMN_RG_23AC_II_TRXS.register_id%TYPE)
AS
 Cursor rg_others_cur( p_register_id IN Number, p_tax_type JAI_CMN_RG_OTHERS.tax_type%TYPE ) IS
  Select *
  from   JAI_CMN_RG_OTHERS
  where  source_register_id = p_register_id
  and    source_type        = 1
  and    tax_type           = p_tax_type;

  rg_others_rec rg_others_cur%ROWTYPE ;


BEGIN
 /*------------------------------------------------------------------------------------------
   FILENAME: ja_in_master_org_other_taxes_p.sql

   Harshita J: /**********************************************************************
   CREATED BY       : hjujjuru
   CREATED DATE     : 11-JAN-2005
   ENHANCEMENT BUG  : 4106667
   PURPOSE          : To consolidate the data in the table JAI_CMN_RG_OTHERS as a part of the Master-Org Consolidation
              of JAI_CMN_RG_23AC_II_TRXS table
   CALLED FROM      : Called from the Concurrent -  Master Org RG Entries Request Set

**********************************************************************/
 /*

   CHANGE HISTORY:

   1. 2005/01/28  Harshita.J - For Bug #410667 Version -  115.0
          Base Bug has been changed.
          Base Bug #4146708. This bug creates all the database objects.

   1. 2005/02/03  Harshita.J - For Bug #410667 Version -  115.1
          Incorrect phase information has been entered in the phase comment during the
          previous check in. This has been updated.


 --------------------------------------------------------------------------------------------*/

  -- Get the details of the existing record
   OPEN  rg_others_cur(p_register_id, p_tax_type);
   FETCH rg_others_cur INTO rg_others_rec;

   IF rg_others_cur%FOUND THEN
    insert into JAI_CMN_RG_OTHERS
    (
    rg_other_id,
    source_type,
    source_register,
    source_register_id,
    tax_type,
    credit,
    debit,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
    )
    values
    (
    -rg_others_rec.rg_other_id,
    rg_others_rec.source_type,
    rg_others_rec.source_register,
    -rg_others_rec.source_register_id,
    rg_others_rec.tax_type,
    rg_others_rec.credit,
    rg_others_rec.debit,
    /*start changes for bug 6118417 (FP for bug 6112850)*/
    rg_others_rec.created_by,  --FND_GLOBAL.USER_ID,
    rg_others_rec.creation_date,  --SYSDATE,
    rg_others_rec.last_updated_by,  --FND_GLOBAL.USER_ID,
    rg_others_rec.last_update_date  --SYSDATE
    /*end bug 6118417*/
    );

  END IF ;

  CLOSE rg_others_cur;

-- RETCODE := '0';
-- ERRBUF := NULL;
EXCEPTION
 WHEN OTHERS THEN

 IF rg_others_cur%ISOPEN then
    close rg_others_cur;
 end if;
 RETCODE := '2' ;
 ERRBUF  := ' Error Encountered in - jai_cmn_rg_master_org_pkg.insert_rg23_others  ' || substr(SQLERRM,1,1000);
END insert_rg23_others;


PROCEDURE insert_pla_others
(ERRBUF OUT NOCOPY VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2,
 p_previous_serial_no IN JAI_CMN_RG_PLA_TRXS.slno%TYPE,
 p_tax_type           IN JAI_CMN_RG_OTHERS.tax_type%TYPE,
 p_register_id        IN JAI_CMN_RG_PLA_TRXS.register_id%TYPE)
AS

  Cursor rg_others_cur( p_register_id IN Number, p_tax_type JAI_CMN_RG_OTHERS.tax_type%TYPE ) IS
  Select * from JAI_CMN_RG_OTHERS
  where source_register_id =  p_register_id
  and source_type = 2
  and tax_type = p_tax_type;

  rg_others_rec rg_others_cur%ROWTYPE ;


BEGIN

 /*------------------------------------------------------------------------------------------
   FILENAME: jai_cmn_rg_master_org_pkg.sql
   Harshita J: /**********************************************************************
      CREATED BY       : hjujjuru
      CREATED DATE     : 11-JAN-2005
      ENHANCEMENT BUG  : 4106667
      PURPOSE          : To consolidate the data in the table JAI_CMN_RG_OTHERS as a part of the Master-Org Consolidation
                  of JAI_CMN_RG_23AC_II_TRXS table
   CALLED FROM      : Called from the Concurrent -  Master Org RG Entries Request Set

   CHANGE HISTORY:

   1. 2005/01/28  Harshita.J - For Bug #410667 Version -  115.1
              Base Bug has been changed.
          Base Bug #4146708. This bug creates all the database objects.

   --------------------------------------------------------------------------------------------*/



  -- Get the details of the existing record


   OPEN  rg_others_cur(p_register_id, p_tax_type);
   FETCH rg_others_cur INTO rg_others_rec;


  IF rg_others_cur%FOUND THEN

    insert into JAI_CMN_RG_OTHERS
    (
    rg_other_id,
    source_type,
    source_register,
    source_register_id,
    tax_type,
    credit,
    debit,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date
    )
    values
    (
    -rg_others_rec.rg_other_id,
    rg_others_rec.source_type,
    rg_others_rec.source_register,
    -rg_others_rec.source_register_id,
    rg_others_rec.tax_type,
    rg_others_rec.credit,
    rg_others_rec.debit,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    SYSDATE
    );
 END IF ;

 CLOSE rg_others_cur;

 RETCODE := '0';
 ERRBUF := NULL;
EXCEPTION
 WHEN OTHERS THEN

 RETCODE := '2' ;
 ERRBUF := ' Error Encountered in - jai_cmn_rg_master_org_pkg  ' || substr(SQLERRM,1,1000);
 --RAISE_APPLICATION_ERROR(-20001,'This Concurrent Program has ended in an Error ' || SQLERRM);
END insert_pla_others;


PROCEDURE consolidate_rg23_part_i
(errbuf OUT NOCOPY VARCHAR2,
retcode OUT NOCOPY VARCHAR2,
p_organization_id IN NUMBER,
p_location_id IN NUMBER) as

  Cursor master_ec_code_cur(p_organization_id IN NUMBER,  p_location_id IN NUMBER) IS
  Select ec_code
  from   JAI_CMN_INVENTORY_ORGS
  Where  organization_id = p_organization_id
  And    location_id     = nvl(p_location_id,0);
  v_ec_code            Varchar2(50);

  Cursor rg23_part_i_cur(p_register_id IN Number) IS
  Select *
  From   JAI_CMN_RG_23AC_I_TRXS a
  Where  a.register_id     = p_register_id;
  rg23_rec          rg23_part_i_cur%ROWTYPE;

  Cursor rg23_part_i_register_id_cur(p_ec_code IN Varchar2) IS
  Select register_id
  From   JAI_CMN_RG_23AC_I_TRXS a, JAI_CMN_INVENTORY_ORGS b
  Where  ( a.posted_flag IS NULL OR a.posted_flag = 'N' )  --rchandan for bug#4428980
  And    ( a.master_flag IS NULL OR a.master_flag = 'N')   --rchandan for bug#4428980
  And    a.organization_id = b.organization_id
  And    a.location_id     = b.location_id
  And    b.master_org_flag ='N' --Changed by Nagaraj.s for Bug2708516
  And    b.ec_code         = p_ec_code
  Order  by a.Register_Id;


  Cursor serial_no_cur(p_organization_id IN Number, p_location_id IN Number, p_inventory_item_id IN Number,
                      p_fin_year IN Number, p_register_type Char) IS
  Select nvl(MAX(slno),0) , nvl(MAX(slno),0) + 1
  From   JAI_CMN_RG_23AC_I_TRXS
  Where  organization_id = p_organization_id
  And    location_id    = nvl(p_location_id,0)
  And    inventory_item_id = p_inventory_item_id
  And    fin_year = p_fin_year
  And    register_type = p_register_type;
  --And    nvl(master_flag,'N') = 'Y'; --Commented by Nagaraj.s for Bug2708516

  v_previous_serial_no          Number  := 0;
  v_serial_no               Number  := 0;

  Cursor opening_balance_qty_cur(p_previous_serial_no IN NUMBER, p_organization_id IN Number, p_location_id IN Number,
                      p_inventory_item_id IN Number,p_fin_year IN Number, p_register_type Char) IS
  Select nvl(opening_balance_qty,0), nvl(closing_balance_qty,0)
  From   JAI_CMN_RG_23AC_I_TRXS
  Where  slno = p_previous_serial_no
  And    organization_id = p_organization_id
  And    location_id = nvl(p_location_id,0)
  And    register_type = p_register_type
  And    fin_year = p_fin_year
  And    inventory_item_id = p_inventory_item_id;
  --And    nvl(master_flag,'N') = 'Y'; --Commented by Nagaraj.s for Bug2708516

  v_opening_balance_qty         Number  := 0;
  v_transaction_quantity        Number  := 0;
  v_closing_balance_qty           Number    := 0;
  v_debug_flag  VARCHAR2 (1);  -- char(1) :='Y'; --Added by Nagaraj.s for Bug2708516  (For File.Sql.35 by Brathod)
  lv_remarks jai_cmn_rg_23ac_i_trxs.remarks%TYPE ;


Begin
 /*------------------------------------------------------------------------------------------
     FILENAME: jai_cmn_rg_master_org_pkg.consolidate_rg23_part_i.sql
     CHANGE HISTORY:

     1.  2002/12/14   Nagaraj.s - For BUG#2708516 Version - 615.1
                      Ideally In Master Organization, no transactions should happen
                      and only Consolidation needs to happen.
                      But since Transactions are bound to happen and no check
                      exists across the Localization objects, hence the following changes
                      are done.
                      1. rg23_part_ii_register_id_cur has been incorporated with a new condition
                      that the Consolidation should happen only for Child Organizations.
                      2. serial_no_cur has been commented with a condition And    nvl(master_flag,'N') = 'Y'
                      3. opening_balance_cur has been commented with a condition And nvl(master_flag,'N') = 'Y';


    --------------------------------------------------------------------------------------------*/

  v_debug_flag :='Y'; -- File.Sql.35 by Brathod

  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '*************************** START OF LOG FILE ****************************************');
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.0 The Organization Id is ' || p_organization_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.1 The Location Id is ' || p_location_id);
  end if;

  OPEN  master_ec_code_cur(p_organization_id, nvl(p_location_id,0));
  FETCH master_ec_code_cur INTO v_ec_code;
  CLOSE master_ec_code_cur;

  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.2 The EC Code is ' || v_ec_code);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.3 ************** Before the Main Loop ********************');
  end if;

  For rg23_reg_rec IN rg23_part_i_register_id_cur(v_ec_code)
  Loop
    OPEN  rg23_part_i_cur(rg23_reg_rec.register_id);
    FETCH rg23_part_i_cur INTO rg23_rec;
    CLOSE rg23_part_i_cur;

    if v_debug_flag = 'Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, '1.4 The Register Id is  ' || rg23_reg_rec.register_id);
    end if;

    /*Bug 9550254 - Start*/
    /*
    OPEN  serial_no_cur(p_organization_id, nvl(p_location_id,0), rg23_rec.inventory_item_id, rg23_rec.fin_year,
                        rg23_rec.register_type);
    FETCH serial_no_cur INTO v_previous_serial_no, v_serial_no;
    CLOSE serial_no_cur;
    */

    v_opening_balance_qty := jai_om_rg_pkg.ja_in_rg23i_balance(p_organization_id,nvl(p_location_id,0),rg23_rec.inventory_item_id,
                                                               rg23_rec.fin_year,rg23_rec.register_type,v_previous_serial_no);
    /*Bug 9550254 - End*/

    if v_debug_flag = 'Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, '1.5 The v_previous_serial_no is  ' || v_previous_serial_no);
     FND_FILE.PUT_LINE(FND_FILE.LOG, '1.6 The v_serial_no is  ' || v_serial_no);
    end if;

    IF nvl(v_previous_serial_no, 0) = 0  -- Bug 9550254 - Added NVL
    THEN
      -- v_opening_balance_qty := 0;
      -- v_closing_balance_qty := rg23_rec.closing_balance_qty;
      v_serial_no := 1; -- Added for Bug 9550254
      v_transaction_quantity := nvl(rg23_rec.closing_balance_qty,0) - nvl(rg23_rec.opening_balance_qty,0);-- Added for Bug 9550254
 	  v_closing_balance_qty := v_transaction_quantity + v_opening_balance_qty; -- Added for Bug 9550254
    ELSE
      v_serial_no := v_previous_serial_no + 1; -- Added for Bug 9550254
      OPEN  opening_balance_qty_cur(v_previous_serial_no, p_organization_id, nvl(p_location_id,0), rg23_rec.inventory_item_id,
                                  rg23_rec.fin_year, rg23_rec.register_type);
      FETCH opening_balance_qty_cur INTO v_opening_balance_qty, v_closing_balance_qty;
      CLOSE opening_balance_qty_cur;

      v_transaction_quantity := nvl(rg23_rec.closing_balance_qty,0) - nvl(rg23_rec.opening_balance_qty,0);

      v_opening_balance_qty := v_closing_balance_qty;
      v_closing_balance_qty := nvl(v_opening_balance_qty,0) + nvl(v_transaction_quantity,0);
    END IF;

    if v_debug_flag = 'Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, '1.7 The v_opening_balance_qty is  ' || v_opening_balance_qty);
     FND_FILE.PUT_LINE(FND_FILE.LOG, '1.8 The v_closing_balance_qty is  ' || v_closing_balance_qty);
    end if;
    lv_remarks := rg23_rec.remarks || ' Master Org';--rchandan for bug#4428980
    INSERT INTO JAI_CMN_RG_23AC_I_TRXS
      (register_id,
       fin_year,
       slno,
       TRANSACTION_SOURCE_NUM,
       inventory_item_id,
       organization_id,
       quantity_received,
       RECEIPT_REF,
       transaction_type,
       receipt_date,
       range_no,
       division_no,
       po_header_id,
       po_header_date,
       po_line_id,
       po_line_location_id,
       vendor_id,
       vendor_site_id,
       customer_id,
       customer_site_id,
       GOODS_ISSUE_ID_REF,
       goods_issue_date,
       goods_issue_quantity,
       SALES_INVOICE_NO,
       sales_invoice_quantity,
       EXCISE_INVOICE_NO,
       excise_invoice_date,
       OTH_RECEIPT_ID_REF,
       oth_receipt_quantity,
       oth_receipt_date,
       register_type,
       identification_no,
       identification_mark,
       brand_name,
       date_of_verification,
       date_of_installation,
       date_of_commission,
       REGISTER_ID_PART_II,
       additional_cvd,                  -- Bug 9382720 - Added Additional CVD as it is not getting consolidated in the Master Org
       place_of_install,
       remarks,
       location_id,
       primary_uom_code,
       transaction_uom_code,
       transaction_date,
       basic_ed,
       other_ed,
       additional_ed,
       opening_balance_qty,
       closing_balance_qty,
       charge_account_id,
       posted_flag,
       master_flag,
       creation_date,
       created_by,
       last_update_login,
       last_update_date,
       last_updated_by)
    VALUES
       (
       -rg23_rec.register_id,
       rg23_rec.fin_year,
       v_serial_no,
       rg23_rec.TRANSACTION_SOURCE_NUM,
       rg23_rec.inventory_item_id,
       p_organization_id,
       rg23_rec.quantity_received,
       rg23_rec.receipt_ref,
       rg23_rec.transaction_type,
       rg23_rec.receipt_date,
       rg23_rec.range_no,
       rg23_rec.division_no,
       rg23_rec.po_header_id,
       rg23_rec.po_header_date,
       rg23_rec.po_line_id,
       rg23_rec.po_line_location_id,
       rg23_rec.vendor_id,
       rg23_rec.vendor_site_id,
       rg23_rec.customer_id,
       rg23_rec.customer_site_id,
       rg23_rec.goods_issue_id_ref,
       rg23_rec.goods_issue_date,
       rg23_rec.goods_issue_quantity,
       rg23_rec.sales_invoice_no,
       rg23_rec.sales_invoice_quantity,
       rg23_rec.excise_invoice_no,
       rg23_rec.excise_invoice_date,
       rg23_rec.OTH_RECEIPT_ID_REF,
       rg23_rec.oth_receipt_quantity,
       rg23_rec.oth_receipt_date,
       rg23_rec.register_type,
       rg23_rec.identification_no,
       rg23_rec.identification_mark,
       rg23_rec.brand_name,
       rg23_rec.date_of_verification,
       rg23_rec.date_of_installation,
       rg23_rec.date_of_commission,
       -rg23_rec.REGISTER_ID_PART_II,
       rg23_rec.additional_cvd,         -- Bug 9382720 - Added Additional CVD as it is not getting consolidated in the Master Org
       rg23_rec.place_of_install,
       lv_remarks,              --rchandan for bug#4428980
       nvl(p_location_id,0),
       rg23_rec.primary_uom_code,
       rg23_rec.transaction_uom_code,
       rg23_rec.transaction_date,
       rg23_rec.basic_ed,
       rg23_rec.other_ed,
       rg23_rec.additional_ed,
       v_opening_balance_qty,  ----Changed by Nagaraj.s for Bug2708516 Previously : rg23_rec.opening_balance_qty
       v_closing_balance_qty, --Changed by Nagaraj.s for Bug2708516 Previously : rg23_rec.closing_balance_qty
       rg23_rec.charge_account_id,
       'N',
       'Y',
       sysdate,
       rg23_rec.created_by,
       rg23_rec.last_update_login,
       rg23_rec.last_update_date,
       rg23_rec.last_updated_by);

    UPDATE JAI_CMN_RG_23AC_I_TRXS
    SET    posted_flag = 'Y',
           master_flag = 'N'
    WHERE  register_id = rg23_rec.register_id;

  End Loop;

  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '*************************** END OF LOG FILE ****************************************');
  end if;

  --Exception added by Nagaraj.s for Bug2708516
Exception
 WHEN OTHERS THEN
 RAISE_APPLICATION_ERROR(-20001,'This Concurrent Program has ended in an Error ' || SQLERRM);
End consolidate_rg23_part_i;


PROCEDURE consolidate_rg23_part_ii
(ERRBUF OUT NOCOPY VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2,
 p_organization_id IN NUMBER,
 p_location_id IN NUMBER) as

  Cursor master_ec_code_cur(p_organization_id IN NUMBER,  p_location_id IN NUMBER) IS
  Select ec_code
  from   JAI_CMN_INVENTORY_ORGS
  Where  organization_id = p_organization_id
  And    location_id     = nvl(p_location_id,0);
  v_ec_code            Varchar2(50);

  Cursor rg23_part_ii_cur(p_register_id IN Number) IS
  Select *
  From   JAI_CMN_RG_23AC_II_TRXS a
  Where  a.register_id     = p_register_id;
  rg23_rec        rg23_part_ii_cur%ROWTYPE;

  Cursor rg23_part_ii_register_id_cur(p_ec_code IN Varchar2) IS
  Select register_id
  From   JAI_CMN_RG_23AC_II_TRXS a, JAI_CMN_INVENTORY_ORGS b
  Where  ( a.posted_flag IS NULL OR a.posted_flag = 'N' )  --rchandan for bug#4428980
  And    ( a.master_flag IS NULL OR a.master_flag = 'N' )  --rchandan for bug#4428980
  And    a.organization_id = b.organization_id
  And    a.location_id     = b.location_id
  And    b.master_org_flag ='N' --Changed by Nagaraj.s for Bug2636714
  And    b.ec_code         = p_ec_code
  Order  by a.Register_Id;


  Cursor serial_no_cur(p_organization_id IN Number, p_location_id IN Number,
                      p_fin_year IN Number, p_register_type Char) IS
  Select nvl(MAX(slno),0) , nvl(MAX(slno),0) + 1
  From   JAI_CMN_RG_23AC_II_TRXS
  Where  organization_id = p_organization_id
  And    location_id  = nvl(p_location_id,0)
  And    fin_year = p_fin_year
  And    register_type = p_register_type;
  --And    nvl(master_flag,'N') = 'Y';--Commented by Nagaraj.s for Bug2636714
  v_previous_serial_no      JAI_CMN_RG_23AC_II_TRXS.slno%TYPE  := 0;
  v_serial_no       JAI_CMN_RG_23AC_II_TRXS.slno%TYPE  := 0;

  Cursor opening_balance_cur(p_previous_serial_no IN NUMBER, p_organization_id IN Number, p_location_id IN Number,
                      p_fin_year IN Number, p_register_type Char) IS
  Select nvl(opening_balance,0), nvl(closing_balance,0)
  From   JAI_CMN_RG_23AC_II_TRXS
  Where  slno = p_previous_serial_no
  And    organization_id = p_organization_id
  And    location_id = nvl(p_location_id,0)
  And    register_type = p_register_type
  And    fin_year = p_fin_year ;
  --And    nvl(master_flag,'N') = 'Y';--Commented by Nagaraj.s for Bug2636714

  --Added by Nagaraj.s for Bug2636714
  Cursor c_fetch_fin_active_year(p_organization_id IN  number) IS
  SELECT FIN_YEAR FROM
  JAI_CMN_FIN_YEARS
  WHERE ORGANIZATION_ID=p_organization_id
  and   FIN_ACTIVE_FLAG='Y';

  Cursor c_final_balance_rg23(p_organization_id IN NUMBER,p_location_id IN NUMBER,p_fin_year IN NUMBER,P_REGISTER_TYPE CHAR) IS
  SELECT NVL(CLOSING_BALANCE,0)
  FROM JAI_CMN_RG_23AC_II_TRXS
  WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
  AND   LOCATION_ID     = P_LOCATION_ID
  AND   REGISTER_TYPE   = P_REGISTER_TYPE
  AND   FIN_YEAR = P_FIN_YEAR
  AND   SLNO IN
               (SELECT NVL(MAX(SLNO),0) FROM JAI_CMN_RG_23AC_II_TRXS
                 WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                 AND LOCATION_ID = P_LOCATION_ID
                 AND FIN_YEAR    = P_FIN_YEAR
                 AND REGISTER_TYPE =P_REGISTER_TYPE);


  v_opening_balance                 Number  := 0;
  v_transaction_balance     Number  := 0;
  v_closing_balance                 Number  := 0;
  v_debug_flag                  varchar2(1); -- :='Y' --Added by Nagaraj.s for Bug2636714  File.Sql.35 by Brathod
  v_fin_active_year  NUMBER;
  v_rg23a_final_balance NUMBER;
  v_rg23c_final_balance NUMBER;
  lv_buffer varchar2(1996) ;
  lv_retcode varchar2(100);

Begin
 /*------------------------------------------------------------------------------------------
   FILENAME: jai_cmn_rg_master_org_pkg.consolidate_rg23_part_ii.sql
   CHANGE HISTORY:

     1.  2002/12/09   Nagaraj.s - For BUG#2636714 Version - 615.1
                      Ideally In Master Organization, no transactions should happen
                      and only Consolidation needs to happen.
                      But since Transactions are bound to happen and no check
                      exists across the Localization objects, hence the following changes
                      are done.
                      1. rg23_part_ii_register_id_cur has been incorporated with a new condition
                      that the Consolidation should happen only for Child Organizations.
                      2. serial_no_cur has been commented with a condition And    nvl(master_flag,'N') = 'Y'
                      3. opening_balance_cur has been commented with a condition And nvl(master_flag,'N') = 'Y';
                      4. A new cursor is added to fetch the Active Financial Year(c_fetch_fin_active_year).
                      5. A new Cusor is added to fetch the Closing Balance of RG23A and RG23C Registers
                      (c_final_balance_rg23)
                      6. Updation of JAI_CMN_RG_BALANCES is done for Master Organization/Location.

    2. 2005/01/07     Harshita.J - For Bug #410667 Version -  115.0
                      Master Org Consolidation has been implemented for CESS taxes and any other new
                      tax types that may be added in future.
                      Procedure jai_cmn_rg_master_org_pkg.insert_rg23_others is called for each record that has been consolidated
                      with the master to consolidate the taxes for CESS.
                      Base Bug #4106633

   3. 2005/01/28    Harshita.J - For Bug #410667 Version -  115.1
            Base Bug has been changed.
                Base Bug #4146708. This bug creates all the database objects.


  --------------------------------------------------------------------------------------------*/
  v_debug_flag := 'Y';  -- File.Sql.35 by Brathod

  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '*************************** START OF LOG FILE ****************************************');
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.0 The Organization Id is ' || p_organization_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.1 The Location Id is ' || p_location_id);
  end if;
  OPEN  master_ec_code_cur(p_organization_id, nvl(p_location_id,0));
  FETCH master_ec_code_cur INTO v_ec_code;
  CLOSE master_ec_code_cur;

  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.2 The EC Code is ' || v_ec_code);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.3 ************** Before the Main Loop ********************');
  end if;

  For rg23_reg_rec IN rg23_part_ii_register_id_cur(v_ec_code)
  Loop

    OPEN  rg23_part_ii_cur(rg23_reg_rec.register_id);
    FETCH rg23_part_ii_cur INTO rg23_rec;
    CLOSE rg23_part_ii_cur;

    if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.4 The Register Id is  ' || rg23_reg_rec.register_id);
    end if;

    OPEN  serial_no_cur(p_organization_id, nvl(p_location_id,0), rg23_rec.fin_year, rg23_rec.register_type);
    FETCH serial_no_cur INTO v_previous_serial_no, v_serial_no;
    CLOSE serial_no_cur;

    if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.5 The v_previous_serial_no is  ' || v_previous_serial_no);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.6 The v_serial_no is  ' || v_serial_no);
    end if;

    IF v_previous_serial_no = 0
    THEN
      v_opening_balance := 0;
      v_closing_balance := rg23_rec.closing_balance;
    ELSE
      OPEN  opening_balance_cur(v_previous_serial_no, p_organization_id, nvl(p_location_id,0), rg23_rec.fin_year, rg23_rec.register_type);
      FETCH opening_balance_cur INTO v_opening_balance, v_closing_balance;
      CLOSE opening_balance_cur;

      v_transaction_balance := nvl(rg23_rec.closing_balance,0) - nvl(rg23_rec.opening_balance,0);
      v_opening_balance := v_closing_balance;
      v_closing_balance := nvl(v_opening_balance,0) + nvl(v_transaction_balance,0);
    END IF;
    if v_debug_flag = 'Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, '1.7 The v_opening_balance is  ' || v_opening_balance);
     FND_FILE.PUT_LINE(FND_FILE.LOG, '1.8 The v_closing_balance is  ' || v_closing_balance);
    end if;

    INSERT INTO JAI_CMN_RG_23AC_II_TRXS (register_id,
                                    fin_year,
                                    slno,
                                    TRANSACTION_SOURCE_NUM,
                                    inventory_item_id,
                                    organization_id,
                                    RECEIPT_REF,
                                    receipt_date,
                                    range_no,
                                    division_no,
                                    cr_basic_ed,
                                    cr_additional_Ed,
                                    cr_other_ed,
                                    dr_basic_ed,
                                    dr_additional_ed,
                                    dr_other_ed,
                                    excise_invoice_no,
                                    excise_invoice_date,
                                    register_type,
                                    remarks,
                                    vendor_id,
                                    vendor_site_id,
                                    customer_id,
                                    customer_site_id,
                                    location_id,
                                    transaction_date,
                                    opening_balance,
                                    closing_balance,
                                    charge_account_id,
                                    register_id_part_i,
                                    posted_flag,
                                    master_flag,
                                    creation_date,
                                    created_by,
                                    last_update_date,
                                    last_updated_by,
                                    last_update_login,
                                    other_tax_credit,
                                    other_tax_debit,
                                    -- Bug 9382720 - Added Additional CVD as it is not getting consolidated in the Master Org
                                    additional_cvd_amt,
                                    cr_additional_cvd,
                                    dr_additional_cvd
                                    )
               VALUES
                                    (
                                     -rg23_rec.register_id,
                                     rg23_rec.fin_year,
                                     v_serial_no,
                                     rg23_rec.transaction_source_num,
                                     rg23_rec.inventory_item_id,
                                     p_organization_id,
                                     rg23_rec.receipt_ref,
                                     rg23_rec.receipt_date,
                                     rg23_rec.range_no,
                                     rg23_rec.division_no,
                                     rg23_rec.cr_basic_ed,
                                     rg23_rec.cr_additional_Ed,
                                     rg23_rec.cr_other_ed,
                                     rg23_rec.dr_basic_ed,
                                     rg23_rec.dr_additional_ed,
                                     rg23_rec.dr_other_ed,
                                     rg23_rec.excise_invoice_no,
                                     rg23_rec.excise_invoice_date,
                                     rg23_rec.register_type,
                                     rg23_rec.remarks,
                                     rg23_rec.vendor_id,
                                     rg23_rec.vendor_site_id,
                                     rg23_rec.customer_id,
                                     rg23_rec.customer_site_id,
                                     nvl(p_location_id,0),
                                     rg23_rec.transaction_date,
                                     v_opening_balance,
                                     v_closing_balance,
                                     rg23_rec.charge_account_id,
                                     -rg23_rec.register_id_part_i,
                                     'N',
                                     'Y',
                                      rg23_rec.creation_date, --sysdate,/*changed for bug 6118417 (FP for bug 6112850)*/
                                      rg23_rec.created_by,
                                      rg23_rec.last_update_date,
                                      rg23_rec.last_updated_by,
                                      rg23_rec.last_update_login,
                                      rg23_rec.other_tax_credit,
                                      rg23_rec.other_tax_debit,
                                      -- Bug 9382720 - Added Additional CVD as it is not getting consolidated in the Master Org
                                      rg23_rec.additional_cvd_amt,
                                      rg23_rec.cr_additional_cvd,
                                      rg23_rec.dr_additional_cvd  );
    if v_debug_flag = 'Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, '1.9 After Insert into JAI_CMN_RG_23AC_II_TRXS table');
     FND_FILE.PUT_LINE(FND_FILE.LOG, '2.0 After the Register id is Processed' );
    end if;

    UPDATE JAI_CMN_RG_23AC_II_TRXS
    SET    posted_flag = 'Y',
           master_flag = 'N'
    WHERE  register_id = rg23_rec.register_id;

  -- added by hjujjuru for #Bug 4106667

  FOR tax_types_rec IN
  (select tax_type
   from   JAI_CMN_RG_OTHERS
   where  source_register_id =  rg23_rec.register_id
   and    source_type = 1
  )
  LOOP
    if v_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, '1.812 . Before calling other taxes  ');
    end if;
    jai_cmn_rg_master_org_pkg.insert_rg23_others
    (errbuf               => lv_buffer,
     retcode              => lv_retcode,
     p_previous_serial_no => v_previous_serial_no,
     p_tax_type           => tax_types_rec.tax_type,
     p_register_id        => rg23_rec.register_id )  ;

    if v_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, '1.812 . After calling other taxes   with status = ' || lv_retcode);
       FND_FILE.PUT_LINE(FND_FILE.LOG, '1.812 . After calling other taxes   with error  = ' || lv_buffer);
    end if;




     if nvl(lv_retcode,'0') <> '0' then  /* if not success then get out the loop */
        if v_debug_flag = 'Y' THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG, '1.80 . Error is   ' || lv_buffer || ' Halting the processing ...   ');
        end if;
        ERRBUF := lv_buffer ;
        goto errhandling_block; /* Halt the processing and no more records would get processed. */
     end if;
  END LOOP ;

  -- ended by hjujjuru for #Bug 4106667

    if v_debug_flag = 'Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, '*******************************************************************');
    end if;

  End Loop;

  --Added by Nagaraj.s for Bug263674
  OPEN c_fetch_fin_active_year(p_organization_id);
  FETCH c_fetch_fin_active_year into v_fin_active_year;
  CLOSE c_fetch_fin_active_year;

  OPEN c_final_balance_rg23(p_organization_id,p_location_id,v_fin_active_year,'A');
  FETCH c_final_balance_rg23 INTO v_rg23a_final_balance;
  CLOSE c_final_balance_rg23;

  OPEN c_final_balance_rg23(p_organization_id,p_location_id,v_fin_active_year,'C');
  FETCH c_final_balance_rg23 INTO v_rg23c_final_balance;
  CLOSE c_final_balance_rg23;

  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.7 The v_rg23a_final_balance is  ' || v_rg23a_final_balance);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.8 The v_rg23c_final_balance is  ' || v_rg23c_final_balance);
  end if;
  UPDATE JAI_CMN_RG_BALANCES
  SET RG23A_BALANCE = v_rg23a_final_balance, RG23C_BALANCE=v_rg23c_final_balance
  where organization_id=p_organization_id
  and   location_id    =p_location_id;
   --Ends here.....
  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '*************************** END OF LOG FILE ****************************************');
  end if;
  --Exception added by Nagaraj.s for Bug263674

  retcode := '0';
  ERRBUF := NULL;
  return;
<<errhandling_block>>
  Rollback; /* Rolling back because there was some problem */
  RETCODE  := '2';
  if v_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'in the err handling block  ' || lv_buffer );
  end if;
Exception
 WHEN OTHERS THEN

 RETCODE := '2' ;
 RAISE_APPLICATION_ERROR(-20001,'This Concurrent Program has ended in an Error ' || SQLERRM);
  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception !!!! ' || SQLERRM );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception !!!! ' || SQLERRM );
  end if;
End consolidate_rg23_part_ii;

PROCEDURE consolidate_pla
(ERRBUF OUT NOCOPY VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2,
 p_organization_id IN NUMBER,
 p_location_id IN NUMBER) as

  Cursor master_ec_code_cur(p_organization_id IN NUMBER,  p_location_id IN NUMBER) IS
  Select ec_code
  from   JAI_CMN_INVENTORY_ORGS
  Where  organization_id = p_organization_id
  And    location_id     = nvl(p_location_id,0);
  v_ec_code            Varchar2(50);

  Cursor pla_cur(p_register_id IN Number) IS
  Select *
  From   JAI_CMN_RG_PLA_TRXS a
  Where  a.register_id     = p_register_id;
  pla_rec         pla_cur%ROWTYPE;

  Cursor pla_register_id_cur(p_ec_code IN Varchar2) IS
  Select register_id
  From   JAI_CMN_RG_PLA_TRXS a, JAI_CMN_INVENTORY_ORGS b
  Where  ( a.posted_flag IS NULL OR a.posted_flag = 'N' )   --rchandan for bug#4428980
  And    ( a.master_flag IS NULL OR a.master_flag = 'N' )   --rchandan for bug#4428980
  And    a.organization_id = b.organization_id
  And    a.location_id     = b.location_id
  And    b.master_org_flag ='N' --Changed by Nagaraj.s for Bug2708514
  And    b.ec_code         = p_ec_code
  Order  by a.Register_Id;


  Cursor serial_no_cur(p_organization_id IN Number, p_location_id IN Number,
                      p_fin_year IN Number /*, p_register_type Char */ ) IS
  Select nvl(MAX(slno),0) , nvl(MAX(slno),0) + 1
  From   JAI_CMN_RG_PLA_TRXS
  Where  organization_id = p_organization_id
  And    location_id  = nvl(p_location_id,0)
  And    fin_year = p_fin_year ;
--  And    register_type = p_register_type
--  And    nvl(master_flag,'N') = 'Y'; --Commented by Nagaraj.s for Bug2708514
  v_previous_serial_no      Number  := 0;
  v_serial_no       Number  := 0;

  Cursor opening_balance_cur(p_previous_serial_no IN NUMBER, p_organization_id IN Number, p_location_id IN Number,
                      p_fin_year IN Number /*, p_register_type Char*/ ) IS
  Select nvl(opening_balance,0), nvl(closing_balance,0)
  From   JAI_CMN_RG_PLA_TRXS
  Where  slno = p_previous_serial_no
  And    organization_id = p_organization_id
  And    location_id = nvl(p_location_id,0)
--  And    register_type = p_register_type
  And    fin_year = p_fin_year;
  --And    nvl(master_flag,'N') = 'Y';--Commented by Nagaraj.s for Bug2708514

    --Added by Nagaraj.s for Bug2708514
    Cursor c_fetch_fin_active_year(p_organization_id IN  number) IS
    SELECT FIN_YEAR FROM
    JAI_CMN_FIN_YEARS
    WHERE ORGANIZATION_ID=p_organization_id
    and   FIN_ACTIVE_FLAG='Y';

    Cursor c_final_balance_pla(p_organization_id IN NUMBER,p_location_id IN NUMBER,p_fin_year IN NUMBER) IS
    SELECT NVL(CLOSING_BALANCE,0)
    FROM JAI_CMN_RG_PLA_TRXS
    WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
    AND   LOCATION_ID     = P_LOCATION_ID
    AND   FIN_YEAR        = P_FIN_YEAR
    AND   SLNO IN
                 (SELECT NVL(MAX(SLNO),0) FROM JAI_CMN_RG_PLA_TRXS
                   WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                   AND LOCATION_ID = P_LOCATION_ID
                   AND FIN_YEAR    = P_FIN_YEAR
                 );

  v_opening_balance                 Number  := 0;
  v_transaction_balance             Number  := 0;
  v_closing_balance               Number  := 0;
  v_debug_flag                  varchar2(1); --:='Y'; --Added by Nagaraj.s for Bug2708514  File.Sql.35 by Brathod
  v_pla_balance                     NUMBER  :=0;
  v_fin_active_year  NUMBER;
  v_record_count            number :=0; --3335814
  lv_buffer varchar2(1996) ; --  4106667
  lv_retcode varchar2(100);  --  4106667


Begin
 /*------------------------------------------------------------------------------------------
   FILENAME: ja_in_master_organizationpla_p.sql
   CHANGE HISTORY:

     1.  2002/12/14   Nagaraj.s - For Bug#2708514 Version - 615.1
                      Ideally In Master Organization, no transactions should happen
                      and only Consolidation needs to happen.
                      But since Transactions are bound to happen and no check
                      exists across the Localization objects, hence the following changes
                      are done.
                      1. pla_register_id_cur has been incorporated with a new condition
                      that the Consolidation should happen only for Child Organizations.
                      2. serial_no_cur has been commented with a condition And    nvl(master_flag,'N') = 'Y'
                      3. opening_balance_cur has been commented with a condition And nvl(master_flag,'N') = 'Y';
                      4. A new cursor is added to fetch the Active Financial Year(c_fetch_fin_active_year).
                      5. A new Cusor is added to fetch the Closing Balance of RG23A and RG23C Registers
                      (c_final_balance_pla)
                      6. Updation of JAI_CMN_RG_BALANCES.pla_balance is done for Master Organization/Location.


  2.  2003/12/30   Nagaraj.s for Bug#3335814. Version - 618.1

           In scenarios where Master Org records is not present and not processed, and if
           no data existed for Organization, Location, Present Financial Year, then the
           Updation of JAI_CMN_RG_BALANCES was going wrong.

           This has been rectified by ensuring that the updation of JAI_CMN_RG_BALANCES
           happens only if child records are present and processed. Hence now a record count
           is kept of the records processed in the loop and if the record count > 0 only
           then the updation of JAI_CMN_RG_BALANCES would happen.

3. 2005/01/07    Harshita.J - For Bug #410667 Version - 115.0
         Master Org Consolidation has been implemented for CESS taxes and any other new
         tax types that may be added in future.
         Procedure jai_cmn_rg_master_org_pkg.insert_rg23_others is called for each record that has been consolidated
                 with the master to consolidate the taxes for CESS.
                 Base Bug #4106633

 3. 2005/01/28    Harshita.J - For Bug #410667 Version -  115.1
          Base Bug has been changed.
          Base Bug #4146708. This bug creates all the database objects.

  --------------------------------------------------------------------------------------------*/

  v_debug_flag :='Y';  -- File.Sql.35 by Brathod
  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '*************************** START OF LOG FILE ****************************************');
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.0 The Organization Id is ' || p_organization_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.1 The Location Id is ' || p_location_id);
  end if;

  OPEN  master_ec_code_cur(p_organization_id, nvl(p_location_id,0));
  FETCH master_ec_code_cur INTO v_ec_code;
  CLOSE master_ec_code_cur;

  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.2 The EC Code is ' || v_ec_code);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.3 ************** Before the Main Loop ********************');
  end if;

  For pla_reg_rec IN pla_register_id_cur(v_ec_code)
  Loop
    OPEN  pla_cur(pla_reg_rec.register_id);
    FETCH pla_cur INTO pla_rec;
    CLOSE pla_cur;

    if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.4 The Register Id is  ' || pla_reg_rec.register_id);
    end if;

    OPEN  serial_no_cur(p_organization_id, nvl(p_location_id,0), pla_rec.fin_year /*, pla_rec.register_type*/ );
    FETCH serial_no_cur INTO v_previous_serial_no, v_serial_no;
    CLOSE serial_no_cur;

    if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.5 The v_previous_serial_no is  ' || v_previous_serial_no);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.6 The v_serial_no is  ' || v_serial_no);
    end if;

    IF v_previous_serial_no = 0
    THEN
      v_opening_balance := 0;
      v_closing_balance := pla_rec.closing_balance;
    ELSE
      OPEN  opening_balance_cur(v_previous_serial_no, p_organization_id, nvl(p_location_id,0), pla_rec.fin_year /*, rg23_rec.register_type */ );
      FETCH opening_balance_cur INTO v_opening_balance, v_closing_balance;
      CLOSE opening_balance_cur;

      v_transaction_balance := nvl(pla_rec.closing_balance,0) - nvl(pla_rec.opening_balance,0);

      v_opening_balance := v_closing_balance;
      v_closing_balance := nvl(v_opening_balance,0) + nvl(v_transaction_balance,0);
    END IF;
    if v_debug_flag = 'Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, '1.7 The v_opening_balance is  ' || v_opening_balance);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '1.8 The v_closing_balance is  ' || v_closing_balance);
    end if;
    INSERT INTO JAI_CMN_RG_PLA_TRXS (register_id,
                           fin_year,
                           slno,
                           tr6_challan_no,
                           tr6_challan_date,
                           cr_basic_ed,
                           cr_additional_ed,
                           cr_other_ed,
                           TRANSACTION_SOURCE_NUM,
                           ref_document_id,
                           ref_document_date,
                           DR_INVOICE_NO,
                           dr_invoice_date,
                           dr_basic_ed,
                           dr_additional_ed,
                           dr_other_ed,
                           organization_id,
                           location_id,
                           bank_branch_id,
                           entry_date,
                           inventory_item_id,
                           vendor_cust_flag,
                           vendor_id,
                           vendor_site_id,
                           range_no,
                           division_no,
                           excise_invoice_no,
                           remarks,
                           transaction_date,
                           opening_balance,
                           closing_balance,
                           charge_account_id,
                           posted_flag,
                           master_flag,
                           creation_date,
                           created_by,
                           last_update_date,
                           last_updated_by,
                           last_update_login,
                           other_tax_credit,
                           other_tax_debit)
                   VALUES(  -1 * pla_rec.register_id,
                           pla_rec.fin_year,
                           v_serial_no,
                           pla_rec.tr6_challan_no,
                           pla_rec.tr6_challan_date,
                           pla_rec.cr_basic_ed,
                           pla_rec.cr_additional_ed,
                           pla_rec.cr_other_ed,
                           pla_rec.TRANSACTION_SOURCE_NUM,
                           pla_rec.ref_document_id,
                           pla_rec.ref_document_date,
                           pla_rec.DR_INVOICE_NO,
                           pla_rec.dr_invoice_date,
                           pla_rec.dr_basic_ed,
                           pla_rec.dr_additional_ed,
                           pla_rec.dr_other_ed,
                           p_organization_id,
                           nvl(p_location_id,0),
                           pla_rec.bank_branch_id,
                           pla_rec.entry_date,
                           pla_rec.inventory_item_id,
                           pla_rec.vendor_cust_flag,
                           pla_rec.vendor_id,
                           pla_rec.vendor_site_id,
                           pla_rec.range_no,
                           pla_rec.division_no,
                           pla_rec.excise_invoice_no,
                           pla_rec.remarks,
                           pla_rec.transaction_date,
                           v_opening_balance,
                           v_closing_balance,
                           pla_rec.charge_account_id,
                           'N',  --posted_flag,
                           'Y', --master_flag,
                           pla_rec.creation_date,
                           pla_rec.created_by,
                           pla_rec.last_update_date,
                           pla_rec.last_updated_by,
                           pla_rec.last_update_login,
                           pla_rec.other_tax_credit,
                           pla_rec.other_tax_debit);

    UPDATE JAI_CMN_RG_PLA_TRXS
    SET    posted_flag = 'Y',
           master_flag = 'N'
    WHERE  register_id = pla_rec.register_id;

  v_record_count := v_record_count + 1; --3335814

   -- added by hjujjuru for #Bug 4106667


  FOR tax_types_rec IN
  ( select tax_type
    from JAI_CMN_RG_OTHERS
    where
      source_register_id =  pla_rec.register_id
      and  source_type = 2
    )

    LOOP


      jai_cmn_rg_master_org_pkg.insert_pla_others
      ( errbuf               => lv_buffer,
        retcode              => lv_retcode,
        p_previous_serial_no => v_previous_serial_no,
        p_tax_type           => tax_types_rec.tax_type,
        p_register_id        => pla_rec.register_id
      );

      if nvl(lv_retcode,'0') <> '0' then  /* if not success then get out the loop */
         if v_debug_flag = 'Y' THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, '1.80 . Error is   ' || lv_buffer || ' Halting the processing ...   ');
         end if;
         ERRBUF := lv_buffer ;
         goto errhandling_block; /* Halt the processing and no more records would get processed. */
      end if;

    END LOOP ;

  -- ended by hjujjuru for #Bug 4106667

  End Loop;

   if v_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '1.81 The v_record_count is  ' || v_record_count);
   end if;

   if v_record_count >0 then --3335814
     --Added by Nagaraj.s for Bug2708514
     --This Cursor Fetches the Active Financial Year
    OPEN c_fetch_fin_active_year(p_organization_id);
    FETCH c_fetch_fin_active_year into v_fin_active_year;
    CLOSE c_fetch_fin_active_year;

     --This Cursor Fetches the Closing Balance of the Org/Location
    OPEN c_final_balance_pla(p_organization_id,p_location_id,v_fin_active_year);
    FETCH c_final_balance_pla INTO v_pla_balance;
    CLOSE c_final_balance_pla;

    if v_debug_flag = 'Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, '1.82 The v_fin_active_year is  ' || v_fin_active_year);
     FND_FILE.PUT_LINE(FND_FILE.LOG, '1.83 The pla balance that is updated in JAI_CMN_RG_BALANCES is  ' || v_pla_balance);
    end if;

    --This is for Updation of RG Balances table
    UPDATE JAI_CMN_RG_BALANCES
    SET PLA_BALANCE = v_pla_balance
    where organization_id=p_organization_id
    and   location_id    =p_location_id;
  end if; --end if for v_record_count.

     --Ends here.....
  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '*************************** END OF LOG FILE ****************************************');
  end if;

 retcode := '0';
 ERRBUF := NULL;
 return;
<<errhandling_block>>
  Rollback; /* Rolling back because there was some problem */
  RETCODE  := '2';
  --Exception added by Nagaraj.s for Bug2708514
Exception
 WHEN OTHERS THEN
 retcode := '2';
 ERRBUF := substr(sqlerrm,1,950);
 RAISE_APPLICATION_ERROR(-20001,'This Concurrent Program has ended in an Error ' || SQLERRM);
End consolidate_pla;


PROCEDURE consolidate_rg_i
(errbuf OUT NOCOPY VARCHAR2,
 retcode OUT NOCOPY VARCHAR2,
 p_organization_id IN NUMBER,
 p_location_id IN NUMBER )
 AS

    CURSOR master_ec_code_cur(p_organization_id IN NUMBER,  p_location_id IN NUMBER) IS
        SELECT ec_code
        FROM   JAI_CMN_INVENTORY_ORGS
        WHERE  organization_id = p_organization_id
        AND    location_id     = nvl(p_location_id,0);

    CURSOR rgi_register_id_cur(p_ec_code IN VARCHAR2) IS
        SELECT register_id
        FROM   JAI_CMN_RG_I_TRXS a, JAI_CMN_INVENTORY_ORGS b
        WHERE  ( a.posted_flag IS NULL OR a.posted_flag = 'N' )    --rchandan for bug#4428980
        AND    ( a.master_flag IS NULL OR a.master_flag = 'N' )  --rchandan for bug#4428980
        AND    a.organization_id = b.organization_id
        AND    a.location_id     = b.location_id
        And    b.master_org_flag ='N' --Changed by Nagaraj.s for Bug2708518
        AND    b.ec_code         = p_ec_code
        ORDER  BY a.inventory_item_id, a.Register_Id;

    CURSOR rgi_cur(p_register_id IN NUMBER) IS
        SELECT *
        FROM   JAI_CMN_RG_I_TRXS a
        WHERE  a.register_id     = p_register_id;

    CURSOR balance_cur(p_serial_no IN NUMBER, p_organization_id IN Number, p_location_id IN Number,
            p_inventory_item_id IN Number, p_fin_year IN Number) IS
        SELECT NVL(balance_packed, 0), NVL(balance_loose, 0)
            , nvl(manufactured_qty, 0)      -- Vijay Shankar for Bug# 3165687
        FROM   JAI_CMN_RG_I_TRXS
        WHERE  slno = p_serial_no
        AND    organization_id = p_organization_id
        AND    location_id = nvl(p_location_id,0)
        AND    fin_year = p_fin_year
        AND    inventory_item_id = p_inventory_item_id;

    CURSOR c_max_fin_year(p_organization_id IN NUMBER, p_location_id IN NUMBER, p_inventory_item_id NUMBER) IS
        SELECT max(fin_year)
        FROM JAI_CMN_RG_I_TRXS
        WHERE  organization_id = p_organization_id
        AND    location_id  = nvl(p_location_id,0)
        AND    inventory_item_id = p_inventory_item_id;

    CURSOR serial_no_cur(p_organization_id IN NUMBER, p_location_id IN NUMBER, p_inventory_item_id NUMBER, p_fin_year NUMBER) IS
        SELECT nvl(max(slno), 0)
        FROM   JAI_CMN_RG_I_TRXS
        WHERE  organization_id = p_organization_id
        AND    location_id  = nvl(p_location_id,0)
        AND    inventory_item_id = p_inventory_item_id
        AND    fin_year = p_fin_year;


    rgi_rec                                 rgi_cur%ROWTYPE;
    v_ec_code                               VARCHAR2(50);

    -- Vijay Shankar for Bug# 3587423
    v_prev_item_id                          NUMBER := 0;
    v_fin_year                              NUMBER;

    v_serial_no                             NUMBER := 0;
    v_balance_packed                        NUMBER := 0;
    v_balance_loose                         NUMBER := 0;
    v_debug_flag    VARCHAR2 (1) ; -- CHAR(1) := 'Y'; --Added by Nagaraj.s for Bug2708518  File.Sql.35 by Brathod

    -- Vijay Shankar for BUG#3165687
    v_manu_qty NUMBER := 0;
    v_statement_id VARCHAR2(3);
    v_regid_being_processed NUMBER;


BEGIN
/*------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_cmn_rg_master_org_pkg.consolidate_rg23_part_i.sql

SlNo yyyy/mm/dd   Details of Changes
------------------------------------------------------------------------------------------
1.   2002/12/14   Nagaraj.s - For BUG#2708518 Version - 615.1
                      Ideally In Master Organization, no transactions should happen
                      and only Consolidation needs to happen.
                      But since Transactions are bound to happen and no check
                      exists across the Localization objects, hence the following changes
                      are done.
                      1. rgi_register_id_cur has been incorporated with a new condition
                      that the Consolidation should happen only for Child Organizations.
                      2. serial_no_cur has been commented with a condition And    nvl(master_flag,'N') = 'Y'
                      3. balance_cur has been commented with a condition And nvl(master_flag,'N') = 'Y';
                      4. Fetching of Balances for Packed and Loose Quantities were commented.
                         Previously which is necessary to see that the Previous Balance is picked for
                         deciding on the Balance_Loose and Balance_Packed Columns of the Database.

2.   2004/02/17   Vijay Shankar for BUG#3165687, FileVersion - 619.1
                    Balance Loose and Balance packed are calculated wrongly which is made correct.
                    Also Manufactured quantity is not getting populated correctly which is also made correct with this fix

3.   2004/04/27   Vijay Shankar for BUG#3587423, FileVersion - 619.2
                    Modified the procedure to calculate balances by carrying forward the previous year balances. Modified CURSOR
                    rgi_register_id_cur to ORDER BY inventory_item_id, register_id instead of register_id and previous balances are
                    fetched only for first record of consolidated inventory item. Removed the execution of CURSOR serial_no_cur
                    for every record posted into Master Org, by using previous record balances.

                    Please refer to previous version for the changes made in this bug
--------------------------------------------------------------------------------------------*/

v_debug_flag :='Y';  -- File.Sql.35 by Brathod

if v_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '********* START OF LOG FILE - '||to_char(SYSDATE,'dd-mon-yyyy hh24:mi:ss')||' *********');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '1.0 organization->' || p_organization_id||', Location->' || p_location_id);
end if;

v_statement_id := '1';
OPEN  master_ec_code_cur(p_organization_id, nvl(p_location_id,0));
FETCH master_ec_code_cur INTO v_ec_code;
CLOSE master_ec_code_cur;

if v_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, '1.2 Before the Main Loop, EC Code->' || v_ec_code);
end if;

FOR rgi_reg_rec IN rgi_register_id_cur(v_ec_code)  LOOP

    v_regid_being_processed := rgi_reg_rec.register_id;

    v_statement_id := '2';
    if v_debug_flag = 'Y' THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, '1.4 The Register Id is  ' || rgi_reg_rec.register_id);
    end if;

    v_statement_id := '2a';

    OPEN  rgi_cur(rgi_reg_rec.register_id);
    FETCH rgi_cur INTO rgi_rec;
    CLOSE rgi_cur;

    v_statement_id := '3';
    --Start, Vijay Shankar for Bug# 3587423
    IF v_prev_item_id <> rgi_rec.inventory_item_id THEN
        -- This code is executed for the first record of each inventory_item_id. For the remaining records, these balances will be used
        -- removed fin_year from filtering condition, so that previous year balances are carried forward to next financial year
        v_statement_id := '3a';
        /*Bug 9550254 - Start*/
        /*
        v_fin_year := null;
        OPEN  c_max_fin_year(p_organization_id, nvl(p_location_id,0), rgi_rec.inventory_item_id);
        FETCH c_max_fin_year INTO v_fin_year;
        CLOSE c_max_fin_year;
        */

        v_fin_year := rgi_rec.fin_year;

        v_statement_id := '3b';
        /*
        OPEN  serial_no_cur(p_organization_id, nvl(p_location_id,0), rgi_rec.inventory_item_id, v_fin_year);
        FETCH serial_no_cur INTO v_serial_no;
        CLOSE serial_no_cur;
        */

        v_balance_loose := jai_om_rg_pkg.ja_in_rgi_balance(p_organization_id,nvl(p_location_id,0),rgi_rec.inventory_item_id,v_fin_year,
                                                           v_serial_no,v_balance_packed);

        IF nvl(v_serial_no, 0) = 0 THEN --'NVL' added for Bug 9550254
            -- v_balance_packed := 0;
            -- v_balance_loose := 0;
            v_manu_qty := 0;
            v_serial_no := 0;
            v_fin_year := rgi_rec.fin_year;
        ELSE
            v_statement_id := '7';
            v_statement_id := '3d';
						--OPEN  balance_cur(v_serial_no, p_organization_id, nvl(p_location_id,0), v_fin_year, rgi_rec.inventory_item_id);
			      --commented the above and added the below by Ramananda for Bug# 4589502
			      OPEN  balance_cur(v_serial_no, p_organization_id, nvl(p_location_id,0), rgi_rec.inventory_item_id, v_fin_year);
            FETCH balance_cur INTO v_balance_packed, v_balance_loose, v_manu_qty;
            CLOSE balance_cur;
        END IF;
        /*Bug 9550254 - End*/

        v_prev_item_id  := rgi_rec.inventory_item_id;

        IF v_debug_flag = 'Y' THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, '1.5 ChildItem->' || rgi_rec.inventory_item_id
                ||', v_fin_year->' || v_fin_year
                ||', v_serial_no->' || v_serial_no
                ||', bal_pac->' || v_balance_packed||', bal_loo->' || v_balance_loose||', man_qty->' || v_manu_qty);
        END IF;

    END IF;
    /*Commented for Bug 9550254*/
    /*
    IF v_fin_year <> rgi_rec.fin_year THEN
        v_statement_id := '7.1';
        v_serial_no := 1;
    ELSE
        v_statement_id := '6';
        v_serial_no := v_serial_no + 1;
    END IF;
    v_fin_year := rgi_rec.fin_year;
    */
    --End, Vijay Shankar for Bug# 3587423

    v_statement_id := '7a';
    v_manu_qty := nvl(rgi_rec.manufactured_packed_qty,0) + nvl(rgi_rec.manufactured_loose_qty,0);

    v_balance_packed := nvl(v_balance_packed, 0)
                            + nvl(rgi_rec.manufactured_packed_qty,0);

    v_statement_id := '7b';
    v_balance_loose  := nvl(v_balance_loose, 0)
                            - nvl(rgi_rec.for_home_use_pay_ed_qty,0)
                            - nvl(rgi_rec.for_export_pay_ed_qty,0)
                            - nvl(rgi_rec.for_export_n_pay_ed_qty,0)
                            - nvl(rgi_rec.to_other_factory_n_pay_ed_qty,0)
                            - nvl(rgi_rec.other_purpose_n_pay_ed_qty,0)
                            - nvl(rgi_rec.other_purpose_pay_ed_qty,0)
                            + nvl(rgi_rec.manufactured_loose_qty,0);

    v_serial_no := v_serial_no + 1; /*Bug 9550254*/

    IF v_debug_flag = 'Y' THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, '1.51 v_fin_year->' || v_fin_year||', bal_loo->' || v_balance_loose
            ||', serial_no->' || v_serial_no);
    END IF;

    v_statement_id := '8';
    INSERT INTO JAI_CMN_RG_I_TRXS ( register_id,
                            register_id_part_ii,
                            fin_year,
                            slno,
                            TRANSACTION_SOURCE_NUM,
                            organization_id,
                            location_id,
                            transaction_date,
                            inventory_item_id,
                            transaction_type,
                            REF_DOC_NO,
                            manufactured_qty,
                            manufactured_packed_qty,
                            manufactured_loose_qty,
                            for_home_use_pay_ed_qty,
                            for_home_use_pay_ed_val,
                            for_export_pay_ed_qty,
                            for_export_pay_ed_val,
                            for_export_n_pay_ed_qty,
                            for_export_n_pay_ed_val,
                            other_purpose,
                            to_other_factory_n_pay_ed_qty,
                            to_other_factory_n_pay_ed_val,
                            other_purpose_n_pay_ed_qty,
                            other_purpose_n_pay_ed_val,
                            other_purpose_pay_ed_qty,
                            other_purpose_pay_ed_val,
                            primary_uom_code,
                            transaction_uom_code,
                            balance_packed,
                            balance_loose,
                            issue_type,
                            excise_duty_amount,
                            excise_invoice_number,
                            excise_invoice_date,
                            payment_register,
                            charge_account_id,
                            range_no,
                            division_no,
                            remarks,
                            basic_ed,
                            additional_ed,
                            other_ed,
                            excise_duty_rate,
                            vendor_id,
                            vendor_site_id,
                            customer_id,
                            customer_site_id,
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by,
                            last_update_login,
                            posted_flag,
                            master_flag )
                   VALUES(  -1 * rgi_rec.register_id,
                            -1 * rgi_rec.register_id_part_ii,
                            rgi_rec.fin_year,
                            v_serial_no,
                            rgi_rec.transaction_source_num,
                            p_organization_id,
                            nvl(p_location_id,0),
                            rgi_rec.transaction_date,
                            rgi_rec.inventory_item_id,
                            rgi_rec.transaction_type,
                            rgi_rec.REF_DOC_NO,
                            -- Modified by Vijay Shankar for Bug# 3165687
                            v_manu_qty, -- rgi_rec.manufactured_qty,
                            rgi_rec.manufactured_packed_qty,
                            rgi_rec.manufactured_loose_qty,
                            rgi_rec.for_home_use_pay_ed_qty,
                            rgi_rec.for_home_use_pay_ed_val,
                            rgi_rec.for_export_pay_ed_qty,
                            rgi_rec.for_export_pay_ed_val,
                            rgi_rec.for_export_n_pay_ed_qty,
                            rgi_rec.for_export_n_pay_ed_val,
                            rgi_rec.other_purpose,
                            rgi_rec.to_other_factory_n_pay_ed_qty,
                            rgi_rec.to_other_factory_n_pay_ed_val,
                            rgi_rec.other_purpose_n_pay_ed_qty,
                            rgi_rec.other_purpose_n_pay_ed_val,
                            rgi_rec.other_purpose_pay_ed_qty,
                            rgi_rec.other_purpose_pay_ed_val,
                            rgi_rec.primary_uom_code,
                            rgi_rec.transaction_uom_code,
                            nvl(v_balance_packed,0),--nvl(rgi_rec.balance_packed,0),--By Nagaraj.s for Bug2708518
                            nvl(v_balance_loose,0),  --nvl(rgi_rec.balance_loose,0),--By Nagaraj.s for Bug2708518
                            rgi_rec.issue_type,
                            rgi_rec.excise_duty_amount,
                            rgi_rec.excise_invoice_number,
                            rgi_rec.excise_invoice_date,
                            rgi_rec.payment_register,
                            rgi_rec.charge_account_id,
                            rgi_rec.range_no,
                            rgi_rec.division_no,
                            rgi_rec.remarks,
                            rgi_rec.basic_ed,
                            rgi_rec.additional_ed,
                            rgi_rec.other_ed,
                            rgi_rec.excise_duty_rate,
                            rgi_rec.vendor_id,
                            rgi_rec.vendor_site_id,
                            rgi_rec.customer_id,
                            rgi_rec.customer_site_id,
                            rgi_rec.creation_date,
                            rgi_rec.created_by,
                            rgi_rec.last_update_date,
                            rgi_rec.last_updated_by,
                            rgi_rec.last_update_login,
                            'N',
                            'Y' );

    v_statement_id := '9';
    UPDATE JAI_CMN_RG_I_TRXS
    SET    posted_flag = 'Y',
           master_flag = 'N'
    WHERE  register_id = rgi_rec.register_id;

  END LOOP;

  if v_debug_flag = 'Y' THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG, '*************************** END OF LOG FILE ****************************************');
  end if;

--Exception added by Nagaraj.s for Bug2708518
Exception
    WHEN OTHERS THEN

        FND_FILE.PUT_LINE(FND_FILE.LOG, '######### Error at: v_regid_being_processed->'||v_regid_being_processed
            ||', statement_id->'||v_statement_id
            ||', SQLERRM->'||SQLERRM
        );

        RAISE_APPLICATION_ERROR(-20001,'This Concurrent Program has ended in an Error ' || SQLERRM);

END consolidate_rg_i;

END jai_cmn_rg_master_org_pkg ;

/
