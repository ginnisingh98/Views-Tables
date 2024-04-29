--------------------------------------------------------
--  DDL for Package IGS_OR_VAL_LOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_VAL_LOC" AUTHID CURRENT_USER AS
/* $Header: IGSOR05S.pls 115.5 2002/11/29 01:47:02 nsidana ship $ */
 -- As part of the bug# 1956374 prcodure assp_val_actv_stdnt is removed
 --msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed
  --
  -- Validate the location type.
  FUNCTION orgp_val_loc_type(
  p_location_type IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Retrofitted
  FUNCTION assp_val_loc_coord(
  p_location_type  IGS_AD_LOCATION_ALL.location_type%TYPE ,
  p_coord_person_id  IGS_AD_LOCATION_ALL.coord_person_id%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Retrofitted
  FUNCTION assp_val_loc_ve_open(
  p_location_cd  IGS_AD_LOCATION_ALL.location_cd%TYPE ,
  p_location_type  IGS_AD_LOCATION_ALL.location_type%TYPE ,
  p_closed_ind  IGS_AD_LOCATION_ALL.closed_ind%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Retrofitted
  FUNCTION assp_val_loc_ve_xist(
  p_location_cd  IGS_AD_LOCATION_ALL.location_cd%TYPE ,
  p_new_location_type  IGS_AD_LOCATION_ALL.location_type%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --

  --

END IGS_OR_VAL_LOC;

 

/
