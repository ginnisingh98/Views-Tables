--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CEPRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CEPRC" AUTHID CURRENT_USER AS
/* $Header: IGSPS18S.pls 115.5 2002/11/29 02:57:52 nsidana ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_ref_cd_type
-- As a part of the bug#2146753 removed the function crsp_val_ceprc_uref

  -- Validate unique combination of IGS_PS_UNIT set and IGS_PS_COURSE offerning option
  FUNCTION crsp_val_ceprc_uniq(
  p_coo_id IN NUMBER ,
  p_reference_cd_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate crs  entry point IGS_PS_UNIT set against crs offer option IGS_PS_UNIT set
  FUNCTION crsp_val_ceprc_coous(
  p_coo_id IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;
END IGS_PS_VAL_CEPRC;

 

/
