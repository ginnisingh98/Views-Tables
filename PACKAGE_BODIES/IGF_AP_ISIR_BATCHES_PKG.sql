--------------------------------------------------------
--  DDL for Package Body IGF_AP_ISIR_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_ISIR_BATCHES_PKG" AS
/* $Header: IGFAI06B.pls 115.7 2002/11/28 13:55:14 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_ap_isir_batches_all%ROWTYPE;
  new_references igf_ap_isir_batches_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_number                      IN     VARCHAR2    DEFAULT NULL,
    x_batch_year                        IN     VARCHAR2    DEFAULT NULL,
    x_batch_type                        IN     VARCHAR2    DEFAULT NULL,
    x_batch_count                       IN     NUMBER      DEFAULT NULL,
    x_tran_source_site                  IN     NUMBER      DEFAULT NULL,
    x_stud_rec_count                    IN     NUMBER      DEFAULT NULL,
    x_err_rec_count                     IN     NUMBER      DEFAULT NULL,
    x_not_on_db_count                   IN     NUMBER      DEFAULT NULL,
    x_batch_creation_date               IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 02-JAN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AP_ISIR_BATCHES_ALL
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
    new_references.batch_number                      := x_batch_number;
    new_references.batch_year                        := x_batch_year;
    new_references.batch_type                        := x_batch_type;
    new_references.batch_count                       := x_batch_count;
    new_references.tran_source_site                  := x_tran_source_site;
    new_references.stud_rec_count                    := x_stud_rec_count;
    new_references.err_rec_count                     := x_err_rec_count;
    new_references.not_on_db_count                   := x_not_on_db_count;
    new_references.batch_creation_date               := x_batch_creation_date;

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


  FUNCTION get_pk_for_validation (
    x_batch_number                      IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasingh
  ||  Created On : 02-JAN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_isir_batches_all
      WHERE    batch_number = x_batch_number
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_number                      IN     VARCHAR2    DEFAULT NULL,
    x_batch_year                        IN     VARCHAR2    DEFAULT NULL,
    x_batch_type                        IN     VARCHAR2    DEFAULT NULL,
    x_batch_count                       IN     NUMBER      DEFAULT NULL,
    x_tran_source_site                  IN     NUMBER      DEFAULT NULL,
    x_stud_rec_count                    IN     NUMBER      DEFAULT NULL,
    x_err_rec_count                     IN     NUMBER      DEFAULT NULL,
    x_not_on_db_count                   IN     NUMBER      DEFAULT NULL,
    x_batch_creation_date               IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 02-JAN-2001
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
      x_batch_number,
      x_batch_year,
      x_batch_type,
      x_batch_count,
      x_tran_source_site,
      x_stud_rec_count,
      x_err_rec_count,
      x_not_on_db_count,
      x_batch_creation_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.batch_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.batch_number
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
    x_batch_number                      IN     VARCHAR2,
    x_batch_year                        IN     VARCHAR2,
    x_batch_type                        IN     VARCHAR2,
    x_batch_count                       IN     NUMBER,
    x_tran_source_site                  IN     NUMBER,
    x_stud_rec_count                    IN     NUMBER,
    x_err_rec_count                     IN     NUMBER,
    x_not_on_db_count                   IN     NUMBER,
    x_batch_creation_date               IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 02-JAN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_isir_batches_all
      WHERE    batch_number                      = x_batch_number;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

    l_org_id                igf_ap_isir_batches_all.org_id%TYPE  DEFAULT igf_aw_gen.get_org_id;

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
      x_batch_number                      => x_batch_number,
      x_batch_year                        => x_batch_year,
      x_batch_type                        => x_batch_type,
      x_batch_count                       => x_batch_count,
      x_tran_source_site                  => x_tran_source_site,
      x_stud_rec_count                    => x_stud_rec_count,
      x_err_rec_count                     => x_err_rec_count,
      x_not_on_db_count                   => x_not_on_db_count,
      x_batch_creation_date               => x_batch_creation_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_ap_isir_batches_all (
      batch_number,
      batch_year,
      batch_type,
      batch_count,
      tran_source_site,
      stud_rec_count,
      err_rec_count,
      not_on_db_count,
      batch_creation_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id
    ) VALUES (
      new_references.batch_number,
      new_references.batch_year,
      new_references.batch_type,
      new_references.batch_count,
      new_references.tran_source_site,
      new_references.stud_rec_count,
      new_references.err_rec_count,
      new_references.not_on_db_count,
      new_references.batch_creation_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      l_org_id
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
    x_batch_number                      IN     VARCHAR2,
    x_batch_year                        IN     VARCHAR2,
    x_batch_type                        IN     VARCHAR2,
    x_batch_count                       IN     NUMBER,
    x_tran_source_site                  IN     NUMBER,
    x_stud_rec_count                    IN     NUMBER,
    x_err_rec_count                     IN     NUMBER,
    x_not_on_db_count                   IN     NUMBER,
    x_batch_creation_date               IN     DATE
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 02-JAN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        batch_year,
        batch_type,
        batch_count,
        tran_source_site,
        stud_rec_count,
        err_rec_count,
        not_on_db_count,
        batch_creation_date,
        org_id
      FROM  igf_ap_isir_batches_all
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
        ((tlinfo.batch_year = x_batch_year) OR ((tlinfo.batch_year IS NULL) AND (X_batch_year IS NULL)))
        AND ((tlinfo.batch_type = x_batch_type) OR ((tlinfo.batch_type IS NULL) AND (X_batch_type IS NULL)))
        AND ((tlinfo.batch_count = x_batch_count) OR ((tlinfo.batch_count IS NULL) AND (X_batch_count IS NULL)))
        AND ((tlinfo.tran_source_site = x_tran_source_site) OR ((tlinfo.tran_source_site IS NULL) AND (X_tran_source_site IS NULL)))
        AND ((tlinfo.stud_rec_count = x_stud_rec_count) OR ((tlinfo.stud_rec_count IS NULL) AND (X_stud_rec_count IS NULL)))
        AND ((tlinfo.err_rec_count = x_err_rec_count) OR ((tlinfo.err_rec_count IS NULL) AND (X_err_rec_count IS NULL)))
        AND ((tlinfo.not_on_db_count = x_not_on_db_count) OR ((tlinfo.not_on_db_count IS NULL) AND (X_not_on_db_count IS NULL)))
        AND ((tlinfo.batch_creation_date = x_batch_creation_date) OR ((tlinfo.batch_creation_date IS NULL) AND (X_batch_creation_date IS NULL)))
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
    x_batch_number                      IN     VARCHAR2,
    x_batch_year                        IN     VARCHAR2,
    x_batch_type                        IN     VARCHAR2,
    x_batch_count                       IN     NUMBER,
    x_tran_source_site                  IN     NUMBER,
    x_stud_rec_count                    IN     NUMBER,
    x_err_rec_count                     IN     NUMBER,
    x_not_on_db_count                   IN     NUMBER,
    x_batch_creation_date               IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 02-JAN-2001
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
      x_batch_number                      => x_batch_number,
      x_batch_year                        => x_batch_year,
      x_batch_type                        => x_batch_type,
      x_batch_count                       => x_batch_count,
      x_tran_source_site                  => x_tran_source_site,
      x_stud_rec_count                    => x_stud_rec_count,
      x_err_rec_count                     => x_err_rec_count,
      x_not_on_db_count                   => x_not_on_db_count,
      x_batch_creation_date               => x_batch_creation_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_ap_isir_batches_all
      SET
        batch_year                        = new_references.batch_year,
        batch_type                        = new_references.batch_type,
        batch_count                       = new_references.batch_count,
        tran_source_site                  = new_references.tran_source_site,
        stud_rec_count                    = new_references.stud_rec_count,
        err_rec_count                     = new_references.err_rec_count,
        not_on_db_count                   = new_references.not_on_db_count,
        batch_creation_date               = new_references.batch_creation_date,
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
    x_batch_number                      IN     VARCHAR2,
    x_batch_year                        IN     VARCHAR2,
    x_batch_type                        IN     VARCHAR2,
    x_batch_count                       IN     NUMBER,
    x_tran_source_site                  IN     NUMBER,
    x_stud_rec_count                    IN     NUMBER,
    x_err_rec_count                     IN     NUMBER,
    x_not_on_db_count                   IN     NUMBER,
    x_batch_creation_date               IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 02-JAN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_isir_batches_all
      WHERE    batch_number                      = x_batch_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_batch_number,
        x_batch_year,
        x_batch_type,
        x_batch_count,
        x_tran_source_site,
        x_stud_rec_count,
        x_err_rec_count,
        x_not_on_db_count,
        x_batch_creation_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_batch_number,
      x_batch_year,
      x_batch_type,
      x_batch_count,
      x_tran_source_site,
      x_stud_rec_count,
      x_err_rec_count,
      x_not_on_db_count,
      x_batch_creation_date,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 02-JAN-2001
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

    DELETE FROM igf_ap_isir_batches_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_isir_batches_pkg;

/
