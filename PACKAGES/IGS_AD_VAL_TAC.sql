--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_TAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_TAC" AUTHID CURRENT_USER AS
/* $Header: IGSAD71S.pls 115.3 2002/11/28 21:40:09 nsidana ship $ */

  --
  -- Validate the update of a TAC admission code record
  FUNCTION admp_val_tac_upd(
  p_tac_admission_cd IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_TAC;

 

/
