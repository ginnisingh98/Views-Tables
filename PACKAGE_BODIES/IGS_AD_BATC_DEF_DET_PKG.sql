--------------------------------------------------------
--  DDL for Package Body IGS_AD_BATC_DEF_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_BATC_DEF_DET_PKG" AS
/* $Header: IGSAIE8B.pls 115.7 2003/09/01 07:44:25 pbondugu noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_batc_def_det_all%ROWTYPE;
  new_references igs_ad_batc_def_det_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_acad_cal_type                     IN     VARCHAR2    DEFAULT NULL,
    x_acad_ci_sequence_number           IN     NUMBER      DEFAULT NULL,
    x_adm_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_adm_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_admission_cat                     IN     VARCHAR2    DEFAULT NULL,
    x_s_admission_process_type          IN     VARCHAR2    DEFAULT NULL,
    x_decision_make_id                  IN     NUMBER      DEFAULT NULL,
    x_decision_date                     IN     DATE        DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER      DEFAULT NULL,
    x_pending_reason_id                 IN     NUMBER      DEFAULT NULL,
    x_offer_dt                          IN     DATE        DEFAULT NULL,
    x_offer_response_dt                 IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 14-AUG-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_BATC_DEF_DET_ALL
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
    new_references.batch_id                          := x_batch_id;
    new_references.description                       := x_description;
    new_references.acad_cal_type                     := x_acad_cal_type;
    new_references.acad_ci_sequence_number           := x_acad_ci_sequence_number;
    new_references.adm_cal_type                      := x_adm_cal_type;
    new_references.adm_ci_sequence_number            := x_adm_ci_sequence_number;
    new_references.admission_cat                     := x_admission_cat;
    new_references.s_admission_process_type          := x_s_admission_process_type;
    new_references.decision_make_id                  := x_decision_make_id;
    new_references.decision_date                     := TRUNC(x_decision_date);
    new_references.decision_reason_id                := x_decision_reason_id;
    new_references.pending_reason_id                 := x_pending_reason_id;
    new_references.offer_dt                          := TRUNC(x_offer_dt);
    new_references.offer_response_dt                 := TRUNC(x_offer_response_dt);

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


 FUNCTION Get_PK_For_Validation (
    x_batch_id IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_BATC_DEF_DET_ALL
      WHERE    batch_id = x_batch_id
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
     IF (cur_rowid%FOUND) THEN
       Close cur_rowid;
       Return (TRUE);
	 ELSE
       Close cur_rowid;
       Return (FALSE);
 END IF;

  END Get_PK_For_Validation;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_acad_cal_type                     IN     VARCHAR2    DEFAULT NULL,
    x_acad_ci_sequence_number           IN     NUMBER      DEFAULT NULL,
    x_adm_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_adm_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_admission_cat                     IN     VARCHAR2    DEFAULT NULL,
    x_s_admission_process_type          IN     VARCHAR2    DEFAULT NULL,
    x_decision_make_id                  IN     NUMBER      DEFAULT NULL,
    x_decision_date                     IN     DATE        DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER      DEFAULT NULL,
    x_pending_reason_id                 IN     NUMBER      DEFAULT NULL,
    x_offer_dt                          IN     DATE        DEFAULT NULL,
    x_offer_response_dt                 IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 14-AUG-2001
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
      x_batch_id,
      x_description,
      x_acad_cal_type,
      x_acad_ci_sequence_number,
      x_adm_cal_type,
      x_adm_ci_sequence_number,
      x_admission_cat,
      x_s_admission_process_type,
      x_decision_make_id,
      x_decision_date,
      x_decision_reason_id,
      x_pending_reason_id,
      x_offer_dt,
      x_offer_response_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
      	   new_references.batch_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
      	   new_references.batch_id
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
    x_batch_id                          IN OUT NOCOPY NUMBER,
    x_description                       IN     VARCHAR2,
    x_acad_cal_type                     IN     VARCHAR2,
    x_acad_ci_sequence_number           IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_ci_sequence_number            IN     NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 14-AUG-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_batc_def_det_all
      WHERE    batch_id = x_batch_id;

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

    new_references.org_id := igs_ge_gen_003.get_org_id;

    x_batch_id := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_batch_id                          => x_batch_id,
      x_description                       => x_description,
      x_acad_cal_type                     => x_acad_cal_type,
      x_acad_ci_sequence_number           => x_acad_ci_sequence_number,
      x_adm_cal_type                      => x_adm_cal_type,
      x_adm_ci_sequence_number            => x_adm_ci_sequence_number,
      x_admission_cat                     => x_admission_cat,
      x_s_admission_process_type          => x_s_admission_process_type,
      x_decision_make_id                  => x_decision_make_id,
      x_decision_date                     => x_decision_date,
      x_decision_reason_id                => x_decision_reason_id,
      x_pending_reason_id                 => x_pending_reason_id,
      x_offer_dt                          => x_offer_dt,
      x_offer_response_dt                 => x_offer_response_dt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ad_batc_def_det_all (
      batch_id,
      description,
      acad_cal_type,
      acad_ci_sequence_number,
      adm_cal_type,
      adm_ci_sequence_number,
      admission_cat,
      s_admission_process_type,
      decision_make_id,
      decision_date,
      decision_reason_id,
      pending_reason_id,
      offer_dt,
      offer_response_dt,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_ad_batc_def_det_s.NEXTVAL,
      new_references.description,
      new_references.acad_cal_type,
      new_references.acad_ci_sequence_number,
      new_references.adm_cal_type,
      new_references.adm_ci_sequence_number,
      new_references.admission_cat,
      new_references.s_admission_process_type,
      new_references.decision_make_id,
      new_references.decision_date,
      new_references.decision_reason_id,
      new_references.pending_reason_id,
      new_references.offer_dt,
      new_references.offer_response_dt,
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    )RETURNING batch_id INTO x_batch_id;

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
    x_batch_id                          IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_acad_cal_type                     IN     VARCHAR2,
    x_acad_ci_sequence_number           IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_ci_sequence_number            IN     NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 14-AUG-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        batch_id,
        description,
        acad_cal_type,
        acad_ci_sequence_number,
        adm_cal_type,
        adm_ci_sequence_number,
        admission_cat,
        s_admission_process_type,
        decision_make_id,
        decision_date,
        decision_reason_id,
        pending_reason_id,
        offer_dt,
        offer_response_dt
      FROM  igs_ad_batc_def_det_all
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
        (tlinfo.batch_id = x_batch_id)
        AND ((tlinfo.description = x_description) OR ((tlinfo.description IS NULL) AND (X_description IS NULL)))
        AND (tlinfo.acad_cal_type = x_acad_cal_type)
        AND (tlinfo.acad_ci_sequence_number = x_acad_ci_sequence_number)
        AND (tlinfo.adm_cal_type = x_adm_cal_type)
        AND (tlinfo.adm_ci_sequence_number = x_adm_ci_sequence_number)
        AND (tlinfo.admission_cat = x_admission_cat)
        AND (tlinfo.s_admission_process_type = x_s_admission_process_type)
        AND ((tlinfo.decision_make_id = x_decision_make_id) OR ((tlinfo.decision_make_id IS NULL) AND (X_decision_make_id IS NULL)))
        AND ((TRUNC(tlinfo.decision_date) = TRUNC(x_decision_date)) OR ((tlinfo.decision_date IS NULL) AND (X_decision_date IS NULL)))
        AND ((tlinfo.decision_reason_id = x_decision_reason_id) OR ((tlinfo.decision_reason_id IS NULL) AND (X_decision_reason_id IS NULL)))
        AND ((tlinfo.pending_reason_id = x_pending_reason_id) OR ((tlinfo.pending_reason_id IS NULL) AND (X_pending_reason_id IS NULL)))
        AND ((TRUNC(tlinfo.offer_dt) = TRUNC(x_offer_dt)) OR ((tlinfo.offer_dt IS NULL) AND (X_offer_dt IS NULL)))
        AND ((TRUNC(tlinfo.offer_response_dt) = TRUNC(x_offer_response_dt)) OR ((tlinfo.offer_response_dt IS NULL) AND (X_offer_response_dt IS NULL)))
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
    x_batch_id                          IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_acad_cal_type                     IN     VARCHAR2,
    x_acad_ci_sequence_number           IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_ci_sequence_number            IN     NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 14-AUG-2001
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
      x_batch_id                          => x_batch_id,
      x_description                       => x_description,
      x_acad_cal_type                     => x_acad_cal_type,
      x_acad_ci_sequence_number           => x_acad_ci_sequence_number,
      x_adm_cal_type                      => x_adm_cal_type,
      x_adm_ci_sequence_number            => x_adm_ci_sequence_number,
      x_admission_cat                     => x_admission_cat,
      x_s_admission_process_type          => x_s_admission_process_type,
      x_decision_make_id                  => x_decision_make_id,
      x_decision_date                     => x_decision_date,
      x_decision_reason_id                => x_decision_reason_id,
      x_pending_reason_id                 => x_pending_reason_id,
      x_offer_dt                          => x_offer_dt,
      x_offer_response_dt                 => x_offer_response_dt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ad_batc_def_det_all
      SET
        batch_id                          = new_references.batch_id,
        description                       = new_references.description,
        acad_cal_type                     = new_references.acad_cal_type,
        acad_ci_sequence_number           = new_references.acad_ci_sequence_number,
        adm_cal_type                      = new_references.adm_cal_type,
        adm_ci_sequence_number            = new_references.adm_ci_sequence_number,
        admission_cat                     = new_references.admission_cat,
        s_admission_process_type          = new_references.s_admission_process_type,
        decision_make_id                  = new_references.decision_make_id,
        decision_date                     = new_references.decision_date,
        decision_reason_id                = new_references.decision_reason_id,
        pending_reason_id                 = new_references.pending_reason_id,
        offer_dt                          = new_references.offer_dt,
        offer_response_dt                 = new_references.offer_response_dt,
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
    x_batch_id                          IN OUT NOCOPY NUMBER,
    x_description                       IN     VARCHAR2,
    x_acad_cal_type                     IN     VARCHAR2,
    x_acad_ci_sequence_number           IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_ci_sequence_number            IN     NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 14-AUG-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_batc_def_det_all
      WHERE    batch_id = x_batch_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_batch_id,
        x_description,
        x_acad_cal_type,
        x_acad_ci_sequence_number,
        x_adm_cal_type,
        x_adm_ci_sequence_number,
        x_admission_cat,
        x_s_admission_process_type,
        x_decision_make_id,
        x_decision_date,
        x_decision_reason_id,
        x_pending_reason_id,
        x_offer_dt,
        x_offer_response_dt,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_batch_id,
      x_description,
      x_acad_cal_type,
      x_acad_ci_sequence_number,
      x_adm_cal_type,
      x_adm_ci_sequence_number,
      x_admission_cat,
      x_s_admission_process_type,
      x_decision_make_id,
      x_decision_date,
      x_decision_reason_id,
      x_pending_reason_id,
      x_offer_dt,
      x_offer_response_dt,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 14-AUG-2001
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

    DELETE FROM igs_ad_batc_def_det_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ad_batc_def_det_pkg;

/
