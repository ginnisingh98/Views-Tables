--------------------------------------------------------
--  DDL for Package IGS_ST_VAL_ULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_VAL_ULA" AUTHID CURRENT_USER AS
/* $Header: IGSST16S.pls 115.5 2002/11/29 04:13:11 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (STAP_VAL_CI_STATUS) - from the spec and body. -- kdande
*/
  -- Validate the unit load apportion unit version status.
  FUNCTION stap_val_ula_uv_sts(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

END IGS_ST_VAL_ULA;

 

/
