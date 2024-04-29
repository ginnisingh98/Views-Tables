--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_AW" AUTHID CURRENT_USER AS
 /* $Header: IGSPS12S.pls 115.4 2002/11/29 02:56:38 nsidana ship $ */

  -- Validate update to IGS_PS_AWD type.
  FUNCTION crsp_val_aw_upd(
  p_award_cd  IGS_PS_AWD.award_cd%TYPE ,
  p_new_award_type  IGS_PS_AWD.s_award_type%TYPE ,
  p_old_award_type  IGS_PS_AWD.s_award_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;


  -- Validate a testamur type is not closed.
  FUNCTION crsp_val_tt_closed(
  p_testamur_type  IGS_GR_TESTAMUR_TYPE.testamur_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

END IGS_PS_VAL_AW;

 

/
