--------------------------------------------------------
--  DDL for Package IGS_OR_VAL_LOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_VAL_LOT" AUTHID CURRENT_USER AS
/* $Header: IGSOR06S.pls 115.4 2002/11/29 01:47:23 nsidana ship $ */
  -- Retrofitted
  FUNCTION assp_val_lot_loc(
  p_location_type  IGS_AD_LOCATION_TYPE_ALL.location_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_OR_VAL_LOT;

 

/
