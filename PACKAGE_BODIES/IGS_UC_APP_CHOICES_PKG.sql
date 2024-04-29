--------------------------------------------------------
--  DDL for Package Body IGS_UC_APP_CHOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_APP_CHOICES_PKG" AS
/* $Header: IGSXI02B.pls 120.2 2005/07/03 18:49:54 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_app_choices%ROWTYPE;
  new_references igs_uc_app_choices%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_app_choice_id                     IN     NUMBER      ,
    x_app_id                            IN     NUMBER      ,
    x_app_no                            IN     NUMBER      ,
    x_choice_no                         IN     NUMBER      ,
    x_last_change                       IN     DATE        ,
    x_institute_code                    IN     VARCHAR2    ,
    x_ucas_program_code                 IN     VARCHAR2    ,
    x_oss_program_code                  IN     VARCHAR2    ,
    x_oss_program_version               IN     NUMBER      ,
    x_oss_attendance_type               IN     VARCHAR2    ,
    x_oss_attendance_mode               IN     VARCHAR2    ,
    x_campus                            IN     VARCHAR2    ,
    x_oss_location                      IN     VARCHAR2    ,
    x_faculty                           IN     VARCHAR2    ,
    x_entry_year                        IN     NUMBER      ,
    x_entry_month                       IN     NUMBER      ,
    x_point_of_entry                    IN     NUMBER      ,
    x_home                              IN     VARCHAR2    ,
    x_deferred                          IN     VARCHAR2    ,
    x_route_b_pref_round                IN     NUMBER      ,
    x_route_b_actual_round              IN     NUMBER      ,
    x_condition_category                IN     VARCHAR2    ,
    x_condition_code                    IN     VARCHAR2    ,
    x_decision                          IN     VARCHAR2    ,
    x_decision_date                     IN     DATE        ,
    x_decision_number                   IN     NUMBER      ,
    x_reply                             IN     VARCHAR2    ,
    x_summary_of_cond                   IN     VARCHAR2    ,
    x_choice_cancelled                  IN     VARCHAR2    ,
    x_action                            IN     VARCHAR2    ,
    x_substitution                      IN     VARCHAR2    ,
    x_date_substituted                  IN     DATE        ,
    x_prev_institution                  IN     VARCHAR2    ,
    x_prev_course                       IN     VARCHAR2    ,
    x_prev_campus                       IN     VARCHAR2    ,
    x_ucas_amendment                    IN     VARCHAR2    ,
    x_withdrawal_reason                 IN     VARCHAR2    ,
    x_offer_course                      IN     VARCHAR2    ,
    x_offer_campus                      IN     VARCHAR2    ,
    x_offer_crse_length                 IN     NUMBER      ,
    x_offer_entry_month                 IN     VARCHAR2    ,
    x_offer_entry_year                  IN     VARCHAR2    ,
    x_offer_entry_point                 IN     VARCHAR2    ,
    x_offer_text                        IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_export_to_oss_status              IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_request_id                        IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_extra_round_nbr                   IN     NUMBER,
    x_system_code		                    IN		 VARCHAR2		,
    x_part_time		                      IN		 VARCHAR2		,
    x_interview	                       	IN		 DATE		    ,
    x_late_application	              	IN		 VARCHAR2		,
    x_modular	                        	IN		 VARCHAR2		,
    x_residential	                    	IN		 VARCHAR2,
    -- smaddali added this column for ucfd203 build bug #2669208
    x_ucas_cycle                        IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  adding ucas_cycle and obsoleting timestamp columns for ucfd203 bug#2669208
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_APP_CHOICES
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
    new_references.app_choice_id                     := x_app_choice_id;
    new_references.app_id                            := x_app_id;
    new_references.app_no                            := x_app_no;
    new_references.choice_no                         := x_choice_no;
    new_references.last_change                       := x_last_change;
    new_references.institute_code                    := x_institute_code;
    new_references.ucas_program_code                 := x_ucas_program_code;
    new_references.oss_program_code                  := x_oss_program_code;
    new_references.oss_program_version               := x_oss_program_version;
    new_references.oss_attendance_type               := x_oss_attendance_type;
    new_references.oss_attendance_mode               := x_oss_attendance_mode;
    new_references.campus                            := x_campus;
    new_references.oss_location                      := x_oss_location;
    new_references.faculty                           := x_faculty;
    new_references.entry_year                        := x_entry_year;
    new_references.entry_month                       := x_entry_month;
    new_references.point_of_entry                    := x_point_of_entry;
    new_references.home                              := x_home;
    new_references.deferred                          := x_deferred;
    new_references.route_b_pref_round                := x_route_b_pref_round;
    new_references.route_b_actual_round              := x_route_b_actual_round;
    new_references.condition_category                := x_condition_category;
    new_references.condition_code                    := x_condition_code;
    new_references.decision                          := x_decision;
    new_references.decision_date                     := x_decision_date;
    new_references.decision_number                   := x_decision_number;
    new_references.reply                             := x_reply;
    new_references.summary_of_cond                   := x_summary_of_cond;
    new_references.choice_cancelled                  := x_choice_cancelled;
    new_references.action                            := x_action;
    new_references.substitution                      := x_substitution;
    new_references.date_substituted                  := x_date_substituted;
    new_references.prev_institution                  := x_prev_institution;
    new_references.prev_course                       := x_prev_course;
    new_references.prev_campus                       := x_prev_campus;
    new_references.ucas_amendment                    := x_ucas_amendment;
    new_references.withdrawal_reason                 := x_withdrawal_reason;
    new_references.offer_course                      := x_offer_course;
    new_references.offer_campus                      := x_offer_campus;
    new_references.offer_crse_length                 := x_offer_crse_length;
    new_references.offer_entry_month                 := x_offer_entry_month;
    new_references.offer_entry_year                  := x_offer_entry_year;
    new_references.offer_entry_point                 := x_offer_entry_point;
    new_references.offer_text                        := x_offer_text;
    new_references.export_to_oss_status              := x_export_to_oss_status;
    new_references.error_code                        := x_error_code;
    new_references.request_id                        := x_request_id;
    new_references.batch_id                          := x_batch_id;
    new_references.system_code		                   := x_system_code;
    new_references.part_time		                     := x_part_time;
    new_references.interview	                       := x_interview;
    new_references.late_application	              	 := x_late_application;
    new_references.modular	                         := x_modular;
    new_references.residential	                     := x_residential;
    -- smaddali added new column for ucfd203 - bug#2669208
    new_references.ucas_cycle	                     := x_ucas_cycle;


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

    -- The below column is added newly in UCFD06 - 24SEP2002 - Bug#2574566
    new_references.extra_round_nbr                   := x_extra_round_nbr;

  END set_column_values;


 PROCEDURE check_child_existance IS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    igs_uc_app_cho_cnds_pkg.get_fk_igs_uc_app_choices(old_references.app_choice_id);

  END check_child_existance;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || smaddali 10-jun-03  adding ucas_cycle to UK for bug#2669208 ucfd203 build
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.app_no,
           new_references.choice_no,
	   -- smaddali added new column for ucfd203 - bug#2669208
           new_references.ucas_cycle
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    -- Cursor to fetch the current Institute Code
    CURSOR crnt_inst_cur IS
    SELECT DISTINCT current_inst_code
    FROM   igs_uc_defaults
    WHERE  current_inst_code IS NOT NULL;
    l_crnt_institute igs_uc_defaults.current_inst_code%TYPE;

  BEGIN

    IF (((old_references.app_id = new_references.app_id)) OR
        ((new_references.app_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_applicants_pkg.get_pk_for_validation (
                new_references.app_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.condition_category = new_references.condition_category) AND
         (old_references.condition_code = new_references.condition_code)) OR
        ((new_references.condition_category IS NULL) OR
         (new_references.condition_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_offer_conds_pkg.get_pk_for_validation (
                new_references.condition_category,
                new_references.condition_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (
        (
         (old_references.ucas_program_code = new_references.ucas_program_code) AND
         (old_references.campus = new_references.campus) OR
         (old_references.institute_code = new_references.institute_code) OR
         (old_references.system_code = new_references.system_code)
        )
        AND
        (
         (new_references.ucas_program_code IS NULL) OR
         (new_references.campus IS NULL) OR
         (new_references.institute_code IS NULL) OR
         (new_references.system_code IS NULL)
        )
       ) THEN
      NULL;
    ELSE

      l_crnt_institute := NULL;
      OPEN crnt_inst_cur;
      FETCH crnt_inst_cur INTO l_crnt_institute;
      CLOSE crnt_inst_cur;

      IF new_references.institute_code = l_crnt_institute AND
         NOT igs_uc_crse_dets_pkg.get_pk_for_validation (
                new_references.ucas_program_code,
                new_references.institute_code,
                new_references.campus,
                new_references.system_code) THEN

        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

      END IF;
    END IF;


  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_app_choice_id                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_choices
      WHERE    app_choice_id = x_app_choice_id ;

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
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    -- smaddali added new column for ucfd203 - bug#2669208
    x_ucas_cycle                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  adding ucas_cycle to UK for bug#2669208 ucfd203 build
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_choices
      WHERE    app_no = x_app_no
      AND      choice_no = x_choice_no
      AND      ucas_cycle = x_ucas_cycle
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


  PROCEDURE get_fk_igs_uc_applicants (
    x_app_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nishikant       17Jun2002       Bug#2415346. UCAPCH_UCAP_FKIGS_UC_APPLICANTS
  ||                                  message was replaced with IGS_UC_UCAPCH_UCAP_FK.
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_choices
      WHERE   ((app_id = x_app_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCAPCH_UCAP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_applicants;


  PROCEDURE get_fk_igs_uc_offer_conds (
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nishikant       17Jun2002       Bug#2415346. UCAPACH_UCOC_FKIGS_UC_OFFER_CONDS
  ||                                  message was replaced with IGS_UC_UCAPCH_UCOC_FK
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_choices
      WHERE   ((condition_category = x_condition_category) AND
               (condition_code = x_condition_name));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCAPCH_UCOC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_offer_conds;


  PROCEDURE get_fk_igs_uc_crse_dets(
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute_code                    IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2
  )  AS
  /*
  ||  Created By : bayadav
  ||  Created On : 21-NOV-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_choices
      WHERE   ((ucas_program_code = x_ucas_program_code) AND
               (institute_code = x_institute_code) AND
               (campus = x_campus) AND
               (system_code = x_system_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCAPCH_UCCSDE_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_crse_dets;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_app_choice_id                     IN     NUMBER      ,
    x_app_id                            IN     NUMBER      ,
    x_app_no                            IN     NUMBER      ,
    x_choice_no                         IN     NUMBER      ,
    x_last_change                       IN     DATE        ,
    x_institute_code                    IN     VARCHAR2    ,
    x_ucas_program_code                 IN     VARCHAR2    ,
    x_oss_program_code                  IN     VARCHAR2    ,
    x_oss_program_version               IN     NUMBER      ,
    x_oss_attendance_type               IN     VARCHAR2    ,
    x_oss_attendance_mode               IN     VARCHAR2    ,
    x_campus                            IN     VARCHAR2    ,
    x_oss_location                      IN     VARCHAR2    ,
    x_faculty                           IN     VARCHAR2    ,
    x_entry_year                        IN     NUMBER      ,
    x_entry_month                       IN     NUMBER      ,
    x_point_of_entry                    IN     NUMBER      ,
    x_home                              IN     VARCHAR2    ,
    x_deferred                          IN     VARCHAR2    ,
    x_route_b_pref_round                IN     NUMBER      ,
    x_route_b_actual_round              IN     NUMBER      ,
    x_condition_category                IN     VARCHAR2    ,
    x_condition_code                    IN     VARCHAR2    ,
    x_decision                          IN     VARCHAR2    ,
    x_decision_date                     IN     DATE        ,
    x_decision_number                   IN     NUMBER      ,
    x_reply                             IN     VARCHAR2    ,
    x_summary_of_cond                   IN     VARCHAR2    ,
    x_choice_cancelled                  IN     VARCHAR2    ,
    x_action                            IN     VARCHAR2    ,
    x_substitution                      IN     VARCHAR2    ,
    x_date_substituted                  IN     DATE        ,
    x_prev_institution                  IN     VARCHAR2    ,
    x_prev_course                       IN     VARCHAR2    ,
    x_prev_campus                       IN     VARCHAR2    ,
    x_ucas_amendment                    IN     VARCHAR2    ,
    x_withdrawal_reason                 IN     VARCHAR2    ,
    x_offer_course                      IN     VARCHAR2    ,
    x_offer_campus                      IN     VARCHAR2    ,
    x_offer_crse_length                 IN     NUMBER      ,
    x_offer_entry_month                 IN     VARCHAR2    ,
    x_offer_entry_year                  IN     VARCHAR2    ,
    x_offer_entry_point                 IN     VARCHAR2    ,
    x_offer_text                        IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
      x_export_to_oss_status              IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_request_id                        IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    -- The below column is added newly in UCFD06 - 24SEP2002 - Bug#2574566
    x_extra_round_nbr                   IN     NUMBER,
    -- The below columns are added newly in UCFD102  - Bug#2643048
    x_system_code		                    IN		 VARCHAR2		,
    x_part_time		                      IN		 VARCHAR2		,
    x_interview	                       	IN		 DATE		    ,
    x_late_application	              	IN		 VARCHAR2		,
    x_modular	                        	IN		 VARCHAR2		,
    x_residential	                    	IN		 VARCHAR2		,
    -- smaddali added this column for ucfd203 build bug #2669208
    x_ucas_cycle                        IN     NUMBER
  ) IS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  adding ucas_cycle and obsoleting timestamps for bug#2669208 ucfd203 build
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_app_choice_id,
      x_app_id,
      x_app_no,
      x_choice_no,
      x_last_change,
      x_institute_code,
      x_ucas_program_code,
      x_oss_program_code,
      x_oss_program_version,
      x_oss_attendance_type,
      x_oss_attendance_mode,
      x_campus,
      x_oss_location,
      x_faculty,
      x_entry_year,
      x_entry_month,
      x_point_of_entry,
      x_home,
      x_deferred,
      x_route_b_pref_round,
      x_route_b_actual_round,
      x_condition_category,
      x_condition_code,
      x_decision,
      x_decision_date,
      x_decision_number,
      x_reply,
      x_summary_of_cond,
      x_choice_cancelled,
      x_action,
      x_substitution,
      x_date_substituted,
      x_prev_institution,
      x_prev_course,
      x_prev_campus,
      x_ucas_amendment,
      x_withdrawal_reason,
      x_offer_course,
      x_offer_campus,
      x_offer_crse_length,
      x_offer_entry_month,
      x_offer_entry_year,
      x_offer_entry_point,
      x_offer_text,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_export_to_oss_status        ,
      x_error_code                    ,
      x_request_id      ,
      x_batch_id        ,
      x_extra_round_nbr ,
      x_system_code		  ,
      x_part_time		                                        ,
      x_interview	                       	                  ,
      x_late_application	                                 	,
      x_modular	                                          	,
      x_residential	    	 ,
      -- smaddali added new column for ucfd203 - bug#2669208
      x_ucas_cycle               );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.app_choice_id
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
             new_references.app_choice_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_choice_id                     IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_last_change                       IN     DATE,
    x_institute_code                    IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_point_of_entry                    IN     NUMBER,
    x_home                              IN     VARCHAR2,
    x_deferred                          IN     VARCHAR2,
    x_route_b_pref_round                IN     NUMBER,
    x_route_b_actual_round              IN     NUMBER,
    x_condition_category                IN     VARCHAR2,
    x_condition_code                    IN     VARCHAR2,
    x_decision                          IN     VARCHAR2,
    x_decision_date                     IN     DATE,
    x_decision_number                   IN     NUMBER,
    x_reply                             IN     VARCHAR2,
    x_summary_of_cond                   IN     VARCHAR2,
    x_choice_cancelled                  IN     VARCHAR2,
    x_action                            IN     VARCHAR2,
    x_substitution                      IN     VARCHAR2,
    x_date_substituted                  IN     DATE,
    x_prev_institution                  IN     VARCHAR2,
    x_prev_course                       IN     VARCHAR2,
    x_prev_campus                       IN     VARCHAR2,
    x_ucas_amendment                    IN     VARCHAR2,
    x_withdrawal_reason                 IN     VARCHAR2,
    x_offer_course                      IN     VARCHAR2,
    x_offer_campus                      IN     VARCHAR2,
    x_offer_crse_length                 IN     NUMBER,
    x_offer_entry_month                 IN     VARCHAR2,
    x_offer_entry_year                  IN     VARCHAR2,
    x_offer_entry_point                 IN     VARCHAR2,
    x_offer_text                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_export_to_oss_status              IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_request_id                        IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    -- The below column is added newly in UCFD06 - 24SEP2002 - Bug#2574566
    x_extra_round_nbr                   IN     NUMBER,
        -- The below column is added newly in UCFD102 - Bug#2643048
    x_system_code		                    IN		 VARCHAR2		,
    x_part_time		                      IN		 VARCHAR2		,
    x_interview	                       	IN		 DATE		    ,
    x_late_application	              	IN		 VARCHAR2		,
    x_modular	                        	IN		 VARCHAR2		,
    x_residential	                    	IN		 VARCHAR2		,
    -- smaddali added this column for ucfd203 build bug #2669208
    x_ucas_cycle                        IN     NUMBER
  ) IS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  adding ucas_cycle and obsoleting timestamps for bug#2669208 ucfd203 build
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_app_choices
      WHERE    app_choice_id                     = x_app_choice_id;

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

    SELECT    igs_uc_app_choices_s.NEXTVAL
    INTO      x_app_choice_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_app_choice_id                     => x_app_choice_id,
      x_app_id                            => x_app_id,
      x_app_no                            => x_app_no,
      x_choice_no                         => x_choice_no,
      x_last_change                       => x_last_change,
      x_institute_code                    => x_institute_code,
      x_ucas_program_code                 => x_ucas_program_code,
      x_oss_program_code                  => x_oss_program_code,
      x_oss_program_version               => x_oss_program_version,
      x_oss_attendance_type               => x_oss_attendance_type,
      x_oss_attendance_mode               => x_oss_attendance_mode,
      x_campus                            => x_campus,
      x_oss_location                      => x_oss_location,
      x_faculty                           => x_faculty,
      x_entry_year                        => x_entry_year,
      x_entry_month                       => x_entry_month,
      x_point_of_entry                    => x_point_of_entry,
      x_home                              => x_home,
      x_deferred                          => x_deferred,
      x_route_b_pref_round                => x_route_b_pref_round,
      x_route_b_actual_round              => x_route_b_actual_round,
      x_condition_category                => x_condition_category,
      x_condition_code                    => x_condition_code,
      x_decision                          => x_decision,
      x_decision_date                     => x_decision_date,
      x_decision_number                   => x_decision_number,
      x_reply                             => x_reply,
      x_summary_of_cond                   => x_summary_of_cond,
      x_choice_cancelled                  => x_choice_cancelled,
      x_action                            => x_action,
      x_substitution                      => x_substitution,
      x_date_substituted                  => x_date_substituted,
      x_prev_institution                  => x_prev_institution,
      x_prev_course                       => x_prev_course,
      x_prev_campus                       => x_prev_campus,
      x_ucas_amendment                    => x_ucas_amendment,
      x_withdrawal_reason                 => x_withdrawal_reason,
      x_offer_course                      => x_offer_course,
      x_offer_campus                      => x_offer_campus,
      x_offer_crse_length                 => x_offer_crse_length,
      x_offer_entry_month                 => x_offer_entry_month,
      x_offer_entry_year                  => x_offer_entry_year,
      x_offer_entry_point                 => x_offer_entry_point,
      x_offer_text                        => x_offer_text,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_export_to_oss_status              =>x_export_to_oss_status,
      x_error_code                        =>x_error_code ,
      x_request_id                        =>x_request_id,
      x_batch_id                          =>x_batch_id,
      x_extra_round_nbr                   => x_extra_round_nbr,
      x_system_code		                    => x_system_code,
      x_part_time		                      => x_part_time 		,
      x_interview	                        => x_interview	    ,
      x_late_application	              	=> x_late_application		,
      x_modular	                        	=> x_modular	,
      x_residential	                    	=> x_residential	,
      -- smaddali added new column for ucfd203 - bug#2669208
      x_ucas_cycle	                        => x_ucas_cycle
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_uc_app_choices (
      app_choice_id,
      app_id,
      app_no,
      choice_no,
      last_change,
      institute_code,
      ucas_program_code,
      oss_program_code,
      oss_program_version,
      oss_attendance_type,
      oss_attendance_mode,
      campus,
      oss_location,
      faculty,
      entry_year,
      entry_month,
      point_of_entry,
      home,
      deferred,
      route_b_pref_round,
      route_b_actual_round,
      condition_category,
      condition_code,
      decision,
      decision_date,
      decision_number,
      reply,
      summary_of_cond,
      choice_cancelled,
      action,
      substitution,
      date_substituted,
      prev_institution,
      prev_course,
      prev_campus,
      ucas_amendment,
      withdrawal_reason,
      offer_course,
      offer_campus,
      offer_crse_length,
      offer_entry_month,
      offer_entry_year,
      offer_entry_point,
      offer_text,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      export_to_oss_status            ,
      error_code                      ,
      request_id                      ,
      batch_id,
      extra_round_nbr,
      system_code,
      part_time,
      interview,
      late_application,
      modular,
      residential,
      -- smaddali added new column for ucfd203 - bug#2669208
      ucas_cycle
      )
      VALUES (
      new_references.app_choice_id,
      new_references.app_id,
      new_references.app_no,
      new_references.choice_no,
      new_references.last_change,
      new_references.institute_code,
      new_references.ucas_program_code,
      new_references.oss_program_code,
      new_references.oss_program_version,
      new_references.oss_attendance_type,
      new_references.oss_attendance_mode,
      new_references.campus,
      new_references.oss_location,
      new_references.faculty,
      new_references.entry_year,
      new_references.entry_month,
      new_references.point_of_entry,
      new_references.home,
      new_references.deferred,
      new_references.route_b_pref_round,
      new_references.route_b_actual_round,
      new_references.condition_category,
      new_references.condition_code,
      new_references.decision,
      new_references.decision_date,
      new_references.decision_number,
      new_references.reply,
      new_references.summary_of_cond,
      new_references.choice_cancelled,
      new_references.action,
      new_references.substitution,
      new_references.date_substituted,
      new_references.prev_institution,
      new_references.prev_course,
      new_references.prev_campus,
      new_references.ucas_amendment,
      new_references.withdrawal_reason,
      new_references.offer_course,
      new_references.offer_campus,
      new_references.offer_crse_length,
      new_references.offer_entry_month,
      new_references.offer_entry_year,
      new_references.offer_entry_point,
      new_references.offer_text,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      new_references.export_to_oss_status,
      new_references.error_code          ,
      new_references.request_id          ,
      new_references.batch_id,
      new_references.extra_round_nbr,
      new_references.system_code,
      new_references.part_time,
      new_references.interview,
      new_references.late_application,
      new_references.modular,
      new_references.residential,
      -- smaddali added new column for ucfd203 - bug#2669208
      new_references.ucas_cycle
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
    x_app_choice_id                     IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_last_change                       IN     DATE,
    x_institute_code                    IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_point_of_entry                    IN     NUMBER,
    x_home                              IN     VARCHAR2,
    x_deferred                          IN     VARCHAR2,
    x_route_b_pref_round                IN     NUMBER,
    x_route_b_actual_round              IN     NUMBER,
    x_condition_category                IN     VARCHAR2,
    x_condition_code                    IN     VARCHAR2,
    x_decision                          IN     VARCHAR2,
    x_decision_date                     IN     DATE,
    x_decision_number                   IN     NUMBER,
    x_reply                             IN     VARCHAR2,
    x_summary_of_cond                   IN     VARCHAR2,
    x_choice_cancelled                  IN     VARCHAR2,
    x_action                            IN     VARCHAR2,
    x_substitution                      IN     VARCHAR2,
    x_date_substituted                  IN     DATE,
    x_prev_institution                  IN     VARCHAR2,
    x_prev_course                       IN     VARCHAR2,
    x_prev_campus                       IN     VARCHAR2,
    x_ucas_amendment                    IN     VARCHAR2,
    x_withdrawal_reason                 IN     VARCHAR2,
    x_offer_course                      IN     VARCHAR2,
    x_offer_campus                      IN     VARCHAR2,
    x_offer_crse_length                 IN     NUMBER,
    x_offer_entry_month                 IN     VARCHAR2,
    x_offer_entry_year                  IN     VARCHAR2,
    x_offer_entry_point                 IN     VARCHAR2,
    x_offer_text                        IN     VARCHAR2,
    x_export_to_oss_status              IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_request_id                        IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    -- The below column is added newly in UCFD06 - 24SEP2002 - Bug#2574566
    x_extra_round_nbr                   IN     NUMBER,
    -- The below column is added newly in UCFD102 - Bug#2643048
    x_system_code		                    IN		 VARCHAR2		,
    x_part_time		                      IN		 VARCHAR2		,
    x_interview	                       	IN		 DATE		    ,
    x_late_application	              	IN		 VARCHAR2		,
    x_modular	                        	IN		 VARCHAR2		,
    x_residential	                    	IN		 VARCHAR2		,
    -- smaddali added this column for ucfd203 build bug #2669208
    x_ucas_cycle                        IN     NUMBER
  ) IS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  adding ucas_cycle and obsoleting timestamps for bug#2669208 ucfd203 build
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        app_id,
        app_no,
        choice_no,
        last_change,
        institute_code,
        ucas_program_code,
        oss_program_code,
        oss_program_version,
        oss_attendance_type,
        oss_attendance_mode,
        campus,
        oss_location,
        faculty,
        entry_year,
        entry_month,
        point_of_entry,
        home,
        deferred,
        route_b_pref_round,
        route_b_actual_round,
        condition_category,
        condition_code,
        decision,
        decision_date,
        decision_number,
        reply,
        summary_of_cond,
        choice_cancelled,
        action,
        substitution,
        date_substituted,
        prev_institution,
        prev_course,
        prev_campus,
        ucas_amendment,
        withdrawal_reason,
        offer_course,
        offer_campus,
        offer_crse_length,
        offer_entry_month,
        offer_entry_year,
        offer_entry_point,
        offer_text,
        export_to_oss_status  ,
        error_code ,
        request_id ,
        batch_id,
       	extra_round_nbr,
          -- The below column is added newly in UCFD102 - Bug#2643048
        system_code,
        part_time,
        interview,
        late_application,
        modular,
        residential,
        -- smaddali added new column for ucfd203 - bug#2669208
        ucas_cycle
      FROM  igs_uc_app_choices
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
        (tlinfo.app_id = x_app_id)
        AND (tlinfo.app_no = x_app_no)
        AND (tlinfo.choice_no = x_choice_no)
        AND (tlinfo.last_change = x_last_change)
        AND (tlinfo.institute_code = x_institute_code)
        AND (tlinfo.ucas_program_code = x_ucas_program_code)
        AND ((tlinfo.oss_program_code = x_oss_program_code) OR ((tlinfo.oss_program_code IS NULL) AND (X_oss_program_code IS NULL)))
        AND ((tlinfo.oss_program_version = x_oss_program_version) OR ((tlinfo.oss_program_version IS NULL) AND (X_oss_program_version IS NULL)))
        AND ((tlinfo.oss_attendance_type = x_oss_attendance_type) OR ((tlinfo.oss_attendance_type IS NULL) AND (X_oss_attendance_type IS NULL)))
        AND ((tlinfo.oss_attendance_mode = x_oss_attendance_mode) OR ((tlinfo.oss_attendance_mode IS NULL) AND (X_oss_attendance_mode IS NULL)))
        AND (tlinfo.campus = x_campus)
        AND ((tlinfo.oss_location = x_oss_location) OR ((tlinfo.oss_location IS NULL) AND (X_oss_location IS NULL)))
        AND ((tlinfo.faculty = x_faculty) OR ((tlinfo.faculty IS NULL) AND (X_faculty IS NULL)))
        AND (tlinfo.entry_year = x_entry_year)
        AND (tlinfo.entry_month = x_entry_month)
        AND ((tlinfo.point_of_entry = x_point_of_entry) OR ((tlinfo.point_of_entry IS NULL) AND (X_point_of_entry IS NULL)))
        AND (tlinfo.home = x_home)
        AND (tlinfo.deferred = x_deferred)
        AND ((tlinfo.route_b_pref_round = x_route_b_pref_round) OR ((tlinfo.route_b_pref_round IS NULL) AND (X_route_b_pref_round IS NULL)))
        AND ((tlinfo.route_b_actual_round = x_route_b_actual_round) OR ((tlinfo.route_b_actual_round IS NULL) AND (X_route_b_actual_round IS NULL)))
        AND ((tlinfo.condition_category = x_condition_category) OR ((tlinfo.condition_category IS NULL) AND (X_condition_category IS NULL)))
        AND ((tlinfo.condition_code = x_condition_code) OR ((tlinfo.condition_code IS NULL) AND (X_condition_code IS NULL)))
        AND ((tlinfo.decision = x_decision) OR ((tlinfo.decision IS NULL) AND (X_decision IS NULL)))
        AND ((tlinfo.decision_date = x_decision_date) OR ((tlinfo.decision_date IS NULL) AND (X_decision_date IS NULL)))
        AND ((tlinfo.decision_number = x_decision_number) OR ((tlinfo.decision_number IS NULL) AND (X_decision_number IS NULL)))
        AND ((tlinfo.reply = x_reply) OR ((tlinfo.reply IS NULL) AND (X_reply IS NULL)))
        AND ((tlinfo.summary_of_cond = x_summary_of_cond) OR ((tlinfo.summary_of_cond IS NULL) AND (X_summary_of_cond IS NULL)))
        AND ((tlinfo.choice_cancelled = x_choice_cancelled) OR ((tlinfo.choice_cancelled IS NULL) AND (X_choice_cancelled IS NULL)))
        AND ((tlinfo.action = x_action) OR ((tlinfo.action IS NULL) AND (X_action IS NULL)))
        AND ((tlinfo.substitution = x_substitution) OR ((tlinfo.substitution IS NULL) AND (X_substitution IS NULL)))
        AND ((tlinfo.date_substituted = x_date_substituted) OR ((tlinfo.date_substituted IS NULL) AND (X_date_substituted IS NULL)))
        AND ((tlinfo.prev_institution = x_prev_institution) OR ((tlinfo.prev_institution IS NULL) AND (X_prev_institution IS NULL)))
        AND ((tlinfo.prev_course = x_prev_course) OR ((tlinfo.prev_course IS NULL) AND (X_prev_course IS NULL)))
        AND ((tlinfo.prev_campus = x_prev_campus) OR ((tlinfo.prev_campus IS NULL) AND (X_prev_campus IS NULL)))
        AND ((tlinfo.ucas_amendment = x_ucas_amendment) OR ((tlinfo.ucas_amendment IS NULL) AND (X_ucas_amendment IS NULL)))
        AND ((tlinfo.withdrawal_reason = x_withdrawal_reason) OR ((tlinfo.withdrawal_reason IS NULL) AND (X_withdrawal_reason IS NULL)))
        AND ((tlinfo.offer_course = x_offer_course) OR ((tlinfo.offer_course IS NULL) AND (X_offer_course IS NULL)))
        AND ((tlinfo.offer_campus = x_offer_campus) OR ((tlinfo.offer_campus IS NULL) AND (X_offer_campus IS NULL)))
        AND ((tlinfo.offer_crse_length = x_offer_crse_length) OR ((tlinfo.offer_crse_length IS NULL) AND (X_offer_crse_length IS NULL)))
        AND ((tlinfo.offer_entry_month = x_offer_entry_month) OR ((tlinfo.offer_entry_month IS NULL) AND (X_offer_entry_month IS NULL)))
        AND ((tlinfo.offer_entry_year = x_offer_entry_year) OR ((tlinfo.offer_entry_year IS NULL) AND (X_offer_entry_year IS NULL)))
        AND ((tlinfo.offer_entry_point = x_offer_entry_point) OR ((tlinfo.offer_entry_point IS NULL) AND (X_offer_entry_point IS NULL)))
        AND ((tlinfo.offer_text = x_offer_text) OR ((tlinfo.offer_text IS NULL) AND (X_offer_text IS NULL)))
        AND ((tlinfo.export_to_oss_status   = x_export_to_oss_status  ) OR ((tlinfo.export_to_oss_status   IS NULL) AND (X_export_to_oss_status   IS NULL)))
        AND ((tlinfo.error_code = x_error_code) OR ((tlinfo.error_code IS NULL) AND (X_error_code IS NULL)))
        AND ((tlinfo.request_id = x_request_id) OR ((tlinfo.request_id IS NULL) AND (X_request_id IS NULL)))
        AND ((tlinfo.batch_id = x_batch_id) OR ((tlinfo.batch_id IS NULL) AND (X_batch_id IS NULL)))
        AND ((tlinfo.extra_round_nbr = x_extra_round_nbr) OR ((tlinfo.extra_round_nbr IS NULL) AND (x_extra_round_nbr IS NULL)))
        AND ((tlinfo.system_code = x_system_code) )
        AND ((tlinfo.part_time = x_part_time) OR ((tlinfo.part_time IS NULL) AND (x_part_time IS NULL)))
        AND ((tlinfo.interview = x_interview) OR ((tlinfo.interview IS NULL) AND (x_interview IS NULL)))
        AND ((tlinfo.late_application = x_late_application) OR ((tlinfo.late_application IS NULL) AND (x_late_application IS NULL)))
        AND ((tlinfo.modular = x_modular) OR ((tlinfo.modular IS NULL) AND (x_modular IS NULL)))
        AND ((tlinfo.residential = x_residential) OR ((tlinfo.residential IS NULL) AND (x_residential IS NULL)))
        -- smaddali added new column for ucfd203 - bug#2669208
        AND (tlinfo.ucas_cycle = x_ucas_cycle)
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
    x_app_choice_id                     IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_last_change                       IN     DATE,
    x_institute_code                    IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_point_of_entry                    IN     NUMBER,
    x_home                              IN     VARCHAR2,
    x_deferred                          IN     VARCHAR2,
    x_route_b_pref_round                IN     NUMBER,
    x_route_b_actual_round              IN     NUMBER,
    x_condition_category                IN     VARCHAR2,
    x_condition_code                    IN     VARCHAR2,
    x_decision                          IN     VARCHAR2,
    x_decision_date                     IN     DATE,
    x_decision_number                   IN     NUMBER,
    x_reply                             IN     VARCHAR2,
    x_summary_of_cond                   IN     VARCHAR2,
    x_choice_cancelled                  IN     VARCHAR2,
    x_action                            IN     VARCHAR2,
    x_substitution                      IN     VARCHAR2,
    x_date_substituted                  IN     DATE,
    x_prev_institution                  IN     VARCHAR2,
    x_prev_course                       IN     VARCHAR2,
    x_prev_campus                       IN     VARCHAR2,
    x_ucas_amendment                    IN     VARCHAR2,
    x_withdrawal_reason                 IN     VARCHAR2,
    x_offer_course                      IN     VARCHAR2,
    x_offer_campus                      IN     VARCHAR2,
    x_offer_crse_length                 IN     NUMBER,
    x_offer_entry_month                 IN     VARCHAR2,
    x_offer_entry_year                  IN     VARCHAR2,
    x_offer_entry_point                 IN     VARCHAR2,
    x_offer_text                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2  ,
    x_export_to_oss_status              IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_request_id                        IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    -- The below column is added newly in UCFD06 - 24SEP2002 - Bug#2574566
    x_extra_round_nbr                   IN     NUMBER,
    -- The below column is added newly in UCFD102- Bug#2643048
    x_system_code		                    IN		 VARCHAR2		,
    x_part_time		                      IN		 VARCHAR2		,
    x_interview	                       	IN		 DATE		    ,
    x_late_application	              	IN		 VARCHAR2		,
    x_modular	                        	IN		 VARCHAR2		,
    x_residential	                    	IN		 VARCHAR2		,
    -- smaddali added this column for ucfd203 build bug #2669208
    x_ucas_cycle                        IN     NUMBER
  ) IS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  adding ucas_cycle and obsoleting timestamps for bug#2669208 ucfd203 build
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
      x_app_choice_id                     => x_app_choice_id,
      x_app_id                            => x_app_id,
      x_app_no                            => x_app_no,
      x_choice_no                         => x_choice_no,
      x_last_change                       => x_last_change,
      x_institute_code                    => x_institute_code,
      x_ucas_program_code                 => x_ucas_program_code,
      x_oss_program_code                  => x_oss_program_code,
      x_oss_program_version               => x_oss_program_version,
      x_oss_attendance_type               => x_oss_attendance_type,
      x_oss_attendance_mode               => x_oss_attendance_mode,
      x_campus                            => x_campus,
      x_oss_location                      => x_oss_location,
      x_faculty                           => x_faculty,
      x_entry_year                        => x_entry_year,
      x_entry_month                       => x_entry_month,
      x_point_of_entry                    => x_point_of_entry,
      x_home                              => x_home,
      x_deferred                          => x_deferred,
      x_route_b_pref_round                => x_route_b_pref_round,
      x_route_b_actual_round              => x_route_b_actual_round,
      x_condition_category                => x_condition_category,
      x_condition_code                    => x_condition_code,
      x_decision                          => x_decision,
      x_decision_date                     => x_decision_date,
      x_decision_number                   => x_decision_number,
      x_reply                             => x_reply,
      x_summary_of_cond                   => x_summary_of_cond,
      x_choice_cancelled                  => x_choice_cancelled,
      x_action                            => x_action,
      x_substitution                      => x_substitution,
      x_date_substituted                  => x_date_substituted,
      x_prev_institution                  => x_prev_institution,
      x_prev_course                       => x_prev_course,
      x_prev_campus                       => x_prev_campus,
      x_ucas_amendment                    => x_ucas_amendment,
      x_withdrawal_reason                 => x_withdrawal_reason,
      x_offer_course                      => x_offer_course,
      x_offer_campus                      => x_offer_campus,
      x_offer_crse_length                 => x_offer_crse_length,
      x_offer_entry_month                 => x_offer_entry_month,
      x_offer_entry_year                  => x_offer_entry_year,
      x_offer_entry_point                 => x_offer_entry_point,
      x_offer_text                        => x_offer_text,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_export_to_oss_status              =>x_export_to_oss_status,
      x_error_code                        =>x_error_code ,
      x_request_id                        =>x_request_id,
      x_batch_id                          =>x_batch_id,
      x_extra_round_nbr                   =>x_extra_round_nbr,
      x_system_code		                    =>x_system_code	,
      x_part_time		                      =>x_part_time,
      x_interview	                       	=>x_interview,
      x_late_application	              	=>x_late_application,
      x_modular	                        	=>x_modular,
      x_residential	                    	=>x_residential,
      -- smaddali added new column for ucfd203 - bug#2669208
      x_ucas_cycle	                     =>  x_ucas_cycle
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_uc_app_choices
      SET
        app_id                            = new_references.app_id,
        app_no                            = new_references.app_no,
        choice_no                         = new_references.choice_no,
        last_change                       = new_references.last_change,
        institute_code                    = new_references.institute_code,
        ucas_program_code                 = new_references.ucas_program_code,
        oss_program_code                  = new_references.oss_program_code,
        oss_program_version               = new_references.oss_program_version,
        oss_attendance_type               = new_references.oss_attendance_type,
        oss_attendance_mode               = new_references.oss_attendance_mode,
        campus                            = new_references.campus,
        oss_location                      = new_references.oss_location,
        faculty                           = new_references.faculty,
        entry_year                        = new_references.entry_year,
        entry_month                       = new_references.entry_month,
        point_of_entry                    = new_references.point_of_entry,
        home                              = new_references.home,
        deferred                          = new_references.deferred,
        route_b_pref_round                = new_references.route_b_pref_round,
        route_b_actual_round              = new_references.route_b_actual_round,
        condition_category                = new_references.condition_category,
        condition_code                    = new_references.condition_code,
        decision                          = new_references.decision,
        decision_date                     = new_references.decision_date,
        decision_number                   = new_references.decision_number,
        reply                             = new_references.reply,
        summary_of_cond                   = new_references.summary_of_cond,
        choice_cancelled                  = new_references.choice_cancelled,
        action                            = new_references.action,
        substitution                      = new_references.substitution,
        date_substituted                  = new_references.date_substituted,
        prev_institution                  = new_references.prev_institution,
        prev_course                       = new_references.prev_course,
        prev_campus                       = new_references.prev_campus,
        ucas_amendment                    = new_references.ucas_amendment,
        withdrawal_reason                 = new_references.withdrawal_reason,
        offer_course                      = new_references.offer_course,
        offer_campus                      = new_references.offer_campus,
        offer_crse_length                 = new_references.offer_crse_length,
        offer_entry_month                 = new_references.offer_entry_month,
        offer_entry_year                  = new_references.offer_entry_year,
        offer_entry_point                 = new_references.offer_entry_point,
        offer_text                        = new_references.offer_text,
        last_update_date                  = new_references.last_update_date,
        last_updated_by                   = new_references.last_updated_by,
        last_update_login                 = new_references.last_update_login ,
        export_to_oss_status              = new_references.export_to_oss_status,
        error_code                        = new_references.error_code ,
        request_id                        = new_references.request_id,
        batch_id                          = new_references.batch_id,
	extra_round_nbr                   = new_references.extra_round_nbr,
      -- The below column is added newly in UCFD102- Bug#2643048
    system_code                     = new_references.system_code,
    part_time		                    = new_references.part_time		,
    interview	                      = new_references.interview    ,
    late_application	              = new_references.late_application	,
    modular	                        = new_references.modular,
    residential	                    = new_references.residential,
    -- smaddali added new column for ucfd203 - bug#2669208
    ucas_cycle	                     = new_references.ucas_cycle
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
    x_app_choice_id                     IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_choice_no                         IN     NUMBER,
    x_last_change                       IN     DATE,
    x_institute_code                    IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_point_of_entry                    IN     NUMBER,
    x_home                              IN     VARCHAR2,
    x_deferred                          IN     VARCHAR2,
    x_route_b_pref_round                IN     NUMBER,
    x_route_b_actual_round              IN     NUMBER,
    x_condition_category                IN     VARCHAR2,
    x_condition_code                    IN     VARCHAR2,
    x_decision                          IN     VARCHAR2,
    x_decision_date                     IN     DATE,
    x_decision_number                   IN     NUMBER,
    x_reply                             IN     VARCHAR2,
    x_summary_of_cond                   IN     VARCHAR2,
    x_choice_cancelled                  IN     VARCHAR2,
    x_action                            IN     VARCHAR2,
    x_substitution                      IN     VARCHAR2,
    x_date_substituted                  IN     DATE,
    x_prev_institution                  IN     VARCHAR2,
    x_prev_course                       IN     VARCHAR2,
    x_prev_campus                       IN     VARCHAR2,
    x_ucas_amendment                    IN     VARCHAR2,
    x_withdrawal_reason                 IN     VARCHAR2,
    x_offer_course                      IN     VARCHAR2,
    x_offer_campus                      IN     VARCHAR2,
    x_offer_crse_length                 IN     NUMBER,
    x_offer_entry_month                 IN     VARCHAR2,
    x_offer_entry_year                  IN     VARCHAR2,
    x_offer_entry_point                 IN     VARCHAR2,
    x_offer_text                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_export_to_oss_status              IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_request_id                        IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    -- The below column is added newly in UCFD06 - 24SEP2002 - Bug#2574566
    x_extra_round_nbr                   IN     NUMBER,
    -- The below column is added newly in UCFD102- Bug#2640438
     x_system_code		                    IN		 VARCHAR2		,
    x_part_time		                      IN		 VARCHAR2		,
    x_interview	                       	IN		 DATE		    ,
    x_late_application	              	IN		 VARCHAR2		,
    x_modular	                        	IN		 VARCHAR2		,
    x_residential	                    	IN		 VARCHAR2		,
    -- smaddali added this column for ucfd203 build bug #2669208
    x_ucas_cycle                        IN     NUMBER
  ) IS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03  adding ucas_cycle and obsoleting timestamps for bug#2669208 ucfd203 build
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_app_choices
      WHERE    app_choice_id                     = x_app_choice_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_app_choice_id,
        x_app_id,
        x_app_no,
        x_choice_no,
        x_last_change,
        x_institute_code,
        x_ucas_program_code,
        x_oss_program_code,
        x_oss_program_version,
        x_oss_attendance_type,
        x_oss_attendance_mode,
        x_campus,
        x_oss_location,
        x_faculty,
        x_entry_year,
        x_entry_month,
        x_point_of_entry,
        x_home,
        x_deferred,
        x_route_b_pref_round,
        x_route_b_actual_round,
        x_condition_category,
        x_condition_code,
        x_decision,
        x_decision_date,
        x_decision_number,
        x_reply,
        x_summary_of_cond,
        x_choice_cancelled,
        x_action,
        x_substitution,
        x_date_substituted,
        x_prev_institution,
        x_prev_course,
        x_prev_campus,
        x_ucas_amendment,
        x_withdrawal_reason,
        x_offer_course,
        x_offer_campus,
        x_offer_crse_length,
        x_offer_entry_month,
        x_offer_entry_year,
        x_offer_entry_point,
        x_offer_text,
        x_mode ,
        x_export_to_oss_status          ,
        x_error_code                    ,
        x_request_id                    ,
        x_batch_id                      ,
	x_extra_round_nbr,
   x_system_code		      ,
    x_part_time		        ,
    x_interview	          ,
    x_late_application	  ,
    x_modular	            ,
    x_residential	        		,
    -- smaddali added new column for ucfd203 - bug#2669208
    x_ucas_cycle
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_app_choice_id,
      x_app_id,
      x_app_no,
      x_choice_no,
      x_last_change,
      x_institute_code,
      x_ucas_program_code,
      x_oss_program_code,
      x_oss_program_version,
      x_oss_attendance_type,
      x_oss_attendance_mode,
      x_campus,
      x_oss_location,
      x_faculty,
      x_entry_year,
      x_entry_month,
      x_point_of_entry,
      x_home,
      x_deferred,
      x_route_b_pref_round,
      x_route_b_actual_round,
      x_condition_category,
      x_condition_code,
      x_decision,
      x_decision_date,
      x_decision_number,
      x_reply,
      x_summary_of_cond,
      x_choice_cancelled,
      x_action,
      x_substitution,
      x_date_substituted,
      x_prev_institution,
      x_prev_course,
      x_prev_campus,
      x_ucas_amendment,
      x_withdrawal_reason,
      x_offer_course,
      x_offer_campus,
      x_offer_crse_length,
      x_offer_entry_month,
      x_offer_entry_year,
      x_offer_entry_point,
      x_offer_text,
      x_mode ,
      x_export_to_oss_status ,
      x_error_code           ,
      x_request_id           ,
      x_batch_id         ,
      x_extra_round_nbr,
      x_system_code		   		,
      x_part_time		          	,
      x_interview	              ,
      x_late_application	  		,
      x_modular	            		,
      x_residential	        ,
      -- smaddali added new column for ucfd203 - bug#2669208
      x_ucas_cycle
      );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) IS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
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
 DELETE FROM igs_uc_app_choices
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


END igs_uc_app_choices_pkg;

/
