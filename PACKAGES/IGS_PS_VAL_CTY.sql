--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CTY" AUTHID CURRENT_USER AS
 /* $Header: IGSPS37S.pls 115.3 2002/11/29 03:02:50 nsidana ship $ */
  --
  -- Validate IGS_PS_COURSE type government IGS_PS_COURSE type.
  FUNCTION crsp_val_cty_govt(
  p_govt_course_type IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_COURSE type IGS_PS_COURSE type group code.
  FUNCTION crsp_val_cty_group(
  p_course_type_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_COURSE type IGS_PS_AWD IGS_PS_COURSE indicator.
  FUNCTION crsp_val_cty_award(
  p_course_type IN VARCHAR2 ,
  p_award_course_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_CTY;

 

/
