--------------------------------------------------------
--  DDL for Package Body GL_AUTOREVERSE_DATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTOREVERSE_DATE_PKG" as
/* $Header: glustarb.pls 120.5.12010000.2 2010/02/19 10:09:50 skotakar ship $ */

-- private functions
PROCEDURE get_business_day( X_Date_Rule                 VARCHAR2,
                            X_Trxn_Calendar_Id          NUMBER,
                            X_Je_Source                 VARCHAR2,
                            X_Reversal_Date    IN OUT NOCOPY   DATE) IS

  NORMAL_EXIT         EXCEPTION;

  eff_date_rule       VARCHAR2(1);
  business_day_flag   VARCHAR2(1);

  CURSOR get_effective_date_rule IS
      SELECT effective_date_rule_code
      FROM   gl_je_sources
      WHERE  je_source_name = X_Je_Source;

  CURSOR is_business_day IS
      SELECT business_day_flag
      FROM   gl_transaction_dates
      WHERE  transaction_calendar_id = X_Trxn_Calendar_Id
      AND    transaction_date = X_Reversal_Date;

  CURSOR roll_backward IS
      SELECT max(transaction_date)
      FROM   gl_transaction_dates
      WHERE  transaction_calendar_id = X_Trxn_Calendar_Id
      AND    business_day_flag = 'Y'
      AND    transaction_date <= X_Reversal_Date;

  CURSOR roll_forward IS
      SELECT min(transaction_date)
      FROM   gl_transaction_dates
      WHERE  transaction_calendar_id = X_Trxn_Calendar_Id
      AND    business_day_flag = 'Y'
      AND    transaction_date >= X_Reversal_Date;

BEGIN

    IF (X_Je_Source = 'Manual') THEN
    -- Manual source journals created by Enter Journals form
    -- should always have the business day rolled
       eff_date_rule := 'R';
    ELSE
       OPEN get_effective_date_rule;
       FETCH get_effective_date_rule INTO eff_date_rule;

       IF (get_effective_date_rule%NOTFOUND) THEN
         CLOSE get_effective_date_rule;
         Error_Buffer := 'Cannot find effective date rule for this source '
                   ||X_Je_Source;
         Raise GET_REV_PERIOD_DATE_FAILED;
       END IF;

       -- 1. Reversal date is valid when effective date rule is Leave Alone
       IF eff_date_rule = 'L' THEN
          Raise NORMAL_EXIT;
       END IF;
    END IF;

    OPEN is_business_day;
    FETCH is_business_day INTO business_day_flag;

    IF (is_business_day%NOTFOUND) THEN
      CLOSE is_business_day;
      Error_Buffer := 'The reversal date '||X_Reversal_Date||
                 ' is not in the transaction calendar.';
      Raise GET_REV_PERIOD_DATE_FAILED;
    END IF;

    -- 2. Exit normal if business day
    IF (business_day_flag = 'Y') THEN
      Raise NORMAL_EXIT;
    END IF;

    -- 3. Error out non-business day when effective date rule is fail
    IF (business_day_flag = 'N' AND eff_date_rule = 'F') THEN
       Error_Buffer := 'The reversal date '||X_Reversal_Date||
                  ' is not a business day.';
       Raise GET_REV_PERIOD_DATE_FAILED;
    END IF;

    -- 4. now the effective date can only be Roll Date
    --    Roll to find a business day
    IF X_Date_Rule = 'LAST_DAY' THEN
       OPEN roll_backward;
       FETCH roll_backward INTO X_Reversal_Date;

       IF (X_Reversal_Date IS NULL) THEN
          CLOSE roll_backward;
          Error_Buffer := 'Cannot find a business day by rolling backwards from '
                     ||X_Reversal_Date;
          Raise GET_REV_PERIOD_DATE_FAILED;
       END IF;
    ELSE
       OPEN roll_forward;
       FETCH roll_forward INTO X_Reversal_Date;

       IF (X_Reversal_Date IS NULL) THEN
          CLOSE roll_forward;
          Error_Buffer := 'Cannot find a business day by rolling forward from '
                     ||X_Reversal_Date;
          Raise GET_REV_PERIOD_DATE_FAILED;
       END IF;
    END IF;


EXCEPTION
    WHEN NORMAL_EXIT THEN
        null;
    WHEN OTHERS THEN
        Error_Buffer := 'get_business_day.'||Error_Buffer;
        Raise;
END get_business_day;

PROCEDURE get_reversal_date(X_Reversal_Period           VARCHAR2,
                            X_Adj_Period_Flag           VARCHAR2,
                            X_Period_Rule               VARCHAR2,
                            X_Date_Rule                 VARCHAR2,
                            X_Cons_Ledger               VARCHAR2,
                            X_Trxn_Calendar_Id          NUMBER,
                            X_Je_Source                 VARCHAR2,
                            X_Je_Date                   DATE,
                            X_Start_Date                DATE,
                            X_End_Date                  DATE,
                            X_Reversal_Date    IN OUT NOCOPY   DATE) IS
  NORMAL_EXIT      EXCEPTION;
  WRONG_CRITERIA   EXCEPTION;
  reversal_date    DATE;
BEGIN
      ------    ADB Consolidation Ledger  -----------
      -- When the reversal period rule is same period, use the journal's
      -- date as the reversal date. For an average journal, this should
      -- be the 1st day of the month. When the reversal period rule
      -- is NEXT_(ADJ_)PERIOD, use the 1st day of the reversal period.

      IF X_Cons_Ledger = 'Y' THEN
         IF X_Period_Rule = 'SAME_PERIOD' THEN
            reversal_date := X_Je_Date;
         ELSE
            reversal_date := X_Start_Date;
         END IF;
         Raise NORMAL_EXIT;
      END IF;

      ------    ADB Non-Consolidation Ledger ----------
      -- 1. get reversal date from date_rule

      IF X_Period_Rule = 'SAME_PERIOD' THEN

         IF X_Date_Rule = 'NEXT_DAY' THEN
            reversal_date := X_Je_Date + 1;
            IF reversal_date > X_End_Date THEN
               Error_Buffer := 'Cannot find a valid reversal date; '
                             ||'The next day '||reversal_date
                             ||' is outside the reversal period '
                             ||X_Reversal_Period||'.';

               Raise GET_REV_PERIOD_DATE_FAILED;
            END IF;
         ELSIF X_Date_Rule = 'LAST_DAY' THEN
            reversal_date := X_End_Date;
         ELSE
            Raise WRONG_CRITERIA;
         END IF;
      ELSE -- next (non-adj) period
         IF X_Date_Rule = 'FIRST_DAY' THEN
            reversal_date := X_Start_Date;
         ELSIF X_Date_Rule = 'LAST_DAY' THEN
            reversal_date := X_End_Date;
         ELSE
            Raise WRONG_CRITERIA;
         END IF;
      END IF;
      -- 2. No effective date check for Adjusting Period
      -- IF X_Adj_Period_Flag = 'Y' THEN
      --   Raise NORMAL_EXIT;
      -- END IF;

      -- 3. Check if reversal date is business day. If not, find one.
      get_business_day(X_Date_Rule, X_Trxn_Calendar_Id, X_Je_Source,
                       reversal_date);
      -- 4. Check if reversal date is still in the reversal period.
      IF (reversal_date < X_Start_Date OR reversal_date > X_End_Date) THEN
         Error_Buffer := 'Cannot find a businness day within the reversal period '||X_Reversal_Period||' as reversal date.';
         Raise GET_REV_PERIOD_DATE_FAILED;
      END IF;
      IF ( reversal_date < X_Je_Date) THEN
         Error_Buffer := 'Cannot find a valid reversal date because the first valid day is before the journal date.';
         Raise GET_REV_PERIOD_DATE_FAILED;
      END IF;

      X_Reversal_Date := reversal_date;

EXCEPTION
    WHEN NORMAL_EXIT THEN
        X_Reversal_Date := reversal_date;
    WHEN WRONG_CRITERIA THEN
        Error_Buffer := 'Invalid REVERSAL_DATE_CODE, '||X_Date_Rule||', in GL_AUTOREVERSE_OPTIONS.';
        Raise GET_REV_PERIOD_DATE_FAILED;
    WHEN OTHERS THEN
        Error_Buffer := '.get_reversal_date.'||Error_Buffer;
        Raise;
END get_reversal_date;

     -- Public Procedure

PROCEDURE get_reversal_period_date(X_Ledger_Id    	      NUMBER,
                                   X_Je_Category              VARCHAR2,
                                   X_Je_Source                VARCHAR2,
                                   X_Je_Period_Name           VARCHAR2,
                                   X_Je_Date                  DATE,
                                   X_Reversal_Method  IN OUT NOCOPY  VARCHAR2,
                                   X_Reversal_Period  IN OUT NOCOPY  VARCHAR2,
                                   X_Reversal_Date    IN OUT NOCOPY  DATE) IS
    adb_lgr           VARCHAR2(1);
    cons_lgr          VARCHAR2(1);
    trxn_calendar_id  VARCHAR2(15);
    method_code       VARCHAR2(1);
    period_rule       VARCHAR2(30);
    date_rule         VARCHAR2(30);
    reversal_period   VARCHAR2(15);
    adj_period_flag   VARCHAR2(1);
    pstatus           VARCHAR2(1);
    period_set        VARCHAR2(15);
    v_period_type        VARCHAR2(15);
    reversal_date     DATE;
    start_date        DATE;
    end_date          DATE;
    l_criteria_set_id NUMBER :=0;

    CURSOR get_lgr IS
    SELECT enable_average_balances_flag,
           consolidation_ledger_flag,
           transaction_calendar_id,
           period_set_name,
           accounted_period_type,
	   criteria_set_id
    FROM   gl_ledgers
    WHERE  ledger_id = X_Ledger_Id;

    CURSOR get_criteria IS
    SELECT decode(method_code,'C','Y','N'),
           reversal_period_code,reversal_date_code
    FROM   gl_autoreverse_options
    WHERE  criteria_set_id = l_Criteria_Set_Id
    AND    je_category_name = X_Je_Category;


    CURSOR same_period IS
    SELECT period_name,closing_status,start_date,end_date,
           adjustment_period_flag
    FROM   gl_period_statuses p
    WHERE  p.application_id = 101
    AND    p.ledger_id = X_Ledger_Id
    AND    p.period_name = X_Je_Period_Name;

    CURSOR next_period IS
    SELECT period_name, closing_status, start_date, end_date,
           adjustment_period_flag
    FROM   gl_period_statuses p1
    WHERE  p1.application_id = 101
    AND    p1.ledger_id = X_Ledger_Id
    AND    p1.effective_period_num =
     ( SELECT min(effective_period_num)
       FROM   gl_period_statuses p1
       WHERE  p1.application_id = 101
       AND    p1.ledger_id = X_Ledger_Id
       AND    p1.effective_period_num >
          ( SELECT effective_period_num
            FROM gl_period_statuses p2
            WHERE p2.application_id = 101
            AND   p2.ledger_id = X_Ledger_Id
            AND   p2.period_name = X_Je_Period_Name));

    CURSOR next_nonadj_period IS
    SELECT period_name, closing_status, start_date, end_date
    FROM   gl_period_statuses p
    WHERE  p.application_id = 101
    AND    p.ledger_id = X_Ledger_Id
    AND    p.effective_period_num =
     ( SELECT min(effective_period_num)
       FROM   gl_period_statuses p1
       WHERE  p1.application_id = 101
       AND    p1.ledger_id = X_Ledger_Id
       AND    adjustment_period_flag = 'N'
       AND    p1.effective_period_num >
          ( SELECT effective_period_num
            FROM gl_period_statuses p2
            WHERE p2.application_id = 101
            AND   p2.ledger_id = X_Ledger_Id
            AND   p2.period_name = X_Je_Period_Name));

     -- When the journal'next day falls into the next period,
     -- reverse into the next non-adj period if the journal period is non-adj,
     -- reverse into the next adjusting period if the journal period is adj.
     -- note: min() neccessary because there may be overlapping adj periods
     CURSOR next_day_to_period IS
        SELECT period_name, closing_status, start_date, end_date
        FROM   gl_period_statuses p
        WHERE  p.application_id = 101
        AND    p.ledger_id = X_Ledger_Id
        AND    p.effective_period_num =
          ( SELECT min(effective_period_num)
            FROM   gl_period_statuses p1
            WHERE  p1.application_id = 101
            AND    p1.ledger_id = X_Ledger_Id
            AND    reversal_date between p1.start_date and p1.end_date
            AND    p1.adjustment_period_flag = adj_period_flag);

BEGIN

    Error_Buffer := Null;

    OPEN get_lgr;
    FETCH get_lgr INTO adb_lgr,cons_lgr,trxn_calendar_id,
                  period_set,v_period_type,l_criteria_set_id;

    if (get_lgr%NOTFOUND) then
      CLOSE get_lgr;
      Error_Buffer := 'Cannot find ledger info for ledger id '
                      ||X_Ledger_Id;
      Raise NO_DATA_FOUND;
    end if;

    if (l_criteria_set_id IS NULL) THEN

      get_default_reversal_data
                       (X_Category_name        => X_Je_Category,
                        X_adb_lgr_flag         =>adb_lgr,
                        X_cons_lgr_flag        =>cons_lgr,
                        X_Reversal_Method_code =>method_code,
                        X_Reversal_Period_code =>period_rule,
                        X_Reversal_Date_code   =>date_rule) ;

     CLOSE get_lgr;
    else

       CLOSE get_lgr;
       OPEN get_criteria;
       FETCH get_criteria INTO method_code,period_rule,date_rule;

       if (get_criteria%NOTFOUND) then
          CLOSE get_criteria;
        Error_Buffer :=
            'Cannot find reversal criteria for je category '||X_Je_Category;
        Raise NO_DATA_FOUND;
       end if;

	CLOSE get_criteria;

    end if;

    IF (period_rule = 'NO_DEFAULT') THEN
       Raise NO_DEFAULT;
    ELSIF (period_rule = 'SAME_PERIOD') THEN

       OPEN same_period;
       FETCH same_period INTO reversal_period,pstatus,start_date,end_date,
                              adj_period_flag;
       IF (same_period%NOTFOUND) THEN

            CLOSE same_period;
            Error_Buffer := 'Invalid journal period '||X_Je_Period_Name;
            Raise GET_REV_PERIOD_DATE_FAILED;
       END IF;
       CLOSE same_period;

    ELSIF (period_rule = 'NEXT_PERIOD') THEN
       OPEN next_period;
       FETCH next_period INTO reversal_period,pstatus,start_date,end_date,
                              adj_period_flag;
       IF (next_period%NOTFOUND) THEN
            CLOSE next_period;
            Error_Buffer := 'Cannot find the next period of '||X_Je_Period_Name;
            Raise GET_REV_PERIOD_DATE_FAILED;
       END IF;

       CLOSE next_period;
    ELSIF (period_rule = 'NEXT_NON_ADJ_PERIOD') THEN
       OPEN next_nonadj_period;
       FETCH next_nonadj_period INTO reversal_period,pstatus,
                                     start_date,end_date;
       IF (next_nonadj_period%NOTFOUND) THEN
            CLOSE next_nonadj_period;
            Error_Buffer := 'Cannot find the next non-adjusting period of '||X_Je_Period_Name;
            Raise GET_REV_PERIOD_DATE_FAILED;
       END IF;
       CLOSE next_nonadj_period;
    ELSIF (period_rule = 'NEXT_DAY') THEN

     IF (adb_lgr  <> 'Y' OR
          (adb_lgr =  'Y' AND cons_lgr =  'Y')) THEN
            method_code := 'N';
            Raise NO_DEFAULT;
     ELSE

       reversal_date := X_Je_date + 1;

       -- Fetch the journal period info
       OPEN same_period;
       FETCH same_period INTO reversal_period,pstatus,start_date,end_date,
                                  adj_period_flag;

       IF (same_period%NOTFOUND) THEN
           CLOSE same_period;
           Error_Buffer := 'Invalid journal period '||X_Je_Period_Name;
           Raise GET_REV_PERIOD_DATE_FAILED;
       END IF;
       CLOSE same_period;

       -- Reset reversal date to a business day
       -- when neccessary
       -- IF adj_period_flag = 'N' THEN
           get_business_day('NEXT_DAY', trxn_calendar_id, X_Je_Source,
                       reversal_date);
       -- END IF;

      -- if the reversal is not in the journal period, find the reversal period
       IF ( reversal_date > end_date) THEN
           OPEN next_day_to_period;
           FETCH next_day_to_period INTO reversal_period,pstatus,
                                     start_date,end_date;

           IF (next_day_to_period%NOTFOUND) THEN
               --CLOSE next_day_to_period;
               /*Added this code as part of bug9295385*/
               --For the Adj journal, if the NEXT_DAY has no Adjusment period defined
               --then pick up the period from the next non-adjusting period in which
               --the NEXT_DAY falls into.
               IF adj_period_flag  = 'Y' THEN
		       OPEN next_nonadj_period;
		       FETCH next_nonadj_period INTO reversal_period,pstatus,
						     start_date,end_date;
		       IF (next_nonadj_period%NOTFOUND) THEN
			    CLOSE next_nonadj_period;
			    Error_Buffer := 'Cannot find the next non-adjusting period of '||X_Je_Period_Name;
			    Raise GET_REV_PERIOD_DATE_FAILED;
		       END IF;
		       CLOSE next_nonadj_period;
		ELSE
		/*End of Addition*/
		   CLOSE next_day_to_period;
                   Error_Buffer := 'Cannot find a reversal period for the next day '||reversal_date;
                   Raise GET_REV_PERIOD_DATE_FAILED;
                END IF;---adj flag
           END IF;
           CLOSE next_day_to_period;
       END IF;

     END IF; -- check for adb_lgr ends

    ELSE
        Error_Buffer := 'Invalid Reversal_Period_Code in GL_REVERSE_OPTIONS for '||X_Je_Category;
        Raise GET_REV_PERIOD_DATE_FAILED;
    END IF;

    IF NOT (pstatus = 'O' OR pstatus = 'F') THEN
       Error_Buffer := 'Reversal period '||reversal_period
                  ||' is not open or futur-enterable';
       Raise GET_REV_PERIOD_DATE_FAILED;
    END IF;

    IF (adb_lgr = 'Y' AND period_rule <> 'NEXT_DAY') THEN

        -- If the X_Date_Rule is NULL then default the date rules
	-- as follows. When a new criteria set is created in Journal
	-- reversal criteria form then we don't know the type of ledger
	-- and so it is not able to default the date rule.
	-- Now it is the time to default it.

      IF ((Date_Rule IS NULL) AND (cons_lgr = 'N')) THEN
         IF (X_JE_CATEGORY = 'Income Statement Close') OR
              (X_JE_CATEGORY = 'Income Offset') THEN
	       date_rule := 'LAST_DAY';
	    ELSIF (X_JE_CATEGORY = 'Balance Sheet Close') THEN
	       date_rule := 'FIRST_DAY';
         END IF;
      END IF;

      get_reversal_date(reversal_period,adj_period_flag,
                        period_rule,date_rule,cons_lgr,trxn_calendar_id,
                        X_Je_Source,X_Je_Date,start_date,end_date,
                        reversal_date);
    END IF;

    X_Reversal_Period := reversal_period;
    X_Reversal_Date := reversal_date;
    X_Reversal_Method := method_code;

    -- populate message buffer for debugging
    Error_Buffer := 'Get reversal info. Category='||X_Je_Category
                    ||',Source='||X_Je_Source
                    ||',Je Period='||X_Je_Period_Name||',Je Date='||X_Je_Date
                    ||',Reversal Method='||X_Reversal_Method
                    ||',Reversal Period='||X_Reversal_Period
                    ||',Reversal Date='||to_char(X_Reversal_Date);
EXCEPTION
    WHEN NO_DEFAULT THEN
         X_Reversal_Method := method_code;
         Error_Buffer := 'Get reversal info. Category='||X_Je_Category
                    ||',Source='||X_Je_Source
                    ||',Je Period='||X_Je_Period_Name||',Je Date='||X_Je_Date
                    ||',Reversal Method='||X_Reversal_Method
                    ||',Reversal Period Rule='||period_rule;
    WHEN GET_REV_PERIOD_DATE_FAILED THEN

         Error_Buffer :=
                    'GL_AUTOREVERSE_DATE_PKG.get_reversal_period_date.'
                    ||Error_Buffer
                    ||' Package parameters: Category='||X_Je_Category
                    ||',Source='||X_Je_Source
                    ||',Je Period='||X_Je_Period_Name||',Je Date='||X_Je_Date
                    ||',Reversal Period Rule='||period_rule
                    ||',Reversal Date Rule='||date_rule;
         Raise;
    WHEN OTHERS THEN
         Error_Buffer :=
                    'GL_AUTOREVERSE_DATE_PKG.get_reversal_period_date.'
                    ||Error_Buffer||' : '||SUBSTRB(SQLERRM,1,100)
                    ||' Package parameters: Category='||X_Je_Category
                    ||',Source='||X_Je_Source
                    ||',Je Period='||X_Je_Period_Name||',Je Date='||X_Je_Date
                    ||',Reversal Period Rule='||period_rule
                    ||',Reversal Date Rule='||date_rule;
         Raise;
         -- APP_EXCEPTION.raise_exception;
END get_reversal_period_date;

 -- Public procedure

PROCEDURE GET_DEFAULT_REVERSAL_DATA
                       (X_Category_name             VARCHAR2,
                        X_adb_lgr_flag             VARCHAR2 DEFAULT 'N',
                        X_cons_lgr_flag            VARCHAR2 DEFAULT 'N' ,
                        X_Reversal_Method_code     IN OUT NOCOPY  VARCHAR2,
                        X_Reversal_Period_code     IN OUT NOCOPY  VARCHAR2,
                        X_Reversal_Date_code       IN OUT NOCOPY  VARCHAR2) IS

   BEGIN
        IF ((X_CATEGORY_NAME = 'Income Statement Close') OR
            (X_CATEGORY_NAME = 'Income Offset')OR
             (X_CATEGORY_NAME = 'MRC Open Balances') OR
              (X_CATEGORY_NAME = 'Revalue Profit/Loss')) THEN

		 X_Reversal_Method_Code := 'Y';
        ELSE
	         X_Reversal_Method_Code := 'N';
	END IF;

        IF ((X_CATEGORY_NAME = 'Income Statement Close') OR
	     (X_CATEGORY_NAME = 'Income Offset')) THEN

    	    	 X_Reversal_Period_code := 'SAME_PERIOD';

        ELSIF (X_CATEGORY_NAME = 'Balance Sheet Close') THEN
		 X_Reversal_Period_code := 'NEXT_PERIOD';
        ELSE
		 X_Reversal_Period_code := 'NO_DEFAULT';
        END IF;

       IF (X_adb_lgr_flag = 'Y') AND
	    (X_cons_lgr_flag = 'N') THEN

         IF (X_CATEGORY_NAME = 'Income Statement Close') OR
             (X_CATEGORY_NAME = 'Income Offset') THEN

	      X_Reversal_Date_code := 'LAST_DAY';

	  ELSIF (X_CATEGORY_NAME = 'Balance Sheet Close') THEN

		X_Reversal_Date_code := 'FIRST_DAY';
          ELSE
		X_Reversal_Date_code := NULL;
          END IF;
       ELSE
		X_Reversal_Date_code := NULL;
       END IF;

   EXCEPTION
	WHEN OTHERS THEN
	  Error_Buffer := '.get_defualt_reversal_data'||Error_Buffer;
          Raise;
  END GET_DEFAULT_REVERSAL_DATA;

 -- Public procedure

PROCEDURE Get_Default_Reversal_Method
                       (X_Ledger_Id                NUMBER,
			X_Category_name            VARCHAR2,
                        X_Reversal_Method_code     IN OUT NOCOPY  VARCHAR2) IS


	adb_flag VARCHAR2(1);
        cons_flag VARCHAR2(1);
        reversal_period_rule  VARCHAR2(15);
	reversal_date_rule    VARCHAR2(15);

  BEGIN
	   SELECT DECODE(method_code,'C', 'Y', 'N'),
                  gll.enable_average_balances_flag,
           	  gll.consolidation_ledger_flag
	   INTO
		  X_Reversal_Method_code,
                  adb_flag, cons_flag
 	   FROM   GL_LEDGERS gll, GL_AUTOREVERSE_OPTIONS glao
	   WHERE  gll.ledger_id            = X_Ledger_Id
	   AND    glao.criteria_set_id(+)  = gll.Criteria_Set_Id
           AND    glao.je_category_name(+) = X_Category_Name;

          -- The following call returns at least reversal method.
	  -- Journal Import, Recurring journal programs requires
	  -- reversal method code.

	   IF (X_Reversal_Method_code IS NULL) THEN

              get_default_reversal_data
                       (X_Category_name        => X_Category_Name,
                        X_adb_lgr_flag         =>adb_flag,
                        X_cons_lgr_flag        =>cons_flag,
                        X_Reversal_Method_code =>X_Reversal_Method_code,
                        X_Reversal_Period_code =>Reversal_Period_rule ,
                        X_Reversal_Date_code   =>Reversal_Date_rule) ;
          END IF;

END Get_Default_Reversal_Method;

END GL_AUTOREVERSE_DATE_PKG;

/
