--------------------------------------------------------
--  DDL for Package Body JAI_JRG_OTH_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_JRG_OTH_TRIGGER_PKG" AS
/* $Header: jai_jrg_oth_t.plb 120.6 2007/10/08 05:03:03 ssumaith ship $ */
/*  REM +======================================================================+
  REM NAME          BRI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_JRG_OTH_BRIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_JRG_OTH_BRI_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE BRI_T1 ( pr_old t_rec%type , pr_new in out t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
ln_balance number;
ln_balance_cnt   number;
ln_org_unit_id   JAI_CMN_INVENTORY_ORGS.org_unit_id%TYPE;
lv_register_type JAI_CMN_RG_OTH_BALANCES.register_type%TYPE;

CURSOR cur_org_unit_id_pla IS
SELECT org_unit_id
  FROM JAI_CMN_INVENTORY_ORGS
 WHERE (organization_id,location_id)
    IN ( SELECT organization_id,location_id
           FROM JAI_CMN_RG_PLA_TRXS
          WHERE register_id     = pr_new.source_register_id
            AND pr_new.source_type    = 2 );

CURSOR cur_org_unit_id_rg23 IS
SELECT org_unit_id
  FROM JAI_CMN_INVENTORY_ORGS
 WHERE ( organization_id,location_id)
    IN ( SELECT organization_id,location_id
           FROM JAI_CMN_RG_23AC_II_TRXS
          WHERE register_id      = pr_new.source_register_id
            AND pr_new.source_type = 1);

CURSOR cur_balance
IS
SELECT balance
  FROM JAI_CMN_RG_OTH_BALANCES
 WHERE org_unit_id = ln_org_unit_id
   AND tax_type = pr_new.tax_type
   AND register_type = lv_register_type;
/*Bug 5141459 start*/
CURSOR cur_chk_consolidation( p_register_id NUMBER )
IS
SELECT 1
  FROM JAI_CMN_RG_23AC_II_TRXS
 WHERE register_id = p_register_id
   AND transaction_source_num IS NULL
   AND pr_new.source_type = 1
 UNION
SELECT 1
  FROM JAI_CMN_RG_PLA_TRXS
 WHERE register_id = p_register_id
   AND ( transaction_source_num IS NULL OR tr6_source='CONSOLIDATION' or tr6_source='MANUAL') /*ADDED or tr6_source='MANUAL' for bug #5894216*/
   AND pr_new.source_type = 2;

/*Bug 5141459 End*/

/*------------------------------------------------------------------------------------------
CHANGE HISTORY:     FILENAME: jai_rg_others_bi_trg.sql


S.No  Version      Date            Author and Details
------------------------------------------------------------------------------------------
1.     08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                     DB Entity as required for CASE COMPLAINCE.  Version 116.1


2. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

3. 3-Mar-2007	  bduvarag for bug#5141459,File version 120.2
		   Forward porting the changes done in 11i bug#4548378

4.  9-jul-2007	  vkaranam for bug#5894216,File Version 120.3
                  Forward porting the changes done in 11i bug#5854331
                  (In Pla Duty Book Report, Education Cess Opening Balance Is Showing Wrongly)

5. 01-Oct-2007    Bgowrava for Bug#6455886, File Version 120.4
                  Added NVL condition to ln_balance. Thus the balance calculation is proper.

6. 03-Oct-2007    Bgowrava for Bug#6455886, File Version 120.5
                  Added one condition to check if the variable ln_balance has null value,
                  instead of nvl condition at 3 places.

Dependency:
----------

Sl No. Current Bug        Dependent on
                          Bug/Patch set    Details
-------------------------------------------------------------------------------------------------
  1       4146822         4146708          New tables created(JAI_CMN_RG_OTHERS,JAI_CMN_RG_OTH_BALANCES)
                                           , columns added to tables
                                           which are refered in this trigger

--------------------------------------------------------------------------------------------------*/
  BEGIN
    pv_return_code := jai_constants.successful ;

/**********************************************************************
CREATED BY       : rchandan
CREATED DATE     : 28-JAN-2005
ENHANCEMENT BUG  : 4146822
PURPOSE          : To update opening balance and closing balance of JAI_CMN_RG_OTHERS and update the balance of
                   JAI_CMN_RG_OTH_BALANCES for the inserted tax type and register id. bug# 4146708 creates the objects

**********************************************************************/
  ln_balance := 0 ;
  /*Bug 5141459 Start*/
    OPEN cur_chk_consolidation(pr_new.source_register_id);
  FETCH cur_chk_consolidation INTO ln_balance;
  CLOSE cur_chk_consolidation;

  IF ln_balance = 1 THEN
    RETURN;
  END IF;
/*Bug 5141459 End*/
  SELECT DECODE(pr_new.source_register,'RG23A_P2','RG23A','RG23C_P2','RG23C','PLA','PLA')
    INTO lv_register_type
    FROM dual;

  IF pr_new.source_type IN ( 3,4) THEN
     /* Insertion into this table from JAI_IN_RG23D, JAI_RCV_CENVAT_CLAIMS . No need of balances calculation in this case*/
     return;

  ELSIF pr_new.source_type    = 1 THEN /* RG23 */

     OPEN cur_org_unit_id_rg23;
    FETCH cur_org_unit_id_rg23 into ln_org_unit_id;
    CLOSE cur_org_unit_id_rg23;

  ELSIF pr_new.source_type = 2 THEN /* PLA */

    OPEN cur_org_unit_id_pla;
    FETCH cur_org_unit_id_pla into ln_org_unit_id;
    CLOSE cur_org_unit_id_pla;

  END IF;

-- Retrieve the balance from JAI_CMN_RG_OTH_BALANCES

  SELECT count(1)
    INTO ln_balance_cnt
    FROM JAI_CMN_RG_OTH_BALANCES
   WHERE org_unit_id   = ln_org_unit_id
     AND tax_type      = pr_new.tax_type
     AND register_type = lv_register_type;

  IF ln_balance_cnt <> 0 THEN /* If there are no records in JAI_CMN_RG_OTH_BALANCES
                                 for that org_unit_id,tax_type,lv_register_type*/

    --Lock the table ja_in_oth_balances with a dummy update.

    UPDATE JAI_CMN_RG_OTH_BALANCES
       SET tax_type    = tax_type
     WHERE org_unit_id = ln_org_unit_id
       AND tax_type    = pr_new.tax_type
       AND register_type = lv_register_type;

      OPEN cur_balance;
     FETCH cur_balance INTO ln_balance;
     CLOSE cur_balance;

     --Added below by Bgowrava for Bug#6455886
     if ln_balance is null then
     ln_balance := 0;
     end if;

  ELSE

    ln_balance := 0;

    INSERT INTO JAI_CMN_RG_OTH_BALANCES( org_unit_id      ,
                                     tax_type         ,
                                     balance          ,
                                     register_type    ,
                                     created_by       ,
                                     creation_date    ,
                                     last_updated_by  ,
                                     last_update_date ,
                                     last_update_login)
                             VALUES( ln_org_unit_id     ,
                                     pr_new.tax_type      ,
                                     0                  ,
                                     lv_register_type   ,
                                     fnd_global.user_id ,
                                     sysdate            ,
                                     fnd_global.user_id ,
                                     sysdate            ,
                                     fnd_global.login_id
                                    );

END IF;

--Update closing and opening balances of JAI_CMN_RG_OTHERS accordingly.

 pr_new.opening_balance := ln_balance;

 IF pr_new.debit IS NOT NULL THEN

   pr_new.closing_balance := ln_balance - pr_new.debit;

 ELSIF pr_new.credit IS NOT NULL THEN

   pr_new.closing_balance := ln_balance + pr_new.credit;

 END IF ;

 UPDATE JAI_CMN_RG_OTH_BALANCES
    SET balance           = pr_new.closing_balance,
        last_updated_by   = fnd_global.user_id,
  last_update_date  = sysdate,
        last_update_login = fnd_global.login_id
  WHERE org_unit_id   = ln_org_unit_id
    AND tax_type      = pr_new.tax_type
    AND register_type = lv_register_type;

 /* Added an exception block by Ramananda for bug#4570303 */
 EXCEPTION
   WHEN OTHERS THEN
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_JRG_OTH_TRIGGER_PKG.BRI_T1 '  || substr(sqlerrm,1,1900);

END BRI_T1 ;

END JAI_JRG_OTH_TRIGGER_PKG ;

/
