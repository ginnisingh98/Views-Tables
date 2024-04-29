--------------------------------------------------------
--  DDL for Package Body IGS_PS_US_UNSCHED_CL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_US_UNSCHED_CL_PKG" AS
/* $Header: IGSPI2UB.pls 120.1 2005/06/29 04:26:50 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_us_unsched_cl%ROWTYPE;
  new_references igs_ps_us_unsched_cl%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_us_unscheduled_cl_id              IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_activity_type_id                  IN     NUMBER      DEFAULT NULL,
    x_location_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_building_id                       IN     NUMBER      DEFAULT NULL,
    x_room_id                           IN     NUMBER      DEFAULT NULL,
    x_number_of_students                IN     NUMBER      DEFAULT NULL,
    x_hours_per_student                 IN     NUMBER      DEFAULT NULL,
    x_hours_per_faculty                 IN     NUMBER      DEFAULT NULL,
    x_instructor_id                     IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_US_UNSCHED_CL
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
    new_references.us_unscheduled_cl_id              := x_us_unscheduled_cl_id;
    new_references.uoo_id                            := x_uoo_id;
    new_references.activity_type_id                  := x_activity_type_id;
    new_references.location_cd                       := x_location_cd;
    new_references.building_id                       := x_building_id;
    new_references.room_id                           := x_room_id;
    new_references.number_of_students                := x_number_of_students;
    new_references.hours_per_student                 := x_hours_per_student;
    new_references.hours_per_faculty                 := x_hours_per_faculty;
    new_references.instructor_id                     := x_instructor_id;

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
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.uoo_id,
           new_references.activity_type_id,
           new_references.location_cd,
           new_references.building_id,
           new_references.room_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

PROCEDURE Check_Constraints(
                                Column_Name     IN      VARCHAR2   ,
                                Column_Value    IN      VARCHAR2   )
AS
 /*************************************************************
   Created By : sarakshi
   Date Created By : 2005/02/06
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
  ***************************************************************/
BEGIN
        IF Column_Name IS NULL THEN
                NULL;
        ELSIF Upper(Column_Name)='NUMBER_OF_STUDENTS' THEN
                New_References.number_of_students := Column_Value;
        ELSIF Upper(Column_Name)='HOURS_PER_STUDENT' THEN
                New_References.hours_per_student := Column_Value;
        ELSIF Upper(Column_Name)='HOURS_PER_FACULTY' THEN
                New_References.hours_per_faculty := Column_Value;
        END IF;


	IF UPPER(Column_Name)='NUMBER_OF_STUDENTS' OR Column_Name IS NULL THEN
                IF New_References.number_of_students < 0 OR New_References.number_of_students > 9999999999 THEN
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

	IF UPPER(Column_Name)='HOURS_PER_STUDENT' OR Column_Name IS NULL THEN
                IF New_References.hours_per_student < 0 OR New_References.hours_per_student > 999.99 THEN
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

	IF UPPER(Column_Name)='HOURS_PER_FACULTY' OR Column_Name IS NULL THEN
                IF New_References.hours_per_faculty < 0 OR New_References.hours_per_faculty > 999.99 THEN
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

END Check_Constraints;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     hz_parties
      WHERE    party_id = new_references.instructor_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_location_pkg.get_pk_for_validation (
                new_references.location_cd ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.building_id = new_references.building_id)) OR
        ((new_references.building_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_building_pkg.get_pk_for_validation (
                new_references.building_id ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.room_id = new_references.room_id)) OR
        ((new_references.room_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_room_pkg.get_pk_for_validation (
                new_references.room_id ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ofr_opt_pkg.get_uk_For_validation (
                new_references.uoo_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.instructor_id = new_references.instructor_id)) OR
        ((new_references.instructor_id IS NULL))) THEN
      NULL;
    ELSE
      OPEN cur_rowid;
      FETCH cur_rowid INTO lv_rowid;
      IF (cur_rowid%FOUND) THEN
        CLOSE cur_rowid;
      ELSE
        CLOSE cur_rowid;
        fnd_message.set_name ('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_us_unscheduled_cl_id    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_unsched_cl
      WHERE    us_unscheduled_cl_id = x_us_unscheduled_cl_id
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
    x_uoo_id                            IN     NUMBER,
    x_activity_type_id                  IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_building_id                       IN     NUMBER,
    x_room_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_unsched_cl
      WHERE    uoo_id = x_uoo_id
      AND      activity_type_id = x_activity_type_id
      AND      location_cd = x_location_cd
      AND      building_id = x_building_id
      AND      room_id = x_room_id
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


  PROCEDURE get_fk_igs_ad_location (
    x_location_cd                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_unsched_cl
      WHERE   ((location_cd = x_location_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_LOC_UUCL_FK1');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_location;


  PROCEDURE get_fk_igs_ad_building (
    x_building_id                       IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_unsched_cl
      WHERE   ((building_id = x_building_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_BLD_UUCL_FK2');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_building;


  PROCEDURE get_fk_igs_ad_room (
    x_room_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_unsched_cl
      WHERE   ((room_id = x_room_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_ROM_UUCL_FK3');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_room;


  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_unsched_cl
      WHERE   ((uoo_id = x_uoo_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_UOO_UUCL_FK4');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ps_unit_ofr_opt;


  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_unsched_cl
      WHERE   ((instructor_id = x_party_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_HZP_UUCL_FK5');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_parties;

  PROCEDURE get_fk_igs_ps_usec_act_type (
    x_activity_type_id                    IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 21-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_unsched_cl
      WHERE   ((activity_type_id = x_activity_type_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_USAT_UUCL_FK6');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_usec_act_type;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_us_unscheduled_cl_id    IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_activity_type_id                  IN     NUMBER      DEFAULT NULL,
    x_location_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_building_id                       IN     NUMBER      DEFAULT NULL,
    x_room_id                           IN     NUMBER      DEFAULT NULL,
    x_number_of_students                IN     NUMBER      DEFAULT NULL,
    x_hours_per_student                 IN     NUMBER      DEFAULT NULL,
    x_hours_per_faculty                 IN     NUMBER      DEFAULT NULL,
    x_instructor_id                     IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
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
      x_us_unscheduled_cl_id,
      x_uoo_id,
      x_activity_type_id,
      x_location_cd,
      x_building_id,
      x_room_id,
      x_number_of_students,
      x_hours_per_student,
      x_hours_per_faculty,
      x_instructor_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.us_unscheduled_cl_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      Check_Constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      Check_Constraints;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.us_unscheduled_cl_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      Check_Constraints;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_us_unscheduled_cl_id    IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_activity_type_id                  IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_building_id                       IN     NUMBER,
    x_room_id                           IN     NUMBER,
    x_number_of_students                IN     NUMBER,
    x_hours_per_student                 IN     NUMBER,
    x_hours_per_faculty                 IN     NUMBER,
    x_instructor_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ps_us_unsched_cl
      WHERE    us_unscheduled_cl_id    = x_us_unscheduled_cl_id;

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

    SELECT    igs_ps_us_unsched_cl_s.NEXTVAL
    INTO      x_us_unscheduled_cl_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_us_unscheduled_cl_id    => x_us_unscheduled_cl_id,
      x_uoo_id                            => x_uoo_id,
      x_activity_type_id                  => x_activity_type_id,
      x_location_cd                       => x_location_cd,
      x_building_id                       => x_building_id,
      x_room_id                           => x_room_id,
      x_number_of_students                => x_number_of_students,
      x_hours_per_student                 => x_hours_per_student,
      x_hours_per_faculty                 => x_hours_per_faculty,
      x_instructor_id                     => x_instructor_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ps_us_unsched_cl (
      us_unscheduled_cl_id,
      uoo_id,
      activity_type_id,
      location_cd,
      building_id,
      room_id,
      number_of_students,
      hours_per_student,
      hours_per_faculty,
      instructor_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.us_unscheduled_cl_id,
      new_references.uoo_id,
      new_references.activity_type_id,
      new_references.location_cd,
      new_references.building_id,
      new_references.room_id,
      new_references.number_of_students,
      new_references.hours_per_student,
      new_references.hours_per_faculty,
      new_references.instructor_id,
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
    x_us_unscheduled_cl_id    IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_activity_type_id                  IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_building_id                       IN     NUMBER,
    x_room_id                           IN     NUMBER,
    x_number_of_students                IN     NUMBER,
    x_hours_per_student                 IN     NUMBER,
    x_hours_per_faculty                 IN     NUMBER,
    x_instructor_id                     IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        uoo_id,
        activity_type_id,
        location_cd,
        building_id,
        room_id,
        number_of_students,
        hours_per_student,
        hours_per_faculty,
        instructor_id
      FROM  igs_ps_us_unsched_cl
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
        (tlinfo.uoo_id = x_uoo_id)
        AND (tlinfo.activity_type_id = x_activity_type_id)
        AND (tlinfo.location_cd = x_location_cd)
        AND (tlinfo.building_id = x_building_id)
        AND (tlinfo.room_id = x_room_id)
        AND (tlinfo.number_of_students = x_number_of_students)
        AND (tlinfo.hours_per_student = x_hours_per_student)
        AND (tlinfo.hours_per_faculty = x_hours_per_faculty)
        AND ((tlinfo.instructor_id = x_instructor_id) OR ((tlinfo.instructor_id IS NULL) AND (X_instructor_id IS NULL)))
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
    x_us_unscheduled_cl_id    IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_activity_type_id                  IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_building_id                       IN     NUMBER,
    x_room_id                           IN     NUMBER,
    x_number_of_students                IN     NUMBER,
    x_hours_per_student                 IN     NUMBER,
    x_hours_per_faculty                 IN     NUMBER,
    x_instructor_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
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
      x_us_unscheduled_cl_id    => x_us_unscheduled_cl_id,
      x_uoo_id                            => x_uoo_id,
      x_activity_type_id                  => x_activity_type_id,
      x_location_cd                       => x_location_cd,
      x_building_id                       => x_building_id,
      x_room_id                           => x_room_id,
      x_number_of_students                => x_number_of_students,
      x_hours_per_student                 => x_hours_per_student,
      x_hours_per_faculty                 => x_hours_per_faculty,
      x_instructor_id                     => x_instructor_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ps_us_unsched_cl
      SET
        uoo_id                            = new_references.uoo_id,
        activity_type_id                  = new_references.activity_type_id,
        location_cd                       = new_references.location_cd,
        building_id                       = new_references.building_id,
        room_id                           = new_references.room_id,
        number_of_students                = new_references.number_of_students,
        hours_per_student                 = new_references.hours_per_student,
        hours_per_faculty                 = new_references.hours_per_faculty,
        instructor_id                     = new_references.instructor_id,
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
    x_us_unscheduled_cl_id    IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_activity_type_id                  IN     NUMBER,
    x_location_cd                       IN     VARCHAR2,
    x_building_id                       IN     NUMBER,
    x_room_id                           IN     NUMBER,
    x_number_of_students                IN     NUMBER,
    x_hours_per_student                 IN     NUMBER,
    x_hours_per_faculty                 IN     NUMBER,
    x_instructor_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ps_us_unsched_cl
      WHERE    us_unscheduled_cl_id    = x_us_unscheduled_cl_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_us_unscheduled_cl_id,
        x_uoo_id,
        x_activity_type_id,
        x_location_cd,
        x_building_id,
        x_room_id,
        x_number_of_students,
        x_hours_per_student,
        x_hours_per_faculty,
        x_instructor_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_us_unscheduled_cl_id,
      x_uoo_id,
      x_activity_type_id,
      x_location_cd,
      x_building_id,
      x_room_id,
      x_number_of_students,
      x_hours_per_student,
      x_hours_per_faculty,
      x_instructor_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
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

    DELETE FROM igs_ps_us_unsched_cl
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ps_us_unsched_cl_pkg;

/
