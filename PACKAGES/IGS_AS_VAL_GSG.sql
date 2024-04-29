--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_GSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_GSG" AUTHID CURRENT_USER AS
/* $Header: IGSAS24S.pls 115.3 2002/11/28 22:45:38 nsidana ship $ */
  --
  -- Validate grade's gs date range is current or future
  FUNCTION assp_val_gs_cur_fut(
  p_grading_schema_cd IN IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE ,
  p_version_number IN IGS_AS_GRD_SCHEMA.version_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Retrofitted
  FUNCTION genp_val_dt_range(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate upper mark range >= lower mark range and both set if one set
  FUNCTION assp_val_gsg_mrk_rng(
  p_lower_mark_range IN IGS_AS_GRD_SCH_GRADE.lower_mark_range%TYPE ,
  p_upper_mark_range IN IGS_AS_GRD_SCH_GRADE.upper_mark_range%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate max percentage >= min percentage
  FUNCTION assp_val_gsg_min_max(
  p_min_percentage IN IGS_AS_GRD_SCH_GRADE.min_percentage%TYPE ,
  p_max_percentage IN IGS_AS_GRD_SCH_GRADE.max_percentage%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate mark range does not overlap with other grades in GS version
  FUNCTION assp_val_gsg_m_ovrlp(
  p_grading_schema_cd IN IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE ,
  p_version_number IN IGS_AS_GRD_SCH_GRADE.version_number%TYPE ,
  p_grade IN IGS_AS_GRD_SCH_GRADE.grade%TYPE ,
  p_lower_mark_range IN IGS_AS_GRD_SCH_GRADE.lower_mark_range%TYPE ,
  p_upper_mark_range IN IGS_AS_GRD_SCH_GRADE.upper_mark_range%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate only 1 grade exists in a GS with the dflt outstanding ind set
  FUNCTION assp_val_gsg_dflt(
  p_grading_schema_cd IN IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE ,
  p_version_number IN IGS_AS_GRD_SCH_GRADE.version_number%TYPE ,
  p_grade IN IGS_AS_GRD_SCH_GRADE.grade%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  --
  -- Validate the result for a grade cannot be chngd when translat'ns exist
  FUNCTION assp_val_gsg_gsgt(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate special grade type.
  FUNCTION assp_val_gsg_ssgt(
  p_s_special_grade_type IN VARCHAR2 ,
  p_s_result_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AS_VAL_GSG;

 

/
