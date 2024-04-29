--------------------------------------------------------
--  DDL for Package Body IGS_PR_COHINST_RANK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_COHINST_RANK_PKG" AS
/* $Header: IGSQI43B.pls 120.0 2005/07/05 12:06:37 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pr_cohinst_rank%ROWTYPE;
  new_references igs_pr_cohinst_rank%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_as_of_rank_gpa                    IN     NUMBER,
    x_cohort_rank                       IN     NUMBER,
    x_cohort_override_rank              IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pr_cohinst_rank
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
    new_references.cohort_name                       := x_cohort_name;
    new_references.load_cal_type                     := x_load_cal_type;
    new_references.load_ci_sequence_number           := x_load_ci_sequence_number;
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.as_of_rank_gpa                    := x_as_of_rank_gpa;
    new_references.cohort_rank                       := x_cohort_rank;
    new_references.cohort_override_rank              := x_cohort_override_rank;
    new_references.comments                          := x_comments;

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
  ||  Created On : 30-OCT-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.cohort_name = new_references.cohort_name) AND
         (old_references.load_cal_type = new_references.load_cal_type) AND
         (old_references.load_ci_sequence_number = new_references.load_ci_sequence_number)) OR
        ((new_references.cohort_name IS NULL) OR
         (new_references.load_cal_type IS NULL) OR
         (new_references.load_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pr_cohort_inst_pkg.get_pk_for_validation (
                new_references.cohort_name,
                new_references.load_cal_type,
                new_references.load_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

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

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_cohinst_rank
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      cohort_name = x_cohort_name
      AND      load_cal_type = x_load_cal_type
      AND      load_ci_sequence_number = x_load_ci_sequence_number
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

  PROCEDURE get_fk_igs_pr_cohort_inst (
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_cohinst_rank
      WHERE   ((cohort_name = x_cohort_name) AND
               (load_cal_type = x_load_cal_type) AND
               (load_ci_sequence_number = x_load_ci_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PR_COHI_COHIR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pr_cohort_inst;


  PROCEDURE get_fk_igs_en_stdnt_ps_att (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_cohinst_rank
      WHERE   ((course_cd = x_course_cd) AND
               (person_id = x_person_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PR_COHIR_SPA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_stdnt_ps_att;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_as_of_rank_gpa                    IN     NUMBER,
    x_cohort_rank                       IN     NUMBER,
    x_cohort_override_rank              IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
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
      x_cohort_name,
      x_load_cal_type,
      x_load_ci_sequence_number,
      x_person_id,
      x_course_cd,
      x_as_of_rank_gpa,
      x_cohort_rank,
      x_cohort_override_rank,
      x_comments,
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
             new_references.cohort_name,
             new_references.load_cal_type,
             new_references.load_ci_sequence_number
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
             new_references.person_id,
             new_references.course_cd,
             new_references.cohort_name,
             new_references.load_cal_type,
             new_references.load_ci_sequence_number
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
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_as_of_rank_gpa                    IN     NUMBER,
    x_cohort_rank                       IN     NUMBER,
    x_cohort_override_rank              IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_cohort_name                       => x_cohort_name,
      x_load_cal_type                     => x_load_cal_type,
      x_load_ci_sequence_number           => x_load_ci_sequence_number,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_as_of_rank_gpa                    => x_as_of_rank_gpa,
      x_cohort_rank                       => x_cohort_rank,
      x_cohort_override_rank              => x_cohort_override_rank,
      x_comments                          => x_comments,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_pr_cohinst_rank (
      cohort_name,
      load_cal_type,
      load_ci_sequence_number,
      person_id,
      course_cd,
      as_of_rank_gpa,
      cohort_rank,
      cohort_override_rank,
      comments,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      new_references.cohort_name,
      new_references.load_cal_type,
      new_references.load_ci_sequence_number,
      new_references.person_id,
      new_references.course_cd,
      new_references.as_of_rank_gpa,
      new_references.cohort_rank,
      new_references.cohort_override_rank,
      new_references.comments,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_as_of_rank_gpa                    IN     NUMBER,
    x_cohort_rank                       IN     NUMBER,
    x_cohort_override_rank              IN     NUMBER,
    x_comments                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        as_of_rank_gpa,
        cohort_rank,
        cohort_override_rank,
        comments
      FROM  igs_pr_cohinst_rank
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
        (tlinfo.as_of_rank_gpa = x_as_of_rank_gpa)
        AND (tlinfo.cohort_rank = x_cohort_rank)
        AND ((tlinfo.cohort_override_rank = x_cohort_override_rank) OR ((tlinfo.cohort_override_rank IS NULL) AND (X_cohort_override_rank IS NULL)))
        AND ((tlinfo.comments = x_comments) OR ((tlinfo.comments IS NULL) AND (X_comments IS NULL)))
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
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_as_of_rank_gpa                    IN     NUMBER,
    x_cohort_rank                       IN     NUMBER,
    x_cohort_override_rank              IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
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
      x_cohort_name                       => x_cohort_name,
      x_load_cal_type                     => x_load_cal_type,
      x_load_ci_sequence_number           => x_load_ci_sequence_number,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_as_of_rank_gpa                    => x_as_of_rank_gpa,
      x_cohort_rank                       => x_cohort_rank,
      x_cohort_override_rank              => x_cohort_override_rank,
      x_comments                          => x_comments,
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

    UPDATE igs_pr_cohinst_rank
      SET
        as_of_rank_gpa                    = new_references.as_of_rank_gpa,
        cohort_rank                       = new_references.cohort_rank,
        cohort_override_rank              = new_references.cohort_override_rank,
        comments                          = new_references.comments,
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

  -- raise business event whenever there is a change in override rank or override
  -- rank is given
  DECLARE
    -- cursor to fetch person details
    CURSOR c_pers (cp_person_id igs_pe_person.person_id%TYPE) IS
           SELECT person_number, full_name
	   FROM   igs_pe_person_base_v
	   WHERE  person_id = cp_person_id;
    rec_pers  c_pers%ROWTYPE;
    rec_admin c_pers%ROWTYPE;

    CURSOR c_fnd IS
           SELECT distinct person_party_id
	   FROm FND_USER
	   WHERE user_id = FND_GLOBAL.USER_ID;
    l_person_party_id fnd_user.person_party_id%TYPE;

    CURSOR c_meaning IS
           SELECT meaning
           FROM igs_lookups_view
           WHERE lookup_code = 'ADMIN'
           AND   lookup_type = 'IGS_PT_SS_ROLE_TYPES';
    l_meaning c_meaning%ROWTYPE;

  BEGIN
    IF  new_references.cohort_override_rank IS NOT NULL AND
       (new_references.cohort_override_rank <> old_references.cohort_override_rank OR
       (new_references.cohort_override_rank IS NOT NULL AND old_references.cohort_override_rank IS NULL)) THEN
          OPEN c_fnd;
	  FETCH c_fnd INTO l_person_party_id;
	  CLOSE c_fnd;
	  OPEN c_pers (new_references.person_id);
	  FETCH c_pers INTO rec_pers;
	  CLOSE c_pers;
	  OPEN c_pers (l_person_party_id);
	  FETCH c_pers INTO rec_admin;
	  CLOSE c_pers;
          OPEN c_meaning;
          FETCH  c_meaning INTO l_meaning;
          CLOSE c_meaning;

          IGS_PR_CLASS_RANK.RAISE_CLSRANK_BE_CR002 (
               P_PERSON_ID                   => new_references.person_id,
	       P_PERSON_NUMBER               => rec_pers.person_number,
	       P_PERSON_NAME                 => rec_pers.full_name,
	       P_CURRENT_RANK                => new_references.cohort_rank,
	       P_OVERRIDE_RANK               => new_references.cohort_override_rank,
	       P_OVRBY_PERSON_ID             => FND_GLOBAL.USER_ID,
	       P_OVRBY_PERSON_NUMBER         => rec_admin.person_number,
	       P_OVRBY_PERSON_NAME           => NVL(rec_admin.full_name,l_meaning.meaning)
						  );
      END IF;
    END;


  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_as_of_rank_gpa                    IN     NUMBER,
    x_cohort_rank                       IN     NUMBER,
    x_cohort_override_rank              IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pr_cohinst_rank
      WHERE    person_id                         = x_person_id
      AND      course_cd                         = x_course_cd
      AND      cohort_name                       = x_cohort_name
      AND      load_cal_type                     = x_load_cal_type
      AND      load_ci_sequence_number           = x_load_ci_sequence_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_cohort_name,
        x_load_cal_type,
        x_load_ci_sequence_number,
        x_person_id,
        x_course_cd,
        x_as_of_rank_gpa,
        x_cohort_rank,
        x_cohort_override_rank,
        x_comments,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_cohort_name,
      x_load_cal_type,
      x_load_ci_sequence_number,
      x_person_id,
      x_course_cd,
      x_as_of_rank_gpa,
      x_cohort_rank,
      x_cohort_override_rank,
      x_comments,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 30-OCT-2002
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

    DELETE FROM igs_pr_cohinst_rank
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pr_cohinst_rank_pkg;

/
