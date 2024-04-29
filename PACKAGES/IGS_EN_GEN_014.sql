--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_014
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_014" AUTHID CURRENT_USER AS
/* $Header: IGSEN14S.pls 120.0 2005/06/01 18:58:19 appldev noship $ */


-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --ckasu     22-JUL-2004    added new Functions and Procedures Specs inorder to incorporate the
  --                         logic for getting current,future load calendars information.
  --                         as a part of Bug# 3784635
  -------------------------------------------------------------------------------------------

Function Enrs_Clc_Sua_Cp(
  p_person_id  IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd  IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_crv_version_number  IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_unit_cd  IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_unit_version_number  IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE ,
  p_teach_cal_type  IGS_EN_SU_ATTEMPT_ALL.cal_type%TYPE ,
  p_teach_sequence_number  IGS_EN_SU_ATTEMPT_ALL.ci_sequence_number%TYPE ,
  p_uoo_id IN NUMBER ,
  p_load_cal_type  IGS_CA_INST_ALL.cal_type%TYPE ,
  p_load_sequence_number  IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_override_enrolled_cp IN NUMBER ,
  p_override_eftsu IN NUMBER ,
  p_truncate_ind IN VARCHAR2 ,
  p_sca_cp_total IN NUMBER ,
  -- anilk, Audit special fee build
  p_include_audit IN VARCHAR2 DEFAULT 'N')
RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(Enrs_Clc_Sua_Cp, WNDS, WNPS);

Function Enrs_Clc_Sua_Eftsu(
  p_person_id  IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd  IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_crv_version_number  IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_unit_cd  IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_unit_version_number  IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE ,
  p_teach_cal_type  IGS_EN_SU_ATTEMPT_ALL.cal_type%TYPE ,
  p_teach_sequence_number  IGS_EN_SU_ATTEMPT_ALL.ci_sequence_number%TYPE ,
  p_uoo_id IN NUMBER ,
  p_load_cal_type  IGS_CA_INST_ALL.cal_type%TYPE ,
  p_load_sequence_number  IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_override_enrolled_cp IN NUMBER ,
  p_override_eftsu IN NUMBER ,
  p_truncate_ind IN VARCHAR2 ,
  p_sca_cp_total IN NUMBER ,
  -- anilk, Audit special fee build
  p_include_audit IN VARCHAR2 DEFAULT 'N')
RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES(Enrs_Clc_Sua_Eftsu, WNDS, WNPS);

Function Enrs_Clc_Sua_Eftsut(
  P_PERSON_ID IN NUMBER ,
  P_COURSE_CD IN VARCHAR2 ,
  P_CRV_VERSION_NUMBER IN NUMBER ,
  P_UNIT_CD IN VARCHAR2 ,
  P_UNIT_VERSION_NUMBER IN NUMBER ,
  P_TEACH_CAL_TYPE IN VARCHAR2 ,
  P_TEACH_SEQUENCE_NUMBER IN NUMBER ,
  p_uoo_id IN NUMBER ,
  p_override_enrolled_cp IN NUMBER ,
  p_override_eftsu IN NUMBER ,
  p_sca_cp_total IN NUMBER )
RETURN NUMBER;
   PRAGMA RESTRICT_REFERENCES(Enrs_Clc_Sua_Eftsut, WNDS, WNPS);

Function Enrs_Get_Acad_Alt_Cd(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER )
RETURN VARCHAR2;
 PRAGMA RESTRICT_REFERENCES(Enrs_Get_Acad_Alt_Cd, WNDS,WNPS);

Function Enrs_Get_Acai_Cndtnl(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_cndtnl_off_must_be_stsfd_ind IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2;
 PRAGMA RESTRICT_REFERENCES(Enrs_Get_Acai_Cndtnl, WNDS,WNPS);

Function Enrs_Get_Sca_Comm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_effective_date IN DATE )
RETURN VARCHAR2;
 PRAGMA RESTRICT_REFERENCES(Enrs_Get_Sca_Comm, WNDS, WNPS);

Function Enrs_Get_Sca_Elgbl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_comm_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER )
RETURN VARCHAR2;
 --PRAGMA RESTRICT_REFERENCES(Enrs_Get_Sca_Elgbl, WNDS, WNPS);

Function Enrs_Get_Sca_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2;
 PRAGMA RESTRICT_REFERENCES(Enrs_Get_Sca_Trnsfr, WNDS, WNPS);

Function Enrs_Get_Within_Ci(
  p_sup_cal_type IN VARCHAR2 ,
  p_sup_sequence_number IN NUMBER ,
  p_sub_cal_type IN VARCHAR2 ,
  p_sub_sequence_number IN NUMBER ,
  p_direct_match_ind IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrs_Get_Within_Ci, WNDS, WNPS);

 TYPE load_cal_rec_type IS RECORD (
    p_load_cal_type       IGS_CA_INST.CAL_TYPE%TYPE,
    p_load_ci_seq_num     IGS_CA_INST.SEQUENCE_NUMBER%TYPE,
    p_load_ci_alt_code    IGS_CA_INST.ALTERNATE_CODE%TYPE,
    p_load_ci_start_dt    IGS_CA_INST.START_DT%TYPE,
    p_load_ci_end_dt      IGS_CA_INST.END_DT%TYPE,
    p_load_cal_desc       IGS_CA_INST.DESCRIPTION%TYPE
  );

  TYPE load_cal_table_type IS TABLE  OF load_cal_rec_type
   INDEX BY BINARY_INTEGER;

  PROCEDURE get_all_cur_load_cal (
    p_acad_cal_type       IN VARCHAR2,
    p_effective_dt        IN DATE,
	p_load_cal_table_info_str OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_all_future_load_cal (
    p_acad_cal_type       IN VARCHAR2,
	p_future_ld_cal_table_info_str OUT NOCOPY VARCHAR2
  );

  FUNCTION get_cal_tbl_frm_caltyp_seq_lst (
   p_seqno_caltype_info  IN VARCHAR2
  ) RETURN load_cal_table_type;


  FUNCTION get_cur_ld_cal_with_erly_st_dt (
   p_load_cal_table_info_str IN VARCHAR2
  )  RETURN VARCHAR2;


  FUNCTION get_load_eff_dt_alias
    RETURN VARCHAR2;

  FUNCTION get_seqno_caltyp_from_caltable (
   p_cal_table_info IN load_cal_table_type
  ) RETURN VARCHAR2;

  FUNCTION is_cur_ld_cal_has_eff_dt_alias  (
   p_acad_cal_type       IN VARCHAR2,
   p_effective_dt        IN DATE,
   p_all_cur_load_cal_info_str  OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION is_fut_cal_exists_as_cur_cal (
   p_all_cur_load_cal_info IN load_cal_table_type,
   p_fut_load_cal_rec  IN  load_cal_rec_type
  ) RETURN BOOLEAN;

END IGS_EN_GEN_014;

 

/
