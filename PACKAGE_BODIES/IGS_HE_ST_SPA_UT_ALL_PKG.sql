--------------------------------------------------------
--  DDL for Package Body IGS_HE_ST_SPA_UT_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_ST_SPA_UT_ALL_PKG" AS
/* $Header: IGSWI23B.pls 115.8 2002/11/29 04:40:51 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_st_spa_ut_all%ROWTYPE;
  new_references igs_he_st_spa_ut_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_st_spau_id                   IN     NUMBER      ,
    x_org_id                            IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_version_number                    IN     NUMBER      ,
    x_qualification_level               IN     VARCHAR2    ,
    x_number_of_qual                    IN     NUMBER      ,
    x_tariff_score                      IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_ST_SPA_UT_ALL
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
    new_references.hesa_st_spau_id                   := x_hesa_st_spau_id;
    new_references.org_id                            := x_org_id;
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.version_number                    := x_version_number;
    new_references.qualification_level               := x_qualification_level;
    new_references.number_of_qual                    := x_number_of_qual;
    new_references.tariff_score                      := x_tariff_score;

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
           new_references.person_id,
           new_references.course_cd,
           new_references.qualification_level
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
  || smaddali 7-nov-2002 replaced igs_he_st_spa_all_pkg.get_uk_for_validation
  || call with cursor as part of build bug 2641273
  ||  (reverse chronological order - newest change first)
  */

   -- smaddali added this cursor to check if parent record exists or not
   -- as part of build bug 2641273
   l_rowid VARCHAR2(100) ;
   CURSOR c_check_parent IS
   SELECT rowid
   FROM igs_he_st_spa_all
   WHERE person_id =  new_references.person_id AND
         course_cd =   new_references.course_cd ;

  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      -- smaddali replaced igs_he_st_spa_all_pkg.get_uk_for_validation call
      -- with cursor because this call was giving wrong results
      OPEN c_check_parent ;
      FETCH c_check_parent INTO l_rowid ;
      IF c_check_parent%NOTFOUND THEN
            CLOSE c_check_parent ;
            fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
             igs_ge_msg_stack.add;
            app_exception.raise_exception;
      ELSE
          CLOSE c_check_parent ;
      END IF ;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_hesa_st_spau_id                   IN     NUMBER
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
      FROM     igs_he_st_spa_ut_all
      WHERE    hesa_st_spau_id = x_hesa_st_spau_id
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_qualification_level               IN     VARCHAR2
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
      FROM     igs_he_st_spa_ut_all
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      ((qualification_level = x_qualification_level) OR (qualification_level IS NULL AND x_qualification_level IS NULL))
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


  PROCEDURE get_ufk_igs_he_st_spa_all (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
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
      FROM     igs_he_st_spa_ut_all
      WHERE   ((course_cd = x_course_cd) AND
               (person_id = x_person_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HSPAU_HSPA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_he_st_spa_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_st_spau_id                   IN     NUMBER      ,
    x_org_id                            IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_version_number                    IN     NUMBER      ,
    x_qualification_level               IN     VARCHAR2    ,
    x_number_of_qual                    IN     NUMBER      ,
    x_tariff_score                      IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
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
      x_hesa_st_spau_id,
      x_org_id,
      x_person_id,
      x_course_cd,
      x_version_number,
      x_qualification_level,
      x_number_of_qual,
      x_tariff_score,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.hesa_st_spau_id
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
             new_references.hesa_st_spau_id
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
    x_hesa_st_spau_id                   IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_qualification_level               IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smvk	      13-Feb-2002     Call to igs_ge_gen_003.get_org_id
  ||				      w.r.t. SWCR006
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_st_spa_ut_all
      WHERE    hesa_st_spau_id                   = x_hesa_st_spau_id;

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

    SELECT    igs_he_st_spa_ut_all_s.NEXTVAL
    INTO      x_hesa_st_spau_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_hesa_st_spau_id                   => x_hesa_st_spau_id,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_qualification_level               => x_qualification_level,
      x_number_of_qual                    => x_number_of_qual,
      x_tariff_score                      => x_tariff_score,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_st_spa_ut_all (
      hesa_st_spau_id,
      org_id,
      person_id,
      course_cd,
      version_number,
      qualification_level,
      number_of_qual,
      tariff_score,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.hesa_st_spau_id,
      new_references.org_id,
      new_references.person_id,
      new_references.course_cd,
      new_references.version_number,
      new_references.qualification_level,
      new_references.number_of_qual,
      new_references.tariff_score,
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
    x_hesa_st_spau_id                   IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_qualification_level               IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smvk	      13-Feb-2002     Removed org_id from cursor declaration
  ||				      and conditional checking w.r.t.SWCR006
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        course_cd,
        version_number,
        qualification_level,
        number_of_qual,
        tariff_score
      FROM  igs_he_st_spa_ut_all
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
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.course_cd = x_course_cd)
        AND ((tlinfo.version_number = x_version_number) OR ((tlinfo.version_number IS NULL) AND (X_version_number IS NULL)))
        AND ((tlinfo.qualification_level = x_qualification_level) OR ((tlinfo.qualification_level IS NULL) AND (X_qualification_level IS NULL)))
        AND ((tlinfo.number_of_qual = x_number_of_qual) OR ((tlinfo.number_of_qual IS NULL) AND (X_number_of_qual IS NULL)))
        AND ((tlinfo.tariff_score = x_tariff_score) OR ((tlinfo.tariff_score IS NULL) AND (X_tariff_score IS NULL)))
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
    x_hesa_st_spau_id                   IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_qualification_level               IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smvk	      13-Feb-2002     Call to igs_ge_gen_003.get_org_id
  ||				      w.r.t. SWCR006
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
      x_hesa_st_spau_id                   => x_hesa_st_spau_id,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_qualification_level               => x_qualification_level,
      x_number_of_qual                    => x_number_of_qual,
      x_tariff_score                      => x_tariff_score,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_st_spa_ut_all
      SET
        person_id                         = new_references.person_id,
        course_cd                         = new_references.course_cd,
        version_number                    = new_references.version_number,
        qualification_level               = new_references.qualification_level,
        number_of_qual                    = new_references.number_of_qual,
        tariff_score                      = new_references.tariff_score,
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
    x_hesa_st_spau_id                   IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_qualification_level               IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_st_spa_ut_all
      WHERE    hesa_st_spau_id                   = x_hesa_st_spau_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_hesa_st_spau_id,
        x_org_id,
        x_person_id,
        x_course_cd,
        x_version_number,
        x_qualification_level,
        x_number_of_qual,
        x_tariff_score,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_hesa_st_spau_id,
      x_org_id,
      x_person_id,
      x_course_cd,
      x_version_number,
      x_qualification_level,
      x_number_of_qual,
      x_tariff_score,
      x_mode
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

    DELETE FROM igs_he_st_spa_ut_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_st_spa_ut_all_pkg;

/
