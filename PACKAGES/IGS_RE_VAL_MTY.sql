--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_MTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_MTY" AUTHID CURRENT_USER AS
/* $Header: IGSRE10S.pls 115.3 2002/11/29 03:29:05 nsidana ship $ */

  --
  -- To validate IGS_PR_MILESTONE type notification days
  FUNCTION RESP_VAL_MTY_DAYS(
  p_reminder_days IN NUMBER ,
  p_re_reminder_days IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;


END IGS_RE_VAL_MTY;

 

/
