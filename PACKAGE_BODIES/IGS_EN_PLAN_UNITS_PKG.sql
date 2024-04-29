--------------------------------------------------------
--  DDL for Package Body IGS_EN_PLAN_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_PLAN_UNITS_PKG" AS
/* $Header: IGSEI79B.pls 120.2 2005/10/27 04:18:29 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_plan_units%ROWTYPE;
  new_references igs_en_plan_units%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_no_assessment_ind                 IN     VARCHAR2,
    x_sup_uoo_id                        IN     NUMBER,
    x_override_enrolled_cp              IN     NUMBER,
    x_grading_schema_code               IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_alternative_title                 IN     VARCHAR2,
    x_cart_error_flag                   IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 30-MAY-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_plan_units
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.uoo_id                            := x_uoo_id;
    new_references.term_cal_type                     := x_term_cal_type;
    new_references.term_ci_sequence_number           := x_term_ci_sequence_number;
    new_references.no_assessment_ind                 := x_no_assessment_ind;
    new_references.sup_uoo_id                        := x_sup_uoo_id;
    new_references.override_enrolled_cp              := NVL(IGS_EN_GEN_015.enrp_get_appr_cr_pt(x_person_id,x_uoo_id), x_override_enrolled_cp);
    new_references.grading_schema_code               := x_grading_schema_code;
    new_references.gs_version_number                 := x_gs_version_number;
    new_references.core_indicator_code               := x_core_indicator_code;
    new_references.alternative_title                 := x_alternative_title;
    new_references.cart_error_flag                   := x_cart_error_flag;
    new_references.session_id                        := x_session_id;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By :
  ||  Created On : 30-MAY-2005
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    -- The following validation is added because
    -- SPA terms record is created only when SUA (enrolled) attempt is being created or
    -- PLAN units record is created.
    -- When Add_units_api gets some error while creating SUA record it creates error
    -- plan units record. While creating error plan units record it is not necessary to
    -- check for FK relationship, as error plan units record are just used for display
    -- purpose only and not used for any processing.
    IF new_references.cart_error_flag = 'Y' THEN
       RETURN;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.course_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.term_cal_type = new_references.term_cal_type) AND
         (old_references.term_ci_sequence_number = new_references.term_ci_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.term_cal_type IS NULL) OR
         (new_references.term_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_spa_terms_pkg.get_uk_for_validation (
                new_references.person_id,
                new_references.course_cd,
                new_references.term_cal_type,
                new_references.term_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_cart_error_flag                   IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 30-MAY-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_plan_units
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      uoo_id = x_uoo_id
      AND      cart_error_flag = x_cart_error_flag
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_pk_for_validation;


  PROCEDURE get_fk_igs_en_stdnt_ps_att (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 30-MAY-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_plan_units
      WHERE   ((course_cd = x_course_cd) AND
               (person_id = x_person_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;

      fnd_message.set_name ('IGS', 'IGS_EN_PLSHT_SCA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_stdnt_ps_att;


  PROCEDURE get_fk_igs_en_spa_terms (
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 30-MAY-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_plan_units
      WHERE   ((course_cd = x_program_cd) AND
               (person_id = x_person_id) AND
               (term_cal_type = x_term_cal_type) AND
               (term_ci_sequence_number = x_term_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_PLSHT_ESPT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_spa_terms;

  PROCEDURE before_insert_update(p_action IN VARCHAR2) IS

  CURSOR c_spa_exists (cp_person_id IN NUMBER, cp_program_cd IN VARCHAR2, cp_term_cal IN VARCHAR2, cp_term_seq IN NUMBER) IS
         SELECT PLAN_SHT_STATUS
         FROM IGS_EN_SPA_TERMS
         WHERE person_id = cp_person_id
         AND   program_cd  = cp_program_cd
         AND   term_cal_type = cp_term_cal
         AND   term_sequence_number = cp_term_seq;


  l_message_name VARCHAR2(2000);
  l_plan_sht_status igs_en_spa_terms.plan_sht_status%TYPE;

  BEGIN
    IF p_action NOT IN ('INSERT','UPDATE') or new_references.cart_error_flag = 'Y' THEN
       RETURN;
    END IF;

    OPEN c_spa_exists(new_references.person_id, new_references.course_cd, new_references.term_cal_type, new_references.term_ci_sequence_number);
    FETCH c_spa_exists INTO l_plan_sht_status;
    IF c_spa_exists%FOUND THEN
       CLOSE c_spa_exists;
       IF l_plan_sht_status = 'PLAN' THEN
          RETURN;
       END IF;
    ELSE
       CLOSE c_spa_exists;
    END IF;


	      -- Call the API to Create/Update the term record.
              igs_en_spa_terms_api.create_update_term_rec(p_person_id => new_references.person_id,
                                                          p_program_cd => new_references.course_cd,
                                                          p_term_cal_type =>new_references.term_cal_type,
                                                          p_term_sequence_number => new_references.term_ci_sequence_number,
														  p_plan_sht_status => 'PLAN',
                                                          p_ripple_frwrd => FALSE,
                                                          p_message_name => l_message_name,
                                                          p_update_rec => TRUE);


  END before_insert_update;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
    CURSOR c_plan_rec_exists (cp_person_id IGS_EN_PLAN_UNITS.PERSON_ID%TYPE,
                              cp_course_cd IGS_EN_PLAN_UNITS.COURSE_CD%TYPE,
                              cp_term_cal_type IGS_EN_PLAN_UNITS.TERM_CAL_TYPE%TYPE,
                              cp_term_ci_sequence_number IGS_EN_PLAN_UNITS.TERM_CI_SEQUENCE_NUMBER%TYPE
                              )IS
    SELECT UOO_ID FROM IGS_EN_PLAN_UNITS
    WHERE PERSON_ID= cp_person_id
    AND COURSE_CD = cp_course_Cd
    AND TERM_CAL_TYPE = cp_term_cal_type
    AND TERM_CI_SEQUENCE_NUMBER =cp_term_ci_sequence_number
    AND CART_ERROR_FLAG ='N';

    l_dummy IGS_EN_PLAN_UNITS.UOO_ID%TYPE;
    l_message_name VARCHAR2(30);
  BEGIN

    IF p_action = 'DELETE' THEN

        OPEN c_plan_rec_exists(old_references.person_id,old_references.course_cd,
             old_references.term_cal_type,old_references.term_ci_sequence_number)  ;
        FETCH c_plan_rec_exists INTO l_dummy;
        IF c_plan_rec_exists%NOTFOUND THEN
    	      -- Call the API to Create/Update the term record.
                  igs_en_spa_terms_api.create_update_term_rec(p_person_id => old_references.person_id,
                                                              p_program_cd => old_references.course_cd,
                                                              p_term_cal_type =>old_references.term_cal_type,
                                                              p_term_sequence_number => old_references.term_ci_sequence_number,
    														  p_plan_sht_status => 'NONE',
                                                              p_ripple_frwrd => FALSE,
                                                              p_message_name => l_message_name,
                                                              p_update_rec => TRUE);
        END IF; -- c_plan_rec_exists%NOTFOUND
        CLOSE c_plan_rec_exists;
    END IF; -- p_action = 'DELETE'

  END;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_no_assessment_ind                 IN     VARCHAR2,
    x_sup_uoo_id                        IN     NUMBER,
    x_override_enrolled_cp              IN     NUMBER,
    x_grading_schema_code               IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_alternative_title                 IN     VARCHAR2,
    x_cart_error_flag                   IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 30-MAY-2005
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
     CURSOR cur_sub_uoo(cp_n_uoo_id IN NUMBER) IS
          SELECT sub.sup_uoo_id
          FROM igs_ps_unit_ofr_opt sub
          WHERE sub.uoo_id = cp_n_uoo_id ;
     l_sup_uoo_id igs_ps_unit_ofr_opt.sup_uoo_id%TYPE;

  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_term_cal_type,
      x_term_ci_sequence_number,
      x_no_assessment_ind,
      x_sup_uoo_id,
      x_override_enrolled_cp,
      x_grading_schema_code,
      x_gs_version_number,
      x_core_indicator_code,
      x_alternative_title,
      x_cart_error_flag,
      x_session_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.person_id,
             new_references.course_cd,
             new_references.uoo_id,
             new_references.cart_error_flag
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      before_insert_update(p_action);
      check_parent_existance;

      -- when taking as audit, the enrolled_cp is 0
      IF (new_references.no_assessment_ind = 'Y') THEN
            new_references.override_enrolled_cp := 0;
      END IF;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      before_insert_update(p_action);
      check_parent_existance;

      -- when taking as audit, the enrolled_cp is 0
       IF old_references.no_assessment_ind = 'N'
            AND new_references.no_assessment_ind = 'Y'
        THEN
                  new_references.override_enrolled_cp := 0;
      END IF;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.person_id,
             new_references.course_cd,
             new_references.uoo_id,
             new_references.cart_error_flag
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

        -- populate the sup_uoo_id if context unit is a subordinate unit
     IF p_action  IN ( 'INSERT','UPDATE')   AND new_references.sup_uoo_id IS NULL THEN
         OPEN cur_sub_uoo(new_references.uoo_id);
         FETCH cur_sub_uoo INTO new_references.sup_uoo_id;
          CLOSE cur_sub_uoo;
     END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_no_assessment_ind                 IN     VARCHAR2,
    x_sup_uoo_id                        IN     NUMBER,
    x_override_enrolled_cp              IN     NUMBER,
    x_grading_schema_code               IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_alternative_title                 IN     VARCHAR2,
    x_cart_error_flag                   IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 30-MAY-2005
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGS_EN_PLAN_UNITS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_term_cal_type                     => x_term_cal_type,
      x_term_ci_sequence_number           => x_term_ci_sequence_number,
      x_no_assessment_ind                 => x_no_assessment_ind,
      x_sup_uoo_id                        => x_sup_uoo_id,
      x_override_enrolled_cp              => x_override_enrolled_cp,
      x_grading_schema_code               => x_grading_schema_code,
      x_gs_version_number                 => x_gs_version_number,
      x_core_indicator_code               => x_core_indicator_code,
      x_alternative_title                 => x_alternative_title,
      x_cart_error_flag                   => x_cart_error_flag,
      x_session_id                        => x_session_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_plan_units (
      person_id,
      course_cd,
      uoo_id,
      term_cal_type,
      term_ci_sequence_number,
      no_assessment_ind,
      sup_uoo_id,
      override_enrolled_cp,
      grading_schema_code,
      gs_version_number,
      core_indicator_code,
      alternative_title,
      cart_error_flag,
      session_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.person_id,
      new_references.course_cd,
      new_references.uoo_id,
      new_references.term_cal_type,
      new_references.term_ci_sequence_number,
      new_references.no_assessment_ind,
      new_references.sup_uoo_id,
      new_references.override_enrolled_cp,
      new_references.grading_schema_code,
      new_references.gs_version_number,
      new_references.core_indicator_code,
      new_references.alternative_title,
      new_references.cart_error_flag,
      new_references.session_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_no_assessment_ind                 IN     VARCHAR2,
    x_sup_uoo_id                        IN     NUMBER,
    x_override_enrolled_cp              IN     NUMBER,
    x_grading_schema_code               IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_alternative_title                 IN     VARCHAR2,
    x_cart_error_flag                   IN     VARCHAR2,
    x_session_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 30-MAY-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        term_cal_type,
        term_ci_sequence_number,
        no_assessment_ind,
        sup_uoo_id,
        override_enrolled_cp,
        grading_schema_code,
        gs_version_number,
        core_indicator_code,
        alternative_title,
        session_id
      FROM  igs_en_plan_units
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.term_cal_type = x_term_cal_type)
        AND (tlinfo.term_ci_sequence_number = x_term_ci_sequence_number)
        AND (tlinfo.no_assessment_ind = x_no_assessment_ind)
        AND ((tlinfo.sup_uoo_id = x_sup_uoo_id) OR ((tlinfo.sup_uoo_id IS NULL) AND (X_sup_uoo_id IS NULL)))
        AND ((tlinfo.override_enrolled_cp = x_override_enrolled_cp) OR ((tlinfo.override_enrolled_cp IS NULL) AND (X_override_enrolled_cp IS NULL)))
        AND ((tlinfo.grading_schema_code = x_grading_schema_code) OR ((tlinfo.grading_schema_code IS NULL) AND (X_grading_schema_code IS NULL)))
        AND ((tlinfo.gs_version_number = x_gs_version_number) OR ((tlinfo.gs_version_number IS NULL) AND (X_gs_version_number IS NULL)))
        AND ((tlinfo.core_indicator_code = x_core_indicator_code) OR ((tlinfo.core_indicator_code IS NULL) AND (X_core_indicator_code IS NULL)))
        AND ((tlinfo.alternative_title = x_alternative_title) OR ((tlinfo.alternative_title IS NULL) AND (X_alternative_title IS NULL)))
        AND (tlinfo.session_id = x_session_id)
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_no_assessment_ind                 IN     VARCHAR2,
    x_sup_uoo_id                        IN     NUMBER,
    x_override_enrolled_cp              IN     NUMBER,
    x_grading_schema_code               IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_alternative_title                 IN     VARCHAR2,
    x_cart_error_flag                   IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 30-MAY-2005
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGS_EN_PLAN_UNITS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_term_cal_type                     => x_term_cal_type,
      x_term_ci_sequence_number           => x_term_ci_sequence_number,
      x_no_assessment_ind                 => x_no_assessment_ind,
      x_sup_uoo_id                        => x_sup_uoo_id,
      x_override_enrolled_cp              => x_override_enrolled_cp,
      x_grading_schema_code               => x_grading_schema_code,
      x_gs_version_number                 => x_gs_version_number,
      x_core_indicator_code               => x_core_indicator_code,
      x_alternative_title                 => x_alternative_title,
      x_cart_error_flag                   => x_cart_error_flag,
      x_session_id                        => x_session_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_plan_units
      SET
        term_cal_type                     = new_references.term_cal_type,
        term_ci_sequence_number           = new_references.term_ci_sequence_number,
        no_assessment_ind                 = new_references.no_assessment_ind,
        sup_uoo_id                        = new_references.sup_uoo_id,
        override_enrolled_cp              = new_references.override_enrolled_cp,
        grading_schema_code               = new_references.grading_schema_code,
        gs_version_number                 = new_references.gs_version_number,
        core_indicator_code               = new_references.core_indicator_code,
        alternative_title                 = new_references.alternative_title,
        session_id                        = new_references.session_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_no_assessment_ind                 IN     VARCHAR2,
    x_sup_uoo_id                        IN     NUMBER,
    x_override_enrolled_cp              IN     NUMBER,
    x_grading_schema_code               IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_alternative_title                 IN     VARCHAR2,
    x_cart_error_flag                   IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 30-MAY-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_plan_units
      WHERE    person_id                         = x_person_id
      AND      course_cd                         = x_course_cd
      AND      uoo_id                            = x_uoo_id
      AND      cart_error_flag                   = x_cart_error_flag;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_person_id,
        x_course_cd,
        x_uoo_id,
        x_term_cal_type,
        x_term_ci_sequence_number,
        x_no_assessment_ind,
        x_sup_uoo_id,
        x_override_enrolled_cp,
        x_grading_schema_code,
        x_gs_version_number,
        x_core_indicator_code,
        x_alternative_title,
        x_cart_error_flag,
        x_session_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_term_cal_type,
      x_term_ci_sequence_number,
      x_no_assessment_ind,
      x_sup_uoo_id,
      x_override_enrolled_cp,
      x_grading_schema_code,
      x_gs_version_number,
      x_core_indicator_code,
      x_alternative_title,
      x_cart_error_flag,
      x_session_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 30-MAY-2005
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igs_en_plan_units
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    After_DML(
      p_action => 'DELETE',
      x_rowid => X_ROWID
    );


  END delete_row;


END igs_en_plan_units_pkg;

/
