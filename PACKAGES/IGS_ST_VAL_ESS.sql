--------------------------------------------------------
--  DDL for Package IGS_ST_VAL_ESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_VAL_ESS" AUTHID CURRENT_USER AS
/* $Header: IGSST05S.pls 115.5 2002/11/29 04:11:20 nsidana ship $ */

  --
  -- Validate no warnings exist for excluded pid,crs,unit records
  FUNCTION stap_val_eswv_xandw(
  p_snapshot_dt_time IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END IGS_ST_VAL_ESS;

 

/
