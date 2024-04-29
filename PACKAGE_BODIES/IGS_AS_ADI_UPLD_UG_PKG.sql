--------------------------------------------------------
--  DDL for Package Body IGS_AS_ADI_UPLD_UG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_ADI_UPLD_UG_PKG" AS
/* $Header: IGSAS43B.pls 120.4 2006/06/20 13:16:33 sepalani noship $ */
  PROCEDURE grading_period_grade_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2 DEFAULT 'Y'
  ) IS
    --
    p_batch_date                   DATE                 := TO_DATE (p_batch_datetime, 'YYYY/MM/DD HH24:MI:SS');
    --
    --
    --
    --
    --
    --
    CURSOR c_upload_outcome_ugi IS
      SELECT user_id,
             batch_date,
             decode(person_number,'-',null,person_number) person_number,
             decode(anonymous_id,'-',null,anonymous_id) anonymous_id,
             course_cd,
             unit_cd,
             cal_type,
             ci_sequence_number,
             alternate_code,
             grade,
             mark,
             grading_period_cd,
             incomp_default_mark,
             incomp_default_grade,
             incomp_deadline_date,
             comments,
             error_code,
             rowid,
             unit_class,
             location_cd,
             uoo_id,
             manual_override_flag,
             mark_capped_flag,
             release_date
      FROM   igs_as_ug_interface ugi
      WHERE  ugi.user_id = p_user_id
      AND    trunc(ugi.batch_date) = trunc(p_batch_date)
      AND   NVL(grading_period_cd , '-') <> '-';

    --
    --
    --
    CURSOR c_upload_outcome_ugi_upd IS
      SELECT   user_id,
               batch_date,
               decode(person_number,'-',null,person_number) person_number,
               decode(anonymous_id,'-',null,anonymous_id) anonymous_id,
               course_cd,
               unit_cd,
               cal_type,
               ci_sequence_number ,
               alternate_code,
               grade,
               mark,
               grading_period_cd ,
               incomp_default_mark,
               incomp_default_grade,
               incomp_deadline_date,
               comments,
               error_code,
               rowid,
               unit_class,
               location_cd,
               uoo_id,
               manual_override_flag,
               mark_capped_flag,
               release_date
      FROM     igs_as_ug_interface  ugi
      WHERE    ugi.user_id=p_user_id
      AND      trunc(ugi.batch_date) = trunc(p_batch_date)
      AND      (error_code IS NULL
      OR        error_code IN ('IGS_AS_ASW_GP_GRADE_EXIST', 'IGS_AS_ASW_MARK_GRADE_INVALID'))
      AND   NVL(grading_period_cd, '-') <> '-';
    --
    -- Cursor added to get the Student Unit Attempt uoo_id
    --
    CURSOR  c_sua_uoo (
              cp_person_id           igs_en_su_attempt.person_id%TYPE,
              cp_course_cd           igs_en_su_attempt.course_cd%TYPE,
              cp_unit_cd             igs_en_su_attempt.unit_cd%TYPE,
              cp_cal_type            igs_en_su_attempt.cal_type%TYPE,
              cp_ci_sequence_number  igs_en_su_attempt.ci_sequence_number%TYPE,
              cp_location_cd         igs_en_su_attempt.location_cd%TYPE,
              cp_unit_class          igs_en_su_attempt.unit_class%TYPE
            ) IS
      SELECT  sua.uoo_id
      FROM    igs_en_su_attempt  sua
      WHERE   sua.person_id = cp_person_id
      AND     sua.course_cd = cp_course_cd
      AND     sua.unit_cd = cp_unit_cd
      AND     sua.cal_type = cp_cal_type
      AND     sua.ci_sequence_number = cp_ci_sequence_number
      AND     sua.location_cd = cp_location_cd
      AND     sua.unit_class = cp_unit_class;
    --
    --
    --
    CURSOR c_suao (
      cp_person_id                          igs_as_su_atmpt_itm.person_id%TYPE,
      cp_course_cd                          igs_as_su_atmpt_itm.course_cd%TYPE,
      cp_unit_cd                            igs_as_su_atmpt_itm.unit_cd%TYPE,
      cp_cal_type                           igs_as_su_atmpt_itm.cal_type%TYPE,
      cp_ci_sequence_number                 igs_as_su_atmpt_itm.ci_sequence_number%TYPE,
      cp_grading_period_cd                  igs_as_gpc_programs.grading_period_cd%TYPE,
      -- anilk, 22-Apr-2003, Bug# 2829262
      cp_uoo_id                             igs_as_su_atmpt_itm.uoo_id%TYPE
    ) IS
      SELECT ROWID
      FROM   igs_as_su_stmptout_all suao
      WHERE  suao.person_id = cp_person_id
      AND    suao.course_cd = cp_course_cd
      AND    suao.uoo_id = cp_uoo_id
      AND    suao.grading_period_cd = cp_grading_period_cd
      AND    suao.finalised_outcome_ind = 'N';
    --
    --
    --
    CURSOR c_suao_record (
      cp_rowid IN VARCHAR2
    ) IS
      SELECT suao.*
      FROM   igs_as_su_stmptout_all suao
      WHERE  ROWID = cp_rowid;
    -- Declare local variables
    v_person_id                    NUMBER (15);
    v_cal_type                     VARCHAR2 (10);
    v_ci_sequence_number           NUMBER (6);
    v_ci_start_dt                  DATE;
    v_ci_end_dt                    DATE;
    v_error_code                   VARCHAR2 (30);
    v_grade                        VARCHAR2 (5);
    v_request_id                   NUMBER;
    v_uoo_id                       NUMBER (7);
    v_load_file_flag               VARCHAR2 (1);
    v_load_file_master             VARCHAR2 (1)         := 'Y';
    v_load_record_flag             VARCHAR2 (1);
    v_grading_schema_cd            VARCHAR2 (10);
    v_gs_version_number            NUMBER (3);
    v_rowid                        VARCHAR2 (25);
    v_outcome_dt                   DATE                 DEFAULT SYSDATE;
    v_s_grade_creation_method_type VARCHAR2 (30)        DEFAULT 'WEBADI';
    v_finalised_outcome_ind        VARCHAR2 (1)         DEFAULT 'N';
    v_number_times_keyed           NUMBER (2)           DEFAULT 1;
    l_uoo_id                       NUMBER;
    rec_suao_record c_suao_record%ROWTYPE;
      --
      l_validuser varchar2(1);
  BEGIN

    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054
--
-- FND_LOGGING
--
IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	fnd_log.string ( fnd_log.level_procedure,
		'igs.plsql.igs_as_adi_upld_ug_pkg.grading_period_grade_process.begin',
		'Params: p_user_id  => '||p_user_id|| ';' ||
		' p_batch_datetime  => '||p_batch_datetime|| ';' ||
		' p_grade_creation_method_type  => '||p_grade_creation_method_type|| ';' ||
		' p_delete_rows  => '||p_delete_rows|| ';'
	     );
END IF;

    FOR v_ugi_rec IN c_upload_outcome_ugi LOOP
      -- Initialize variables here.
      v_cal_type := v_ugi_rec.cal_type;
      v_ci_sequence_number := v_ugi_rec.ci_sequence_number;
      v_grade := v_ugi_rec.grade;
      --Call routine to upload for validate the particular row

      --Check if the user is authorised to upload data .
      --Only admin and faculty for the unitsection can upload data to OSS.

      l_validuser:=IGS_AS_ADI_UPLD_AIO_PKG.isvaliduser (
           v_ugi_rec.user_id ,
           v_ugi_rec.uoo_id
      );

      if(l_validuser<>'Y') then
       UPDATE igs_as_ug_interface
         SET error_code = 'IGS_EN_PERSON_NO_RESP'
       WHERE ROWID = v_ugi_rec.ROWID;
      else
	--
	-- FND_LOGGING
	--
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
	fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_as_adi_upld_ug_pkg.grading_period_grade_process.c_upload_outcome_ugi',
		'v_ugi_rec.person_number => '||v_ugi_rec.person_number||';'||
		'v_ugi_rec.anonymous_id => '||v_ugi_rec.anonymous_id||';'||
		'v_cal_type => '||v_cal_type||';'||
		'v_ci_sequence_number =>'||v_ci_sequence_number||';'||
		'v_grade =>'||v_grade||';'
		);
	END IF;

      igs_as_ug_val_upld (
        v_ugi_rec.person_number,
        v_ugi_rec.anonymous_id,
        v_ugi_rec.alternate_code,
        v_ugi_rec.course_cd,
        v_ugi_rec.unit_cd,
        v_ugi_rec.grading_period_cd,
        v_ugi_rec.mark,
        v_grade,
        v_person_id,
        v_cal_type,
        v_ci_sequence_number,
        v_ci_start_dt,
        v_ci_end_dt,
        v_grading_schema_cd,
        v_gs_version_number,
        v_error_code,
        v_load_file_flag,
        v_load_record_flag,
        v_ugi_rec.unit_class,
        v_ugi_rec.location_cd,
        v_ugi_rec.manual_override_flag,
        v_ugi_rec.mark_capped_flag,
        v_ugi_rec.release_date,
        v_ugi_rec.uoo_id
      );
      IF v_load_file_flag = 'N' THEN
        v_load_file_master := 'N';
      END IF;
      UPDATE igs_as_ug_interface
         SET error_code = v_error_code,
             grade = v_grade
       WHERE ROWID = v_ugi_rec.ROWID;
     end if ;
    END LOOP;
    COMMIT;
    FOR v_ugi_rec IN c_upload_outcome_ugi_upd LOOP
      -- Initialize variables here.
      v_cal_type := v_ugi_rec.cal_type;
      v_ci_sequence_number := v_ugi_rec.ci_sequence_number;
      v_grade := v_ugi_rec.grade;
      --

      IF (UPPER (NVL (v_ugi_rec.manual_override_flag, 'N')) <> 'Y') THEN
        v_ugi_rec.manual_override_flag := 'N';
      ELSE
        v_ugi_rec.manual_override_flag := 'Y';
      END IF;
      --
      IF (UPPER (NVL (v_ugi_rec.mark_capped_flag, 'N')) <> 'Y') THEN
        v_ugi_rec.mark_capped_flag := 'N';
      ELSE
        v_ugi_rec.mark_capped_flag := 'Y';
      END IF;

	--
	-- FND_LOGGING
	--
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
	fnd_log.string (fnd_log.level_statement,
		'igs.plsql.igs_as_adi_upld_ug_pkg.grading_period_grade_process.c_upload_outcome_ugi_upd',
		'v_ugi_rec.person_number => '||v_ugi_rec.person_number||';'||
		'v_ugi_rec.anonymous_id => '||v_ugi_rec.anonymous_id||';'||
		'v_cal_type => '||v_cal_type||';'||
		'v_ci_sequence_number =>'||v_ci_sequence_number||';'||
		'v_grade =>'||v_grade||';'
		);
	END IF;

	igs_as_ug_val_upld (
        v_ugi_rec.person_number,
        v_ugi_rec.anonymous_id,
        v_ugi_rec.alternate_code,
        v_ugi_rec.course_cd,
        v_ugi_rec.unit_cd,
        v_ugi_rec.grading_period_cd,
        v_ugi_rec.mark,
        v_grade,
        v_person_id,
        v_cal_type,
        v_ci_sequence_number,
        v_ci_start_dt,
        v_ci_end_dt,
        v_grading_schema_cd,
        v_gs_version_number,
        v_error_code,
        v_load_file_flag,
        v_load_record_flag,
        v_ugi_rec.unit_class,
        v_ugi_rec.location_cd,
        v_ugi_rec.manual_override_flag,
        v_ugi_rec.mark_capped_flag,
        v_ugi_rec.release_date,
        v_ugi_rec.uoo_id
      );
      IF v_load_record_flag = 'Y' THEN
        -- anilk, 22-Apr-2003, Bug# 2829262

        -- BUG # 2735673 UOO_ID is added to the interface table.  So no need to quary for UOO_ID from the tables.
        -- Still keeping this cursor if user does not provide the uoo_id in the interface table
        -- and wants to upload
 IF v_ugi_rec.uoo_id IS NULL THEN
        OPEN c_sua_uoo(
               v_person_id,
               v_ugi_rec.course_cd,
               v_ugi_rec.unit_cd,
               v_cal_type,
               v_ci_sequence_number,
               v_ugi_rec.location_cd,
               v_ugi_rec.unit_class
               );
        FETCH c_sua_uoo INTO l_uoo_id;
        CLOSE c_sua_uoo;
        v_ugi_rec.uoo_id := l_uoo_id;
  END IF;

        OPEN c_suao (
               v_person_id,
               v_ugi_rec.course_cd,
               v_ugi_rec.unit_cd,
               v_cal_type,
               v_ci_sequence_number,
               v_ugi_rec.grading_period_cd,
               v_ugi_rec.uoo_id
             );

        FETCH c_suao INTO v_rowid;
        IF c_suao%FOUND THEN
          BEGIN
            OPEN c_suao_record (v_rowid);
            FETCH c_suao_record INTO rec_suao_record;
            CLOSE c_suao_record;
            -- that means record is already exists in base table

            IF v_ugi_rec.grading_period_cd = 'EARLY_FINAL' THEN
                v_ugi_rec.grading_period_cd := 'FINAL';
            END IF;

            igs_as_su_stmptout_pkg.update_row (
              x_rowid                        => v_rowid,
              x_person_id                    => v_person_id,
              x_course_cd                    => v_ugi_rec.course_cd,
              x_unit_cd                      => v_ugi_rec.unit_cd,
              x_cal_type                     => v_cal_type,
              x_ci_sequence_number           => v_ci_sequence_number,
              x_outcome_dt                   => v_outcome_dt,
              x_ci_start_dt                  => v_ci_start_dt,
              x_ci_end_dt                    => v_ci_end_dt,
              x_grading_schema_cd            => v_grading_schema_cd,
              x_version_number               => v_gs_version_number,
              x_grade                        => v_ugi_rec.grade,
              x_s_grade_creation_method_type => v_s_grade_creation_method_type,
              x_finalised_outcome_ind        => v_finalised_outcome_ind,
              x_mark                         => v_ugi_rec.mark,
              x_number_times_keyed           => v_number_times_keyed,
              x_translated_grading_schema_cd => rec_suao_record.translated_grading_schema_cd,
              x_translated_version_number    => rec_suao_record.translated_version_number,
              x_translated_grade             => rec_suao_record.translated_grade,
              x_translated_dt                => rec_suao_record.translated_dt,
              x_mode                         => 'S',
              x_grading_period_cd            => v_ugi_rec.grading_period_cd,
              x_attribute_category           => rec_suao_record.attribute_category,
              x_attribute1                   => rec_suao_record.attribute1,
              x_attribute2                   => rec_suao_record.attribute2,
              x_attribute3                   => rec_suao_record.attribute3,
              x_attribute4                   => rec_suao_record.attribute4,
              x_attribute5                   => rec_suao_record.attribute5,
              x_attribute6                   => rec_suao_record.attribute6,
              x_attribute7                   => rec_suao_record.attribute7,
              x_attribute8                   => rec_suao_record.attribute8,
              x_attribute9                   => rec_suao_record.attribute9,
              x_attribute10                  => rec_suao_record.attribute10,
              x_attribute11                  => rec_suao_record.attribute11,
              x_attribute12                  => rec_suao_record.attribute12,
              x_attribute13                  => rec_suao_record.attribute13,
              x_attribute14                  => rec_suao_record.attribute14,
              x_attribute15                  => rec_suao_record.attribute15,
              x_attribute16                  => rec_suao_record.attribute16,
              x_attribute17                  => rec_suao_record.attribute17,
              x_attribute18                  => rec_suao_record.attribute18,
              x_attribute19                  => rec_suao_record.attribute19,
              x_attribute20                  => rec_suao_record.attribute20,
              x_incomp_deadline_date         => v_ugi_rec.incomp_deadline_date,
              x_incomp_grading_schema_cd     => rec_suao_record.incomp_grading_schema_cd,
              x_incomp_version_number        => rec_suao_record.incomp_version_number,
              x_incomp_default_grade         => v_ugi_rec.incomp_default_grade,
              x_incomp_default_mark          => v_ugi_rec.incomp_default_mark,
              x_comments                     => v_ugi_rec.comments,
              x_uoo_id                       => v_ugi_rec.uoo_id,
              x_mark_capped_flag             => v_ugi_rec.mark_capped_flag,
              x_release_date                 => v_ugi_rec.release_date,
              x_manual_override_flag         => v_ugi_rec.manual_override_flag,
              x_show_on_academic_histry_flag => rec_suao_record.show_on_academic_histry_flag
            );
          EXCEPTION
            WHEN OTHERS THEN
              DECLARE
                app_short_name VARCHAR2 (10);
                message_name   VARCHAR2 (100);
              BEGIN
                fnd_file.put_line (fnd_file.LOG, 'SQL Error Message :' || SQLERRM);
                fnd_message.parse_encoded (
                  fnd_message.get_encoded,
                  app_short_name,
                  message_name
                );
                retcode := 2;
                errbuf := message_name;
                IF (errbuf IS NOT NULL) THEN
                  UPDATE igs_as_ug_interface
                  SET  error_code = errbuf
                  WHERE rowid = v_ugi_rec.rowid;
                END IF;
              END;
          END;
        ELSE  -- records is not exist in base table
          BEGIN
            IF v_ugi_rec.grading_period_cd = 'EARLY_FINAL' THEN
                v_ugi_rec.grading_period_cd := 'FINAL';
            END IF;
            igs_as_su_stmptout_pkg.insert_row (
              x_rowid                        => v_rowid,
              x_org_id                       => NULL,
              x_person_id                    => v_person_id,
              x_course_cd                    => v_ugi_rec.course_cd,
              x_unit_cd                      => v_ugi_rec.unit_cd,
              x_cal_type                     => v_cal_type,
              x_ci_sequence_number           => v_ci_sequence_number,
              x_outcome_dt                   => v_outcome_dt,
              x_ci_start_dt                  => v_ci_start_dt,
              x_ci_end_dt                    => v_ci_end_dt,
              x_grading_schema_cd            => v_grading_schema_cd,
              x_version_number               => v_gs_version_number,
              x_grade                        => v_ugi_rec.grade,
              x_s_grade_creation_method_type => v_s_grade_creation_method_type,
              x_finalised_outcome_ind        => v_finalised_outcome_ind,
              x_mark                         => v_ugi_rec.mark,
              x_number_times_keyed           => v_number_times_keyed,
              x_translated_grading_schema_cd => NULL,
              x_translated_version_number    => NULL,
              x_translated_grade             => NULL,
              x_translated_dt                => NULL,
              x_mode                         => 'S',
              x_grading_period_cd            => v_ugi_rec.grading_period_cd,
              x_attribute_category           => NULL,
              x_attribute1                   => NULL,
              x_attribute2                   => NULL,
              x_attribute3                   => NULL,
              x_attribute4                   => NULL,
              x_attribute5                   => NULL,
              x_attribute6                   => NULL,
              x_attribute7                   => NULL,
              x_attribute8                   => NULL,
              x_attribute9                   => NULL,
              x_attribute10                  => NULL,
              x_attribute11                  => NULL,
              x_attribute12                  => NULL,
              x_attribute13                  => NULL,
              x_attribute14                  => NULL,
              x_attribute15                  => NULL,
              x_attribute16                  => NULL,
              x_attribute17                  => NULL,
              x_attribute18                  => NULL,
              x_attribute19                  => NULL,
              x_attribute20                  => NULL,
              x_incomp_deadline_date         => v_ugi_rec.incomp_deadline_date,
              x_incomp_grading_schema_cd     => NULL,
              x_incomp_version_number        => NULL,
              x_incomp_default_grade         => v_ugi_rec.incomp_default_grade,
              x_incomp_default_mark          => v_ugi_rec.incomp_default_mark,
              x_comments                     => v_ugi_rec.comments,
              x_uoo_id                       => v_ugi_rec.uoo_id,
              x_mark_capped_flag             => v_ugi_rec.mark_capped_flag,
              x_release_date                 => v_ugi_rec.release_date,
              x_manual_override_flag         => v_ugi_rec.manual_override_flag,
              x_show_on_academic_histry_flag => 'Y'
            );
          EXCEPTION
            WHEN OTHERS THEN
              DECLARE
                app_short_name VARCHAR2 (10);
                message_name   VARCHAR2 (100);
              BEGIN
                fnd_file.put_line (fnd_file.LOG, 'SQL Error Message :' || SQLERRM);
                fnd_message.parse_encoded (
                  fnd_message.get_encoded,
                  app_short_name,
                  message_name
                );
                retcode := 2;
                errbuf := message_name;
                IF (errbuf IS NOT NULL) THEN
                  UPDATE igs_as_ug_interface
                  SET  error_code = errbuf
                  WHERE rowid = v_ugi_rec.rowid;
                END IF;
              END;
          END;
        END IF;
        CLOSE c_suao;
      END IF;
    END LOOP;
    /*  Extracting WebADI from Concurrent Program LOV */
    IF p_grade_creation_method_type <> 'WEBADI' THEN
      v_request_id := fnd_request.submit_request ('IGS', 'IGSASS24', NULL, NULL, FALSE, p_user_id, p_batch_datetime, p_delete_rows);
      IF v_request_id = 0 THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
--
-- FND_LOGGING
--
IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	fnd_log.string ( fnd_log.level_procedure,
		'igs.plsql.igs_as_adi_upld_ug_pkg.grading_period_grade_process.end',
		'Exiting IGS_AS_ADI_UPLD_UG_PKG.grading_period_grade_process'
	     );
END IF;

    COMMIT;
  END grading_period_grade_process;
  --
  -- Validate single Grading Period record from the interface table
  -- before being uploaded.  This validation is called from the interface
  -- table import routine and also the ADI pre-validation functionality.
  --
  PROCEDURE igs_as_ug_val_upld (
    p_person_number                IN     VARCHAR2,
    p_anonymous_id                 IN     VARCHAR2,
    p_alternate_code               IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_grading_period_cd            IN     VARCHAR2,
    p_mark                         IN     NUMBER,
    p_grade                        IN OUT NOCOPY VARCHAR2,
    p_person_id                    OUT NOCOPY NUMBER,
    p_cal_type                     IN OUT NOCOPY VARCHAR2,
    p_ci_sequence_number           IN OUT NOCOPY NUMBER,
    p_ci_start_dt                  OUT NOCOPY DATE,
    p_ci_end_dt                    OUT NOCOPY DATE,
    p_grading_schema_cd            OUT NOCOPY VARCHAR2,
    p_gs_version_number            OUT NOCOPY NUMBER,
    p_error_code                   OUT NOCOPY VARCHAR2,
    p_load_file_flag               OUT NOCOPY VARCHAR2,
    p_load_record_flag             OUT NOCOPY VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_location_cd                  IN     VARCHAR2,
    manual_override_flag           IN     VARCHAR2,
    mark_capped_flag               IN     VARCHAR2,
    release_date                   IN     DATE,
    p_uoo_id                       IN NUMBER
  ) IS
    --
    v_key_mark_mndtry_ind       VARCHAR2 (1);
    v_key_grade_derive_ind      VARCHAR2 (1);
    v_key_allow_invalid_ind     VARCHAR2 (1);
    v_upld_person_no_exist      VARCHAR2 (1);
    v_upld_crs_not_enrolled     VARCHAR2 (1);
    v_upld_unit_not_enrolled    VARCHAR2 (1);
    v_upld_unit_discont         VARCHAR2 (1);
    v_upld_grade_invalid        VARCHAR2 (1);
    v_upld_mark_grade_invalid   VARCHAR2 (1);
    v_upld_ug_sbmtd_grade_exist VARCHAR2 (1);
    v_upld_ug_saved_grade_exist VARCHAR2 (1);
    v_key_mark_entry_dec_points NUMBER;
    v_course_attempt_status     VARCHAR2 (30);
    v_unit_attempt_status       VARCHAR2 (30);
    v_uoo_id                    NUMBER;
    v_finalized_outcome_ind     VARCHAR2 (1);
    v_mark                      NUMBER (6, 3);
    v_grade                     VARCHAR2 (5);
    v_lower_mark_range          NUMBER (3);
    v_upper_mark_range          NUMBER (3);
    v_grading_schema_cd         VARCHAR2 (10);
    v_gs_version_number         NUMBER (3);
    v_submission_status         VARCHAR2 (20);
    v_dummy                     VARCHAR2 (1);
    v_result_type               VARCHAR2 (30);
    --
    --
    --
    CURSOR cur_uoo_id IS
      SELECT uoo_id
      FROM   igs_ps_unit_ofr_opt
      WHERE  unit_cd = p_unit_cd
      AND    cal_type = p_cal_type
      AND    ci_sequence_number = p_ci_sequence_number
      AND    location_cd = p_location_cd
      AND    unit_class = p_unit_class;
    rec_uoo_id                  cur_uoo_id%ROWTYPE;
    --
    -- Grade Period Start Date
    --
    CURSOR c_grd_st IS
      SELECT 'X'
      FROM   igs_ca_da_inst_v
      WHERE  cal_type = p_cal_type
      AND    ci_sequence_number = p_ci_sequence_number
      AND    dt_alias = (SELECT DECODE (
                                  p_grading_period_cd,
                                  'FINAL', final_mgs_start_dt_alias,
                                  'MIDTERM', mid_mgs_start_dt_alias,
                                  'EARLY_FINAL', efinal_mgs_start_dt_alias,
                                  NULL
                                )
                         FROM   igs_as_cal_conf
                         WHERE  s_control_num = 1)
      AND    alias_val <= SYSDATE;
    --
    -- Get Grade Entry Configuration
    --
    CURSOR c_ec IS
      SELECT key_grade_derive_ind,
             key_allow_invalid_ind,
             upld_person_no_exist,
             upld_crs_not_enrolled,
             upld_unit_not_enrolled,
             upld_unit_discont,
             upld_grade_invalid,
             upld_mark_grade_invalid,
             upld_ug_sbmtd_grade_exist,
             upld_ug_saved_grade_exist,
             key_mark_mndtry_ind,
             key_mark_entry_dec_points
      FROM   igs_as_entry_conf ec
      WHERE  ec.s_control_num = 1;
    --
    --
    --
    CURSOR c_ci IS
      SELECT ci.cal_type,
             ci.sequence_number,
             ci.start_dt,
             ci.end_dt
      FROM   igs_ca_inst_all ci,
             igs_ca_type ct,
             igs_ca_stat cs
      WHERE /* (ci.alternate_code = p_alternate_code
              OR p_alternate_code IS NULL
             )
      AND  */  ((ci.cal_type = p_cal_type
               AND ci.sequence_number = p_ci_sequence_number
              )
              OR p_cal_type IS NULL
             )
      AND    ct.cal_type = ci.cal_type
      AND    ct.s_cal_cat = 'TEACHING'
      AND    cs.cal_status = ci.cal_status
      AND    cs.s_cal_status = 'ACTIVE';
    --
    -- Get Person ID
    --
    CURSOR c_p IS
      SELECT p.party_id
      FROM   hz_parties p
      WHERE  p.party_number = p_person_number;
    --
    -- Get Student Program Attempt status
    --
    CURSOR c_spa IS
      SELECT spa.course_attempt_status
      FROM   igs_en_stdnt_ps_att spa
      WHERE  spa.person_id = p_person_id
      AND    spa.course_cd = p_course_cd;
    --
    -- Get Student Unit Attempt details
    --
    CURSOR c_sua (
      cp_uoo_id                             igs_en_su_attempt.uoo_id%TYPE
    ) IS
      SELECT sua.unit_attempt_status,
             NVL (ugs.grading_schema_code, ungs.GRADING_SCHEMA_CODE),
             NVL (ugs.grd_schm_version_number, ungs.GRD_SCHM_VERSION_NUMBER)
      FROM   igs_en_su_attempt sua,
             --igs_ps_unit_ofr_opt uoo,
             IGS_PS_UNIT_GRD_SCHM ungs,
             igs_ps_usec_grd_schm ugs
      WHERE  sua.person_id = p_person_id
      AND    sua.course_cd = p_course_cd
      AND    sua.unit_cd = p_unit_cd
      AND    sua.uoo_id = cp_uoo_id
      AND    ungs.unit_code = sua.unit_cd
      AND    ungs.unit_version_number = sua.version_number
      AND    ungs.default_flag = 'Y'
      AND    sua.uoo_id = ugs.uoo_id(+)
      AND    ugs.default_flag(+) = 'Y';
    --
    -- Get saved or submitted grades
    --
    CURSOR c_suao (
      cp_cal_type                           igs_en_su_attempt.cal_type%TYPE,
      cp_ci_sequence_number                 igs_en_su_attempt.ci_sequence_number%TYPE,
      cp_uoo_id                             igs_en_su_attempt.uoo_id%TYPE
    ) IS
      SELECT suao.mark,
             suao.grade,
             suao.finalised_outcome_ind
      FROM   igs_as_su_stmptout_all suao
      WHERE  suao.person_id = p_person_id
      AND    suao.course_cd = p_course_cd
      -- anilk, 22-Apr-2003, Bug# 2829262
      AND    suao.uoo_id = cp_uoo_id
      AND    suao.grading_period_cd = p_grading_period_cd;
    --
    -- Get Grading Schema details
    --
    CURSOR c_gsg (
      cp_grading_schema_cd                  igs_as_grd_sch_grade.grading_schema_cd%TYPE,
      cp_gs_version_number                  igs_as_grd_sch_grade.version_number%TYPE
    ) IS
      SELECT gsg.lower_mark_range,
             gsg.upper_mark_range,
             gsg.s_result_type
      FROM   igs_as_grd_sch_grade gsg
      WHERE  gsg.grading_schema_cd = cp_grading_schema_cd
      AND    gsg.version_number = cp_gs_version_number
      AND    gsg.grade = p_grade
      AND    gsg.system_only_ind = 'N';
    --
    -- Derive Grade
    --
    CURSOR c_gsg_derive (
      cp_grading_schema_cd                  igs_as_grd_sch_grade.grading_schema_cd%TYPE,
      cp_gs_version_number                  igs_as_grd_sch_grade.version_number%TYPE
    ) IS
      SELECT gsg.grade
      FROM   igs_as_grd_sch_grade gsg
      WHERE  gsg.grading_schema_cd = cp_grading_schema_cd
      AND    gsg.version_number = cp_gs_version_number
      AND    gsg.system_only_ind = 'N'
      AND    p_mark BETWEEN lower_mark_range AND upper_mark_range + 0.999;
    --
    -- Get Grading Submission History
    --
    CURSOR c_gsh (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
      SELECT gsh.submission_status
      FROM   igs_as_gaa_sub_hist gsh
      WHERE  gsh.uoo_id = cp_uoo_id
      AND    gsh.grading_period_cd = p_grading_period_cd;
    --
    -- Check Grading Period Cohorts
    --
    CURSOR c_gpc IS
      SELECT 'X'
      FROM   DUAL
      WHERE  EXISTS ( SELECT 'X'
                      FROM   igs_as_gpc_programs gpr
                      WHERE  gpr.course_cd = p_course_cd
                      AND    gpr.grading_period_cd = p_grading_period_cd)
      OR     EXISTS ( SELECT 'X'
                      FROM   igs_en_stdnt_ps_att spa,
                             igs_as_gpc_aca_stndg gas
                      WHERE  spa.person_id = p_person_id
                      AND    spa.course_cd = p_course_cd
                      AND    spa.progression_status = gas.progression_status
                      AND    gas.grading_period_cd = p_grading_period_cd)
      OR     EXISTS ( SELECT 'X'
                      FROM   igs_pe_prsid_grp_mem pigm,
                             igs_as_gpc_pe_id_grp gpg
                      WHERE  p_person_id = pigm.person_id
                      AND    pigm.GROUP_ID = gpg.GROUP_ID
                      AND    gpg.grading_period_cd = p_grading_period_cd)
      OR     EXISTS ( SELECT 'X'
                      FROM   igs_as_gpc_cls_stndg gcs
                      WHERE  gcs.class_standing = igs_pr_get_class_std.get_class_standing (
                                                    p_person_id,
                                                    p_course_cd,
                                                    'N',
                                                    SYSDATE,
                                                    NULL,
                                                    NULL
                                                  )
                      AND    gcs.grading_period_cd = p_grading_period_cd)
      OR     EXISTS ( SELECT 'X'
                      FROM   igs_as_su_setatmpt susa,
                             igs_as_gpc_unit_sets gus
                      WHERE  susa.person_id = p_person_id
                      AND    susa.course_cd = p_course_cd
                      AND    susa.selection_dt IS NOT NULL
                      AND    (susa.end_dt IS NULL
                              OR susa.rqrmnts_complete_ind = 'Y'
                             )
                      AND    susa.unit_set_cd = gus.unit_set_cd
                      AND    gus.grading_period_cd = p_grading_period_cd);
    --
    -- Get the Minimum of the Lower and Maximum of the Upper Mark limits
    -- as setup in the Grading Schema
    --
    CURSOR c_gsg_min_max (
             cp_grading_schema_cd                  igs_as_grd_sch_grade.grading_schema_cd%TYPE,
             cp_gs_version_number                  igs_as_grd_sch_grade.version_number%TYPE
           ) IS
      SELECT NVL (MIN (gsg.lower_mark_range), 0) min_lower_mark_range,
             NVL (MAX (gsg.upper_mark_range), 1000) max_upper_mark_range
      FROM   igs_as_grd_sch_grade gsg
      WHERE  gsg.grading_schema_cd = cp_grading_schema_cd
      AND    gsg.version_number = cp_gs_version_number;
    rec_gsg_min_max c_gsg_min_max%ROWTYPE;
    --
  BEGIN
    --
    -- Initialise variables
    --
    p_load_file_flag := 'Y';
    p_load_record_flag := 'Y';
    -- anilk, 22-Apr-2003, Bug# 2829262

        -- BUG # 2735673 UOO_ID is added to the interface table.  So no need to quary for UOO_ID from the tables.
        -- Still keeping this cursor if user does not provide the uoo_id in the interface table
        -- and wants to upload


IF p_uoo_id IS NULL THEN
    OPEN cur_uoo_id;
    FETCH cur_uoo_id INTO rec_uoo_id;
    v_uoo_id := rec_uoo_id.uoo_id;
    CLOSE cur_uoo_id;
 ELSE
         v_uoo_id := p_uoo_id;
END IF;

    --
    -- Get the Calendar Instance details
    --
    OPEN c_ci;

    FETCH c_ci INTO p_cal_type,
                    p_ci_sequence_number,
                    p_ci_start_dt,
                    p_ci_end_dt;
    IF c_ci%NOTFOUND THEN
      CLOSE c_ci;
      p_error_code := 'IGS_AS_MISSING_ALTNTE_CODE';
      p_load_file_flag := 'N';
      RETURN;
    END IF;
    CLOSE c_ci;
    --
    -- Get Grade Entry Configuration
    --
    OPEN c_ec;
    FETCH c_ec INTO v_key_grade_derive_ind,
                    v_key_allow_invalid_ind,
                    v_upld_person_no_exist,
                    v_upld_crs_not_enrolled,
                    v_upld_unit_not_enrolled,
                    v_upld_unit_discont,
                    v_upld_grade_invalid,
                    v_upld_mark_grade_invalid,
                    v_upld_ug_sbmtd_grade_exist,
                    v_upld_ug_saved_grade_exist,
                    v_key_mark_mndtry_ind,
                    v_key_mark_entry_dec_points;
    CLOSE c_ec;
    --
    -- Check number of decimal places in marks
    --
    IF (LENGTH (p_mark) - LENGTH (FLOOR (p_mark)) - 1) > v_key_mark_entry_dec_points THEN
      p_error_code := 'IGS_AS_MORE_DECIMAL_PLACES';
      p_load_record_flag := 'N';
      RETURN;
    END IF;
    --
    -- Get Person id  AND Person Does Not Exist --
    --
    IF  p_person_number IS NULL
        AND p_anonymous_id IS NULL THEN
      IF v_upld_person_no_exist = 'D' THEN
        p_error_code := 'IGS_AS_ASD_AN_NO_PERSON_EXIST';
        p_load_record_flag := 'N';
        RETURN;
      ELSIF v_upld_person_no_exist = 'A' THEN
        p_error_code := 'IGS_AS_ASA_AN_NO_PERSON_EXIST';
        p_load_file_flag := 'N';
        RETURN;
      END IF;
    ELSIF  p_person_number IS NOT NULL
           AND p_anonymous_id IS NOT NULL THEN
      p_error_code := 'IGS_AS_ASD_PER_ANON_BOTH_EXIST';
      p_load_record_flag := 'N';
      RETURN;
    ELSIF  p_person_number IS NULL
           AND p_anonymous_id IS NOT NULL THEN
      --
      -- Call function to get Person ID based on Anonymous ID
      --
      p_person_id := igs_as_anon_grd_pkg.get_person_id (p_anonymous_id, p_cal_type, p_ci_sequence_number);
      IF p_person_id IS NULL THEN
        IF v_upld_person_no_exist = 'D' THEN
          p_error_code := 'IGS_AS_ASD_AN_NO_PERSON_EXIST';
          p_load_record_flag := 'N';
          RETURN;
        ELSIF v_upld_person_no_exist = 'A' THEN
          p_error_code := 'IGS_AS_ASA_AN_NO_PERSON_EXIST';
          p_load_file_flag := 'N';
          RETURN;
        END IF;
      END IF;
    ELSIF  p_person_number IS NOT NULL
           AND p_anonymous_id IS NULL THEN
      OPEN c_p;
      FETCH c_p INTO p_person_id;
      IF c_p%NOTFOUND THEN
        IF v_upld_person_no_exist = 'D' THEN
          p_error_code := 'IGS_AS_ASD_AN_NO_PERSON_EXIST';
          p_load_record_flag := 'N';
          RETURN;
        ELSIF v_upld_person_no_exist = 'A' THEN
          p_error_code := 'IGS_AS_ASA_AN_NO_PERSON_EXIST';
          p_load_file_flag := 'N';
          RETURN;
        END IF;
      END IF;
      CLOSE c_p;
    END IF;
    --
    -- Check Grading Period Start Date
    --
    OPEN c_grd_st;
    FETCH c_grd_st INTO v_dummy;
    IF c_grd_st%NOTFOUND THEN
      p_error_code := 'IGS_SS_AS_GRD_START_DT_VIOLATN';
      p_load_record_flag := 'N';
      RETURN;
    END IF;
    CLOSE c_grd_st;
    --
    -- Check Student Program Attempt status
    --
    OPEN c_spa;
    FETCH c_spa INTO v_course_attempt_status;
    IF c_spa%NOTFOUND
       OR v_course_attempt_status NOT IN ('ENROLLED', 'INACTIVE') THEN
      IF v_upld_crs_not_enrolled = 'D' THEN
        p_error_code := 'IGS_AS_ASD_COURSE_NOT_ENROLLED';
        p_load_record_flag := 'N';
        RETURN;
      ELSIF v_upld_crs_not_enrolled = 'A' THEN
        p_error_code := 'IGS_AS_ASA_COURSE_NOT_ENROLLED';
        p_load_file_flag := 'N';
        RETURN;
      END IF;
    END IF;
    --
    -- Check Student Unit Attempt status
    --
    OPEN c_sua (
           v_uoo_id
         );
    FETCH c_sua INTO v_unit_attempt_status,
                     v_grading_schema_cd,
                     v_gs_version_number;
    IF c_sua%NOTFOUND THEN
      IF v_upld_unit_not_enrolled = 'D' THEN
        p_error_code := 'IGS_AS_ASD_UNIT_NOT_ENROLLED';
        p_load_record_flag := 'N';
        RETURN;
      ELSIF v_upld_unit_not_enrolled = 'A' THEN
        p_error_code := 'IGS_AS_ASA_UNIT_NOT_ENROLLED';
        p_load_file_flag := 'N';
        RETURN;
      END IF;
    END IF;
    IF v_unit_attempt_status = 'DISCONTIN' THEN
      IF v_upld_unit_discont = 'D' THEN
        p_error_code := 'IGS_AS_ASD_UNIT_DISCONTINUED';
        p_load_record_flag := 'N';
        RETURN;
      ELSIF v_upld_unit_discont = 'A' THEN
        p_error_code := 'IGS_AS_ASA_UNIT_DISCONTINUED';
        p_load_file_flag := 'N';
        RETURN;
      END IF;
    ELSIF v_unit_attempt_status <> 'ENROLLED' THEN
      IF v_upld_unit_not_enrolled = 'D' THEN
        p_error_code := 'IGS_AS_ASD_UNIT_NOT_ENROLLED';
        p_load_record_flag := 'N';
        RETURN;
      ELSIF v_upld_unit_not_enrolled = 'A' THEN
        p_error_code := 'IGS_AS_ASA_UNIT_NOT_ENROLLED';
        p_load_file_flag := 'N';
        RETURN;
      END IF;
    END IF;
    --
    OPEN c_gsg_min_max (
           v_grading_schema_cd,
           v_gs_version_number
         );
    FETCH c_gsg_min_max INTO rec_gsg_min_max;
    CLOSE c_gsg_min_max;
    IF ((p_mark < rec_gsg_min_max.min_lower_mark_range) OR
        (p_mark > rec_gsg_min_max.max_upper_mark_range)) THEN
      p_error_code := 'IGS_AS_MARK_INVALID';
      p_load_record_flag := 'N';
      RETURN;
    END IF;
    --
    -- Check if Submitted or Saved grade exists
    --
    OPEN c_suao (
           p_cal_type,
           p_ci_sequence_number,
                 v_uoo_id
         );
    FETCH c_suao INTO v_mark,
                      v_grade,
                      v_finalized_outcome_ind;
    IF c_suao%FOUND THEN
      IF  v_mark = p_mark
          AND v_grade = p_grade THEN
        p_error_code := 'IGS_AS_ASD_DUPLICATE_RECORD';
        p_load_record_flag := 'N';
        RETURN;
      ELSIF v_finalized_outcome_ind = 'Y' THEN
        IF v_upld_ug_sbmtd_grade_exist = 'D' THEN
          p_error_code := 'IGS_AS_ASD_GP_GRADE_SUBMITTED';
          p_load_record_flag := 'N';
          RETURN;
        ELSIF v_upld_ug_sbmtd_grade_exist = 'A' THEN
          p_error_code := 'IGS_AS_ASA_GP_GRADE_SUBMITTED';
          p_load_file_flag := 'N';
          RETURN;
        END IF;
      ELSIF v_finalized_outcome_ind = 'N' THEN
        IF v_upld_ug_saved_grade_exist = 'D' THEN
          p_error_code := 'IGS_AS_ASD_GP_GRADE_EXIST';
          p_load_record_flag := 'N';
          RETURN;
        ELSIF v_upld_ug_saved_grade_exist = 'A' THEN
          p_error_code := 'IGS_AS_ASA_GP_GRADE_EXIST';
          p_load_file_flag := 'N';
          RETURN;
        ELSIF v_upld_ug_saved_grade_exist = 'W' THEN
          p_error_code := 'IGS_AS_ASW_GP_GRADE_EXIST';
        END IF;
      END IF;
      CLOSE c_suao;
    END IF;
    --
    -- Grade Invalid
    --
    OPEN c_gsg (v_grading_schema_cd, v_gs_version_number);
    FETCH c_gsg INTO v_lower_mark_range,
                     v_upper_mark_range,
                     v_result_type;
    IF (c_gsg%NOTFOUND
        AND p_grade IS NOT NULL
       )
       OR (v_key_grade_derive_ind = 'N'
           AND p_grade IS NULL
          )
       OR (p_mark IS NULL
           AND p_grade IS NULL
          ) THEN
      IF v_upld_grade_invalid = 'D' THEN
        p_error_code := 'IGS_AS_ASD_GRADE_INVALID';
        p_load_record_flag := 'N';
        RETURN;
      ELSIF v_upld_grade_invalid = 'A' THEN
        p_error_code := 'IGS_AS_ASA_GRADE_INVALID';
        p_load_file_flag := 'N';
        RETURN;
      END IF;
    ELSE
      -- Mark Grade Combination Invalid
      IF  v_key_allow_invalid_ind = 'N'
          AND p_mark IS NOT NULL THEN
        IF p_mark NOT BETWEEN v_lower_mark_range AND v_upper_mark_range THEN
          IF v_upld_mark_grade_invalid = 'D' THEN
            p_error_code := 'IGS_AS_ASD_MARK_GRADE_INVALID';
            p_load_record_flag := 'N';
            RETURN;
          ELSIF v_upld_mark_grade_invalid = 'A' THEN
            p_error_code := 'IGS_AS_ASA_MARK_GRADE_INVALID';
            p_load_file_flag := 'N';
            RETURN;
          ELSIF v_upld_mark_grade_invalid = 'W' THEN
            p_error_code := 'IGS_AS_ASW_MARK_GRADE_INVALID';
          END IF; --setup combination invalid
        END IF; --mark not between range
      END IF;
    END IF;
    --
    -- Derive Grade
    --
    IF  v_key_grade_derive_ind = 'Y'
        AND p_mark IS NOT NULL
        AND p_grade IS NULL THEN
      OPEN c_gsg_derive (v_grading_schema_cd, v_gs_version_number);
      FETCH c_gsg_derive INTO p_grade;
      IF c_gsg_derive%NOTFOUND THEN
        p_error_code := 'IGS_AS_ASD_MARK_GRADE_INVALID';
        p_load_record_flag := 'N';
        RETURN;
      END IF;
      CLOSE c_gsg_derive;
    END IF;
    p_grading_schema_cd := v_grading_schema_cd;
    p_gs_version_number := v_gs_version_number;
    --
    -- Check Mark Entry Mandatory
    --
    IF  v_key_mark_mndtry_ind = 'Y'
        AND p_mark IS NULL
        AND v_result_type <> 'INCOMP' THEN
      p_error_code := 'IGS_SS_AS_MARK_MANDATORY';
      p_load_record_flag := 'N';
      RETURN;
    END IF;
    --
    -- Check Grading Period Cohorts
    -- Cohorts are only considerd for Mid Term and Early Final
    --
    IF p_grading_period_cd <> 'FINAL' THEN
      OPEN c_gsh (v_uoo_id);
      FETCH c_gsh INTO v_submission_status;
      IF c_gsh%NOTFOUND
         OR v_submission_status = 'Incomplete' THEN
        OPEN c_gpc;
        FETCH c_gpc INTO v_dummy;
        IF c_gpc%NOTFOUND THEN
          p_error_code := 'IGS_AS_ASD_NO_COHORT_SETUP';
          p_load_record_flag := 'N';
          RETURN;
        END IF;
        CLOSE c_gpc;
      END IF;
      CLOSE c_gsh;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_load_file_flag := 'N';
      p_load_record_flag := 'N';
      p_error_code := 'No Data Found - Others';
  END igs_as_ug_val_upld;
END igs_as_adi_upld_ug_pkg;

/
