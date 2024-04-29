--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_PRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_PRO" AUTHID CURRENT_USER AS
/* $Header: IGSPR19S.pls 115.8 2002/11/29 02:48:52 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_OU_ACTIVE) - from the spec and body. -- kdande
*/
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001    Bug Id : 1956374. Removed function "prgp_val_appeal_ind"
  --smadathi    29-AUG-2001    Bug Id : 1956374. Removed function "prgp_val_cause_ind"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_att_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cgr_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_active"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cty_closed"
  -------------------------------------------------------------------------------------------
  --

  -- Validate progression outcome type clolsed indicator

  FUNCTION prgp_val_pot_closed(

  p_progression_outcome_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --


  -- Validate progression rule outcome restrict attendance type

  FUNCTION prgp_val_pro_att(

  p_progression_outcome_type IN VARCHAR2 ,

  p_restricted_attendance_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;


  --

  -- Validate progression rule outcome automatically apply indicator

  FUNCTION prgp_val_pro_auto(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_sequence_number IN NUMBER ,

  p_progression_outcome_type IN VARCHAR2 ,


  p_apply_automatically_ind IN VARCHAR2 DEFAULT 'N',

  p_encmb_course_group_cd IN VARCHAR2 ,

  p_restricted_enrolment_cp IN NUMBER ,

  p_restricted_attendance_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;


  --

  -- Validate progression rule outcome exclude course group

  FUNCTION prgp_val_pro_cgr(

  p_progression_outcome_type IN VARCHAR2 ,

  p_encmb_course_group_cd IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;


  --

  -- Validate progression outcome type restrict enrolled credit points

  FUNCTION prgp_val_pro_cp(

  p_progression_outcome_type IN VARCHAR2 ,

  p_restricted_enrolment_cp IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2  )


RETURN BOOLEAN;

  --

  -- Validate progression rule outcome progression outcome type

  FUNCTION prgp_val_pro_pot(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_sequence_number IN NUMBER ,


  p_progression_outcome_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate progression rule outcome has required details

  FUNCTION prgp_val_pro_rqrd(


  p_progression_outcome_type IN VARCHAR2 ,

  p_duration IN NUMBER ,

  p_duration_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

  --

  -- Validate the {s_ou_conf,s_crv_conf}.appeal_ind




  -- Validate the {s_ou_conf,s_crv_conf}.show_cause_ind.



END IGS_PR_VAL_PRO;

 

/
