--------------------------------------------------------
--  DDL for Package Body IGF_AW_AWD_DIST_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_AWD_DIST_PLANS_PKG" AS
/* $Header: IGFWI59B.pls 115.5 2003/11/21 06:38:29 veramach noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_awd_dist_plans%ROWTYPE;
  new_references igf_aw_awd_dist_plans%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_awd_dist_plan_cd                  IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_awd_dist_plan_cd_desc             IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_dist_plan_method_code             IN     VARCHAR2,
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
      FROM     igf_aw_awd_dist_plans
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
    new_references.adplans_id                        := x_adplans_id;
    new_references.awd_dist_plan_cd                  := x_awd_dist_plan_cd;
    new_references.cal_type                          := x_cal_type;
    new_references.sequence_number                   := x_sequence_number;
    new_references.awd_dist_plan_cd_desc             := x_awd_dist_plan_cd_desc;
    new_references.active_flag                       := x_active_flag;
    new_references.dist_plan_method_code             := x_dist_plan_method_code;

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

    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.sequence_number = new_references.sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.cal_type,
                new_references.sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : veramach
  ||  Created On : 31-OCT-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        10-NOV-2003     FA 125 Multiple Distr methods
  ||                                  Added call to igf_aw_award_pkg.get_fk_igf_aw_awd_dist_plans
  */
  BEGIN

    igf_aw_dp_terms_pkg.get_fk_igf_aw_awd_dist_plans (
      old_references.adplans_id
    );

    igf_aw_award_pkg.get_fk_igf_aw_awd_dist_plans (
      old_references.adplans_id
    );

    igf_aw_target_grp_pkg.get_fk_igf_aw_awd_dist_plans (
      old_references.adplans_id
    );

    igf_aw_awd_frml_det_pkg.get_fk_igf_aw_awd_dist_plans (
      old_references.adplans_id
    );

  END check_child_existance;

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
                               new_references.awd_dist_plan_cd,
                               new_references.cal_type,
                               new_references.sequence_number
                              )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END check_uniqueness;

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
      FROM     igf_aw_awd_dist_plans
      WHERE   ((cal_type = x_cal_type) AND
               (sequence_number = x_sequence_number));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_ADPLANS_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;

  FUNCTION get_pk_for_validation (
    x_adplans_id                        IN     NUMBER
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
      FROM     igf_aw_awd_dist_plans
      WHERE    adplans_id = x_adplans_id
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


  FUNCTION  get_uk_for_validation(
                                  x_awd_dist_plan_cd  IN VARCHAR2,
                                  x_cal_type          IN VARCHAR2,
                                  x_sequence_number   IN NUMBER
                                 ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 06-NOV-2003
  --
  --Purpose:Validate unique key constraint on the table
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_dist_plans
      WHERE    awd_dist_plan_cd = x_awd_dist_plan_cd
      AND      cal_type         = x_cal_type
      AND      sequence_number  = x_sequence_number
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
    x_adplans_id                        IN     NUMBER,
    x_awd_dist_plan_cd                  IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_awd_dist_plan_cd_desc             IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_dist_plan_method_code             IN     VARCHAR2,
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
      x_adplans_id,
      x_awd_dist_plan_cd,
      x_cal_type,
      x_sequence_number,
      x_awd_dist_plan_cd_desc,
      x_active_flag,
      x_dist_plan_method_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.adplans_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.adplans_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adplans_id                        IN OUT NOCOPY NUMBER,
    x_awd_dist_plan_cd                  IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_awd_dist_plan_cd_desc             IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_dist_plan_method_code             IN     VARCHAR2,
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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_AWD_DIST_PLANS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_adplans_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_adplans_id                        => x_adplans_id,
      x_awd_dist_plan_cd                  => x_awd_dist_plan_cd,
      x_cal_type                          => x_cal_type,
      x_sequence_number                   => x_sequence_number,
      x_awd_dist_plan_cd_desc             => x_awd_dist_plan_cd_desc,
      x_active_flag                       => x_active_flag,
      x_dist_plan_method_code             => x_dist_plan_method_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_awd_dist_plans (
      adplans_id,
      awd_dist_plan_cd,
      cal_type,
      sequence_number,
      awd_dist_plan_cd_desc,
      active_flag,
      dist_plan_method_code,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igf_aw_awd_dist_plans_s.NEXTVAL,
      new_references.awd_dist_plan_cd,
      new_references.cal_type,
      new_references.sequence_number,
      new_references.awd_dist_plan_cd_desc,
      new_references.active_flag,
      new_references.dist_plan_method_code,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, adplans_id INTO x_rowid, x_adplans_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_awd_dist_plan_cd                  IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_awd_dist_plan_cd_desc             IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_dist_plan_method_code             IN     VARCHAR2
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
        awd_dist_plan_cd,
        cal_type,
        sequence_number,
        awd_dist_plan_cd_desc,
        active_flag,
        dist_plan_method_code
      FROM  igf_aw_awd_dist_plans
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
        (tlinfo.awd_dist_plan_cd = x_awd_dist_plan_cd)
        AND (tlinfo.cal_type = x_cal_type)
        AND (tlinfo.sequence_number = x_sequence_number)
        AND (tlinfo.awd_dist_plan_cd_desc = x_awd_dist_plan_cd_desc)
        AND (tlinfo.active_flag = x_active_flag)
        AND (tlinfo.dist_plan_method_code = x_dist_plan_method_code)
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
    x_adplans_id                        IN     NUMBER,
    x_awd_dist_plan_cd                  IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_awd_dist_plan_cd_desc             IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_dist_plan_method_code             IN     VARCHAR2,
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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_AWD_DIST_PLANS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_adplans_id                        => x_adplans_id,
      x_awd_dist_plan_cd                  => x_awd_dist_plan_cd,
      x_cal_type                          => x_cal_type,
      x_sequence_number                   => x_sequence_number,
      x_awd_dist_plan_cd_desc             => x_awd_dist_plan_cd_desc,
      x_active_flag                       => x_active_flag,
      x_dist_plan_method_code             => x_dist_plan_method_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_aw_awd_dist_plans
      SET
        awd_dist_plan_cd                  = new_references.awd_dist_plan_cd,
        cal_type                          = new_references.cal_type,
        sequence_number                   = new_references.sequence_number,
        awd_dist_plan_cd_desc             = new_references.awd_dist_plan_cd_desc,
        active_flag                       = new_references.active_flag,
        dist_plan_method_code             = new_references.dist_plan_method_code,
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
    x_adplans_id                        IN OUT NOCOPY NUMBER,
    x_awd_dist_plan_cd                  IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_awd_dist_plan_cd_desc             IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_dist_plan_method_code             IN     VARCHAR2,
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
      FROM     igf_aw_awd_dist_plans
      WHERE    adplans_id                        = x_adplans_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_adplans_id,
        x_awd_dist_plan_cd,
        x_cal_type,
        x_sequence_number,
        x_awd_dist_plan_cd_desc,
        x_active_flag,
        x_dist_plan_method_code,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_adplans_id,
      x_awd_dist_plan_cd,
      x_cal_type,
      x_sequence_number,
      x_awd_dist_plan_cd_desc,
      x_active_flag,
      x_dist_plan_method_code,
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

    DELETE FROM igf_aw_awd_dist_plans
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_awd_dist_plans_pkg;

/
