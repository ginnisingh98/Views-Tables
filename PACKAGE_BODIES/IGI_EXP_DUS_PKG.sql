--------------------------------------------------------
--  DDL for Package Body IGI_EXP_DUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_DUS_PKG" AS
/* $Header: igiexpwb.pls 120.4.12000000.1 2007/09/13 04:25:09 mbremkum ship $ */

--following variables added for bug 3199481: fnd logging changes: sdixit
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

  l_rowid VARCHAR2(25);
  old_references igi_exp_dus_all%ROWTYPE;
  new_references igi_exp_dus_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_du_id                             IN     NUMBER      ,
    x_du_type_header_id                 IN     NUMBER      ,
    x_du_order_number                   IN     VARCHAR2    ,
    x_du_legal_number                   IN     VARCHAR2    ,
    x_du_description                    IN     VARCHAR2    ,
    x_du_status                         IN     VARCHAR2    ,
    x_du_amount                         IN     NUMBER      ,
    x_du_prepay_amount                  IN     NUMBER      ,
    x_du_stp_id                         IN     NUMBER      ,
    x_du_stp_site_id                    IN     NUMBER      ,
    x_du_currency_code                  IN     VARCHAR2    ,
    x_tu_id                             IN     NUMBER      ,
    x_print_date                        IN     DATE        ,
    x_du_by_user_id                     IN     NUMBER      ,
    x_du_fiscal_year                    IN     NUMBER      ,
    x_du_date                           IN     DATE        ,
    x_org_id                            IN     NUMBER      ,
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
  ||  Created On : 01-NOV-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGI_EXP_DUS_ALL
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
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.set_column_values',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.du_id                             := x_du_id;
    new_references.du_type_header_id                 := x_du_type_header_id;
    new_references.du_order_number                   := x_du_order_number;
    new_references.du_legal_number                   := x_du_legal_number;
    new_references.du_description                    := x_du_description;
    new_references.du_status                         := x_du_status;
    new_references.du_amount                         := x_du_amount;
    new_references.du_prepay_amount                  := x_du_prepay_amount;
    new_references.du_stp_id                         := x_du_stp_id;
    new_references.du_stp_site_id                    := x_du_stp_site_id;
    new_references.du_currency_code                  := x_du_currency_code;
    new_references.tu_id                             := x_tu_id;
    new_references.print_date                        := x_print_date;
    new_references.du_by_user_id                     := x_du_by_user_id;
    new_references.du_fiscal_year                    := x_du_fiscal_year;
    new_references.du_date                           := x_du_date;
    new_references.org_id                            := x_org_id;
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
  ||  Created On : 01-NOV-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.du_type_header_id = new_references.du_type_header_id)) OR
        ((new_references.du_type_header_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_exp_du_type_headers_pkg.get_pk_for_validation (
                new_references.du_type_header_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.check_parent_existance.msg1',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
    END IF;

    IF (((old_references.tu_id = new_references.tu_id)) OR
        ((new_references.tu_id IS NULL))) THEN
      NULL;
    ELSIF NOT igi_exp_tus_pkg.get_pk_for_validation (
                new_references.tu_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.check_parent_existance.msg2',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
    END IF;
/*
    IF (((old_references.du_stp_id = new_references.du_stp_id)) OR
        ((new_references.du_stp_id IS NULL))) THEN
      NULL;
    ELSIF NOT po_vendors_pkg.get_pk_for_validation (
                new_references.du_stp_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');

      app_exception.raise_exception;
    END IF;  commented by kakrishn */

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-NOV-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igi_exp_ap_trans_pkg.get_fk_igi_exp_dus (
      old_references.du_id
    );

    igi_exp_ar_trans_pkg.get_fk_igi_exp_dus (
      old_references.du_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_du_id                             IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-NOV-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_exp_dus_all
      WHERE    du_id = x_du_id
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


  PROCEDURE get_fk_igi_exp_du_type_headers (
    x_du_type_header_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_exp_dus_all
      WHERE   ((du_type_header_id = x_du_type_header_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name('FND' ,'FND-CANNOT DELETE MASTER');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.get_fk_igi_exp_du_type_headers',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_exp_du_type_headers;


  PROCEDURE get_fk_igi_exp_tus (
    x_tu_id                             IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_exp_dus_all
      WHERE   ((tu_id = x_tu_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
       fnd_message.set_name('FND' ,'FND-CANNOT DELETE MASTER');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.get_fk_igi_exp_tus',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igi_exp_tus;


  PROCEDURE get_fk_po_vendors (
    x_vendor_id                         IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igi_exp_dus_all
      WHERE   ((du_stp_id = x_vendor_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
       fnd_message.set_name('FND' ,'FND-CANNOT DELETE MASTER');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.get_fk_po_vendors',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_po_vendors;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_du_id                             IN     NUMBER      ,
    x_du_type_header_id                 IN     NUMBER      ,
    x_du_order_number                   IN     VARCHAR2    ,
    x_du_legal_number                   IN     VARCHAR2    ,
    x_du_description                    IN     VARCHAR2    ,
    x_du_status                         IN     VARCHAR2    ,
    x_du_amount                         IN     NUMBER      ,
    x_du_prepay_amount                  IN     NUMBER      ,
    x_du_stp_id                         IN     NUMBER      ,
    x_du_stp_site_id                    IN     NUMBER      ,
    x_du_currency_code                  IN     VARCHAR2    ,
    x_tu_id                             IN     NUMBER      ,
    x_print_date                        IN     DATE        ,
    x_du_by_user_id                     IN     NUMBER      ,
    x_du_fiscal_year                    IN     NUMBER      ,
    x_du_date                           IN     DATE        ,
    x_org_id                            IN     NUMBER      ,
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
  ||  Created On : 01-NOV-2001
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
      x_du_id,
      x_du_type_header_id,
      x_du_order_number,
      x_du_legal_number,
      x_du_description,
      x_du_status,
      x_du_amount,
      x_du_prepay_amount,
      x_du_stp_id,
      x_du_stp_site_id,
      x_du_currency_code,
      x_tu_id,
      x_print_date,
      x_du_by_user_id,
      x_du_fiscal_year,
      x_du_date,
      x_org_id,
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
             new_references.du_id
           )
         ) THEN
        fnd_message.set_name('IGI','IGI_EXP_DUP_ROW');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.before_dml.msg1',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.du_id
           )
         ) THEN
        fnd_message.set_name('IGI','IGI_EXP_DUP_ROW');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_error_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.before_dml.msg2',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_du_id                             IN OUT NOCOPY NUMBER,
    x_du_type_header_id                 IN     NUMBER,
    x_du_order_number                   IN     VARCHAR2,
    x_du_legal_number                   IN     VARCHAR2,
    x_du_description                    IN     VARCHAR2,
    x_du_status                         IN     VARCHAR2,
    x_du_amount                         IN     NUMBER,
    x_du_prepay_amount                  IN     NUMBER,
    x_du_stp_id                         IN     NUMBER,
    x_du_stp_site_id                    IN     NUMBER,
    x_du_currency_code                  IN     VARCHAR2,
    x_tu_id                             IN     NUMBER,
    x_print_date                        IN     DATE,
    x_du_by_user_id                     IN     NUMBER,
    x_du_fiscal_year                    IN     NUMBER,
    x_du_date                           IN     DATE,
    x_org_id                            IN     NUMBER,
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
  ||  Created On : 01-NOV-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igi_exp_dus_all
      WHERE    du_id                             = x_du_id;

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
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.insert_row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
    END IF;

    SELECT    igi_exp_dus_s1.NEXTVAL
    INTO      x_du_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_du_id                             => x_du_id,
      x_du_type_header_id                 => x_du_type_header_id,
      x_du_order_number                   => x_du_order_number,
      x_du_legal_number                   => x_du_legal_number,
      x_du_description                    => x_du_description,
      x_du_status                         => x_du_status,
      x_du_amount                         => x_du_amount,
      x_du_prepay_amount                  => x_du_prepay_amount,
      x_du_stp_id                         => x_du_stp_id,
      x_du_stp_site_id                    => x_du_stp_site_id,
      x_du_currency_code                  => x_du_currency_code,
      x_tu_id                             => x_tu_id,
      x_print_date                        => x_print_date,
      x_du_by_user_id                     => x_du_by_user_id,
      x_du_fiscal_year                    => x_du_fiscal_year,
      x_du_date                           => x_du_date,
      x_org_id                            => x_org_id,
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

    INSERT INTO igi_exp_dus_all (
      du_id,
      du_type_header_id,
      du_order_number,
      du_legal_number,
      du_description,
      du_status,
      du_amount,
      du_prepay_amount,
      du_stp_id,
      du_stp_site_id,
      du_currency_code,
      tu_id,
      print_date,
      du_by_user_id,
      du_fiscal_year,
      du_date,
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
      new_references.du_id,
      new_references.du_type_header_id,
      new_references.du_order_number,
      new_references.du_legal_number,
      new_references.du_description,
      new_references.du_status,
      new_references.du_amount,
      new_references.du_prepay_amount,
      new_references.du_stp_id,
      new_references.du_stp_site_id,
      new_references.du_currency_code,
      new_references.tu_id,
      new_references.print_date,
      new_references.du_by_user_id,
      new_references.du_fiscal_year,
      new_references.du_date,
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
    x_du_id                             IN     NUMBER,
    x_du_type_header_id                 IN     NUMBER,
    x_du_order_number                   IN     VARCHAR2,
    x_du_legal_number                   IN     VARCHAR2,
    x_du_description                    IN     VARCHAR2,
    x_du_status                         IN     VARCHAR2,
    x_du_amount                         IN     NUMBER,
    x_du_prepay_amount                  IN     NUMBER,
    x_du_stp_id                         IN     NUMBER,
    x_du_stp_site_id                    IN     NUMBER,
    x_du_currency_code                  IN     VARCHAR2,
    x_tu_id                             IN     NUMBER,
    x_print_date                        IN     DATE,
    x_du_by_user_id                     IN     NUMBER,
    x_du_fiscal_year                    IN     NUMBER,
    x_du_date                           IN     DATE,
    x_org_id                            IN     NUMBER,
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
  ||  Created On : 01-NOV-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        du_type_header_id,
        du_order_number,
        du_legal_number,
        du_description,
        du_status,
        du_amount,
        du_prepay_amount,
        du_stp_id,
        du_stp_site_id,
        du_currency_code,
        tu_id,
        print_date,
        du_by_user_id,
        du_fiscal_year,
        du_date,
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
        attribute15
      FROM  igi_exp_dus_all
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
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.lock_row.msg1',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.du_type_header_id = x_du_type_header_id)
        AND (tlinfo.du_order_number = x_du_order_number)
        AND ((tlinfo.du_legal_number = x_du_legal_number) OR ((tlinfo.du_legal_number IS NULL) AND (X_du_legal_number IS NULL)))
        AND ((tlinfo.du_description = x_du_description) OR ((tlinfo.du_description IS NULL) AND (X_du_description IS NULL)))
        AND (tlinfo.du_status = x_du_status)
        AND (tlinfo.du_amount = x_du_amount)
        AND (tlinfo.du_prepay_amount = x_du_prepay_amount)
        AND ((tlinfo.du_stp_id = x_du_stp_id) OR ((tlinfo.du_stp_id IS NULL) AND (X_du_stp_id IS NULL)))
        AND ((tlinfo.du_stp_site_id = x_du_stp_site_id) OR ((tlinfo.du_stp_site_id IS NULL) AND (X_du_stp_site_id IS NULL)))
        AND (tlinfo.du_currency_code = x_du_currency_code)
        AND ((tlinfo.tu_id = x_tu_id) OR ((tlinfo.tu_id IS NULL) AND (X_tu_id IS NULL)))
        AND ((tlinfo.print_date = x_print_date) OR ((tlinfo.print_date IS NULL) AND (X_print_date IS NULL)))
        AND (tlinfo.du_by_user_id = x_du_by_user_id)
        AND (tlinfo.du_fiscal_year = x_du_fiscal_year)
        AND (tlinfo.du_date = x_du_date)
        AND (tlinfo.org_id = x_org_id)
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
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.lock_row.msg2',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_du_id                             IN     NUMBER,
    x_du_type_header_id                 IN     NUMBER,
    x_du_order_number                   IN     VARCHAR2,
    x_du_legal_number                   IN     VARCHAR2,
    x_du_description                    IN     VARCHAR2,
    x_du_status                         IN     VARCHAR2,
    x_du_amount                         IN     NUMBER,
    x_du_prepay_amount                  IN     NUMBER,
    x_du_stp_id                         IN     NUMBER,
    x_du_stp_site_id                    IN     NUMBER,
    x_du_currency_code                  IN     VARCHAR2,
    x_tu_id                             IN     NUMBER,
    x_print_date                        IN     DATE,
    x_du_by_user_id                     IN     NUMBER,
    x_du_fiscal_year                    IN     NUMBER,
    x_du_date                           IN     DATE,
    x_org_id                            IN     NUMBER,
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
  ||  Created On : 01-NOV-2001
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
          FND_LOG.MESSAGE (l_error_level , 'igi.plsql.igiexpwb.IGI_EXP_DUS_PKG.update_row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block

      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_du_id                             => x_du_id,
      x_du_type_header_id                 => x_du_type_header_id,
      x_du_order_number                   => x_du_order_number,
      x_du_legal_number                   => x_du_legal_number,
      x_du_description                    => x_du_description,
      x_du_status                         => x_du_status,
      x_du_amount                         => x_du_amount,
      x_du_prepay_amount                  => x_du_prepay_amount,
      x_du_stp_id                         => x_du_stp_id,
      x_du_stp_site_id                    => x_du_stp_site_id,
      x_du_currency_code                  => x_du_currency_code,
      x_tu_id                             => x_tu_id,
      x_print_date                        => x_print_date,
      x_du_by_user_id                     => x_du_by_user_id,
      x_du_fiscal_year                    => x_du_fiscal_year,
      x_du_date                           => x_du_date,
      x_org_id                            => x_org_id,
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

    UPDATE igi_exp_dus_all
      SET
        du_type_header_id                 = new_references.du_type_header_id,
        du_order_number                   = new_references.du_order_number,
        du_legal_number                   = new_references.du_legal_number,
        du_description                    = new_references.du_description,
        du_status                         = new_references.du_status,
        du_amount                         = new_references.du_amount,
        du_prepay_amount                  = new_references.du_prepay_amount,
        du_stp_id                         = new_references.du_stp_id,
        du_stp_site_id                    = new_references.du_stp_site_id,
        du_currency_code                  = new_references.du_currency_code,
        tu_id                             = new_references.tu_id,
        print_date                        = new_references.print_date,
        du_by_user_id                     = new_references.du_by_user_id,
        du_fiscal_year                    = new_references.du_fiscal_year,
        du_date                           = new_references.du_date,
        org_id                            = new_references.org_id,
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
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_du_id                             IN OUT NOCOPY NUMBER,
    x_du_type_header_id                 IN     NUMBER,
    x_du_order_number                   IN     VARCHAR2,
    x_du_legal_number                   IN     VARCHAR2,
    x_du_description                    IN     VARCHAR2,
    x_du_status                         IN     VARCHAR2,
    x_du_amount                         IN     NUMBER,
    x_du_prepay_amount                  IN     NUMBER,
    x_du_stp_id                         IN     NUMBER,
    x_du_stp_site_id                    IN     NUMBER,
    x_du_currency_code                  IN     VARCHAR2,
    x_tu_id                             IN     NUMBER,
    x_print_date                        IN     DATE,
    x_du_by_user_id                     IN     NUMBER,
    x_du_fiscal_year                    IN     NUMBER,
    x_du_date                           IN     DATE,
    x_org_id                            IN     NUMBER,
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
  ||  Created On : 01-NOV-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igi_exp_dus_all
      WHERE    du_id                             = x_du_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_du_id,
        x_du_type_header_id,
        x_du_order_number,
        x_du_legal_number,
        x_du_description,
        x_du_status,
        x_du_amount,
        x_du_prepay_amount,
        x_du_stp_id,
        x_du_stp_site_id,
        x_du_currency_code,
        x_tu_id,
        x_print_date,
        x_du_by_user_id,
        x_du_fiscal_year,
        x_du_date,
        x_org_id,
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
      x_du_id,
      x_du_type_header_id,
      x_du_order_number,
      x_du_legal_number,
      x_du_description,
      x_du_status,
      x_du_amount,
      x_du_prepay_amount,
      x_du_stp_id,
      x_du_stp_site_id,
      x_du_currency_code,
      x_tu_id,
      x_print_date,
      x_du_by_user_id,
      x_du_fiscal_year,
      x_du_date,
      x_org_id,
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
  ||  Created On : 01-NOV-2001
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

    DELETE FROM igi_exp_dus_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igi_exp_dus_pkg;

/
