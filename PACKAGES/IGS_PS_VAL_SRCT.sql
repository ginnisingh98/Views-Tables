--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_SRCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_SRCT" AUTHID CURRENT_USER AS
/* $Header: IGSPS55S.pls 115.3 2002/11/29 03:07:32 nsidana ship $ */
  --
  -- To validate the update of a system IGS_PS_COURSE group type record
  FUNCTION CRSP_VAL_SRCT_UPD(
  p_s_reference_cd_type IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
END IGS_PS_VAL_SRCT;

 

/
