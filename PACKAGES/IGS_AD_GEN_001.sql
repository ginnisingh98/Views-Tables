--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSAD01S.pls 120.2 2005/08/10 21:06:29 appldev ship $ */

Function Admp_Del_Aa_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Function Admp_Del_Acaiu_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Function Admp_Del_Acai_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


Function Admp_Del_Aca_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Procedure Admp_Del_Sca_Unconf(
  p_log_creation_dt OUT NOCOPY DATE );

Procedure SET_TOKEN(token varchar2);
PROCEDURE Check_Mand_Person_Type
(
  p_person_id       IN HZ_PARTIES.PARTY_ID%TYPE,
  p_data_element    IN IGS_PE_STUP_DATA_EMT_ALL.data_element%TYPE,
  p_required_ind    OUT NOCOPY IGS_PE_STUP_DATA_EMT_ALL.required_ind%TYPE
);

FUNCTION get_user_form_name (p_function_name VARCHAR2) RETURN VARCHAR2;

END IGS_AD_GEN_001;

 

/
