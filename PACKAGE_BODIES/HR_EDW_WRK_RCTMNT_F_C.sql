--------------------------------------------------------
--  DDL for Package Body HR_EDW_WRK_RCTMNT_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EDW_WRK_RCTMNT_F_C" AS
/* $Header: hriepwrt.pkb 115.10 2004/03/09 03:44:34 knarula noship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 Procedure Push(Errbuf      in out nocopy Varchar2,
                Retcode     in out nocopy Varchar2,
                p_from_date  IN   VARCHAR2,
                p_to_date    IN   VARCHAR2) IS
 l_fact_name   Varchar2(30) :='HR_EDW_WRK_RCTMNT_F'  ;
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
	HR_EDW_WRK_RCTMNT_F_C.g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset;
  ELSE
		HR_EDW_WRK_RCTMNT_F_C.g_push_date_range1 := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;

  IF (p_to_date IS NULL) THEN
		HR_EDW_WRK_RCTMNT_F_C.g_push_date_range2 := EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
  ELSE
		HR_EDW_WRK_RCTMNT_F_C.g_push_date_range2 := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
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
   edw_log.put_line('Populating Recruitment Table');
   hri_edw_fct_recruitment.populate_recruitment_table;
   edw_log.put_line('Finished populating table');

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;
   --
   COMMIT;
   --
   INSERT INTO hr_edw_wrk_rctmnt_fstg (
     ACCEPT_OCCURRED,
     AGE_BAND_FK,
     APPLICANT_FTE,
     APPLICANT_HEADCOUNT,
     APPLICATION_END_DATE,
     APPLICATION_ID,
     APPLICATION_START_DATE,
     APPLICATION_TERMINATED,
     ASSIGNMENT_FK,
     ASSIGNMENT_ID,
     BUSINESS_GROUP_ID,
     CREATION_DATE,
     DAYS_TO_ACCEPT,
     DAYS_TO_END_EMP,
     DAYS_TO_HIRE,
     DAYS_TO_INTERVIEW1,
     DAYS_TO_INTERVIEW2,
     DAYS_TO_OFFER,
     DAYS_TO_TERM_APL,
     END_EMP_OCCURRED,
     MOVEMENT_ACCEPT_FK,
     MOVEMENT_APPLICATION_FK,
     MOVEMENT_EMPLYMNT_END_FK,
     MOVEMENT_HIRE_FK,
     MOVEMENT_INTERVIEW1_FK,
     MOVEMENT_INTERVIEW2_FK,
     MOVEMENT_OFFER_FK,
     MOVEMENT_TERMINATION_FK,
     FINISHED_VALUE,
     GEOGRAPHY_FK,
     GRADE_FK,
     HIRE_DATE,
     HIRE_OCCURRED,
     INSTANCE_FK,
     INTERVIEW1_OCCURRED,
     INTERVIEW2_OCCURRED,
     JOB_FK,
     LAST_UPDATE_DATE,
     OFFER_OCCURRED,
     ORGNZTN_ASSGNMNT_FK,
     ORGNZTN_CRDNTNG_FK,
     PERSON_APPLICANT_FK,
     PERSON_AUTHORISER_FK,
     PERSON_CONTACT_FK,
     PERSON_ID,
     PERSON_ORIGINATOR_FK,
     PERSON_RECRUITER_FK,
     PERSON_TYPE_FK,
     PLANNED_START_DATE,
     POSITION_FK,
     REASON_ACCEPT_FK,
     REASON_APPLICATION_FK,
     REASON_EMPLYMNT_END_FK,
     REASON_HIRE_FK,
     REASON_INTERVIEW1_FK,
     REASON_INTERVIEW2_FK,
     REASON_OFFER_FK,
     REASON_TERMINATION_FK,
     RECRUITMENT_ACTIVITY_FK,
     RECRUITMENT_GAIN_PK,
     REQUISITION_VACANCY_FK,
     SERVICE_BAND_FK,
     TIME_ACCEPTED_FK,
     TIME_APPLICATION_FK,
     TIME_EMPLOYMENT_ENDED_FK,
     TIME_HIRE_FK,
     TIME_INTERVIEW1_FK,
     TIME_INTERVIEW2_FK,
     TIME_OFFER_FK,
     TIME_TERMINATED_FK,
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
     application_occurred,
     application_result_pending,
     application_pass_occurred,
     application_fail_occurred,
     interview1_result_pending,
     interview1_pass_occurred,
     interview1_fail_occurred,
     interview2_result_pending,
     interview2_pass_occurred,
     interview2_fail_occurred,
     offer_fail_occurred,
     accept_fail_occurred)
   select
     ACCEPT_OCCURRED,
     NVL(AGE_BAND_FK,'NA_EDW'),
     APPLICANT_FTE,
     APPLICANT_HEADCOUNT,
     APPLICATION_END_DATE,
     APPLICATION_ID,
     APPLICATION_START_DATE,
     APPLICATION_TERMINATED,
     NVL(ASSIGNMENT_FK,'NA_EDW'),
     ASSIGNMENT_ID,
     BUSINESS_GROUP_ID,
     CREATION_DATE,
     DAYS_TO_ACCEPT,
     DAYS_TO_END_EMP,
     DAYS_TO_HIRE,
     DAYS_TO_INTERVIEW1,
     DAYS_TO_INTERVIEW2,
     DAYS_TO_OFFER,
     DAYS_TO_TERM_APL,
     END_EMP_OCCURRED,
     NVL(MOVEMENT_ACCEPT_FK,'NA_EDW'),
     NVL(MOVEMENT_APPLICATION_FK,'NA_EDW'),
     NVL(MOVEMENT_EMPLYMNT_END_FK,'NA_EDW'),
     NVL(MOVEMENT_HIRE_FK,'NA_EDW'),
     NVL(MOVEMENT_INTERVIEW1_FK,'NA_EDW'),
     NVL(MOVEMENT_INTERVIEW2_FK,'NA_EDW'),
     NVL(MOVEMENT_OFFER_FK,'NA_EDW'),
     NVL(MOVEMENT_TERMINATION_FK,'NA_EDW'),
     FINISHED_VALUE,
     NVL(GEOGRAPHY_FK,'NA_EDW'),
     NVL(GRADE_FK,'NA_EDW'),
     HIRE_DATE,
     HIRE_OCCURRED,
     NVL(INSTANCE_FK,'NA_EDW'),
     INTERVIEW1_OCCURRED,
     INTERVIEW2_OCCURRED,
     NVL(JOB_FK,'NA_EDW'),
     LAST_UPDATE_DATE,
     OFFER_OCCURRED,
     NVL(ORGNZTN_ASSGNMNT_FK,'NA_EDW'),
     NVL(ORGNZTN_CRDNTNG_FK,'NA_EDW'),
     NVL(PERSON_APPLICANT_FK,'NA_EDW'),
     NVL(PERSON_AUTHORISER_FK,'NA_EDW'),
     NVL(PERSON_CONTACT_FK,'NA_EDW'),
     PERSON_ID,
     NVL(PERSON_ORIGINATOR_FK,'NA_EDW'),
     NVL(PERSON_RECRUITER_FK,'NA_EDW'),
     NVL(PERSON_TYPE_FK,'NA_EDW'),
     PLANNED_START_DATE,
     NVL(POSITION_FK,'NA_EDW'),
     NVL(REASON_ACCEPT_FK,'NA_EDW'),
     NVL(REASON_APPLICATION_FK,'NA_EDW'),
     NVL(REASON_EMPLYMNT_END_FK,'NA_EDW'),
     NVL(REASON_HIRE_FK,'NA_EDW'),
     NVL(REASON_INTERVIEW1_FK,'NA_EDW'),
     NVL(REASON_INTERVIEW2_FK,'NA_EDW'),
     NVL(REASON_OFFER_FK,'NA_EDW'),
     NVL(REASON_TERMINATION_FK,'NA_EDW'),
     NVL(RECRUITMENT_ACTIVITY_FK,'NA_EDW'),
     RECRUITMENT_GAIN_PK,
     NVL(REQUISITION_VACANCY_FK,'NA_EDW'),
     NVL(SERVICE_BAND_FK,'NA_EDW'),
     NVL(TIME_ACCEPTED_FK,'NA_EDW'),
     NVL(TIME_APPLICATION_FK,'NA_EDW'),
     NVL(TIME_EMPLOYMENT_ENDED_FK,'NA_EDW'),
     NVL(TIME_HIRE_FK,'NA_EDW'),
     NVL(TIME_INTERVIEW1_FK,'NA_EDW'),
     NVL(TIME_INTERVIEW2_FK,'NA_EDW'),
     NVL(TIME_OFFER_FK,'NA_EDW'),
     NVL(TIME_TERMINATED_FK,'NA_EDW'),
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
     application_occurred,
     application_result_pending,
     application_pass_occurred,
     application_fail_occurred,
     interview1_result_pending,
     interview1_pass_occurred,
     interview1_fail_occurred,
     interview2_result_pending,
     interview2_pass_occurred,
     interview2_fail_occurred,
     offer_fail_occurred,
     accept_fail_occurred
   from HR_EDW_WRK_RCTMNT_FCV
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   COMMIT;
   l_duration := sysdate - l_temp_date;
   /*Above where clause should be replaced in future when complete fix
   available for bug 2418020 with the commented lines below.
   For this to happen effective_start_date needs to be added
   to HR_EDW_WRK_RCTMNT_FCV */
   /* comment in as described above in later release
   WHERE last_update_date BETWEEN l_date1 AND l_date2
   AND   effective_start_date between l_date1 AND l_date2;
   */

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
End HR_EDW_WRK_RCTMNT_F_C;

/
