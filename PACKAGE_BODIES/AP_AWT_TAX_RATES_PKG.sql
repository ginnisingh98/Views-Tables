--------------------------------------------------------
--  DDL for Package Body AP_AWT_TAX_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AWT_TAX_RATES_PKG" AS
/* $Header: aptaxckb.pls 120.3 2005/05/12 06:30:38 sguddeti noship $ */

   PROCEDURE CHECK_AMOUNT_OVERLAP(X_tax_name IN VARCHAR2,
                                  X_calling_sequence In VARCHAR2) IS

     CURSOR c_rate_type(v_tax_name VARCHAR2) IS
	SELECT 	DISTINCT RATE_TYPE
	FROM    AP_AWT_TAX_RATES
	WHERE   TAX_NAME = v_tax_name
	-- For bug2995926
	-- Removing 'CERTIFICATE' and 'EXCEPTION' type in the
	-- validation.
	AND     RATE_TYPE NOT IN ('CERTIFICATE','EXCEPTION');


     CURSOR c_rate_date(v_tax_name VARCHAR2,
                        v_rate_type AP_AWT_TAX_RATES.RATE_TYPE%TYPE) IS
	SELECT	nvl(Start_date,to_date('01-01-1000','DD-MM-YYYY')),
                nvl(END_DATE,to_date('01-12-3000','DD-MM-YYYY')),
                vendor_id, --BUG 1974076
                vendor_site_id --BUG 1974076
	FROM	AP_AWT_TAX_RATES
	WHERE	TAX_NAME   = v_tax_name
	  AND	RATE_TYPE  = v_rate_type
        GROUP BY nvl(Start_date,to_date('01-01-1000','DD-MM-YYYY')),
                 nvl(END_DATE,to_date('01-12-3000','DD-MM-YYYY')),
                 vendor_id, --BUG 1974076
                 vendor_site_id; --BUG 1974076

     CURSOR c_start_end(v_tax_name VARCHAR2,
                        v_rate_type AP_AWT_TAX_RATES.RATE_TYPE%TYPE,
			v_start_dt  AP_AWT_TAX_RATES.START_DATE%TYPE,
			v_end_dt    AP_AWT_TAX_RATES.END_DATE%TYPE)  IS
	SELECT	NVL(START_AMOUNT,0),
                NVL(END_AMOUNT, 99999999999999), TAX_RATE_ID, TAX_NAME
	FROM 	AP_AWT_TAX_RATES
	WHERE	TAX_NAME      = v_tax_name
          AND	RATE_TYPE     = v_rate_type
          AND   nvl(Start_date,to_date('01-01-1000','DD-MM-YYYY')) = v_start_dt
          AND   nvl(END_DATE,to_date('01-12-3000','DD-MM-YYYY'))   = v_end_dt;

     var_start	     AP_AWT_TAX_RATES.START_AMOUNT%TYPE;
     var_end	     AP_AWT_TAX_RATES.END_AMOUNT%TYPE;
     var_rate_type   AP_AWT_TAX_RATES.RATE_TYPE%TYPE;
     var_start_dt    AP_AWT_TAX_RATES.START_DATE%TYPE;
     var_end_dt      AP_AWT_TAX_RATES.END_DATE%TYPE;
     duplicate_check NUMBER;
     num_duplicate   NUMBER;
     var_check       NUMBER;
     var_tax_id      AP_AWT_TAX_RATES.TAX_RATE_ID%TYPE;
     var_tax_name    AP_AWT_TAX_RATES.TAX_NAME%TYPE;
     var_vendor_id   AP_AWT_TAX_RATES.VENDOR_ID%TYPE;         --BUG 1974076
     var_vendor_site_id AP_AWT_TAX_RATES.VENDOR_SITE_ID%TYPE; --BUG 1974076

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

    AMOUNT_OVERLAP  EXCEPTION;
    DATE_OVERLAP  EXCEPTION;

    test1 VARCHAR2(10);
    test2 VARCHAR2(10);
    test3 VARCHAR2(10);
    test4 VARCHAR2(10);

  BEGIN
     current_calling_sequence := 'AP_AWT_TAX_RATES_PKG.CHECK_AMOUNT_OVERLAP<-'||X_calling_sequence;

     duplicate_check := 0;
     num_duplicate :=0;
     var_check := 0;
     OPEN c_rate_type(X_tax_name);
     LOOP
	FETCH c_rate_type INTO var_rate_type;
	EXIT WHEN c_rate_type%NOTFOUND;
	OPEN c_rate_date(X_tax_name, var_rate_type);

	LOOP
           FETCH c_rate_date INTO var_start_dt, var_end_dt, var_vendor_id, var_vendor_site_id;
	   EXIT WHEN c_rate_date%NOTFOUND;


	     /* The following SQL statement checks to see if the amount ranges are
		null so that we can go ahead and check for any duplicates.
		Duplicate_check gets incremented if the query finds amount ranges
		that are not null.
	     */

	      SELECT  COUNT(*)
	      INTO    duplicate_check
	      FROM    AP_AWT_TAX_RATES
	      WHERE   TAX_NAME      = X_tax_name
          	AND   RATE_TYPE     = var_rate_type
                AND   NOT (
			   START_AMOUNT IS NULL AND END_AMOUNT IS NULL
			  );

	     IF duplicate_check = 0 THEN

 	        -- For bug 2995926
 	        -- Removing vendor id conditions as it is applicable only for
 	        -- 'CERTIFICATE' and 'EXCEPTION'. We are not going to handle
 	        -- this anymore in this package.

	      SELECT  Count(*)
	      INTO num_duplicate
   	      FROM    AP_AWT_TAX_RATES
	      WHERE   TAX_NAME      = X_tax_name
 	        AND   RATE_TYPE     = var_rate_type
                AND   nvl(start_date,to_date('01-01-1000','DD-MM-YYYY'))
		      IN ( Select nvl(start_date,to_date('01-01-1000','DD-MM-YYYY'))
			   FROM ap_awt_tax_rates
			   WHERE TAX_NAME = X_tax_name /* BUG 1666209  */
		           AND RATE_TYPE = var_rate_type -- BUG 1974076
			   GROUP BY nvl(start_date,to_date('01-01-1000','DD-MM-YYYY')),
				     nvl(end_date,to_date('31-12-3000','DD-MM-YYYY'))
			   HAVING count(*)>1
			   AND nvl(end_date,to_date('31-12-3000','DD-MM-YYYY')) =
			       nvl(ap_awt_tax_rates.end_date,
					    to_date('31-12-3000','DD-MM-YYYY'))
                         )
	      ORDER BY start_date, end_date;


                 IF num_duplicate > 0 THEN   /* BUG 1666209 */
			RAISE DATE_OVERLAP;
	         END IF;

	     END IF;



	      /* The following sql statement checks to see if any of the dates lie
		 in between any other dates. If they do, then we have overlapping
		 dates in which case var_check > 0. Then, we throw an exception to
		 display an error message.
	      */

 	      -- For bug 2995926
 	      -- Removing vendor id conditions as it is applicable only for
 	      -- 'CERTIFICATE' and 'EXCEPTION'. We are not going to handle
 	      -- this anymore in this package.


	      SELECT  COUNT(*)
              INTO    var_check
   	      FROM    AP_AWT_TAX_RATES
	      WHERE   TAX_NAME      = X_tax_name
          	AND   RATE_TYPE     = var_rate_type
                AND NOT (

                       nvl(START_DATE,to_date('01-01-1000','DD-MM-YYYY')) = var_start_dt
                       AND
                       nvl(END_DATE,to_date('01-12-3000','DD-MM-YYYY')) = var_end_dt

                     ) -- current cursor row should not be counted

                AND  ( (

                        var_start_dt >= nvl(START_DATE,to_date('01-01-1000','DD-MM-YYYY'))
                        AND
		        var_start_dt <= nvl(END_DATE,to_date('01-12-3000','DD-MM-YYYY'))

                       )
		       OR
		       (

                        var_end_dt >= nvl(START_DATE,to_date('01-01-1000','DD-MM-YYYY'))
                        AND
                 	var_end_dt <= nvl(END_DATE,to_date('01-12-2999','DD-MM-YYYY'))

 		       )
                     );

	       IF var_check >0 THEN
			RAISE DATE_OVERLAP;
	       END IF;

	   OPEN c_start_end(X_tax_name,var_rate_type,var_start_dt,var_end_dt);

	   LOOP
	      FETCH c_start_end INTO var_start, var_end, var_tax_id, var_tax_name;
              EXIT WHEN c_start_end%NOTFOUND;

	      SELECT  COUNT(*)
              INTO    var_check
   	      FROM    AP_AWT_TAX_RATES
	      WHERE   TAX_NAME      = X_tax_name
          	AND   RATE_TYPE     = var_rate_type
                AND   nvl(START_DATE,to_date('01-01-1000','DD-MM-YYYY'))
                                                               = var_start_dt
                AND   nvl(END_DATE,to_date('01-12-2999','DD-MM-YYYY'))
                                                               = var_end_dt
	  	AND 	((var_start   >= START_AMOUNT  AND
			 var_start    < END_AMOUNT)
			OR
			(var_end      >  START_AMOUNT  AND
                 	var_end      <= END_AMOUNT))
		AND   TAX_RATE_ID   <> var_tax_id;
	       IF var_check >0 THEN
			RAISE AMOUNT_OVERLAP;
	       END IF;
           END LOOP;
	   CLOSE c_start_end;
	END LOOP;
	CLOSE c_rate_date;
     END LOOP;
     CLOSE c_rate_type;

    EXCEPTION
    WHEN DATE_OVERLAP THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_AWT_DATE_OVRLP');
         APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN AMOUNT_OVERLAP THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_OVERLAP1');
         APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','tax_name = '||X_tax_name);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END CHECK_AMOUNT_OVERLAP;

  PROCEDURE CHECK_AMOUNT_GAPS(X_tax_name  IN VARCHAR2,
                              X_calling_sequence IN VARCHAR2) IS

     CURSOR c_rate_type(v_tax_name VARCHAR2) IS
	SELECT 	RATE_TYPE
	FROM    AP_AWT_TAX_RATES
	WHERE   TAX_NAME = v_tax_name
	-- For bug 2995926
	-- Removing 'CERTIFICATE' and 'EXCEPTION' type in the
	-- validation.
	AND     RATE_TYPE NOT IN ('CERTIFICATE','EXCEPTION');


     CURSOR c_rate_date(v_tax_name VARCHAR2,
                       	v_rate_type AP_AWT_TAX_RATES.RATE_TYPE%TYPE) IS
	SELECT	nvl(Start_date,to_date('01-01-1000','DD-MM-YYYY')), nvl(END_DATE,to_date('01-12-1000','DD-MM-YYYY'))
	FROM	AP_AWT_TAX_RATES
	WHERE	TAX_NAME   = v_tax_name
	  AND	RATE_TYPE  = v_rate_type;

     CURSOR c_start_amount(v_tax_name VARCHAR2,
                           v_rate_type AP_AWT_TAX_RATES.RATE_TYPE%TYPE,
			   v_start_dt  AP_AWT_TAX_RATES.START_DATE%TYPE,
			   v_end_dt    AP_AWT_TAX_RATES.END_DATE%TYPE) IS
	SELECT 	START_AMOUNT
	FROM	AP_AWT_TAX_RATES
        WHERE 	TAX_NAME      = v_tax_name
          AND	RATE_TYPE     = v_rate_type
          AND	nvl(START_DATE,to_date('01-01-1000','DD-MM-YYYY'))    = v_start_dt
          AND	nvl(END_DATE,to_date('01-12-2999','DD-MM-YYYY'))      = v_end_dt
 	  AND   START_AMOUNT  <> 0;

     var_start      AP_AWT_TAX_RATES.START_AMOUNT%TYPE;
     var_rate_type  AP_AWT_TAX_RATES.RATE_TYPE%TYPE;
     var_start_dt   AP_AWT_TAX_RATES.START_DATE%TYPE;
     var_end_dt     AP_AWT_TAX_RATES.END_DATE%TYPE;
     var_check      NUMBER;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

    AMOUNT_GAP     EXCEPTION;

  BEGIN
     current_calling_sequence := 'AP_AWT_TAX_RATES_PKG.CHECK_AMOUNT_GAPS<-'||X_calling_sequence;
     var_check := 0;

     OPEN c_rate_type(X_tax_name);
     LOOP
	FETCH c_rate_type INTO var_rate_type;
	EXIT WHEN c_rate_type%NOTFOUND;
	OPEN c_rate_date(X_tax_name, var_rate_type);

	LOOP
           FETCH c_rate_date INTO var_start_dt, var_end_dt;
	   EXIT WHEN c_rate_date%NOTFOUND;
	   OPEN c_start_amount(X_tax_name, var_rate_type, var_start_dt, var_end_dt);

     	   LOOP
		FETCH c_start_amount INTO var_start;
		EXIT WHEN c_start_amount%NOTFOUND;

		SELECT  COUNT(*)
		INTO	var_check
		FROM 	AP_AWT_TAX_RATES
		WHERE 	TAX_NAME      = X_tax_name
       		  AND	RATE_TYPE     = var_rate_type
          	  AND	nvl(START_DATE,to_date('01-01-1000','DD-MM-YYYY'))    = var_start_dt
       		  AND	nvl(END_DATE,to_date('01-12-2999','DD-MM-YYYY'))      = var_end_dt
		  AND	END_AMOUNT    = var_start;
		IF var_check = 0 THEN
			RAISE AMOUNT_GAP;
		END IF;
    	   END LOOP;
     	   CLOSE c_start_amount;
	END LOOP;
	CLOSE c_rate_date;
     END LOOP;
     CLOSE c_rate_type;

    EXCEPTION
    WHEN AMOUNT_GAP THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_GAPS');
         APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','tax_name = '||X_tax_name);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END CHECK_AMOUNT_GAPS;

  PROCEDURE CHECK_LAST_AMOUNT(X_tax_name  IN VARCHAR2,
                              X_calling_sequence IN VARCHAR2) IS
     CURSOR c_rate_type(v_tax_name VARCHAR2) IS
	SELECT 	RATE_TYPE
	FROM    AP_AWT_TAX_RATES
	WHERE   TAX_NAME = v_tax_name
	-- For Bug 2995926
	-- Removing 'CERTIFICATE' and 'EXCEPTION' type in the
	-- validation.
	AND     RATE_TYPE NOT IN ('CERTIFICATE','EXCEPTION');


     CURSOR c_rate_date(v_tax_name  VARCHAR2,
                        v_rate_type AP_AWT_TAX_RATES.RATE_TYPE%TYPE) IS
	SELECT	nvl(START_DATE,to_date('01-01-1000','DD-MM-YYYY')), nvl(END_DATE,to_date('01-12-2999','DD-MM-YYYY'))
	FROM	AP_AWT_TAX_RATES
	WHERE	TAX_NAME   = v_tax_name
	  AND	RATE_TYPE  = v_rate_type;

     var_start	  AP_AWT_TAX_RATES.START_AMOUNT%TYPE;
     var_max_end  AP_AWT_TAX_RATES.START_AMOUNT%TYPE;
     var_rate_type  AP_AWT_TAX_RATES.RATE_TYPE%TYPE;
     var_start_dt   AP_AWT_TAX_RATES.START_DATE%TYPE;
     var_end_dt     AP_AWT_TAX_RATES.END_DATE%TYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

    LAST_AMOUNT_ERROR           EXCEPTION;

  BEGIN
     current_calling_sequence := 'AP_AWT_TAX_RATES_PKG.CHECK_AMOUNT_GAPS<-'||X_calling_sequence;
     var_max_end := 0;
     OPEN c_rate_type(X_tax_name);
     LOOP
	FETCH c_rate_type INTO var_rate_type;
	EXIT WHEN c_rate_type%NOTFOUND;
	OPEN c_rate_date(X_tax_name,var_rate_type);

	LOOP
           FETCH c_rate_date INTO var_start_dt, var_end_dt;
	   EXIT WHEN c_rate_date%NOTFOUND;

  	   SELECT 	START_AMOUNT
   	   INTO		var_start
    	   FROM		AP_AWT_TAX_RATES
    	   WHERE	TAX_NAME      = X_tax_name
             AND	RATE_TYPE     = var_rate_type
             AND	nvl(START_DATE,to_date('01-01-1000','DD-MM-YYYY'))    = var_start_dt
             AND	nvl(END_DATE,to_date('01-12-2999','DD-MM-YYYY'))      = var_end_dt
	     AND  	END_AMOUNT IS NULL;
     	   IF SQL%FOUND THEN
		SELECT  MAX(END_AMOUNT)
		INTO	var_max_end
		FROM 	AP_AWT_TAX_RATES
		WHERE	TAX_NAME      = X_tax_name
      		  AND	RATE_TYPE     = var_rate_type
          	  AND	nvl(START_DATE,to_date('01-01-1000','DD-MM-YYYY'))    = var_start_dt
                  AND	nvl(END_DATE,to_date('01-12-2999','DD-MM-YYYY'))      = var_end_dt;
		IF var_start <> var_max_end AND var_start <> 0 THEN
			RAISE LAST_AMOUNT_ERROR;
		END IF;
     	   END IF;
	END LOOP;
 	CLOSE c_rate_date;
     END LOOP;
     CLOSE c_rate_type;

     EXCEPTION
     WHEN LAST_AMOUNT_ERROR THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_LAST1');
         APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_LAST2');
         APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN TOO_MANY_ROWS THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_LAST3');
         APP_EXCEPTION.RAISE_EXCEPTION;
     WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','tax_name = '||X_tax_name);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
       END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;
  END CHECK_LAST_AMOUNT;

END AP_AWT_TAX_RATES_PKG;

/
