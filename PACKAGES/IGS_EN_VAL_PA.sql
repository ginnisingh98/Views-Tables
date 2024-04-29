--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PA" AUTHID CURRENT_USER AS
/* $Header: IGSEN48S.pls 115.5 2002/11/29 00:01:40 nsidana ship $ */

--
-- bug id : 1956374
-- sjadhav , 29-aug-2001
-- removed function enrp_val_pc_closed
--
 -----------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_strt_end_dt
  --                            removed .
  ----------------------------------------------------------------------------------------
  --
  -- Validate the IGS_PE_PERSON address correspondence addresses
  FUNCTION enrp_val_pa_corr(
  p_person_id IN NUMBER ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_pa_corr,WNDS);
   --
  -- Validate for IGS_PE_PERSON address date overlaps.
  FUNCTION enrp_val_pa_ovrlp(
  p_person_id IN NUMBER ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_pa_ovrlp,WNDS);
  --
  -- Validate that no other open-ended IGS_PE_PERSON addr record exists.
  FUNCTION enrp_val_pa_open(
  p_person_id IN NUMBER ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_pa_open,WNDS);
  --
  -- Validate the address type closed indicator
  FUNCTION enrp_val_adt_closed(
  p_addr_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_adt_closed,WNDS);
END IGS_EN_VAL_PA;

 

/
