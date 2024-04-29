--------------------------------------------------------
--  DDL for Package Body IGS_HE_ST_SPA_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_ST_SPA_ALL_PKG" AS
/* $Header: IGSWI22B.pls 120.4 2006/02/06 19:53:27 jbaber ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_st_spa_all%ROWTYPE;
  new_references igs_he_st_spa_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_st_spa_id                    IN     NUMBER      ,
    x_org_id                            IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_version_number                    IN     NUMBER      ,
    x_fe_student_marker                 IN     VARCHAR2    ,
    x_domicile_cd                       IN     VARCHAR2    ,
    x_inst_last_attended                IN     VARCHAR2    ,
    x_year_left_last_inst               IN     VARCHAR2    ,
    x_highest_qual_on_entry             IN     VARCHAR2    ,
    x_date_qual_on_entry_calc           IN     DATE        ,
    x_a_level_point_score               IN     NUMBER      ,
    x_highers_points_scores             IN     NUMBER      ,
    x_occupation_code                   IN     VARCHAR2    ,
    x_commencement_dt                   IN     DATE        ,
    x_special_student                   IN     VARCHAR2    ,
    x_student_qual_aim                  IN     VARCHAR2    ,
    x_student_fe_qual_aim               IN     VARCHAR2    ,
    x_teacher_train_prog_id             IN     VARCHAR2    ,
    x_itt_phase                         IN     VARCHAR2    ,
    x_bilingual_itt_marker              IN     VARCHAR2    ,
    x_teaching_qual_gain_sector         IN     VARCHAR2    ,
    x_teaching_qual_gain_subj1          IN     VARCHAR2    ,
    x_teaching_qual_gain_subj2          IN     VARCHAR2    ,
    x_teaching_qual_gain_subj3          IN     VARCHAR2    ,
    x_student_inst_number               IN     VARCHAR2    ,
    x_destination                       IN     VARCHAR2    ,
    x_itt_prog_outcome                  IN     VARCHAR2    ,
    x_hesa_return_name                  IN     VARCHAR2    ,
    x_hesa_return_id                    IN     NUMBER      ,
    x_hesa_submission_name              IN     VARCHAR2    ,
    x_associate_ucas_number             IN     VARCHAR2    ,
    x_associate_scott_cand              IN     VARCHAR2    ,
    x_associate_teach_ref_num           IN     VARCHAR2    ,
    x_associate_nhs_reg_num             IN     VARCHAR2    ,
    x_nhs_funding_source                IN     VARCHAR2    ,
    x_ufi_place                         IN     VARCHAR2    ,
    x_postcode                          IN     VARCHAR2    ,
    x_social_class_ind                  IN     VARCHAR2    ,
    x_occcode                           IN     VARCHAR2    ,
    x_total_ucas_tariff                 IN     NUMBER      ,
    x_nhs_employer                      IN     VARCHAR2    ,
    x_return_type                       IN     VARCHAR2    ,
    x_qual_aim_subj1                    IN     VARCHAR2    ,
    x_qual_aim_subj2                    IN     VARCHAR2    ,
    x_qual_aim_subj3                    IN     VARCHAR2    ,
    x_qual_aim_proportion               IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER,
    x_dependants_cd                     IN     VARCHAR2,
    x_implied_fund_rate                 IN     NUMBER,
    x_gov_initiatives_cd                IN     VARCHAR2,
    x_units_for_qual                    IN     NUMBER,
    x_disadv_uplift_elig_cd             IN     VARCHAR2,
    x_franch_partner_cd                 IN     VARCHAR2,
    x_units_completed                   IN     NUMBER,
    x_franch_out_arr_cd                 IN     VARCHAR2,
    x_employer_role_cd                  IN     VARCHAR2,
    x_disadv_uplift_factor              IN     NUMBER,
    x_enh_fund_elig_cd                  IN     VARCHAR2,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_ST_SPA_ALL
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
    new_references.hesa_st_spa_id                    := x_hesa_st_spa_id;
    new_references.org_id                            := x_org_id;
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.version_number                    := x_version_number;
    new_references.fe_student_marker                 := x_fe_student_marker;
    new_references.domicile_cd                       := x_domicile_cd;
    new_references.inst_last_attended                := x_inst_last_attended;
    new_references.year_left_last_inst               := x_year_left_last_inst;
    new_references.highest_qual_on_entry             := x_highest_qual_on_entry;
    new_references.date_qual_on_entry_calc           := x_date_qual_on_entry_calc;
    new_references.a_level_point_score               := x_a_level_point_score;
    new_references.highers_points_scores             := x_highers_points_scores;
    new_references.occupation_code                   := x_occupation_code;
    new_references.commencement_dt                   := x_commencement_dt;
    new_references.special_student                   := x_special_student;
    new_references.student_qual_aim                  := x_student_qual_aim;
    new_references.student_fe_qual_aim               := x_student_fe_qual_aim;
    new_references.teacher_train_prog_id             := x_teacher_train_prog_id;
    new_references.itt_phase                         := x_itt_phase;
    new_references.bilingual_itt_marker              := x_bilingual_itt_marker;
    new_references.teaching_qual_gain_sector         := x_teaching_qual_gain_sector;
    new_references.teaching_qual_gain_subj1          := x_teaching_qual_gain_subj1;
    new_references.teaching_qual_gain_subj2          := x_teaching_qual_gain_subj2;
    new_references.teaching_qual_gain_subj3          := x_teaching_qual_gain_subj3;
    new_references.student_inst_number               := x_student_inst_number;
    new_references.destination                       := x_destination;
    new_references.itt_prog_outcome                  := x_itt_prog_outcome;
    new_references.hesa_return_name                  := x_hesa_return_name;
    new_references.hesa_return_id                    := x_hesa_return_id;
    new_references.hesa_submission_name              := x_hesa_submission_name;
    new_references.associate_ucas_number             := x_associate_ucas_number;
    new_references.associate_scott_cand              := x_associate_scott_cand;
    new_references.associate_teach_ref_num           := x_associate_teach_ref_num;
    new_references.associate_nhs_reg_num             := x_associate_nhs_reg_num;
    new_references.nhs_funding_source                := x_nhs_funding_source;
    new_references.ufi_place                         := x_ufi_place;
    new_references.postcode                          := x_postcode;
    new_references.social_class_ind                  := x_social_class_ind;
    new_references.occcode                           := x_occcode;
    new_references.total_ucas_tariff                 := x_total_ucas_tariff;
    new_references.nhs_employer                      := x_nhs_employer;
    new_references.return_type                       := x_return_type;
    new_references.qual_aim_subj1                    := x_qual_aim_subj1  ;
    new_references.qual_aim_subj2                    := x_qual_aim_subj2;
    new_references.qual_aim_subj3                    := x_qual_aim_subj3;
    new_references.qual_aim_proportion               := x_qual_aim_proportion ;
    new_references.dependants_cd                     := x_dependants_cd;
    new_references.implied_fund_rate                 := x_implied_fund_rate;
    new_references.gov_initiatives_cd                := x_gov_initiatives_cd;
    new_references.units_for_qual                    := x_units_for_qual;
    new_references.disadv_uplift_elig_cd             := x_disadv_uplift_elig_cd;
    new_references.franch_partner_cd                 := x_franch_partner_cd;
    new_references.units_completed                   := x_units_completed;
    new_references.franch_out_arr_cd                 := x_franch_out_arr_cd;
    new_references.employer_role_cd                  := x_employer_role_cd;
    new_references.disadv_uplift_factor              := x_disadv_uplift_factor;
    new_references.enh_fund_elig_cd                  := x_enh_fund_elig_cd;

    IF (p_action = 'UPDATE' AND x_exclude_flag IS NULL) THEN
        new_references.exclude_flag                  := old_references.exclude_flag;
    ELSE
        new_references.exclude_flag                  := x_exclude_flag;
    END IF;

    IF (p_action = 'INSERT') THEN
           new_references.associate_ucas_number             := NVL(x_associate_ucas_number,'Y');
           new_references.associate_scott_cand              := NVL(x_associate_scott_cand,'Y');
           new_references.associate_teach_ref_num           := NVL(x_associate_teach_ref_num,'Y');
           new_references.associate_nhs_reg_num             := NVL(x_associate_nhs_reg_num,'Y');
    END IF;

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

 PROCEDURE check_constraints(
        column_name IN VARCHAR2,
        column_value IN VARCHAR2
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By : knaraset
  ||  Created On : 14-Nov-2002
  ||  Purpose : Validating the values of the given column
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ----------------------------------------------------------------------------*/
  BEGIN
        IF column_name IS NULL THEN
              NULL;
        ELSIF UPPER(column_name) = 'ASSOCIATE_UCAS_NUMBER' THEN
              new_references.associate_ucas_number := column_value;
        ELSIF UPPER(column_name) = 'ASSOCIATE_SCOTT_CAND' THEN
              new_references.associate_scott_cand := column_value;
        ELSIF UPPER(column_name) = 'ASSOCIATE_TEACH_REF_NUM' THEN
              new_references.associate_teach_ref_num := column_value;
        ELSIF UPPER(column_name) = 'ASSOCIATE_NHS_REG_NUM' THEN
              new_references.associate_nhs_reg_num := column_value;
        END IF;

        IF UPPER(column_name) = 'ASSOCIATE_UCAS_NUMBER' OR
               column_name IS NULL THEN
               IF new_references.associate_ucas_number   NOT  IN ( 'Y' , 'N')   THEN
                      FND_MESSAGE.SET_NAME ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      APP_EXCEPTION.RAISE_EXCEPTION;
               END IF;
        END IF;
        IF UPPER(column_name) = 'ASSOCIATE_SCOTT_CAND' OR
               column_name IS NULL THEN
               IF new_references.associate_scott_cand   NOT  IN ( 'Y' , 'N')   THEN
                      FND_MESSAGE.SET_NAME ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      APP_EXCEPTION.RAISE_EXCEPTION;
               END IF;
        END IF;
        IF UPPER(column_name) = 'ASSOCIATE_TEACH_REF_NUM' OR
               column_name IS NULL THEN
               IF new_references.associate_teach_ref_num   NOT  IN ( 'Y' , 'N')   THEN
                      FND_MESSAGE.SET_NAME ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      APP_EXCEPTION.RAISE_EXCEPTION;
               END IF;
        END IF;
        IF UPPER(column_name) = 'ASSOCIATE_NHS_REG_NUM' OR
               column_name IS NULL THEN
               IF new_references.associate_nhs_reg_num   NOT  IN ( 'Y' , 'N')   THEN
                      FND_MESSAGE.SET_NAME ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      APP_EXCEPTION.RAISE_EXCEPTION;
               END IF;
        END IF;
  END check_constraints;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.person_id,
           new_references.course_cd
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

  END check_parent_existance;


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

    igs_he_st_spa_ut_all_pkg.get_ufk_igs_he_st_spa_all (
      old_references.person_id,
      old_references.course_cd
    );

  END check_child_existance;


  PROCEDURE check_uk_child_existance IS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Checks for the existance of Child records based on Unique Keys of this table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((old_references.person_id IS NULL) OR
         (old_references.course_cd IS NULL))) THEN
      NULL;
    ELSE igs_he_st_spa_ut_all_pkg.get_ufk_igs_he_st_spa_all (
           old_references.person_id,
           old_references.course_cd
         );
    END IF;

  END check_uk_child_existance;


  FUNCTION get_pk_for_validation (
    x_hesa_st_spa_id                    IN     NUMBER
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
      FROM     igs_he_st_spa_all
      WHERE    hesa_st_spa_id = x_hesa_st_spa_id
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
    x_course_cd                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_st_spa_all
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      FOR UPDATE NOWAIT;

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


  PROCEDURE get_fk_igs_en_stdnt_ps_att_all (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_st_spa_all
      WHERE   ((course_cd = x_course_cd) AND
               (person_id = x_person_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HSPA_SCA_FK');
            igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_stdnt_ps_att_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_st_spa_id                    IN     NUMBER      ,
    x_org_id                            IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_version_number                    IN     NUMBER      ,
    x_fe_student_marker                 IN     VARCHAR2    ,
    x_domicile_cd                       IN     VARCHAR2    ,
    x_inst_last_attended                IN     VARCHAR2    ,
    x_year_left_last_inst               IN     VARCHAR2    ,
    x_highest_qual_on_entry             IN     VARCHAR2    ,
    x_date_qual_on_entry_calc           IN     DATE        ,
    x_a_level_point_score               IN     NUMBER      ,
    x_highers_points_scores             IN     NUMBER      ,
    x_occupation_code                   IN     VARCHAR2    ,
    x_commencement_dt                   IN     DATE        ,
    x_special_student                   IN     VARCHAR2    ,
    x_student_qual_aim                  IN     VARCHAR2    ,
    x_student_fe_qual_aim               IN     VARCHAR2    ,
    x_teacher_train_prog_id             IN     VARCHAR2    ,
    x_itt_phase                         IN     VARCHAR2    ,
    x_bilingual_itt_marker              IN     VARCHAR2    ,
    x_teaching_qual_gain_sector         IN     VARCHAR2    ,
    x_teaching_qual_gain_subj1          IN     VARCHAR2    ,
    x_teaching_qual_gain_subj2          IN     VARCHAR2    ,
    x_teaching_qual_gain_subj3          IN     VARCHAR2    ,
    x_student_inst_number               IN     VARCHAR2    ,
    x_destination                       IN     VARCHAR2    ,
    x_itt_prog_outcome                  IN     VARCHAR2    ,
    x_hesa_return_name                  IN     VARCHAR2    ,
    x_hesa_return_id                    IN     NUMBER      ,
    x_hesa_submission_name              IN     VARCHAR2    ,
    x_associate_ucas_number             IN     VARCHAR2    ,
    x_associate_scott_cand              IN     VARCHAR2    ,
    x_associate_teach_ref_num           IN     VARCHAR2    ,
    x_associate_nhs_reg_num             IN     VARCHAR2    ,
    x_nhs_funding_source                IN     VARCHAR2    ,
    x_ufi_place                         IN     VARCHAR2    ,
    x_postcode                          IN     VARCHAR2    ,
    x_social_class_ind                  IN     VARCHAR2    ,
    x_occcode                           IN     VARCHAR2    ,
    x_total_ucas_tariff                 IN     NUMBER      ,
    x_nhs_employer                      IN     VARCHAR2    ,
    x_return_type                       IN     VARCHAR2    ,
    x_qual_aim_subj1                    IN     VARCHAR2    ,
    x_qual_aim_subj2                    IN     VARCHAR2    ,
    x_qual_aim_subj3                    IN     VARCHAR2    ,
    x_qual_aim_proportion               IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER       ,
    x_dependants_cd                     IN     VARCHAR2,
    x_implied_fund_rate                 IN     NUMBER  ,
    x_gov_initiatives_cd                IN     VARCHAR2,
    x_units_for_qual                    IN     NUMBER  ,
    x_disadv_uplift_elig_cd             IN     VARCHAR2,
    x_franch_partner_cd                 IN     VARCHAR2,
    x_units_completed                   IN     NUMBER  ,
    x_franch_out_arr_cd                 IN     VARCHAR2,
    x_employer_role_cd                  IN     VARCHAR2,
    x_disadv_uplift_factor              IN     NUMBER  ,
    x_enh_fund_elig_cd                  IN     VARCHAR2,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
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
      x_hesa_st_spa_id,
      x_org_id,
      x_person_id,
      x_course_cd,
      x_version_number,
      x_fe_student_marker,
      x_domicile_cd,
      x_inst_last_attended,
      x_year_left_last_inst,
      x_highest_qual_on_entry,
      x_date_qual_on_entry_calc,
      x_a_level_point_score,
      x_highers_points_scores,
      x_occupation_code,
      x_commencement_dt,
      x_special_student,
      x_student_qual_aim,
      x_student_fe_qual_aim,
      x_teacher_train_prog_id,
      x_itt_phase,
      x_bilingual_itt_marker,
      x_teaching_qual_gain_sector,
      x_teaching_qual_gain_subj1,
      x_teaching_qual_gain_subj2,
      x_teaching_qual_gain_subj3,
      x_student_inst_number,
      x_destination,
      x_itt_prog_outcome,
      x_hesa_return_name,
      x_hesa_return_id,
      x_hesa_submission_name,
      x_associate_ucas_number,
      x_associate_scott_cand,
      x_associate_teach_ref_num,
      x_associate_nhs_reg_num,
      x_nhs_funding_source,
      x_ufi_place,
      x_postcode,
      x_social_class_ind,
      x_occcode,
      x_total_ucas_tariff,
      x_nhs_employer,
      x_return_type,
      x_qual_aim_subj1 ,
      x_qual_aim_subj2,
      x_qual_aim_subj3,
      x_qual_aim_proportion,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_dependants_cd,
      x_implied_fund_rate,
      x_gov_initiatives_cd,
      x_units_for_qual,
      x_disadv_uplift_elig_cd,
      x_franch_partner_cd,
      x_units_completed,
      x_franch_out_arr_cd,
      x_employer_role_cd,
      x_disadv_uplift_factor,
      x_enh_fund_elig_cd,
      x_exclude_flag
   );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.hesa_st_spa_id
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
      check_uk_child_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.hesa_st_spa_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_uk_child_existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_st_spa_id                    IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_fe_student_marker                 IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_inst_last_attended                IN     VARCHAR2,
    x_year_left_last_inst               IN     VARCHAR2,
    x_highest_qual_on_entry             IN     VARCHAR2,
    x_date_qual_on_entry_calc           IN     DATE,
    x_a_level_point_score               IN     NUMBER,
    x_highers_points_scores             IN     NUMBER,
    x_occupation_code                   IN     VARCHAR2,
    x_commencement_dt                   IN     DATE,
    x_special_student                   IN     VARCHAR2,
    x_student_qual_aim                  IN     VARCHAR2,
    x_student_fe_qual_aim               IN     VARCHAR2,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_gain_sector         IN     VARCHAR2,
    x_teaching_qual_gain_subj1          IN     VARCHAR2,
    x_teaching_qual_gain_subj2          IN     VARCHAR2,
    x_teaching_qual_gain_subj3          IN     VARCHAR2,
    x_student_inst_number               IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_itt_prog_outcome                  IN     VARCHAR2,
    x_hesa_return_name                  IN     VARCHAR2,
    x_hesa_return_id                    IN     NUMBER,
    x_hesa_submission_name              IN     VARCHAR2,
    x_associate_ucas_number             IN     VARCHAR2,
    x_associate_scott_cand              IN     VARCHAR2,
    x_associate_teach_ref_num           IN     VARCHAR2,
    x_associate_nhs_reg_num             IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_social_class_ind                  IN     VARCHAR2,
    x_occcode                           IN     VARCHAR2,
    x_total_ucas_tariff                 IN     NUMBER,
    x_nhs_employer                      IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_qual_aim_subj1                    IN     VARCHAR2,
    x_qual_aim_subj2                    IN     VARCHAR2,
    x_qual_aim_subj3                    IN     VARCHAR2,
    x_qual_aim_proportion               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_dependants_cd                     IN     VARCHAR2 ,
    x_implied_fund_rate                 IN     NUMBER   ,
    x_gov_initiatives_cd                IN     VARCHAR2 ,
    x_units_for_qual                    IN     NUMBER   ,
    x_disadv_uplift_elig_cd             IN     VARCHAR2 ,
    x_franch_partner_cd                 IN     VARCHAR2 ,
    x_units_completed                   IN     NUMBER   ,
    x_franch_out_arr_cd                 IN     VARCHAR2 ,
    x_employer_role_cd                  IN     VARCHAR2 ,
    x_disadv_uplift_factor              IN     NUMBER   ,
    x_enh_fund_elig_cd                  IN     VARCHAR2 ,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smvk            13-Feb-2002     Call to igs_ge_gen_003.get_org_id
  ||                                  w.r.t. SWCR006
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_st_spa_all
      WHERE    hesa_st_spa_id                    = x_hesa_st_spa_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

    l_mode VARCHAR2(1);

  BEGIN

    l_mode := NVL(x_mode,'R');

    x_last_update_date := SYSDATE;
    IF (l_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (l_mode IN ('R','S')) THEN
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

    SELECT    igs_he_st_spa_all_s.NEXTVAL
    INTO      x_hesa_st_spa_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_hesa_st_spa_id                    => x_hesa_st_spa_id,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_fe_student_marker                 => x_fe_student_marker,
      x_domicile_cd                       => x_domicile_cd,
      x_inst_last_attended                => x_inst_last_attended,
      x_year_left_last_inst               => x_year_left_last_inst,
      x_highest_qual_on_entry             => x_highest_qual_on_entry,
      x_date_qual_on_entry_calc           => x_date_qual_on_entry_calc,
      x_a_level_point_score               => x_a_level_point_score,
      x_highers_points_scores             => x_highers_points_scores,
      x_occupation_code                   => x_occupation_code,
      x_commencement_dt                   => x_commencement_dt,
      x_special_student                   => x_special_student,
      x_student_qual_aim                  => x_student_qual_aim,
      x_student_fe_qual_aim               => x_student_fe_qual_aim,
      x_teacher_train_prog_id             => x_teacher_train_prog_id,
      x_itt_phase                         => x_itt_phase,
      x_bilingual_itt_marker              => x_bilingual_itt_marker,
      x_teaching_qual_gain_sector         => x_teaching_qual_gain_sector,
      x_teaching_qual_gain_subj1          => x_teaching_qual_gain_subj1,
      x_teaching_qual_gain_subj2          => x_teaching_qual_gain_subj2,
      x_teaching_qual_gain_subj3          => x_teaching_qual_gain_subj3,
      x_student_inst_number               => x_student_inst_number,
      x_destination                       => x_destination,
      x_itt_prog_outcome                  => x_itt_prog_outcome,
      x_hesa_return_name                  => x_hesa_return_name,
      x_hesa_return_id                    => x_hesa_return_id,
      x_hesa_submission_name              => x_hesa_submission_name,
      x_associate_ucas_number             => x_associate_ucas_number,
      x_associate_scott_cand              => x_associate_scott_cand,
      x_associate_teach_ref_num           => x_associate_teach_ref_num,
      x_associate_nhs_reg_num             => x_associate_nhs_reg_num,
      x_nhs_funding_source                => x_nhs_funding_source,
      x_ufi_place                         => x_ufi_place,
      x_postcode                          => x_postcode,
      x_social_class_ind                  => x_social_class_ind,
      x_occcode                           => x_occcode,
      x_total_ucas_tariff                 => x_total_ucas_tariff,
      x_nhs_employer                      => x_nhs_employer,
      x_return_type                       => x_return_type,
      x_qual_aim_subj1                    => x_qual_aim_subj1,
      x_qual_aim_subj2                    => x_qual_aim_subj2,
      x_qual_aim_subj3                    => x_qual_aim_subj3,
      x_qual_aim_proportion               => x_qual_aim_proportion ,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_dependants_cd                     => x_dependants_cd,
      x_implied_fund_rate                 => x_implied_fund_rate,
      x_gov_initiatives_cd                => x_gov_initiatives_cd,
      x_units_for_qual                    => x_units_for_qual,
      x_disadv_uplift_elig_cd             => x_disadv_uplift_elig_cd,
      x_franch_partner_cd                 => x_franch_partner_cd,
      x_units_completed                   => x_units_completed,
      x_franch_out_arr_cd                 => x_franch_out_arr_cd,
      x_employer_role_cd                  => x_employer_role_cd,
      x_disadv_uplift_factor              => x_disadv_uplift_factor,
      x_enh_fund_elig_cd                  => x_enh_fund_elig_cd,
      x_exclude_flag                      => x_exclude_flag
   );

    IF (x_mode = 'S') THEN
      igs_sc_gen_001.set_ctx('R');
    END IF;
    INSERT INTO igs_he_st_spa_all (
      hesa_st_spa_id,
      org_id,
      person_id,
      course_cd,
      version_number,
      fe_student_marker,
      domicile_cd,
      inst_last_attended,
      year_left_last_inst,
      highest_qual_on_entry,
      date_qual_on_entry_calc,
      a_level_point_score,
      highers_points_scores,
      occupation_code,
      commencement_dt,
      special_student,
      student_qual_aim,
      student_fe_qual_aim,
      teacher_train_prog_id,
      itt_phase,
      bilingual_itt_marker,
      teaching_qual_gain_sector,
      teaching_qual_gain_subj1,
      teaching_qual_gain_subj2,
      teaching_qual_gain_subj3,
      student_inst_number,
      destination,
      itt_prog_outcome,
      hesa_return_name,
      hesa_return_id,
      hesa_submission_name,
      associate_ucas_number,
      associate_scott_cand,
      associate_teach_ref_num,
      associate_nhs_reg_num,
      nhs_funding_source,
      ufi_place,
      postcode,
      social_class_ind,
      occcode,
      total_ucas_tariff,
      nhs_employer,
      return_type,
      qual_aim_subj1,
      qual_aim_subj2,
      qual_aim_subj3,
      qual_aim_proportion,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      dependants_cd,
      implied_fund_rate,
      gov_initiatives_cd,
      units_for_qual,
      disadv_uplift_elig_cd,
      franch_partner_cd,
      units_completed,
      franch_out_arr_cd,
      employer_role_cd,
      disadv_uplift_factor,
      enh_fund_elig_cd,
      exclude_flag
   ) VALUES (
      new_references.hesa_st_spa_id,
      new_references.org_id,
      new_references.person_id,
      new_references.course_cd,
      new_references.version_number,
      new_references.fe_student_marker,
      new_references.domicile_cd,
      new_references.inst_last_attended,
      new_references.year_left_last_inst,
      new_references.highest_qual_on_entry,
      new_references.date_qual_on_entry_calc,
      new_references.a_level_point_score,
      new_references.highers_points_scores,
      new_references.occupation_code,
      new_references.commencement_dt,
      new_references.special_student,
      new_references.student_qual_aim,
      new_references.student_fe_qual_aim,
      new_references.teacher_train_prog_id,
      new_references.itt_phase,
      new_references.bilingual_itt_marker,
      new_references.teaching_qual_gain_sector,
      new_references.teaching_qual_gain_subj1,
      new_references.teaching_qual_gain_subj2,
      new_references.teaching_qual_gain_subj3,
      new_references.student_inst_number,
      new_references.destination,
      new_references.itt_prog_outcome,
      new_references.hesa_return_name,
      new_references.hesa_return_id,
      new_references.hesa_submission_name,
      new_references.associate_ucas_number,
      new_references.associate_scott_cand,
      new_references.associate_teach_ref_num,
      new_references.associate_nhs_reg_num,
      new_references.nhs_funding_source,
      new_references.ufi_place,
      new_references.postcode,
      new_references.social_class_ind,
      new_references.occcode,
      new_references.total_ucas_tariff,
      new_references.nhs_employer,
      new_references.return_type,
      new_references.qual_aim_subj1,
      new_references.qual_aim_subj2,
      new_references.qual_aim_subj3,
      new_references.qual_aim_proportion,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.dependants_cd,
      new_references.implied_fund_rate,
      new_references.gov_initiatives_cd,
      new_references.units_for_qual,
      new_references.disadv_uplift_elig_cd,
      new_references.franch_partner_cd,
      new_references.units_completed,
      new_references.franch_out_arr_cd,
      new_references.employer_role_cd,
      new_references.disadv_uplift_factor,
      new_references.enh_fund_elig_cd,
      new_references.exclude_flag
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
    x_hesa_st_spa_id                    IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_fe_student_marker                 IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_inst_last_attended                IN     VARCHAR2,
    x_year_left_last_inst               IN     VARCHAR2,
    x_highest_qual_on_entry             IN     VARCHAR2,
    x_date_qual_on_entry_calc           IN     DATE,
    x_a_level_point_score               IN     NUMBER,
    x_highers_points_scores             IN     NUMBER,
    x_occupation_code                   IN     VARCHAR2,
    x_commencement_dt                   IN     DATE,
    x_special_student                   IN     VARCHAR2,
    x_student_qual_aim                  IN     VARCHAR2,
    x_student_fe_qual_aim               IN     VARCHAR2,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_gain_sector         IN     VARCHAR2,
    x_teaching_qual_gain_subj1          IN     VARCHAR2,
    x_teaching_qual_gain_subj2          IN     VARCHAR2,
    x_teaching_qual_gain_subj3          IN     VARCHAR2,
    x_student_inst_number               IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_itt_prog_outcome                  IN     VARCHAR2,
    x_hesa_return_name                  IN     VARCHAR2,
    x_hesa_return_id                    IN     NUMBER,
    x_hesa_submission_name              IN     VARCHAR2,
    x_associate_ucas_number             IN     VARCHAR2,
    x_associate_scott_cand              IN     VARCHAR2,
    x_associate_teach_ref_num           IN     VARCHAR2,
    x_associate_nhs_reg_num             IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_social_class_ind                  IN     VARCHAR2,
    x_occcode                           IN     VARCHAR2,
    x_total_ucas_tariff                 IN     NUMBER,
    x_nhs_employer                      IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_qual_aim_subj1                    IN     VARCHAR2,
    x_qual_aim_subj2                    IN     VARCHAR2,
    x_qual_aim_subj3                    IN     VARCHAR2,
    x_qual_aim_proportion               IN     VARCHAR2,
    x_dependants_cd                     IN     VARCHAR2 ,
    x_implied_fund_rate                 IN     NUMBER   ,
    x_gov_initiatives_cd                IN     VARCHAR2 ,
    x_units_for_qual                    IN     NUMBER   ,
    x_disadv_uplift_elig_cd             IN     VARCHAR2 ,
    x_franch_partner_cd                 IN     VARCHAR2 ,
    x_units_completed                   IN     NUMBER   ,
    x_franch_out_arr_cd                 IN     VARCHAR2 ,
    x_employer_role_cd                  IN     VARCHAR2 ,
    x_disadv_uplift_factor              IN     NUMBER   ,
    x_enh_fund_elig_cd                  IN     VARCHAR2 ,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smvk             13-feb-2002     Removed org_id from cursor declaration
  ||                                  and conditional checking  w.r.t. SWCR006
  ||
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        course_cd,
        version_number,
        fe_student_marker,
        domicile_cd,
        inst_last_attended,
        year_left_last_inst,
        highest_qual_on_entry,
        date_qual_on_entry_calc,
        a_level_point_score,
        highers_points_scores,
        occupation_code,
        commencement_dt,
        special_student,
        student_qual_aim,
        student_fe_qual_aim,
        teacher_train_prog_id,
        itt_phase,
        bilingual_itt_marker,
        teaching_qual_gain_sector,
        teaching_qual_gain_subj1,
        teaching_qual_gain_subj2,
        teaching_qual_gain_subj3,
        student_inst_number,
        destination,
        itt_prog_outcome,
        hesa_return_name,
        hesa_return_id,
        hesa_submission_name,
        associate_ucas_number,
        associate_scott_cand,
        associate_teach_ref_num,
        associate_nhs_reg_num,
        nhs_funding_source,
        ufi_place,
        postcode,
        social_class_ind,
        occcode,
        total_ucas_tariff,
        nhs_employer,
        return_type,
        qual_aim_subj1,
        qual_aim_subj2 ,
        qual_aim_subj3 ,
        qual_aim_proportion,
        dependants_cd,
        implied_fund_rate,
        gov_initiatives_cd,
        units_for_qual,
        disadv_uplift_elig_cd,
        franch_partner_cd,
        units_completed,
        franch_out_arr_cd,
        employer_role_cd,
        disadv_uplift_factor,
        enh_fund_elig_cd,
        exclude_flag
      FROM  igs_he_st_spa_all
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
        AND (tlinfo.version_number = x_version_number)
        AND ((tlinfo.fe_student_marker = x_fe_student_marker) OR ((tlinfo.fe_student_marker IS NULL) AND (X_fe_student_marker IS NULL)))
        AND ((tlinfo.domicile_cd = x_domicile_cd) OR ((tlinfo.domicile_cd IS NULL) AND (X_domicile_cd IS NULL)))
        AND ((tlinfo.inst_last_attended = x_inst_last_attended) OR ((tlinfo.inst_last_attended IS NULL) AND (X_inst_last_attended IS NULL)))
        AND ((tlinfo.year_left_last_inst = x_year_left_last_inst) OR ((tlinfo.year_left_last_inst IS NULL) AND (X_year_left_last_inst IS NULL)))
        AND ((tlinfo.highest_qual_on_entry = x_highest_qual_on_entry) OR ((tlinfo.highest_qual_on_entry IS NULL) AND (X_highest_qual_on_entry IS NULL)))
        AND ((tlinfo.date_qual_on_entry_calc = x_date_qual_on_entry_calc) OR ((tlinfo.date_qual_on_entry_calc IS NULL) AND (X_date_qual_on_entry_calc IS NULL)))
        AND ((tlinfo.a_level_point_score = x_a_level_point_score) OR ((tlinfo.a_level_point_score IS NULL) AND (X_a_level_point_score IS NULL)))
        AND ((tlinfo.highers_points_scores = x_highers_points_scores) OR ((tlinfo.highers_points_scores IS NULL) AND (X_highers_points_scores IS NULL)))
        AND ((tlinfo.occupation_code = x_occupation_code) OR ((tlinfo.occupation_code IS NULL) AND (X_occupation_code IS NULL)))
        AND ((tlinfo.commencement_dt = x_commencement_dt) OR ((tlinfo.commencement_dt IS NULL) AND (X_commencement_dt IS NULL)))
        AND ((tlinfo.special_student = x_special_student) OR ((tlinfo.special_student IS NULL) AND (X_special_student IS NULL)))
        AND ((tlinfo.student_qual_aim = x_student_qual_aim) OR ((tlinfo.student_qual_aim IS NULL) AND (X_student_qual_aim IS NULL)))
        AND ((tlinfo.student_fe_qual_aim = x_student_fe_qual_aim) OR ((tlinfo.student_fe_qual_aim IS NULL) AND (X_student_fe_qual_aim IS NULL)))
        AND ((tlinfo.teacher_train_prog_id = x_teacher_train_prog_id) OR ((tlinfo.teacher_train_prog_id IS NULL) AND (X_teacher_train_prog_id IS NULL)))
        AND ((tlinfo.itt_phase = x_itt_phase) OR ((tlinfo.itt_phase IS NULL) AND (X_itt_phase IS NULL)))
        AND ((tlinfo.bilingual_itt_marker = x_bilingual_itt_marker) OR ((tlinfo.bilingual_itt_marker IS NULL) AND (X_bilingual_itt_marker IS NULL)))
        AND ((tlinfo.teaching_qual_gain_sector = x_teaching_qual_gain_sector) OR ((tlinfo.teaching_qual_gain_sector IS NULL) AND (X_teaching_qual_gain_sector IS NULL)))
        AND ((tlinfo.teaching_qual_gain_subj1 = x_teaching_qual_gain_subj1) OR ((tlinfo.teaching_qual_gain_subj1 IS NULL) AND (X_teaching_qual_gain_subj1 IS NULL)))
        AND ((tlinfo.teaching_qual_gain_subj2 = x_teaching_qual_gain_subj2) OR ((tlinfo.teaching_qual_gain_subj2 IS NULL) AND (X_teaching_qual_gain_subj2 IS NULL)))
        AND ((tlinfo.teaching_qual_gain_subj3 = x_teaching_qual_gain_subj3) OR ((tlinfo.teaching_qual_gain_subj3 IS NULL) AND (X_teaching_qual_gain_subj3 IS NULL)))
        AND ((tlinfo.student_inst_number = x_student_inst_number) OR ((tlinfo.student_inst_number IS NULL) AND (X_student_inst_number IS NULL)))
        AND ((tlinfo.destination = x_destination) OR ((tlinfo.destination IS NULL) AND (X_destination IS NULL)))
        AND ((tlinfo.itt_prog_outcome = x_itt_prog_outcome) OR ((tlinfo.itt_prog_outcome IS NULL) AND (X_itt_prog_outcome IS NULL)))
        AND ((tlinfo.hesa_return_name = x_hesa_return_name) OR ((tlinfo.hesa_return_name IS NULL) AND (X_hesa_return_name IS NULL)))
        AND ((tlinfo.hesa_return_id = x_hesa_return_id) OR ((tlinfo.hesa_return_id IS NULL) AND (X_hesa_return_id IS NULL)))
        AND ((tlinfo.hesa_submission_name = x_hesa_submission_name) OR ((tlinfo.hesa_submission_name IS NULL) AND (X_hesa_submission_name IS NULL)))
        AND ((tlinfo.associate_ucas_number = x_associate_ucas_number) OR ((tlinfo.associate_ucas_number IS NULL) AND (X_associate_ucas_number IS NULL)))
        AND ((tlinfo.associate_scott_cand = x_associate_scott_cand) OR ((tlinfo.associate_scott_cand IS NULL) AND (X_associate_scott_cand IS NULL)))
        AND ((tlinfo.associate_teach_ref_num = x_associate_teach_ref_num) OR ((tlinfo.associate_teach_ref_num IS NULL) AND (X_associate_teach_ref_num IS NULL)))
        AND ((tlinfo.associate_nhs_reg_num = x_associate_nhs_reg_num) OR ((tlinfo.associate_nhs_reg_num IS NULL) AND (X_associate_nhs_reg_num IS NULL)))
        AND ((tlinfo.nhs_funding_source = x_nhs_funding_source) OR ((tlinfo.nhs_funding_source IS NULL) AND (X_nhs_funding_source IS NULL)))
        AND ((tlinfo.ufi_place = x_ufi_place) OR ((tlinfo.ufi_place IS NULL) AND (X_ufi_place IS NULL)))
        AND ((tlinfo.postcode = x_postcode) OR ((tlinfo.postcode IS NULL) AND (X_postcode IS NULL)))
        AND ((tlinfo.social_class_ind = x_social_class_ind) OR ((tlinfo.social_class_ind IS NULL) AND (X_social_class_ind IS NULL)))
        AND ((tlinfo.occcode = x_occcode) OR ((tlinfo.occcode IS NULL) AND (X_occcode IS NULL)))
        AND ((tlinfo.total_ucas_tariff = x_total_ucas_tariff) OR ((tlinfo.total_ucas_tariff IS NULL) AND (X_total_ucas_tariff IS NULL)))
        AND ((tlinfo.nhs_employer = x_nhs_employer) OR ((tlinfo.nhs_employer IS NULL) AND (X_nhs_employer IS NULL)))
        AND ((tlinfo.return_type = x_return_type) OR ((tlinfo.return_type IS NULL) AND (X_return_type IS NULL)))
        AND ((tlinfo.qual_aim_subj1 = x_qual_aim_subj1) OR ((tlinfo.qual_aim_subj1 IS NULL) AND (X_qual_aim_subj1 IS NULL)))
        AND ((tlinfo.qual_aim_subj2 = x_qual_aim_subj2) OR ((tlinfo.qual_aim_subj2 IS NULL) AND (X_qual_aim_subj2 IS NULL)))
        AND ((tlinfo.qual_aim_subj3 = x_qual_aim_subj3) OR ((tlinfo.qual_aim_subj3 IS NULL) AND (X_qual_aim_subj3 IS NULL)))
        AND ((tlinfo.qual_aim_proportion = x_qual_aim_proportion) OR ((tlinfo.qual_aim_proportion IS NULL) AND (X_qual_aim_proportion IS NULL)))
        AND ((tlinfo.dependants_cd = x_dependants_cd) OR ((tlinfo.dependants_cd IS NULL) AND (x_dependants_cd IS NULL)))
        AND ((tlinfo.implied_fund_rate = x_implied_fund_rate) OR ((tlinfo.implied_fund_rate IS NULL) AND (x_implied_fund_rate IS NULL)))
        AND ((tlinfo.gov_initiatives_cd = x_gov_initiatives_cd) OR ((tlinfo.gov_initiatives_cd IS NULL) AND (x_gov_initiatives_cd IS NULL)))
        AND ((tlinfo.units_for_qual = x_units_for_qual) OR ((tlinfo.units_for_qual IS NULL) AND (x_units_for_qual IS NULL)))
        AND ((tlinfo.disadv_uplift_elig_cd = x_disadv_uplift_elig_cd) OR ((tlinfo.disadv_uplift_elig_cd IS NULL) AND (x_disadv_uplift_elig_cd IS NULL)))
        AND ((tlinfo.franch_partner_cd = x_franch_partner_cd) OR ((tlinfo.franch_partner_cd IS NULL) AND (x_franch_partner_cd IS NULL)))
        AND ((tlinfo.units_completed = x_units_completed) OR ((tlinfo.units_completed IS NULL) AND (x_units_completed IS NULL)))
        AND ((tlinfo.franch_out_arr_cd = x_franch_out_arr_cd) OR ((tlinfo.franch_out_arr_cd IS NULL) AND (x_franch_out_arr_cd IS NULL)))
        AND ((tlinfo.employer_role_cd = x_employer_role_cd) OR ((tlinfo.employer_role_cd IS NULL) AND (x_employer_role_cd IS NULL)))
        AND ((tlinfo.disadv_uplift_factor = x_disadv_uplift_factor) OR ((tlinfo.disadv_uplift_factor IS NULL) AND (x_disadv_uplift_factor IS NULL)))
        AND ((tlinfo.enh_fund_elig_cd = x_enh_fund_elig_cd) OR ((tlinfo.enh_fund_elig_cd IS NULL) AND (x_enh_fund_elig_cd IS NULL)))
        AND ((tlinfo.exclude_flag = x_exclude_flag) OR ((tlinfo.exclude_flag IS NULL) AND (x_exclude_flag IS NULL)))
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
    x_hesa_st_spa_id                    IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_fe_student_marker                 IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_inst_last_attended                IN     VARCHAR2,
    x_year_left_last_inst               IN     VARCHAR2,
    x_highest_qual_on_entry             IN     VARCHAR2,
    x_date_qual_on_entry_calc           IN     DATE,
    x_a_level_point_score               IN     NUMBER,
    x_highers_points_scores             IN     NUMBER,
    x_occupation_code                   IN     VARCHAR2,
    x_commencement_dt                   IN     DATE,
    x_special_student                   IN     VARCHAR2,
    x_student_qual_aim                  IN     VARCHAR2,
    x_student_fe_qual_aim               IN     VARCHAR2,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_gain_sector         IN     VARCHAR2,
    x_teaching_qual_gain_subj1          IN     VARCHAR2,
    x_teaching_qual_gain_subj2          IN     VARCHAR2,
    x_teaching_qual_gain_subj3          IN     VARCHAR2,
    x_student_inst_number               IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_itt_prog_outcome                  IN     VARCHAR2,
    x_hesa_return_name                  IN     VARCHAR2,
    x_hesa_return_id                    IN     NUMBER,
    x_hesa_submission_name              IN     VARCHAR2,
    x_associate_ucas_number             IN     VARCHAR2,
    x_associate_scott_cand              IN     VARCHAR2,
    x_associate_teach_ref_num           IN     VARCHAR2,
    x_associate_nhs_reg_num             IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_social_class_ind                  IN     VARCHAR2,
    x_occcode                           IN     VARCHAR2,
    x_total_ucas_tariff                 IN     NUMBER,
    x_nhs_employer                      IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_qual_aim_subj1                    IN     VARCHAR2,
    x_qual_aim_subj2                    IN     VARCHAR2,
    x_qual_aim_subj3                    IN     VARCHAR2,
    x_qual_aim_proportion               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_dependants_cd                     IN     VARCHAR2 ,
    x_implied_fund_rate                 IN     NUMBER   ,
    x_gov_initiatives_cd                IN     VARCHAR2 ,
    x_units_for_qual                    IN     NUMBER   ,
    x_disadv_uplift_elig_cd             IN     VARCHAR2 ,
    x_franch_partner_cd                 IN     VARCHAR2 ,
    x_units_completed                   IN     NUMBER   ,
    x_franch_out_arr_cd                 IN     VARCHAR2 ,
    x_employer_role_cd                  IN     VARCHAR2 ,
    x_disadv_uplift_factor              IN     NUMBER   ,
    x_enh_fund_elig_cd                  IN     VARCHAR2 ,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||smvk              13-feb-2002     Call to igs_ge_gen_003.get_org_id
  ||                                  w.r.t. SWCR006
  ||
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_mode VARCHAR2(1);

  BEGIN

    l_mode := NVL(x_mode,'R');

    x_last_update_date := SYSDATE;
    IF (l_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (l_mode IN ('R', 'S')) THEN
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
      x_hesa_st_spa_id                    => x_hesa_st_spa_id,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_fe_student_marker                 => x_fe_student_marker,
      x_domicile_cd                       => x_domicile_cd,
      x_inst_last_attended                => x_inst_last_attended,
      x_year_left_last_inst               => x_year_left_last_inst,
      x_highest_qual_on_entry             => x_highest_qual_on_entry,
      x_date_qual_on_entry_calc           => x_date_qual_on_entry_calc,
      x_a_level_point_score               => x_a_level_point_score,
      x_highers_points_scores             => x_highers_points_scores,
      x_occupation_code                   => x_occupation_code,
      x_commencement_dt                   => x_commencement_dt,
      x_special_student                   => x_special_student,
      x_student_qual_aim                  => x_student_qual_aim,
      x_student_fe_qual_aim               => x_student_fe_qual_aim,
      x_teacher_train_prog_id             => x_teacher_train_prog_id,
      x_itt_phase                         => x_itt_phase,
      x_bilingual_itt_marker              => x_bilingual_itt_marker,
      x_teaching_qual_gain_sector         => x_teaching_qual_gain_sector,
      x_teaching_qual_gain_subj1          => x_teaching_qual_gain_subj1,
      x_teaching_qual_gain_subj2          => x_teaching_qual_gain_subj2,
      x_teaching_qual_gain_subj3          => x_teaching_qual_gain_subj3,
      x_student_inst_number               => x_student_inst_number,
      x_destination                       => x_destination,
      x_itt_prog_outcome                  => x_itt_prog_outcome,
      x_hesa_return_name                  => x_hesa_return_name,
      x_hesa_return_id                    => x_hesa_return_id,
      x_hesa_submission_name              => x_hesa_submission_name,
      x_associate_ucas_number             => x_associate_ucas_number,
      x_associate_scott_cand              => x_associate_scott_cand,
      x_associate_teach_ref_num           => x_associate_teach_ref_num,
      x_associate_nhs_reg_num             => x_associate_nhs_reg_num,
      x_nhs_funding_source                => x_nhs_funding_source,
      x_ufi_place                         => x_ufi_place,
      x_postcode                          => x_postcode,
      x_social_class_ind                  => x_social_class_ind,
      x_occcode                           => x_occcode,
      x_total_ucas_tariff                 => x_total_ucas_tariff,
      x_nhs_employer                      => x_nhs_employer,
      x_return_type                       => x_return_type,
      x_qual_aim_subj1                    => x_qual_aim_subj1,
      x_qual_aim_subj2                    => x_qual_aim_subj2,
      x_qual_aim_subj3                    => x_qual_aim_subj3,
      x_qual_aim_proportion               => x_qual_aim_proportion ,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_dependants_cd                     => x_dependants_cd,
      x_implied_fund_rate                 => x_implied_fund_rate,
      x_gov_initiatives_cd                => x_gov_initiatives_cd,
      x_units_for_qual                    => x_units_for_qual,
      x_disadv_uplift_elig_cd             => x_disadv_uplift_elig_cd,
      x_franch_partner_cd                 => x_franch_partner_cd,
      x_units_completed                   => x_units_completed,
      x_franch_out_arr_cd                 => x_franch_out_arr_cd,
      x_employer_role_cd                  => x_employer_role_cd,
      x_disadv_uplift_factor              => x_disadv_uplift_factor,
      x_enh_fund_elig_cd                  => x_enh_fund_elig_cd,
      x_exclude_flag                      => x_exclude_flag
   );

    IF (x_mode = 'S') THEN
     igs_sc_gen_001.set_ctx('R');
    END IF;
    UPDATE igs_he_st_spa_all
      SET
        org_id                            = new_references.org_id,
        person_id                         = new_references.person_id,
        course_cd                         = new_references.course_cd,
        version_number                    = new_references.version_number,
        fe_student_marker                 = new_references.fe_student_marker,
        domicile_cd                       = new_references.domicile_cd,
        inst_last_attended                = new_references.inst_last_attended,
        year_left_last_inst               = new_references.year_left_last_inst,
        highest_qual_on_entry             = new_references.highest_qual_on_entry,
        date_qual_on_entry_calc           = new_references.date_qual_on_entry_calc,
        a_level_point_score               = new_references.a_level_point_score,
        highers_points_scores             = new_references.highers_points_scores,
        occupation_code                   = new_references.occupation_code,
        commencement_dt                   = new_references.commencement_dt,
        special_student                   = new_references.special_student,
        student_qual_aim                  = new_references.student_qual_aim,
        student_fe_qual_aim               = new_references.student_fe_qual_aim,
        teacher_train_prog_id             = new_references.teacher_train_prog_id,
        itt_phase                         = new_references.itt_phase,
        bilingual_itt_marker              = new_references.bilingual_itt_marker,
        teaching_qual_gain_sector         = new_references.teaching_qual_gain_sector,
        teaching_qual_gain_subj1          = new_references.teaching_qual_gain_subj1,
        teaching_qual_gain_subj2          = new_references.teaching_qual_gain_subj2,
        teaching_qual_gain_subj3          = new_references.teaching_qual_gain_subj3,
        student_inst_number               = new_references.student_inst_number,
        destination                       = new_references.destination,
        itt_prog_outcome                  = new_references.itt_prog_outcome,
        hesa_return_name                  = new_references.hesa_return_name,
        hesa_return_id                    = new_references.hesa_return_id,
        hesa_submission_name              = new_references.hesa_submission_name,
        associate_ucas_number             = new_references.associate_ucas_number,
        associate_scott_cand              = new_references.associate_scott_cand,
        associate_teach_ref_num           = new_references.associate_teach_ref_num,
        associate_nhs_reg_num             = new_references.associate_nhs_reg_num,
        nhs_funding_source                = new_references.nhs_funding_source,
        ufi_place                         = new_references.ufi_place,
        postcode                          = new_references.postcode,
        social_class_ind                  = new_references.social_class_ind,
        occcode                           = new_references.occcode,
        total_ucas_tariff                 = new_references.total_ucas_tariff,
        nhs_employer                      = new_references.nhs_employer,
        return_type                       = new_references.return_type,
        qual_aim_subj1                    = new_references.qual_aim_subj1,
        qual_aim_subj2                    = new_references.qual_aim_subj2,
        qual_aim_subj3                    = new_references.qual_aim_subj3,
        qual_aim_proportion               = new_references.qual_aim_proportion ,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        dependants_cd                     = new_references.dependants_cd,
        implied_fund_rate                 = new_references.implied_fund_rate,
        gov_initiatives_cd                = new_references.gov_initiatives_cd,
        units_for_qual                    = new_references.units_for_qual,
        disadv_uplift_elig_cd             = new_references.disadv_uplift_elig_cd,
        franch_partner_cd                 = new_references.franch_partner_cd,
        units_completed                   = new_references.units_completed,
        franch_out_arr_cd                 = new_references.franch_out_arr_cd,
        employer_role_cd                  = new_references.employer_role_cd,
        disadv_uplift_factor              = new_references.disadv_uplift_factor,
        enh_fund_elig_cd                  = new_references.enh_fund_elig_cd,
        exclude_flag                      = new_references.exclude_flag
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
    x_rowid                             IN OUT NOCOPY  VARCHAR2,
    x_hesa_st_spa_id                    IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_fe_student_marker                 IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_inst_last_attended                IN     VARCHAR2,
    x_year_left_last_inst               IN     VARCHAR2,
    x_highest_qual_on_entry             IN     VARCHAR2,
    x_date_qual_on_entry_calc           IN     DATE,
    x_a_level_point_score               IN     NUMBER,
    x_highers_points_scores             IN     NUMBER,
    x_occupation_code                   IN     VARCHAR2,
    x_commencement_dt                   IN     DATE,
    x_special_student                   IN     VARCHAR2,
    x_student_qual_aim                  IN     VARCHAR2,
    x_student_fe_qual_aim               IN     VARCHAR2,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_gain_sector         IN     VARCHAR2,
    x_teaching_qual_gain_subj1          IN     VARCHAR2,
    x_teaching_qual_gain_subj2          IN     VARCHAR2,
    x_teaching_qual_gain_subj3          IN     VARCHAR2,
    x_student_inst_number               IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_itt_prog_outcome                  IN     VARCHAR2,
    x_hesa_return_name                  IN     VARCHAR2,
    x_hesa_return_id                    IN     NUMBER,
    x_hesa_submission_name              IN     VARCHAR2,
    x_associate_ucas_number             IN     VARCHAR2,
    x_associate_scott_cand              IN     VARCHAR2,
    x_associate_teach_ref_num           IN     VARCHAR2,
    x_associate_nhs_reg_num             IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_postcode                          IN     VARCHAR2,
    x_social_class_ind                  IN     VARCHAR2,
    x_occcode                           IN     VARCHAR2,
    x_total_ucas_tariff                 IN     NUMBER,
    x_nhs_employer                      IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_qual_aim_subj1                    IN     VARCHAR2,
    x_qual_aim_subj2                    IN     VARCHAR2,
    x_qual_aim_subj3                    IN     VARCHAR2,
    x_qual_aim_proportion               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_dependants_cd                     IN     VARCHAR2,
    x_implied_fund_rate                 IN     NUMBER  ,
    x_gov_initiatives_cd                IN     VARCHAR2,
    x_units_for_qual                    IN     NUMBER  ,
    x_disadv_uplift_elig_cd             IN     VARCHAR2,
    x_franch_partner_cd                 IN     VARCHAR2,
    x_units_completed                   IN     NUMBER  ,
    x_franch_out_arr_cd                 IN     VARCHAR2,
    x_employer_role_cd                  IN     VARCHAR2,
    x_disadv_uplift_factor              IN     NUMBER  ,
    x_enh_fund_elig_cd                  IN     VARCHAR2,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_st_spa_all
      WHERE    hesa_st_spa_id                    = x_hesa_st_spa_id;

     l_mode VARCHAR2(1);

  BEGIN

    l_mode := NVL(x_mode,'R');

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_hesa_st_spa_id,
        x_org_id,
        x_person_id,
        x_course_cd,
        x_version_number,
        x_fe_student_marker,
        x_domicile_cd,
        x_inst_last_attended,
        x_year_left_last_inst,
        x_highest_qual_on_entry,
        x_date_qual_on_entry_calc,
        x_a_level_point_score,
        x_highers_points_scores,
        x_occupation_code,
        x_commencement_dt,
        x_special_student,
        x_student_qual_aim,
        x_student_fe_qual_aim,
        x_teacher_train_prog_id,
        x_itt_phase,
        x_bilingual_itt_marker,
        x_teaching_qual_gain_sector,
        x_teaching_qual_gain_subj1,
        x_teaching_qual_gain_subj2,
        x_teaching_qual_gain_subj3,
        x_student_inst_number,
        x_destination,
        x_itt_prog_outcome,
        x_hesa_return_name,
        x_hesa_return_id,
        x_hesa_submission_name,
        x_associate_ucas_number,
        x_associate_scott_cand,
        x_associate_teach_ref_num,
        x_associate_nhs_reg_num,
        x_nhs_funding_source,
        x_ufi_place,
        x_postcode,
        x_social_class_ind,
        x_occcode,
        x_total_ucas_tariff,
        x_nhs_employer,
        x_return_type,
        x_qual_aim_subj1,
        x_qual_aim_subj2 ,
        x_qual_aim_subj3,
        x_qual_aim_proportion,
        l_mode,
        x_dependants_cd,
        x_implied_fund_rate,
        x_gov_initiatives_cd,
        x_units_for_qual,
        x_disadv_uplift_elig_cd,
        x_franch_partner_cd,
        x_units_completed,
        x_franch_out_arr_cd,
        x_employer_role_cd,
        x_disadv_uplift_factor,
        x_enh_fund_elig_cd,
        x_exclude_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_hesa_st_spa_id,
      x_org_id,
      x_person_id,
      x_course_cd,
      x_version_number,
      x_fe_student_marker,
      x_domicile_cd,
      x_inst_last_attended,
      x_year_left_last_inst,
      x_highest_qual_on_entry,
      x_date_qual_on_entry_calc,
      x_a_level_point_score,
      x_highers_points_scores,
      x_occupation_code,
      x_commencement_dt,
      x_special_student,
      x_student_qual_aim,
      x_student_fe_qual_aim,
      x_teacher_train_prog_id,
      x_itt_phase,
      x_bilingual_itt_marker,
      x_teaching_qual_gain_sector,
      x_teaching_qual_gain_subj1,
      x_teaching_qual_gain_subj2,
      x_teaching_qual_gain_subj3,
      x_student_inst_number,
      x_destination,
      x_itt_prog_outcome,
      x_hesa_return_name,
      x_hesa_return_id,
      x_hesa_submission_name,
      x_associate_ucas_number,
      x_associate_scott_cand,
      x_associate_teach_ref_num,
      x_associate_nhs_reg_num,
      x_nhs_funding_source,
      x_ufi_place,
      x_postcode,
      x_social_class_ind,
      x_occcode,
      x_total_ucas_tariff,
      x_nhs_employer,
      x_return_type,
      x_qual_aim_subj1 ,
      x_qual_aim_subj2   ,
      x_qual_aim_subj3   ,
      x_qual_aim_proportion ,
      l_mode ,
      x_dependants_cd,
      x_implied_fund_rate,
      x_gov_initiatives_cd,
      x_units_for_qual,
      x_disadv_uplift_elig_cd,
      x_franch_partner_cd,
      x_units_completed,
      x_franch_out_arr_cd,
      x_employer_role_cd,
      x_disadv_uplift_factor,
      x_enh_fund_elig_cd,
      x_exclude_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
    x_mode IN VARCHAR2
  ) AS
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
    DELETE FROM igs_he_st_spa_all
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


END igs_he_st_spa_all_pkg;

/
