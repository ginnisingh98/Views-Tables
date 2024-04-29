--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_ELS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_ELS" AUTHID CURRENT_USER AS
/* $Header: IGSAS18S.pls 115.5 2002/11/28 22:44:04 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function declaration of  genp_val_staff_prsn removed

  -------------------------------------------------------------------------------------------
 /*****  Bug No :   1956374
          Task   :   Duplicated Procedures and functions
          PROCEDURE  assp_val_actv_stdnt reference is changed ***/
  --
  -- Retrofitted
  FUNCTION assp_val_ve_lot(
  p_exam_location_cd  IGS_GR_VENUE_all.exam_location_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  --
  -- Validate IGS_AD_LOCATION closed indicator.
  FUNCTION orgp_val_loc_closed(
  p_location_cd IN IGS_AD_LOCATION_ALL.location_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AS_VAL_ELS;

 

/
