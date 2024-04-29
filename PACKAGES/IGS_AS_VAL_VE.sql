--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_VE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_VE" AUTHID CURRENT_USER AS
/* $Header: IGSAS37S.pls 115.6 2002/11/28 22:48:37 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of orgp_val_loc_closed
  --                            removed .
  -------------------------------------------------------------------------------------------
  --msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed
  -- Validate IGS_AD_LOCATION closed indicator.
   -- As part of the bug# 1956374 prcodure assp_val_actv_stdnt is removed
  -- Retrofitted
  FUNCTION assp_val_ve_lot(
  p_exam_location_cd  IGS_GR_VENUE_ALL.exam_location_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  --
  -- Retrofitted
  FUNCTION assp_val_ve_reopen(
  p_exam_location_cd  IGS_GR_VENUE_ALL.exam_location_cd%TYPE ,
  p_closed_ind  IGS_GR_VENUE_ALL.closed_ind%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


END IGS_AS_VAL_VE;

 

/
