--------------------------------------------------------
--  DDL for Package Body IGI_EXP_DU_TYPE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_DU_TYPE_DETAILS_PKG" AS
/* $Header: igiexptb.pls 120.5.12000000.1 2007/09/13 04:24:40 mbremkum ship $ */

--following variables added for bug 3199481: fnd logging changes: sdixit
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

  l_rowid VARCHAR2(25);
  old_references igi_exp_du_type_details_all%ROWTYPE;
  new_references igi_exp_du_type_details_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_du_type_detail_id                 IN     NUMBER      ,
    x_du_type_header_id                 IN     NUMBER      ,
    x_transaction_type                  IN     VARCHAR2    ,
    x_org_id                            IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGI_EXP_DU_TYPE_DETAILS_ALL
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
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexptb.IGI_EXP_DU_TYPE_DETAILS_PKG.set_column_values',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.du_type_detail_id                 := x_du_type_detail_id;
    new_references.du_type_header_id                 := x_du_type_header_id;
    new_references.transaction_type                  := x_transaction_type;
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


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-OCT-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.du_type_header_id = new_references.du_type_header_id)) OR
        ((new_references.du_type_header_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_exp_du_type_headers_pkg.get_pk_for_validation (
                new_references.du_type_header_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexptb.IGI_EXP_DU_TYPE_DETAILS_PKG.check_parent_existance',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_du_type_detail_id                 IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-OCT-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_exp_du_type_details_all
      WHERE    du_type_detail_id = x_du_type_detail_id
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


  PROCEDURE get_fk_igi_exp_du_type_headers (
    x_du_type_header_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-OCT-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_exp_du_type_details_all
      WHERE   ((du_type_header_id = x_du_type_header_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND','FND-CANNOT DELETE MASTER');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexptb.IGI_EXP_DU_TYPE_DETAILS_PKG.get_fk_igi_exp_du_type_headers',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_exp_du_type_headers;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_du_type_detail_id                 IN     NUMBER      ,
    x_du_type_header_id                 IN     NUMBER      ,
    x_transaction_type                  IN     VARCHAR2    ,
    x_org_id                            IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-OCT-2001
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
      x_du_type_detail_id,
      x_du_type_header_id,
      x_transaction_type,
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
             new_references.du_type_detail_id
           )
         ) THEN
        fnd_message.set_name('IGI','IGI_EXP_DUP_ROW');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexptb.IGI_EXP_DU_TYPE_DETAILS_PKG.before_dml.msg1',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.du_type_detail_id
           )
         ) THEN
        fnd_message.set_name('IGI','IGI_EXP_DUP_ROW');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexptb.IGI_EXP_DU_TYPE_DETAILS_PKG.before_dml.msg2',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_du_type_detail_id                 IN OUT NOCOPY NUMBER,
    x_du_type_header_id                 IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_exp_du_type_details_all
      WHERE    du_type_detail_id                 = x_du_type_detail_id;

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
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexptb.IGI_EXP_DU_TYPE_DETAILS_PKG.insert_row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
    END IF;

    SELECT    igi_exp_du_type_details_s1.NEXTVAL
    INTO      x_du_type_detail_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_du_type_detail_id                 => x_du_type_detail_id,
      x_du_type_header_id                 => x_du_type_header_id,
      x_transaction_type                  => x_transaction_type,
      x_org_id                            => x_org_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igi_exp_du_type_details_all (
      du_type_detail_id,
      du_type_header_id,
      transaction_type,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.du_type_detail_id,
      new_references.du_type_header_id,
      new_references.transaction_type,
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
    x_du_type_detail_id                 IN     NUMBER,
    x_du_type_header_id                 IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_org_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        du_type_header_id,
        transaction_type,
        org_id
      FROM  igi_exp_du_type_details_all
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexptb.IGI_EXP_DU_TYPE_DETAILS_PKG.lock_row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.du_type_header_id = x_du_type_header_id)
        AND (tlinfo.transaction_type = x_transaction_type)
        AND (tlinfo.org_id = x_org_id)
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexptb.IGI_EXP_DU_TYPE_DETAILS_PKG.lock_row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_du_type_detail_id                 IN     NUMBER,
    x_du_type_header_id                 IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-OCT-2001
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
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexptb.IGI_EXP_DU_TYPE_DETAILS_PKG.update_row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_du_type_detail_id                 => x_du_type_detail_id,
      x_du_type_header_id                 => x_du_type_header_id,
      x_transaction_type                  => x_transaction_type,
      x_org_id                            => x_org_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_exp_du_type_details_all
      SET
        du_type_header_id                 = new_references.du_type_header_id,
        transaction_type                  = new_references.transaction_type,
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
    x_du_type_detail_id                 IN OUT NOCOPY NUMBER,
    x_du_type_header_id                 IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_exp_du_type_details_all
      WHERE    du_type_detail_id                 = x_du_type_detail_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_du_type_detail_id,
        x_du_type_header_id,
        x_transaction_type,
        x_org_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_du_type_detail_id,
      x_du_type_header_id,
      x_transaction_type,
      x_org_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-OCT-2001
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

    DELETE FROM igi_exp_du_type_details_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igi_exp_du_type_details_pkg;

/
