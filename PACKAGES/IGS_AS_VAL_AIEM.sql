--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_AIEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_AIEM" AUTHID CURRENT_USER AS
/* $Header: IGSAS13S.pls 115.4 2002/11/28 22:42:42 nsidana ship $ */
  --
  -- Retrofitted
  FUNCTION assp_val_aiem_catqty(
  p_s_material_cat  IGS_AS_ITM_EXAM_MTRL.s_material_cat%TYPE ,
  p_quantity_per_student  IGS_AS_ITM_EXAM_MTRL.quantity_per_student%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Retrofitted
  FUNCTION assp_val_ai_exmnbl(
  p_ass_id  IGS_AS_ASSESSMNT_ITM_ALL.ass_id%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Retrofitted
  FUNCTION assp_val_exmt_closed(
  p_exam_material_type  IGS_AS_EXM_MTRL_TYPE.exam_material_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AS_VAL_AIEM;

 

/
