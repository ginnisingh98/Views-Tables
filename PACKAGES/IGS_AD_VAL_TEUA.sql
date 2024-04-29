--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_TEUA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_TEUA" AUTHID CURRENT_USER AS
/* $Header: IGSAD75S.pls 115.4 2002/11/28 21:41:14 nsidana ship $ */
/*****  Bug No :   1956374
          Task   :   Duplicated Procedures and functions
          PROCEDURE  admp_val_teua_sret  is removed
                      *****/
  --
  -- Validate if IGS_PS_DSCP.discipline_group_cd is closed.
  FUNCTION crsp_val_di_closed(
  p_discipline_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate tertiary edu unit attempt result type.

END IGS_AD_VAL_TEUA;

 

/
