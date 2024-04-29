--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_SETUP_PKG" AS
/* $Header: IGFLI07B.pls 120.0 2005/06/01 15:12:03 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_dl_setup_all%ROWTYPE;
  new_references igf_sl_dl_setup_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dlset_id                          IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_school_id                         IN     VARCHAR2    DEFAULT NULL,
    x_orig_fee_perct_stafford           IN     NUMBER      DEFAULT NULL,
    x_orig_fee_perct_plus               IN     NUMBER      DEFAULT NULL,
    x_int_rebate                        IN     NUMBER      DEFAULT NULL,
    x_pnote_print_ind                   IN     VARCHAR2    DEFAULT NULL,
    x_pnote_print_copies                IN     NUMBER      DEFAULT NULL,
    x_acc_note_for_disb                 IN     VARCHAR2    DEFAULT NULL,
    x_affirmation_reqd                  IN     VARCHAR2    DEFAULT NULL,
    x_interview_reqd                    IN     VARCHAR2    DEFAULT NULL,
    x_disclosure_print_ind              IN     VARCHAR2    DEFAULT NULL,
    x_special_school                    IN     VARCHAR2    DEFAULT NULL,
    x_dl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_response_option_code              IN     VARCHAR2    DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        15-OCT-2003     Bug # 3102439. FA 126 Multiple FA Offices
  ||                                  school_id is being obsoleted.
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_SL_DL_SETUP_ALL
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
    new_references.dlset_id                          := x_dlset_id;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.school_id                         := NULL;
    new_references.orig_fee_perct_stafford           := x_orig_fee_perct_stafford;
    new_references.orig_fee_perct_plus               := x_orig_fee_perct_plus;
    new_references.int_rebate                        := x_int_rebate;
    new_references.pnote_print_ind                   := x_pnote_print_ind;
    new_references.pnote_print_copies                := x_pnote_print_copies;
    new_references.acc_note_for_disb                 := x_acc_note_for_disb;
    new_references.affirmation_reqd                  := NULL;
    new_references.interview_reqd                    := x_interview_reqd;
    new_references.disclosure_print_ind              := x_disclosure_print_ind;
    new_references.special_school                    := x_special_school;
    new_references.dl_version                        := x_dl_version;
    new_references.response_option_code              := x_response_option_code;
    new_references.funding_method                    := x_funding_method;

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


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.ci_cal_type,
           new_references.ci_sequence_number
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.ci_cal_type = new_references.ci_cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.ci_cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.ci_cal_type,
                new_references.ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_dlset_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_dl_setup_all
      WHERE    dlset_id = x_dlset_id
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


  FUNCTION get_uk_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_dl_setup_all
      WHERE    ci_cal_type = x_ci_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_dl_setup_all
      WHERE   ((ci_cal_type = x_cal_type) AND
               (ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dlset_id                          IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_school_id                         IN     VARCHAR2    DEFAULT NULL,
    x_orig_fee_perct_stafford           IN     NUMBER      DEFAULT NULL,
    x_orig_fee_perct_plus               IN     NUMBER      DEFAULT NULL,
    x_int_rebate                        IN     NUMBER      DEFAULT NULL,
    x_pnote_print_ind                   IN     VARCHAR2    DEFAULT NULL,
    x_pnote_print_copies                IN     NUMBER      DEFAULT NULL,
    x_acc_note_for_disb                 IN     VARCHAR2    DEFAULT NULL,
    x_affirmation_reqd                  IN     VARCHAR2    DEFAULT NULL,
    x_interview_reqd                    IN     VARCHAR2    DEFAULT NULL,
    x_disclosure_print_ind              IN     VARCHAR2    DEFAULT NULL,
    x_special_school                    IN     VARCHAR2    DEFAULT NULL,
    x_dl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_response_option_code              IN     VARCHAR2    DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2    DEFAULT NULL

  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        15-OCT-2003     Bug # 3102439. FA 126 Multiple FA Offices
  ||                                  school_id is being obsoleted.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_dlset_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      NULL,     /* school_id is being obsoleted w.r.t FA 126 Bug # 3102439 */
      x_orig_fee_perct_stafford,
      x_orig_fee_perct_plus,
      x_int_rebate,
      x_pnote_print_ind,
      x_pnote_print_copies,
      x_acc_note_for_disb,
      NULL,
      x_interview_reqd,
      x_disclosure_print_ind,
      x_special_school,
      x_dl_version,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_response_option_code,
      x_funding_method

    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.dlset_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.dlset_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dlset_id                          IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_school_id                         IN     VARCHAR2 DEFAULT NULL,
    x_orig_fee_perct_stafford           IN     NUMBER,
    x_orig_fee_perct_plus               IN     NUMBER,
    x_int_rebate                        IN     NUMBER,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_print_copies                IN     NUMBER,
    x_acc_note_for_disb                 IN     VARCHAR2,
    x_affirmation_reqd                  IN     VARCHAR2 DEFAULT NULL,
    x_interview_reqd                    IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_special_school                    IN     VARCHAR2,
    x_dl_version                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_response_option_code              IN     VARCHAR2,
    x_funding_method                    IN     VARCHAR2

  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        15-OCT-2003     Bug # 3102439. FA 126 Multiple FA Offices
  ||                                  school_id is being obsoleted.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_dl_setup_all
      WHERE    dlset_id                          = x_dlset_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_org_id			 igf_sl_dl_setup_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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

    SELECT igf_sl_dl_setup_s.nextval INTO x_dlset_id FROM DUAL;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_dlset_id                          => x_dlset_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_school_id                         => NULL,
      x_orig_fee_perct_stafford           => x_orig_fee_perct_stafford,
      x_orig_fee_perct_plus               => x_orig_fee_perct_plus,
      x_int_rebate                        => x_int_rebate,
      x_pnote_print_ind                   => x_pnote_print_ind,
      x_pnote_print_copies                => x_pnote_print_copies,
      x_acc_note_for_disb                 => x_acc_note_for_disb,
      x_affirmation_reqd                  => NULL,
      x_interview_reqd                    => x_interview_reqd,
      x_disclosure_print_ind              => x_disclosure_print_ind,
      x_special_school                    => x_special_school,
      x_dl_version                        => x_dl_version,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_response_option_code              => x_response_option_code,
      x_funding_method                    => x_funding_method

    );

    INSERT INTO igf_sl_dl_setup_all(
      dlset_id,
      ci_cal_type,
      ci_sequence_number,
      school_id,
      orig_fee_perct_stafford,
      orig_fee_perct_plus,
      int_rebate,
      pnote_print_ind,
      pnote_print_copies,
      acc_note_for_disb,
      affirmation_reqd,
      interview_reqd,
      disclosure_print_ind,
      special_school,
      dl_version,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id,
      response_option_code,
      funding_method

    ) VALUES (
      new_references.dlset_id,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      NULL,   /*  school_id is being obsoleted. Bug # 3102439. FA 126 Multiple FA Offices */
      new_references.orig_fee_perct_stafford,
      new_references.orig_fee_perct_plus,
      new_references.int_rebate,
      new_references.pnote_print_ind,
      new_references.pnote_print_copies,
      new_references.acc_note_for_disb,
      NULL,
      new_references.interview_reqd,
      new_references.disclosure_print_ind,
      new_references.special_school,
      new_references.dl_version,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      l_org_id ,
      new_references.response_option_code,
      new_references.funding_method

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
    x_dlset_id                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_school_id                         IN     VARCHAR2 DEFAULT NULL,
    x_orig_fee_perct_stafford           IN     NUMBER,
    x_orig_fee_perct_plus               IN     NUMBER,
    x_int_rebate                        IN     NUMBER,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_print_copies                IN     NUMBER,
    x_acc_note_for_disb                 IN     VARCHAR2,
    x_affirmation_reqd                  IN     VARCHAR2 DEFAULT NULL,
    x_interview_reqd                    IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_special_school                    IN     VARCHAR2,
    x_dl_version                        IN     VARCHAR2,
    x_response_option_code              IN     VARCHAR2,
    x_funding_method                    IN     VARCHAR2


  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        15-OCT-2003     Bug # 3102439. FA 126 Multiple FA Offices
  ||                                  school_id is being obsoleted.
  ||  masehgal        16-Jun-2003     # 2990040   FACR115
  ||                                  Changes to lock row for Dl_version
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        ci_cal_type,
        ci_sequence_number,
        orig_fee_perct_stafford,
        orig_fee_perct_plus,
        int_rebate,
        pnote_print_ind,
        pnote_print_copies,
        acc_note_for_disb,
        interview_reqd,
        disclosure_print_ind,
        special_school,
        dl_version,
        org_id,
        response_option_code,
        funding_method

      FROM  igf_sl_dl_setup_all
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
        (tlinfo.ci_cal_type = x_ci_cal_type)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND (tlinfo.orig_fee_perct_stafford = x_orig_fee_perct_stafford)
        AND (tlinfo.orig_fee_perct_plus = x_orig_fee_perct_plus)
        AND (tlinfo.int_rebate = x_int_rebate)
        AND (tlinfo.pnote_print_ind = x_pnote_print_ind)
        AND (tlinfo.pnote_print_copies = x_pnote_print_copies)
        AND ((tlinfo.acc_note_for_disb = x_acc_note_for_disb) OR ((tlinfo.acc_note_for_disb IS NULL) AND (X_acc_note_for_disb IS NULL)))
        AND ((tlinfo.interview_reqd = x_interview_reqd) OR ((tlinfo.interview_reqd IS NULL) AND (X_interview_reqd IS NULL)))
        AND ((tlinfo.disclosure_print_ind = x_disclosure_print_ind) OR ((tlinfo.disclosure_print_ind IS NULL) AND (X_disclosure_print_ind IS NULL)))
        AND ((tlinfo.special_school = x_special_school) OR ((tlinfo.special_school IS NULL) AND (X_special_school IS NULL)))
        AND ((tlinfo.dl_version = x_dl_version) OR ((tlinfo.dl_version IS NULL) AND (X_dl_version IS NULL)))
        AND ((tlinfo.response_option_code = x_response_option_code) OR ((tlinfo.response_option_code IS NULL) AND (X_response_option_code IS NULL)))
        AND ((tlinfo.funding_method = x_funding_method) OR ((tlinfo.funding_method IS NULL) AND (X_funding_method IS NULL)))

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
    x_dlset_id                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_school_id                         IN     VARCHAR2 DEFAULT NULL,
    x_orig_fee_perct_stafford           IN     NUMBER,
    x_orig_fee_perct_plus               IN     NUMBER,
    x_int_rebate                        IN     NUMBER,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_print_copies                IN     NUMBER,
    x_acc_note_for_disb                 IN     VARCHAR2,
    x_affirmation_reqd                  IN     VARCHAR2 DEFAULT NULL,
    x_interview_reqd                    IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_special_school                    IN     VARCHAR2,
    x_dl_version                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_response_option_code              IN     VARCHAR2,
    x_funding_method                    IN     VARCHAR2

  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        15-OCT-2003     Bug # 3102439. FA 126 Multiple FA Offices
  ||                                  school_id is being obsoleted.
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
      x_dlset_id                          => x_dlset_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_school_id                         => NULL,
      x_orig_fee_perct_stafford           => x_orig_fee_perct_stafford,
      x_orig_fee_perct_plus               => x_orig_fee_perct_plus,
      x_int_rebate                        => x_int_rebate,
      x_pnote_print_ind                   => x_pnote_print_ind,
      x_pnote_print_copies                => x_pnote_print_copies,
      x_acc_note_for_disb                 => x_acc_note_for_disb,
      x_affirmation_reqd                  => NULL,
      x_interview_reqd                    => x_interview_reqd,
      x_disclosure_print_ind              => x_disclosure_print_ind,
      x_special_school                    => x_special_school,
      x_dl_version                        => x_dl_version,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_response_option_code              => x_response_option_code,
      x_funding_method                    => x_funding_method

    );

    UPDATE igf_sl_dl_setup_all
      SET
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        school_id                         = NULL,
        orig_fee_perct_stafford           = new_references.orig_fee_perct_stafford,
        orig_fee_perct_plus               = new_references.orig_fee_perct_plus,
        int_rebate                        = new_references.int_rebate,
        pnote_print_ind                   = new_references.pnote_print_ind,
        pnote_print_copies                = new_references.pnote_print_copies,
        acc_note_for_disb                 = new_references.acc_note_for_disb,
        affirmation_reqd                  = NULL,
        interview_reqd                    = new_references.interview_reqd,
        disclosure_print_ind              = new_references.disclosure_print_ind,
        special_school                    = new_references.special_school,
        dl_version                        = new_references.dl_version,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        response_option_code              = new_references.response_option_code,
        funding_method                    = new_references.funding_method


      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dlset_id                          IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_school_id                         IN     VARCHAR2 DEFAULT NULL,
    x_orig_fee_perct_stafford           IN     NUMBER,
    x_orig_fee_perct_plus               IN     NUMBER,
    x_int_rebate                        IN     NUMBER,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_print_copies                IN     NUMBER,
    x_acc_note_for_disb                 IN     VARCHAR2,
    x_affirmation_reqd                  IN     VARCHAR2 DEFAULT NULL,
    x_interview_reqd                    IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_special_school                    IN     VARCHAR2,
    x_dl_version                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_response_option_code              IN     VARCHAR2,
    x_funding_method                    IN     VARCHAR2

  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        15-OCT-2003     Bug # 3102439. FA 126 Multiple FA Offices
  ||                                  school_id is being obsoleted.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_dl_setup_all
      WHERE    dlset_id                          = x_dlset_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_dlset_id,
        x_ci_cal_type,
        x_ci_sequence_number,
        NULL, /* school_id is being obsoleted. Bug # 3102439. FA 126 Multiple FA Offices */
        x_orig_fee_perct_stafford,
        x_orig_fee_perct_plus,
        x_int_rebate,
        x_pnote_print_ind,
        x_pnote_print_copies,
        x_acc_note_for_disb,
        NULL,
        x_interview_reqd,
        x_disclosure_print_ind,
        x_special_school,
        x_dl_version,
        x_mode,
        x_response_option_code,
        x_funding_method

      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_dlset_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      NULL, /* school_id is being obsoleted. Bug # 3102439. FA 126 Multiple FA Offices */
      x_orig_fee_perct_stafford,
      x_orig_fee_perct_plus,
      x_int_rebate,
      x_pnote_print_ind,
      x_pnote_print_copies,
      x_acc_note_for_disb,
      NULL,
      x_interview_reqd,
      x_disclosure_print_ind,
      x_special_school,
      x_dl_version,
      x_mode,
      x_response_option_code,
      x_funding_method

    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 31-JAN-2001
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

    DELETE FROM igf_sl_dl_setup_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_dl_setup_pkg;

/
