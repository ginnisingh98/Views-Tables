--------------------------------------------------------
--  DDL for Package Body IGS_CO_OU_CO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_OU_CO_PKG" AS
/* $Header: IGSLI14B.pls 115.12 2002/11/29 01:05:49 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to IGS_CO_VAL_OC.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references igs_co_ou_co_all%ROWTYPE;
  new_references igs_co_ou_co_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_reference_number                  IN     NUMBER      DEFAULT NULL,
    x_issue_dt                          IN     DATE        DEFAULT NULL,
    x_addr_type                         IN     VARCHAR2    DEFAULT NULL,
    x_tracking_id                       IN     NUMBER      DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_dt_sent                           IN     DATE        DEFAULT NULL,
    x_unknown_return_dt                 IN     DATE        DEFAULT NULL,
    x_letter_reference_number           IN     NUMBER      DEFAULT NULL,
    x_spl_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CO_OU_CO_ALL
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
    new_references.person_id                         := x_person_id;
    new_references.correspondence_type               := x_correspondence_type;
    new_references.reference_number                  := x_reference_number;
    new_references.issue_dt                          := x_issue_dt;
    new_references.addr_type                         := x_addr_type;
    new_references.tracking_id                       := x_tracking_id;
    new_references.comments                          := x_comments;
    new_references.dt_sent                           := x_dt_sent;
    new_references.unknown_return_dt                 := x_unknown_return_dt;
    new_references.letter_reference_number           := x_letter_reference_number;
    new_references.spl_sequence_number               := x_spl_sequence_number;
    new_references.org_id                            := x_org_id;

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
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the Check Constraint logic for the the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER(column_name) = 'REFERENCE_NUMBER') THEN
      new_references.reference_number := igs_ge_number.to_num (column_value);
    END IF;

    IF (UPPER(column_name) = 'REFERENCE_NUMBER' OR column_name IS NULL) THEN
      IF NOT (new_references.reference_number BETWEEN 1
              AND 999999)  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;

  PROCEDURE get_fk_igs_co_s_ltr (
    x_correspondence_type               IN     VARCHAR2,
    x_letter_reference_number           IN     NUMBER
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 19-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_ou_co_all
      WHERE   ((correspondence_type = x_correspondence_type) AND
               (spl_sequence_number = x_letter_reference_number));

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

  END get_fk_igs_co_s_ltr;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_co_ou_co_ref_pkg.get_fk_igs_co_ou_co (
      old_references.person_id,
      old_references.correspondence_type,
      old_references.reference_number,
      old_references.issue_dt
    );

  END check_child_existance;

  PROCEDURE  BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_created_date	IGS_CO_ITM_ALL.create_dt%TYPE;
	v_message_name varchar2(30);
	CURSOR c_cor_item IS
		SELECT	create_dt
		FROM	IGS_CO_ITM_ALL
		WHERE	correspondence_type = new_references.correspondence_type AND
			reference_number = new_references.reference_number;
  BEGIN
	-- If trigger has not been disabled, perform required processing
	IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_CO_OU_CO_ALL') THEN
		-- Fetch the Cor Item Created Date and validate it
		OPEN	c_cor_item;
		FETCH	c_cor_item INTO v_created_date;
		CLOSE	c_cor_item;
		IF  IGS_CO_VAL_OC.corp_val_oc_dateseq(
			v_created_date,
			new_references.issue_dt,
			new_references.dt_sent,
			new_references.unknown_return_dt,
			v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;


  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_ou_co_all
      WHERE    person_id = x_person_id
      AND      correspondence_type = x_correspondence_type
      AND      reference_number = x_reference_number
      AND      issue_dt = x_issue_dt
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
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_reference_number                  IN     NUMBER      DEFAULT NULL,
    x_issue_dt                          IN     DATE        DEFAULT NULL,
    x_addr_type                         IN     VARCHAR2    DEFAULT NULL,
    x_tracking_id                       IN     NUMBER      DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_dt_sent                           IN     DATE        DEFAULT NULL,
    x_unknown_return_dt                 IN     DATE        DEFAULT NULL,
    x_letter_reference_number           IN     NUMBER      DEFAULT NULL,
    x_spl_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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
      x_person_id,
      x_correspondence_type,
      x_reference_number,
      x_issue_dt,
      x_addr_type,
      x_tracking_id,
      x_comments,
      x_dt_sent,
      x_unknown_return_dt,
      x_letter_reference_number,
      x_spl_sequence_number,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
          BeforeRowInsertUpdate1 ( p_inserting => TRUE );

      IF ( get_pk_for_validation(
             new_references.person_id,
             new_references.correspondence_type,
             new_references.reference_number,
             new_references.issue_dt
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdate1 ( p_inserting => TRUE );
       check_constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.person_id,
             new_references.correspondence_type,
             new_references.reference_number,
             new_references.issue_dt
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN OUT NOCOPY DATE,
    x_addr_type                         IN     VARCHAR2,
    x_tracking_id                       IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_dt_sent                           IN     DATE,
    x_unknown_return_dt                 IN     DATE,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_co_ou_co_all
      WHERE    person_id                         = x_person_id
      AND      correspondence_type               = x_correspondence_type
      AND      reference_number                  = x_reference_number
      AND      issue_dt                          = new_references.issue_dt;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_correspondence_type               => x_correspondence_type,
      x_reference_number                  => x_reference_number,
      x_issue_dt                          => NVL (x_issue_dt,sysdate ),
      x_addr_type                         => x_addr_type,
      x_tracking_id                       => x_tracking_id,
      x_comments                          => x_comments,
      x_dt_sent                           => x_dt_sent,
      x_unknown_return_dt                 => x_unknown_return_dt,
      x_letter_reference_number           => x_letter_reference_number,
      x_spl_sequence_number               => x_spl_sequence_number,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_co_ou_co_all (
      person_id,
      correspondence_type,
      reference_number,
      issue_dt,
      addr_type,
      tracking_id,
      comments,
      dt_sent,
      unknown_return_dt,
      letter_reference_number,
      spl_sequence_number,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      new_references.person_id,
      new_references.correspondence_type,
      new_references.reference_number,
      new_references.issue_dt,
      new_references.addr_type,
      new_references.tracking_id,
      new_references.comments,
      new_references.dt_sent,
      new_references.unknown_return_dt,
      new_references.letter_reference_number,
      new_references.spl_sequence_number,
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
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
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN     DATE,
    x_addr_type                         IN     VARCHAR2,
    x_tracking_id                       IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_dt_sent                           IN     DATE,
    x_unknown_return_dt                 IN     DATE,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER
     ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        addr_type,
        tracking_id,
        comments,
        dt_sent,
        unknown_return_dt,
        letter_reference_number,
        spl_sequence_number

      FROM  igs_co_ou_co_all
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
        ((tlinfo.addr_type = x_addr_type) OR ((tlinfo.addr_type IS NULL) AND (X_addr_type IS NULL)))
        AND ((tlinfo.tracking_id = x_tracking_id) OR ((tlinfo.tracking_id IS NULL) AND (X_tracking_id IS NULL)))
        AND ((tlinfo.comments = x_comments) OR ((tlinfo.comments IS NULL) AND (X_comments IS NULL)))
        AND ((tlinfo.dt_sent = x_dt_sent) OR ((tlinfo.dt_sent IS NULL) AND (X_dt_sent IS NULL)))
        AND ((tlinfo.unknown_return_dt = x_unknown_return_dt) OR ((tlinfo.unknown_return_dt IS NULL) AND (X_unknown_return_dt IS NULL)))
        AND ((tlinfo.letter_reference_number = x_letter_reference_number) OR ((tlinfo.letter_reference_number IS NULL) AND (X_letter_reference_number IS NULL)))
        AND ((tlinfo.spl_sequence_number = x_spl_sequence_number) OR ((tlinfo.spl_sequence_number IS NULL) AND (X_spl_sequence_number IS NULL)))

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
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN     DATE,
    x_addr_type                         IN     VARCHAR2,
    x_tracking_id                       IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_dt_sent                           IN     DATE,
    x_unknown_return_dt                 IN     DATE,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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
      x_person_id                         => x_person_id,
      x_correspondence_type               => x_correspondence_type,
      x_reference_number                  => x_reference_number,
      x_issue_dt                          => NVL (x_issue_dt,sysdate ),
      x_addr_type                         => x_addr_type,
      x_tracking_id                       => x_tracking_id,
      x_comments                          => x_comments,
      x_dt_sent                           => x_dt_sent,
      x_unknown_return_dt                 => x_unknown_return_dt,
      x_letter_reference_number           => x_letter_reference_number,
      x_spl_sequence_number               => x_spl_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
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

    UPDATE igs_co_ou_co_all
      SET
        addr_type                         = new_references.addr_type,
        tracking_id                       = new_references.tracking_id,
        comments                          = new_references.comments,
        dt_sent                           = new_references.dt_sent,
        unknown_return_dt                 = new_references.unknown_return_dt,
        letter_reference_number           = new_references.letter_reference_number,
        spl_sequence_number               = new_references.spl_sequence_number,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN OUT NOCOPY DATE,
    x_addr_type                         IN     VARCHAR2,
    x_tracking_id                       IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_dt_sent                           IN     DATE,
    x_unknown_return_dt                 IN     DATE,
    x_letter_reference_number           IN     NUMBER,
    x_spl_sequence_number               IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_co_ou_co_all
      WHERE    person_id                         = x_person_id
      AND      correspondence_type               = x_correspondence_type
      AND      reference_number                  = x_reference_number
      AND      issue_dt                         = NVL (x_issue_dt,SYSDATE);

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_person_id,
        x_correspondence_type,
        x_reference_number,
        x_issue_dt,
        x_addr_type,
        x_tracking_id,
        x_comments,
        x_dt_sent,
        x_unknown_return_dt,
        x_letter_reference_number,
        x_spl_sequence_number,
        x_org_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_id,
      x_correspondence_type,
      x_reference_number,
      x_issue_dt,
      x_addr_type,
      x_tracking_id,
      x_comments,
      x_dt_sent,
      x_unknown_return_dt,
      x_letter_reference_number,
      x_spl_sequence_number,
      x_mode
    );

  END add_row;


  PROCEDURE GET_FK_IGS_CO_ADDR_TYPE (
    x_addr_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CO_OU_CO_ALL
      WHERE    addr_type = x_addr_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	  Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CO_OC_ADT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CO_ADDR_TYPE;

  PROCEDURE GET_FK_IGS_CO_ITM (
    x_correspondence_type IN VARCHAR2,
    x_reference_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CO_OU_CO_ALL
      WHERE    correspondence_type = x_correspondence_type
      AND      reference_number = x_reference_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	  Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CO_OC_CORI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CO_ITM;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CO_OU_CO_ALL
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	  Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CO_OC_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_TR_ITEM (
    x_tracking_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CO_OU_CO_ALL
      WHERE    tracking_id = x_tracking_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	  Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CO_OC_TRI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_TR_ITEM;



  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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

    DELETE FROM igs_co_ou_co_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_co_ou_co_pkg;

/
