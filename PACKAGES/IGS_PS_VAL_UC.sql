--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_UC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_UC" AUTHID CURRENT_USER AS
/* $Header: IGSPS59S.pls 115.4 2002/11/29 03:08:32 nsidana ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_uv_sys_sts
-- As part of the bug# 1956374 removed the function crsp_val_uv_exists


  -- Validate the IGS_PS_UNIT category for IGS_PS_UNIT categorisation
  FUNCTION crsp_val_uc_unit_cat(
  p_unit_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_PS_VAL_UC;

 

/
