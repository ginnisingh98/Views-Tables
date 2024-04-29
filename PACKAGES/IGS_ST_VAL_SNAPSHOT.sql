--------------------------------------------------------
--  DDL for Package IGS_ST_VAL_SNAPSHOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_VAL_SNAPSHOT" AUTHID CURRENT_USER AS
/* $Header: IGSST15S.pls 115.4 2002/11/29 04:12:56 nsidana ship $ */
  -- Validate whether or not an org unit belongs to the local institution.
  FUNCTION stap_val_local_ou(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;
END IGS_ST_VAL_SNAPSHOT;

 

/
