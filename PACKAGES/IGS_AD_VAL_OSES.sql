--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_OSES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_OSES" AUTHID CURRENT_USER AS
/* $Header: IGSAD65S.pls 115.3 2002/11/28 21:38:41 nsidana ship $ */

  --
  -- Validate that at least one of subject_cd or subject_desc is entered
  FUNCTION ADMP_VAL_OSES_SUBJ(
  p_subject_cd IN VARCHAR2 ,
  p_subject_desc IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate tertiary edu unit attempt result type.
  FUNCTION admp_val_teua_sret(
  p_result_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_OSES;

 

/
