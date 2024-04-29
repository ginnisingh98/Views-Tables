--------------------------------------------------------
--  DDL for Package Body IGS_PE_IMMU_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_IMMU_DTLS_PKG" AS
/* $Header: IGSNI90B.pls 120.3 2005/10/17 02:22:16 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_immu_dtls%ROWTYPE;
  new_references igs_pe_immu_dtls%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,    --DEFAULT NULL,
    x_immu_details_id                   IN     NUMBER ,    -- DEFAULT NULL,
    x_person_id                         IN     NUMBER ,   --  DEFAULT NULL,
    x_immunization_code                 IN     VARCHAR2,  --  DEFAULT NULL,
    x_status_code                       IN     VARCHAR2,  --  DEFAULT NULL,
    x_start_date                        IN     DATE ,     --  DEFAULT NULL,
    x_end_date                          IN     DATE        , -- DEFAULT NULL,
    x_attribute_category		IN     VARCHAR2  , -- DEFAULT NULL,
    x_attribute1			IN     VARCHAR2   , -- DEFAULT NULL,
    x_attribute2			IN     VARCHAR2   , -- DEFAULT NULL,
    x_attribute3			IN	 VARCHAR2   , -- DEFAULT NULL,
    x_attribute4			IN	 VARCHAR2   , -- DEFAULT NULL,
    x_attribute5			IN	 VARCHAR2   , -- DEFAULT NULL,
    x_attribute6			IN	 VARCHAR2   , -- DEFAULT NULL,
    x_attribute7			IN	 VARCHAR2   , -- DEFAULT NULL,
    x_attribute8			IN	 VARCHAR2   , -- DEFAULT NULL,
    x_attribute9			IN	 VARCHAR2   , -- DEFAULT NULL,
    x_attribute10			IN	 VARCHAR2  , -- DEFAULT NULL,
    x_attribute11			IN	 VARCHAR2  , -- DEFAULT NULL,
    x_attribute12			IN	 VARCHAR2  , -- DEFAULT NULL,
    x_attribute13			IN	 VARCHAR2  , -- DEFAULT NULL,
    x_attribute14			IN	 VARCHAR2  , -- DEFAULT NULL,
    x_attribute15			IN	 VARCHAR2  , -- DEFAULT NULL,
    x_attribute16			IN	 VARCHAR2  , -- DEFAULT NULL,
    x_attribute17			IN	 VARCHAR2  , -- DEFAULT NULL,
    x_attribute18			IN	 VARCHAR2  , -- DEFAULT NULL,
    x_attribute19			IN	 VARCHAR2  , -- DEFAULT NULL,
    x_attribute20			IN	 VARCHAR2  , -- DEFAULT NULL,
    x_creation_date                     IN     DATE        , -- DEFAULT NULL,
    x_created_by                        IN     NUMBER      , -- DEFAULT NULL,
    x_last_update_date                  IN     DATE        , -- DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      , -- DEFAULT NULL,
    x_last_update_login                 IN     NUMBER       -- DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_immu_dtls
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
    new_references.immu_details_id                   := x_immu_details_id;
    new_references.person_id                         := x_person_id;
    new_references.immunization_code                 := x_immunization_code;
    new_references.status_code                       := x_status_code;
    new_references.start_date                        := x_start_date;
    new_references.end_date                          := x_end_date;
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


PROCEDURE BeforeRowInsertUpdate(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) as
  ------------------------------------------------------------------------------------------
  --Created by  : vredkar
  --Date created: 19-JUL-2005
  --
  --Purpose:
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------
  CURSOR validate_brth_dt(cp_person_id NUMBER) IS
  SELECT birth_date FROM
  IGS_PE_PERSON_BASE_V
  WHERE person_id =  cp_person_id ;

  l_bth_dt IGS_PE_PERSON_BASE_V.birth_date%TYPE;

  BEGIN
       IF p_inserting OR p_updating THEN
          OPEN validate_brth_dt(new_references.person_id);
          FETCH validate_brth_dt INTO  l_bth_dt;
          CLOSE validate_brth_dt;

          IF new_references.END_DATE IS NOT NULL AND new_references.START_DATE > new_references.END_DATE  THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_FI_ST_DT_LE_END_DT');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;

	 ELSIF  l_bth_dt IS NOT NULL AND l_bth_dt >  new_references.START_DATE  THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_AD_STRT_DT_LESS_BIRTH_DT');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;

     END IF;

 END BeforeRowInsertUpdate;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.person_id,
           new_references.immunization_code,
           new_references.start_date
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_PE_HLTH_IMM_DUP_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_immu_details_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_immu_dtls
      WHERE    immu_details_id = x_immu_details_id
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
    x_immunization_code                 IN     VARCHAR2,
    x_start_date                        IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_immu_dtls
      WHERE    person_id = x_person_id
      AND      immunization_code = x_immunization_code
      AND      start_date = x_start_date
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


  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_immu_dtls
      WHERE   ((person_id = x_party_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_PID_HZ_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_parties;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_immu_details_id                   IN     NUMBER  ,
    x_person_id                         IN     NUMBER  ,
    x_immunization_code                 IN     VARCHAR2 ,
    x_status_code                       IN     VARCHAR2 ,
    x_start_date                        IN     DATE     ,
    x_end_date                          IN     DATE     ,
    x_attribute_category		IN VARCHAR2 ,
    x_attribute1			IN VARCHAR2 ,
    x_attribute2			IN VARCHAR2 ,
    x_attribute3			IN VARCHAR2 ,
    x_attribute4			IN VARCHAR2 ,
    x_attribute5			IN VARCHAR2 ,
    x_attribute6			IN VARCHAR2 ,
    x_attribute7			IN VARCHAR2 ,
    x_attribute8			IN VARCHAR2 ,
    x_attribute9			IN VARCHAR2 ,
    x_attribute10			IN VARCHAR2,
    x_attribute11			IN VARCHAR2,
    x_attribute12			IN VARCHAR2,
    x_attribute13			IN VARCHAR2,
    x_attribute14			IN VARCHAR2,
    x_attribute15			IN VARCHAR2,
    x_attribute16			IN VARCHAR2,
    x_attribute17			IN VARCHAR2,
    x_attribute18			IN VARCHAR2,
    x_attribute19			IN VARCHAR2,
    x_attribute20			IN VARCHAR2,
    x_creation_date                     IN     DATE  ,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE  ,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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
      x_immu_details_id,
      x_person_id,
      x_immunization_code,
      x_status_code,
      x_start_date,
      x_end_date,
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
      BeforeRowInsertUpdate( TRUE, FALSE,FALSE );

      IF ( get_pk_for_validation(
             new_references.immu_details_id
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
      BeforeRowInsertUpdate( FALSE,TRUE,FALSE );
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.immu_details_id
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
    x_immu_details_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_immunization_code                 IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_ATTRIBUTE_CATEGORY		IN     VARCHAR2,
    x_ATTRIBUTE1			IN     VARCHAR2,
    x_ATTRIBUTE2			IN     VARCHAR2,
    x_ATTRIBUTE3			IN     VARCHAR2,
    x_ATTRIBUTE4			IN     VARCHAR2,
    x_ATTRIBUTE5			IN     VARCHAR2,
    x_ATTRIBUTE6			IN     VARCHAR2,
    x_ATTRIBUTE7			IN     VARCHAR2,
    x_ATTRIBUTE8			IN     VARCHAR2,
    x_ATTRIBUTE9			IN     VARCHAR2,
    x_ATTRIBUTE10			IN     VARCHAR2,
    x_ATTRIBUTE11			IN     VARCHAR2,
    x_ATTRIBUTE12			IN     VARCHAR2,
    x_ATTRIBUTE13			IN     VARCHAR2,
    x_ATTRIBUTE14			IN     VARCHAR2,
    x_ATTRIBUTE15			IN     VARCHAR2,
    x_ATTRIBUTE16			IN     VARCHAR2,
    x_ATTRIBUTE17			IN     VARCHAR2,
    x_ATTRIBUTE18			IN     VARCHAR2,
    x_ATTRIBUTE19			IN     VARCHAR2,
    x_ATTRIBUTE20			IN     VARCHAR2,
    x_mode                              IN     VARCHAR2  -- DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pe_immu_dtls
      WHERE    immu_details_id                   = x_immu_details_id;

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

    SELECT    igs_pe_immu_dtls_s.NEXTVAL
    INTO      x_immu_details_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_immu_details_id                   => x_immu_details_id,
      x_person_id                         => x_person_id,
      x_immunization_code                 => x_immunization_code,
      x_status_code                       => x_status_code,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_attribute_category		  =>X_ATTRIBUTE_CATEGORY,
      x_attribute1			  =>X_ATTRIBUTE1,
      x_attribute2			  =>X_ATTRIBUTE2,
      x_attribute3			  =>X_ATTRIBUTE3,
      x_attribute4			  =>X_ATTRIBUTE4,
      x_attribute5			  =>X_ATTRIBUTE5,
      x_attribute6			  =>X_ATTRIBUTE6,
      x_attribute7			  =>X_ATTRIBUTE7,
      x_attribute8			  =>X_ATTRIBUTE8,
      x_attribute9			  =>X_ATTRIBUTE9,
      x_attribute10			  =>X_ATTRIBUTE10,
      x_attribute11			  =>X_ATTRIBUTE11,
      x_attribute12			  =>X_ATTRIBUTE12,
      x_attribute13			  =>X_ATTRIBUTE13,
      x_attribute14			  =>X_ATTRIBUTE14,
      x_attribute15			  =>X_ATTRIBUTE15,
      x_attribute16			  =>X_ATTRIBUTE16,
      x_attribute17			  =>X_ATTRIBUTE17,
      x_attribute18			  =>X_ATTRIBUTE18,
      x_attribute19			  =>X_ATTRIBUTE19,
      x_attribute20			  =>X_ATTRIBUTE20,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_immu_dtls (
      immu_details_id,
      person_id,
      immunization_code,
      status_code,
      start_date,
      end_date,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	ATTRIBUTE16,
	ATTRIBUTE17,
	ATTRIBUTE18,
	ATTRIBUTE19,
	ATTRIBUTE20,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.immu_details_id,
      new_references.person_id,
      new_references.immunization_code,
      new_references.status_code,
      new_references.start_date,
      new_references.end_date,
        NEW_REFERENCES.ATTRIBUTE_CATEGORY,
        NEW_REFERENCES.ATTRIBUTE1,
        NEW_REFERENCES.ATTRIBUTE2,
        NEW_REFERENCES.ATTRIBUTE3,
        NEW_REFERENCES.ATTRIBUTE4,
        NEW_REFERENCES.ATTRIBUTE5,
        NEW_REFERENCES.ATTRIBUTE6,
        NEW_REFERENCES.ATTRIBUTE7,
        NEW_REFERENCES.ATTRIBUTE8,
        NEW_REFERENCES.ATTRIBUTE9,
        NEW_REFERENCES.ATTRIBUTE10,
        NEW_REFERENCES.ATTRIBUTE11,
        NEW_REFERENCES.ATTRIBUTE12,
        NEW_REFERENCES.ATTRIBUTE13,
        NEW_REFERENCES.ATTRIBUTE14,
        NEW_REFERENCES.ATTRIBUTE15,
        NEW_REFERENCES.ATTRIBUTE16,
        NEW_REFERENCES.ATTRIBUTE17,
        NEW_REFERENCES.ATTRIBUTE18,
        NEW_REFERENCES.ATTRIBUTE19,
        NEW_REFERENCES.ATTRIBUTE20,
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
    x_immu_details_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_immunization_code                 IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_ATTRIBUTE_CATEGORY		IN	VARCHAR2,
    x_ATTRIBUTE1			IN	VARCHAR2,
    x_ATTRIBUTE2			IN	VARCHAR2,
    x_ATTRIBUTE3			IN	VARCHAR2,
    x_ATTRIBUTE4			IN	VARCHAR2,
    x_ATTRIBUTE5			IN	VARCHAR2,
    x_ATTRIBUTE6			IN	VARCHAR2,
    x_ATTRIBUTE7			IN	VARCHAR2,
    x_ATTRIBUTE8			IN	VARCHAR2,
    x_ATTRIBUTE9			IN	VARCHAR2,
    x_ATTRIBUTE10			IN	VARCHAR2,
    x_ATTRIBUTE11			IN	VARCHAR2,
    x_ATTRIBUTE12			IN	VARCHAR2,
    x_ATTRIBUTE13			IN	VARCHAR2,
    x_ATTRIBUTE14			IN	VARCHAR2,
    x_ATTRIBUTE15			IN	VARCHAR2,
    x_ATTRIBUTE16			IN	VARCHAR2,
    x_ATTRIBUTE17			IN	VARCHAR2,
    x_ATTRIBUTE18			IN	VARCHAR2,
    x_ATTRIBUTE19			IN	VARCHAR2,
    x_ATTRIBUTE20			IN	VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        immunization_code,
        status_code,
        start_date,
        end_date,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20

      FROM  igs_pe_immu_dtls
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
        AND (tlinfo.immunization_code = x_immunization_code)
        AND (tlinfo.status_code = x_status_code)
        AND (tlinfo.start_date = x_start_date)
        AND ((tlinfo.end_date = x_end_date) OR ((tlinfo.end_date IS NULL) AND (X_end_date IS NULL)))
  AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
 	    OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
		AND (X_ATTRIBUTE_CATEGORY is null)))
  AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
 	    OR ((tlinfo.ATTRIBUTE1 is null)
		AND (X_ATTRIBUTE1 is null)))
  AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
 	    OR ((tlinfo.ATTRIBUTE2 is null)
		AND (X_ATTRIBUTE2 is null)))
  AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
 	    OR ((tlinfo.ATTRIBUTE3 is null)
		AND (X_ATTRIBUTE3 is null)))
  AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
 	    OR ((tlinfo.ATTRIBUTE4 is null)
		AND (X_ATTRIBUTE4 is null)))
  AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
 	    OR ((tlinfo.ATTRIBUTE5 is null)
		AND (X_ATTRIBUTE5 is null)))
  AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
 	    OR ((tlinfo.ATTRIBUTE6 is null)
		AND (X_ATTRIBUTE6 is null)))
  AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
 	    OR ((tlinfo.ATTRIBUTE7 is null)
		AND (X_ATTRIBUTE7 is null)))
  AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
 	    OR ((tlinfo.ATTRIBUTE8 is null)
		AND (X_ATTRIBUTE8 is null)))
  AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
 	    OR ((tlinfo.ATTRIBUTE9 is null)
		AND (X_ATTRIBUTE9 is null)))
  AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
 	    OR ((tlinfo.ATTRIBUTE10 is null)
		AND (X_ATTRIBUTE10 is null)))
  AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
 	    OR ((tlinfo.ATTRIBUTE11 is null)
		AND (X_ATTRIBUTE11 is null)))
  AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
 	    OR ((tlinfo.ATTRIBUTE12 is null)
		AND (X_ATTRIBUTE12 is null)))
  AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
 	    OR ((tlinfo.ATTRIBUTE13 is null)
		AND (X_ATTRIBUTE13 is null)))
  AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
 	    OR ((tlinfo.ATTRIBUTE14 is null)
		AND (X_ATTRIBUTE14 is null)))
  AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
 	    OR ((tlinfo.ATTRIBUTE15 is null)
		AND (X_ATTRIBUTE15 is null)))
  AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
 	    OR ((tlinfo.ATTRIBUTE16 is null)
		AND (X_ATTRIBUTE16 is null)))
  AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
 	    OR ((tlinfo.ATTRIBUTE17 is null)
		AND (X_ATTRIBUTE17 is null)))
  AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
 	    OR ((tlinfo.ATTRIBUTE18 is null)
		AND (X_ATTRIBUTE18 is null)))
  AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
 	    OR ((tlinfo.ATTRIBUTE19 is null)
		AND (X_ATTRIBUTE19 is null)))
  AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)   OR ((tlinfo.ATTRIBUTE20 is null)	AND (X_ATTRIBUTE20 is null)))

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
    x_immu_details_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_immunization_code                 IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_ATTRIBUTE_CATEGORY		IN	VARCHAR2,
    x_ATTRIBUTE1			IN	VARCHAR2,
    x_ATTRIBUTE2			IN	VARCHAR2,
    x_ATTRIBUTE3			IN	VARCHAR2,
    x_ATTRIBUTE4			IN	VARCHAR2,
    x_ATTRIBUTE5			IN	VARCHAR2,
    x_ATTRIBUTE6			IN	VARCHAR2,
    x_ATTRIBUTE7			IN	VARCHAR2,
    x_ATTRIBUTE8			IN	VARCHAR2,
    x_ATTRIBUTE9			IN	VARCHAR2,
    x_ATTRIBUTE10			IN	VARCHAR2,
    x_ATTRIBUTE11			IN	VARCHAR2,
    x_ATTRIBUTE12			IN	VARCHAR2,
    x_ATTRIBUTE13			IN	VARCHAR2,
    x_ATTRIBUTE14			IN	VARCHAR2,
    x_ATTRIBUTE15			IN	VARCHAR2,
    x_ATTRIBUTE16			IN	VARCHAR2,
    x_ATTRIBUTE17			IN	VARCHAR2,
    x_ATTRIBUTE18			IN	VARCHAR2,
    x_ATTRIBUTE19			IN	VARCHAR2,
    x_ATTRIBUTE20			IN	VARCHAR2,
    x_mode                              IN     VARCHAR2  -- DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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
      x_immu_details_id                   => x_immu_details_id,
      x_person_id                         => x_person_id,
      x_immunization_code                 => x_immunization_code,
      x_status_code                       => x_status_code,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_attribute_category		 =>X_ATTRIBUTE_CATEGORY,
      x_attribute1			=>X_ATTRIBUTE1,
      x_attribute2			=>X_ATTRIBUTE2,
      x_attribute3			=>X_ATTRIBUTE3,
      x_attribute4			=>X_ATTRIBUTE4,
      x_attribute5			=>X_ATTRIBUTE5,
      x_attribute6			=>X_ATTRIBUTE6,
      x_attribute7			=>X_ATTRIBUTE7,
      x_attribute8			=>X_ATTRIBUTE8,
      x_attribute9			=>X_ATTRIBUTE9,
      x_attribute10			=>X_ATTRIBUTE10,
      x_attribute11			=>X_ATTRIBUTE11,
      x_attribute12			=>X_ATTRIBUTE12,
      x_attribute13			=>X_ATTRIBUTE13,
      x_attribute14			=>X_ATTRIBUTE14,
      x_attribute15			=>X_ATTRIBUTE15,
      x_attribute16			=>X_ATTRIBUTE16,
      x_attribute17			=>X_ATTRIBUTE17,
      x_attribute18			=>X_ATTRIBUTE18,
      x_attribute19			=>X_ATTRIBUTE19,
      x_attribute20			=>X_ATTRIBUTE20,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_immu_dtls
      SET
        person_id                         = new_references.person_id,
        immunization_code                 = new_references.immunization_code,
        status_code                       = new_references.status_code,
        start_date                        = new_references.start_date,
        end_date                          = new_references.end_date,
      ATTRIBUTE_CATEGORY		=  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
      ATTRIBUTE1			=  NEW_REFERENCES.ATTRIBUTE1,
      ATTRIBUTE2			=  NEW_REFERENCES.ATTRIBUTE2,
      ATTRIBUTE3			=  NEW_REFERENCES.ATTRIBUTE3,
      ATTRIBUTE4			=  NEW_REFERENCES.ATTRIBUTE4,
      ATTRIBUTE5			=  NEW_REFERENCES.ATTRIBUTE5,
      ATTRIBUTE6			=  NEW_REFERENCES.ATTRIBUTE6,
      ATTRIBUTE7			=  NEW_REFERENCES.ATTRIBUTE7,
      ATTRIBUTE8			=  NEW_REFERENCES.ATTRIBUTE8,
      ATTRIBUTE9			=  NEW_REFERENCES.ATTRIBUTE9,
      ATTRIBUTE10			=  NEW_REFERENCES.ATTRIBUTE10,
      ATTRIBUTE11			=  NEW_REFERENCES.ATTRIBUTE11,
      ATTRIBUTE12			=  NEW_REFERENCES.ATTRIBUTE12,
      ATTRIBUTE13			 =  NEW_REFERENCES.ATTRIBUTE13,
      ATTRIBUTE14			=  NEW_REFERENCES.ATTRIBUTE14,
      ATTRIBUTE15			=  NEW_REFERENCES.ATTRIBUTE15,
      ATTRIBUTE16			=  NEW_REFERENCES.ATTRIBUTE16,
      ATTRIBUTE17			=  NEW_REFERENCES.ATTRIBUTE17,
      ATTRIBUTE18			=  NEW_REFERENCES.ATTRIBUTE18,
      ATTRIBUTE19			=  NEW_REFERENCES.ATTRIBUTE19,
      ATTRIBUTE20			=  NEW_REFERENCES.ATTRIBUTE20,
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
    x_immu_details_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_immunization_code                 IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_ATTRIBUTE_CATEGORY		IN VARCHAR2,
    x_ATTRIBUTE1			IN VARCHAR2,
    x_ATTRIBUTE2			IN VARCHAR2,
    x_ATTRIBUTE3			IN VARCHAR2,
    x_ATTRIBUTE4			IN VARCHAR2,
    x_ATTRIBUTE5			IN VARCHAR2,
    x_ATTRIBUTE6			IN VARCHAR2,
    x_ATTRIBUTE7			IN VARCHAR2,
    x_ATTRIBUTE8			IN VARCHAR2,
    x_ATTRIBUTE9			IN VARCHAR2,
    x_ATTRIBUTE10			IN VARCHAR2,
    x_ATTRIBUTE11			IN VARCHAR2,
    x_ATTRIBUTE12			IN VARCHAR2,
    x_ATTRIBUTE13			IN VARCHAR2,
    x_ATTRIBUTE14			IN VARCHAR2,
    x_ATTRIBUTE15			IN VARCHAR2,
    x_ATTRIBUTE16			IN VARCHAR2,
    x_ATTRIBUTE17			IN VARCHAR2,
    x_ATTRIBUTE18			IN VARCHAR2,
    x_ATTRIBUTE19			IN VARCHAR2,
    x_ATTRIBUTE20			IN VARCHAR2,
    x_mode                              IN     VARCHAR2  -- DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_immu_dtls
      WHERE    immu_details_id                   = x_immu_details_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_immu_details_id,
        x_person_id,
        x_immunization_code,
        x_status_code,
        x_start_date,
        x_end_date,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_immu_details_id,
      x_person_id,
      x_immunization_code,
      x_status_code,
      x_start_date,
      x_end_date,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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
 DELETE FROM igs_pe_immu_dtls
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


END igs_pe_immu_dtls_pkg;

/
