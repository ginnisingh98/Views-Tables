--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_AM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_AM" AUTHID CURRENT_USER AS
 /* $Header: IGSPS09S.pls 115.6 2002/11/29 02:55:51 nsidana ship $ */


  -- Validate Govt Attendance Mode is not closed.
  FUNCTION CRSP_VAL_AM_GOVT(
  p_govt_attendance_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  PROCEDURE schedule_rollover(
  errbuf  out NOCOPY  VARCHAR2,
  retcode out NOCOPY  NUMBER,
  p_old_sch_version IN IGS_PS_CATLG_VERS_ALL.CATALOG_VERSION%TYPE,
  p_new_sch_version IN IGS_PS_CATLG_VERS_ALL.CATALOG_VERSION%TYPE,
  p_override_flag  IN VARCHAR2 ,
  p_debug_flag IN VARCHAR2 ,
  p_org_id IN NUMBER
  );

 END IGS_PS_VAL_AM;

 

/
