--------------------------------------------------------
--  DDL for Package IGS_RU_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_GEN_005" AUTHID CURRENT_USER AS
/* $Header: IGSRU11S.pls 115.9 2002/11/29 03:41:08 nsidana ship $ */
-- svenkata 14-MAR-2002	The procedures CHECK_CHILD_EXISTANCE_RU_RULE and  CHECK_CHILD_EXISTANCE_RU_CALL have been
--			moved to the package IGS_RU_GEN_005. This procedure is being called (from the table handlers
--			IGS_RU_CALL_PKG and IGS_RU_RULE_PKG) only when the user is NOT DATA MERGE .Bug # 2233951.

FUNCTION RULP_VAL_SCA_COMP(
  p_person_id IN NUMBER ,
  p_sca_course_cd  VARCHAR2 ,
  p_sca_course_version  NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_predicted_ind  VARCHAR2 DEFAULT 'N',
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

FUNCTION RULP_VAL_SCA_PRG(
  p_rul_sequence_number  NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

FUNCTION RULP_VAL_STG_COMP(
  p_person_id IN NUMBER ,
  p_sca_course_cd  VARCHAR2 ,
  p_sca_course_version  NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_cst_sequence_number  NUMBER ,
  p_predicted_ind  VARCHAR2 DEFAULT 'N',
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

FUNCTION RULP_VAL_SUSA_COMP(
  p_person_id IN NUMBER ,
  p_sca_course_cd  VARCHAR2 ,
  p_sca_course_version  NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_unit_set_version  NUMBER ,
  p_predicted_ind  VARCHAR2 DEFAULT 'N',
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

PROCEDURE CHECK_CHILD_EXISTANCE_RU_RULE(
   p_sequence_number IN NUMBER );

PROCEDURE CHECK_CHILD_EXISTANCE_RU_CALL (
   p_rud_sequence_number IN NUMBER,
   p_s_rule_call_cd IN VARCHAR2  );

END IGS_RU_GEN_005;

 

/
