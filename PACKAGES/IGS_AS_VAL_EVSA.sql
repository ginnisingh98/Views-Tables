--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_EVSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_EVSA" AUTHID CURRENT_USER AS
/* $Header: IGSAS22S.pls 115.5 2002/11/28 22:45:03 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "assp_val_ve_closed"
  -------------------------------------------------------------------------------------------

  --
  -- Validate delete of exam_venue_session_availability
  FUNCTION ASSP_VAL_EVSA_DEL(
  p_ese_id IN NUMBER ,
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
RETURN boolean;

  --
  -- To validate the calendar instance system cal status is not 'INACTIVE'
  FUNCTION ASSP_VAL_CI_STATUS(
  p_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_message_name OUT NOCOPY varchar2 )
RETURN boolean;

END IGS_AS_VAL_EVSA;

 

/
