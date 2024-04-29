--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_TPMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_TPMT" AUTHID CURRENT_USER AS
/* $Header: IGSRE18S.pls 115.3 2002/11/29 03:31:03 nsidana ship $ */
  -- To validate thesis panel member type tracking type value
  FUNCTION RESP_VAL_TPMT_TRT(
  p_tracking_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

END IGS_RE_VAL_TPMT;

 

/
