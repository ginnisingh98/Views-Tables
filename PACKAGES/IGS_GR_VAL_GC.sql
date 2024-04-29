--------------------------------------------------------
--  DDL for Package IGS_GR_VAL_GC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_VAL_GC" AUTHID CURRENT_USER AS
/* $Header: IGSGR02S.pls 115.4 2002/11/29 00:39:41 nsidana ship $ */
  --
  --
  -- Validate the graduation ceremony date aliases
  FUNCTION grdp_val_gc_dai(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_dt_alias IN VARCHAR2 ,
  p_ceremony_dai_sequence_number IN NUMBER ,
  p_closing_dt_alias IN VARCHAR2 ,
  p_closing_dai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the graduation ceremony can be updated
  FUNCTION grdp_val_gc_upd(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the ceremony round linked to the graduation ceremony
  FUNCTION grdp_val_gc_crd(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the start and end time of the graduation ceremony
  FUNCTION grdp_val_gc_times(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_venue_cd IN VARCHAR2 ,
  p_ceremony_dt_alias IN VARCHAR2 ,
  p_ceremony_dai_sequence_number IN NUMBER ,
  p_ceremony_start_time IN DATE ,
  p_ceremony_end_time IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the ins/upd/del to the graduation ceremony
  FUNCTION grdp_val_gc_iud(
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate if the venue has a system location type of CRD_CTR
  FUNCTION grdp_val_ve_lot(
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- To validate the venue closed indicator
  FUNCTION ASSP_VAL_VE_CLOSED(
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_GR_VAL_GC;

 

/
