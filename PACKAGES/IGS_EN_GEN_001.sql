--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_001" AUTHID CURRENT_USER as
/* $Header: IGSEN01S.pls 120.0 2005/06/02 03:40:57 appldev noship $ */
 -------------------------------------------------------------------------------------------
 --Change History:
 --Who         When            What
 --kkillams    24-04-2003      New parameter p_uoo_id is added to the Enrp_Del_Sua_Trnsfr,
 --                            Enrp_Del_Sua_Sut and Enrp_Del_Suao_Discon procedures
 --                            w.r.t. bug number 2829262
 -------------------------------------------------------------------------------------------

Function Check_HRMS_Installed
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Check_HRMS_Installed, WNDS,WNPS);

PROCEDURE Enrp_Clc_Crrnt_Acad(
  p_cal_type IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_sequence_number OUT NOCOPY NUMBER );

PROCEDURE Enrp_Clc_Sca_Acad(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_cal_type OUT NOCOPY VARCHAR2 ,
  p_sequence_number OUT NOCOPY NUMBER );

FUNCTION Enrp_Clc_Sca_Pass_Cp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(Enrp_Clc_Sca_Pass_Cp, WNDS,WNPS);

PROCEDURE Enrp_Del_Suao_Discon(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_discontinued_dt     IN DATE,
  p_uoo_id              IN NUMBER);

FUNCTION Enrp_Del_Sua_Sut(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER )
RETURN BOOLEAN;


FUNCTION Enrp_Del_Sua_Trnsfr(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER)
RETURN BOOLEAN;


FUNCTION Enrp_Del_Susa_Hist(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;


FUNCTION Enrp_Del_Susa_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;


END IGS_EN_GEN_001;

 

/
