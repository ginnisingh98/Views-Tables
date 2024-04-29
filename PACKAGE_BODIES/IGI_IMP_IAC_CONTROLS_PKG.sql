--------------------------------------------------------
--  DDL for Package Body IGI_IMP_IAC_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IMP_IAC_CONTROLS_PKG" AS
/* $Header: igiimicb.pls 120.5.12000000.1 2007/08/01 16:21:12 npandya ship $ */

  l_rowid VARCHAR2(25);
  old_references igi_imp_iac_controls%ROWTYPE;
  new_references igi_imp_iac_controls%ROWTYPE;

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiimicb.igi_imp_iac_controls_pkg.';

--===========================FND_LOG.END=====================================

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_book_type_code                    IN     VARCHAR2    ,
    x_corp_book                         IN     VARCHAR2    ,
    x_period_counter                    IN     NUMBER      ,
    x_request_status                    IN     VARCHAR2    ,
    x_request_id                            IN     NUMBER  ,
    x_request_date                      IN     DATE        ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ) AS
  /*
  ||  Created By : sowsubra
  ||  Created On : 27-JUN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    l_path_name VARCHAR2(150) := g_path||'set_column_values';

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igi_imp_iac_controls
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
      igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		      p_full_path => l_path_name,
		      p_remove_from_stack => FALSE);
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.book_type_code                    := x_book_type_code;
    new_references.corp_book                         := x_corp_book;
    new_references.period_counter                    := x_period_counter;
    new_references.request_status                    := x_request_status;
    new_references.request_id                        := x_request_id;
    new_references.request_date                      := x_request_date;

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
    x_book_type_code                    IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sowsubra
  ||  Created On : 27-JUN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_imp_iac_controls
      WHERE    book_type_code = x_book_type_code
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
    x_book_type_code                    IN     VARCHAR2    ,
    x_corp_book                         IN     VARCHAR2    ,
    x_period_counter                    IN     NUMBER      ,
    x_request_status                    IN     VARCHAR2    ,
    x_request_id                        IN     NUMBER      ,
    x_request_date                      IN     DATE        ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ) AS
  /*
  ||  Created By : sowsubra
  ||  Created On : 27-JUN-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  l_path_name VARCHAR2(150) := g_path||'before_dml';
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_book_type_code,
      x_corp_book,
      x_period_counter,
      x_request_status,
      x_request_id,
      x_request_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.book_type_code
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
        igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		       p_full_path => l_path_name,
		       p_remove_from_stack => FALSE);
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.book_type_code
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
        igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		       p_full_path => l_path_name,
		       p_remove_from_stack => FALSE);
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_book_type_code                    IN OUT NOCOPY VARCHAR2,
    x_corp_book                         IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_request_status                    IN     VARCHAR2,
    x_request_id                        IN     NUMBER,
    x_request_date                      IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra
  ||  Created On : 27-JUN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR c IS
      SELECT   rowid
      FROM     igi_imp_iac_controls
      WHERE    book_type_code                    = x_book_type_code;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_path_name VARCHAR2(150) := g_path||'insert_row';

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
      igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		       p_full_path => l_path_name,
		       p_remove_from_stack => FALSE);
      app_exception.raise_exception;
    END IF;

   /* SELECT    igi_imp_iac_controls_s.NEXTVAL
    INTO      x_book_type_code
    FROM      dual;*/

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_book_type_code                    => x_book_type_code,
      x_corp_book                         => x_corp_book,
      x_period_counter                    => x_period_counter,
      x_request_status                    => x_request_status,
      x_request_id                        => x_request_id,
      x_request_date                      => x_request_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );


    INSERT INTO igi_imp_iac_controls (
      book_type_code,
      corp_book,
      period_counter,
      request_status,
      request_id,
      request_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.book_type_code,
      new_references.corp_book,
      new_references.period_counter,
      new_references.request_status,
      new_references.request_id,
      new_references.request_date,
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
    x_book_type_code                    IN     VARCHAR2,
    x_corp_book                         IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_request_status                    IN     VARCHAR2,
    x_request_id                        IN     NUMBER,
    x_request_date                      IN     DATE
  ) AS
  /*
  ||  Created By : sowsubra
  ||  Created On : 27-JUN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        corp_book,
        period_counter,
        request_status,
        request_id,
        request_date
      FROM  igi_imp_iac_controls
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;
    l_path_name VARCHAR2(150) := g_path||'lock_row';

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      CLOSE c1;
      igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		      p_full_path => l_path_name,
		      p_remove_from_stack => FALSE);
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.corp_book = x_corp_book)
        AND (tlinfo.period_counter = x_period_counter)
        AND (tlinfo.request_status = x_request_status)
        AND ((tlinfo.request_id = x_request_id) OR ((tlinfo.request_id IS NULL) AND (X_request_id IS NULL)))
        AND ((tlinfo.request_date = x_request_date) OR ((tlinfo.request_date IS NULL) AND (X_request_date IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		      p_full_path => l_path_name,
		      p_remove_from_stack => FALSE);
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_book_type_code                    IN     VARCHAR2,
    x_corp_book                         IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_request_status                    IN     VARCHAR2,
    x_request_id                            IN     NUMBER,
    x_request_date                      IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra
  ||  Created On : 27-JUN-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_path_name VARCHAR2(150) := g_path||'update_row';

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
      igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		      p_full_path => l_path_name,
		      p_remove_from_stack => FALSE);
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_book_type_code                    => x_book_type_code,
      x_corp_book                         => x_corp_book,
      x_period_counter                    => x_period_counter,
      x_request_status                    => x_request_status,
      x_request_id                            => x_request_id,
      x_request_date                      => x_request_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_imp_iac_controls
      SET
        corp_book                         = new_references.corp_book,
        period_counter                    = new_references.period_counter,
        request_status                    = new_references.request_status,
        request_id                            = new_references.request_id,
        request_date                      = new_references.request_date,
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
    x_book_type_code                    IN OUT NOCOPY VARCHAR2,
    x_corp_book                         IN     VARCHAR2,
    x_period_counter                    IN     NUMBER,
    x_request_status                    IN     VARCHAR2,
    x_request_id                            IN     NUMBER,
    x_request_date                      IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra
  ||  Created On : 27-JUN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_imp_iac_controls
      WHERE    book_type_code                    = x_book_type_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_book_type_code,
        x_corp_book,
        x_period_counter,
        x_request_status,
        x_request_id,
        x_request_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_book_type_code,
      x_corp_book,
      x_period_counter,
      x_request_status,
      x_request_id,
      x_request_date,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sowsubra
  ||  Created On : 27-JUN-2002
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

    DELETE FROM igi_imp_iac_controls
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igi_imp_iac_controls_pkg;

/
