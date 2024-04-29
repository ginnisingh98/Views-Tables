--------------------------------------------------------
--  DDL for Package IGS_OR_VAL_OU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_VAL_OU" AUTHID CURRENT_USER AS
/* $Header: IGSOR09S.pls 115.3 2002/11/29 01:48:09 nsidana ship $ */
  --
  -- Validate the organisational unit end date.
  FUNCTION orgp_val_ou_end_dt(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN Boolean;
  --
  -- Validate if any open ended org units exist for the current org unit.
  FUNCTION orgp_val_open_ou(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the organisational status.
  FUNCTION orgp_val_org_status(
  p_org_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Ensure an organisational unit status change is valid.
  FUNCTION orgp_val_ou_sts_chng(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_org_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the organisational type.
  FUNCTION orgp_val_org_type(
  p_org_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the member type.
  FUNCTION orgp_val_mbr_type(
  p_member_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the organisational unit institution code is active.
  FUNCTION orgp_val_ou_instn_cd(
  p_institution_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate for date overlaps for a specific organisational IGS_PS_UNIT.
  FUNCTION orgp_val_ou_ovrlp(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Cross-field validation of the org unit end date and status.
  FUNCTION orgp_val_ou_end_sts(
  p_end_dt IN DATE ,
  p_org_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_OR_VAL_OU;

 

/
