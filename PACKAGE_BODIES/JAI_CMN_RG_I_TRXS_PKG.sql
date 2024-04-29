--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RG_I_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RG_I_TRXS_PKG" AS
/* $Header: jai_cmn_rg_i.plb 120.3.12010000.4 2010/04/28 11:48:17 vkaranam ship $ */


    PROCEDURE validate_rg1_balances(
        P_ORGANIZATION_ID                 IN NUMBER,
        P_LOCATION_ID                     IN NUMBER,
        P_INVENTORY_ITEM_ID               IN NUMBER,
        P_FIN_YEAR                        IN NUMBER,
        P_QUANTITY                        IN NUMBER,
        P_TRANSACTION_UOM_CODE            IN VARCHAR2,
        P_TRANSACTION_TYPE                IN VARCHAR2,
        P_ERR_BUF OUT NOCOPY VARCHAR2
    ) IS

        /* Added by Ramananda for bug#4407165 */
        lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_i_trxs_pkg.validate_rg1_balances';

	v_primary_uom_code MTL_UNITS_OF_MEASURE.uom_code%TYPE;
        v_transaction_uom_code MTL_UNITS_OF_MEASURE.uom_code%TYPE;
        CURSOR c_item_primary_uom(p_organization_id NUMBER, p_inventory_item_id NUMBER) IS
            SELECT primary_uom_code
            FROM mtl_system_items
            WHERE organization_id = p_organization_id
            AND inventory_item_id = p_inventory_item_id;

        vTransToPrimaryUOMConv NUMBER;
        vMaxSlno NUMBER;

        -- Quantity field used in the insert statement
        vBalanceLoose NUMBER;
        vBalancePacked NUMBER;
        v_quantity NUMBER ; -- := NVL(p_quantity, 0) File.Sql.35 by Brathod
        v_manufactured_qty NUMBER;

   /*bug 9122545*/
   CURSOR c_org_addl_rg_flag (cp_organization_id jai_cmn_inventory_orgs.organization_id%type,
                              cp_location_id     jai_cmn_inventory_orgs.location_id%type)
   IS
   SELECT nvl(allow_negative_rg_flag,'N')
   FROM jai_cmn_inventory_orgs
   WHERE organization_id = cp_organization_id
   AND location_id = cp_location_id;

   lv_allow_negative_rg_flag jai_cmn_inventory_orgs.allow_negative_rg_flag%TYPE;
   /*end bug 9122545*/


    BEGIN

    /*-------------------------------------------------------------------------------------------------------------
     Functionality of the Package
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        - PROCEDURE validate_rg1_balances
           This procedure is used to validate whether required amount of balances are available to issue the goods.
           Populates P_ERR_BUF variable with proper message if balances are not sufficient to hit RG1 register

        - FUNCTION get_rg1_transaction_id
           This function returns a UNIQUE NUMBER used to identify the RG1 transaction type in JAI_CMN_RG_I_TRXS table

        - PROCEDURE create_rg1_entry
           This procedure takes in all the values that has to be populated into database columns.
           Generates the sequence no, serial no for REGISTER_ID, SLNO columns. Calculates the quantity balance to
           be populated into BALANCE_LOOSE column of the table and finally inserts data into JAI_CMN_RG_I_TRXS table.



    Change History
    ~~~~~~~~~~~~~~

    S.No    DD/MM/YYYY    Author and Details
    ---------------------------------------------------------------------------------------------------------------
    1       30/04/2004    Nagaraj.s for Bug # 3535729 File Version : 619.1
                          In case of RECEIPTS, and Transaction Type ='CR' transaction_id=18 is set.
    2.    8-Jun-2005      Version 116.2 jai_cmn_rg_i -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		         as required for CASE COMPLAINCE.
    3.    14/07/2005   4485801 Brathod, File Version 117.1
                       Issue: Inventory Convergence Uptake for R12 Initiative
    4.    16/04/2007	  bduvarag for the Bug#5989740, file version 120.2
			Forward porting the changes done in 11i bug#5907436


    5. 16/08/2007  vkaranam for bug#6030615,File version 120.3
                   forward porting the changes done in 115 bug#2942973(Interorg).
    6.  27-Nov-2009   Bug 9122545  File version 120.1.12000000.4 / 120.3.12010000.2 / 120.4
                      Checked the setup option to allow negative balance in quantity registers before
                      raising the error "Enough RG1 balance is not available to Issue the Goods".

    7.  06/04/2010  Bug 9550254
 	                The opening balance for the RG I has been derived from the previous
 	                financial year closing balance, if no entries found for the current year.
8.   27-apr-2010 bug#9466919
                 issue :quantity in rg registers are not in sync with the inventory.
                 fix:
                 added the rounding precision of 5 to the quantity fields while inserting.
-------------------------------------------------------------------------------------------------------------*/
    v_quantity := NVL(p_quantity, 0);  -- File.Sql.35 by Brathod
        IF p_transaction_type IN ('R', 'RA', 'IOR', 'PR', 'CR') THEN
            -- No need to test for balances for these transactions types
            -- as these are receipt transactions which increase the balances
            RETURN;
        END IF;

        OPEN c_item_primary_uom(p_organization_id, p_inventory_item_id);
        FETCH c_item_primary_uom INTO v_primary_uom_code;
        CLOSE c_item_primary_uom;

        IF p_transaction_uom_code IS NULL THEN
          v_transaction_uom_code := v_primary_uom_code;
        ELSE
          v_transaction_uom_code := p_transaction_uom_code;
        END IF;

        IF v_transaction_uom_code <> v_primary_uom_code THEN
            INV_CONVERT.inv_um_conversion(
                v_transaction_uom_code, v_primary_uom_code,
                p_inventory_item_id, vTransToPrimaryUOMConv
            );

            IF nvl(vTransToPrimaryUOMConv, 0) <= 0 THEN
                INV_CONVERT.inv_um_conversion(
                    v_transaction_uom_code, v_primary_uom_code,
                    0, vTransToPrimaryUOMConv
                );
                IF nvl(vTransToPrimaryUOMConv, 0) <= 0  THEN
                    vTransToPrimaryUOMConv := 1;
                END IF;
            END IF;

        ELSE
            vTransToPrimaryUOMConv := 1;
        END IF;

        v_quantity := nvl(p_quantity, 0) * vTransToPrimaryUOMConv;
        /*Bug 9550254 - Start*/
        /*
        SELECT max(slno) INTO vMaxSlno
        FROM JAI_CMN_RG_I_TRXS
        WHERE organization_id = p_organization_id
        AND location_id = p_location_id
        AND inventory_item_id = p_inventory_item_id
        AND fin_year = p_fin_year;

        IF vMaxSlno IS NOT NULL THEN
            SELECT NVL(balance_packed,0), NVL(balance_loose,0) INTO vBalancePacked, vBalanceLoose
            FROM JAI_CMN_RG_I_TRXS
            WHERE organization_id = p_organization_id
            and location_id = p_location_id
            and inventory_item_id = p_inventory_item_id
            AND fin_year = p_fin_year
            AND slno = vMaxSlno;

        ELSE
            -- If execution comes here, then it means it is an ISSUE type of transaction and no balances available
            p_err_buf := 'Enough RG1 balance is not available to Issue the Goods';
        END IF;
        */
        /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_I_TRXS*/
        vBalanceLoose := jai_om_rg_pkg.ja_in_rgi_balance(p_organization_id,p_location_id,p_inventory_item_id,p_fin_year,
                                                         vMaxSlno,vBalancePacked);
        /*Bug 9550254 - End*/

        IF p_transaction_type IN ('I', 'IA', 'IOI', 'PI') THEN
          /*bug 9122545*/
          OPEN  c_org_addl_rg_flag(p_organization_id, p_location_id );
          FETCH c_org_addl_rg_flag INTO lv_allow_negative_rg_flag;
          CLOSE c_org_addl_rg_flag;

          IF lv_allow_negative_rg_flag = 'Y'
          THEN
            p_err_buf := NULL;
          ELSIF lv_allow_negative_rg_flag ='N'
          THEN
            IF vBalanceLoose < v_quantity THEN
                p_err_buf := 'Enough RG1 balance is not available to Issue the Goods';
            END IF;
          END IF;
          /*end bug 9122545*/
        END IF;

         /* Added by Ramananda for bug#4407165 */
         EXCEPTION
          WHEN OTHERS THEN
            P_ERR_BUF  := null;
            FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
            FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
            app_exception.raise_exception;

    END validate_rg1_balances;

    FUNCTION get_rg1_transaction_id(
        P_TRANSACTION_TYPE                IN VARCHAR2,
        P_ISSUE_TYPE                      IN VARCHAR2,
        P_CALLED_FROM                     IN VARCHAR2
    ) RETURN NUMBER IS

        v_transaction_id NUMBER := -1;

	/* Added by Ramananda for bug#4407165 */
        lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_i_trxs_pkg.get_rg1_transaction_id';

    BEGIN
        IF p_called_from = 'MANUAL ENTRY' THEN
            IF p_transaction_type = 'R' THEN
                v_transaction_id := 91;
            ELSIF  p_transaction_type = 'IOR' THEN
                v_transaction_id := 92;
            ELSIF  p_transaction_type = 'RA' THEN
                v_transaction_id := 93;
            ELSIF  p_transaction_type = 'PR' THEN
                v_transaction_id := 94;
            ELSIF  p_transaction_type = 'CR' THEN
                v_transaction_id := 95;
            ELSIF  p_transaction_type = 'I' THEN
                v_transaction_id := 100;
            ELSIF  p_transaction_type = 'IOI' THEN
                v_transaction_id := 110;
            ELSIF  p_transaction_type = 'IA' THEN
                v_transaction_id := 120;
            ELSIF  p_transaction_type = 'PI' THEN
                v_transaction_id := 130;
            ELSE
                v_transaction_id := 99;
            END IF;

            IF p_issue_type = 'HU' THEN
                v_transaction_id := v_transaction_id + 1;
            ELSIF  p_issue_type = 'EWE' THEN
                v_transaction_id := v_transaction_id + 2;
            ELSIF  p_issue_type = 'ENE' THEN
                v_transaction_id := v_transaction_id + 3;
            ELSIF  p_issue_type = 'OF' THEN
                v_transaction_id := v_transaction_id + 4;
            ELSIF  p_issue_type = 'OPWE' THEN
                v_transaction_id := v_transaction_id + 5;
            ELSIF  p_issue_type = 'OPNE' THEN
                v_transaction_id := v_transaction_id + 6;
            END IF;

        ELSIF p_called_from = 'RECEIPTS' THEN
            IF p_transaction_type in ( 'R' ,'CR') THEN --3535729
                v_transaction_id := 18;
            ELSE
                v_transaction_id := 98;
            END IF;

        ELSIF p_called_from = 'AAA' THEN
            v_transaction_id := 97;
        -- Added by Brathod, for Inv.Convergence
        ELSIF p_called_from = 'jai_cmn_rg_opm_pkg.create_rg_i_entry'
        AND   p_transaction_type = 'R' THEN
          v_transaction_id := 202;
        ELSIF p_called_from = 'jai_cmn_rg_opm_pkg.create_rg_i_entry'
        AND   p_transaction_type = 'I' THEN
          v_transaction_id := 201;

        END IF;

        RETURN v_transaction_id;

	/* Added by Ramananda for bug#4407165 */
	 EXCEPTION
	  WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
	    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
	    app_exception.raise_exception;

    END get_rg1_transaction_id;

    PROCEDURE create_rg1_entry(
        P_REGISTER_ID OUT NOCOPY NUMBER,
        P_REGISTER_ID_PART_II             IN NUMBER,
        P_FIN_YEAR                        IN NUMBER,
        P_SLNO OUT NOCOPY NUMBER,
        P_TRANSACTION_ID                  IN NUMBER,
        P_ORGANIZATION_ID                 IN NUMBER,
        P_LOCATION_ID                     IN NUMBER,
        P_TRANSACTION_DATE                IN DATE,
        P_INVENTORY_ITEM_ID               IN NUMBER,
        P_TRANSACTION_TYPE                IN VARCHAR2,
        P_REF_DOC_ID                      IN VARCHAR2,
        P_QUANTITY                        IN NUMBER,
        P_TRANSACTION_UOM_CODE            IN VARCHAR2,
        P_ISSUE_TYPE                      IN VARCHAR2,
        P_EXCISE_DUTY_AMOUNT              IN NUMBER,
        P_EXCISE_INVOICE_NUMBER           IN VARCHAR2,
        P_EXCISE_INVOICE_DATE             IN DATE,
        P_PAYMENT_REGISTER                IN VARCHAR2,
        P_CHARGE_ACCOUNT_ID               IN NUMBER,
        P_RANGE_NO                        IN VARCHAR2,
        P_DIVISION_NO                     IN VARCHAR2,
        P_REMARKS                         IN VARCHAR2,
        P_BASIC_ED                        IN NUMBER,
        P_ADDITIONAL_ED                   IN NUMBER,
        P_OTHER_ED                        IN NUMBER,
        P_ASSESSABLE_VALUE                IN NUMBER,
        P_EXCISE_DUTY_RATE                IN NUMBER,
        P_VENDOR_ID                       IN NUMBER,
        P_VENDOR_SITE_ID                  IN NUMBER,
        P_CUSTOMER_ID                     IN NUMBER,
        P_CUSTOMER_SITE_ID                IN NUMBER,
        P_CREATION_DATE                   IN DATE,
        P_CREATED_BY                      IN NUMBER,
        P_LAST_UPDATE_DATE                IN DATE,
        P_LAST_UPDATED_BY                 IN NUMBER,
        P_LAST_UPDATE_LOGIN               IN NUMBER,
        P_CALLED_FROM                     IN VARCHAR2,
P_CESS_AMOUNT                     IN NUMBER DEFAULT NULL,/*Bug 2942973. To
resolve compilation error- bduvarag*/
	P_SH_CESS_AMOUNT                  IN NUMBER DEFAULT NULL/*Bug 5989740 bduvarag*/
    ) IS

        /* Added by Ramananda for bug#4407165 */
        lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rg_i_trxs_pkg.create_rg1_entry';

        vMaxSlno                    NUMBER;
        v_transaction_id            JAI_CMN_RG_I_TRXS.TRANSACTION_SOURCE_NUM%TYPE;
        v_primary_uom_code          MTL_UNITS_OF_MEASURE.uom_code%TYPE;
        v_transaction_uom_code      MTL_UNITS_OF_MEASURE.uom_code%TYPE;
        vTransToPrimaryUOMConv      NUMBER;

        CURSOR c_item_primary_uom(p_organization_id NUMBER, p_inventory_item_id NUMBER) IS
            SELECT primary_uom_code
            FROM mtl_system_items
            WHERE organization_id = p_organization_id
            AND inventory_item_id = p_inventory_item_id;

        -- Quantity field used in the insert statement
        v_quantity NUMBER ; --:= NVL(p_quantity, 0); File.Sql.35 by Brathod

        vBalanceLoose                   NUMBER;
        vBalancePacked                  NUMBER;
        v_manufactured_qty              NUMBER;
        v_manufactured_packed_qty       NUMBER;
        v_manufactured_loose_qty        NUMBER;
        v_for_home_use_pay_ed_qty       NUMBER;
        v_for_home_use_pay_ed_val       NUMBER;
        v_for_export_pay_ed_qty         NUMBER;
        v_for_export_pay_ed_val         NUMBER;
        v_for_export_n_pay_ed_qty       NUMBER;
        v_for_export_n_pay_ed_val       NUMBER;
        v_other_purpose                 NUMBER;
        v_to_other_fac_n_pay_ed_qty     NUMBER;
        v_to_other_fac_n_pay_ed_val     NUMBER;
        v_other_purpose_n_pay_ed_qty    NUMBER;
        v_other_purpose_n_pay_ed_val    NUMBER;
        v_other_purpose_pay_ed_qty      NUMBER;
        v_other_purpose_pay_ed_val      NUMBER;

   /*bug 9122545*/
   CURSOR c_org_addl_rg_flag (cp_organization_id jai_cmn_inventory_orgs.organization_id%type,
                              cp_location_id     jai_cmn_inventory_orgs.location_id%type)
   IS
   SELECT nvl(allow_negative_rg_flag,'N')
   FROM jai_cmn_inventory_orgs
   WHERE organization_id = cp_organization_id
   AND location_id = cp_location_id;

   lv_allow_negative_rg_flag jai_cmn_inventory_orgs.allow_negative_rg_flag%TYPE;
   /*end bug 9122545*/

    BEGIN
    v_quantity := NVL(p_quantity, 0);  -- File.Sql.35 by Brathod
        OPEN c_item_primary_uom(p_organization_id, p_inventory_item_id);
        FETCH c_item_primary_uom INTO v_primary_uom_code;
        CLOSE c_item_primary_uom;

        IF p_transaction_uom_code IS NULL THEN
          v_transaction_uom_code := v_primary_uom_code;
        ELSE
          v_transaction_uom_code := p_transaction_uom_code;
        END IF;

        IF v_transaction_uom_code <> v_primary_uom_code THEN
            INV_CONVERT.inv_um_conversion(
                v_transaction_uom_code, v_primary_uom_code,
                p_inventory_item_id, vTransToPrimaryUOMConv
            );

            IF nvl(vTransToPrimaryUOMConv, 0) <= 0 THEN
                INV_CONVERT.inv_um_conversion(
                    v_transaction_uom_code, v_primary_uom_code,
                    0, vTransToPrimaryUOMConv
                );
                IF nvl(vTransToPrimaryUOMConv, 0) <= 0  THEN
                    vTransToPrimaryUOMConv := 1;
                END IF;
            END IF;

        ELSE
            vTransToPrimaryUOMConv := 1;
        END IF;

        v_quantity := nvl(p_quantity, 0) * vTransToPrimaryUOMConv;

        /*Bug 9550254 - Start*/
        /*
        SELECT max(slno) INTO vMaxSlno
        FROM JAI_CMN_RG_I_TRXS
        WHERE organization_id = p_organization_id
        AND location_id = p_location_id
        AND inventory_item_id = p_inventory_item_id
        AND fin_year = p_fin_year;
        */
        vBalanceLoose := jai_om_rg_pkg.ja_in_rgi_balance(p_organization_id,p_location_id,p_inventory_item_id,p_fin_year,
                                                         vMaxSlno,vBalancePacked);

        IF vMaxSlno IS NOT NULL THEN
            SELECT NVL(balance_packed,0), NVL(balance_loose,0) INTO vBalancePacked, vBalanceLoose
            FROM JAI_CMN_RG_I_TRXS
            WHERE organization_id = p_organization_id
            and location_id = p_location_id
            and inventory_item_id = p_inventory_item_id
            AND fin_year = p_fin_year
            AND slno = vMaxSlno;
        /*
        ELSE
            vBalancePacked := 0;
            vBalanceLoose := 0;
        */
        END IF;
        /*Bug 9550254 - End*/

        IF p_transaction_type IN ('R', 'RA', 'IOR', 'PR', 'CR') THEN

            vBalanceLoose := vBalanceLoose + v_quantity;

            v_manufactured_qty := v_quantity;
            v_manufactured_loose_qty  := v_quantity;

        ELSIF p_transaction_type IN ('I', 'IA', 'IOI', 'PI') THEN
            IF vBalanceLoose >= v_quantity THEN
                vBalanceLoose := vBalanceLoose - v_quantity;
            ELSE
          /*bug 9122545*/
          OPEN  c_org_addl_rg_flag(p_organization_id, p_location_id );
          FETCH c_org_addl_rg_flag INTO lv_allow_negative_rg_flag;
          CLOSE c_org_addl_rg_flag;

          IF lv_allow_negative_rg_flag = 'Y'
          THEN
            vBalanceLoose := vBalanceLoose - v_quantity;
          ELSIF lv_allow_negative_rg_flag = 'N'
          THEN
                -- p_err_buf := 'Enough RG1 balance is not available to Issue the Goods';
                RAISE_APPLICATION_ERROR(-20199, 'Enough RG1 balance is not available to Issue the Goods');
                -- RETURN;
          END IF;
          /*end bug 9122545*/

            END IF;

            IF p_issue_type = 'HU' THEN
                v_for_home_use_pay_ed_qty := v_quantity;
                v_for_home_use_pay_ed_val := p_assessable_value;
            ELSIF p_issue_type = 'EWE' THEN
                v_for_export_pay_ed_qty := v_quantity;
                v_for_export_pay_ed_val := p_assessable_value;
            ELSIF p_issue_type = 'ENE' THEN
                v_for_export_n_pay_ed_qty := v_quantity;
                v_for_export_n_pay_ed_val := p_assessable_value;
                -- v_for_export_n_pay_ed_val := p_excise_duty_amount;
            ELSIF p_issue_type = 'OF' THEN
                v_to_other_fac_n_pay_ed_qty := v_quantity;
                v_to_other_fac_n_pay_ed_val := p_assessable_value;
                -- v_to_other_fac_n_pay_ed_val := p_excise_duty_amount;
            ELSIF p_issue_type = 'OPWE' THEN
                v_other_purpose_pay_ed_qty := v_quantity;
                v_other_purpose_pay_ed_val := p_assessable_value;
            ELSIF p_issue_type = 'OPNE' THEN
                v_other_purpose_n_pay_ed_qty := v_quantity;
                v_other_purpose_n_pay_ed_val := p_assessable_value;
                -- v_other_purpose_n_pay_ed_val := p_excise_duty_amount;
            END IF;

        END IF;

        IF vMaxSlno is NULL THEN
            P_SLNO := 1;
        ELSE
            P_SLNO := vMaxSlno + 1;
        END IF;

        SELECT JAI_CMN_RG_I_TRXS_S.nextval INTO P_REGISTER_ID FROM DUAL;

        v_transaction_id := get_rg1_transaction_id(
                                p_transaction_type,
                                p_issue_type,
                                p_called_from
                            );

       --added rounding precision with 5 digits for bug#9466919
        INSERT INTO JAI_CMN_RG_I_TRXS(
            REGISTER_ID,
            REGISTER_ID_PART_II,
            FIN_YEAR,
            SLNO,
            TRANSACTION_SOURCE_NUM,
            ORGANIZATION_ID,
            LOCATION_ID,
            TRANSACTION_DATE,
            INVENTORY_ITEM_ID,
            TRANSACTION_TYPE,
            REF_DOC_NO,
            MANUFACTURED_QTY,
            MANUFACTURED_PACKED_QTY,
            MANUFACTURED_LOOSE_QTY,
            FOR_HOME_USE_PAY_ED_QTY,
            FOR_HOME_USE_PAY_ED_VAL,
            FOR_EXPORT_PAY_ED_QTY,
            FOR_EXPORT_PAY_ED_VAL,
            FOR_EXPORT_N_PAY_ED_QTY,
            FOR_EXPORT_N_PAY_ED_VAL,
            OTHER_PURPOSE,
            TO_OTHER_FACTORY_N_PAY_ED_QTY,
            TO_OTHER_FACTORY_N_PAY_ED_VAL,
            OTHER_PURPOSE_N_PAY_ED_QTY,
            OTHER_PURPOSE_N_PAY_ED_VAL,
            OTHER_PURPOSE_PAY_ED_QTY,
            OTHER_PURPOSE_PAY_ED_VAL,
            PRIMARY_UOM_CODE,
            TRANSACTION_UOM_CODE,
            BALANCE_PACKED,
            BALANCE_LOOSE,
            ISSUE_TYPE,
            EXCISE_DUTY_AMOUNT,
            EXCISE_INVOICE_NUMBER,
            EXCISE_INVOICE_DATE,
            PAYMENT_REGISTER,
            CHARGE_ACCOUNT_ID,
            RANGE_NO,
            DIVISION_NO,
            REMARKS,
            BASIC_ED,
            ADDITIONAL_ED,
            OTHER_ED,
            EXCISE_DUTY_RATE,
            VENDOR_ID,
            VENDOR_SITE_ID,
            CUSTOMER_ID,
            CUSTOMER_SITE_ID,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            POSTED_FLAG,
            MASTER_FLAG,
            CESS_AMT,/*BUG *6030615*/
	    SH_CESS_AMT/*Bug 5989740 bduvarag*/
        ) VALUES (
            P_REGISTER_ID,
            P_REGISTER_ID_PART_II,
            P_FIN_YEAR,
            P_SLNO,
            V_TRANSACTION_ID,
            P_ORGANIZATION_ID,
            P_LOCATION_ID,
            P_TRANSACTION_DATE,
            P_INVENTORY_ITEM_ID,
            P_TRANSACTION_TYPE,
            P_REF_DOC_ID,
            round(V_MANUFACTURED_QTY,5),
            round(V_MANUFACTURED_PACKED_QTY,5),
            round(V_MANUFACTURED_LOOSE_QTY,5),
            round(V_FOR_HOME_USE_PAY_ED_QTY,5),
          V_FOR_HOME_USE_PAY_ED_VAL,
            round(V_FOR_EXPORT_PAY_ED_QTY,5),
            V_FOR_EXPORT_PAY_ED_VAL,
            round(V_FOR_EXPORT_N_PAY_ED_QTY,5),
            V_FOR_EXPORT_N_PAY_ED_VAL,
            V_OTHER_PURPOSE,
            round(V_TO_OTHER_FAC_N_PAY_ED_QTY,5),
            V_TO_OTHER_FAC_N_PAY_ED_VAL,
            round(V_OTHER_PURPOSE_N_PAY_ED_QTY,5),
            V_OTHER_PURPOSE_N_PAY_ED_VAL,
            round(V_OTHER_PURPOSE_PAY_ED_QTY,5),
            V_OTHER_PURPOSE_PAY_ED_VAL,
            V_PRIMARY_UOM_CODE,
            P_TRANSACTION_UOM_CODE,
            round(vBalancePacked,5),
            round(vBalanceLoose,5),
            P_ISSUE_TYPE,
            P_EXCISE_DUTY_AMOUNT,
            P_EXCISE_INVOICE_NUMBER,
            P_EXCISE_INVOICE_DATE,
            P_PAYMENT_REGISTER,
            P_CHARGE_ACCOUNT_ID,
            P_RANGE_NO,
            P_DIVISION_NO,
            P_REMARKS,
            P_BASIC_ED,
            P_ADDITIONAL_ED,
            P_OTHER_ED,
            P_EXCISE_DUTY_RATE,
            P_VENDOR_ID,
            P_VENDOR_SITE_ID,
            P_CUSTOMER_ID,
            P_CUSTOMER_SITE_ID,
            P_CREATION_DATE,
            P_CREATED_BY,
            P_LAST_UPDATE_DATE,
            P_LAST_UPDATED_BY,
            P_LAST_UPDATE_LOGIN,
            'N',
            'N',
            P_CESS_AMOUNT,/*BUG *6030615*/
	    P_SH_CESS_AMOUNT/*Bug 5989740 bduvarag*/
        );

   /* Added by Ramananda for bug#4407165 */
  EXCEPTION
   WHEN OTHERS THEN
    P_REGISTER_ID  := null;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

    END create_rg1_entry;

END jai_cmn_rg_i_trxs_pkg;

/
