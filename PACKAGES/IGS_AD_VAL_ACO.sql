--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ACO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ACO" AUTHID CURRENT_USER AS
/* $Header: IGSAD29S.pls 115.4 2002/11/28 21:29:06 nsidana ship $ */

/*****  Bug No :   1956374
        Task   :   Duplicated Procedures and functions
        PROCEDURE  ADMP_VAL_BFA_CLOSED is removed  *****/
  -- Validate the Tertiary Admissions Centre admission code closed ind
  FUNCTION admp_val_tac_closed(
  p_tac_admission_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;



END IGS_AD_VAL_ACO;

 

/
