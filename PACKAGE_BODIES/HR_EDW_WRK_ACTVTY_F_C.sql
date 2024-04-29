--------------------------------------------------------
--  DDL for Package Body HR_EDW_WRK_ACTVTY_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EDW_WRK_ACTVTY_F_C" AS
/* $Header: hriepwac.pkb 115.7 2004/03/09 03:43:10 knarula noship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 Procedure Push(Errbuf      in out nocopy Varchar2,
                Retcode     in out nocopy Varchar2,
                p_from_date  IN   VARCHAR2,
                p_to_date    IN   VARCHAR2) IS
 l_fact_name   Varchar2(30) :='HR_EDW_WRK_ACTVTY_F'  ;
 l_date1                Date:=Null;
 l_date2                Date:=Null;
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
  Errbuf :=NULL;
   Retcode:=0;
  IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
    Return;
  END IF;

  IF (p_from_date IS NULL) THEN
	HR_EDW_WRK_ACTVTY_F_C.g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset;
  ELSE
		HR_EDW_WRK_ACTVTY_F_C.g_push_date_range1 := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;

  IF (p_to_date IS NULL) THEN
		HR_EDW_WRK_ACTVTY_F_C.g_push_date_range2 := EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
  ELSE
		HR_EDW_WRK_ACTVTY_F_C.g_push_date_range2 := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;


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
   COMMIT;
   --
   l_temp_date := sysdate;
   Insert Into HR_EDW_WRK_ACTVTY_FSTG(
     AGE_BAND_FK,
     APPLICATION_ID,
     ASG_CHANGE_FTE,
     ASG_CHANGE_HEADCOUNT,
     ASG_REQUEST_ID,
     ASG_TITLE,
     ASSIGNMENT_CHANGE_FK,
     ASSIGNMENT_CHANGE_PK,
     ASSIGNMENT_FK,
     ASSIGNMENT_ID,
     ASSIGNMENT_NUMBER,
     ASSIGNMENT_SEQUENCE,
     ASSIGNMENT_STATUS_TYPE_ID,
     ASSIGNMENT_TYPE,
     BARGAINING_UNIT_CODE,
     BUSINESS_GROUP_ID,
     CAGR_GRADE_DEF_ID,
     CAGR_ID_FLEX_NUM,
     CHANGE_REASON,
     COLLECTIVE_AGREEMENT_ID,
     COMMENT_ID,
     CONTRACT_ID,
     DATE_PROBATION_END,
     DAYS_EMP_START_TO_TERM,
     DAYS_SINCE_LAST_GEOG_X,
     DAYS_SINCE_LAST_GRD_X,
     DAYS_SINCE_LAST_JOB_X,
     DAYS_SINCE_LAST_ORG_X,
     DAYS_SINCE_LAST_POS_X,
     DEFAULT_CODE_COMB_ID,
     EFFECTIVE_END_DATE,
     EFFECTIVE_START_DATE,
     EMPLOYMENT_CATEGORY,
     EMPLYMNT_START_FLAG,
     ASSGNMNT_ENDED_FLAG,
     ESTABLISHMENT_ID,
     FREQUENCY,
     GEOGRAPHY_FROM_FK,
     GEOGRAPHY_TO_FK,
     GEOG_CHANGE_FLAG,
     GRADE_FROM_FK,
     GRADE_ID,
     GRADE_TO_FK,
     GRD_CHANGE_FLAG,
     HOURLY_SALARIED_CODE,
     INSTANCE_FK,
     INTERNAL_ADDRESS_LINE,
     JOB_CHANGE_FLAG,
     JOB_FROM_FK,
     JOB_ID,
     JOB_TO_FK,
     LABOUR_UNION_MEMBER_FLAG,
     LOCATION_ID,
     MANAGER_FLAG,
     MOVEMENT_FK,
     NORMAL_HOURS,
     OBJECT_VERSION_NUMBER,
     ORGANIZATION_FROM_FK,
     ORGANIZATION_ID,
     ORGANIZATION_TO_FK,
     ORG_CHANGE_FLAG,
     OTHER_CHANGE_FLAG,
     PAYROLL_ID,
     PAY_BASIS_ID,
     PEOPLE_GROUP_ID,
     PERF_REVIEW_PERIOD,
     PERF_REVIEW_PERIOD_FREQUENCY,
     PERIOD_OF_SERVICE_ID,
     PERSON_FK,
     PERSON_ID,
     PERSON_REFERRED_BY_ID,
     PERSON_TYPE_FK,
     POSITION_FROM_FK,
     POSITION_ID,
     POSITION_TO_FK,
     POS_CHANGE_FLAG,
     PRIMARY_FLAG,
     PROBATION_PERIOD,
     PROBATION_UNIT,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     REASON_FK,
     RECRUITER_ID,
     RECRUITMENT_ACTIVITY_ID,
     SAL_REVIEW_PERIOD,
     SAL_REVIEW_PERIOD_FREQUENCY,
     SERVICE_BAND_FK,
     SET_OF_BOOKS_ID,
     SOFT_CODING_KEYFLEX_ID,
     SOURCE_ORGANIZATION_ID,
     SOURCE_TYPE,
     SPECIAL_CEILING_STEP_ID,
     SUPERVISOR_ID,
     TIME_FROM_FK,
     TIME_NORMAL_FINISH,
     TIME_NORMAL_START,
     TIME_TO_FK,
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
     VACANCY_ID,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     NVL(AGE_BAND_FK,'NA_EDW'),
     APPLICATION_ID,
     ASG_CHANGE_FTE,
     ASG_CHANGE_HEADCOUNT,
     ASG_REQUEST_ID,
     ASG_TITLE,
     NVL(ASSIGNMENT_CHANGE_FK,'NA_EDW'),
     ASSIGNMENT_CHANGE_PK,
     NVL(ASSIGNMENT_FK,'NA_EDW'),
     ASSIGNMENT_ID,
     ASSIGNMENT_NUMBER,
     ASSIGNMENT_SEQUENCE,
     ASSIGNMENT_STATUS_TYPE_ID,
     ASSIGNMENT_TYPE,
     BARGAINING_UNIT_CODE,
     BUSINESS_GROUP_ID,
     CAGR_GRADE_DEF_ID,
     CAGR_ID_FLEX_NUM,
     CHANGE_REASON,
     COLLECTIVE_AGREEMENT_ID,
     COMMENT_ID,
     CONTRACT_ID,
     DATE_PROBATION_END,
     DAYS_EMP_START_TO_TERM,
     DAYS_SINCE_LAST_GEOG_X,
     DAYS_SINCE_LAST_GRD_X,
     DAYS_SINCE_LAST_JOB_X,
     DAYS_SINCE_LAST_ORG_X,
     DAYS_SINCE_LAST_POS_X,
     DEFAULT_CODE_COMB_ID,
     EFFECTIVE_END_DATE,
     EFFECTIVE_START_DATE,
     EMPLOYMENT_CATEGORY,
     EMPLYMNT_START_FLAG,
     ASSGNMNT_ENDED_FLAG,
     ESTABLISHMENT_ID,
     FREQUENCY,
     NVL(GEOGRAPHY_FROM_FK,'NA_EDW'),
     NVL(GEOGRAPHY_TO_FK,'NA_EDW'),
     GEOG_CHANGE_FLAG,
     NVL(GRADE_FROM_FK,'NA_EDW'),
     GRADE_ID,
     NVL(GRADE_TO_FK,'NA_EDW'),
     GRD_CHANGE_FLAG,
     HOURLY_SALARIED_CODE,
     NVL(INSTANCE_FK,'NA_EDW'),
     INTERNAL_ADDRESS_LINE,
     JOB_CHANGE_FLAG,
     NVL(JOB_FROM_FK,'NA_EDW'),
     JOB_ID,
     NVL(JOB_TO_FK,'NA_EDW'),
     LABOUR_UNION_MEMBER_FLAG,
     LOCATION_ID,
     MANAGER_FLAG,
     NVL(MOVEMENT_FK,'NA_EDW'),
     NORMAL_HOURS,
     OBJECT_VERSION_NUMBER,
     NVL(ORGANIZATION_FROM_FK,'NA_EDW'),
     ORGANIZATION_ID,
     NVL(ORGANIZATION_TO_FK,'NA_EDW'),
     ORG_CHANGE_FLAG,
     OTHER_CHANGE_FLAG,
     PAYROLL_ID,
     PAY_BASIS_ID,
     PEOPLE_GROUP_ID,
     PERF_REVIEW_PERIOD,
     PERF_REVIEW_PERIOD_FREQUENCY,
     PERIOD_OF_SERVICE_ID,
     NVL(PERSON_FK,'NA_EDW'),
     PERSON_ID,
     PERSON_REFERRED_BY_ID,
     NVL(PERSON_TYPE_FK,'NA_EDW'),
     NVL(POSITION_FROM_FK,'NA_EDW'),
     POSITION_ID,
     NVL(POSITION_TO_FK,'NA_EDW'),
     POS_CHANGE_FLAG,
     PRIMARY_FLAG,
     PROBATION_PERIOD,
     PROBATION_UNIT,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     NVL(REASON_FK,'NA_EDW'),
     RECRUITER_ID,
     RECRUITMENT_ACTIVITY_ID,
     SAL_REVIEW_PERIOD,
     SAL_REVIEW_PERIOD_FREQUENCY,
     NVL(SERVICE_BAND_FK,'NA_EDW'),
     SET_OF_BOOKS_ID,
     SOFT_CODING_KEYFLEX_ID,
     SOURCE_ORGANIZATION_ID,
     SOURCE_TYPE,
     SPECIAL_CEILING_STEP_ID,
     SUPERVISOR_ID,
     NVL(TIME_FROM_FK,'NA_EDW'),
     TIME_NORMAL_FINISH,
     TIME_NORMAL_START,
     NVL(TIME_TO_FK,'NA_EDW'),
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
     VACANCY_ID,
     NULL, -- OPERATION_CODE
     'READY'
   from HR_EDW_WRK_ACTVTY_FCV
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   --
   COMMIT;
   l_duration := sysdate - l_temp_date;
   --

   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the staging table');
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, null, l_date1, l_date2);

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, l_date1, l_date2);
    raise;

End;
End HR_EDW_WRK_ACTVTY_F_C;

/
