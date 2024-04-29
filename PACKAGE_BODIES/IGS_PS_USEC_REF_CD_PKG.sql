--------------------------------------------------------
--  DDL for Package Body IGS_PS_USEC_REF_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_USEC_REF_CD_PKG" AS
/* $Header: IGSPI1HB.pls 115.9 2003/05/09 06:40:16 sarakshi ship $ */
/* CAHNGE HISTORY
   WHO        WHEN       WAHT
   ayedubat    24-MAY-2001   modified the Before_Dml to a new validation according to the DLD,PSP001-US */

  l_rowid VARCHAR2(25);
  old_references igs_ps_usec_ref_cd%ROWTYPE;
  new_references igs_ps_usec_ref_cd%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_section_reference_cd_id IN NUMBER DEFAULT NULL,
    x_unit_section_reference_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_reference_code_type  IN VARCHAR2 ,
    x_reference_code       IN VARCHAR2 ,
    x_reference_code_desc  IN VARCHAR2
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ps_usec_ref_cd
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
    new_references.unit_section_reference_cd_id := x_unit_section_reference_cd_id;
    new_references.unit_section_reference_id := x_unit_section_reference_id;
    new_references.reference_code_type :=x_reference_code_type;
    new_references.reference_code :=x_reference_code;
    new_references.reference_code_desc :=x_reference_code_desc;
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
   column_name IN VARCHAR2  DEFAULT NULL,
   column_value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
        NULL;
      END IF;

  END check_constraints;

 PROCEDURE check_uniqueness AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   BEGIN
       IF get_uk_for_validation (
      new_references.unit_section_reference_id,
      new_references.reference_code_type,
      new_references.reference_code
      ) THEN
   fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
   app_exception.raise_exception;
      END IF;
 END check_uniqueness ;

  PROCEDURE check_parent_existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR cur_reference_cd_chk(cp_reference_cd_type igs_ge_ref_cd_type_all.reference_cd_type%TYPE) IS
  SELECT 'X'
  FROM   igs_ge_ref_cd_type_all
  WHERE  restricted_flag='Y'
  AND    reference_cd_type=cp_reference_cd_type;
  l_var  VARCHAR2(1);

  BEGIN

    IF (((old_references.unit_section_reference_id = new_references.unit_section_reference_id)) OR
        ((new_references.unit_section_reference_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_usec_ref_pkg.get_pk_for_validation (
          new_references.unit_section_reference_id
        )  THEN
  fnd_message.set_name ('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
   app_exception.raise_exception;
    END IF;

    OPEN cur_reference_cd_chk(new_references.reference_code_type);
    FETCH cur_reference_cd_chk INTO l_var;
    IF cur_reference_cd_chk%FOUND THEN
      IF (((old_references.reference_code_type = new_references.reference_code_type) AND
         (old_references.reference_code= new_references.reference_code)) OR
        ((new_references.reference_code_type IS NULL) OR
         (new_references.reference_code IS NULL))) THEN
        NULL;
      ELSIF NOT igs_ge_ref_cd_pkg.get_uk_For_validation (
                  new_references.reference_code_type,
                  new_references.reference_code
                ) THEN
	CLOSE cur_reference_cd_chk;
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    CLOSE cur_reference_cd_chk;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_unit_section_reference_cd_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_usec_ref_cd
      WHERE    unit_section_reference_cd_id = x_unit_section_reference_cd_id
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
    x_unit_section_reference_id IN NUMBER,
    x_reference_code_type IN VARCHAR2,
    x_reference_code  IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_usec_ref_cd
      WHERE    reference_code_type = x_reference_code_type
      AND      reference_code = x_reference_code
      AND      unit_section_reference_id = x_unit_section_reference_id
      AND      ((l_rowid IS NULL) OR (ROWID <> l_rowid));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (TRUE);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;
  END get_uk_for_validation ;
  PROCEDURE get_fk_igs_ps_usec_ref (
    x_unit_section_reference_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_usec_ref_cd
      WHERE    unit_section_reference_id = x_unit_section_reference_id ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_USRCD_USREF_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_usec_ref;

  PROCEDURE get_fk_igs_ge_ref_cd_type(
    x_reference_code_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :sarakshi
  Date Created By :28-Apr-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_usec_ref_cd
      WHERE    reference_code_type = x_reference_code_type;

    lv_rowid cur_rowid%ROWTYPE;
  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_USRCD_RCT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ge_ref_cd_type;

  PROCEDURE get_ufk_igs_ge_ref_cd (
    x_reference_code_type IN VARCHAR2,
    x_reference_code IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_usec_ref_cd
      WHERE    reference_code_type = x_reference_code_type
      AND      reference_code = x_reference_code ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_USRCD_RC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ge_ref_cd;

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_section_reference_cd_id IN NUMBER DEFAULT NULL,
    x_unit_section_reference_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_reference_code_type  IN VARCHAR2 ,
    x_reference_code       IN VARCHAR2 ,
    x_reference_code_desc  IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR cur_ps_usec_ref_cd_v IS
    SELECT reference_code_type
    FROM   igs_ps_usec_ref_cd_v
    WHERE  unit_section_reference_cd_id = x_unit_section_reference_cd_id;
  lv_reference_code_type cur_ps_usec_ref_cd_v%ROWTYPE;
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_unit_section_reference_cd_id,
      x_unit_section_reference_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_reference_code_type  ,
      x_reference_code       ,
      x_reference_code_desc
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      NULL;
      IF get_pk_for_validation(
      new_references.unit_section_reference_cd_id)  THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      NULL;
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
    -- Call all the procedures related to Before Delete.
      NULL;
      OPEN cur_ps_usec_ref_cd_v;
      FETCH cur_ps_usec_ref_cd_v INTO lv_reference_code_type;
      IF igs_ps_val_atl.chk_mandatory_ref_cd(lv_reference_code_type.reference_code_type) THEN
        fnd_message.set_name ('IGS', 'IGS_PS_REF_CD_MANDATORY');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      CLOSE cur_ps_usec_ref_cd_v;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
  -- Call all the procedures related to Before Insert.
      IF get_pk_for_validation (
      new_references.unit_section_reference_cd_id)  THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
    END IF;

  END before_dml;

  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      NULL;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      NULL;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      NULL;
    END IF;
  l_rowid:=NULL;
  END after_dml;

  PROCEDURE insert_row (
      x_rowid IN OUT NOCOPY VARCHAR2,
      x_unit_section_reference_cd_id IN OUT NOCOPY NUMBER,
      x_unit_section_reference_id IN NUMBER,
      x_mode IN VARCHAR2 DEFAULT 'R' ,
      x_reference_code_type  IN VARCHAR2 ,
      x_reference_code       IN VARCHAR2 ,
      x_reference_code_desc  IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR c IS SELECT ROWID FROM igs_ps_usec_ref_cd
             WHERE   unit_section_reference_cd_id= x_unit_section_reference_cd_id;
     x_last_update_date DATE ;
     x_last_updated_by NUMBER ;
     x_last_update_login NUMBER ;
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
   SELECT igs_ps_usec_ref_cd_s.nextval
   INTO   x_unit_section_reference_cd_id
   FROM   dual;
   before_dml(
   p_action=>'INSERT',
   x_rowid=>x_rowid,
        x_unit_section_reference_cd_id=>x_unit_section_reference_cd_id,
        x_unit_section_reference_id=>x_unit_section_reference_id,
        x_creation_date=>x_last_update_date,
        x_created_by=>x_last_updated_by,
        x_last_update_date=>x_last_update_date,
        x_last_updated_by=>x_last_updated_by,
        x_last_update_login=>x_last_update_login,
        x_reference_code_type=>x_reference_code_type);
     INSERT INTO igs_ps_usec_ref_cd (
  unit_section_reference_cd_id
  ,unit_section_reference_id
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,reference_code_type
  ,reference_code
  ,reference_code_desc

        ) VALUES  (
  new_references.unit_section_reference_cd_id
  ,new_references.unit_section_reference_id
  ,x_last_update_date
  ,x_last_updated_by
  ,x_last_update_date
  ,x_last_updated_by
  ,x_last_update_login
  ,x_reference_code_type
  ,x_reference_code
  ,x_reference_code_desc
  );
  OPEN c;
   FETCH c INTO x_rowid;
   IF (c%NOTFOUND) THEN
  CLOSE c;
       RAISE NO_DATA_FOUND;
  END IF;
   CLOSE c;
    after_dml (
  p_action => 'INSERT' ,
  x_rowid => x_rowid );
 END insert_row;

 PROCEDURE lock_row (
      x_rowid IN  VARCHAR2,
      x_unit_section_reference_cd_id IN NUMBER,
      x_unit_section_reference_id IN NUMBER ,
      x_reference_code_type  IN VARCHAR2 ,
      x_reference_code       IN VARCHAR2 ,
      x_reference_code_desc  IN VARCHAR2
       ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   CURSOR c1 IS SELECT
      unit_section_reference_id,
      reference_code_type,
      reference_code,
      reference_code_desc
    FROM igs_ps_usec_ref_cd
    WHERE ROWID = x_rowid
    FOR UPDATE NOWAIT;
     tlinfo c1%ROWTYPE;
BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
    CLOSE c1;
    app_exception.raise_exception;
    RETURN;
  END IF;
  CLOSE c1;
  IF ( (tlinfo.unit_section_reference_id = x_unit_section_reference_id)
      AND ((tlinfo.reference_code_type= x_reference_code_type)
           OR ((tlinfo.reference_code_type IS NULL)
               AND (x_reference_code_type IS NULL)))
      AND ((tlinfo.reference_code= x_reference_code)
           OR ((tlinfo.reference_code IS NULL)
               AND (x_reference_code IS NULL)))
      AND ((tlinfo.reference_code_desc= x_reference_code_desc)
           OR ((tlinfo.reference_code_desc IS NULL)
               AND (x_reference_code_desc IS NULL)))
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
       x_unit_section_reference_cd_id IN NUMBER,
       x_unit_section_reference_id IN NUMBER,
       x_mode IN VARCHAR2 DEFAULT 'R'  ,
       x_reference_code_type  IN VARCHAR2,
       x_reference_code       IN VARCHAR2 ,
       x_reference_code_desc  IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     x_last_update_date DATE ;
     x_last_updated_by NUMBER ;
     x_last_update_login NUMBER ;
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
   before_dml(
   p_action=>'UPDATE',
   x_rowid=>x_rowid,
         x_unit_section_reference_cd_id=>x_unit_section_reference_cd_id,
         x_unit_section_reference_id=>x_unit_section_reference_id,
         x_creation_date=>x_last_update_date,
         x_created_by=>x_last_updated_by,
         x_last_update_date=>x_last_update_date,
         x_last_updated_by=>x_last_updated_by,
         x_last_update_login=>x_last_update_login,
         x_reference_code_type=>x_reference_code_type,
         x_reference_code=>x_reference_code,
         x_reference_code_desc=>x_reference_code_desc
);
   UPDATE igs_ps_usec_ref_cd SET
      unit_section_reference_id =  new_references.unit_section_reference_id,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by,
      last_update_login = x_last_update_login,
      reference_code_type= x_reference_code_type,
      reference_code = x_reference_code,
      reference_code_desc = x_reference_code_desc

   WHERE ROWID = x_rowid;
   IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
   END IF;

   after_dml (
     p_action => 'UPDATE' ,
     x_rowid => x_rowid
   );
 END update_row;
 PROCEDURE add_row (
      x_rowid IN OUT NOCOPY VARCHAR2,
      x_unit_section_reference_cd_id IN OUT NOCOPY NUMBER,
      x_unit_section_reference_id IN NUMBER,
      x_mode IN VARCHAR2 DEFAULT 'R' ,
      x_reference_code_type  IN VARCHAR2 ,
      x_reference_code       IN VARCHAR2 ,
      x_reference_code_desc  IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR c1 IS SELECT ROWID FROM igs_ps_usec_ref_cd
             WHERE     unit_section_reference_cd_id= x_unit_section_reference_cd_id;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_unit_section_reference_cd_id,
        x_unit_section_reference_id,
        x_mode ,
        x_reference_code_type,
        x_reference_code,
        x_reference_code_desc);
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
       x_rowid,
       x_unit_section_reference_cd_id,
       x_unit_section_reference_id,
       x_mode,
       x_reference_code_type,
       x_reference_code,
       x_reference_code_desc);
  END add_row;
  PROCEDURE delete_row (
  x_rowid IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    before_dml (
    p_action => 'DELETE',
    x_rowid => x_rowid
    );
    DELETE FROM igs_ps_usec_ref_cd
    WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    after_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );
  END delete_row;

END igs_ps_usec_ref_cd_pkg;

/
