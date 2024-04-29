--------------------------------------------------------
--  DDL for Package IGS_GR_VAL_CRD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_VAL_CRD" AUTHID CURRENT_USER AS
/* $Header: IGSGR06S.pls 115.5 2002/11/29 00:40:29 nsidana ship $ */
  --
  -- BUG #1956374 ,w.r.t Duplicated procedures and functions
  -- Procedure assp_val_ci_status is removed
  -- Validate if the calendar instance has a category of GRADUATION
  FUNCTION grdp_val_ci_grad(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_GR_VAL_CRD;

 

/
