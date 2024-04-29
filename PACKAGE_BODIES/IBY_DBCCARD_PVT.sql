--------------------------------------------------------
--  DDL for Package Body IBY_DBCCARD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DBCCARD_PVT" AS
/*$Header: ibyvdbcb.pls 120.4 2005/10/30 05:51:29 appldev noship $*/

--------------------------------------------------------------------------------------
                      -- Global Variable Declaration --
--------------------------------------------------------------------------------------

     G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_DBCCARD_PVT';
     g_validation_level CONSTANT NUMBER  := FND_API.G_VALID_LEVEL_FULL;

--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------

/*
The following function is a wrapper on a GL function that returns a converted amount.
If the rate is not found or the currency does not exist, GL functions a negative number.
*/
   FUNCTION Convert_Amount ( from_currency  VARCHAR2,
                             to_currency    VARCHAR2,
                             eff_date       DATE,
                             amount         NUMBER,
                             conv_type      VARCHAR2
                           ) RETURN NUMBER IS

   converted_amount NUMBER;
   BEGIN

      converted_amount := amount;

      IF( amount is NULL) THEN
         converted_amount := 0;
      END IF;

      converted_amount := GL_CURRENCY_API.CONVERT_AMOUNT_SQL( from_currency,
                                                              to_currency,
                                                              eff_date,
                                                              conv_type,
                                                              converted_amount
                                                             );

      RETURN converted_amount;

   EXCEPTION
      WHEN OTHERS THEN
         converted_amount := -1;
         RETURN converted_amount;

   END Convert_Amount;


/*
The following function filters all the statuses that are supported in this release.
It returns an appropriate value if a match is found, else it returns 'UNKNOWN'.
*/
   FUNCTION get_status_meaning ( status  NUMBER
                               ) RETURN VARCHAR2 IS

   BEGIN

      IF( status = 0 ) THEN
         RETURN C_STATUS_SUCCESS;
      ELSIF( status IN (-99,1,2,4,5,8,15,16,17,19,20,21,9999) ) THEN
         RETURN C_STATUS_FAILED;
      ELSIF( status IN (100,109,111) ) THEN
         RETURN C_STATUS_PENDING;
      ELSE
         RETURN C_STATUS_UNKNOWN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         RETURN C_STATUS_UNKNOWN;

   END get_status_meaning;

/*
The following procedure will sort the records based on the statuses.
*/

   PROCEDURE bubble_sort( l_failTemp IN OUT NOCOPY TrxnFail_tbl_type
                        ) IS

   switch TrxnFail_tbl_type;
   l_cnt PLS_INTEGER;

   BEGIN

   l_cnt := l_failTemp.COUNT;

   --sort by total_trxn
      FOR outer_loop IN 1..l_cnt LOOP
         FOR counter IN REVERSE outer_loop..l_cnt-1 LOOP
            IF (l_failTemp(counter).totalTrxn < l_failTemp(counter+1).totalTrxn) THEN
               switch(1) := l_failTemp(counter);
               l_failTemp(counter) := l_failTemp(counter+1);
               l_failTemp(counter+1) := switch(1);
            END IF;
         END LOOP;
      END LOOP;

   END bubble_sort;


/*
The following function gets the CAUSE for the error
*/

   FUNCTION get_status_cause ( status  NUMBER
                             ) RETURN VARCHAR2 IS

   BEGIN

      IF( status = -99) THEN
         RETURN 'Invalid Status';
      ELSIF( status = 1) THEN
         RETURN 'Communication Error';
      ELSIF( status = 2) THEN
         RETURN 'Duplicate Order Id';
      ELSIF( status = 4) THEN
         RETURN 'Field Missing';
      ELSIF( status = 5) THEN
         RETURN 'Back End Payment System returned Error';
      ELSIF( status = 8) THEN
         RETURN 'Status not supported';
      ELSIF( status = 15) THEN
         RETURN 'Failed to Schedule';
      ELSIF( status = 16) THEN
         RETURN 'Failed at Back End Payment System';
      ELSIF( status = 17) THEN
         RETURN 'Unable to Pay';
      ELSIF( status = 19) THEN
         RETURN 'Invalid CreditCard';
      ELSIF( status = 20) THEN
         RETURN 'Transaction Declined';
      ELSIF( status = 21) THEN
         RETURN 'Voice Authorization Required';
      ELSIF( status = 9999) THEN
         RETURN 'Timed Out';
      ELSE
         RETURN 'Unknown';
      END IF;


   EXCEPTION
      WHEN OTHERS THEN
         RETURN 'Unknown';

   END get_status_cause;


/*
The following function will either chop or pad the table so that the length is 'l_length'.
*/

   PROCEDURE get_final_padded( l_failTemp IN OUT NOCOPY TrxnFail_tbl_type,
                               l_length   IN     NUMBER
                             ) IS

   l_final_tbl TrxnFail_tbl_type;
   BEGIN

   IF( l_failTemp.COUNT = l_length ) THEN
      RETURN;
   ELSIF(l_failTemp.COUNT > l_length ) THEN
      FOR i IN 1..l_length LOOP
         l_final_tbl(i) := l_failTemp(i);
      END LOOP;
      l_failTemp := l_final_tbl;
   ELSE
      FOR i IN (l_failTemp.COUNT + 1)..l_length LOOP
         l_failTemp(i).cause := ' ';
         l_failTemp(i).columnId := i;
      END LOOP;
   END IF;

   END get_final_padded;


/*
The following function gets the DATE that should be used
depending on the period passed.
*/

   FUNCTION get_date ( l_period VARCHAR2
                     ) RETURN DATE IS

   BEGIN

   -- Set the date.
   IF ( l_period = C_PERIOD_DAILY ) THEN
      RETURN TRUNC(SYSDATE);
   ELSIF ( l_period = C_PERIOD_WEEKLY ) THEN
      -- We don't want the trailing 7 days to overlap between months.
      -- If the last 7 days also include a portion of last month then
      -- we just take data for the current month.
      IF( TO_NUMBER( TO_CHAR( SYSDATE, 'dd')) < 7 ) THEN
         RETURN TRUNC(SYSDATE, 'mm');
      ELSE
         RETURN TRUNC(SYSDATE - 6);
      END IF;
   ELSE
      RETURN TRUNC(SYSDATE, 'mm');
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
         RETURN TRUNC(SYSDATE);

   END get_date;

--------------------------------------------------------------------------------------
        -- 1. Get_Trxn_Summary
        -- Start of comments
        --   API name        : Get_Trxn_Summary
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for a trsnaction.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     period              IN    VARCHAR2            Required
        --                     summary_tbl         OUT   Summary_tbl_type
        --                     trxnSum_tbl         OUT   TrxnSum_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Trxn_Summary ( payee_id        IN    VARCHAR2,
                             period          IN    VARCHAR2,
                             summary_tbl     OUT NOCOPY Summary_tbl_type,
                             trxnSum_tbl     OUT NOCOPY TrxnSum_tbl_type
                            ) IS

   CURSOR auth_summary_csr(l_date DATE, l_payeeid VARCHAR2) IS
      SELECT  CurrencyNameCode currency,
              InstrType,
              Status,
              COUNT(*) total_trxn,
              SUM(amount) total_amt,
              TRUNC(updatedate) trxndate
      FROM iby_trxn_summaries_all
      WHERE TRUNC(updatedate) >= l_date
      AND trxntypeid IN (2,3)
      AND instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND payeeid LIKE l_payeeId
      GROUP BY INSTRTYPE,CurrencyNameCode, STATUS, TRUNC(updatedate)
      ORDER BY INSTRTYPE,STATUS ASC;

   CURSOR capt_summary_csr(l_date DATE, l_payeeid VARCHAR2) IS
      SELECT  CurrencyNameCode currency,
              InstrType,
              Status,
              COUNT(*) total_trxn,
              SUM(amount) total_amt,
              TRUNC(updatedate) trxndate
      FROM iby_trxn_summaries_all
      WHERE TRUNC(updatedate) >= l_date
      AND trxntypeid IN (3,8,9)
      AND instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND payeeid LIKE l_payeeId
      GROUP BY INSTRTYPE,CurrencyNameCode, STATUS, TRUNC(updatedate)
      ORDER BY INSTRTYPE,STATUS ASC;

   CURSOR cred_summary_csr(l_date DATE, l_payeeid VARCHAR2) IS
      SELECT  CurrencyNameCode currency,
              InstrType,
              Status,
              COUNT(*) total_trxn,
              SUM(amount) total_amt,
              TRUNC(updatedate) trxndate
      FROM iby_trxn_summaries_all
      WHERE TRUNC(updatedate) >= l_date
      AND trxntypeid IN (5,10,11)
      AND instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND payeeid LIKE l_payeeId
      GROUP BY INSTRTYPE,CurrencyNameCode, STATUS, TRUNC(updatedate)
      ORDER BY INSTRTYPE,STATUS ASC;

   CURSOR load_auth_outstand_csr(l_date DATE, l_payeeid VARCHAR2) IS
      SELECT CurrencyNameCode currency,
             COUNT(*) total_trxn,
             SUM(amount) total_amt,
             TRUNC(updatedate) trxndate
	FROM iby_trxn_summaries_all
	WHERE transactionid IN
            (
            SELECT transactionid
            FROM iby_trxn_summaries_all
            WHERE instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
            AND status = 0
            GROUP BY transactionid
            HAVING COUNT(*) = 1
            )
      AND TRUNC(updatedate) >= l_date
      AND trxntypeid = 2
      AND payeeid LIKE l_payeeid
      GROUP BY CurrencyNamecode, TRUNC(updatedate)
      ORDER BY CurrencyNameCode;

   -- All Transactions.
   l_all_trxns_no NUMBER := 0;
   l_all_trxns_amt NUMBER(38,2) := 0;

   -- Total Authorization Requests
   l_total_auth_no NUMBER := 0;
   l_total_auth_amt NUMBER(38,2) := 0;

   -- Total Capture/Settlement Requests
   l_total_capt_no NUMBER := 0;
   l_total_capt_amt NUMBER(38,2) := 0;

   -- Total Refunds/Credits Requests
   l_total_Cred_no NUMBER := 0;
   l_total_Cred_amt NUMBER(38,2) := 0;

   -- Total Authorizations Settled
   l_total_authSet_no NUMBER := 0;
   l_total_authSet_amt NUMBER(38,2) := 0;

   -- Total Authorizations Outstanding
   l_total_authOut_no NUMBER := 0;
   l_total_authOut_amt NUMBER(38,2) := 0;

   -- Total Credit Card Transactions
   l_total_ccard_no NUMBER := 0;
   l_total_ccard_amt NUMBER(38,2) := 0;

   -- Total Purchase Card Transactions
   l_total_pcard_no NUMBER := 0;
   l_total_pcard_amt NUMBER(38,2) := 0;

   -- Following are for Transaction Summary Table

   -- Authorization Requests
   l_auth_succ_no NUMBER := 0;
   l_auth_fail_no NUMBER := 0;
   l_auth_pend_no NUMBER := 0;

   -- Capture/Settlement Requests
   l_capt_succ_no NUMBER := 0;
   l_capt_fail_no NUMBER := 0;
   l_capt_pend_no NUMBER := 0;

   -- Refunds/Credits Requests
   l_cred_succ_no NUMBER := 0;
   l_cred_fail_no NUMBER := 0;
   l_cred_pend_no NUMBER := 0;

   -- other local variables
   l_updatedate DATE;
   l_payeeId VARCHAR2(80);
   l_amount NUMBER := 0;
   l_status VARCHAR2(15);

   -- Bug 3714173: reporting currency
   l_to_currency VARCHAR2(10);

BEGIN
   -- Bug 3714173: Retrieve the reporting currency
   l_to_currency := nvl(fnd_profile.value('IBY_DBC_REPORTING_CURRENCY'), 'USD');

   -- Set the payee value accordingly.
   IF( payee_id is NULL ) THEN
      l_payeeId := '%';
   ELSE
      l_payeeId := TRIM(payee_id);
   END IF;

   -- Set the date.
   l_updatedate := get_date(period);

   -- close the cursors, if it is already open.
   IF( auth_summary_csr%ISOPEN ) THEN
      CLOSE auth_summary_csr;
   END IF;

   /*  --- Processing Authorization Requests ---- */

   FOR t_auths IN auth_summary_csr( l_updatedate, l_payeeId) LOOP

      -- Bug 3714173: reporting currency is from the profile option
      -- l_amount := Convert_Amount( t_auths.currency, C_TO_CURRENCY, t_auths.trxndate, t_auths.total_amt, NULL);
      l_amount := Convert_Amount( t_auths.currency, l_to_currency, t_auths.trxndate, t_auths.total_amt, NULL);
      l_status := get_status_meaning( t_auths.status);

      -- We ignore the cases when the RATE or CURRENCY is not found.
      -- We only process if the status is supported.
      IF ( (l_amount >= 0) AND (l_status <> C_STATUS_UNKNOWN) ) THEN

         -- Add up all auths.
         l_total_auth_no := l_total_auth_no + t_auths.total_trxn;
         l_total_auth_amt := l_total_auth_amt + l_amount;

	 -- Bug 3306449: Only capture trans count.
	 -- Bug 3458221: Re-install the auth trans count.
         -- Add all creditcard or purchasecard trxns
         IF( t_auths.instrtype = C_INSTRTYPE_CREDITCARD ) THEN
            l_total_ccard_no := l_total_ccard_no + t_auths.total_trxn;
            l_total_ccard_amt := l_total_ccard_amt + l_amount;
         ELSIF( t_auths.instrtype = C_INSTRTYPE_PURCHASECARD ) THEN
            l_total_pcard_no := l_total_pcard_no + t_auths.total_trxn;
            l_total_pcard_amt := l_total_pcard_amt + l_amount;
         END IF;

         -- Add up all auths based on status.
         IF( l_status = C_STATUS_SUCCESS ) THEN
            l_auth_succ_no := l_auth_succ_no + t_auths.total_trxn;
         ELSIF( l_status = C_STATUS_FAILED ) THEN
            l_auth_fail_no := l_auth_fail_no + t_auths.total_trxn;
         ELSIF( l_status = C_STATUS_PENDING ) THEN
            l_auth_pend_no := l_auth_pend_no + t_auths.total_trxn;
         END IF;

      END IF; -- for check l_amount > 0

   END LOOP;    -- For Authorization Requests

   -- close the cursors, if it is already open.
   IF( capt_summary_csr%ISOPEN ) THEN
      CLOSE capt_summary_csr;
   END IF;

   /*  --- Processing Capture/Settlement Requests ---- */

   FOR t_capts IN capt_summary_csr( l_updatedate, l_payeeId) LOOP

      -- Bug 3714173: reporting currency is from the profile option
      -- l_amount := Convert_Amount( t_capts.currency, C_TO_CURRENCY, t_capts.trxndate, t_capts.total_amt, NULL);
      l_amount := Convert_Amount( t_capts.currency, l_to_currency, t_capts.trxndate, t_capts.total_amt, NULL);
      l_status := get_status_meaning( t_capts.status);

      -- We ignore the cases when the RATE or CURRENCY is not found.
      -- We only process if the status is supported.
      IF ( (l_amount >= 0) AND (l_status <> C_STATUS_UNKNOWN) ) THEN

         -- Add up all captures/settlements.
         l_total_capt_no := l_total_capt_no + t_capts.total_trxn;
         l_total_capt_amt := l_total_capt_amt + l_amount;

	 -- Bug 3458221: Only auth trans count in calculating totals.
         -- Add all creditcard or purchasecard trxns
	 /*
         IF( t_capts.instrtype = C_INSTRTYPE_CREDITCARD ) THEN
            l_total_ccard_no := l_total_ccard_no + t_capts.total_trxn;
            l_total_ccard_amt := l_total_ccard_amt + l_amount;
         ELSIF( t_capts.instrtype = C_INSTRTYPE_PURCHASECARD ) THEN
            l_total_pcard_no := l_total_pcard_no + t_capts.total_trxn;
            l_total_pcard_amt := l_total_pcard_amt + l_amount;
         END IF;
	 */

         -- Add up all captures based on status.
         IF( l_status = C_STATUS_SUCCESS ) THEN
            l_capt_succ_no := l_capt_succ_no + t_capts.total_trxn;
            -- Total Authorizations Settled is same as successful captures.
            l_total_authSet_no := l_total_authSet_no + t_capts.total_trxn;
            l_total_authSet_amt := l_total_authSet_amt + l_amount;
         ELSIF( l_status = C_STATUS_FAILED ) THEN
            l_capt_fail_no := l_capt_fail_no + t_capts.total_trxn;
         ELSIF( l_status = C_STATUS_PENDING ) THEN
            l_capt_pend_no := l_capt_pend_no + t_capts.total_trxn;
         END IF;

      END IF; -- for check l_amount > 0

   END LOOP;    -- For Capture/Settlement Requests

   -- close the cursors, if it is already open.
   IF( cred_summary_csr%ISOPEN ) THEN
      CLOSE cred_summary_csr;
   END IF;

   /*  --- Processing Credits/Refunds Requests ---- */

   FOR t_creds IN cred_summary_csr( l_updatedate, l_payeeId) LOOP

      -- Bug 3714173: reporting currency is from the profile option
      -- l_amount := Convert_Amount( t_creds.currency, C_TO_CURRENCY, t_creds.trxndate, t_creds.total_amt, NULL);
      l_amount := Convert_Amount( t_creds.currency, l_to_currency, t_creds.trxndate, t_creds.total_amt, NULL);
      l_status := get_status_meaning( t_creds.status);

      -- We ignore the cases when the RATE or CURRENCY is not found.
      -- We only process if the status is supported.
      IF ( (l_amount >= 0) AND (l_status <> C_STATUS_UNKNOWN) ) THEN

         -- Add up all credits/refunds.
         l_total_cred_no := l_total_cred_no + t_creds.total_trxn;
         -- we want it to be a negative number.
         l_total_cred_amt := l_total_cred_amt - l_amount;

         -- Add all creditcard or purchasecard trxns
         IF( t_creds.instrtype = C_INSTRTYPE_CREDITCARD ) THEN
            l_total_ccard_no := l_total_ccard_no + t_creds.total_trxn;
            l_total_ccard_amt := l_total_ccard_amt - l_amount;
         ELSIF( t_creds.instrtype = C_INSTRTYPE_PURCHASECARD ) THEN
            l_total_pcard_no := l_total_pcard_no + t_creds.total_trxn;
            l_total_pcard_amt := l_total_pcard_amt - l_amount;
         END IF;

         -- Add up all credits/refunds based on status.
         IF( l_status = C_STATUS_SUCCESS ) THEN
            l_cred_succ_no := l_cred_succ_no + t_creds.total_trxn;
         ELSIF( l_status = C_STATUS_FAILED ) THEN
            l_cred_fail_no := l_cred_fail_no + t_creds.total_trxn;
         ELSIF( l_status = C_STATUS_PENDING ) THEN
            l_cred_pend_no := l_cred_pend_no + t_creds.total_trxn;
         END IF;

      END IF; -- for check l_amount > 0

   END LOOP;    -- For Credits/Refunds Requests

   -- close the cursors, if it is already open.
   IF( load_auth_outstand_csr%ISOPEN ) THEN
      CLOSE load_auth_outstand_csr;
   END IF;

   /*  --- Processing Authorizations Outstanding---- */

   FOR t_outs IN load_auth_outstand_csr( l_updatedate,l_payeeId) LOOP

      -- Bug 3714173: reporting currency is from the profile option
      -- l_amount := Convert_Amount( t_outs.currency, C_TO_CURRENCY, t_outs.trxndate, t_outs.total_amt, NULL);
      l_amount := Convert_Amount( t_outs.currency, l_to_currency, t_outs.trxndate, t_outs.total_amt, NULL);

      -- We ignore the cases when the RATE or CURRENCY is not found.
      IF (l_amount >= 0) THEN
         -- Add up all records.
         l_total_authOut_no := l_total_authOut_no + t_outs.total_trxn;
         l_total_authOut_amt := l_total_authOut_amt + l_amount;
      END IF; -- for check l_amount > 0

   END LOOP; -- For Outstanding Authorizations


   -- Finally set the "All Transactions"
   -- Bug 3306449: Amount and count from auth trans are commented out.
   -- l_all_trxns_no := l_total_auth_no + l_total_capt_no + l_total_cred_no;
   -- l_all_trxns_amt := l_total_auth_amt + l_total_capt_amt + l_total_cred_amt;
   -- Bug 3458221: Switched from capt to auth.
   -- l_all_trxns_no := l_total_capt_no + l_total_cred_no;
   -- l_all_trxns_amt := l_total_capt_amt + l_total_cred_amt;
   l_all_trxns_no := l_total_auth_no + l_total_cred_no;
   l_all_trxns_amt := l_total_auth_amt + l_total_cred_amt;

   -- Populate the summary table
   summary_tbl(1).columnId := 1;
   summary_tbl(1).totalTrxn := l_all_trxns_no;
   summary_tbl(1).totalAmt := l_all_trxns_amt;

   summary_tbl(2).columnId := 2;
   summary_tbl(2).totalTrxn := l_total_auth_no;
   summary_tbl(2).totalAmt := l_total_auth_amt;

   summary_tbl(3).columnId := 3;
   summary_tbl(3).totalTrxn := l_total_capt_no;
   summary_tbl(3).totalAmt := l_total_capt_amt;

   summary_tbl(4).columnId := 4;
   summary_tbl(4).totalTrxn := l_total_cred_no;
   summary_tbl(4).totalAmt := l_total_cred_amt;

   summary_tbl(5).columnId := 5;
   summary_tbl(5).totalTrxn := l_total_authSet_no;
   summary_tbl(5).totalAmt := l_total_authSet_amt;

   summary_tbl(6).columnId := 6;
   summary_tbl(6).totalTrxn := l_total_authOut_no;
   summary_tbl(6).totalAmt := l_total_authOut_amt;

   summary_tbl(7).columnId := 7;
   summary_tbl(7).totalTrxn := l_total_ccard_no;
   summary_tbl(7).totalAmt := l_total_ccard_amt;

   summary_tbl(8).columnId := 8;
   summary_tbl(8).totalTrxn := l_total_pcard_no;
   summary_tbl(8).totalAmt := l_total_pcard_amt;

   -- Populate the Transation Summary table
   trxnSum_tbl(1).columnId := 1;
   trxnSum_tbl(1).totalReq := l_total_auth_no;
   trxnSum_tbl(1).totalSuc := l_auth_succ_no;
   trxnSum_tbl(1).totalFail := l_auth_fail_no;
   trxnSum_tbl(1).totalPend := l_auth_pend_no;

   trxnSum_tbl(2).columnId := 2;
   trxnSum_tbl(2).totalReq := l_total_capt_no;
   trxnSum_tbl(2).totalSuc := l_capt_succ_no;
   trxnSum_tbl(2).totalFail := l_capt_fail_no;
   trxnSum_tbl(2).totalPend := l_capt_pend_no;

   trxnSum_tbl(3).columnId := 3;
   trxnSum_tbl(3).totalReq := l_total_cred_no;
   trxnSum_tbl(3).totalSuc := l_cred_succ_no;
   trxnSum_tbl(3).totalFail := l_cred_fail_no;
   trxnSum_tbl(3).totalPend := l_cred_pend_no;

END Get_Trxn_Summary;

--------------------------------------------------------------------------------------
        -- 2. Get_Failure_Summary
        -- Start of comments
        --   API name        : Get_Failure_Summary
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Failures
        --   Parameters      :
        --   IN              : payee_id             IN    VARCHAR2
        --                     period               IN    VARCHAR2            Required
        --                     authFail_tbl         OUT   TrxnFail_tbl_type
        --                     settFail_tbl         OUT   TrxnFail_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Failure_Summary ( payee_id        IN    VARCHAR2,
                                period          IN    VARCHAR2,
                                authFail_tbl     OUT NOCOPY TrxnFail_tbl_type,
                                settFail_tbl     OUT NOCOPY TrxnFail_tbl_type
                               ) IS

   CURSOR get_authFail_csr( l_date DATE, l_payeeId VARCHAR2) IS
      SELECT  CurrencyNameCode currency,
              Status,
              COUNT(*) total_trxn,
              SUM(amount) total_amt,
              TRUNC(updatedate) trxndate
      FROM iby_trxn_summaries_all
      WHERE TRUNC(updatedate) >= l_date
      AND trxntypeid IN (2,3)
      AND instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND payeeid LIKE l_payeeId
      AND status IN (-99,1,2,4,5,8,15,16,17,19,20,21,9999)
      GROUP BY STATUS, CurrencyNameCode, TRUNC(updatedate)
      ORDER BY status ASC;

   CURSOR get_settFail_csr( l_date DATE, l_payeeId VARCHAR2) IS
      SELECT  CurrencyNameCode currency,
              Status,
              COUNT(*) total_trxn,
              SUM(amount) total_amt,
              TRUNC(updatedate) trxndate
      FROM iby_trxn_summaries_all
      WHERE TRUNC(updatedate) >= l_date
      AND trxntypeid IN (3,8,9)
      AND instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND payeeid LIKE l_payeeId
      AND status IN (-99,1,2,4,5,8,15,16,17,19,20,21,9999)
      GROUP BY STATUS, CurrencyNameCode, TRUNC(updatedate)
      ORDER BY status ASC;

   -- other local variables
   l_updatedate DATE;
   l_payeeId VARCHAR2(80);
   l_amount NUMBER := 0;

   l_curr_status NUMBER(15);
   l_prev_status NUMBER(15);
   l_tbl_count PLS_INTEGER;

   l_failTemp TrxnFail_tbl_type;
   l_failSett TrxnFail_tbl_type;

   -- Bug 3714173: DBC reporting currency
   l_to_currency VARCHAR2(10);

BEGIN
   -- Bug 3714173: Retrieve the reporting currency
   l_to_currency := nvl(fnd_profile.value('IBY_DBC_REPORTING_CURRENCY'), 'USD');

   -- Set the payee value accordingly.
   IF( payee_id is NULL ) THEN
      l_payeeId := '%';
   ELSE
      l_payeeId := TRIM(payee_id);
   END IF;

   -- Set the date.
   l_updatedate := get_date(period);

   -- close the cursors, if it is already open.
   IF( get_authFail_csr%ISOPEN ) THEN
      CLOSE get_authFail_csr;
   END IF;

   /*  --- Processing Authorization Failures ---- */

   -- Initialize the count
   l_tbl_count := 1;
   l_curr_status := 0;
   l_prev_status := 0;

   FOR t_auths IN get_authFail_csr( l_updatedate, l_payeeId) LOOP

      -- Bug 3714173: reporting currency is from the profile option
      -- l_amount := Convert_Amount( t_auths.currency, C_TO_CURRENCY, t_auths.trxndate, t_auths.total_amt, NULL);
      l_amount := Convert_Amount( t_auths.currency, l_to_currency, t_auths.trxndate, t_auths.total_amt, NULL);
      l_curr_status := t_auths.status;

      -- We ignore the cases when the RATE or CURRENCY is not found.
      IF ( (l_amount >= 0) ) THEN

         IF( (l_prev_status <> 0) AND (l_prev_status <> l_curr_status) ) THEN
            l_tbl_count := l_tbl_count + 1;
         END IF;

         l_failTemp(l_tbl_count).status := l_curr_status;
         l_failTemp(l_tbl_count).cause := get_status_cause(l_curr_status);
         l_failTemp(l_tbl_count).totalTrxn := l_failTemp(l_tbl_count).totalTrxn + t_auths.total_trxn;
         l_failTemp(l_tbl_count).totalAmt := l_failTemp(l_tbl_count).totalAmt + l_amount;

         -- set the prev status to curr status for the next loop.
         l_prev_status := l_curr_status;


      END IF;

   END LOOP; -- For get_authFail_csr


      /*
      l_tbl_count := 1;

      dbms_output.put_line('The TOTAL count for the table is ' || l_failTemp.count );

      WHILE( l_tbl_count <= l_failTemp.count ) LOOP
         --dbms_output.put_line('The status for ' || l_tbl_count || ' is ' || l_failTemp(l_tbl_count).status );
         dbms_output.put_line('The count for ' || l_tbl_count || ' is ' || l_failTemp(l_tbl_count).totalTrxn);
         --dbms_output.put_line('The amount for ' || l_tbl_count || ' is ' || l_failTemp(l_tbl_count).totalAmt);
         l_tbl_count := l_tbl_count + 1;
      END LOOP;
      */

      -- Sort the table and then make the length 5.
      bubble_sort(l_failTemp);
      get_final_padded(l_failTemp, 5);

      /*
      dbms_output.put_line('After bubble sort !!!!');

      l_tbl_count := 1;

      dbms_output.put_line('The toatl count for the table is ' || l_failTemp.count );

      WHILE( l_tbl_count <= l_failTemp.count ) LOOP
         --dbms_output.put_line('The status for ' || l_tbl_count || ' is ' || l_failTemp(l_tbl_count).status );
         dbms_output.put_line('The count for ' || l_tbl_count || ' is ' || l_failTemp(l_tbl_count).totalTrxn);
         --dbms_output.put_line('The amount for ' || l_tbl_count || ' is ' || l_failTemp(l_tbl_count).totalAmt);
         l_tbl_count := l_tbl_count + 1;
      END LOOP;
      */

      authFail_tbl := l_failTemp;

   /*  --- Processing Settlement/Capture Failures ---- */

   -- close the cursors, if it is already open.
   IF( get_settFail_csr%ISOPEN ) THEN
      CLOSE get_settFail_csr;
   END IF;

   -- Initialize the count
   l_tbl_count := 1;
   l_curr_status := 0;
   l_prev_status := 0;

   FOR t_auths IN get_settFail_csr( l_updatedate, l_payeeId) LOOP

      -- Bug 3714173: reporting currency is from the profile option
      -- l_amount := Convert_Amount( t_auths.currency, C_TO_CURRENCY, t_auths.trxndate, t_auths.total_amt, NULL);
      l_amount := Convert_Amount( t_auths.currency, l_to_currency, t_auths.trxndate, t_auths.total_amt, NULL);
      l_curr_status := t_auths.status;

      -- We ignore the cases when the RATE or CURRENCY is not found.
      IF ( (l_amount >= 0) ) THEN

         IF( (l_prev_status <> 0) AND (l_prev_status <> l_curr_status) ) THEN
            l_tbl_count := l_tbl_count + 1;
         END IF;

         l_failSett(l_tbl_count).status := l_curr_status;
         l_failSett(l_tbl_count).cause := get_status_cause(l_curr_status);
         l_failSett(l_tbl_count).totalTrxn := l_failSett(l_tbl_count).totalTrxn + t_auths.total_trxn;
         l_failSett(l_tbl_count).totalAmt := l_failSett(l_tbl_count).totalAmt + l_amount;

         -- set the prev status to curr status for the next loop.
         l_prev_status := l_curr_status;


      END IF;

   END LOOP; -- For get_authSett_csr


      /*
      l_tbl_count := 1;

      dbms_output.put_line('The TOTAL count for the table is ' || l_failSett.count );

      WHILE( l_tbl_count <= l_failSett.count ) LOOP
         dbms_output.put_line('The cause for ' || l_tbl_count || ' is ' || l_failSett(l_tbl_count).cause );
         dbms_output.put_line('The count for ' || l_tbl_count || ' is ' || l_failSett(l_tbl_count).totalTrxn);
         dbms_output.put_line('The amount for ' || l_tbl_count || ' is ' || l_failSett(l_tbl_count).totalAmt);
         l_tbl_count := l_tbl_count + 1;
      END LOOP;
      */

      -- Sort the table and then make the length 5.
      bubble_sort(l_failSett);
      get_final_padded(l_failSett, 5);

      /*
      dbms_output.put_line('After bubble sort !!!!');

      l_tbl_count := 1;

      dbms_output.put_line('The toatl count for the table is ' || l_failSett.count );

      WHILE( l_tbl_count <= l_failSett.count ) LOOP
         dbms_output.put_line('The cause for ' || l_tbl_count || ' is ' || l_failSett(l_tbl_count).cause );
         dbms_output.put_line('The count for ' || l_tbl_count || ' is ' || l_failSett(l_tbl_count).totalTrxn);
         dbms_output.put_line('The amount for ' || l_tbl_count || ' is ' || l_failSett(l_tbl_count).totalAmt);
         l_tbl_count := l_tbl_count + 1;
      END LOOP;
      */

      settFail_tbl := l_failSett;


END Get_Failure_Summary;


--------------------------------------------------------------------------------------
        -- 3. Get_CardType_Summary
        -- Start of comments
        --   API name        : Get_CardType_Summary
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Card Sub Types.
        --   Parameters      :
        --   IN              : payee_id             IN    VARCHAR2
        --                     period               IN    VARCHAR2            Required
        --                     cardType_tbl         OUT   TrxnFail_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_CardType_Summary ( payee_id         IN    VARCHAR2,
                                 period           IN    VARCHAR2,
                                 cardType_tbl     OUT NOCOPY TrxnFail_tbl_type
                                ) IS

   CURSOR get_CardType_csr( l_date DATE, l_payeeId VARCHAR2) IS
      SELECT  CurrencyNameCode currency,
              instrsubtype,
              -- DECODE(trxntypeid, 3, 2, 5,-1, 10, -1, 11, -1, 1) factor, -- Bug 3306449
	      -- DECODE(trxntypeid, 5, -1, 10, -1, 11, -1, 2, 0, 1) factor, -- Bug 3458221
	      DECODE(trxntypeid, 5, -1, 8, 0, 9, 0, 10, -1, 11, -1, 1) factor,
              COUNT(*) total_trxn,
              SUM(amount) total_amt,
              TRUNC(updatedate) trxndate
      FROM iby_trxn_summaries_all
      WHERE TRUNC(updatedate) >= l_date
      AND trxntypeid IN (2,3,5,8,9,10,11)
      AND instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND payeeid LIKE l_payeeId
      AND instrsubtype IS NOT NULL
      AND status IN
          (-99,0,1,2,4,5,8,15,16,17,19,20,21,100,109,111,9999)
      GROUP BY instrsubtype,
               -- DECODE(trxntypeid, 3, 2, 5,-1, 10, -1, 11, -1, 1), -- Bug 3306449
	       -- DECODE(trxntypeid, 5, -1, 10, -1, 11, -1, 2, 0, 1), -- Bug 3458221
	       DECODE(trxntypeid, 5, -1, 8, 0, 9, 0, 10, -1, 11, -1, 1),
               CurrencyNameCode, TRUNC(updatedate)
      ORDER BY UPPER(instrsubtype) ASC;

   -- other local variables
   l_updatedate DATE;
   l_payeeId VARCHAR2(80);
   l_amount NUMBER := 0;

   l_curr_subtype VARCHAR2(30);
   l_prev_subtype VARCHAR2(30);
   l_tbl_count PLS_INTEGER;

   -- Bug 3714173: DBC reporting currency
   l_to_currency VARCHAR2(10);

BEGIN
   -- Bug 3714173: Retrieve the reporting currency
   l_to_currency := nvl(fnd_profile.value('IBY_DBC_REPORTING_CURRENCY'), 'USD');

   -- Set the payee value accordingly.
   IF( payee_id is NULL ) THEN
      l_payeeId := '%';
   ELSE
      l_payeeId := TRIM(payee_id);
   END IF;

   -- Set the date.
   l_updatedate := get_date(period);

   -- close the cursors, if it is already open.
   IF( get_CardType_csr%ISOPEN ) THEN
      CLOSE get_CardType_csr;
   END IF;

   /*  --- Processing Card types ---- */

   -- Initialize the count
   l_tbl_count := 1;
   l_curr_subtype := '*';
   l_prev_subtype := '*';

   FOR t_auths IN get_CardType_csr( l_updatedate, l_payeeId) LOOP

      -- Bug 3714173: reporting currency is from the profile option
      -- l_amount := Convert_Amount( t_auths.currency, C_TO_CURRENCY, t_auths.trxndate, t_auths.total_amt, NULL);
      l_amount := Convert_Amount( t_auths.currency, l_to_currency, t_auths.trxndate, t_auths.total_amt, NULL);
      l_curr_subtype := t_auths.instrsubtype;

      -- We ignore the cases when the RATE or CURRENCY is not found.
      IF ( (l_amount >= 0) ) THEN

         IF( (l_prev_subtype <> '*') AND (l_prev_subtype <> l_curr_subtype) ) THEN
            l_tbl_count := l_tbl_count + 1;
         END IF;

         cardType_tbl(l_tbl_count).columnId := l_tbl_count;
         cardType_tbl(l_tbl_count).cause := l_curr_subtype;
	 -- Bug 3306449: The following case will not be true.
	 /*
         -- We should count a transaction twice if it is AuthCapture
         IF( t_auths.factor = 2) THEN
            cardType_tbl(l_tbl_count).totalTrxn := cardType_tbl(l_tbl_count).totalTrxn + (2 * t_auths.total_trxn);
         ELSE
            cardType_tbl(l_tbl_count).totalTrxn := cardType_tbl(l_tbl_count).totalTrxn + t_auths.total_trxn;
         END IF;
	 */
	 cardType_tbl(l_tbl_count).totalTrxn := cardType_tbl(l_tbl_count).totalTrxn
							+ abs(t_auths.factor) * t_auths.total_trxn;
         cardType_tbl(l_tbl_count).totalAmt := cardType_tbl(l_tbl_count).totalAmt + (t_auths.factor * l_amount);

         -- set the prev status to curr status for the next loop.
         l_prev_subtype := l_curr_subtype;


      END IF;

   END LOOP; -- For get_CardType_csr

END Get_CardType_Summary;

--------------------------------------------------------------------------------------
        -- 4. Get_Processor_Summary
        -- Start of comments
        --   API name        : Get_Processor_Summary
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for the Processors
        --   Parameters      :
        --   IN              : payee_id             IN    VARCHAR2
        --                     period               IN    VARCHAR2            Required
        --                     Processor_tbl         OUT   TrxnFail_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Processor_Summary ( payee_id         IN    VARCHAR2,
                                  period           IN    VARCHAR2,
                                  Processor_tbl     OUT NOCOPY TrxnFail_tbl_type
                                ) IS

   CURSOR get_Processor_csr( l_date DATE, l_payeeId VARCHAR2) IS
      SELECT  b.name,
              a.CurrencyNameCode currency,
              -- DECODE(a.trxntypeid, 3, 2, 5,-1, 10, -1, 11, -1, 1) factor, -- Bug 3306449
	      -- DECODE(a.trxntypeid, 5, -1, 10, -1, 11, -1, 2, 0, 1) factor, -- Bug 3458221
	      DECODE(a.trxntypeid, 5, -1, 8, 0, 9, 0, 10, -1, 11, -1, 1) factor,
              COUNT(*) total_trxn,
              SUM(a.amount) total_amt,
              TRUNC(a.updatedate) trxndate
      FROM    iby_trxn_summaries_all a,
              iby_bepinfo b
      WHERE TRUNC(updatedate) >= l_date
      AND a.trxntypeid IN (2,3,5,8,9,10,11)
      AND a.instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND a.payeeid LIKE l_payeeId
      AND b.bepid = a.bepid
      -- AND b.activestatus = 'Y'
      AND a.status IN
          (-99,0,1,2,4,5,8,15,16,17,19,20,21,100,109,111,9999)
      GROUP BY b.name,
               -- DECODE(a.trxntypeid, 3, 2, 5,-1, 10, -1, 11, -1, 1), -- Bug 3306449
	       -- DECODE(a.trxntypeid, 5, -1, 10, -1, 11, -1, 2, 0, 1), -- Bug 3458221
	       DECODE(a.trxntypeid, 5, -1, 8, 0, 9, 0, 10, -1, 11, -1, 1),
               a.CurrencyNameCode, TRUNC(a.updatedate)
      ORDER BY b.name ASC;

   -- other local variables
   l_updatedate DATE;
   l_payeeId VARCHAR2(80);
   l_amount NUMBER := 0;

   l_curr_processor VARCHAR2(30);
   l_prev_processor VARCHAR2(30);
   l_tbl_count PLS_INTEGER;

   -- Bug 3714173: DBC reporting currency
   l_to_currency VARCHAR2(10);

BEGIN
   -- Bug 3714173: Retrieve the reporting currency
   l_to_currency := nvl(fnd_profile.value('IBY_DBC_REPORTING_CURRENCY'), 'USD');

   -- Set the payee value accordingly.
   IF( payee_id is NULL ) THEN
      l_payeeId := '%';
   ELSE
      l_payeeId := TRIM(payee_id);
   END IF;

   -- Set the date.
   l_updatedate := get_date(period);

   -- close the cursors, if it is already open.
   IF( get_Processor_csr%ISOPEN ) THEN
      CLOSE get_Processor_csr;
   END IF;

   /*  --- Processing all Processors ---- */

   -- Initialize the count
   l_tbl_count := 1;
   l_curr_processor := '*';
   l_prev_processor := '*';

   FOR t_auths IN get_Processor_csr( l_updatedate, l_payeeId) LOOP

      -- Bug 3714173: reporting currency is from the profile option
      -- l_amount := Convert_Amount( t_auths.currency, C_TO_CURRENCY, t_auths.trxndate, t_auths.total_amt, NULL);
      l_amount := Convert_Amount( t_auths.currency, l_to_currency, t_auths.trxndate, t_auths.total_amt, NULL);

      l_curr_processor := t_auths.name;

      -- We ignore the cases when the RATE or CURRENCY is not found.
      IF ( (l_amount >= 0) ) THEN

         IF( (l_prev_processor <> '*') AND (l_prev_processor <> l_curr_processor) ) THEN
            l_tbl_count := l_tbl_count + 1;
         END IF;

         Processor_tbl(l_tbl_count).columnId := l_tbl_count;
         Processor_tbl(l_tbl_count).cause := l_curr_processor;
	 -- Bug 3306449: Only capture trxn counts.
	 /*
         -- We should count a transaction twice if it is AuthCapture
         IF( t_auths.factor = 2) THEN
            Processor_tbl(l_tbl_count).totalTrxn := Processor_tbl(l_tbl_count).totalTrxn + (2 * t_auths.total_trxn);
         ELSE
            Processor_tbl(l_tbl_count).totalTrxn := Processor_tbl(l_tbl_count).totalTrxn + t_auths.total_trxn;
         END IF;
	 */
	 Processor_tbl(l_tbl_count).totalTrxn := Processor_tbl(l_tbl_count).totalTrxn
							+ abs(t_auths.factor) *  t_auths.total_trxn;
         Processor_tbl(l_tbl_count).totalAmt := Processor_tbl(l_tbl_count).totalAmt + (t_auths.factor * l_amount);

         -- set the prev status to curr status for the next loop.
         l_prev_processor := l_curr_processor;


      END IF;

   END LOOP; -- For get_processor_csr

END Get_Processor_Summary;


--------------------------------------------------------------------------------------
        -- 5. Get_Risk_Summary
        -- Start of comments
        --   API name        : Get_Risk_Summary
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Risks
        --   Parameters      :
        --   IN              : payee_id             IN    VARCHAR2
        --                     period               IN    VARCHAR2            Required
        --                     total_screened       OUT   NUMBER
        --                     total_risky          OUT   NUMBER
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Risk_Summary ( payee_id         IN    VARCHAR2,
                             period           IN    VARCHAR2,
                             total_screened   OUT NOCOPY NUMBER,
                             total_risky      OUT NOCOPY NUMBER
                           ) IS

   CURSOR get_risk_csr( l_date DATE, l_payeeId VARCHAR2) IS
      SELECT DECODE(a.overall_score - b.threshold, 0,0,a.overall_score - b.threshold ) value,
             -- DECODE(a.trxntypeid, 3, 2, 1) factor, -- Bug 3306449
	     -- DECODE(a.trxntypeid, 2, 0, 1) factor, -- Bug 3458221
	     DECODE(a.trxntypeid, 8, 0, 9, 0, 1) factor,
             COUNT(*) total_trxn
      FROM   iby_trxn_summaries_all a,
	       iby_payee b
      WHERE  TRUNC(updatedate) >= l_date
      AND    trxntypeid IN (2,3,5,8,9,10,11)
      AND    instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND    a.payeeid = b.payeeid
      AND    b.payeeid LIKE l_payeeId
      -- AND    b.activestatus = 'Y'
      AND    b.threshold IS NOT NULL
      AND    a.overall_score IS NOT NULL
      AND    status IN (-99,0,1,2,4,5,8,15,16,17,19,20,21,100,109,111,9999)
      GROUP BY DECODE(a.overall_score - b.threshold,0,0,a.overall_score - b.threshold ),
	         -- DECODE(a.trxntypeid, 3, 2, 1) -- Bug 3306449
		 -- DECODE(a.trxntypeid, 2, 0, 1) -- Bug 3458221
		 DECODE(a.trxntypeid, 8, 0, 9, 0, 1)
      ORDER BY value ASC;

   -- other local variables
   l_updatedate DATE;
   l_payeeId VARCHAR2(80);

BEGIN

   -- Set the payee value accordingly.
   IF( payee_id is NULL ) THEN
      l_payeeId := '%';
   ELSE
      l_payeeId := TRIM(payee_id);
   END IF;

   -- Set the date.
   l_updatedate := get_date(period);

   -- close the cursors, if it is already open.
   IF( get_risk_csr%ISOPEN ) THEN
      CLOSE get_risk_csr;
   END IF;

   /*  --- Processing all Processors ---- */

   total_screened := 0;
   total_risky := 0;

   FOR t_risk IN get_risk_csr( l_updatedate, l_payeeId) LOOP
      total_screened := total_screened + (t_risk.total_trxn * t_risk.factor);
      IF ( t_risk.value < 0 ) THEN
         total_risky := total_risky + (t_risk.total_trxn * t_risk.factor);
      END IF;
   END LOOP; -- For get_risk_csr

END Get_Risk_Summary;

END IBY_DBCCARD_PVT;

/
