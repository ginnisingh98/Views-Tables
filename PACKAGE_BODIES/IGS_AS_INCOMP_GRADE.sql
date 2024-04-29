--------------------------------------------------------
--  DDL for Package Body IGS_AS_INCOMP_GRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_INCOMP_GRADE" AS
/* $Header: IGSAS41B.pls 120.2 2006/01/18 22:56:28 swaghmar ship $ */

PROCEDURE incomp_grade_process(
  errbuf  	OUT NOCOPY  VARCHAR2,
  retcode 	OUT NOCOPY  NUMBER  )
IS

BEGIN	-- incomp_grade_process
	-- Process to convert the incomplete grades recorded to the default grades
	-- entered once the deadline date is passed and the student has not completed.
	-- the incomplete grade.
	-- This process is run every day by the system automatically

DECLARE

  l_wf_event_t				WF_EVENT_T;
  l_wf_parameter_list_t			WF_PARAMETER_LIST_T;
  l_key					NUMBER;
  l_internal_name			VARCHAR2(100);
  l_sysdate				DATE;
  x_rowid				VARCHAR2(25);

  CURSOR c_suao IS
  		 SELECT suao.person_id,
       	 		suao.course_cd,
       			suao.unit_cd,
       			suao.cal_type,
       			suao.ci_sequence_number,
                 -- anilk, 22-Apr-2003, Bug# 2829262
                        suao.uoo_id,
       			suao.ci_start_dt,
       			suao.ci_end_dt,
			suao.grade,
       			suao.incomp_grading_schema_cd,
       			suao.incomp_version_number,
       			suao.incomp_default_grade,
       			suao.incomp_default_mark,
       			uv.title,
       			uv.short_title,
       			ci.description
		FROM   igs_as_suaoa_v  	 suao,
		       igs_en_su_attempt sua,
       		       igs_ps_unit_ver   uv,
       		       igs_ca_inst       ci
		WHERE  suao.person_id = sua.person_id
		AND    suao.course_cd = sua.course_cd
                -- anilk, 22-Apr-2003, Bug# 2829262
		AND    suao.uoo_id = sua.uoo_id
		AND    sua.unit_cd = uv.unit_cd
		AND    sua.version_number = uv.version_number
		AND    sua.cal_type = ci.cal_type
		AND    sua.ci_sequence_number = ci.sequence_number
		AND    TRUNC(suao.incomp_deadline_date) <= TRUNC(SYSDATE)
		AND    suao.finalised_outcome_ind = 'Y'
		AND    suao.grading_period_cd = 'FINAL';

BEGIN


  retcode := 0;
  IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054
  SAVEPOINT s_before_insert;

  FOR v_suao_rec IN c_suao LOOP

	l_sysdate := SYSDATE;

        -- Call table handler to insert new Student Unit Attempt Outcome
        IGS_AS_SU_STMPTOUT_PKG.INSERT_ROW(
                        X_ROWID                        => x_rowid,
			X_ORG_ID       		       => NULL,
                        X_PERSON_ID                    => v_suao_rec.person_id,
                        X_COURSE_CD                    => v_suao_rec.course_cd,
                        X_UNIT_CD                      => v_suao_rec.unit_cd,
                        X_CAL_TYPE                     => v_suao_rec.cal_type,
                        X_CI_SEQUENCE_NUMBER           => v_suao_rec.ci_sequence_number,
                        X_OUTCOME_DT                   => l_sysdate,
                        X_CI_START_DT                  => v_suao_rec.ci_start_dt,
                        X_CI_END_DT                    => v_suao_rec.ci_end_dt,
                        X_GRADING_SCHEMA_CD            => v_suao_rec.incomp_grading_schema_cd,
                        X_VERSION_NUMBER               => v_suao_rec.incomp_version_number,
                        X_GRADE                        => v_suao_rec.incomp_default_grade,
                        X_S_GRADE_CREATION_METHOD_TYPE => 'SYSTEM',
                        X_FINALISED_OUTCOME_IND        => 'N',
                        X_MARK                         => v_suao_rec.incomp_default_mark,
                        X_NUMBER_TIMES_KEYED           => NULL,
                        X_TRANSLATED_GRADING_SCHEMA_CD => NULL,
                        X_TRANSLATED_VERSION_NUMBER    => NULL,
                        X_TRANSLATED_GRADE             => NULL,
                        X_TRANSLATED_DT                => NULL,
                        X_MODE                         => 'R',
                        X_GRADING_PERIOD_CD            => 'FINAL',
                        X_ATTRIBUTE_CATEGORY           => NULL,
                        X_ATTRIBUTE1                   => NULL,
                        X_ATTRIBUTE2                   => NULL,
                        X_ATTRIBUTE3                   => NULL,
                        X_ATTRIBUTE4                   => NULL,
                        X_ATTRIBUTE5                   => NULL,
                        X_ATTRIBUTE6                   => NULL,
                        X_ATTRIBUTE7                   => NULL,
                        X_ATTRIBUTE8                   => NULL,
                        X_ATTRIBUTE9                   => NULL,
                        X_ATTRIBUTE10                  => NULL,
                        X_ATTRIBUTE11                  => NULL,
                        X_ATTRIBUTE12                  => NULL,
                        X_ATTRIBUTE13                  => NULL,
                        X_ATTRIBUTE14                  => NULL,
                        X_ATTRIBUTE15                  => NULL,
                        X_ATTRIBUTE16                  => NULL,
                        X_ATTRIBUTE17                  => NULL,
                        X_ATTRIBUTE18                  => NULL,
                        X_ATTRIBUTE19                  => NULL,
                        X_ATTRIBUTE20                  => NULL,
			X_INCOMP_DEADLINE_DATE         => NULL,
			X_INCOMP_GRADING_SCHEMA_CD     => NULL,
			X_INCOMP_VERSION_NUMBER        => NULL,
			X_INCOMP_DEFAULT_GRADE         => NULL,
			X_INCOMP_DEFAULT_MARK          => NULL,
			X_COMMENTS     		       => NULL,
                        -- anilk, 22-Apr-2003, Bug# 2829262
			X_UOO_ID                       => v_suao_rec.uoo_id,
                        x_mark_capped_flag              => 'N',
                        x_show_on_academic_histry_flag  => 'Y',
                        x_release_date                  => NULL,
                        x_manual_override_flag          => 'N'
                        );

	  -- Call the finalization process for this record
          --ijeddy, 25-Aug-2005 bug fix for bug 4371745. pass uoo_id instead of NULL
          IGS_AS_FINALIZE_GRADE.finalize_process( v_suao_rec.uoo_id,
	    					v_suao_rec.person_id,
	    					v_suao_rec.course_cd,
	    					v_suao_rec.unit_cd,
	    					v_suao_rec.cal_type,
	    					v_suao_rec.ci_sequence_number );


        -- Raise business event for Incomplete Grade to be used for Notification.
	  IGS_AS_GRD_ATT_BE_PKG.wf_inform_admin_incgrd( v_suao_rec.person_id,
	    						v_suao_rec.course_cd,
	    						v_suao_rec.unit_cd,
	    						v_suao_rec.cal_type,
	    						v_suao_rec.ci_sequence_number,
							l_sysdate,
							v_suao_rec.grade,
							v_suao_rec.incomp_default_grade);


  END LOOP

  COMMIT;

  EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK TO s_before_insert;

		FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_INCOMP_GRADE.incomp_grade_process');
		IGS_GE_MSG_STACK.ADD;
   		retcode := 2;
   		errbuf  :=  fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXP');
   		IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END;
END incomp_grade_process;

END IGS_AS_INCOMP_GRADE ;

/
