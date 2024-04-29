--------------------------------------------------------
--  DDL for Package Body IGS_AZ_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AZ_GROUPS_PKG" AS
/* $Header: IGSHI01B.pls 115.6 2003/10/30 13:29:08 rghosh noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_az_groups%ROWTYPE;
  new_references igs_az_groups%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_group_name                        IN     VARCHAR2,
    x_group_desc                        IN     VARCHAR2,
    x_advising_code                     IN     VARCHAR2,
    x_resp_org_unit_cd                  IN     VARCHAR2,
    x_resp_person_id                    IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_delivery_method_code              IN     VARCHAR2,
    x_advisor_group_id                  IN     NUMBER,
    x_student_group_id                  IN     NUMBER,
    x_default_advisor_load_num          IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_advising_sessions_num             IN     NUMBER,
    x_advising_hold_type                IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_comments_txt                      IN     VARCHAR2,
    x_auto_refresh_flag                 IN     VARCHAR2,
    x_last_auto_refresh_date            IN     DATE,
    x_auto_stdnt_add_flag               IN     VARCHAR2,
    x_auto_stdnt_remove_flag            IN     VARCHAR2,
    x_auto_advisor_add_flag             IN     VARCHAR2,
    x_auto_advisor_remove_flag          IN     VARCHAR2,
    x_auto_match_flag                   IN     VARCHAR2,
    x_auto_apply_hold_flag              IN     VARCHAR2,
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
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_az_groups
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
    new_references.group_name                        := x_group_name;
    new_references.group_desc                        := x_group_desc;
    new_references.advising_code                     := x_advising_code;
    new_references.resp_org_unit_cd                  := x_resp_org_unit_cd;
    new_references.resp_person_id                    := x_resp_person_id;
    new_references.location_cd                       := x_location_cd;
    new_references.delivery_method_code              := x_delivery_method_code;
    new_references.advisor_group_id                  := x_advisor_group_id;
    new_references.student_group_id                  := x_student_group_id;
    new_references.default_advisor_load_num          := x_default_advisor_load_num;
    new_references.mandatory_flag                    := x_mandatory_flag;
    new_references.advising_sessions_num             := x_advising_sessions_num;
    new_references.advising_hold_type                := x_advising_hold_type;
    new_references.closed_flag                       := x_closed_flag;
    new_references.comments_txt                      := x_comments_txt;
    new_references.auto_refresh_flag                 := x_auto_refresh_flag;
    new_references.last_auto_refresh_date            := TRUNC(x_last_auto_refresh_date);
    new_references.auto_stdnt_add_flag               := x_auto_stdnt_add_flag;
    new_references.auto_stdnt_remove_flag            := x_auto_stdnt_remove_flag;
    new_references.auto_advisor_add_flag             := x_auto_advisor_add_flag;
    new_references.auto_advisor_remove_flag          := x_auto_advisor_remove_flag;
    new_references.auto_match_flag                   := x_auto_match_flag;
    new_references.auto_apply_hold_flag              := x_auto_apply_hold_flag;
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
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_location_pkg.get_pk_for_validation (
                new_references.location_cd,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.advisor_group_id = new_references.advisor_group_id)) OR
        ((new_references.advisor_group_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_persid_group_pkg.get_pk_for_validation (
                new_references.advisor_group_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.student_group_id = new_references.student_group_id)) OR
        ((new_references.student_group_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_persid_group_pkg.get_pk_for_validation (
                new_references.student_group_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.advising_hold_type = new_references.advising_hold_type)) OR
        ((new_references.advising_hold_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_encmb_type_pkg.get_pk_for_validation (
                new_references.advising_hold_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IGS_AZ_ADVISING_RELS_pkg.get_fk_igs_az_groups (
      old_references.group_name
    );

    IGS_AZ_ADVISORS_pkg.get_fk_igs_az_groups (
      old_references.group_name
    );

    IGS_AZ_STUDENTS_pkg.get_fk_igs_az_groups (
      old_references.group_name
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_group_name                        IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_az_groups
      WHERE    group_name = x_group_name;

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


  PROCEDURE get_fk_igs_ad_location (
    x_location_cd                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_az_groups
      WHERE   ((location_cd = x_location_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AZ_GROUPS_LOC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_location;


  PROCEDURE get_fk_igs_pe_persid_group (
    x_group_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_az_groups
      WHERE   ((advisor_group_id = x_group_id))
      OR      ((student_group_id = x_group_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AZ_GROUPS_PERS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_persid_group;


  PROCEDURE get_fk_igs_fi_encmb_type (
    x_encumbrance_type                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_az_groups
      WHERE   ((advising_hold_type = x_encumbrance_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AZ_GROUPS_ENCMB_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_encmb_type;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_group_name                        IN     VARCHAR2,
    x_group_desc                        IN     VARCHAR2,
    x_advising_code                     IN     VARCHAR2,
    x_resp_org_unit_cd                  IN     VARCHAR2,
    x_resp_person_id                    IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_delivery_method_code              IN     VARCHAR2,
    x_advisor_group_id                  IN     NUMBER,
    x_student_group_id                  IN     NUMBER,
    x_default_advisor_load_num          IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_advising_sessions_num             IN     NUMBER,
    x_advising_hold_type                IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_comments_txt                      IN     VARCHAR2,
    x_auto_refresh_flag                 IN     VARCHAR2,
    x_last_auto_refresh_date            IN     DATE,
    x_auto_stdnt_add_flag               IN     VARCHAR2,
    x_auto_stdnt_remove_flag            IN     VARCHAR2,
    x_auto_advisor_add_flag             IN     VARCHAR2,
    x_auto_advisor_remove_flag          IN     VARCHAR2,
    x_auto_match_flag                   IN     VARCHAR2,
    x_auto_apply_hold_flag              IN     VARCHAR2,
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
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
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
      x_group_name,
      x_group_desc,
      x_advising_code,
      x_resp_org_unit_cd,
      x_resp_person_id,
      x_location_cd,
      x_delivery_method_code,
      x_advisor_group_id,
      x_student_group_id,
      x_default_advisor_load_num,
      x_mandatory_flag,
      x_advising_sessions_num,
      x_advising_hold_type,
      x_closed_flag,
      x_comments_txt,
      x_auto_refresh_flag,
      x_last_auto_refresh_date,
      x_auto_stdnt_add_flag,
      x_auto_stdnt_remove_flag,
      x_auto_advisor_add_flag,
      x_auto_advisor_remove_flag,
      x_auto_match_flag,
      x_auto_apply_hold_flag,
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
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.group_name
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.group_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_name                        IN OUT NOCOPY VARCHAR2,
    x_group_desc                        IN     VARCHAR2,
    x_advising_code                     IN     VARCHAR2,
    x_resp_org_unit_cd                  IN     VARCHAR2,
    x_resp_person_id                    IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_delivery_method_code              IN     VARCHAR2,
    x_advisor_group_id                  IN     NUMBER,
    x_student_group_id                  IN     NUMBER,
    x_default_advisor_load_num          IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_advising_sessions_num             IN     NUMBER,
    x_advising_hold_type                IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_comments_txt                      IN     VARCHAR2,
    x_auto_refresh_flag                 IN     VARCHAR2,
    x_last_auto_refresh_date            IN     DATE,
    x_auto_stdnt_add_flag               IN     VARCHAR2,
    x_auto_stdnt_remove_flag            IN     VARCHAR2,
    x_auto_advisor_add_flag             IN     VARCHAR2,
    x_auto_advisor_remove_flag          IN     VARCHAR2,
    x_auto_match_flag                   IN     VARCHAR2,
    x_auto_apply_hold_flag              IN     VARCHAR2,
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
    x_mode                              IN     VARCHAR2,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
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
    FND_MSG_PUB.initialize;
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
      fnd_message.set_token ('ROUTINE', 'IGS_AZ_GROUPS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_group_name                        => x_group_name,
      x_group_desc                        => x_group_desc,
      x_advising_code                     => x_advising_code,
      x_resp_org_unit_cd                  => x_resp_org_unit_cd,
      x_resp_person_id                    => x_resp_person_id,
      x_location_cd                       => x_location_cd,
      x_delivery_method_code              => x_delivery_method_code,
      x_advisor_group_id                  => x_advisor_group_id,
      x_student_group_id                  => x_student_group_id,
      x_default_advisor_load_num          => x_default_advisor_load_num,
      x_mandatory_flag                    => x_mandatory_flag,
      x_advising_sessions_num             => x_advising_sessions_num,
      x_advising_hold_type                => x_advising_hold_type,
      x_closed_flag                       => x_closed_flag,
      x_comments_txt                      => x_comments_txt,
      x_auto_refresh_flag                 => x_auto_refresh_flag,
      x_last_auto_refresh_date            => x_last_auto_refresh_date,
      x_auto_stdnt_add_flag               => x_auto_stdnt_add_flag,
      x_auto_stdnt_remove_flag            => x_auto_stdnt_remove_flag,
      x_auto_advisor_add_flag             => x_auto_advisor_add_flag,
      x_auto_advisor_remove_flag          => x_auto_advisor_remove_flag,
      x_auto_match_flag                   => x_auto_match_flag,
      x_auto_apply_hold_flag              => x_auto_apply_hold_flag,
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
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_az_groups (
      group_name,
      group_desc,
      advising_code,
      resp_org_unit_cd,
      resp_person_id,
      location_cd,
      delivery_method_code,
      advisor_group_id,
      student_group_id,
      default_advisor_load_num,
      mandatory_flag,
      advising_sessions_num,
      advising_hold_type,
      closed_flag,
      comments_txt,
      auto_refresh_flag,
      last_auto_refresh_date,
      auto_stdnt_add_flag,
      auto_stdnt_remove_flag,
      auto_advisor_add_flag,
      auto_advisor_remove_flag,
      auto_match_flag,
      auto_apply_hold_flag,
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
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      UPPER(new_references.group_name),
      new_references.group_desc,
      new_references.advising_code,
      new_references.resp_org_unit_cd,
      new_references.resp_person_id,
      new_references.location_cd,
      new_references.delivery_method_code,
      new_references.advisor_group_id,
      new_references.student_group_id,
      new_references.default_advisor_load_num,
      new_references.mandatory_flag,
      new_references.advising_sessions_num,
      new_references.advising_hold_type,
      new_references.closed_flag,
      new_references.comments_txt,
      new_references.auto_refresh_flag,
      new_references.last_auto_refresh_date,
      new_references.auto_stdnt_add_flag,
      new_references.auto_stdnt_remove_flag,
      new_references.auto_advisor_add_flag,
      new_references.auto_advisor_remove_flag,
      new_references.auto_match_flag,
      new_references.auto_apply_hold_flag,
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
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, group_name INTO x_rowid, x_group_name;
  -- Initialize API return status to success.
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message
  -- info.
     FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(
                     p_encoded => FND_API.G_FALSE,
                     p_count => x_MSG_COUNT,
                     p_data  => X_MSG_DATA);
     RETURN;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                    FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_MSG_COUNT,
                        p_data  => X_MSG_DATA);
     RETURN;
        WHEN OTHERS THEN
             X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
             FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
             FND_MSG_PUB.ADD;
             FND_MSG_PUB.Count_And_Get(
                               p_encoded => FND_API.G_FALSE,
                               p_count => x_MSG_COUNT,
                               p_data  => X_MSG_DATA);
     RETURN;

  END insert_row;


  Procedure lock_row (
    x_rowid                             IN     VARCHAR2,
    x_group_name                        IN     VARCHAR2,
    x_group_desc                        IN     VARCHAR2,
    x_advising_code                     IN     VARCHAR2,
    x_resp_org_unit_cd                  IN     VARCHAR2,
    x_resp_person_id                    IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_delivery_method_code              IN     VARCHAR2,
    x_advisor_group_id                  IN     NUMBER,
    x_student_group_id                  IN     NUMBER,
    x_default_advisor_load_num          IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_advising_sessions_num             IN     NUMBER,
    x_advising_hold_type                IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_comments_txt                      IN     VARCHAR2,
    x_auto_refresh_flag                 IN     VARCHAR2,
    x_last_auto_refresh_date            IN     DATE,
    x_auto_stdnt_add_flag               IN     VARCHAR2,
    x_auto_stdnt_remove_flag            IN     VARCHAR2,
    x_auto_advisor_add_flag             IN     VARCHAR2,
    x_auto_advisor_remove_flag          IN     VARCHAR2,
    x_auto_match_flag                   IN     VARCHAR2,
    x_auto_apply_hold_flag              IN     VARCHAR2,
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
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        group_desc,
        advising_code,
        resp_org_unit_cd,
        resp_person_id,
        location_cd,
        delivery_method_code,
        advisor_group_id,
        student_group_id,
        default_advisor_load_num,
        mandatory_flag,
        advising_sessions_num,
        advising_hold_type,
        closed_flag,
        comments_txt,
        auto_refresh_flag,
        last_auto_refresh_date,
        auto_stdnt_add_flag,
        auto_stdnt_remove_flag,
        auto_advisor_add_flag,
        auto_advisor_remove_flag,
        auto_match_flag,
        auto_apply_hold_flag,
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
        attribute20
      FROM  igs_az_groups
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN
    FND_MSG_PUB.initialize;
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
        (tlinfo.group_desc = x_group_desc)
        AND (tlinfo.advising_code = x_advising_code OR ((tlinfo.advising_code IS NULL) AND (x_advising_code IS NULL)))
        AND (tlinfo.resp_org_unit_cd = x_resp_org_unit_cd)
        AND ((tlinfo.resp_person_id = x_resp_person_id) OR ((tlinfo.resp_person_id IS NULL) AND (X_resp_person_id IS NULL)))
        AND ((tlinfo.location_cd = x_location_cd) OR ((tlinfo.location_cd IS NULL) AND (X_location_cd IS NULL)))
        AND (tlinfo.delivery_method_code = x_delivery_method_code)
        AND ((tlinfo.advisor_group_id = x_advisor_group_id) OR ((tlinfo.advisor_group_id IS NULL) AND (X_advisor_group_id IS NULL)))
        AND ((tlinfo.student_group_id = x_student_group_id) OR ((tlinfo.student_group_id IS NULL) AND (X_student_group_id IS NULL)))
        AND ((tlinfo.default_advisor_load_num = x_default_advisor_load_num) OR ((tlinfo.default_advisor_load_num IS NULL) AND (x_default_advisor_load_num IS NULL)))
        AND (tlinfo.mandatory_flag = x_mandatory_flag)
        AND ((tlinfo.advising_sessions_num = x_advising_sessions_num) OR ((tlinfo.advising_sessions_num IS NULL) AND (x_advising_sessions_num IS NULL)))
        AND ((tlinfo.advising_hold_type = x_advising_hold_type) OR ((tlinfo.advising_hold_type IS NULL) AND (X_advising_hold_type IS NULL)))
        AND (tlinfo.closed_flag = x_closed_flag)
        AND ((tlinfo.comments_txt = x_comments_txt) OR ((tlinfo.comments_txt IS NULL) AND (x_comments_txt IS NULL)))
        AND (tlinfo.auto_refresh_flag = x_auto_refresh_flag)
        AND ((trunc(tlinfo.last_auto_refresh_date) = trunc(x_last_auto_refresh_date)) OR ((tlinfo.last_auto_refresh_date IS NULL) AND (x_last_auto_refresh_date IS NULL)))
        AND (tlinfo.auto_stdnt_add_flag = x_auto_stdnt_add_flag)
        AND (tlinfo.auto_stdnt_remove_flag = x_auto_stdnt_remove_flag)
        AND (tlinfo.auto_advisor_add_flag = x_auto_advisor_add_flag)
        AND (tlinfo.auto_advisor_remove_flag = x_auto_advisor_remove_flag)
        AND (tlinfo.auto_match_flag = x_auto_match_flag)
        AND (tlinfo.auto_apply_hold_flag = x_auto_apply_hold_flag)
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
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  -- Initialize API return status to success.
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message
  -- info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);
     RETURN;
 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                 p_encoded => FND_API.G_FALSE,
                 p_count => x_MSG_COUNT,
                 p_data  => X_MSG_DATA);
 RETURN;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_MSG_COUNT,
                    p_data  => X_MSG_DATA);
 RETURN;
  WHEN OTHERS THEN
         X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
         FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(
                           p_encoded => FND_API.G_FALSE,
                           p_count => x_MSG_COUNT,
                           p_data  => X_MSG_DATA);
 RETURN;


  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_group_name                        IN     VARCHAR2,
    x_group_desc                        IN     VARCHAR2,
    x_advising_code                     IN     VARCHAR2,
    x_resp_org_unit_cd                  IN     VARCHAR2,
    x_resp_person_id                    IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_delivery_method_code              IN     VARCHAR2,
    x_advisor_group_id                  IN     NUMBER,
    x_student_group_id                  IN     NUMBER,
    x_default_advisor_load_num          IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_advising_sessions_num             IN     NUMBER,
    x_advising_hold_type                IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_comments_txt                      IN     VARCHAR2,
    x_auto_refresh_flag                 IN     VARCHAR2,
    x_last_auto_refresh_date            IN     DATE,
    x_auto_stdnt_add_flag               IN     VARCHAR2,
    x_auto_stdnt_remove_flag            IN     VARCHAR2,
    x_auto_advisor_add_flag             IN     VARCHAR2,
    x_auto_advisor_remove_flag          IN     VARCHAR2,
    x_auto_match_flag                   IN     VARCHAR2,
    x_auto_apply_hold_flag              IN     VARCHAR2,
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
    x_mode                              IN     VARCHAR2,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
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
    FND_MSG_PUB.initialize;
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
      fnd_message.set_token ('ROUTINE', 'IGS_AZ_GROUPS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_group_name                        => x_group_name,
      x_group_desc                        => x_group_desc,
      x_advising_code                     => x_advising_code,
      x_resp_org_unit_cd                  => x_resp_org_unit_cd,
      x_resp_person_id                    => x_resp_person_id,
      x_location_cd                       => x_location_cd,
      x_delivery_method_code              => x_delivery_method_code,
      x_advisor_group_id                  => x_advisor_group_id,
      x_student_group_id                  => x_student_group_id,
      x_default_advisor_load_num          => x_default_advisor_load_num,
      x_mandatory_flag                    => x_mandatory_flag,
      x_advising_sessions_num             => x_advising_sessions_num,
      x_advising_hold_type                => x_advising_hold_type,
      x_closed_flag                       => x_closed_flag,
      x_comments_txt                      => x_comments_txt,
      x_auto_refresh_flag                 => x_auto_refresh_flag,
      x_last_auto_refresh_date            => x_last_auto_refresh_date,
      x_auto_stdnt_add_flag               => x_auto_stdnt_add_flag,
      x_auto_stdnt_remove_flag            => x_auto_stdnt_remove_flag,
      x_auto_advisor_add_flag             => x_auto_advisor_add_flag,
      x_auto_advisor_remove_flag          => x_auto_advisor_remove_flag,
      x_auto_match_flag                   => x_auto_match_flag,
      x_auto_apply_hold_flag              => x_auto_apply_hold_flag,
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
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_az_groups
      SET
        group_desc                        = new_references.group_desc,
        advising_code                     = new_references.advising_code,
        resp_org_unit_cd                  = new_references.resp_org_unit_cd,
        resp_person_id                    = new_references.resp_person_id,
        location_cd                       = new_references.location_cd,
        delivery_method_code              = new_references.delivery_method_code,
        advisor_group_id                  = new_references.advisor_group_id,
        student_group_id                  = new_references.student_group_id,
        default_advisor_load_num          = new_references.default_advisor_load_num,
        mandatory_flag                    = new_references.mandatory_flag,
        advising_sessions_num             = new_references.advising_sessions_num,
        advising_hold_type                = new_references.advising_hold_type,
        closed_flag                       = new_references.closed_flag,
        comments_txt                      = new_references.comments_txt,
        auto_refresh_flag                 = new_references.auto_refresh_flag,
        last_auto_refresh_date            = new_references.last_auto_refresh_date,
        auto_stdnt_add_flag               = new_references.auto_stdnt_add_flag,
        auto_stdnt_remove_flag            = new_references.auto_stdnt_remove_flag,
        auto_advisor_add_flag             = new_references.auto_advisor_add_flag,
        auto_advisor_remove_flag          = new_references.auto_advisor_remove_flag,
        auto_match_flag                   = new_references.auto_match_flag,
        auto_apply_hold_flag              = new_references.auto_apply_hold_flag,
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
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  -- Initialize API return status to success.
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message
  -- info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_MSG_COUNT,
                p_data  => X_MSG_DATA);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_MSG_COUNT,
                   p_data  => X_MSG_DATA);
   RETURN;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                  FND_MSG_PUB.Count_And_Get(
                      p_encoded => FND_API.G_FALSE,
                      p_count => x_MSG_COUNT,
                      p_data  => X_MSG_DATA);
   RETURN;
    WHEN OTHERS THEN
           X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
           FND_MESSAGE.SET_TOKEN('NAME','Update_Row : '||SQLERRM);
           FND_MSG_PUB.ADD;
           FND_MSG_PUB.Count_And_Get(
                             p_encoded => FND_API.G_FALSE,
                             p_count => x_MSG_COUNT,
                             p_data  => X_MSG_DATA);
   RETURN;
  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_name                        IN OUT NOCOPY VARCHAR2,
    x_group_desc                        IN     VARCHAR2,
    x_advising_code                     IN     VARCHAR2,
    x_resp_org_unit_cd                  IN     VARCHAR2,
    x_resp_person_id                    IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_delivery_method_code              IN     VARCHAR2,
    x_advisor_group_id                  IN     NUMBER,
    x_student_group_id                  IN     NUMBER,
    x_default_advisor_load_num          IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_advising_sessions_num             IN     NUMBER,
    x_advising_hold_type                IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_comments_txt                      IN     VARCHAR2,
    x_auto_refresh_flag                 IN     VARCHAR2,
    x_last_auto_refresh_date            IN     DATE,
    x_auto_stdnt_add_flag               IN     VARCHAR2,
    x_auto_stdnt_remove_flag            IN     VARCHAR2,
    x_auto_advisor_add_flag             IN     VARCHAR2,
    x_auto_advisor_remove_flag          IN     VARCHAR2,
    x_auto_match_flag                   IN     VARCHAR2,
    x_auto_apply_hold_flag              IN     VARCHAR2,
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
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_az_groups
      WHERE    group_name                        = x_group_name;
    l_return_status                VARCHAR2(10);
    l_msg_data                     VARCHAR2(2000);
    l_msg_count                    NUMBER(10);
  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_group_name,
        x_group_desc,
        x_advising_code,
        x_resp_org_unit_cd,
        x_resp_person_id,
        x_location_cd,
        x_delivery_method_code,
        x_advisor_group_id,
        x_student_group_id,
        x_default_advisor_load_num,
        x_mandatory_flag,
        x_advising_sessions_num,
        x_advising_hold_type,
        x_closed_flag,
        x_comments_txt,
        x_auto_refresh_flag,
        x_last_auto_refresh_date,
        x_auto_stdnt_add_flag,
        x_auto_stdnt_remove_flag,
        x_auto_advisor_add_flag,
        x_auto_advisor_remove_flag,
        x_auto_match_flag,
        x_auto_apply_hold_flag,
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
        x_mode,
        l_return_status,
        l_msg_data,
        l_msg_count
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_group_name,
      x_group_desc,
      x_advising_code,
      x_resp_org_unit_cd,
      x_resp_person_id,
      x_location_cd,
      x_delivery_method_code,
      x_advisor_group_id,
      x_student_group_id,
      x_default_advisor_load_num,
      x_mandatory_flag,
      x_advising_sessions_num,
      x_advising_hold_type,
      x_closed_flag,
      x_comments_txt,
      x_auto_refresh_flag,
      x_last_auto_refresh_date,
      x_auto_stdnt_add_flag,
      x_auto_stdnt_remove_flag,
      x_auto_advisor_add_flag,
      x_auto_advisor_remove_flag,
      x_auto_match_flag,
      x_auto_apply_hold_flag,
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
      x_mode,
      l_return_status,
      l_msg_data,
      l_msg_count
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid                             IN  VARCHAR2,
    x_return_status                     OUT NOCOPY    VARCHAR2,
    x_msg_data                          OUT NOCOPY    VARCHAR2,
    x_msg_count                         OUT NOCOPY    NUMBER
  ) AS
  /*
  ||  Created By : gjha@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    FND_MSG_PUB.initialize;
    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igs_az_groups
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    -- Initialize API return status to success.
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to get message count and if count is 1, get message
    -- info.
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_MSG_COUNT,
      p_data  => X_MSG_DATA
    );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(
                   p_encoded => FND_API.G_FALSE,
                   p_count => x_MSG_COUNT,
                   p_data  => X_MSG_DATA);
   RETURN;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                  X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                  FND_MSG_PUB.Count_And_Get(
                      p_encoded => FND_API.G_FALSE,
                      p_count => x_MSG_COUNT,
                      p_data  => X_MSG_DATA);
   RETURN;
    WHEN OTHERS THEN
           X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
           FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
           FND_MSG_PUB.ADD;
           FND_MSG_PUB.Count_And_Get(
                             p_encoded => FND_API.G_FALSE,
                             p_count => x_MSG_COUNT,
                             p_data  => X_MSG_DATA);
   RETURN;
  END delete_row;


END igs_az_groups_pkg;

/
