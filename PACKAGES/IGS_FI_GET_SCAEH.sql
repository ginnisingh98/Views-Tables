--------------------------------------------------------
--  DDL for Package IGS_FI_GET_SCAEH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GET_SCAEH" AUTHID CURRENT_USER AS
/* $Header: IGSFI06S.pls 115.5 2002/11/29 00:15:26 nsidana ship $ */
  --
  TYPE r_scaeh_dtl IS RECORD
  (
  r_scah IGS_AS_SC_ATTEMPT_H_ALL%ROWTYPE);
  --
  --
  gr_scaeh r_scaeh_dtl;
  --
  --
  gv_person_id igs_pe_person.person_id%type;
  --
  --
  gv_course_cd IGS_PS_COURSE.COURSE_CD%TYPE;
  --
  --
  gv_effective_dt DATE;
  --
  -- Routine to save SCA effective history data in a PL/SQL RECORD.
  PROCEDURE FINP_GET_SCAEH(
  p_person_id IN NUMBER ,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE,
  p_effective_dt IN DATE ,
  p_data_found OUT NOCOPY BOOLEAN ,
  p_scaeh_dtl IN OUT NOCOPY IGS_AS_SC_ATTEMPT_H_ALL%ROWTYPE )
;
END IGS_FI_GET_SCAEH;

 

/
