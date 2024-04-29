--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_GS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_GS" AUTHID CURRENT_USER AS
/* $Header: IGSAS23S.pls 115.4 2002/11/28 22:45:20 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_strt_end_dt
  --                            removed .
  -------------------------------------------------------------------------------------------
  -- Validate for one open version of grading schema
  FUNCTION assp_val_gs_one_open(
  p_grading_schema_cd IN IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE ,
  p_version_number IN IGS_AS_GRD_SCHEMA.version_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate for overlapping dates for grading schemas
  FUNCTION assp_val_gs_ovrlp(
  p_grading_schema_cd IN IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE ,
  p_version_number IN IGS_AS_GRD_SCHEMA.version_number%TYPE ,
  p_start_dt IN IGS_AS_GRD_SCHEMA.start_dt%TYPE ,
  p_end_dt IN IGS_AS_GRD_SCHEMA.end_dt%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AS_VAL_GS;

 

/
