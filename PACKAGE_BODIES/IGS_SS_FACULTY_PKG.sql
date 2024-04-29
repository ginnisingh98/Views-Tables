--------------------------------------------------------
--  DDL for Package Body IGS_SS_FACULTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SS_FACULTY_PKG" AS
/* $Header: IGSSS08B.pls 115.7 2003/12/03 10:25:29 ijeddy ship $ */
 FUNCTION assp_ins_get_by_uoo(
  p_keying_who IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_include_discont_ind IN VARCHAR2 ,
  p_sort_by IN VARCHAR2 ,
  p_keying_time OUT NOCOPY DATE,
  p_return_status OUT NOCOPY VARCHAR2,
  p_msg_data OUT NOCOPY VARCHAR2,
  p_msg_count OUT NOCOPY NUMBER

 ) RETURN VARCHAR2 IS
 BEGIN

   IF IGS_AS_GEN_004.assp_ins_get(
          p_keying_who,
          NULL,
          p_cal_type,
          p_sequence_number,
          p_unit_cd,
          p_location_cd,
          NULL,
          p_unit_class,
          p_include_discont_ind,
          p_sort_by,
          p_keying_time ) THEN
     return 'TRUE';
   ELSE
      p_msg_data :=sqlerrm;
      p_return_status :=  fnd_api.g_ret_sts_error;
     return 'FALSE';
   END IF;

 END assp_ins_get_by_uoo;



  PROCEDURE update_suao(
    p_person_id          IN NUMBER,
    p_cal_type           IN VARCHAR2,
    p_ci_sequence_number IN NUMBER,
    p_unit_cd            IN VARCHAR2,
    p_course_cd          IN VARCHAR2,
    p_mark               IN NUMBER,
    p_grade              IN VARCHAR2,
    p_grading_schema_cd  IN VARCHAR2,
    p_gs_version_number  IN NUMBER,
    p_uoo_id             IN igs_en_su_attempt.uoo_id%TYPE
  ) IS
/*
| Who         When            What
| knaraset  09-May-03   modified this procedure to add parameter uoo_id which is used in cursors c_suao_chkand c_IGS_AS_SU_STMPTOUT,
|                       also passed the uoo_id in TBH calls of IGS_AS_SU_STMPTOUT_PKG, as part of MUS build bug 2829262
|
|
*/
    CURSOR c_suao_chk (cp_person_id          IGS_AS_SU_STMPTOUT.person_id%TYPE,
                       cp_course_cd          IGS_AS_SU_STMPTOUT.course_cd%TYPE,
                       cp_uoo_id            IGS_AS_SU_STMPTOUT.uoo_id%TYPE) IS
      SELECT  finalised_outcome_ind,
              mark,
              grade,
              grading_schema_cd,
              version_number,
              outcome_dt,
              number_times_keyed
      FROM  IGS_AS_SU_STMPTOUT
      WHERE   person_id          = cp_person_id
       AND    course_cd          = cp_course_cd
       AND    uoo_id            = cp_uoo_id
      ORDER BY outcome_dt ASC;

    CURSOR c_ci (cp_cal_type         IGS_CA_INST.cal_type%TYPE,
		 cp_sequence_number  IGS_CA_INST.sequence_number%TYPE) IS
      SELECT  start_dt,
              end_dt
      FROM  IGS_CA_INST
      WHERE  cal_type = cp_cal_type
       AND   sequence_number = cp_sequence_number;


    CURSOR c_IGS_AS_SU_STMPTOUT	(cp_person_id          IGS_AS_SU_STMPTOUT.person_id%TYPE,
                                 cp_course_cd          IGS_AS_SU_STMPTOUT.course_cd%TYPE,
                                 cp_uoo_id            IGS_AS_SU_STMPTOUT.uoo_id%TYPE,
                                 cp_outcome_dt         IGS_AS_SU_STMPTOUT.outcome_dt%TYPE) IS
      SELECT   ROWID,
               IGS_AS_SU_STMPTOUT.*
      FROM    IGS_AS_SU_STMPTOUT
      WHERE    person_id = cp_person_id
       AND     course_cd = cp_course_cd
       AND     uoo_id = cp_uoo_id
       AND     outcome_dt = cp_outcome_dt;


	v_ci_rec			c_ci%ROWTYPE;
	v_suao1_rec			c_suao_chk%ROWTYPE;
        v_stmptout_rec  		c_IGS_AS_SU_STMPTOUT%ROWTYPE;
	v_records_found			BOOLEAN;
	l_rowid                         VARCHAR2(25);
        lv_rowid                        VARCHAR2(25);

  BEGIN

    FOR v_suao_rec IN c_suao_chk( p_person_id,
                                  p_course_cd,
                                  p_uoo_id) LOOP
      v_records_found := TRUE;
      v_suao1_rec := v_suao_rec;
    END LOOP;

    IF v_records_found AND v_suao1_rec.finalised_outcome_ind = 'N' THEN

      OPEN c_IGS_AS_SU_STMPTOUT(
             p_person_id,
             p_course_cd,
             p_uoo_id,
             v_suao1_rec.outcome_dt);

      FETCH c_IGS_AS_SU_STMPTOUT INTO v_stmptout_rec;

      IGS_AS_SU_STMPTOUT_PKG.UPDATE_ROW (
	  X_ROWID                        => v_stmptout_rec.rowid ,
          X_MODE                         => 'R',
  	  x_person_id                    => v_stmptout_rec.person_id,
	  x_course_cd                    => v_stmptout_rec.course_cd,
	  x_unit_cd                      => v_stmptout_rec.unit_cd,
	  x_cal_type                     => v_stmptout_rec.cal_type,
	  x_ci_sequence_number           => v_stmptout_rec.ci_sequence_number,
          x_outcome_dt                   => v_stmptout_rec.OUTCOME_DT,
	  x_ci_start_dt                  => v_stmptout_rec.CI_START_DT,
	  x_ci_end_dt                    => v_stmptout_rec.CI_END_DT,
	  X_GRADING_SCHEMA_CD 		 => p_grading_schema_cd,
	  X_VERSION_NUMBER  		 => p_gs_version_number,
	  X_GRADE			 => p_grade,
          x_s_grade_creation_method_type => v_stmptout_rec.s_grade_creation_method_type,
          x_finalised_outcome_ind        => v_stmptout_rec.finalised_outcome_ind,
	  x_mark                         => p_mark,
          x_number_times_keyed           => NVL(v_suao1_rec.number_times_keyed,0)+1,
          x_translated_grading_schema_cd => v_stmptout_rec.translated_grading_schema_cd,
	  x_translated_version_number    => v_stmptout_rec.translated_version_number,
	  x_translated_grade             => v_stmptout_rec.translated_grade,
	  x_translated_dt                => v_stmptout_rec.translated_dt ,
          X_ATTRIBUTE_CATEGORY           => v_stmptout_rec.attribute_category,
          X_ATTRIBUTE1                   => v_stmptout_rec.attribute1,
          X_ATTRIBUTE2                   => v_stmptout_rec.attribute2,
          X_ATTRIBUTE3                   => v_stmptout_rec.attribute3,
          X_ATTRIBUTE4                   => v_stmptout_rec.attribute4,
          X_ATTRIBUTE5                   => v_stmptout_rec.attribute5,
          X_ATTRIBUTE6                   => v_stmptout_rec.attribute6,
          X_ATTRIBUTE7                   => v_stmptout_rec.attribute7,
          X_ATTRIBUTE8                   => v_stmptout_rec.attribute8,
          X_ATTRIBUTE9                   => v_stmptout_rec.attribute9,
          X_ATTRIBUTE10                  => v_stmptout_rec.attribute10,
          X_ATTRIBUTE11                  => v_stmptout_rec.attribute11,
          X_ATTRIBUTE12                  => v_stmptout_rec.attribute12,
          X_ATTRIBUTE13                  => v_stmptout_rec.attribute13,
          X_ATTRIBUTE14                  => v_stmptout_rec.attribute14,
          X_ATTRIBUTE15                  => v_stmptout_rec.attribute15,
          X_ATTRIBUTE16                  => v_stmptout_rec.attribute16,
          X_ATTRIBUTE17                  => v_stmptout_rec.attribute17,
          X_ATTRIBUTE18                  => v_stmptout_rec.attribute18,
          X_ATTRIBUTE19                  => v_stmptout_rec.attribute19,
          X_ATTRIBUTE20                  => v_stmptout_rec.attribute20,
          X_UOO_ID                       => v_stmptout_rec.uoo_id,
          x_mark_capped_flag             => v_stmptout_rec.mark_capped_flag,
          x_show_on_academic_histry_flag => v_stmptout_rec.show_on_academic_histry_flag,
          x_release_date                 => v_stmptout_rec.release_date,
          x_manual_override_flag         => v_stmptout_rec.manual_override_flag,
          x_incomp_deadline_date         => v_stmptout_rec.incomp_deadline_date,
          x_incomp_grading_schema_cd     => v_stmptout_rec.incomp_grading_schema_cd,
          x_incomp_version_number        => v_stmptout_rec.incomp_version_number,
          x_incomp_default_grade         => v_stmptout_rec.incomp_default_grade,
          x_incomp_default_mark          => v_stmptout_rec.incomp_default_mark,
          x_comments                     => v_stmptout_rec.comments,
          x_grading_period_cd            => v_stmptout_rec.grading_period_cd
	  );

      CLOSE c_IGS_AS_SU_STMPTOUT;

    ELSE
      -- get the start/end dates from the calendar instance.
      OPEN  c_ci(p_cal_type, p_ci_sequence_number);
      FETCH c_ci INTO v_ci_rec;
      CLOSE c_ci;

      -- Add a new IGS_AS_SU_STMPTOUT record.
      IGS_AS_SU_STMPTOUT_pkg.INSERT_ROW(
        x_rowid                        => l_rowid,
        x_mode  		       => 'R',
        x_person_id                    => p_person_id,
        x_course_cd                    => p_course_cd,
        x_unit_cd                      => p_unit_cd,
        x_cal_type                     => p_cal_type,
        x_ci_sequence_number           => p_ci_sequence_number,
        x_ci_start_dt                  => v_ci_rec.start_dt,
        x_ci_end_dt                    => v_ci_rec.end_dt,
        x_outcome_dt                   => SYSDATE,
        x_s_grade_creation_method_type => 'KEYED',
        x_number_times_keyed           => 1,
        x_finalised_outcome_ind        => 'N',
        x_mark                         => p_mark,
        x_grade                        => p_grade,
        x_grading_schema_cd            => p_grading_schema_cd,
        x_version_number               => p_gs_version_number,
        x_translated_grading_schema_cd => null,
        x_translated_version_number    => null,
        x_translated_grade             => null,
        x_translated_dt                => null,
        X_ORG_ID                       => TO_NUMBER(FND_PROFILE.VALUE('ORG_ID')) ,
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
        X_UOO_ID                       => p_uoo_id,
        x_mark_capped_flag             => 'N',
        x_show_on_academic_histry_flag => 'Y',
        x_release_date                 => NULL,
        x_manual_override_flag         => 'N',
        x_incomp_deadline_date         => NULL,
        x_incomp_grading_schema_cd     => NULL,
        x_incomp_version_number        => NULL,
        x_incomp_default_grade         => NULL,
        x_incomp_default_mark          => NULL,
        x_comments                     => NULL,
        x_grading_period_cd            => 'FINAL'
	);
    END IF;
  END update_suao;

END IGS_SS_FACULTY_PKG;

/
