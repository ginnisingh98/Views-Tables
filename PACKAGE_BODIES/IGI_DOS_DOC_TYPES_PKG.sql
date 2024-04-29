--------------------------------------------------------
--  DDL for Package Body IGI_DOS_DOC_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DOS_DOC_TYPES_PKG" AS
/* $Header: igidosob.pls 120.6.12000000.2 2007/06/14 05:47:01 pshivara ship $ */

l_debug_level   number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;

l_state_level   number := FND_LOG.LEVEL_STATEMENT ;
l_proc_level    number := FND_LOG.LEVEL_PROCEDURE ;
l_event_level   number := FND_LOG.LEVEL_EVENT ;
l_excep_level   number := FND_LOG.LEVEL_EXCEPTION ;
l_error_level   number := FND_LOG.LEVEL_ERROR ;
l_unexp_level   number := FND_LOG.LEVEL_UNEXPECTED ;

 l_rowid VARCHAR2(25);
  old_references igi_dos_doc_types%ROWTYPE;
  new_references igi_dos_doc_types%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_amount_type                       IN     VARCHAR2    ,
    x_dossier_id                        IN     NUMBER      ,
    x_dossier_name                      IN     VARCHAR2    ,
    x_dossier_numbering                 IN     VARCHAR2    ,
    x_coa_id                            IN     NUMBER      ,
    x_sob_id                            IN     NUMBER      ,
    x_hierarchy_id                      IN     NUMBER      ,
    x_balanced                          IN     VARCHAR2    ,
    x_dossier_description               IN     VARCHAR2    ,
    x_multi_annual                      IN     VARCHAR2    ,
 --   x_related_dossier                   IN     VARCHAR2    ,
    x_related_dossier_dsp               IN     VARCHAR2    ,
    x_dossier_relationship              IN     VARCHAR2    ,
    x_dossier_relationship_dsp          IN     VARCHAR2    ,
    x_dossier_status                    IN     VARCHAR2    ,
    x_workflow_name                     IN     VARCHAR2    ,
    x_retired_flag                      IN     VARCHAR2    ,
    x_attribute_category                IN     VARCHAR2    ,
    x_attribute1                        IN     VARCHAR2    ,
    x_attribute2                        IN     VARCHAR2    ,
    x_attribute3                        IN     VARCHAR2    ,
    x_attribute4                        IN     VARCHAR2    ,
    x_attribute5                        IN     VARCHAR2    ,
    x_attribute6                        IN     VARCHAR2    ,
    x_attribute7                        IN     VARCHAR2    ,
    x_attribute8                        IN     VARCHAR2    ,
    x_attribute9                        IN     VARCHAR2    ,
    x_attribute10                       IN     VARCHAR2    ,
    x_attribute11                       IN     VARCHAR2    ,
    x_attribute12                       IN     VARCHAR2    ,
    x_attribute13                       IN     VARCHAR2    ,
    x_attribute14                       IN     VARCHAR2    ,
    x_attribute15                       IN     VARCHAR2    ,
    x_related_dossier_id                IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ) AS
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
      FROM     igi_dos_doc_types
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_doc_types_pkg.set_column_values.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.amount_type                       := x_amount_type;
    new_references.dossier_id                        := x_dossier_id;
    new_references.dossier_name                      := x_dossier_name;
    new_references.dossier_numbering                 := x_dossier_numbering;
    new_references.coa_id                            := x_coa_id;
    new_references.sob_id                            := x_sob_id;
    new_references.hierarchy_id                      := x_hierarchy_id;
    new_references.balanced                          := x_balanced;
    new_references.dossier_description               := x_dossier_description;
    new_references.multi_annual                      := x_multi_annual;
--    new_references.related_dossier                   := x_related_dossier;
    new_references.related_dossier_dsp               := x_related_dossier_dsp;
    new_references.dossier_relationship              := x_dossier_relationship;
    new_references.dossier_relationship_dsp          := x_dossier_relationship_dsp;
    new_references.dossier_status                    := x_dossier_status;
    new_references.workflow_name                     := x_workflow_name;
    new_references.retired_flag                      := x_retired_flag;
    new_references.attribute_category                := x_attribute_category;
    new_references.attribute1                        := x_attribute1;
    new_references.attribute2                        := x_attribute2;
    new_references.attribute3                        := x_attribute3;
    new_references.attribute4                        := x_attribute4;
    new_references.attribute5                        := x_attribute5;
    new_references.attribute6                        := x_attribute6;
    new_references.attribute7                        := x_attribute7;
    new_references.attribute8                        := x_attribute8;
    new_references.attribute9                        := x_attribute9;
    new_references.attribute10                       := x_attribute10;
    new_references.attribute11                       := x_attribute11;
    new_references.attribute12                       := x_attribute12;
    new_references.attribute13                       := x_attribute13;
    new_references.attribute14                       := x_attribute14;
    new_references.attribute15                       := x_attribute15;
    new_references.related_dossier_id                := x_related_dossier_id;

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

    IF (((old_references.dossier_numbering = new_references.dossier_numbering)) OR
        ((new_references.dossier_numbering IS NULL))) THEN
      NULL;
    /* for dossier numbering there is no TBH package
    ELSIF NOT igi_dossier_numbering_pkg.get_pk_for_validation (
                new_references.dossier_numbering
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_doc_types_pkg.check_parent_existance.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception; */
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  cursor cur_rel_dos is
  select count(*) from
  igi_dos_doc_types
  where related_dossier_id = old_references.dossier_id ;

  cur_row_cnt number;

  BEGIN
     open cur_rel_dos ;
     fetch cur_rel_dos into cur_row_cnt;
     close cur_rel_dos;

     if cur_row_cnt > 0 then
           fnd_message.set_name('IGI', 'IGI_DOS_NO_DELETE_TYPE');
-- bug 3199481, start block
           IF (l_unexp_level >= l_debug_level) THEN
              FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_doc_types_pkg.check_child_existance.Msg1',FALSE);
           END IF;
-- bug 3199481, end block
           app_exception.raise_exception;
     end if;

    igi_dos_sources_pkg.get_fk_igi_dos_doc_types (
      old_references.dossier_id
    );
    igi_dos_destinations_pkg.get_fk_igi_dos_doc_types (
      old_references.dossier_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_dossier_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 18-APR-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_dos_doc_types
      WHERE    dossier_id = x_dossier_id
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


  PROCEDURE get_fk_igi_dossier_numbering (
    x_numbering_scheme                  IN     VARCHAR2
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
      FROM     igi_dos_doc_types
      WHERE   ((dossier_numbering = x_numbering_scheme));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND', 'FND-CANNOT DELETE MASTER');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_doc_types_pkg.get_fk_igi_dossier_numbering.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_dossier_numbering;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_amount_type                       IN     VARCHAR2    ,
    x_dossier_id                        IN     NUMBER      ,
    x_dossier_name                      IN     VARCHAR2    ,
    x_dossier_numbering                 IN     VARCHAR2    ,
    x_coa_id                            IN     NUMBER      ,
    x_sob_id                            IN     NUMBER      ,
    x_hierarchy_id                      IN     NUMBER      ,
    x_balanced                          IN     VARCHAR2    ,
    x_dossier_description               IN     VARCHAR2    ,
    x_multi_annual                      IN     VARCHAR2    ,
    x_related_dossier                   IN     VARCHAR2    ,
    x_related_dossier_dsp               IN     VARCHAR2    ,
    x_dossier_relationship              IN     VARCHAR2    ,
    x_dossier_relationship_dsp          IN     VARCHAR2    ,
    x_dossier_status                    IN     VARCHAR2    ,
    x_workflow_name                     IN     VARCHAR2    ,
    x_retired_flag                      IN     VARCHAR2    ,
    x_attribute_category                IN     VARCHAR2     ,
    x_attribute1                        IN     VARCHAR2     ,
    x_attribute2                        IN     VARCHAR2     ,
    x_attribute3                        IN     VARCHAR2     ,
    x_attribute4                        IN     VARCHAR2     ,
    x_attribute5                        IN     VARCHAR2     ,
    x_attribute6                        IN     VARCHAR2     ,
    x_attribute7                        IN     VARCHAR2     ,
    x_attribute8                        IN     VARCHAR2     ,
    x_attribute9                        IN     VARCHAR2     ,
    x_attribute10                       IN     VARCHAR2     ,
    x_attribute11                       IN     VARCHAR2     ,
    x_attribute12                       IN     VARCHAR2     ,
    x_attribute13                       IN     VARCHAR2     ,
    x_attribute14                       IN     VARCHAR2     ,
    x_attribute15                       IN     VARCHAR2     ,
    x_related_dossier_id                IN     NUMBER       ,
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
      x_amount_type,
      x_dossier_id,
      x_dossier_name,
      x_dossier_numbering,
      x_coa_id,
      x_sob_id,
      x_hierarchy_id,
      x_balanced,
      x_dossier_description,
      x_multi_annual,
  --    x_related_dossier,
      x_related_dossier_dsp,
      x_dossier_relationship,
      x_dossier_relationship_dsp,
      x_dossier_status,
      x_workflow_name,
      x_retired_flag,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_related_dossier_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.dossier_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
-- bug 3199481, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_doc_types_pkg.before_dml.Msg1',FALSE);
        END IF;
-- bug 3199481, end block
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
             new_references.dossier_id
           )
         ) THEN
        fnd_message.set_name('FND','FORM_DUPLICATE_KEY_IN_INDEX');
-- bug 3199481, start block
        IF (l_unexp_level >= l_debug_level) THEN
           FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_doc_types_pkg.before_dml.Msg2',FALSE);
        END IF;
-- bug 3199481, end block
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_amount_type                       IN     VARCHAR2,
    x_dossier_id                        IN OUT NOCOPY NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_dossier_numbering                 IN     VARCHAR2,
    x_coa_id                            IN     NUMBER,
    x_sob_id                            IN     NUMBER,
    x_hierarchy_id                      IN     NUMBER,
    x_balanced                          IN     VARCHAR2,
    x_dossier_description               IN     VARCHAR2,
    x_multi_annual                      IN     VARCHAR2,
    x_related_dossier                   IN     VARCHAR2,
    x_related_dossier_dsp               IN     VARCHAR2,
    x_dossier_relationship              IN     VARCHAR2,
    x_dossier_relationship_dsp          IN     VARCHAR2,
    x_dossier_status                    IN     VARCHAR2,
    x_workflow_name                     IN     VARCHAR2,
    x_retired_flag                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_related_dossier_id                IN     NUMBER,
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
      FROM     igi_dos_doc_types
      WHERE    dossier_id                        = x_dossier_id;

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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_doc_types_pkg.insert_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    SELECT    igi_dos_doc_types_s.NEXTVAL
    INTO      x_dossier_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_amount_type                       => x_amount_type,
      x_dossier_id                        => x_dossier_id,
      x_dossier_name                      => x_dossier_name,
      x_dossier_numbering                 => x_dossier_numbering,
      x_coa_id                            => x_coa_id,
      x_sob_id                            => x_sob_id,
      x_hierarchy_id                      => x_hierarchy_id,
      x_balanced                          => x_balanced,
      x_dossier_description               => x_dossier_description,
      x_multi_annual                      => x_multi_annual,
      x_related_dossier                   => x_related_dossier,
      x_related_dossier_dsp               => x_related_dossier_dsp,
      x_dossier_relationship              => x_dossier_relationship,
      x_dossier_relationship_dsp          => x_dossier_relationship_dsp,
      x_dossier_status                    => x_dossier_status,
      x_workflow_name                     => x_workflow_name,
      x_retired_flag                      => x_retired_flag,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_related_dossier_id                => x_related_dossier_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igi_dos_doc_types (
      amount_type,
      dossier_id,
      dossier_name,
      dossier_numbering,
      coa_id,
      sob_id,
      hierarchy_id,
      balanced,
      dossier_description,
      multi_annual,
     -- related_dossier,
      related_dossier_dsp,
      dossier_relationship,
      dossier_relationship_dsp,
      dossier_status,
      workflow_name,
      retired_flag,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      related_dossier_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.amount_type,
      new_references.dossier_id,
      new_references.dossier_name,
      new_references.dossier_numbering,
      new_references.coa_id,
      new_references.sob_id,
      new_references.hierarchy_id,
      new_references.balanced,
      new_references.dossier_description,
      new_references.multi_annual,
   --   new_references.related_dossier,
      new_references.related_dossier_dsp,
      new_references.dossier_relationship,
      new_references.dossier_relationship_dsp,
      new_references.dossier_status,
      new_references.workflow_name,
      new_references.retired_flag,
      new_references.attribute_category,
      new_references.attribute1,
      new_references.attribute2,
      new_references.attribute3,
      new_references.attribute4,
      new_references.attribute5,
      new_references.attribute6,
      new_references.attribute7,
      new_references.attribute8,
      new_references.attribute9,
      new_references.attribute10,
      new_references.attribute11,
      new_references.attribute12,
      new_references.attribute13,
      new_references.attribute14,
      new_references.attribute15,
      new_references.related_dossier_id,
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
    x_amount_type                       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_dossier_numbering                 IN     VARCHAR2,
    x_coa_id                            IN     NUMBER,
    x_sob_id                            IN     NUMBER,
    x_hierarchy_id                      IN     NUMBER,
    x_balanced                          IN     VARCHAR2,
    x_dossier_description               IN     VARCHAR2,
    x_multi_annual                      IN     VARCHAR2,
    x_related_dossier                   IN     VARCHAR2,
    x_related_dossier_dsp               IN     VARCHAR2,
    x_dossier_relationship              IN     VARCHAR2,
    x_dossier_relationship_dsp          IN     VARCHAR2,
    x_dossier_status                    IN     VARCHAR2,
    x_workflow_name                     IN     VARCHAR2,
    x_retired_flag                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_related_dossier_id                IN     NUMBER
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
        amount_type,
        dossier_name,
        dossier_numbering,
        coa_id,
        sob_id,
        hierarchy_id,
        balanced,
        dossier_description,
        multi_annual,
      --  related_dossier,
        related_dossier_dsp,
        dossier_relationship,
        dossier_relationship_dsp,
        dossier_status,
        workflow_name,
        retired_flag,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        related_dossier_id
      FROM  igi_dos_doc_types
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_doc_types_pkg.lock_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        ((tlinfo.amount_type = x_amount_type) OR ((tlinfo.amount_type IS NULL) AND (X_amount_type IS NULL)))
        AND (tlinfo.dossier_name = x_dossier_name)
        AND ((tlinfo.dossier_numbering = x_dossier_numbering) OR ((tlinfo.dossier_numbering IS NULL) AND (X_dossier_numbering IS NULL)))
        AND (tlinfo.coa_id = x_coa_id)
        AND (tlinfo.sob_id = x_sob_id)
        AND ((tlinfo.hierarchy_id = x_hierarchy_id) OR ((tlinfo.hierarchy_id IS NULL) AND (X_hierarchy_id IS NULL)))
        AND (tlinfo.balanced = x_balanced)
        AND ((tlinfo.dossier_description = x_dossier_description) OR ((tlinfo.dossier_description IS NULL) AND (X_dossier_description IS NULL)))
        AND (tlinfo.multi_annual = x_multi_annual)
       -- AND ((tlinfo.related_dossier = x_related_dossier) OR ((tlinfo.related_dossier IS NULL) AND (X_related_dossier IS NULL)))
        AND ((tlinfo.related_dossier_dsp = x_related_dossier_dsp) OR ((tlinfo.related_dossier_dsp IS NULL) AND (X_related_dossier_dsp IS NULL)))
        AND ((tlinfo.dossier_relationship = x_dossier_relationship) OR ((tlinfo.dossier_relationship IS NULL) AND (X_dossier_relationship IS NULL)))
        AND ((tlinfo.dossier_relationship_dsp = x_dossier_relationship_dsp) OR ((tlinfo.dossier_relationship_dsp IS NULL) AND (X_dossier_relationship_dsp IS NULL)))
        AND (tlinfo.dossier_status = x_dossier_status)
        AND ((tlinfo.workflow_name = x_workflow_name) OR ((tlinfo.workflow_name IS NULL) AND (X_workflow_name IS NULL)))
        AND ((tlinfo.retired_flag = x_retired_flag) OR ((tlinfo.retired_flag IS NULL) AND (X_retired_flag IS NULL)))
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (X_attribute11 IS NULL)))
        AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (X_attribute12 IS NULL)))
        AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (X_attribute13 IS NULL)))
        AND ((tlinfo.attribute14 = x_attribute14) OR ((tlinfo.attribute14 IS NULL) AND (X_attribute14 IS NULL)))
        AND ((tlinfo.attribute15 = x_attribute15) OR ((tlinfo.attribute15 IS NULL) AND (X_attribute15 IS NULL)))
        AND ((tlinfo.related_dossier_id = x_related_dossier_id) OR ((tlinfo.related_dossier_id IS NULL) AND (X_related_dossier_id IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_doc_types_pkg.lock_row.Msg2',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_amount_type                       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_dossier_numbering                 IN     VARCHAR2,
    x_coa_id                            IN     NUMBER,
    x_sob_id                            IN     NUMBER,
    x_hierarchy_id                      IN     NUMBER,
    x_balanced                          IN     VARCHAR2,
    x_dossier_description               IN     VARCHAR2,
    x_multi_annual                      IN     VARCHAR2,
    x_related_dossier                   IN     VARCHAR2,
    x_related_dossier_dsp               IN     VARCHAR2,
    x_dossier_relationship              IN     VARCHAR2,
    x_dossier_relationship_dsp          IN     VARCHAR2,
    x_dossier_status                    IN     VARCHAR2,
    x_workflow_name                     IN     VARCHAR2,
    x_retired_flag                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_related_dossier_id                IN     NUMBER,
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
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_dos_doc_types_pkg.update_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_amount_type                       => x_amount_type,
      x_dossier_id                        => x_dossier_id,
      x_dossier_name                      => x_dossier_name,
      x_dossier_numbering                 => x_dossier_numbering,
      x_coa_id                            => x_coa_id,
      x_sob_id                            => x_sob_id,
      x_hierarchy_id                      => x_hierarchy_id,
      x_balanced                          => x_balanced,
      x_dossier_description               => x_dossier_description,
      x_multi_annual                      => x_multi_annual,
      x_related_dossier                   => x_related_dossier,
      x_related_dossier_dsp               => x_related_dossier_dsp,
      x_dossier_relationship              => x_dossier_relationship,
      x_dossier_relationship_dsp          => x_dossier_relationship_dsp,
      x_dossier_status                    => x_dossier_status,
      x_workflow_name                     => x_workflow_name,
      x_retired_flag                      => x_retired_flag,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_related_dossier_id                => x_related_dossier_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_dos_doc_types
      SET
        amount_type                       = new_references.amount_type,
        dossier_name                      = new_references.dossier_name,
        dossier_numbering                 = new_references.dossier_numbering,
        coa_id                            = new_references.coa_id,
        sob_id                            = new_references.sob_id,
        hierarchy_id                      = new_references.hierarchy_id,
        balanced                          = new_references.balanced,
        dossier_description               = new_references.dossier_description,
        multi_annual                      = new_references.multi_annual,
       -- related_dossier                   = new_references.related_dossier,
        related_dossier_dsp               = new_references.related_dossier_dsp,
        dossier_relationship              = new_references.dossier_relationship,
        dossier_relationship_dsp          = new_references.dossier_relationship_dsp,
        dossier_status                    = new_references.dossier_status,
        workflow_name                     = new_references.workflow_name,
        retired_flag                      = new_references.retired_flag,
        attribute_category                = new_references.attribute_category,
        attribute1                        = new_references.attribute1,
        attribute2                        = new_references.attribute2,
        attribute3                        = new_references.attribute3,
        attribute4                        = new_references.attribute4,
        attribute5                        = new_references.attribute5,
        attribute6                        = new_references.attribute6,
        attribute7                        = new_references.attribute7,
        attribute8                        = new_references.attribute8,
        attribute9                        = new_references.attribute9,
        attribute10                       = new_references.attribute10,
        attribute11                       = new_references.attribute11,
        attribute12                       = new_references.attribute12,
        attribute13                       = new_references.attribute13,
        attribute14                       = new_references.attribute14,
        attribute15                       = new_references.attribute15,
        related_dossier_id                = new_references.related_dossier_id,
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
    x_amount_type                       IN     VARCHAR2,
    x_dossier_id                        IN OUT NOCOPY NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_dossier_numbering                 IN     VARCHAR2,
    x_coa_id                            IN     NUMBER,
    x_sob_id                            IN     NUMBER,
    x_hierarchy_id                      IN     NUMBER,
    x_balanced                          IN     VARCHAR2,
    x_dossier_description               IN     VARCHAR2,
    x_multi_annual                      IN     VARCHAR2,
    x_related_dossier                   IN     VARCHAR2,
    x_related_dossier_dsp               IN     VARCHAR2,
    x_dossier_relationship              IN     VARCHAR2,
    x_dossier_relationship_dsp          IN     VARCHAR2,
    x_dossier_status                    IN     VARCHAR2,
    x_workflow_name                     IN     VARCHAR2,
    x_retired_flag                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_related_dossier_id                IN     NUMBER,
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
      FROM     igi_dos_doc_types
      WHERE    dossier_id                        = x_dossier_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_amount_type,
        x_dossier_id,
        x_dossier_name,
        x_dossier_numbering,
        x_coa_id,
        x_sob_id,
        x_hierarchy_id,
        x_balanced,
        x_dossier_description,
        x_multi_annual,
        x_related_dossier,
        x_related_dossier_dsp,
        x_dossier_relationship,
        x_dossier_relationship_dsp,
        x_dossier_status,
        x_workflow_name,
        x_retired_flag,
        x_attribute_category,
        x_attribute1,
        x_attribute2,
        x_attribute3,
        x_attribute4,
        x_attribute5,
        x_attribute6,
        x_attribute7,
        x_attribute8,
        x_attribute9,
        x_attribute10,
        x_attribute11,
        x_attribute12,
        x_attribute13,
        x_attribute14,
        x_attribute15,
        x_related_dossier_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_amount_type,
      x_dossier_id,
      x_dossier_name,
      x_dossier_numbering,
      x_coa_id,
      x_sob_id,
      x_hierarchy_id,
      x_balanced,
      x_dossier_description,
      x_multi_annual,
      x_related_dossier,
      x_related_dossier_dsp,
      x_dossier_relationship,
      x_dossier_relationship_dsp,
      x_dossier_status,
      x_workflow_name,
      x_retired_flag,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_related_dossier_id,
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


    DELETE FROM igi_dos_doc_types
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igi_dos_doc_types_pkg;

/
