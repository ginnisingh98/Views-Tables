--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_VEA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_VEA" AUTHID CURRENT_USER AS
/* $Header: IGSAS38S.pls 115.7 2002/11/28 22:48:51 nsidana ship $ */

--
-- bug id : 1956374
-- sjadhav , 29-aug-2001
-- removed function enrp_val_pc_closed
--
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_strt_end_dt
  --                            removed .
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of orgp_val_addr_type
  --                            removed .
  -------------------------------------------------------------------------------------------
 -- Validate the IGS_PE_PERSON address codes
  -- Retrofitted
  FUNCTION assp_val_vea_coraddr(
  p_venue_cd  IGS_AD_LOCVENUE_ADDR.location_venue_cd%TYPE ,
  p_addr_type  FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE ,
  p_start_dt  HZ_LOCATIONS.ADDRESS_EFFECTIVE_DATE%TYPE ,
  p_end_dt  HZ_LOCATIONS.ADDRESS_EXPIRATION_DATE%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Retrofitted
  FUNCTION ASSP_VAL_VEA_OVRLP(
  p_venue_cd  IGS_AD_LOCVENUE_ADDR.location_venue_cd%TYPE ,
  p_addr_type  FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE ,
  p_start_dt  HZ_LOCATIONs.ADDRESS_EFFECTIVE_DATE%TYPE ,
  p_end_dt  HZ_LOCATIONS.ADDRESS_EXPIRATION_DATE%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.

  PROCEDURE validate_address
  (
    p_city IN VARCHAR2,
    p_state IN VARCHAR2,
    p_province IN VARCHAR2,
    p_county IN VARCHAR2,
    p_country IN VARCHAR2,
    p_postcode IN VARCHAR2,
    p_valid_address OUT NOCOPY BOOLEAN,
    p_error_msg OUT NOCOPY VARCHAR2
  );

END IGS_AS_VAL_VEA;

 

/
