--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_TRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_TRO" AUTHID CURRENT_USER AS
/* $Header: IGSPS58S.pls 115.4 2002/11/29 03:08:18 nsidana ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_ou_sys_sts

  --
  -- Validate teaching responsibility override percentages = 100%
  FUNCTION CRSP_VAL_TRO_PERC(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_PS_VAL_TRo;

 

/
