--------------------------------------------------------
--  DDL for Package Body IGS_FI_IMPCHGS_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_IMPCHGS_LINES_PKG" AS
/* $Header: IGSSI85B.pls 115.11 2002/11/29 03:55:51 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_impchgs_lines%ROWTYPE;
  new_references igs_fi_impchgs_lines%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2  ,
    x_rowid                             IN     VARCHAR2  ,
    x_impchg_lines_id                   IN     NUMBER    ,
    x_import_charges_id                 IN     NUMBER    ,
    x_transaction_dt                    IN     DATE      ,
    x_effective_dt                      IN     DATE      ,
    x_transaction_amount                IN     NUMBER    ,
    x_currency_cd                       IN     VARCHAR2  ,
    x_exchange_rate                     IN     NUMBER    ,
    x_comments                          IN     VARCHAR2  ,
    x_ancillary_attribute1              IN     VARCHAR2    ,
    x_ancillary_attribute2              IN     VARCHAR2    ,
    x_ancillary_attribute3              IN     VARCHAR2    ,
    x_ancillary_attribute4              IN     VARCHAR2    ,
    x_ancillary_attribute5              IN     VARCHAR2    ,
    x_ancillary_attribute6              IN     VARCHAR2    ,
    x_ancillary_attribute7              IN     VARCHAR2    ,
    x_ancillary_attribute8              IN     VARCHAR2    ,
    x_ancillary_attribute9              IN     VARCHAR2    ,
    x_ancillary_attribute10             IN     VARCHAR2    ,
    x_ancillary_attribute11             IN     VARCHAR2    ,
    x_ancillary_attribute12             IN     VARCHAR2    ,
    x_ancillary_attribute13             IN     VARCHAR2    ,
    x_ancillary_attribute14             IN     VARCHAR2    ,
    x_ancillary_attribute15             IN     VARCHAR2    ,
    x_attribute_category                IN     VARCHAR2    ,
    x_attribute1                        IN     VARCHAR2    ,
    x_attribute2                        IN     VARCHAR2    ,
    x_attribute3                        IN     VARCHAR2    ,
    x_attribute4                        IN     VARCHAR2    ,
    x_attribute5                        IN     VARCHAR2    ,
    x_attribute6                        IN     VARCHAR2    ,
    x_attribute7                        IN     VARCHAR2    ,
    x_attribute8                        IN     VARCHAR2    ,
    x_attribute9                        IN     VARCHAR2    ,
    x_attribute10                       IN     VARCHAR2    ,
    x_attribute11                       IN     VARCHAR2    ,
    x_attribute12                       IN     VARCHAR2    ,
    x_attribute13                       IN     VARCHAR2    ,
    x_attribute14                       IN     VARCHAR2    ,
    x_attribute15                       IN     VARCHAR2    ,
    x_attribute16                       IN     VARCHAR2    ,
    x_attribute17                       IN     VARCHAR2    ,
    x_attribute18                       IN     VARCHAR2    ,
    x_attribute19                       IN     VARCHAR2    ,
    x_attribute20                       IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi   06-Nov-2002           Enh. Bug 2584986. Removed columns as mentioned
  ||                                  in GL interface TD
  ||  vvutukur        24-Jul-2002     Bug#2425767.Removed references to chg_rate,chg_elements.
  ||  agairola        04-Jun-2002     For bug 2395663, added EXT_ columns for the DFF for External Charges
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_IMPCHGS_LINES
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
    new_references.impchg_lines_id                   := x_impchg_lines_id;
    new_references.import_charges_id                 := x_import_charges_id;
    new_references.transaction_dt                    := x_transaction_dt;
    new_references.effective_dt                      := x_effective_dt;
    new_references.transaction_amount                := x_transaction_amount;
    new_references.currency_cd                       := x_currency_cd;
    new_references.exchange_rate                     := x_exchange_rate;
    new_references.comments                          := x_comments;
    new_references.ancillary_attribute1              := x_ancillary_attribute1;
    new_references.ancillary_attribute2              := x_ancillary_attribute2;
    new_references.ancillary_attribute3              := x_ancillary_attribute3;
    new_references.ancillary_attribute4              := x_ancillary_attribute4;
    new_references.ancillary_attribute5              := x_ancillary_attribute5;
    new_references.ancillary_attribute6              := x_ancillary_attribute6;
    new_references.ancillary_attribute7              := x_ancillary_attribute7;
    new_references.ancillary_attribute8              := x_ancillary_attribute8;
    new_references.ancillary_attribute9              := x_ancillary_attribute9;
    new_references.ancillary_attribute10             := x_ancillary_attribute10;
    new_references.ancillary_attribute11             := x_ancillary_attribute11;
    new_references.ancillary_attribute12             := x_ancillary_attribute12;
    new_references.ancillary_attribute13             := x_ancillary_attribute13;
    new_references.ancillary_attribute14             := x_ancillary_attribute14;
    new_references.ancillary_attribute15             := x_ancillary_attribute15;
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
  ||  Created On : 09-APR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.import_charges_id = new_references.import_charges_id)) OR
        ((new_references.import_charges_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_imp_chgs_pkg.get_pk_for_validation (
                new_references.import_charges_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_impchg_lines_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_impchgs_lines
      WHERE    impchg_lines_id = x_impchg_lines_id
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

  PROCEDURE get_fk_igs_fi_imp_chgs_all (
    x_import_charges_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_impchgs_lines
      WHERE   ((import_charges_id = x_import_charges_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FIML_FIMP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_imp_chgs_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_impchg_lines_id                   IN     NUMBER      ,
    x_import_charges_id                 IN     NUMBER      ,
    x_transaction_dt                    IN     DATE        ,
    x_effective_dt                      IN     DATE        ,
    x_transaction_amount                IN     NUMBER      ,
    x_currency_cd                       IN     VARCHAR2    ,
    x_exchange_rate                     IN     NUMBER      ,
    x_comments                          IN     VARCHAR2    ,
    x_ancillary_attribute1              IN     VARCHAR2    ,
    x_ancillary_attribute2              IN     VARCHAR2    ,
    x_ancillary_attribute3              IN     VARCHAR2    ,
    x_ancillary_attribute4              IN     VARCHAR2    ,
    x_ancillary_attribute5              IN     VARCHAR2    ,
    x_ancillary_attribute6              IN     VARCHAR2    ,
    x_ancillary_attribute7              IN     VARCHAR2    ,
    x_ancillary_attribute8              IN     VARCHAR2    ,
    x_ancillary_attribute9              IN     VARCHAR2    ,
    x_ancillary_attribute10             IN     VARCHAR2    ,
    x_ancillary_attribute11             IN     VARCHAR2    ,
    x_ancillary_attribute12             IN     VARCHAR2    ,
    x_ancillary_attribute13             IN     VARCHAR2    ,
    x_ancillary_attribute14             IN     VARCHAR2    ,
    x_ancillary_attribute15             IN     VARCHAR2    ,
    x_attribute_category                IN     VARCHAR2    ,
    x_attribute1                        IN     VARCHAR2    ,
    x_attribute2                        IN     VARCHAR2    ,
    x_attribute3                        IN     VARCHAR2    ,
    x_attribute4                        IN     VARCHAR2    ,
    x_attribute5                        IN     VARCHAR2    ,
    x_attribute6                        IN     VARCHAR2    ,
    x_attribute7                        IN     VARCHAR2    ,
    x_attribute8                        IN     VARCHAR2    ,
    x_attribute9                        IN     VARCHAR2    ,
    x_attribute10                       IN     VARCHAR2    ,
    x_attribute11                       IN     VARCHAR2    ,
    x_attribute12                       IN     VARCHAR2    ,
    x_attribute13                       IN     VARCHAR2    ,
    x_attribute14                       IN     VARCHAR2    ,
    x_attribute15                       IN     VARCHAR2    ,
    x_attribute16                       IN     VARCHAR2    ,
    x_attribute17                       IN     VARCHAR2    ,
    x_attribute18                       IN     VARCHAR2    ,
    x_attribute19                       IN     VARCHAR2    ,
    x_attribute20                       IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi   06-Nov-2002           Enh. Bug 2584986. Removed columns as mentioned
  ||                                  in GL interface TD. removed DEFAULT clauses
  ||  vvutukur        24-Jul-2002     Bug#2425767.Removed references to obsoleted columns chg_rate,chg_elements
  ||                                  from call to set_column_values.
  ||  agairola        04-Jun-2002     For bug 2395663, added EXT_ columns for the DFF for External Charges
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_impchg_lines_id,
      x_import_charges_id,
      x_transaction_dt,
      x_effective_dt,
      x_transaction_amount,
      x_currency_cd,
      x_exchange_rate,
      x_comments,
      x_ancillary_attribute1,
      x_ancillary_attribute2,
      x_ancillary_attribute3,
      x_ancillary_attribute4,
      x_ancillary_attribute5,
      x_ancillary_attribute6,
      x_ancillary_attribute7,
      x_ancillary_attribute8,
      x_ancillary_attribute9,
      x_ancillary_attribute10,
      x_ancillary_attribute11,
      x_ancillary_attribute12,
      x_ancillary_attribute13,
      x_ancillary_attribute14,
      x_ancillary_attribute15,
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
      IF ( get_pk_for_validation(
             new_references.impchg_lines_id
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
             new_references.impchg_lines_id
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
    x_impchg_lines_id                   IN OUT NOCOPY NUMBER,
    x_import_charges_id                 IN     NUMBER,
    x_transaction_dt                    IN     DATE,
    x_effective_dt                      IN     DATE,
    x_transaction_amount                IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
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
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When           What
  || smadathi       06-Nov-2002      Enh. Bug 2584986. Removed columns as mentioned
  ||                                 in GL interface TD
  ||  vvutukur        24-Jul-2002   Bug#2425767.Removed references to obsoleted columns chg_rate,chg_elements
  ||                                (from the call to before_dml and from insert statement).
  ||  agairola        04-Jun-2002     For bug 2395663, added EXT_ columns for the DFF for External Charges
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_impchgs_lines
      WHERE    impchg_lines_id                   = x_impchg_lines_id;

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

   SELECT igs_fi_impchgs_lines_s.NEXTVAL INTO x_impchg_lines_id FROM DUAL;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_impchg_lines_id                   => x_impchg_lines_id,
      x_import_charges_id                 => x_import_charges_id,
      x_transaction_dt                    => x_transaction_dt,
      x_effective_dt                      => x_effective_dt,
      x_transaction_amount                => x_transaction_amount,
      x_currency_cd                       => x_currency_cd,
      x_exchange_rate                     => x_exchange_rate,
      x_comments                          => x_comments,
      x_ancillary_attribute1              => x_ancillary_attribute1,
      x_ancillary_attribute2              => x_ancillary_attribute2,
      x_ancillary_attribute3              => x_ancillary_attribute3,
      x_ancillary_attribute4              => x_ancillary_attribute4,
      x_ancillary_attribute5              => x_ancillary_attribute5,
      x_ancillary_attribute6              => x_ancillary_attribute6,
      x_ancillary_attribute7              => x_ancillary_attribute7,
      x_ancillary_attribute8              => x_ancillary_attribute8,
      x_ancillary_attribute9              => x_ancillary_attribute9,
      x_ancillary_attribute10             => x_ancillary_attribute10,
      x_ancillary_attribute11             => x_ancillary_attribute11,
      x_ancillary_attribute12             => x_ancillary_attribute12,
      x_ancillary_attribute13             => x_ancillary_attribute13,
      x_ancillary_attribute14             => x_ancillary_attribute14,
      x_ancillary_attribute15             => x_ancillary_attribute15,
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
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_impchgs_lines (
      impchg_lines_id,
      import_charges_id,
      transaction_dt,
      effective_dt,
      transaction_amount,
      currency_cd,
      exchange_rate,
      comments,
      ancillary_attribute1,
      ancillary_attribute2,
      ancillary_attribute3,
      ancillary_attribute4,
      ancillary_attribute5,
      ancillary_attribute6,
      ancillary_attribute7,
      ancillary_attribute8,
      ancillary_attribute9,
      ancillary_attribute10,
      ancillary_attribute11,
      ancillary_attribute12,
      ancillary_attribute13,
      ancillary_attribute14,
      ancillary_attribute15,
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
      new_references.impchg_lines_id,
      new_references.import_charges_id,
      new_references.transaction_dt,
      new_references.effective_dt,
      new_references.transaction_amount,
      new_references.currency_cd,
      new_references.exchange_rate,
      new_references.comments,
      new_references.ancillary_attribute1,
      new_references.ancillary_attribute2,
      new_references.ancillary_attribute3,
      new_references.ancillary_attribute4,
      new_references.ancillary_attribute5,
      new_references.ancillary_attribute6,
      new_references.ancillary_attribute7,
      new_references.ancillary_attribute8,
      new_references.ancillary_attribute9,
      new_references.ancillary_attribute10,
      new_references.ancillary_attribute11,
      new_references.ancillary_attribute12,
      new_references.ancillary_attribute13,
      new_references.ancillary_attribute14,
      new_references.ancillary_attribute15,
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

    l_rowid := NULL;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_impchg_lines_id                   IN     NUMBER,
    x_import_charges_id                 IN     NUMBER,
    x_transaction_dt                    IN     DATE,
    x_effective_dt                      IN     DATE,
    x_transaction_amount                IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
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
    x_attribute20                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || smadathi   06-Nov-2002  Enh. Bug 2584986. Removed columns as mentioned
  ||                         in GL interface TD
  ||  vvutukur        24-Jul-2002   Bug#2425767.Removed references to obsoleted columns chg_rate,chg_elements
  ||                                (from cursor c1 and from if condition).
  ||  agairola        04-Jun-2002     For bug 2395663, added EXT_ columns for the DFF for External Charges
  */
    CURSOR c1 IS
      SELECT
        import_charges_id,
        transaction_dt,
        effective_dt,
        transaction_amount,
        currency_cd,
        exchange_rate,
        comments,
        ancillary_attribute1,
        ancillary_attribute2,
        ancillary_attribute3,
        ancillary_attribute4,
        ancillary_attribute5,
        ancillary_attribute6,
        ancillary_attribute7,
        ancillary_attribute8,
        ancillary_attribute9,
        ancillary_attribute10,
        ancillary_attribute11,
        ancillary_attribute12,
        ancillary_attribute13,
        ancillary_attribute14,
        ancillary_attribute15,
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
        attribute20
      FROM  igs_fi_impchgs_lines
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
        (tlinfo.import_charges_id = x_import_charges_id)
        AND (tlinfo.transaction_dt = x_transaction_dt)
        AND ((tlinfo.effective_dt = x_effective_dt) OR ((tlinfo.effective_dt IS NULL) AND (X_effective_dt IS NULL)))
        AND (tlinfo.transaction_amount = x_transaction_amount)
        AND ((tlinfo.currency_cd = x_currency_cd) OR ((tlinfo.currency_cd IS NULL) AND (X_currency_cd IS NULL)))
        AND ((tlinfo.exchange_rate = x_exchange_rate) OR ((tlinfo.exchange_rate IS NULL) AND (X_exchange_rate IS NULL)))
        AND ((tlinfo.comments = x_comments) OR ((tlinfo.comments IS NULL) AND (X_comments IS NULL)))
        AND ((tlinfo.ancillary_attribute1 = x_ancillary_attribute1) OR ((tlinfo.ancillary_attribute1 IS NULL) AND (X_ancillary_attribute1 IS NULL)))
        AND ((tlinfo.ancillary_attribute2 = x_ancillary_attribute2) OR ((tlinfo.ancillary_attribute2 IS NULL) AND (X_ancillary_attribute2 IS NULL)))
        AND ((tlinfo.ancillary_attribute3 = x_ancillary_attribute3) OR ((tlinfo.ancillary_attribute3 IS NULL) AND (X_ancillary_attribute3 IS NULL)))
        AND ((tlinfo.ancillary_attribute4 = x_ancillary_attribute4) OR ((tlinfo.ancillary_attribute4 IS NULL) AND (X_ancillary_attribute4 IS NULL)))
        AND ((tlinfo.ancillary_attribute5 = x_ancillary_attribute5) OR ((tlinfo.ancillary_attribute5 IS NULL) AND (X_ancillary_attribute5 IS NULL)))
        AND ((tlinfo.ancillary_attribute6 = x_ancillary_attribute6) OR ((tlinfo.ancillary_attribute6 IS NULL) AND (X_ancillary_attribute6 IS NULL)))
        AND ((tlinfo.ancillary_attribute7 = x_ancillary_attribute7) OR ((tlinfo.ancillary_attribute7 IS NULL) AND (X_ancillary_attribute7 IS NULL)))
        AND ((tlinfo.ancillary_attribute8 = x_ancillary_attribute8) OR ((tlinfo.ancillary_attribute8 IS NULL) AND (X_ancillary_attribute8 IS NULL)))
        AND ((tlinfo.ancillary_attribute9 = x_ancillary_attribute9) OR ((tlinfo.ancillary_attribute9 IS NULL) AND (X_ancillary_attribute9 IS NULL)))
        AND ((tlinfo.ancillary_attribute10 = x_ancillary_attribute10) OR ((tlinfo.ancillary_attribute10 IS NULL) AND (X_ancillary_attribute10 IS NULL)))
        AND ((tlinfo.ancillary_attribute11 = x_ancillary_attribute11) OR ((tlinfo.ancillary_attribute11 IS NULL) AND (X_ancillary_attribute11 IS NULL)))
        AND ((tlinfo.ancillary_attribute12 = x_ancillary_attribute12) OR ((tlinfo.ancillary_attribute12 IS NULL) AND (X_ancillary_attribute12 IS NULL)))
        AND ((tlinfo.ancillary_attribute13 = x_ancillary_attribute13) OR ((tlinfo.ancillary_attribute13 IS NULL) AND (X_ancillary_attribute13 IS NULL)))
        AND ((tlinfo.ancillary_attribute14 = x_ancillary_attribute14) OR ((tlinfo.ancillary_attribute14 IS NULL) AND (X_ancillary_attribute14 IS NULL)))
        AND ((tlinfo.ancillary_attribute15 = x_ancillary_attribute15) OR ((tlinfo.ancillary_attribute15 IS NULL) AND (X_ancillary_attribute15 IS NULL)))
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
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    l_rowid := NULL;
    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_impchg_lines_id                   IN     NUMBER,
    x_import_charges_id                 IN     NUMBER,
    x_transaction_dt                    IN     DATE,
    x_effective_dt                      IN     DATE,
    x_transaction_amount                IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
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
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi   06-Nov-2002  Enh. Bug 2584986. Removed columns as mentioned
  ||                         in GL interface TD
  ||  vvutukur        24-Jul-2002   Bug#2425767.Removed references to obsoleted columns chg_rate,chg_elements
  ||                                (from the call to before_dml and from update statement).
  ||  agairola        04-Jun-2002     For bug 2395663, added EXT_ columns for the DFF for External Charges
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
      x_impchg_lines_id                   => x_impchg_lines_id,
      x_import_charges_id                 => x_import_charges_id,
      x_transaction_dt                    => x_transaction_dt,
      x_effective_dt                      => x_effective_dt,
      x_transaction_amount                => x_transaction_amount,
      x_currency_cd                       => x_currency_cd,
      x_exchange_rate                     => x_exchange_rate,
      x_comments                          => x_comments,
      x_ancillary_attribute1              => x_ancillary_attribute1,
      x_ancillary_attribute2              => x_ancillary_attribute2,
      x_ancillary_attribute3              => x_ancillary_attribute3,
      x_ancillary_attribute4              => x_ancillary_attribute4,
      x_ancillary_attribute5              => x_ancillary_attribute5,
      x_ancillary_attribute6              => x_ancillary_attribute6,
      x_ancillary_attribute7              => x_ancillary_attribute7,
      x_ancillary_attribute8              => x_ancillary_attribute8,
      x_ancillary_attribute9              => x_ancillary_attribute9,
      x_ancillary_attribute10             => x_ancillary_attribute10,
      x_ancillary_attribute11             => x_ancillary_attribute11,
      x_ancillary_attribute12             => x_ancillary_attribute12,
      x_ancillary_attribute13             => x_ancillary_attribute13,
      x_ancillary_attribute14             => x_ancillary_attribute14,
      x_ancillary_attribute15             => x_ancillary_attribute15,
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

    UPDATE igs_fi_impchgs_lines
      SET
        import_charges_id                 = new_references.import_charges_id,
        transaction_dt                    = new_references.transaction_dt,
        effective_dt                      = new_references.effective_dt,
        transaction_amount                = new_references.transaction_amount,
        currency_cd                       = new_references.currency_cd,
        exchange_rate                     = new_references.exchange_rate,
        comments                          = new_references.comments,
        ancillary_attribute1              = new_references.ancillary_attribute1,
        ancillary_attribute2              = new_references.ancillary_attribute2,
        ancillary_attribute3              = new_references.ancillary_attribute3,
        ancillary_attribute4              = new_references.ancillary_attribute4,
        ancillary_attribute5              = new_references.ancillary_attribute5,
        ancillary_attribute6              = new_references.ancillary_attribute6,
        ancillary_attribute7              = new_references.ancillary_attribute7,
        ancillary_attribute8              = new_references.ancillary_attribute8,
        ancillary_attribute9              = new_references.ancillary_attribute9,
        ancillary_attribute10             = new_references.ancillary_attribute10,
        ancillary_attribute11             = new_references.ancillary_attribute11,
        ancillary_attribute12             = new_references.ancillary_attribute12,
        ancillary_attribute13             = new_references.ancillary_attribute13,
        ancillary_attribute14             = new_references.ancillary_attribute14,
        ancillary_attribute15             = new_references.ancillary_attribute15,
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

    l_rowid := NULL;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_impchg_lines_id                   IN OUT NOCOPY NUMBER,
    x_import_charges_id                 IN     NUMBER,
    x_transaction_dt                    IN     DATE,
    x_effective_dt                      IN     DATE,
    x_transaction_amount                IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_ancillary_attribute1              IN     VARCHAR2,
    x_ancillary_attribute2              IN     VARCHAR2,
    x_ancillary_attribute3              IN     VARCHAR2,
    x_ancillary_attribute4              IN     VARCHAR2,
    x_ancillary_attribute5              IN     VARCHAR2,
    x_ancillary_attribute6              IN     VARCHAR2,
    x_ancillary_attribute7              IN     VARCHAR2,
    x_ancillary_attribute8              IN     VARCHAR2,
    x_ancillary_attribute9              IN     VARCHAR2,
    x_ancillary_attribute10             IN     VARCHAR2,
    x_ancillary_attribute11             IN     VARCHAR2,
    x_ancillary_attribute12             IN     VARCHAR2,
    x_ancillary_attribute13             IN     VARCHAR2,
    x_ancillary_attribute14             IN     VARCHAR2,
    x_ancillary_attribute15             IN     VARCHAR2,
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
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi   06-Nov-2002  Enh. Bug 2584986. Removed columns as mentioned
  ||                         in GL interface TD
  ||  vvutukur        24-Jul-2002   Bug#2425767.Removed references to obsoleted columns chg_rate,chg_elements
  ||                                (from the calls to insert_row and update_row procedures).
  ||  agairola        04-Jun-2002     For bug 2395663, added EXT_ columns for the DFF for External Charges
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_impchgs_lines
      WHERE    impchg_lines_id                   = x_impchg_lines_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_impchg_lines_id,
        x_import_charges_id,
        x_transaction_dt,
        x_effective_dt,
        x_transaction_amount,
        x_currency_cd,
        x_exchange_rate,
        x_comments,
        x_ancillary_attribute1,
        x_ancillary_attribute2,
        x_ancillary_attribute3,
        x_ancillary_attribute4,
        x_ancillary_attribute5,
        x_ancillary_attribute6,
        x_ancillary_attribute7,
        x_ancillary_attribute8,
        x_ancillary_attribute9,
        x_ancillary_attribute10,
        x_ancillary_attribute11,
        x_ancillary_attribute12,
        x_ancillary_attribute13,
        x_ancillary_attribute14,
        x_ancillary_attribute15,
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
      x_impchg_lines_id,
      x_import_charges_id,
      x_transaction_dt,
      x_effective_dt,
      x_transaction_amount,
      x_currency_cd,
      x_exchange_rate,
      x_comments,
      x_ancillary_attribute1,
      x_ancillary_attribute2,
      x_ancillary_attribute3,
      x_ancillary_attribute4,
      x_ancillary_attribute5,
      x_ancillary_attribute6,
      x_ancillary_attribute7,
      x_ancillary_attribute8,
      x_ancillary_attribute9,
      x_ancillary_attribute10,
      x_ancillary_attribute11,
      x_ancillary_attribute12,
      x_ancillary_attribute13,
      x_ancillary_attribute14,
      x_ancillary_attribute15,
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

    l_rowid := NULL;

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 09-APR-2001
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

    DELETE FROM igs_fi_impchgs_lines
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END delete_row;


END igs_fi_impchgs_lines_pkg;

/
