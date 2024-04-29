--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_DR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_DR" AUTHID CURRENT_USER AS
/* $Header: IGSEN33S.pls 115.3 2002/11/28 23:57:21 nsidana ship $ */
  --
  -- Validate system  default indicator anddiscont reason type.
  FUNCTION enrp_val_dr_sysdflt(
  p_s_discontin_reason_type IN VARCHAR2 ,
  p_sys_dflt_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_dr_sysdflt,WNDS);
  --
  -- Validate sys discontinuation reason code closed indicator
  FUNCTION enrp_val_sdrt_closed(
  p_s_discontin_reason_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_sdrt_closed,WNDS);
  --
  -- Validate system  default indicator (at least one).
  FUNCTION enrp_val_dr_sysdflt2(
  p_s_discontin_reason_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_dr_sysdflt2,WNDS);
  --
  -- Validate system  default indicator (>one).
  FUNCTION enrp_val_dr_sysdflt1(
  p_s_discontin_reason_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_dr_sysdflt1,WNDS);
  --
  -- Validate the discontinuation reason code default.
  FUNCTION enrp_val_dr_dflt(
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_dr_dflt,WNDS);
END IGS_EN_VAL_DR;

 

/
