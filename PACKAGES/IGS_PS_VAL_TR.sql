--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_TR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_TR" AUTHID CURRENT_USER AS
/* $Header: IGSPS57S.pls 115.5 2002/12/12 09:47:18 smvk ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_ou_sys_sts
  --
  -- Validate teaching responsibility percentage for the IGS_PS_UNIT version
 /***********************************************************************************************
    Created By     :
    Date Created By:
    Purpose        :

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who		When		What
    smvk      12-Dec-2002      Added a boolean parameter p_b_lgcy_validator to the function call crsp_val_tr_perc.
                               As a part of the Bug # 2696207
  ********************************************************************************************** */
  FUNCTION crsp_val_tr_perc(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_b_lgcy_validator IN BOOLEAN DEFAULT FALSE )
RETURN BOOLEAN;

END IGS_PS_VAL_TR;

 

/
