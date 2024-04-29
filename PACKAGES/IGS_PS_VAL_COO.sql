--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_COO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_COO" AUTHID CURRENT_USER AS
/* $Header: IGSPS25S.pls 115.4 2002/11/29 02:59:57 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_staff_prsn removed

  -------------------------------------------------------------------------------------------
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_loc_cd
  --

  -- Validate IGS_PS_COURSE offering option attendance mode.
  FUNCTION crsp_val_coo_am(
  p_attendance_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate that IGS_PS_COURSE offering option attendance type.
  FUNCTION crsp_val_coo_att(
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_COo;

 

/
