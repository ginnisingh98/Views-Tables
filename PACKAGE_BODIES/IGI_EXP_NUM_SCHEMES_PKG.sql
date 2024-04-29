--------------------------------------------------------
--  DDL for Package Body IGI_EXP_NUM_SCHEMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_NUM_SCHEMES_PKG" AS
/* $Header: igiexcb.pls 120.4.12000000.1 2007/09/13 04:24:05 mbremkum ship $ */

  l_rowid VARCHAR2(25);
  old_references igi_exp_num_schemes_all%ROWTYPE;
  new_references igi_exp_num_schemes_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_num_scheme_id                     IN     NUMBER      ,
    x_numbering_type                    IN     VARCHAR2    ,
    x_numbering_class                   IN     VARCHAR2    ,
    x_du_tu_type_id                     IN     VARCHAR2    ,
    x_prefix                            IN     VARCHAR2    ,
    x_suffix                            IN     VARCHAR2    ,
    x_fiscal_year                       IN     VARCHAR2    ,
    x_next_seq_val                      IN     VARCHAR2    ,
    x_org_id                            IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ) AS
  /*
  ||  Created By :
  ||  Created On : 27-SEP-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGI_EXP_NUM_SCHEMES_ALL
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
    new_references.num_scheme_id                     := x_num_scheme_id;
    new_references.numbering_type                    := x_numbering_type;
    new_references.numbering_class                   := x_numbering_class;
    new_references.du_tu_type_id                     := x_du_tu_type_id;
    new_references.prefix                            := x_prefix;
    new_references.suffix                            := x_suffix;
    new_references.fiscal_year                       := x_fiscal_year;
    new_references.next_seq_val                      := x_next_seq_val;
    new_references.org_id                            := x_org_id;

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
    x_num_scheme_id                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 27-SEP-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_exp_num_schemes_all
      WHERE    num_scheme_id = x_num_scheme_id
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
    x_rowid                             IN     VARCHAR2    ,
    x_num_scheme_id                     IN     NUMBER      ,
    x_numbering_type                    IN     VARCHAR2    ,
    x_numbering_class                   IN     VARCHAR2    ,
    x_du_tu_type_id                     IN     VARCHAR2    ,
    x_prefix                            IN     VARCHAR2    ,
    x_suffix                            IN     VARCHAR2    ,
    x_fiscal_year                       IN     VARCHAR2    ,
    x_next_seq_val                      IN     VARCHAR2    ,
    x_org_id                            IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ) AS
  /*
  ||  Created By :
  ||  Created On : 27-SEP-2001
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
      x_num_scheme_id,
      x_numbering_type,
      x_numbering_class,
      x_du_tu_type_id,
      x_prefix,
      x_suffix,
      x_fiscal_year,
      x_next_seq_val,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.num_scheme_id
           )
         ) THEN
        fnd_message.set_name('IGI','IGI_EXP_DUP_ROW');

        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.num_scheme_id
           )
         ) THEN
        fnd_message.set_name('IGI','IGI_EXP_DUP_ROW');

        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_num_scheme_id                     IN OUT NOCOPY NUMBER,
    x_numbering_type                    IN     VARCHAR2,
    x_numbering_class                   IN     VARCHAR2,
    x_du_tu_type_id                     IN     VARCHAR2,
    x_prefix                            IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_fiscal_year                       IN     VARCHAR2,
    x_next_seq_val                      IN     VARCHAR2,
    x_org_id                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By :
  ||  Created On : 27-SEP-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_exp_num_schemes_all
      WHERE    num_scheme_id                     = x_num_scheme_id;

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

    SELECT    igi_exp_num_schemes_s1.NEXTVAL
    INTO      x_num_scheme_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_num_scheme_id                     => x_num_scheme_id,
      x_numbering_type                    => x_numbering_type,
      x_numbering_class                   => x_numbering_class,
      x_du_tu_type_id                     => x_du_tu_type_id,
      x_prefix                            => x_prefix,
      x_suffix                            => x_suffix,
      x_fiscal_year                       => x_fiscal_year,
      x_next_seq_val                      => x_next_seq_val,
      x_org_id                            => x_org_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igi_exp_num_schemes_all (
      num_scheme_id,
      numbering_type,
      numbering_class,
      du_tu_type_id,
      prefix,
      suffix,
      fiscal_year,
      next_seq_val,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.num_scheme_id,
      new_references.numbering_type,
      new_references.numbering_class,
      new_references.du_tu_type_id,
      new_references.prefix,
      new_references.suffix,
      new_references.fiscal_year,
      new_references.next_seq_val,
      new_references.org_id,
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
    x_num_scheme_id                     IN     NUMBER,
    x_numbering_type                    IN     VARCHAR2,
    x_numbering_class                   IN     VARCHAR2,
    x_du_tu_type_id                     IN     VARCHAR2,
    x_prefix                            IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_fiscal_year                       IN     VARCHAR2,
    x_next_seq_val                      IN     VARCHAR2,
    x_org_id                            IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-SEP-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        numbering_type,
        numbering_class,
        du_tu_type_id,
        prefix,
        suffix,
        fiscal_year,
        next_seq_val,
        org_id
      FROM  igi_exp_num_schemes_all
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
        ((tlinfo.numbering_type = x_numbering_type) OR ((tlinfo.numbering_type IS NULL) AND (X_numbering_type IS NULL)))
        AND ((tlinfo.numbering_class = x_numbering_class) OR ((tlinfo.numbering_class IS NULL) AND (X_numbering_class IS NULL)))
        AND ((tlinfo.du_tu_type_id = x_du_tu_type_id) OR ((tlinfo.du_tu_type_id IS NULL) AND (X_du_tu_type_id IS NULL)))
        AND ((tlinfo.prefix = x_prefix) OR ((tlinfo.prefix IS NULL) AND (X_prefix IS NULL)))
        AND ((tlinfo.suffix = x_suffix) OR ((tlinfo.suffix IS NULL) AND (X_suffix IS NULL)))
        AND ((tlinfo.fiscal_year = x_fiscal_year) OR ((tlinfo.fiscal_year IS NULL) AND (X_fiscal_year IS NULL)))
        AND ((tlinfo.next_seq_val = x_next_seq_val) OR ((tlinfo.next_seq_val IS NULL) AND (X_next_seq_val IS NULL)))
        AND ((tlinfo.org_id = x_org_id) OR ((tlinfo.org_id IS NULL) AND (X_org_id IS NULL)))
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
    x_num_scheme_id                     IN     NUMBER,
    x_numbering_type                    IN     VARCHAR2,
    x_numbering_class                   IN     VARCHAR2,
    x_du_tu_type_id                     IN     VARCHAR2,
    x_prefix                            IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_fiscal_year                       IN     VARCHAR2,
    x_next_seq_val                      IN     VARCHAR2,
    x_org_id                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By :
  ||  Created On : 27-SEP-2001
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
      x_num_scheme_id                     => x_num_scheme_id,
      x_numbering_type                    => x_numbering_type,
      x_numbering_class                   => x_numbering_class,
      x_du_tu_type_id                     => x_du_tu_type_id,
      x_prefix                            => x_prefix,
      x_suffix                            => x_suffix,
      x_fiscal_year                       => x_fiscal_year,
      x_next_seq_val                      => x_next_seq_val,
      x_org_id                            => x_org_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_exp_num_schemes_all
      SET
        numbering_type                    = new_references.numbering_type,
        numbering_class                   = new_references.numbering_class,
        du_tu_type_id                     = new_references.du_tu_type_id,
        prefix                            = new_references.prefix,
        suffix                            = new_references.suffix,
        fiscal_year                       = new_references.fiscal_year,
        next_seq_val                      = new_references.next_seq_val,
        org_id                            = new_references.org_id,
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
    x_num_scheme_id                     IN OUT NOCOPY NUMBER,
    x_numbering_type                    IN     VARCHAR2,
    x_numbering_class                   IN     VARCHAR2,
    x_du_tu_type_id                     IN     VARCHAR2,
    x_prefix                            IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_fiscal_year                       IN     VARCHAR2,
    x_next_seq_val                      IN     VARCHAR2,
    x_org_id                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By :
  ||  Created On : 27-SEP-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_exp_num_schemes_all
      WHERE    num_scheme_id                     = x_num_scheme_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_num_scheme_id,
        x_numbering_type,
        x_numbering_class,
        x_du_tu_type_id,
        x_prefix,
        x_suffix,
        x_fiscal_year,
        x_next_seq_val,
        x_org_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_num_scheme_id,
      x_numbering_type,
      x_numbering_class,
      x_du_tu_type_id,
      x_prefix,
      x_suffix,
      x_fiscal_year,
      x_next_seq_val,
      x_org_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-SEP-2001
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

    DELETE FROM igi_exp_num_schemes_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igi_exp_num_schemes_pkg;

/
