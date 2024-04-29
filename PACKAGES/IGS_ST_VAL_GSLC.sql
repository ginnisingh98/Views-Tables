--------------------------------------------------------
--  DDL for Package IGS_ST_VAL_GSLC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_VAL_GSLC" AUTHID CURRENT_USER AS
/* $Header: IGSST11S.pls 115.6 2002/11/29 04:12:38 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (STAP_VAL_GSC_SDT_UPD) - from the spec and body. -- kdande
*/
  -- Validate the govt semester load calendar is type Load and is Active.
  FUNCTION stap_val_gslc(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_ST_VAL_GSLC;

 

/
