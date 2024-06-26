--------------------------------------------------------
--  DDL for Package Body IGS_FI_WAIVER_PGMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_WAIVER_PGMS_PKG" AS
/* $Header: IGSSIF6B.pls 120.0 2005/09/09 18:34:21 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_waiver_pgms%ROWTYPE;
  new_references igs_fi_waiver_pgms%ROWTYPE;

   PROCEDURE check_parent_existance AS
  /*
  ||  Created By : umesh.udayaprakash@oracle.com
  ||  Created On : 27-JUL-2005
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

  /*
  Check For the igs_ca_inst_all Foriegn Key
  */
    IF (((old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)
         ) OR
        ((new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) )) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.fee_cal_type,
                new_references.fee_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  /*
  Check For the parent validation for credit_type_id
  */
    IF (old_references.credit_type_id = new_references.credit_type_id) OR
       (new_references.credit_type_id IS NULL)  THEN
      NULL;
    ELSIF NOT igs_fi_cr_types_pkg.get_pk_for_validation(new_references.credit_type_id) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  /*
  Check For the parent validation for adjustment_fee_type
  */
    IF (old_references.adjustment_fee_type = new_references.adjustment_fee_type) OR
       (new_references.adjustment_fee_type IS NULL)  THEN
      NULL;
    ELSIF NOT igs_fi_fee_type_pkg.get_pk_for_validation(new_references.adjustment_fee_type) THEN
      fnd_message.set_name ('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  /*
  Check For the parent validation for rule_fee_type
  */
    IF ((new_references.waiver_method_code <> 'COMP_RULE' )
       OR (old_references.waiver_method_code = new_references.waiver_method_code)) THEN
      NULL;
    ELSIF NOT igs_fi_fee_type_pkg.get_pk_for_validation(new_references.rule_fee_type) THEN
      fnd_message.set_name ('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  /*
  Check For the parent validation for target_fee_type
  */
    IF (old_references.target_fee_type = new_references.target_fee_type) OR
       (new_references.target_fee_type IS NULL)  THEN
      NULL;
    ELSIF NOT igs_fi_fee_type_pkg.get_pk_for_validation(new_references.target_fee_type) THEN
      fnd_message.set_name ('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  PROCEDURE Check_Constraints (
   	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	   Column_Value 	IN	VARCHAR2	DEFAULT NULL
  ) AS
  /*
  ||  Created By : Umesh.udayaprakash@oracle.com
  ||  Created On : 7/28/2005
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN
    IF Column_Name is NULL THEN
       	NULL;
    ELSIF (Upper(Column_Name) = 'WAIVER_METHOD_CODE' AND Upper(Column_Value) = 'COMP_RULE' ) THEN
      IF ((new_references.waiver_criteria_code IS NULL) OR (new_references.WAIVER_PERCENT_ALLOC IS NULL) OR (new_references.RULE_FEE_TYPE IS NULL)) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
   END IF;
  END Check_Constraints;


  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_waiver_desc                       IN     VARCHAR2,
    x_waiver_status_code                IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_adjustment_fee_type               IN     VARCHAR2,
    x_target_fee_type                   IN     VARCHAR2,
    x_waiver_method_code                IN     VARCHAR2,
    x_waiver_mode_code                  IN     VARCHAR2,
    x_waiver_criteria_code              IN     VARCHAR2,
    x_waiver_percent_alloc              IN     NUMBER,
    x_rule_fee_type                     IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : umesh.udayaprakash@oracle.com
  ||  Created On : 27-JUL-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_waiver_pgms
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
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
    new_references.waiver_name                       := x_waiver_name;
    new_references.object_version_number             := x_object_version_number;
    new_references.waiver_desc                       := x_waiver_desc;
    new_references.waiver_status_code                := x_waiver_status_code;
    new_references.credit_type_id                    := x_credit_type_id;
    new_references.adjustment_fee_type               := x_adjustment_fee_type;
    new_references.target_fee_type                   := x_target_fee_type;
    new_references.waiver_method_code                := x_waiver_method_code;
    new_references.waiver_mode_code                  := x_waiver_mode_code;
    new_references.waiver_criteria_code              := x_waiver_criteria_code;
    new_references.waiver_percent_alloc              := x_waiver_percent_alloc;
    new_references.rule_fee_type                     := x_rule_fee_type;

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
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : umesh.udayaprakash@oracle.com
  ||  Created On : 27-JUL-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_waiver_pgms
      WHERE    fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      waiver_name = x_waiver_name
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
    x_rowid                             IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_waiver_desc                       IN     VARCHAR2,
    x_waiver_status_code                IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_adjustment_fee_type               IN     VARCHAR2,
    x_target_fee_type                   IN     VARCHAR2,
    x_waiver_method_code                IN     VARCHAR2,
    x_waiver_mode_code                  IN     VARCHAR2,
    x_waiver_criteria_code              IN     VARCHAR2,
    x_waiver_percent_alloc              IN     NUMBER,
    x_rule_fee_type                     IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : umesh.udayaprakash@oracle.com
  ||  Created On : 27-JUL-2005
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
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_waiver_name,
      x_object_version_number,
      x_waiver_desc,
      x_waiver_status_code,
      x_credit_type_id,
      x_adjustment_fee_type,
      x_target_fee_type,
      x_waiver_method_code,
      x_waiver_mode_code,
      x_waiver_criteria_code,
      x_waiver_percent_alloc,
      x_rule_fee_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.fee_cal_type,
             new_references.fee_ci_sequence_number,
             new_references.waiver_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.fee_cal_type,
             new_references.fee_ci_sequence_number,
             new_references.waiver_name
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
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_waiver_desc                       IN     VARCHAR2,
    x_waiver_status_code                IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_adjustment_fee_type               IN     VARCHAR2,
    x_target_fee_type                   IN     VARCHAR2,
    x_waiver_method_code                IN     VARCHAR2,
    x_waiver_mode_code                  IN     VARCHAR2,
    x_waiver_criteria_code              IN     VARCHAR2,
    x_waiver_percent_alloc              IN     NUMBER,
    x_rule_fee_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : umesh.udayaprakash@oracle.com
  ||  Created On : 27-JUL-2005
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_WAIVER_PGMS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_waiver_name                       => x_waiver_name,
      x_object_version_number             => 1,
      x_waiver_desc                       => x_waiver_desc,
      x_waiver_status_code                => x_waiver_status_code,
      x_credit_type_id                    => x_credit_type_id,
      x_adjustment_fee_type               => x_adjustment_fee_type,
      x_target_fee_type                   => x_target_fee_type,
      x_waiver_method_code                => x_waiver_method_code,
      x_waiver_mode_code                  => x_waiver_mode_code,
      x_waiver_criteria_code              => x_waiver_criteria_code,
      x_waiver_percent_alloc              => x_waiver_percent_alloc,
      x_rule_fee_type                     => x_rule_fee_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_waiver_pgms (
      fee_cal_type,
      fee_ci_sequence_number,
      waiver_name,
      object_version_number,
      waiver_desc,
      waiver_status_code,
      credit_type_id,
      adjustment_fee_type,
      target_fee_type,
      waiver_method_code,
      waiver_mode_code,
      waiver_criteria_code,
      waiver_percent_alloc,
      rule_fee_type,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.waiver_name,
      new_references.object_version_number,
      new_references.waiver_desc,
      new_references.waiver_status_code,
      new_references.credit_type_id,
      new_references.adjustment_fee_type,
      new_references.target_fee_type,
      new_references.waiver_method_code,
      new_references.waiver_mode_code,
      new_references.waiver_criteria_code,
      new_references.waiver_percent_alloc,
      new_references.rule_fee_type,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_waiver_desc                       IN     VARCHAR2,
    x_waiver_status_code                IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_adjustment_fee_type               IN     VARCHAR2,
    x_target_fee_type                   IN     VARCHAR2,
    x_waiver_method_code                IN     VARCHAR2,
    x_waiver_mode_code                  IN     VARCHAR2,
    x_waiver_criteria_code              IN     VARCHAR2,
    x_waiver_percent_alloc              IN     NUMBER,
    x_rule_fee_type                     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : umesh.udayaprakash@oracle.com
  ||  Created On : 27-JUL-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        object_version_number,
        waiver_desc,
        waiver_status_code,
        credit_type_id,
        adjustment_fee_type,
        target_fee_type,
        waiver_method_code,
        waiver_mode_code,
        waiver_criteria_code,
        waiver_percent_alloc,
        rule_fee_type
      FROM  igs_fi_waiver_pgms
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
        (tlinfo.object_version_number = x_object_version_number)
        AND (tlinfo.waiver_desc = x_waiver_desc)
        AND (tlinfo.waiver_status_code = x_waiver_status_code)
        AND (tlinfo.credit_type_id = x_credit_type_id)
        AND (tlinfo.adjustment_fee_type = x_adjustment_fee_type)
        AND (tlinfo.target_fee_type = x_target_fee_type)
        AND (tlinfo.waiver_method_code = x_waiver_method_code)
        AND (tlinfo.waiver_mode_code = x_waiver_mode_code)
        AND ((tlinfo.waiver_criteria_code = x_waiver_criteria_code) OR ((tlinfo.waiver_criteria_code IS NULL) AND (X_waiver_criteria_code IS NULL)))
        AND ((tlinfo.waiver_percent_alloc = x_waiver_percent_alloc) OR ((tlinfo.waiver_percent_alloc IS NULL) AND (X_waiver_percent_alloc IS NULL)))
        AND ((tlinfo.rule_fee_type = x_rule_fee_type) OR ((tlinfo.rule_fee_type IS NULL) AND (X_rule_fee_type IS NULL)))
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
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_waiver_desc                       IN     VARCHAR2,
    x_waiver_status_code                IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_adjustment_fee_type               IN     VARCHAR2,
    x_target_fee_type                   IN     VARCHAR2,
    x_waiver_method_code                IN     VARCHAR2,
    x_waiver_mode_code                  IN     VARCHAR2,
    x_waiver_criteria_code              IN     VARCHAR2,
    x_waiver_percent_alloc              IN     NUMBER,
    x_rule_fee_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : umesh.udayaprakash@oracle.com
  ||  Created On : 27-JUL-2005
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

    CURSOR cur_waiver_pgms(cp_rowid         varchar2) IS
      SELECT object_version_number
      FROM   igs_fi_waiver_pgms
      WHERE  rowid = cp_rowid
      FOR UPDATE NOWAIT;
    l_n_object_version_number           igs_fi_waiver_pgms.object_version_number%TYPE;

  BEGIN

    OPEN cur_waiver_pgms(x_rowid);
    FETCH cur_waiver_pgms INTO l_n_object_version_number;
    CLOSE cur_waiver_pgms;

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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_WAIVER_PGMS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_waiver_name                       => x_waiver_name,
      x_object_version_number             => l_n_object_version_number,
      x_waiver_desc                       => x_waiver_desc,
      x_waiver_status_code                => x_waiver_status_code,
      x_credit_type_id                    => x_credit_type_id,
      x_adjustment_fee_type               => x_adjustment_fee_type,
      x_target_fee_type                   => x_target_fee_type,
      x_waiver_method_code                => x_waiver_method_code,
      x_waiver_mode_code                  => x_waiver_mode_code,
      x_waiver_criteria_code              => x_waiver_criteria_code,
      x_waiver_percent_alloc              => x_waiver_percent_alloc,
      x_rule_fee_type                     => x_rule_fee_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_fi_waiver_pgms
      SET
        object_version_number             = l_n_object_version_number +1, --Made this Change to Maintain the OVN Sync
        waiver_desc                       = new_references.waiver_desc,
        waiver_status_code                = new_references.waiver_status_code,
        credit_type_id                    = new_references.credit_type_id,
        adjustment_fee_type               = new_references.adjustment_fee_type,
        target_fee_type                   = new_references.target_fee_type,
        waiver_method_code                = new_references.waiver_method_code,
        waiver_mode_code                  = new_references.waiver_mode_code,
        waiver_criteria_code              = new_references.waiver_criteria_code,
        waiver_percent_alloc              = new_references.waiver_percent_alloc,
        rule_fee_type                     = new_references.rule_fee_type,
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
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_waiver_desc                       IN     VARCHAR2,
    x_waiver_status_code                IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_adjustment_fee_type               IN     VARCHAR2,
    x_target_fee_type                   IN     VARCHAR2,
    x_waiver_method_code                IN     VARCHAR2,
    x_waiver_mode_code                  IN     VARCHAR2,
    x_waiver_criteria_code              IN     VARCHAR2,
    x_waiver_percent_alloc              IN     NUMBER,
    x_rule_fee_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : umesh.udayaprakash@oracle.com
  ||  Created On : 27-JUL-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_waiver_pgms
      WHERE    fee_cal_type                      = x_fee_cal_type
      AND      fee_ci_sequence_number            = x_fee_ci_sequence_number
      AND      waiver_name                       = x_waiver_name;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
        x_waiver_name,
        x_waiver_desc,
        x_waiver_status_code,
        x_credit_type_id,
        x_adjustment_fee_type,
        x_target_fee_type,
        x_waiver_method_code,
        x_waiver_mode_code,
        x_waiver_criteria_code,
        x_waiver_percent_alloc,
        x_rule_fee_type,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_waiver_name,
      x_waiver_desc,
      x_waiver_status_code,
      x_credit_type_id,
      x_adjustment_fee_type,
      x_target_fee_type,
      x_waiver_method_code,
      x_waiver_mode_code,
      x_waiver_criteria_code,
      x_waiver_percent_alloc,
      x_rule_fee_type,
      x_mode
    );

  END add_row;


END igs_fi_waiver_pgms_pkg;

/
