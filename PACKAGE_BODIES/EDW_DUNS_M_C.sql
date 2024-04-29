--------------------------------------------------------
--  DDL for Package Body EDW_DUNS_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_DUNS_M_C" AS
/* $Header: poaphtpb.pls 115.20 2004/02/26 13:53:00 apalorka ship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 g_start_time  Date:=Null;

 Procedure Push(Errbuf       in out NOCOPY Varchar2,
                Retcode      in out NOCOPY Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_dimension_name   Varchar2(30) :='EDW_DUNS_M'  ;
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
 l_from_date            date;
 l_to_date              date;

Begin
  Errbuf :=NULL;
   Retcode:=0;

  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
  END IF;

  l_from_date := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  l_to_date := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

  EDW_DUNS_M_C.g_push_date_range1 := nvl(l_from_date,
                EDW_COLLECTION_UTIL.G_local_last_push_start_date -
                EDW_COLLECTION_UTIL.g_offset);

  EDW_DUNS_M_C.g_push_date_range2 := nvl(l_to_date,
                           EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

  edw_log.put_line( 'The collection range is from '||
        to_char(EDW_DUNS_M_C.g_push_date_range1,
                'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(EDW_DUNS_M_C.g_push_date_range2,
                'MM/DD/YYYY HH24:MI:SS'));

  edw_log.put_line(' ');
  edw_log.put_line('Pushing data');

  Push_EDW_DNB_TPRT();
  Push_EDW_DUNS_NUMBER_LSTG(EDW_DUNS_M_C.g_push_date_range1,
                            EDW_DUNS_M_C.g_push_date_range2);

  Push_EDW_DUNS_PARENT_LSTG(EDW_DUNS_M_C.g_push_date_range1,
                            EDW_DUNS_M_C.g_push_date_range2);

  Push_EDW_DUNS_DOMESTIC_LSTG(EDW_DUNS_M_C.g_push_date_range1,
                              EDW_DUNS_M_C.g_push_date_range2);

  Push_EDW_DUNS_HEADQTR_LSTG(EDW_DUNS_M_C.g_push_date_range1,
                             EDW_DUNS_M_C.g_push_date_range2);

  Push_EDW_DUNS_GLOBAL_LSTG(EDW_DUNS_M_C.g_push_date_range1,
                            EDW_DUNS_M_C.g_push_date_range2);

  Push_EDW_SICM_SIC_LSTG(EDW_DUNS_M_C.g_push_date_range1,
                         EDW_DUNS_M_C.g_push_date_range2);

  l_duration := sysdate - l_temp_date;

  edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
  edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
  EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, EDW_DUNS_M_C.g_exception_msg,
                             g_push_date_range1, g_push_date_range2);
commit;

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_DUNS_M_C.g_exception_msg  := l_exception_msg;
   rollback;

   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_DUNS_M_C.g_exception_msg,
                              g_push_date_range1, g_push_date_range2);

commit;
End Push;

Procedure Push_EDW_DNB_TPRT IS
  CURSOR c_vendors  IS
    select distinct Trade_Partner_FK, Name
    from EDW_TPRT_TPARTNER_LOC_LTC TPRT,
         POA_TPRT_INTERFACE dnb
    where (TPRT.TPartner_Loc_PK = dnb.Trading_Partner_PK);

  CURSOR c_dnb_failure IS
    select distinct FAILURE_IND
    from POA_TPRT_INTERFACE dnb
    where (FAILURE_IND IS NOT NULL);

  CURSOR c_dnb_high_risk IS
    select distinct HIGH_RISK_INDCATOR
    from POA_TPRT_INTERFACE dnb
    where (HIGH_RISK_INDCATOR IS NOT NULL);

  CURSOR c_dnb_minority_owned IS
    select distinct MINORITY_OWNED_IND
    from POA_TPRT_INTERFACE dnb
    where (MINORITY_OWNED_IND IS NOT NULL);

  CURSOR c_dnb_current_statement IS
    select distinct CURRENT_STATEMENT_TYPE
    from POA_TPRT_INTERFACE dnb
    where (CURRENT_STATEMENT_TYPE IS NOT NULL);

  CURSOR c_dnb_legal_status IS
    select distinct LEGAL_STATUS
    from POA_TPRT_INTERFACE dnb
    where (LEGAL_STATUS IS NOT NULL);

  CURSOR c_dnb_fire_disaster IS
    select distinct FIRE_DISASTER_IND
    from POA_TPRT_INTERFACE dnb
    where (FIRE_DISASTER_IND IS NOT NULL);

  CURSOR c_dnb_owns_rents IS
    select distinct OWNS_RENTS_IND
    from POA_TPRT_INTERFACE dnb
    where (OWNS_RENTS_IND IS NOT NULL);

  CURSOR c_dnb_history IS
    select distinct HISTORY
    from POA_TPRT_INTERFACE dnb
    where (HISTORY IS NOT NULL);

  CURSOR c_dnb_location_status IS
   select distinct LOCATION_STATUS_IND
    from POA_TPRT_INTERFACE dnb
    where (LOCATION_STATUS_IND IS NOT NULL);

  CURSOR c_dnb_oob IS
   select distinct OOB_IND
    from POA_TPRT_INTERFACE dnb
    where (OOB_IND IS NOT NULL);

  CURSOR c_dnb_criminal_proceedings IS
   select distinct CRIMINAL_PROCEEDINGS_IND
    from POA_TPRT_INTERFACE dnb
    where (CRIMINAL_PROCEEDINGS_IND IS NOT NULL);

  CURSOR c_dnb_bankruptcy IS
   select distinct BANKRUPTCY_IND
    from POA_TPRT_INTERFACE dnb
    where (BANKRUPTCY_IND IS NOT NULL);

  CURSOR c_dnb_business_moved IS
   select distinct BUSINESS_MOVED_IND
    from POA_TPRT_INTERFACE dnb
    where (BUSINESS_MOVED_IND IS NOT NULL);

BEGIN

  -- Update the lookup values in the Interface table
  edw_log.put_line('Updating dnb failure code');
  For lfailure in c_dnb_failure loop
     Update POA_TPRT_INTERFACE dnb
     set (FAILURE_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code = lfailure.FAILURE_IND) and
                (fnd.lookup_type = 'POA_DNB_FAILURE_IND')))
     where (dnb.FAILURE_IND = lfailure.FAILURE_IND);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set FAILURE_VALUE = FAILURE_IND
  where (FAILURE_VALUE IS NULL);

  edw_log.put_line('Updating Dnb High Risk Code');
  For lhigh_risk in c_dnb_high_risk loop
     Update POA_TPRT_INTERFACE dnb
     set (HIGH_RISK_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code = lhigh_risk.HIGH_RISK_INDCATOR) and
                (fnd.lookup_type = 'POA_DNB_HIGH_RISK_IND')))
     where (dnb.HIGH_RISK_INDCATOR = lhigh_risk.HIGH_RISK_INDCATOR);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set HIGH_RISK_VALUE = HIGH_RISK_INDCATOR
  where (HIGH_RISK_VALUE IS NULL);

  edw_log.put_line('Updating Minority Code');
  For lminority_owned in c_dnb_minority_owned loop
     Update POA_TPRT_INTERFACE dnb
     set (MINORITY_OWNED_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code = lminority_owned.MINORITY_OWNED_IND) and
                (fnd.lookup_type = 'POA_DNB_MINORITY_OWNED_TYPE')))
     where (dnb.MINORITY_OWNED_IND = lminority_owned.MINORITY_OWNED_IND);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set MINORITY_OWNED_VALUE = MINORITY_OWNED_IND
  where (MINORITY_OWNED_VALUE IS NULL);

  edw_log.put_line('Updating DNB Current Statement');
  For lcurrent_statement in c_dnb_current_statement loop
     Update POA_TPRT_INTERFACE dnb
     set (CURRENT_STATEMENT_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code =
                     lcurrent_statement.CURRENT_STATEMENT_TYPE) and
                (fnd.lookup_type = 'POA_DNB_CURRENT_STMT_TYPE')))
     where (dnb.CURRENT_STATEMENT_TYPE =
                lcurrent_statement.CURRENT_STATEMENT_TYPE);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set CURRENT_STATEMENT_VALUE = CURRENT_STATEMENT_TYPE
  where (CURRENT_STATEMENT_VALUE IS NULL);

  edw_log.put_line('Updating Legal Status');
  For llegal_status in c_dnb_legal_status loop
     Update POA_TPRT_INTERFACE dnb
     set (LEGAL_STATUS_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code = llegal_status.LEGAL_STATUS) and
                (fnd.lookup_type = 'POA_DNB_LEGAL_STATUS')))
     where (dnb.LEGAL_STATUS = llegal_status.LEGAL_STATUS);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set LEGAL_STATUS_VALUE = LEGAL_STATUS
  where (LEGAL_STATUS_VALUE IS NULL);

  edw_log.put_line('Updating Fire Disaster Code');
  For lfire_disaster in c_dnb_fire_disaster loop
     Update POA_TPRT_INTERFACE dnb
     set (FIRE_DISASTER_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code = lfire_disaster.FIRE_DISASTER_IND) and
                (fnd.lookup_type = 'POA_DNB_FIRE_DISASTER_IND')))
     where (dnb.FIRE_DISASTER_IND = lfire_disaster.FIRE_DISASTER_IND);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set FIRE_DISASTER_VALUE = FIRE_DISASTER_IND
  where (FIRE_DISASTER_VALUE IS NULL);

  edw_log.put_line('Updating DNB owns/Rents Code');
  For lowns_rents in c_dnb_owns_rents loop
     Update POA_TPRT_INTERFACE dnb
     set (OWNS_RENTS_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code = lowns_rents.OWNS_RENTS_IND) and
                (fnd.lookup_type = 'POA_DNB_OWNS_RENTS_IND')))
     where (dnb.OWNS_RENTS_IND = lowns_rents.OWNS_RENTS_IND);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set OWNS_RENTS_VALUE = OWNS_RENTS_IND
  where (OWNS_RENTS_VALUE IS NULL);

  edw_log.put_line('Updating History Code');
  For lhistory in c_dnb_history loop
     Update POA_TPRT_INTERFACE dnb
     set (HISTORY_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code = lhistory.HISTORY) and
                (fnd.lookup_type = 'POA_DNB_HISTORY_IND')))
     where (dnb.HISTORY = lhistory.HISTORY);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set HISTORY_VALUE = HISTORY
  where (HISTORY IS NULL);

  edw_log.put_line('Updating Location Status Code');
  For llocation_status in c_dnb_location_status loop
     Update POA_TPRT_INTERFACE dnb
     set (LOCATION_STATUS_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code = llocation_status.LOCATION_STATUS_IND) and
                (fnd.lookup_type = 'POA_DNB_LOCATION_STATUS')))
     where (dnb.LOCATION_STATUS_IND = llocation_status.LOCATION_STATUS_IND);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set LOCATION_STATUS_VALUE = LOCATION_STATUS_IND
  where (LOCATION_STATUS_VALUE IS NULL);

  edw_log.put_line('Updating DNB OOB');
  For loob in c_dnb_oob loop
     Update POA_TPRT_INTERFACE dnb
     set (OOB_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code = loob.OOB_IND) and
                (fnd.lookup_type = 'POA_DNB_OOB_IND')))
     where (dnb.OOB_IND = loob.OOB_IND);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set OOB_VALUE = OOB_IND
  where (OOB_VALUE IS NULL);

  edw_log.put_line('Updating Criminal Proceedings Code');
  For lcriminal_proceedings in c_dnb_criminal_proceedings loop
     Update POA_TPRT_INTERFACE dnb
     set (CRIMINAL_PROCEEDINGS_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code =
                    lcriminal_proceedings.CRIMINAL_PROCEEDINGS_IND) and
                (fnd.lookup_type = 'POA_DNB_CRIMINAL_PROCDN_IND')))
     where (dnb.CRIMINAL_PROCEEDINGS_IND =
                    lcriminal_proceedings.CRIMINAL_PROCEEDINGS_IND);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set CRIMINAL_PROCEEDINGS_VALUE = CRIMINAL_PROCEEDINGS_IND
  where (CRIMINAL_PROCEEDINGS_VALUE IS NULL);

  edw_log.put_line('Updating Bankruptcy Code');
  For lbankruptcy in c_dnb_bankruptcy loop
     Update POA_TPRT_INTERFACE dnb
     set (BANKRUPTCY_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code = lbankruptcy.BANKRUPTCY_IND) and
                (fnd.lookup_type = 'POA_DNB_BANKRUPTCY_IND')))
     where (dnb.BANKRUPTCY_IND = lbankruptcy.BANKRUPTCY_IND);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set BANKRUPTCY_VALUE = BANKRUPTCY_IND
  where (BANKRUPTCY_VALUE IS NULL);

  edw_log.put_line('Updating Business Moved Code');
  For lbusiness_moved in c_dnb_business_moved loop
     Update POA_TPRT_INTERFACE dnb
     set (BUSINESS_MOVED_VALUE) =
         (select Description
         from fnd_lookups fnd
         where ((fnd.lookup_code = lbusiness_moved.BUSINESS_MOVED_IND) and
                (fnd.lookup_type = 'POA_DNB_BUSINESS_MOVED_IND')))
     where (dnb.BUSINESS_MOVED_IND = lbusiness_moved.BUSINESS_MOVED_IND);
  end loop;

  Update POA_TPRT_INTERFACE dnb
  set BUSINESS_MOVED_VALUE = BUSINESS_MOVED_IND
  where (BUSINESS_MOVED_VALUE IS NULL);

  -- Update Trading Partner Vendor Sites (Lowest Level)
  edw_log.put_line('Starting Push_EDW_DNB_TPRT');
  edw_log.put_line('Update Trading Partner Vendor Sites (Lowest Level)');

  g_start_time := sysdate;

  Update POA_DNB_TRD_PRTNR poa
  set (TRADING_PARTNER_PK,
       TRADING_PARTNER_NAME,
       DUNS,
       SIC_CODE,
       DNB_Update_Date,
       LAST_UPDATE_DATE) =
  (select TRADING_PARTNER_PK,
          TRADING_PARTNER_NAME,
          DUNS,
          SIC_CODE_1,
          sysdate,
          sysdate from POA_TPRT_INTERFACE dnb
          where (poa.TRADING_PARTNER_PK = dnb.TRADING_PARTNER_PK))
  where TRADING_PARTNER_PK IN
        (select TRADING_PARTNER_PK
         from POA_TPRT_INTERFACE dnb
         where ((poa.TRADING_PARTNER_PK = dnb.TRADING_PARTNER_PK) and
                ((poa.DUNS <> dnb.DUNS) OR
                 (poa.SIC_CODE <> dnb.SIC_CODE_1))));

  edw_log.put_line('Update of Trading Partner Vendor Sites complete');
  edw_log.put_line('Insert Trading Partner Vendor Sites (Lowest Level)');
  insert into POA_DNB_TRD_PRTNR poa (
         TRADING_PARTNER_PK,
         TRADING_PARTNER_NAME,
         DUNS,
         SIC_CODE,
         DNB_Update_Date,
         LAST_UPDATE_DATE,
         CREATION_DATE)
   select TRADING_PARTNER_PK,
          TRADING_PARTNER_NAME,
          DUNS,
          SIC_CODE_1,
          sysdate,
          sysdate,
          sysdate from POA_TPRT_INTERFACE dnb
    where NOT EXISTS
          (select 'X' FROM
           POA_DNB_TRD_PRTNR pdtp
           where ltrim(rtrim(pdtp.TRADING_PARTNER_PK)) IS NOT NULL
           and dnb.TRADING_PARTNER_PK = pdtp.TRADING_PARTNER_PK);

  edw_log.put_line('Insert of Trading Partner Vendor Sites complete');

/*
  --  Commenting this portion out for bug 2377655 (Ford)
  --  This cursor is taking the maximum amount of time
  --  and not returning any rows in their trace file
  --  Looks like the vendor_site cursor is not going to return any
  --  rows since tprt.tpartner_loc_pk and lvendor.trade_partner_fk
  --  are not going to match because of the way there are constructed
  --  Also, the duns interface table poa_tprt_interface has only
  --  supplier site level records

  -- Update Trading Partner Vendors (Higher levels)
  edw_log.put_line('Update Trading Partner Vendors (Higher levels)');
  BEGIN
    For lvendor in c_vendors loop
      DECLARE
        CURSOR c_vendor_site IS
           select Trade_Partner_FK, Global_Ult_Duns
           from EDW_TPRT_TPARTNER_LOC_LTC TPRT,
                POA_TPRT_INTERFACE dnb
           where ((TPRT.TPartner_Loc_PK = lvendor.Trade_Partner_FK) and
                  (dnb.Trading_Partner_PK = TPRT.Trade_Partner_FK));
      BEGIN
        For lvsite in c_vendor_site loop
          Update POA_DNB_TRD_PRTNR poa
          set TRADING_PARTNER_PK = lvendor.Trade_Partner_FK,
              TRADING_PARTNER_NAME = lvendor.Name,
              DUNS = lvsite.Global_Ult_Duns,
              DNB_Update_Date = sysdate
          where Trading_Partner_PK IN
                (select Trade_Partner_FK
                 from EDW_TPRT_TPARTNER_LOC_LTC TPRT,
                      POA_TPRT_INTERFACE dnb
                 where ((poa.TRADING_PARTNER_PK = lvendor.Trade_Partner_FK) and
                        (poa.DUNS <> lvsite.Global_Ult_Duns)));

          edw_log.put_line('Update of Trading Partner Vendor complete');
          edw_log.put_line('Insert Trading Partner Vendors (Higher levels)');

          Insert into POA_DNB_TRD_PRTNR poa (
                 TRADING_PARTNER_PK,
                 TRADING_PARTNER_NAME,
                 DUNS,
                 DNB_Update_Date)
          select lvendor.Trade_Partner_FK,
                 lvendor.Name,
                 lvsite.Global_Ult_Duns,
                 sysdate
          from POA_DNB_TRD_PRTNR
          where NOT EXISTS
                (select 'X'
                 from POA_DNB_TRD_PRTNR pdtp
                 where ltrim(rtrim(Trading_Partner_PK)) IS NOT NULL
                 and pdtp.Trading_Partner_PK = lvendor.Trade_Partner_FK);
          edw_log.put_line('Insert of Trading Partner Vendor complete');
          exit;
        END LOOP;
      END;
    END LOOP;
  END Push_EDW_DNB_TPRT;
*/
  -- Update the SIC Code Combination Table
  edw_log.put_line('Updating SIC Code');
  Update POA_DNB_SIC_CODE poa
  set (SIC_Code,
       SIC_Description,
       DNB_Update_Date) =
  (select distinct SIC_CODE_1,
          SIC_1_DESCRIPTION,
          sysdate from POA_TPRT_INTERFACE dnb
          where (poa.SIC_Code = dnb.SIC_CODE_1))
  where SIC_Code IN
        (select SIC_CODE_1
         from POA_TPRT_INTERFACE dnb
         where ((poa.SIC_Code = dnb.SIC_CODE_1) and
                (poa.SIC_Description <> dnb.SIC_1_DESCRIPTION)));

  edw_log.put_line('Inserting SIC Code');
  insert into POA_DNB_SIC_CODE poa (
         SIC_Code,
         SIC_Description,
         DNB_Update_Date)
  (select distinct SIC_CODE_1,
          SIC_1_DESCRIPTION,
          sysdate from POA_TPRT_INTERFACE dnb
          where NOT EXISTS
                (select 'X'
                 from POA_DNB_SIC_CODE pdsc
                 where ltrim(rtrim(SIC_Code)) IS NOT NULL
                 and dnb.sic_code_1 = pdsc.sic_code));


  edw_log.put_line('Completed Push_EDW_DNB_TPRT');
 Exception When others then
   raise;
commit;

END Push_EDW_DNB_TPRT;



Procedure Push_EDW_DUNS_NUMBER_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW__DUNS_NUMBER_LSTG');
   l_date1 := p_from_date;
   l_date2 := p_to_date;

   Insert Into
   EDW_DUNS_NUMBER_LSTG(
      DUNS_NUM_PK,
      DUNS_NUM_DP,
      NAME,
      DUNS_NUMBER,
      COMPANY_NAME,
      ADDRESS,
      CITY,
      STATE_PROV,
      ZIP_CODE,
      TELEPHONE,
      COUNTRY,
      CEO_NAME,
      CEO_TITLE,
      LEGAL_STATUS,
      LOCATION_STATUS,
      HQ_FLAG,
      EMPLOYEES_TOTAL,
      CONTROL_YEAR,
      SIC_CODE1,
      SIC_CODE2,
      SIC1_DESCRIPTION,
      OOB_IND,
      CONG_DIST_CODE1,
      CONG_DIST_CODE2,
      CONG_DIST_CODE3,
      IMPORT_FLAG,
      EXPORT_FLAG,
      FAILURE_IND,
      BANKRUPTCY_IND,
      HIGH_RISK_IND,
      SUITS_COUNT,
      LIENS_COUNT,
      JUDGMENTS_COUNT,
      HQ_DUNS,
      HQ_NAME,
      HQ_ADDRESS,
      HQ_CITY,
      HQ_STATE_PROV,
      HQ_POSTAL_CODE,
      HQ_COUNTRY,
      HQ_TELEPHONE,
      PARENT_DUNS,
      PARENT_NAME,
      PARENT_ADDRESS,
      PARENT_CITY,
      PARENT_STATE_PROV,
      PARENT_POSTAL_CODE,
      PARENT_COUNTRY,
      PARENT_TELEPHONE,
      GLOBAL_ULT_DUNS,
      GLOBAL_ULT_NAME,
      GLOBAL_ULT_ADDRESS,
      GLOBAL_ULT_CITY,
      GLOBAL_ULT_STATE_PROV,
      GLOBAL_ULT_POSTAL_CODE,
      GLOBAL_ULT_COUNTRY,
      GLOBAL_ULT_TELEPHONE,
      DOMESTIC_ULT_DUNS,
      DOMESTIC_ULT_NAME,
      DOMESTIC_ULT_ADDRESS,
      DOMESTIC_ULT_CITY,
      DOMESTIC_ULT_STATE_PROV,
      DOMESTIC_ULT_POSTAL_CODE,
      DOMESTIC_ULT_COUNTRY,
      DOMESTIC_ULT_TELEPHONE,
      DNB_RATING,
      DELINQUENCY_SCORE,
      FAILURE_SCORE,
      FAILURE_NATL_PCNT_RANK,
      FAILURE_INDU_PCNT_RANK,
      FAILURE_NATL_INCE_DFT,
      FAILURE_INDU_INCE_DFT,
      PAYDEX_CURRENT,
      LABOR_SURPLUS_FLAG,
      DEBARMENT_FLAG,
      MINORITY_OWNED_FLAG,
      MINORITY_OWNED_TYPE,
      WOMAN_OWNED_FLAG,
      DISADVANTAGED_FLAG,
      SMALL_BUSINESS_FLAG,
      SDB_ENTRANCE_DATE,
      SDB_EXIT_DATE,
      ISO9000_REGISTRATION,
      FEDERAL_TAX_ID,
      CURRENT_STATEMENT_DATE,
      CURRENT_STATEMENT_TYPE,
      SALES,
      CASH,
      ACCOUNTS_RECEIVABLES,
      INVENTORY,
      CURRENT_ASSETS,
      TOTAL_ASSETS,
      CURRENT_LIABILITIES,
      TOTAL_DEBT,
      NET_WORTH,
      REPORT_BASE_DATE,
      DNB_LAST_UPDATE_DATE,
      HIGH_CREDIT,
      AVERAGE_HIGH_CREDIT,
      BUSINESS_MOVED_IND,
      CRIMINAL_PROCEEDINGS_IND,
      FIRE_DISASTER_IND,
      OWNS_RENTS_IND,
      HISTORY,
      NEGATIVE_PAYMENTS,
      PAYDEX_NORM,
      PAYDEX_PRIOR_Q1,
      PAYDEX_PRIOR_Q2,
      PAYDEX_PRIOR_Q3,
      SLOW_PAYMENTS,
      TOTAL_PAYMENTS,
      NET_PROFIT,
      PREV_CURRENT_ASSETS,
      PREV_CURRENT_LIABILITIES,
      PREV_NET_WORTH,
      PREV_SALES,
      PREV_STATEMENT_DATE,
      PREV_STATEMENT_TYPE,
      PREV_TOTAL_ASSETS,
      TRADE_STYLE,
      DOMESTIC_ULT_FK,
      HQ_FK,
      PARENT_FK,
      INSTANCE,
      LAST_UPDATE_DATE,
      COLLECTION_STATUS,
      UPDATE_FACT_FLAG)
   select
      distinct dnb.DUNS,
      COMPANY_NAME || '-' || dnb.DUNS,
      COMPANY_NAME || '-' || dnb.DUNS,
      dnb.DUNS,
      COMPANY_NAME,
      ADDRESS,
      CITY,
      STATE,
      ZIP,
      TELEPHONE,
      COUNTRY,
      CEO_NAME,
      CEO_TITLE,
      LEGAL_STATUS_VALUE,
      LOCATION_STATUS_VALUE,
      HQ_IND,
      EMPLOYEES_TOTAL,
      CONTROL_YEAR,
      SIC_CODE_1,
      SIC_CODE_2,
      SIC_1_DESCRIPTION,
      OOB_VALUE,
      CONG_DIST_CODE_1,
      CONG_DIST_CODE_2,
      CONG_DIST_CODE_3,
      IMPORT_IND,
      EXPORT_IND,
      FAILURE_VALUE,
      BANKRUPTCY_IND,
      HIGH_RISK_VALUE,
      SUITS_COUNT,
      LIENS_COUNT,
      JUDGMENTS_COUNT,
      HQ_DUNS,
      HQ_NAME,
      HQ_ADDRESS,
      HQ_CITY,
      HQ_STATE,
      HQ_POSTAL_CODE,
      HQ_COUNTRY,
      HQ_TELEPHONE,
      PARENT_DUNS,
      PARENT_NAME,
      PARENT_ADDRESS,
      PARENT_CITY,
      PARENT_STATE,
      PARENT_POSTAL_CODE,
      PARENT_COUNTRY,
      PARENT_TELEPHONE,
      GLOBAL_ULT_DUNS,
      GLOBAL_ULT_NAME,
      GLOBAL_ULT_ADDRESS,
      GLOBAL_ULT_CITY,
      GLOBAL_ULT_STATE,
      GLOBAL_ULT_POSTAL_CODE,
      GLOBAL_ULT_COUNTRY,
      GLOBAL_ULT_TELEPHONE,
      DOMESTIC_ULT_DUNS,
      DOMESTIC_ULT_NAME,
      DOMESTIC_ULT_ADDRESS,
      DOMESTIC_ULT_CITY,
      DOMESTIC_ULT_STATE,
      DOMESTIC_ULT_POSTAL_CODE,
      DOMESTIC_ULT_COUNTRY,
      DOMESTIC_ULT_TELEPHONE,
      DNB_RATING,
      CREDIT_SCORE,
      FSS_SER_SCORE,
      FSS_NATIONAL_RANK,
      FSS_INDSTRY_RANK,
      FSS_NATL_INC_OF_DEFAULT,
      FSS_IND_INC_OF_DEFAULT,
      PAYDEX_CURRENT,
      LABOR_SURPLUS_IND,
      DEBARMENT_IND,
      MINORITY_OWNED_VALUE,
      dnb.Minority_Owned_Type,
      WOMAN_OWNED_IND,
      DISADVANTAGED_IND,
      SMALL_BUSINESS_IND,
      decode(ltrim(rtrim(SDB_ENTRANCE_DATE)),
             '', NULL,
             to_date(SDB_ENTRANCE_DATE, 'YYYYMMDD')),
      decode(ltrim(rtrim(SDB_EXIT_DATE)),
             '', NULL,
             to_date(SDB_EXIT_DATE, 'YYYYMMDD')),
      ISO9000_REGISTRATION,
      FEDERAL_TAX_ID,
      decode(ltrim(rtrim(CURRENT_STATEMENT_DATE)),
             '', NULL,
             to_date(CURRENT_STATEMENT_DATE, 'YYMMDD')),
      CURRENT_STATEMENT_VALUE,
      SALES,
      CASH,
      ACCOUNTS_REC,
      INVENTORY,
      CURRENT_ASSETS,
      TOTAL_ASSETS,
      CURRENT_LIABILITIES,
      TOTAL_DEBT,
      NET_WORTH,
      decode(ltrim(rtrim(REPORT_BASE_DATE)),
             '', NULL,
             to_date(REPORT_BASE_DATE, 'YYMMDD')),
      decode(ltrim(rtrim(DNB_LAST_UPDATE_DATE)),
             '', NULL,
             to_date(DNB_LAST_UPDATE_DATE, 'YYMMDD')),
      HIGH_CREDIT,
      AVERAGE_HIGH_CREDIT,
      BUSINESS_MOVED_IND,
      CRIMINAL_PROCEEDINGS_VALUE,
      FIRE_DISASTER_VALUE,
      OWNS_RENTS_VALUE,
      HISTORY_VALUE,
      NEGATIVE_PAYMENTS,
      PAYDEX_NORM,
      PAYDEX_PRIOR_Q1,
      PAYDEX_PRIOR_Q2,
      PAYDEX_PRIOR_Q3,
      SLOW_PAYMENTS,
      TOTAL_PAYMENTS,
      NET_PROFIT,
      PREVIOUS_CURRENT_ASSETS,
      PREV_CURRENT_LIABILITIES,
      PREV_NET_WORTH,
      PREV_SALES,
      decode(ltrim(rtrim(PREV_STATEMENT_DATE)),
             '', NULL,
             to_date(PREV_STATEMENT_DATE, 'YYMMDD')),
      dnb.Prev_Statement_Type,
      PREV_TOTAL_ASSETS,
      TRADE_STYLE,
      NVL(ltrim(rtrim(DOMESTIC_ULT_DUNS)), GLOBAL_ULT_DUNS),
      NVL(ltrim(rtrim(HQ_DUNS)), GLOBAL_ULT_DUNS),
      NVL(ltrim(rtrim(PARENT_DUNS)), GLOBAL_ULT_DUNS),
      NULL,
      sysdate,
      'READY',
      decode(greatest(poa.dnb_update_date,g_start_time), poa.dnb_update_date, decode(greatest(poa.dnb_update_date, sysdate), sysdate, 'Y', 'N'), 'N')
   from POA_TPRT_INTERFACE dnb,
        POA_DNB_TRD_PRTNR poa
   where (dnb.TRADING_PARTNER_PK = poa.TRADING_PARTNER_PK);

   l_rows_inserted := sql%rowcount;

   EDW_DUNS_M_C.g_row_count := EDW_DUNS_M_C.g_row_count + l_rows_inserted ;

   edw_log.put_line('Commiting records for EDW_DUNS_NUMBER_LSTG');
   commit;

   edw_log.put_line('Completed Push_EDW_DUNS_NUMBER_LSTG');
 Exception When others then
   raise;
commit;
END Push_EDW_DUNS_NUMBER_LSTG;





Procedure Push_EDW_DUNS_PARENT_LSTG(p_from_date IN date,
                                    p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_DUNS_PARENT_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
   EDW_DUNS_PARENT_LSTG(
      PARENT_PK,
      PARENT_DP,
      NAME,
      DUNS_NUMBER,
      ADDRESS,
      CITY,
      STATE_PROV,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      GLOBAL_ULT_FK,
      INSTANCE,
      LAST_UPDATE_DATE,
      COLLECTION_STATUS)
   select
       distinct PARENT_DUNS,
       PARENT_NAME || '-' || PARENT_DUNS,
       PARENT_NAME || '-' || PARENT_DUNS,
       PARENT_DUNS,
       PARENT_ADDRESS,
       PARENT_CITY,
       PARENT_STATE,
       PARENT_POSTAL_CODE,
       PARENT_COUNTRY,
       PARENT_TELEPHONE,
       NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
       NULL,
       sysdate,
       'READY'
    from POA_TPRT_INTERFACE dnb
    where EXISTS (select 'X'
                  from POA_TPRT_INTERFACE pti
                  where ltrim(rtrim(PARENT_DUNS)) IS NOT NULL
                  and dnb.PARENT_DUNS = pti.PARENT_DUNS);

   l_rows_inserted := sql%rowcount;

   -- Push up the DUNS No. if its doesnt have any Parent
   Insert Into
   EDW_DUNS_PARENT_LSTG(
      PARENT_PK,
      PARENT_DP,
      NAME,
      DUNS_NUMBER,
      ADDRESS,
      CITY,
      STATE_PROV,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      GLOBAL_ULT_FK,
      INSTANCE,
      LAST_UPDATE_DATE,
      COLLECTION_STATUS)
   select
      distinct dnb.DUNS,
      COMPANY_NAME || '-' || dnb.DUNS,
      COMPANY_NAME || '-' || dnb.DUNS,
      dnb.DUNS,
      ADDRESS,
      CITY,
      STATE,
      ZIP,
      COUNTRY,
      TELEPHONE,
      NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
       NULL,
      sysdate,
      'READY'
    from POA_TPRT_INTERFACE dnb
    where (ltrim(rtrim(PARENT_DUNS)) IS NULL);

   l_rows_inserted := l_rows_inserted + sql%rowcount;
   EDW_DUNS_M_C.g_row_count := EDW_DUNS_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_DUNS_PARENT_LSTG');
   commit;

   edw_log.put_line('Completed Push_EDW_DUNS_PARENT_LSTG');
 Exception When others then
   raise;
   commit;
END Push_EDW_DUNS_PARENT_LSTG;



Procedure Push_EDW_DUNS_DOMESTIC_LSTG(p_from_date IN date,
                                      p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_DUNS_DOMESTIC_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
   EDW_DUNS_DOMESTIC_LSTG(
      DOMESTIC_ULT_PK,
      DOMESTIC_ULT_DP,
      NAME,
      DUNS_NUMBER,
      ADDRESS,
      CITY,
      STATE_PROV,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      GLOBAL_ULT_FK,
      INSTANCE,
      LAST_UPDATE_DATE ,
      COLLECTION_STATUS)
   select
       distinct DOMESTIC_ULT_DUNS,
       DOMESTIC_ULT_NAME  || '-' || DOMESTIC_ULT_DUNS,
       DOMESTIC_ULT_NAME  || '-' || DOMESTIC_ULT_DUNS,
       DOMESTIC_ULT_DUNS,
       DOMESTIC_ULT_ADDRESS,
       DOMESTIC_ULT_CITY,
       DOMESTIC_ULT_STATE,
       DOMESTIC_ULT_POSTAL_CODE,
       DOMESTIC_ULT_COUNTRY,
       DOMESTIC_ULT_TELEPHONE,
       NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
       NULL,
       sysdate,
       'READY'
    from POA_TPRT_INTERFACE dnb
    where EXISTS (select 'X'
                  from POA_TPRT_INTERFACE pti
                  where ltrim(rtrim(DOMESTIC_ULT_DUNS)) IS NOT NULL
                  and dnb.DOMESTIC_ULT_DUNS = pti.DOMESTIC_ULT_DUNS);

   l_rows_inserted := sql%rowcount;

   Insert Into
   EDW_DUNS_DOMESTIC_LSTG(
      DOMESTIC_ULT_PK,
      DOMESTIC_ULT_DP,
      NAME,
      DUNS_NUMBER,
      ADDRESS,
      CITY,
      STATE_PROV,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      GLOBAL_ULT_FK,
      INSTANCE,
      LAST_UPDATE_DATE ,
      COLLECTION_STATUS)
   select
      distinct dnb.DUNS,
      COMPANY_NAME || '-' || dnb.DUNS,
      COMPANY_NAME || '-' || dnb.DUNS,
      dnb.DUNS,
      ADDRESS,
      CITY,
      STATE,
      ZIP,
      COUNTRY,
      TELEPHONE,
      NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
      NULL,
      sysdate,
      'READY'
    from POA_TPRT_INTERFACE dnb
    where (ltrim(rtrim(DOMESTIC_ULT_DUNS)) IS NULL);

   EDW_DUNS_M_C.g_row_count := EDW_DUNS_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_DUNS_DOMESTIC_LSTG');
   commit;

   edw_log.put_line('Completed Push_EDW_DUNS_DOMESTIC_LSTG');
 Exception When others then
   raise;
   commit;
END Push_EDW_DUNS_DOMESTIC_LSTG;



Procedure Push_EDW_DUNS_GLOBAL_LSTG(p_from_date IN date,
                                    p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_DUNS_GLOBAL_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
   EDW_DUNS_GLOBAL_LSTG(
      GLOBAL_ULT_PK,
      GLOBAL_ULT_DP,
      NAME,
      DUNS_NUMBER,
      ADDRESS,
      CITY,
      STATE_PROV,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      ALL_FK,
      INSTANCE,
      LAST_UPDATE_DATE,
      COLLECTION_STATUS)
   select
       distinct GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME || '-' || GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME || '-' || GLOBAL_ULT_DUNS,
       GLOBAL_ULT_DUNS,
       GLOBAL_ULT_ADDRESS,
       GLOBAL_ULT_CITY,
       GLOBAL_ULT_STATE,
       GLOBAL_ULT_POSTAL_CODE,
       GLOBAL_ULT_COUNTRY,
       GLOBAL_ULT_TELEPHONE,
       'ALL',
       NULL,
       sysdate,
       'READY'
    from POA_TPRT_INTERFACE dnb;

   l_rows_inserted := sql%rowcount;
   EDW_DUNS_M_C.g_row_count := EDW_DUNS_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_DUNS_GLOBAL_LSTG');
   commit;

   -- Push Global Ultimate to all lower level if needed
   Insert into EDW_DUNS_DOMESTIC_LSTG(
      DOMESTIC_ULT_PK,
      DOMESTIC_ULT_DP,
      NAME,
      DUNS_NUMBER,
      ADDRESS,
      CITY,
      STATE_PROV,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      GLOBAL_ULT_FK,
      INSTANCE,
      LAST_UPDATE_DATE ,
      COLLECTION_STATUS)
   select
      distinct GLOBAL_ULT_DUNS,
      GLOBAL_ULT_NAME || '-' || GLOBAL_ULT_DUNS,
      GLOBAL_ULT_NAME || '-' || GLOBAL_ULT_DUNS,
      GLOBAL_ULT_DUNS,
      GLOBAL_ULT_ADDRESS,
      GLOBAL_ULT_CITY,
      GLOBAL_ULT_STATE,
      GLOBAL_ULT_POSTAL_CODE,
      GLOBAL_ULT_COUNTRY,
      GLOBAL_ULT_TELEPHONE,
      NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
      NULL,
      sysdate,
      'READY'
    from POA_TPRT_INTERFACE dnb
    where (NOT EXISTS (select 'X'
                       from POA_TPRT_INTERFACE pti
                       where ltrim(rtrim(DOMESTIC_ULT_DUNS)) IS NOT NULL
                       and dnb.GLOBAL_ULT_DUNS = pti.DOMESTIC_ULT_DUNS
                       UNION ALL
                       select 'X'
                       from POA_TPRT_INTERFACE pti
                       where ltrim(rtrim(DUNS)) IS NOT NULL
                       and dnb.GLOBAL_ULT_DUNS = pti.DUNS));

   l_rows_inserted := sql%rowcount;
   EDW_DUNS_M_C.g_row_count := EDW_DUNS_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_DUNS_DOMESTIC_LSTG');
   commit;

   Insert into EDW_DUNS_HEADQTR_LSTG(
      HQ_PK,
      HQ_DP,
      NAME,
      DUNS_NUMBER,
      ADDRESS,
      CITY,
      STATE_PROV,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      GLOBAL_ULT_FK,
      INSTANCE,
      LAST_UPDATE_DATE,
      COLLECTION_STATUS)
   select
       distinct GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME || '-' || GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME || '-' || GLOBAL_ULT_DUNS,
       GLOBAL_ULT_DUNS,
       GLOBAL_ULT_ADDRESS,
       GLOBAL_ULT_CITY,
       GLOBAL_ULT_STATE,
       GLOBAL_ULT_POSTAL_CODE,
       GLOBAL_ULT_COUNTRY,
       GLOBAL_ULT_TELEPHONE,
       NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
       NULL,
       sysdate,
       'READY'
    from POA_TPRT_INTERFACE dnb
    where (NOT EXISTS (select 'X'
                       from POA_TPRT_INTERFACE pti
                       where (ltrim(rtrim(HQ_DUNS)) IS NOT NULL)
                       and dnb.GLOBAL_ULT_DUNS = pti.HQ_DUNS
                       UNION ALL
                       select 'X'
                       from POA_TPRT_INTERFACE pti
                       where (ltrim(rtrim(DUNS)) IS NOT NULL)
                       and dnb.GLOBAL_ULT_DUNS = pti.DUNS));

   l_rows_inserted := sql%rowcount;
   EDW_DUNS_M_C.g_row_count := EDW_DUNS_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_DUNS_HEADQTR_LSTG');
   commit;

   Insert into EDW_DUNS_PARENT_LSTG(
      PARENT_PK,
      PARENT_DP,
      NAME,
      DUNS_NUMBER,
      ADDRESS,
      CITY,
      STATE_PROV,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      GLOBAL_ULT_FK,
      INSTANCE,
      LAST_UPDATE_DATE,
      COLLECTION_STATUS)
   select
       distinct GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME || '-' || GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME || '-' || GLOBAL_ULT_DUNS,
       GLOBAL_ULT_DUNS,
       GLOBAL_ULT_ADDRESS,
       GLOBAL_ULT_CITY,
       GLOBAL_ULT_STATE,
       GLOBAL_ULT_POSTAL_CODE,
       GLOBAL_ULT_COUNTRY,
       GLOBAL_ULT_TELEPHONE,
       NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
       NULL,
       sysdate,
       'READY'
    from POA_TPRT_INTERFACE dnb
    where (NOT EXISTS (select 'X'
                       from POA_TPRT_INTERFACE pti
                       where (ltrim(rtrim(PARENT_DUNS)) IS NOT NULL)
                       and dnb.GLOBAL_ULT_DUNS = pti.PARENT_DUNS
                       UNION ALL
                       select 'X'
                       from POA_TPRT_INTERFACE pti
                       where (ltrim(rtrim(DUNS)) IS NOT NULL)
                       and dnb.GLOBAL_ULT_DUNS = pti.DUNS));

   l_rows_inserted := sql%rowcount;
   EDW_DUNS_M_C.g_row_count := EDW_DUNS_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_DUNS_PARENT_LSTG');
   commit;

   Insert into EDW_DUNS_NUMBER_LSTG(
      DUNS_NUM_PK,
      DUNS_NUM_DP,
      NAME,
      DUNS_NUMBER,
      COMPANY_NAME,
      ADDRESS,
      CITY,
      STATE_PROV,
      ZIP_CODE,
      TELEPHONE,
      COUNTRY,
      HQ_DUNS,
      HQ_NAME,
      HQ_ADDRESS,
      HQ_CITY,
      HQ_STATE_PROV,
      HQ_POSTAL_CODE,
      HQ_COUNTRY,
      HQ_TELEPHONE,
      PARENT_DUNS,
      PARENT_NAME,
      PARENT_ADDRESS,
      PARENT_CITY,
      PARENT_STATE_PROV,
      PARENT_POSTAL_CODE,
      PARENT_COUNTRY,
      PARENT_TELEPHONE,
      GLOBAL_ULT_DUNS,
      GLOBAL_ULT_NAME,
      GLOBAL_ULT_ADDRESS,
      GLOBAL_ULT_CITY,
      GLOBAL_ULT_STATE_PROV,
      GLOBAL_ULT_POSTAL_CODE,
      GLOBAL_ULT_COUNTRY,
      GLOBAL_ULT_TELEPHONE,
      DOMESTIC_ULT_DUNS,
      DOMESTIC_ULT_NAME,
      DOMESTIC_ULT_ADDRESS,
      DOMESTIC_ULT_CITY,
      DOMESTIC_ULT_STATE_PROV,
      DOMESTIC_ULT_POSTAL_CODE,
      DOMESTIC_ULT_COUNTRY,
      DOMESTIC_ULT_TELEPHONE,
      DOMESTIC_ULT_FK,
      HQ_FK,
      PARENT_FK,
      INSTANCE,
      LAST_UPDATE_DATE,
      COLLECTION_STATUS,
      UPDATE_FACT_FLAG)
   select
       distinct GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME || '-' || GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME || '-' || GLOBAL_ULT_DUNS,
       GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME,
       GLOBAL_ULT_ADDRESS,
       GLOBAL_ULT_CITY,
       GLOBAL_ULT_STATE,
       GLOBAL_ULT_POSTAL_CODE,
       GLOBAL_ULT_TELEPHONE,
       GLOBAL_ULT_COUNTRY,
       GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME,
       GLOBAL_ULT_ADDRESS,
       GLOBAL_ULT_CITY,
       GLOBAL_ULT_STATE,
       GLOBAL_ULT_POSTAL_CODE,
       GLOBAL_ULT_COUNTRY,
       GLOBAL_ULT_TELEPHONE,
       GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME,
       GLOBAL_ULT_ADDRESS,
       GLOBAL_ULT_CITY,
       GLOBAL_ULT_STATE,
       GLOBAL_ULT_POSTAL_CODE,
       GLOBAL_ULT_COUNTRY,
       GLOBAL_ULT_TELEPHONE,
       GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME,
       GLOBAL_ULT_ADDRESS,
       GLOBAL_ULT_CITY,
       GLOBAL_ULT_STATE,
       GLOBAL_ULT_POSTAL_CODE,
       GLOBAL_ULT_COUNTRY,
       GLOBAL_ULT_TELEPHONE,
       GLOBAL_ULT_DUNS,
       GLOBAL_ULT_NAME,
       GLOBAL_ULT_ADDRESS,
       GLOBAL_ULT_CITY,
       GLOBAL_ULT_STATE,
       GLOBAL_ULT_POSTAL_CODE,
       GLOBAL_ULT_COUNTRY,
       GLOBAL_ULT_TELEPHONE,
       NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
       NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
       NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
       NULL,
       sysdate,
       'READY',
       'N'
    from POA_TPRT_INTERFACE dnb,
         POA_DNB_TRD_PRTNR poa
    where ((dnb.TRADING_PARTNER_PK = poa.TRADING_PARTNER_PK) and
           (NOT EXISTS (select 'X'
                        from POA_TPRT_INTERFACE pti
                        where (ltrim(rtrim(DUNS)) IS NOT NULL)
                        and dnb.GLOBAL_ULT_DUNS = pti.DUNS)));

   l_rows_inserted := sql%rowcount;
   EDW_DUNS_M_C.g_row_count := EDW_DUNS_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_DUNS_NUMBER_LSTG');
   commit;

   edw_log.put_line('Completed Push_EDW_DUNS_GLOBAL_LSTG');
 Exception When others then
   raise;
   commit;
END Push_EDW_DUNS_GLOBAL_LSTG;



Procedure Push_EDW_DUNS_HEADQTR_LSTG(p_from_date IN date,
                                     p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HEADQTR_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
   EDW_DUNS_HEADQTR_LSTG(
      HQ_PK,
      HQ_DP,
      NAME,
      DUNS_NUMBER,
      ADDRESS,
      CITY,
      STATE_PROV,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      GLOBAL_ULT_FK,
      INSTANCE,
      LAST_UPDATE_DATE,
      COLLECTION_STATUS)
   select
       distinct HQ_DUNS,
       HQ_NAME  || '-' || HQ_DUNS,
       HQ_NAME  || '-' || HQ_DUNS,
       HQ_DUNS,
       HQ_ADDRESS,
       HQ_CITY,
       HQ_STATE,
       HQ_POSTAL_CODE,
       HQ_COUNTRY,
       HQ_TELEPHONE,
       NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
       NULL,
       sysdate,
       'READY'
    from POA_TPRT_INTERFACE dnb
    where EXISTS (select 'X'
                  from POA_TPRT_INTERFACE pti
                  where (ltrim(rtrim(HQ_DUNS)) IS NOT NULL)
                  and  dnb.HQ_DUNS = pti.HQ_DUNS);

   l_rows_inserted := sql%rowcount;

   Insert Into
   EDW_DUNS_HEADQTR_LSTG(
      HQ_PK,
      HQ_DP,
      NAME,
      DUNS_NUMBER,
      ADDRESS,
      CITY,
      STATE_PROV,
      POSTAL_CODE,
      COUNTRY,
      TELEPHONE,
      GLOBAL_ULT_FK,
      INSTANCE,
      LAST_UPDATE_DATE,
      COLLECTION_STATUS)
   select
      distinct dnb.DUNS,
      COMPANY_NAME || '-' || dnb.DUNS,
      COMPANY_NAME || '-' || dnb.DUNS,
      dnb.DUNS,
      ADDRESS,
      CITY,
      STATE,
      ZIP,
      COUNTRY,
      TELEPHONE,
      NVL(ltrim(rtrim(GLOBAL_ULT_DUNS)), 'NA_EDW'),
      NULL,
      sysdate,
      'READY'
    from POA_TPRT_INTERFACE dnb
    where (ltrim(rtrim(HQ_DUNS)) IS NULL);

   EDW_DUNS_M_C.g_row_count := EDW_DUNS_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_DUNS_HEADQTR_LSTG');
   commit;

   edw_log.put_line('Completed Push_EDW_DUNS_HEADQTR_LSTG');
 Exception When others then
   raise;
   commit;
END Push_EDW_DUNS_HEADQTR_LSTG;


Procedure Push_EDW_SICM_SIC_LSTG(p_from_date IN date,
                                    p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_SICM_SIC_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
   EDW_SICM_SIC_LSTG(
      SIC_CODE_PK,
      SIC_CODE_DP,
      SIC_CODE,
      DESCRIPTION,
      ALL_FK,
      COLLECTION_STATUS,
      UPDATE_FACT_FLAG)
   select
       distinct SIC_CODE,
       SIC_CODE,
       SIC_CODE,
       SIC_DESCRIPTION,
       'ALL',
       'READY',
      'Y'
   from POA_DNB_SIC_CODE poa;

   l_rows_inserted := sql%rowcount;
   EDW_DUNS_M_C.g_row_count := EDW_DUNS_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_SICM_SIC_LSTG');
 Exception When others then
   raise;
commit;
END Push_EDW_SICM_SIC_LSTG;


END EDW_DUNS_M_C;


/
