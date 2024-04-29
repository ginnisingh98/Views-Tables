--------------------------------------------------------
--  DDL for Package Body IGF_AW_AWARD_LEVEL_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_AWARD_LEVEL_HIST_PKG" AS
/* $Header: IGFWI72B.pls 120.0 2005/09/09 17:14:08 appldev noship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_AW_AWARD_LEVEL_HIST_PKG
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
 *=======================================================================*/

  l_rowid VARCHAR2(25);
  old_references igf_aw_award_level_hist%ROWTYPE;
  new_references igf_aw_award_level_hist%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2,
    x_award_change_source_code          IN     VARCHAR2,
    x_old_offered_amt                   IN     NUMBER,
    x_new_offered_amt                   IN     NUMBER,
    x_old_accepted_amt                  IN     NUMBER,
    x_new_accepted_amt                  IN     NUMBER,
    x_old_paid_amt                      IN     NUMBER,
    x_new_paid_amt                      IN     NUMBER,
    x_old_lock_award_flag               IN     VARCHAR2,
    x_new_lock_award_flag               IN     VARCHAR2,
    x_old_award_status_code             IN     VARCHAR2,
    x_new_award_status_code             IN     VARCHAR2,
    x_old_adplans_id                    IN     NUMBER,
    x_new_adplans_id                    IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAY-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_aw_award_level_hist
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
    new_references.award_hist_tran_id                := x_award_hist_tran_id;
    new_references.award_attrib_code                 := x_award_attrib_code;
    new_references.award_change_source_code          := x_award_change_source_code;
    new_references.old_offered_amt                   := x_old_offered_amt;
    new_references.new_offered_amt                   := x_new_offered_amt;
    new_references.old_accepted_amt                  := x_old_accepted_amt;
    new_references.new_accepted_amt                  := x_new_accepted_amt;
    new_references.old_paid_amt                      := x_old_paid_amt;
    new_references.new_paid_amt                      := x_new_paid_amt;
    new_references.old_lock_award_flag               := x_old_lock_award_flag;
    new_references.new_lock_award_flag               := x_new_lock_award_flag;
    new_references.old_award_status_code             := x_old_award_status_code;
    new_references.new_award_status_code             := x_new_award_status_code;
    new_references.old_adplans_id                    := x_old_adplans_id;
    new_references.new_adplans_id                    := x_new_adplans_id;

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
  ||  Created By :
  ||  Created On : 27-MAY-2005
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.old_adplans_id = new_references.old_adplans_id)) OR
        ((new_references.old_adplans_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_awd_dist_plans_pkg.get_pk_for_validation (
                new_references.old_adplans_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.new_adplans_id = new_references.new_adplans_id)) OR
        ((new_references.new_adplans_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_awd_dist_plans_pkg.get_pk_for_validation (
                new_references.new_adplans_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

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
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 27-MAY-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_award_level_hist
      WHERE    award_id = x_award_id
      AND      award_hist_tran_id = x_award_hist_tran_id
      AND      award_attrib_code = x_award_attrib_code
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


  PROCEDURE get_fk_igf_aw_awd_dist_plans (
    x_adplans_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAY-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_award_level_hist
      WHERE   ((old_adplans_id = x_adplans_id))
      OR      ((new_adplans_id = x_adplans_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_awd_dist_plans;


  PROCEDURE get_fk_igf_aw_award (
    x_award_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAY-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_award_level_hist
      WHERE   ((award_id = x_award_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_award;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2,
    x_award_change_source_code          IN     VARCHAR2,
    x_old_offered_amt                   IN     NUMBER,
    x_new_offered_amt                   IN     NUMBER,
    x_old_accepted_amt                  IN     NUMBER,
    x_new_accepted_amt                  IN     NUMBER,
    x_old_paid_amt                      IN     NUMBER,
    x_new_paid_amt                      IN     NUMBER,
    x_old_lock_award_flag               IN     VARCHAR2,
    x_new_lock_award_flag               IN     VARCHAR2,
    x_old_award_status_code             IN     VARCHAR2,
    x_new_award_status_code             IN     VARCHAR2,
    x_old_adplans_id                    IN     NUMBER,
    x_new_adplans_id                    IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAY-2005
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
      x_award_hist_tran_id,
      x_award_attrib_code,
      x_award_change_source_code,
      x_old_offered_amt,
      x_new_offered_amt,
      x_old_accepted_amt,
      x_new_accepted_amt,
      x_old_paid_amt,
      x_new_paid_amt,
      x_old_lock_award_flag,
      x_new_lock_award_flag,
      x_old_award_status_code,
      x_new_award_status_code,
      x_old_adplans_id,
      x_new_adplans_id,
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
             new_references.award_hist_tran_id,
             new_references.award_attrib_code
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
             new_references.award_hist_tran_id,
             new_references.award_attrib_code
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
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2,
    x_award_change_source_code          IN     VARCHAR2,
    x_old_offered_amt                   IN     NUMBER,
    x_new_offered_amt                   IN     NUMBER,
    x_old_accepted_amt                  IN     NUMBER,
    x_new_accepted_amt                  IN     NUMBER,
    x_old_paid_amt                      IN     NUMBER,
    x_new_paid_amt                      IN     NUMBER,
    x_old_lock_award_flag               IN     VARCHAR2,
    x_new_lock_award_flag               IN     VARCHAR2,
    x_old_award_status_code             IN     VARCHAR2,
    x_new_award_status_code             IN     VARCHAR2,
    x_old_adplans_id                    IN     NUMBER,
    x_new_adplans_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAY-2005
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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_AWARD_LEVEL_HIST_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    --new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_award_id                          => x_award_id,
      x_award_hist_tran_id                => x_award_hist_tran_id,
      x_award_attrib_code                 => x_award_attrib_code,
      x_award_change_source_code          => x_award_change_source_code,
      x_old_offered_amt                   => x_old_offered_amt,
      x_new_offered_amt                   => x_new_offered_amt,
      x_old_accepted_amt                  => x_old_accepted_amt,
      x_new_accepted_amt                  => x_new_accepted_amt,
      x_old_paid_amt                      => x_old_paid_amt,
      x_new_paid_amt                      => x_new_paid_amt,
      x_old_lock_award_flag               => x_old_lock_award_flag,
      x_new_lock_award_flag               => x_new_lock_award_flag,
      x_old_award_status_code             => x_old_award_status_code,
      x_new_award_status_code             => x_new_award_status_code,
      x_old_adplans_id                    => x_old_adplans_id,
      x_new_adplans_id                    => x_new_adplans_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_award_level_hist (
      award_id,
      award_hist_tran_id,
      award_attrib_code,
      award_change_source_code,
      old_offered_amt,
      new_offered_amt,
      old_accepted_amt,
      new_accepted_amt,
      old_paid_amt,
      new_paid_amt,
      old_lock_award_flag,
      new_lock_award_flag,
      old_award_status_code,
      new_award_status_code,
      old_adplans_id,
      new_adplans_id,
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
      new_references.award_hist_tran_id,
      new_references.award_attrib_code,
      new_references.award_change_source_code,
      new_references.old_offered_amt,
      new_references.new_offered_amt,
      new_references.old_accepted_amt,
      new_references.new_accepted_amt,
      new_references.old_paid_amt,
      new_references.new_paid_amt,
      new_references.old_lock_award_flag,
      new_references.new_lock_award_flag,
      new_references.old_award_status_code,
      new_references.new_award_status_code,
      new_references.old_adplans_id,
      new_references.new_adplans_id,
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

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2,
    x_award_change_source_code          IN     VARCHAR2,
    x_old_offered_amt                   IN     NUMBER,
    x_new_offered_amt                   IN     NUMBER,
    x_old_accepted_amt                  IN     NUMBER,
    x_new_accepted_amt                  IN     NUMBER,
    x_old_paid_amt                      IN     NUMBER,
    x_new_paid_amt                      IN     NUMBER,
    x_old_lock_award_flag               IN     VARCHAR2,
    x_new_lock_award_flag               IN     VARCHAR2,
    x_old_award_status_code             IN     VARCHAR2,
    x_new_award_status_code             IN     VARCHAR2,
    x_old_adplans_id                    IN     NUMBER,
    x_new_adplans_id                    IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAY-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        award_change_source_code,
        old_offered_amt,
        new_offered_amt,
        old_accepted_amt,
        new_accepted_amt,
        old_paid_amt,
        new_paid_amt,
        old_lock_award_flag,
        new_lock_award_flag,
        old_award_status_code,
        new_award_status_code,
        old_adplans_id,
        new_adplans_id
      FROM  igf_aw_award_level_hist
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
        (tlinfo.award_change_source_code = x_award_change_source_code)
        AND ((tlinfo.old_offered_amt = x_old_offered_amt) OR ((tlinfo.old_offered_amt IS NULL) AND (X_old_offered_amt IS NULL)))
        AND ((tlinfo.new_offered_amt = x_new_offered_amt) OR ((tlinfo.new_offered_amt IS NULL) AND (X_new_offered_amt IS NULL)))
        AND ((tlinfo.old_accepted_amt = x_old_accepted_amt) OR ((tlinfo.old_accepted_amt IS NULL) AND (X_old_accepted_amt IS NULL)))
        AND ((tlinfo.new_accepted_amt = x_new_accepted_amt) OR ((tlinfo.new_accepted_amt IS NULL) AND (X_new_accepted_amt IS NULL)))
        AND ((tlinfo.old_paid_amt = x_old_paid_amt) OR ((tlinfo.old_paid_amt IS NULL) AND (X_old_paid_amt IS NULL)))
        AND ((tlinfo.new_paid_amt = x_new_paid_amt) OR ((tlinfo.new_paid_amt IS NULL) AND (X_new_paid_amt IS NULL)))
        AND ((tlinfo.old_lock_award_flag = x_old_lock_award_flag) OR ((tlinfo.old_lock_award_flag IS NULL) AND (X_old_lock_award_flag IS NULL)))
        AND ((tlinfo.new_lock_award_flag = x_new_lock_award_flag) OR ((tlinfo.new_lock_award_flag IS NULL) AND (X_new_lock_award_flag IS NULL)))
        AND ((tlinfo.old_award_status_code = x_old_award_status_code) OR ((tlinfo.old_award_status_code IS NULL) AND (X_old_award_status_code IS NULL)))
        AND ((tlinfo.new_award_status_code = x_new_award_status_code) OR ((tlinfo.new_award_status_code IS NULL) AND (X_new_award_status_code IS NULL)))
        AND ((tlinfo.old_adplans_id = x_old_adplans_id) OR ((tlinfo.old_adplans_id IS NULL) AND (X_old_adplans_id IS NULL)))
        AND ((tlinfo.new_adplans_id = x_new_adplans_id) OR ((tlinfo.new_adplans_id IS NULL) AND (X_new_adplans_id IS NULL)))
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
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2,
    x_award_change_source_code          IN     VARCHAR2,
    x_old_offered_amt                   IN     NUMBER,
    x_new_offered_amt                   IN     NUMBER,
    x_old_accepted_amt                  IN     NUMBER,
    x_new_accepted_amt                  IN     NUMBER,
    x_old_paid_amt                      IN     NUMBER,
    x_new_paid_amt                      IN     NUMBER,
    x_old_lock_award_flag               IN     VARCHAR2,
    x_new_lock_award_flag               IN     VARCHAR2,
    x_old_award_status_code             IN     VARCHAR2,
    x_new_award_status_code             IN     VARCHAR2,
    x_old_adplans_id                    IN     NUMBER,
    x_new_adplans_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAY-2005
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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_AWARD_LEVEL_HIST_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_award_id                          => x_award_id,
      x_award_hist_tran_id                => x_award_hist_tran_id,
      x_award_attrib_code                 => x_award_attrib_code,
      x_award_change_source_code          => x_award_change_source_code,
      x_old_offered_amt                   => x_old_offered_amt,
      x_new_offered_amt                   => x_new_offered_amt,
      x_old_accepted_amt                  => x_old_accepted_amt,
      x_new_accepted_amt                  => x_new_accepted_amt,
      x_old_paid_amt                      => x_old_paid_amt,
      x_new_paid_amt                      => x_new_paid_amt,
      x_old_lock_award_flag               => x_old_lock_award_flag,
      x_new_lock_award_flag               => x_new_lock_award_flag,
      x_old_award_status_code             => x_old_award_status_code,
      x_new_award_status_code             => x_new_award_status_code,
      x_old_adplans_id                    => x_old_adplans_id,
      x_new_adplans_id                    => x_new_adplans_id,
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

    -- Not setting the Old value since
    -- In case of disbursments there could be updation in different disbursments but
    -- yet the transaction is the same and hence to preserve the old values it is not updated


    UPDATE igf_aw_award_level_hist
      SET
        award_change_source_code          = new_references.award_change_source_code,
--      old_offered_amt                   = new_references.old_offered_amt,
        new_offered_amt                   = new_references.new_offered_amt,
--      old_accepted_amt                  = new_references.old_accepted_amt,
        new_accepted_amt                  = new_references.new_accepted_amt,
--      old_paid_amt                      = new_references.old_paid_amt,
        new_paid_amt                      = new_references.new_paid_amt,
--      old_lock_award_flag               = new_references.old_lock_award_flag,
        new_lock_award_flag               = new_references.new_lock_award_flag,
--      old_award_status_code             = new_references.old_award_status_code,
        new_award_status_code             = new_references.new_award_status_code,
--      old_adplans_id                    = new_references.old_adplans_id,
        new_adplans_id                    = new_references.new_adplans_id,
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
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2,
    x_award_change_source_code          IN     VARCHAR2,
    x_old_offered_amt                   IN     NUMBER,
    x_new_offered_amt                   IN     NUMBER,
    x_old_accepted_amt                  IN     NUMBER,
    x_new_accepted_amt                  IN     NUMBER,
    x_old_paid_amt                      IN     NUMBER,
    x_new_paid_amt                      IN     NUMBER,
    x_old_lock_award_flag               IN     VARCHAR2,
    x_new_lock_award_flag               IN     VARCHAR2,
    x_old_award_status_code             IN     VARCHAR2,
    x_new_award_status_code             IN     VARCHAR2,
    x_old_adplans_id                    IN     NUMBER,
    x_new_adplans_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAY-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_award_level_hist
      WHERE    award_id                          = x_award_id
      AND      award_hist_tran_id                = x_award_hist_tran_id
      AND      award_attrib_code                 = x_award_attrib_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_award_id,
        x_award_hist_tran_id,
        x_award_attrib_code,
        x_award_change_source_code,
        x_old_offered_amt,
        x_new_offered_amt,
        x_old_accepted_amt,
        x_new_accepted_amt,
        x_old_paid_amt,
        x_new_paid_amt,
        x_old_lock_award_flag,
        x_new_lock_award_flag,
        x_old_award_status_code,
        x_new_award_status_code,
        x_old_adplans_id,
        x_new_adplans_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_award_id,
      x_award_hist_tran_id,
      x_award_attrib_code,
      x_award_change_source_code,
      x_old_offered_amt,
      x_new_offered_amt,
      x_old_accepted_amt,
      x_new_accepted_amt,
      x_old_paid_amt,
      x_new_paid_amt,
      x_old_lock_award_flag,
      x_new_lock_award_flag,
      x_old_award_status_code,
      x_new_award_status_code,
      x_old_adplans_id,
      x_new_adplans_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAY-2005
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

    DELETE FROM igf_aw_award_level_hist
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_award_level_hist_pkg;

/
