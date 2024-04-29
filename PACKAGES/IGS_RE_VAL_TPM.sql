--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_TPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_TPM" AUTHID CURRENT_USER AS
/* $Header: IGSRE17S.pls 120.0 2005/06/01 13:53:58 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS removed
  --msrinivi    25-Aug-2001    Bug No.  1956374. the func genp_val_pe_deceased removed
  -------------------------------------------------------------------------------------------
  -- To validate IGS_RE_THESIS panel member minimum panel size
  FUNCTION RESP_VAL_TPM_MIN(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_thesis_panel_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate the IGS_RE_THESIS panel member chair indicator
  FUNCTION RESP_VAL_TPM_CHAIR(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate IGS_RE_THESIS panel member paid date
  FUNCTION RESP_VAL_TPM_PAID(
  p_paid_dt IN DATE ,
  p_confirmed_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate the IGS_RE_THESIS panel member confirmed date
  FUNCTION RESP_VAL_TPM_CNFRM(
  p_confirmed_dt IN DATE ,
  p_thesis_result_cd IN VARCHAR2 ,
  p_paid_dt IN DATE ,
  p_declined_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate IGS_RE_THESIS panel member declined date
  FUNCTION RESP_VAL_TPM_DCLN(
  p_declined_dt IN DATE ,
  p_confirmed_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate the IGS_RE_THESIS panel member IGS_PE_PERSON ID
  FUNCTION RESP_VAL_TPM_PE(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate the IGS_RE_THESIS panel member IGS_RE_THESIS result code
  FUNCTION RESP_VAL_TPM_THR(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_thesis_result_cd IN VARCHAR2 ,
  p_recommendation_summary IN VARCHAR2 ,
  p_confirmed_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate IGS_RE_THESIS panel member panel type
  FUNCTION RESP_VAL_TPM_TPMT(
  p_panel_member_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate IGS_RE_THESIS panel member updates
  FUNCTION RESP_VAL_TPM_UPD(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_transaction_type IN VARCHAR2 ,
  p_old_thesis_result_cd IN VARCHAR2 ,
  p_new_thesis_result_cd IN VARCHAR2 ,
  p_old_panel_member_type IN VARCHAR2 ,
  p_new_panel_member_type IN VARCHAR2 ,
  p_old_confirmed_dt IN DATE ,
  p_new_confirmed_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

END IGS_RE_VAL_TPM;

 

/
