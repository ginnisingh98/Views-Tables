--------------------------------------------------------
--  DDL for Package Body IGS_UC_CRSE_VAC_OPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_CRSE_VAC_OPS_PKG" AS
/* $Header: IGSXI16B.pls 115.9 2003/06/11 10:17:18 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_crse_vac_ops%ROWTYPE;
  new_references igs_uc_crse_vac_ops%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_ucas_program_code                 IN     VARCHAR2     ,
    x_institute                         IN     VARCHAR2     ,
    x_ucas_campus                       IN     VARCHAR2     ,
    x_option_code                       IN     VARCHAR2     ,
    x_updater                           IN     VARCHAR2     ,
    x_cl_updated                        IN     VARCHAR2     ,
    x_cl_date                           IN     DATE         ,
    x_vacancy_status                    IN     VARCHAR2     ,
    x_sent_to_ucas                      IN     VARCHAR2     ,
     x_system_code                       IN     VARCHAR2  ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_CRSE_VAC_OPS
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
    new_references.ucas_program_code                 := x_ucas_program_code;
    new_references.institute                         := x_institute;
    new_references.ucas_campus                       := x_ucas_campus;
    new_references.option_code                       := x_option_code;
    new_references.updater                           := x_updater;
    new_references.cl_updated                        := x_cl_updated;
    new_references.cl_date                           := x_cl_date;
    new_references.vacancy_status                    := x_vacancy_status;
    new_references.sent_to_ucas                      := x_sent_to_ucas;
    new_references.system_code                      := x_system_code;

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
  ||  Created By : rgopalan
  ||  Created On : 23-OCT-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.ucas_program_code = new_references.ucas_program_code) AND
         (old_references.institute = new_references.institute) AND
         (old_references.ucas_campus = new_references.ucas_campus)) OR
        ((new_references.ucas_program_code IS NULL) OR
         (new_references.institute IS NULL) OR
         (new_references.ucas_campus IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_crse_dets_pkg.get_pk_for_validation (
                new_references.ucas_program_code,
                new_references.institute,
                new_references.ucas_campus,
                new_references.system_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_option_code                       IN     VARCHAR2 ,
    x_system_code                       IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-OCT-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_crse_vac_ops
      WHERE    ucas_program_code = x_ucas_program_code
      AND      institute = x_institute
      AND      ucas_campus = x_ucas_campus
      AND      option_code = x_option_code
      AND      system_code = x_system_code;

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


  PROCEDURE get_fk_igs_uc_crse_dets (
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2   ,
    x_system_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-OCT-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_crse_vac_ops
      WHERE   ((institute = x_institute) AND
               (ucas_campus = x_ucas_campus) AND
               (ucas_program_code = x_ucas_program_code)AND
               (system_code = x_system_code));
    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCCSVO_UCCSDE_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_crse_dets;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_ucas_program_code                 IN     VARCHAR2     ,
    x_institute                         IN     VARCHAR2     ,
    x_ucas_campus                       IN     VARCHAR2     ,
    x_option_code                       IN     VARCHAR2     ,
    x_updater                           IN     VARCHAR2     ,
    x_cl_updated                        IN     VARCHAR2     ,
    x_cl_date                           IN     DATE         ,
    x_vacancy_status                    IN     VARCHAR2     ,
    x_sent_to_ucas                      IN     VARCHAR2     ,
     x_system_code                       IN     VARCHAR2  ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-OCT-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_ucas_program_code,
      x_institute,
      x_ucas_campus,
      x_option_code,
      x_updater,
      x_cl_updated,
      x_cl_date,
      x_vacancy_status,
      x_sent_to_ucas,
       x_system_code    ,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ucas_program_code,
             new_references.institute,
             new_references.ucas_campus,
             new_references.option_code             ,
             new_references.system_code
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
             new_references.ucas_program_code,
             new_references.institute,
             new_references.ucas_campus,
             new_references.option_code,
             new_references.system_code
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
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_option_code                       IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_cl_updated                        IN     VARCHAR2,
    x_cl_date                           IN     DATE,
    x_vacancy_status                    IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
     x_system_code                       IN     VARCHAR2  ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_crse_vac_ops
      WHERE    ucas_program_code                 = x_ucas_program_code
      AND      institute                         = x_institute
      AND      ucas_campus                       = x_ucas_campus
      AND      option_code                       = x_option_code;

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
      x_ucas_program_code                 => x_ucas_program_code,
      x_institute                         => x_institute,
      x_ucas_campus                       => x_ucas_campus,
      x_option_code                       => x_option_code,
      x_updater                           => x_updater,
      x_cl_updated                        => x_cl_updated,
      x_cl_date                           => x_cl_date,
      x_vacancy_status                    => x_vacancy_status,
      x_sent_to_ucas                      => x_sent_to_ucas,
       x_system_code                       => x_system_code   ,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_crse_vac_ops (
      ucas_program_code,
      institute,
      ucas_campus,
      option_code,
      updater,
      cl_updated,
      cl_date,
      vacancy_status,
      sent_to_ucas,
      system_code,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.ucas_program_code,
      new_references.institute,
      new_references.ucas_campus,
      new_references.option_code,
      new_references.updater,
      new_references.cl_updated,
      new_references.cl_date,
      new_references.vacancy_status,
      new_references.sent_to_ucas,
      new_references.system_code,
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
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_option_code                       IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_cl_updated                        IN     VARCHAR2,
    x_cl_date                           IN     DATE,
    x_vacancy_status                    IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        updater,
        cl_updated,
        cl_date,
        vacancy_status,
        sent_to_ucas,
        system_code
      FROM  igs_uc_crse_vac_ops
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
        (tlinfo.updater = x_updater)
        AND ((tlinfo.cl_updated = x_cl_updated) OR ((tlinfo.cl_updated IS NULL) AND (X_cl_updated IS NULL)))
        AND ((tlinfo.cl_date = x_cl_date) OR ((tlinfo.cl_date IS NULL) AND (X_cl_date IS NULL)))
        AND ((tlinfo.vacancy_status = x_vacancy_status) OR ((tlinfo.vacancy_status IS NULL) AND (X_vacancy_status IS NULL)))
        AND (tlinfo.sent_to_ucas = x_sent_to_ucas)
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
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_option_code                       IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_cl_updated                        IN     VARCHAR2,
    x_cl_date                           IN     DATE,
    x_vacancy_status                    IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2  ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-OCT-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
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
      x_ucas_program_code                 => x_ucas_program_code,
      x_institute                         => x_institute,
      x_ucas_campus                       => x_ucas_campus,
      x_option_code                       => x_option_code,
      x_updater                           => x_updater,
      x_cl_updated                        => x_cl_updated,
      x_cl_date                           => x_cl_date,
      x_vacancy_status                    => x_vacancy_status,
      x_sent_to_ucas                      => x_sent_to_ucas,
      x_system_code                        => x_system_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_crse_vac_ops
      SET
        updater                           = new_references.updater,
        cl_updated                        = new_references.cl_updated,
        cl_date                           = new_references.cl_date,
        vacancy_status                    = new_references.vacancy_status,
        sent_to_ucas                      = new_references.sent_to_ucas,
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
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_option_code                       IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_cl_updated                        IN     VARCHAR2,
    x_cl_date                           IN     DATE,
    x_vacancy_status                    IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  Obsoleting datetimestamp column for ucfd203 -multiple cycled build ,bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_crse_vac_ops
      WHERE    ucas_program_code                 = x_ucas_program_code
      AND      institute                         = x_institute
      AND      ucas_campus                       = x_ucas_campus
      AND      option_code                       = x_option_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ucas_program_code,
        x_institute,
        x_ucas_campus,
        x_option_code,
        x_updater,
        x_cl_updated,
        x_cl_date,
        x_vacancy_status,
        x_sent_to_ucas,
         x_system_code,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ucas_program_code,
      x_institute,
      x_ucas_campus,
      x_option_code,
      x_updater,
      x_cl_updated,
      x_cl_date,
      x_vacancy_status,
      x_sent_to_ucas,
       x_system_code  ,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-OCT-2001
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

    DELETE FROM igs_uc_crse_vac_ops
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_crse_vac_ops_pkg;

/
