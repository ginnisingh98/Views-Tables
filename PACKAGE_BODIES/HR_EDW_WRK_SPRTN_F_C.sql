--------------------------------------------------------
--  DDL for Package Body HR_EDW_WRK_SPRTN_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EDW_WRK_SPRTN_F_C" AS
/* $Header: hriepwsp.pkb 115.10 2004/03/09 03:45:28 knarula noship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 Procedure Push(Errbuf      in out nocopy Varchar2,
                Retcode     in out nocopy Varchar2,
                p_from_date  IN   VARCHAR2,
                p_to_date    IN   VARCHAR2) IS
 l_fact_name   Varchar2(30) :='HR_EDW_WRK_SPRTN_F'  ;
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
	HR_EDW_WRK_SPRTN_F_C.g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset;
  ELSE
		HR_EDW_WRK_SPRTN_F_C.g_push_date_range1 := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;

  IF (p_to_date IS NULL) THEN
		HR_EDW_WRK_SPRTN_F_C.g_push_date_range2 := EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
  ELSE
		HR_EDW_WRK_SPRTN_F_C.g_push_date_range2 := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
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
   edw_log.put_line('Populating separation reason types');
   commit;
   hri_edw_fct_wrkfc_sprtn.populate_sep_rsns;
   commit;
   edw_log.put_line('Finished populating separation reason types');

   edw_log.put_line(' ');
   edw_log.put_line('Populating separation performance table');
   hri_edw_fct_wrkfc_sprtn.populate_hri_prd_of_srvce;
   edw_log.put_line('Finished populating separation performance table');

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');
   commit;

   l_temp_date := sysdate;
   commit;
   Insert Into HR_EDW_WRK_SPRTN_FSTG(
     separation_pk,
     assignment_fk,
     age_band_fk,
     service_band_fk,
     geography_fk,
     grade_fk,
     instance_fk,
     job_fk,
     organization_fk,
     person_fk,
     person_type_fk,
     position_fk,
     time_trm_ntfd_fk,
     time_emp_strt_fk,
     time_trm_accptd_fk,
     time_trm_prjctd_fk,
     time_trm_prcss_fk,
     time_trm_occrd_fk,
     reason_fk,
     movement_type_fk,
     asg_assignment_id,
     asg_business_group_id,
     asg_grade_id,
     asg_job_id,
     asg_location_id,
     asg_organization_id,
     asg_person_id,
     asg_position_id,
     pps_prd_of_srvc_id,
     pps_trm_acptd_prsn_id,
     date_of_birth,
     last_update_date,
     creation_date,
     emp_start_fte,
     emp_start_hdcnt,
     sprtn_ntfd_fte,
     sprtn_ntfd_hdcnt,
     sprtn_accptd_fte,
     sprtn_accptd_hdcnt,
     sprtn_prjctd_fte,
     sprtn_prjctd_hdcnt,
     emp_sprtn_fte,
     emp_sprtn_hdcnt,
     final_prcss_fte,
     final_prcss_hdcnt,
     separation_fte,
     separation_headcount,
     dys_frm_strt_to_lst_updt,
     dys_frm_strt_to_lst_updt_asg,
     latest_asg_duration,
     sprtn_ntfd_vl,
     sprtn_accptd_vl,
     sprtn_plnd_vl,
     sprtn_cncld_vl,
     sprtn_occrrd_vl,
     sprtn_fnl_prcssng_vl,
     dys_frm_strt_to_ntfd_asg,
     dys_frm_strt_to_accptd_asg,
     dys_frm_strt_to_plnd_asg,
     dys_frm_strt_to_trm_asg,
     dys_frm_strt_to_prcss_asg,
     dys_frm_strt_to_ntfd,
     dys_frm_strt_to_accptd,
     dys_frm_strt_to_plnd,
     dys_frm_strt_to_trm,
     dys_frm_strt_to_prcss,
     dys_frm_ntfd_to_acptd,
     dys_frm_ntfd_to_plnd,
     dys_frm_ntfd_to_ocrd,
     dys_frm_acptd_to_plnd,
     dys_frm_acptd_to_ocrd,
     ntfd_trmntn_dt,
     accptd_trmntn_dt,
     prjctd_trmntn_dt,
     actual_trmntn_dt,
     final_process_dt,
     leaving_reason,
     user_measure1,
     user_measure2,
     user_measure3,
     user_measure4,
     user_measure5,
     user_attribute1,
     user_attribute2,
     user_attribute3,
     user_attribute4,
     user_attribute5,
     user_attribute6,
     user_attribute7,
     user_attribute8,
     user_attribute9,
     user_attribute10,
     user_attribute11,
     user_attribute12,
     user_attribute13,
     user_attribute14,
     user_attribute15,
     user_fk1,
     user_fk2,
     user_fk3,
     user_fk4,
     user_fk5,
     operation_code,
     collection_status)
   select
     separation_pk,
     NVL(assignment_fk,'NA_EDW'),
     NVL(age_band_fk,'NA_EDW'),
     NVL(service_band_fk,'NA_EDW'),
     NVL(geography_fk,'NA_EDW'),
     NVL(grade_fk,'NA_EDW'),
     NVL(instance_fk,'NA_EDW'),
     NVL(job_fk,'NA_EDW'),
     NVL(organization_fk,'NA_EDW'),
     NVL(person_fk,'NA_EDW'),
     NVL(person_type_fk,'NA_EDW'),
     NVL(position_fk,'NA_EDW'),
     NVL(time_trm_ntfd_fk,'NA_EDW'),
     NVL(time_emp_strt_fk,'NA_EDW'),
     NVL(time_trm_accptd_fk,'NA_EDW'),
     NVL(time_trm_prjctd_fk,'NA_EDW'),
     NVL(time_trm_prcss_fk,'NA_EDW'),
     NVL(time_trm_occrd_fk,'NA_EDW'),
     NVL(reason_fk,'NA_EDW'),
     NVL(movement_type_fk,'NA_EDW'),
     asg_assignment_id,
     asg_business_group_id,
     asg_grade_id,
     asg_job_id,
     asg_location_id,
     asg_organization_id,
     asg_person_id,
     asg_position_id,
     pps_prd_of_srvc_id,
     pps_trm_acptd_prsn_id,
     date_of_birth,
     last_update_date,
     creation_date,
     emp_start_fte,
     emp_start_hdcnt,
     sprtn_ntfd_fte,
     sprtn_ntfd_hdcnt,
     sprtn_accptd_fte,
     sprtn_accptd_hdcnt,
     sprtn_prjctd_fte,
     sprtn_prjctd_hdcnt,
     emp_sprtn_fte,
     emp_sprtn_hdcnt,
     final_prcss_fte,
     final_prcss_hdcnt,
     separation_fte,
     separation_headcount,
     dys_frm_strt_to_lst_updt,
     dys_frm_strt_to_lst_updt_asg,
     latest_asg_duration,
     sprtn_ntfd_vl,
     sprtn_accptd_vl,
     sprtn_plnd_vl,
     sprtn_cncld_vl,
     sprtn_occrrd_vl,
     sprtn_fnl_prcssng_vl,
     dys_frm_strt_to_ntfd_asg,
     dys_frm_strt_to_accptd_asg,
     dys_frm_strt_to_plnd_asg,
     dys_frm_strt_to_trm_asg,
     dys_frm_strt_to_prcss_asg,
     dys_frm_strt_to_ntfd,
     dys_frm_strt_to_accptd,
     dys_frm_strt_to_plnd,
     dys_frm_strt_to_trm,
     dys_frm_strt_to_prcss,
     dys_frm_ntfd_to_acptd,
     dys_frm_ntfd_to_plnd,
     dys_frm_ntfd_to_ocrd,
     dys_frm_acptd_to_plnd,
     dys_frm_acptd_to_ocrd,
     ntfd_trmntn_dt,
     accptd_trmntn_dt,
     prjctd_trmntn_dt,
     actual_trmntn_dt,
     final_process_dt,
     leaving_reason,
     user_measure1,
     user_measure2,
     user_measure3,
     user_measure4,
     user_measure5,
     user_attribute1,
     user_attribute2,
     user_attribute3,
     user_attribute4,
     user_attribute5,
     user_attribute6,
     user_attribute7,
     user_attribute8,
     user_attribute9,
     user_attribute10,
     user_attribute11,
     user_attribute12,
     user_attribute13,
     user_attribute14,
     user_attribute15,
     NVL(user_fk1,'NA_EDW'),
     NVL(user_fk2,'NA_EDW'),
     NVL(user_fk3,'NA_EDW'),
     NVL(user_fk4,'NA_EDW'),
     NVL(user_fk5,'NA_EDW'),
     NULL, -- OPERATION_CODE
     'READY'
   from HR_EDW_WRK_SPRTN_FCV
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   --
   commit;
   --
   l_duration := sysdate - l_temp_date;

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
End HR_EDW_WRK_SPRTN_F_C;

/
