--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_RESP_R8_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_RESP_R8_PKG" AS
/* $Header: IGFLI23B.pls 120.1 2006/08/08 06:26:09 akomurav noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_cl_resp_r8_all%ROWTYPE;
  new_references igf_sl_cl_resp_r8_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clrp1_id                          IN     NUMBER      DEFAULT NULL,
    x_clrp8_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_date                         IN     DATE        DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_orig_fee                          IN     NUMBER      DEFAULT NULL,
    x_guarantee_fee                     IN     NUMBER      DEFAULT NULL,
    x_net_disb_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_hold_rel_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_disb_status                       IN     VARCHAR2    DEFAULT NULL,
    x_guarnt_fee_paid                   IN     NUMBER      DEFAULT NULL,
    x_orig_fee_paid                     IN     NUMBER      DEFAULT NULL,
    x_resp_record_status                IN     VARCHAR2    DEFAULT NULL,
    x_layout_owner_code_txt             IN     VARCHAR2    DEFAULT NULL,
    x_layout_version_code_txt           IN     VARCHAR2    DEFAULT NULL,
    x_record_code_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_direct_to_borr_flag               IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 02-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_sl_cl_resp_r8_all
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
    new_references.clrp1_id                          := x_clrp1_id;
    new_references.clrp8_id                          := x_clrp8_id;
    new_references.disb_date                         := x_disb_date;
    new_references.disb_gross_amt                    := x_disb_gross_amt;
    new_references.orig_fee                          := x_orig_fee;
    new_references.guarantee_fee                     := x_guarantee_fee;
    new_references.net_disb_amt                      := x_net_disb_amt;
    new_references.disb_hold_rel_ind                 := x_disb_hold_rel_ind;
    new_references.disb_status                       := x_disb_status;
    new_references.guarnt_fee_paid                   := x_guarnt_fee_paid;
    new_references.orig_fee_paid                     := x_orig_fee_paid;
    new_references.resp_record_status                := x_resp_record_status;

    new_references.layout_owner_code_txt             := x_layout_owner_code_txt;
    new_references.layout_version_code_txt           := x_layout_version_code_txt;
    new_references.record_code_txt                   := x_record_code_txt;

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
    new_references.direct_to_borr_flag             := x_direct_to_borr_flag;

  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 02-NOV-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.clrp1_id = new_references.clrp1_id)) OR
        ((new_references.clrp1_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_cl_resp_r1_pkg.get_pk_for_validation (
                new_references.clrp1_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_clrp1_id                          IN     NUMBER,
    x_clrp8_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 02-NOV-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r8_all
      WHERE    clrp1_id = x_clrp1_id
      AND      clrp8_id = x_clrp8_id
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


  PROCEDURE get_fk_igf_sl_cl_resp_r1 (
    x_clrp1_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 02-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r8_all
      WHERE   ((clrp1_id = x_clrp1_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_CLRP8_CLRP1_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_cl_resp_r1;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clrp1_id                          IN     NUMBER      DEFAULT NULL,
    x_clrp8_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_date                         IN     DATE        DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_orig_fee                          IN     NUMBER      DEFAULT NULL,
    x_guarantee_fee                     IN     NUMBER      DEFAULT NULL,
    x_net_disb_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_hold_rel_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_disb_status                       IN     VARCHAR2    DEFAULT NULL,
    x_guarnt_fee_paid                   IN     NUMBER      DEFAULT NULL,
    x_orig_fee_paid                     IN     NUMBER      DEFAULT NULL,
    x_resp_record_status                IN     VARCHAR2    DEFAULT NULL,
    x_layout_owner_code_txt             IN     VARCHAR2    DEFAULT NULL,
    x_layout_version_code_txt           IN     VARCHAR2    DEFAULT NULL,
    x_record_code_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_direct_to_borr_flag               IN     VARCHAR2     DEFAULT NULL

  ) AS
  /*
  ||  Created By : mesriniv
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
      x_clrp1_id,
      x_clrp8_id,
      x_disb_date,
      x_disb_gross_amt,
      x_orig_fee,
      x_guarantee_fee,
      x_net_disb_amt,
      x_disb_hold_rel_ind,
      x_disb_status,
      x_guarnt_fee_paid,
      x_orig_fee_paid,
      x_resp_record_status,
      x_layout_owner_code_txt,
      x_layout_version_code_txt,
      x_record_code_txt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_direct_to_borr_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.clrp1_id,
             new_references.clrp8_id
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
             new_references.clrp1_id,
             new_references.clrp8_id
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
    x_clrp1_id                          IN     NUMBER,
    x_clrp8_id                          IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_gross_amt                    IN     NUMBER,
    x_orig_fee                          IN     NUMBER,
    x_guarantee_fee                     IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_disb_hold_rel_ind                 IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_guarnt_fee_paid                   IN     NUMBER,
    x_orig_fee_paid                     IN     NUMBER,
    x_resp_record_status                IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2,
    x_layout_version_code_txt           IN     VARCHAR2,
    x_record_code_txt                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_direct_to_borr_flag               IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 02-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r8_all
      WHERE    clrp1_id                          = x_clrp1_id
      AND      clrp8_id                          = x_clrp8_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_sl_cl_resp_r8_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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
      x_clrp1_id                          => x_clrp1_id,
      x_clrp8_id                          => x_clrp8_id,
      x_disb_date                         => x_disb_date,
      x_disb_gross_amt                    => x_disb_gross_amt,
      x_orig_fee                          => x_orig_fee,
      x_guarantee_fee                     => x_guarantee_fee,
      x_net_disb_amt                      => x_net_disb_amt,
      x_disb_hold_rel_ind                 => x_disb_hold_rel_ind,
      x_disb_status                       => x_disb_status,
      x_guarnt_fee_paid                   => x_guarnt_fee_paid,
      x_orig_fee_paid                     => x_orig_fee_paid,
      x_resp_record_status                => x_resp_record_status,
      x_layout_owner_code_txt             => x_layout_owner_code_txt,
      x_layout_version_code_txt           => x_layout_version_code_txt,
      x_record_code_txt                   => x_record_code_txt,

      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_direct_to_borr_flag               => x_direct_to_borr_flag
    );

    INSERT INTO igf_sl_cl_resp_r8_all (
      clrp1_id,
      clrp8_id,
      disb_date,
      disb_gross_amt,
      orig_fee,
      guarantee_fee,
      net_disb_amt,
      disb_hold_rel_ind,
      disb_status,
      guarnt_fee_paid,
      orig_fee_paid,
      resp_record_status,
      layout_owner_code_txt,
      layout_version_code_txt,
      record_code_txt,
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
      direct_to_borr_flag
    ) VALUES (
      new_references.clrp1_id,
      new_references.clrp8_id,
      new_references.disb_date,
      new_references.disb_gross_amt,
      new_references.orig_fee,
      new_references.guarantee_fee,
      new_references.net_disb_amt,
      new_references.disb_hold_rel_ind,
      new_references.disb_status,
      new_references.guarnt_fee_paid,
      new_references.orig_fee_paid,
      new_references.resp_record_status,
      new_references.layout_owner_code_txt,
      new_references.layout_version_code_txt,
      new_references.record_code_txt,
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
      new_references.direct_to_borr_flag
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
    x_clrp1_id                          IN     NUMBER,
    x_clrp8_id                          IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_gross_amt                    IN     NUMBER,
    x_orig_fee                          IN     NUMBER,
    x_guarantee_fee                     IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_disb_hold_rel_ind                 IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_guarnt_fee_paid                   IN     NUMBER,
    x_orig_fee_paid                     IN     NUMBER,
    x_resp_record_status                IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2,
    x_layout_version_code_txt           IN     VARCHAR2,
    x_record_code_txt                   IN     VARCHAR2,
    x_direct_to_borr_flag               IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 02-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        disb_date,
        disb_gross_amt,
        orig_fee,
        guarantee_fee,
        net_disb_amt,
        disb_hold_rel_ind,
        disb_status,
        guarnt_fee_paid,
        orig_fee_paid,
        resp_record_status,
        org_id,
        layout_owner_code_txt,
        layout_version_code_txt,
        record_code_txt,
	direct_to_borr_flag

      FROM  igf_sl_cl_resp_r8_all
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
        ((tlinfo.disb_date = x_disb_date) OR ((tlinfo.disb_date IS NULL) AND (X_disb_date IS NULL)))
        AND ((tlinfo.disb_gross_amt = x_disb_gross_amt) OR ((tlinfo.disb_gross_amt IS NULL) AND (X_disb_gross_amt IS NULL)))
        AND ((tlinfo.orig_fee = x_orig_fee) OR ((tlinfo.orig_fee IS NULL) AND (X_orig_fee IS NULL)))
        AND ((tlinfo.guarantee_fee = x_guarantee_fee) OR ((tlinfo.guarantee_fee IS NULL) AND (X_guarantee_fee IS NULL)))
        AND ((tlinfo.net_disb_amt = x_net_disb_amt) OR ((tlinfo.net_disb_amt IS NULL) AND (X_net_disb_amt IS NULL)))
        AND ((tlinfo.disb_hold_rel_ind = x_disb_hold_rel_ind) OR ((tlinfo.disb_hold_rel_ind IS NULL) AND (X_disb_hold_rel_ind IS NULL)))
        AND ((tlinfo.disb_status = x_disb_status) OR ((tlinfo.disb_status IS NULL) AND (X_disb_status IS NULL)))
        AND ((tlinfo.guarnt_fee_paid = x_guarnt_fee_paid) OR ((tlinfo.guarnt_fee_paid IS NULL) AND (X_guarnt_fee_paid IS NULL)))
        AND ((tlinfo.orig_fee_paid = x_orig_fee_paid) OR ((tlinfo.orig_fee_paid IS NULL) AND (X_orig_fee_paid IS NULL)))
        AND ((tlinfo.resp_record_status = x_resp_record_status) OR ((tlinfo.resp_record_status IS NULL) AND (X_resp_record_status IS NULL)))
        AND ((tlinfo.layout_owner_code_txt = x_layout_owner_code_txt) OR ((tlinfo.layout_owner_code_txt IS NULL) AND (X_layout_owner_code_txt IS NULL)))
        AND ((tlinfo.layout_version_code_txt = x_layout_version_code_txt) OR ((tlinfo.layout_version_code_txt IS NULL) AND (X_layout_version_code_txt IS NULL)))
        AND ((tlinfo.record_code_txt = x_record_code_txt) OR ((tlinfo.record_code_txt IS NULL) AND (X_record_code_txt IS NULL)))
	AND ((tlinfo.direct_to_borr_flag = x_direct_to_borr_flag) OR ((tlinfo.direct_to_borr_flag IS NULL) AND (x_direct_to_borr_flag IS NULL)))

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
    x_clrp1_id                          IN     NUMBER,
    x_clrp8_id                          IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_gross_amt                    IN     NUMBER,
    x_orig_fee                          IN     NUMBER,
    x_guarantee_fee                     IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_disb_hold_rel_ind                 IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_guarnt_fee_paid                   IN     NUMBER,
    x_orig_fee_paid                     IN     NUMBER,
    x_resp_record_status                IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2,
    x_layout_version_code_txt           IN     VARCHAR2,
    x_record_code_txt                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_direct_to_borr_flag               IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : mesriniv
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
      x_clrp1_id                          => x_clrp1_id,
      x_clrp8_id                          => x_clrp8_id,
      x_disb_date                         => x_disb_date,
      x_disb_gross_amt                    => x_disb_gross_amt,
      x_orig_fee                          => x_orig_fee,
      x_guarantee_fee                     => x_guarantee_fee,
      x_net_disb_amt                      => x_net_disb_amt,
      x_disb_hold_rel_ind                 => x_disb_hold_rel_ind,
      x_disb_status                       => x_disb_status,
      x_guarnt_fee_paid                   => x_guarnt_fee_paid,
      x_orig_fee_paid                     => x_orig_fee_paid,
      x_resp_record_status                => x_resp_record_status,
      x_layout_owner_code_txt             => x_layout_owner_code_txt,
      x_layout_version_code_txt           => x_layout_version_code_txt,
      x_record_code_txt                   => x_record_code_txt,

      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_direct_to_borr_flag               => x_direct_to_borr_flag
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

    UPDATE igf_sl_cl_resp_r8_all
      SET
        disb_date                         = new_references.disb_date,
        disb_gross_amt                    = new_references.disb_gross_amt,
        orig_fee                          = new_references.orig_fee,
        guarantee_fee                     = new_references.guarantee_fee,
        net_disb_amt                      = new_references.net_disb_amt,
        disb_hold_rel_ind                 = new_references.disb_hold_rel_ind,
        disb_status                       = new_references.disb_status,
        guarnt_fee_paid                   = new_references.guarnt_fee_paid,
        orig_fee_paid                     = new_references.orig_fee_paid,
        resp_record_status                = new_references.resp_record_status,
        layout_owner_code_txt             = new_references.layout_owner_code_txt,
        layout_version_code_txt           = new_references.layout_version_code_txt,
        record_code_txt                   = new_references.record_code_txt,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
	direct_to_borr_flag               = new_references.direct_to_borr_flag
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clrp1_id                          IN     NUMBER,
    x_clrp8_id                          IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_gross_amt                    IN     NUMBER,
    x_orig_fee                          IN     NUMBER,
    x_guarantee_fee                     IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_disb_hold_rel_ind                 IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_guarnt_fee_paid                   IN     NUMBER,
    x_orig_fee_paid                     IN     NUMBER,
    x_resp_record_status                IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2,
    x_layout_version_code_txt           IN     VARCHAR2,
    x_record_code_txt                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_direct_to_borr_flag               IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 02-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r8_all
      WHERE    clrp1_id                          = x_clrp1_id
      AND      clrp8_id                          = x_clrp8_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_clrp1_id,
        x_clrp8_id,
        x_disb_date,
        x_disb_gross_amt,
        x_orig_fee,
        x_guarantee_fee,
        x_net_disb_amt,
        x_disb_hold_rel_ind,
        x_disb_status,
        x_guarnt_fee_paid,
        x_orig_fee_paid,
        x_resp_record_status,
        x_layout_owner_code_txt,
        x_layout_version_code_txt,
        x_record_code_txt,
        x_mode,
	x_direct_to_borr_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_clrp1_id,
      x_clrp8_id,
      x_disb_date,
      x_disb_gross_amt,
      x_orig_fee,
      x_guarantee_fee,
      x_net_disb_amt,
      x_disb_hold_rel_ind,
      x_disb_status,
      x_guarnt_fee_paid,
      x_orig_fee_paid,
      x_resp_record_status,
      x_layout_owner_code_txt,
      x_layout_version_code_txt,
      x_record_code_txt,
      x_mode,
      x_direct_to_borr_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : mesriniv
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

    DELETE FROM igf_sl_cl_resp_r8_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_cl_resp_r8_pkg;

/
