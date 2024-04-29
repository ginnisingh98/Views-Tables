--------------------------------------------------------
--  DDL for Package IGS_OR_VAL_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_VAL_OA" AUTHID CURRENT_USER AS
/* $Header: IGSOR08S.pls 115.7 2002/11/29 01:47:55 nsidana ship $ */

--
-- bug id : 1956374
-- sjadhav , 29-aug-2001
-- removed function enrp_val_pc_closed
--

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_strt_end_dt
  --                            removed .
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of orgp_val_addr_type
  --                            removed .
  -------------------------------------------------------------------------------------------
  --
  -- Validate that there is only one cor address per org unit
  FUNCTION orgp_val_oa_cor_addr(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate that only one org unit address is open per address type
  FUNCTION orgp_val_oa_one_open(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate that date overlaps do not exist for an org unit
  FUNCTION orgp_val_oa_ovrlp(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  --

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
END IGS_OR_VAL_OA;

 

/
