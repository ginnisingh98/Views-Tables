--------------------------------------------------------
--  DDL for Package Body IGS_AD_ADMDE_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_ADMDE_INT_PKG" AS
/* $Header: IGSAIE9B.pls 115.10 2003/12/15 11:55:38 rboddu noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_admde_int_all%ROWTYPE;
  new_references igs_ad_admde_int_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_interface_mkdes_id                IN     NUMBER      DEFAULT NULL,
    x_interface_run_id                  IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_admission_appl_number             IN     NUMBER      DEFAULT NULL,
    x_nominated_course_cd               IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_adm_outcome_status                IN     VARCHAR2    DEFAULT NULL,
    x_decision_make_id                  IN     NUMBER      DEFAULT NULL,
    x_decision_date                     IN     DATE        DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER      DEFAULT NULL,
    x_pending_reason_id                 IN     NUMBER      DEFAULT NULL,
    x_offer_dt                          IN     DATE        DEFAULT NULL,
    x_offer_response_dt                 IN     DATE        DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_error_code                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_reconsider_flag                   IN     VARCHAR2    DEFAULT 'N',
    x_prpsd_commencement_date           IN     DATE DEFAULT NULL,
    x_error_text                        IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 16-AUG-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_ADMDE_INT_ALL
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
    new_references.interface_mkdes_id                := x_interface_mkdes_id;
    new_references.interface_run_id                  := x_interface_run_id;
    new_references.batch_id                          := x_batch_id;
    new_references.person_id                         := x_person_id;
    new_references.admission_appl_number             := x_admission_appl_number;
    new_references.nominated_course_cd               := x_nominated_course_cd;
    new_references.sequence_number                   := x_sequence_number;
    new_references.adm_outcome_status                := x_adm_outcome_status;
    new_references.decision_make_id                  := x_decision_make_id;
    new_references.decision_date                     := x_decision_date;
    new_references.decision_reason_id                := x_decision_reason_id;
    new_references.pending_reason_id                 := x_pending_reason_id;
    new_references.offer_dt                          := x_offer_dt;
    new_references.offer_response_dt                 := x_offer_response_dt;
    new_references.status                            := x_status;
    new_references.error_code                        := x_error_code;
    new_references.reconsider_flag                   := x_reconsider_flag;
    new_references.prpsd_commencement_date           := x_prpsd_commencement_date;
    new_references.error_text                        := x_error_text;

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
     x_interface_mkdes_id IN NUMBER
     ) RETURN BOOLEAN AS

     CURSOR cur_rowid IS
       SELECT   rowid
       FROM     IGS_AD_ADMDE_INT_ALL
       WHERE    interface_mkdes_id = x_interface_mkdes_id
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
    x_interface_mkdes_id                IN     NUMBER      DEFAULT NULL,
    x_interface_run_id                  IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_admission_appl_number             IN     NUMBER      DEFAULT NULL,
    x_nominated_course_cd               IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_adm_outcome_status                IN     VARCHAR2    DEFAULT NULL,
    x_decision_make_id                  IN     NUMBER      DEFAULT NULL,
    x_decision_date                     IN     DATE        DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER      DEFAULT NULL,
    x_pending_reason_id                 IN     NUMBER      DEFAULT NULL,
    x_offer_dt                          IN     DATE        DEFAULT NULL,
    x_offer_response_dt                 IN     DATE        DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_error_code                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_reconsider_flag                   IN     VARCHAR2    DEFAULT 'N',
    x_prpsd_commencement_date           IN     DATE DEFAULT NULL,
    x_error_text                        IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 16-AUG-2001
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
      x_interface_mkdes_id,
      x_interface_run_id,
      x_batch_id,
      x_person_id,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_sequence_number,
      x_adm_outcome_status,
      x_decision_make_id,
      x_decision_date,
      x_decision_reason_id,
      x_pending_reason_id,
      x_offer_dt,
      x_offer_response_dt,
      x_status,
      x_error_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_reconsider_flag,
      x_prpsd_commencement_date,
      x_error_text
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
	    new_references.interface_mkdes_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
	    new_references.interface_mkdes_id
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
    x_interface_mkdes_id                IN OUT NOCOPY NUMBER,
    x_interface_run_id                  IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_adm_outcome_status                IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_status                            IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_reconsider_flag                   IN     VARCHAR2,
    x_prpsd_commencement_date             IN     DATE DEFAULT NULL,
    x_error_text                        IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 16-AUG-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_admde_int_all
      WHERE    interface_mkdes_id = x_interface_mkdes_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    x_interface_mkdes_id := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_interface_mkdes_id                => x_interface_mkdes_id,
      x_interface_run_id                  => x_interface_run_id,
      x_batch_id                          => x_batch_id,
      x_person_id                         => x_person_id,
      x_admission_appl_number             => x_admission_appl_number,
      x_nominated_course_cd               => x_nominated_course_cd,
      x_sequence_number                   => x_sequence_number,
      x_adm_outcome_status                => x_adm_outcome_status,
      x_decision_make_id                  => x_decision_make_id,
      x_decision_date                     => x_decision_date,
      x_decision_reason_id                => x_decision_reason_id,
      x_pending_reason_id                 => x_pending_reason_id,
      x_offer_dt                          => x_offer_dt,
      x_offer_response_dt                 => x_offer_response_dt,
      x_status                            => x_status,
      x_error_code                        => x_error_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_reconsider_flag                   => x_reconsider_flag,
      x_prpsd_commencement_date             => x_prpsd_commencement_date,
      x_error_text                        => x_error_text
    );

    INSERT INTO igs_ad_admde_int_all (
      interface_mkdes_id,
      interface_run_id,
      batch_id,
      person_id,
      admission_appl_number,
      nominated_course_cd,
      sequence_number,
      adm_outcome_status,
      decision_make_id,
      decision_date,
      decision_reason_id,
      pending_reason_id,
      offer_dt,
      offer_response_dt,
      status,
      error_code,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      reconsider_flag,
      prpsd_commencement_date,
      error_text
    ) VALUES (
      igs_ad_admde_int_s.NEXTVAL,
      new_references.interface_run_id,
      new_references.batch_id,
      new_references.person_id,
      new_references.admission_appl_number,
      new_references.nominated_course_cd,
      new_references.sequence_number,
      new_references.adm_outcome_status,
      new_references.decision_make_id,
      new_references.decision_date,
      new_references.decision_reason_id,
      new_references.pending_reason_id,
      new_references.offer_dt,
      new_references.offer_response_dt,
      new_references.status,
      new_references.error_code,
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.reconsider_flag,
      new_references.prpsd_commencement_date,
      new_references.error_text
    )RETURNING interface_mkdes_id INTO x_interface_mkdes_id;

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
    x_interface_mkdes_id                IN     NUMBER,
    x_interface_run_id                  IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_adm_outcome_status                IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_status                            IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_reconsider_flag                   IN     VARCHAR2,
    x_prpsd_commencement_date             IN     DATE DEFAULT NULL,
    x_error_text                        IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 16-AUG-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        interface_mkdes_id,
        interface_run_id,
        batch_id,
        person_id,
        admission_appl_number,
        nominated_course_cd,
        sequence_number,
        adm_outcome_status,
        decision_make_id,
        decision_date,
        decision_reason_id,
        pending_reason_id,
        offer_dt,
        offer_response_dt,
        status,
        error_code,
	reconsider_flag,
	prpsd_commencement_date,
	error_text
      FROM  igs_ad_admde_int_all
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
        (tlinfo.interface_mkdes_id = x_interface_mkdes_id)
        AND (tlinfo.interface_run_id = x_interface_run_id)
        AND (tlinfo.batch_id = x_batch_id)
        AND (tlinfo.person_id = x_person_id)
        AND (tlinfo.admission_appl_number = x_admission_appl_number)
        AND (tlinfo.nominated_course_cd = x_nominated_course_cd)
        AND (tlinfo.sequence_number = x_sequence_number)
        AND ((tlinfo.adm_outcome_status = x_adm_outcome_status) OR ((tlinfo.adm_outcome_status IS NULL) AND (X_adm_outcome_status IS NULL)))
        AND ((tlinfo.decision_make_id = x_decision_make_id) OR ((tlinfo.decision_make_id IS NULL) AND (X_decision_make_id IS NULL)))
        AND ((trunc(tlinfo.decision_date) = trunc(x_decision_date)) OR ((tlinfo.decision_date IS NULL) AND (X_decision_date IS NULL)))
        AND ((tlinfo.decision_reason_id = x_decision_reason_id) OR ((tlinfo.decision_reason_id IS NULL) AND (X_decision_reason_id IS NULL)))
        AND ((tlinfo.pending_reason_id = x_pending_reason_id) OR ((tlinfo.pending_reason_id IS NULL) AND (X_pending_reason_id IS NULL)))
        AND ((trunc(tlinfo.offer_dt) = trunc(x_offer_dt)) OR ((tlinfo.offer_dt IS NULL) AND (X_offer_dt IS NULL)))
        AND ((trunc(tlinfo.offer_response_dt) = trunc(x_offer_response_dt)) OR ((tlinfo.offer_response_dt IS NULL) AND (X_offer_response_dt IS NULL)))
        AND ((tlinfo.status = x_status) OR ((tlinfo.status IS NULL) AND (X_status IS NULL)))
        AND ((tlinfo.error_code = x_error_code) OR ((tlinfo.error_code IS NULL) AND (X_error_code IS NULL)))
	AND ((tlinfo.reconsider_flag = x_reconsider_flag) OR ((tlinfo.reconsider_flag IS NULL) AND (X_reconsider_flag IS NULL)))
        AND ((trunc(tlinfo.prpsd_commencement_date) = trunc(x_prpsd_commencement_date)) OR ((tlinfo.prpsd_commencement_date IS NULL) AND (x_prpsd_commencement_date IS NULL)))
	AND ((tlinfo.error_text = x_error_text) OR ((tlinfo.error_text IS NULL) AND (X_error_text IS NULL)))
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
    x_interface_mkdes_id                IN     NUMBER,
    x_interface_run_id                  IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_adm_outcome_status                IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_status                            IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_reconsider_flag                   IN     VARCHAR2,
    x_prpsd_commencement_date           IN     DATE DEFAULT NULL,
    x_error_text                        IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 16-AUG-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_interface_mkdes_id                => x_interface_mkdes_id,
      x_interface_run_id                  => x_interface_run_id,
      x_batch_id                          => x_batch_id,
      x_person_id                         => x_person_id,
      x_admission_appl_number             => x_admission_appl_number,
      x_nominated_course_cd               => x_nominated_course_cd,
      x_sequence_number                   => x_sequence_number,
      x_adm_outcome_status                => x_adm_outcome_status,
      x_decision_make_id                  => x_decision_make_id,
      x_decision_date                     => x_decision_date,
      x_decision_reason_id                => x_decision_reason_id,
      x_pending_reason_id                 => x_pending_reason_id,
      x_offer_dt                          => x_offer_dt,
      x_offer_response_dt                 => x_offer_response_dt,
      x_status                            => x_status,
      x_error_code                        => x_error_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_reconsider_flag                   => x_reconsider_flag,
      x_prpsd_commencement_date           => x_prpsd_commencement_date,
      x_error_text                        => x_error_text
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igs_ad_admde_int_all
      SET
        interface_mkdes_id                = new_references.interface_mkdes_id,
        interface_run_id                  = new_references.interface_run_id,
        batch_id                          = new_references.batch_id,
        person_id                         = new_references.person_id,
        admission_appl_number             = new_references.admission_appl_number,
        nominated_course_cd               = new_references.nominated_course_cd,
        sequence_number                   = new_references.sequence_number,
        adm_outcome_status                = new_references.adm_outcome_status,
        decision_make_id                  = new_references.decision_make_id,
        decision_date                     = new_references.decision_date,
        decision_reason_id                = new_references.decision_reason_id,
        pending_reason_id                 = new_references.pending_reason_id,
        offer_dt                          = new_references.offer_dt,
        offer_response_dt                 = new_references.offer_response_dt,
        status                            = new_references.status,
        error_code                        = new_references.error_code,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
	reconsider_flag                   = x_reconsider_flag,
	prpsd_commencement_date           = x_prpsd_commencement_date,
	error_text                        = x_error_text
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_interface_mkdes_id                IN OUT NOCOPY NUMBER,
    x_interface_run_id                  IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_adm_outcome_status                IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_status                            IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_reconsider_flag                   IN     VARCHAR2,
    x_prpsd_commencement_date             IN     DATE DEFAULT NULL,
    x_error_text                        IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 16-AUG-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_admde_int_all
      WHERE    interface_mkdes_id= x_interface_mkdes_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_interface_mkdes_id,
        x_interface_run_id,
        x_batch_id,
        x_person_id,
        x_admission_appl_number,
        x_nominated_course_cd,
        x_sequence_number,
        x_adm_outcome_status,
        x_decision_make_id,
        x_decision_date,
        x_decision_reason_id,
        x_pending_reason_id,
        x_offer_dt,
        x_offer_response_dt,
        x_status,
        x_error_code,
        x_mode,
	x_reconsider_flag,
	x_prpsd_commencement_date,
	x_error_text
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_interface_mkdes_id,
      x_interface_run_id,
      x_batch_id,
      x_person_id,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_sequence_number,
      x_adm_outcome_status,
      x_decision_make_id,
      x_decision_date,
      x_decision_reason_id,
      x_pending_reason_id,
      x_offer_dt,
      x_offer_response_dt,
      x_status,
      x_error_code,
      x_mode,
      x_reconsider_flag,
      x_prpsd_commencement_date,
      x_error_text
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nilotpal.Shee@oracle.com
  ||  Created On : 16-AUG-2001
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

    DELETE FROM igs_ad_admde_int_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ad_admde_int_pkg;

/
