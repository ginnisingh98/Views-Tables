--------------------------------------------------------
--  DDL for Package Body IGS_UC_COM_SCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_COM_SCH_PKG" AS
/* $Header: IGSXI10B.pls 115.9 2003/08/13 09:51:51 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_com_sch%ROWTYPE;
  new_references igs_uc_com_sch%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER  ,
    x_school_name                       IN     VARCHAR2,
    x_name_change_date                  IN     DATE    ,
    x_former_name                       IN     VARCHAR2,
    x_ncn                               IN     VARCHAR2,
    x_edexcel_ncn                       IN     VARCHAR2,
    x_dfee_code                         IN     VARCHAR2,
    x_country                           IN     NUMBER  ,
    x_lea                               IN     VARCHAR2,
    x_ucas_status                       IN     VARCHAR2,
    x_estab_group                       IN     VARCHAR2,
    x_school_type                       IN     VARCHAR2,
    x_stats_date                        IN     DATE    ,
    x_number_on_roll                    IN     NUMBER  ,
    x_number_in_5_form                  IN     NUMBER  ,
    x_number_in_6_form                  IN     NUMBER  ,
    x_number_to_he                      IN     NUMBER  ,
    x_imported                          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_COM_SCH
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
    new_references.school                            := x_school;
    new_references.school_name                       := x_school_name;
    new_references.name_change_date                  := x_name_change_date;
    new_references.former_name                       := x_former_name;
    new_references.ncn                               := x_ncn;
    new_references.edexcel_ncn                       := x_edexcel_ncn;
    new_references.dfee_code                         := x_dfee_code;
    new_references.country                           := x_country;
    new_references.lea                               := x_lea;
    new_references.ucas_status                       := x_ucas_status;
    new_references.estab_group                       := x_estab_group;
    new_references.school_type                       := x_school_type;
    new_references.stats_date                        := x_stats_date;
    new_references.number_on_roll                    := x_number_on_roll;
    new_references.number_in_5_form                  := x_number_in_5_form;
    new_references.number_in_6_form                  := x_number_in_6_form;
    new_references.number_to_he                      := x_number_to_he;
    new_references.imported                          := x_imported;

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


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_uc_com_schsites_pkg.get_fk_igs_uc_com_sch (
      old_references.school
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_school                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_com_sch
      WHERE    school = x_school ;

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

 PROCEDURE check_parent_existance AS
  /*
  ||  Created By : rbezawad
  ||  Created On : 17-DEC-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.country = new_references.country)) OR
        ((new_references.country IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_ref_apr_pkg.get_pk_for_validation (
                new_references.country
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE get_fk_igs_uc_ref_apr (
    x_country    IN   NUMBER
  ) AS
  /*
  ||  Created By : RBEZAWAD
  ||  Created On : 17-DEC-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_com_sch
      WHERE   ((country = x_country));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCCH_UCRA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_ref_apr;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_school                            IN     NUMBER  ,
    x_school_name                       IN     VARCHAR2,
    x_name_change_date                  IN     DATE    ,
    x_former_name                       IN     VARCHAR2,
    x_ncn                               IN     VARCHAR2,
    x_edexcel_ncn                       IN     VARCHAR2,
    x_dfee_code                         IN     VARCHAR2,
    x_country                           IN     NUMBER  ,
    x_lea                               IN     VARCHAR2,
    x_ucas_status                       IN     VARCHAR2,
    x_estab_group                       IN     VARCHAR2,
    x_school_type                       IN     VARCHAR2,
    x_stats_date                        IN     DATE    ,
    x_number_on_roll                    IN     NUMBER  ,
    x_number_in_5_form                  IN     NUMBER  ,
    x_number_in_6_form                  IN     NUMBER  ,
    x_number_to_he                      IN     NUMBER  ,
    x_imported                          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_school,
      x_school_name,
      x_name_change_date,
      x_former_name,
      x_ncn,
      x_edexcel_ncn,
      x_dfee_code,
      x_country,
      x_lea,
      x_ucas_status,
      x_estab_group,
      x_school_type,
      x_stats_date,
      x_number_on_roll,
      x_number_in_5_form,
      x_number_in_6_form,
      x_number_to_he,
      x_imported,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.school
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
     -- Call all the procedures related to Before Update
     check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.school
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_school                            IN OUT NOCOPY NUMBER,
    x_school_name                       IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_former_name                       IN     VARCHAR2,
    x_ncn                               IN     VARCHAR2,
    x_edexcel_ncn                       IN     VARCHAR2,
    x_dfee_code                         IN     VARCHAR2,
    x_country                           IN     NUMBER,
    x_lea                               IN     VARCHAR2,
    x_ucas_status                       IN     VARCHAR2,
    x_estab_group                       IN     VARCHAR2,
    x_school_type                       IN     VARCHAR2,
    x_stats_date                        IN     DATE,
    x_number_on_roll                    IN     NUMBER,
    x_number_in_5_form                  IN     NUMBER,
    x_number_in_6_form                  IN     NUMBER,
    x_number_to_he                      IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_com_sch
      WHERE    school                            = x_school;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_school                            => x_school,
      x_school_name                       => x_school_name,
      x_name_change_date                  => x_name_change_date,
      x_former_name                       => x_former_name,
      x_ncn                               => x_ncn,
      x_edexcel_ncn                       => x_edexcel_ncn,
      x_dfee_code                         => x_dfee_code,
      x_country                           => x_country,
      x_lea                               => x_lea,
      x_ucas_status                       => x_ucas_status,
      x_estab_group                       => x_estab_group,
      x_school_type                       => x_school_type,
      x_stats_date                        => x_stats_date,
      x_number_on_roll                    => x_number_on_roll,
      x_number_in_5_form                  => x_number_in_5_form,
      x_number_in_6_form                  => x_number_in_6_form,
      x_number_to_he                      => x_number_to_he,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_com_sch (
      school,
      school_name,
      name_change_date,
      former_name,
      ncn,
      edexcel_ncn,
      dfee_code,
      country,
      lea,
      ucas_status,
      estab_group,
      school_type,
      stats_date,
      number_on_roll,
      number_in_5_form,
      number_in_6_form,
      number_to_he,
      imported,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.school,
      new_references.school_name,
      new_references.name_change_date,
      new_references.former_name,
      new_references.ncn,
      new_references.edexcel_ncn,
      new_references.dfee_code,
      new_references.country,
      new_references.lea,
      new_references.ucas_status,
      new_references.estab_group,
      new_references.school_type,
      new_references.stats_date,
      new_references.number_on_roll,
      new_references.number_in_5_form,
      new_references.number_in_6_form,
      new_references.number_to_he,
      new_references.imported,
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
    x_school                            IN     NUMBER,
    x_school_name                       IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_former_name                       IN     VARCHAR2,
    x_ncn                               IN     VARCHAR2,
    x_edexcel_ncn                       IN     VARCHAR2,
    x_dfee_code                         IN     VARCHAR2,
    x_country                           IN     NUMBER,
    x_lea                               IN     VARCHAR2,
    x_ucas_status                       IN     VARCHAR2,
    x_estab_group                       IN     VARCHAR2,
    x_school_type                       IN     VARCHAR2,
    x_stats_date                        IN     DATE,
    x_number_on_roll                    IN     NUMBER,
    x_number_in_5_form                  IN     NUMBER,
    x_number_in_6_form                  IN     NUMBER,
    x_number_to_he                      IN     NUMBER,
    x_imported                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  (reverse chronological order - newest change first)
  ||  Who       When            What
  ||  rbezawad  26-Dec-2002     Modified Lock_row() procedure as the 5 columns STATS_DATE,NUMBER_ON_ROLL, NUMBER_IN_5_FORM,
  ||                            NUMBER_IN_6_FORM, NUMBER_TO_HE are made as Non-Mandatory w.r.t. Bug 2708703.
  || smaddali  10-jun-03        obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
  || smaddali  13-aug-03    Modified copmarision of old and new values for stats_date for bug#3091973
  */
    CURSOR c1 IS
      SELECT
        school_name,
        name_change_date,
        former_name,
        ncn,
        edexcel_ncn,
        dfee_code,
        country,
        lea,
        ucas_status,
        estab_group,
        school_type,
        stats_date,
        number_on_roll,
        number_in_5_form,
        number_in_6_form,
        number_to_he,
        imported
      FROM  igs_uc_com_sch
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
    -- smaddali corrected typo in comparision of stats_date , it was comparing with ucas_status instead of stats_date, bug#3091973
    IF (
        ((tlinfo.school_name = x_school_name) OR ((tlinfo.school_name IS NULL) AND (X_school_name IS NULL)))
        AND ((tlinfo.name_change_date = x_name_change_date) OR ((tlinfo.name_change_date IS NULL) AND (X_name_change_date IS NULL)))
        AND ((tlinfo.former_name = x_former_name) OR ((tlinfo.former_name IS NULL) AND (X_former_name IS NULL)))
        AND ((tlinfo.ncn = x_ncn) OR ((tlinfo.ncn IS NULL) AND (X_ncn IS NULL)))
        AND ((tlinfo.edexcel_ncn = x_edexcel_ncn) OR ((tlinfo.edexcel_ncn IS NULL) AND (X_edexcel_ncn IS NULL)))
        AND ((tlinfo.dfee_code = x_dfee_code) OR ((tlinfo.dfee_code IS NULL) AND (X_dfee_code IS NULL)))
        AND ((tlinfo.country = x_country) OR ((tlinfo.country IS NULL) AND (X_country IS NULL)))
        AND ((tlinfo.lea = x_lea) OR ((tlinfo.lea IS NULL) AND (X_lea IS NULL)))
        AND ((tlinfo.ucas_status = x_ucas_status) OR ((tlinfo.ucas_status IS NULL) AND (X_ucas_status IS NULL)))
        AND (tlinfo.estab_group = x_estab_group)
        AND (tlinfo.school_type = x_school_type)
	AND ((tlinfo.stats_date = x_stats_date) OR ((tlinfo.stats_date IS NULL) AND (x_stats_date IS NULL)))
        AND ((tlinfo.number_on_roll = x_number_on_roll) OR ((tlinfo.number_on_roll IS NULL) AND (x_number_on_roll IS NULL)))
        AND ((tlinfo.number_in_5_form = x_number_in_5_form) OR ((tlinfo.number_in_5_form IS NULL) AND (x_number_in_5_form IS NULL)))
        AND ((tlinfo.number_in_6_form = x_number_in_6_form) OR ((tlinfo.number_in_6_form IS NULL) AND (x_number_in_6_form IS NULL)))
        AND ((tlinfo.number_to_he = x_number_to_he) OR ((tlinfo.number_to_he IS NULL) AND (x_number_to_he IS NULL)))
        AND (tlinfo.imported = x_imported)
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
    x_school                            IN     NUMBER,
    x_school_name                       IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_former_name                       IN     VARCHAR2,
    x_ncn                               IN     VARCHAR2,
    x_edexcel_ncn                       IN     VARCHAR2,
    x_dfee_code                         IN     VARCHAR2,
    x_country                           IN     NUMBER,
    x_lea                               IN     VARCHAR2,
    x_ucas_status                       IN     VARCHAR2,
    x_estab_group                       IN     VARCHAR2,
    x_school_type                       IN     VARCHAR2,
    x_stats_date                        IN     DATE,
    x_number_on_roll                    IN     NUMBER,
    x_number_in_5_form                  IN     NUMBER,
    x_number_in_6_form                  IN     NUMBER,
    x_number_to_he                      IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
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
      x_school                            => x_school,
      x_school_name                       => x_school_name,
      x_name_change_date                  => x_name_change_date,
      x_former_name                       => x_former_name,
      x_ncn                               => x_ncn,
      x_edexcel_ncn                       => x_edexcel_ncn,
      x_dfee_code                         => x_dfee_code,
      x_country                           => x_country,
      x_lea                               => x_lea,
      x_ucas_status                       => x_ucas_status,
      x_estab_group                       => x_estab_group,
      x_school_type                       => x_school_type,
      x_stats_date                        => x_stats_date,
      x_number_on_roll                    => x_number_on_roll,
      x_number_in_5_form                  => x_number_in_5_form,
      x_number_in_6_form                  => x_number_in_6_form,
      x_number_to_he                      => x_number_to_he,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_com_sch
      SET
        school_name                       = new_references.school_name,
        name_change_date                  = new_references.name_change_date,
        former_name                       = new_references.former_name,
        ncn                               = new_references.ncn,
        edexcel_ncn                       = new_references.edexcel_ncn,
        dfee_code                         = new_references.dfee_code,
        country                           = new_references.country,
        lea                               = new_references.lea,
        ucas_status                       = new_references.ucas_status,
        estab_group                       = new_references.estab_group,
        school_type                       = new_references.school_type,
        stats_date                        = new_references.stats_date,
        number_on_roll                    = new_references.number_on_roll,
        number_in_5_form                  = new_references.number_in_5_form,
        number_in_6_form                  = new_references.number_in_6_form,
        number_to_he                      = new_references.number_to_he,
        imported                          = new_references.imported,
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
    x_school                            IN OUT NOCOPY NUMBER,
    x_school_name                       IN     VARCHAR2,
    x_name_change_date                  IN     DATE,
    x_former_name                       IN     VARCHAR2,
    x_ncn                               IN     VARCHAR2,
    x_edexcel_ncn                       IN     VARCHAR2,
    x_dfee_code                         IN     VARCHAR2,
    x_country                           IN     NUMBER,
    x_lea                               IN     VARCHAR2,
    x_ucas_status                       IN     VARCHAR2,
    x_estab_group                       IN     VARCHAR2,
    x_school_type                       IN     VARCHAR2,
    x_stats_date                        IN     DATE,
    x_number_on_roll                    IN     NUMBER,
    x_number_in_5_form                  IN     NUMBER,
    x_number_in_6_form                  IN     NUMBER,
    x_number_to_he                      IN     NUMBER,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  10-jun-03    obsoleting timestamp column for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_com_sch
      WHERE    school                            = x_school;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_school,
        x_school_name,
        x_name_change_date,
        x_former_name,
        x_ncn,
        x_edexcel_ncn,
        x_dfee_code,
        x_country,
        x_lea,
        x_ucas_status,
        x_estab_group,
        x_school_type,
        x_stats_date,
        x_number_on_roll,
        x_number_in_5_form,
        x_number_in_6_form,
        x_number_to_he,
        x_imported,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_school,
      x_school_name,
      x_name_change_date,
      x_former_name,
      x_ncn,
      x_edexcel_ncn,
      x_dfee_code,
      x_country,
      x_lea,
      x_ucas_status,
      x_estab_group,
      x_school_type,
      x_stats_date,
      x_number_on_roll,
      x_number_in_5_form,
      x_number_in_6_form,
      x_number_to_he,
      x_imported,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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

    DELETE FROM igs_uc_com_sch
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_com_sch_pkg;

/
