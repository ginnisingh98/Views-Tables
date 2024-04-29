--------------------------------------------------------
--  DDL for Package Body IGF_AW_AWD_LTR_TMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_AWD_LTR_TMP_PKG" AS
/* $Header: IGFWI51B.pls 120.0 2005/06/01 13:53:06 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGF_AW_AWD_LTR_TMP%ROWTYPE;
  new_references IGF_AW_AWD_LTR_TMP%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_line_id                           IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_fund_description                  IN     VARCHAR2    DEFAULT NULL,
    x_award_name                        IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_award_total                       IN     NUMBER      DEFAULT NULL,
    x_term_amount_text                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 07-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_AWD_LTR_TMP
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.line_id                           := x_line_id;
    new_references.person_id                         := x_person_id;
    new_references.fund_code                         := x_fund_code;
    new_references.fund_description                  := x_fund_description;
    new_references.award_name                        := x_award_name;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.award_total                       := x_award_total;
    new_references.term_amount_text                  := x_term_amount_text;

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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_line_id                           IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_fund_description                  IN     VARCHAR2    DEFAULT NULL,
    x_award_name                        IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_award_total                       IN     NUMBER      DEFAULT NULL,
    x_term_amount_text                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 07-FEB-2002
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
      x_line_id,
      x_person_id,
      x_fund_code,
      x_fund_description,
      x_award_name,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_award_total ,
      x_term_amount_text ,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.line_id,
             new_references.person_id,
             new_references.ci_cal_type,
             new_references.ci_sequence_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.line_id,
             new_references.person_id,
             new_references.ci_cal_type,
             new_references.ci_sequence_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_line_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_fund_description                  IN     VARCHAR2    DEFAULT NULL,
    x_award_name                        IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_award_total                       IN     NUMBER      DEFAULT NULL,
    x_term_amount_text                  IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 07-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   ROWID
      FROM     IGF_AW_AWD_LTR_TMP
      WHERE    line_id = new_references.line_id ;

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
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_line_id                           => x_line_id,
      x_person_id                         => x_person_id,
      x_fund_code                         => x_fund_code,
      x_fund_description                         => x_fund_description,
      x_award_name                        => x_award_name,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_award_total                       => x_award_total ,
      x_term_amount_text                  => x_term_amount_text,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO IGF_AW_AWD_LTR_TMP (
      line_id,
      person_id,
      fund_code,
      fund_description,
      award_name,
      ci_cal_type,
      ci_sequence_number,
      award_total ,
      term_amount_text ,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.line_id,
      new_references.person_id,
      new_references.fund_code,
      new_references.fund_description,
      new_references.award_name,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      new_references.award_total ,
      new_references.term_amount_text ,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
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
    x_line_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_fund_description                  IN     VARCHAR2    DEFAULT NULL,
    x_award_name                        IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_award_total                       IN     NUMBER      DEFAULT NULL,
    x_term_amount_text                  IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 07-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        line_id,
        person_id,
        fund_code,
        fund_description,
        award_name,
        ci_cal_type,
        ci_sequence_number,
        award_total ,
        term_amount_text
      FROM  IGF_AW_AWD_LTR_TMP
      WHERE ROWID = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.line_id = x_line_id)
        AND (tlinfo.person_id = x_person_id)
      AND ((tlinfo.fund_code = X_fund_code) OR ((tlinfo.fund_code IS NULL) AND (X_fund_code IS NULL)))
      AND ((tlinfo.fund_code = X_fund_description) OR ((tlinfo.fund_code IS NULL) AND (X_fund_description IS NULL)))
      AND ((tlinfo.fund_code = X_award_name) OR ((tlinfo.award_name IS NULL) AND (X_award_name IS NULL)))
      AND ((tlinfo.fund_code = X_ci_cal_type) OR ((tlinfo.ci_cal_type IS NULL) AND (X_ci_cal_type IS NULL)))
      AND ((tlinfo.fund_code = X_ci_sequence_number) OR ((tlinfo.ci_sequence_number IS NULL) AND (X_ci_sequence_number IS NULL)))
      AND ((tlinfo.fund_code = X_award_total) OR ((tlinfo.award_total IS NULL) AND (X_award_total IS NULL)))
      AND ((tlinfo.fund_code = X_term_amount_text) OR ((tlinfo.term_amount_text IS NULL) AND (X_term_amount_text IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;

  FUNCTION get_pk_for_validation (
    x_line_id                            IN     NUMBER,
    x_person_id                          IN     NUMBER,
    x_ci_cal_type                        IN     VARCHAR2,
    x_ci_sequence_number                 IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT rowid
        FROM igf_aw_awd_ltr_tmp
       WHERE person_id          = x_person_id
         AND line_id            = x_line_id
         AND ci_cal_type        = x_ci_cal_type
         AND ci_sequence_number = x_ci_sequence_number
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

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_line_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_fund_description                  IN     VARCHAR2    DEFAULT NULL,
    x_award_name                        IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_award_total                       IN     NUMBER      DEFAULT NULL,
    x_term_amount_text                  IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 07-FEB-2002
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
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_line_id                           => x_line_id,
      x_person_id                         => x_person_id,
      x_fund_code                         => x_fund_code,
      x_fund_description                  => x_fund_description,
      x_award_name                        => x_award_name,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_award_total                       => x_award_total,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE IGF_AW_AWD_LTR_TMP
      SET
        line_id                           = new_references.line_id,
        person_id                         = new_references.person_id,
        fund_code                         = new_references.fund_code,
        fund_description                  = new_references.fund_description,
        award_name                        = new_references.award_name,
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        award_total                       = new_references.award_total,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_line_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_fund_description                  IN     VARCHAR2    DEFAULT NULL,
    x_award_name                        IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_award_total                       IN     NUMBER      DEFAULT NULL,
    x_term_amount_text                  IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 07-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   ROWID
      FROM     IGF_AW_AWD_LTR_TMP
      WHERE    line_id = x_line_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_line_id,
        x_person_id,
        x_fund_code,
        x_fund_description,
        x_award_name,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_award_total       ,
        x_term_amount_text   ,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_line_id,
      x_person_id,
      x_fund_code,
      x_fund_description,
      x_award_name,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_award_total       ,
      x_term_amount_text   ,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 07-FEB-2002
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

    DELETE FROM IGF_AW_AWD_LTR_TMP
    WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_awd_ltr_tmp_pkg;

/
