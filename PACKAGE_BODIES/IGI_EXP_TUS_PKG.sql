--------------------------------------------------------
--  DDL for Package Body IGI_EXP_TUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_TUS_PKG" AS
/* $Header: igiexpzb.pls 120.5.12000000.1 2007/09/13 04:25:30 mbremkum ship $ */

--following variables added for bug 3199481: fnd logging changes: sdixit
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

  l_rowid VARCHAR2(25);
  old_references igi_exp_tus_all%ROWTYPE;
  new_references igi_exp_tus_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_tu_id                             IN     NUMBER      ,
    x_tu_type_header_id                 IN     NUMBER      ,
    x_tu_order_number                   IN     VARCHAR2    ,
    x_tu_legal_number                   IN     VARCHAR2    ,
    x_tu_description                    IN     VARCHAR2    ,
    x_tu_status                         IN     VARCHAR2    ,
    x_tu_currency_code                  IN     VARCHAR2    ,
    x_tu_amount                         IN     NUMBER      ,
    x_apprv_profile_id                  IN     NUMBER      ,
    x_next_approver_user_id             IN     NUMBER      ,
    x_tu_fiscal_year                    IN     NUMBER      ,
    x_tu_by_user_id                     IN     NUMBER      ,
    x_tu_date                           IN     DATE        ,
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
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 16-APR-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igi_exp_tus_all
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
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpzb.IGI_EXP_TUS_PKG.set_column_values',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.tu_id                             := x_tu_id;
    new_references.tu_type_header_id                 := x_tu_type_header_id;
    new_references.tu_order_number                   := x_tu_order_number;
    new_references.tu_legal_number                   := x_tu_legal_number;
    new_references.tu_description                    := x_tu_description;
    new_references.tu_status                         := x_tu_status;
    new_references.tu_currency_code                  := x_tu_currency_code;
    new_references.tu_amount                         := x_tu_amount;
    new_references.apprv_profile_id                  := x_apprv_profile_id;
    new_references.next_approver_user_id             := x_next_approver_user_id;
    new_references.tu_fiscal_year                    := x_tu_fiscal_year;
    new_references.tu_by_user_id                     := x_tu_by_user_id;
    new_references.tu_date                           := x_tu_date;
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
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 16-APR-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.apprv_profile_id = new_references.apprv_profile_id)) OR
        ((new_references.apprv_profile_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_exp_apprv_profiles_pkg.get_pk_for_validation (
                new_references.apprv_profile_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpzb.IGI_EXP_TUS_PKG.check_parent_existance.msg1',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      app_exception.raise_exception;
    END IF;

    IF (((old_references.tu_type_header_id = new_references.tu_type_header_id)) OR
        ((new_references.tu_type_header_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_exp_tu_type_headers_pkg.get_pk_for_validation (
                new_references.tu_type_header_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpzb.IGI_EXP_TUS_PKG.check_parent_existance.msg2',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

 PROCEDURE check_child_existance IS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 14-APR-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igi_exp_dus_pkg.get_fk_igi_exp_tus (
      old_references.tu_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_tu_id                             IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 16-APR-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_exp_tus_all
      WHERE    tu_id = x_tu_id
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


  PROCEDURE get_fk_igi_exp_apprv_profiles (
    x_apprv_profile_id                  IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 16-APR-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_exp_tus_all
      WHERE   ((apprv_profile_id = x_apprv_profile_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND', 'FND-CANNOT DELETE MASTER');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpzb.IGI_EXP_TUS_PKG.get_fk_igi_exp_apprv_profiles',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_exp_apprv_profiles;


  PROCEDURE get_fk_igi_exp_tu_type_headers (
    x_tu_type_header_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 16-APR-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_exp_tus_all
      WHERE   ((tu_type_header_id = x_tu_type_header_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND', 'FND-CANNOT DELETE MASTER');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpzb.IGI_EXP_TUS_PKG.get_fk_igi_exp_tu_type_headers ',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_exp_tu_type_headers;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_tu_id                             IN     NUMBER      ,
    x_tu_type_header_id                 IN     NUMBER      ,
    x_tu_order_number                   IN     VARCHAR2    ,
    x_tu_legal_number                   IN     VARCHAR2    ,
    x_tu_description                    IN     VARCHAR2    ,
    x_tu_status                         IN     VARCHAR2    ,
    x_tu_currency_code                  IN     VARCHAR2    ,
    x_tu_amount                         IN     NUMBER      ,
    x_apprv_profile_id                  IN     NUMBER      ,
    x_next_approver_user_id             IN     NUMBER      ,
    x_tu_fiscal_year                    IN     NUMBER      ,
    x_tu_by_user_id                     IN     NUMBER      ,
    x_tu_date                           IN     DATE        ,
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
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 16-APR-2002
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
      x_tu_id,
      x_tu_type_header_id,
      x_tu_order_number,
      x_tu_legal_number,
      x_tu_description,
      x_tu_status,
      x_tu_currency_code,
      x_tu_amount,
      x_apprv_profile_id,
      x_next_approver_user_id,
      x_tu_fiscal_year,
      x_tu_by_user_id,
      x_tu_date,
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
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.tu_id
           )
         ) THEN
        fnd_message.set_name('IGI','IGI_EXP_DUP_ROW');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpzb.IGI_EXP_TUS_PKG.before_dml.msg1',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.tu_id
           )
         ) THEN
        fnd_message.set_name('IGI','IGI_EXP_DUP_ROW');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpzb.IGI_EXP_TUS_PKG.before_dml.msg2',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_org_id                            IN     NUMBER,
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tu_id                             IN OUT NOCOPY NUMBER,
    x_tu_type_header_id                 IN     NUMBER,
    x_tu_order_number                   IN     VARCHAR2,
    x_tu_legal_number                   IN     VARCHAR2,
    x_tu_description                    IN     VARCHAR2,
    x_tu_status                         IN     VARCHAR2,
    x_tu_currency_code                  IN     VARCHAR2,
    x_tu_amount                         IN     NUMBER,
    x_apprv_profile_id                  IN     NUMBER,
    x_next_approver_user_id             IN     NUMBER,
    x_tu_fiscal_year                    IN     NUMBER,
    x_tu_by_user_id                     IN     NUMBER,
    x_tu_date                           IN     DATE,
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
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 16-APR-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_exp_tus_all
      WHERE    tu_id                             = x_tu_id;

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
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpzb.IGI_EXP_TUS_PKG.insert_row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      app_exception.raise_exception;
    END IF;

    SELECT    igi_exp_tus_s1.NEXTVAL
    INTO      x_tu_id
    FROM      dual;

    new_references.org_id := x_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_tu_id                             => x_tu_id,
      x_tu_type_header_id                 => x_tu_type_header_id,
      x_tu_order_number                   => x_tu_order_number,
      x_tu_legal_number                   => x_tu_legal_number,
      x_tu_description                    => x_tu_description,
      x_tu_status                         => x_tu_status,
      x_tu_currency_code                  => x_tu_currency_code,
      x_tu_amount                         => x_tu_amount,
      x_apprv_profile_id                  => x_apprv_profile_id,
      x_next_approver_user_id             => x_next_approver_user_id,
      x_tu_fiscal_year                    => x_tu_fiscal_year,
      x_tu_by_user_id                     => x_tu_by_user_id,
      x_tu_date                           => x_tu_date,
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
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igi_exp_tus_all (
      tu_id,
      tu_type_header_id,
      tu_order_number,
      tu_legal_number,
      tu_description,
      tu_status,
      tu_currency_code,
      tu_amount,
      apprv_profile_id,
      next_approver_user_id,
      tu_fiscal_year,
      tu_by_user_id,
      tu_date,
      org_id,
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
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.tu_id,
      new_references.tu_type_header_id,
      new_references.tu_order_number,
      new_references.tu_legal_number,
      new_references.tu_description,
      new_references.tu_status,
      new_references.tu_currency_code,
      new_references.tu_amount,
      new_references.apprv_profile_id,
      new_references.next_approver_user_id,
      new_references.tu_fiscal_year,
      new_references.tu_by_user_id,
      new_references.tu_date,
      new_references.org_id,
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
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
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
    x_tu_id                             IN     NUMBER,
    x_tu_type_header_id                 IN     NUMBER,
    x_tu_order_number                   IN     VARCHAR2,
    x_tu_legal_number                   IN     VARCHAR2,
    x_tu_description                    IN     VARCHAR2,
    x_tu_status                         IN     VARCHAR2,
    x_tu_currency_code                  IN     VARCHAR2,
    x_tu_amount                         IN     NUMBER,
    x_apprv_profile_id                  IN     NUMBER,
    x_next_approver_user_id             IN     NUMBER,
    x_tu_fiscal_year                    IN     NUMBER,
    x_tu_by_user_id                     IN     NUMBER,
    x_tu_date                           IN     DATE,
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
    x_attribute15                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 16-APR-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        tu_type_header_id,
        tu_order_number,
        tu_legal_number,
        tu_description,
        tu_status,
        tu_currency_code,
        tu_amount,
        apprv_profile_id,
        next_approver_user_id,
        tu_fiscal_year,
        tu_by_user_id,
        tu_date,
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
        attribute15
      FROM  igi_exp_tus_all
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpzb.IGI_EXP_TUS_PKG.lock_row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.tu_type_header_id = x_tu_type_header_id)
        AND (tlinfo.tu_order_number = x_tu_order_number)
        AND ((tlinfo.tu_legal_number = x_tu_legal_number) OR ((tlinfo.tu_legal_number IS NULL) AND (X_tu_legal_number IS NULL)))
        AND ((tlinfo.tu_description = x_tu_description) OR ((tlinfo.tu_description IS NULL) AND (X_tu_description IS NULL)))
        AND (tlinfo.tu_status = x_tu_status)
        AND ((tlinfo.tu_currency_code = x_tu_currency_code) OR ((tlinfo.tu_currency_code IS NULL) AND (X_tu_currency_code IS NULL)))
        AND (tlinfo.tu_amount = x_tu_amount)
        AND (tlinfo.apprv_profile_id = x_apprv_profile_id)
        AND ((tlinfo.next_approver_user_id = x_next_approver_user_id) OR ((tlinfo.next_approver_user_id IS NULL) AND (X_next_approver_user_id IS NULL)))
        AND (tlinfo.tu_fiscal_year = x_tu_fiscal_year)
        AND (tlinfo.tu_by_user_id = x_tu_by_user_id)
        AND (tlinfo.tu_date = x_tu_date)
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
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpzb.IGI_EXP_TUS_PKG.lock_row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_tu_id                             IN     NUMBER,
    x_tu_type_header_id                 IN     NUMBER,
    x_tu_order_number                   IN     VARCHAR2,
    x_tu_legal_number                   IN     VARCHAR2,
    x_tu_description                    IN     VARCHAR2,
    x_tu_status                         IN     VARCHAR2,
    x_tu_currency_code                  IN     VARCHAR2,
    x_tu_amount                         IN     NUMBER,
    x_apprv_profile_id                  IN     NUMBER,
    x_next_approver_user_id             IN     NUMBER,
    x_tu_fiscal_year                    IN     NUMBER,
    x_tu_by_user_id                     IN     NUMBER,
    x_tu_date                           IN     DATE,
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
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 16-APR-2002
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
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpzb.IGI_EXP_TUS_PKG.update_row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_tu_id                             => x_tu_id,
      x_tu_type_header_id                 => x_tu_type_header_id,
      x_tu_order_number                   => x_tu_order_number,
      x_tu_legal_number                   => x_tu_legal_number,
      x_tu_description                    => x_tu_description,
      x_tu_status                         => x_tu_status,
      x_tu_currency_code                  => x_tu_currency_code,
      x_tu_amount                         => x_tu_amount,
      x_apprv_profile_id                  => x_apprv_profile_id,
      x_next_approver_user_id             => x_next_approver_user_id,
      x_tu_fiscal_year                    => x_tu_fiscal_year,
      x_tu_by_user_id                     => x_tu_by_user_id,
      x_tu_date                           => x_tu_date,
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
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igi_exp_tus_all
      SET
        tu_type_header_id                 = new_references.tu_type_header_id,
        tu_order_number                   = new_references.tu_order_number,
        tu_legal_number                   = new_references.tu_legal_number,
        tu_description                    = new_references.tu_description,
        tu_status                         = new_references.tu_status,
        tu_currency_code                  = new_references.tu_currency_code,
        tu_amount                         = new_references.tu_amount,
        apprv_profile_id                  = new_references.apprv_profile_id,
        next_approver_user_id             = new_references.next_approver_user_id,
        tu_fiscal_year                    = new_references.tu_fiscal_year,
        tu_by_user_id                     = new_references.tu_by_user_id,
        tu_date                           = new_references.tu_date,
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
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_org_id                            IN     NUMBER,
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tu_id                             IN OUT NOCOPY NUMBER,
    x_tu_type_header_id                 IN     NUMBER,
    x_tu_order_number                   IN     VARCHAR2,
    x_tu_legal_number                   IN     VARCHAR2,
    x_tu_description                    IN     VARCHAR2,
    x_tu_status                         IN     VARCHAR2,
    x_tu_currency_code                  IN     VARCHAR2,
    x_tu_amount                         IN     NUMBER,
    x_apprv_profile_id                  IN     NUMBER,
    x_next_approver_user_id             IN     NUMBER,
    x_tu_fiscal_year                    IN     NUMBER,
    x_tu_by_user_id                     IN     NUMBER,
    x_tu_date                           IN     DATE,
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
    x_mode                              IN     VARCHAR2 ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 16-APR-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_exp_tus_all
      WHERE    tu_id                             = x_tu_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_org_id,
        x_rowid,
        x_tu_id,
        x_tu_type_header_id,
        x_tu_order_number,
        x_tu_legal_number,
        x_tu_description,
        x_tu_status,
        x_tu_currency_code,
        x_tu_amount,
        x_apprv_profile_id,
        x_next_approver_user_id,
        x_tu_fiscal_year,
        x_tu_by_user_id,
        x_tu_date,
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
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_tu_id,
      x_tu_type_header_id,
      x_tu_order_number,
      x_tu_legal_number,
      x_tu_description,
      x_tu_status,
      x_tu_currency_code,
      x_tu_amount,
      x_apprv_profile_id,
      x_next_approver_user_id,
      x_tu_fiscal_year,
      x_tu_by_user_id,
      x_tu_date,
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
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 16-APR-2002
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

    DELETE FROM igi_exp_tus_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

 /* Commented becase of MOAC changes

  FUNCTION get_org_id RETURN NUMBER AS
    CURSOR cur_orgid IS
    SELECT
 NVL ( TO_NUMBER ( DECODE ( SUBSTRB ( USERENV ('CLIENT_INFO' ), 1, 1  ), ' ', NULL,  SUBSTRB (USERENV ('CLIENT_INFO'),1,10)  )   ), NULL  ) org_id FROM dual;

    lv_org_id Number(15);

  BEGIN

    OPEN cur_orgid;
    FETCH cur_orgid INTO lv_org_id;
    CLOSE cur_orgid;

 RETURN lv_org_id ;

 END get_org_id ;
 */

END igi_exp_tus_pkg;

/
