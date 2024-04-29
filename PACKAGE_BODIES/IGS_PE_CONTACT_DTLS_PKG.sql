--------------------------------------------------------
--  DDL for Package Body IGS_PE_CONTACT_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_CONTACT_DTLS_PKG" AS
/* $Header: IGSNI73B.pls 120.1 2005/06/28 05:13:47 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_contact_dtls%ROWTYPE;
  new_references igs_pe_contact_dtls%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_phone_line_type IN VARCHAR2 DEFAULT NULL,
    x_contact_point_id IN NUMBER DEFAULT NULL,
    x_location_venue_addr_id IN NUMBER DEFAULT NULL,
    x_contact_point_type IN VARCHAR2 DEFAULT NULL,
    x_status IN VARCHAR2 DEFAULT NULL,
    x_primary_flag IN VARCHAR2 DEFAULT NULL,
    x_email_format IN VARCHAR2 DEFAULT NULL,
    x_email_address IN VARCHAR2 DEFAULT NULL,
    x_telephone_type IN VARCHAR2 DEFAULT NULL,
    x_phone_area_code IN VARCHAR2 DEFAULT NULL,
    x_phone_country_code IN VARCHAR2 DEFAULT NULL,
    x_phone_number IN VARCHAR2 DEFAULT NULL,
    x_phone_extension IN VARCHAR2 DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_CONTACT_DTLS
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
    new_references.phone_line_type := x_phone_line_type;
    new_references.contact_point_id := x_contact_point_id;
    new_references.location_venue_addr_id := x_location_venue_addr_id;
    new_references.contact_point_type := x_contact_point_type;
    new_references.status := x_status;
    new_references.primary_flag := x_primary_flag;
    new_references.email_format := x_email_format;
    new_references.email_address := x_email_address;
    new_references.telephone_type := x_telephone_type;
    new_references.phone_area_code := x_phone_area_code;
    new_references.phone_country_code := x_phone_country_code;
    new_references.phone_number := x_phone_number;
    new_references.phone_extension := x_phone_extension;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;

    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;

  END set_column_values;

  PROCEDURE check_constraints (
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value IN VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (column_name IS NULL) THEN
      NULL;
      NULL;
    END IF;




  END check_constraints;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.location_venue_addr_id = new_references.location_venue_addr_id)) OR
        ((new_references.location_venue_addr_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_locvenue_addr_pkg.get_pk_for_validation (
            new_references.location_venue_addr_id
        )  THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_contact_point_id IN NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_contact_dtls
      WHERE    contact_point_id = x_contact_point_id
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

 PROCEDURE get_fk_igs_ad_locvenue_addr (
   x_location_venue_addr_id IN NUMBER
    ) AS

  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_contact_dtls
      WHERE    location_venue_addr_id = x_location_venue_addr_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_locvenue_addr;

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_phone_line_type IN VARCHAR2 DEFAULT NULL,
    x_contact_point_id IN NUMBER DEFAULT NULL,
    x_location_venue_addr_id IN NUMBER DEFAULT NULL,
    x_contact_point_type IN VARCHAR2 DEFAULT NULL,
    x_status IN VARCHAR2 DEFAULT NULL,
    x_primary_flag IN VARCHAR2 DEFAULT NULL,
    x_email_format IN VARCHAR2 DEFAULT NULL,
    x_email_address IN VARCHAR2 DEFAULT NULL,
    x_telephone_type IN VARCHAR2 DEFAULT NULL,
    x_phone_area_code IN VARCHAR2 DEFAULT NULL,
    x_phone_country_code IN VARCHAR2 DEFAULT NULL,
    x_phone_number IN VARCHAR2 DEFAULT NULL,
    x_phone_extension IN VARCHAR2 DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_phone_line_type,
      x_contact_point_id,
      x_location_venue_addr_id,
      x_contact_point_type,
      x_status,
      x_primary_flag,
      x_email_format,
      x_email_address,
      x_telephone_type,
      x_phone_area_code,
      x_phone_country_code,
      x_phone_number,
      x_phone_extension,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
      IF (get_pk_for_validation(
            new_references.contact_point_id)) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
 check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF (get_pk_for_validation (
            new_references.contact_point_id)) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
    END IF;

  END before_dml;

  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END after_dml;

  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_phone_line_type IN VARCHAR2,
    x_contact_point_id IN OUT NOCOPY NUMBER,
    x_location_venue_addr_id IN NUMBER,
    x_contact_point_type IN VARCHAR2,
    x_status IN VARCHAR2,
    x_primary_flag IN VARCHAR2,
    x_email_format IN VARCHAR2,
    x_email_address IN VARCHAR2,
    x_telephone_type IN VARCHAR2,
    x_phone_area_code IN VARCHAR2,
    x_phone_country_code IN VARCHAR2,
    x_phone_number IN VARCHAR2,
    x_phone_extension IN VARCHAR2,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pe_contact_dtls
      WHERE    contact_point_id = x_contact_point_id
    ;

    x_last_update_date DATE;
    x_last_updated_by NUMBER;
    x_last_update_login NUMBER;
    x_request_id NUMBER;
    x_program_id NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date DATE;

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
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id := NULL;
        x_program_id := NULL;
        x_program_application_id := NULL;
        x_program_update_date := NULL;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT igs_pe_contact_dtls_s.nextval INTO x_contact_point_id
    FROM dual;

    before_dml(
      p_action => 'INSERT',
      x_rowid => X_ROWID,
      x_phone_line_type => x_phone_line_type,
      x_contact_point_id => x_contact_point_id,
      x_location_venue_addr_id => x_location_venue_addr_id,
      x_contact_point_type => x_contact_point_type,
      x_status => x_status,
      x_primary_flag => x_primary_flag,
      x_email_format => x_email_format,
      x_email_address => x_email_address,
      x_telephone_type => x_telephone_type,
      x_phone_area_code => x_phone_area_code,
      x_phone_country_code => x_phone_country_code,
      x_phone_number => x_phone_number,
      x_phone_extension => x_phone_extension,
      x_attribute_category => x_attribute_category,
      x_attribute1 => x_attribute1,
      x_attribute2 => x_attribute2,
      x_attribute3 => x_attribute3,
      x_attribute4 => x_attribute4,
      x_attribute5 => x_attribute5,
      x_attribute6 => x_attribute6,
      x_attribute7 => x_attribute7,
      x_attribute8 => x_attribute8,
      x_attribute9 => x_attribute9,
      x_attribute10 => x_attribute10,
      x_attribute11 => x_attribute11,
      x_attribute12 => x_attribute12,
      x_attribute13 => x_attribute13,
      x_attribute14 => x_attribute14,
      x_attribute15 => x_attribute15,
      x_attribute16 => x_attribute16,
      x_attribute17 => x_attribute17,
      x_attribute18 => x_attribute18,
      x_attribute19 => x_attribute19,
      x_attribute20 => x_attribute20,
      x_creation_date => x_last_update_date,
      x_created_by => x_last_updated_by,
      x_last_update_date => x_last_update_date,
      x_last_updated_by => x_last_updated_by,
      x_last_update_login => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_contact_dtls (
      phone_line_type
      ,contact_point_id
      ,location_venue_addr_id
      ,contact_point_type
      ,status
      ,primary_flag
      ,email_format
      ,email_address
      ,telephone_type
      ,phone_area_code
      ,phone_country_code
      ,phone_number
      ,phone_extension
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,request_id
      ,program_id
      ,program_application_id
      ,program_update_date
    ) VALUES (
      new_references.phone_line_type
      ,new_references.contact_point_id
      ,new_references.location_venue_addr_id
      ,new_references.contact_point_type
      ,new_references.status
      ,new_references.primary_flag
      ,new_references.email_format
      ,new_references.email_address
      ,new_references.telephone_type
      ,new_references.phone_area_code
      ,new_references.phone_country_code
      ,new_references.phone_number
      ,new_references.phone_extension
      ,new_references.attribute_category
      ,new_references.attribute1
      ,new_references.attribute2
      ,new_references.attribute3
      ,new_references.attribute4
      ,new_references.attribute5
      ,new_references.attribute6
      ,new_references.attribute7
      ,new_references.attribute8
      ,new_references.attribute9
      ,new_references.attribute10
      ,new_references.attribute11
      ,new_references.attribute12
      ,new_references.attribute13
      ,new_references.attribute14
      ,new_references.attribute15
      ,new_references.attribute16
      ,new_references.attribute17
      ,new_references.attribute18
      ,new_references.attribute19
      ,new_references.attribute20
      ,x_last_update_date
      ,x_last_updated_by
      ,x_last_update_date
      ,x_last_updated_by
      ,x_last_update_login
      ,x_request_id
      ,x_program_id
      ,x_program_application_id
      ,x_program_update_date
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

    after_dml (
      p_action => 'INSERT' ,
      x_rowid => X_ROWID
    );


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
    x_rowid IN VARCHAR2,
    x_phone_line_type IN VARCHAR2,
    x_contact_point_id IN NUMBER,
    x_location_venue_addr_id IN NUMBER,
    x_contact_point_type IN VARCHAR2,
    x_status IN VARCHAR2,
    x_primary_flag IN VARCHAR2,
    x_email_format IN VARCHAR2,
    x_email_address IN VARCHAR2,
    x_telephone_type IN VARCHAR2,
    x_phone_area_code IN VARCHAR2,
    x_phone_country_code IN VARCHAR2,
    x_phone_number IN VARCHAR2,
    x_phone_extension IN VARCHAR2,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS SELECT
      phone_line_type
,      location_venue_addr_id
,      contact_point_type
,      status
,      primary_flag
,      email_format
,      email_address
,      telephone_type
,      phone_area_code
,      phone_country_code
,      phone_number
,      phone_extension
,      attribute_category
,      attribute1
,      attribute2
,      attribute3
,      attribute4
,      attribute5
,      attribute6
,      attribute7
,      attribute8
,      attribute9
,      attribute10
,      attribute11
,      attribute12
,      attribute13
,      attribute14
,      attribute15
,      attribute16
,      attribute17
,      attribute18
,      attribute19
,      attribute20
    FROM igs_pe_contact_dtls
    WHERE ROWID = x_rowid
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

    IF ((  (tlinfo.PHONE_LINE_TYPE = x_PHONE_LINE_TYPE)
       OR ((tlinfo.PHONE_LINE_TYPE is null)
      AND (X_PHONE_LINE_TYPE is null)))
      AND (tlinfo.LOCATION_VENUE_ADDR_ID = x_LOCATION_VENUE_ADDR_ID)
      AND (tlinfo.CONTACT_POINT_TYPE = x_CONTACT_POINT_TYPE)
      AND (tlinfo.STATUS = x_STATUS)
      AND ((tlinfo.PRIMARY_FLAG = x_PRIMARY_FLAG)
       OR ((tlinfo.PRIMARY_FLAG is null)
      AND (X_PRIMARY_FLAG is null)))
      AND ((tlinfo.EMAIL_FORMAT = x_EMAIL_FORMAT)
       OR ((tlinfo.EMAIL_FORMAT is null)
      AND (X_EMAIL_FORMAT is null)))
      AND ((tlinfo.EMAIL_ADDRESS = x_EMAIL_ADDRESS)
       OR ((tlinfo.EMAIL_ADDRESS is null)
      AND (X_EMAIL_ADDRESS is null)))
      AND ((tlinfo.TELEPHONE_TYPE = x_TELEPHONE_TYPE)
       OR ((tlinfo.TELEPHONE_TYPE is null)
      AND (X_TELEPHONE_TYPE is null)))
      AND ((tlinfo.PHONE_AREA_CODE = x_PHONE_AREA_CODE)
       OR ((tlinfo.PHONE_AREA_CODE is null)
      AND (X_PHONE_AREA_CODE is null)))
      AND ((tlinfo.PHONE_COUNTRY_CODE = x_PHONE_COUNTRY_CODE)
       OR ((tlinfo.PHONE_COUNTRY_CODE is null)
      AND (X_PHONE_COUNTRY_CODE is null)))
      AND ((tlinfo.PHONE_NUMBER = x_PHONE_NUMBER)
       OR ((tlinfo.PHONE_NUMBER is null)
      AND (X_PHONE_NUMBER is null)))
      AND ((tlinfo.PHONE_EXTENSION = x_PHONE_EXTENSION)
       OR ((tlinfo.PHONE_EXTENSION is null)
      AND (X_PHONE_EXTENSION is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = x_ATTRIBUTE_CATEGORY)
       OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
      AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.ATTRIBUTE1 = x_ATTRIBUTE1)
       OR ((tlinfo.ATTRIBUTE1 is null)
      AND (X_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = x_ATTRIBUTE2)
       OR ((tlinfo.ATTRIBUTE2 is null)
      AND (X_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = x_ATTRIBUTE3)
       OR ((tlinfo.ATTRIBUTE3 is null)
      AND (X_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = x_ATTRIBUTE4)
       OR ((tlinfo.ATTRIBUTE4 is null)
      AND (X_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = x_ATTRIBUTE5)
       OR ((tlinfo.ATTRIBUTE5 is null)
      AND (X_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = x_ATTRIBUTE6)
       OR ((tlinfo.ATTRIBUTE6 is null)
      AND (X_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = x_ATTRIBUTE7)
       OR ((tlinfo.ATTRIBUTE7 is null)
      AND (X_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = x_ATTRIBUTE8)
       OR ((tlinfo.ATTRIBUTE8 is null)
      AND (X_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = x_ATTRIBUTE9)
       OR ((tlinfo.ATTRIBUTE9 is null)
      AND (X_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = x_ATTRIBUTE10)
       OR ((tlinfo.ATTRIBUTE10 is null)
      AND (X_ATTRIBUTE10 is null)))
      AND ((tlinfo.ATTRIBUTE11 = x_ATTRIBUTE11)
       OR ((tlinfo.ATTRIBUTE11 is null)
      AND (X_ATTRIBUTE11 is null)))
      AND ((tlinfo.ATTRIBUTE12 = x_ATTRIBUTE12)
       OR ((tlinfo.ATTRIBUTE12 is null)
      AND (X_ATTRIBUTE12 is null)))
      AND ((tlinfo.ATTRIBUTE13 = x_ATTRIBUTE13)
       OR ((tlinfo.ATTRIBUTE13 is null)
      AND (X_ATTRIBUTE13 is null)))
      AND ((tlinfo.ATTRIBUTE14 = x_ATTRIBUTE14)
       OR ((tlinfo.ATTRIBUTE14 is null)
      AND (X_ATTRIBUTE14 is null)))
      AND ((tlinfo.ATTRIBUTE15 = x_ATTRIBUTE15)
       OR ((tlinfo.ATTRIBUTE15 is null)
      AND (X_ATTRIBUTE15 is null)))
      AND ((tlinfo.ATTRIBUTE16 = x_ATTRIBUTE16)
       OR ((tlinfo.ATTRIBUTE16 is null)
      AND (X_ATTRIBUTE16 is null)))
      AND ((tlinfo.ATTRIBUTE17 = x_ATTRIBUTE17)
       OR ((tlinfo.ATTRIBUTE17 is null)
      AND (X_ATTRIBUTE17 is null)))
      AND ((tlinfo.ATTRIBUTE18 = x_ATTRIBUTE18)
       OR ((tlinfo.ATTRIBUTE18 is null)
      AND (X_ATTRIBUTE18 is null)))
      AND ((tlinfo.ATTRIBUTE19 = x_ATTRIBUTE19)
       OR ((tlinfo.ATTRIBUTE19 is null)
      AND (X_ATTRIBUTE19 is null)))
      AND ((tlinfo.ATTRIBUTE20 = x_ATTRIBUTE20)
       OR ((tlinfo.ATTRIBUTE20 is null)
      AND (X_ATTRIBUTE20 is null)))
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
    x_rowid IN  VARCHAR2,
    x_PHONE_LINE_TYPE IN VARCHAR2,
    x_CONTACT_POINT_ID IN NUMBER,
    x_LOCATION_VENUE_ADDR_ID IN NUMBER,
    x_CONTACT_POINT_TYPE IN VARCHAR2,
    x_STATUS IN VARCHAR2,
    x_PRIMARY_FLAG IN VARCHAR2,
    x_EMAIL_FORMAT IN VARCHAR2,
    x_EMAIL_ADDRESS IN VARCHAR2,
    x_TELEPHONE_TYPE IN VARCHAR2,
    x_PHONE_AREA_CODE IN VARCHAR2,
    x_PHONE_COUNTRY_CODE IN VARCHAR2,
    x_PHONE_NUMBER IN VARCHAR2,
    x_PHONE_EXTENSION IN VARCHAR2,
    x_ATTRIBUTE_CATEGORY IN VARCHAR2,
    x_ATTRIBUTE1 IN VARCHAR2,
    x_ATTRIBUTE2 IN VARCHAR2,
    x_ATTRIBUTE3 IN VARCHAR2,
    x_ATTRIBUTE4 IN VARCHAR2,
    x_ATTRIBUTE5 IN VARCHAR2,
    x_ATTRIBUTE6 IN VARCHAR2,
    x_ATTRIBUTE7 IN VARCHAR2,
    x_ATTRIBUTE8 IN VARCHAR2,
    x_ATTRIBUTE9 IN VARCHAR2,
    x_ATTRIBUTE10 IN VARCHAR2,
    x_ATTRIBUTE11 IN VARCHAR2,
    x_ATTRIBUTE12 IN VARCHAR2,
    x_ATTRIBUTE13 IN VARCHAR2,
    x_ATTRIBUTE14 IN VARCHAR2,
    x_ATTRIBUTE15 IN VARCHAR2,
    x_ATTRIBUTE16 IN VARCHAR2,
    x_ATTRIBUTE17 IN VARCHAR2,
    x_ATTRIBUTE18 IN VARCHAR2,
    x_ATTRIBUTE19 IN VARCHAR2,
    x_ATTRIBUTE20 IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date DATE ;
    x_last_updated_by NUMBER ;
    x_last_update_login NUMBER ;
    x_request_id NUMBER;
    x_program_id NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date DATE;

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
      p_action=>'UPDATE',
      x_rowid=>X_ROWID,
      x_phone_line_type => x_PHONE_LINE_TYPE,
      x_contact_point_id => x_CONTACT_POINT_ID,
      x_location_venue_addr_id => x_LOCATION_VENUE_ADDR_ID,
      x_contact_point_type => x_CONTACT_POINT_TYPE,
      x_status => x_STATUS,
      x_primary_flag => x_PRIMARY_FLAG,
      x_email_format => x_EMAIL_FORMAT,
      x_email_address => x_EMAIL_ADDRESS,
      x_telephone_type => x_TELEPHONE_TYPE,
      x_phone_area_code => x_PHONE_AREA_CODE,
      x_phone_country_code => x_PHONE_COUNTRY_CODE,
      x_phone_number => x_PHONE_NUMBER,
      x_phone_extension => x_PHONE_EXTENSION,
      x_attribute_category => x_ATTRIBUTE_CATEGORY,
      x_attribute1 => x_ATTRIBUTE1,
      x_attribute2 => x_ATTRIBUTE2,
      x_attribute3 => x_ATTRIBUTE3,
      x_attribute4 => x_ATTRIBUTE4,
      x_attribute5 => x_ATTRIBUTE5,
      x_attribute6 => x_ATTRIBUTE6,
      x_attribute7 => x_ATTRIBUTE7,
      x_attribute8 => x_ATTRIBUTE8,
      x_attribute9 => x_ATTRIBUTE9,
      x_attribute10 => x_ATTRIBUTE10,
      x_attribute11 => x_ATTRIBUTE11,
      x_attribute12 => x_ATTRIBUTE12,
      x_attribute13 => x_ATTRIBUTE13,
      x_attribute14 => x_ATTRIBUTE14,
      x_attribute15 => x_ATTRIBUTE15,
      x_attribute16 => x_ATTRIBUTE16,
      x_attribute17 => x_ATTRIBUTE17,
      x_attribute18 => x_ATTRIBUTE18,
      x_attribute19 => x_ATTRIBUTE19,
      x_attribute20 => x_ATTRIBUTE20,
      x_creation_date=>x_last_update_date,
      x_created_by=>x_last_updated_by,
      x_last_update_date=>x_last_update_date,
      x_last_updated_by=>x_last_updated_by,
      x_last_update_login=>x_last_update_login
    );

    IF (X_MODE IN ('R', 'S')) THEN
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

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_contact_dtls SET
      phone_line_type =  new_references.phone_line_type,
      location_venue_addr_id =  new_references.location_venue_addr_id,
      contact_point_type =  new_references.contact_point_type,
      status =  new_references.status,
      primary_flag =  new_references.primary_flag,
      email_format =  new_references.email_format,
      email_address =  new_references.email_address,
      telephone_type =  new_references.telephone_type,
      phone_area_code =  new_references.phone_area_code,
      phone_country_code =  new_references.phone_country_code,
      phone_number =  new_references.phone_number,
      phone_extension =  new_references.phone_extension,
      attribute_category =  new_references.attribute_category,
      attribute1 =  new_references.attribute1,
      attribute2 =  new_references.attribute2,
      attribute3 =  new_references.attribute3,
      attribute4 =  new_references.attribute4,
      attribute5 =  new_references.attribute5,
      attribute6 =  new_references.attribute6,
      attribute7 =  new_references.attribute7,
      attribute8 =  new_references.attribute8,
      attribute9 =  new_references.attribute9,
      attribute10 =  new_references.attribute10,
      attribute11 =  new_references.attribute11,
      attribute12 =  new_references.attribute12,
      attribute13 =  new_references.attribute13,
      attribute14 =  new_references.attribute14,
      attribute15 =  new_references.attribute15,
      attribute16 =  new_references.attribute16,
      attribute17 =  new_references.attribute17,
      attribute18 =  new_references.attribute18,
      attribute19 =  new_references.attribute19,
      attribute20 =  new_references.attribute20,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by,
      last_update_login = x_last_update_login ,
      request_id = x_request_id,
      program_id = x_program_id,
      program_application_id = x_program_application_id,
      program_update_date = x_program_update_date
    WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    after_dml (
      p_action => 'UPDATE',
      x_rowid => X_ROWID
    );


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
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_phone_line_type IN VARCHAR2,
    x_contact_point_id IN OUT NOCOPY NUMBER,
    x_location_venue_addr_id IN NUMBER,
    x_contact_point_type IN VARCHAR2,
    x_status IN VARCHAR2,
    x_primary_flag IN VARCHAR2,
    x_email_format IN VARCHAR2,
    x_email_address IN VARCHAR2,
    x_telephone_type IN VARCHAR2,
    x_phone_area_code IN VARCHAR2,
    x_phone_country_code IN VARCHAR2,
    x_phone_number IN VARCHAR2,
    x_phone_extension IN VARCHAR2,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS SELECT rowid FROM igs_pe_contact_dtls
             WHERE     contact_point_id = x_contact_point_id
    ;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_phone_line_type,
        x_contact_point_id,
        x_location_venue_addr_id,
        x_contact_point_type,
        x_status,
        x_primary_flag,
        x_email_format,
        x_email_address,
        x_telephone_type,
        x_phone_area_code,
        x_phone_country_code,
        x_phone_number,
        x_phone_extension,
        x_attribute_category,
        x_attribute1,
        x_attribute2,
        x_attribute3,
        x_attribute4,
        x_attribute5,
        x_attribute6,
        x_attribute7,
        x_attribute8,
        x_attribute9,
        x_attribute10,
        x_attribute11,
        x_attribute12,
        x_attribute13,
        x_attribute14,
        x_attribute15,
        x_attribute16,
        x_attribute17,
        x_attribute18,
        x_attribute19,
        x_attribute20,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_phone_line_type,
      x_contact_point_id,
      x_location_venue_addr_id,
      x_contact_point_type,
      x_status,
      x_primary_flag,
      x_email_format,
      x_email_address,
      x_telephone_type,
      x_phone_area_code,
      x_phone_country_code,
      x_phone_number,
      x_phone_extension,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_mode
    );

  END add_row;

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Date Created By :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => X_ROWID
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_pe_contact_dtls
    WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    after_dml (
      p_action => 'DELETE',
      x_rowid => X_ROWID
    );

  END delete_row;

END igs_pe_contact_dtls_pkg;

/
