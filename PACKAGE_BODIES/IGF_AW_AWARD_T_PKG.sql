--------------------------------------------------------
--  DDL for Package Body IGF_AW_AWARD_T_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_AWARD_T_PKG" AS
/* $Header: IGFWI26B.pls 120.0 2005/06/01 13:45:29 appldev noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_AW_AWARD_T_PKG
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | This package has a flag on the end of some of the procedures called   |
 | X_MODE. Pass either 'R' for runtime, or 'I' for Install-time.         |
 | This will control how the who columns are filled in; If you are       |
 | running in runtime mode, they are taken from the profiles, whereas in |
 | install-time mode they get defaulted with special values to indicate  |
 | that they were inserted by datamerge.                                 |
 |                                                                       |
 | The ADD_ROW routine will see whether a row exists by selecting        |
 | based on the primary key, and updates the row if it exists,           |
 | or inserts the row if it doesn't already exist.                       |
 |                                                                       |
 | This module is called by AutoInstall (afplss.drv) on install and      |
 | upgrade.  The WHENEVER SQLERROR and EXIT (at bottom) are required.    |
 |                                                                       |
 | HISTORY                                                               |
 | WHO                  WHEN             WHAT                            |
 | veramach             12-Oct-2004      FA 152 Added award_id,          |
 |                                       lock_award_flag                 |
 | veramach             03-DEC-2003      FA 131 Added app_trans_num_txt  |
 | veramach             21-NOV-2003      FA 125 Added adplans_id to tbh  |
 *=======================================================================*/

  l_rowid VARCHAR2(25);
  old_references igf_aw_award_t_all%ROWTYPE;
  new_references igf_aw_award_t_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_process_id                        IN     NUMBER      DEFAULT NULL,
    x_sl_number                         IN     NUMBER      DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_offered_amt                       IN     NUMBER      DEFAULT NULL,
    x_accepted_amt                      IN     NUMBER      DEFAULT NULL,
    x_paid_amt                          IN     NUMBER      DEFAULT NULL,
    x_need_reduction_amt                IN     NUMBER      DEFAULT NULL,
    x_flag                              IN     VARCHAR2    DEFAULT NULL,
    x_temp_num_val1                     IN     NUMBER      DEFAULT NULL,
    x_temp_num_val2                     IN     NUMBER      DEFAULT NULL,
    x_temp_char_val1                    IN     VARCHAR2    DEFAULT NULL,
    x_tp_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_tp_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_temp_val3_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_val4_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_char2_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_temp_char3_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 08-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        12-Oct-2004     FA 152 Added award_id,lock_award_flag
  ||  veramach        03-DEC-2003     FA 131 Added app_trans_num_txt to tbh signature
  ||  veramach        21-NOV-2003     FA 125 Added adplans_id to tbh signature
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_AWARD_T_ALL
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
    new_references.process_id                        := x_process_id;
    new_references.sl_number                         := x_sl_number;
    new_references.fund_id                           := x_fund_id;
    new_references.base_id                           := x_base_id;
    new_references.offered_amt                       := x_offered_amt;
    new_references.accepted_amt                      := x_accepted_amt;
    new_references.paid_amt                          := x_paid_amt;
    new_references.need_reduction_amt                := x_need_reduction_amt;
    new_references.flag                              := x_flag;
    new_references.temp_num_val1                     := x_temp_num_val1;
    new_references.temp_num_val2                     := x_temp_num_val2;
    new_references.temp_char_val1                    := x_temp_char_val1;
    new_references.tp_cal_type                       := x_tp_cal_type;
    new_references.tp_sequence_number                := x_tp_sequence_number;
    new_references.ld_cal_type                       := x_ld_cal_type;
    new_references.ld_sequence_number                := x_ld_sequence_number;
    new_references.adplans_id                        := x_adplans_id;
    new_references.app_trans_num_txt                 := x_app_trans_num_txt;
    new_references.award_id                          := x_award_id;
    new_references.lock_award_flag                   := x_lock_award_flag;
    new_references.temp_val3_num                     := x_temp_val3_num;
    new_references.temp_val4_num                     := x_temp_val4_num;
    new_references.temp_char2_txt                    := x_temp_char2_txt;
    new_references.temp_char3_txt                    := x_temp_char3_txt;

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
    x_process_id                        IN     NUMBER,
    x_sl_number                         IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 08-NOV-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_award_t_all
      WHERE    process_id = x_process_id
      AND      sl_number = x_sl_number
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
    x_process_id                        IN     NUMBER      DEFAULT NULL,
    x_sl_number                         IN     NUMBER      DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_offered_amt                       IN     NUMBER      DEFAULT NULL,
    x_accepted_amt                      IN     NUMBER      DEFAULT NULL,
    x_paid_amt                          IN     NUMBER      DEFAULT NULL,
    x_need_reduction_amt                IN     NUMBER      DEFAULT NULL,
    x_flag                              IN     VARCHAR2    DEFAULT NULL,
    x_temp_num_val1                     IN     NUMBER      DEFAULT NULL,
    x_temp_num_val2                     IN     NUMBER      DEFAULT NULL,
    x_temp_char_val1                    IN     VARCHAR2    DEFAULT NULL,
    x_tp_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_tp_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_temp_val3_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_val4_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_char2_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_temp_char3_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 08-NOV-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        12-Oct-2004     FA 152 Added award_id,lock_award_flag
  ||  veramach        03-DEC-2003     FA 131 Added app_trans_num_txt to tbh signature
  ||  veramach        21-NOV-2003     FA 125 Added adplans_id to tbh signature
  */
  BEGIN
    set_column_values (
      p_action,
      x_rowid,
      x_process_id,
      x_sl_number,
      x_fund_id,
      x_base_id,
      x_offered_amt,
      x_accepted_amt,
      x_paid_amt,
      x_need_reduction_amt,
      x_flag,
      x_temp_num_val1,
      x_temp_num_val2,
      x_temp_char_val1,
      x_tp_cal_type,
      x_tp_sequence_number,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_adplans_id,
      x_app_trans_num_txt,
      x_award_id,
      x_lock_award_flag,
      x_temp_val3_num,
      x_temp_val4_num,
      x_temp_char2_txt,
      x_temp_char3_txt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.process_id,
             new_references.sl_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.process_id,
             new_references.sl_number
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
    x_process_id                        IN     NUMBER,
    x_sl_number                         IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_need_reduction_amt                IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_temp_num_val1                     IN     NUMBER,
    x_temp_num_val2                     IN     NUMBER,
    x_temp_char_val1                    IN     VARCHAR2,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_adplans_id                        IN     NUMBER,
    x_app_trans_num_txt                 IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2,
    x_temp_val3_num                     IN     NUMBER,
    x_temp_val4_num                     IN     NUMBER,
    x_temp_char2_txt                    IN     VARCHAR2,
    x_temp_char3_txt                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 08-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        12-Oct-2004     FA 152 Added award_id,lock_award_flag
  ||  veramach        03-DEC-2003     FA 131 Added app_trans_num_txt to tbh signature
  ||  veramach        21-NOV-2003     FA 125 Added adplans_id to tbh signature
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_award_t_all
      WHERE    process_id                        = x_process_id
      AND      sl_number                         = x_sl_number;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id       igf_aw_award_t_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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

     SELECT igf_aw_award_t_s.NEXTVAL INTO x_sl_number FROM dual ;
   before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_process_id                        => x_process_id,
      x_sl_number                         => x_sl_number,
      x_fund_id                           => x_fund_id,
      x_base_id                           => x_base_id,
      x_offered_amt                       => x_offered_amt,
      x_accepted_amt                      => x_accepted_amt,
      x_paid_amt                          => x_paid_amt,
      x_need_reduction_amt                => x_need_reduction_amt,
      x_flag                              => x_flag,
      x_temp_num_val1                     => x_temp_num_val1,
      x_temp_num_val2                     => x_temp_num_val2,
      x_temp_char_val1                    => x_temp_char_val1,
      x_tp_cal_type                       => x_tp_cal_type,
      x_tp_sequence_number                => x_tp_sequence_number,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_adplans_id                        => x_adplans_id,
      x_app_trans_num_txt                 => x_app_trans_num_txt,
      x_award_id                          => x_award_id,
      x_temp_val3_num                     => x_temp_val3_num,
      x_temp_val4_num                     => x_temp_val4_num,
      x_temp_char2_txt                    => x_temp_char2_txt,
      x_temp_char3_txt                    => x_temp_char3_txt,
      x_lock_award_flag                   => x_lock_award_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );
    INSERT INTO igf_aw_award_t_all(
      process_id,
      sl_number,
      fund_id,
      base_id,
      offered_amt,
      accepted_amt,
      paid_amt,
      need_reduction_amt,
      flag,
      temp_num_val1,
      temp_num_val2,
      temp_char_val1,
      tp_cal_type,
      tp_sequence_number,
      ld_cal_type,
      ld_sequence_number,
      adplans_id,
      app_trans_num_txt,
      award_id,
      lock_award_flag,
      temp_val3_num,
      temp_val4_num,
      temp_char2_txt,
      temp_char3_txt,
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
      new_references.process_id,
      new_references.sl_number,
      new_references.fund_id,
      new_references.base_id,
      new_references.offered_amt,
      new_references.accepted_amt,
      new_references.paid_amt,
      new_references.need_reduction_amt,
      new_references.flag,
      new_references.temp_num_val1,
      new_references.temp_num_val2,
      new_references.temp_char_val1,
      new_references.tp_cal_type,
      new_references.tp_sequence_number,
      new_references.ld_cal_type,
      new_references.ld_sequence_number,
      new_references.adplans_id,
      new_references.app_trans_num_txt,
      new_references.award_id,
      new_references.lock_award_flag,
      new_references.temp_val3_num,
      new_references.temp_val4_num,
      new_references.temp_char2_txt,
      new_references.temp_char3_txt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
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
    x_process_id                        IN     NUMBER,
    x_sl_number                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_need_reduction_amt                IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_temp_num_val1                     IN     NUMBER,
    x_temp_num_val2                     IN     NUMBER,
    x_temp_char_val1                    IN     VARCHAR2,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_adplans_id                        IN     NUMBER,
    x_app_trans_num_txt                 IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2,
    x_temp_val3_num                     IN     NUMBER,
    x_temp_val4_num                     IN     NUMBER,
    x_temp_char2_txt                    IN     VARCHAR2,
    x_temp_char3_txt                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 08-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        12-Oct-2004     FA 152 Added award_id,lock_award_flag
  ||  veramach        03-DEC-2003     FA 131 Added app_trans_num_txt to tbh signature
  ||  veramach        21-NOV-2003     FA 125 Added adplans_id to tbh signature
  */
    CURSOR c1 IS
      SELECT
        fund_id,
        base_id,
        offered_amt,
        accepted_amt,
        paid_amt,
        need_reduction_amt,
        flag,
        temp_num_val1,
        temp_num_val2,
        temp_char_val1,
        tp_cal_type,
        tp_sequence_number,
        ld_cal_type,
        ld_sequence_number,
        adplans_id,
        app_trans_num_txt,
        award_id,
        lock_award_flag,
        temp_val3_num,
        temp_val4_num,
        temp_char2_txt,
        temp_char3_txt
      FROM  igf_aw_award_t_all
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
        ((tlinfo.fund_id = x_fund_id) OR ((tlinfo.fund_id IS NULL) AND (X_fund_id IS NULL)))
        AND ((tlinfo.base_id = x_base_id) OR ((tlinfo.base_id IS NULL) AND (X_base_id IS NULL)))
        AND ((tlinfo.offered_amt = x_offered_amt) OR ((tlinfo.offered_amt IS NULL) AND (X_offered_amt IS NULL)))
        AND ((tlinfo.accepted_amt = x_accepted_amt) OR ((tlinfo.accepted_amt IS NULL) AND (X_accepted_amt IS NULL)))
        AND ((tlinfo.paid_amt = x_paid_amt) OR ((tlinfo.paid_amt IS NULL) AND (X_paid_amt IS NULL)))
        AND ((tlinfo.need_reduction_amt = x_need_reduction_amt) OR ((tlinfo.need_reduction_amt IS NULL) AND (X_need_reduction_amt IS NULL)))
        AND ((tlinfo.flag = x_flag) OR ((tlinfo.flag IS NULL) AND (X_flag IS NULL)))
        AND ((tlinfo.temp_num_val1 = x_temp_num_val1) OR ((tlinfo.temp_num_val1 IS NULL) AND (X_temp_num_val1 IS NULL)))
        AND ((tlinfo.temp_num_val2 = x_temp_num_val2) OR ((tlinfo.temp_num_val2 IS NULL) AND (X_temp_num_val2 IS NULL)))
        AND ((tlinfo.temp_char_val1 = x_temp_char_val1) OR ((tlinfo.temp_char_val1 IS NULL) AND (X_temp_char_val1 IS NULL)))
        AND ((tlinfo.tp_cal_type = x_tp_cal_type) OR ((tlinfo.tp_cal_type IS NULL) AND (X_tp_cal_type IS NULL)))
        AND ((tlinfo.tp_sequence_number = x_tp_sequence_number) OR ((tlinfo.tp_sequence_number IS NULL) AND (X_tp_sequence_number IS NULL)))
        AND ((tlinfo.ld_cal_type = x_ld_cal_type) OR ((tlinfo.ld_cal_type IS NULL) AND (X_ld_cal_type IS NULL)))
        AND ((tlinfo.ld_sequence_number = x_ld_sequence_number) OR ((tlinfo.ld_sequence_number IS NULL) AND (X_ld_sequence_number IS NULL)))
        AND ((tlinfo.adplans_id = x_adplans_id) OR ((tlinfo.adplans_id IS NULL) AND (x_adplans_id IS NULL)))
        AND ((tlinfo.app_trans_num_txt = x_app_trans_num_txt) OR ((tlinfo.app_trans_num_txt IS NULL) AND (x_app_trans_num_txt IS NULL)))
        AND ((tlinfo.award_id = x_award_id) OR ((tlinfo.award_id IS NULL) AND (x_award_id IS NULL)))
        AND ((tlinfo.lock_award_flag = x_lock_award_flag) OR ((tlinfo.lock_award_flag IS NULL) AND (x_lock_award_flag IS NULL)))
        AND ((tlinfo.temp_val3_num  = x_temp_val3_num ) OR ((tlinfo.temp_val3_num  IS NULL) AND (x_temp_val3_num  IS NULL)))
        AND ((tlinfo.temp_val4_num  = x_temp_val4_num ) OR ((tlinfo.temp_val4_num  IS NULL) AND (x_temp_val4_num  IS NULL)))
        AND ((tlinfo.temp_char2_txt = x_temp_char2_txt) OR ((tlinfo.temp_char2_txt IS NULL) AND (x_temp_char2_txt IS NULL)))
        AND ((tlinfo.temp_char3_txt = x_temp_char3_txt) OR ((tlinfo.temp_char3_txt IS NULL) AND (x_temp_char3_txt IS NULL)))
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
    x_process_id                        IN     NUMBER,
    x_sl_number                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_need_reduction_amt                IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_temp_num_val1                     IN     NUMBER,
    x_temp_num_val2                     IN     NUMBER,
    x_temp_char_val1                    IN     VARCHAR2,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2  DEFAULT 'R',
    x_adplans_id                        IN     NUMBER,
    x_app_trans_num_txt                 IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2,
    x_temp_val3_num                     IN     NUMBER,
    x_temp_val4_num                     IN     NUMBER,
    x_temp_char2_txt                    IN     VARCHAR2,
    x_temp_char3_txt                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 08-NOV-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        12-Oct-2004     FA 152 Added award_id,lock_award_flag
  ||  veramach        03-DEC-2003     FA 131 Added app_trans_num_txt to tbh signature
  ||  veramach        21-NOV-2003     FA 125 Added adplans_id to tbh signature
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
      x_process_id                        => x_process_id,
      x_sl_number                         => x_sl_number,
      x_fund_id                           => x_fund_id,
      x_base_id                           => x_base_id,
      x_offered_amt                       => x_offered_amt,
      x_accepted_amt                      => x_accepted_amt,
      x_paid_amt                          => x_paid_amt,
      x_need_reduction_amt                => x_need_reduction_amt,
      x_flag                              => x_flag,
      x_temp_num_val1                     => x_temp_num_val1,
      x_temp_num_val2                     => x_temp_num_val2,
      x_temp_char_val1                    => x_temp_char_val1,
      x_tp_cal_type                       => x_tp_cal_type,
      x_tp_sequence_number                => x_tp_sequence_number,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_adplans_id                        => x_adplans_id,
      x_app_trans_num_txt                 => x_app_trans_num_txt,
      x_award_id                          => x_award_id,
      x_lock_award_flag                   => x_lock_award_flag,
      x_temp_val3_num                     => x_temp_val3_num,
      x_temp_val4_num                     => x_temp_val4_num,
      x_temp_char2_txt                    => x_temp_char2_txt,
      x_temp_char3_txt                    => x_temp_char3_txt,
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

    UPDATE igf_aw_award_t_all
      SET
        fund_id                           = new_references.fund_id,
        base_id                           = new_references.base_id,
        offered_amt                       = new_references.offered_amt,
        accepted_amt                      = new_references.accepted_amt,
        paid_amt                          = new_references.paid_amt,
        need_reduction_amt                = new_references.need_reduction_amt,
        flag                              = new_references.flag,
        temp_num_val1                     = new_references.temp_num_val1,
        temp_num_val2                     = new_references.temp_num_val2,
        temp_char_val1                    = new_references.temp_char_val1,
        tp_cal_type                       = new_references.tp_cal_type,
        tp_sequence_number                = new_references.tp_sequence_number,
        ld_cal_type                       = new_references.ld_cal_type,
        ld_sequence_number                = new_references.ld_sequence_number,
        adplans_id                        = new_references.adplans_id,
        app_trans_num_txt                 = new_references.app_trans_num_txt,
        award_id                          = new_references.award_id,
        lock_award_flag                   = new_references.lock_award_flag,
        temp_val3_num                     = new_references.temp_val3_num,
        temp_val4_num                     = new_references.temp_val4_num,
        temp_char2_txt                    = new_references.temp_char2_txt,
        temp_char3_txt                    = new_references.temp_char3_txt,
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
    x_process_id                        IN     NUMBER,
    x_sl_number                         IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_need_reduction_amt                IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_temp_num_val1                     IN     NUMBER,
    x_temp_num_val2                     IN     NUMBER,
    x_temp_char_val1                    IN     VARCHAR2,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_adplans_id                        IN     NUMBER,
    x_app_trans_num_txt                 IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2,
    x_temp_val3_num                     IN     NUMBER,
    x_temp_val4_num                     IN     NUMBER,
    x_temp_char2_txt                    IN     VARCHAR2,
    x_temp_char3_txt                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 08-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        12-Oct-2004     FA 152 Added award_id,lock_award_flag
  ||  veramach        03-DEC-2003     FA 131 Added app_trans_num_txt to tbh signature
  ||  veramach        21-NOV-2003     FA 125 Added adplans_id to tbh signature
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_award_t_all
      WHERE    process_id                        = x_process_id
      AND      sl_number                         = x_sl_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_process_id,
        x_sl_number,
        x_fund_id,
        x_base_id,
        x_offered_amt,
        x_accepted_amt,
        x_paid_amt,
        x_need_reduction_amt,
        x_flag,
        x_temp_num_val1,
        x_temp_num_val2,
        x_temp_char_val1,
        x_tp_cal_type,
        x_tp_sequence_number,
        x_ld_cal_type,
        x_ld_sequence_number,
        x_mode,
        x_adplans_id,
        x_app_trans_num_txt,
        x_award_id,
        x_lock_award_flag,
        x_temp_val3_num,
        x_temp_val4_num,
        x_temp_char2_txt,
        x_temp_char3_txt
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_process_id,
      x_sl_number,
      x_fund_id,
      x_base_id,
      x_offered_amt,
      x_accepted_amt,
      x_paid_amt,
      x_need_reduction_amt,
      x_flag,
      x_temp_num_val1,
      x_temp_num_val2,
      x_temp_char_val1,
      x_tp_cal_type,
      x_tp_sequence_number,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_mode,
      x_adplans_id,
      x_app_trans_num_txt,
      x_award_id,
      x_lock_award_flag,
      x_temp_val3_num,
      x_temp_val4_num,
      x_temp_char2_txt,
      x_temp_char3_txt
    );


  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
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

    DELETE FROM igf_aw_award_t_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_award_t_pkg;

/
