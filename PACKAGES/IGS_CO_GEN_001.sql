--------------------------------------------------------
--  DDL for Package IGS_CO_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSCO01S.pls 115.3 2002/02/12 16:41:57 pkm ship    $ */
FUNCTION CORP_GET_COR_CAT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 DEFAULT null)
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(CORP_GET_COR_CAT,WNDS);
--
FUNCTION corp_get_let_title(
  p_correspondence_type IN VARCHAR2 ,
  p_letter_reference_number IN NUMBER )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(corp_get_let_title,WNDS);
--
FUNCTION corp_get_ocr_refnum(
  p_s_other_reference_type IN VARCHAR2 ,
  p_other_reference IN VARCHAR2 )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(corp_get_ocr_refnum,WNDS);
--
FUNCTION cors_get_ocv_issuedt(
  p_person_id IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cv_version_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_s_other_reference_type IN VARCHAR2 ,
  p_other_reference IN VARCHAR2 )
 RETURN DATE;
PRAGMA RESTRICT_REFERENCES(cors_get_ocv_issuedt,WNDS);
--
END IGS_CO_GEN_001;

 

/
