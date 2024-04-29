--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_QLITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_QLITY" AS
/* $Header: IGSCA14B.pls 120.4 2005/09/28 06:22:43 appldev ship $ */

  ------------------------------------------------------------------
  --Change History:
  --Who            When            What
  --skpandey    27-SEP-2005        Bug: 4036104
  --                               Description: Modified the cursor c_chk_enr_ci definition to select only those enrolment
  --                               calendars (output from cursor c_chk_acad_ci) which have subordinates of any type
  --                               Description: Modified the cursor c_chk_acad_ci to select only those records which are of
  --                               Enrollment type and are subordinate of Academic cal instance.
  --				   c_chk_tch_ci_aus changed to use get_within_ci = 'Y' rather than N.
  --npalanis    16-JAN-2003        Bug : 2739139
  --                               Check for  all Academic Term (Load) period should have one
  --                               superior fee periods is removed
  -- npalanis   23-DEC-2002        Bug : 2694794
  --                               new cursor added in CALP_VAL_ADM_CI to check that only one load calendar instance is attached
  --                               as a subordinate calendar under an admission calendar instance.
  -- npalanis   16-dec-2002        Bug:2697221 . check is added for calculating load apportionment for teaching calendars which are active
  --smadathi    11-sep-2002        Bug 2086177. Modified the procedure CALP_VAL_LOAD_CI, CALP_VAL_ADM_CI.Added
  --                               procedure calp_val_award_ci
  --sarakshi    19-Aug-2002        Bug#2518938,modified the cursor  c_chk_acad_fee_ci removed the cartesian join in the not exists clause
  --                               as functionally it was redundant, in the process resolved the  bug also
  --vchappid    11-Jun-2002        Bug#2384110, Progression Calendar is a mandatory superior calendar for the Teaching Calendar
  --                               implemented this constraint in the procedure calp_val_teach_ci
  --schodava    17-Apr-2002        Bug #2279265
  --                               Modified procedure CALP_VAL_LOAD_CI
  -- nsidana    7/30/2004          Bug : 3736551 : Added check to verify that load calenders do not overlap within a same academic calender.
  ------------------------------------------------------------------

  -- forward declaration of the procedure
  PROCEDURE calp_val_award_ci( p_c_acad_cal_type        IN igs_ca_inst_all.cal_type%TYPE,
                               p_n_acad_sequence_number IN igs_ca_inst_all.sequence_number%TYPE,
                               p_c_s_log_type           IN VARCHAR2 ,
                               p_d_log_creation_dt      IN DATE
		             );

  PROCEDURE CHK_ONE_PER_CAL(p_acad_cal_type        IN VARCHAR2,
                            p_acad_sequence_number IN NUMBER,
                            p_cal_cat              IN VARCHAR2,
                            p_s_log_type           IN VARCHAR2,
                            p_log_creation_dt      IN DATE)
  AS

-- Picks with a cal cat
CURSOR get_all_sda(cp_cal_cat VARCHAR2) IS
SELECT DISTINCT sys_date_type,date_alias
FROM
(SELECT sys_date_type,date_alias
  FROM   igs_ca_Da_configs
  WHERE  (res_cal_cat1    = cp_cal_cat OR
          res_cal_cat2    = cp_cal_cat) AND
	 one_per_cal_flag = 'Y'
  UNION ALL
  SELECT a.sys_date_type,b.date_alias
  FROM   igs_ca_Da_ovd_vals b,igs_ca_Da_configs a
  WHERE  a.sys_date_type = b.sys_date_type
  AND  a.one_per_cal_flag = 'Y'
  AND  (  a.res_cal_cat1    =cp_cal_cat OR
          a.res_cal_cat2    =cp_cal_cat)
);

-- Picks without a cal cat
  CURSOR get_all_sda_with_no_cal_cat IS
  SELECT distinct sys_date_type,date_alias
  FROM
  (SELECT sys_date_type,date_alias
   FROM   igs_ca_Da_configs
   WHERE  one_per_cal_flag = 'Y'
  UNION ALL
    SELECT a.sys_date_type,b.date_alias
   FROM   igs_ca_Da_ovd_vals b,
   igs_ca_Da_configs a
   WHERE  a.sys_date_type = b.sys_date_type
   AND  a.one_per_cal_flag = 'Y'
   );

  CURSOR get_cal_desc(cp_cal_type VARCHAR2, cp_seq_num NUMBER)
  IS
  SELECT description
  FROM   igs_ca_inst
  WHERE  cal_type        = cp_cal_type AND
         sequence_number = cp_seq_num;

  -- Count the instances of the DA in the CI.
  CURSOR chk_one_per_cal(cp_dt_alias VARCHAR2, cp_cal_type VARCHAR2,cp_seq_num NUMBER)
  IS
  SELECT count(*)
  FROM   igs_ca_da_inst
  WHERE  dt_alias           = cp_dt_alias AND
         cal_type           = cp_cal_type AND
	 ci_sequence_number = cp_seq_num;

  l_cal_desc VARCHAR2(80);
  l_count NUMBER;

  BEGIN

  OPEN get_cal_desc(p_acad_cal_type,p_acad_sequence_number);
  FETCH get_cal_desc INTO l_cal_desc;
  CLOSE get_cal_desc;

  IF (p_cal_cat = 'ALL' OR p_cal_cat = 'DATES')
  THEN
    -- Open cursor without any restriction on the cal category and run the loop.
    FOR get_all_sda_rec IN get_all_sda_with_no_cal_cat
    LOOP
      l_count := 0;
      OPEN chk_one_per_cal(get_all_sda_rec.date_alias,p_acad_cal_type,p_acad_sequence_number);
      FETCH chk_one_per_cal INTO l_count;
      CLOSE chk_one_per_cal;
      IF (l_count > 1)
      THEN
        -- Log an entry in the LOG table.
        fnd_message.Set_Name('IGS','IGS_CA_GR_ONE_DAI_CI');
        fnd_message.set_token('DA',get_all_sda_rec.date_alias);
        fnd_message.set_token('CAL_DESC',l_cal_desc);
        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (p_s_log_type,
			                 p_log_creation_dt,
 			                 'DATES' || ',' || p_acad_cal_type || ',' ||TO_CHAR (p_acad_sequence_number),
 	 		                 NULL,
 	 		                 fnd_message.get);
       END IF;
    END LOOP;
  ELSE
    -- Open cursor with the restrictions on the cal category and run the loop.
    FOR get_all_sda_rec IN get_all_sda(p_cal_cat)
    LOOP
      l_count := 0;
      OPEN chk_one_per_cal(get_all_sda_rec.date_alias,p_acad_cal_type,p_acad_sequence_number);
      FETCH chk_one_per_cal INTO l_count;
      CLOSE chk_one_per_cal;
      IF (l_count > 1)
      THEN
        -- Log an entry in the LOG table.
        fnd_message.Set_Name('IGS','IGS_CA_GR_ONE_DAI_CI');
        fnd_message.set_token('DA',get_all_sda_rec.date_alias);
        fnd_message.set_token('CAL_DESC',l_cal_desc);
        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (p_s_log_type,
			                 p_log_creation_dt,
 			                 p_cal_cat || ',' || p_acad_cal_type || ',' ||TO_CHAR (p_acad_sequence_number),
 	 		                 NULL,
 	 		                 fnd_message.get);
       END IF;
    END LOOP;
  END IF;

  END chk_one_per_cal;

  -- To validate research calendar instance (part of the quality check)
  PROCEDURE CALP_VAL_RESEARCH_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
  AS
  ------------------------------------------------------------------
  --Change History:
  --Who            When            What
  --
  --sarakshi    13-Jul-2004        Bug#3729462, Added predicate DELETE_FLAG='N' to the cursor c_uop_uv .
  --smadathi    16-sep-2002        Bug 2086177. Included getching of Planned calendars
  --                               along with the Active ones
  ------------------------------------------------------------------
        lv_param_values                 VARCHAR2(1080);
        gv_other_detail         VARCHAR2(255);
  BEGIN -- calp_val_research_ci
        -- Quality check calendar structures related to research teaching calendars.
        -- The checks include:
        -- 1. Should only be specified against the teaching periods.
        -- 2. Should only be specified against teaching periods with a single census
        --    date.
        -- 3. A teaching period should only have a single start/end date.
        -- 4. If a teaching period has a start/end date then it must have the
        --    corresponding end/start date.
        -- 5. All teaching periods with 'research' units should have these dates
        --    (warning!).
        -- 6. Effective periods should not overlap.
        -- 7. Effective start date should be before effective end date.
        -- 8. Effective periods should not have gaps in days between periods (or
        --    between academic periods.
        -- 9. Multiple teaching periods which have effective periods defined (ie.
        --    research calendars) cannot be linked to the same load calendar within
        --    an academic period.
        -- EFTSU Load Determination
        -- *  Percentages specified in calendar instance relationships between
        --    academic and load calendars should total 100%.
  DECLARE

        cst_active      CONSTANT        VARCHAR2(10) := 'ACTIVE';
        cst_planned     CONSTANT        VARCHAR2(10) := 'PLANNED';
        cst_teaching    CONSTANT        VARCHAR2(10) := 'TEACHING';
        cst_load        CONSTANT        VARCHAR2(10) := 'LOAD';
        v_effective_strt_dt_alias       IGS_RE_S_RES_CAL_CON.effective_strt_dt_alias%TYPE;
        v_effective_end_dt_alias        IGS_RE_S_RES_CAL_CON.effective_end_dt_alias%TYPE;
        v_last_alias_val                IGS_CA_DA_INST.absolute_val%TYPE;
        v_last_alias_type               IGS_RE_S_RES_CAL_CON.effective_strt_dt_alias%TYPE;
        v_last_cal_type                 IGS_CA_DA_INST.CAL_TYPE%TYPE;
        v_last_ci_sequence_number       IGS_CA_DA_INST.ci_sequence_number%TYPE;
        v_unit_cd                       IGS_PS_UNIT_VER.unit_cd%TYPE;
        v_out_of_order                  BOOLEAN;
        v_strt_counter                  NUMBER;
        v_end_counter                   NUMBER;
        v_total_perc                    NUMBER;
        v_count                         NUMBER;
        v_dummy                         VARCHAR2(1);
        CURSOR c_srcc IS
                SELECT  srcc.effective_strt_dt_alias,
                        srcc.effective_end_dt_alias
                FROM    IGS_RE_S_RES_CAL_CON                    srcc
                WHERE   s_control_num                   = 1;
        CURSOR c_dai_cat (
                cp_effective_strt_dt_alias      IGS_RE_S_RES_CAL_CON.effective_strt_dt_alias%TYPE,
                cp_effective_end_dt_alias       IGS_RE_S_RES_CAL_CON.effective_end_dt_alias%TYPE) IS
                SELECT  dai.CAL_TYPE,
                        cat.S_CAL_CAT
                FROM    IGS_CA_DA_INST          dai,
                        IGS_CA_TYPE                     cat
                WHERE   dai.DT_ALIAS                    IN (
                                                        cp_effective_strt_dt_alias,
                                                        cp_effective_end_dt_alias) AND
                        IGS_EN_GEN_014.ENRS_GET_WITHIN_CI (
                                        p_acad_cal_type,
                                        p_acad_sequence_number,
                                        dai.CAL_TYPE,
                                        dai.ci_sequence_number, 'N') = 'Y' AND
                        cat.CAL_TYPE                    = dai.CAL_TYPE AND
                        cat.S_CAL_CAT                   <> cst_teaching;
        CURSOR c_ci_cs_cat IS
                SELECT  ci.CAL_TYPE,
                        ci.sequence_number
                FROM    IGS_CA_INST                     ci,
                        IGS_CA_STAT                     cs,
                        IGS_CA_TYPE                     cat
                WHERE   IGS_EN_GEN_014.ENRS_GET_WITHIN_CI (
                                        p_acad_cal_type,
                                        p_acad_sequence_number,
                                        ci.CAL_TYPE,
                                        ci.sequence_number, 'Y') = 'Y' AND
                        cs.CAL_STATUS                   = ci.CAL_STATUS AND
                        cs.s_cal_status                 IN (cst_active,cst_planned) AND
                        cat.CAL_TYPE                    = ci.CAL_TYPE AND
                        cat.S_CAL_CAT                   = cst_teaching;
        CURSOR c_dai (
                cp_cal_type                     IGS_CA_INST.CAL_TYPE%TYPE,
                cp_sequence_number              IGS_CA_INST.sequence_number%TYPE,
                cp_effective_strt_dt_alias      IGS_RE_S_RES_CAL_CON.effective_strt_dt_alias%TYPE,
                cp_effective_end_dt_alias       IGS_RE_S_RES_CAL_CON.effective_end_dt_alias%TYPE) IS
                SELECT  NVL (
                                dai.absolute_val,
                                IGS_CA_GEN_001.CALP_GET_ALIAS_VAL (
                                                dai.DT_ALIAS,
                                                dai.sequence_number,
                                                dai.CAL_TYPE,
                                                dai.ci_sequence_number)) AS alias_val,
                        dai.DT_ALIAS
                FROM    IGS_CA_DA_INST          dai
                WHERE   dai.CAL_TYPE                    = cp_cal_type AND
                        dai.ci_sequence_number          = cp_sequence_number AND
                        dai.DT_ALIAS                    IN (
                                                        cp_effective_strt_dt_alias,
                                                        cp_effective_end_dt_alias)
                ORDER BY alias_val ASC;
        CURSOR c_dai_sgcc (
                cp_cal_type                     IGS_CA_INST.CAL_TYPE%TYPE,
                cp_sequence_number              IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  count(*)
                FROM    IGS_GE_S_GEN_CAL_CON                    sgcc,
                        IGS_CA_DA_INST          dai
                WHERE   dai.CAL_TYPE                    = cp_cal_type AND
                        dai.ci_sequence_number          = cp_sequence_number AND
                        dai.DT_ALIAS                    = sgcc.census_dt_alias AND
                        sgcc.s_control_num              = 1;
        CURSOR c_uop_uv (
                cp_cal_type                     IGS_CA_INST.CAL_TYPE%TYPE,
                cp_sequence_number              IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  uop.unit_cd
                FROM    IGS_PS_UNIT_OFR_PAT             uop,
                        IGS_PS_UNIT_VER                         uv
                WHERE   uop.CAL_TYPE                    = cp_cal_type AND
                        uop.ci_sequence_number          = cp_sequence_number AND
                        uv.unit_cd                      = uop.unit_cd AND
                        uv.version_number               = uop.version_number AND
                        uv.research_unit_ind            = 'Y' AND
			uop.delete_flag = 'N';
        CURSOR c_dai_ci_cs_cat (
                cp_effective_strt_dt_alias      IGS_RE_S_RES_CAL_CON.effective_strt_dt_alias%TYPE,
                cp_effective_end_dt_alias       IGS_RE_S_RES_CAL_CON.effective_end_dt_alias%TYPE) IS
                SELECT  NVL (
                                dai.absolute_val,
                                IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
                                                dai.DT_ALIAS,
                                                dai.sequence_number,
                                                dai.CAL_TYPE,
                                                dai.ci_sequence_number)) AS alias_val,
                        dai.DT_ALIAS,
                        dai.CAL_TYPE,
                        dai.ci_sequence_number
                FROM    IGS_CA_DA_INST          dai,
                        IGS_CA_INST                     ci,
                        IGS_CA_STAT                     cs,
                        IGS_CA_TYPE                     cat
                WHERE   dai.DT_ALIAS                    IN (
                                                        cp_effective_strt_dt_alias,
                                                        cp_effective_end_dt_alias) AND
                        ci.CAL_TYPE                     = dai.CAL_TYPE AND
                        ci.sequence_number              = dai.ci_sequence_number AND
                        cs.CAL_STATUS                   = ci.CAL_STATUS AND
                        cs.s_cal_status                 IN (cst_active,cst_planned) AND
                        cat.CAL_TYPE                    = ci.CAL_TYPE AND
                        cat.S_CAL_CAT                   = cst_teaching
                ORDER BY ci.start_dt ASC,
                        ci.end_dt ASC,
                        DECODE (
                                dai.DT_ALIAS,   cp_effective_strt_dt_alias, 1,
                                                cp_effective_end_dt_alias, 2);
        CURSOR c_cir_cat_ci_cs IS
                SELECT  ci.CAL_TYPE,
                        ci.sequence_number
                FROM    IGS_CA_INST_REL cir,
                        IGS_CA_TYPE                     cat,
                        IGS_CA_INST                     ci,
                        IGS_CA_STAT                     cs
                WHERE   cir.sup_cal_type                = p_acad_cal_type AND
                        cir.sup_ci_sequence_number      = p_acad_sequence_number AND
                        cat.CAL_TYPE                    = cir.sub_cal_type AND
                        cat.S_CAL_CAT                   = cst_load AND
                        ci.CAL_TYPE                     = cir.sub_cal_type AND
                        ci.sequence_number              = cir.sub_ci_sequence_number AND
                        cs.CAL_STATUS                   = ci.CAL_STATUS AND
                        cs.s_cal_status                 IN (cst_active,cst_planned);
        CURSOR c_dla_cir_ci_cs (
                cp_cal_type                     IGS_CA_INST.CAL_TYPE%TYPE,
                cp_sequence_number              IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  'X'
                FROM    IGS_ST_DFT_LOAD_APPO            dla,
                        IGS_CA_INST_REL         cir,
                        IGS_CA_INST                     ci,
                        IGS_CA_STAT                     cs
                WHERE   dla.CAL_TYPE                    = cp_cal_type AND
                        dla.ci_sequence_number          = cp_sequence_number AND
                        cir.sup_cal_type                = p_acad_cal_type AND
                        cir.sup_ci_sequence_number      = p_acad_sequence_number AND
                        cir.sub_cal_type                = dla.teach_cal_type AND
                        ci.CAL_TYPE                     = cir.sub_cal_type AND
                        ci.sequence_number              = cir.sub_ci_sequence_number AND
                        cs.CAL_STATUS                   = ci.CAL_STATUS AND
                        cs.s_cal_status                 IN (cst_active,cst_planned) AND
                        EXISTS  (
                                SELECT  'X'
                                FROM    IGS_RE_S_RES_CAL_CON            srcc,
                                        IGS_CA_DA_INST  dai
                                WHERE   srcc.s_control_num      = 1 AND
                                        dai.CAL_TYPE            = ci.CAL_TYPE AND
                                        dai.ci_sequence_number  = ci.sequence_number AND
                                        dai.DT_ALIAS            IN (
                                                                srcc.effective_strt_dt_alias,
                                                                srcc.effective_end_dt_alias));
        CURSOR c_cir_ci_cs_cat IS
                SELECT  SUM(NVL(cir.load_research_percentage, 0))
                FROM    IGS_CA_INST_REL         cir,
                        IGS_CA_INST                     ci,
                        IGS_CA_STAT                     cs,
                        IGS_CA_TYPE                     cat
                WHERE   cir.sup_cal_type                = p_acad_cal_type AND
                        cir.sup_ci_sequence_number      = p_acad_sequence_number AND
                        ci.CAL_TYPE                     = cir.sub_cal_type AND
                        ci.sequence_number              = cir.sub_ci_sequence_number AND
                        cs.CAL_STATUS                   = ci.CAL_STATUS AND
                        cs.s_cal_status                 IN (cst_active,cst_planned) AND
                        cat.CAL_TYPE                    = ci.CAL_TYPE AND
                        cat.S_CAL_CAT                   = cst_load;
  BEGIN
        -- Load the research calendar configuration
        OPEN c_srcc;
        FETCH c_srcc INTO
                        v_effective_strt_dt_alias,
                        v_effective_end_dt_alias;
        IF c_srcc%NOTFOUND OR
                        v_effective_strt_dt_alias IS NULL OR
                        v_effective_end_dt_alias IS NULL THEN
                CLOSE c_srcc;


                --- added by syam
                Fnd_Message.Set_Name('IGS', 'IGS_CA_NO_RES_EFF_DT');
                --- added by syam

  --- added by syam
                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                                p_s_log_type,
                                p_log_creation_dt,
                                'DATES' || ',' ||
                                p_acad_cal_type || ',' ||
                                TO_CHAR(p_acad_sequence_number),
                                NULL,
                                fnd_message.get);
  --- added by syam



                RETURN;
        END IF;

        CLOSE c_srcc;
        -- Check whether research effective dates are linked to calendars of types
        -- other than TEACHING
        FOR v_dai_cat_rec IN c_dai_cat (
                        v_effective_strt_dt_alias,
                        v_effective_end_dt_alias) LOOP

                --- added by syam
                Fnd_Message.Set_Name('IGS', 'IGS_CA_RES_EFF_IN_CAL');
                fnd_message.set_token('TOKEN1',v_dai_cat_rec.CAL_TYPE || ',' ||v_dai_cat_rec.S_CAL_CAT);

                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                                        p_s_log_type,
                                        p_log_creation_dt,
                                        'DATES' || ',' ||
                                        p_acad_cal_type || ',' ||
                                        TO_CHAR(p_acad_sequence_number),
                                        NULL,
                                        fnd_message.get);
        --- added by syam



        END LOOP;
        -- Perform date alias checks within teaching calendars in the academic year
        FOR v_ci_cs_cat_rec IN c_ci_cs_cat LOOP
                v_last_alias_val := NULL;
                v_last_alias_type := NULL;
                v_out_of_order := FALSE;
                v_strt_counter := 0;
                v_end_counter := 0;


        -- Check one per cal for SDAs.
         CHK_ONE_PER_CAL(v_ci_cs_cat_rec.cal_type,       -- will check for fee cal instance.
	                 v_ci_cs_cat_rec.sequence_number,
			 'DATES',
			 p_s_log_type,
			 p_log_creation_dt);

                FOR v_dai_rec IN c_dai (
                                        v_ci_cs_cat_rec.CAL_TYPE,
                                        v_ci_cs_cat_rec.sequence_number,
                                        v_effective_strt_dt_alias,
                                        v_effective_end_dt_alias) LOOP
                        IF v_last_alias_val IS NOT NULL THEN
                                -- If the last date was not a start date, or the current date is not
                                -- an end date then the order is incorrect.
                                IF v_last_alias_type <> v_effective_strt_dt_alias OR
                                                v_dai_rec.DT_ALIAS <> v_effective_end_dt_alias THEN
                                        v_out_of_order := TRUE;
                                END IF;
                        END IF;
                        -- Increment counters for number of start/end dates
                        IF v_dai_rec.DT_ALIAS = v_effective_strt_dt_alias THEN
                                v_strt_counter := v_strt_counter + 1;
                        ELSE
                                v_end_counter := v_end_counter + 1;
                        END IF;
                        v_last_alias_val := v_dai_rec.alias_val;
                        v_last_alias_type := v_dai_rec.DT_ALIAS;
                END LOOP;
                IF v_strt_counter > 1 OR
                                v_end_counter > 1 OR
                                (v_strt_counter = 0 AND
                                v_end_counter = 1) OR
                                (v_end_counter = 0 AND
                                v_strt_counter = 1) THEN

                        --- added by syam
                        Fnd_Message.Set_Name('IGS', 'IGS_CA_EFF_START_END');

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                                                        p_s_log_type,
                                                        p_log_creation_dt,
                                                        'RESEARCH' || ',' ||
                                                        v_ci_cs_cat_rec.CAL_TYPE || ',' ||
                                                        TO_CHAR(v_ci_cs_cat_rec.sequence_number),
                                                        NULL,
                                                        fnd_message.get);
                        --- added by syam


                ELSE
                        IF v_out_of_order THEN

                        --- added by syam
                            Fnd_Message.Set_Name('IGS', 'IGS_CA_EFF_DATES_OUT_OF_ORDER');

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                                                        p_s_log_type,
                                                        p_log_creation_dt,
                                                        'RESEARCH' || ',' ||
                                                        v_ci_cs_cat_rec.CAL_TYPE || ',' ||
                                                        TO_CHAR(v_ci_cs_cat_rec.sequence_number),
                                                        NULL,
                                                        fnd_message.get);

                         --- added by syam


                        END IF;
                END IF;
                -- If valid research dates perform further checks
                IF v_strt_counter = 1 AND
                                v_end_counter = 1 THEN
                        OPEN c_dai_sgcc (
                                        v_ci_cs_cat_rec.CAL_TYPE,
                                        v_ci_cs_cat_rec.sequence_number);
                        FETCH c_dai_sgcc INTO v_count;
                        CLOSE c_dai_sgcc;
                        IF v_count > 1 THEN

                        --- added by syam
                            Fnd_Message.Set_Name('IGS', 'IGS_CA_TPERIOD_SINGLE_CENS');

                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                'RESEARCH' || ',' ||
                                                v_ci_cs_cat_rec.CAL_TYPE || ',' ||
                                                TO_CHAR(v_ci_cs_cat_rec.sequence_number),
                                                NULL,
                                                fnd_message.get);
                         --- added by syam

                        END IF;
                END IF;
                -- If not a research teaching period, warn against research units being
                -- offered within it
                IF v_strt_counter = 0 AND
                                v_end_counter = 0 THEN
                        OPEN c_uop_uv (
                                        v_ci_cs_cat_rec.CAL_TYPE,
                                        v_ci_cs_cat_rec.sequence_number);
                        FETCH c_uop_uv INTO v_unit_cd;
                        IF c_uop_uv%FOUND THEN
                                CLOSE c_uop_uv;
                        --- added by syam
                            Fnd_Message.Set_Name('IGS', 'IGS_CA_NORMAL_TP_STD_EFTSU_USE');
                            fnd_message.set_token('TOKEN1',v_unit_cd);

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                'RESEARCH' || ',' ||
                                                v_ci_cs_cat_rec.CAL_TYPE || ',' ||
                                                TO_CHAR(v_ci_cs_cat_rec.sequence_number),
                                                NULL,
                                                fnd_message.get);

                        --- added by syam

                        ELSE
                                CLOSE c_uop_uv;
                        END IF;
                END IF;
        END LOOP;
        -- Check for gaps or overlaps in effective research dates ; only report on
        -- logical periods which overlap the context academic period
        v_last_alias_val := NULL;
        v_last_alias_type := NULL;
        v_last_cal_type := NULL;
        v_last_ci_sequence_number := NULL;
        FOR v_dai_ci_cs_cat_rec IN c_dai_ci_cs_cat (
                                                v_effective_strt_dt_alias,
                                                v_effective_end_dt_alias) LOOP


        -- Check one per cal for SDAs.
         CHK_ONE_PER_CAL(v_dai_ci_cs_cat_rec.cal_type,       -- will check for fee cal instance.
	                 v_dai_ci_cs_cat_rec.ci_sequence_number,
			 'RESEARCH',
			 p_s_log_type,
			 p_log_creation_dt);

                IF c_dai_ci_cs_cat%ROWCOUNT > 1 AND
                                v_dai_ci_cs_cat_rec.DT_ALIAS = v_effective_strt_dt_alias THEN
                        IF v_dai_ci_cs_cat_rec.alias_val <= v_last_alias_val THEN
                                IF IGS_EN_GEN_014.ENRS_GET_WITHIN_CI (
                                                        p_acad_cal_type,
                                                        p_acad_sequence_number,
                                                        v_dai_ci_cs_cat_rec.CAL_TYPE,
                                                        v_dai_ci_cs_cat_rec.ci_sequence_number,
                                                        'Y') = 'Y' OR
                                                IGS_EN_GEN_014.ENRS_GET_WITHIN_CI (
                                                                p_acad_cal_type,
                                                                p_acad_sequence_number,
                                                                v_last_cal_type,
                                                                v_last_ci_sequence_number,
                                                                'Y') = 'Y' THEN




                        --- added by syam
                            Fnd_Message.Set_Name('IGS', 'IGS_CA_RES_EFF_DATES_OVERLAP');
                            fnd_message.set_token('TOKEN1',v_dai_ci_cs_cat_rec.DT_ALIAS||':'|| IGS_GE_DATE.IGSCHAR(v_dai_ci_cs_cat_rec.alias_val)|| ', '||v_last_alias_type||':'||IGS_GE_DATE.IGSCHAR(v_last_alias_val));
                        --- added by syam


                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                                                        p_s_log_type,
                                                        p_log_creation_dt,
                                                        'RESEARCH' || ',' ||
                                                        p_acad_cal_type || ',' ||
                                                        TO_CHAR(p_acad_sequence_number),
                                                        NULL,
                                                        fnd_message.get);
                        --- added by syam




                                END IF;
                        ELSIF v_dai_ci_cs_cat_rec.alias_val > (v_last_alias_val + 1) THEN
                                IF IGS_EN_GEN_014.ENRS_GET_WITHIN_CI (
                                                        p_acad_cal_type,
                                                        p_acad_sequence_number,
                                                        v_dai_ci_cs_cat_rec.CAL_TYPE,
                                                        v_dai_ci_cs_cat_rec.ci_sequence_number,
                                                        'Y') = 'Y' OR
                                                IGS_EN_GEN_014.ENRS_GET_WITHIN_CI (
                                                                p_acad_cal_type,
                                                                p_acad_sequence_number,
                                                                v_last_cal_type,
                                                                v_last_ci_sequence_number,
                                                                'Y') = 'Y' THEN

                                --- added by syam
                                Fnd_Message.Set_Name('IGS', 'IGS_CA_GAP_BTW_EFF_PERIODS');
                                fnd_message.set_token('TOKEN1',v_dai_ci_cs_cat_rec.DT_ALIAS||':'||IGS_GE_DATE.IGSCHAR(v_dai_ci_cs_cat_rec.alias_val)||', '||v_last_alias_type||':'||IGS_GE_DATE.IGSCHAR(v_last_alias_val));

                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                                                        p_s_log_type,
                                                        p_log_creation_dt,
                                                        'RESEARCH' || ',' ||
                                                        p_acad_cal_type || ',' ||
                                                        TO_CHAR(p_acad_sequence_number),
                                                        NULL,
                                                        fnd_message.get);
                                --- added by syam



                                END IF;
                        END IF;
                END IF;
                v_last_alias_val := v_dai_ci_cs_cat_rec.alias_val;
                v_last_alias_type := v_dai_ci_cs_cat_rec.DT_ALIAS;
                v_last_cal_type := v_dai_ci_cs_cat_rec.CAL_TYPE;
                v_last_ci_sequence_number := v_dai_ci_cs_cat_rec.ci_sequence_number;
        END LOOP;
        -- Check that the research teaching periods are linked to only a single load
        -- calendar within the academic calendar
        FOR v_cir_cat_ci_cs_rec IN c_cir_cat_ci_cs LOOP

        -- Check one per cal for SDAs.
         CHK_ONE_PER_CAL(v_cir_cat_ci_cs_rec.cal_type,       -- will check for fee cal instance.
	                 v_cir_cat_ci_cs_rec.sequence_number,
			 'RESEARCH',
			 p_s_log_type,
			 p_log_creation_dt);

                FOR v_dla_cir_ci_cs_rec IN c_dla_cir_ci_cs (
                                                        v_cir_cat_ci_cs_rec.CAL_TYPE,
                                                        v_cir_cat_ci_cs_rec.sequence_number) LOOP
                        IF c_dla_cir_ci_cs%ROWCOUNT > 1 THEN

                                --- added by syam
                                Fnd_Message.Set_Name('IGS','IGS_CA_MULT_TP_SINGLE_CAL');
                                fnd_message.set_token('TOKEN1',v_cir_cat_ci_cs_rec.CAL_TYPE);

                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                'RESEARCH' || ',' ||
                                                p_acad_cal_type || ',' ||
                                                TO_CHAR(p_acad_sequence_number),
                                                NULL,
                                                fnd_message.get);
                                ---added by syam



                                EXIT;
                        END IF;
                END LOOP;
        END LOOP;
        -- Check that the research percentage adds up to 100% for the academic period
        OPEN c_cir_ci_cs_cat;
        FETCH c_cir_ci_cs_cat INTO v_total_perc;
        CLOSE c_cir_ci_cs_cat;
        IF v_total_perc <> 100 THEN

                        --- added by syam
                                Fnd_Message.Set_Name('IGS','IGS_CA_RES_PERCENT_NOT_100');

                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                                        p_s_log_type,
                                        p_log_creation_dt,
                                        'RESEARCH' || ',' ||
                                        p_acad_cal_type || ',' ||
                                        TO_CHAR(p_acad_sequence_number),
                                        NULL,
                                        fnd_message.get);
                --- added by syam

        END IF;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_srcc%ISOPEN THEN
                        CLOSE c_srcc;
                END IF;
                IF c_dai_cat%ISOPEN THEN
                        CLOSE c_dai_cat;
                END IF;
                IF c_ci_cs_cat%ISOPEN THEN
                        CLOSE c_ci_cs_cat;
                END IF;
                IF c_dai%ISOPEN THEN
                        CLOSE c_dai;
                END IF;
                IF c_dai_sgcc%ISOPEN THEN
                        CLOSE c_dai_sgcc;
                END IF;
                IF c_uop_uv%ISOPEN THEN
                        CLOSE c_uop_uv;
                END IF;
                IF c_dai_ci_cs_cat%ISOPEN THEN
                        CLOSE c_dai_ci_cs_cat;
                END IF;
                IF c_cir_cat_ci_cs%ISOPEN THEN
                        CLOSE c_cir_cat_ci_cs;
                END IF;
                IF c_dla_cir_ci_cs%ISOPEN THEN
                        CLOSE c_dla_cir_ci_cs;
                END IF;
                IF c_cir_ci_cs_cat%ISOPEN THEN
                        CLOSE c_cir_ci_cs_cat;
                END IF;
                App_Exception.Raise_Exception;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_QLITY.calp_val_research_ci');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values:=p_acad_cal_type||','||(to_char(p_acad_sequence_number));
                Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
                IGS_GE_MSG_STACK.ADD;
                lv_param_values:=p_s_log_type ||','||(to_char(p_log_creation_dt));
                Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END calp_val_research_ci;
  --
  -- To quality check admission calendar instances
  PROCEDURE CALP_VAL_ADM_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
  AS
  ------------------------------------------------------------------
  --
  --Change History:
  --Who         When            What
  --smadathi    11-Sep-2002     Bug 2086177. Added new cursor c_cir_5 and
  --                            associated logic to Check that all admission periods have
  --                            at least one direct subordinate Load calendar instance.
  --skpandey    25-AUG-2005     BUG 4036104
  --                            Added a condition in where clause of cursor c_cict to select only those records which are of Admission type and are subordinate of Academic cal instance.
  -------------------------------------------------------------------
          lv_param_values                       VARCHAR2(1080);
        gv_other_detail                 VARCHAR2(255);
  BEGIN         -- calp_val_adm_ci
        -- Validate that the admission calendar instance has links to the
        -- appropriate calendars.
        -- This routine will the called as part of the calendar quality check.
  DECLARE

        cst_admission                   CONSTANT        VARCHAR2(9) := 'ADMISSION';
        cst_admission2                  CONSTANT        VARCHAR2(10) := 'ADMISSION,';
        cst_academic                    CONSTANT        VARCHAR2(8) := 'ACADEMIC';
        cst_teaching                    CONSTANT        VARCHAR2(8) := 'TEACHING';
        cst_active                      CONSTANT        VARCHAR2(6) := 'ACTIVE';
        cst_planned                     CONSTANT        VARCHAR2(7) := 'PLANNED';
        cst_enrolment                   CONSTANT        VARCHAR2(9) := 'ENROLMENT';
        cst_load                        CONSTANT        VARCHAR2(10) := 'LOAD';
        v_aal_rec_found                 BOOLEAN         := FALSE;
        v_cir_1_rec_found               BOOLEAN         := FALSE;
        v_cir_4_rec_found               BOOLEAN         := FALSE;
        v_daiv_1_rec_found              BOOLEAN         := FALSE;
        v_daiv_2_rec_found              BOOLEAN         := FALSE;
        v_daiv_3_rec_found              BOOLEAN         := FALSE;
        v_cir2_sub_cal_type             IGS_CA_INST_REL.sub_cal_type%TYPE;
        v_cir2_sub_ci_sequence_number   IGS_CA_INST_REL.sub_ci_sequence_number%TYPE;
        v_cal_type                      IGS_CA_INST.CAL_TYPE%TYPE;
        v_sequence_number               IGS_CA_INST.sequence_number%TYPE;
        v_dummy                                         VARCHAR2(1);
        v_count                                         NUMBER;
        CURSOR c_cict   IS
                SELECT  ci.CAL_TYPE,
                        ci.sequence_number
                FROM    IGS_CA_INST     ci,
                        IGS_CA_STAT     cs,
                        IGS_CA_TYPE     cat
                WHERE   IGS_EN_GEN_014.ENRS_GET_WITHIN_CI (
                                        p_acad_cal_type,
                                        p_acad_sequence_number,
                                        ci.CAL_TYPE,
                                        ci.sequence_number, 'N') = 'Y' AND
                        cat.S_CAL_CAT   = cst_admission AND
                        cs.s_cal_status IN (cst_active, cst_planned) AND
                        ci.CAL_TYPE     = cat.CAL_TYPE AND
                        ci.CAL_STATUS   = cs.CAL_STATUS;
        CURSOR c_cir_1 (
                        cp_sub_cal_type         IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sub_sequence_number  IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  cir.sup_cal_type,
                        cir.sup_ci_sequence_number
                FROM    IGS_CA_INST_REL cir,
                        IGS_CA_TYPE                     cat
                WHERE   cir.sub_cal_type                = cp_sub_cal_type AND
                        cir.sub_ci_sequence_number      = cp_sub_sequence_number AND
                        cat.S_CAL_CAT                   = cst_academic AND
                        cir.sup_cal_type                = cat.CAL_TYPE;
        CURSOR c_cat_cir2 (
                        cp_sub_cal_type                 IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sub_sequence_number          IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  cir2.sub_cal_type,
                        cir2.sub_ci_sequence_number
                FROM    IGS_CA_INST_REL cir2,
                        IGS_CA_TYPE cat
                WHERE   cir2.sup_cal_type               = cp_sub_cal_type AND
                        cir2.sup_ci_sequence_number     = cp_sub_sequence_number AND
                        cat.S_CAL_CAT                   = cst_enrolment AND
                        cir2.sub_cal_type               = cat.CAL_TYPE;
        CURSOR c_cir_2 (
                        cp_sub_cal_type                 IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sub_sequence_number          IGS_CA_INST.sequence_number%TYPE,
                        cp_acad_cal_type                IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_acad_sequence_number         IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  'x'
                FROM    IGS_CA_INST_REL cir
                WHERE   cir.sub_cal_type                = cp_sub_cal_type AND
                        cir.sub_ci_sequence_number      = cp_sub_sequence_number AND
                        cir.sup_cal_type                = cp_acad_cal_type AND
                        cir.sup_ci_sequence_number      = cp_acad_sequence_number;
        CURSOR c_cir_3 (
                        cp_sub_cal_type                 IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sub_sequence_number          IGS_CA_INST.sequence_number%TYPE,
                        cp_acad_cal_type                IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_acad_sequence_number         IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  'x'
                FROM    IGS_CA_INST_REL cir
                WHERE   cir.sub_cal_type                = cp_sub_cal_type AND
                        cir.sub_ci_sequence_number      = cp_sub_sequence_number AND
                        cir.sup_cal_type                = cp_acad_cal_type AND
                        cir.sup_ci_sequence_number      <> cp_acad_sequence_number;
        CURSOR c_cir_4 (
                        cp_sub_cal_type                 IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sub_sequence_number          IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  cir.sup_cal_type,
                        cir.sup_ci_sequence_number
                FROM    IGS_CA_INST_REL cir,
                        IGS_CA_TYPE                     cat
                WHERE   cir.sub_cal_type                = cp_sub_cal_type AND
                        cir.sub_ci_sequence_number      = cp_sub_sequence_number AND
                        cat.S_CAL_CAT                   = cst_teaching AND
                        cir.sup_cal_type                = cat.CAL_TYPE;
        CURSOR c_aal (
                        cp_adm_cal_type                 IGS_AD_PERD_AD_CAT.adm_cal_type%TYPE,
                        cp_adm_ci_sequence_number
                                                        IGS_AD_PERD_AD_CAT.adm_ci_sequence_number%TYPE) IS
                SELECT  'x'
                FROM    IGS_AD_PERD_AD_CAT              apac
                WHERE   apac.adm_cal_type               = cp_adm_cal_type AND
                        apac.adm_ci_sequence_number     = cp_adm_ci_sequence_number;
        CURSOR c_daiv_1 (
                        cp_cal_type                     IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_ci_sequence_number           IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  'x'
                FROM    IGS_CA_DA_INST_V                daiv,
                        IGS_AD_CAL_CONF                 sacc
                WHERE   daiv.CAL_TYPE                   = cp_cal_type AND
                        daiv.ci_sequence_number         = cp_ci_sequence_number AND
                        daiv.DT_ALIAS                   = sacc.initialise_adm_perd_dt_alias AND
                        sacc.s_control_num              = 1;
        CURSOR c_daiv_2 (
                        cp_cal_type                     IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_ci_sequence_number           IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  'x'
                FROM    IGS_CA_DA_INST_V                daiv,
                        IGS_AD_CAL_CONF                 sacc
                WHERE   daiv.CAL_TYPE                   = cp_cal_type AND
                        daiv.ci_sequence_number         = cp_ci_sequence_number AND
                        daiv.DT_ALIAS                   = sacc.adm_appl_encmb_chk_dt_alias AND
                        sacc.s_control_num              = 1;
        CURSOR c_daiv_3 (
                        cp_cal_type                     IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_ci_sequence_number           IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  'x'
                FROM    IGS_CA_DA_INST_V                daiv,
                        IGS_AD_CAL_CONF                 sacc
                WHERE   daiv.CAL_TYPE                   = cp_cal_type AND
                        daiv.ci_sequence_number         = cp_ci_sequence_number AND
                        daiv.DT_ALIAS                   = sacc.adm_appl_course_strt_dt_alias AND
                        sacc.s_control_num              = 1;
        CURSOR c_daiv_4 (
                        cp_cal_type                     IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_ci_sequence_number           IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  COUNT(*)
                FROM    IGS_CA_DA_INST_V                daiv,
                        IGS_AD_CAL_CONF                 sacc
                WHERE   daiv.CAL_TYPE                   = cp_cal_type AND
                        daiv.ci_sequence_number         = cp_ci_sequence_number AND
                        daiv.DT_ALIAS                   = sacc.adm_appl_due_dt_alias AND
                        sacc.s_control_num              = 1 AND
                        NOT EXISTS      (
                                SELECT  'x'
                                FROM    IGS_AD_PECRS_OFOP_DT    apcood
                                WHERE   apcood.adm_cal_type             = cp_cal_type AND
                                        apcood.adm_ci_sequence_number   = cp_ci_sequence_number AND
                                        apcood.DT_ALIAS                 = daiv.CAL_TYPE AND
                                        apcood.dai_sequence_number      = daiv.sequence_number);
        CURSOR c_daiv_5 (
                        cp_cal_type                     IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_ci_sequence_number           IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  COUNT(*)
                FROM    IGS_CA_DA_INST_V                daiv,
                        IGS_AD_CAL_CONF                 sacc
                WHERE   daiv.CAL_TYPE                   = cp_cal_type AND
                        daiv.ci_sequence_number         = cp_ci_sequence_number AND
                        daiv.DT_ALIAS                   = sacc.adm_appl_final_dt_alias AND
                        sacc.s_control_num              = 1 AND
                        NOT EXISTS      (
                                SELECT  'x'
                                FROM    IGS_AD_PECRS_OFOP_DT    apcood
                                WHERE   apcood.adm_cal_type             = cp_cal_type AND
                                        apcood.adm_ci_sequence_number   = cp_ci_sequence_number AND
                                        apcood.DT_ALIAS                 = daiv.CAL_TYPE AND
                                        apcood.dai_sequence_number      = daiv.sequence_number);
        CURSOR c_daiv_6 (
                        cp_cal_type                     IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_ci_sequence_number           IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  COUNT(*)
                FROM    IGS_CA_DA_INST_V                daiv,
                        IGS_AD_CAL_CONF                 sacc
                WHERE   daiv.CAL_TYPE                   = cp_cal_type AND
                        daiv.ci_sequence_number         = cp_ci_sequence_number AND
                        daiv.DT_ALIAS                   = sacc.adm_appl_offer_resp_dt_alias AND
                        sacc.s_control_num              = 1 AND
                        NOT EXISTS      (
                                SELECT  'x'
                                FROM    IGS_AD_PECRS_OFOP_DT    apcood
                                WHERE   apcood.adm_cal_type             = cp_cal_type AND
                                        apcood.adm_ci_sequence_number   = cp_ci_sequence_number AND
                                        apcood.DT_ALIAS                 = daiv.CAL_TYPE AND
                                        apcood.dai_sequence_number      = daiv.sequence_number);

        -- Cursor to Check that all admission periods have
	-- at least one direct subordinate Load calendar instance

        CURSOR  c_cir_5 ( cp_c_sup_cal_type        igs_ca_inst.cal_type%TYPE,
                          cp_n_sup_sequence_number igs_ca_inst.sequence_number%TYPE
                        ) IS
        SELECT  cir5.sub_cal_type,
                cir5.sub_ci_sequence_number
        FROM    igs_ca_inst_rel cir5,
                igs_ca_type cat
        WHERE   cir5.sup_cal_type               = cp_c_sup_cal_type
	AND     cir5.sup_ci_sequence_number     = cp_n_sup_sequence_number
	AND     cat.s_cal_cat                   = cst_load
	AND     cir5.sub_cal_type               = cat.cal_type;

        -- Bug : 2694794
        -- cursor to check that only one load calendar instance is attached
        -- as a subordinate calendar under an admission calendar instance

        CURSOR ad_rel_load(p_cal_type igs_ca_inst_all.cal_type%TYPE,
                     p_sequence_number igs_ca_inst_all.sequence_number%TYPE ) IS
        SELECT count(car.sub_ci_sequence_number)
        FROM   igs_ca_inst_rel car,
               igs_ca_inst_all ca,
               igs_ca_type cat
        WHERE
              car.SUP_CI_SEQUENCE_NUMBER= p_sequence_number AND
              car.SUP_CAL_type = p_cal_type AND
              ca.cal_type = car.sub_cal_type AND
              ca.sequence_number = car.sub_ci_sequence_number AND
              ca.cal_type = cat.cal_type AND
              cat.s_cal_cat = 'LOAD' ;

	rec_c_cir_5 c_cir_5%ROWTYPE;
  BEGIN
	-- Select admission periods
        FOR v_cict_rec IN c_cict LOOP
                -- Check that all admission period have at least one direct superior
                -- academic period.
                v_cal_type := v_cict_rec.CAL_TYPE;
                v_sequence_number := v_cict_rec.sequence_number;
		-- Check one per cal for SDAs.
		CHK_ONE_PER_CAL(v_cal_type,       -- will check for acad cal instance.
				v_sequence_number,
				cst_admission2,
				p_s_log_type,
				p_log_creation_dt);

                FOR v_cir_1_rec IN c_cir_1(
                                        v_cal_type,
                                        v_sequence_number) LOOP
                        v_cir_1_rec_found := TRUE;
                        -- Only check admission period for the academic period parameter
                        OPEN c_cir_2(
                                v_cal_type,
                                v_sequence_number,
                                p_acad_cal_type,
                                p_acad_sequence_number);
                        FETCH   c_cir_2 INTO v_dummy;
                        IF(c_cir_2%FOUND) THEN
                                CLOSE c_cir_2;
                                -- Identify if admission period is linked to another academic period
                                -- of the same academic calendar type
                                FOR v_cir_3_rec IN c_cir_3(
                                                        v_cal_type,
                                                        v_sequence_number,
                                                        p_acad_cal_type,
                                                        p_acad_sequence_number) LOOP


                        --- added by syam
                                Fnd_Message.Set_Name('IGS','IGS_CA_ADMCAL_ONLY_1_ACADCAL');

                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                cst_admission2 || v_cal_type || ',' || TO_CHAR(v_sequence_number),
                                                NULL,
                                                fnd_message.get);


                                END LOOP;
                                --Check that all admission periods have at least one direct
                                --subordinate enrolment period
                                OPEN c_cat_cir2(
                                        v_cal_type,
                                        v_sequence_number);
                                FETCH c_cat_cir2 INTO   v_cir2_sub_cal_type,
                                                        v_cir2_sub_ci_sequence_number;
                                IF c_cat_cir2%NOTFOUND THEN
                                        CLOSE c_cat_cir2;

                                --- added by syam
                                Fnd_Message.Set_Name('IGS','IGS_CA_ADMCAL_HAVE_1_ENROLCAL');

                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                                                p_s_log_type,
                                                                                p_log_creation_dt,
                                                                                cst_admission2|| v_cal_type ||',' || TO_CHAR(v_sequence_number),
                                                                                NULL,
                                                                                fnd_message.get);
                                --- added by syam


                                ELSE
                                        CLOSE c_cat_cir2;
                                END IF;

                                --Check that all admission periods have at least one
                                --subordinate Academic Term (Load) period
                                OPEN c_cir_5 ( cp_c_sup_cal_type        => v_cal_type,
                                               cp_n_sup_sequence_number => v_sequence_number
					      );
		                FETCH c_cir_5 INTO rec_c_cir_5;
				IF c_cir_5%NOTFOUND THEN
				  FND_MESSAGE.SET_NAME('IGS','IGS_CA_ADMCAL_HAVE_1_LOAD');
                                  igs_ge_gen_003.genp_ins_log_entry( p_s_log_type,
                                                                     p_log_creation_dt,
                                                                     cst_admission2|| v_cal_type ||',' || TO_CHAR(v_sequence_number),
                                                                     NULL,
                                                                     fnd_message.get
								    );
				END IF;
				CLOSE c_cir_5;

                                -- Bug : 2694794
                                -- check that only one load calendar instance is attached under an admission calendar
                                -- as subordinate calendar
                                OPEN ad_rel_load(v_cal_type,v_sequence_number);
                                FETCH ad_rel_load INTO v_count;
                                IF v_count > 1 THEN
                                  FND_MESSAGE.SET_NAME('IGS','IGS_CA_ADM_CAL_SUB_LOAD');
                                  igs_ge_gen_003.genp_ins_log_entry( p_s_log_type,
                                                                     p_log_creation_dt,
                                                                     cst_admission2|| v_cal_type ||',' || TO_CHAR(v_sequence_number),
                                                                     NULL,
                                                                     fnd_message.get
								    );
                                END IF;
                                CLOSE ad_rel_load;


                                -- Check that the admission period in the academic period has at least one
                                -- direct superior teaching period
                                FOR v_cir_4_rec IN c_cir_4(
                                                        v_cal_type,
                                                        v_sequence_number) LOOP
                                        v_cir_4_rec_found := TRUE;
                                END LOOP;
                                IF(v_cir_4_rec_found = FALSE) THEN

                                --- added by syam
                                Fnd_Message.Set_Name('IGS','IGS_CA_ADMCAL_HAVE_1_TEACHCAL');
                                --- added by syam

                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                cst_admission2 || v_cal_type || ',' || TO_CHAR(v_sequence_number),
                                                NULL,
                                                fnd_message.get);
                                 --- added by syam

                                ELSE
                                        v_cir_4_rec_found := FALSE;
                                END IF;
                                -- Check that the admission period is defined by an admission category
                                FOR v_aal_rec IN c_aal(
                                                        v_cal_type,
                                                        v_sequence_number) LOOP
                                        v_aal_rec_found := TRUE;
                                END LOOP;
                                IF(v_aal_rec_found = FALSE) THEN

                                --- added by syam
                                Fnd_Message.Set_Name('IGS','IGS_CA_ADMCAL_DEFINE_1_ADMCAT');

                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                cst_admission2 || v_cal_type || ',' || TO_CHAR(v_sequence_number),
                                                NULL,
                                                fnd_message.get);
                                --- added by syam


                                ELSE
                                        v_aal_rec_found := FALSE;
                                END IF;
                                -- Validate that important dates exist in admission period
                                FOR v_daiv_1_rec IN c_daiv_1(
                                                        v_cal_type,
                                                        v_sequence_number) LOOP
                                        v_daiv_1_rec_found := TRUE;
                                END LOOP;
                                IF(v_daiv_1_rec_found = FALSE) THEN

                                --- added by syam
                                fnd_Message.Set_Name('IGS','IGS_CA_ADMCAL_NO_INIT_DATE');

                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                cst_admission2 || v_cal_type || ',' || TO_CHAR(v_sequence_number),
                                                NULL,
                                                fnd_message.get);
                                --- added by syam

                                ELSE
                                        v_daiv_1_rec_found := FALSE;
                                END IF;
                                FOR v_daiv_2_rec IN c_daiv_2(
                                                        v_cal_type,
                                                        v_sequence_number) LOOP
                                        v_daiv_2_rec_found := TRUE;
                                END LOOP;
                                IF(v_daiv_2_rec_found = FALSE) THEN


                                --- added by syam
                                fnd_Message.Set_Name('IGS','IGS_CA_ADMCAL_NO_ENCUMB_DATE');

                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                cst_admission2 || v_cal_type || ',' || TO_CHAR(v_sequence_number),
                                                NULL,
                                                fnd_message.get);


                                ELSE
                                        v_daiv_2_rec_found := FALSE;
                                END IF;
                                FOR v_daiv_3_rec IN c_daiv_3(
                                                        v_cal_type,
                                                        v_sequence_number) LOOP
                                        v_daiv_3_rec_found := TRUE;
                                END LOOP;
                                IF(v_daiv_3_rec_found = FALSE) THEN


                                --- added by syam
                                  fnd_Message.Set_Name('IGS','IGS_CA_ADMCAL_NO_PSCOURSE_DATE');
                                --- added by syam

                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                cst_admission2 || v_cal_type || ',' || TO_CHAR(v_sequence_number),
                                                NULL,
                                                fnd_message.get);

                                ELSE
                                        v_daiv_3_rec_found := FALSE;
                                END IF;
                                -- Check that for date aliases that can be attached to admission period
                                -- IGS_PS_COURSE
                                -- offering option override, only one date value in the admission must
                                -- not be  linked to IGS_AD_PECRS_OFOP_DT
                                OPEN    c_daiv_4(
                                                v_cal_type,
                                                v_sequence_number);
                                FETCH   c_daiv_4 INTO v_count;
                                CLOSE   c_daiv_4;
                                IF(v_count > 1) THEN


                                 --- added by syam
                                  fnd_Message.Set_Name('IGS','IGS_CA_ADMCAL_THAN_1_DUEDATE');

                                --- added by syam

                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                cst_admission2 || v_cal_type || ',' || TO_CHAR(v_sequence_number),
                                                NULL,
                                                fnd_message.get);


                                END IF;
                                OPEN    c_daiv_5(
                                                v_cal_type,
                                                v_sequence_number);
                                FETCH   c_daiv_5 INTO v_count;
                                CLOSE   c_daiv_5;
                                IF(v_count > 1) THEN


                                 --- added by syam
                                  fnd_Message.Set_Name('IGS','IGS_CA_ADMCAL_THAN_1_APPLDATE');
                                  --- added by syam

                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                cst_admission2 || v_cal_type || ',' || TO_CHAR(v_sequence_number),
                                                NULL,
                                                fnd_Message.get);

                                END IF;
                                OPEN    c_daiv_6(
                                                v_cal_type,
                                                v_sequence_number);
                                FETCH   c_daiv_6 INTO v_count;
                                CLOSE   c_daiv_6;
                                IF(v_count > 1) THEN

                                --- added by syam
                                  fnd_Message.Set_Name('IGS','IGS_CA_ADMCAL_THAN_1_OFRDATE');

                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                cst_admission2 || v_cal_type || ',' || TO_CHAR(v_sequence_number),
                                                NULL,
                                                fnd_message.get);
                                  --- added by syam

                                END IF;
                        ELSE
                                CLOSE c_cir_2;
                        END IF; -- (c_cir_2%FOUND)
                END LOOP; -- c_cir_1
                IF(v_cir_1_rec_found = FALSE) THEN

                --- added by syam
                  fnd_Message.Set_Name('IGS','IGS_CA_ADMCAL_HAVE_1_ACADCAL');

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                        p_s_log_type,
                                                        p_log_creation_dt,
                                                        cst_admission2 || v_cal_type || ',' || TO_CHAR(v_sequence_number),
                                                        NULL,
                                                        fnd_message.get);

                --- added by syam

                ELSE
                        v_cir_1_rec_found := FALSE;
                END IF;
        END LOOP; -- c_cict
        RETURN;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_cict%ISOPEN THEN
                        CLOSE c_cict;
                END IF;
                IF c_cir_1%ISOPEN THEN
                        CLOSE c_cir_1;
                END IF;
                IF c_cat_cir2%ISOPEN THEN
                        CLOSE c_cat_cir2;
                END IF;
                IF c_cir_2%ISOPEN THEN
                        CLOSE c_cir_2;
                END IF;
                IF c_cir_3%ISOPEN THEN
                        CLOSE c_cir_3;
                END IF;
                IF c_cir_4%ISOPEN THEN
                        CLOSE c_cir_4;
                END IF;
                IF c_aal%ISOPEN THEN
                        CLOSE c_aal;
                END IF;
                IF c_daiv_1%ISOPEN THEN
                        CLOSE c_daiv_1;
                END IF;
                IF c_daiv_2%ISOPEN THEN
                        CLOSE c_daiv_2;
                END IF;
                IF c_daiv_3%ISOPEN THEN
                        CLOSE c_daiv_3;
                END IF;
                IF c_daiv_4%ISOPEN THEN
                        CLOSE c_daiv_4;
                END IF;
                IF c_daiv_5%ISOPEN THEN
                        CLOSE c_daiv_5;
                END IF;
                IF c_daiv_6%ISOPEN THEN
                        CLOSE c_daiv_6;
                END IF;
		IF c_cir_5%ISOPEN THEN
		  CLOSE c_cir_5;
		END IF;
                App_Exception.Raise_Exception;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_QLITY.calp_val_adm_ci');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values:=p_acad_cal_type||','||(to_char(p_acad_sequence_number));
                 Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                 FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
                 IGS_GE_MSG_STACK.ADD;
                lv_param_values:=p_s_log_type||','||(to_char(p_log_creation_dt));
                 Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                 FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
                 IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END calp_val_adm_ci;

  --
  -- To quality check calendar data structures
  -- Bug # 2279265
  -- Update to Calendar Quality Check report
  -- This function is called from the report IGSCAS01
  FUNCTION CALP_VAL_QUAL_CHK(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_calendar_category IN VARCHAR2 )
  RETURN DATE AS
        lv_param_values                 VARCHAR2(1080);
        gv_other_detail         VARCHAR2(255);
  BEGIN
  DECLARE

        cst_all         CONSTANT        VARCHAR2(3) := 'ALL';
        cst_load        CONSTANT        VARCHAR2(4) := 'LOAD';
        cst_dates       CONSTANT        VARCHAR2(5) := 'DATES';
        cst_teaching    CONSTANT        VARCHAR2(8) := 'TEACHING';
        cst_enrolment   CONSTANT        VARCHAR2(9) := 'ENROLMENT';
        cst_admission   CONSTANT        VARCHAR2(9) := 'ADMISSION';
        cst_research    CONSTANT        VARCHAR2(8) := 'RESEARCH';
        cst_calquality  CONSTANT        VARCHAR2(10) := 'CALQUALITY';
        v_creation_dt   DATE;
  BEGIN -- calp_val_qual_chk
        -- Calendar quality check module
        -- This routine is triggered from a Report and calls the required dbase
        -- routines to perform  a quality check of the calendar structures
        IGS_GE_GEN_003.GENP_INS_LOG(cst_calquality,
                     p_acad_cal_type || ',' || TO_CHAR(p_acad_sequence_number),
                     v_creation_dt);
        IGS_CA_VAL_QLITY.g_cal_cat := p_calendar_category;
	-- Call the procedure to check if the DA used in SDAs have more than 1 instance in the Calendar for which the report is run.
        CHK_ONE_PER_CAL(p_acad_cal_type,p_acad_sequence_number,'ALL',cst_calquality,v_creation_dt);  -- will check for ACAD cal instance.
        -- Process TEACHING calendars
        IF p_calendar_category = cst_all OR
                        p_calendar_category = cst_teaching THEN
                IGS_CA_VAL_QLITY.calp_val_teach_ci(
                                        p_acad_cal_type,
                                        p_acad_sequence_number,
                                        cst_calquality,
                                        v_creation_dt);
        END IF;
        -- Process LOAD calendars
        IF p_calendar_category = cst_all OR
                        p_calendar_category = cst_load THEN
                IGS_CA_VAL_QLITY.calp_val_load_ci(
                                p_acad_cal_type,
                                p_acad_sequence_number,
                                cst_calquality,
                                v_creation_dt);
        END IF;
        -- Process ENROLMENT calendars
        IF p_calendar_category = cst_all OR
                        p_calendar_category = cst_enrolment THEN
                IGS_CA_VAL_QLITY.calp_val_enrol_ci(
                                p_acad_cal_type,
                                p_acad_sequence_number,
                                cst_calquality,
                                v_creation_dt);
        END IF;
        -- Process ADMISSION calendars
        IF p_calendar_category = cst_all OR
                        p_calendar_category = cst_admission THEN
                IGS_CA_VAL_QLITY.calp_val_adm_ci(
                                p_acad_cal_type,
                                p_acad_sequence_number,
                                cst_calquality,
                                v_creation_dt);
        END IF;
        -- Process DATES calendars
        IF p_calendar_category = cst_all OR
                        p_calendar_category = cst_dates THEN
                IGS_CA_VAL_QLITY.calp_val_dates_ci(
                                p_acad_cal_type,
                                p_acad_sequence_number,
                                cst_calquality,
                                v_creation_dt);
        END IF;

        IF p_calendar_category = cst_all OR
                        p_calendar_category = cst_research THEN
                IGS_CA_VAL_QLITY.calp_val_research_ci(
                                p_acad_cal_type,
                                p_acad_sequence_number,
                                cst_calquality,
                                v_creation_dt);
        END IF;

        -- Process Award calendars
        -- The Award calendars selected should be ones that overlap with
        -- the Academic Calendar selected in the CM parameters.

	IF p_calendar_category = cst_all THEN
            calp_val_award_ci( p_c_acad_cal_type        => p_acad_cal_type,
                               p_n_acad_sequence_number => p_acad_sequence_number,
                               p_c_s_log_type           => cst_calquality ,
                               p_d_log_creation_dt      => v_creation_dt
		             );


	END IF;


        COMMIT;
        RETURN v_creation_dt;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_QLITY.calp_val_qual_chk');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values:=  p_acad_cal_type||','||(to_char(p_acad_sequence_number)) ;
                 Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                 FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
                 IGS_GE_MSG_STACK.ADD;
                lv_param_values:=  p_calendar_category ;
                 Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                 FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
                 IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END calp_val_qual_chk;
  --
  -- To quality check system control dates within calendar instances.
  PROCEDURE CALP_VAL_DATES_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
  AS
       lv_param_values          VARCHAR2(1080);
        cst_load                        constant IGS_CA_TYPE.S_CAL_CAT%TYPE := 'LOAD';
        cst_academic                    constant IGS_CA_TYPE.S_CAL_CAT%TYPE := 'ACADEMIC';
        cst_teaching                    constant IGS_CA_TYPE.S_CAL_CAT%TYPE := 'TEACHING';
        cst_enrolment                   constant IGS_CA_TYPE.S_CAL_CAT%TYPE := 'ENROLMENT';
        gv_other_detail         VARCHAR2(255);
  BEGIN
  DECLARE
        CURSOR c_chk_dt_aliases IS
                SELECT  load_effect_dt_alias,
                        commencement_dt_alias,
                        commence_cutoff_dt_alias,
                        enr_form_due_dt_alias,
                        enr_pckg_prod_dt_alias,
                        effect_enr_strt_dt_alias
                FROM    IGS_EN_CAL_CONF
                WHERE   s_control_num = 1;
        CURSOR c_chk_da_exists (
                cp_dt_alias             IGS_EN_CAL_CONF.load_effect_dt_alias%TYPE,
                cp_s_cal_cat            IGS_CA_TYPE.S_CAL_CAT%TYPE ) IS
                SELECT  'x'
                FROM    IGS_CA_DA_INST_V daiv,
                        IGS_CA_TYPE ct
                WHERE   daiv.DT_ALIAS = cp_dt_alias                             AND
                        daiv.CAL_TYPE = ct.CAL_TYPE                             AND
                        ct.S_CAL_CAT <> cp_s_cal_cat;
        CURSOR c_chk_da_exists1 (
                cp_dt_alias             IGS_EN_CAL_CONF.load_effect_dt_alias%TYPE,
                cp_s_cal_cat            IGS_CA_TYPE.S_CAL_CAT%TYPE ,
                cp_s_cal_cat1           IGS_CA_TYPE.S_CAL_CAT%TYPE) IS
                SELECT  'x'
                FROM    IGS_CA_DA_INST_V daiv,
                        IGS_CA_TYPE ct
                WHERE   daiv.DT_ALIAS = cp_dt_alias                             AND
                        daiv.CAL_TYPE = ct.CAL_TYPE                             AND
                        ct.S_CAL_CAT <> cp_s_cal_cat                            AND
                        ct.S_CAL_CAT <> cp_s_cal_cat1;
        v_load_effect_dt_alias          IGS_EN_CAL_CONF.load_effect_dt_alias%TYPE;
        v_commencement_dt_alias         IGS_EN_CAL_CONF.commencement_dt_alias%TYPE;
        v_commence_cutoff_dt_alias      IGS_EN_CAL_CONF.commence_cutoff_dt_alias%TYPE;
        v_enr_form_due_dt_alias         IGS_EN_CAL_CONF.enr_form_due_dt_alias%TYPE;
        v_enr_pckg_prod_dt_alias        IGS_EN_CAL_CONF.enr_pckg_prod_dt_alias%TYPE;
        v_effect_enr_strt_dt_alias      IGS_EN_CAL_CONF.effect_enr_strt_dt_alias%TYPE;
        v_check_dt_alias_flag   CHAR;

        v_test_flag             BOOLEAN := FALSE;
  BEGIN
        -- Check optional enrolment date aliases from the IGS_EN_CAL_CONF table
        OPEN c_chk_dt_aliases;
        FETCH c_chk_dt_aliases INTO
                v_load_effect_dt_alias,
                v_commencement_dt_alias,
                v_commence_cutoff_dt_alias,
                v_enr_form_due_dt_alias,
                v_enr_pckg_prod_dt_alias,
                v_effect_enr_strt_dt_alias;
        CLOSE c_chk_dt_aliases;
        OPEN c_chk_da_exists( v_load_effect_dt_alias, cst_load );
        FETCH c_chk_da_exists INTO v_check_dt_alias_flag;
        IF c_chk_da_exists%FOUND THEN

                                --- added by syam
                                          fnd_Message.Set_Name('IGS','IGS_CA_LODEFFDT_WITHIN_CALINS');
                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                p_s_log_type,
                                p_log_creation_dt,
                                'DATES' || ',' || p_acad_cal_type || ',' || TO_CHAR(p_acad_sequence_number),
                                NULL,
                                fnd_message.get);

                                --- added by syam
        END IF;
        CLOSE c_chk_da_exists;
        IF v_commencement_dt_alias IS NOT NULL THEN
                OPEN c_chk_da_exists( v_commencement_dt_alias, cst_academic );
                FETCH c_chk_da_exists INTO v_check_dt_alias_flag;
                IF c_chk_da_exists%FOUND THEN


                                --- added by syam
                                          fnd_Message.Set_Name('IGS','IGS_CA_COMMDT_WITHIN_CALINS');
                                --- added by syam

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                'DATES' || ',' || p_acad_cal_type || ',' || TO_CHAR(p_acad_sequence_number),
                                                NULL,
                                                fnd_message.get);

                END IF;
                CLOSE c_chk_da_exists;
        END IF;
        IF v_commence_cutoff_dt_alias IS NOT NULL THEN
                OPEN c_chk_da_exists( v_commence_cutoff_dt_alias, cst_teaching );
                FETCH c_chk_da_exists INTO v_check_dt_alias_flag;
                IF c_chk_da_exists%FOUND THEN

                                --- added by syam
                                  fnd_Message.Set_Name('IGS','IGS_CA_COMCUTOF_WITHIN_CALINS');
                                --- added by syam
                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                'DATES' || ',' || p_acad_cal_type || ',' || TO_CHAR(p_acad_sequence_number),
                                                NULL,
                                                fnd_message.get);

                END IF;
                CLOSE c_chk_da_exists;
        END IF;
        IF v_enr_form_due_dt_alias IS NOT NULL THEN
                OPEN c_chk_da_exists1( v_enr_form_due_dt_alias, cst_academic, cst_enrolment );
                FETCH c_chk_da_exists1 INTO v_check_dt_alias_flag;
                IF c_chk_da_exists1%FOUND THEN
                                --- added by syam
                                  fnd_Message.Set_Name('IGS','IGS_CA_ENRDUEDT_WITHIN_CALINS');
                                --- added by syam

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                p_s_log_type,
                                p_log_creation_dt,
                                'DATES' || ',' || p_acad_cal_type || ',' || TO_CHAR(p_acad_sequence_number),
                                NULL,
                                fnd_message.get);


                END IF;
                CLOSE c_chk_da_exists1;
        END IF;
        IF v_enr_pckg_prod_dt_alias IS NOT NULL THEN
                OPEN c_chk_da_exists1( v_enr_pckg_prod_dt_alias, cst_academic,
                                                 cst_enrolment);
                FETCH c_chk_da_exists1 INTO v_check_dt_alias_flag;
                IF c_chk_da_exists1%FOUND THEN

                                --- added by syam
                                                  fnd_Message.Set_Name('IGS','IGS_CA_ENRPKGDT_WITHIN_CALINS');
                                --- added by syam


                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                'DATES' || ',' || p_acad_cal_type || ',' || TO_CHAR(p_acad_sequence_number),
                                                NULL,
                                                fnd_message.get);


                END IF;
                CLOSE c_chk_da_exists1;
        END IF;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_QLITY.calp_val_dates_ci');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values:= p_acad_cal_type||','||(to_char(p_acad_sequence_number));
                 Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                 FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
                 IGS_GE_MSG_STACK.ADD;
                lv_param_values:= p_s_log_type ||','||(to_char(p_log_creation_dt));
                 Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                 FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
                 IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END calp_val_dates_ci;
  --
  -- To quality check enrolment calendar instances
  PROCEDURE CALP_VAL_ENROL_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
  AS
  ------------------------------------------------------------------
  --Change History:
  --Who            When            What
  --smadathi    16-sep-2002        Bug 2086177. Included Fetching of Planned calendars
  --                               along with the Active ones
  --skpandey    23-SEP-2005        BUG 4036104
  --                               Description: Modified the cursor c_chk_acad_ci to select only those records which are of Enrollment type and are subordinate of Academic cal instance.
  --skpandey    27-SEP-2005        Bug: 4036104
  --                               Description: Modified the cursor c_chk_enr_ci definition to select only those enrolment calendars (from cursor c_chk_acad_ci) which have subordinates of any type
  ------------------------------------------------------------------
        gv_other_detail         VARCHAR2(255);

  BEGIN
  DECLARE
        cst_academic            CONSTANT IGS_CA_TYPE.S_CAL_CAT%TYPE := 'ACADEMIC';
        cst_admission           CONSTANT IGS_CA_TYPE.S_CAL_CAT%TYPE := 'ADMISSION';
        cst_enrolment           CONSTANT IGS_CA_TYPE.S_CAL_CAT%TYPE := 'ENROLMENT';
        cst_active              CONSTANT IGS_CA_STAT.s_cal_status%TYPE := 'ACTIVE';
        cst_planned             CONSTANT IGS_CA_STAT.s_cal_status%TYPE := 'PLANNED';
        CURSOR c_chk_acad_ci IS
                SELECT  ci.cal_type, ci.sequence_number, ct.S_CAL_CAT
                FROM    IGS_CA_INST ci,
                        IGS_CA_TYPE ct,
                        IGS_CA_STAT cs
                WHERE   IGS_EN_GEN_014.ENRS_GET_WITHIN_CI (
                                        p_acad_cal_type,
                                        p_acad_sequence_number,
                                        ci.CAL_TYPE,
                                        ci.sequence_number, 'N') = 'Y'  AND
                        cs.s_cal_status IN (cst_active,cst_planned)     AND
                        ct.S_CAL_CAT = cst_enrolment                   AND
                        cs.CAL_STATUS = ci.CAL_STATUS                   AND
                        ct.CAL_TYPE = ci.CAL_TYPE;

        CURSOR c_chk_enr_ci (cp_cal_type IGS_CA_INST.cal_type%type, cp_sequence_number IGS_CA_INST.sequence_number%type) IS
                SELECT  cir.sup_cal_type, cir.sup_ci_sequence_number, ct2.S_CAL_CAT
                FROM    IGS_CA_INST ci,
                        IGS_CA_TYPE ct,
                        IGS_CA_TYPE ct2,
                        IGS_CA_STAT cs,
                        IGS_CA_INST_REL cir
                WHERE   cs.s_cal_status IN (cst_active,cst_planned)     AND
                        ct.S_CAL_CAT = cst_enrolment                    AND
                        ci.CAL_TYPE = ct.CAL_TYPE                       AND
                        cs.CAL_STATUS = ci.CAL_STATUS                   AND
                        cir.sup_cal_type = cp_cal_type                  AND
                        cir.sup_ci_sequence_number = cp_sequence_number AND
                        ct2.CAL_TYPE = cir.sub_cal_type;
  BEGIN
        --- Check that enrolment calendars are only linked to academic superior
        --- calendar instances.
        FOR v_chk_acad_ci IN c_chk_acad_ci LOOP

        --------
                --- added by syam
                  fnd_Message.Set_Name('IGS','IGS_CA_ENRCAL_ONLY_ACADMCAL');
                  fnd_message.set_token('TOKEN1',v_chk_acad_ci.S_CAL_CAT);


                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY( p_s_log_type,
                                p_log_creation_dt,
                                'ENROLMENT,' || v_chk_acad_ci.cal_type || ',' ||
                                                 TO_CHAR(v_chk_acad_ci.sequence_number),
                                NULL,
                                fnd_message.get);
                --- added by syam

        --- Select enrolment calendars which have subordinates of any type
        -- skpandey changed for loop position, earlier it was an independent loop
                 FOR v_chk_enr_ci IN c_chk_enr_ci(v_chk_acad_ci.cal_type, v_chk_acad_ci.sequence_number) LOOP

                     --- added by syam
                       fnd_Message.Set_Name('IGS','IGS_CA_ENRCAL_NO_SUBORCAL');
                       fnd_message.set_token('TOKEN1',v_chk_enr_ci.S_CAL_CAT);
                     --- added by syam


                       IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                   p_s_log_type,
                                   p_log_creation_dt,
                                   'ENROLMENT,' || v_chk_enr_ci.sup_cal_type || ',' ||
                                                TO_CHAR(v_chk_enr_ci.sup_ci_sequence_number),
                                   NULL,
                                   fnd_message.get);

                END LOOP;

        END LOOP;

  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_QLITY.calp_val_enrol_ci');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END calp_val_enrol_ci;
  --
  -- To quality check load calendar instances
  PROCEDURE CALP_VAL_LOAD_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
  AS
  ------------------------------------------------------------------
  --Change History:
  --Who            When            What
  --smadathi     11-Sep-2002       Bug 2086177. Modified code logic to define
  --                               Award and Admission calendar categories as
  --                               superior to the 'LOAD' category.
  --                               Included Fetching of Planned calendars
  --                               along with the Active ones.
  --                               A mandatory relationship between award,fee and Load
  --                               calendars established
  --schodava     17-Apr-2002       Bug #2279265
  --                               Added 'FEE' and 'PROGRESS' calendar categories
  --                               to the list of calendar categories
  --                               allowed to be superior to the 'LOAD' category
  -- nsidana    7/30/2004          Bug : 3736551 : Added check to verify that load calenders
  --                               do not overlap within a same academic calender.
  --
  ------------------------------------------------------------------

         lv_param_values                        VARCHAR2(1080);
        gv_other_detail         VARCHAR2(255);
  BEGIN
  DECLARE

        v_sub_cal_type                  IGS_CA_INST_REL.sub_cal_type%TYPE;
        v_cal_type                      IGS_EN_ATD_TYPE_LOAD.CAL_TYPE%TYPE;
        v_key                           VARCHAR2(50);
        v_warning_msg                   VARCHAR2(2000);
        v_last_upper                    IGS_EN_ATD_TYPE_LOAD.upper_enr_load_range%TYPE;
        v_count                         NUMBER;

        -- 1. Select load calendars which have superior
        -- relationships to parents other than academic,fee,award,admission and progress
        CURSOR c_ci_cat_cs IS
                SELECT  ci.CAL_TYPE,
                        ci.sequence_number
                FROM    IGS_CA_INST                     ci,
                        IGS_CA_TYPE                     cat,
                        IGS_CA_STAT                     cs
                WHERE   cs.s_cal_status IN ('ACTIVE','PLANNED') AND
                        cat.S_CAL_CAT = 'LOAD' AND
                        cat.CAL_TYPE = ci.CAL_TYPE AND
                        cs.CAL_STATUS = ci.CAL_STATUS;
        CURSOR c_cir_ci_cat (
                cp_sub_cal_type                 IGS_CA_INST_REL.sub_cal_type%TYPE,
                cp_sub_ci_sequence_number
                        IGS_CA_INST_REL.sub_ci_sequence_number%TYPE) IS
                SELECT  cat.S_CAL_CAT
                FROM    IGS_CA_INST_REL cir,
                        IGS_CA_INST                     ci,
                        IGS_CA_TYPE                     cat
                WHERE   cir.sub_cal_type = cp_sub_cal_type AND
                        cir.sub_ci_sequence_number = cp_sub_ci_sequence_number AND
                        ci.CAL_TYPE = cir.sup_cal_type AND
                        ci.sequence_number = cir.sup_ci_sequence_number AND
                        cat.CAL_TYPE = ci.CAL_TYPE;
        -- 2. Loop through all load calendars in the specified
        -- academic year and check for valid links
        CURSOR c_load_calendars IS
                SELECT  ci.CAL_TYPE,
                        ci.sequence_number
                FROM    IGS_CA_INST     ci,
                        IGS_CA_TYPE     cat,
                        IGS_CA_STAT     cs
                WHERE   cs.s_cal_status IN ('ACTIVE','PLANNED') AND
                        cat.S_CAL_CAT = 'LOAD' AND
                        cs.CAL_STATUS = ci.CAL_STATUS AND
                        cat.CAL_TYPE = ci.CAL_TYPE AND
                        IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                                        p_acad_cal_type,
                                        p_acad_sequence_number,
                                        ci.CAL_TYPE,
                                        ci.sequence_number,
                                        'N') = 'Y';
        -- 2.1 Check for overlapping load calenders.

        CURSOR c_chk_overlap(cp_cal_type igs_ca_inst.cal_type%TYPE,cp_seq_num igs_ca_inst.sequence_number%TYPE)
	IS
	  SELECT  ci.alternate_code,ci.description,ci.start_dt,ci.end_dt
 	  FROM    IGS_CA_INST     ci,
	          IGS_CA_INST     ci2,
		  IGS_CA_TYPE     cat,
		  IGS_CA_STAT     cs,
		  IGS_CA_INST_REL car
	  WHERE
		  ci2.cal_type        = cp_cal_type AND
		  ci2.sequence_number = cp_seq_num AND
	  	  cs.s_cal_status IN ('ACTIVE','PLANNED') AND
		  cat.S_CAL_CAT = 'LOAD' AND
		  cs.CAL_STATUS = ci.CAL_STATUS AND
		  cat.CAL_TYPE = ci.CAL_TYPE AND
		  car.SUP_CAL_TYPE           = p_acad_cal_type AND
		  car.SUP_CI_SEQUENCE_NUMBER = p_acad_sequence_number AND
		  car.SUB_CAL_TYPE           = ci.CAL_TYPE AND
		  car.SUB_CI_SEQUENCE_NUMBER = ci.sequence_number AND
		  (ci.rowid <> ci2.rowid) AND
		  (
		   (ci2.start_dt BETWEEN ci.start_dt AND ci.end_dt) OR
		   (ci2.end_dt BETWEEN ci.start_dt AND ci.end_dt) OR
		   (ci2.start_dt <=  ci.start_dt AND ci2.end_dt >= ci.end_dt)
  	          );

        -- 3. Select load calendars which have subordinates of any type
        CURSOR c_cir (
                        cp_cal_type             IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sequence_number      IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  cir.sub_cal_type
                FROM    IGS_CA_INST_REL cir
                WHERE   cir.sup_cal_type = cp_cal_type AND
                        cir.sup_ci_sequence_number = cp_sequence_number;
        -- 4. Check that the load calendar is not linked to
        -- other academic calendar instances.
        CURSOR c_cir2 (
                        cp_cal_type             IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sequence_number      IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  cir.sub_cal_type
                FROM    IGS_CA_INST_REL cir,
                        IGS_CA_TYPE                     cat
                WHERE   cir.sub_cal_type = cp_cal_type AND
                        cir.sub_ci_sequence_number = cp_sequence_number AND
                        (cir.sup_cal_type <> p_acad_cal_type OR
                        cir.sup_ci_sequence_number <> p_acad_sequence_number) AND
                        cat.CAL_TYPE = cir.sup_cal_type AND
                        cat.S_CAL_CAT = 'ACADEMIC';
        -- 5. Check that one and only one 'load effect date' alias
        -- instance exists within the calendar instance.
        CURSOR c_secc_dai (
                        cp_cal_type             IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sequence_number      IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  count(*)
                FROM    IGS_EN_CAL_CONF         secc,
                        IGS_CA_DA_INST  dai
                WHERE   secc.s_control_num = 1 AND
                        dai.CAL_TYPE = cp_cal_type AND
                        dai.ci_sequence_number = cp_sequence_number AND
                        dai.DT_ALIAS = secc.load_effect_dt_alias;
        -- 6. Checks related to default load apportion entries
        CURSOR c_dla (
                        cp_cal_type             IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_sequence_number      IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  dla.teach_cal_type,
                        dla.second_percentage
                FROM    IGS_ST_DFT_LOAD_APPO    dla
                WHERE   dla.CAL_TYPE = cp_cal_type AND
                        dla.ci_sequence_number = cp_sequence_number;
        -- 7. Validate that teaching period is linked to the same academic period.
        CURSOR c_ci_cs (
                        cp_teach_cal_type       IGS_ST_DFT_LOAD_APPO.teach_cal_type%TYPE) IS
                SELECT  count(*)
                FROM    IGS_CA_INST     ci,
                        IGS_CA_STAT     cs
                WHERE   CAL_TYPE = cp_teach_cal_type AND
                        cs.s_cal_status IN ('ACTIVE','PLANNED') AND
                        ci.CAL_STATUS = cs.CAL_STATUS AND
                        IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                                        p_acad_cal_type,
                                        p_acad_sequence_number,
                                        ci.CAL_TYPE,
                                        ci.sequence_number,
                                        'N') = 'Y';
        -- 8. Validate that attendance type load records exist for all load calendars
        CURSOR c_att IS
                SELECT  att.ATTENDANCE_TYPE
                FROM    IGS_EN_ATD_TYPE att
                WHERE   att.closed_ind = 'N' AND
                        ((att.lower_enr_load_range IS NOT NULL AND
                        att.lower_enr_load_range <> 0) OR
                        (att.upper_enr_load_range IS NOT NULL AND
                        att.upper_enr_load_range <> 0));
        CURSOR c_atl (
                        cp_attendance_type      IGS_EN_ATD_TYPE.ATTENDANCE_TYPE%TYPE,
                        cp_cal_type             IGS_CA_INST.CAL_TYPE%TYPE) IS
                SELECT  atl.CAL_TYPE                    -- not used
                FROM    IGS_EN_ATD_TYPE_LOAD    atl
                WHERE   atl.ATTENDANCE_TYPE = cp_attendance_type AND
                        atl.CAL_TYPE = cp_cal_type;
        -- 9. Validate that the attendance type load records for all
        -- attendance types cover the entire range of EFTSU. (ie. there are no gaps)
        CURSOR c_atl_att (
                        cp_cal_type             IGS_CA_INST.CAL_TYPE%TYPE) IS
                SELECT  atl.lower_enr_load_range,
                        atl.upper_enr_load_range
                FROM    IGS_EN_ATD_TYPE_LOAD    atl,
                        IGS_EN_ATD_TYPE         att
                WHERE   atl.CAL_TYPE = cp_cal_type AND
                        att.closed_ind = 'N' AND
                        att.ATTENDANCE_TYPE = atl.ATTENDANCE_TYPE
                ORDER BY att.lower_enr_load_range;

        -- Cursor to Check that award calendar should have
	-- at least one direct subordinate Load calendar instance

        CURSOR  c_cir_6 ( cp_c_sub_cal_type        igs_ca_inst.cal_type%TYPE,
                          cp_n_sub_sequence_number igs_ca_inst.sequence_number%TYPE
                        ) IS
        SELECT  cir6.sup_cal_type,
                cir6.sup_ci_sequence_number
        FROM    igs_ca_inst_rel cir6,
                igs_ca_type cat
        WHERE   cir6.sub_cal_type               = cp_c_sub_cal_type
	AND     cir6.sub_ci_sequence_number     = cp_n_sub_sequence_number
	AND     cat.S_CAL_CAT                   = 'AWARD'
	AND     cir6.sup_cal_type               = cat.cal_type;

	rec_c_cir_6 c_cir_6%ROWTYPE;

        CURSOR  c_cir_9 ( cp_c_sub_cal_type        igs_ca_inst.cal_type%TYPE,
                          cp_n_sub_sequence_number igs_ca_inst.sequence_number%TYPE
                        ) IS
        SELECT  cir9.sup_cal_type,
                cir9.sup_ci_sequence_number
        FROM    igs_ca_inst_rel cir9,
                igs_ca_type cat
        WHERE   cir9.sub_cal_type               = cp_c_sub_cal_type
	AND     cir9.sub_ci_sequence_number     = cp_n_sub_sequence_number
	AND     cat.S_CAL_CAT                   = 'ADMISSION'
	AND     cir9.sup_cal_type               = cat.cal_type;

	rec_c_cir_9 c_cir_9%ROWTYPE;
	l_overlap c_chk_overlap%ROWTYPE;

  BEGIN
        -- Quality check of calendar data structures related to Load Calendars.
        -- Checks Include:
        -- 1. Must always be linked to a single academic calendar instance
        -- 2. Bug #2279265 : Modified the comment
        --    Should only be a subordinate to academic, Fee and Progress calendars
        -- 3. Has no logical subordinate calendar categories
        -- 4. Must have one load effect date alias instance
        -- 5. Default load apportion should only link to teaching period
        --    calendar types which are offered in the related academic calendar
        -- 6. Attendance Type Load structure should exist for all derivable
        --    attendance types covering the total applicable load
        -----------------------------------------------------------
        -- Select load calendars which have superior relationships
        -- to parents other than academic, fee ,progress, award and Admission
        FOR v_ci_cat_cs_rec IN c_ci_cat_cs LOOP
                FOR v_cir_ci_cat_rec IN c_cir_ci_cat(
                                                        v_ci_cat_cs_rec.CAL_TYPE,
                                                        v_ci_cat_cs_rec.sequence_number) LOOP
                        IF (v_cir_ci_cat_rec.S_CAL_CAT NOT IN ('ACADEMIC','FEE','PROGRESS','ADMISSION','AWARD')) THEN
                                -- Raise Warning
                                v_key :=        'LOAD,' ||
                                                v_ci_cat_cs_rec.CAL_TYPE || ',' ||
                                                v_ci_cat_cs_rec.sequence_number;
                --- added by syam
                  fnd_Message.Set_Name('IGS','IGS_CA_LODCAL_ONLY_ACADMCAL');
                  fnd_message.set_token('TOKEN1',v_cir_ci_cat_rec.S_CAL_CAT);
                  v_warning_msg := fnd_message.get;
                --- added by syam


                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                v_key,
                                                NULL,
                                                v_warning_msg);
                                EXIT;
                        END IF;
                END LOOP;
        END LOOP;
        -- Loop through all load calendars in the specified academic year and
        -- check for valid links.
        FOR v_load_calendars IN c_load_calendars LOOP

	        -- Check one per cal for SDAs.
         CHK_ONE_PER_CAL(v_load_calendars.cal_type,       -- will check for load cal instance.
	                 v_load_calendars.sequence_number,
			 'LOAD',
			 p_s_log_type,
			 p_log_creation_dt);

	-- Check if the load calender overlaps with another one in the system. Check if there are any overlapping calenders, if yes, run a loop and record all of them in the LOG table.

       l_overlap.alternate_code := null;

       FOR l_overlap IN c_chk_overlap(v_load_calendars.cal_type,v_load_calendars.sequence_number)
       LOOP

	 v_key := 'LOAD,' || v_load_calendars.CAL_TYPE || ',' || v_load_calendars.sequence_number || ',' || l_overlap.alternate_code ;  -- key for the log table.

	 fnd_Message.Set_Name('IGS','IGS_CA_OVERLAP_LOAD_CAL');  -- new message for this check.
	 fnd_message.set_token('TOKEN1',l_overlap.alternate_code);
	 fnd_message.set_token('TOKEN2',l_overlap.description);
	 fnd_message.set_token('TOKEN3',l_overlap.start_dt);
	 fnd_message.set_token('TOKEN4',l_overlap.end_dt);
	 v_warning_msg := fnd_message.get;

	 IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(p_s_log_type,
                                	   p_log_creation_dt,
 	                                   v_key,
 	                                   NULL,
 	                                   v_warning_msg);
       END LOOP;

       IF (c_chk_overlap%ISOPEN)
       THEN
         CLOSE c_chk_overlap;
       END IF;

            -- Check that the load calendar is not linked to another other
                -- academic calendar instances.
                OPEN c_cir(
                        v_load_calendars.CAL_TYPE,
                        v_load_calendars.sequence_number);
                FETCH c_cir INTO v_sub_cal_type;
                IF (c_cir%FOUND) THEN
                        -- Raise warning
                        v_key :=        'LOAD,' ||
                                        v_load_calendars.CAL_TYPE || ',' ||
                                        v_load_calendars.sequence_number;


                        --- added by syam
                                          fnd_Message.Set_Name('IGS','IGS_CA_LODCAL_NO_SUBORCAL');
                                          fnd_message.set_token('TOKEN1',v_sub_cal_type);
                                          v_warning_msg := fnd_message.get;
                        --- added by syam


                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        p_s_log_type,
                                        p_log_creation_dt,
                                        v_key,
                                        NULL,
                                        v_warning_msg);
                END IF;
                CLOSE c_cir;
                -- Check that the load calendar is not linked to
                -- other academic calendar instance.
                OPEN c_cir2(
                        v_load_calendars.CAL_TYPE,
                        v_load_calendars.sequence_number);
                FETCH c_cir2 INTO v_sub_cal_type;
                IF (c_cir2%FOUND) THEN
                        -- Raise warning
                        v_key :=        'LOAD,' ||
                                        v_load_calendars.CAL_TYPE || ',' ||
                                        v_load_calendars.sequence_number;

                        --- added by syam
                                  fnd_Message.Set_Name('IGS','IGS_CA_LODCAL_SUB_TO_1_CALINS');
                                  v_warning_msg := fnd_message.get;
                        --- added by syam

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        p_s_log_type,
                                        p_log_creation_dt,
                                        v_key,
                                        NULL,
                                        v_warning_msg);

                END IF;
                CLOSE c_cir2;

               /**This section covers validating the mandatory relation between admission, award , fee  and Academic Term (Load) period **/

               --Check that all Academic Term (Load) period have at least one
               --superior award periods
               OPEN c_cir_6 ( cp_c_sub_cal_type        => v_load_calendars.cal_type,
                              cp_n_sub_sequence_number => v_load_calendars.sequence_number
	                    );
	       FETCH c_cir_6 INTO rec_c_cir_6;
	       IF c_cir_6%NOTFOUND THEN
		  FND_MESSAGE.SET_NAME('IGS','IGS_CA_LOAD_HAVE_1_AWDCAL');
                  igs_ge_gen_003.genp_ins_log_entry( p_s_log_type,
                                                     p_log_creation_dt,
                                                     'LOAD,'|| v_load_calendars.cal_type ||',' ||v_load_calendars.sequence_number,
                                                     NULL,
                                                     fnd_message.get
						    );
		END IF;
		CLOSE c_cir_6;

               --Check that all Academic Term (Load) period have at least one
               --superior admission periods
               OPEN c_cir_9 ( cp_c_sub_cal_type        => v_load_calendars.cal_type,
                              cp_n_sub_sequence_number => v_load_calendars.sequence_number
	                    );
	       FETCH c_cir_9 INTO rec_c_cir_9;
	       IF c_cir_9%NOTFOUND THEN
		  FND_MESSAGE.SET_NAME('IGS','IGS_CA_LOAD_HAVE_1_ADMCAL');
                  igs_ge_gen_003.genp_ins_log_entry( p_s_log_type,
                                                     p_log_creation_dt,
                                                     'LOAD,'|| v_load_calendars.cal_type ||',' ||v_load_calendars.sequence_number,
                                                     NULL,
                                                     fnd_message.get
						    );
		END IF;
		CLOSE c_cir_9;

	       /**End of this section **/

                -- Check that one and only one load effect date alias
                -- instance exists within the calendar instance
                OPEN c_secc_dai(
                                v_load_calendars.CAL_TYPE,
                                v_load_calendars.sequence_number);
                FETCH c_secc_dai INTO v_count;
                CLOSE c_secc_dai;
                IF (v_count <> 1) THEN
                        -- Raise warning
                        v_key :=        'LOAD,' ||
                                        v_load_calendars.CAL_TYPE || ',' ||
                                        v_load_calendars.sequence_number;

                        --- added by syam
                          fnd_Message.Set_Name('IGS','IGS_CA_LDCLINS_1_EFFDTALIAS');
                          v_warning_msg := fnd_message.get;
                        --- added by syam

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        p_s_log_type,
                                        p_log_creation_dt,
                                        v_key,
                                        NULL,
                                        v_warning_msg);
                END IF;
                -- Checks related to default load apportion entries
                FOR v_dla_rec IN c_dla(
                                        v_load_calendars.CAL_TYPE,
                                        v_load_calendars.sequence_number) LOOP
                        -- Validate that teaching period is linked to the same academic period.
                        OPEN c_ci_cs(v_dla_rec.teach_cal_type);
                        FETCH c_ci_cs INTO v_count;
                        CLOSE c_ci_cs;
                        IF (v_count = 0) THEN
                                -- Raise warning
                                v_key :=        'LOAD,' ||
                                                v_load_calendars.CAL_TYPE || ',' ||
                                                v_load_calendars.sequence_number;


                        --- added by syam
                          fnd_Message.Set_Name('IGS','IGS_CA_CALTYPE_NO_INSACAD');
                          fnd_message.set_token('TOKEN1',v_dla_rec.teach_cal_type);
                          v_warning_msg := fnd_message.get;
                        --- added by syam

                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                v_key,
                                                NULL,
                                                v_warning_msg);


                        END IF;
                        -- If the second percentage is set, check
                        -- that there is need for it
                        IF (v_dla_rec.second_percentage IS NOT NULL AND
                                        v_count = 1) THEN
                                -- Raise warning
                                v_key :=        'LOAD,' ||
                                                v_load_calendars.CAL_TYPE || ',' ||
                                                v_load_calendars.sequence_number;


                        --- added by syam
                          fnd_Message.Set_Name('IGS','IGS_CA_TEACHCAL_1_INSACAD');
                          fnd_message.set_token('TOKEN1',v_dla_rec.teach_cal_type);
                          v_warning_msg := fnd_message.get;
                        --- added by syam

                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                v_key,
                                                NULL,
                                                v_warning_msg);
                        END IF;
                END LOOP; -- (dlft_load_apportion)
                -- Validate that the attendance type load records exist
                -- for all load calendars
                FOR v_att_rec IN c_att LOOP
                        OPEN c_atl(
                                v_att_rec.ATTENDANCE_TYPE,
                                v_load_calendars.CAL_TYPE);
                        FETCH c_atl INTO v_cal_type;
                        IF (c_atl%NOTFOUND) THEN
                                -- Raise warning
                                v_key :=        'LOAD,' ||
                                                v_load_calendars.CAL_TYPE || ',' ||
                                                v_load_calendars.sequence_number;

                        --- added by syam
                          fnd_Message.Set_Name('IGS','IGS_CA_ATTYPE_NO_LODDTL');
                          fnd_message.set_token('TOKEN1',v_att_rec.ATTENDANCE_TYPE);
                          v_warning_msg := fnd_message.get;
                        --- added by syam

                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                v_key,
                                                NULL,
                                                v_warning_msg);
                        END IF;
                        CLOSE c_atl;
                END LOOP;
                -- Validate that the attendance type load records for all
                -- attendance types cover the entire of EFTSU.
                -- ie. There are no gaps
                v_last_upper := 0.00;
                FOR v_atl_att_rec IN c_atl_att(v_load_calendars.CAL_TYPE) LOOP
                        IF ((v_atl_att_rec.lower_enr_load_range - v_last_upper) > .001) THEN
                                -- Raise warning
                                v_key :=        'LOAD,' ||
                                                v_load_calendars.CAL_TYPE || ',' ||
                                                v_load_calendars.sequence_number;


                                --- added by syam
                                                  fnd_Message.Set_Name('IGS','IGS_CA_GAP_BW_ATTYPE_LODRNGES');
                                                  v_warning_msg := fnd_message.get;
                                --- added by syam


                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                v_key,
                                                NULL,
                                                v_warning_msg);

                                -- exit the v_atl_att_rec loop because we only want to
                                -- insert the one record, even if more gaps exists.
                                EXIT;
                        END IF;
                        v_last_upper := v_atl_att_rec.upper_enr_load_range;
                END LOOP; -- (IGS_EN_ATD_TYPE_LOAD)
        END LOOP; -- (IGS_CA_INST)
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGA_CA_VAL_QLITY.calp_val_load_ci');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values:= p_acad_cal_type ||','||(to_char(p_acad_sequence_number))||','||p_s_log_type||','||(to_char(p_log_creation_dt));
                 Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                 FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
                 IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END calp_val_load_ci;
  --
  -- To quality check teaching calendar instances
  PROCEDURE CALP_VAL_TEACH_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
  AS
  ------------------------------------------------------------------
  --Change History:
  --Who            When            What
  --smadathi    16-sep-2002        Bug 2086177. Included Fetching of Planned calendars
  --                               along with the Active ones
  ------------------------------------------------------------------
        lv_param_values         VARCHAR2(1080);
        gv_other_detail         VARCHAR2(255);
  BEGIN -- The checks include:
        -- 1.  Must always be linked to at least one academic calendar
        -- 2.  Should only have superiors of Academic or Fee calendars.
        -- 3.  Should not have any subordinate calendars other than ADMISSION,
        --     and should be linked to at least ONE admission calendar.
        -- 4.  The total apportionment to load calendars must equal 100%
        -- 5.  Second percentage field is only required when linked to more
        --     than one instance of a load calendar type.
        -- 6.  Administrative IGS_PS_UNIT status load structure must be defined for
        --     all applicable load calendars for any administrative IGS_PS_UNIT
        --     statuses which can be used in the teaching period.
  DECLARE

        cst_academic            CONSTANT IGS_CA_TYPE.S_CAL_CAT%TYPE     := 'ACADEMIC';
        cst_fee                 CONSTANT IGS_CA_TYPE.S_CAL_CAT%TYPE     := 'FEE';
        cst_exam                CONSTANT IGS_CA_TYPE.S_CAL_CAT%TYPE     := 'EXAM';
        cst_assessment          CONSTANT IGS_CA_TYPE.S_CAL_CAT%TYPE     := 'ASSESSMENT';
        cst_teaching            CONSTANT IGS_CA_TYPE.S_CAL_CAT%TYPE     := 'TEACHING';
        cst_progress            CONSTANT igs_ca_type.s_cal_cat%TYPE := 'PROGRESS';
        cst_active              CONSTANT IGS_CA_STAT.s_cal_status%TYPE  := 'ACTIVE';
        cst_planned             CONSTANT IGS_CA_STAT.s_cal_status%TYPE  := 'PLANNED';
        cst_admission           CONSTANT IGS_CA_STAT.s_cal_status%TYPE  := 'ADMISSION';

        v_exists_flag   CHAR;
        v_dummy         VARCHAR2(10);
        v_message_name   VARCHAR2(30);
        v_total_percentage      IGS_ST_DFT_LOAD_APPO.percentage%TYPE;
        v_acad_cal_type         IGS_CA_INST.CAL_TYPE%TYPE;
        v_acad_sequence_number  IGS_CA_INST.sequence_number%TYPE;
        v_acad_start_dt         IGS_CA_INST.start_dt%TYPE;
        v_acad_end_dt           IGS_CA_INST.end_dt%TYPE;
        v_p_acad_start_dt       IGS_CA_INST.start_dt%TYPE;
        v_p_acad_end_dt         IGS_CA_INST.end_dt%TYPE;
        v_chk_tch_sub_cal_type  IGS_CA_INST_REL.sub_cal_type%TYPE;
        v_sub_not_admission     BOOLEAN := FALSE;
        v_chk_tch_sub_rec_found BOOLEAN := FALSE;
        CURSOR c_acad_dates (
                cp_acad_cal_type                IGS_CA_INST.CAL_TYPE%TYPE,
                cp_acad_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  start_dt,
                        end_dt
                FROM    IGS_CA_INST
                WHERE   CAL_TYPE = cp_acad_cal_type AND
                        sequence_number = cp_acad_sequence_number;
        CURSOR  c_chk_acad_fee_ci IS
                SELECT  cir.sub_cal_type, cir.sub_ci_sequence_number, ct1.S_CAL_CAT
                FROM    IGS_CA_INST ci,
                        IGS_CA_TYPE ct1,
                        IGS_CA_TYPE ct2,
                        IGS_CA_STAT cs,
                        IGS_CA_INST_REL cir
                WHERE   cs.s_cal_status IN (cst_active,cst_planned)    AND
                        ct2.S_CAL_CAT = cst_teaching                    AND
                        cs.CAL_STATUS = ci.CAL_STATUS                   AND
                        cir.sub_cal_type = ci.CAL_TYPE                  AND
                        cir.sub_ci_sequence_number = ci.sequence_number AND
                        cir.sup_cal_type = ct1.CAL_TYPE                 AND
                        ct2.CAL_TYPE = ci.CAL_TYPE                      AND
                        ct1.S_CAL_CAT NOT IN ( cst_academic )   AND
                        (IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(     p_acad_cal_type,
                                                p_acad_sequence_number,
                                                ci.CAL_TYPE,
                                                ci.sequence_number,
                                                'Y') = 'Y'  OR
                        NOT EXISTS (
                                    SELECT 'x'
                                    FROM    IGS_CA_INST_REL cir,
                                            IGS_CA_INST ci,
                                            IGS_CA_TYPE cat
                                    WHERE   cir.sub_cal_type                = ci.CAL_TYPE AND
                                            cir.sub_ci_sequence_number      = ci.sequence_number AND
                                            cir.sup_cal_type                = ci.CAL_TYPE  AND
                                            cir.sup_ci_sequence_number      = ci.sequence_number AND
                                            ci.CAL_TYPE                     = cat.CAL_TYPE AND
                                            cat.S_CAL_CAT                   = 'ACADEMIC' ));



        CURSOR c_chk_teach_ci IS
                SELECT  ci.CAL_TYPE,
                        ci.sequence_number,
                        cs.s_cal_status -- Bug:2697221 cal status selected to check whether
                                        -- the status is planned or active for calculating load apportionment
                FROM    IGS_CA_INST ci,
                        IGS_CA_TYPE ct,
                        IGS_CA_STAT cs
                WHERE   cs.s_cal_status IN (cst_active,cst_planned) AND
                        cs.CAL_STATUS   = ci.CAL_STATUS         AND
                        ct.S_CAL_CAT    = cst_teaching          AND
                        ct.CAL_TYPE     = ci.CAL_TYPE           AND
                        IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                                p_acad_cal_type,
                                p_acad_sequence_number,
                                ci.CAL_TYPE,
                                ci.sequence_number,
                                'Y' ) = 'Y';
        CURSOR c_chk_tch_sub (
                cp_cal_type             IGS_CA_INST_REL.sup_cal_type%TYPE,
                cp_sequence_number      IGS_CA_INST_REL.sup_ci_sequence_number%TYPE ) IS
                SELECT  cir.sub_cal_type,
                        cat2.S_CAL_CAT
                FROM    IGS_CA_INST_REL cir,
                        IGS_CA_TYPE cat1,
                        IGS_CA_TYPE cat2
                WHERE   cir.sup_cal_type                = cat1.CAL_TYPE         AND
                        cir.sub_cal_type                = cat2.CAL_TYPE         AND
                        cir.sup_cal_type                = cp_cal_type           AND
                        cir.sup_ci_sequence_number      = cp_sequence_number;
        CURSOR c_chk_census_dt (
                cp_cal_type             IGS_CA_DA_INST_V.CAL_TYPE%TYPE,
                cp_sequence_number      IGS_CA_DA_INST_V.sequence_number%TYPE,
                cp_acad_start_dt        DATE,
                cp_acad_end_dt          DATE ) IS
                SELECT  'x'
                FROM    dual
                WHERE   EXISTS (
                                SELECT  *
                                FROM    IGS_GE_S_GEN_CAL_CON sgcc,
                                        IGS_CA_DA_INST_V daiv
                                WHERE   sgcc.s_control_num = 1                          AND
                                        daiv.CAL_TYPE = cp_cal_type                     AND
                                        daiv.ci_sequence_number = cp_sequence_number    AND
                                        daiv.DT_ALIAS = sgcc.census_dt_alias    AND
                                        daiv.alias_val BETWEEN cp_acad_start_dt AND cp_acad_end_dt);
        CURSOR c_chk_acad_pct (
                cp_cal_type             IGS_CA_INST.CAL_TYPE%TYPE,
                cp_sequence_number      IGS_CA_INST.sequence_number%TYPE ) IS
                SELECT  ci.*
                FROM    IGS_CA_INST ci,
                        IGS_CA_TYPE ct,
                        IGS_CA_STAT cs
                WHERE   cs.s_cal_status IN (cst_active,cst_planned)   AND
                        ct.S_CAL_CAT    = cst_academic          AND
                        ci.CAL_TYPE     = ct.CAL_TYPE           AND
                        cs.CAL_STATUS   = ci.CAL_STATUS         AND
                        IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                                ci.CAL_TYPE,
                                ci.sequence_number,
                                cp_cal_type,
                                cp_sequence_number,
                                'Y' ) = 'Y';
        CURSOR c_chk_dla (
                cp_teach_cal_type               IGS_ST_DFT_LOAD_APPO.teach_cal_type%TYPE,
                cp_acad_cal_type                IGS_CA_INST.CAL_TYPE%TYPE,
                cp_acad_ci_sequence_number      IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  dla.*
                FROM    IGS_ST_DFT_LOAD_APPO dla
                WHERE   teach_cal_type = cp_teach_cal_type AND
                        IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                                cp_acad_cal_type,
                                cp_acad_ci_sequence_number,
                                dla.CAL_TYPE,
                                dla.ci_sequence_number,
                                'Y' ) = 'Y';
        CURSOR c_chk_tch_ci_aus IS
                SELECT  ci.CAL_TYPE,
                        ci.sequence_number
                FROM    IGS_CA_INST ci,
                        IGS_CA_TYPE ct,
                        IGS_CA_STAT cs
                WHERE   cs.s_cal_status IN (cst_active,cst_planned) AND
                        ci.CAL_STATUS   = cs.CAL_STATUS         AND
                        ct.S_CAL_CAT    = cst_teaching          AND
                        ct.CAL_TYPE     = ci.CAL_TYPE           AND
                        IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                                p_acad_cal_type,
                                p_acad_sequence_number,
                                ci.CAL_TYPE,
                                ci.sequence_number,
                                'Y') = 'Y';  --'N';  ssawhney. this should never be N.
        CURSOR c_chk_aus (
                cp_cal_type             IGS_CA_INST.CAL_TYPE%TYPE,
                cp_sequence_number      IGS_CA_INST.sequence_number%TYPE ) IS
                SELECT  DISTINCT ADMINISTRATIVE_UNIT_STATUS
                FROM    IGS_CA_DA_INST_V daiv,
                        IGS_PS_UNIT_DISC_CRT uddc
                WHERE   daiv.CAL_TYPE           = cp_cal_type                   AND
                        ci_sequence_number      = cp_sequence_number            AND
                        daiv.DT_ALIAS           = uddc.unit_discont_dt_alias    AND
                        uddc.delete_ind         = 'N';
        CURSOR c_chk_load_ci (
                cp_cal_type             IGS_CA_INST.CAL_TYPE%TYPE ) IS
                SELECT  ci.CAL_TYPE,
                        ci.sequence_number
                FROM    IGS_ST_DFT_LOAD_APPO dla,
                        IGS_CA_INST ci
                WHERE   teach_cal_type          = cp_cal_type                   AND
                        ci.CAL_TYPE             = dla.CAL_TYPE                  AND
                        ci.sequence_number      = dla.ci_sequence_number        AND
                        IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                                p_acad_cal_type,
                                p_acad_sequence_number,
                                ci.CAL_TYPE,
                                ci.sequence_number,
                                'N') = 'Y';
        CURSOR c_chk_ausl (
                cp_uddc_aus                     IGS_PS_UNIT_DISC_CRT.ADMINISTRATIVE_UNIT_STATUS%TYPE,
                cp_load_ci_cal_type             IGS_CA_INST.CAL_TYPE%TYPE,
                cp_load_ci_sequence_number      IGS_CA_INST.sequence_number%TYPE,
                cp_teach_ci_cal_type            IGS_CA_INST.CAL_TYPE%TYPE ) IS
                SELECT  'x'
                FROM    dual
                WHERE   EXISTS (
                        SELECT  *
                        FROM    IGS_AD_ADM_UT_STT_LD
                        WHERE   ADMINISTRATIVE_UNIT_STATUS      = cp_uddc_aus           AND
                                CAL_TYPE                        = cp_load_ci_cal_type   AND
                                ci_sequence_number              = cp_load_ci_sequence_number    AND
                                teach_cal_type                  = cp_teach_ci_cal_type);
  BEGIN
        -- Select parameter calendar start date/end date into variables for later use.
        OPEN c_acad_dates (
                        p_acad_cal_type,
                        p_acad_sequence_number);
        FETCH c_acad_dates INTO v_p_acad_start_dt,
                                v_p_acad_end_dt;
        IF c_acad_dates%NOTFOUND THEN
                CLOSE c_acad_dates;
                RETURN;
        END IF;
        CLOSE c_acad_dates;
        -- Check for teaching calendar instances which have superior calendars of a
        --  category other than ACADEMIC or FEE.
        --  Only consider calendars which are children of the academic calendar
        --  parameter  or which don't have any superior academic calendar.
        --  Bug 2384110, Progression Calendar is a mandatory superior calendar for the Teaching Calendar
        FOR v_chk_acad_fee_ci_rec IN c_chk_acad_fee_ci LOOP
                IF v_chk_acad_fee_ci_rec.s_cal_cat NOT IN (cst_academic, cst_exam,
                                                 cst_assessment, cst_progress) THEN

                --- added by syam
                          fnd_Message.set_name('IGS','IGS_CA_TEACHCAL_SUP_ACEXASCAL');
                          fnd_message.set_token('TOKEN1',v_chk_acad_fee_ci_rec.s_cal_cat);
                --- added by syam


                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                'TEACHING,' || v_chk_acad_fee_ci_rec.sub_cal_type || ',' ||
                                                TO_CHAR(v_chk_acad_fee_ci_rec.sub_ci_sequence_number),
                                                NULL,
                                                fnd_message.get);

                END IF;

        -- Check one per cal for SDAs.
         CHK_ONE_PER_CAL(v_chk_acad_fee_ci_rec.sub_cal_type,       -- will check for fee cal instance.
	                 v_chk_acad_fee_ci_rec.sub_ci_sequence_number,
			 'TEACHING',
			 p_s_log_type,
			 p_log_creation_dt);

        END LOOP;
        --- Loop through all teaching calendar instances related to the academic period
        FOR v_chk_teach_ci_rec IN c_chk_teach_ci LOOP

		-- Check one per cal for SDAs.
		 CHK_ONE_PER_CAL(v_chk_teach_ci_rec.CAL_TYPE,       -- will check for teach cal instance.
				 v_chk_teach_ci_rec.sequence_number,
				 'TEACHING',
				 p_s_log_type,
				 p_log_creation_dt);

		-- Select teaching calendars which have subordinates of any type
                FOR v_chk_tch_sub_rec IN c_chk_tch_sub(
                                                v_chk_teach_ci_rec.CAL_TYPE,
                                                v_chk_teach_ci_rec.sequence_number ) LOOP
                        v_chk_tch_sub_rec_found := TRUE;
                        v_chk_tch_sub_cal_type := v_chk_tch_sub_rec.sub_cal_type;
                        IF v_chk_tch_sub_rec.S_CAL_CAT <> cst_admission THEN
                                v_sub_not_admission := TRUE;
                                EXIT;
                        END IF;
                END LOOP; -- c_chk_tch_sub
                IF v_sub_not_admission = TRUE THEN

                --- added by syam
                          fnd_Message.Set_Name('IGS','IGS_CA_TEACHCAL_SUB_ADMCAL');
                          fnd_message.set_token('TOKEN1',v_chk_tch_sub_cal_type);
                --- added by syam

                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                'TEACHING,' || v_chk_teach_ci_rec.CAL_TYPE || ',' ||
                                                TO_CHAR(v_chk_teach_ci_rec.sequence_number),
                                                NULL,
                                                fnd_message.get);

                END IF;
                IF v_chk_tch_sub_rec_found = FALSE THEN

                        fnd_message.set_name('IGS','IGS_CA_TEACHCAL_HAVE_1_ADM');
			fnd_message.set_token('CAL_TYPE',v_chk_tch_sub_cal_type);

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                p_s_log_type,
                                p_log_creation_dt,
                                'TEACHING,' || v_chk_teach_ci_rec.CAL_TYPE || ',' ||
                                TO_CHAR(v_chk_teach_ci_rec.sequence_number),
                                NULL,
                                fnd_message.get);
                END IF;
                v_total_percentage := 0;
                --- Check that the calendar instance has at least 1 census date.
                OPEN c_chk_census_dt(
                                v_chk_teach_ci_rec.CAL_TYPE,
                                v_chk_teach_ci_rec.sequence_number,
                                v_p_acad_start_dt,
                                v_p_acad_end_dt );
                FETCH c_chk_census_dt INTO v_exists_flag;
                IF c_chk_census_dt%NOTFOUND THEN

                --- added by syam
                          fnd_Message.Set_Name('IGS','IGS_CA_TEACHCAL_1_CENSUSALIAS');
                --- added by syam


                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                'TEACHING,' || v_chk_teach_ci_rec.CAL_TYPE || ',' ||
                                                TO_CHAR(v_chk_teach_ci_rec.sequence_number),
                                                NULL,
                                                fnd_message.get);

                END IF;
                CLOSE c_chk_census_dt;
                --- Loop through all apportionments that the teaching period has to load
                --- calendars and sum the percentages; they must equal 100.
                IF v_chk_teach_ci_rec.s_cal_status = cst_active THEN -- Bug:2697221 check added to avoid
                                                                     -- calculating load apportionment for planned calendar
                  FOR v_chk_acad_pct_rec IN c_chk_acad_pct(
                                 v_chk_teach_ci_rec.CAL_TYPE,
                                 v_chk_teach_ci_rec.sequence_number ) LOOP

		 CHK_ONE_PER_CAL(v_chk_acad_pct_rec.cal_type,       -- will check for apportionments that the teaching period has to "acad"
				 v_chk_acad_pct_rec.sequence_number,
				 'TEACHING',
				 p_s_log_type,
				 p_log_creation_dt);

                        FOR v_chk_dla_rec IN c_chk_dla(
                                        v_chk_teach_ci_rec.CAL_TYPE,
                                        v_chk_acad_pct_rec.CAL_TYPE,
                                        v_chk_acad_pct_rec.sequence_number) LOOP
                                -- Total the percentages from all load calendars instances within academic
                                --  years to which the teaching period is related.
                                -- Select all of the load calendars within the academic year that match
                                -- the default load apportionment record.
                                IF IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                                        v_chk_acad_pct_rec.CAL_TYPE,
                                        v_chk_acad_pct_rec.sequence_number,
                                        v_chk_dla_rec.CAL_TYPE,
                                        v_chk_dla_rec.ci_sequence_number,
                                        'N' ) = 'Y' THEN
                                        IF v_chk_dla_rec.second_percentage IS NOT NULL THEN
                                                        v_dummy := IGS_EN_GEN_002.ENRP_GET_ACAD_ALT_CD(
                                                                v_chk_teach_ci_rec.CAL_TYPE,
                                                                v_chk_teach_ci_rec.sequence_number,
                                                                v_acad_cal_type,
                                                                v_acad_sequence_number,
                                                                v_acad_start_dt,
                                                                v_acad_end_dt,
                                                                v_message_name);
                                                IF v_acad_cal_type <> v_chk_acad_pct_rec.CAL_TYPE OR
                                                        v_acad_sequence_number <> v_chk_acad_pct_rec.sequence_number THEN
                                                        v_total_percentage := v_total_percentage +
                                                                         v_chk_dla_rec.second_percentage;
                                                ELSE
                                                        v_total_percentage := v_total_percentage + v_chk_dla_rec.percentage;
                                                END IF;
                                        ELSE
                                                v_total_percentage := v_total_percentage + v_chk_dla_rec.percentage;
                                        END IF;
                                END IF; -- IGS_EN_GEN_014.ENRS_GET_WITHIN_CI
                        END LOOP; --- c_chk_dla
                  END LOOP; --- c_chk_acad_pct
                  IF v_total_percentage <> 100 THEN

                  --- added by syam
                          fnd_Message.Set_Name('IGS','IGS_CA_TOTLODAPPORTION_NOT_100');
                  --- added by syam
                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type,
                                                p_log_creation_dt,
                                                'TEACHING,' || v_chk_teach_ci_rec.CAL_TYPE || ',' ||
                                                TO_CHAR(v_chk_teach_ci_rec.sequence_number),
                                                NULL,
                                                fnd_message.get);

                  END IF;
                END IF; ---- Bug:2697221 end of check added to avoid calculating load apportionment for planned calendar
        END LOOP; -- c_chk_teach_ci
        -- Validate that the administrative IGS_PS_UNIT statuses are correctly linked to all
        -- appropriate load calendar instances.
        FOR v_chk_tch_ci_aus_rec IN c_chk_tch_ci_aus LOOP

		--SIMRAN get all teaching period under the passed acad cal.
                --- Select the administrative IGS_PS_UNIT statuses for all date aliases within the
                --- teaching calendar which are discontinuation date criteria aliases.
                FOR v_chk_aus_rec IN c_chk_aus(
                                                v_chk_tch_ci_aus_rec.CAL_TYPE,
                                                v_chk_tch_ci_aus_rec.sequence_number ) LOOP
                        --- Select all load calendars to which the teaching calendar is linked
                        --- within the parameter academic period.
                        --  SIMRAN Change this to use TEACH_TO_LOAD_V
			FOR v_chk_load_ci_rec IN c_chk_load_ci(
                                                v_chk_tch_ci_aus_rec.CAL_TYPE ) LOOP
                                OPEN c_chk_ausl(
                                        v_chk_aus_rec.ADMINISTRATIVE_UNIT_STATUS,
                                        v_chk_load_ci_rec.CAL_TYPE,
                                        v_chk_load_ci_rec.sequence_number,
                                        v_chk_tch_ci_aus_rec.CAL_TYPE );
                                FETCH c_chk_ausl INTO v_exists_flag;
                                IF c_chk_ausl%NOTFOUND THEN

                                --- added by syam
                                  fnd_Message.Set_Name('IGS','IGS_CA_ADMIN_STATUS_LNK_LODCAL');
                                  fnd_message.set_token('TOKEN1',v_chk_aus_rec.ADMINISTRATIVE_UNIT_STATUS);
                                --- added by syam


                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                 p_s_log_type,
                                                 p_log_creation_dt,
                                                'TEACHING,' || v_chk_tch_ci_aus_rec.CAL_TYPE || ',' ||
                                                 TO_CHAR(v_chk_tch_ci_aus_rec.sequence_number),
                                                 NULL,
                                                 fnd_message.get);


                                END IF;
                                CLOSE c_chk_ausl;
                        END LOOP; -- c_chk_load_ci
                END LOOP; -- c_chk_aus
        END LOOP; -- c_chk_tch_ci_aus
  EXCEPTION
        WHEN OTHERS THEN
                IF c_acad_dates%ISOPEN THEN
                        CLOSE c_acad_dates;
                END IF;
                IF c_chk_acad_fee_ci%ISOPEN THEN
                        CLOSE c_chk_acad_fee_ci;
                END IF;
                IF c_chk_teach_ci%ISOPEN THEN
                        CLOSE c_chk_teach_ci;
                END IF;
                IF c_chk_tch_sub%ISOPEN THEN
                        CLOSE c_chk_tch_sub;
                END IF;
                IF c_chk_census_dt%ISOPEN THEN
                        CLOSE c_chk_census_dt;
                END IF;
                IF c_chk_acad_pct%ISOPEN THEN
                        CLOSE c_chk_acad_pct;
                END IF;
                IF c_chk_dla%ISOPEN THEN
                        CLOSE c_chk_dla;
                END IF;
                IF c_chk_tch_ci_aus%ISOPEN THEN
                        CLOSE c_chk_tch_ci_aus;
                END IF;
                IF c_chk_aus%ISOPEN THEN
                        CLOSE c_chk_aus;
                END IF;
                IF c_chk_load_ci%ISOPEN THEN
                        CLOSE c_chk_load_ci;
                END IF;
                IF c_chk_ausl%ISOPEN THEN
                        CLOSE c_chk_ausl;
                END IF;
                App_Exception.Raise_Exception;
  END;
  EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_QLITY.calp_val_teach_ci');
                IGS_GE_MSG_STACK.ADD;
                lv_param_values:= p_acad_cal_type||','||(to_char(p_acad_sequence_number))||','||p_s_log_type||','||(to_char(p_log_creation_dt));
                 Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
                 FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
                 IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END calp_val_teach_ci;

  PROCEDURE calp_val_award_ci( p_c_acad_cal_type        IN igs_ca_inst_all.cal_type%TYPE,
                               p_n_acad_sequence_number IN igs_ca_inst_all.sequence_number%TYPE,
                               p_c_s_log_type           IN VARCHAR2 ,
                               p_d_log_creation_dt      IN DATE
		             ) IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 17 Sep 2002
  --
  --Purpose: This procedure is private to this package body .
  --         The Award calendars selected should be ones that overlap with
  --         the Academic Calendar selected in the CM parameters.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR  c_ca_inst_acad   IS
  SELECT  ci.cal_type,
          ci.sequence_number,
	  ci.start_dt,
	  ci.end_dt
  FROM    igs_ca_inst     ci
  WHERE   ci.cal_type     = p_c_acad_cal_type
  AND     ci.sequence_number = p_n_acad_sequence_number;

  rec_c_ca_inst_acad c_ca_inst_acad%ROWTYPE;

  CURSOR  c_ca_inst_awd (p_d_start_dt igs_ca_inst.start_dt%TYPE,
                         p_d_end_dt   igs_ca_inst.end_dt%TYPE
			) IS
  SELECT  ci.cal_type,
          ci.sequence_number
  FROM    igs_ca_inst     ci,
          igs_ca_stat     cs,
          igs_ca_type     cat
  WHERE   cat.s_cal_cat   = 'AWARD'
  AND     cs.s_cal_status IN ('ACTIVE','PLANNED')
  AND     ci.cal_type     = cat.cal_type
  AND     ci.cal_status   = cs.cal_status
  AND     (TRUNC(ci.start_dt) >= TRUNC(p_d_start_dt)  OR
           TRUNC(ci.end_dt) <= TRUNC(p_d_end_dt)) ;

  rec_c_ca_inst_awd c_ca_inst_awd%ROWTYPE;

  -- Cursor to Check that all Award periods have
  -- at least one direct subordinate Load calendar instance

  CURSOR  c_cir_8 ( cp_c_sup_cal_type        igs_ca_inst.cal_type%TYPE,
                    cp_n_sup_sequence_number igs_ca_inst.sequence_number%TYPE
                  ) IS
  SELECT  cir8.sub_cal_type,
          cir8.sub_ci_sequence_number
  FROM    igs_ca_inst_rel cir8,
          igs_ca_type cat
  WHERE   cir8.sup_cal_type               = cp_c_sup_cal_type
  AND     cir8.sup_ci_sequence_number     = cp_n_sup_sequence_number
  AND     cat.s_cal_cat                   = 'LOAD'
  AND     cir8.sub_cal_type               = cat.cal_type;

  rec_c_cir_8 c_cir_8%ROWTYPE;


  BEGIN
    FOR rec_c_ca_inst_acad IN c_ca_inst_acad
    LOOP
      FOR rec_c_ca_inst_awd IN c_ca_inst_awd (rec_c_ca_inst_acad.start_dt,
                                              rec_c_ca_inst_acad.end_dt
					     )
      LOOP

              -- Check one per cal for SDAs.
         CHK_ONE_PER_CAL(rec_c_ca_inst_awd.cal_type,       -- will check for fee cal instance.
	                 rec_c_ca_inst_awd.sequence_number,
			 'LOAD',
			 p_c_s_log_type,
			 p_d_log_creation_dt);

        --Check that all award periods have at least one
        --subordinate Academic Term (Load) period
        OPEN c_cir_8 ( cp_c_sup_cal_type        => rec_c_ca_inst_awd.cal_type,
                       cp_n_sup_sequence_number => rec_c_ca_inst_awd.sequence_number
	             );
	FETCH c_cir_8 INTO rec_c_cir_8;
	IF c_cir_8%NOTFOUND THEN
	   FND_MESSAGE.SET_NAME('IGS','IGS_CA_AWDCAL_HAVE_1_LOAD');
           igs_ge_gen_003.genp_ins_log_entry( p_c_s_log_type,
                                              p_d_log_creation_dt,
                                              'LOAD,'|| rec_c_ca_inst_awd.cal_type ||',' ||rec_c_ca_inst_awd.sequence_number,
                                              NULL,
                                              fnd_message.get
					     );
	END IF;
	CLOSE c_cir_8;
      END LOOP;
    END LOOP;

  END calp_val_award_ci;

END IGS_CA_VAL_QLITY;

/
