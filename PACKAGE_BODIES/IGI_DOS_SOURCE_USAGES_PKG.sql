--------------------------------------------------------
--  DDL for Package Body IGI_DOS_SOURCE_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DOS_SOURCE_USAGES_PKG" AS
/* $Header: igidospb.pls 120.5.12000000.2 2007/06/14 05:01:41 pshivara ship $ */

l_debug_level   number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;

l_state_level   number := FND_LOG.LEVEL_STATEMENT ;
l_proc_level    number := FND_LOG.LEVEL_PROCEDURE ;
l_event_level   number := FND_LOG.LEVEL_EVENT ;
l_excep_level   number := FND_LOG.LEVEL_EXCEPTION ;
l_error_level   number := FND_LOG.LEVEL_ERROR ;
l_unexp_level   number := FND_LOG.LEVEL_UNEXPECTED ;

  l_rowid VARCHAR2(25);
  old_references igi_dos_source_usages%ROWTYPE;
  new_references igi_dos_source_usages%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_source_id                         IN     NUMBER       ,
    x_segment_name                      IN     VARCHAR2     ,
    x_segment_name_dsp                  IN     VARCHAR2     ,
    x_sob_id                            IN     NUMBER       ,
    x_coa_id                            IN     NUMBER       ,
    x_visibility                        IN     VARCHAR2     ,
    x_default_type                      IN     VARCHAR2     ,
    x_default_value                     IN     VARCHAR2     ,
    x_updatable                         IN     VARCHAR2     ,
    x_stored_name                       IN     VARCHAR2     ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igi_dos_source_usages
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
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_source_usages_pkg.set_column_values.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.source_id                         := x_source_id;
    new_references.segment_name                      := x_segment_name;
    new_references.segment_name_dsp                  := x_segment_name_dsp;
    new_references.sob_id                            := x_sob_id;
    new_references.coa_id                            := x_coa_id;
    new_references.visibility                        := x_visibility;
    new_references.default_type                      := x_default_type;
    new_references.default_value                     := x_default_value;
    new_references.updatable                         := x_updatable;
    new_references.stored_name                       := x_stored_name;

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
  ||  Created On : 18-APR-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.source_id = new_references.source_id)) OR
        ((new_references.source_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_dos_sources_pkg.get_pk_for_validation (
                new_references.source_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_source_usages_pkg.check_parent_existance.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE get_fk_igi_dos_sources (
    x_source_id                         IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_dos_source_usages
      WHERE   ((source_id = x_source_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND', 'FND-CANNOT DELETE MASTER');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_source_usages_pkg.get_fk_igi_dos_sources.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_dos_sources;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_source_id                         IN     NUMBER       ,
    x_segment_name                      IN     VARCHAR2     ,
    x_segment_name_dsp                  IN     VARCHAR2     ,
    x_sob_id                            IN     NUMBER       ,
    x_coa_id                            IN     NUMBER       ,
    x_visibility                        IN     VARCHAR2     ,
    x_default_type                      IN     VARCHAR2     ,
    x_default_value                     IN     VARCHAR2     ,
    x_updatable                         IN     VARCHAR2     ,
    x_stored_name                       IN     VARCHAR2     ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
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
      x_source_id,
      x_segment_name,
      x_segment_name_dsp,
      x_sob_id,
      x_coa_id,
      x_visibility,
      x_default_type,
      x_default_value,
      x_updatable,
      x_stored_name,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      /* commented since there is no pk
      IF ( get_pk_for_validation(

           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_source_usages_pkg.before_dml.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
        app_exception.raise_exception;
      END IF;  */

      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      /* commented since there is no pk
      IF ( get_pk_for_validation (

           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
-- bug 3199481, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_source_usages_pkg.before_dml.Msg2',FALSE);
        END IF;
-- bug 3199481, end block
        app_exception.raise_exception;
      END IF;  */

       null ;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_source_id                         IN     NUMBER,
    x_segment_name                      IN     VARCHAR2,
    x_segment_name_dsp                  IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_visibility                        IN     VARCHAR2,
    x_default_type                      IN     VARCHAR2,
    x_default_value                     IN     VARCHAR2,
    x_updatable                         IN     VARCHAR2,
    x_stored_name                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_dos_source_usages
      WHERE   1=1  ;

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
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_source_usages_pkg.insert_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_source_id                         => x_source_id,
      x_segment_name                      => x_segment_name,
      x_segment_name_dsp                  => x_segment_name_dsp,
      x_sob_id                            => x_sob_id,
      x_coa_id                            => x_coa_id,
      x_visibility                        => x_visibility,
      x_default_type                      => x_default_type,
      x_default_value                     => x_default_value,
      x_updatable                         => x_updatable,
      x_stored_name                       => x_stored_name,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igi_dos_source_usages (
      source_id,
      segment_name,
      segment_name_dsp,
      sob_id,
      coa_id,
      visibility,
      default_type,
      default_value,
      updatable,
      stored_name,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.source_id,
      new_references.segment_name,
      new_references.segment_name_dsp,
      new_references.sob_id,
      new_references.coa_id,
      new_references.visibility,
      new_references.default_type,
      new_references.default_value,
      new_references.updatable,
      new_references.stored_name,
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
    x_source_id                         IN     NUMBER,
    x_segment_name                      IN     VARCHAR2,
    x_segment_name_dsp                  IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_visibility                        IN     VARCHAR2,
    x_default_type                      IN     VARCHAR2,
    x_default_value                     IN     VARCHAR2,
    x_updatable                         IN     VARCHAR2,
    x_stored_name                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        source_id,
        segment_name,
        segment_name_dsp,
        sob_id,
        coa_id,
        visibility,
        default_type,
        default_value,
        updatable,
        stored_name
      FROM  igi_dos_source_usages
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_source_usages_pkg.lock_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        ((tlinfo.source_id = x_source_id) OR ((tlinfo.source_id IS NULL) AND (X_source_id IS NULL)))
        AND ((tlinfo.segment_name = x_segment_name) OR ((tlinfo.segment_name IS NULL) AND (X_segment_name IS NULL)))
        AND ((tlinfo.segment_name_dsp = x_segment_name_dsp) OR ((tlinfo.segment_name_dsp IS NULL) AND (X_segment_name_dsp IS NULL)))
        AND ((tlinfo.sob_id = x_sob_id) OR ((tlinfo.sob_id IS NULL) AND (X_sob_id IS NULL)))
        AND ((tlinfo.coa_id = x_coa_id) OR ((tlinfo.coa_id IS NULL) AND (X_coa_id IS NULL)))
        AND ((tlinfo.visibility = x_visibility) OR ((tlinfo.visibility IS NULL) AND (X_visibility IS NULL)))
        AND ((tlinfo.default_type = x_default_type) OR ((tlinfo.default_type IS NULL) AND (X_default_type IS NULL)))
        AND ((tlinfo.default_value = x_default_value) OR ((tlinfo.default_value IS NULL) AND (X_default_value IS NULL)))
        AND ((tlinfo.updatable = x_updatable) OR ((tlinfo.updatable IS NULL) AND (X_updatable IS NULL)))
        AND ((tlinfo.stored_name = x_stored_name) OR ((tlinfo.stored_name IS NULL) AND (X_stored_name IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_source_usages_pkg.lock_row.Msg2',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_source_id                         IN     NUMBER,
    x_segment_name                      IN     VARCHAR2,
    x_segment_name_dsp                  IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_visibility                        IN     VARCHAR2,
    x_default_type                      IN     VARCHAR2,
    x_default_value                     IN     VARCHAR2,
    x_updatable                         IN     VARCHAR2,
    x_stored_name                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
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
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_source_usages_pkg.update_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_source_id                         => x_source_id,
      x_segment_name                      => x_segment_name,
      x_segment_name_dsp                  => x_segment_name_dsp,
      x_sob_id                            => x_sob_id,
      x_coa_id                            => x_coa_id,
      x_visibility                        => x_visibility,
      x_default_type                      => x_default_type,
      x_default_value                     => x_default_value,
      x_updatable                         => x_updatable,
      x_stored_name                       => x_stored_name,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_dos_source_usages
      SET
        source_id                         = new_references.source_id,
        segment_name                      = new_references.segment_name,
        segment_name_dsp                  = new_references.segment_name_dsp,
        sob_id                            = new_references.sob_id,
        coa_id                            = new_references.coa_id,
        visibility                        = new_references.visibility,
        default_type                      = new_references.default_type,
        default_value                     = new_references.default_value,
        updatable                         = new_references.updatable,
        stored_name                       = new_references.stored_name,
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
    x_source_id                         IN     NUMBER,
    x_segment_name                      IN     VARCHAR2,
    x_segment_name_dsp                  IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_coa_id                            IN     NUMBER,
    x_visibility                        IN     VARCHAR2,
    x_default_type                      IN     VARCHAR2,
    x_default_value                     IN     VARCHAR2,
    x_updatable                         IN     VARCHAR2,
    x_stored_name                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_dos_source_usages
      WHERE   1=1 ;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_source_id,
        x_segment_name,
        x_segment_name_dsp,
        x_sob_id,
        x_coa_id,
        x_visibility,
        x_default_type,
        x_default_value,
        x_updatable,
        x_stored_name,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_source_id,
      x_segment_name,
      x_segment_name_dsp,
      x_sob_id,
      x_coa_id,
      x_visibility,
      x_default_type,
      x_default_value,
      x_updatable,
      x_stored_name,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
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

    DELETE FROM igi_dos_source_usages
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igi_dos_source_usages_pkg;

/
