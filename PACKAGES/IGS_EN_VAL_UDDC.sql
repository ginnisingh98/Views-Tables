--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_UDDC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_UDDC" AUTHID CURRENT_USER AS
/* $Header: IGSEN71S.pls 115.3 2002/11/29 00:08:47 nsidana ship $ */
  --
  -- Validate the administrative UNIT status closed indicator
  FUNCTION enrp_val_aus_closed(
  p_aus IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
-- PRAGMA RESTRICT_REFERENCES(enrp_val_aus_closed , WNDS);

  -- Validate the AUS UNIT attempt status is 'DISCONTIN'
  FUNCTION enrp_val_aus_discont(
  p_aus IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
--PRAGMA RESTRICT_REFERENCES(enrp_val_aus_discont , WNDS);

  -- To validate TEACHING date alias.
  FUNCTION enrp_val_teaching_da(
  p_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
--PRAGMA RESTRICT_REFERENCES(enrp_val_teaching_da , WNDS);

  -- Validate either the admin UNIT status or delete indicator is set.
  FUNCTION enrp_val_uddc_fields(
  p_aus IN VARCHAR2 ,
  p_delete_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

--PRAGMA RESTRICT_REFERENCES(enrp_val_uddc_fields , WNDS);

END IGS_EN_VAL_UDDC;

 

/
