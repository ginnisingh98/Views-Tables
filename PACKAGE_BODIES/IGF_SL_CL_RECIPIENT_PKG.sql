--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_RECIPIENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_RECIPIENT_PKG" AS
/* $Header: IGFLI06B.pls 120.1 2006/04/19 08:12:43 bvisvana noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_cl_recipient%ROWTYPE;
  new_references igf_sl_cl_recipient%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rcpt_id                           IN     NUMBER      DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2    DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recipient_type                    IN     VARCHAR2    DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2    DEFAULT NULL,
    x_enabled                           IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_relationship_cd_desc              IN     VARCHAR2    DEFAULT NULL,
    x_preferred_flag                    IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_SL_CL_RECIPIENT
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
    new_references.rcpt_id                           := x_rcpt_id;
    new_references.lender_id                         := x_lender_id;
    new_references.lend_non_ed_brc_id                := x_lend_non_ed_brc_id;
    new_references.guarantor_id                      := x_guarantor_id;
    new_references.recipient_id                      := x_recipient_id;
    new_references.recipient_type                    := x_recipient_type;
    new_references.recip_non_ed_brc_id               := x_recip_non_ed_brc_id;
    new_references.enabled                           := x_enabled;
    new_references.relationship_cd                   := x_relationship_cd;
    new_references.relationship_cd_desc              := x_relationship_cd_desc;

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
    new_references.preferred_flag                    := x_preferred_flag;

  END set_column_values;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.lender_id,
           new_references.lend_non_ed_brc_id,
           new_references.guarantor_id,
           new_references.recipient_id,
           new_references.recip_non_ed_brc_id,
           new_references.relationship_cd
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF ( get_uk1_for_validation (
           new_references.relationship_cd
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE check_child_existance IS
  /*
  ||  Created By : veramach
  ||  Created On : 09-SEP-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  bkkumar       10-apr-04         FACR116 - Added the
  ||                                  igf_aw_fund_cat_pkg.get_fk_igf_sl_cl_recipient
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_sl_cl_setup_pkg.get_fk_igf_sl_cl_recipient (
      old_references.relationship_cd
    );

    igf_sl_cl_pref_lenders_pkg.get_fk_igf_sl_cl_recipient (
      old_references.relationship_cd
    );

    igf_sl_lor_pkg.get_fk_igf_sl_cl_recipient (
      old_references.relationship_cd
    );

    igf_aw_fund_cat_pkg.get_fk_igf_sl_cl_recipient (
      old_references.relationship_cd
    );

  END check_child_existance;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.lender_id = new_references.lender_id)) OR
        ((new_references.lender_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_lender_pkg.get_pk_for_validation (
                new_references.lender_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.lender_id = new_references.lender_id) AND
         (old_references.lend_non_ed_brc_id = new_references.lend_non_ed_brc_id)) OR
        ((new_references.lender_id IS NULL) OR
         (new_references.lend_non_ed_brc_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_lender_brc_pkg.get_pk_for_validation (
                new_references.lender_id,
                new_references.lend_non_ed_brc_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.guarantor_id = new_references.guarantor_id)) OR
        ((new_references.guarantor_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_guarantor_pkg.get_pk_for_validation (
                new_references.guarantor_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_rcpt_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_recipient
      WHERE    rcpt_id = x_rcpt_id
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
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  veramach        10-SEP-2003     Changed signature of function to use relationship_code_txt also
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_recipient
      WHERE    lender_id = x_lender_id
      AND      ((lend_non_ed_brc_id = x_lend_non_ed_brc_id) OR (lend_non_ed_brc_id IS NULL AND x_lend_non_ed_brc_id IS NULL))
      AND      guarantor_id = x_guarantor_id
      AND      recipient_id = x_recipient_id
      AND      ((recip_non_ed_brc_id = x_recip_non_ed_brc_id) OR (recip_non_ed_brc_id IS NULL AND x_recip_non_ed_brc_id IS NULL))
      AND      relationship_cd = x_relationship_cd
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

  FUNCTION get_uk1_for_validation (
    x_relationship_cd            IN     VARCHAR2
  ) RETURN BOOLEAN AS
/*
  ||  Created By : veramach
  ||  Created On : 08-SEP-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_recipient
      WHERE    ((relationship_cd = x_relationship_cd))
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

  END get_uk1_for_validation ;


  PROCEDURE get_fk_igf_sl_lender (
    x_lender_id                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_recipient
      WHERE   ((lender_id = x_lender_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_RCPT_LND_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_lender;


  PROCEDURE get_fk_igf_sl_lender_brc (
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_recipient
      WHERE   ((lender_id = x_lender_id) AND
               (lend_non_ed_brc_id = x_lend_non_ed_brc_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_RCPT_LNDB_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_lender_brc;


  PROCEDURE get_fk_igf_sl_guarantor (
    x_guarantor_id                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_recipient
      WHERE   ((guarantor_id = x_guarantor_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_RCPT_GUARN_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_guarantor;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     DEFAULT NULL,
    x_rcpt_id                           IN     NUMBER       DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2     DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2     DEFAULT NULL,
    x_guarantor_id                      IN     VARCHAR2     DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2     DEFAULT NULL,
    x_recipient_type                    IN     VARCHAR2     DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2     DEFAULT NULL,
    x_enabled                           IN     VARCHAR2     DEFAULT NULL,
    x_creation_date                     IN     DATE         DEFAULT NULL,
    x_created_by                        IN     NUMBER       DEFAULT NULL,
    x_last_update_date                  IN     DATE         DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER       DEFAULT NULL,
    x_last_update_login                 IN     NUMBER       DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2     DEFAULT NULL,
    x_relationship_cd_desc              IN     VARCHAR2     DEFAULT NULL,
    x_preferred_flag                    IN     VARCHAR2     DEFAULT NULL
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
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
      x_rcpt_id,
      x_lender_id,
      x_lend_non_ed_brc_id,
      x_guarantor_id,
      x_recipient_id,
      x_recipient_type,
      x_recip_non_ed_brc_id,
      x_enabled,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_relationship_cd,
      x_relationship_cd_desc,
      x_preferred_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.rcpt_id
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.rcpt_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;

    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rcpt_id                           IN OUT NOCOPY NUMBER,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_relationship_cd_desc              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_preferred_flag                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_cl_recipient
      WHERE    rcpt_id                           = x_rcpt_id;

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


    SELECT igf_sl_cl_recipient_s.nextval
    INTO x_rcpt_id
    FROM dual;


    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_rcpt_id                           => x_rcpt_id,
      x_lender_id                         => x_lender_id,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_guarantor_id                      => x_guarantor_id,
      x_recipient_id                      => x_recipient_id,
      x_recipient_type                    => x_recipient_type,
      x_recip_non_ed_brc_id               => x_recip_non_ed_brc_id,
      x_enabled                           => x_enabled,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_relationship_cd                   => x_relationship_cd,
      x_relationship_cd_desc              => x_relationship_cd_desc,
      x_preferred_flag                    => x_preferred_flag
    );

    INSERT INTO igf_sl_cl_recipient (
      rcpt_id,
      lender_id,
      lend_non_ed_brc_id,
      guarantor_id,
      recipient_id,
      recipient_type,
      recip_non_ed_brc_id,
      enabled,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      relationship_cd,
      relationship_cd_desc,
      preferred_flag
    ) VALUES (
      new_references.rcpt_id,
      new_references.lender_id,
      new_references.lend_non_ed_brc_id,
      new_references.guarantor_id,
      new_references.recipient_id,
      new_references.recipient_type,
      new_references.recip_non_ed_brc_id,
      new_references.enabled,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.relationship_cd,
      new_references.relationship_cd_desc,
      new_references.preferred_flag
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
    x_rcpt_id                           IN     NUMBER,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_relationship_cd_desc              IN     VARCHAR2,
    x_preferred_flag                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        lender_id,
        lend_non_ed_brc_id,
        guarantor_id,
        recipient_id,
        recipient_type,
        recip_non_ed_brc_id,
        enabled,
        relationship_cd,
        relationship_cd_desc,
        preferred_flag
      FROM  igf_sl_cl_recipient
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
        (tlinfo.lender_id = x_lender_id)
        AND ((tlinfo.lend_non_ed_brc_id = x_lend_non_ed_brc_id) OR ((tlinfo.lend_non_ed_brc_id IS NULL) AND (X_lend_non_ed_brc_id IS NULL)))
        AND (tlinfo.guarantor_id = x_guarantor_id)
        AND (tlinfo.recipient_id = x_recipient_id)
        AND (tlinfo.recipient_type = x_recipient_type)
        AND ((tlinfo.recip_non_ed_brc_id = x_recip_non_ed_brc_id) OR ((tlinfo.recip_non_ed_brc_id IS NULL) AND (X_recip_non_ed_brc_id IS NULL)))
        AND (tlinfo.enabled = x_enabled)
        AND (tlinfo.relationship_cd = x_relationship_cd)
        AND (tlinfo.relationship_cd_desc = x_relationship_cd_desc)
        AND ((tlinfo.preferred_flag = x_preferred_flag) OR ((tlinfo.preferred_flag IS NULL) AND (X_preferred_flag IS NULL)))
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
    x_rcpt_id                           IN     NUMBER,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_relationship_cd_desc              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_preferred_flag                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
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
      x_rcpt_id                           => x_rcpt_id,
      x_lender_id                         => x_lender_id,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_guarantor_id                      => x_guarantor_id,
      x_recipient_id                      => x_recipient_id,
      x_recipient_type                    => x_recipient_type,
      x_recip_non_ed_brc_id               => x_recip_non_ed_brc_id,
      x_enabled                           => x_enabled,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_relationship_cd                   => x_relationship_cd,
      x_relationship_cd_desc              => x_relationship_cd_desc,
      x_preferred_flag                    => x_preferred_flag
    );

    UPDATE igf_sl_cl_recipient
      SET
        lender_id                         = new_references.lender_id,
        lend_non_ed_brc_id                = new_references.lend_non_ed_brc_id,
        guarantor_id                      = new_references.guarantor_id,
        recipient_id                      = new_references.recipient_id,
        recipient_type                    = new_references.recipient_type,
        recip_non_ed_brc_id               = new_references.recip_non_ed_brc_id,
        enabled                           = new_references.enabled,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        relationship_cd                   = x_relationship_cd,
        relationship_cd_desc              = x_relationship_cd_desc,
        preferred_flag                    = new_references.preferred_flag
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rcpt_id                           IN OUT NOCOPY NUMBER,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_relationship_cd_desc              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_preferred_flag                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_cl_recipient
      WHERE    rcpt_id                           = x_rcpt_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_rcpt_id,
        x_lender_id,
        x_lend_non_ed_brc_id,
        x_guarantor_id,
        x_recipient_id,
        x_recipient_type,
        x_recip_non_ed_brc_id,
        x_enabled,
        x_relationship_cd,
        x_relationship_cd_desc,
        x_mode,
        x_preferred_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_rcpt_id,
      x_lender_id,
      x_lend_non_ed_brc_id,
      x_guarantor_id,
      x_recipient_id,
      x_recipient_type,
      x_recip_non_ed_brc_id,
      x_enabled,
      x_relationship_cd,
      x_relationship_cd_desc,
      x_mode,
      x_preferred_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 09-NOV-2000
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

    DELETE FROM igf_sl_cl_recipient
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_cl_recipient_pkg;

/
