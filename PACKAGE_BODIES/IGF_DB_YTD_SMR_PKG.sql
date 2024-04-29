--------------------------------------------------------
--  DDL for Package Body IGF_DB_YTD_SMR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_YTD_SMR_PKG" AS
/* $Header: IGFDI10B.pls 115.4 2003/02/26 03:52:00 smvk noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_db_ytd_smr_all%ROWTYPE;
  new_references igf_db_ytd_smr_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ytds_id                           IN     NUMBER  ,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE    ,
    x_process_dt                        IN     DATE    ,
    x_disb_smr_type                     IN     VARCHAR2,
    x_bkd_gross                         IN     NUMBER  ,
    x_bkd_fee                           IN     NUMBER  ,
    x_bkd_int_rebate                    IN     NUMBER  ,
    x_bkd_net                           IN     NUMBER  ,
    x_unbkd_gross                       IN     NUMBER  ,
    x_unbkd_fee                         IN     NUMBER  ,
    x_unbkd_int_rebate                  IN     NUMBER  ,
    x_unbkd_net                         IN     NUMBER  ,
    x_region_code                       IN     VARCHAR2,
    x_state_code                        IN     VARCHAR2,
    x_rec_count                         IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 23-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_db_ytd_smr_all
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
    new_references.ytds_id                           := x_ytds_id;
    new_references.dl_version                        := x_dl_version;
    new_references.record_type                       := x_record_type;
    new_references.batch_id                          := x_batch_id;
    new_references.school_code                       := x_school_code;
    new_references.stat_end_dt                       := x_stat_end_dt;
    new_references.process_dt                        := x_process_dt;
    new_references.disb_smr_type                     := x_disb_smr_type;
    new_references.bkd_gross                         := x_bkd_gross;
    new_references.bkd_fee                           := x_bkd_fee;
    new_references.bkd_int_rebate                    := x_bkd_int_rebate;
    new_references.bkd_net                           := x_bkd_net;
    new_references.unbkd_gross                       := x_unbkd_gross;
    new_references.unbkd_fee                         := x_unbkd_fee;
    new_references.unbkd_int_rebate                  := x_unbkd_int_rebate;
    new_references.unbkd_net                         := x_unbkd_net;
    new_references.region_code                       := x_region_code;
    new_references.state_code                        := x_state_code;
    new_references.rec_count                         := x_rec_count;

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


  FUNCTION get_pk_for_validation (
    x_ytds_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasingh
  ||  Created On : 23-JAN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_db_ytd_smr_all
      WHERE    ytds_id = x_ytds_id
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
    x_ytds_id                           IN     NUMBER  ,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE    ,
    x_process_dt                        IN     DATE    ,
    x_disb_smr_type                     IN     VARCHAR2,
    x_bkd_gross                         IN     NUMBER  ,
    x_bkd_fee                           IN     NUMBER  ,
    x_bkd_int_rebate                    IN     NUMBER  ,
    x_bkd_net                           IN     NUMBER  ,
    x_unbkd_gross                       IN     NUMBER  ,
    x_unbkd_fee                         IN     NUMBER  ,
    x_unbkd_int_rebate                  IN     NUMBER  ,
    x_unbkd_net                         IN     NUMBER  ,
    x_region_code                       IN     VARCHAR2,
    x_state_code                        IN     VARCHAR2,
    x_rec_count                         IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 23-JAN-2002
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
      x_ytds_id,
      x_dl_version,
      x_record_type,
      x_batch_id,
      x_school_code,
      x_stat_end_dt,
      x_process_dt,
      x_disb_smr_type,
      x_bkd_gross,
      x_bkd_fee,
      x_bkd_int_rebate,
      x_bkd_net,
      x_unbkd_gross,
      x_unbkd_fee,
      x_unbkd_int_rebate,
      x_unbkd_net,
      x_region_code,
      x_state_code,
      x_rec_count,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ytds_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.ytds_id
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
    x_ytds_id                           IN OUT NOCOPY NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_disb_smr_type                     IN     VARCHAR2,
    x_bkd_gross                         IN     NUMBER,
    x_bkd_fee                           IN     NUMBER,
    x_bkd_int_rebate                    IN     NUMBER,
    x_bkd_net                           IN     NUMBER,
    x_unbkd_gross                       IN     NUMBER,
    x_unbkd_fee                         IN     NUMBER,
    x_unbkd_int_rebate                  IN     NUMBER,
    x_unbkd_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2,
    x_state_code                        IN     VARCHAR2,
    x_rec_count                         IN     NUMBER  ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 23-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_db_ytd_smr_all
      WHERE    ytds_id                           = x_ytds_id;

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

    SELECT    igf_db_ytd_smr_s.NEXTVAL
    INTO      x_ytds_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ytds_id                           => x_ytds_id,
      x_dl_version                        => x_dl_version,
      x_record_type                       => x_record_type,
      x_batch_id                          => x_batch_id,
      x_school_code                       => x_school_code,
      x_stat_end_dt                       => x_stat_end_dt,
      x_process_dt                        => x_process_dt,
      x_disb_smr_type                     => x_disb_smr_type,
      x_bkd_gross                         => x_bkd_gross,
      x_bkd_fee                           => x_bkd_fee,
      x_bkd_int_rebate                    => x_bkd_int_rebate,
      x_bkd_net                           => x_bkd_net,
      x_unbkd_gross                       => x_unbkd_gross,
      x_unbkd_fee                         => x_unbkd_fee,
      x_unbkd_int_rebate                  => x_unbkd_int_rebate,
      x_unbkd_net                         => x_unbkd_net,
      x_region_code                       => x_region_code,
      x_state_code                        => x_state_code,
      x_rec_count                         => x_rec_count,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );


    INSERT INTO igf_db_ytd_smr_all (
      ytds_id,
      dl_version,
      record_type,
      batch_id,
      school_code,
      stat_end_dt,
      process_dt,
      disb_smr_type,
      bkd_gross,
      bkd_fee,
      bkd_int_rebate,
      bkd_net,
      unbkd_gross,
      unbkd_fee,
      unbkd_int_rebate,
      unbkd_net,
      region_code,
      state_code ,
      rec_count  ,
      org_id,
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
      new_references.ytds_id,
      new_references.dl_version,
      new_references.record_type,
      new_references.batch_id,
      new_references.school_code,
      new_references.stat_end_dt,
      new_references.process_dt,
      new_references.disb_smr_type,
      new_references.bkd_gross,
      new_references.bkd_fee,
      new_references.bkd_int_rebate,
      new_references.bkd_net,
      new_references.unbkd_gross,
      new_references.unbkd_fee,
      new_references.unbkd_int_rebate,
      new_references.unbkd_net,
      new_references.region_code,
      new_references.state_code ,
      new_references.rec_count  ,
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
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
    x_ytds_id                           IN     NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_disb_smr_type                     IN     VARCHAR2,
    x_bkd_gross                         IN     NUMBER,
    x_bkd_fee                           IN     NUMBER,
    x_bkd_int_rebate                    IN     NUMBER,
    x_bkd_net                           IN     NUMBER,
    x_unbkd_gross                       IN     NUMBER,
    x_unbkd_fee                         IN     NUMBER,
    x_unbkd_int_rebate                  IN     NUMBER,
    x_unbkd_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2,
    x_state_code                        IN     VARCHAR2,
    x_rec_count                         IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 23-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        dl_version,
        record_type,
        batch_id,
        school_code,
        stat_end_dt,
        process_dt,
        disb_smr_type,
        bkd_gross,
        bkd_fee,
        bkd_int_rebate,
        bkd_net,
        unbkd_gross,
        unbkd_fee,
        unbkd_int_rebate,
        unbkd_net,
        region_code,
        state_code ,
        rec_count
      FROM  igf_db_ytd_smr_all
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
        (tlinfo.dl_version = x_dl_version)
        AND ((tlinfo.record_type = x_record_type) OR ((tlinfo.record_type IS NULL) AND (X_record_type IS NULL)))
        AND ((tlinfo.batch_id = x_batch_id) OR ((tlinfo.batch_id IS NULL) AND (X_batch_id IS NULL)))
        AND ((tlinfo.school_code = x_school_code) OR ((tlinfo.school_code IS NULL) AND (X_school_code IS NULL)))
        AND ((tlinfo.stat_end_dt = x_stat_end_dt) OR ((tlinfo.stat_end_dt IS NULL) AND (X_stat_end_dt IS NULL)))
        AND ((tlinfo.process_dt = x_process_dt) OR ((tlinfo.process_dt IS NULL) AND (X_process_dt IS NULL)))
        AND ((tlinfo.disb_smr_type = x_disb_smr_type) OR ((tlinfo.disb_smr_type IS NULL) AND (X_disb_smr_type IS NULL)))
        AND ((tlinfo.bkd_gross = x_bkd_gross) OR ((tlinfo.bkd_gross IS NULL) AND (X_bkd_gross IS NULL)))
        AND ((tlinfo.bkd_fee = x_bkd_fee) OR ((tlinfo.bkd_fee IS NULL) AND (X_bkd_fee IS NULL)))
        AND ((tlinfo.bkd_int_rebate = x_bkd_int_rebate) OR ((tlinfo.bkd_int_rebate IS NULL) AND (X_bkd_int_rebate IS NULL)))
        AND ((tlinfo.bkd_net = x_bkd_net) OR ((tlinfo.bkd_net IS NULL) AND (X_bkd_net IS NULL)))
        AND ((tlinfo.unbkd_gross = x_unbkd_gross) OR ((tlinfo.unbkd_gross IS NULL) AND (X_unbkd_gross IS NULL)))
        AND ((tlinfo.unbkd_fee = x_unbkd_fee) OR ((tlinfo.unbkd_fee IS NULL) AND (X_unbkd_fee IS NULL)))
        AND ((tlinfo.unbkd_int_rebate = x_unbkd_int_rebate) OR ((tlinfo.unbkd_int_rebate IS NULL) AND (X_unbkd_int_rebate IS NULL)))
        AND ((tlinfo.unbkd_net = x_unbkd_net) OR ((tlinfo.unbkd_net IS NULL) AND (X_unbkd_net IS NULL)))
        AND ((tlinfo.region_code = x_region_code) OR ((tlinfo.region_code IS NULL) AND (x_region_code IS NULL)))
        AND ((tlinfo.state_code = x_state_code) OR ((tlinfo.state_code IS NULL) AND (x_state_code IS NULL)))
        AND ((tlinfo.rec_count = x_rec_count) OR ((tlinfo.rec_count IS NULL) AND (x_rec_count IS NULL)))
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
    x_ytds_id                           IN     NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_disb_smr_type                     IN     VARCHAR2,
    x_bkd_gross                         IN     NUMBER,
    x_bkd_fee                           IN     NUMBER,
    x_bkd_int_rebate                    IN     NUMBER,
    x_bkd_net                           IN     NUMBER,
    x_unbkd_gross                       IN     NUMBER,
    x_unbkd_fee                         IN     NUMBER,
    x_unbkd_int_rebate                  IN     NUMBER,
    x_unbkd_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2,
    x_state_code                        IN     VARCHAR2,
    x_rec_count                         IN     NUMBER  ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 23-JAN-2002
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
      x_ytds_id                           => x_ytds_id,
      x_dl_version                        => x_dl_version,
      x_record_type                       => x_record_type,
      x_batch_id                          => x_batch_id,
      x_school_code                       => x_school_code,
      x_stat_end_dt                       => x_stat_end_dt,
      x_process_dt                        => x_process_dt,
      x_disb_smr_type                     => x_disb_smr_type,
      x_bkd_gross                         => x_bkd_gross,
      x_bkd_fee                           => x_bkd_fee,
      x_bkd_int_rebate                    => x_bkd_int_rebate,
      x_bkd_net                           => x_bkd_net,
      x_unbkd_gross                       => x_unbkd_gross,
      x_unbkd_fee                         => x_unbkd_fee,
      x_unbkd_int_rebate                  => x_unbkd_int_rebate,
      x_unbkd_net                         => x_unbkd_net,
      x_region_code                       => x_region_code,
      x_state_code                        => x_state_code,
      x_rec_count                         => x_rec_count,
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

    UPDATE igf_db_ytd_smr_all
      SET
        dl_version                        = new_references.dl_version,
        record_type                       = new_references.record_type,
        batch_id                          = new_references.batch_id,
        school_code                       = new_references.school_code,
        stat_end_dt                       = new_references.stat_end_dt,
        process_dt                        = new_references.process_dt,
        disb_smr_type                     = new_references.disb_smr_type,
        bkd_gross                         = new_references.bkd_gross,
        bkd_fee                           = new_references.bkd_fee,
        bkd_int_rebate                    = new_references.bkd_int_rebate,
        bkd_net                           = new_references.bkd_net,
        unbkd_gross                       = new_references.unbkd_gross,
        unbkd_fee                         = new_references.unbkd_fee,
        unbkd_int_rebate                  = new_references.unbkd_int_rebate,
        unbkd_net                         = new_references.unbkd_net,
        region_code                       = new_references.region_code,
        state_code                        = new_references.state_code,
        rec_count                         = new_references.rec_count,
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
    x_ytds_id                           IN OUT NOCOPY NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_disb_smr_type                     IN     VARCHAR2,
    x_bkd_gross                         IN     NUMBER,
    x_bkd_fee                           IN     NUMBER,
    x_bkd_int_rebate                    IN     NUMBER,
    x_bkd_net                           IN     NUMBER,
    x_unbkd_gross                       IN     NUMBER,
    x_unbkd_fee                         IN     NUMBER,
    x_unbkd_int_rebate                  IN     NUMBER,
    x_unbkd_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2,
    x_state_code                        IN     VARCHAR2,
    x_rec_count                         IN     NUMBER  ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 23-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_db_ytd_smr_all
      WHERE    ytds_id                           = x_ytds_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ytds_id,
        x_dl_version,
        x_record_type,
        x_batch_id,
        x_school_code,
        x_stat_end_dt,
        x_process_dt,
        x_disb_smr_type,
        x_bkd_gross,
        x_bkd_fee,
        x_bkd_int_rebate,
        x_bkd_net,
        x_unbkd_gross,
        x_unbkd_fee,
        x_unbkd_int_rebate,
        x_unbkd_net,
        x_region_code,
        x_state_code,
        x_rec_count,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ytds_id,
      x_dl_version,
      x_record_type,
      x_batch_id,
      x_school_code,
      x_stat_end_dt,
      x_process_dt,
      x_disb_smr_type,
      x_bkd_gross,
      x_bkd_fee,
      x_bkd_int_rebate,
      x_bkd_net,
      x_unbkd_gross,
      x_unbkd_fee,
      x_unbkd_int_rebate,
      x_unbkd_net,
      x_region_code,
      x_state_code,
      x_rec_count,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 23-JAN-2002
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

    DELETE FROM igf_db_ytd_smr_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_db_ytd_smr_pkg;

/