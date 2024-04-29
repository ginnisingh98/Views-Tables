--------------------------------------------------------
--  DDL for Package Body IGF_AP_MATCH_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_MATCH_DETAILS_PKG" AS
/* $Header: IGFAI38B.pls 120.0 2005/06/02 15:55:31 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_ap_match_details%ROWTYPE;
  new_references igf_ap_match_details%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2 ,
    x_rowid                             IN     VARCHAR2 ,
    x_amd_id                            IN     NUMBER   ,
    x_apm_id                            IN     NUMBER   ,
    x_person_id                         IN     NUMBER   ,
    x_ssn_match                         IN     NUMBER   ,
    x_given_name_match                  IN     NUMBER   ,
    x_surname_match                     IN     NUMBER   ,
    x_dob_match                         IN     NUMBER   ,
    x_address_match                     IN     NUMBER   ,
    x_city_match                        IN     NUMBER   ,
    x_zip_match                         IN     NUMBER   ,
    x_match_score                       IN     NUMBER   ,
    x_record_status                     IN     VARCHAR2 ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER   ,
    x_ssn_txt                           IN     VARCHAR2 ,
    x_given_name_txt                    IN     VARCHAR2 ,
    x_sur_name_txt                      IN     VARCHAR2 ,
    x_birth_date                        IN     DATE     ,
    x_address_txt                       IN     VARCHAR2 ,
    x_city_txt                          IN     VARCHAR2 ,
    x_zip_txt                           IN     VARCHAR2 ,
    x_gender_txt                        IN     VARCHAR2 ,
    x_email_id_txt                      IN     VARCHAR2 ,
    x_email_id_match                    IN     NUMBER   ,
    x_gender_match                      IN     NUMBER
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 03-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AP_MATCH_DETAILS
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
    new_references.amd_id                            := x_amd_id;
    new_references.apm_id                            := x_apm_id;
    new_references.person_id                         := x_person_id;
    new_references.ssn_match                         := x_ssn_match;
    new_references.given_name_match                  := x_given_name_match;
    new_references.surname_match                     := x_surname_match;
    new_references.dob_match                         := x_dob_match;
    new_references.address_match                     := x_address_match;
    new_references.city_match                        := x_city_match;
    new_references.zip_match                         := x_zip_match;
    new_references.match_score                       := x_match_score;
    new_references.record_status                     := x_record_status;

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

    new_references.ssn_txt                           := x_ssn_txt;
    new_references.given_name_txt                    := x_given_name_txt;
    new_references.sur_name_txt                      := x_sur_name_txt;
    new_references.birth_date                        := x_birth_date;
    new_references.address_txt                       := x_address_txt;
    new_references.city_txt                          := x_city_txt;
    new_references.zip_txt                           := x_zip_txt;
    new_references.gender_txt                        := x_gender_txt;
    new_references.email_id_txt                      := x_email_id_txt;
    new_references.email_id_match                    := x_email_id_match;
    new_references.gender_match                      := x_gender_match;

  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 03-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.apm_id = new_references.apm_id)) OR
        ((new_references.apm_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_ap_person_match_pkg.get_pk_for_validation (
                new_references.apm_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_amd_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 03-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_match_details
      WHERE    amd_id = x_amd_id
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


  PROCEDURE get_fk_igf_ap_person_match_all (
    x_apm_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 03-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_match_details
      WHERE   ((apm_id = x_apm_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AP_AMD_APM_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_ap_person_match_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_amd_id                            IN     NUMBER  ,
    x_apm_id                            IN     NUMBER  ,
    x_person_id                         IN     NUMBER  ,
    x_ssn_match                         IN     NUMBER  ,
    x_given_name_match                  IN     NUMBER  ,
    x_surname_match                     IN     NUMBER  ,
    x_dob_match                         IN     NUMBER  ,
    x_address_match                     IN     NUMBER  ,
    x_city_match                        IN     NUMBER  ,
    x_zip_match                         IN     NUMBER  ,
    x_match_score                       IN     NUMBER  ,
    x_record_status                     IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_ssn_txt                           IN     VARCHAR2 ,
    x_given_name_txt                    IN     VARCHAR2 ,
    x_sur_name_txt                      IN     VARCHAR2 ,
    x_birth_date                        IN     DATE     ,
    x_address_txt                       IN     VARCHAR2 ,
    x_city_txt                          IN     VARCHAR2 ,
    x_zip_txt                           IN     VARCHAR2 ,
    x_gender_txt                        IN     VARCHAR2 ,
    x_email_id_txt                      IN     VARCHAR2 ,
    x_email_id_match                    IN     NUMBER   ,
    x_gender_match                      IN     NUMBER
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 03-JUN-2001
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
      x_amd_id,
      x_apm_id,
      x_person_id,
      x_ssn_match,
      x_given_name_match,
      x_surname_match,
      x_dob_match,
      x_address_match,
      x_city_match,
      x_zip_match,
      x_match_score,
      x_record_status,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_ssn_txt,
      x_given_name_txt,
      x_sur_name_txt,
      x_birth_date,
      x_address_txt,
      x_city_txt,
      x_zip_txt,
      x_gender_txt,
      x_email_id_txt,
      x_email_id_match,
      x_gender_match
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.amd_id
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
             new_references.amd_id
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
    x_amd_id                            IN OUT NOCOPY NUMBER,
    x_apm_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ssn_match                         IN     NUMBER,
    x_given_name_match                  IN     NUMBER,
    x_surname_match                     IN     NUMBER,
    x_dob_match                         IN     NUMBER,
    x_address_match                     IN     NUMBER,
    x_city_match                        IN     NUMBER,
    x_zip_match                         IN     NUMBER,
    x_match_score                       IN     NUMBER,
    x_record_status                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_ssn_txt                           IN     VARCHAR2 ,
    x_given_name_txt                    IN     VARCHAR2 ,
    x_sur_name_txt                      IN     VARCHAR2 ,
    x_birth_date                        IN     DATE     ,
    x_address_txt                       IN     VARCHAR2 ,
    x_city_txt                          IN     VARCHAR2 ,
    x_zip_txt                           IN     VARCHAR2 ,
    x_gender_txt                        IN     VARCHAR2 ,
    x_email_id_txt                      IN     VARCHAR2 ,
    x_email_id_match                    IN     NUMBER   ,
    x_gender_match                      IN     NUMBER
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 03-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_match_details
      WHERE    amd_id                            = x_amd_id;

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

    SELECT    igf_ap_match_details_s.NEXTVAL
    INTO      x_amd_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_amd_id                            => x_amd_id,
      x_apm_id                            => x_apm_id,
      x_person_id                         => x_person_id,
      x_ssn_match                         => x_ssn_match,
      x_given_name_match                  => x_given_name_match,
      x_surname_match                     => x_surname_match,
      x_dob_match                         => x_dob_match,
      x_address_match                     => x_address_match,
      x_city_match                        => x_city_match,
      x_zip_match                         => x_zip_match,
      x_match_score                       => x_match_score,
      x_record_status                     => x_record_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_ssn_txt                           => x_ssn_txt,
      x_given_name_txt                    => x_given_name_txt,
      x_sur_name_txt                      => x_sur_name_txt,
      x_birth_date                        => x_birth_date,
      x_address_txt                       => x_address_txt,
      x_city_txt                          => x_city_txt,
      x_zip_txt                           => x_zip_txt,
      x_gender_txt                        => x_gender_txt,
      x_email_id_txt                      => x_email_id_txt,
      x_email_id_match                    => x_email_id_match,
      x_gender_match                      => x_gender_match
    );

    INSERT INTO igf_ap_match_details (
      amd_id,
      apm_id,
      person_id,
      ssn_match,
      given_name_match,
      surname_match,
      dob_match,
      address_match,
      city_match,
      zip_match,
      match_score,
      record_status,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      ssn_txt,
      given_name_txt,
      sur_name_txt,
      birth_date,
      address_txt,
      city_txt,
      zip_txt,
      gender_txt,
      email_id_txt,
      email_id_match,
      gender_match
    ) VALUES (
      new_references.amd_id,
      new_references.apm_id,
      new_references.person_id,
      new_references.ssn_match,
      new_references.given_name_match,
      new_references.surname_match,
      new_references.dob_match,
      new_references.address_match,
      new_references.city_match,
      new_references.zip_match,
      new_references.match_score,
      new_references.record_status,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.ssn_txt,
      new_references.given_name_txt,
      new_references.sur_name_txt,
      new_references.birth_date,
      new_references.address_txt,
      new_references.city_txt,
      new_references.zip_txt,
      new_references.gender_txt,
      new_references.email_id_txt,
      new_references.email_id_match,
      new_references.gender_match
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
    x_amd_id                            IN     NUMBER,
    x_apm_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ssn_match                         IN     NUMBER,
    x_given_name_match                  IN     NUMBER,
    x_surname_match                     IN     NUMBER,
    x_dob_match                         IN     NUMBER,
    x_address_match                     IN     NUMBER,
    x_city_match                        IN     NUMBER,
    x_zip_match                         IN     NUMBER,
    x_match_score                       IN     NUMBER,
    x_record_status                     IN     VARCHAR2,
    x_ssn_txt                           IN     VARCHAR2 ,
    x_given_name_txt                    IN     VARCHAR2 ,
    x_sur_name_txt                      IN     VARCHAR2 ,
    x_birth_date                        IN     DATE     ,
    x_address_txt                       IN     VARCHAR2 ,
    x_city_txt                          IN     VARCHAR2 ,
    x_zip_txt                           IN     VARCHAR2 ,
    x_gender_txt                        IN     VARCHAR2 ,
    x_email_id_txt                      IN     VARCHAR2 ,
    x_email_id_match                    IN     NUMBER   ,
    x_gender_match                      IN     NUMBER
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 03-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        apm_id,
        person_id,
        ssn_match,
        given_name_match,
        surname_match,
        dob_match,
        address_match,
        city_match,
        zip_match,
        match_score,
        record_status,
        ssn_txt,
        given_name_txt,
        sur_name_txt,
        birth_date,
        address_txt,
        city_txt,
        zip_txt,
        gender_txt,
        email_id_txt,
        email_id_match,
        gender_match
      FROM  igf_ap_match_details
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
        (tlinfo.apm_id = x_apm_id)
        AND ((tlinfo.person_id = x_person_id) OR ((tlinfo.person_id IS NULL) AND (X_person_id IS NULL)))
        AND ((tlinfo.ssn_match = x_ssn_match) OR ((tlinfo.ssn_match IS NULL) AND (X_ssn_match IS NULL)))
        AND ((tlinfo.given_name_match = x_given_name_match) OR ((tlinfo.given_name_match IS NULL) AND (X_given_name_match IS NULL)))
        AND ((tlinfo.surname_match = x_surname_match) OR ((tlinfo.surname_match IS NULL) AND (X_surname_match IS NULL)))
        AND ((tlinfo.dob_match = x_dob_match) OR ((tlinfo.dob_match IS NULL) AND (X_dob_match IS NULL)))
        AND ((tlinfo.address_match = x_address_match) OR ((tlinfo.address_match IS NULL) AND (X_address_match IS NULL)))
        AND ((tlinfo.city_match = x_city_match) OR ((tlinfo.city_match IS NULL) AND (X_city_match IS NULL)))
        AND ((tlinfo.zip_match = x_zip_match) OR ((tlinfo.zip_match IS NULL) AND (X_zip_match IS NULL)))
        AND (tlinfo.match_score = x_match_score)
        AND (tlinfo.record_status = x_record_status)
        AND ((tlinfo.ssn_txt = x_ssn_txt) OR ((tlinfo.ssn_txt IS NULL) AND (x_ssn_txt IS NULL)))
        AND ((tlinfo.given_name_txt = x_given_name_txt) OR ((tlinfo.given_name_txt IS NULL) AND (x_given_name_txt IS NULL)))
        AND ((tlinfo.sur_name_txt = x_sur_name_txt) OR ((tlinfo.sur_name_txt IS NULL) AND (x_sur_name_txt IS NULL)))
        AND ((tlinfo.birth_date = x_birth_date) OR ((tlinfo.birth_date IS NULL) AND (x_birth_date IS NULL)))
        AND ((tlinfo.address_txt = x_address_txt) OR ((tlinfo.address_txt IS NULL) AND (x_address_txt IS NULL)))
        AND ((tlinfo.city_txt = x_city_txt) OR ((tlinfo.city_txt IS NULL) AND (x_city_txt IS NULL)))
        AND ((tlinfo.zip_txt = x_zip_txt) OR ((tlinfo.zip_txt IS NULL) AND (x_zip_txt IS NULL)))
        AND ((tlinfo.gender_txt = x_gender_txt) OR ((tlinfo.gender_txt IS NULL) AND (x_gender_txt IS NULL)))
        AND ((tlinfo.email_id_txt = x_email_id_txt) OR ((tlinfo.email_id_txt IS NULL) AND (x_email_id_txt IS NULL)))
        AND ((tlinfo.email_id_match = x_email_id_match) OR ((tlinfo.email_id_match IS NULL) AND (x_email_id_match IS NULL)))
        AND ((tlinfo.gender_match = x_gender_match) OR ((tlinfo.gender_match IS NULL) AND (x_gender_match IS NULL)))
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
    x_amd_id                            IN     NUMBER,
    x_apm_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ssn_match                         IN     NUMBER,
    x_given_name_match                  IN     NUMBER,
    x_surname_match                     IN     NUMBER,
    x_dob_match                         IN     NUMBER,
    x_address_match                     IN     NUMBER,
    x_city_match                        IN     NUMBER,
    x_zip_match                         IN     NUMBER,
    x_match_score                       IN     NUMBER,
    x_record_status                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_ssn_txt                           IN     VARCHAR2 ,
    x_given_name_txt                    IN     VARCHAR2 ,
    x_sur_name_txt                      IN     VARCHAR2 ,
    x_birth_date                        IN     DATE     ,
    x_address_txt                       IN     VARCHAR2 ,
    x_city_txt                          IN     VARCHAR2 ,
    x_zip_txt                           IN     VARCHAR2 ,
    x_gender_txt                        IN     VARCHAR2 ,
    x_email_id_txt                      IN     VARCHAR2 ,
    x_email_id_match                    IN     NUMBER   ,
    x_gender_match                      IN     NUMBER
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 03-JUN-2001
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
      x_amd_id                            => x_amd_id,
      x_apm_id                            => x_apm_id,
      x_person_id                         => x_person_id,
      x_ssn_match                         => x_ssn_match,
      x_given_name_match                  => x_given_name_match,
      x_surname_match                     => x_surname_match,
      x_dob_match                         => x_dob_match,
      x_address_match                     => x_address_match,
      x_city_match                        => x_city_match,
      x_zip_match                         => x_zip_match,
      x_match_score                       => x_match_score,
      x_record_status                     => x_record_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_ssn_txt                           => x_ssn_txt,
      x_given_name_txt                    => x_given_name_txt,
      x_sur_name_txt                      => x_sur_name_txt,
      x_birth_date                        => x_birth_date,
      x_address_txt                       => x_address_txt,
      x_city_txt                          => x_city_txt,
      x_zip_txt                           => x_zip_txt,
      x_gender_txt                        => x_gender_txt,
      x_email_id_txt                      => x_email_id_txt,
      x_email_id_match                    => x_email_id_match,
      x_gender_match                      => x_gender_match
    );

    UPDATE igf_ap_match_details
      SET
        apm_id                            = new_references.apm_id,
        person_id                         = new_references.person_id,
        ssn_match                         = new_references.ssn_match,
        given_name_match                  = new_references.given_name_match,
        surname_match                     = new_references.surname_match,
        dob_match                         = new_references.dob_match,
        address_match                     = new_references.address_match,
        city_match                        = new_references.city_match,
        zip_match                         = new_references.zip_match,
        match_score                       = new_references.match_score,
        record_status                     = new_references.record_status,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        ssn_txt                           = new_references.ssn_txt,
        given_name_txt                    = new_references.given_name_txt,
        sur_name_txt                      = new_references.sur_name_txt,
        birth_date                        = new_references.birth_date,
        address_txt                       = new_references.address_txt,
        city_txt                          = new_references.city_txt,
        zip_txt                           = new_references.zip_txt,
        gender_txt                        = new_references.gender_txt,
        email_id_txt                      = new_references.email_id_txt,
        email_id_match                    = new_references.email_id_match,
        gender_match                      = new_references.gender_match

      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_amd_id                            IN OUT NOCOPY NUMBER,
    x_apm_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_ssn_match                         IN     NUMBER,
    x_given_name_match                  IN     NUMBER,
    x_surname_match                     IN     NUMBER,
    x_dob_match                         IN     NUMBER,
    x_address_match                     IN     NUMBER,
    x_city_match                        IN     NUMBER,
    x_zip_match                         IN     NUMBER,
    x_match_score                       IN     NUMBER,
    x_record_status                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_ssn_txt                           IN     VARCHAR2 ,
    x_given_name_txt                    IN     VARCHAR2 ,
    x_sur_name_txt                      IN     VARCHAR2 ,
    x_birth_date                        IN     DATE     ,
    x_address_txt                       IN     VARCHAR2 ,
    x_city_txt                          IN     VARCHAR2 ,
    x_zip_txt                           IN     VARCHAR2 ,
    x_gender_txt                        IN     VARCHAR2 ,
    x_email_id_txt                      IN     VARCHAR2 ,
    x_email_id_match                    IN     NUMBER   ,
    x_gender_match                      IN     NUMBER
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 03-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_match_details
      WHERE    amd_id                            = x_amd_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_amd_id,
        x_apm_id,
        x_person_id,
        x_ssn_match,
        x_given_name_match,
        x_surname_match,
        x_dob_match,
        x_address_match,
        x_city_match,
        x_zip_match,
        x_match_score,
        x_record_status,
        x_mode,
        x_ssn_txt,
        x_given_name_txt,
        x_sur_name_txt,
        x_birth_date ,
        x_address_txt,
        x_city_txt ,
        x_zip_txt ,
        x_gender_txt ,
        x_email_id_txt ,
        x_email_id_match,
        x_gender_match
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_amd_id,
      x_apm_id,
      x_person_id,
      x_ssn_match,
      x_given_name_match,
      x_surname_match,
      x_dob_match,
      x_address_match,
      x_city_match,
      x_zip_match,
      x_match_score,
      x_record_status,
      x_mode ,
      x_ssn_txt,
      x_given_name_txt,
      x_sur_name_txt,
      x_birth_date ,
      x_address_txt,
      x_city_txt ,
      x_zip_txt ,
      x_gender_txt ,
      x_email_id_txt ,
      x_email_id_match,
      x_gender_match
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 03-JUN-2001
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

    DELETE FROM igf_ap_match_details
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_match_details_pkg;

/
