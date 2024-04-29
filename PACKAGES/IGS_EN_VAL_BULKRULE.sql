--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_BULKRULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_BULKRULE" AUTHID CURRENT_USER AS
/* $Header: IGSEN28S.pls 115.7 2002/12/04 10:36:41 pradhakr ship $ */
/* smaddali added new parameters in both the procedures for
   enrollment processes build nov 2001 bug#1832130 */
-- Who         When            What
-- pradhakr  04-Dec-2002   Changed the parameter sequence in the procedure ENRP_VAL_SCA_RULTODO.
--			   As per standard the parameter errbuf and retcode are made as the
--			   first two paramters. Changes as per bug# 2683629

  --
  -- To process bulk unit rule checks for students with todo entries
  PROCEDURE ENRP_VAL_SCA_RULTODO(
  errbuf OUT NOCOPY VARCHAR2 ,
  retcode OUT NOCOPY NUMBER ,
  p_acad_calander IN VARCHAR2,
  p_crs_cd IN VARCHAR2 ,
  p_org_id IN NUMBER,
  -- added new parameters for bug#1832130
  p_load_teach_calendar IN VARCHAR2 DEFAULT NULL ,
  p_org_unit_cd IN VARCHAR2 DEFAULT NULL ,
  p_rule_to_be_validated IN VARCHAR2 DEFAULT NULL )
;
  --
  -- Validate the unit rules for a student course attempt (in bulk)
  PROCEDURE ENRP_VAL_SCA_URULE(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_log_type IN VARCHAR2 ,
  p_creation_dt IN DATE ,
  -- added new parameters for bug#1832130
  p_cal_type IN VARCHAR2 DEFAULT NULL ,
  p_ci_sequence_number IN NUMBER DEFAULT NULL ,
  p_org_unit_cd IN VARCHAR2 DEFAULT NULL ,
  p_rule_to_be_validated IN VARCHAR2 DEFAULT NULL )
;
END IGS_EN_VAL_BULKRULE;

 

/
