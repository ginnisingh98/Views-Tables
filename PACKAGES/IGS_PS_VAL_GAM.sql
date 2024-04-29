--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_GAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_GAM" AUTHID CURRENT_USER AS
 /* $Header: IGSPS44S.pls 115.3 2002/11/29 03:04:23 nsidana ship $ */

  --
  -- To validate the update of a Govt attendance mode record
  FUNCTION CRSP_VAL_GAM_UPD(
  p_govt_attendance_mode IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
END IGS_PS_VAL_GAM;

 

/
