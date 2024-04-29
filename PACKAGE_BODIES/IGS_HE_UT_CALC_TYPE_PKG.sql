--------------------------------------------------------
--  DDL for Package Body IGS_HE_UT_CALC_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_UT_CALC_TYPE_PKG" AS
/* $Header: IGSWI33B.pls 120.0 2005/06/01 18:40:55 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_ut_calc_type%ROWTYPE;
  new_references igs_he_ut_calc_type%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_calc_type_desc             IN     VARCHAR2,
    x_external_calc_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_report_all_hierarchy_flag         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 11-FEB-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_he_ut_calc_type
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
    new_references.tariff_calc_type_cd               := x_tariff_calc_type_cd;
    new_references.tariff_calc_type_desc             := x_tariff_calc_type_desc;
    new_references.external_calc_ind                 := x_external_calc_ind;
    new_references.closed_ind                        := x_closed_ind;
    new_references.report_all_hierarchy_flag         := x_report_all_hierarchy_flag;

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
  ||  Created By :
  ||  Created On : 28-AUG-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_he_ut_excl_qals_pkg.get_fk_igs_he_ut_calc_type (
      old_references.tariff_calc_type_cd
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_tariff_calc_type_cd               IN     VARCHAR2 ,
    x_closed_ind                        IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 11-FEB-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_ut_calc_type
      WHERE    tariff_calc_type_cd = x_tariff_calc_type_cd
      AND  closed_ind  =  NVL(x_closed_ind,closed_ind)
      FOR UPDATE NOWAIT ;

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


  FUNCTION get_uk_for_validation(
    x_external_calc_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smaddali
  ||  Created On : 29-aug-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali modified cursor cur_rowid to add check for rowid as it was missing
  */
      -- get all open external calculation types
      CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_ut_calc_type
      WHERE    external_calc_ind   = 'Y'
      AND      closed_ind          = 'N'
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid)) ;

    lv_rowid cur_rowid%RowType;

  BEGIN
    IF x_external_calc_ind = 'Y' AND x_closed_ind = 'N' THEN
            OPEN cur_rowid;
            FETCH cur_rowid INTO lv_rowid;
            IF (cur_rowid%FOUND) THEN
              CLOSE cur_rowid;
                RETURN (true);
            ELSE
               CLOSE cur_rowid;
              RETURN(FALSE);
            END IF;
     ELSE
            RETURN(FALSE);
     END IF ;

  END get_uk_for_validation ;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : smaddali
  ||  Created On : 29-aug-03
  ||  Purpose : only one external tariff calc type can be open
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF  get_uk_for_validation( new_references.external_calc_ind, new_references.closed_ind )    THEN
      fnd_message.set_name ('IGS', 'IGS_HE_ONE_EXT_CALC_TYPE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;



  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_calc_type_desc             IN     VARCHAR2,
    x_external_calc_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_report_all_hierarchy_flag         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 11-FEB-2003
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
      x_tariff_calc_type_cd,
      x_tariff_calc_type_desc,
      x_external_calc_ind,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_report_all_hierarchy_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.tariff_calc_type_cd,
             NULL
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_HE_UT_CALC_TYPE_EXISTS');
        fnd_message.set_token('CALCTYPE', new_references.tariff_calc_type_cd );
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.tariff_calc_type_cd,
             NULL
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_HE_UT_CALC_TYPE_EXISTS');
        fnd_message.set_token('CALCTYPE', new_references.tariff_calc_type_cd );
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
       check_child_existance;
    END IF;

    IF (p_action IN ('VALIDATE_INSERT', 'VALIDATE_UPDATE', 'VALIDATE_DELETE') ) THEN
      l_rowid := NULL;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_calc_type_desc             IN     VARCHAR2,
    x_external_calc_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_report_all_hierarchy_flag         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 11-FEB-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_UT_CALC_TYPE_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_tariff_calc_type_cd               => x_tariff_calc_type_cd,
      x_tariff_calc_type_desc             => x_tariff_calc_type_desc,
      x_external_calc_ind                 => x_external_calc_ind,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_report_all_hierarchy_flag         => x_report_all_hierarchy_flag
    );

    INSERT INTO igs_he_ut_calc_type (
      tariff_calc_type_cd,
      tariff_calc_type_desc,
      external_calc_ind,
      closed_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      report_all_hierarchy_flag
    ) VALUES (
      new_references.tariff_calc_type_cd,
      new_references.tariff_calc_type_desc,
      new_references.external_calc_ind,
      new_references.closed_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.report_all_hierarchy_flag
    ) RETURNING ROWID INTO x_rowid;

    l_rowid := NULL;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_calc_type_desc             IN     VARCHAR2,
    x_external_calc_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_report_all_hierarchy_flag         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 11-FEB-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        tariff_calc_type_desc,
        external_calc_ind,
        closed_ind,
        report_all_hierarchy_flag
      FROM  igs_he_ut_calc_type
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
        ((tlinfo.tariff_calc_type_desc = x_tariff_calc_type_desc) OR ((tlinfo.tariff_calc_type_desc IS NULL) AND (X_tariff_calc_type_desc IS NULL)))
        AND (tlinfo.external_calc_ind = x_external_calc_ind)
        AND (tlinfo.closed_ind = x_closed_ind)
        AND (tlinfo.report_all_hierarchy_flag = x_report_all_hierarchy_flag)
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
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_calc_type_desc             IN     VARCHAR2,
    x_external_calc_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_report_all_hierarchy_flag         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 11-FEB-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_UT_CALC_TYPE_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_tariff_calc_type_cd               => x_tariff_calc_type_cd,
      x_tariff_calc_type_desc             => x_tariff_calc_type_desc,
      x_external_calc_ind                 => x_external_calc_ind,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_report_all_hierarchy_flag         => x_report_all_hierarchy_flag
    );

    UPDATE igs_he_ut_calc_type
      SET
        tariff_calc_type_desc             = new_references.tariff_calc_type_desc,
        external_calc_ind                 = new_references.external_calc_ind,
        closed_ind                        = new_references.closed_ind,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        report_all_hierarchy_flag         = new_references.report_all_hierarchy_flag
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_calc_type_desc             IN     VARCHAR2,
    x_external_calc_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_report_all_hierarchy_flag         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 11-FEB-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_ut_calc_type
      WHERE    tariff_calc_type_cd               = x_tariff_calc_type_cd;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_tariff_calc_type_cd,
        x_tariff_calc_type_desc,
        x_external_calc_ind,
        x_closed_ind,
        x_report_all_hierarchy_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_tariff_calc_type_cd,
      x_tariff_calc_type_desc,
      x_external_calc_ind,
      x_closed_ind,
      x_report_all_hierarchy_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 11-FEB-2003
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

    DELETE FROM igs_he_ut_calc_type
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END delete_row;


END igs_he_ut_calc_type_pkg;

/
