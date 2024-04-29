--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_AIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_AIA" AUTHID CURRENT_USER AS
/* $Header: IGSAS12S.pls 115.5 2002/11/28 22:42:23 nsidana ship $ */
  --
  -- msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed
  -- As part of the bug# 1956374 removed the function crsp_val_ucl_closed
  -- As part of the bug# 1956374 removed the function crsp_val_loc_cd
  -- As part of the bug# 1956374 removed the function crsp_val_um_closed
  --
  -- Validate assessment assessor type closed indicator.
  FUNCTION assp_val_asst_closed(
  p_ass_assessor_type IN IGS_AS_ASSESSOR_TYPE.ass_assessor_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate only one primary assessor per assessment item
  FUNCTION assp_val_aia_primary(
  p_ass_id IN IGS_AS_ITEM_ASSESSOR.ass_id%TYPE ,
  p_person_id IN IGS_AS_ITEM_ASSESSOR.person_id%TYPE ,
  p_sequence_number IN IGS_AS_ITEM_ASSESSOR.sequence_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate assessor links for invalid combinations.
  FUNCTION assp_val_aia_links(
  p_ass_id IN IGS_AS_ITEM_ASSESSOR.ass_id%TYPE ,
  p_person_id IN IGS_AS_ITEM_ASSESSOR.person_id%TYPE ,
  p_sequence_number IN IGS_AS_ITEM_ASSESSOR.sequence_number%TYPE ,
  p_location_cd IN IGS_AS_ITEM_ASSESSOR.location_cd%TYPE ,
  p_unit_mode IN IGS_AS_ITEM_ASSESSOR.unit_mode%TYPE ,
  p_unit_class IN IGS_AS_ITEM_ASSESSOR.unit_class%TYPE ,
  p_ass_assessor_type IN IGS_AS_ITEM_ASSESSOR.ass_assessor_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Generic links validation routine.
  FUNCTION ASSP_VAL_OPTNL_LINKS(
  p_new_location_cd IN IGS_AS_ITEM_ASSESSOR.location_cd%TYPE ,
  p_new_unit_mode IN IGS_AS_ITEM_ASSESSOR.unit_mode%TYPE ,
  p_new_unit_class IN IGS_AS_ITEM_ASSESSOR.unit_class%TYPE ,
  p_db_location_cd IN IGS_AS_ITEM_ASSESSOR.location_cd%TYPE ,
  p_db_unit_mode IN IGS_AS_ITEM_ASSESSOR.unit_mode%TYPE ,
  p_db_unit_class IN IGS_AS_ITEM_ASSESSOR.unit_class%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.

END IGS_AS_VAL_AIA;

 

/
