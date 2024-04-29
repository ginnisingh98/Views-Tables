--------------------------------------------------------
--  DDL for Package IGS_ST_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSST01S.pls 120.0 2005/06/01 19:01:50 appldev noship $ */
-- svenkata	25-02-02     Removed the procedure Stap_Del_Ess  as part of CCR
--                           ENCR024 .Bug # 2239050

Function Stap_Get_Att_Mode(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Stap_Get_Att_Mode,WNDS,WNPS);

Function Stap_Get_Comm_Stdnt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_commencement_dt IN OUT NOCOPY DATE ,
  p_collection_yr IN NUMBER )
RETURN VARCHAR2;

END IGS_ST_GEN_001;

 

/
