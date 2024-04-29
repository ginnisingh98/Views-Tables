--------------------------------------------------------
--  DDL for Package Body IGS_EN_TIMESLOT_PARA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_TIMESLOT_PARA_PKG" AS
/* $Header: IGSEI41B.pls 115.6 2002/11/28 23:42:16 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_timeslot_para%ROWTYPE;
  new_references igs_en_timeslot_para%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_en_timeslot_para_id           IN     NUMBER      DEFAULT NULL,
    x_program_type_group_cd             IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_student_type                      IN     VARCHAR2    DEFAULT NULL,
    x_timeslot_calendar                 IN     VARCHAR2    DEFAULT NULL,
    x_timeslot_st_time                  IN     DATE        DEFAULT NULL,
    x_timeslot_end_time                 IN     DATE        DEFAULT NULL,
    x_ts_mode                           IN     VARCHAR2    DEFAULT NULL,
    x_max_head_count                    IN     NUMBER      DEFAULT NULL,
    x_length_of_time                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_org_id 				IN     NUMBER 	   DEFAULT NULL
  ) AS
  /*
  ||  Created By : nalkumar
  ||  Created On : 08-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_TIMESLOT_PARA
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
    new_references.igs_en_timeslot_para_id           := x_igs_en_timeslot_para_id;
    new_references.program_type_group_cd             := x_program_type_group_cd;
    new_references.cal_type                          := x_cal_type;
    new_references.sequence_number                   := x_sequence_number;
    new_references.student_type                      := x_student_type;
    new_references.timeslot_calendar                 := x_timeslot_calendar;
    new_references.timeslot_st_time                  := x_timeslot_st_time;
    new_references.timeslot_end_time                 := x_timeslot_end_time;
    new_references.ts_mode                           := x_ts_mode;
    new_references.max_head_count                    := x_max_head_count;
    new_references.length_of_time                    := x_length_of_time;
    new_references.org_id 			     := x_org_id;

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
  ||  Created By : nalkumar
  ||  Created On : 08-DEC-2000
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.program_type_group_cd,
           new_references.cal_type,
           new_references.sequence_number,
           new_references.student_type,
           new_references.timeslot_calendar,
           new_references.ts_mode
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : nalkumar
  ||  Created On : 08-DEC-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_en_timeslot_rslt_pkg.get_fk_igs_en_timeslot_para (
      old_references.igs_en_timeslot_para_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_igs_en_timeslot_para_id           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : nalkumar
  ||  Created On : 08-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_timeslot_para
      WHERE    igs_en_timeslot_para_id = x_igs_en_timeslot_para_id
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
    x_program_type_group_cd             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_student_type                      IN     VARCHAR2,
    x_timeslot_calendar                 IN     VARCHAR2,
    x_ts_mode                           IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : nalkumar
  ||  Created On : 08-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_timeslot_para
      WHERE    program_type_group_cd = x_program_type_group_cd
      AND      cal_type = x_cal_type
      AND      sequence_number = x_sequence_number
      AND      student_type = x_student_type
      AND      timeslot_calendar = x_timeslot_calendar
      AND      ts_mode = x_ts_mode
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

  PROCEDURE GET_FK_IGS_EN_TIMESLOT_CONF (
    X_TIMESLOT_NAME   IN VARCHAR2
    ) AS
  /*
  ||  Created By : nalkumar
  ||  Created On : 27-DEC-2000
  ||  Purpose : Validates the foreign Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_TIMESLOT_PARA
      WHERE    TIMESLOT_CALENDAR   = X_TIMESLOT_NAME;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_TS_CONF_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_TIMESLOT_CONF;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_en_timeslot_para_id           IN     NUMBER      DEFAULT NULL,
    x_program_type_group_cd             IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_student_type                      IN     VARCHAR2    DEFAULT NULL,
    x_timeslot_calendar                 IN     VARCHAR2    DEFAULT NULL,
    x_timeslot_st_time                  IN     DATE        DEFAULT NULL,
    x_timeslot_end_time                 IN     DATE        DEFAULT NULL,
    x_ts_mode                           IN     VARCHAR2    DEFAULT NULL,
    x_max_head_count                    IN     NUMBER      DEFAULT NULL,
    x_length_of_time                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_org_id 				IN     NUMBER 	   DEFAULT NULL
  ) AS
  /*
  ||  Created By : nalkumar
  ||  Created On : 08-DEC-2000
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
      x_igs_en_timeslot_para_id,
      x_program_type_group_cd,
      x_cal_type,
      x_sequence_number,
      x_student_type,
      x_timeslot_calendar,
      x_timeslot_st_time,
      x_timeslot_end_time,
      x_ts_mode,
      x_max_head_count,
      x_length_of_time,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.igs_en_timeslot_para_id
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
             new_references.igs_en_timeslot_para_id
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
    x_igs_en_timeslot_para_id           IN OUT NOCOPY NUMBER,
    x_program_type_group_cd             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_student_type                      IN     VARCHAR2,
    x_timeslot_calendar                 IN     VARCHAR2,
    x_timeslot_st_time                  IN     DATE,
    x_timeslot_end_time                 IN     DATE,
    x_ts_mode                           IN     VARCHAR2,
    x_max_head_count                    IN     NUMBER,
    x_length_of_time                    IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_org_id 				IN     NUMBER
  ) AS
  /*
  ||  Created By : nalkumar
  ||  Created On : 08-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pradhakr	     23-Jul-2002      Assigned igs_ge_gen_003.get_org_id to x_org_id
  ||				      in before dml as part of bug# 2457599
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_en_timeslot_para
      WHERE    igs_en_timeslot_para_id           = x_igs_en_timeslot_para_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;


   SELECT IGS_EN_TIMESLOT_PARA_S.NEXTVAL
   INTO x_igs_en_timeslot_para_id
   FROM DUAL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_igs_en_timeslot_para_id           => x_igs_en_timeslot_para_id,
      x_program_type_group_cd             => x_program_type_group_cd,
      x_cal_type                          => x_cal_type,
      x_sequence_number                   => x_sequence_number,
      x_student_type                      => x_student_type,
      x_timeslot_calendar                 => x_timeslot_calendar,
      x_timeslot_st_time                  => x_timeslot_st_time,
      x_timeslot_end_time                 => x_timeslot_end_time,
      x_ts_mode                           => x_ts_mode,
      x_max_head_count                    => x_max_head_count,
      x_length_of_time                    => x_length_of_time,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_org_id 				  => igs_ge_gen_003.get_org_id
    );

    INSERT INTO igs_en_timeslot_para (
      igs_en_timeslot_para_id,
      program_type_group_cd,
      cal_type,
      sequence_number,
      student_type,
      timeslot_calendar,
      timeslot_st_time,
      timeslot_end_time,
      ts_mode,
      max_head_count,
      length_of_time,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id
    ) VALUES (
      new_references.igs_en_timeslot_para_id,
      new_references.program_type_group_cd,
      new_references.cal_type,
      new_references.sequence_number,
      new_references.student_type,
      new_references.timeslot_calendar,
      new_references.timeslot_st_time,
      new_references.timeslot_end_time,
      new_references.ts_mode,
      new_references.max_head_count,
      new_references.length_of_time,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      NEW_REFERENCES.ORG_ID
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
    x_igs_en_timeslot_para_id           IN     NUMBER,
    x_program_type_group_cd             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_student_type                      IN     VARCHAR2,
    x_timeslot_calendar                 IN     VARCHAR2,
    x_timeslot_st_time                  IN     DATE,
    x_timeslot_end_time                 IN     DATE,
    x_ts_mode                           IN     VARCHAR2,
    x_max_head_count                    IN     NUMBER,
    x_length_of_time                    IN     NUMBER
  ) AS
  /*
  ||  Created By : nalkumar
  ||  Created On : 08-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        program_type_group_cd,
        cal_type,
        sequence_number,
        student_type,
        timeslot_calendar,
        timeslot_st_time,
        timeslot_end_time,
        ts_mode,
        max_head_count,
        length_of_time
      FROM  igs_en_timeslot_para
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
        (tlinfo.program_type_group_cd = x_program_type_group_cd)
        AND (tlinfo.cal_type = x_cal_type)
        AND (tlinfo.sequence_number = x_sequence_number)
        AND (tlinfo.student_type = x_student_type)
        AND (tlinfo.timeslot_calendar = x_timeslot_calendar)
        AND (tlinfo.timeslot_st_time = x_timeslot_st_time)
        AND (tlinfo.timeslot_end_time = x_timeslot_end_time)
        AND (tlinfo.ts_mode = x_ts_mode)
        AND (tlinfo.max_head_count = x_max_head_count)
        AND (tlinfo.length_of_time = x_length_of_time)
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
    x_igs_en_timeslot_para_id           IN     NUMBER,
    x_program_type_group_cd             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_student_type                      IN     VARCHAR2,
    x_timeslot_calendar                 IN     VARCHAR2,
    x_timeslot_st_time                  IN     DATE,
    x_timeslot_end_time                 IN     DATE,
    x_ts_mode                           IN     VARCHAR2,
    x_max_head_count                    IN     NUMBER,
    x_length_of_time                    IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : nalkumar
  ||  Created On : 08-DEC-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_igs_en_timeslot_para_id           => x_igs_en_timeslot_para_id,
      x_program_type_group_cd             => x_program_type_group_cd,
      x_cal_type                          => x_cal_type,
      x_sequence_number                   => x_sequence_number,
      x_student_type                      => x_student_type,
      x_timeslot_calendar                 => x_timeslot_calendar,
      x_timeslot_st_time                  => x_timeslot_st_time,
      x_timeslot_end_time                 => x_timeslot_end_time,
      x_ts_mode                           => x_ts_mode,
      x_max_head_count                    => x_max_head_count,
      x_length_of_time                    => x_length_of_time,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igs_en_timeslot_para
      SET
        program_type_group_cd             = new_references.program_type_group_cd,
        cal_type                          = new_references.cal_type,
        sequence_number                   = new_references.sequence_number,
        student_type                      = new_references.student_type,
        timeslot_calendar                 = new_references.timeslot_calendar,
        timeslot_st_time                  = new_references.timeslot_st_time,
        timeslot_end_time                 = new_references.timeslot_end_time,
        ts_mode                           = new_references.ts_mode,
        max_head_count                    = new_references.max_head_count,
        length_of_time                    = new_references.length_of_time,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_en_timeslot_para_id           IN OUT NOCOPY NUMBER,
    x_program_type_group_cd             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_student_type                      IN     VARCHAR2,
    x_timeslot_calendar                 IN     VARCHAR2,
    x_timeslot_st_time                  IN     DATE,
    x_timeslot_end_time                 IN     DATE,
    x_ts_mode                           IN     VARCHAR2,
    x_max_head_count                    IN     NUMBER,
    x_length_of_time                    IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_org_id				IN     NUMBER
  ) AS
  /*
  ||  Created By : nalkumar
  ||  Created On : 08-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_timeslot_para
      WHERE    igs_en_timeslot_para_id           = x_igs_en_timeslot_para_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_igs_en_timeslot_para_id,
        x_program_type_group_cd,
        x_cal_type,
        x_sequence_number,
        x_student_type,
        x_timeslot_calendar,
        x_timeslot_st_time,
        x_timeslot_end_time,
        x_ts_mode,
        x_max_head_count,
        x_length_of_time,
        x_mode,
        x_org_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_igs_en_timeslot_para_id,
      x_program_type_group_cd,
      x_cal_type,
      x_sequence_number,
      x_student_type,
      x_timeslot_calendar,
      x_timeslot_st_time,
      x_timeslot_end_time,
      x_ts_mode,
      x_max_head_count,
      x_length_of_time,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : nalkumar
  ||  Created On : 08-DEC-2000
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

    DELETE FROM igs_en_timeslot_para
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_timeslot_para_pkg;

/
