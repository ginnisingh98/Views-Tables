--------------------------------------------------------
--  DDL for Package Body IGS_SS_ADMAPPL_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SS_ADMAPPL_SETUP_PKG" AS
/* $Header: IGSAIB6B.pls 115.10 2003/10/30 13:25:47 rghosh ship $ */

--hreddych 16-jul-2002  #2464172 removed the default null value in the lock_row procedure
--                       for X_DEPENDENT_OF_VETERAN and X_APP_SOURCE_ID
  l_rowid VARCHAR2(25);
  old_references igs_ss_admappl_setup%ROWTYPE;
  new_references igs_ss_admappl_setup%ROWTYPE;
  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2, --DEFAULT NULL,
    x_admappl_setup_id IN NUMBER,-- DEFAULT NULL,
    x_alias_type IN VARCHAR2, -- DEFAULT NULL,
    x_permanent_addr_type IN VARCHAR2, -- DEFAULT NULL,
    x_mailing_addr_type IN VARCHAR2, -- DEFAULT NULL,
    x_person_id_type IN VARCHAR2 ,--DEFAULT NULL,
    x_ps_note_type_id IN NUMBER , --DEFAULT NULL,
    x_we_note_type_id IN NUMBER , --DEFAULT NULL,
    x_act_note_type_id IN NUMBER , --DEFAULT NULL,
    x_dependent_of_veteran  IN NUMBER , --DEFAULT NULL,
    x_app_source_id  IN NUMBER , --DEFAULT NULL,
    x_creation_date IN DATE , --DEFAULT NULL,
    x_created_by IN NUMBER , --DEFAULT NULL,
    x_last_update_date IN DATE, -- DEFAULT NULL,
    x_last_updated_by IN NUMBER, -- DEFAULT NULL,
    x_last_update_login IN NUMBER --DEFAULT NULL
  ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || kumma            16-NOV-2002     REMOVED igs_pe_alias_types_pkg.get_pk_for_validation
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_SS_ADMAPPL_SETUP
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
    new_references.admappl_setup_id := x_admappl_setup_id;
    new_references.alias_type := x_alias_type;
/*
    Removed references due to DLD ver 1.7
    new_references.permanent_addr_type := x_permanent_addr_type;
    new_references.mailing_addr_type := x_mailing_addr_type;
*/
    new_references.person_id_type := x_person_id_type;
    new_references.ps_note_type_id := x_ps_note_type_id;
    new_references.we_note_type_id := x_we_note_type_id;
    new_references.act_note_type_id := x_act_note_type_id;
    new_references.dependent_of_veteran :=x_dependent_of_veteran;
     new_references.app_source_id := x_app_source_id;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
  END set_column_values;

  PROCEDURE check_constraints (
    column_name IN VARCHAR2, -- DEFAULT NULL,
    column_value IN VARCHAR2 --DEFAULT NULL
  ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
      NULL;
    END IF;
  END check_constraints;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF (((old_references.we_note_type_id = new_references.we_note_type_id)) OR
        ((new_references.we_note_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_note_types_pkg.get_pk_for_validation (
            new_references.we_note_type_id,
            'N'
        )  THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    IF (((old_references.alias_type = new_references.alias_type)) OR
        ((new_references.alias_type IS NULL))) THEN
      NULL;
/*
    ELSIF NOT igs_pe_alias_types_pkg.get_pk_for_validation (
            new_references.alias_type
        )  THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
*/
    END IF;
/*
 Removed Reference due to DLD1.7,  Column Obsoleted
    IF (((old_references.permanent_addr_type = new_references.permanent_addr_type)) OR
        ((new_references.permanent_addr_type IS NULL))) THEN
      NULL;
    END IF;
*/
    IF (((old_references.act_note_type_id = new_references.act_note_type_id)) OR
        ((new_references.act_note_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_note_types_pkg.get_pk_for_validation (
            new_references.act_note_type_id,
            'N'
        )  THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
/*
 Removed Reference due to DLD1.7,  Column Obsoleted
    IF (((old_references.mailing_addr_type = new_references.mailing_addr_type)) OR
        ((new_references.mailing_addr_type IS NULL))) THEN
      NULL;
    END IF;
*/
    IF (((old_references.person_id_type = new_references.person_id_type)) OR
        ((new_references.person_id_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_id_typ_pkg.get_pk_for_validation (
            new_references.person_id_type
        )  THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    IF (((old_references.ps_note_type_id = new_references.ps_note_type_id)) OR
        ((new_references.ps_note_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_note_types_pkg.get_pk_for_validation (
            new_references.ps_note_type_id,
            'N'
        )  THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_admappl_setup_id IN NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ss_admappl_setup
      WHERE    admappl_setup_id = x_admappl_setup_id
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

 PROCEDURE get_fk_igs_ad_note_types_we (
   x_notes_type_id IN NUMBER
    ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ss_admappl_setup
      WHERE    we_note_type_id = x_notes_type_id ;
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
  END get_fk_igs_ad_note_types_we;


 PROCEDURE get_fk_igs_pe_alias_types (
   x_alias_type IN VARCHAR2
    ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ss_admappl_setup
      WHERE    alias_type = x_alias_type ;
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
  END get_fk_igs_pe_alias_types;

 -- Code Removed as Column is Obsoleted in DLD ver 1.7
 --PROCEDURE get_fk_igs_co_addr_type_pat (
 -- x_addr_type IN VARCHAR2
 -- ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
/*
CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ss_admappl_setup
      WHERE    permanent_addr_type = x_addr_type ;
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
  END get_fk_igs_co_addr_type_pat;
*/
 PROCEDURE get_fk_igs_ad_note_types_act (
   x_notes_type_id IN NUMBER
    ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ss_admappl_setup
      WHERE    act_note_type_id = x_notes_type_id ;
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
  END get_fk_igs_ad_note_types_act;
-- Removed Reference due to DLD1.7,  Column Obsoleted
-- PROCEDURE get_fk_igs_co_addr_type_mat (
--  x_addr_type IN VARCHAR2
--  ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
/*
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ss_admappl_setup
      WHERE    mailing_addr_type = x_addr_type ;
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
  END get_fk_igs_co_addr_type_mat;
*/
 PROCEDURE get_fk_igs_pe_person_id_typ (
   x_person_id_type IN VARCHAR2
    ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ss_admappl_setup
      WHERE    person_id_type = x_person_id_type ;
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
  END get_fk_igs_pe_person_id_typ;
 PROCEDURE get_fk_igs_ad_note_types_psnt (
   x_notes_type_id IN NUMBER
    ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ss_admappl_setup
      WHERE    ps_note_type_id = x_notes_type_id ;
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
  END get_fk_igs_ad_note_types_psnt;

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 , --DEFAULT NULL,
    x_admappl_setup_id IN NUMBER, -- DEFAULT NULL,
    x_alias_type IN VARCHAR2 ,--DEFAULT NULL,
    x_permanent_addr_type IN VARCHAR2, -- DEFAULT NULL,
    x_mailing_addr_type IN VARCHAR2 , --DEFAULT NULL,
    x_person_id_type IN VARCHAR2 , --DEFAULT NULL,
    x_ps_note_type_id IN NUMBER , --DEFAULT NULL,
    x_we_note_type_id IN NUMBER , --DEFAULT NULL,
    x_act_note_type_id IN NUMBER, -- DEFAULT NULL,
    x_dependent_of_veteran  IN NUMBER , --DEFAULT NULL,
    x_app_source_id  IN NUMBER , --DEFAULT NULL,
    x_creation_date IN DATE , --DEFAULT NULL,
    x_created_by IN NUMBER , --DEFAULT NULL,
    x_last_update_date IN DATE , --DEFAULT NULL,
    x_last_updated_by IN NUMBER , --DEFAULT NULL,
    x_last_update_login IN NUMBER --DEFAULT NULL
  ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    set_column_values (
      p_action,
      x_rowid,
      x_admappl_setup_id,
      x_alias_type,
      x_permanent_addr_type,
      x_mailing_addr_type,
      x_person_id_type,
      x_ps_note_type_id,
      x_we_note_type_id,
      x_act_note_type_id,
      x_dependent_of_veteran,
      x_app_source_id ,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
      IF (get_pk_for_validation(
            new_references.admappl_setup_id)) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF (get_pk_for_validation (
            new_references.admappl_setup_id)) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
    END IF;
  END before_dml;
  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;
  END after_dml;

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_admappl_setup_id IN NUMBER,
    x_alias_type IN VARCHAR2,
    x_permanent_addr_type IN VARCHAR2,
    x_mailing_addr_type IN VARCHAR2,
    x_person_id_type IN VARCHAR2,
    x_ps_note_type_id IN NUMBER,
    x_we_note_type_id IN NUMBER,
    x_act_note_type_id IN NUMBER,
    x_dependent_of_veteran  IN NUMBER,
    x_app_source_id  IN NUMBER
  ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS SELECT
      alias_type
,      permanent_addr_type
,      mailing_addr_type
,      person_id_type
,      ps_note_type_id
,      we_note_type_id
,      act_note_type_id
,     dependent_of_veteran
,     app_source_id
    FROM igs_ss_admappl_setup
    WHERE ROWID = x_rowid
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
    IF ((  (tlinfo.ALIAS_TYPE = x_ALIAS_TYPE)
       OR ((tlinfo.ALIAS_TYPE is null)
      AND (X_ALIAS_TYPE is null)))

/*  Code Removed because the columns are obsoleted as part of DLD ver 1.7
      AND ((tlinfo.PERMANENT_ADDR_TYPE = x_PERMANENT_ADDR_TYPE)
       OR ((tlinfo.PERMANENT_ADDR_TYPE is null)
      AND (X_PERMANENT_ADDR_TYPE is null)))
      AND ((tlinfo.MAILING_ADDR_TYPE = x_MAILING_ADDR_TYPE)
       OR ((tlinfo.MAILING_ADDR_TYPE is null)
      AND (X_MAILING_ADDR_TYPE is null)))
*/
      AND ((tlinfo.PERSON_ID_TYPE = x_PERSON_ID_TYPE)
       OR ((tlinfo.PERSON_ID_TYPE is null)
      AND (X_PERSON_ID_TYPE is null)))
      AND ((tlinfo.PS_NOTE_TYPE_ID = x_PS_NOTE_TYPE_ID)
       OR ((tlinfo.PS_NOTE_TYPE_ID is null)
      AND (X_PS_NOTE_TYPE_ID is null)))
      AND ((tlinfo.WE_NOTE_TYPE_ID = x_WE_NOTE_TYPE_ID)
       OR ((tlinfo.WE_NOTE_TYPE_ID is null)
      AND (X_WE_NOTE_TYPE_ID is null)))
      AND ((tlinfo.DEPENDENT_OF_VETERAN = x_DEPENDENT_OF_VETERAN)
       OR ((tlinfo.DEPENDENT_OF_VETERAN is null)
      AND (X_APP_SOURCE_ID is null)))
      AND ((tlinfo.APP_SOURCE_ID = x_APP_SOURCE_ID)
       OR ((tlinfo.APP_SOURCE_ID is null)
      AND (X_APP_SOURCE_ID is null)))
     AND ((tlinfo.ACT_NOTE_TYPE_ID = x_ACT_NOTE_TYPE_ID)
       OR ((tlinfo.ACT_NOTE_TYPE_ID is null)
      AND (X_ACT_NOTE_TYPE_ID is null)))
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
    x_rowid IN  VARCHAR2,
    x_ADMAPPL_SETUP_ID IN NUMBER,
    x_ALIAS_TYPE IN VARCHAR2,
    x_PERMANENT_ADDR_TYPE IN VARCHAR2,
    x_MAILING_ADDR_TYPE IN VARCHAR2,
    x_PERSON_ID_TYPE IN VARCHAR2,
    x_PS_NOTE_TYPE_ID IN NUMBER,
    x_WE_NOTE_TYPE_ID IN NUMBER,
    x_ACT_NOTE_TYPE_ID IN NUMBER,
    x_dependent_of_veteran  IN NUMBER ,
    x_app_source_id  IN NUMBER ,
    x_mode IN VARCHAR2 --DEFAULT 'R'
  ) AS
  /*
  ||  Created By : tray
  ||  Date Created By : 2000/07/31
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date DATE ;
    x_last_updated_by NUMBER ;
    x_last_update_login NUMBER ;
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
      p_action=>'UPDATE',
      x_rowid=>X_ROWID,
      x_admappl_setup_id => x_ADMAPPL_SETUP_ID,
      x_alias_type => x_ALIAS_TYPE,
      x_permanent_addr_type => x_PERMANENT_ADDR_TYPE,
      x_mailing_addr_type => x_MAILING_ADDR_TYPE,
      x_person_id_type => x_PERSON_ID_TYPE,
      x_ps_note_type_id => x_PS_NOTE_TYPE_ID,
      x_we_note_type_id => x_WE_NOTE_TYPE_ID,
      x_act_note_type_id => x_ACT_NOTE_TYPE_ID,
      x_dependent_of_veteran => X_DEPENDENT_OF_VETERAN ,
      x_app_source_id  => X_APP_SOURCE_ID,
      x_creation_date=>x_last_update_date,
      x_created_by=>x_last_updated_by,
      x_last_update_date=>x_last_update_date,
      x_last_updated_by=>x_last_updated_by,
      x_last_update_login=>x_last_update_login
    );
    UPDATE igs_ss_admappl_setup SET
      alias_type =  new_references.alias_type,
      permanent_addr_type =  new_references.permanent_addr_type,
      mailing_addr_type =  new_references.mailing_addr_type,
      person_id_type =  new_references.person_id_type,
      ps_note_type_id =  new_references.ps_note_type_id,
      we_note_type_id =  new_references.we_note_type_id,
      act_note_type_id =  new_references.act_note_type_id,
      dependent_of_veteran  = new_references.dependent_of_veteran ,
      app_source_id  = new_references.app_source_id,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by,
      last_update_login = x_last_update_login
    WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    after_dml (
      p_action => 'UPDATE',
      x_rowid => X_ROWID
    );
  END update_row;
END igs_ss_admappl_setup_pkg;

/
