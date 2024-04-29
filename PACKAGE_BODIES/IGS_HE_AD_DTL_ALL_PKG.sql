--------------------------------------------------------
--  DDL for Package Body IGS_HE_AD_DTL_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_AD_DTL_ALL_PKG" AS
/* $Header: IGSWI20B.pls 120.2 2005/07/03 18:32:47 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_ad_dtl_all%ROWTYPE;
  new_references igs_he_ad_dtl_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_org_id                            IN     NUMBER      ,
    x_hesa_ad_dtl_id                    IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_admission_appl_number             IN     NUMBER      ,
    x_nominated_course_cd               IN     VARCHAR2    ,
    x_sequence_number                   IN     NUMBER      ,
    x_occupation_cd                     IN     VARCHAR2    ,
    x_domicile_cd                       IN     VARCHAR2    ,
    x_social_class_cd                   IN     VARCHAR2    ,
    x_special_student_cd                IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 17-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_AD_DTL_ALL
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
    new_references.org_id                            := x_org_id;
    new_references.hesa_ad_dtl_id                    := x_hesa_ad_dtl_id;
    new_references.person_id                         := x_person_id;
    new_references.admission_appl_number             := x_admission_appl_number;
    new_references.nominated_course_cd               := x_nominated_course_cd;
    new_references.sequence_number                   := x_sequence_number;
    new_references.occupation_cd                     := x_occupation_cd;
    new_references.domicile_cd                       := x_domicile_cd;
    new_references.social_class_cd                   := x_social_class_cd;
    new_references.special_student_cd                := x_special_student_cd;

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
  ||  Created On : 17-JAN-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number) AND
         (old_references.nominated_course_cd = new_references.nominated_course_cd) AND
         (old_references.sequence_number = new_references.sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL) OR
         (new_references.nominated_course_cd IS NULL) OR
         (new_references.sequence_number IS NULL))) THEN
      NULL;

    ELSIF NOT igs_ad_ps_appl_inst_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.admission_appl_number,
                new_references.nominated_course_cd,
                new_references.sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_hesa_ad_dtl_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 17-JAN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_ad_dtl_all
      WHERE    hesa_ad_dtl_id = x_hesa_ad_dtl_id
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


  PROCEDURE get_fk_igs_ad_ps_appl_inst_all (
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 17-JAN-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_ad_dtl_all
      WHERE   ((admission_appl_number = x_admission_appl_number) AND
               (nominated_course_cd = x_nominated_course_cd) AND
               (person_id = x_person_id) AND
               (sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HAD_APAI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_ps_appl_inst_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_org_id                            IN     NUMBER      ,
    x_hesa_ad_dtl_id                    IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_admission_appl_number             IN     NUMBER      ,
    x_nominated_course_cd               IN     VARCHAR2    ,
    x_sequence_number                   IN     NUMBER      ,
    x_occupation_cd                     IN     VARCHAR2    ,
    x_domicile_cd                       IN     VARCHAR2    ,
    x_social_class_cd                   IN     VARCHAR2    ,
    x_special_student_cd                IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 17-JAN-2002
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
      x_org_id,
      x_hesa_ad_dtl_id,
      x_person_id,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_sequence_number,
      x_occupation_cd,
      x_domicile_cd,
      x_social_class_cd,
      x_special_student_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.hesa_ad_dtl_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.hesa_ad_dtl_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_hesa_ad_dtl_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_occupation_cd                     IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_social_class_cd                   IN     VARCHAR2,
    x_special_student_cd                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 17-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_ad_dtl_all
      WHERE    hesa_ad_dtl_id                    = x_hesa_ad_dtl_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
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

    SELECT    igs_he_ad_dtl_all_s.NEXTVAL
    INTO      x_hesa_ad_dtl_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_hesa_ad_dtl_id                    => x_hesa_ad_dtl_id,
      x_person_id                         => x_person_id,
      x_admission_appl_number             => x_admission_appl_number,
      x_nominated_course_cd               => x_nominated_course_cd,
      x_sequence_number                   => x_sequence_number,
      x_occupation_cd                     => x_occupation_cd,
      x_domicile_cd                       => x_domicile_cd,
      x_social_class_cd                   => x_social_class_cd,
      x_special_student_cd                => x_special_student_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_he_ad_dtl_all (
      org_id,
      hesa_ad_dtl_id,
      person_id,
      admission_appl_number,
      nominated_course_cd,
      sequence_number,
      occupation_cd,
      domicile_cd,
      social_class_cd,
      special_student_cd,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.org_id,
      new_references.hesa_ad_dtl_id,
      new_references.person_id,
      new_references.admission_appl_number,
      new_references.nominated_course_cd,
      new_references.sequence_number,
      new_references.occupation_cd,
      new_references.domicile_cd,
      new_references.social_class_cd,
      new_references.special_student_cd,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_hesa_ad_dtl_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_occupation_cd                     IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_social_class_cd                   IN     VARCHAR2,
    x_special_student_cd                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 17-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smvk	     13-Feb-2002      Removed org_id from cursor
  ||				      declaration and conditional checking
  ||				      w.r.t. SWCR006
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        admission_appl_number,
        nominated_course_cd,
        sequence_number,
        occupation_cd,
        domicile_cd,
        social_class_cd,
        special_student_cd
      FROM  igs_he_ad_dtl_all
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
        AND (tlinfo.admission_appl_number = x_admission_appl_number)
        AND (tlinfo.nominated_course_cd = x_nominated_course_cd)
        AND (tlinfo.sequence_number = x_sequence_number)
        AND ((tlinfo.occupation_cd = x_occupation_cd) OR ((tlinfo.occupation_cd IS NULL) AND (X_occupation_cd IS NULL)))
        AND ((tlinfo.domicile_cd = x_domicile_cd) OR ((tlinfo.domicile_cd IS NULL) AND (X_domicile_cd IS NULL)))
        AND ((tlinfo.social_class_cd = x_social_class_cd) OR ((tlinfo.social_class_cd IS NULL) AND (X_social_class_cd IS NULL)))
        AND ((tlinfo.special_student_cd = x_special_student_cd) OR ((tlinfo.special_student_cd IS NULL) AND (X_special_student_cd IS NULL)))
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
    x_org_id                            IN     NUMBER,
    x_hesa_ad_dtl_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_occupation_cd                     IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_social_class_cd                   IN     VARCHAR2,
    x_special_student_cd                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 17-JAN-2002
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
    ELSIF (X_MODE IN ('R', 'S')) THEN
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
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_hesa_ad_dtl_id                    => x_hesa_ad_dtl_id,
      x_person_id                         => x_person_id,
      x_admission_appl_number             => x_admission_appl_number,
      x_nominated_course_cd               => x_nominated_course_cd,
      x_sequence_number                   => x_sequence_number,
      x_occupation_cd                     => x_occupation_cd,
      x_domicile_cd                       => x_domicile_cd,
      x_social_class_cd                   => x_social_class_cd,
      x_special_student_cd                => x_special_student_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_he_ad_dtl_all
      SET
        person_id                         = new_references.person_id,
        admission_appl_number             = new_references.admission_appl_number,
        nominated_course_cd               = new_references.nominated_course_cd,
        sequence_number                   = new_references.sequence_number,
        occupation_cd                     = new_references.occupation_cd,
        domicile_cd                       = new_references.domicile_cd,
        social_class_cd                   = new_references.social_class_cd,
        special_student_cd                = new_references.special_student_cd,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE = (-28115)) THEN
        fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
        fnd_message.set_token ('ERR_CD', SQLCODE);
        igs_ge_msg_stack.add;
        igs_sc_gen_001.unset_ctx('R');
        app_exception.raise_exception;
      ELSE
        igs_sc_gen_001.unset_ctx('R');
        RAISE;
      END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_hesa_ad_dtl_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_occupation_cd                     IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_social_class_cd                   IN     VARCHAR2,
    x_special_student_cd                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 17-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_ad_dtl_all
      WHERE    hesa_ad_dtl_id                    = x_hesa_ad_dtl_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_org_id,
        x_hesa_ad_dtl_id,
        x_person_id,
        x_admission_appl_number,
        x_nominated_course_cd,
        x_sequence_number,
        x_occupation_cd,
        x_domicile_cd,
        x_social_class_cd,
        x_special_student_cd,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_org_id,
      x_hesa_ad_dtl_id,
      x_person_id,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_sequence_number,
      x_occupation_cd,
      x_domicile_cd,
      x_social_class_cd,
      x_special_student_cd,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 17-JAN-2002
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

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_he_ad_dtl_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  END delete_row;


END igs_he_ad_dtl_all_pkg;

/
