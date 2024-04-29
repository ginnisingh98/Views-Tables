--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_CSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_CSC" AUTHID CURRENT_USER AS
/* $Header: IGSRE07S.pls 115.4 2002/11/29 03:28:21 nsidana ship $ */
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
  -- Validate IGS_RE_CANDIDATURE socio-economic classification code percentage.
  FUNCTION resp_val_csc_perc(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate IGS_RE_CANDIDATURE socio-economic classification code.
  FUNCTION resp_val_csc_seocc(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_seo_class_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate if  Socio-Economic Classification Code is closed.
  FUNCTION resp_val_seocc_clsd(
  p_seo_class_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_RE_VAL_CSC;

 

/
