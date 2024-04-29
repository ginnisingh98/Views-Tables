--------------------------------------------------------
--  DDL for Package Body IGF_AP_ATTEND_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_ATTEND_MAP_PKG" AS
/* $Header: IGFAI44B.pls 115.9 2002/11/28 14:02:04 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_ap_attend_map_all%ROWTYPE;
  new_references igf_ap_attend_map_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2 ,
    x_rowid                             IN     VARCHAR2 ,
    x_atm_id                            IN     NUMBER   ,
    x_attendance_type                   IN     VARCHAR2 ,
    x_pell_att_code                     IN     VARCHAR2 ,
    x_cl_att_code                       IN     VARCHAR2 ,
    x_ap_att_code                       IN     VARCHAR2 ,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER  ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AP_ATTEND_MAP_ALL
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
    new_references.atm_id                            := x_atm_id;
    new_references.attendance_type                   := x_attendance_type;
    new_references.pell_att_code                     := x_pell_att_code;
    new_references.cl_att_code                       := x_cl_att_code;
    new_references.ap_att_code                       := x_ap_att_code;
    new_references.cal_type                          := x_cal_type;
    new_references.sequence_number                   := x_sequence_number;

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
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.attendance_type,
           new_references.org_id,
           new_references.cal_type       ,
           new_references.sequence_number
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || adhawan         24-oct-2002      Added check for Award Year
  || 2613546
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_atd_type_pkg.get_pk_for_validation (
                new_references.attendance_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    --Bug ID 2613546
    ELSIF  NOT igs_ca_inst_pkg.get_pk_for_validation(new_references.cal_type,
                                                 new_references.sequence_number) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_atm_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_attend_map_all
      WHERE    atm_id = x_atm_id
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
    x_attendance_type                   IN     VARCHAR2,
    x_org_id                            IN     NUMBER ,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || vvutukur        18-feb-2002    modified org_id check in cur_rowid cursor with new local variable l_org_id.Bug:2222272.
  ||  (reverse chronological order - newest change first)
  */

   l_org_id          igf_ap_attend_map.org_id%TYPE := igf_aw_gen.get_org_id;

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_attend_map
      WHERE    attendance_type = x_attendance_type
      AND      cal_type        = x_cal_type
      AND      sequence_number = x_sequence_number
      AND      NVL(org_id,NVL(l_org_id,-99)) = NVL(l_org_id,-99)
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

  PROCEDURE get_fk_igs_ca_inst (
   x_cal_type                          IN     VARCHAR2,
   x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 24-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History : Bug id 2613546
  ||  Who             When            What
  ||
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_attend_map_all
      WHERE   ((cal_type = x_cal_type) AND
               (sequence_number = x_sequence_number)
              );
    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF','IGF_AP_ATM_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
     END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE get_fk_igs_en_atd_type_all (
    x_attendance_type                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  masehgal        14-Jun-2002     # 2413695   Changed message to
  ||                                  'IGF','IGF_AP_ATM_ATT_FK'
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_attend_map_all
      WHERE   ((attendance_type = x_attendance_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF','IGF_AP_ATM_ATT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_atd_type_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2 ,
    x_rowid                             IN     VARCHAR2 ,
    x_atm_id                            IN     NUMBER   ,
    x_attendance_type                   IN     VARCHAR2 ,
    x_pell_att_code                     IN     VARCHAR2 ,
    x_cl_att_code                       IN     VARCHAR2 ,
    x_ap_att_code                       IN     VARCHAR2 ,
    x_cal_type                          IN     VARCHAR2 ,
    x_sequence_number                   IN     NUMBER   ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
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
      x_atm_id,
      x_attendance_type,
      x_pell_att_code,
      x_cl_att_code,
      x_ap_att_code,
      x_cal_type  ,
      x_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.atm_id
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.atm_id
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

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_atm_id                            IN OUT NOCOPY NUMBER,
    x_attendance_type                   IN     VARCHAR2,
    x_pell_att_code                     IN     VARCHAR2,
    x_cl_att_code                       IN     VARCHAR2,
    x_ap_att_code                       IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_attend_map_all
      WHERE    atm_id                            = x_atm_id;

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

    SELECT    igf_ap_attend_map_s.NEXTVAL
    INTO      x_atm_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_atm_id                            => x_atm_id,
      x_attendance_type                   => x_attendance_type,
      x_pell_att_code                     => x_pell_att_code,
      x_cl_att_code                       => x_cl_att_code,
      x_ap_att_code                       => x_ap_att_code,
      x_cal_type                          => x_cal_type    ,
      x_sequence_number                   => x_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_ap_attend_map_all (
      atm_id,
      attendance_type,
      pell_att_code,
      cl_att_code,
      ap_att_code,
      cal_type,
      sequence_number,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.atm_id,
      new_references.attendance_type,
      new_references.pell_att_code,
      new_references.cl_att_code,
      new_references.ap_att_code,
      new_references.cal_type ,
      new_references.sequence_number,
      new_references.org_id,
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
    x_atm_id                            IN     NUMBER,
    x_attendance_type                   IN     VARCHAR2,
    x_pell_att_code                     IN     VARCHAR2,
    x_cl_att_code                       IN     VARCHAR2,
    x_ap_att_code                       IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        attendance_type,
        pell_att_code,
        cl_att_code,
        ap_att_code,
        cal_type ,
        sequence_number
      FROM  igf_ap_attend_map_all
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
        (tlinfo.attendance_type = x_attendance_type)
        AND ((tlinfo.pell_att_code = x_pell_att_code) OR ((tlinfo.pell_att_code IS NULL) AND (X_pell_att_code IS NULL)))
        AND ((tlinfo.cl_att_code = x_cl_att_code) OR ((tlinfo.cl_att_code IS NULL) AND (X_cl_att_code IS NULL)))
        AND ((tlinfo.ap_att_code = x_ap_att_code) OR ((tlinfo.ap_att_code IS NULL) AND (X_ap_att_code IS NULL)))
        AND ((tlinfo.cal_type = x_cal_type ) OR ((tlinfo.cal_type IS NULL) AND (x_cal_type IS NULL)))
        AND ((tlinfo.sequence_number = x_sequence_number ) OR ((tlinfo.sequence_number IS NULL) AND (x_sequence_number IS NULL)))
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
    x_atm_id                            IN     NUMBER,
    x_attendance_type                   IN     VARCHAR2,
    x_pell_att_code                     IN     VARCHAR2,
    x_cl_att_code                       IN     VARCHAR2,
    x_ap_att_code                       IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
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
      x_atm_id                            => x_atm_id,
      x_attendance_type                   => x_attendance_type,
      x_pell_att_code                     => x_pell_att_code,
      x_cl_att_code                       => x_cl_att_code,
      x_ap_att_code                       => x_ap_att_code,
      x_cal_type                          => x_cal_type ,
      x_sequence_number                   => x_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_ap_attend_map_all
      SET
        attendance_type                   = new_references.attendance_type,
        pell_att_code                     = new_references.pell_att_code,
        cl_att_code                       = new_references.cl_att_code,
        ap_att_code                       = new_references.ap_att_code,
        cal_type                          = new_references.cal_type ,
        sequence_number                   = new_references.sequence_number,
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
    x_atm_id                            IN OUT NOCOPY NUMBER,
    x_attendance_type                   IN     VARCHAR2,
    x_pell_att_code                     IN     VARCHAR2,
    x_cl_att_code                       IN     VARCHAR2,
    x_ap_att_code                       IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_attend_map_all
      WHERE    atm_id                            = x_atm_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_atm_id,
        x_attendance_type,
        x_pell_att_code,
        x_cl_att_code,
        x_ap_att_code,
        x_cal_type,
        x_sequence_number,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_atm_id,
      x_attendance_type,
      x_pell_att_code,
      x_cl_att_code,
      x_ap_att_code,
      x_cal_type ,
      x_sequence_number,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : John.Deekollu@oracle.com
  ||  Created On : 11-JUN-2001
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

    DELETE FROM igf_ap_attend_map_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_attend_map_pkg;

/
