--------------------------------------------------------
--  DDL for Package Body JTF_TTY_CAL_METRICS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_CAL_METRICS_PVT" AS
/* $Header: jtfvcamb.pls 120.1 2005/06/24 00:25:45 jradhakr ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_CAL_METRICS_PVT
--    PURPOSE : This package calculates the territory alignment metrics for all
--              named accounts
--
--      PROCEDUREs:
--         (see below for specIFication)
--
--
--
--
--    NOTES
--
--
--
--
--    HISTORY
--      08/08/03    SP         CREATED
--      06/22/05    JRADHAKR   Removed hard coded Schema Name 'JTF'
--
--    END of Comments
--

   G_METRIC_TYPE   VARCHAR2(30) := 'JTF_TTY_ALIGN_METRICS' ;
   G_DEBUG         BOOLEAN  := FALSE;

   /* Global System Variables */
   G_APPL_ID         NUMBER       := FND_GLOBAL.proG_APPL_ID();
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.login_id();
   G_CONC_LOGIN_ID   NUMBER       := FND_GLOBAL.conc_login_id();
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.conc_program_id();
   G_USER_ID         NUMBER       := FND_GLOBAL.user_id();
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.conc_request_id();

   DATE_PROFILES_NULL EXCEPTION;
   DATE_PROFILES_FMT  EXCEPTION;

   TYPE PARTY_LIST_TABLE  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   PROCEDURE print_log(p_string IN VARCHAR2)
   IS
        l_time VARCHAR2(60) := TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss');
   BEGIN

    IF G_DEBUG THEN
      --   dbms_output.put_line(l_time || ': ' || p_string);
         fnd_file.put_line(fnd_file.log,  l_time || ': ' || p_string);
    END IF;

  END print_log;

  PROCEDURE calculate_dnb_employees(partyList IN PARTY_LIST_TABLE)
  IS
       l_align_metric_code VARCHAR2(20) := 'DNB_NUM_EMPLOYEES' ;
       l_sysdate  DATE := SYSDATE;

  BEGIN

    FORALL i in partyList.FIRST ..partyList.LAST
       INSERT into jtf_tty_acct_metrics
       ( NAMED_ACCT_METRIC_ID
        ,OBJECT_VERSION_NUMBER
        ,NAMED_ACCOUNT_ID
        ,METRIC_LOOKUP_TYPE
        ,METRIC_LOOKUP_CODE
        ,METRIC_VALUE
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,PROGRAM_ID
        ,PROGRAM_LOGIN_ID
        ,PROGRAM_APPLICATION_ID
        ,REQUEST_ID
       )
       ( select  jtf_tty_acct_metrics_s.nextval,
                 1,
                 na.named_account_id,
                 G_METRIC_TYPE,
                 l_align_metric_code,
                 nvl(hzop.emp_at_primary_adr,0),
                 G_USER_ID,
                 l_sysdate,
                 G_USER_ID,
                 l_sysdate,
                 G_LOGIN_ID,
                 G_PROGRAM_ID,
                 G_CONC_LOGIN_ID,
                 G_APPL_ID,
                 G_REQUEST_ID
            from hz_organization_profiles hzop,
                 jtf_tty_named_accts na
           where hzop.party_id = na.party_id
             and sysdate between hzop.effective_start_date and nvl(hzop.effective_END_date, sysdate)
             and na.party_id = partyList(i)
         );


      print_log('    Inserted ' || SQL%ROWCOUNT || ' rows IN JTF_TTY_ACCT_METRICS ');
      COMMIT;

  END;


  PROCEDURE calculate_annual_revenue(partyList IN PARTY_LIST_TABLE)
  IS
       l_align_metric_code VARCHAR2(20) := 'DNB_ANNUAL_REVENUE' ;
       l_sysdate DATE := SYSDATE;
  BEGIN

      FORALL i in partyList.FIRST ..partyList.LAST
        INSERT into jtf_tty_acct_metrics
          ( NAMED_ACCT_METRIC_ID
           ,OBJECT_VERSION_NUMBER
           ,NAMED_ACCOUNT_ID
           ,METRIC_LOOKUP_TYPE
           ,METRIC_LOOKUP_CODE
           ,METRIC_VALUE
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,PROGRAM_ID
           ,PROGRAM_LOGIN_ID
           ,PROGRAM_APPLICATION_ID
           ,REQUEST_ID
          )
          ( select  jtf_tty_acct_metrics_s.nextval,
                 1,
                 na.named_account_id,
                 G_METRIC_TYPE,
                 l_align_metric_code,
                 nvl(hfn.financial_number,0),
                 G_USER_ID,
                 l_sysdate,
                 G_USER_ID,
                 l_sysdate,
                 G_LOGIN_ID,
                 G_PROGRAM_ID,
                 G_CONC_LOGIN_ID,
                 G_APPL_ID,
                 G_REQUEST_ID
           from hz_financial_numbers hfn,
                hz_financial_reports hfr,
                jtf_tty_named_accts na
         where hfn.financial_report_id = hfr.financial_report_id
           and hfr.type_of_financial_report = 'INCOME_STATEMENT'
           and hfn.financial_number_name = 'SALES'
           and hfr.party_id = na.party_id
           and hfr.actual_content_source = 'DNB'
           and hfn.actual_content_source = 'DNB'
           and hfr.report_end_date <=  l_sysdate
           and round(months_between (hfr.report_end_date, hfr.report_start_date ))  = 12
           and (  to_char(hfr.report_end_date, 'yyyy')  = to_char(l_sysdate, 'yyyy')  OR
                  to_char(hfr.report_end_date, 'yyyy')  = to_char(l_sysdate, 'yyyy')  - 1
               )
           and hfn.financial_number_currency = 'USD'
           and na.party_id = partyList(i)
         );


      print_log('    Inserted ' || SQL%ROWCOUNT || ' rows IN JTF_TTY_ACCT_METRICS ');
      COMMIT;

  END;



  PROCEDURE calculate_prior_sales(partyList IN PARTY_LIST_TABLE)
  IS

       l_align_metric_code VARCHAR2(20) := 'PRIOR_SALES' ;
       l_calc_start_date  DATE := NULL;
       l_calc_end_date  DATE := NULL;
       l_sysdate DATE := sysdate;
       l_char_date VARCHAR2(100) := NULL;

  BEGIN

     l_char_date := fnd_profile.value('JTF_TTY_ALIGN_METRIC_CAL_FROM_DT' );
     IF l_char_date IS NULL
     THEN
            raise DATE_PROFILES_NULL;
     END IF;
     l_calc_start_date := fnd_date.string_to_date( l_char_date, 'mm/dd/yyyy' );

     l_char_date := fnd_profile.value('JTF_TTY_ALIGN_METRIC_CAL_TO_DT' );
     IF l_char_date IS NULL
     THEN
          raise DATE_PROFILES_NULL;
     END IF;
     l_calc_end_date := fnd_date.string_to_date( l_char_date, 'mm/dd/yyyy' );

     IF ( l_calc_start_date IS NULL ) OR ( l_calc_end_date IS NULL )
     THEN
       raise DATE_PROFILES_FMT;
     END IF;


     FORALL i in partyList.FIRST ..partyList.LAST
       INSERT into jtf_tty_acct_metrics
       (NAMED_ACCT_METRIC_ID
        ,OBJECT_VERSION_NUMBER
        ,NAMED_ACCOUNT_ID
        ,METRIC_LOOKUP_TYPE
        ,METRIC_LOOKUP_CODE
        ,METRIC_VALUE
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,PROGRAM_ID
        ,PROGRAM_LOGIN_ID
        ,PROGRAM_APPLICATION_ID
        ,REQUEST_ID
        )
       ( select  jtf_tty_acct_metrics_s.nextval,
                 1,
                 na_list.named_account_id,
                 G_METRIC_TYPE,
                 l_align_metric_code,
                 na_list.prior_sales,
                 G_USER_ID,
                 l_sysdate,
                 G_USER_ID,
                 l_sysdate,
                 G_LOGIN_ID,
                 G_PROGRAM_ID,
                 G_LOGIN_ID,
                 G_APPL_ID,
                 G_REQUEST_ID
           from ( select na.named_account_id,
                         nvl(sum(l.total_amount),0) prior_sales
                    from as_leads_all l,
                         as_statuses_b s,
                         jtf_tty_named_accts na
                   where l.status = s.status_code
                     and s.win_loss_indicator = 'W'
                     and l.decision_date between l_calc_start_date and l_calc_end_date
                     and l.customer_id = na.party_id
                     and na.party_id = partyList(i)
                  group by na.named_account_id
                ) na_list

         );

      print_log('    Inserted ' || SQL%ROWCOUNT || ' rows IN JTF_TTY_ACCT_METRICS ');
      COMMIT;

  END;

PROCEDURE calculate_acct_metrics
( ERRBUF          OUT NOCOPY  VARCHAR2
, RETCODE         OUT NOCOPY  VARCHAR2
, p_metric_code   IN          VARCHAR2
, p_debug_flag    IN          VARCHAR2
) IS

   l_proc_name         VARCHAR2(30) := 'CALCULATE_ACCT_METRICS';
   l_return_status     VARCHAR2(320) := NULL;
   l_error_message     VARCHAR2(320) := NULL;


   CURSOR c_get_parties
   IS
   SELECT party_id
     FROM jtf_tty_named_accts;

   partyList PARTY_LIST_TABLE;
   numRows   NATURAL := 10000;

   l_status         VARCHAR2(30);
   l_industry       VARCHAR2(30);
   l_jtf_schema     VARCHAR2(30);
   l_trunc_statement VARCHAR2(256);
   L_SCHEMA_NOTFOUND  EXCEPTION;

   i binary_integer := 0;
   numRowsProcessed binary_integer := 0;

BEGIN

      IF upper( rtrim(p_Debug_Flag) ) = 'Y' THEN
         G_Debug := TRUE;
      END IF;

      print_log('Parameters : Metric Code - ' || p_metric_code );
      print_log('Start of ' || l_proc_name);

       IF(FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
         NULL;
       END IF;

       IF (l_jtf_schema IS NULL) THEN
         RAISE L_SCHEMA_NOTFOUND;
       END IF;


      IF p_metric_code = 'ALL'
      THEN
         l_trunc_statement := 'Truncate table ' || l_jtf_schema || '.JTF_TTY_ACCT_METRICS';
         print_log('  Truncating table JTF_TTY_ACCT_METRICS ');
         EXECUTE IMMEDIATE l_trunc_statement;
         print_log('  Completed Truncating table JTF_TTY_ACCT_METRICS ');
      ELSE
         print_log('  Deleting from JTF_TTY_ACCT_METRICS ');
         delete from JTF_TTY_ACCT_METRICS where metric_lookup_code = p_metric_code;
         print_log('  Completed deleting ' || SQL%ROWCOUNT || ' rows from JTF_TTY_ACCT_METRICS ');
      END IF;

      print_log('  Starting Processing of Named Accounts Loop');
      OPEN c_get_parties;
      LOOP
         /* The following statement fetches numRows (or less). */
         FETCH c_get_parties BULK COLLECT INTO partyList LIMIT numRows;


         print_log('   Started Processing ' || partyList.count ||  ' rows from JTF_TTY_NAMED_ACCTS' );
         IF (p_metric_code = 'ALL') OR ( p_metric_code = 'DNB_NUM_EMPLOYEES' )
         THEN
            print_log('   Calculating DNB EMployees ');
            l_proc_name    := 'CALCULATE_DNB_EMPLOYEES';
            calculate_dnb_employees(partyList);
         END IF;


         IF (p_metric_code = 'ALL') OR ( p_metric_code = 'DNB_ANNUAL_REVENUE' )
         THEN
            print_log('   Calculating DNB Annual Revenue ');
            l_proc_name    := 'CALCULATE_DNB_ANNUAL_REVENUE';
            calculate_annual_revenue(partyList);
         END IF;

         IF (p_metric_code = 'ALL') OR ( p_metric_code = 'PRIOR_SALES' )
         THEN
            print_log('   Calculating Prior Sales ');
            l_proc_name    := 'CALCULATE_PRIOR_SALES';
            calculate_prior_sales(partyList);
         END IF;


         print_log('   Completed Processing ' || partyList.count ||  ' rows from JTF_TTY_NAMED_ACCTS' );
         EXIT WHEN c_get_parties%NOTFOUND;

        i := i + 1;
        numRowsProcessed := numRows * i;

      END LOOP;
      print_log('  Completed Processing of Named Accounts Loop');

      CLOSE c_get_parties;
      ERRBUF := 'Program completed successfully.';
      RetCode := 0;

      print_log('End of CALCULATE_ACCT_METRICS. Program completed successfully');

EXCEPTION

     WHEN fnd_file.utl_file_error THEN
              ERRBUF := 'Program terminated with exception. Error writing to output file.';
              RETCODE := 2;

     WHEN DATE_PROFILES_NULL THEN
              print_log('Territory Alignment Alignment Metric Calculation Date profiles are not set.' ) ;
              print_log('Program terminated with exception.' ) ;
              ERRBUF := 'Program terminated with exception. Territory Alignment Date Profiles Not Set.';
              RETCODE := 2;

    WHEN DATE_PROFILES_FMT THEN
              print_log('Territory Alignment Alignment Metric Calculation Date profiles are not specified in correct format (mm/dd/yyyy).' ) ;
              print_log('Program terminated with exception.' ) ;
              ERRBUF := 'Program terminated with exception. Territory Alignment Date Profiles not specified in correct format (mm/dd/yyyy).';
              RETCODE := 2;
     WHEN L_SCHEMA_NOTFOUND THEN
            print_log('Schema name JTF does not exist  ');
            ERRBUF  := 'JTF_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES: [END] SCHEMA NAME FOUND CORRESPONDING TO JTF APPLICATION. ';
            RETCODE := 2;

     WHEN OTHERS THEN
            print_log('Program terminated with OTHERS exception. ' || SQLERRM);
            ERRBUF  := 'Program terminated with OTHERS exception. ' || SQLERRM;
            RETCODE := 2;


END;


END  JTF_TTY_CAL_METRICS_PVT;

/
