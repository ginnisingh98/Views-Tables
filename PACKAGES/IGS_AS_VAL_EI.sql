--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_EI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_EI" AUTHID CURRENT_USER AS
/* $Header: IGSAS16S.pls 115.4 2002/11/28 22:43:37 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "assp_val_ve_closed"
  -------------------------------------------------------------------------------------------

  --
  -- Validate insert of IGS_AS_EXAM_INSTANCE record
  FUNCTION ASSP_VAL_EI_INS(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_ass_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

END IGS_AS_VAL_EI;

 

/
