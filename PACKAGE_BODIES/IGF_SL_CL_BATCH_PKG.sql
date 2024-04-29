--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_BATCH_PKG" AS
/* $Header: IGFLI21B.pls 120.0 2005/06/02 15:52:14 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_cl_batch_all%ROWTYPE;
  new_references igf_sl_cl_batch_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_cbth_id                           IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_file_creation_date                IN     DATE        DEFAULT NULL,
    x_file_trans_date                   IN     DATE        DEFAULT NULL,
    x_file_ident_code                   IN     VARCHAR2    DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2    DEFAULT NULL,
    x_source_id                         IN     VARCHAR2    DEFAULT NULL,
    x_source_non_ed_brc_id              IN     VARCHAR2    DEFAULT NULL,
    x_send_resp                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_record_count_num                  IN     NUMBER      DEFAULT NULL,
    x_total_net_disb_amt                IN     NUMBER      DEFAULT NULL,
    x_total_net_eft_amt                 IN     NUMBER      DEFAULT NULL,
    x_total_net_non_eft_amt             IN     NUMBER      DEFAULT NULL,
    x_total_reissue_amt                 IN     NUMBER      DEFAULT NULL,
    x_total_cancel_amt                  IN     NUMBER      DEFAULT NULL,
    x_total_deficit_amt                 IN     NUMBER      DEFAULT NULL,
    x_total_net_cancel_amt              IN     NUMBER      DEFAULT NULL,
    x_total_net_out_cancel_amt          IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_sl_cl_batch_all
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
    new_references.cbth_id                           := x_cbth_id;
    new_references.batch_id                          := x_batch_id;
    new_references.file_creation_date                := x_file_creation_date;
    new_references.file_trans_date                   := x_file_trans_date;
    new_references.file_ident_code                   := x_file_ident_code;
    new_references.recipient_id                      := x_recipient_id;
    new_references.recip_non_ed_brc_id               := x_recip_non_ed_brc_id;
    new_references.source_id                         := x_source_id;
    new_references.source_non_ed_brc_id              := x_source_non_ed_brc_id;
    new_references.send_resp                         := x_send_resp;

    new_references.record_count_num		     := x_record_count_num;
    new_references.total_net_disb_amt		     := x_total_net_disb_amt;
    new_references.total_net_eft_amt		     := x_total_net_eft_amt;
    new_references.total_net_non_eft_amt		     := x_total_net_non_eft_amt;
    new_references.total_reissue_amt		     := x_total_reissue_amt;
    new_references.total_cancel_amt		     := x_total_cancel_amt;
    new_references.total_deficit_amt		     := x_total_deficit_amt;
    new_references.total_net_cancel_amt		     := x_total_net_cancel_amt;
    new_references.total_net_out_cancel_amt	     := x_total_net_out_cancel_amt;

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


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_sl_cl_resp_r1_pkg.get_fk_igf_sl_cl_batch (
      old_references.cbth_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_cbth_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_batch_all
      WHERE    cbth_id = x_cbth_id
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
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_cbth_id                           IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_file_creation_date                IN     DATE        DEFAULT NULL,
    x_file_trans_date                   IN     DATE        DEFAULT NULL,
    x_file_ident_code                   IN     VARCHAR2    DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2    DEFAULT NULL,
    x_source_id                         IN     VARCHAR2    DEFAULT NULL,
    x_source_non_ed_brc_id              IN     VARCHAR2    DEFAULT NULL,
    x_send_resp                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_record_count_num                  IN     NUMBER      DEFAULT NULL,
    x_total_net_disb_amt                IN     NUMBER      DEFAULT NULL,
    x_total_net_eft_amt                 IN     NUMBER      DEFAULT NULL,
    x_total_net_non_eft_amt             IN     NUMBER      DEFAULT NULL,
    x_total_reissue_amt                 IN     NUMBER      DEFAULT NULL,
    x_total_cancel_amt                  IN     NUMBER      DEFAULT NULL,
    x_total_deficit_amt                 IN     NUMBER      DEFAULT NULL,
    x_total_net_cancel_amt              IN     NUMBER      DEFAULT NULL,
    x_total_net_out_cancel_amt          IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
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
      x_cbth_id,
      x_batch_id,
      x_file_creation_date,
      x_file_trans_date,
      x_file_ident_code,
      x_recipient_id,
      x_recip_non_ed_brc_id,
      x_source_id,
      x_source_non_ed_brc_id,
      x_send_resp,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_record_count_num,
      x_total_net_disb_amt,
      x_total_net_eft_amt,
      x_total_net_non_eft_amt ,
      x_total_reissue_amt,
      x_total_cancel_amt,
      x_total_deficit_amt,
      x_total_net_cancel_amt,
      x_total_net_out_cancel_amt
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.cbth_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.cbth_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cbth_id                           IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_file_creation_date                IN     DATE,
    x_file_trans_date                   IN     DATE,
    x_file_ident_code                   IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_source_id                         IN     VARCHAR2,
    x_source_non_ed_brc_id              IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_record_count_num                  IN     NUMBER DEFAULT NULL,
    x_total_net_disb_amt                IN     NUMBER DEFAULT NULL,
    x_total_net_eft_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_non_eft_amt             IN     NUMBER DEFAULT NULL,
    x_total_reissue_amt                 IN     NUMBER DEFAULT NULL,
    x_total_cancel_amt                  IN     NUMBER DEFAULT NULL,
    x_total_deficit_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_cancel_amt              IN     NUMBER DEFAULT NULL,
    x_total_net_out_cancel_amt          IN     NUMBER DEFAULT NULL
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_cl_batch_all
      WHERE    cbth_id                           = x_cbth_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_sl_cl_batch_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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

    SELECT igf_sl_cl_batch_s.nextval
      INTO x_cbth_id
      FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_cbth_id                           => x_cbth_id,
      x_batch_id                          => x_batch_id,
      x_file_creation_date                => x_file_creation_date,
      x_file_trans_date                   => x_file_trans_date,
      x_file_ident_code                   => x_file_ident_code,
      x_recipient_id                      => x_recipient_id,
      x_recip_non_ed_brc_id               => x_recip_non_ed_brc_id,
      x_source_id                         => x_source_id,
      x_source_non_ed_brc_id              => x_source_non_ed_brc_id,
      x_send_resp                         => x_send_resp,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_record_count_num		  => x_record_count_num,
      x_total_net_disb_amt		  => x_total_net_disb_amt,
      x_total_net_eft_amt		  => x_total_net_eft_amt,
      x_total_net_non_eft_amt		  => x_total_net_non_eft_amt,
      x_total_reissue_amt		  => x_total_reissue_amt,
      x_total_cancel_amt		  => x_total_cancel_amt,
      x_total_deficit_amt		  => x_total_deficit_amt,
      x_total_net_cancel_amt		  => x_total_net_cancel_amt,
      x_total_net_out_cancel_amt	  => x_total_net_out_cancel_amt
    );

    INSERT INTO igf_sl_cl_batch_all (
      cbth_id,
      batch_id,
      file_creation_date,
      file_trans_date,
      file_ident_code,
      recipient_id,
      recip_non_ed_brc_id,
      source_id,
      source_non_ed_brc_id,
      send_resp,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id,
      record_count_num,
      total_net_disb_amt,
      total_net_eft_amt,
      total_net_non_eft_amt,
      total_reissue_amt,
      total_cancel_amt,
      total_deficit_amt,
      total_net_cancel_amt,
      total_net_out_cancel_amt
    ) VALUES (
      new_references.cbth_id,
      new_references.batch_id,
      new_references.file_creation_date,
      new_references.file_trans_date,
      new_references.file_ident_code,
      new_references.recipient_id,
      new_references.recip_non_ed_brc_id,
      new_references.source_id,
      new_references.source_non_ed_brc_id,
      new_references.send_resp,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      l_org_id,
      new_references.record_count_num,
      new_references.total_net_disb_amt,
      new_references.total_net_eft_amt,
      new_references.total_net_non_eft_amt ,
      new_references.total_reissue_amt,
      new_references.total_cancel_amt,
      new_references.total_deficit_amt,
      new_references.total_net_cancel_amt,
      new_references.total_net_out_cancel_amt
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
    x_cbth_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_file_creation_date                IN     DATE,
    x_file_trans_date                   IN     DATE,
    x_file_ident_code                   IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_source_id                         IN     VARCHAR2,
    x_source_non_ed_brc_id              IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_record_count_num                  IN     NUMBER,
    x_total_net_disb_amt                IN     NUMBER,
    x_total_net_eft_amt                 IN     NUMBER,
    x_total_net_non_eft_amt             IN     NUMBER,
    x_total_reissue_amt                 IN     NUMBER,
    x_total_cancel_amt                  IN     NUMBER,
    x_total_deficit_amt                 IN     NUMBER,
    x_total_net_cancel_amt              IN     NUMBER,
    x_total_net_out_cancel_amt          IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        batch_id,
        file_creation_date,
        file_trans_date,
        file_ident_code,
        recipient_id,
        recip_non_ed_brc_id,
        source_id,
        source_non_ed_brc_id,
        send_resp,
        org_id
      FROM  igf_sl_cl_batch_all
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
        ((tlinfo.batch_id = x_batch_id) OR ((tlinfo.batch_id IS NULL) AND (X_batch_id IS NULL)))
        AND ((tlinfo.file_creation_date = x_file_creation_date) OR ((tlinfo.file_creation_date IS NULL) AND (X_file_creation_date IS NULL)))
        AND ((tlinfo.file_trans_date = x_file_trans_date) OR ((tlinfo.file_trans_date IS NULL) AND (X_file_trans_date IS NULL)))
        AND ((tlinfo.file_ident_code = x_file_ident_code) OR ((tlinfo.file_ident_code IS NULL) AND (X_file_ident_code IS NULL)))
        AND ((tlinfo.recipient_id = x_recipient_id) OR ((tlinfo.recipient_id IS NULL) AND (X_recipient_id IS NULL)))
        AND ((tlinfo.recip_non_ed_brc_id = x_recip_non_ed_brc_id) OR ((tlinfo.recip_non_ed_brc_id IS NULL) AND (X_recip_non_ed_brc_id IS NULL)))
        AND ((tlinfo.source_id = x_source_id) OR ((tlinfo.source_id IS NULL) AND (X_source_id IS NULL)))
        AND ((tlinfo.source_non_ed_brc_id = x_source_non_ed_brc_id) OR ((tlinfo.source_non_ed_brc_id IS NULL) AND (X_source_non_ed_brc_id IS NULL)))
        AND ((tlinfo.send_resp = x_send_resp) OR ((tlinfo.send_resp IS NULL) AND (X_send_resp IS NULL)))
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
    x_cbth_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_file_creation_date                IN     DATE,
    x_file_trans_date                   IN     DATE,
    x_file_ident_code                   IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_source_id                         IN     VARCHAR2,
    x_source_non_ed_brc_id              IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_record_count_num                  IN     NUMBER DEFAULT NULL,
    x_total_net_disb_amt                IN     NUMBER DEFAULT NULL,
    x_total_net_eft_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_non_eft_amt             IN     NUMBER DEFAULT NULL,
    x_total_reissue_amt                 IN     NUMBER DEFAULT NULL,
    x_total_cancel_amt                  IN     NUMBER DEFAULT NULL,
    x_total_deficit_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_cancel_amt              IN     NUMBER DEFAULT NULL,
    x_total_net_out_cancel_amt          IN     NUMBER DEFAULT NULL
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
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
      x_cbth_id                           => x_cbth_id,
      x_batch_id                          => x_batch_id,
      x_file_creation_date                => x_file_creation_date,
      x_file_trans_date                   => x_file_trans_date,
      x_file_ident_code                   => x_file_ident_code,
      x_recipient_id                      => x_recipient_id,
      x_recip_non_ed_brc_id               => x_recip_non_ed_brc_id,
      x_source_id                         => x_source_id,
      x_source_non_ed_brc_id              => x_source_non_ed_brc_id,
      x_send_resp                         => x_send_resp,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_record_count_num		  => x_record_count_num,
      x_total_net_disb_amt		  => x_total_net_disb_amt,
      x_total_net_eft_amt		  => x_total_net_eft_amt,
      x_total_net_non_eft_amt		  => x_total_net_non_eft_amt,
      x_total_reissue_amt		  => x_total_reissue_amt,
      x_total_cancel_amt		  => x_total_cancel_amt,
      x_total_deficit_amt		  => x_total_deficit_amt,
      x_total_net_cancel_amt		  => x_total_net_cancel_amt,
      x_total_net_out_cancel_amt	  => x_total_net_out_cancel_amt
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

    UPDATE igf_sl_cl_batch_all
      SET
        batch_id                          = new_references.batch_id,
        file_creation_date                = new_references.file_creation_date,
        file_trans_date                   = new_references.file_trans_date,
        file_ident_code                   = new_references.file_ident_code,
        recipient_id                      = new_references.recipient_id,
        recip_non_ed_brc_id               = new_references.recip_non_ed_brc_id,
        source_id                         = new_references.source_id,
        source_non_ed_brc_id              = new_references.source_non_ed_brc_id,
        send_resp                         = new_references.send_resp,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        record_count_num		  = new_references.record_count_num,
        total_net_disb_amt		  = new_references.total_net_disb_amt,
        total_net_eft_amt		  = new_references.total_net_eft_amt,
        total_net_non_eft_amt		  = new_references.total_net_non_eft_amt ,
        total_reissue_amt		  = new_references.total_reissue_amt,
        total_cancel_amt		  = new_references.total_cancel_amt,
        total_deficit_amt		  = new_references.total_deficit_amt,
        total_net_cancel_amt		  = new_references.total_net_cancel_amt,
        total_net_out_cancel_amt	  = new_references.total_net_out_cancel_amt


      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cbth_id                           IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_file_creation_date                IN     DATE,
    x_file_trans_date                   IN     DATE,
    x_file_ident_code                   IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_source_id                         IN     VARCHAR2,
    x_source_non_ed_brc_id              IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_record_count_num                  IN     NUMBER DEFAULT NULL,
    x_total_net_disb_amt                IN     NUMBER DEFAULT NULL,
    x_total_net_eft_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_non_eft_amt             IN     NUMBER DEFAULT NULL,
    x_total_reissue_amt                 IN     NUMBER DEFAULT NULL,
    x_total_cancel_amt                  IN     NUMBER DEFAULT NULL,
    x_total_deficit_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_cancel_amt              IN     NUMBER DEFAULT NULL,
    x_total_net_out_cancel_amt          IN     NUMBER DEFAULT NULL
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_cl_batch_all
      WHERE    cbth_id                           = x_cbth_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_cbth_id,
        x_batch_id,
        x_file_creation_date,
        x_file_trans_date,
        x_file_ident_code,
        x_recipient_id,
        x_recip_non_ed_brc_id,
        x_source_id,
        x_source_non_ed_brc_id,
        x_send_resp,
        x_mode,
	x_record_count_num,
	x_total_net_disb_amt,
	x_total_net_eft_amt,
	x_total_net_non_eft_amt ,
	x_total_reissue_amt,
	x_total_cancel_amt,
	x_total_deficit_amt,
	x_total_net_cancel_amt,
	x_total_net_out_cancel_amt
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_cbth_id,
      x_batch_id,
      x_file_creation_date,
      x_file_trans_date,
      x_file_ident_code,
      x_recipient_id,
      x_recip_non_ed_brc_id,
      x_source_id,
      x_source_non_ed_brc_id,
      x_send_resp,
      x_mode,
      x_record_count_num,
      x_total_net_disb_amt,
      x_total_net_eft_amt,
      x_total_net_non_eft_amt ,
      x_total_reissue_amt,
      x_total_cancel_amt,
      x_total_deficit_amt,
      x_total_net_cancel_amt,
      x_total_net_out_cancel_amt
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
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

    DELETE FROM igf_sl_cl_batch_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_cl_batch_pkg;

/
