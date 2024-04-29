--------------------------------------------------------
--  DDL for Package Body IGF_AW_COA_ITM_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_COA_ITM_TERMS_PKG" AS
/* $Header: IGFWI58B.pls 120.0 2005/06/01 14:23:56 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_coa_itm_terms%ROWTYPE;
  new_references igf_aw_coa_itm_terms%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_lock_flag                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_aw_coa_itm_terms
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
    new_references.base_id                           := x_base_id;
    new_references.item_code                         := x_item_code;
    new_references.amount                            := x_amount;
    new_references.ld_cal_type                       := x_ld_cal_type;
    new_references.ld_sequence_number                := x_ld_sequence_number;
    new_references.lock_flag                          := x_lock_flag;

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
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.base_id = new_references.base_id) AND
         (old_references.item_code = new_references.item_code)) OR
        ((new_references.base_id IS NULL) OR
         (new_references.item_code IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_coa_items_pkg.get_pk_for_validation (
                new_references.base_id,
                new_references.item_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.ld_cal_type = new_references.ld_cal_type) AND
         (old_references.ld_sequence_number = new_references.ld_sequence_number)) OR
        ((new_references.ld_cal_type IS NULL) OR
         (new_references.ld_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.ld_cal_type,
                new_references.ld_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_coa_itm_terms
      WHERE    base_id = x_base_id
      AND      ld_cal_type = x_ld_cal_type
      AND      ld_sequence_number = x_ld_sequence_number
      AND      item_code = x_item_code
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


  PROCEDURE get_fk_igf_aw_coa_items (
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_coa_itm_terms
      WHERE   ((base_id = x_base_id) AND
               (item_code = x_item_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_COAIT_COAI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_coa_items;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_coa_itm_terms
      WHERE   ((ld_cal_type = x_cal_type) AND
               (ld_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_COAIT_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_lock_flag                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
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
      x_base_id,
      x_item_code,
      x_amount,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_lock_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.base_id,
             new_references.ld_cal_type,
             new_references.ld_sequence_number,
             new_references.item_code
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
             new_references.base_id,
             new_references.ld_cal_type,
             new_references.ld_sequence_number,
             new_references.item_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;

  PROCEDURE AfterRowInsertUpdateDelete2(
    p_inserting IN BOOLEAN ,
    p_updating  IN BOOLEAN ,
    p_deleting  IN BOOLEAN
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By : veramach
  ||  Created On : 16-Nov-2004
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
  lv_rowid         ROWID;
  l_coah_id        igf_aw_coa_hist.coah_id%TYPE;
  l_operation_txt  igf_aw_coa_hist.operation_txt%TYPE;
  l_base_id        igf_ap_fa_base_rec_all.base_id%TYPE;
  l_ld_cal_type    igs_ca_inst.cal_type%TYPE;
  l_ld_seq_num     igs_ca_inst.sequence_number%TYPE;
  l_item_code      igf_aw_item.item_code%TYPE;

  BEGIN
    IF p_updating THEN
      l_operation_txt := 'UPDATE';
      l_base_id       := old_references.base_id;
      l_ld_cal_type   := old_references.ld_cal_type;
      l_ld_seq_num    := old_references.ld_sequence_number;
      l_item_code     := old_references.item_code;
    ELSIF p_inserting THEN
      l_operation_txt := 'INSERT';
      l_base_id       := new_references.base_id;
      l_ld_cal_type   := new_references.ld_cal_type;
      l_ld_seq_num    := new_references.ld_sequence_number;
      l_item_code     := new_references.item_code;
    ELSIF p_deleting THEN
      l_operation_txt := 'DELETE';
      l_base_id       := old_references.base_id;
      l_ld_cal_type   := old_references.ld_cal_type;
      l_ld_seq_num    := old_references.ld_sequence_number;
      l_item_code     := old_references.item_code;
    END IF;
    lv_rowid  := NULL;
    l_coah_id := NULL;
    IF NVL(old_references.amount,-1) <> NVL(new_references.amount,-1) THEN
      igf_aw_coa_hist_pkg.insert_row(
                                     x_rowid              => lv_rowid,
                                     x_coah_id            => l_coah_id,
                                     x_base_id            => l_base_id,
                                     x_tran_date          => SYSDATE,
                                     x_item_code          => l_item_code,
                                     x_ld_cal_type        => l_ld_cal_type,
                                     x_ld_sequence_number => l_ld_seq_num,
                                     x_operation_txt      => l_operation_txt,
                                     x_old_value          => old_references.amount,
                                     x_new_value          => new_references.amount,
                                     x_mode               => 'R'
                                    );
    END IF;
  END AfterRowInsertUpdateDelete2;

  PROCEDURE AfterRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating  IN BOOLEAN ,
    p_deleting  IN BOOLEAN
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By : veramach
  ||  Created On : 16-Nov-2004
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
  lv_rowid  ROWID;
  l_coah_id igf_aw_coa_hist.coah_id%TYPE;
  l_operation_txt igf_aw_coa_hist.operation_txt%TYPE;

  BEGIN
    IF NVL(old_references.lock_flag,'N') <> NVL(new_references.lock_flag,'N')  AND NVL(old_references.lock_flag,'N') = 'Y' THEN
      l_operation_txt := 'UNLOCK';
    ELSIF NVL(old_references.lock_flag,'N') <> NVL(new_references.lock_flag,'N')  AND NVL(old_references.lock_flag,'N') = 'N' THEN
      l_operation_txt := 'LOCK';
    ELSE
      RETURN;
    END IF;
    lv_rowid  := NULL;
    l_coah_id := NULL;
    igf_aw_coa_hist_pkg.insert_row(
                                   x_rowid              => lv_rowid,
                                   x_coah_id            => l_coah_id,
                                   x_base_id            => NVL(old_references.base_id,new_references.base_id),
                                   x_tran_date          => SYSDATE,
                                   x_item_code          => NVL(old_references.item_code,new_references.item_code),
                                   x_ld_cal_type        => NVL(old_references.ld_cal_type,new_references.ld_cal_type),
                                   x_ld_sequence_number => NVL(old_references.ld_sequence_number,new_references.ld_sequence_number),
                                   x_operation_txt      => l_operation_txt,
                                   x_old_value          => NULL,
                                   x_new_value          => NULL,
                                   x_mode               => 'R'
                                  );
  END AfterRowInsertUpdateDelete1;

  PROCEDURE after_dml(
                      p_action IN VARCHAR2,
                      x_rowid IN VARCHAR2
                     ) AS
   /*-----------------------------------------------------------------
  ||  Created By : veramach
  ||  Created On : 16-Nov-2004
  ||  Purpose : Invoke the proceduers related to after update
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      AfterRowInsertUpdateDelete1(
                                  p_inserting => TRUE,
                                  p_updating  => FALSE ,
                                  p_deleting  => FALSE
                                 );
      AfterRowInsertUpdateDelete2(
                                  p_inserting => TRUE,
                                  p_updating  => FALSE ,
                                  p_deleting  => FALSE
                                 );
    END IF;
    IF (p_action = 'DELETE') THEN
      AfterRowInsertUpdateDelete1(
                                  p_inserting => FALSE,
                                  p_updating  => FALSE ,
                                  p_deleting  => TRUE
                                 );
      AfterRowInsertUpdateDelete2(
                                  p_inserting => FALSE,
                                  p_updating  => FALSE ,
                                  p_deleting  => TRUE
                                 );
    END IF;
    IF (p_action = 'UPDATE') THEN
      AfterRowInsertUpdateDelete1(
                                  p_inserting => FALSE,
                                  p_updating  => TRUE ,
                                  p_deleting  => FALSE
                                 );
      AfterRowInsertUpdateDelete2(
                                  p_inserting => FALSE,
                                  p_updating  => TRUE ,
                                  p_deleting  => FALSE
                                 );
    END IF;
    l_rowid := NULL;
  END after_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_lock_flag                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_base_id                           => x_base_id,
      x_item_code                         => x_item_code,
      x_amount                            => x_amount,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_lock_flag                          => x_lock_flag
    );

    INSERT INTO igf_aw_coa_itm_terms (
      base_id,
      item_code,
      amount,
      ld_cal_type,
      ld_sequence_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      lock_flag
    ) VALUES (
      new_references.base_id,
      new_references.item_code,
      new_references.amount,
      new_references.ld_cal_type,
      new_references.ld_sequence_number,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.lock_flag
    ) RETURNING ROWID INTO x_rowid;

    after_dml(
              p_action => 'INSERT',
              x_rowid  => x_rowid
             );
  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_lock_flag                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        amount,
        lock_flag
      FROM  igf_aw_coa_itm_terms
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
        (tlinfo.amount = x_amount)
        AND ((tlinfo.lock_flag = x_lock_flag) OR ((tlinfo.lock_flag IS NULL) AND (x_lock_flag IS NULL)))
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
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_lock_flag                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
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
      x_base_id                           => x_base_id,
      x_item_code                         => x_item_code,
      x_amount                            => x_amount,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_lock_flag                          => x_lock_flag
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

    UPDATE igf_aw_coa_itm_terms
      SET
        amount                            = new_references.amount,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        lock_flag                          = new_references.lock_flag
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    after_dml(
              p_action => 'UPDATE',
              x_rowid  => x_rowid
             );
  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_lock_flag                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_coa_itm_terms
      WHERE    base_id                           = x_base_id
      AND      ld_cal_type                       = x_ld_cal_type
      AND      ld_sequence_number                = x_ld_sequence_number
      AND      item_code                         = x_item_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_base_id,
        x_item_code,
        x_amount,
        x_ld_cal_type,
        x_ld_sequence_number,
        x_mode,
        x_lock_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_base_id,
      x_item_code,
      x_amount,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_mode,
      x_lock_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 19-OCT-2002
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

    DELETE FROM igf_aw_coa_itm_terms
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    after_dml(
              p_action => 'DELETE',
              x_rowid  => x_rowid
             );

  END delete_row;


END igf_aw_coa_itm_terms_pkg;

/
