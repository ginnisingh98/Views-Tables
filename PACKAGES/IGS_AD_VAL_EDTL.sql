--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_EDTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_EDTL" AUTHID CURRENT_USER AS
/* $Header: IGSAD57S.pls 115.4 2002/11/28 21:36:53 nsidana ship $ */
  --msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed

  -- Validate either the ou code or employer fld is set
  FUNCTION admp_val_edtl_emplyr(
  p_org_unit_cd IN VARCHAR2 ,
  p_employer IN VARCHAR2 ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- To validate that end date is greater than or equal to start date.
  FUNCTION GENP_VAL_STRT_END_DT(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(genp_val_strt_end_dt,WNDS);

END IGS_AD_VAL_EDTL;

 

/
