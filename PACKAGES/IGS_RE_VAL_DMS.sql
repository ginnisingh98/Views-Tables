--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_DMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_DMS" AUTHID CURRENT_USER AS
/* $Header: IGSRE08S.pls 115.3 2002/11/29 03:28:35 nsidana ship $ */
  --
  -- To validate IGS_RE_DFLT_MS_SET uniqueness
  FUNCTION RESP_VAL_DMS_UNIQ(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

END IGS_RE_VAL_DMS;

 

/
