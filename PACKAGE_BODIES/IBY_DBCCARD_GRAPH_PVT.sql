--------------------------------------------------------
--  DDL for Package Body IBY_DBCCARD_GRAPH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DBCCARD_GRAPH_PVT" AS
/*$Header: ibyvgphb.pls 120.3 2005/10/30 05:49:04 appldev noship $*/

--------------------------------------------------------------------------------------
                      -- Global Variable Declaration --
--------------------------------------------------------------------------------------

     C_INSTRTYPE_CREDITCARD  CONSTANT  VARCHAR2(20) := IBY_DBCCARD_PVT.C_INSTRTYPE_CREDITCARD;
     C_INSTRTYPE_PURCHASECARD  CONSTANT  VARCHAR2(20) := IBY_DBCCARD_PVT.C_INSTRTYPE_PURCHASECARD;
     -- Bug 3714173: DBC reporting currency is from the profile option
     -- C_TO_CURRENCY CONSTANT  VARCHAR2(5) := IBY_DBCCARD_PVT.C_TO_CURRENCY;

     G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_DBCCARD_GRAPH_PVT';
     g_validation_level CONSTANT NUMBER  := FND_API.G_VALID_LEVEL_FULL;


--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
/*
The following function gets the time stirng for the hour
*/

   FUNCTION get_time_str ( hour  NUMBER
                         ) RETURN VARCHAR2 IS

   BEGIN

      IF(hour = 0) THEN
         RETURN '12am';
      ELSIF(hour = 1) THEN
         RETURN '1am';
      ELSIF(hour = 2) THEN
         RETURN '2am';
      ELSIF(hour = 3) THEN
         RETURN '3am';
      ELSIF(hour = 4) THEN
         RETURN '4am';
      ELSIF(hour = 5) THEN
         RETURN '5am';
      ELSIF(hour = 6) THEN
         RETURN '6am';
      ELSIF(hour = 7) THEN
         RETURN '7am';
      ELSIF(hour = 8) THEN
         RETURN '8am';
      ELSIF(hour = 9) THEN
         RETURN '9am';
      ELSIF(hour = 10) THEN
         RETURN '10am';
      ELSIF(hour = 11) THEN
         RETURN '11am';
      ELSIF(hour = 12) THEN
         RETURN '12pm';
      ELSIF(hour = 13) THEN
         RETURN '1pm';
      ELSIF(hour = 14) THEN
         RETURN '2pm';
      ELSIF(hour = 15) THEN
         RETURN '3pm';
      ELSIF(hour = 16) THEN
         RETURN '4pm';
      ELSIF(hour = 17) THEN
         RETURN '5pm';
      ELSIF(hour = 18) THEN
         RETURN '6pm';
      ELSIF(hour = 19) THEN
         RETURN '7pm';
      ELSIF(hour = 20) THEN
         RETURN '8pm';
      ELSIF(hour = 21) THEN
         RETURN '9pm';
      ELSIF(hour = 22) THEN
         RETURN '10pm';
      ELSE
         RETURN '11pm';
      END IF;

   END get_time_str;


/*
The following procedure pads the table.
*/

   Procedure pad_table ( tbl         IN OUT NOCOPY HourlyVol_tbl_type,
                         from_count  IN     NUMBER,
                         to_count    IN     NUMBER
                       ) IS

   BEGIN

   FOR i IN from_count..to_count LOOP
      tbl(i+1).columnId := i+1;
      tbl(i+1).time := get_time_str(i);
      tbl(i+1).totalTrxn := 0;
   END LOOP;

   END pad_table;

/*
The following procedure returns a complete table if the input table has
any missing records.
*/

   Procedure complete_table ( tbl         IN OUT NOCOPY Trends_tbl_type,
                              from_date   IN     DATE,
                              type        IN     VARCHAR2,
                              period      IN     VARCHAR2
                             ) IS

   l_final_tbl Trends_tbl_type := Trends_tbl_type();
   l_curr_date DATE;
   l_input_count PLS_INTEGER;
   l_upper_cnt PLS_INTEGER;
   l_date_format VARCHAR2(5);
   l_date_str VARCHAR2(5);
   l_date_factor PLS_INTEGER;

   BEGIN

      IF( period = C_PERIOD_YEARLY) THEN
         l_upper_cnt := 3;
         l_date_format := 'yyyy';
         l_date_str := 'yyyy';
         l_date_factor := 12;
      ELSE
         l_upper_cnt := 12;
         l_date_format := 'mm';
         l_date_str := 'MON';
         l_date_factor := 1;
      END IF;

      l_input_count := 1;

      FOR i IN 1..l_upper_cnt LOOP
         WHILE( NOT l_final_tbl.EXISTS(i)) LOOP
            l_final_tbl.EXTEND;
            l_final_tbl(l_final_tbl.COUNT).value := 0;
         END LOOP;
         l_curr_date := TRUNC(ADD_MONTHS(from_date,(i * l_date_factor)), l_date_format);
         IF( (tbl.EXISTS(l_input_count)) AND (tbl(l_input_count).tdate = l_curr_date) ) THEN
            --l_final_tbl(i) := tbl(l_input_count);
            l_final_tbl(i).month := tbl(l_input_count).month;
            l_final_tbl(i).type := tbl(l_input_count).type;
            l_final_tbl(i).tdate := tbl(l_input_count).tdate;
            l_final_tbl(i).value := tbl(l_input_count).value;
            l_input_count := l_input_count + 1;
         ELSE
            l_final_tbl(i).month := TO_CHAR(l_curr_date, l_date_str);
            l_final_tbl(i).type := type;
            l_final_tbl(i).tdate := l_curr_date;
            l_final_tbl(i).value := 0;
         END IF;

      END LOOP;

      tbl := l_final_tbl;

   END complete_table;

/*
The procedure adds the a table records to another.
*/
Procedure add_to_output( to_tbl    IN OUT NOCOPY TrxnTrends_tbl_type,
                         from_tbl  IN      Trends_tbl_type
                        )  IS
BEGIN

   FOR i IN 1..from_tbl.COUNT LOOP
      to_tbl( to_tbl.count + 1) := from_tbl(i);
   END LOOP;

End add_to_output;

/*
The procedure adds the table record values to another
table records. It assumes that the order of records is same
in both the tables.
*/
Procedure add_to_total (total_tbl    IN OUT NOCOPY Trends_tbl_type,
                        curr_tbl     IN      Trends_tbl_type
                        )  IS
BEGIN

   FOR i IN 1..12 LOOP
      WHILE( NOT total_tbl.EXISTS(i)) LOOP
         total_tbl.EXTEND;
         total_tbl(total_tbl.COUNT).value := 0;
      END LOOP;
      total_tbl(i).month := curr_tbl(i).month;
      total_tbl(i).value := total_tbl(i).value + curr_tbl(i).value;
      total_tbl(i).type := 'TOTAL';
      total_tbl(i).tdate := curr_tbl(i).tdate;
   END LOOP;

End add_to_total;

--------------------------------------------------------------------------------------
        -- 1. Get_Hourly_Volume
        -- Start of comments
        --   API name        : Get_Hourly_Volume
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for hourly transaction.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     HourlyVol_tbl       OUT   HourlyVol_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Hourly_Volume ( payee_id          IN    VARCHAR2,
                              HourlyVol_tbl     OUT NOCOPY HourlyVol_tbl_type
                            ) IS

   CURSOR hourly_volume_csr(l_payeeid VARCHAR2) IS
      SELECT COUNT(*) totalTrxn,
	     -- DECODE(trxntypeid, 3, 2, 1) factor,  -- Bug 3458221
	     DECODE(trxntypeid, 8, 0, 9, 0, 1) factor,
             TO_NUMBER(TO_CHAR(updatedate, 'hh24')) hour
      FROM   iby_trxn_summaries_all
      WHERE  TRUNC(updatedate) = TRUNC(SYSDATE)
      AND    instrtype IN ('CREDITCARD', 'PURCHASECARD')
      AND    trxntypeid IN (2,3,5,8,9,10,11)
      AND    payeeid LIKE l_payeeId
      AND    status IN
             (-99,0,1,2,4,5,8,15,16,17,19,20,21,100,109,111,9999)
      GROUP BY TO_CHAR(updatedate, 'hh24'),
	       -- DECODE(trxntypeid, 3, 2, 1) -- Bug 3458221
	       DECODE(trxntypeid, 8, 0, 9, 0, 1)
      ORDER BY hour ASC;

   l_payeeid VARCHAR2(80);
   l_prev_hour NUMBER;
   l_curr_hour NUMBER;

BEGIN

   -- Set the payee value accordingly.
   IF( payee_id is NULL ) THEN
      l_payeeId := '%';
   ELSE
      l_payeeId := TRIM(payee_id);
   END IF;

   -- close the cursors, if it is already open.
   IF( hourly_volume_csr%ISOPEN ) THEN
      CLOSE hourly_volume_csr;
   END IF;

   /*  --- Processing begins ---- */

   l_prev_hour := -1;
   l_curr_hour := 0;

   FOR t_vol IN hourly_volume_csr(l_payeeId) LOOP

      l_curr_hour := t_vol.hour;

      IF( (l_curr_hour - l_prev_hour) > 1 ) THEN
         pad_table( HourlyVol_tbl, l_prev_hour+1, l_curr_hour -1);
      END IF;

      HourlyVol_tbl(l_curr_hour+1).columnId := l_curr_hour+1;
      HourlyVol_tbl(l_curr_hour+1).time := get_time_str(l_curr_hour);
      HourlyVol_tbl(l_curr_hour+1).totalTrxn := HourlyVol_tbl(l_curr_hour+1).totalTrxn +
                                                (t_vol.totalTrxn * t_vol.factor);


      l_prev_hour := l_curr_hour;

   END LOOP;

   IF( HourlyVol_tbl.count < 24 ) THEN
      pad_table( HourlyVol_tbl, HourlyVol_tbl.count, 23);
   END IF;

   For i IN 1..HourlyVol_tbl.count loop
      NULL;
      -- dbms_output.put_line('The Columns are  ' || HourlyVol_tbl(i).totalTrxn || ' : ' || HourlyVol_tbl(i).time );
      -- dbms_output.put_line('The time is ' || HourlyVol_tbl(i).time );
   end loop;

END Get_Hourly_Volume;

--------------------------------------------------------------------------------------
        -- 2. Get_Trxn_Trends
        -- Start of comments
        --   API name        : Get_Trxn_Trends
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Credit/Purchase Cards.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     output_type         IN    VARCHAR2
        --                     TrxnTrend_tbl       OUT   TrxnTrends_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Trxn_Trends ( payee_id          IN    VARCHAR2,
                            output_type       IN    VARCHAR2,
                            TrxnTrend_tbl     OUT NOCOPY TrxnTrends_tbl_type
                            ) IS

   CURSOR get_trends_csr( from_date DATE, to_date DATE, l_payeeId VARCHAR2) IS
      SELECT  CurrencyNameCode currency,
              instrtype type,
              -- DECODE(trxntypeid, 3, 2, 5,-1, 10, -1, 11, -1, 1) factor, -- Bug 3458221
	      DECODE(trxntypeid, 5, -1, 8, 0, 9, 0, 10, -1, 11, -1, 1) factor,
              COUNT(*) total_trxn,
              SUM(amount) total_amt,
              TRUNC(updatedate) trxndate
      FROM iby_trxn_summaries_all
      WHERE TRUNC(updatedate) > from_date
      AND TRUNC(updatedate) <= to_date
      AND trxntypeid IN (2,3,5,8,9,10,11)
      AND instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND payeeid LIKE l_payeeId
      AND status IN
          (-99,0,1,2,4,5,8,15,16,17,19,20,21,100,109,111,9999)
      GROUP BY instrtype,
               -- DECODE(trxntypeid, 3, 2, 5,-1, 10, -1, 11, -1, 1), -- Bug 3458221
	       DECODE(trxntypeid, 5, -1, 8, 0, 9, 0, 10, -1, 11, -1, 1),
               CurrencyNameCode, TRUNC(updatedate)
      ORDER BY instrtype, TRUNC(updatedate) ASC;

   l_from_date DATE;
   l_to_date DATE;
   l_curr_date DATE := NULL;
   l_prev_date DATE := NULL;
   l_curr_type VARCHAR2(100);
   l_prev_type VARCHAR2(100);
   returnAmount boolean := FALSE;
   l_currType_tbl Trends_tbl_type := Trends_tbl_type();
   l_total_tbl Trends_tbl_type := Trends_tbl_type();
   l_amount NUMBER := 0;

   l_tbl_count PLS_INTEGER;
   l_payeeId VARCHAR2(80);

   -- Bug 3714173: reporting currency
   l_to_currency VARCHAR2(10);

BEGIN
   -- Bug 3714173: Retrieve the reporting currency
   l_to_currency := nvl(fnd_profile.value('IBY_DBC_REPORTING_CURRENCY'), 'USD');

   -- Check whether 'amount' or 'transactions' need to be returned.
   returnAmount := (output_type = C_OUTPUTTYPE_AMOUNT);

   -- Set the dates appropriately
   l_from_date := LAST_DAY(ADD_MONTHS(SYSDATE, -13));
   l_to_date := LAST_DAY(ADD_MONTHS(SYSDATE, -1));

   -- Set the payee if it is null.
   IF( payee_id IS NULL OR TRIM(payee_id) = '') THEN
      l_payeeId := '%';
   ELSE
      l_payeeId := payee_id;
   END IF;

   /*  --- Processing Card types ---- */

   -- Initialize the count
   l_tbl_count := 1;
   l_curr_type := '*';
   l_prev_type := '*';

   FOR t_type IN get_trends_csr( l_from_date, l_to_date, l_payeeId) LOOP
      l_amount := IBY_DBCCARD_PVT.Convert_Amount( t_type.currency,
                                                  -- C_TO_CURRENCY,
  						  l_to_currency,
                                                  t_type.trxndate,
                                                  t_type.total_amt,
                                                  NULL);

      -- We ignore the cases when the RATE or CURRENCY is not found.
      IF ( (l_amount >= 0) ) THEN

         l_curr_date := TRUNC(t_type.trxndate, 'mm');
         l_curr_type := t_type.type;

         IF( (l_prev_type <> '*') AND (l_prev_type <> l_curr_type) ) THEN
            complete_table( l_currType_tbl, l_from_date, l_prev_type, C_PERIOD_MONTHLY);
            add_to_output( TrxnTrend_tbl, l_currType_tbl);
            add_to_total( l_total_tbl, l_currType_tbl);
            l_currType_tbl.TRIM(l_currType_tbl.COUNT);
            -- Initialize the values
            l_tbl_count := 1;
            l_curr_date := NULL;
            l_prev_date := NULL;
         END IF;

         l_prev_type := l_curr_type;

         IF( (l_prev_date IS NOT NULL) AND (l_prev_date <> l_curr_date) ) THEN
            l_tbl_count := l_tbl_count + 1;
         END IF;

         WHILE (NOT l_currType_tbl.EXISTS(l_tbl_COUNT) ) LOOP
            l_currType_tbl.EXTEND;
            l_currTYpe_tbl(l_currTYpe_tbl.COUNT).value := 0;
         END LOOP;

         l_prev_date := l_curr_date;

         l_currType_tbl(l_tbl_count).month := TO_CHAR(l_curr_date, 'MON');

         IF( returnAmount ) THEN
            l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + (t_type.total_amt * t_type.factor);
         ELSE
            -- We should count a transaction twice if it is AuthCapture
	    /* -- Bug 3458221: Only auth trans count, and capt trans are excluded.
            IF( t_type.factor = 2) THEN
               l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + (2 * t_type.total_trxn);
            ELSE
               l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + t_type.total_trxn;
            END IF;
	    */
	    l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + abs(t_type.factor) *  t_type.total_trxn;
         END IF;
         l_currType_tbl(l_tbl_count).type := t_type.type;
         l_currType_tbl(l_tbl_count).tdate := l_curr_date;

      END IF;
   END LOOP;

   IF( l_curr_type = '*' ) THEN
      l_curr_type := 'No Records Found';
      complete_table( l_currType_tbl, l_from_date, l_curr_type, C_PERIOD_MONTHLY);
      add_to_output( TrxnTrend_tbl, l_currType_tbl);
   ELSE
      complete_table( l_currType_tbl, l_from_date, l_curr_type, C_PERIOD_MONTHLY);
      add_to_output( TrxnTrend_tbl, l_currType_tbl);
      add_to_total( l_total_tbl, l_currType_tbl);

      add_to_output( TrxnTrend_tbl, l_total_tbl);
   END IF;


END Get_Trxn_Trends;

--------------------------------------------------------------------------------------
        -- 3. Get_Processor_Trends
        -- Start of comments
        --   API name        : Get_Processor_Trends
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Processors.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     output_type         IN    VARCHAR2
        --                     TrxnTrend_tbl       OUT   TrxnTrends_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Processor_Trends ( payee_id          IN    VARCHAR2,
                                 output_type       IN    VARCHAR2,
                                 TrxnTrend_tbl     OUT NOCOPY TrxnTrends_tbl_type
                               ) IS

   CURSOR get_trends_csr( from_date DATE, to_date DATE, l_payeeId VARCHAR2) IS
      SELECT  a.CurrencyNameCode currency,
              b.name TYPE,
              -- DECODE(a.trxntypeid, 3, 2, 5,-1, 10, -1, 11, -1, 1) factor, -- Bug 3458221
	      DECODE(a.trxntypeid, 5, -1, 8, 0, 9, 0, 10, -1, 11, -1, 1) factor,
              COUNT(*) total_trxn,
              SUM(a.amount) total_amt,
              TRUNC(a.updatedate) trxndate
      FROM   iby_trxn_summaries_all a,
	       iby_bepinfo b
      WHERE TRUNC(a.updatedate) > from_date
      AND TRUNC(a.updatedate) <= to_date
      AND a.trxntypeid IN (2,3,5,8,9,10,11)
      AND a.instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND a.payeeid LIKE l_payeeId
      AND a.bepid = b.bepid
      AND a.status IN
          (-99,0,1,2,4,5,8,15,16,17,19,20,21,100,109,111,9999)
      GROUP BY b.name,
               -- DECODE(a.trxntypeid, 3, 2, 5,-1, 10, -1, 11, -1, 1), -- Bug 3458221
	       DECODE(a.trxntypeid, 5, -1, 8, 0, 9, 0, 10, -1, 11, -1, 1),
               a.CurrencyNameCode, TRUNC(a.updatedate)
      ORDER BY b.name, TRUNC(a.updatedate) ASC;

   l_from_date DATE;
   l_to_date DATE;
   l_curr_date DATE := NULL;
   l_prev_date DATE := NULL;
   l_curr_type VARCHAR2(100);
   l_prev_type VARCHAR2(100);
   returnAmount boolean := FALSE;
   l_currType_tbl Trends_tbl_type := Trends_tbl_type();
   --l_total_tbl Trends_tbl_type := Trends_tbl_type();
   l_amount NUMBER := 0;

   l_tbl_count PLS_INTEGER;
   l_payeeId VARCHAR2(80);

   -- Bug 3714173: reporting currency
   l_to_currency VARCHAR2(10);

BEGIN
   -- Bug 3714173: Retrieve the reporting currency
   l_to_currency := nvl(fnd_profile.value('IBY_DBC_REPORTING_CURRENCY'), 'USD');

   -- Check whether 'amount' or 'transactions' need to be returned.
   returnAmount := (output_type = C_OUTPUTTYPE_AMOUNT);

   -- Set the dates appropriately
   l_from_date := LAST_DAY(ADD_MONTHS(SYSDATE, -13));
   l_to_date := LAST_DAY(ADD_MONTHS(SYSDATE, -1));

   -- Set the payee if it is null.
   IF( payee_id IS NULL OR TRIM(payee_id) = '') THEN
      l_payeeId := '%';
   ELSE
      l_payeeId := payee_id;
   END IF;

   /*  --- Processing Processor types ---- */

   -- Initialize the count
   l_tbl_count := 1;
   l_curr_type := '*';
   l_prev_type := '*';

   FOR t_type IN get_trends_csr( l_from_date, l_to_date, l_payeeId) LOOP
      l_amount := IBY_DBCCARD_PVT.Convert_Amount( t_type.currency,
                                                  -- C_TO_CURRENCY,
 						  l_to_currency,
                                                  t_type.trxndate,
                                                  t_type.total_amt,
                                                  NULL);

      -- We ignore the cases when the RATE or CURRENCY is not found.
      IF ( (l_amount >= 0) ) THEN

         l_curr_date := TRUNC(t_type.trxndate, 'mm');
         l_curr_type := t_type.type;

         IF( (l_prev_type <> '*') AND (l_prev_type <> l_curr_type) ) THEN
            complete_table( l_currType_tbl, l_from_date, l_prev_type, C_PERIOD_MONTHLY);
            add_to_output( TrxnTrend_tbl, l_currType_tbl);
            l_currType_tbl.TRIM(l_currType_tbl.COUNT);
            -- Initialize the values
            l_tbl_count := 1;
            l_curr_date := NULL;
            l_prev_date := NULL;
         END IF;

         l_prev_type := l_curr_type;

         IF( (l_prev_date IS NOT NULL) AND (l_prev_date <> l_curr_date) ) THEN
            l_tbl_count := l_tbl_count + 1;
         END IF;

         WHILE (NOT l_currType_tbl.EXISTS(l_tbl_COUNT) ) LOOP
            l_currType_tbl.EXTEND;
            l_currTYpe_tbl(l_currTYpe_tbl.COUNT).value := 0;
         END LOOP;

         l_prev_date := l_curr_date;

         l_currType_tbl(l_tbl_count).month := TO_CHAR(l_curr_date, 'MON');

         IF( returnAmount ) THEN
            l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + (t_type.total_amt * t_type.factor);
         ELSE
            -- We should count a transaction twice if it is AuthCapture
	    /* -- Bug 3458221: Only auth trans count and capt trans are excluded.
            IF( t_type.factor = 2) THEN
               l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + (2 * t_type.total_trxn);
            ELSE
               l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + t_type.total_trxn;
            END IF;
	    */
	    l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + abs(t_type.factor) * t_type.total_trxn;
         END IF;
         l_currType_tbl(l_tbl_count).type := t_type.type;
         l_currType_tbl(l_tbl_count).tdate := l_curr_date;

      END IF;
   END LOOP;

   IF ( l_curr_type = '*' ) THEN
      l_curr_type := 'No Records Found';
   END IF;

   complete_table( l_currType_tbl, l_from_date, l_curr_type, C_PERIOD_MONTHLY);
   add_to_output( TrxnTrend_tbl, l_currType_tbl);


END Get_Processor_Trends;

--------------------------------------------------------------------------------------
        -- 4. Get_Subtype_Trends
        -- Start of comments
        --   API name        : Get_Subtype_Trends
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Credit/Purchase SubTypes.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     output_type         IN    VARCHAR2
        --                     TrxnTrend_tbl       OUT   TrxnTrends_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Subtype_Trends ( payee_id          IN    VARCHAR2,
                               output_type       IN    VARCHAR2,
                               TrxnTrend_tbl     OUT NOCOPY TrxnTrends_tbl_type
                               ) IS

   CURSOR get_trends_csr( from_date DATE, to_date DATE, l_payeeId VARCHAR2) IS
	SELECT  CurrencyNameCode currency,
              instrsubtype TYPE,
              -- DECODE(trxntypeid, 3, 2, 5,-1, 10, -1, 11, -1, 1) factor, -- Bug 3458221
	      DECODE(trxntypeid, 5, -1, 8, 0, 9, 0, 10, -1, 11, -1, 1) factor,
              COUNT(*) total_trxn,
              SUM(amount) total_amt,
              TRUNC(updatedate) trxndate
      FROM iby_trxn_summaries_all
      WHERE TRUNC(updatedate) > from_date
      AND TRUNC(updatedate) <= TO_DATE
      AND trxntypeid IN (2,3,5,8,9,10,11)
      AND instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND instrsubtype IS NOT NULL
      AND payeeid LIKE l_payeeId
      AND status IN
          (-99,0,1,2,4,5,8,15,16,17,19,20,21,100,109,111,9999)
      GROUP BY instrsubtype,
               -- DECODE(trxntypeid, 3, 2, 5,-1, 10, -1, 11, -1, 1), -- Bug 3458221
	       DECODE(trxntypeid, 5, -1, 8, 0, 9, 0, 10, -1, 11, -1, 1),
               CurrencyNameCode, TRUNC(updatedate)
      ORDER BY instrsubtype, TRUNC(updatedate) ASC;

   l_from_date DATE;
   l_to_date DATE;
   l_curr_date DATE := NULL;
   l_prev_date DATE := NULL;
   l_curr_type VARCHAR2(100);
   l_prev_type VARCHAR2(100);
   returnAmount boolean := FALSE;
   l_currType_tbl Trends_tbl_type := Trends_tbl_type();
   --l_total_tbl Trends_tbl_type := Trends_tbl_type();
   l_amount NUMBER := 0;

   l_tbl_count PLS_INTEGER;
   l_payeeId VARCHAR2(80);

   -- Bug 3714173: reporting currency
   l_to_currency VARCHAR2(10);

BEGIN
   -- Bug 3714173: Retrieve the reporting currency
   l_to_currency := nvl(fnd_profile.value('IBY_DBC_REPORTING_CURRENCY'), 'USD');

   -- Check whether 'amount' or 'transactions' need to be returned.
   returnAmount := (output_type = C_OUTPUTTYPE_AMOUNT);

   -- Set the dates appropriately
   l_from_date := LAST_DAY(ADD_MONTHS(SYSDATE, -13));
   l_to_date := LAST_DAY(ADD_MONTHS(SYSDATE, -1));

   -- Set the payee if it is null.
   IF( payee_id IS NULL OR TRIM(payee_id) = '') THEN
      l_payeeId := '%';
   ELSE
      l_payeeId := payee_id;
   END IF;

   /*  --- Processing Processor types ---- */

   -- Initialize the count
   l_tbl_count := 1;
   l_curr_type := '*';
   l_prev_type := '*';

   FOR t_type IN get_trends_csr( l_from_date, l_to_date, l_payeeId) LOOP
      l_amount := IBY_DBCCARD_PVT.Convert_Amount( t_type.currency,
                                                  -- C_TO_CURRENCY,
 						  l_to_currency,
                                                  t_type.trxndate,
                                                  t_type.total_amt,
                                                  NULL);

      -- We ignore the cases when the RATE or CURRENCY is not found.
      IF ( (l_amount >= 0) ) THEN

         l_curr_date := TRUNC(t_type.trxndate, 'mm');
         l_curr_type := t_type.type;

         IF( (l_prev_type <> '*') AND (l_prev_type <> l_curr_type) ) THEN
            complete_table( l_currType_tbl, l_from_date, l_prev_type, C_PERIOD_MONTHLY);
            add_to_output( TrxnTrend_tbl, l_currType_tbl);
            l_currType_tbl.TRIM(l_currType_tbl.COUNT);
            -- Initialize the values
            l_tbl_count := 1;
            l_curr_date := NULL;
            l_prev_date := NULL;
         END IF;

         l_prev_type := l_curr_type;

         IF( (l_prev_date IS NOT NULL) AND (l_prev_date <> l_curr_date) ) THEN
            l_tbl_count := l_tbl_count + 1;
         END IF;

         WHILE (NOT l_currType_tbl.EXISTS(l_tbl_COUNT) ) LOOP
            l_currType_tbl.EXTEND;
            l_currTYpe_tbl(l_currTYpe_tbl.COUNT).value := 0;
         END LOOP;

         l_prev_date := l_curr_date;

         l_currType_tbl(l_tbl_count).month := TO_CHAR(l_curr_date, 'MON');

         IF( returnAmount ) THEN
            l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + (t_type.total_amt * t_type.factor);
         ELSE
            -- We should count a transaction twice if it is AuthCapture
	    /* -- Bug 3458221: Only auth trans count and capt trans are excluded.
            IF( t_type.factor = 2) THEN
               l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + (2 * t_type.total_trxn);
            ELSE
               l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + t_type.total_trxn;
            END IF;
	    */
	    l_currType_tbl(l_tbl_count).value := l_currType_tbl(l_tbl_count).value + abs(t_type.factor) * t_type.total_trxn;
         END IF;
         l_currType_tbl(l_tbl_count).type := t_type.type;
         l_currType_tbl(l_tbl_count).tdate := l_curr_date;

      END IF;
   END LOOP;

   IF ( l_curr_type = '*' ) THEN
      l_curr_type := 'No Records Found';
   END IF;

   complete_table( l_currType_tbl, l_from_date, l_curr_type, C_PERIOD_MONTHLY);
   add_to_output( TrxnTrend_tbl, l_currType_tbl);


END Get_Subtype_Trends;

--------------------------------------------------------------------------------------
        -- 5. Get_Failure_Trends
        -- Start of comments
        --   API name        : Get_Failure_Trends
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Authorization and Settlement failures.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     output_type         IN    VARCHAR2
        --                     TrxnTrend_tbl       OUT   TrxnTrends_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Failure_Trends ( payee_id          IN    VARCHAR2,
                               output_type       IN    VARCHAR2,
                               TrxnTrend_tbl     OUT NOCOPY TrxnTrends_tbl_type
                               ) IS

   CURSOR get_trends_csr( from_date DATE, to_date DATE, l_payeeId VARCHAR2) IS
	SELECT  CurrencyNameCode currency,
              DECODE(trxntypeid, 2, 'A', 3, 'B', 'C') factor,
              COUNT(*) total_trxn,
              SUM(amount) total_amt,
              TRUNC(updatedate) trxndate
      FROM iby_trxn_summaries_all
      WHERE TRUNC(updatedate) >= from_date
      AND TRUNC(updatedate) <= TO_DATE
      AND trxntypeid IN (2,3,8,9)
      AND instrtype IN (C_INSTRTYPE_CREDITCARD,C_INSTRTYPE_PURCHASECARD)
      AND payeeid LIKE l_payeeId
      AND status IN
          (-99,1,2,4,5,8,15,16,17,19,20,21,9999)
      GROUP BY DECODE(trxntypeid, 2, 'A', 3, 'B', 'C'),
               CurrencyNameCode, TRUNC(updatedate)
      ORDER BY TRUNC(updatedate) ASC;

   l_from_date DATE;
   l_to_date DATE;

   l_curr_auth_date DATE := NULL;
   l_prev_auth_date DATE := NULL;

   l_curr_sett_date DATE := NULL;
   l_prev_sett_date DATE := NULL;

   returnAmount boolean := FALSE;

   l_authFail_tbl Trends_tbl_type := Trends_tbl_type();
   l_settFail_tbl Trends_tbl_type := Trends_tbl_type();

   l_amount NUMBER := 0;

   l_auth_count PLS_INTEGER;
   l_sett_count PLS_INTEGER;

   l_payeeId VARCHAR2(80);

   C_AUTHORIZATIONS CONSTANT VARCHAR2(15) := 'Authorizations';
   C_SETTLEMENTS CONSTANT VARCHAR2(15) := 'Settlements';

   -- Bug 3714173: reporting currency
   l_to_currency VARCHAR2(10);

BEGIN
   -- Bug 3714173: Retrieve the reporting currency
   l_to_currency := nvl(fnd_profile.value('IBY_DBC_REPORTING_CURRENCY'), 'USD');

   -- Check whether 'amount' or 'transactions' need to be returned.
   returnAmount := (output_type = C_OUTPUTTYPE_AMOUNT);

   -- Set the dates appropriately
   l_from_date := TRUNC(ADD_MONTHS(SYSDATE, -37), 'yyyy');
   l_to_date := (TRUNC(SYSDATE, 'yyyy') - 1);

   -- Set the payee if it is null.
   IF( payee_id IS NULL OR TRIM(payee_id) = '') THEN
      l_payeeId := '%';
   ELSE
      l_payeeId := payee_id;
   END IF;

   /*  --- Processing Failures ---- */

   -- Initialize the count
   l_auth_count := 1;
   l_sett_count := 1;

   FOR t_type IN get_trends_csr( l_from_date, l_to_date, l_payeeId) LOOP
      l_amount := IBY_DBCCARD_PVT.Convert_Amount( t_type.currency,
                                                  -- C_TO_CURRENCY,
						  l_to_currency,
                                                  t_type.trxndate,
                                                  t_type.total_amt,
                                                  NULL);

      -- We ignore the cases when the RATE or CURRENCY is not found.
      IF ( (l_amount >= 0) ) THEN


         -- Processing Authorization requests here
         IF (t_type.factor IN ('A','B')) THEN

            l_curr_auth_date := TRUNC(t_type.trxndate, 'yyyy');
            IF( (l_prev_auth_date IS NOT NULL) AND (l_prev_auth_date <> l_curr_auth_date) ) THEN
               l_auth_count := l_auth_count + 1;
            END IF;

            l_prev_auth_date := l_curr_auth_date;

            WHILE (NOT l_authFail_tbl.EXISTS(l_auth_count) ) LOOP
               l_authFail_tbl.EXTEND;
               l_authFail_tbl(l_authFail_tbl.COUNT).value := 0;
            END LOOP;

            l_authFail_tbl(l_auth_count).month := TO_CHAR(l_curr_auth_date, 'yyyy');
            IF( returnAmount ) THEN
               l_authFail_tbl(l_auth_count).value := l_authFail_tbl(l_auth_count).value + t_type.total_amt;
            ELSE
               l_authFail_tbl(l_auth_count).value := l_authFail_tbl(l_auth_count).value + t_type.total_trxn;
            END IF;
            l_authFail_tbl(l_auth_count).type := C_AUTHORIZATIONS;
            l_authFail_tbl(l_auth_count).tdate := l_curr_auth_date;

         END IF;

         -- Processing Settlements requests here
         IF (t_type.factor IN ('B','C')) THEN

            l_curr_sett_date := TRUNC(t_type.trxndate, 'yyyy');
            IF( (l_prev_sett_date IS NOT NULL) AND (l_prev_sett_date <> l_curr_sett_date) ) THEN
               l_sett_count := l_sett_count + 1;
            END IF;

            l_prev_sett_date := l_curr_sett_date;

            WHILE (NOT l_settFail_tbl.EXISTS(l_sett_count) ) LOOP
               l_settFail_tbl.EXTEND;
               l_settFail_tbl(l_settFail_tbl.COUNT).value := 0;
            END LOOP;

            l_settFail_tbl(l_sett_count).month := TO_CHAR(l_curr_sett_date, 'yyyy');
            IF( returnAmount ) THEN
               l_settFail_tbl(l_sett_count).value := l_settFail_tbl(l_sett_count).value + t_type.total_amt;
            ELSE
               l_settFail_tbl(l_sett_count).value := l_settFail_tbl(l_sett_count).value + t_type.total_trxn;
            END IF;
            l_settFail_tbl(l_sett_count).type := C_SETTLEMENTS;
            l_settFail_tbl(l_sett_count).tdate := l_curr_sett_date;

         END IF;

      END IF;
   END LOOP;

   complete_table( l_authFail_tbl, ADD_MONTHS(l_from_date,-12), C_AUTHORIZATIONS, C_PERIOD_YEARLY);
   complete_table( l_settFail_tbl, ADD_MONTHS(l_from_date,-12), C_SETTLEMENTS, C_PERIOD_YEARLY);
   add_to_output( TrxnTrend_tbl, l_authFail_tbl);
   add_to_output( TrxnTrend_tbl, l_settFail_tbl);


END Get_Failure_Trends;

END IBY_DBCCARD_GRAPH_PVT;

/
