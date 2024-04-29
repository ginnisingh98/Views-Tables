--------------------------------------------------------
--  DDL for Package IGS_AV_VAL_AS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AV_VAL_AS" AUTHID CURRENT_USER AS
/* $Header: IGSAV02S.pls 115.4 2002/11/28 22:52:38 nsidana ship $ */

  -- To validate the advanced standing IGS_PS_COURSE code.
  FUNCTION advp_val_as_crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- To validate the advanced standing major exemption IGS_OR_INSTITUTION code.
  FUNCTION advp_val_as_inst(
  p_exempt_inst IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


END IGS_AV_VAL_AS;

 

/
