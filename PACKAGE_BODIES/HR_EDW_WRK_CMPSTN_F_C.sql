--------------------------------------------------------
--  DDL for Package Body HR_EDW_WRK_CMPSTN_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EDW_WRK_CMPSTN_F_C" AS
/* $Header: hriepwcp.pkb 115.17 2003/12/19 08:07:56 vsethi noship $ */
 --
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 g_local_same_as_remote BOOLEAN:=FALSE;
 --
 -- Populate the hri_edw_daily_salary_details performace
 -- weith pre calculated salary information
 --
 --
 FUNCTION LOCAL_SAME_AS_REMOTE RETURN BOOLEAN
 IS

 BEGIN
   --
   RETURN edw_collection_util.source_same_as_target;
   --
 END LOCAL_SAME_AS_REMOTE;
 --
 --
 PROCEDURE drop_index IS
   --
   l_stmt VARCHAR2(240);
   --
 BEGIN
   l_stmt := 'DROP INDEX hri_edw_daily_salary_details_u';
   EXECUTE IMMEDIATE l_stmt;
 EXCEPTION WHEN OTHERS THEN
   null;          -- Do nothing if no index error occurs
 END drop_index;
 --
 PROCEDURE push_local IS
   --
 Begin
   --
   -- Push the Composition data
   --
   Insert /*+ NOPARALLEL */ Into HR_EDW_WRK_CMPSTN_FSTG(
     AGE_BAND_FK,
     ASG_ASSIGNMENT_ID,
     ASG_BUSINESS_GROUP_ID,
     ASG_GRADE_ID,
     ASG_JOB_ID,
     ASG_LOCATION_ID,
     ASG_ORGANIZATION_ID,
     ASG_PERSON_ID,
     ASG_POSITION_ID,
     ASSIGNMENT_FK,
     ASSIGNMENT_START_DATE,
     COMPOSITION_FTE,
     COMPOSITION_HEADCOUNT,
     COMPOSITION_PK,
     CREATION_DATE,
     CRNT_ANNLZED_SLRY,
     CRNT_ANNLZED_SLRY_BC,
     DATE_OF_BIRTH,
     GEOGRAPHY_FK,
     GRADE_FK,
     HGHST_GRD_SLRY,
     INSTANCE_FK,
     JOB_FK,
     LAST_UPDATE_DATE,
     LWST_GRD_SLRY,
     ORGANIZATION_FK,
     PERSON_FK,
     PERSON_TYPE_FK,
     POSITION_FK,
     SERVICE_BAND_FK,
     SNAPSHOT_DATE,
     TIME_FK,
     USER_FK1,
     USER_FK2,
     USER_FK3,
     USER_FK4,
     USER_FK5,
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE11,
     USER_ATTRIBUTE12,
     USER_ATTRIBUTE13,
     USER_ATTRIBUTE14,
     USER_ATTRIBUTE15,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     OPERATION_CODE,
     COLLECTION_STATUS,
     CRRNCY_CNVRSN_RATE,
     CURRENCY_FK)
   select /*+ PARALLEL (WCP,3) */
     NVL(AGE_BAND_FK,'NA_EDW'),
     ASG_ASSIGNMENT_ID,
     ASG_BUSINESS_GROUP_ID,
     ASG_GRADE_ID,
     ASG_JOB_ID,
     ASG_LOCATION_ID,
     ASG_ORGANIZATION_ID,
     ASG_PERSON_ID,
     ASG_POSITION_ID,
     NVL(ASSIGNMENT_FK,'NA_EDW'),
     ASSIGNMENT_START_DATE,
     COMPOSITION_FTE,
     COMPOSITION_HEADCOUNT,
     COMPOSITION_PK,
     CREATION_DATE,
     CRNT_ANNLZED_SLRY,
     CRNT_ANNLZED_SLRY_BC,
     DATE_OF_BIRTH,
     NVL(GEOGRAPHY_FK,'NA_EDW'),
     NVL(GRADE_FK,'NA_EDW'),
     HGHST_GRD_SLRY,
     NVL(INSTANCE_FK,'NA_EDW'),
     NVL(JOB_FK,'NA_EDW'),
     LAST_UPDATE_DATE,
     LWST_GRD_SLRY,
     NVL(ORGANIZATION_FK,'NA_EDW'),
     NVL(PERSON_FK,'NA_EDW'),
     NVL(PERSON_TYPE_FK,'NA_EDW'),
     NVL(POSITION_FK,'NA_EDW'),
     NVL(SERVICE_BAND_FK,'NA_EDW'),
     SNAPSHOT_DATE,
     NVL(TIME_FK,'NA_EDW'),
     NVL(USER_FK1,'NA_EDW'),
     NVL(USER_FK2,'NA_EDW'),
     NVL(USER_FK3,'NA_EDW'),
     NVL(USER_FK4,'NA_EDW'),
     NVL(USER_FK5,'NA_EDW'),
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE11,
     USER_ATTRIBUTE12,
     USER_ATTRIBUTE13,
     USER_ATTRIBUTE14,
     USER_ATTRIBUTE15,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     NULL, -- OPERATION_CODE
     DECODE(CRRNCY_CNVRSN_RATE,-1,'RATE_NOT_AVAILABLE',-2,'INVALID_CURRENCY','LOCAL READY'),
     CRRNCY_CNVRSN_RATE,
     NVL(CURRENCY_FK,'NA_EDW')
   from HR_EDW_WRK_CMPSTN_FCV;
   --  from HR_EDW_WRK_CMPSTN_FCV@APPS_TO_APPS WCP;
   --
   -- The following line although standard is being removed
   -- the push should only occur for the date specified in the
   -- hri_snapshot_date table.
   --
   -- where last_update_date between l_date1 and l_date2;
   commit;
   --
 END;
 --
 PROCEDURE push_local_directly (p_on_date   IN DATE) IS
   --
   l_temp_date        Date:=Null;
   l_rows_inserted    Number:=0;
   l_duration         Number:=0;
   --
 Begin
   --
   -- Push the Composition data
   --
   l_temp_date := sysdate;
   --
/* Version 115.7 - J Titmas */
/* Decoded collection_status to INVALID_CURRENCY if conversion rate is -2 */
   --
   Insert /*+ NOPARALLEL */ Into HR_EDW_WRK_CMPSTN_FSTG(
     AGE_BAND_FK,
     ASG_ASSIGNMENT_ID,
     ASG_BUSINESS_GROUP_ID,
     ASG_GRADE_ID,
     ASG_JOB_ID,
     ASG_LOCATION_ID,
     ASG_ORGANIZATION_ID,
     ASG_PERSON_ID,
     ASG_POSITION_ID,
     ASSIGNMENT_FK,
     ASSIGNMENT_START_DATE,
     COMPOSITION_FTE,
     COMPOSITION_HEADCOUNT,
     COMPOSITION_PK,
     CREATION_DATE,
     CRNT_ANNLZED_SLRY,
     CRNT_ANNLZED_SLRY_BC,
     DATE_OF_BIRTH,
     GEOGRAPHY_FK,
     GRADE_FK,
     HGHST_GRD_SLRY,
     INSTANCE_FK,
     JOB_FK,
     LAST_UPDATE_DATE,
     LWST_GRD_SLRY,
     ORGANIZATION_FK,
     PERSON_FK,
     PERSON_TYPE_FK,
     POSITION_FK,
     SERVICE_BAND_FK,
     SNAPSHOT_DATE,
     TIME_FK,
     USER_FK1,
     USER_FK2,
     USER_FK3,
     USER_FK4,
     USER_FK5,
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE11,
     USER_ATTRIBUTE12,
     USER_ATTRIBUTE13,
     USER_ATTRIBUTE14,
     USER_ATTRIBUTE15,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     OPERATION_CODE,
     COLLECTION_STATUS,
     CRRNCY_CNVRSN_RATE,
     CURRENCY_FK)
   select /*+ PARALLEL (WCP,3) */
     NVL(AGE_BAND_FK,'NA_EDW'),
     ASG_ASSIGNMENT_ID,
     ASG_BUSINESS_GROUP_ID,
     ASG_GRADE_ID,
     ASG_JOB_ID,
     ASG_LOCATION_ID,
     ASG_ORGANIZATION_ID,
     ASG_PERSON_ID,
     ASG_POSITION_ID,
     NVL(ASSIGNMENT_FK,'NA_EDW'),
     ASSIGNMENT_START_DATE,
     COMPOSITION_FTE,
     COMPOSITION_HEADCOUNT,
     COMPOSITION_PK,
     CREATION_DATE,
     CRNT_ANNLZED_SLRY,
     CRNT_ANNLZED_SLRY_BC,
     DATE_OF_BIRTH,
     NVL(GEOGRAPHY_FK,'NA_EDW'),
     NVL(GRADE_FK,'NA_EDW'),
     HGHST_GRD_SLRY,
     NVL(INSTANCE_FK,'NA_EDW'),
     NVL(JOB_FK,'NA_EDW'),
     LAST_UPDATE_DATE,
     LWST_GRD_SLRY,
     NVL(ORGANIZATION_FK,'NA_EDW'),
     NVL(PERSON_FK,'NA_EDW'),
     NVL(PERSON_TYPE_FK,'NA_EDW'),
     NVL(POSITION_FK,'NA_EDW'),
     NVL(SERVICE_BAND_FK,'NA_EDW'),
     SNAPSHOT_DATE,
     NVL(TIME_FK,'NA_EDW'),
     NVL(USER_FK1,'NA_EDW'),
     NVL(USER_FK2,'NA_EDW'),
     NVL(USER_FK3,'NA_EDW'),
     NVL(USER_FK4,'NA_EDW'),
     NVL(USER_FK5,'NA_EDW'),
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE11,
     USER_ATTRIBUTE12,
     USER_ATTRIBUTE13,
     USER_ATTRIBUTE14,
     USER_ATTRIBUTE15,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     NULL, -- OPERATION_CODE
     DECODE(CRRNCY_CNVRSN_RATE,-1,'RATE_NOT_AVAILABLE',-2,'INVALID_CURRENCY','READY'),
     CRRNCY_CNVRSN_RATE,
     NVL(CURRENCY_FK,'NA_EDW')
   from HR_EDW_WRK_CMPSTN_FCV WCP;
-- from HR_EDW_WRK_CMPSTN_FCV@APPS_TO_APPS WCP;
   --
   -- The following line although standard is being removed
   -- the push should only occur for the date specified in the
   -- hri_snapshot_date table.
   --
   -- where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;
   --
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
     ' rows into the HR_EDW_WRK_CMPSTN_FSTG staging table');
   edw_log.put_line('Date of Snapshot: ' || p_on_date);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
   --
   commit;
   --
 END;
 --
 PROCEDURE push_remote (p_on_date   IN DATE) IS
   --
   l_temp_date        Date:=Null;
   l_rows_inserted    Number:=0;
   l_duration         Number:=0;
   --
 Begin
   --
   -- Push the Composition data
   --
   l_temp_date := sysdate;
    Insert  Into HR_EDW_WRK_CMPSTN_FSTG@EDW_APPS_TO_WH(
     AGE_BAND_FK,
     ASG_ASSIGNMENT_ID,
     ASG_BUSINESS_GROUP_ID,
     ASG_GRADE_ID,
     ASG_JOB_ID,
     ASG_LOCATION_ID,
     ASG_ORGANIZATION_ID,
     ASG_PERSON_ID,
     ASG_POSITION_ID,
     ASSIGNMENT_FK,
     ASSIGNMENT_START_DATE,
     COMPOSITION_FTE,
     COMPOSITION_HEADCOUNT,
     COMPOSITION_PK,
     CREATION_DATE,
     CRNT_ANNLZED_SLRY,
     CRNT_ANNLZED_SLRY_BC,
     DATE_OF_BIRTH,
     GEOGRAPHY_FK,
     GRADE_FK,
     HGHST_GRD_SLRY,
     INSTANCE_FK,
     JOB_FK,
     LAST_UPDATE_DATE,
     LWST_GRD_SLRY,
     ORGANIZATION_FK,
     PERSON_FK,
     PERSON_TYPE_FK,
     POSITION_FK,
     SERVICE_BAND_FK,
     SNAPSHOT_DATE,
     TIME_FK,
     USER_FK1,
     USER_FK2,
     USER_FK3,
     USER_FK4,
     USER_FK5,
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE11,
     USER_ATTRIBUTE12,
     USER_ATTRIBUTE13,
     USER_ATTRIBUTE14,
     USER_ATTRIBUTE15,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     OPERATION_CODE,
     COLLECTION_STATUS,
     CRRNCY_CNVRSN_RATE,
     CURRENCY_FK)
   select /*+ PARALLEL(WCP) */
     NVL(AGE_BAND_FK,'NA_EDW'),
     ASG_ASSIGNMENT_ID,
     ASG_BUSINESS_GROUP_ID,
     ASG_GRADE_ID,
     ASG_JOB_ID,
     ASG_LOCATION_ID,
     ASG_ORGANIZATION_ID,
     ASG_PERSON_ID,
     ASG_POSITION_ID,
     NVL(ASSIGNMENT_FK,'NA_EDW'),
     ASSIGNMENT_START_DATE,
     COMPOSITION_FTE,
     COMPOSITION_HEADCOUNT,
     COMPOSITION_PK,
     CREATION_DATE,
     CRNT_ANNLZED_SLRY,
     CRNT_ANNLZED_SLRY_BC,
     DATE_OF_BIRTH,
     NVL(GEOGRAPHY_FK,'NA_EDW'),
     NVL(GRADE_FK,'NA_EDW'),
     HGHST_GRD_SLRY,
     NVL(INSTANCE_FK,'NA_EDW'),
     NVL(JOB_FK,'NA_EDW'),
     LAST_UPDATE_DATE,
     LWST_GRD_SLRY,
     NVL(ORGANIZATION_FK,'NA_EDW'),
     NVL(PERSON_FK,'NA_EDW'),
     NVL(PERSON_TYPE_FK,'NA_EDW'),
     NVL(POSITION_FK,'NA_EDW'),
     NVL(SERVICE_BAND_FK,'NA_EDW'),
     SNAPSHOT_DATE,
     NVL(TIME_FK,'NA_EDW'),
     NVL(USER_FK1,'NA_EDW'),
     NVL(USER_FK2,'NA_EDW'),
     NVL(USER_FK3,'NA_EDW'),
     NVL(USER_FK4,'NA_EDW'),
     NVL(USER_FK5,'NA_EDW'),
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE11,
     USER_ATTRIBUTE12,
     USER_ATTRIBUTE13,
     USER_ATTRIBUTE14,
     USER_ATTRIBUTE15,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     NULL, -- OPERATION_CODE
     'READY',
     CRRNCY_CNVRSN_RATE,
     NVL(CURRENCY_FK,'NA_EDW')
   from HR_EDW_WRK_CMPSTN_FSTG WCP
   where COLLECTION_STATUS = 'LOCAL READY';
/* 115.7 - only push valid rows - filter on collection_status */
-- from HR_EDW_WRK_CMPSTN_FSTG@APPS_TO_APPS WCP;
   --
   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;
   --
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
     ' rows into the HR_EDW_WRK_CMPSTN_FSTG staging table');
   edw_log.put_line('Date of Snapshot: ' || p_on_date);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
   --
   commit;
   --
 END;
 --
 --
 --
 Procedure bld_daily_salary_details IS
   --
   l_stmt VARCHAR2(240);
   --
   -- Added for 3246744, tablespace migration project
   --
   l_is_object_registered varchar2(50);
   l_ts_exists		  varchar2(50);
   l_tablespace		  varchar2(50);
   --
 Begin
   --
   -- Push the Composition data
   --
   l_stmt := 'TRUNCATE TABLE hri_edw_daily_salary_details';
   BEGIN
     EXECUTE IMMEDIATE l_stmt;
   EXCEPTION
     WHEN OTHERS THEN
       DELETE FROM hri_edw_daily_salary_details;
   END;
   --
   INSERT INTO hri_edw_daily_salary_details
   (salary,
    salary_currency_code,
    assignment_id)
   select  s.proposed_salary_n*
           nvl(ppb.pay_annualization_factor,
               tpt.number_per_fiscal_year)    salary
   ,         pet.input_currency_code          salary_currency_code
   ,     a.assignment_id
   from    pay_element_types_f pet
   ,       pay_input_values_f piv
   ,       per_pay_bases ppb
   ,       per_time_period_types tpt
   ,       pay_all_payrolls_f prl
   ,       per_assignments_f a
   ,       per_pay_proposals_v2 s
   ,       hri_edw_cmpstn_snpsht_dts snp
   where  a.assignment_type = 'E'
   and    snp.snapshot_date between a.effective_start_date
                           and     a.effective_end_date
   and    s.change_date IN (select max(ppp2.change_date)
                            from per_pay_proposals_v2 ppp2
                            where ppp2.change_date   < snp.snapshot_date
                            and   ppp2.assignment_id = a.assignment_id)
   and    a.pay_basis_id = ppb.pay_basis_id
   and    ppb.input_value_id = piv.input_value_id
   and    s.change_date between
             prl.effective_start_date and prl.effective_end_date
   and    a.payroll_id=prl.payroll_id
   and    prl.period_type=tpt.period_type
   and    snp.snapshot_date between
              piv.effective_start_date and piv.effective_end_date
   and    piv.element_type_id = pet.element_type_id
   and    snp.snapshot_date between
              pet.effective_start_date and pet.effective_end_date
   and    a.assignment_id = s.assignment_id
   and   s.approved = 'Y';
   --
   -- Changes made for 3246744, tablespace migration project
   -- The indexes should be created in correct tablespace.
   --
   ad_tspace_util.get_object_tablespace(
   		  x_product_short_name  => 'HRI',
   		  x_object_name         => 'HRI_EDW_DAILY_SALARY_DETAILS',
   		  x_object_type         => 'TABLE',
   		  x_index_lookup_flag   => 'Y',
   		  x_validate_ts_exists  => 'N',
   		  x_is_object_registered => l_is_object_registered,
    		  x_ts_exists            => l_ts_exists,
		  x_tablespace           => l_tablespace);
   --
   l_stmt:='Create index hri_edw_daily_salary_details_u on hri_edw_daily_salary_details'||
          '(assignment_id) tablespace '||l_tablespace;
   --
   BEGIN
     EXECUTE IMMEDIATE l_stmt;
     commit;
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
   END;
   --
 End bld_daily_salary_details;
  --
 PROCEDURE report_missing_rates IS

  l_no_missing_rates         NUMBER;

/* Cursor for reporting rate issues to the log */
  CURSOR rate_issues_csr IS
  SELECT
   DECODE(a.collection_status,
            'INVALID_CURRENCY','Invalid currency    ',
         'Rate not available  ')       collection_status
  ,to_char(a.snapshot_date,'DD Mon YYYY  ')
                                     snapshot_date
  ,rpad(b.name,20)                   currency_name
  ,b.currency_code                   currency_code
  ,count(*)                          total
  FROM hr_edw_wrk_cmpstn_fstg a, fnd_currencies_vl b
  WHERE a.currency_fk = b.currency_code (+)
  AND a.collection_status IN ('INVALID_CURRENCY','RATE_NOT_AVAILABLE')
  GROUP BY a.collection_status, a.snapshot_date, b.name, b.currency_code
  ORDER BY 1,2,3;

 BEGIN

/* Count is a group function so will always return 1 row */
   select count(*) into l_no_missing_rates
   from hr_edw_wrk_cmpstn_fstg
   where collection_status IN ('INVALID_CURRENCY','RATE_NOT_AVAILABLE');

/* If there are any issues, print report to log */
   IF (l_no_missing_rates > 0) THEN

     edw_log.put_line('');
     edw_log.put_line('Missing Rate Report');
     edw_log.put_line('===================');
     edw_log.put_line('');

     edw_log.put_line('Issue               Date         Currency Name         Number of rows');
     edw_log.put_line('------------------  -----------  --------------------  --------------');

     FOR missing_rate IN rate_issues_csr LOOP

       edw_log.put_line(missing_rate.collection_status ||
                        missing_rate.snapshot_date ||
                        missing_rate.currency_name || '  ' ||
                        missing_rate.total);

     END LOOP;

     edw_log.put_line('');
     edw_log.put_line('');

  END IF;

 END report_missing_rates;
 --
 Procedure Push(Errbuf      in out NOCOPY Varchar2,
                 Retcode     in out NOCOPY  Varchar2,
                 p_from_date  IN   VARCHAR2,
                 p_to_date    IN   VARCHAR2,
                 p_frequency  IN   VARCHAR2) IS
    --
    l_fact_name   Varchar2(30) :='HR_EDW_WRK_CMPSTN_F'  ;
    l_date1                Date:=Null;
    l_date2                Date:=Null;
    l_exception_msg            Varchar2(2000):=Null;
    -- -------------------------------------------
    -- Put any additional developer variables here
    -- -------------------------------------------
    l_snapshot_date         DATE;
    l_counter               NUMBER;
  Begin
    g_local_same_as_remote := LOCAL_SAME_AS_REMOTE;
    Errbuf :=NULL;
    Retcode:=0;
    IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name)) THEN
      errbuf := fnd_message.get;
      RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
      Return;
    END IF;
    --
    IF (p_from_date IS NULL) THEN
      HR_EDW_WRK_CMPSTN_F_C.g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset;
    ELSE
      HR_EDW_WRK_CMPSTN_F_C.g_push_date_range1 := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
    END IF;
    --
    IF (p_to_date IS NULL) THEN
		HR_EDW_WRK_CMPSTN_F_C.g_push_date_range2 := EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
    ELSE
      HR_EDW_WRK_CMPSTN_F_C.g_push_date_range2 := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
    END IF;
    --
    l_date1 := g_push_date_range1;
    l_date2 := g_push_date_range2;
    edw_log.put_line( 'The collection range is from '||
       to_char(l_date1,'MM/DD/YYYY HH24:MI:SS')||' to '||
       to_char(l_date2,'MM/DD/YYYY HH24:MI:SS'));
    edw_log.put_line(' ');
    -- -----------------------------------------------------------------------------
    -- Start of Collection , Developer Customizable Section
    -- -----------------------------------------------------------------------------
    edw_log.put_line(' ');
    edw_log.put_line('Pushing data');
    --
    /**************************************************************************/
    /* Section to populate snapshot dates table                               */
    /**************************************************************************/
    /* Initialize loop - l_snapshot_date holds next date to insert */
    /*                   l_counter holds number of dates inserted  */
    l_snapshot_date := l_date1;
    l_counter := 0;
    --
    /* Run the collection for each date until every date has been collected */
    --
    -- Empty the snapshot date table
    --
    DELETE FROM hri_edw_cmpstn_snpsht_dts;
    --
    --
    INSERT INTO hri_edw_cmpstn_snpsht_dts
    (snapshot_date)
    VALUES
    (l_snapshot_date);
    --
    WHILE (l_snapshot_date < l_date2)
    LOOP
      --
      -- Set the Snapshot Date to the appropriate value.
      --
      IF l_counter <> 0 THEN
        --
        UPDATE hri_edw_cmpstn_snpsht_dts
        SET snapshot_date = l_snapshot_date;
        --
      END IF;
      --
      -- Populate the Salary Detail for the snapshot date.
      --
      bld_daily_salary_details;
      --
      IF g_local_same_as_remote THEN
      --
      /* Populate staging table */
        push_local_directly(l_snapshot_date);
      --
      ELSE
      --
      /* Populate local staging table */
        push_local;
        --
      /* Populate remote staging table */
        push_remote(l_snapshot_date);
        --
      /* Empty pushed rows from local staging table */
        DELETE FROM hr_edw_wrk_cmpstn_fstg@apps_to_apps
        WHERE collection_status = 'LOCAL READY';
      --
      END IF;
      --
      -- Increment Counter
      --
      l_counter := l_counter + 1;
      --
      -- Find next date to insert - frequency restricted to Days,
      -- Months, Weeks or Years
      --
      IF    (p_frequency = 'D') THEN
        l_snapshot_date := l_snapshot_date + 1;
      ELSIF (p_frequency = 'M') THEN
        l_snapshot_date := ADD_MONTHS(l_date1, l_counter);
      ELSIF (p_frequency = 'W') THEN
        l_snapshot_date := l_snapshot_date + 7;
      ELSIF (p_frequency = 'Y') THEN
        l_snapshot_date := ADD_MONTHS(l_date1, (l_counter*12));
      END IF;
      --
    END LOOP;
    --
    /* Print report of currency rate problems */
    report_missing_rates;

    /* Remove invalid currency rate rows from staging table */
    DELETE FROM HR_EDW_WRK_CMPSTN_FSTG
    WHERE collection_status IN ('RATE_NOT_AVAILABLE','INVALID_CURRENCY');

    /**************************************************************************/
    -- -----------------------------------------------------------------------
    -- END OF Collection , Developer Customizable Section
    -- -----------------------------------------------------------------------
    --
    DROP_INDEX;
    --
    EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, null, l_date1, l_date2);
    --
  Exception When others then
    --
    DROP_INDEX;
    --
    Errbuf:=sqlerrm;
    Retcode:=sqlcode;
    l_exception_msg  := Retcode || ':' || Errbuf;
    rollback;
    EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, l_date1, l_date2);
    raise;
    --
  End Push;
  --
End HR_EDW_WRK_CMPSTN_F_C;

/
