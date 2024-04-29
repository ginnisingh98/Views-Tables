--------------------------------------------------------
--  DDL for Package IGS_PS_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_GEN_005" AUTHID CURRENT_USER AS
 /* $Header: IGSPS05S.pls 115.4 2002/11/29 02:54:33 nsidana ship $ */

FUNCTION CRSP_DEL_TRO_HIST(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


FUNCTION crsp_ins_calul(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_yr_num IN NUMBER ,
  p_effective_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

PROCEDURE CRSP_INS_TRO_HIST(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_new_percentage IN NUMBER ,
  p_old_percentage IN NUMBER ,
  p_new_update_who IN VARCHAR2 ,
  p_old_update_who IN VARCHAR2 ,
  p_new_update_on IN DATE ,
  p_old_update_on IN DATE )
;

PROCEDURE crsp_ins_tr_hist(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_percentage IN NUMBER )
;

PROCEDURE crsp_ins_ud_hist(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_discipline_group_cd IN VARCHAR2 ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_percentage IN NUMBER )
;

PROCEDURE crsp_ins_urc_hist(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_reference_cd_type IN VARCHAR2 ,
  p_reference_cd IN VARCHAR2 ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_description IN VARCHAR2 )
;

END IGS_PS_GEN_005;

 

/
