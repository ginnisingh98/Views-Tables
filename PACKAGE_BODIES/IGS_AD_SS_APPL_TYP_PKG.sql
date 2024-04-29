--------------------------------------------------------
--  DDL for Package Body IGS_AD_SS_APPL_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_SS_APPL_TYP_PKG" AS
/* $Header: IGSAIF8B.pls 120.2 2005/12/15 03:52:25 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_ss_appl_typ%ROWTYPE;
  new_references igs_ad_ss_appl_typ%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_configurability_func_name         IN     VARCHAR2,
    x_application_fee_amount            IN     NUMBER,
    x_gl_rev_acct_ccid                  IN     NUMBER,
    x_gl_cash_acct_ccid                 IN     NUMBER,
    x_rev_account_code                  IN     VARCHAR2,
    x_cash_account_code                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_system_default                    IN     VARCHAR2,
    x_enroll_deposit_amount             IN     NUMBER,
    x_enroll_deposit_level              IN     VARCHAR2,
    x_use_in_appl_self_srvc             IN     VARCHAR2,
    x_crt_rev_instr                     IN     VARCHAR2,
    x_submit_instr                      IN     VARCHAR2,
    x_submit_err_instr                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ad_ss_appl_typ
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
    new_references.admission_application_type        := x_admission_application_type;
    new_references.description                       := x_description;
    new_references.admission_cat                     := x_admission_cat;
    new_references.s_admission_process_type          := x_s_admission_process_type;
    new_references.configurability_func_name         := x_configurability_func_name;
    new_references.application_fee_amount            := x_application_fee_amount;
    new_references.gl_rev_acct_ccid                  := x_gl_rev_acct_ccid;
    new_references.gl_cash_acct_ccid                 := x_gl_cash_acct_ccid;
    new_references.rev_account_code                  := x_rev_account_code;
    new_references.cash_account_code                 := x_cash_account_code;
    new_references.closed_ind                        := x_closed_ind;
    new_references.system_default                    := x_system_default;
    new_references.enroll_deposit_amount             := x_enroll_deposit_amount;
    new_references.enroll_deposit_level              := x_enroll_deposit_level;
    new_references.use_in_appl_self_srvc             := x_use_in_appl_self_srvc;
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
    new_references.crt_rev_instr                     := x_crt_rev_instr;
    new_references.submit_instr                      := x_submit_instr;
    new_references.submit_err_instr                  := x_submit_err_instr;

  END set_column_values;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : rghosh
  ||  Created On : 04-oct-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

  IF (((old_references.admission_cat = new_references.admission_cat) AND
         (old_references.s_admission_process_type = new_references.s_admission_process_type)) OR
        ((new_references.admission_cat IS NULL) OR
         (new_references.s_admission_process_type IS NULL))) THEN
      NULL;
    ELSE
 	IF NOT IGS_AD_PRCS_CAT_PKG.Get_PK_For_Validation (
        new_references.admission_cat,
        new_references.s_admission_process_type,
        'N' ) THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	 END IF;
    END IF;

  END Check_Parent_Existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vdixit          09-Jan-2001     Calls to igs_ad_aptyp_pestat_pkg.get_fk_igs_ad_ss_appl_typ
  ||  				      and igs_ad_pestat_group_pkg.get_fk_igs_ad_ss_appl_typ added
  ||				      a part of Enh. 2152871
  ||  rboddu          26-dec-2001     added call to igs_ad_appl_pkg.get_fk_igs_ad_ss_appl_typ procedure.
  ||                                  Bug no : 2158524
  ||  rghosh          28-oct-2002     Added the get fk calls to the tables IGS_AD_DEPLVL_PRG and
  ||                                  IGS_AD_DEPLVL_PRGTY for Bug #2602077
  */
  BEGIN

    igs_ad_appl_pkg.get_fk_igs_ad_ss_appl_typ(
      old_references.admission_application_type
    );

    igs_ad_aptyp_pestat_pkg.get_fk_igs_ad_ss_appl_typ(
      old_references.admission_application_type
    );

    igs_ad_pestat_group_pkg.get_fk_igs_ad_ss_appl_typ(
      old_references.admission_application_type
    );
    igs_ad_deplvl_prgty_pkg.get_fk_igs_ad_ss_appl_typ(
      old_references.admission_application_type
    );
    igs_ad_deplvl_prg_pkg.get_fk_igs_ad_ss_appl_typ(
      old_references.admission_application_type
    );

   igs_uc_defaults_pkg.get_fk_igs_ad_ss_appl_typ(
      old_references.admission_application_type );


  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_admission_application_type               IN     VARCHAR2,
    x_closed_ind                               IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_ss_appl_typ
      WHERE    UPPER(admission_application_type) = UPPER(x_admission_application_type) AND
               closed_ind = NVL(x_closed_ind,closed_ind);

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


 PROCEDURE get_fk_igs_ad_prcs_cat (
    x_admission_cat            IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2
    ) AS
/*************************************************************
  Created By :rghosh
  Date Created By : 04-oct-2002
  Purpose :checks for the presence of child record when parent record is deleted
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_ss_appl_typ
      WHERE    admission_cat = x_admission_cat
      AND      s_admission_process_type = x_s_admission_process_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_SSAT_PRC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_prcs_cat;



PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2,
	 Column_Value 	IN	VARCHAR2
	)
	 AS
BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'CLOSED_IND' then
     new_references.closed_ind := column_value;
 END IF;

IF upper(column_name) = 'CLOSED_IND' OR
     column_name is null Then
     IF NOT (new_references.closed_ind  IN ('Y','N')) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
	END IF;
END IF;

END Check_Constraints;



  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_configurability_func_name         IN     VARCHAR2,
    x_application_fee_amount            IN     NUMBER,
    x_gl_rev_acct_ccid                  IN     NUMBER,
    x_gl_cash_acct_ccid                 IN     NUMBER,
    x_rev_account_code                  IN     VARCHAR2,
    x_cash_account_code                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_system_default			IN     VARCHAR2,
    x_enroll_deposit_amount             IN     NUMBER,
    x_enroll_deposit_level              IN     VARCHAR2,
    x_use_in_appl_self_srvc             IN     VARCHAR2,
    x_crt_rev_instr                     IN     VARCHAR2,
    x_submit_instr                      IN     VARCHAR2,
    x_submit_err_instr                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When              What
  ||  rghosh         04-oct-2002      added the PROCEDURE GET_FK_IGS_AD_PRCS_CAT
  ||                                  and added the column system default for
  ||                                  Bug # 2599457
  ||  rghosh         17-oct-2002      added the columns enroll_deposit_amount and
  ||                                  enroll_deposit_level columns for Bug
  ||                                  #2602077
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_admission_application_type,
      x_description,
      x_admission_cat,
      x_s_admission_process_type,
      x_configurability_func_name,
      x_application_fee_amount,
      x_gl_rev_acct_ccid,
      x_gl_cash_acct_ccid,
      x_rev_account_code,
      x_cash_account_code,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_system_default,
      x_enroll_deposit_amount,
      x_enroll_deposit_level,
      x_use_in_appl_self_srvc,
      x_crt_rev_instr,
      x_submit_instr,
      x_submit_err_instr
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.admission_application_type
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.admission_application_type
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_admission_application_type               IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_configurability_func_name         IN     VARCHAR2,
    x_application_fee_amount            IN     NUMBER,
    x_gl_rev_acct_ccid                  IN     NUMBER,
    x_gl_cash_acct_ccid                 IN     NUMBER,
    x_rev_account_code                  IN     VARCHAR2,
    x_cash_account_code                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_system_default			IN     VARCHAR2,
    x_enroll_deposit_amount             IN     NUMBER,
    x_enroll_deposit_level              IN     VARCHAR2,
    x_use_in_appl_self_srvc             IN     VARCHAR2,
    x_crt_rev_instr                     IN     VARCHAR2,
    x_submit_instr                      IN     VARCHAR2,
    x_submit_err_instr                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  rghosh         04-oct-2002      added the PROCEDURE GET_FK_IGS_AD_PRCS_CAT
  ||                                  and added the column system default for
  ||                                  Bug # 2599457
  ||  rghosh         17-oct-2002      added the columns enroll_deposit_amount and
  ||                                  enroll_deposit_level columns for Bug
  ||                                  #2602077
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_ss_appl_typ
      WHERE    admission_application_type               = x_admission_application_type;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_admission_application_type        => x_admission_application_type,
      x_description                       => x_description,
      x_admission_cat                     => x_admission_cat,
      x_s_admission_process_type          => x_s_admission_process_type,
      x_configurability_func_name         => x_configurability_func_name,
      x_application_fee_amount            => x_application_fee_amount,
      x_gl_rev_acct_ccid                  => x_gl_rev_acct_ccid,
      x_gl_cash_acct_ccid                 => x_gl_cash_acct_ccid,
      x_rev_account_code                  => x_rev_account_code,
      x_cash_account_code                 => x_cash_account_code,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_system_default                    => x_system_default,
      x_enroll_deposit_amount             => x_enroll_deposit_amount,
      x_enroll_deposit_level              => x_enroll_deposit_level,
      x_use_in_appl_self_srvc             => x_use_in_appl_self_srvc,
      x_crt_rev_instr                     => x_crt_rev_instr,
      x_submit_instr                      => x_submit_instr,
      x_submit_err_instr                  => x_submit_err_instr
    );

    INSERT INTO igs_ad_ss_appl_typ (
      admission_application_type,
      description,
      admission_cat,
      s_admission_process_type,
      configurability_func_name,
      application_fee_amount,
      gl_rev_acct_ccid,
      gl_cash_acct_ccid,
      rev_account_code,
      cash_account_code,
      closed_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      system_default,
      enroll_deposit_amount,
      enroll_deposit_level,
      use_in_appl_self_srvc,
      crt_rev_instr,
      submit_instr,
      submit_err_instr
    ) VALUES (
      new_references.admission_application_type,
      new_references.description,
      new_references.admission_cat,
      new_references.s_admission_process_type,
      new_references.configurability_func_name,
      new_references.application_fee_amount,
      new_references.gl_rev_acct_ccid,
      new_references.gl_cash_acct_ccid,
      new_references.rev_account_code,
      new_references.cash_account_code,
      new_references.closed_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.system_default,
      new_references.enroll_deposit_amount,
      new_references.enroll_deposit_level,
      new_references.use_in_appl_self_srvc,
      new_references.crt_rev_instr,
      new_references.submit_instr,
      new_references.submit_err_instr
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
    x_admission_application_type        IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_configurability_func_name         IN     VARCHAR2,
    x_application_fee_amount            IN     NUMBER,
    x_gl_rev_acct_ccid                  IN     NUMBER,
    x_gl_cash_acct_ccid                 IN     NUMBER,
    x_rev_account_code                  IN     VARCHAR2,
    x_cash_account_code                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_system_default			IN     VARCHAR2,
    x_enroll_deposit_amount             IN     NUMBER,
    x_enroll_deposit_level              IN     VARCHAR2,
    x_use_in_appl_self_srvc             IN     VARCHAR2,
    x_crt_rev_instr                     IN     VARCHAR2,
    x_submit_instr                      IN     VARCHAR2,
    x_submit_err_instr                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  rghosh         04-oct-2002      added the PROCEDURE GET_FK_IGS_AD_PRCS_CAT
  ||                                  and added the column system default for
  ||                                  Bug # 2599457
  ||  rghosh         17-oct-2002      added the columns enroll_deposit_amount and
  ||                                  enroll_deposit_level columns for Bug
  ||                                  #2602077
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        description,
        admission_cat,
        s_admission_process_type,
        configurability_func_name,
        application_fee_amount,
        gl_rev_acct_ccid,
        gl_cash_acct_ccid,
        rev_account_code,
        cash_account_code,
	closed_ind,
	system_default,
	enroll_deposit_amount,
	enroll_deposit_level,
	use_in_appl_self_srvc,
        crt_rev_instr,
        submit_instr,
        submit_err_instr
      FROM  igs_ad_ss_appl_typ
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
        ((tlinfo.description = x_description) OR ((tlinfo.description IS NULL) AND (X_description IS NULL)))
        AND (tlinfo.admission_cat = x_admission_cat)
        AND (tlinfo.s_admission_process_type = x_s_admission_process_type)
        AND ((tlinfo.configurability_func_name = x_configurability_func_name) OR ((tlinfo.configurability_func_name IS NULL) AND (X_configurability_func_name IS NULL)))
        AND ((tlinfo.application_fee_amount = x_application_fee_amount) OR ((tlinfo.application_fee_amount IS NULL) AND (X_application_fee_amount IS NULL)))
        AND ((tlinfo.gl_rev_acct_ccid = x_gl_rev_acct_ccid) OR ((tlinfo.gl_rev_acct_ccid IS NULL) AND (X_gl_rev_acct_ccid IS NULL)))
        AND ((tlinfo.gl_cash_acct_ccid = x_gl_cash_acct_ccid) OR ((tlinfo.gl_cash_acct_ccid IS NULL) AND (X_gl_cash_acct_ccid IS NULL)))
        AND ((tlinfo.rev_account_code = x_rev_account_code) OR ((tlinfo.rev_account_code IS NULL) AND (X_rev_account_code IS NULL)))
        AND ((tlinfo.cash_account_code = x_cash_account_code) OR ((tlinfo.cash_account_code IS NULL) AND (X_cash_account_code IS NULL)))
	AND ((tlinfo.closed_ind = x_closed_ind) OR ((tlinfo.closed_ind IS NULL) AND (X_closed_ind IS NULL)))
	AND ((tlinfo.system_default = x_system_default) OR ((tlinfo.system_default IS NULL) AND (X_system_default IS NULL)))
	AND ((tlinfo.enroll_deposit_amount = x_enroll_deposit_amount) OR ((tlinfo.enroll_deposit_amount IS NULL) AND (X_enroll_deposit_amount IS NULL)))
	AND ((tlinfo.enroll_deposit_level = x_enroll_deposit_level) OR ((tlinfo.enroll_deposit_level IS NULL) AND (X_enroll_deposit_level IS NULL)))
	AND ((tlinfo.use_in_appl_self_srvc = x_use_in_appl_self_srvc) OR ((tlinfo.use_in_appl_self_srvc IS NULL) AND (X_use_in_appl_self_srvc IS NULL)))
	AND ((tlinfo.crt_rev_instr = x_crt_rev_instr) OR ((tlinfo.crt_rev_instr IS NULL) AND (x_crt_rev_instr IS NULL)))
	AND ((tlinfo.submit_instr = x_submit_instr) OR ((tlinfo.submit_instr IS NULL) AND (x_submit_instr IS NULL)))
	AND ((tlinfo.submit_err_instr = x_submit_err_instr) OR ((tlinfo.submit_err_instr IS NULL) AND (x_submit_err_instr IS NULL)))
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
    x_admission_application_type        IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_configurability_func_name         IN     VARCHAR2,
    x_application_fee_amount            IN     NUMBER,
    x_gl_rev_acct_ccid                  IN     NUMBER,
    x_gl_cash_acct_ccid                 IN     NUMBER,
    x_rev_account_code                  IN     VARCHAR2,
    x_cash_account_code                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_system_default                    IN     VARCHAR2,
    x_enroll_deposit_amount             IN     NUMBER,
    x_enroll_deposit_level              IN     VARCHAR2,
    x_use_in_appl_self_srvc		IN     VARCHAR2,
    x_crt_rev_instr                     IN     VARCHAR2,
    x_submit_instr                      IN     VARCHAR2,
    x_submit_err_instr                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  rghosh         04-oct-2002      added the PROCEDURE GET_FK_IGS_AD_PRCS_CAT
  ||                                  and added the column system default for
  ||                                  Bug # 2599457
  ||  rghosh         17-oct-2002      added the columns enroll_deposit_amount and
  ||                                  enroll_deposit_level columns for Bug
  ||                                  #2602077
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
      x_admission_application_type        => x_admission_application_type,
      x_description                       => x_description,
      x_admission_cat                     => x_admission_cat,
      x_s_admission_process_type          => x_s_admission_process_type,
      x_configurability_func_name         => x_configurability_func_name,
      x_application_fee_amount            => x_application_fee_amount,
      x_gl_rev_acct_ccid                  => x_gl_rev_acct_ccid,
      x_gl_cash_acct_ccid                 => x_gl_cash_acct_ccid,
      x_rev_account_code                  => x_rev_account_code,
      x_cash_account_code                 => x_cash_account_code,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_system_default                    => x_system_default,
      x_enroll_deposit_amount             => x_enroll_deposit_amount,
      x_enroll_deposit_level              => x_enroll_deposit_level,
      x_use_in_appl_self_srvc	          => x_use_in_appl_self_srvc,
      x_crt_rev_instr                     => x_crt_rev_instr,
      x_submit_instr                      => x_submit_instr,
      x_submit_err_instr	          => x_submit_err_instr
    );

    UPDATE igs_ad_ss_appl_typ
      SET
        description                       = new_references.description,
        admission_cat                     = new_references.admission_cat,
        s_admission_process_type          = new_references.s_admission_process_type,
        configurability_func_name         = new_references.configurability_func_name,
        application_fee_amount            = new_references.application_fee_amount,
        gl_rev_acct_ccid                  = new_references.gl_rev_acct_ccid,
        gl_cash_acct_ccid                 = new_references.gl_cash_acct_ccid,
        rev_account_code                  = new_references.rev_account_code,
        cash_account_code                 = new_references.cash_account_code,
	closed_ind                        = new_references.closed_ind,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
	system_default                    = new_references.system_default,
	enroll_deposit_amount             = new_references.enroll_deposit_amount,
        enroll_deposit_level              = new_references.enroll_deposit_level	,
	use_in_appl_self_srvc             = new_references.use_in_appl_self_srvc,
        crt_rev_instr                     = new_references.crt_rev_instr,
        submit_instr                      = new_references.submit_instr,
        submit_err_instr                  = new_references.submit_err_instr
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_admission_application_type               IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_configurability_func_name         IN     VARCHAR2,
    x_application_fee_amount            IN     NUMBER,
    x_gl_rev_acct_ccid                  IN     NUMBER,
    x_gl_cash_acct_ccid                 IN     NUMBER,
    x_rev_account_code                  IN     VARCHAR2,
    x_cash_account_code                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_system_default			IN     VARCHAR2,
    x_enroll_deposit_amount             IN     NUMBER,
    x_enroll_deposit_level              IN     VARCHAR2,
    x_use_in_appl_self_srvc             IN     VARCHAR2,
    x_crt_rev_instr                     IN     VARCHAR2,
    x_submit_instr                      IN     VARCHAR2,
    x_submit_err_instr                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  rghosh         04-oct-2002      added the PROCEDURE GET_FK_IGS_AD_PRCS_CAT
  ||                                  and added the column system default for
  ||                                  Bug # 2599457
  ||  rghosh         17-oct-2002      added the columns enroll_deposit_amount and
  ||                                  enroll_deposit_level columns for Bug
  ||                                  #2602077
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_ss_appl_typ
      WHERE    admission_application_type               = x_admission_application_type;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_admission_application_type,
        x_description,
        x_admission_cat,
        x_s_admission_process_type,
        x_configurability_func_name,
        x_application_fee_amount,
        x_gl_rev_acct_ccid,
        x_gl_cash_acct_ccid,
        x_rev_account_code,
        x_cash_account_code,
	x_closed_ind,
        x_mode,
	x_system_default,
	x_enroll_deposit_amount,
	x_enroll_deposit_level,
	x_use_in_appl_self_srvc,
        x_crt_rev_instr,
        x_submit_instr,
        x_submit_err_instr
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_admission_application_type,
      x_description,
      x_admission_cat,
      x_s_admission_process_type,
      x_configurability_func_name,
      x_application_fee_amount,
      x_gl_rev_acct_ccid,
      x_gl_cash_acct_ccid,
      x_rev_account_code,
      x_cash_account_code,
      x_closed_ind,
      x_mode,
      x_system_default,
      x_enroll_deposit_amount,
      x_enroll_deposit_level,
      x_use_in_appl_self_srvc,
      x_crt_rev_instr,
      x_submit_instr,
      x_submit_err_instr
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR c_del_at_ss_pgs (v_rowid VARCHAR2) IS
  SELECT admission_application_type
  FROM igs_ad_ss_appl_typ
  WHERE rowid=v_rowid;

  CURSOR c_del_sspgs(v_atyp VARCHAR2) IS
  SELECT ROWID
  FROM igs_ad_ss_appl_pgs
  WHERE admission_application_type=v_atyp;

  rec_c_del_sspgs c_del_sspgs%ROWTYPE;

  v_aat igs_ad_ss_appl_typ.admission_application_type%TYPE;
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    OPEN c_del_at_ss_pgs(x_rowid);
    FETCH c_del_at_ss_pgs INTO v_aat;
    CLOSE c_del_at_ss_pgs;

    FOR rec_c_del_sspgs IN c_del_sspgs(v_aat) LOOP
      igs_ad_ss_appl_pgs_pkg.delete_row(x_rowid => rec_c_del_sspgs.rowid);
    END LOOP;


    DELETE FROM igs_ad_ss_appl_typ
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

-- Called from Application Types form (IGSAD085)
-- Do not call from TBH
PROCEDURE check_child_existance_apc (
  p_admission_application_type IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2) is
BEGIN
  old_references.admission_application_type := p_admission_application_type;
  BEGIN
    check_child_existance;
  EXCEPTION
    WHEN OTHERS THEN
      p_message_name := 'IGS_AD_CNT_UPD_APC';
  END;
  old_references.admission_application_type := NULL;

END check_child_existance_apc;


END igs_ad_ss_appl_typ_pkg;

/
