--------------------------------------------------------
--  DDL for Package Body IGI_IAC_PROJECTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_PROJECTIONS_PKG" AS
/* $Header: igiiapjb.pls 120.4.12000000.1 2007/08/01 16:15:56 npandya ship $ */

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiapjb.igi_iac_projections_pkg.';

--===========================FND_LOG.END=======================================

  l_rowid VARCHAR2(25);
  old_references igi_iac_projections%ROWTYPE;
  new_references igi_iac_projections%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2   ,
    x_projection_id                     IN     NUMBER      ,
    x_book_type_code                    IN     VARCHAR2    ,
    x_start_period_counter              IN     NUMBER      ,
    x_end_period                        IN     NUMBER      ,
    x_category_id                       IN     NUMBER      ,
    x_revaluation_period                IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igi_iac_projections
      WHERE    rowid = x_rowid;
    l_path 	varchar2(150) := g_path||'set_column_values';
  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.projection_id                     := x_projection_id;
    new_references.book_type_code                    := x_book_type_code;
    new_references.start_period_counter              := x_start_period_counter;
    new_references.end_period                        := x_end_period;
    new_references.category_id                       := x_category_id;
    new_references.revaluation_period                := x_revaluation_period;

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


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igi_iac_proj_details_pkg.get_fk_igi_iac_projections (
      old_references.projection_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_projection_id                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_iac_projections
      WHERE    projection_id = x_projection_id
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
    x_projection_id                     IN     NUMBER      ,
    x_book_type_code                    IN     VARCHAR2    ,
    x_start_period_counter              IN     NUMBER      ,
    x_end_period                        IN     NUMBER      ,
    x_category_id                       IN     NUMBER      ,
    x_revaluation_period                IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    l_path 	varchar2(150) := g_path||'before_dml';
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_projection_id,
      x_book_type_code,
      x_start_period_counter,
      x_end_period,
      x_category_id,
      x_revaluation_period,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.projection_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
        igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.projection_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
        igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_projection_id                     IN OUT NOCOPY NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_start_period_counter              IN     NUMBER,
    x_end_period                        IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_revaluation_period                IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_iac_projections
      WHERE    projection_id                     = x_projection_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_path 	varchar2(150) := g_path||'insert_row';
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
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
    END IF;

    SELECT    igi_iac_projections_s.NEXTVAL
    INTO      x_projection_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_projection_id                     => x_projection_id,
      x_book_type_code                    => x_book_type_code,
      x_start_period_counter              => x_start_period_counter,
      x_end_period                        => x_end_period,
      x_category_id                       => x_category_id,
      x_revaluation_period                => x_revaluation_period,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igi_iac_projections (
      projection_id,
      book_type_code,
      start_period_counter,
      end_period,
      category_id,
      revaluation_period,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.projection_id,
      new_references.book_type_code,
      new_references.start_period_counter,
      new_references.end_period,
      new_references.category_id,
      new_references.revaluation_period,
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
    x_projection_id                     IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_start_period_counter              IN     NUMBER,
    x_end_period                        IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_revaluation_period                IN     NUMBER
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        book_type_code,
        start_period_counter,
        end_period,
        category_id,
        revaluation_period
      FROM  igi_iac_projections
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;
    l_path 	varchar2(150) := g_path||'lock_row';
  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.book_type_code = x_book_type_code)
        AND (tlinfo.start_period_counter = x_start_period_counter)
        AND (tlinfo.end_period = x_end_period)
        AND (tlinfo.category_id = x_category_id)
        AND (tlinfo.revaluation_period = x_revaluation_period)
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_projection_id                     IN     NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_start_period_counter              IN     NUMBER,
    x_end_period                        IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_revaluation_period                IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_path 	varchar2(150) := g_path||'update_row';
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
      igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_projection_id                     => x_projection_id,
      x_book_type_code                    => x_book_type_code,
      x_start_period_counter              => x_start_period_counter,
      x_end_period                        => x_end_period,
      x_category_id                       => x_category_id,
      x_revaluation_period                => x_revaluation_period,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_iac_projections
      SET
        book_type_code                    = new_references.book_type_code,
        start_period_counter              = new_references.start_period_counter,
        end_period                        = new_references.end_period,
        category_id                       = new_references.category_id,
        revaluation_period                = new_references.revaluation_period,
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
    x_projection_id                     IN OUT NOCOPY NUMBER,
    x_book_type_code                    IN     VARCHAR2,
    x_start_period_counter              IN     NUMBER,
    x_end_period                        IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_revaluation_period                IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_iac_projections
      WHERE    projection_id                     = x_projection_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_projection_id,
        x_book_type_code,
        x_start_period_counter,
        x_end_period,
        x_category_id,
        x_revaluation_period,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_projection_id,
      x_book_type_code,
      x_start_period_counter,
      x_end_period,
      x_category_id,
      x_revaluation_period,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra@oracle.com
  ||  Created On : 30-MAY-2002
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

    DELETE FROM igi_iac_projections
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igi_iac_projections_pkg;

/
