--------------------------------------------------------
--  DDL for Package IGS_FI_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGSFI03S.pls 120.2 2005/08/26 07:00:09 appldev ship $ */

/***********************************************
Change History
svuppala  23-JUN-2005   Bug 3392088 Modifications as part of CPF build
                        Added 2 functions finp_del_fsert, finp_del_fser
rnirwani   05-May-02 removed reference to IGS_FI_DSBR_SPSHT bug# 2329407
rnirwani - 25-APR-02 Obsoleted the procedures:
                                    finp_ins_disb_jnl
                                    FINP_DEL_DISB_JNL
                                    Bug# 2329407
************************************************/

--
PROCEDURE FINP_DEL_DISB_SNPSHT(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  NUMBER,
  p_fee_period IN VARCHAR2,
  p_fee_type VARCHAR2 ,
  p_snapshot_create_dt_C VARCHAR2,
  p_delete_ds_ind  VARCHAR2 ,
  p_delete_dsd_ind  VARCHAR2 ,
  p_delete_dda_ind  VARCHAR2,
  p_org_id NUMBER
  );
--
FUNCTION finp_del_err(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_range_number IN NUMBER ,
  p_rate_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;
--
PROCEDURE finp_del_minor_debt(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  P_FEE_ASSESSMENT_PERIOD IN VARCHAR2 ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_course_cd IN igs_ps_course.course_cd%type,
  p_person_id	   IN HZ_PARTIES.PARTY_ID%type,
  p_group_id IN IGS_PE_PERSID_GROUP_ALL.group_id%TYPE ,
  p_min_days_overdue IN NUMBER,
  p_max_outstanding IN IGS_FI_FEE_AS_ALL.transaction_amount%TYPE ,
  p_comments IN igs_fi_fee_as_all.comments%type,
  p_org_id NUMBER );
--
FUNCTION finp_ins_cfar(
  p_person_id  IGS_FI_FEE_AS_RT.person_id%TYPE ,
  p_course_cd  IGS_FI_FEE_AS_RT.course_cd%TYPE ,
  p_fee_type  IGS_FI_FEE_AS_RT.FEE_TYPE%TYPE ,
  p_start_dt  IGS_FI_FEE_AS_RT.start_dt%TYPE ,
  p_end_dt  IGS_FI_FEE_AS_RT.end_dt%TYPE ,
  p_location_cd  IGS_FI_FEE_AS_RT.location_cd%TYPE ,
  p_attendance_type  IGS_FI_FEE_AS_RT.ATTENDANCE_TYPE%TYPE ,
  p_attendance_mode  IGS_FI_FEE_AS_RT.ATTENDANCE_MODE%TYPE ,
  p_chg_rate  IGS_FI_FEE_AS_RT.chg_rate%TYPE ,
  p_lower_nrml_rate_ovrd_ind  IGS_FI_FEE_AS_RT.lower_nrml_rate_ovrd_ind%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;
--
FUNCTION finp_del_fsert(
  p_sub_er_id NUMBER,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

--
FUNCTION finp_del_fser(
  p_er_id NUMBER,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

--
FUNCTION finp_del_sub_rt(
  p_sub_err_id NUMBER,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--
END IGS_FI_GEN_003;

 

/
