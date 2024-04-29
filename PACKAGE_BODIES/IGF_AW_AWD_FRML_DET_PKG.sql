--------------------------------------------------------
--  DDL for Package Body IGF_AW_AWD_FRML_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_AWD_FRML_DET_PKG" AS
/* $Header: IGFWI13B.pls 120.0 2005/06/02 15:46:43 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_awd_frml_det_all%ROWTYPE;
  new_references igf_aw_awd_frml_det_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_formula_code                      IN     VARCHAR2    ,
    x_ci_cal_type                       IN     VARCHAR2    ,
    x_ci_sequence_number                IN     NUMBER      ,
    x_seq_no                            IN     NUMBER      ,
    x_fund_id                           IN     NUMBER      ,
    x_min_award_amt                     IN     NUMBER      ,
    x_max_award_amt                     IN     NUMBER      ,
    x_replace_fc                        IN     VARCHAR2    ,
    x_pe_group_id                       IN     NUMBER      ,
    x_adplans_id                        IN     NUMBER      ,
    x_lock_award_flag                   IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 08-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_AWD_FRML_DET_ALL
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
    new_references.formula_code                      := x_formula_code;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.seq_no                            := x_seq_no;
    new_references.fund_id                           := x_fund_id;
    new_references.min_award_amt                     := x_min_award_amt;
    new_references.max_award_amt                     := x_max_award_amt;
    new_references.replace_fc                        := x_replace_fc;
    new_references.pe_group_id                       := x_pe_group_id;
    new_references.adplans_id                        := x_adplans_id;
    new_references.lock_award_flag                   := x_lock_award_flag;

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
  ||  Created By : avenkatr
  ||  Created On : 08-NOV-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || veramach         06-Nov-2003     FA 125 - Added call for igf_aw_awd_dist_plans_pkg.get_pk_for_validation(adplans_id)
  || adhawan          24-oct-2002     igf_aw_awd_frml_pkg.get_pk_for_validation removed
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.formula_code = new_references.formula_code) AND
         (old_references.ci_cal_type = new_references.ci_cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.formula_code IS NULL) OR
         (new_references.ci_cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    END IF;
    IF (((old_references.fund_id = new_references.fund_id)) OR
        ((new_references.fund_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_fund_mast_pkg.get_pk_for_validation (
                new_references.fund_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF ((old_references.adplans_id = new_references.adplans_id)) OR
       ((new_references.adplans_id IS NULL)) THEN
      NULL;
    ELSIF NOT igf_aw_awd_dist_plans_pkg.get_pk_for_validation(new_references.adplans_id) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_seq_no                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 08-NOV-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_frml_det_all
      WHERE    formula_code = x_formula_code
      AND      ci_cal_type = x_ci_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      seq_no = x_seq_no
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


  PROCEDURE get_fk_igf_aw_fund_mast (
    x_fund_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 08-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_frml_det_all
      WHERE   ((fund_id = x_fund_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_FMDET_FMAST_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_fund_mast;

  PROCEDURE get_fk_igf_aw_awd_dist_plans(
                                         x_adplans_id IN NUMBER
                                        ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 06-NOV-2003
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_frml_det_all
      WHERE   ((adplans_id = x_adplans_id));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_FMDET_ADPLANS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_awd_dist_plans;

   PROCEDURE get_ufk_igf_aw_target_grp (
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : CDCRUZ
  ||  Created On : 31-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_frml_det_all
      WHERE   (formula_code = x_formula_code and
               ci_cal_type  = x_ci_cal_type and
         ci_sequence_number = x_ci_sequence_number);

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('FND', 'FND-CANNOT DELETE MASTER');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igf_aw_target_grp;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_formula_code                      IN     VARCHAR2    ,
    x_ci_cal_type                       IN     VARCHAR2    ,
    x_ci_sequence_number                IN     NUMBER      ,
    x_seq_no                            IN     NUMBER      ,
    x_fund_id                           IN     NUMBER      ,
    x_min_award_amt                     IN     NUMBER      ,
    x_max_award_amt                     IN     NUMBER      ,
    x_replace_fc                        IN     VARCHAR2    ,
    x_pe_group_id                       IN     NUMBER      ,
    x_adplans_id                        IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 08-NOV-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_formula_code,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_seq_no,
      x_fund_id,
      x_min_award_amt,
      x_max_award_amt,
      x_replace_fc,
      x_pe_group_id,
      x_adplans_id,
      x_lock_award_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.formula_code,
             new_references.ci_cal_type,
             new_references.ci_sequence_number,
             new_references.seq_no
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
             new_references.formula_code,
             new_references.ci_cal_type,
             new_references.ci_sequence_number,
             new_references.seq_no
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
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_seq_no                            IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_replace_fc                        IN     VARCHAR2,
    x_pe_group_id                       IN     NUMBER  ,
    x_mode                              IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 08-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_awd_frml_det_all
      WHERE    formula_code                      = x_formula_code
      AND      ci_cal_type                       = x_ci_cal_type
      AND      ci_sequence_number                = x_ci_sequence_number
      AND      seq_no                            = x_seq_no;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_org_id           igf_aw_awd_frml_det_all.org_id%TYPE  DEFAULT igf_aw_gen.get_org_id;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_formula_code                      => x_formula_code,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_seq_no                            => x_seq_no,
      x_fund_id                           => x_fund_id,
      x_min_award_amt                     => x_min_award_amt,
      x_max_award_amt                     => x_max_award_amt,
      x_replace_fc                        => x_replace_fc,
      x_pe_group_id                       => x_pe_group_id,
      x_adplans_id                        => x_adplans_id,
      x_lock_award_flag                   => x_lock_award_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_awd_frml_det_all (
      formula_code,
      ci_cal_type,
      ci_sequence_number,
      seq_no,
      fund_id,
      min_award_amt,
      max_award_amt,
      replace_fc,
      pe_group_id,
      adplans_id,
      lock_award_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id
    ) VALUES (
      new_references.formula_code,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      new_references.seq_no,
      new_references.fund_id,
      new_references.min_award_amt,
      new_references.max_award_amt,
      new_references.replace_fc,
      new_references.pe_group_id,
      new_references.adplans_id,
      new_references.lock_award_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      l_org_id
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
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_seq_no                            IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_replace_fc                        IN     VARCHAR2,
    x_pe_group_id                       IN     NUMBER,
    x_adplans_id                        IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 08-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
  */
    CURSOR c1 IS
      SELECT
        fund_id,
        min_award_amt,
        max_award_amt,
        replace_fc,
        adplans_id,
        lock_award_flag
      FROM  igf_aw_awd_frml_det_all
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
        (tlinfo.fund_id = x_fund_id)
        AND ((tlinfo.min_award_amt = x_min_award_amt) OR ((tlinfo.min_award_amt IS NULL) AND (X_min_award_amt IS NULL)))
        AND ((tlinfo.max_award_amt = x_max_award_amt) OR ((tlinfo.max_award_amt IS NULL) AND (X_max_award_amt IS NULL)))
        AND ((tlinfo.replace_fc = x_replace_fc) OR ((tlinfo.replace_fc IS NULL) AND (X_replace_fc IS NULL)))
        AND ((tlinfo.adplans_id = x_adplans_id) OR ((tlinfo.adplans_id IS NULL) AND (x_adplans_id IS NULL)))
        AND ((tlinfo.lock_award_flag = x_lock_award_flag) OR (tlinfo.lock_award_flag IS NULL))       ) THEN
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
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_seq_no                            IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_replace_fc                        IN     VARCHAR2,
    x_pe_group_id                       IN     NUMBER      ,
    x_mode                              IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 08-NOV-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
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
      x_formula_code                      => x_formula_code,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_seq_no                            => x_seq_no,
      x_fund_id                           => x_fund_id,
      x_min_award_amt                     => x_min_award_amt,
      x_max_award_amt                     => x_max_award_amt,
      x_replace_fc                        => x_replace_fc,
      x_pe_group_id                       => x_pe_group_id ,
      x_adplans_id                        => x_adplans_id,
      x_lock_award_flag                   => x_lock_award_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_aw_awd_frml_det_all
      SET
        seq_no                            = new_references.seq_no,
        fund_id                           = new_references.fund_id,
        min_award_amt                     = new_references.min_award_amt,
        max_award_amt                     = new_references.max_award_amt,
        replace_fc                        = new_references.replace_fc,
        pe_group_id                       = new_references.pe_group_id,
        adplans_id                        = new_references.adplans_id,
        lock_award_flag                   = new_references.lock_award_flag,
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
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_seq_no                            IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_replace_fc                        IN     VARCHAR2,
    x_pe_group_id                       IN     NUMBER ,
    x_mode                              IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 08-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        06-NOV-2003     FA 125 Multiple distr methods
  ||                                  Added new column adplans_id
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_awd_frml_det_all
      WHERE    formula_code                      = x_formula_code
      AND      ci_cal_type                       = x_ci_cal_type
      AND      ci_sequence_number                = x_ci_sequence_number
      AND      seq_no                            = x_seq_no;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_formula_code,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_seq_no,
        x_fund_id,
        x_min_award_amt,
        x_max_award_amt,
        x_replace_fc,
        x_pe_group_id,
        x_mode,
        x_adplans_id,
        x_lock_award_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_formula_code,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_seq_no,
      x_fund_id,
      x_min_award_amt,
      x_max_award_amt,
      x_replace_fc,
      x_pe_group_id,
      x_mode,
      x_adplans_id,
      x_lock_award_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 08-NOV-2000
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

    DELETE FROM igf_aw_awd_frml_det_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

END igf_aw_awd_frml_det_pkg;

/
