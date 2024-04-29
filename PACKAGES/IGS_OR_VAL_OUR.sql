--------------------------------------------------------
--  DDL for Package IGS_OR_VAL_OUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_VAL_OUR" AUTHID CURRENT_USER AS
/* $Header: IGSOR11S.pls 115.3 2002/11/29 01:48:24 nsidana ship $ */
  -- Validate the organisational unit relationship.

  FUNCTION orgp_val_our(
  p_parent_org_unit_cd IN VARCHAR2 ,
  p_parent_start_dt IN DATE ,
  p_child_org_unit_cd IN VARCHAR2 ,
  p_child_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_OR_VAL_OUR;

 

/
