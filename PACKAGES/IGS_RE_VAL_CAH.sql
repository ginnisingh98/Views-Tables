--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_CAH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_CAH" AUTHID CURRENT_USER AS
/* $Header: IGSRE06S.pls 120.0 2005/06/01 17:23:05 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .Modified function GENP_VAL_SDTT_SESS
  --svanukur    15-APR-2004     Removed procedure resp_val_cah_strt_dt as part of bug 3544986
  -------------------------------------------------------------------------------------------
  -- Allow for specified IGS_RE_CANDIDATURE trigger validation.
  PROCEDURE RESP_VAL_CA_TRG(
  p_table_name IN VARCHAR2 ,
  p_insert_delete_ind IN VARCHAR2 DEFAULT 'N')
;
  --
  -- Validate IGS_RE_CANDIDATURE attendance history changes prior to census date.
  FUNCTION resp_val_cah_census(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate IGS_RE_CANDIDATURE update.
  FUNCTION resp_val_ca_childupd(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate IGS_RE_CANDIDATURE attendance history dates.
  FUNCTION resp_val_cah_hist_dt(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_validate_first_hist_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate IGS_RE_CANDIDATURE attendance history insert.
  FUNCTION resp_val_cah_ca_ins(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_commencement_dt OUT NOCOPY DATE ,
  p_attendance_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate IGS_RE_CANDIDATURE attendance hist start date and SCA commencement.
  FUNCTION resp_val_cah_comm(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_commencement_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate IGS_RE_CANDIDATURE attendance history end date.
  FUNCTION resp_val_cah_end_dt(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_hist_start_dt IN DATE ,
  p_hist_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;



END IGS_RE_VAL_CAH;

 

/
