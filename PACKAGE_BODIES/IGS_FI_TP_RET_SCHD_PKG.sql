--------------------------------------------------------
--  DDL for Package Body IGS_FI_TP_RET_SCHD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_TP_RET_SCHD_PKG" AS
/* $Header: IGSSIE7B.pls 120.0 2005/06/02 04:20:06 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_tp_ret_schd%ROWTYPE;
  new_references igs_fi_tp_ret_schd%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ftci_teach_retention_id           IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_ret_percentage                    IN     NUMBER,
    x_ret_amount                        IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 02-SEP-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_tp_ret_schd
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
    new_references.ftci_teach_retention_id           := x_ftci_teach_retention_id;
    new_references.teach_cal_type                    := x_teach_cal_type;
    new_references.teach_ci_sequence_number          := x_teach_ci_sequence_number;
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
    new_references.fee_type                          := x_fee_type;
    new_references.dt_alias                          := x_dt_alias;
    new_references.dai_sequence_number               := x_dai_sequence_number;
    new_references.ret_percentage                    := x_ret_percentage;
    new_references.ret_amount                        := x_ret_amount;

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
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 02-SEP-2004
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.teach_cal_type,
           new_references.teach_ci_sequence_number,
           new_references.fee_cal_type,
           new_references.fee_ci_sequence_number,
           new_references.fee_type,
           new_references.dt_alias,
           new_references.dai_sequence_number
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 13-SEP-2004
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
     IF ((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
	 (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)
	)
	OR
	((new_references.fee_type IS NULL) OR
	 (new_references.fee_cal_type IS NULL) OR
	 (new_references.fee_ci_sequence_number IS NULL)) THEN

	NULL;
     ELSIF NOT igs_fi_f_typ_ca_inst_pkg.get_pk_for_validation (
		 x_fee_type => new_references.fee_type,
		 x_fee_cal_type => new_references.fee_cal_type,
		 x_fee_ci_sequence_number => new_references.fee_ci_sequence_number
		)  THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
     END IF;

     IF ((old_references.dt_alias = new_references.dt_alias) AND
         (old_references.dai_sequence_number = new_references.dai_sequence_number) AND
	 (old_references.teach_cal_type = new_references.teach_cal_type) AND
	 (old_references.teach_ci_sequence_number = new_references.teach_ci_sequence_number)
	) OR
	((new_references.dt_alias IS NULL) OR
	 (new_references.dai_sequence_number IS NULL) OR
	 (new_references.teach_cal_type IS NULL) OR
	 (new_references.teach_ci_sequence_number IS NULL)) THEN

	NULL;
     ELSIF NOT igs_ca_da_inst_pkg.get_pk_for_validation (
			x_dt_alias => new_references.dt_alias,
			x_sequence_number => new_references.dai_sequence_number,
			x_cal_type => new_references.teach_cal_type,
			x_ci_sequence_number => new_references.teach_ci_sequence_number) THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
     END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_ftci_teach_retention_id           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 02-SEP-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_tp_ret_schd
      WHERE    ftci_teach_retention_id = x_ftci_teach_retention_id
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
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 02-SEP-2004
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_tp_ret_schd
      WHERE    teach_cal_type = x_teach_cal_type
      AND      teach_ci_sequence_number = x_teach_ci_sequence_number
      AND      ((fee_cal_type = x_fee_cal_type) OR (fee_cal_type IS NULL AND x_fee_cal_type IS NULL))
      AND      ((fee_ci_sequence_number = x_fee_ci_sequence_number) OR (fee_ci_sequence_number IS NULL AND x_fee_ci_sequence_number IS NULL))
      AND      ((fee_type = x_fee_type) OR (fee_type IS NULL AND x_fee_type IS NULL))
      AND      dt_alias = x_dt_alias
      AND      dai_sequence_number = x_dai_sequence_number
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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 20-SEP-2004
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
      IF (p_inserting OR p_updating) THEN
          IF (new_references.ret_percentage IS NULL AND new_references.ret_amount IS NULL) THEN
              fnd_message.set_name('IGS','IGS_FI_RETAMT_OR_PER_MAND');
	      igs_ge_msg_stack.add;
              App_Exception.Raise_Exception;
	  ELSIF (new_references.ret_percentage IS NOT NULL AND new_references.ret_amount IS NOT NULL) THEN
              fnd_message.set_name('IGS','IGS_FI_ONE_RETAMT_OR_RETPREC');
	      igs_ge_msg_stack.add;
              App_Exception.Raise_Exception;
	  END IF;
      END IF;
  END BeforeRowInsertUpdateDelete1;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ftci_teach_retention_id           IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_ret_percentage                    IN     NUMBER,
    x_ret_amount                        IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 02-SEP-2004
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
      x_ftci_teach_retention_id,
      x_teach_cal_type,
      x_teach_ci_sequence_number,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_type,
      x_dt_alias,
      x_dai_sequence_number,
      x_ret_percentage,
      x_ret_amount,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF ( get_pk_for_validation(
             new_references.ftci_teach_retention_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      Check_Constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      check_uniqueness;
      Check_Constraints;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.ftci_teach_retention_id
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
    l_rowid := NULL;
  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ftci_teach_retention_id           IN OUT NOCOPY NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_ret_percentage                    IN     NUMBER,
    x_ret_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 02-SEP-2004
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_TP_RET_SCHD_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_ftci_teach_retention_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ftci_teach_retention_id           => x_ftci_teach_retention_id,
      x_teach_cal_type                    => x_teach_cal_type,
      x_teach_ci_sequence_number          => x_teach_ci_sequence_number,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_fee_type                          => x_fee_type,
      x_dt_alias                          => x_dt_alias,
      x_dai_sequence_number               => x_dai_sequence_number,
      x_ret_percentage                    => x_ret_percentage,
      x_ret_amount                        => x_ret_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_tp_ret_schd (
      ftci_teach_retention_id,
      teach_cal_type,
      teach_ci_sequence_number,
      fee_cal_type,
      fee_ci_sequence_number,
      fee_type,
      dt_alias,
      dai_sequence_number,
      ret_percentage,
      ret_amount,
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
      igs_fi_tp_ret_schd_s.NEXTVAL,
      new_references.teach_cal_type,
      new_references.teach_ci_sequence_number,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.fee_type,
      new_references.dt_alias,
      new_references.dai_sequence_number,
      new_references.ret_percentage,
      new_references.ret_amount,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, ftci_teach_retention_id INTO x_rowid, x_ftci_teach_retention_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ftci_teach_retention_id           IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_ret_percentage                    IN     NUMBER,
    x_ret_amount                        IN     NUMBER
  ) AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 02-SEP-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        teach_cal_type,
        teach_ci_sequence_number,
        fee_cal_type,
        fee_ci_sequence_number,
        fee_type,
        dt_alias,
        dai_sequence_number,
        ret_percentage,
        ret_amount
      FROM  igs_fi_tp_ret_schd
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
        (tlinfo.teach_cal_type = x_teach_cal_type)
        AND (tlinfo.teach_ci_sequence_number = x_teach_ci_sequence_number)
        AND ((tlinfo.fee_cal_type = x_fee_cal_type) OR ((tlinfo.fee_cal_type IS NULL) AND (X_fee_cal_type IS NULL)))
        AND ((tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number) OR ((tlinfo.fee_ci_sequence_number IS NULL) AND (X_fee_ci_sequence_number IS NULL)))
        AND ((tlinfo.fee_type = x_fee_type) OR ((tlinfo.fee_type IS NULL) AND (X_fee_type IS NULL)))
        AND (tlinfo.dt_alias = x_dt_alias)
        AND (tlinfo.dai_sequence_number = x_dai_sequence_number)
        AND ((tlinfo.ret_percentage = x_ret_percentage) OR ((tlinfo.ret_percentage IS NULL) AND (X_ret_percentage IS NULL)))
        AND ((tlinfo.ret_amount = x_ret_amount) OR ((tlinfo.ret_amount IS NULL) AND (X_ret_amount IS NULL)))
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
    x_ftci_teach_retention_id           IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_ret_percentage                    IN     NUMBER,
    x_ret_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 02-SEP-2004
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_TP_RET_SCHD_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_ftci_teach_retention_id           => x_ftci_teach_retention_id,
      x_teach_cal_type                    => x_teach_cal_type,
      x_teach_ci_sequence_number          => x_teach_ci_sequence_number,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_fee_type                          => x_fee_type,
      x_dt_alias                          => x_dt_alias,
      x_dai_sequence_number               => x_dai_sequence_number,
      x_ret_percentage                    => x_ret_percentage,
      x_ret_amount                        => x_ret_amount,
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

    UPDATE igs_fi_tp_ret_schd
      SET
        teach_cal_type                    = new_references.teach_cal_type,
        teach_ci_sequence_number          = new_references.teach_ci_sequence_number,
        fee_cal_type                      = new_references.fee_cal_type,
        fee_ci_sequence_number            = new_references.fee_ci_sequence_number,
        fee_type                          = new_references.fee_type,
        dt_alias                          = new_references.dt_alias,
        dai_sequence_number               = new_references.dai_sequence_number,
        ret_percentage                    = new_references.ret_percentage,
        ret_amount                        = new_references.ret_amount,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
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
    x_ftci_teach_retention_id           IN OUT NOCOPY NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_ret_percentage                    IN     NUMBER,
    x_ret_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 02-SEP-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_tp_ret_schd
      WHERE    ftci_teach_retention_id           = x_ftci_teach_retention_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ftci_teach_retention_id,
        x_teach_cal_type,
        x_teach_ci_sequence_number,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
        x_fee_type,
        x_dt_alias,
        x_dai_sequence_number,
        x_ret_percentage,
        x_ret_amount,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ftci_teach_retention_id,
      x_teach_cal_type,
      x_teach_ci_sequence_number,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_type,
      x_dt_alias,
      x_dai_sequence_number,
      x_ret_percentage,
      x_ret_amount,
      x_mode
    );

  END add_row;

  PROCEDURE get_fk_igs_ca_da_inst (
    x_dt_alias                          IN     VARCHAR2,
    x_dai_sequence_number               IN     NUMBER,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER
  ) AS
    /*
  ||  Created By : rmaddipa
  ||  Created On : 02-SEP-04
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_tp_ret_schd
      WHERE   ((dt_alias = x_dt_alias ) AND
               (dai_sequence_number = x_dai_sequence_number) AND
	       (teach_cal_type = x_teach_cal_type) AND
	       (teach_ci_sequence_number = x_teach_ci_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_TPRS_DAI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_ca_da_inst;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 08-SEP-2004
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

    DELETE FROM igs_fi_tp_ret_schd
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


  PROCEDURE Check_Constraints (
   	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
  ) AS
  /*
  ||  Created By : raghavendra.maddipatla@oracle.com
  ||  Created On : 20-SEP-2004
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN
    IF Column_Name is NULL THEN
       	NULL;
    ELSIF Upper(Column_Name) = 'RET_PERCENTAGE' THEN
        new_references.ret_percentage := igs_ge_number.to_num (column_value);
    ELSIF Upper(Column_Name) = 'RET_AMOUNT' THEN
        new_references.ret_amount := igs_ge_number.to_num (column_value);
    END IF;

    IF (Upper(Column_Name) = 'RET_PERCENTAGE' OR Column_Name IS NULL) THEN
        IF (new_references.ret_percentage <= 0 OR new_references.ret_percentage > 100) THEN
	     fnd_message.set_name('IGS','IGS_FI_RET_PERCENT_GT_ZERO');
	     igs_ge_msg_stack.add;
             App_Exception.Raise_Exception;
        END IF;
    END IF;

    IF (Upper(Column_Name) = 'RET_AMOUNT' OR Column_Name IS NULL) THEN
        IF (new_references.ret_amount <= 0) THEN
             fnd_message.set_name('IGS','IGS_FI_RET_AMT_GT_ZERO');
	     igs_ge_msg_stack.add;
             App_Exception.Raise_Exception;
        END IF;
    END IF;

  END Check_Constraints;
END igs_fi_tp_ret_schd_pkg;

/
