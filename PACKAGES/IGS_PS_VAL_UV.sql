--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_UV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_UV" AUTHID CURRENT_USER AS
/* $Header: IGSPS72S.pls 120.0 2005/06/01 16:06:28 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sarakshi    02-sep-2003     Enh#3052452,removed functions crsp_val_uv_sub_ind and crsp_val_uv_sup_ind
  --sarakshi    14-Nov-2002     Bug#2649028,modified function crsp_val_uv_pnt_ovr,crsp_val_uv_unit_sts
  --                            added parameter p_lgcy_validator
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_staff_prsn removed
  --bdeviset    21-JUL-004      Added procedure get_cp_values for Bug # 3782329

  -------------------------------------------------------------------------------------------
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_ou_sys_sts
-- As part of the bug# 1956374 removed the function crsp_val_ver_dt


  -- Validate the IGS_PS_UNIT level
  FUNCTION crsp_val_unit_lvl(
  p_unit_level IN CHAR ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate the credit point descritor for IGS_PS_UNIT version.
  FUNCTION crsp_val_uv_cp_desc(
  P_CREDIT_POINT_DESCRIPTOR IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the IGS_PS_UNIT internal IGS_PS_COURSE level for IGS_PS_UNIT version.
  FUNCTION crsp_val_uv_uicl(
  p_unit_int_course_level_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_UNIT version end date and IGS_PS_UNIT version status
  FUNCTION crsp_val_uv_end_sts(
  p_end_dt IN DATE ,
  p_unit_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_UNIT version expiry date and IGS_PS_UNIT version status.
  FUNCTION crsp_val_uv_exp_sts(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_expiry_dt IN DATE ,
  p_unit_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate points increment, min and max fields against points override.
  FUNCTION crsp_val_uv_pnt_ovrd(
  p_points_override_ind IN VARCHAR2 ,
  p_points_increment IN NUMBER ,
  p_points_min IN NUMBER ,
  p_points_max IN NUMBER ,
  p_enrolled_credit_points IN NUMBER ,
  p_achievable_credit_points IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_lgcy_validator IN BOOLEAN DEFAULT FALSE)
RETURN BOOLEAN;

  --
  -- Validate the IGS_PS_UNIT status for IGS_PS_UNIT version
  FUNCTION crsp_val_uv_unit_sts(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_new_unit_status IN VARCHAR2 ,
  p_old_unit_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_lgcy_validator IN BOOLEAN DEFAULT FALSE)
RETURN BOOLEAN;
  --
  -- Perform quality validation checks on a IGS_PS_UNIT version and its details.
  FUNCTION crsp_val_uv_quality(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_old_unit_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate supplementary exam indicator against the assessable indicator
  FUNCTION CRSP_VAL_UV_SUP_EXAM(
  p_supp_exam_permitted_ind IN VARCHAR2 ,
  p_assessable_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate students fall within new override limits set
  FUNCTION crsp_val_uv_cp_ovrd(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_points_override_ind IN VARCHAR2 DEFAULT 'N',
  p_points_min IN NUMBER ,
  p_points_max IN NUMBER ,
  p_points_increment IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate discont sua with pass grade within new uv overrides.
  FUNCTION crsp_val_uv_dsc_ovrd(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_points_min IN NUMBER ,
  p_points_max IN NUMBER ,
  p_points_increment IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_UNIT attempts when ending IGS_PS_UNIT version.
  FUNCTION crsp_val_uv_end(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate if students have IGS_EN_SU_ATTEMPT IGS_PE_TITLE override set
  FUNCTION crsp_val_uv_ttl_ovrd(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_title_override_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

 -- gets the Enrolled, Audit and Billable credit point values for the passes unit section
 PROCEDURE get_cp_values(
  p_uoo_id IN IGS_PS_UNIT_OFR_OPT_ALL.uoo_id%TYPE,
  p_enrolled_cp OUT NOCOPY IGS_PS_USEC_CPS.enrolled_credit_points%TYPE,
  p_billable_cp OUT NOCOPY IGS_PS_USEC_CPS.billing_hrs%TYPE,
  p_audit_cp OUT NOCOPY IGS_PS_USEC_CPS.billing_credit_points%TYPE );
  PRAGMA RESTRICT_REFERENCES (get_cp_values,WNDS,WNPS);

END IGS_PS_VAL_UV;

 

/
