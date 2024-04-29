--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_SCAE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_SCAE" AUTHID CURRENT_USER AS
/* $Header: IGSEN62S.pls 115.3 2002/11/29 00:06:03 nsidana ship $ */
  --
  -- Validate the student COURSE attempt enrolment category.
  FUNCTION ENRP_VAL_SCAE_EC(
  p_enrolment_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SCAE_EC , WNDS);
END IGS_EN_VAL_SCAE;

 

/
