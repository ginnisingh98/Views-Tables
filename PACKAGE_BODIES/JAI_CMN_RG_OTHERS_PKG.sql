--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RG_OTHERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RG_OTHERS_PKG" AS
/* $Header: jai_cmn_rg_oth.plb 120.2 2007/05/04 13:43:25 csahoo ship $ */
/***************************************************************************************************
CREATED BY       : ssumaith
CREATED DATE     : 11-JAN-2005
ENHANCEMENT BUG  : 4136981
PURPOSE          : To pass cess register entries
CALLED FROM      : jai_om_rg_pkg.ja_in_rg23_part_ii_entry , jai_om_rg_pkg.pla_emtry , jai_om_rg_pkg.ja_in23d_entry



/*----------------------------------------------------------------------------------------------------------------------------

CHANGE HISTORY for FILENAME: jai_rg_others_pkg_b.sql
S.No  dd/mm/yyyy   Author and Details
1     17/02/2005   ssumaith  - File version 115.1
                   IF cess amount is passed as zero, an error is thrown to the user that cess amount cannot be zero
                   This may not be correct at all times. Hence code has been added to return control with success
                   and not process the insert into JAI_CMN_RG_OTHERS table with zero debit and credit.

2. 08-Jun-2005  Version 116.1 jai_cmn_rg_oth -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

3. 14-Jun-2005      rchandan for bug#4428980, Version 116.2
                        Modified the object to remove literals from DML statements and CURSORS.
4.16-apr-2007    Vkaranam For bug#5989740,File version 120.2
                 Forward Porting The changes in 115 bug #5907436
                 Added a new peocedure check_sh_balances.



------------------------------------------------------------------------------------------------------------------------------

***************************************************************************************************/

procedure insert_row (p_source_type         JAI_CMN_RG_OTHERS.SOURCE_TYPE%TYPE        ,
                      p_source_name         JAI_CMN_RG_OTHERS.SOURCE_REGISTER%TYPE    ,
                      p_source_id           JAI_CMN_RG_OTHERS.SOURCE_REGISTER_ID%TYPE ,
                      p_tax_type            JAI_CMN_RG_OTHERS.TAX_TYPE%TYPE           ,
                      debit_amt             JAI_CMN_RG_OTHERS.DEBIT%TYPE              ,
                      credit_amt            JAI_CMN_RG_OTHERS.CREDIT%TYPE             ,
                      p_process_flag OUT NOCOPY VARCHAR2                              ,
                      p_process_msg OUT NOCOPY VARCHAR2                              ,
                      p_attribute1          VARCHAR2 DEFAULT NULL                 ,
                      p_attribute2          VARCHAR2 DEFAULT NULL                 ,
                      p_attribute3          VARCHAR2 DEFAULT NULL                 ,
                      p_attribute4          VARCHAR2 DEFAULT NULL                 ,
                      p_attribute5          VARCHAR2 DEFAULT NULL
                     ) IS

  CURSOR c_rg_other_id IS
  SELECT JAI_CMN_RG_OTHERS_S.nextval
  FROM   dual;

  ln_rg_other_id JAI_CMN_RG_OTHERS.RG_OTHER_ID%TYPE;
  ln_user_id     NUMBER ; --:= fnd_global.user_id  File.Sql.35 by Brathod
BEGIN
    ln_user_id  := fnd_global.user_id ; -- File.Sql.35 by Brathod
    IF nvl(debit_amt,0) = 0  AND NVL(credit_amt,0) =0 THEN
      p_process_flag := jai_constants.successful;
      p_process_msg  := NULL;
      return;
    END IF;

    IF p_source_type IS NULL THEN
      p_process_flag := jai_constants.expected_error;
      p_process_msg  := 'jai_cmn_rg_others_pkg - Source type cannot be Null';
      return;
    END IF;

    IF p_source_name IS NULL THEN
        p_process_flag := jai_constants.expected_error;
        p_process_msg  := 'jai_cmn_rg_others_pkg -Source Name cannot be Null';
        return;
    end if;

    IF p_tax_type IS NULL THEN
        p_process_flag := jai_constants.expected_error;
        p_process_msg  := 'jai_cmn_rg_others_pkg - Tax type cannot be Null';
        return;
    END IF;

    OPEN  c_rg_other_id;
    FETCH c_rg_other_id into  ln_rg_other_id;
    CLOSE c_rg_other_id;

    Insert into JAI_CMN_RG_OTHERS
    (
    rg_other_id              ,
    source_type              ,
    source_register          ,
    source_register_id       ,
    tax_type                 ,
    credit                   ,
    debit                    ,
    created_by               ,
    creation_date            ,
    last_updated_by          ,
    last_update_date         ,
    last_update_login
    )
    Values
    (
     ln_rg_other_id         ,
     p_source_type          ,
     p_source_name          ,
     p_source_id            ,
     p_tax_type             ,
     credit_amt             ,
     debit_amt              ,
     ln_user_id             ,
     sysdate                ,
     ln_user_id             ,
     sysdate                ,
     fnd_global.login_id
    );
    p_process_flag := jai_constants.successful;

EXCEPTION
  WHEN OTHERS THEN
    p_process_flag := jai_constants.unexpected_error;
    p_process_msg  := 'Error Occured in jai_cmn_rg_others_pkg.insert_row - ' || substr(sqlerrm,1,900);
END insert_row;


procedure check_balances(p_organization_id        JAI_CMN_INVENTORY_ORGS.ORGANIZATION_ID%TYPE  ,
                         p_location_id            HR_LOCATIONS.LOCATION_ID%TYPE                     ,
                         p_register_type          JAI_CMN_RG_OTH_BALANCES.REGISTER_TYPE%TYPE            ,
                         p_trx_amount             NUMBER                                            ,
                         p_process_flag OUT NOCOPY VARCHAR2                                          ,
                         p_process_message OUT NOCOPY VARCHAR2
                       )
IS

  CURSOR c_org_unit_id IS
  SELECT org_unit_id
  FROM   JAI_CMN_INVENTORY_ORGS
  WHERE  organization_id = p_organization_id
  AND    location_id     = p_location_id ;

  CURSOR c_balance_cur(cp_org_unit_id   JAI_CMN_INVENTORY_ORGS.ORG_UNIT_ID%TYPE) IS
  SELECT NVL(SUM(balance),0)
  FROM   JAI_CMN_RG_OTH_BALANCES
  WHERE  org_unit_id = cp_org_unit_id
  and    register_type = p_register_type
  and    tax_type in ( jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_cvd_edu_cess);  --rchandan for bug#4428980

  ln_org_unit_id       NUMBER;
  ln_balance_avlbl     NUMBER;

BEGIN

  IF  NVL(p_trx_amount,0) = 0 THEN
     p_process_flag    := jai_constants.successful;
     p_process_message := NULL;
     RETURN;
  END IF;

  OPEN  c_org_unit_id;
  FETCH c_org_unit_id into ln_org_unit_id;
  CLOSE c_org_unit_id;

  IF ln_org_unit_id IS NULL then
     p_process_flag    := jai_constants.expected_error;
     p_process_message := 'JAI_CMN_RG_OTHERS.check_balances => Invalid Organization and Location Combination passed ';
     return;
  END IF;

  OPEN  c_balance_cur(ln_org_unit_id);
  FETCH c_balance_cur into ln_balance_avlbl;
  close c_balance_cur;

  IF ln_balance_avlbl = 0 THEN
     p_process_flag    := jai_constants.expected_error;
     p_process_message := 'JAI_CMN_RG_OTHERS.check_balances => No Balance Available for the organization , location and register type combination ';
     return;
  END IF;

  IF p_trx_amount IS NULL THEN
     p_process_flag    := jai_constants.expected_error;
     p_process_message := 'JAI_CMN_RG_OTHERS.check_balances => Input Transaction Amount is NULL  ';
     return;
  END IF;

  IF ln_balance_avlbl < p_trx_amount THEN
     p_process_flag    := jai_constants.expected_error;
     p_process_message := 'JAI_CMN_RG_OTHERS.check_balances => Sufficient Balance Not Available for the organization , location and register type combination ';
     return;
  END IF;

  p_process_flag    := jai_constants.successful;
  p_process_message := NULL;

EXCEPTION
 WHEN others THEN
   p_process_flag    := jai_constants.unexpected_error;
   p_process_message := 'JAI_CMN_RG_OTHERS.check_balances => Error Occured : ' || substr(sqlerrm,1,1000);
END;

/*Procedure check_sh_balances is added to check balances for secondary and higher education cess */
-- start 5989740
procedure check_sh_balances(p_organization_id       JAI_CMN_INVENTORY_ORGS.ORGANIZATION_ID%TYPE  ,
                            p_location_id            HR_LOCATIONS.LOCATION_ID%TYPE                     ,
                            p_register_type          JAI_CMN_RG_OTH_BALANCES.REGISTER_TYPE%TYPE            ,
                            p_trx_amount             NUMBER                                            ,
                            p_process_flag OUT NOCOPY VARCHAR2                                          ,
                            p_process_message OUT NOCOPY VARCHAR2
                       )
IS

  CURSOR c_org_unit_id IS
  SELECT org_unit_id
  FROM   JAI_CMN_INVENTORY_ORGS
  WHERE  organization_id = p_organization_id
  AND    location_id     = p_location_id ;


  CURSOR c_balance_cur(cp_org_unit_id   JAI_CMN_INVENTORY_ORGS.ORG_UNIT_ID%TYPE) IS
  SELECT NVL(SUM(balance),0)
  FROM   JAI_CMN_RG_OTH_BALANCES
  WHERE  org_unit_id = cp_org_unit_id
  and    register_type = p_register_type
  and    tax_type in ( jai_constants.tax_type_sh_exc_edu_cess,
		       jai_constants.tax_type_sh_cvd_edu_cess
		     );

  ln_org_unit_id       NUMBER;
  ln_balance_avlbl     NUMBER;

BEGIN

  IF  NVL(p_trx_amount,0) = 0 THEN
     p_process_flag    := jai_constants.successful;
     p_process_message := NULL;
     RETURN;
  END IF;

  OPEN  c_org_unit_id;
  FETCH c_org_unit_id into ln_org_unit_id;
  CLOSE c_org_unit_id;

  IF ln_org_unit_id IS NULL then
     p_process_flag    := jai_constants.expected_error;
     p_process_message := 'JAI_CMN_RG_OTHERS.check_sh_balances => Invalid Organization and Location Combination passed ';
     return;
  END IF;

  OPEN  c_balance_cur(ln_org_unit_id);
  FETCH c_balance_cur into ln_balance_avlbl;
  close c_balance_cur;

  IF ln_balance_avlbl = 0 THEN
     p_process_flag    := jai_constants.expected_error;
     p_process_message := 'JAI_CMN_RG_OTHERS.check_sh_balances => No Balance Available for the organization , location and register type combination ';
     return;
  END IF;

  IF p_trx_amount IS NULL THEN
     p_process_flag    := jai_constants.expected_error;
     p_process_message := 'JAI_CMN_RG_OTHERS.check_sh_balances => Input Transaction Amount is NULL  ';
     return;
  END IF;

  IF ln_balance_avlbl < p_trx_amount THEN
     p_process_flag    := jai_constants.expected_error;
     p_process_message := 'JAI_CMN_RG_OTHERS.check_sh_balances => Sufficient Balance Not Available for the organization , location and register type combination ';
     return;
  END IF;

  p_process_flag    := jai_constants.successful;
  p_process_message := NULL;

EXCEPTION
 WHEN others THEN
   p_process_flag    := jai_constants.unexpected_error;
   p_process_message := 'JAI_CMN_RG_OTHERS.check_sh_balances => Error Occured : ' || substr(sqlerrm,1,1000);
END check_sh_balances;
--end 5989740


END jai_cmn_rg_others_pkg;

/
