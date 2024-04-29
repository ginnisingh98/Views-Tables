--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_UD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_UD" AUTHID CURRENT_USER AS
/* $Header: IGSPS61S.pls 115.6 2002/12/12 09:49:20 smvk ship $ */

  --
  -- Validate the IGS_PS_DSCP group code for IGS_PS_UNIT IGS_PS_DSCP.
  FUNCTION crsp_val_ud_dg_cd(
  p_discipline_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate IGS_PS_UNIT IGS_PS_DSCP percentage for the IGS_PS_UNIT version
  /***********************************************************************************************
    Created By     :
    Date Created By:
    Purpose        :

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who		When		What
    smvk      12-Dec-2002      Added a boolean parameter p_b_lgcy_validator to the function call crsp_val_ud_perc.
                               As a part of the Bug # 2696207
  ********************************************************************************************** */

  FUNCTION crsp_val_ud_perc(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_b_lgcy_validator IN BOOLEAN DEFAULT FALSE )
RETURN BOOLEAN;


END IGS_PS_VAL_UD;

 

/
