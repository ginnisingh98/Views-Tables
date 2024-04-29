--------------------------------------------------------
--  DDL for Package Body IGF_SL_CLCHRS_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CLCHRS_DTLS_PKG" AS
/* $Header: IGFLI41B.pls 120.0 2005/06/01 13:02:48 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_clchrs_dtls%ROWTYPE;
  new_references igf_sl_clchrs_dtls%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_clchgrsp_id                       IN     NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code                       IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2,
    x_error_message_1_code              IN     VARCHAR2,
    x_error_message_2_code              IN     VARCHAR2,
    x_error_message_3_code              IN     VARCHAR2,
    x_error_message_4_code              IN     VARCHAR2,
    x_error_message_5_code              IN     VARCHAR2,
    x_record_process_code               IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 04-NOV-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_sl_clchrs_dtls
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
    new_references.clchgrsp_id                       := x_clchgrsp_id;
    new_references.clrp1_id                          := x_clrp1_id;
    new_references.record_code                       := x_record_code;
    new_references.send_record_txt                   := x_send_record_txt;
    new_references.error_message_1_code              := x_error_message_1_code;
    new_references.error_message_2_code              := x_error_message_2_code;
    new_references.error_message_3_code              := x_error_message_3_code;
    new_references.error_message_4_code              := x_error_message_4_code;
    new_references.error_message_5_code              := x_error_message_5_code;
    new_references.record_process_code               := x_record_process_code;

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
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 04-NOV-2004
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

     IF ((old_references.clrp1_id = new_references.clrp1_id))
        OR
        ((new_references.clrp1_id IS NULL)) THEN
        NULL;
     ELSIF NOT igf_sl_cl_resp_r1_pkg.get_pk_for_validation (
                 x_clrp1_id => new_references.clrp1_id
                )  THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
     END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_clchgrsp_id      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 04-NOV-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
      CURSOR cur_rowid IS
      SELECT rowid
      FROM   igf_sl_clchrs_dtls
      WHERE  clchgrsp_id = x_clchgrsp_id
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

  PROCEDURE get_fk_igf_sl_cl_resp_r1 (
    x_clrp1_id      IN     NUMBER
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 04-NOV-2004
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

      CURSOR cur_rowid IS
      SELECT rowid
      FROM   igf_sl_clchrs_dtls
      WHERE  ((clrp1_id = x_clrp1_id ));

      lv_rowid cur_rowid%ROWTYPE;
  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_CLCHGRSP_CLRP1_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_cl_resp_r1;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_clchgrsp_id                       IN     NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code                       IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2,
    x_error_message_1_code              IN     VARCHAR2,
    x_error_message_2_code              IN     VARCHAR2,
    x_error_message_3_code              IN     VARCHAR2,
    x_error_message_4_code              IN     VARCHAR2,
    x_error_message_5_code              IN     VARCHAR2,
    x_record_process_code               IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 04-NOV-2004
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
      x_clchgrsp_id,
      x_clrp1_id,
      x_record_code,
      x_send_record_txt,
      x_error_message_1_code,
      x_error_message_2_code,
      x_error_message_3_code,
      x_error_message_4_code,
      x_error_message_5_code,
      x_record_process_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

      IF ( get_pk_for_validation(
             new_references.clchgrsp_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.clchgrsp_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    l_rowid := NULL;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clchgrsp_id                       IN OUT NOCOPY NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code                       IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2,
    x_error_message_1_code              IN     VARCHAR2,
    x_error_message_2_code              IN     VARCHAR2,
    x_error_message_3_code              IN     VARCHAR2,
    x_error_message_4_code              IN     VARCHAR2,
    x_error_message_5_code              IN     VARCHAR2,
    x_record_process_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 04-NOV-2004
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      fnd_message.set_token ('ROUTINE', 'IGF_SL_CLCHRS_DTLS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_clchgrsp_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_clchgrsp_id                       => x_clchgrsp_id,
      x_clrp1_id                          => x_clrp1_id,
      x_record_code                       => x_record_code,
      x_send_record_txt                   => x_send_record_txt,
      x_error_message_1_code              => x_error_message_1_code,
      x_error_message_2_code              => x_error_message_2_code,
      x_error_message_3_code              => x_error_message_3_code,
      x_error_message_4_code              => x_error_message_4_code,
      x_error_message_5_code              => x_error_message_5_code,
      x_record_process_code               => x_record_process_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_sl_clchrs_dtls (
      clchgrsp_id,
      clrp1_id,
      record_code,
      send_record_txt,
      error_message_1_code,
      error_message_2_code,
      error_message_3_code,
      error_message_4_code,
      error_message_5_code,
      record_process_code,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      igf_sl_clchrs_dtls_s.NEXTVAL,
      new_references.clrp1_id,
      new_references.record_code,
      new_references.send_record_txt,
      new_references.error_message_1_code,
      new_references.error_message_2_code,
      new_references.error_message_3_code,
      new_references.error_message_4_code,
      new_references.error_message_5_code,
      new_references.record_process_code,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, clchgrsp_id INTO x_rowid, x_clchgrsp_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_clchgrsp_id                       IN     NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code                       IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2,
    x_error_message_1_code              IN     VARCHAR2,
    x_error_message_2_code              IN     VARCHAR2,
    x_error_message_3_code              IN     VARCHAR2,
    x_error_message_4_code              IN     VARCHAR2,
    x_error_message_5_code              IN     VARCHAR2,
    x_record_process_code               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 04-NOV-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        clchgrsp_id,
        clrp1_id,
        record_code,
        send_record_txt,
        error_message_1_code,
        error_message_2_code,
        error_message_3_code,
        error_message_4_code,
        error_message_5_code,
        record_process_code
      FROM  igf_sl_clchrs_dtls
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
        (tlinfo.clchgrsp_id = x_clchgrsp_id)
        AND (tlinfo.clrp1_id = x_clrp1_id)
        AND (tlinfo.record_code = x_record_code)
        AND ((tlinfo.send_record_txt = x_send_record_txt) OR ((tlinfo.send_record_txt IS NULL) AND (X_send_record_txt IS NULL)))
        AND ((tlinfo.error_message_1_code = x_error_message_1_code) OR ((tlinfo.error_message_1_code IS NULL) AND (X_error_message_1_code IS NULL)))
        AND ((tlinfo.error_message_2_code = x_error_message_2_code) OR ((tlinfo.error_message_2_code IS NULL) AND (X_error_message_2_code IS NULL)))
        AND ((tlinfo.error_message_3_code = x_error_message_3_code) OR ((tlinfo.error_message_3_code IS NULL) AND (X_error_message_3_code IS NULL)))
        AND ((tlinfo.error_message_4_code = x_error_message_4_code) OR ((tlinfo.error_message_4_code IS NULL) AND (X_error_message_4_code IS NULL)))
        AND ((tlinfo.error_message_5_code = x_error_message_5_code) OR ((tlinfo.error_message_5_code IS NULL) AND (X_error_message_5_code IS NULL)))
        AND ((tlinfo.record_process_code = x_record_process_code) OR ((tlinfo.record_process_code IS NULL) AND (X_record_process_code IS NULL)))
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
    x_clchgrsp_id                       IN     NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code                       IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2,
    x_error_message_1_code              IN     VARCHAR2,
    x_error_message_2_code              IN     VARCHAR2,
    x_error_message_3_code              IN     VARCHAR2,
    x_error_message_4_code              IN     VARCHAR2,
    x_error_message_5_code              IN     VARCHAR2,
    x_record_process_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 04-NOV-2004
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
      fnd_message.set_token ('ROUTINE', 'IGF_SL_CLCHRS_DTLS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_clchgrsp_id                       => x_clchgrsp_id,
      x_clrp1_id                          => x_clrp1_id,
      x_record_code                       => x_record_code,
      x_send_record_txt                   => x_send_record_txt,
      x_error_message_1_code              => x_error_message_1_code,
      x_error_message_2_code              => x_error_message_2_code,
      x_error_message_3_code              => x_error_message_3_code,
      x_error_message_4_code              => x_error_message_4_code,
      x_error_message_5_code              => x_error_message_5_code,
      x_record_process_code               => x_record_process_code,
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

    UPDATE igf_sl_clchrs_dtls
      SET
        clchgrsp_id                       = new_references.clchgrsp_id,
        clrp1_id                          = new_references.clrp1_id,
        record_code                       = new_references.record_code,
        send_record_txt                   = new_references.send_record_txt,
        error_message_1_code              = new_references.error_message_1_code,
        error_message_2_code              = new_references.error_message_2_code,
        error_message_3_code              = new_references.error_message_3_code,
        error_message_4_code              = new_references.error_message_4_code,
        error_message_5_code              = new_references.error_message_5_code,
        record_process_code               = new_references.record_process_code,
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
    x_clchgrsp_id                       IN OUT NOCOPY NUMBER,
    x_clrp1_id                          IN     NUMBER,
    x_record_code                       IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2,
    x_error_message_1_code              IN     VARCHAR2,
    x_error_message_2_code              IN     VARCHAR2,
    x_error_message_3_code              IN     VARCHAR2,
    x_error_message_4_code              IN     VARCHAR2,
    x_error_message_5_code              IN     VARCHAR2,
    x_record_process_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 04-NOV-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_clchrs_dtls
      WHERE    clchgrsp_id = x_clchgrsp_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_clchgrsp_id,
        x_clrp1_id,
        x_record_code,
        x_send_record_txt,
        x_error_message_1_code,
        x_error_message_2_code,
        x_error_message_3_code,
        x_error_message_4_code,
        x_error_message_5_code,
        x_record_process_code,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_clchgrsp_id,
      x_clrp1_id,
      x_record_code,
      x_send_record_txt,
      x_error_message_1_code,
      x_error_message_2_code,
      x_error_message_3_code,
      x_error_message_4_code,
      x_error_message_5_code,
      x_record_process_code,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 04-NOV-2004
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

    DELETE FROM igf_sl_clchrs_dtls
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_clchrs_dtls_pkg;

/
