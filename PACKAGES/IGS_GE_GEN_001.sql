--------------------------------------------------------
--  DDL for Package IGS_GE_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSGE01S.pls 115.5 2002/11/29 00:31:22 nsidana ship $ */

FUNCTION GENP_CHK_COL_UPPER(
  p_column_name  VARCHAR2 ,
  p_table_name  VARCHAR2 )
RETURN BOOLEAN ;
PRAGMA RESTRICT_REFERENCES(GENP_CHK_COL_UPPER, WNDS);

FUNCTION genp_clc_dt_diff(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(genp_clc_dt_diff, WNDS);

FUNCTION GENP_CLC_WEEK_END_DT(
  p_date IN DATE ,
  p_day_week_end IN VARCHAR2 DEFAULT 'FRIDAY')
RETURN DATE ;
PRAGMA RESTRICT_REFERENCES(GENP_CLC_WEEK_END_DT, WNDS);

PROCEDURE GENP_DEL_LOG(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY number ,
  p_s_log_type IN VARCHAR2 ,
  p_days_old IN NUMBER );

FUNCTION GENP_DEL_NOTE(
  p_reference_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

FUNCTION genp_get_addr(
  p_person_id  NUMBER ,
  p_org_unit_cd  VARCHAR2 ,
  p_institution_cd  VARCHAR2 ,
  p_location_cd  VARCHAR2 ,
  p_addr_type  VARCHAR2 ,
  p_case_type  VARCHAR2 DEFAULT 'UPPER',
  p_phone_no  VARCHAR2 DEFAULT 'Y',
  p_name_style  VARCHAR2 DEFAULT 'CONTEXT',
  p_inc_addr  VARCHAR2 DEFAULT 'Y')
RETURN VARCHAR2 ;
 PRAGMA RESTRICT_REFERENCES(genp_get_addr, WNDS);

FUNCTION genp_get_appl_owner
RETURN VARCHAR2 ;
 PRAGMA RESTRICT_REFERENCES(genp_get_appl_owner, WNDS);

PROCEDURE genp_get_audit(
  p_table_name IN VARCHAR2 ,
  p_rowid IN VARCHAR2 ,
  p_update_who OUT NOCOPY VARCHAR2 ,
  p_update_on OUT NOCOPY DATE );

FUNCTION genp_get_cmp_cutoff(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER )
RETURN DATE ;
 PRAGMA RESTRICT_REFERENCES(genp_get_cmp_cutoff, WNDS);

FUNCTION adm_get_name(
	x_person_id in NUMBER)
RETURN VARCHAR2;

FUNCTION adm_get_unit_title(
	x_person_id             NUMBER,
	x_admission_appl_number NUMBER,
        x_NOMINATED_COURSE_CD   VARCHAR2 )
RETURN VARCHAR2;

END IGS_GE_GEN_001 ;

 

/
