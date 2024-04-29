--------------------------------------------------------
--  DDL for Package IGS_FI_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GEN_004" AUTHID CURRENT_USER AS
/* $Header: IGSFI04S.pls 120.1 2005/06/07 01:31:12 appldev  $ */
--
/*************************************************************
 Created By :
 Date Created By :
 Purpose :
 Know limitations, enhancements or remarks
 Change History
 Who             When       What
 bannamal        27-May-05  Fee Calculation Performance Enhancement. Changes done as per TD.
 vchappid        11-Nov-02  Bug# 2584986, GL- Interface Build New Date parameter.
                            p_d_gl_date is added to the finp_prc_enr_fa_todo, finp_prc_enr_fee_ass procedure specification
 vchappid        17-Oct-02  Bug#2595962.Removed the IN parameter p_predictive_ass_ind
                            from the procedure finp_prc_enr_fee_ass.
 rnirwani        05-May-02  Bug# 2329407 removeal of reference to IGS_FI_DSBR_SPSHT
 vchappid        02-Jan-02  Enh Bug#2162747, Key Program Implementation, Fin Cal Inst parameters
                            removed, new parameter p_c_career is added
 (reverse chronological order - newest change first)
***************************************************************/

FUNCTION finp_prc_cfar(
  p_person_id  IGS_FI_FEE_AS_RT.person_id%TYPE ,
  p_course_cd  IGS_FI_FEE_AS_RT.course_cd%TYPE ,
  p_commencement_dt  IGS_FI_FEE_AS_RT.start_dt%TYPE ,
  p_completion_dt  IGS_FI_FEE_AS_RT.end_dt%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

--
PROCEDURE finp_prc_disb_jnl(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  NUMBER,
  p_fin_period IN VARCHAR2 ,
  p_fee_period IN VARCHAR2,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_snapshot_create_dt_c IN DATE ,
  p_income_type IN VARCHAR2 ,
  p_ignore_prior_journals IN CHAR ,
  p_percent_disbursement IN NUMBER,
  p_org_id NUMBER
);
--
PROCEDURE finp_prc_disb_snpsht(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  NUMBER,
  p_fin_period IN VARCHAR2,
  p_fee_period IN VARCHAR2,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE,
  p_org_id NUMBER
);
--
PROCEDURE finp_prc_enr_fa_todo(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  P_FEE_CAL IN VARCHAR2 ,
  p_org_id NUMBER,
  p_d_gl_date IN VARCHAR2 DEFAULT NULL
 );
--
PROCEDURE finp_prc_enr_fee_ass(
  errbuf  OUT NOCOPY  VARCHAR2,
  retcode OUT NOCOPY  NUMBER,
  p_person_id IN VARCHAR2,
  p_person_grp_id IN VARCHAR2 DEFAULT NULL,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_fee_cal   IN VARCHAR2,
  p_fee_category IN IGS_EN_STDNT_PS_ATT_ALL.FEE_CAT%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.FEE_TYPE%TYPE ,
  p_trace_on IN VARCHAR2 ,
  p_test_run IN VARCHAR2 ,
  p_org_id   NUMBER,
  p_process_mode IN VARCHAR2 DEFAULT 'ACTUAL',
  p_c_career      IN igs_ps_ver.course_type%TYPE DEFAULT NULL,
  p_d_gl_date     IN VARCHAR2 DEFAULT NULL,
  p_comments IN  VARCHAR2 DEFAULT NULL
  );
  -- prameters process mode , init process prior calendar instance
  -- and person id group have been added as a part
  -- of the build for fee calc undertaken in July 2001.
  -- Bug# 1851586

--
PROCEDURE finp_prc_hecs_pymnt_optn(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  NUMBER,
  p_effective_dt_c  IN OUT NOCOPY VARCHAR2 ,
  P_fee_assessment_period IN VARCHAR2,
  p_person_id IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_fee_cat  IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_course_cd  IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_deferred_payment_option IGS_FI_HECS_PAY_OPTN.hecs_payment_option%TYPE,
  p_upfront_payment_option IGS_FI_HECS_PAY_OPTN.hecs_payment_option%TYPE,
  p_org_id NUMBER
  );
--
PROCEDURE finp_prc_penalties(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  p_effective_dt_c IN VARCHAR2 ,
  P_fee_assessment_period IN VARCHAR2,
  p_person_id IN      IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_fee_type IN     IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_cat IN     IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_course_cd IN     IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_pending_fee_encmb_status IN VARCHAR2,
  p_n_authorising_person_id  IN NUMBER,
  p_org_id NUMBER
);
--
PROCEDURE finp_prc_sca_unconf(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_attempt_status IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_log_creation_dt IN DATE ,
  p_key IN VARCHAR2 ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_fee_ass_log_creation_dt IN OUT NOCOPY DATE ,
  p_delete_sca_ind OUT NOCOPY VARCHAR2 );
--
END  IGS_FI_GEN_004;

 

/
