--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_008" AUTHID CURRENT_USER AS
/* $Header: IGSAD08S.pls 115.6 2002/11/28 21:24:09 nsidana ship $ */

Function Admp_Get_Safs(
  p_adm_fee_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Saods(
  p_adm_offer_dfrmnt_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Saors(
  p_adm_offer_resp_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Saos(
  p_adm_outcome_status IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Admp_Get_Saos,WNDS,WNPS);

Function Admp_Get_Sauos(
  p_adm_unit_outcome_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Short_Dt(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER )
RETURN DATE;

Function Admp_Get_Status_Rule(
  p_person_id IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_admission_appl_number  NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_s_letter_parameter_type IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Sys_Aas(
  p_s_adm_appl_status IN VARCHAR2 )
RETURN VARCHAR2;

PROCEDURE get_acad_cal (
   p_adm_cal_type         IN  OUT NOCOPY     igs_ca_type.cal_type%TYPE,
   p_adm_seq              IN OUT NOCOPY   igs_ca_inst.sequence_number%TYPE,
   p_acad_cal_type        OUT NOCOPY      igs_ca_type.cal_type%TYPE,
   p_acad_seq             OUT NOCOPY      igs_ca_inst.sequence_number%TYPE,
   p_adm_alternate_code   OUT NOCOPY      igs_ca_inst.alternate_code%TYPE,
   p_message              OUT NOCOPY      VARCHAR2
);
END IGS_AD_GEN_008;

 

/
