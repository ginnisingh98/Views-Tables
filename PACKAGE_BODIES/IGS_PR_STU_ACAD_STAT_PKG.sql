--------------------------------------------------------
--  DDL for Package Body IGS_PR_STU_ACAD_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_STU_ACAD_STAT_PKG" AS
/* $Header: IGSQI39B.pls 115.3 2003/08/19 05:41:29 smanglm noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pr_stu_acad_stat%ROWTYPE;
  new_references igs_pr_stu_acad_stat%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_source_reference                  IN     VARCHAR2,
    x_attempted_credit_points           IN     NUMBER,
    x_earned_credit_points              IN     NUMBER,
    x_gpa                               IN     NUMBER,
    x_gpa_credit_points                 IN     NUMBER,
    x_gpa_quality_points                IN     NUMBER,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)

  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pr_stu_acad_stat
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
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.cal_type                          := x_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.stat_type                         := x_stat_type;
    new_references.timeframe                         := x_timeframe;
    new_references.source_type                       := x_source_type;
    new_references.source_reference                  := x_source_reference;
    new_references.attempted_credit_points           := x_attempted_credit_points;
    new_references.earned_credit_points              := x_earned_credit_points;
    new_references.gpa                               := x_gpa;
    new_references.gpa_credit_points                 := x_gpa_credit_points;
    new_references.gpa_quality_points                := x_gpa_quality_points;


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
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.course_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.cal_type= new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.cal_type,
        new_references.ci_sequence_number
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF (((old_references.stat_type = new_references.stat_type)) OR
        ((new_references.stat_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pr_stat_type_pkg.get_pk_for_validation (
                new_references.stat_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;



  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
		x_timeframe                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_stu_acad_stat
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      stat_type = x_stat_type
			AND      timeframe = x_timeframe
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


    PROCEDURE get_fk_igs_en_stdnt_ps_att (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS
      /*
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_pr_stu_acad_stat
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SAS_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
	        CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_en_stdnt_ps_att;

    PROCEDURE get_fk_igs_ca_inst (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_pr_stu_acad_stat
      WHERE    cal_type= x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number;

    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SAS_CI_FK');
      IGS_GE_MSG_STACK.ADD;
	        CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_ca_inst;

    PROCEDURE get_fk_igs_pr_stat_type (
    x_stat_type                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_stu_acad_stat
      WHERE   ((stat_type = x_stat_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PR_SAS_STTY_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pr_stat_type;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_source_reference                  IN     VARCHAR2,
    x_attempted_credit_points           IN     NUMBER,
    x_earned_credit_points              IN     NUMBER,
    x_gpa                               IN     NUMBER,
    x_gpa_credit_points                 IN     NUMBER,
    x_gpa_quality_points                IN     NUMBER,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
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
      x_person_id,
      x_course_cd,
      x_cal_type,
      x_ci_sequence_number,
      x_stat_type,
      x_timeframe,
      x_source_type,
      x_source_reference,
      x_attempted_credit_points,
      x_earned_credit_points,
      x_gpa,
      x_gpa_credit_points,
      x_gpa_quality_points,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.person_id,
             new_references.course_cd,
             new_references.cal_type,
             new_references.ci_sequence_number,
             new_references.stat_type,
             new_references.timeframe)
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.person_id,
             new_references.course_cd,
             new_references.cal_type,
             new_references.ci_sequence_number,
             new_references.stat_type,
             new_references.timeframe
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      END IF;
  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_source_reference                  IN     VARCHAR2,
    x_attempted_credit_points           IN     NUMBER,
    x_earned_credit_points              IN     NUMBER,
    x_gpa                               IN     NUMBER,
    x_gpa_credit_points                 IN     NUMBER,
    x_gpa_quality_points                IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pr_stu_acad_stat
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      stat_type = x_stat_type;

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

    before_dml(
      p_action                              => 'INSERT',
      x_rowid                               => x_rowid,
      x_person_id                           => x_person_id,
      x_course_cd                           => x_course_cd ,
      x_cal_type                            => x_cal_type,
      x_ci_sequence_number                  => x_ci_sequence_number,
      x_stat_type                           => x_stat_type,
      x_timeframe                           => x_timeframe,
      x_source_type                         => x_source_type,
      x_source_reference                    => x_source_reference,
      x_attempted_credit_points             => x_attempted_credit_points,
      x_earned_credit_points                => x_earned_credit_points,
      x_gpa                                 => x_gpa,
      x_gpa_credit_points                   => x_gpa_credit_points,
      x_gpa_quality_points                  => x_gpa_quality_points,
      x_creation_date                       => x_last_update_date,
      x_created_by                          => x_last_updated_by,
      x_last_update_date                    => x_last_update_date,
      x_last_updated_by                     => x_last_updated_by,
      x_last_update_login                   => x_last_update_login
    );

    INSERT INTO igs_pr_stu_acad_stat (
      person_id,
      course_cd,
      cal_type,
      ci_sequence_number,
      stat_type,
      timeframe,
      source_type,
      source_reference,
      attempted_credit_points,
      earned_credit_points,
      gpa,
      gpa_credit_points,
      gpa_quality_points,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.person_id,
      new_references.course_cd,
      new_references.cal_type,
      new_references.ci_sequence_number,
      new_references.stat_type,
      new_references.timeframe,
      new_references.source_type,
      new_references.source_reference,
      new_references.attempted_credit_points,
      new_references.earned_credit_points,
      new_references.gpa,
      new_references.gpa_credit_points,
      new_references.gpa_quality_points,
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_source_reference                  IN     VARCHAR2,
    x_attempted_credit_points           IN     NUMBER,
    x_earned_credit_points              IN     NUMBER,
    x_gpa                               IN     NUMBER,
    x_gpa_credit_points                 IN     NUMBER,
    x_gpa_quality_points                IN     NUMBER
  ) AS
  /*
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
      timeframe,
      source_type,
      source_reference,
      attempted_credit_points,
      earned_credit_points,
      gpa,
      gpa_credit_points,
      gpa_quality_points
      FROM  igs_pr_stu_acad_stat
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
        (tlinfo.timeframe = x_timeframe)
        AND (tlinfo.source_type = x_source_type)
        AND (tlinfo.source_reference = x_source_reference)
        AND (tlinfo.attempted_credit_points = x_attempted_credit_points )
        AND (tlinfo.earned_credit_points = x_earned_credit_points )
        AND (tlinfo.gpa = x_gpa )
        AND (tlinfo.gpa_credit_points = x_gpa_credit_points )
        AND (tlinfo.gpa_quality_points = x_gpa_quality_points )

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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_source_reference                  IN     VARCHAR2,
    x_attempted_credit_points           IN     NUMBER,
    x_earned_credit_points              IN     NUMBER,
    x_gpa                               IN     NUMBER,
    x_gpa_credit_points                 IN     NUMBER,
    x_gpa_quality_points                IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
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
      p_action                              => 'UPDATE',
      x_rowid                               => x_rowid,
      x_person_id                           => x_person_id,
      x_course_cd                           => x_course_cd ,
      x_cal_type                            => x_cal_type,
      x_ci_sequence_number                  => x_ci_sequence_number,
      x_stat_type                           => x_stat_type,
      x_timeframe                           => x_timeframe,
      x_source_type                         => x_source_type,
      x_source_reference                    => x_source_reference,
      x_attempted_credit_points             => x_attempted_credit_points,
      x_earned_credit_points                => x_earned_credit_points,
      x_gpa                                 => x_gpa,
      x_gpa_credit_points                   => x_gpa_credit_points,
      x_gpa_quality_points                  => x_gpa_quality_points,
      x_creation_date                       => x_last_update_date,
      x_created_by                          => x_last_updated_by,
      x_last_update_date                    => x_last_update_date,
      x_last_updated_by                     => x_last_updated_by,
      x_last_update_login                   => x_last_update_login
    );

    UPDATE igs_pr_stu_acad_stat
      SET
      timeframe                 = new_references.timeframe,
      source_type               = new_references.source_type,
      source_reference          = new_references.source_reference,
      attempted_credit_points   = new_references.attempted_credit_points,
      earned_credit_points      = new_references.earned_credit_points,
      gpa                       = new_references.gpa,
      gpa_credit_points         = new_references.gpa_credit_points,
      gpa_quality_points        = new_references.gpa_quality_points,
      last_update_date          = x_last_update_date,
      last_updated_by           = x_last_updated_by,
      last_update_login         = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_source_reference                  IN     VARCHAR2,
    x_attempted_credit_points           IN     NUMBER,
    x_earned_credit_points              IN     NUMBER,
    x_gpa                               IN     NUMBER,
    x_gpa_credit_points                 IN     NUMBER,
    x_gpa_quality_points                IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pr_stu_acad_stat
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      stat_type = x_stat_type
      AND      timeframe = x_timeframe;


  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
    x_rowid,
    x_person_id,
    x_course_cd,
    x_cal_type,
    x_ci_sequence_number,
    x_stat_type,
    x_timeframe,
    x_source_type,
    x_source_reference,
    x_attempted_credit_points,
    x_earned_credit_points,
    x_gpa,
    x_gpa_credit_points,
    x_gpa_quality_points,
    x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
    x_rowid,
    x_person_id,
    x_course_cd,
    x_cal_type,
    x_ci_sequence_number,
    x_stat_type,
    x_timeframe,
    x_source_type,
    x_source_reference,
    x_attempted_credit_points,
    x_earned_credit_points,
    x_gpa,
    x_gpa_credit_points,
    x_gpa_quality_points,
    x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
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

    DELETE FROM igs_pr_stu_acad_stat
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pr_stu_acad_stat_pkg;


/
