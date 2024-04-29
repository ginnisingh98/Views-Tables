--------------------------------------------------------
--  DDL for Package IGS_FI_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GEN_006" AUTHID CURRENT_USER AS
/* $Header: IGSFI44S.pls 115.8 2003/02/21 14:40:39 vchappid ship $ */
 --
 -- vchappid       20-Feb-2003       Bug# 2747335, new function created, validates user-defined
 --                                  Person Type Id exists in system.
 -- nalkumar       11-Dec-2001       Removed the function finp_mnt_fee_encmb from this package.
 --		                     This is as per the SFCR015-HOLDS DLD. Bug:2126091
 --
 -- Nalin Kumar 16-Jan-2002 Added 'SET VERIFY OFF' before whenever sqlerr... |
 PROCEDURE finp_ins_stmnt_o_acc(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  p_correspondence_type IN VARCHAR2 ,
  P_FIN_PERD IN VARCHAR2,
  P_FEE_PERD IN VARCHAR2,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_person_group_id IN NUMBER ,
  p_institution_cd IN VARCHAR2 ,
  p_addr_type IN VARCHAR2 ,
  P_DATE_OF_ISSUE_C IN VARCHAR2,
  p_comment IN VARCHAR2 ,
  p_test_extraction IN VARCHAR2 ,
  p_org_id NUMBER
);

PROCEDURE finp_mnt_pymnt_schdl(
 errbuf  out NOCOPY  varchar2,
 retcode out NOCOPY  number,
 P_FEE_ASSESSMENT_PERIOD IN VARCHAR2,
 p_person_id IN     IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
 p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
 p_fee_category IN  IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
 p_notification_dt_c IN VARCHAR2,
 p_num_days_to_notification  NUMBER ,
 p_next_bus_day_ind IN VARCHAR,
 p_org_id NUMBER
 );

FUNCTION finp_mnt_hecs_pymnt_optn(
  p_effective_dt IN DATE ,
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_fee_cal_type IN IGS_CA_INST_ALL.CAL_TYPE%TYPE ,
  p_fee_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.FEE_CAT%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_update_ind IN VARCHAR2 DEFAULT 'N',
  p_deferred_payment_option  IGS_FI_HECS_PAY_OPTN.HECS_PAYMENT_OPTION%TYPE ,
  p_upfront_payment_option  IGS_FI_HECS_PAY_OPTN.HECS_PAYMENT_OPTION%TYPE ,
  p_creation_dt IN OUT NOCOPY IGS_GE_S_LOG.creation_dt%TYPE ,
  p_hecs_payment_type OUT NOCOPY fnd_lookup_values.LOOKUP_CODE%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN ;

PROCEDURE validate_prsn_id_typ(p_c_usr_alt_prs_id_typ IN VARCHAR2,
                               p_c_unique IN VARCHAR2,
                               p_b_status OUT NOCOPY BOOLEAN,
                               p_c_sys_alt_prs_id_typ OUT NOCOPY VARCHAR2);

END igs_fi_gen_006;

 

/
