--------------------------------------------------------
--  DDL for Package Body IGS_PS_REF_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_REF_CD_PKG" AS
/* $Header: IGSPI29B.pls 115.9 2003/05/20 12:48:52 sarakshi ship $ */
/* CAHNGE HISTORY
   WHO         WHEN          WAHT
   ayedubat    11-JUN-2001   modified the BeforeRowInsertUpdateDelete1 to add a
                             new validation according to the DLD,PSP001-US      */

  l_rowid VARCHAR2(25);
  old_references igs_ps_ref_cd%ROWTYPE;
  new_references igs_ps_ref_cd%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ps_ref_cd
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.reference_cd_type := x_reference_cd_type;
    new_references.reference_cd := x_reference_cd;
    new_references.description := x_description;
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

  -- Trigger description :-
  -- "OSS_TST".trg_crfc_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_PS_REF_CD
  -- FOR EACH ROW

  PROCEDURE beforerowinsertupdatedelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  v_description igs_ps_ref_cd.description%TYPE;
  v_message_name VARCHAR2(30);
  v_course_cd igs_ps_ref_cd.course_cd%TYPE;
  v_version_number igs_ps_ref_cd.version_number%TYPE;
  BEGIN
     -- Set variables.
    IF p_deleting THEN
      v_course_cd := old_references.course_cd;
      v_version_number := old_references.version_number;
    ELSE -- p_inserting or p_updating
      v_course_cd := new_references.course_cd;
      v_version_number := new_references.version_number;
    END IF;
    -- Validate the insert/update/delete.
    IF  igs_ps_val_crs.crsp_val_iud_crv_dtl (
      v_course_cd,
      v_version_number,
      v_message_name) = FALSE THEN
      fnd_message.set_name('IGS',v_message_name);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    -- Validate reference code type.
    IF p_inserting OR
       (p_updating AND
         (old_references.reference_cd_type <> new_references.reference_cd_type)) THEN
      IF igs_ps_val_crfc.crsp_val_ref_cd_type(
                                              new_references.reference_cd_type,
                                              v_message_name) = FALSE THEN
        fnd_message.set_name('IGS',v_message_name);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF p_updating THEN
      IF NVL(old_references.description,'NULL') <>
         NVL(new_references.description,'NULL') THEN
        SELECT decode(NVL(old_references.description,'NULL'),
                      NVL(new_references.description,'NULL'),
                      NULL,old_references.description)
        INTO v_description
        FROM dual;
       -- Create history record for update
       igs_ps_gen_007.crsp_ins_crc_hist(
                               old_references.course_cd,
                               old_references.version_number,
                               old_references.reference_cd_type,
                               old_references.reference_cd,
                               old_references.last_update_date,
                               new_references.last_update_date,
                               old_references.last_updated_by,
                               v_description);
      END IF;
    END IF;
    IF p_deleting THEN
      IF igs_ps_val_atl.chk_mandatory_ref_cd(old_references.reference_cd_type) THEN
        fnd_message.set_name ('IGS', 'IGS_PS_REF_CD_MANDATORY');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      -- Create history record for deletion
      igs_ps_gen_007.crsp_ins_crc_hist(
                              old_references.course_cd,
                              old_references.version_number,
                              old_references.reference_cd_type,
                              old_references.reference_cd,
                              old_references.last_update_date,
                              SYSDATE,
                              old_references.last_updated_by,
                              old_references.description);
    END IF;

  END beforerowinsertupdatedelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_crfc_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_PS_REF_CD
  -- FOR EACH ROW

  PROCEDURE afterrowinsertupdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  v_message_name VARCHAR2(30);
  BEGIN
    IF  p_inserting  THEN
       NULL;
    END IF;

  END afterrowinsertupdate2;

  -- Trigger description :-
  -- "OSS_TST".trg_crfc_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_PS_REF_CD


  PROCEDURE check_uniqueness   AS
  BEGIN
    IF get_uk_for_validation(
      new_references.course_cd,
      new_references.version_number,
      new_references.reference_cd_type
      )THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END check_uniqueness;


  PROCEDURE check_constraints (
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value IN VARCHAR2 DEFAULT NULL
    ) AS
  BEGIN
    IF column_name IS NULL THEN
      NULL;
    ELSIF UPPER(column_name) = 'COURSE_CD' THEN
      new_references.course_cd := column_value;
    ELSIF UPPER(column_name) = 'REFERENCE_CD' THEN
      new_references.reference_cd := column_value;
    ELSIF UPPER(column_name) = 'REFERENCE_CD_TYPE' THEN
      new_references.reference_cd_type := column_value;
    END IF;
    IF UPPER(column_name)= 'COURSE_CD' OR
             column_name IS NULL THEN
      IF new_references.course_cd <> UPPER(new_references.course_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name)= 'REFERENCE_CD' OR
             column_name IS NULL THEN
      IF new_references.reference_cd <> UPPER(new_references.reference_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name)= 'REFERENCE_CD_TYPE' OR
             column_name IS NULL THEN
      IF new_references.reference_cd_type <> UPPER(new_references.reference_cd_type)  THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;

  PROCEDURE check_parent_existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_ps_ver_pkg.get_pk_for_validation (
        new_references.course_cd,
        new_references.version_number
        )THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF (((old_references.reference_cd_type = new_references.reference_cd_type)) OR

        ((new_references.reference_cd_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_ge_ref_cd_type_pkg.get_pk_for_validation (
        new_references.reference_cd_type )THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_reference_cd_type IN VARCHAR2,
    x_reference_cd IN VARCHAR2
    )RETURN BOOLEAN
  AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_ref_cd
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      reference_cd_type = x_reference_cd_type
      AND      reference_cd = x_reference_cd
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;

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
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_reference_cd_type IN VARCHAR2
    )RETURN BOOLEAN
  AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_ref_cd
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      reference_cd_type = x_reference_cd_type
      AND      (l_rowid IS NULL OR ROWID <> l_rowid)
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;

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
  END get_uk_for_validation;

  PROCEDURE get_fk_igs_ps_ver (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_ref_cd
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_CRFC_CRV_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_ver;

  PROCEDURE get_fk_igs_ge_ref_cd_type (
    x_reference_cd_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_ref_cd
      WHERE    reference_cd_type = x_reference_cd_type ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_CRFC_RCT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ge_ref_cd_type;

  PROCEDURE get_ufk_igs_ge_ref_cd (
    x_reference_cd_type IN VARCHAR2,
    x_reference_cd IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :sarakshi
  Date Created By :7-May-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_ref_cd
      WHERE    reference_cd_type = x_reference_cd_type
      AND      reference_cd = x_reference_cd ;

    lv_rowid cur_rowid%ROWTYPE;

 BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_CRFC_RC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ge_ref_cd;


  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_course_cd,
      x_version_number,
      x_reference_cd_type,
      x_reference_cd,
      x_description,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      beforerowinsertupdatedelete1 ( p_inserting => TRUE );
      IF get_pk_for_validation(
           new_references.course_cd ,
           new_references.version_number ,
           new_references.reference_cd_type ,
           new_references.reference_cd
           ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      beforerowinsertupdatedelete1 ( p_updating => TRUE );
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      beforerowinsertupdatedelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF get_pk_for_validation(
           new_references.course_cd ,
           new_references.version_number ,
           new_references.reference_cd_type ,
           new_references.reference_cd  ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_constraints;
    END IF;

    l_rowid:=NULL;

  END before_dml;

  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      afterrowinsertupdate2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      afterrowinsertupdate2 ( p_updating => TRUE );
    END IF;

    l_rowid:=NULL;

  END after_dml;

  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_reference_cd IN VARCHAR2,
    x_reference_cd_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
    ) AS
    CURSOR c IS SELECT ROWID FROM igs_ps_ref_cd
      WHERE course_cd = x_course_cd
      AND version_number = x_version_number
      AND reference_cd = x_reference_cd
      AND reference_cd_type = x_reference_cd_type;
    x_last_update_date DATE;
    x_last_updated_by NUMBER;
    x_last_update_login NUMBER;
  BEGIN
    x_last_update_date := SYSDATE;
    IF(x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login :=fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    before_dml (
      p_action => 'INSERT',
      x_rowid => x_rowid,
      x_course_cd => x_course_cd,
      x_version_number => x_version_number,
      x_reference_cd_type => x_reference_cd_type,
      x_reference_cd => x_reference_cd,
      x_description => x_description,
      x_creation_date => x_last_update_date  ,
      x_created_by => x_last_updated_by ,
      x_last_update_date => x_last_update_date  ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_update_login
      );

     INSERT INTO igs_ps_ref_cd (
       course_cd,
       version_number,
       reference_cd_type,
       reference_cd,
       description,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login)
       VALUES (
       new_references.course_cd,
       new_references.version_number,
       new_references.reference_cd_type,
       new_references.reference_cd,
       new_references.description,
       x_last_update_date,
       x_last_updated_by,
       x_last_update_date,
       x_last_updated_by,
       x_last_update_login
       );
      OPEN c;
      FETCH c INTO x_rowid;
      IF (c%NOTFOUND) THEN
        CLOSE c;
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE c;
      after_dml (
                 p_action => 'INSERT',
                 x_rowid => x_rowid
      );
  END insert_row;

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_reference_cd IN VARCHAR2,
    x_reference_cd_type IN VARCHAR2,
    x_description IN VARCHAR2
    ) AS
  CURSOR c1 IS SELECT
      description
    FROM igs_ps_ref_cd
    WHERE ROWID = x_rowid
    FOR UPDATE NOWAIT;
  tlinfo c1%ROWTYPE;

  BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF ( ((tlinfo.description = x_description)
           OR ((tlinfo.description IS NULL)
               AND (x_description IS NULL)))
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
    x_rowid IN VARCHAR2,
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_reference_cd IN VARCHAR2,
    x_reference_cd_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
    ) AS
    x_last_update_date DATE;
    x_last_updated_by NUMBER;
    x_last_update_login NUMBER;
  BEGIN
    x_last_update_date := SYSDATE;
    IF(x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login :=fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    before_dml (
    p_action => 'UPDATE',
    x_rowid => x_rowid,
    x_course_cd => x_course_cd,
    x_version_number => x_version_number,
    x_reference_cd_type => x_reference_cd_type,
    x_reference_cd => x_reference_cd,
    x_description => x_description,
    x_creation_date => x_last_update_date  ,
    x_created_by => x_last_updated_by ,
    x_last_update_date => x_last_update_date  ,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login => x_last_update_login
    );

    UPDATE igs_ps_ref_cd SET
    course_cd = new_references.course_cd,
    version_number = new_references.version_number,
    reference_cd_type = new_references.reference_cd_type,
    reference_cd = new_references.reference_cd,
    description = new_references.description,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login
    WHERE ROWID = x_rowid ;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    after_dml (
      p_action => 'UPDATE',
      x_rowid => x_rowid);

  END update_row;

  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_reference_cd IN VARCHAR2,
    x_reference_cd_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
    ) AS
  CURSOR c1 IS SELECT ROWID FROM igs_ps_ref_cd
     WHERE course_cd = x_course_cd
     AND version_number = x_version_number
     AND reference_cd = x_reference_cd
     AND reference_cd_type = x_reference_cd_type ;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_course_cd,
        x_version_number,
        x_reference_cd,
        x_reference_cd_type,
        x_description,
        x_mode);
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_course_cd,
      x_version_number,
      x_reference_cd,
      x_reference_cd_type,
      x_description,
      x_mode);
  END add_row;

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  BEGIN
    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );
    DELETE FROM igs_ps_ref_cd
    WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    after_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid);
  END delete_row;

END igs_ps_ref_cd_pkg;

/
