--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RG_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RG_TRANSFER_PKG" AS
/* $Header: jai_cmn_rg_trnfr.plb 120.6.12010000.2 2008/08/07 14:27:35 jmeena ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_cmn_rg_trnfr -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

14-Jun-2005   rchandan for bug#4428980, Version 116.3
              Modified the object to remove literals from DML statements and CURSORS.
17/04/2007     bduvarag for the Bug#5989740, file version 120.3
		Forward porting the changes done in 11i bug#5907436
17/04/2007	bduvarag for the Bug#4543171, file version 120.3
		Forward porting the changes done in 11i bug#4404994
17/04/2007	bduvarag for the Bug#5349052, file version 120.3
		Forward porting the changes done in 11i bug#5352134
02/05/2007	bduvarag for the Bug#5141459, file version 120.4
		Forward porting the changes done in 11i bug#4548378
14-may-07   kunkumar made changes for Budget and ST by IO and Build issues resolved

25-JUL-2008 Changed by JMEENA for bug#7260552
		   Reset the variable lv_debit and lv_credit to NULL in the procedure insert_rg_others.
		   Added the code to populate the gl_interface table for the SH CESS accounting and added conditions
		   to verify that Cenvat / Cess / SH Cess Accounts are not NULL.


*/


PROCEDURE balance_transfer (
  p_organization_id   NUMBER,
  p_to_organization_id  NUMBER,
  p_location_id     NUMBER,
  p_to_location_id    NUMBER,
  p_register        VARCHAR2,
  p_amount        NUMBER,
  p_cess_amount   NUMBER,/*Bug 5989740 bduvarag*/
   p_sh_cess_amount NUMBER,
  p_process_flag   OUT NOCOPY VARCHAR2,
  p_process_message OUT NOCOPY   VARCHAR2

) IS

/* Added by Ramananda for bug#4407165 */
lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_transfer_pkg.balance_transfer';
lv_debit       jai_cmn_rg_others.debit%TYPE ;    --rchandan for bug#4428980
lv_credit      jai_cmn_rg_others.credit%TYPE ;   --rchandan for bug#4428980

  CURSOR c_rg_balances(p_organization_id NUMBER, p_location_id NUMBER) IS
    select nvl(rg23a_balance,0), nvl(rg23c_balance,0), nvl(pla_balance,0)
    from   JAI_CMN_RG_BALANCES
    where  organization_id = p_organization_id
    and location_id = p_location_id;

  --Added by Sanjikum for cess for Bug #4136939
  CURSOR c_oth_balances(p_organization_id IN  JAI_CMN_INVENTORY_ORGS.organization_id%TYPE,
                        p_location_id     IN  JAI_CMN_INVENTORY_ORGS.location_id%TYPE,
                        p_register_type   IN  JAI_CMN_RG_OTH_BALANCES.register_type%TYPE,
                        p_tax_type        IN  JAI_CMN_RG_OTH_BALANCES.tax_type%TYPE DEFAULT NULL)
  IS
    SELECT  NVL(SUM(balance),0) balance
    FROM    JAI_CMN_RG_OTH_BALANCES a,
            JAI_CMN_INVENTORY_ORGS b
    WHERE   a.org_unit_id = b.org_unit_id
    AND     b.organization_id = p_organization_id
    AND     b.location_id = p_location_id
    AND     a.register_type = p_register_type
    AND     a.tax_type in (jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_cvd_edu_cess)
    AND     a.tax_type = NVL(p_tax_type,a.tax_type);
/*Bug 5989740 bduvarag start*/
	CURSOR c_sh_oth_balances(p_organization_id IN  JAI_CMN_INVENTORY_ORGS.organization_id%TYPE,
													 p_location_id     IN  JAI_CMN_INVENTORY_ORGS.location_id%TYPE,
													 p_register_type   IN  JAI_CMN_RG_OTH_BALANCES.register_type%TYPE,
													 p_tax_type        IN  JAI_CMN_RG_OTH_BALANCES.tax_type%TYPE DEFAULT NULL)
	IS
		SELECT  NVL(SUM(balance),0) balance
		FROM    JAI_CMN_RG_OTH_BALANCES a,
						JAI_CMN_INVENTORY_ORGS b
		WHERE   a.org_unit_id = b.org_unit_id
		AND     b.organization_id = p_organization_id
		AND     b.location_id = p_location_id
		AND     a.register_type = p_register_type
		AND     a.tax_type in (jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess)
    AND     a.tax_type = NVL(p_tax_type,a.tax_type);
/*Bug 5989740 bduvarag end*/
  CURSOR balances_to_exist IS
    select count(1)
    from   JAI_CMN_RG_BALANCES
    where  organization_id = p_to_organization_id
    and location_id = p_to_location_id;

  CURSOR balance_cur(p_serial_no IN NUMBER, p_org_id NUMBER, p_location_id NUMBER,
      p_fin_year NUMBER, p_register_type VARCHAR2) IS
    SELECT nvl(closing_balance,0)
    FROM JAI_CMN_RG_23AC_II_TRXS
    WHERE organization_id = p_org_id
    AND location_id = p_location_id
    AND slno  = p_serial_no
    AND register_type = p_register_type
    AND fin_year = p_fin_year;

  CURSOR serial_no_cur(p_org_id NUMBER, p_location_id NUMBER, p_fin_year NUMBER, p_register_type VARCHAR2) IS
    SELECT nvl(max(slno),0)
    FROM JAI_CMN_RG_23AC_II_TRXS
    WHERE organization_id = p_org_id
    and location_id = p_location_id
    and fin_year = p_fin_year
    and register_type = p_register_type;

  CURSOR fin_year_cur(p_org_id NUMBER, p_location_id NUMBER) IS
    Select max(fin_year) fin_year
    From   JAI_CMN_FIN_YEARS
    Where  organization_id = p_org_id and
    NVL(fin_active_flag,'N') = 'Y';

  CURSOR c_rg23_fin_yr(p_org_id NUMBER, p_location_id NUMBER, p_register VARCHAR2) IS
    Select max(fin_year) fin_year
    From   JAI_CMN_RG_23AC_II_TRXS
    Where  organization_id = p_org_id
    and location_id = p_location_id
    and register_type = p_register;

  CURSOR c_pla_fin_yr(p_org_id NUMBER, p_location_id NUMBER) IS
    Select max(fin_year) fin_year
    From   JAI_CMN_RG_PLA_TRXS
    Where organization_id = p_org_id
    and location_id = p_location_id;

  CURSOR pla_serial_no_cur(p_org_id NUMBER, p_location_id NUMBER, p_fin_year NUMBER) IS
    SELECT nvl(max(slno),0)
    FROM JAI_CMN_RG_PLA_TRXS
    WHERE organization_id = p_org_id
    and location_id = p_location_id
    and fin_year = p_fin_year;

  CURSOR pla_balance_cur(p_previous_serial_no IN NUMBER, p_org_id NUMBER, p_location_id NUMBER, p_fin_year NUMBER) IS
    SELECT nvl(closing_balance,0)
    FROM JAI_CMN_RG_PLA_TRXS
    WHERE organization_id = p_org_id
    AND location_id = p_location_id
    AND slno  = p_previous_serial_no
    AND fin_year = p_fin_year;

  v_rg23a_bal                 NUMBER;
  v_rg23c_bal                 NUMBER;
  v_pla_bal                   NUMBER;
  v_to_rg23a_bal              NUMBER;
  v_to_rg23c_bal              NUMBER;
  v_to_pla_bal                NUMBER;

  --Start Added by Sanjikum for cess for Bug #4136939
  v_excise_cess_bal           NUMBER;
  v_excise_cess_amount        NUMBER;
  v_cvd_cess_amount           NUMBER;
  v_oth_balances              c_oth_balances%ROWTYPE;
  v_source_register           JAI_CMN_RG_OTHERS.source_register%TYPE;
  --End Added by Sanjikum for cess for Bug #4136939
/*Bug 5989740 bduvarag start*/
    v_sh_excise_cess_bal				NUMBER;
  v_sh_excise_cess_amount     NUMBER;
  v_sh_cvd_cess_amount        NUMBER;
  v_sh_oth_balances						c_sh_oth_balances%ROWTYPE;
/*Bug 5989740 bduvarag end*/
  v_check_amount              NUMBER := 0;
  v_exist                     NUMBER := 0;
  v_previous_serial_no        NUMBER;
  v_closing_balance           NUMBER;
  v_fin_year                  NUMBER;
  v_register                  CHAR(1);
  v_to_previous_serial_no     NUMBER;
  v_to_closing_balance        NUMBER;
  v_to_fin_year               NUMBER;

  -- Vijay Shankar for BUG#3587423
  v_from_register_id          NUMBER;
  v_to_register_id            NUMBER;
  v_slno                      NUMBER;
  v_to_slno                   NUMBER;
  v_opening_balance           NUMBER;
  v_to_opening_balance        NUMBER;
  v_to_transaction_id         NUMBER := 18;
  v_src_transaction_id        NUMBER := 33;
  v_not_a_first_transaction   BOOLEAN := true;
  v_remarks                   VARCHAR2(50); -- := 'RG Funds Transfer';  File.Sql.35 by Brathod
  v_user_id                   NUMBER ;  -- := nvl(to_number(FND_PROFILE.value('USER_ID')), -1) File.Sql.35 by Brathod
  v_login_id                  NUMBER ;-- := nvl(to_number(FND_PROFILE.value('LOGIN_ID')), -1) File.Sql.35 by Brathod
lv_reference_num            jai_cmn_rg_23ac_ii_trxs.reference_num%TYPE ;--rchandan for bug#4428980
/*Bug 4543171 bduvarag start*/
   CURSOR currency_cur  IS
   SELECT currency_code
   FROM JAI_CMN_RG_BALANCES_v
   WHERE organization_id = p_Organization_ID and Location_ID = p_Location_ID;

   /* Added by Ramananda for bug#4404994, start */

   CURSOR rg23a_account_cur( p_orgid  IN  Number,
                             p_locid  IN  Number
                            )IS
   SELECT MODVAT_RM_ACCOUNT_ID
   FROM JAI_CMN_INVENTORY_ORGS
   WHERE organization_id = p_orgid
   AND   location_id    = p_locid;

   CURSOR rg23c_account_cur( p_orgid  IN  Number,
                             p_locid  IN  Number
                            )IS
   SELECT MODVAT_CG_ACCOUNT_ID
   FROM JAI_CMN_INVENTORY_ORGS
   WHERE organization_id = p_orgid
   AND   location_id    = p_locid;

   CURSOR pla_account_cur( p_orgid  IN  Number,
                             p_locid  IN  Number
                            )IS
   SELECT MODVAT_PLA_ACCOUNT_ID
   FROM JAI_CMN_INVENTORY_ORGS
   WHERE organization_id = p_orgid
   AND   location_id    = p_locid;


   CURSOR cur_cess_accountid ( p_orgid  IN  Number, p_locid  IN  Number, p_regtyp IN  VARCHAR2) IS
   SELECT
   decode( p_regtyp,
          'A', EXCISE_EDU_CESS_RM_ACCOUNT,
          'C', EXCISE_EDU_CESS_CG_ACCOUNT
         ) cess_account_id,
   --added by JMEENA for BUG#7260552
   decode( p_regtyp,
          'A', SH_CESS_RM_ACCOUNT,
          'C', SH_CESS_CG_ACCOUNT_ID
         ) sh_cess_account_id

   FROM
   JAI_CMN_INVENTORY_ORGS
   WHERE organization_id = p_orgid
   AND   location_id    = p_locid;

   lv_currency               varchar2(10) ;
   --Commented by JMEENA for bug#7260552
   --lv_from_cess_account_id   number ;
   --lv_to_cess_account_id     number ;
   --Added by JMEENA for bug#7260552
   lv_from_cess_account_id   cur_cess_accountid%ROWTYPE ;
   lv_to_cess_account_id     cur_cess_accountid%ROWTYPE ;
   lv_from_account_id        number ;
   lv_to_account_id          number ;

/*Bug 4543171 bduvarag end*/
  --Added by Sanjikum for cess for Bug #4136939
  PROCEDURE insert_rg_others( p_organization_id     IN  JAI_CMN_INVENTORY_ORGS.organization_id%TYPE,
                              p_location_id         IN  JAI_CMN_INVENTORY_ORGS.location_id%TYPE,
                              p_register_type       IN  VARCHAR2,
                              p_source_register     IN  VARCHAR2,
                              p_excise_cess_amount  IN  NUMBER,
                              p_sh_exc_cess_amount	IN	NUMBER,			/*Bug 5989740 bduvarag*/
                              p_sh_cvd_cess_amount	IN	NUMBER,			/*Bug 5989740 bduvarag*/
                              p_cvd_cess_amount     IN  NUMBER,
                              p_transfer_from_to    IN  VARCHAR2,
                              p_register_id         IN  NUMBER,
                              p_fin_year            IN  NUMBER)
  IS

    /* Added by Ramananda for bug#4407165 */
    lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_transfer_pkg.insert_rg_others';

    CURSOR c_pla_cess_slno(c_tax_type VARCHAR2) IS
    select  max(slno) slno
    from    JAI_CMN_RG_PLA_TRXS a
    where   organization_id = p_organization_id
    and     location_id = p_location_id
    and     fin_year = p_fin_year
    and     register_id < 0
    and   exists (select  '1'
                  from    JAI_CMN_RG_OTHERS
                  where   source_type = 2 --2 is for PLA
                  and     source_register_id = a.register_id
                  and     tax_type = c_tax_type);

    CURSOR c_pla_cess_master_org(c_slno NUMBER, c_tax_type VARCHAR) IS
    Select  NVL(a.closing_balance,0) closing_balance
    from    JAI_CMN_RG_OTHERS a,
            JAI_CMN_RG_PLA_TRXS b
    Where   a.source_type = 2 --2 is for PLA
    AND     b.register_id = a.source_register_id
    AND     b.organization_id = p_organization_id
    and     b.location_id = p_location_id
    and     a.tax_type = c_tax_type
    and     b.slno = c_slno
    and     b.fin_year = p_fin_year;

    cursor c_pla_cess_non_master_org(c_tax_type VARCHAR2) is
    Select  nvl(a.closing_balance,0) closing_balance
    from    JAI_CMN_RG_OTHERS a
    Where   a.source_type = 2 --2 is for PLA
    and     a.tax_type = c_tax_type /*Bug 5141459 bduvarag*/
    AND     a.source_register_id =  (SELECT b.register_id
				                               FROM JAI_CMN_RG_PLA_TRXS b
				                              WHERE b.slno =(
				                                 SELECT MAX(JIP.slno)
				               		     FROM JAI_CMN_RG_PLA_TRXS  JIP
				                               WHERE JIP.organization_id = p_organization_id
				                                AND JIP.location_id     = p_location_id
				                               	AND JIP.fin_year        = p_fin_year
				                               	AND JIP.register_id     > 0
				                              	AND EXISTS (SELECT '1'
						              FROM JAI_CMN_RG_OTHERS
						             WHERE source_type = 2
						              AND source_register_id = JIP.register_id
						              AND source_register    = p_source_register
                                                              AND tax_type           = c_tax_type)
						                	)
				                                AND b.organization_id = p_organization_id
				                                AND b.location_id     = p_location_id
				                                AND b.fin_year        = p_fin_year
                                    );


    CURSOR c_rg23_cess_slno(c_tax_type VARCHAR2, c_register_type VARCHAR2, c_source_register VARCHAR2) IS
    select  max(slno) slno
    from    JAI_CMN_RG_23AC_II_TRXS a
    where   organization_id = p_organization_id
    and     location_id = p_location_id
    and     fin_year = p_fin_year
    AND     register_type = c_register_type
    and     register_id < 0
    and   exists (select  '1'
                  from    JAI_CMN_RG_OTHERS
                  where   source_type = 1 --1 is for RG23
                  and     source_register_id = a.register_id
                  and     source_register = c_source_register
                  and     tax_type = c_tax_type);

    CURSOR c_rg23_cess_master_org(c_slno  NUMBER, c_tax_type VARCHAR,
                                  c_register_type VARCHAR2, c_source_register VARCHAR2) IS
    Select  NVL(a.closing_balance,0) closing_balance
    from    JAI_CMN_RG_OTHERS a,
            JAI_CMN_RG_23AC_II_TRXS b
    Where   a.source_type = 1 --1 is for RG23
    AND     b.register_id = a.source_register_id
    AND     b.organization_id = p_organization_id
    and     b.location_id = p_location_id
    and     a.tax_type = c_tax_type
    and     b.slno = c_slno
    and     b.fin_year = p_fin_year
    and     b.register_type = c_register_type
    AND     a.source_register = c_source_register;

    cursor c_rg23_cess_non_master_org(c_tax_type VARCHAR2, c_register_type VARCHAR2, c_source_register VARCHAR2) IS
    Select  nvl(a.closing_balance,0) closing_balance
    from    JAI_CMN_RG_OTHERS a
    Where   a.source_type = 1 --1 is for RG23
    and     a.tax_type = c_tax_type
    and     a.source_register = c_source_register/*Bug 5141459 bduvarag*/
    AND     a.source_register_id =  (SELECT register_id
				                               FROM JAI_CMN_RG_23AC_II_TRXS b
				                              WHERE b.slno =(
				                                  SELECT MAX(JIRP.slno)
											                           		      FROM JAI_CMN_RG_23AC_II_TRXS  JIRP
											                                   WHERE JIRP.organization_id = p_organization_id
											                                     AND JIRP.location_id     = p_location_id
											                                  	 AND JIRP.fin_year        = p_fin_year
											                                     AND JIRP.register_type   = p_register_type
											                                     AND EXISTS (SELECT '1'
																													               FROM JAI_CMN_RG_OTHERS
																													              WHERE source_type = 2
																													                AND source_register_id = JIRP.register_id
																													                AND source_register    = p_source_register
                                                                          AND tax_type           = c_tax_type
                                                                      )
											                              )
				                                 AND b.organization_id = p_organization_id
				                                 AND b.location_id     = p_location_id
				                                 AND b.fin_year        = p_fin_year
				                                 AND b.register_type   = p_register_type

                                    );


    /*CURSOR cess_balance_cur_pla(c_organization_id IN  JAI_CMN_INVENTORY_ORGS.organization_id%TYPE,
                                c_location_id     IN  JAI_CMN_INVENTORY_ORGS.location_id%TYPE,
                                c_source_register IN  VARCHAR2,
                                c_tax_type        IN  JAI_CMN_RG_OTH_BALANCES.tax_type%TYPE) IS
    SELECT  nvl(a.closing_balance,0) closing_balance
    FROM    JAI_CMN_RG_OTHERS a
    WHERE   a.source_type = 2 --2 is for JAI_CMN_RG_PLA_TRXS
    AND     a.source_register = c_source_register
    AND     a.tax_type = c_tax_type
    AND     abs(a.source_register_id) = (SELECT max(abs(c.source_register_id))
                                        FROM    JAI_CMN_RG_PLA_TRXS b,
                                                JAI_CMN_RG_OTHERS c
                                        WHERE   b.register_id = c.source_register_id
                                        AND     b.organization_id = c_organization_id
                                        AND     b.location_id = c_location_id
                                        AND     c.tax_type = c_tax_type
                                        AND     c.source_type = 2 --2 is for JAI_CMN_RG_PLA_TRXS
                                        AND     c.source_register = c_source_register);

    CURSOR cess_balance_cur(c_organization_id IN  JAI_CMN_INVENTORY_ORGS.organization_id%TYPE,
                            c_location_id     IN  JAI_CMN_INVENTORY_ORGS.location_id%TYPE,
                            c_register_type   IN  VARCHAR2,
                            c_source_register IN  VARCHAR2,
                            c_tax_type        IN  JAI_CMN_RG_OTH_BALANCES.tax_type%TYPE) IS
    SELECT  nvl(a.closing_balance,0) closing_balance
    FROM    JAI_CMN_RG_OTHERS a
    WHERE   a.source_type = 1 --1 is for JAI_CMN_RG_23AC_II_TRXS
    AND     a.source_register = c_source_register
    AND     a.tax_type = c_tax_type
    AND     abs(a.source_register_id) = (SELECT max(abs(c.source_register_id))
                                        FROM    JAI_CMN_RG_23AC_II_TRXS b,
                                                JAI_CMN_RG_OTHERS c
                                        WHERE   b.register_id = c.source_register_id
                                        AND     b.organization_id = c_organization_id
                                        AND     b.location_id = c_location_id
                                        AND     b.register_type = c_register_type
                                        AND     c.tax_type = c_tax_type
                                        AND     c.source_type = 1 --1 is for JAI_CMN_RG_23AC_II_TRXS
                                        AND     c.source_register = c_source_register);*/

    v_cess_amount               JAI_CMN_RG_OTHERS.debit%TYPE;
    v_cess_opening_balance      JAI_CMN_RG_OTHERS.opening_balance%TYPE;
    v_cess_closing_balance      JAI_CMN_RG_OTHERS.closing_balance%TYPE;
    v_tax_type                  JAI_CMN_RG_OTH_BALANCES.tax_type%TYPE;
    v_source_type               NUMBER(1);
    v_slno                      NUMBER;

  BEGIN
    FOR i in 1..4 LOOP/*Bug 5989740 bduvarag*/
      v_tax_type := NULL;
      v_cess_amount := 0;
      IF i = 1 AND p_excise_cess_amount > 0 THEN
        v_tax_type := jai_constants.tax_type_exc_edu_cess;
        v_cess_amount := p_excise_cess_amount;
      ELSIF i = 2 AND p_cvd_cess_amount > 0 THEN
        v_tax_type := jai_constants.tax_type_cvd_edu_cess;
        v_cess_amount := p_cvd_cess_amount;
	/*Bug 5989740 bduvarag start*/
      ELSIF i = 3 AND p_sh_exc_cess_amount > 0 THEN
	v_tax_type := jai_constants.tax_type_sh_exc_edu_cess;
        v_cess_amount := p_sh_exc_cess_amount;
      ELSIF i = 4 AND p_sh_cvd_cess_amount > 0 THEN
      	v_tax_type := jai_constants.tax_type_sh_cvd_edu_cess;
        v_cess_amount := p_sh_cvd_cess_amount;
/*Bug 5989740 bduvarag end*/
      END IF;

      IF v_cess_amount = 0 THEN
        goto NEXT_RECORD;
      END IF;

      IF p_register_type <> 'PLA' THEN
        OPEN c_rg23_cess_slno(v_tax_type, p_register_type, p_source_register);
        FETCH c_rg23_cess_slno INTO v_slno;
        CLOSE c_rg23_cess_slno;

        IF v_slno IS NULL THEN
          OPEN c_rg23_cess_non_master_org(v_tax_type, p_register_type, p_source_register);
          FETCH c_rg23_cess_non_master_org INTO v_cess_opening_balance;
          CLOSE c_rg23_cess_non_master_org;
        ELSE
          OPEN c_rg23_cess_master_org(v_slno, v_tax_type, p_register_type, p_source_register);
          FETCH c_rg23_cess_master_org INTO v_cess_opening_balance;
          CLOSE c_rg23_cess_master_org;
        END IF;


        /*OPEN cess_balance_cur(p_organization_id, p_location_id, p_register_type, p_source_register, v_tax_type);
        FETCH cess_balance_cur INTO v_cess_opening_balance;
        CLOSE cess_balance_cur;*/

        v_source_type := 1;

      ELSIF p_register_type = 'PLA' THEN
        /*OPEN cess_balance_cur_pla(p_organization_id, p_location_id, p_source_register, v_tax_type);
        FETCH cess_balance_cur_pla INTO v_cess_opening_balance;
        CLOSE cess_balance_cur_pla;        */

        OPEN c_pla_cess_slno(v_tax_type);
        FETCH c_pla_cess_slno INTO v_slno;
        CLOSE c_pla_cess_slno;

        IF v_slno IS NULL THEN
          OPEN c_pla_cess_non_master_org(v_tax_type);
          FETCH c_pla_cess_non_master_org INTO v_cess_opening_balance;
          CLOSE c_pla_cess_non_master_org;
        ELSE
          OPEN c_pla_cess_master_org(v_slno, v_tax_type);
          FETCH c_pla_cess_master_org INTO v_cess_opening_balance;
          CLOSE c_pla_cess_master_org;
        END IF;


        v_source_type := 2;

      END IF;
      v_cess_closing_balance := NVL(v_cess_closing_balance,0);/*Bug 5989740 bduvarag*/
      IF p_transfer_from_to = 'FROM' THEN
        v_cess_closing_balance := v_cess_opening_balance - v_cess_amount;
      ELSIF p_transfer_from_to = 'TO' THEN
        v_cess_closing_balance := v_cess_opening_balance + v_cess_amount;
      END IF;

	  lv_debit:=NULL; --Added for bug#7260552
	  lv_credit:=NULL; --Added for bug#7260552
      IF p_transfer_from_to = 'FROM' THEN
        lv_debit := v_cess_amount;
      ELSIF p_transfer_from_to = 'TO' THEN
        lv_credit := v_cess_amount;
      END IF;--rchandan for bug#4428980

      INSERT INTO JAI_CMN_RG_OTHERS
        (RG_OTHER_ID,
        SOURCE_TYPE,
        SOURCE_REGISTER,
        SOURCE_REGISTER_ID,
        TAX_TYPE,
        DEBIT,
        CREDIT,
        OPENING_BALANCE,
        CLOSING_BALANCE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE)
      VALUES
        (JAI_CMN_RG_OTHERS_S.nextval,
        v_source_type,
        p_source_register,
        p_register_id,
        v_tax_type,
        lv_debit,
        lv_credit,
        v_cess_opening_balance,
        v_cess_closing_balance,
        uid,
        sysdate,
        uid,
        sysdate);

      <<NEXT_RECORD>>
      NULL;
    END LOOP;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
       p_process_flag := jai_constants.unexpected_error;/*Bug 5989740 bduvarag*/
       p_process_message  := 'error in insert_rg_others proc ' ||sqlerrm;/*Bug 5989740 bduvarag*/

    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

  END insert_rg_others;



/*Bug 4543171 bduvarag start*/
PROCEDURE rg_fund_transfer_gl_interface(
           p_org_id    number,
           p_excise_credit      number,
           p_excise_debit       number,
           p_cess_credit        number,
           p_cess_debit         number,
		   p_sh_cess_credit     number,  --Added by JMEENA for bug#7260552
           p_sh_cess_debit      number,  --Added by JMEENA for bug#7260552
           p_account_id         number,
           p_cess_account_id    number,
		   p_sh_cess_account_id number,  --Added by JMEENA for bug#7260552
           p_charge_account_id  number,
           p_currency           varchar2,
           p_v_reference10      varchar2,
           p_v_reference23      varchar2,
           p_v_reference24      varchar2,
           p_v_reference25      varchar2,
           p_v_reference26      varchar2
           )   IS

BEGIN
/* Following two Inserts will insert excise amount data into gl_interface table */

   jai_cmn_gl_pkg.create_gl_entry
                (p_org_id,
                 lv_currency,
                 p_excise_debit, /* rallamse bug#4404994 reversed p_excise_debit and p_excise_credit */
                 p_excise_credit, --null
                 p_account_id,
                 'Register India',
                 'Register India',
                 to_number(fnd_profile.value('USER_ID')),
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 p_v_reference10,
                 p_v_reference23,
                 p_v_reference24,
                 p_v_reference25,
                 p_v_reference26
                );


   jai_cmn_gl_pkg.create_gl_entry
                (p_org_id,
                 lv_currency,
                 p_cess_debit,  /* rallamse bug#4404994 reversed p_cess_credit and p_cess_debit */
                 p_cess_credit, --null
                 p_cess_account_id,
                 'Register India',
                 'Register India',
                 to_number(fnd_profile.value('USER_ID')),
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 p_v_reference10,
                 p_v_reference23,
                 p_v_reference24,
                 p_v_reference25,
                 p_v_reference26
                );
--Added by JMEENA for bug#7260552
	jai_cmn_gl_pkg.create_gl_entry
                (p_org_id,
                 lv_currency,
                 p_sh_cess_debit,  /* rallamse bug#4404994 reversed p_cess_credit and p_cess_debit */
                 p_sh_cess_credit,
                 p_sh_cess_account_id,
                 'Register India',
                 'Register India',
                 to_number(fnd_profile.value('USER_ID')),
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 p_v_reference10,
                 p_v_reference23,
                 p_v_reference24,
                 p_v_reference25,
                 p_v_reference26
                );
EXCEPTION
        WHEN OTHERS THEN
        --FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
        --FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
        --FND_MESSAGE.SET_STRING('rg_fund_transfer_gl_interface: Error in balance_transfer procedure. Err:'||sqlerrm );
        --raise_application_error(-20001, 'Error in rg_fund_transfer_gl_interface procedure');
        app_exception.raise_exception;

END rg_fund_transfer_gl_interface ;

/*Bug 4543171 bduvarag end*/
BEGIN
/*------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: ja_in_jai_cmn_rg_transfer_pkg.balance_transfer.sql
SlNo yyyy/mm/dd   Details of Changes
------------------------------------------------------------------------------------------
1.   2004/04/27   Vijay Shankar for BUG#3587423, FileVersion - 619.1
                   Cleanedup the procedure to function properly as required

2.   2005/01/21   Sanjikum For Bug #4136939, File Version - 115.1
                  Changes done for handling the Cess

-- # Future Dependencies For the release Of this Object:-
-- # (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
-- #  A datamodel change )

--===============================================================================================================
-- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- #  Current Version       Current Bug    Dependent           Files                                  Version     Author   Date         Remarks
-- #  Of File                              On Bug/Patchset    Dependent On
-- #  ja_in_jai_cmn_rg_transfer_pkg.balance_transfer.sql
-- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- #  115.1                  4136939       IN60105D2+ 4146708
-- #                                                                                                                                    Enhnacement added 2 columns in table JAI_RCV_CENVAT_CLAIMS
-- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- # ****************************************************************************************************************************************************************************************

--------------------------------------------------------------------------------------------*/
/*Bug 4543171 bduvarag start*/
  open currency_cur;
  fetch currency_cur into lv_currency;
  close currency_cur;
/*Bug 4543171 bduvarag end*/
  v_remarks  := 'RG Funds Transfer';                                -- File.Sql.35 by Brathod
  v_user_id  := nvl(to_number(FND_PROFILE.value('USER_ID')), -1) ;   -- File.Sql.35 by Brathod
  v_login_id := nvl(to_number(FND_PROFILE.value('LOGIN_ID')), -1) ;  -- File.Sql.35 by Brathod

  IF p_register NOT IN ('RG23A','RG23C','PLA') THEN
    RAISE_APPLICATION_ERROR(-20120, 'Select a Register');
  END IF;

  OPEN   c_rg_balances(p_organization_id, p_location_id);
  FETCH  c_rg_balances INTO v_rg23a_bal, v_rg23c_bal, v_pla_bal;
  CLOSE  c_rg_balances;

  IF p_register = 'RG23A' THEN
    v_rg23a_bal    := nvl(v_rg23a_bal,0) - nvl(p_amount,0);
    v_check_amount := v_rg23a_bal;
    v_register := 'A';
    v_source_register := jai_constants.reg_rg23a_2; --Added by Sanjikum for cess for Bug #4136939
  ELSIF p_register = 'RG23C' THEN
    v_rg23c_bal := nvl(v_rg23c_bal,0) - nvl(p_amount,0);
    v_check_amount := v_rg23c_bal;
    v_register := 'C';
    v_source_register := jai_constants.reg_rg23c_2; --Added by Sanjikum for cess for Bug #4136939
  ELSIF p_register = 'PLA' THEN
    v_pla_bal := nvl(v_pla_bal,0) - nvl(p_amount,0);
    v_check_amount := v_pla_bal;
    v_source_register := jai_constants.reg_pla; --Added by Sanjikum for cess for Bug #4136939
  END IF;

  IF v_check_amount < 0 THEN
    RAISE_APPLICATION_ERROR(-20120, 'Amount that you want to transfer will turn your --> ' ||
      p_register || ' Balance Negative For Organization ' ||
      to_char(p_organization_id) || '  and for location_id '|| to_char(p_location_id));
  END If;

  --Start Added by Sanjikum for cess for Bug #4136939

  --Get the total balance, for all cess taxes
  OPEN c_oth_balances(p_organization_id, p_location_id, p_register);
  FETCH c_oth_balances INTO v_oth_balances;
  CLOSE c_oth_balances;

  IF v_oth_balances.balance - NVL(p_cess_amount,0) < 0 THEN
    RAISE_APPLICATION_ERROR(-20120, 'Amount that you want to transfer will turn your --> ' ||
      p_register || ' Cess Balance Negative For Organization ' ||
      to_char(p_organization_id) || '  and for location_id '|| to_char(p_location_id));
  END If;

  --Get the balance for excise cess
  OPEN c_oth_balances(p_organization_id, p_location_id, p_register, jai_constants.tax_type_exc_edu_cess);
  FETCH c_oth_balances INTO v_excise_cess_bal;
  CLOSE c_oth_balances;

  IF NVL(p_cess_amount,0) > v_excise_cess_bal THEN
    v_excise_cess_amount := v_excise_cess_bal;
    v_cvd_cess_amount := NVL(p_cess_amount,0) - v_excise_cess_amount;
  ELSE
    v_excise_cess_amount := NVL(p_cess_amount,0);
    v_cvd_cess_amount := 0;
  END IF;

  --End Added by Sanjikum for cess for Bug #4136939
  /*Bug 5989740 bduvarag start*/
  	OPEN c_sh_oth_balances(p_organization_id, p_location_id, p_register);
	FETCH c_sh_oth_balances INTO v_sh_oth_balances;
	CLOSE c_sh_oth_balances;

	IF v_sh_oth_balances.balance - NVL(p_sh_cess_amount,0) < 0 THEN
	 RAISE_APPLICATION_ERROR(-20120, 'Amount that you want to transfer will turn your --> ' ||
		 p_register || ' Cess Balance Negative For Organization ' ||
		 to_char(p_organization_id) || '  and for location_id '|| to_char(p_location_id));
	END If;

	--Get the balance for excise cess
	OPEN c_sh_oth_balances(p_organization_id, p_location_id, p_register, jai_constants.tax_type_sh_exc_edu_cess);
	FETCH c_sh_oth_balances INTO v_sh_excise_cess_bal;
	CLOSE c_sh_oth_balances;

	IF NVL(p_sh_cess_amount,0) > v_sh_excise_cess_bal THEN
	 v_sh_excise_cess_amount := v_sh_excise_cess_bal;
	 v_sh_cvd_cess_amount := NVL(p_sh_cess_amount,0) - v_sh_excise_cess_amount;
	ELSE
	 v_sh_excise_cess_amount := NVL(p_sh_cess_amount,0);
	 v_sh_cvd_cess_amount := 0;
	END IF;
/*Bug 5989740 bduvarag end*/
  OPEN   balances_to_exist;
  FETCH  balances_to_exist INTO v_exist;
  CLOSE  balances_to_exist;

  IF nvl(v_exist,0) = 0 THEN
    RAISE_APPLICATION_ERROR(-20120, 'Balances not available for Organization ' ||
      to_char(p_to_organization_id) ||
      '  and for location_id ' ||to_char(p_to_location_id));
  ELSE
    OPEN  c_rg_balances(p_to_organization_id, p_to_location_id);
    FETCH  c_rg_balances INTO v_to_rg23a_bal, v_to_rg23c_bal, v_to_pla_bal;
    CLOSE  c_rg_balances;
  END IF;

  IF p_register = 'RG23A' THEN
    v_to_rg23a_bal := nvl(v_to_rg23a_bal,0) + nvl(p_amount,0);
  ELSIF p_register = 'RG23C' THEN
    v_to_rg23c_bal := nvl(v_to_rg23c_bal,0) + nvl(p_amount,0);
  ELSIF p_register = 'PLA' THEN
    v_to_pla_bal := nvl(v_to_pla_bal,0) + nvl(p_amount,0);
  END IF;

  -- RG Register Updation starts here For FROM Organization
  IF p_register IN ('RG23A','RG23C') THEN
    OPEN  c_rg23_fin_yr(p_organization_id , p_location_id, v_register);
    FETCH c_rg23_fin_yr INTO v_fin_year;
    CLOSE c_rg23_fin_yr;
  ELSIF p_register IN ('PLA') THEN
    OPEN  c_pla_fin_yr(p_organization_id , p_location_id);
    FETCH c_pla_fin_yr INTO v_fin_year;
    CLOSE c_pla_fin_yr;
  END IF;

  -- following condition is successful means, there is no transaction for FROM Orgn and Loc
  IF v_fin_year IS NULL THEN
    RAISE_APPLICATION_ERROR(-20119, 'Balances does not exist for From Organization:' ||
      to_char(p_organization_id) || ' and location:' ||to_char(p_location_id));
  END IF;

  UPDATE JAI_CMN_RG_BALANCES
  SET pla_balance =   v_pla_bal,
    rg23a_balance = v_rg23a_bal,
    rg23c_balance = v_rg23c_bal
  WHERE  organization_id = p_organization_id
  and location_id = p_location_id;

  UPDATE JAI_CMN_RG_BALANCES
  SET pla_balance =   v_to_pla_bal,
    rg23a_balance = v_to_rg23a_bal,
    rg23c_balance = v_to_rg23c_bal
  where  organization_id = p_to_organization_id
  and location_id =  p_to_location_id;

  --No Updates required for Cess balance as, this will be handled through a trigger

  --Updations for the From Organization
  IF p_register IN ('RG23A','RG23C') THEN

    OPEN  serial_no_cur(p_organization_id , p_location_id, v_fin_year, v_register);
    FETCH  serial_no_cur  INTO v_previous_serial_no;
    CLOSE  serial_no_cur;

    IF nvl(v_previous_serial_no,0) > 0 THEN

      OPEN  balance_cur(v_previous_serial_no, p_organization_id , p_location_id, v_fin_year, v_register);
      FETCH  balance_cur INTO v_closing_balance;
      CLOSE  balance_cur;

      v_slno := v_previous_serial_no + 1;
      v_opening_balance := nvl(v_closing_balance,0);
      v_closing_balance := v_opening_balance - p_amount;

      -- to fetch the active fin_year and populate PART II Register
      v_fin_year := null;
      OPEN  fin_year_cur(p_organization_id , p_location_id) ;
      FETCH fin_year_cur INTO v_fin_year;
      CLOSE fin_year_cur;
      lv_reference_num :=  v_remarks||'. Slno-'||v_slno;--rchandan for bug#4428980

      INSERT INTO JAI_CMN_RG_23AC_II_TRXS(
        REGISTER_ID, FIN_YEAR, SLNO, TRANSACTION_SOURCE_NUM, INVENTORY_ITEM_ID, ORGANIZATION_ID,
        RECEIPT_REF, RECEIPT_DATE, RANGE_NO, DIVISION_NO, CR_BASIC_ED, CR_ADDITIONAL_ED, CR_OTHER_ED,
        DR_BASIC_ED, DR_ADDITIONAL_ED, DR_OTHER_ED, EXCISE_INVOICE_NO, EXCISE_INVOICE_DATE,
        REGISTER_TYPE, REMARKS, VENDOR_ID, VENDOR_SITE_ID, CUSTOMER_ID, CUSTOMER_SITE_ID,
        LOCATION_ID, TRANSACTION_DATE, OPENING_BALANCE, CLOSING_BALANCE, CHARGE_ACCOUNT_ID,
        REGISTER_ID_PART_I, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN, POSTED_FLAG, MASTER_FLAG, REFERENCE_NUM,
        other_tax_debit --Added by Sanjikum for cess for Bug #4136939
      ) VALUES (
        JAI_CMN_RG_23AC_II_TRXS_S.nextval, v_fin_year, v_slno, v_src_transaction_id, -1, p_organization_id,
        null, null, null, null, null, null, null,
        p_amount, null, null, null, null,
        v_register, v_remarks,  null, null, null, null,
        p_location_id, SYSDATE, v_opening_balance, v_closing_balance, null,
        null, SYSDATE, v_user_id, SYSDATE, v_user_id, v_login_id, null, null,lv_reference_num,--rchandan for bug#4428980
        p_cess_amount+ nvl(p_sh_cess_amount,0) --Added by Sanjikum for cess for Bug #4136939 --Added + nvl(p_sh_cess_amount,0) by JMEENA for bug#7260552
      ) RETURNING register_id INTO v_from_register_id;
/*Bug 4543171 bduvarag start*/
        IF p_register = 'RG23A' THEN

                open cur_cess_accountid(p_organization_id, p_location_id, 'A');
                fetch cur_cess_accountid into lv_from_cess_account_id;
                close cur_cess_accountid;

                open rg23a_account_cur(p_organization_id, p_location_id);
                fetch rg23a_account_cur into lv_from_account_id;
                close rg23a_account_cur;

                open rg23a_account_cur(p_to_organization_id, p_to_location_id);
                fetch rg23a_account_cur into lv_to_account_id;
                close rg23a_account_cur;
			/*added by JMEENA for bug#7260552, start*/
				if lv_from_account_id IS NULL OR lv_from_cess_account_id.cess_account_id  IS NULL OR lv_from_cess_account_id.sh_cess_account_id  IS NULL THEN
                p_process_flag    := jai_constants.expected_error;
                p_process_message := 'Cenvat / Cess / SH Cess Accounts not defined for the Source Organization';
                return;
                END IF;
            /* JMEENA for bug#7260552, end*/
              rg_fund_transfer_gl_interface(
                   p_org_id   => p_organization_id   ,
                   p_excise_credit     => null       ,
                   p_excise_debit      => p_amount       ,
                   p_cess_credit       => null  ,
                   p_cess_debit        => p_cess_amount  ,
				   p_sh_cess_credit       => null  ,		--Added by JMEENA for bug#7260552
                   p_sh_cess_debit        => p_sh_cess_amount  ,  --Added by JMEENA for bug#7260552
                   p_account_id        => lv_from_account_id    ,
                   p_cess_account_id   => lv_from_cess_account_id.cess_account_id , --Changed by JMEENA for bug#7260552, ( lv_from_cess_account_id to lv_from_cess_account_id.cess_account_id)
				   p_sh_cess_account_id   => lv_from_cess_account_id.sh_cess_account_id , --Added by JMEENA for bug#7260552
                   p_charge_account_id => lv_to_account_id ,
                   p_currency          => lv_currency     ,
                   p_v_reference10     => 'India Local RG Funds Transfer of RG23A part ii Register' ,
                   p_v_reference23     => 'JAINRGFT Form : balance_transfer',
                   p_v_reference24     => 'ja_in_rg23_part_ii',
                   p_v_reference25     => 'register_id : slno' ,
                   p_v_reference26     => v_from_register_id|| ':' || v_slno
                   ) ;
          END IF ;

          IF p_register = 'RG23C'
          THEN
                open cur_cess_accountid(p_organization_id, p_location_id, 'C');
                fetch cur_cess_accountid into lv_from_cess_account_id;
                close cur_cess_accountid;

                open rg23c_account_cur(p_organization_id, p_location_id);
                fetch rg23c_account_cur into lv_from_account_id;
                close rg23c_account_cur;

                open rg23c_account_cur(p_to_organization_id, p_to_location_id);
                fetch rg23c_account_cur into lv_to_account_id;
                close rg23c_account_cur;
		/*added by JMEENA for bug#7260552, start*/
			if lv_from_account_id IS NULL OR lv_from_cess_account_id.cess_account_id  IS NULL OR lv_from_cess_account_id.sh_cess_account_id  IS NULL THEN
            p_process_flag    := jai_constants.expected_error;
            p_process_message := 'Cenvat / Cess / SH Cess Accounts not defined for the Source Organization';
            return;
            END IF;
        /* JMEENA for bug#7260552, end*/
              rg_fund_transfer_gl_interface(
                   p_org_id   => p_organization_id   ,
                   p_excise_credit     => null       ,
                   p_excise_debit      => p_amount       ,
                   p_cess_credit       => null  ,
                   p_cess_debit        => p_cess_amount  ,
				   p_sh_cess_credit       => null  ,     --Added by JMEENA for bug#7260552
                   p_sh_cess_debit        => p_sh_cess_amount  , --Added by JMEENA for bug#7260552
                   p_account_id        => lv_from_account_id    ,
                   p_cess_account_id   => lv_from_cess_account_id.cess_account_id, --Changed by JMEENA for bug#7260552
				   p_sh_cess_account_id   => lv_from_cess_account_id.sh_cess_account_id , --Added by JMEENA for bug#7260552
                   p_charge_account_id => lv_to_account_id ,
                   p_currency          => lv_currency,
                   p_v_reference10     => 'India Local RG Funds Transfer of RG23C part ii Register',
                   p_v_reference23     => 'JAINRGFT Form : balance_transfer',
                   p_v_reference24     => 'ja_in_rg23_part_ii',
                   p_v_reference25     => 'register_id : slno' ,
                   p_v_reference26     => v_from_register_id|| ':' || v_slno
                   ) ;

           END IF;

/*Bug 4543171 bduvarag end*/
      --Added by Sanjikum for cess for Bug #4136939
      insert_rg_others( p_organization_id => p_organization_id,
                        p_location_id => p_location_id,
                        p_register_type => v_register,
                        p_source_register => v_source_register,
                        p_excise_cess_amount => v_excise_cess_amount,
                        p_sh_exc_cess_amount => v_sh_excise_cess_amount,/*Bug 5989740 bduvarag*/
                        p_sh_cvd_cess_amount => v_sh_cvd_cess_amount,	/*Bug 5989740 bduvarag*/
                        p_cvd_cess_amount => v_cvd_cess_amount,
                        p_transfer_from_to => 'FROM',
                        p_register_id => v_from_register_id,
                        p_fin_year => v_fin_year);

    ELSE
      RAISE_APPLICATION_ERROR(-20021,'Previous Serial Number not available for Organization_id:'||p_organization_id
        ||', location_id:'||p_location_id);
    END IF;

  ELSIF p_register = 'PLA' THEN

    OPEN   pla_serial_no_cur(p_organization_id , p_location_id, v_fin_year);
    FETCH  pla_serial_no_cur  INTO v_previous_serial_no;
    CLOSE  pla_serial_no_cur;

    IF NVL(v_previous_serial_no,0) > 0 THEN
      OPEN  pla_balance_cur(v_previous_serial_no, p_organization_id , p_location_id, v_fin_year );
      FETCH  pla_balance_cur INTO v_closing_balance;
      CLOSE  pla_balance_cur;

      v_slno := v_previous_serial_no + 1;
      v_opening_balance := nvl(v_closing_balance, 0);
      v_closing_balance := v_opening_balance - p_amount;

      -- to fetch the active fin_year and populate PART II Register
      v_fin_year := null;
      OPEN  fin_year_cur(p_organization_id , p_location_id) ;
      FETCH fin_year_cur INTO v_fin_year;
      CLOSE fin_year_cur;

      INSERT INTO JAI_CMN_RG_PLA_TRXS(
        REGISTER_ID, FIN_YEAR, SLNO, TR6_CHALLAN_NO, TR6_CHALLAN_DATE, CR_BASIC_ED, CR_ADDITIONAL_ED,
        CR_OTHER_ED, TRANSACTION_SOURCE_NUM, REF_DOCUMENT_ID, REF_DOCUMENT_DATE, DR_INVOICE_NO, DR_INVOICE_DATE,
        DR_BASIC_ED, DR_ADDITIONAL_ED, DR_OTHER_ED, ORGANIZATION_ID, LOCATION_ID, BANK_BRANCH_ID,
        ENTRY_DATE, INVENTORY_ITEM_ID, VENDOR_CUST_FLAG, VENDOR_ID, VENDOR_SITE_ID, RANGE_NO,
        DIVISION_NO, EXCISE_INVOICE_NO, REMARKS, TRANSACTION_DATE, OPENING_BALANCE, CLOSING_BALANCE,
        CHARGE_ACCOUNT_ID, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN, POSTED_FLAG, MASTER_FLAG, BASIC_OPENING_BALANCE, BASIC_CLOSING_BALANCE,
        ADDITIONAL_OPENING_BALANCE, ADDITIONAL_CLOSING_BALANCE, OTHER_OPENING_BALANCE, OTHER_CLOSING_BALANCE,
        OTHER_TAX_DEBIT --Added by Sanjikum for cess for Bug #4136939
      ) VALUES (
        JAI_CMN_RG_PLA_TRXS_S1.nextval, v_fin_year, v_slno, null, null, null, null,
        null, v_src_transaction_id, null, null, null, null,
        p_amount, null, null, p_organization_id, p_location_id, null,
        SYSDATE, null, null, null, null, null,
        null, null, v_remarks, trunc(SYSDATE), v_opening_balance, v_closing_balance,
        null, SYSDATE, v_user_id, SYSDATE, v_user_id,
        v_login_id, null, null, null, null,
        null, null, null, null,
        p_cess_amount + nvl(p_sh_cess_amount,0)/*Bug 5989740 bduvarag*/--Added by Sanjikum for cess for Bug #4136939
      ) RETURNING register_id INTO v_from_register_id;

/*Bug 4543171 bduvarag start*/
     IF p_register = 'PLA' THEN
                open pla_account_cur(p_organization_id, p_location_id);
                fetch pla_account_cur into lv_from_account_id;
                close pla_account_cur;

                open pla_account_cur(p_to_organization_id, p_to_location_id);
                fetch pla_account_cur into lv_to_account_id;
                close pla_account_cur;
		/*added by JMEENA for bug#7260552, start*/
            if lv_from_account_id IS NULL THEN
            p_process_flag    := jai_constants.expected_error;
            p_process_message := 'Cenvat / Cess / SH Cess Accounts not defined for the Source Organization';
            return;
            END IF;
        /* JMEENA for bug#7260552, end*/
              rg_fund_transfer_gl_interface(
                   p_org_id   => p_organization_id   ,
                   p_excise_credit     => null       ,
                   p_excise_debit      => p_amount       ,
                   p_cess_credit       => null  ,
                   p_cess_debit        => p_cess_amount  ,
				   p_sh_cess_credit    => null  ,            	 --Added by JMEENA for bug#7260552                                           --csahoo for BUG#5907436
                   p_sh_cess_debit     => p_sh_cess_amount  ,   --Added by JMEENA for bug#7260552
                   p_account_id        => lv_from_account_id    ,
                   p_cess_account_id   => lv_from_account_id ,
				   p_sh_cess_account_id=> lv_from_account_id ,  --Added by JMEENA for bug#7260552
                   p_charge_account_id => lv_to_account_id ,
                   p_currency          => lv_currency,
                   p_v_reference10     => 'India Local RG Funds Transfer of PLA Register',
                   p_v_reference23     => 'JAINRGFT Form : balance_transfer',
                   p_v_reference24     => 'ja_in_pla',
                   p_v_reference25     => 'register_id : slno' ,
                   p_v_reference26     => v_from_register_id|| ':' || v_slno
                   ) ;
        END IF ;

/*Bug 4543171 bduvarag end*/
      --Added by Sanjikum for cess for Bug #4136939
      insert_rg_others( p_organization_id => p_organization_id,
                        p_location_id => p_location_id,
                        p_register_type => 'PLA',
                        p_source_register => v_source_register,
                        p_excise_cess_amount => v_excise_cess_amount,
                        p_sh_exc_cess_amount => v_sh_excise_cess_amount,/*Bug 5989740 bduvarag*/
                        p_sh_cvd_cess_amount => v_sh_cvd_cess_amount,	/*Bug 5989740 bduvarag*/
                        p_cvd_cess_amount => v_cvd_cess_amount,
                        p_transfer_from_to => 'FROM',
                        p_register_id => v_from_register_id,
                        p_fin_year => v_fin_year);

    ELSE
      RAISE_APPLICATION_ERROR(-20022,'Previous Serial Number not available for Organization_id:'||p_organization_id
        ||', location_id:'||p_location_id);
    END IF;

  END IF;

  --- RG Register Updation starts here for TO Organization
  IF p_register IN ('RG23A','RG23C') THEN
    OPEN  c_rg23_fin_yr(p_to_organization_id , p_to_location_id, v_register);
    FETCH c_rg23_fin_yr INTO v_to_fin_year;
    CLOSE c_rg23_fin_yr;
  ELSIF p_register IN ('PLA') THEN
    OPEN  c_pla_fin_yr(p_to_organization_id , p_to_location_id);
    FETCH c_pla_fin_yr INTO v_to_fin_year;
    CLOSE c_pla_fin_yr;
  END IF;

  -- following condition is successful if the funds transfer is the first transaction for TO Orgn. and Loc.
  IF v_to_fin_year IS NULL THEN -- AND v_to_previous_serial_no = 0 THEN
    v_to_previous_serial_no := 0;
    v_to_closing_balance := 0;
    v_not_a_first_transaction := false;

    OPEN  fin_year_cur(p_to_organization_id , p_to_location_id) ;
    FETCH fin_year_cur INTO v_to_fin_year;
    CLOSE fin_year_cur;
  END IF;

  IF p_register IN ('RG23A', 'RG23C') THEN

    -- following if loop gets executed only if transactions exist for TO_ORGANIZATION
    IF v_not_a_first_transaction THEN -- AND v_to_previous_serial_no = 0 THEN

      OPEN  serial_no_cur(p_to_organization_id , p_to_location_id, v_to_fin_year, v_register);
      FETCH  serial_no_cur  INTO v_to_previous_serial_no;   --, v_to_register_id;
      CLOSE  serial_no_cur;

      IF NVL(v_to_previous_serial_no,0) = 0 THEN
        -- If transactions exist in previous financial year

        OPEN  serial_no_cur(p_to_organization_id , p_to_location_id, v_to_fin_year-1, v_register);
        FETCH  serial_no_cur  INTO v_to_previous_serial_no;   --, v_to_register_id;
        CLOSE  serial_no_cur;

        OPEN  balance_cur(v_to_previous_serial_no, p_to_organization_id , p_to_location_id, v_to_fin_year-1, v_register);
        FETCH  balance_cur INTO v_to_closing_balance;
        CLOSE  balance_cur;

        IF NVL(v_to_previous_serial_no,0) > 0 THEN
          -- as this is new financial year and balances exist in previous fin_year
          v_to_previous_serial_no := 0;
        END IF;

      ELSE    -- If transactions exist in the same Financial Year
        OPEN  balance_cur(v_to_previous_serial_no, p_to_organization_id , p_to_location_id, v_to_fin_year, v_register);
        FETCH  balance_cur INTO v_to_closing_balance;
        CLOSE  balance_cur;

      END IF;

    END IF;

    v_to_slno       := v_to_previous_serial_no + 1;
    v_to_opening_balance  := nvl(v_to_closing_balance, 0);
    v_to_closing_balance  := v_to_opening_balance + p_amount;
    lv_reference_num := v_remarks||'. Slno-'||v_slno;--rchandan for bug#4428980
    INSERT INTO JAI_CMN_RG_23AC_II_TRXS(
      REGISTER_ID, FIN_YEAR, SLNO, TRANSACTION_SOURCE_NUM, INVENTORY_ITEM_ID, ORGANIZATION_ID,
      RECEIPT_REF, RECEIPT_DATE, RANGE_NO, DIVISION_NO, CR_BASIC_ED, CR_ADDITIONAL_ED, CR_OTHER_ED,
      DR_BASIC_ED, DR_ADDITIONAL_ED, DR_OTHER_ED, EXCISE_INVOICE_NO, EXCISE_INVOICE_DATE,
      REGISTER_TYPE, REMARKS, VENDOR_ID, VENDOR_SITE_ID, CUSTOMER_ID, CUSTOMER_SITE_ID,
      LOCATION_ID, TRANSACTION_DATE, OPENING_BALANCE, CLOSING_BALANCE, CHARGE_ACCOUNT_ID,
      REGISTER_ID_PART_I, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN, POSTED_FLAG, MASTER_FLAG, REFERENCE_NUM,
      OTHER_TAX_CREDIT --Added by Sanjikum for cess for Bug #4136939
    ) VALUES (
      JAI_CMN_RG_23AC_II_TRXS_S.nextval, v_to_fin_year, v_to_slno, v_to_transaction_id, -1, p_to_organization_id,
      v_from_register_id, null, null, null, p_amount, null, null,
      null, null, null, null, null,
      v_register, v_remarks,  null, null, null, null,
      p_to_location_id, SYSDATE, v_to_opening_balance, v_to_closing_balance, null,
      null, SYSDATE, v_user_id, SYSDATE, v_user_id, v_login_id, null, null, lv_reference_num,--rchandan for bug#4428980
      p_cess_amount + nvl(p_sh_cess_amount,0)/*Bug 5989740 bduvarag*/--Added by Sanjikum for cess for Bug #4136939
    ) RETURNING register_id INTO v_to_register_id;

    UPDATE JAI_CMN_RG_23AC_II_TRXS
    SET RECEIPT_REF = v_to_register_id
    WHERE register_id = v_from_register_id;
    /*Bug 4543171 bduvarag start*/
            IF p_register = 'RG23A' THEN
                open cur_cess_accountid(p_to_organization_id, p_to_location_id, 'A');
                fetch cur_cess_accountid into lv_to_cess_account_id;
                close cur_cess_accountid;

                open rg23a_account_cur(p_organization_id, p_location_id);
                fetch rg23a_account_cur into lv_from_account_id;
                close rg23a_account_cur;

                open rg23a_account_cur(p_to_organization_id, p_to_location_id);
                fetch rg23a_account_cur into lv_to_account_id;
                close rg23a_account_cur;
			/*added by JMEENA for bug#7260552, start*/
				if lv_to_account_id IS NULL OR lv_to_cess_account_id.cess_account_id  IS NULL OR lv_to_cess_account_id.sh_cess_account_id  IS NULL THEN
                p_process_flag    := jai_constants.expected_error;
                p_process_message := 'Cenvat / Cess / SH Cess Accounts not defined for the Destination Organization';
                return;
                END IF;
            /*JMEENA for bug#7260552, end*/
           rg_fund_transfer_gl_interface(
                   p_org_id  => p_organization_id   ,           /*Bug 5349052 bduvarag*/
                   p_excise_credit     => p_amount       ,
                   p_excise_debit      => null ,
                   p_cess_credit       => p_cess_amount  ,
                   p_cess_debit        => null ,
				   p_sh_cess_credit       => p_sh_cess_amount  , --JMEENA for bug#7260552
                   p_sh_cess_debit        => null ,              --JMEENA for bug#7260552
                   p_account_id        => lv_to_account_id       ,
                   p_cess_account_id   => lv_to_cess_account_id.cess_account_id  , --Changed by JMEENA for bug#7260552, Added .cess_account_id
				   p_sh_cess_account_id   => lv_to_cess_account_id.sh_cess_account_id  , --JMEENA for BUG#7260552
                   p_charge_account_id => lv_from_account_id ,
                   p_currency          => lv_currency,
                   p_v_reference10     => 'India Local RG Funds Transfer of RG23A part ii Register',
                   p_v_reference23     => 'JAINRGFT Form: balance_transfer',
                   p_v_reference24     => 'ja_in_rg23_part_ii',
                   p_v_reference25     => 'register_id : slno' ,
                   p_v_reference26     => v_from_register_id|| ':' || v_slno
                   )  ;
          END IF ;

          IF p_register = 'RG23C'
          THEN
                open cur_cess_accountid(p_to_organization_id, p_to_location_id, 'C');
                fetch cur_cess_accountid into lv_to_cess_account_id;
                close cur_cess_accountid;

                open rg23c_account_cur(p_organization_id, p_location_id);
                fetch rg23c_account_cur into lv_from_account_id;
                close rg23c_account_cur;

                open rg23c_account_cur(p_to_organization_id, p_to_location_id);
                fetch rg23c_account_cur into lv_to_account_id;
                close rg23c_account_cur;
			/*added by JMEENA for bug#7260552, start*/
				if lv_to_account_id IS NULL OR lv_to_cess_account_id.cess_account_id  IS NULL OR lv_to_cess_account_id.sh_cess_account_id  IS NULL THEN
                p_process_flag    := jai_constants.expected_error;
                p_process_message := 'Cenvat / Cess / SH Cess Accounts not defined for the Destination Organization';
                return;
                END IF;
            /*JMEENA for bug#7260552, end*/
              rg_fund_transfer_gl_interface(
                   p_org_id   => p_organization_id   ,    /*Bug 5349052 bduvarag*/
                   p_excise_credit     => p_amount       ,
                   p_excise_debit      => null ,
                   p_cess_credit       => p_cess_amount  ,
                   p_cess_debit        => null ,
				   p_sh_cess_credit       => p_sh_cess_amount  , --JMEENA for bug#7260552
                   p_sh_cess_debit        => null ,   --JMEENA for bug#7260552
                   p_account_id        => lv_to_account_id       ,
                   p_cess_account_id   => lv_to_cess_account_id.cess_account_id  , --JMEENA for bug#7260552, Changed to lv_to_cess_account_id.cess_account_id from lv_to_cess_account_id
				   p_sh_cess_account_id   => lv_to_cess_account_id.sh_cess_account_id  ,--JMEENA for bug#7260552
                   p_charge_account_id => lv_from_account_id ,
                   p_currency          => lv_currency,
                   p_v_reference10     => 'India Local RG Funds Transfer of RG23C part ii Register',
                   p_v_reference23     => 'JAINRGFT Form : balance_transfer',
                   p_v_reference24     => 'ja_in_rg23_part_ii',
                   p_v_reference25     => 'register_id : slno' ,
                   p_v_reference26     => v_from_register_id|| ':' || v_slno
                   )  ;
           END IF;

    /*Bug 4543171 bduvarag end*/

    --Added by Sanjikum for cess for Bug #4136939
    insert_rg_others( p_organization_id => p_organization_id,
                      p_location_id => p_location_id,
                      p_register_type => v_register,
                      p_source_register => v_source_register,
                      p_excise_cess_amount => v_excise_cess_amount,
                      p_cvd_cess_amount => v_cvd_cess_amount,
                      p_sh_exc_cess_amount => v_sh_excise_cess_amount, /*Bug 5989740 bduvarag*/
		      p_sh_cvd_cess_amount => v_sh_cvd_cess_amount,	/*Bug 5989740 bduvarag*/
                      p_transfer_from_to => 'TO',
                      p_register_id => v_to_register_id,
                      p_fin_year => v_fin_year);

  ELSIF p_register = 'PLA' THEN

    -- following if loop gets executed only if transactions exist for TO_ORGANIZATION in PLA
    IF v_not_a_first_transaction THEN -- AND v_to_previous_serial_no = 0 THEN

      OPEN   pla_serial_no_cur(p_to_organization_id , p_to_location_id, v_to_fin_year);
      FETCH  pla_serial_no_cur  INTO v_to_previous_serial_no;   --, v_to_register_id;
      CLOSE  pla_serial_no_cur;

      IF NVL(v_to_previous_serial_no, 0) = 0 THEN
        -- If transactions exist in previous financial year, then the execution comes here

        OPEN   pla_serial_no_cur(p_to_organization_id , p_to_location_id, v_to_fin_year-1);
        FETCH  pla_serial_no_cur INTO v_to_previous_serial_no;    --, v_to_register_id;
        CLOSE  pla_serial_no_cur;

        OPEN  pla_balance_cur(v_to_previous_serial_no, p_to_organization_id , p_to_location_id, v_to_fin_year-1 );
        FETCH  pla_balance_cur INTO v_to_closing_balance;
        CLOSE  pla_balance_cur;

        IF NVL(v_to_previous_serial_no,0) > 0 THEN
          -- as this is new financial year and balances exist in previous fin_year
          v_to_slno := 0;
        END IF;

      ELSE    -- If transactions exist in the same Financial Year
        OPEN  pla_balance_cur(v_to_previous_serial_no, p_to_organization_id , p_to_location_id, v_to_fin_year);
        FETCH  pla_balance_cur INTO v_to_closing_balance;
        CLOSE  pla_balance_cur;

        v_to_slno := v_to_previous_serial_no + 1;
      END IF;

    END IF;

    v_to_slno       := v_to_previous_serial_no + 1;
    v_to_opening_balance  := nvl(v_to_closing_balance, 0);
    v_to_closing_balance  := v_to_opening_balance + p_amount;

    INSERT INTO JAI_CMN_RG_PLA_TRXS(
      REGISTER_ID, FIN_YEAR, SLNO, TR6_CHALLAN_NO, TR6_CHALLAN_DATE, CR_BASIC_ED, CR_ADDITIONAL_ED,
      CR_OTHER_ED, TRANSACTION_SOURCE_NUM, REF_DOCUMENT_ID, REF_DOCUMENT_DATE, DR_INVOICE_NO, DR_INVOICE_DATE,
      DR_BASIC_ED, DR_ADDITIONAL_ED, DR_OTHER_ED, ORGANIZATION_ID, LOCATION_ID, BANK_BRANCH_ID,
      ENTRY_DATE, INVENTORY_ITEM_ID, VENDOR_CUST_FLAG, VENDOR_ID, VENDOR_SITE_ID, RANGE_NO,
      DIVISION_NO, EXCISE_INVOICE_NO, REMARKS, TRANSACTION_DATE, OPENING_BALANCE, CLOSING_BALANCE,
      CHARGE_ACCOUNT_ID, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN, POSTED_FLAG, MASTER_FLAG, BASIC_OPENING_BALANCE, BASIC_CLOSING_BALANCE,
      ADDITIONAL_OPENING_BALANCE, ADDITIONAL_CLOSING_BALANCE, OTHER_OPENING_BALANCE, OTHER_CLOSING_BALANCE,
      OTHER_TAX_CREDIT --Added by Sanjikum for cess for Bug #4136939
    ) VALUES (
      JAI_CMN_RG_PLA_TRXS_S1.nextval, v_to_fin_year, v_to_slno, null, null, p_amount, null,
      null, v_to_transaction_id, v_from_register_id, null, null, null,
      null, null, null, p_to_organization_id, p_to_location_id, null,
      SYSDATE,  null, null, null, null, null,
      null, null, v_remarks, trunc(SYSDATE), v_to_opening_balance, v_to_closing_balance,
      null, SYSDATE, v_user_id, SYSDATE, v_user_id,
      v_login_id, null, null, null, null,
      null, null, null, null,
      p_cess_amount + nvl(p_sh_cess_amount,0)/*Bug 5989740 bduvarag*/--Added by Sanjikum for cess for Bug #4136939
    ) RETURNING register_id INTO v_to_register_id;

    UPDATE JAI_CMN_RG_PLA_TRXS
    SET ref_document_id = v_to_register_id
    WHERE register_id = v_from_register_id;
/*Bug 4543171 bduvarag start*/
            IF p_register = 'PLA' THEN
                open pla_account_cur(p_organization_id, p_location_id);
                fetch pla_account_cur into lv_from_account_id;
                close pla_account_cur;

                open pla_account_cur(p_to_organization_id, p_to_location_id);
                fetch pla_account_cur into lv_to_account_id;
                close pla_account_cur;
			/*added by JMEENA for bug#7260552, start*/
				if lv_to_account_id IS NULL THEN
                p_process_flag    := jai_constants.expected_error;
                p_process_message := 'Cenvat / Cess / SH Cess Accounts not defined for the Destination Organization';
                return;
                END IF;
            /*JMEENA for bug#7260552, end*/
              rg_fund_transfer_gl_interface(
                   p_org_id   => p_organization_id   ,          /*Bug 5349052 bduvarag*/
                   p_excise_credit     => p_amount       ,
                   p_excise_debit      => null ,
                   p_cess_credit       => p_cess_amount  ,
                   p_cess_debit        => null ,
				   p_sh_cess_credit    => p_sh_cess_amount  , --JMEENA for bug#7260552
                   p_sh_cess_debit     => null ,     		--JMEENA for bug#7260552
                   p_account_id        => lv_to_account_id       ,
                   p_cess_account_id   => lv_to_account_id  ,
				   p_sh_cess_account_id=> lv_to_account_id  ,  --JMEENA for bug#7260552
                   p_charge_account_id => lv_from_account_id ,
                   p_currency          => lv_currency,
                   p_v_reference10     => 'India Local RG Funds Transfer of PLA Register',
                   p_v_reference23     => 'JAINRGFT Form : balance_transfer',
                   p_v_reference24     => 'ja_in_pla',
                   p_v_reference25     => 'register_id : slno' ,
                   p_v_reference26     => v_from_register_id|| ':' || v_slno
                   )  ;
          END IF ;

/*Bug 4543171 bduvarag end*/
    --Added by Sanjikum for cess for Bug #4136939
    insert_rg_others( p_organization_id => p_organization_id,
                      p_location_id => p_location_id,
                      p_register_type => 'PLA',
                      p_source_register => v_source_register,
                      p_excise_cess_amount => v_excise_cess_amount,
                      p_cvd_cess_amount => v_cvd_cess_amount,
                      p_sh_exc_cess_amount => v_sh_excise_cess_amount, /*Bug 5989740 bduvarag*/
			p_sh_cvd_cess_amount => v_sh_cvd_cess_amount,	/*Bug 5989740 bduvarag*/
                      p_transfer_from_to => 'TO',
                      p_register_id => v_to_register_id,
                      p_fin_year => v_fin_year);

  END IF;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN

 p_process_flag := jai_constants.unexpected_error;
 p_process_message  := sqlerrm;

    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END balance_transfer;

END jai_cmn_rg_transfer_pkg ;

/
