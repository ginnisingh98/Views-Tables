--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_ATT" AUTHID CURRENT_USER AS
 /* $Header: IGSPS11S.pls 115.4 2002/11/29 02:56:22 nsidana ship $ */


  -- Validate Govt Attendance Type is not closed.
  FUNCTION CRSP_VAL_ATT_GOVT(
  p_govt_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;



  -- To validate the attendance type load ranges
  FUNCTION crsp_val_att_rng(
  p_lower_enr_load_range IN NUMBER ,
  p_upper_enr_load_range IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
PRAGMA RESTRICT_REFERENCES(crsp_val_att_rng, WNDS);

END IGS_PS_VAL_ATT;

 

/
