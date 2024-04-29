--------------------------------------------------------
--  DDL for Package Body IGS_RU_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_GEN_005" AS
/* $Header: IGSRU11B.pls 120.1 2005/07/11 06:15:55 appldev ship $ */
/*
 HISTORY
  who       when        what
  gurprsin  28-Jun-2205 Bug#3392088, Added a call to IGS_FI_F_TYP_CA_INST_PKG.GET_FK1_IGS_RU_RULE for Scope_rul_sequence_number.
  smvk      28-AUG-2002 Removed the procedure call IGS_FI_FEE_DSB_FM_RU_PKG.GET_FK_IGS_RU_CALL()
                        from CHECK_CHILD_EXISTANCE_RU_CALL and IGS_FI_FEE_DSB_FM_RU_PKG.GET_FK_IGS_RU_RULE()
                        from CHECK_CHILD_EXISTANCE_RU_RULE as a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
                        Removed default value from the procedures RULP_VAL_SCA_COMP,RULP_VAL_STG_COMP,RULP_VAL_SUSA_COMP to avoid gscc warning 'File.Pkg.22'
-- svenkata 14-MAR-2002 The procedures CHECK_CHILD_EXISTANCE_RU_RULE and  CHECK_CHILD_EXISTANCE_RU_CALL have been
--                      moved to the package IGS_RU_GEN_005. This procedure is being called (from the table handlers
--                      IGS_RU_CALL_PKG and IGS_RU_RULE_PKG) only when the user is NOT DATA MERGE .Bug # 2233951.
*/

FUNCTION RULP_VAL_SCA_COMP(
  p_person_id IN NUMBER ,
  p_sca_course_cd  VARCHAR2 ,
  p_sca_course_version  NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_predicted_ind   VARCHAR2,
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
/*
 For the given SCA determine and evaluate the rule
 HISTORY
 who       when        what
 smvk      28-AUG-2002 Removed the default value of p_predicted_int to avoid gscc warning 'File.Pkg.22'
*/
        v_return_val    VARCHAR2(30);
BEGIN
        SAVEPOINT before_senna;
        v_return_val := IGS_RU_GEN_001.rulp_val_senna(
                                p_rule_call_name=>'CRS-COMP',
                                p_person_id=>p_person_id,
                                p_course_cd=>p_sca_course_cd,
                                p_course_version=>p_sca_course_version,
                                p_param_3=>p_course_cd,
                                p_param_4=>p_course_version,
                                p_param_5=>p_predicted_ind,
                                p_message=>p_message_text );
        ROLLBACK TO before_senna;
        IF v_return_val = 'false' OR v_return_val IS NULL
        THEN
                RETURN FALSE;
        END IF;
        RETURN TRUE;
END RULP_VAL_SCA_COMP;

FUNCTION RULP_VAL_SCA_PRG(
  p_rul_sequence_number  NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
/*
 For the given SCA evaluate the rule number
*/
        v_return_val    VARCHAR2(30);
BEGIN
        v_return_val := IGS_RU_GEN_001.rulp_val_senna(
                                p_rule_number=>p_rul_sequence_number,
                                p_person_id=>p_person_id,
                                p_course_cd=>p_course_cd,
                                p_course_version=>p_course_version,
                                p_cal_type=>p_prg_cal_type,
                                p_ci_sequence_number=>p_prg_ci_sequence_number,
                                p_message=>p_message_text );
        IF v_return_val = 'false' OR v_return_val IS NULL
        THEN
                RETURN TRUE;
        END IF;
        RETURN FALSE;
END RULP_VAL_SCA_PRG;

FUNCTION RULP_VAL_STG_COMP(
  p_person_id IN NUMBER ,
  p_sca_course_cd  VARCHAR2 ,
  p_sca_course_version  NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_cst_sequence_number  NUMBER ,
  p_predicted_ind  VARCHAR2,
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
/*
 Get and evaluate the course stage completion rule
 HISTORY
 who       when        what
 smvk      28-AUG-2002 Removed the default value of p_predicted_int to avoid gscc warning 'File.Pkg.22'
*/
        v_return_val            VARCHAR2(30);
BEGIN
        v_return_val := IGS_RU_GEN_001.rulp_val_senna(
                                p_rule_call_name=>'STG-COMP',
                                p_person_id=>p_person_id,
                                p_course_cd=>p_sca_course_cd,
                                p_course_version=>p_sca_course_version,
                                p_param_1=>p_cst_sequence_number,
                                p_param_3=>p_course_cd,
                                p_param_4=>p_course_version,
                                p_param_5=>p_predicted_ind,
                                p_message=>p_message_text);

        IF v_return_val = 'false' OR v_return_val IS NULL
        THEN
                RETURN FALSE;
        END IF;
        RETURN TRUE;
END RULP_VAL_STG_COMP;

FUNCTION RULP_VAL_SUSA_COMP(
  p_person_id IN NUMBER ,
  p_sca_course_cd  VARCHAR2 ,
  p_sca_course_version  NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_unit_set_version  NUMBER ,
  p_predicted_ind  VARCHAR2,
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
/*
 Get and evaluate the unit set completion rule
 HISTORY
 who       when        what
 smvk      28-AUG-2002 Removed the default value of p_predicted_int to avoid gscc warning 'File.Pkg.22'
*/
        v_return_val    VARCHAR2(30);
BEGIN
        v_return_val := IGS_RU_GEN_001.rulp_val_senna(
                                p_rule_call_name=>'US-COMP',
                                p_person_id=>p_person_id,
                                p_course_cd=>p_sca_course_cd,
                                p_course_version=>p_sca_course_version,
                                p_param_1=>p_unit_set_cd,
                                p_param_2=>p_unit_set_version,
                                p_param_3=>p_course_cd,
                                p_param_4=>p_course_version,
                                p_param_5=>p_predicted_ind,
                                p_message=>p_message_text);

        IF v_return_val = 'false' OR v_return_val IS NULL
        THEN
                RETURN FALSE;
        END IF;
        RETURN TRUE;
END RULP_VAL_SUSA_COMP;

  PROCEDURE Check_Child_Existance_Ru_Rule(
  p_sequence_number IN NUMBER) AS
 /*
  HISTORY
  who       when        what
  gurprsin  28-Jun-2205 Bug#3392088, Added a call to IGS_FI_F_TYP_CA_INST_PKG.GET_FK1_IGS_RU_RULE for Scope_rul_sequence_number.
  smvk      28-AUG-2002 Removed the procedure call IGS_FI_FEE_DSB_FM_RU_PKG.GET_FK_IGS_RU_RULE()
                        as a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
*/
  BEGIN

   IGS_PS_RU_PKG.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    IGS_PS_STAGE_RU_PKG.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    IGS_PS_VER_RU_PKG.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    IGS_FI_F_CAT_FEE_LBL_PKG.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    /* obsolete the call IGS_FI_FEE_DSB_FM_RU_PKG.GET_FK_IGS_RU_RULE ( )  as a part of Bug # 2531390*/

    IGS_FI_F_TYP_CA_INST_PKG.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    Igs_Ru_Named_Rule_Pkg.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    IGS_PR_RULE_PKG.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    Igs_Ru_Item_Pkg.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    IGS_PS_UNIT_RU_PKG.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    IGS_EN_UNIT_SET_RULE_PKG.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    IGS_PS_UNIT_VER_RU_PKG.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    IGS_PS_USEC_RU_PKG.GET_FK_IGS_RU_RULE (
      p_sequence_number
      );

    igs_en_cpd_ext_pkg.get_fk_igs_ru_rule(
      p_sequence_number
      );

    IGS_AD_APCTR_RU_PKG.GET_FK_IGS_RU_RULE(
      p_sequence_number
      );

    IGS_FI_F_TYP_CA_INST_PKG.GET_FK1_IGS_RU_RULE (
      p_sequence_number
      );

  END Check_Child_Existance_Ru_rule ;

  PROCEDURE Check_Child_Existance_Ru_Call
  (p_rud_sequence_number IN NUMBER,
   p_s_rule_call_cd IN VARCHAR2 )  AS
 /*
  HISTORY
  who       when        what
  smvk      28-AUG-2002 Removed the procedure call IGS_FI_FEE_DSB_FM_RU_PKG.GET_FK_IGS_RU_CALL()
                        as a part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
*/

  BEGIN

    IGS_RU_ITEM_PKG.GET_UFK_IGS_RU_CALL (
      p_rud_sequence_number
      );

    IGS_PS_RU_PKG.GET_FK_IGS_RU_CALL (
      p_s_rule_call_cd
      );

    IGS_PS_STAGE_RU_PKG.GET_FK_IGS_RU_CALL (
      p_s_rule_call_cd
      );

    IGS_PS_VER_RU_PKG.GET_FK_IGS_RU_CALL (
      p_s_rule_call_cd
      );

     /* Obsolete the call IGS_FI_FEE_DSB_FM_RU_PKG.GET_FK_IGS_RU_CALL as a part of the Bug # 2531390 */

    IGS_PR_RU_CAT_PKG.GET_FK_IGS_RU_CALL (
      p_s_rule_call_cd
      );

    IGS_PS_UNIT_RU_PKG.GET_FK_IGS_RU_CALL (
      p_s_rule_call_cd
      );

    IGS_EN_UNIT_SET_RULE_PKG.GET_FK_IGS_RU_CALL (
      p_s_rule_call_cd
      );

    IGS_PS_UNIT_VER_RU_PKG.GET_FK_IGS_RU_CALL (
      p_s_rule_call_cd
      );

    IGS_PS_USEC_RU_PKG.GET_FK_IGS_RU_CALL (
     p_s_rule_call_cd
      );

    igs_en_cpd_ext_pkg.get_fk_igs_ru_call (
      p_s_rule_call_cd
      );

  END Check_Child_Existance_Ru_Call;

END IGS_RU_GEN_005;

/
