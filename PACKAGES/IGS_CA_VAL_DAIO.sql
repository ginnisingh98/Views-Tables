--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_DAIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_DAIO" AUTHID CURRENT_USER AS
/* $Header: IGSCA08S.pls 115.4 2002/11/28 22:58:05 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "calp_val_holidat_cat"
  -------------------------------------------------------------------------------------------

--
  -- Validate insert of IGS_CA_DA_INST_OFST
  FUNCTION CALP_VAL_DAIO_INS(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_offset_dt_alias IN VARCHAR2 ,
  p_offset_dai_sequence_number IN NUMBER ,
  p_offset_cal_type IN VARCHAR2 ,
  p_offset_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
  --
  -- Validate if a IGS_CA_DA_INST_OFST can be deleted.
  FUNCTION CALP_VAL_DAIO_DEL(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_offset_dt_alias IN VARCHAR2 ,
  p_offset_dai_sequence_number IN NUMBER ,
  p_offset_cal_type IN VARCHAR2 ,
  p_offset_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
END IGS_CA_VAL_DAIO;

 

/
