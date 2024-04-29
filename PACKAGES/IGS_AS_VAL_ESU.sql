--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_ESU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_ESU" AUTHID CURRENT_USER AS
/* $Header: IGSAS20S.pls 115.4 2002/11/28 22:44:33 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The The function declaration of genp_val_staff_prsn removed
  --msrinivi    29 aug2001       Bug 1956374 Removed genp_val_prsn_id

  -------------------------------------------------------------------------------------------
-- Bug #1956374
-- As part of the bug# 1956374 removed the function  crsp_val_ou_sys_sts
-- Bug No 1956374 , Procedure assp_val_actv_stdnt is removed
  --
 -- Validate if the exam supervisor type is not closed.
  FUNCTION ASSP_VAL_EST_CLOSED(
  p_exam_supervisor_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --

END IGS_AS_VAL_ESU;

 

/
