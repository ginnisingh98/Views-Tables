--------------------------------------------------------
--  DDL for Package Body IGS_DA_CNFG_REQ_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_DA_CNFG_REQ_TYP_PKG" AS
/* $Header: IGSKI46B.pls 120.0 2005/07/05 12:55:39 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_da_cnfg_req_typ%ROWTYPE;
  new_references igs_da_cnfg_req_typ%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_request_name                      IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_request_mode                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_purgable_ind                      IN     VARCHAR2,
    x_request_type_comment              IN     VARCHAR2,
    x_wif_ind                           IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_wif_program_mod_ind               IN     VARCHAR2,
    x_wif_catalog_cal_type              IN     VARCHAR2,
    x_wif_catalog_ci_seq_num            IN     NUMBER,
    x_wif_catalog_mod_ind               IN     VARCHAR2,
    x_special_ind                       IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_special_program_mod_ind           IN     VARCHAR2,
    x_special_catalog                   IN     VARCHAR2,
    x_special_catalog_mod_ind           IN     VARCHAR2,
    x_enrolled_ind                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_spa_complete_ind                  IN     VARCHAR2,
    x_susa_complete_ind                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_da_cnfg_req_typ
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
    new_references.request_type_id                   := x_request_type_id;
    new_references.request_name                      := x_request_name;
    new_references.request_type                      := x_request_type;
    new_references.request_mode                      := x_request_mode;
    new_references.closed_ind                        := x_closed_ind;
    new_references.purgable_ind                      := x_purgable_ind;
    new_references.request_type_comment              := x_request_type_comment;
    new_references.wif_ind                           := x_wif_ind;
    new_references.wif_program_code                  := x_wif_program_code;
    new_references.wif_program_mod_ind               := x_wif_program_mod_ind;
    new_references.wif_catalog_cal_type              := x_wif_catalog_cal_type;
    new_references.wif_catalog_ci_seq_num            := x_wif_catalog_ci_seq_num;
    new_references.wif_catalog_mod_ind               := x_wif_catalog_mod_ind;
    new_references.special_ind                       := x_special_ind;
    new_references.special_program_code              := x_special_program_code;
    new_references.special_program_mod_ind           := x_special_program_mod_ind;
    new_references.special_catalog                   := x_special_catalog;
    new_references.special_catalog_mod_ind           := x_special_catalog_mod_ind;
    new_references.enrolled_ind                      := x_enrolled_ind;
    new_references.attribute_category                := x_attribute_category;
    new_references.attribute1                        := x_attribute1;
    new_references.attribute2                        := x_attribute2;
    new_references.attribute3                        := x_attribute3;
    new_references.attribute4                        := x_attribute4;
    new_references.attribute5                        := x_attribute5;
    new_references.attribute6                        := x_attribute6;
    new_references.attribute7                        := x_attribute7;
    new_references.attribute8                        := x_attribute8;
    new_references.attribute9                        := x_attribute9;
    new_references.attribute10                       := x_attribute10;
    new_references.attribute11                       := x_attribute11;
    new_references.attribute12                       := x_attribute12;
    new_references.attribute13                       := x_attribute13;
    new_references.attribute14                       := x_attribute14;
    new_references.attribute15                       := x_attribute15;
    new_references.attribute16                       := x_attribute16;
    new_references.attribute17                       := x_attribute17;
    new_references.attribute18                       := x_attribute18;
    new_references.attribute19                       := x_attribute19;
    new_references.attribute20                       := x_attribute20;
    new_references.spa_complete_ind                  := x_spa_complete_ind;
    new_references.susa_complete_ind                 := x_susa_complete_ind;

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



  FUNCTION get_uk_for_validation (
    x_request_name                      IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_request_mode                      IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ddey
  ||  Created On : 04-Apr-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_cnfg_req_typ
      WHERE    request_name = x_request_name
      AND      request_type = x_request_type
      AND      request_mode = x_request_mode
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


 PROCEDURE check_uniqueness AS
  /*
  ||  Created By : ddey
  ||  Created On : 04-Apr-2003
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.request_name ,
           new_references.request_type ,
           new_references.request_mode
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.wif_program_code = new_references.wif_program_code)) OR
        ((new_references.wif_program_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_course_pkg.get_pk_for_validation (
                new_references.wif_program_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.wif_catalog_cal_type = new_references.wif_catalog_cal_type) AND
         (old_references.wif_catalog_ci_seq_num = new_references.wif_catalog_ci_seq_num)) OR
        ((new_references.wif_catalog_cal_type IS NULL) OR
         (new_references.wif_catalog_ci_seq_num IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.wif_catalog_cal_type,
                new_references.wif_catalog_ci_seq_num
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_da_cnfg_pkg.get_fk_igs_da_cnfg_req_typ (
      old_references.request_type_id
    );

    igs_da_cnfg_ftr_pkg.get_fk_igs_da_cnfg_req_typ (
      old_references.request_type_id
    );

    igs_da_cnfg_stat_pkg.get_fk_igs_da_cnfg_req_typ (
      old_references.request_type_id
    );

    igs_da_rqst_pkg.get_fk_igs_da_cnfg_req_typ (
        old_references.request_type_id );


  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_request_type_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_cnfg_req_typ
      WHERE    request_type_id = x_request_type_id
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


  PROCEDURE get_fk_igs_ps_course (
    x_course_cd                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_cnfg_req_typ
      WHERE   ((wif_program_code = x_course_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_DA_CNFG_PSC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_course;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_cnfg_req_typ
      WHERE   ((wif_catalog_cal_type = x_cal_type) AND
               (wif_catalog_ci_seq_num = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_DA_CNFG_CAI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_request_name                      IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_request_mode                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_purgable_ind                      IN     VARCHAR2,
    x_request_type_comment              IN     VARCHAR2,
    x_wif_ind                           IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_wif_program_mod_ind               IN     VARCHAR2,
    x_wif_catalog_cal_type              IN     VARCHAR2,
    x_wif_catalog_ci_seq_num            IN     NUMBER,
    x_wif_catalog_mod_ind               IN     VARCHAR2,
    x_special_ind                       IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_special_program_mod_ind           IN     VARCHAR2,
    x_special_catalog                   IN     VARCHAR2,
    x_special_catalog_mod_ind           IN     VARCHAR2,
    x_enrolled_ind                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_spa_complete_ind                  IN     VARCHAR2,
    x_susa_complete_ind                 IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
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
      x_request_type_id,
      x_request_name,
      x_request_type,
      x_request_mode,
      x_closed_ind,
      x_purgable_ind,
      x_request_type_comment,
      x_wif_ind,
      x_wif_program_code,
      x_wif_program_mod_ind,
      x_wif_catalog_cal_type,
      x_wif_catalog_ci_seq_num,
      x_wif_catalog_mod_ind,
      x_special_ind,
      x_special_program_code,
      x_special_program_mod_ind,
      x_special_catalog,
      x_special_catalog_mod_ind,
      x_enrolled_ind,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_spa_complete_ind,
      x_susa_complete_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.request_type_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.request_type_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_request_type_id                   IN OUT NOCOPY NUMBER,
    x_request_name                      IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_request_mode                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_purgable_ind                      IN     VARCHAR2,
    x_request_type_comment              IN     VARCHAR2,
    x_wif_ind                           IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_wif_program_mod_ind               IN     VARCHAR2,
    x_wif_catalog_cal_type              IN     VARCHAR2,
    x_wif_catalog_ci_seq_num            IN     NUMBER,
    x_wif_catalog_mod_ind               IN     VARCHAR2,
    x_special_ind                       IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_special_program_mod_ind           IN     VARCHAR2,
    x_special_catalog                   IN     VARCHAR2,
    x_special_catalog_mod_ind           IN     VARCHAR2,
    x_enrolled_ind                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_spa_complete_ind                  IN     VARCHAR2,
    x_susa_complete_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_CNFG_REQ_TYP_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    -- x_request_type_id := NULL;  -- Commented by Deep. Need to be verified

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_request_type_id                   => x_request_type_id,
      x_request_name                      => x_request_name,
      x_request_type                      => x_request_type,
      x_request_mode                      => x_request_mode,
      x_closed_ind                        => x_closed_ind,
      x_purgable_ind                      => x_purgable_ind,
      x_request_type_comment              => x_request_type_comment,
      x_wif_ind                           => x_wif_ind,
      x_wif_program_code                  => x_wif_program_code,
      x_wif_program_mod_ind               => x_wif_program_mod_ind,
      x_wif_catalog_cal_type              => x_wif_catalog_cal_type,
      x_wif_catalog_ci_seq_num            => x_wif_catalog_ci_seq_num,
      x_wif_catalog_mod_ind               => x_wif_catalog_mod_ind,
      x_special_ind                       => x_special_ind,
      x_special_program_code              => x_special_program_code,
      x_special_program_mod_ind           => x_special_program_mod_ind,
      x_special_catalog                   => x_special_catalog,
      x_special_catalog_mod_ind           => x_special_catalog_mod_ind,
      x_enrolled_ind                      => x_enrolled_ind,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_spa_complete_ind                  => x_spa_complete_ind,
      x_susa_complete_ind                 => x_susa_complete_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_da_cnfg_req_typ (
      request_type_id,
      request_name,
      request_type,
      request_mode,
      closed_ind,
      purgable_ind,
      request_type_comment,
      wif_ind,
      wif_program_code,
      wif_program_mod_ind,
      wif_catalog_cal_type,
      wif_catalog_ci_seq_num,
      wif_catalog_mod_ind,
      special_ind,
      special_program_code,
      special_program_mod_ind,
      special_catalog,
      special_catalog_mod_ind,
      enrolled_ind,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      spa_complete_ind,
      susa_complete_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_da_cnfg_req_typ_s.NEXTVAL,
      new_references.request_name,
      new_references.request_type,
      new_references.request_mode,
      new_references.closed_ind,
      new_references.purgable_ind,
      new_references.request_type_comment,
      new_references.wif_ind,
      new_references.wif_program_code,
      new_references.wif_program_mod_ind,
      new_references.wif_catalog_cal_type,
      new_references.wif_catalog_ci_seq_num,
      new_references.wif_catalog_mod_ind,
      new_references.special_ind,
      new_references.special_program_code,
      new_references.special_program_mod_ind,
      new_references.special_catalog,
      new_references.special_catalog_mod_ind,
      new_references.enrolled_ind,
      new_references.attribute_category,
      new_references.attribute1,
      new_references.attribute2,
      new_references.attribute3,
      new_references.attribute4,
      new_references.attribute5,
      new_references.attribute6,
      new_references.attribute7,
      new_references.attribute8,
      new_references.attribute9,
      new_references.attribute10,
      new_references.attribute11,
      new_references.attribute12,
      new_references.attribute13,
      new_references.attribute14,
      new_references.attribute15,
      new_references.attribute16,
      new_references.attribute17,
      new_references.attribute18,
      new_references.attribute19,
      new_references.attribute20,
      new_references.spa_complete_ind,
      new_references.susa_complete_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, request_type_id INTO x_rowid, x_request_type_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_request_name                      IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_request_mode                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_purgable_ind                      IN     VARCHAR2,
    x_request_type_comment              IN     VARCHAR2,
    x_wif_ind                           IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_wif_program_mod_ind               IN     VARCHAR2,
    x_wif_catalog_cal_type              IN     VARCHAR2,
    x_wif_catalog_ci_seq_num            IN     NUMBER,
    x_wif_catalog_mod_ind               IN     VARCHAR2,
    x_special_ind                       IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_special_program_mod_ind           IN     VARCHAR2,
    x_special_catalog                   IN     VARCHAR2,
    x_special_catalog_mod_ind           IN     VARCHAR2,
    x_enrolled_ind                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_spa_complete_ind                  IN     VARCHAR2,
    x_susa_complete_ind                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        request_name,
        request_type,
        request_mode,
        closed_ind,
        purgable_ind,
        request_type_comment,
        wif_ind,
        wif_program_code,
        wif_program_mod_ind,
        wif_catalog_cal_type,
        wif_catalog_ci_seq_num,
        wif_catalog_mod_ind,
        special_ind,
        special_program_code,
        special_program_mod_ind,
        special_catalog,
        special_catalog_mod_ind,
        enrolled_ind,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        spa_complete_ind,
        susa_complete_ind
      FROM  igs_da_cnfg_req_typ
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
        (tlinfo.request_name = x_request_name)
        AND (tlinfo.request_type = x_request_type)
        AND (tlinfo.request_mode = x_request_mode)
        AND (tlinfo.closed_ind = x_closed_ind)
        AND (tlinfo.purgable_ind = x_purgable_ind)
        AND ((tlinfo.request_type_comment = x_request_type_comment) OR ((tlinfo.request_type_comment IS NULL) AND (X_request_type_comment IS NULL)))
        AND (tlinfo.wif_ind = x_wif_ind)
        AND ((tlinfo.wif_program_code = x_wif_program_code) OR ((tlinfo.wif_program_code IS NULL) AND (X_wif_program_code IS NULL)))
        AND (tlinfo.wif_program_mod_ind = x_wif_program_mod_ind)
        AND ((tlinfo.wif_catalog_cal_type = x_wif_catalog_cal_type) OR ((tlinfo.wif_catalog_cal_type IS NULL) AND (X_wif_catalog_cal_type IS NULL)))
        AND ((tlinfo.wif_catalog_ci_seq_num = x_wif_catalog_ci_seq_num) OR ((tlinfo.wif_catalog_ci_seq_num IS NULL) AND (X_wif_catalog_ci_seq_num IS NULL)))
        AND (tlinfo.wif_catalog_mod_ind = x_wif_catalog_mod_ind)
        AND (tlinfo.special_ind = x_special_ind)
        AND ((tlinfo.special_program_code = x_special_program_code) OR ((tlinfo.special_program_code IS NULL) AND (X_special_program_code IS NULL)))
        AND (tlinfo.special_program_mod_ind = x_special_program_mod_ind)
        AND ((tlinfo.special_catalog = x_special_catalog) OR ((tlinfo.special_catalog IS NULL) AND (X_special_catalog IS NULL)))
        AND (tlinfo.special_catalog_mod_ind = x_special_catalog_mod_ind)
        AND (tlinfo.enrolled_ind = x_enrolled_ind)
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (X_attribute11 IS NULL)))
        AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (X_attribute12 IS NULL)))
        AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (X_attribute13 IS NULL)))
        AND ((tlinfo.attribute14 = x_attribute14) OR ((tlinfo.attribute14 IS NULL) AND (X_attribute14 IS NULL)))
        AND ((tlinfo.attribute15 = x_attribute15) OR ((tlinfo.attribute15 IS NULL) AND (X_attribute15 IS NULL)))
        AND ((tlinfo.attribute16 = x_attribute16) OR ((tlinfo.attribute16 IS NULL) AND (X_attribute16 IS NULL)))
        AND ((tlinfo.attribute17 = x_attribute17) OR ((tlinfo.attribute17 IS NULL) AND (X_attribute17 IS NULL)))
        AND ((tlinfo.attribute18 = x_attribute18) OR ((tlinfo.attribute18 IS NULL) AND (X_attribute18 IS NULL)))
        AND ((tlinfo.attribute19 = x_attribute19) OR ((tlinfo.attribute19 IS NULL) AND (X_attribute19 IS NULL)))
        AND ((tlinfo.attribute20 = x_attribute20) OR ((tlinfo.attribute20 IS NULL) AND (X_attribute20 IS NULL)))
        AND ((tlinfo.spa_complete_ind = x_spa_complete_ind) OR ((tlinfo.spa_complete_ind IS NULL) AND (X_spa_complete_ind IS NULL)))
        AND ((tlinfo.susa_complete_ind = x_susa_complete_ind) OR ((tlinfo.susa_complete_ind IS NULL) AND (X_susa_complete_ind IS NULL)))
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
    x_request_type_id                   IN     NUMBER,
    x_request_name                      IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_request_mode                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_purgable_ind                      IN     VARCHAR2,
    x_request_type_comment              IN     VARCHAR2,
    x_wif_ind                           IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_wif_program_mod_ind               IN     VARCHAR2,
    x_wif_catalog_cal_type              IN     VARCHAR2,
    x_wif_catalog_ci_seq_num            IN     NUMBER,
    x_wif_catalog_mod_ind               IN     VARCHAR2,
    x_special_ind                       IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_special_program_mod_ind           IN     VARCHAR2,
    x_special_catalog                   IN     VARCHAR2,
    x_special_catalog_mod_ind           IN     VARCHAR2,
    x_enrolled_ind                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_spa_complete_ind                  IN     VARCHAR2,
    x_susa_complete_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_CNFG_REQ_TYP_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    -- x_request_type_id := NULL;  -- Commented by Deep. Need to be verified

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_request_type_id                   => x_request_type_id,
      x_request_name                      => x_request_name,
      x_request_type                      => x_request_type,
      x_request_mode                      => x_request_mode,
      x_closed_ind                        => x_closed_ind,
      x_purgable_ind                      => x_purgable_ind,
      x_request_type_comment              => x_request_type_comment,
      x_wif_ind                           => x_wif_ind,
      x_wif_program_code                  => x_wif_program_code,
      x_wif_program_mod_ind               => x_wif_program_mod_ind,
      x_wif_catalog_cal_type              => x_wif_catalog_cal_type,
      x_wif_catalog_ci_seq_num            => x_wif_catalog_ci_seq_num,
      x_wif_catalog_mod_ind               => x_wif_catalog_mod_ind,
      x_special_ind                       => x_special_ind,
      x_special_program_code              => x_special_program_code,
      x_special_program_mod_ind           => x_special_program_mod_ind,
      x_special_catalog                   => x_special_catalog,
      x_special_catalog_mod_ind           => x_special_catalog_mod_ind,
      x_enrolled_ind                      => x_enrolled_ind,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_spa_complete_ind                  => x_spa_complete_ind,
      x_susa_complete_ind                 => x_susa_complete_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_da_cnfg_req_typ
      SET
        request_name                      = new_references.request_name,
        request_type                      = new_references.request_type,
        request_mode                      = new_references.request_mode,
        closed_ind                        = new_references.closed_ind,
        purgable_ind                      = new_references.purgable_ind,
        request_type_comment              = new_references.request_type_comment,
        wif_ind                           = new_references.wif_ind,
        wif_program_code                  = new_references.wif_program_code,
        wif_program_mod_ind               = new_references.wif_program_mod_ind,
        wif_catalog_cal_type              = new_references.wif_catalog_cal_type,
        wif_catalog_ci_seq_num            = new_references.wif_catalog_ci_seq_num,
        wif_catalog_mod_ind               = new_references.wif_catalog_mod_ind,
        special_ind                       = new_references.special_ind,
        special_program_code              = new_references.special_program_code,
        special_program_mod_ind           = new_references.special_program_mod_ind,
        special_catalog                   = new_references.special_catalog,
        special_catalog_mod_ind           = new_references.special_catalog_mod_ind,
        enrolled_ind                      = new_references.enrolled_ind,
        attribute_category                = new_references.attribute_category,
        attribute1                        = new_references.attribute1,
        attribute2                        = new_references.attribute2,
        attribute3                        = new_references.attribute3,
        attribute4                        = new_references.attribute4,
        attribute5                        = new_references.attribute5,
        attribute6                        = new_references.attribute6,
        attribute7                        = new_references.attribute7,
        attribute8                        = new_references.attribute8,
        attribute9                        = new_references.attribute9,
        attribute10                       = new_references.attribute10,
        attribute11                       = new_references.attribute11,
        attribute12                       = new_references.attribute12,
        attribute13                       = new_references.attribute13,
        attribute14                       = new_references.attribute14,
        attribute15                       = new_references.attribute15,
        attribute16                       = new_references.attribute16,
        attribute17                       = new_references.attribute17,
        attribute18                       = new_references.attribute18,
        attribute19                       = new_references.attribute19,
        attribute20                       = new_references.attribute20,
        spa_complete_ind                  = new_references.spa_complete_ind,
        susa_complete_ind                 = new_references.susa_complete_ind,
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
    x_request_type_id                   IN OUT NOCOPY NUMBER,
    x_request_name                      IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_request_mode                      IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_purgable_ind                      IN     VARCHAR2,
    x_request_type_comment              IN     VARCHAR2,
    x_wif_ind                           IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_wif_program_mod_ind               IN     VARCHAR2,
    x_wif_catalog_cal_type              IN     VARCHAR2,
    x_wif_catalog_ci_seq_num            IN     NUMBER,
    x_wif_catalog_mod_ind               IN     VARCHAR2,
    x_special_ind                       IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_special_program_mod_ind           IN     VARCHAR2,
    x_special_catalog                   IN     VARCHAR2,
    x_special_catalog_mod_ind           IN     VARCHAR2,
    x_enrolled_ind                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_spa_complete_ind                  IN     VARCHAR2,
    x_susa_complete_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_da_cnfg_req_typ
      WHERE    request_type_id                   = x_request_type_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_request_type_id,
        x_request_name,
        x_request_type,
        x_request_mode,
        x_closed_ind,
        x_purgable_ind,
        x_request_type_comment,
        x_wif_ind,
        x_wif_program_code,
        x_wif_program_mod_ind,
        x_wif_catalog_cal_type,
        x_wif_catalog_ci_seq_num,
        x_wif_catalog_mod_ind,
        x_special_ind,
        x_special_program_code,
        x_special_program_mod_ind,
        x_special_catalog,
        x_special_catalog_mod_ind,
        x_enrolled_ind,
        x_attribute_category,
        x_attribute1,
        x_attribute2,
        x_attribute3,
        x_attribute4,
        x_attribute5,
        x_attribute6,
        x_attribute7,
        x_attribute8,
        x_attribute9,
        x_attribute10,
        x_attribute11,
        x_attribute12,
        x_attribute13,
        x_attribute14,
        x_attribute15,
        x_attribute16,
        x_attribute17,
        x_attribute18,
        x_attribute19,
        x_attribute20,
        x_spa_complete_ind,
        x_susa_complete_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_request_type_id,
      x_request_name,
      x_request_type,
      x_request_mode,
      x_closed_ind,
      x_purgable_ind,
      x_request_type_comment,
      x_wif_ind,
      x_wif_program_code,
      x_wif_program_mod_ind,
      x_wif_catalog_cal_type,
      x_wif_catalog_ci_seq_num,
      x_wif_catalog_mod_ind,
      x_special_ind,
      x_special_program_code,
      x_special_program_mod_ind,
      x_special_catalog,
      x_special_catalog_mod_ind,
      x_enrolled_ind,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_spa_complete_ind,
      x_susa_complete_ind,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR cur_parent_table IS
   SELECT
     request_type_id
     FROM igs_da_cnfg_req_typ_v
     WHERE row_id = x_rowid;

  CURSOR cur_igs_da_cnfg_ftr (cp_request_type_id igs_da_cnfg_ftr.request_type_id%TYPE) IS
   SELECT
     rowid
     FROM igs_da_cnfg_ftr
     WHERE request_type_id = cp_request_type_id;


  CURSOR cur_igs_da_cnfg_stat (cp_request_type_id igs_da_cnfg_ftr.request_type_id%TYPE) IS
   SELECT
     rowid
     FROM igs_da_cnfg_stat
     WHERE request_type_id = cp_request_type_id;

  CURSOR cur_igs_da_cnfg (cp_request_type_id igs_da_cnfg_ftr.request_type_id%TYPE) IS
   SELECT
     rowid
     FROM igs_da_cnfg
     WHERE request_type_id = cp_request_type_id;


  l_cur_parent_table cur_parent_table%ROWTYPE;
  l_cur_igs_da_cnfg_ftr cur_igs_da_cnfg_ftr%ROWTYPE;
  l_cur_igs_da_cnfg_stat cur_igs_da_cnfg_stat%ROWTYPE;
  l_cur_igs_da_cnfg cur_igs_da_cnfg%ROWTYPE;


  BEGIN

 -- The Functionality in the form requires a CASCADE DELETE , hence the child would be deleted once the parent
 -- record is deleted.

/*    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );
 */

   OPEN cur_parent_table;
   FETCH cur_parent_table INTO l_cur_parent_table;
   CLOSE cur_parent_table;


   FOR l_cur_igs_da_cnfg_ftr IN cur_igs_da_cnfg_ftr(l_cur_parent_table.request_type_id) LOOP


    igs_da_cnfg_ftr_pkg.delete_row (
          x_rowid  => l_cur_igs_da_cnfg_ftr.rowid
                                   );
   END LOOP;



    FOR l_cur_igs_da_cnfg_stat IN  cur_igs_da_cnfg_stat(l_cur_parent_table.request_type_id) LOOP

       igs_da_cnfg_stat_pkg.delete_row (
          x_rowid  => l_cur_igs_da_cnfg_stat.rowid
                                    );
    END LOOP;


   FOR  l_cur_igs_da_cnfg IN cur_igs_da_cnfg(l_cur_parent_table.request_type_id) LOOP


    igs_da_cnfg_pkg.delete_row (
          x_rowid  => l_cur_igs_da_cnfg.rowid
    );

   END LOOP;


    DELETE FROM igs_da_cnfg_req_typ
    WHERE rowid = x_rowid;


    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;



 END delete_row;


END igs_da_cnfg_req_typ_pkg;

/
