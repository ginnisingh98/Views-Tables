--------------------------------------------------------
--  DDL for Package Body IGS_PS_RSV_UOP_PRF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_RSV_UOP_PRF_PKG" AS
/* $Header: IGSPI1TB.pls 120.1 2005/08/18 07:13:28 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_rsv_uop_prf%ROWTYPE;
  new_references igs_ps_rsv_uop_prf%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rsv_uop_prf_id                    IN     NUMBER      DEFAULT NULL,
    x_rsv_uop_pri_id                    IN     NUMBER      DEFAULT NULL,
    x_preference_order                  IN     NUMBER      DEFAULT NULL,
    x_preference_code                   IN     VARCHAR2    DEFAULT NULL,
    x_preference_version                IN     NUMBER      DEFAULT NULL,
    x_percentage_reserved               IN     NUMBER      DEFAULT NULL,
    x_group_id                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 04-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_RSV_UOP_PRF
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
    new_references.rsv_uop_prf_id                    := x_rsv_uop_prf_id;
    new_references.rsv_uop_pri_id                    := x_rsv_uop_pri_id;
    new_references.preference_order                  := x_preference_order;
    new_references.preference_code                   := x_preference_code;
    new_references.preference_version                := x_preference_version;
    new_references.percentage_reserved               := x_percentage_reserved;
    new_references.group_id                          := x_group_id;

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
  ||  Created By : apelleti
  ||  Created On : 04-MAY-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.rsv_uop_pri_id,
           new_references.preference_code
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE check_parent_existance AS
  CURSOR c_check_hz_exists IS
    SELECT 'x' FROM hz_parties hp,igs_pe_hz_parties pe
    WHERE hp.party_id = pe.party_id
    AND pe.oss_org_unit_cd = new_references.preference_code;
  cur_rec_hz_exists c_check_hz_exists%ROWTYPE;
  /*
  ||  Created By : apelleti
  ||  Created On : 02-MAY-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  sommukhe    12-AUG-2005     Bug#4377818,changed the cursor c_check_hz_exists, included table igs_pe_hz_parties in
  ||                              FROM clause and modified the WHERE clause by joining HZ_PARTIES and IGS_PE_HZ_PARTIES
  ||                              using party_id and org unit being compared with oss_org_unit_cd of IGS_PE_HZ_PARTIES.
  ||  (reverse chronological order - newest change first)
  */
 CURSOR c_priority is
   Select priority_value
   from  IGS_PS_RSV_UOP_PRI PRI
   Where PRI.RSV_UOP_PRI_ID = new_references.rsv_uop_pri_id;
   priority_value1 VARCHAR2(30);
  BEGIN

    IF (((old_references.rsv_uop_pri_id = new_references.rsv_uop_pri_id)) OR
        ((new_references.rsv_uop_pri_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_rsv_uop_pri_pkg.get_pk_for_validation (
                new_references.rsv_uop_pri_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    ELSE
    OPEN c_priority;
    FETCH c_priority INTO priority_value1;
    IF (c_priority%found) THEN
      IF (priority_value1 = 'PROGRAM') THEN
        IF NOT igs_ps_ver_pkg.get_pk_for_validation(
               new_references.preference_code,
               new_references.preference_version ) THEN
            CLOSE c_priority;
            fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
         ELSE
            CLOSE c_priority;
         END IF;

       ELSIF (priority_value1 = 'PROGRAM_STAGE') THEN
         IF NOT igs_ps_stage_type_pkg.get_pk_for_validation(
               new_references.preference_code ) THEN
               fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
               CLOSE c_priority;
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
          ELSE
               CLOSE c_priority;
         END IF;
       ELSIF (priority_value1 = 'UNIT_SET') THEN
         IF NOT igs_en_unit_set_pkg.get_pk_for_validation(
               new_references.preference_code,
               new_references.preference_version ) THEN
               fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
               CLOSE c_priority;
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
          ELSE
               CLOSE c_priority;
         END IF;
       ELSIF (priority_value1 = 'PERSON_GRP') THEN
         IF NOT igs_pe_persid_group_pkg.get_pk_for_validation(
               new_references.group_id ) THEN
               fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
               CLOSE c_priority;
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
          ELSE
               CLOSE c_priority;
         END IF;
       ELSIF (priority_value1 = 'ORG_UNIT') THEN
          OPEN c_check_hz_exists;
          FETCH c_check_hz_exists into cur_rec_hz_exists;
          IF c_check_hz_exists%NotFound THEN
             CLOSE c_check_hz_exists;
             CLOSE c_priority;
             fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
             igs_ge_msg_stack.add;
             app_exception.raise_exception;
           ELSE
             CLOSE c_check_hz_exists;
             CLOSE c_priority;
          END IF;
        END IF;
        --CLOSE c_priority;
    END IF;
    END IF;
  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_rsv_uop_prf_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : apelleti
  ||  Created On : 04-MAY-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_rsv_uop_prf
      WHERE    rsv_uop_prf_id = x_rsv_uop_prf_id
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
    x_rsv_uop_pri_id                    IN     NUMBER,
    x_preference_code                   IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : apelleti
  ||  Created On : 04-MAY-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_rsv_uop_prf
      WHERE    rsv_uop_pri_id = x_rsv_uop_pri_id
      AND      preference_code = x_preference_code
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


  PROCEDURE get_fk_igs_ps_rsv_uop_pri (
    x_rsv_uop_pri_id                    IN     NUMBER
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 04-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_rsv_uop_prf
      WHERE   ((rsv_uop_pri_id = x_rsv_uop_pri_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_USPF_USPR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_rsv_uop_pri;

   PROCEDURE get_fk_igs_ps_ver_all (
    x_preference_code               IN     VARCHAR2,
    x_preference_version          IN     NUMBER
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 02-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_rsv_uop_prf
      WHERE   ((preference_code = x_preference_code) AND (preference_version = x_preference_version) );

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_RUPF_CRV_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_ver_all;

  PROCEDURE get_fk_igs_ps_stage_type (
    x_preference_code               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 02-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_rsv_uop_prf
      WHERE   ((preference_code = x_preference_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_RUPF_CSTT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_stage_type;

  PROCEDURE get_fk_igs_en_unit_set_all (
    x_preference_code               IN     VARCHAR2,
    x_preference_version            IN     NUMBER
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 02-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_rsv_uop_prf
      WHERE   ((preference_code = x_preference_code) AND (preference_version = x_preference_version));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_RUPF_US_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_unit_set_all;

  PROCEDURE get_fk_hz_parties (
    x_preference_code               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 02-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_rsv_uop_prf
      WHERE   ((preference_code = x_preference_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_RUPF_HZ_PARTIES_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_parties;

  PROCEDURE BeforeInsertUpdate(p_inserting BOOLEAN , p_updating BOOLEAN) AS
  p_message_name VARCHAR2(30);
  BEGIN
   IF ( p_inserting = TRUE OR (p_updating = TRUE AND new_references.group_id <> old_references.group_id ) ) THEN
    IF  NOT IGS_PE_PERSID_GROUP_PKG.val_persid_group(new_references.group_id,p_message_name) THEN
        Fnd_Message.Set_Name('IGS', p_message_name);
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;
   END IF;
  END BeforeInsertUpdate;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rsv_uop_prf_id                    IN     NUMBER      DEFAULT NULL,
    x_rsv_uop_pri_id                    IN     NUMBER      DEFAULT NULL,
    x_preference_order                  IN     NUMBER      DEFAULT NULL,
    x_preference_code                   IN     VARCHAR2    DEFAULT NULL,
    x_preference_version                IN     NUMBER      DEFAULT NULL,
    x_percentage_reserved               IN     NUMBER      DEFAULT NULL,
    x_group_id                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 04-MAY-2001
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
      x_rsv_uop_prf_id,
      x_rsv_uop_pri_id,
      x_preference_order,
      x_preference_code,
      x_preference_version,
      x_percentage_reserved,
      x_group_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeInsertUpdate(TRUE,FALSE);
      IF ( get_pk_for_validation(
             new_references.rsv_uop_prf_id
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
      BeforeInsertUpdate(FALSE,TRUE);
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.rsv_uop_prf_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  l_rowid:=NULL;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rsv_uop_prf_id                    IN OUT NOCOPY NUMBER,
    x_rsv_uop_pri_id                    IN     NUMBER,
    x_preference_order                  IN     NUMBER,
    x_preference_code                   IN     VARCHAR2,
    x_preference_version                IN     NUMBER,
    x_percentage_reserved               IN     NUMBER,
    x_group_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 04-MAY-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ps_rsv_uop_prf
      WHERE    rsv_uop_prf_id                    = x_rsv_uop_prf_id;

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

    SELECT    igs_ps_rsv_uop_prf_s.NEXTVAL
    INTO      x_rsv_uop_prf_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_rsv_uop_prf_id                    => x_rsv_uop_prf_id,
      x_rsv_uop_pri_id                    => x_rsv_uop_pri_id,
      x_preference_order                  => x_preference_order,
      x_preference_code                   => x_preference_code,
      x_preference_version                => x_preference_version,
      x_percentage_reserved               => x_percentage_reserved,
      x_group_id                          => x_group_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ps_rsv_uop_prf (
      rsv_uop_prf_id,
      rsv_uop_pri_id,
      preference_order,
      preference_code,
      preference_version,
      percentage_reserved,
      group_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.rsv_uop_prf_id,
      new_references.rsv_uop_pri_id,
      new_references.preference_order,
      new_references.preference_code,
      new_references.preference_version,
      new_references.percentage_reserved,
      new_references.group_id,
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

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rsv_uop_prf_id                    IN     NUMBER,
    x_rsv_uop_pri_id                    IN     NUMBER,
    x_preference_order                  IN     NUMBER,
    x_preference_code                   IN     VARCHAR2,
    x_preference_version                IN     NUMBER,
    x_percentage_reserved               IN     NUMBER,
    x_group_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 04-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        rsv_uop_pri_id,
        preference_order,
        preference_code,
        preference_version,
        percentage_reserved,
        group_id
      FROM  igs_ps_rsv_uop_prf
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
        (tlinfo.rsv_uop_pri_id = x_rsv_uop_pri_id)
        AND (tlinfo.preference_order = x_preference_order)
        AND (tlinfo.preference_code = x_preference_code)
        AND ((tlinfo.preference_version = x_preference_version) OR ((tlinfo.preference_version IS NULL) AND (X_preference_version IS NULL)))
        AND (tlinfo.percentage_reserved = x_percentage_reserved)
        AND ((tlinfo.group_id = x_group_id) OR ((tlinfo.group_id IS NULL) AND (X_group_id IS NULL)))
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
    x_rsv_uop_prf_id                    IN     NUMBER,
    x_rsv_uop_pri_id                    IN     NUMBER,
    x_preference_order                  IN     NUMBER,
    x_preference_code                   IN     VARCHAR2,
    x_preference_version                IN     NUMBER,
    x_percentage_reserved               IN     NUMBER,
    x_group_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 04-MAY-2001
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
      x_rsv_uop_prf_id                    => x_rsv_uop_prf_id,
      x_rsv_uop_pri_id                    => x_rsv_uop_pri_id,
      x_preference_order                  => x_preference_order,
      x_preference_code                   => x_preference_code,
      x_preference_version                => x_preference_version,
      x_percentage_reserved               => x_percentage_reserved,
      x_group_id                          => x_group_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ps_rsv_uop_prf
      SET
        rsv_uop_pri_id                    = new_references.rsv_uop_pri_id,
        preference_order                  = new_references.preference_order,
        preference_code                   = new_references.preference_code,
        preference_version                = new_references.preference_version,
        percentage_reserved               = new_references.percentage_reserved,
        group_id                          = new_references.group_id,
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
    x_rsv_uop_prf_id                    IN OUT NOCOPY NUMBER,
    x_rsv_uop_pri_id                    IN     NUMBER,
    x_preference_order                  IN     NUMBER,
    x_preference_code                   IN     VARCHAR2,
    x_preference_version                IN     NUMBER,
    x_percentage_reserved               IN     NUMBER,
    x_group_id                          IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 04-MAY-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ps_rsv_uop_prf
      WHERE    rsv_uop_prf_id                    = x_rsv_uop_prf_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_rsv_uop_prf_id,
        x_rsv_uop_pri_id,
        x_preference_order,
        x_preference_code,
        x_preference_version,
        x_percentage_reserved,
        x_group_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_rsv_uop_prf_id,
      x_rsv_uop_pri_id,
      x_preference_order,
      x_preference_code,
      x_preference_version,
      x_percentage_reserved,
      x_group_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 04-MAY-2001
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

    DELETE FROM igs_ps_rsv_uop_prf
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ps_rsv_uop_prf_pkg;

/
