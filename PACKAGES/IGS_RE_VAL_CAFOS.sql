--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_CAFOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_CAFOS" AUTHID CURRENT_USER AS
/* $Header: IGSRE05S.pls 115.4 2002/11/29 03:27:49 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS
  --                            removed .
  -------------------------------------------------------------------------------------------
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (RESP_VAL_CA_CHILDUPD) - from the spec and body. -- kdande
*/
  -- Validate IGS_RE_CANDIDATURE field of study percentage.
  FUNCTION resp_val_cafos_perc(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate IGS_RE_CANDIDATURE field of study.
  FUNCTION resp_val_cafos_fos(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_field_of_study IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate if IGS_PS_FLD_OF_STUDY.field_of_study is closed.
  FUNCTION crsp_val_fos_closed(
  p_field_of_study IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_RE_VAL_CAFOS;

 

/
