--------------------------------------------------------
--  DDL for Package Body IGS_DA_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_DA_SETUP_PKG" AS
/* $Header: IGSKI40B.pls 120.1 2005/09/28 02:23:01 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_da_setup%ROWTYPE;
  new_references igs_da_setup%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_s_control_num                     IN     NUMBER,
    x_program_definition_ind            IN     VARCHAR2,
    x_default_student_id_type           IN     VARCHAR2,
    x_default_inst_id_type                   IN     VARCHAR2,
    x_default_address_type              IN     VARCHAR2,
    x_wif_major_unit_set_cat            IN     VARCHAR2,
    x_wif_minor_unit_set_cat            IN     VARCHAR2,
    x_wif_track_unit_set_cat            IN     VARCHAR2,
    x_wif_unit_set_title                IN     VARCHAR2,
    x_third_party_options               IN     VARCHAR2,
--    x_advisor_relationship_ind          IN     VARCHAR2,
    x_display_container_ind             IN     VARCHAR2,
    x_container_title                   IN     VARCHAR2,
    x_link_text                         IN     VARCHAR2,
    x_link_url                          IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 19-MAR-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_da_setup
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
    new_references.s_control_num                     := x_s_control_num;
    new_references.program_definition_ind            := x_program_definition_ind;
    new_references.default_student_id_type           := x_default_student_id_type;
    new_references.default_inst_id_type                   := x_default_inst_id_type;
    new_references.default_address_type              := x_default_address_type;
    new_references.wif_major_unit_set_cat            := x_wif_major_unit_set_cat;
    new_references.wif_minor_unit_set_cat            := x_wif_minor_unit_set_cat;
    new_references.wif_track_unit_set_cat            := x_wif_track_unit_set_cat;
    new_references.wif_unit_set_title                := x_wif_unit_set_title;
    new_references.third_party_options               := x_third_party_options;
--    new_references.advisor_relationship_ind          := x_advisor_relationship_ind;
    new_references.display_container_ind             := x_display_container_ind;
    new_references.container_title                   := x_container_title;
    new_references.link_text                         := x_link_text;
    new_references.link_url                          := x_link_url;

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
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 19-MAR-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.default_student_id_type = new_references.default_student_id_type)) OR
        ((new_references.default_student_id_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_id_typ_pkg.get_pk_for_validation (
                new_references.default_student_id_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.wif_major_unit_set_cat = new_references.wif_major_unit_set_cat)) OR
        ((new_references.wif_major_unit_set_cat IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_unit_set_cat_pkg.get_pk_for_validation (
                new_references.wif_major_unit_set_cat
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.wif_minor_unit_set_cat = new_references.wif_minor_unit_set_cat)) OR
        ((new_references.wif_minor_unit_set_cat IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_unit_set_cat_pkg.get_pk_for_validation (
                new_references.wif_minor_unit_set_cat
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.wif_track_unit_set_cat = new_references.wif_track_unit_set_cat)) OR
        ((new_references.wif_track_unit_set_cat IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_unit_set_cat_pkg.get_pk_for_validation (
                new_references.wif_track_unit_set_cat
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.default_inst_id_type = new_references.default_inst_id_type)) OR
        ((new_references.default_inst_id_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_or_org_alt_idtyp_pkg.get_pk_for_validation (
                new_references.default_inst_id_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_s_control_num                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 19-MAR-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_setup
      WHERE    s_control_num = x_s_control_num
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

  PROCEDURE get_fk_igs_en_unit_set_cat (
    x_unit_set_cat                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 19-MAR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_setup
      WHERE   ((wif_major_unit_set_cat = x_unit_set_cat))
      OR      ((wif_minor_unit_set_cat = x_unit_set_cat))
      OR      ((wif_track_unit_set_cat = x_unit_set_cat));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_DA_SET_EUS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_unit_set_cat;


  PROCEDURE get_fk_igs_or_org_alt_idtyp (
    x_org_alternate_id_type             IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 19-MAR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_setup
      WHERE   ((default_inst_id_type = x_org_alternate_id_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_DA_SET_OAIT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_or_org_alt_idtyp;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_s_control_num                     IN     NUMBER,
    x_program_definition_ind            IN     VARCHAR2,
    x_default_student_id_type           IN     VARCHAR2,
    x_default_inst_id_type                   IN     VARCHAR2,
    x_default_address_type              IN     VARCHAR2,
    x_wif_major_unit_set_cat            IN     VARCHAR2,
    x_wif_minor_unit_set_cat            IN     VARCHAR2,
    x_wif_track_unit_set_cat            IN     VARCHAR2,
    x_wif_unit_set_title                IN     VARCHAR2,
    x_third_party_options               IN     VARCHAR2,
--    x_advisor_relationship_ind          IN     VARCHAR2,
    x_display_container_ind             IN     VARCHAR2,
    x_container_title                   IN     VARCHAR2,
    x_link_text                         IN     VARCHAR2,
    x_link_url                          IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
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
      x_s_control_num,
      x_program_definition_ind,
      x_default_student_id_type,
      x_default_inst_id_type,
      x_default_address_type,
      x_wif_major_unit_set_cat,
      x_wif_minor_unit_set_cat,
      x_wif_track_unit_set_cat,
      x_wif_unit_set_title,
      x_third_party_options,
--      x_advisor_relationship_ind,
      x_display_container_ind,
      x_container_title,
      x_link_text,
      x_link_url,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.s_control_num
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
             new_references.s_control_num
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
    x_s_control_num                     IN     NUMBER,
    x_program_definition_ind            IN     VARCHAR2,
    x_default_student_id_type           IN     VARCHAR2,
    x_default_inst_id_type                   IN     VARCHAR2,
    x_default_address_type              IN     VARCHAR2,
    x_wif_major_unit_set_cat            IN     VARCHAR2,
    x_wif_minor_unit_set_cat            IN     VARCHAR2,
    x_wif_track_unit_set_cat            IN     VARCHAR2,
    x_wif_unit_set_title                IN     VARCHAR2,
    x_third_party_options               IN     VARCHAR2,
--    x_advisor_relationship_ind          IN     VARCHAR2,
    x_display_container_ind             IN     VARCHAR2,
    x_container_title                   IN     VARCHAR2,
    x_link_text                         IN     VARCHAR2,
    x_link_url                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_SETUP_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_s_control_num                     => x_s_control_num,
      x_program_definition_ind            => x_program_definition_ind,
      x_default_student_id_type           => x_default_student_id_type,
      x_default_inst_id_type                   => x_default_inst_id_type,
      x_default_address_type              => x_default_address_type,
      x_wif_major_unit_set_cat            => x_wif_major_unit_set_cat,
      x_wif_minor_unit_set_cat            => x_wif_minor_unit_set_cat,
      x_wif_track_unit_set_cat            => x_wif_track_unit_set_cat,
      x_wif_unit_set_title                => x_wif_unit_set_title,
      x_third_party_options               => x_third_party_options,
--      x_advisor_relationship_ind          => x_advisor_relationship_ind,
      x_display_container_ind             => x_display_container_ind,
      x_container_title                   => x_container_title,
      x_link_text                         => x_link_text,
      x_link_url                          => x_link_url,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_da_setup (
      s_control_num,
      program_definition_ind,
      default_student_id_type,
      default_inst_id_type,
      default_address_type,
      wif_major_unit_set_cat,
      wif_minor_unit_set_cat,
      wif_track_unit_set_cat,
      wif_unit_set_title,
      third_party_options,
--      advisor_relationship_ind,
      display_container_ind,
      container_title,
      link_text,
      link_url,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.s_control_num,
      new_references.program_definition_ind,
      new_references.default_student_id_type,
      new_references.default_inst_id_type,
      new_references.default_address_type,
      new_references.wif_major_unit_set_cat,
      new_references.wif_minor_unit_set_cat,
      new_references.wif_track_unit_set_cat,
      new_references.wif_unit_set_title,
      new_references.third_party_options,
--      new_references.advisor_relationship_ind,
      new_references.display_container_ind,
      new_references.container_title,
      new_references.link_text,
      new_references.link_url,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_s_control_num                     IN     NUMBER,
    x_program_definition_ind            IN     VARCHAR2,
    x_default_student_id_type           IN     VARCHAR2,
    x_default_inst_id_type                   IN     VARCHAR2,
    x_default_address_type              IN     VARCHAR2,
    x_wif_major_unit_set_cat            IN     VARCHAR2,
    x_wif_minor_unit_set_cat            IN     VARCHAR2,
    x_wif_track_unit_set_cat            IN     VARCHAR2,
    x_wif_unit_set_title                IN     VARCHAR2,
    x_third_party_options               IN     VARCHAR2,
--    x_advisor_relationship_ind          IN     VARCHAR2,
    x_display_container_ind             IN     VARCHAR2,
    x_container_title                   IN     VARCHAR2,
    x_link_text                         IN     VARCHAR2,
    x_link_url                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 19-MAR-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        program_definition_ind,
        default_student_id_type,
        default_inst_id_type,
        default_address_type,
        wif_major_unit_set_cat,
        wif_minor_unit_set_cat,
        wif_track_unit_set_cat,
        wif_unit_set_title,
        third_party_options,
--        advisor_relationship_ind,
        display_container_ind,
        container_title,
        link_text,
        link_url
      FROM  igs_da_setup
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
        (tlinfo.program_definition_ind = x_program_definition_ind)
        AND ((tlinfo.default_student_id_type = x_default_student_id_type) OR ((tlinfo.default_student_id_type IS NULL) AND (X_default_student_id_type IS NULL)))
        AND ((tlinfo.default_inst_id_type = x_default_inst_id_type) OR ((tlinfo.default_inst_id_type IS NULL) AND (X_default_inst_id_type IS NULL)))
        AND (tlinfo.default_address_type = x_default_address_type)
        AND (tlinfo.wif_major_unit_set_cat = x_wif_major_unit_set_cat)
        AND (tlinfo.wif_minor_unit_set_cat = x_wif_minor_unit_set_cat)
        AND (tlinfo.wif_track_unit_set_cat = x_wif_track_unit_set_cat)
        AND (tlinfo.wif_unit_set_title = x_wif_unit_set_title)
        AND (tlinfo.third_party_options = x_third_party_options)
--        AND (tlinfo.advisor_relationship_ind = x_advisor_relationship_ind)
        AND (tlinfo.display_container_ind = x_display_container_ind)
        AND ((tlinfo.container_title = x_container_title) OR ((tlinfo.container_title IS NULL) AND (X_container_title IS NULL)))
        AND ((tlinfo.link_text = x_link_text) OR ((tlinfo.link_text IS NULL) AND (X_link_text IS NULL)))
        AND ((tlinfo.link_url = x_link_url) OR ((tlinfo.link_url IS NULL) AND (X_link_url IS NULL)))
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
    x_s_control_num                     IN     NUMBER,
    x_program_definition_ind            IN     VARCHAR2,
    x_default_student_id_type           IN     VARCHAR2,
    x_default_inst_id_type                   IN     VARCHAR2,
    x_default_address_type              IN     VARCHAR2,
    x_wif_major_unit_set_cat            IN     VARCHAR2,
    x_wif_minor_unit_set_cat            IN     VARCHAR2,
    x_wif_track_unit_set_cat            IN     VARCHAR2,
    x_wif_unit_set_title                IN     VARCHAR2,
    x_third_party_options               IN     VARCHAR2,
--    x_advisor_relationship_ind          IN     VARCHAR2,
    x_display_container_ind             IN     VARCHAR2,
    x_container_title                   IN     VARCHAR2,
    x_link_text                         IN     VARCHAR2,
    x_link_url                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_SETUP_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_s_control_num                     => x_s_control_num,
      x_program_definition_ind            => x_program_definition_ind,
      x_default_student_id_type           => x_default_student_id_type,
      x_default_inst_id_type                   => x_default_inst_id_type,
      x_default_address_type              => x_default_address_type,
      x_wif_major_unit_set_cat            => x_wif_major_unit_set_cat,
      x_wif_minor_unit_set_cat            => x_wif_minor_unit_set_cat,
      x_wif_track_unit_set_cat            => x_wif_track_unit_set_cat,
      x_wif_unit_set_title                => x_wif_unit_set_title,
      x_third_party_options               => x_third_party_options,
--      x_advisor_relationship_ind          => x_advisor_relationship_ind,
      x_display_container_ind             => x_display_container_ind,
      x_container_title                   => x_container_title,
      x_link_text                         => x_link_text,
      x_link_url                          => x_link_url,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_da_setup
      SET
        program_definition_ind            = new_references.program_definition_ind,
        default_student_id_type           = new_references.default_student_id_type,
        default_inst_id_type                   = new_references.default_inst_id_type,
        default_address_type              = new_references.default_address_type,
        wif_major_unit_set_cat            = new_references.wif_major_unit_set_cat,
        wif_minor_unit_set_cat            = new_references.wif_minor_unit_set_cat,
        wif_track_unit_set_cat            = new_references.wif_track_unit_set_cat,
        wif_unit_set_title                = new_references.wif_unit_set_title,
        third_party_options               = new_references.third_party_options,
--        advisor_relationship_ind          = new_references.advisor_relationship_ind,
        display_container_ind             = new_references.display_container_ind,
        container_title                   = new_references.container_title,
        link_text                         = new_references.link_text,
        link_url                          = new_references.link_url,
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
    x_s_control_num                     IN     NUMBER,
    x_program_definition_ind            IN     VARCHAR2,
    x_default_student_id_type           IN     VARCHAR2,
    x_default_inst_id_type                   IN     VARCHAR2,
    x_default_address_type              IN     VARCHAR2,
    x_wif_major_unit_set_cat            IN     VARCHAR2,
    x_wif_minor_unit_set_cat            IN     VARCHAR2,
    x_wif_track_unit_set_cat            IN     VARCHAR2,
    x_wif_unit_set_title                IN     VARCHAR2,
    x_third_party_options               IN     VARCHAR2,
--    x_advisor_relationship_ind          IN     VARCHAR2,
    x_display_container_ind             IN     VARCHAR2,
    x_container_title                   IN     VARCHAR2,
    x_link_text                         IN     VARCHAR2,
    x_link_url                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 19-MAR-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_da_setup
      WHERE    s_control_num = x_s_control_num;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_s_control_num,
        x_program_definition_ind,
        x_default_student_id_type,
        x_default_inst_id_type,
        x_default_address_type,
        x_wif_major_unit_set_cat,
        x_wif_minor_unit_set_cat,
        x_wif_track_unit_set_cat,
        x_wif_unit_set_title,
        x_third_party_options,
--        x_advisor_relationship_ind,
        x_display_container_ind,
        x_container_title,
        x_link_text,
        x_link_url,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_s_control_num,
      x_program_definition_ind,
      x_default_student_id_type,
      x_default_inst_id_type,
      x_default_address_type,
      x_wif_major_unit_set_cat,
      x_wif_minor_unit_set_cat,
      x_wif_track_unit_set_cat,
      x_wif_unit_set_title,
      x_third_party_options,
--      x_advisor_relationship_ind,
      x_display_container_ind,
      x_container_title,
      x_link_text,
      x_link_url,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 19-MAR-2003
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

    DELETE FROM igs_da_setup
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_da_setup_pkg;

/
