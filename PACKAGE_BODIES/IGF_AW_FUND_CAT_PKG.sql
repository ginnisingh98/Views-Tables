--------------------------------------------------------
--  DDL for Package Body IGF_AW_FUND_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_FUND_CAT_PKG" AS
/* $Header: IGFWI04B.pls 120.0 2005/06/01 13:41:03 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_fund_cat_all%ROWTYPE;
  new_references igf_aw_fund_cat_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_fund_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_fund_source                       IN     VARCHAR2,
    x_fed_fund_code                     IN     VARCHAR2,
    x_sys_fund_type                     IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_fcat_id                           IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_alt_loan_code                     IN     VARCHAR2,
    x_alt_rel_code                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_FUND_CAT_ALL
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
    new_references.fund_code                         := x_fund_code;
    new_references.description                       := x_description;
    new_references.fund_type                         := x_fund_type;
    new_references.fund_source                       := x_fund_source;
    new_references.fed_fund_code                     := x_fed_fund_code;
    new_references.sys_fund_type                     := x_sys_fund_type;
    new_references.active                            := x_active;
    new_references.fcat_id                           := x_fcat_id;
    new_references.alt_loan_code                     := x_alt_loan_code;
    new_references.alt_rel_code                      := x_alt_rel_code;

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
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ((get_uk_for_validation(new_references.fund_code)) OR (get_uk1_for_validation(new_references.alt_loan_code))) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.fund_type = new_references.fund_type)) OR
        ((new_references.fund_type IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_fund_type_pkg.get_uk_For_validation (
                new_references.fund_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  PROCEDURE check_child_existance IS
  /*
  ||  Created By : prchandr
  ||  Created On : 04-APR-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel        04-OCT-2002      Bug NO: 2600842
  ||                                  Added the call igs_pe_fund_excl_pkg.get_ufk_igf_aw_fund_cat
  ||  nalkumar       14-NOV-2002      Bug NO: 2658550
  ||                                  Added the call igs_pr_ou_fnd_pkg.get_fk_igf_aw_fund_cat and
  ||                                  igs_pr_stdnt_pr_fnd_pkg.get_fk_igf_aw_fund_cat. As per FA110 PR Enh.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_aw_fund_excl_pkg.get_ufk_igf_aw_fund_cat (
      old_references.fund_code
    );

    igf_aw_fund_incl_pkg.get_ufk_igf_aw_fund_cat (
      old_references.fund_code
    );

    igf_aw_fund_mast_pkg.get_ufk_igf_aw_fund_cat (
      old_references.fund_code ,
       old_references.org_id
    );

    igs_pe_fund_excl_pkg.get_ufk_igf_aw_fund_cat (
      old_references.fund_code
    );

    igs_pr_ou_fnd_pkg.get_fk_igf_aw_fund_cat (
      old_references.fund_code
    );
    igs_pr_stdnt_pr_fnd_pkg.get_fk_igf_aw_fund_cat (
      old_references.fund_code
    );
  END check_child_existance;

  PROCEDURE check_uk_child_existance IS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
  ||  Purpose : Checks for the existance of Child records based on Unique Keys of this table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN


    IF (((old_references.fund_code = new_references.fund_code)) OR
        ((old_references.fund_code IS NULL))) THEN
      NULL;
    ELSE igf_aw_fund_excl_pkg.get_ufk_igf_aw_fund_cat (
           old_references.fund_code
         );
    END IF;

    IF (((old_references.fund_code = new_references.fund_code)) OR
        ((old_references.fund_code IS NULL))) THEN
      NULL;
    ELSE igf_aw_fund_incl_pkg.get_ufk_igf_aw_fund_cat (
           old_references.fund_code
         );
    END IF;

    IF (((old_references.fund_code = new_references.fund_code)) OR
        ((old_references.fund_code IS NULL))) THEN
      NULL;
    ELSE igf_aw_fund_mast_pkg.get_ufk_igf_aw_fund_cat (
           old_references.fund_code ,
           old_references.org_id
         );
    END IF;

  END check_uk_child_existance;


  FUNCTION get_pk_for_validation (
    x_fcat_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fund_cat_all
      WHERE    fcat_id = x_fcat_id
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
    x_fund_code                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    l_org_id                     igf_aw_fund_cat_all.org_id%TYPE  := igf_aw_gen.get_org_id;
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fund_cat_all
      WHERE    fund_code = x_fund_code
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      AND      NVL(org_id,NVL(l_org_id,-99))=NVL(l_org_id,-99)
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (TRUE);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;

FUNCTION get_uk1_for_validation (
    x_alt_loan_code                     IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  bkkumar        02-apr-04        FACR116 - Added the validation for checking the
  ||                                  uniqueness of the alt_loan_code column.
  ||  (reverse chronological order - newest change first)
  */

    l_org_id                     igf_aw_fund_cat_all.org_id%TYPE  := igf_aw_gen.get_org_id;
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fund_cat_all
      WHERE    (NVL(alt_loan_code,'*') = NVL(x_alt_loan_code,'**')
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid)))
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN (TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk1_for_validation ;

 PROCEDURE get_fk_igf_sl_cl_recipient (
                   x_relationship_cd           IN     VARCHAR2
  ) AS
  /*
  ||  Created By : bkkumar
  ||  Created On : 10-APR-2004
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
    SELECT   rowid
    FROM     igf_aw_fund_cat_all
    WHERE   NVL(alt_rel_code,'*') = x_relationship_cd;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF','IGF_AW_FUND_CAT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_cl_recipient;

  PROCEDURE get_ufk_igf_aw_fund_type (
    x_fund_type                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  l_org_id                     igf_aw_fund_cat_all.org_id%TYPE  := igf_aw_gen.get_org_id;
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fund_cat_all
      WHERE   ((fund_type = x_fund_type))
      AND     NVL(org_id,NVL(l_org_id,-99))=NVL(l_org_id,-99);

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_FCAT_FT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igf_aw_fund_type;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_fund_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_fund_source                       IN     VARCHAR2,
    x_fed_fund_code                     IN     VARCHAR2,
    x_sys_fund_type                     IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_fcat_id                           IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_alt_loan_code                     IN     VARCHAR2,
    x_alt_rel_code                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
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
      x_fund_code,
      x_description,
      x_fund_type,
      x_fund_source,
      x_fed_fund_code,
      x_sys_fund_type,
      x_active,
      x_fcat_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_alt_loan_code,
      x_alt_rel_code
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.fcat_id
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
      check_uniqueness;
      check_parent_existance;
      check_uk_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.fcat_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_uk_child_existance;

    ELSIF (p_action = 'DELETE') THEN
      check_child_existance;

    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_fund_source                       IN     VARCHAR2,
    x_fed_fund_code                     IN     VARCHAR2,
    x_sys_fund_type                     IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_fcat_id                           IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2,
    x_alt_loan_code                     IN     VARCHAR2,
    x_alt_rel_code                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_fund_cat_all
      WHERE    fcat_id                           = x_fcat_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

    l_org_id                     igf_aw_fund_cat_all.org_id%TYPE  := igf_aw_gen.get_org_id;

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

    SELECT igf_aw_fund_cat_all_s.nextval INTO x_fcat_id FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_fund_code                         => x_fund_code,
      x_description                       => x_description,
      x_fund_type                         => x_fund_type,
      x_fund_source                       => x_fund_source,
      x_fed_fund_code                     => x_fed_fund_code,
      x_sys_fund_type                     => x_sys_fund_type,
      x_active                            => x_active,
      x_fcat_id                           => x_fcat_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_alt_loan_code                     => x_alt_loan_code ,
      x_alt_rel_code                      => x_alt_rel_code
     );
    INSERT INTO igf_aw_fund_cat_all (
      fund_code,
      description,
      fund_type,
      fund_source,
      fed_fund_code,
      sys_fund_type,
      active,
      fcat_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id,
      alt_loan_code,
      alt_rel_code
    ) VALUES (
      new_references.fund_code,
      new_references.description,
      new_references.fund_type,
      new_references.fund_source,
      new_references.fed_fund_code,
      new_references.sys_fund_type,
      new_references.active,
      new_references.fcat_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      l_org_id ,
      new_references.alt_loan_code,
      new_references.alt_rel_code
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
    x_fund_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_fund_source                       IN     VARCHAR2,
    x_fed_fund_code                     IN     VARCHAR2,
    x_sys_fund_type                     IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_fcat_id                           IN     NUMBER,
    x_alt_loan_code                     IN     VARCHAR2,
    x_alt_rel_code                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        fund_code,
        description,
        fund_type,
        fund_source,
        fed_fund_code,
        sys_fund_type,
        active,
        alt_loan_code,
        alt_rel_code
      FROM  igf_aw_fund_cat
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
        (tlinfo.fund_code = x_fund_code)
        AND ((tlinfo.description = x_description) OR ((tlinfo.description IS NULL) AND (X_description IS NULL)))
        AND (tlinfo.fund_type = x_fund_type)
        AND (tlinfo.fund_source = x_fund_source)
        AND (tlinfo.fed_fund_code = x_fed_fund_code)
        AND (tlinfo.sys_fund_type = x_sys_fund_type)
        AND (tlinfo.active = x_active)
        AND ((tlinfo.alt_loan_code = x_alt_loan_code) OR ((tlinfo.alt_loan_code IS NULL) AND (x_alt_loan_code IS NULL)))
        AND ((tlinfo.alt_rel_code = x_alt_rel_code) OR ((tlinfo.alt_rel_code IS NULL) AND (x_alt_rel_code IS NULL)))
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
    x_fund_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_fund_source                       IN     VARCHAR2,
    x_fed_fund_code                     IN     VARCHAR2,
    x_sys_fund_type                     IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_fcat_id                           IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_alt_loan_code                     IN     VARCHAR2,
    x_alt_rel_code                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_fund_code                         => x_fund_code,
      x_description                       => x_description,
      x_fund_type                         => x_fund_type,
      x_fund_source                       => x_fund_source,
      x_fed_fund_code                     => x_fed_fund_code,
      x_sys_fund_type                     => x_sys_fund_type,
      x_active                            => x_active,
      x_fcat_id                           => x_fcat_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_alt_loan_code                     => x_alt_loan_code ,
      x_alt_rel_code                      => x_alt_rel_code
    );

    UPDATE igf_aw_fund_cat_all
      SET
        fund_code                         = new_references.fund_code,
        description                       = new_references.description,
        fund_type                         = new_references.fund_type,
        fund_source                       = new_references.fund_source,
        fed_fund_code                     = new_references.fed_fund_code,
        sys_fund_type                     = new_references.sys_fund_type,
        active                            = new_references.active,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        alt_loan_code                     = new_references.alt_loan_code,
        alt_rel_code                      = new_references.alt_rel_code
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_fund_source                       IN     VARCHAR2,
    x_fed_fund_code                     IN     VARCHAR2,
    x_sys_fund_type                     IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_fcat_id                           IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2,
    x_alt_loan_code                     IN     VARCHAR2,
    x_alt_rel_code                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_fund_cat_all
      WHERE    fcat_id                           = x_fcat_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_fund_code,
        x_description,
        x_fund_type,
        x_fund_source,
        x_fed_fund_code,
        x_sys_fund_type,
        x_active,
        x_fcat_id,
        x_mode ,
        x_alt_loan_code,
        x_alt_rel_code
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_fund_code,
      x_description,
      x_fund_type,
      x_fund_source,
      x_fed_fund_code,
      x_sys_fund_type,
      x_active,
      x_fcat_id,
      x_mode ,
      x_alt_loan_code,
      x_alt_rel_code
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 29-MAR-2001
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

    DELETE FROM igf_aw_fund_cat_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_fund_cat_pkg;

/
