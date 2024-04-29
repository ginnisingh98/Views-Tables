--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_BULKRULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_BULKRULE" AS
/* $Header: IGSEN28B.pls 120.2 2006/05/02 23:54:29 ckasu noship $ */
/* smaddali modified all the procedures , added new parameters during
   nov 2001 build of enrollment processes dld , bug#1832130 */
--Added refernces to column ORG_UNIT_CD incall to IGS_EN_SU_ATTEMPT TBH call as a part of bug 1964697
  --
  -- To process bulk unit Rule checks for students with todo entries
  --added 3 new parameters for enrollment processes dld bug#1832130
--Who         When            What
--Aiyer     10-Oct-2001     Added the column grading schema in all Tbh calls of IGS_EN_SU_ATTEMPT_PKG as a part of the bug 2037897.
-- pradhakr  10-Dec-2001    Added the column deg_Aud_Detail_Id as part of Degree Audit Interface build.
--                          Bug# 2033208
-- svenkata   20-Dec-2001   Added columns student_career_transcript and Student_career_statistics as part of build Career
--                          Impact Part2 . Bug #2158626
-- svenkata   7-JAN-2002    Bug No. 2172405  Standard Flex Field columns have been added
--                          to table handler procedure calls as part of CCR - ENCR022.
--Nishikant  29-jan-2002     Added the column session_id  in the Tbh calls of IGS_EN_SU_ATTEMPT_PKG
--                           as a part of the bug 2172380.
--mesriniv    12-sep-2002     Added a new parameter waitlist_manual_ind in TBH call of IGS_EN_SU_ATTEMPT
--                            for  Bug 2554109 MINI Waitlist Build for Jan 03 Release
--svenkata   20-NOV-2002   Modified the call to the function igs_en_val_sua.enrp_val_sua_advstnd to add value 'N' for the parameter
--                         p_legacy. Bug#2661533.
-- pradhakr  04-Dec-2002   Changed the parameter sequence in the procedure ENRP_VAL_SCA_RULTODO.
--                         As per standard the parameter errbuf and retcode are made as the
--                         first two paramters. Changes as per bug# 2683629
-- pradhakr  15-Dec-2002   Changed the call to the update_row of igs_en_su_attempt
--                         table to igs_en_sua_api.update_unit_attempt.
--                         Changes wrt ENCR031 build. Bug# 2643207
-- svenkata   3-Jun-2003   The function ENRP_VAL_COO_CROSS has been removed. All references to this API is removed. Bug# 2829272
--rvivekan    3-SEP-2003     Waitlist Enhacements build # 3052426. 2 new columns added to
--                           IGS_EN_SU_ATTEMPT_PKG procedures and consequently to IGS_EN_SUA_API procedures
--rvangala    07-OCT-2003    Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
--                           added as part of Prevent Dropping Core Units. Enh Bug# 3052432
--ptandon     25-Feb-2004    Modified procedure ENRP_VAL_SCA_RULTODO to log parameters in the log file of the
--                           job. Modified procedure enrpl_enrolled_to_invalid to rollback per unit attempt
--                           in case of exception and process the Subordinate unit attempts before Superior
--                           unit attempts. Modified procedure enrpl_invalid_to_enrolled to rollback per unit
--                           attempt in case of exception and process the Superior unit attempts before
--                           Subordinate unit attempts. Removed the exception handling block of enrp_val_sca_urule
--                           Bug# 3451409.
--svanukur    04-MAY-2004    Added the check to filter the programs based on the academic calendar type passed as
--                            parameter .
-- smaddali  15-oct-04      Modified for bug#3954071 - load calendar being passed to rules engine instead of teaching calendar
  --ckasu      02-May-2006     Modified as a part of bug#5191592

  PROCEDURE ENRP_VAL_SCA_RULTODO(
    errbuf OUT NOCOPY VARCHAR2 ,
    retcode OUT NOCOPY NUMBER ,
    p_acad_calander IN VARCHAR2,
    p_crs_cd IN VARCHAR2 ,
    p_org_id IN NUMBER,
    -- added new parameters for enrollment processes build bug#1832130
    p_load_teach_calendar IN VARCHAR2 ,
    p_org_unit_cd IN VARCHAR2  ,
    p_rule_to_be_validated IN VARCHAR2  )
  AS
    p_course_cd               igs_ps_course.course_cd%type;
    p_acad_cal_type             igs_ca_inst.cal_type%TYPE ;
    p_acad_sequence_number      igs_ca_inst.sequence_number%TYPE;
    --added for enrollment processes dld bug#1832130
    p_load_cal_type    igs_ca_inst.cal_type%TYPE ;
    p_load_sequence_number   igs_ca_inst.sequence_number%TYPE;
  BEGIN
    retcode:=0;

     IGS_GE_GEN_003.SET_ORG_ID(p_org_id);

    p_course_cd :=      nvl(p_crs_cd,'%');
    BEGIN
     IF p_acad_calander IS NOT NULL THEN
      p_acad_cal_type := RTRIM(SUBSTR(p_acad_calander,1,10));
      p_acad_sequence_number := (SUBSTR(p_acad_calander,75,10));
     ELSE
      p_acad_cal_type := '%';
     END IF;

      -- added for enrollment processes dld bug#1832130
      p_load_cal_type  := RTRIM(SUBSTR(p_load_teach_calendar,101,10));
      p_load_sequence_number  := SUBSTR(p_load_teach_calendar,111,10);
    END ;
    DECLARE
      CURSOR c_st IS
      SELECT    rowid,cst.*
      FROM      IGS_PE_STD_TODO cst
      WHERE     s_student_todo_type = 'UNIT-RULES' AND
                logical_delete_dt IS NULL AND
                NVL(todo_dt,TO_DATE('01/01/1980','DD/MM/YYYY')) <= SYSDATE
      ORDER BY person_id asc
      FOR UPDATE  NOWAIT;
      CURSOR c_sca (cp_person_id IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                cp_course_cd IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
      SELECT    course_cd
      FROM      IGS_EN_STDNT_PS_ATT
      WHERE     person_id = cp_person_id AND
                (course_cd = cp_course_cd OR
                 course_cd like cp_course_cd) AND
                (cal_type = p_acad_cal_type OR
                 cal_type like p_acad_cal_type) AND
                course_attempt_status IN ('ENROLLED','INACTIVE','INTERMIT');
      v_creation_dt     DATE;
      v_last_person_id  IGS_PE_PERSON.person_id%TYPE;

    BEGIN
      -- Call routine to create a new IGS_GE_S_LOG entry under which the log
      -- entries will be placed.
      IGS_GE_GEN_003.GENP_INS_LOG(p_rule_to_be_validated,
        p_acad_cal_type||','||TO_CHAR(p_acad_sequence_number)||','||p_course_cd,
        v_creation_dt);

      -- Logging parameters in the Log File.
      FND_FILE.PUT_LINE(FND_FILE.LOG,'================================================================================');
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_EN_ACAD_CAL') || ': ' || RTRIM(SUBSTR(p_acad_calander,1,74)));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_AD_CRS_CD') || ': ' || p_crs_cd);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_EN_TERM_TEACH_CAL') || ': ' || RTRIM(SUBSTR(p_load_teach_calendar,1,100)));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_PR_ORG_UNIT') || ': ' || p_org_unit_cd);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_EN_RULE_TO_VAL') || ': ' || p_rule_to_be_validated);
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'================================================================================');

      v_last_person_id := 0;
      BEGIN
        FOR v_st_rec IN c_st
        LOOP

          -- Only process each PERSON once (NOTE : a distinct could
          -- not be used in the query due to the FOR UPDATE clause.
          IF v_st_rec.person_id <> v_last_person_id THEN
            v_last_person_id := v_st_rec.person_id;

            FOR v_sca_rec IN c_sca(v_st_rec.person_id,p_course_cd)
            LOOP
              -- Call routine to process individual student Course
              -- attempt.
              --added 4 new parameters to this call for enrollment processes dld

              IGS_EN_VAL_BULKRULE.enrp_val_sca_urule(
                p_acad_cal_type,
                p_acad_sequence_number,
                v_st_rec.person_id,
                v_sca_rec.course_cd,
                p_rule_to_be_validated,
                v_creation_dt,
                p_load_cal_type,
                p_load_sequence_number,
                p_org_unit_cd,
                p_rule_to_be_validated);
            END LOOP;
            -- Logically remove the todo entries as they have been processed.
            /* For the coloumn to be updated,modify the record variable value fetched */
            v_st_rec.logical_delete_dt := SYSDATE;
            /* Call server side TBH package procedure */
            IGS_PE_STD_TODO_pkg.update_row(
              X_ROWID => v_st_rec.ROWID,
              X_PERSON_ID => v_st_rec.PERSON_ID,
              X_S_STUDENT_TODO_TYPE => v_st_rec.S_STUDENT_TODO_TYPE,
              X_SEQUENCE_NUMBER => v_st_rec.SEQUENCE_NUMBER,
              X_TODO_DT => v_st_rec.TODO_DT,
              X_LOGICAL_DELETE_DT => v_st_rec.LOGICAL_DELETE_DT,
              X_MODE => 'R');
          END IF;
        END LOOP;
      END;
      COMMIT;
    END;

  EXCEPTION
    WHEN OTHERS THEN
      retcode:=2;
      Fnd_File.PUT_LINE(Fnd_File.LOG,SQLERRM);
      IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_val_bulkrule.enrp_val_sca_rultodo.UNH_EXP','Unhandled Exception raised with code '||SQLCODE||' and error '||SQLERRM);
      END IF;
      ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END enrp_val_sca_rultodo;

    --
    -- Validate the unit rules for a student Course attempt (in bulk)
  /* smaddali modified this procedure to add 3 new parameters and their use in code */
  PROCEDURE ENRP_VAL_SCA_URULE(
    p_acad_cal_type IN VARCHAR2 ,
    p_acad_sequence_number IN NUMBER ,
    p_person_id IN NUMBER ,
    p_course_cd IN VARCHAR2 ,
    p_s_log_type IN VARCHAR2 ,
    p_creation_dt IN DATE ,
    -- added new parameters for bug#1832130
    p_cal_type IN VARCHAR2  ,
    p_ci_sequence_number IN NUMBER  ,
    p_org_unit_cd IN VARCHAR2  ,
    p_rule_to_be_validated IN VARCHAR2 )
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Modified the r_unit_attempt_typ record type definition in the
  --                            enrpl_enrolled_to_invalid and enrpl_invalid_to_enrolled procedures
  --                            w.r.t. bug number 2829262
  -- svenkata   3-Jun-2003      The function ENRP_VAL_COO_CROSS has been removed. All references to this API is removed. Bug# 2829272
  --rvangala    07-OCT-2003     Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
  --                            added as part of Prevent Dropping Core Units. Enh Bug# 3052432
  --ptandon     25-Feb-2004     Modified procedure enrpl_enrolled_to_invalid to rollback per unit attempt
  --                            in case of exception and process the Subordinate unit attempts before Superior
  --                            unit attempts. Modified procedure enrpl_invalid_to_enrolled to rollback per unit
  --                            attempt in case of exception and process the Superior unit attempts before
  --                            Subordinate unit attempts. Removed the exception handling block of
  --                            enrp_val_sca_urule. Bug# 3451409.
  --svanukur    04-MAY-2004     Modified procedures enrpl_enrolled_to_invalid and enrpl_invalid_to_enrolled to pass
  --                            the Term calendar as parameter to the rule checking procedures in IGS_RU_VAL_UNIT_RULE
  --                             to fix bug 3606629
  -- smaddali 15-oct-04         Modified for bug#3954071, reverted earlier fix bug 3606629 of passing load calendar to rules engine
  -------------------------------------------------------------------------------------------
  AS
  BEGIN
    DECLARE
      cst_s_control_num CONSTANT        IGS_EN_CAL_CONF.s_control_num%TYPE := 1;
      e_no_records_found        EXCEPTION;
      v_enrolled_rule_cutoff_dt         IGS_EN_CAL_CONF.enrolled_rule_cutoff_dt_alias%TYPE;
      v_invalid_rule_cutoff_dt          IGS_EN_CAL_CONF.invalid_rule_cutoff_dt_alias%TYPE;
      v_message_name                            varchar2(30);
      CURSOR c_secc IS
      SELECT    secc.enrolled_rule_cutoff_dt_alias,
                secc.invalid_rule_cutoff_dt_alias
      FROM      IGS_EN_CAL_CONF secc
      WHERE     secc.s_control_num = cst_s_control_num;

        /* smaddali modified this procedure to add 4 new parameters and their use in code
        --stutta      08-SEP-2004   Modified c_sua as part of performance tuning bug #3869677*/
        -------------------------------------
        PROCEDURE enrpl_enrolled_to_invalid (
          p_acad_cal_type                       IN      IGS_CA_INST.cal_type%TYPE,
          p_acad_sequence_number                IN      IGS_CA_INST.sequence_number%TYPE,
          p_person_id                           IN      IGS_EN_STDNT_PS_ATT.person_id%TYPE,
          p_course_cd                           IN      IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
          p_s_log_type                          IN      IGS_GE_S_LOG.s_log_type%TYPE,
          p_creation_dt                         IN      IGS_GE_S_LOG.creation_dt%TYPE,
          p_invalid_rule_cutoff_dt              IN      IGS_EN_CAL_CONF.invalid_rule_cutoff_dt_alias%TYPE,
          --added for enrollment processes dld by smaddali bug#1832130
          p_cal_type                            IN  IGS_CA_INST.cal_type%TYPE,
          p_ci_sequence_number                  IN  IGS_CA_INST.sequence_number%TYPE ,
          p_org_unit_cd                         IN  IGS_OR_UNIT.org_unit_cd%TYPE ,
          p_rule_to_be_validated                IN  IGS_EN_SU_ATTEMPT_ALL.failed_unit_rule%TYPE  )
        IS
        BEGIN
          DECLARE
            cst_enrolled   CONSTANT  IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'ENROLLED';
            cst_active CONSTANT IGS_CA_INST.cal_status%TYPE := 'ACTIVE';

            v_counter   NUMBER; -- keeps record of the number of records in the PL/SQL table
            v_next_rec  BOOLEAN; -- used to determine if the next record should be found
            v_do_cursor_again_ind       BOOLEAN;
            v_last_date_to_invalid      IGS_CA_DA_INST_V.alias_val%TYPE;
            v_message_text              VARCHAR2(2000);
            -- Add the following one line of code.       From Callista 2.0  18-May-2000
            v_sca_version_number              IGS_EN_STDNT_PS_ATT.version_number%TYPE;
            -- Initialise PL/SQL table to hold UNIT attempt records which
            -- cannot be set to INVALID.
            TYPE r_unit_attempt_typ IS RECORD (rv_uoo_id   igs_en_su_attempt.uoo_id%TYPE);
            r_unit_attempt_rec          r_unit_attempt_typ;
            TYPE t_unit_attempt_typ IS TABLE OF r_unit_attempt_rec%TYPE
                        INDEX BY BINARY_INTEGER;
            t_unit_attempt_tab          t_unit_attempt_typ;

            t_unit_att_failure t_unit_attempt_typ;
            r_unit_att_failure_rec r_unit_attempt_typ;
            l_counter_failure NUMBER;
            l_log_msg BOOLEAN;

            -- modified for enrollment processes build bug#1832130 by smaddali
            -- to consider the new parameters added.this cursor selects all the
            -- student unit attempts for the passed program attempt.
            --The two selects are mutually exclusive ie at any time the calendar passed is
            --either 'LOAD' or 'TEACHING' so this cursor selects the unit attempts
            -- for that particular calendar passed as parameter
            CURSOR c_sua(cp_cal_cat igs_ca_type.s_cal_cat%TYPE) IS
            -- selects the unit attempt when a teaching calendar is passed
            SELECT
             sua.unit_cd,
             sua.cal_type,
             sua.ci_sequence_number,
             sua.version_number,
             sua.location_cd,
             sua.unit_class,
             ci.alternate_code,
             uoo.uoo_id,
             sua.sup_unit_cd
            FROM  IGS_EN_SU_ATTEMPT    sua,
             IGS_CA_INST  ci,
             IGS_PS_UNIT_OFR_OPT uoo
            WHERE
             sua.person_id = p_person_id
             AND sua.course_cd = p_course_cd
             AND sua.unit_attempt_status = 'ENROLLED'
             AND sua.rule_waived_dt IS NULL
             AND ci.cal_type    = sua.cal_type
             AND ci.sequence_number = sua.ci_sequence_number
             AND uoo.uoo_id  = sua.uoo_id
             AND uoo.owner_org_unit_cd LIKE NVL(p_org_unit_cd,'%')
             AND (
                ( cp_cal_cat = 'TEACHING'
                  AND sua.cal_type LIKE NVL(p_cal_type,'%')
                  AND sua.ci_sequence_number = nvl(p_ci_sequence_number,sua.ci_sequence_number)
                ) OR
                ( cp_cal_cat = 'LOAD' AND
                  (sua.cal_type,sua.ci_sequence_number) IN
                   ( SELECT teach_cal_type,teach_ci_sequence_number
                     FROM IGS_CA_LOAD_TO_TEACH_V
                     WHERE load_cal_type LIKE NVL(p_cal_type,'%')
                     AND load_ci_sequence_number = nvl(p_ci_sequence_number,load_ci_sequence_number)
                   )
                )
                  )
            ORDER BY  sup_unit_cd;

            -- gets the invalid cutoff date alias value
            CURSOR c_daiv (
                        cp_sua_cal_type         IGS_EN_SU_ATTEMPT.cal_type%TYPE,
                        cp_sua_sequence_number  IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE) IS
            SELECT      MAX(daiv.alias_val)
            FROM        IGS_CA_DA_INST_V        daiv
            WHERE       daiv.cal_type = cp_sua_cal_type AND
                        daiv.ci_sequence_number  = cp_sua_sequence_number AND
                        daiv.dt_alias = p_invalid_rule_cutoff_dt;

            -- Add the following five lines of code.       From Callista 2.0  18-May-2000
            --gets the course varsion number for the student program attempt
            CURSOR c_sca IS
            SELECT      sca.version_number
            FROM        IGS_EN_STDNT_PS_ATT     sca
            WHERE       sca.person_id = p_person_id AND
                        sca.course_cd = p_course_cd;

            --smaddali modified this cursor to select only one unit section attempt
            --instead of all the unit sections of a given unit cd during enrollment processes dld
            CURSOR cur_IGS_EN_SU_ATTEMPT(cp_unit_cd VARCHAR2,
                                         cp_uoo_id igs_en_su_attempt_all.uoo_id%TYPE) IS
            SELECT sua.*
            FROM   IGS_EN_SU_ATTEMPT sua,
                   IGS_CA_INST  ci
            WHERE     sua.person_id = p_person_id AND
                      sua.course_cd = p_course_cd AND
                      sua.unit_attempt_status = cst_enrolled AND
                      sua.rule_waived_dt IS NULL        AND
                      ci.cal_type       = sua.cal_type  AND
                      ci.sequence_number = sua.ci_sequence_number AND
                      sua.unit_cd = cp_unit_cd AND
                      --added for enrollment processes dld by smaddali
                      sua.uoo_id = cp_uoo_id;

            /* smaddali bug#1832130 enrollment processes build nov 2001 release
              added declarations for workflow events */
           CURSOR cur_cal_cat IS
           SELECT s_cal_cat
           FROM IGS_CA_TYPE
           WHERE  cal_type = p_cal_type ;
            l_cal_cat igs_ca_type.s_cal_cat%TYPE ;
            l_failed_rule igs_en_su_attempt_all.failed_unit_rule%TYPE ;
            l_retval  BOOLEAN ;
            sua_rec cur_IGS_EN_SU_ATTEMPT%ROWTYPE ;


          BEGIN
            -- 3. Check all ENROLLED UNIT attempt IGS_PS_UNIT rules. If a RULE is failed the
            -- status is set to  INVALID and the select is repeated. This process
            -- repeats until no further units fail rules.
            --------------------------------------------------------

            v_counter := 0;
            l_counter_failure :=0;
            -- Add the following nine lines of code.       From Callista 2.0  18-May-2000
            -- Determine the version number of the course to be used in the call to
            -- rulp_val_enrol_unit.

            OPEN c_sca;
            FETCH c_sca INTO v_sca_version_number;
            IF c_sca%NOTFOUND THEN
                CLOSE c_sca;
                RAISE NO_DATA_FOUND;
            END IF;
            CLOSE c_sca;

            IF p_cal_type IS NULL THEN
                  l_cal_cat := 'TEACHING' ;
            ELSE
                OPEN cur_cal_cat ;
                FETCH cur_cal_cat INTO l_cal_cat ;
                CLOSE cur_cal_cat ;
            END IF;

            LOOP
              v_do_cursor_again_ind := FALSE;
              -- get the calendar category of the calendar passed

              FOR v_sua_rec IN c_sua(l_cal_cat)
              LOOP

              DECLARE
                l_message_text VARCHAR2(1000);
              BEGIN
                SAVEPOINT sp_sua;
                v_next_rec := FALSE;

                -- unit attempts which can't be set to invalid shouldn't be
                -- processed again - would result in a never ending recursive loop
                FOR i IN 1..v_counter
                LOOP
                  r_unit_attempt_rec := t_unit_attempt_tab(i);
                  IF (r_unit_attempt_rec.rv_uoo_id = v_sua_rec.uoo_id) THEN
                    v_next_rec := TRUE;
                    EXIT;
                  END IF;
                END LOOP;

                IF (v_next_rec = FALSE) THEN

                  -- sua record is not in the PL/SQL table
                  -- Select the last date to switch to ENROLLED from the teaching period.
                  IF (p_invalid_rule_cutoff_dt IS NOT NULL) THEN
                    OPEN c_daiv(
                        v_sua_rec.cal_type,
                        v_sua_rec.ci_sequence_number);
                    FETCH c_daiv INTO v_last_date_to_invalid;
                    IF (c_daiv%NOTFOUND) THEN
                      v_last_date_to_invalid := NULL;
                    END IF;
                    CLOSE c_daiv;
                  ELSE
                    v_last_date_to_invalid := NULL;
                  END IF;

                  -- Check whether the unit attempt fails the unit rule passed as parameter
                  -- If so, it should be set to INVALID.
                  IF (p_rule_to_be_validated = 'PRE-REQ') THEN

                  --if rule to validate is prerequisite then call the corresponding
                    l_retval := IGS_RU_VAL_UNIT_RULE.rulp_val_prereq(
                                p_person_id,
                                p_course_cd,
                                v_sua_rec.unit_cd,
                                v_sua_rec.cal_type,
                                v_sua_rec.ci_sequence_number,
                                v_message_text ,
                                v_sca_version_number,
                                v_sua_rec.version_number,
                                v_sua_rec.uoo_id,
                                l_failed_rule );

                  ELSIF (p_rule_to_be_validated = 'CO-REQ') THEN

                    l_retval := IGS_RU_VAL_UNIT_RULE.rulp_val_coreq(
                                p_person_id,
                                p_course_cd,
                                v_sua_rec.unit_cd,
                                v_sua_rec.cal_type,
                                v_sua_rec.ci_sequence_number,
                                v_message_text ,
                                v_sca_version_number,
                                v_sua_rec.version_number,
                                v_sua_rec.uoo_id,
                                l_failed_rule );
                 ELSIF (p_rule_to_be_validated = 'INCOMP') THEN

                    l_retval := IGS_RU_VAL_UNIT_RULE.rulp_val_incomp(
                                p_person_id,
                                p_course_cd,
                                v_sua_rec.unit_cd,
                                v_sua_rec.cal_type,
                                v_sua_rec.ci_sequence_number,
                                v_message_text ,
                                v_sca_version_number,
                                v_sua_rec.version_number,
                                v_sua_rec.uoo_id,
                                l_failed_rule );

                  ELSIF (p_rule_to_be_validated = 'ALL') THEN

                    l_retval := IGS_RU_VAL_UNIT_RULE.rulp_val_enrol_unit(
                                p_person_id,
                                p_course_cd,
                                -- Add the following one lines of code.From Callista 2.0  18-May-2000
                                v_sca_version_number,
                                v_sua_rec.unit_cd,
                                v_sua_rec.version_number,
                                v_sua_rec.cal_type,
                                v_sua_rec.ci_sequence_number,
                                v_message_text ,
                                v_sua_rec.uoo_id,
                                l_failed_rule );

                  END IF ;
                  IF NOT l_retval THEN

                   -- if the rule has failed then log an entry and try to change to invalid
                    IF (v_last_date_to_invalid IS NOT NULL AND
                        SYSDATE > v_last_date_to_invalid) THEN
                      --the invalid cutoff date has passed so cannot make invalid
                      -- If logging is required, then log the change to the passed log

                      IF (p_s_log_type IS NOT NULL AND
                        p_creation_dt IS NOT NULL) THEN
                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                          p_s_log_type,
                          p_creation_dt,
                          'WARNING,' || p_person_id || ',' ||
                          p_course_cd ||',' ||
                          v_sua_rec.unit_cd || ',' ||
                          v_sua_rec.version_number || ',' ||
                          'ENROLLED,' || v_sua_rec.alternate_code || ',' ||
                          v_sua_rec.location_cd || ',' ||
                          v_sua_rec.unit_class,
                          'IGS_EN_UA_FAILS_ST_INVALID',
                          NULL);
                      END IF;
                      -- Store unit_cd, cal_type and ci_sequence_number in PL/SQL table
                      r_unit_attempt_rec.rv_uoo_id := v_sua_rec.uoo_id;
                      v_counter := v_counter + 1;
                      t_unit_attempt_tab(v_counter) := r_unit_attempt_rec;
                    ELSE
                      -- Set the student unit attempt to invalid
                      -- as rules are being breached.

                      OPEN cur_IGS_EN_SU_ATTEMPT(v_sua_rec.unit_cd,v_sua_rec.uoo_id)  ;
                      FETCH cur_IGS_EN_SU_ATTEMPT INTO sua_rec  ;
                      CLOSE cur_IGS_EN_SU_ATTEMPT ;
                      /* For the coloumn to be updated,modify the record variable value fetched */
                      sua_rec.unit_attempt_status := 'INVALID' ;
                      -- Call the API to update the student unit attempt. This API is a
                      -- wrapper to the update row of the TBH.
                      igs_en_sua_api.update_unit_attempt(
                            X_ROWID => sua_rec.ROW_ID,
                            X_PERSON_ID => sua_rec.PERSON_ID,
                            X_COURSE_CD => sua_rec.COURSE_CD,
                            X_UNIT_CD => sua_rec.UNIT_CD,
                            X_CAL_TYPE => sua_rec.CAL_TYPE,
                            X_CI_SEQUENCE_NUMBER => sua_rec.CI_SEQUENCE_NUMBER,
                            X_VERSION_NUMBER => sua_rec.VERSION_NUMBER,
                            X_LOCATION_CD => sua_rec.LOCATION_CD,
                            X_UNIT_CLASS => sua_rec.UNIT_CLASS,
                            X_CI_START_DT => sua_rec.CI_START_DT,
                            X_CI_END_DT => sua_rec.CI_END_DT,
                            X_UOO_ID => sua_rec.UOO_ID,
                            X_ENROLLED_DT => sua_rec.ENROLLED_DT,
                            X_UNIT_ATTEMPT_STATUS => sua_rec.UNIT_ATTEMPT_STATUS,
                            X_ADMINISTRATIVE_UNIT_STATUS => sua_rec.ADMINISTRATIVE_UNIT_STATUS,
                            X_ADMINISTRATIVE_PRIORITY => sua_rec.ADMINISTRATIVE_PRIORITY,
                            X_DISCONTINUED_DT => sua_rec.DISCONTINUED_DT,
                            X_DCNT_REASON_CD  => sua_rec.DCNT_REASON_CD ,
                            X_RULE_WAIVED_DT => sua_rec.RULE_WAIVED_DT,
                            X_RULE_WAIVED_PERSON_ID => sua_rec.RULE_WAIVED_PERSON_ID,
                            X_NO_ASSESSMENT_IND => sua_rec.NO_ASSESSMENT_IND,
                            X_SUP_UNIT_CD => sua_rec.SUP_UNIT_CD,
                            X_SUP_VERSION_NUMBER => sua_rec.SUP_VERSION_NUMBER,
                            X_EXAM_LOCATION_CD => sua_rec.EXAM_LOCATION_CD,
                            X_ALTERNATIVE_TITLE => sua_rec.ALTERNATIVE_TITLE,
                            X_OVERRIDE_ENROLLED_CP => sua_rec.OVERRIDE_ENROLLED_CP,
                            X_OVERRIDE_EFTSU => sua_rec.OVERRIDE_EFTSU,
                            X_OVERRIDE_ACHIEVABLE_CP => sua_rec.OVERRIDE_ACHIEVABLE_CP,
                            X_OVERRIDE_OUTCOME_DUE_DT => sua_rec.OVERRIDE_OUTCOME_DUE_DT,
                            X_OVERRIDE_CREDIT_REASON => sua_rec.OVERRIDE_CREDIT_REASON,
                            X_WAITLIST_DT => sua_rec.WAITLIST_DT,
                            X_MODE  => 'R' ,
                            -- added for enrollment processes dld nov2001 by smaddali
                            X_GS_VERSION_NUMBER => sua_rec.gs_version_number,
                            X_ENR_METHOD_TYPE  => sua_rec.enr_method_type,
                            X_FAILED_UNIT_RULE  => l_failed_rule,
                            X_CART => sua_rec.CART,
                            X_RSV_SEAT_EXT_ID => sua_rec.RSV_SEAT_EXT_ID,
                            X_ORG_UNIT_CD => sua_rec.ORG_UNIT_CD ,
                            -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                            X_SESSION_ID          => sua_rec.session_id,
                            -- Added the column grading schema as a part pf the bug 2037897. - aiyer
                            X_GRADING_SCHEMA_CODE => sua_rec.GRADING_SCHEMA_CODE,
                            -- Added the column deg_aud_detail_id as part of Degree Audit Interface build (Bug# 2033208)
                            -- by pradhakr
                            X_DEG_AUD_DETAIL_ID   => sua_rec.DEG_AUD_DETAIL_ID,
                            X_SUBTITLE       =>  sua_rec.subtitle,
                            X_STUDENT_CAREER_TRANSCRIPT =>  sua_rec.student_career_transcript,
                            X_STUDENT_CAREER_STATISTICS =>  sua_rec.student_career_statistics,
                            X_ATTRIBUTE_CATEGORY        =>  sua_rec.attribute_category,
                            X_ATTRIBUTE1                =>  sua_rec.attribute1,
                            X_ATTRIBUTE2                =>  sua_rec.attribute2,
                            X_ATTRIBUTE3                =>  sua_rec.attribute3,
                            X_ATTRIBUTE4                =>  sua_rec.attribute4,
                            X_ATTRIBUTE5                =>  sua_rec.attribute5,
                            X_ATTRIBUTE6                =>  sua_rec.attribute6,
                            X_ATTRIBUTE7                =>  sua_rec.attribute7,
                            X_ATTRIBUTE8                =>  sua_rec.attribute8,
                            X_ATTRIBUTE9                =>  sua_rec.attribute9,
                            X_ATTRIBUTE10               =>  sua_rec.attribute10,
                            X_ATTRIBUTE11               =>  sua_rec.attribute11,
                            X_ATTRIBUTE12               =>  sua_rec.attribute12,
                            X_ATTRIBUTE13               =>  sua_rec.attribute13,
                            X_ATTRIBUTE14               =>  sua_rec.attribute14,
                            X_ATTRIBUTE15               =>  sua_rec.attribute15,
                            X_ATTRIBUTE16               =>  sua_rec.attribute16,
                            X_ATTRIBUTE17               =>  sua_rec.attribute17,
                            X_ATTRIBUTE18               =>  sua_rec.attribute18,
                            X_ATTRIBUTE19               =>  sua_rec.attribute19,
                            X_ATTRIBUTE20               =>  sua_rec.attribute20,
                            X_WAITLIST_MANUAL_IND       =>  sua_rec.waitlist_manual_ind, --Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                            X_WLST_PRIORITY_WEIGHT_NUM  =>  sua_rec.wlst_priority_weight_num,
                            X_WLST_PREFERENCE_WEIGHT_NUM=>  sua_rec.wlst_preference_weight_num,
                            -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
                            X_CORE_INDICATOR_CODE       =>  sua_rec.core_indicator_code
                            );

                      -- added for bug#1832130 enrollment processes dld
                      -- raise the workflow event  to send a mail to the student when the
                      --student unit attempt status has changed from enrolled to invalid
                     IGS_EN_WORKFLOW.SUA_STATUS_CHANGE_MAIL(sua_rec.UNIT_ATTEMPT_STATUS,
                                      sua_rec.PERSON_ID,sua_rec.UOO_ID);

                      -- If logging is required, then log the change to the passed log
                      IF (p_s_log_type IS NOT NULL AND
                        p_creation_dt IS NOT NULL) THEN
                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                          p_s_log_type,
                          p_creation_dt,
                          'INFO,' || p_person_id || ',' ||
                          p_course_cd ||',' ||
                          v_sua_rec.unit_cd || ',' ||
                          v_sua_rec.version_number || ',' ||
                          'INVALID,' || v_sua_rec.alternate_code || ',' ||
                          v_sua_rec.location_cd || ',' ||
                          v_sua_rec.unit_class,
                          'IGS_EN_UA_FAILES_STATUS_INVAL',
                          NULL);
                      END IF;
                    END IF;
                    -- Exit from loop and repeat entire select
                    v_do_cursor_again_ind := TRUE;
                    EXIT;
                  END IF;
                END IF;
              EXCEPTION
               WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN

                ROLLBACK TO sp_sua;
                IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_val_bulkrule.enrp_val_sca_urule.enrpl_enrolled_to_invalid.APP_EXP','Application Exception raised with code '||SQLCODE||' and error '||SQLERRM);
                END IF;
                l_message_text := FND_MESSAGE.GET;

                IF l_message_text IS NULL THEN
                   l_message_text := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNEXPECTED_ERR');
                END IF;
                IF (p_s_log_type IS NOT NULL AND
                    p_creation_dt IS NOT NULL) THEN

                    l_log_msg := TRUE;

                    FOR i IN 1..l_counter_failure
                    LOOP
                       r_unit_att_failure_rec := t_unit_att_failure(i);
                       IF (r_unit_att_failure_rec.rv_uoo_id = v_sua_rec.uoo_id) THEN
                          l_log_msg := FALSE;
                       EXIT;
                     END IF;
                    END LOOP;

                    IF l_log_msg = TRUE THEN

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                          p_s_log_type,
                          p_creation_dt,
                          'ERROR,' || p_person_id || ',' ||
                          p_course_cd ||',' ||
                          v_sua_rec.unit_cd || ',' ||
                          v_sua_rec.version_number || ',' ||
                          'ENROLLED,' || v_sua_rec.alternate_code || ',' ||
                          v_sua_rec.location_cd || ',' ||
                          v_sua_rec.unit_class,
                          NULL,
                          l_message_text);

                          r_unit_att_failure_rec.rv_uoo_id := v_sua_rec.uoo_id;
                          l_counter_failure := l_counter_failure + 1;
                          t_unit_att_failure(l_counter_failure) := r_unit_att_failure_rec;

                    END IF;
                END IF;

               WHEN OTHERS THEN

                ROLLBACK TO sp_sua;
                IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_val_bulkrule.enrp_val_sca_urule.enrpl_enrolled_to_invalid.UNH_EXP','Unhandled Exception raised with code '||SQLCODE||' and error '||SQLERRM);
                END IF;
                l_message_text := FND_MESSAGE.GET;
                IF l_message_text IS NULL THEN
                   l_message_text := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNEXPECTED_ERR');
                END IF;
                IF (p_s_log_type IS NOT NULL AND
                    p_creation_dt IS NOT NULL) THEN

                    l_log_msg := TRUE;

                    FOR i IN 1..l_counter_failure
                    LOOP
                       r_unit_att_failure_rec := t_unit_att_failure(i);
                       IF (r_unit_att_failure_rec.rv_uoo_id = v_sua_rec.uoo_id) THEN
                          l_log_msg := FALSE;
                       EXIT;
                     END IF;
                    END LOOP;

                    IF l_log_msg = TRUE THEN

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                          p_s_log_type,
                          p_creation_dt,
                          'ERROR,' || p_person_id || ',' ||
                          p_course_cd ||',' ||
                          v_sua_rec.unit_cd || ',' ||
                          v_sua_rec.version_number || ',' ||
                          'ENROLLED,' || v_sua_rec.alternate_code || ',' ||
                          v_sua_rec.location_cd || ',' ||
                          v_sua_rec.unit_class,
                          NULL,
                          l_message_text);

                          r_unit_att_failure_rec.rv_uoo_id := v_sua_rec.uoo_id;
                          l_counter_failure := l_counter_failure + 1;
                          t_unit_att_failure(l_counter_failure) := r_unit_att_failure_rec;

                    END IF;
                END IF;

              END;
              END LOOP;
              IF (v_do_cursor_again_ind = FALSE) THEN
                EXIT;
              END IF;
            END LOOP;

          END;
        END enrpl_enrolled_to_invalid;

     /* --smaddali modified this procedure to add 3 new parameters and their use in code
        --rvangala    07-OCT-2003    Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
        --                   added as part of Prevent Dropping Core Units. Enh Bug# 3052432
        --stutta      08-SEP-2004   Modified c_sua_sca as part of performance tuning bug #3869677
        --stutta      21-FEB-2006   Modified c_sua_sca and added pl/sql logic as part of bug #5051047
        --ckasu       25-APR-2006    Modfied as a part of bug#5191592.
        */
      -----------------------------------
      PROCEDURE enrpl_invalid_to_enrolled (
                p_acad_cal_type            IN      IGS_CA_INST.cal_type%TYPE,
                p_acad_sequence_number     IN      IGS_CA_INST.sequence_number%TYPE,
                p_person_id                IN      IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                p_course_cd                IN      IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                p_s_log_type               IN      IGS_GE_S_LOG.s_log_type%TYPE,
                p_creation_dt              IN      IGS_GE_S_LOG.creation_dt%TYPE,
                p_enrolled_rule_cutoff_dt  IN      IGS_EN_CAL_CONF.enrolled_rule_cutoff_dt_alias%TYPE,
                --added for enrollment processes dld by smaddali bug#1832130
                p_cal_type                 IN      IGS_CA_INST.cal_type%TYPE ,
                p_ci_sequence_number       IN      IGS_CA_INST.sequence_number%TYPE ,
                p_org_unit_cd              IN      IGS_OR_UNIT.org_unit_cd%TYPE )
      IS
      BEGIN
        DECLARE
            v_counter    NUMBER;  -- keeps record of the number of records in the PL/SQL table
            v_next_rec  BOOLEAN; -- used to determine if the next record should be found
            v_do_cursor_again_ind               BOOLEAN;
            v_last_date_to_enrolled             IGS_CA_DA_INST_V.alias_val%TYPE;
            v_validation_error          BOOLEAN;
            v_message_text                      VARCHAR2(2000);
            v_validation_message_name   VARCHAR2(30);
            v_attendance_types          VARCHAR2(100);
             cst_active CONSTANT IGS_CA_INST.cal_status%TYPE := 'ACTIVE';
            -- Initialise PL/SQL table to hold UNIT attempt records which
            -- cannot be set to ENROLLED.
            TYPE r_unit_attempt_typ IS RECORD (rv_uoo_id   IGS_EN_SU_ATTEMPT.uoo_id%TYPE);
            r_unit_attempt_rec          r_unit_attempt_typ;
            TYPE t_unit_attempt_typ IS TABLE OF r_unit_attempt_rec%TYPE
                INDEX BY BINARY_INTEGER;
            t_unit_attempt_tab          t_unit_attempt_typ;

            t_unit_att_failure t_unit_attempt_typ;
            r_unit_att_failure_rec r_unit_attempt_typ;
            l_counter_failure NUMBER;
            l_log_msg BOOLEAN;

            -- exception declaration - used when updating sua.unit_attempt_status
            e_resource_busy_exception           EXCEPTION;
            PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);

            -- modified for enrollment processes build bug#1832130 by smaddali
            -- to consider the new parameters added .
            --The two selects are mutually exclusive ie at any time the calendar passed is
            --either 'LOAD' or 'TEACHING' so this cursor selects the unit attempts
            -- for that particular calendar passed as parameter

            CURSOR c_sua_sca(cp_cal_cat igs_ca_type.s_cal_cat%TYPE, cp_cal_type igs_ca_inst.cal_type%TYPE, cp_ci_sequence_number igs_ca_inst.sequence_number%TYPE) IS
            --selects unit attempts when a teaching calendar is passed
            SELECT sua.unit_cd,
             sua.version_number      sua_version_number,
             sua.cal_type,
             sua.ci_sequence_number,
             sua.unit_class,
             sua.location_cd,
             sca.version_number      sca_version_number,
             sca.coo_id,
             ci.alternate_code ,
             uoo.uoo_id,
             sua.sup_unit_cd
            FROM IGS_EN_SU_ATTEMPT      sua,
             IGS_EN_STDNT_PS_ATT    sca,
             IGS_CA_INST            ci ,
             IGS_PS_UNIT_OFR_OPT uoo
            WHERE    sua.person_id = p_person_id
            AND sua.course_cd = p_course_cd
            AND sua.unit_attempt_status = 'INVALID'
            AND sca.person_id = sua.person_id
            AND sca.course_cd = sua.course_cd
            AND ci.sequence_number = sua.ci_sequence_number
            AND ci.cal_type = sua.cal_type
            AND uoo.uoo_id  = sua.uoo_id
            AND uoo.owner_org_unit_cd LIKE NVL(p_org_unit_cd,'%')
            AND sua.cal_type LIKE NVL(cp_cal_type ,'%')
            AND sua.ci_sequence_number = nvl( cp_ci_sequence_number ,sua.ci_sequence_number)
            ORDER BY sup_unit_cd DESC;

            --smaddali modified this cursor to select only one unit section attempt
            --instead of all the unit sections of a given unit cd during enrollment processes dld
            CURSOR cur_IGS_EN_SU_ATTEMPT(cp_unit_cd varchar2,
                                         cp_uoo_id igs_en_su_attempt_all.uoo_id%TYPE) IS
            SELECT sua.*
            FROM     IGS_EN_SU_ATTEMPT sua,
                     IGS_EN_STDNT_PS_ATT        sca,
                     IGS_CA_INST        ci
            WHERE       sua.person_id = p_person_id AND
                        sua.course_cd = p_course_cd AND
                        sua.unit_attempt_status = 'INVALID' AND
                        sca.person_id = sua.person_id AND
                        sca.course_cd = sua.course_cd AND
                        ci.cal_type = sua.cal_type      AND
                        ci.sequence_number = sua.ci_sequence_number AND
                        sua.unit_cd = cp_unit_cd AND
                        --added for enrollment processes dld by smaddali
                        sua.uoo_id = cp_uoo_id;

            CURSOR c_daiv (
                   cp_sua_cal_type              IGS_EN_SU_ATTEMPT.cal_type%TYPE,
                   cp_sua_sequence_number       IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE) IS
            SELECT      MAX(daiv.alias_val)
            FROM        IGS_CA_DA_INST_V        daiv
            WHERE       daiv.cal_type = cp_sua_cal_type AND
                        daiv.ci_sequence_number  = cp_sua_sequence_number AND
                        daiv.dt_alias = p_enrolled_rule_cutoff_dt;

            /* smaddali bug#1832130 enrollment processes build nov 2001 release
            added declarations for workflow events and new parameters added to this procedure */
           CURSOR cur_cal_cat IS
           SELECT s_cal_cat
           FROM IGS_CA_TYPE
           WHERE  cal_type = p_cal_type ;

           CURSOR c_load_to_teach IS
           SELECT teach_cal_type,teach_ci_sequence_number
           FROM   IGS_CA_LOAD_TO_TEACH_V
           WHERE  load_cal_type = p_cal_type
           AND    load_ci_sequence_number = nvl( p_ci_sequence_number ,load_ci_sequence_number);

           rec_teach c_load_to_teach%ROWTYPE;
            l_cal_cat igs_ca_type.s_cal_cat%TYPE ;
            l_failed_rule igs_en_su_attempt_all.failed_unit_rule%TYPE;
            sua_rec cur_IGS_EN_SU_ATTEMPT%ROWTYPE ;
            l_loop_ended BOOLEAN := FALSE;

        BEGIN
          -- 2. Re-check all INVALID UNIT attempts and switch to ENROLLED if the
          -- rules are now passed. If an invalid unit passes all rules the status is
          -- set to ENROLLED and the select is repeated. This repeats until no more
          -- invalid unit attempts pass the unit rules.
          --------------------------------------------------------------------------
          v_counter := 0;
          l_counter_failure := 0;

          IF p_cal_type IS NULL THEN
                  l_cal_cat := 'TEACHING' ;
          ELSE
                OPEN cur_cal_cat ;
                FETCH cur_cal_cat INTO l_cal_cat ;
                CLOSE cur_cal_cat ;
          END IF;

          l_loop_ended := FALSE;

          IF l_cal_cat = 'TEACHING' THEN
             --
            rec_teach.teach_cal_type := p_cal_type;
            rec_teach.teach_ci_sequence_number := p_ci_sequence_number;
          ELSIF l_cal_cat = 'LOAD' THEN
            OPEN c_load_to_teach;
          END IF;
          LOOP -- loop to find each teach calendar associated with the load.

            IF l_cal_cat = 'LOAD' THEN
              --

              FETCH c_load_to_teach INTO rec_teach;
              IF c_load_to_teach%NOTFOUND THEN
                --
                l_loop_ended :=TRUE;
              END IF;

            END IF;
            EXIT WHEN l_loop_ended = TRUE;
    --

          LOOP
            v_do_cursor_again_ind := FALSE;
            -- for eachof the unit attempts of the student program attempt
            --validate the rule
            -- get the calendar category of the calendar passed

		    FOR v_sua_sca_rec IN c_sua_sca(l_cal_cat, rec_teach.teach_cal_type, rec_teach.teach_ci_sequence_number)
              LOOP
             DECLARE
              l_message_text VARCHAR2(1000);
             BEGIN
              SAVEPOINT sp_sua;
              v_next_rec := FALSE;
              -- unit attempts which can't be set to enrolled shouldn't be processed
              -- again - would result in a never ending recursive loop.
              FOR i IN 1..v_counter
              LOOP
                r_unit_attempt_rec := t_unit_attempt_tab(i);
                IF (r_unit_attempt_rec.rv_uoo_id = v_sua_sca_rec.uoo_id) THEN
                    v_next_rec := TRUE;
                    EXIT;
                END IF;
              END LOOP;
              --if unit attempt hasn't been processed before then only validate for rules
              IF (v_next_rec = FALSE) THEN
                  -- sua record is not in the PL/SQL table
                  -- Select the last date to switch to ENROLLED from the teaching period
                  IF (p_enrolled_rule_cutoff_dt IS NOT NULL) THEN
                       OPEN c_daiv(v_sua_sca_rec.cal_type,v_sua_sca_rec.ci_sequence_number);
                       FETCH c_daiv INTO v_last_date_to_enrolled;
                       IF (c_daiv%NOTFOUND) THEN
                             v_last_date_to_enrolled := NULL;
                       END IF;
                       CLOSE c_daiv;
                  ELSE
                       v_last_date_to_enrolled := NULL;
                  END IF;

                  -- Check that there is still a unit Rule being failed for the UNIT
                  -- attempt.  If not, it should be switched back to ENROLLED.
                  -- smaddali added two new parameters to this function bug#1832130

                  IF IGS_RU_VAL_UNIT_RULE.rulp_val_enrol_unit(
                            p_person_id,
                            p_course_cd,
                            -- Add the following one line of code.  From Callista 2.0  18-May-2000
                            v_sua_sca_rec.sca_version_number,
                            v_sua_sca_rec.unit_cd,
                            v_sua_sca_rec.sua_version_number,
                            v_sua_sca_rec.cal_type,
                            v_sua_sca_rec.ci_sequence_number,
                            v_message_text ,
                            --added for enrollment processes dld by smaddali
                            v_sua_sca_rec.uoo_id,
                           l_failed_rule) = TRUE THEN
                       v_validation_error := FALSE;
                       IF (v_last_date_to_enrolled IS NOT NULL AND
                                SYSDATE > v_last_date_to_enrolled) THEN
                         -- if the enrollment cutoff date has passed then cannot
                         --change the unit to enrolled , so mark as validation error
                            v_validation_error := TRUE;
                            v_validation_message_name := 'IGS_EN_UA_CHGST_ENROLLED';

                       ELSE
                           --update the unit attempt status to enrolled and set failed unit rule to NULL
                           OPEN cur_IGS_EN_SU_ATTEMPT(v_sua_sca_rec.unit_cd, v_sua_sca_rec.uoo_id);
                           FETCH cur_IGS_EN_SU_ATTEMPT INTO sua_rec ;
                           CLOSE cur_IGS_EN_SU_ATTEMPT  ;
                           /* For the column to be updated,modify the record variable value fetched */

                           sua_rec.unit_attempt_status := 'ENROLLED' ;
                           -- Call the API to update the student unit attempt. This API is a
                           -- wrapper to the update row of the TBH.
                           igs_en_sua_api.update_unit_attempt(
                                 X_ROWID => sua_rec.ROW_ID,
                                 X_PERSON_ID => sua_rec.PERSON_ID,
                                 X_COURSE_CD => sua_rec.COURSE_CD,
                                 X_UNIT_CD => sua_rec.UNIT_CD,
                                 X_CAL_TYPE => sua_rec.CAL_TYPE,
                                 X_CI_SEQUENCE_NUMBER => sua_rec.CI_SEQUENCE_NUMBER,
                                 X_VERSION_NUMBER => sua_rec.VERSION_NUMBER,
                                 X_LOCATION_CD => sua_rec.LOCATION_CD,
                                 X_UNIT_CLASS => sua_rec.UNIT_CLASS,
                                 X_CI_START_DT => sua_rec.CI_START_DT,
                                 X_CI_END_DT => sua_rec.CI_END_DT,
                                 X_UOO_ID => sua_rec.UOO_ID,
                                 X_ENROLLED_DT => sua_rec.ENROLLED_DT,
                                 X_UNIT_ATTEMPT_STATUS => sua_rec.UNIT_ATTEMPT_STATUS,
                                 X_ADMINISTRATIVE_UNIT_STATUS => sua_rec.ADMINISTRATIVE_UNIT_STATUS,
                                 X_ADMINISTRATIVE_PRIORITY => sua_rec.ADMINISTRATIVE_PRIORITY,
                                 X_DISCONTINUED_DT => sua_rec.DISCONTINUED_DT,
                                 X_DCNT_REASON_CD  => sua_rec.DCNT_REASON_CD ,
                                 X_RULE_WAIVED_DT => sua_rec.RULE_WAIVED_DT,
                                 X_RULE_WAIVED_PERSON_ID => sua_rec.RULE_WAIVED_PERSON_ID,
                                 X_NO_ASSESSMENT_IND => sua_rec.NO_ASSESSMENT_IND,
                                 X_SUP_UNIT_CD => sua_rec.SUP_UNIT_CD,
                                 X_SUP_VERSION_NUMBER => sua_rec.SUP_VERSION_NUMBER,
                                 X_EXAM_LOCATION_CD => sua_rec.EXAM_LOCATION_CD,
                                 X_ALTERNATIVE_TITLE => sua_rec.ALTERNATIVE_TITLE,
                                 X_OVERRIDE_ENROLLED_CP => sua_rec.OVERRIDE_ENROLLED_CP,
                                 X_OVERRIDE_EFTSU => sua_rec.OVERRIDE_EFTSU,
                                 X_OVERRIDE_ACHIEVABLE_CP => sua_rec.OVERRIDE_ACHIEVABLE_CP,
                                 X_OVERRIDE_OUTCOME_DUE_DT => sua_rec.OVERRIDE_OUTCOME_DUE_DT,
                                 X_OVERRIDE_CREDIT_REASON => sua_rec.OVERRIDE_CREDIT_REASON,
                                 X_WAITLIST_DT => sua_rec.waitlist_dt,
                                 X_MODE  => 'R' ,
                                 X_GS_VERSION_NUMBER => sua_rec.gs_version_number,
                                 X_ENR_METHOD_TYPE  => sua_rec.enr_method_type,
                                 X_FAILED_UNIT_RULE  => l_failed_rule ,
                                 X_CART => sua_rec.CART,
                                 X_RSV_SEAT_EXT_ID => sua_rec.RSV_SEAT_EXT_ID,
                                 X_ORG_UNIT_CD  =>  sua_rec.ORG_UNIT_CD,
                                 -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                 X_SESSION_ID   =>  sua_rec.session_id,
                                 -- Added the column grading schema as a part pf the bug 2037897. - aiyer
                                 X_GRADING_SCHEMA_CODE => sua_rec.GRADING_SCHEMA_CODE,
                                 -- Added the column deg_aud_detail_id as part of Degree Audit Interface build (Bug# 2033208)
                                 -- by pradhakr
                                 X_DEG_AUD_DETAIL_ID      => sua_rec.DEG_AUD_DETAIL_ID,
                                 X_SUBTITLE               =>  sua_rec.subtitle,
                                 X_STUDENT_CAREER_TRANSCRIPT =>  sua_rec.student_career_transcript,
                                 X_STUDENT_CAREER_STATISTICS =>  sua_rec.student_career_statistics,
                                 X_ATTRIBUTE_CATEGORY        =>  sua_rec.attribute_category,
                                 X_ATTRIBUTE1                =>  sua_rec.attribute1,
                                 X_ATTRIBUTE2                =>  sua_rec.attribute2,
                                 X_ATTRIBUTE3                =>  sua_rec.attribute3,
                                 X_ATTRIBUTE4                =>  sua_rec.attribute4,
                                 X_ATTRIBUTE5                =>  sua_rec.attribute5,
                                 X_ATTRIBUTE6                =>  sua_rec.attribute6,
                                 X_ATTRIBUTE7                =>  sua_rec.attribute7,
                                 X_ATTRIBUTE8                =>  sua_rec.attribute8,
                                 X_ATTRIBUTE9                =>  sua_rec.attribute9,
                                 X_ATTRIBUTE10               =>  sua_rec.attribute10,
                                 X_ATTRIBUTE11               =>  sua_rec.attribute11,
                                 X_ATTRIBUTE12               =>  sua_rec.attribute12,
                                 X_ATTRIBUTE13               =>  sua_rec.attribute13,
                                 X_ATTRIBUTE14               =>  sua_rec.attribute14,
                                 X_ATTRIBUTE15               =>  sua_rec.attribute15,
                                 X_ATTRIBUTE16               =>  sua_rec.attribute16,
                                 X_ATTRIBUTE17               =>  sua_rec.attribute17,
                                 X_ATTRIBUTE18               =>  sua_rec.attribute18,
                                 X_ATTRIBUTE19               =>  sua_rec.attribute19,
                                 X_ATTRIBUTE20               =>  sua_rec.attribute20,
                                 X_WAITLIST_MANUAL_IND       =>  sua_rec.waitlist_manual_ind, --Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                                 X_WLST_PRIORITY_WEIGHT_NUM  =>  sua_rec.wlst_priority_weight_num,
                                 X_WLST_PREFERENCE_WEIGHT_NUM=>  sua_rec.wlst_preference_weight_num,
                                  -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
                                 X_CORE_INDICATOR_CODE       =>  sua_rec.core_indicator_code
                                 );

                       END IF;
                      IF (v_validation_error = FALSE) THEN

                          -- ie unt attempt has passed rules so changed to enrolled
                          -- so check for other validations
                          IF (IGS_EN_VAL_ENCMB.enrp_val_excld_unit(
                                  p_person_id,p_course_cd,v_sua_sca_rec.unit_cd,
                                  SYSDATE,v_message_name) = FALSE) THEN
                             v_validation_error := TRUE;
                             v_validation_message_name := 'IGS_EN_UA_NOFAIL_STUD_EXCL';

                          ELSIF (IGS_EN_VAL_SUA.enrp_val_sua_intrmt(
                                p_person_id,p_course_cd,v_sua_sca_rec.cal_type,
                                v_sua_sca_rec.ci_sequence_number,v_message_name) = FALSE) THEN
                             v_validation_error := TRUE;
                             v_validation_message_name := 'IGS_EN_UA_NOFAIL_UNIT_ATT';

                          ELSIF (IGS_EN_VAL_SUA.enrp_val_sua_advstnd( p_person_id,p_course_cd,
                                 v_sua_sca_rec.sca_version_number, v_sua_sca_rec.unit_cd,
                                 v_sua_sca_rec.sua_version_number,
                                 v_message_name , 'N') = FALSE AND  v_message_name <> 'IGS_EN_STUD_APPROVED_ADVSTD') THEN
                             v_validation_error := TRUE;
                             v_validation_message_name := 'IGS_EN_UA_NOFAIL_UNIT_EXISTS';

                          ELSIF (IGS_EN_VAL_SUA.enrp_val_coo_mode( v_sua_sca_rec.coo_id,
                                   v_sua_sca_rec.unit_class,v_message_name) = FALSE OR
                               IGS_EN_VAL_SUA.enrp_val_coo_loc( v_sua_sca_rec.coo_id,
                                   v_sua_sca_rec.location_cd,v_message_name) = FALSE OR
                               IGS_EN_VAL_SCA.enrp_val_coo_att(
                                  p_person_id,v_sua_sca_rec.coo_id,v_sua_sca_rec.cal_type,
                                  v_sua_sca_rec.ci_sequence_number,v_message_name,
                                  v_attendance_types,
                                  nvl(p_cal_type,v_sua_sca_rec.cal_type),
                                  nvl(p_ci_sequence_number,v_sua_sca_rec.ci_sequence_number)) = FALSE) THEN
                             v_validation_error := TRUE;
                             v_validation_message_name := 'IGS_EN_UA_NOFAIL_BREACHES_FND';

                          END IF;
                      END IF;

                      IF (v_validation_error) THEN

                          -- if any of the above validations failed or the cutoff date has failed
                          -- then revert to the invalid state of the unit attempt and enter into log
                          OPEN cur_IGS_EN_SU_ATTEMPT(v_sua_sca_rec.unit_cd,v_sua_sca_rec.uoo_id);
                          FETCH cur_IGS_EN_SU_ATTEMPT INTO sua_rec ;
                          CLOSE cur_IGS_EN_SU_ATTEMPT  ;
                          -- Set the status back to invalid
                          /* For the coloumn to be updated,modify the record variable value fetched */
                          sua_rec.unit_attempt_status := 'INVALID';
                          -- Call the API to update the student unit attempt. This API is a
                          -- wrapper to the update row of the TBH.
                          igs_en_sua_api.update_unit_attempt(
                            X_ROWID => sua_rec.ROW_ID,
                            X_PERSON_ID => sua_rec.PERSON_ID,
                            X_COURSE_CD => sua_rec.COURSE_CD,
                            X_UNIT_CD => sua_rec.UNIT_CD,
                            X_CAL_TYPE => sua_rec.CAL_TYPE,
                            X_CI_SEQUENCE_NUMBER => sua_rec.CI_SEQUENCE_NUMBER,
                            X_VERSION_NUMBER => sua_rec.VERSION_NUMBER,
                            X_LOCATION_CD => sua_rec.LOCATION_CD,
                            X_UNIT_CLASS => sua_rec.UNIT_CLASS,
                            X_CI_START_DT => sua_rec.CI_START_DT,
                            X_CI_END_DT => sua_rec.CI_END_DT,
                            X_UOO_ID => sua_rec.UOO_ID,
                            X_ENROLLED_DT => sua_rec.ENROLLED_DT,
                            X_UNIT_ATTEMPT_STATUS => sua_rec.UNIT_ATTEMPT_STATUS,
                            X_ADMINISTRATIVE_UNIT_STATUS => sua_rec.ADMINISTRATIVE_UNIT_STATUS,
                            X_ADMINISTRATIVE_PRIORITY => sua_rec.ADMINISTRATIVE_PRIORITY,
                            X_DISCONTINUED_DT => sua_rec.DISCONTINUED_DT,
                            X_DCNT_REASON_CD  => sua_rec.DCNT_REASON_CD ,
                            X_RULE_WAIVED_DT => sua_rec.RULE_WAIVED_DT,
                            X_RULE_WAIVED_PERSON_ID => sua_rec.RULE_WAIVED_PERSON_ID,
                            X_NO_ASSESSMENT_IND => sua_rec.NO_ASSESSMENT_IND,
                            X_SUP_UNIT_CD => sua_rec.SUP_UNIT_CD,
                            X_SUP_VERSION_NUMBER => sua_rec.SUP_VERSION_NUMBER,
                            X_EXAM_LOCATION_CD => sua_rec.EXAM_LOCATION_CD,
                            X_ALTERNATIVE_TITLE => sua_rec.ALTERNATIVE_TITLE,
                            X_OVERRIDE_ENROLLED_CP => sua_rec.OVERRIDE_ENROLLED_CP,
                            X_OVERRIDE_EFTSU => sua_rec.OVERRIDE_EFTSU,
                            X_OVERRIDE_ACHIEVABLE_CP => sua_rec.OVERRIDE_ACHIEVABLE_CP,
                            X_OVERRIDE_OUTCOME_DUE_DT => sua_rec.OVERRIDE_OUTCOME_DUE_DT,
                            X_OVERRIDE_CREDIT_REASON => sua_rec.OVERRIDE_CREDIT_REASON,
                            X_WAITLIST_DT => sua_rec.waitlist_dt,
                            X_MODE  => 'R' ,
                            --added the new fields for enrollment processes dld
                            X_GS_VERSION_NUMBER => sua_rec.gs_version_number,
                            X_ENR_METHOD_TYPE  => sua_rec.enr_method_type,
                            X_FAILED_UNIT_RULE  => sua_rec.failed_unit_rule,
                            X_CART => sua_rec.CART,
                            X_RSV_SEAT_EXT_ID => sua_rec.RSV_SEAT_EXT_ID ,
                            X_ORG_UNIT_CD => sua_rec.ORG_UNIT_CD,
                            -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                            X_SESSION_ID   => sua_rec.session_id,
                            -- Added the column grading schema as a part pf the bug 2037897. - aiyer
                            X_GRADING_SCHEMA_CODE => sua_rec.GRADING_SCHEMA_CODE,
                            -- Added the column deg_aud_detail_id as part of Degree Audit Interface build (Bug# 2033208)
                            -- by pradhakr
                            X_DEG_AUD_DETAIL_ID   => sua_rec.DEG_AUD_DETAIL_ID,
                            X_SUBTITLE       =>  sua_rec.subtitle,
                            X_STUDENT_CAREER_TRANSCRIPT =>  sua_rec.student_career_transcript,
                            X_STUDENT_CAREER_STATISTICS =>  sua_rec.student_career_statistics,
                            X_ATTRIBUTE_CATEGORY        =>  sua_rec.attribute_category,
                            X_ATTRIBUTE1                =>  sua_rec.attribute1,
                            X_ATTRIBUTE2                =>  sua_rec.attribute2,
                            X_ATTRIBUTE3                =>  sua_rec.attribute3,
                            X_ATTRIBUTE4                =>  sua_rec.attribute4,
                            X_ATTRIBUTE5                =>  sua_rec.attribute5,
                            X_ATTRIBUTE6                =>  sua_rec.attribute6,
                            X_ATTRIBUTE7                =>  sua_rec.attribute7,
                            X_ATTRIBUTE8                =>  sua_rec.attribute8,
                            X_ATTRIBUTE9                =>  sua_rec.attribute9,
                            X_ATTRIBUTE10               =>  sua_rec.attribute10,
                            X_ATTRIBUTE11               =>  sua_rec.attribute11,
                            X_ATTRIBUTE12               =>  sua_rec.attribute12,
                            X_ATTRIBUTE13               =>  sua_rec.attribute13,
                            X_ATTRIBUTE14               =>  sua_rec.attribute14,
                            X_ATTRIBUTE15               =>  sua_rec.attribute15,
                            X_ATTRIBUTE16               =>  sua_rec.attribute16,
                            X_ATTRIBUTE17               =>  sua_rec.attribute17,
                            X_ATTRIBUTE18               =>  sua_rec.attribute18,
                            X_ATTRIBUTE19               =>  sua_rec.attribute19,
                            X_ATTRIBUTE20               =>  sua_rec.attribute20,
                            X_WAITLIST_MANUAL_IND       =>  sua_rec.waitlist_manual_ind ,--Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                            X_WLST_PRIORITY_WEIGHT_NUM  =>  sua_rec.wlst_priority_weight_num,
                            X_WLST_PREFERENCE_WEIGHT_NUM=>  sua_rec.wlst_preference_weight_num,
                             -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
                            X_CORE_INDICATOR_CODE       =>  sua_rec.core_indicator_code
                            ) ;
                          -- If logging is required, then log the change to the passed log
                          IF (p_s_log_type IS NOT NULL AND
                                  p_creation_dt IS NOT NULL) THEN
                             IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                p_s_log_type,
                                p_creation_dt,
                                'WARNING,' || p_person_id || ',' ||
                                p_course_cd ||',' ||
                                 v_sua_sca_rec.unit_cd || ',' ||
                                v_sua_sca_rec.sua_version_number || ',' ||
                                'INVALID,' || v_sua_sca_rec.alternate_code || ',' ||
                                v_sua_sca_rec.location_cd || ',' ||
                                v_sua_sca_rec.unit_class,
                                v_validation_message_name,
                                NULL);

                          END IF;
                          -- the unit attempt has been validated to invalid
                          -- Store unit_cd, cal_type, ci_sequence_number in PL/SQL table
                          r_unit_attempt_rec.rv_uoo_id := v_sua_sca_rec.uoo_id;
                          v_counter := v_counter + 1;
                          t_unit_attempt_tab(v_counter) := r_unit_attempt_rec;
                      ELSE

                      --ie the rules have been passed and no other validation errors
                      --then log an entry that the unit attempt has successfully changed to enrolled
                          IF (p_s_log_type IS NOT NULL AND
                                 p_creation_dt IS NOT NULL) THEN

                             IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                 p_s_log_type,
                                 p_creation_dt,
                                 'INFO,' || p_person_id || ',' ||
                                 p_course_cd ||',' ||
                                 v_sua_sca_rec.unit_cd || ',' ||
                                 v_sua_sca_rec.sua_version_number || ',' ||
                                 'ENROLLED,' || v_sua_sca_rec.alternate_code || ',' ||
                                 v_sua_sca_rec.location_cd || ',' ||
                                 v_sua_sca_rec.unit_class,
                                 'IGS_EN_UA_NOFAIL_CHG_ENROLL',
                                 NULL);

                          END IF;
                          -- added for bug#1832130 enrollment processes dld
                          --since the student unit attempt status has changed from invalid to enrolled
                          --we have to raise a workflow event to send a mail to the student about the status
                          IGS_EN_WORKFLOW.SUA_STATUS_CHANGE_MAIL(sua_rec.UNIT_ATTEMPT_STATUS,
                                      sua_rec.PERSON_ID,sua_rec.UOO_ID);
                      END IF;
                      -- Exit from loop and repeat entire select
                      v_do_cursor_again_ind := TRUE;
                      EXIT;
                  END IF;
              END IF;

              EXCEPTION
               WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
                ROLLBACK TO sp_sua;
                IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_val_bulkrule.enrp_val_sca_urule.enrpl_invalid_to_enrolled.APP_EXP','Application Exception raised with code '||SQLCODE||' and error '||SQLERRM);
                END IF;
                l_message_text := FND_MESSAGE.GET;

                IF l_message_text IS NULL THEN
                   l_message_text := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNEXPECTED_ERR');
                END IF;
                IF (p_s_log_type IS NOT NULL AND
                    p_creation_dt IS NOT NULL) THEN

                    l_log_msg := TRUE;

                    FOR i IN 1..l_counter_failure
                    LOOP
                       r_unit_att_failure_rec := t_unit_att_failure(i);
                       IF (r_unit_att_failure_rec.rv_uoo_id = v_sua_sca_rec.uoo_id) THEN
                          l_log_msg := FALSE;
                       EXIT;
                     END IF;
                    END LOOP;

                    IF l_log_msg = TRUE THEN

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                          p_s_log_type,
                          p_creation_dt,
                          'ERROR,' || p_person_id || ',' ||
                          p_course_cd ||',' ||
                          v_sua_sca_rec.unit_cd || ',' ||
                          v_sua_sca_rec.sua_version_number || ',' ||
                          'INVALID,' || v_sua_sca_rec.alternate_code || ',' ||
                          v_sua_sca_rec.location_cd || ',' ||
                          v_sua_sca_rec.unit_class,
                          NULL,
                          l_message_text);

                          r_unit_att_failure_rec.rv_uoo_id := v_sua_sca_rec.uoo_id;
                          l_counter_failure := l_counter_failure + 1;
                          t_unit_att_failure(l_counter_failure) := r_unit_att_failure_rec;

                    END IF;
                END IF;

               WHEN OTHERS THEN
                ROLLBACK TO sp_sua;
                IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_val_bulkrule.enrp_val_sca_urule.enrpl_invalid_to_enrolled.UNH_EXP','Unhandled Exception raised with code '||SQLCODE||' and error '||SQLERRM);
                END IF;
                l_message_text := FND_MESSAGE.GET;
                IF l_message_text IS NULL THEN
                   l_message_text := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNEXPECTED_ERR');
                END IF;
                IF (p_s_log_type IS NOT NULL AND
                    p_creation_dt IS NOT NULL) THEN

                    l_log_msg := TRUE;

                    FOR i IN 1..l_counter_failure
                    LOOP
                       r_unit_att_failure_rec := t_unit_att_failure(i);
                       IF (r_unit_att_failure_rec.rv_uoo_id = v_sua_sca_rec.uoo_id) THEN
                          l_log_msg := FALSE;
                       EXIT;
                     END IF;
                    END LOOP;

                    IF l_log_msg = TRUE THEN

                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                          p_s_log_type,
                          p_creation_dt,
                          'ERROR,' || p_person_id || ',' ||
                          p_course_cd ||',' ||
                          v_sua_sca_rec.unit_cd || ',' ||
                          v_sua_sca_rec.sua_version_number || ',' ||
                          'INVALID,' || v_sua_sca_rec.alternate_code || ',' ||
                          v_sua_sca_rec.location_cd || ',' ||
                          v_sua_sca_rec.unit_class,
                          NULL,
                          l_message_text);

                          r_unit_att_failure_rec.rv_uoo_id := v_sua_sca_rec.uoo_id;
                          l_counter_failure := l_counter_failure + 1;
                          t_unit_att_failure(l_counter_failure) := r_unit_att_failure_rec;
                    END IF;

                END IF;
             END;

            END LOOP;
            IF (v_do_cursor_again_ind = FALSE) THEN
                EXIT;
            END IF;
          END LOOP;

          IF l_cal_cat = 'TEACHING' THEN
            l_loop_ended := TRUE;
          END IF;
         END LOOP; -- loop for each teach cal of a load.
         IF c_load_to_teach%ISOPEN THEN
           CLOSE c_load_to_teach;
         END IF;

        END;
      END enrpl_invalid_to_enrolled;
        ------------------------------
    BEGIN
        -------------------------------------------------------------------------------
        -- This procedure validates the unit rules for all unit attempts within a
        -- nominated student Course attempt for a nominated academic calendar instance.
        -- It has been designed to accept S_LOG type and creation_dt to enable any
        -- output to be inserted into these. If null, nothing will be logged.
        -------------------------------------------------------------------------------
        -- 1. Select the date fields representing the date after which units cannot be
        -- set to ENROLLED, and the date after which units can not be set to INVALID.
        ------------------------------------------------------------------------------

        OPEN c_secc;
        FETCH c_secc INTO       v_enrolled_rule_cutoff_dt,
                                v_invalid_rule_cutoff_dt;
        IF (c_secc%NOTFOUND) THEN
                CLOSE c_secc;
                RAISE   e_no_records_found;
        END IF;
        CLOSE c_secc;
        -- added this if condition for enrollment processes dld bug#1832130
        --can enroll an invalid unit attempt only when the user passes all rules

        IF (p_rule_to_be_validated= 'ALL' ) THEN
          enrpl_invalid_to_enrolled(
                                p_acad_cal_type,
                                p_acad_sequence_number,
                                p_person_id,
                                p_course_cd,
                                p_s_log_type,
                                p_creation_dt,
                                v_enrolled_rule_cutoff_dt,
                                --added 3 parameters for enrollment processes dld bug#1832130
                                p_cal_type,
                                p_ci_sequence_number,
                                p_org_unit_cd  );
        END IF;
        --validate the passed rule for all enrolled unit attempts and make them
        --invalid if the rule fails
        enrpl_enrolled_to_invalid(
                                p_acad_cal_type,
                                p_acad_sequence_number,
                                p_person_id,
                                p_course_cd,
                                p_s_log_type,
                                p_creation_dt,
                                v_invalid_rule_cutoff_dt,
                                --added 4 parameters for enrollment processes dld bug#1832130
                                p_cal_type ,
                                p_ci_sequence_number,
                                p_org_unit_cd,
                                p_rule_to_be_validated);
   EXCEPTION
        WHEN e_no_records_found THEN
                Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
   END;
  END enrp_val_sca_urule;
END IGS_EN_VAL_BULKRULE;

/
