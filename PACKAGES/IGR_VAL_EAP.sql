--------------------------------------------------------
--  DDL for Package IGR_VAL_EAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_VAL_EAP" AUTHID CURRENT_USER AS
/* $Header: IGSRT08S.pls 120.0 2005/06/02 04:08:35 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sjlaport    18-Feb-05       Created for IGR Migration
  ------------------------------------------------------------------------------------------

  -- Validate the Enquiry application status.
  FUNCTION admp_val_eap_es_comp(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_enquiry_status IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate the admission enquiry academic calendar.
  FUNCTION admp_val_ae_acad_cal(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate the admission enquiry admission calendar.
  FUNCTION admp_val_ae_adm_cal(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate the Enquiry applicant has a current address.
  FUNCTION admp_val_eap_addr(
  p_person_id IN NUMBER ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate the Enquiry application status on insert.
  FUNCTION admp_val_eap_reg(
  p_enquiry_status IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate the Enquiry application status.
  FUNCTION admp_val_eap_status(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_old_enquiry_status IN VARCHAR2 ,
  p_new_enquiry_status IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate the Enquiry completion status.
  FUNCTION admp_val_eap_comp(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate the Enquiry Status closed indicator.
  FUNCTION admp_val_es_status(
  p_enquiry_status IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- To validate the indicated mailing date of the enquiry package.
  FUNCTION admp_val_eap_ind_dt(
  p_enquiry_dt IN DATE ,
  p_indicated_mailing_dt IN DATE ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;


END IGR_VAL_EAP;

 

/
