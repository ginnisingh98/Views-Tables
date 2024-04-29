--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_ECPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_ECPS" AUTHID CURRENT_USER AS
/* $Header: IGSEN36S.pls 115.3 2002/11/28 23:58:04 nsidana ship $ */
  --
  -- Validate the enrolment cat procedure step system enrolment step type.
  FUNCTION enrp_val_ecps_sest(
  p_s_enrolment_step_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_ecps_sest,WNDS);
END IGS_EN_VAL_ECPS;

 

/
