--------------------------------------------------------
--  DDL for Package Body IGF_AP_APPL_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_APPL_SETUP_PKG" AS
/* $Header: IGFAI01B.pls 120.1 2005/08/09 07:42:50 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_ap_appl_setup_all%ROWTYPE;
  new_references igf_ap_appl_setup_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_question_id                       IN     NUMBER      DEFAULT NULL,
    x_question                          IN     VARCHAR2    DEFAULT NULL,
    x_enabled                           IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_application_code                  IN     VARCHAR2,
    x_application_name                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2	   DEFAULT NULL,
    x_answer_type_code                  IN     VARCHAR2,
    x_destination_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_all_terms_flag                    IN     VARCHAR2    DEFAULT NULL,
    x_override_exist_ant_data_flag      IN     VARCHAR2    DEFAULT NULL,
    x_required_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_minimum_value_num                 IN     NUMBER      DEFAULT NULL,
    x_maximum_value_num                 IN     NUMBER      DEFAULT NULL,
    x_minimum_date                      IN     DATE        DEFAULT NULL,
    x_maximium_date                     IN     DATE        DEFAULT NULL,
    x_lookup_code                       IN     VARCHAR2    DEFAULT NULL,
    x_hint_txt                          IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 07-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AP_APPL_SETUP_ALL
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
    new_references.question_id                       := x_question_id;
    new_references.question                          := x_question;
    new_references.enabled                           := x_enabled;
    new_references.org_id                            := x_org_id;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.application_code                  := x_application_code;
    new_references.application_name                  := x_application_name;
    new_references.active_flag                       := x_active_flag;
    new_references.answer_type_code                  := x_answer_type_code;
    new_references.destination_txt                   := x_destination_txt;
    new_references.ld_cal_type                       := x_ld_cal_type;
    new_references.ld_sequence_number                := x_ld_sequence_number;
    new_references.all_terms_flag                    := x_all_terms_flag;
    new_references.override_exist_ant_data_flag      := x_override_exist_ant_data_flag;
    new_references.required_flag                     := x_required_flag;
    new_references.minimum_value_num                 := x_minimum_value_num;
    new_references.maximum_value_num                 := x_maximum_value_num;
    new_references.minimum_date                      := x_minimum_date;
    new_references.maximium_date                     := x_maximium_date;
    new_references.lookup_code                       := x_lookup_code;
    new_references.hint_txt                          := x_hint_txt;


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


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : rasingh
  ||  Created On : 04-JAN-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.ci_cal_type,
           new_references.ci_sequence_number,
           new_references.application_code,
           new_references.question
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : brajendr
  ||  Created On : 07-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.ci_cal_type = new_references.ci_cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.ci_cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.ci_cal_type,
                new_references.ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : brajendr
  ||  Created On : 07-DEC-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_ap_st_inst_appl_pkg.get_fk_igf_ap_appl_setup (
      old_references.question_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_question_id                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : brajendr
  ||  Created On : 07-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_appl_setup_all
      WHERE    question_id = x_question_id
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


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 07-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_appl_setup_all
      WHERE   ((ci_cal_type = x_cal_type) AND
               (ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AP_IAS_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  FUNCTION get_uk_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_application_code                  IN     VARCHAR2,
    x_question                          IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasingh
  ||  Created On : 04-JAN-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_appl_setup_all
      WHERE    ci_cal_type = x_ci_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      application_code = x_application_code
      AND      question = x_question
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_question_id                       IN     NUMBER      DEFAULT NULL,
    x_question                          IN     VARCHAR2    DEFAULT NULL,
    x_enabled                           IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_application_code                  IN     VARCHAR2,
    x_application_name                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_answer_type_code                  IN     VARCHAR2,
    x_destination_txt                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_all_terms_flag                    IN     VARCHAR2,
    x_override_exist_ant_data_flag      IN     VARCHAR2,
    x_required_flag                     IN     VARCHAR2,
    x_minimum_value_num                 IN     NUMBER,
    x_maximum_value_num                 IN     NUMBER,
    x_minimum_date                      IN     DATE,
    x_maximium_date                     IN     DATE,
    x_lookup_code                       IN     VARCHAR2,
    x_hint_txt                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 07-DEC-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_question_id,
      x_question,
      x_enabled,
      x_org_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_application_code,
      x_application_name,
      x_active_flag,
      x_answer_type_code,
      x_destination_txt,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_all_terms_flag,
      x_override_exist_ant_data_flag,
      x_required_flag,
      x_minimum_value_num,
      x_maximum_value_num,
      x_minimum_date,
      x_maximium_date,
      x_lookup_code,
      x_hint_txt
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.question_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.question_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_question_id                       IN OUT NOCOPY NUMBER,
    x_question                          IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_application_code                  IN     VARCHAR2,
    x_application_name                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_answer_type_code                  IN     VARCHAR2,
    x_destination_txt                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_all_terms_flag                    IN     VARCHAR2,
    x_override_exist_ant_data_flag      IN     VARCHAR2,
    x_required_flag                     IN     VARCHAR2,
    x_minimum_value_num                 IN     NUMBER,
    x_maximum_value_num                 IN     NUMBER,
    x_minimum_date                      IN     DATE,
    x_maximium_date                     IN     DATE,
    x_lookup_code                       IN     VARCHAR2,
    x_hint_txt                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 07-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || vvutukur       16-feb-2002      removed l_org_id portion and passed igf_aw_gen.get_org_id to before_dml.
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_appl_setup_all
      WHERE    question_id                       = x_question_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    SELECT igf_ap_appl_setup_s.nextval
	INTO x_question_id
	FROM dual;

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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_question_id                       => x_question_id,
      x_question                          => x_question,
      x_enabled                           => NVL (x_enabled,'Y' ),
      x_org_id                            => igf_aw_gen.get_org_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_application_code                  => x_application_code,
      x_application_name                  => x_application_name,
      x_active_flag                       => x_active_flag,
      x_answer_type_code                  => x_answer_type_code,
      x_destination_txt                   => x_destination_txt,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_all_terms_flag                    => x_all_terms_flag,
      x_override_exist_ant_data_flag      => x_override_exist_ant_data_flag,
      x_required_flag                     => x_required_flag,
      x_minimum_value_num                 => x_minimum_value_num,
      x_maximum_value_num                 => x_maximum_value_num,
      x_minimum_date                      => x_minimum_date,
      x_maximium_date                     => x_maximium_date,
      x_lookup_code                       => x_lookup_code,
      x_hint_txt                          => x_hint_txt
    );


    INSERT INTO igf_ap_appl_setup_all (
      question_id,
      question,
      enabled,
      org_id,
      ci_cal_type,
      ci_sequence_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      application_code,
      application_name,
      active_flag,
      answer_type_code,
      destination_txt,
      ld_cal_type,
      ld_sequence_number,
      all_terms_flag,
      override_exist_ant_data_flag,
      required_flag,
      minimum_value_num,
      maximum_value_num,
      minimum_date,
      maximium_date,
      lookup_code,
      hint_txt
    ) VALUES (
      new_references.question_id,
      new_references.question,
      new_references.enabled,
      new_references.org_id,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.application_code,
      new_references.application_name,
      new_references.active_flag,
      new_references.answer_type_code,
      new_references.destination_txt,
      new_references.ld_cal_type,
      new_references.ld_sequence_number,
      new_references.all_terms_flag,
      new_references.override_exist_ant_data_flag,
      new_references.required_flag,
      new_references.minimum_value_num,
      new_references.maximum_value_num,
      new_references.minimum_date,
      new_references.maximium_date,
      new_references.lookup_code,
      new_references.hint_txt
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_question_id                       IN     NUMBER,
    x_question                          IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_application_code                  IN     VARCHAR2,
    x_application_name                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_answer_type_code                  IN     VARCHAR2,
    x_destination_txt                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_all_terms_flag                    IN     VARCHAR2,
    x_override_exist_ant_data_flag      IN     VARCHAR2,
    x_required_flag                     IN     VARCHAR2,
    x_minimum_value_num                 IN     NUMBER,
    x_maximum_value_num                 IN     NUMBER,
    x_minimum_date                      IN     DATE,
    x_maximium_date                     IN     DATE,
    x_lookup_code                       IN     VARCHAR2,
    x_hint_txt                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 07-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || vvutukur       16-feb-2002      removed tlinfo check in IF condition for bug:2222272(SWSCR006-MO)
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        question,
        enabled,
        org_id,
        ci_cal_type,
        ci_sequence_number,
        application_code,
        application_name,
        active_flag,
        answer_type_code,
        destination_txt,
        ld_cal_type,
        ld_sequence_number,
        all_terms_flag,
        override_exist_ant_data_flag,
        required_flag,
        minimum_value_num,
        maximum_value_num,
        minimum_date,
        maximium_date,
        lookup_code,
        hint_txt
      FROM  igf_ap_appl_setup_all
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
        (tlinfo.question = x_question)
        AND (tlinfo.enabled = x_enabled)
        AND (tlinfo.ci_cal_type = x_ci_cal_type)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND (tlinfo.application_code = x_application_code)
        AND (tlinfo.application_name = x_application_name)
        AND ((tlinfo.active_flag = x_active_flag) OR ((tlinfo.active_flag IS NULL) AND (X_active_flag IS NULL)))
        AND ((tlinfo.answer_type_code = x_answer_type_code) OR ((tlinfo.answer_type_code IS NULL) AND (X_answer_type_code IS NULL)))
        AND ((tlinfo.destination_txt = x_destination_txt) OR ((tlinfo.destination_txt IS NULL) AND (X_destination_txt IS NULL)))
        AND ((tlinfo.ld_cal_type = x_ld_cal_type) OR ((tlinfo.ld_cal_type IS NULL) AND (X_ld_cal_type IS NULL)))
        AND ((tlinfo.ld_sequence_number = x_ld_sequence_number) OR ((tlinfo.ld_sequence_number IS NULL) AND (X_ld_sequence_number IS NULL)))
        AND ((tlinfo.all_terms_flag = x_all_terms_flag) OR ((tlinfo.all_terms_flag IS NULL) AND (X_all_terms_flag IS NULL)))
        AND ((tlinfo.override_exist_ant_data_flag = x_override_exist_ant_data_flag) OR ((tlinfo.override_exist_ant_data_flag IS NULL) AND (X_override_exist_ant_data_flag IS NULL)))
        AND ((tlinfo.required_flag = x_required_flag) OR ((tlinfo.required_flag IS NULL) AND (X_required_flag IS NULL)))
        AND ((tlinfo.minimum_value_num = x_minimum_value_num) OR ((tlinfo.minimum_value_num IS NULL) AND (X_minimum_value_num IS NULL)))
        AND ((tlinfo.maximum_value_num = x_maximum_value_num) OR ((tlinfo.maximum_value_num IS NULL) AND (X_maximum_value_num IS NULL)))
        AND ((tlinfo.minimum_date = x_minimum_date) OR ((tlinfo.minimum_date IS NULL) AND (X_minimum_date IS NULL)))
        AND ((tlinfo.maximium_date = x_maximium_date) OR ((tlinfo.maximium_date IS NULL) AND (X_maximium_date IS NULL)))
        AND ((tlinfo.lookup_code = x_lookup_code) OR ((tlinfo.lookup_code IS NULL) AND (X_lookup_code IS NULL)))
        AND ((tlinfo.hint_txt = x_hint_txt) OR ((tlinfo.hint_txt IS NULL) AND (X_hint_txt IS NULL)))
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
    x_question_id                       IN     NUMBER,
    x_question                          IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_application_code                  IN     VARCHAR2,
    x_application_name                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_answer_type_code                  IN     VARCHAR2,
    x_destination_txt                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_all_terms_flag                    IN     VARCHAR2,
    x_override_exist_ant_data_flag      IN     VARCHAR2,
    x_required_flag                     IN     VARCHAR2,
    x_minimum_value_num                 IN     NUMBER,
    x_maximum_value_num                 IN     NUMBER,
    x_minimum_date                      IN     DATE,
    x_maximium_date                     IN     DATE,
    x_lookup_code                       IN     VARCHAR2,
    x_hint_txt                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 07-DEC-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || vvutukur        16-feb-2002     passed igf_aw_gen.get_org_id in call to up before_dml call.bug:2222272.
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_question_id                       => x_question_id,
      x_question                          => x_question,
      x_enabled                           => NVL (x_enabled,'Y' ),
      x_org_id                            => igf_aw_gen.get_org_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_application_code                  => x_application_code,
      x_application_name                  => x_application_name,
      x_active_flag                       => x_active_flag,
      x_answer_type_code                  => x_answer_type_code,
      x_destination_txt                   => x_destination_txt,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_all_terms_flag                    => x_all_terms_flag,
      x_override_exist_ant_data_flag      => x_override_exist_ant_data_flag,
      x_required_flag                     => x_required_flag,
      x_minimum_value_num                 => x_minimum_value_num,
      x_maximum_value_num                 => x_maximum_value_num,
      x_minimum_date                      => x_minimum_date,
      x_maximium_date                     => x_maximium_date,
      x_lookup_code                       => x_lookup_code,
      x_hint_txt                          => x_hint_txt
    );

    UPDATE igf_ap_appl_setup_all
      SET
        question                          = new_references.question,
        enabled                           = new_references.enabled,
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        application_code                  = new_references.application_code,
        application_name                  = new_references.application_name,
        active_flag                       = new_references.active_flag,
        answer_type_code                  = new_references.answer_type_code,
        destination_txt                   = new_references.destination_txt,
        ld_cal_type                       = new_references.ld_cal_type,
        ld_sequence_number                = new_references.ld_sequence_number,
        all_terms_flag                    = new_references.all_terms_flag,
        override_exist_ant_data_flag      = new_references.override_exist_ant_data_flag,
        required_flag                     = new_references.required_flag,
        minimum_value_num                 = new_references.minimum_value_num,
        maximum_value_num                 = new_references.maximum_value_num,
        minimum_date                      = new_references.minimum_date,
        maximium_date                     = new_references.maximium_date,
        lookup_code                       = new_references.lookup_code,
        hint_txt                          = new_references.hint_txt
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_question_id                       IN OUT NOCOPY NUMBER,
    x_question                          IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_application_code                  IN     VARCHAR2,
    x_application_name                  IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_answer_type_code                  IN     VARCHAR2,
    x_destination_txt                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_all_terms_flag                    IN     VARCHAR2,
    x_override_exist_ant_data_flag      IN     VARCHAR2,
    x_required_flag                     IN     VARCHAR2,
    x_minimum_value_num                 IN     NUMBER,
    x_maximum_value_num                 IN     NUMBER,
    x_minimum_date                      IN     DATE,
    x_maximium_date                     IN     DATE,
    x_lookup_code                       IN     VARCHAR2,
    x_hint_txt                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 07-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_appl_setup_all
      WHERE    question_id                       = x_question_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_question_id,
        x_question,
        x_enabled,
        x_org_id,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_mode,
        x_application_code,
        x_application_name,
        x_active_flag,
        x_answer_type_code,
        x_destination_txt,
        x_ld_cal_type,
        x_ld_sequence_number,
        x_all_terms_flag,
        x_override_exist_ant_data_flag,
        x_required_flag,
        x_minimum_value_num,
        x_maximum_value_num,
        x_minimum_date,
        x_maximium_date,
        x_lookup_code,
        x_hint_txt
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_question_id,
      x_question,
      x_enabled,
      x_org_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_mode,
      x_application_code,
      x_application_name,
      x_active_flag,
      x_answer_type_code,
      x_destination_txt,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_all_terms_flag,
      x_override_exist_ant_data_flag,
      x_required_flag,
      x_minimum_value_num,
      x_maximum_value_num,
      x_minimum_date,
      x_maximium_date,
      x_lookup_code,
      x_hint_txt
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 07-DEC-2000
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

    DELETE FROM igf_ap_appl_setup_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_appl_setup_pkg;

/
