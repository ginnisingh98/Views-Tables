--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RG_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RG_BALANCES_PKG" AS
/* $Header: jai_cmn_rg_bals.plb 120.1 2005/07/20 12:57:15 avallabh ship $ */

PROCEDURE insert_row(

  P_ORG_UNIT_ID                   IN  JAI_CMN_RG_BALANCES.org_unit_id%TYPE,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_BALANCES.organization_id%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_BALANCES.location_id%TYPE,
  P_PLA_BALANCE                   IN  JAI_CMN_RG_BALANCES.pla_balance%TYPE,
  P_RG23A_BALANCE                 IN  JAI_CMN_RG_BALANCES.rg23a_balance%TYPE,
  P_RG23C_BALANCE                 IN  JAI_CMN_RG_BALANCES.rg23c_balance%TYPE,
  P_CREATION_DATE                 IN  JAI_CMN_RG_BALANCES.creation_date%TYPE,
  P_CREATED_BY                    IN  JAI_CMN_RG_BALANCES.created_by%TYPE,
  P_LAST_UPDATE_DATE              IN  JAI_CMN_RG_BALANCES.last_update_date%TYPE,
  P_LAST_UPDATED_BY               IN  JAI_CMN_RG_BALANCES.last_updated_by%TYPE,
  P_LAST_UPDATE_LOGIN             IN  JAI_CMN_RG_BALANCES.last_update_login%TYPE,
  P_BASIC_PLA_BALANCE             IN  JAI_CMN_RG_BALANCES.basic_pla_balance%TYPE,
  P_ADDITIONAL_PLA_BALANCE        IN  JAI_CMN_RG_BALANCES.additional_pla_balance%TYPE,
  P_OTHER_PLA_BALANCE             IN  JAI_CMN_RG_BALANCES.other_pla_balance%TYPE,
  P_SIMULATE_FLAG                 IN  VARCHAR2,  --  DEFAULT 'N' File.Sql.35 by Brathod
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
) IS

/* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_balances_pkg.insert_row';

BEGIN
/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_cmn_rg_balances_pkg.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     16/07/2002   Vijay Shankar for Bug# 3496408, Version:115.0
                    Table handler Package for JAI_CMN_RG_BALANCES table

2. 08-Jun-2005  Version 116.2 jai_cmn_rg_bals -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

----------------------------------------------------------------------------------------------------------------------------*/
/*P_SIMULATE_FLAG                 := 'N' ; */ --File.Sql.35 by Brathod

  INSERT INTO JAI_CMN_RG_BALANCES(
    ORG_UNIT_ID,
    ORGANIZATION_ID,
    LOCATION_ID,
    PLA_BALANCE,
    RG23A_BALANCE,
    RG23C_BALANCE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    BASIC_PLA_BALANCE,
    ADDITIONAL_PLA_BALANCE,
    OTHER_PLA_BALANCE
  ) VALUES (
    P_ORG_UNIT_ID,
    P_ORGANIZATION_ID,
    P_LOCATION_ID,
    P_PLA_BALANCE,
    P_RG23A_BALANCE,
    P_RG23C_BALANCE,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN,
    P_BASIC_PLA_BALANCE,
    P_ADDITIONAL_PLA_BALANCE,
    P_OTHER_PLA_BALANCE
  );

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    P_PROCESS_STATUS  := 'E';
    P_PROCESS_MESSAGE :='Error in '||lv_object_name;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END insert_row;

PROCEDURE update_row(
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_BALANCES.organization_id%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_BALANCES.location_id%TYPE,
  p_register_type                 IN  VARCHAR2,
  p_amount_to_be_added            IN  NUMBER,
  P_SIMULATE_FLAG                 IN  VARCHAR2,   -- DEFAULT 'N' File.Sql.35 by Brathod
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
) IS

  ln_rg23a_amount   NUMBER := 0;
  ln_rg23c_amount   NUMBER := 0;
  ln_pla_amount     NUMBER := 0;

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_balances_pkg.update_row';


BEGIN

  IF p_register_type = 'A' THEN
    ln_rg23a_amount := p_amount_to_be_added;
  ELSIF p_register_type = 'C' THEN
    ln_rg23c_amount := p_amount_to_be_added;
  ELSIF p_register_type = 'PLA' THEN
    ln_pla_amount   := p_amount_to_be_added;
  ELSE
    P_PROCESS_STATUS := 'E';
    P_PROCESS_MESSAGE := 'jai_cmn_rg_balances_pkg.update_row: Not able to find Register Type';
    RETURN;
  END IF;

  UPDATE JAI_CMN_RG_BALANCES SET
    PLA_BALANCE                   = nvl(PLA_BALANCE, 0) + ln_pla_amount,
    RG23A_BALANCE                 = nvl(RG23A_BALANCE, 0) + ln_rg23a_amount,
    RG23C_BALANCE                 = nvl(RG23C_BALANCE, 0) + ln_rg23c_amount,
    LAST_UPDATE_DATE              = SYSDATE,
    LAST_UPDATED_BY               = FND_GLOBAL.user_id,
    LAST_UPDATE_LOGIN             = FND_GLOBAL.login_id
  WHERE organization_id = p_organization_id
  AND location_id = p_location_id;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    P_PROCESS_STATUS  := null;
    P_PROCESS_MESSAGE := null;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END update_row;

PROCEDURE get_balance(
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_BALANCES.organization_id%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_BALANCES.location_id%TYPE,
  P_REGISTER_TYPE                 IN  VARCHAR2,
  P_OPENING_BALANCE OUT NOCOPY VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
) IS

  ln_organization_id  NUMBER;
  ln_rg23a_amount   NUMBER := 0;
  ln_rg23c_amount   NUMBER := 0;
  ln_pla_amount     NUMBER := 0;

  CURSOR c_rg_balances(cp_organization_id IN NUMBER, cp_location_id IN NUMBER) IS
    SELECT organization_id, rg23a_balance, rg23c_balance, pla_balance
    FROM JAI_CMN_RG_BALANCES
    WHERE organization_id = cp_organization_id
    AND location_id = cp_location_id;

BEGIN

  OPEN c_rg_balances(p_organization_id, p_location_id);
  FETCH c_rg_balances INTO ln_organization_id, ln_rg23a_amount, ln_rg23c_amount, ln_pla_amount;
  CLOSE c_rg_balances;

  IF ln_organization_id IS NULL THEN
    p_process_status  := 'E';
    p_process_message := 'No Record found in JAI_CMN_RG_BALANCES';
    RETURN;
  END IF;

  IF p_register_type = 'A' THEN
    P_OPENING_BALANCE := ln_rg23a_amount;
  ELSIF p_register_type = 'C' THEN
    P_OPENING_BALANCE := ln_rg23c_amount;
  ELSIF p_register_type = 'PLA' THEN
    P_OPENING_BALANCE := ln_pla_amount;
  ELSE
    p_opening_balance := 0;
  END IF;

END get_balance;

END jai_cmn_rg_balances_pkg;

/
