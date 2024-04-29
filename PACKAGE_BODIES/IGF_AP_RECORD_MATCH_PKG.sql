--------------------------------------------------------
--  DDL for Package Body IGF_AP_RECORD_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_RECORD_MATCH_PKG" AS
/* $Header: IGFAI40B.pls 120.0 2005/06/01 14:49:26 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_ap_record_match_all%ROWTYPE;
  new_references igf_ap_record_match_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2 ,
    x_rowid                             IN     VARCHAR2 ,
    x_arm_id                            IN     NUMBER   ,
    x_ssn                               IN     NUMBER   ,
    x_given_name                        IN     NUMBER   ,
    x_surname                           IN     NUMBER   ,
    x_birth_dt                          IN     NUMBER   ,
    x_address                           IN     NUMBER   ,
    x_city                              IN     NUMBER   ,
    x_zip                               IN     NUMBER   ,
    x_min_score_auto_fa                 IN     NUMBER   ,
    x_min_score_rvw_fa                  IN     NUMBER   ,
    x_admn_term                         IN     VARCHAR2 ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER   ,
    x_match_code                        IN     VARCHAR2    DEFAULT NULL,
    x_match_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_num                        IN     NUMBER      DEFAULT NULL,
    x_email_num                         IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_given_name_mt_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_surname_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt_mt_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_address_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_city_mt_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_zip_mt_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_mt_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_email_mt_txt                      IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 29-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AP_RECORD_MATCH_ALL
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
    new_references.arm_id                            := x_arm_id;
    new_references.ssn                               := x_ssn;
    new_references.given_name                        := x_given_name;
    new_references.surname                           := x_surname;
    new_references.birth_dt                          := x_birth_dt;
    new_references.address                           := x_address;
    new_references.city                              := x_city;
    new_references.zip                               := x_zip;
    new_references.min_score_auto_fa                 := x_min_score_auto_fa;
    new_references.min_score_rvw_fa                  := x_min_score_rvw_fa;
    new_references.admn_term                         := x_admn_term;
    new_references.match_code                        := x_match_code;
    new_references.match_desc                        := x_match_desc;
    new_references.gender_num                        := x_gender_num;
    new_references.email_num                         := x_email_num;
    new_references.enabled_flag                      := x_enabled_flag;
    new_references.given_name_mt_txt                 := x_given_name_mt_txt;
    new_references.surname_mt_txt                    := x_surname_mt_txt;
    new_references.birth_dt_mt_txt                   := x_birth_dt_mt_txt;
    new_references.address_mt_txt                    := x_address_mt_txt;
    new_references.city_mt_txt                       := x_city_mt_txt;
    new_references.zip_mt_txt                        := x_zip_mt_txt;
    new_references.gender_mt_txt                     := x_gender_mt_txt;
    new_references.email_mt_txt                      := x_email_mt_txt;

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


  FUNCTION get_pk_for_validation (
    x_arm_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 29-MAY-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_record_match_all
      WHERE    arm_id = x_arm_id
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
    x_match_code                        IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : gvarapra
  ||  Created On : 30-JUL-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_record_match_all
      WHERE    match_code = x_match_code
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
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

  END get_uk_for_validation;

PROCEDURE check_uniqueness AS
  ------------------------------------------------------------------
  --Created by  : gvarapra, Oracle India
  --Date created: 30-JUL-2003
  --
  --Purpose:Call all unique key constraint functions
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  BEGIN
    IF ( get_uk_for_validation(
                               new_references.match_code
                              )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END check_uniqueness;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2 ,
    x_rowid                             IN     VARCHAR2 ,
    x_arm_id                            IN     NUMBER   ,
    x_ssn                               IN     NUMBER   ,
    x_given_name                        IN     NUMBER   ,
    x_surname                           IN     NUMBER   ,
    x_birth_dt                          IN     NUMBER   ,
    x_address                           IN     NUMBER   ,
    x_city                              IN     NUMBER   ,
    x_zip                               IN     NUMBER   ,
    x_min_score_auto_fa                 IN     NUMBER   ,
    x_min_score_rvw_fa                  IN     NUMBER   ,
    x_admn_term                         IN     VARCHAR2 ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER   ,
    x_match_code                        IN     VARCHAR2    DEFAULT NULL,
    x_match_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_num                        IN     NUMBER      DEFAULT NULL,
    x_email_num                         IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_given_name_mt_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_surname_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt_mt_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_address_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_city_mt_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_zip_mt_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_mt_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_email_mt_txt                      IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 29-MAY-2001
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
      x_arm_id,
      x_ssn,
      x_given_name,
      x_surname,
      x_birth_dt,
      x_address,
      x_city,
      x_zip,
      x_min_score_auto_fa,
      x_min_score_rvw_fa,
      x_admn_term,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_match_code,
      x_match_desc,
      x_gender_num,
      x_email_num,
      x_enabled_flag,
      x_given_name_mt_txt,
      x_surname_mt_txt,
      x_birth_dt_mt_txt,
      x_address_mt_txt,
      x_city_mt_txt,
      x_zip_mt_txt,
      x_gender_mt_txt,
      x_email_mt_txt
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.arm_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.arm_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_arm_id                            IN OUT NOCOPY NUMBER,
    x_ssn                               IN     NUMBER,
    x_given_name                        IN     NUMBER,
    x_surname                           IN     NUMBER,
    x_birth_dt                          IN     NUMBER,
    x_address                           IN     NUMBER,
    x_city                              IN     NUMBER,
    x_zip                               IN     NUMBER,
    x_min_score_auto_fa                 IN     NUMBER,
    x_min_score_rvw_fa                  IN     NUMBER,
    x_admn_term                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_match_code                        IN     VARCHAR2    DEFAULT NULL,
    x_match_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_num                        IN     NUMBER      DEFAULT NULL,
    x_email_num                         IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_given_name_mt_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_surname_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt_mt_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_address_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_city_mt_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_zip_mt_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_mt_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_email_mt_txt                      IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 29-MAY-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_record_match_all
      WHERE    arm_id = x_arm_id;

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

    SELECT    igf_ap_record_match_all_s.NEXTVAL
    INTO      x_arm_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_arm_id                            => x_arm_id,
      x_ssn                               => x_ssn,
      x_given_name                        => x_given_name,
      x_surname                           => x_surname,
      x_birth_dt                          => x_birth_dt,
      x_address                           => x_address,
      x_city                              => x_city,
      x_zip                               => x_zip,
      x_min_score_auto_fa                 => x_min_score_auto_fa,
      x_min_score_rvw_fa                  => x_min_score_rvw_fa,
      x_admn_term                         => x_admn_term,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_match_code                        => x_match_code,
      x_match_desc                        => x_match_desc,
      x_gender_num                        => x_gender_num,
      x_email_num                         => x_email_num,
      x_enabled_flag                      => x_enabled_flag,
      x_given_name_mt_txt                 => x_given_name_mt_txt,
      x_surname_mt_txt                    => x_surname_mt_txt,
      x_birth_dt_mt_txt                   => x_birth_dt_mt_txt,
      x_address_mt_txt                    => x_address_mt_txt,
      x_city_mt_txt                       => x_city_mt_txt,
      x_zip_mt_txt                        => x_zip_mt_txt,
      x_gender_mt_txt                     => x_gender_mt_txt,
      x_email_mt_txt                      => x_email_mt_txt
    );

    INSERT INTO igf_ap_record_match_all (
      arm_id,
      org_id,
      ssn,
      given_name,
      surname,
      birth_dt,
      address,
      city,
      zip,
      min_score_auto_fa,
      min_score_rvw_fa,
      admn_term,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      match_code,
      match_desc,
      gender_num,
      email_num,
      enabled_flag,
      given_name_mt_txt,
      surname_mt_txt,
      birth_dt_mt_txt,
      address_mt_txt,
      city_mt_txt,
      zip_mt_txt,
      gender_mt_txt,
      email_mt_txt
    ) VALUES (
      new_references.arm_id,
      new_references.org_id,
      new_references.ssn,
      new_references.given_name,
      new_references.surname,
      new_references.birth_dt,
      new_references.address,
      new_references.city,
      new_references.zip,
      new_references.min_score_auto_fa,
      new_references.min_score_rvw_fa,
      new_references.admn_term,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.match_code,
      new_references.match_desc,
      new_references.gender_num,
      new_references.email_num,
      new_references.enabled_flag,
      new_references.given_name_mt_txt,
      new_references.surname_mt_txt,
      new_references.birth_dt_mt_txt,
      new_references.address_mt_txt,
      new_references.city_mt_txt,
      new_references.zip_mt_txt,
      new_references.gender_mt_txt,
      new_references.email_mt_txt
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
    x_arm_id                            IN     NUMBER,
    x_ssn                               IN     NUMBER,
    x_given_name                        IN     NUMBER,
    x_surname                           IN     NUMBER,
    x_birth_dt                          IN     NUMBER,
    x_address                           IN     NUMBER,
    x_city                              IN     NUMBER,
    x_zip                               IN     NUMBER,
    x_min_score_auto_fa                 IN     NUMBER,
    x_min_score_rvw_fa                  IN     NUMBER,
    x_admn_term                         IN     VARCHAR2,
    x_match_code                        IN     VARCHAR2    DEFAULT NULL,
    x_match_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_num                        IN     NUMBER      DEFAULT NULL,
    x_email_num                         IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_given_name_mt_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_surname_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt_mt_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_address_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_city_mt_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_zip_mt_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_mt_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_email_mt_txt                      IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 29-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        ssn,
        given_name,
        surname,
        birth_dt,
        address,
        city,
        zip,
        min_score_auto_fa,
        min_score_rvw_fa,
        admn_term,
            match_code,
        match_desc,
        gender_num,
        email_num,
        enabled_flag,
        given_name_mt_txt,
        surname_mt_txt,
        birth_dt_mt_txt,
        address_mt_txt,
        city_mt_txt,
        zip_mt_txt,
        gender_mt_txt,
        email_mt_txt
      FROM  igf_ap_record_match_all
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
        (tlinfo.ssn = x_ssn)
        AND (tlinfo.given_name = x_given_name)
        AND (tlinfo.surname = x_surname)
        AND (tlinfo.birth_dt = x_birth_dt)
        AND (tlinfo.address = x_address)
        AND (tlinfo.city = x_city)
        AND (tlinfo.zip = x_zip)
        AND (tlinfo.min_score_auto_fa = x_min_score_auto_fa)
        AND (tlinfo.min_score_rvw_fa = x_min_score_rvw_fa)
        AND ((tlinfo.admn_term = x_admn_term) OR ((tlinfo.admn_term IS NULL) AND (x_admn_term IS NULL)))
            AND (tlinfo.match_code = x_match_code)
            AND ((tlinfo.match_desc         =  x_match_desc        ) OR  ((tlinfo.match_desc         IS NULL) AND ( x_match_desc        IS NULL)))
        AND ((tlinfo.gender_num         =  x_gender_num        ) OR  ((tlinfo.gender_num         IS NULL) AND ( x_gender_num        IS NULL)))
        AND ((tlinfo.email_num          =  x_email_num         ) OR  ((tlinfo.email_num          IS NULL) AND ( x_email_num         IS NULL)))
        AND ((tlinfo.enabled_flag       =  x_enabled_flag      ) OR  ((tlinfo.enabled_flag       IS NULL) AND ( x_enabled_flag      IS NULL)))
        AND ((tlinfo.given_name_mt_txt  =  x_given_name_mt_txt ) OR  ((tlinfo.given_name_mt_txt  IS NULL) AND ( x_given_name_mt_txt IS NULL)))
        AND ((tlinfo.surname_mt_txt     =  x_surname_mt_txt    ) OR  ((tlinfo.surname_mt_txt     IS NULL) AND ( x_surname_mt_txt    IS NULL)))
        AND ((tlinfo.birth_dt_mt_txt    =  x_birth_dt_mt_txt   ) OR  ((tlinfo.birth_dt_mt_txt    IS NULL) AND ( x_birth_dt_mt_txt   IS NULL)))
        AND ((tlinfo.address_mt_txt     =  x_address_mt_txt    ) OR  ((tlinfo.address_mt_txt     IS NULL) AND ( x_address_mt_txt    IS NULL)))
        AND ((tlinfo.city_mt_txt        =  x_city_mt_txt       ) OR  ((tlinfo.city_mt_txt        IS NULL) AND ( x_city_mt_txt       IS NULL)))
        AND ((tlinfo.zip_mt_txt         =  x_zip_mt_txt        ) OR  ((tlinfo.zip_mt_txt         IS NULL) AND ( x_zip_mt_txt        IS NULL)))
        AND ((tlinfo.gender_mt_txt      =  x_gender_mt_txt     ) OR  ((tlinfo.gender_mt_txt      IS NULL) AND ( x_gender_mt_txt     IS NULL)))
        AND ((tlinfo.email_mt_txt       =  x_email_mt_txt      ) OR  ((tlinfo.email_mt_txt       IS NULL) AND ( x_email_mt_txt      IS NULL)))
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
    x_arm_id                            IN     NUMBER,
    x_ssn                               IN     NUMBER,
    x_given_name                        IN     NUMBER,
    x_surname                           IN     NUMBER,
    x_birth_dt                          IN     NUMBER,
    x_address                           IN     NUMBER,
    x_city                              IN     NUMBER,
    x_zip                               IN     NUMBER,
    x_min_score_auto_fa                 IN     NUMBER,
    x_min_score_rvw_fa                  IN     NUMBER,
    x_admn_term                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_match_code                        IN     VARCHAR2    DEFAULT NULL,
    x_match_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_num                        IN     NUMBER      DEFAULT NULL,
    x_email_num                         IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_given_name_mt_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_surname_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt_mt_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_address_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_city_mt_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_zip_mt_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_mt_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_email_mt_txt                      IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 29-MAY-2001
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
      x_arm_id                            => x_arm_id,
      x_ssn                               => x_ssn,
      x_given_name                        => x_given_name,
      x_surname                           => x_surname,
      x_birth_dt                          => x_birth_dt,
      x_address                           => x_address,
      x_city                              => x_city,
      x_zip                               => x_zip,
      x_min_score_auto_fa                 => x_min_score_auto_fa,
      x_min_score_rvw_fa                  => x_min_score_rvw_fa,
      x_admn_term                         => x_admn_term,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_match_code                        => x_match_code,
      x_match_desc                        => x_match_desc,
      x_gender_num                        => x_gender_num,
      x_email_num                         => x_email_num,
      x_enabled_flag                      => x_enabled_flag,
      x_given_name_mt_txt                 => x_given_name_mt_txt,
      x_surname_mt_txt                    => x_surname_mt_txt,
      x_birth_dt_mt_txt                   => x_birth_dt_mt_txt,
      x_address_mt_txt                    => x_address_mt_txt,
      x_city_mt_txt                       => x_city_mt_txt,
      x_zip_mt_txt                        => x_zip_mt_txt,
      x_gender_mt_txt                     => x_gender_mt_txt,
      x_email_mt_txt                      => x_email_mt_txt
    );

    UPDATE igf_ap_record_match_all
      SET
        ssn                               = new_references.ssn,
        given_name                        = new_references.given_name,
        surname                           = new_references.surname,
        birth_dt                          = new_references.birth_dt,
        address                           = new_references.address,
        city                              = new_references.city,
        zip                               = new_references.zip,
        min_score_auto_fa                 = new_references.min_score_auto_fa,
        min_score_rvw_fa                  = new_references.min_score_rvw_fa,
        admn_term                         = new_references.admn_term,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
            match_code                        = new_references.match_code,
        match_desc                        = new_references.match_desc,
        gender_num                        = new_references.gender_num,
        email_num                         = new_references.email_num,
        enabled_flag                      = new_references.enabled_flag,
        given_name_mt_txt                 = new_references.given_name_mt_txt,
        surname_mt_txt                    = new_references.surname_mt_txt,
        birth_dt_mt_txt                   = new_references.birth_dt_mt_txt,
        address_mt_txt                    = new_references.address_mt_txt,
        city_mt_txt                       = new_references.city_mt_txt,
        zip_mt_txt                        = new_references.zip_mt_txt,
        gender_mt_txt                     = new_references.gender_mt_txt,
        email_mt_txt                      = new_references.email_mt_txt
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_arm_id                            IN OUT NOCOPY NUMBER,
    x_ssn                               IN     NUMBER,
    x_given_name                        IN     NUMBER,
    x_surname                           IN     NUMBER,
    x_birth_dt                          IN     NUMBER,
    x_address                           IN     NUMBER,
    x_city                              IN     NUMBER,
    x_zip                               IN     NUMBER,
    x_min_score_auto_fa                 IN     NUMBER,
    x_min_score_rvw_fa                  IN     NUMBER,
    x_admn_term                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_match_code                        IN     VARCHAR2    DEFAULT NULL,
    x_match_desc                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_num                        IN     NUMBER      DEFAULT NULL,
    x_email_num                         IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_given_name_mt_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_surname_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt_mt_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_address_mt_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_city_mt_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_zip_mt_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_gender_mt_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_email_mt_txt                      IN     VARCHAR2    DEFAULT NULL
    ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 29-MAY-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_record_match_all
      WHERE    arm_id = x_arm_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_arm_id,
        x_ssn,
        x_given_name,
        x_surname,
        x_birth_dt,
        x_address,
        x_city,
        x_zip,
        x_min_score_auto_fa,
        x_min_score_rvw_fa,
        x_admn_term,
        x_mode ,
            x_match_code,
        x_match_desc,
        x_gender_num,
        x_email_num,
        x_enabled_flag,
        x_given_name_mt_txt,
        x_surname_mt_txt,
        x_birth_dt_mt_txt,
        x_address_mt_txt,
        x_city_mt_txt,
        x_zip_mt_txt,
        x_gender_mt_txt,
        x_email_mt_txt
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_arm_id,
      x_ssn,
      x_given_name,
      x_surname,
      x_birth_dt,
      x_address,
      x_city,
      x_zip,
      x_min_score_auto_fa,
      x_min_score_rvw_fa,
      x_admn_term,
      x_mode,
      x_match_code,
      x_match_desc,
      x_gender_num,
      x_email_num,
      x_enabled_flag,
      x_given_name_mt_txt,
      x_surname_mt_txt,
      x_birth_dt_mt_txt,
      x_address_mt_txt,
      x_city_mt_txt,
      x_zip_mt_txt,
      x_gender_mt_txt,
      x_email_mt_txt
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 29-MAY-2001
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What cex
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igf_ap_record_match_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_record_match_pkg;

/
