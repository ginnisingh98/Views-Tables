--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_TEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_TEX" AUTHID CURRENT_USER AS
/* $Header: IGSRE15S.pls 120.0 2005/06/01 15:38:26 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --Nishikant   19NOV2002       Bug#2661533. The signature of the functions resp_val_tex_sbmsn got modified to add
  --                            two more parameer p_legacy and p_final_title_ind.
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS
  --                            removed .
  -------------------------------------------------------------------------------------------
   -- Validate the deceased indicator for a IGS_PE_PERSON.
  FUNCTION GENP_VAL_PE_DECEASED(
  p_person_id IN NUMBER ,
  p_message_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate IGS_RE_THESIS examination submission date
  FUNCTION RESP_VAL_TEX_SBMSN(
  p_person_id IN NUMBER,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE,
  p_thesis_result_cd IN VARCHAR2 ,
  p_submission_dt IN DATE,
  p_legacy  IN VARCHAR2 DEFAULT 'N',
  p_final_title_ind IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate the IGS_RE_THESIS examination update
  FUNCTION RESP_VAL_TEX_UPD(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_transaction_type IN VARCHAR2 ,
  p_submission_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate IGS_RE_THESIS examination type
  FUNCTION RESP_VAL_TEX_TET(
  p_thesis_exam_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate IGS_RE_THESIS examination result code
  FUNCTION RESP_VAL_TEX_THR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_submission_dt IN DATE ,
  p_thesis_result_cd IN VARCHAR2 ,
  p_thesis_panel_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- To validate IGS_RE_THESIS_EXAM panel type
  FUNCTION RESP_VAL_TEX_TPT(
  p_thesis_panel_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_RE_VAL_TEX;

 

/
