--------------------------------------------------------
--  DDL for Package Body IGS_UC_EXP_QUAL_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_EXP_QUAL_SUM_PKG" AS
/* $Header: IGSXI36B.pls 115.6 2003/02/28 07:50:39 bayadav noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_exp_qual_sum%ROWTYPE;
  new_references igs_uc_exp_qual_sum%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_exp_qual_sum_id                   IN     NUMBER  ,
    x_person_id                         IN     NUMBER  ,
    x_exp_gce                           IN     NUMBER  ,
    x_exp_vce                           IN     NUMBER  ,
    x_winter_a_levels                   IN     NUMBER  ,
    x_prev_a_levels                     IN     NUMBER  ,
    x_prev_as_levels                    IN     NUMBER  ,
    x_sqa                               IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ksi                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_prev_oeq                          IN     VARCHAR2,
    x_vqi                               IN     VARCHAR2,
    x_seq_updated_date                  IN     DATE    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_EXP_QUAL_SUM
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
    new_references.exp_qual_sum_id                   := x_exp_qual_sum_id;
    new_references.person_id                         := x_person_id;
    new_references.exp_gce                           := x_exp_gce;
    new_references.exp_vce                           := x_exp_vce;
    new_references.winter_a_levels                   := x_winter_a_levels;
    new_references.prev_a_levels                     := x_prev_a_levels;
    new_references.prev_as_levels                    := x_prev_as_levels;
    new_references.sqa                               := x_sqa;
    new_references.btec                              := x_btec;
    new_references.ib                                := x_ib;
    new_references.ilc                               := x_ilc;
    new_references.ailc                              := x_ailc;
    new_references.ksi                               := x_ksi;
    new_references.roa                               := x_roa;
    new_references.manual                            := x_manual;
    new_references.oeq                               := x_oeq;
    new_references.prev_oeq                          := x_prev_oeq;
    new_references.vqi                               := x_vqi;
    new_references.seq_updated_date                  := x_seq_updated_date;

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
  ||  Created On : 01-FEB-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  rbezawad     16-Dec-2002     Changed FK relation get_fk_pe_hz_parties to get_fk_igs_pe_person w.r.t. Bug 2541370.
  ||                                 So changed the get_pk...() call from igs_pe_hz_parties_pkg to igs_pe_person_pkg.
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_exp_qual_sum_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_exp_qual_sum
      WHERE    exp_qual_sum_id = x_exp_qual_sum_id ;

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


  PROCEDURE get_fk_igs_pe_person (
    x_person_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||   rbezawad     16-Dec-2002    Changed FK relation get_fk_pe_hz_parties to
  ||                                get_fk_igs_pe_person w.r.t. Bug 2541370.
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_exp_qual_sum
      WHERE   ((person_id = x_person_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCEQS_IHP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_person;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_exp_qual_sum_id                   IN     NUMBER  ,
    x_person_id                         IN     NUMBER  ,
    x_exp_gce                           IN     NUMBER  ,
    x_exp_vce                           IN     NUMBER  ,
    x_winter_a_levels                   IN     NUMBER  ,
    x_prev_a_levels                     IN     NUMBER  ,
    x_prev_as_levels                    IN     NUMBER  ,
    x_sqa                               IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ksi                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_prev_oeq                          IN     VARCHAR2,
    x_vqi                               IN     VARCHAR2,
    x_seq_updated_date                  IN     DATE    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-FEB-2002
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
      x_exp_qual_sum_id,
      x_person_id,
      x_exp_gce,
      x_exp_vce,
      x_winter_a_levels,
      x_prev_a_levels,
      x_prev_as_levels,
      x_sqa,
      x_btec,
      x_ib,
      x_ilc,
      x_ailc,
      x_ksi,
      x_roa,
      x_manual,
      x_oeq,
      x_prev_oeq,
      x_vqi,
      x_seq_updated_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.exp_qual_sum_id
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
             new_references.exp_qual_sum_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_exp_qual_sum_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_exp_gce                           IN     NUMBER,
    x_exp_vce                           IN     NUMBER,
    x_winter_a_levels                   IN     NUMBER,
    x_prev_a_levels                     IN     NUMBER,
    x_prev_as_levels                    IN     NUMBER,
    x_sqa                               IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ksi                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_prev_oeq                          IN     VARCHAR2,
    x_vqi                               IN     VARCHAR2,
    x_seq_updated_date                  IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_exp_qual_sum
      WHERE    exp_qual_sum_id                   = x_exp_qual_sum_id;

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

    SELECT    igs_uc_exp_qual_sum_s.NEXTVAL
    INTO      x_exp_qual_sum_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_exp_qual_sum_id                   => x_exp_qual_sum_id,
      x_person_id                         => x_person_id,
      x_exp_gce                           => x_exp_gce,
      x_exp_vce                           => x_exp_vce,
      x_winter_a_levels                   => x_winter_a_levels,
      x_prev_a_levels                     => x_prev_a_levels,
      x_prev_as_levels                    => x_prev_as_levels,
      x_sqa                               => x_sqa,
      x_btec                              => x_btec,
      x_ib                                => x_ib,
      x_ilc                               => x_ilc,
      x_ailc                              => x_ailc,
      x_ksi                               => x_ksi,
      x_roa                               => x_roa,
      x_manual                            => x_manual,
      x_oeq                               => x_oeq,
      x_prev_oeq                          => x_prev_oeq,
      x_vqi                               => x_vqi,
      x_seq_updated_date                  => x_seq_updated_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_exp_qual_sum (
      exp_qual_sum_id,
      person_id,
      exp_gce,
      exp_vce,
      winter_a_levels,
      prev_a_levels,
      prev_as_levels,
      sqa,
      btec,
      ib,
      ilc,
      ailc,
      ksi,
      roa,
      manual,
      oeq,
      prev_oeq,
      vqi,
      seq_updated_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.exp_qual_sum_id,
      new_references.person_id,
      new_references.exp_gce,
      new_references.exp_vce,
      new_references.winter_a_levels,
      new_references.prev_a_levels,
      new_references.prev_as_levels,
      new_references.sqa,
      new_references.btec,
      new_references.ib,
      new_references.ilc,
      new_references.ailc,
      new_references.ksi,
      new_references.roa,
      new_references.manual,
      new_references.oeq,
      new_references.prev_oeq,
      new_references.vqi,
      new_references.seq_updated_date,
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
    x_exp_qual_sum_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_exp_gce                           IN     NUMBER,
    x_exp_vce                           IN     NUMBER,
    x_winter_a_levels                   IN     NUMBER,
    x_prev_a_levels                     IN     NUMBER,
    x_prev_as_levels                    IN     NUMBER,
    x_sqa                               IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ksi                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_prev_oeq                          IN     VARCHAR2,
    x_vqi                               IN     VARCHAR2,
    x_seq_updated_date                  IN     DATE
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        exp_gce,
        exp_vce,
        winter_a_levels,
        prev_a_levels,
        prev_as_levels,
        sqa,
        btec,
        ib,
        ilc,
        ailc,
        ksi,
        roa,
        manual,
        oeq,
        prev_oeq,
        vqi,
        seq_updated_date
      FROM  igs_uc_exp_qual_sum
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
        (tlinfo.person_id = x_person_id)
        AND ((tlinfo.exp_gce = x_exp_gce) OR ((tlinfo.exp_gce IS NULL) AND (X_exp_gce IS NULL)))
        AND ((tlinfo.exp_vce = x_exp_vce) OR ((tlinfo.exp_vce IS NULL) AND (X_exp_vce IS NULL)))
        AND ((tlinfo.winter_a_levels = x_winter_a_levels) OR ((tlinfo.winter_a_levels IS NULL) AND (X_winter_a_levels IS NULL)))
        AND ((tlinfo.prev_a_levels = x_prev_a_levels) OR ((tlinfo.prev_a_levels IS NULL) AND (X_prev_a_levels IS NULL)))
        AND ((tlinfo.prev_as_levels = x_prev_as_levels) OR ((tlinfo.prev_as_levels IS NULL) AND (X_prev_as_levels IS NULL)))
        AND ((tlinfo.sqa = x_sqa) OR ((tlinfo.sqa IS NULL) AND (X_sqa IS NULL)))
        AND ((tlinfo.btec = x_btec) OR ((tlinfo.btec IS NULL) AND (X_btec IS NULL)))
        AND ((tlinfo.ib = x_ib) OR ((tlinfo.ib IS NULL) AND (X_ib IS NULL)))
        AND ((tlinfo.ilc = x_ilc) OR ((tlinfo.ilc IS NULL) AND (X_ilc IS NULL)))
        AND ((tlinfo.ailc = x_ailc) OR ((tlinfo.ailc IS NULL) AND (X_ailc IS NULL)))
        AND ((tlinfo.ksi = x_ksi) OR ((tlinfo.ksi IS NULL) AND (X_ksi IS NULL)))
        AND ((tlinfo.roa = x_roa) OR ((tlinfo.roa IS NULL) AND (X_roa IS NULL)))
        AND ((tlinfo.manual = x_manual) OR ((tlinfo.manual IS NULL) AND (X_manual IS NULL)))
        AND ((tlinfo.oeq = x_oeq) OR ((tlinfo.oeq IS NULL) AND (X_oeq IS NULL)))
        AND ((tlinfo.prev_oeq = x_prev_oeq) OR ((tlinfo.prev_oeq IS NULL) AND (X_prev_oeq IS NULL)))
        AND ((tlinfo.vqi = x_vqi) OR ((tlinfo.vqi IS NULL) AND (X_vqi IS NULL)))
        AND (tlinfo.seq_updated_date = x_seq_updated_date)
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
    x_exp_qual_sum_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_exp_gce                           IN     NUMBER,
    x_exp_vce                           IN     NUMBER,
    x_winter_a_levels                   IN     NUMBER,
    x_prev_a_levels                     IN     NUMBER,
    x_prev_as_levels                    IN     NUMBER,
    x_sqa                               IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ksi                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_prev_oeq                          IN     VARCHAR2,
    x_vqi                               IN     VARCHAR2,
    x_seq_updated_date                  IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-FEB-2002
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
      x_exp_qual_sum_id                   => x_exp_qual_sum_id,
      x_person_id                         => x_person_id,
      x_exp_gce                           => x_exp_gce,
      x_exp_vce                           => x_exp_vce,
      x_winter_a_levels                   => x_winter_a_levels,
      x_prev_a_levels                     => x_prev_a_levels,
      x_prev_as_levels                    => x_prev_as_levels,
      x_sqa                               => x_sqa,
      x_btec                              => x_btec,
      x_ib                                => x_ib,
      x_ilc                               => x_ilc,
      x_ailc                              => x_ailc,
      x_ksi                               => x_ksi,
      x_roa                               => x_roa,
      x_manual                            => x_manual,
      x_oeq                               => x_oeq,
      x_prev_oeq                          => x_prev_oeq,
      x_vqi                               => x_vqi,
      x_seq_updated_date                  => x_seq_updated_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_exp_qual_sum
      SET
        person_id                         = new_references.person_id,
        exp_gce                           = new_references.exp_gce,
        exp_vce                           = new_references.exp_vce,
        winter_a_levels                   = new_references.winter_a_levels,
        prev_a_levels                     = new_references.prev_a_levels,
        prev_as_levels                    = new_references.prev_as_levels,
        sqa                               = new_references.sqa,
        btec                              = new_references.btec,
        ib                                = new_references.ib,
        ilc                               = new_references.ilc,
        ailc                              = new_references.ailc,
        ksi                               = new_references.ksi,
        roa                               = new_references.roa,
        manual                            = new_references.manual,
        oeq                               = new_references.oeq,
        prev_oeq                          = new_references.prev_oeq,
        vqi                               = new_references.vqi,
        seq_updated_date                  = new_references.seq_updated_date,
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
    x_exp_qual_sum_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_exp_gce                           IN     NUMBER,
    x_exp_vce                           IN     NUMBER,
    x_winter_a_levels                   IN     NUMBER,
    x_prev_a_levels                     IN     NUMBER,
    x_prev_as_levels                    IN     NUMBER,
    x_sqa                               IN     VARCHAR2,
    x_btec                              IN     VARCHAR2,
    x_ib                                IN     VARCHAR2,
    x_ilc                               IN     VARCHAR2,
    x_ailc                              IN     VARCHAR2,
    x_ksi                               IN     VARCHAR2,
    x_roa                               IN     VARCHAR2,
    x_manual                            IN     VARCHAR2,
    x_oeq                               IN     VARCHAR2,
    x_prev_oeq                          IN     VARCHAR2,
    x_vqi                               IN     VARCHAR2,
    x_seq_updated_date                  IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_exp_qual_sum
      WHERE    exp_qual_sum_id                   = x_exp_qual_sum_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_exp_qual_sum_id,
        x_person_id,
        x_exp_gce,
        x_exp_vce,
        x_winter_a_levels,
        x_prev_a_levels,
        x_prev_as_levels,
        x_sqa,
        x_btec,
        x_ib,
        x_ilc,
        x_ailc,
        x_ksi,
        x_roa,
        x_manual,
        x_oeq,
        x_prev_oeq,
        x_vqi,
        x_seq_updated_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_exp_qual_sum_id,
      x_person_id,
      x_exp_gce,
      x_exp_vce,
      x_winter_a_levels,
      x_prev_a_levels,
      x_prev_as_levels,
      x_sqa,
      x_btec,
      x_ib,
      x_ilc,
      x_ailc,
      x_ksi,
      x_roa,
      x_manual,
      x_oeq,
      x_prev_oeq,
      x_vqi,
      x_seq_updated_date,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 01-FEB-2002
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

    DELETE FROM igs_uc_exp_qual_sum
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_exp_qual_sum_pkg;

/
