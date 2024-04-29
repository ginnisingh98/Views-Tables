--------------------------------------------------------
--  DDL for Package Body CS_CONTRACT_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CONTRACT_BILLING" as
/* $Header: csctbilb.pls 115.8 99/07/16 08:48:52 porting ship  $ */

--  Global constant holding the package name
	G_PKG_NAME           CONSTANT VARCHAR2(30) := 'CS_CONTRACT_BILLING';

-- Global var holding the Current Error code for the error encountered
	Current_Error_Code   Varchar2(20) := NULL;

-- Global var holding the User Id
	user_id			NUMBER;

-- Global var to hold the ERROR value.
	ERROR			 NUMBER := 1;

-- Global var to hold the SUCCESS value.
	SUCCESS			 NUMBER := 0;

-- Global var to hold the commit size.
	COMMIT_SIZE		 NUMBER := 10;

-- Global var to hold the month unit of measure.
 	month_unit	      VARCHAR2(15);

-- Global var to hold the day unit of measure.
 	day_unit	      	 VARCHAR2(15);

-- Global var to hold the Concurrent Process return value
   conc_ret_code		 NUMBER := SUCCESS;

PROCEDURE Generate_Billing_Lines
		(
			ERRBUF     OUT VARCHAR2,
			RETCODE     OUT NUMBER,
			P_DEFAULT_DATE     IN DATE,
			P_WINDOW           IN NUMBER,
			P_CONTRACT_NUMBER  IN NUMBER

		)IS

     CONC_STATUS BOOLEAN;
	v_retcode	  NUMBER := SUCCESS;

 	input_date_range	DATE;
BEGIN


	-- Only for testing purpose --

	--FND_FILE.PUT_NAMES('bill.log','bill.out','/sqlcom/log');
    	--FND_GLOBAL.APPS_INITIALIZE (
	--				  1001,170,20638);

	-- Only for testing purpose --


	user_id    := FND_GLOBAL.USER_ID;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'User_Id ='||
						to_char(user_id));

     input_date_range := p_default_date + p_window;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Default Date ='||
						to_char(input_date_range));


	month_unit :=
 			FND_PROFILE.VALUE('MONTH_UNIT_OF_MEASURE');
	FND_FILE.PUT_LINE (FND_FILE.LOG,'MONTH UNIT = ' || month_unit);

	day_unit :=
 			FND_PROFILE.VALUE('DAY_UNIT_OF_MEASURE');
	FND_FILE.PUT_LINE (FND_FILE.LOG,'DAY UNIT = ' || day_unit);

	v_retcode 	  := get_billing_Lines(	input_date_range,
									p_contract_number);

     IF v_retcode = SUCCESS THEN

    			FND_FILE.PUT_LINE( FND_FILE.LOG,
				'get Billing lines successfully completed' );

	           v_retcode 	  := CS_AR_FEEDER_PROGRAM.Main_Procedure;
	END IF;



	FND_FILE.PUT_LINE (FND_FILE.LOG,'RETCODE = ' || to_char(v_retcode));

	COMMIT;

   	IF conc_ret_code = SUCCESS THEN
   	   CONC_STATUS :=
     	     FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',
			Current_Error_Code);
   	ELSE
   	   CONC_STATUS :=
     	     FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
   	END IF;

	--FND_FILE.CLOSE;

/*********************
	EXCEPTION
	WHEN UTL_FILE.INVALID_PATH THEN
		--DBMS_OUTPUT.PUT_LINE ('FILE LOCATION OR NAME WAS INVALID');

	WHEN UTL_FILE.INVALID_MODE THEN
		--DBMS_OUTPUT.PUT_LINE ('FILE OPEN MODE STRING WAS INVALID');

	WHEN UTL_FILE.INVALID_FILEHANDLE THEN
		--DBMS_OUTPUT.PUT_LINE ('FILE HANDLE WAS INVALID');

	WHEN UTL_FILE.INVALID_OPERATION THEN
		--DBMS_OUTPUT.PUT_LINE ('FILE IS NOT OPEN FOR WRITTING');

	WHEN UTL_FILE.WRITE_ERROR THEN
		--DBMS_OUTPUT.PUT_LINE ('OS ERROR OCCURRED DURING WRITE OPERATION');
	 NULL;

	 *****************/
END Generate_Billing_Lines;





FUNCTION Get_Billing_Lines
				(
					P_DATE_RANGE     	IN DATE,
					P_CONTRACT_NUMBER   IN NUMBER
 			     )
RETURN NUMBER IS

	CURSOR lines IS
		SELECT
			CON.CONTRACT_ID 			CONTRACT_ID,
			CON.CONTRACT_NUMBER			CONTRACT_NUMBER,
			SRV.CP_SERVICE_ID			CP_SERVICE_ID,
			SRV.EXTENDED_PRICE			EXTENDED_PRICE,
			SRV.DURATION_QUANTITY		DURATION,
			SRV.UNIT_OF_MEASURE_CODE		PERIOD,
			SRV.BILLING_FREQUENCY_PERIOD  BILLING_PERIOD,
			SRV.NEXT_BILL_DATE			NEXT_BILL_DATE,
			SRV.FIRST_BILL_DATE			FIRST_BILL_DATE,
			SRV.START_DATE_ACTIVE		START_DATE_ACTIVE,
			SRV.END_DATE_ACTIVE			END_DATE_ACTIVE,
			SRV.BILL_ON				BILL_ON,
			SRV.SERVICE_INVENTORY_ITEM_ID	INVENTORY_ITEM_ID
		FROM
			CS_CONTRACTS 				CON,
			CS_CP_SERVICES 			SRV,
			CS_CONTRACT_STATUSES 		STS
 		WHERE
			CON.CONTRACT_ID  = SRV.CONTRACT_ID AND
			CON.CONTRACT_NUMBER  =
				 NVL(p_contract_number,CON.CONTRACT_NUMBER) AND
			STS.ELIGIBLE_FOR_INVOICING = 'Y' AND
		     (
			 ( SRV.FIRST_BILL_DATE <= p_date_range AND
			   SRV.NEXT_BILL_DATE IS NULL
			  ) OR

		 	 (  SRV.NEXT_BILL_DATE <= p_date_range AND
			    SRV.NEXT_BILL_DATE <= SRV.END_DATE_ACTIVE
			  )
			 ) AND
			SRV.CONTRACT_LINE_STATUS_ID = STS.CONTRACT_STATUS_ID ;
		--FOR UPDATE OF CON.CONTRACT_ID NOWAIT;
/*
	CURSOR lines IS
		SELECT
			CON.CONTRACT_ID 			CONTRACT_ID,
			CON.CONTRACT_NUMBER			CONTRACT_NUMBER,
			SRV.CP_SERVICE_ID			CP_SERVICE_ID,
			SRV.EXTENDED_PRICE			EXTENDED_PRICE,
			SRV.DURATION_QUANTITY		DURATION,
			SRV.UNIT_OF_MEASURE_CODE		PERIOD,
			SRV.BILLING_FREQUENCY_PERIOD  BILLING_PERIOD,
			SRV.NEXT_BILL_DATE			NEXT_BILL_DATE,
			SRV.FIRST_BILL_DATE			FIRST_BILL_DATE,
			SRV.START_DATE_ACTIVE		START_DATE_ACTIVE,
			SRV.END_DATE_ACTIVE			END_DATE_ACTIVE,
			SRV.BILL_ON				BILL_ON,
			SRV.SERVICE_INVENTORY_ITEM_ID	INVENTORY_ITEM_ID,
			PROD.QUANTITY				QUANTITY
		FROM
			CS_CONTRACTS 				CON,
			CS_CP_SERVICES 			SRV,
			CS_CUSTOMER_PRODUCTS 		PROD,
			CS_CONTRACT_COVERAGE_LEVELS 	COVL,
			CS_COVERED_PRODUCTS   		COVP,
			CS_CONTRACT_STATUSES 		STS
 		WHERE
			CON.CONTRACT_ID  = SRV.CONTRACT_ID AND
			STS.ELIGIBLE_FOR_INVOICING = 'Y' AND
		     (
			 ( SRV.FIRST_BILL_DATE <= p_date_range AND
			   SRV.NEXT_BILL_DATE IS NULL
			  ) OR

		 	 (  SRV.NEXT_BILL_DATE <= p_date_range AND
			    SRV.NEXT_BILL_DATE <= SRV.END_DATE_ACTIVE
			  )
			 ) AND
			SRV.CONTRACT_LINE_STATUS_ID = STS.CONTRACT_STATUS_ID AND
			SRV.CP_SERVICE_ID   = COVL.CP_SERVICE_ID AND
			COVL.COVERAGE_LEVEL_ID = COVP.COVERAGE_LEVEL_ID AND
			PROD.CUSTOMER_PRODUCT_ID = COVP.CUSTOMER_PRODUCT_ID
		FOR UPDATE OF CON.CONTRACT_ID;
    */
     eligible_line      	  lines%ROWTYPE;


     invoiced_service_amount      	NUMBER;
     invoice_amount      		NUMBER;
     v_retcode      			NUMBER := SUCCESS;
     v_success      			NUMBER := SUCCESS;
     billed_until_date      	  	DATE;
     next_bill_date      	  	DATE;


BEGIN
     /* Process all fetched lines where the service amount is greater than */
     /* the total invoiced amount for the service.                         */

	FOR eligible_line IN lines
	LOOP
        BEGIN
		/*
		get the total invoiced amount and the maximun
          billed_until_date for a specific sevice line
          in a contract.If the Service line is billed for
		the first time then the invoiced_service_amount
		will be 0 and billed_until_date = NULL.

		*/

		FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Contract line : ');
		FND_FILE.PUT_LINE(FND_FILE.LOG,'CONTRACT NUMBER : '||
				to_char(eligible_line.contract_number) );
		FND_FILE.PUT_LINE(FND_FILE.LOG,'SERVICE ID : '||
				to_char(eligible_line.CP_service_id) );

		v_retcode := Get_Invoiced_Amount(
						invoiced_service_amount,
				    		billed_until_date,
				    		eligible_line.contract_id,
				    		eligible_line.cp_service_id);




		 IF (billed_until_date IS NULL ) THEN
			NULL;
		 ELSE
		 	billed_until_date := billed_until_date + 1;
		 END IF;

           IF v_retcode = SUCCESS THEN

    			FND_FILE.PUT_LINE( FND_FILE.LOG,
				'Invvoiced amount =' || to_char(invoiced_service_amount));
    			FND_FILE.PUT_LINE( FND_FILE.LOG,
				'Billed Until Date =' || to_char(billed_until_date));



          	/* Process the service line only if the service amount
             	is greater than the total invoiced amount for the service.
		   	This implies that the service line has to be further
             	invoiced
          	*/
			--IF (eligible_line.extended_price>invoiced_service_amount) THEN


			/* Process all lines which have :
			1. Value in the field First Bill Date
			2. Null value in the field Next Bill Date and
			3. Null value in Billed Until Date (which means the
			contract line is billed for the first time ) or
			4. all lines with a Not Null Next Bill Date and First_Bill_Date.
			i.e.All eligible contract line which are not fully invoiced. */

         		IF (
				 (
					(
					 eligible_line.next_bill_date IS NULL AND
					 eligible_line.first_bill_date IS NOT NULL AND
					 billed_until_date IS NULL
					 ) OR
					 (
					 eligible_line.next_bill_date IS NOT NULL  AND
					 eligible_line.first_bill_date IS NOT NULL
					 )
				 ) AND
				 eligible_line.extended_price > 0
			    ) THEN

		    		/* Calculate the remaining amount to be invoiced */

              		invoice_amount := eligible_line.extended_price
                               - invoiced_service_amount;

              		FND_FILE.PUT_LINE(FND_FILE.LOG,'Invoice_Amount='||
		   					  to_char(Invoice_Amount));

				Process_And_Insert_Records
				(
					Billed_Until_Date     ,
					eligible_line.Next_Bill_date 		,
					eligible_line.bill_on,
					eligible_line.First_Bill_date 	,
					eligible_line.Start_Date_active 	,
					eligible_line.End_Date_active 	,
					eligible_line.Contract_Id 	,
					eligible_line.CP_Service_Id 	,
					invoice_amount,
					eligible_line.Extended_Price 		,
					eligible_line.duration	,
					eligible_line.inventory_Item_Id 	,
					eligible_line.period 	,
					eligible_line.Billing_Period
				);
	        ELSE
			FND_FILE.PUT_LINE(FND_FILE.LOG,
			   'The contract line has been fully invoiced Or
			   the Contract line has bad data.');

			FND_FILE.PUT_LINE(FND_FILE.LOG,'CONTRACT NUMBER : '||
				to_char(eligible_line.contract_number) ||
				' SERVICE ID : ' || to_char(eligible_line.CP_Service_Id));

            END IF;			   /* After Total invoice check */
      END IF ; 			   /* Fetch Invoice Amount      */

	 EXCEPTION
 	 WHEN OTHERS THEN
		v_retcode := ERROR;
	     Current_error_Code := to_Char(SQLCODE);
       	FND_FILE.PUT_LINE( FND_FILE.LOG, 'Contract Line not Processed' );
       	FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
          return (v_retcode);
       END;
	END LOOP;

	COMMIT;
     --CLOSE lines;

	Current_error_Code := to_Char(SQLCODE);
     return (v_success);

	EXCEPTION
 	WHEN OTHERS THEN
		v_success := ERROR;
	     Current_error_Code := to_Char(SQLCODE);
       	FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in Cursor Processing' );
       	FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
          return (v_retcode);

END Get_Billing_Lines;




FUNCTION Get_Invoiced_Amount
		(
			P_INVOICED_SERVICE_AMOUNT  OUT NUMBER,
			P_BILLED_UNTIL_DATE     	OUT DATE,
			P_CONTRACT_ID     		IN NUMBER,
			P_CP_SERVICE_ID    		IN NUMBER
 		)
		RETURN NUMBER IS
     	v_retcode      			NUMBER := SUCCESS;
BEGIN

	/* Select the sum of the invoice ammount for the service line and the
	maximum billed_until_date from CS_CONTRACTS_BILLING     */

     --FND_FILE.PUT_LINE(FND_FILE.LOG,'CONTRACT_ID ='||
	--	   					  to_char(p_contract_id));
     --FND_FILE.PUT_LINE(FND_FILE.LOG,'CP_SERVICE_ID ='||
	--						  to_char(p_cp_service_id));

	SELECT SUM(TRX_PRE_TAX_AMOUNT), MAX(BILLED_UNTIL_DATE)
	INTO   p_invoiced_service_amount, p_billed_until_date
	FROM   CS_CONTRACTS_BILLING
	WHERE  CONTRACT_ID = p_contract_Id
	AND    CP_SERVICE_ID  = p_cp_service_id;

	/* When no record exist in CS_CONTRACTS_BILLING for the specific
	Contract_Id and cs_cp_service_id , the total invoiced amount is ZERO
	and the Billed_Until_Date is NULL	*/

	IF (p_invoiced_service_amount IS NULL ) THEN
		p_invoiced_service_amount := 0;
     END IF;

	Current_error_Code := to_Char(SQLCODE);
     v_retcode := SUCCESS;
	return (v_retcode);

	EXCEPTION
 	WHEN OTHERS THEN
		v_retcode := ERROR;
	     Current_error_Code := to_Char(SQLCODE);
       	FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error getting Invoice Amount ' );
       	FND_FILE.PUT_LINE( FND_FILE.LOG, SQLCODE );
       	FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
          return (v_retcode);

END Get_Invoiced_Amount;

PROCEDURE Process_And_Insert_Records
			    (
				P_BILLED_UNTIL_DATE     		IN OUT DATE,
				P_NEXT_BILL_DATE     		IN OUT DATE,
				P_BILL_ON 				IN OUT NUMBER,
				P_FIRST_BILL_DATE     		IN DATE,
				P_START_DATE_ACTIVE     		IN DATE,
				P_END_DATE_ACTIVE       		IN DATE,
				P_CONTRACT_ID	      		IN NUMBER,
				P_CP_SERVICE_ID     		IN NUMBER,
				P_INVOICE_AMOUNT      		IN NUMBER,
				P_EXTENDED_PRICE      		IN NUMBER,
				P_DURATION_QUANTITY    		IN NUMBER,
				P_SERVICE_INVENTORY_ITEM_ID 	IN NUMBER,
				P_UNIT_OF_MEASURE_CODE  		IN VARCHAR2,
				P_BILLING_FREQUENCY_PERIOD  	IN VARCHAR2
 			     ) IS
     v_retcode      			NUMBER ;
     billed_from_date      	  	DATE;
     transaction_date      	  	DATE;
     billing_amount      	  	NUMBER;
	commit_count     			NUMBER := 1;

BEGIN

	/* set the transaction date which should be passed to the
	interface table CS_CONT_BILL_IFACE */

	IF (p_next_bill_date is NULL ) then
		transaction_date := p_first_bill_date;
     ELSE
		transaction_date := p_Next_bill_date;
	END IF;

     FND_FILE.PUT_lINE(FND_FILE.LOG,'Transaction Date ='||
		   			  to_char(Transaction_Date));

   	v_retcode := Process_Billing_records
   			   (
				billing_Amount     ,
				Billed_From_Date   ,
				p_Billed_Until_Date     ,
				p_Next_Bill_date 		,
				p_bill_on,
				p_First_Bill_date 	,
				p_Start_Date_active 	,
				p_End_Date_active 	,
				p_invoice_amount,
				p_Extended_Price 		,
				p_duration_quantity	,
				p_Service_inventory_Item_Id 	,
				p_unit_of_measure_code 	,
				p_Billing_Frequency_Period
				);


      IF v_retcode = SUCCESS THEN

	    /* Insert a record in the interface table */
	    /*
         v_retcode := INSERT_CS_CONT_BILL_IFACE
		   			(
						billing_Amount     ,
						Billed_From_Date     ,
						p_Billed_Until_Date     ,
						Transaction_Date,
		    				eligible_line.contract_id,
		    				eligible_line.cp_service_id,
		    				eligible_line.quantity);
	 	*/

          v_retcode := INSERT_CS_CONT_BILL_IFACE
					   (
						billing_Amount     ,
						Billed_From_Date     ,
						p_Billed_Until_Date     ,
						Transaction_Date,
		    				p_contract_id,
		    				p_cp_service_id,
		    				NULL);

         	IF v_retcode = SUCCESS THEN

	    		/* update CS_CP_SERVICES set the transaction_availability_code*/
	    		/* To 'RESERVED' and update the column Next_bill_date with the*/
	    		/* new Next_Bill_date  */


              	v_retcode := UPDATE_CS_CP_SERVICES
				  		(
		    					p_contract_id,
		    					p_cp_service_id,
							p_Next_Bill_date
						);


         		IF v_retcode = SUCCESS THEN
	 			IF (commit_Count = COMMIT_SIZE) THEN
	   				COMMIT;
					commit_count := 1;
	 			ELSE
					commit_count := commit_count + 1;
	 			END IF;
	   		END IF; /* After Commit */
 	       END IF;    /* After Update */
     END IF; 	   /* After Insert */


	EXCEPTION
 	WHEN OTHERS THEN
	     Current_error_Code := to_Char(SQLCODE);
       	FND_FILE.PUT_LINE( FND_FILE.LOG,
					'Error in Process and Insert record' );
       	FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );

END Process_And_Insert_Records ;


FUNCTION Process_Billing_Records
			    (
				p_BILLING_AMOUNT     		OUT NUMBER,
				P_BILLED_FROM_DATE     		OUT DATE,
				P_BILLED_UNTIL_DATE     		IN OUT DATE,
				P_NEXT_BILL_DATE     		IN OUT DATE,
				P_BILL_ON 				IN OUT NUMBER,
				P_FIRST_BILL_DATE     		IN DATE,
				P_START_DATE_ACTIVE     		IN DATE,
				P_END_DATE_ACTIVE       		IN DATE,
				P_INVOICE_AMOUNT      		IN NUMBER,
				P_EXTENDED_PRICE      		IN NUMBER,
				P_DURATION_QUANTITY    		IN NUMBER,
				P_SERVICE_INVENTORY_ITEM_ID 	IN NUMBER,
				P_UNIT_OF_MEASURE_CODE  		IN VARCHAR2,
				P_BILLING_FREQUENCY_PERIOD  	IN VARCHAR2
 			     )
		    	RETURN NUMBER IS
     v_retcode      NUMBER ;
BEGIN
         IF ( P_Next_Bill_Date IS NULL ) THEN
               /* Record has been picked up by the billing program */
               /* for the first time. */

	    		v_retcode := Process_First_Bill_date
				(
				P_BILLING_AMOUNT     	,
				P_BILLED_FROM_DATE     ,
				P_BILLED_UNTIL_DATE     ,
				P_NEXT_BILL_DATE     	,
				P_BILL_ON,
				P_FIRST_BILL_DATE     	,
				P_START_DATE_ACTIVE     ,
				P_END_DATE_ACTIVE       ,
				P_EXTENDED_PRICE      	,
				P_DURATION_QUANTITY    	,
				P_SERVICE_INVENTORY_ITEM_ID ,
				P_UNIT_OF_MEASURE_CODE  ,
				P_BILLING_FREQUENCY_PERIOD
				);

	    		FND_FILE.PUT_LINE(FND_FILE.LOG,'AFTER PROCESS FIRST BILL DATE ');
         ELSE
	   		v_retcode := Process_Next_Bill_date
			(
				P_BILLING_AMOUNT     	   ,
				P_BILLED_FROM_DATE          ,
				P_BILLED_UNTIL_DATE         ,
				P_NEXT_BILL_DATE     	   ,
				P_BILL_ON                   ,
				P_FIRST_BILL_DATE     	   ,
				P_START_DATE_ACTIVE         ,
				P_END_DATE_ACTIVE           ,
				P_INVOICE_AMOUNT      	   ,
				P_EXTENDED_PRICE      	   ,
				P_DURATION_QUANTITY         ,
				P_SERVICE_INVENTORY_ITEM_ID ,
				P_UNIT_OF_MEASURE_CODE  ,
				P_BILLING_FREQUENCY_PERIOD
			);
	    		FND_FILE.PUT_LINE(FND_FILE.LOG,'AFTER PROCESS NEXT BILL DATE');
	    END IF;

	    return(v_retcode);

		EXCEPTION
 		WHEN OTHERS THEN
			v_retcode := ERROR;
	     	Current_error_Code := to_Char(SQLCODE);
       		FND_FILE.PUT_LINE( FND_FILE.LOG,
					'Error in Process Billing record' );
       		FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
          	return (v_retcode);

END Process_Billing_Records;

FUNCTION Process_First_Bill_Date
			    (
				P_BILLING_AMOUNT     		OUT NUMBER,
				P_BILLED_FROM_DATE     		OUT DATE,
				P_BILLED_UNTIL_DATE     		IN OUT DATE,
				P_NEXT_BILL_DATE     		IN OUT DATE,
				P_BILL_ON 				IN OUT NUMBER,
				P_FIRST_BILL_DATE     		IN DATE,
				P_START_DATE_ACTIVE     		IN DATE,
				P_END_DATE_ACTIVE       		IN DATE,
				P_EXTENDED_PRICE      		IN NUMBER,
				P_DURATION_QUANTITY    		IN NUMBER,
				P_SERVICE_INVENTORY_ITEM_ID 	IN NUMBER,
				P_UNIT_OF_MEASURE_CODE  		IN VARCHAR2,
				P_BILLING_FREQUENCY_PERIOD	IN VARCHAR2
 			     )
		    	RETURN NUMBER IS

     v_retcode      NUMBER := SUCCESS;

BEGIN

       FND_FILE.PUT_LINE(FND_FILE.LOG,'FBD =' || to_char(p_first_bill_date));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'SDA =' || to_char(p_start_date_active));
    IF (P_First_Bill_Date >= P_End_Date_Active ) THEN

	    /* Bill for the entire amount */

         P_Billing_Amount := P_extended_price;
         --P_Next_Bill_date := P_end_date_active;
         P_Next_Bill_date := Null;
         P_Billed_From_Date := P_Start_date_active;
         P_Billed_until_Date := P_end_date_active;

    ELSIF (P_First_Bill_Date = p_Start_Date_Active) THEN


       /* Bill in advance for the billing period between   */
       /* Service start Date and Next Bill Date.           */
       /* Next Bill Date is calculated based on the billing */
       /* frequency and bill on */

	  --FND_FILE.Put_Line(FND_FILE.LOG,'PROCESS FIRST BILL IN ADVANCE');
       p_next_bill_date :=CS_CONTRACT_BILLING.Calculate_next_bill_date(
					p_start_Date_active,
					p_End_Date_active,
					p_bill_on,
					p_Service_inventory_item_id,
					p_billing_frequency_period );

       FND_FILE.PUT_LINE(FND_FILE.LOG,
			' Next Bill Date =' || to_char(p_next_bill_date));

       IF (p_next_bill_date IS NULL ) THEN
                v_retcode := ERROR;
       ELSE
	 /*
       FND_FILE.PUT_LINE(FND_FILE.LOG,'STDA =' || to_char(p_start_date_active));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'NBD  =' || to_char(p_next_bill_date));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'AMNT  =' || to_char(p_extended_price));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'DURN =' || to_char(p_duration_quantity));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'ITEM  =' ||
							to_char(p_service_inventory_item_id));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'PERD  =' || (p_unit_of_measure_code));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'BILL =' || (p_billing_frequency_period));
	 */
	        P_Billing_amount := Calculate_Txn_Amount (
						'Y',
						p_Start_Date_Active,
						p_next_Bill_Date,
						p_extended_price,
						p_duration_quantity,
						p_service_inventory_item_id,
						p_Unit_of_Measure_code,
						p_billing_frequency_period);

      	   IF (P_Billing_Amount > 0) THEN
                     p_billed_From_date := P_Start_Date_Active;
                     p_billed_until_date := P_Next_Bill_Date -1;
             ELSE
                	v_retcode := ERROR;
             END IF;
        	   FND_FILE.PUT_LINE(FND_FILE.LOG,
			'BILLING AMOUNT =' || to_char(p_billing_amount));

    		   IF (P_Next_Bill_Date >= P_End_Date_Active ) THEN
         			P_Next_Bill_date := Null;
		   END IF;
        END IF;
    ELSE

             /* Bill in arrears for the billing period between   */
             /* Start Date Active and First Bill Date.            */
	/*
       FND_FILE.PUT_LINE(FND_FILE.LOG,'STDA =' || to_char(p_start_date_active));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'FBD  =' || to_char(p_FIRST_bill_date));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'AMNT =' || to_char(p_extended_price));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'DURN =' || to_char(p_duration_quantity));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'ITEM =' ||
							to_char(p_service_inventory_item_id));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'PERD =' || (p_unit_of_measure_code));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'FREQ =' || (p_billing_frequency_period));
	 */

	     P_Billing_amount := Calculate_Txn_Amount (
						'Y',
						p_Start_Date_Active,
						P_First_Bill_Date,
						p_extended_price,
						p_duration_quantity,
						p_service_inventory_item_id,
						p_Unit_of_Measure_code,
						p_billing_frequency_period);

      	IF (P_Billing_Amount > 0) THEN
    		   IF (P_Next_Bill_Date = P_End_Date_Active ) THEN
         			P_Next_Bill_date := Null;
		   ELSE
            	p_Next_Bill_Date :=Calculate_next_bill_date(
					--p_start_Date_active,
					p_first_bill_date,
					p_End_Date_active,
					p_bill_on,
					p_Service_inventory_item_id,
					p_billing_frequency_period );
                p_billed_From_date := P_Start_Date_Active;
                p_billed_until_date := P_First_Bill_Date - 1;
		   END IF;
	     ELSE
                	v_retcode := ERROR;
	     END IF;
     END IF;

     return (v_retcode);

	EXCEPTION
 		WHEN OTHERS THEN
			v_retcode := ERROR;
	     	Current_error_Code := to_Char(SQLCODE);
       		FND_FILE.PUT_LINE( FND_FILE.LOG,
					'Error in Process First_Bill Date' );
       		FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
          	return (v_retcode);

END Process_First_Bill_date;




FUNCTION Process_Next_Bill_Date
			    (
				P_BILLING_AMOUNT     		OUT NUMBER,
				P_BILLED_FROM_DATE     		OUT DATE,
				P_BILLED_UNTIL_DATE     		IN OUT DATE,
				P_NEXT_BILL_DATE     		IN OUT DATE,
				P_BILL_ON 				IN OUT NUMBER,
				P_FIRST_BILL_DATE     		IN DATE,
				P_START_DATE_ACTIVE     		IN DATE,
				P_END_DATE_ACTIVE       		IN DATE,
				P_INVOICE_AMOUNT      		IN NUMBER,
				P_EXTENDED_PRICE      		IN NUMBER,
				P_DURATION_QUANTITY    		IN NUMBER,
				P_SERVICE_INVENTORY_ITEM_ID 	IN NUMBER,
				P_UNIT_OF_MEASURE_CODE  		IN VARCHAR2,
				P_BILLING_FREQUENCY_PERIOD  	IN VARCHAR2
 			     )
		    	RETURN NUMBER IS
     v_retcode      NUMBER := SUCCESS;

BEGIN

    IF (P_Next_Bill_Date = p_End_Date_Active) THEN
	    /* Bill for the remaining amount */

         P_Billing_Amount := P_invoice_amount;
         P_Next_Bill_date := NULL;
         --P_Next_Bill_date := P_end_date_active;
         P_Billed_From_Date := P_Billed_Until_Date;
         P_Billed_until_Date := P_end_date_active;

    ELSIF (P_Next_Bill_Date = p_Billed_Until_date) THEN
         /* Bill in advance for the billing period between   */
         /* Billed until date and the newly calculated       */
	    /* Next Bill Date.            */

          p_next_bill_date :=CS_CONTRACT_BILLING.Calculate_next_bill_date(
					p_billed_Until_date  ,
					p_End_Date_active,
					p_bill_on,
					p_Service_inventory_item_id,
					p_billing_frequency_period );


          IF (p_next_bill_date IS NULL ) THEN
                v_retcode := ERROR;
          ELSE

    		   IF (P_Next_Bill_Date = p_End_Date_Active) THEN
	        /* Bill for the remaining amount */
         	   		P_Billed_From_Date := P_Billed_Until_Date;
         	   		P_Billed_until_Date := P_End_Date_Active;

         			P_Billing_Amount := P_invoice_amount;
         			P_Next_Bill_date := NULL;
         			--P_Next_Bill_date := P_end_date_active;

		   ELSE
         	   		P_Billed_From_Date := P_Billed_Until_Date;
         	   		P_Billed_until_Date := P_Next_bill_Date - 1;
	        		P_Billing_amount := Calculate_Txn_Amount (
						'Y',
						p_billed_from_date,
						p_next_Bill_Date,
						p_extended_price,
						p_duration_quantity,
						p_service_inventory_item_id,
						p_Unit_of_Measure_code,
						p_billing_frequency_period);
		   END IF;

      	   IF (P_Billing_Amount > 0) THEN
				NULL;
             ELSE
                	v_retcode := ERROR;
             END IF;
        END IF;

    ELSE
         /* Bill in arrears for the billing period between   */
         /* Billed until date and Next Bill Date.            */

	 	P_Billing_amount := Calculate_Txn_Amount (
						'Y',
						p_Billed_Until_Date,
						p_Next_Bill_Date,
						p_extended_price,
						p_duration_quantity,
						p_service_inventory_item_id,
						p_Unit_of_Measure_code,
						p_billing_frequency_period);
             		FND_FILE.PUT_LINE(FND_FILE.LOG,
				'BILLING AMOUNT='||to_char(p_billing_amount));

          IF (P_Billing_Amount > 0) THEN
         			P_Billed_From_Date := P_Billed_Until_Date;
         			P_Billed_until_Date := P_Next_Bill_Date - 1;

    		   		IF (P_Next_Bill_Date = P_End_Date_Active ) THEN
         				P_Next_Bill_date := Null;
		   		ELSE
            			p_Next_Bill_Date :=Calculate_next_bill_date(
					p_Billed_Until_Date + 1,
					p_End_Date_active,
					p_bill_on,
					p_Service_inventory_item_id,
					p_billing_frequency_period );
				END IF;
             		FND_FILE.PUT_LINE(FND_FILE.LOG,
				'NBD ='||to_char(p_next_bill_date));

             		FND_FILE.PUT_LINE(FND_FILE.LOG,
						'BILLED FROM='|| to_char(p_billed_from_date));
             		FND_FILE.PUT_LINE(FND_FILE.LOG,
						'BILLED TILL='||to_char(p_billed_until_date));
	    	ELSE
     			v_retcode       := ERROR;
	    	END IF;
     END IF;

     return (v_retcode);
	EXCEPTION
 		WHEN OTHERS THEN
			v_retcode := ERROR;
	     	Current_error_Code := to_Char(SQLCODE);
       		FND_FILE.PUT_LINE( FND_FILE.LOG,
					'Error in Process Next Date' );
       		FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
          	return (v_retcode);

END Process_Next_Bill_date;

FUNCTION Insert_cs_cont_bill_iface
			(
				P_BILLING_AMOUNT     	IN NUMBER,
				P_billed_from_date     	IN DATE,
				P_billed_until_date     	IN DATE,
				P_transaction_date     	IN DATE,
				P1_CONTRACT_ID     		IN NUMBER,
				P1_CP_SERVICE_ID    		IN NUMBER,
				P_quantity    		IN NUMBER
			)RETURN NUMBER IS
txn_id NUMBER;
v_return_status  VARCHAR2(1);
v_msg_count      NUMBER;
v_msg_data       VARCHAR2(2000);

v_retcode       	NUMBER := SUCCESS;
contracts_interface_id NUMBER;
object_version_number  NUMBER;

BEGIN
     DBMS_TRANSACTION.SAVEPOINT('Insert_Interface');


     SELECT MAX(CP_SERVICE_TRANSACTION_ID)
	INTO   txn_id
	FROM   CS_CP_SERVICE_TRANSACTIONS
	WHERE  CP_SERVICE_ID = p1_cp_service_id
	AND    TRANSACTION_TYPE_CODE  NOT IN ('TERMINATE');

     FND_FILE.PUT_LINE( FND_FILE.LOG, 'p1_cp_service_id ' || p1_cp_service_id);
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'txn_id ' || txn_id);
     CS_CONTINTF_PVT.Insert_Row
	(
	  p_api_version		=> 1.0,
	  p_init_msg_list		=> 'T',
	  p_validation_level	=> 100,
	  p_commit			=> 'F',
	  x_return_status        => v_return_status,
	  x_msg_count		     => v_msg_count,
	  x_msg_data			=> v_msg_data,
	  p_cp_service_transaction_id 	=> txn_id,
	  p_cp_service_id 				=> p1_cp_service_id,
	  p_contract_id 				=> p1_contract_id,
	  p_ar_trx_type 				=> 'INV',
	  p_trx_start_date 				=> p_billed_from_date,
	  p_trx_end_date 				=> p_billed_until_date,
	  p_trx_date 					=> p_transaction_date,
	  p_trx_amount 				=> round(p_billing_amount,2),
	  p_reason_code	 			=> 'CONTRACTS',
	  p_reason_comments	 			=> NULL,
	  p_cp_quantity	 			=> NULL,
	  p_concurrent_process_id 		=> NULL,
	  p_created_by 				=> user_id,
	  p_creation_date 				=> sysdate,
	  x_contracts_interface_id 		=> contracts_interface_id,
	  x_object_version_number 		=> object_version_number);

     FND_FILE.PUT_LINE( FND_FILE.LOG, 'v_return_status ' ||
		    v_return_status);
	  IF (v_return_status <> 'S' and v_msg_count >= 1) THEN
		v_retcode := ERROR;
	     Current_error_Code := to_Char(SQLCODE);
       	FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error Inserting in Interface tbl' );
       	FND_FILE.PUT_LINE( FND_FILE.LOG, SQLCODE );
       	FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
          return (v_retcode);
	  ELSE
		v_retcode := SUCCESS;
	     Current_error_Code := to_Char(SQLCODE);
       	FND_FILE.PUT_LINE( FND_FILE.LOG, 'records Inserted in Interface tbl');
		return(v_retcode);
	  END IF;

	  EXCEPTION
 		WHEN OTHERS THEN
			v_retcode := ERROR;
	     	Current_error_Code := to_Char(SQLCODE);
       		FND_FILE.PUT_LINE( FND_FILE.LOG,
					'Error in Insert_CS_cont_bill_iface ' );
			v_msg_data := FND_MESSAGE.Get;
       		FND_FILE.PUT_LINE( FND_FILE.LOG, 'Err in UPdate CS_CP_SERVICES :'
			|| 	 v_msg_data);
       		FND_FILE.PUT_LINE( FND_FILE.LOG, SQLCODE );
          	return (v_retcode);

END;


FUNCTION Update_CS_CP_Services
			(
				P_CONTRACT_ID     		IN NUMBER,
				P_CP_SERVICE_ID    		IN NUMBER,
				P_Next_Bill_Date     	IN DATE
			) RETURN NUMBER IS

    v_retcode NUMBER := SUCCESS;
    dummy VARCHAR2(02) ;
BEGIN
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'CS_CP_SERVICES  Before' );


	-- This select is required only to lock the record.
     SELECT 'X'
	INTO  dummy
	FROM   CS_CP_SERVICES
	WHERE  contract_id = p_contract_id AND
		  cp_service_id = p_cp_service_id
	FOR UPDATE OF cp_service_id;


	UPDATE CS_CP_SERVICES
--	SET SERVICE_TXN_AVAILABILITY_CODE = 'RESERVED' ,
 	SET NEXT_BILL_DATE = p_Next_Bill_Date
     WHERE CONTRACT_ID = p_Contract_Id AND
		 CP_SERVICE_ID = p_cp_service_id;

	Current_Error_Code := to_char(SQLCODE);
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'CS_CP_SERVICES  Updated' );
     return (v_retcode);

	EXCEPTION
	 WHEN others THEN
	    IF (SQLCODE = -54) THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,
			   'The record has been locked: Contract_id : '
				 || p_contract_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,
			   ' CP_SERVICE_id : '
				 || p_cp_service_id);
		ELSE
		    RAISE;
		END IF;
		v_retcode := ERROR;
		DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('Insert_Interface');
     	FND_FILE.PUT_LINE( FND_FILE.LOG, 'Transaction Rollbacked ' );
          return (v_retcode);
END;




FUNCTION Calculate_Next_Bill_Date
				(
                   		P_LAST_TXN_DATE       IN  DATE,
                   		P_END_DATE_ACTIVE     IN  DATE,
                 	   	P_BILL_ON        	  IN OUT NUMBER,
                   		P_INVENTORY_ITEM_ID   IN  NUMBER,
                   		P_FROM_UNIT           IN  VARCHAR2
		    		)RETURN DATE IS

	temp_to_unit VARCHAR2(15);
	temp_from_unit VARCHAR2(15);

	Day_Of_week VARCHAR2(15);
	next_bill_date DATE;
	Converted_Duration NUMBER;
BEGIN

	month_unit :=
 			FND_PROFILE.VALUE('MONTH_UNIT_OF_MEASURE');
	temp_to_unit :=
	   	FND_PROFILE.VALUE('DAY_UNIT_OF_MEASURE');

	FND_FILE.PUT_LINE( FND_FILE.LOG,'p_From_unit = ' ||
						    (p_From_Unit));


	IF (p_from_unit  = month_unit) THEN
		Next_Bill_date := ADD_MONTHS(p_last_txn_Date , 1);
	ELSE

		Converted_Duration := Convert_Duration(
						'Y',
						1,
						p_inventory_item_id,
						p_from_unit,
						temp_to_unit);


      	IF (Converted_Duration > 0 )THEN
	  		Next_Bill_Date := p_Last_Txn_Date + Converted_Duration;
      	ELSE
			Next_Bill_Date := NULL ;
		END IF;
	END IF;

     IF (Next_Bill_Date is not null) THEN
	  Calc_Actual_Next_Bill_Date(
					Next_Bill_Date   ,
					P_Bill_On
					);

	 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Next Bill Date22 = ' ||
						    to_char(Next_Bill_Date));
	 FND_FILE.PUT_LINE(FND_FILE.LOG, 'end_date_Active22 = ' ||
						    to_char(p_end_date_active));

	  IF (Next_Bill_Date > p_end_date_active) THEN
		 Next_Bill_date := p_end_date_active;
	 	 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Actual Next Bill Date22 = ' ||
						    to_char(Next_Bill_Date));
       END IF;
	END IF;

	 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Actual Next Bill Date = ' ||
						    to_char(Next_Bill_Date));
      RETURN(Next_Bill_Date);

	 EXCEPTION
 	 WHEN OTHERS THEN
	     Current_error_Code := to_Char(SQLCODE);
		Next_Bill_Date := NULL;
       	FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in Next Bill Date' );
       	FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
      	RETURN(Next_Bill_Date);
END Calculate_Next_Bill_date;




PROCEDURE Calc_Actual_Next_Bill_date(
                             P_NEXT_BILL_DATE   IN OUT  DATE,
                             P_BILL_ON   IN OUT NUMBER
								)IS
  Next_Day     NUMBER;
  Next_month   NUMBER;
  Next_year    NUMBER;
  temp_date    varchar2(20);

  BEGIN
    Next_Day   := TO_NUMBER(TO_CHAR(P_Next_Bill_Date, 'DD'));
    Next_Month := TO_NUMBER(TO_CHAR(P_Next_Bill_Date, 'MM'));
    Next_Year   := TO_NUMBER(TO_CHAR(P_Next_Bill_Date,'YYYY'));


    FND_FILE.PUT_LINE(FND_FILE.LOG, 'BILL ON  = ' ||
						    to_char(P_bill_On));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'NEXT DAY   = ' ||
						    to_char(Next_day));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'NEXT MONTH   = ' ||
						    to_char(Next_Month));
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'NEXT YEAR   = ' ||
						    to_char(Next_Year));

    IF ((p_bill_on IS NULL )OR (p_bill_on = 0)) THEN
		NULL ;
    ELSIF (p_bill_on = 31) THEN
		Next_Month := Next_Month + 1;
		IF (Next_Month = 11 ) THEN
			Next_Month := 01;
			Next_Year  := Next_Year + 1;
        	END IF;
		temp_date := '01' ||'-' || Next_Month ||'-' || Next_year;
		P_Next_Bill_Date := TO_DATE( temp_date, 'DD-MM-YYYY') - 1;
    ELSIF (Next_Day <=  p_bill_on) THEN

		IF (p_bill_on = 29 and Next_Month = 02 ) THEN
	    		p_bill_on := 01;
	    		Next_Month := 03;
        	END IF;

		temp_date := p_bill_on ||'-' || Next_Month ||'-' || Next_year;

		P_Next_Bill_Date := TO_DATE( temp_date, 'DD-MM-YYYY');
    ELSE
		IF (p_bill_on = 29 and Next_Month = 01 ) THEN
			p_bill_on := 01;
			Next_Month := 02;
		ELSIF (Next_Month = 12 ) THEN
			Next_Month := 01;
			Next_Year  := Next_Year + 1;
        	END IF;
		temp_date := p_bill_on ||'-' || (Next_Month + 1) ||'-' || Next_year;
		P_Next_Bill_Date := TO_DATE( temp_date, 'DD-MM-YYYY');
    END IF;
/*
   FND_FILE.PUT_LINE( FND_FILE.LOG,
			 'Next Bill Date IS = ' || to_char(P_Next_Bill_Date));
    FND_FILE.PUT_LINE( FND_FILE.LOG,' ');
*/

    	FND_FILE.PUT_LINE(FND_FILE.LOG, 'NEXT BILL_DATE   = ' ||
						    to_char(p_Next_Bill_Date));
	 EXCEPTION
 	 WHEN OTHERS THEN
	     Current_error_Code := to_Char(SQLCODE);
		p_Next_Bill_Date := NULL;
       	FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in Actual Next Bill Date' );
       	FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
END Calc_Actual_Next_Bill_date;







/* This procedure is only used by the Terminate Contract form */
/* to calculate the adjusted service amount, when a service   */
/* line is terminated on a date which is in a billing period  `*/
/* which  has not been invoiced .*/

FUNCTION Get_Final_Adjustment  (
                             P_CONC_PROGRAM        IN  VARCHAR2,
                             P_TXN_START_DATE      IN  DATE,
                             P_TXN_END_DATE        IN  DATE,
                             P_SERVICE_AMOUNT      IN  NUMBER,
                             P_SERVICE_DURATION    IN  NUMBER,
                             P_INVENTORY_ITEM_ID   IN  NUMBER,
                             P_SERVICE_PERIOD      IN  VARCHAR2,
                             P_BILL_FREQUENCY      IN  VARCHAR2
                               )RETURN NUMBER IS
	Average_Amount NUMBER;
	Transaction_Amount NUMBER;
	Adjusted_Amount NUMBER;
BEGIN
	/* The procedure Calculate_Txn_Amount is used to calculate */
	/* the invoice amount for a specific period*/
	Transaction_amount := Calculate_Txn_Amount (
							p_conc_program,
							p_txn_start_date,
							p_txn_end_date,
							p_Service_Amount,
							p_service_duration,
							p_inventory_item_id,
							p_service_period,
							p_bill_frequency);

      	IF (Transaction_Amount > 0) THEN
		/* The Final adjusted amount is the diference between    */
		/* the total service amount and the transaction amount   */

		Adjusted_Amount := p_service_amount - Transaction_Amount;
	ELSE
		Adjusted_Amount := -99;
	END IF;

	RETURN(Adjusted_Amount);

	 EXCEPTION
 	 WHEN OTHERS THEN
	     Current_error_Code := to_Char(SQLCODE);
       	FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in Get Final Adjust' );
       	FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
		RETURN(Adjusted_Amount);

END Get_Final_Adjustment;

FUNCTION Calculate_Txn_Amount  (
                             P_CONC_PROGRAM        IN  VARCHAR2,
                             P_TXN_START_DATE      IN  DATE,
                             P_TXN_END_DATE        IN  DATE,
                             P_SERVICE_AMOUNT      IN  NUMBER,
                             P_SERVICE_DURATION    IN  NUMBER,
                             P_INVENTORY_ITEM_ID   IN  NUMBER,
                             P_SERVICE_PERIOD      IN  VARCHAR2,
                             P_BILL_FREQUENCY      IN  VARCHAR2
                               )RETURN NUMBER IS
	Average_Amount NUMBER;
	v_retcode NUMBER := SUCCESS;
	Transaction_Amount NUMBER;
	Txn_Duration_Days  NUMBER;
	Converted_Duration NUMBER;
	temp_end_date DATE;
	p_temp_from_unit VARCHAR2(5);
	day_unit varchar2(5);
BEGIN
/*

     FND_FILE.PUT_LINE(FND_FILE.LOG,
			'Service Amount =' || to_char(p_service_amount));
     FND_FILE.PUT_LINE(FND_FILE.LOG,
			'Service Duration=' || to_char(p_service_duration));
     FND_FILE.PUT_LINE(FND_FILE.LOG,
			'inventory_Item_Id =' || to_char(p_inventory_item_id));
     FND_FILE.PUT_LINE(FND_FILE.LOG,
			'Service Period=' || p_service_period);
     FND_FILE.PUT_LINE(FND_FILE.LOG,
			'p_bill_frequency =' || p_bill_frequency);

			*/
	Average_amount := Calculate_Average_Amount (
							p_conc_program,
							p_Service_Amount,
							p_service_duration,
							p_inventory_item_id,
							p_service_period,
							p_bill_frequency);


    IF (Average_Amount > 0) THEN

          	IF (p_txn_start_date >= p_txn_end_date ) THEN
	    			Transaction_Amount := -99 ;
				v_retcode := 1;
          	ELSE
	    			p_temp_from_unit :=
	   			FND_PROFILE.VALUE('DAY_UNIT_OF_MEASURE');
			month_unit :=
 			FND_PROFILE.VALUE('MONTH_UNIT_OF_MEASURE');

        			Txn_Duration_Days := p_txn_end_date - p_txn_start_date;
		          --Converted_Duration := Txn_Duration_Days + 1;

				/******** 11/16/98 (average amount per day) ***/

				temp_end_date := p_txn_end_date + 1;
				/*
				DBMS_OUTPUT.PUT_LINE('TEMP_END_DATE :' ||
							to_char(temp_end_date));
				DBMS_OUTPUT.PUT_LINE('TXN_START_DATE :' ||
							to_char(p_txn_start_date));
				DBMS_OUTPUT.PUT_LINE('MONTH_UNIT :' || (month_unit));
				*/

				IF (p_bill_frequency = month_unit) THEN
					Converted_duration :=
					    MONTHS_BETWEEN(temp_end_date ,p_txn_start_date);
			     ELSE
	        			Converted_Duration := Convert_Duration(
						p_conc_program,
						Txn_duration_Days,
						p_inventory_item_id,
						p_temp_from_unit,
						p_bill_frequency);

				END IF;
				/******* 11/16/98     *********/

    				--DBMS_OUTPUT.PUT_LINE(
				--	'Converted DurationIN='|| to_char(Converted_Duration));

               	IF (Converted_Duration > 0 )THEN
	    	   			Transaction_Amount := Average_amount *
									  Converted_Duration;
					v_retcode := 0;
                    ELSE
	    	   			Transaction_Amount := -99 ;
					v_retcode := 2;
                    END IF;
                END IF;
     ELSE
 			Transaction_Amount := -99 ;
			v_retcode := 3;
    	END IF;



      IF p_conc_program = 'Y'THEN
        if v_retcode = 0 THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,
					 'Transaction Amount calculated ');
          FND_FILE.PUT_LINE( FND_FILE.LOG,' ');
        elsif v_retcode = 1 THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,
			 'Txn End Date must be greater than tx start date ');
          FND_FILE.PUT_LINE( FND_FILE.LOG,' ');
        elsif v_retcode = 2 THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,
					 'Negative converted duration  ');
          FND_FILE.PUT_LINE( FND_FILE.LOG,' ');
        elsif v_retcode = 3 THEN
          FND_FILE.PUT_LINE( FND_FILE.LOG,
					 'Negative average amount  ');
          FND_FILE.PUT_LINE( FND_FILE.LOG,' ');
        End if;
     END IF;

      RETURN (Transaction_Amount);



	 EXCEPTION
 	 WHEN OTHERS THEN
	     Current_error_Code := to_Char(SQLCODE);
          IF p_conc_program = 'Y'THEN
       		FND_FILE.PUT_LINE( FND_FILE.LOG,
					'Error in Calculate Transaction Amount' );
       		FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
		END IF;
      	RETURN (Transaction_Amount);


END Calculate_Txn_Amount;



FUNCTION Calculate_Average_Amount(
                             P_CONC_PROGRAM        IN  VARCHAR2,
                             P_SERVICE_AMOUNT      IN  NUMBER,
                             P_SERVICE_DURATION    IN  NUMBER,
                             P_INVENTORY_ITEM_ID   IN  NUMBER,
                             P_FROM_UNIT           IN  VARCHAR2,
                             P_TO_UNIT             IN  VARCHAR2
                               )
	    RETURN Number	 IS
	   	Average_Amount  	Number;
	   	Converted_Duration  	Number;
	   	day_unit  	Varchar2(05);
BEGIN
    /*** Calculate the average amount per day ***/
    /*
	 day_unit :=
 			FND_PROFILE.VALUE('DAY_UNIT_OF_MEASURE');
	 Converted_Duration := Convert_Duration(
						p_Conc_program,
						p_service_duration,
						p_inventory_item_id,
						p_from_unit,
						day_unit);

     IF (Converted_Duration > 0 )THEN
	   		Average_Amount := p_service_amount/ Converted_Duration;
     ELSE
			Average_amount := -99;
     END IF;



	*/

      IF (p_from_unit = p_to_unit) THEN
		Average_Amount := p_service_amount / p_service_duration;
      ELSE
	 	Converted_Duration := Convert_Duration(
						p_Conc_program,
						p_service_duration,
						p_inventory_item_id,
						p_from_unit,
						p_to_unit);


      	IF (Converted_Duration > 0 )THEN
	   		Average_Amount := p_service_amount/ Converted_Duration;
      	ELSE
			Average_amount := -99;
      	END IF;
      END IF;



	 --DBMS_OUTPUT.PUT_LINE('AVERAGE_AMOUNT : ' || to_char(average_amount));
	 IF (P_Conc_Program = 'Y')THEN
         	 	FND_FILE.PUT_LINE( FND_FILE.LOG,
						 'Average Amount = ' || to_char(average_amount));
               FND_FILE.PUT_LINE( FND_FILE.LOG,' ');
      END IF;




      RETURN (Average_Amount);

	 EXCEPTION
 	 WHEN OTHERS THEN
	     Current_error_Code := to_Char(SQLCODE);
	 	IF (P_Conc_Program = 'Y')THEN
       		FND_FILE.PUT_LINE( FND_FILE.LOG,
					'Error in Calculate Average Amount' );
       		FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
		END IF;
      	RETURN (Average_Amount);

END Calculate_Average_Amount;






FUNCTION Convert_Duration(
                             P_CONC_PROGRAM        IN  VARCHAR2,
                             P_SERVICE_DURATION   IN  NUMBER,
                             P_INVENTORY_ITEM_ID  IN  NUMBER,
                             P_FROM_UNIT          IN  VARCHAR2,
                             P_TO_UNIT            IN  VARCHAR2
                               ) RETURN  NUMBER IS
	Converted_Duration  Number;
 BEGIN
/*
   FND_FILE.Put_Line (FND_FILE.LOG,'Service Duration = '||
		    to_char(p_service_duration));
   FND_FILE.Put_Line (FND_FILE.LOG,'From_Unit = '||p_from_unit);
   FND_FILE.Put_Line (FND_FILE.LOG,'To_Unit = '||p_to_unit);
*/
      IF (p_from_unit = p_to_unit) then
	 	Converted_Duration := p_service_duration ;
 	 ELSE
     	Converted_duration := INV_CONVERT.inv_um_convert
					( item_id       => p_inventory_item_id,
					  precision     => 5,
					  From_quantity => p_service_duration,
					  From_Unit	=> p_from_unit,
					  To_Unit	=> p_to_unit,
					  From_Name	=> NULL,
					  To_Name	=> NULL);

      END IF;


	IF (P_Conc_Program = 'Y')THEN
              FND_FILE.PUT_LINE( FND_FILE.LOG,'Converted Duration is ='||
					to_char(Converted_Duration));
              FND_FILE.PUT_LINE( FND_FILE.LOG,' ');
     END IF;


   RETURN ( Converted_Duration);


	 EXCEPTION
 	 WHEN OTHERS THEN
	     Current_error_Code := to_Char(SQLCODE);
		IF (P_Conc_Program = 'Y')THEN
       		FND_FILE.PUT_LINE( FND_FILE.LOG,
					'Error in Convert Duration' );
       		FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
		END IF;
      	RETURN (Converted_Duration);

END Convert_Duration;



Procedure Print_Error IS
l_count   number;
l_msg     varchar2(2000);
begin
	Fnd_msg_pub.Count_And_get(p_count    => l_count,
                          	  p_data     => l_msg,
                                  p_encoded  => 'F');
	if l_count = 0
	then
		null;
	elsif l_count = 1
	then
         	FND_FILE.PUT_LINE( FND_FILE.LOG, l_msg);
	else
		For I in 1..l_count
		loop
	 		l_msg := fnd_msg_pub.get(I,'F');
         		FND_FILE.PUT_LINE( FND_FILE.LOG, l_msg);
		end loop;
	end if;
        FND_MSG_PUB.initialize;
Exception
 when others then
       FND_FILE.PUT_LINE( FND_FILE.LOG, SQLERRM );
End Print_Error;
END CS_CONTRACT_BILLING;


/
