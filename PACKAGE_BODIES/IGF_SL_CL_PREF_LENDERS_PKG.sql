--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_PREF_LENDERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_PREF_LENDERS_PKG" AS
/* $Header: IGFLI34B.pls 120.0 2005/06/01 13:14:07 appldev noship $ */

  l_rowid VARCHAR2(25);
  g_msg_count  NUMBER;
  g_msg_data   VARCHAR2(2000);
  g_return_status VARCHAR2(1);

  old_references igf_sl_cl_pref_lenders%ROWTYPE;
  new_references igf_sl_cl_pref_lenders%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_clprl_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_relationship_cd             IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_object_version_number             IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 07-SEP-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_sl_cl_pref_lenders
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
    new_references.clprl_id                          := x_clprl_id;
    new_references.person_id                         := x_person_id;
    new_references.relationship_cd             := x_relationship_cd;
    new_references.start_date                        := x_start_date;
    new_references.end_date                          := x_end_date;


    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
      new_references.object_version_number           := (old_references.object_version_number + 1);
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
      new_references.object_version_number           := x_object_version_number;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By :
  ||  Created On : 07-SEP-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_pkg.get_pk_for_validation (
              new_references.person_id
          ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.relationship_cd = new_references.relationship_cd)) OR
        ((new_references.relationship_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_cl_recipient_pkg.get_uk1_for_validation (
              new_references.relationship_cd
          ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_clprl_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 07-SEP-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_pref_lenders
      WHERE    clprl_id = x_clprl_id
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



  PROCEDURE get_fk_igf_sl_cl_recipient (
    x_relationship_cd           IN     VARCHAR2
  ) AS
  /*
  ||  Created By : bkkumar
  ||  Created On : 05-SEP-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_pref_lenders
      WHERE   ((relationship_cd = x_relationship_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF','IGF_SL_CLPRL_RECIP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_cl_recipient;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_clprl_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_relationship_cd             IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_object_version_number             IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 07-SEP-2003
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  l_message  VARCHAR2(2000);
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_clprl_id,
      x_person_id,
      x_relationship_cd,
      x_start_date,
      x_end_date,
      x_object_version_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    l_message := NULL;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.clprl_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.clprl_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;

PROCEDURE after_dml (
    p_action                            IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE
  ) AS
  /*
  ||  Created By : bkkumar
  ||  Created On : 07-SEP-2003
  ||  Purpose : Checks for the valid lender setup.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  l_message  VARCHAR2(2000);
  BEGIN
    l_message := NULL;
    igf_sl_gen.check_lend_relation(x_person_id,x_start_date,x_end_date,l_message);
    IF l_message IS NOT NULL THEN
      g_msg_count  := 1;
      g_msg_data   := l_message;
      g_return_status := 'E';
    END IF ;
  END after_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clprl_id                          IN OUT NOCOPY NUMBER,
    x_msg_count                            OUT NOCOPY NUMBER,
    x_msg_data                             OUT NOCOPY VARCHAR2,
    x_return_status                        OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_relationship_cd             IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_object_version_number             IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 07-SEP-2003
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
    g_msg_count  := NULL;
    g_msg_data   := NULL;
    g_return_status := NULL;
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
      fnd_message.set_token ('ROUTINE', 'IGF_SL_CL_PREF_LENDERS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_clprl_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_clprl_id                          => x_clprl_id,
      x_person_id                         => x_person_id,
      x_relationship_cd                   => x_relationship_cd,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_object_version_number             => x_object_version_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_sl_cl_pref_lenders (
      clprl_id,
      person_id,
      relationship_cd,
      start_date,
      end_date,
      object_version_number,
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
      igf_sl_cl_pref_lenders_s.NEXTVAL,
      new_references.person_id,
      new_references.relationship_cd,
      new_references.start_date,
      new_references.end_date,
      1,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, clprl_id INTO x_rowid, x_clprl_id;

    after_dml(
      p_action                            => 'INSERT',
      x_person_id                         => x_person_id,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date
     );
    IF g_return_status IS NOT NULL THEN
      x_msg_count  := g_msg_count;
      x_msg_data   := g_msg_data;
      x_return_status := g_return_status;
      fnd_message.set_name ('IGF',g_msg_data);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_clprl_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_relationship_cd             IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_object_version_number             IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 07-SEP-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        relationship_cd,
        start_date,
        end_date,
        object_version_number
      FROM  igf_sl_cl_pref_lenders
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
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.relationship_cd = x_relationship_cd)
        AND (tlinfo.start_date = x_start_date)
        AND ((tlinfo.end_date = x_end_date) OR ((tlinfo.end_date IS NULL) AND (X_end_date IS NULL)))
        AND ((tlinfo.object_version_number = x_object_version_number) OR ((tlinfo.object_version_number IS NULL) AND (X_object_version_number IS NULL)))
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
    x_clprl_id                          IN     NUMBER,
    x_msg_count                            OUT NOCOPY NUMBER,
    x_msg_data                             OUT NOCOPY VARCHAR2,
    x_return_status                        OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_relationship_cd                   IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_object_version_number             IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 07-SEP-2003
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
    g_msg_count  := NULL;
    g_msg_data   := NULL;
    g_return_status := NULL;
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
      fnd_message.set_token ('ROUTINE', 'igf_sl_cl_pref_lenders_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_clprl_id                          => x_clprl_id,
      x_person_id                         => x_person_id,
      x_relationship_cd                   => x_relationship_cd,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_object_version_number             => x_object_version_number,
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

    UPDATE igf_sl_cl_pref_lenders
      SET
        person_id                         = new_references.person_id,
        relationship_cd             = new_references.relationship_cd,
        start_date                        = new_references.start_date,
        end_date                          = new_references.end_date,
        object_version_number             = new_references.object_version_number,
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

    after_dml(
      p_action                            => 'UPDATE',
      x_person_id                         => x_person_id,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date
     );
    IF g_return_status IS NOT NULL THEN
      x_msg_count  := g_msg_count;
      x_msg_data   := g_msg_data;
      x_return_status := g_return_status;
      fnd_message.set_name ('IGF',g_msg_data);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END update_row;





  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 07-SEP-2003
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

    DELETE FROM igf_sl_cl_pref_lenders
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_cl_pref_lenders_pkg;

/
