--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_SAFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_SAFT" AUTHID CURRENT_USER AS
/* $Header: IGSAD68S.pls 115.4 2002/11/28 21:39:24 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_am_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_fs_closed"
  -------------------------------------------------------------------------------------------


  --
  -- Validate if IGS_FI_FUND_SRC.funding_source is closed.
  FUNCTION crsp_val_fs_closed(
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate target AOU codes are active and at the local INSTITUTION.
  FUNCTION admp_val_trgt_aou(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate if course type group is closed.
  FUNCTION crsp_val_ctg_closed(
  p_course_type_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate if unit internal course level is closed.
  FUNCTION crsp_val_uicl_closed(
  p_unit_int_course_level_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_SAFT;

 

/
