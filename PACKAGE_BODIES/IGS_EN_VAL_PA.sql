--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PA" AS
/* $Header: IGSEN48B.pls 115.8 2003/11/27 14:29:17 gmaheswa ship $ */

-- bug id  : 1956374
-- sjadhav , 29-aug-2001
-- removed function enrp_val_pc_closed
--
-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function GENP_VAL_STRT_END_DT removed
  --gmaheswa    19-nov-2003     Bug No. 3227106 .The whole API stubbed as part of ADDRESS CHANGES.
-------------------------------------------------------------------------------------------
  --
  --
  -- Validate the IGS_PE_PERSON address correspondence addresses
  FUNCTION enrp_val_pa_corr(
  p_person_id IN NUMBER ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN
  RETURN TRUE;
  END enrp_val_pa_corr;


  FUNCTION enrp_val_pa_ovrlp(
  p_person_id IN NUMBER ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN

    RETURN TRUE;
    END enrp_val_pa_ovrlp;

  FUNCTION enrp_val_pa_open(
  p_person_id IN NUMBER ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN

   return TRUE;
  END enrp_val_pa_open;
  FUNCTION enrp_val_adt_closed(
  p_addr_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
   RETURN TRUE;
  END enrp_val_adt_closed;

END IGS_EN_VAL_PA;

/
