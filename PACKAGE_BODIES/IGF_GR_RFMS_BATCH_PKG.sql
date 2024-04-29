--------------------------------------------------------
--  DDL for Package Body IGF_GR_RFMS_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_RFMS_BATCH_PKG" AS
/* $Header: IGFGI15B.pls 115.6 2002/11/28 14:18:45 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_gr_rfms_batch_all%ROWTYPE;
  new_references igf_gr_rfms_batch_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2   ,
    x_rfmb_id                           IN     NUMBER     ,
    x_batch_id                          IN     VARCHAR2   ,
    x_data_rec_length                   IN     VARCHAR2   ,
    x_ope_id                            IN     VARCHAR2   ,
    x_software_providor                 IN     VARCHAR2   ,
    x_rfms_process_dt                   IN     DATE       ,
    x_rfms_ack_dt                       IN     DATE       ,
    x_rfms_ack_batch_id                 IN     VARCHAR2   ,
    x_reject_reason                     IN     VARCHAR2   ,
    x_creation_date                     IN     DATE       ,
    x_created_by                        IN     NUMBER     ,
    x_last_update_date                  IN     DATE       ,
    x_last_updated_by                   IN     NUMBER     ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 10-JAN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_gr_rfms_batch_all
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
    new_references.rfmb_id                           := x_rfmb_id;
    new_references.batch_id                          := x_batch_id;
    new_references.data_rec_length                   := x_data_rec_length;
    new_references.ope_id                            := x_ope_id;
    new_references.software_providor                 := x_software_providor;
    new_references.rfms_process_dt                   := x_rfms_process_dt;
    new_references.rfms_ack_dt                       := x_rfms_ack_dt;
    new_references.rfms_ack_batch_id                 := x_rfms_ack_batch_id;
    new_references.reject_reason                     := x_reject_reason;

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
    x_rfmb_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 10-JAN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_rfms_batch_all
      WHERE    rfmb_id = x_rfmb_id
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

  PROCEDURE check_child_existance IS
  /*
  ||  Created By : cdcruz
  ||  Created On : 10-JAN-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_gr_rfms_pkg.get_fk_igf_gr_rfms_batch (
      old_references.rfmb_id
      );

    igf_gr_rfms_disb_pkg.get_fk_igf_gr_rfms_batch (
      old_references.rfmb_id
      );

  END check_child_existance ;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2   ,
    x_rfmb_id                           IN     NUMBER     ,
    x_batch_id                          IN     VARCHAR2   ,
    x_data_rec_length                   IN     VARCHAR2   ,
    x_ope_id                            IN     VARCHAR2   ,
    x_software_providor                 IN     VARCHAR2   ,
    x_rfms_process_dt                   IN     DATE       ,
    x_rfms_ack_dt                       IN     DATE       ,
    x_rfms_ack_batch_id                 IN     VARCHAR2   ,
    x_reject_reason                     IN     VARCHAR2   ,
    x_creation_date                     IN     DATE       ,
    x_created_by                        IN     NUMBER     ,
    x_last_update_date                  IN     DATE       ,
    x_last_updated_by                   IN     NUMBER     ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 10-JAN-2001
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
      x_rfmb_id,
      x_batch_id,
      x_data_rec_length,
      x_ope_id,
      x_software_providor,
      x_rfms_process_dt,
      x_rfms_ack_dt,
      x_rfms_ack_batch_id,
      x_reject_reason,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.rfmb_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.rfmb_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    ELSIF (p_action = 'DELETE') THEN
       check_child_existance ;

    ELSIF (p_action = 'VALIDATE_DELETE') THEN
       check_child_existance ;



    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rfmb_id                           IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_data_rec_length                   IN     VARCHAR2,
    x_ope_id                            IN     VARCHAR2,
    x_software_providor                 IN     VARCHAR2,
    x_rfms_process_dt                   IN     DATE,
    x_rfms_ack_dt                       IN     DATE,
    x_rfms_ack_batch_id                 IN     VARCHAR2,
    x_reject_reason                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 10-JAN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_gr_rfms_batch_all
      WHERE    rfmb_id                           = x_rfmb_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_gr_rfms_batch_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT igf_gr_rfms_batch_s.nextval into x_rfmb_id
    FROM dual ;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_rfmb_id                           => x_rfmb_id,
      x_batch_id                          => x_batch_id,
      x_data_rec_length                   => x_data_rec_length,
      x_ope_id                            => x_ope_id,
      x_software_providor                 => x_software_providor,
      x_rfms_process_dt                   => x_rfms_process_dt,
      x_rfms_ack_dt                       => x_rfms_ack_dt,
      x_rfms_ack_batch_id                 => x_rfms_ack_batch_id,
      x_reject_reason                     => x_reject_reason,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_gr_rfms_batch_all (
      rfmb_id,
      batch_id,
      data_rec_length,
      ope_id,
      software_providor,
      rfms_process_dt,
      rfms_ack_dt,
      rfms_ack_batch_id,
      reject_reason,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id
    ) VALUES (
      new_references.rfmb_id,
      new_references.batch_id,
      new_references.data_rec_length,
      new_references.ope_id,
      new_references.software_providor,
      new_references.rfms_process_dt,
      new_references.rfms_ack_dt,
      new_references.rfms_ack_batch_id,
      new_references.reject_reason,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
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
    x_rfmb_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_data_rec_length                   IN     VARCHAR2,
    x_ope_id                            IN     VARCHAR2,
    x_software_providor                 IN     VARCHAR2,
    x_rfms_process_dt                   IN     DATE,
    x_rfms_ack_dt                       IN     DATE,
    x_rfms_ack_batch_id                 IN     VARCHAR2,
    x_reject_reason                     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 10-JAN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        batch_id,
        data_rec_length,
        ope_id,
        software_providor,
        rfms_process_dt,
        rfms_ack_dt,
        rfms_ack_batch_id,
        reject_reason
      FROM  igf_gr_rfms_batch_all
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
        ((tlinfo.batch_id = x_batch_id) OR ((tlinfo.batch_id IS NULL) AND (X_batch_id IS NULL)))
        AND ((tlinfo.data_rec_length = x_data_rec_length) OR ((tlinfo.data_rec_length IS NULL) AND (X_data_rec_length IS NULL)))
        AND ((tlinfo.ope_id = x_ope_id) OR ((tlinfo.ope_id IS NULL) AND (X_ope_id IS NULL)))
        AND ((tlinfo.software_providor = x_software_providor) OR ((tlinfo.software_providor IS NULL) AND (X_software_providor IS NULL)))
        AND ((tlinfo.rfms_process_dt = x_rfms_process_dt) OR ((tlinfo.rfms_process_dt IS NULL) AND (X_rfms_process_dt IS NULL)))
        AND ((tlinfo.rfms_ack_dt = x_rfms_ack_dt) OR ((tlinfo.rfms_ack_dt IS NULL) AND (X_rfms_ack_dt IS NULL)))
        AND ((tlinfo.rfms_ack_batch_id = x_rfms_ack_batch_id) OR ((tlinfo.rfms_ack_batch_id IS NULL) AND (X_rfms_ack_batch_id IS NULL)))
        AND ((tlinfo.reject_reason = x_reject_reason) OR ((tlinfo.reject_reason IS NULL) AND (X_reject_reason IS NULL)))
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
    x_rfmb_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_data_rec_length                   IN     VARCHAR2,
    x_ope_id                            IN     VARCHAR2,
    x_software_providor                 IN     VARCHAR2,
    x_rfms_process_dt                   IN     DATE,
    x_rfms_ack_dt                       IN     DATE,
    x_rfms_ack_batch_id                 IN     VARCHAR2,
    x_reject_reason                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 10-JAN-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_rfmb_id                           => x_rfmb_id,
      x_batch_id                          => x_batch_id,
      x_data_rec_length                   => x_data_rec_length,
      x_ope_id                            => x_ope_id,
      x_software_providor                 => x_software_providor,
      x_rfms_process_dt                   => x_rfms_process_dt,
      x_rfms_ack_dt                       => x_rfms_ack_dt,
      x_rfms_ack_batch_id                 => x_rfms_ack_batch_id,
      x_reject_reason                     => x_reject_reason,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igf_gr_rfms_batch_all
      SET
        batch_id                          = new_references.batch_id,
        data_rec_length                   = new_references.data_rec_length,
        ope_id                            = new_references.ope_id,
        software_providor                 = new_references.software_providor,
        rfms_process_dt                   = new_references.rfms_process_dt,
        rfms_ack_dt                       = new_references.rfms_ack_dt,
        rfms_ack_batch_id                 = new_references.rfms_ack_batch_id,
        reject_reason                     = new_references.reject_reason,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rfmb_id                           IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_data_rec_length                   IN     VARCHAR2,
    x_ope_id                            IN     VARCHAR2,
    x_software_providor                 IN     VARCHAR2,
    x_rfms_process_dt                   IN     DATE,
    x_rfms_ack_dt                       IN     DATE,
    x_rfms_ack_batch_id                 IN     VARCHAR2,
    x_reject_reason                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 10-JAN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_gr_rfms_batch_all
      WHERE    rfmb_id                           = x_rfmb_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_rfmb_id,
        x_batch_id,
        x_data_rec_length,
        x_ope_id,
        x_software_providor,
        x_rfms_process_dt,
        x_rfms_ack_dt,
        x_rfms_ack_batch_id,
        x_reject_reason,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_rfmb_id,
      x_batch_id,
      x_data_rec_length,
      x_ope_id,
      x_software_providor,
      x_rfms_process_dt,
      x_rfms_ack_dt,
      x_rfms_ack_batch_id,
      x_reject_reason,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 10-JAN-2001
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

    DELETE FROM igf_gr_rfms_batch_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_gr_rfms_batch_pkg;

/
