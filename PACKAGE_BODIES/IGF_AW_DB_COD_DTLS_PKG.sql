--------------------------------------------------------
--  DDL for Package Body IGF_AW_DB_COD_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_DB_COD_DTLS_PKG" AS
/* $Header: IGFWI65B.pls 120.0 2005/06/01 15:20:30 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_db_cod_dtls%ROWTYPE;
  new_references igf_aw_db_cod_dtls%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_orig_fee_amt                      IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_rel_flag                     IN     VARCHAR2,
    x_first_disb_flag                   IN     VARCHAR2,
    x_interest_rebate_amt               IN     NUMBER,
    x_disb_conf_flag                    IN     VARCHAR2,
    x_pymnt_per_start_date              IN     DATE,
    x_note_message                      IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 29-SEP-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_aw_db_cod_dtls
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
    new_references.document_id_txt                   := x_document_id_txt;
    new_references.disb_num                          := x_disb_num;
    new_references.disb_seq_num                      := x_disb_seq_num;
    new_references.disb_accepted_amt                 := x_disb_accepted_amt;
    new_references.orig_fee_amt                      := x_orig_fee_amt;
    new_references.disb_net_amt                      := x_disb_net_amt;
    new_references.disb_date                         := x_disb_date;
    new_references.disb_rel_flag                     := x_disb_rel_flag;
    new_references.first_disb_flag                   := x_first_disb_flag;
    new_references.interest_rebate_amt               := x_interest_rebate_amt;
    new_references.disb_conf_flag                    := x_disb_conf_flag;
    new_references.pymnt_per_start_date              := x_pymnt_per_start_date;
    new_references.note_message                      := x_note_message;
    new_references.rep_entity_id_txt                 := x_rep_entity_id_txt;
    new_references.atd_entity_id_txt                 := x_atd_entity_id_txt;


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
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 29-SEP-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_db_cod_dtls
      WHERE    award_id = x_award_id
      AND      disb_num = x_disb_num
      AND      disb_seq_num = x_disb_seq_num
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
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 29-SEP-2004
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_db_cod_dtls
      WHERE   ((award_id = x_award_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_AWD_DBCOD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_award;


  PROCEDURE get_fk_igf_aw_awd_disb (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 29-SEP-2004
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_db_cod_dtls
      WHERE    award_id = x_award_id
        AND    disb_num = x_disb_num;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_DB_DISB_DBCOD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_awd_disb;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_orig_fee_amt                      IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_rel_flag                     IN     VARCHAR2,
    x_first_disb_flag                   IN     VARCHAR2,
    x_interest_rebate_amt               IN     NUMBER,
    x_disb_conf_flag                    IN     VARCHAR2,
    x_pymnt_per_start_date              IN     DATE,
    x_note_message                      IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 29-SEP-2004
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
      x_document_id_txt,
      x_disb_num,
      x_disb_seq_num,
      x_disb_accepted_amt,
      x_orig_fee_amt,
      x_disb_net_amt,
      x_disb_date,
      x_disb_rel_flag,
      x_first_disb_flag,
      x_interest_rebate_amt,
      x_disb_conf_flag,
      x_pymnt_per_start_date,
      x_note_message,
      x_rep_entity_id_txt,
      x_atd_entity_id_txt,
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
             new_references.disb_num,
             new_references.disb_seq_num
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
             new_references.disb_num,
             new_references.disb_seq_num
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
    x_document_id_txt                   IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_orig_fee_amt                      IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_rel_flag                     IN     VARCHAR2,
    x_first_disb_flag                   IN     VARCHAR2,
    x_interest_rebate_amt               IN     NUMBER,
    x_disb_conf_flag                    IN     VARCHAR2,
    x_pymnt_per_start_date              IN     DATE,
    x_note_message                      IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 29-SEP-2004
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_db_cod_dtls
      WHERE    award_id                          = x_award_id
      AND      disb_num                          = x_disb_num
      AND      disb_seq_num                      = x_disb_seq_num;

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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_DB_COD_DTLS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_award_id                          => x_award_id,
      x_document_id_txt                   => x_document_id_txt,
      x_disb_num                          => x_disb_num,
      x_disb_seq_num                      => x_disb_seq_num,
      x_disb_accepted_amt                 => x_disb_accepted_amt,
      x_orig_fee_amt                      => x_orig_fee_amt,
      x_disb_net_amt                      => x_disb_net_amt,
      x_disb_date                         => x_disb_date,
      x_disb_rel_flag                     => x_disb_rel_flag,
      x_first_disb_flag                   => x_first_disb_flag,
      x_interest_rebate_amt               => x_interest_rebate_amt,
      x_disb_conf_flag                    => x_disb_conf_flag,
      x_pymnt_per_start_date              => x_pymnt_per_start_date,
      x_note_message                      => x_note_message,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_db_cod_dtls (
      award_id,
      document_id_txt,
      disb_num,
      disb_seq_num,
      disb_accepted_amt,
      orig_fee_amt,
      disb_net_amt,
      disb_date,
      disb_rel_flag,
      first_disb_flag,
      interest_rebate_amt,
      disb_conf_flag,
      pymnt_per_start_date,
      note_message,
      rep_entity_id_txt,
      atd_entity_id_txt,
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
      new_references.award_id,
      new_references.document_id_txt,
      new_references.disb_num,
      new_references.disb_seq_num,
      new_references.disb_accepted_amt,
      new_references.orig_fee_amt,
      new_references.disb_net_amt,
      new_references.disb_date,
      new_references.disb_rel_flag,
      new_references.first_disb_flag,
      new_references.interest_rebate_amt,
      new_references.disb_conf_flag,
      new_references.pymnt_per_start_date,
      new_references.note_message,
      new_references.rep_entity_id_txt,
      new_references.atd_entity_id_txt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID INTO x_rowid;


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
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_orig_fee_amt                      IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_rel_flag                     IN     VARCHAR2,
    x_first_disb_flag                   IN     VARCHAR2,
    x_interest_rebate_amt               IN     NUMBER,
    x_disb_conf_flag                    IN     VARCHAR2,
    x_pymnt_per_start_date              IN     DATE,
    x_note_message                      IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 29-SEP-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        document_id_txt,
        disb_accepted_amt,
        orig_fee_amt,
        disb_net_amt,
        disb_date,
        disb_rel_flag,
        first_disb_flag,
        interest_rebate_amt,
        disb_conf_flag,
        pymnt_per_start_date,
        note_message,
        rep_entity_id_txt,
        atd_entity_id_txt
      FROM  igf_aw_db_cod_dtls
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
        ((tlinfo.document_id_txt = x_document_id_txt) OR ((tlinfo.document_id_txt IS NULL) AND (X_document_id_txt IS NULL)))
        AND (tlinfo.disb_accepted_amt = x_disb_accepted_amt)
        AND ((tlinfo.orig_fee_amt = x_orig_fee_amt) OR ((tlinfo.orig_fee_amt IS NULL) AND (X_orig_fee_amt IS NULL)))
        AND ((tlinfo.disb_net_amt = x_disb_net_amt) OR ((tlinfo.disb_net_amt IS NULL) AND (X_disb_net_amt IS NULL)))
        AND (tlinfo.disb_date = x_disb_date)
        AND ((tlinfo.disb_rel_flag = x_disb_rel_flag) OR ((tlinfo.disb_rel_flag IS NULL) AND (X_disb_rel_flag IS NULL)))
        AND ((tlinfo.first_disb_flag = x_first_disb_flag) OR ((tlinfo.first_disb_flag IS NULL) AND (X_first_disb_flag IS NULL)))
        AND ((tlinfo.interest_rebate_amt = x_interest_rebate_amt) OR ((tlinfo.interest_rebate_amt IS NULL) AND (X_interest_rebate_amt IS NULL)))
        AND ((tlinfo.disb_conf_flag = x_disb_conf_flag) OR ((tlinfo.disb_conf_flag IS NULL) AND (X_disb_conf_flag IS NULL)))
        AND ((tlinfo.pymnt_per_start_date = x_pymnt_per_start_date) OR ((tlinfo.pymnt_per_start_date IS NULL) AND (X_pymnt_per_start_date IS NULL)))
        AND ((tlinfo.note_message = x_note_message) OR ((tlinfo.note_message IS NULL) AND (X_note_message IS NULL)))
        AND ((tlinfo.rep_entity_id_txt = x_rep_entity_id_txt) OR ((tlinfo.rep_entity_id_txt IS NULL) AND (X_rep_entity_id_txt IS NULL)))
        AND ((tlinfo.atd_entity_id_txt = x_atd_entity_id_txt) OR ((tlinfo.atd_entity_id_txt IS NULL) AND (X_atd_entity_id_txt IS NULL)))
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
    x_document_id_txt                   IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_orig_fee_amt                      IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_rel_flag                     IN     VARCHAR2,
    x_first_disb_flag                   IN     VARCHAR2,
    x_interest_rebate_amt               IN     NUMBER,
    x_disb_conf_flag                    IN     VARCHAR2,
    x_pymnt_per_start_date              IN     DATE,
    x_note_message                      IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 29-SEP-2004
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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_DB_COD_DTLS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_award_id                          => x_award_id,
      x_document_id_txt                   => x_document_id_txt,
      x_disb_num                          => x_disb_num,
      x_disb_seq_num                      => x_disb_seq_num,
      x_disb_accepted_amt                 => x_disb_accepted_amt,
      x_orig_fee_amt                      => x_orig_fee_amt,
      x_disb_net_amt                      => x_disb_net_amt,
      x_disb_date                         => x_disb_date,
      x_disb_rel_flag                     => x_disb_rel_flag,
      x_first_disb_flag                   => x_first_disb_flag,
      x_interest_rebate_amt               => x_interest_rebate_amt,
      x_disb_conf_flag                    => x_disb_conf_flag,
      x_pymnt_per_start_date              => x_pymnt_per_start_date,
      x_note_message                      => x_note_message,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
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

    UPDATE igf_aw_db_cod_dtls
      SET
        document_id_txt                   = new_references.document_id_txt,
        disb_accepted_amt                 = new_references.disb_accepted_amt,
        orig_fee_amt                      = new_references.orig_fee_amt,
        disb_net_amt                      = new_references.disb_net_amt,
        disb_date                         = new_references.disb_date,
        disb_rel_flag                     = new_references.disb_rel_flag,
        first_disb_flag                   = new_references.first_disb_flag,
        interest_rebate_amt               = new_references.interest_rebate_amt,
        disb_conf_flag                    = new_references.disb_conf_flag,
        pymnt_per_start_date              = new_references.pymnt_per_start_date,
        note_message                      = new_references.note_message,
        rep_entity_id_txt                 = new_references.rep_entity_id_txt,
        atd_entity_id_txt                 = new_references.atd_entity_id_txt,
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
    x_award_id                          IN     NUMBER,
    x_document_id_txt                   IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_orig_fee_amt                      IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_rel_flag                     IN     VARCHAR2,
    x_first_disb_flag                   IN     VARCHAR2,
    x_interest_rebate_amt               IN     NUMBER,
    x_disb_conf_flag                    IN     VARCHAR2,
    x_pymnt_per_start_date              IN     DATE,
    x_note_message                      IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 29-SEP-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_db_cod_dtls
      WHERE    award_id                          = x_award_id
      AND      disb_num                          = x_disb_num
      AND      disb_seq_num                      = x_disb_seq_num;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_award_id,
        x_document_id_txt,
        x_disb_num,
        x_disb_seq_num,
        x_disb_accepted_amt,
        x_orig_fee_amt,
        x_disb_net_amt,
        x_disb_date,
        x_disb_rel_flag,
        x_first_disb_flag,
        x_interest_rebate_amt,
        x_disb_conf_flag,
        x_pymnt_per_start_date,
        x_note_message,
        x_rep_entity_id_txt,
        x_atd_entity_id_txt,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_award_id,
      x_document_id_txt,
      x_disb_num,
      x_disb_seq_num,
      x_disb_accepted_amt,
      x_orig_fee_amt,
      x_disb_net_amt,
      x_disb_date,
      x_disb_rel_flag,
      x_first_disb_flag,
      x_interest_rebate_amt,
      x_disb_conf_flag,
      x_pymnt_per_start_date,
      x_note_message,
      x_rep_entity_id_txt,
      x_atd_entity_id_txt,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : bhaskar.annamalai@oracle.com
  ||  Created On : 29-SEP-2004
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

    DELETE FROM igf_aw_db_cod_dtls
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_db_cod_dtls_pkg;

/
