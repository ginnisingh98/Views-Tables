--------------------------------------------------------
--  DDL for Package Body IGF_AW_DP_TEACH_PRDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_DP_TEACH_PRDS_PKG" AS
/* $Header: IGFWI61B.pls 120.0 2005/06/01 15:46:00 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_dp_teach_prds%ROWTYPE;
  new_references igf_aw_dp_teach_prds%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_adteach_id                        IN     NUMBER,
    x_adterms_id                        IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_tp_perct_num                      IN     NUMBER,
    x_date_offset_cd                    IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_credit_points_num                 IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 31-OCT-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_aw_dp_teach_prds
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
    new_references.adteach_id                        := x_adteach_id;
    new_references.adterms_id                        := x_adterms_id;
    new_references.tp_cal_type                       := x_tp_cal_type;
    new_references.tp_sequence_number                := x_tp_sequence_number;
    new_references.tp_perct_num                      := x_tp_perct_num;
    new_references.date_offset_cd                    := x_date_offset_cd;
    new_references.attendance_type_code              := x_attendance_type_code;
    new_references.credit_points_num                 := x_credit_points_num;

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
  ||  Created By : veramach
  ||  Created On : 31-OCT-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.adterms_id = new_references.adterms_id)) OR
        ((new_references.adterms_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_dp_terms_pkg.get_pk_for_validation (
                new_references.adterms_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    IF (((old_references.tp_cal_type = new_references.tp_cal_type) AND
       (old_references.tp_sequence_number = new_references.tp_sequence_number)) OR
       ((new_references.tp_cal_type IS NULL) OR
       (new_references.tp_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation(
                                                    new_references.tp_cal_type,
                                                    new_references.tp_sequence_number
                                                   ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.date_offset_cd = new_references.date_offset_cd)) OR
        ((new_references.date_offset_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_da_pkg.get_pk_for_validation(
                                                  new_references.date_offset_cd
                                                 ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  PROCEDURE check_uniqueness AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 06-NOV-2003
  --
  --Purpose:Call all unique key constraint functions
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  BEGIN
    IF ( get_uk_for_validation(
                               new_references.adterms_id,
                               new_references.tp_cal_type,
                               new_references.tp_sequence_number,
                               new_references.date_offset_cd
                              )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END check_uniqueness;

  FUNCTION get_pk_for_validation (
    x_adteach_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : veramach
  ||  Created On : 31-OCT-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_dp_teach_prds
      WHERE    adteach_id = x_adteach_id
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


  PROCEDURE get_fk_igf_aw_dp_terms (
    x_adterms_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 31-OCT-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_dp_teach_prds
      WHERE   ((adterms_id = x_adterms_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_ADTEACH_ADTERMS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_dp_terms;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 21-NOV-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_dp_teach_prds
      WHERE   ((tp_cal_type = x_cal_type) AND
               (tp_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_ADTEACH_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;

  PROCEDURE get_fk_igs_ca_da (
    x_dt_alias                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 21-NOV-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_dp_teach_prds
      WHERE   ((date_offset_cd = x_dt_alias));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGF_AW_ADTEACH_DA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_da;

  FUNCTION get_uk_for_validation(
                                 x_adterms_id           IN NUMBER,
                                 x_tp_cal_type          IN VARCHAR2,
                                 x_tp_sequence_number   IN NUMBER,
                                 x_date_offset_cd       IN VARCHAR2
                                ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 06-NOV-2003
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --bkkumar     27-July-2004    Bug 3783096 Added the uniqueness for
  --                            the column date_offset_cd
  -------------------------------------------------------------------
  CURSOR cur_rowid IS
    SELECT   rowid
    FROM     igf_aw_dp_teach_prds
    WHERE    adterms_id          = x_adterms_id
    AND      tp_cal_type         = x_tp_cal_type
    AND      tp_sequence_number  = x_tp_sequence_number
    AND      NVL(date_offset_cd,'*') = NVL(x_date_offset_cd,'*')
    AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

  lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN TRUE;
    ELSE
      CLOSE cur_rowid;
      RETURN FALSE;
    END IF;

  END get_uk_for_validation;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_adteach_id                        IN     NUMBER,
    x_adterms_id                        IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_tp_perct_num                      IN     NUMBER,
    x_date_offset_cd                    IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_credit_points_num                 IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 31-OCT-2003
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
      x_adteach_id,
      x_adterms_id,
      x_tp_cal_type,
      x_tp_sequence_number,
      x_tp_perct_num,
      x_date_offset_cd,
      x_attendance_type_code,
      x_credit_points_num,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.adteach_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.adteach_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adteach_id                        IN OUT NOCOPY NUMBER,
    x_adterms_id                        IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_tp_perct_num                      IN     NUMBER,
    x_date_offset_cd                    IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 31-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_DP_TEACH_PRDS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_adteach_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_adteach_id                        => x_adteach_id,
      x_adterms_id                        => x_adterms_id,
      x_tp_cal_type                       => x_tp_cal_type,
      x_tp_sequence_number                => x_tp_sequence_number,
      x_tp_perct_num                      => x_tp_perct_num,
      x_date_offset_cd                    => x_date_offset_cd,
      x_attendance_type_code              => x_attendance_type_code,
      x_credit_points_num                 => x_credit_points_num,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_dp_teach_prds (
      adteach_id,
      adterms_id,
      tp_cal_type,
      tp_sequence_number,
      tp_perct_num,
      date_offset_cd,
      attendance_type_code,
      credit_points_num,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igf_aw_dp_teach_prds_s.NEXTVAL,
      new_references.adterms_id,
      new_references.tp_cal_type,
      new_references.tp_sequence_number,
      new_references.tp_perct_num,
      new_references.date_offset_cd,
      new_references.attendance_type_code,
      new_references.credit_points_num,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, adteach_id INTO x_rowid, x_adteach_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_adteach_id                        IN     NUMBER,
    x_adterms_id                        IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_tp_perct_num                      IN     NUMBER,
    x_date_offset_cd                    IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_credit_points_num                 IN     NUMBER
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 31-OCT-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        adterms_id,
        tp_cal_type,
        tp_sequence_number,
        tp_perct_num,
        date_offset_cd,
        attendance_type_code,
        credit_points_num
      FROM  igf_aw_dp_teach_prds
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
        (tlinfo.adterms_id = x_adterms_id)
        AND (tlinfo.tp_cal_type = x_tp_cal_type)
        AND (tlinfo.tp_sequence_number = x_tp_sequence_number)
        AND (tlinfo.tp_perct_num = x_tp_perct_num)
        AND ((tlinfo.date_offset_cd = x_date_offset_cd) OR ((tlinfo.date_offset_cd IS NULL) AND (X_date_offset_cd IS NULL)))
        AND ((tlinfo.attendance_type_code = x_attendance_type_code) OR ((tlinfo.attendance_type_code IS NULL) AND (X_attendance_type_code IS NULL)))
        AND ((tlinfo.credit_points_num = x_credit_points_num) OR ((tlinfo.credit_points_num IS NULL) AND (X_credit_points_num IS NULL)))
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
    x_adteach_id                        IN     NUMBER,
    x_adterms_id                        IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_tp_perct_num                      IN     NUMBER,
    x_date_offset_cd                    IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 31-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_DP_TEACH_PRDS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_adteach_id                        => x_adteach_id,
      x_adterms_id                        => x_adterms_id,
      x_tp_cal_type                       => x_tp_cal_type,
      x_tp_sequence_number                => x_tp_sequence_number,
      x_tp_perct_num                      => x_tp_perct_num,
      x_date_offset_cd                    => x_date_offset_cd,
      x_attendance_type_code              => x_attendance_type_code,
      x_credit_points_num                 => x_credit_points_num,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_aw_dp_teach_prds
      SET
        adterms_id                        = new_references.adterms_id,
        tp_cal_type                       = new_references.tp_cal_type,
        tp_sequence_number                = new_references.tp_sequence_number,
        tp_perct_num                      = new_references.tp_perct_num,
        date_offset_cd                    = new_references.date_offset_cd,
        attendance_type_code              = new_references.attendance_type_code,
        credit_points_num                 = new_references.credit_points_num,
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
    x_adteach_id                        IN OUT NOCOPY NUMBER,
    x_adterms_id                        IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_tp_perct_num                      IN     NUMBER,
    x_date_offset_cd                    IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 31-OCT-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_dp_teach_prds
      WHERE    adteach_id                        = x_adteach_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_adteach_id,
        x_adterms_id,
        x_tp_cal_type,
        x_tp_sequence_number,
        x_tp_perct_num,
        x_date_offset_cd,
        x_attendance_type_code,
        x_credit_points_num,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_adteach_id,
      x_adterms_id,
      x_tp_cal_type,
      x_tp_sequence_number,
      x_tp_perct_num,
      x_date_offset_cd,
      x_attendance_type_code,
      x_credit_points_num,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 31-OCT-2003
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

    DELETE FROM igf_aw_dp_teach_prds
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_dp_teach_prds_pkg;

/
