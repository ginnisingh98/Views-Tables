--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_SCHT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_SCHT" AUTHID CURRENT_USER AS
/* $Header: IGSRE13S.pls 115.4 2002/11/29 03:29:52 nsidana ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_ou_sys_sts

  -- To validate IGS_RE_SCHL_TYPE person_id/org_unit_cd/start_dt
  FUNCTION RESP_VAL_SCHT_PID_OU(
  p_person_id_from IN NUMBER ,
  p_org_unit_cd_from IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;


END IGS_RE_VAL_SCHT;

 

/
