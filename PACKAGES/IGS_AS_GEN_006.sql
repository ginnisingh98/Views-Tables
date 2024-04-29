--------------------------------------------------------
--  DDL for Package IGS_AS_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GEN_006" AUTHID CURRENT_USER AS
/* $Header: IGSAS06S.pls 120.0 2005/07/05 13:00:44 appldev noship $ */

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- Aiyer      08-APR-2002     Bug No. 2124034. The parameter p_reproduce was also added as a hidden parameter in the
  --                            concurrent job IGSASJ05 Produce Student Assignment Cover Sheet with a default value as 'NO'.
  --                            In the package body of porocedure too it was made to have a default value of 'NO'.
  -------------------------------------------------------------------------------------------------------------------------


 PROCEDURE assp_get_ese_key(
  p_exam_cal_type IN OUT NOCOPY VARCHAR2 ,
  p_exam_ci_sequence_number IN OUT NOCOPY NUMBER ,
  p_dt_alias IN OUT NOCOPY VARCHAR2 ,
  p_dai_sequence_number IN OUT NOCOPY NUMBER ,
  p_start_time IN OUT NOCOPY DATE ,
  p_end_time IN OUT NOCOPY DATE ,
  p_ese_id IN OUT NOCOPY NUMBER );

PROCEDURE assp_ins_admin_grds(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  p_assess_calendar IN VARCHAR2 ,
  p_teaching_calendar IN VARCHAR2,
  p_org_unt_cd IN VARCHAR2 ,
  p_unt_cd  VARCHAR2 ,
  p_lctn_cd IN VARCHAR2 ,
  p_unt_md IN VARCHAR2 ,
  p_unt_cls IN VARCHAR2 ,
  p_insert_default_ind IN VARCHAR2 ,
  p_grade IN VARCHAR2 ,
  p_finalised_ind IN VARCHAR2 ,
  p_assble_type IN VARCHAR2 ,
  p_no_assmnt_type IN VARCHAR2,
  p_org_id IN NUMBER ,
   --added by lkaki--
  p_audit_grade IN VARCHAR2 DEFAULT NULL);

 PROCEDURE assp_ins_aia(
  p_ass_id IN IGS_AS_ITEM_ASSESSOR.ass_id%TYPE ,
  p_person_id IN IGS_AS_ITEM_ASSESSOR.person_id%TYPE ,
  p_ass_assessor_type IN IGS_AS_ITEM_ASSESSOR.ass_assessor_type%TYPE ,
  p_primary_assessor_ind IN IGS_AS_ITEM_ASSESSOR.primary_assessor_ind%TYPE ,
  p_item_limit IN IGS_AS_ITEM_ASSESSOR.item_limit%TYPE ,
  p_location_cd IN IGS_AS_ITEM_ASSESSOR.location_cd%TYPE ,
  p_unit_mode IN IGS_AS_ITEM_ASSESSOR.unit_mode%TYPE ,
  p_unit_class IN IGS_AS_ITEM_ASSESSOR.unit_class%TYPE ,
  p_comments IN IGS_AS_ITEM_ASSESSOR.comments%TYPE );

 PROCEDURE assp_ins_aia_default(
  p_ass_id IN IGS_AS_ITEM_ASSESSOR.ass_id%TYPE ,
  p_unit_cd IN IGS_PS_UNIT_VER_ALL.unit_cd%TYPE ,
  p_version_number IN IGS_PS_UNIT_VER_ALL.version_number%TYPE );

 PROCEDURE assp_ins_ai_cvr_sht(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  p_acad_calendar IN VARCHAR2,
  p_teach_calendar IN VARCHAR2,
  p_crs_cd  VARCHAR2 ,
  p_unt_cd IN VARCHAR2 ,
  p_lctn_cd IN VARCHAR2 ,
  p_unt_cls IN VARCHAR2 ,
  p_unt_md IN VARCHAR2 ,
  p_person_id IN NUMBER ,
  p_ass_id  NUMBER ,
  p_reprdc IN VARCHAR2 DEFAULT 'N',
  p_org_id IN NUMBER);

 PROCEDURE assp_ins_asr1020_tmp(
  p_ass_perd_cal_type IN VARCHAR2 ,
  p_ass_perd_sequence_number IN NUMBER ,
  p_owner_org_unit_cd IN VARCHAR2 ,
  p_owner_ou_start_dt IN DATE ,
  p_unit_mode IN VARCHAR2 );

 PROCEDURE assp_ins_dflt_evsa_a(
 errbuf  out NOCOPY  varchar2,
retcode out NOCOPY  number,
p_exam_cal varchar2,
p_org_id IN NUMBER
 );

 PROCEDURE assp_ins_ese_sprvsr(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_exam_supervisor_type IN VARCHAR2 ,
  p_venue_cd IN VARCHAR2 ,
  p_session_venue_ind IN VARCHAR2 DEFAULT 'N',
  p_ignore_warnings_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 );

 PROCEDURE assp_ins_gs_duprec(
  p_old_grading_schema_cd IN IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE ,
  p_old_version_number IN IGS_AS_GRD_SCHEMA.version_number%TYPE ,
  p_new_grading_schema_cd IN IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE ,
  p_new_version_number IN IGS_AS_GRD_SCHEMA.version_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 );

 PROCEDURE assp_upd_suao_trans(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  p_assess_calendar IN VARCHAR2 ,
  p_teaching_calendar IN VARCHAR2,
  p_crs_grp_cd IN VARCHAR2 ,
  p_crs_cd IN VARCHAR2 ,
  p_crs_org_unt_cd IN VARCHAR2 ,
  p_crs_lctn_cd IN VARCHAR2 ,
  p_crs_attd_md IN VARCHAR2 ,
  p_unt_cd IN VARCHAR2 ,
  p_unt_org_unt_cd IN VARCHAR2 ,
  p_unt_lctn_cd IN VARCHAR2 ,
  p_u_mode IN VARCHAR2 ,
  p_u_class IN VARCHAR2 ,
  p_allow_invalid_ind IN VARCHAR2,
  p_org_id in NUMBER );

END IGS_AS_GEN_006 ;

 

/
