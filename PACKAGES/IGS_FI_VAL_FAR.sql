--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FAR" AUTHID CURRENT_USER AS
/* $Header: IGSFI22S.pls 120.1 2005/06/05 20:27:24 appldev  $ */
  --
  --Who          When         What
  -- svuppala   03-Jun-2005   Enh# 3442712 - Modified finp_val_far_unique
  --pathipat     10-Sep-2003  Enh 3108052 - Add Unit Sets to Rate Table
  --                          Modified finp_val_far_unique() - Added 2 new params
  -- vvutukur    29-Nov-2002  Enh#2584986.Obsoleted function FINP_VAL_FAR_CUR.
  -- npalanis    23-OCT-2002  Bug : 2608360
  --                          p_residency_status_id column is changed to p_residency_status_cd of
  --                          datatype varchar2.
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_att_closed
  --
  -- Validate fee assessment rate can be created for the relation type.
  FUNCTION finp_val_far_create(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_far_create,wnds);
  --
  -- Validate IGS_PS_COURSE IGS_AD_LOCATION code.
  FUNCTION crsp_val_loc_cd(
  p_location_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(crsp_val_loc_cd,wnds);
  --
  -- Ensure IGS_FI_GOV_HEC_PA_OP is specified.
  FUNCTION finp_val_far_rqrd(
  p_fee_type IN VARCHAR2 ,
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_far_rqrd,wnds);
  --
  -- Validate fee assessment rate is unqiue.
  FUNCTION finp_val_far_unique(
  p_fee_type                  IN VARCHAR2 ,
  p_fee_cal_type              IN VARCHAR2 ,
  p_fee_ci_sequence_number    IN NUMBER ,
  p_s_relation_type           IN VARCHAR2 ,
  p_rate_number               IN NUMBER ,
  p_fee_cat                   IN VARCHAR2 ,
  p_location_cd               IN VARCHAR2 ,
  p_attendance_type           IN VARCHAR2 ,
  p_attendance_mode           IN VARCHAR2 ,
  p_govt_hecs_payment_option  IN VARCHAR2 ,
  p_govt_hecs_cntrbtn_band    IN NUMBER ,
  p_chg_rate                  IN NUMBER ,
  p_unit_class                IN VARCHAR2,
-- Added by Nishikant , to include the following five new fields for enhancement bug#1851586
  p_residency_status_cd       IN VARCHAR2 DEFAULT NULL,
  p_course_cd                 IN VARCHAR2 DEFAULT NULL,
  p_version_number            IN NUMBER DEFAULT NULL,
  p_org_party_id              IN NUMBER DEFAULT NULL,
  p_class_standing            IN VARCHAR2 DEFAULT NULL,
  p_message_name              OUT NOCOPY VARCHAR2,
  p_unit_set_cd               IN VARCHAR2,
  p_us_version_number         IN NUMBER,
  p_unit_cd                   IN VARCHAR2 ,
  p_unit_version_number       IN NUMBER   ,
  p_unit_level                IN VARCHAR2 ,
  p_unit_type_id              IN NUMBER   ,
  p_unit_mode                 IN VARCHAR2

  ) RETURN BOOLEAN;
pragma restrict_references(finp_val_far_unique,wnds);
  --
  -- Validate fee assessment rate order of precednce.
  FUNCTION finp_val_far_order(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_rate_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_govt_hecs_cntrbtn_band IN NUMBER ,
  p_order_of_precedence IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_far_order,wnds);
  --
  -- Ensure fee assessment rate fields can be populated.
  FUNCTION finp_val_far_defntn(
  p_fee_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_govt_hecs_cntrbtn_band IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_far_defntn,wnds);
  --
  -- Validate the attendance mode closed indicator.
  FUNCTION enrp_val_am_closed(
  p_attend_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(enrp_val_am_closed,wnds);
  --
  -- Validate if IGS_FI_GOVT_HEC_CNTB.govt_hecs_contrbn_band is closed.
  FUNCTION finp_val_ghc_closed(
  p_govt_hecs_cntrbtn_band IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_ghc_closed,wnds);
  --
  -- Validate if IGS_FI_GOV_HEC_PA_OP.govt_hecs_payment_opt is closed.
  FUNCTION finp_val_ghpo_closed(
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_ghpo_closed,wnds);
  --
  -- Ensure fee assessment rate can be created.
  FUNCTION finp_val_far_ins(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_far_ins,wnds);
  --
  --
  -- Validate the unit class closed indicator.
  FUNCTION unit_class_closed(
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN ;
pragma restrict_references(unit_class_closed,wnds);
  --
  -- Ensure fee ass rate relations are valid.
  FUNCTION finp_val_far_rltn(
  p_s_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_far_rltn,wnds);

END IGS_FI_VAL_FAR;

 

/
