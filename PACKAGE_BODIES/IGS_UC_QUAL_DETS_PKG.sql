--------------------------------------------------------
--  DDL for Package Body IGS_UC_QUAL_DETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_QUAL_DETS_PKG" AS
/* $Header: IGSXI37B.pls 120.3 2005/10/17 02:23:43 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_qual_dets%ROWTYPE;
  new_references igs_uc_qual_dets%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_qual_dets_id                      IN     NUMBER       ,
    x_person_id                         IN     NUMBER       ,
    x_exam_level                        IN     VARCHAR2     ,
    x_subject_code                      IN     VARCHAR2     ,
    x_year                              IN     NUMBER       ,
    x_sitting                           IN     VARCHAR2     ,
    x_awarding_body                     IN     VARCHAR2     ,
    x_grading_schema_cd                 IN     VARCHAR2     ,
    x_version_number                    IN     NUMBER       ,
    x_predicted_result                  IN     VARCHAR2     ,
    x_approved_result                   IN     VARCHAR2     ,
    x_claimed_result                    IN     VARCHAR2     ,
    x_ucas_tariff                       IN     NUMBER       ,
    x_imported_flag                     IN     VARCHAR2     ,
    x_imported_date                     IN     DATE         ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_QUAL_DETS
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
    new_references.qual_dets_id                      := x_qual_dets_id;
    new_references.person_id                         := x_person_id;
    new_references.exam_level                        := x_exam_level;
    new_references.subject_code                      := x_subject_code;
    new_references.year                              := x_year;
    new_references.sitting                           := x_sitting;
    new_references.awarding_body                     := x_awarding_body;
    new_references.grading_schema_cd                 := x_grading_schema_cd;
    new_references.version_number                    := x_version_number;
    new_references.predicted_result                  := x_predicted_result;
    new_references.approved_result                   := x_approved_result;
    new_references.claimed_result                    := x_claimed_result;
    new_references.ucas_tariff                       := x_ucas_tariff;
    new_references.imported_flag                     := x_imported_flag;
    new_references.imported_date                     := x_imported_date;

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
  ||  Created By : rbezawad
  ||  Created On : 23-MAY-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.person_id,
           new_references.exam_level,
           new_references.subject_code,
           new_references.year,
           new_references.sitting,
           new_references.awarding_body,
           new_references.approved_result
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_PE_QUAL_DUP_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_approved_result                   IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rbezawad
  ||  Created On : 23-MAY-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali  11-jun-2002 added new field approved result to procedure
  ||      get_uk_for_validation for bug 2409543
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_qual_dets
      WHERE    person_id = x_person_id
      AND      exam_level = x_exam_level
      AND      ((subject_code = x_subject_code) OR (subject_code IS NULL AND x_subject_code IS NULL))
      AND      ((year = x_year) OR (year IS NULL AND x_year IS NULL))
      AND      ((sitting = x_sitting) OR (sitting IS NULL AND x_sitting IS NULL))
      AND      ((awarding_body = x_awarding_body) OR (awarding_body IS NULL AND x_awarding_body IS NULL))
      AND      ( (approved_result = x_approved_result) OR (approved_result IS NULL AND x_approved_result IS NULL) )
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

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverSE chronological order - newest change first)
  ||  smaddali  27-jun-2002     bug 2430139 modified the calls to patent tbhs by passing UPPER of columns
  ||                              grading_schema_cd, approved_result,claimd_result,predicted_result,exam_level,subject_code
  ||                              also trimming the result fields
  ||  rbezawad  16-Dec-2002     1) Changed FK relation get_fk_pe_hz_parties to get_fk_igs_pe_person.  So changed the get_pk...() call from igs_pe_hz_parties_pkg to igs_pe_person_pkg.
  ||                            2) Removed the commented code which was checking awarding_body column value.
  ||                            3) Uncommented the code which was checking subject_code value in igs_ps_fld_of_study_all_pkg.
  ||                            Modifications are done w.r.t. Bug 2541370.
  */
  BEGIN

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.claimed_result = new_references.claimed_result)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.claimed_result IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                UPPER(TRIM(new_references.grading_schema_cd)),
                new_references.version_number,
                UPPER(TRIM(new_references.claimed_result))
              ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_GRD_SCHEMA_CLAIM_RSLT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.predicted_result = new_references.predicted_result)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.predicted_result IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                UPPER(TRIM(new_references.grading_schema_cd)),
                new_references.version_number,
                UPPER(TRIM(new_references.predicted_result))
              ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_GRD_SCHEMA_PRD_RSLT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.approved_result = new_references.approved_result)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.approved_result IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                UPPER(TRIM(new_references.grading_schema_cd)),
                new_references.version_number,
                UPPER(TRIM(new_references.approved_result))
              ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_GRD_SCHEMA_APRD_RSLT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.exam_level = new_references.exam_level)) OR
        ((new_references.exam_level IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_awd_pkg.get_pk_for_validation (
                UPPER(TRIM(new_references.exam_level))
              ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_EXAM_LEVEL'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.subject_code = new_references.subject_code)) OR
        ((new_references.subject_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_fld_of_study_pkg.get_pk_for_validation (
                UPPER(TRIM(new_references.subject_code))
              ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SUBJECT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.person_id
              ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END check_parent_existance;


  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_AV_STND_UNIT_LVL_PKG.GET_FK_IGS_UC_QUAL_DETS(
      old_references.QUAL_DETS_ID
      );
  END Check_Child_Existance;



  FUNCTION get_pk_for_validation (
    x_qual_dets_id                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_qual_dets
      WHERE    qual_dets_id = x_qual_dets_id;

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


  PROCEDURE get_fk_igs_as_grd_sch_grade (
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_grade                             IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_qual_dets
      WHERE   ((claimed_result = x_grade) AND
               (grading_schema_cd = x_grading_schema_cd) AND
               (version_number = x_version_number))
      OR      ((grading_schema_cd = x_grading_schema_cd) AND
               (predicted_result = x_grade) AND
               (version_number = x_version_number))
      OR      ((approved_result = x_grade) AND
               (grading_schema_cd = x_grading_schema_cd) AND
               (version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_grd_sch_grade;


  PROCEDURE get_fk_igs_ps_awd (
    x_award_cd                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_qual_dets
      WHERE   ((exam_level = x_award_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_awd;


  PROCEDURE get_fk_igs_ps_fld_of_study_all (
    x_field_of_study                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_qual_dets
      WHERE   ((subject_code = x_field_of_study));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_fld_of_study_all;


  PROCEDURE get_ufk_hz_parties (
    x_party_number                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_qual_dets
      WHERE   ((awarding_body = x_party_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_hz_parties;


  PROCEDURE get_fk_igs_pe_person (
    x_person_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||   rbezawad     16-Dec-2002    Changed FK relation get_fk_pe_hz_parties to
  ||                                get_fk_igs_pe_person w.r.t. Bug 2541370.
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_qual_dets
      WHERE   ((person_id = x_person_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_person;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_qual_dets_id                      IN     NUMBER       ,
    x_person_id                         IN     NUMBER       ,
    x_exam_level                        IN     VARCHAR2     ,
    x_subject_code                      IN     VARCHAR2     ,
    x_year                              IN     NUMBER       ,
    x_sitting                           IN     VARCHAR2     ,
    x_awarding_body                     IN     VARCHAR2     ,
    x_grading_schema_cd                 IN     VARCHAR2     ,
    x_version_number                    IN     NUMBER       ,
    x_predicted_result                  IN     VARCHAR2     ,
    x_approved_result                   IN     VARCHAR2     ,
    x_claimed_result                    IN     VARCHAR2     ,
    x_ucas_tariff                       IN     NUMBER       ,
    x_imported_flag                     IN     VARCHAR2     ,
    x_imported_date                     IN     DATE         ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
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
      x_qual_dets_id,
      x_person_id,
      x_exam_level,
      x_subject_code,
      x_year,
      x_sitting,
      x_awarding_body,
      x_grading_schema_cd,
      x_version_number,
      x_predicted_result,
      x_approved_result,
      x_claimed_result,
      x_ucas_tariff,
      x_imported_flag,
      x_imported_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.qual_dets_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.qual_dets_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
              Check_Child_Existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_qual_dets_id                      IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_approved_result                   IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_ucas_tariff                       IN     NUMBER,
    x_imported_flag                     IN     VARCHAR2,
    x_imported_date                     IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_qual_dets
      WHERE    qual_dets_id                      = x_qual_dets_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
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

    SELECT    igs_uc_qual_dets_s.NEXTVAL
    INTO      x_qual_dets_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_qual_dets_id                      => x_qual_dets_id,
      x_person_id                         => x_person_id,
      x_exam_level                        => x_exam_level,
      x_subject_code                      => x_subject_code,
      x_year                              => x_year,
      x_sitting                           => x_sitting,
      x_awarding_body                     => x_awarding_body,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_version_number                    => x_version_number,
      x_predicted_result                  => x_predicted_result,
      x_approved_result                   => x_approved_result,
      x_claimed_result                    => x_claimed_result,
      x_ucas_tariff                       => x_ucas_tariff,
      x_imported_flag                     => x_imported_flag,
      x_imported_date                     => x_imported_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_uc_qual_dets (
      qual_dets_id,
      person_id,
      exam_level,
      subject_code,
      year,
      sitting,
      awarding_body,
      grading_schema_cd,
      version_number,
      predicted_result,
      approved_result,
      claimed_result,
      ucas_tariff,
      imported_flag,
      imported_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.qual_dets_id,
      new_references.person_id,
      new_references.exam_level,
      new_references.subject_code,
      new_references.year,
      new_references.sitting,
      new_references.awarding_body,
      new_references.grading_schema_cd,
      new_references.version_number,
      new_references.predicted_result,
      new_references.approved_result,
      new_references.claimed_result,
      new_references.ucas_tariff,
      new_references.imported_flag,
      new_references.imported_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_qual_dets_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_approved_result                   IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_ucas_tariff                       IN     NUMBER,
    x_imported_flag                     IN     VARCHAR2,
    x_imported_date                     IN     DATE
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        exam_level,
        subject_code,
        year,
        sitting,
        awarding_body,
        grading_schema_cd,
        version_number,
        predicted_result,
        approved_result,
        claimed_result,
        ucas_tariff,
        imported_flag,
        imported_date
      FROM  igs_uc_qual_dets
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
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.exam_level = x_exam_level)
        AND ((tlinfo.subject_code = x_subject_code) OR ((tlinfo.subject_code IS NULL) AND (X_subject_code IS NULL)))
        AND ((tlinfo.year = x_year) OR ((tlinfo.year IS NULL) AND (X_year IS NULL)))
        AND ((tlinfo.sitting = x_sitting) OR ((tlinfo.sitting IS NULL) AND (X_sitting IS NULL)))
        AND ((tlinfo.awarding_body = x_awarding_body) OR ((tlinfo.awarding_body IS NULL) AND (X_awarding_body IS NULL)))
        AND ((tlinfo.grading_schema_cd = x_grading_schema_cd) OR ((tlinfo.grading_schema_cd IS NULL) AND (X_grading_schema_cd IS NULL)))
        AND ((tlinfo.version_number = x_version_number) OR ((tlinfo.version_number IS NULL) AND (X_version_number IS NULL)))
        AND ((tlinfo.predicted_result = x_predicted_result) OR ((tlinfo.predicted_result IS NULL) AND (X_predicted_result IS NULL)))
        AND ((tlinfo.approved_result = x_approved_result) OR ((tlinfo.approved_result IS NULL) AND (X_approved_result IS NULL)))
        AND ((tlinfo.claimed_result = x_claimed_result) OR ((tlinfo.claimed_result IS NULL) AND (X_claimed_result IS NULL)))
        AND ((tlinfo.ucas_tariff = x_ucas_tariff) OR ((tlinfo.ucas_tariff IS NULL) AND (X_ucas_tariff IS NULL)))
        AND ((tlinfo.imported_flag = x_imported_flag) OR ((tlinfo.imported_flag IS NULL) AND (X_imported_flag IS NULL)))
        AND (tlinfo.imported_date = x_imported_date)
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
    x_qual_dets_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_approved_result                   IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_ucas_tariff                       IN     NUMBER,
    x_imported_flag                     IN     VARCHAR2,
    x_imported_date                     IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
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
    ELSIF (X_MODE IN ('R', 'S')) THEN
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
      x_qual_dets_id                      => x_qual_dets_id,
      x_person_id                         => x_person_id,
      x_exam_level                        => x_exam_level,
      x_subject_code                      => x_subject_code,
      x_year                              => x_year,
      x_sitting                           => x_sitting,
      x_awarding_body                     => x_awarding_body,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_version_number                    => x_version_number,
      x_predicted_result                  => x_predicted_result,
      x_approved_result                   => x_approved_result,
      x_claimed_result                    => x_claimed_result,
      x_ucas_tariff                       => x_ucas_tariff,
      x_imported_flag                     => x_imported_flag,
      x_imported_date                     => x_imported_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_uc_qual_dets
      SET
        person_id                         = new_references.person_id,
        exam_level                        = new_references.exam_level,
        subject_code                      = new_references.subject_code,
        year                              = new_references.year,
        sitting                           = new_references.sitting,
        awarding_body                     = new_references.awarding_body,
        grading_schema_cd                 = new_references.grading_schema_cd,
        version_number                    = new_references.version_number,
        predicted_result                  = new_references.predicted_result,
        approved_result                   = new_references.approved_result,
        claimed_result                    = new_references.claimed_result,
        ucas_tariff                       = new_references.ucas_tariff,
        imported_flag                     = new_references.imported_flag,
        imported_date                     = new_references.imported_date,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE = (-28115)) THEN
        fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
        fnd_message.set_token ('ERR_CD', SQLCODE);
        igs_ge_msg_stack.add;
        igs_sc_gen_001.unset_ctx('R');
        app_exception.raise_exception;
      ELSE
        igs_sc_gen_001.unset_ctx('R');
        RAISE;
      END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_qual_dets_id                      IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_exam_level                        IN     VARCHAR2,
    x_subject_code                      IN     VARCHAR2,
    x_year                              IN     NUMBER,
    x_sitting                           IN     VARCHAR2,
    x_awarding_body                     IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_predicted_result                  IN     VARCHAR2,
    x_approved_result                   IN     VARCHAR2,
    x_claimed_result                    IN     VARCHAR2,
    x_ucas_tariff                       IN     NUMBER,
    x_imported_flag                     IN     VARCHAR2,
    x_imported_date                     IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_qual_dets
      WHERE    qual_dets_id                      = x_qual_dets_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_qual_dets_id,
        x_person_id,
        x_exam_level,
        x_subject_code,
        x_year,
        x_sitting,
        x_awarding_body,
        x_grading_schema_cd,
        x_version_number,
        x_predicted_result,
        x_approved_result,
        x_claimed_result,
        x_ucas_tariff,
        x_imported_flag,
        x_imported_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_qual_dets_id,
      x_person_id,
      x_exam_level,
      x_subject_code,
      x_year,
      x_sitting,
      x_awarding_body,
      x_grading_schema_cd,
      x_version_number,
      x_predicted_result,
      x_approved_result,
      x_claimed_result,
      x_ucas_tariff,
      x_imported_flag,
      x_imported_date,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 12-FEB-2002
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

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_uc_qual_dets
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  END delete_row;


END igs_uc_qual_dets_pkg;

/
