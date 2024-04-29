--------------------------------------------------------
--  DDL for Package Body AP_CONC_PROG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CONC_PROG_PKG" AS
/* $Header: apcpreqb.pls 120.3 2004/10/27 01:29:56 pjena noship $ */

    -----------------------------------------------------------------------
    -- Procedure pay_batch_requests_finished checks whether any of the
    -- concurrent requests submitted for a payment batch are pending,
    -- currently running or inactive, and sets X_finished_flag to TRUE if no
    -- payment batch requests could run now and FALSE otherwise.
    --
    -- Drives off records in AP_CHECKRUN_CONC_PROCESSES which are loaded up
    -- as each request is submitted.  If all payment batch requests have been
    -- completed, they are deleted from the table.
    --
    PROCEDURE pay_batch_requests_finished(X_batch_name IN VARCHAR2,
					  X_calling_sequence IN VARCHAR2,
					  X_finished_flag OUT NOCOPY BOOLEAN)
    IS
        X_request_id			NUMBER;
        X_tmp_flag			BOOLEAN;
        X_call_status   		BOOLEAN;
	X_translated_phase		VARCHAR2(80);
	X_translated_status		VARCHAR2(80);
	X_phase         		VARCHAR2(80);
	X_status       			VARCHAR2(80);
	X_message       		VARCHAR2(255);
	X_debug_info			VARCHAR2(255);
	X_curr_calling_sequence		VARCHAR2(2000);

        -------------------------------------------------------------------
        -- Declare cursor to check payment batch requests
        --
        CURSOR requests_cursor IS
        SELECT request_id
        FROM   ap_checkrun_conc_processes
        WHERE  checkrun_name = X_batch_name;

    BEGIN
	X_curr_calling_sequence := 'AP_CONC_PROG_PKG.PAY_BATCH_REQUESTS_FINISHED<-' ||
				   X_calling_sequence;
	X_tmp_flag := TRUE;

	X_debug_info := 'Open requests_cursor';
        OPEN requests_cursor;

        LOOP
	    X_debug_info := 'Fetch requests_cursor';
            FETCH requests_cursor INTO X_request_id;

            EXIT WHEN requests_cursor%NOTFOUND;

            ---------------------------------------------------------------
	    -- Get payment batch request status and set X_finished_flag to
	    -- FALSE if request is PENDING, RUNNING or INACTIVE
	    --
	    X_debug_info := 'Get payment batch concurrent request status';

	    X_call_status := FND_CONCURRENT.GET_REQUEST_STATUS(X_request_id,
							       '',
							       '',
							       X_translated_phase,
							       X_translated_status,
							       X_phase,
							       X_status,
							       X_message);
	    IF (X_call_status = FALSE) THEN
	        APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;

	    IF (X_phase IN ('PENDING','RUNNING','INACTIVE')) THEN
	        X_tmp_flag := FALSE;
		EXIT;
	    END IF;

	END LOOP;

	X_debug_info := 'Close requests_cursor';
	CLOSE requests_cursor;

        -------------------------------------------------------------------
	-- Delete payment batch requests from table if all have finished
	--
	IF (X_tmp_flag = TRUE) THEN
	    X_debug_info := 'Delete requests from ap_checkrun_conc_processes';

	    DELETE FROM ap_checkrun_conc_processes
	    WHERE checkrun_name = X_batch_name;

	    COMMIT;
	END IF;

	X_finished_flag := X_tmp_flag;

    EXCEPTION
	WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',X_curr_calling_sequence);
	    FND_MESSAGE.SET_TOKEN('PARAMETERS','CHECKRUN_NAME = '||X_batch_name);
	    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',X_debug_info);
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END pay_batch_requests_finished;


    -----------------------------------------------------------------------
    -- Procedure requests_finished checks if a particular concurrent program
    -- has any pending or running requests and sets X_finished_flag to FALSE
    -- if requests are outstanding and TRUE otherwise.
    --
    -- NOTE: Sets X_finished_flag to FALSE if program is not registered.
    --
    PROCEDURE requests_finished(X_program_name IN VARCHAR2,
				X_application_name IN VARCHAR2,
				X_calling_sequence IN VARCHAR2,
				X_finished_flag OUT NOCOPY BOOLEAN)
    IS
	X_program_id     		NUMBER;
	X_application_id 		NUMBER;
	X_request_id		 	NUMBER;
        X_call_status   		BOOLEAN;
	X_translated_phase         	VARCHAR2(30);
	X_translated_status        	VARCHAR2(30);
	X_phase         		VARCHAR2(30);
	X_status        		VARCHAR2(30);
	X_message       		VARCHAR2(240);
	X_debug_info    		VARCHAR2(240);
	X_curr_calling_sequence 	VARCHAR2(2000);

        -------------------------------------------------------------------
        -- Declare cursor to check concurrent program requests
        --
	CURSOR requests_cursor IS
	SELECT request_id
	FROM   fnd_concurrent_requests
	WHERE  program_application_id = X_application_id
	AND    concurrent_program_id = X_program_id;

    BEGIN
	X_curr_calling_sequence := 'AP_CONC_PROG_PKG.REQUESTS_FINISHED<-' ||
				   X_calling_sequence;
	X_finished_flag := TRUE;

	X_debug_info := 'Get concurrent program_id and application_id';

	SELECT FCP.concurrent_program_id,
	       FCP.application_id
	INTO   X_program_id,
	       X_application_id
	FROM   fnd_concurrent_programs FCP, fnd_application FA
	WHERE  FA.application_short_name = X_application_name
	AND    FA.application_id = FCP.application_id
	AND    FCP.concurrent_program_name = X_program_name;

	X_debug_info := 'Open requests_cursor';
	OPEN requests_cursor;

	LOOP
	    X_debug_info := 'Fetch requests_cursor';
            FETCH requests_cursor INTO X_request_id;

            EXIT WHEN requests_cursor%NOTFOUND;

            ---------------------------------------------------------------
	    -- Get concurrent request status and set X_finished_flag to FALSE
	    -- if request is PENDING or RUNNING
	    --
	    X_debug_info := 'Get concurrent request status';

	    X_call_status := FND_CONCURRENT.GET_REQUEST_STATUS(X_request_id,
							       '',
							       '',
							       X_translated_phase,
							       X_translated_status,
							       X_phase,
							       X_status,
							       X_message);
	    IF (X_call_status = FALSE) THEN
	        APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;

	    IF (X_phase IN ('PENDING','RUNNING')) THEN
	        X_finished_flag := FALSE;
		EXIT;
	    END IF;

	END LOOP;

	X_debug_info := 'Close requests_cursor';
	CLOSE requests_cursor;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            X_finished_flag := FALSE;
	WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',X_curr_calling_sequence);
	    FND_MESSAGE.SET_TOKEN('PARAMETERS','PROGRAM_NAME = ' ||
							X_program_name ||
					       ', APPLICATION_NAME = ' ||
							X_application_name);
	    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',X_debug_info);
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END requests_finished;


    -----------------------------------------------------------------------
    -- Procedure execution_method returns the execution method code for a
    -- particular concurrent program.  This is used by formats that submit
    -- the Format Payments program of the payment batch.  Since users can
    -- write their own programs in any language, we need to know what type
    -- of program it is registered as in order to know how to submit the
    -- concurrent request.
    --
    -- Sets X_execution_method to R for rpts, P for srws, A for C programs,
    -- and NULL if program is not registered.
    --
    PROCEDURE execution_method(X_program_name IN VARCHAR2,
			       X_calling_sequence IN VARCHAR2,
			       X_execution_method OUT NOCOPY VARCHAR2)
    IS
	X_debug_info		 	VARCHAR2(240);
        X_curr_calling_sequence		VARCHAR2(2000);
    BEGIN
        X_curr_calling_sequence := 'AP_CONC_PROG_PKG.EXECUTION_METHOD' ||
				   X_calling_sequence;

        X_debug_info := 'Get execution method code';

	SELECT execution_method_code
	INTO   X_execution_method
	FROM   fnd_concurrent_programs
	WHERE  application_id = 200
	AND    concurrent_program_name = X_program_name;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
	    X_execution_method := NULL;
	WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',X_curr_calling_sequence);
	    FND_MESSAGE.SET_TOKEN('PARAMETERS','PROGRAM_NAME = ' || X_program_name);
	    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',X_debug_info);
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END execution_method;

    -----------------------------------------------------------------------
    -- Procedure is_program_srs returns the srs_flag for a particular
    -- concurrent program.  This is used prior submitting concurrent
    -- programs to determine whether or not a programs srs flag is set to
    -- 'N'. If it is set to 'N', then parameters passed to program must
    -- include token and "" around parameters with imbedded spaces.
    --  If this is not done, then problems can occur with NT.
    --
    ------------------------------------------------------------------------
    PROCEDURE IS_PROGRAM_SRS(X_program_name IN VARCHAR2,
			       X_calling_sequence IN VARCHAR2,
			       X_srs_flag OUT NOCOPY VARCHAR2)
    IS
	X_debug_info		 	VARCHAR2(240);
        X_curr_calling_sequence		VARCHAR2(2000);
    BEGIN
        X_curr_calling_sequence := 'AP_CONC_PROG_PKG.IS_PROGRAM_SRS' ||
				   X_calling_sequence;

        X_debug_info := 'Get SRS flag value';

	SELECT srs_flag
	INTO   X_srs_flag
	FROM   fnd_concurrent_programs_vl
	WHERE  application_id = 200
	AND    concurrent_program_name = X_program_name;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
	    X_srs_flag := NULL;
	WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
            FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',X_curr_calling_sequence);
	    FND_MESSAGE.SET_TOKEN('PARAMETERS','PROGRAM_NAME = ' || X_program_name);
	    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',X_debug_info);
	    APP_EXCEPTION.RAISE_EXCEPTION;

    END IS_PROGRAM_SRS;


END AP_CONC_PROG_PKG;

/
