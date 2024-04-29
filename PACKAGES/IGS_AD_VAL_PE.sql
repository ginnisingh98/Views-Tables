--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_PE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_PE" AUTHID CURRENT_USER AS
/* $Header: IGSAD66S.pls 115.3 2002/11/28 21:38:55 nsidana ship $ */

  --
  -- To validate duplicate person records using surname and birthdate
  FUNCTION ADMP_VAL_PE_DPLCT(
  p_person_id IN NUMBER ,
  p_surname IN VARCHAR2 ,
  p_birth_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
  --
  -- Validate the person deceased indicator.
  FUNCTION admp_val_pe_deceased(
  p_deceased_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_PE;

 

/
