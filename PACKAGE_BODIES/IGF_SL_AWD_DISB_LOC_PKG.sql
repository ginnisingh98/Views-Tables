--------------------------------------------------------
--  DDL for Package Body IGF_SL_AWD_DISB_LOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_AWD_DISB_LOC_PKG" AS
/* $Header: IGFLI24B.pls 120.0 2005/06/01 14:44:26 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_awd_disb_loc_all%ROWTYPE;
  new_references igf_sl_awd_disb_loc_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_fee_1                             IN     NUMBER      DEFAULT NULL,
    x_fee_2                             IN     NUMBER      DEFAULT NULL,
    x_disb_net_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_date                         IN     DATE        DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_paid_1                        IN     NUMBER      DEFAULT NULL,
    x_fee_paid_2                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 16-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_SL_AWD_DISB_LOC_ALL
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
    new_references.award_id                          := x_award_id;
    new_references.disb_num                          := x_disb_num;
    new_references.disb_gross_amt                    := x_disb_gross_amt;
    new_references.fee_1                             := x_fee_1;
    new_references.fee_2                             := x_fee_2;
    new_references.disb_net_amt                      := x_disb_net_amt;
    new_references.disb_date                         := x_disb_date;
    new_references.hold_rel_ind                      := x_hold_rel_ind;
    new_references.fee_paid_1                        := x_fee_paid_1;
    new_references.fee_paid_2                        := x_fee_paid_2;

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
  ||  Created By : venagara
  ||  Created On : 16-NOV-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.award_id = new_references.award_id)) OR
        ((new_references.award_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_award_pkg.get_pk_for_validation (
                new_references.award_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
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
      FROM     igf_sl_awd_disb_loc_all
      WHERE    award_id = x_award_id
      AND      disb_num = x_disb_num
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


  PROCEDURE get_fk_igf_aw_award (
    x_award_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 16-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_awd_disb_loc_all
      WHERE   ((award_id = x_award_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_AWDL_AWD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_award;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_fee_1                             IN     NUMBER      DEFAULT NULL,
    x_fee_2                             IN     NUMBER      DEFAULT NULL,
    x_disb_net_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_date                         IN     DATE        DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_paid_1                        IN     NUMBER      DEFAULT NULL,
    x_fee_paid_2                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 16-NOV-2000
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
      x_award_id,
      x_disb_num,
      x_disb_gross_amt,
      x_fee_1,
      x_fee_2,
      x_disb_net_amt,
      x_disb_date,
      x_hold_rel_ind,
      x_fee_paid_1,
      x_fee_paid_2,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.award_id,
             new_references.disb_num
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
             new_references.award_id,
             new_references.disb_num
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
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 16-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_awd_disb_loc_all
      WHERE    award_id                          = x_award_id
      AND      disb_num                          = x_disb_num;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id			 igf_sl_awd_disb_loc_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_award_id                          => x_award_id,
      x_disb_num                          => x_disb_num,
      x_disb_gross_amt                    => x_disb_gross_amt,
      x_fee_1                             => x_fee_1,
      x_fee_2                             => x_fee_2,
      x_disb_net_amt                      => x_disb_net_amt,
      x_disb_date                         => x_disb_date,
      x_hold_rel_ind                      => x_hold_rel_ind,
      x_fee_paid_1                        => x_fee_paid_1,
      x_fee_paid_2                        => x_fee_paid_2,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_sl_awd_disb_loc_all(
      award_id,
      disb_num,
      disb_gross_amt,
      fee_1,
      fee_2,
      disb_net_amt,
      disb_date,
      hold_rel_ind,
      fee_paid_1,
      fee_paid_2,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id
    ) VALUES (
      new_references.award_id,
      new_references.disb_num,
      new_references.disb_gross_amt,
      new_references.fee_1,
      new_references.fee_2,
      new_references.disb_net_amt,
      new_references.disb_date,
      new_references.hold_rel_ind,
      new_references.fee_paid_1,
      new_references.fee_paid_2,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
      l_org_id
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

    after_dml (p_action => 'INSERT');

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 16-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        disb_gross_amt,
        fee_1,
        fee_2,
        disb_net_amt,
        disb_date,
        hold_rel_ind,
        fee_paid_1,
        fee_paid_2,
        org_id
      FROM  igf_sl_awd_disb_loc_all
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
        (tlinfo.disb_gross_amt = x_disb_gross_amt)
        AND ((tlinfo.fee_1 = x_fee_1) OR ((tlinfo.fee_1 IS NULL) AND (X_fee_1 IS NULL)))
        AND ((tlinfo.fee_2 = x_fee_2) OR ((tlinfo.fee_2 IS NULL) AND (X_fee_2 IS NULL)))
        AND (tlinfo.disb_net_amt = x_disb_net_amt)
        AND (tlinfo.disb_date = x_disb_date)
        AND ((tlinfo.hold_rel_ind = x_hold_rel_ind) OR ((tlinfo.hold_rel_ind IS NULL) AND (X_hold_rel_ind IS NULL)))
        AND ((tlinfo.fee_paid_1 = x_fee_paid_1) OR ((tlinfo.fee_paid_1 IS NULL) AND (X_fee_paid_1 IS NULL)))
        AND ((tlinfo.fee_paid_2 = x_fee_paid_2) OR ((tlinfo.fee_paid_2 IS NULL) AND (X_fee_paid_2 IS NULL)))
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
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 16-NOV-2000
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
      x_award_id                          => x_award_id,
      x_disb_num                          => x_disb_num,
      x_disb_gross_amt                    => x_disb_gross_amt,
      x_fee_1                             => x_fee_1,
      x_fee_2                             => x_fee_2,
      x_disb_net_amt                      => x_disb_net_amt,
      x_disb_date                         => x_disb_date,
      x_hold_rel_ind                      => x_hold_rel_ind,
      x_fee_paid_1                        => x_fee_paid_1,
      x_fee_paid_2                        => x_fee_paid_2,
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

    UPDATE igf_sl_awd_disb_loc_all
      SET
        disb_gross_amt                    = new_references.disb_gross_amt,
        fee_1                             = new_references.fee_1,
        fee_2                             = new_references.fee_2,
        disb_net_amt                      = new_references.disb_net_amt,
        disb_date                         = new_references.disb_date,
        hold_rel_ind                      = new_references.hold_rel_ind,
        fee_paid_1                        = new_references.fee_paid_1,
        fee_paid_2                        = new_references.fee_paid_2,
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

        after_dml (p_action => 'UPDATE');
  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 16-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_awd_disb_loc_all
      WHERE    award_id                          = x_award_id
      AND      disb_num                          = x_disb_num;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_award_id,
        x_disb_num,
        x_disb_gross_amt,
        x_fee_1,
        x_fee_2,
        x_disb_net_amt,
        x_disb_date,
        x_hold_rel_ind,
        x_fee_paid_1,
        x_fee_paid_2,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_award_id,
      x_disb_num,
      x_disb_gross_amt,
      x_fee_1,
      x_fee_2,
      x_disb_net_amt,
      x_disb_date,
      x_hold_rel_ind,
      x_fee_paid_1,
      x_fee_paid_2,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 16-NOV-2000
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

    DELETE FROM igf_sl_awd_disb_loc_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

PROCEDURE after_dml( p_action IN VARCHAR2
          ) AS
  /*
  ||  Created By : pssahni
  ||  Created On : 4-Nov-2004
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  l_rowid   ROWID;
  l_source  VARCHAR2(10);
  l_seq     NUMBER;

  BEGIN

  IF p_action = 'INSERT' THEN
    l_source := 'SYSTEM';
  ELSIF p_action='UPDATE' THEN
      l_source := 'RESPONSE';
  END IF;

    igf_sl_disb_loc_history_pkg.insert_row (
        x_rowid                                  => l_rowid,
        x_lodisbh_id                             =>  l_seq,
        x_award_id                               => new_references.award_id                    ,
        x_disbursement_number                    => new_references.disb_num         ,
        x_disbursement_gross_amt                 => new_references.disb_gross_amt      ,
        x_origination_fee_amt                    => new_references.fee_1         ,
        x_guarantee_fee_amt                      => new_references.fee_2           ,
        x_origination_fee_paid_amt               => new_references.fee_paid_1    ,
        x_guarantee_fee_paid_amt                 => new_references.fee_paid_2      ,
        x_disbursement_date                      => new_references.disb_date           ,
        x_disbursement_hold_rel_ind              => new_references.hold_rel_ind   ,
        x_disbursement_net_amt                   => new_references.disb_net_amt        ,
        x_source_txt                             => l_source,
        x_mode                                   => 'R'
      );

  END after_dml;


END igf_sl_awd_disb_loc_pkg;

/
