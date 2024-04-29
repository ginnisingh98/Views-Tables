--------------------------------------------------------
--  DDL for Package Body IGF_AP_TD_ITEM_MST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_TD_ITEM_MST_PKG" AS
/* $Header: IGFAI37B.pls 120.2 2005/08/16 23:07:52 appldev ship $ */

 /*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_AP_TD_ITEM_MST_PKG                  |
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
 | gvarapra         13-sep-2004     FA138 - ISIR Enhancements            |
 |                                 added new cloumn system_todo_type_code|
 *=======================================================================*/

  l_rowid VARCHAR2(25);
  old_references igf_ap_td_item_mst_all%ROWTYPE;
  new_references igf_ap_td_item_mst_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_todo_number                       IN     NUMBER  ,
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_description                       IN     VARCHAR2,
    x_corsp_mesg                        IN     VARCHAR2,
    x_career_item                       IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER  ,
    x_max_attempt                       IN     NUMBER  ,
    x_required_for_application          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_system_todo_type_code             IN     VARCHAR2,
    x_application_code                  IN     VARCHAR2,
    x_display_in_ss_flag                IN     VARCHAR2,
    x_ss_instruction_txt                IN     VARCHAR2,
    x_allow_attachment_flag             IN     VARCHAR2,
    x_document_url_txt                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 29-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AP_TD_ITEM_MST_ALL
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
    new_references.todo_number                       := x_todo_number;
    new_references.item_code                         := x_item_code;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.description                       := x_description;
    new_references.corsp_mesg                        := x_corsp_mesg;
    new_references.career_item                       := x_career_item;
    new_references.freq_attempt                      := x_freq_attempt;
    new_references.max_attempt                       := x_max_attempt;
    new_references.required_for_application          := x_required_for_application;
    new_references.system_todo_type_code             := x_system_todo_type_code;
    new_references.application_code                  := x_application_code;
    new_references.display_in_ss_flag                := x_display_in_ss_flag;
    new_references.ss_instruction_txt                := x_ss_instruction_txt;
    new_references.allow_attachment_flag             := x_allow_attachment_flag;
    new_references.document_url_txt                  := x_document_url_txt;

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
  ||  Created By : kkillams
  ||  Created On : 29-MAY-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.item_code,
           new_references.ci_cal_type,
           new_references.ci_sequence_number,
           new_references.org_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_child_existance IS
/*
  ||  Created By : kkillams
  ||  Created On : 07-JUN-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 */
  BEGIN

    igf_aw_fund_td_map_pkg.get_fk_igf_ap_td_item_mst(
      old_references.todo_number
    );
    igf_ap_td_item_inst_pkg.get_fk_igf_ap_td_item_mst(
    old_references.todo_number
    );

  END check_child_existance;

  PROCEDURE get_fk_igf_ap_appl_setup(
    x_ci_cal_type          IN     VARCHAR2,
    x_ci_sequence_number   IN     NUMBER,
    x_application_code     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 07/June/2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_td_item_mst_all
      WHERE   ((ci_cal_type = x_ci_cal_type) AND
               (ci_sequence_number = x_ci_sequence_number) AND
               (application_code = x_application_code));

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

  END get_fk_igf_ap_appl_setup;

  FUNCTION get_pk_for_validation (
    x_todo_number                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kkillams
  ||  Created On : 29-MAY-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_td_item_mst_all
      WHERE    todo_number = x_todo_number
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
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_org_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kkillams
  ||  Created On : 29-MAY-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_td_item_mst
      WHERE    UPPER(item_code) =UPPER( x_item_code)
      AND      ci_cal_type = x_ci_cal_type
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

 PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_todo_number                       IN     NUMBER  ,
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_description                       IN     VARCHAR2,
    x_corsp_mesg                        IN     VARCHAR2,
    x_career_item                       IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER  ,
    x_max_attempt                       IN     NUMBER  ,
    x_required_for_application          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_system_todo_type_code             IN     VARCHAR2,
    x_application_code                  IN     VARCHAR2,
    x_display_in_ss_flag                IN     VARCHAR2,
    x_ss_instruction_txt                IN     VARCHAR2,
    x_allow_attachment_flag             IN     VARCHAR2,
    x_document_url_txt                  IN     VARCHAR2

  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 29-MAY-2001
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
      x_todo_number,
      x_item_code,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_description,
      x_corsp_mesg,
      x_career_item,
      x_freq_attempt,
      x_max_attempt,
      x_required_for_application,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_system_todo_type_code,
      x_application_code,
      x_display_in_ss_flag,
      x_ss_instruction_txt,
      x_allow_attachment_flag,
      x_document_url_txt
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.todo_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.todo_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_todo_number                       IN OUT NOCOPY NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_corsp_mesg                        IN     VARCHAR2,
    x_career_item                       IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER  ,
    x_max_attempt                       IN     NUMBER  ,
    x_required_for_application          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_system_todo_type_code             IN     VARCHAR2,
    x_application_code                  IN     VARCHAR2,
    x_display_in_ss_flag                IN     VARCHAR2,
    x_ss_instruction_txt                IN     VARCHAR2,
    x_allow_attachment_flag             IN     VARCHAR2,
    x_document_url_txt                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 29-MAY-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_td_item_mst_all
      WHERE    todo_number                       = x_todo_number;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

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

    SELECT    igf_ap_td_item_mst_all_s.NEXTVAL
    INTO      x_todo_number
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_todo_number                       => x_todo_number,
      x_item_code                         => x_item_code,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_description                       => x_description,
      x_corsp_mesg                        => x_corsp_mesg,
      x_career_item                       => x_career_item,
      x_freq_attempt                      => x_freq_attempt,
      x_max_attempt                       => x_max_attempt,
      x_required_for_application          => x_required_for_application,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_system_todo_type_code             => x_system_todo_type_code,
      x_application_code                  => x_application_code,
      x_display_in_ss_flag                => x_display_in_ss_flag,
      x_ss_instruction_txt                => x_ss_instruction_txt,
      x_allow_attachment_flag             => x_allow_attachment_flag,
      x_document_url_txt                  => x_document_url_txt
    );

    INSERT INTO igf_ap_td_item_mst_all (
      todo_number,
      item_code,
      ci_cal_type,
      ci_sequence_number,
      description,
      corsp_mesg,
      career_item,
      freq_attempt,
      max_attempt,
      required_for_application,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      system_todo_type_code,
      application_code,
      display_in_ss_flag,
      ss_instruction_txt,
      allow_attachment_flag,
      document_url_txt
    ) VALUES (
      new_references.todo_number,
      new_references.item_code,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      new_references.description,
      new_references.corsp_mesg,
      new_references.career_item,
      new_references.freq_attempt,
      new_references.max_attempt,
      new_references.required_for_application,
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.system_todo_type_code,
      new_references.application_code,
      new_references.display_in_ss_flag,
      new_references.ss_instruction_txt,
      new_references.allow_attachment_flag,
      new_references.document_url_txt
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
    x_todo_number                       IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_corsp_mesg                        IN     VARCHAR2,
    x_career_item                       IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER  ,
    x_max_attempt                       IN     NUMBER  ,
    x_required_for_application          IN     VARCHAR2,
    x_system_todo_type_code             IN     VARCHAR2,
    x_application_code                  IN     VARCHAR2,
    x_display_in_ss_flag                IN     VARCHAR2,
    x_ss_instruction_txt                IN     VARCHAR2,
    x_allow_attachment_flag             IN     VARCHAR2,
    x_document_url_txt                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 29-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        item_code,
        ci_cal_type,
        ci_sequence_number,
        description,
        corsp_mesg,
        career_item,
        freq_attempt,
        max_attempt,
        required_for_application,
        system_todo_type_code,
        application_code,
        display_in_ss_flag,
        ss_instruction_txt,
        allow_attachment_flag,
        document_url_txt
      FROM  igf_ap_td_item_mst_all
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
        (tlinfo.item_code = x_item_code)
        AND ((tlinfo.ci_cal_type = x_ci_cal_type) OR ((tlinfo.ci_cal_type IS NULL) AND (X_ci_cal_type IS NULL)))
        AND ((tlinfo.ci_sequence_number = x_ci_sequence_number) OR ((tlinfo.ci_sequence_number IS NULL) AND (X_ci_sequence_number IS NULL)))
        AND (tlinfo.description = x_description)
        AND ((tlinfo.corsp_mesg = x_corsp_mesg) OR ((tlinfo.corsp_mesg IS NULL) AND (X_corsp_mesg IS NULL)))
        AND (tlinfo.career_item = x_career_item)
        AND ((tlinfo.freq_attempt = x_freq_attempt) OR ((tlinfo.freq_attempt IS NULL) AND (x_freq_attempt IS NULL)))
        AND ((tlinfo.max_attempt = x_max_attempt) OR ((tlinfo.max_attempt IS NULL) AND (X_max_attempt IS NULL)))
        AND ((tlinfo.required_for_application = x_required_for_application) OR ((tlinfo.required_for_application IS NULL) AND (x_required_for_application IS NULL)))
        AND ((tlinfo.system_todo_type_code = x_system_todo_type_code) OR ((tlinfo.system_todo_type_code IS NULL) AND (x_system_todo_type_code IS NULL)))
        AND ((tlinfo.application_code = x_application_code) OR ((tlinfo.application_code IS NULL) AND (x_application_code IS NULL)))
        AND ((tlinfo.display_in_ss_flag = x_display_in_ss_flag) OR ((tlinfo.display_in_ss_flag IS NULL) AND (x_display_in_ss_flag IS NULL)))
        AND ((tlinfo.ss_instruction_txt = x_ss_instruction_txt) OR ((tlinfo.ss_instruction_txt IS NULL) AND (x_ss_instruction_txt IS NULL)))
        AND ((tlinfo.allow_attachment_flag = x_allow_attachment_flag) OR ((tlinfo.allow_attachment_flag IS NULL) AND (x_allow_attachment_flag IS NULL)))
        AND ((tlinfo.document_url_txt = x_document_url_txt) OR ((tlinfo.document_url_txt IS NULL) AND (x_document_url_txt IS NULL)))
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
    x_todo_number                       IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_corsp_mesg                        IN     VARCHAR2,
    x_career_item                       IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER  ,
    x_max_attempt                       IN     NUMBER  ,
    x_required_for_application          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_system_todo_type_code             IN     VARCHAR2,
    x_application_code                  IN     VARCHAR2,
    x_display_in_ss_flag                IN     VARCHAR2,
    x_ss_instruction_txt                IN     VARCHAR2,
    x_allow_attachment_flag             IN     VARCHAR2,
    x_document_url_txt                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 29-MAY-2001
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
      x_todo_number                       => x_todo_number,
      x_item_code                         => x_item_code,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_description                       => x_description,
      x_corsp_mesg                        => x_corsp_mesg,
      x_career_item                       => x_career_item,
      x_freq_attempt                      => x_freq_attempt,
      x_max_attempt                       => x_max_attempt,
      x_required_for_application          => x_required_for_application,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_system_todo_type_code             => x_system_todo_type_code,
      x_application_code                  => x_application_code,
      x_display_in_ss_flag                => x_display_in_ss_flag,
      x_ss_instruction_txt                => x_ss_instruction_txt,
      x_allow_attachment_flag             => x_allow_attachment_flag,
      x_document_url_txt                  => x_document_url_txt

    );

    UPDATE igf_ap_td_item_mst_all
      SET
        item_code                         = new_references.item_code,
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        description                       = new_references.description,
        corsp_mesg                        = new_references.corsp_mesg,
        career_item                       = new_references.career_item,
        freq_attempt                      = new_references.freq_attempt,
        max_attempt                       = new_references.max_attempt,
        required_for_application          = new_references.required_for_application,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        system_todo_type_code             = new_references.system_todo_type_code,
        application_code                  = new_references.application_code,
        display_in_ss_flag                = new_references.display_in_ss_flag,
        ss_instruction_txt                = new_references.ss_instruction_txt,
        allow_attachment_flag             = new_references.allow_attachment_flag,
        document_url_txt                  = new_references.document_url_txt
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_todo_number                       IN OUT NOCOPY NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_corsp_mesg                        IN     VARCHAR2,
    x_career_item                       IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER  ,
    x_max_attempt                       IN     NUMBER  ,
    x_required_for_application          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_system_todo_type_code             IN     VARCHAR2,
    x_application_code                  IN     VARCHAR2,
    x_display_in_ss_flag                IN     VARCHAR2,
    x_ss_instruction_txt                IN     VARCHAR2,
    x_allow_attachment_flag             IN     VARCHAR2,
    x_document_url_txt                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 29-MAY-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_td_item_mst_all
      WHERE    todo_number                       = x_todo_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_todo_number,
        x_item_code,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_description,
        x_corsp_mesg,
        x_career_item,
        x_freq_attempt,
        x_max_attempt,
        x_required_for_application,
        x_mode,
        x_system_todo_type_code,
        x_application_code,
        x_display_in_ss_flag,
        x_ss_instruction_txt,
        x_allow_attachment_flag,
        x_document_url_txt
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_todo_number,
      x_item_code,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_description,
      x_corsp_mesg,
      x_career_item,
      x_freq_attempt,
      x_max_attempt,
      x_required_for_application,
      x_mode,
      x_system_todo_type_code,
      x_application_code,
      x_display_in_ss_flag,
      x_ss_instruction_txt,
      x_allow_attachment_flag,
      x_document_url_txt
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 29-MAY-2001
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

    DELETE FROM igf_ap_td_item_mst_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_td_item_mst_pkg;

/
