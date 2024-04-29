--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_AUSL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_AUSL" AUTHID CURRENT_USER AS
/* $Header: IGSEN27S.pls 115.4 2002/11/28 23:55:51 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (STAP_VAL_CI_STATUS) - from the spec and body. -- kdande
--msrinivi Bug 1956374 Removed duplciate code genp_prc_clear_rowid
*/
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_aus_closed
  --
  -- Validate the AUS unit attempt status is 'DISCONTIN'
  FUNCTION enrp_val_ausl_aus(
  p_aus IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_ausl_aus,WNDS);
END IGS_EN_VAL_AUSL;

 

/
