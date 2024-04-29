--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_013
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_013" AUTHID CURRENT_USER AS
/* $Header: IGSEN13S.pls 115.5 2002/11/28 23:53:45 nsidana ship $ */

-- Modification By : jbegum
-- Modification    : Removed the following 3 functions:
--                   Enrp_Val_Sca_Fs , Enrp_Val_Sua_Excld , Enrp_Val_Sua_Pre
--                   The functions  Enrp_Val_Sca_Fs , Enrp_Val_Sua_Excld were not being called from anywhere .
--                   Also identical functions were present in the packages of IGSEN61B.pls and IGSEN68B.pls .
--	 	     Hence these two functions were removed
--                   The function Enrp_Val_Sua_Pre was being called from the package in IGSEN09B.pls.But the
--                   exact replica of it was found in IGSEN68B.pls.Hence it was removed and the call to
--		     this function from IGSEN09B.pls was replaced with the call to its replica in IGSEN68B.pls


Function Enrp_Upd_Sci_Ua(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name out NOCOPY Varchar2 )
RETURN boolean;

Function Enrp_Upd_Susa_End_Dt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_end_dt IN DATE ,
  p_voluntary_end_ind IN VARCHAR2 DEFAULT 'N',
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;


Function Enrp_Upd_Susa_Sci(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;

END IGS_EN_GEN_013;

 

/
