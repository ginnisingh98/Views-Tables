--------------------------------------------------------
--  DDL for Package Body IGS_HE_STDNT_DLHE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_STDNT_DLHE_PKG" AS
/* $Header: IGSWI38B.pls 120.1 2005/08/31 22:52:29 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_stdnt_dlhe%ROWTYPE;
  new_references igs_he_stdnt_dlhe%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_dlhe_record_status                IN     VARCHAR2,
    x_participant_source                IN     VARCHAR2,
    x_date_status_changed               IN     DATE,
    x_validation_status                 IN     VARCHAR2,
    x_admin_coding                      IN     VARCHAR2,
    x_survey_method                     IN     VARCHAR2,
    x_employment                        IN     VARCHAR2,
    x_further_study                     IN     VARCHAR2,
    x_qualified_teacher                 IN     VARCHAR2,
    x_pt_study                          IN     VARCHAR2,
    x_employer_business                 IN     VARCHAR2,
    x_employer_name                     IN     VARCHAR2,
    x_employer_classification           IN     VARCHAR2,
    x_employer_location                 IN     VARCHAR2,
    x_employer_postcode                 IN     VARCHAR2,
    x_employer_country                  IN     VARCHAR2,
    x_job_title                         IN     VARCHAR2,
    x_job_duties                        IN     VARCHAR2,
    x_job_classification                IN     VARCHAR2,
    x_employer_size                     IN     VARCHAR2,
    x_job_duration                      IN     VARCHAR2,
    x_job_salary                        IN     NUMBER,
    x_salary_refused                    IN     VARCHAR2,
    x_qualification_requirement         IN     VARCHAR2,
    x_qualification_importance          IN     VARCHAR2,
    x_job_reason1                       IN     VARCHAR2,
    x_job_reason2                       IN     VARCHAR2,
    x_job_reason3                       IN     VARCHAR2,
    x_job_reason4                       IN     VARCHAR2,
    x_job_reason5                       IN     VARCHAR2,
    x_job_reason6                       IN     VARCHAR2,
    x_job_reason7                       IN     VARCHAR2,
    x_job_reason8                       IN     VARCHAR2,
    x_other_job_reason                  IN     VARCHAR2,
    x_no_other_job_reason               IN     VARCHAR2,
    x_job_source                        IN     VARCHAR2,
    x_other_job_source                  IN     VARCHAR2,
    x_no_other_job_source               IN     VARCHAR2,
    x_previous_job                      IN     VARCHAR2,
    x_previous_jobtype1                 IN     VARCHAR2,
    x_previous_jobtype2                 IN     VARCHAR2,
    x_previous_jobtype3                 IN     VARCHAR2,
    x_previous_jobtype4                 IN     VARCHAR2,
    x_previous_jobtype5                 IN     VARCHAR2,
    x_previous_jobtype6                 IN     VARCHAR2,
    x_further_study_type                IN     VARCHAR2,
    x_course_name                       IN     VARCHAR2,
    x_course_training_subject           IN     VARCHAR2,
    x_research_subject                  IN     VARCHAR2,
    x_research_training_subject         IN     VARCHAR2,
    x_further_study_provider            IN     VARCHAR2,
    x_further_study_qualaim             IN     VARCHAR2,
    x_professional_qualification        IN     VARCHAR2,
    x_study_reason1                     IN     VARCHAR2,
    x_study_reason2                     IN     VARCHAR2,
    x_study_reason3                     IN     VARCHAR2,
    x_study_reason4                     IN     VARCHAR2,
    x_study_reason5                     IN     VARCHAR2,
    x_study_reason6                     IN     VARCHAR2,
    x_study_reason7                     IN     VARCHAR2,
    x_other_study_reason                IN     VARCHAR2,
    x_no_other_study_reason             IN     VARCHAR2,
    x_employer_sponsored                IN     VARCHAR2,
    x_funding_source                    IN     VARCHAR2,
    x_teacher_teaching                  IN     VARCHAR2,
    x_teacher_seeking                   IN     VARCHAR2,
    x_teaching_sector                   IN     VARCHAR2,
    x_teaching_level                    IN     VARCHAR2,
    x_reason_for_ptcourse               IN     VARCHAR2,
    x_job_while_studying                IN     VARCHAR2,
    x_employer_support1                 IN     VARCHAR2,
    x_employer_support2                 IN     VARCHAR2,
    x_employer_support3                 IN     VARCHAR2,
    x_employer_support4                 IN     VARCHAR2,
    x_employer_support5                 IN     VARCHAR2,
    x_popdlhe_flag                      IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prasada.marada@oracle.com
  ||  Created On : 17-APR-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_he_stdnt_dlhe
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
    new_references.submission_name                   := x_submission_name;
    new_references.user_return_subclass              := x_user_return_subclass;
    new_references.return_name                       := x_return_name;
    new_references.qual_period_code                  := x_qual_period_code;
    new_references.dlhe_record_status                := x_dlhe_record_status;
    new_references.participant_source                := x_participant_source;
    new_references.date_status_changed               := x_date_status_changed;
    new_references.validation_status                 := x_validation_status;
    new_references.admin_coding                      := x_admin_coding;
    new_references.survey_method                     := x_survey_method;
    new_references.employment                        := x_employment;
    new_references.further_study                     := x_further_study;
    new_references.qualified_teacher                 := x_qualified_teacher;
    new_references.pt_study                          := x_pt_study;
    new_references.employer_business                 := x_employer_business;
    new_references.employer_name                     := x_employer_name;
    new_references.employer_classification           := x_employer_classification;
    new_references.employer_location                 := x_employer_location;
    new_references.employer_postcode                 := x_employer_postcode;
    new_references.employer_country                  := x_employer_country;
    new_references.job_title                         := x_job_title;
    new_references.job_duties                        := x_job_duties;
    new_references.job_classification                := x_job_classification;
    new_references.employer_size                     := x_employer_size;
    new_references.job_duration                      := x_job_duration;
    new_references.job_salary                        := x_job_salary;
    new_references.salary_refused                    := x_salary_refused;
    new_references.qualification_requirement         := x_qualification_requirement;
    new_references.qualification_importance          := x_qualification_importance;
    new_references.job_reason1                       := x_job_reason1;
    new_references.job_reason2                       := x_job_reason2;
    new_references.job_reason3                       := x_job_reason3;
    new_references.job_reason4                       := x_job_reason4;
    new_references.job_reason5                       := x_job_reason5;
    new_references.job_reason6                       := x_job_reason6;
    new_references.job_reason7                       := x_job_reason7;
    new_references.job_reason8                       := x_job_reason8;
    new_references.other_job_reason                  := x_other_job_reason;
    new_references.no_other_job_reason               := x_no_other_job_reason;
    new_references.job_source                        := x_job_source;
    new_references.other_job_source                  := x_other_job_source;
    new_references.no_other_job_source               := x_no_other_job_source;
    new_references.previous_job                      := x_previous_job;
    new_references.previous_jobtype1                 := x_previous_jobtype1;
    new_references.previous_jobtype2                 := x_previous_jobtype2;
    new_references.previous_jobtype3                 := x_previous_jobtype3;
    new_references.previous_jobtype4                 := x_previous_jobtype4;
    new_references.previous_jobtype5                 := x_previous_jobtype5;
    new_references.previous_jobtype6                 := x_previous_jobtype6;
    new_references.further_study_type                := x_further_study_type;
    new_references.course_name                       := x_course_name;
    new_references.course_training_subject           := x_course_training_subject;
    new_references.research_subject                  := x_research_subject;
    new_references.research_training_subject         := x_research_training_subject;
    new_references.further_study_provider            := x_further_study_provider;
    new_references.further_study_qualaim             := x_further_study_qualaim;
    new_references.professional_qualification        := x_professional_qualification;
    new_references.study_reason1                     := x_study_reason1;
    new_references.study_reason2                     := x_study_reason2;
    new_references.study_reason3                     := x_study_reason3;
    new_references.study_reason4                     := x_study_reason4;
    new_references.study_reason5                     := x_study_reason5;
    new_references.study_reason6                     := x_study_reason6;
    new_references.study_reason7                     := x_study_reason7;
    new_references.other_study_reason                := x_other_study_reason;
    new_references.no_other_study_reason             := x_no_other_study_reason;
    new_references.employer_sponsored                := x_employer_sponsored;
    new_references.funding_source                    := x_funding_source;
    new_references.teacher_teaching                  := x_teacher_teaching;
    new_references.teacher_seeking                   := x_teacher_seeking;
    new_references.teaching_sector                   := x_teaching_sector;
    new_references.teaching_level                    := x_teaching_level;
    new_references.reason_for_ptcourse               := x_reason_for_ptcourse;
    new_references.job_while_studying                := x_job_while_studying;
    new_references.employer_support1                 := x_employer_support1;
    new_references.employer_support2                 := x_employer_support2;
    new_references.employer_support3                 := x_employer_support3;
    new_references.employer_support4                 := x_employer_support4;
    new_references.employer_support5                 := x_employer_support5;
    new_references.popdlhe_flag                      := x_popdlhe_flag;

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
  ||  Created By : prasada.marada@oracle.com
  ||  Created On : 17-APR-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.submission_name = new_references.submission_name) AND
         (old_references.user_return_subclass = new_references.user_return_subclass) AND
         (old_references.return_name = new_references.return_name) AND
         (old_references.qual_period_code = new_references.qual_period_code)) OR
        ((new_references.submission_name IS NULL) OR
         (new_references.user_return_subclass IS NULL) OR
         (new_references.return_name IS NULL) OR
         (new_references.qual_period_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_he_sub_rtn_qual_pkg.get_pk_for_validation (
                new_references.submission_name,
                new_references.user_return_subclass,
                new_references.return_name,
                new_references.qual_period_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_submission_name                   IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prasada.marada@oracle.com
  ||  Created On : 17-APR-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_stdnt_dlhe
      WHERE    submission_name = x_submission_name
      AND      return_name = x_return_name
      AND      person_id = x_person_id
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


  PROCEDURE get_fk_igs_he_sub_rtn_qual (
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prasada.marada@oracle.com
  ||  Created On : 17-APR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_stdnt_dlhe
      WHERE   ((qual_period_code = x_qual_period_code) AND
               (return_name = x_return_name) AND
               (submission_name = x_submission_name) AND
               (user_return_subclass = x_user_return_subclass));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HDLHE_HSRQ_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_he_sub_rtn_qual;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_dlhe_record_status                IN     VARCHAR2,
    x_participant_source                IN     VARCHAR2,
    x_date_status_changed               IN     DATE,
    x_validation_status                 IN     VARCHAR2,
    x_admin_coding                      IN     VARCHAR2,
    x_survey_method                     IN     VARCHAR2,
    x_employment                        IN     VARCHAR2,
    x_further_study                     IN     VARCHAR2,
    x_qualified_teacher                 IN     VARCHAR2,
    x_pt_study                          IN     VARCHAR2,
    x_employer_business                 IN     VARCHAR2,
    x_employer_name                     IN     VARCHAR2,
    x_employer_classification           IN     VARCHAR2,
    x_employer_location                 IN     VARCHAR2,
    x_employer_postcode                 IN     VARCHAR2,
    x_employer_country                  IN     VARCHAR2,
    x_job_title                         IN     VARCHAR2,
    x_job_duties                        IN     VARCHAR2,
    x_job_classification                IN     VARCHAR2,
    x_employer_size                     IN     VARCHAR2,
    x_job_duration                      IN     VARCHAR2,
    x_job_salary                        IN     NUMBER,
    x_salary_refused                    IN     VARCHAR2,
    x_qualification_requirement         IN     VARCHAR2,
    x_qualification_importance          IN     VARCHAR2,
    x_job_reason1                       IN     VARCHAR2,
    x_job_reason2                       IN     VARCHAR2,
    x_job_reason3                       IN     VARCHAR2,
    x_job_reason4                       IN     VARCHAR2,
    x_job_reason5                       IN     VARCHAR2,
    x_job_reason6                       IN     VARCHAR2,
    x_job_reason7                       IN     VARCHAR2,
    x_job_reason8                       IN     VARCHAR2,
    x_other_job_reason                  IN     VARCHAR2,
    x_no_other_job_reason               IN     VARCHAR2,
    x_job_source                        IN     VARCHAR2,
    x_other_job_source                  IN     VARCHAR2,
    x_no_other_job_source               IN     VARCHAR2,
    x_previous_job                      IN     VARCHAR2,
    x_previous_jobtype1                 IN     VARCHAR2,
    x_previous_jobtype2                 IN     VARCHAR2,
    x_previous_jobtype3                 IN     VARCHAR2,
    x_previous_jobtype4                 IN     VARCHAR2,
    x_previous_jobtype5                 IN     VARCHAR2,
    x_previous_jobtype6                 IN     VARCHAR2,
    x_further_study_type                IN     VARCHAR2,
    x_course_name                       IN     VARCHAR2,
    x_course_training_subject           IN     VARCHAR2,
    x_research_subject                  IN     VARCHAR2,
    x_research_training_subject         IN     VARCHAR2,
    x_further_study_provider            IN     VARCHAR2,
    x_further_study_qualaim             IN     VARCHAR2,
    x_professional_qualification        IN     VARCHAR2,
    x_study_reason1                     IN     VARCHAR2,
    x_study_reason2                     IN     VARCHAR2,
    x_study_reason3                     IN     VARCHAR2,
    x_study_reason4                     IN     VARCHAR2,
    x_study_reason5                     IN     VARCHAR2,
    x_study_reason6                     IN     VARCHAR2,
    x_study_reason7                     IN     VARCHAR2,
    x_other_study_reason                IN     VARCHAR2,
    x_no_other_study_reason             IN     VARCHAR2,
    x_employer_sponsored                IN     VARCHAR2,
    x_funding_source                    IN     VARCHAR2,
    x_teacher_teaching                  IN     VARCHAR2,
    x_teacher_seeking                   IN     VARCHAR2,
    x_teaching_sector                   IN     VARCHAR2,
    x_teaching_level                    IN     VARCHAR2,
    x_reason_for_ptcourse               IN     VARCHAR2,
    x_job_while_studying                IN     VARCHAR2,
    x_employer_support1                 IN     VARCHAR2,
    x_employer_support2                 IN     VARCHAR2,
    x_employer_support3                 IN     VARCHAR2,
    x_employer_support4                 IN     VARCHAR2,
    x_employer_support5                 IN     VARCHAR2,
    x_popdlhe_flag                      IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prasada.marada@oracle.com
  ||  Created On : 17-APR-2003
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
      x_submission_name,
      x_user_return_subclass,
      x_return_name,
      x_qual_period_code,
      x_dlhe_record_status,
      x_participant_source,
      x_date_status_changed,
      x_validation_status,
      x_admin_coding,
      x_survey_method,
      x_employment,
      x_further_study,
      x_qualified_teacher,
      x_pt_study,
      x_employer_business,
      x_employer_name,
      x_employer_classification,
      x_employer_location,
      x_employer_postcode,
      x_employer_country,
      x_job_title,
      x_job_duties,
      x_job_classification,
      x_employer_size,
      x_job_duration,
      x_job_salary,
      x_salary_refused,
      x_qualification_requirement,
      x_qualification_importance,
      x_job_reason1,
      x_job_reason2,
      x_job_reason3,
      x_job_reason4,
      x_job_reason5,
      x_job_reason6,
      x_job_reason7,
      x_job_reason8,
      x_other_job_reason,
      x_no_other_job_reason,
      x_job_source,
      x_other_job_source,
      x_no_other_job_source,
      x_previous_job,
      x_previous_jobtype1,
      x_previous_jobtype2,
      x_previous_jobtype3,
      x_previous_jobtype4,
      x_previous_jobtype5,
      x_previous_jobtype6,
      x_further_study_type,
      x_course_name,
      x_course_training_subject,
      x_research_subject,
      x_research_training_subject,
      x_further_study_provider,
      x_further_study_qualaim,
      x_professional_qualification,
      x_study_reason1,
      x_study_reason2,
      x_study_reason3,
      x_study_reason4,
      x_study_reason5,
      x_study_reason6,
      x_study_reason7,
      x_other_study_reason,
      x_no_other_study_reason,
      x_employer_sponsored,
      x_funding_source,
      x_teacher_teaching,
      x_teacher_seeking,
      x_teaching_sector,
      x_teaching_level,
      x_reason_for_ptcourse,
      x_job_while_studying,
      x_employer_support1,
      x_employer_support2,
      x_employer_support3,
      x_employer_support4,
      x_employer_support5,
      x_popdlhe_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.submission_name,
             new_references.return_name,
             new_references.person_id
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
             new_references.submission_name,
             new_references.return_name,
             new_references.person_id
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
    x_person_id                         IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_dlhe_record_status                IN     VARCHAR2,
    x_participant_source                IN     VARCHAR2,
    x_date_status_changed               IN     DATE,
    x_validation_status                 IN     VARCHAR2,
    x_admin_coding                      IN     VARCHAR2,
    x_survey_method                     IN     VARCHAR2,
    x_employment                        IN     VARCHAR2,
    x_further_study                     IN     VARCHAR2,
    x_qualified_teacher                 IN     VARCHAR2,
    x_pt_study                          IN     VARCHAR2,
    x_employer_business                 IN     VARCHAR2,
    x_employer_name                     IN     VARCHAR2,
    x_employer_classification           IN     VARCHAR2,
    x_employer_location                 IN     VARCHAR2,
    x_employer_postcode                 IN     VARCHAR2,
    x_employer_country                  IN     VARCHAR2,
    x_job_title                         IN     VARCHAR2,
    x_job_duties                        IN     VARCHAR2,
    x_job_classification                IN     VARCHAR2,
    x_employer_size                     IN     VARCHAR2,
    x_job_duration                      IN     VARCHAR2,
    x_job_salary                        IN     NUMBER,
    x_salary_refused                    IN     VARCHAR2,
    x_qualification_requirement         IN     VARCHAR2,
    x_qualification_importance          IN     VARCHAR2,
    x_job_reason1                       IN     VARCHAR2,
    x_job_reason2                       IN     VARCHAR2,
    x_job_reason3                       IN     VARCHAR2,
    x_job_reason4                       IN     VARCHAR2,
    x_job_reason5                       IN     VARCHAR2,
    x_job_reason6                       IN     VARCHAR2,
    x_job_reason7                       IN     VARCHAR2,
    x_job_reason8                       IN     VARCHAR2,
    x_other_job_reason                  IN     VARCHAR2,
    x_no_other_job_reason               IN     VARCHAR2,
    x_job_source                        IN     VARCHAR2,
    x_other_job_source                  IN     VARCHAR2,
    x_no_other_job_source               IN     VARCHAR2,
    x_previous_job                      IN     VARCHAR2,
    x_previous_jobtype1                 IN     VARCHAR2,
    x_previous_jobtype2                 IN     VARCHAR2,
    x_previous_jobtype3                 IN     VARCHAR2,
    x_previous_jobtype4                 IN     VARCHAR2,
    x_previous_jobtype5                 IN     VARCHAR2,
    x_previous_jobtype6                 IN     VARCHAR2,
    x_further_study_type                IN     VARCHAR2,
    x_course_name                       IN     VARCHAR2,
    x_course_training_subject           IN     VARCHAR2,
    x_research_subject                  IN     VARCHAR2,
    x_research_training_subject         IN     VARCHAR2,
    x_further_study_provider            IN     VARCHAR2,
    x_further_study_qualaim             IN     VARCHAR2,
    x_professional_qualification        IN     VARCHAR2,
    x_study_reason1                     IN     VARCHAR2,
    x_study_reason2                     IN     VARCHAR2,
    x_study_reason3                     IN     VARCHAR2,
    x_study_reason4                     IN     VARCHAR2,
    x_study_reason5                     IN     VARCHAR2,
    x_study_reason6                     IN     VARCHAR2,
    x_study_reason7                     IN     VARCHAR2,
    x_other_study_reason                IN     VARCHAR2,
    x_no_other_study_reason             IN     VARCHAR2,
    x_employer_sponsored                IN     VARCHAR2,
    x_funding_source                    IN     VARCHAR2,
    x_teacher_teaching                  IN     VARCHAR2,
    x_teacher_seeking                   IN     VARCHAR2,
    x_teaching_sector                   IN     VARCHAR2,
    x_teaching_level                    IN     VARCHAR2,
    x_reason_for_ptcourse               IN     VARCHAR2,
    x_job_while_studying                IN     VARCHAR2,
    x_employer_support1                 IN     VARCHAR2,
    x_employer_support2                 IN     VARCHAR2,
    x_employer_support3                 IN     VARCHAR2,
    x_employer_support4                 IN     VARCHAR2,
    x_employer_support5                 IN     VARCHAR2,
    x_popdlhe_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prasada.marada@oracle.com
  ||  Created On : 17-APR-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_STDNT_DLHE_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_submission_name                   => x_submission_name,
      x_user_return_subclass              => x_user_return_subclass,
      x_return_name                       => x_return_name,
      x_qual_period_code                  => x_qual_period_code,
      x_dlhe_record_status                => x_dlhe_record_status,
      x_participant_source                => x_participant_source,
      x_date_status_changed               => x_date_status_changed,
      x_validation_status                 => x_validation_status,
      x_admin_coding                      => x_admin_coding,
      x_survey_method                     => x_survey_method,
      x_employment                        => x_employment,
      x_further_study                     => x_further_study,
      x_qualified_teacher                 => x_qualified_teacher,
      x_pt_study                          => x_pt_study,
      x_employer_business                 => x_employer_business,
      x_employer_name                     => x_employer_name,
      x_employer_classification           => x_employer_classification,
      x_employer_location                 => x_employer_location,
      x_employer_postcode                 => x_employer_postcode,
      x_employer_country                  => x_employer_country,
      x_job_title                         => x_job_title,
      x_job_duties                        => x_job_duties,
      x_job_classification                => x_job_classification,
      x_employer_size                     => x_employer_size,
      x_job_duration                      => x_job_duration,
      x_job_salary                        => x_job_salary,
      x_salary_refused                    => x_salary_refused,
      x_qualification_requirement         => x_qualification_requirement,
      x_qualification_importance          => x_qualification_importance,
      x_job_reason1                       => x_job_reason1,
      x_job_reason2                       => x_job_reason2,
      x_job_reason3                       => x_job_reason3,
      x_job_reason4                       => x_job_reason4,
      x_job_reason5                       => x_job_reason5,
      x_job_reason6                       => x_job_reason6,
      x_job_reason7                       => x_job_reason7,
      x_job_reason8                       => x_job_reason8,
      x_other_job_reason                  => x_other_job_reason,
      x_no_other_job_reason               => x_no_other_job_reason,
      x_job_source                        => x_job_source,
      x_other_job_source                  => x_other_job_source,
      x_no_other_job_source               => x_no_other_job_source,
      x_previous_job                      => x_previous_job,
      x_previous_jobtype1                 => x_previous_jobtype1,
      x_previous_jobtype2                 => x_previous_jobtype2,
      x_previous_jobtype3                 => x_previous_jobtype3,
      x_previous_jobtype4                 => x_previous_jobtype4,
      x_previous_jobtype5                 => x_previous_jobtype5,
      x_previous_jobtype6                 => x_previous_jobtype6,
      x_further_study_type                => x_further_study_type,
      x_course_name                       => x_course_name,
      x_course_training_subject           => x_course_training_subject,
      x_research_subject                  => x_research_subject,
      x_research_training_subject         => x_research_training_subject,
      x_further_study_provider            => x_further_study_provider,
      x_further_study_qualaim             => x_further_study_qualaim,
      x_professional_qualification        => x_professional_qualification,
      x_study_reason1                     => x_study_reason1,
      x_study_reason2                     => x_study_reason2,
      x_study_reason3                     => x_study_reason3,
      x_study_reason4                     => x_study_reason4,
      x_study_reason5                     => x_study_reason5,
      x_study_reason6                     => x_study_reason6,
      x_study_reason7                     => x_study_reason7,
      x_other_study_reason                => x_other_study_reason,
      x_no_other_study_reason             => x_no_other_study_reason,
      x_employer_sponsored                => x_employer_sponsored,
      x_funding_source                    => x_funding_source,
      x_teacher_teaching                  => x_teacher_teaching,
      x_teacher_seeking                   => x_teacher_seeking,
      x_teaching_sector                   => x_teaching_sector,
      x_teaching_level                    => x_teaching_level,
      x_reason_for_ptcourse               => x_reason_for_ptcourse,
      x_job_while_studying                => x_job_while_studying,
      x_employer_support1                 => x_employer_support1,
      x_employer_support2                 => x_employer_support2,
      x_employer_support3                 => x_employer_support3,
      x_employer_support4                 => x_employer_support4,
      x_employer_support5                 => x_employer_support5,
      x_popdlhe_flag                      => x_popdlhe_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_stdnt_dlhe (
      person_id,
      submission_name,
      user_return_subclass,
      return_name,
      qual_period_code,
      dlhe_record_status,
      participant_source,
      date_status_changed,
      validation_status,
      admin_coding,
      survey_method,
      employment,
      further_study,
      qualified_teacher,
      pt_study,
      employer_business,
      employer_name,
      employer_classification,
      employer_location,
      employer_postcode,
      employer_country,
      job_title,
      job_duties,
      job_classification,
      employer_size,
      job_duration,
      job_salary,
      salary_refused,
      qualification_requirement,
      qualification_importance,
      job_reason1,
      job_reason2,
      job_reason3,
      job_reason4,
      job_reason5,
      job_reason6,
      job_reason7,
      job_reason8,
      other_job_reason,
      no_other_job_reason,
      job_source,
      other_job_source,
      no_other_job_source,
      previous_job,
      previous_jobtype1,
      previous_jobtype2,
      previous_jobtype3,
      previous_jobtype4,
      previous_jobtype5,
      previous_jobtype6,
      further_study_type,
      course_name,
      course_training_subject,
      research_subject,
      research_training_subject,
      further_study_provider,
      further_study_qualaim,
      professional_qualification,
      study_reason1,
      study_reason2,
      study_reason3,
      study_reason4,
      study_reason5,
      study_reason6,
      study_reason7,
      other_study_reason,
      no_other_study_reason,
      employer_sponsored,
      funding_source,
      teacher_teaching,
      teacher_seeking,
      teaching_sector,
      teaching_level,
      reason_for_ptcourse,
      job_while_studying,
      employer_support1,
      employer_support2,
      employer_support3,
      employer_support4,
      employer_support5,
      popdlhe_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.person_id,
      new_references.submission_name,
      new_references.user_return_subclass,
      new_references.return_name,
      new_references.qual_period_code,
      new_references.dlhe_record_status,
      new_references.participant_source,
      new_references.date_status_changed,
      new_references.validation_status,
      new_references.admin_coding,
      new_references.survey_method,
      new_references.employment,
      new_references.further_study,
      new_references.qualified_teacher,
      new_references.pt_study,
      new_references.employer_business,
      new_references.employer_name,
      new_references.employer_classification,
      new_references.employer_location,
      new_references.employer_postcode,
      new_references.employer_country,
      new_references.job_title,
      new_references.job_duties,
      new_references.job_classification,
      new_references.employer_size,
      new_references.job_duration,
      new_references.job_salary,
      new_references.salary_refused,
      new_references.qualification_requirement,
      new_references.qualification_importance,
      new_references.job_reason1,
      new_references.job_reason2,
      new_references.job_reason3,
      new_references.job_reason4,
      new_references.job_reason5,
      new_references.job_reason6,
      new_references.job_reason7,
      new_references.job_reason8,
      new_references.other_job_reason,
      new_references.no_other_job_reason,
      new_references.job_source,
      new_references.other_job_source,
      new_references.no_other_job_source,
      new_references.previous_job,
      new_references.previous_jobtype1,
      new_references.previous_jobtype2,
      new_references.previous_jobtype3,
      new_references.previous_jobtype4,
      new_references.previous_jobtype5,
      new_references.previous_jobtype6,
      new_references.further_study_type,
      new_references.course_name,
      new_references.course_training_subject,
      new_references.research_subject,
      new_references.research_training_subject,
      new_references.further_study_provider,
      new_references.further_study_qualaim,
      new_references.professional_qualification,
      new_references.study_reason1,
      new_references.study_reason2,
      new_references.study_reason3,
      new_references.study_reason4,
      new_references.study_reason5,
      new_references.study_reason6,
      new_references.study_reason7,
      new_references.other_study_reason,
      new_references.no_other_study_reason,
      new_references.employer_sponsored,
      new_references.funding_source,
      new_references.teacher_teaching,
      new_references.teacher_seeking,
      new_references.teaching_sector,
      new_references.teaching_level,
      new_references.reason_for_ptcourse,
      new_references.job_while_studying,
      new_references.employer_support1,
      new_references.employer_support2,
      new_references.employer_support3,
      new_references.employer_support4,
      new_references.employer_support5,
      new_references.popdlhe_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_dlhe_record_status                IN     VARCHAR2,
    x_participant_source                IN     VARCHAR2,
    x_date_status_changed               IN     DATE,
    x_validation_status                 IN     VARCHAR2,
    x_admin_coding                      IN     VARCHAR2,
    x_survey_method                     IN     VARCHAR2,
    x_employment                        IN     VARCHAR2,
    x_further_study                     IN     VARCHAR2,
    x_qualified_teacher                 IN     VARCHAR2,
    x_pt_study                          IN     VARCHAR2,
    x_employer_business                 IN     VARCHAR2,
    x_employer_name                     IN     VARCHAR2,
    x_employer_classification           IN     VARCHAR2,
    x_employer_location                 IN     VARCHAR2,
    x_employer_postcode                 IN     VARCHAR2,
    x_employer_country                  IN     VARCHAR2,
    x_job_title                         IN     VARCHAR2,
    x_job_duties                        IN     VARCHAR2,
    x_job_classification                IN     VARCHAR2,
    x_employer_size                     IN     VARCHAR2,
    x_job_duration                      IN     VARCHAR2,
    x_job_salary                        IN     NUMBER,
    x_salary_refused                    IN     VARCHAR2,
    x_qualification_requirement         IN     VARCHAR2,
    x_qualification_importance          IN     VARCHAR2,
    x_job_reason1                       IN     VARCHAR2,
    x_job_reason2                       IN     VARCHAR2,
    x_job_reason3                       IN     VARCHAR2,
    x_job_reason4                       IN     VARCHAR2,
    x_job_reason5                       IN     VARCHAR2,
    x_job_reason6                       IN     VARCHAR2,
    x_job_reason7                       IN     VARCHAR2,
    x_job_reason8                       IN     VARCHAR2,
    x_other_job_reason                  IN     VARCHAR2,
    x_no_other_job_reason               IN     VARCHAR2,
    x_job_source                        IN     VARCHAR2,
    x_other_job_source                  IN     VARCHAR2,
    x_no_other_job_source               IN     VARCHAR2,
    x_previous_job                      IN     VARCHAR2,
    x_previous_jobtype1                 IN     VARCHAR2,
    x_previous_jobtype2                 IN     VARCHAR2,
    x_previous_jobtype3                 IN     VARCHAR2,
    x_previous_jobtype4                 IN     VARCHAR2,
    x_previous_jobtype5                 IN     VARCHAR2,
    x_previous_jobtype6                 IN     VARCHAR2,
    x_further_study_type                IN     VARCHAR2,
    x_course_name                       IN     VARCHAR2,
    x_course_training_subject           IN     VARCHAR2,
    x_research_subject                  IN     VARCHAR2,
    x_research_training_subject         IN     VARCHAR2,
    x_further_study_provider            IN     VARCHAR2,
    x_further_study_qualaim             IN     VARCHAR2,
    x_professional_qualification        IN     VARCHAR2,
    x_study_reason1                     IN     VARCHAR2,
    x_study_reason2                     IN     VARCHAR2,
    x_study_reason3                     IN     VARCHAR2,
    x_study_reason4                     IN     VARCHAR2,
    x_study_reason5                     IN     VARCHAR2,
    x_study_reason6                     IN     VARCHAR2,
    x_study_reason7                     IN     VARCHAR2,
    x_other_study_reason                IN     VARCHAR2,
    x_no_other_study_reason             IN     VARCHAR2,
    x_employer_sponsored                IN     VARCHAR2,
    x_funding_source                    IN     VARCHAR2,
    x_teacher_teaching                  IN     VARCHAR2,
    x_teacher_seeking                   IN     VARCHAR2,
    x_teaching_sector                   IN     VARCHAR2,
    x_teaching_level                    IN     VARCHAR2,
    x_reason_for_ptcourse               IN     VARCHAR2,
    x_job_while_studying                IN     VARCHAR2,
    x_employer_support1                 IN     VARCHAR2,
    x_employer_support2                 IN     VARCHAR2,
    x_employer_support3                 IN     VARCHAR2,
    x_employer_support4                 IN     VARCHAR2,
    x_employer_support5                 IN     VARCHAR2,
    x_popdlhe_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prasada.marada@oracle.com
  ||  Created On : 17-APR-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        user_return_subclass,
        qual_period_code,
        dlhe_record_status,
        participant_source,
        date_status_changed,
        validation_status,
        admin_coding,
        survey_method,
        employment,
        further_study,
        qualified_teacher,
        pt_study,
        employer_business,
        employer_name,
        employer_classification,
        employer_location,
        employer_postcode,
        employer_country,
        job_title,
        job_duties,
        job_classification,
        employer_size,
        job_duration,
        job_salary,
        salary_refused,
        qualification_requirement,
        qualification_importance,
        job_reason1,
        job_reason2,
        job_reason3,
        job_reason4,
        job_reason5,
        job_reason6,
        job_reason7,
        job_reason8,
        other_job_reason,
        no_other_job_reason,
        job_source,
        other_job_source,
        no_other_job_source,
        previous_job,
        previous_jobtype1,
        previous_jobtype2,
        previous_jobtype3,
        previous_jobtype4,
        previous_jobtype5,
        previous_jobtype6,
        further_study_type,
        course_name,
        course_training_subject,
        research_subject,
        research_training_subject,
        further_study_provider,
        further_study_qualaim,
        professional_qualification,
        study_reason1,
        study_reason2,
        study_reason3,
        study_reason4,
        study_reason5,
        study_reason6,
        study_reason7,
        other_study_reason,
        no_other_study_reason,
        employer_sponsored,
        funding_source,
        teacher_teaching,
        teacher_seeking,
        teaching_sector,
        teaching_level,
        reason_for_ptcourse,
        job_while_studying,
        employer_support1,
        employer_support2,
        employer_support3,
        employer_support4,
        employer_support5,
        popdlhe_flag
      FROM  igs_he_stdnt_dlhe
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
        (tlinfo.user_return_subclass = x_user_return_subclass)
        AND (tlinfo.qual_period_code = x_qual_period_code)
        AND (tlinfo.dlhe_record_status = x_dlhe_record_status)
        AND (tlinfo.participant_source = x_participant_source)
        AND ((tlinfo.date_status_changed = x_date_status_changed) OR ((tlinfo.date_status_changed IS NULL) AND (X_date_status_changed IS NULL)))
        AND ((tlinfo.validation_status = x_validation_status) OR ((tlinfo.validation_status IS NULL) AND (X_validation_status IS NULL)))
        AND ((tlinfo.admin_coding = x_admin_coding) OR ((tlinfo.admin_coding IS NULL) AND (X_admin_coding IS NULL)))
        AND ((tlinfo.survey_method = x_survey_method) OR ((tlinfo.survey_method IS NULL) AND (X_survey_method IS NULL)))
        AND ((tlinfo.employment = x_employment) OR ((tlinfo.employment IS NULL) AND (X_employment IS NULL)))
        AND ((tlinfo.further_study = x_further_study) OR ((tlinfo.further_study IS NULL) AND (X_further_study IS NULL)))
        AND ((tlinfo.qualified_teacher = x_qualified_teacher) OR ((tlinfo.qualified_teacher IS NULL) AND (X_qualified_teacher IS NULL)))
        AND ((tlinfo.pt_study = x_pt_study) OR ((tlinfo.pt_study IS NULL) AND (X_pt_study IS NULL)))
        AND ((tlinfo.employer_business = x_employer_business) OR ((tlinfo.employer_business IS NULL) AND (X_employer_business IS NULL)))
        AND ((tlinfo.employer_name = x_employer_name) OR ((tlinfo.employer_name IS NULL) AND (X_employer_name IS NULL)))
        AND ((tlinfo.employer_classification = x_employer_classification) OR ((tlinfo.employer_classification IS NULL) AND (X_employer_classification IS NULL)))
        AND ((tlinfo.employer_location = x_employer_location) OR ((tlinfo.employer_location IS NULL) AND (X_employer_location IS NULL)))
        AND ((tlinfo.employer_postcode = x_employer_postcode) OR ((tlinfo.employer_postcode IS NULL) AND (X_employer_postcode IS NULL)))
        AND ((tlinfo.employer_country = x_employer_country) OR ((tlinfo.employer_country IS NULL) AND (X_employer_country IS NULL)))
        AND ((tlinfo.job_title = x_job_title) OR ((tlinfo.job_title IS NULL) AND (X_job_title IS NULL)))
        AND ((tlinfo.job_duties = x_job_duties) OR ((tlinfo.job_duties IS NULL) AND (X_job_duties IS NULL)))
        AND ((tlinfo.job_classification = x_job_classification) OR ((tlinfo.job_classification IS NULL) AND (X_job_classification IS NULL)))
        AND ((tlinfo.employer_size = x_employer_size) OR ((tlinfo.employer_size IS NULL) AND (X_employer_size IS NULL)))
        AND ((tlinfo.job_duration = x_job_duration) OR ((tlinfo.job_duration IS NULL) AND (X_job_duration IS NULL)))
        AND ((tlinfo.job_salary = x_job_salary) OR ((tlinfo.job_salary IS NULL) AND (X_job_salary IS NULL)))
        AND (tlinfo.salary_refused = x_salary_refused)
        AND ((tlinfo.qualification_requirement = x_qualification_requirement) OR ((tlinfo.qualification_requirement IS NULL) AND (X_qualification_requirement IS NULL)))
        AND ((tlinfo.qualification_importance = x_qualification_importance) OR ((tlinfo.qualification_importance IS NULL) AND (X_qualification_importance IS NULL)))
        AND (tlinfo.job_reason1 = x_job_reason1)
        AND (tlinfo.job_reason2 = x_job_reason2)
        AND (tlinfo.job_reason3 = x_job_reason3)
        AND (tlinfo.job_reason4 = x_job_reason4)
        AND (tlinfo.job_reason5 = x_job_reason5)
        AND (tlinfo.job_reason6 = x_job_reason6)
        AND (tlinfo.job_reason7 = x_job_reason7)
        AND (tlinfo.job_reason8 = x_job_reason8)
        AND ((tlinfo.other_job_reason = x_other_job_reason) OR ((tlinfo.other_job_reason IS NULL) AND (X_other_job_reason IS NULL)))
        AND (tlinfo.no_other_job_reason = x_no_other_job_reason)
        AND ((tlinfo.job_source = x_job_source) OR ((tlinfo.job_source IS NULL) AND (X_job_source IS NULL)))
        AND ((tlinfo.other_job_source = x_other_job_source) OR ((tlinfo.other_job_source IS NULL) AND (X_other_job_source IS NULL)))
        AND (tlinfo.no_other_job_source = x_no_other_job_source)
        AND ((tlinfo.previous_job = x_previous_job) OR ((tlinfo.previous_job IS NULL) AND (X_previous_job IS NULL)))
        AND (tlinfo.previous_jobtype1 = x_previous_jobtype1)
        AND (tlinfo.previous_jobtype2 = x_previous_jobtype2)
        AND (tlinfo.previous_jobtype3 = x_previous_jobtype3)
        AND (tlinfo.previous_jobtype4 = x_previous_jobtype4)
        AND (tlinfo.previous_jobtype5 = x_previous_jobtype5)
        AND (tlinfo.previous_jobtype6 = x_previous_jobtype6)
        AND ((tlinfo.further_study_type = x_further_study_type) OR ((tlinfo.further_study_type IS NULL) AND (X_further_study_type IS NULL)))
        AND ((tlinfo.course_name = x_course_name) OR ((tlinfo.course_name IS NULL) AND (X_course_name IS NULL)))
        AND ((tlinfo.course_training_subject = x_course_training_subject) OR ((tlinfo.course_training_subject IS NULL) AND (X_course_training_subject IS NULL)))
        AND ((tlinfo.research_subject = x_research_subject) OR ((tlinfo.research_subject IS NULL) AND (X_research_subject IS NULL)))
        AND ((tlinfo.research_training_subject = x_research_training_subject) OR ((tlinfo.research_training_subject IS NULL) AND (X_research_training_subject IS NULL)))
        AND ((tlinfo.further_study_provider = x_further_study_provider) OR ((tlinfo.further_study_provider IS NULL) AND (X_further_study_provider IS NULL)))
        AND ((tlinfo.further_study_qualaim = x_further_study_qualaim) OR ((tlinfo.further_study_qualaim IS NULL) AND (X_further_study_qualaim IS NULL)))
        AND ((tlinfo.professional_qualification = x_professional_qualification) OR ((tlinfo.professional_qualification IS NULL) AND (X_professional_qualification IS NULL)))
        AND ((tlinfo.study_reason1 = x_study_reason1) OR ((tlinfo.study_reason1 IS NULL) AND (X_study_reason1 IS NULL)))
        AND (tlinfo.study_reason2 = x_study_reason2)
        AND (tlinfo.study_reason3 = x_study_reason3)
        AND (tlinfo.study_reason4 = x_study_reason4)
        AND (tlinfo.study_reason5 = x_study_reason5)
        AND (tlinfo.study_reason6 = x_study_reason6)
        AND (tlinfo.study_reason7 = x_study_reason7)
        AND ((tlinfo.other_study_reason = x_other_study_reason) OR ((tlinfo.other_study_reason IS NULL) AND (X_other_study_reason IS NULL)))
        AND (tlinfo.no_other_study_reason = x_no_other_study_reason)
        AND (tlinfo.employer_sponsored = x_employer_sponsored)
        AND ((tlinfo.funding_source = x_funding_source) OR ((tlinfo.funding_source IS NULL) AND (X_funding_source IS NULL)))
        AND ((tlinfo.teacher_teaching = x_teacher_teaching) OR ((tlinfo.teacher_teaching IS NULL) AND (X_teacher_teaching IS NULL)))
        AND ((tlinfo.teacher_seeking = x_teacher_seeking) OR ((tlinfo.teacher_seeking IS NULL) AND (X_teacher_seeking IS NULL)))
        AND ((tlinfo.teaching_sector = x_teaching_sector) OR ((tlinfo.teaching_sector IS NULL) AND (X_teaching_sector IS NULL)))
        AND ((tlinfo.teaching_level = x_teaching_level) OR ((tlinfo.teaching_level IS NULL) AND (X_teaching_level IS NULL)))
        AND ((tlinfo.reason_for_ptcourse = x_reason_for_ptcourse) OR ((tlinfo.reason_for_ptcourse IS NULL) AND (X_reason_for_ptcourse IS NULL)))
        AND (tlinfo.job_while_studying = x_job_while_studying)
        AND (tlinfo.employer_support1 = x_employer_support1)
        AND (tlinfo.employer_support2 = x_employer_support2)
        AND (tlinfo.employer_support3 = x_employer_support3)
        AND (tlinfo.employer_support4 = x_employer_support4)
        AND (tlinfo.employer_support5 = x_employer_support5)
        AND (tlinfo.popdlhe_flag = x_popdlhe_flag)
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
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_dlhe_record_status                IN     VARCHAR2,
    x_participant_source                IN     VARCHAR2,
    x_date_status_changed               IN     DATE,
    x_validation_status                 IN     VARCHAR2,
    x_admin_coding                      IN     VARCHAR2,
    x_survey_method                     IN     VARCHAR2,
    x_employment                        IN     VARCHAR2,
    x_further_study                     IN     VARCHAR2,
    x_qualified_teacher                 IN     VARCHAR2,
    x_pt_study                          IN     VARCHAR2,
    x_employer_business                 IN     VARCHAR2,
    x_employer_name                     IN     VARCHAR2,
    x_employer_classification           IN     VARCHAR2,
    x_employer_location                 IN     VARCHAR2,
    x_employer_postcode                 IN     VARCHAR2,
    x_employer_country                  IN     VARCHAR2,
    x_job_title                         IN     VARCHAR2,
    x_job_duties                        IN     VARCHAR2,
    x_job_classification                IN     VARCHAR2,
    x_employer_size                     IN     VARCHAR2,
    x_job_duration                      IN     VARCHAR2,
    x_job_salary                        IN     NUMBER,
    x_salary_refused                    IN     VARCHAR2,
    x_qualification_requirement         IN     VARCHAR2,
    x_qualification_importance          IN     VARCHAR2,
    x_job_reason1                       IN     VARCHAR2,
    x_job_reason2                       IN     VARCHAR2,
    x_job_reason3                       IN     VARCHAR2,
    x_job_reason4                       IN     VARCHAR2,
    x_job_reason5                       IN     VARCHAR2,
    x_job_reason6                       IN     VARCHAR2,
    x_job_reason7                       IN     VARCHAR2,
    x_job_reason8                       IN     VARCHAR2,
    x_other_job_reason                  IN     VARCHAR2,
    x_no_other_job_reason               IN     VARCHAR2,
    x_job_source                        IN     VARCHAR2,
    x_other_job_source                  IN     VARCHAR2,
    x_no_other_job_source               IN     VARCHAR2,
    x_previous_job                      IN     VARCHAR2,
    x_previous_jobtype1                 IN     VARCHAR2,
    x_previous_jobtype2                 IN     VARCHAR2,
    x_previous_jobtype3                 IN     VARCHAR2,
    x_previous_jobtype4                 IN     VARCHAR2,
    x_previous_jobtype5                 IN     VARCHAR2,
    x_previous_jobtype6                 IN     VARCHAR2,
    x_further_study_type                IN     VARCHAR2,
    x_course_name                       IN     VARCHAR2,
    x_course_training_subject           IN     VARCHAR2,
    x_research_subject                  IN     VARCHAR2,
    x_research_training_subject         IN     VARCHAR2,
    x_further_study_provider            IN     VARCHAR2,
    x_further_study_qualaim             IN     VARCHAR2,
    x_professional_qualification        IN     VARCHAR2,
    x_study_reason1                     IN     VARCHAR2,
    x_study_reason2                     IN     VARCHAR2,
    x_study_reason3                     IN     VARCHAR2,
    x_study_reason4                     IN     VARCHAR2,
    x_study_reason5                     IN     VARCHAR2,
    x_study_reason6                     IN     VARCHAR2,
    x_study_reason7                     IN     VARCHAR2,
    x_other_study_reason                IN     VARCHAR2,
    x_no_other_study_reason             IN     VARCHAR2,
    x_employer_sponsored                IN     VARCHAR2,
    x_funding_source                    IN     VARCHAR2,
    x_teacher_teaching                  IN     VARCHAR2,
    x_teacher_seeking                   IN     VARCHAR2,
    x_teaching_sector                   IN     VARCHAR2,
    x_teaching_level                    IN     VARCHAR2,
    x_reason_for_ptcourse               IN     VARCHAR2,
    x_job_while_studying                IN     VARCHAR2,
    x_employer_support1                 IN     VARCHAR2,
    x_employer_support2                 IN     VARCHAR2,
    x_employer_support3                 IN     VARCHAR2,
    x_employer_support4                 IN     VARCHAR2,
    x_employer_support5                 IN     VARCHAR2,
    x_popdlhe_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prasada.marada@oracle.com
  ||  Created On : 17-APR-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_STDNT_DLHE_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_submission_name                   => x_submission_name,
      x_user_return_subclass              => x_user_return_subclass,
      x_return_name                       => x_return_name,
      x_qual_period_code                  => x_qual_period_code,
      x_dlhe_record_status                => x_dlhe_record_status,
      x_participant_source                => x_participant_source,
      x_date_status_changed               => x_date_status_changed,
      x_validation_status                 => x_validation_status,
      x_admin_coding                      => x_admin_coding,
      x_survey_method                     => x_survey_method,
      x_employment                        => x_employment,
      x_further_study                     => x_further_study,
      x_qualified_teacher                 => x_qualified_teacher,
      x_pt_study                          => x_pt_study,
      x_employer_business                 => x_employer_business,
      x_employer_name                     => x_employer_name,
      x_employer_classification           => x_employer_classification,
      x_employer_location                 => x_employer_location,
      x_employer_postcode                 => x_employer_postcode,
      x_employer_country                  => x_employer_country,
      x_job_title                         => x_job_title,
      x_job_duties                        => x_job_duties,
      x_job_classification                => x_job_classification,
      x_employer_size                     => x_employer_size,
      x_job_duration                      => x_job_duration,
      x_job_salary                        => x_job_salary,
      x_salary_refused                    => x_salary_refused,
      x_qualification_requirement         => x_qualification_requirement,
      x_qualification_importance          => x_qualification_importance,
      x_job_reason1                       => x_job_reason1,
      x_job_reason2                       => x_job_reason2,
      x_job_reason3                       => x_job_reason3,
      x_job_reason4                       => x_job_reason4,
      x_job_reason5                       => x_job_reason5,
      x_job_reason6                       => x_job_reason6,
      x_job_reason7                       => x_job_reason7,
      x_job_reason8                       => x_job_reason8,
      x_other_job_reason                  => x_other_job_reason,
      x_no_other_job_reason               => x_no_other_job_reason,
      x_job_source                        => x_job_source,
      x_other_job_source                  => x_other_job_source,
      x_no_other_job_source               => x_no_other_job_source,
      x_previous_job                      => x_previous_job,
      x_previous_jobtype1                 => x_previous_jobtype1,
      x_previous_jobtype2                 => x_previous_jobtype2,
      x_previous_jobtype3                 => x_previous_jobtype3,
      x_previous_jobtype4                 => x_previous_jobtype4,
      x_previous_jobtype5                 => x_previous_jobtype5,
      x_previous_jobtype6                 => x_previous_jobtype6,
      x_further_study_type                => x_further_study_type,
      x_course_name                       => x_course_name,
      x_course_training_subject           => x_course_training_subject,
      x_research_subject                  => x_research_subject,
      x_research_training_subject         => x_research_training_subject,
      x_further_study_provider            => x_further_study_provider,
      x_further_study_qualaim             => x_further_study_qualaim,
      x_professional_qualification        => x_professional_qualification,
      x_study_reason1                     => x_study_reason1,
      x_study_reason2                     => x_study_reason2,
      x_study_reason3                     => x_study_reason3,
      x_study_reason4                     => x_study_reason4,
      x_study_reason5                     => x_study_reason5,
      x_study_reason6                     => x_study_reason6,
      x_study_reason7                     => x_study_reason7,
      x_other_study_reason                => x_other_study_reason,
      x_no_other_study_reason             => x_no_other_study_reason,
      x_employer_sponsored                => x_employer_sponsored,
      x_funding_source                    => x_funding_source,
      x_teacher_teaching                  => x_teacher_teaching,
      x_teacher_seeking                   => x_teacher_seeking,
      x_teaching_sector                   => x_teaching_sector,
      x_teaching_level                    => x_teaching_level,
      x_reason_for_ptcourse               => x_reason_for_ptcourse,
      x_job_while_studying                => x_job_while_studying,
      x_employer_support1                 => x_employer_support1,
      x_employer_support2                 => x_employer_support2,
      x_employer_support3                 => x_employer_support3,
      x_employer_support4                 => x_employer_support4,
      x_employer_support5                 => x_employer_support5,
      x_popdlhe_flag                      => x_popdlhe_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_stdnt_dlhe
      SET
        user_return_subclass              = new_references.user_return_subclass,
        qual_period_code                  = new_references.qual_period_code,
        dlhe_record_status                = new_references.dlhe_record_status,
        participant_source                = new_references.participant_source,
        date_status_changed               = new_references.date_status_changed,
        validation_status                 = new_references.validation_status,
        admin_coding                      = new_references.admin_coding,
        survey_method                     = new_references.survey_method,
        employment                        = new_references.employment,
        further_study                     = new_references.further_study,
        qualified_teacher                 = new_references.qualified_teacher,
        pt_study                          = new_references.pt_study,
        employer_business                 = new_references.employer_business,
        employer_name                     = new_references.employer_name,
        employer_classification           = new_references.employer_classification,
        employer_location                 = new_references.employer_location,
        employer_postcode                 = new_references.employer_postcode,
        employer_country                  = new_references.employer_country,
        job_title                         = new_references.job_title,
        job_duties                        = new_references.job_duties,
        job_classification                = new_references.job_classification,
        employer_size                     = new_references.employer_size,
        job_duration                      = new_references.job_duration,
        job_salary                        = new_references.job_salary,
        salary_refused                    = new_references.salary_refused,
        qualification_requirement         = new_references.qualification_requirement,
        qualification_importance          = new_references.qualification_importance,
        job_reason1                       = new_references.job_reason1,
        job_reason2                       = new_references.job_reason2,
        job_reason3                       = new_references.job_reason3,
        job_reason4                       = new_references.job_reason4,
        job_reason5                       = new_references.job_reason5,
        job_reason6                       = new_references.job_reason6,
        job_reason7                       = new_references.job_reason7,
        job_reason8                       = new_references.job_reason8,
        other_job_reason                  = new_references.other_job_reason,
        no_other_job_reason               = new_references.no_other_job_reason,
        job_source                        = new_references.job_source,
        other_job_source                  = new_references.other_job_source,
        no_other_job_source               = new_references.no_other_job_source,
        previous_job                      = new_references.previous_job,
        previous_jobtype1                 = new_references.previous_jobtype1,
        previous_jobtype2                 = new_references.previous_jobtype2,
        previous_jobtype3                 = new_references.previous_jobtype3,
        previous_jobtype4                 = new_references.previous_jobtype4,
        previous_jobtype5                 = new_references.previous_jobtype5,
        previous_jobtype6                 = new_references.previous_jobtype6,
        further_study_type                = new_references.further_study_type,
        course_name                       = new_references.course_name,
        course_training_subject           = new_references.course_training_subject,
        research_subject                  = new_references.research_subject,
        research_training_subject         = new_references.research_training_subject,
        further_study_provider            = new_references.further_study_provider,
        further_study_qualaim             = new_references.further_study_qualaim,
        professional_qualification        = new_references.professional_qualification,
        study_reason1                     = new_references.study_reason1,
        study_reason2                     = new_references.study_reason2,
        study_reason3                     = new_references.study_reason3,
        study_reason4                     = new_references.study_reason4,
        study_reason5                     = new_references.study_reason5,
        study_reason6                     = new_references.study_reason6,
        study_reason7                     = new_references.study_reason7,
        other_study_reason                = new_references.other_study_reason,
        no_other_study_reason             = new_references.no_other_study_reason,
        employer_sponsored                = new_references.employer_sponsored,
        funding_source                    = new_references.funding_source,
        teacher_teaching                  = new_references.teacher_teaching,
        teacher_seeking                   = new_references.teacher_seeking,
        teaching_sector                   = new_references.teaching_sector,
        teaching_level                    = new_references.teaching_level,
        reason_for_ptcourse               = new_references.reason_for_ptcourse,
        job_while_studying                = new_references.job_while_studying,
        employer_support1                 = new_references.employer_support1,
        employer_support2                 = new_references.employer_support2,
        employer_support3                 = new_references.employer_support3,
        employer_support4                 = new_references.employer_support4,
        employer_support5                 = new_references.employer_support5,
        popdlhe_flag                      = new_references.popdlhe_flag,
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
    x_person_id                         IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_dlhe_record_status                IN     VARCHAR2,
    x_participant_source                IN     VARCHAR2,
    x_date_status_changed               IN     DATE,
    x_validation_status                 IN     VARCHAR2,
    x_admin_coding                      IN     VARCHAR2,
    x_survey_method                     IN     VARCHAR2,
    x_employment                        IN     VARCHAR2,
    x_further_study                     IN     VARCHAR2,
    x_qualified_teacher                 IN     VARCHAR2,
    x_pt_study                          IN     VARCHAR2,
    x_employer_business                 IN     VARCHAR2,
    x_employer_name                     IN     VARCHAR2,
    x_employer_classification           IN     VARCHAR2,
    x_employer_location                 IN     VARCHAR2,
    x_employer_postcode                 IN     VARCHAR2,
    x_employer_country                  IN     VARCHAR2,
    x_job_title                         IN     VARCHAR2,
    x_job_duties                        IN     VARCHAR2,
    x_job_classification                IN     VARCHAR2,
    x_employer_size                     IN     VARCHAR2,
    x_job_duration                      IN     VARCHAR2,
    x_job_salary                        IN     NUMBER,
    x_salary_refused                    IN     VARCHAR2,
    x_qualification_requirement         IN     VARCHAR2,
    x_qualification_importance          IN     VARCHAR2,
    x_job_reason1                       IN     VARCHAR2,
    x_job_reason2                       IN     VARCHAR2,
    x_job_reason3                       IN     VARCHAR2,
    x_job_reason4                       IN     VARCHAR2,
    x_job_reason5                       IN     VARCHAR2,
    x_job_reason6                       IN     VARCHAR2,
    x_job_reason7                       IN     VARCHAR2,
    x_job_reason8                       IN     VARCHAR2,
    x_other_job_reason                  IN     VARCHAR2,
    x_no_other_job_reason               IN     VARCHAR2,
    x_job_source                        IN     VARCHAR2,
    x_other_job_source                  IN     VARCHAR2,
    x_no_other_job_source               IN     VARCHAR2,
    x_previous_job                      IN     VARCHAR2,
    x_previous_jobtype1                 IN     VARCHAR2,
    x_previous_jobtype2                 IN     VARCHAR2,
    x_previous_jobtype3                 IN     VARCHAR2,
    x_previous_jobtype4                 IN     VARCHAR2,
    x_previous_jobtype5                 IN     VARCHAR2,
    x_previous_jobtype6                 IN     VARCHAR2,
    x_further_study_type                IN     VARCHAR2,
    x_course_name                       IN     VARCHAR2,
    x_course_training_subject           IN     VARCHAR2,
    x_research_subject                  IN     VARCHAR2,
    x_research_training_subject         IN     VARCHAR2,
    x_further_study_provider            IN     VARCHAR2,
    x_further_study_qualaim             IN     VARCHAR2,
    x_professional_qualification        IN     VARCHAR2,
    x_study_reason1                     IN     VARCHAR2,
    x_study_reason2                     IN     VARCHAR2,
    x_study_reason3                     IN     VARCHAR2,
    x_study_reason4                     IN     VARCHAR2,
    x_study_reason5                     IN     VARCHAR2,
    x_study_reason6                     IN     VARCHAR2,
    x_study_reason7                     IN     VARCHAR2,
    x_other_study_reason                IN     VARCHAR2,
    x_no_other_study_reason             IN     VARCHAR2,
    x_employer_sponsored                IN     VARCHAR2,
    x_funding_source                    IN     VARCHAR2,
    x_teacher_teaching                  IN     VARCHAR2,
    x_teacher_seeking                   IN     VARCHAR2,
    x_teaching_sector                   IN     VARCHAR2,
    x_teaching_level                    IN     VARCHAR2,
    x_reason_for_ptcourse               IN     VARCHAR2,
    x_job_while_studying                IN     VARCHAR2,
    x_employer_support1                 IN     VARCHAR2,
    x_employer_support2                 IN     VARCHAR2,
    x_employer_support3                 IN     VARCHAR2,
    x_employer_support4                 IN     VARCHAR2,
    x_employer_support5                 IN     VARCHAR2,
    x_popdlhe_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prasada.marada@oracle.com
  ||  Created On : 17-APR-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_stdnt_dlhe
      WHERE    submission_name                   = x_submission_name
      AND      return_name                       = x_return_name
      AND      person_id                         = x_person_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_person_id,
        x_submission_name,
        x_user_return_subclass,
        x_return_name,
        x_qual_period_code,
        x_dlhe_record_status,
        x_participant_source,
        x_date_status_changed,
        x_validation_status,
        x_admin_coding,
        x_survey_method,
        x_employment,
        x_further_study,
        x_qualified_teacher,
        x_pt_study,
        x_employer_business,
        x_employer_name,
        x_employer_classification,
        x_employer_location,
        x_employer_postcode,
        x_employer_country,
        x_job_title,
        x_job_duties,
        x_job_classification,
        x_employer_size,
        x_job_duration,
        x_job_salary,
        x_salary_refused,
        x_qualification_requirement,
        x_qualification_importance,
        x_job_reason1,
        x_job_reason2,
        x_job_reason3,
        x_job_reason4,
        x_job_reason5,
        x_job_reason6,
        x_job_reason7,
        x_job_reason8,
        x_other_job_reason,
        x_no_other_job_reason,
        x_job_source,
        x_other_job_source,
        x_no_other_job_source,
        x_previous_job,
        x_previous_jobtype1,
        x_previous_jobtype2,
        x_previous_jobtype3,
        x_previous_jobtype4,
        x_previous_jobtype5,
        x_previous_jobtype6,
        x_further_study_type,
        x_course_name,
        x_course_training_subject,
        x_research_subject,
        x_research_training_subject,
        x_further_study_provider,
        x_further_study_qualaim,
        x_professional_qualification,
        x_study_reason1,
        x_study_reason2,
        x_study_reason3,
        x_study_reason4,
        x_study_reason5,
        x_study_reason6,
        x_study_reason7,
        x_other_study_reason,
        x_no_other_study_reason,
        x_employer_sponsored,
        x_funding_source,
        x_teacher_teaching,
        x_teacher_seeking,
        x_teaching_sector,
        x_teaching_level,
        x_reason_for_ptcourse,
        x_job_while_studying,
        x_employer_support1,
        x_employer_support2,
        x_employer_support3,
        x_employer_support4,
        x_employer_support5,
        x_popdlhe_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_id,
      x_submission_name,
      x_user_return_subclass,
      x_return_name,
      x_qual_period_code,
      x_dlhe_record_status,
      x_participant_source,
      x_date_status_changed,
      x_validation_status,
      x_admin_coding,
      x_survey_method,
      x_employment,
      x_further_study,
      x_qualified_teacher,
      x_pt_study,
      x_employer_business,
      x_employer_name,
      x_employer_classification,
      x_employer_location,
      x_employer_postcode,
      x_employer_country,
      x_job_title,
      x_job_duties,
      x_job_classification,
      x_employer_size,
      x_job_duration,
      x_job_salary,
      x_salary_refused,
      x_qualification_requirement,
      x_qualification_importance,
      x_job_reason1,
      x_job_reason2,
      x_job_reason3,
      x_job_reason4,
      x_job_reason5,
      x_job_reason6,
      x_job_reason7,
      x_job_reason8,
      x_other_job_reason,
      x_no_other_job_reason,
      x_job_source,
      x_other_job_source,
      x_no_other_job_source,
      x_previous_job,
      x_previous_jobtype1,
      x_previous_jobtype2,
      x_previous_jobtype3,
      x_previous_jobtype4,
      x_previous_jobtype5,
      x_previous_jobtype6,
      x_further_study_type,
      x_course_name,
      x_course_training_subject,
      x_research_subject,
      x_research_training_subject,
      x_further_study_provider,
      x_further_study_qualaim,
      x_professional_qualification,
      x_study_reason1,
      x_study_reason2,
      x_study_reason3,
      x_study_reason4,
      x_study_reason5,
      x_study_reason6,
      x_study_reason7,
      x_other_study_reason,
      x_no_other_study_reason,
      x_employer_sponsored,
      x_funding_source,
      x_teacher_teaching,
      x_teacher_seeking,
      x_teaching_sector,
      x_teaching_level,
      x_reason_for_ptcourse,
      x_job_while_studying,
      x_employer_support1,
      x_employer_support2,
      x_employer_support3,
      x_employer_support4,
      x_employer_support5,
      x_popdlhe_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prasada.marada@oracle.com
  ||  Created On : 17-APR-2003
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

    DELETE FROM igs_he_stdnt_dlhe
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_stdnt_dlhe_pkg;

/
