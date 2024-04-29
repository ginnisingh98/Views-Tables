--------------------------------------------------------
--  DDL for Package Body IGS_FI_CR_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_CR_TYPES_PKG" AS
/* $Header: IGSSI88B.pls 120.1 2005/09/22 01:53:48 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_cr_types_all%ROWTYPE;
  new_references igs_fi_cr_types_all%ROWTYPE;
  PROCEDURE beforerowdelete;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER  ,
    x_credit_type_name                  IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_credit_class                      IN     VARCHAR2,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER  ,
    x_cr_gl_ccid                        IN     NUMBER  ,
    x_effective_start_date              IN     DATE    ,
    x_effective_end_date                IN     DATE    ,
    x_refund_allowed                    IN     VARCHAR2,
    x_payment_priority                  IN     NUMBER  ,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_title4_type_ind                   IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_payment_credit_type_id            IN     NUMBER  ,
    x_forfeiture_gl_ccid                IN     NUMBER  ,
    x_forfeiture_account_cd             IN     VARCHAR2,
    x_appl_hierarchy_id			IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr	     20-Sep-2005      Enh#4228665.Added field appl_hierarchy_id.
  ||  shtatiko       03-Dec-2002      Enh Bug 2584741, Added three new columns
  ||                                  payment_credit_type_id, forfeiture_gl_ccid
  ||                                  and forfeiture_account_cd
  ||  vvutukur       16-Sep-2002 Enh#2564643.Removed references to subaccount_id.Also removed
  ||                            DEFAULTing the parameters using DEFAULT keyword to avoid gscc warnings.
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_CR_TYPES_ALL
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
    new_references.credit_type_id                    := x_credit_type_id;
    new_references.credit_type_name                  := x_credit_type_name;
    new_references.description                       := x_description;
    new_references.credit_class                      := x_credit_class;
    new_references.dr_account_cd                     := x_dr_account_cd;
    new_references.cr_account_cd                     := x_cr_account_cd;
    new_references.dr_gl_ccid                        := x_dr_gl_ccid;
    new_references.cr_gl_ccid                        := x_cr_gl_ccid;
    new_references.effective_start_date              := x_effective_start_date;
    new_references.effective_end_date                := x_effective_end_date;
    new_references.refund_allowed                    := x_refund_allowed;
    new_references.payment_priority                  := x_payment_priority;
    new_references.attribute_category                := x_attribute_category;
    new_references.attribute1                        := x_attribute1;
    new_references.attribute2                        := x_attribute2;
    new_references.attribute3                        := x_attribute3;
    new_references.attribute4                        := x_attribute4;
    new_references.attribute5                        := x_attribute5;
    new_references.attribute6                        := x_attribute6;
    new_references.attribute7                        := x_attribute7;
    new_references.attribute8                        := x_attribute8;
    new_references.attribute9                        := x_attribute9;
    new_references.attribute10                       := x_attribute10;
    new_references.attribute11                       := x_attribute11;
    new_references.attribute12                       := x_attribute12;
    new_references.attribute13                       := x_attribute13;
    new_references.attribute14                       := x_attribute14;
    new_references.attribute15                       := x_attribute15;
    new_references.attribute16                       := x_attribute16;
    new_references.attribute17                       := x_attribute17;
    new_references.attribute18                       := x_attribute18;
    new_references.attribute19                       := x_attribute19;
    new_references.attribute20                       := x_attribute20;
    new_references.title4_type_ind                   := x_title4_type_ind;
    new_references.payment_credit_type_id            := x_payment_credit_type_id;
    new_references.forfeiture_gl_ccid                := x_forfeiture_gl_ccid;
    new_references.forfeiture_account_cd             := x_forfeiture_account_cd;
    new_references.appl_hierarchy_id	             := x_appl_hierarchy_id;


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

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS

--CHANGE HISTORY
--Who            When            What
--vvutukur    26-Aug-2003   Enh#3045007.Added Installment Payments credit class in order to restrict the creation
--                          of credit types with overlapping dates.
--vvutukur    09-Dec-2002   Enh#2584741.Added cursor cur_enr_deposit and corresponding validation not to allow
--                          the user to create two credit types with credit class 'Enrollment Deposit'.
--                          Also modified cursors cur_online_pay,cur_nca_meaning to check dates overlapping.Check
--                          introduced with the value specified by the user on the form instead of SYSDATE, for
--                          online payment and negative charge adjustment credit classes.Replaced igs_lookups_view
--                          with igs_lookup_values and selected active lookup codes only.
--vvutukur    16-Sep-2002   Enh#2564643.Removed references to subaccount_id from cursors cur_online_pay,
--                          cur_nca and from places where the cursors are used.Also removed DEFAULT
--                          in procedure parameters list to avoid gscc warnings.
--vvutukur      30-jan-2002     Modified cur_online_pay and added IF condition
--                              before opening that cursor for bug 2183291 as part of SFCR003.
--vvutukur      25-Jan-2002     Added code to error out NOCOPY when a Credit Type
--                              with credit class CHGADJ already exists
--                              for the subaccount for bug 2195715 as part of SFCR003.

  CURSOR cur_overlapping_u(cp_credit_type_id igs_fi_cr_types.credit_type_id%TYPE,
                           cp_credit_class   igs_fi_cr_types.credit_class%TYPE
                           ) IS
  SELECT 'x'
  FROM   igs_fi_cr_types
  WHERE  credit_class = cp_credit_class
  AND    credit_type_id <> cp_credit_type_id
  AND   (new_references.effective_start_date >= effective_start_date AND new_references.effective_start_date <= NVL(effective_end_date,new_references.effective_start_date)
  OR    ((new_references.effective_end_date >= effective_start_date OR (new_references.effective_end_date IS NULL)) AND new_references.effective_start_date <= effective_start_date));

  l_var  VARCHAR2(1);

  BEGIN

    --Validating if effective dates of credit type are not overlapping
      IF new_references.credit_class IN ('CHGADJ','ONLINE PAYMENT','ENRDEPOSIT','INSTALLMENT_PAYMENTS') THEN
        OPEN cur_overlapping_u(new_references.credit_type_id,new_references.credit_class);
        FETCH cur_overlapping_u INTO l_var;
        IF cur_overlapping_u%FOUND THEN
          CLOSE cur_overlapping_u;
          FND_MESSAGE.SET_NAME('IGS','IGS_FI_SUB_ACCT_CR_TYP_EXIST');
          FND_MESSAGE.SET_TOKEN('CRCLASS',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_CREDIT_CLASS',new_references.credit_class));
          IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
        CLOSE cur_overlapping_u;
      END IF;

  END BeforeRowInsertUpdate1;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.credit_type_name,
           new_references.effective_start_date
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr	   20-Sep-2005      Enh#4228665.Added check for parent in igs_fi_a_hierarchies_pkg
  ||  vvutukur     16-Sep-2002  Enh#2564643.Removed code referring subaccount_id which contains call to
  ||                            igs_fi_subaccts_pkg.get_pk_for_validation.
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

-- Added by sapanigr for Enhancement 4228665.
    IF ((old_references.appl_hierarchy_id = new_references.appl_hierarchy_id) OR
         (new_references.appl_hierarchy_id IS NULL)) THEN
      NULL;
    ELSE
      IF NOT igs_fi_a_hierarchies_pkg.Get_PK_For_Validation (
               new_references.appl_hierarchy_id
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.credit_class = new_references.credit_class)) OR
        ((new_references.credit_class IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'IGS_FI_CREDIT_CLASS',
          new_references.credit_class
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;

    -- Following is added by shtatiko as part of Deposits Build, Bug# 2584741
    -- Check if any account exists with code new_references.forfeiture_account_cd
    IF ((old_references.forfeiture_account_cd = new_references.forfeiture_account_cd) OR
         (new_references.forfeiture_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT igs_fi_acc_pkg.get_pk_for_validation (
               x_account_cd => new_references.forfeiture_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((old_references.payment_credit_type_id = new_references.payment_credit_type_id) OR
         (new_references.payment_credit_type_id IS NULL)) THEN
      NULL;
    ELSE
      IF NOT igs_fi_cr_types_pkg.get_pk_for_validation (
               x_credit_type_id => new_references.payment_credit_type_id
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sapanigr	21-SEP-2005	Enhc 4228665 Deleted igs_fi_a_hierarchies_pkg.get_fk_igs_fi_cr_types_all
  ||  (reverse chronological order - newest change first)
  */
  BEGIN



    igs_fi_bal_ex_c_typs_pkg.get_fk_igs_fi_cr_types_all (
      old_references.credit_type_id
    );

    igs_fi_credits_pkg.get_fk_igs_fi_cr_types_all (
      old_references.credit_type_id
    );

    -- Added by shtatiko as part of Enh Bug# 2584741, Deposits Build
    igs_fi_cr_types_pkg.get_fk_igs_fi_cr_types_all (
      old_references.credit_type_id
    );

  END check_child_existance;


  PROCEDURE GET_FK_IGS_FI_CR_TYPES_ALL(
    x_credit_type_id IN NUMBER
    ) AS
  /*
  ||  Created By : shtatiko
  ||  Created On : 04-DEC-2002
  ||  Purpose : Validates the foreign Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_CR_TYPES_ALL
      WHERE    credit_type_id = x_credit_type_id;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_CRTY_CRTY_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_rowid;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_CR_TYPES_ALL;


  FUNCTION get_pk_for_validation (
    x_credit_type_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi       10-Jun-2002       Bug 2404523. The row share table lock on the table igs_fi_cr_types_all
  ||                                  removed.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_cr_types_all
      WHERE    credit_type_id = x_credit_type_id ;


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
    x_credit_type_name                  IN     VARCHAR2,
    x_effective_start_date              IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_cr_types
      WHERE    credit_type_name = x_credit_type_name
      AND      ((effective_start_date = x_effective_start_date) OR (effective_start_date IS NULL AND x_effective_start_date IS NULL))
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER  ,
    x_credit_type_name                  IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_credit_class                      IN     VARCHAR2,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER  ,
    x_cr_gl_ccid                        IN     NUMBER  ,
    x_effective_start_date              IN     DATE    ,
    x_effective_end_date                IN     DATE    ,
    x_refund_allowed                    IN     VARCHAR2,
    x_payment_priority                  IN     NUMBER  ,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_title4_type_ind                   IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_payment_credit_type_id            IN     NUMBER  ,
    x_forfeiture_gl_ccid                IN     NUMBER  ,
    x_forfeiture_account_cd             IN     VARCHAR2,
    x_appl_hierarchy_id			IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr	     20-Sep-2005      Enh#4228665.Added field appl_hierarchy_id.
  ||  shtatiko        03-Dec-2002     Enh Bug 2584741, Added three new columns
  ||                                  payment_credit_type_id, forfeiture_gl_ccid
  ||                                  and forfeiture_account_cd
  ||  vvutukur   16-Sep-2002      Enh#2564643.Removed references to subaccount_id.ie., from parameters list
  ||                              and from call to set_column_values.Also removed DEFAULTing values
  ||                              in parameter list using DEFAULT keyword to avoid gscc warnings.
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_credit_type_id,
      x_credit_type_name,
      x_description,
      x_credit_class,
      x_dr_account_cd,
      x_cr_account_cd,
      x_dr_gl_ccid,
      x_cr_gl_ccid,
      x_effective_start_date,
      x_effective_end_date,
      x_refund_allowed,
      x_payment_priority,
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
      x_title4_type_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_payment_credit_type_id,
      x_forfeiture_gl_ccid,
      x_forfeiture_account_cd,
      x_appl_hierarchy_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1(p_inserting => FALSE,
                             p_updating  => FALSE,
                             p_deleting  => FALSE);
      IF ( get_pk_for_validation(
             new_references.credit_type_id
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
          BeforeRowInsertUpdate1(p_inserting => FALSE,
                                 p_updating  => FALSE,
                                 p_deleting  => FALSE);
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
      beforerowdelete;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
    -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1(p_inserting => FALSE,
                             p_updating  => FALSE,
                             p_deleting  => FALSE);
     IF ( get_pk_for_validation (
            new_references.credit_type_id
          )
        ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      BeforeRowInsertUpdate1(p_inserting => FALSE,
                             p_updating  => FALSE,
                             p_deleting  => FALSE);
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_credit_type_id                    IN OUT NOCOPY NUMBER,
    x_credit_type_name                  IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_credit_class                      IN     VARCHAR2,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_refund_allowed                    IN     VARCHAR2,
    x_payment_priority                  IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_title4_type_ind                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_payment_credit_type_id            IN     NUMBER,
    x_forfeiture_gl_ccid                IN     NUMBER,
    x_forfeiture_account_cd             IN     VARCHAR2,
    x_appl_hierarchy_id			IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr	     20-Sep-2005      Enh#4228665.Added field appl_hierarchy_id.
  ||  shtatiko        03-Dec-2002     Enh Bug 2584741, Added three new columns
  ||                                  payment_credit_type_id, forfeiture_gl_ccid
  ||                                  and forfeiture_account_cd
  ||  vvutukur      16-Sep-2002     Enh#2564643.Removed referenes to subaccount_id.ie., from parameters
  ||                                list and from call to before_dml and from insert statement.Also removed
  ||                                DEFAULT keyword in parameter list.
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_cr_types_all
      WHERE    credit_type_id                    = x_credit_type_id;

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

    SELECT    igs_fi_cr_types_s.NEXTVAL
    INTO      x_credit_type_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_credit_type_id                    => x_credit_type_id,
      x_credit_type_name                  => x_credit_type_name,
      x_description                       => x_description,
      x_credit_class                      => x_credit_class,
      x_dr_account_cd                     => x_dr_account_cd,
      x_cr_account_cd                     => x_cr_account_cd,
      x_dr_gl_ccid                        => x_dr_gl_ccid,
      x_cr_gl_ccid                        => x_cr_gl_ccid,
      x_effective_start_date              => x_effective_start_date,
      x_effective_end_date                => x_effective_end_date,
      x_refund_allowed                    => x_refund_allowed,
      x_payment_priority                  => x_payment_priority,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_title4_type_ind                   => x_title4_type_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_payment_credit_type_id            => x_payment_credit_type_id,
      x_forfeiture_gl_ccid                => x_forfeiture_gl_ccid,
      x_forfeiture_account_cd             => x_forfeiture_account_cd,
      x_appl_hierarchy_id		  => x_appl_hierarchy_id
    );

    INSERT INTO igs_fi_cr_types_all (
      credit_type_id,
      credit_type_name,
      description,
      credit_class,
      dr_account_cd,
      cr_account_cd,
      dr_gl_ccid,
      cr_gl_ccid,
      effective_start_date,
      effective_end_date,
      refund_allowed,
      org_id,
      payment_priority,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      title4_type_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      payment_credit_type_id,
      forfeiture_gl_ccid,
      forfeiture_acCount_cd,
      appl_hierarchy_id
    ) VALUES (
      new_references.credit_type_id,
      new_references.credit_type_name,
      new_references.description,
      new_references.credit_class,
      new_references.dr_account_cd,
      new_references.cr_account_cd,
      new_references.dr_gl_ccid,
      new_references.cr_gl_ccid,
      new_references.effective_start_date,
      new_references.effective_end_date,
      new_references.refund_allowed,
      new_references.org_id,
      new_references.payment_priority,
      new_references.attribute_category,
      new_references.attribute1,
      new_references.attribute2,
      new_references.attribute3,
      new_references.attribute4,
      new_references.attribute5,
      new_references.attribute6,
      new_references.attribute7,
      new_references.attribute8,
      new_references.attribute9,
      new_references.attribute10,
      new_references.attribute11,
      new_references.attribute12,
      new_references.attribute13,
      new_references.attribute14,
      new_references.attribute15,
      new_references.attribute16,
      new_references.attribute17,
      new_references.attribute18,
      new_references.attribute19,
      new_references.attribute20,
      new_references.title4_type_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.payment_credit_type_id,
      new_references.forfeiture_gl_ccid,
      new_references.forfeiture_account_cd,
      new_references.appl_hierarchy_id
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
    x_credit_type_id                    IN     NUMBER,
    x_credit_type_name                  IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_credit_class                      IN     VARCHAR2,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_refund_allowed                    IN     VARCHAR2,
    x_payment_priority                  IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_title4_type_ind                   IN     VARCHAR2,
    x_payment_credit_type_id            IN     NUMBER,
    x_forfeiture_gl_ccid                IN     NUMBER,
    x_forfeiture_account_cd             IN     VARCHAR2,
    x_appl_hierarchy_id			IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr	     20-Sep_2005      Enh#4228665.Added field appl_hierarchy_id.
  ||  shtatiko        03-Dec-2002     Enh Bug 2584741, Added three new columns
  ||                                  payment_credit_type_id, forfeiture_gl_ccid
  ||                                  and forfeiture_account_cd
  ||  vvutukur     16-Sep-2002    Enh#2564643.Removed references to subaccount_id.ie., from parameters list,
  ||                              from cursor c1 and from if condition.Also removed DEFAULT value
  ||                              for x_title4_type_ind from parameter list to avoid gscc warning.
  */
    CURSOR c1 IS
      SELECT
        credit_type_name,
        description,
        credit_class,
        dr_account_cd,
        cr_account_cd,
        dr_gl_ccid,
        cr_gl_ccid,
        effective_start_date,
        effective_end_date,
        refund_allowed,
        payment_priority,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        title4_type_ind,
        payment_credit_type_id,
        forfeiture_gl_ccid,
        forfeiture_account_cd,
        appl_hierarchy_id
      FROM  igs_fi_cr_types_all
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
        (tlinfo.credit_type_name = x_credit_type_name)
        AND ((tlinfo.description = x_description) OR ((tlinfo.description IS NULL) AND (X_description IS NULL)))
        AND (tlinfo.credit_class = x_credit_class)
        AND ((tlinfo.dr_account_cd = x_dr_account_cd) OR ((tlinfo.dr_account_cd IS NULL) AND (X_dr_account_cd IS NULL)))
        AND ((tlinfo.cr_account_cd = x_cr_account_cd) OR ((tlinfo.cr_account_cd IS NULL) AND (X_cr_account_cd IS NULL)))
        AND ((tlinfo.dr_gl_ccid = x_dr_gl_ccid) OR ((tlinfo.dr_gl_ccid IS NULL) AND (X_dr_gl_ccid IS NULL)))
        AND ((tlinfo.cr_gl_ccid = x_cr_gl_ccid) OR ((tlinfo.cr_gl_ccid IS NULL) AND (X_cr_gl_ccid IS NULL)))
        AND ((tlinfo.effective_start_date = x_effective_start_date) OR ((tlinfo.effective_start_date IS NULL) AND (X_effective_start_date IS NULL)))
        AND ((tlinfo.effective_end_date = x_effective_end_date) OR ((tlinfo.effective_end_date IS NULL) AND (X_effective_end_date IS NULL)))
        AND ((tlinfo.refund_allowed = x_refund_allowed) OR ((tlinfo.refund_allowed IS NULL) AND (X_refund_allowed IS NULL)))
        AND ((tlinfo.payment_priority = x_payment_priority) OR ((tlinfo.payment_priority IS NULL) AND (X_payment_priority IS NULL)))
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (X_attribute11 IS NULL)))
        AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (X_attribute12 IS NULL)))
        AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (X_attribute13 IS NULL)))
        AND ((tlinfo.attribute14 = x_attribute14) OR ((tlinfo.attribute14 IS NULL) AND (X_attribute14 IS NULL)))
        AND ((tlinfo.attribute15 = x_attribute15) OR ((tlinfo.attribute15 IS NULL) AND (X_attribute15 IS NULL)))
        AND ((tlinfo.attribute16 = x_attribute16) OR ((tlinfo.attribute16 IS NULL) AND (X_attribute16 IS NULL)))
        AND ((tlinfo.attribute17 = x_attribute17) OR ((tlinfo.attribute17 IS NULL) AND (X_attribute17 IS NULL)))
        AND ((tlinfo.attribute18 = x_attribute18) OR ((tlinfo.attribute18 IS NULL) AND (X_attribute18 IS NULL)))
        AND ((tlinfo.attribute19 = x_attribute19) OR ((tlinfo.attribute19 IS NULL) AND (X_attribute19 IS NULL)))
        AND ((tlinfo.attribute20 = x_attribute20) OR ((tlinfo.attribute20 IS NULL) AND (X_attribute20 IS NULL)))
        AND (tlinfo.title4_type_ind = x_title4_type_ind)
        AND ((tlinfo.payment_credit_type_id = x_payment_credit_type_id) OR ((tlinfo.payment_credit_type_id IS NULL) AND (x_payment_credit_type_id IS NULL)))
        AND ((tlinfo.forfeiture_gl_ccid = x_forfeiture_gl_ccid) OR ((tlinfo.forfeiture_gl_ccid IS NULL) AND (x_forfeiture_gl_ccid IS NULL)))
        AND ((tlinfo.forfeiture_account_cd = x_forfeiture_account_cd) OR ((tlinfo.forfeiture_account_cd IS NULL) AND (x_forfeiture_account_cd IS NULL)))
        AND ((tlinfo.appl_hierarchy_id = x_appl_hierarchy_id) OR ((tlinfo.appl_hierarchy_id IS NULL) AND (x_appl_hierarchy_id IS NULL)))
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
    x_credit_type_id                    IN     NUMBER,
    x_credit_type_name                  IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_credit_class                      IN     VARCHAR2,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_refund_allowed                    IN     VARCHAR2,
    x_payment_priority                  IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_title4_type_ind                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_payment_credit_type_id            IN     NUMBER,
    x_forfeiture_gl_ccid                IN     NUMBER,
    x_forfeiture_account_cd             IN     VARCHAR2,
    x_appl_hierarchy_id			IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr	     20-Sep-2005      Enh#4228665.Added field appl_hierarchy_id.
  ||  shtatiko        03-Dec-2002     Enh Bug 2584741, Added three new columns
  ||                                  payment_credit_type_id, forfeiture_gl_ccid
  ||                                  and forfeiture_account_cd
  ||  vvutukur     16-Sep-2002   Enh#2564643.Removed references to subaccount_id.ie., from parameters list
  ||                             and from call to before_dml and from update statement.Also removed
  ||                             DEFAULT value for x_title4_type_ind,x_mode to avoid gscc warnings.
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
      x_credit_type_id                    => x_credit_type_id,
      x_credit_type_name                  => x_credit_type_name,
      x_description                       => x_description,
      x_credit_class                      => x_credit_class,
      x_dr_account_cd                     => x_dr_account_cd,
      x_cr_account_cd                     => x_cr_account_cd,
      x_dr_gl_ccid                        => x_dr_gl_ccid,
      x_cr_gl_ccid                        => x_cr_gl_ccid,
      x_effective_start_date              => x_effective_start_date,
      x_effective_end_date                => x_effective_end_date,
      x_refund_allowed                    => x_refund_allowed,
      x_payment_priority                  => x_payment_priority,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_title4_type_ind                   => x_title4_type_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_payment_credit_type_id            => x_payment_credit_type_id,
      x_forfeiture_gl_ccid                => x_forfeiture_gl_ccid,
      x_forfeiture_account_cd             => x_forfeiture_account_cd,
      x_appl_hierarchy_id		  => x_appl_hierarchy_id
    );

    UPDATE igs_fi_cr_types_all
      SET
        credit_type_name                  = new_references.credit_type_name,
        description                       = new_references.description,
        credit_class                      = new_references.credit_class,
        dr_account_cd                     = new_references.dr_account_cd,
        cr_account_cd                     = new_references.cr_account_cd,
        dr_gl_ccid                        = new_references.dr_gl_ccid,
        cr_gl_ccid                        = new_references.cr_gl_ccid,
        effective_start_date              = new_references.effective_start_date,
        effective_end_date                = new_references.effective_end_date,
        refund_allowed                    = new_references.refund_allowed,
        payment_priority                  = new_references.payment_priority,
        attribute_category                = new_references.attribute_category,
        attribute1                        = new_references.attribute1,
        attribute2                        = new_references.attribute2,
        attribute3                        = new_references.attribute3,
        attribute4                        = new_references.attribute4,
        attribute5                        = new_references.attribute5,
        attribute6                        = new_references.attribute6,
        attribute7                        = new_references.attribute7,
        attribute8                        = new_references.attribute8,
        attribute9                        = new_references.attribute9,
        attribute10                       = new_references.attribute10,
        attribute11                       = new_references.attribute11,
        attribute12                       = new_references.attribute12,
        attribute13                       = new_references.attribute13,
        attribute14                       = new_references.attribute14,
        attribute15                       = new_references.attribute15,
        attribute16                       = new_references.attribute16,
        attribute17                       = new_references.attribute17,
        attribute18                       = new_references.attribute18,
        attribute19                       = new_references.attribute19,
        attribute20                       = new_references.attribute20,
        title4_type_ind                   = new_references.title4_type_ind,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        payment_credit_type_id            = x_payment_credit_type_id,
        forfeiture_gl_ccid                = x_forfeiture_gl_ccid,
        forfeiture_account_cd             = x_forfeiture_account_cd,
	appl_hierarchy_id		  = x_appl_hierarchy_id
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_credit_type_id                    IN OUT NOCOPY NUMBER,
    x_credit_type_name                  IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_credit_class                      IN     VARCHAR2,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_refund_allowed                    IN     VARCHAR2,
    x_payment_priority                  IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_title4_type_ind                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_payment_credit_type_id            IN     NUMBER,
    x_forfeiture_gl_ccid                IN     NUMBER,
    x_forfeiture_account_cd             IN     VARCHAR2,
    x_appl_hierarchy_id			IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sapanigr	     20-Sep-2005      Enh#4228665.Added field appl_hierarchy_id.
  ||  shtatiko        03-Dec-2002     Enh Bug 2584741, Added three new columns
  ||                                  payment_credit_type_id, forfeiture_gl_ccid
  ||                                  and forfeiture_account_cd
  ||  vvutukur   16-Sep-2002    Enh#2564643.Removed references to subaccount_id.ie.,from parameters,
  ||                            from calls to insert_row and update_row.Also removed DEFAULT value
  ||                            for x_title4_type_ind,x_mode in parameter list to avoid gscc warnings.
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_cr_types_all
      WHERE    credit_type_id                    = x_credit_type_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_credit_type_id,
        x_credit_type_name,
        x_description,
        x_credit_class,
        x_dr_account_cd,
        x_cr_account_cd,
        x_dr_gl_ccid,
        x_cr_gl_ccid,
        x_effective_start_date,
        x_effective_end_date,
        x_refund_allowed,
        x_payment_priority,
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
        x_title4_type_ind,
        x_mode ,
        x_payment_credit_type_id,
        x_forfeiture_gl_ccid,
        x_forfeiture_account_cd,
	x_appl_hierarchy_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_credit_type_id,
      x_credit_type_name,
      x_description,
      x_credit_class,
      x_dr_account_cd,
      x_cr_account_cd,
      x_dr_gl_ccid,
      x_cr_gl_ccid,
      x_effective_start_date,
      x_effective_end_date,
      x_refund_allowed,
      x_payment_priority,
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
      x_title4_type_ind,
      x_mode ,
      x_payment_credit_type_id,
      x_forfeiture_gl_ccid,
      x_forfeiture_account_cd,
      x_appl_hierarchy_id
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

    DELETE FROM igs_fi_cr_types_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

  PROCEDURE beforerowdelete AS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle India
  --Date created: 12-Jun-2002
  --
  --Purpose: Only planned Calendar Instances are allowed for deletion
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  BEGIN
    -- while inserting records into credits table, an explicit lock was place on the IGS_FI_CR_TYPES table
    -- As a result locking contention occured when simultaneous transactions on the credit table were
    -- carried out. Hence the row share table lock on the IGS_FI_CR_TYPES table was removed from get_pk_for_validation.
    -- Through the forms, deletion of the IGS_FI_CR_TYPES records are not happening. To ensure that none of the
    -- other process which manipulates the records of the IGS_FI_CR_TYPES should not delete any of the records present
    -- in the table, explicitly the logic has been coded to prevent the deletion of records.
    -- done as part of bug 2404523
    FND_MESSAGE.SET_NAME('IGS','IGS_FI_DEL_NOT_ALLWD');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END beforerowdelete;

END igs_fi_cr_types_pkg;

/
