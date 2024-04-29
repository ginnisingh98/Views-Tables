--------------------------------------------------------
--  DDL for Package IGS_AV_VAL_ASAU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AV_VAL_ASAU" AUTHID CURRENT_USER AS
/* $Header: IGSAV03S.pls 115.4 2002/11/28 22:52:51 nsidana ship $ */

  -- To validate the advanced standing alternate units.
  FUNCTION advp_val_alt_unit(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version IN NUMBER ,
  p_adv_stnd_type IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_unit_version IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- To validate the precluded and alternate units.
  FUNCTION advp_val_prclde_unit(
  p_precluded_unit_cd IN VARCHAR2 ,
  p_alternate_unit_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


END IGS_AV_VAL_ASAU;

 

/
