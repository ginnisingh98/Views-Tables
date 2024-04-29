--------------------------------------------------------
--  DDL for Package Body IGS_PS_AWD_HNR_BASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_AWD_HNR_BASE_PKG" AS
/* $Header: IGSPI3LB.pls 115.2 2003/10/21 08:41:12 nalkumar noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_awd_hnr_base%ROWTYPE;
  new_references igs_ps_awd_hnr_base%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_awd_hnr_basis_id                  IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_weighted_average                  IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 17-OCT-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ps_awd_hnr_base
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
    new_references.awd_hnr_basis_id                  := x_awd_hnr_basis_id;
    new_references.award_cd                          := x_award_cd;
    new_references.unit_level                        := x_unit_level;
    new_references.weighted_average                  := x_weighted_average;
    new_references.stat_type                         := x_stat_type;
    new_references.s_stat_element                    := x_s_stat_element;
    new_references.timeframe                         := x_timeframe;

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

  PROCEDURE beforeinsertupdate(p_rowid IN VARCHAR2 DEFAULT NULL) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 17-OCT-2003
  ||  Purpose : To check duplication of the unit Level in a Honors Level.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_chk_prof IS
    SELECT 'x'
    FROM igs_ps_awd_hnr_base
    WHERE award_cd   = new_references.award_cd;
    rec_chk_prof cur_chk_prof %ROWTYPE;

    CURSOR cur_chk_unk_unt_lvl IS
    SELECT 'x'
    FROM igs_ps_awd_hnr_base
    WHERE unit_level = new_references.unit_level AND
          award_cd   = new_references.award_cd AND
          (p_rowid IS NULL OR rowid <> p_rowid);
    rec_chk_unk_unt_lvl cur_chk_unk_unt_lvl%ROWTYPE;
  BEGIN
    IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'Y' AND p_rowid IS NULL THEN
      OPEN cur_chk_prof;
      FETCH cur_chk_prof INTO rec_chk_prof;
      IF cur_chk_prof%FOUND THEN
        CLOSE cur_chk_prof;
        FND_MESSAGE.SET_NAME ('FND', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      CLOSE cur_chk_prof;
    END IF;
    OPEN cur_chk_unk_unt_lvl;
    FETCH cur_chk_unk_unt_lvl INTO rec_chk_unk_unt_lvl;
    IF cur_chk_unk_unt_lvl%FOUND THEN
      CLOSE cur_chk_unk_unt_lvl;
      FND_MESSAGE.SET_NAME ('FND', 'IGS_PR_AWD_UL_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE cur_chk_unk_unt_lvl;


  END beforeinsertupdate;



  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 17-OCT-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.award_cd = new_references.award_cd)) OR
        ((new_references.award_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_awd_pkg.get_pk_for_validation (
                new_references.award_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_level = new_references.unit_level)) OR
        ((new_references.unit_level IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_level_pkg.get_pk_for_validation (
                new_references.unit_level
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.stat_type = new_references.stat_type) AND
         (old_references.s_stat_element = new_references.s_stat_element)) OR
        ((new_references.stat_type IS NULL) OR
         (new_references.s_stat_element IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pr_sta_type_ele_pkg.get_pk_for_validation (
                new_references.stat_type,
                new_references.s_stat_element
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_awd_hnr_basis_id                  IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 17-OCT-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_awd_hnr_base
      WHERE    awd_hnr_basis_id = x_awd_hnr_basis_id
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

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_awd_hnr_basis_id                  IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_weighted_average                  IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 17-OCT-2003
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
      x_awd_hnr_basis_id,
      x_award_cd,
      x_unit_level,
      x_weighted_average,
      x_stat_type,
      x_s_stat_element,
      x_timeframe,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.awd_hnr_basis_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      beforeinsertupdate(x_rowid);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      beforeinsertupdate(x_rowid);
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.awd_hnr_basis_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      beforeinsertupdate(x_rowid);
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_awd_hnr_basis_id                  IN OUT NOCOPY NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_weighted_average                  IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 17-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_PS_AWD_HNR_BASE_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_awd_hnr_basis_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_awd_hnr_basis_id                  => x_awd_hnr_basis_id,
      x_award_cd                          => x_award_cd,
      x_unit_level                        => x_unit_level,
      x_weighted_average                  => x_weighted_average,
      x_stat_type                         => x_stat_type,
      x_s_stat_element                    => x_s_stat_element,
      x_timeframe                         => x_timeframe,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ps_awd_hnr_base (
      awd_hnr_basis_id,
      award_cd,
      unit_level,
      weighted_average,
      stat_type,
      s_stat_element,
      timeframe,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_ps_awd_hnr_base_s.NEXTVAL,
      new_references.award_cd,
      new_references.unit_level,
      new_references.weighted_average,
      new_references.stat_type,
      new_references.s_stat_element,
      new_references.timeframe,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, awd_hnr_basis_id INTO x_rowid, x_awd_hnr_basis_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_awd_hnr_basis_id                  IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_weighted_average                  IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 17-OCT-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        award_cd,
        unit_level,
        weighted_average,
        stat_type,
        s_stat_element,
        timeframe
      FROM  igs_ps_awd_hnr_base
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
        (tlinfo.award_cd = x_award_cd)
        AND ((tlinfo.unit_level = x_unit_level) OR ((tlinfo.unit_level IS NULL) AND (X_unit_level IS NULL)))
        AND ((tlinfo.weighted_average = x_weighted_average) OR ((tlinfo.weighted_average IS NULL) AND (X_weighted_average IS NULL)))
        AND ((tlinfo.stat_type = x_stat_type) OR ((tlinfo.stat_type IS NULL) AND (X_stat_type IS NULL)))
        AND ((tlinfo.s_stat_element = x_s_stat_element) OR ((tlinfo.s_stat_element IS NULL) AND (X_s_stat_element IS NULL)))
        AND ((tlinfo.timeframe = x_timeframe) OR ((tlinfo.timeframe IS NULL) AND (X_timeframe IS NULL)))
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
    x_awd_hnr_basis_id                  IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_weighted_average                  IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 17-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_PS_AWD_HNR_BASE_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_awd_hnr_basis_id                  => x_awd_hnr_basis_id,
      x_award_cd                          => x_award_cd,
      x_unit_level                        => x_unit_level,
      x_weighted_average                  => x_weighted_average,
      x_stat_type                         => x_stat_type,
      x_s_stat_element                    => x_s_stat_element,
      x_timeframe                         => x_timeframe,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ps_awd_hnr_base
      SET
        award_cd                          = new_references.award_cd,
        unit_level                        = new_references.unit_level,
        weighted_average                  = new_references.weighted_average,
        stat_type                         = new_references.stat_type,
        s_stat_element                    = new_references.s_stat_element,
        timeframe                         = new_references.timeframe,
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
    x_awd_hnr_basis_id                  IN OUT NOCOPY NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_weighted_average                  IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_s_stat_element                    IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 17-OCT-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ps_awd_hnr_base
      WHERE    awd_hnr_basis_id                  = x_awd_hnr_basis_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_awd_hnr_basis_id,
        x_award_cd,
        x_unit_level,
        x_weighted_average,
        x_stat_type,
        x_s_stat_element,
        x_timeframe,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_awd_hnr_basis_id,
      x_award_cd,
      x_unit_level,
      x_weighted_average,
      x_stat_type,
      x_s_stat_element,
      x_timeframe,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 17-OCT-2003
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

    DELETE FROM igs_ps_awd_hnr_base
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ps_awd_hnr_base_pkg;

/
