--------------------------------------------------------
--  DDL for Package IGS_ST_VAL_ESSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_VAL_ESSC" AUTHID CURRENT_USER AS
/* $Header: IGSST06S.pls 115.5 2002/11/29 04:11:38 nsidana ship $ */

  --
  -- Validate the setting of the delete of an enrolment statistics snapshot
  FUNCTION stap_val_essc_delete(
  p_snapshot_dt_time IN DATE ,
  p_delete_snapshot_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END IGS_ST_VAL_ESSC;

 

/
