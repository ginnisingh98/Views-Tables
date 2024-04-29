--------------------------------------------------------
--  DDL for Package Body IGS_HE_ST_UNT_VS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_ST_UNT_VS_ALL_PKG" AS
/* $Header: IGSWI24B.pls 120.1 2006/02/06 19:53:52 jbaber noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_st_unt_vs_all%ROWTYPE;
  new_references igs_he_st_unt_vs_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_st_unt_vs_id                 IN     NUMBER      ,
    x_org_id                            IN     NUMBER      ,
    x_unit_cd                           IN     VARCHAR2    ,
    x_version_number                    IN     NUMBER      ,
    x_prop_of_teaching_in_welsh         IN     NUMBER      ,
    x_credit_transfer_scheme            IN     VARCHAR2    ,
    x_module_length                     IN     NUMBER      ,
    x_proportion_of_fte                 IN     NUMBER      ,
    x_location_cd                       IN     VARCHAR2   ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga       8-apr-2002     Added a parameter x_location_cd as part of #2278825
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_ST_UNT_VS_ALL
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
    new_references.hesa_st_unt_vs_id                 := x_hesa_st_unt_vs_id;
    new_references.org_id                            := x_org_id;
    new_references.unit_cd                           := x_unit_cd;
    new_references.version_number                    := x_version_number;
    new_references.prop_of_teaching_in_welsh         := x_prop_of_teaching_in_welsh;
    new_references.credit_transfer_scheme            := x_credit_transfer_scheme;
    new_references.module_length                     := x_module_length;
    new_references.proportion_of_fte                 := x_proportion_of_fte;
    new_references.location_cd                       := x_location_cd;
    new_references.exclude_flag                      := x_exclude_flag;

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
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.unit_cd,
           new_references.version_number
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ver_pkg.get_pk_for_validation (
                new_references.unit_cd,
                new_references.version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_hesa_st_unt_vs_id                 IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_st_unt_vs_all
      WHERE    hesa_st_unt_vs_id = x_hesa_st_unt_vs_id
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
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_st_unt_vs_all
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

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


  PROCEDURE get_fk_igs_ps_unit_ver_all (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_st_unt_vs_all
      WHERE   ((unit_cd = x_unit_cd) AND
               (version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HSUV_UV_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_unit_ver_all;

  PROCEDURE check_unit_attempt_exists AS
    CURSOR cur_unit_attempt(cp_unit_cd  igs_en_su_attempt.course_cd%TYPE,
                            cp_version  igs_en_su_attempt.version_number%TYPE
                            ) IS
    SELECT 'X' FROM igs_en_su_attempt
    WHERE unit_cd      =   cp_unit_cd
      AND version_number = cp_version;

      l_unit_attempt VARCHAR2(1);

  BEGIN
     -- Check whether any SUA exists
     OPEN cur_unit_attempt(new_references.unit_cd,
                           new_references.version_number);
     FETCH cur_unit_attempt INTO l_unit_attempt;
     IF cur_unit_attempt%FOUND THEN
        CLOSE cur_unit_attempt;
        fnd_message.set_name ('IGS', 'IGS_HE_CANT_DEL_SUA_EXIST');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
        RETURN;
     END IF;
     CLOSE cur_unit_attempt;

  END check_unit_attempt_exists;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_st_unt_vs_id                 IN     NUMBER      ,
    x_org_id                            IN     NUMBER      ,
    x_unit_cd                           IN     VARCHAR2    ,
    x_version_number                    IN     NUMBER      ,
    x_prop_of_teaching_in_welsh         IN     NUMBER      ,
    x_credit_transfer_scheme            IN     VARCHAR2    ,
    x_module_length                     IN     NUMBER      ,
    x_proportion_of_fte                 IN     NUMBER      ,
    x_location_cd                       IN     VARCHAR2   ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga      8-Apr-2002    Added a parameter x_location_cd as aprt of #2278825
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_hesa_st_unt_vs_id,
      x_org_id,
      x_unit_cd,
      x_version_number,
      x_prop_of_teaching_in_welsh,
      x_credit_transfer_scheme,
      x_module_length,
      x_proportion_of_fte,
      x_location_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_exclude_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.hesa_st_unt_vs_id
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
    ELSIF (p_action = 'DELETE') THEN
      check_unit_attempt_exists;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.hesa_st_unt_vs_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
       check_unit_attempt_exists;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_st_unt_vs_id                 IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_prop_of_teaching_in_welsh         IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_module_length                     IN     NUMBER,
    x_proportion_of_fte                 IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga         8-Apr-2002     Added a parameter x_location_cd as part of #2278825
  ||  smvk           13-Feb-2002     Call to igs_ge_gen_003.get_org_id
  ||                                 w.r.t. SWCR006
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_st_unt_vs_all
      WHERE    hesa_st_unt_vs_id                 = x_hesa_st_unt_vs_id;

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

    SELECT    igs_he_st_unt_vs_all_s.NEXTVAL
    INTO      x_hesa_st_unt_vs_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_hesa_st_unt_vs_id                 => x_hesa_st_unt_vs_id,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_unit_cd                           => x_unit_cd,
      x_version_number                    => x_version_number,
      x_prop_of_teaching_in_welsh         => x_prop_of_teaching_in_welsh,
      x_credit_transfer_scheme            => x_credit_transfer_scheme,
      x_module_length                     => x_module_length,
      x_proportion_of_fte                 => x_proportion_of_fte,
      x_location_cd                       => x_location_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_exclude_flag                      => x_exclude_flag
    );

    INSERT INTO igs_he_st_unt_vs_all (
      hesa_st_unt_vs_id,
      org_id,
      unit_cd,
      version_number,
      prop_of_teaching_in_welsh,
      credit_transfer_scheme,
      module_length,
      proportion_of_fte,
      location_cd,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      exclude_flag
    ) VALUES (
      new_references.hesa_st_unt_vs_id,
      new_references.org_id,
      new_references.unit_cd,
      new_references.version_number,
      new_references.prop_of_teaching_in_welsh,
      new_references.credit_transfer_scheme,
      new_references.module_length,
      new_references.proportion_of_fte,
      new_references.location_cd,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.exclude_flag
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
    x_hesa_st_unt_vs_id                 IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_prop_of_teaching_in_welsh         IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_module_length                     IN     NUMBER,
    x_proportion_of_fte                 IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga       8-Apr-2002       Added a parameter x_location_cd as part of #2278825
  ||  smvk            13-Feb-2002     Removed org_id from cursor declaration
  ||                                  and conditional checking w.r.t.SWCR006
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        unit_cd,
        version_number,
        prop_of_teaching_in_welsh,
        credit_transfer_scheme,
        module_length,
        proportion_of_fte,
        location_cd,
        exclude_flag
      FROM  igs_he_st_unt_vs_all
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
        (tlinfo.unit_cd = x_unit_cd)
        AND (tlinfo.version_number = x_version_number)
        AND ((tlinfo.prop_of_teaching_in_welsh = x_prop_of_teaching_in_welsh) OR ((tlinfo.prop_of_teaching_in_welsh IS NULL) AND (X_prop_of_teaching_in_welsh IS NULL)))
        AND ((tlinfo.credit_transfer_scheme = x_credit_transfer_scheme) OR ((tlinfo.credit_transfer_scheme IS NULL) AND (X_credit_transfer_scheme IS NULL)))
        AND ((tlinfo.module_length = x_module_length) OR ((tlinfo.module_length IS NULL) AND (X_module_length IS NULL)))
        AND ((tlinfo.proportion_of_fte = x_proportion_of_fte) OR ((tlinfo.proportion_of_fte IS NULL) AND (X_proportion_of_fte IS NULL)))
        AND ((tlinfo.location_cd = x_location_cd) OR ((tlinfo.location_cd IS NULL) AND (X_location_cd IS NULL)))
        AND ((tlinfo.exclude_flag = x_exclude_flag) OR ((tlinfo.exclude_flag IS NULL) AND (X_exclude_flag IS NULL)))
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
    x_hesa_st_unt_vs_id                 IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_prop_of_teaching_in_welsh         IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_module_length                     IN     NUMBER,
    x_proportion_of_fte                 IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga         8-Apr-2002         Added parameter x_location_cd as part of #2278825
  ||  smvk            13-Feb-2002     Call to igs_ge_gen_003.get_org_id
  ||                                  w.r.t  SWCR006
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
      x_hesa_st_unt_vs_id                 => x_hesa_st_unt_vs_id,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_unit_cd                           => x_unit_cd,
      x_version_number                    => x_version_number,
      x_prop_of_teaching_in_welsh         => x_prop_of_teaching_in_welsh,
      x_credit_transfer_scheme            => x_credit_transfer_scheme,
      x_module_length                     => x_module_length,
      x_proportion_of_fte                 => x_proportion_of_fte,
      x_location_cd                       => x_location_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_exclude_flag                      => x_exclude_flag
    );

    UPDATE igs_he_st_unt_vs_all
      SET
        unit_cd                           = new_references.unit_cd,
        version_number                    = new_references.version_number,
        prop_of_teaching_in_welsh         = new_references.prop_of_teaching_in_welsh,
        credit_transfer_scheme            = new_references.credit_transfer_scheme,
        module_length                     = new_references.module_length,
        proportion_of_fte                 = new_references.proportion_of_fte,
        location_cd                       = new_references.location_cd,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        exclude_flag                      = new_references.exclude_flag
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_st_unt_vs_id                 IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_prop_of_teaching_in_welsh         IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_module_length                     IN     NUMBER,
    x_proportion_of_fte                 IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||sbaliga       8-Apr-2002    Added a parameter x_location_cd as part of #2278825
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_st_unt_vs_all
      WHERE    hesa_st_unt_vs_id                 = x_hesa_st_unt_vs_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_hesa_st_unt_vs_id,
        x_org_id,
        x_unit_cd,
        x_version_number,
        x_prop_of_teaching_in_welsh,
        x_credit_transfer_scheme,
        x_module_length,
        x_proportion_of_fte,
        x_location_cd,
        x_mode,
        x_exclude_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_hesa_st_unt_vs_id,
      x_org_id,
      x_unit_cd,
      x_version_number,
      x_prop_of_teaching_in_welsh,
      x_credit_transfer_scheme,
      x_module_length,
      x_proportion_of_fte,
      x_location_cd,
      x_mode,
      x_exclude_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
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

    DELETE FROM igs_he_st_unt_vs_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_st_unt_vs_all_pkg;

/
