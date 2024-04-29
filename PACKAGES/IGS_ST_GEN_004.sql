--------------------------------------------------------
--  DDL for Package IGS_ST_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_GEN_004" AUTHID CURRENT_USER AS
/* $Header: IGSST04S.pls 120.0 2005/06/01 22:27:15 appldev noship $ */
/*------------------------------------------------------------------------------+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA       |
 |                            All rights reserved.                              |
 +==============================================================================+
 |                                                                              |
 | DESCRIPTION                                                                  |
 |      PL/SQL body for package: IGS_ST_GEN_004                             |
 |                                                                              |
 | NOTES                                                                        |
 |                                                                              |
 |                                                                              |
 | HISTORY                                                                      |
 | Who          When            What                                            |
 | knaraset    15-May-2003    Modified function Stap_Get_Un_Comp_Sts to add
 |                            parameter uoo_id,as part of MUS build bug 2829262
 |
 | ctyagi      12-Apr-2005    Obsolete  Procedure Stas_Ins_Ess for bug 4293239
+------------------------------------------------------------------------------*/
Function Stap_Get_Supp_Fos(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN VARCHAR2;

Function Stap_Get_Tot_Exmpt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN NUMBER;

Function Stap_Get_Un_Comp_Sts(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_sua_cal_type IN VARCHAR2 ,
  p_sua_ci_sequence_number IN NUMBER,
  p_uoo_id IN igs_ps_unit_ofr_opt.uoo_id%TYPE)
RETURN NUMBER;

Function Stap_Ins_Govt_Snpsht(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_ess_snapshot_dt_time IN DATE ,
  p_use_most_recent_ess_ind IN VARCHAR2 DEFAULT 'N',
  p_message_nAmE OUT NOCOPY VARCHAR2,
  p_log_creation_dt OUT NOCOPY DATE )
RETURN BOOLEAN;

Procedure Stap_Ins_Gsch(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER );


Procedure Stas_Ins_Govt_Snpsht(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_ess_snapshot_dt_time IN DATE ,
  p_use_most_recent_ess_ind IN VARCHAR2 DEFAULT 'N',
  p_log_creation_dt OUT NOCOPY DATE );

END IGS_ST_GEN_004;

 

/
