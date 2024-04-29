--------------------------------------------------------
--  DDL for Package Body IGS_EN_DROP_UNITS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_DROP_UNITS_API" AS
/* $Header: IGSEN92B.pls 120.13 2006/08/24 07:27:08 bdeviset noship $ */

--package variables
g_debug_level               CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


      CURSOR C_SUA_lock (cp_person_id igs_en_su_attempt_all.person_id%TYPE,
                          cp_course_cd igs_en_su_attempt_all.course_cd%TYPE,
                         cp_uoo_id igs_en_su_attempt_all.uoo_id%TYPE) IS
      SELECT unit_attempt_status
      FROM IGS_EN_SU_ATTEMPT_ALL sua
      WHERE person_id = cp_person_id AND
            course_cd = cp_course_cd AND
            uoo_id = cp_uoo_id
      FOR UPDATE NOWAIT;
      l_lock_rec  C_SUA_lock%ROWTYPE;


  FUNCTION is_unit_subordinate(
                               p_person_id        IN igs_en_su_attempt.person_id%TYPE,
                               p_course_cd        IN igs_en_su_attempt.course_cd%TYPE,
                               p_uoo_id           IN igs_en_su_attempt.uoo_id%TYPE,
                               p_drop_alluoo_ids  IN VARCHAR2
                              ) RETURN VARCHAR2 AS

 -------------------------------------------------------------------------------------------
  -- Created by  : Basanth Kumar D, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure checks wheter the passed unit is a subordinate unit or not and
  --           returns the same
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------------

    l_sub_unit VARCHAR2(1);
    l_sup_unitcd           igs_en_su_attempt.sup_unit_cd%TYPE;
    l_sup_version          igs_en_su_attempt.sup_version_number%TYPE;

    TYPE c_ref_cursor IS REF CURSOR;
    c_chk_is_sub c_ref_cursor;


  BEGIN
    --modified sqlquery for bug 5037726,sqlid :14792699
    OPEN c_chk_is_sub FOR
                        'SELECT sua.sup_unit_cd ,sua.sup_version_number
                         FROM igs_en_su_attempt sua
                         WHERE sua.uoo_id =:1
                         AND sua.person_id =:2
                         AND sua.course_cd =:3
                         AND EXISTS
                                    (SELECT ''X'' FROM igs_ps_unit_ofr_opt uoo
                                     WHERE uoo.sup_uoo_id IN (' ||p_drop_alluoo_ids||')
                                     AND uoo.relation_type = ''SUBORDINATE''
                                     AND uoo.uoo_id = sua.uoo_id)' USING p_uoo_id,p_person_id,p_course_cd;

    FETCH c_chk_is_sub INTO l_sup_unitcd, l_sup_version;

    l_sub_unit := 'N';
    IF c_chk_is_sub%FOUND THEN

        l_sub_unit := 'Y';

    END IF;

    CLOSE c_chk_is_sub;

    RETURN l_sub_unit;

  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_DROP_UNITS_API.is_unit_subordinate');
      IGS_GE_MSG_STACK.ADD;
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
            FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_drop_units_api.is_unit_subordinate :',SQLERRM);
      END IF;
      RAISE;
  END is_unit_subordinate;


  PROCEDURE drop_units(
                            p_person_id               IN igs_en_su_attempt.person_id%TYPE,
                            p_course_cd               IN igs_en_su_attempt.course_cd%TYPE,
                            p_course_version          IN igs_en_stdnt_ps_att.version_number%TYPE,
                            p_start_uoo_id            IN NUMBER,
                            p_drop_alluoo_ids         IN VARCHAR2,
                            p_acad_cal_type           IN igs_ca_inst.cal_type%TYPE,
                            p_acad_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                            p_load_cal_type           IN igs_ca_inst.cal_type%TYPE,
                            p_load_sequence_number    IN igs_ca_inst.sequence_number%TYPE,
                            p_enr_cat                 IN igs_ps_type.enrolment_cat%TYPE,
                            p_enr_comm                IN VARCHAR2,
                            p_enr_meth_type           IN igs_en_method_type.enr_method_type%TYPE,
                            p_dcnt_reason_cd          IN igs_en_dcnt_reasoncd.discontinuation_reason_cd%TYPE,
                            p_admin_unit_status       IN VARCHAR2,
                            p_effective_date          IN DATE,
                            p_deny_warn_coreq         IN VARCHAR2,
                            p_deny_warn_prereq        IN VARCHAR2,
                            p_deny_warn_min_cp        IN VARCHAR2,
                            p_deny_warn_att_type      IN VARCHAR2,
			    p_deny_warn_core	      IN VARCHAR2,
                            p_failed_uoo_ids          OUT NOCOPY VARCHAR2,
                            p_message                 OUT NOCOPY VARCHAR2,
                            p_return_status           OUT NOCOPY VARCHAR2) AS


 -------------------------------------------------------------------------------------------
  -- Created by  : Basanth Kumar D, Oracle Student Systems Oracle IDC
  -- Purpose : This proceduere makes min credit,forced att type
  --           coreq and prereq checks.If it fails the check then a record
  --           is created in warnings table with message as either deny or warn
  --           depending on the setup of check and drops the units.Incase of prereq/coreq the
  --           units that failed the validation  after dropping the units to be dropped
  --           are passed back as failed units which are dropped in the next iteration of
  --           the loop.
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------------


    TYPE c_ref_cursor IS REF CURSOR;
    c_ref_cur_coreq_prereq c_ref_cursor;
    v_ref_cur_rec igs_en_su_attempt%ROWTYPE;

    l_drop_alluoo_ids           VARCHAR2(1000);
    l_message                   VARCHAR2(200);
    l_eftsu_total               igs_en_su_attempt.override_eftsu%TYPE;
    l_credit_points             igs_en_su_attempt.override_enrolled_cp%TYPE;
    l_total_credit_points       igs_en_su_attempt.override_enrolled_cp%TYPE;

    l_coreq_failed_uoo_ids      VARCHAR2(1000);
    l_prereq_failed_uoo_ids     VARCHAR2(1000);

    l_message_name              VARCHAR2(50);

    l_att_typ_failed            BOOLEAN;
    l_uoo_id                    igs_en_su_attempt.uoo_id%TYPE;
    l_sub_unit                  VARCHAR2(1);

      -- cursor to get unit details
    CURSOR get_unit_dtls (p_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
    SELECT unit_cd||'/'||unit_class unit_det
    FROM igs_ps_unit_ofr_opt
    WHERE uoo_id = p_uoo_id ;

    l_unit_rec                  get_unit_dtls%ROWTYPE;
    l_message_icon              VARCHAR2(10);
    l_rul_text                  VARCHAR2(2000);

    lv_message_name             VARCHAR2(50);
    lv_message_name2            VARCHAR2(50);
    lv_return_type              VARCHAR2(50);
    l_message_for               VARCHAR2(100);
    -- bmerugu added for core drop
    l_deny_warn_core		VARCHAR2(10);


    NO_AUSL_RECORD_FOUND EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_AUSL_RECORD_FOUND , -20010);

  BEGIN

     -- cursor to get all uooids with enrolled,invalid status and not in dropped list
     --modified sqlquery for bug 5037726,sqlid : 14792726
            OPEN  c_ref_cur_coreq_prereq FOR
                             'SELECT U.* FROM  IGS_EN_SU_ATTEMPT U, IGS_CA_LOAD_TO_TEACH_V V
                              WHERE U.person_id = :1
                              AND U.course_cd = :2
                              AND U.unit_attempt_status IN  (''ENROLLED'',''INVALID'')
                              AND U.uoo_id NOT IN ('||p_drop_alluoo_ids||')
                              AND U.cal_type = V.teach_cal_type
                              AND U.ci_sequence_number = V.teach_ci_sequence_number
                              AND V.load_cal_type = :3
                              AND V.load_ci_sequence_number = :4'
                              USING p_person_id,p_course_cd,p_load_cal_type,p_load_sequence_number;
        LOOP
        -- Loop to get the units failing coreq and prereq validation s vefore dropping the units
        FETCH c_ref_cur_coreq_prereq INTO v_ref_cur_rec ;

        EXIT WHEN c_ref_cur_coreq_prereq%NOTFOUND;

        l_message   := NULL;
        IF p_deny_warn_coreq IS NOT NULL AND NOT
          IGS_EN_ELGBL_UNIT.eval_coreq(
                                        p_person_id                =>  p_person_id,
                                        p_load_cal_type            =>  p_load_cal_type,
                                        p_load_sequence_number     =>  p_load_sequence_number,
                                        p_uoo_id                   =>  v_ref_cur_rec.uoo_id,
                                        p_course_cd                =>  p_course_cd,
                                        p_course_version           =>  p_course_version,
                                        p_message                  =>  l_message,
                                        p_deny_warn                =>  p_deny_warn_coreq,
                                        p_calling_obj              => 'DROP') THEN

--            l_coreq_failed_units  := l_coreq_failed_units || ',' || v_ref_cur_rec.unit_cd;
            IF l_coreq_failed_uoo_ids IS NOT NULL THEN
              l_coreq_failed_uoo_ids := l_coreq_failed_uoo_ids  ||','|| TO_CHAR(v_ref_cur_rec.uoo_id);
            ELSE
              l_coreq_failed_uoo_ids := TO_CHAR(v_ref_cur_rec.uoo_id);
            END IF;

        END IF;

        l_message   := NULL;
        IF p_deny_warn_prereq IS NOT NULL AND NOT
          IGS_EN_ELGBL_UNIT.eval_prereq(
                                            p_person_id                =>  p_person_id,
                                            p_load_cal_type            =>  p_load_cal_type,
                                            p_load_sequence_number     =>  p_load_sequence_number,
                                            p_uoo_id                   =>  v_ref_cur_rec.uoo_id,
                                            p_course_cd                =>  p_course_cd,
                                            p_course_version           =>  p_course_version,
                                            p_message                  =>  l_message,
                                            p_deny_warn                =>  p_deny_warn_prereq,
                                            p_calling_obj              =>  'DROP') THEN

--          l_prereq_failed_units  := l_prereq_failed_units || ',' ||  v_ref_cur_rec.uoo_id;
          IF l_prereq_failed_uoo_ids IS NOT NULL THEN
            l_prereq_failed_uoo_ids := l_prereq_failed_uoo_ids||','||TO_CHAR(v_ref_cur_rec.uoo_id);
          ELSE
            l_prereq_failed_uoo_ids := TO_CHAR(v_ref_cur_rec.uoo_id);
          END IF;


        END IF;

      END LOOP;

      CLOSE c_ref_cur_coreq_prereq;

      l_drop_alluoo_ids := p_drop_alluoo_ids;
      WHILE l_drop_alluoo_ids IS NOT NULL LOOP

      l_credit_points := 0;

      --Check if unit is subordinate and superior is in selection , then   set the l_sub_param to Y
      --Perform Min CP validation if step is defined. To do this, get the eftsu total before the unit is dropped.

        --extract the uoo_id
        IF(instr(l_drop_alluoo_ids,',',1) = 0) THEN

          l_uoo_id :=TO_NUMBER(l_drop_alluoo_ids);

        ELSE

          l_uoo_id := TO_NUMBER(substr(l_drop_alluoo_ids,0,instr(l_drop_alluoo_ids,',',1)-1)) ;

        END IF;

        --   Remove the  uoo_id to be  processed
        IF(instr(l_drop_alluoo_ids,',',1) = 0) THEN

          l_drop_alluoo_ids := NULL;

        ELSE

          l_drop_alluoo_ids :=   substr(l_drop_alluoo_ids,instr(l_drop_alluoo_ids,',',1)+1);

        END IF; -- end of IF(instr(l_drop_alluoo_ids,',',1) = 0)

              -- smaddali added this cursor to lock the row , bug#4864437
              OPEN C_SUA_lock (p_person_id,p_course_cd,l_uoo_id);
              FETCH C_SUA_lock INTO l_lock_rec;
              CLOSE C_SUA_lock;


        l_sub_unit := is_unit_subordinate(p_person_id,
                                          p_course_cd,
                                          l_uoo_id,
                                          p_drop_alluoo_ids);

        IF p_deny_warn_min_cp  IS NOT NULL THEN

          l_eftsu_total := igs_en_prc_load.enrp_clc_eftsu_total(
                                                p_person_id             => p_person_id,
                                                p_course_cd             => p_course_cd ,
                                                p_acad_cal_type         => p_acad_cal_type,
                                                p_acad_sequence_number  => p_acad_ci_sequence_number,
                                                p_load_cal_type         => p_load_cal_type,
                                                p_load_sequence_number  => p_load_sequence_number,
                                                p_truncate_ind          => 'N',
                                                p_include_research_ind  => 'Y'  ,
                                                p_key_course_cd         => NULL ,
                                                p_key_version_number    => NULL ,
                                                p_credit_points         => l_total_credit_points
                                                );

        END IF;

	--bmerugu added for core drop
	--Evaluate the Allow Core Drop step if setup. If Core Drop fails set the warning message depending on whether the step is deny or warn.  If step is deny, then return.
        l_message   := NULL;
        IF p_deny_warn_core  IS NOT NULL AND
           igs_en_gen_015.eval_core_unit_drop
                       (
			    p_person_id               => p_person_id,
			    p_course_cd               => p_course_cd,
			    p_uoo_id                  => l_uoo_id,
			    p_step_type               => 'DROP_CORE',
			    p_term_cal                => p_load_cal_type,
			    p_term_sequence_number    => p_load_sequence_number,
			    p_deny_warn               => l_deny_warn_core,
			    p_enr_method	      => null) = 'FALSE' THEN

	   OPEN get_unit_dtls(l_uoo_id);
	   FETCH get_unit_dtls INTO l_unit_rec;
	   CLOSE get_unit_dtls;
	  IF l_deny_warn_core = 'DENY' THEN

            --Set the message IGS_EN_NO_CORE_REM_CRT and return status to error and return.
            p_message := 'IGS_EN_SS_SWP_DEL_CORE_FAIL*' || l_unit_rec.unit_det;
            p_return_status := 'E';
            RETURN;

          ELSIF l_deny_warn_core = 'WARN' THEN
	    --create a warning record with message_icon set to "W" IGS_EN_NO_CORE_REM_CRT
            igs_en_drop_units_api.create_ss_warning(
                                     p_person_id      => p_person_id,
                                     p_course_cd      => p_course_cd,
                                     p_term_cal_type  => p_load_cal_type,
                                     p_term_ci_sequence_number => p_load_sequence_number,
                                     p_uoo_id => p_start_uoo_id, -- the original unit attempt which started the drop
                                     p_message_for =>  l_unit_rec.unit_det,
                                     p_message_icon=> 'W',
                                     p_message_name => 'IGS_EN_PRCD_DROP_CORE_PAGE',
                                     p_message_rule_text => NULL,
                                     p_message_tokens => NULL,
                                     p_message_action=> NULL,
                                     p_destination => NULL,
                                     p_parameters => NULL, --the subordinate for which the warning is created
                                     p_step_type =>'DROP'
                                                    );

          END IF; -- l_deny_warn_core

        END IF; -- IF l_deny_warn_CORE  IS NOT NULL

        -- Drop the Unit
        igs_en_gen_004.enrp_dropall_unit(
                                        p_person_id          => p_person_id,
                                        p_cal_type           => p_load_cal_type,
                                        p_ci_sequence_number => p_load_sequence_number,
                                        p_dcnt_reason_cd     => p_dcnt_reason_cd,
                                        p_admin_unit_sta     => p_admin_unit_status,
                                        p_effective_date     => p_effective_date,
                                        p_program_cd         => p_course_cd,
                                        p_uoo_id             => l_uoo_id,
                                        p_sub_unit           => l_sub_unit
                                        );

        --Evaluate the Min CP step if setup. Pass the eftsu calculated in step 2. If Min CP fails set the warning message depending on whether the step is deny or warn.  If step is deny, then return.
        l_message   := NULL;
        IF p_deny_warn_min_cp  IS NOT NULL AND
           NOT igs_en_elgbl_program.eval_min_cp(
                                                p_person_id                 =>  p_person_id,
                                                p_load_calendar_type        =>  p_load_cal_type,
                                                p_load_cal_sequence_number  =>  p_load_sequence_number,
                                                p_uoo_id                    =>  l_uoo_id,
                                                p_program_cd                =>  p_course_cd,
                                                p_program_version           =>  p_course_version,
                                                p_message                   =>  l_message,
                                                p_deny_warn                 =>  p_deny_warn_min_cp,
                                                p_credit_points             =>  l_credit_points ,
                                                p_enrollment_category       =>  p_enr_cat,
                                                p_comm_type                 =>  p_enr_comm,
                                                p_method_type               =>  p_enr_meth_type,
                                                p_min_credit_point          =>  l_total_credit_points,
                                                p_calling_obj               =>  'DROP') THEN

          IF p_deny_warn_min_cp = 'DENY' THEN

            --Set the message IGS_SS_EN_MINIMUM_CP_DENY and return status to error and return.
            p_message := 'IGS_SS_EN_MINIMUM_CP_DENY';
            p_return_status := 'E';
            RETURN;

          ELSIF p_deny_warn_min_cp = 'WARN' THEN

            l_message_for := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                p_lookup_code => 'FMIN_CRDT',
                                                p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT');
            --create a warning record with message_icon set to "W" IGS_SS_EN_MINIMUM_CP_WARN
            igs_en_drop_units_api.create_ss_warning(
                                     p_person_id      => p_person_id,
                                     p_course_cd      => p_course_cd,
                                     p_term_cal_type  => p_load_cal_type,
                                     p_term_ci_sequence_number => p_load_sequence_number,
                                     p_uoo_id => p_start_uoo_id, -- the original unit attempt which started the drop
                                     p_message_for =>  l_message_for,
                                     p_message_icon=> 'W',
                                     p_message_name => 'IGS_SS_EN_MINIMUM_CP_WARN',
                                     p_message_rule_text => NULL,
                                     p_message_tokens => NULL,
                                     p_message_action=> NULL,
                                     p_destination => NULL,
                                     p_parameters => NULL, --the subordinate for which the warning is created
                                     p_step_type =>'DROP'
                                                    );

          END IF; -- l_deny_warn_min_cp

        END IF; -- IF l_deny_warn_min_cp  IS NOT NULL

       -- If the Attendance Type validation step has been setup, evaluate the same.
        l_message   := NULL;
        IF  p_deny_warn_att_type IS NOT NULL AND
          NOT igs_en_elgbl_program.eval_unit_forced_type(
                                                         p_person_id                 => p_person_id,
                                                         p_load_calendar_type        => p_load_cal_type,
                                                         p_load_cal_sequence_number  => p_load_sequence_number,
                                                         p_uoo_id                    => l_uoo_id          ,
                                                         p_course_cd                 => p_course_cd,
                                                         p_course_version            => p_course_version,
                                                         p_message                   => l_message,
                                                         p_deny_warn                 => p_deny_warn_att_type ,
                                                         p_enrollment_category       => p_enr_cat,
                                                         p_comm_type                 => p_enr_comm,
                                                         p_method_type               => p_enr_meth_type,
                                                         p_calling_obj               =>  'DROP')  THEN

          l_att_typ_failed := TRUE;

            IF l_message  = 'IGS_SS_EN_ATT_TYP_DENY' THEN
            -- Set the message IGS_SS_EN_ATT_TYP_DENY and return status and return.
              p_message := 'IGS_SS_EN_ATT_TYP_DENY';
              p_return_status := 'E';

              RETURN;
            ELSIF l_message  = 'IGS_SS_EN_ATT_TYP_WARN' THEN

             l_message_for := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                    p_lookup_code => 'FATD_TYPE',
                                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT');
            -- Set message to IGS_SS_EN_ATT_TYP_WARN
            --  Create a warnign record in the warnings table with message_icon as "WARN" , message_for as the lookup_code of the step.
            --create a warning record with message_icon set to "W" IGS_SS_EN_MINIMUM_CP_WARN
             igs_en_drop_units_api.create_ss_warning(
                                 p_person_id      => p_person_id,
                                 p_course_cd      => p_course_cd,
                                 p_term_cal_type  => p_load_cal_type,
                                 p_term_ci_sequence_number => p_load_sequence_number,
                                 p_uoo_id => p_start_uoo_id, -- the original unit attempt which started the drop
                                 p_message_for =>  l_message_for,
                                 p_message_icon=> 'W',
                                 p_message_name => l_message,
                                 p_message_rule_text => NULL,
                                 p_message_tokens => NULL,
                                 p_message_action=> NULL,
                                 p_destination => NULL,
                                 p_parameters => NULL, --the subordinate for which the warning is created
                                 p_step_type =>'DROP'
                                        );

           END IF;

        END IF ; -- IF l_all_units_for_drop

      END LOOP; --end of WHILE l_drop_alluoo_ids LOOP
      --modified sqlquery for bug 5037726,sql id :14792727
      OPEN  c_ref_cur_coreq_prereq FOR
      'SELECT U.* FROM  IGS_EN_SU_ATTEMPT U, igs_ca_load_to_teach_v V
       WHERE U.person_id  = :1
       AND U.course_cd = :2
       AND U.unit_attempt_status IN  (''ENROLLED'',''INVALID'')
       AND U.uoo_id NOT IN ('||p_drop_alluoo_ids||')
       AND U.cal_type = V.teach_cal_type
       AND U.ci_sequence_number= V.teach_ci_sequence_number
       AND V.load_cal_type = :3
       AND V.load_ci_sequence_number =  :4'
       USING p_person_id, p_course_cd,p_load_cal_type,p_load_sequence_number;

      LOOP

        FETCH c_ref_cur_coreq_prereq INTO v_ref_cur_rec ;
        EXIT WHEN c_ref_cur_coreq_prereq%NOTFOUND;
        l_rul_text     := NULL;
        l_message_name := NULL;

        IF p_deny_warn_coreq IS NOT NULL AND NOT
        IGS_EN_ELGBL_UNIT.eval_coreq(
                                    p_person_id                =>  p_person_id,
                                    p_load_cal_type            =>  p_load_cal_type,
                                    p_load_sequence_number     =>  p_load_sequence_number,
                                    p_uoo_id                   =>  v_ref_cur_rec.uoo_id,
                                    p_course_cd                =>  p_course_cd,
                                    p_course_version           =>  p_course_version,
                                    p_message                  =>  l_rul_text, -- rule text is returned
                                    p_deny_warn                =>  p_deny_warn_coreq,
                                    p_calling_obj              =>   'DROP') THEN

          --Check if the coreq step is set to deny or warn .
          IF  (l_coreq_failed_uoo_ids IS NULL OR  INSTR(','||l_coreq_failed_uoo_ids||',' , ','||v_ref_cur_rec.uoo_id||',') = 0) THEN

            IF p_deny_warn_coreq = 'DENY' THEN

              l_message_icon := 'D';
              l_message_name := 'IGS_SS_EN_COREQ_DRP_DENY';

              IF  p_failed_uoo_ids IS NOT NULL THEN

                p_failed_uoo_ids      := p_failed_uoo_ids  ||','|| TO_CHAR(v_ref_cur_rec.uoo_id);

              ELSE

                p_failed_uoo_ids      :=  TO_CHAR(v_ref_cur_rec.uoo_id);

              END IF;

            ELSIF p_deny_warn_coreq = 'WARN' THEN

              l_message_icon := 'W';
              l_message_name := 'IGS_SS_EN_COREQ_DRP_WARN';

            END IF;


            OPEN get_unit_dtls(v_ref_cur_rec.uoo_id);
            FETCH get_unit_dtls INTO l_unit_rec;
            CLOSE get_unit_dtls;

            igs_en_drop_units_api.create_ss_warning(
                            p_person_id => p_person_id,
                            p_course_cd => p_course_cd,
                            p_Term_cal_type=>p_load_cal_type,
                            p_term_ci_sequence_number => p_load_sequence_number,
                            p_uoo_id => p_start_uoo_id,
                            p_message_for => l_unit_rec.unit_det,
                            p_message_icon=> l_message_icon,
                            p_message_name =>l_message_name,
                            p_message_tokens=> NULL,
                            p_message_rule_text => l_rul_text,
                            p_message_action=> NULL,
                            p_destination => NULL,
                            p_parameters => v_ref_cur_rec.uoo_id,--uoo_id of the unit for which the warnign record is being created null
                            p_step_type =>'DROP');
          END IF; -- end of  IF  (l_coreq_failed_uoo_ids IS NULL

        END IF; -- end of IF l_deny_warn_coreq IS NOT NULL


        -- Do the same checks for Pre-Req rule

         l_rul_text     := NULL;
         l_message_name := NULL;

        IF p_deny_warn_prereq IS NOT NULL AND
           NOT IGS_EN_ELGBL_UNIT.eval_prereq(
                                    p_person_id                =>  p_person_id,
                                    p_load_cal_type            =>  p_load_cal_type,
                                    p_load_sequence_number     =>  p_load_sequence_number,
                                    p_uoo_id                   =>  v_ref_cur_rec.uoo_id,
                                    p_course_cd                =>  p_course_cd,
                                    p_course_version           =>  p_course_version,
                                    p_message                  =>  l_rul_text,  -- rule text is returned
                                    p_deny_warn                =>  p_deny_warn_prereq,
                                    p_calling_obj              =>  'DROP') THEN

          -- Append to failed uoo_ids if step is set to deny.
          IF   (l_prereq_failed_uoo_ids IS NULL OR INSTR(','||l_prereq_failed_uoo_ids||',' , ','||v_ref_cur_rec.uoo_id||',' ) = 0) THEN

            IF p_deny_warn_prereq = 'DENY' THEN

              l_message_icon := 'D';
              l_message_name := 'IGS_SS_EN_PREREQ_DRP_DENY';

              IF  p_failed_uoo_ids IS NOT NULL THEN

                p_failed_uoo_ids      := p_failed_uoo_ids  ||','|| TO_CHAR(v_ref_cur_rec.uoo_id);

              ELSE

                p_failed_uoo_ids      :=  TO_CHAR(v_ref_cur_rec.uoo_id);

              END IF;

            ELSE

              l_message_icon := 'W';
              l_message_name := 'IGS_SS_EN_PREREQ_DRP_WARN';

            END IF;


            OPEN get_unit_dtls(v_ref_cur_rec.uoo_id);
            FETCH get_unit_dtls INTO l_unit_rec;
            CLOSE get_unit_dtls;

            -- Create the warning record.
              igs_en_drop_units_api.create_ss_warning(
                                            p_person_id => p_person_id,
                                            p_course_cd => p_course_cd,
                                            p_Term_cal_type=>p_load_cal_type,
                                            p_term_ci_sequence_number => p_load_sequence_number,
                                            p_uoo_id => p_start_uoo_id,
                                            p_message_for => l_unit_rec.unit_det,
                                            p_message_icon=> l_message_icon,
                                            p_message_name =>l_message_name,
                                            p_message_tokens=> NULL,
                                            p_message_rule_text => l_rul_text,
                                            p_message_action=> NULL,
                                            p_destination => NULL,
                                            p_parameters => v_ref_cur_rec.uoo_id,--uoo_id of the unit for which the warnign record is being created null
                                            p_step_type =>'DROP');
          END IF; -- IF   (l_prereq_failed_uoo_ids IS NULL

        END IF; -- IF l_deny_warn_prereq IS NOT NULL

      END LOOP; -- end of loop for cursor c_ref_cur_coreq_prereq

      CLOSE c_ref_cur_coreq_prereq;

      --Now implement the encumbrance checks for required untis.
      IF NOT IGS_EN_VAL_ENCMB.enrp_val_enr_encmb(p_person_id => p_person_id,
                                         p_course_cd => p_course_cd,
                                         p_cal_type => p_load_cal_type,
                                         p_ci_sequence_number => p_load_sequence_number,
                                         p_message_name => lv_message_name ,
                                         p_message_name2 => lv_message_name2,
                                         p_return_type => lv_return_type,
                                         p_effective_dt => NULL -- default value, it will be calculated internally based on the census date
                                         )   THEN

       -- Check for the messages returned by this function in lv_message_name and lv_message_name2. If these messages relate to the required units check then overwrite these messages with messages that have been defined for self service diplay.

        IF  lv_message_name = 'IGS_EN_PRSN_NOTENR_REQUIRE' OR lv_message_name2 = 'IGS_EN_PRSN_NOTENR_REQUIRE' THEN

        -- Override message with 'IGS_EN_REQ_UNIT_CANNOT_DROP'
          p_message := 'IGS_EN_REQ_UNIT_CANNOT_DROP';
        END IF;

        p_return_status := 'E';
        RETURN;

      END IF; -- end of IF NOT IGS_EN_VAL_ENCMB.enrp_val_enr_encmb

  EXCEPTION

    -- To handle user defined exception raised when adminstrative unit status cannot be detremined
    WHEN NO_AUSL_RECORD_FOUND THEN
      RAISE NO_AUSL_RECORD_FOUND;

    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      RAISE;

    WHEN OTHERS THEN

      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_DROP_UNITS_API.drop_units');
      IGS_GE_MSG_STACK.ADD;
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
            FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_drop_units_api.drop_units :',SQLERRM);
      END IF;
      RAISE;

  END drop_units ;



  PROCEDURE drop_student_unit_attempts(
                                     p_person_id              IN igs_en_su_attempt.person_id%TYPE,
                                     p_course_cd              IN igs_en_su_attempt.course_cd%TYPE,
                                     p_course_version         IN igs_en_stdnt_ps_att.version_number%TYPE,
                                     p_start_uoo_id           IN NUMBER,
                                     p_drop_uoo_ids           IN VARCHAR2,
                                     p_acad_cal_type          IN igs_ca_inst.cal_type%TYPE,
                                     p_acad_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                                     p_load_cal_type          IN igs_ca_inst.cal_type%TYPE,
                                     p_load_sequence_number   IN igs_ca_inst.sequence_number%TYPE,
                                     p_enr_cat                IN igs_ps_type.enrolment_cat%TYPE,
                                     p_enr_comm               IN VARCHAR2,
                                     p_enr_meth_type          IN igs_en_method_type.enr_method_type%TYPE,
                                     p_dcnt_reason_cd         IN igs_en_dcnt_reasoncd.discontinuation_reason_cd%TYPE,
                                     p_admin_unit_status      IN VARCHAR2,
                                     p_effective_date         IN DATE,
                                     p_deny_warn_coreq        IN VARCHAR2,
                                     p_deny_warn_prereq       IN VARCHAR2,
                                     p_deny_warn_min_cp       IN VARCHAR2,
                                     p_deny_warn_att_type     IN VARCHAR2,
				     p_deny_warn_core	      IN VARCHAR2,
                                     p_failed_uoo_ids         OUT NOCOPY VARCHAR2,
                                     p_uooids_dropped         OUT NOCOPY VARCHAR2,
                                     p_message                OUT NOCOPY VARCHAR2,
                                     p_return_status          OUT NOCOPY VARCHAR2) AS

  -------------------------------------------------------------------------------------------
  -- Created by  : Basanth Kumar D, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure reorders the units with subordantes first
  --  and cheks whether all units in enrolled,waitlisted and invalid are to be dropped
  --  or apart from duplicates all the units are to be dropped then  just drop the units
  --  without making any validations else call drop units which validates and drops
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------------



    l_drop_alluoo_ids   VARCHAR2(1000);
    l_sub_drop_uoo_ids  VARCHAR2(1000);
    l_nonsub_uoo_ids    VARCHAR2(1000);

    TYPE c_ref_cursor IS REF CURSOR;
    c_chk_units c_ref_cursor;
    c_ref_only_dup c_ref_cursor;
    c_chk_is_sub c_ref_cursor;
    v_ref_cur_rec igs_en_su_attempt%ROWTYPE;

    l_all_units_for_drop BOOLEAN;

    l_credit_points        igs_en_su_attempt.override_enrolled_cp%TYPE;
    l_uoo_id               igs_en_su_attempt.uoo_id%TYPE;
    l_sub_unit             VARCHAR2(1);

    l_enc_message_name              VARCHAR2(2000);
    l_app_short_name                VARCHAR2(100);
    l_msg_index                     NUMBER;
    l_message_name                  VARCHAR2(4000);

    NO_AUSL_RECORD_FOUND EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_AUSL_RECORD_FOUND , -20010);

  BEGIN

    l_credit_points := 0;
    igs_en_drop_units_api.reorder_drop_units (
                                                    p_person_id => p_person_id ,
                                                    p_course_cd => p_course_cd,
                                                    p_start_uoo_id => p_start_uoo_id,
                                                    p_load_cal_type => p_load_cal_type,
                                                    p_load_ci_seq_num => p_load_sequence_number,
                                                    p_selected_uoo_ids => p_drop_uoo_ids,  ---  uooids that are to be dropped
                                                    p_ret_all_uoo_ids => l_drop_alluoo_ids, -- uooids that are to be dropping after adding subordinate units
                                                    p_ret_sub_uoo_ids => l_sub_drop_uoo_ids, -- retunrs the subordinate uooids if any in the uooids to be dropped
                                                    p_ret_nonsub_uoo_ids => l_nonsub_uoo_ids
                                                    );
    -- assign the uooids to be dropped to the out parameter
    p_uooids_dropped := l_drop_alluoo_ids;

    -- check whether all enrolled,invalid,wsitlisted units for that person,course are selected,
    --in which case, just delete all units w/o checking cp or coreq requirements.
    --modified sqlquery for bug 5037726 ,sql id :14792729

    OPEN c_chk_units FOR
                            'SELECT U.* FROM IGS_EN_SU_ATTEMPT U
                             WHERE person_id =:1
                             AND course_cd = :2
                             AND unit_attempt_status IN  (''ENROLLED'',''INVALID'',''WAITLISTED'')
                             AND (cal_type,ci_sequence_number) IN
                                                                  (SELECT teach_cal_type,teach_ci_sequence_number
                                                                   FROM igs_ca_load_to_teach_v
                                                                   WHERE load_cal_type = :3
                                                                   AND load_ci_sequence_number =:4 )
                                                                   AND uoo_id NOT IN('||l_drop_alluoo_ids||')'
                             USING p_person_id, p_course_cd, p_load_cal_type, p_load_sequence_number ;

    FETCH c_chk_units INTO v_ref_cur_rec ;

    l_all_units_for_drop := FALSE;
    IF c_chk_units%NOTFOUND THEN

        l_all_units_for_drop := TRUE;

    END IF;
    CLOSE c_chk_units;


    IF NOT l_all_units_for_drop THEN
      -- Even if all unit attempts except duplicates are selected for drop then do
      -- not perform any validations. So that we do not get any min cp or
      -- attendance type validation fialures.
      --modified sqlquery for bug 5037726
      OPEN c_ref_only_dup FOR
                              'SELECT U.* FROM  IGS_EN_SU_ATTEMPT U
                               WHERE person_id =:1
                               AND course_cd = :2
                               AND unit_attempt_status <> ''DUPLICATE''
                               AND (cal_type,ci_sequence_number) IN
                                                                    (SELECT teach_cal_type,teach_ci_sequence_number
                                                                     FROM igs_ca_load_to_teach_v
                                                                     WHERE load_cal_type = :3
                                                                     AND load_ci_sequence_number =:4 )
                               AND uoo_id IN('||l_drop_alluoo_ids||')'
                               USING p_person_id, p_course_cd, p_load_cal_type, p_load_sequence_number;
      FETCH c_ref_only_dup INTO v_ref_cur_rec ;

      l_all_units_for_drop := FALSE;
      IF c_ref_only_dup%NOTFOUND THEN

        -- except duplicates units all other units are selected for drop
        l_all_units_for_drop := TRUE;

      END IF;

      CLOSE c_ref_only_dup;

    END IF; -- end of IF NOT l_all_units_for_drop

    -- if only duplicates are not selected for drop the drop without any validations
    IF l_all_units_for_drop THEN

      WHILE l_drop_alluoo_ids IS NOT NULL LOOP

        l_credit_points := 0;

        --extract the uoo_id
        IF(instr(l_drop_alluoo_ids,',',1) = 0) THEN

          l_uoo_id :=TO_NUMBER(l_drop_alluoo_ids);

        ELSE

          l_uoo_id := TO_NUMBER(substr(l_drop_alluoo_ids,0,instr(l_drop_alluoo_ids,',',1)-1)) ;

        END IF;

        --   Remove the  uoo_id that will be processed
        IF(instr(l_drop_alluoo_ids,',',1) = 0) THEN

          l_drop_alluoo_ids := NULL;

        ELSE

          l_drop_alluoo_ids :=   substr(l_drop_alluoo_ids,instr(l_drop_alluoo_ids,',',1)+1);

        END IF; -- end of IF(instr(l_drop_alluoo_ids,',',1) = 0)

          -- smaddali added this cursor to lock the row , bug#4864437
          OPEN C_SUA_lock (p_person_id,p_course_cd,l_uoo_id);
          FETCH C_SUA_lock INTO l_lock_rec;
          CLOSE C_SUA_lock;

        -- Set the parameter to  indicate if unit is subordinate
        l_sub_unit := 'N';

        IF l_sub_drop_uoo_ids IS NOT NULL THEN

          l_sub_unit := is_unit_subordinate(p_person_id,
                                            p_course_cd,
                                            l_uoo_id,
                                            p_uooids_dropped);    -- use the entire set uooids that will be dropped


        END IF;   -- end of IF l_sub_drop_uoo_ids IS NOT NULL

        igs_en_gen_004.enrp_dropall_unit(
                                                 p_person_id          => p_person_id,
                                                 p_cal_type           => p_load_cal_type,
                                                 p_ci_sequence_number => p_load_sequence_number,
                                                 p_dcnt_reason_cd     => p_dcnt_reason_cd,
                                                 p_admin_unit_sta     => p_admin_unit_status,
                                                 p_effective_date     => p_effective_date,
                                                 p_program_cd         => p_course_cd,
                                                 p_uoo_id             => l_uoo_id,
                                                 p_sub_unit           => l_sub_unit);


      END LOOP; -- end of loop

    -- if not all the enrolled,invalid,wailsited units are not in list of units to be dropped or
    -- apart from duplicate units their are units which are not their in list of dropped units
    -- then validate prereq,coreq,min_cp,forced att type and if successful then drop units
    ELSE


      drop_units(
                p_person_id,
                p_course_cd,
                p_course_version,
                p_start_uoo_id,
                l_drop_alluoo_ids,
                p_acad_cal_type,
                p_acad_ci_sequence_number,
                p_load_cal_type,
                p_load_sequence_number,
                p_enr_cat,
                p_enr_comm,
                p_enr_meth_type,
                p_dcnt_reason_cd,
                p_admin_unit_status,
                p_effective_date,
                p_deny_warn_coreq,
                p_deny_warn_prereq,
                p_deny_warn_min_cp,
                p_deny_warn_att_type,
		p_deny_warn_core,
                p_failed_uoo_ids,
                p_message,
                p_return_status);

        IF p_return_status = 'E' THEN

          RETURN;

        END IF;



    END IF;  -- end of  IF l_all_units_for_drop THEN


  EXCEPTION

    -- To handle user defined exception raised when adminstrative unit status cannot be detremined
    WHEN NO_AUSL_RECORD_FOUND THEN
      RAISE NO_AUSL_RECORD_FOUND;

    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      RAISE;

    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_DROP_UNITS_API.drop_student_unit_attempts');
      IGS_GE_MSG_STACK.ADD;
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
            FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_drop_units_api.drop_student_unit_attempts :',SQLERRM);
      END IF;
      RAISE;

  END drop_student_unit_attempts;


  PROCEDURE reorder_drop_units(
                                 p_person_id            IN igs_en_su_attempt.person_id%TYPE,
                                 p_course_cd            IN igs_en_su_attempt.course_cd%TYPE,
                                 p_start_uoo_id         IN igs_en_su_attempt.uoo_id%TYPE,
                                 p_load_cal_type        IN igs_ca_inst.cal_type%TYPE,
                                 p_load_ci_seq_num      IN igs_ca_inst.sequence_number%TYPE,
                                 p_selected_uoo_ids     IN VARCHAR2,
                                 p_ret_all_uoo_ids      OUT NOCOPY VARCHAR2,
                                 p_ret_sub_uoo_ids      OUT NOCOPY VARCHAR2,
                                 p_ret_nonsub_uoo_ids   OUT NOCOPY VARCHAR2
                               )  AS

  -------------------------------------------------------------------------------------------
  -- Created by  : Basanth Kumar D, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure adds  if any subordinates of the units to be dropped are not inlcuded
  --  in the drop list and reorders them with subordinates followed by superior units.
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------------



-- cursor to get unit details
    CURSOR get_unit_dtls (p_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
    SELECT unit_cd||'/'||unit_class unit_det
    FROM igs_ps_unit_ofr_opt
    WHERE uoo_id = p_uoo_id ;

    TYPE c_ref_cursor IS REF CURSOR;
    c_chk_sub c_ref_cursor;

    l_unit_section      get_unit_dtls%ROWTYPE;
    l_grep_uoo_ids      VARCHAR2(2000);
    l_selected_uoo_ids  VARCHAR2(3000);
    l_sub_uooid         igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_unit_cd           igs_ps_unit_ofr_opt.unit_cd%TYPE;
    l_unit_class        igs_ps_unit_ofr_opt.unit_class%TYPE;
    l_sup_uooid         igs_ps_unit_ofr_opt.sup_uoo_id%TYPE;

  BEGIN

    --modified sql query for bug 5037726,sqlid:14792730
    OPEN c_chk_sub FOR
   'SELECT uoo.uoo_id sub_uoo_id, uoo.unit_cd, uoo.unit_class, uoo.sup_uoo_id
    FROM igs_ps_unit_ofr_opt uoo
    WHERE uoo.sup_uoo_id  IN ('||p_selected_uoo_ids||')
    AND uoo.RELATION_TYPE  = ''SUBORDINATE''
    AND uoo.uoo_id IN
                    ( SELECT uoo_id FROM igs_en_su_attempt
                      WHERE person_id =  :1
                      AND course_cd =  :2
                      AND cal_type = uoo.cal_type
                      AND ci_sequence_number = uoo.ci_sequence_number
                      AND unit_Attempt_status NOT IN (''DROPPED'', ''DISCONTIN'')
                      AND uoo_id NOT IN ('||p_selected_uoo_ids||')
                    )' USING p_person_id,p_course_cd;



    LOOP

      FETCH c_chk_sub INTO l_sub_uooid,l_unit_cd,l_unit_class,l_sup_uooid;

      EXIT WHEN c_chk_sub%NOTFOUND;

      OPEN get_unit_dtls(l_sup_uooid);

      FETCH get_unit_dtls INTO l_unit_section;

      IF get_unit_dtls%FOUND THEN

        IF  l_grep_uoo_ids IS NULL THEN

          l_grep_uoo_ids := l_sub_uooid;

        ELSE

          l_grep_uoo_ids := l_grep_uoo_ids||','||l_sub_uooid;

        END IF;

        igs_en_drop_units_api.create_ss_warning(
                                                 p_person_id      => p_person_id,
                                                 p_course_cd      => p_course_cd,
                                                 p_term_cal_type  => p_load_cal_type,
                                                 p_term_ci_sequence_number => p_load_ci_seq_num,
                                                 p_uoo_id => p_start_uoo_id, -- the original unit attempt which started the drop
                                                 p_message_for => l_unit_cd || '/'|| l_unit_class ,
                                                 p_message_icon=> 'D',
                                                 p_message_name => 'IGS_EN_WILL_DROP_SUP',
                                                 p_message_rule_text => NULL,
                                                 p_message_tokens => 'UNIT_CD:'|| l_unit_section.unit_det||';',
                                                 p_message_action=> NULL,
                                                 p_destination => NULL,
                                                 p_parameters => NULL,
                                                 p_step_type =>'DROP'
                                                );


      END IF;

      CLOSE get_unit_dtls;

    END LOOP;

    IF l_grep_uoo_ids IS NOT NULL THEN
      l_selected_uoo_ids    := p_selected_uoo_ids ||','|| l_grep_uoo_ids;
    ELSE
      l_selected_uoo_ids    := p_selected_uoo_ids;
    END IF;


    IGS_SS_EN_WRAPPERS.enrp_chk_del_sub_units (
                                    p_person_id           => p_person_id ,
                                    p_course_cd           => p_course_cd,
                                    p_load_cal_type       => p_load_cal_type,
                                    p_load_ci_seq_num     => p_load_ci_seq_num,
                                    p_selected_uoo_ids    => l_selected_uoo_ids,
                                    p_ret_all_uoo_ids     => p_ret_all_uoo_ids,
                                    p_ret_sub_uoo_ids     => p_ret_sub_uoo_ids,
                                    p_ret_nonsub_uoo_ids  => p_ret_nonsub_uoo_ids,
                                    p_delete_flag         => 'N'
                                );


    IF  p_ret_all_uoo_ids IS NULL THEN

      p_ret_all_uoo_ids :=  l_selected_uoo_ids;

    END IF;

    RETURN;

  EXCEPTION
    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      RAISE;

    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_DROP_UNITS_API.reorder_drop_units');
      IGS_GE_MSG_STACK.ADD;
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
            FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_drop_units_api.reorder_drop_units :',SQLERRM);
      END IF;
      ROLLBACK;
      RAISE;


  END reorder_drop_units;


  PROCEDURE create_ss_warning (
            p_person_id                 IN igs_en_su_attempt.person_id%TYPE,
            p_course_cd                 IN igs_en_su_attempt.course_cd%TYPE,
            p_term_cal_type             IN igs_ca_inst.cal_type%TYPE,
            p_term_ci_sequence_number   IN igs_ca_inst.sequence_number%TYPE,
            p_uoo_id                    IN igs_en_su_attempt.uoo_id%TYPE,
            p_message_for               IN IGS_EN_STD_WARNINGS.message_for%TYPE,
            p_message_icon              IN IGS_EN_STD_WARNINGS.message_icon%TYPE,
            p_message_name              IN IGS_EN_STD_WARNINGS.message_name%TYPE,
            p_message_rule_text         IN VARCHAR2,
            p_message_tokens            IN VARCHAR2,
            p_message_action            IN VARCHAR2,
            p_destination               IN IGS_EN_STD_WARNINGS.destination%TYPE,
            p_parameters                IN IGS_EN_STD_WARNINGS.p_parameters%TYPE,
            p_step_type                 IN IGS_EN_STD_WARNINGS.step_type%TYPE) AS

    PRAGMA AUTONOMOUS_TRANSACTION;

    -------------------------------------------------------------------------------------------
  -- Created by  : Basanth Kumar D, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure creates a record in warnings table after getting the relevant data
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------------



    l_token_set         VARCHAR2(1000);
    l_token             VARCHAR2(100);
    l_token_value       VARCHAR2(100);
    l_message_text      VARCHAR2(2000);
    l_row_id            VARCHAR2(30);
    x_warning_id        NUMBER;
    l_message_tokens    VARCHAR2(1000);
    -- cursor to get the record using unique key
      -- Unique key for
      -- DROP step :             person_id,course_cd,p_term_cal_type,p_term_ci_sequence_number,step_type,uoo_id,p_message_for,p_message_name
      -- PERSON,PROGRAM steps :  person_id,course_cd,p_term_cal_type,p_term_ci_sequence_number,step_type,p_message_for
      -- UNIT step :             person_id,course_cd,p_term_cal_type,p_term_ci_sequence_number,step_type,uoo_id,message_name

    CURSOR c_rec_exists IS
    SELECT ROWID,warn.*
    FROM igs_en_std_warnings warn
    WHERE person_id = p_person_id
    AND course_cd = p_course_cd
    AND term_cal_type = p_term_cal_type
    AND term_ci_sequence_number = p_term_ci_sequence_number
    AND step_type = p_step_type
    AND (
                (p_step_type = 'DROP' AND uoo_id = p_uoo_id AND message_for = p_message_for AND message_name = p_message_name)
                OR (p_step_type IN  ('PROGRAM','PERSON') AND message_for = p_message_for)
                OR (p_step_type = 'UNIT' AND uoo_id = p_uoo_id    AND message_name = p_message_name)
            );



    l_warn_rec    c_rec_exists%ROWTYPE;


    BEGIN

      FND_MESSAGE.SET_NAME('IGS',p_message_name);

      l_message_tokens := p_message_tokens;
      WHILE l_message_tokens IS NOT NULL LOOP


          l_token_set := substr(l_message_tokens, 0, instr(l_message_tokens,';')-1);
          l_token := substr(l_token_set, 0, instr(l_token_set, ':')-1);
          l_token_value := substr(l_token_set, instr(l_token_set, ':')+1);
          FND_MESSAGE.SET_TOKEN (l_token, l_token_value);

          l_message_tokens := substr(l_message_tokens, instr(l_message_tokens,';')+1);


      END LOOP;

      l_message_text := FND_MESSAGE.GET();

      IF p_message_rule_text IS NOT NULL THEN

        l_message_text := l_message_text || p_message_rule_text;

      END IF;

      OPEN c_rec_exists;
      FETCH c_rec_exists INTO l_warn_rec;
      IF c_rec_exists%NOTFOUND THEN

               IGS_EN_STD_WARNINGS_PKG.INSERT_ROW (
                              x_rowid                     =>  l_row_id,
                              x_warning_id                =>  x_warning_id,
                              x_person_id                 =>  p_person_id,
                              x_course_cd                 =>  p_course_cd,
                              x_uoo_id                    =>  p_uoo_id,
                              x_term_cal_type             =>  p_term_cal_type,
                              x_term_ci_sequence_number   =>  p_term_ci_sequence_number,
                              x_message_for               =>  p_message_for,
                              x_message_icon              =>  p_message_icon,
                              x_message_name              =>  p_message_name,
                              x_message_text              =>  l_message_text,
                              x_message_action            =>  p_message_action,
                              x_destination               =>  p_destination,
                              x_p_parameters              =>  p_parameters,
                              x_step_type                 =>  p_step_type,
                              x_session_id                =>  igs_en_add_units_api.g_ss_session_id,
                              x_mode                      =>  'R'     );
       ELSE -- update the row
                IGS_EN_STD_WARNINGS_PKG.UPDATE_ROW (
                                    x_rowid                     =>  l_warn_rec.rowid,
                                    x_warning_id                => l_warn_rec.warning_id,
                                    x_person_id                 =>   p_person_id,
                                    x_course_cd                 =>   p_course_cd,
                                    x_uoo_id                    =>  p_uoo_id,
                                    x_term_cal_type             =>  p_term_cal_type,
                                    x_term_ci_sequence_number   =>  p_term_ci_sequence_number,
                                    x_message_for               =>  p_message_for,
                                    x_message_icon              =>  p_message_icon,
                                    x_message_name              =>  p_message_name,
                                    x_message_text              =>  l_message_text,
                                    x_message_action            =>  p_message_action,
                                    x_destination               =>  p_destination,
                                    x_p_parameters              =>  p_parameters,
                                    x_step_type                 =>  p_step_type,
                                    x_session_id                =>  igs_en_add_units_api.g_ss_session_id,
                                    x_mode                      =>  'R'    );

       END IF;
       COMMIT;

    EXCEPTION

      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
        RAISE;

      WHEN OTHERS THEN

        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_DROP_UNITS_API.create_ss_warning');
        IGS_GE_MSG_STACK.ADD;
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
              FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_drop_units_api.create_ss_warning :',SQLERRM);
        END IF;
        ROLLBACK;
        RAISE;

    END create_ss_warning;

    FUNCTION get_aus_desc(p_token IN VARCHAR2)
    RETURN VARCHAR2 AS
      l_token VARCHAR2(2000);
      l_token_desc VARCHAR2(2000);
      l_stmt VARCHAR2(2000);

      TYPE c_ref_cur_typ IS REF CURSOR;
      c_ref_cur c_ref_cur_typ;

      l_description igs_ad_adm_unit_stat.description%TYPE;

    BEGIN
      l_token_desc := NULL;
      l_token :=  '''' || REPLACE (p_token, ',',''',''') || '''';

      l_stmt := 'SELECT description
                FROM igs_ad_adm_unit_stat_v
                WHERE unit_attempt_status = ''DISCONTIN''
                AND closed_ind = ''N''
                AND administrative_unit_status IN (' || l_token || ')';


      OPEN c_ref_cur FOR l_stmt;

      LOOP
        FETCH c_ref_cur INTO l_description;
        EXIT WHEN c_ref_cur%NOTFOUND ;

        IF l_token_desc IS NULL THEN
          l_token_desc := l_description;
        ELSE
          l_token_desc := l_token_desc || ',' || l_description;
        END IF;

      END LOOP;

      RETURN l_token_desc;

    EXCEPTION
      WHEN OTHERS THEN
        -- supressing the exception since this function is
        -- called within an exception
        l_token_desc := 'Error';
        RETURN l_token_desc;
    END get_aus_desc;


    PROCEDURE drop_ss_unit_attempt    (
                                            p_person_id IN NUMBER,
                                            p_course_cd IN VARCHAR2,
                                            p_course_version IN NUMBER ,
                                            p_uoo_id IN NUMBER,
                                            p_load_cal_type IN VARCHAR2,
                                            p_load_sequence_number IN NUMBER,
                                            p_dcnt_reason_cd IN VARCHAR2 ,
                                            p_admin_unit_status IN VARCHAR2 ,
                                            p_effective_date IN DATE ,
                                            p_dropped_uooids OUT NOCOPY VARCHAR2,
                                            p_return_status OUT NOCOPY VARCHAR2,
                                            p_message OUT NOCOPY VARCHAR2,
                                            p_ss_session_id IN NUMBER) AS

  -------------------------------------------------------------------------------------------
  -- Created by  : Basanth Kumar D, Oracle Student Systems Oracle IDC
  -- Purpose : This procedure is called from drop page to drop the unit selected by  the user
  -- Along with user selected unit other units which fail validtion in deny mode of that setup
  -- are also dropped
  --Change History:
  --Who         When            What
  --amuthu      9-Aug-2006      If the default drop reason cannot be determined then
  --                            stopping the further processing and showing a newly added message
  -------------------------------------------------------------------------------------------



    l_enr_meth_type             igs_en_method_type.enr_method_type%TYPE;

    l_alternate_code            igs_ca_inst.alternate_code%TYPE;
    l_acad_cal_type             igs_ca_inst.cal_type%TYPE;
    l_acad_ci_sequence_number   igs_ca_inst.sequence_number%TYPE;
    l_acad_start_dt             DATE;
    l_acad_end_dt               DATE;

    l_enr_cat                   igs_ps_type.enrolment_cat%TYPE;
    l_enr_cal_type              IGS_CA_INST.cal_type%TYPE;
    l_enr_ci_seq                IGS_CA_INST.sequence_number%TYPE;
    l_enr_categories            VARCHAR2(255);
    l_enr_comm                  VARCHAR2(1000);

    l_deny_warn_min_cp          VARCHAR2(10);
    l_deny_warn_att_type        VARCHAR2(30);
    l_deny_warn_coreq           VARCHAR2(10);
    l_deny_warn_prereq          VARCHAR2(10);
    -- bmerugu added for core drop validation
    l_deny_warn_core		VARCHAR2(10);
    l_person_type               igs_pe_typ_instances.person_type_code%TYPE;

    l_message                   VARCHAR2(100);
    l_return_status             VARCHAR2(5);

    l_drop_uoo_ids              VARCHAR2(1000);
    l_temp_failed_uooids        VARCHAR2(1000);
    l_uooids_dropped            VARCHAR2(1000);

    l_enc_message_name          VARCHAR2(2000);
    l_app_short_name            VARCHAR2(100);
    l_msg_index                 NUMBER;
    l_message_name              VARCHAR2(4000);
    l_token                     VARCHAR2(2000);


    CURSOR c_dcnt_rsn IS
    SELECT discontinuation_reason_cd
    FROM igs_en_dcnt_reasoncd
    WHERE  NVL(closed_ind,'N') ='N'
    AND  dflt_ind ='Y'
    AND dcnt_unit_ind ='Y'
    AND s_discontinuation_reason_type IS NULL;

    l_dcnt_reason_cd          igs_en_dcnt_reasoncd.discontinuation_reason_cd%TYPE;

    -- Cursor to get the coo_id of the student.
    CURSOR cur_coo_id IS
    SELECT coo_id coo_id
    FROM   igs_en_stdnt_ps_att
    WHERE  person_id = p_person_id
    AND    course_cd = p_course_cd ;

    l_attendance_type_reach   BOOLEAN;
    l_cur_coo_id              cur_coo_id%ROWTYPE;
    l_attendance_types        VARCHAR2(100);
    resource_busy  EXCEPTION;
    NO_AUSL_RECORD_FOUND EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_AUSL_RECORD_FOUND , -20010);
    PRAGMA EXCEPTION_INIT(resource_busy,-00054);

    BEGIN

    igs_en_add_units_api.g_ss_session_id := p_ss_session_id;

    igs_en_add_units_api.delete_ss_warnings
                            (
                              p_person_id             => p_person_id,
                              p_course_cd             => p_course_cd,
                              p_load_cal_type         => p_load_cal_type,
                              p_load_sequence_number  => p_load_sequence_number,
                              p_uoo_id                => p_uoo_id,
                              p_message_for           => NULL,
                              p_delete_steps          => 'DROP'
                              );

      -- smaddali added this cursor to lock the row , bug#4864437
      OPEN C_SUA_lock (p_person_id,p_course_cd,p_uoo_id);
      FETCH C_SUA_lock INTO l_lock_rec;
      CLOSE C_SUA_lock;

      IF l_lock_rec.unit_attempt_status IN ('DROPPED','DISCONTIN') THEN
          p_message := 'IGS_GE_RECORD_CHANGED';
          p_return_status := 'E';
          igs_en_add_units_api.g_ss_session_id := NULL;
          RETURN;
      END IF;

    igs_en_gen_017.enrp_get_enr_method(
                             p_enr_method_type => l_enr_meth_type,
                             p_error_message   => l_message,
                             p_ret_status      => l_return_status
                             );
     IF l_return_status = 'FALSE' OR l_message IS NOT NULL THEN

      p_message := l_message;
      p_return_status := 'E';
      igs_en_add_units_api.g_ss_session_id := NULL;
      RETURN;

     END IF ;


    IF p_dcnt_reason_cd IS NULL THEN

      OPEN c_dcnt_rsn;
      FETCH c_dcnt_rsn INTO l_dcnt_reason_cd;
      CLOSE c_dcnt_rsn;

      IF l_dcnt_reason_cd IS NULL THEN
        p_message := 'IGS_EN_DFLT_DCNT_RSN_NOT_SETUP';
        p_return_status := 'E';
        igs_en_add_units_api.g_ss_session_id := NULL;
        RETURN;
      END IF;

    ELSE

      l_dcnt_reason_cd := p_dcnt_reason_cd;

    END IF;

    l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                        p_cal_type                => p_load_cal_type,
                        p_ci_sequence_number      => p_load_sequence_number,
                        p_acad_cal_type           => l_acad_cal_type,
                        p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                        p_acad_ci_start_dt        => l_acad_start_dt,
                        p_acad_ci_end_dt          => l_acad_end_dt,
                        p_message_name            => l_message );

    IF l_message IS NOT NULL THEN

      p_message := l_message;
      p_return_status := 'E';
      igs_en_add_units_api.g_ss_session_id := NULL;
      RETURN;

    END IF;



    l_enr_cat := igs_en_gen_003.enrp_get_enr_cat(
                        p_person_id                 =>  p_person_id,
                        p_course_cd                 =>  p_course_cd ,
                        p_cal_type                  =>  l_acad_cal_type ,
                        p_ci_sequence_number        =>  l_acad_ci_sequence_number,
                        p_session_enrolment_cat     =>  NULL,
                        p_enrol_cal_type            =>  l_enr_cal_type,
                        p_enrol_ci_sequence_number  =>  l_enr_ci_seq,
                        p_commencement_type         =>  l_enr_comm,
                        p_enr_categories            =>  l_enr_categories
                        );


    IF l_enr_comm = 'BOTH' THEN

     l_enr_comm :='ALL';

    END IF;

    l_message:= NULL;

    l_person_type := igs_en_gen_008.enrp_get_person_type(p_course_cd);

    l_deny_warn_min_cp  := igs_ss_enr_details.get_notification(
                                p_person_type            => l_person_type,
                                p_enrollment_category    => l_enr_cat,
                                p_comm_type              => l_enr_comm,
                                p_enr_method_type        => l_enr_meth_type,
                                p_step_group_type        => 'PROGRAM',
                                p_step_type              => 'FMIN_CRDT',
                                p_person_id              => p_person_id,
                                p_message                => l_message
                                ) ;


    IF l_message IS NOT NULL THEN

          p_message := l_message;
          p_return_status := 'E';
          igs_en_add_units_api.g_ss_session_id := NULL;
          RETURN;

    END IF;


    l_deny_warn_att_type  := igs_ss_enr_details.get_notification(
                                        p_person_type            => l_person_type,
                                        p_enrollment_category    => l_enr_cat,
                                        p_comm_type              => l_enr_comm,
                                        p_enr_method_type        => l_enr_meth_type,
                                        p_step_group_type        => 'PROGRAM',
                                        p_step_type              => 'FATD_TYPE',
                                        p_person_id              => p_person_id,
                                        p_message                => l_message
                                        ) ;
    IF l_message IS NOT NULL THEN

          p_message := l_message;
          p_return_status := 'E';
          igs_en_add_units_api.g_ss_session_id := NULL;
          RETURN;

    END IF;

    --bmerugu added
    -- Get the value of Deny/Warn Flag for unit step 'DROP_CORE'
    l_deny_warn_core := igs_ss_enr_details.get_notification(
				p_person_type            => l_person_type,
				p_enrollment_category    => l_enr_cat,
				p_comm_type              => l_enr_comm,
				p_enr_method_type        => l_enr_meth_type,
				p_step_group_type        => 'UNIT',
				p_step_type              => 'DROP_CORE',
				p_person_id              => p_person_id,
				p_message                => l_message
				) ;

    IF l_message IS NOT NULL THEN
          p_message := l_message;
          p_return_status := 'E';
          igs_en_add_units_api.g_ss_session_id := NULL;
          RETURN;
    END IF;

    IF l_deny_warn_att_type  IS NOT NULL THEN

      OPEN  cur_coo_id;
      FETCH cur_coo_id INTO l_cur_coo_id;
      CLOSE cur_coo_id;

      l_attendance_type_reach := TRUE;

      -- Check if the Forced Attendance Type has already been reached for the Student
      l_attendance_type_reach := igs_en_val_sca.enrp_val_coo_att(
                                            p_person_id          => p_person_id,
                                            p_coo_id             => l_cur_coo_id.coo_id,
                                            p_cal_type           => l_acad_cal_type,
                                            p_ci_sequence_number => l_acad_ci_sequence_number,
                                            p_message_name       => l_message,
                                            p_attendance_types   => l_attendance_types,
                                            p_load_or_teach_cal_type => p_load_cal_type,
                                            p_load_or_teach_seq_number => p_load_sequence_number
                                            );

      -- Assign values to the parameter p_deny_warn_att based on if Attendance Type has not been already reached or not.
      IF l_attendance_type_reach THEN
          l_deny_warn_att_type  := 'AttTypReached' ;
      ELSE
          l_deny_warn_att_type  := 'AttTypNotReached' ;
      END IF ;

    END IF ;

    l_message := NULL;

    l_deny_warn_coreq  := igs_ss_enr_details.get_notification(
                                p_person_type            => l_person_type,
                                p_enrollment_category    => l_enr_cat,
                                p_comm_type              => l_enr_comm,
                                p_enr_method_type        => l_enr_meth_type,
                                p_step_group_type        => 'UNIT',
                                p_step_type              => 'COREQ',
                                p_person_id              => p_person_id,
                                p_message                => l_message
                                ) ;
    IF l_message IS NOT NULL THEN

          p_message := l_message;
          p_return_status := 'E';
          igs_en_add_units_api.g_ss_session_id := NULL;
          RETURN;

    END IF;

    l_message := NULL;
    l_deny_warn_prereq := igs_ss_enr_details.get_notification(
                                p_person_type            => l_person_type,
                                p_enrollment_category    => l_enr_cat,
                                p_comm_type              => l_enr_comm,
                                p_enr_method_type        => l_enr_meth_type,
                                p_step_group_type        => 'UNIT',
                                p_step_type              => 'PREREQ',
                                p_person_id              => p_person_id,
                                p_message                => l_message
                                ) ;
    IF l_message IS NOT NULL THEN

          p_message := l_message;
          p_return_status := 'E';
          igs_en_add_units_api.g_ss_session_id := NULL;
          RETURN;

    END IF;

    l_drop_uoo_ids := p_uoo_id;
    l_uooids_dropped := NULL;
    l_return_status := NULL;
    p_message := NULL;

     -- smaddali 8-dec-2005   added this global variable to bypass update spa,
     -- matriculation  and reserved seat counts for DROP  : bug#4864437
    igs_en_su_attempt_pkg.pkg_source_of_drop := 'DROP';


    --  This  loop drop the units passed and in that process collects
    -- all the uooids that are failing (prereq/coreq in deny mode) because of dropping
    -- the passed units and these units are passed in the next iteration to be dropped .
    -- This process is repeated untill no units fail validations
    LOOP

      drop_student_unit_attempts(
                        p_person_id,
                        p_course_cd,
                        p_course_version,
                        p_uoo_id, -- uoo_id passed to api from page
                        l_drop_uoo_ids,
                        l_acad_cal_type,
                        l_acad_ci_sequence_number,
                        p_load_cal_type,
                        p_load_sequence_number,
                        l_enr_cat,
                        l_enr_comm,
                        l_enr_meth_type,
                        l_dcnt_reason_cd,
                        p_admin_unit_status,
                        p_effective_date,
                        l_deny_warn_coreq,
                        l_deny_warn_prereq,
                        l_deny_warn_min_cp,
                        l_deny_warn_att_type,
			            l_deny_warn_core,
                        l_temp_failed_uooids,  -- uooids failed in this loop
                        l_uooids_dropped,    --- uooids dropped in this loop
                        p_message,
                        l_return_status);

      IF l_return_status = 'E' AND p_message IS NOT NULL THEN
        igs_en_su_attempt_pkg.pkg_source_of_drop := NULL;
        p_return_status := 'E';
        igs_en_add_units_api.g_ss_session_id := NULL;
        RETURN;
      END IF;

      IF p_dropped_uooids IS NULL THEN
        p_dropped_uooids := l_uooids_dropped;
      ELSE
        p_dropped_uooids := p_dropped_uooids||','||l_uooids_dropped;
      END IF;

      EXIT WHEN  l_temp_failed_uooids IS NULL OR l_return_status = 'E' ;

      l_drop_uoo_ids := l_temp_failed_uooids;
      l_temp_failed_uooids := NULL;
      l_return_status := NULL;
      l_uooids_dropped := NULL;

    END LOOP;
    igs_en_su_attempt_pkg.pkg_source_of_drop := NULL;
    igs_en_add_units_api.g_ss_session_id := NULL;

  EXCEPTION
    WHEN NO_AUSL_RECORD_FOUND THEN
      igs_en_su_attempt_pkg.pkg_source_of_drop := NULL;
      igs_en_add_units_api.g_ss_session_id := NULL;
      p_message := 'IGS_SS_CANTDET_ADM_UNT_STATUS';
      p_return_status := 'E';
      RETURN;

    WHEN resource_busy THEN
      igs_en_su_attempt_pkg.pkg_source_of_drop := NULL;
      igs_en_add_units_api.g_ss_session_id := NULL;
      p_message := 'IGS_GE_RECORD_LOCKED';
      p_return_status := 'E';
      RETURN;

    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
       igs_en_su_attempt_pkg.pkg_source_of_drop := NULL;
       igs_en_add_units_api.g_ss_session_id := NULL;
        IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
        FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);
        l_token := FND_MESSAGE.GET_TOKEN('LIST',NULL);
        IF l_token IS NOT NULL THEN
         l_message_name := l_message_name || '*' || get_aus_desc(l_token);
        END IF;
        p_return_status := 'E';
        p_message := l_message_name;
        RETURN;

    WHEN OTHERS THEN
        igs_en_su_attempt_pkg.pkg_source_of_drop := NULL;
        igs_en_add_units_api.g_ss_session_id := NULL;
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_DROP_UNITS_API.drop_ss_unit_attempt');
        IGS_GE_MSG_STACK.ADD;
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
              FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_drop_units_api.drop_ss_unit_attempt :',SQLERRM);
        END IF;
        ROLLBACK;
        RAISE;

  END drop_ss_unit_attempt;


  FUNCTION update_dropped_units (
            p_person_id igs_en_su_attempt.person_id%TYPE,
            p_course_cd igs_en_su_attempt.course_cd%TYPE,
            p_uoo_ids VARCHAR2,
            p_discontinuation_reason_cd VARCHAR2 )
            RETURN VARCHAR2 AS
  BEGIN

    RETURN update_dropped_units(p_person_id, p_course_cd, p_uoo_ids, p_discontinuation_reason_cd, NULL  );

  END update_dropped_units;

  FUNCTION update_dropped_units (
            p_person_id igs_en_su_attempt.person_id%TYPE,
            p_course_cd igs_en_su_attempt.course_cd%TYPE,
            p_uoo_ids VARCHAR2,
            p_discontinuation_reason_cd VARCHAR2,
            p_admin_unit_status VARCHAR2)
            RETURN VARCHAR2 AS

    l_discont_reason_cd   igs_en_dcnt_reasoncd.discontinuation_reason_cd%TYPE;

    TYPE c_ref_cursor IS REF CURSOR;
    c_upd_units           c_ref_cursor;

    upd_units_rec         igs_en_su_attempt%ROWTYPE;
    l_admin_unit_status   igs_en_su_attempt.administrative_unit_status%TYPE;
  BEGIN
--check that the uoo_ids list to be modified is not null

IF p_uoo_ids IS NULL THEN
FND_MESSAGE.set_name('IGS', 'IGS_GE_RECORD_CHANGED');
 IGS_GE_MSG_STACK.ADD;
APP_EXCEPTION.RAISE_EXCEPTION;
END IF;

  --modified sqlquery for bug 5037726,sql id : 14792801
    OPEN c_upd_units FOR
                          'SELECT sua.* FROM igs_En_su_attempt sua
                           WHERE person_id = :1
                           AND course_cd = :2
                           AND uoo_id IN ('||p_uoo_ids||')' USING p_person_id,p_course_cd ;

    LOOP

      FETCH c_upd_units INTO upd_units_rec;

      EXIT WHEN  c_upd_units%NOTFOUND;

      IF p_admin_unit_status IS NULL THEN
        l_admin_unit_status := upd_units_rec.administrative_unit_status;
      ELSE
        l_admin_unit_status := p_admin_unit_status;
      END IF;

      -- Call update_row of the student unit attempt table handler i.e
      igs_En_su_Attempt_pkg.update_row( X_ROWID                        =>     upd_units_rec.row_id                        ,
                                        X_PERSON_ID                    =>     upd_units_rec.person_id                      ,
                                        X_COURSE_CD                    =>     upd_units_rec.course_cd                      ,
                                        X_UNIT_CD                      =>     upd_units_rec.unit_cd                        ,
                                        X_CAL_TYPE                     =>     upd_units_rec.cal_type                       ,
                                        X_CI_SEQUENCE_NUMBER           =>     upd_units_rec.ci_sequence_number             ,
                                        X_VERSION_NUMBER               =>     upd_units_rec.version_number                 ,
                                        X_LOCATION_CD                  =>     upd_units_rec.location_cd                    ,
                                        X_UNIT_CLASS                   =>     upd_units_rec.unit_class                     ,
                                        X_CI_START_DT                  =>     upd_units_rec.ci_start_dt                    ,
                                        X_CI_END_DT                    =>     upd_units_rec.ci_end_dt                      ,
                                        X_UOO_ID                       =>     upd_units_rec.uoo_id                         ,
                                        X_ENROLLED_DT                  =>     upd_units_rec.enrolled_dt                    ,
                                        X_UNIT_ATTEMPT_STATUS          =>     upd_units_rec.unit_attempt_status            ,
                                        X_ADMINISTRATIVE_UNIT_STATUS   =>     l_admin_unit_status                          ,
                                        X_DISCONTINUED_DT              =>     upd_units_rec.discontinued_dt                ,
                                        X_RULE_WAIVED_DT               =>     upd_units_rec.rule_waived_dt                 ,
                                        X_RULE_WAIVED_PERSON_ID        =>     upd_units_rec.rule_waived_person_id          ,
                                        X_NO_ASSESSMENT_IND            =>     upd_units_rec.no_assessment_ind              ,
                                        X_SUP_UNIT_CD                  =>     upd_units_rec.sup_unit_cd                    ,
                                        X_SUP_VERSION_NUMBER           =>     upd_units_rec.sup_version_number             ,
                                        X_EXAM_LOCATION_CD             =>     upd_units_rec.exam_location_cd               ,
                                        X_ALTERNATIVE_TITLE            =>     upd_units_rec.alternative_title              ,
                                        X_OVERRIDE_ENROLLED_CP         =>     upd_units_rec.override_enrolled_cp           ,
                                        X_OVERRIDE_EFTSU               =>     upd_units_rec.override_eftsu                 ,
                                        X_OVERRIDE_ACHIEVABLE_CP       =>     upd_units_rec.override_achievable_cp         ,
                                        X_OVERRIDE_OUTCOME_DUE_DT      =>     upd_units_rec.override_outcome_due_dt        ,
                                        X_OVERRIDE_CREDIT_REASON       =>     upd_units_rec.override_credit_reason         ,
                                        X_ADMINISTRATIVE_PRIORITY      =>     upd_units_rec.administrative_priority        ,
                                        X_WAITLIST_DT                  =>     upd_units_rec.waitlist_dt                    ,
                                        X_DCNT_REASON_CD               =>     p_discontinuation_reason_cd                  , --- upodate with passed discont reason cd
                                        X_MODE                         =>     'R'                                          ,
                                        X_GS_VERSION_NUMBER            =>     upd_units_rec.gs_version_number              ,
                                        X_ENR_METHOD_TYPE              =>     upd_units_rec.enr_method_type                ,
                                        X_FAILED_UNIT_RULE             =>     upd_units_rec.failed_unit_rule               ,
                                        X_CART                         =>     upd_units_rec.cart                           ,
                                        X_RSV_SEAT_EXT_ID              =>     upd_units_rec.rsv_seat_ext_id                ,
                                        X_ORG_UNIT_CD                  =>     upd_units_rec.org_unit_cd                    ,
                                        X_SESSION_ID                   =>     upd_units_rec.session_id                     ,
                                        X_GRADING_SCHEMA_CODE          =>     upd_units_rec.grading_schema_code            ,
                                        X_DEG_AUD_DETAIL_ID            =>     upd_units_rec.deg_aud_detail_id              ,
                                        X_STUDENT_CAREER_TRANSCRIPT    =>     upd_units_rec.student_career_transcript,
                                        X_STUDENT_CAREER_STATISTICS    =>      upd_units_rec.student_career_statistics,
                                        X_ATTRIBUTE_CATEGORY           =>      upd_units_rec.attribute_category,
                                        X_ATTRIBUTE1                   =>      upd_units_rec.attribute1,
                                        X_ATTRIBUTE2                   =>      upd_units_rec.attribute2,
                                        X_ATTRIBUTE3                   =>      upd_units_rec.attribute3,
                                        X_ATTRIBUTE4                   =>      upd_units_rec.attribute4,
                                        X_ATTRIBUTE5                   =>      upd_units_rec.attribute5,
                                        X_ATTRIBUTE6                   =>      upd_units_rec.attribute6,
                                        X_ATTRIBUTE7                   =>      upd_units_rec.attribute7,
                                        X_ATTRIBUTE8                   =>      upd_units_rec.attribute8,
                                        X_ATTRIBUTE9                   =>      upd_units_rec.attribute9,
                                        X_ATTRIBUTE10                  =>      upd_units_rec.attribute10,
                                        X_ATTRIBUTE11                  =>      upd_units_rec.attribute11,
                                        X_ATTRIBUTE12                  =>      upd_units_rec.attribute12,
                                        X_ATTRIBUTE13                  =>      upd_units_rec.attribute13,
                                        X_ATTRIBUTE14                  =>      upd_units_rec.attribute14,
                                        X_ATTRIBUTE15                  =>      upd_units_rec.attribute15,
                                        X_ATTRIBUTE16                  =>      upd_units_rec.attribute16,
                                        X_ATTRIBUTE17                  =>      upd_units_rec.attribute17,
                                        X_ATTRIBUTE18                  =>      upd_units_rec.attribute18,
                                        X_ATTRIBUTE19                  =>      upd_units_rec.attribute19,
                                        X_ATTRIBUTE20                  =>      upd_units_rec.attribute20,
                                        X_WAITLIST_MANUAL_IND          =>      upd_units_rec.waitlist_manual_ind ,
                                        X_WLST_PRIORITY_WEIGHT_NUM     =>      upd_units_rec.wlst_priority_weight_num,
                                        X_WLST_PREFERENCE_WEIGHT_NUM   =>      upd_units_rec.wlst_preference_weight_num,
                                        X_CORE_INDICATOR_CODE          =>      upd_units_rec.core_indicator_code
                                      );

    END LOOP;
    RETURN 'TRUE' ;

  EXCEPTION
     WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
        ROLLBACK;
        RAISE;
    WHEN OTHERS THEN

        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_DROP_UNITS_API.update_dropped_units');
        IGS_GE_MSG_STACK.ADD;
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
              FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_drop_units_api.update_dropped_units:',SQLERRM);
        END IF;
        ROLLBACK;
        RAISE;

  END update_dropped_units;

END igs_en_drop_units_api;

/
