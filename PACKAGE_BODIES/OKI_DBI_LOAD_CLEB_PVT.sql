--------------------------------------------------------
--  DDL for Package Body OKI_DBI_LOAD_CLEB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_LOAD_CLEB_PVT" AS
/* $Header: OKIRILEB.pls 120.28 2008/01/10 19:08:30 syeddana ship $ */

  g_debug  BOOLEAN;
  g_4712_date  date;
  g_9999_date  date;
  g_0001_date  date;
  g_euro_start_date  date;
  g_global_start_date   DATE;
  g_no_of_workers NUMBER;
  g_true_incr NUMBER;
  g_del_count NUMBER;
  g_contracts_count NUMBER;
  g_batch_size NUMBER;
  g_renewal_id number;
  g_ren_con_id number;

  TYPE WorkerList is table of NUMBER index by binary_integer;
  g_worker WorkerList;

  G_CHILD_PROCESS_ISSUE         EXCEPTION;

/* *****************************************************************************
    Procedure:rlog
	Description:Procedure to write messages to the log file
	Parameters: p_string : The message to be written onto the log
				p_indent : Indentation of the message
   ************************************************************************** */
  PROCEDURE rlog (  p_string IN VARCHAR2,  p_indent IN NUMBER ) IS
  BEGIN
     BIS_COLLECTION_UTILITIES.log(p_string,p_indent);
  EXCEPTION
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_LOAD_CLEB_PVT.log' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END rlog;

/* *****************************************************************************
    Procedure:rout
	Description:Procedure to write messages to the output file
	Parameters:	p_string : The message to be written onto the log
				p_indent : Indentation of the message
   ************************************************************************** */

  PROCEDURE rout (  p_string IN VARCHAR2,  p_indent IN NUMBER ) IS
  BEGIN
     BIS_COLLECTION_UTILITIES.out(p_string,p_indent);
  EXCEPTION
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_LOAD_CLEB_PVT.out ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END rout;

/* *****************************************************************************
    Procedure:gather_table_stats
	Description:Procedure to gather table stats
	Parameters: tabname : The name of the table/mv on which statistics should be gathered
   ************************************************************************** */
PROCEDURE gather_table_stats (tabname varchar2)
IS

  l_sql_string VARCHAR2(2000);
BEGIN
     FND_STATS.GATHER_TABLE_STATS( OWNNAME=>'OKI' ,
                                   TABNAME=>tabname );

     l_sql_string := 'alter session enable parallel dml' ;
     EXECUTE IMMEDIATE l_sql_string ;

EXCEPTION
    WHEN OTHERS THEN
       rlog( 'Unexpected Error while gathering statistics on '|| tabname ||' table :'|| SQLERRM, 2 );
END;
/* *****************************************************************************
   Procedure:Initial_load
   Description:Performs the inital steps like altering hash and sort areas before calling
   populate_base_tables. This is called during initial load
   Parameters:
   errbuf -Mandatory out parameter containing error message to be passed back to the concurrent manager
   retcode-Mandatory out parameter containing the Oracle error number to be passed back to the concurrent manager
   p_startdate - user entered from date
   p_end_date  - user entered to date
   ************************************************************************** */

  PROCEDURE initial_load(
                         errbuf  OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY VARCHAR2,
                         p_start_date IN VARCHAR2,
                         p_end_date IN VARCHAR2
                         ) IS
     l_sql_string  VARCHAR2(2000);
     l_setup_ok     BOOLEAN ;
     l_run_date     DATE;
  BEGIN

     l_setup_ok   := FALSE;
     g_4712_date := to_date('01/01/4712' , 'MM/DD/YYYY');
     g_9999_date  := to_date('12-31-9999' ,'MM-DD-YYYY');
     g_0001_date  := to_date('01-01-0001' ,'MM-DD-YYYY');
     g_euro_start_date := to_date('01/01/1999','MM/DD/RRRR');
     l_run_date   := SYSDATE;
     l_setup_ok := BIS_COLLECTION_UTILITIES.setup('OKIDBICLEB');
     IF (NOT l_setup_ok) THEN
         errbuf := fnd_message.get;
         rlog( 'BIS Setup Failure ',0);
         RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
     END IF;

     rlog( 'Service Contracts Intelligence -  INITIAL LOAD:  ' ||
            fnd_date.date_to_displayDT(sysdate),0);
     rlog( 'Parameter : Start date        '|| fnd_date.date_to_displayDT(to_date(p_start_date,'yyyy/mm/dd hh24:mi:ss')), 1);
     rlog( 'Parameter : End date          '|| fnd_date.date_to_displayDT(to_date(p_end_date,'yyyy/mm/dd hh24:mi:ss')), 1);

     l_sql_string := 'alter session set hash_area_size=100000000';
     EXECUTE IMMEDIATE l_sql_string;
     l_sql_string := 'alter session set sort_area_size=100000000';
     EXECUTE IMMEDIATE l_sql_string;
    -- Lesters feedback 5/19/04
     l_sql_string := 'alter session  set workarea_size_policy = manual';
     EXECUTE IMMEDIATE l_sql_string;

      OKI_DBI_LOAD_CLEB_PVT.g_load_type := 'INITIAL LOAD';
      rlog( 'Resetting base tables and BIS log file  ' ||
                                        fnd_date.date_to_displayDT(sysdate),1);
     reset_base_tables(errbuf, retcode);

      IF(retcode  = 0 )
      THEN
         populate_base_tables(errbuf,
                              retcode,
                              p_start_date,
                              p_end_date,
                              1);
      END IF;

      rlog( 'DONE : Initial Load Successfully completed ' ||
                                        fnd_date.date_to_displayDT(sysdate),0);
    DECLARE
      l_days     NUMBER;
      l_hours    NUMBER;
      l_minutes  NUMBER;
      l_seconds  NUMBER;
      l_date     TIMESTAMP;
      l_Str      VARCHAR2(1000);
    BEGIN
       l_date    := TO_TIMESTAMP(SYSDATE);
       l_days    := EXTRACT (day FROM l_date - l_run_date);
       l_hours   := EXTRACT (hour FROM l_date - l_run_date);
       l_minutes := EXTRACT (minute FROM l_date - l_run_date);
       l_seconds := EXTRACT (second FROM l_date - l_run_date);
           l_str := 'Load Successfully Completed in ';
       IF ( l_days <> 0 ) THEN
       	l_str := l_str || l_days || ' Days ';
       END IF;
       IF ( l_hours <> 0 ) THEN
       	l_str := l_str || l_hours || ' Hours ';
       END IF;
       if ( l_minutes <> 0 ) THEN
       	l_str := l_str || l_minutes || ' Minutes ';
       END IF;
       if ( l_seconds <> 0 ) THEN
       	l_str := l_str || l_seconds || ' Seconds ';
       END IF;
       rlog (l_str,0);
    EXCEPTION
      WHEN OTHERS THEN
        rlog('Unable to calculate load ran time ', 0);
    END;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       RAISE;
    WHEN OTHERS THEN
      errbuf  := SQLERRM ;
      retcode := SQLCODE ;
       bis_collection_utilities.put_line(errbuf || '' || retcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(
                              token => 'ROUTINE'
                            , value => 'OKI_DBI_LOAD_CLEB_PVT.INITIAL_LOAD ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END initial_load;

/* *****************************************************************************
   Procedure:reset_base_tables
   Description:Procedure to reset OKI DBI table
   Parameters:
   errbuf: The error message to be passed back to caller
   retcode: Oracle error number
   ************************************************************************** */
  PROCEDURE reset_base_tables  (
                                  errbuf  OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY VARCHAR2
                                ) IS

     l_sql_string   VARCHAR2(4000);
     l_oki_schema   VARCHAR2(30);
     l_status       VARCHAR2(30);
     l_industry     VARCHAR2(30);

  BEGIN
   retcode := 0;

   IF (FND_INSTALLATION.GET_APP_INFO('OKI', l_status, l_industry, l_oki_schema)) THEN

     l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema || '.OKI_DBI_CHR_STAGE_INC' ;
     EXECUTE IMMEDIATE l_sql_string ;
     rlog( 'Truncated Table OKI_DBI_CHR_STAGE_INC',2);

     l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema || '.OKI_DBI_CHR_INC' ;
     EXECUTE IMMEDIATE l_sql_string ;
     rlog( 'Truncated Table OKI_DBI_CHR_INC',2);

     l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema ||'.OKI_DBI_CURR_CONV';
     EXECUTE IMMEDIATE l_sql_string;
     rlog( 'Truncated table OKI_DBI_CURR_CONV' ,2);

     l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema ||'.OKI_DBI_CLE_B_OLD';
     EXECUTE IMMEDIATE l_sql_string;
     rlog( 'Truncated Table OKI_DBI_CLE_B_OLD' ,2);

-- RSG is now dropping the MV log before doing the initial load
--     l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema ||'.MLOG$_OKI_DBI_CLE_B';
--     l_sql_string := 'TRUNCATE TABLE MLOG$_OKI_DBI_CLE_B';
--     EXECUTE IMMEDIATE l_sql_string;
--     rlog( 'Base table LOG MLOG_OKI_DBI_CLE_B was truncated ' ,2);

     l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema ||'.OKI_DBI_CLE_B';
     EXECUTE IMMEDIATE l_sql_string;
     rlog( 'Truncated Table OKI_DBI_CLE_B' ,2);

     BIS_COLLECTION_UTILITIES.DeleteLogForObject('OKIDBICLEB');
     rlog( 'Completed resetting base tables and BIS log file ' || fnd_date.date_to_displayDT(sysdate),1);
  END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR  THEN
       RAISE;
    WHEN OTHERS
    THEN
       errbuf  := sqlerrm;
       retcode := sqlcode;
       bis_collection_utilities.put_line(errbuf || '' || retcode ) ;
       fnd_message.set_name(  application => 'FND'
                          , name          => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(
                         token => 'ROUTINE'
                     ,   value => 'OKI_DBI_LOAD_CLEB_PVT.RESET_BASE_TABLES ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END reset_base_tables;

  /* *****************************************************************************
   Procedure:populate_base_tables
   Description:This procedure calls different procedures based on the type of load
   Parameters:
   errbuf: The error message to be passed back to caller
   retcode: Oracle error number
   p_start_date: User entered from date
   p_end_date: User entered to date
   p_no_of_workers: User entered number of sub workers ( for incremental load )
   ************************************************************************** */

  PROCEDURE populate_base_tables (
                                  errbuf  OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY VARCHAR2,
                                  p_start_date IN VARCHAR2,
                                  p_end_date IN VARCHAR2,
                                  p_no_of_workers IN NUMBER
                                ) IS
     l_start_date   DATE;
     l_end_date     DATE;
     l_run_date     DATE;
     l_setup_ok     BOOLEAN;
     l_count        NUMBER ;
     l_ren_count    NUMBER;
     l_max_ren_batch    NUMBER;
     l_recs_processed NUMBER;
     l_missing_flag NUMBER;
     l_exception exception;
  BEGIN
     l_setup_ok     := FALSE;
     l_count        := 0 ;
     l_ren_count    := 0;
     l_max_ren_batch  := 0;
     l_recs_processed := 0 ;
     l_missing_flag := 0;

     g_true_incr := 0;
     g_4712_date := to_date('01/01/4712' , 'MM/DD/YYYY');
     g_9999_date  := to_date('12-31-9999' ,'MM-DD-YYYY');
     g_0001_date  := to_date('01-01-0001' ,'MM-DD-YYYY');
     g_euro_start_date := to_date('01/01/1999','MM/DD/RRRR');

     l_run_date   :=  sysdate;
     g_global_start_date :=  bis_common_parameters.get_global_start_date;
     g_no_of_workers := p_no_of_workers;

     IF( NVL(OKI_DBI_LOAD_CLEB_PVT.g_load_type,'INC LOAD') <> 'INITIAL LOAD')
     THEN
        l_setup_ok := BIS_COLLECTION_UTILITIES.setup('OKIDBICLEB');
        IF (NOT l_setup_ok) THEN
            errbuf := fnd_message.get;
            rlog( 'BIS Setup Failure ',0);
            RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
        END IF;

        rlog( 'Service Contracts Intelligence - INCREMENTAL LOAD ' || fnd_date.date_to_displayDT(sysdate),0);
        rlog( 'Number of workers requested : ' || g_no_of_workers,0);
     END IF;

     g_debug := BIS_COLLECTION_UTILITIES.G_DEBUG;

    -- Check to see if User entered the start date for incremental load as param.
    -- if not default to previous last refresh of load date.(from bis_refresh_log)

	 IF( NVL(OKI_DBI_LOAD_CLEB_PVT.g_load_type,'INC LOAD') <> 'INITIAL LOAD')
     THEN
			IF(p_start_date IS NULL )
		     THEN
				l_start_date := fnd_date.displaydt_to_date(BIS_COLLECTION_UTILITIES.get_last_refresh_period('OKIDBICLEB'))
                               - 0.004;
		        g_true_incr :=1;
		     ELSE
				l_start_date :=  to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS') - 0.004;
		     END IF;
     ELSE
	l_start_date :=  to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS') ;
     END IF;

	-- End date for load is defaulted to sysdate/ run_date
	 IF(p_end_date is NULL)
     THEN
        l_end_date   := l_run_date;
     ELSE
        l_end_date   :=  to_date(p_end_date,'YYYY/MM/DD HH24:MI:SS');
     END IF;

     OKI_DBI_LOAD_CLEB_PVT.g_start_date := l_start_date;
     OKI_DBI_LOAD_CLEB_PVT.g_end_date   := l_end_date;
     OKI_DBI_LOAD_CLEB_PVT.g_run_date   := l_run_date;

     IF( NVL(OKI_DBI_LOAD_CLEB_PVT.g_load_type,'INC LOAD') <> 'INITIAL LOAD')
     THEN
        rlog( 'Start date  -          '|| fnd_date.date_to_displayDT(l_start_date),1);
        rlog( 'End date    -          '|| fnd_date.date_to_displayDT(l_end_date),1);
        rlog( 'Processing Deletes           ' || fnd_date.date_to_displayDT(sysdate),1);
        OKI_DBI_LOAD_CLEB_PVT.process_deletes;
        OKI_DBI_LOAD_CLEB_PVT.populate_inc_table_inc;
     ELSE
        OKI_DBI_LOAD_CLEB_PVT.populate_inc_table_init;
     END IF;

     rlog( 'Populating Currencies Table OKI_DBI_CURR_CONV - ' || fnd_date.date_to_displayDT(sysdate),1);
     OKI_DBI_LOAD_CLEB_PVT.load_currencies;
     rlog( 'Load of Currencies Table OKI_DBI_CURR_CONV completed - ' || fnd_date.date_to_displayDT(sysdate),1);

     rlog( 'Checking negative rates in Table OKI_DBI_CURR_CONV - ' ||
               fnd_date.date_to_displayDT(sysdate),1);
	 SELECT COUNT(1) INTO l_missing_flag
     FROM oki_dbi_curr_conv
	 --WHERE upper(rate_type) <> 'USER'
     WHERE (rate_f <= 0 OR rate_g < 0 OR rate_sg < 0 OR rate_f is NULL);


     IF(nvl(l_missing_flag,0) > 0)   -- There are missing currencies
     THEN
        rlog( 'Reporting Missing Currencies ' ||   fnd_date.date_to_displayDT(sysdate),1);
        OKI_DBI_LOAD_CLEB_PVT.report_missing_currencies;

        errbuf  := 'There are missing currencies';
	  rlog( 'ERROR : Missing Currencies, view output file for details',0);
          retcode := 2;
          RAISE_APPLICATION_ERROR (-20000, 'Error in INC table collection: ' || errbuf);
        COMMIT ;
     END IF ;

     IF( OKI_DBI_LOAD_CLEB_PVT.g_load_type = 'INITIAL LOAD')
     THEN
         OKI_DBI_LOAD_CLEB_PVT.direct_load(l_recs_processed);
     ELSE

      IF ( g_contracts_count > 0 OR g_del_count > 0 ) THEN
         OKI_DBI_LOAD_CLEB_PVT.incr_load(l_recs_processed);
      ELSE
         rlog ('No contracts are identified for update/delete',1);
      END IF;

     END IF;
     l_count := l_count + l_recs_processed ;

     IF l_count IS NULL THEN
     	  l_count := 0;
     END IF;

     BIS_COLLECTION_UTILITIES.wrapup(TRUE,
                                     l_count,
                                     'OKI DBI COV LINES COLLECTION SUCCEEDED',
                                     OKI_DBI_LOAD_CLEB_PVT.g_start_date,
                                     OKI_DBI_LOAD_CLEB_PVT.g_end_date
                                     );

    IF( NVL(OKI_DBI_LOAD_CLEB_PVT.g_load_type,'INC LOAD') <> 'INITIAL LOAD') THEN
	   rlog('SUCCESS: Load Program Successfully completed ' || fnd_date.date_to_displayDT(SYSDATE),0);
       DECLARE
         l_days    NUMBER;
         l_hours   NUMBER;
         l_minutes NUMBER;
         l_seconds NUMBER;
         l_date    TIMESTAMP;
         l_str     VARCHAR2(1000);
       BEGIN
          l_date    := TO_TIMESTAMP(SYSDATE);
          l_days    := EXTRACT (day FROM l_date - l_run_date);
          l_hours   := EXTRACT (hour FROM l_date - l_run_date);
          l_minutes := EXTRACT (minute FROM l_date - l_run_date);
          l_seconds := EXTRACT (second FROM l_date - l_run_date);
          l_str := 'Load Completed in ';
          IF ( l_days <> 0 ) THEN
          	l_str := l_str || l_days || ' Days ';
           ELSif l_days =1 then
           	l_str := l_str || l_days || ' Day ';
          END IF;
          IF ( l_hours <> 0 ) THEN
          	l_str := l_str || l_hours || ' Hours ';
          elsIF ( l_hours =1 ) THEN
          	l_str := l_str || l_hours || ' Hour ';
          END IF;
          IF ( l_minutes <> 0 ) THEN
          	l_str := l_str || l_minutes || ' Minutes ';
          ELSIF ( l_minutes = 1 ) THEN
          	l_str := l_str || l_minutes || ' Minute ';
          END IF;
          IF ( l_seconds <> 0 ) THEN
          	l_str := l_str || l_seconds || ' Seconds ';
          ELSIF ( l_seconds =1 ) THEN
          	l_str := l_str || l_seconds || ' Second ';
          END IF;

          rlog (l_str,0);
       EXCEPTION
          WHEN OTHERS THEN
             rlog('Unable to calculate load running time ', 0);
       END;
   END IF;

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       RAISE;
     WHEN OTHERS
     THEN
       retcode := SQLCODE ;
       errbuf  := SQLERRM ;
       BIS_COLLECTION_UTILITIES.wrapup(FALSE,
                                         l_count,
                                         errbuf || ': ' || retcode,
                                         OKI_DBI_LOAD_CLEB_PVT.g_start_date,
                                         OKI_DBI_LOAD_CLEB_PVT.g_end_date
                                         ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(
                      token => 'ROUTINE'
                    , value => 'OKI_DBI_LOAD_CLEB_PVT.populate_base_tables ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END populate_base_tables;

/* *****************************************************************************
   Procedure:populate_inc_table_init
   Description:Procedure to populate incremental table for Initial load.
   Check okc_k_vers_numbers table for new/modified contracts
   ************************************************************************** */

  PROCEDURE populate_inc_table_init IS
    l_start_date  DATE ;
    l_end_date    DATE ;
    l_batch_size  NUMBER ;
    l_sql_string  VARCHAR2(10000) ;

    l_oki_schema  VARCHAR2(30) ;
    l_status      VARCHAR2(30) ;
    l_industry    VARCHAR2(30) ;
    l_count       NUMBER ;
    l_count2       NUMBER;
    l_global_curr VARCHAR(30);
	--Added by Arun for secondary global currency conversion
    l_sglobal_curr VARCHAR(30);
    l_conv_type   VARCHAR2(40);
    l_salesperson_code VARCHAR2(80) ;
    l_sysdate     DATE ;
    l_rate_type   VARCHAR2(1000);
    l_srate_type   VARCHAR2(1000);
    l_annu_curr_code   VARCHAR2(100);


  BEGIN


    l_start_date  := OKI_DBI_LOAD_CLEB_PVT.G_Start_Date;
    l_end_date    := OKI_DBI_LOAD_CLEB_PVT.G_End_Date;
    l_global_curr := BIS_COMMON_PARAMETERS.Get_Currency_Code;
    l_sysdate     := OKI_DBI_LOAD_CLEB_PVT.G_Run_Date;
    l_rate_type   := BIS_COMMON_PARAMETERS.Get_Rate_Type;
    l_srate_type   := bis_common_parameters.get_secondary_rate_type ;
    l_annu_curr_code := CASE bis_common_parameters.get_annualized_currency_code
                              WHEN  'PRIMARY' THEN 'Primary'
                              WHEN  'SECONDARY' THEN 'Secondary'
                              ELSE 'Not Defined'
                        END;


    -- Added by Arun for secondary global currency conversion changes
    IF(POA_CURRENCY_PKG.display_secondary_currency_yn)
    THEN
       -- Check if Sec currency Display profile is set
       IF BIS_COMMON_PARAMETERS.Get_Secondary_Currency_Code IS NOT NULL
         THEN l_sglobal_curr := BIS_COMMON_PARAMETERS.Get_Secondary_Currency_Code;
       END IF;
    END IF;
	l_conv_type   := bis_common_parameters.get_treasury_rate_type;

    rlog ('Treasury Rate Type is - '||NVL(l_conv_type, 'Not Defined'),1);

	IF l_conv_type is NULL THEN
    l_conv_type   := bis_common_parameters.get_rate_type ;
    END IF;

    rlog ('Primary Rate Type is - '||NVL(l_rate_type,'Not Defined'),1);
	rlog ('Secondary Rate Type is - '||NVL(l_srate_type,'Not Defined'),1);
	rlog ('Primary Global Currency is - '||NVL(l_global_curr,'Not Defined'),1);
	rlog ('Secondary Global Currency is - '||NVL(l_sglobal_curr,'Not Defined'),1);
	rlog ('Annualized Global Currency is - '||l_annu_curr_code,1);


    l_salesperson_code := fnd_profile.value('OKS_ENABLE_SALES_CREDIT');
    IF l_salesperson_code IN ('YES', 'DRT') THEN /* Added 'DRT' filter condition, Please refer Bug#5978601 */
      l_salesperson_code := fnd_profile.value('OKS_VENDOR_CONTACT_ROLE');
    ELSE
      l_salesperson_code := 'SALESPERSON';
    END IF ;

	rlog ('Sales Person Code  - '||l_salesperson_code,1);
    SELECT NVL(BIS_COMMON_PARAMETERS.get_batch_size(BIS_COMMON_PARAMETERS.HIGH)
               , 1000)
    INTO   l_batch_size
    FROM DUAL ;

    rlog( 'Populating Incremental Staging Table OKI_DBI_CHR_STAGE_INC -  ' || fnd_date.date_to_displayDT(sysdate),1);

	SELECT MAX(renewal_id),MAX(ren_con_id)
	INTO g_renewal_id,g_ren_con_id
	from
	(
	SELECT decode(opn_code,'RENEWAL',id,null) Renewal_ID, decode(opn_code,'REN_CON',id,null) Ren_CON_ID
	from okc_class_operations clsop
	WHERE clsop.cls_code='SERVICE'
	AND clsop.opn_code in ('RENEWAL','REN_CON')
	);

  INSERT /*+ append */ INTO OKI_DBI_CHR_STAGE_INC
      ( id,
        currency_code,
        date_approved,
        creation_date,
        conversion_rate_date,
        conversion_type,
        conversion_rate,
        end_date,
        authoring_org_id,
				application_id,
				contract_number,
				contract_number_modifier,
				buy_or_sell,
				scs_code,
				trn_code,
				date_signed,
				start_date,
				date_terminated,
				renewal_type_code,
				sts_code,
				datetime_cancelled,
				last_update_date,
				Bill_to_site_use_id,
				Ship_to_site_use_id,
				inv_organization_id,
				subsequent_renewal_type_code, /* for ER#5760744 */
				hdr_term_cancel_source  /* for ER 6684955 */
     )
      SELECT /*+ parallel(h) parallel(v) */  h.id
            , h.currency_code
            , h.date_approved
            , h.creation_date
            , h.conversion_rate_date
            , h.conversion_type
            , h.conversion_rate
            , h.end_date
            , h.authoring_org_id
	    			, h.application_id
	    			, h.contract_number
	    			, h.contract_number_modifier
	    			, h.buy_or_sell
	    			, h.scs_code
	    			, h.trn_code
	    			, h.date_signed
	    			, h.start_date
	    			, h.date_terminated
	    			, h.renewal_type_code
	    			, h.sts_code
	    			, h.datetime_cancelled
	    			, h.last_update_date
	    			, h.Bill_to_site_use_id
	    			, h.Ship_to_site_use_id
	    			, h.inv_organization_id
	    			, decode(h.renewal_type_code, 'ERN', Decode(h.approval_type, 'M', 'ERN'),
							       'EVN', decode(h.approval_type, 'Y', 'EVN', 'N', 'EVN'),
							       'DNR', 'DNR',
							       'NSR', decode(h.approval_type, 'Y', 'NSR', 'N', 'NSR', 'NSR')
										) subsequent_renewal_type_code /* Added this colunm as a part of ER#5760744 */
						,h.term_cancel_source  hdr_term_cancel_source  /* Added for ER 6684955 */
      FROM   okc_k_headers_all_b h
           , okc_k_vers_numbers v
      WHERE 1=1
      AND
	  (
		(
			v.last_update_date   >= l_start_date
			AND v.last_update_date+0 <= l_end_date
			AND COALESCE(h.date_terminated,h.datetime_cancelled,h.end_date,g_4712_date) > g_global_start_date
		)
		OR
		(   /* Retrieve open contracts that do not fall within the initial load date range, for disco */
			v.last_update_date   < l_start_date
			AND h.datetime_cancelled is NULL
			AND h.date_signed is NULL
			AND h.date_terminated is NULL -- This check is for bad data which have date terminated without date signed
		)
	  )
	  AND h.id                = v.chr_id
	  AND h.template_yn       = 'N'
      AND h.application_id    = 515
      AND h.buy_or_sell       ='S'
      AND h.scs_code IN ('SERVICE','WARRANTY') ;

      l_count := SQL%ROWCOUNT ;

      rlog( 'Number of contracts inserted into OKI_DBI_CHR_STAGE_INC : '||to_char(l_count), 2) ;
      COMMIT;

      GATHER_TABLE_STATS(TABNAME => 'OKI_DBI_CHR_STAGE_INC');

      rlog('Load of Incremental Staging Table OKI_DBI_CHR_STAGE_INC completed -    ' ||
                                        fnd_date.date_to_displayDT(SYSDATE),1) ;

      rlog( 'Populating Incremental Table OKI_DBI_CHR_INC -  ' || fnd_date.date_to_displayDT(sysdate),1);

      INSERT /*+ append parallel(a) */ INTO  oki_dbi_chr_inc  a
      (
             chr_id
           , conversion_date
           , trx_rate_type
           , trx_currency
           , func_currency
           , trx_func_rate
           , batch_id
           , grace_end_date
           , salesrep_id
           , resource_id
           , resource_group_id
           , gsd_flag
	   , authoring_org_id
   	   , application_id
	   , contract_number
	   , contract_number_modifier
	   , buy_or_sell
	   , scs_code
	   , trn_code
	   , date_signed
	   , start_date
	   , end_date
	   , date_terminated
	   , renewal_type_code
	   , sts_code
	   , date_approved
	   , datetime_cancelled
	   , creation_Date
	   , last_update_date
	   , Bill_to_site_use_id
	   , Ship_to_site_use_id
	   , est_rev_percent
	   , est_rev_date
	   , Acct_rule_id
	   , master_organization_id
	   , customer_party_id
	   , order_number
	   , subsequent_renewal_type_code     /* for ER#5760744 */
	   , negotiation_status               /* for ER#5950128 */
	   , reminder                         /* for ER#5950128 */
	   , hdr_term_cancel_source           /* Added for ER 6684955 */
      ) SELECT k.id
               , trunc(COALESCE(k.conversion_date, k.date_approved, k.creation_date)) CONVERSION_DATE
               , (CASE WHEN k.currency_code = k.sob_currency_code
                       THEN l_rate_type
                       ELSE oki_dbi_currency_pvt.get_trx_rate_type_init(
                                  k.id
                                , k.currency_code
                                , k.sob_currency_code
                                , NVL(k.date_approved, k.creation_date)
                                , k.conversion_date
                                , k.conversion_type
                                , k.trx_func_rate )
                       END ) TRX_RATE_TYPE
		, k.currency_code
		, k.sob_currency_code
		, k.trx_func_rate
		, 1 batch_id
		, k.ged+1 AS GRACE_END_DATE
		, k.salesrep_id
	        , k.resource_id
		, k.resource_group_id
		, k.gsd_flag
		, k.authoring_org_id
		, k.application_id
		, k.contract_number
		, k.contract_number_modifier
		, k.buy_or_sell
		, k.scs_code
		, k.trn_code
		, k.date_signed
		, k.start_date
		, k.end_date
		, k.date_terminated
		, k.renewal_type_code
		, k.sts_code
		, k.date_approved
		, k.datetime_cancelled
		, k.creation_Date
		, k.last_update_date
		, k.Bill_to_site_use_id
		, k.Ship_to_site_use_id
		, k.est_rev_percent
		, k.est_rev_date
		, k.Acct_rule_id
		, k.master_organization_id
		, k.customer_party_id
		, k.order_number
		, k.subsequent_renewal_type_code    /* for ER#5760744 */
		, k.negotiation_status              /* for ER#5950128 */
		, k.reminder                        /* for ER#5950128 */
		, k.hdr_term_cancel_source      /* Added as part of ER6684955 */
        FROM  (
             SELECT /*+ ordered no_merge use_hash(fsp,sob,sh,tcu,srep,res)
                          parallel(fsp) parallel(sob) parallel(h) parallel(sh)
                          parallel(srep) parallel(res) swap_join_inputs(fsp)
	                  swap_join_inputs(sob)
                          pq_distribute(fsp,none,broadcast)
                          pq_distribute(sob,none, broadcast) */
                        h.id
                      , h.currency_code
                      , sob.currency_code AS SOB_CURRENCY_CODE
                      , h.date_approved
                      , h.creation_date
		                  , h.conversion_rate_date AS CONVERSION_DATE
		                  , h.conversion_type
                      , decode(upper(h.conversion_type), 'USER',
                               decode(h.currency_code, sob.currency_code, 1, h.conversion_rate),
                               NULL) AS TRX_FUNC_RATE
 		                  --  , sh.est_rev_percent win_percent
		                  --  , sh.est_rev_date expected_close_date
                      -- This CASE expression must handle all TCE_CODE values.
                      -- For HOUR and MINUTE values,
                      -- the (((24 * 60) - 1) / (24 * 60))
                      -- expr makes end_date 1 minute before midnight so that
                      -- adding the grace period always adds at least 1 day
		                  -- since 11.5.10 grace_duration from OKS tables
                      , TRUNC(CASE
                                WHEN tcu.tce_code IN ('YEAR')
                                  THEN ADD_MONTHS (h.end_date
                                         , (12 * sh.grace_duration * tcu.quantity))
                                WHEN tcu.tce_code IN ('MONTH')
                                  THEN ADD_MONTHS (h.end_date
                                         , (sh.grace_duration * tcu.quantity))
                                WHEN tcu.tce_code IN ('DAY')
                                  THEN h.end_date
                                         + (sh.grace_duration * tcu.quantity)
                                WHEN tcu.tce_code IN ('HOUR')
                                  THEN h.end_date
                                         + (((24 * 60) - 1) / (24 * 60))
                                         + ((sh.grace_duration * tcu.quantity) / 24)
                                WHEN tcu.tce_code IN ('MINUTE')
                                  THEN h.end_date
                                         + (((24 * 60) - 1) / (24 * 60))
                                         + ((sh.grace_duration * tcu.quantity) / (24 * 60))                              END) ged
                      , DECODE(srep.salesrep_id, NULL, -1, srep.salesrep_id) AS salesrep_id
                      , res.resource_id
                      , nvl(srep.SALES_GROUP_ID, -1) resource_group_id
                      , h.gsd_flag
		  	, h.authoring_org_id
			, h.application_id
			, h.contract_number
			, h.contract_number_modifier
			, h.buy_or_sell
			, h.scs_code
			, h.trn_code
			, h.date_signed
			, h.start_date
			, h.end_date
			, h.date_terminated
			, h.renewal_type_code
			, h.sts_code
			, h.datetime_cancelled
			, h.last_update_date
			, h.Bill_to_site_use_id
			, h.Ship_to_site_use_id
			, sh.est_rev_percent
			, sh.est_rev_date
			, sh.Acct_rule_id
			, mprm.master_organization_id
			, TO_NUMBER(c.object1_id1) customer_party_id
			, oh.order_number order_number
			, h.subsequent_renewal_type_code	      /* for ER#5760744 */
			, sh.renewal_status negotiation_status  /* for ER#5950128 */
			, sh.rmndr_suppress_flag  reminder      /* for ER#5950128 */
			, h.hdr_term_cancel_source              /* for ER6684955 */
               FROM    (SELECT /*+ no_merge parallel(h) */
                               h.id
				, h.currency_code
				, h.date_approved
				, h.creation_date
				, h.conversion_rate_date
				, h.conversion_type
				, h.conversion_rate
				, h.end_date
				, h.authoring_org_id
				, 1 gsd_flag
				, h.application_id
				, h.contract_number
				, h.contract_number_modifier
				, h.buy_or_sell
				, h.scs_code
				, h.trn_code
				, h.date_signed
				, h.start_date
				, h.date_terminated
				, h.renewal_type_code
				, h.sts_code
				, h.datetime_cancelled
				, h.last_update_date
				, h.Bill_to_site_use_id
				, h.Ship_to_site_use_id
				, h.inv_organization_id
				, h.subsequent_renewal_type_code		/* for ER#5760744 */
				, h.hdr_term_cancel_source  /* for ER6684955 */
		                    FROM oki_dbi_chr_stage_inc h
                       UNION
                       SELECT /*+ leading(inc) use_hash(h,ren_rel,a)
                                    parallel(inc) parallel(h) parallel(ren_rel) parallel(a) */
                                h.id
				, h.currency_code
				, h.date_approved
				, h.creation_date
				, h.conversion_rate_date
				, h.conversion_type
				, h.conversion_rate
				, h.end_date
				, h.authoring_org_id
				, case when (COALESCE(h.date_terminated,h.end_date,g_4712_date) <= g_global_start_date) then -1
					else 1 end gsd_flag
				, h.application_id
				, h.contract_number
				, h.contract_number_modifier
				, h.buy_or_sell
				, h.scs_code
				, h.trn_code
				, h.date_signed
				, h.start_date
				, h.date_terminated
				, h.renewal_type_code
				, h.sts_code
				, h.datetime_cancelled
				, h.last_update_date
				, h.Bill_to_site_use_id
				, h.Ship_to_site_use_id
				, h.inv_organization_id
				, decode(h.renewal_type_code, 'ERN', Decode(h.approval_type, 'M', 'ERN'),
													   'EVN', decode(h.approval_type, 'Y', 'EVN', 'N', 'EVN'),
													   'DNR', 'DNR',
													   'NSR', decode(h.approval_type, 'Y', 'NSR', 'N', 'NSR', 'NSR')
						) subsequent_renewal_type_code /* Added this colunm as a part of ER#5760744 */
	,h.term_cancel_source hdr_term_cancel_source  /* for ER6684955 */
     FROM    oki_dbi_chr_stage_inc inc
				, okc_k_headers_all_b h
				, okc_operation_lines ren_rel
				, oki_dbi_chr_stage_inc inc2
				, okc_operation_instances opins
                         WHERE 1=1
                         AND ren_rel.object_chr_id  = h.ID
                         AND ren_rel.subject_chr_id = inc.id
                         AND ren_rel.subject_cle_id IS NULL
                         AND ren_rel.object_cle_id IS NULL
						 /* restricts relationships to renewals and renewal consolidations*/
						 AND ren_rel.oie_id=opins.id
						 AND opins.cop_id in (g_renewal_id,g_ren_con_id)
						 /* end of restricting relationship to renewals and renewal consolidations*/
                         AND inc2.ID(+) = H.ID
                         -- only get the ones that did not find a match
                         AND inc2.ID IS NULL
                         AND h.datetime_cancelled is null
                         AND h.template_yn       = 'N'
                         AND h.application_id    = 515
                         AND h.buy_or_sell       ='S'
                         AND h.scs_code IN ('SERVICE','WARRANTY')
                        ) h
                      , financials_system_params_all fsp
                      , gl_sets_of_books sob
                      , OKS_K_HEADERS_B sh
      		      			, mtl_parameters mprm
                      , okc_k_party_roles_b c
		      						, okc_k_rel_objs ro
		      						, oe_order_headers_all oh
                      -- inline view to select one conversion only per UOM code
                      -- Chooses the conversion rule with the lowest quantity
											, (SELECT /*+ no_merge parallel(tcui) */
                                  tcui.uom_code
                                , max(tcui.tce_code)
                                    keep (dense_rank first order by tcui.quantity) as tce_code
                                , max(tcui.quantity)
                                    keep (dense_rank first order by tcui.quantity) as quantity
														FROM   okc_time_code_units_b tcui
														WHERE  tcui.active_flag = 'Y'
														GROUP BY tcui.uom_code
                        ) tcu
                      			-- salesrep
											, (SELECT /*+ no_merge parallel(srep) parallel(h) */
					    							srep.dnz_chr_id
					  							, h.authoring_org_id
					  							-- if multiple sales rep are in contract get the sales rep
					  							-- with the closest date to current date.
					  							-- for this sales rep identified get  the sales group id.
					  							, max(srep.object1_id1) keep (dense_rank first
					      					ORDER BY CASE WHEN (l_sysdate
							       					BETWEEN NVL(srep.start_date,l_sysdate)
								   						AND NVL(srep.end_date,l_sysdate))
							      					THEN  1
							    						WHEN (NVL(srep.start_date, l_sysdate) >
									 							l_sysdate)
							      					THEN 2
							    						ELSE 3
						       						END ASC
					  							, CASE WHEN (l_sysdate BETWEEN NVL(srep.start_date,l_sysdate)
								 AND NVL(srep.end_date,l_sysdate))
						   THEN g_9999_date -
						      NVL(srep.start_date, l_sysdate)
						 ELSE (CASE WHEN (NVL(srep.start_date,l_sysdate) > l_sysdate)
							      THEN g_9999_date -
							      NVL(srep.start_date,l_sysdate)
							    ELSE NVL(srep.end_date,l_sysdate) -
							    g_0001_date
					      END)
					    END ASC , srep.last_update_date DESC, srep.id ASC) salesrep_id
					  , max(srep.sales_group_id) keep (dense_rank first
					      ORDER BY CASE WHEN (sysdate
							       BETWEEN NVL(srep.start_date,sysdate)
								   AND NVL(srep.end_date,sysdate))
							      THEN  1
							    WHEN (NVL(srep.start_date, sysdate) >
									 sysdate)
							      THEN 2
							    ELSE 3
						       END ASC
					  , CASE WHEN (sysdate BETWEEN NVL(srep.start_date,sysdate)
								 AND NVL(srep.end_date,sysdate))
						   THEN g_9999_date -
						      NVL(srep.start_date, sysdate)
						 ELSE (CASE WHEN (NVL(srep.start_date,sysdate) > sysdate)
							      THEN  g_9999_date -
							      NVL(srep.start_date,sysdate)
							    ELSE NVL(srep.end_date,sysdate) -
							   g_0001_date
					      END)
					    END ASC , srep.last_update_date DESC, srep.id ASC) sales_group_id
					 FROM  okc_contacts srep
					     , okc_k_headers_all_b h
					 WHERE 1 = 1
					 AND h.id    = srep.dnz_chr_id
					 AND srep.cro_code = l_salesperson_code
					 AND NVL (srep.primary_yn, 'Y') = 'Y'
					 AND h.template_yn       = 'N'
					 AND h.application_id    = 515
					 AND h.buy_or_sell       ='S'
					 AND h.scs_code IN ('SERVICE','WARRANTY')
					 GROUP BY srep.dnz_chr_id, h.authoring_org_id
			)srep
                      , jtf_rs_salesreps res
                 WHERE 1=1
                 AND fsp.org_id          = h.authoring_org_id
                 AND sob.set_of_books_id = fsp.set_of_books_id
                 AND h.id  = sh.chr_id
		 AND h.inv_organization_id = mprm.organization_id
		 AND c.dnz_chr_id      = h.id
		 AND c.cle_id   IS NULL
		 AND c.rle_code IN ('CUSTOMER','LICENSEE','BUYER')
		 AND NVL(c.primary_yn,'Y') = 'Y'
		 AND h.id = ro.chr_id (+)
		 AND ro.jtot_object1_code(+) = 'OKX_ORDERHEAD'
		 AND ro.object1_id1 = oh.header_id(+)
                 AND tcu.uom_code(+)     = sh.grace_period
                 AND h.id                = srep.dnz_chr_id(+)
                 AND srep.salesrep_id    = res.salesrep_id(+)
                 AND srep.authoring_org_id  = res.org_id(+)
			) k ;

      l_count := SQL%ROWCOUNT ;

      rlog( 'Number of contracts inserted into OKI_DBI_CHR_INC : '||to_char(l_count),2) ;
      COMMIT;

      GATHER_TABLE_STATS( TABNAME => 'OKI_DBI_CHR_INC') ;

      rlog('Load of Incremental Table OKI_DBI_CHR_INC completed -    ' ||
                                        fnd_date.date_to_displayDT(SYSDATE),1) ;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      RAISE;
    WHEN OTHERS THEN
      rlog( 'Error : While loading Incremental Table OKI_DBI_CHR_INC ',0);
      bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
      fnd_message.set_name(  application => 'FND'
                           , name        => 'CRM-DEBUG ERROR' ) ;
      fnd_message.set_token(
                  token => 'ROUTINE'
                , value => 'OKI_DBI_LOAD_CLEB_PVT.POPULATE_INC_TABLE_INIT ' ) ;
      bis_collection_utilities.put_line(fnd_message.get) ;
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
  END populate_inc_table_init ;

/* *****************************************************************************
   Procedure:populate_inc_table_inc
   Descritpion:Procedure to populate incremental table for incremental load.
   Check okc_k_vers_numbers table for new/modified contracts
   ************************************************************************** */

  PROCEDURE populate_inc_table_inc IS
    l_start_date  DATE ;
    l_end_date    DATE ;
    l_batch_size  NUMBER ;
    l_sql_string  VARCHAR2(10000) ;

    l_oki_schema  VARCHAR2(30) ;
    l_status      VARCHAR2(30) ;
    l_industry    VARCHAR2(30) ;
    l_count       NUMBER ;
    l_global_curr VARCHAR(30);
     --Added by Arun for secondary global currency conversion
    l_sglobal_curr VARCHAR(30);
    l_salesperson_code VARCHAR2(80) ;
    l_sysdate     DATE ;
    l_rate_type   VARCHAR2(1000);

  BEGIN



SELECT MAX(renewal_id),MAX(ren_con_id)
	INTO g_renewal_id,g_ren_con_id
	from
	(
	SELECT decode(opn_code,'RENEWAL',id,null) Renewal_ID, decode(opn_code,'REN_CON',id,null) Ren_CON_ID
	from okc_class_operations clsop
	WHERE clsop.cls_code='SERVICE'
	AND clsop.opn_code in ('RENEWAL','REN_CON')
	);


    l_start_date  := OKI_DBI_LOAD_CLEB_PVT.g_start_date ;
    l_end_date    := OKI_DBI_LOAD_CLEB_PVT.g_end_date ;
    l_global_curr := bis_common_parameters.get_currency_code ;
    l_sysdate     := OKI_DBI_LOAD_CLEB_PVT.g_run_date ;

	-- Added by Arun for secondary global currency conversion changes
    IF(POA_CURRENCY_PKG.display_secondary_currency_yn)
    THEN
         -- Check if Sec Currency display flag is set
       IF BIS_COMMON_PARAMETERS.Get_Secondary_Currency_Code IS NOT NULL
         THEN l_sglobal_curr := BIS_COMMON_PARAMETERS.Get_Secondary_Currency_Code;
       END IF;
    END IF;

    l_salesperson_code := fnd_profile.value('OKS_ENABLE_SALES_CREDIT');
    IF l_salesperson_code IN ('YES', 'DRT') THEN	/* Added 'DRT' filter condition, Please refer Bug#5978601 */
      l_salesperson_code := fnd_profile.value('OKS_VENDOR_CONTACT_ROLE');
    ELSE
      l_salesperson_code := 'SALESPERSON';
    END IF ;

    SELECT NVL(BIS_COMMON_PARAMETERS.get_batch_size(BIS_COMMON_PARAMETERS.HIGH)
               , 1000)
    INTO   l_batch_size
    FROM DUAL ;

    g_batch_size   := l_batch_size;
    IF (FND_INSTALLATION.GET_APP_INFO(
              application_short_name => 'OKI'
            , status                 => l_status
            , industry               => l_industry
            , oracle_schema          => l_oki_schema           )) THEN

      l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema || '.OKI_DBI_CHR_STAGE_INC';
      EXECUTE IMMEDIATE l_sql_string;
      rlog( 'Truncated Table ' || l_oki_schema || '.OKI_DBI_CHR_STAGE_INC',1);

      l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema || '.OKI_DBI_CHR_INC';
      EXECUTE IMMEDIATE l_sql_string;
      rlog( 'Truncated Table ' || l_oki_schema || '.OKI_DBI_CHR_INC',1);

      /* Commented as per mail communications - for Disco */
	  /*
	  l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema || '.OKI_DBI_WORKER_STATUS';
      EXECUTE IMMEDIATE l_sql_string;
      rlog( 'Truncated Table ' || l_oki_schema || '.OKI_DBI_WORKER_STATUS',1);
	  */

	  DELETE FROM OKI_DBI_WORKER_STATUS WHERE OBJECT_NAME = 'OKI_DBI_CLE_B_OLD';
      COMMIT;

      l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema || '.OKI_DBI_CLE_B_OLD';
      EXECUTE IMMEDIATE l_sql_string;
      rlog( 'Truncated Table ' || l_oki_schema || '.OKI_DBI_CLE_B_OLD',1);

      l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema || '.OKI_DBI_CURR_CONV';
      EXECUTE IMMEDIATE l_sql_string;
      rlog( 'Truncated Table ' || l_oki_schema || '.OKI_DBI_CURR_CONV',1);
      l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema || '.OKI_DBI_REN_INC' ;
      EXECUTE IMMEDIATE l_sql_string ;
      rlog('Truncated Table OKI_DBI_REN_INC ',1);
      l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema || '.OKI_DBI_PREV_INC' ;
      EXECUTE IMMEDIATE l_sql_string ;
      rlog('Truncated Table OKI_DBI_PREV_INC ',1);

      l_rate_type   := bis_common_parameters.get_treasury_rate_type;

	  rlog ('Treasury Rate Type is '||NVL(l_rate_type,'Not Defined'),1);

    IF l_rate_type is NULL THEN
      l_rate_type   := bis_common_parameters.get_rate_type ;
    END IF;

    rlog ('Primary Rate Type is '||NVL(bis_common_parameters.get_rate_type,'Not Defined'),1);

    rlog( 'Populating Incremental Staging Table OKI_DBI_CHR_STAGE_INC -  ' || fnd_date.date_to_displayDT(sysdate),1);



   /* Added hint as per perf. teams recommendations*/
    INSERT  INTO OKI_DBI_CHR_STAGE_INC
      ( id,
        currency_code,
        date_approved,
        creation_date,
        conversion_rate_date,
        conversion_type,
        conversion_rate,
        end_date,
        authoring_org_id,
				application_id,
				contract_number,
				contract_number_modifier,
				buy_or_sell,
				scs_code,
				trn_code,
				date_signed,
				start_date,
				date_terminated,
				renewal_type_code,
				sts_code,
				datetime_cancelled,
				last_update_date,
				Bill_to_site_use_id,
				Ship_to_site_use_id,
				inv_organization_id,
				subsequent_renewal_type_code,
				hdr_term_cancel_source
      )
      SELECT /*+ cardinality(v,1) index(V OKC_K_VERS_NUMBERS_N1) */ h.id
		, h.currency_code
		, h.date_approved
		, h.creation_date
		, h.conversion_rate_date
		, h.conversion_type
		, h.conversion_rate
		, h.end_date
		, h.authoring_org_id
		, h.application_id
		, h.contract_number
		, h.contract_number_modifier
		, h.buy_or_sell
		, h.scs_code
		, h.trn_code
		, h.date_signed
		, h.start_date
		, h.date_terminated
		, h.renewal_type_code
		, h.sts_code
		, h.datetime_cancelled
		, h.last_update_date
		, h.Bill_to_site_use_id
		, h.Ship_to_site_use_id
		, h.inv_organization_id
		, decode(h.renewal_type_code, 'ERN', Decode(h.approval_type, 'M', 'ERN'),
								   'EVN', decode(h.approval_type, 'Y', 'EVN', 'N', 'EVN'),
								   'DNR', 'DNR',
								   'NSR', decode(h.approval_type, 'Y', 'NSR', 'N', 'NSR', 'NSR')
					) subsequent_renewal_type_code /* for ER#5760744 */
		, h.term_cancel_source  hdr_term_cancel_source  /* for ER 6684955 */
      FROM   okc_k_headers_all_b h
           , okc_k_vers_numbers v
      WHERE 1=1
	AND v.last_update_date   >= l_start_date
	AND v.last_update_date+0 <= l_end_date
	AND h.id                = v.chr_id
	AND COALESCE(h.date_terminated,h.datetime_cancelled,h.end_date,g_4712_date) > g_global_start_date
	AND h.template_yn       = 'N'
	AND h.application_id    = 515
	AND h.buy_or_sell       ='S'
	AND h.scs_code IN ('SERVICE','WARRANTY') ;

     l_count := SQL%ROWCOUNT ;

     rlog( 'Number of contracts inserted into OKI_DBI_CHR_STAGE_INC : '||to_char(l_count), 2) ;
     COMMIT;

      GATHER_TABLE_STATS(TABNAME => 'OKI_DBI_CHR_STAGE_INC');

     rlog('Load of Incremental Staging Table OKI_DBI_CHR_STAGE_INC completed -    ' ||
                                        fnd_date.date_to_displayDT(SYSDATE),1) ;

     rlog( 'Populating Incremental Table OKI_DBI_CHR_INC -  ' || fnd_date.date_to_displayDT(sysdate),1);

      INSERT INTO  oki_dbi_chr_inc
      (
          chr_id
        , conversion_date
        , trx_rate_type
        , trx_currency
        , func_currency
        , trx_func_rate
        , batch_id
        , grace_end_date
        , salesrep_id
        , resource_id
	      , resource_group_id
        , worker_number
        , gsd_flag
	      , authoring_org_id
   	    , application_id
	      , contract_number
	      , contract_number_modifier
	      , buy_or_sell
	      , scs_code
	      , trn_code
	      , date_signed
	      , start_date
	      , end_date
	      , date_terminated
	      , renewal_type_code
	      , sts_code
	      , date_approved
	      , datetime_cancelled
	      , creation_Date
	      , last_update_date
	      , Bill_to_site_use_id
	      , Ship_to_site_use_id
	      , est_rev_percent
	      , est_rev_date
	      , Acct_rule_id
	      , master_organization_id
	      , customer_party_id
	      , order_number
	      , subsequent_renewal_type_code		/* Added this colunm as a part of ER#5760744 */
	      , negotiation_status                    /* Added this colunm as a part of ER#5950128 */
	      , reminder                              /* Added this colunm as a part of ER#5950128 */
	      , hdr_term_cancel_source                /* Added for ER 6684955 */
      )
    select	  chr_id
		, conversion_date
		, trx_rate_type
		, trx_currency
		, func_currency
		, trx_func_rate
		, batch_id
		, grace_end_date
		, salesrep_id
		, CASE WHEN SALESREP_ID <> -1 THEN
			(select resource_id from jtf_rs_salesreps s where s.salesrep_id = new.salesrep_id
			and s.org_id = new.authoring_org_id)
		   END	resource_id
		, resource_group_id
		, -1 worker_number
		, gsd_flag
		, authoring_org_id
   		, application_id
		, contract_number
		, contract_number_modifier
		, buy_or_sell
		, scs_code
		, trn_code
		, date_signed
		, start_date
		, end_date
		, date_terminated
		, renewal_type_code
		, sts_code
		, date_approved
		, datetime_cancelled
		, creation_Date
		, last_update_date
		, Bill_to_site_use_id
		, Ship_to_site_use_id
		, est_rev_percent
		, est_rev_date
		, Acct_rule_id
		, master_organization_id
		, customer_party_id
		, order_number
		, subsequent_renewal_type_code		/* for ER#5760744 */
		, negotiation_status        /* for ER#5950128 */
		, reminder          /* for ER#5950128 */
		, hdr_term_cancel_source   /* for ER 6684955 */
from (
			SELECT  chr_id
					, conversion_date
	        , trx_rate_type
					, trx_currency
	        , func_currency
	        , trx_func_rate
	        , batch_id
	        , grace_end_date
	        , NVL((SELECT to_number(substr(salesrep_attribs,1,instr(salesrep_attribs,'#')-1)) from dual),-1) salesrep_id
	        , NVL((SELECT to_number(substr(salesrep_attribs,instr(salesrep_attribs,'#')+1)) from dual),-1) resource_group_id
					, gsd_flag
					, authoring_org_id
   				, application_id
					, contract_number
					, contract_number_modifier
					, buy_or_sell
					, scs_code
					, trn_code
					, date_signed
					, start_date
					, end_date
					, date_terminated
					, renewal_type_code
					, sts_code
					, date_approved
					, datetime_cancelled
					, creation_Date
					, last_update_date
					, Bill_to_site_use_id
					, Ship_to_site_use_id
					, est_rev_percent
					, est_rev_date
					, Acct_rule_id
					, master_organization_id
					, customer_party_id
					, order_number
					, subsequent_renewal_type_code		/* for ER#5760744 */
					, negotiation_status        /* for ER#5950128 */
					, reminder        /* Added this colunm as a part of ER#5950128 */
					, hdr_term_cancel_source     /* Added for ER 6684955 */
				FROM (SELECT  /*+ use_hash(fsp,mprm) swap_join_inputs(fsp) use_nl(sob,sh,c,ro)*/
               h.id chr_id
               , trunc(COALESCE(h.conversion_rate_date, h.date_approved, h.creation_date)) AS CONVERSION_DATE
               , (CASE WHEN h.currency_code = sob.currency_code
                       THEN l_rate_type
                       ELSE oki_dbi_currency_pvt.get_trx_rate_type(
                                 h.id
                               , h.currency_code
                               , sob.currency_code
                               , h.creation_date
			       		, h.conversion_rate_date
			       		, h.conversion_type
			       		, h.conversion_rate)
                  END ) AS TRX_RATE_TYPE
               , h.currency_code trx_currency
               , sob.currency_code func_currency
               , decode(upper(h.conversion_type), 'USER',
                        decode(h.currency_code, sob.currency_code, 1, h.conversion_rate),
                        NULL) AS TRX_FUNC_RATE
               , 1 BATCH_ID
               -- This CASE expression must handle all TCE_CODE values.
               -- For HOUR and MINUTE values,
               -- the (((24 * 60) - 1) / (24 * 60))
               -- expr makes end_date 1 minute before midnight so that
               -- adding the grace period always adds at least 1 day
               , (SELECT TRUNC(CASE
                         WHEN tcu.tce_code IN ('YEAR')
                           THEN ADD_MONTHS (h.end_date
                                  , (12 * sh.grace_duration * tcu.quantity))
                         WHEN tcu.tce_code IN ('MONTH')
                           THEN ADD_MONTHS (h.end_date
                                  , (sh.grace_duration * tcu.quantity))
                         WHEN tcu.tce_code IN ('DAY')
                           THEN h.end_date
                                  + (sh.grace_duration * tcu.quantity)
                         WHEN tcu.tce_code IN ('HOUR')
                           THEN h.end_date
                                  + (((24 * 60) - 1) / (24 * 60))
                                  + ((sh.grace_duration * tcu.quantity) / 24)
                         WHEN tcu.tce_code IN ('MINUTE')
                           THEN h.end_date
                                  + (((24 * 60) - 1) / (24 * 60))
                                  + ((sh.grace_duration * tcu.quantity) / (24 * 60))
                       END)+1 FROM DUAL) AS GRACE_END_DATE
               ,( SELECT  nvl(max(srep.object1_id1) keep (dense_rank first
                      ORDER BY CASE WHEN (l_sysdate
                                       BETWEEN NVL(srep.start_date,l_sysdate)
                                           AND NVL(srep.end_date,l_sysdate))
                                      THEN  1
                                    WHEN (NVL(srep.start_date, l_sysdate) >
                                                 l_sysdate)
                                      THEN 2
                                    ELSE 3
                               END ASC
                  , CASE WHEN (l_sysdate BETWEEN NVL(srep.start_date,l_sysdate)
                                             AND NVL(srep.end_date,l_sysdate))
                           THEN g_9999_date -
                                      NVL(srep.start_date, l_sysdate)
                         ELSE (CASE WHEN (NVL(srep.start_date,l_sysdate) > l_sysdate)
                                      THEN g_9999_date -
                                              NVL(srep.start_date,l_sysdate)
                                    ELSE NVL(srep.end_date,l_sysdate) -
                                            g_0001_date
                               END)
                    END ASC , srep.last_update_date DESC, srep.id ASC),-1) || '#' ||
                   nvl(max(srep.sales_group_id) keep (dense_rank first
                      ORDER BY CASE WHEN (l_sysdate
                                       BETWEEN NVL(srep.start_date,l_sysdate)
                                           AND NVL(srep.end_date,l_sysdate))
                                      THEN  1
                                    WHEN (NVL(srep.start_date, l_sysdate) >
                                                 l_sysdate)
                                      THEN 2
                                    ELSE 3
                               END ASC
                  , CASE WHEN (l_sysdate BETWEEN NVL(srep.start_date,l_sysdate)
                                             AND NVL(srep.end_date,l_sysdate))
                           THEN g_9999_date -
                                      NVL(srep.start_date, l_sysdate)
                         ELSE (CASE WHEN (NVL(srep.start_date,l_sysdate) > l_sysdate)
                                      THEN g_9999_date -
                                              NVL(srep.start_date,l_sysdate)
                                    ELSE NVL(srep.end_date,l_sysdate) -
                                            g_0001_date
                               END)
                    END ASC , srep.last_update_date DESC , srep.id ASC),-1)
                FROM  okc_contacts srep
                WHERE 1 = 1
                AND srep.cro_code = l_salesperson_code
                AND NVL (srep.primary_yn, 'Y') = 'Y'
                AND h.id = srep.dnz_chr_id
                GROUP BY srep.dnz_chr_id) Salesrep_attribs
		, h.gsd_flag
  		, h.authoring_org_id
		, h.application_id
		, h.contract_number
		, h.contract_number_modifier
		, h.buy_or_sell
		, h.scs_code
		, h.trn_code
		, h.date_signed
		, h.start_date
		, h.end_date
		, h.date_terminated
		, h.renewal_type_code
		, h.sts_code
		, h.date_approved
		, h.datetime_cancelled
		, h.creation_Date
		, h.last_update_date
		, h.Bill_to_site_use_id
		, h.Ship_to_site_use_id
  		, sh.est_rev_percent
  		, sh.est_rev_date
  		, sh.Acct_rule_id
		, mprm.master_organization_id
		, TO_NUMBER(c.object1_id1) customer_party_id
		, CASE WHEN ro.object1_id1 is not null then
		   	 (SELECT order_number from oe_order_headers_all where header_id = ro.object1_id1)
		  END order_number
		, h.subsequent_renewal_type_code	/* Added this colunm as a part of ER#5760744 */
		, sh.renewal_status negotiation_status  /* Added this colunm as a part of ER#5950128 */
		, sh.rmndr_suppress_flag reminder       /* Added this colunm as a part of ER#5950128 */
		, h.hdr_term_cancel_source                /* Added for ER 6684955 */
              FROM   (
               	SELECT id
			, currency_code
			, date_approved
			, creation_date
			, conversion_rate_date
			, conversion_type
			, conversion_rate
			, end_date
			, authoring_org_id
			, gsd_flag
			, application_id
			, contract_number
			, contract_number_modifier
			, buy_or_sell
			, scs_code
			, trn_code
			, date_signed
			, start_date
			, date_terminated
			, renewal_type_code
			, sts_code
			, datetime_cancelled
			, last_update_date
			, Bill_to_site_use_id
			, Ship_to_site_use_id
			, inv_organization_id
			, subsequent_renewal_type_code		/* Added this colunm as a part of ER#5760744 */
			, hdr_term_cancel_source          /* Added for ER 6684955 */
                  FROM (
                        SELECT id
				, currency_code
				, date_approved
				, creation_date
				, conversion_rate_date
				, conversion_type
				, conversion_rate
				, end_date
				, authoring_org_id
				, gsd_flag
				, application_id
				, contract_number
				, contract_number_modifier
				, buy_or_sell
				, scs_code
				, trn_code
				, date_signed
				, start_date
				, date_terminated
				, renewal_type_code
				, sts_code
				, datetime_cancelled
				, last_update_date
				, Bill_to_site_use_id
				, Ship_to_site_use_id
				, inv_organization_id
				, subsequent_renewal_type_code		/* Added this colunm as a part of ER#5760744 */
				, hdr_term_cancel_source          /* Added for ER 6684955 */
                               ,ROW_NUMBER() OVER (PARTITION BY id ORDER BY gsd_flag DESC) r
                          FROM (
                                  SELECT /*+ cardinality(inc,10) */
					 														inc.id
																		, inc.currency_code
																		, inc.date_approved
																		, inc.creation_date
																		, inc.conversion_rate_date
																		, inc.conversion_type
																		, inc.conversion_rate
																		, inc.end_date
																		, inc.authoring_org_id
                                   	, inc.application_id
                                   	, inc.contract_number
                                   	, inc.contract_number_modifier
                                   	, inc.buy_or_sell
                                   	, inc.scs_code
                                   	, inc.trn_code
                                   	, inc.date_signed
                                   	, inc.start_date
                                   	, inc.date_terminated
                                   	, inc.renewal_type_code
                                   	, inc.sts_code
                                   	, inc.datetime_cancelled
                                   	, inc.last_update_date
                                   	, inc.Bill_to_site_use_id
                                   	, inc.Ship_to_site_use_id
                                   	, inc.inv_organization_id
																		, 1 gsd_flag
																		, subsequent_renewal_type_code		/* Added this colunm as a part of ER#5760744 */
																		, inc.hdr_term_cancel_source      /* Added for ER 6684955 */
                                  FROM oki_dbi_chr_stage_inc inc
                                  UNION ALL
                                  SELECT /*+ ordered cardinality(inc,10) */
					  													h.id
																		, h.currency_code
																		, h.date_approved
																		, h.creation_date
																		, h.conversion_rate_date
																		, h.conversion_type
																		, h.conversion_rate
																		, h.end_date
																		, h.authoring_org_id
																		, h.application_id
                                   	, h.contract_number
                                   	, h.contract_number_modifier
                                   	, h.buy_or_sell
                                   	, h.scs_code
                                   	, h.trn_code
                                   	, h.date_signed
                                   	, h.start_date
                                   	, h.date_terminated
                                   	, h.renewal_type_code
                                   	, h.sts_code
                                   	, h.datetime_cancelled
                                   	, h.last_update_date
                                   	, h.Bill_to_site_use_id
                                   	, h.Ship_to_site_use_id
                                   	, h.inv_organization_id
																		, CASE WHEN (COALESCE(h.date_terminated,h.end_date,g_4712_date)<= g_global_start_date)
																						THEN -1
																						ELSE 1
					  																END gsd_flag
																		, decode(h.renewal_type_code, 'ERN', Decode(h.approval_type, 'M', 'ERN'),
											   											'EVN', decode(h.approval_type, 'Y', 'EVN', 'N', 'EVN'),
											  											 'DNR', 'DNR',
											  											 'NSR', decode(h.approval_type, 'Y', 'NSR', 'N', 'NSR', 'NSR')
																						) subsequent_renewal_type_code         /* Added this colunm as a part of ER#5760744 */
																		, h.term_cancel_source hdr_term_cancel_source  /* Added for ER 6684955 */
                                  FROM oki_dbi_chr_stage_inc inc ,
                                       okc_operation_lines ren_rel ,
                                       okc_operation_instances opins,
                                       okc_k_headers_all_b h
                                  WHERE 1=1
                                    AND ren_rel.object_chr_id = h.id
                                    AND ren_rel.subject_chr_id = inc.id
                                    AND ren_rel.subject_cle_id IS NULL
                                    AND ren_rel.object_cle_id IS NULL
																		/* restricts relationships to renewals and renewal consolidations*/
                                    AND ren_rel.oie_id=opins.id
                                    AND opins.cop_id in (g_renewal_id,g_ren_con_id)
																			/* end of restricting relationship to renewals and renewal consolidations*/
																			/*AND COALESCE(h.date_terminated,h.end_date,g_4712_date)<= g_global_start_date*/
                                    AND h.datetime_cancelled IS NULL
                                    AND h.template_yn = 'N'
                                    AND h.application_id = 515
                                    AND h.buy_or_sell ='S'
                                    AND h.scs_code IN ('SERVICE','WARRANTY')
				)
			)
		WHERE r = 1 ) h
		, oks_k_headers_b sh
		, mtl_parameters mprm
		, okc_k_party_roles_b c
		, okc_k_rel_objs ro
		, financials_system_params_all fsp
		, gl_sets_of_books sob
             -- inline view to select one conversion only per UOM code
             -- Chooses the conversion rule with the lowest quantity
		, (SELECT   tcui.uom_code
                       , max(tcui.tce_code)
                           keep (dense_rank first order by tcui.quantity) as tce_code
                       , max(tcui.quantity)
                           keep (dense_rank first order by tcui.quantity) as quantity
			FROM   okc_time_code_units_b tcui
			WHERE  tcui.active_flag = 'Y'
			GROUP BY tcui.uom_code
		  ) tcu
       WHERE 1=1
		AND fsp.org_id          = h.authoring_org_id
		AND h.inv_organization_id = mprm.organization_id
		AND c.dnz_chr_id      = h.id
  		AND c.cle_id   IS NULL
  		AND c.rle_code IN ('CUSTOMER','LICENSEE','BUYER')
        /* Removed this conditions after confirming from Ramesh Shankar*/
--		AND NVL(c.primary_yn,'Y') = 'Y'
		AND h.id = ro.chr_id (+)
		AND ro.jtot_object1_code(+) = 'OKX_ORDERHEAD'
		AND sob.set_of_books_id = fsp.set_of_books_id
		AND h.ID                = sh.chr_id
		AND tcu.uom_code(+)     = sh.grace_period
	) ilv1
      ) new ;

      g_contracts_count := SQL%ROWCOUNT ;

      rlog( 'Number of contracts identified for merge:  ' ||          to_char(g_contracts_count), 2) ;
    COMMIT ;
      rlog( 'Load of Incremental Table OKI_DBI_CHR_INC completed - ' || fnd_date.date_to_displayDT(sysdate),1);

      GATHER_TABLE_STATS(TABNAME => 'OKI_DBI_CHR_INC') ;
    END IF ;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      RAISE;
    WHEN OTHERS THEN
      rlog( 'Error : while loading Incremental Table OKI_DBI_CHR_INC ',0);
      bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
      fnd_message.set_name(  application => 'FND'
                           , name        => 'CRM-DEBUG ERROR' ) ;
      fnd_message.set_token(
                   token => 'ROUTINE'
                 , value => 'OKI_DBI_LOAD_CLEB_PVT.POPULATE_INC_TABLE_INC ' ) ;
      bis_collection_utilities.put_line(fnd_message.get) ;
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
  END populate_inc_table_inc ;

/* *****************************************************************************
   Procedure:load_currencies
   Description:loads the currencies Staging table
   ************************************************************************** */

PROCEDURE load_currencies  IS
  l_count       NUMBER ;
  l_sql_string  VARCHAR2(10000) ;

  BEGIN

    INSERT /*+ append */ INTO  oki_dbi_curr_conv
      (chr_id,
      from_currency,
      to_currency,
      curr_conv_date,
      rate_type,
      rate_f,
      rate_g,
      rate_sg)
    SELECT
      chr_id,
      inc.trx_currency FROM_CURRENCY,
      inc.func_currency TO_CURRENCY,
      inc.conv_date CURR_CONV_DATE,
      inc.conv_type RATE_TYPE
      , CASE WHEN (UPPER(inc.conv_type) = 'USER' )
          THEN inc.rate
          ELSE
      FII_CURRENCY.Get_Rate(inc.trx_currency
                           ,inc.func_currency
                           ,inc.conv_date,inc.conv_type)
          END rate_f,
      FII_CURRENCY.Get_TC_To_PGC_Rate(inc.trx_currency
                                     ,inc.conv_date
                                     ,inc.conv_type
                                     ,inc.func_currency
                                     ,inc.conv_date,inc.rate) RATE_G,
      FII_CURRENCY.Get_TC_To_SGC_Rate(inc.trx_currency
                                     ,inc.conv_date
                                     ,inc.conv_type
                                     ,inc.func_currency
                                     ,inc.conv_date,inc.rate) RATE_SG
    FROM (SELECT
                 DISTINCT trx_currency
                        , func_currency
                        , conversion_date conv_date
                        , trx_rate_type conv_type
          , DECODE (UPPER(trx_rate_type),'USER', trx_func_rate, NULL) rate
                        , DECODE(upper(trx_rate_type), 'USER', chr.chr_id, NULL) chr_id
          FROM oki_dbi_chr_inc chr
          ORDER BY func_currency
                 , conversion_date ) inc;
-- selecting all the distinct curr conv , "USER" will come as well but FII will return NULL, these rows will be handled when inserting into _old table

     l_count := SQL%ROWCOUNT ;
     rlog( 'Number of lines inserted into OKI_DBI_CURR_CONV :   ' ||  to_char(l_count),2);

    COMMIT;

       GATHER_TABLE_STATS(tabname=>'OKI_DBI_CURR_CONV');




  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       RAISE;
    WHEN OTHERS THEN
      rlog('Error during load_currencies: Insert into OKI_DBI_CURR_CONV Failed' , 0);
      rlog(sqlerrm ||'   '||sqlcode, 0);
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_LOAD_CLEB_PVT.load_currencies' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

  END load_currencies;

/* *****************************************************************************
   Procedure:report_missing_currencies
   Description:Identifies missing Currencies and reports in a tabular format
   ************************************************************************** */

  PROCEDURE report_missing_currencies IS
    l_rate_type       VARCHAR2(1000) ;
    --Added by Arun for secondary global currency changes
    l_srate_type      VARCHAR2(1000) ;
    l_global_currency VARCHAR2(100) ;
    --Added by Arun for secondary global currency changes
    l_sglobal_currency VARCHAR2(100) ;
    l_indenting              VARCHAR2(10) ;
    l_length_contract_number NUMBER ;
    l_length_sts_code        NUMBER ;
    l_length_rate_type 	     NUMBER ;
    l_length_from_currency   NUMBER ;
    l_length_to_currency     NUMBER ;
    l_length_date            NUMBER ;
    l_length_contract_id     NUMBER ;

  BEGIN
    l_rate_type    := bis_common_parameters.get_rate_type ;
    l_srate_type   := bis_common_parameters.get_secondary_rate_type ;
    l_global_currency := bis_common_parameters.get_currency_code;
    l_indenting  := '    ' ;
    l_length_contract_number := 35 ;
    l_length_sts_code        := 30 ;
    l_length_rate_type 	     := 12 ;
    l_length_from_currency   := 17 ;
    l_length_to_currency     := 15 ;
    l_length_date            := 20 ;
    l_length_contract_id     := 50 ;


	IF(POA_CURRENCY_PKG.display_secondary_currency_yn)
    THEN
       l_sglobal_currency := BIS_COMMON_PARAMETERS.Get_Secondary_Currency_Code;
    END IF;

    -- Section 1 Missing functional to global conversion rates
    rout(rpad('*' ,80 ,'*'), 0 ) ;
    rout('                Missing Functional To Global Conversion Rates', 0 ) ;
    rout(rpad('*' ,80 ,'*'), 0 ) ;
    rout(' ', 0 ) ;

    BIS_COLLECTION_UTILITIES.writemissingrateheader ;

    -- Missing currency summary for converting from functional to
    -- global currency
    FOR r_cur IN (SELECT distinct to_currency func_currency,
                  decode(rate_g, -3, g_euro_start_date , curr_conv_date) conversion_date
                  FROM   oki_dbi_curr_conv
                  WHERE  curr_conv_date IS NOT NULL
                --AND    rate_type <> 'USER'  --fix for 4102597
                  AND    rate_g < 0
				  AND	 rate_g NOT IN (-2,-3,-5)
                  ORDER BY conversion_date ASC)
    LOOP
      BIS_COLLECTION_UTILITIES.writemissingrate(
            l_rate_type
          , r_cur.func_currency
          , l_global_currency
          , r_cur.conversion_date ) ;
    END LOOP ;

/********************Added by Arun for secondary global currency conversion changes****/
    -- Section 1a Missing functional to secondary global conversion rates
    IF(l_sglobal_currency IS NOT NULL)
      THEN
        rout(rpad('*' ,80 ,'*'), 0 ) ;
        rout('                Missing Functional To Secondary Global Conversion Rates', 0 ) ;
        rout(rpad('*' ,80 ,'*'), 0 ) ;
        rout(' ', 0 ) ;

        BIS_COLLECTION_UTILITIES.writemissingrateheader ;

    -- Missing currency summary for converting from functional to
    -- secondary global currency
        FOR r_cur IN (SELECT DISTINCT to_currency func_currency
                            ,decode(rate_sg, -3, g_euro_start_date, curr_conv_date) conversion_date
                      FROM   oki_dbi_curr_conv
                      WHERE  curr_conv_date IS NOT NULL
                     --AND    rate_type <> 'USER'  --fix for 4102597
                      AND    rate_sg < 0
					  AND	 rate_sg NOT IN (-2,-3,-5)
                      ORDER BY conversion_date ASC)
        LOOP
          BIS_COLLECTION_UTILITIES.writemissingrate(
            l_srate_type
           ,r_cur.func_currency
           ,l_sglobal_currency
           ,r_cur.conversion_date ) ;
        END LOOP ;
    END IF;

/**************changes for secondary global currency conversion ends here*******/

    -- Section 2 Missing transactional to functional conversion rates
    rout(rpad(' ' ,80 ,' '), 0 ) ;
    rout(rpad('*' ,80 ,'*'), 0 ) ;
    rout('                Missing Transactional To Functional Conversion Rates'
         , 0 ) ;
    rout(rpad('*' ,80 ,'*'), 0 ) ;
    rout(' ', 0 ) ;

    BIS_COLLECTION_UTILITIES.writemissingrateheader ;

    -- Missing currency summary for converting from transactional to
    -- functional currency
    FOR r_cur IN (SELECT DISTINCT rate_type AS TRX_RATE_TYPE
                                , from_currency as TRX_CURRENCY
                                , to_currency as FUNC_CURRENCY
                                , decode(rate_f, -3, g_euro_start_date, curr_conv_date) AS CONVERSION_DATE
                  FROM   oki_dbi_curr_conv
                  WHERE  curr_conv_date IS NOT NULL
                 --AND    rate_type <> 'USER' --fix for 4102597
                  AND    ( rate_f <= 0 OR rate_f IS NULL)
                  ORDER BY conversion_date ASC )
    LOOP
      BIS_COLLECTION_UTILITIES.writemissingrate(
           r_cur.trx_rate_type
         , r_cur.trx_currency
         , r_cur.func_currency
         , r_cur.conversion_date ) ;
    END LOOP ;

    rout(rpad(' ' ,110 ,' '), 0 ) ;
    rout(rpad('*' ,110 ,'*'), 0 ) ;
    rout('                Contracts With Missing Functional to Global Conversion Rates', 0 ) ;
    rout(rpad('*' ,110 ,'*'), 0 ) ;
    rout(' ', 0 ) ;

    bis_collection_utilities.writeMissingContractHeader ;

    FOR r_cur IN (
        SELECT /*+ ordered use_hash(chr) use_nl(h)
                    parallel(inc) parallel(chr) parallel(h)  */
              distinct h.contract_number || ' ' ||
              h.contract_number_modifier AS complete_contract_number
            , h.sts_code          AS sts_code
           , h.id                AS chr_id
            , inc.to_currency   AS func_currency
           , decode(inc.rate_g, -3,  g_euro_start_date, inc.curr_conv_date) conversion_date
        FROM   oki_dbi_curr_conv inc
             , oki_dbi_chr_inc chr
             , okc_k_headers_all_b h
        WHERE  1 = 1
        --AND    inc.rate_type <> 'USER'
        AND    inc.rate_g < 0
		AND	 inc.rate_g NOT IN (-2,-3,-5)
        AND  decode(upper(inc.rate_type),'USER',inc.chr_id,chr.chr_id) = chr.chr_id
        AND    h.id = chr.chr_id
        AND    chr.conversion_date = inc.curr_conv_date
        AND    chr.trx_currency = inc.from_currency
        AND    chr.func_currency = inc.to_currency
        AND    chr.trx_rate_type = inc.rate_type
        ORDER BY conversion_date asc)

    LOOP
      bis_collection_utilities.writeMissingContract(
          r_cur.complete_contract_number
        , r_cur.sts_code
        , r_cur.chr_id
        , l_rate_type
        , r_cur.func_currency
        , l_global_currency
        , r_cur.conversion_date );
    END LOOP;

/**************Added By Arun for secondary global currency conversion*******/
  IF(l_sglobal_currency IS NOT NULL)
    THEN
      rout(rpad(' ' ,110 ,' '), 0 ) ;
      rout(rpad('*' ,110 ,'*'), 0 ) ;
      rout('                Contracts With Missing Functional to Secondary Global Conversion Rates', 0 ) ;
      rout(rpad('*' ,110 ,'*'), 0 ) ;
      rout(' ', 0 ) ;

      bis_collection_utilities.writeMissingContractHeader ;

      FOR r_cur IN (
        SELECT /*+ leading(inc) use_hash(chr) use_nl(h) */
             distinct h.contract_number || ' ' ||
                 h.contract_number_modifier AS complete_contract_number
           , h.sts_code          AS sts_code
           , h.id                AS chr_id
           , inc.to_currency     AS func_currency
           , decode(inc.rate_sg,-3,g_euro_start_date,inc.curr_conv_date) AS CONVERSION_DATE
        FROM   oki_dbi_curr_conv inc
             , oki_dbi_chr_inc chr
             , okc_k_headers_all_b h
        WHERE  inc.rate_sg < 0
		AND	 inc.rate_sg NOT IN (-2,-3,-5)
         --AND    inc.rate_type <> 'USER'
	      AND  decode(upper(inc.rate_type),'USER',inc.chr_id,chr.chr_id) = chr.chr_id
        AND    h.id = chr.chr_id
        AND    chr.conversion_date = inc.curr_conv_date
        AND    chr.trx_currency = inc.from_currency
        AND    chr.func_currency = inc.to_currency
        AND    chr.trx_rate_type = inc.rate_type
        ORDER BY conversion_date ASC )
      LOOP
        bis_collection_utilities.writeMissingContract(
          r_cur.complete_contract_number
         ,r_cur.sts_code
         ,r_cur.chr_id
         ,l_rate_type
         ,r_cur.func_currency
         ,l_sglobal_currency
         ,r_cur.conversion_date);
      END LOOP;
  END IF;
/**************changes for secondary global currency conversion ends here*******/


    rout(rpad(' ' ,110 ,' '), 0 ) ;
    rout(rpad('*' ,110 ,'*') ,0) ;
    rout('                Contracts With Missing Transactional To Functional Conversion Rates',0) ;
    rout(rpad('*' ,110 ,'*') ,0) ;
    rout(' ' ,0) ;

    bis_collection_utilities.writeMissingContractHeader ;

    -- Error occured when converting from transactional to function currency
    -- Write the details to the error log
    FOR r_cur IN (
        SELECT distinct /*+ leading(inc) use_hash(chr) use_nl(h) */
              h.contract_number || ' ' ||
              h.contract_number_modifier AS complete_contract_number
            , h.sts_code          AS sts_code
            , chr.chr_id          AS chr_id
            , inc.rate_type   AS trx_rate_type
            , inc.from_currency    AS trx_currency
            , inc.to_currency   AS func_currency
            , decode(inc.rate_f,-3,g_euro_start_date,inc.curr_conv_date) AS conversion_date
        FROM   oki_dbi_curr_conv inc
             , oki_dbi_chr_inc chr
             , okc_k_headers_all_b h
        WHERE  1 = 1
          --AND    inc.rate_type <> 'USER'
	      AND  decode(upper(inc.rate_type),'USER',inc.chr_id,chr.chr_id) = chr.chr_id
		AND    (inc.rate_f <= 0 OR inc.rate_f is null)
        AND    h.id = chr.chr_id
        AND    chr.conversion_date = inc.curr_conv_date
        AND    chr.trx_currency = inc.from_currency
        AND    chr.func_currency = inc.to_currency
        AND    chr.trx_rate_type = inc.rate_type
        ORDER BY conversion_date)
    LOOP
      bis_collection_utilities.writeMissingContract(
          r_cur.complete_contract_number
        , r_cur.sts_code
        , r_cur.chr_id
        , r_cur.trx_rate_type
        , r_cur.trx_currency
        , r_cur.func_currency
        , r_cur.conversion_date);
    END LOOP ;

/**************Added By Arun for secondary global currency conversion*******/
  IF(l_sglobal_currency IS NOT NULL)
    THEN
      rout(rpad(' ' ,80 ,' '), 0 ) ;
      rout(rpad('*' ,80 ,'*'), 0 ) ;
      rout('                Other Errors in Functional To Secondary Global Conversion Rates', 0 ) ;
      rout('                Contact System Administrator with the list of Contracts', 0 ) ;
      rout('                Missing Functional To Secondary Global Conversion Rates',0);
      rout(rpad('*' ,80 ,'*'), 0 ) ;
      rout(' ', 0 ) ;


      FOR r_cur IN (
        SELECT /*+ leading(inc) use_hash(chr) use_nl(h) */
             distinct h.contract_number || ' ' ||
                 h.contract_number_modifier AS complete_contract_number
           , h.sts_code          AS sts_code
           , h.id                AS chr_id
           , inc.to_currency   AS func_currency
           , inc.curr_conv_date AS conversion_date
           , inc.rate_sg func_sglobal_rate
        FROM   oki_dbi_curr_conv inc
             , oki_dbi_chr_inc chr
             , okc_k_headers_all_b h
        WHERE  inc.rate_sg < 0
          --AND    inc.rate_type <> 'USER'
	      AND  decode(upper(inc.rate_type),'USER',inc.chr_id,chr.chr_id) = chr.chr_id
        AND    h.id = chr.chr_id
        AND    chr.conversion_date = inc.curr_conv_date
        AND    chr.trx_currency = inc.from_currency
        AND    chr.func_currency = inc.to_currency
        AND    chr.trx_rate_type = inc.rate_type
        ORDER BY conversion_date ASC )
      LOOP

       bis_collection_utilities.writeMissingContract(
          r_cur.complete_contract_number
         ,r_cur.sts_code
         ,r_cur.chr_id
         ,l_rate_type
         ,r_cur.func_currency
         ,l_sglobal_currency
         ,r_cur.conversion_date);

      END LOOP;
  END IF;
/**************changes for secondary global currency conversion ends here*******/

   EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       RAISE;
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(
                 token => 'ROUTINE'
               , value => 'OKI_DBI_LOAD_CLEB_PVT.report_missing_currencies ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
   END report_missing_currencies ;

/* *****************************************************************************
   Procedure:process_deletes
   Description:Identifies deleted lines from OLTP table and deletes
   such records from OKI_DBI base tables
   ************************************************************************** */
  PROCEDURE process_deletes  IS

     l_oki_schema          VARCHAR2(30);
     l_status              VARCHAR2(30);
     l_industry            VARCHAR2(30);
     l_sql_string          VARCHAR2(4000) ;
     l_count               NUMBER;

  BEGIN

    -- Delete the records from the last load from the delete table;
    IF (FND_INSTALLATION.GET_APP_INFO(
              application_short_name => 'OKI'
            , status                 => l_status
            , industry               => l_industry
            , oracle_schema          => l_oki_schema)) THEN

      l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema ||'.OKI_DBI_CLE_DEL' ;
      EXECUTE IMMEDIATE l_sql_string ;

      INSERT /*+ APPEND */ INTO oki_dbi_cle_del
      (cle_id)
      SELECT /*+ index_ffs(f OKI_DBI_CLE_B_U1) parallel_index(f OKI_DBI_CLE_B_U1) */
           f.cle_id
      FROM   oki_dbi_cle_b f
      WHERE  cle_id not in (SELECT /*+ index_ffs(okc OKC_K_LINES_B_U1) parallel_index(okc OKC_K_LINES_B_U1) */
							id
							FROM  okc_k_lines_b okc );

      l_count := SQL%ROWCOUNT;
      g_del_count := l_count;
      rlog('Number of lines identified for delete:  ' ||
              TO_CHAR(l_count), 2);
      COMMIT;

      IF ( g_del_count > 0 ) THEN
      DELETE FROM oki_dbi_cle_b
      WHERE  cle_id IN ( SELECT cle_id
                         FROM   oki_dbi_cle_del
                       );
      l_count := SQL%ROWCOUNT;
      END IF;
      rlog('Number of lines deleted from oki_dbi_cle_b:   ' ||
              TO_CHAR(l_count), 2);
      COMMIT;
     END IF ;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       RAISE;
    WHEN OTHERS THEN
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(
                           token => 'ROUTINE'
                         , value => 'OKI_DBI_LOAD_CLEB_PVT.PROCESS_DELETES ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END process_deletes;

/* *****************************************************************************
   Procedure:load_staging
   Description:Procedure to merge new/modified records from OLTP into OKI DBI Staging table
   p_worker - current worker number
   p_recs_processed - number or records processed by the current worker
   ************************************************************************** */
  PROCEDURE load_staging(
                          p_worker   IN NUMBER
                        , p_recs_processed OUT NOCOPY NUMBER
                       ) IS
    l_run_date   DATE ;
    l_location   VARCHAR2(1000) ;
    l_count      NUMBER ;
    l_login_id   NUMBER;

    l_annu_curr_code VARCHAR2(20);
    l_glob_curr_code VARCHAR2(20);
    l_sglob_curr_code VARCHAR2(20);
    l_renewal_logic   VARCHAR2(10);
    l_balance_logic   VARCHAR2(10);
    l_service_code number;
    l_warranty_code number;
    l_ext_warr_code number;

  BEGIN



    g_global_start_date  :=  bis_common_parameters.get_global_start_date;
    g_4712_date := to_date('01/01/4712' , 'MM/DD/YYYY');
    l_login_id   := FND_GLOBAL.login_id ;
    l_run_date    := sysdate;

    l_annu_curr_code := bis_common_parameters.get_annualized_currency_code;
    l_glob_curr_code := 'PRIMARY';/* BUg 4015406 bis_common_parameters.get_currency_code; */
    l_sglob_curr_code := 'SECONDARY';/*bis_common_parameters.get_secondary_currency_code;*/

    l_location := ' Inserting modified contract lines into OKI_DBI_CLE_B_OLD
                    table with worker '|| p_worker||'  ';
    rlog('Populating Staging Table OKI_DBI_CLE_B_OLD with updated/created Contracts : '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

	-- l_balance_logic:='EVENTDATE';
	-- l_balance_logic:=nvl(l_balance_logic,'CONTRDATE');

    /* Balance logic for OI */
	l_balance_logic := nvl(fnd_profile.value('OKI_BAL_IDENT'),'CONTRDATE');

  	/*Renewal logic for OI */
    l_renewal_logic := nvl(fnd_profile.value('OKI_REN_IDENT'),'STANDARD');

	rlog( 'Profile value for balance logic is '|| l_balance_logic , 1 );
	rlog( 'Profile value for renewal logic is '|| l_renewal_logic , 1 );

   /* Effective_expire_date is populated only if the date signed is not null. Prior to 8.0,
	  there was no scenario wherein a renewal could exist without thhe original contract was signed and so
      the expirations mv used r_date_signed and r_date_cancelled internally to ensure that date signed
	  was present. Because of transfers scenarios in R12, a renewal relationship can exist without the original
	  contract being signed and hence, to avoid unsigned contracts showing up in expirations, effective_expire_date
	  is populated only when date signed is not null */
SELECT Max(service_code),Max(warranty_code),Max(ext_warr_code)
INTO l_service_code,l_warranty_code,l_ext_warr_code
FROM
(
SELECT
Decode(lty_code,'SERVICE',Id) service_code,
Decode(lty_code,'WARRANTY',Id) warranty_code,
Decode(lty_code,'EXT_WARRANTY',Id) ext_warr_code
FROM okc_line_styles_b
WHERE lty_code IN ('SERVICE','WARRANTY','EXT_WARRANTY')
AND lse_parent_id IS NULL
);

SELECT MAX(renewal_id),MAX(ren_con_id)
	INTO g_renewal_id,g_ren_con_id
	from
	(
	SELECT decode(opn_code,'RENEWAL',id,null) Renewal_ID, decode(opn_code,'REN_CON',id,null) Ren_CON_ID
	from okc_class_operations clsop
	WHERE clsop.cls_code='SERVICE'
	AND clsop.opn_code in ('RENEWAL','REN_CON')
	);


    INSERT /*+ append */ INTO oki_dbi_cle_b_old(
               chr_id
             , cle_id
             , cle_creation_date
             , inv_organization_id
             , authoring_org_id
             , application_id
             , Customer_party_id
             , salesrep_id
             , price_negotiated
             , price_negotiated_f
             , price_negotiated_g
             , price_negotiated_sg
             , contract_number
             , contract_number_modifier
             , buy_or_sell
             , scs_code
             , sts_code
             , trn_code
             , root_lty_code
             , renewal_flag
             , date_signed
             , date_cancelled
             , start_date
             , end_date
             , date_terminated
             , effective_start_date
             , effective_end_date
             , trx_func_curr_rate
             , func_global_curr_rate
             , func_sglobal_curr_rate
             , resource_group_id
             , resource_id
             , sle_id
             , service_item_id
             , covered_item_id
             , covered_item_org_id
             , quantity
             , uom_code
             , grace_end_date
             , expected_close_date
             , win_percent
             , ubt_amt
             , ubt_amt_f
             , ubt_amt_g
             , ubt_amt_sg
             , credit_amt
             , credit_amt_f
             , credit_amt_g
             , credit_amt_sg
             , override_amt
             , override_amt_f
             , override_amt_g
             , override_amt_sg
             , supp_credit
             , supp_credit_f
             , supp_credit_g
             , supp_credit_sg
             , renewal_type
             , term_flag
             , hstart_date
             , hend_date
             , annualization_factor
             , ubt_amt_a
             , credit_amt_a
             , override_amt_a
             , supp_credit_a
             , price_negotiated_a
             , worker_number
             , created_by
             , creation_Date
             , last_update_Date
             , gsd_flag
             -- add the four extra columns
             , effective_active_date
             , effective_term_date
             , effective_expire_date
             , termination_entry_date
             , falsernwlyn
             , curr_code
             , curr_code_f
             , hdr_order_number
             , hdr_sts_code
             , hdr_trn_code
             , hdr_renewal_type
             , hdr_date_approved
             , hdr_date_cancelled
             , hdr_date_terminated
             , hdr_creation_date
             , hdr_last_update_date
             , service_item_org_id
             , sl_line_number
             , sl_sts_code
             , sl_trn_code
             , sl_renewal_type
             , sl_start_date
             , sl_end_Date
             , sl_date_cancelled
             , sl_date_terminated
             , sl_creation_date
             , sl_last_update_date
             , order_number
             , unit_price_percent
             , unit_price
             , unit_price_f
             , unit_price_g
             , unit_price_sg
             , list_price
             , list_price_f
             , list_price_g
             , list_price_sg
             , duration_uom
             , duration_qty
             , cl_last_update_date
             , cov_prod_id
             , cov_prod_system_id
             , line_number
             , line_type
             , hdr_bill_site_id
             , hdr_ship_site_id
             , hdr_acct_rule_id
             , hdr_grace_end_date
             , hdr_date_signed
	           , hdr_subsequent_renewal_type		/* Added this colunm as a part of ER#5760744 */
             , agreement_type_code /* for ER 6062516 */
	           , agreement_name   /* for ER 6062516 */
	           , negotiation_status  /* Added this colunm as a part of ER#5950128 */
	           , reminder            /* Added this colunm as a part of ER#5950128 */
	           , HDR_TERM_CANCEL_SOURCE  /* Added as part of ER6684955 */
	           , SL_TERM_CANCEL_SOURCE   /* Added as part of ER6684955 */
             )
         ( select
               new.chr_id
             , new.cle_id
             , new.cle_creation_date
             , new.inv_organization_id
             , new.authoring_org_id
             , new.application_id
             , new.Customer_party_id
             , new.salesrep_id
             , new.price_negotiated
             , new.price_negotiated_f
             , new.price_negotiated_g
             , new.price_negotiated_sg
             , new.contract_number
             , new.contract_number_modifier
             , new.buy_or_sell
             , new.scs_code
             , new.sts_code
             , new.trn_code
             , new.root_lty_code
             , new.renewal_flag
             , new.date_signed
             , new.date_cancelled
             , new.start_date
             , new.end_date
             , new.date_terminated
             , new.effective_start_date
             , case when l_balance_logic='CONTRDATE' THEN new.effective_end_date
                    ELSE NVL2(new.date_terminated, new.effective_term_date,new.effective_expire_date)
               end effective_end_date
             , new.trx_func_curr_rate
             , new.func_global_curr_rate
             , new.func_sglobal_curr_rate
             , new.resource_group_id
             , new.resource_id
             , new.sle_id
             , new.service_item_id
             , new.covered_item_id
             , case new.covered_item_id when -1 then -99 else new.inv_organization_id end covered_item_org_id
             , new.quantity
             , new.uom_code
             , new.grace_end_date
             , new.expected_close_date
             , new.win_percent
             , new.ubt_amt
             , new.ubt_amt_f
             , new.ubt_amt_g
             , new.ubt_amt_sg
             , new.credit_amt
             , new.credit_amt_f
             , new.credit_amt_g
             , new.credit_amt_sg
             , new.override_amt
             , new.override_amt_f
             , new.override_amt_g
             , new.override_amt_sg
             , new.supp_credit
             , new.supp_credit_f
             , new.supp_credit_g
             , new.supp_credit_sg
             , new.renewal_type
             , new.term_flag
             , new.hstart_date
             , new.hend_date
             , new.annualization_factor
             , case l_annu_curr_code when l_glob_curr_code then new.ubt_amt_g
                                     when  l_sglob_curr_code then new.ubt_amt_sg
                                     else new.ubt_amt_g end * new.annualization_factor ubt_amt_a
             , case l_annu_curr_code when l_glob_curr_code then new.credit_amt_g
                                     when l_sglob_curr_code then new.credit_amt_sg
                                     else new.credit_amt_g end * new.annualization_factor credit_amt_a
             , case l_annu_curr_code when l_glob_curr_code then new.override_amt_g
                                     when l_sglob_curr_code then new.override_amt_sg
                                     else new.override_amt_g end * new.annualization_factor override_amt_a
             , case l_annu_curr_code when l_glob_curr_code then new.supp_credit_g
                                     when l_sglob_curr_code then new.supp_credit_sg
                                     else new.supp_credit_g end * new.annualization_factor supp_credit_a
             , case l_annu_curr_code when l_glob_curr_code then new.price_negotiated_g
                                     when l_sglob_curr_code then new.price_negotiated_sg
                                    else new.price_negotiated_g end * new.annualization_factor price_negotiated_a
             , p_worker
             , l_login_id
             , l_run_Date
             , l_run_date
             , new.gsd_flag
             -- add the four extra columns
             , new.effective_active_date
             , new.effective_term_date
             , new.effective_expire_date
             , new.termination_entry_date
             , new.falsernwlyn
             , new.curr_code
             , new.curr_code_f
             , new.hdr_order_number
             , new.hdr_sts_code
             , new.hdr_trn_code
             , new.hdr_renewal_type
             , new.hdr_date_approved
             , new.hdr_date_cancelled
             , new.hdr_date_terminated
             , new.hdr_creation_date
             , new.hdr_last_update_date
             , new.service_item_org_id
             , new.sl_line_number
             , new.sl_sts_code
             , new.sl_trn_code
             , new.sl_renewal_type
             , new.sl_start_date
             , new.sl_end_Date
             , new.sl_date_cancelled
             , new.sl_date_terminated
             , new.sl_creation_date
             , new.sl_last_update_date
             , new.order_number
             , new.unit_price_percent
             , new.unit_price
             , new.unit_price_f
             , new.unit_price_g
             , new.unit_price_sg
             , new.list_price
             , new.list_price_f
             , new.list_price_g
             , new.list_price_sg
             , new.duration_uom
             , new.duration_qty
             , new.cl_last_update_date
             , new.cov_prod_id
             , new.cov_prod_system_id
             , new.line_number
             , new.line_type
             , new.hdr_bill_site_id
             , new.hdr_ship_site_id
             , new.hdr_acct_rule_id
             , new.hdr_grace_end_date
             , new.hdr_date_signed
	           , new.hdr_subsequent_renewal_type	/* Added this colunm as a part of ER#5760744 */
	           , new.agreement_type_code /* for ER 6062516 */
	           , new.agreement_name   /* for ER 6062516 */
	           , new.negotiation_status  /* Added this colunm as a part of ER#5950128 */
	           , new.reminder            /* Added this colunm as a part of ER#5950128 */
	           , new.HDR_TERM_CANCEL_SOURCE  /* Added as part of ER6684955 */
	           , new.SL_TERM_CANCEL_SOURCE  /* Added as part of ER6684955 */
       from     (SELECT
                    ilv1.chr_id
                  , ilv1.cle_id
                  , ilv1.cle_creation_date
                  , ilv1.inv_organization_id
                  , ilv1.authoring_org_id
                  , ilv1.application_id
                  , ilv1.Customer_party_id
                  , ilv1.salesrep_id
                  , ilv1.price_negotiated
                  , ilv1.price_negotiated_f
                  , ilv1.price_negotiated_g
                  , ilv1.price_negotiated_sg
                  , ilv1.contract_number
                  , ilv1.contract_number_modifier
                  , ilv1.buy_or_sell
                  , ilv1.scs_code
                  , ilv1.sts_code
                  , ilv1.trn_code
                  , ilv1.root_lty_code
                  , ilv1.date_signed
                  , ilv1.date_cancelled
                  , ilv1.start_date
                  , ilv1.end_date
                  , ilv1.date_terminated
                  , ilv1.trx_func_curr_rate
                  , ilv1.func_global_curr_rate
                  , ilv1.func_sglobal_curr_rate
                  , ilv1.resource_group_id
                  , ilv1.resource_id
                  , ilv1.sle_id
                  , ilv1.quantity
                  , ilv1.uom_code
				  /*, msi.primary_uom_code
                  , poa_dbi_uom_pkg.convert_to_item_base_uom (
                        ilv1.covered_item_id
                      , ilv1.inv_organization_id
                      , NULL
                      , msi.primary_uom_code
                      , ilv1.uom_code) AS trx_mst_uom_conv_rate
					  */
                  , ilv1.grace_end_date
                  , ilv1.expected_close_date
                  , ilv1.win_percent
                  , ilv1.ubt_amt
                  , ilv1.ubt_amt * ilv1.trx_func_curr_rate ubt_amt_f
                  , ilv1.ubt_amt * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate ubt_amt_g
                  , ilv1.ubt_amt * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate ubt_amt_sg
                  , ilv1.credit_amt
                  , ilv1.credit_amt * ilv1.trx_func_curr_rate credit_amt_f
                  , ilv1.credit_amt * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate credit_amt_g
                  , ilv1.credit_amt * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate credit_amt_sg
                  , ilv1.override_amt
                  , ilv1.override_amt * ilv1.trx_func_curr_rate override_amt_f
                  , ilv1.override_amt * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate override_amt_g
                  , ilv1.override_amt * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate override_amt_sg
                  , ilv1.supp_credit
                  , ilv1.supp_credit * ilv1.trx_func_curr_rate supp_credit_f
                  , ilv1.supp_credit * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate supp_credit_g
                  , ilv1.supp_credit * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate supp_credit_sg
                  , ilv1.renewal_type
                  , CASE WHEN ilv1.date_terminated < ilv1.start_date THEN -1 ELSE 1 END term_flag
                  , ilv1.hstart_date
                  , ilv1.hend_date
                  , ilv1.annualization_factor annualization_factor
                  , ilv1.gsd_flag
                  , case when l_balance_logic='CONTRDATE' THEN date_terminated
                         ELSE least(greatest(date_terminated,
                    	                       termination_entry_date,
                    	                       nvl(date_signed,date_terminated)),
                                     greatest(ilv1.date_signed,ilv1.end_date))
                    --Usually date_terminated cannot be prsent without date signed.
                    --This is a check for bad data available in the volume environments
                    END effective_term_date
                  , case when l_balance_logic='CONTRDATE' and ilv1.date_signed is not null THEN ilv1.end_date
                         ELSE greatest(ilv1.date_signed,ilv1.end_date)
                    END effective_expire_date
                  , case when l_balance_logic='CONTRDATE'  and ilv1.date_signed is not null THEN ilv1.start_date
                         ELSE greatest(ilv1.date_signed,ilv1.start_date)
                    END effective_active_date
                  , NVL2(ilv1.date_terminated,termination_entry_date,NULL) termination_entry_date
                  /* We change the definition given in the inner query if the value of balance logic is event dates */
                  , case when l_balance_logic='CONTRDATE' THEN ilv1.effective_start_date
                         else greatest(ilv1.date_signed,ilv1.start_date)
                    end effective_start_date
                  , ilv1.effective_end_date
                  , ilv1.curr_code
                  , ilv1.curr_code_f
                  , ilv1.hdr_order_number
                  , ilv1.hdr_sts_code
                  , ilv1.hdr_trn_code
                  , ilv1.hdr_renewal_type
                  , ilv1.hdr_date_approved
                  , ilv1.hdr_date_cancelled
                  , ilv1.hdr_date_terminated
                  , ilv1.hdr_creation_date
                  , ilv1.hdr_last_update_date
                  , (select to_number(substr(ilv1.service_item_attribs,1,instr(service_item_attribs,'#')-1)) from dual) service_item_id
                  , (select to_number(substr(ilv1.service_item_attribs,instr(service_item_attribs,'#')+1)) from dual) service_item_org_id
                  , ilv1.sl_line_number
                  , ilv1.sl_sts_code
                  , ilv1.sl_trn_code
                  , ilv1.sl_renewal_type
                  , ilv1.sl_start_date
                  , ilv1.sl_end_Date
                  , ilv1.sl_date_cancelled
                  , ilv1.sl_date_terminated
                  , ilv1.sl_creation_date
                  , ilv1.sl_last_update_date
                  , CASE l_renewal_logic when 'STANDARD' THEN ilv1.okc_renewal_flag
                                       else NVL2(ilv1.order_number,0,1) END renewal_flag
                  , CASE WHEN l_renewal_logic= 'ORDERNO' AND ilv1.order_number IS NULL
                           AND ilv1.okc_renewal_flag = 0 THEN 'Y'
                     END falsernwlyn
                  , ilv1.order_number
                  , ilv1.unit_price_percent
                  , ilv1.unit_price
                  , nvl(ilv1.unit_price,0) * ilv1.trx_func_curr_rate unit_price_f
                  , nvl(ilv1.unit_price,0) * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate unit_price_g
                  , nvl(ilv1.unit_price,0) * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate unit_price_sg
                  , ilv1.list_price
                  , nvl(ilv1.list_price,0) * ilv1.trx_func_curr_rate list_price_f
                  , nvl(ilv1.list_price,0) * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate list_price_g
                  , nvl(ilv1.list_price,0) * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate list_price_sg
                  , ilv1.duration_uom
                  , ilv1.duration_qty
                  , ilv1.cl_last_update_date
                  , ilv1.line_number
                  , ilv1.line_type
                  , ilv1.hdr_bill_site_id
                  , ilv1.hdr_ship_site_id
                  , ilv1.hdr_acct_rule_id
                  , ilv1.hdr_grace_end_date
                  , ilv1.hdr_date_signed
                  , CASE line_type when 'COVER_PROD' THEN
                      to_number(substr(csi_attribs,1,instr(csi_attribs,'#')-1))
                     ELSE -999 END cov_prod_id
                  , CASE line_type when 'COVER_PROD' THEN
                      to_number(substr(csi_attribs,instr(csi_attribs,'#')+1,instr(csi_attribs,'#',1,2)-instr(csi_attribs,'#')-1))
                     ELSE -999 END cov_prod_system_id
                  , CASE line_type when 'COVER_ITEM' THEN  covered_item_id
                                   when 'COVER_PROD' then to_number(substr(csi_attribs,instr(csi_attribs,'#',-1)+1))
                     ELSE -1 END     covered_item_id
		              , ilv1.hdr_subsequent_renewal_type	/* Added this colunm as a part of ER#5760744 */
		              , ilv1.agreement_type_code		/* for ER 6062516 */
	                , ilv1.agreement_name			/* for ER 6062516 */
		              , ilv1.negotiation_status             /* Added this colunm as a part of ER#5950128 */
		              , ilv1.reminder                       /* Added this colunm as a part of ER#5950128 */
		              , ilv1.HDR_TERM_CANCEL_SOURCE   /* Added as part of ER6684955 */
	                , ilv1.SL_TERM_CANCEL_SOURCE    /* Added as part of ER6684955 */
           FROM (SELECT /*+ ordered use_nl(root_temp,agmt) cardinality(h,10)*/
                           h.chr_id        AS chr_id
                         , l.id            AS cle_id
                         , l.creation_date AS cle_creation_date
                         , h.master_organization_id inv_organization_id
                         , h.authoring_org_id
                         , h.application_id
                         , h.customer_party_id
                         , h.salesrep_id
                         , nvl(l.price_negotiated,0) price_negotiated
                         , nvl(l.price_negotiated,0) * cur.rate_f AS price_negotiated_f
                         , nvl(l.price_negotiated,0) * cur.rate_g AS price_negotiated_g
                         , nvl(l.price_negotiated,0) * cur.rate_sg AS price_negotiated_sg
                         , h.contract_number
                         , h.contract_number_modifier
                         , h.buy_or_sell
                         , h.scs_code
                         , l.sts_code
                         , NVL(l.trn_code,h.trn_code)  AS trn_code
                         , root_temp.root_lty_code
                         , l.annualized_factor annualization_factor
                         , NVL2(l.date_cancelled,null,date_signed) date_signed
                         , h.datetime_cancelled hdr_date_cancelled
                         , sl.date_cancelled sl_date_cancelled
                         , l.date_cancelled   AS date_cancelled
                         , h.sts_code hdr_sts_code
                         , sl.sts_code sl_sts_code
                         , h.start_date hstart_date
                         , h.end_date hend_date
                         , l.start_date AS start_date
                         , COALESCE(l.end_date,h.end_date,g_4712_date)+1 AS end_date
                         , NVL2(h.date_signed, l.date_terminated,NULL ) AS date_terminated
                         , NVL2(h.date_signed, l.start_date, NULL) effective_start_date
                         , NVL2(h.date_signed, LEAST( COALESCE(l.end_date
                                                             , h.end_date
                                                             , g_4712_date) +1
                                                     ,COALESCE(l.date_terminated
                                                              , h.date_terminated
                                                              , g_4712_date))
                                 , NULL) AS effective_end_date
                         , cur.rate_f AS trx_func_curr_rate
                         , cur.rate_g / decode(cur.rate_f,0,-1,cur.rate_f) AS func_global_curr_rate
                         , cur.rate_sg / decode(cur.rate_f,0,-1,cur.rate_f) AS func_sglobal_curr_rate
                         , h.resource_group_id resource_group_id
                         , h.resource_id resource_id
                         , sl.id  AS sle_id
                         , CASE root_temp.lty_code when 'COVER_ITEM' then TO_NUMBER (itm2.object1_id1) END covered_item_id
                         , itm2.number_of_items quantity
                         , itm2.uom_code uom_code
                         , CASE WHEN h.end_date = l.end_date
                                THEN h.grace_end_date
                                ELSE NULL
                           END grace_end_date
                         , h.est_rev_date   AS expected_close_date
                         , h.est_rev_percent  AS win_percent
                         -- terminated amounts
                         , nvl(oksl.ubt_amount,0) ubt_amt
                         , nvl(oksl.credit_amount,0) credit_amt
                         , nvl(oksl.override_amount,0) override_amt
                         , nvl(oksl.suppressed_credit,0) supp_credit
                         , h.renewal_type_code    hdr_renewal_type
                         , CASE NVL(h.renewal_type_code,sl.line_renewal_Type_code) when 'DNR' THEN 'DNR'
                            ELSE l.line_renewal_type_code
                           END renewal_type
                         , h.gsd_flag
                         -- we take last update date as the candidate for termination entry date
                         , l.last_update_date termination_entry_date
                         , h.trx_currency              curr_code
                         , h.func_currency             curr_code_f
                         , h.order_number             hdr_order_number
                         , ( select object1_id1||'#' || object1_id2 from okc_k_items
                             where cle_id = sl.id and rownum=1) service_item_attribs
                         /* For line lelvel order number */
                         ,CASE WHEN root_lty_code <> 'WARRANTY' then (
                         /* rel objs has multiple entries for the same order number */
                            Select oehdr.order_number order_number
                              from  oe_order_headers_all  oehdr
                                  , oe_order_lines_all oelin
                                  , okc_k_rel_objs okcrel
                            WHERE  okcrel.object1_id1 = oelin.line_id
                              AND  oehdr.header_id = oelin.header_id
                              AND  okcrel.cle_id = l.id
                              AND  rownum=1 )
                          /* End of for line level order number */
                            ELSE h.order_number END order_number
                         , NVL(( SELECT  1
                               FROM    okc_operation_lines okl
                                     , okc_operation_instances opins
                              WHERE okl.oie_id=opins.id
                                AND opins.cop_id in (g_renewal_id,g_ren_con_id)
                                AND object_cle_id IS NOT NULL
                                AND subject_cle_id = l.id
                                AND rownum = 1),0) okc_renewal_flag
                         , CASE root_temp.lty_code WHEN 'COVER_PROD' THEN
                             ( select instance_id || '#' || system_id || '#' || inventory_item_id
                                from csi_item_instances where instance_id = itm2.object1_id1)
                            END csi_attribs
                         , h.trn_code                  hdr_trn_code
                         , h.date_approved             hdr_date_approved
                         , h.date_terminated           hdr_date_terminated
                         , h.creation_Date             hdr_creation_date
                         , h.last_update_date          hdr_last_update_date
                         , sl.line_number              sl_line_number
                         , NVL(sl.trn_code,h.trn_code) sl_trn_code
                         , CASE WHEN h.renewal_type_code = 'DNR' THEN 'DNR'
                             ELSE sl.line_renewal_type_code
                            END sl_renewal_type
                         , sl.start_date               sl_start_date
                         , sl.end_date                 sl_end_Date
                         , sl.date_terminated          sl_date_terminated
                         , sl.creation_date            sl_creation_date
                         , sl.last_update_date         sl_last_update_date
                         , case oksl.toplvl_operand_code when 'PERCENT_PRICE'
                                then oksl.toplvl_operand_val
                            end unit_price_percent
                         , nvl(l.price_unit,0)         unit_price
                         , nvl(l.line_list_price,0)    list_price
                         , oksl.toplvl_uom_code        duration_uom
                         , oksl.toplvl_price_qty       duration_qty
                         , l.last_update_date          cl_last_update_date
                         , sl.line_number ||'.' || l.line_number line_number
                         , root_temp.lty_code          line_type
                         , h.Bill_to_site_use_id hdr_bill_site_id
                         , h.Ship_to_site_use_id hdr_ship_site_id
                         , h.Acct_rule_id     hdr_acct_rule_id
                         , h.grace_end_date      hdr_grace_end_date
                         , h.date_signed hdr_date_signed
		                     , h.renewal_type_code hdr_subsequent_renewal_type	/* Added this colunm as a part of ER#5760744 */
		                     , agmt.agreement_type_code                             /* for ER 6062516 */
	                       , agmt.agreement_name                                  /* for ER 6062516 */
			                   , h.negotiation_status negotiation_status              /* Added this colunm as a part of ER#5950128 */
			                   , decode(h.reminder, 'Y', 'Enable', 'N', 'Disable', h.reminder) reminder   /* Added this colunm as a part of ER#5950128 */
			                   , h.HDR_TERM_CANCEL_SOURCE HDR_TERM_CANCEL_SOURCE
			                   , NVL(sl.term_cancel_source, h.HDR_TERM_CANCEL_SOURCE)  SL_TERM_CANCEL_SOURCE
                  FROM
                         oki_dbi_chr_inc h
                       , oki_dbi_curr_conv cur
                       , okc_k_lines_b sl
                       , okc_k_lines_b l
                       , ( select /*+ no_merge */ cii.instance_id
                                 , qpl.meaning agreement_type_code
                                 , oat.name agreement_name
                             from oe_agreements_tl oat,
		                              qp_lookups qpl,
                                  oe_agreements_b oab,
                                  csi_item_instances cii
                             where oab.agreement_id = oat.agreement_id
                               and cii.last_oe_agreement_id = oab.agreement_id(+)
                               and oat.language = userenv('LANG')
                               and qpl.lookup_type(+) = 'QP_AGREEMENT_TYPE'
		                           and qpl.lookup_code(+) = oab.agreement_type_code
                          ) agmt     /* for ER 6062516 */
                        , (Select id,lty_code,
                                      case lse_parent_id when l_service_code then 'SERVICE'
                                                        when l_warranty_code then 'WARRANTY'
                                                        when l_ext_warr_code then 'EXT_WARRANTY'
							                        END root_lty_code
                              FROM okc_line_styles_b n
                              where lse_parent_id   = l_service_code
                               or lse_parent_id = l_warranty_code
                               or lse_parent_id = l_ext_warr_code ) root_temp
                       , okc_k_items itm2
                       , oks_k_lines_b oksl
                  WHERE 1 = 1
                   AND h.worker_number   = p_worker
                   AND (h.chr_id = cur.chr_id OR upper(cur.rate_type) <> 'USER')
                   AND h.conversion_date = cur.curr_conv_date
                   AND h.trx_currency    = cur.from_currency
                   AND h.func_currency   = cur.to_currency
                   AND h.trx_rate_type   = cur.rate_type
                   AND h.chr_id          = sl.chr_id
                   AND sl.id             = l.cle_id
                   AND l.price_level_ind = 'Y'
                   AND l.lse_id          = root_temp.id
                   AND l.id              = itm2.cle_id
                   AND l.id              = oksl.cle_id
		   AND itm2.object1_id1  = agmt.instance_id(+)
                 ) ilv1
            )new
         WHERE NOT EXISTS
         (
           SELECT 1 FROM oki_dbi_cle_b old
               WHERE   new.cle_id                                = old.cle_id
                 AND   new.cl_last_update_date                   = old.cl_last_update_date
                 AND   new.sl_last_update_date                   = old.sl_last_update_date
                 AND   new.hdr_last_update_date                  = old.hdr_last_update_date
                 AND   NVL(new.salesrep_id,-9999)                = NVL(old.salesrep_id,-9999)
                 AND   new.renewal_flag                          = old.renewal_flag
                 AND   new.term_flag                             = old.term_flag
                 AND   NVL(new.ubt_amt,0)                        = NVL(old.ubt_amt,0)
                 AND   NVL(new.credit_amt,0)                     = NVL(old.credit_amt,0)
                 AND   NVL(new.override_amt,0)                   = NVL(old.override_amt,0)
                 AND   NVL(new.trx_func_curr_rate,-1)            = NVL(old.trx_func_curr_rate,-1)
                 AND   NVL(new.func_global_curr_rate,-1)         = NVL(old.func_global_curr_rate,-1)
                 AND   NVL(new.func_sglobal_curr_rate,-1)         = NVL(old.func_sglobal_curr_rate,-1)
                 AND   NVL(new.resource_group_id, -9999)         = NVL(old.resource_group_id, -9999)
                 AND   NVL(new.resource_id, -1)                  = NVL(old.resource_id, -1)
                 AND   NVL(new.grace_end_date, l_run_date)       = NVL(old.grace_end_date, l_run_date)
                 AND   NVL(new.expected_close_date, l_run_date)  = NVL(old.expected_close_date, l_run_date)
                 AND   new.curr_code_f                           = old.curr_code_f
                 AND   NVL(new.hdr_order_number,-99999)          = NVL(old.hdr_order_number,-99999)
                 AND   NVL(new.order_number,-99999)              = NVL(old.order_number,-99999)
                 AND   NVL(new.unit_price_percent,-99999)        = NVL(old.unit_price_percent,-99999)
                 AND   NVL(new.list_price,-99999)                = NVL(old.list_price,-99999)
                 AND   NVL(new.duration_uom,'ABC')               = NVL(old.duration_uom,'ABC')
                 AND   NVL(new.duration_qty,-99999)              = NVL(old.duration_qty,-99999)
                 AND   NVL(new.cov_prod_id,-99999)               = NVL(old.cov_prod_id,-99999)
                 AND   NVL(new.cov_prod_system_id,-99999)        = NVL(old.cov_prod_system_id,-99999)
                 AND   nvl(new.hdr_acct_rule_id,-99999)          = old.hdr_acct_rule_id
                 AND   new.service_item_org_id                   = old.service_item_org_id
--               AND   new.sts_code                              = old.sts_code
--               AND   new.hstart_date                           = old.hstart_date
--               AND   new.hend_date                             = old.hend_date
--               AND   NVL(new.hdr_date_approved,l_run_date)     = NVL(old.hdr_date_approved,l_run_date)
--               AND   NVL(new.hdr_date_cancelled,l_run_date)    = NVL(old.hdr_date_cancelled,l_run_date)
--               AND   NVL(new.hdr_date_terminated,l_run_date)   = NVL(old.hdr_date_terminated,l_run_date)
--               AND   NVL(new.sl_start_date,l_run_date)         = NVL(old.sl_start_date,l_run_date)
--               AND   NVL(new.sl_end_Date,l_run_date)           = NVL(old.sl_end_Date,l_run_date)
--               AND   NVL(new.sl_date_cancelled,l_run_date)     = NVL(old.sl_date_cancelled,l_run_date)
--               AND   NVL(new.sl_date_terminated,l_run_date)    = NVL(old.sl_date_terminated,l_run_date)
--               AND   new.start_date                            = old.start_date
--               AND   new.end_date                              = old.end_date
--               AND   NVL(new.date_signed,l_run_date)           = NVL(old.date_signed,l_run_date)
--               AND   NVL(new.date_cancelled,l_run_date)        = NVL(old.date_cancelled,l_run_date)
--               AND   NVL(new.date_terminated,l_run_date)       = NVL(old.date_terminated,l_run_date)
--               AND   NVL(new.price_negotiated,0)               = NVL(old.price_negotiated,0)
--               AND   NVL(new.trn_code,'X')                     = NVL(old.trn_code,'X')
--               AND   new.renewal_type                          = old.renewal_type
--               AND   new.inv_organization_id                   = old.inv_organization_id
--               AND   NVL(new.supp_credit,0)                    = NVL(old.supp_credit,0)
--               AND   NVL(new.root_lty_code,'X')                = NVL(old.root_lty_code,'X')
--               AND   new.customer_party_id                     = old.customer_party_id
--               AND   NVL(new.service_item_id, -1)              = NVL(old.service_item_id, -1)
--               AND   NVL(new.covered_item_id, -1)              = NVL(old.covered_item_id, -1)
--               AND   NVL(new.win_percent, -1)                  = NVL(old.win_percent, -1)
--               AND   new.curr_code                             = old.curr_code
--               AND   new.hdr_sts_code                          = old.hdr_sts_code
--               AND   NVL(new.hdr_trn_code,'ABC')               = NVL(old.hdr_trn_code,'ABC')
--               AND   NVL(new.hdr_renewal_type,'ABC')           = NVL(old.hdr_renewal_type,'ABC')
--               AND   new.sl_line_number                        = old.sl_line_number
--               AND   new.sl_sts_code                           = old.sl_sts_code
--               AND   NVL(new.sl_trn_code,'ABC')                = NVL(old.sl_trn_code,'ABC')
--               AND   NVL(new.sl_renewal_type,'ABC')            = NVL(old.sl_renewal_type,'ABC')
--               AND   NVL(new.unit_price,-99999)                = NVL(old.unit_price,-99999)
--               AND   nvl(new.hdr_bill_site_id,-99999)          = old.hdr_bill_site_id
--               AND   nvl(new.hdr_ship_site_id,-99999)          = old.hdr_ship_site_id
--               AND   new.line_number                           = old.line_number
--               AND   new.line_type                             = old.line_type
--               AND   NVL(new.effective_start_date,l_run_date)  = NVL(old.effective_start_date,l_run_date)
--               AND   NVL(new.effective_end_date,l_run_date)    = NVL(old.effective_end_date,l_run_date)
--               AND   NVL(new.price_negotiated_f,0)             = NVL(old.price_negotiated_f,0)
--               AND   NVL(new.price_negotiated_g,0)             = NVL(old.price_negotiated_g,0)
--               AND   NVL(new.price_negotiated_sg,0)            = NVL(old.price_negotiated_sg,0)
--               AND   NVL(new.ubt_amt_f,0)                      = NVL(old.ubt_amt_f,0)
--               AND   NVL(new.ubt_amt_g,0)                      = NVL(old.ubt_amt_g,0)
--               AND   NVL(new.ubt_amt_sg,0)                     = NVL(old.ubt_amt_sg,0)
--               AND   NVL(new.credit_amt_f,0)                   = NVL(old.credit_amt_f,0)
--               AND   NVL(new.credit_amt_g,0)                   = NVL(old.credit_amt_g,0)
--               AND   NVL(new.credit_amt_sg,0)                  = NVL(old.credit_amt_sg,0)
--               AND   NVL(new.override_amt_f,0)                 = NVL(old.override_amt_f,0)
--               AND   NVL(new.override_amt_g,0)                 = NVL(old.override_amt_g,0)
--               AND   NVL(new.override_amt_sg,0)                = NVL(old.override_amt_sg,0)
--               AND   NVL(new.supp_credit_f,0)                  = NVL(old.supp_credit_f,0)
--               AND   NVL(new.supp_credit_g,0)                  = NVL(old.supp_credit_g,0)
--               AND   NVL(new.supp_credit_sg,0)                 = NVL(old.supp_credit_sg,0)
--               AND   NVL(new.sle_id, -1)                       = NVL(old.sle_id, -1)
--               AND   NVL(new.quantity, -1)                     = NVL(old.quantity, -1)
--               AND   NVL(new.uom_code, 'X')                    = NVL(old.uom_code, 'X')
--               AND   NVL(new.unit_price_f,-99999)              = NVL(old.unit_price_f,-99999)
--               AND   NVL(new.unit_price_g,-99999)              = NVL(old.unit_price_g,-99999)
--               AND   NVL(new.unit_price_sg,-99999)             = NVL(old.unit_price_sg,-99999)
--               AND   NVL(new.list_price_f,-99999)              = NVL(old.list_price_f,-99999)
--               AND   NVL(new.list_price_g,-99999)              = NVL(old.list_price_g,-99999)
--               AND   NVL(new.list_price_sg,-99999)             = NVL(old.list_price_sg,-99999)
--               AND   NVL(new.effective_term_date,l_run_date)   = NVL(old.effective_term_date,l_run_date)
--               AND   NVL(new.effective_expire_date,l_run_date) = NVL(old.effective_expire_date,l_run_date)
--               AND   NVL(new.effective_active_date,l_run_date) = NVL(old.effective_active_date,l_run_date)
--               AND   NVL(new.falsernwlyn,'ABC')                = NVL(old.falsernwlyn,'ABC')
--               AND   NVL(new.hdr_grace_end_date, l_run_date)   = NVL(old.hdr_grace_end_date, l_run_date)
--               AND   NVL(new.hdr_date_signed,l_run_date)       = NVL(old.hdr_date_signed,l_run_date)
        ));
    p_recs_processed := SQL%ROWCOUNT ;
    rlog( 'Number of lines inserted into OKI_DBI_CLE_B_OLD is '||p_recs_processed,2);
    rlog('Load of Staging Table OKI_DBI_CLE_B_OLD for updated/created Contracts completed: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;
    COMMIT;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       RAISE;
   WHEN OTHERS THEN
      rlog('Error during load_staging: ' || l_location || ' Failed' , 0);
      rlog(sqlerrm ||'   '||sqlcode, 0) ;
      rlog(l_location , 0) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_LOAD_CLEB_PVT.LOAD_STAGING ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
  END load_staging;

/*******************************************************************************
  Procedure:   populate_ren_rel
  Description: populate renewal relationship needs to be done in three phases
               and in the order of delta changes (1), latest relations (2),
               and updates due to deletes(3). This needs to be done in the same
               order to avoid any overriding of the relathip information.
               1. Identify lines that got affected due to delta changes
               2. Apply on top of this latest relations
               3. Identify new relation ships to lines affected due to deletes.
               Changing the order may override the actual relationships
  Parameters: p_no_of_workers Number of sub workers entered by the user
*******************************************************************************/
  PROCEDURE populate_ren_rel(p_no_of_workers IN NUMBER) IS

  l_start_date  DATE;
  l_end_date    DATE;
  l_run_date    DATE;
  l_batch_size  NUMBER;
  l_sql_string  VARCHAR2(4000);
  l_oki_schema  VARCHAR2(30);
  l_status      VARCHAR2(30);
  l_industry    VARCHAR2(30);
  l_count       NUMBER;
  l_location    VARCHAR2(1000);

  BEGIN
    l_start_date := OKI_DBI_LOAD_CLEB_PVT.g_start_date ;
    l_end_date   := OKI_DBI_LOAD_CLEB_PVT.g_end_date ;
    l_run_date   := OKI_DBI_LOAD_CLEB_PVT.g_run_date ;

    rlog('Populating  table OKI_DBI_REN_INC due to ''Operation Lines Changes'': '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;
          /* Changes to operation_lines */
		  /* Changed for appsperf bug 4913262 */
          MERGE /*+ INDEX(B OKI_DBI_REN_INC_U1) */ INTO  OKI_DBI_REN_INC b
          USING
            (SELECT  s1.cle_id
                   , s1.r_cle_id
                   , case when g_true_incr = 1 then mod(rownum-1,p_no_of_workers)+1 else -99 end worker_number
             FROM (SELECT /*+ ordered use_nl(OPINS,CLSOP)*/
                            rel.object_cle_id cle_id
                          , MAX(rel.subject_cle_id) KEEP (DENSE_RANK LAST
                                 ORDER BY rel.last_update_date) r_cle_id
	                 FROM OKC_OPERATION_LINES REL ,
				            OKC_OPERATION_INSTANCES OPINS,
				            OKC_CLASS_OPERATIONS CLSOP
					WHERE  1 = 1
					AND rel.oie_id=opins.id
					AND opins.cop_id=clsop.id
					AND clsop.cls_code='SERVICE'
					AND clsop.opn_code in ('RENEWAL','REN_CON')
                    AND
                    (  EXISTS
                       (select null
                        FROM oki_dbi_cle_b b
                        where b.cle_id = rel.object_cle_id)
                    OR
                       EXISTS
                       (select null
                        FROM oki_dbi_cle_b_old o
                        where o.cle_Id = rel.object_cle_id)
                    )
                   AND rel.object_cle_id    IS NOT NULL
                   AND rel.subject_cle_id   IS NOT NULL
                   AND rel.last_update_date BETWEEN l_start_date AND l_end_date
                   GROUP BY rel.object_cle_id) s1
            ) s
          ON (b.cle_id = s.cle_id)
          WHEN MATCHED THEN
            UPDATE SET
                     r_cle_id      = s.r_cle_id
                  ,  worker_number = s.worker_number
          WHEN NOT MATCHED THEN
            INSERT(
                     cle_id
                   , r_cle_id
                   , worker_number
            ) VALUES (
                     s.cle_id
                   , s.r_cle_id
                   , s.worker_number
            );

          l_count := SQL%ROWCOUNT;

      rlog( 'Number of lines inserted into OKI_DBI_REN_INC : '
                                                          ||TO_CHAR(l_count),2);
      rlog('Load of table OKI_DBI_REN_INC due to ''Operation Lines Changes'' completed: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;
          COMMIT;

   IF  g_true_incr = 0 THEN

--            GATHER_TABLE_STATS(TABNAME=>'OKI_DBI_REN_INC');

      rlog('Updating table OKI_DBI_REN_INC due to ''Operation Lines Changes'': '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

      /* Changes to operation_lines */
          MERGE /*+ INDEX(B OKI_DBI_REN_INC_U1) */ INTO  OKI_DBI_REN_INC b
          USING
            (SELECT  s1.cle_id
                   , s1.r_cle_id
                   , mod(rownum-1,p_no_of_workers)+1 worker_number
             FROM (SELECT  /*+ ordered index(b) use_nl(rel,opins) */
                         rel.object_cle_id cle_id
                       , MAX (rel.subject_cle_id)KEEP (DENSE_RANK LAST ORDER BY rel.last_update_date) r_cle_id
                    FROM oki_dbi_ren_inc b,
                         okc_operation_lines rel
 			             ,okc_operation_instances opins,
						 okc_class_operations clsop
						 WHERE  1 = 1
						  AND rel.oie_id=opins.id
						  AND opins.cop_id=clsop.id
						  AND clsop.cls_code='SERVICE'
						  AND clsop.opn_code in ('RENEWAL','REN_CON')
              AND b.worker_number = -99
              AND b.cle_id = rel.object_cle_id
              AND rel.object_cle_id IS NOT NULL
              AND rel.subject_cle_id IS NOT NULL
             GROUP BY rel.object_cle_id
                   ) s1
            ) s
          ON (b.cle_id = s.cle_id)
          WHEN MATCHED THEN
            UPDATE SET
                     r_cle_id      = s.r_cle_id
                  ,  worker_number = s.worker_number
          WHEN NOT MATCHED THEN
            INSERT(
                     cle_id
                   , r_cle_id
                   , worker_number
            ) VALUES (
                     s.cle_id
                   , s.r_cle_id
                   , s.worker_number
            );
          l_count := SQL%ROWCOUNT;

       rlog('Number of lines updated into OKI_DBI_REN_INC : '
                                                          ||TO_CHAR(l_count),2);
       rlog('Updation of table OKI_DBI_REN_INC due to ''Operation Lines Changes'' completed: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;
          COMMIT;
     END IF;

      /* Lines affected due to deletes */
   IF (g_del_count > 0 ) then

      rlog('Populating table OKI_DBI_REN_INC due to ''Deletes'': '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

          MERGE INTO  OKI_DBI_REN_INC b
          USING
            (SELECT   cle_id
                    , r_cle_id
                    , mod(rownum-1,p_no_of_workers)+1 worker_number
             FROM (SELECT   /*+ ordered use_nl(del,rl,opins,clsop) */
                            del.cle_id
                          , MAX(rl.subject_cle_id) KEEP (DENSE_RANK LAST
                                ORDER BY rl.last_update_date) r_cle_id
                   FROM   oki_dbi_cle_del del1
                        , oki_dbi_cle_b del
                        , okc_operation_lines rl
 			                  , okc_operation_instances opins
 			                  , okc_class_operations clsop
						      WHERE  1 = 1
                    AND rl.oie_id=opins.id
						        AND opins.cop_id=clsop.id
						        AND clsop.cls_code='SERVICE'
						        AND clsop.opn_code in ('RENEWAL','REN_CON')
	                  AND del.r_cle_id = del1.cle_id
		                AND rl.object_cle_id(+) = del.cle_id
                    AND (  (    rl.subject_cle_id IS NOT NULL
                            AND rl.object_cle_id  IS NOT NULL)
                         OR(    rl.subject_cle_id IS NULL
                            AND rl.object_cle_id  IS NULL
                            AND rl.object_chr_id  IS NULL
                            AND rl.subject_chr_id IS NULL))
                   GROUP BY del.cle_id) s1
            ) s
          ON (b.cle_id = s.cle_id)
          WHEN MATCHED THEN
            UPDATE SET
                  r_cle_id      = s.r_cle_id
                , worker_number = s.worker_number
          WHEN NOT MATCHED THEN
            INSERT(
                     cle_id
                   , r_cle_id
                   , worker_number
            ) VALUES (
                     s.cle_id
                   , s.r_cle_id
                   , s.worker_number
            );

          l_count := SQL%ROWCOUNT;
      rlog( 'Number of lines inserted into OKI_DBI_REN_INC : '
                                                          ||TO_CHAR(l_count),2);
      rlog('Load of table OKI_DBI_REN_INC due to ''Deletes'' completed: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;
      COMMIT;
 END IF;
            GATHER_TABLE_STATS( TABNAME=>'OKI_DBI_REN_INC' );


  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      RAISE;
    WHEN OTHERS THEN
      rlog('Error in populate_ren_rel: Insert into OKI_DBI_REN_INC FAILED', 0);
      rlog(sqlerrm ||'   '||sqlcode, 0);
      rlog(l_location , 0);
      fnd_message.set_name(  application => 'FND'
                           , name        => 'CRM-DEBUG ERROR' ) ;
      fnd_message.set_token(
                          token => 'ROUTINE'
                        , value => 'OKI_DBI_LOAD_CLEB_PVT.POPULATE_REN_REL' ) ;
      bis_collection_utilities.put_line(fnd_message.get) ;
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END populate_ren_rel;

/*******************************************************************************
  Procedure:   UPdate_RHS
  Description: Update the right hand side (renewal information) by copying
               the left hand side (original information).
  Parameters:
  p_worker : current worker number
  p_no_of_workers: total number of workers requested by the user
  p_recs_processed: total number of records processed by the current woker
*******************************************************************************/
  PROCEDURE Update_RHS
                      (   p_worker         IN NUMBER
                        , p_no_of_workers  IN NUMBER
                        , p_recs_processed OUT NOCOPY NUMBER
                      ) IS
  l_batch_size  NUMBER;
  l_sql_string  VARCHAR2(4000);
  l_oki_schema  VARCHAR2(30);
  l_status      VARCHAR2(30);
  l_industry    VARCHAR2(30);
  l_count       NUMBER;
  l_location   VARCHAR2(1000) ;
  l_start_date date;
  l_end_date   date;
  l_temp exception;
  l_sts_count number;

  BEGIN

      l_location := ' Updating Covered Lines in OKI_DBI_CLE_B_OLD with Renewals: ' ;

     rlog('Updating Staging Table OKI_DBI_CLE_B_OLD with renewal information : '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;
     UPDATE oki_dbi_cle_b_old b set (
            r_chr_id
          , r_cle_id
          , r_date_signed
          , r_date_cancelled
			)=
          (SELECT /*+ ordered index(ren_inc) use_nl(old) */
            chr_id
			, old.cle_id
			, date_signed
			, date_cancelled
          FROM oki_dbi_ren_inc ren_inc,
               oki_dbi_cle_b_old old
         WHERE  ren_inc.r_cle_id      = old.cle_id (+)
           AND  ren_inc.worker_number = p_worker
           AND  ren_inc.cle_id        = b.cle_id)
        WHERE EXISTS (SELECT/*+ ordered index(ren_inc) use_nl(old) */ 1
                        FROM oki_dbi_cle_b_old old,
                             oki_dbi_ren_inc ren_inc
                       WHERE  ren_inc.r_cle_id      = old.cle_id (+)
                         AND  ren_inc.worker_number = p_worker
                         AND  ren_inc.cle_id        = b.cle_id);

      p_recs_processed := SQL%ROWCOUNT ;

      rlog( 'Number of lines updated into OKI_DBI_CLE_B_OLD with renewal information is '
         || TO_CHAR(p_recs_processed),2) ;
      rlog('Updation of Staging Table OKI_DBI_CLE_B_OLD with renewal information completed: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

      COMMIT;
      EXCEPTION
         WHEN OTHERS THEN
             rlog('Error in update_RHS: ',0);
             rlog(SQLERRM ||'   '||SQLCODE, 0) ;
             rlog(l_location || ' Failed', 0) ;
             fnd_message.set_name(  application => 'FND'
                                  , name        => 'CRM-DEBUG ERROR' ) ;
             fnd_message.set_token(
                                    token => 'ROUTINE'
                                  , value => 'OKI_DBI_LOAD_CLEB_PVT.Update_RHS ' ) ;
             bis_collection_utilities.put_line(fnd_message.get) ;
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
  END update_RHS ;

/*******************************************************************************
  Procedure:   UPdate_LHS
  Description: Update the left hand side (original information) by copying
               the right hand side (renewal information).
  Parameters:  p_worker:		The worker number of the current worker that calls this procedure
               p_no_of_workers:	The total number of workers requested by the user
			   p_recs_processed:The number of records processed by the current worker
*******************************************************************************/
PROCEDURE Update_LHS(
                          p_worker         IN NUMBER
                        , p_no_of_workers  IN NUMBER
                        , p_recs_processed OUT NOCOPY NUMBER
                    )
IS

  l_sql_string  VARCHAR2(4000);
  l_count       NUMBER;
  l_location    VARCHAR2(1000);
  l_sts_count   NUMBER;

  BEGIN

      l_location := 'Updating Covered Lines in OKI_DBI_CLE_B_OLD with Original Information: ' ;

       rlog('Updating Staging Table OKI_DBI_CLE_B_OLD with original information : '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

      UPDATE oki_dbi_cle_b_old b SET
          (     p_chr_id
              , p_cle_id
              , p_price_negotiated
              , p_price_negotiated_f
              , p_price_negotiated_g
              , p_price_negotiated_sg
              , p_grace_end_date
              , p_ubt_amt
              , p_ubt_amt_f
              , p_ubt_amt_g
              , p_ubt_amt_sg
              , p_credit_amt
              , p_credit_amt_f
              , p_credit_amt_g
              , p_credit_amt_sg
              , p_override_amt
              , p_override_amt_f
              , p_override_amt_g
              , p_override_amt_sg
              , p_supp_credit
              , p_supp_credit_f
              , p_supp_credit_g
              , p_supp_credit_sg
              , p_end_date
              , p_term_flag
              , p_price_negotiated_a
              , p_ubt_amt_a
              , p_credit_amt_a
              , p_override_amt_a
              , p_supp_credit_a) =
           (SELECT /*+ ordered index(prev_inc) use_nl(cle) */
                chr_id
              , cle.cle_id
              , price_negotiated
              , price_negotiated_f
              , price_negotiated_g
              , price_negotiated_sg
              , grace_end_date
              , ubt_amt
              , ubt_amt_f
              , ubt_amt_g
              , ubt_amt_sg
              , credit_amt
              , credit_amt_f
              , credit_amt_g
              , credit_amt_sg
              , override_amt
              , override_amt_f
              , override_amt_g
              , override_amt_sg
              , supp_credit
              , supp_credit_f
              , supp_credit_g
              , supp_credit_sg
              , end_date
              , term_flag
              , price_negotiated_a
              , ubt_amt_a
              , credit_amt_a
              , override_amt_a
              , supp_credit_a
            FROM oki_dbi_prev_inc prev_inc
                ,oki_dbi_cle_b_old cle
            WHERE prev_inc.p_cle_id = cle.cle_id (+)
            AND   prev_inc.worker_number = p_worker
            AND   prev_inc.cle_id = b.cle_id)
            WHERE EXISTS (SELECT /*+ ordered index(prev_inc) use_nl(cle) */ 1
                            FROM oki_dbi_cle_b_old cle
                               , oki_dbi_prev_inc prev_inc
                           WHERE prev_inc.p_cle_id = cle.cle_id (+)
                             AND prev_inc.worker_number = p_worker
                             AND prev_inc.cle_id = b.cle_id);

      p_recs_processed := SQL%ROWCOUNT ;

      rlog( 'Number of lines updated into OKI_DBI_CLE_B_OLD with original information is '
         || TO_CHAR(p_recs_processed),2) ;
      rlog('Updation of Staging Table OKI_DBI_CLE_B_OLD with original information completed: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

      COMMIT;

EXCEPTION
      WHEN OTHERS THEN
         rlog('Error in update_LHS: Updating LHS information in OKI_DBI_CLE_B_OLD FAILED',0);
         rlog(sqlerrm ||'   '||sqlcode, 0) ;
         rlog(l_location , 0) ;
         fnd_message.set_name(  application => 'FND'
                               , name        => 'CRM-DEBUG ERROR' ) ;
         fnd_message.set_token(
                               token => 'ROUTINE'
                             , value => 'OKI_DBI_LOAD_CLEB_PVT.Update_LHS ' ) ;
         bis_collection_utilities.put_line(fnd_message.get) ;
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
END Update_LHS;

/*******************************************************************************
  Procedure:   incr_load
  Description: Load OKI_DBI_CLE_B_OLD with original, LHS and RHS information.
               Update OKI_DBI_CLE_B with this information.
  Parameters:  p_recs_processed:The number of records processed
*******************************************************************************/
PROCEDURE incr_Load ( p_recs_processed OUT NOCOPY NUMBER )
  IS
    l_login_id               NUMBER;
    l_user_id                NUMBER;
    l_request_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_id             NUMBER;
    l_program_login_id       NUMBER;
    l_run_date               DATE;
    l_count                  NUMBER;
    l_no_of_workers          NUMBER;
    l_batch_size             number;

    l_oki_schema  VARCHAR2(30) ;
    l_status      VARCHAR2(30) ;
    l_industry    VARCHAR2(30) ;
    l_sql_string  VARCHAR2(1000) ;
    l_start_date     DATE;
    l_end_date       DATE;
    l_location     VARCHAR2(1000);

BEGIN



      l_user_id                :=  FND_GLOBAL.user_id ;
      l_request_id             :=  FND_GLOBAL.conc_request_id;
      l_program_application_id :=  FND_GLOBAL.prog_appl_id;
      l_program_id             :=  FND_GLOBAL.conc_program_id;
      l_program_login_id       :=  FND_GLOBAL.conc_login_id;
      l_run_date               :=  OKI_DBI_LOAD_CLEB_PVT.g_run_date ;
      l_oki_schema             :='OKI';
      l_start_date := OKI_DBI_LOAD_CLEB_PVT.g_start_date ;
      l_end_date   := OKI_DBI_LOAD_CLEB_PVT.g_end_date ;


    /* Contracts count may be less than the no of workers. */
    l_location := 'Deriving No of workers';
    l_no_of_workers := least(CEIL(g_contracts_count/g_batch_size), g_no_of_workers);
    rlog( 'Number of workers to be started  : ' || l_no_of_workers,0);
      FOR worker_no IN 1 .. l_no_of_workers LOOP
           UPDATE oki_dbi_chr_inc
           SET worker_number = worker_no
           WHERE worker_number   = -1
           AND ROWNUM <= CEIL(g_contracts_count/l_no_of_workers);

           IF ( SQL%ROWCOUNT > 0 ) THEN
              INSERT INTO OKI_DBI_WORKER_STATUS (
                 object_name
               , worker_number
               , status
               , phase) VALUES(
                'OKI_DBI_CLE_B_OLD'
               , worker_no
               , 'UNASSIGNED'
               , 0);
          END IF;
          COMMIT;
      END LOOP;

      FOR l_phase IN 1 .. 7
      LOOP
          IF l_phase = 1 THEN
          	rlog ('Inserting modified/created contracts into OKI_DBI_CLE_B_OLD : '||fnd_date.date_to_displayDT(sysdate), 1);
          ELSIF l_phase = 2 THEN
          	rlog ('Finding new renewal relationship information Phase I : '||fnd_date.date_to_displayDT(sysdate),1);
          ELSIF l_phase = 3 THEN
          	rlog ('Finding new renewal relationship information Phase II : '||fnd_date.date_to_displayDT(sysdate),1);
          ELSIF l_phase = 4 THEN
          	rlog ('Finding new renewal relationship information Phase III : '||fnd_date.date_to_displayDT(sysdate),1);
          ELSIF l_phase = 5 THEN
          	rlog ('Inserting covered lines into OKI_DBI_CLE_B_OLD from OKI_DBI_CLE_B : '||fnd_date.date_to_displayDT(sysdate),1);
          ELSIF l_phase = 6 THEN
          	rlog ('Updating renewal information into OKI_DBI_CLE_B_OLD : '||fnd_date.date_to_displayDT(sysdate),1);
          ELSIF l_phase = 7 THEN
          	rlog ('Updating original information into OKI_DBI_CLE_B_OLD : '||fnd_date.date_to_displayDT(sysdate),1);
          END IF;
          FOR i IN 1 .. l_no_of_workers
          LOOP
            g_worker(i) := LAUNCH_WORKER( i
                                        , l_phase
                                        , l_no_of_workers);
          END LOOP;
          COMMIT;

          DECLARE
            l_unassigned_cnt       NUMBER := 0;
            l_completed_cnt        NUMBER := 0;
            l_wip_cnt              NUMBER := 0;
            l_failed_cnt           NUMBER := 0;
            l_tot_cnt              NUMBER := 0;
          BEGIN
            LOOP
              SELECT NVL(sum(decode(status,'UNASSIGNED',1,0)),0),
                     NVL(sum(decode(status,'COMPLETED',1,0)),0),
                     NVL(sum(decode(status,'IN PROCESS',1,0)),0),
                     NVL(sum(decode(status,'FAILED',1,0)),0),
                     count(*)
              INTO   l_unassigned_cnt,
                     l_completed_cnt,
                     l_wip_cnt,
                     l_failed_cnt,
                     l_tot_cnt
              FROM   OKI_DBI_WORKER_STATUS
              WHERE object_name = 'OKI_DBI_CLE_B_OLD';

              IF ( l_failed_cnt > 0 ) THEN
              	rlog('One of the sub-workers errored out..Exiting',1);
                RAISE G_CHILD_PROCESS_ISSUE;
              END IF;

              IF ( l_tot_cnt = l_completed_cnt ) THEN
                  IF l_phase = 1 THEN
                  	rlog ('Inserting modified/created contracts into OKI_DBI_CLE_B_OLD completed : '||fnd_date.date_to_displayDT(sysdate), 1);
                  ELSIF l_phase = 2 THEN
                  	rlog ('Finding new renewal relationship information Phase I completed : '||fnd_date.date_to_displayDT(sysdate),1);
                  ELSIF l_phase = 3 THEN
                  	rlog ('Finding new renewal relationship information Phase II completed : '||fnd_date.date_to_displayDT(sysdate),1);
                  ELSIF l_phase = 4 THEN
                  	rlog ('Finding new renewal relationship information Phase III completed : '||fnd_date.date_to_displayDT(sysdate),1);
                  ELSIF l_phase = 5 THEN
                  	rlog ('Inserting covered lines into OKI_DBI_CLE_B_OLD from OKI_DBI_CLE_B completed : '||fnd_date.date_to_displayDT(sysdate),1);
                  ELSIF l_phase = 6 THEN
                  	rlog ('Updating renewal information into OKI_DBI_CLE_B_OLD completed : '||fnd_date.date_to_displayDT(sysdate),1);
                  ELSIF l_phase = 7 THEN
                  	rlog ('Updating original information into OKI_DBI_CLE_B_OLD completed : '||fnd_date.date_to_displayDT(sysdate),1);
                  END IF;
                  EXIT;
              END IF;
              DBMS_LOCK.sleep(5);
            END LOOP;

        END;   -- Monitor child process Ends here.

        IF ( l_phase = 2 ) THEN

            GATHER_TABLE_STATS(TABNAME=>'OKI_DBI_PREV_INC');

			rlog('Populating table OKI_DBI_REN_INC from OKI_DBI_PREV_INC: '
					||fnd_date.date_to_displayDT(sysdate), 1) ;

			MERGE INTO  OKI_DBI_REN_INC b
            USING
                 (SELECT       rel.p_cle_id cle_id
                              , rel.cle_id   r_cle_id
                              , MOD(ROWNUM-1,l_no_of_workers)+1 worker_number
                          FROM   oki_dbi_prev_inc rel
                 )s
			ON (b.cle_id = s.cle_id)
            WHEN MATCHED THEN
       	        UPDATE SET
                     r_cle_id      =  s.r_cle_id
                   , worker_number =  s.worker_number
            WHEN NOT MATCHED THEN
                INSERT  ( cle_id
                        , r_cle_id
                        , worker_number
                         )  VALUES(
                          s.cle_id
                        , s.r_cle_id
                        , s.worker_number
                         );

			l_count := SQL%ROWCOUNT;
			rlog( 'Number of lines inserted into OKI_DBI_REN_INC : '
                                                         ||TO_CHAR(l_count),2);
			rlog('Load of table OKI_DBI_REN_INC from OKI_DBI_PREV_INC completed: '
				||fnd_date.date_to_displayDT(sysdate), 1) ;
			COMMIT;
			OKI_DBI_LOAD_CLEB_PVT.populate_ren_rel(l_no_of_workers);

		ELSIF( l_phase = 3 ) THEN

            GATHER_TABLE_STATS(TABNAME=>'OKI_DBI_PREV_INC');

        ELSIF (l_phase = 4 ) THEN

            GATHER_TABLE_STATS(TABNAME=>'OKI_DBI_PREV_INC');

            l_sql_string := 'TRUNCATE TABLE '||l_oki_schema||'.oki_dbi_Cle_del';
            EXECUTE IMMEDIATE l_sql_string;
            rlog('Truncated table OKI_DBI_CLE_DEL ',2);

			rlog('Populating table OKI_DBI_CLE_DEL from OKI_DBI_REN_INC,OKI_DBI_PREV_INC: '
					||fnd_date.date_to_displayDT(sysdate), 1) ;
            INSERT INTO OKI_DBI_CLE_DEL
                  ( cle_id
                   ,worker_number)
            (SELECT
                      cle_id
                    , worker_number
              FROM (
                    SELECT   cle_id
                           , MOD(ROWNUM-1,l_no_of_workers)+1 worker_number
                   FROM  (
                           SELECT /*+ index_ffs(OKI_DBI_REN_INC OKI_DBI_REN_INC_U1) */
						   cle_id   FROM oki_dbi_ren_inc
                           UNION
                           SELECT r_cle_id FROM oki_dbi_ren_inc
                           where r_cle_id is not null
                           UNION
                           SELECT /*+ index_ffs(OKI_DBI_PREV_INC OKI_DBI_PREV_INC_U1) */
						   cle_id   FROM oki_dbi_prev_inc
                           where cle_id is not null
                         )
                     )
             );

            COMMIT;

			rlog('Load of table OKI_DBI_CLE_DEL from OKI_DBI_REN_INC,OKI_DBI_PREV_INC completed: '
				 ||fnd_date.date_to_displayDT(sysdate), 1) ;

            GATHER_TABLE_STATS(TABNAME=>'OKI_DBI_CLE_DEL');

       END IF;

        IF ( l_phase < 7 ) THEN
          UPDATE OKI_DBI_WORKER_STATUS  SET STATUS='UNASSIGNED', phase = l_phase + 1;
        END IF;
        COMMIT;
      END LOOP;

         GATHER_TABLE_STATS(TABNAME=>'OKI_DBI_CLE_B_OLD');

		  rlog('Updating summary table OKI_DBI_CLE_B from OKI_DBI_CLE_B_OLD: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

		UPDATE
      	  (
	     SELECT /* + ordered use_nl(b) */
  	         b.chr_id                  new_chr_id
           , b.cle_creation_date       new_cle_creation_date
           , b.inv_organization_id     new_inv_organization_id
           , b.authoring_org_id        new_authoring_org_id
           , b.application_id          new_application_id
           , b.customer_party_id       new_customer_party_id
           , b.salesrep_id             new_salesrep_id
           , b.price_negotiated        new_price_negotiated
           , b.price_negotiated_f      new_price_negotiated_f
           , b.price_negotiated_g      new_price_negotiated_g
           , b.price_negotiated_sg     new_price_negotiated_sg
           , b.contract_number         new_contract_number
           , b.contract_number_modifier new_contract_number_modifier
           , b.buy_or_sell             new_buy_or_sell
           , b.scs_code                new_scs_code
           , b.sts_code                new_sts_code
           , b.trn_code                new_trn_code
           , b.root_lty_code           new_root_lty_code
           , b.renewal_flag            new_renewal_flag
           , b.date_signed             new_date_signed
           , b.date_cancelled          new_date_cancelled
           , b.hstart_date             new_hstart_date
           , b.hend_date               new_hend_date
           , b.start_date              new_start_date
           , b.end_date                new_end_date
           , b.date_terminated         new_date_terminated
           , b.effective_start_date    new_effective_start_date
           , b.effective_end_date      new_effective_end_date
           , b.trx_func_curr_rate      new_trx_func_curr_rate
           , b.func_global_curr_rate   new_func_global_curr_rate
           , b.func_sglobal_curr_rate  new_func_sglobal_curr_rate
           , b.last_update_login       new_last_update_login
           , b.last_updated_by         new_last_updated_by
           , b.last_update_date        new_last_update_date
           , b.request_id              new_request_id
           , b.program_application_id  new_program_application_id
           , b.program_id              new_program_id
           , b.program_login_id        new_program_login_id
           , b.resource_group_id       new_resource_group_id
           , b.resource_id             new_resource_id
           , b.sle_id                  new_sle_id
           , b.service_item_id         new_service_item_id
           , b.covered_item_id         new_covered_item_id
           , b.covered_item_org_id     new_covered_item_org_id
           , b.quantity                new_quantity
           , b.uom_code                new_uom_code
      	   , b.grace_end_date          new_grace_end_date
           , b.expected_close_date     new_expected_close_date
           , b.win_percent             new_win_percent
           , b.ubt_amt                 new_ubt_amt
           , b.ubt_amt_f               new_ubt_amt_f
           , b.ubt_amt_g               new_ubt_amt_g
           , b.ubt_amt_sg              new_ubt_amt_sg
           , b.credit_amt              new_credit_amt
           , b.credit_amt_f            new_credit_amt_f
           , b.credit_amt_g            new_credit_amt_g
           , b.credit_amt_sg           new_credit_amt_sg
           , b.override_amt            new_override_amt
           , b.override_amt_f          new_override_amt_f
           , b.override_amt_g          new_override_amt_g
           , b.override_amt_sg         new_override_amt_sg
           , b.supp_credit             new_supp_credit
           , b.supp_credit_f           new_supp_credit_f
           , b.supp_credit_g           new_supp_credit_g
           , b.supp_credit_sg          new_supp_credit_sg
           , b.renewal_type            new_renewal_type
           , b.term_flag               new_term_flag
           , b.r_chr_id                new_r_chr_id
           , b.r_cle_id                new_r_cle_id
           , b.r_date_signed           new_r_date_signed
           , b.r_date_cancelled        new_r_date_cancelled
           , b.annualization_factor    new_annualization_factor
           , b.p_chr_id                new_p_chr_id
           , b.p_cle_id                new_p_cle_id
           , b.p_price_negotiated      new_p_price_negotiated
           , b.p_price_negotiated_f    new_p_price_negotiated_f
           , b.p_price_negotiated_g    new_p_price_negotiated_g
           , b.p_price_negotiated_sg   new_p_price_negotiated_sg
           , b.p_grace_end_date        new_p_grace_end_date
           , b.p_ubt_amt               new_p_ubt_amt
           , b.p_ubt_amt_f             new_p_ubt_amt_f
           , b.p_ubt_amt_g             new_p_ubt_amt_g
           , b.p_ubt_amt_sg            new_p_ubt_amt_sg
           , b.p_credit_amt            new_p_credit_amt
           , b.p_credit_amt_f          new_p_credit_amt_f
           , b.p_credit_amt_g          new_p_credit_amt_g
           , b.p_credit_amt_sg         new_p_credit_amt_sg
           , b.p_override_amt          new_p_override_amt
           , b.p_override_amt_f        new_p_override_amt_f
           , b.p_override_amt_g        new_p_override_amt_g
           , b.p_override_amt_sg       new_p_override_amt_sg
           , b.p_supp_credit           new_p_supp_credit
           , b.p_supp_credit_f         new_p_supp_credit_f
           , b.p_supp_credit_g         new_p_supp_credit_g
           , b.p_supp_credit_sg        new_p_supp_credit_sg
           , b.p_end_date              new_p_end_date
           , b.p_term_flag             new_p_term_flag
           , b.price_negotiated_a      new_price_negotiated_a
           , b.ubt_amt_a               new_ubt_amt_a
           , b.credit_amt_a            new_credit_amt_a
           , b.override_amt_a          new_override_amt_a
           , b.supp_credit_a           new_supp_credit_a
           , b.p_price_negotiated_a    new_p_price_negotiated_a
           , b.p_ubt_amt_a             new_p_ubt_amt_a
           , b.p_credit_amt_a          new_p_credit_amt_a
           , b.p_override_amt_a        new_p_override_amt_a
           , b.p_supp_credit_a         new_p_supp_credit_a
           , b.gsd_flag                new_gsd_flag
           , b.falsernwlyn             new_falsernwlyn
           , b.effective_active_date   new_effective_active_date
           , b.effective_term_date     new_effective_term_date
           , b.effective_expire_date   new_effective_expire_date
           , b.termination_entry_date  new_termination_entry_date
           , b.curr_code               new_curr_code
           , b.curr_code_f             new_curr_code_f
           , b.hdr_order_number        new_hdr_order_number
           , b.hdr_sts_code            new_hdr_sts_code
           , b.hdr_trn_code            new_hdr_trn_code
           , b.hdr_renewal_type        new_hdr_renewal_type
           , b.hdr_date_approved       new_hdr_date_approved
           , b.hdr_date_cancelled      new_hdr_date_cancelled
           , b.hdr_date_terminated     new_hdr_date_terminated
           , b.hdr_creation_date       new_hdr_creation_date
           , b.hdr_last_update_date    new_hdr_last_update_date
           , b.service_item_org_id     new_service_item_org_id
           , b.sl_line_number          new_sl_line_number
           , b.sl_sts_code             new_sl_sts_code
           , b.sl_trn_code             new_sl_trn_code
           , b.sl_renewal_type         new_sl_renewal_type
           , b.sl_start_date           new_sl_start_date
           , b.sl_end_Date             new_sl_end_Date
           , b.sl_date_cancelled       new_sl_date_cancelled
           , b.sl_date_terminated      new_sl_date_terminated
           , b.sl_creation_date        new_sl_creation_date
           , b.sl_last_update_date     new_sl_last_update_date
           , b.order_number            new_order_number
           , b.unit_price_percent      new_unit_price_percent
           , b.unit_price              new_unit_price
           , b.unit_price_f            new_unit_price_f
           , b.unit_price_g            new_unit_price_g
           , b.unit_price_sg           new_unit_price_sg
           , b.list_price              new_list_price
           , b.list_price_f            new_list_price_f
           , b.list_price_g            new_list_price_g
           , b.list_price_sg           new_list_price_sg
           , b.duration_uom            new_duration_uom
           , b.duration_qty            new_duration_qty
           , b.cl_last_update_date     new_cl_last_update_date
           , b.cov_prod_id             new_cov_prod_id
           , b.cov_prod_system_id      new_cov_prod_system_id
           , b.line_number             new_line_number
           , b.line_type               new_line_type
	         , b.hdr_bill_site_id	       new_hdr_bill_site_id
	         , b.hdr_ship_site_id        new_hdr_ship_site_id
	         , b.hdr_acct_rule_id        new_hdr_acct_rule_id
	         , b.hdr_grace_end_Date      new_hdr_grace_end_Date
	         , b.hdr_date_signed         new_hdr_date_signed
	         , b.hdr_subsequent_renewal_type N_HDR_SUBSEQUENT_RENEWAL_TYPE    /* Added this colunm as a part of ER#5760744 */
	         , b.agreement_type_code     new_agreement_type_code              /* for ER 6062516 */
	         , b.agreement_name          new_agreement_name                   /* for ER 6062516 */
	         , b.negotiation_status      new_negotiation_status               /* Added this colunm as a part of ER#5950128 */
	         , b.reminder                new_reminder                         /* Added this colunm as a part of ER#5950128 */
	         , b.hdr_term_cancel_source  new_hdr_term_cancel_source           /* Added for ER 6684955 */
	         , b.sl_term_cancel_source   new_sl_term_cancel_source            /* Added for ER 6684955 */
                 , s.chr_id                  	   old_chr_id
                 , s.cle_creation_date       	   old_cle_creation_date
                 , s.inv_organization_id     	   old_inv_organization_id
                 , s.authoring_org_id        	   old_authoring_org_id
                 , s.application_id          	   old_application_id
                 , s.customer_party_id       	   old_customer_party_id
                 , s.salesrep_id             	   old_salesrep_id
                 , s.price_negotiated        	   old_price_negotiated
                 , s.price_negotiated_f      	   old_price_negotiated_f
                 , s.price_negotiated_g      	   old_price_negotiated_g
                 , s.price_negotiated_sg     	   old_price_negotiated_sg
                 , s.contract_number         	   old_contract_number
                 , s.contract_number_modifier	   old_contract_number_modifier
                 , s.buy_or_sell             	   old_buy_or_sell
                 , s.scs_code                	   old_scs_code
                 , s.sts_code                	   old_sts_code
                 , s.trn_code                	   old_trn_code
                 , s.root_lty_code           	   old_root_lty_code
                 , s.renewal_flag            	   old_renewal_flag
	               , s.date_signed             	   old_date_signed
                 , s.date_cancelled          	   old_date_cancelled
                 , s.hstart_date             	   old_hstart_date
                 , s.hend_date               	   old_hend_date
                 , s.start_date              	   old_start_date
                 , s.end_date                	   old_end_date
                 , s.date_terminated         	   old_date_terminated
                 , s.effective_start_date    	   old_effective_start_date
                 , s.effective_end_date      	   old_effective_end_date
                 , s.trx_func_curr_rate      	   old_trx_func_curr_rate
                 , s.func_global_curr_rate   	   old_func_global_curr_rate
                 , s.func_sglobal_curr_rate  	   old_func_sglobal_curr_rate
                 , s.resource_group_id       	   old_resource_group_id
                 , s.resource_id             	   old_resource_id
                 , s.sle_id                  	   old_sle_id
                 , s.service_item_id         	   old_service_item_id
                 , s.covered_item_id         	   old_covered_item_id
                 , s.covered_item_org_id     	   old_covered_item_org_id
                 , s.quantity                	   old_quantity
                 , s.uom_code                	   old_uom_code
                 , s.grace_end_date          	   old_grace_end_date
                 , s.expected_close_date     	   old_expected_close_date
                 , s.win_percent             	   old_win_percent
                 , s.ubt_amt                 	   old_ubt_amt
                 , s.ubt_amt_f               	   old_ubt_amt_f
                 , s.ubt_amt_g               	   old_ubt_amt_g
                 , s.ubt_amt_sg              	   old_ubt_amt_sg
                 , s.credit_amt              	   old_credit_amt
                 , s.credit_amt_f            	   old_credit_amt_f
                 , s.credit_amt_g            	   old_credit_amt_g
                 , s.credit_amt_sg           	   old_credit_amt_sg
                 , s.override_amt            	   old_override_amt
                 , s.override_amt_f          	   old_override_amt_f
                 , s.override_amt_g          	   old_override_amt_g
                 , s.override_amt_sg         	   old_override_amt_sg
                 , s.supp_credit             	   old_supp_credit
                 , s.supp_credit_f           	   old_supp_credit_f
                 , s.supp_credit_g           	   old_supp_credit_g
                 , s.supp_credit_sg          	   old_supp_credit_sg
                 , s.renewal_type            	   old_renewal_type
                 , s.term_flag               	   old_term_flag
                 , s.r_chr_id                	   old_r_chr_id
                 , s.r_cle_id                	   old_r_cle_id
                 , s.r_date_signed           	   old_r_date_signed
                 , s.r_date_cancelled        	   old_r_date_cancelled
                 , s.annualization_factor    	   old_annualization_factor
                 , s.p_chr_id                	   old_p_chr_id
                 , s.p_cle_id                	   old_p_cle_id
                 , s.p_price_negotiated      	   old_p_price_negotiated
                 , s.p_price_negotiated_f    	   old_p_price_negotiated_f
                 , s.p_price_negotiated_g    	   old_p_price_negotiated_g
                 , s.p_price_negotiated_sg   	   old_p_price_negotiated_sg
                 , s.p_grace_end_date        	   old_p_grace_end_date
                 , s.p_ubt_amt               	   old_p_ubt_amt
                 , s.p_ubt_amt_f             	   old_p_ubt_amt_f
                 , s.p_ubt_amt_g             	   old_p_ubt_amt_g
                 , s.p_ubt_amt_sg            	   old_p_ubt_amt_sg
                 , s.p_credit_amt            	   old_p_credit_amt
                 , s.p_credit_amt_f          	   old_p_credit_amt_f
                 , s.p_credit_amt_g          	   old_p_credit_amt_g
                 , s.p_credit_amt_sg         	   old_p_credit_amt_sg
                 , s.p_override_amt          	   old_p_override_amt
                 , s.p_override_amt_f        	   old_p_override_amt_f
                 , s.p_override_amt_g        	   old_p_override_amt_g
                 , s.p_override_amt_sg       	   old_p_override_amt_sg
                 , s.p_supp_credit           	   old_p_supp_credit
                 , s.p_supp_credit_f         	   old_p_supp_credit_f
                 , s.p_supp_credit_g         	   old_p_supp_credit_g
                 , s.p_supp_credit_sg        	   old_p_supp_credit_sg
                 , s.p_end_date              	   old_p_end_date
                 , s.p_term_flag             	   old_p_term_flag
                 , s.price_negotiated_a      	   old_price_negotiated_a
                 , s.ubt_amt_a               	   old_ubt_amt_a
                 , s.credit_amt_a            	   old_credit_amt_a
                 , s.override_amt_a          	   old_override_amt_a
                 , s.supp_credit_a           	   old_supp_credit_a
                 , s.p_price_negotiated_a    	   old_p_price_negotiated_a
                 , s.p_ubt_amt_a             	   old_p_ubt_amt_a
                 , s.p_credit_amt_a          	   old_p_credit_amt_a
                 , s.p_override_amt_a        	   old_p_override_amt_a
                 , s.p_supp_credit_a         	   old_p_supp_credit_a
                 , s.gsd_flag                	   old_gsd_flag
                 , s.falsernwlyn             	   old_falsernwlyn
                 , s.effective_active_date   	   old_effective_active_date
                 , s.effective_term_date     	   old_effective_term_date
                 , s.effective_expire_date   	   old_effective_expire_date
                 , s.termination_entry_date  	   old_termination_entry_date
                 , s.curr_code               	   old_curr_code
                 , s.curr_code_f             	   old_curr_code_f
                 , s.hdr_order_number        	   old_hdr_order_number
                 , s.hdr_sts_code            	   old_hdr_sts_code
                 , s.hdr_trn_code            	   old_hdr_trn_code
                 , s.hdr_renewal_type        	   old_hdr_renewal_type
                 , s.hdr_date_approved       	   old_hdr_date_approved
                 , s.hdr_date_cancelled      	   old_hdr_date_cancelled
                 , s.hdr_date_terminated     	   old_hdr_date_terminated
                 , s.hdr_creation_date       	   old_hdr_creation_date
                 , s.hdr_last_update_date    	   old_hdr_last_update_date
                 , s.service_item_org_id     	   old_service_item_org_id
                 , s.sl_line_number          	   old_sl_line_number
                 , s.sl_sts_code             	   old_sl_sts_code
                 , s.sl_trn_code             	   old_sl_trn_code
                 , s.sl_renewal_type         	   old_sl_renewal_type
                 , s.sl_start_date           	   old_sl_start_date
                 , s.sl_end_Date             	   old_sl_end_Date
                 , s.sl_date_cancelled       	   old_sl_date_cancelled
                 , s.sl_date_terminated      	   old_sl_date_terminated
                 , s.sl_creation_date        	   old_sl_creation_date
                 , s.sl_last_update_date     	   old_sl_last_update_date
                 , s.order_number            	   old_order_number
                 , s.unit_price_percent      	   old_unit_price_percent
                 , s.unit_price              	   old_unit_price
                 , s.unit_price_f            	   old_unit_price_f
                 , s.unit_price_g            	   old_unit_price_g
                 , s.unit_price_sg           	   old_unit_price_sg
                 , s.list_price              	   old_list_price
                 , s.list_price_f            	   old_list_price_f
                 , s.list_price_g            	   old_list_price_g
                 , s.list_price_sg           	   old_list_price_sg
                 , s.duration_uom            	   old_duration_uom
                 , s.duration_qty            	   old_duration_qty
                 , s.cl_last_update_date   	   old_cl_last_update_date
                 , s.cov_prod_id             	   old_cov_prod_id
                 , s.cov_prod_system_id      	   old_cov_prod_system_id
                 , s.line_number             	   old_line_number
                 , s.line_type               	   old_line_type
                 , s.hdr_bill_site_id        	   old_hdr_bill_site_id
                 , s.hdr_ship_site_id        	   old_hdr_ship_site_id
                 , s.hdr_acct_rule_id        	   old_hdr_acct_rule_id
                 , s.hdr_grace_end_date		         old_hdr_grace_end_date
                 , s.hdr_date_signed   		         old_hdr_date_signed
		             , s.hdr_subsequent_renewal_type   o_hdr_subsequent_renewal_type	/* Added this colunm as a part of ER#5760744 */
		             , s.agreement_type_code           old_agreement_type_code              /* Added for ER 6062516 */
                 , s.agreement_name                old_agreement_name                   /* Added for ER 6062516 */
		             , s.negotiation_status            old_negotiation_status               /* Added this colunm as a part of ER#5950128 */
		             , s.reminder                      old_reminder                         /* Added this colunm as a part of ER#5950128 */
                 , s.hdr_term_cancel_source        old_hdr_term_cancel_source           /* Added for ER 6684955 */
	               , s.sl_term_cancel_source         old_sl_term_cancel_source            /* Added for ER 6684955 */

             FROM  OKI_DBI_CLE_B_OLD S ,
			             OKI_DBI_CLE_B B
		     WHERE B.CLE_ID = S.CLE_ID )
	SET
	new_chr_id                        = old_chr_id,
	new_cle_creation_date             = old_cle_creation_date           ,
	new_inv_organization_id           = old_inv_organization_id         ,
	new_authoring_org_id              = old_authoring_org_id            ,
	new_application_id                = old_application_id              ,
	new_customer_party_id             = old_customer_party_id           ,
	new_salesrep_id                   = old_salesrep_id                 ,
	new_price_negotiated              = old_price_negotiated            ,
	new_price_negotiated_f            = old_price_negotiated_f          ,
	new_price_negotiated_g            = old_price_negotiated_g          ,
	new_price_negotiated_sg           = old_price_negotiated_sg         ,
	new_contract_number               = old_contract_number             ,
	new_contract_number_modifier      = old_contract_number_modifier    ,
	new_buy_or_sell                   = old_buy_or_sell                 ,
	new_scs_code                      = old_scs_code                    ,
	new_sts_code                      = old_sts_code                    ,
	new_trn_code                      = old_trn_code                    ,
	new_root_lty_code                 = old_root_lty_code               ,
	new_renewal_flag                  = old_renewal_flag                ,
	new_date_signed                   = old_date_signed                 ,
	new_date_cancelled                = old_date_cancelled              ,
	new_hstart_date                   = old_hstart_date                 ,
	new_hend_date                     = old_hend_date                   ,
	new_start_date                    = old_start_date                  ,
	new_end_date                      = old_end_date                    ,
	new_date_terminated               = old_date_terminated             ,
	new_effective_start_date          = old_effective_start_date        ,
	new_effective_end_date            = old_effective_end_date          ,
	new_trx_func_curr_rate            = old_trx_func_curr_rate          ,
	new_func_global_curr_rate         = old_func_global_curr_rate       ,
	new_func_sglobal_curr_rate        = old_func_sglobal_curr_rate      ,
	new_last_update_login             = l_login_id                      ,
	new_last_updated_by               = l_user_id                       ,
	new_last_update_date              = l_run_date                      ,
	new_request_id                    = l_request_id                    ,
	new_program_application_id        = l_program_application_id        ,
	new_program_id                    = l_program_id                    ,
	new_program_login_id              = l_program_login_id              ,
	new_resource_group_id             = old_resource_group_id           ,
	new_resource_id                   = old_resource_id                 ,
	new_sle_id                        = old_sle_id                      ,
	new_service_item_id               = old_service_item_id             ,
	new_covered_item_id               = old_covered_item_id             ,
	new_covered_item_org_id           = old_covered_item_org_id         ,
	new_quantity                      = old_quantity                    ,
	new_uom_code                      = old_uom_code                    ,
	new_grace_end_date                = old_grace_end_date              ,
	new_expected_close_date           = old_expected_close_date         ,
	new_win_percent                   = old_win_percent                 ,
	new_ubt_amt                       = old_ubt_amt                     ,
	new_ubt_amt_f                     = old_ubt_amt_f                   ,
	new_ubt_amt_g                     = old_ubt_amt_g                   ,
	new_ubt_amt_sg                    = old_ubt_amt_sg                  ,
	new_credit_amt                    = old_credit_amt                  ,
	new_credit_amt_f                  = old_credit_amt_f                ,
	new_credit_amt_g                  = old_credit_amt_g                ,
	new_credit_amt_sg                 = old_credit_amt_sg               ,
	new_override_amt                  = old_override_amt                ,
	new_override_amt_f                = old_override_amt_f              ,
	new_override_amt_g                = old_override_amt_g              ,
	new_override_amt_sg               = old_override_amt_sg             ,
	new_supp_credit                   = old_supp_credit                 ,
	new_supp_credit_f                 = old_supp_credit_f               ,
	new_supp_credit_g                 = old_supp_credit_g               ,
	new_supp_credit_sg                = old_supp_credit_sg              ,
	new_renewal_type                  = old_renewal_type                ,
	new_term_flag                     = old_term_flag                   ,
	new_r_chr_id                      = old_r_chr_id                    ,
	new_r_cle_id                      = old_r_cle_id                    ,
	new_r_date_signed                 = old_r_date_signed               ,
	new_r_date_cancelled              = old_r_date_cancelled            ,
	new_annualization_factor          = old_annualization_factor        ,
	new_p_chr_id                      = old_p_chr_id                    ,
	new_p_cle_id                      = old_p_cle_id                    ,
	new_p_price_negotiated            = old_p_price_negotiated          ,
	new_p_price_negotiated_f          = old_p_price_negotiated_f        ,
	new_p_price_negotiated_g          = old_p_price_negotiated_g        ,
	new_p_price_negotiated_sg         = old_p_price_negotiated_sg       ,
	new_p_grace_end_date              = old_p_grace_end_date            ,
	new_p_ubt_amt                     = old_p_ubt_amt                   ,
	new_p_ubt_amt_f                   = old_p_ubt_amt_f                 ,
	new_p_ubt_amt_g                   = old_p_ubt_amt_g                 ,
	new_p_ubt_amt_sg                  = old_p_ubt_amt_sg                ,
	new_p_credit_amt                  = old_p_credit_amt                ,
	new_p_credit_amt_f                = old_p_credit_amt_f              ,
	new_p_credit_amt_g                = old_p_credit_amt_g              ,
	new_p_credit_amt_sg               = old_p_credit_amt_sg             ,
	new_p_override_amt                = old_p_override_amt              ,
	new_p_override_amt_f              = old_p_override_amt_f            ,
	new_p_override_amt_g              = old_p_override_amt_g            ,
	new_p_override_amt_sg             = old_p_override_amt_sg           ,
	new_p_supp_credit                 = old_p_supp_credit               ,
	new_p_supp_credit_f               = old_p_supp_credit_f             ,
	new_p_supp_credit_g               = old_p_supp_credit_g             ,
	new_p_supp_credit_sg              = old_p_supp_credit_sg            ,
	new_p_end_date                    = old_p_end_date                  ,
	new_p_term_flag                   = old_p_term_flag                 ,
	new_price_negotiated_a            = old_price_negotiated_a          ,
	new_ubt_amt_a                     = old_ubt_amt_a                   ,
	new_credit_amt_a                  = old_credit_amt_a                ,
	new_override_amt_a                = old_override_amt_a              ,
	new_supp_credit_a                 = old_supp_credit_a               ,
	new_p_price_negotiated_a          = old_p_price_negotiated_a        ,
	new_p_ubt_amt_a                   = old_p_ubt_amt_a                 ,
	new_p_credit_amt_a                = old_p_credit_amt_a              ,
	new_p_override_amt_a              = old_p_override_amt_a            ,
	new_p_supp_credit_a               = old_p_supp_credit_a             ,
	new_gsd_flag                      = old_gsd_flag                    ,
	new_falsernwlyn                   = old_falsernwlyn                 ,
	new_effective_active_date         = old_effective_active_date       ,
	new_effective_term_date           = old_effective_term_date         ,
	new_effective_expire_date         = old_effective_expire_date       ,
	new_termination_entry_date        = old_termination_entry_date      ,
	new_curr_code                     = old_curr_code                   ,
	new_curr_code_f                   = old_curr_code_f                 ,
	new_hdr_order_number              = old_hdr_order_number            ,
	new_hdr_sts_code                  = old_hdr_sts_code                ,
	new_hdr_trn_code                  = old_hdr_trn_code                ,
	new_hdr_renewal_type              = old_hdr_renewal_type            ,
	new_hdr_date_approved             = old_hdr_date_approved           ,
	new_hdr_date_cancelled            = old_hdr_date_cancelled          ,
	new_hdr_date_terminated           = old_hdr_date_terminated         ,
	new_hdr_creation_date             = old_hdr_creation_date           ,
	new_hdr_last_update_date          = old_hdr_last_update_date        ,
	new_service_item_org_id           = old_service_item_org_id         ,
	new_sl_line_number                = old_sl_line_number              ,
	new_sl_sts_code                   = old_sl_sts_code                 ,
	new_sl_trn_code                   = old_sl_trn_code                 ,
	new_sl_renewal_type               = old_sl_renewal_type             ,
	new_sl_start_date                 = old_sl_start_date               ,
	new_sl_end_Date                   = old_sl_end_Date                 ,
	new_sl_date_cancelled             = old_sl_date_cancelled           ,
	new_sl_date_terminated            = old_sl_date_terminated          ,
	new_sl_creation_date              = old_sl_creation_date            ,
	new_sl_last_update_date           = old_sl_last_update_date         ,
	new_order_number                  = old_order_number                ,
	new_unit_price_percent            = old_unit_price_percent          ,
	new_unit_price                    = old_unit_price                  ,
	new_unit_price_f                  = old_unit_price_f                ,
	new_unit_price_g                  = old_unit_price_g                ,
	new_unit_price_sg                 = old_unit_price_sg               ,
	new_list_price                    = old_list_price                  ,
	new_list_price_f                  = old_list_price_f                ,
	new_list_price_g                  = old_list_price_g                ,
	new_list_price_sg                 = old_list_price_sg               ,
	new_duration_uom                  = old_duration_uom                ,
	new_duration_qty                  = old_duration_qty                ,
	new_cl_last_update_date           = old_cl_last_update_date         ,
	new_cov_prod_id                   = old_cov_prod_id                 ,
	new_cov_prod_system_id            = old_cov_prod_system_id          ,
	new_line_number                   = old_line_number                 ,
	new_line_type                     = old_line_type                   ,
	new_hdr_bill_site_id		          = old_hdr_bill_site_id            ,
	new_hdr_ship_site_id              = old_hdr_ship_site_id            ,
	new_hdr_acct_rule_id              = old_hdr_acct_rule_id            ,
	new_hdr_grace_end_Date            = old_hdr_grace_end_date          ,
	new_hdr_date_signed               = old_hdr_date_signed	            ,
	n_hdr_subsequent_renewal_type     =  o_hdr_subsequent_renewal_type  ,		/* Added this colunm as a part of ER#5760744 */
	new_agreement_type_code           = old_agreement_type_code         ,   /* for ER 6062516 */
	new_agreement_name                = old_agreement_name              ,   /* for ER 6062516 */
	new_negotiation_status            = old_negotiation_status          ,   /* Added this colunm as a part of ER#5950128 */
	new_reminder                      = old_reminder                    ,   /* Added this colunm as a part of ER#5950128 */
  new_hdr_term_cancel_source        = old_hdr_term_cancel_source      ,     /* Added for ER 6684955 */       /* Added for ER 6684955 */
  new_sl_term_cancel_source         = old_sl_term_cancel_source;           /* Added for ER 6684955 */ /* Added for ER 6684955 */


		  l_count := SQL%ROWCOUNT;

          rlog('Number of lines updated into OKI_DBI_CLE_B : '|| l_count,2);
          COMMIT ;

		  INSERT INTO OKI_DBI_CLE_B
          (
			       chr_id
           , cle_id
           , cle_creation_date
           , inv_organization_id
           , authoring_org_id
           , application_id
           , customer_party_id
           , salesrep_id
           , price_negotiated
           , price_negotiated_f
           , price_negotiated_g
           , price_negotiated_sg
           , contract_number
           , contract_number_modifier
           , buy_or_sell
           , scs_code
           , sts_code
           , trn_code
           , root_lty_code
           , renewal_flag
           , date_signed
           , date_cancelled
           , hstart_date
           , hend_date
           , start_date
           , end_date
           , date_terminated
           , effective_start_date
           , effective_end_date
           , trx_func_curr_rate
           , func_global_curr_rate
           , func_sglobal_curr_rate
           , created_by
           , last_update_login
           , creation_date
           , last_updated_by
           , last_update_date
           , request_id
           , program_application_id
           , program_id
           , program_login_id
           , resource_group_id
           , resource_id
           , sle_id
           , service_item_id
           , covered_item_id
           , covered_item_org_id
           , quantity
           , uom_code
           , grace_end_date
           , expected_close_date
           , win_percent
           , ubt_amt
           , ubt_amt_f
           , ubt_amt_g
           , ubt_amt_sg
           , credit_amt
           , credit_amt_f
           , credit_amt_g
           , credit_amt_sg
           , override_amt
           , override_amt_f
           , override_amt_g
           , override_amt_sg
           , supp_credit
           , supp_credit_f
           , supp_credit_g
           , supp_credit_sg
           , renewal_type
           , term_flag
           , r_chr_id
           , r_cle_id
           , r_date_signed
           , r_date_cancelled
           , annualization_factor
           , p_chr_id
           , p_cle_id
           , p_price_negotiated
           , p_price_negotiated_f
           , p_price_negotiated_g
           , p_price_negotiated_sg
           , p_grace_end_date
           , p_ubt_amt
           , p_ubt_amt_f
           , p_ubt_amt_g
           , p_ubt_amt_sg
           , p_credit_amt
           , p_credit_amt_f
           , p_credit_amt_g
           , p_credit_amt_sg
           , p_override_amt
           , p_override_amt_f
           , p_override_amt_g
           , p_override_amt_sg
           , p_supp_credit
           , p_supp_credit_f
           , p_supp_credit_g
           , p_supp_credit_sg
           , p_end_date
           , p_term_flag
           , price_negotiated_a
           , ubt_amt_a
           , credit_amt_a
           , override_amt_a
           , supp_credit_a
           , p_price_negotiated_a
           , p_ubt_amt_a
           , p_credit_amt_a
           , p_override_amt_a
           , p_supp_credit_a
           , gsd_flag
	         , falsernwlyn
           , effective_active_date
           , effective_term_date
           , effective_expire_date
           , termination_entry_date
           , curr_code
           , curr_code_f
           , hdr_order_number
           , hdr_sts_code
           , hdr_trn_code
           , hdr_renewal_type
           , hdr_date_approved
           , hdr_date_cancelled
           , hdr_date_terminated
           , hdr_creation_date
           , hdr_last_update_date
           , service_item_org_id
           , sl_line_number
           , sl_sts_code
           , sl_trn_code
           , sl_renewal_type
           , sl_start_date
           , sl_end_Date
           , sl_date_cancelled
           , sl_date_terminated
           , sl_creation_date
           , sl_last_update_date
           , order_number
           , unit_price_percent
           , unit_price
           , unit_price_f
           , unit_price_g
           , unit_price_sg
           , list_price
           , list_price_f
           , list_price_g
           , list_price_sg
           , duration_uom
           , duration_qty
           , cl_last_update_date
           , cov_prod_id
           , cov_prod_system_id
           , line_number
           , line_type
	         , hdr_bill_site_id
	         , hdr_ship_site_id
	         , hdr_acct_rule_id
	         , hdr_grace_end_date
           , hdr_date_signed
	         , hdr_subsequent_renewal_type    /* Added this colunm as a part of ER#5760744 */
	         , agreement_type_code            /* for ER 6062516 */
	         , agreement_name                 /* for ER 6062516 */
	         , negotiation_status             /* Added this colunm as a part of ER#5950128 */
	         , reminder                       /* Added this colunm as a part of ER#5950128 */
	         , hdr_term_cancel_source         /* Added for ER 6684955 */
	         , sl_term_cancel_source          /* Added for ER 6684955 */
          )
         ( SELECT
             s.chr_id
           , s.cle_id
           , s.cle_creation_date
           , s.inv_organization_id
           , s.authoring_org_id
           , s.application_id
           , s.customer_party_id
           , s.salesrep_id
           , s.price_negotiated
           , s.price_negotiated_f
           , s.price_negotiated_g
           , s.price_negotiated_sg
           , s.contract_number
           , s.contract_number_modifier
           , s.buy_or_sell
           , s.scs_code
           , s.sts_code
           , s.trn_code
           , s.root_lty_code
           , s.renewal_flag
           , s.date_signed
           , s.date_cancelled
           , s.hstart_date
           , s.hend_date
           , s.start_date
           , s.end_date
           , s.date_terminated
           , s.effective_start_date
           , s.effective_end_date
           , s.trx_func_curr_rate
           , s.func_global_curr_rate
           , s.func_sglobal_curr_rate
           , s.created_by
           , l_login_id
           , s.creation_date
           , l_user_id
           , l_run_date
           , l_request_id
           , l_program_application_id
           , l_program_id
           , l_program_login_id
           , s.resource_group_id
           , s.resource_id
           , s.sle_id
           , s.service_item_id
           , s.covered_item_id
           , s.covered_item_org_id
           , s.quantity
           , s.uom_code
           , s.grace_end_date
           , s.expected_close_date
           , s.win_percent
           , s.ubt_amt
           , s.ubt_amt_f
           , s.ubt_amt_g
           , s.ubt_amt_sg
           , s.credit_amt
           , s.credit_amt_f
           , s.credit_amt_g
           , s.credit_amt_sg
           , s.override_amt
           , s.override_amt_f
           , s.override_amt_g
           , s.override_amt_sg
           , s.supp_credit
           , s.supp_credit_f
           , s.supp_credit_g
           , s.supp_credit_sg
           , s.renewal_type
           , s.term_flag
           , s.r_chr_id
           , s.r_cle_id
           , s.r_date_signed
           , s.r_date_cancelled
           , s.annualization_factor
           , s.p_chr_id
           , s.p_cle_id
           , s.p_price_negotiated
           , s.p_price_negotiated_f
           , s.p_price_negotiated_g
           , s.p_price_negotiated_sg
           , s.p_grace_end_date
           , s.p_ubt_amt
           , s.p_ubt_amt_f
           , s.p_ubt_amt_g
           , s.p_ubt_amt_sg
           , s.p_credit_amt
           , s.p_credit_amt_f
           , s.p_credit_amt_g
           , s.p_credit_amt_sg
           , s.p_override_amt
           , s.p_override_amt_f
           , s.p_override_amt_g
           , s.p_override_amt_sg
           , s.p_supp_credit
           , s.p_supp_credit_f
           , s.p_supp_credit_g
           , s.p_supp_credit_sg
           , s.p_end_date
           , s.p_term_flag
           , s.price_negotiated_a
           , s.ubt_amt_a
           , s.credit_amt_a
           , s.override_amt_a
           , s.supp_credit_a
           , s.p_price_negotiated_a
           , s.p_ubt_amt_a
           , s.p_credit_amt_a
           , s.p_override_amt_a
           , s.p_supp_credit_a
           , s.gsd_flag
	         , s.falsernwlyn
           , s.effective_active_date
           , s.effective_term_date
           , s.effective_expire_date
           , s.termination_entry_date
           , s.curr_code
           , s.curr_code_f
           , s.hdr_order_number
           , s.hdr_sts_code
           , s.hdr_trn_code
           , s.hdr_renewal_type
           , s.hdr_date_approved
           , s.hdr_date_cancelled
           , s.hdr_date_terminated
           , s.hdr_creation_date
           , s.hdr_last_update_date
           , s.service_item_org_id
           , s.sl_line_number
           , s.sl_sts_code
           , s.sl_trn_code
           , s.sl_renewal_type
           , s.sl_start_date
           , s.sl_end_Date
           , s.sl_date_cancelled
           , s.sl_date_terminated
           , s.sl_creation_date
           , s.sl_last_update_date
           , s.order_number
           , s.unit_price_percent
           , s.unit_price
           , s.unit_price_f
           , s.unit_price_g
           , s.unit_price_sg
           , s.list_price
           , s.list_price_f
           , s.list_price_g
           , s.list_price_sg
           , s.duration_uom
           , s.duration_qty
           , s.cl_last_update_date
           , s.cov_prod_id
           , s.cov_prod_system_id
           , s.line_number
           , s.line_type
	         , s.hdr_bill_site_id
	         , s.hdr_ship_site_id
	         , s.hdr_acct_rule_id
	         , s.hdr_grace_end_date
           , s.hdr_date_signed
	         , s.hdr_subsequent_renewal_type  /* for ER#5760744 */
	         , s.agreement_type_code          /* for ER 6062516 */
	         , s.agreement_name               /* for ER 6062516 */
	         , s.negotiation_status           /* Added this colunm as a part of ER#5950128 */
	         , s.reminder                     /* Added this colunm as a part of ER#5950128 */
	         , s.hdr_term_cancel_source       /* Added for ER 6684955 */
	         , s.sl_term_cancel_source        /* Added for ER 6684955 */
          FROM oki_dbi_cle_b_old s
          WHERE NOT EXISTS( SELECT NULL
                        FROM oki_dbi_cle_b b
                       WHERE b.cle_id = s.cle_id ) );
      p_recs_processed := SQL%ROWCOUNT;

      rlog('Number of lines inserted into OKI_DBI_CLE_B : '|| p_recs_processed,2);
      p_recs_processed := l_count + p_recs_processed;
      COMMIT ;

      rlog('Updation of summary table OKI_DBI_CLE_B from OKI_DBI_CLE_B_OLD completed: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

EXCEPTION
   	  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         RAISE;
      WHEN OTHERS THEN
         rlog (sqlerrm || ' ' || sqlcode,0);
         bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
         fnd_message.set_name(  application => 'FND'
                              , name        => 'CRM-DEBUG ERROR' ) ;
         fnd_message.set_token(
                      token => 'ROUTINE'
                    , value => 'OKI_DBI_LOAD_CLEB_PVT.INCR_LOAD' ) ;
         bis_collection_utilities.put_line(fnd_message.get) ;
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
END incr_load;

/* *****************************************************************************
   Procedure   : direct_load
   Description : Procedure to insert covered lines and renewal relationships
   Parameters  : p_recs_processed:The number of records processed
   ************************************************************************** */
  PROCEDURE direct_load
  (  p_recs_processed OUT NOCOPY NUMBER
  ) IS
    l_login_id   NUMBER;
    l_user_id    NUMBER;
    l_request_id NUMBER;
    l_program_application_id NUMBER;
    l_program_id NUMBER;
    l_program_login_id  NUMBER;

    l_annu_curr_code VARCHAR2(20);

    l_start_date DATE ;
    l_end_date   DATE ;
    l_run_date   DATE ;
    l_dop        NUMBER;
    l_location   VARCHAR2(1000);
    l_sysdate    DATE;

    l_sql_string  VARCHAR2(1000) ;
    l_count       NUMBER ;

    l_oki_schema       VARCHAR2(30) ;
    l_status           VARCHAR2(30) ;
    l_industry         VARCHAR2(30) ;
    l_salesperson_code VARCHAR2(80) ;
    l_glob_curr_code VARCHAR2(20);
    l_sglob_curr_code VARCHAR2(20);
    l_renewal_logic VARCHAR2(10);
    l_balance_logic VARCHAR2(10);
	l_service_code number;
	l_warranty_code number;
	l_ext_warr_code number;

  BEGIN



    l_login_id   := FND_GLOBAL.login_id ;
    l_user_id    := FND_GLOBAL.user_id ;
    l_request_id :=  fnd_global.CONC_REQUEST_ID;
    l_program_application_id :=  fnd_global.PROG_APPL_ID;
    l_program_id :=  fnd_global.CONC_PROGRAM_ID;
    l_program_login_id :=  fnd_global.conc_login_id;

    l_sysdate    := OKI_DBI_LOAD_CLEB_PVT.g_run_date ;
    l_annu_curr_code := bis_common_parameters. get_annualized_currency_code;
    l_glob_curr_code := 'PRIMARY';/* BUg 4015406 bis_common_parameters.get_currency_code; */
    l_sglob_curr_code := 'SECONDARY';/*bis_common_parameters.get_secondary_currency_code;*/

    l_start_date := OKI_DBI_LOAD_CLEB_PVT.g_start_date ;
    l_end_date   := OKI_DBI_LOAD_CLEB_PVT.g_end_date ;
    l_run_date   := OKI_DBI_LOAD_CLEB_PVT.g_run_date ;
    l_dop        := 1 ;

    l_salesperson_code := fnd_profile.value('OKS_ENABLE_SALES_CREDIT');
    IF l_salesperson_code IN ('YES', 'DRT') THEN	/* Added 'DRT' filter condition, Please refer Bug#5978601 */
      l_salesperson_code := fnd_profile.value('OKS_VENDOR_CONTACT_ROLE');
    ELSE
      l_salesperson_code := 'SALESPERSON';
    END IF ;

    l_location := 'Insert Covered Lines ';

	-- Lesters Feedback 5/19/04 force parallel qry

    EXECUTE IMMEDIATE 'alter session force parallel query';

    rlog('Populating Staging Table OKI_DBI_CLE_B_OLD -    ' ||fnd_date.date_to_displayDT(sysdate),1) ;
	/* Balance logic for OI */
	 l_balance_logic := nvl(fnd_profile.value('OKI_BAL_IDENT'),'CONTRDATE');
	/* Renewal logic for OI */
    l_renewal_logic := nvl(fnd_profile.value('OKI_REN_IDENT'),'STANDARD');

	rlog( 'Profile value for balance logic is '|| l_balance_logic , 2 );
	rlog( 'Profile value for renewal logic is '|| l_renewal_logic , 2 );



SELECT Max(service_code),Max(warranty_code),Max(ext_warr_code)
INTO l_service_code,l_warranty_code,l_ext_warr_code
FROM
(
SELECT
Decode(lty_code,'SERVICE',Id) service_code,
Decode(lty_code,'WARRANTY',Id) warranty_code,
Decode(lty_code,'EXT_WARRANTY',Id) ext_warr_code
FROM okc_line_styles_b
WHERE lty_code IN ('SERVICE','WARRANTY','EXT_WARRANTY')
AND lse_parent_id IS NULL
);

   /* Effective_expire_date is populated only if the date signed is not null. Prior to 8.0,
	  there was no scenario wherein a renewal could exist without thhe original contract was signed and so
      the expirations mv used r_date_signed and r_date_cancelled internally to ensure that date signed
	  was present. Because of transfers scenarios in R12, a renewal relationship can exist without the original
	  contract being signed and hence, to avoid unsigned contracts showing up in expirations, effective_expire_date
	  is populated only when date signed is not null */

--++++++++++++++++++++++
    INSERT /*+ append parallel(old) */ into oki_dbi_cle_b_old old
         (   chr_id
             ,cle_id
             ,cle_creation_date
             ,inv_organization_id
             ,authoring_org_id
             ,application_id
             ,customer_party_id
             ,resource_group_id
             ,resource_id
             ,salesrep_id
             ,price_negotiated
             ,price_negotiated_f
             ,price_negotiated_g
             ,price_negotiated_sg
             ,contract_number
             ,contract_number_modifier
             ,buy_or_sell
             ,scs_code
             ,sts_code
             ,trn_code
             ,root_lty_code
             ,renewal_flag
             ,date_signed
             ,date_cancelled
             ,hstart_date
             ,hend_date
             ,start_date
             ,end_date
             ,date_terminated
             ,effective_start_date
             ,effective_end_date
             ,trx_func_curr_rate
             ,func_global_curr_rate
             ,func_sglobal_curr_rate
             ,sle_id
             ,service_item_id
             ,covered_item_id
             ,covered_item_org_id
             ,quantity
             ,uom_code
             ,grace_end_date
             ,expected_close_date
             ,win_percent
             ,ubt_amt
             ,ubt_amt_f
             ,ubt_amt_g
             ,ubt_amt_sg
             ,credit_amt
             ,credit_amt_f
             ,credit_amt_g
             ,credit_amt_sg
             ,override_amt
             ,override_amt_f
             ,override_amt_g
             ,override_amt_sg
             ,supp_credit
             ,supp_credit_f
             ,supp_credit_g
             ,supp_credit_sg
             ,renewal_type
             ,term_flag
             ,annualization_factor
             ,ubt_amt_a
             ,credit_amt_a
             ,override_amt_a
             ,supp_credit_a
             ,price_negotiated_a
             ,created_by
             ,creation_date
             ,last_update_date
             ,gsd_flag
              -- add the four extra columns
             , effective_active_date
             , effective_term_date
             , effective_expire_date
             , termination_entry_date
             , falsernwlyn
             ,curr_code
             ,curr_code_f
             ,hdr_order_number
             ,hdr_sts_code
             ,hdr_trn_code
             ,hdr_renewal_type
             ,hdr_date_approved
	           ,hdr_date_cancelled
             ,hdr_date_terminated
             ,hdr_creation_date
             ,hdr_last_update_date
             ,service_item_org_id
             ,sl_line_number
             ,sl_sts_code
             ,sl_trn_code
             ,sl_renewal_type
             ,sl_start_date
             ,sl_end_Date
	           ,sl_date_cancelled
             ,sl_date_terminated
             ,sl_creation_date
             ,sl_last_update_date
             ,order_number
             ,unit_price_percent
             ,unit_price
             ,unit_price_f
             ,unit_price_g
             ,unit_price_sg
             ,list_price
             ,list_price_f
             ,list_price_g
             ,list_price_sg
             ,duration_uom
             ,duration_qty
             ,cl_last_update_date
             ,cov_prod_id
             ,cov_prod_system_id
             ,line_number
             ,line_type
	           ,hdr_bill_site_id
	           ,hdr_ship_site_id
	           ,hdr_acct_rule_id
	           ,hdr_grace_end_date
	           ,hdr_date_signed
	           ,p_cle_id
	           ,r_cle_id
	           ,hdr_subsequent_renewal_type  /* for ER#5760744 */
	           ,agreement_type_code          /* for ER 6062516 */
	           ,agreement_name               /* for ER 6062516 */
	     			 ,negotiation_status   /* for ER#5950128 */
	           ,reminder       /* for ER#5950128 */
	           ,HDR_TERM_CANCEL_SOURCE   /* Added as part of ER 6684955 */
	           ,SL_TERM_CANCEL_SOURCE    /* Added as part of ER 6684955 */
          )
         ( SELECT  chr_id
             ,cle_id
             ,cle_creation_date
             ,inv_organization_id
             ,authoring_org_id
             ,application_id
             ,customer_party_id
             ,resource_group_id
             ,resource_id
             ,salesrep_id
             ,price_negotiated
             ,price_negotiated_f
             ,price_negotiated_g
             ,price_negotiated_sg
             ,contract_number
             ,contract_number_modifier
             ,buy_or_sell
             ,scs_code
             ,sts_code
             ,trn_code
             ,root_lty_code
             ,renewal_flag
             ,date_signed
	           ,date_cancelled
             ,hstart_date
             ,hend_date
             ,start_date
             ,end_date
             ,date_terminated
             ,effective_start_date
             ,effective_end_date
             ,trx_func_curr_rate
             ,func_global_curr_rate
             ,func_sglobal_curr_rate
             ,sle_id
             ,service_item_id
             ,covered_item_id
             ,covered_item_org_id
             ,quantity
             ,uom_code
             ,grace_end_date
             ,expected_close_date
             ,win_percent
             ,ubt_amt
             ,ubt_amt_f
             ,ubt_amt_g
             ,ubt_amt_sg
             ,credit_amt
             ,credit_amt_f
             ,credit_amt_g
             ,credit_amt_sg
             ,override_amt
             ,override_amt_f
             ,override_amt_g
             ,override_amt_sg
             ,supp_credit
             ,supp_credit_f
             ,supp_credit_g
             ,supp_credit_sg
             ,renewal_type
             ,term_flag
             ,annualization_factor
             ,DECODE(l_annu_curr_code, l_glob_curr_code, ubt_amt_g
                                     , l_sglob_curr_code, ubt_amt_sg
                                     , ubt_amt_g) * annualization_factor ubt_amt_a
             ,DECODE(l_annu_curr_code, l_glob_curr_code, credit_amt_g
                                     , l_sglob_curr_code, credit_amt_sg
                                     , credit_amt_g) * annualization_factor credit_amt_a
             ,DECODE(l_annu_curr_code, l_glob_curr_code, override_amt_g
                                     , l_sglob_curr_code, override_amt_sg
                                     , override_amt_g) * annualization_factor override_amt_a
             ,DECODE(l_annu_curr_code, l_glob_curr_code, supp_credit_g
                                     , l_sglob_curr_code, supp_credit_sg
                                     , supp_credit_g) * annualization_factor supp_credit_a
             ,DECODE(l_annu_curr_code, l_glob_curr_code, price_negotiated_g
                                     , l_sglob_curr_code, price_negotiated_sg
                                     , price_negotiated_g) * annualization_factor price_negotiated_a
             , l_login_id
             , l_run_date
             , l_run_date
             , gsd_flag
              -- add the four extra columns
             , effective_active_date
             , effective_term_date
             , effective_expire_date
             , termination_entry_date
             , falsernwlyn
             , curr_code
             , curr_code_f
             , hdr_order_number
             , hdr_sts_code
             , hdr_trn_code
             , hdr_renewal_type
             , hdr_date_approved
             , hdr_date_cancelled
             , hdr_date_terminated
             , hdr_creation_date
             , hdr_last_update_date
             , service_item_org_id
             , sl_line_number
             , sl_sts_code
             , sl_trn_code
             , sl_renewal_type
             , sl_start_date
             , sl_end_Date
             , sl_date_cancelled
             , sl_date_terminated
             , sl_creation_date
             , sl_last_update_date
             , order_number
             , unit_price_percent
             , unit_price
             , unit_price_f
             , unit_price_g
             , unit_price_sg
             , list_price
             , list_price_f
             , list_price_g
             , list_price_sg
             , duration_uom
             , duration_qty
             , cl_last_update_date
             , cov_prod_id
             , cov_prod_system_id
             , line_number
             , line_type
	           , hdr_bill_site_id
	           , hdr_ship_site_id
	           , hdr_acct_rule_id
	           , hdr_grace_end_date
	           , hdr_date_signed
	           , to_number(p_cle_id)
	           , to_number(r_cle_id)
	           , hdr_subsequent_renewal_type	/* for ER#5760744 */
             , agreement_type_code   /* for ER 6062516 */
             , agreement_name       /* for ER 6062516 */
	           , negotiation_status   /* Added this colunm as a part of ER#5950128 */
	           , reminder   /* Added this colunm as a part of ER#5950128 */
	           , HDR_TERM_CANCEL_SOURCE  /* Added as part of ER 6684955 */
	           , SL_TERM_CANCEL_SOURCE  /* Added as part of ER 6684955 */
        FROM
         (  SELECT
                ilv1.chr_id
              , ilv1.cle_id
              , ilv1.cle_creation_date
              , ilv1.inv_organization_id
              , ilv1.authoring_org_id
              , ilv1.application_id
              , ilv1.customer_party_id
              , ilv1.resource_group_id
              , ilv1.resource_id
              , ilv1.salesrep_id
              , ilv1.price_negotiated
              , ilv1.price_negotiated_f
              , ilv1.price_negotiated_g
              , ilv1.price_negotiated_sg
              , ilv1.contract_number
              , ilv1.contract_number_modifier
              , ilv1.buy_or_sell
              , ilv1.scs_code
              , ilv1.sts_code -- line level cancellation code
              , ilv1.trn_code
              , ilv1.root_lty_code
              ,  CASE when l_renewal_logic = 'STANDARD' THEN
   						        NVL (ilv1.renewal_flag, 0)
				         ELSE
						         DECODE(ilv1.order_number,NULL,1,0)
				         END  AS renewal_flag
              , p_cle_id
	            , r_cle_id
              , ilv1.date_signed
	            , ilv1.date_cancelled -- line level cancelled date
	            , ilv1.hstart_date   -- header start_date
              , ilv1.hend_date      -- header end_date
              , ilv1.start_date
              , ilv1.end_date
              , ilv1.date_terminated
              , ilv1.trx_func_curr_rate
              , ilv1.func_global_curr_rate
              , ilv1.func_sglobal_curr_rate
              , ilv1.sle_id
              , ilv1.service_item_id
              , ilv1.covered_item_id
              , decode (ilv1.covered_item_id, -1,-99,ilv1.inv_organization_id) covered_item_org_id
              , ilv1.quantity
              , ilv1.uom_code
              , ilv1.grace_end_date
              , ilv1.expected_close_date
              , ilv1.win_percent
              , ilv1.ubt_amt
              , ilv1.ubt_amt * ilv1.trx_func_curr_rate ubt_amt_f
              , ilv1.ubt_amt * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate ubt_amt_g
              , ilv1.ubt_amt * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate ubt_amt_sg
              , ilv1.credit_amt
              , ilv1.credit_amt * ilv1.trx_func_curr_rate credit_amt_f
              , ilv1.credit_amt * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate credit_amt_g
              , ilv1.credit_amt * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate credit_amt_sg
              , ilv1.override_amt
              , ilv1.override_amt * ilv1.trx_func_curr_rate override_amt_f
              , ilv1.override_amt * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate override_amt_g
              , ilv1.override_amt * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate override_amt_sg
              , ilv1.supp_credit
              , ilv1.supp_credit * ilv1.trx_func_curr_rate supp_credit_f
              , ilv1.supp_credit * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate supp_credit_g
              , ilv1.supp_credit * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate supp_credit_sg
              , ilv1.renewal_type
              , (CASE WHEN ilv1.date_terminated < ilv1.start_date
                      THEN -1
	               ELSE 1
                 END ) term_flag
              , ilv1.annualization_factor
              , ilv1.gsd_flag
              , CASE WHEN l_balance_logic='CONTRDATE' THEN 	date_terminated
				         ELSE
 				           least(greatest(date_terminated,termination_entry_date,nvl(date_signed,date_terminated)),
				           greatest(ilv1.date_signed,ilv1.end_date))
				       --Usually date_terminated cannot be prsent without date signed. This is a check for bad data available in the volume environments
				         END effective_term_date
              ,  CASE WHEN l_balance_logic='CONTRDATE'  and ilv1.date_signed is not null THEN
					           ilv1.end_date
                  ELSE
					           greatest(ilv1.date_signed,ilv1.end_date)
				         END effective_expire_date
              ,  CASE WHEN l_balance_logic='CONTRDATE'  and ilv1.date_signed is not null THEN
					            ilv1.start_date
                  ELSE
					            greatest(ilv1.date_signed,ilv1.start_date)
                END effective_active_date
             ,  NVL2(ilv1.date_terminated,termination_entry_date,NULL) termination_entry_date
             /* We change the definition given in the inner query if the value of balance logic is event dates */
             ,	CASE WHEN l_balance_logic='CONTRDATE' THEN
					           ilv1.effective_start_date
			           ELSE
					           greatest(ilv1.date_signed,ilv1.start_date)
                 END effective_start_date
             , CASE WHEN l_balance_logic='CONTRDATE' THEN
  			            ilv1.effective_end_date
			          ELSE
                    NVL2(ilv1.date_terminated,
                   least(greatest(date_terminated,termination_entry_date,nvl(date_signed,date_terminated)),
					         greatest(ilv1.date_signed,ilv1.end_date))
                  ,greatest(ilv1.end_date,ilv1.date_signed))
               END effective_end_date
             , CASE WHEN l_renewal_logic= 'ORDERNO' AND ilv1.order_number IS NULL
				            AND ilv1.renewal_flag =0 THEN 'Y'
				       END falsernwlyn
	           , ilv1.curr_code
             , ilv1.curr_code_f
             , ilv1.hdr_order_number
	           , ilv1.hdr_sts_code
             , ilv1.hdr_trn_code
             , ilv1.hdr_renewal_type
             , ilv1.hdr_date_approved
             , ilv1.hdr_date_cancelled
             , ilv1.hdr_date_terminated
             , ilv1.hdr_creation_date
             , ilv1.hdr_last_update_date
             , ilv1.service_item_org_id
             , ilv1.sl_line_number
             , ilv1.sl_sts_code
             , ilv1.sl_trn_code
             , ilv1.sl_renewal_type
             , ilv1.sl_start_date
             , ilv1.sl_end_Date
             , ilv1.sl_date_cancelled
             , ilv1.sl_date_terminated
             , ilv1.sl_creation_date
             , ilv1.sl_last_update_date
             , ilv1.order_number
             , ilv1.unit_price_percent
             , ilv1.unit_price
             , nvl(ilv1.unit_price,0) * ilv1.trx_func_curr_rate unit_price_f
             , nvl(ilv1.unit_price,0) * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate unit_price_g
             , nvl(ilv1.unit_price,0) * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate unit_price_sg
             , ilv1.list_price
             , nvl(ilv1.list_price,0) * ilv1.trx_func_curr_rate list_price_f
             , nvl(ilv1.list_price,0) * ilv1.trx_func_curr_rate * ilv1.func_global_curr_rate list_price_g
             , nvl(ilv1.list_price,0) * ilv1.trx_func_curr_rate * ilv1.func_sglobal_curr_rate list_price_sg
             , ilv1.duration_uom
             , ilv1.duration_qty
             , ilv1.cl_last_update_date
             , ilv1.cov_prod_id
             , ilv1.cov_prod_system_id
             , ilv1.line_number
             , ilv1.line_type
	           , ilv1.hdr_bill_site_id
	           , ilv1.hdr_ship_site_id
	           , ilv1.hdr_acct_rule_id
	           , ilv1.hdr_grace_end_date
	           , ilv1.hdr_date_signed
	           , ilv1.hdr_subsequent_renewal_type	 /* Added ER#5760744 */
             , ilv1.agreement_type_code  /* for ER 6062516 */
             , ilv1.agreement_name      /* for ER 6062516 */
	           , ilv1.negotiation_status  /* Added for ER#5950128 */
	           , ilv1.reminder /* Added  ER#5950128 */
	           , ilv1.HDR_TERM_CANCEL_SOURCE  /*  ER 6684955 */
	           , ilv1.SL_TERM_CANCEL_SOURCE   /*  ER 6684955 */
            -- modified hints as feedback from performance team 27-OCT-2005.
          FROM
		         (
		          SELECT
		             newilv.*,
		               (SELECT  DECODE(COUNT(1), 0, 0, 1) renewal_flag
                      FROM   okc_operation_lines okl
 		                       , okc_operation_instances opins
                     WHERE  rownum=1
                     AND okl.object_cle_id IS NOT NULL
					           AND okl.subject_cle_id IS NOT NULL
					           AND okl.oie_id=opins.id
					           AND opins.cop_id in (g_renewal_id,g_ren_con_id)
    				         AND newilv.cle_id=okl.subject_cle_id
					   ) RENEWAL_FLAG
		      FROM
	           (SELECT /*+ ordered use_hash(h,sl,l,root_temp,itm,itm2,cii,oksl) full(l)
                      parallel(cur) parallel(h)  parallel(l) parallel(sl)
                      parallel(oksl) parallel(itm) parallel(itm2) parallel(cii)
					            swap_join_inputs(root_temp)
                      pq_distribute(h hash,hash)
                      pq_distribute(oksl hash,hash)
                      pq_distribute(itm,hash,hash)
		                  pq_distribute(l,hash,hash) pq_distribute(itm2,hash,hash)  */
                 h.chr_id chr_id
               , l.id cle_id
               , l.creation_date cle_creation_date
	             , l.annualized_factor annualization_factor
               , h.master_organization_id AS inv_organization_id
               , h.authoring_org_id
               , h.application_id
               , TO_NUMBER(h.customer_party_id) customer_party_id
               , h.salesrep_id
               , h.resource_id
               , h.resource_group_id
               , nvl(l.price_negotiated,0) price_negotiated
               , nvl(l.price_negotiated,0) * cur.rate_f price_negotiated_f
               , nvl(l.price_negotiated,0) * cur.rate_g price_negotiated_g
               , nvl(l.price_negotiated,0) * cur.rate_sg price_negotiated_sg
               , h.contract_number
               , h.contract_number_modifier
               , h.buy_or_sell
               , h.scs_code
               , l.sts_code
               , NVL(l.trn_code,h.trn_code) trn_code
               , root_temp.root_lty_code
		     	 /*  , row_number() over (partition by l.id order by okl.last_update_date desc) rnum */
                , to_number(null) p_cle_id
                , r1.subject_cle_id r_cle_id
                , CASE WHEN l.date_cancelled is null
				               THEN h.date_signed
				           ELSE null
				          END date_signed
			          , l.date_cancelled date_cancelled
			          , h.start_date hstart_date
			          , h.end_date hend_date
                , l.start_date start_date
                , COALESCE((l.end_date + 1)
                        , (h.end_date + 1)
                        ,  g_4712_date) end_date
               ,trunc(months_between((COALESCE((l.end_date)
                        , (h.end_date)
                        ,  g_4712_date)), l.start_date)/12)   nyears
               , NVL2(h.date_signed,l.date_terminated,NULL ) AS date_terminated
               , NVL2(h.date_signed, l.start_date,NULL) effective_start_date
               , NVL2(h.date_signed
                      , LEAST(COALESCE(l.end_date
                                     , h.end_date
                                     ,  g_4712_date) +1
                            , COALESCE(l.date_terminated
                                     , h.date_terminated
                                     ,  g_4712_date))
                      , NULL) effective_end_date
               , cur.rate_f trx_func_curr_rate
               , cur.rate_g / decode(cur.rate_f,0,-1,cur.rate_f) func_global_curr_rate
               , cur.rate_sg / decode(cur.rate_f,0,-1,cur.rate_f) func_sglobal_curr_rate
               , CASE WHEN h.end_date = l.end_date
                      THEN h.grace_end_date
                      ELSE NULL
                 END AS grace_end_date
               -- service item, covered item
               , sl.id           AS sle_id
               , itm.object1_id1 AS service_item_id
               , NVL((CASE WHEN root_temp.lty_code IN ('COVER_ITEM')
               -- if to_number is removed get ORA-00932 inconsistent datatypes
                        THEN TO_NUMBER (itm2.object1_id1)
                      WHEN root_temp.lty_code IN ('COVER_PROD')
                        THEN cii.inventory_item_id
                 END),-1) AS covered_item_id
               , itm2.number_of_items  quantity
               , itm2.uom_code AS uom_code
                -- Forecast
               , h.est_rev_percent win_percent
               , h.est_rev_date expected_close_date
                -- terminated amounts
               , nvl(oksl.ubt_amount,0) ubt_amt
               , nvl(oksl.credit_amount,0) credit_amt
               , nvl(oksl.override_amount,0) override_amt
               , nvl(oksl.suppressed_credit,0) supp_credit
               , CASE WHEN nvl(h.renewal_type_code,'X') = 'DNR'
				             OR nvl(sl.line_renewal_type_code,'X') ='DNR' THEN
				             'DNR'
			 	         ELSE
				            l.line_renewal_type_code
				         END renewal_type
		           , h.gsd_flag
		           , l.last_update_date termination_entry_date
		           , h.trx_currency              curr_code
		           , h.func_currency             curr_code_f
		           , h.order_number             hdr_order_number
		           , h.sts_code                  hdr_sts_code
		           , h.trn_code                  hdr_trn_code
		           , h.renewal_type_code         hdr_renewal_type
		           , h.date_approved             hdr_date_approved
		           , h.datetime_cancelled        hdr_date_cancelled
		           , h.date_terminated           hdr_date_terminated
		           , h.creation_Date             hdr_creation_date
		           , h.last_update_date          hdr_last_update_date
		           , itm.object1_id2             service_item_org_id
		           , sl.line_number              sl_line_number
		           , sl.sts_code                 sl_sts_code
		           , NVL(sl.trn_code,h.trn_code) sl_trn_code
		           , ( CASE WHEN h.renewal_type_code = 'DNR'
 		                    THEN h.renewal_type_code
			             ELSE sl.line_renewal_type_code
			             END ) sl_renewal_type
		           , sl.start_date               sl_start_date
		           , sl.end_date                 sl_end_Date
	             , sl.date_cancelled           sl_date_cancelled
	             , sl.date_terminated          sl_date_terminated
	             , sl.creation_date            sl_creation_date
	             , sl.last_update_date         sl_last_update_date
	             , decode(root_temp.root_lty_code,'WARRANTY',h.order_number,oehdr.order_number)   order_number
	             , decode(oksl.toplvl_operand_code,
	                  'PERCENT_PRICE',oksl.toplvl_operand_val,
	                                 NULL) unit_price_percent
	             , nvl(l.price_unit,0)         unit_price
	             , nvl(l.line_list_price,0)    list_price
	             , oksl.toplvl_uom_code        duration_uom
	             , oksl.toplvl_price_qty        duration_qty
	             , l.last_update_date          cl_last_update_date
	             , CASE WHEN root_temp.lty_code IN ('COVER_PROD')
			                THEN cii.instance_id
			           ELSE -999
                 END		                cov_prod_id
	             , CASE WHEN root_temp.lty_code IN ('COVER_PROD')
                        THEN NVL(cii.system_id,-1)
                      ELSE -999
		             END		                cov_prod_system_id
		           , sl.line_number ||'.' || l.line_number line_number
	             , root_temp.lty_code          line_type
		           , h.Bill_to_site_use_id		 hdr_bill_site_id
		           , h.Ship_to_site_use_id		 hdr_ship_site_id
		           , h.Acct_rule_id			 hdr_acct_rule_id
		           , h.grace_end_date      hdr_grace_end_date
		           , h.date_signed         hdr_date_signed
	, h.subsequent_renewal_type_code hdr_subsequent_renewal_type		/* ER#5760744 */
  , agmt.agreement_type_code   /* for ER 6062516 */
  , agmt.agreement_name        /* for ER 6062516 */
  , h.negotiation_status negotiation_status   /* ER#5950128 */
	, decode(h.reminder, 'Y', 'Enable', 'N', 'Disable', h.reminder) reminder    /*  ER#5950128 */
	, h.HDR_TERM_CANCEL_SOURCE HDR_TERM_CANCEL_SOURCE  /*  ER 6684955 */
	, NVL(sl.term_cancel_source, h.HDR_TERM_CANCEL_SOURCE ) SL_TERM_CANCEL_SOURCE   /*  ER 6684955 */
	         FROM
                    oki_dbi_chr_inc h
                  , oki_dbi_curr_conv cur
                  , okc_k_lines_b sl
		              , okc_k_items itm
                  , okc_k_lines_b l
                  , ( select /*+ no_merge */ oab.agreement_id
                            , qpl.meaning agreement_type_code
                            , oat.name agreement_name
                        from oe_agreements_tl oat,
		                         qp_lookups qpl,
                             oe_agreements_b oab
                        where oab.agreement_id = oat.agreement_id
                          and oat.language = userenv('LANG')
                          and qpl.lookup_type(+) = 'QP_AGREEMENT_TYPE'
		                      and qpl.lookup_code(+) = oab.agreement_type_code
                    ) agmt     /* for ER 6062516 */
                  , (   Select  /*+ no_merge */ id,lty_code,decode(lse_parent_id,l_service_code,'SERVICE',l_warranty_code,'WARRANTY',l_ext_warr_code,'EXT_WARRANTY') root_lty_code
                        FROM okc_line_styles_b n
			                  where lse_parent_id in (l_service_code,l_warranty_code,l_ext_warr_code)
                     ) root_temp
		              , oks_k_lines_b oksl
	                      /*, okc_operation_lines okl
	                        , okc_operation_instances OPINS */
                  , okc_k_items itm2
                  , csi_item_instances cii
		              , ( /* rel objs has multiple entries for the same order number */
				              Select /*+ no_merge parallel(oehdr) parallel(oelin) parallel(okcrel) */ okcrel.cle_id,max(oehdr.order_number) order_number
				                from
				                  oe_order_headers_all  oehdr
				                , oe_order_lines_all oelin
				                , okc_k_rel_objs okcrel
				              WHERE  okcrel.object1_id1 = oelin.line_id
			                  AND  oehdr.header_id = oelin.header_id
				               group by okcrel.cle_id
                     ) oehdr
		              , (    SELECT    object_cle_id  ,
		                              MAX(subject_cle_id) KEEP (DENSE_RANK LAST ORDER BY okl.last_update_date) subject_cle_id
					                FROM   okc_operation_lines okl
					                      , okc_operation_instances opins
					                WHERE
					                    okl.object_cle_id IS NOT NULL
					                 AND okl.subject_cle_id IS NOT NULL
					                 AND okl.oie_id=opins.id
					                 AND opins.cop_id in (g_renewal_id,g_ren_con_id)
					               group by okl.object_cle_id
		               ) r1
        WHERE 1 = 1
        AND l.id = oehdr.cle_id(+)
	      AND (h.chr_id = cur.chr_id OR upper(cur.rate_type) <> 'USER')
	      AND h.conversion_date = cur.curr_conv_date
	      AND h.trx_currency = cur.from_currency
	      AND h.func_currency = cur.to_currency
	      AND h.trx_rate_type = cur.rate_type
	      AND h.chr_id          = sl.chr_id
	      AND sl.ID         = l.cle_id
	      AND l.price_level_ind = 'Y'
        AND l.lse_id = root_temp.id
	      AND sl.ID             = itm.cle_id
	      AND l.id              = itm2.cle_id
	      AND itm2.object1_id1  = cii.instance_id(+)
	      AND l.id              = oksl.cle_id
	      AND l.id               = r1.object_cle_id(+)
        AND cii.last_oe_agreement_id = agmt.agreement_id(+)
			/*  AND l.id              = okl.object_cle_id(+)
			  AND okl.object_cle_id(+) IS NOT NULL
		    AND okl.subject_cle_id(+) IS NOT NULL
			  AND okl.oie_id=opins.id(+)
			  AND opins.cop_id(+) = decode(opins.cop_id(+),g_renewal_id,g_renewal_id,g_ren_con_id,g_ren_con_id) */
		) newilv
            ) ilv1
	   WHERE   1=1
    ));
   p_recs_processed := SQL%ROWCOUNT ;

  --++++++++++++++++++++++++

   --Lesters Feedback 5/19/04 disable force parallel qry
    EXECUTE IMMEDIATE 'alter session enable parallel query';
        l_count := p_recs_processed;
        rlog( 'Number of lines inserted into OKI_DBI_CLE_B_OLD :   ' ||
               to_char(l_count),2);
        COMMIT;
	    rlog('Load of Staging Table OKI_DBI_CLE_B_OLD completed -    ' ||
                                        fnd_date.date_to_displayDT(SYSDATE),1) ;

        GATHER_TABLE_STATS(TABNAME=>'OKI_DBI_CLE_B_OLD');

        rlog('Populating Base Summary Table OKI_DBI_CLE_B -   ' ||  fnd_date.date_to_displayDT(SYSDATE),1) ;


		-- Added enable parallel dml since change in dbms_stats implementation disables
		-- the parellel dml call which results in the subsequent insert being serialized.
	   -- No longer need since it is now done in the gather_table_stats procedure
		-- EXECUTE IMMEDIATE 'alter session enable parallel dml';

   INSERT /*+ APPEND parallel(f)*/ INTO OKI_DBI_CLE_B f
    (
       chr_id
     , cle_id
     , cle_creation_date
     , inv_organization_id
     , authoring_org_id
     , application_id
     , customer_party_id
     , salesrep_id
     , price_negotiated
     , price_negotiated_f
     , price_negotiated_g
     , price_negotiated_sg
     , contract_number
     , contract_number_modifier
     , buy_or_sell
     , scs_code
     , sts_code
     , trn_code
     , root_lty_code
     , renewal_flag
     , date_signed
     , date_cancelled
     , hstart_date
     , hend_date
     , start_date
     , end_date
     , date_terminated
     , effective_start_date
     , effective_end_date
     , trx_func_curr_rate
     , func_global_curr_rate
     , func_sglobal_curr_rate
     , created_by
     , last_update_login
     , creation_date
     , last_updated_by
     , last_update_date
     , request_id
     , program_application_id
     , program_id
     , program_login_id
     , resource_group_id
     , resource_id
     , sle_id
     , service_item_id
     , covered_item_id
     , covered_item_org_id
     , quantity
     , uom_code
     , grace_end_date
     , expected_close_date
     , win_percent
     , ubt_amt
     , ubt_amt_f
     , ubt_amt_g
     , ubt_amt_sg
     , credit_amt
     , credit_amt_f
     , credit_amt_g
     , credit_amt_sg
     , override_amt
     , override_amt_f
     , override_amt_g
     , override_amt_sg
     , supp_credit
     , supp_credit_f
     , supp_credit_g
     , supp_credit_sg
     , renewal_type
     , term_flag
     , r_chr_id
     , r_cle_id
     , r_date_signed
     , r_date_cancelled
     , annualization_factor
     , p_chr_id
     , p_cle_id
     , p_price_negotiated
     , p_price_negotiated_f
     , p_price_negotiated_g
     , p_price_negotiated_sg
     , p_grace_end_date
     , p_ubt_amt
     , p_ubt_amt_f
     , p_ubt_amt_g
     , p_ubt_amt_sg
     , p_credit_amt
     , p_credit_amt_f
     , p_credit_amt_g
     , p_credit_amt_sg
     , p_override_amt
     , p_override_amt_f
     , p_override_amt_g
     , p_override_amt_sg
     , p_supp_credit
     , p_supp_credit_f
     , p_supp_credit_g
     , p_supp_credit_sg
     , p_end_date
     , p_term_flag
     , price_negotiated_a
     , ubt_amt_a
     , credit_amt_a
     , override_amt_a
     , supp_credit_a
     , p_price_negotiated_a
     , p_ubt_amt_a
     , p_credit_amt_a
     , p_override_amt_a
     , p_supp_credit_a
     , gsd_flag
     , falsernwlyn
     , effective_term_date
     , effective_expire_date
     , effective_active_date
     , termination_entry_date
     , curr_code
     , curr_code_f
     , hdr_order_number
     , hdr_sts_code
     , hdr_trn_code
     , hdr_renewal_type
     , hdr_date_approved
     , hdr_date_cancelled
     , hdr_date_terminated
     , hdr_creation_date
     , hdr_last_update_date
     , service_item_org_id
     , sl_line_number
     , sl_sts_code
     , sl_trn_code
     , sl_renewal_type
     , sl_start_date
     , sl_end_Date
     , sl_date_cancelled
     , sl_date_terminated
     , sl_creation_date
     , sl_last_update_date
     , order_number
     , unit_price_percent
     , unit_price
     , unit_price_f
     , unit_price_g
     , unit_price_sg
     , list_price
     , list_price_f
     , list_price_g
     , list_price_sg
     , duration_uom
     , duration_qty
     , cl_last_update_date
     , cov_prod_id
     , cov_prod_system_id
     , line_number
     , line_type
     , hdr_bill_site_id
     , hdr_ship_site_id
     , hdr_acct_rule_id
     , hdr_grace_end_date
     , hdr_date_signed
     , hdr_subsequent_renewal_type		/*  ER#5760744 */
     , agreement_type_code  /* ER 6062516 */
     , agreement_name  /* ER 6062516 */
     , negotiation_status      /*  ER#5950128 */
     , reminder                /*  ER#5950128 */
     , hdr_term_cancel_source  /*  ER 6684955 */
	   , sl_term_cancel_source   /*  ER 6684955 */
      )
       SELECT /*+ ordered use_hash(rl) parallel(ren_rel) parallel(rl)
               pq_distribute(rl,hash,hash)  */
                ren_rel.chr_id
              , ren_rel.cle_id
              , ren_rel.cle_creation_date
              , ren_rel.inv_organization_id
              , ren_rel.authoring_org_id
              , ren_rel.application_id
              , ren_rel.customer_party_id
              , ren_rel.salesrep_id
              , ren_rel.price_negotiated
              , ren_rel.price_negotiated_f
              , ren_rel.price_negotiated_g
              , ren_rel.price_negotiated_sg
              , ren_rel.contract_number
              , ren_rel.contract_number_modifier
              , ren_rel.buy_or_sell
              , ren_rel.scs_code
              , ren_rel.sts_code
              , ren_rel.trn_code
              , ren_rel.root_lty_code
              , ren_rel.renewal_flag
              , ren_rel.date_signed
              , ren_rel.date_cancelled
              , ren_rel.hstart_date
              , ren_rel.hend_date
              , ren_rel.start_date
              , ren_rel.end_date
              , ren_rel.date_terminated
              , ren_rel.effective_start_date
              , ren_rel.effective_end_date
              , ren_rel.trx_func_curr_rate
              , ren_rel.func_global_curr_rate
              , ren_rel.func_sglobal_curr_rate
              , l_user_id
              , l_login_id
              , l_run_date
              , l_user_id
              , l_run_date
              -- CM request ID columns here
              , l_request_id
              , l_program_application_id
              , l_program_id
              , l_program_login_id
               -- Resource, resource group
              , ren_rel.resource_group_id
              , ren_rel.resource_id
              -- service item, covered item
              , ren_rel.sle_id
              , ren_rel.service_item_id
              , ren_rel.covered_item_id
              , ren_rel.covered_item_org_id
              , ren_rel.quantity
              , ren_rel.uom_code
              , ren_rel.grace_end_date
              -- Forecast
              , ren_rel.expected_close_date
              , ren_rel.win_percent
              , ren_rel.ubt_amt
              , ren_rel.ubt_amt_f
              , ren_rel.ubt_amt_g
              , ren_rel.ubt_amt_sg
              , ren_rel.credit_amt
              , ren_rel.credit_amt_f
              , ren_rel.credit_amt_g
              , ren_rel.credit_amt_sg
              , ren_rel.override_amt
              , ren_rel.override_amt_f
              , ren_rel.override_amt_g
              , ren_rel.override_amt_sg
              , ren_rel.supp_credit
              , ren_rel.supp_credit_f
              , ren_rel.supp_credit_g
              , ren_rel.supp_credit_sg
              , ren_rel.renewal_type
              , ren_rel.term_flag
              , rl.chr_id
              , rl.cle_id
              , rl.date_signed
              , rl.date_cancelled
              , ren_rel.annualization_factor
              , p.chr_id
              , p.cle_id
              , p.price_negotiated
              , p.price_negotiated_f
              , p.price_negotiated_g
              , p.price_negotiated_sg
              , p.grace_end_date
              , p.ubt_amt
              , p.ubt_amt_f
              , p.ubt_amt_g
              , p.ubt_amt_sg
              , p.credit_amt
              , p.credit_amt_f
              , p.credit_amt_g
              , p.credit_amt_sg
              , p.override_amt
              , p.override_amt_f
              , p.override_amt_g
              , p.override_amt_sg
              , p.supp_credit
              , p.supp_credit_f
              , p.supp_credit_g
              , p.supp_credit_sg
              , p.end_date
              , p.term_flag
              , ren_rel.price_negotiated_a
              , ren_rel.ubt_amt_a
              , ren_rel.credit_amt_a
              , ren_rel.override_amt_a
              , ren_rel.supp_credit_a
              , p.price_negotiated_a
              , p.ubt_amt_a
              , p.credit_amt_a
              , p.override_amt_a
              , p.supp_credit_a
              , ren_rel.gsd_flag
	            , ren_rel.falsernwlyn
	            , ren_rel.effective_term_date
              , ren_rel.effective_expire_date
              , ren_rel.effective_active_date
              , ren_rel.termination_entry_date
	            , ren_rel.curr_code
              , ren_rel.curr_code_f
              , ren_rel.hdr_order_number
              , ren_rel.hdr_sts_code
              , ren_rel.hdr_trn_code
              , ren_rel.hdr_renewal_type
              , ren_rel.hdr_date_approved
              , ren_rel.hdr_date_cancelled
              , ren_rel.hdr_date_terminated
              , ren_rel.hdr_creation_date
              , ren_rel.hdr_last_update_date
              , ren_rel.service_item_org_id
              , ren_rel.sl_line_number
              , ren_rel.sl_sts_code
              , ren_rel.sl_trn_code
              , ren_rel.sl_renewal_type
              , ren_rel.sl_start_date
              , ren_rel.sl_end_Date
              , ren_rel.sl_date_cancelled
              , ren_rel.sl_date_terminated
              , ren_rel.sl_creation_date
              , ren_rel.sl_last_update_date
              , ren_rel.order_number
              , ren_rel.unit_price_percent
              , ren_rel.unit_price
              , ren_rel.unit_price_f
              , ren_rel.unit_price_g
              , ren_rel.unit_price_sg
              , ren_rel.list_price
              , ren_rel.list_price_f
              , ren_rel.list_price_g
              , ren_rel.list_price_sg
              , ren_rel.duration_uom
              , ren_rel.duration_qty
              , ren_rel.cl_last_update_date
              , ren_rel.cov_prod_id
              , ren_rel.cov_prod_system_id
              , ren_rel.line_number
              , ren_rel.line_type
	            , ren_rel.hdr_bill_site_id
	            , ren_rel.hdr_ship_site_id
	            , ren_rel.hdr_acct_rule_id
	            , ren_rel.hdr_grace_end_date
	            , ren_rel.hdr_date_signed
	   , ren_rel.hdr_subsequent_renewal_type	/*  ER#5760744 */
	   , ren_rel.agreement_type_code  /* ER 6062516 */
	   , ren_rel.agreement_name  /* ER 6062516 */
	   , ren_rel.negotiation_status   /*  ER#5950128 */
	   , ren_rel.reminder             /*  ER#5950128 */
	   , ren_rel.hdr_term_cancel_source   /*  ER 6684955 */
	   , ren_rel.sl_term_cancel_source    /*  ER 6684955 */
       FROM
             oki_dbi_cle_b_old ren_rel
           , oki_dbi_cle_b_old P
           , oki_dbi_cle_b_old rl
      WHERE 1=1
      AND   ren_rel.r_cle_id=rl.cle_id(+)
      AND   ren_rel.cle_id=P.r_cle_id(+);

        p_recs_processed := SQL%ROWCOUNT ;

        l_count := p_recs_processed;
        rlog('Number of lines inserted into OKI_DBI_CLE_B :       ' || to_char(l_count),2);
      COMMIT;
    rlog('Load of Base Summary Table OKI_DBI_CLE_B Completed -   ' ||
                                        fnd_date.date_to_displayDT(SYSDATE),1) ;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       RAISE;
    WHEN OTHERS THEN
      rlog('Error during direct_load: Insert into OKI_DBI_CLE_B Table Failed' , 0);
      rlog(sqlerrm ||'   '||sqlcode, 0);
       bis_collection_utilities.put_line(sqlerrm || '' || sqlcode ) ;
       fnd_message.set_name(  application => 'FND'
                            , name        => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                             , value => 'OKI_DBI_LOAD_CLEB_PVT.direct_load ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END direct_load;

/*******************************************************************************
  Procedure:    worker
  Description:  This Procedure will be called by spawned request.
                Hence value of global variables will be lost.
                Here we will decide which stage it should load.
                  Stage 1) Load Staging table oki_dbi_cle_b_old with contracts info
                  Stage 2) Load RHS of oki_dbi_cle_b_old with its renewal information
                  Stage 3) Load LHS of oki_dbi_cle_b_old with its original information
  Parameters:
   errbuf -Mandatory out parameter containing error message to be passed back to the concurrent manager
   retcode-Mandatory out parameter containing the Oracle error number to be passed back to the concurrent manager
   p_worker_no- current worker number
   p_phase - identifier of the sub-stage
   p_no_of_workers- total number of workers requested by the user
*******************************************************************************/

PROCEDURE worker(errbuf      OUT   NOCOPY VARCHAR2,
                 retcode     OUT   NOCOPY VARCHAR2,
                 p_worker_no IN NUMBER,
                 p_phase     IN NUMBER,
                 p_no_of_workers IN NUMBER) IS

  l_unassigned_cnt       NUMBER := 0;
  l_failed_cnt           NUMBER := 0;
  l_wip_cnt              NUMBER := 0;
  l_completed_cnt        NUMBER := 0;
  l_total_cnt            NUMBER := 0;
  l_count                NUMBER := 0;
  l_recs_processed       NUMBER := 0;

BEGIN

    rlog('Start of Worker '|| p_worker_no ||' : ' ||fnd_date.date_to_displayDT(SYSDATE),1);
    errbuf  := NULL;
    retcode := 0;
    l_count := 0;

    SELECT NVL(sum(decode(status,'UNASSIGNED', 1, 0)),0),
           NVL(sum(decode(status,'FAILED', 1, 0)),0),
           NVL(sum(decode(status,'IN PROCESS', 1, 0)),0),
           NVL(sum(decode(status,'COMPLETED',1 , 0)),0),
           count(*)
    INTO   l_unassigned_cnt,
           l_failed_cnt,
           l_wip_cnt,
           l_completed_cnt,
           l_total_cnt
    FROM   OKI_DBI_WORKER_STATUS
    WHERE 1=1
    AND object_name = 'OKI_DBI_CLE_B_OLD';

    IF (l_failed_cnt > 0) THEN
      rlog('Another worker have errored out.  Stop processing.',2);
    ELSIF (l_unassigned_cnt = 0) THEN
      rlog('No more jobs left.  Terminating.',2);
    ELSIF (l_completed_cnt = l_total_cnt) THEN
      rlog('All jobs completed, no more job.  Terminating',2);
    ELSIF (l_unassigned_cnt > 0) THEN

      UPDATE OKI_DBI_WORKER_STATUS
      SET status = 'IN PROCESS'
         ,phase   = p_phase
      WHERE object_name = 'OKI_DBI_CLE_B_OLD'
      AND worker_number = p_worker_no
      AND STATUS ='UNASSIGNED';

      COMMIT;

      DECLARE
      BEGIN
        IF p_phase = 1 THEN
           load_staging(p_worker_no, l_recs_processed);
        ELSIF p_phase = 2 THEN
        	 delta_changes  ( p_worker_no, p_no_of_workers, l_recs_processed );
        ELSIF p_phase = 3 THEN
           populate_prev_inc( p_worker_no, p_no_of_workers,1,l_recs_processed );
        ELSIF p_phase = 4 THEN
           populate_prev_inc( p_worker_no, p_no_of_workers,2,l_recs_processed );
        ELSIF p_phase = 5 THEN
        	 update_staging ( p_worker_no, p_no_of_workers, l_recs_processed );
        ELSIF p_phase = 6 THEN
           update_RHS(p_worker_no, p_no_of_workers, l_recs_processed);
        ELSIF p_phase  = 7 THEN
           update_LHS(p_worker_no, p_no_of_workers,l_recs_processed);
        ELSE
        	    RAISE G_CHILD_PROCESS_ISSUE;
        END IF;

    --    rlog('Total No of Records updated in OKI_DBI_CLE_B_OLD using Worker '||
    --                                p_worker_no || ' is '|| l_recs_processed,3);
        COMMIT;

        UPDATE OKI_DBI_WORKER_STATUS
        SET    status = 'COMPLETED'
        WHERE  object_name = 'OKI_DBI_CLE_B_OLD'
        AND    status = 'IN PROCESS'
        AND    worker_number = p_worker_no;
        COMMIT;

      EXCEPTION
        WHEN OTHERS THEN
          retcode := -1;

          UPDATE OKI_DBI_WORKER_STATUS
          SET    status = 'FAILED'
          WHERE  object_name = 'OKI_DBI_CLE_B_OLD'
          AND    status = 'IN PROCESS'
          AND    worker_number = p_worker_no;

          COMMIT;
          rlog('An Error occurred in worker : '|| p_worker_no ,1);
          RAISE G_CHILD_PROCESS_ISSUE;
      END;
    END IF;

    rlog('Finished Worker ' || p_worker_no || ' : ' ||fnd_date.date_to_displayDT(SYSDATE),1);

EXCEPTION
   WHEN OTHERS THEN
     rlog('Error in procedure worker : Error : ' || SQLERRM,2);
     RAISE;
END WORKER;

/*******************************************************************************
  Procedure:   launch_worker
  Description: This Function is used to spawn requests . It returns the spawned
               request id
  Parameters:
   p_worker - current worker number
   p_phase  - identifier of the sub-stage
   p_recs_processed - number or records processed by the current worker
*******************************************************************************/

FUNCTION launch_worker(p_worker_no IN NUMBER,
                       p_phase IN NUMBER,
                       p_no_of_workers IN NUMBER) RETURN NUMBER IS

   l_request_id NUMBER;

BEGIN

  --rlog('Start of the procedure launch_worker for worker ' ||p_worker_no||' at : ' ||
		--   fnd_date.date_to_displayDT(SYSDATE),2);

  fnd_profile.put('CONC_SINGLE_THREAD','N');

  DECLARE
   l_oki_schema  VARCHAR2(30);
   l_status      VARCHAR2(30);
   l_industry    VARCHAR2(30);
  BEGIN
  	 IF (FND_INSTALLATION.GET_APP_INFO(
              application_short_name => 'OKI'
            , status                 => l_status
            , industry               => l_industry
            , oracle_schema          => l_oki_schema)) THEN

     l_request_id := FND_REQUEST.SUBMIT_REQUEST(l_oki_schema,
                                             'OKI_DBI_SUB_WORKER',
                                             NULL,
                                             NULL,
                                             FALSE,
                                             p_worker_no,
                                             p_phase,
                                             p_no_of_workers);
     END IF;

  EXCEPTION
     WHEN OTHERS THEN
       rlog('Worker exception is ' || SQLERRM,2);
  END;


  -- if the submission of the request fails , abort the program
  IF (l_request_id = 0) THEN
     rlog('Error in launching child workers',2);
     RAISE G_CHILD_PROCESS_ISSUE;
  END IF;
  rlog('Request ID of the sub-worker launched : ' || l_request_id,2);
  RETURN l_request_id;

EXCEPTION
  WHEN OTHERS THEN
    rlog('Error in launch_worker : Error : ' || sqlerrm,2);
    RAISE;
END LAUNCH_WORKER;


/*******************************************************************************
  Procedure:   delta_changes
  Description: This procedure is used to find out renewal and original
               delta changes
  Parameters:
   p_worker - current worker number
   p_no_of_workers  - the total number of workers requested by the user
   p_recs_processed - number or records processed by the current worker
*******************************************************************************/
PROCEDURE delta_changes(
                         p_worker         IN  NUMBER
                       , p_no_of_workers  IN  NUMBER
                       , p_recs_processed OUT NOCOPY NUMBER
                       )
IS
l_location VARCHAR2(1000);
l_count NUMBER;

BEGIN
	     l_location := ' populating renewal increments table ' ;
       rlog('Populating renewal incremental table OKI_DBI_REN_INC due to ''Delta Changes'': '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

      /* Delta Changes */
      INSERT INTO  OKI_DBI_REN_INC
      (
         cle_id
       , r_cle_id
       , worker_number
      )
      (SELECT /*+ ordered index(ch) use_nl(al) */
               al.cle_id
             , al.r_cle_id
             , MOD(ROWNUM-1,p_no_of_workers)+1 worker_number
      FROM   oki_dbi_cle_b_old ch
           , oki_dbi_cle_b al
      WHERE ch.worker_number = p_worker
        AND ch.cle_id = al.r_cle_id);

      l_count := SQL%ROWCOUNT;
      rlog( 'Number of lines inserted into OKI_DBI_REN_INC due to ''Delta Changes'' is '
                                                          ||TO_CHAR(l_count),2);
      rlog('Load of renewal incremental table OKI_DBI_REN_INC due to ''Delta Changes'' completed: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;
      COMMIT;

  	  l_location := ' populating original increments table ' ;
      rlog('Populating original incremental table OKI_DBI_PREV_INC due to ''Delta Changes'': '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

      /* Delta Changes */
      INSERT INTO  OKI_DBI_PREV_INC
       (
          p_cle_id
        , cle_id
        , worker_number
       )
        (SELECT  s.p_cle_id,
                 s.cle_id ,
                 s.worker_number
                 FROM
       (SELECT /*+ ordered index(ch) use_nl(al) */
                al.cle_id p_cle_id
              , al.r_cle_id cle_id
              , MOD(ROWNUM-1,p_no_of_workers)+1 worker_number
      FROM   oki_dbi_cle_b_old ch
           , oki_dbi_cle_b al
      WHERE   ch.cle_id = al.cle_id
      AND    al.r_cle_id IS NOT NULL
      AND    ch.worker_number = p_worker)S);

      l_count := SQL%ROWCOUNT;
      rlog( 'Number of lines inserted into OKI_DBI_PREV_INC due to ''Delta Changes'' is ' ||TO_CHAR(l_count),2);
      rlog('Load of original incremental table OKI_DBI_PREV_INC due to ''Delta Changes'' completed: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;
      COMMIT;



EXCEPTION
	WHEN OTHERS THEN
     rlog('Error in delta_changes: ',0);
     rlog(SQLERRM ||'   '||SQLCODE, 0) ;
     rlog(l_location || ' Failed', 0) ;
     fnd_message.set_name(  application => 'FND'
                          , name        => 'CRM-DEBUG ERROR' ) ;
     fnd_message.set_token(
                                  token => 'ROUTINE'
                                , value => 'OKI_DBI_LOAD_CLEB_PVT.delta_changes ' ) ;
     bis_collection_utilities.put_line(fnd_message.get) ;
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;

END;

/*******************************************************************************
  Procedure:   update_staging
  Description: This Function is used to insert covered lines into
               oki_dbi_cle_b_old which have been identified for update
               in identifying renewal relationship change
  Parameters:
   p_worker - current worker number
   p_no_of_workers  - the total number of workers requested by the user
   p_recs_processed - number or records processed by the current worker
*******************************************************************************/
PROCEDURE update_staging( p_worker IN NUMBER
                        , p_no_of_workers IN NUMBER
                        , p_recs_processed OUT NOCOPY NUMBER
                        )
IS
l_location VARCHAR2(1000);
l_count NUMBER;

BEGIN


     rlog('Populating staging table OKI_DBI_CLE_B_OLD from OKI_DBI_CLE_B: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

     INSERT INTO oki_dbi_cle_b_old
       (       chr_id
             , cle_id
             , cle_creation_date
             , inv_organization_id
             , authoring_org_id
             , application_id
             , customer_party_id
             , salesrep_id
             , price_negotiated
             , price_negotiated_f
             , price_negotiated_g
             , contract_number
             , contract_number_modifier
             , buy_or_sell
             , sts_code
             , trn_code
             , renewal_flag
             , date_signed
             , date_cancelled
             , start_date
             , end_date
             , date_terminated
             , effective_start_date
             , effective_end_date
             , trx_func_curr_rate
             , func_global_curr_rate
             , created_by
             , last_update_login
             , creation_date
             , last_updated_by
             , last_update_date
             , security_group_id
             , root_lty_code
             , resource_group_id
             , resource_id
             , sle_id
             , service_item_id
             , covered_item_id
             , quantity
             , uom_code
             , grace_end_date
             , expected_close_date
             , win_percent
             , price_negotiated_sg
             , scs_code
             , hstart_date
             , hend_date
             , func_sglobal_curr_rate
             , request_id
             , program_login_id
             , program_application_id
             , program_id
             , covered_item_org_id
             , ubt_amt
             , credit_amt
             , credit_amt_f
             , credit_amt_g
             , ubt_amt_f
             , credit_amt_sg
             , override_amt
             , ubt_amt_g
             , ubt_amt_sg
             , override_amt_f
             , override_amt_g
             , override_amt_sg
             , supp_credit
             , supp_credit_f
             , supp_credit_g
             , supp_credit_sg
             , term_flag
             , renewal_type
             , annualization_factor
             , price_negotiated_a
             , ubt_amt_a
             , credit_amt_a
             , override_amt_a
             , supp_credit_a
             , worker_number
             , gsd_flag
             /* Added the following columns for bug 4227245 */
                , p_chr_id
                , p_cle_id
                , p_price_negotiated
                , p_price_negotiated_f
                , p_price_negotiated_g
                , p_price_negotiated_sg
                , p_grace_end_date
                , p_ubt_amt
                , p_ubt_amt_f
                , p_ubt_amt_g
                , p_ubt_amt_sg
                , p_credit_amt
                , p_credit_amt_f
                , p_credit_amt_g
                , p_credit_amt_sg
                , p_override_amt
                , p_override_amt_f
                , p_override_amt_g
                , p_override_amt_sg
                , p_supp_credit
                , p_supp_credit_f
                , p_supp_credit_g
                , p_supp_credit_sg
                , p_end_date
                , p_term_flag
                , p_price_negotiated_a
                , p_ubt_amt_a
                , p_credit_amt_a
                , p_override_amt_a
                , p_supp_credit_a
                , r_chr_id
                , r_cle_id
                , r_date_signed
                , r_date_cancelled
		            , falsernwlyn
               /* End of Additions for bug 4227245 */
                , effective_active_date
                , effective_term_date
                , effective_expire_date
                , termination_entry_date
		            , curr_code
                , curr_code_f
                , hdr_order_number
                , hdr_sts_code
                , hdr_trn_code
                , hdr_renewal_type
                , hdr_date_approved
                , hdr_date_cancelled
                , hdr_date_terminated
                , hdr_creation_date
                , hdr_last_update_date
                , service_item_org_id
                , sl_line_number
                , sl_sts_code
                , sl_trn_code
                , sl_renewal_type
                , sl_start_date
                , sl_end_Date
                , sl_date_cancelled
                , sl_date_terminated
                , sl_creation_date
                , sl_last_update_date
                , order_number
                , unit_price_percent
                , unit_price
                , unit_price_f
                , unit_price_g
                , unit_price_sg
                , list_price
                , list_price_f
                , list_price_g
                , list_price_sg
                , duration_uom
                , duration_qty
                , cl_last_update_date
                , cov_prod_id
                , cov_prod_system_id
                , line_number
                , line_type
		            , hdr_bill_site_id
		            , hdr_ship_site_id
		            , hdr_acct_rule_id
		            , hdr_grace_end_Date
		            , hdr_date_Signed
	 , hdr_subsequent_renewal_type	/* Added  ER#5760744 */
	 , agreement_type_code  /* ER 6062516 */
   , agreement_name  /* ER 6062516 */
	 , negotiation_status   /*  ER#5950128 */
	 , reminder             /*  ER#5950128 */
	 , HDR_TERM_CANCEL_SOURCE /*  of ER 6684955 */
   , SL_TERM_CANCEL_SOURCE  /*  ER 6684955 */
        	)
      (SELECT /*+ ordered index(ren_inc) use_nl(b) cardinality(ren_inc,10) */
               b.chr_id
             , b.cle_id
             , b.cle_creation_date
             , b.inv_organization_id
             , b.authoring_org_id
             , b.application_id
             , b.customer_party_id
             , b.salesrep_id
             , b.price_negotiated
             , b.price_negotiated_f
             , b.price_negotiated_g
             , b.contract_number
             , b.contract_number_modifier
             , b.buy_or_sell
             , b.sts_code
             , b.trn_code
             , b.renewal_flag
             , b.date_signed
             , b.date_cancelled
             , b.start_date
             , b.end_date
             , b.date_terminated
             , b.effective_start_date
             , b.effective_end_date
             , b.trx_func_curr_rate
             , b.func_global_curr_rate
             , b.created_by
             , b.last_update_login
             , b.creation_date
             , b.last_updated_by
             , b.last_update_date
             , b.security_group_id
             , b.root_lty_code
             , b.resource_group_id
             , b.resource_id
             , b.sle_id
             , b.service_item_id
             , b.covered_item_id
             , b.quantity
             , b.uom_code
             , b.grace_end_date
             , b.expected_close_date
             , b.win_percent
             , b.price_negotiated_sg
             , b.scs_code
             , b.hstart_date
             , b.hend_date
             , b.func_sglobal_curr_rate
             , b.request_id
             , b.program_login_id
             , b.program_application_id
             , b.program_id
             , b.covered_item_org_id
             , b.ubt_amt
             , b.credit_amt
             , b.credit_amt_f
             , b.credit_amt_g
             , b.ubt_amt_f
             , b.credit_amt_sg
             , b.override_amt
             , b.ubt_amt_g
             , b.ubt_amt_sg
             , b.override_amt_f
             , b.override_amt_g
             , b.override_amt_sg
             , b.supp_credit
             , b.supp_credit_f
             , b.supp_credit_g
             , b.supp_credit_sg
             , b.term_flag
             , b.renewal_type
             , b.annualization_factor
             , b.price_negotiated_a
             , b.ubt_amt_a
             , b.credit_amt_a
             , b.override_amt_a
             , b.supp_credit_a
             , MOD(ROWNUM-1,p_no_of_workers)+1 worker_number
             , b.gsd_flag
       /* Added the following columns for bug 4227245 */
                , b.p_chr_id
                , b.p_cle_id
                , b.p_price_negotiated
                , b.p_price_negotiated_f
                , b.p_price_negotiated_g
                , b.p_price_negotiated_sg
                , b.p_grace_end_date
                , b.p_ubt_amt
                , b.p_ubt_amt_f
                , b.p_ubt_amt_g
                , b.p_ubt_amt_sg
                , b.p_credit_amt
                , b.p_credit_amt_f
                , b.p_credit_amt_g
                , b.p_credit_amt_sg
                , b.p_override_amt
                , b.p_override_amt_f
                , b.p_override_amt_g
                , b.p_override_amt_sg
                , b.p_supp_credit
                , b.p_supp_credit_f
                , b.p_supp_credit_g
                , b.p_supp_credit_sg
                , b.p_end_date
                , b.p_term_flag
                , b.p_price_negotiated_a
                , b.p_ubt_amt_a
                , b.p_credit_amt_a
                , b.p_override_amt_a
                , b.p_supp_credit_a
                , b.r_chr_id
                , b.r_cle_id
                , b.r_date_signed
                , b.r_date_cancelled
		            , b.falsernwlyn
                /* End of Additions for bug 4227245 */
                , b.effective_active_date
                , b.effective_term_date
                , b.effective_expire_date
                , b.termination_entry_date
		            , b.curr_code
                , b.curr_code_f
                , b.hdr_order_number
                , b.hdr_sts_code
                , b.hdr_trn_code
                , b.hdr_renewal_type
                , b.hdr_date_approved
                , b.hdr_date_cancelled
                , b.hdr_date_terminated
                , b.hdr_creation_date
                , b.hdr_last_update_date
                , b.service_item_org_id
                , b.sl_line_number
                , b.sl_sts_code
                , b.sl_trn_code
                , b.sl_renewal_type
                , b.sl_start_date
                , b.sl_end_Date
                , b.sl_date_cancelled
                , b.sl_date_terminated
                , b.sl_creation_date
                , b.sl_last_update_date
                , b.order_number
                , b.unit_price_percent
                , b.unit_price
                , b.unit_price_f
                , b.unit_price_g
                , b.unit_price_sg
                , b.list_price
                , b.list_price_f
                , b.list_price_g
                , b.list_price_sg
                , b.duration_uom
                , b.duration_qty
                , b.cl_last_update_date
                , b.cov_prod_id
                , b.cov_prod_system_id
                , b.line_number
                , b.line_type
		            , b.hdr_bill_site_id
		            , b.hdr_ship_site_id
		            , b.hdr_acct_rule_id
		            , b.hdr_grace_end_Date
		            , b.hdr_date_Signed
		, b.hdr_subsequent_renewal_type		/*  ER#5760744 */
	  , b.agreement_type_code  /* ER 6062516 */
	  , b.agreement_name  /* ER 6062516 */
		, b.negotiation_status   /* Added part of ER#5950128 */
		, b.reminder   /* Added part of ER#5950128 */
		, b.HDR_TERM_CANCEL_SOURCE   /* ER 6684955 */
    , b.SL_TERM_CANCEL_SOURCE   /* ER 6684955 */
        FROM oki_dbi_cle_del ren_inc ,
             oki_dbi_cle_b b
        WHERE b.cle_id = ren_inc.cle_id
          AND ren_inc.worker_number = p_worker
          AND NOT EXISTS
              (SELECT NULL
               FROM oki_dbi_cle_b_old old
               WHERE old.cle_id = b.cle_id)
      );

       l_count := SQL%ROWCOUNT;
       rlog( 'Number of lines inserted into OKI_DBI_CLE_B_OLD from OKI_DBI_CLE_B: '
                                                         ||TO_CHAR(l_count),2);
       rlog('Load of staging table OKI_DBI_CLE_B_OLD from OKI_DBI_CLE_B complete: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;
      COMMIT;

	p_recs_processed := NVL(l_count,0);

EXCEPTION
	WHEN OTHERS THEN
     rlog('Error in update_staging : ',0);
     rlog(SQLERRM ||'   '||SQLCODE, 0) ;
     rlog(l_location || ' Failed', 0) ;
     fnd_message.set_name(  application => 'FND'
                          , name        => 'CRM-DEBUG ERROR' ) ;
     fnd_message.set_token(
                                  token => 'ROUTINE'
                                , value => 'OKI_DBI_LOAD_CLEB_PVT.update_staging ' ) ;
     bis_collection_utilities.put_line(fnd_message.get) ;
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
END ;

/*******************************************************************************
  Procedure:   populate_prev_inc
  Description: Find renewal relationship changes for original contract lines.
               and update oki_dbi_prev_inc table
  Parameters:
   p_worker - current worker number
   p_no_of_workers  - the total number of workers requested by the user
   p_stage          - identifier of the stage
   p_recs_processed - number or records processed by the current worker
*******************************************************************************/
PROCEDURE populate_prev_inc(
                             p_worker         IN  NUMBER
                           , p_no_of_workers  IN  NUMBER
                           , p_stage          IN  NUMBER
                           , p_recs_processed OUT NOCOPY NUMBER

                           )
IS
l_location VARCHAR2(1000);
l_count NUMBER;

BEGIN
		/* Confirmed from OKS that renewed contracts cannot be deleted).
		Hence there is no need of processing deletes here*/

	  IF( p_stage = 1 ) THEN

      rlog('Populating original incremental table OKI_DBI_PREV_INC from OKI_DBI_REN_INC: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

      /* Changes to Operation Lines...Use the information Already found in
            the previous merge to get p_cle_id*/
      MERGE INTO  OKI_DBI_PREV_INC b
      USING
      (SELECT          rel.r_cle_id cle_id
                     , rel.cle_id   p_cle_id
                     , MOD(ROWNUM-1,p_no_of_workers)+1 worker_number
               FROM   oki_dbi_ren_inc rel
               WHERE rel.worker_number = p_worker
      )s
      ON (b.cle_id = s.cle_id)
      WHEN MATCHED THEN
       	UPDATE SET
             p_cle_id      =  s.p_cle_id
           , worker_number =  s.worker_number
      WHEN NOT MATCHED THEN
        INSERT  ( cle_id
                , p_cle_id
                , worker_number
                )  VALUES(
                  s.cle_id
                , s.p_cle_id
                , s.worker_number
                );

      l_count := SQL%ROWCOUNT;

      rlog( 'Number of lines inserted into OKI_DBI_PREV_INC from OKI_DBI_REN_INC: '
                                                         ||TO_CHAR(l_count),2);

      rlog('Load of original incremental table OKI_DBI_PREV_INC from OKI_DBI_REN_INC: '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

      COMMIT;

    ELSIF ( p_stage = 2 ) THEN

   rlog('Populating original incremental table OKI_DBI_PREV_INC for ''Intermediate Cancellations'': '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;

      /* Check for intermediate Cancellations*/
       MERGE INTO OKI_DBI_PREV_INC b
          USING
            (SELECT   cle_id
                    , p_cle_id
                    , worker_number
             FROM (SELECT /*+ ordered index(del) use_nl(cle) */
                           cle.cle_id,
                          NULL p_cle_id,
                          MOD(ROWNUM-1,p_no_of_workers)+1 worker_number
                    FROM oki_dbi_prev_inc del,
                         oki_dbi_cle_b cle
                    WHERE cle.p_cle_id = del.p_cle_id
                     AND  cle.cle_id   <> del.cle_id
                     AND  cle.p_cle_id IS NOT NULL
                     AND  del.worker_number = p_worker) s1
            ) s
          ON (b.cle_id = s.cle_id)
          WHEN MATCHED THEN
            UPDATE SET
                  worker_number = s.worker_number
				  , p_cle_id = s.p_cle_id
          WHEN NOT MATCHED THEN
            INSERT(
                     cle_id
                   , p_cle_id
                   , worker_number
            ) VALUES (
                     s.cle_id
                   , s.p_cle_id
                   , s.worker_number
            );

          l_count := SQL%ROWCOUNT;
      rlog( 'Number of lines inserted into OKI_DBI_REN_INC due to ''Intermediate Cancellations'' is '
                                                          ||TO_CHAR(l_count),2);

      rlog('Load of original incremental table OKI_DBI_PREV_INC for ''Intermediate Cancellations'' completed : '
         ||fnd_date.date_to_displayDT(sysdate), 1) ;
      COMMIT;

    END IF;
	  p_recs_processed := l_count;

EXCEPTION
	WHEN OTHERS THEN
     rlog('Error in populate_prev_inc: ',0);
     rlog(SQLERRM ||'   '||SQLCODE, 0) ;
     rlog(l_location || ' Failed', 0) ;
     fnd_message.set_name(  application => 'FND'
                          , name        => 'CRM-DEBUG ERROR' ) ;
     fnd_message.set_token(
                                  token => 'ROUTINE'
                                , value => 'OKI_DBI_LOAD_CLEB_PVT.populate_prev_inc ' ) ;
     bis_collection_utilities.put_line(fnd_message.get) ;
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR ;
END;



END OKI_DBI_LOAD_CLEB_PVT;

/
