--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FAS" AUTHID CURRENT_USER AS
/* $Header: IGSFI23S.pls 120.0 2005/06/01 17:30:25 appldev noship $ */
--
-- Change History
-- Who             When             What
-- masehgal        17-Jan-2002      ENH # 2170429
--                                  Obsoletion of SPONSOR_CD related paramaters
  --
  -- Validate fee assessable indicator value.
  -- Enh # 2122257 (SFCR015 : Change In Fee Category)
  -- Changed the signature of this function.
  -- Added params fee_cal_type and fee_ci_sequence_number
  FUNCTION finp_val_fas_ass_ind(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_transaction_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 DEFAULT NULL,
  p_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fas_ass_ind,WNDS);
  --
  -- Validate retrospective date of fee assessment period.
  FUNCTION finp_val_fas_retro(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fas_retro,WNDS);
  --
  -- Validate IGS_FI_FEE_AS_ALL.SI_FI_S_TRN_TYPE for a manual assessment.
  FUNCTION finp_val_fas_cat(
  p_transaction_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fas_cat,WNDS);
  --
  -- Check if contract fee assessment rate exists for the student.
  FUNCTION finp_val_fas_cntrct(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fas_cntrct,WNDS);
  --
  -- Validate that appropriate optional fields are entered for IGS_FI_FEE_AS.
  FUNCTION finp_val_fas_create(
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_cat IN IGS_FI_FEE_CAT_ALL.fee_cat%TYPE ,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fas_create,WNDS);
  --
  -- Ensure comment is recorded for a manual fee assessment.
  FUNCTION finp_val_fas_com(
  p_transaction_type IN VARCHAR2 ,
  p_comments IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fas_com,WNDS);
  --
  -- Validate effective date of fee assessment.
  FUNCTION finp_val_fas_eff_dt(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_s_transaction_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fas_eff_dt,WNDS);
  --
  -- Validate effect of transaction amount on student's balance.
  FUNCTION finp_val_fas_balance(
  p_person_id IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_transaction_amount IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fas_balance,WNDS);
  --
  -- Validate update to columns in the IGS_FI_FEE_AS table.

-- Change History
-- Who           When           What
-- masehgal      17-Jan-2002    ENH # 2170429
--                              Obsoletion of SPONSOR_CD related parameters

  FUNCTION finp_val_fas_upd(
  p_new_person_id  IGS_FI_FEE_AS_ALL.person_id%TYPE ,
  p_old_person_id  IGS_FI_FEE_AS_ALL.person_id%TYPE ,
  p_new_transaction_id  IGS_FI_FEE_AS_ALL.transaction_id%TYPE ,
  p_old_transaction_id  IGS_FI_FEE_AS_ALL.transaction_id%TYPE ,
  p_new_fee_type  IGS_FI_FEE_AS_ALL.fee_type%TYPE ,
  p_old_fee_type  IGS_FI_FEE_AS_ALL.fee_type%TYPE ,
  p_new_fee_cal_type  IGS_FI_FEE_AS_ALL.fee_cal_type%TYPE ,
  p_old_fee_cal_type  IGS_FI_FEE_AS_ALL.fee_cal_type%TYPE ,
  p_new_fee_ci_seq_num  IGS_FI_FEE_AS_ALL.fee_ci_sequence_number%TYPE ,
  p_old_fee_ci_seq_num  IGS_FI_FEE_AS_ALL.fee_ci_sequence_number%TYPE ,
  p_new_fee_cat  IGS_FI_FEE_AS_ALL.fee_cat%TYPE ,
  p_old_fee_cat  IGS_FI_FEE_AS_ALL.fee_cat%TYPE ,
  p_new_transaction_type  IGS_FI_FEE_AS_ALL.s_transaction_type%TYPE,
  p_old_transaction_type  IGS_FI_FEE_AS_ALL.s_transaction_type%TYPE ,
  p_new_transaction_dt  IGS_FI_FEE_AS_ALL.transaction_dt%TYPE ,
  p_old_transaction_dt  IGS_FI_FEE_AS_ALL.transaction_dt%TYPE ,
  p_new_transaction_amount  IGS_FI_FEE_AS_ALL.transaction_amount%TYPE ,
  p_old_transaction_amount  IGS_FI_FEE_AS_ALL.transaction_amount%TYPE ,
  p_new_currency_cd  IGS_FI_FEE_AS_ALL.currency_cd%TYPE ,
  p_old_currency_cd  IGS_FI_FEE_AS_ALL.currency_cd%TYPE ,
  p_new_exchange_rate  IGS_FI_FEE_AS_ALL.exchange_rate%TYPE ,
  p_old_exchange_rate  IGS_FI_FEE_AS_ALL.exchange_rate%TYPE ,
  p_new_chg_elements  IGS_FI_FEE_AS_ALL.chg_elements%TYPE ,
  p_old_chg_elements  IGS_FI_FEE_AS_ALL.chg_elements%TYPE ,
  p_new_effective_dt  IGS_FI_FEE_AS_ALL.effective_dt%TYPE ,
  p_old_effective_dt  IGS_FI_FEE_AS_ALL.effective_dt%TYPE ,
  p_new_course_cd  IGS_FI_FEE_AS_ALL.course_cd%TYPE ,
  p_old_course_cd  IGS_FI_FEE_AS_ALL.course_cd%TYPE ,
  p_new_notification_dt  IGS_FI_FEE_AS_ALL.notification_dt%TYPE ,
  p_old_notification_dt  IGS_FI_FEE_AS_ALL.notification_dt%TYPE ,
  p_new_logical_delete_dt  IGS_FI_FEE_AS_ALL.logical_delete_dt%TYPE ,
  p_old_logical_delete_dt  IGS_FI_FEE_AS_ALL.logical_delete_dt%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fas_upd,WNDS);
END IGS_FI_VAL_FAS;

 

/
