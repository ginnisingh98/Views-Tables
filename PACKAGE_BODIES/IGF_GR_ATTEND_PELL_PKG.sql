--------------------------------------------------------
--  DDL for Package Body IGF_GR_ATTEND_PELL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_ATTEND_PELL_PKG" AS
/* $Header: IGFGI21B.pls 120.0 2005/06/01 15:38:41 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_gr_attend_pell%ROWTYPE;
  new_references igf_gr_attend_pell%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_acampus_id                        IN     NUMBER,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_gr_attend_pell
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
    new_references.acampus_id                        := x_acampus_id;
    new_references.rcampus_id                        := x_rcampus_id;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.attending_pell_cd                 := x_attending_pell_cd;
    new_references.ope_cd                            := x_ope_cd;
    new_references.atd_entity_id_txt                 := x_atd_entity_id_txt;

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
  ||  Created By : nsidana@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.rcampus_id = new_references.rcampus_id)) OR
        ((new_references.rcampus_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_gr_report_pell_pkg.get_pk_for_validation (
                new_references.rcampus_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_acampus_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_attend_pell
      WHERE    acampus_id = x_acampus_id
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


  PROCEDURE get_fk_igf_gr_report_pell (
    x_rcampus_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_attend IS
      SELECT   *
      FROM     igf_gr_attend_pell
      WHERE   ((rcampus_id = x_rcampus_id));

    attend_rec cur_attend%rowtype;

  BEGIN

    OPEN cur_attend;
    FETCH cur_attend INTO attend_rec;
    IF (cur_attend%FOUND) THEN
      CLOSE cur_attend;
      IF attend_rec.atd_entity_id_txt IS NULL THEN
        fnd_message.set_name ('IGF', 'IGF_GR_CANT_DEL_REP_PELL');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      ELSE
        fnd_message.set_name ('IGF', 'IGF_GR_CANT_DEL_REP_ENT');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      RETURN;
    END IF;
    CLOSE cur_attend;

  END get_fk_igf_gr_report_pell;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_acampus_id                        IN     NUMBER,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 16-OCT-2003
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
      x_acampus_id,
      x_rcampus_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_attending_pell_cd,
      x_ope_cd,
      x_atd_entity_id_txt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.acampus_id
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
             new_references.acampus_id
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
    x_acampus_id                        IN OUT NOCOPY NUMBER,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 16-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGF_GR_ATTEND_PELL_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_acampus_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_acampus_id                        => x_acampus_id,
      x_rcampus_id                        => x_rcampus_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_attending_pell_cd                 => x_attending_pell_cd,
      x_ope_cd                            => x_ope_cd,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_gr_attend_pell (
      acampus_id,
      rcampus_id,
      ci_cal_type,
      ci_sequence_number,
      attending_pell_cd,
      ope_cd,
      atd_entity_id_txt,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igf_gr_attend_pell_s.NEXTVAL,
      new_references.rcampus_id,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      new_references.attending_pell_cd,
      new_references.ope_cd,
      new_references.atd_entity_id_txt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, acampus_id INTO x_rowid, x_acampus_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_acampus_id                        IN     NUMBER,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        rcampus_id,
        ci_cal_type,
        ci_sequence_number,
        attending_pell_cd,
        ope_cd,
        atd_entity_id_txt
      FROM  igf_gr_attend_pell
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
        (tlinfo.rcampus_id = x_rcampus_id)
        AND (tlinfo.ci_cal_type = x_ci_cal_type)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND ((tlinfo.attending_pell_cd = x_attending_pell_cd) OR ((tlinfo.attending_pell_cd IS NULL) AND (x_attending_pell_cd IS NULL)))
        AND ((tlinfo.ope_cd = x_ope_cd) OR ((tlinfo.ope_cd IS NULL) AND (X_ope_cd IS NULL)))
        AND ((tlinfo.atd_entity_id_txt = x_atd_entity_id_txt) OR ((tlinfo.atd_entity_id_txt IS NULL) AND (x_atd_entity_id_txt IS NULL)))
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
    x_acampus_id                        IN     NUMBER,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 16-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGF_GR_ATTEND_PELL_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_acampus_id                        => x_acampus_id,
      x_rcampus_id                        => x_rcampus_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_attending_pell_cd                 => x_attending_pell_cd,
      x_ope_cd                            => x_ope_cd,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_gr_attend_pell
      SET
        rcampus_id                        = new_references.rcampus_id,
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        attending_pell_cd                 = new_references.attending_pell_cd,
        ope_cd                            = new_references.ope_cd,
        atd_entity_id_txt                 = new_references.atd_entity_id_txt,
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
    x_acampus_id                        IN OUT NOCOPY NUMBER,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_gr_attend_pell
      WHERE    acampus_id                        = x_acampus_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_acampus_id,
        x_rcampus_id,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_attending_pell_cd,
        x_ope_cd,
        x_atd_entity_id_txt,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_acampus_id,
      x_rcampus_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_attending_pell_cd,
      x_ope_cd,
      x_atd_entity_id_txt,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 16-OCT-2003
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

    DELETE FROM igf_gr_attend_pell
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

  PROCEDURE check_uniqueness AS

  BEGIN

    IF new_references.attending_pell_cd IS NOT NULL THEN
      IF ( get_uk1_for_validation (
           new_references.ci_cal_type,
           new_references.ci_sequence_number,
	         new_references.attending_pell_cd
          )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      END IF;

    END IF;


    IF new_references.atd_entity_id_txt IS NOT NULL THEN
      IF ( get_uk2_for_validation (
             new_references.ci_cal_type,
             new_references.ci_sequence_number,
             new_references.atd_entity_id_txt
           )
         ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_uniqueness;

  FUNCTION get_uk1_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2
  ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
        FROM     igf_gr_attend_pell
       WHERE     NVL(attending_pell_cd,'*') = NVL(x_attending_pell_cd,'*')
         AND     ci_cal_type = x_ci_cal_type
         AND     ci_sequence_number = x_ci_sequence_number
         AND     ((l_rowid IS NULL) OR (rowid <> l_rowid));

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

  FUNCTION get_uk2_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_atd_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL
  ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
        FROM     igf_gr_attend_pell
       WHERE     NVL(atd_entity_id_txt,'*') = NVL(x_atd_entity_id_txt,'*')
         AND     ci_cal_type = x_ci_cal_type
         AND     ci_sequence_number = x_ci_sequence_number
         AND     ((l_rowid IS NULL) OR (rowid <> l_rowid));

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
  END get_uk2_for_validation ;


END igf_gr_attend_pell_pkg;

/
