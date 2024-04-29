--------------------------------------------------------
--  DDL for Package Body IGS_EN_SVS_AUTH_CAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SVS_AUTH_CAL_PKG" AS
/* $Header: IGSEI82B.pls 120.0 2006/05/02 01:43:28 amuthu noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_svs_auth_cal%ROWTYPE;
  new_references igs_en_svs_auth_cal%ROWTYPE;

    PROCEDURE  afterinsert1(
       x_sevis_auth_id IN NUMBER,
       x_cal_type IN VARCHAR2,
       x_ci_sequence_number IN NUMBER);

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_svs_auth_cal
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
    new_references.sevis_auth_id                     := x_sevis_auth_id;
    new_references.cal_type                          := x_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;

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
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.sevis_auth_id = new_references.sevis_auth_id)) OR
        ((new_references.sevis_auth_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_svs_auth_pkg.get_pk_for_validation (
                new_references.sevis_auth_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.cal_type is null) OR
         (new_references.ci_sequence_number is null))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                        new_references.cal_type,
                         new_references.ci_sequence_number
        )  THEN
     fnd_message.set_name ('FND','FORM_RECORD_DELETED');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
    END IF;



  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_sevis_auth_id                     IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_svs_auth_cal
      WHERE    sevis_auth_id = x_sevis_auth_id
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
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


  PROCEDURE get_fk_igs_en_svs_auth (
    x_sevis_auth_id                     IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_svs_auth_cal
      WHERE   ((sevis_auth_id = x_sevis_auth_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_ESAC_ESA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_svs_auth;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_en_svs_auth_cal
      WHERE  cal_type = x_cal_type
            AND  ci_sequence_number = x_ci_sequence_number  ;
    lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_ESAC_CI_FK');
      Igs_Ge_Msg_Stack.ADD;
      CLOSE cur_rowid;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_ca_inst;

  PROCEDURE beforedelete1(
    x_sevis_auth_id                     IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) AS

    CURSOR c_auth IS
    SELECT eeo.ELGB_OVERRIDE_ID, esa.person_id
    FROM IGS_EN_SVS_AUTH esa,
         IGS_EN_ELGB_OVR eeo
    WHERE esa.SEVIS_AUTH_ID = x_sevis_auth_id
    AND esa.person_id = eeo.person_id
    AND eeo.cal_type = x_cal_type
    AND eeo.ci_sequence_number = x_ci_sequence_number;

    CURSOR c_another_auth (cp_person_id HZ_PARTIES.PARTY_ID%TYPE) IS
      SELECT 'X'
      FROM IGS_EN_SVS_AUTH_CAL sac, IGS_EN_SVS_AUTH esa
      WHERE esa.SEVIS_AUTH_ID <> x_sevis_auth_id
      AND esa.person_id = cp_person_id
      AND esa.sevis_auth_id = sac.sevis_auth_id
      AND sac.cal_type = x_cal_type
      AND sac.ci_sequence_number = x_ci_sequence_number ;

    CURSOR c_eos (cp_elgb_override_id IGS_EN_ELGB_OVR.ELGB_OVERRIDE_ID%TYPE) IS
    SELECT eos.rowid row_id, step_override_type, step_override_limit
    FROM IGS_EN_ELGB_OVR_STEP eos
    WHERE elgb_override_id = cp_elgb_override_id
    AND STEP_OVERRIDE_TYPE IN ('FMIN_CRDT','FATD_TYPE');

    l_elgb_override_id IGS_EN_ELGB_OVR.ELGB_OVERRIDE_ID%TYPE;
    l_step_override_type  IGS_EN_ELGB_OVR_STEP.step_override_type%TYPE;
    l_step_override_limit IGS_EN_ELGB_OVR_STEP.step_override_limit%TYPE;
    l_person_id HZ_PARTIES.PARTY_ID%TYPE;
    l_dummy VARCHAR2(10);
    l_rowid VARCHAR2(25);

  BEGIN

    OPEN c_auth;
    FETCH c_auth INTO l_elgb_override_id, l_person_id;
    IF c_auth%FOUND THEN
      CLOSE c_auth;

        OPEN c_eos(l_elgb_override_id);
        FETCH c_eos INTO l_rowid,l_step_override_type,l_step_override_limit;
        CLOSE c_eos;

        IF g_s_last_ovr_step IS NULL THEN
          g_s_last_ovr_step := l_step_override_type;
          g_s_last_step_limit := l_step_override_limit;
        END IF;

        OPEN c_another_auth(l_person_id);
        FETCH c_another_auth INTO l_dummy;
        IF c_another_auth%NOTFOUND THEN
          CLOSE c_another_auth;
          FOR c_eos_rec in c_eos(l_elgb_override_id) LOOP
            IGS_EN_ELGB_OVR_STEP_PKG.DELETE_ROW(c_eos_rec.row_id);
          END LOOP;
        ELSE
          CLOSE c_another_auth;
        END IF;

    ELSE
      CLOSE c_auth;
    END IF;

  END beforedelete1;



  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
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
      x_sevis_auth_id,
      x_cal_type,
      x_ci_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.sevis_auth_id,
             new_references.cal_type,
             new_references.ci_sequence_number
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
             new_references.sevis_auth_id,
             new_references.cal_type,
             new_references.ci_sequence_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (p_action = 'DELETE') THEN
      beforedelete1(
       old_references.sevis_auth_id,
       old_references.cal_type,
       old_references.ci_sequence_number);
    END IF;

  END before_dml;

  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    IF (p_action = 'INSERT') THEN
      afterinsert1(
       new_references.sevis_auth_id,
       new_references.cal_type,
       new_references.ci_sequence_number);
    END IF;

  END after_dml;

  PROCEDURE  afterinsert1(
       x_sevis_auth_id IN NUMBER,
       x_cal_type IN VARCHAR2,
       x_ci_sequence_number IN NUMBER) IS

    CURSOR c_step_exists IS
    SELECT 'X'
    FROM IGS_EN_ELGB_OVR_STEP eos,
         IGS_EN_ELGB_OVR eo,
         IGS_EN_SVS_AUTH esa
    WHERE esa.sevis_auth_id = x_sevis_auth_id
    AND esa.person_id = eo.person_id
    AND eo.cal_type = x_cal_type
    AND eo.CI_SEQUENCE_NUMBER = x_ci_sequence_number
    AND eo.ELGB_OVERRIDE_ID = eos.ELGB_OVERRIDE_ID
    AND eos.STEP_OVERRIDE_TYPE IN ('FMIN_CRDT','FATD_TYPE');

    CURSOR c_ovr IS
    SELECT  eo.ELGB_OVERRIDE_ID
    FROM IGS_EN_SVS_AUTH esa, IGS_EN_ELGB_OVR eo
    WHERE esa.sevis_auth_id = x_sevis_auth_id
    AND esa.person_id = eo.person_id
    AND eo.cal_type = x_cal_type
    AND eo.ci_sequence_number = X_ci_sequence_number;


    CURSOR c_earliest_cal IS
    SELECT  cal_type, ci_sequence_number
    FROM IGS_EN_SVS_AUTH_CAL
    WHERE sevis_auth_id = x_sevis_auth_id
    ORDER BY CREATION_DATE ASC;

    CURSOR c_person_id IS
    SELECT person_id
    FROM igs_en_svs_auth
    WHERE sevis_auth_id = x_sevis_auth_id;


    CURSOR c_ovr_step (cp_person_id hz_parties.party_id%TYPE,
                       cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                       cp_ci_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE)IS
    SELECT STEP_OVERRIDE_TYPE, STEP_OVERRIDE_LIMIT
    FROM IGS_EN_ELGB_OVR_STEP eos, IGS_EN_ELGB_OVR eo
    WHERE eo.elgb_override_id = eos.elgb_override_id
    AND eo.person_id = cp_person_id
    AND eo.cal_type = cp_cal_type
    AND eo.ci_sequence_number = cp_ci_sequence_number
    AND STEP_OVERRIDE_TYPE IN ('FMIN_CRDT','FATD_TYPE')
    ORDER BY eos.CREATION_DATE ASC;


    l_cal_type IGS_CA_INST.CAL_TYPE%TYPE;
    l_ci_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    l_person_id hz_parties.party_id%TYPE;
    l_elgb_override_id igs_en_elgb_ovr.elgb_override_id%TYPE;
    l_step IGS_EN_ELGB_OVR_STEP.STEP_OVERRIDE_TYPE%TYPE;
    l_limit IGS_EN_ELGB_OVR_STEP.STEP_OVERRIDE_LIMIT%TYPE;

    l_rowid            VARCHAR2(25);
    l_elgb_ovr_step_id igs_en_elgb_ovr_step.elgb_ovr_step_id%TYPE;

    l_dummy VARCHAR2(1);


  BEGIN

    OPEN c_person_id;
    FETCH c_person_id INTO l_person_id;
    CLOSE c_person_id;

    OPEN c_step_exists;
    FETCH c_step_exists INTO l_dummy;

    IF c_step_exists%NOTFOUND THEN
      CLOSE c_step_exists;

      OPEN c_ovr;
      FETCH c_ovr INTO l_elgb_override_id;
      IF c_ovr%NOTFOUND THEN
          l_rowid := NULL;
          l_elgb_override_id := NULL;

          igs_en_elgb_ovr_pkg.insert_row (
            x_mode                              => 'R',
            x_rowid                             => l_rowid,
            x_elgb_override_id                  => l_elgb_override_id,
            x_person_id                         => l_person_id,
            x_cal_type                          => x_cal_type,
            x_ci_sequence_number                => x_ci_sequence_number
          );

      END IF;
      CLOSE c_ovr;

      OPEN c_earliest_cal;
      FETCH c_earliest_cal INTO l_cal_type, l_ci_sequence_number;
      IF c_earliest_cal%NOTFOUND THEN
        l_step := g_s_last_ovr_step;
        l_limit := g_s_last_step_limit;
      ELSE

        OPEN c_ovr_step(l_person_id,l_cal_type, l_ci_sequence_number );
        FETCH c_ovr_step INTO l_step,l_limit;
        IF c_ovr_step%NOTFOUND THEN
          l_step := g_s_last_ovr_step;
          l_limit := g_s_last_step_limit;
        END IF;
        CLOSE c_ovr_step;
      END IF;
      CLOSE c_earliest_cal;


      IF l_step IS NOT NULL THEN

        l_rowid := NULL;
        l_elgb_ovr_step_id := NULL;

        igs_en_elgb_ovr_step_pkg.insert_row (
          x_mode                              => 'R',
          x_rowid                             => l_rowid,
          x_elgb_ovr_step_id                  => l_elgb_ovr_step_id,
          x_elgb_override_id                  => l_elgb_override_id,
          x_step_override_type                => l_step,
          x_step_override_dt                  => trunc(SYSDATE),
          x_step_override_limit               => l_limit
        );
      ELSE
        fnd_message.set_name('IGS', 'IGS_EN_CANNOT_FIND_STEP');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSE
      CLOSE c_step_exists;
    END IF;

    g_s_last_ovr_step := NULL;
    g_s_last_step_limit := NULL;


  END afterinsert1;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_SVS_AUTH_CAL_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sevis_auth_id                     => x_sevis_auth_id,
      x_cal_type                          => x_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_svs_auth_cal (
      sevis_auth_id,
      cal_type,
      ci_sequence_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.sevis_auth_id,
      new_references.cal_type,
      new_references.ci_sequence_number,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

      after_dml(
        p_action => 'INSERT',
        x_rowid => x_rowid
      );
  EXCEPTION
    WHEN OTHERS THEN
      g_s_last_ovr_step := NULL;
      g_s_last_step_limit := NULL;
      RAISE;
  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        rowid
      FROM  igs_en_svs_auth_cal
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
  ||  Created By :
  ||  Created On : 08-MAR-2006
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

    DELETE FROM igs_en_svs_auth_cal
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

      after_dml(
        p_action => 'DELETE',
        x_rowid => x_rowid
      );


  END delete_row;


END igs_en_svs_auth_cal_pkg;

/
