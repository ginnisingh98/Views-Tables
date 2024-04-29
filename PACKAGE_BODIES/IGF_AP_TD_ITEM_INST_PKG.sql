--------------------------------------------------------
--  DDL for Package Body IGF_AP_TD_ITEM_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_TD_ITEM_INST_PKG" AS
/* $Header: IGFAI15B.pls 120.8 2005/09/01 06:30:42 appldev ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_AP_TD_ITEM_INST_PKG                 |
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
 | bkkumar    #2858504  Added   legacy_ record_flag in the tbh calls     |
 | 04-jun-2003                                                           |
 *=======================================================================*/

  l_rowid VARCHAR2(25);
  old_references igf_ap_td_item_inst_all%ROWTYPE;
  new_references igf_ap_td_item_inst_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_item_sequence_number              IN     NUMBER      DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_status_date                       IN     DATE        DEFAULT NULL,
    x_add_date                          IN     DATE        DEFAULT NULL,
    x_corsp_date                        IN     DATE        DEFAULT NULL,
    x_corsp_count                       IN     NUMBER      DEFAULT NULL,
    x_inactive_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_clprl_id                          IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 13-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AP_TD_ITEM_INST_ALL
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
    new_references.item_sequence_number              := x_item_sequence_number;
    new_references.status                            := x_status;
    new_references.status_date                       := x_status_date;
    new_references.add_date                          := x_add_date;
    new_references.corsp_date                        := x_corsp_date;
    new_references.corsp_count                       := x_corsp_count;
    new_references.inactive_flag                     := x_inactive_flag;
    new_references.freq_attempt                      := x_freq_attempt;
    new_references.max_attempt                       := x_max_attempt;
    new_references.required_for_application          := x_required_for_application;
    new_references.legacy_record_flag                := x_legacy_record_flag;
    new_references.clprl_id                          := x_clprl_id;

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
  ||  Created By : rasingh
  ||  Created On : 13-NOV-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.base_id = new_references.base_id)) OR
        ((new_references.base_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_ap_fa_base_rec_pkg.get_pk_for_validation (
                new_references.base_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.item_sequence_number = new_references.item_sequence_number)) OR
        ((new_references.item_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igf_ap_td_item_mst_pkg.get_pk_for_validation (
                new_references.item_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasingh
  ||  Created On : 13-NOV-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_td_item_inst_all
      WHERE    base_id = x_base_id
      AND      item_sequence_number = x_item_sequence_number
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


 PROCEDURE check_uniqueness AS
  /*
  ||  Created By : masehgal
  ||  Created On : 26-APR-2002
  ||  Purpose : Validates the uniqueness for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
             new_references.base_id  ,
             new_references.item_sequence_number
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  FUNCTION get_uk_for_validation (
    x_base_id                           IN     NUMBER ,
    x_item_sequence_number              IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : masehgal
  ||  Created On : 26-APR-2002
  ||  Purpose : Validates the uniqueness for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT  rowid
      FROM    igf_ap_td_item_inst_all
      WHERE   base_id = x_base_id
      AND     item_sequence_number  = x_item_sequence_number
      AND    ((l_rowid IS NULL) OR (rowid <> l_rowid));

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


  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 13-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_td_item_inst_all
      WHERE   ((base_id = x_base_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AP_TDII_FA_DETAIL_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_ap_fa_base_rec;

  PROCEDURE get_fk_igf_ap_td_item_mst (
    x_todo_number              IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 13-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_td_item_inst_all
      WHERE   ((item_sequence_number = x_todo_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AP_TDII_TDI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_ap_td_item_mst;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_item_sequence_number              IN     NUMBER      DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_status_date                       IN     DATE        DEFAULT NULL,
    x_add_date                          IN     DATE        DEFAULT NULL,
    x_corsp_date                        IN     DATE        DEFAULT NULL,
    x_corsp_count                       IN     NUMBER      DEFAULT NULL,
    x_inactive_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2   ,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_clprl_id                          IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 13-NOV-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  masehgal        26-Apr-2002     # 2303509  Added call to check Uniqueness
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_base_id,
      x_item_sequence_number,
      x_status,
      x_status_date,
      x_add_date,
      x_corsp_date,
      x_corsp_count,
      x_inactive_flag,
      x_freq_attempt,
      x_max_attempt,
      x_required_for_application,
      x_legacy_record_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_clprl_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.base_id,
             new_references.item_sequence_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;

      -- Added call to check uniqueness
      check_uniqueness ;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.base_id,
             new_references.item_sequence_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

            -- Added call to check uniqueness
      check_uniqueness ;

    END IF;

  END before_dml;

  PROCEDURE after_dml(
                      p_action   IN VARCHAR2
                     ) AS
  /*
  ||  Created By :
  ||  Created On :
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||
  ||  (reverse chronological order - newest change first)
  */
  CURSOR c_inst_appl(
                     cp_base_id                NUMBER,
                     cp_item_sequence_number   NUMBER
                    ) IS
    SELECT appl_setup.*
      FROM igf_ap_appl_setup_all appl_setup,
           igf_ap_td_item_mst_all td_mst,
           igf_ap_td_item_inst_all td_inst
     WHERE td_mst.ci_cal_type           = appl_setup.ci_cal_type
       AND td_mst.ci_sequence_number    = appl_setup.ci_sequence_number
       AND td_mst.application_code      = appl_setup.application_code
       AND td_mst.todo_number           = td_inst.item_sequence_number
       AND td_inst.base_id              = cp_base_id
       AND td_inst.item_sequence_number = cp_item_sequence_number
       AND appl_setup.question_id NOT IN (SELECT question_id
                                            FROM igf_ap_st_inst_appl_all
                                           WHERE base_id = td_inst.base_id);

  l_inst_appl c_inst_appl%ROWTYPE;

  lv_rowid VARCHAR2(25) := NULL;
  lv_inst_app_id NUMBER := NULL;

  lv_base_id NUMBER;
  lv_item_sequence_number NUMBER;

  CURSOR c_appl_status(
                       cp_base_id           NUMBER,
                       cp_application_code  VARCHAR2
                      ) IS
    SELECT appl.rowid row_id,
           appl.*
      FROM igf_ap_appl_status_all appl
     WHERE appl.base_id = cp_base_id
       AND appl.application_code = cp_application_code;
  l_appl_status c_appl_status%ROWTYPE;

  -- Get application code
  CURSOR c_appl_code(
                     cp_item_sequence_number   NUMBER
                    ) IS
    SELECT application_code,
           system_todo_type_code
      FROM igf_ap_td_item_mst_all
     WHERE todo_number = cp_item_sequence_number;
  l_appl_code c_appl_code%ROWTYPE;

  BEGIN

    OPEN c_appl_code(new_references.item_sequence_number);
    FETCH c_appl_code INTO l_appl_code;
    CLOSE c_appl_code;

    IF l_appl_code.system_todo_type_code = 'INSTAPP' THEN
      IF p_action = 'INSERT' THEN
        /*
          For an institutional application to do item, on insert,
          create all the questions in the IGF_AP_ST_INST_APPL_ALL,
          and create a record for the status also.
        */
        lv_base_id := new_references.base_id;
        lv_item_sequence_number := new_references.item_sequence_number;

        FOR l_inst_appl IN c_inst_appl(lv_base_id, lv_item_sequence_number) LOOP
          igf_ap_st_inst_appl_pkg.insert_row(
                                             x_rowid            =>  lv_rowid,
                                             x_inst_app_id      =>  lv_inst_app_id,
                                             x_base_id          =>  lv_base_id,
                                             x_question_id      =>  l_inst_appl.question_id,
                                             x_question_value   =>  NULL,
                                             x_application_code =>  l_inst_appl.application_code,
                                             x_mode             =>  'R'
                                            );
        END LOOP;

        lv_rowid     := NULL;

        IF l_appl_code.application_code IS NOT NULL THEN
          igf_ap_appl_status_pkg.insert_row(
                                            x_rowid                   => lv_rowid,
                                            x_base_id                 => lv_base_id,
                                            x_application_code        => l_appl_code.application_code,
                                            x_application_status_code => new_references.status,
                                            x_mode                    => 'R'
                                           );
        END IF;
      END IF;

      IF p_action = 'UPDATE' THEN
        IF NVL(old_references.status,'*') <> NVL(new_references.status,'**') THEN
          /*
            On update of a institutional application to do item, update the status of the to do item also
          */

          OPEN c_appl_status(new_references.base_id,l_appl_code.application_code);
          FETCH c_appl_status INTO l_appl_status;
          CLOSE c_appl_status;

          igf_ap_appl_status_pkg.update_row(
                                            x_rowid                   => l_appl_status.row_id,
                                            x_base_id                 => l_appl_status.base_id,
                                            x_application_code        => l_appl_status.application_code,
                                            x_application_status_code => new_references.status,
                                            x_mode                    => 'R'
                                           );
        END IF;
        IF old_references.inactive_flag IS NOT NULL AND
           new_references.inactive_flag IS NOT NULL AND
           old_references.inactive_flag = 'Y' AND
           new_references.inactive_flag = 'N' THEN
          /*
            On updating a to do from inactive to active, create the questions once again
          */
          lv_base_id := new_references.base_id;
          lv_item_sequence_number := new_references.item_sequence_number;

          FOR l_inst_appl IN c_inst_appl(lv_base_id, lv_item_sequence_number) LOOP
            igf_ap_st_inst_appl_pkg.insert_row(
                                               x_rowid            =>  lv_rowid,
                                               x_inst_app_id      =>  lv_inst_app_id,
                                               x_base_id          =>  lv_base_id,
                                               x_question_id      =>  l_inst_appl.question_id,
                                               x_question_value   =>  NULL,
                                               x_application_code =>  l_inst_appl.application_code,
                                               x_mode             =>  'R'
                                              );
          END LOOP;
          lv_rowid     := NULL;

          IF l_appl_code.application_code IS NOT NULL THEN
            igf_ap_appl_status_pkg.add_row(
                                           x_rowid                   => lv_rowid,
                                           x_base_id                 => lv_base_id,
                                           x_application_code        => l_appl_code.application_code,
                                           x_application_status_code => new_references.status,
                                           x_mode                    => 'R'
                                          );
          END IF;
        END IF;
      END IF;
    END IF;
  END after_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_add_date                          IN     DATE,
    x_corsp_date                        IN     DATE,
    x_corsp_count                       IN     NUMBER,
    x_inactive_flag                     IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_legacy_record_flag                IN     VARCHAR2,
    x_clprl_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 13-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_td_item_inst_all
      WHERE    base_id                           = x_base_id
      AND      item_sequence_number              = x_item_sequence_number;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

    l_org_id                     igf_ap_td_item_inst_all.org_id%TYPE  DEFAULT igf_aw_gen.get_org_id;

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
      x_base_id                           => x_base_id,
      x_item_sequence_number              => x_item_sequence_number,
      x_status                            => x_status,
      x_status_date                       => x_status_date,
      x_add_date                          => x_add_date,
      x_corsp_date                        => x_corsp_date,
      x_corsp_count                       => x_corsp_count,
      x_inactive_flag                     => x_inactive_flag,
      x_freq_attempt                      => x_freq_attempt,
      x_max_attempt                       => x_max_attempt,
      x_required_for_application          => x_required_for_application,
      x_legacy_record_flag                => x_legacy_record_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_clprl_id                          => x_clprl_id
    );

    INSERT INTO igf_ap_td_item_inst_all (
      base_id,
      item_sequence_number,
      status,
      status_date,
      add_date,
      corsp_date,
      corsp_count,
      inactive_flag,
      freq_attempt,
      max_attempt,
      required_for_application,
      legacy_record_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id,
      clprl_id
    ) VALUES (
      new_references.base_id,
      new_references.item_sequence_number,
      new_references.status,
      new_references.status_date,
      new_references.add_date,
      new_references.corsp_date,
      new_references.corsp_count,
      new_references.inactive_flag,
      new_references.freq_attempt,
      new_references.max_attempt,
      new_references.required_for_application,
      new_references.legacy_record_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      l_org_id,
      new_references.clprl_id
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

    after_dml(p_action => 'INSERT');

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_add_date                          IN     DATE,
    x_corsp_date                        IN     DATE,
    x_corsp_count                       IN     NUMBER,
    x_inactive_flag                     IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2,
    x_clprl_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 13-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        status,
        status_date,
        add_date,
        corsp_date,
        corsp_count,
        inactive_flag,
        freq_attempt,
        max_attempt,
        required_for_application,
        org_id,
        legacy_record_flag,
        clprl_id
      FROM  igf_ap_td_item_inst_all
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
        ((tlinfo.status = x_status) OR ((tlinfo.status IS NULL) AND (X_status IS NULL)))
        AND ((tlinfo.status_date = x_status_date) OR ((tlinfo.status_date IS NULL) AND (X_status_date IS NULL)))
        AND ((tlinfo.add_date = x_add_date) OR ((tlinfo.add_date IS NULL) AND (X_add_date IS NULL)))
        AND ((tlinfo.corsp_date = x_corsp_date) OR ((tlinfo.corsp_date IS NULL) AND (X_corsp_date IS NULL)))
        AND ((tlinfo.corsp_count = x_corsp_count) OR ((tlinfo.corsp_count IS NULL) AND (X_corsp_count IS NULL)))
        AND ((tlinfo.inactive_flag = x_inactive_flag) OR ((tlinfo.inactive_flag IS NULL) AND (X_inactive_flag IS NULL)))
        AND ((tlinfo.freq_attempt = x_freq_attempt) OR ((tlinfo.freq_attempt IS NULL) AND (x_freq_attempt IS NULL)))
        AND ((tlinfo.max_attempt = x_max_attempt) OR ((tlinfo.max_attempt IS NULL) AND (X_max_attempt IS NULL)))
   AND ((tlinfo.required_for_application = x_required_for_application) OR ((tlinfo.required_for_application IS NULL) AND (x_required_for_application IS NULL)))
   AND ((tlinfo.legacy_record_flag = x_legacy_record_flag) OR ((tlinfo.legacy_record_flag IS NULL) AND (x_legacy_record_flag IS NULL)))
        AND ((tlinfo.clprl_id = x_clprl_id) OR ((tlinfo.clprl_id IS NULL) AND (x_clprl_id IS NULL)))
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
    x_item_sequence_number              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_add_date                          IN     DATE,
    x_corsp_date                        IN     DATE,
    x_corsp_count                       IN     NUMBER,
    x_inactive_flag                     IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_legacy_record_flag                IN     VARCHAR2,
    x_clprl_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 13-NOV-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
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
      x_base_id                           => x_base_id,
      x_item_sequence_number              => x_item_sequence_number,
      x_status                            => x_status,
      x_status_date                       => x_status_date,
      x_add_date                          => x_add_date,
      x_corsp_date                        => x_corsp_date,
      x_corsp_count                       => x_corsp_count,
      x_inactive_flag                     => x_inactive_flag,
      x_freq_attempt                      => x_freq_attempt,
      x_max_attempt                       => x_max_attempt,
      x_required_for_application          => x_required_for_application,
      x_legacy_record_flag                => x_legacy_record_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_clprl_id                          => x_clprl_id
    );

    UPDATE igf_ap_td_item_inst_all
      SET
        status                            = new_references.status,
        status_date                       = new_references.status_date,
        add_date                          = new_references.add_date,
        corsp_date                        = new_references.corsp_date,
        corsp_count                       = new_references.corsp_count,
        inactive_flag                     = new_references.inactive_flag,
        freq_attempt                      = new_references.freq_attempt,
        max_attempt                       = new_references.max_attempt,
        required_for_application          = new_references.required_for_application,
        legacy_record_flag                = new_references.legacy_record_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        clprl_id                          = new_references.clprl_id
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    after_dml(p_action => 'UPDATE');

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_add_date                          IN     DATE,
    x_corsp_date                        IN     DATE,
    x_corsp_count                       IN     NUMBER,
    x_inactive_flag                     IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_legacy_record_flag                IN     VARCHAR2,
    x_clprl_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 13-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_td_item_inst_all
      WHERE    base_id                           = x_base_id
      AND      item_sequence_number              = x_item_sequence_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_base_id,
        x_item_sequence_number,
        x_status,
        x_status_date,
        x_add_date,
        x_corsp_date,
        x_corsp_count,
        x_inactive_flag,
        x_freq_attempt,
        x_max_attempt,
        x_required_for_application,
        x_mode,
        x_legacy_record_flag,
        x_clprl_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_base_id,
      x_item_sequence_number,
      x_status,
      x_status_date,
      x_add_date,
      x_corsp_date,
      x_corsp_count,
      x_inactive_flag,
      x_freq_attempt,
      x_max_attempt,
      x_required_for_application,
      x_mode,
      x_legacy_record_flag,
      x_clprl_id
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 13-NOV-2000
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

    DELETE FROM igf_ap_td_item_inst_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_td_item_inst_pkg;

/
