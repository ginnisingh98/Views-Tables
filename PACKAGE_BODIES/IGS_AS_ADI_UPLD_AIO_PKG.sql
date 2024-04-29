--------------------------------------------------------
--  DDL for Package Body IGS_AS_ADI_UPLD_AIO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_ADI_UPLD_AIO_PKG" AS
/* $Header: IGSAS44B.pls 120.7 2006/05/29 06:26:14 ijeddy ship $ */
  --
  FUNCTION get_sua_yop (
    p_person_id                    IN     igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN     igs_en_su_attempt.course_cd%TYPE,
    p_teach_cal_type               IN     igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN     igs_en_su_attempt.ci_sequence_number%TYPE
  ) RETURN VARCHAR2 AS
    --
    -- This function returns the Unit Set Code of any YOP specific Student Unit
    -- Set Attempts which have Selection and Requirements Complete/End Dates
    -- which span the Census Date of the Teaching Period provided. If more than
    -- one exists the one with the latest selection date will be returned
    --
    v_unit_set_cd igs_en_unit_set.unit_set_cd%TYPE;
    --
    --
    --
    CURSOR c_susa IS
      SELECT   us.title
      FROM     igs_as_su_setatmpt susa,
               igs_en_unit_set us,
               igs_en_unit_set_cat usc
      WHERE    p_person_id = susa.person_id
      AND      p_course_cd = susa.course_cd
      AND      (igs_en_gen_015.get_effective_census_date (
                  NULL,
                  NULL,
                  p_teach_cal_type,
                  p_teach_ci_sequence_number
                ) BETWEEN susa.selection_dt
                      AND NVL (susa.rqrmnts_complete_dt,
                               NVL (susa.end_dt,
                                    fnd_date.canonical_to_date ('9999/12/31'))))
      AND      susa.unit_set_cd = us.unit_set_cd
      AND      us.unit_set_cat = usc.unit_set_cat
      AND      usc.s_unit_set_cat = 'PRENRL_YR'
      ORDER BY susa.selection_dt DESC;
    --
  BEGIN
    --
    OPEN c_susa;
    FETCH c_susa INTO v_unit_set_cd;
    --
    IF c_susa%FOUND THEN
      CLOSE c_susa;
      RETURN v_unit_set_cd;
    ELSE
      CLOSE c_susa;
      RETURN NULL;
    END IF;
    --
  END get_sua_yop;
  --
  -- Validate the Assessment Item Outcome records before inserting them into
  -- base table and call table handlers
  --
  PROCEDURE assessment_item_grade_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2 DEFAULT 'Y'
  ) IS
  BEGIN
    DECLARE
      p_batch_date               DATE := TO_DATE (p_batch_datetime, 'YYYY/MM/DD HH24:MI:SS');
      --
      -- Get the uoo_id based on the pk columns for Unit Section
      --
      CURSOR cur_uoo_id (
        cp_unit_cd                            igs_en_su_attempt.unit_cd%TYPE,
        cp_version_number                     igs_en_su_attempt.version_number%TYPE,
        cp_cal_type                           igs_en_su_attempt.cal_type%TYPE,
        cp_ci_sequence_number                 igs_en_su_attempt.ci_sequence_number%TYPE,
        cp_unit_class                         igs_en_su_attempt.unit_class%TYPE,
        cp_location_cd                        igs_en_su_attempt.location_cd%TYPE
      ) IS
        SELECT uoo_id
        FROM   igs_ps_unit_ofr_opt
        WHERE  unit_cd = cp_unit_cd
        --AND    version_number = cp_version_number
        AND    cal_type = cp_cal_type
        AND    ci_sequence_number = cp_ci_sequence_number
        AND    unit_class = cp_unit_class
        AND    location_cd = cp_location_cd;
      --
      rec_uoo_id                 cur_uoo_id%ROWTYPE;
      --
      -- Get the Assessment Item Outcomes from the Assessment Item Outcome
      -- Interface table. The data from this interface table is the data that is
      -- being uploaded currently and once the data is uploaded it is deleted
      -- from the Interface table.
      --
      CURSOR c_upload_outcome_ai IS
                SELECT user_id,
                       batch_date,
                       decode(person_number,'-',null,person_number) person_number,
                       decode(anonymous_id,'-',null,anonymous_id) anonymous_id,
                       course_cd,
                       unit_cd,
                       cal_type,
                       ci_sequence_number,
                       alternate_code,
                       ass_id,
                       assessment_type,
                       reference,
                       grade,
                       outcome_comment_code,
                       mark,
                       error_code,
                       ROWID,
                       unit_class,
                       location_cd,
                       override_due_dt,
                       penalty_applied_flag,
                       waived_flag,
                       submitted_date,
                       uoo_id
                FROM   igs_as_aio_interface
                WHERE  user_id = p_user_id
                AND     trunc(batch_date)  =  trunc(p_batch_date)
		            AND     ass_id IS NOT NULL;
      --
      -- Get the Student Unit Attempt Assessment Item details
      --
      CURSOR cur_suaai (
        cp_person_id                          NUMBER,
        cp_course_cd                          VARCHAR2,
        cp_uoo_id                             NUMBER,
        cp_ass_id                             NUMBER,
        cp_reference                          VARCHAR2
      ) IS
        SELECT suaai.*, suaai.rowid
        FROM   igs_as_su_atmpt_itm suaai
        WHERE  suaai.person_id = cp_person_id
        AND    suaai.course_cd = cp_course_cd
        AND    suaai.uoo_id = cp_uoo_id
        AND    suaai.ass_id = cp_ass_id
        AND    igs_as_gen_003.assp_get_ai_ref (suaai.unit_section_ass_item_id, suaai.unit_ass_item_id) = cp_reference
        AND    suaai.logical_delete_dt IS NULL;
      --
      rec_suaai cur_suaai%ROWTYPE;
      --
      -- Declare local variables
      -- insert flag will update when any of the record got Abort message
      -- not load flag will update when any of the record got Do Not Load Record message.
      --
      v_person_id                NUMBER (15);
      v_cal_type                 VARCHAR2 (10);
      v_ci_sequence_number       NUMBER (6);
      v_ass_id                   NUMBER (10);
      v_grade                    VARCHAR2 (5);
      v_request_id               NUMBER;
      v_uoo_id                   NUMBER (7);
      v_error_code               VARCHAR2 (30);
      v_ret_val                  BOOLEAN;
      v_insert_flag              VARCHAR2 (1);
      v_insert_batch             VARCHAR2 (1);
      v_load_flag                VARCHAR2 (1);
      v_grading_schema_cd        VARCHAR2 (10);
      v_gs_version_number        NUMBER (3);
      v_rowid                    VARCHAR2 (25);
      v_outcome_dt               DATE DEFAULT SYSDATE;
      v_creation_dt              DATE DEFAULT SYSDATE;
      --
      l_validuser varchar2(1);
    BEGIN

      --
      IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054
--
-- FND_LOGGING
--
IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	fnd_log.string ( fnd_log.level_procedure,
		'igs.plsql.igs_as_adi_upld_aio_pkg.assessment_item_grade_process.begin',
		'Params: p_user_id  => '||p_user_id|| ';' ||
		' p_batch_datetime  => '||p_batch_datetime|| ';' ||
		' p_grade_creation_method_type  => '||p_grade_creation_method_type|| ';' ||
		' p_delete_rows  => '||p_delete_rows|| ';'
	     );
END IF;

      FOR v_aio_upld IN c_upload_outcome_ai LOOP
        --
        -- Initialize variables here.
        --
        v_cal_type := v_aio_upld.cal_type;
        v_ci_sequence_number := v_aio_upld.ci_sequence_number;
        v_ass_id := v_aio_upld.ass_id;
        v_insert_flag := 'Y';
        v_insert_batch := 'Y';
        v_load_flag := 'Y';
        v_grade := v_aio_upld.grade;
        -- Check if the user is authorised to upload data .
        -- Only admin and faculty for the unitsection can upload data to OSS.
        l_validuser:= isvaliduser (
                        v_aio_upld.user_id ,
                        v_aio_upld.uoo_id
                      );
        IF (l_validuser <> 'Y') THEN
          UPDATE igs_as_aio_interface
          SET    error_code = 'IGS_EN_PERSON_NO_RESP'
          WHERE  ROWID = v_aio_upld.ROWID;
        ELSE

	--
	-- FND_LOGGING
	--
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
	  fnd_log.string (fnd_log.level_statement,
		'igs.plsql.IGS_AS_ADI_UPLD_AIO_PKG.assessment_item_grade_process.c_upload_outcome_ai',
		'v_ugi_rec.person_number => '||v_aio_upld.person_number||';'||
		'v_ugi_rec.anonymous_id => '||v_aio_upld.anonymous_id||';'||
		'v_cal_type => '||v_cal_type||';'||
		'v_ci_sequence_number =>'||v_ci_sequence_number||';'||
		'v_grade =>'||v_grade||';'
		);
	END IF;

          --
          -- Call routine to upload for validate the particular row
          --
          igs_as_aio_val_upld (
            v_aio_upld.person_number,
            v_person_id,
            v_aio_upld.anonymous_id,
            v_aio_upld.course_cd,
            v_aio_upld.unit_cd,
            v_cal_type,
            v_ci_sequence_number,
            v_aio_upld.alternate_code,
            v_ass_id,
            v_aio_upld.assessment_type,
            v_aio_upld.REFERENCE,
            v_grading_schema_cd,
            v_gs_version_number,
            v_grade,
            v_aio_upld.mark,
            v_error_code,
            v_ret_val,
            v_insert_flag,
            v_load_flag,
            v_aio_upld.unit_class,
            v_aio_upld.location_cd,
            v_aio_upld.override_due_dt,
            v_aio_upld.penalty_applied_flag,
            v_aio_upld.waived_flag,
            v_aio_upld.submitted_date,
            v_aio_upld.uoo_id
          );
          --
          IF v_insert_flag = 'N' THEN
            v_insert_batch := 'N';
          END IF;
          --
          UPDATE igs_as_aio_interface
          SET    error_code = v_error_code,
                 grade = v_grade
           WHERE ROWID = v_aio_upld.ROWID;
        END IF;
      END LOOP;
      --
      COMMIT; -- commit the records into interface table.
      --
      /* Need to call table handlers only if any of the records does not have setup option abort.
         get the value that is there any record into interface table with Abort Status */
      --
      IF v_insert_batch = 'Y' THEN
        FOR v_aio_upld IN c_upload_outcome_ai LOOP
          IF (v_aio_upld.ERROR_CODE IS NULL OR
             (v_aio_upld.ERROR_CODE IS NOT NULL AND
              v_aio_upld.ERROR_CODE <> 'IGS_EN_PERSON_NO_RESP')) THEN
            --
            -- Initialize variables here.
            --
            v_cal_type := v_aio_upld.cal_type;
            v_ci_sequence_number := v_aio_upld.ci_sequence_number;
            v_ass_id := v_aio_upld.ass_id;
            v_grade := v_aio_upld.grade;
            --
            IF (UPPER (NVL(v_aio_upld.waived_flag, 'N')) NOT IN('N', 'Y')) THEN
              v_aio_upld.waived_flag := NULL;
            ELSE
              v_aio_upld.waived_flag := UPPER(v_aio_upld.waived_flag);
            END IF;
            --
            IF (UPPER (NVL(v_aio_upld.penalty_applied_flag, 'N')) NOT IN('N', 'Y')) THEN
              v_aio_upld.penalty_applied_flag := NULL;
            ELSE
              v_aio_upld.penalty_applied_flag := (v_aio_upld.penalty_applied_flag) ;
            END IF;

	    --
	    -- FND_LOGGING
	    --
	    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
			fnd_log.string (fnd_log.level_statement,
				'igs.plsql.IGS_AS_ADI_UPLD_AIO_PKG.assessment_item_grade_process.c_upload_outcome_ai',
				'v_ugi_rec.person_number => '||v_aio_upld.person_number||';'||
				'v_ugi_rec.anonymous_id => '||v_aio_upld.anonymous_id||';'||
				'v_cal_type => '||v_cal_type||';'||
				'v_ci_sequence_number =>'||v_ci_sequence_number||';'||
				'v_grade =>'||v_grade||';'
			);
	    END IF;

	    --
            -- Call the same procedure again for update mode, earlier we call this procedure for validate mode.
            --
            igs_as_aio_val_upld (
              v_aio_upld.person_number,
              v_person_id,
              v_aio_upld.anonymous_id,
              v_aio_upld.course_cd,
              v_aio_upld.unit_cd,
              v_cal_type,
              v_ci_sequence_number,
              v_aio_upld.alternate_code,
              v_ass_id,
              v_aio_upld.assessment_type,
              v_aio_upld.reference,
              v_grading_schema_cd,
              v_gs_version_number,
              v_grade,
              v_aio_upld.mark,
              v_error_code,
              v_ret_val,
              v_insert_flag,
              v_load_flag,
              v_aio_upld.unit_class,
              v_aio_upld.location_cd,
              v_aio_upld.override_due_dt,
              v_aio_upld.penalty_applied_flag,
              v_aio_upld.waived_flag,
              v_aio_upld.submitted_date,
              v_aio_upld.uoo_id
            );
            --
            -- start process only if load flag is 'Y'
            --
            IF v_load_flag = 'Y' THEN
              -- BUG # 2735673 UOO_ID is added to the interface table.  So no need to quary for UOO_ID from the tables.
              -- Still keeping this cursor if user does not provide the uoo_id in the interface table
              -- and wants to upload
              IF v_aio_upld.uoo_id IS NULL THEN
                OPEN cur_uoo_id (
                  v_aio_upld.unit_cd,
                  v_gs_version_number,
                  v_cal_type,
                  v_ci_sequence_number,
                  v_aio_upld.unit_class,
                  v_aio_upld.location_cd
                );
                FETCH cur_uoo_id INTO rec_uoo_id;
                CLOSE cur_uoo_id;
                v_aio_upld.uoo_id := rec_uoo_id.uoo_id;
              END IF;
              OPEN cur_suaai (
                     v_person_id,
                     v_aio_upld.course_cd,
                     v_aio_upld.uoo_id,
                     v_ass_id,
                     v_aio_upld.reference
                   );
              FETCH cur_suaai INTO rec_suaai; --l_unit_section_ass_item_id, l_unit_ass_item_id, v_rowid;
              --
              IF cur_suaai%FOUND THEN -- that means record is already exist into base table
                CLOSE cur_suaai;
                BEGIN
                  igs_as_su_atmpt_itm_pkg.update_row (
                    x_rowid                        => rec_suaai.rowid,
                    x_person_id                    => rec_suaai.person_id,
                    x_course_cd                    => rec_suaai.course_cd,
                    x_unit_cd                      => rec_suaai.unit_cd,
                    x_cal_type                     => rec_suaai.cal_type,
                    x_ci_sequence_number           => rec_suaai.ci_sequence_number,
                    x_ass_id                       => rec_suaai.ass_id,
                    x_creation_dt                  => rec_suaai.creation_dt,
                    x_attempt_number               => rec_suaai.attempt_number,
                    x_outcome_dt                   => SYSDATE,
                    x_override_due_dt              => v_aio_upld.override_due_dt,
                    x_tracking_id                  => rec_suaai.tracking_id,
                    x_logical_delete_dt            => rec_suaai.logical_delete_dt,
                    x_s_default_ind                => rec_suaai.s_default_ind,
                    x_ass_pattern_id               => rec_suaai.ass_pattern_id,
                    x_mode                         => 'S',
                    x_grading_schema_cd            => rec_suaai.grading_schema_cd,
                    x_gs_version_number            => rec_suaai.gs_version_number,
                    x_grade                        => v_aio_upld.grade,
                    x_outcome_comment_code         => 'UPLOAD',
                    x_mark                         => v_aio_upld.mark,
                    x_attribute_category           => rec_suaai.attribute_category,
                    x_attribute1                   => rec_suaai.attribute1,
                    x_attribute2                   => rec_suaai.attribute2,
                    x_attribute3                   => rec_suaai.attribute3,
                    x_attribute4                   => rec_suaai.attribute4,
                    x_attribute5                   => rec_suaai.attribute5,
                    x_attribute6                   => rec_suaai.attribute6,
                    x_attribute7                   => rec_suaai.attribute7,
                    x_attribute8                   => rec_suaai.attribute8,
                    x_attribute9                   => rec_suaai.attribute9,
                    x_attribute10                  => rec_suaai.attribute10,
                    x_attribute11                  => rec_suaai.attribute11,
                    x_attribute12                  => rec_suaai.attribute12,
                    x_attribute13                  => rec_suaai.attribute13,
                    x_attribute14                  => rec_suaai.attribute14,
                    x_attribute15                  => rec_suaai.attribute15,
                    x_attribute16                  => rec_suaai.attribute16,
                    x_attribute17                  => rec_suaai.attribute17,
                    x_attribute18                  => rec_suaai.attribute18,
                    x_attribute19                  => rec_suaai.attribute19,
                    x_attribute20                  => rec_suaai.attribute20,
                    x_uoo_id                       => rec_suaai.uoo_id,
                    x_unit_section_ass_item_id     => rec_suaai.unit_section_ass_item_id,
                    x_unit_ass_item_id             => rec_suaai.unit_ass_item_id,
                    x_sua_ass_item_group_id        => rec_suaai.sua_ass_item_group_id,
                    x_midterm_mandatory_type_code  => rec_suaai.midterm_mandatory_type_code,
                    x_midterm_weight_qty           => rec_suaai.midterm_weight_qty,
                    x_final_mandatory_type_code    => rec_suaai.final_mandatory_type_code,
                    x_final_weight_qty             => rec_suaai.final_weight_qty,
                    x_submitted_date               => v_aio_upld.submitted_date,
                    x_waived_flag                  => v_aio_upld.waived_flag,
                    x_penalty_applied_flag         => v_aio_upld.penalty_applied_flag
                  );
                EXCEPTION
                  WHEN OTHERS THEN
                    DECLARE
                      app_short_name VARCHAR2 (10);
                      message_name   VARCHAR2 (100);
                    BEGIN
                      errbuf := NULL;
                      fnd_message.parse_encoded (fnd_message.get_encoded, app_short_name, message_name);
                      retcode := 2;
                      errbuf := message_name;
                      IF (errbuf IS NOT NULL) THEN
                        UPDATE igs_as_aio_interface
                        SET    ERROR_CODE = errbuf
                        WHERE  ROWID = v_aio_upld.ROWID;
                      END IF;
                    END;
                END;
              ELSE
                CLOSE cur_suaai;
              END IF; -- rowid is not null
            END IF; -- the record is good to load
          END IF;
        END LOOP;
      END IF; --insert_batch is 'Y' or not
      /* Call Reports for generating error report with parameter and after that delete the records from Report only
         by calling after report trigger.
         ERR_REPORT (p_user_id,p_batch_date,p_delete_rows,p_header_message)*/
      /*  Extracting WebADI from Concurrent Program LOV */
      IF p_grade_creation_method_type <> 'WEBADI' THEN
        v_request_id :=
        fnd_request.submit_request ('IGS', 'IGSASS25', NULL, NULL, FALSE, p_user_id, p_batch_datetime, p_delete_rows);
      END IF;
      IF v_request_id = 0 THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

	--
	-- FND_LOGGING
	--
	IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
		fnd_log.string ( fnd_log.level_procedure,
			'igs.plsql.IGS_AS_ADI_UPLD_AIO_PKG.assessment_item_grade_process.end',
			'Exiting IGS_AS_ADI_UPLD_AIO_PKG.assessment_item_grade_process'
		     );
	END IF;

      COMMIT;
    END;
  END assessment_item_grade_process;
  --
  -- Validate the records before inserting into base table and call the table handlers
  -- This is a wrapper API to the Grade Unit and Grade Assessment Item API's
  --
  PROCEDURE assmnt_item_grade_unit_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2
  ) IS
    p_batch_date  DATE  :=  to_date(p_batch_datetime, 'YYYY/MM/DD HH24:MI:SS');
    -- Cursors to copy back the error code for UG_INTERFACE to AIO INTERFACD
	CURSOR cur_ug_err (cp_user_id number, cp_batch_date DATE,  cp_person_number VARCHAR2,
	 CP_ANONYMOUS_ID VARCHAR2, cp_uoo_id NUMBER)
	 IS SELECT ugi.error_code from IGS_AS_UG_INTERFACE UGI
	 WHERE ( (PERSON_number = cp_person_number OR ANONYMOUS_ID = CP_ANONYMOUS_ID)
	 AND user_id = cp_user_id and trunc(batch_date) = trunc(cp_batch_date)
	 AND uoo_id = cp_uoo_id and ERROR_CODE IS NOT NULL
	 );
	 CURSOR CUR_AIO_NO_ERR IS SELECT aio.* from IGS_AS_AIO_INTERFACE AIO
	 WHERE user_id = p_user_id and trunc(batch_date) = trunc(p_batch_date)
	 AND ASS_ID IS NULL
	 AND  ERROR_CODE IS  NULL
	 FOR UPDATE OF ERROR_CODE;
	v_error_code_toaio VARCHAR2(30);
  BEGIN
    assessment_item_grade_process (
      errbuf,
      retcode,
      p_user_id,
      p_batch_datetime,
      p_grade_creation_method_type,
      p_delete_rows
    );
    igs_as_adi_upld_ug_pkg.grading_period_grade_process (
      errbuf,
      retcode,
      p_user_id,
      p_batch_datetime,
      p_grade_creation_method_type,
      p_delete_rows
    );
    --- Bug# 2735673 Since the SQL Statement to identify the errored rows accept only
    -- one table as the String_Value in BNE_PARAM_LIST_ITEMS, We need to copy the eror code
    -- From UG INTERFACE TABLE TO AIO INTERFACE table show that rows can be appropriately identified in the spread sheet
    FOR AIO_NO_ERR IN CUR_AIO_NO_ERR LOOP
         -- Initialize the error code to null so that the existing one is not used to replace the next one
      v_error_code_toaio := NULL;
      OPEN cur_ug_err (AIO_NO_ERR.USER_ID, AIO_NO_ERR.batch_date, AIO_NO_ERR.person_number,AIO_NO_ERR.anonymous_id, AIO_NO_ERR.uoo_id);
      FETCH cur_ug_err into v_error_code_toaio;
      CLOSE cur_ug_err;
      UPDATE IGS_AS_AIO_INTERFACE SET ERROR_CODE = v_error_code_toaio WHERE CURRENT OF CUR_AIO_NO_ERR;
    END LOOP;
  END assmnt_item_grade_unit_process;
  --
  -- Validate single Grading Period record from the interface table before
  -- uploading it. This validation is called from the interface table import
  -- routine, and also the ADI pre-validation functionality.
  --
  PROCEDURE igs_as_aio_val_upld (
    p_person_number                IN     VARCHAR2,
    p_person_id                    OUT NOCOPY NUMBER,
    p_anonymous_id                 IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN OUT NOCOPY VARCHAR2,
    p_ci_sequence_number           IN OUT NOCOPY NUMBER,
    p_alternate_code               IN     VARCHAR2,
    p_ass_id                       IN OUT NOCOPY NUMBER,
    p_assessment_type              IN     VARCHAR2,
    p_reference                    IN     VARCHAR2,
    p_grading_schema_cd            OUT NOCOPY VARCHAR2,
    p_gs_version_number            OUT NOCOPY NUMBER,
    p_grade                        IN OUT NOCOPY VARCHAR2,
    p_mark                         IN     NUMBER,
    p_error_code                   OUT NOCOPY VARCHAR2,
    p_ret_val                      OUT NOCOPY BOOLEAN,
    p_insert_flag                  OUT NOCOPY VARCHAR2,
    p_load_flag                    OUT NOCOPY VARCHAR2,
    p_unit_class                   IN     VARCHAR2 DEFAULT NULL,
    p_location_cd                  IN     VARCHAR2 DEFAULT NULL,
    p_override_due_dt              IN     DATE DEFAULT NULL,
    p_penalty_applied_flag         IN     VARCHAR2 DEFAULT NULL,
    p_waived_flag                  IN     VARCHAR2 DEFAULT NULL,
    p_submitted_date               IN     DATE DEFAULT NULL,
    p_uoo_id                       IN NUMBER
  ) IS
    --
    v_no_program_status         VARCHAR2 (30);
    v_unit_enrolled_status      VARCHAR2 (30);
    v_uoo_id                    NUMBER (7);
    v_upld_person_no_exist      VARCHAR2 (1);
    v_upld_crs_not_enrolled     VARCHAR2 (1);
    v_upld_unit_discont         VARCHAR2 (1);
    v_upld_unit_not_enrolled    VARCHAR2 (1);
    v_finalized_outcome_ind     VARCHAR2 (1);
    v_lower_mark_range          NUMBER (3);
    v_upper_mark_range          NUMBER (3);
    v_grading_schema_cd         VARCHAR2 (10);
    v_gs_version_number         NUMBER (3);
    v_upld_grade_invalid        VARCHAR2 (1);
    v_invalid_allow             VARCHAR2 (1);
    v_combination_invalid       VARCHAR2 (3);
    v_upld_mark_grade_invalid   VARCHAR2 (1);
    v_valid_record              VARCHAR2 (1);
    v_assessment_item_exist     VARCHAR2 (1);
    v_upld_asmnt_item_not_exist VARCHAR2 (1);
    v_outcome_dt                DATE;
    v_upld_asmnt_grade_exist    VARCHAR2 (1);
    v_mark_entry_mandatory      VARCHAR2 (1);
    --
    --
    --
    CURSOR c_alternate_code IS
      SELECT ci.cal_type,
             ci.sequence_number
      FROM   igs_ca_inst_all ci,
             igs_ca_type cat,
             igs_ca_stat cs
      WHERE  (ci.alternate_code = p_alternate_code
              OR p_alternate_code IS NULL
             )
      AND    ((ci.cal_type = p_cal_type
               AND ci.sequence_number = p_ci_sequence_number
              )
              OR p_cal_type IS NULL
             )
      AND    cat.cal_type = ci.cal_type
      AND    cat.s_cal_cat = 'TEACHING'
      AND    cs.cal_status = ci.cal_status
      AND    cs.s_cal_status = 'ACTIVE';
    --
    --
    --
    CURSOR c_person_id IS
      SELECT party_id
      FROM   hz_parties hzp
      WHERE  hzp.party_number = p_person_number;
    --
    --
    --
    CURSOR c_assessment_id (cp_uoo_id igs_en_su_attempt_all.uoo_id%TYPE) IS
      SELECT ai.ass_id,
             gs.grading_schema_cd,
             gs.version_number
      FROM   igs_as_assessmnt_itm ai,
             igs_as_grd_schema gs
      WHERE  (ai.assessment_type = p_assessment_type
              OR p_assessment_type IS NULL
             )
      AND    (ai.ass_id = p_ass_id
              OR p_ass_id IS NULL
             )
      AND    (EXISTS ( SELECT 'X'
                       FROM   igs_ps_unitass_item uooai,
                              igs_ps_unit_ofr_opt uoo
                       WHERE  uoo.uoo_id = cp_uoo_id
                       AND    uooai.uoo_id = uoo.uoo_id
                       AND    uooai.ass_id = ai.ass_id
                       AND    uooai.logical_delete_dt IS NULL
                       AND    (uooai.REFERENCE = p_reference
                               OR p_reference IS NULL
                              )
                       AND    uooai.grading_schema_cd = gs.grading_schema_cd
                       AND    uooai.gs_version_number = gs.version_number)
              OR EXISTS ( SELECT 'X'
                          FROM   igs_as_unitass_item uoai,
                                 igs_ps_unit_ofr_opt uoo
                          WHERE  uoo.uoo_id = cp_uoo_id
                          AND    uoai.unit_cd = uoo.unit_cd
                          AND    uoai.version_number = uoo.version_number
                          AND    uoai.cal_type = uoo.cal_type
                          AND    uoai.ci_sequence_number = uoo.ci_sequence_number
                          AND    uoai.ass_id = ai.ass_id
                          AND    uoai.logical_delete_dt IS NULL
                          AND    (uoai.REFERENCE = p_reference
                                  OR p_reference IS NULL
                                 )
                          AND    uoai.grading_schema_cd = gs.grading_schema_cd
                          AND    uoai.gs_version_number = gs.version_number
                          AND    NOT EXISTS ( SELECT 'X'
                                              FROM   igs_ps_unitass_item uooai
                                              WHERE  uooai.uoo_id = uoo.uoo_id
                                              AND    uooai.logical_delete_dt IS NULL
                                              AND    uooai.ass_id = ai.ass_id)));
    --
    --
    --
    CURSOR c_uoo_id (
      cp_cal_type                           igs_en_su_attempt_all.cal_type%TYPE,
      cp_ci_sequence_number                 igs_en_su_attempt_all.ci_sequence_number%TYPE,
      cp_person_id                          hz_parties.party_id%TYPE
    ) IS
      SELECT uoo_id
      FROM   igs_en_su_attempt_all
      WHERE  unit_cd = p_unit_cd
      AND    cal_type = cp_cal_type
      AND    ci_sequence_number = cp_ci_sequence_number
      AND    person_id = cp_person_id
      AND    course_cd = p_course_cd
      AND    unit_class = p_unit_class
      AND    location_cd = p_location_cd;
    --
    --
    --
    CURSOR c_course_attempt_status (cp_person_id hz_parties.party_id%TYPE) IS
      SELECT course_attempt_status
      FROM   igs_en_stdnt_ps_att_all
      WHERE  person_id = cp_person_id
      AND    course_cd = p_course_cd;
    --
    --
    --
    CURSOR c_unit_enroll_status (
      cp_person_id                          igs_en_su_attempt_all.person_id%TYPE,
      cp_course_cd                          igs_en_su_attempt_all.course_cd%TYPE,
      cp_uoo_id                             igs_en_su_attempt_all.uoo_id%TYPE
    ) IS
      SELECT unit_attempt_status
      FROM   igs_en_su_attempt_all
      WHERE  person_id = cp_person_id
      AND    course_cd = cp_course_cd
      AND    uoo_id = cp_uoo_id;
    --
    --
    --
    CURSOR c_ass_item_exist (
      cp_uoo_id                             igs_en_su_attempt_all.uoo_id%TYPE,
      cp_ass_id                             igs_as_assessmnt_itm.ass_id%TYPE,
      cp_person_id                          hz_parties.party_id%TYPE,
      cp_reference                          VARCHAR2
    ) IS
      SELECT 'X'
      FROM   igs_as_su_atmpt_itm sai
      WHERE  sai.person_id = cp_person_id
      AND    sai.course_cd = p_course_cd
      AND    sai.uoo_id = cp_uoo_id
      AND    sai.ass_id = cp_ass_id
      AND    igs_as_gen_003.assp_get_ai_ref (sai.unit_section_ass_item_id, sai.unit_ass_item_id) = cp_reference
      AND    sai.logical_delete_dt IS NULL;
    --
    --
    --
    CURSOR c_ass_item_grade_exist (
      cp_uoo_id                             igs_en_su_attempt_all.uoo_id%TYPE,
      cp_person_id                          hz_parties.party_id%TYPE,
      cp_ass_id                             igs_as_assessmnt_itm.ass_id%TYPE,
      cp_reference                          VARCHAR2
    ) IS
      SELECT sai.outcome_dt outcome_dt
      FROM   igs_as_su_atmpt_itm sai
      WHERE  sai.person_id = cp_person_id
      AND    sai.course_cd = p_course_cd
      AND    sai.uoo_id = cp_uoo_id
      AND    sai.ass_id = cp_ass_id
      AND    igs_as_gen_003.assp_get_ai_ref (sai.unit_section_ass_item_id, sai.unit_ass_item_id) = cp_reference
      AND    sai.logical_delete_dt IS NULL;
    --
    --
    --
    CURSOR c_grade_invalid (
      cp_grading_schema_cd                  igs_as_grd_schema.grading_schema_cd%TYPE,
      cp_gs_version_number                  igs_as_grd_schema.version_number%TYPE
    ) IS
      SELECT gsg.lower_mark_range,
             gsg.upper_mark_range
      FROM   igs_as_grd_sch_grade gsg
      WHERE  gsg.grading_schema_cd = cp_grading_schema_cd
      AND    gsg.version_number = cp_gs_version_number
      AND    system_only_ind = 'N'
      AND    gsg.grade = p_grade;
    --
    -- Get the Mark/Grade Entry Configuration Setup
    --
    CURSOR cur_ai_mark_grade_conf IS
      SELECT *
      FROM   igs_as_entry_conf
      WHERE  s_control_num = 1;
    --
    rec_ai_mark_grade_conf cur_ai_mark_grade_conf%ROWTYPE;
    --
    -- Derive the Grade from the Grading Schema and the entered mark
    --
    CURSOR cur_gsg_derive (
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
    rec_gsg_derive cur_gsg_derive%ROWTYPE;
    --
  BEGIN
    --
    p_insert_flag := 'Y';
    p_load_flag := 'Y';
    --
    -- Get the Alternate Code
    --
    BEGIN
      IF  p_cal_type IS NULL
          AND p_ci_sequence_number IS NULL
          AND p_alternate_code IS NULL THEN
        p_error_code := 'IGS_AS_MISSING_ALTNTE_CODE';
        p_ret_val := FALSE;
        p_insert_flag := 'N';
        RETURN;
      ELSIF  p_cal_type IS NULL
             AND p_ci_sequence_number IS NULL
             AND p_alternate_code IS NOT NULL THEN
        OPEN c_alternate_code;
        FETCH c_alternate_code INTO p_cal_type,
                                    p_ci_sequence_number;
        IF c_alternate_code%NOTFOUND THEN
          CLOSE c_alternate_code;
          p_error_code := 'IGS_AS_MISSING_ALTNTE_CODE';
          p_ret_val := FALSE;
          p_insert_flag := 'N';
          RETURN;
        ELSE
          CLOSE c_alternate_code;
        END IF;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_insert_flag := 'N';
    END;
    --
    -- Get the Assessment Item Mark/Grade Entry Configuration
    --
    OPEN cur_ai_mark_grade_conf;
    FETCH cur_ai_mark_grade_conf INTO rec_ai_mark_grade_conf;
    CLOSE cur_ai_mark_grade_conf;
    --
    -- Get Person ID AND Person Does Not Exist
    --
    BEGIN
      IF  p_person_number IS NULL
          AND p_anonymous_id IS NULL THEN
        SELECT upld_person_no_exist
        INTO   v_upld_person_no_exist
        FROM   igs_as_entry_conf;
        IF v_upld_person_no_exist = 'D' THEN
          p_error_code := 'IGS_AS_ASD_AN_NO_PERSON_EXIST';
          p_ret_val := FALSE;
          p_load_flag := 'N';
          RETURN;
        ELSIF v_upld_person_no_exist = 'A' THEN
          p_error_code := 'IGS_AS_ASA_AN_NO_PERSON_EXIST';
          p_ret_val := FALSE;
          p_insert_flag := 'N';
          RETURN;
        END IF;
      ELSIF  p_person_number IS NOT NULL
             AND p_anonymous_id IS NOT NULL THEN
        p_error_code := 'IGS_AS_ASD_PER_ANON_BOTH_EXIST';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
      ELSIF  p_person_number IS NULL
             AND p_anonymous_id IS NOT NULL THEN
        -- call function to get person id based on anonymous number
        p_person_id := igs_as_anon_grd_pkg.get_person_id (
                         p_anonymous_id,
                         p_cal_type,
                         p_ci_sequence_number
                       );
      ELSIF  p_person_number IS NOT NULL
             AND p_anonymous_id IS NULL THEN
        OPEN c_person_id;
        FETCH c_person_id INTO p_person_id;
        IF c_person_id%NOTFOUND THEN
          CLOSE c_person_id;
          p_error_code := 'IGS_AS_ASD_AN_NO_PERSON_EXIST';
          p_ret_val := FALSE;
          p_load_flag := 'N';
          RETURN;
        ELSE
          CLOSE c_person_id;
        END IF;
        --
        -- If Person does not exist then show error into exception report based
        -- on option selected into configuration setup form.
        --
        IF p_person_id IS NOT NULL THEN
          IF v_upld_person_no_exist = 'D' THEN
            p_error_code := 'IGS_AS_ASD_AN_NO_PERSON_EXIST';
            p_ret_val := FALSE;
            p_load_flag := 'N';
            RETURN;
          ELSIF v_upld_person_no_exist = 'A' THEN
            p_error_code := 'IGS_AS_ASA_AN_NO_PERSON_EXIST';
            p_ret_val := FALSE;
            p_insert_flag := 'N';
            RETURN;
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_insert_flag := 'N';
    END;
    --
    -- Get Assessment ID
    --
    /*  If user enters new records, they are going to key in assessment id, assessment type and reference.
      If users download the file then they will be having all the information. That means if assessment id
      is blank and assessment type or reference is blank give error or get the value for assessment id
      based on assessment type and reference. FIRST GET UOO_ID
    */
   -- As per bug# 2735673 The uoo_id column has been added to the interface table. UOO_ID is not
   -- required to be derived from the tables based on PK of IGS_PS_UNIT_OFR_OPT_ALL.
   --Still Keeping this query in case user has not entered the UOO_ID in the spreadsheet).
   IF p_uoo_id   IS NULL THEN
        OPEN c_uoo_id (p_cal_type, p_ci_sequence_number, p_person_id);
        FETCH c_uoo_id INTO v_uoo_id;
        IF c_uoo_id%NOTFOUND THEN
          -- 'student unit attempt not exist
          p_load_flag := 'N';
        END IF;
       CLOSE c_uoo_id;
     ELSE
         v_uoo_id := p_uoo_id;
    END IF; /* End p_uoo_id is null */
    IF  p_ass_id IS NULL
        AND (p_assessment_type IS NULL
             OR p_reference IS NULL
            ) THEN
      p_error_code := 'IGS_AS_ASD_AI_INFO_MISSING';
      p_ret_val := FALSE;
      p_load_flag := 'N';
      RETURN;
    ELSE
      OPEN c_assessment_id (v_uoo_id);
      FETCH c_assessment_id INTO p_ass_id,
                                 p_grading_schema_cd,
                                 p_gs_version_number;
      IF c_assessment_id%NOTFOUND THEN
        p_error_code := 'IGS_AS_ASD_AI_NOT_FOUND';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
        --  Could not find unique assessment item for particular assessment type and reference combination)
      END IF; --ass_id is null
      CLOSE c_assessment_id;
    END IF; -- ass_id , assessment type , reference is null
    -- No Program Attempts
    OPEN c_course_attempt_status (p_person_id);
    FETCH c_course_attempt_status INTO v_no_program_status;
    /*    If student dose not enrolled into course then act according to configuration setup. Available options are
        1) Abort File 2) Do not Load Record. Course attempt other then ?Enrolled? consider  as no program attempt.
    */
    IF c_course_attempt_status%NOTFOUND
       OR v_no_program_status NOT IN ('ENROLLED', 'INACTIVE') THEN
      SELECT upld_crs_not_enrolled
      INTO   v_upld_crs_not_enrolled
      FROM   igs_as_entry_conf;
      IF v_upld_crs_not_enrolled = 'D' THEN
        p_error_code := 'IGS_AS_ASD_COURSE_NOT_ENROLLED';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
      ELSIF v_upld_crs_not_enrolled = 'A' THEN
        p_error_code := 'IGS_AS_ASA_COURSE_NOT_ENROLLED';
        p_ret_val := FALSE;
        p_insert_flag := 'N';
        RETURN;
      END IF;
    END IF;
    CLOSE c_course_attempt_status;
    -- Unit Not Enrolled or Unit Discontinued -
    OPEN c_unit_enroll_status (p_person_id, p_course_cd, v_uoo_id);
    FETCH c_unit_enroll_status INTO v_unit_enrolled_status;
    IF c_unit_enroll_status%NOTFOUND THEN
      SELECT upld_unit_not_enrolled
      INTO   v_upld_unit_not_enrolled
      FROM   igs_as_entry_conf;
      IF v_upld_unit_not_enrolled = 'D' THEN
        p_error_code := 'IGS_AS_ASD_UNIT_NOT_ENROLLED';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
      ELSIF v_upld_unit_not_enrolled = 'A' THEN
        p_error_code := 'IGS_AS_ASA_UNIT_NOT_ENROLLED';
        p_ret_val := FALSE;
        p_insert_flag := 'N';
        RETURN;
      END IF;
    END IF;
    CLOSE c_unit_enroll_status;
    /*    Student who has been enrolled in the unit  for current teaching period but  afterward
        withdrawn from the same then act according to configuration setup. Available options are
         1) Abort File 2) Do not Load Record.
    */
    IF v_unit_enrolled_status = 'DISCONTIN' THEN
      SELECT upld_unit_discont
      INTO   v_upld_unit_discont
      FROM   igs_as_entry_conf;
      IF v_upld_unit_discont = 'D' THEN
        p_error_code := 'IGS_AS_ASD_UNIT_DISCONTINUED';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
      ELSIF v_upld_unit_discont = 'A' THEN
        p_error_code := 'IGS_AS_ASA_UNIT_DISCONTINUED';
        p_ret_val := FALSE;
        p_insert_flag := 'N';
        RETURN;
      END IF;
    /*    Student might enrolled in the institution  but not in the Unit for current period which
        results are uploading then act according to configuration setup. Available options are
        1) Abort File 2) Do not Load Record.
    */
    ELSIF v_unit_enrolled_status <> 'ENROLLED' THEN
      SELECT upld_unit_not_enrolled
      INTO   v_upld_unit_not_enrolled
      FROM   igs_as_entry_conf;

      IF v_upld_unit_not_enrolled = 'D' THEN
        p_error_code := 'IGS_AS_ASD_UNIT_NOT_ENROLLED';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
      ELSIF v_upld_unit_not_enrolled = 'A' THEN
        p_error_code := 'IGS_AS_ASA_UNIT_NOT_ENROLLED';
        p_ret_val := FALSE;
        p_insert_flag := 'N';
        RETURN;
      END IF;
    END IF;
    -- Assessment Item Not Exists
    -- Applies to a record where the student unit attempt does not have a record for that Assessment Item.
    OPEN c_ass_item_exist (v_uoo_id, p_ass_id, p_person_id, p_reference);
    FETCH c_ass_item_exist INTO v_assessment_item_exist;
    IF c_ass_item_exist%NOTFOUND THEN
      SELECT upld_asmnt_item_not_exist
      INTO   v_upld_asmnt_item_not_exist
      FROM   igs_as_entry_conf;
      IF v_upld_asmnt_item_not_exist = 'D' THEN
        p_error_code := 'IGS_AS_ASD_AIO_NOT_EXIST';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
      ELSIF v_upld_asmnt_item_not_exist = 'A' THEN
        p_error_code := 'IGS_AS_ASA_AIO_NOT_EXIST';
        p_ret_val := FALSE;
        p_insert_flag := 'N';
        RETURN;
      END IF;
    END IF;
    --
    -- Check if Assessment Item Grade already exists
    --
    OPEN c_ass_item_grade_exist (v_uoo_id, p_person_id, p_ass_id, p_reference);
    FETCH c_ass_item_grade_exist INTO v_outcome_dt;
    IF  c_ass_item_exist%FOUND
        AND v_outcome_dt IS NOT NULL THEN
      CLOSE c_ass_item_exist;
      /* If a record exist in the table with outcome date then act according to configuration setup.
         Available options are 1) Abort File 2) Do not Load file 3) Warning.*/
      SELECT upld_asmnt_item_grd_exist
      INTO   v_upld_asmnt_grade_exist
      FROM   igs_as_entry_conf;
      IF v_upld_asmnt_grade_exist = 'D' THEN
        p_error_code := 'IGS_AS_ASD_AIO_GRADE_EXIST';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
      ELSIF v_upld_asmnt_grade_exist = 'A' THEN
        p_error_code := 'IGS_AS_ASA_AIO_GRADE_EXIST';
        p_ret_val := FALSE;
        p_insert_flag := 'N';
        RETURN;
      ELSIF v_upld_asmnt_grade_exist = 'W' THEN
        p_error_code := 'IGS_AS_ASW_AIO_GRADE_EXIST';
        p_ret_val := FALSE;
      END IF;
    ELSE
      CLOSE c_ass_item_exist;
    END IF;
    CLOSE c_ass_item_grade_exist;
    --
    -- Check that Marks are entered when Mark Entry is Mandatory
    --
    IF ((p_mark IS NULL) AND
        (rec_ai_mark_grade_conf.key_ai_mark_mndtry_flag = 'Y') AND
        (NVL (p_waived_flag, 'N') = 'N')) THEN
      p_error_code := 'IGS_SS_AS_MARK_MANDATORY';
      p_ret_val := FALSE;
      p_load_flag := 'N';
      RETURN;
    END IF;
    --
    -- Check number of decimal places entered in the marks field. If the number
    -- of decimals is more than the setup then show an error message
    --
    IF (((LENGTH (p_mark) - LENGTH (FLOOR (p_mark)) - 1) >
        rec_ai_mark_grade_conf.key_ai_mark_entry_dec_points) AND
        (NVL (p_waived_flag, 'N') = 'N')) THEN
      p_error_code := 'IGS_AS_MORE_DECIMAL_PLACES';
      p_ret_val := FALSE;
      p_load_flag := 'N';
      RETURN;
    END IF;
    --
    -- If Derive Grade From Mark is enabled then derive the Grade from the mark
    -- entered using the Assessment Item Grading Schema. If there is no range
    -- defined for the mark and Invalid Mark/Grade is not allowed then show error
    --
    IF ((rec_ai_mark_grade_conf.key_ai_grade_derive_flag = 'Y') AND
        (p_mark IS NOT NULL) AND
        (p_grade IS NULL) AND
        (NVL (p_waived_flag, 'N') = 'N')) THEN
      OPEN cur_gsg_derive (p_grading_schema_cd, p_gs_version_number);
      FETCH cur_gsg_derive INTO p_grade;
      IF ((cur_gsg_derive%NOTFOUND) AND
          (rec_ai_mark_grade_conf.key_ai_allow_invalid_flag <> 'Y')) THEN
        CLOSE cur_gsg_derive;
        p_error_code := 'IGS_AS_ASD_MARK_GRADE_INVALID';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
      ELSE
        CLOSE cur_gsg_derive;
      END IF;
    END IF;
    --
    -- Grade Invalid
    --
    OPEN c_grade_invalid (p_grading_schema_cd, p_gs_version_number);
    FETCH c_grade_invalid INTO v_lower_mark_range,
                               v_upper_mark_range;
    IF (c_grade_invalid%NOTFOUND AND
        p_grade IS NOT NULL AND
       (NVL (p_waived_flag, 'N') = 'N')) THEN
      /*      If record contains a grade that is not within the grading schema for student unit attempt than
            act according to configuration setup. Available options are 1) Abort File 2) Do not Load Record
      */
      SELECT upld_grade_invalid
      INTO   v_upld_grade_invalid
      FROM   igs_as_entry_conf;
      IF v_upld_grade_invalid = 'D' THEN
        p_error_code := 'IGS_AS_ASD_GRADE_INVALID';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
      ELSIF v_upld_grade_invalid = 'A' THEN
        p_error_code := 'IGS_AS_ASA_GRADE_INVALID';
        p_ret_val := FALSE;
        p_insert_flag := 'N';
        RETURN;
      END IF;
    END IF;
    CLOSE c_grade_invalid;
    --
    -- Mark Grade Combination Invalid
    --
    IF (p_mark NOT BETWEEN v_lower_mark_range AND v_upper_mark_range
        AND p_mark IS NOT NULL
        AND (NVL (p_waived_flag, 'N') = 'N')) THEN
      /*    If a record contains a grade that is within the relevant grading schema for the student unit attempt
           but the grade dose not relate to the mark range for the entered mark then act according to
          configuration setup. Available options are 1) Abort File 2) Do not Load file 3) Warning.
      */
      IF (rec_ai_mark_grade_conf.key_ai_allow_invalid_flag <> 'Y') THEN
        p_error_code := 'IGS_AS_ASD_MARK_GRADE_INVALID';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
      END IF;
      SELECT upld_mark_grade_invalid
      INTO   v_upld_mark_grade_invalid
      FROM   igs_as_entry_conf;
      --
      IF v_upld_mark_grade_invalid = 'D' THEN
        p_error_code := 'IGS_AS_ASD_MARK_GRADE_INVALID';
        p_ret_val := FALSE;
        p_load_flag := 'N';
        RETURN;
      ELSIF v_upld_mark_grade_invalid = 'A' THEN
        p_error_code := 'IGS_AS_ASA_MARK_GRADE_INVALID';
        p_ret_val := FALSE;
        p_insert_flag := 'N';
        RETURN;
      ELSIF v_upld_mark_grade_invalid = 'W' THEN
        p_error_code := 'IGS_AS_ASW_MARK_GRADE_INVALID';
        p_ret_val := FALSE;
      END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_insert_flag := 'N';
      p_load_flag := 'N';
      p_error_code := 'No Data Found';
    WHEN TOO_MANY_ROWS THEN
      p_insert_flag := 'N';
      p_load_flag := 'N';
      p_error_code := 'More then One row retirve for a select statment';
    WHEN OTHERS THEN
      p_insert_flag := 'N';
      p_load_flag := 'N';
      p_error_code := 'No Data Found - Others';
  END igs_as_aio_val_upld;
  --
  -- Validate the user while upload and download of ADI data
  --
  FUNCTION isvaliduser (
     p_userid     IN   NUMBER,
     p_uoo_id     IN   NUMBER DEFAULT NULL,
     p_group_id   IN   NUMBER DEFAULT NULL
  ) RETURN VARCHAR2 IS
    CURSOR cur_cusid IS
      SELECT person_party_id
      FROM fnd_user
      WHERE user_id = p_userid;
    CURSOR cur_instruct (cp_inst_id NUMBER) IS
      SELECT 1
      FROM igs_ps_usec_tch_resp
      WHERE instructor_id = cp_inst_id AND uoo_id = p_uoo_id;
    CURSOR cur_class_list (cp_inst_id NUMBER) IS
      SELECT 1
      FROM igs_as_x_usec_classlist_v
      WHERE instructor_id = cp_inst_id AND GROUP_ID = p_group_id;
    customerid      NUMBER       := NULL;
    linstructorid   NUMBER;
    outval          VARCHAR2 (3);
  BEGIN
    -- Check if the logged in user is a administrator
    IF fnd_function.test ('IGS_SS_ADMIN_HOME') OR fnd_function.test ('IGSAS016') OR fnd_function.test ('IGSAS030') THEN
      -- If administrator allow download by returning Y
      RETURN 'Y';
    ELSIF (fnd_function.test ('IGS_SS_FACULTY_HOME')) THEN
      -- Get the customer id for customer attached to the logged in user
      OPEN cur_cusid;
      FETCH cur_cusid INTO customerid;
      CLOSE cur_cusid;
      -- UOO_ID is present for grading and student list adi sheets
      IF p_uoo_id IS NOT NULL THEN
        -- check if the logged in user is a faculty for the given unit section identified by the uoo_id
        OPEN cur_instruct (customerid);
        FETCH cur_instruct INTO linstructorid;
        IF cur_instruct%NOTFOUND THEN
          -- Not a facluty for the unit section .. disallow download
          CLOSE cur_instruct;
          RETURN 'N';
        ELSE
          -- Is a facluty for the unit section .. allow download
          CLOSE cur_instruct;
          RETURN 'Y';
        END IF;
      ELSIF p_group_id IS NOT NULL THEN
        -- check if the logged in user is a faculty for the given cross listed group
        OPEN cur_class_list (p_group_id);
        FETCH cur_class_list INTO linstructorid;
        IF cur_class_list%NOTFOUND THEN
          -- Not a facluty for the crosslisted group .. disallow download
          CLOSE cur_class_list;
          RETURN 'N';
        ELSE
          -- Not a facluty for the crosslisted group  .. disallow download
          CLOSE cur_class_list;
          RETURN 'Y';
        END IF;
      END IF;
    ELSE
      -- For all other responsibilities except ADMIN and FACULTY return N and disallow download
      RETURN 'N';
    END IF;
    -- For all other combinations return N and disallow download
    RETURN 'N';
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END isvaliduser;
END igs_as_adi_upld_aio_pkg;

/
