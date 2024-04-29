--------------------------------------------------------
--  DDL for Package IGS_OR_VAL_LR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_VAL_LR" AUTHID CURRENT_USER AS
/* $Header: IGSOR07S.pls 115.4 2002/11/29 01:47:39 nsidana ship $ */

  -- Validate the location relationship.
  FUNCTION orgp_val_lr(
  p_location_cd IN VARCHAR2 ,
  p_sub_location_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the location.
  FUNCTION orgp_val_loc_cd(
  p_location_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Retrofitted
  FUNCTION assp_val_lr_dfltslot(
  p_location_cd  IGS_AD_LOCATION_REL.location_cd%TYPE ,
  p_sub_location_cd  IGS_AD_LOCATION_REL.sub_location_cd%TYPE ,
  p_dflt_ind  IGS_AD_LOCATION_REL.dflt_ind%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Retrofitted
  FUNCTION assp_val_lr_dflt_one(
  p_location_cd  IGS_AD_LOCATION_REL.location_cd%TYPE ,
  p_sub_location_cd  IGS_AD_LOCATION_REL.sub_location_cd%TYPE ,
  p_sub_s_location_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Retrofitted
  FUNCTION assp_val_lr_lr(
  p_location_cd  IGS_AD_LOCATION_REL.location_cd%TYPE ,
  p_sub_location_cd  IGS_AD_LOCATION_REL.sub_location_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_OR_VAL_LR;

 

/
