--------------------------------------------------------
--  DDL for Package Body EDW_HR_PRSN_TYP_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_PRSN_TYP_M_C" AS
/* $Header: hrieppty.pkb 120.2 2006/04/06 02:23:23 jtitmas noship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;


 Procedure Push(Errbuf       in out NOCOPY Varchar2,
                Retcode      in out NOCOPY Varchar2,
                p_from_date  IN   VARCHAR2,
                p_to_date    IN   VARCHAR2) IS
 l_dimension_name   Varchar2(30) :='EDW_HR_PRSN_TYP_M'  ;
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
  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
  errbuf := fnd_message.get;
    Return;
  END IF;

  IF (p_from_date IS NULL) THEN
		EDW_HR_PRSN_TYP_M_C.g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date -
		EDW_COLLECTION_UTIL.g_offset;
  ELSE
	EDW_HR_PRSN_TYP_M_C.g_push_date_range1 := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;

  IF (p_to_date IS NULL) THEN
		EDW_HR_PRSN_TYP_M_C.g_push_date_range2 := EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
  ELSE
	EDW_HR_PRSN_TYP_M_C.g_push_date_range2 := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;


   edw_log.put_line( 'The collection range is from '||
        to_char(EDW_HR_PRSN_TYP_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(EDW_HR_PRSN_TYP_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Populating HRI Person Type table');
     HRI_EDW_DIM_PERSON_TYPE.populate_person_types;
   edw_log.put_line('Finished populating table');

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;


        Push_EDW_HR_PTYP_PRSN_TYP_LSTG(EDW_HR_PRSN_TYP_M_C.g_push_date_range1, EDW_HR_PRSN_TYP_M_C.g_push_date_range2);


   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Total rows inserted : '||g_row_count);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, null, g_push_date_range1, g_push_date_range2 );
commit;

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_HR_PRSN_TYP_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_HR_PRSN_TYP_M_C.g_exception_msg, g_push_date_range1, g_push_date_range2);

commit;
End;


Procedure Push_EDW_HR_PTYP_PRSN_TYP_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_PTYP_PRSN_TYP_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;

-- Set collect to date to sysdate below so that changes to the collected
-- table are picked up (changes to collected table will be timestamped
-- later than collect to date which is defaulted to sysdate at process
-- submit time)
   Insert Into
    EDW_HR_PTYP_PRSN_TYP_LSTG@EDW_APPS_TO_WH(
    PERSON_TYPE_PK,
    ALL_FK,
    NAME,
    PERSON_TYPE_DP,
    INSTANCE,
    POTENTIAL_WORKER_FLAG,
    PW_EMPLOYEE_TYPE,
    EMP_DIRECT_HIRE_FLAG,
    DH_PERMANENT_TYPE,
    DH_INTERN_TYPE,
    DH_FXD_TRM_LOWER_TYPE,
    DH_FXD_TRM_UPPER_TYPE,
    DH_EMP_STUDENT_FLAG,
    EMP_CNTNGNT_WRKFRC_FLAG,
    CW_AGNCY_CNTRCTR_TYPE,
    CW_SELF_EMPLOYED_TYPE,
    CW_CONSULTANT_TYPE,
    PW_EX_EMPLOYEE_TYPE,
    PW_APPLICANT_TYPE,
    NON_WORKER_FLAG,
    NW_CONTACT_FLAG,
    NW_DEPENDENT_TYPE,
    NW_RETIREE_TYPE,
    NW_BENEFICIARY_TYPE,
    SRVIVING_FMLY_MBR_TYPE,
    SRVIVING_SPOUSE_TYPE,
    EX_APPLICANT_TYPE,
    OTHER_TYPE,
    PARTICIPANT_TYPE,
    FORMER_SPOUSE_TYPE,
    FORMER_FMLY_MBR_TYPE,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    PW_EMPLOYEE_FLAG,
    DH_PERMANENT_FLAG,
    DH_INTERN_FLAG,
    DH_FXD_TRM_LOWER_FLAG,
    DH_FXD_TRM_UPPER_FLAG,
    CW_AGNCY_CNTRCTR_FLAG,
    CW_SELF_EMPLOYED_FLAG,
    CW_CONSULTANT_FLAG,
    PW_EX_EMPLOYEE_FLAG,
    PW_APPLICANT_FLAG,
    NW_DEPENDENT_FLAG,
    NW_RETIREE_FLAG,
    NW_BENEFICIARY_FLAG,
    SRVIVING_FMLY_MBR_FLAG,
    SRVIVING_SPOUSE_FLAG,
    EX_APPLICANT_FLAG,
    OTHER_FLAG,
    PARTICIPANT_FLAG,
    FORMER_SPOUSE_FLAG,
    FORMER_FMLY_MBR_FLAG,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select PERSON_TYPE_PK,
    NVL(ALL_FK, 'NA_EDW'),
NAME,
PERSON_TYPE_DP,
INSTANCE,
POTENTIAL_WORKER_FLAG,
PW_EMPLOYEE_TYPE,
EMP_DIRECT_HIRE_FLAG,
DH_PERMANENT_TYPE,
DH_INTERN_TYPE,
DH_FXD_TRM_LOWER_TYPE,
DH_FXD_TRM_UPPER_TYPE,
DH_EMP_STUDENT_FLAG,
EMP_CNTNGNT_WRKFRC_FLAG,
CW_AGNCY_CNTRCTR_TYPE,
CW_SELF_EMPLOYED_TYPE,
CW_CONSULTANT_TYPE,
PW_EX_EMPLOYEE_TYPE,
PW_APPLICANT_TYPE,
NON_WORKER_FLAG,
NW_CONTACT_FLAG,
NW_DEPENDENT_TYPE,
NW_RETIREE_TYPE,
NW_BENEFICIARY_TYPE,
SRVIVING_FMLY_MBR_TYPE,
SRVIVING_SPOUSE_TYPE,
EX_APPLICANT_TYPE,
OTHER_TYPE,
PARTICIPANT_TYPE,
FORMER_SPOUSE_TYPE,
FORMER_FMLY_MBR_TYPE,
LAST_UPDATE_DATE,
CREATION_DATE,
USER_ATTRIBUTE1,
USER_ATTRIBUTE2,
USER_ATTRIBUTE3,
USER_ATTRIBUTE4,
USER_ATTRIBUTE5,
PW_EMPLOYEE_FLAG,
DH_PERMANENT_FLAG,
DH_INTERN_FLAG,
DH_FXD_TRM_LOWER_FLAG,
DH_FXD_TRM_UPPER_FLAG,
CW_AGNCY_CNTRCTR_FLAG,
CW_SELF_EMPLOYED_FLAG,
CW_CONSULTANT_FLAG,
PW_EX_EMPLOYEE_FLAG,
PW_APPLICANT_FLAG,
NW_DEPENDENT_FLAG,
NW_RETIREE_FLAG,
NW_BENEFICIARY_FLAG,
SRVIVING_FMLY_MBR_FLAG,
SRVIVING_SPOUSE_FLAG,
EX_APPLICANT_FLAG,
OTHER_FLAG,
PARTICIPANT_FLAG,
FORMER_SPOUSE_FLAG,
FORMER_FMLY_MBR_FLAG,
    NULL, -- OPERATION_CODE
    'READY'
   from EDW_HR_PTYP_PRSN_TYP_LCV@APPS_TO_APPS
   where last_update_date between l_date1 and sysdate;


   l_rows_inserted := sql%rowcount;
   EDW_HR_PRSN_TYP_M_C.g_row_count := EDW_HR_PRSN_TYP_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(sql%rowcount,0))||
' rows into the EDW_HR_PTYP_PRSN_TYP_LSTG staging table');
   edw_log.put_line('Commiting records for EDW_HR_PTYP_PRSN_TYP_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_PTYP_PRSN_TYP_LSTG');
 Exception When others then
   raise;
commit;
END;
End EDW_HR_PRSN_TYP_M_C;

/
