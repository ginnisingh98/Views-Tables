--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CALUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CALUL" AUTHID CURRENT_USER AS
/* $Header: IGSPS15S.pls 115.4 2002/11/29 02:57:08 nsidana ship $ */
-- As part of the bug# 1956374 added pragma to  the function crsp_val_uv_sys_sts

  --
  -- Validate that the IGS_PS_UNIT version exists.
  FUNCTION crsp_val_uv_exists(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_UNIT version system status.
  FUNCTION crsp_val_uv_sys_sts(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(crsp_val_uv_sys_sts,WNDS);

END IGS_PS_VAL_CALul;

 

/
