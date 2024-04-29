--------------------------------------------------------
--  DDL for Package Body PSP_PI_IMPORT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PI_IMPORT_DATA" AS
/* $Header: PSPPII2B.pls 120.3 2006/10/19 05:45:11 dpaudel noship $ */
    /*********************************************************************************************
		This package has been created for concurrent processing. This contains parameters
		for errbuf and retCode. This has been modified on 05/08/98 by Al Arunachalam
    **********************************************************************************************/
    retVal Number;
    g_bg_currency_code psp_payroll_interface.currency_code%type;
    g_sob_currency_code gl_sets_of_books.currency_code%type;	-- Introduced for bug fix 3107800


    -- Introduced v_precision,v_ext_precision,v_currency_code in perform_validation for Bug 2916848
    Function Perform_Validations(v_Batch_Name IN varchar2,v_business_group_id IN NUMBER,
				v_set_of_books_id IN NUMBER,v_precision IN NUMBER,
				v_ext_precision  IN NUMBER,v_currency_code IN VARCHAR2) return Number;

    -- Introduced v_precision,v_ext_precision,v_currency_code IN perform_import function for Bug 2916848
    Function Perform_Import(v_Batch_Name IN varchar2,v_business_group_id IN NUMBER,
				v_set_of_books_id IN NUMBER,v_precision  IN NUMBER,
			    v_ext_precision  IN  NUMBER,v_currency_code  IN VARCHAR2) return Number;

    -- Introduced v_precision,v_ext_precision IN import_payroll_lines function for Bug 2916848
    Function Import_Payroll_Lines(V_Batch_Name IN varchar2,v_business_group_id IN NUMBER,
				v_set_of_books_id IN NUMBER,v_precision IN NUMBER,
				v_ext_precision  IN NUMBER) return Number;
    Function Import_Payroll_Sub_Lines(v_RowID IN OUT NOCOPY varchar2, n_Payroll_Sub_Lines_ID number,
		n_Payroll_Lines_ID Number, d_Sub_Line_Start_Date DATE,
		d_Sub_Line_End_Date Date, v_Reason_Code varchar2, n_Pay_Amount Number, n_Daily_Rate
		Number, n_Salary_Used Number, n_Current_Salary Number,
		n_FTE Number, n_Organization_ID Number, n_Job_ID Number, n_Position_ID Number,
		d_Employment_Begin_Date Date, d_Employment_End_Date Date, d_Status_Inactive_Date Date,
		d_Status_Active_Date Date, d_Assignment_Begin_Date Date, d_Assignment_End_Date Date,
                p_attribute_category IN VARCHAR2, p_attribute1 IN VARCHAR2,		-- Introduced DFF columns for bug fix 2908859
                p_attribute2 IN VARCHAR2, p_attribute3 IN VARCHAR2,
                p_attribute4 IN VARCHAR2, p_attribute5 IN VARCHAR2,
                p_attribute6 IN VARCHAR2, p_attribute7 IN VARCHAR2,
                p_attribute8 IN VARCHAR2, p_attribute9 IN VARCHAR2,
                p_attribute10 IN VARCHAR2)
		return Number;

    --  Introduced v_precision,v_ext_precision in process_payroll_sub_lines function for Bug 2916848
    Function Process_Payroll_Sub_Lines(v_Batch_Name varchar2, n_Payroll_Period_ID number,
		n_Assignment_ID Number, n_Element_Type_Id Number, n_Payroll_Lines_ID Number,
		d_Sub_Line_Start_Date DATE, d_Sub_Line_End_Date DATE,v_precision number,
		v_ext_precision number, v_business_group_id IN NUMBER) return Number;	-- Introduced BG for bug 2908859

    Function Change_To_Transfer(v_Batch_Name IN varchar2) return Number;
    Function Check_For_Valid_Batches(v_Batch_Name IN varchar2,v_business_group_id IN NUMBER,
					v_set_of_books_id IN NUMBER) return Number;

    -- Enc Fix 2916848
    -- Introduces check for valid currency for Bug2916848 to check  whether a batch has more than
    -- one currency.

    Function Check_For_Valid_Currency(v_batch_name IN VARCHAR2,v_business_group_id IN NUMBER,
				      v_set_of_books_id	IN NUMBER) return NUMBER;

    -- Introduced get currency for batch for Bug 2916848

    Function Get_Currency_For_Batch(v_batch_name IN VARCHAR2,v_business_group_id IN NUMBER,
				     v_set_of_books_id  IN NUMBER) return VARCHAR2;

    -- End of Enc fix 2916848

  /*************************************IMPORT_RECORDS**************************************
   OBJ: This is a public procedure (called externally, from the concurrent manager). This
        serves as a wrapper for calling the Validations procedure, for performing the import,
        and for Changing the status of records imported to 'TRANSFER'.
  CREATED BY:   AL ARUNACHALAM
  DATE:         03/27/98
  *****************************************************************************************/
  Procedure Imp_Rec(errBuf OUT NOCOPY varchar2, retCode OUT NOCOPY varchar2,
		    v_Batch_Name IN varchar2, v_business_group_id IN NUMBER,
		    v_set_of_books_id IN NUMBER) IS

--	Enh. fix 2094036
	CURSOR	payroll_interface_check_cur IS
	SELECT	payroll_interface_id
	FROM	psp_payroll_interface
	WHERE	batch_name = v_batch_name
	AND	business_group_id = v_business_group_id
	AND	set_of_books_id = v_set_of_books_id
	FOR UPDATE OF payroll_interface_id NOWAIT;

	l_payroll_interface_id		NUMBER;

	RECORD_ALREADY_LOCKED	EXCEPTION;

--     Enc. Fix 2916848

--	Introduced the following for bug fix 3107800
	CURSOR	sob_currency_code_cur IS
	SELECT	currency_code
	FROM	gl_sets_of_books gsob
	WHERE	set_of_books_id = v_set_of_books_id;
--	End of fix 3107800

	l_currency_code 	psp_payroll_interface.currency_code%type;

        l_precision		NUMBER;
	l_ext_precision 	NUMBER;


--	End of Fix 2916848 by tbalacha

	PRAGMA EXCEPTION_INIT (RECORD_ALREADY_LOCKED, -54);
--	End of Enh. fix 2094036

        l_error_api_name        VARCHAR2(2000);

        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_dist_message          VARCHAR2(2000);
  Begin

	-- Initialize the FND_MSG_PUB package
	fnd_msg_pub.Initialize;

--	Enh. fix 2094036
	OPEN payroll_interface_check_cur;
	FETCH payroll_interface_check_cur INTO l_payroll_interface_id;
	IF (payroll_interface_check_cur%NOTFOUND) THEN
		CLOSE payroll_interface_check_cur;
		RAISE RECORD_ALREADY_LOCKED;
	END IF;

	CLOSE payroll_interface_check_cur;
--	End of Enh. fix 2094036

        -- First, Validate all records in this batch


	If Check_For_Valid_Batches(v_Batch_Name,v_business_group_id,v_set_of_books_id) <> 0 Then
		l_error_api_name := 'INVALID BATCH';
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;


--	ENH. fix 2916848

	g_bg_currency_code := psp_general.get_currency_code(v_business_group_id);

--	Introduced for bug fix 3107800
	OPEN sob_currency_code_cur;
	FETCH sob_currency_code_cur INTO g_sob_currency_code;
	CLOSE sob_currency_code_cur;
--	End of bug fix 3107800

        IF Check_for_valid_currency(v_batch_name,v_business_group_id,v_set_of_books_id) <> 0 Then
           l_error_api_name := 'INVALID_CURRENCY';
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


       l_currency_code := Get_Currency_For_Batch(v_batch_name,v_business_group_id,v_set_of_books_id);

       psp_general.get_currency_precision(l_currency_code,l_precision,l_ext_precision);

--  calling procedure get_currency_precision to calculate  precision based on currency_code
--	End Enh 2916848

--  Intorduced l_precisin,l_ext_precision,l_currency_code parameters in perform_validation  for bug 2916848

        If Perform_Validations(v_Batch_Name,v_business_group_id,v_set_of_books_id,l_precision,
			       l_ext_precision,l_currency_code) <> 0 Then
                -- dbms_output.put_line('Errors occured during validation');
                l_error_api_name := 'PERFORM VALIDATIONS';
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        End If;
        -- Now, perform the IMPORT
-- Introduced l_precision,l_ext_precision  l_currency_code  variables for Bug 2916848

        If Perform_Import(v_Batch_Name,v_business_group_id,v_set_of_books_id,
			  l_precision,l_ext_precision,l_currency_code) <> 0 Then
                -- dbms_output.put_line('Errors occured during Import process');
                l_error_api_name := 'IMPORT PROCESS';
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        End If;
       -- COMMIT;

    /* commit commented out to allow proper rollback  in the event that problem occurs during change to_transfer
       procedure */

        -- Finally, change the statuses of all records in this batch to TRANSFER
        If Change_To_Transfer(v_Batch_Name) <> 0 Then
                -- dbms_output.put_line('Unable to change the statuses of all records to TRANSFER');
                l_error_api_name := 'CHANGE TO TRANSFER STATUS';
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        End If;

        COMMIT;
        retCode := 0;
  Exception
--	Enh. fix 2094036
	WHEN RECORD_ALREADY_LOCKED THEN
		fnd_message.set_name('PSP', 'PSP_PI_BATCH_IN_PROGRESS');
		fnd_message.set_token('BATCH_NAME', v_batch_name);
		l_dist_message := fnd_message.get;
		errbuf := l_error_api_name || fnd_global.local_chr(10) || l_dist_message;
		retcode:= 2;
--	End of Enh. fix 2094036
        when FND_API.G_EXC_UNEXPECTED_ERROR Then
                fnd_msg_pub.get(p_msg_index     => FND_MSG_PUB.G_FIRST,
                                p_encoded       => FND_API.G_FALSE,
                                p_data          => l_msg_data,
                                p_msg_index_out => l_msg_count);
                fnd_message.set_name('PSP','PSP_PI_IMPORT_GENERAL');
                fnd_message.set_token('PROCEDURE_NAME',l_error_api_name);
                l_dist_message := fnd_message.get;
                errbuf := substr(l_error_api_name || fnd_global.local_chr(10) || l_msg_data || fnd_global.local_chr(10) || l_dist_message, 1, 232);
                retCode := 2;
		rollback;


        when others then
                -- dbms_output.put_line('Unknown Error ' || sqlerrm);
                fnd_msg_pub.add_exc_msg('PSP_PI_IMPORT_DATA',l_error_api_name);
                fnd_msg_pub.get(p_msg_index     => FND_MSG_PUB.G_FIRST,
                                p_encoded       => FND_API.G_FALSE,
                                p_data          => l_msg_data,
                                p_msg_index_out => l_msg_count);
                fnd_message.set_name('PSP','PSP_PI_IMPORT_GENERAL');
                fnd_message.set_token('PROCEDURE_NAME',l_error_api_name);
                l_dist_message := fnd_message.get;

                errbuf := substr(l_error_api_name || fnd_global.local_chr(10) || l_msg_data || fnd_global.local_chr(10) || l_dist_message, 1, 232);
                retCode := 2;
		rollback;
  End Imp_Rec;
  /***********************************Change_To_Transfer************************************
   OBJ: This is a private procedure (called internally, from Import_Records). This
        is where the status of records imported are changed to 'TRANSFER'.
  CREATED BY:   AL ARUNACHALAM
  DATE:         03/27/98
  *****************************************************************************************/
  Function Change_To_Transfer(v_Batch_Name IN varchar2) return Number IS
    Cursor Change_Statuses Is
        select  STATUS_CODE
        from    PSP_PAYROLL_INTERFACE
        where   Batch_Name = v_Batch_Name
        FOR UPDATE OF STATUS_CODE;
    Change_Statuses_Agg Change_Statuses%RowType;
  Begin
        FOR Change_Statuses_Agg IN Change_Statuses LOOP
                Update PSP_PAYROLL_INTERFACE set STATUS_CODE = 'T' where CURRENT OF Change_Statuses;
        End Loop;
        return 0;
  Exception
        when others then

                fnd_msg_pub.add_exc_msg('PSP_PI_IMPORT_DATA', 'Change_To_Transfer');
                return 2;
  End Change_To_Transfer;
  /*******************************Perform_Validations***************************************
   OBJ: This is a private procedure (called internally, from Import_Records). This
        is where the server side package PSP_VALID_NON_ORCL_PKG is called to perform
        validations.
  CREATED BY:   AL ARUNACHALAM
  DATE:         03/27/98
  *****************************************************************************************/

  Function Perform_Validations(v_Batch_Name         IN VARCHAR2,
			       v_business_group_id  IN NUMBER,
			       v_set_of_books_id    IN NUMBER,
			       v_precision	    IN NUMBER,
			       v_ext_precision      IN NUMBER,
			       v_currency_code      IN VARCHAR2) return NUMBER IS
        n_Valid_Records Number;
  Begin
        PSP_VALID_NON_ORCL_PKG.All_Records(v_Batch_Name,v_business_group_id,v_set_of_books_id,
					   v_precision,v_ext_precision,v_currency_code);
        -- Next, check if any records have statuses other than Valid
        select count(*)
        into n_Valid_Records
        from PSP_PAYROLL_INTERFACE
        where Batch_Name = v_Batch_Name
        and STATUS_CODE <> 'V';
        -- If records do not have Valid status, then inform the user
        --      and exit. Else, continue
        If n_Valid_Records > 0 Then

          -- dbms_output.put_line('Records are not all valid in this batch. Please validate the records
		--		Non_Orcl Maintenance screen');
          FND_MESSAGE.SET_NAME('PSP', 'PSP_PI_INVALID_RECORDS');
          FND_MESSAGE.SET_TOKEN('BATCH_NAME', v_Batch_Name);
          return (1);
        Else
          -- dbms_output.put_line('Server side validation done successfully. Now, on to import
		-- process.');
          return (0);
        End If;
    End Perform_Validations;
  /*******************************Perform_Import*******************************************
   OBJ: This is a private procedure (called internally, from Import_Records). This
        is where data from PSP_PAYROLL_INTERFACE is imported to PSP_PAYROLL_CONTROLS. After
        this has been done successfully, the Import_Payroll_Lines procedure is called.
  CREATED BY:   AL ARUNACHALAM
  DATE:         03/27/98

  -- Intoduced v_precision,v_ext_precision,v_currency_code for bug 2916848
  *****************************************************************************************/
    Function Perform_Import(v_Batch_Name IN varchar2,v_business_group_id IN NUMBER,
			    v_set_of_books_id IN NUMBER,v_precision IN  NUMBER,
			    v_ext_precision IN NUMBER,v_currency_code IN VARCHAR2) return Number IS
            cursor Control_Record IS
                Select  DISTINCT Payroll_Period_ID, Payroll_Source_Code,
			GL_POSTING_OVERRIDE_DATE,GMS_POSTING_OVERRIDE_DATE
                From    PSP_PAYROLL_INTERFACE
                Where   Batch_Name = v_Batch_Name
                And     STATUS_CODE <> 'T';
            n_Payroll_ID Number;

            n_Number_Of_Credits Number;
            n_Number_Of_Debits Number;
            n_Credit_Amount Number;
            n_Debit_Amount Number;
            n_Payroll_Control_ID Number;
            v_ROWID Varchar2(30);
            n_Payroll_Action_ID Number := 1;
            v_Rollback_Flag varchar2(30);
            v_Rollback_Date DATE;
	    v_Sublines_CR_Amount Number;
	    v_Sublines_DR_Amount Number;

-- intorduced the following for Bug 2916848

            CURSOR Time_period_end_date_cur(n_time_period_id IN NUMBER) IS
	    SELECT end_date
	    FROM   PER_TIME_PERIODS
            WHERE  time_period_id = n_time_period_id;

            l_exchange_rate_type psp_payroll_controls.exchange_rate_type%type;
            l_end_date       DATE;
	    l_currency_chk    BOOLEAN := TRUE;

-- End of Bug 2916848


    Begin

	-- Performing the following currency_code check for population of Exchange_rate_type
	-- for Bug 2916848

	   IF ((g_bg_currency_code = v_currency_code) AND (g_bg_currency_code = g_sob_currency_code)) THEN
		l_currency_chk := FALSE;
	   END IF;

	-- End of code for Bug 2916848

        -- First, create Control Records in PSP_Payroll_Controls
        -- Create a record for every unique Payroll_Period_ID, Payroll_Source_Code
        For Control_Record_Agg IN Control_Record LOOP
          -- Obtain the Payroll ID for every Payroll Period being added to the table
          Begin
                Select DISTINCT Payroll_ID
                Into    n_Payroll_ID
                From    PSP_PAYROLL_INTERFACE
                where   PAYROLL_PERIOD_ID = Control_Record_Agg.Payroll_Period_ID
                and     PAYROLL_SOURCE_CODE = Control_Record_Agg.Payroll_Source_Code
		and 	BATCH_NAME = v_Batch_Name;
          Exception
                when too_many_rows then
                        -- dbms_output.put_line('Too many Payroll IDs returned for the Batch ' ||
			-- v_batch_name || ' while creating control lines');

                        fnd_message.set_name('PSP','PSP_PI_MULTPL_PAYROLLS');
                        fnd_message.set_token('BATCH_NAME',v_batch_name);
                        fnd_msg_pub.add;
                        return 1;
                when no_data_found then
                        fnd_message.set_name('PSP','PSP_PI_NO_PAYROLLS');
                        fnd_message.set_token('BATCH_NAME',v_batch_name);
                        fnd_msg_pub.add;
                        return 1;
          End;

         -- Introduced the following code to fetch exchange_rate_type for Bug 2916848
            l_exchange_rate_type := NULL;

            IF (l_currency_chk)  THEN
	       open Time_period_end_date_cur(Control_Record_Agg.payroll_period_id);
               fetch Time_period_end_date_cur into l_end_date;
               close Time_period_end_date_cur;
	       l_exchange_rate_type := hruserdt.get_table_value(v_business_group_id,'EXCHANGE_RATE_TYPES',
					'Conversion Rate Type','PAY' ,l_end_date);

            END IF;


        -- End of code for Bug 2916848



          -- Next, obtain the Number of Credits, Debits, Credit Amount, and Debit amount
          -- for every record being added
          select        Count(DR_CR_FLAG), SUM(ROUND(PAY_AMOUNT,v_precision))
          into  n_Number_Of_Credits, n_Credit_Amount
          from  PSP_PAYROLL_INTERFACE
          where Payroll_Period_ID = Control_Record_Agg.Payroll_Period_ID
          and   Payroll_Source_Code = Control_Record_Agg.Payroll_Source_Code
          and   Batch_Name = v_Batch_Name
          and   UPPER(DR_CR_FLAG) = 'C';

          select        Count(DR_CR_FLAG), SUM(ROUND(PAY_AMOUNT,v_precision))
          into  n_Number_Of_Debits, n_Debit_Amount
          from  PSP_PAYROLL_INTERFACE
          where Payroll_Period_ID = Control_Record_Agg.Payroll_Period_ID
          and   Payroll_Source_Code = Control_Record_Agg.Payroll_Source_Code
          and   Batch_Name = v_Batch_Name
          and   UPPER(DR_CR_FLAG) = 'D';

	  -- Also, obtain the Total Sublines CR Amount and Total Sublines DR Amount for Batch
	  Select  SUM(ROUND(PAY_AMOUNT,v_precision))
	  into	  v_Sublines_CR_Amount
	  from	  PSP_PAYROLL_INTERFACE
	  where	  Batch_Name = v_Batch_Name
--	Introduced Time Period and Source Code check for bug fix 3116383
	  AND	  payroll_period_id = control_record_agg.payroll_period_id
	  AND	  payroll_source_code = control_record_agg.payroll_source_code
	  and	  UPPER(DR_CR_FLAG) = 'C';

	  Select  SUM(ROUND(PAY_AMOUNT,v_precision))
	  into	  v_Sublines_DR_Amount
	  from	  PSP_PAYROLL_INTERFACE
	  where	  Batch_Name = v_Batch_Name
--	Introduced Time Period and Source Code check for bug fix 3116383
	  AND	  payroll_period_id = control_record_agg.payroll_period_id
	  AND	  payroll_source_code = control_record_agg.payroll_source_code
	  and	  UPPER(DR_CR_FLAG) = 'D';


          -- Insert Payroll Control Records into PSP_Payroll_Controls table
          Select PSP_PAYROLL_CONTROLS_S.NextVal
          into n_Payroll_Control_ID
          from DUAL;

	  PSP_PAYROLL_CONTROLS_PKG.INSERT_ROW (
	    X_ROWID => v_ROWID,
	    X_PAYROLL_CONTROL_ID => n_Payroll_Control_ID,
	    X_PAYROLL_ACTION_ID => n_Payroll_Action_ID,
	    X_PAYROLL_SOURCE_CODE => Control_Record_Agg.Payroll_Source_Code,
	    X_SOURCE_TYPE => 'N',
	    X_PAYROLL_ID => n_Payroll_ID,
	    X_TIME_PERIOD_ID => Control_Record_Agg.Payroll_Period_ID,
	    X_NUMBER_OF_CR => n_Number_Of_Credits,
	    X_NUMBER_OF_DR => n_Number_Of_Debits,
	    X_TOTAL_DR_AMOUNT => n_Debit_Amount,
	    X_TOTAL_CR_AMOUNT => n_Credit_Amount,
	    -- X_ROLLBACK_FLAG => v_Rollback_Flag,
	    -- X_ROLLBACK_DATE => v_Rollback_Date,
	    X_BATCH_NAME => v_Batch_Name,
	    X_SUBLINES_DR_AMOUNT => v_Sublines_DR_Amount,
	    X_SUBLINES_CR_AMOUNT => v_Sublines_CR_Amount,
	    -- X_DISTRIBUTION_AMOUNT => NULL,
	    X_DIST_DR_AMOUNT => NULL,
	    X_DIST_CR_AMOUNT => NULL,
	    X_OGM_DR_AMOUNT => NULL,
	    X_OGM_CR_AMOUNT => NULL,
	    X_GL_DR_AMOUNT => NULL,
	    X_GL_CR_AMOUNT => NULL,
	    X_STATUS_CODE => 'N',
	    X_MODE => 'R' ,
            X_GL_POSTING_OVERRIDE_DATE => Control_Record_Agg.GL_POSTING_OVERRIDE_DATE,
            X_GMS_POSTING_OVERRIDE_DATE => Control_Record_Agg.GMS_POSTING_OVERRIDE_DATE,
	    X_set_of_books_id           => v_set_of_books_id,
	    X_business_group_id         => v_business_group_id,
	    X_GL_phase                  => NULL,
	    X_GMS_PHASE                 => NULL,
	    X_ADJ_SUM_BATCH_NAME        => NULL,
	    X_CURRENCY_CODE		=> v_currency_code,
	    X_EXCHANGE_RATE_TYPE	=> l_exchange_rate_type);

        -- dbms_output.put_line('Insert to PAYROLL_CONTROLS table done successfully');
    END LOOP;
    -- Call the Import_Payroll_Lines function to import data to Payroll_Lines and
    -- to Payroll_Sub_Lines
    retVal := Import_Payroll_Lines(v_Batch_Name,v_business_group_id,v_set_of_books_id,
				   v_precision,v_ext_precision);
    -- Introduced v_precision,v_ext_precision for import_payroll_lines call for bug 2916848

    If retVal <> 0 Then
        Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    Else
        -- dbms_output.put_line('Import to Payroll Controls table done completely');
        return 0;
    End If;
  EXCEPTION
        when FND_API.G_EXC_UNEXPECTED_ERROR Then
                fnd_msg_pub.add_exc_msg('PSP_PI_IMPORT_DATA','IMPORT_PERFORM_IMPORT');
                return 3;
        when OTHERS Then
                fnd_msg_pub.add_exc_msg('PSP_PI_IMPORT_DATA','IMPORT_PERFORM_IMPORT');
                return 2;
  End Perform_Import;
  /*****************************Import_Payroll_Lines***************************************
   OBJ: This is a private procedure (called internally, from Perform_Import). This procedure
        inserts records to the PSP_PAYROLL_LINES table and creates corresponding sub_lines

        by calling the Process_Payroll_Sub_Lines procedure.
  ASSUMPTIONS: The foll. fields that are to be entered to the Payroll Lines tables have been left
                empty (ref: Subbarao, date: 03/27/98)
                COST_ID, COST_ALLOCATION_KEYFLEX_ID, GL_CODE_COMBINATION_ID, BALANCE_AMOUNT
  CREATED BY:   AL ARUNACHALAM
  DATE:         03/27/98

 --  Intoduced v_precision parameter for Bug 2916848
  *****************************************************************************************/
  Function Import_Payroll_Lines(v_Batch_Name IN varchar2,v_business_group_id IN NUMBER,
				v_set_of_books_id IN NUMBER,
				v_precision     IN  NUMBER,v_ext_precision IN NUMBER) return Number IS
           cursor Lines_Record IS
                Select  DISTINCT Payroll_Period_ID, Assignment_ID, Element_Type_ID, Payroll_Source_Code,
				Sub_Line_Start_Date, Sub_Line_End_Date
                From    PSP_PAYROLL_INTERFACE
                Where   Batch_Name = v_Batch_Name
                And     STATUS_CODE <> 'T';
           Lines_Record_Agg Lines_Record%ROWTYPE;
                v_ROWID varchar2(30);
                n_Payroll_ID Number;
                n_Payroll_Control_ID Number;
                n_Payroll_Lines_ID Number;
                n_Set_Of_Books_ID Number;
                d_Effective_Date DATE;
                n_Person_ID Number;
                n_Cost_ID Number;
                n_Pay_Amount Number;

                d_Check_Date Date;
                d_Earned_Date Date;
                v_DR_CR_Flag varchar2(1);
                n_Cost_Allocation_KeyFlex_ID Number;
                n_GL_Code_Combination_ID Number;
                n_Balance_Amount Number;

--	   v_Set_Of_Books_ID varchar2(30);
  Begin
         -- dbms_output.put_line('About to insert Payroll Lines');
         -- Next, create Payroll Line records in PSP_Payroll_Lines table
         -- Create a record for every unique Payroll_Period_ID, Assignment_ID, Element_Type_ID
        FOR Lines_Record_Agg IN Lines_Record LOOP
                -- Obtain foreign key reference from PSP_Payroll_Controls table
                BEGIN
                  select        DISTINCT PAYROLL_CONTROL_ID
                  into          n_Payroll_Control_ID
                  from          PSP_PAYROLL_CONTROLS
                  where         TIME_PERIOD_ID = Lines_Record_Agg.Payroll_Period_ID
                  and           PAYROLL_SOURCE_CODE = Lines_Record_Agg.Payroll_Source_Code
		  and		BATCH_NAME = v_Batch_Name
		  and           business_group_id = v_business_group_id
		  and           set_of_books_id   = v_set_of_books_id;

                EXCEPTION
                  when too_many_rows then
                        fnd_message.set_name('PSP','PSP_PI_MULTPL_PAYROLL_CNTRL_ID');
                        fnd_message.set_token('PAYROLL_PERIOD_ID', to_char(Lines_Record_Agg.Payroll_Period_ID));
                        fnd_message.set_token( 'PAYROLL_SOURCE_CODE', Lines_Record_Agg.Payroll_Source_Code);
                        fnd_msg_pub.add;
                        return 1;
                END;
/* Bug 4155144 - commented this block since the same check has already been done when inserting the control record
                -- Obtain Payroll ID for a given Payroll Period and the non-oracle source code
		BEGIN
                  Select DISTINCT Payroll_ID
                  Into    n_Payroll_ID
                  From    PSP_PAYROLL_INTERFACE
                  where   PAYROLL_PERIOD_ID = Lines_Record_Agg.Payroll_Period_ID
                  and     PAYROLL_SOURCE_CODE = Lines_Record_Agg.Payroll_Source_Code
		  and	  BATCH_NAME = v_Batch_Name;
                  -- dbms_output.put_line('Payroll ID ' || to_Char(n_Payroll_ID) || ' obtained');
		EXCEPTION
		  when OTHERS then
			fnd_message.set_name('PSP', 'PSP_PI_INV_PAYROLL_FOR_PERIOD');
			fnd_message.set_token('PAYROLL_PERIOD', to_char(Lines_Record_Agg.Payroll_Period_ID));
			fnd_message.set_token('PAYROLL_SOURCE', Lines_Record_Agg.Payroll_Source_Code);
			fnd_msg_pub.add;
			return 1;
		END;

*/
                -- Obtain information from PSP_PAYROLL_INTERFACE table that is to be inserted into the
		-- PSP_PAYROLL_LINES table
-- n_payroll_id Added for bug fix 4179476
		BEGIN
                  Select DISTINCT Effective_Date, Person_ID, round(Pay_Amount,v_precision),
		         Check_Date, Earned_Date, UPPER(DR_CR_Flag), payroll_id
                  Into    d_Effective_Date, n_Person_ID, n_Pay_Amount, d_Check_Date, d_Earned_Date,
			  v_DR_CR_Flag, n_payroll_id
                  From    PSP_PAYROLL_INTERFACE
                  where   PAYROLL_PERIOD_ID = Lines_Record_Agg.Payroll_Period_ID
                  and     PAYROLL_SOURCE_CODE = Lines_Record_Agg.Payroll_Source_Code
--Condition Droped for bug fix 4179476
--                  and     PAYROLL_ID = n_Payroll_ID
                  and     ASSIGNMENT_ID = Lines_Record_Agg.Assignment_ID
                  and     ELEMENT_TYPE_ID = Lines_Record_Agg.Element_Type_ID
		  and 	  SUB_LINE_START_DATE = Lines_Record_Agg.Sub_Line_Start_Date
		  and	  SUB_LINE_END_DATE = Lines_Record_Agg.Sub_Line_End_Date
		  and	BATCH_NAME = v_Batch_Name;
		EXCEPTION
		  when OTHERS then
			fnd_message.set_name('PSP', 'PSP_PI_MUL_REC_FOR_PER_ASS_EL');
			fnd_message.set_token('PAYROLL_PERIOD', to_char(Lines_Record_Agg.Payroll_Period_ID));
			fnd_message.set_token('PAYROLL_SOURCE', Lines_Record_Agg.Payroll_Source_Code);
			fnd_message.set_token('ASSIGNMENT', to_char(Lines_Record_Agg.Assignment_ID));
			fnd_message.set_token('ELEMENT_TYPE', to_char(Lines_Record_Agg.Element_Type_ID));
			fnd_msg_pub.add;
			return 1;
		END;

		select 	Cost_Allocation_KeyFlex_ID
		into	n_Cost_Allocation_KeyFlex_ID
		from 	PAY_PAYROLLS_F a
		where	a.PAYROLL_ID = n_Payroll_ID
		and	d_Effective_Date BETWEEN a.EFFECTIVE_START_DATE AND a.EFFECTIVE_END_DATE
                and     a.business_group_id = v_business_group_id;

                -- obtain the primary key for the PSP_PAYROLL_LINES table from the DUAL table
                select  PSP_PAYROLL_LINES_S.NextVal
                into    n_Payroll_Lines_ID
                from    DUAL;

		/*********************************************************************************************
		-- Commented out the following code bcos we no longer want to obtain GL_CCID from the complex
		-- procedure below. Instead, we want to obtain GL_CCID from PSP_Clearing_Account (Venkat 06/24)
                -- Next, obtain the Set_Of_Books_ID from Pay_Payrolls_F
                -- Obtain Cost Allocation Key Flex ID, GL_Code_Combination_ID, and
		-- Balance_Amount using Venkat's procedure
                -- dbms_output.put_line('Running Venkat''s procedure for GL CCID');
		v_Set_Of_Books_ID := FND_Profile.Value('PSP_SET_OF_BOOKS');

		If (v_Set_Of_Books_ID IS NULL) or (to_number(v_Set_Of_Books_ID) <> n_Set_Of_Books_ID) Then
			-- dbms_output.put_line('Profile value for Set of Books ID :' ||
			-- v_Set_Of_Books_ID || ' does not match value from PAY_PAYROLLS_F. Cannot
			-- proceed');
			fnd_message.set_name('PSP', 'PSP_PI_INVALID_SET_OF_BOOKS');
                        fnd_msg_pub.add;
			return 2;
		End If;

		PSP_General.get_GL_CCID(P_Payroll_ID => n_Payroll_ID, P_Set_Of_Books_ID =>
			n_Set_Of_Books_ID, P_Cost_KeyFlex_ID => n_Cost_Allocation_KeyFlex_ID,
			x_GL_CCID => n_GL_Code_Combination_ID);

		If n_GL_Code_Combination_ID IS NULL or n_GL_Code_Combination_ID = 0 Then
			-- dbms_output.put_line('GL Code Combination ID is invalid. Cannot proceed');
			fnd_message.set_name('PSP', 'PSP_INVALID_GL_CCID');
                        fnd_msg_pub.add;
			return 2;
		End If;
		******************************************************************************************/
		Begin
			Select 	reversing_gl_ccid
			into	n_GL_Code_Combination_ID
			from	PSP_CLEARING_ACCOUNT a
			where   a.business_group_id = v_business_group_id
			and     a.set_of_books_id   = v_set_of_books_id
			and     a.payroll_id = n_payroll_id;  -- Added for bug 5592964

			If n_GL_Code_Combination_ID IS NULL or n_GL_Code_Combination_ID = 0 Then
			  -- dbms_output.put_line('GL Code Combination ID is invalid. Cannot proceed');
			  fnd_message.set_name('PSP', 'PSP_NO_CLEARING_ACCOUNT');
                          fnd_msg_pub.add;
			  return 2;
			End If;

		Exception
			when OTHERS Then
			  fnd_message.set_name('PSP', 'PSP_NO_CLEARING_ACCOUNT');
			  fnd_msg_pub.add;
			  return 2;
		End;

--		v_Set_Of_Books_ID := FND_Profile.Value('PSP_SET_OF_BOOKS');

		If (v_Set_Of_Books_ID IS NULL) Then
			-- dbms_output.put_line('Profile value for Set of Books ID :' ||
			-- v_Set_Of_Books_ID || ' does not match value from PAY_PAYROLLS_F. Cannot
			-- proceed');
			fnd_message.set_name('PSP', 'PSP_PI_INVALID_SET_OF_BOOKS');
                        fnd_msg_pub.add;
			return 2;
		End If;
--		n_Set_Of_Books_ID := to_number(v_set_of_books_id);

		-- dbms_output.put_line('Obtained GL CCID. Now, inserting to Payroll Lines');
                -- Now, insert rows to the PSP_PAYROLL_LINES table
                PSP_PAYROLL_LINES_PKG.INSERT_ROW (
                  X_ROWID => v_ROWID,
                  X_PAYROLL_LINE_ID => n_Payroll_Lines_ID,
                  X_PAYROLL_CONTROL_ID => n_Payroll_Control_ID,
                  X_SET_OF_BOOKS_ID => v_Set_Of_Books_ID,
                  X_ASSIGNMENT_ID => Lines_Record_Agg.Assignment_ID,
                  X_PERSON_ID => n_Person_ID,
                  X_COST_ID => n_Cost_ID,
                  X_ELEMENT_TYPE_ID => Lines_Record_Agg.Element_Type_ID,
                  X_PAY_AMOUNT => n_Pay_Amount,
                  X_STATUS_CODE => 'N',
                  X_EFFECTIVE_DATE => d_Effective_Date,
                  X_CHECK_DATE => d_Check_Date,
                  X_EARNED_DATE => d_Earned_Date,
                  X_COST_ALLOCATION_KEYFLEX_ID => n_Cost_Allocation_KeyFlex_ID,
                  X_GL_CODE_COMBINATION_ID => n_GL_Code_Combination_ID,
                  X_BALANCE_AMOUNT => n_Balance_Amount,
                  X_DR_CR_FLAG => v_DR_CR_Flag,
                  X_MODE => 'R'
                  );
                -- Finally, create Payroll Sub line records in PSP_Payroll_Sub_Lines table
                -- Create a record in PSP_payroll_sub_lines table for every record in
		-- PSP_Payroll_Interface table
		-- dbms_output.put_line('Inserted into Payroll Lines. Now, inserting to Payroll Sub
		-- lines');
                retVal := Process_Payroll_Sub_Lines(v_batch_name, Lines_Record_Agg.Payroll_Period_ID,
				Lines_Record_Agg.Assignment_ID, Lines_Record_Agg.Element_Type_ID,
				n_Payroll_Lines_ID, Lines_Record_Agg.Sub_Line_Start_Date,
				Lines_Record_Agg.Sub_Line_End_Date,v_precision,v_ext_precision,
				v_business_group_id);	-- Introduced BG for bug 2908859
                If retVal <> 0 Then
                        Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                End If;
        END LOOP;
        return 0;
  EXCEPTION
        when FND_API.G_EXC_UNEXPECTED_ERROR Then
                fnd_msg_pub.add_exc_msg('PSP_PI_IMPORT_DATA', 'IMPORT_PAYROLL_LINES');
                return 3;
        when others then
                fnd_msg_pub.add_exc_msg('PSP_PI_IMPORT_DATA', 'IMPORT_PAYROLL_LINES');
                return 2;
  End Import_Payroll_Lines;
  /*****************************Process_Payroll_Sub_Lines************************************
   OBJ: This is a private procedure (called internally, from Import_Payroll_Lines). This procedure
        inserts records to the PSP_PAYROLL_SUB_LINES table and creates corresponding sub_lines
        by calling the Import_Payroll_Sub_Lines procedure.
  ASSUMPTIONS: The foll. fields that are to be entered to the Payroll Lines tables have been left
                empty (ref: Subbarao, date: 03/27/98)
                ORGANIZATION_ID, JOB_ID, POSITION_ID, EMP_BEGIN_DATE, EMP_END_DATE,             EMP_STATUS_INACTIVE_DATE,EMP_STATUS_ACTIVE_DATE, ASSIGNMENT_BEGIN_DATE,         ASSIGNMENT_END_DATE
  CREATED BY:   AL ARUNACHALAM
  DATE:         03/27/98
  *****************************************************************************************/
  Function Process_Payroll_Sub_Lines(v_Batch_Name varchar2, n_Payroll_Period_ID number,
	n_Assignment_ID Number, n_Element_Type_Id Number, n_Payroll_Lines_ID Number,
	d_Sub_Line_Start_Date DATE, d_Sub_Line_End_Date DATE,
        v_precision  IN  NUMBER,v_ext_precision IN NUMBER,
	v_business_group_id IN NUMBER)		-- Introduced BG for bug 2908859
  return Number IS
    cursor Sub_Lines_Record IS
        Select  *
        From    PSP_PAYROLL_INTERFACE
        where   Batch_Name = v_batch_name
        and     PAYROLL_PERIOD_ID = n_Payroll_Period_ID
        and     ASSIGNMENT_ID = n_Assignment_ID
        and     ELEMENT_TYPE_ID = n_Element_Type_ID
	and	SUB_LINE_START_DATE = d_Sub_Line_Start_Date
	and	SUB_LINE_END_DATE = d_Sub_Line_End_Date
        and     STATUS_CODE <> 'T';
        Sub_Lines_Record_Agg Sub_Lines_Record%ROWTYPE;
        v_RowID varchar2(30);
        n_Payroll_Sub_Lines_ID Number;
        n_Current_Salary Number;
        n_Organization_ID Number;
        n_Job_ID Number;
        n_Position_ID Number;
        d_Employment_Begin_Date Date;
        d_Employment_End_Date Date;
        d_Status_Inactive_Date Date;
        d_Status_Active_Date Date;
        d_Assignment_Begin_Date Date;
        d_Assignment_End_Date Date;
        -- commented following line for 4992668
	---l_dff_grouping_option	VARCHAR2(1) DEFAULT psp_general.get_act_dff_grouping_option(v_business_group_id);	-- Introduced for bug 2908859
	l_attribute_category	VARCHAR2(30);
	l_attribute1		VARCHAR2(150);
	l_attribute2		VARCHAR2(150);
	l_attribute3		VARCHAR2(150);
	l_attribute4		VARCHAR2(150);
	l_attribute5		VARCHAR2(150);
	l_attribute6		VARCHAR2(150);
	l_attribute7		VARCHAR2(150);
	l_attribute8		VARCHAR2(150);
	l_attribute9		VARCHAR2(150);
	l_attribute10		VARCHAR2(150);
  BEGIN
        FOR Sub_Lines_Record_Agg IN Sub_Lines_Record LOOP
                  -- The Payroll Lines ID key is the current value of n_Payroll_Lines_ID
                  -- Obtain the primary key for the PSP_PAYROLL_SUB_LINES table from DUAL
                  select PSP_PAYROLL_SUB_LINES_S.nextval
                  into n_Payroll_Sub_Lines_ID
                  from DUAL;
                  -- Insert records to the PSP_PAYROLL_SUB_LINES table
                  -- Leave Organization_ID, Job_ID, Position_ID, Employment_Begin_Date,
		  -- dbms_output.put_line('Inserting into payroll sub lines table');
                  -- Employment_End_Date, Assignment Date, etc empty (Venkat 03/19/98)
		  -- Introduced extended precision for daily_rate for Bug2916948
		  -- Introduced currency_precision for pay_amount,salary_used for Bug2916848

--	Introduced the folowing for bug fix 2908859
		----IF (l_dff_grouping_option = 'Y') THEN   --- commented for 4992668
			l_attribute_category := sub_lines_record_agg.attribute_category;
			l_attribute1 := sub_lines_record_agg.attribute1;
			l_attribute2 := sub_lines_record_agg.attribute2;
			l_attribute3 := sub_lines_record_agg.attribute3;
			l_attribute4 := sub_lines_record_agg.attribute4;
			l_attribute5 := sub_lines_record_agg.attribute5;
			l_attribute6 := sub_lines_record_agg.attribute6;
			l_attribute7 := sub_lines_record_agg.attribute7;
			l_attribute8 := sub_lines_record_agg.attribute8;
			l_attribute9 := sub_lines_record_agg.attribute9;
			l_attribute10 := sub_lines_record_agg.attribute10;
		---END IF;
--	End of changes for bug fix 2908859

                retVal := Import_Payroll_Sub_Lines(v_RowID, n_Payroll_Sub_Lines_ID, n_Payroll_Lines_ID,
				Sub_Lines_Record_Agg.Sub_Line_Start_Date,
				Sub_Lines_Record_Agg.Sub_Line_End_Date,
				Sub_Lines_Record_Agg.Reason_Code,
				ROUND(Sub_Lines_Record_Agg.Pay_Amount,v_precision),
                                ROUND(Sub_Lines_Record_Agg.Daily_Rate,v_ext_precision),
				ROUND(Sub_Lines_Record_Agg.Salary_Used,v_precision),
                                n_Current_Salary, Sub_Lines_Record_Agg.FTE, n_Organization_ID, n_Job_ID,
				n_Position_ID, d_Employment_Begin_Date, d_Employment_End_Date,
				d_Status_Inactive_Date, d_Status_Active_Date, d_Assignment_Begin_Date,
				d_Assignment_End_Date,
				l_attribute_category,	-- Introduced DFF columns for bug 2908859
                                l_attribute1, l_attribute2, l_attribute3, l_attribute4, l_attribute5,
				l_attribute6, l_attribute7, l_attribute8, l_attribute9, l_attribute10);
                if retVal <> 0 Then
                  -- dbms_output.put_line('Error occured while inserting sub-line');
                  Raise FND_API.G_EXC_UNEXPECTED_ERROR;
                else
		   -- dbms_output.put_line('Successfully imported Payroll Sub Line');
                   null;
                end if;
        END LOOP;
        return 0;
  EXCEPTION
        when FND_API.G_EXC_UNEXPECTED_ERROR Then
                fnd_msg_pub.add_exc_msg('PSP_PI_IMPORT_DATA', 'PROCESS_PAYROLL_SUB_LINES');
                return 3;
        when others then
                -- dbms_output.put_line('Error occured while processing sub-lines. Error Message' ||
		-- sqlerrm);
                fnd_msg_pub.add_exc_msg('PSP_PI_IMPORT_DATA', 'PROCESS_PAYROLL_SUB_LINES');
                return 2;
  END Process_Payroll_Sub_Lines;

Function Import_Payroll_Sub_Lines(v_RowID IN OUT NOCOPY varchar2, n_Payroll_Sub_Lines_ID number,
					n_Payroll_Lines_ID Number, d_Sub_Line_Start_Date DATE,
					d_Sub_Line_End_Date Date, v_Reason_Code varchar2, n_Pay_Amount
					Number, n_Daily_Rate Number, n_Salary_Used Number,
					n_Current_Salary Number, n_FTE Number, n_Organization_ID Number,
					n_Job_ID Number, n_Position_ID Number,
					d_Employment_Begin_Date Date, d_Employment_End_Date Date,
					d_Status_Inactive_Date Date, d_Status_Active_Date Date,
					d_Assignment_Begin_Date Date, d_Assignment_End_Date Date,
--	Introduced DFF column parameters for bug 2908859
                                        p_attribute_category IN VARCHAR2, p_attribute1 IN VARCHAR2,
                                        p_attribute2 IN VARCHAR2, p_attribute3 IN VARCHAR2,
                                        p_attribute4 IN VARCHAR2, p_attribute5 IN VARCHAR2,
                                        p_attribute6 IN VARCHAR2, p_attribute7 IN VARCHAR2,
                                        p_attribute8 IN VARCHAR2, p_attribute9 IN VARCHAR2,
                                        p_attribute10 IN VARCHAR2)
Return Number IS
  Begin
          PSP_PAYROLL_SUB_LINES_PKG.INSERT_ROW (
            X_ROWID => v_RowID,
            X_PAYROLL_SUB_LINE_ID => n_Payroll_Sub_Lines_ID,
            X_PAYROLL_LINE_ID => n_Payroll_Lines_ID,
            X_SUB_LINE_START_DATE => d_Sub_Line_Start_Date,
            X_SUB_LINE_END_DATE => d_Sub_Line_End_Date,
            X_REASON_CODE => v_Reason_Code,
            X_PAY_AMOUNT => n_Pay_Amount,
            X_DAILY_RATE => n_Daily_Rate,
            X_SALARY_USED => n_Salary_Used,
            X_CURRENT_SALARY => n_Current_Salary,
            X_FTE => n_FTE,
            X_ORGANIZATION_ID => n_Organization_ID,
            X_JOB_ID => n_Job_ID,
            X_POSITION_ID => n_Position_ID,
            X_GRADE_ID    => NULL,   ---  Bug Fix  2023955
            X_PEOPLE_GRP_ID  => NULL,
            X_EMPLOYMENT_BEGIN_DATE => d_Employment_Begin_Date,
            X_EMPLOYMENT_END_DATE => d_Employment_End_Date,
            X_EMPLOYEE_STATUS_INACTIVE_DAT => d_Status_Inactive_Date,
            X_EMPLOYEE_STATUS_ACTIVE_DATE => d_Status_Active_Date,
            X_ASSIGNMENT_BEGIN_DATE => d_Assignment_Begin_Date,
            X_ASSIGNMENT_END_DATE => d_Assignment_End_Date,
            X_ATTRIBUTE_CATEGORY => p_attribute_category,		-- Introduced DFF column parameters for bug 2908859
            X_ATTRIBUTE1 => p_attribute1,
            X_ATTRIBUTE2 => p_attribute2,
            X_ATTRIBUTE3 => p_attribute3,
            X_ATTRIBUTE4 => p_attribute4,
            X_ATTRIBUTE5 => p_attribute5,
            X_ATTRIBUTE6 => p_attribute6,
            X_ATTRIBUTE7 => p_attribute7,
            X_ATTRIBUTE8 => p_attribute8,
            X_ATTRIBUTE9 => p_attribute9,
            X_ATTRIBUTE10 => p_attribute10,
            X_MODE => 'R'
          );
        -- dbms_output.put_line('Insert of row to PSP_Payroll_Sub_Lines table done successfully');
        return 0;
  Exception
        when others then
                -- dbms_output.put_line('Error occured while inserting sub-lines. Error Message' ||
		-- sqlerrm);
                fnd_msg_pub.add_exc_msg('PSP_PI_IMPORT_DATA', 'IMPORT_PAYROLL_SUB_LINES');
                return 2;
  End Import_Payroll_Sub_Lines;


  FUNCTION Check_For_Valid_Batches(v_Batch_Name         IN VARCHAR2,
				   v_business_group_id  IN NUMBER,
				   v_set_of_books_id    IN NUMBER ) return NUMBER IS
  -- Check if any invalid batch names exist in PSP_PAYROLL_INTERFACE
  -- i.e. check if any non-transferred batch exists in PSP_PAYROLL_INTERFACE
  --	that already exists in PSP_PAYROLL_CONTROLS.
  --	If it does, then inform the user about the error and exit.
  cursor C1 is
/*****	Modified the following cursor defn for R12 performance fixes (bug 4507892)
  	Select 	DISTINCT a.batch_name batch_name
	from   	PSP_PAYROLL_INTERFACE a,
		PSP_PAYROLL_CONTROLS b
	where	a.batch_name        = b.batch_name
	and	a.status_code       <> 'T'
	and	b.SOURCE_TYPE       = 'N'
	and	a.BATCH_NAME        = v_Batch_Name
	and     b.business_group_id = v_business_group_id
	and     b.set_of_books_id   = v_set_of_books_id;
	End of comment for bug fix 4507892	*****/
--	New cursor defn for bug fix 4507892
	SELECT	ppi.batch_name batch_name
	FROM	psp_payroll_interface ppi
	WHERE	ppi.batch_name = v_batch_name
	AND	ppi.business_group_id = v_business_group_id
	AND	ppi.set_of_books_id = v_set_of_books_id
	AND	ppi.status_code <> 'T'
	AND	EXISTS	(SELECT	1
			FROM	psp_payroll_controls ppc
			WHERE	ppc.batch_name = v_batch_name
			AND	ppc.SOURCE_TYPE	= 'N'
			AND	ppc.business_group_id = v_business_group_id
			AND	ppc.set_of_books_id = v_set_of_books_id);

        C1_Batch_Name PSP_PAYROLL_INTERFACE.batch_name%TYPE;
  BEGIN
   Open C1;
   LOOP
    Fetch C1 INTO C1_Batch_Name;
    Exit when c1%NOTFOUND;
    Exit;
   END LOOP;
   Close C1;

   If C1_Batch_Name IS NOT NULL Then
	fnd_message.set_name('PSP', 'PSP_PI_INVALID_BATCH_NAME');
	fnd_message.set_token('PSP_BATCH_NAME', C1_Batch_Name);
        fnd_msg_pub.add;
	return 2;
   End If;

   return 0;
  Exception
   when OTHERS then
  	fnd_msg_pub.add_exc_msg('PSP_PI_IMPORT_DATA', 'PSP_PI_INVALID_BATCH_NAME');
        return 2;
  End Check_For_Valid_Batches;

-- Introduced the function check_for_valid_currency to check whether a batch has got more than one currency
-- for Bug 2916848

 FUNCTION Check_For_Valid_Currency(v_batch_name in VARCHAR2,v_business_group_id IN NUMBER,
				    v_set_of_books_id IN NUMBER) return NUMBER IS


         CURSOR Count_currency_code_cur IS
	 SELECT COUNT(DISTINCT(NVL(currency_code,'*')))
	 FROM   PSP_PAYROLL_INTERFACE
	 WHERE  batch_name = v_batch_name
	 AND    business_group_id = v_business_group_id
         AND    set_of_books_id = v_set_of_books_id;

	 l_count_currency  NUMBER;

BEGIN

	   OPEN Count_currency_code_cur;
	   FETCH Count_currency_code_cur into l_count_currency;
	   CLOSE Count_currency_code_cur;

           IF (l_count_currency >1 ) then
             fnd_message.set_name ('PSP','PSP_PI_INVALID_CURRENCY');
   	     fnd_message.set_token('BATCH_NAME',v_batch_name);
	     fnd_msg_pub.add;
             return 2;
           END IF;

           return 0;

        EXCEPTION

           when others then
            fnd_msg_pub.add_exc_msg('PSP_PI_IMPORT_DATA','PSP_PI_INVALID_CURRENCY');
            return 2;

END Check_For_Valid_Currency;
/**** end of check for valid currency *******/

-- Introduced function get currency for batch for Bug 2916848

FUNCTION Get_Currency_For_Batch(v_batch_name  IN VARCHAR2,v_business_group_id IN NUMBER,
	  v_set_of_books_id  IN NUMBER) return VARCHAR2 IS


	CURSOR get_currency_code_cur IS
	SELECT DISTINCT(NVL(currency_code,g_bg_currency_code))
	FROM   PSP_PAYROLL_INTERFACE
	WHERE  batch_name = v_batch_name
	AND    business_group_id = v_business_group_id
	AND    set_of_books_id = v_set_of_books_id
	AND    rownum = 1;

       l_currency_code psp_payroll_interface.currency_code%type;


BEGIN

      OPEN   get_currency_code_cur;
      FETCH  get_currency_code_cur INTO l_currency_code;
      CLOSE  get_currency_code_cur;

      return (l_currency_code);

END Get_Currency_For_Batch;




END;

/
