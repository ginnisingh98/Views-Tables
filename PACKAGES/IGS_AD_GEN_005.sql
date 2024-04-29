--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_005" AUTHID CURRENT_USER AS
/* $Header: IGSAD05S.pls 120.0 2005/06/02 03:35:54 appldev noship $ */
Function Admp_Get_Crv_Strt_Dt(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER )
RETURN DATE;

PRAGMA RESTRICT_REFERENCES (Admp_Get_Crv_Strt_Dt,wnds,wnps);

Function Admp_Get_Dflt_Ccm(
  p_admission_cat IN VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Dflt_Ecm(
  p_admission_cat IN VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Dflt_Fcm(
  p_admission_cat IN VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Dflt_Fs(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Dflt_Hpo(
  p_admission_cat IN VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Dflt_Uc(
  p_unit_mode IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Dflt_Um(
  p_unit_class IN VARCHAR2 )
RETURN VARCHAR2;

END IGS_AD_GEN_005;

 

/
