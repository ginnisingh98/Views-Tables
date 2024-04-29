--------------------------------------------------------
--  DDL for Package Body IGS_CO_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_MAPPING_PKG" AS
/* $Header: IGSLI29B.pls 120.0 2005/06/01 23:37:26 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_co_mapping%ROWTYPE;
  new_references igs_co_mapping%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_map_id                            IN     NUMBER      DEFAULT NULL,
    x_map_code                          IN     VARCHAR2    DEFAULT NULL,
    x_doc_code                          IN     VARCHAR2    DEFAULT NULL,
    x_document_id                       IN     NUMBER      DEFAULT NULL,
    x_enable_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_sys_ltr_code                      IN     VARCHAR2    DEFAULT NULL,
    x_map_description                   IN     VARCHAR2    DEFAULT NULL,
    x_elapsed_days                      IN     NUMBER      DEFAULT NULL,
    x_repeat_times                      IN     NUMBER      DEFAULT NULL,
    x_attr_description                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 07-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_co_mapping
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
    new_references.map_id                            := x_map_id;
    new_references.map_code                          := x_map_code;
    new_references.doc_code                          := x_doc_code;
    new_references.document_id                       := x_document_id;
    new_references.enable_flag                       := x_enable_flag;
    new_references.sys_ltr_code                      := x_sys_ltr_code;
    new_references.map_description                   := x_map_description;
    new_references.elapsed_days                      := x_elapsed_days;
    new_references.repeat_times                      := x_repeat_times;
    new_references.attr_description                  := x_attr_description;

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


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : prchandr
  ||  Created On : 07-FEB-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.document_id,
           new_references.map_code,
           new_references.sys_ltr_code
         )
       ) THEN
     IF new_references.enable_flag='Y' THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : prchandr
  ||  Created On : 07-FEB-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kumma           07-JUN-2003     Modified the cursor to use the new data modal
  ||  ssawhney        4-may-2004      IBC.C patchset changes bug 3565861, different cursors for LIST and DOCUMENT
  */


  CURSOR c_list_item (cp_id IN NUMBER, cp_ctype_code IN VARCHAR) IS
          SELECT COUNT(citem_id)
	  FROM IBC_CITEMS_V
	  WHERE CITEM_ID = cp_id AND
	  CTYPE_CODE =cp_ctype_code AND
	  LANGUAGE = USERENV('LANG');


  CURSOR c_doc_item (cp_id IN NUMBER) IS
          SELECT COUNT(content_item_id)
	  FROM IBC_CONTENT_ITEMS
	  WHERE CONTENT_ITEM_ID = cp_id AND
	  EXISTS
	  (SELECT CONTENT_TYPE_CODE FROM IBC_CTYPE_GROUP_NODES WHERE
	   DIRECTORY_NODE_ID IN (32,33,34));

  l_list_item NUMBER;
  l_doc_item NUMBER;

  BEGIN


  IF new_references.map_code='LIST' THEN
    OPEN c_list_item (new_references.document_id,'IBC_QUERY');
    FETCH c_list_item INTO l_list_item;
    CLOSE c_list_item;

     IF (((old_references.document_id = new_references.document_id)) OR
        ((new_references.document_id IS NULL))) THEN
       NULL;
     ELSIF l_list_item = 0 THEN
       fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
     END IF;
   ELSIF new_references.map_code = 'DOCUMENT' THEN
     OPEN c_doc_item(new_references.document_id);
     FETCH c_doc_item INTO l_doc_item;
     CLOSE c_doc_item;

     IF (((old_references.document_id = new_references.document_id)) OR
        ((new_references.document_id IS NULL))) THEN
       NULL;
     ELSIF l_doc_item = 0 THEN
       fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
     END IF;
   END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_map_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 07-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_mapping
      WHERE    map_id = x_map_id
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


  FUNCTION get_uk_for_validation (
    x_document_id                       IN     NUMBER,
    x_map_code                          IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 07-FEB-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_mapping
      WHERE    document_id = x_document_id
      AND      map_code = x_map_code
      AND      sys_ltr_code = x_sys_ltr_code
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      AND      enable_flag='Y';

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_map_id                            IN     NUMBER      DEFAULT NULL,
    x_map_code                          IN     VARCHAR2    DEFAULT NULL,
    x_doc_code                          IN     VARCHAR2    DEFAULT NULL,
    x_document_id                       IN     NUMBER      DEFAULT NULL,
    x_enable_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_sys_ltr_code                      IN     VARCHAR2    DEFAULT NULL,
    x_map_description                   IN     VARCHAR2    DEFAULT NULL,
    x_elapsed_days                      IN     NUMBER      DEFAULT NULL,
    x_repeat_times                      IN     NUMBER      DEFAULT NULL,
    x_attr_description                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 07-FEB-2002
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
      x_map_id,
      x_map_code,
      x_doc_code,
      x_document_id,
      x_enable_flag,
      x_sys_ltr_code,
      x_map_description,
      x_elapsed_days,
      x_repeat_times,
      x_attr_description,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.map_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.map_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_map_id                            IN OUT NOCOPY NUMBER,
    x_map_code                          IN     VARCHAR2,
    x_doc_code                          IN     VARCHAR2,
    x_document_id                       IN     NUMBER,
    x_enable_flag                       IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_map_description                   IN     VARCHAR2,
    x_elapsed_days                      IN     NUMBER,
    x_repeat_times                      IN     NUMBER,
    x_attr_description                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 07-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_co_mapping
      WHERE    map_id                            = x_map_id;

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

    SELECT    igs_co_mapping_s.NEXTVAL
    INTO      x_map_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_map_id                            => x_map_id,
      x_map_code                          => x_map_code,
      x_doc_code                          => x_doc_code,
      x_document_id                       => x_document_id,
      x_enable_flag                       => x_enable_flag,
      x_sys_ltr_code                      => x_sys_ltr_code,
      x_map_description                   => x_map_description,
      x_elapsed_days                      => x_elapsed_days,
      x_repeat_times                      => x_repeat_times,
      x_attr_description                  => x_attr_description,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_co_mapping (
      map_id,
      map_code,
      doc_code,
      document_id,
      enable_flag,
      sys_ltr_code,
      map_description,
      elapsed_days,
      repeat_times,
      attr_description,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.map_id,
      new_references.map_code,
      new_references.doc_code,
      new_references.document_id,
      new_references.enable_flag,
      new_references.sys_ltr_code,
      new_references.map_description,
      new_references.elapsed_days,
      new_references.repeat_times,
      new_references.attr_description,
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
    x_map_id                            IN     NUMBER,
    x_map_code                          IN     VARCHAR2,
    x_doc_code                          IN     VARCHAR2,
    x_document_id                       IN     NUMBER,
    x_enable_flag                       IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_map_description                   IN     VARCHAR2,
    x_elapsed_days                      IN     NUMBER,
    x_repeat_times                      IN     NUMBER,
    x_attr_description                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 07-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        map_code,
        doc_code,
        document_id,
        enable_flag,
        sys_ltr_code,
        map_description,
        elapsed_days,
        repeat_times,
        attr_description
      FROM  igs_co_mapping
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
        (tlinfo.map_code = x_map_code)
        AND (tlinfo.doc_code = x_doc_code)
        AND (tlinfo.document_id = x_document_id)
        AND (tlinfo.enable_flag = x_enable_flag)
        AND (tlinfo.sys_ltr_code = x_sys_ltr_code)
        AND ((tlinfo.map_description = x_map_description) OR ((tlinfo.map_description IS NULL) AND (X_map_description IS NULL)))
        AND ((tlinfo.elapsed_days = x_elapsed_days) OR ((tlinfo.elapsed_days IS NULL) AND (X_elapsed_days IS NULL)))
        AND ((tlinfo.repeat_times = x_repeat_times) OR ((tlinfo.repeat_times IS NULL) AND (X_repeat_times IS NULL)))
        AND ((tlinfo.attr_description = x_attr_description) OR ((tlinfo.attr_description IS NULL) AND (X_attr_description IS NULL)))
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
    x_map_id                            IN     NUMBER,
    x_map_code                          IN     VARCHAR2,
    x_doc_code                          IN     VARCHAR2,
    x_document_id                       IN     NUMBER,
    x_enable_flag                       IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_map_description                   IN     VARCHAR2,
    x_elapsed_days                      IN     NUMBER,
    x_repeat_times                      IN     NUMBER,
    x_attr_description                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 07-FEB-2002
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_map_id                            => x_map_id,
      x_map_code                          => x_map_code,
      x_doc_code                          => x_doc_code,
      x_document_id                       => x_document_id,
      x_enable_flag                       => x_enable_flag,
      x_sys_ltr_code                      => x_sys_ltr_code,
      x_map_description                   => x_map_description,
      x_elapsed_days                      => x_elapsed_days,
      x_repeat_times                      => x_repeat_times,
      x_attr_description                  => x_attr_description,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_co_mapping
      SET
        map_code                          = new_references.map_code,
        doc_code                          = new_references.doc_code,
        document_id                       = new_references.document_id,
        enable_flag                       = new_references.enable_flag,
        sys_ltr_code                      = new_references.sys_ltr_code,
        map_description                   = new_references.map_description,
        elapsed_days                      = new_references.elapsed_days,
        repeat_times                      = new_references.repeat_times,
        attr_description                  = new_references.attr_description,
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
    x_map_id                            IN OUT NOCOPY NUMBER,
    x_map_code                          IN     VARCHAR2,
    x_doc_code                          IN     VARCHAR2,
    x_document_id                       IN     NUMBER,
    x_enable_flag                       IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_map_description                   IN     VARCHAR2,
    x_elapsed_days                      IN     NUMBER,
    x_repeat_times                      IN     NUMBER,
    x_attr_description                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 07-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_co_mapping
      WHERE    map_id                            = x_map_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_map_id,
        x_map_code,
        x_doc_code,
        x_document_id,
        x_enable_flag,
        x_sys_ltr_code,
        x_map_description,
        x_elapsed_days,
        x_repeat_times,
        x_attr_description,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_map_id,
      x_map_code,
      x_doc_code,
      x_document_id,
      x_enable_flag,
      x_sys_ltr_code,
      x_map_description,
      x_elapsed_days,
      x_repeat_times,
      x_attr_description,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 07-FEB-2002
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

    DELETE FROM igs_co_mapping
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_co_mapping_pkg;

/
