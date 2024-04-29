--------------------------------------------------------
--  DDL for Package Body IGF_SE_AUTH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SE_AUTH_PKG" AS
/* $Header: IGFSI04B.pls 120.0 2005/06/03 14:28:02 appldev noship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: igf_se_auth_PKG
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | This package has a flag on the end of some of the procedures called   |
 | X_MODE. Pass either 'R' for runtime, or 'I' for Install-time.         |
 | This will control how the who columns are filled in; If you are       |
 | running in runtime mode, they are taken from the profiles, whereas in |
 | install-time mode they get defaulted with special values to indicate  |
 | that they were inserted by datamerge.                                 |
 |                                                                       |
 | The ADD_ROW routine will see whether a row exists by selecting        |
 | based on the primary key, and updates the row if it exists,           |
 | or inserts the row if it doesn't already exist.                       |
 |                                                                       |
 | This module is called by AutoInstall (afplss.drv) on install and      |
 | upgrade.  The WHENEVER SQLERROR and EXIT (at bottom) are required.    |
 |                                                                       |
 | HISTORY                                                               |
 |veramach    July 2004     Obsoleted min_hr_rate,max_hr_rate,           |
 |                          govt_share_perct,ld_cal_type,                |
 |                          ld_sequence_number                           |
 |                          Added award_id,authorization_date,           |
 |                          notification_date                            |
 *=======================================================================*/

  l_rowid VARCHAR2(25);
  old_references igf_se_auth%ROWTYPE;
  new_references igf_se_auth%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sequence_no                       IN     NUMBER      DEFAULT NULL,
    x_auth_id                           IN     NUMBER      DEFAULT NULL,
    x_flag                              IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_first_name                        IN     VARCHAR2    DEFAULT NULL,
    x_last_name                         IN     VARCHAR2    DEFAULT NULL,
    x_address1                          IN     VARCHAR2    DEFAULT NULL,
    x_address2                          IN     VARCHAR2    DEFAULT NULL,
    x_address3                          IN     VARCHAR2    DEFAULT NULL,
    x_address4                          IN     VARCHAR2    DEFAULT NULL,
    x_city                              IN     VARCHAR2    DEFAULT NULL,
    x_state                             IN     VARCHAR2    DEFAULT NULL,
    x_province                          IN     VARCHAR2    DEFAULT NULL,
    x_county                            IN     VARCHAR2    DEFAULT NULL,
    x_country                           IN     VARCHAR2    DEFAULT NULL,
    x_sex                               IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt                          IN     DATE        DEFAULT NULL,
    x_ssn_no                            IN     VARCHAR2    DEFAULT NULL,
    x_marital_status                    IN     VARCHAR2    DEFAULT NULL,
    x_visa_type                         IN     VARCHAR2    DEFAULT NULL,
    x_visa_category                     IN     VARCHAR2    DEFAULT NULL,
    x_visa_number                       IN     VARCHAR2    DEFAULT NULL,
    x_visa_expiry_dt                    IN     DATE        DEFAULT NULL,
    x_entry_date                        IN     DATE        DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_threshold_perct                   IN     NUMBER      DEFAULT NULL,
    x_threshold_value                   IN     NUMBER      DEFAULT NULL,
    x_accepted_amnt                     IN     NUMBER      DEFAULT NULL,
    x_aw_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_aw_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_authorization_date                IN     DATE        DEFAULT NULL,
    x_notification_date                 IN     DATE        DEFAULT NULL
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_SE_AUTH
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
    new_references.sequence_no                       := x_sequence_no;
    new_references.auth_id                           := x_auth_id;
    new_references.flag                              := x_flag;
    new_references.person_id                         := x_person_id;
    new_references.first_name                        := x_first_name;
    new_references.last_name                         := x_last_name;
    new_references.address1                          := x_address1;
    new_references.address2                          := x_address2;
    new_references.address3                          := x_address3;
    new_references.address4                          := x_address4;
    new_references.city                              := x_city;
    new_references.state                             := x_state;
    new_references.province                          := x_province;
    new_references.county                            := x_county;
    new_references.country                           := x_country;
    new_references.sex                               := x_sex;
    new_references.birth_dt                          := x_birth_dt;
    new_references.ssn_no                            := x_ssn_no;
    new_references.marital_status                    := x_marital_status;
    new_references.visa_type                         := x_visa_type;
    new_references.visa_category                     := x_visa_category;
    new_references.visa_number                       := x_visa_number;
    new_references.visa_expiry_dt                    := x_visa_expiry_dt;
    new_references.entry_date                        := x_entry_date;
    new_references.fund_id                           := x_fund_id;
    new_references.threshold_perct                   := x_threshold_perct;
    new_references.threshold_value                   := x_threshold_value;
    new_references.accepted_amnt                     := x_accepted_amnt;
    new_references.aw_cal_type                       := x_aw_cal_type;
    new_references.aw_sequence_number                := x_aw_sequence_number;
    new_references.award_id                          := x_award_id;
    new_references.authorization_date                := x_authorization_date;
    new_references.notification_date                 := x_notification_date;

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


  PROCEDURE check_constraints (
    column_name    IN     VARCHAR2    DEFAULT NULL,
    column_value   IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 02-JAN-2002
  ||  Purpose : Handles the Check Constraint logic for the the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER(column_name) = 'FLAG') THEN
      new_references.flag := column_value;
    END IF;

    IF (UPPER(column_name) = 'FLAG' OR column_name IS NULL) THEN
      IF NOT (new_references.flag IN ('A','I'))  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;



  FUNCTION get_pk_for_validation (
    x_sequence_no                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_se_auth
      WHERE    sequence_no = x_sequence_no
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



  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sequence_no                       IN     NUMBER      DEFAULT NULL,
    x_auth_id                           IN     NUMBER      DEFAULT NULL,
    x_flag                              IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_first_name                        IN     VARCHAR2    DEFAULT NULL,
    x_last_name                         IN     VARCHAR2    DEFAULT NULL,
    x_address1                          IN     VARCHAR2    DEFAULT NULL,
    x_address2                          IN     VARCHAR2    DEFAULT NULL,
    x_address3                          IN     VARCHAR2    DEFAULT NULL,
    x_address4                          IN     VARCHAR2    DEFAULT NULL,
    x_city                              IN     VARCHAR2    DEFAULT NULL,
    x_state                             IN     VARCHAR2    DEFAULT NULL,
    x_province                          IN     VARCHAR2    DEFAULT NULL,
    x_county                            IN     VARCHAR2    DEFAULT NULL,
    x_country                           IN     VARCHAR2    DEFAULT NULL,
    x_sex                               IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt                          IN     DATE        DEFAULT NULL,
    x_ssn_no                            IN     VARCHAR2    DEFAULT NULL,
    x_marital_status                    IN     VARCHAR2    DEFAULT NULL,
    x_visa_type                         IN     VARCHAR2    DEFAULT NULL,
    x_visa_category                     IN     VARCHAR2    DEFAULT NULL,
    x_visa_number                       IN     VARCHAR2    DEFAULT NULL,
    x_visa_expiry_dt                    IN     DATE        DEFAULT NULL,
    x_entry_date                        IN     DATE        DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_threshold_perct                   IN     NUMBER      DEFAULT NULL,
    x_threshold_value                   IN     NUMBER      DEFAULT NULL,
    x_accepted_amnt                     IN     NUMBER      DEFAULT NULL,
    x_aw_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_aw_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_authorization_date                IN     DATE        DEFAULT NULL,
    x_notification_date                 IN     DATE        DEFAULT NULL
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
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
      x_sequence_no,
      x_auth_id,
      x_flag,
      x_person_id,
      x_first_name,
      x_last_name,
      x_address1,
      x_address2,
      x_address3,
      x_address4,
      x_city,
      x_state,
      x_province,
      x_county,
      x_country,
      x_sex,
      x_birth_dt,
      x_ssn_no,
      x_marital_status,
      x_visa_type,
      x_visa_category,
      x_visa_number,
      x_visa_expiry_dt,
      x_entry_date,
      x_fund_id,
      x_threshold_perct,
      x_threshold_value,
      x_accepted_amnt,
      x_aw_cal_type,
      x_aw_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_award_id,
      x_authorization_date,
      x_notification_date
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.sequence_no
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      -- check_uniqueness;
        check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      -- check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.sequence_no
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      -- check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- check_uniqueness;
      check_constraints;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sequence_no                       IN OUT NOCOPY NUMBER,
    x_auth_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_first_name                        IN     VARCHAR2,
    x_last_name                         IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_ssn_no                            IN     VARCHAR2,
    x_marital_status                    IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_visa_category                     IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_expiry_dt                    IN     DATE,
    x_entry_date                        IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_accepted_amnt                     IN     NUMBER,
    x_aw_cal_type                       IN     VARCHAR2,
    x_aw_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_award_id                          IN     NUMBER,
    x_authorization_date                IN     DATE,
    x_notification_date                 IN     DATE
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_se_auth
      WHERE    sequence_no                       = x_sequence_no;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igf_se_auth_s.NEXTVAL
    INTO      x_sequence_no
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sequence_no                       => x_sequence_no,
      x_auth_id                           => x_auth_id,
      x_flag                              => x_flag,
      x_person_id                         => x_person_id,
      x_first_name                        => x_first_name,
      x_last_name                         => x_last_name,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_city                              => x_city,
      x_state                             => x_state,
      x_province                          => x_province,
      x_county                            => x_county,
      x_country                           => x_country,
      x_sex                               => x_sex,
      x_birth_dt                          => x_birth_dt,
      x_ssn_no                            => x_ssn_no,
      x_marital_status                    => x_marital_status,
      x_visa_type                         => x_visa_type,
      x_visa_category                     => x_visa_category,
      x_visa_number                       => x_visa_number,
      x_visa_expiry_dt                    => x_visa_expiry_dt,
      x_entry_date                        => x_entry_date,
      x_fund_id                           => x_fund_id,
      x_threshold_perct                   => x_threshold_perct,
      x_threshold_value                   => x_threshold_value,
      x_accepted_amnt                     => x_accepted_amnt,
      x_aw_cal_type                       => x_aw_cal_type,
      x_aw_sequence_number                => x_aw_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_award_id                          => x_award_id,
      x_authorization_date                => x_authorization_date,
      x_notification_date                 => x_notification_date
    );

    INSERT INTO igf_se_auth (
      sequence_no,
      auth_id,
      flag,
      person_id,
      first_name,
      last_name,
      address1,
      address2,
      address3,
      address4,
      city,
      state,
      province,
      county,
      country,
      sex,
      birth_dt,
      ssn_no,
      marital_status,
      visa_type,
      visa_category,
      visa_number,
      visa_expiry_dt,
      entry_date,
      fund_id,
      threshold_perct,
      threshold_value,
      accepted_amnt,
      aw_cal_type,
      aw_sequence_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      award_id,
      authorization_date,
      notification_date
    ) VALUES (
      new_references.sequence_no,
      new_references.auth_id,
      new_references.flag,
      new_references.person_id,
      new_references.first_name,
      new_references.last_name,
      new_references.address1,
      new_references.address2,
      new_references.address3,
      new_references.address4,
      new_references.city,
      new_references.state,
      new_references.province,
      new_references.county,
      new_references.country,
      new_references.sex,
      new_references.birth_dt,
      new_references.ssn_no,
      new_references.marital_status,
      new_references.visa_type,
      new_references.visa_category,
      new_references.visa_number,
      new_references.visa_expiry_dt,
      new_references.entry_date,
      new_references.fund_id,
      new_references.threshold_perct,
      new_references.threshold_value,
      new_references.accepted_amnt,
      new_references.aw_cal_type,
      new_references.aw_sequence_number,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.award_id,
      new_references.authorization_date,
      new_references.notification_date
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
    x_sequence_no                       IN     NUMBER,
    x_auth_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_first_name                        IN     VARCHAR2,
    x_last_name                         IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_ssn_no                            IN     VARCHAR2,
    x_marital_status                    IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_visa_category                     IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_expiry_dt                    IN     DATE,
    x_entry_date                        IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_accepted_amnt                     IN     NUMBER,
    x_aw_cal_type                       IN     VARCHAR2,
    x_aw_sequence_number                IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_authorization_date                IN     DATE,
    x_notification_date                 IN     DATE
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        auth_id,
        flag,
        person_id,
        first_name,
        last_name,
        address1,
        address2,
        address3,
        address4,
        city,
        state,
        province,
        county,
        country,
        sex,
        birth_dt,
        ssn_no,
        marital_status,
        visa_type,
        visa_category,
        visa_number,
        visa_expiry_dt,
        entry_date,
        fund_id,
        threshold_perct,
        threshold_value,
        accepted_amnt,
        aw_cal_type,
        aw_sequence_number,
        award_id,
        authorization_date,
        notification_date
      FROM  igf_se_auth
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
        (tlinfo.auth_id = x_auth_id)
        AND (tlinfo.flag = x_flag)
        AND (tlinfo.person_id = x_person_id)
        AND (tlinfo.first_name = x_first_name)
        AND (tlinfo.last_name = x_last_name)
        AND (tlinfo.address1 = x_address1)
        AND ((tlinfo.address2 = x_address2) OR ((tlinfo.address2 IS NULL) AND (X_address2 IS NULL)))
        AND ((tlinfo.address3 = x_address3) OR ((tlinfo.address3 IS NULL) AND (X_address3 IS NULL)))
        AND ((tlinfo.address4 = x_address4) OR ((tlinfo.address4 IS NULL) AND (X_address4 IS NULL)))
        AND ((tlinfo.city = x_city) OR ((tlinfo.city IS NULL) AND (X_city IS NULL)))
        AND ((tlinfo.state = x_state) OR ((tlinfo.state IS NULL) AND (X_state IS NULL)))
        AND ((tlinfo.province = x_province) OR ((tlinfo.province IS NULL) AND (X_province IS NULL)))
        AND ((tlinfo.county = x_county) OR ((tlinfo.county IS NULL) AND (X_county IS NULL)))
        AND (tlinfo.country = x_country)
        AND ((tlinfo.sex = x_sex) OR ((tlinfo.sex IS NULL) AND (X_sex IS NULL)))
        AND (tlinfo.birth_dt = x_birth_dt)
        AND (tlinfo.ssn_no = x_ssn_no)
        AND (tlinfo.marital_status = x_marital_status)
        AND ((tlinfo.visa_type = x_visa_type) OR ((tlinfo.visa_type IS NULL) AND (X_visa_type IS NULL)))
        AND ((tlinfo.visa_category = x_visa_category) OR ((tlinfo.visa_category IS NULL) AND (X_visa_category IS NULL)))
        AND ((tlinfo.visa_number = x_visa_number) OR ((tlinfo.visa_number IS NULL) AND (X_visa_number IS NULL)))
        AND ((tlinfo.visa_expiry_dt = x_visa_expiry_dt) OR ((tlinfo.visa_expiry_dt IS NULL) AND (X_visa_expiry_dt IS NULL)))
        AND ((tlinfo.entry_date = x_entry_date) OR ((tlinfo.entry_date IS NULL) AND (X_entry_date IS NULL)))
        AND (tlinfo.fund_id = x_fund_id)
        AND ((tlinfo.threshold_perct = x_threshold_perct) OR ((tlinfo.threshold_perct IS NULL) AND (X_threshold_perct IS NULL)))
        AND ((tlinfo.threshold_value = x_threshold_value) OR ((tlinfo.threshold_value IS NULL) AND (X_threshold_value IS NULL)))
        AND (tlinfo.accepted_amnt = x_accepted_amnt)
        AND (tlinfo.aw_cal_type = x_aw_cal_type)
        AND (tlinfo.aw_sequence_number = x_aw_sequence_number)
        AND ((tlinfo.award_id = x_award_id) OR ((tlinfo.award_id IS NULL) AND (x_award_id IS NULL)))
        AND ((tlinfo.authorization_date = x_authorization_date) OR ((tlinfo.authorization_date IS NULL) AND (x_authorization_date IS NULL)))
        AND ((tlinfo.notification_date = x_notification_date) OR ((tlinfo.notification_date IS NULL) AND (x_notification_date IS NULL)))
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
    x_sequence_no                       IN     NUMBER,
    x_auth_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_first_name                        IN     VARCHAR2,
    x_last_name                         IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_ssn_no                            IN     VARCHAR2,
    x_marital_status                    IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_visa_category                     IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_expiry_dt                    IN     DATE,
    x_entry_date                        IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_accepted_amnt                     IN     NUMBER,
    x_aw_cal_type                       IN     VARCHAR2,
    x_aw_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_award_id                          IN     NUMBER,
    x_authorization_date                IN     DATE,
    x_notification_date                 IN     DATE
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_sequence_no                       => x_sequence_no,
      x_auth_id                           => x_auth_id,
      x_flag                              => x_flag,
      x_person_id                         => x_person_id,
      x_first_name                        => x_first_name,
      x_last_name                         => x_last_name,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_city                              => x_city,
      x_state                             => x_state,
      x_province                          => x_province,
      x_county                            => x_county,
      x_country                           => x_country,
      x_sex                               => x_sex,
      x_birth_dt                          => x_birth_dt,
      x_ssn_no                            => x_ssn_no,
      x_marital_status                    => x_marital_status,
      x_visa_type                         => x_visa_type,
      x_visa_category                     => x_visa_category,
      x_visa_number                       => x_visa_number,
      x_visa_expiry_dt                    => x_visa_expiry_dt,
      x_entry_date                        => x_entry_date,
      x_fund_id                           => x_fund_id,
      x_threshold_perct                   => x_threshold_perct,
      x_threshold_value                   => x_threshold_value,
      x_accepted_amnt                     => x_accepted_amnt,
      x_aw_cal_type                       => x_aw_cal_type,
      x_aw_sequence_number                => x_aw_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_award_id                          => x_award_id,
      x_authorization_date                => x_authorization_date,
      x_notification_date                 => x_notification_date
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igf_se_auth
      SET
        auth_id                           = new_references.auth_id,
        flag                              = new_references.flag,
        person_id                         = new_references.person_id,
        first_name                        = new_references.first_name,
        last_name                         = new_references.last_name,
        address1                          = new_references.address1,
        address2                          = new_references.address2,
        address3                          = new_references.address3,
        address4                          = new_references.address4,
        city                              = new_references.city,
        state                             = new_references.state,
        province                          = new_references.province,
        county                            = new_references.county,
        country                           = new_references.country,
        sex                               = new_references.sex,
        birth_dt                          = new_references.birth_dt,
        ssn_no                            = new_references.ssn_no,
        marital_status                    = new_references.marital_status,
        visa_type                         = new_references.visa_type,
        visa_category                     = new_references.visa_category,
        visa_number                       = new_references.visa_number,
        visa_expiry_dt                    = new_references.visa_expiry_dt,
        entry_date                        = new_references.entry_date,
        fund_id                           = new_references.fund_id,
        threshold_perct                   = new_references.threshold_perct,
        threshold_value                   = new_references.threshold_value,
        accepted_amnt                     = new_references.accepted_amnt,
        aw_cal_type                       = new_references.aw_cal_type,
        aw_sequence_number                = new_references.aw_sequence_number,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        award_id                          = x_award_id,
        authorization_date                = x_authorization_date,
        notification_date                 = x_notification_date
      WHERE rowid = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sequence_no                       IN OUT NOCOPY NUMBER,
    x_auth_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_first_name                        IN     VARCHAR2,
    x_last_name                         IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_ssn_no                            IN     VARCHAR2,
    x_marital_status                    IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_visa_category                     IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_expiry_dt                    IN     DATE,
    x_entry_date                        IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_accepted_amnt                     IN     NUMBER,
    x_aw_cal_type                       IN     VARCHAR2,
    x_aw_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_award_id                          IN     NUMBER,
    x_authorization_date                IN     DATE,
    x_notification_date                 IN     DATE
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_se_auth
      WHERE    sequence_no                       = x_sequence_no;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_sequence_no,
        x_auth_id,
        x_flag,
        x_person_id,
        x_first_name,
        x_last_name,
        x_address1,
        x_address2,
        x_address3,
        x_address4,
        x_city,
        x_state,
        x_province,
        x_county,
        x_country,
        x_sex,
        x_birth_dt,
        x_ssn_no,
        x_marital_status,
        x_visa_type,
        x_visa_category,
        x_visa_number,
        x_visa_expiry_dt,
        x_entry_date,
        x_fund_id,
        x_threshold_perct,
        x_threshold_value,
        x_accepted_amnt,
        x_aw_cal_type,
        x_aw_sequence_number,
        x_mode,
        x_award_id,
        x_authorization_date,
        x_notification_date
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sequence_no,
      x_auth_id,
      x_flag,
      x_person_id,
      x_first_name,
      x_last_name,
      x_address1,
      x_address2,
      x_address3,
      x_address4,
      x_city,
      x_state,
      x_province,
      x_county,
      x_country,
      x_sex,
      x_birth_dt,
      x_ssn_no,
      x_marital_status,
      x_visa_type,
      x_visa_category,
      x_visa_number,
      x_visa_expiry_dt,
      x_entry_date,
      x_fund_id,
      x_threshold_perct,
      x_threshold_value,
      x_accepted_amnt,
      x_aw_cal_type,
      x_aw_sequence_number,
      x_mode,
      x_award_id,
      x_authorization_date,
      x_notification_date
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 31-DEC-2001
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

    DELETE FROM igf_se_auth
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_se_auth_pkg;

/
