--------------------------------------------------------
--  DDL for Package Body IGS_PR_OU_FND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_OU_FND_PKG" AS
/* $Header: IGSQI44B.pls 115.3 2003/02/25 09:08:22 anilk noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pr_ou_fnd%ROWTYPE;
  new_references igs_pr_ou_fnd%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 11-NOV-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pr_ou_fnd
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
    new_references.progression_rule_cat              := x_progression_rule_cat;
    new_references.pra_sequence_number               := x_pra_sequence_number;
    new_references.pro_sequence_number               := x_pro_sequence_number;
    new_references.fund_code                         := x_fund_code;

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
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 11-NOV-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF (((old_references.progression_rule_cat = new_references.progression_rule_cat) AND
         (old_references.pra_sequence_number = new_references.pra_sequence_number) AND
         (old_references.pro_sequence_number = new_references.pro_sequence_number)) OR
        ((new_references.progression_rule_cat IS NULL) OR
         (new_references.pra_sequence_number IS NULL) OR
         (new_references.pro_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pr_ru_ou_pkg.get_pk_for_validation (
                new_references.progression_rule_cat,
                new_references.pra_sequence_number,
                new_references.pro_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.fund_code = new_references.fund_code)) OR
        ((new_references.fund_code IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_fund_cat_pkg.get_uk_for_validation ( new_references.fund_code ) THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
    END IF;
  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 11-NOV-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_ou_fnd
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      pra_sequence_number = x_pra_sequence_number
      AND      pro_sequence_number = x_pro_sequence_number
      AND      fund_code = x_fund_code
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


  PROCEDURE get_fk_igs_pr_ru_ou (
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 11-NOV-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_ou_fnd
      WHERE   ((pra_sequence_number = x_pra_sequence_number) AND
               (progression_rule_cat = x_progression_rule_cat) AND
               (pro_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PR_PREF_PRO_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pr_ru_ou;


  PROCEDURE get_fk_igf_aw_fund_cat (
    x_fund_code                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 11-NOV-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_ou_fnd
      WHERE   ((fund_code = x_fund_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PR_PREF_FCAT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_fund_cat;

  PROCEDURE BeforeInsertUpdate( p_action VARCHAR2 ) AS
  /*
  ||  Created By : anilk
  ||  Created On : 25-FEB-2003
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c_parent (
         cp_progression_rule_cat    IGS_PR_RU_OU.progression_rule_cat%TYPE,
         cp_pra_sequence_number     IGS_PR_RU_OU.pra_sequence_number%TYPE,
         cp_sequence_number         IGS_PR_RU_OU.sequence_number%TYPE  ) IS
     SELECT 1
     FROM   IGS_PR_RU_OU pro
     WHERE  pro.progression_rule_cat = cp_progression_rule_cat    AND
            pro.pra_sequence_number  = cp_pra_sequence_number AND
            pro.sequence_number      = cp_sequence_number     AND
            pro.logical_delete_dt is NULL;

    l_dummy NUMBER;

  BEGIN

   IF (p_action = 'INSERT') THEN
      OPEN c_parent( new_references.progression_rule_cat, new_references.pra_sequence_number, new_references.pro_sequence_number );
      FETCH c_parent INTO l_dummy;
      IF c_parent%NOTFOUND THEN
          CLOSE c_parent;
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      CLOSE c_parent;
   ELSIF(p_action = 'UPDATE') THEN
      IF new_references.progression_rule_cat <> old_references.progression_rule_cat  OR
         new_references.pra_sequence_number <> old_references.pra_sequence_number  OR
         new_references.pro_sequence_number <> old_references.pro_sequence_number  THEN
        OPEN c_parent( new_references.progression_rule_cat,  new_references.pra_sequence_number, new_references.pro_sequence_number );
        FETCH c_parent INTO l_dummy;
        IF c_parent%NOTFOUND THEN
          CLOSE c_parent;
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
        CLOSE c_parent;
      END IF;
   END IF;

  END BeforeInsertUpdate;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 11-NOV-2002
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
      x_progression_rule_cat,
      x_pra_sequence_number,
      x_pro_sequence_number,
      x_fund_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.progression_rule_cat,
             new_references.pra_sequence_number,
             new_references.pro_sequence_number,
             new_references.fund_code
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
             new_references.progression_rule_cat,
             new_references.pra_sequence_number,
             new_references.pro_sequence_number,
             new_references.fund_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    -- anilk, bug#2784198
    BeforeInsertUpdate(p_action);

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 11-NOV-2002
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_progression_rule_cat              => x_progression_rule_cat,
      x_pra_sequence_number               => x_pra_sequence_number,
      x_pro_sequence_number               => x_pro_sequence_number,
      x_fund_code                         => x_fund_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_pr_ou_fnd (
      progression_rule_cat,
      pra_sequence_number,
      pro_sequence_number,
      fund_code,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.progression_rule_cat,
      new_references.pra_sequence_number,
      new_references.pro_sequence_number,
      new_references.fund_code,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 11-NOV-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        rowid
      FROM  igs_pr_ou_fnd
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


    RETURN;

  END lock_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 11-NOV-2002
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

    DELETE FROM igs_pr_ou_fnd
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pr_ou_fnd_pkg;

/
