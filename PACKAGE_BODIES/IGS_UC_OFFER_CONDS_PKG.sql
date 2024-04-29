--------------------------------------------------------
--  DDL for Package Body IGS_UC_OFFER_CONDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_OFFER_CONDS_PKG" AS
/* $Header: IGSXI22B.pls 115.6 2003/11/02 18:00:53 ayedubat noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_offer_conds%ROWTYPE;
  new_references igs_uc_offer_conds%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_effective_from                    IN     DATE    ,
    x_effective_to                      IN     DATE    ,
    x_status                            IN     VARCHAR2,
    x_marvin_code                       IN     VARCHAR2,
    x_summ_of_cond                      IN     VARCHAR2,
    x_letter_text                       IN     LONG    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER   ,
    x_decision                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_OFFER_CONDS
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
    new_references.condition_category                := x_condition_category;
    new_references.condition_name                    := x_condition_name;
    new_references.effective_from                    := x_effective_from;
    new_references.effective_to                      := x_effective_to;
    new_references.status                            := x_status;
    new_references.marvin_code                       := x_marvin_code;
    new_references.summ_of_cond                      := x_summ_of_cond;
    new_references.letter_text                       := x_letter_text;
    new_references.decision                          := x_decision;

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


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_uc_app_choices_pkg.get_fk_igs_uc_offer_conds (
      old_references.condition_category,
      old_references.condition_name
    );

    igs_uc_cond_details_pkg.get_fk_igs_uc_offer_conds (
      old_references.condition_category,
      old_references.condition_name
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_offer_conds
      WHERE    condition_category = x_condition_category
      AND      condition_name = x_condition_name ;

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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_effective_from                    IN     DATE    ,
    x_effective_to                      IN     DATE    ,
    x_status                            IN     VARCHAR2,
    x_marvin_code                       IN     VARCHAR2,
    x_summ_of_cond                      IN     VARCHAR2,
    x_letter_text                       IN     LONG    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_decision                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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
      x_condition_category,
      x_condition_name,
      x_effective_from,
      x_effective_to,
      x_status,
      x_marvin_code,
      x_summ_of_cond,
      x_letter_text,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_decision
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.condition_category,
             new_references.condition_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.condition_category,
             new_references.condition_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_effective_from                    IN     DATE,
    x_effective_to                      IN     DATE,
    x_status                            IN     VARCHAR2,
    x_marvin_code                       IN     VARCHAR2,
    x_summ_of_cond                      IN     VARCHAR2,
    x_letter_text                       IN     LONG,
    x_mode                              IN     VARCHAR2,
    x_decision                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_offer_conds
      WHERE    condition_category                = x_condition_category
      AND      condition_name                    = x_condition_name;

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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_condition_category                => x_condition_category,
      x_condition_name                    => x_condition_name,
      x_effective_from                    => x_effective_from,
      x_effective_to                      => x_effective_to,
      x_status                            => x_status,
      x_marvin_code                       => x_marvin_code,
      x_summ_of_cond                      => x_summ_of_cond,
      x_letter_text                       => x_letter_text,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_decision                          => x_decision
    );

    INSERT INTO igs_uc_offer_conds (
      condition_category,
      condition_name,
      effective_from,
      effective_to,
      status,
      marvin_code,
      summ_of_cond,
      letter_text,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      decision
    ) VALUES (
      new_references.condition_category,
      new_references.condition_name,
      new_references.effective_from,
      new_references.effective_to,
      new_references.status,
      new_references.marvin_code,
      new_references.summ_of_cond,
      new_references.letter_text,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      new_references.decision
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
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_effective_from                    IN     DATE,
    x_effective_to                      IN     DATE,
    x_status                            IN     VARCHAR2,
    x_marvin_code                       IN     VARCHAR2,
    x_summ_of_cond                      IN     VARCHAR2,
    x_letter_text                       IN     LONG,
    x_decision                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        effective_from,
        effective_to,
        status,
        marvin_code,
        summ_of_cond,
        letter_text,
        decision
      FROM  igs_uc_offer_conds
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
        (tlinfo.effective_from = x_effective_from)
        AND ((tlinfo.effective_to = x_effective_to) OR ((tlinfo.effective_to IS NULL) AND (X_effective_to IS NULL)))
        AND (tlinfo.status = x_status)
        AND ((tlinfo.marvin_code = x_marvin_code) OR ((tlinfo.marvin_code IS NULL) AND (X_marvin_code IS NULL)))
        AND ((tlinfo.summ_of_cond = x_summ_of_cond) OR ((tlinfo.summ_of_cond IS NULL) AND (X_summ_of_cond IS NULL)))
        AND ((tlinfo.letter_text = x_letter_text) OR ((tlinfo.letter_text IS NULL) AND (X_letter_text IS NULL)))
        AND ((tlinfo.decision = x_decision) OR ((tlinfo.decision IS NULL) AND (X_decision IS NULL)))
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
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_effective_from                    IN     DATE,
    x_effective_to                      IN     DATE,
    x_status                            IN     VARCHAR2,
    x_marvin_code                       IN     VARCHAR2,
    x_summ_of_cond                      IN     VARCHAR2,
    x_letter_text                       IN     LONG,
    x_mode                              IN     VARCHAR2,
    x_decision                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_condition_category                => x_condition_category,
      x_condition_name                    => x_condition_name,
      x_effective_from                    => x_effective_from,
      x_effective_to                      => x_effective_to,
      x_status                            => x_status,
      x_marvin_code                       => x_marvin_code,
      x_summ_of_cond                      => x_summ_of_cond,
      x_letter_text                       => x_letter_text,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_decision                          => x_decision
    );

    UPDATE igs_uc_offer_conds
      SET
        effective_from                    = new_references.effective_from,
        effective_to                      = new_references.effective_to,
        status                            = new_references.status,
        marvin_code                       = new_references.marvin_code,
        summ_of_cond                      = new_references.summ_of_cond,
        letter_text                       = new_references.letter_text,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        decision                          = x_decision
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_effective_from                    IN     DATE,
    x_effective_to                      IN     DATE,
    x_status                            IN     VARCHAR2,
    x_marvin_code                       IN     VARCHAR2,
    x_summ_of_cond                      IN     VARCHAR2,
    x_letter_text                       IN     LONG,
    x_mode                              IN     VARCHAR2,
    x_decision                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_offer_conds
      WHERE    condition_category                = x_condition_category
      AND      condition_name                    = x_condition_name;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_condition_category,
        x_condition_name,
        x_effective_from,
        x_effective_to,
        x_status,
        x_marvin_code,
        x_summ_of_cond,
        x_letter_text,
        x_mode ,
        x_decision
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_condition_category,
      x_condition_name,
      x_effective_from,
      x_effective_to,
      x_status,
      x_marvin_code,
      x_summ_of_cond,
      x_letter_text,
      x_mode ,
      x_decision
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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

    DELETE FROM igs_uc_offer_conds
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_offer_conds_pkg;

/
