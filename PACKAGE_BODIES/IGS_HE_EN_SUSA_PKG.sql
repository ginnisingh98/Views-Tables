--------------------------------------------------------
--  DDL for Package Body IGS_HE_EN_SUSA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_EN_SUSA_PKG" AS
/* $Header: IGSWI21B.pls 120.2 2005/07/03 18:34:02 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_en_susa%ROWTYPE;
  new_references igs_he_en_susa%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_en_susa_id                   IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_unit_set_cd                       IN     VARCHAR2    ,
    x_us_version_number                 IN     NUMBER      ,
    x_sequence_number                   IN     NUMBER      ,
    x_new_he_entrant_cd                 IN     VARCHAR2    ,
    x_term_time_accom                   IN     VARCHAR2    ,
    x_disability_allow                  IN     VARCHAR2    ,
    x_additional_sup_band               IN     VARCHAR2    ,
    x_sldd_discrete_prov                IN     VARCHAR2    ,
    x_study_mode                        IN     VARCHAR2    ,
    x_study_location                    IN     VARCHAR2    ,
    x_fte_perc_override			IN	NUMBER	   ,
    x_franchising_activity              IN     VARCHAR2    ,
    x_completion_status                 IN     VARCHAR2    ,
    x_good_stand_marker                 IN     VARCHAR2    ,
    x_complete_pyr_study_cd             IN     VARCHAR2    ,
    x_credit_value_yop1                 IN     NUMBER      ,
    x_credit_value_yop2                 IN     NUMBER      ,
    x_credit_value_yop3			IN     NUMBER      ,
    x_credit_value_yop4			IN     NUMBER      ,
    x_credit_level_achieved1            IN     VARCHAR2    ,
    x_credit_level_achieved2            IN     VARCHAR2    ,
    x_credit_level_achieved3            IN     VARCHAR2    ,
    x_credit_level_achieved4            IN     VARCHAR2    ,
    x_credit_pt_achieved1               IN     NUMBER      ,
    x_credit_pt_achieved2               IN     NUMBER      ,
    x_credit_pt_achieved3               IN     NUMBER      ,
    x_credit_pt_achieved4               IN     NUMBER      ,
    x_credit_level1                     IN     VARCHAR2    ,
    x_credit_level2                     IN     VARCHAR2    ,
    x_credit_level3                     IN     VARCHAR2    ,
    x_credit_level4                     IN     VARCHAR2    ,
    x_additional_sup_cost               IN     NUMBER      ,
    x_enh_fund_elig_cd                  IN     VARCHAR2    ,
    x_disadv_uplift_factor              IN     NUMBER      ,
    x_year_stu                          IN     NUMBER      ,
    x_grad_sch_grade                    IN     VARCHAR2    ,
    x_mark                              IN     NUMBER      ,
    x_teaching_inst1                    IN     VARCHAR2    ,
    x_teaching_inst2                    IN     VARCHAR2    ,
    x_pro_not_taught                    IN     NUMBER      ,
    x_fundability_code                  IN     VARCHAR2    ,
    x_fee_eligibility                   IN     VARCHAR2    ,
    x_fee_band                          IN     VARCHAR2    ,
    x_non_payment_reason                IN     VARCHAR2    ,
    x_student_fee                       IN     VARCHAR2    ,
    x_fte_intensity			IN 	NUMBER	   ,
    x_calculated_fte			IN	NUMBER	   ,
    x_fte_calc_type			IN	VARCHAR2   ,
    x_type_of_year   IN     VARCHAR2	  ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga	     8-Apr-2002	  Added 3 new parameters x_fte_intensity,x_calculated_fte
  ||				   and x_fte_calc_type as part of #2278825
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_EN_SUSA
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
    new_references.hesa_en_susa_id                   := x_hesa_en_susa_id;
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.unit_set_cd                       := x_unit_set_cd;
    new_references.us_version_number                 := x_us_version_number;
    new_references.sequence_number                   := x_sequence_number;
    new_references.new_he_entrant_cd                 := x_new_he_entrant_cd;
    new_references.term_time_accom                   := x_term_time_accom;
    new_references.disability_allow                  := x_disability_allow;
    new_references.additional_sup_band               := x_additional_sup_band;
    new_references.sldd_discrete_prov                := x_sldd_discrete_prov;
    new_references.study_mode                        := x_study_mode;
    new_references.study_location                    := x_study_location;
     new_references.fte_perc_override                := x_fte_perc_override;
   new_references.franchising_activity              := x_franchising_activity;
    new_references.completion_status                 := x_completion_status;
    new_references.good_stand_marker                 := x_good_stand_marker;
    new_references.complete_pyr_study_cd             := x_complete_pyr_study_cd;
    new_references.credit_value_yop1                 := x_credit_value_yop1;
    new_references.credit_value_yop2                 := x_credit_value_yop2;
    new_references.credit_value_yop3                 := x_credit_value_yop3;
    new_references.credit_value_yop4                 := x_credit_value_yop4;
    new_references.credit_level_achieved1            := x_credit_level_achieved1;
    new_references.credit_level_achieved2            := x_credit_level_achieved2;
    new_references.credit_level_achieved3            := x_credit_level_achieved3;
    new_references.credit_level_achieved4            := x_credit_level_achieved4;
    new_references.credit_pt_achieved1               := x_credit_pt_achieved1;
    new_references.credit_pt_achieved2               := x_credit_pt_achieved2;
    new_references.credit_pt_achieved3               := x_credit_pt_achieved3;
    new_references.credit_pt_achieved4               := x_credit_pt_achieved4;
    new_references.credit_level1                     := x_credit_level1;
    new_references.credit_level2                     := x_credit_level2;
    new_references.credit_level3                     := x_credit_level3;
    new_references.credit_level4                     := x_credit_level4;
    new_references.additional_sup_cost               := x_additional_sup_cost;
    new_references.enh_fund_elig_cd                  := x_enh_fund_elig_cd;
    new_references.disadv_uplift_factor              := x_disadv_uplift_factor;
    new_references.year_stu                          := x_year_stu;
    new_references.grad_sch_grade                    := x_grad_sch_grade;
    new_references.mark                              := x_mark;
    new_references.teaching_inst1                    := x_teaching_inst1;
    new_references.teaching_inst2                    := x_teaching_inst2;
    new_references.pro_not_taught                    := x_pro_not_taught;
    new_references.fundability_code                  := x_fundability_code;
    new_references.fee_eligibility                   := x_fee_eligibility;
    new_references.fee_band                          := x_fee_band;
    new_references.non_payment_reason                := x_non_payment_reason;
    new_references.student_fee                       := x_student_fee;
    new_references.fte_intensity		     := x_fte_intensity;
    new_references.calculated_fte		     := x_calculated_fte;
    new_references.fte_calc_type		     := x_fte_calc_type;
    new_references.type_of_year		       := x_type_of_year;


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
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.person_id,
           new_references.course_cd,
           new_references.unit_set_cd,
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
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.sequence_number = new_references.sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.unit_set_cd IS NULL) OR
         (new_references.sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_su_setatmpt_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.course_cd,
                new_references.unit_set_cd,
                new_references.sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_hesa_en_susa_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_en_susa
      WHERE    hesa_en_susa_id = x_hesa_en_susa_id
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_en_susa
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      unit_set_cd = x_unit_set_cd
      AND      sequence_number = x_sequence_number
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


  PROCEDURE get_fk_igs_as_su_setatmpt (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_en_susa
      WHERE   ((course_cd = x_course_cd) AND
               (person_id = x_person_id) AND
               (sequence_number = x_sequence_number) AND
               (unit_set_cd = x_unit_set_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'HES_ASS_FKIGS_AS_SU_SETATMPT');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_su_setatmpt;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_en_susa_id                   IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_unit_set_cd                       IN     VARCHAR2    ,
    x_us_version_number                 IN     NUMBER      ,
    x_sequence_number                   IN     NUMBER      ,
    x_new_he_entrant_cd                 IN     VARCHAR2    ,
    x_term_time_accom                   IN     VARCHAR2    ,
    x_disability_allow                  IN     VARCHAR2    ,
    x_additional_sup_band               IN     VARCHAR2    ,
    x_sldd_discrete_prov                IN     VARCHAR2    ,
    x_study_mode                        IN     VARCHAR2    ,
    x_study_location                    IN     VARCHAR2    ,
    x_fte_perc_override			IN	NUMBER	   ,
    x_franchising_activity              IN     VARCHAR2    ,
    x_completion_status                 IN     VARCHAR2    ,
    x_good_stand_marker                 IN     VARCHAR2    ,
    x_complete_pyr_study_cd             IN     VARCHAR2    ,
    x_credit_value_yop1                 IN     NUMBER      ,
    x_credit_value_yop2                 IN     NUMBER      ,
    x_credit_value_yop3                 IN     NUMBER      ,
    x_credit_value_yop4                 IN     NUMBER      ,
    x_credit_level_achieved1            IN     VARCHAR2    ,
    x_credit_level_achieved2            IN     VARCHAR2    ,
    x_credit_level_achieved3            IN     VARCHAR2    ,
    x_credit_level_achieved4            IN     VARCHAR2    ,
    x_credit_pt_achieved1               IN     NUMBER      ,
    x_credit_pt_achieved2               IN     NUMBER      ,
    x_credit_pt_achieved3               IN     NUMBER      ,
    x_credit_pt_achieved4               IN     NUMBER      ,
    x_credit_level1                     IN     VARCHAR2    ,
    x_credit_level2                     IN     VARCHAR2    ,
    x_credit_level3                     IN     VARCHAR2    ,
    x_credit_level4                     IN     VARCHAR2    ,
    x_additional_sup_cost               IN     NUMBER      ,
    x_enh_fund_elig_cd                  IN     VARCHAR2    ,
    x_disadv_uplift_factor              IN     NUMBER      ,
    x_year_stu                          IN     NUMBER      ,
    x_grad_sch_grade                    IN     VARCHAR2    ,
    x_mark                              IN     NUMBER      ,
    x_teaching_inst1                    IN     VARCHAR2    ,
    x_teaching_inst2                    IN     VARCHAR2    ,
    x_pro_not_taught                    IN     NUMBER      ,
    x_fundability_code                  IN     VARCHAR2    ,
    x_fee_eligibility                   IN     VARCHAR2    ,
    x_fee_band                          IN     VARCHAR2    ,
    x_non_payment_reason                IN     VARCHAR2    ,
    x_student_fee                       IN     VARCHAR2    ,
    x_fte_intensity			IN 	NUMBER	   ,
    x_calculated_fte			IN	NUMBER	   ,
    x_fte_calc_type			IN	VARCHAR2   ,
    x_type_of_year   IN     VARCHAR2	  ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga	     8-Apr-2002	  Added 3 new parameters x_fte_intensity,x_calculated_fte
  ||				   and x_fte_calc_type as part of #2278825
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_hesa_en_susa_id,
      x_person_id,
      x_course_cd,
      x_unit_set_cd,
      x_us_version_number,
      x_sequence_number,
      x_new_he_entrant_cd,
      x_term_time_accom,
      x_disability_allow,
      x_additional_sup_band,
      x_sldd_discrete_prov,
      x_study_mode,
      x_study_location,
      x_fte_perc_override,
      x_franchising_activity,
      x_completion_status,
      x_good_stand_marker,
      x_complete_pyr_study_cd,
      x_credit_value_yop1,
      x_credit_value_yop2,
      x_credit_value_yop3,
      x_credit_value_yop4,
      x_credit_level_achieved1,
      x_credit_level_achieved2,
      x_credit_level_achieved3,
      x_credit_level_achieved4,
      x_credit_pt_achieved1,
      x_credit_pt_achieved2,
      x_credit_pt_achieved3,
      x_credit_pt_achieved4,
      x_credit_level1,
      x_credit_level2,
      x_credit_level3,
      x_credit_level4,
      x_additional_sup_cost,
      x_enh_fund_elig_cd,
      x_disadv_uplift_factor,
      x_year_stu,
      x_grad_sch_grade,
      x_mark,
      x_teaching_inst1,
      x_teaching_inst2,
      x_pro_not_taught,
      x_fundability_code,
      x_fee_eligibility,
      x_fee_band,
      x_non_payment_reason,
      x_student_fee,
      x_fte_intensity,
      x_calculated_fte,
      x_fte_calc_type,
      x_type_of_year,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.hesa_en_susa_id
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
             new_references.hesa_en_susa_id
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
    x_hesa_en_susa_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_sequence_number                   IN     NUMBER,
    x_new_he_entrant_cd                 IN     VARCHAR2,
    x_term_time_accom                   IN     VARCHAR2,
    x_disability_allow                  IN     VARCHAR2,
    x_additional_sup_band               IN     VARCHAR2,
    x_sldd_discrete_prov                IN     VARCHAR2,
    x_study_mode                        IN     VARCHAR2,
    x_study_location                    IN     VARCHAR2,
    x_fte_perc_override			IN	NUMBER,
    x_franchising_activity              IN     VARCHAR2,
    x_completion_status                 IN     VARCHAR2,
    x_good_stand_marker                 IN     VARCHAR2,
    x_complete_pyr_study_cd             IN     VARCHAR2,
    x_credit_value_yop1                 IN     NUMBER,
    x_credit_value_yop2                 IN     NUMBER,
    x_credit_value_yop3                 IN     NUMBER,
    x_credit_value_yop4                 IN     NUMBER,
    x_credit_level_achieved1            IN     VARCHAR2,
    x_credit_level_achieved2            IN     VARCHAR2,
    x_credit_level_achieved3            IN     VARCHAR2,
    x_credit_level_achieved4            IN     VARCHAR2,
    x_credit_pt_achieved1               IN     NUMBER,
    x_credit_pt_achieved2               IN     NUMBER,
    x_credit_pt_achieved3               IN     NUMBER,
    x_credit_pt_achieved4               IN     NUMBER,
    x_credit_level1                     IN     VARCHAR2,
    x_credit_level2                     IN     VARCHAR2,
    x_credit_level3                     IN     VARCHAR2,
    x_credit_level4                     IN     VARCHAR2,
    x_additional_sup_cost               IN     NUMBER,
    x_enh_fund_elig_cd                  IN     VARCHAR2,
    x_disadv_uplift_factor              IN     NUMBER,
    x_year_stu                          IN     NUMBER,
    x_grad_sch_grade                    IN     VARCHAR2,
    x_mark                              IN     NUMBER,
    x_teaching_inst1                    IN     VARCHAR2,
    x_teaching_inst2                    IN     VARCHAR2,
    x_pro_not_taught                    IN     NUMBER,
    x_fundability_code                  IN     VARCHAR2,
    x_fee_eligibility                   IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_non_payment_reason                IN     VARCHAR2,
    x_student_fee                       IN     VARCHAR2,
    x_fte_intensity			IN 	NUMBER	   ,
    x_calculated_fte			IN	NUMBER	   ,
    x_fte_calc_type			IN	VARCHAR2    ,
    x_type_of_year   IN     VARCHAR2	  ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga	     8-Apr-2002	  Added 3 new parameters x_fte_intensity,x_calculated_fte
  ||				   and x_fte_calc_type as part of #2278825
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_en_susa
      WHERE    hesa_en_susa_id                   = x_hesa_en_susa_id;

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

    SELECT    igs_he_en_susa_s.NEXTVAL
    INTO      x_hesa_en_susa_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_hesa_en_susa_id                   => x_hesa_en_susa_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_unit_set_cd                       => x_unit_set_cd,
      x_us_version_number                 => x_us_version_number,
      x_sequence_number                   => x_sequence_number,
      x_new_he_entrant_cd                 => x_new_he_entrant_cd,
      x_term_time_accom                   => x_term_time_accom,
      x_disability_allow                  => x_disability_allow,
      x_additional_sup_band               => x_additional_sup_band,
      x_sldd_discrete_prov                => x_sldd_discrete_prov,
      x_study_mode                        => x_study_mode,
      x_study_location                    => x_study_location,
      x_fte_perc_override		  => x_fte_perc_override,
      x_franchising_activity              => x_franchising_activity,
      x_completion_status                 => x_completion_status,
      x_good_stand_marker                 => x_good_stand_marker,
      x_complete_pyr_study_cd             => x_complete_pyr_study_cd,
      x_credit_value_yop1                 => x_credit_value_yop1,
      x_credit_value_yop2                 => x_credit_value_yop2,
      x_credit_value_yop3                 => x_credit_value_yop3,
      x_credit_value_yop4                 => x_credit_value_yop4,
      x_credit_level_achieved1            => x_credit_level_achieved1,
      x_credit_level_achieved2            => x_credit_level_achieved2,
      x_credit_level_achieved3            => x_credit_level_achieved3,
      x_credit_level_achieved4            => x_credit_level_achieved4,
      x_credit_pt_achieved1               => x_credit_pt_achieved1,
      x_credit_pt_achieved2               => x_credit_pt_achieved2,
      x_credit_pt_achieved3               => x_credit_pt_achieved3,
      x_credit_pt_achieved4               => x_credit_pt_achieved4,
      x_credit_level1                     => x_credit_level1,
      x_credit_level2                     => x_credit_level2,
      x_credit_level3                     => x_credit_level3,
      x_credit_level4                     => x_credit_level4,
      x_additional_sup_cost               => x_additional_sup_cost,
      x_enh_fund_elig_cd                  => x_enh_fund_elig_cd,
      x_disadv_uplift_factor              => x_disadv_uplift_factor,
      x_year_stu                          => x_year_stu,
      x_grad_sch_grade                    => x_grad_sch_grade,
      x_mark                              => x_mark,
      x_teaching_inst1                    => x_teaching_inst1,
      x_teaching_inst2                    => x_teaching_inst2,
      x_pro_not_taught                    => x_pro_not_taught,
      x_fundability_code                  => x_fundability_code,
      x_fee_eligibility                   => x_fee_eligibility,
      x_fee_band                          => x_fee_band,
      x_non_payment_reason                => x_non_payment_reason,
      x_student_fee                       => x_student_fee,
      x_fte_intensity			  => x_fte_intensity,
      x_calculated_fte			  => x_calculated_fte,
      x_fte_calc_type			  => x_fte_calc_type,
      x_type_of_year    => x_type_of_year,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_he_en_susa (
      hesa_en_susa_id,
      person_id,
      course_cd,
      unit_set_cd,
      us_version_number,
      sequence_number,
      new_he_entrant_cd,
      term_time_accom,
      disability_allow,
      additional_sup_band,
      sldd_discrete_prov,
      study_mode,
      study_location,
      fte_perc_override,
      franchising_activity,
      completion_status,
      good_stand_marker,
      complete_pyr_study_cd,
      credit_value_yop1,
      credit_value_yop2,
      credit_value_yop3,
      credit_value_yop4,
      credit_level_achieved1,
      credit_level_achieved2,
      credit_level_achieved3,
      credit_level_achieved4,
      credit_pt_achieved1,
      credit_pt_achieved2,
      credit_pt_achieved3,
      credit_pt_achieved4,
      credit_level1,
      credit_level2,
      credit_level3,
      credit_level4,
      additional_sup_cost,
      enh_fund_elig_cd,
      disadv_uplift_factor,
      year_stu,
      grad_sch_grade,
      mark,
      teaching_inst1,
      teaching_inst2,
      pro_not_taught,
      fundability_code,
      fee_eligibility,
      fee_band,
      non_payment_reason,
      student_fee,
      fte_intensity,
      calculated_fte,
      fte_calc_type,
      type_of_year,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.hesa_en_susa_id,
      new_references.person_id,
      new_references.course_cd,
      new_references.unit_set_cd,
      new_references.us_version_number,
      new_references.sequence_number,
      new_references.new_he_entrant_cd,
      new_references.term_time_accom,
      new_references.disability_allow,
      new_references.additional_sup_band,
      new_references.sldd_discrete_prov,
      new_references.study_mode,
      new_references.study_location,
      new_references.fte_perc_override,
      new_references.franchising_activity,
      new_references.completion_status,
      new_references.good_stand_marker,
      new_references.complete_pyr_study_cd,
      new_references.credit_value_yop1,
      new_references.credit_value_yop2,
      new_references.credit_value_yop3,
      new_references.credit_value_yop4,
      new_references.credit_level_achieved1,
      new_references.credit_level_achieved2,
      new_references.credit_level_achieved3,
      new_references.credit_level_achieved4,
      new_references.credit_pt_achieved1,
      new_references.credit_pt_achieved2,
      new_references.credit_pt_achieved3,
      new_references.credit_pt_achieved4,
      new_references.credit_level1,
      new_references.credit_level2,
      new_references.credit_level3,
      new_references.credit_level4,
      new_references.additional_sup_cost,
      new_references.enh_fund_elig_cd,
      new_references.disadv_uplift_factor,
      new_references.year_stu,
      new_references.grad_sch_grade,
      new_references.mark,
      new_references.teaching_inst1,
      new_references.teaching_inst2,
      new_references.pro_not_taught,
      new_references.fundability_code,
      new_references.fee_eligibility,
      new_references.fee_band,
      new_references.non_payment_reason,
      new_references.student_fee,
        new_references.fte_intensity,
           new_references.calculated_fte,
      new_references.fte_calc_type,
      new_references.type_of_year,
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
    x_hesa_en_susa_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_sequence_number                   IN     NUMBER,
    x_new_he_entrant_cd                 IN     VARCHAR2,
    x_term_time_accom                   IN     VARCHAR2,
    x_disability_allow                  IN     VARCHAR2,
    x_additional_sup_band               IN     VARCHAR2,
    x_sldd_discrete_prov                IN     VARCHAR2,
    x_study_mode                        IN     VARCHAR2,
    x_study_location                    IN     VARCHAR2,
    x_fte_perc_override			IN	NUMBER	,
    x_franchising_activity              IN     VARCHAR2,
    x_completion_status                 IN     VARCHAR2,
    x_good_stand_marker                 IN     VARCHAR2,
    x_complete_pyr_study_cd             IN     VARCHAR2,
    x_credit_value_yop1                 IN     NUMBER,
    x_credit_value_yop2                 IN     NUMBER,
    x_credit_value_yop3                 IN     NUMBER,
    x_credit_value_yop4                 IN     NUMBER,
    x_credit_level_achieved1            IN     VARCHAR2,
    x_credit_level_achieved2            IN     VARCHAR2,
    x_credit_level_achieved3            IN     VARCHAR2,
    x_credit_level_achieved4            IN     VARCHAR2,
    x_credit_pt_achieved1               IN     NUMBER,
    x_credit_pt_achieved2               IN     NUMBER,
    x_credit_pt_achieved3               IN     NUMBER,
    x_credit_pt_achieved4               IN     NUMBER,
    x_credit_level1                     IN     VARCHAR2,
    x_credit_level2                     IN     VARCHAR2,
    x_credit_level3                     IN     VARCHAR2,
    x_credit_level4                     IN     VARCHAR2,
    x_additional_sup_cost               IN     NUMBER,
    x_enh_fund_elig_cd                  IN     VARCHAR2,
    x_disadv_uplift_factor              IN     NUMBER,
    x_year_stu                          IN     NUMBER,
    x_grad_sch_grade                    IN     VARCHAR2,
    x_mark                              IN     NUMBER,
    x_teaching_inst1                    IN     VARCHAR2,
    x_teaching_inst2                    IN     VARCHAR2,
    x_pro_not_taught                    IN     NUMBER,
    x_fundability_code                  IN     VARCHAR2,
    x_fee_eligibility                   IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_non_payment_reason                IN     VARCHAR2,
    x_student_fee                       IN     VARCHAR2,
    x_fte_intensity			IN 	NUMBER	   ,
    x_calculated_fte			IN	NUMBER	   ,
    x_fte_calc_type			IN	VARCHAR2     ,
    x_type_of_year   IN     VARCHAR2

  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga	     8-Apr-2002	  Added 3 new parameters x_fte_intensity,x_calculated_fte
  ||				   and x_fte_calc_type as part of #2278825
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        course_cd,
        unit_set_cd,
        us_version_number,
        sequence_number,
        new_he_entrant_cd,
        term_time_accom,
        disability_allow,
        additional_sup_band,
        sldd_discrete_prov,
        study_mode,
        study_location,
        fte_perc_override,
        franchising_activity,
        completion_status,
        good_stand_marker,
        complete_pyr_study_cd,
        credit_value_yop1,
        credit_value_yop2,
        credit_value_yop3,
	credit_value_yop4,
        credit_level_achieved1,
        credit_level_achieved2,
        credit_level_achieved3,
        credit_level_achieved4,
        credit_pt_achieved1,
        credit_pt_achieved2,
        credit_pt_achieved3,
        credit_pt_achieved4,
        credit_level1,
        credit_level2,
        credit_level3,
	credit_level4,
	additional_sup_cost,
	enh_fund_elig_cd,
	disadv_uplift_factor,
	year_stu,
        grad_sch_grade,
        mark,
        teaching_inst1,
        teaching_inst2,
        pro_not_taught,
        fundability_code,
        fee_eligibility,
        fee_band,
        non_payment_reason,
        student_fee,
        fte_intensity,
        calculated_fte,
        fte_calc_type,
        type_of_year
      FROM  igs_he_en_susa
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
        AND (tlinfo.course_cd = x_course_cd)
        AND (tlinfo.unit_set_cd = x_unit_set_cd)
        AND (tlinfo.us_version_number = x_us_version_number)
        AND (tlinfo.sequence_number = x_sequence_number)
        AND ((tlinfo.new_he_entrant_cd = x_new_he_entrant_cd) OR ((tlinfo.new_he_entrant_cd IS NULL) AND (X_new_he_entrant_cd IS NULL)))
        AND ((tlinfo.term_time_accom = x_term_time_accom) OR ((tlinfo.term_time_accom IS NULL) AND (X_term_time_accom IS NULL)))
        AND ((tlinfo.disability_allow = x_disability_allow) OR ((tlinfo.disability_allow IS NULL) AND (X_disability_allow IS NULL)))
        AND ((tlinfo.additional_sup_band = x_additional_sup_band) OR ((tlinfo.additional_sup_band IS NULL) AND (X_additional_sup_band IS NULL)))
        AND ((tlinfo.sldd_discrete_prov = x_sldd_discrete_prov) OR ((tlinfo.sldd_discrete_prov IS NULL) AND (X_sldd_discrete_prov IS NULL)))
        AND ((tlinfo.study_mode = x_study_mode) OR ((tlinfo.study_mode IS NULL) AND (X_study_mode IS NULL)))
        AND ((tlinfo.study_location = x_study_location) OR ((tlinfo.study_location IS NULL) AND (X_study_location IS NULL)))
        AND ((tlinfo.fte_perc_override = x_fte_perc_override) OR ((tlinfo.fte_perc_override IS NULL) AND (X_fte_perc_override IS NULL)))
       AND ((tlinfo.franchising_activity = x_franchising_activity) OR ((tlinfo.franchising_activity IS NULL) AND (X_franchising_activity IS NULL)))
        AND ((tlinfo.completion_status = x_completion_status) OR ((tlinfo.completion_status IS NULL) AND (X_completion_status IS NULL)))
        AND ((tlinfo.good_stand_marker = x_good_stand_marker) OR ((tlinfo.good_stand_marker IS NULL) AND (X_good_stand_marker IS NULL)))
        AND ((tlinfo.complete_pyr_study_cd = x_complete_pyr_study_cd) OR ((tlinfo.complete_pyr_study_cd IS NULL) AND (X_complete_pyr_study_cd IS NULL)))
        AND ((tlinfo.credit_value_yop1 = x_credit_value_yop1) OR ((tlinfo.credit_value_yop1 IS NULL) AND (X_credit_value_yop1 IS NULL)))
        AND ((tlinfo.credit_value_yop2 = x_credit_value_yop2) OR ((tlinfo.credit_value_yop2 IS NULL) AND (X_credit_value_yop2 IS NULL)))
        AND ((tlinfo.credit_value_yop3 = x_credit_value_yop3) OR ((tlinfo.credit_value_yop3 IS NULL) AND (X_credit_value_yop3 IS NULL)))
        AND ((tlinfo.credit_value_yop4 = x_credit_value_yop4) OR ((tlinfo.credit_value_yop4 IS NULL) AND (X_credit_value_yop4 IS NULL)))
        AND ((tlinfo.credit_level_achieved1 = x_credit_level_achieved1) OR ((tlinfo.credit_level_achieved1 IS NULL) AND (X_credit_level_achieved1 IS NULL)))
        AND ((tlinfo.credit_level_achieved2 = x_credit_level_achieved2) OR ((tlinfo.credit_level_achieved2 IS NULL) AND (X_credit_level_achieved2 IS NULL)))
        AND ((tlinfo.credit_level_achieved3 = x_credit_level_achieved3) OR ((tlinfo.credit_level_achieved3 IS NULL) AND (X_credit_level_achieved3 IS NULL)))
        AND ((tlinfo.credit_level_achieved4 = x_credit_level_achieved4) OR ((tlinfo.credit_level_achieved4 IS NULL) AND (X_credit_level_achieved4 IS NULL)))
        AND ((tlinfo.credit_pt_achieved1 = x_credit_pt_achieved1) OR ((tlinfo.credit_pt_achieved1 IS NULL) AND (X_credit_pt_achieved1 IS NULL)))
        AND ((tlinfo.credit_pt_achieved2 = x_credit_pt_achieved2) OR ((tlinfo.credit_pt_achieved2 IS NULL) AND (X_credit_pt_achieved2 IS NULL)))
        AND ((tlinfo.credit_pt_achieved3 = x_credit_pt_achieved3) OR ((tlinfo.credit_pt_achieved3 IS NULL) AND (X_credit_pt_achieved3 IS NULL)))
        AND ((tlinfo.credit_pt_achieved4 = x_credit_pt_achieved4) OR ((tlinfo.credit_pt_achieved4 IS NULL) AND (X_credit_pt_achieved4 IS NULL)))
        AND ((tlinfo.credit_level1 = x_credit_level1) OR ((tlinfo.credit_level1 IS NULL) AND (X_credit_level1 IS NULL)))
        AND ((tlinfo.credit_level2 = x_credit_level2) OR ((tlinfo.credit_level2 IS NULL) AND (X_credit_level2 IS NULL)))
        AND ((tlinfo.credit_level3 = x_credit_level3) OR ((tlinfo.credit_level3 IS NULL) AND (X_credit_level3 IS NULL)))
        AND ((tlinfo.credit_level4 = x_credit_level4) OR ((tlinfo.credit_level4 IS NULL) AND (X_credit_level4 IS NULL)))
        AND ((tlinfo.additional_sup_cost = x_additional_sup_cost) OR ((tlinfo.additional_sup_cost IS NULL) AND (X_additional_sup_cost IS NULL)))
        AND ((tlinfo.enh_fund_elig_cd = x_enh_fund_elig_cd) OR ((tlinfo.enh_fund_elig_cd IS NULL) AND (X_enh_fund_elig_cd IS NULL)))
        AND ((tlinfo.disadv_uplift_factor = x_disadv_uplift_factor) OR ((tlinfo.disadv_uplift_factor IS NULL) AND (X_disadv_uplift_factor IS NULL)))
        AND ((tlinfo.year_stu = x_year_stu) OR ((tlinfo.year_stu IS NULL) AND (X_year_stu IS NULL)))
        AND ((tlinfo.grad_sch_grade = x_grad_sch_grade) OR ((tlinfo.grad_sch_grade IS NULL) AND (X_grad_sch_grade IS NULL)))
        AND ((tlinfo.mark = x_mark) OR ((tlinfo.mark IS NULL) AND (X_mark IS NULL)))
        AND ((tlinfo.teaching_inst1 = x_teaching_inst1) OR ((tlinfo.teaching_inst1 IS NULL) AND (X_teaching_inst1 IS NULL)))
        AND ((tlinfo.teaching_inst2 = x_teaching_inst2) OR ((tlinfo.teaching_inst2 IS NULL) AND (X_teaching_inst2 IS NULL)))
        AND ((tlinfo.pro_not_taught = x_pro_not_taught) OR ((tlinfo.pro_not_taught IS NULL) AND (X_pro_not_taught IS NULL)))
        AND ((tlinfo.fundability_code = x_fundability_code) OR ((tlinfo.fundability_code IS NULL) AND (X_fundability_code IS NULL)))
        AND ((tlinfo.fee_eligibility = x_fee_eligibility) OR ((tlinfo.fee_eligibility IS NULL) AND (X_fee_eligibility IS NULL)))
        AND ((tlinfo.fee_band = x_fee_band) OR ((tlinfo.fee_band IS NULL) AND (X_fee_band IS NULL)))
        AND ((tlinfo.non_payment_reason = x_non_payment_reason) OR ((tlinfo.non_payment_reason IS NULL) AND (X_non_payment_reason IS NULL)))
        AND ((tlinfo.student_fee = x_student_fee) OR ((tlinfo.student_fee IS NULL) AND (X_student_fee IS NULL)))
        AND ((tlinfo.fte_intensity = x_fte_intensity) OR ((tlinfo.fte_intensity IS NULL) AND (X_fte_intensity IS NULL)))
        AND ((tlinfo.calculated_fte = x_calculated_fte) OR ((tlinfo.calculated_fte IS NULL) AND (X_calculated_fte IS NULL)))
        AND ((tlinfo.fte_calc_type = x_fte_calc_type) OR ((tlinfo.fte_calc_type IS NULL) AND (X_fte_calc_type IS NULL)))
        AND ((tlinfo.type_of_year = x_type_of_year) OR ((tlinfo.type_of_year IS NULL) AND (X_type_of_year IS NULL)))
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
    x_hesa_en_susa_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_sequence_number                   IN     NUMBER,
    x_new_he_entrant_cd                 IN     VARCHAR2,
    x_term_time_accom                   IN     VARCHAR2,
    x_disability_allow                  IN     VARCHAR2,
    x_additional_sup_band               IN     VARCHAR2,
    x_sldd_discrete_prov                IN     VARCHAR2,
    x_study_mode                        IN     VARCHAR2,
    x_study_location                    IN     VARCHAR2,
    x_fte_perc_override			IN	NUMBER	,
    x_franchising_activity              IN     VARCHAR2,
    x_completion_status                 IN     VARCHAR2,
    x_good_stand_marker                 IN     VARCHAR2,
    x_complete_pyr_study_cd             IN     VARCHAR2,
    x_credit_value_yop1                 IN     NUMBER,
    x_credit_value_yop2                 IN     NUMBER,
    x_credit_value_yop3                 IN     NUMBER,
    x_credit_value_yop4                 IN     NUMBER,
    x_credit_level_achieved1            IN     VARCHAR2,
    x_credit_level_achieved2            IN     VARCHAR2,
    x_credit_level_achieved3            IN     VARCHAR2,
    x_credit_level_achieved4            IN     VARCHAR2,
    x_credit_pt_achieved1               IN     NUMBER,
    x_credit_pt_achieved2               IN     NUMBER,
    x_credit_pt_achieved3               IN     NUMBER,
    x_credit_pt_achieved4               IN     NUMBER,
    x_credit_level1                     IN     VARCHAR2,
    x_credit_level2                     IN     VARCHAR2,
    x_credit_level3                     IN     VARCHAR2,
    x_credit_level4                     IN     VARCHAR2,
    x_additional_sup_cost               IN     NUMBER,
    x_enh_fund_elig_cd                  IN     VARCHAR2,
    x_disadv_uplift_factor              IN     NUMBER,
    x_year_stu                          IN     NUMBER,
    x_grad_sch_grade                    IN     VARCHAR2,
    x_mark                              IN     NUMBER,
    x_teaching_inst1                    IN     VARCHAR2,
    x_teaching_inst2                    IN     VARCHAR2,
    x_pro_not_taught                    IN     NUMBER,
    x_fundability_code                  IN     VARCHAR2,
    x_fee_eligibility                   IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_non_payment_reason                IN     VARCHAR2,
    x_student_fee                       IN     VARCHAR2,
    x_fte_intensity			IN 	NUMBER	   ,
    x_calculated_fte			IN	NUMBER	   ,
    x_fte_calc_type			IN	VARCHAR2    ,
    x_type_of_year   IN     VARCHAR2	  ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||sbaliga	8-Apr-2002	Added 3 new parameters x_fte_intensity,x_calculated_fte and
  ||				x_fte_calc_type as part of #2278825
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
      x_hesa_en_susa_id                   => x_hesa_en_susa_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_unit_set_cd                       => x_unit_set_cd,
      x_us_version_number                 => x_us_version_number,
      x_sequence_number                   => x_sequence_number,
      x_new_he_entrant_cd                 => x_new_he_entrant_cd,
      x_term_time_accom                   => x_term_time_accom,
      x_disability_allow                  => x_disability_allow,
      x_additional_sup_band               => x_additional_sup_band,
      x_sldd_discrete_prov                => x_sldd_discrete_prov,
      x_study_mode                        => x_study_mode,
      x_study_location                    => x_study_location,
       x_fte_perc_override                => x_fte_perc_override,
     x_franchising_activity              => x_franchising_activity,
      x_completion_status                 => x_completion_status,
      x_good_stand_marker                 => x_good_stand_marker,
      x_complete_pyr_study_cd             => x_complete_pyr_study_cd,
      x_credit_value_yop1                 => x_credit_value_yop1,
      x_credit_value_yop2                 => x_credit_value_yop2,
      x_credit_value_yop3                 => x_credit_value_yop3,
      x_credit_value_yop4                 => x_credit_value_yop4,
      x_credit_level_achieved1            => x_credit_level_achieved1,
      x_credit_level_achieved2            => x_credit_level_achieved2,
      x_credit_level_achieved3            => x_credit_level_achieved3,
      x_credit_level_achieved4            => x_credit_level_achieved4,
      x_credit_pt_achieved1               => x_credit_pt_achieved1,
      x_credit_pt_achieved2               => x_credit_pt_achieved2,
      x_credit_pt_achieved3               => x_credit_pt_achieved3,
      x_credit_pt_achieved4               => x_credit_pt_achieved4,
      x_credit_level1                     => x_credit_level1,
      x_credit_level2                     => x_credit_level2,
      x_credit_level3                     => x_credit_level3,
      x_credit_level4                     => x_credit_level4,
      x_additional_sup_cost               => x_additional_sup_cost,
      x_enh_fund_elig_cd                  => x_enh_fund_elig_cd,
      x_disadv_uplift_factor              => x_disadv_uplift_factor,
      x_year_stu                          => x_year_stu,
      x_grad_sch_grade                    => x_grad_sch_grade,
      x_mark                              => x_mark,
      x_teaching_inst1                    => x_teaching_inst1,
      x_teaching_inst2                    => x_teaching_inst2,
      x_pro_not_taught                    => x_pro_not_taught,
      x_fundability_code                  => x_fundability_code,
      x_fee_eligibility                   => x_fee_eligibility,
      x_fee_band                          => x_fee_band,
      x_non_payment_reason                => x_non_payment_reason,
      x_student_fee                       => x_student_fee,
      x_fte_intensity			  => x_fte_intensity,
      x_calculated_fte			  =>x_calculated_fte,
      x_fte_calc_type			  => x_fte_calc_type,
     x_type_of_year  => x_type_of_year,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_he_en_susa
      SET
        person_id                         = new_references.person_id,
        course_cd                         = new_references.course_cd,
        unit_set_cd                       = new_references.unit_set_cd,
        us_version_number                 = new_references.us_version_number,
        sequence_number                   = new_references.sequence_number,
        new_he_entrant_cd                 = new_references.new_he_entrant_cd,
        term_time_accom                   = new_references.term_time_accom,
        disability_allow                  = new_references.disability_allow,
        additional_sup_band               = new_references.additional_sup_band,
        sldd_discrete_prov                = new_references.sldd_discrete_prov,
        study_mode                        = new_references.study_mode,
        study_location                    = new_references.study_location,
        fte_perc_override                  = new_references.fte_perc_override,
       franchising_activity              = new_references.franchising_activity,
        completion_status                 = new_references.completion_status,
        good_stand_marker                 = new_references.good_stand_marker,
        complete_pyr_study_cd             = new_references.complete_pyr_study_cd,
        credit_value_yop1                 = new_references.credit_value_yop1,
        credit_value_yop2                 = new_references.credit_value_yop2,
        credit_value_yop3                 = new_references.credit_value_yop3,
        credit_value_yop4                 = new_references.credit_value_yop4,
        credit_level_achieved1            = new_references.credit_level_achieved1,
        credit_level_achieved2            = new_references.credit_level_achieved2,
        credit_level_achieved3            = new_references.credit_level_achieved3,
        credit_level_achieved4            = new_references.credit_level_achieved4,
        credit_pt_achieved1               = new_references.credit_pt_achieved1,
        credit_pt_achieved2               = new_references.credit_pt_achieved2,
        credit_pt_achieved3               = new_references.credit_pt_achieved3,
        credit_pt_achieved4               = new_references.credit_pt_achieved4,
        credit_level1                     = new_references.credit_level1,
        credit_level2                     = new_references.credit_level2,
        credit_level3                     = new_references.credit_level3,
	credit_level4                     = new_references.credit_level4,
	additional_sup_cost               = new_references.additional_sup_cost,
	enh_fund_elig_cd                  = new_references.enh_fund_elig_cd,
	disadv_uplift_factor              = new_references.disadv_uplift_factor,
	year_stu                          = new_references.year_stu,
        grad_sch_grade                    = new_references.grad_sch_grade,
        mark                              = new_references.mark,
        teaching_inst1                    = new_references.teaching_inst1,
        teaching_inst2                    = new_references.teaching_inst2,
        pro_not_taught                    = new_references.pro_not_taught,
        fundability_code                  = new_references.fundability_code,
        fee_eligibility                   = new_references.fee_eligibility,
        fee_band                          = new_references.fee_band,
        non_payment_reason                = new_references.non_payment_reason,
        student_fee                       = new_references.student_fee,
        fte_intensity			  = new_references.fte_intensity,
        calculated_fte			  = new_references.calculated_fte,
        fte_calc_type			  = new_references.fte_calc_type,
        type_of_year			  = new_references.type_of_year,
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
    x_hesa_en_susa_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_sequence_number                   IN     NUMBER,
    x_new_he_entrant_cd                 IN     VARCHAR2,
    x_term_time_accom                   IN     VARCHAR2,
    x_disability_allow                  IN     VARCHAR2,
    x_additional_sup_band               IN     VARCHAR2,
    x_sldd_discrete_prov                IN     VARCHAR2,
    x_study_mode                        IN     VARCHAR2,
    x_study_location                    IN     VARCHAR2,
    x_fte_perc_override			IN	NUMBER,
    x_franchising_activity              IN     VARCHAR2,
    x_completion_status                 IN     VARCHAR2,
    x_good_stand_marker                 IN     VARCHAR2,
    x_complete_pyr_study_cd             IN     VARCHAR2,
    x_credit_value_yop1                 IN     NUMBER,
    x_credit_value_yop2                 IN     NUMBER,
    x_credit_value_yop3                 IN     NUMBER,
    x_credit_value_yop4                 IN     NUMBER,
    x_credit_level_achieved1            IN     VARCHAR2,
    x_credit_level_achieved2            IN     VARCHAR2,
    x_credit_level_achieved3            IN     VARCHAR2,
    x_credit_level_achieved4            IN     VARCHAR2,
    x_credit_pt_achieved1               IN     NUMBER,
    x_credit_pt_achieved2               IN     NUMBER,
    x_credit_pt_achieved3               IN     NUMBER,
    x_credit_pt_achieved4               IN     NUMBER,
    x_credit_level1                     IN     VARCHAR2,
    x_credit_level2                     IN     VARCHAR2,
    x_credit_level3                     IN     VARCHAR2,
    x_credit_level4                     IN     VARCHAR2,
    x_additional_sup_cost               IN     NUMBER,
    x_enh_fund_elig_cd                  IN     VARCHAR2,
    x_disadv_uplift_factor              IN     NUMBER,
    x_year_stu                          IN     NUMBER,
    x_grad_sch_grade                    IN     VARCHAR2,
    x_mark                              IN     NUMBER,
    x_teaching_inst1                    IN     VARCHAR2,
    x_teaching_inst2                    IN     VARCHAR2,
    x_pro_not_taught                    IN     NUMBER,
    x_fundability_code                  IN     VARCHAR2,
    x_fee_eligibility                   IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_non_payment_reason                IN     VARCHAR2,
    x_student_fee                       IN     VARCHAR2,
     x_fte_intensity			IN 	NUMBER	   ,
    x_calculated_fte			IN	NUMBER	   ,
    x_fte_calc_type			IN	VARCHAR2    ,
     x_type_of_year   IN     VARCHAR2	  ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga	  8-Apr-2002	    Added 3 parameters fte_intensity,calculated_fte and
  ||					fte_calc_type as part of #2278825
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_en_susa
      WHERE    hesa_en_susa_id                   = x_hesa_en_susa_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_hesa_en_susa_id,
        x_person_id,
        x_course_cd,
        x_unit_set_cd,
        x_us_version_number,
        x_sequence_number,
        x_new_he_entrant_cd,
        x_term_time_accom,
        x_disability_allow,
        x_additional_sup_band,
        x_sldd_discrete_prov,
        x_study_mode,
        x_study_location,
        x_fte_perc_override,
        x_franchising_activity,
        x_completion_status,
        x_good_stand_marker,
        x_complete_pyr_study_cd,
        x_credit_value_yop1,
        x_credit_value_yop2,
        x_credit_value_yop3,
        x_credit_value_yop4,
        x_credit_level_achieved1,
        x_credit_level_achieved2,
        x_credit_level_achieved3,
        x_credit_level_achieved4,
        x_credit_pt_achieved1,
        x_credit_pt_achieved2,
        x_credit_pt_achieved3,
        x_credit_pt_achieved4,
        x_credit_level1,
        x_credit_level2,
        x_credit_level3,
        x_credit_level4,
        x_additional_sup_cost,
	x_enh_fund_elig_cd,
	x_disadv_uplift_factor,
	x_year_stu,
        x_grad_sch_grade,
        x_mark,
        x_teaching_inst1,
        x_teaching_inst2,
        x_pro_not_taught,
        x_fundability_code,
        x_fee_eligibility,
        x_fee_band,
        x_non_payment_reason,
        x_student_fee,
        x_fte_intensity,
        x_calculated_fte,
        x_fte_calc_type,
        x_type_of_year ,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_hesa_en_susa_id,
      x_person_id,
      x_course_cd,
      x_unit_set_cd,
      x_us_version_number,
      x_sequence_number,
      x_new_he_entrant_cd,
      x_term_time_accom,
      x_disability_allow,
      x_additional_sup_band,
      x_sldd_discrete_prov,
      x_study_mode,
      x_study_location,
      x_fte_perc_override,
      x_franchising_activity,
      x_completion_status,
      x_good_stand_marker,
      x_complete_pyr_study_cd,
      x_credit_value_yop1,
      x_credit_value_yop2,
      x_credit_value_yop3,
      x_credit_value_yop4,
      x_credit_level_achieved1,
      x_credit_level_achieved2,
      x_credit_level_achieved3,
      x_credit_level_achieved4,
      x_credit_pt_achieved1,
      x_credit_pt_achieved2,
      x_credit_pt_achieved3,
      x_credit_pt_achieved4,
      x_credit_level1,
      x_credit_level2,
      x_credit_level3,
      x_credit_level4,
      x_grad_sch_grade,
      x_additional_sup_cost,
      x_enh_fund_elig_cd,
      x_disadv_uplift_factor,
      x_year_stu,
      x_mark,
      x_teaching_inst1,
      x_teaching_inst2,
      x_pro_not_taught,
      x_fundability_code,
      x_fee_eligibility,
      x_fee_band,
      x_non_payment_reason,
      x_student_fee,
      x_fte_intensity,
      x_calculated_fte,
      x_fte_calc_type,
      x_type_of_year ,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 20-FEB-2002
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
 DELETE FROM igs_he_en_susa
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


END igs_he_en_susa_pkg;

/
