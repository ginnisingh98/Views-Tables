--------------------------------------------------------
--  DDL for Package IGS_PS_GEN_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_GEN_007" AUTHID CURRENT_USER AS
 /* $Header: IGSPS07S.pls 115.6 2003/11/05 18:44:00 ijeddy ship $ */

FUNCTION crsp_get_rct_srct(
  p_reference_cd_type IN IGS_GE_REF_CD_TYPE_ALL.reference_cd_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
;

PROCEDURE crsp_ins_cow_hist(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_percentage IN NUMBER )
;

PROCEDURE crsp_ins_crc_hist(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_reference_cd_type IN VARCHAR2 ,
  p_reference_cd IN VARCHAR2 ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_description IN VARCHAR2 )
;

 PROCEDURE crsp_ins_cul_hist(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_course_type  VARCHAR2 DEFAULT NULL,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_unit_level IN VARCHAR2 ,
  p_wam_weighting IN NUMBER ,
  p_course_cd VARCHAR2,
  p_course_version_number NUMBER )
;

END IGS_PS_GEN_007;

 

/
