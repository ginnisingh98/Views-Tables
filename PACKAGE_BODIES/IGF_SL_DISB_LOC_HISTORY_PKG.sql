--------------------------------------------------------
--  DDL for Package Body IGF_SL_DISB_LOC_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DISB_LOC_HISTORY_PKG" AS
/* $Header: IGFLI42B.pls 120.0 2005/06/01 14:33:12 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_disb_loc_history%ROWTYPE;
  new_references igf_sl_disb_loc_history%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_lodisbh_id                        IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_gross_amt            IN     NUMBER,
    x_origination_fee_amt               IN     NUMBER,
    x_guarantee_fee_amt                 IN     NUMBER,
    x_origination_fee_paid_amt          IN     NUMBER,
    x_guarantee_fee_paid_amt            IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_disbursement_hold_rel_ind         IN     VARCHAR2,
    x_disbursement_net_amt              IN     NUMBER,
    x_source_txt                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 04-NOV-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_sl_disb_loc_history
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
    new_references.lodisbh_id                        := x_lodisbh_id;
    new_references.award_id                          := x_award_id;
    new_references.disbursement_number               := x_disbursement_number;
    new_references.disbursement_gross_amt            := x_disbursement_gross_amt;
    new_references.origination_fee_amt               := x_origination_fee_amt;
    new_references.guarantee_fee_amt                 := x_guarantee_fee_amt;
    new_references.origination_fee_paid_amt          := x_origination_fee_paid_amt;
    new_references.guarantee_fee_paid_amt            := x_guarantee_fee_paid_amt;
    new_references.disbursement_date                 := x_disbursement_date;
    new_references.disbursement_hold_rel_ind         := x_disbursement_hold_rel_ind;
    new_references.disbursement_net_amt              := x_disbursement_net_amt;
    new_references.source_txt                        := x_source_txt;
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_lodisbh_id                        IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_gross_amt            IN     NUMBER,
    x_origination_fee_amt               IN     NUMBER,
    x_guarantee_fee_amt                 IN     NUMBER,
    x_origination_fee_paid_amt          IN     NUMBER,
    x_guarantee_fee_paid_amt            IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_disbursement_hold_rel_ind         IN     VARCHAR2,
    x_disbursement_net_amt              IN     NUMBER,
    X_source_txt                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 04-NOV-2004
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
      x_lodisbh_id,
      x_award_id,
      x_disbursement_number,
      x_disbursement_gross_amt,
      x_origination_fee_amt,
      x_guarantee_fee_amt,
      x_origination_fee_paid_amt,
      x_guarantee_fee_paid_amt,
      x_disbursement_date,
      x_disbursement_hold_rel_ind,
      x_disbursement_net_amt,
      x_source_txt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation( new_references.lodisbh_id

           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation ( new_references.lodisbh_id

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
    x_lodisbh_id                        IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_gross_amt            IN     NUMBER,
    x_origination_fee_amt               IN     NUMBER,
    x_guarantee_fee_amt                 IN     NUMBER,
    x_origination_fee_paid_amt          IN     NUMBER,
    x_guarantee_fee_paid_amt            IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_disbursement_hold_rel_ind         IN     VARCHAR2,
    x_disbursement_net_amt              IN     NUMBER,
    X_source_txt                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 04-NOV-2004
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

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
      fnd_message.set_token ('ROUTINE', 'igf_sl_disb_loc_history_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_lodisbh_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_lodisbh_id                        => x_lodisbh_id,
      x_award_id                          => x_award_id,
      x_disbursement_number               => x_disbursement_number,
      x_disbursement_gross_amt            => x_disbursement_gross_amt,
      x_origination_fee_amt               => x_origination_fee_amt,
      x_guarantee_fee_amt                 => x_guarantee_fee_amt,
      x_origination_fee_paid_amt          => x_origination_fee_paid_amt,
      x_guarantee_fee_paid_amt            => x_guarantee_fee_paid_amt,
      x_disbursement_date                 => x_disbursement_date,
      x_disbursement_hold_rel_ind         => x_disbursement_hold_rel_ind,
      x_disbursement_net_amt              => x_disbursement_net_amt,
      x_source_txt                        => X_source_txt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_sl_disb_loc_history (
      lodisbh_id,
      award_id,
      disbursement_number,
      disbursement_gross_amt,
      origination_fee_amt,
      guarantee_fee_amt,
      origination_fee_paid_amt,
      guarantee_fee_paid_amt,
      disbursement_date,
      disbursement_hold_rel_ind,
      disbursement_net_amt,
      source_txt,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      igf_sl_disb_loc_history_s.NEXTVAL,
      new_references.award_id,
      new_references.disbursement_number,
      new_references.disbursement_gross_amt,
      new_references.origination_fee_amt,
      new_references.guarantee_fee_amt,
      new_references.origination_fee_paid_amt,
      new_references.guarantee_fee_paid_amt,
      new_references.disbursement_date,
      new_references.disbursement_hold_rel_ind,
      new_references.disbursement_net_amt,
      new_references.source_txt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, lodisbh_id INTO x_rowid, x_lodisbh_id;

  END insert_row;

 FUNCTION get_pk_for_validation (
    x_lodisbh_id                          IN     NUMBER
    ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 16-NOV-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_disb_loc_history
      WHERE    lodisbh_id = x_lodisbh_id
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


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lodisbh_id                        IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_gross_amt            IN     NUMBER,
    x_origination_fee_amt               IN     NUMBER,
    x_guarantee_fee_amt                 IN     NUMBER,
    x_origination_fee_paid_amt          IN     NUMBER,
    x_guarantee_fee_paid_amt            IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_disbursement_hold_rel_ind         IN     VARCHAR2,
    x_disbursement_net_amt              IN     NUMBER,
    x_source_txt                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 04-NOV-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        lodisbh_id,
        award_id,
        disbursement_number,
        disbursement_gross_amt,
        origination_fee_amt,
        guarantee_fee_amt,
        origination_fee_paid_amt,
        guarantee_fee_paid_amt,
        disbursement_date,
        disbursement_hold_rel_ind,
        disbursement_net_amt,
        source_txt
      FROM  igf_sl_disb_loc_history
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
        (tlinfo.lodisbh_id = x_lodisbh_id)
        AND (tlinfo.award_id = x_award_id)
        AND (tlinfo.disbursement_number = x_disbursement_number)
        AND ((tlinfo.disbursement_gross_amt = x_disbursement_gross_amt) OR ((tlinfo.disbursement_gross_amt IS NULL) AND (X_disbursement_gross_amt IS NULL)))
        AND ((tlinfo.origination_fee_amt = x_origination_fee_amt) OR ((tlinfo.origination_fee_amt IS NULL) AND (X_origination_fee_amt IS NULL)))
        AND ((tlinfo.guarantee_fee_amt = x_guarantee_fee_amt) OR ((tlinfo.guarantee_fee_amt IS NULL) AND (X_guarantee_fee_amt IS NULL)))
        AND ((tlinfo.origination_fee_paid_amt = x_origination_fee_paid_amt) OR ((tlinfo.origination_fee_paid_amt IS NULL) AND (X_origination_fee_paid_amt IS NULL)))
        AND ((tlinfo.guarantee_fee_paid_amt = x_guarantee_fee_paid_amt) OR ((tlinfo.guarantee_fee_paid_amt IS NULL) AND (X_guarantee_fee_paid_amt IS NULL)))
        AND ((tlinfo.disbursement_date = x_disbursement_date) OR ((tlinfo.disbursement_date IS NULL) AND (X_disbursement_date IS NULL)))
        AND ((tlinfo.disbursement_hold_rel_ind = x_disbursement_hold_rel_ind) OR ((tlinfo.disbursement_hold_rel_ind IS NULL) AND (X_disbursement_hold_rel_ind IS NULL)))
        AND ((tlinfo.disbursement_net_amt = x_disbursement_net_amt) OR ((tlinfo.disbursement_net_amt IS NULL) AND (X_disbursement_net_amt IS NULL)))
        AND ((tlinfo.source_txt = x_source_txt) OR ((tlinfo.source_txt IS NULL) AND (X_source_txt IS NULL)))
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
    x_lodisbh_id                        IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_gross_amt            IN     NUMBER,
    x_origination_fee_amt               IN     NUMBER,
    x_guarantee_fee_amt                 IN     NUMBER,
    x_origination_fee_paid_amt          IN     NUMBER,
    x_guarantee_fee_paid_amt            IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_disbursement_hold_rel_ind         IN     VARCHAR2,
    x_disbursement_net_amt              IN     NUMBER,
    x_source_txt                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 04-NOV-2004
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
      fnd_message.set_token ('ROUTINE', 'igf_sl_disb_loc_history_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_lodisbh_id                        => x_lodisbh_id,
      x_award_id                          => x_award_id,
      x_disbursement_number               => x_disbursement_number,
      x_disbursement_gross_amt            => x_disbursement_gross_amt,
      x_origination_fee_amt               => x_origination_fee_amt,
      x_guarantee_fee_amt                 => x_guarantee_fee_amt,
      x_origination_fee_paid_amt          => x_origination_fee_paid_amt,
      x_guarantee_fee_paid_amt            => x_guarantee_fee_paid_amt,
      x_disbursement_date                 => x_disbursement_date,
      x_disbursement_hold_rel_ind         => x_disbursement_hold_rel_ind,
      x_disbursement_net_amt              => x_disbursement_net_amt,
      x_source_txt                        => x_source_txt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
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

    UPDATE igf_sl_disb_loc_history
      SET
        lodisbh_id                        = new_references.lodisbh_id,
        award_id                          = new_references.award_id,
        disbursement_number               = new_references.disbursement_number,
        disbursement_gross_amt            = new_references.disbursement_gross_amt,
        origination_fee_amt               = new_references.origination_fee_amt,
        guarantee_fee_amt                 = new_references.guarantee_fee_amt,
        origination_fee_paid_amt          = new_references.origination_fee_paid_amt,
        guarantee_fee_paid_amt            = new_references.guarantee_fee_paid_amt,
        disbursement_date                 = new_references.disbursement_date,
        disbursement_hold_rel_ind         = new_references.disbursement_hold_rel_ind,
        disbursement_net_amt              = new_references.disbursement_net_amt,
        source_txt                        = new_references.source_txt,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lodisbh_id                        IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_gross_amt            IN     NUMBER,
    x_origination_fee_amt               IN     NUMBER,
    x_guarantee_fee_amt                 IN     NUMBER,
    x_origination_fee_paid_amt          IN     NUMBER,
    x_guarantee_fee_paid_amt            IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_disbursement_hold_rel_ind         IN     VARCHAR2,
    x_disbursement_net_amt              IN     NUMBER,
    x_source_txt                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 04-NOV-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_disb_loc_history
      WHERE  lodisbh_id = x_lodisbh_id  ;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_lodisbh_id,
        x_award_id,
        x_disbursement_number,
        x_disbursement_gross_amt,
        x_origination_fee_amt,
        x_guarantee_fee_amt,
        x_origination_fee_paid_amt,
        x_guarantee_fee_paid_amt,
        x_disbursement_date,
        x_disbursement_hold_rel_ind,
        x_disbursement_net_amt,
        x_source_txt,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_lodisbh_id,
      x_award_id,
      x_disbursement_number,
      x_disbursement_gross_amt,
      x_origination_fee_amt,
      x_guarantee_fee_amt,
      x_origination_fee_paid_amt,
      x_guarantee_fee_paid_amt,
      x_disbursement_date,
      x_disbursement_hold_rel_ind,
      x_disbursement_net_amt,
      x_source_txt,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 04-NOV-2004
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

    DELETE FROM igf_sl_disb_loc_history
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_disb_loc_history_pkg;

/
