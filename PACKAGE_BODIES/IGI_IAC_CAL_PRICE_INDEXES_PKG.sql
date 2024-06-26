--------------------------------------------------------
--  DDL for Package Body IGI_IAC_CAL_PRICE_INDEXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_CAL_PRICE_INDEXES_PKG" AS
/* $Header: igiicpib.pls 120.3.12000000.1 2007/08/01 16:20:37 npandya ship $ */

  l_rowid VARCHAR2(25);
  old_references igi_iac_cal_price_indexes%ROWTYPE;
  new_references igi_iac_cal_price_indexes%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2   ,
    x_cal_price_index_link_id           IN     NUMBER     ,
    x_price_index_id                    IN     NUMBER     ,
    x_calendar_type                     IN     VARCHAR2   ,
    x_previous_rebase_period_name       IN     VARCHAR2   ,
    x_previous_rebase_date              IN     DATE       ,
    x_previous_rebase_index_before      IN     NUMBER     ,
    x_previous_rebase_index_after       IN     NUMBER     ,
    x_creation_date                     IN     DATE       ,
    x_created_by                        IN     NUMBER     ,
    x_last_update_date                  IN     DATE       ,
    x_last_updated_by                   IN     NUMBER     ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 12-APR-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igi_iac_cal_price_indexes
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
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.cal_price_index_link_id           := x_cal_price_index_link_id;
    new_references.price_index_id                    := x_price_index_id;
    new_references.calendar_type                     := x_calendar_type;
    new_references.previous_rebase_period_name       := x_previous_rebase_period_name;
    new_references.previous_rebase_date              := x_previous_rebase_date;
    new_references.previous_rebase_index_before      := x_previous_rebase_index_before;
    new_references.previous_rebase_index_after       := x_previous_rebase_index_after;

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
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 12-APR-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.price_index_id = new_references.price_index_id)) OR
        ((new_references.price_index_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_iac_price_indexes_pkg.get_pk_for_validation (
                new_references.price_index_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 12-APR-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igi_iac_cal_idx_values_pkg.get_fk_igi_iac_cal_price_idx (
      old_references.cal_price_index_link_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_cal_price_index_link_id           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 12-APR-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_iac_cal_price_indexes
      WHERE    cal_price_index_link_id = x_cal_price_index_link_id
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


  PROCEDURE get_fk_igi_iac_price_indexes (
    x_price_index_id                    IN     NUMBER
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 12-APR-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_iac_cal_price_indexes
      WHERE   ((price_index_id = x_price_index_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND', 'FND-CANNOT DELETE MASTER');
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_iac_price_indexes;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2   ,
    x_cal_price_index_link_id           IN     NUMBER     ,
    x_price_index_id                    IN     NUMBER     ,
    x_calendar_type                     IN     VARCHAR2   ,
    x_previous_rebase_period_name       IN     VARCHAR2   ,
    x_previous_rebase_date              IN     DATE       ,
    x_previous_rebase_index_before      IN     NUMBER     ,
    x_previous_rebase_index_after       IN     NUMBER     ,
    x_creation_date                     IN     DATE       ,
    x_created_by                        IN     NUMBER     ,
    x_last_update_date                  IN     DATE       ,
    x_last_updated_by                   IN     NUMBER     ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 12-APR-2002
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
      x_cal_price_index_link_id,
      x_price_index_id,
      x_calendar_type,
      x_previous_rebase_period_name,
      x_previous_rebase_date,
      x_previous_rebase_index_before,
      x_previous_rebase_index_after,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.cal_price_index_link_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.cal_price_index_link_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cal_price_index_link_id           IN OUT NOCOPY NUMBER,
    x_price_index_id                    IN     NUMBER,
    x_calendar_type                     IN     VARCHAR2,
    x_previous_rebase_period_name       IN     VARCHAR2,
    x_previous_rebase_date              IN     DATE,
    x_previous_rebase_index_before      IN     NUMBER,
    x_previous_rebase_index_after       IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 12-APR-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_iac_cal_price_indexes
      WHERE    cal_price_index_link_id           = x_cal_price_index_link_id;

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
      app_exception.raise_exception;
    END IF;

    SELECT    igi_iac_cal_price_indexes_s.NEXTVAL
    INTO      x_cal_price_index_link_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_cal_price_index_link_id           => x_cal_price_index_link_id,
      x_price_index_id                    => x_price_index_id,
      x_calendar_type                     => x_calendar_type,
      x_previous_rebase_period_name       => x_previous_rebase_period_name,
      x_previous_rebase_date              => x_previous_rebase_date,
      x_previous_rebase_index_before      => x_previous_rebase_index_before,
      x_previous_rebase_index_after       => x_previous_rebase_index_after,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igi_iac_cal_price_indexes (
      cal_price_index_link_id,
      price_index_id,
      calendar_type,
      previous_rebase_period_name,
      previous_rebase_date,
      previous_rebase_index_before,
      previous_rebase_index_after,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.cal_price_index_link_id,
      new_references.price_index_id,
      new_references.calendar_type,
      new_references.previous_rebase_period_name,
      new_references.previous_rebase_date,
      new_references.previous_rebase_index_before,
      new_references.previous_rebase_index_after,
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
    x_cal_price_index_link_id           IN     NUMBER,
    x_price_index_id                    IN     NUMBER,
    x_calendar_type                     IN     VARCHAR2,
    x_previous_rebase_period_name       IN     VARCHAR2,
    x_previous_rebase_date              IN     DATE,
    x_previous_rebase_index_before      IN     NUMBER,
    x_previous_rebase_index_after       IN     NUMBER
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 12-APR-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        price_index_id,
        calendar_type,
        previous_rebase_period_name,
        previous_rebase_date,
        previous_rebase_index_before,
        previous_rebase_index_after
      FROM  igi_iac_cal_price_indexes
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.price_index_id = x_price_index_id)
        AND (tlinfo.calendar_type = x_calendar_type)
        AND ((tlinfo.previous_rebase_period_name = x_previous_rebase_period_name) OR ((tlinfo.previous_rebase_period_name IS NULL) AND (X_previous_rebase_period_name IS NULL)))
        AND ((tlinfo.previous_rebase_date = x_previous_rebase_date) OR ((tlinfo.previous_rebase_date IS NULL) AND (X_previous_rebase_date IS NULL)))
        AND ((tlinfo.previous_rebase_index_before = x_previous_rebase_index_before) OR ((tlinfo.previous_rebase_index_before IS NULL) AND (X_previous_rebase_index_before IS NULL)))
        AND ((tlinfo.previous_rebase_index_after = x_previous_rebase_index_after) OR ((tlinfo.previous_rebase_index_after IS NULL) AND (X_previous_rebase_index_after IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_cal_price_index_link_id           IN     NUMBER,
    x_price_index_id                    IN     NUMBER,
    x_calendar_type                     IN     VARCHAR2,
    x_previous_rebase_period_name       IN     VARCHAR2,
    x_previous_rebase_date              IN     DATE,
    x_previous_rebase_index_before      IN     NUMBER,
    x_previous_rebase_index_after       IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 12-APR-2002
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
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_cal_price_index_link_id           => x_cal_price_index_link_id,
      x_price_index_id                    => x_price_index_id,
      x_calendar_type                     => x_calendar_type,
      x_previous_rebase_period_name       => x_previous_rebase_period_name,
      x_previous_rebase_date              => x_previous_rebase_date,
      x_previous_rebase_index_before      => x_previous_rebase_index_before,
      x_previous_rebase_index_after       => x_previous_rebase_index_after,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_iac_cal_price_indexes
      SET
        price_index_id                    = new_references.price_index_id,
        calendar_type                     = new_references.calendar_type,
        previous_rebase_period_name       = new_references.previous_rebase_period_name,
        previous_rebase_date              = new_references.previous_rebase_date,
        previous_rebase_index_before      = new_references.previous_rebase_index_before,
        previous_rebase_index_after       = new_references.previous_rebase_index_after,
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
    x_cal_price_index_link_id           IN OUT NOCOPY NUMBER,
    x_price_index_id                    IN     NUMBER,
    x_calendar_type                     IN     VARCHAR2,
    x_previous_rebase_period_name       IN     VARCHAR2,
    x_previous_rebase_date              IN     DATE,
    x_previous_rebase_index_before      IN     NUMBER,
    x_previous_rebase_index_after       IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 12-APR-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_iac_cal_price_indexes
      WHERE    cal_price_index_link_id           = x_cal_price_index_link_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_cal_price_index_link_id,
        x_price_index_id,
        x_calendar_type,
        x_previous_rebase_period_name,
        x_previous_rebase_date,
        x_previous_rebase_index_before,
        x_previous_rebase_index_after,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_cal_price_index_link_id,
      x_price_index_id,
      x_calendar_type,
      x_previous_rebase_period_name,
      x_previous_rebase_date,
      x_previous_rebase_index_before,
      x_previous_rebase_index_after,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 12-APR-2002
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

    DELETE FROM igi_iac_cal_price_indexes
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igi_iac_cal_price_indexes_pkg;

/
