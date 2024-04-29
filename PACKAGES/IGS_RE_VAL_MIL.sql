--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_MIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_MIL" AUTHID CURRENT_USER AS
/* $Header: IGSRE09S.pls 120.0 2005/06/01 20:41:47 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS
  --                            removed .
  -------------------------------------------------------------------------------------------
  -- To validate the logical uniqueness of IGS_PR_MILESTONEs
  FUNCTION RESP_VAL_MIL_UNIQ(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate the delete of IGS_PR_MILESTONE details
  FUNCTION RESP_VAL_MIL_DEL(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_milestone_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To  validate IGS_PR_MILESTONE actual date reached
  FUNCTION RESP_VAL_MIL_ACTUAL(
  p_milestone_status IN VARCHAR2 ,
  p_actual_reached_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate IGS_PR_MILESTONE notification days
  FUNCTION RESP_VAL_MIL_DAYS(
  p_milestone_type IN VARCHAR2 ,
  p_milestone_status IN VARCHAR2 ,
  p_due_dt IN DATE ,
  p_old_imminent_days IN NUMBER ,
  p_new_imminent_days IN NUMBER ,
  p_old_reminder_days IN NUMBER ,
  p_new_reminder_days IN NUMBER ,
  p_old_re_reminder_days IN NUMBER ,
  p_new_re_reminder_days IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate IGS_PR_MILESTONE due date
  FUNCTION RESP_VAL_MIL_DUE(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_old_milestone_status IN VARCHAR2 ,
  p_new_milestone_status IN VARCHAR2 ,
  p_old_due_dt IN DATE ,
  p_new_due_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate IGS_PR_MILESTONE status
  FUNCTION RESP_VAL_MIL_MST(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_preced_sequence_number IN NUMBER ,
  p_old_milestone_status IN VARCHAR2 ,
  p_new_milestone_status IN VARCHAR2 ,
  p_old_due_dt IN DATE ,
  p_new_due_dt IN DATE ,
  p_validation_level IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate IGS_PR_MILESTONE type
  FUNCTION RESP_VAL_MIL_MTY(
  p_milestone_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate IGS_PR_MILESTONE preceding sequence number
  FUNCTION RESP_VAL_MIL_PRCD(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_due_dt IN DATE ,
  p_preced_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

END IGS_RE_VAL_MIL;

 

/
