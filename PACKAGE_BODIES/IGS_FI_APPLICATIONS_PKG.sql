--------------------------------------------------------
--  DDL for Package Body IGS_FI_APPLICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_APPLICATIONS_PKG" AS
/* $Header: IGSSI94B.pls 115.12 2003/02/17 08:46:58 pathipat ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_applications%ROWTYPE;
  new_references igs_fi_applications%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_application_id                    IN     NUMBER      ,
    x_application_type                  IN     VARCHAR2    ,
    x_invoice_id                        IN     NUMBER      ,
    x_credit_id                         IN     NUMBER      ,
    x_credit_activity_id                IN     NUMBER      ,
    x_amount_applied                    IN     NUMBER      ,
    x_apply_date                        IN     DATE        ,
    x_link_application_id               IN     NUMBER      ,
    x_dr_account_cd                     IN     VARCHAR2    ,
    x_cr_account_cd                     IN     VARCHAR2    ,
    x_dr_gl_code_ccid                   IN     NUMBER      ,
    x_cr_gl_code_ccid                   IN     NUMBER      ,
    x_applied_invoice_lines_id          IN     NUMBER      ,
    x_appl_hierarchy_id                 IN     NUMBER      ,
    x_posting_id                        IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_gl_date                           IN     DATE        ,
    x_gl_posted_date                    IN     DATE        ,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_APPLICATIONS
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
    new_references.application_id                    := x_application_id;
    new_references.application_type                  := x_application_type;
    new_references.invoice_id                        := x_invoice_id;
    new_references.credit_id                         := x_credit_id;
    new_references.credit_activity_id                := x_credit_activity_id;
    new_references.amount_applied                    := x_amount_applied;
    new_references.apply_date                        := x_apply_date;
    new_references.link_application_id               := x_link_application_id;
    new_references.dr_account_cd                     := x_dr_account_cd;
    new_references.cr_account_cd                     := x_cr_account_cd;
    new_references.dr_gl_code_ccid                   := x_dr_gl_code_ccid;
    new_references.cr_gl_code_ccid                   := x_cr_gl_code_ccid;
    new_references.applied_invoice_lines_id          := x_applied_invoice_lines_id;
    new_references.appl_hierarchy_id                 := x_appl_hierarchy_id;
    new_references.posting_id                        := x_posting_id;
    new_references.gl_date                           := TRUNC(x_gl_date);
    new_references.gl_posted_date                    := x_gl_posted_date;
    new_references.posting_control_id                := x_posting_control_id;

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
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ((old_references.cr_account_cd = new_references.cr_account_cd) OR
         (new_references.cr_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.cr_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((old_references.dr_account_cd = new_references.dr_account_cd) OR
         (new_references.dr_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.dr_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.application_type = new_references.application_type)) OR
        ((new_references.application_type IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'IGS_FI_APPLICATION_TYPE',
          new_references.application_type
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.credit_id = new_references.credit_id)) OR
        ((new_references.credit_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_credits_pkg.get_pk_for_validation (
                new_references.credit_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.credit_activity_id = new_references.credit_activity_id)) OR
        ((new_references.credit_activity_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_cr_activities_pkg.get_pk_for_validation (
                new_references.credit_activity_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.posting_id = new_references.posting_id)) OR
        ((new_references.posting_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_posting_int_pkg.get_pk_for_validation (
                new_references.posting_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.appl_hierarchy_id = new_references.appl_hierarchy_id)) OR
        ((new_references.appl_hierarchy_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_a_hierarchies_pkg.get_pk_for_validation (
                new_references.appl_hierarchy_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.invoice_id = new_references.invoice_id)) OR
        ((new_references.invoice_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_inv_int_pkg.get_pk_for_validation (
                new_references.invoice_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.applied_invoice_lines_id = new_references.applied_invoice_lines_id)) OR
        ((new_references.applied_invoice_lines_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_invln_int_pkg.get_pk_for_validation (
                new_references.applied_invoice_lines_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_application_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_applications
      WHERE    application_id = x_application_id
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


  PROCEDURE get_fk_igs_fi_credits_all (
    x_credit_id                         IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_applications
      WHERE   ((credit_id = x_credit_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_APPL_CRDT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_credits_all;


  PROCEDURE get_fk_igs_fi_cr_activities (
    x_credit_activity_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_applications
      WHERE   ((credit_activity_id = x_credit_activity_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_APPL_CRAC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_cr_activities;


  PROCEDURE get_fk_igs_fi_posting_int_all (
    x_posting_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_applications
      WHERE   ((posting_id = x_posting_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_APPL_PINT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_posting_int_all;


  PROCEDURE get_fk_igs_fi_a_hierarchies (
    x_appl_hierarchy_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_applications
      WHERE   ((appl_hierarchy_id = x_appl_hierarchy_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_APPL_APHR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_a_hierarchies;


  PROCEDURE get_fk_igs_fi_inv_int_all (
    x_invoice_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_applications
      WHERE   ((invoice_id = x_invoice_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_APPL_INVI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_inv_int_all;


  PROCEDURE get_fk_igs_fi_invln_int_all (
    x_invoice_lines_id                  IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_applications
      WHERE   ((applied_invoice_lines_id = x_invoice_lines_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_APPL_INLI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_invln_int_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_application_id                    IN     NUMBER      ,
    x_application_type                  IN     VARCHAR2    ,
    x_invoice_id                        IN     NUMBER      ,
    x_credit_id                         IN     NUMBER      ,
    x_credit_activity_id                IN     NUMBER      ,
    x_amount_applied                    IN     NUMBER      ,
    x_apply_date                        IN     DATE        ,
    x_link_application_id               IN     NUMBER      ,
    x_dr_account_cd                     IN     VARCHAR2    ,
    x_cr_account_cd                     IN     VARCHAR2    ,
    x_dr_gl_code_ccid                   IN     NUMBER      ,
    x_cr_gl_code_ccid                   IN     NUMBER      ,
    x_applied_invoice_lines_id          IN     NUMBER      ,
    x_appl_hierarchy_id                 IN     NUMBER      ,
    x_posting_id                        IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_gl_date                           IN     DATE        ,
    x_gl_posted_date                    IN     DATE        ,
    x_posting_control_id                IN     NUMBER

  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_application_id,
      x_application_type,
      x_invoice_id,
      x_credit_id,
      x_credit_activity_id,
      x_amount_applied,
      x_apply_date,
      x_link_application_id,
      x_dr_account_cd,
      x_cr_account_cd,
      x_dr_gl_code_ccid,
      x_cr_gl_code_ccid,
      x_applied_invoice_lines_id,
      x_appl_hierarchy_id,
      x_posting_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_gl_date,
      x_gl_posted_date,
      x_posting_control_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.application_id
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
             new_references.application_id
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
    x_application_id                    IN OUT NOCOPY NUMBER,
    x_application_type                  IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_amount_applied                    IN     NUMBER,
    x_apply_date                        IN     DATE,
    x_link_application_id               IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_applied_invoice_lines_id          IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_gl_date                           IN     DATE    ,
    x_gl_posted_date                    IN     DATE    ,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_applications
      WHERE    application_id                    = x_application_id;

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

    SELECT    igs_fi_applications_s.NEXTVAL
    INTO      x_application_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_application_id                    => x_application_id,
      x_application_type                  => x_application_type,
      x_invoice_id                        => x_invoice_id,
      x_credit_id                         => x_credit_id,
      x_credit_activity_id                => x_credit_activity_id,
      x_amount_applied                    => x_amount_applied,
      x_apply_date                        => x_apply_date,
      x_link_application_id               => x_link_application_id,
      x_dr_account_cd                     => x_dr_account_cd,
      x_cr_account_cd                     => x_cr_account_cd,
      x_dr_gl_code_ccid                   => x_dr_gl_code_ccid,
      x_cr_gl_code_ccid                   => x_cr_gl_code_ccid,
      x_applied_invoice_lines_id          => x_applied_invoice_lines_id,
      x_appl_hierarchy_id                 => x_appl_hierarchy_id,
      x_posting_id                        => x_posting_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_gl_date                           => x_gl_date,
      x_gl_posted_date                    => x_gl_posted_date,
      x_posting_control_id                => x_posting_control_id
    );

    INSERT INTO igs_fi_applications (
      application_id,
      application_type,
      invoice_id,
      credit_id,
      credit_activity_id,
      amount_applied,
      apply_date,
      link_application_id,
      dr_account_cd,
      cr_account_cd,
      dr_gl_code_ccid,
      cr_gl_code_ccid,
      applied_invoice_lines_id,
      appl_hierarchy_id,
      posting_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date ,
      gl_date,
      gl_posted_date,
      posting_control_id
    ) VALUES (
      new_references.application_id,
      new_references.application_type,
      new_references.invoice_id,
      new_references.credit_id,
      new_references.credit_activity_id,
      new_references.amount_applied,
      new_references.apply_date,
      new_references.link_application_id,
      new_references.dr_account_cd,
      new_references.cr_account_cd,
      new_references.dr_gl_code_ccid,
      new_references.cr_gl_code_ccid,
      new_references.applied_invoice_lines_id,
      new_references.appl_hierarchy_id,
      new_references.posting_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
      new_references.gl_date,
      new_references.gl_posted_date,
      new_references.posting_control_id
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
    x_application_id                    IN     NUMBER,
    x_application_type                  IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_amount_applied                    IN     NUMBER,
    x_apply_date                        IN     DATE,
    x_link_application_id               IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_applied_invoice_lines_id          IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_posting_id                        IN     NUMBER,
    x_gl_date                           IN     DATE,
    x_gl_posted_date                    IN     DATE,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        application_type,
        invoice_id,
        credit_id,
        credit_activity_id,
        amount_applied,
        apply_date,
        link_application_id,
        dr_account_cd,
        cr_account_cd,
        dr_gl_code_ccid,
        cr_gl_code_ccid,
        applied_invoice_lines_id,
        appl_hierarchy_id,
        posting_id,
        gl_date,
        gl_posted_date,
        posting_control_id
      FROM  igs_fi_applications
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
        (tlinfo.application_type = x_application_type)
        AND (tlinfo.invoice_id = x_invoice_id)
        AND (tlinfo.credit_id = x_credit_id)
        AND (tlinfo.credit_activity_id = x_credit_activity_id)
        AND (tlinfo.amount_applied = x_amount_applied)
        AND (trunc(tlinfo.apply_date) = trunc(x_apply_date))
        AND ((tlinfo.link_application_id = x_link_application_id) OR ((tlinfo.link_application_id IS NULL) AND (X_link_application_id IS NULL)))
        AND ((tlinfo.dr_account_cd = x_dr_account_cd) OR ((tlinfo.dr_account_cd IS NULL) AND (X_dr_account_cd IS NULL)))
        AND ((tlinfo.cr_account_cd = x_cr_account_cd) OR ((tlinfo.cr_account_cd IS NULL) AND (X_cr_account_cd IS NULL)))
        AND ((tlinfo.dr_gl_code_ccid = x_dr_gl_code_ccid) OR ((tlinfo.dr_gl_code_ccid IS NULL) AND (X_dr_gl_code_ccid IS NULL)))
        AND ((tlinfo.cr_gl_code_ccid = x_cr_gl_code_ccid) OR ((tlinfo.cr_gl_code_ccid IS NULL) AND (X_cr_gl_code_ccid IS NULL)))
        AND ((tlinfo.applied_invoice_lines_id = x_applied_invoice_lines_id) OR ((tlinfo.applied_invoice_lines_id IS NULL) AND (X_applied_invoice_lines_id IS NULL)))
        AND ((tlinfo.appl_hierarchy_id = x_appl_hierarchy_id) OR ((tlinfo.appl_hierarchy_id IS NULL) AND (X_appl_hierarchy_id IS NULL)))
        AND ((tlinfo.posting_id = x_posting_id) OR ((tlinfo.posting_id IS NULL) AND (X_posting_id IS NULL)))
        AND ((TRUNC(tlinfo.gl_date) = TRUNC(x_gl_date)) OR ((tlinfo.gl_date IS NULL) AND (X_gl_date IS NULL)))
        AND ((tlinfo.gl_posted_date = x_gl_posted_date) OR ((tlinfo.gl_posted_date IS NULL) AND (X_gl_posted_date IS NULL)))
        AND ((tlinfo.posting_control_id = x_posting_control_id) OR ((tlinfo.posting_control_id IS NULL) AND (X_posting_control_id IS NULL)))
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
    x_application_id                    IN     NUMBER,
    x_application_type                  IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_amount_applied                    IN     NUMBER,
    x_apply_date                        IN     DATE,
    x_link_application_id               IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_applied_invoice_lines_id          IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_gl_posted_date                    IN     DATE,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
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
      x_application_id                    => x_application_id,
      x_application_type                  => x_application_type,
      x_invoice_id                        => x_invoice_id,
      x_credit_id                         => x_credit_id,
      x_credit_activity_id                => x_credit_activity_id,
      x_amount_applied                    => x_amount_applied,
      x_apply_date                        => x_apply_date,
      x_link_application_id               => x_link_application_id,
      x_dr_account_cd                     => x_dr_account_cd,
      x_cr_account_cd                     => x_cr_account_cd,
      x_dr_gl_code_ccid                   => x_dr_gl_code_ccid,
      x_cr_gl_code_ccid                   => x_cr_gl_code_ccid,
      x_applied_invoice_lines_id          => x_applied_invoice_lines_id,
      x_appl_hierarchy_id                 => x_appl_hierarchy_id,
      x_posting_id                        => x_posting_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_gl_date                           => x_gl_date,
      x_gl_posted_date                    => x_gl_posted_date,
      x_posting_control_id                => x_posting_control_id
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

    UPDATE igs_fi_applications
      SET
        application_type                  = new_references.application_type,
        invoice_id                        = new_references.invoice_id,
        credit_id                         = new_references.credit_id,
        credit_activity_id                = new_references.credit_activity_id,
        amount_applied                    = new_references.amount_applied,
        apply_date                        = new_references.apply_date,
        link_application_id               = new_references.link_application_id,
        dr_account_cd                     = new_references.dr_account_cd,
        cr_account_cd                     = new_references.cr_account_cd,
        dr_gl_code_ccid                   = new_references.dr_gl_code_ccid,
        cr_gl_code_ccid                   = new_references.cr_gl_code_ccid,
        applied_invoice_lines_id          = new_references.applied_invoice_lines_id,
        appl_hierarchy_id                 = new_references.appl_hierarchy_id,
        posting_id                        = new_references.posting_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date ,
        gl_date                           = new_references.gl_date,
        gl_posted_date                    = new_references.gl_posted_date,
        posting_control_id                = new_references.posting_control_id
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_application_id                    IN OUT NOCOPY NUMBER,
    x_application_type                  IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_amount_applied                    IN     NUMBER,
    x_apply_date                        IN     DATE,
    x_link_application_id               IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_applied_invoice_lines_id          IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_gl_posted_date                    IN     DATE,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_applications
      WHERE    application_id                    = x_application_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_application_id,
        x_application_type,
        x_invoice_id,
        x_credit_id,
        x_credit_activity_id,
        x_amount_applied,
        x_apply_date,
        x_link_application_id,
        x_dr_account_cd,
        x_cr_account_cd,
        x_dr_gl_code_ccid,
        x_cr_gl_code_ccid,
        x_applied_invoice_lines_id,
        x_appl_hierarchy_id,
        x_posting_id,
        x_mode ,
        x_gl_date,
        x_gl_posted_date,
        x_posting_control_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_application_id,
      x_application_type,
      x_invoice_id,
      x_credit_id,
      x_credit_activity_id,
      x_amount_applied,
      x_apply_date,
      x_link_application_id,
      x_dr_account_cd,
      x_cr_account_cd,
      x_dr_gl_code_ccid,
      x_cr_gl_code_ccid,
      x_applied_invoice_lines_id,
      x_appl_hierarchy_id,
      x_posting_id,
      x_mode,
      x_gl_date,
      x_gl_posted_date,
      x_posting_control_id
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
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

    DELETE FROM igs_fi_applications
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_applications_pkg;

/
