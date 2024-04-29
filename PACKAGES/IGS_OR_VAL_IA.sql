--------------------------------------------------------
--  DDL for Package IGS_OR_VAL_IA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_VAL_IA" AUTHID CURRENT_USER AS
/* $Header: IGSOR02S.pls 115.6 2002/11/29 01:46:01 nsidana ship $ */

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
  -- Validate that there is only one cor address per institution
  FUNCTION orgp_val_ia_cor_addr(
  p_institution_cd IN VARCHAR2 ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate that only one institution address is open per address type
  FUNCTION orgp_val_ia_one_open(
  p_institution_cd IN VARCHAR2 ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate that address dates do not overlap for an institution
  FUNCTION orgp_val_ia_ovrlp(
  p_institution_cd IN VARCHAR2 ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
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

END IGS_OR_VAL_IA;

 

/
