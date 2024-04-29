--------------------------------------------------------
--  DDL for Package Body IGS_EN_TIMESLOT_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_TIMESLOT_CONF_PKG" AS
/* $Header: IGSEI43B.pls 115.5 2002/11/28 23:42:50 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_timeslot_conf%ROWTYPE;
  new_references igs_en_timeslot_conf%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_en_timeslot_conf_id           IN     NUMBER      DEFAULT NULL,
    x_timeslot_name                     IN     VARCHAR2    DEFAULT NULL,
    x_start_dt_alias                    IN     VARCHAR2    DEFAULT NULL,
    x_end_dt_alias                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_org_id 				IN     NUMBER 	   DEFAULT NULL
  ) AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_TIMESLOT_CONF
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) AND l_rowid IS NOT NULL THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.igs_en_timeslot_conf_id           := x_igs_en_timeslot_conf_id;
    new_references.timeslot_name                     := x_timeslot_name;
    new_references.start_dt_alias                    := x_start_dt_alias;
    new_references.end_dt_alias                      := x_end_dt_alias;

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
    new_references.org_id := x_org_id;
  END set_column_values;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.timeslot_name
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    IF ( get_uk2_for_validation (
           new_references.start_dt_alias,
           new_references.end_dt_alias
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE Check_Child_Existance AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IGS_EN_TIMESLOT_PARA_PKG.GET_FK_IGS_EN_TIMESLOT_CONF (
     old_references.timeslot_name
      );

  END Check_Child_Existance;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.start_dt_alias = new_references.start_dt_alias)) OR
        ((new_references.start_dt_alias IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_da_pkg.get_pk_for_validation (
                new_references.start_dt_alias
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.end_dt_alias = new_references.end_dt_alias)) OR
        ((new_references.end_dt_alias IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_da_pkg.get_pk_for_validation (
                new_references.end_dt_alias
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_igs_en_timeslot_conf_id           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_en_timeslot_conf
      WHERE    igs_en_timeslot_conf_id = x_igs_en_timeslot_conf_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;

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
    x_timeslot_name                     IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_en_timeslot_conf
      WHERE    timeslot_name = x_timeslot_name
      AND      ((l_rowid IS NULL) OR (ROWID <> l_rowid));

    lv_rowid cur_rowid%ROWTYPE;

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


  FUNCTION get_uk2_for_validation (
    x_start_dt_alias                    IN     VARCHAR2,
    x_end_dt_alias                      IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_en_timeslot_conf
      WHERE    start_dt_alias = x_start_dt_alias
      AND      end_dt_alias = x_end_dt_alias
      AND      ((l_rowid IS NULL) OR (ROWID <> l_rowid));

    lv_rowid cur_rowid%ROWTYPE;

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

  END get_uk2_for_validation ;


  PROCEDURE get_fk_igs_ca_da (
    x_dt_alias                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_en_timeslot_conf
      WHERE   ((start_dt_alias = x_dt_alias))
      OR      ((end_dt_alias = x_dt_alias));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_da;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_en_timeslot_conf_id           IN     NUMBER      DEFAULT NULL,
    x_timeslot_name                     IN     VARCHAR2    DEFAULT NULL,
    x_start_dt_alias                    IN     VARCHAR2    DEFAULT NULL,
    x_end_dt_alias                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_org_id 				IN     NUMBER 	   DEFAULT NULL
  ) AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
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
      x_igs_en_timeslot_conf_id,
      x_timeslot_name,
      x_start_dt_alias,
      x_end_dt_alias,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.igs_en_timeslot_conf_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
       Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.igs_en_timeslot_conf_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_timeslot_conf_id           IN OUT NOCOPY  NUMBER,
    x_timeslot_name                     IN     VARCHAR2,
    x_start_dt_alias                    IN     VARCHAR2,
    x_end_dt_alias                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_org_id 				IN 	NUMBER
  ) AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pradhakr	      23-Jul-2002     Assigned igs_ge_gen_003.get_org_id to x_org_id in before_dml
  ||				      as part of bug# 2457599.
  */
    CURSOR c IS
      SELECT   ROWID
      FROM     igs_en_timeslot_conf
      WHERE    igs_en_timeslot_conf_id           = x_igs_en_timeslot_conf_id;

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
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
--Select Next value from sequnce IGS_EN_TIMESLOT_CONF_S for the Primary key to be inserted.
   SELECT IGS_EN_TIMESLOT_CONF_S.NEXTVAL INTO x_igs_en_timeslot_conf_id FROM DUAL;

   before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_igs_en_timeslot_conf_id           => x_igs_en_timeslot_conf_id,
      x_timeslot_name                     => x_timeslot_name,
      x_start_dt_alias                    => x_start_dt_alias,
      x_end_dt_alias                      => x_end_dt_alias,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_org_id  			  => igs_ge_gen_003.get_org_id
    );

    INSERT INTO igs_en_timeslot_conf (
      igs_en_timeslot_conf_id,
      timeslot_name,
      start_dt_alias,
      end_dt_alias,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id
    ) VALUES (
      new_references.igs_en_timeslot_conf_id,
      new_references.timeslot_name,
      new_references.start_dt_alias,
      new_references.end_dt_alias,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      NEW_REFERENCES.org_id
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
    x_igs_en_timeslot_conf_id           IN     NUMBER,
    x_timeslot_name                     IN     VARCHAR2,
    x_start_dt_alias                    IN     VARCHAR2,
    x_end_dt_alias                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        timeslot_name,
        start_dt_alias,
        end_dt_alias
      FROM  igs_en_timeslot_conf
      WHERE ROWID = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.timeslot_name = x_timeslot_name)
        AND (tlinfo.start_dt_alias = x_start_dt_alias)
        AND (tlinfo.end_dt_alias = x_end_dt_alias)
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_en_timeslot_conf_id           IN     NUMBER,
    x_timeslot_name                     IN     VARCHAR2,
    x_start_dt_alias                    IN     VARCHAR2,
    x_end_dt_alias                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
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
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_igs_en_timeslot_conf_id           => x_igs_en_timeslot_conf_id,
      x_timeslot_name                     => x_timeslot_name,
      x_start_dt_alias                    => x_start_dt_alias,
      x_end_dt_alias                      => x_end_dt_alias,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_timeslot_conf
      SET
        timeslot_name                     = new_references.timeslot_name,
        start_dt_alias                    = new_references.start_dt_alias,
        end_dt_alias                      = new_references.end_dt_alias,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_timeslot_conf_id           IN OUT NOCOPY    NUMBER,
    x_timeslot_name                     IN     VARCHAR2,
    x_start_dt_alias                    IN     VARCHAR2,
    x_end_dt_alias                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
     x_org_id IN NUMBER
  ) AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   ROWID
      FROM     igs_en_timeslot_conf
      WHERE    igs_en_timeslot_conf_id           = x_igs_en_timeslot_conf_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_igs_en_timeslot_conf_id,
        x_timeslot_name,
        x_start_dt_alias,
        x_end_dt_alias,
        x_mode,
        x_org_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_igs_en_timeslot_conf_id,
      x_timeslot_name,
      x_start_dt_alias,
      x_end_dt_alias,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sjalasut
  ||  Created On : 13-DEC-2000
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

    DELETE FROM igs_en_timeslot_conf
    WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END Igs_En_Timeslot_Conf_Pkg;

/
