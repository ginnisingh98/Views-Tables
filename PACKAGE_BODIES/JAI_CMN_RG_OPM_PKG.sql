--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RG_OPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RG_OPM_PKG" AS
/* $Header: jai_cmn_rg_opm.plb 120.1 2005/07/20 12:57:19 avallabh ship $ */

PROCEDURE create_rg23_entry
(
p_iss_recpt_mode          varchar2,
--p_orgn_code               varchar2,
p_location_id              NUMBER,   -- l_whse_code
p_ospheader               number,
p_vendor_id               number,
p_trans_date              date,
p_reg_type                Varchar2,
p_amount                  Number default 0,
p_post_rg23_i             Varchar2, -- default 'Y' File.Sql.35 by Brathod
p_organization_id         number
)
IS

/* Added by Ramananda for bug#4407165 */
lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_opm_pkg.create_rg23_entry';

  Cursor C_osp_lines(p_mode varchar2) IS
  Select
    a.act_quantity,
    a.uom_code,
    a.excise_payable,
    a.created_by,
    a.creation_date,
    a.last_updated_by,
    a.last_update_date,
    a.last_update_login,
    a.organization_id,
    a.inventory_item_id
  From
    JAI_OPM_OSP_DTLS a,
    JAI_OPM_OSP_HDRS b
  Where a.osp_header_id = p_ospheader
  and a.issue_recpt_flag = p_mode
  and b.osp_header_id = a.osp_header_id
  and a.trans_date <= b.extended_due_date
  and main_rcpt_flag = 'Y';

  Cursor C_vend_range_div(p_vendor_id in number) IS
    Select
      excise_duty_Range,
      excise_duty_division,
      vendor_site_id
    From
      JAI_CMN_VENDOR_SITES
    Where   vendor_id = p_vendor_id ;

  Cursor C_item_attributes(cpn_organization_id JAI_INV_ITM_SETUPS.organization_id%TYPE ,
                           cpn_inv_itm_id      JAI_INV_ITM_SETUPS.inventory_item_id%type --p_item_id NUMBER
                           )
  IS
    Select
      item_class,
      nvl(modvat_flag, 'N')
    From
      jai_inv_itm_setups -- JAI_OPM_ITM_MASTERS --
    Where organization_id   = cpn_organization_id
    AND   inventory_item_id = cpn_inv_itm_id ;-- item_id = p_item_id;

  Cursor C_tran_date IS
    Select transaction_date
    From  JAI_OPM_OSP_HDRS
    Where osp_header_id = p_ospheader;

  CURSOR fin_year_cur (cpn_organization_id jai_cmn_fin_years.organization_id%type)
  IS
    select
      max(a.fin_year)
    from
      JAI_CMN_FIN_YEARS a
    where  a.organization_id = cpn_organization_id
    and    a.fin_active_flag = 'Y';

   srno                   NUMBER;
   v_year                 Number;
   v_reg_id               Number;
   v_slno                 Number :=0;
   v_slno_ii              Number :=0;
   v_slno_iii             Number :=0;
   v_folio_no_i           Number :=0;
   v_folio_no_ii          Number :=0;
   v_i_ospheader          Number :=  NULL;
   v_i_txndate            Date :=  NULL;
   v_i_quantity           Number :=  NULL;
   v_r_ospheader          Number :=  NULL;
   v_r_txndate            Date :=  NULL;
   v_r_quantity           Number :=  NULL;
   v_trans_id             Number;
   v_r_excise_amt         Number := NULL;
   v_i_excise_amt         Number := NULL;
   v_excise_amt           Number := NULL;
   v_excise_duty_Range    Varchar2(50);
   v_excise_duty_div      Varchar2(50);
   v_register_type        Varchar2(1);
   v_item_class           Varchar2(10);
   v_item_excisable       Varchar2(1);
   l_mode                 Varchar2(1);
   l_org_id               Number;
   l_tran_date            date;
   excise_amt             Number;
   v_opening_balance      Number;
   v_closing_balance      Number;
   amount_flag            varchar2(1);  -- := 'N'; -- File.Sql.35 by Brathod
   lv_proc_status         VARCHAR2(3);
   lv_proc_msg            VARCHAR2(1000);
   ln_vendor_site_id      NUMBER (15);
   lv_reg_id_ii           NUMBER (15);
   lv_reg_id_pla          NUMBER (15);


  BEGIN

  /*------------------------------------------------------------------------------
  Filename: create_rg23_entry_prc.sql

  CHANGE HISTORY:

  S.No    Date            Author and Details
  ----    -------         ------------------
  1       17/10/2004      Aparajita.
                          Merge of OPM and Discrete with Obsoletion of PO logistics.

                          Changed the definition of cursor C_vend_range_div to fetch the details from
                          JAI_CMN_VENDOR_SITES instead of ja_in_vendors. ja_in_vendors has been dropped
                          for the obsoletion of Obsoletion of PO logistics.

                          Clean up was also done for the un necessary cusrosrs and code.

  2       08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old DB Entity Names,
              as required for CASE COMPLAINCE. Version 116.3

  3       08-Jul-2005    Brathod
                         Issue: Inventory Convergence Uptake.
                         Solution:
                         - Code is modified to remove reference of OPM Tables and include reference
                         to related Discrete tables as per the new datamodel of R12.
                         - Direct inserts in OPM tables
                         are removed and instead related discrete API are called to make the entries in RG/PLA
                         Tables.
  -------------------------------------------------------------------------------*/
  amount_flag := 'N';   -- File.Sql.35 by Brathod

    IF p_iss_recpt_mode = 'I' THEN
      v_i_ospheader := p_ospheader;
      v_i_txndate := p_trans_date;
    ELSIF p_iss_recpt_mode = 'R' THEN
      v_r_ospheader := p_ospheader;
      v_r_txndate := p_trans_date;
    END IF;

    OPEN C_tran_date;
    FETCH C_tran_date into l_tran_date;
    CLOSE C_tran_date;

    /* Commented by Brathod for Inv.Convergence
    OPEN C_Org_Id;
    FETCH C_Org_Id INTO l_org_id;
    CLOSE C_Org_Id;
    */
    l_org_id := p_organization_id;

    /* Commented by Brathod for Inv.Convergence
    OPEN C_Location_Id ;
    FETCH C_Location_Id  INTO l_location_id ;
    CLOSE C_Location_Id ;
    */

    OPEN C_vend_range_div(p_vendor_id);
    FETCH C_vend_range_div INTO v_excise_duty_Range,v_excise_duty_div, ln_vendor_site_id;
    CLOSE C_vend_range_div;

    OPEN fin_year_cur (l_org_id);
    FETCH fin_year_cur into v_year;
    CLOSE fin_year_cur;

    IF p_post_rg23_i = 'N' THEN
      l_mode := 'R';
    ELSE
      l_mode := p_iss_recpt_mode;
    END IF;


    FOR rec IN C_osp_lines(l_mode ) LOOP

      v_i_excise_amt := 0;
      amount_flag := 'N';
      v_item_class := NULL;
      v_item_excisable := NULL;

      OPEN  C_item_attributes(rec.organization_id, rec.inventory_item_id );
      FETCH C_item_attributes INTO v_item_class,v_item_excisable;
      CLOSE C_item_attributes;

      IF NVL(v_item_excisable,'N') = 'Y' OR p_iss_recpt_mode ='R'  THEN

        IF (SUBSTR(v_item_class,1,2) IN ('CG', 'FG')) THEN
          v_register_type := 'C';
        ELSE
          v_register_type  := 'A';
        END IF;

        v_i_excise_amt:= rec.excise_payable;

        IF v_i_excise_amt > 0 then
          amount_flag := 'Y';
        End if;


        IF p_iss_recpt_mode = 'I' THEN

          v_i_quantity    := rec.act_quantity;

          IF p_amount = 0 THEN
            v_i_excise_amt  := rec.excise_payable;
          ELSE
            v_i_excise_amt    := p_amount;
          END IF;

          IF v_i_excise_amt > 0 then
            amount_flag := 'Y';
          End if;

          v_r_quantity  := null;

        ELSIF p_iss_recpt_mode = 'R' THEN

          v_r_quantity  := rec.act_quantity;

          IF p_amount = 0 THEN
            v_r_excise_amt  := rec.excise_payable;
          ELSE
            v_r_excise_amt    := p_amount;
          END IF;

          IF v_r_excise_amt > 0 then
            amount_flag := 'Y';
          End if;

          v_i_quantity  := null;

        END IF;


        IF p_post_rg23_i = 'Y' THEN

          jai_cmn_rg_23ac_i_trxs_pkg.insert_row
          (
             P_REGISTER_ID           => v_reg_id
            ,P_INVENTORY_ITEM_ID     => rec.inventory_item_id
            ,P_ORGANIZATION_ID       => rec.organization_id
            ,P_QUANTITY_RECEIVED     => v_r_quantity
            ,P_RECEIPT_ID            => v_r_ospheader
            ,P_TRANSACTION_TYPE      => p_iss_recpt_mode
            ,P_RECEIPT_DATE          => v_r_txndate
            ,P_PO_HEADER_ID          => Null
            ,P_PO_HEADER_DATE        => Null
            ,P_PO_LINE_ID            => Null
            ,P_PO_LINE_LOCATION_ID   => Null
            ,P_VENDOR_ID             => p_vendor_id
            ,P_VENDOR_SITE_ID        => ln_vendor_site_id
            ,P_CUSTOMER_ID           => Null
            ,P_CUSTOMER_SITE_ID      => Null
            ,P_GOODS_ISSUE_ID        => v_i_ospheader
            ,P_GOODS_ISSUE_DATE      => v_i_txndate
            ,P_GOODS_ISSUE_QUANTITY  => v_i_quantity
            ,P_SALES_INVOICE_ID      => Null
            ,P_SALES_INVOICE_DATE    => Null
            ,P_SALES_INVOICE_QUANTITY => Null
            ,P_EXCISE_INVOICE_ID      => Null
            ,P_EXCISE_INVOICE_DATE    => Null
            ,P_OTH_RECEIPT_QUANTITY   => Null
            ,P_OTH_RECEIPT_ID         => Null
            ,P_OTH_RECEIPT_DATE       => Null
            ,P_REGISTER_TYPE          => v_register_type
            ,P_IDENTIFICATION_NO      => null
            ,P_IDENTIFICATION_MARK    => null
            ,P_BRAND_NAME             => null
            ,P_DATE_OF_VERIFICATION   => null
            ,P_DATE_OF_INSTALLATION   => null
            ,P_DATE_OF_COMMISSION     => null
            ,P_REGISER_ID_PART_II     => null
            ,P_PLACE_OF_INSTALL       => null
            ,P_REMARKS                => 'OPM OSP Transaction'
            ,P_LOCATION_ID            => p_location_id
            ,P_TRANSACTION_UOM_CODE   => rec.uom_code
            ,P_TRANSACTION_DATE       => p_trans_date
            ,P_BASIC_ED               => v_excise_amt
            ,P_ADDITIONAL_ED          => null
            ,P_OTHER_ED               => null
            ,P_CHARGE_ACCOUNT_ID      => NULL
            ,P_TRANSACTION_SOURCE     => 'OPM_OSP'
            ,P_CALLED_FROM            => 'jai_cmn_rg_opm_pkg.create_rg23_entry'
            ,P_SIMULATE_FLAG          => jai_constants.no
            ,P_PROCESS_STATUS         => lv_proc_status
            ,P_PROCESS_MESSAGE        => lv_proc_msg
          );

          END IF;

          IF p_reg_type LIKE 'RG%' THEN

            IF p_reg_type = 'RG23A' AND p_iss_recpt_mode ='R' THEN
              v_register_type := 'A';
            ELSIF p_reg_type = 'RG23C' AND p_iss_recpt_mode ='R' THEN
              v_register_type := 'C';
            END IF;

            If amount_flag = 'Y' then
              select  JAI_CMN_RG_23AC_II_TRXS_S.nextval
              into    v_reg_id
              from    dual;

              if substr(p_reg_type,5,1) = 'A' THEN
                v_register_type := 'A';
              elsif substr(p_reg_type,5,1) = 'C' THEN
                v_register_type := 'C';
              end if;

              jai_cmn_rg_23ac_ii_pkg.insert_row
              (
                 P_REGISTER_ID                  => lv_reg_id_ii
                ,P_INVENTORY_ITEM_ID            => rec.inventory_item_id
                ,P_ORGANIZATION_ID              => rec.organization_id
                ,P_RECEIPT_ID                   => v_r_ospheader
                ,P_RECEIPT_DATE                 => v_r_txndate
                ,P_CR_BASIC_ED                  => v_r_excise_amt
                ,P_CR_ADDITIONAL_ED             => null
                ,P_CR_OTHER_ED                  => null
                ,P_DR_BASIC_ED                  => v_i_excise_amt
                ,P_DR_ADDITIONAL_ED             => null
                ,P_DR_OTHER_ED                  => null
                ,P_EXCISE_INVOICE_NO            => NULL
                ,P_EXCISE_INVOICE_DATE          => NULL
                ,P_REGISTER_TYPE                => v_register_type
                ,P_REMARKS                      => 'OPM OSP Transaction'
                ,P_VENDOR_ID                    => p_vendor_id
                ,P_VENDOR_SITE_ID               => ln_vendor_site_id
                ,P_CUSTOMER_ID                  => null
                ,P_CUSTOMER_SITE_ID             => null
                ,P_LOCATION_ID                  => p_location_id
                ,P_TRANSACTION_DATE             => p_trans_date
                ,P_CHARGE_ACCOUNT_ID            => null
                ,P_REGISTER_ID_PART_I           => v_reg_id
                ,P_REFERENCE_NUM                => null
                ,P_ROUNDING_ID                  => null
                ,P_OTHER_TAX_CREDIT             => null
                ,P_OTHER_TAX_DEBIT              => null
                ,P_TRANSACTION_TYPE             => p_iss_recpt_mode
                ,P_TRANSACTION_SOURCE           => 'OPM_OSP'
                ,P_CALLED_FROM                  => 'jai_cmn_rg_opm_pkg.create_rg23_entry'
                ,P_SIMULATE_FLAG                => jai_constants.no
                ,P_PROCESS_STATUS               => lv_proc_status
                ,P_PROCESS_MESSAGE              => lv_proc_msg
              );

              UPDATE jai_cmn_rg_23ac_i_trxs
              SET    register_id_part_ii = lv_reg_id_ii
              WHERE  register_id = v_reg_id;


            end if;

          elsif p_reg_type = 'PLA' then

            If amount_flag = 'Y' then

              If p_iss_recpt_mode  = 'I' THEN
                excise_amt := v_i_excise_amt;
              Else
                excise_amt := v_r_excise_amt;
              End if;

              jai_cmn_rg_pla_trxs_pkg.insert_row
              (
                 P_REGISTER_ID           => lv_reg_id_pla
                ,P_TR6_CHALLAN_NO        => NULL
                ,P_TR6_CHALLAN_DATE      => NULL
                ,P_CR_BASIC_ED           => v_r_excise_amt
                ,P_CR_ADDITIONAL_ED      => null
                ,P_CR_OTHER_ED           => null
                ,P_REF_DOCUMENT_ID       => p_ospheader
                ,P_REF_DOCUMENT_DATE     => sysdate
                ,P_DR_INVOICE_ID         => null
                ,P_DR_INVOICE_DATE       => null
                ,P_DR_BASIC_ED           => v_i_excise_amt
                ,P_DR_ADDITIONAL_ED      => null
                ,P_DR_OTHER_ED           => null
                ,P_ORGANIZATION_ID       => rec.organization_id
                ,P_LOCATION_ID           => p_location_id
                ,P_BANK_BRANCH_ID        => null
                ,P_ENTRY_DATE            => sysdate
                ,P_INVENTORY_ITEM_ID     => rec.inventory_item_id
                ,P_VENDOR_CUST_FLAG      => 'V'
                ,P_VENDOR_ID             => p_vendor_id
                ,P_VENDOR_SITE_ID        => ln_vendor_site_id
                ,P_EXCISE_INVOICE_NO     => NULL
                ,P_REMARKS               => 'OPM OSP Transaction'
                ,P_TRANSACTION_DATE      => nvl(l_tran_date, sysdate)
                ,P_CHARGE_ACCOUNT_ID     => null
                ,P_OTHER_TAX_CREDIT      => null
                ,P_OTHER_TAX_DEBIT       => null
                ,P_TRANSACTION_TYPE      => p_iss_recpt_mode
                ,P_TRANSACTION_SOURCE    => 'OPM OSP'
                ,P_CALLED_FROM           => 'jai_cmn_rg_opm_pkg.create_rg23_entry'
                ,P_SIMULATE_FLAG         => jai_constants.no
                ,P_PROCESS_STATUS        => lv_proc_status
                ,P_PROCESS_MESSAGE       => lv_proc_msg
                ,P_ROUNDING_ID           => NULL
              );

            end if;

          end if;

        end if;-- for if added by yrd above

        /*
        IF p_iss_recpt_mode = 'I' AND  p_reg_type = 'RG23A' THEN

          Update JAI_CMN_RG_BALANCES
          set    rg23a_balance = rg23a_balance - nvl(v_i_excise_amt,0)
          Where organization_id = l_org_id;

        ELSIF p_iss_recpt_mode = 'I' AND  p_reg_type = 'RG23C' THEN

          Update JAI_CMN_RG_BALANCES
          set    rg23c_balance = rg23c_balance - nvl(v_i_excise_amt,0)
          Where   organization_id = l_org_id;

        ELSIF p_iss_recpt_mode = 'I' AND  p_reg_type = 'PLA' THEN

          Update JAI_CMN_RG_BALANCES
          set     pla_balance = pla_balance - nvl(v_i_excise_amt,0)
          Where   organization_id = l_org_id;

        ELSIF p_iss_recpt_mode = 'R' AND  p_reg_type = 'RG23A' THEN

         Update JAI_CMN_RG_BALANCES
         set    rg23a_balance = rg23a_balance + nvl(v_r_excise_amt,0)
         Where  organization_id = l_org_id;

       ELSIF p_iss_recpt_mode = 'R' AND  p_reg_type = 'RG23C' THEN

         Update JAI_CMN_RG_BALANCES
         set    rg23c_balance = rg23c_balance + nvl(v_r_excise_amt,0)
        Where   organization_id = l_org_id;

       ELSIF p_iss_recpt_mode = 'R' AND  p_reg_type = 'PLA' THEN

         Update JAI_CMN_RG_BALANCES
         set pla_balance = pla_balance + nvl(v_r_excise_amt,0)
        Where organization_id = l_org_id;

       END IF;
        */

   END LOOP;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END create_rg23_entry;

/*
PROCEDURE calculate_pla_balances(p_org_id IN NUMBER,p_fin_year IN NUMBER,
        p_mode VARCHAR2,excise_amt NUMBER,v_opening_balance IN OUT NOCOPY NUMBER,
        v_closing_balance IN OUT NOCOPY NUMBER) IS

/* Added by Ramananda for bug#4407165
lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_opm_pkg.calculate_pla_balances';

    CURSOR balance_cur  IS
    SELECT NVL(pla_balance,0)
    FROM JAI_CMN_RG_BALANCES a, JAI_CMN_INVENTORY_ORGS b
    WHERE a.organization_id = b.organization_id
        and a.location_id = b.location_id
          and a.organization_id = p_org_id
          and b.MASTER_ORG_FLAG = 'Y';

-- end

  Cursor pla_balance_cur IS
    SELECT NVL(pla_balance,0)
    FROM JAI_CMN_RG_BALANCES a, JAI_CMN_INVENTORY_ORGS b
    WHERE a.organization_id = b.organization_id
    and a.location_id = b.location_id
    and a.organization_id = p_org_id
    and b.MASTER_ORG_FLAG = 'Y' ;

  Cursor serial_no_cur IS
     SELECT NVL(MAX(slno),0) , NVL(MAX(slno),0) + 1
     FROM JAI_CMN_RG_PLA_TRXS
     WHERE organization_id = p_org_id and
    --    location_id   = p_location_id and
     fin_year = p_fin_year;

   v_previous_serial_no number;
   v_serial_no number;
   v_rg_balance number;
-- added by uday
   v_op_bl number;
-- end
BEGIN
   OPEN  serial_no_cur;
   FETCH  serial_no_cur  INTO v_previous_serial_no, v_serial_no;
   CLOSE  serial_no_cur;

   IF NVL(v_previous_serial_no,0) = 0
   THEN
     v_previous_serial_no := 0;
     v_serial_no := 1;
   END IF;

   IF NVL(v_previous_serial_no,0) > 0
   THEN

   open balance_cur;
   FETCH  balance_cur INTO v_opening_balance;
   CLOSE  balance_cur;

     v_op_bl := v_opening_balance; -- added by uday

 --    v_opening_balance := v_closing_balance;  -- comment by uk

     IF p_mode = 'I' then
--  v_closing_balance := nvl(v_closing_balance,0) - nvl(excise_amt,0); -- comment by uk
       v_closing_balance := nvl(v_op_bl,0) - nvl(excise_amt,0); -- added by uk

     ELSIF p_mode = 'R' then
--       v_closing_balance := nvl(v_closing_balance,0) + nvl(excise_amt,0); -- commented by uk
       v_closing_balance := nvl(v_op_bl,0) + nvl(excise_amt,0); -- added by uk
     END IF;

   ELSE
     OPEN   pla_balance_cur;
     FETCH  pla_balance_cur INTO v_rg_balance;
     CLOSE  pla_balance_cur;

--     v_opening_balance := NVL(v_rg_balance,0); -- commented by uk
        v_op_bl := NVL(v_rg_balance,0); -- added by uk

     v_closing_balance := NVL(v_rg_balance,0);

     IF p_mode = 'I' then
       v_closing_balance := nvl(v_closing_balance,0) - nvl(excise_amt,0);
     ELSIF p_mode = 'R' then
       v_closing_balance := nvl(v_closing_balance,0) + nvl(excise_amt,0);

     END IF;
  END IF;

 /* Added by Ramananda for bug#4407165
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END calculate_pla_balances;
*/

procedure create_rg_i_entry
(
p_location_id           NUMBER, --p_whse_code
p_ospheader           number,
p_trans_date          date,
p_qty                 number,
p_uom_code            varchar2,
p_created_by          number,
p_organization_id     number,
p_inventory_item_id   number
)
IS

/* Added by Ramananda for bug#4407165 */
lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_opm_pkg.create_rg_i_entry';

  itemclass           varchar2(5);
  exciseitem          varchar2(1); -- := 'N'  File.Sql.35 by Brathod
  l_po_id             number(10);
  l_shipvend_id       number(10);
  l_range_no          varchar2(50);
  l_div_no            varchar2(50);
  l1_folio            number;
  l_vend_site_id      number;
  srno                number;

  cursor C_itemclass is
    select item_class
    from   JAI_INV_ITM_SETUPS --JAI_OPM_ITM_MASTERS
    where  organization_id = p_organization_id
    AND    inventory_item_id = p_inventory_item_id ;--item_id = p_item_id;

  cursor C_po_id is
    select po_id
    from JAI_OPM_OSP_HDRS
    where osp_header_id = p_ospheader;

  cursor C_vendor is
    select vendor_id, vendor_site_id
    from po_headers_all --po_ordr_hdr
    where po_header_id = l_po_id;

  cursor C_vend_ran_div is
    select excise_duty_range, excise_duty_division
    from  JAI_CMN_VENDOR_SITES
    where vendor_id = l_shipvend_id;

  cursor C_Excise_Payable IS
    select payable_excise
    from JAI_OPM_OSP_HDRS
    where osp_header_id = p_ospheader ;

  cursor fin_year_cur IS
    select  max(a.fin_year)
    from    JAI_CMN_FIN_YEARS a
    where   a.organization_id = p_organization_id
    and     a.fin_active_flag = 'Y';


  l_year        number := null;
  l_slno        number := null;
  l_folio       number := null;
  l_excise      number := null;
  l1_slno       number;
  l_reg_type    varchar2(1);
  ln_reg_id     number;
  ln_login_id   number;
  lv_proc_status  VARCHAR2(2);
  lv_proc_msg     VARCHAR2(1000);
  ln_rg_i_id      NUMBER;

BEGIN
/*--------------------------------------------------------------------------------------------------------------------------
Procedure to insert into Rg1 table through OSP process

Change History for FileName   create_rg_i_entry_prc.sql


S.No  DD/MM/YYYY   Author and Description
----------------------------------------------------------------------------------------------------------------------------
1     29/09/2004   Vijay Shankar for Bug# 3030446, File Version : 712.1

                   population of data into BALANCE_PACKED column is stopped as it was leading to datafixes
                   and also redundant.

                   From now on only balance_loose should be used and balance_packed is obsolete

2     17/10/2004   Aparajita.
                   Merge of OPM and Discrete with Obsoletion of PO logistics.

                   Changed the definition of cursor C_vend_ran_div to fetch the details from
                   JAI_CMN_VENDOR_SITES instead of ja_in_vendors. ja_in_vendors has been dropped
                   for the obsoletion of Obsoletion of PO logistics.

--------------------------------------------------------------------------------------------------------------------------*/

  exciseitem := 'N';  -- File.Sql.35 by Brathod

  open c_itemclass;
  fetch c_itemclass into itemclass;
  close c_itemclass;

  open c_po_id;
  fetch c_po_id into l_po_id;
  close c_po_id;

  open c_vendor;
  fetch c_vendor into l_shipvend_id, l_vend_site_id;
  close c_vendor;

  open c_vend_ran_div;
  fetch c_vend_ran_div into l_range_no, l_div_no;
  close c_vend_ran_div;

  open c_excise_payable ;
  fetch c_excise_payable  into l_excise;
  close c_excise_payable ;


  open fin_year_cur;
  fetch fin_year_cur into l_year;
  close fin_year_cur;


  If substr(itemclass,1,2) = 'RM' OR substr(itemclass,1,2) = 'CG' then

    l_reg_type := jai_general_pkg.get_rg_register_type(itemclass);

    /* Commented by Brathod for Inv.Convergence
    select max(slno) into srno
    from  JAI_OPM_RG23_I_TRXS
    where orgn_code = p_orgn_code
    and   register_type = l_reg_type
    and   fin_year = l_year;

    if srno is null then
      l1_slno := 1;
    else
      l1_slno := srno + 1;
    end if;

    insert into JAI_OPM_RG23_I_TRXS
    (
      register_id,
      slno,
      fin_year,
      last_update_date,
      last_updated_by,
      last_update_login,
      creation_date,
      created_by,
      TRANSACTION_SOURCE_NUM,
      transaction_date,
      inventory_item_id,
      orgn_code,
      transaction_type,
      vendor_id,
      vendor_site_id,
      register_type,
      uom_code,
      folio_no,
      entry_date,
      LOCATION_CODE,
      range_no,
      division_no,
      quantity_received,
      GOODS_ISSUE_ID_REF,
      receipt_date
    )
    values
    (
      JAI_CMN_RG_23AC_I_TXNS_S.nextval,
      l1_slno,
      l_year,
      sysdate,
      p_created_by,
      null,
      sysdate,
      p_created_by,
      92,
      p_trans_date  ,
      p_item_id,
      p_orgn_code ,
      'R',
      l_shipvend_id,
      l_vend_site_id,
      l_reg_type,
      p_uom_code,
      l1_folio,
      sysdate,
      p_whse_code,
      l_range_no,
      l_div_no,
      p_qty,
      p_ospheader,
      p_trans_date
    );
    */

    jai_cmn_rg_23ac_i_trxs_pkg.insert_row
      (
         P_REGISTER_ID           => ln_reg_id
        ,P_INVENTORY_ITEM_ID     => p_inventory_item_id
        ,P_ORGANIZATION_ID       => p_organization_id
        ,P_QUANTITY_RECEIVED     => p_qty
        ,P_RECEIPT_ID            => NULL
        ,P_TRANSACTION_TYPE      => 'R'
        ,P_RECEIPT_DATE          => p_trans_date
        ,P_PO_HEADER_ID          => l_po_id
        ,P_PO_HEADER_DATE        => Null
        ,P_PO_LINE_ID            => Null
        ,P_PO_LINE_LOCATION_ID   => Null
        ,P_VENDOR_ID             => l_shipvend_id
        ,P_VENDOR_SITE_ID        => l_vend_site_id
        ,P_CUSTOMER_ID           => Null
        ,P_CUSTOMER_SITE_ID      => Null
        ,P_GOODS_ISSUE_ID        => p_ospheader
        ,P_GOODS_ISSUE_DATE      => null
        ,P_GOODS_ISSUE_QUANTITY  => null
        ,P_SALES_INVOICE_ID      => Null
        ,P_SALES_INVOICE_DATE    => Null
        ,P_SALES_INVOICE_QUANTITY => Null
        ,P_EXCISE_INVOICE_ID      => Null
        ,P_EXCISE_INVOICE_DATE    => Null
        ,P_OTH_RECEIPT_QUANTITY   => Null
        ,P_OTH_RECEIPT_ID         => Null
        ,P_OTH_RECEIPT_DATE       => Null
        ,P_REGISTER_TYPE          => l_reg_type
        ,P_IDENTIFICATION_NO      => null
        ,P_IDENTIFICATION_MARK    => null
        ,P_BRAND_NAME             => null
        ,P_DATE_OF_VERIFICATION   => null
        ,P_DATE_OF_INSTALLATION   => null
        ,P_DATE_OF_COMMISSION     => null
        ,P_REGISER_ID_PART_II     => null
        ,P_PLACE_OF_INSTALL       => null
        ,P_REMARKS                => 'OPM OSP Transaction'
        ,P_LOCATION_ID            => p_location_id
        ,P_TRANSACTION_UOM_CODE   => p_uom_code
        ,P_TRANSACTION_DATE       => p_trans_date
        ,P_BASIC_ED               => null
        ,P_ADDITIONAL_ED          => null
        ,P_OTHER_ED               => null
        ,P_CHARGE_ACCOUNT_ID      => NULL
        ,P_TRANSACTION_SOURCE     => 'OPM OSP'
        ,P_CALLED_FROM            => 'jai_cmn_rg_opm_pkg.create_rg_i_entry'
        ,P_SIMULATE_FLAG          => jai_constants.no
        ,P_PROCESS_STATUS         => lv_proc_status
        ,P_PROCESS_MESSAGE        => lv_proc_msg
      );

  elsif substr(itemclass,1,2) = 'FG' then

    /*select max(slno)
    into   srno
    from  JAI_OPM_RG_I_TRXS
    where orgn_code = p_orgn_code
    and   fin_year = l_year;

    if srno is null then
      l_slno := 1;
    else
      l_slno := srno + 1;
    end if;

    insert into JAI_OPM_RG_I_TRXS
    (
      register_id,
      slno,
      fin_year,
      last_update_date,
      last_updated_by,
      last_update_login,
      creation_date,
      created_by,
      TRANSACTION_SOURCE_NUM,
      transaction_date,
      inventory_item_id,
      orgn_code,
      transaction_type,
      --balance_packed,    Commented by Vijay Shankar for Bug# 3030446
      REF_DOC_NO,
      uom_code,
      transaction_uom,
      manufactured_qty,
      excise_duty_amount,
      basic_excise_duty_amount,
      entry_date,
      LOCATION_CODE,
      slno_part_ii,
      folio_no_part_ii
    )
    values
    (
      JAI_CMN_RG_I_TXNS_S.nextval,
      l_slno,
      l_year,
      sysdate,
      p_created_by,
      null,
      sysdate,
      p_created_by,
      92,
      p_trans_date,
      p_item_id,
      p_orgn_code,
      'R',
      -- p_qty,    Commented by Vijay Shankar for Bug# 3030446
      p_ospheader,
      p_uom_code,
      p_uom_code,
      p_qty,
      l_excise,
      l_excise,
      sysdate,
      p_whse_code,
      null,
      null
    );*/
    ln_login_id := fnd_global.login_id;
      jai_cmn_rg_i_trxs_pkg.create_rg1_entry
      (
       P_REGISTER_ID                  => ln_rg_i_id
      ,P_REGISTER_ID_PART_II          => null
      ,P_FIN_YEAR                     => l_year
      ,P_SLNO                         => l_slno
      ,P_TRANSACTION_ID               => null
      ,P_ORGANIZATION_ID              => p_organization_id
      ,P_LOCATION_ID                  => p_location_id
      ,P_TRANSACTION_DATE             => p_trans_date
      ,P_INVENTORY_ITEM_ID            => p_inventory_item_id
      ,P_TRANSACTION_TYPE             => 'R'
      ,P_REF_DOC_ID                   => p_ospheader
      ,P_QUANTITY                     => p_qty
      ,P_TRANSACTION_UOM_CODE         => p_uom_code
      ,P_ISSUE_TYPE                   => NULL
      ,P_EXCISE_DUTY_AMOUNT           => l_excise
      ,P_EXCISE_INVOICE_NUMBER        => null
      ,P_EXCISE_INVOICE_DATE          => null
      ,P_PAYMENT_REGISTER             => null
      ,P_CHARGE_ACCOUNT_ID            => null
      ,P_RANGE_NO                     => null
      ,P_DIVISION_NO                  => null
      ,P_REMARKS                      => 'OPM OSP Transaction'
      ,P_BASIC_ED                     => null
      ,P_ADDITIONAL_ED                => null
      ,P_OTHER_ED                     => null
      ,P_ASSESSABLE_VALUE             => null
      ,P_EXCISE_DUTY_RATE             => null
      ,P_VENDOR_ID                    => l_shipvend_id
      ,P_VENDOR_SITE_ID               => l_vend_site_id
      ,P_CUSTOMER_ID                  => null
      ,P_CUSTOMER_SITE_ID             => null
      ,P_CREATION_DATE                => SYSDATE
      ,P_CREATED_BY                   => p_created_by
      ,P_LAST_UPDATE_DATE             => sysdate
      ,P_LAST_UPDATED_BY              => p_created_by
      ,P_LAST_UPDATE_LOGIN            => ln_login_id
      ,P_CALLED_FROM                  => 'jai_cmn_rg_opm_pkg.create_rg_i_entry'
      );

  end if;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END create_rg_i_entry;

END jai_cmn_rg_opm_pkg;

/
