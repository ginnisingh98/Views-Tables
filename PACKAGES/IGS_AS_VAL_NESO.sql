--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_NESO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_NESO" AUTHID CURRENT_USER AS
/* $Header: IGSAS26S.pls 115.6 2002/11/28 22:46:06 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function declaration of orgp_val_loc_closed
  --                            removed .
  -------------------------------------------------------------------------------------------
  -- As part of the bug# 1956374 removed the function crsp_val_ucl_closed
  -- As part of the bug# 1956374 removed the function crsp_val_um_closed

  -- Validate the insert of a IGS_AS_NON_ENR_STDOT record
  FUNCTION ASSP_VAL_NESO_INS(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_mark IN NUMBER ,
  p_grade IN VARCHAR2 ,
  p_grading_schema_cd IN VARCHAR2,
  p_gs_version_number IN NUMBER,
  p_s_grade_creation_method_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

END IGS_AS_VAL_NESO;

 

/
