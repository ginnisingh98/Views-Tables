--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CST" AUTHID CURRENT_USER AS
 /* $Header: IGSPS36S.pls 115.4 2002/11/29 03:02:34 nsidana ship $ */

  ----------------------------------------------------------------------------
  --  Change History :
  --  Who             When            What
  -- avenkatr   30-AUG-2001     Bug No 1956374. Removed procedure "crsp_Val_iud_crv_dtl"
  ----------------------------------------------------------------------------

  -- Validate if the IGS_PS_COURSE stage type is unique for this IGS_PS_COURSE version
  FUNCTION crsp_val_cst_cstt(
  p_course_cd IN IGS_PS_STAGE.course_cd%TYPE ,
  p_version_number IN IGS_PS_STAGE.version_number%TYPE ,
  p_sequence_number IN IGS_PS_STAGE.sequence_number%TYPE ,
  p_course_stage_type IN IGS_PS_STAGE.course_stage_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the IGS_PS_COURSE stage type closed indicator.
  FUNCTION crsp_val_cstt_closed(
  p_course_stage_type IN IGS_PS_STAGE_TYPE.course_stage_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;


END IGS_PS_VAL_CST;

 

/
