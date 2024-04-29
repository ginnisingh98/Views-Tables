--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_ECPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_ECPD" AUTHID CURRENT_USER AS
/* $Header: IGSEN35S.pls 115.3 2002/11/28 23:57:50 nsidana ship $ */
  --
  -- To validate enr category procedure detail comm type
  FUNCTION ENRP_VAL_ECPD_COMM(
  p_enrolment_cat IN VARCHAR2 ,
  p_enr_method_type IN VARCHAR2 ,
  p_s_student_comm_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES (ENRP_VAL_ECPD_COMM,WNDS);
  --
  -- To validate the enrol method type for the ecpd
  FUNCTION enrp_val_ecpd_emt(
  p_enrolment_method_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES (enrp_val_ecpd_emt,WNDS);
END IGS_EN_VAL_ECPD;

 

/
