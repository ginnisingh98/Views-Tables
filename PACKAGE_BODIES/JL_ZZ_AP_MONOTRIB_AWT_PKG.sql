--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AP_MONOTRIB_AWT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AP_MONOTRIB_AWT_PKG" AS
/* $Header: jlarmtbb.pls 120.0.12010000.9 2009/12/14 13:14:43 rsaini noship $ */

FUNCTION BeforeReport
   RETURN BOOLEAN

IS


    ---------------------------------------------------------------------------------
    ------ Main Supplier Cursor to Fetch all Suppliers with Status as Monotributistas
    ---------------------------------------------------------------------------------

    CURSOR MonoTrib_Suppliers (p_supplier_id NUMBER) IS
        SELECT vendor_name          supplier_name,
               vendor_id            supplier_id,
	             NVL(individual_1099,num_1099)||'-'||global_attribute12 taxpayer_id,
	             global_attribute8    simplif_regime_cont_type
	      FROM   ap_suppliers
        WHERE  global_attribute1 = '06'
        AND    global_attribute8 IN ('GOODS','SERVICES')
        AND    (vendor_id = NVL(p_supplier_id,vendor_id));



    -------------------------------------------------------------------------------------
    ------- Main Invoice Cursor to fetch Invoices pertaining to Monotributistas Suppliers
    -------------------------------------------------------------------------------------

    CURSOR monotrib_supp_inv(p_supplier_id NUMBER, p_to_date DATE, p_from_date DATE) IS
			SELECT 	ai.invoice_id  invoice_id
					    ,ai.invoice_num invoice_num
              ,ai.invoice_date    invoice_date
					    ,ai.payment_status_flag invoice_status
					    ,ai.global_attribute13 dgi_type
					    ,SUM(DECODE(ai.invoice_currency_code, 'ARS', aid.amount, aid.base_amount)) invoice_amt
			FROM 	  ap_invoices ai,
              ap_invoice_lines ail,
              ap_invoice_distributions aid
			WHERE 	ai.vendor_id = p_supplier_id
      AND   ai.invoice_id = aid.invoice_id
      AND   ai.invoice_id = ail.invoice_id
      AND   ail.line_number = aid.invoice_line_number
      AND   ai.invoice_date BETWEEN p_from_date AND p_to_date
      AND   ail.line_type_lookup_code NOT IN ('AWT','TAX')
      AND   ai.invoice_type_lookup_code IN ('STANDARD','PREPAYMENT','CREDIT')
      AND   ai.payment_status_flag IN ('N','P','Y')
      AND   ai.cancelled_date IS NULL
      AND   ai.legal_entity_id = p_legal_entity_id
      GROUP BY ai.invoice_id, ai.invoice_date, ai.invoice_num, ai.payment_status_flag, ai.global_attribute13
      ORDER BY ai.invoice_date,ai.invoice_id;

		   type supp_inv_type is table of monotrib_supp_inv%rowtype;
                c_supp_inv supp_inv_type;
		type supp_type is table of MonoTrib_Suppliers%rowtype;
             c_supp_rec supp_type;

----------------------------------
----- Local Variables Definition
----------------------------------

	v_from_date	           		 DATE;
	v_to_date 	         		   DATE;
	v_flag                     NUMBER;
	v_running_amount         	 NUMBER;
	v_threshold_met          	 VARCHAR2(1);
	Applicability_Chngd_flag 	 VARCHAR2(1);
	v_supp_monotrib_status  	 VARCHAR2(1);
	v_supp_update_status    	 VARCHAR2(1);
	v_inv_amt                	 NUMBER;
	v_inv_tax_amt           	 NUMBER;
	v_threshold_amt         	 NUMBER;
  v_threshold_chk            NUMBER;
	v_update_supp_appl 			   VARCHAR2(1);
	v_inv_amt_without_tax      NUMBER;
BEGIN

p_debug_log := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

---------------------------------------------------------------------------------------------------
----- Deriving the Threshold values for Goods and Services Suppliers as fixed by Simplified Regime
---------------------------------------------------------------------------------------------------

BEGIN


	SELECT 	nvl(threshold_amt,0) INTO p_goods_supp_thld
	FROM   	jl_ar_ap_mtbt_thresholds
	WHERE	contributor_type = 'GOODS'
	AND 	p_report_date BETWEEN start_date AND nvl(end_date,add_months(sysdate,12*50));

	EXCEPTION
	   WHEN OTHERS THEN
			NULL;
END;

BEGIN

	SELECT 	nvl(threshold_amt,0) INTO p_service_supp_thld
	FROM   	JL_AR_AP_MTBT_THRESHOLDS
	WHERE  	contributor_type = 'SERVICES'
	AND 	p_report_date BETWEEN start_date AND nvl(end_date,add_months(sysdate,12*50));

	EXCEPTION
	   WHEN OTHERS THEN
			NULL;
END;


-- Cursor OPEN for Monotributa Suppliers
--
--FOR c_supp IN MonoTrib_Suppliers(p_supplier_id)LOOP
--
  OPEN MonoTrib_Suppliers(p_supplier_id);
  FETCH MonoTrib_Suppliers BULK COLLECT INTO c_supp_rec;
  CLOSE MonoTrib_Suppliers;

  FOR i_supp IN 1..c_supp_rec.COUNT LOOP ---supplier loop start

        v_running_amount 	  := 0;
        v_threshold_met  	  := 'N';
		    v_update_supp_appl 	:= 'N';

        IF p_debug_log = 'Y' THEN
           FND_FILE.put_line( FND_FILE.LOG, 'INSIDE MONOTRIBUTA SUPPLIER LOOP : SUPPLIER NAME - ' ||c_supp_rec(i_supp).SUPPLIER_NAME);
        END IF;


		IF (c_supp_rec(i_supp).simplif_regime_cont_type = 'GOODS') THEN
			 IF (p_goods_supp_thld = 0) THEN
				FND_FILE.put_line( FND_FILE.LOG, 'ERROR : THRESHOLD value for "GOODS" Contributor type is not defined for Date:'||P_REPORT_DATE);
				v_threshold_chk := 0;
			 ELSE
				v_threshold_amt := p_goods_supp_thld;
			 END IF;
        ELSIF (c_supp_rec(i_supp).simplif_regime_cont_type = 'SERVICES') THEN
				IF (p_service_supp_thld = 0) THEN
					FND_FILE.put_line( FND_FILE.LOG, 'ERROR : THRESHOLD value for "SERVICES" Contributor type is not defined for Date:'||P_REPORT_DATE);
					v_threshold_chk := 0;
				ELSE
					v_threshold_amt := p_service_supp_thld;
				END IF;
        END IF;

		IF (v_threshold_chk =0) THEN
			ROLLBACK;
			RETURN (FALSE);
		END IF;



      	---------------------------------------------------------------------------------------------
        -- Deriving boder To and From Dates based on Reporting Date from Report Parameter
		-- The Logic will derive closest Invoice Date to REPORTING_DATE value as To_Date and
		-- From_Date will be the 11 months past date
	---------------------------------------------------------------------------------------------

    BEGIN
            SELECT 	max(invoice_date), trunc(add_months(max(invoice_date), -11),'MM')
			      INTO 	  v_to_date, v_from_date
            FROM 	  AP_INVOICES
            WHERE   vendor_id = c_supp_rec(i_supp).supplier_id
            AND 	  invoice_date <= P_REPORT_DATE;

        EXCEPTION
			WHEN OTHERS THEN
				 v_to_date   := NULL;
				 v_from_date := NULL;

				   IF (p_debug_log = 'Y') THEN
                  FND_FILE.put_line( FND_FILE.LOG,'AN ERROR IS ENCOUNTERED WHILE DERIVING TO_DATE and FROM_DATE '|| SQLCODE || 'ERROR ' || SQLERRM);
				    END IF;
        END;

        -----------------------------------------------------------------------------------------------------------
		-- Logic to check if Simplified Regime Withholding Tax rate is already applicable to Monotributa Supplier
		-----------------------------------------------------------------------------------------------------------
        BEGIN
            SELECT 	1
			      INTO 	  v_flag
            FROM 	  JL_ZZ_AP_AWT_TYPES awt,
                    JL_ZZ_AP_SUPP_AWT_TYPES swt
            WHERE 	swt.vendor_id = c_supp_rec(i_supp).SUPPLIER_ID
            AND 	  swt.awt_type_code = awt.awt_type_code
            AND 	  awt.simplified_regime_flag = 'Y'
            AND 	  swt.wh_subject_flag = 'Y'
            AND 	  ROWNUM = 1;

			EXCEPTION
				WHEN OTHERS THEN
					 v_flag := 0;
					 NULL;
        END;

---- If Supplier is Monotributa and is not already subjected to Special Withholding tax
--
	IF v_flag = 0 THEN   ---

        OPEN Monotrib_Supp_Inv(c_supp_rec(i_supp).SUPPLIER_ID, v_to_date, v_from_date);
				LOOP --LOOP for LIMIT
				    FETCH monotrib_supp_inv BULK COLLECT INTO c_supp_inv LIMIT 100;


				         FOR inv_rec IN 1..c_supp_inv.COUNT
				             LOOP --for loop of inv_rec
                          IF p_debug_log = 'Y' THEN
                           FND_FILE.put_line( FND_FILE.LOG, 'INSIDE INVOICE LOOP : INVOICE ID '|| c_supp_inv(inv_rec).INVOICE_ID);
                          END IF;


                        ---- Logic to check if Running sum of Monotributa Supplier Invoices reached Threshold or not
			                    v_running_amount := v_running_amount + c_supp_inv(inv_rec).INVOICE_AMT;
                           IF v_running_amount >= v_threshold_amt THEN
                                v_threshold_met := 'Y';
                           END IF;
                            IF p_debug_log = 'Y' THEN
                                FND_FILE.put_line( FND_FILE.LOG, 'Invoice_amount without awt and tax : '|| c_supp_inv(inv_rec).INVOICE_AMT);
                                FND_FILE.put_line( FND_FILE.LOG, 'Running sum : '|| v_running_amount);
                             END IF;
			---- Logic to derive Invoice Amount and Invoice amount excluding tax
			                     BEGIN
                                     SELECT ai.INVOICE_AMOUNT,
                                            SUM(DECODE(ail.line_type_lookup_code,'TAX',(DECODE(ai.invoice_currency_code,'ARS', AID.amount, AID.base_amount)),0))
                                     INTO   v_inv_amt,
                                            v_inv_tax_amt
                                     FROM   ap_invoices ai,
                                            ap_invoice_lines ail,
                                            ap_invoice_distributions aid
                                     WHERE  ai.invoice_id = AID.invoice_id
                                     AND    ai.invoice_id = ail.invoice_id
                                     AND    ail.line_number = aid.invoice_line_number
                                     AND    ai.invoice_id = c_supp_inv(inv_rec).invoice_id
                                     GROUP BY ai.invoice_amount;

                          EXCEPTION
                              WHEN OTHERS THEN
                                  FND_FILE.put_line( FND_FILE.LOG,'AN ERROR IS ENCOUNTERED WHILE FETCHING INVOICE AMT '|| SQLCODE || 'ERROR ' || SQLERRM);
                           END;
						               v_inv_amt_without_tax := v_inv_amt - v_inv_tax_amt;
                          /*---------------------------------------------------------------------------------------------------------
                                      ----Logic for inserting Date into TEMP table
                          ----------------------------------------------------------------------------------------------------------
                                      ----Report Mode = 'Verify(01)'
                                      ------------If Threshold is met then Threshold Met = 'Y',
                          -------------------------------------Supplier Current Status for Sp.Witholding Tax = 'N',
                          -------------------------------------Supplier Updated in this cycle = 'N'
                                      ------------If Threshold is met then Threshold Met = 'N',
                          -------------------------------------Supplier Current Status for Sp.Witholding Tax = 'N',
                          -------------------------------------Supplier Updated in this cycle = 'N'
                                      ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                      ----Report Mode = 'Update(02)'
                                      ------------If Threshold is met then Threshold Met = 'Y',
                          -------------------------------------Supplier Current Status for Sp.Witholding Tax = 'Y',
                          -------------------------------------Supplier Updated in this cycle = 'Y'
                                      ------------If Threshold is met then Threshold Met = 'N',
                          -------------------------------------Supplier Current Status for Sp.Witholding Tax = 'N',
                          -------------------------------------Supplier Updated in this cycle = 'N'
                                      ------------------------------------------------------------------------------------------------------------*/

                            IF P_REPORT_MODE = '01' THEN
                                 IF v_threshold_Met = 'Y' THEN
                                    v_supp_monotrib_status := 'N';
                                    v_supp_update_status   := 'N';
                                    Insert_temp_data( c_supp_rec(i_supp).SUPPLIER_NAME,
                                                    c_supp_rec(i_supp).SUPPLIER_ID,
                                                    c_supp_rec(i_supp).TAXPAYER_ID,
                                                    c_supp_rec(i_supp).SIMPLIF_REGIME_CONT_TYPE,
                                                    v_supp_monotrib_status,
                                                    v_supp_update_status,
                                                    v_threshold_amt,
                                                    c_supp_inv(inv_rec).INVOICE_ID,
                                                    c_supp_inv(inv_rec).INVOICE_NUM,
                                                    c_supp_inv(inv_rec).INVOICE_DATE,
                                                    c_supp_inv(inv_rec).INVOICE_STATUS,
                                                    c_supp_inv(inv_rec).DGI_TYPE,
                                                    v_inv_amt,
                                                    v_inv_amt_without_tax,
                                                    v_threshold_Met );
                                 ELSIF v_threshold_Met = 'N' THEN
                                    v_supp_monotrib_status := 'N';
                                    v_supp_update_status   := 'N';
                                    Insert_temp_data( c_supp_rec(i_supp).SUPPLIER_NAME,
                                                      c_supp_rec(i_supp).SUPPLIER_ID,
                                                      c_supp_rec(i_supp).TAXPAYER_ID,
                                                      c_supp_rec(i_supp).SIMPLIF_REGIME_CONT_TYPE,
                                                      v_supp_monotrib_status,
                                                      v_supp_update_status,
                                                      v_threshold_amt,
                                                      c_supp_inv(inv_rec).INVOICE_ID,
                                                      c_supp_inv(inv_rec).INVOICE_NUM,
                                                      c_supp_inv(inv_rec).INVOICE_DATE,
                                                      c_supp_inv(inv_rec).INVOICE_STATUS,
                                                      c_supp_inv(inv_rec).DGI_TYPE,
                                                      v_inv_amt,
                                                      v_inv_amt_without_tax,
                                                      v_threshold_Met );
                                  END IF;

                          ELSIF P_REPORT_MODE = '02' THEN
                                            IF v_threshold_Met = 'Y' THEN
                              -----------------------------------------------------------------------------------------------------------------
                              ---- Call to Routine for Updating Supplier Special Witholding Tax applicability, once they have met the threshold
                              -----------------------------------------------------------------------------------------------------------------
                                                      IF (v_update_supp_appl 	= 'N') THEN
                                                          --call of procedure to update the isupplier's applicability
                                                            Update_Supplier_Applicability (c_supp_rec(i_supp).SUPPLIER_ID, Applicability_Chngd_flag);
                                                            v_update_supp_appl := 'Y';
                                                       END IF;

                                                        ---- Proceed if the Applicability is Successfully updated
                                                        IF Applicability_Chngd_flag = 'Y' AND c_supp_inv(inv_rec).invoice_status = 'N' THEN
                                                                --call of procedure to update the invoice withholding distribution
                                                                Update_Monotrib_Inv_Distrib_Wh(c_supp_inv(inv_rec).invoice_id, c_supp_rec(i_supp).SUPPLIER_ID);
                                                                IF p_debug_log = 'Y' THEN
                                                                     FND_FILE.put_line( FND_FILE.LOG, 'INVOICE APPLICABILITY UPDATED SUCCESSFULLY FOR INVOICE ID : '|| c_supp_inv(inv_rec).invoice_id);
                                                                     FND_FILE.put_line( FND_FILE.LOG, '*******************************');
                                                                END IF;
                                                                v_supp_monotrib_status := 'Y';
                                                                v_supp_update_status   := 'Y';
                                                                Insert_temp_data( c_supp_rec(i_supp).SUPPLIER_NAME,
                                                                                  c_supp_rec(i_supp).SUPPLIER_ID,
                                                                                  c_supp_rec(i_supp).TAXPAYER_ID,
                                                                                  c_supp_rec(i_supp).SIMPLIF_REGIME_CONT_TYPE,
                                                                                  v_supp_monotrib_status,
                                                                                  v_supp_update_status,
                                                                                  v_threshold_amt,
                                                                                  c_supp_inv(inv_rec).INVOICE_ID,
                                                                                  c_supp_inv(inv_rec).INVOICE_NUM,
                                                                                  c_supp_inv(inv_rec).INVOICE_DATE,
                                                                                  c_supp_inv(inv_rec).INVOICE_STATUS,
                                                                                  c_supp_inv(inv_rec).DGI_TYPE,
                                                                                  v_inv_amt,
                                                                                  v_inv_amt_without_tax,
                                                                                  v_threshold_Met );

                                                           END IF;
                                            ELSIF v_threshold_Met = 'N' THEN
                                                v_supp_monotrib_status := 'N';
                                                v_supp_update_status   := 'N';
                                                Insert_temp_data( c_supp_rec(i_supp).SUPPLIER_NAME,
                                                                  c_supp_rec(i_supp).SUPPLIER_ID,
                                                                  c_supp_rec(i_supp).TAXPAYER_ID,
                                                                  c_supp_rec(i_supp).SIMPLIF_REGIME_CONT_TYPE,
                                                                  v_supp_monotrib_status,
                                                                  v_supp_update_status,
                                                                  v_threshold_amt,
                                                                  c_supp_inv(inv_rec).INVOICE_ID,
                                                                  c_supp_inv(inv_rec).INVOICE_NUM,
                                                                  c_supp_inv(inv_rec).INVOICE_DATE,
                                                                  c_supp_inv(inv_rec).INVOICE_STATUS,
                                                                  c_supp_inv(inv_rec).DGI_TYPE,
                                                                  v_inv_amt,
                                                                  v_inv_amt_without_tax,
                                                                  v_threshold_Met );
                                            END IF; --end of v_threshold_Met check
                          END IF; -- end of P_REPORT_MODE check


				END LOOP; ----LOOP for LIMIT
				EXIT WHEN monotrib_supp_inv%NOTFOUND;

			END LOOP; -- end of invoice cursor "Monotrib_Supp_Inv"
			CLOSE monotrib_supp_inv;
---- If the Supplier is already subjected to Special Withholding Tax
ELSE  -- if v_flag <> 0
            FND_FILE.put_line( FND_FILE.LOG,'Supplier is already subjected to Simplified Regime Special Tax');
            v_supp_monotrib_status := 'Y';
            Insert_temp_data(c_supp_rec(i_supp).SUPPLIER_NAME,
								c_supp_rec(i_supp).SUPPLIER_ID,
								c_supp_rec(i_supp).TAXPAYER_ID,
								c_supp_rec(i_supp).SIMPLIF_REGIME_CONT_TYPE,
								v_supp_monotrib_status,
								'N',
								NULL,
								NULL,
								NULL,
								NULL,
								NULL,
								NULL,
								NULL,
								NULL,
								NULL );

END IF;  -- end of v_flag check

END LOOP;     --supplier loop end
RETURN (TRUE);
FND_FILE.put_line( FND_FILE.LOG,'Returning TRUE');
EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.put_line( FND_FILE.LOG,'AN ERROR IS ENCOUNTERED IN BEFORE REPORT FUNCTION '|| SQLCODE || 'ERROR ' || SQLERRM);
        RETURN (FALSE);
END BeforeReport;

-------------------------------------------------------------
----- Routine to Insert date into Temp Table
-------------------------------------------------------------

PROCEDURE Insert_temp_data(
							P_SUPPLIER_NAME 			IN VARCHAR2,
							P_SUPPLIER_ID 				IN NUMBER,
							P_TAXPAYER_ID 				IN VARCHAR2,
							P_SIMPLIF_REGIME_CONT_TYPE 	IN VARCHAR2,
							P_supp_monotrib_status 		IN VARCHAR2,
							P_supp_update_status 		IN VARCHAR2,
							P_threshold_amt 			IN NUMBER,
							P_INVOICE_ID 				IN NUMBER,
							P_INVOICE_NUM 				IN VARCHAR2,
							P_INVOICE_DATE 				IN DATE,
							P_INVOICE_STATUS 			IN VARCHAR2,
							P_DGI_TYPE 					IN VARCHAR2,
							P_INV_AMOUNT 				IN NUMBER,
							P_INV_AMT_WOUT_TAX 			IN NUMBER,
							P_threshold_Met 			IN VARCHAR2
							)
IS

BEGIN
    INSERT
	INTO 	JL_ZZ_INFO_T
			(/*Supplier details*/
             JL_INFO_V1
            ,JL_INFO_N1
			,JL_INFO_V2
			,JL_INFO_V3
			,JL_INFO_V4
            ,JL_INFO_V5
            ,JL_INFO_N6
            /*Invoice Details*/
			,JL_INFO_N3
			,JL_INFO_V6
			,JL_INFO_D1
			,JL_INFO_V7
			,JL_INFO_V8
			,JL_INFO_N4
			,JL_INFO_N5
			,JL_INFO_V9)
    VALUES (/*Supplier details*/
            P_SUPPLIER_NAME,
            P_SUPPLIER_ID,
			P_TAXPAYER_ID,
			P_SIMPLIF_REGIME_CONT_TYPE,
			P_supp_monotrib_status,
			P_supp_update_status,
            P_threshold_amt,
            /*Invoice Details*/
			P_INVOICE_ID,
  			P_INVOICE_NUM,
			P_INVOICE_DATE,
			P_INVOICE_STATUS,
			P_DGI_TYPE,
			P_INV_AMOUNT,
			P_INV_AMT_WOUT_TAX,
			P_threshold_Met);

EXCEPTION
    WHEN OTHERS THEN
         FND_FILE.put_line( FND_FILE.LOG,'AN ERROR IS ENCOUNTERED WHILE INSERTING INTO TEMP TABLE '|| SQLCODE || 'ERROR ' || SQLERRM);
		 RAISE;
END Insert_temp_data;

-----------------------------------------------------------------------------------------------------------------
---- Call to Routine for Updating Supplier Special Witholding Tax applicability, once they have met the threshold
-----------------------------------------------------------------------------------------------------------------

PROCEDURE Update_Supplier_Applicability( P_Supplier_Id 	IN po_vendors.vendor_id%Type,
Applicability_Chngd_flag  OUT NOCOPY VARCHAR2)
IS
   CURSOR awt_types IS
        SELECT 	awt_type_code, description, supplier_exempt_level, multilat_contrib_flag
	    FROM 	JL_ZZ_AP_AWT_TYPES
		WHERE 	Simplified_Regime_Flag = 'Y'
		AND 	nvl(start_date_active, sysdate) <= sysdate
		AND 	nvl(end_date_active, sysdate) >= sysdate;

	v_tax_id               NUMBER(15);
	v_tax_name             VARCHAR2(15);
	v_last_update_by       NUMBER;
	v_last_update_login    NUMBER;
	v_Org_Id               NUMBER;
	v_supp_awt_type_id     NUMBER;
	v_supp_awt_code_id     NUMBER;
	v_flag                 NUMBER;
	v_temp1                NUMBER;
	v_temp2                NUMBER;

BEGIN

	--  Get the information of WHO Columns from FND_GLOBAL
	v_last_update_by := FND_GLOBAL.User_ID;
	v_last_update_login := FND_GLOBAL.Login_Id;
	fnd_profile.get('ORG_ID',v_Org_Id);
	Applicability_Chngd_flag := 'N';

	IF p_debug_log = 'Y' THEN
		FND_FILE.put_line( FND_FILE.LOG, 'INSIDE SUPPLIER APPLICABILITY UPDATE ROUTINE FOR SUPPLIER ID : '|| P_Supplier_Id);
	END IF;

	FOR c_rec IN awt_types LOOP
			SELECT 	tax_id, name
			INTO 	v_tax_id, v_tax_name
			FROM 	AP_TAX_CODES
			WHERE 	global_attribute4 = c_rec.awt_type_code
			AND 	inactive_date IS NULL
			AND 	creation_date >= (	SELECT 	max(creation_date)
										FROM 	AP_TAX_CODES_ALL
										WHERE 	global_attribute4 = c_rec.awt_type_code
										AND 	inactive_date IS NULL
									 )
			AND 	ROWNUM = 1;

			SELECT 	count(*)
			INTO 	v_flag
			FROM 	JL_ZZ_AP_SUPP_AWT_TYPES
			WHERE 	awt_type_code = c_rec.awt_type_code
			AND 	vendor_id = P_Supplier_Id;

	IF v_flag = 0 THEN
				SELECT jl_zz_ap_supp_awt_types_s.nextval
					INTO   v_supp_awt_type_id
					FROM   dual;
				SELECT jl_zz_ap_sup_awt_cd_s.nextval
					INTO   v_supp_awt_code_id
					FROM   dual;

			---- Inserting into Supplier Applicability table
			INSERT INTO JL_ZZ_AP_SUPP_AWT_TYPES (SUPP_AWT_TYPE_ID,
												 VENDOR_ID,
												 AWT_TYPE_CODE,
												 WH_SUBJECT_FLAG,
												 CREATED_BY,
												 CREATION_DATE,
												 LAST_UPDATED_BY,
												 LAST_UPDATE_DATE,
												 LAST_UPDATE_LOGIN)
									 VALUES (v_supp_awt_type_id,
											 P_Supplier_Id,
									 c_rec.awt_type_code,
							 'Y',
							 v_last_update_by,
							 sysdate,
							 v_last_update_by,
							 sysdate,
							 v_last_update_login
												 );

			---- Defaulting Tax Code for Special AWT Type
			INSERT INTO JL_ZZ_AP_SUP_AWT_CD_ALL (SUPP_AWT_CODE_ID,
												 SUPP_AWT_TYPE_ID,
							 TAX_ID,
							 PRIMARY_TAX_FLAG,
							 CREATED_BY,
							 CREATION_DATE,
							 LAST_UPDATED_BY,
							 LAST_UPDATE_DATE,
							 LAST_UPDATE_LOGIN,
							 EFFECTIVE_START_DATE,
										 ORG_ID)
										  VALUES (v_supp_awt_code_id,
									  v_supp_awt_type_id,
								  v_tax_id,
							  'Y',
							  v_last_update_by,
							  sysdate,
							  v_last_update_by,
							  sysdate,
							  v_last_update_login,
							  TO_DATE('01/01/1950','DD/MM/YYYY'),
							  v_org_id
							  );
			Applicability_Chngd_flag := 'Y';
			IF p_debug_log = 'Y' THEN
			   FND_FILE.put_line( FND_FILE.LOG, '*******************************');
			   FND_FILE.put_line( FND_FILE.LOG, 'SUPPLIER APPLICABILITY UPDATED SUCCESSFULLY FOR SUPPLIER ID : '|| P_Supplier_Id);
			END IF;

	ELSE
		  UPDATE JL_ZZ_AP_SUPP_AWT_TYPES SET WH_SUBJECT_FLAG = 'Y'
				WHERE awt_type_code = c_rec.awt_type_code
			   AND vendor_id = P_Supplier_Id;

		  SELECT SUPP_AWT_TYPE_ID INTO v_temp1
			   FROM JL_ZZ_AP_SUPP_AWT_TYPES
			   WHERE awt_type_code = c_rec.awt_type_code
					 AND vendor_id = P_Supplier_Id
					 AND ROWNUM = 1;

		  UPDATE JL_ZZ_AP_SUP_AWT_CD SET PRIMARY_TAX_FLAG = 'N'
					WHERE SUPP_AWT_TYPE_ID = v_temp1;

		  SELECT count(*) INTO v_temp2
			   FROM JL_ZZ_AP_SUP_AWT_CD
			   WHERE TAX_ID = v_tax_id
				   AND SUPP_AWT_TYPE_ID = v_temp1;

		  IF v_temp2 > 0 THEN
			 UPDATE JL_ZZ_AP_SUP_AWT_CD SET PRIMARY_TAX_FLAG = 'Y'
					WHERE TAX_ID = v_tax_id
					AND SUPP_AWT_TYPE_ID = v_temp1;
		  ELSE
			 SELECT jl_zz_ap_sup_awt_cd_s.nextval
					INTO   v_supp_awt_code_id
					FROM   dual;
			 INSERT INTO JL_ZZ_AP_SUP_AWT_CD_ALL(SUPP_AWT_CODE_ID,
												 SUPP_AWT_TYPE_ID,
							 TAX_ID,
							 PRIMARY_TAX_FLAG,
							 CREATED_BY,
							 CREATION_DATE,
							 LAST_UPDATED_BY,
							 LAST_UPDATE_DATE,
							 LAST_UPDATE_LOGIN,
							 EFFECTIVE_START_DATE,
										 ORG_ID)
										  VALUES (v_supp_awt_code_id,
									  v_temp1,
								  v_tax_id,
							  'Y',
							  v_last_update_by,
							  sysdate,
							  v_last_update_by,
							  sysdate,
							  v_last_update_login,
							  TO_DATE('01/01/1950','DD/MM/YYYY'),
							  v_org_id
							  );
		   END IF;
			Applicability_Chngd_flag := 'Y';
			IF p_debug_log = 'Y' THEN
			   FND_FILE.put_line( FND_FILE.LOG, '*******************************');
			   FND_FILE.put_line( FND_FILE.LOG, 'SUPPLIER APPLICABILITY UPDATED SUCCESSFULLY FOR SUPPLIER ID : '|| P_Supplier_Id);
			END IF;
	END IF;

	END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        Applicability_Chngd_flag := 'N';
	FND_FILE.put_line( FND_FILE.LOG,'AN ERROR IS ENCOUNTERED WHILE CHANGING SUPPLIER APPLICABILITY '|| SQLCODE || 'ERROR ' || SQLERRM);
        RAISE;
END Update_Supplier_Applicability;


PROCEDURE Update_Monotrib_Inv_Distrib_Wh
             ( P_Invoice_Id IN ap_invoices_all.invoice_id%TYPE
             , P_vendor_id  IN po_vendors.vendor_id%Type
             --, P_Defaulting_flag BOOLEAN
             ) IS
       CURSOR  Invoice_Distrib IS
             SELECT  invoice_distribution_id
             FROM  ap_invoice_distributions
             WHERE  invoice_id = P_Invoice_ID;
   -- The following variables are used to get the information from the invoice
   -- ditribution lines.
    v_tax_payer_id     ap_invoice_distributions_all.global_attribute2%TYPE;
    v_ship_to_loc      ap_invoice_distributions_all.global_attribute3%TYPE;
    v_line_type        ap_invoice_distributions_all. line_type_lookup_code%TYPE;

BEGIN

    IF p_debug_log = 'Y' THEN
          FND_FILE.put_line( FND_FILE.LOG, 'INSIDE MONOTRIBUTO UNPAID INVOICE UPDATE PROCEDURE : '|| p_vendor_id ||'-'|| p_invoice_id);
    END IF;

    FOR db_reg IN Invoice_Distrib LOOP
        -------------------------------------------------------------------
        -- Information Invoice Distribution Lines.
        -------------------------------------------------------------------
        SELECT apid.global_attribute2           -- Taxpayer Id for Colombia
               ,apid.global_attribute3          -- Ship to Location Argentina
               ,apid.line_type_lookup_code      -- Line Type
          INTO  v_tax_payer_id,
                v_ship_to_loc,
                v_line_type
          FROM  AP_Invoice_Distributions apid,
                AP_Invoice_Lines apil
          WHERE apid.invoice_id               = P_Invoice_Id
          AND apid.invoice_distribution_id = db_reg.invoice_distribution_id
          AND apil.line_number = apid.invoice_line_number
          AND apid.invoice_id = apil.invoice_id;

          Monotrib_Wh_Def_Line(P_Invoice_Id
                          ,db_reg.invoice_distribution_id
                          ,v_tax_payer_id
                          ,v_ship_to_loc
                          ,v_line_type
                          ,p_vendor_id
                          );
	END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.put_line( FND_FILE.LOG,'AN ERROR IS ENCOUNTERED WHILE CHANGING INVOICE DISTRIBUTION FOR AWT '|| SQLCODE || 'ERROR ' || SQLERRM);
        RAISE;
END Update_Monotrib_Inv_Distrib_Wh;


PROCEDURE Monotrib_Wh_Def_Line
            ( p_invoice_id    NUMBER,
              p_inv_dist_id   NUMBER,
              p_tax_payer_id  ap_invoice_distributions_all.global_attribute2%TYPE,
              p_ship_to_loc   VARCHAR2,
              p_line_type     VARCHAR2,
              p_vendor_id     NUMBER
             ) IS
   ---------------------------------------------------------------------
   -- Cursor  Supplier Withholding Types.
   ---------------------------------------------------------------------
   CURSOR Supp_Wh_Types(C_Vendor_Id jl_zz_ap_supp_awt_types.vendor_id%TYPE) Is
   SELECT swt.supp_awt_type_id ,
          swt.awt_type_code,
	      swc.supp_awt_code_id,
		  swc.org_id,
          tca.tax_id,
	      tca.global_attribute7,	 -- Zone
	      awt.jurisdiction_type,
	      awt.province_code,
          awt.city_code
     FROM jl_zz_ap_supp_awt_types	swt,
          jl_zz_ap_sup_awt_cd		swc,
          ap_tax_codes			tca,
          jl_zz_ap_awt_types		awt
    WHERE swt.vendor_id  	  =  C_vendor_id  		-- Select only for this Supplier
      AND swt.wh_subject_flag 	  =  'Y'  			-- Supp subject to the withholding tax type
      AND swc.supp_awt_type_id 	  =  swt.supp_awt_type_id	-- Join
      AND swc.tax_id 		  =  tca.tax_id			-- Join
      AND (tca.inactive_date      >  sysdate                    -- Verify Tax Name Inactive Date
           OR tca.inactive_date   IS NULL)
      AND swc.primary_tax_flag	  =  'Y'  			-- Verify the Primary Withholding Tax
	  AND awt.Simplified_Regime_Flag = 'Y'          -- Verify the Simplified Regime Withholding tax Type ONLY
      AND awt.awt_type_code	  =  swt.awt_type_code 		-- Join
      AND sysdate between nvl(swc.effective_start_date,sysdate) and nvl(swc.effective_end_date,sysdate)
      ;								         -- New Argentine AWT ER 6624809

   v_provincial_code  jl_ar_ap_provinces.province_code%TYPE;
   v_hr_zone          hr_locations_all.region_1%TYPE;
   v_hr_province      hr_locations_all.region_2%TYPE;
   v_hr_city          hr_locations_all.town_or_city%TYPE;
   --pc_vendor_id       number;
   p_calling_sequence varchar2(2000):= 'Mono_trib_Supp_Wth';


BEGIN
    IF p_debug_log = 'Y' THEN
          FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" PROCEDURE : '|| p_vendor_id ||'-'|| p_invoice_id);
    END IF;


    ------------------------------------------------------------------------------------------
    -- Loop for each Supplier Withholding Type
    ------------------------------------------------------------------------------------------
	FOR  db_reg  IN Supp_Wh_Types(p_vendor_id) LOOP
            FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" PROCEDURE - Inside Loop db_reg');
            FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" AWT Code '||db_reg.awt_type_code);
        ---------------------------------------------------------------------------------
        -- The cursor verify the Supplier Withholding Applicability
        -- Each Supp Withholding Type in the Cursor needs to be check.
        -- Company Agent says if the company have to withhold by this Withholding Type.
        ---------------------------------------------------------------------------------
            IF   ( JL_ZZ_AP_AWT_DEFAULT_PKG.Company_Agent(db_reg.awt_type_code,p_Invoice_Id)) THEN
                FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" PROCEDURE - Company validation success');
                ----------------------------------------------------------------------------
                -- Validate the withholding type is according to distribution line.
                ----------------------------------------------------------------------------
                IF JL_ZZ_AP_AWT_DEFAULT_PKG.Validate_Line_Type(p_line_type, db_reg.tax_id) THEN
                    FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" PROCEDURE - LineType Validation Success');
                    -----------------------------------------------------------------------
                    -- Get the information from Zone, Province and City
                    -----------------------------------------------------------------------
                    JL_ZZ_AP_AWT_DEFAULT_PKG.Province_Zone_City
                                  (p_ship_to_loc	-- IN
                                  ,v_hr_zone 	-- OUT NOCOPY
                                  ,v_hr_province 	-- OUT NOCOPY
                                  ,v_hr_city );	-- OUT NOCOPY
                    -----------------------------------------------------------------------
                    -- Validate the Jurisdiction
                    -----------------------------------------------------------------------
                    FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" PROCEDURE - Jurisdiction Type '||db_reg.jurisdiction_type);
                    IF ( db_reg.jurisdiction_type = 'PROVINCIAL') THEN
                        --------------------------------------------------------------------
                        --  Verify if the Withholding Tax for the Province is TERRITORY
                        --------------------------------------------------------------------
                        IF JL_ZZ_AP_AWT_DEFAULT_PKG.Ver_Territorial_Flag (db_reg.province_code)  THEN
                            FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" PROCEDURE - WTax is TERRITORY');
                            -----------------------------------------------------------------
                            -- Validate if the Ship to Location from Inv Dis Line is in the province.
                            -----------------------------------------------------------------
                            IF db_reg.province_code = v_hr_province THEN
                                    FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" PROCEDURE - PROVINCIAL Before Insert');
 	       		            JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default
													(p_Invoice_Id
                            						  , p_inv_dist_id
													  , db_reg. supp_awt_code_id
													  , p_calling_sequence
													  , db_reg.org_id );

                            END IF;
                        ELSE -- v_territorial_flag = 'N' is Country Wide
                             FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" PROCEDURE - WTax is NOT TERRITORY');
                             FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" PROCEDURE - PROVINCIAL Before Insert');
		                     JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default
													(p_Invoice_Id
                            						  , p_inv_dist_id
													  , db_reg. supp_awt_code_id
													  , p_calling_sequence
													  , db_reg.org_id );

                        END IF; -- PROVINCE Class
                    ELSIF db_reg.jurisdiction_type = 'ZONAL' THEN
                        ---------------------------------------------------------------
                        -- The name of the zone is taken from AP_TAX_CODES Global Att 7
                        ---------------------------------------------------------------
                        IF db_reg.global_attribute7 = v_hr_zone     THEN
                                    FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" PROCEDURE - ZONAL Before Insert');
		                     JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default
													(p_Invoice_Id
                            						  , p_inv_dist_id
													  , db_reg. supp_awt_code_id
													  , p_calling_sequence
													  , db_reg.org_id );

                        END IF; --Tax_Zone

                    ELSIF db_reg.jurisdiction_type = 'MUNICIPAL' THEN
                        ---------------------------------------------------------------
                        -- Compare the Withholding Type City with the city in the line
                        ---------------------------------------------------------------
                        IF db_reg.city_code = v_hr_city THEN
                                    FND_FILE.put_line( FND_FILE.LOG, 'INSIDE "Monotrib_Wh_Def_Line" PROCEDURE - MUNICIPAL Before Insert');
		                     JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default
													(p_Invoice_Id
                            						  , p_inv_dist_id
													  , db_reg. supp_awt_code_id
													  , p_calling_sequence
													  , db_reg.org_id );

                        END IF;

                    ELSE -- db_reg.jurisdiction_type = 'FEDERAL'

		                     JL_ZZ_AP_AWT_DEFAULT_PKG.Insert_AWT_Default
													(p_Invoice_Id
                            						  , p_inv_dist_id
													  , db_reg. supp_awt_code_id
													  , p_calling_sequence
													  , db_reg.org_id );

                    END IF;--jurisdiction type
                END IF;--validate line_type
            END IF;--withholding applicability
    END LOOP; -- Loop for each Supplier Withholding Type
EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.put_line( FND_FILE.LOG,'AN ERROR IS ENCOUNTERED WHILE CHANGING INVOICE DISTRIBUTION FOR AWT 1 '|| SQLCODE || 'ERROR ' || SQLERRM);
        RAISE;
END Monotrib_Wh_Def_Line;

FUNCTION AfterReport
   RETURN BOOLEAN
IS
BEGIN
  DELETE from JL_ZZ_INFO_T;
  RETURN (TRUE);
END AfterReport;

END JL_ZZ_AP_MONOTRIB_AWT_PKG;


/
