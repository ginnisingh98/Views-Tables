--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_006" AUTHID CURRENT_USER AS
/* $Header: IGSAD06S.pls 115.6 2002/11/28 21:23:46 nsidana ship $ */
Function Admp_Get_Encmb_Dt(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER )
RETURN DATE;

Procedure Admp_Get_Enq_Pp(
  p_oracle_username IN VARCHAR2 ,
  p_enq_acad_cal_type OUT NOCOPY VARCHAR2 ,
  p_enq_acad_ci_sequence_number OUT NOCOPY NUMBER ,
  p_enq_acad_alternate_code OUT NOCOPY VARCHAR2 ,
  p_enq_acad_abbreviation OUT NOCOPY VARCHAR2 ,
  p_enq_adm_cal_type OUT NOCOPY VARCHAR2 ,
  p_enq_adm_ci_sequence_number OUT NOCOPY NUMBER ,
  p_enq_adm_alternate_code OUT NOCOPY VARCHAR2 ,
  p_enq_adm_abbreviation OUT NOCOPY VARCHAR2 );

Function Admp_Get_Itt_Amttyp(
  p_intake_target_type IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Iv_Addr(
  p_person_id IN NUMBER )
RETURN VARCHAR2;


Function Admp_Get_Let_Resp_Dt(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN VARCHAR2;


Function Admp_Get_Lvl_Qual(
  p_tac_level_of_qual IN VARCHAR2 )
RETURN VARCHAR2;

END IGS_AD_GEN_006;

 

/
