--------------------------------------------------------
--  DDL for Package IGS_ST_VAL_GSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_VAL_GSC" AUTHID CURRENT_USER AS
 /* $Header: IGSST08S.pls 115.5 2002/11/29 04:12:07 nsidana ship $ */
  --
  -- Validate the government snapshot control snapshot date time.
  FUNCTION stap_val_gsc_sdt(
  p_submission_yr IN NUMBER ,
  p_snapshot_dt_time IN DATE ,
  p_message_name OUT NOCOPY  VARCHAR2)
  RETURN BOOLEAN;
  --
  -- Validate the update of government snapshot control snapshot date time.
  FUNCTION stap_val_gsc_sdt_upd(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

END IGS_ST_VAL_GSC;

 

/
