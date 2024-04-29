--------------------------------------------------------
--  DDL for Package Body ASO_BI_POPULATE_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_BI_POPULATE_FACTS" AS
/* $Header: asovbipfb.pls 120.0 2005/05/31 01:26:30 appldev noship $ */

-- 1 second
ONE_SECOND             CONSTANT NUMBER := 0.000011574;
G_TABLE_NOT_EXIST      EXCEPTION;
  PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);
G_PROFILE_NOT_SET      EXCEPTION;
G_WORKER_FAILED        BOOLEAN := FALSE;
G_SEC_CURRENCY         Varchar2(40);
G_PRIM_CURRENCY        Varchar2(40);

-- Populating Currency Rates Table
PROCEDURE Populate_Conversion_Rates(p_from_date DATE,
                                    p_to_date DATE,
                                    p_run_type VARCHAR2)
IS
l_rate_type     varchar2(40);
l_sec_rate_type varchar2(40);
l_func_rate_type varchar2(40);
BEGIN
 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('In Populate Currency Rates');
 END IF;
 l_rate_type := BIS_COMMON_PARAMETERS.Get_Rate_Type;
 l_sec_rate_type := BIS_COMMON_PARAMETERS.Get_Secondary_Rate_Type;
 l_func_rate_type := fnd_profile.value('BIS_TREASURY_RATE_TYPE');

 IF p_run_type = 'INIT' THEN -- initial

 MERGE INTO  ASO_BI_CURRENCY_RATES RATES
 USING  (SELECT txn_currency,
              exchange_date,
              FII_CURRENCY.get_rate(txn_currency,
                           g_prim_currency,
                             exchange_date,
                                 l_rate_type) prim_conversion_rate,
             FII_CURRENCY.get_rate(txn_currency,
                            g_sec_currency,
                             exchange_date,
                             l_sec_rate_type) sec_conversion_rate,
             FII_CURRENCY.get_rate(txn_currency,
                        func_currency_code,
                             exchange_date,
                            l_func_rate_type) func_conversion_rate,
             func_currency_code,
             org_id
        FROM
             (SELECT /*+ no_merge parallel(qhd) use_hash(qhd) */  distinct
                    qhd.currency_code txn_currency,
                    trunc (qhd.last_update_date) exchange_date,
                    fcur.currency_code func_currency_code,
                    op.organization_id org_id
               FROM hr_organization_information op,
                    gl_sets_of_books fcur,
                    aso_quote_headers_all qhd
              WHERE op.org_information3 = fcur.set_of_books_id(+)
                AND qhd.org_id = op.organization_id(+)
                AND op.org_information_context(+) = 'Operating Unit Information'
                AND qhd.last_update_date between p_from_date and p_to_date
             )) trans
 ON
 ( RATES.TXN_CURRENCY = trans.TXN_CURRENCY and
   RATES.EXCHANGE_DATE = trans.EXCHANGE_DATE and
   RATES.ORG_ID = Trans.ORG_ID )
 WHEN MATCHED THEN
   UPDATE
   SET  prim_conversion_rate = trans.prim_conversion_rate,
        sec_conversion_rate = trans.sec_conversion_rate,
        func_conversion_rate = trans.func_conversion_rate,
        func_currency_code = trans.func_currency_code
 WHEN NOT MATCHED THEN
  INSERT
  (rates.txn_currency,
   rates.exchange_date,
   rates.prim_conversion_rate,
   rates.sec_conversion_rate,
   rates.func_conversion_rate,
   rates.func_currency_code,
   rates.org_id
  ) VALUES(
   trans.txn_currency,
   trans.exchange_date,
   trans.prim_conversion_rate,
   trans.sec_conversion_rate,
   trans.func_conversion_rate,
   trans.func_currency_code,
   trans.org_id
  );
 ELSE -- incremental
   MERGE INTO  ASO_BI_CURRENCY_RATES RATES
   USING  (SELECT txn_currency,
              exchange_date,
              FII_CURRENCY.get_rate(txn_currency,
                           g_prim_currency,
                             exchange_date,
                                 l_rate_type) prim_conversion_rate,
             FII_CURRENCY.get_rate(txn_currency,
                            g_sec_currency,
                             exchange_date,
                             l_sec_rate_type) sec_conversion_rate,
             FII_CURRENCY.get_rate(txn_currency,
                        func_currency_code,
                             exchange_date,
                            l_func_rate_type) func_conversion_rate,
             func_currency_code,
             org_id
        FROM
             (SELECT  distinct
                    qhd.currency_code txn_currency,
                    trunc (qhd.last_update_date) exchange_date,
                    fcur.currency_code func_currency_code,
                    op.organization_id org_id
               FROM hr_organization_information op,
                    gl_sets_of_books fcur,
                    aso_quote_headers_all qhd
              WHERE op.org_information3 = fcur.set_of_books_id(+)
                AND qhd.org_id = op.organization_id(+)
                AND op.org_information_context(+) = 'Operating Unit Information'
                AND qhd.last_update_date between p_from_date and p_to_date
             )) trans
   ON
   ( RATES.TXN_CURRENCY = trans.TXN_CURRENCY and
     RATES.EXCHANGE_DATE = trans.EXCHANGE_DATE and
     RATES.ORG_ID = Trans.ORG_ID )
   WHEN MATCHED THEN
     UPDATE
     SET  prim_conversion_rate = trans.prim_conversion_rate,
        sec_conversion_rate = trans.sec_conversion_rate,
        func_conversion_rate = trans.func_conversion_rate,
        func_currency_code = trans.func_currency_code
   WHEN NOT MATCHED THEN
    INSERT
    (rates.txn_currency,
   rates.exchange_date,
   rates.prim_conversion_rate,
   rates.sec_conversion_rate,
   rates.func_conversion_rate,
   rates.func_currency_code,
   rates.org_id
   ) VALUES(
   trans.txn_currency,
   trans.exchange_date,
   trans.prim_conversion_rate,
   trans.sec_conversion_rate,
   trans.func_conversion_rate,
   trans.func_currency_code,
   trans.org_id
   );
 END IF;
  COMMIT;
  BIS_COLLECTION_UTILITIES.put_line('Currency Rates Table Populated Successfully!');
  ASO_BI_UTIL_PVT.Analyze_Table('ASO_BI_CURRENCY_RATES');
  BIS_COLLECTION_UTILITIES.put_line('Currency Rates Table Analyzed');
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('End of Populate Currency Rates');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
      BIS_COLLECTION_UTILITIES.Debug('Error in Populate_Conversion_Rates: '||sqlerrm);
   END IF;
   RAISE;
END Populate_Conversion_Rates;

-- Checks for any missing currency from
-- quote header staging table
FUNCTION Check_Missing_Rates(p_currency_type  IN VARCHAR2)
Return NUMBER
AS
 l_global_prim_rate_type   Varchar2(30);
 l_global_sec_rate_type   Varchar2(30);
 l_cnt_miss_rate Number := 0;
 l_msg_name      Varchar2(40);

-- this cursor used only when secondary global currency
-- is not implemented and reports missing primary
-- conversion rates.
 CURSOR C_missing_rates_p
 IS
   SELECT txn_currency from_currency,
          g_prim_currency to_currency,
         exchange_date,
         prim_conversion_rate
   FROM ASO_BI_CURRENCY_RATES
   WHERE (prim_conversion_rate < 0
   OR prim_conversion_rate IS NULL)
   ORDER BY exchange_date,txn_currency ;

-- this cursor used only when secondary global currency
-- is implemented and reports missing primary and secondary
-- conversion rates.
 CURSOR C_missing_rates_ps
 IS
   SELECT txn_currency from_currency,
         g_prim_currency to_prim_currency,
         prim_conversion_rate,
         g_sec_currency to_sec_currency,
         sec_conversion_rate,
         exchange_date
   FROM ASO_BI_CURRENCY_RATES
   WHERE( (sec_conversion_rate < 0 OR sec_conversion_rate IS NULL)
      OR (prim_conversion_rate < 0   OR prim_conversion_rate IS NULL))
   ORDER BY exchange_date,txn_currency;
BEGIN

 l_msg_name := 'BIS_DBI_CURR_NO_LOAD';
 IF p_currency_type = 'P' THEN --check missing primary currency rates
    SELECT COUNT(*) INTO l_cnt_miss_rate
    FROM ASO_BI_CURRENCY_RATES
    WHERE (prim_conversion_rate < 0
       OR prim_conversion_rate IS NULL) and rownum < 2;

    If(l_cnt_miss_rate > 0 ) Then
      l_global_prim_rate_type := BIS_COMMON_PARAMETERS.Get_Rate_Type;

      BIS_COLLECTION_UTILITIES.put_line_out('Missing Primary Currency Rates Found!');
      BIS_COLLECTION_UTILITIES.put_line('Missing Primary Currency Rates Found!');
      FND_MESSAGE.Set_Name('FII',l_msg_name);
      IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
        BIS_COLLECTION_UTILITIES.debug(l_msg_name||' : '||FND_MESSAGE.get);
      END IF;

      BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

      FOR rate_record in C_missing_rates_p
      LOOP
         IF rate_record.prim_conversion_rate = -3 THEN
            BIS_COLLECTION_UTILITIES.writeMissingRate(
	        p_rate_type => l_global_prim_rate_type,
        	p_from_currency => rate_record.from_currency,
        	p_to_currency => rate_record.to_currency,
        	p_date => TO_DATE('01/01/1999','DD/MM/YYYY'));
         ELSE
            BIS_COLLECTION_UTILITIES.writeMissingRate(
	        p_rate_type => l_global_prim_rate_type,
        	p_from_currency => rate_record.from_currency,
        	p_to_currency => rate_record.to_currency,
        	p_date => rate_record.exchange_date);
         END IF;
      END LOOP;
      ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');
      RETURN -1;
    End If;
    Return 1;
 Else -- check missing primary/secondary currency rates
    SELECT COUNT(*) INTO l_cnt_miss_rate
    FROM ASO_BI_CURRENCY_RATES
    WHERE ((sec_conversion_rate < 0  OR sec_conversion_rate IS NULL)
       OR (prim_conversion_rate < 0  OR prim_conversion_rate IS NULL)) and rownum < 2;

    If(l_cnt_miss_rate > 0 ) Then
      l_global_sec_rate_type := BIS_COMMON_PARAMETERS.Get_Secondary_Rate_Type;
      l_global_prim_rate_type := BIS_COMMON_PARAMETERS.Get_Rate_Type;

      BIS_COLLECTION_UTILITIES.put_line_out('Missing Primary/Secondary Currency Coversin Rates Found!');
      BIS_COLLECTION_UTILITIES.put_line('Missing Primary/Secondary Currency Coversin Rates Found!');

      FND_MESSAGE.Set_Name('FII',l_msg_name);
      IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
        BIS_COLLECTION_UTILITIES.debug(l_msg_name||' : '||FND_MESSAGE.get);
      END IF;

      BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

      FOR rate_record in C_missing_rates_ps
      LOOP
         IF (rate_record.prim_conversion_rate < 0 OR rate_record.prim_conversion_rate IS NULL)
            THEN
            IF rate_record.prim_conversion_rate = -3 THEN
               BIS_COLLECTION_UTILITIES.writeMissingRate(
	          p_rate_type => l_global_prim_rate_type,
        	  p_from_currency => rate_record.from_currency,
        	  p_to_currency => rate_record.to_prim_currency,
        	  p_date => TO_DATE('01/01/1999','DD/MM/YYYY'));
            ELSE
              BIS_COLLECTION_UTILITIES.writeMissingRate(
	             p_rate_type => l_global_prim_rate_type,
        	     p_from_currency => rate_record.from_currency,
        	     p_to_currency => rate_record.to_prim_currency,
        	     p_date => rate_record.exchange_date);
            END IF;
         END IF;
         IF (rate_record.sec_conversion_rate < 0 OR rate_record.sec_conversion_rate IS NULL)
         THEN
           IF rate_record.sec_conversion_rate = -3 THEN
              BIS_COLLECTION_UTILITIES.writeMissingRate(
	        p_rate_type => l_global_sec_rate_type,
        	p_from_currency => rate_record.from_currency,
        	p_to_currency => rate_record.to_sec_currency,
        	p_date => TO_DATE('01/01/1999','DD/MM/YYYY'));
           ELSE
                BIS_COLLECTION_UTILITIES.writeMissingRate(
	             p_rate_type => l_global_sec_rate_type,
        	     p_from_currency => rate_record.from_currency,
        	     p_to_currency => rate_record.to_sec_currency,
        	     p_date => rate_record.exchange_date);
           END IF;
         END IF;
      END LOOP;
      ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');
      RETURN -1;
    End If;
    Return 1;
 End If;
EXCEPTION
 WHEN OTHERS THEN
   IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
      BIS_COLLECTION_UTILITIES.Debug('Error in Check_missing_rates: '||sqlerrm);
   END IF;
   RAISE;
END Check_Missing_Rates;

-- Checks for missing currency codes in staging tables
FUNCTION Chk_Miss_Rates_Lines(p_currency_type  IN VARCHAR2)
Return NUMBER
AS
 l_global_rate    Varchar2(30);
 l_cnt_miss_rate  Number := 0;
 l_msg_name       Varchar2(40);
 l_sec_rate_type  Varchar2(30);
 l_func_rate_type Varchar2(30);
  CURSOR C_missing_cur_rates_pf
  IS SELECT txn_currency from_currency,
            g_prim_currency to_prim_currency,
            prim_conversion_rate to_prim_rate,
            func_currency_code to_func_currency,
            func_conversion_rate to_func_rate,
            exchange_date
   FROM   aso_bi_currency_rates
   WHERE  (prim_conversion_rate < 0 OR prim_conversion_rate IS NULL)
          OR
          (func_conversion_rate < 0 OR func_conversion_rate IS NULL)
   ORDER BY exchange_date,txn_currency;

  CURSOR C_missing_cur_rates_pfs
  IS SELECT txn_currency from_currency,
            g_prim_currency to_prim_currency,
            prim_conversion_rate to_prim_rate,
            func_currency_code to_func_currency,
            func_conversion_rate to_func_rate,
            g_sec_currency to_sec_currency,
            sec_conversion_rate to_sec_rate,
            exchange_date
   FROM   ASO_BI_CURRENCY_RATES
   WHERE  ((prim_conversion_rate < 0  OR prim_conversion_rate IS NULL)
          OR (func_conversion_rate < 0  OR func_conversion_rate IS NULL)
          OR (sec_conversion_rate < 0 OR sec_conversion_rate IS NULL))
   ORDER BY exchange_date,txn_currency;

BEGIN
 l_func_rate_type := fnd_profile.value('BIS_TREASURY_RATE_TYPE');

 l_msg_name := 'BIS_DBI_CURR_NO_LOAD';

 IF p_currency_type = 'PF' THEN
    SELECT COUNT(*) INTO l_cnt_miss_rate FROM ASO_BI_CURRENCY_RATES
    WHERE  ((prim_conversion_rate < 0 OR prim_conversion_rate IS NULL)
     OR (func_conversion_rate<0 OR func_conversion_rate IS NULL)) and rownum < 2;
 ELSE
    SELECT COUNT(*) INTO l_cnt_miss_rate FROM ASO_BI_CURRENCY_RATES
    WHERE (prim_conversion_rate < 0 OR prim_conversion_rate IS NULL)
     OR (func_conversion_rate<0 OR func_conversion_rate IS NULL)
     OR (sec_conversion_rate <0 OR sec_conversion_rate IS NULL) and rownum < 2;
 END IF;

 l_global_rate := BIS_COMMON_PARAMETERS.Get_Rate_Type;
 l_sec_rate_type := BIS_COMMON_PARAMETERS.Get_Secondary_Rate_Type;

 BIS_COLLECTION_UTILITIES.put_line('Missing Primary Currency/Functional Currency Count '||l_cnt_miss_rate);

 If(l_cnt_miss_rate > 0 )
 Then
   FND_MESSAGE.Set_Name('FII',l_msg_name);
   IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
      BIS_COLLECTION_UTILITIES.debug(l_msg_name||': '||FND_MESSAGE.get);
   END IF;
   IF p_currency_type = 'PF' THEN -- check missing primary and functional currency rates
      BIS_COLLECTION_UTILITIES.put_line_out('Missing Primary Currency/Functional Currency Rates Found!');
      BIS_COLLECTION_UTILITIES.put_line('Missing Primary Currency/Functional Currency Rates Found!');
      BIS_COLLECTION_UTILITIES.writeMissingRateHeader;
      FOR rate_record in C_missing_cur_rates_pf
      LOOP
         IF (rate_record.to_prim_rate <0) OR (rate_record.to_prim_rate IS NULL) THEN
            IF (rate_record.to_prim_rate = -3) THEN
               BIS_COLLECTION_UTILITIES.writeMissingRate(
			    p_rate_type => l_global_rate,
          	            p_from_currency => rate_record.from_currency,
         	            p_to_currency => rate_record.to_prim_currency,
        	            p_date => TO_DATE('01/01/1999','DD/MM/YYYY'));
            ELSE
               BIS_COLLECTION_UTILITIES.writeMissingRate(
			    p_rate_type => l_global_rate,
        	            p_from_currency => rate_record.from_currency,
        	            p_to_currency => rate_record.to_prim_currency,
        	            p_date => rate_record.exchange_date);
            END IF;
         END IF;
         IF (rate_record.to_func_rate <0)  THEN
            IF (rate_record.to_func_rate = -3) THEN
               BIS_COLLECTION_UTILITIES.writeMissingRate(
			    p_rate_type => l_func_rate_type,
        	            p_from_currency => rate_record.from_currency,
        	            p_to_currency => rate_record.to_func_currency,
        	            p_date => TO_DATE('01/01/1999','DD/MM/YYYY'));
            ELSE
               BIS_COLLECTION_UTILITIES.writeMissingRate(
			    p_rate_type => l_func_rate_type,
        	            p_from_currency => rate_record.from_currency,
        	            p_to_currency => rate_record.to_func_currency,
        	            p_date => rate_record.exchange_date);
            END IF;
         END IF;
      END LOOP;
      ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');
      RETURN -1;
   ELSE --'PFS' check primary, functional and secondary missing currency
      BIS_COLLECTION_UTILITIES.put_line_out('Missing Primary Currency/Functional/Secondary Currency Rates Found!');
      BIS_COLLECTION_UTILITIES.put_line('Missing Primary Currency/Functional/Secondary Currency Rates Found!');
      BIS_COLLECTION_UTILITIES.writeMissingRateHeader;
      FOR rate_record in C_missing_cur_rates_pfs
      LOOP
          -- report missing primary currency rates
          IF (rate_record.to_prim_rate <0) OR (rate_record.to_prim_rate IS NULL) THEN
            IF (rate_record.to_prim_rate = -3) THEN
               BIS_COLLECTION_UTILITIES.writeMissingRate(
			    p_rate_type => l_global_rate,
          	            p_from_currency => rate_record.from_currency,
         	            p_to_currency => rate_record.to_prim_currency,
        	            p_date => TO_DATE('01/01/1999','DD/MM/YYYY'));
            ELSE
               BIS_COLLECTION_UTILITIES.writeMissingRate(
			    p_rate_type => l_global_rate,
        	            p_from_currency => rate_record.from_currency,
        	            p_to_currency => rate_record.to_prim_currency,
        	            p_date => rate_record.exchange_date);
            END IF;
         END IF;

         -- report missing functional currency rates
         IF (rate_record.to_func_rate <0)  THEN
            IF (rate_record.to_func_rate = -3) THEN
               BIS_COLLECTION_UTILITIES.writeMissingRate(
			    p_rate_type => l_func_rate_type,
        	            p_from_currency => rate_record.from_currency,
        	            p_to_currency => rate_record.to_func_currency,
        	            p_date => TO_DATE('01/01/1999','DD/MM/YYYY'));
            ELSE
               BIS_COLLECTION_UTILITIES.writeMissingRate(
			    p_rate_type => l_func_rate_type,
        	            p_from_currency => rate_record.from_currency,
        	            p_to_currency => rate_record.to_func_currency,
        	            p_date => rate_record.exchange_date);
            END IF;
         END IF;

         -- report missing sondary currency rates
         IF (rate_record.to_sec_rate <0) OR (rate_record.to_sec_rate IS NULL) THEN
            IF (rate_record.to_sec_rate = -3) THEN
               BIS_COLLECTION_UTILITIES.writeMissingRate(
			    p_rate_type => l_sec_rate_type,
        	            p_from_currency => rate_record.from_currency,
        	            p_to_currency => rate_record.to_sec_currency,
        	            p_date => TO_DATE('01/01/1999','DD/MM/YYYY'));
            ELSE
               BIS_COLLECTION_UTILITIES.writeMissingRate(
			    p_rate_type =>  l_sec_rate_type,
        	            p_from_currency => rate_record.from_currency,
        	            p_to_currency => rate_record.to_sec_currency,
        	            p_date => rate_record.exchange_date);
            END IF;
         END IF;
      END LOOP;
      ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');
      RETURN -1;
   END IF;
 End If;

 Return 1;

EXCEPTION
 WHEN OTHERS THEN
   IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
      BIS_COLLECTION_UTILITIES.Debug('Error in Chk_Miss_Rates_Lines:'||sqlerrm);
   END IF;
   RAISE;
END Chk_Miss_Rates_Lines;

-- Launches a worker which populates staging table
Function Launch_Worker(p_worker_no   Number,
                       p_worker_name Varchar2)
RETURN NUMBER
As
 l_request_id Number;
BEGIN
 l_request_id := FND_REQUEST.SUBMIT_REQUEST(
		 application => 'ASO',
     program     => p_worker_name,
		 description => NULL,
		 start_time  => NULL,
		 sub_request => FALSE,
		 argument1   => p_worker_no);
 Return l_request_id;
END Launch_Worker;

FUNCTION Process_Running
Return BOOLEAN
As
 l_unassigned_cnt NUMBER := 0;
 l_completed_cnt  NUMBER := 0;
 l_inprocess_cnt  NUMBER := 0;
 l_failed_cnt     NUMBER := 0;
 l_total_cnt      NUMBER := 0;
Begin
 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('In Process Running');
 END IF;

 SELECT NVL(SUM(DECODE(status,'UNASSIGNED',1,0)),0),
 NVL(SUM(DECODE(status,'COMPLETED',1,0)),0),
 NVL(SUM(DECODE(status,'IN_PROCESS',1,0)),0),
 NVL(SUM(DECODE(status,'FAILED',1,0)),0),
 COUNT(*)
 INTO l_unassigned_cnt,
      l_completed_cnt,
	  l_inprocess_cnt,
	  l_failed_cnt,
	  l_total_cnt
 FROM ASO_BI_QUOTE_FACT_JOBS;

 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Job Status - Unassigned:'||l_unassigned_cnt||
     ' In Process:'||l_inprocess_cnt||' Completed:'||l_completed_cnt||
     ' Failed:'||l_failed_cnt||' Total:'||l_total_cnt);
 END IF;

 IF(l_failed_cnt > 0)
 THEN
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.Debug('Atleast One of the workers failed.Terminating.');
  END IF;
  G_WORKER_FAILED := TRUE;
  Return FALSE;
 End IF;

 IF(l_total_cnt = l_completed_cnt)
 THEN
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.Debug('All Jobs Completed.');
  END IF;
  Return FALSE;
 END IF;
Return TRUE;
End Process_Running;

--This is used for incremental loading of quote headers
PROCEDURE Populate_Facts(errbuf      OUT NOCOPY VARCHAR2,
                         retcode     OUT NOCOPY NUMBER,
                         p_from_date IN  VARCHAR2,
                         p_to_date   IN  VARCHAR2,
	                 p_no_worker IN  NUMBER )
AS
 l_from_date            Date ;
 l_to_date	        Date;
 l_request_id           Number;
 l_missing_date         Boolean := FALSE;
 l_list                 DBMS_SQL.varchar2_table;
 l_valid_curr_setup     Boolean;
BEGIN
 retcode := 0 ;
 l_valid_curr_setup := TRUE; -- to check valid primary/secondary currency setup

 IF(BIS_COLLECTION_UTILITIES.Setup(
       p_object_name => 'ASO_BI_POPULATE_FACTS') = false)
 Then
   errbuf := FND_MESSAGE.Get;
   retcode := -1;
   RAISE_APPLICATION_ERROR(-20000,errbuf);
 End if;

 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.debug('Start ASO_BI_POPULATE_FACTS');
    -- Initialize
    BIS_COLLECTION_UTILITIES.debug('Initialization');
 END IF;

 ASO_BI_UTIL_PVT.INIT;

 g_prim_currency := bis_common_parameters.get_currency_code;
 g_sec_currency := bis_common_parameters.get_secondary_currency_code;

 l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
 l_list(2) := 'BIS_PRIMARY_RATE_TYPE';
 /* Check for Seondary global currency implemeneted */
 IF  g_sec_currency IS NOT NULL THEN
    /* Seondary global currency is implemeneted then
       check for secondary rate type profile is set*/
    l_list(3) := 'BIS_SECONDARY_RATE_TYPE';
 ELSE
    BIS_COLLECTION_UTILITIES.put_line_out('Secondary Global Currency Not Implemented!!');
    BIS_COLLECTION_UTILITIES.put_line('Secondary Global Currency Not Implemented!!');
 END IF;
 IF NOT(bis_common_parameters.check_global_parameters(l_list))
 THEN
   errbuf := FND_MESSAGE.Get;
   retcode := -1;
--   RAISE_APPLICATION_ERROR(-20000,errbuf);
   RAISE G_PROFILE_NOT_SET;
 END IF;

 -- Truncate the processing tables
 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.debug('Cleaning up the tables before processing starts.');
 END IF;

 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_IDS');
 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_FACT_JOBS');

 l_from_date := TRUNC(TO_DATE(p_from_date,'YYYY/MM/DD HH24:MI:SS'));
 l_to_date   := TRUNC(TO_DATE(p_to_date,'YYYY/MM/DD HH24:MI:SS'))+ 1 -
                ONE_SECOND;

 IF l_to_date < l_from_date THEN
  Retcode := -1;
  errbuf := 'To Date provided is less than From Date';
  Return;
 End If;
 FII_TIME_API.check_missing_date (p_from_date => l_from_date,
                                  p_to_date   => l_to_date,
                                  p_has_missing_date => l_missing_date);

 If(l_missing_date) Then
  Retcode := -1;
  Return;
 End If;

 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('The date Range for collection is from ' ||
     p_from_date || ' to ' || p_to_date);
    BIS_COLLECTION_UTILITIES.Debug('Start populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
 END IF;

 ASO_BI_QUOTE_FACT_PVT.Populate_Quote_Ids(
     p_from_date => l_from_date,
     p_to_date   => l_to_date) ;

 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('End populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
    BIS_COLLECTION_UTILITIES.Debug('Registering Jobs');
 END IF;

 /* Populate Currency Rates Table*/
 Populate_Conversion_Rates(p_from_date => l_from_date,
			     p_to_date => l_to_date,
                            p_run_type => 'INCR');

 IF g_sec_currency IS NOT NULL THEN
    BIS_COLLECTION_UTILITIES.put_line('Checking missing Primary and Secondary Currency rates ');
  If (Check_Missing_Rates('PS') = -1) Then
       l_valid_curr_setup := FALSE;
    End If;
 ELSIf(Check_Missing_Rates('P') = -1) Then
    l_valid_curr_setup := FALSE;
 End If;

 IF NOT(l_valid_curr_setup) THEN
   Retcode := -1;
   BIS_COLLECTION_UTILITIES.wrapup(
            p_status      => FALSE ,
            p_count       => 0,
            p_period_from => l_from_date,
            p_period_to   => l_to_date);

   Return;
 END IF;
 BIS_COLLECTION_UTILITIES.put_line('Valid Currency Setup Exists. ');

 ASO_BI_QUOTE_FACT_PVT.Register_Jobs;

 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Done Registering Jobs');
    BIS_COLLECTION_UTILITIES.Debug('Launch Workers');
 END IF;
 BIS_COLLECTION_UTILITIES.put_line('Done Registering Jobs');
 For i IN 1..p_no_worker
 Loop
  l_request_id := Launch_Worker(p_worker_no   => i,
                                p_worker_name => 'ASO_BI_QOT_HDR_SUBWORKER');

  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.Debug(' Worker:'|| i ||' Request Id:' ||
                                 l_request_id);
  END IF;
 End Loop;
 BIS_COLLECTION_UTILITIES.put_line('No. workers Launhed:'||p_no_worker);
 COMMIT;

 While(Process_Running)
 Loop
   DBMS_LOCK.Sleep(60);
 End Loop;
 BIS_COLLECTION_UTILITIES.put_line('Checking missing Primary Currency rates ');
 IF G_WORKER_FAILED THEN
   Retcode := -1;
   BIS_COLLECTION_UTILITIES.wrapup(
            p_status      => FALSE ,
            p_count       => 0,
            p_period_from => l_from_date,
            p_period_to   => l_to_date);

   Return;
 END IF;
 BIS_COLLECTION_UTILITIES.put_line('Populating Data in to fact table ');
 ASO_BI_QUOTE_FACT_PVT.Populate_Data;
 BIS_COLLECTION_UTILITIES.put_line('Truncating Staging table ');

 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_HDRS_STG');

  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => TRUE ,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);

 retcode := 0;
EXCEPTION
WHEN G_PROFILE_NOT_SET THEN -- PROFILE NOT SET exception
  retcode := -1;

  BIS_COLLECTION_UTILITIES.put_line('Required Profiles are not set! ');

  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');

  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => FALSE ,
   p_message     => sqlerrm,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);
WHEN OTHERS THEN
 retcode := -1;
 errbuf  := sqlerrm;
 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
   BIS_COLLECTION_UTILITIES.Debug('Error in Populate Facts:'||errbuf);
 END IF;

 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_HDRS_STG');
 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');

 BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => FALSE ,
   p_message     => sqlerrm,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);
 RAISE;
END Populate_Facts;

--This is used for initial load of quote headers
PROCEDURE Initial_Load_Hdr(errbuf      OUT NOCOPY VARCHAR2,
                           retcode     OUT NOCOPY NUMBER,
                           p_from_date IN  VARCHAR2,
                           p_to_date   IN  VARCHAR2 )
AS
 l_from_date     Date ;
 l_to_date	 Date;
 l_missing_date  Boolean := FALSE;
 l_list          DBMS_SQL.varchar2_table;
 l_valid_curr_setup     Boolean;
BEGIN
 retcode := 0 ;
  l_valid_curr_setup := TRUE;  -- to check valid primary/secondary currency setup
 --Purge the Base Fact Table for Quote Headers and the Refresh Log
 --for the Quote Headers load.
 BIS_COLLECTION_UTILITIES.deleteLogForObject('ASO_BI_POPULATE_FACTS');

 g_prim_currency := bis_common_parameters.get_currency_code;
 g_sec_currency := bis_common_parameters.get_secondary_currency_code;

 IF(BIS_COLLECTION_UTILITIES.Setup(
       p_object_name => 'ASO_BI_POPULATE_FACTS') = false)
 Then
   errbuf := FND_MESSAGE.Get;
   retcode := -1;
   RAISE_APPLICATION_ERROR(-20000,errbuf);
 End if;

 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.debug('Start Initial Load for Quote Headers Fact');
    BIS_COLLECTION_UTILITIES.debug('Initialization');
 END IF;

 -- Initialize
 ASO_BI_UTIL_PVT.INIT;

 l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
 l_list(2) := 'BIS_PRIMARY_RATE_TYPE';
 /* Check seondary global currency is implemeneted */
 IF g_sec_currency IS NOT NULL THEN
    /* Seondary global currency is implemeneted then
       check for secondary rate type profile is set*/
    l_list(3) := 'BIS_SECONDARY_RATE_TYPE';
 ELSE
    BIS_COLLECTION_UTILITIES.put_line_out('Secondary Global Currency Not Implemented!!');
    BIS_COLLECTION_UTILITIES.put_line('Secondary Global Currency Not Implemented!!');
 END IF;
 IF NOT(bis_common_parameters.check_global_parameters(l_list))
 THEN
   errbuf := FND_MESSAGE.Get;
   retcode := -1;
--   RAISE_APPLICATION_ERROR(-20000,errbuf);
   RAISE G_PROFILE_NOT_SET;
 END IF;

 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.debug('Cleaning up the tables before processing starts.');
 END IF;

 -- Truncate the processing tables
 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_IDS');
 --As this is a initial load the Base Fact Table is assumed to be empty
 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_HDRS_ALL');

 l_from_date := TRUNC(TO_DATE(p_from_date,'YYYY/MM/DD HH24:MI:SS'));
 l_to_date   := TRUNC(TO_DATE(p_to_date,'YYYY/MM/DD HH24:MI:SS'))+ 1 -
                ONE_SECOND;

 IF l_to_date < l_from_date THEN
  Retcode := -1;
  errbuf := 'To Date provided is less than From Date';
  Return;
 End If;

 FII_TIME_API.check_missing_date (p_from_date => l_from_date,
                                  p_to_date   => l_to_date,
                                  p_has_missing_date => l_missing_date);

 If(l_missing_date) Then
  Retcode := -1;
  errbuf := 'There are missing dates in the date range';
  Return;
 End If;
 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('The date Range for collection is from ' ||
     p_from_date || ' to ' || p_to_date);
    BIS_COLLECTION_UTILITIES.Debug('Start populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
 END IF;

 ASO_BI_QUOTE_FACT_PVT.InitLoad_Quote_Ids(
     p_from_date => l_from_date,
     p_to_date   => l_to_date) ;

 BIS_COLLECTION_UTILITIES.put_line('Quote Ids Table Populated');
 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
  BIS_COLLECTION_UTILITIES.Debug('End populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
 END IF;
 /*Populate Currency Rate Table*/
 Populate_Conversion_Rates(p_from_date => l_from_date,
			     p_to_date => l_to_date,
                            p_run_type => 'INIT');
 commit;
 IF g_sec_currency IS NOT NULL THEN
    BIS_COLLECTION_UTILITIES.put_line('Checking missing Primary and Secondary Currency rates ');
    If (Check_Missing_Rates('PS') = -1) Then
       l_valid_curr_setup := FALSE;
    End If;
 ELSE
    BIS_COLLECTION_UTILITIES.put_line('Checking missing Primary Currency rates ');
    If(Check_Missing_Rates('P') = -1) Then
      l_valid_curr_setup := FALSE;
    END IF;
 End If;
 IF NOT(l_valid_curr_setup) THEN
   Retcode := -1;
   BIS_COLLECTION_UTILITIES.wrapup(
            p_status      => FALSE ,
            p_count       => 0,
            p_period_from => l_from_date,
            p_period_to   => l_to_date);

   Return;
 END IF;
 BIS_COLLECTION_UTILITIES.put_line('Currency Rates Table Populated');
 ASO_BI_QUOTE_FACT_PVT.InitiLoad_QotHdr;
 BIS_COLLECTION_UTILITIES.put_line('Quote Headers Table Populated');
 BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => TRUE ,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);

 retcode := 0;
EXCEPTION
WHEN G_PROFILE_NOT_SET THEN -- PROFILE NOT SET exception
  retcode := -1;

  BIS_COLLECTION_UTILITIES.put_line('Required Profiles are not set! ');

  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');

  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => FALSE ,
   p_message     => sqlerrm,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);
WHEN OTHERS THEN
 retcode := -1;
 errbuf  := sqlerrm;
 IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Error in Initial Load of Quote Hdr Fact:'
                                ||errbuf);
 END IF;

 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');

 BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => FALSE ,
   p_message     => sqlerrm,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);
 RAISE;
END Initial_Load_Hdr ;

-- This is for populating Quote Lines incrementally
PROCEDURE Populate_Lines_Fact(errbuf 	OUT NOCOPY VARCHAR2,
                            retcode 	OUT NOCOPY NUMBER,
                            p_from_date  IN  VARCHAR2,
                            p_to_date    IN  VARCHAR2,
			                      p_worker_no  IN  NUMBER)
AS
 l_from_date    Date ;
 l_to_date	    Date;
 l_request_id   Number;
 l_missing_date Boolean := FALSE;
 l_curr_count   NUMBER;
 l_list         DBMS_SQL.varchar2_table;
 l_valid_curr_setup  Boolean := TRUE;
BEGIN
  retcode := 0 ;

  IF(BIS_COLLECTION_UTILITIES.Setup(
       p_object_name => 'ASO_BI_LINE_FACTS') = false)
  Then
    errbuf := FND_MESSAGE.Get;
    retcode := -1;
    RAISE_APPLICATION_ERROR(-20000,errbuf);
  End if;

  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.debug('Start ASO_BI_LINE_FACTS');
  END IF;

  -- Initialize
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.debug('Initialization started ');
  END IF;
  BIS_COLLECTION_UTILITIES.put_line('Initialization started ');
  ASO_BI_UTIL_PVT.INIT;

  g_prim_currency := bis_common_parameters.get_currency_code;
  g_sec_currency := bis_common_parameters.get_secondary_currency_code;

  BIS_COLLECTION_UTILITIES.put_line_out('Primary Currency '||g_prim_currency);
  BIS_COLLECTION_UTILITIES.put_line_out('Secondary Currency '||g_sec_currency);

  l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
  l_list(2) := 'BIS_PRIMARY_RATE_TYPE';
  l_list(3) := 'BIS_TREASURY_RATE_TYPE';

  /* Check seondary global currency is implemeneted */
  IF g_sec_currency IS NOT NULL THEN
    /* Seondary global currency is implemeneted then
       check for secondary rate type profile is set*/
    l_list(4) := 'BIS_SECONDARY_RATE_TYPE';
  ELSE
    BIS_COLLECTION_UTILITIES.put_line_out('Secondary Global Currency Not Implemented!!');
    BIS_COLLECTION_UTILITIES.put_line('Secondary Global Currency Not Implemented!!');
  END IF;
  IF NOT(bis_common_parameters.check_global_parameters(l_list))
  THEN
    errbuf := FND_MESSAGE.Get;
    retcode := -1;
--    RAISE_APPLICATION_ERROR(-20000,errbuf);
    RAISE G_PROFILE_NOT_SET;
  END IF;

  -- Truncate the processing tables
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.debug(
                'Cleaning up the tables before processing starts.');
  END IF;

  -- Truncate all the temp tables
  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_IDS');
  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_LINES_STG');
  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_FACT_JOBS');
  ASO_BI_UTIL_PVT.Truncate_table('ASO_BI_LINE_IDS');

  l_from_date := TRUNC(TO_DATE(p_from_date,'YYYY/MM/DD HH24:MI:SS'));
  l_to_date   := TRUNC(TO_DATE(p_to_date,'YYYY/MM/DD HH24:MI:SS'))+ 1 -
                ONE_SECOND;

  IF l_to_date < l_from_date THEN
    Retcode := -1;
    errbuf := 'To Date provided is less than From Date';
    Return;
  End If;
  --Check for missing dates
  FII_TIME_API.check_missing_date (p_from_date => l_from_date,
                                  p_to_date   => l_to_date,
                                  p_has_missing_date => l_missing_date);

  If(l_missing_date) Then
    Retcode := -1;
    errbuf := 'There are missing dates in the date range';
    Return;
  End If;
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('The date Range for collection is from ' ||
     p_from_date || ' to ' || p_to_date);

    BIS_COLLECTION_UTILITIES.Debug('Start populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
  END IF;

  --Get the quote ids that  have changed in the given time range
  ASO_BI_QUOTE_FACT_PVT.Populate_Quote_Ids(
     p_from_date => l_from_date,
     p_to_date   => l_to_date) ;
  BIS_COLLECTION_UTILITIES.put_line('Quote Ids Table Populated');
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.Debug('End populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
  END IF;

  --Get the quote lines corresponding to the quotes changed in the time period
  ASO_BI_LINE_FACT_PVT.Populate_Quote_Line_Ids;

  /* Populate Currency Rates Table*/
  SELECT COUNT(*) INTO l_curr_count
  FROM ASO_BI_CURRENCY_RATES
  WHERE rownum < 2;
  IF l_curr_count = 0 THEN
    Populate_Conversion_Rates(p_from_date => l_from_date,
			         p_to_date => l_to_date,
                                p_run_type => 'INCR');
  END IF;
  IF g_sec_currency IS NOT NULL THEN
     BIS_COLLECTION_UTILITIES.put_line('Checking missing Primary/Functional/Secondary Currency rates ');
     If(Chk_Miss_Rates_Lines('PFS') = -1) Then
        l_valid_curr_setup := FALSE;
     End If;
  ELSE
     BIS_COLLECTION_UTILITIES.put_line('Checking missing Primary/Functional Currency rates ');
     If(Chk_Miss_Rates_Lines('PF') = -1) Then
        l_valid_curr_setup := FALSE;
     End If;
  END IF;
  IF NOT(l_valid_curr_setup) THEN
       Retcode := -1;
       BIS_COLLECTION_UTILITIES.wrapup(
           p_status      => FALSE ,
           p_count       => 0,
           p_period_from => l_from_date,
           p_period_to   => l_to_date);

       Return;
  END IF;
  BIS_COLLECTION_UTILITIES.put_line('Currency Table Populated');
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Registering Line Jobs');
  END IF;
  --Register the jobs for lines by looking up ASO_BI_LINE_IDS table
  ASO_BI_LINE_FACT_PVT.Register_Line_Jobs;

  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Done Registering Jobs');
    BIS_COLLECTION_UTILITIES.Debug('Launch '|| p_worker_no || ' Workers');
  END IF;


  --Workers will populate the ASO_BI_QUOTE_LINE_STG table
  For i IN 1..p_worker_no
  Loop
    l_request_id := Launch_Worker(p_worker_no   => i,
                                  p_worker_name => 'ASO_BI_QOT_LIN_SUBWORKER');
    IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
       BIS_COLLECTION_UTILITIES.Debug(' Worker:'|| i ||' Request Id:' ||
                                 l_request_id);
    END IF;
  End Loop;
  COMMIT;

  While(Process_Running)
  Loop
    DBMS_LOCK.Sleep(60);
  End Loop;

  IF G_WORKER_FAILED THEN
    Retcode := -1;

    BIS_COLLECTION_UTILITIES.wrapup(
      p_status      => FALSE ,
      p_count       => 0,
      p_period_from => l_from_date,
      p_period_to   => l_to_date);

    Return;
  END IF;
  BIS_COLLECTION_UTILITIES.put_line('Quote Lines Staging Table Populated');
  --To Clean any deleted or updated lines from ASO_BI_QUOTE_LINES_ALL
  ASO_BI_LINE_FACT_PVT.Cleanup_Line_Data;

  --Merges data from the staging to the ASO_BI_QUOTE_LINES_ALL
  ASO_BI_LINE_FACT_PVT.Populate_Line_Data;
  BIS_COLLECTION_UTILITIES.put_line('Quote Line Fact Table Populated');

  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_LINES_STG');
  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');

  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => TRUE ,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);

 retcode := 0;
EXCEPTION
WHEN G_PROFILE_NOT_SET THEN -- PROFILE NOT SET exception
  retcode := -1;

  BIS_COLLECTION_UTILITIES.put_line('Required Profiles are not set! ');

  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');

  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => FALSE ,
   p_message     => sqlerrm,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);
WHEN OTHERS THEN
 retcode := -1;
 errbuf  := sqlerrm;
IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
 BIS_COLLECTION_UTILITIES.Debug('Error in Populate Lines Fact:'||errbuf);
END IF;
 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_LINES_STG');
 ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');

 BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => FALSE ,
   p_message     => sqlerrm,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);
 RAISE;

END Populate_Lines_Fact;

-- Used for first time loading of the Quote Lines fact table.
-- Cleans up existing data from aso_bi_quote_lines_all if any
PROCEDURE Initial_Load_Lines(errbuf      OUT NOCOPY VARCHAR2,
                             retcode     OUT NOCOPY NUMBER,
                             p_from_date IN  VARCHAR2,
                             p_to_date   IN  VARCHAR2 )
AS
 l_from_date     Date ;
 l_to_date	 Date;
 l_missing_date  Boolean := FALSE;
 l_curr_count    NUMBER;
 l_list          DBMS_SQL.varchar2_table;
 l_valid_curr_setup Boolean;
BEGIN
 retcode := 0 ;
 l_valid_curr_setup := TRUE;

  Execute immediate 'alter session set hash_area_size=100000000';
  Execute immediate 'alter session set sort_area_size=100000000';
 --Purge the Base Fact Table for Quote Lines and the Refresh debug
 --for the Quote Lines load.
 BIS_COLLECTION_UTILITIES.deleteLogForObject('ASO_BI_LINE_FACTS');

 g_prim_currency := bis_common_parameters.get_currency_code;
 g_sec_currency := bis_common_parameters.get_secondary_currency_code;

 BIS_COLLECTION_UTILITIES.put_line('Secondary Currency :'||g_sec_currency);
 IF(BIS_COLLECTION_UTILITIES.Setup(p_object_name => 'ASO_BI_LINE_FACTS') = false)
 Then
   errbuf := FND_MESSAGE.Get;
   retcode := -1;
   RAISE_APPLICATION_ERROR(-20000,errbuf);
  End if;

  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.debug('Start Initial Load for Quote Lines Fact');
  END IF;

    -- Initialize
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
     BIS_COLLECTION_UTILITIES.debug('Initialization');
  END IF;
  BIS_COLLECTION_UTILITIES.put_line('Initialization');
  ASO_BI_UTIL_PVT.INIT;

  l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
  l_list(2) := 'BIS_PRIMARY_RATE_TYPE';
  l_list(3) := 'BIS_TREASURY_RATE_TYPE';
  /* Check seondary global currency is implemeneted */
  IF g_sec_currency IS NOT NULL THEN
    /* Seondary global currency is implemeneted then
       check for secondary rate type profile is set*/
    l_list(4) := 'BIS_SECONDARY_RATE_TYPE';
  ELSE
    BIS_COLLECTION_UTILITIES.put_line_out('Secondary Global Currency Not Implemented!!');
    BIS_COLLECTION_UTILITIES.put_line('Secondary Global Currency Not Implemented!!');
  END IF;
  IF NOT(bis_common_parameters.check_global_parameters(l_list))
  THEN
    errbuf := FND_MESSAGE.Get;
    retcode := -1;
--    RAISE_APPLICATION_ERROR(-20000,errbuf);
    RAISE G_PROFILE_NOT_SET;
  END IF;

  -- Truncate the processing tables
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.debug(
                'Cleaning up the tables before processing starts.');
  END IF;
  BIS_COLLECTION_UTILITIES.put_line('Cleaning up the tables before processing starts.');

  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_IDS');
  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_LINES_STG');
  ASO_BI_UTIL_PVT.Truncate_table('ASO_BI_LINE_IDS');
 -- As this is a initial load the Base Fact Table is assumed to be empty
  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_LINES_ALL');

  l_from_date := TRUNC(TO_DATE(p_from_date,'YYYY/MM/DD HH24:MI:SS'));
  l_to_date   := TRUNC(TO_DATE(p_to_date,'YYYY/MM/DD HH24:MI:SS'))+ 1 -
                ONE_SECOND;

  IF l_to_date < l_from_date THEN
    Retcode := -1;
    errbuf := 'To Date provided is less than From Date';
    Return;
  End If;
   BIS_COLLECTION_UTILITIES.put_line('Check for date range in fii tables.');
  -- Check for date range in fii tables
  FII_TIME_API.check_missing_date (p_from_date => l_from_date,
                                   p_to_date   => l_to_date,
                                   p_has_missing_date => l_missing_date);
  -- Handling missing date range
  If(l_missing_date) Then
    Retcode := -1;
    errbuf := 'There are missing dates in the date range';
    BIS_COLLECTION_UTILITIES.put_line(errbuf);
    Return;
  End If;
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('The date Range for collection is from ' ||
     p_from_date || ' to ' || p_to_date);

    BIS_COLLECTION_UTILITIES.Debug('Start populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
  END IF;
  BIS_COLLECTION_UTILITIES.put_line(' Collect the changed quote header ids, quote numbers');
  -- collect the changed quote header ids, quote numbers
  ASO_BI_QUOTE_FACT_PVT.InitLoad_Quote_Ids(
     p_from_date => l_from_date,
     p_to_date   => l_to_date) ;

  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('End populating ASO_BI_QUOTE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));

     -- Get the quote lines corresponding to the quotes changed in the time period
     BIS_COLLECTION_UTILITIES.put_line(' Get the quote lines corresponding to the quotes changed in the time period');
     BIS_COLLECTION_UTILITIES.Debug('Start populating ASO_BI_LINE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
  END IF;
  BIS_COLLECTION_UTILITIES.put_line('Quote Header Id Table Populated');
  -- collect the changed quote lines ids
  ASO_BI_LINE_FACT_PVT.initLoad_Quote_Line_ids;
  BIS_COLLECTION_UTILITIES.put_line('Quote Line Id Table Populated');
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('End populating ASO_BI_LINE_IDS: ' ||
     TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS'));
  END IF;

  /* Populate Currency Rates Table*/
  SELECT COUNT(*) INTO l_curr_count
  FROM ASO_BI_CURRENCY_RATES
  WHERE rownum < 2;
  IF l_curr_count = 0 THEN
     Populate_Conversion_Rates(p_from_date => l_from_date,
			         p_to_date => l_to_date,
                                p_run_type => 'INIT');
  END IF;

  IF g_sec_currency IS NOT NULL THEN
     BIS_COLLECTION_UTILITIES.put_line('Checking missing Primary/Functional/Secondary Currency rates ');
     If(Chk_Miss_Rates_Lines('PFS') = -1) Then
       l_valid_curr_setup := FALSE;
     End If;
  ELSE
     BIS_COLLECTION_UTILITIES.put_line('Checking missing Primary/Functional Currency rates ');
     If(Chk_Miss_Rates_Lines('PF') = -1) Then
        l_valid_curr_setup := FALSE;
     End If;
  END IF;
  IF NOT(l_valid_curr_setup) THEN
       Retcode := -1;
       BIS_COLLECTION_UTILITIES.wrapup(
           p_status      => FALSE ,
           p_count       => 0,
           p_period_from => l_from_date,
           p_period_to   => l_to_date);

       Return;
  END IF;
  BIS_COLLECTION_UTILITIES.put_line('Currency rate Table Populated');
  BIS_COLLECTION_UTILITIES.put_line(' load qot line staging table');

  -- load qot line staging table
  ASO_BI_LINE_FACT_PVT.InitiLoad_QotLineStg;
  BIS_COLLECTION_UTILITIES.put_line('Quote Line Staging Table Populated');

  -- Populate the Quote Lines table
  ASO_BI_LINE_FACT_PVT.InitiLoad_QotLine;
  BIS_COLLECTION_UTILITIES.put_line('Quote Line Fact Table Populated');

  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_LINES_STG');
  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');

  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => TRUE ,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);

  -- Indicates succesful completion
  retcode := 0;
EXCEPTION
WHEN G_PROFILE_NOT_SET THEN -- PROFILE NOT SET exception
  retcode := -1;

  BIS_COLLECTION_UTILITIES.put_line('Required Profiles are not set! ');
  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');

  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => FALSE ,
   p_message     => sqlerrm,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);
WHEN OTHERS THEN
  retcode := -1;
  errbuf  := sqlerrm;
  IF(BIS_COLLECTION_UTILITIES.g_debug) THEN
    BIS_COLLECTION_UTILITIES.Debug('Error in Initial Load of Quote Line Fact:'
                                ||errbuf);
  END IF;
  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_QUOTE_LINES_STG');
  ASO_BI_UTIL_PVT.Truncate_Table('ASO_BI_CURRENCY_RATES');

  BIS_COLLECTION_UTILITIES.wrapup(
   p_status      => FALSE ,
   p_message     => sqlerrm,
   p_count       => 0,
   p_period_from => l_from_date,
   p_period_to   => l_to_date);
  RAISE;
END Initial_Load_Lines ;


END ASO_BI_POPULATE_FACTS;

/
