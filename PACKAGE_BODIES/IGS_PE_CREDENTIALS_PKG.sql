--------------------------------------------------------
--  DDL for Package Body IGS_PE_CREDENTIALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_CREDENTIALS_PKG" AS
/* $Header: IGSNI96B.pls 120.1 2005/06/28 05:18:10 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_credentials%ROWTYPE;
  new_references igs_pe_credentials%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_credential_id                     IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_credential_type_id                IN     NUMBER      ,
    x_date_received                     IN     DATE        ,
    x_reviewer_id                       IN     NUMBER      ,
    x_reviewer_notes                    IN     VARCHAR2    ,
    x_recommender_name                  IN     VARCHAR2    ,
    x_recommender_title                 IN     VARCHAR2    ,
    x_recommender_organization          IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_rating_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_credentials
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
    new_references.credential_id                     := x_credential_id;
    new_references.person_id                         := x_person_id;
    new_references.credential_type_id                := x_credential_type_id;
    new_references.date_received                     := x_date_received;
    new_references.reviewer_id                       := x_reviewer_id;
    new_references.reviewer_notes                    := x_reviewer_notes;
    new_references.recommender_name                  := x_recommender_name;
    new_references.recommender_title                 := x_recommender_title;
    new_references.recommender_organization          := x_recommender_organization;
    new_references.rating_code                       := x_rating_code;
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
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    --rating changed to rating_code by gmuralid
    IF (((old_references.rating_code = new_references.rating_code)) OR
        ((new_references.rating_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.Get_PK_For_Validation (
                        'PE_CRE_RATING',
			new_references.rating_code
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_RATING'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;


    IF (((old_references.credential_type_id = new_references.credential_type_id)) OR
        ((new_references.credential_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_cred_types_pkg.get_pk_for_validation (
                new_references.credential_type_id,
                'N'
              ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CREDENTIAL_TYPE'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;
  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_credential_id                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_credentials
      WHERE    credential_id = x_credential_id
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


  PROCEDURE get_fk_igs_ad_cred_types (
    x_credential_type_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_credentials
      WHERE   ((credential_type_id = x_credential_type_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_PEC_CT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_cred_types;

 /* PROCEDURE get_fk_igs_ad_code_classes (
    x_code_id                IN     NUMBER
  ) AS

  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_credentials
      WHERE   ((rating = x_code_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_PEC_ACC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_code_classes; */

  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_credentials
      WHERE   ((person_id = x_party_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_PEC_HZ_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_parties;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2   ,
    x_credential_id                     IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_credential_type_id                IN     NUMBER      ,
    x_date_received                     IN     DATE        ,
    x_reviewer_id                       IN     NUMBER      ,
    x_reviewer_notes                    IN     VARCHAR2    ,
    x_recommender_name                  IN     VARCHAR2    ,
    x_recommender_title                 IN     VARCHAR2    ,
    x_recommender_organization          IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_rating_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ssawhney       16-apr-2003               BUG 2893294, reviewer can BE NULL.
  */
  CURSOR is_reviewer_evaluator IS
  SELECT 'X'
  FROM IGS_PE_TYP_INSTANCES PI,
       IGS_PE_PERSON_TYPES  PT
  WHERE
    PT.PERSON_TYPE_CODE = PI.PERSON_TYPE_CODE AND
	PT.SYSTEM_TYPE IN ('STAFF','FACULTY','EVALUATOR') AND
	SYSDATE BETWEEN PI.START_DATE AND NVL(PI.END_DATE,SYSDATE) AND
	PI.PERSON_ID = x_reviewer_id;
  l_reviewer VARCHAR2(1);

  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_credential_id,
      x_person_id,
      x_credential_type_id,
      x_date_received,
      x_reviewer_id,
      x_reviewer_notes,
      x_recommender_name,
      x_recommender_title,
      x_recommender_organization,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_rating_code
    );
    -- code added as a part of the bug 2121046. Reviewer cannot be the person in context and the
    -- reviewer should have an active person type of EVALUATOR, STAFF or FACULTY.
    -- ssawhney BUG 2893294, reviewer can BE NULL.
    IF (p_action IN ('INSERT','UPDATE')) THEN
      IF(x_reviewer_id = x_person_id) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_PE_REVR_PRSN_SAME');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      ELSE
        IF x_reviewer_id IS NOT NULL THEN
          OPEN is_reviewer_evaluator;
	  FETCH is_reviewer_evaluator INTO l_reviewer;
	  IF is_reviewer_evaluator%NOTFOUND THEN
	    CLOSE is_reviewer_evaluator;
            FND_MESSAGE.SET_NAME('IGS','IGS_PE_INVALID_REVR');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
	  ELSE
	    CLOSE is_reviewer_evaluator;
	  END IF;
	END IF;
      END IF;
    END IF;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.credential_id
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
             new_references.credential_id
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
    x_credential_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_credential_type_id                IN     NUMBER,
    x_date_received                     IN     DATE,
    x_reviewer_id                       IN     NUMBER,
    x_reviewer_notes                    IN     VARCHAR2,
    x_recommender_name                  IN     VARCHAR2,
    x_recommender_title                 IN     VARCHAR2,
    x_recommender_organization          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2  ,
    x_rating_code                       IN     varchar2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pe_credentials
      WHERE    credential_id                     = x_credential_id;

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

    SELECT    igs_pe_credentials_s.NEXTVAL
    INTO      x_credential_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_credential_id                     => x_credential_id,
      x_person_id                         => x_person_id,
      x_credential_type_id                => x_credential_type_id,
      x_date_received                     => x_date_received,
      x_reviewer_id                       => x_reviewer_id,
      x_reviewer_notes                    => x_reviewer_notes,
      x_recommender_name                  => x_recommender_name,
      x_recommender_title                 => x_recommender_title,
      x_recommender_organization          => x_recommender_organization,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_rating_code                       => x_rating_code
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_credentials (
      credential_id,
      person_id,
      credential_type_id,
      date_received,
      reviewer_id,
      reviewer_notes,
      recommender_name,
      recommender_title,
      recommender_organization,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      rating_code
    ) VALUES (
      new_references.credential_id,
      new_references.person_id,
      new_references.credential_type_id,
      new_references.date_received,
      new_references.reviewer_id,
      new_references.reviewer_notes,
      new_references.recommender_name,
      new_references.recommender_title,
      new_references.recommender_organization,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.rating_code
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
    x_credential_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_credential_type_id                IN     NUMBER,
    x_date_received                     IN     DATE,
    x_reviewer_id                       IN     NUMBER,
    x_reviewer_notes                    IN     VARCHAR2,
    x_recommender_name                  IN     VARCHAR2,
    x_recommender_title                 IN     VARCHAR2,
    x_recommender_organization          IN     VARCHAR2,
    x_rating_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        credential_type_id,
        date_received,
        reviewer_id,
        reviewer_notes,
        recommender_name,
        recommender_title,
        recommender_organization,
	rating_code
      FROM  igs_pe_credentials
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
        AND (tlinfo.credential_type_id = x_credential_type_id)
        AND ((tlinfo.date_received = x_date_received) OR ((tlinfo.date_received IS NULL) AND (X_date_received IS NULL)))
        AND ((tlinfo.reviewer_id = x_reviewer_id) OR ((tlinfo.reviewer_id IS NULL) AND (X_reviewer_id IS NULL)))
        AND ((tlinfo.reviewer_notes = x_reviewer_notes) OR ((tlinfo.reviewer_notes IS NULL) AND (X_reviewer_notes IS NULL)))
        AND ((tlinfo.recommender_name = x_recommender_name) OR ((tlinfo.recommender_name IS NULL) AND (X_recommender_name IS NULL)))
        AND ((tlinfo.recommender_title = x_recommender_title) OR ((tlinfo.recommender_title IS NULL) AND (X_recommender_title IS NULL)))
        AND ((tlinfo.recommender_organization = x_recommender_organization) OR ((tlinfo.recommender_organization IS NULL) AND (X_recommender_organization IS NULL)))
         AND ((tlinfo.rating_code = x_rating_code) OR ((tlinfo.rating_code IS NULL) AND (X_rating_code IS NULL)))
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
    x_credential_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_credential_type_id                IN     NUMBER,
    x_date_received                     IN     DATE,
    x_reviewer_id                       IN     NUMBER,
    x_reviewer_notes                    IN     VARCHAR2,
    x_recommender_name                  IN     VARCHAR2,
    x_recommender_title                 IN     VARCHAR2,
    x_recommender_organization          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2  ,
    x_rating_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
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
      x_credential_id                     => x_credential_id,
      x_person_id                         => x_person_id,
      x_credential_type_id                => x_credential_type_id,
      x_date_received                     => x_date_received,
      x_reviewer_id                       => x_reviewer_id,
      x_reviewer_notes                    => x_reviewer_notes,
      x_recommender_name                  => x_recommender_name,
      x_recommender_title                 => x_recommender_title,
      x_recommender_organization          => x_recommender_organization,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_rating_code                       => x_rating_code
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_credentials
      SET
        person_id                         = new_references.person_id,
        credential_type_id                = new_references.credential_type_id,
        date_received                     = new_references.date_received,
        reviewer_id                       = new_references.reviewer_id,
        reviewer_notes                    = new_references.reviewer_notes,
        recommender_name                  = new_references.recommender_name,
        recommender_title                 = new_references.recommender_title,
        recommender_organization          = new_references.recommender_organization,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
	 rating_code                      = new_references.rating_code
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
    x_credential_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_credential_type_id                IN     NUMBER,
    x_date_received                     IN     DATE,
    x_reviewer_id                       IN     NUMBER,
    x_reviewer_notes                    IN     VARCHAR2,
    x_recommender_name                  IN     VARCHAR2,
    x_recommender_title                 IN     VARCHAR2,
    x_recommender_organization          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2  ,
    x_rating_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_credentials
      WHERE    credential_id                     = x_credential_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_credential_id,
        x_person_id,
        x_credential_type_id,
        x_date_received,
        x_reviewer_id,
        x_reviewer_notes,
        x_recommender_name,
        x_recommender_title,
        x_recommender_organization,
        x_mode,
	x_rating_code
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_credential_id,
      x_person_id,
      x_credential_type_id,
      x_date_received,
      x_reviewer_id,
      x_reviewer_notes,
      x_recommender_name,
      x_recommender_title,
      x_recommender_organization,
      x_mode ,
      x_rating_code
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 10-JAN-2002
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
 DELETE FROM igs_pe_credentials
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


END igs_pe_credentials_pkg;

/
