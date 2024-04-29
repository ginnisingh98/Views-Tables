--------------------------------------------------------
--  DDL for Package IGS_FI_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GEN_005" AUTHID CURRENT_USER AS
/* $Header: IGSFI05S.pls 120.0 2005/06/01 18:53:22 appldev noship $ */
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --pathipat    21-Sep-2004     Enh 3880438 - Retention Enhancements
  --                            Removed function get_retention_amount
  -- pathipat   14-Oct-2003     Enh 3117341 - Audit and Special Fees TD
  --                            Added function get_retention_amount
  --smadathi    03-Jan-2003     Bug 2684895. Created new generic function
  --                            finp_get_prsid_grp_code which returns group code
  --sarakshi    13-Sep-2002     Enh#2564643,removed the function validate_psa.
  --smadathi    27-Feb-2002     Bug 2238413. Pragma associated with
  --                            finp_get_receivables_inst  removed.
  --jbegum     08-Feb-2002      Bug 2201081.Added function validate_psa.
  --sarakshi   02-Feb-2002      Bug 2195715.Added function finp_get_acct_meth
  --smadathi   22-Jan-2002      Bug 2170429. Procedure FINP_SET_FSS_EXPIRED
  --                            removed.
  ------------------------------------------------------------------


FUNCTION finp_val_fee_lblty(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;
--pragma restrict_references(finp_val_fee_lblty,wnds);
--
FUNCTION finp_val_fee_trigger(
  p_fee_cat IN IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE ,
  p_fee_cal_type IN IGS_FI_F_CAT_CA_INST.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_FI_F_CAT_CA_INST.fee_ci_sequence_number%TYPE ,
  p_fee_type IN IGS_FI_F_CAT_FEE_LBL_ALL.FEE_TYPE%TYPE ,
  p_s_fee_trigger_cat IN IGS_FI_FEE_TYPE_ALL.s_fee_trigger_cat%TYPE ,
  p_effective_dt IN DATE ,
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_version_number IN IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_cal_type IN IGS_EN_STDNT_PS_ATT_ALL.CAL_TYPE%TYPE ,
  p_location_cd IN IGS_EN_STDNT_PS_ATT_ALL.location_cd%TYPE ,
  p_attendance_mode IN IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_MODE%TYPE ,
  p_attendance_type IN IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_TYPE%TYPE ,
  p_trigger_fired OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--pragma restrict_references(finp_val_fee_trigger,wnds);
--
FUNCTION fins_val_fee_trigger(
  p_fee_cat  IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE ,
  p_fee_cal_type  IGS_FI_F_CAT_CA_INST.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number  IGS_FI_F_CAT_CA_INST.fee_ci_sequence_number%TYPE ,
  p_fee_type  IGS_FI_F_CAT_FEE_LBL_ALL.FEE_TYPE%TYPE ,
  p_s_fee_trigger_cat  IGS_FI_FEE_TYPE_ALL.s_fee_trigger_cat%TYPE ,
  p_effective_dt  DATE ,
  p_person_id  IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd  IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_version_number  IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_cal_type  IGS_EN_STDNT_PS_ATT_ALL.CAL_TYPE%TYPE ,
  p_location_cd  IGS_EN_STDNT_PS_ATT_ALL.location_cd%TYPE ,
  p_attendance_mode  IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_MODE%TYPE ,
  p_attendance_type  IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_TYPE%TYPE )
RETURN CHAR ;
--pragma restrict_references(fins_val_fee_trigger,wnds);
--
--
PROCEDURE finp_set_pymnt_schdl(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  P_FEE_ASSESSMENT_PERIOD IN VARCHAR2,
  p_person_id IN            IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_category IN            IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_grace_days IN NUMBER ,
  p_effective_dt_c IN VARCHAR2 ,
  p_notification_dt_c IN VARCHAR2 ,
  p_include_man_entries IN VARCHAR2 DEFAULT 'N',
  p_next_bus_day IN VARCHAR2 DEFAULT 'N',
  p_org_id NUMBER
  );
--
  FUNCTION finp_get_receivables_inst RETURN IGS_FI_CONTROL.Rec_Installed%TYPE;

  FUNCTION finp_get_acct_meth RETURN igs_fi_control.accounting_method%TYPE;
  pragma restrict_references(finp_get_acct_meth,wnds);

  -- This generic functions returns group code for the person group id passed as parameter to the function
  FUNCTION finp_get_prsid_grp_code(p_n_group_id IN igs_pe_persid_group.group_id%TYPE) RETURN VARCHAR2;


END igs_fi_gen_005;

 

/
