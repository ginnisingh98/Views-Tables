--------------------------------------------------------
--  DDL for Package Body IGS_UC_APP_ADDRESES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_APP_ADDRESES_PKG" AS
/* $Header: IGSXI50B.pls 120.1 2006/08/21 03:37:17 jbaber noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_app_addreses%ROWTYPE;
  new_references igs_uc_app_addreses%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_address_area                      IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_post_code                         IN     VARCHAR2,
    x_mail_sort                         IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_home_address1                     IN     VARCHAR2,
    x_home_address2                     IN     VARCHAR2,
    x_home_address3                     IN     VARCHAR2,
    x_home_address4                     IN     VARCHAR2,
    x_home_postcode                     IN     VARCHAR2,
    x_home_phone                        IN     VARCHAR2,
    x_home_fax                          IN     VARCHAR2,
    x_home_email                        IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_ad_batch_id                       IN     NUMBER,
    x_ad_interface_id                   IN     NUMBER,
    x_mobile                            IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
    x_home_country_code                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_uc_app_addreses
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
    new_references.app_no                            := x_app_no;
    new_references.address_area                      := x_address_area;
    new_references.address1                          := x_address1;
    new_references.address2                          := x_address2;
    new_references.address3                          := x_address3;
    new_references.address4                          := x_address4;
    new_references.post_code                         := x_post_code;
    new_references.mail_sort                         := x_mail_sort;
    new_references.telephone                         := x_telephone;
    new_references.fax                               := x_fax;
    new_references.email                             := x_email;
    new_references.home_address1                     := x_home_address1;
    new_references.home_address2                     := x_home_address2;
    new_references.home_address3                     := x_home_address3;
    new_references.home_address4                     := x_home_address4;
    new_references.home_postcode                     := x_home_postcode;
    new_references.home_phone                        := x_home_phone;
    new_references.home_fax                          := x_home_fax;
    new_references.home_email                        := x_home_email;
    new_references.sent_to_oss_flag                  := x_sent_to_oss_flag;
    new_references.ad_batch_id                       := x_ad_batch_id;
    new_references.ad_interface_id                   := x_ad_interface_id;
    new_references.mobile                            := x_mobile;
    new_references.country_code                      := x_country_code;
    new_references.home_country_code                 := x_home_country_code;

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
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.app_no
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.app_no = new_references.app_no)) OR
        ((new_references.app_no IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_applicants_pkg.get_uk_For_validation (
                new_references.app_no
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_uk_for_validation (
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_addreses
      WHERE    app_no = x_app_no
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


  PROCEDURE get_ufk_igs_uc_applicants (
    x_app_no                            IN     NUMBER
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_addreses
      WHERE   ((app_no = x_app_no));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UAADDR_UCAP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_uc_applicants;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_address_area                      IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_post_code                         IN     VARCHAR2,
    x_mail_sort                         IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_home_address1                     IN     VARCHAR2,
    x_home_address2                     IN     VARCHAR2,
    x_home_address3                     IN     VARCHAR2,
    x_home_address4                     IN     VARCHAR2,
    x_home_postcode                     IN     VARCHAR2,
    x_home_phone                        IN     VARCHAR2,
    x_home_fax                          IN     VARCHAR2,
    x_home_email                        IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_ad_batch_id                       IN     NUMBER,
    x_ad_interface_id                   IN     NUMBER,
    x_mobile                            IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
    x_home_country_code                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
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
      x_app_no,
      x_address_area,
      x_address1,
      x_address2,
      x_address3,
      x_address4,
      x_post_code,
      x_mail_sort,
      x_telephone,
      x_fax,
      x_email,
      x_home_address1,
      x_home_address2,
      x_home_address3,
      x_home_address4,
      x_home_postcode,
      x_home_phone,
      x_home_fax,
      x_home_email,
      x_sent_to_oss_flag,
      x_ad_batch_id,
      x_ad_interface_id,
      x_mobile,
      x_country_code,
      x_home_country_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_address_area                      IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_post_code                         IN     VARCHAR2,
    x_mail_sort                         IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_home_address1                     IN     VARCHAR2,
    x_home_address2                     IN     VARCHAR2,
    x_home_address3                     IN     VARCHAR2,
    x_home_address4                     IN     VARCHAR2,
    x_home_postcode                     IN     VARCHAR2,
    x_home_phone                        IN     VARCHAR2,
    x_home_fax                          IN     VARCHAR2,
    x_home_email                        IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_ad_batch_id                       IN     NUMBER,
    x_ad_interface_id                   IN     NUMBER,
    x_mobile                            IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
    x_home_country_code                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_APP_ADDRESES_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_app_no                            => x_app_no,
      x_address_area                      => x_address_area,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_post_code                         => x_post_code,
      x_mail_sort                         => x_mail_sort,
      x_telephone                         => x_telephone,
      x_fax                               => x_fax,
      x_email                             => x_email,
      x_home_address1                     => x_home_address1,
      x_home_address2                     => x_home_address2,
      x_home_address3                     => x_home_address3,
      x_home_address4                     => x_home_address4,
      x_home_postcode                     => x_home_postcode,
      x_home_phone                        => x_home_phone,
      x_home_fax                          => x_home_fax,
      x_home_email                        => x_home_email,
      x_sent_to_oss_flag                  => x_sent_to_oss_flag,
      x_ad_batch_id                       => x_ad_batch_id,
      x_ad_interface_id                   => x_ad_interface_id,
      x_mobile                            => x_mobile,
      x_country_code                      => x_country_code,
      x_home_country_code                 => x_home_country_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_app_addreses (
      app_no,
      address_area,
      address1,
      address2,
      address3,
      address4,
      post_code,
      mail_sort,
      telephone,
      fax,
      email,
      home_address1,
      home_address2,
      home_address3,
      home_address4,
      home_postcode,
      home_phone,
      home_fax,
      home_email,
      sent_to_oss_flag,
      ad_batch_id,
      ad_interface_id,
      mobile,
      country_code,
      home_country_code,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.app_no,
      new_references.address_area,
      new_references.address1,
      new_references.address2,
      new_references.address3,
      new_references.address4,
      new_references.post_code,
      new_references.mail_sort,
      new_references.telephone,
      new_references.fax,
      new_references.email,
      new_references.home_address1,
      new_references.home_address2,
      new_references.home_address3,
      new_references.home_address4,
      new_references.home_postcode,
      new_references.home_phone,
      new_references.home_fax,
      new_references.home_email,
      new_references.sent_to_oss_flag,
      new_references.ad_batch_id,
      new_references.ad_interface_id,
      new_references.mobile,
      new_references.country_code,
      new_references.home_country_code,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_address_area                      IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_post_code                         IN     VARCHAR2,
    x_mail_sort                         IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_home_address1                     IN     VARCHAR2,
    x_home_address2                     IN     VARCHAR2,
    x_home_address3                     IN     VARCHAR2,
    x_home_address4                     IN     VARCHAR2,
    x_home_postcode                     IN     VARCHAR2,
    x_home_phone                        IN     VARCHAR2,
    x_home_fax                          IN     VARCHAR2,
    x_home_email                        IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_ad_batch_id                       IN     NUMBER,
    x_ad_interface_id                   IN     NUMBER,
    x_mobile                            IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
    x_home_country_code                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        app_no,
        address_area,
        address1,
        address2,
        address3,
        address4,
        post_code,
        mail_sort,
        telephone,
        fax,
        email,
        home_address1,
        home_address2,
        home_address3,
        home_address4,
        home_postcode,
        home_phone,
        home_fax,
        home_email,
        sent_to_oss_flag,
        ad_batch_id,
        ad_interface_id,
        mobile,
        country_code,
        home_country_code
      FROM  igs_uc_app_addreses
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
        (tlinfo.app_no = x_app_no)
        AND ((tlinfo.address_area = x_address_area) OR ((tlinfo.address_area IS NULL) AND (X_address_area IS NULL)))
        AND ((tlinfo.address1 = x_address1) OR ((tlinfo.address1 IS NULL) AND (X_address1 IS NULL)))
        AND ((tlinfo.address2 = x_address2) OR ((tlinfo.address2 IS NULL) AND (X_address2 IS NULL)))
        AND ((tlinfo.address3 = x_address3) OR ((tlinfo.address3 IS NULL) AND (X_address3 IS NULL)))
        AND ((tlinfo.address4 = x_address4) OR ((tlinfo.address4 IS NULL) AND (X_address4 IS NULL)))
        AND ((tlinfo.post_code = x_post_code) OR ((tlinfo.post_code IS NULL) AND (X_post_code IS NULL)))
        AND ((tlinfo.mail_sort = x_mail_sort) OR ((tlinfo.mail_sort IS NULL) AND (X_mail_sort IS NULL)))
        AND ((tlinfo.telephone = x_telephone) OR ((tlinfo.telephone IS NULL) AND (X_telephone IS NULL)))
        AND ((tlinfo.fax = x_fax) OR ((tlinfo.fax IS NULL) AND (X_fax IS NULL)))
        AND ((tlinfo.email = x_email) OR ((tlinfo.email IS NULL) AND (X_email IS NULL)))
        AND ((tlinfo.home_address1 = x_home_address1) OR ((tlinfo.home_address1 IS NULL) AND (X_home_address1 IS NULL)))
        AND ((tlinfo.home_address2 = x_home_address2) OR ((tlinfo.home_address2 IS NULL) AND (X_home_address2 IS NULL)))
        AND ((tlinfo.home_address3 = x_home_address3) OR ((tlinfo.home_address3 IS NULL) AND (X_home_address3 IS NULL)))
        AND ((tlinfo.home_address4 = x_home_address4) OR ((tlinfo.home_address4 IS NULL) AND (X_home_address4 IS NULL)))
        AND ((tlinfo.home_postcode = x_home_postcode) OR ((tlinfo.home_postcode IS NULL) AND (X_home_postcode IS NULL)))
        AND ((tlinfo.home_phone = x_home_phone) OR ((tlinfo.home_phone IS NULL) AND (X_home_phone IS NULL)))
        AND ((tlinfo.home_fax = x_home_fax) OR ((tlinfo.home_fax IS NULL) AND (X_home_fax IS NULL)))
        AND ((tlinfo.home_email = x_home_email) OR ((tlinfo.home_email IS NULL) AND (X_home_email IS NULL)))
        AND (tlinfo.sent_to_oss_flag = x_sent_to_oss_flag)
        AND ((tlinfo.ad_batch_id = x_ad_batch_id) OR ((tlinfo.ad_batch_id IS NULL) AND (X_ad_batch_id IS NULL)))
        AND ((tlinfo.ad_interface_id = x_ad_interface_id) OR ((tlinfo.ad_interface_id IS NULL) AND (X_ad_interface_id IS NULL)))
        AND ((tlinfo.mobile = x_mobile) OR ((tlinfo.mobile IS NULL) AND (X_mobile IS NULL)))
        AND ((tlinfo.country_code = x_country_code) OR ((tlinfo.country_code IS NULL) AND (X_country_code IS NULL)))
        AND ((tlinfo.home_country_code = x_home_country_code) OR ((tlinfo.home_country_code IS NULL) AND (X_home_country_code IS NULL)))
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
    x_app_no                            IN     NUMBER,
    x_address_area                      IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_post_code                         IN     VARCHAR2,
    x_mail_sort                         IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_home_address1                     IN     VARCHAR2,
    x_home_address2                     IN     VARCHAR2,
    x_home_address3                     IN     VARCHAR2,
    x_home_address4                     IN     VARCHAR2,
    x_home_postcode                     IN     VARCHAR2,
    x_home_phone                        IN     VARCHAR2,
    x_home_fax                          IN     VARCHAR2,
    x_home_email                        IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_ad_batch_id                       IN     NUMBER,
    x_ad_interface_id                   IN     NUMBER,
    x_mobile                            IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
    x_home_country_code                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_APP_ADDRESES_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_app_no                            => x_app_no,
      x_address_area                      => x_address_area,
      x_address1                          => x_address1,
      x_address2                          => x_address2,
      x_address3                          => x_address3,
      x_address4                          => x_address4,
      x_post_code                         => x_post_code,
      x_mail_sort                         => x_mail_sort,
      x_telephone                         => x_telephone,
      x_fax                               => x_fax,
      x_email                             => x_email,
      x_home_address1                     => x_home_address1,
      x_home_address2                     => x_home_address2,
      x_home_address3                     => x_home_address3,
      x_home_address4                     => x_home_address4,
      x_home_postcode                     => x_home_postcode,
      x_home_phone                        => x_home_phone,
      x_home_fax                          => x_home_fax,
      x_home_email                        => x_home_email,
      x_sent_to_oss_flag                  => x_sent_to_oss_flag,
      x_ad_batch_id                       => x_ad_batch_id,
      x_ad_interface_id                   => x_ad_interface_id,
      x_mobile                            => x_mobile,
      x_country_code                      => x_country_code,
      x_home_country_code                 => x_home_country_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_app_addreses
      SET
        app_no                            = new_references.app_no,
        address_area                      = new_references.address_area,
        address1                          = new_references.address1,
        address2                          = new_references.address2,
        address3                          = new_references.address3,
        address4                          = new_references.address4,
        post_code                         = new_references.post_code,
        mail_sort                         = new_references.mail_sort,
        telephone                         = new_references.telephone,
        fax                               = new_references.fax,
        email                             = new_references.email,
        home_address1                     = new_references.home_address1,
        home_address2                     = new_references.home_address2,
        home_address3                     = new_references.home_address3,
        home_address4                     = new_references.home_address4,
        home_postcode                     = new_references.home_postcode,
        home_phone                        = new_references.home_phone,
        home_fax                          = new_references.home_fax,
        home_email                        = new_references.home_email,
        sent_to_oss_flag                  = new_references.sent_to_oss_flag,
        ad_batch_id                       = new_references.ad_batch_id,
        ad_interface_id                   = new_references.ad_interface_id,
        mobile                            = new_references.mobile,
        country_code                      = new_references.country_code,
        home_country_code                 = new_references.home_country_code,
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
    x_app_no                            IN     NUMBER,
    x_address_area                      IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_post_code                         IN     VARCHAR2,
    x_mail_sort                         IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_home_address1                     IN     VARCHAR2,
    x_home_address2                     IN     VARCHAR2,
    x_home_address3                     IN     VARCHAR2,
    x_home_address4                     IN     VARCHAR2,
    x_home_postcode                     IN     VARCHAR2,
    x_home_phone                        IN     VARCHAR2,
    x_home_fax                          IN     VARCHAR2,
    x_home_email                        IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_ad_batch_id                       IN     NUMBER,
    x_ad_interface_id                   IN     NUMBER,
    x_mobile                            IN     VARCHAR2,
    x_country_code                      IN     VARCHAR2,
    x_home_country_code                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_app_addreses
      WHERE    app_no = x_app_no;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_app_no,
        x_address_area,
        x_address1,
        x_address2,
        x_address3,
        x_address4,
        x_post_code,
        x_mail_sort,
        x_telephone,
        x_fax,
        x_email,
        x_home_address1,
        x_home_address2,
        x_home_address3,
        x_home_address4,
        x_home_postcode,
        x_home_phone,
        x_home_fax,
        x_home_email,
        x_sent_to_oss_flag,
        x_ad_batch_id,
        x_ad_interface_id,
        x_mobile,
        x_country_code,
        x_home_country_code,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_app_no,
      x_address_area,
      x_address1,
      x_address2,
      x_address3,
      x_address4,
      x_post_code,
      x_mail_sort,
      x_telephone,
      x_fax,
      x_email,
      x_home_address1,
      x_home_address2,
      x_home_address3,
      x_home_address4,
      x_home_postcode,
      x_home_phone,
      x_home_fax,
      x_home_email,
      x_sent_to_oss_flag,
      x_ad_batch_id,
      x_ad_interface_id,
      x_mobile,
      x_country_code,
      x_home_country_code,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
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

    DELETE FROM igs_uc_app_addreses
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_app_addreses_pkg;

/
