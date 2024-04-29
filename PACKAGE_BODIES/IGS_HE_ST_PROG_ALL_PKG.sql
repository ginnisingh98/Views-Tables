--------------------------------------------------------
--  DDL for Package Body IGS_HE_ST_PROG_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_ST_PROG_ALL_PKG" AS
/* $Header: IGSWI26B.pls 120.1 2006/02/06 19:54:15 jbaber noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_st_prog_all%ROWTYPE;
  new_references igs_he_st_prog_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_st_prog_id                   IN     NUMBER      ,
    x_org_id                            IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_version_number                    IN     NUMBER      ,
    x_teacher_train_prog_id             IN     VARCHAR2    ,
    x_itt_phase                         IN     VARCHAR2    ,
    x_bilingual_itt_marker              IN     VARCHAR2    ,
    x_teaching_qual_sought_sector       IN     VARCHAR2    ,
    x_teaching_qual_sought_subj1        IN     VARCHAR2    ,
    x_teaching_qual_sought_subj2        IN     VARCHAR2    ,
    x_teaching_qual_sought_subj3        IN     VARCHAR2    ,
    x_location_of_study                 IN     VARCHAR2    ,
    x_other_inst_prov_teaching1         IN     VARCHAR2    ,
    x_other_inst_prov_teaching2         IN     VARCHAR2    ,
    x_prop_teaching_in_welsh            IN     NUMBER      ,
    x_prop_not_taught                   IN     NUMBER      ,
    x_credit_transfer_scheme            IN     VARCHAR2    ,
    x_return_type                       IN     VARCHAR2    ,
    x_default_award                     IN     VARCHAR2    ,
    x_program_calc                      IN     VARCHAR2    ,
    x_level_applicable_to_funding       IN     VARCHAR2    ,
    x_franchising_activity              IN     VARCHAR2    ,
    x_nhs_funding_source                IN     VARCHAR2    ,
    x_fe_program_marker                 IN     VARCHAR2    ,
    x_fee_band                          IN     VARCHAR2    ,
    x_fundability                       IN     VARCHAR2    ,
    x_fte_intensity                     IN     NUMBER      ,
    x_teach_period_start_dt             IN     DATE       ,
    x_teach_period_end_dt               IN     DATE       ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_implied_fund_rate                 IN     NUMBER      ,
    x_gov_initiatives_cd                IN     VARCHAR2    ,
    x_units_for_qual                    IN     NUMBER      ,
    x_disadv_uplift_elig_cd             IN     VARCHAR2    ,
    x_franch_partner_cd                 IN     VARCHAR2    ,
    x_franch_out_arr_cd                 IN     VARCHAR2    ,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  sbaliga       4-Apr-2002      Added 3 new parameters to the function i.e. x_fte_intensity,
  ||                                x_teach_period_start_dt and x_teach_period_end_dt
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_ST_PROG_ALL
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
    new_references.hesa_st_prog_id                   := x_hesa_st_prog_id;
    new_references.org_id                            := x_org_id;
    new_references.course_cd                         := x_course_cd;
    new_references.version_number                    := x_version_number;
    new_references.teacher_train_prog_id             := x_teacher_train_prog_id;
    new_references.itt_phase                         := x_itt_phase;
    new_references.bilingual_itt_marker              := x_bilingual_itt_marker;
    new_references.teaching_qual_sought_sector       := x_teaching_qual_sought_sector;
    new_references.teaching_qual_sought_subj1        := x_teaching_qual_sought_subj1;
    new_references.teaching_qual_sought_subj2        := x_teaching_qual_sought_subj2;
    new_references.teaching_qual_sought_subj3        := x_teaching_qual_sought_subj3;
    new_references.location_of_study                 := x_location_of_study;
    new_references.other_inst_prov_teaching1         := x_other_inst_prov_teaching1;
    new_references.other_inst_prov_teaching2         := x_other_inst_prov_teaching2;
    new_references.prop_teaching_in_welsh            := x_prop_teaching_in_welsh;
    new_references.prop_not_taught                   := x_prop_not_taught;
    new_references.credit_transfer_scheme            := x_credit_transfer_scheme;
    new_references.return_type                       := x_return_type;
    new_references.default_award                     := x_default_award;
    new_references.program_calc                      := x_program_calc;
    new_references.level_applicable_to_funding       := x_level_applicable_to_funding;
    new_references.franchising_activity              := x_franchising_activity;
    new_references.nhs_funding_source                := x_nhs_funding_source;
    new_references.fe_program_marker                 := x_fe_program_marker;
    new_references.fee_band                          := x_fee_band;
    new_references.fundability                       := x_fundability;
    new_references.fte_intensity                     := x_fte_intensity;
    new_references.teach_period_start_dt             := x_teach_period_start_dt;
    new_references.teach_period_end_dt               := x_teach_period_end_dt;
    new_references.implied_fund_rate                 := x_implied_fund_rate;
    new_references.gov_initiatives_cd                := x_gov_initiatives_cd;
    new_references.units_for_qual                    := x_units_for_qual;
    new_references.disadv_uplift_elig_cd             := x_disadv_uplift_elig_cd;
    new_references.franch_partner_cd                 := x_franch_partner_cd;
    new_references.franch_out_arr_cd                 := x_franch_out_arr_cd;
    new_references.exclude_flag                      := x_exclude_flag;

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
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.course_cd,
           new_references.version_number
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_ver_pkg.get_pk_for_validation (
                new_references.course_cd,
                new_references.version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_hesa_st_prog_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_st_prog_all
      WHERE    hesa_st_prog_id = x_hesa_st_prog_id
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
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_st_prog_all
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
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


  PROCEDURE get_fk_igs_ps_ver_all (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_st_prog_all
      WHERE   ((course_cd = x_course_cd) AND
               (version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HSPR_CRV_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_ver_all;

  PROCEDURE check_prog_attempt_exists AS
    CURSOR cur_prog_attempt(cp_course_cd  igs_en_stdnt_ps_att.course_cd%TYPE,
                            cp_version    igs_en_stdnt_ps_att.version_number%TYPE
                            ) IS
    SELECT 'X' FROM igs_en_stdnt_ps_att
    WHERE course_cd      =   cp_course_cd
      AND version_number = cp_version;

      l_prog_attempt VARCHAR2(1);

  BEGIN
     --Check whether any SPAs exists for this program
     OPEN cur_prog_attempt(new_references.course_cd,
                           new_references.version_number);
     FETCH cur_prog_attempt INTO l_prog_attempt;
     IF cur_prog_attempt%FOUND THEN
        CLOSE cur_prog_attempt;
        fnd_message.set_name ('IGS', 'IGS_HE_CANT_DEL_SPA_EXIST');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
        RETURN;
     END IF;
     CLOSE cur_prog_attempt;

  END check_prog_attempt_exists;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_st_prog_id                   IN     NUMBER      ,
    x_org_id                            IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_version_number                    IN     NUMBER      ,
    x_teacher_train_prog_id             IN     VARCHAR2    ,
    x_itt_phase                         IN     VARCHAR2    ,
    x_bilingual_itt_marker              IN     VARCHAR2    ,
    x_teaching_qual_sought_sector       IN     VARCHAR2    ,
    x_teaching_qual_sought_subj1        IN     VARCHAR2    ,
    x_teaching_qual_sought_subj2        IN     VARCHAR2    ,
    x_teaching_qual_sought_subj3        IN     VARCHAR2    ,
    x_location_of_study                 IN     VARCHAR2    ,
    x_other_inst_prov_teaching1         IN     VARCHAR2    ,
    x_other_inst_prov_teaching2         IN     VARCHAR2    ,
    x_prop_teaching_in_welsh            IN     NUMBER      ,
    x_prop_not_taught                   IN     NUMBER      ,
    x_credit_transfer_scheme            IN     VARCHAR2    ,
    x_return_type                       IN     VARCHAR2    ,
    x_default_award                     IN     VARCHAR2    ,
    x_program_calc                      IN     VARCHAR2    ,
    x_level_applicable_to_funding       IN     VARCHAR2    ,
    x_franchising_activity              IN     VARCHAR2    ,
    x_nhs_funding_source                IN     VARCHAR2    ,
    x_fe_program_marker                 IN     VARCHAR2    ,
    x_fee_band                          IN     VARCHAR2    ,
    x_fundability                       IN     VARCHAR2    ,
    x_fte_intensity                     IN     NUMBER     ,
    x_teach_period_start_dt             IN     DATE       ,
    x_teach_period_end_dt               IN     DATE       ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_implied_fund_rate                 IN     NUMBER      DEFAULT NULL,
    x_gov_initiatives_cd                IN     VARCHAR2    DEFAULT NULL,
    x_units_for_qual                    IN     NUMBER      DEFAULT NULL,
    x_disadv_uplift_elig_cd             IN     VARCHAR2    DEFAULT NULL,
    x_franch_partner_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_franch_out_arr_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || pmarada        20-may-2003    While deleting a record checking whether any students
  ||                               attempted this program as per the bug 2932025.
  || sbaliga        Apr-4-2002      Added 3 new parameters to the function
  ||                               i.e. x_fte_intensity,x_teach_period_start_dt
  ||                               and  x_teach_period_end_dt
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_hesa_st_prog_id,
      x_org_id,
      x_course_cd,
      x_version_number,
      x_teacher_train_prog_id,
      x_itt_phase,
      x_bilingual_itt_marker,
      x_teaching_qual_sought_sector,
      x_teaching_qual_sought_subj1,
      x_teaching_qual_sought_subj2,
      x_teaching_qual_sought_subj3,
      x_location_of_study,
      x_other_inst_prov_teaching1,
      x_other_inst_prov_teaching2,
      x_prop_teaching_in_welsh,
      x_prop_not_taught,
      x_credit_transfer_scheme,
      x_return_type,
      x_default_award,
      x_program_calc,
      x_level_applicable_to_funding,
      x_franchising_activity,
      x_nhs_funding_source,
      x_fe_program_marker,
      x_fee_band,
      x_fundability,
      x_fte_intensity,
      x_teach_period_start_dt,
      x_teach_period_end_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_implied_fund_rate       ,
      x_gov_initiatives_cd      ,
      x_units_for_qual          ,
      x_disadv_uplift_elig_cd   ,
      x_franch_partner_cd       ,
      x_franch_out_arr_cd       ,
      x_exclude_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.hesa_st_prog_id
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
    ELSIF (p_action = 'DELETE') THEN
      check_prog_attempt_exists;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.hesa_st_prog_id
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
       check_prog_attempt_exists;
    END IF;

  END before_dml;


 PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_st_prog_id                   IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_sought_sector       IN     VARCHAR2,
    x_teaching_qual_sought_subj1        IN     VARCHAR2,
    x_teaching_qual_sought_subj2        IN     VARCHAR2,
    x_teaching_qual_sought_subj3        IN     VARCHAR2,
    x_location_of_study                 IN     VARCHAR2,
    x_other_inst_prov_teaching1         IN     VARCHAR2,
    x_other_inst_prov_teaching2         IN     VARCHAR2,
    x_prop_teaching_in_welsh            IN     NUMBER,
    x_prop_not_taught                   IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_default_award                     IN     VARCHAR2,
    x_program_calc                      IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_fe_program_marker                 IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_fundability                       IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER  ,
    x_teach_period_start_dt             IN     DATE    ,
    x_teach_period_end_dt               IN     DATE    ,
    x_mode                              IN     VARCHAR2 ,
    x_implied_fund_rate                 IN     NUMBER      DEFAULT NULL,
    x_gov_initiatives_cd                IN     VARCHAR2    DEFAULT NULL,
    x_units_for_qual                    IN     NUMBER      DEFAULT NULL,
    x_disadv_uplift_elig_cd             IN     VARCHAR2    DEFAULT NULL,
    x_franch_partner_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_franch_out_arr_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga        Apr-4-2002      Added 3 new parameters to the function
  ||                                i.e. x_fte_intensity,x_teach_period_start_dt
  ||                                and x_teach_period_end_dt
  ||  smvk            13-Feb-2002     call to igs_ge_gen_003.get_org_id
  ||                                  w.r.t. SWCR006
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_st_prog_all
      WHERE    hesa_st_prog_id                   = x_hesa_st_prog_id;

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
    ELSIF (l_mode = 'R') THEN
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

    SELECT    igs_he_st_prog_all_s.NEXTVAL
    INTO      x_hesa_st_prog_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_hesa_st_prog_id                   => x_hesa_st_prog_id,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_teacher_train_prog_id             => x_teacher_train_prog_id,
      x_itt_phase                         => x_itt_phase,
      x_bilingual_itt_marker              => x_bilingual_itt_marker,
      x_teaching_qual_sought_sector       => x_teaching_qual_sought_sector,
      x_teaching_qual_sought_subj1        => x_teaching_qual_sought_subj1,
      x_teaching_qual_sought_subj2        => x_teaching_qual_sought_subj2,
      x_teaching_qual_sought_subj3        => x_teaching_qual_sought_subj3,
      x_location_of_study                 => x_location_of_study,
      x_other_inst_prov_teaching1         => x_other_inst_prov_teaching1,
      x_other_inst_prov_teaching2         => x_other_inst_prov_teaching2,
      x_prop_teaching_in_welsh            => x_prop_teaching_in_welsh,
      x_prop_not_taught                   => x_prop_not_taught,
      x_credit_transfer_scheme            => x_credit_transfer_scheme,
      x_return_type                       => x_return_type,
      x_default_award                     => x_default_award,
      x_program_calc                      => x_program_calc,
      x_level_applicable_to_funding       => x_level_applicable_to_funding,
      x_franchising_activity              => x_franchising_activity,
      x_nhs_funding_source                => x_nhs_funding_source,
      x_fe_program_marker                 => x_fe_program_marker,
      x_fee_band                          => x_fee_band,
      x_fundability                       => x_fundability,
      x_fte_intensity                     => x_fte_intensity,
      x_teach_period_start_dt             => x_teach_period_start_dt,
      x_teach_period_end_dt               => x_teach_period_end_dt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_implied_fund_rate                 => x_implied_fund_rate    ,
      x_gov_initiatives_cd                => x_gov_initiatives_cd   ,
      x_units_for_qual                    => x_units_for_qual       ,
      x_disadv_uplift_elig_cd             => x_disadv_uplift_elig_cd,
      x_franch_partner_cd                 => x_franch_partner_cd    ,
      x_franch_out_arr_cd                 => x_franch_out_arr_cd    ,
      x_exclude_flag                      => x_exclude_flag
    );

    INSERT INTO igs_he_st_prog_all (
      hesa_st_prog_id,
      org_id,
      course_cd,
      version_number,
      teacher_train_prog_id,
      itt_phase,
      bilingual_itt_marker,
      teaching_qual_sought_sector,
      teaching_qual_sought_subj1,
      teaching_qual_sought_subj2,
      teaching_qual_sought_subj3,
      location_of_study,
      other_inst_prov_teaching1,
      other_inst_prov_teaching2,
      prop_teaching_in_welsh,
      prop_not_taught,
      credit_transfer_scheme,
      return_type,
      default_award,
      program_calc,
      level_applicable_to_funding,
      franchising_activity,
      nhs_funding_source,
      fe_program_marker,
      fee_band,
      fundability,
      fte_intensity,
      teach_period_start_dt,
      teach_period_end_dt,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      implied_fund_rate      ,
      gov_initiatives_cd     ,
      units_for_qual         ,
      disadv_uplift_elig_cd  ,
      franch_partner_cd      ,
      franch_out_arr_cd      ,
      exclude_flag
    ) VALUES (
      new_references.hesa_st_prog_id,
      new_references.org_id,
      new_references.course_cd,
      new_references.version_number,
      new_references.teacher_train_prog_id,
      new_references.itt_phase,
      new_references.bilingual_itt_marker,
      new_references.teaching_qual_sought_sector,
      new_references.teaching_qual_sought_subj1,
      new_references.teaching_qual_sought_subj2,
      new_references.teaching_qual_sought_subj3,
      new_references.location_of_study,
      new_references.other_inst_prov_teaching1,
      new_references.other_inst_prov_teaching2,
      new_references.prop_teaching_in_welsh,
      new_references.prop_not_taught,
      new_references.credit_transfer_scheme,
      new_references.return_type,
      new_references.default_award,
      new_references.program_calc,
      new_references.level_applicable_to_funding,
      new_references.franchising_activity,
      new_references.nhs_funding_source,
      new_references.fe_program_marker,
      new_references.fee_band,
      new_references.fundability,
      new_references.fte_intensity,
      new_references.teach_period_start_dt,
      new_references.teach_period_end_dt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.implied_fund_rate      ,
      new_references.gov_initiatives_cd     ,
      new_references.units_for_qual         ,
      new_references.disadv_uplift_elig_cd  ,
      new_references.franch_partner_cd      ,
      new_references.franch_out_arr_cd      ,
      new_references.exclude_flag
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
    x_hesa_st_prog_id                   IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_sought_sector       IN     VARCHAR2,
    x_teaching_qual_sought_subj1        IN     VARCHAR2,
    x_teaching_qual_sought_subj2        IN     VARCHAR2,
    x_teaching_qual_sought_subj3        IN     VARCHAR2,
    x_location_of_study                 IN     VARCHAR2,
    x_other_inst_prov_teaching1         IN     VARCHAR2,
    x_other_inst_prov_teaching2         IN     VARCHAR2,
    x_prop_teaching_in_welsh            IN     NUMBER,
    x_prop_not_taught                   IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_default_award                     IN     VARCHAR2,
    x_program_calc                      IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_fe_program_marker                 IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_fundability                       IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER    ,
    x_teach_period_start_dt             IN     DATE     ,
    x_teach_period_end_dt               IN     DATE     ,
    x_implied_fund_rate                 IN     NUMBER    DEFAULT NULL,
    x_gov_initiatives_cd                IN     VARCHAR2  DEFAULT NULL,
    x_units_for_qual                    IN     NUMBER    DEFAULT NULL,
    x_disadv_uplift_elig_cd             IN     VARCHAR2  DEFAULT NULL,
    x_franch_partner_cd                 IN     VARCHAR2  DEFAULT NULL,
    x_franch_out_arr_cd                 IN     VARCHAR2  DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga        Apr-4-2002      Added 3 new parameters to the function
  ||                              i.e. x_fte_intensity,x_teach_period_start_dt
  ||                               and  x_teach_period_end_dt
  ||  smvk            13-Feb-2002     Removed org_id from cursor declaration
  ||                                  and conditional checking w.r.t. SWCR006
  ||  (reverse chronological order - newest change first)
 */
    CURSOR c1 IS
      SELECT
        course_cd,
        version_number,
        teacher_train_prog_id,
        itt_phase,
        bilingual_itt_marker,
        teaching_qual_sought_sector,
        teaching_qual_sought_subj1,
        teaching_qual_sought_subj2,
        teaching_qual_sought_subj3,
        location_of_study,
        other_inst_prov_teaching1,
        other_inst_prov_teaching2,
        prop_teaching_in_welsh,
        prop_not_taught,
        credit_transfer_scheme,
        return_type,
        default_award,
        program_calc,
        level_applicable_to_funding,
        franchising_activity,
        nhs_funding_source,
        fe_program_marker,
        fee_band,
        fundability,
        fte_intensity,
        teach_period_start_dt,
        teach_period_end_dt,
        implied_fund_rate   ,
        gov_initiatives_cd   ,
        units_for_qual       ,
        disadv_uplift_elig_cd,
        franch_partner_cd    ,
        franch_out_arr_cd    ,
        exclude_flag
      FROM  igs_he_st_prog_all
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
        (tlinfo.course_cd = x_course_cd)
        AND (tlinfo.version_number = x_version_number)
        AND ((tlinfo.teacher_train_prog_id = x_teacher_train_prog_id) OR ((tlinfo.teacher_train_prog_id IS NULL) AND (X_teacher_train_prog_id IS NULL)))
        AND ((tlinfo.itt_phase = x_itt_phase) OR ((tlinfo.itt_phase IS NULL) AND (X_itt_phase IS NULL)))
        AND ((tlinfo.bilingual_itt_marker = x_bilingual_itt_marker) OR ((tlinfo.bilingual_itt_marker IS NULL) AND (X_bilingual_itt_marker IS NULL)))
        AND ((tlinfo.teaching_qual_sought_sector = x_teaching_qual_sought_sector) OR ((tlinfo.teaching_qual_sought_sector IS NULL) AND (X_teaching_qual_sought_sector IS NULL)))
        AND ((tlinfo.teaching_qual_sought_subj1 = x_teaching_qual_sought_subj1) OR ((tlinfo.teaching_qual_sought_subj1 IS NULL) AND (X_teaching_qual_sought_subj1 IS NULL)))
        AND ((tlinfo.teaching_qual_sought_subj2 = x_teaching_qual_sought_subj2) OR ((tlinfo.teaching_qual_sought_subj2 IS NULL) AND (X_teaching_qual_sought_subj2 IS NULL)))
        AND ((tlinfo.teaching_qual_sought_subj3 = x_teaching_qual_sought_subj3) OR ((tlinfo.teaching_qual_sought_subj3 IS NULL) AND (X_teaching_qual_sought_subj3 IS NULL)))
        AND ((tlinfo.location_of_study = x_location_of_study) OR ((tlinfo.location_of_study IS NULL) AND (X_location_of_study IS NULL)))
        AND ((tlinfo.other_inst_prov_teaching1 = x_other_inst_prov_teaching1) OR ((tlinfo.other_inst_prov_teaching1 IS NULL) AND (X_other_inst_prov_teaching1 IS NULL)))
        AND ((tlinfo.other_inst_prov_teaching2 = x_other_inst_prov_teaching2) OR ((tlinfo.other_inst_prov_teaching2 IS NULL) AND (X_other_inst_prov_teaching2 IS NULL)))
        AND ((tlinfo.prop_teaching_in_welsh = x_prop_teaching_in_welsh) OR ((tlinfo.prop_teaching_in_welsh IS NULL) AND (X_prop_teaching_in_welsh IS NULL)))
        AND ((tlinfo.prop_not_taught = x_prop_not_taught) OR ((tlinfo.prop_not_taught IS NULL) AND (X_prop_not_taught IS NULL)))
        AND ((tlinfo.credit_transfer_scheme = x_credit_transfer_scheme) OR ((tlinfo.credit_transfer_scheme IS NULL) AND (X_credit_transfer_scheme IS NULL)))
        AND ((tlinfo.return_type = x_return_type) OR ((tlinfo.return_type IS NULL) AND (X_return_type IS NULL)))
        AND ((tlinfo.default_award = x_default_award) OR ((tlinfo.default_award IS NULL) AND (X_default_award IS NULL)))
        AND ((tlinfo.program_calc = x_program_calc) OR ((tlinfo.program_calc IS NULL) AND (X_program_calc IS NULL)))
        AND ((tlinfo.level_applicable_to_funding = x_level_applicable_to_funding) OR ((tlinfo.level_applicable_to_funding IS NULL) AND (X_level_applicable_to_funding IS NULL)))
        AND ((tlinfo.franchising_activity = x_franchising_activity) OR ((tlinfo.franchising_activity IS NULL) AND (X_franchising_activity IS NULL)))
        AND ((tlinfo.nhs_funding_source = x_nhs_funding_source) OR ((tlinfo.nhs_funding_source IS NULL) AND (X_nhs_funding_source IS NULL)))
        AND ((tlinfo.fe_program_marker = x_fe_program_marker) OR ((tlinfo.fe_program_marker IS NULL) AND (X_fe_program_marker IS NULL)))
        AND ((tlinfo.fee_band = x_fee_band) OR ((tlinfo.fee_band IS NULL) AND (X_fee_band IS NULL)))
        AND ((tlinfo.fundability = x_fundability) OR ((tlinfo.fundability IS NULL) AND (X_fundability IS NULL)))
        AND ((tlinfo.fte_intensity = x_fte_intensity) OR ((tlinfo.fte_intensity IS NULL) AND (X_fte_intensity IS NULL)))
        AND ((tlinfo.teach_period_start_dt = x_teach_period_start_dt) OR ((tlinfo.teach_period_start_dt IS NULL) AND (X_teach_period_start_dt IS NULL)))
        AND ((tlinfo.teach_period_end_dt = x_teach_period_end_dt) OR ((tlinfo.teach_period_end_dt IS NULL) AND (X_teach_period_end_dt IS NULL)))
        AND ((tlinfo.implied_fund_rate     = x_implied_fund_rate    ) OR ((tlinfo.implied_fund_rate     IS NULL) AND (x_implied_fund_rate     IS NULL)))
        AND ((tlinfo.gov_initiatives_cd    = x_gov_initiatives_cd   ) OR ((tlinfo.gov_initiatives_cd    IS NULL) AND (x_gov_initiatives_cd    IS NULL)))
        AND ((tlinfo.units_for_qual        = x_units_for_qual       ) OR ((tlinfo.units_for_qual        IS NULL) AND (x_units_for_qual        IS NULL)))
        AND ((tlinfo.disadv_uplift_elig_cd = x_disadv_uplift_elig_cd) OR ((tlinfo.disadv_uplift_elig_cd IS NULL) AND (x_disadv_uplift_elig_cd IS NULL)))
        AND ((tlinfo.franch_partner_cd     = x_franch_partner_cd    ) OR ((tlinfo.franch_partner_cd     IS NULL) AND (x_franch_partner_cd     IS NULL)))
        AND ((tlinfo.franch_out_arr_cd     = x_franch_out_arr_cd    ) OR ((tlinfo.franch_out_arr_cd     IS NULL) AND (x_franch_out_arr_cd     IS NULL)))
        AND ((tlinfo.exclude_flag          = x_exclude_flag         ) OR ((tlinfo.exclude_flag          IS NULL) AND (x_exclude_flag          IS NULL)))
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
    x_hesa_st_prog_id                   IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_sought_sector       IN     VARCHAR2,
    x_teaching_qual_sought_subj1        IN     VARCHAR2,
    x_teaching_qual_sought_subj2        IN     VARCHAR2,
    x_teaching_qual_sought_subj3        IN     VARCHAR2,
    x_location_of_study                 IN     VARCHAR2,
    x_other_inst_prov_teaching1         IN     VARCHAR2,
    x_other_inst_prov_teaching2         IN     VARCHAR2,
    x_prop_teaching_in_welsh            IN     NUMBER,
    x_prop_not_taught                   IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_default_award                     IN     VARCHAR2,
    x_program_calc                      IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_fe_program_marker                 IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_fundability                       IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER  ,
    x_teach_period_start_dt             IN     DATE    ,
    x_teach_period_end_dt               IN     DATE    ,
    x_mode                              IN     VARCHAR2 ,
    x_implied_fund_rate                 IN     NUMBER    DEFAULT NULL,
    x_gov_initiatives_cd                IN     VARCHAR2  DEFAULT NULL,
    x_units_for_qual                    IN     NUMBER    DEFAULT NULL,
    x_disadv_uplift_elig_cd             IN     VARCHAR2  DEFAULT NULL,
    x_franch_partner_cd                 IN     VARCHAR2  DEFAULT NULL,
    x_franch_out_arr_cd                 IN     VARCHAR2  DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga        Apr-4-2002      Added 3 new parameters to the function
  ||                              i.e. x_fte_intensity,x_teach_period_start_dt
  ||                               and  x_teach_period_end_dt
  ||  smvk            13-Feb-2002     Call to igs_ge_gen_003.get_org_id
  ||                                  w.r.t. SWCR006
  ||  (reverse chronological order - newest change first)
   */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_mode VARCHAR2(1);
  BEGIN

    l_mode := NVL(x_mode,'R');

    x_last_update_date := SYSDATE;
    IF (l_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (l_mode = 'R') THEN
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
      x_hesa_st_prog_id                   => x_hesa_st_prog_id,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_teacher_train_prog_id             => x_teacher_train_prog_id,
      x_itt_phase                         => x_itt_phase,
      x_bilingual_itt_marker              => x_bilingual_itt_marker,
      x_teaching_qual_sought_sector       => x_teaching_qual_sought_sector,
      x_teaching_qual_sought_subj1        => x_teaching_qual_sought_subj1,
      x_teaching_qual_sought_subj2        => x_teaching_qual_sought_subj2,
      x_teaching_qual_sought_subj3        => x_teaching_qual_sought_subj3,
      x_location_of_study                 => x_location_of_study,
      x_other_inst_prov_teaching1         => x_other_inst_prov_teaching1,
      x_other_inst_prov_teaching2         => x_other_inst_prov_teaching2,
      x_prop_teaching_in_welsh            => x_prop_teaching_in_welsh,
      x_prop_not_taught                   => x_prop_not_taught,
      x_credit_transfer_scheme            => x_credit_transfer_scheme,
      x_return_type                       => x_return_type,
      x_default_award                     => x_default_award,
      x_program_calc                      => x_program_calc,
      x_level_applicable_to_funding       => x_level_applicable_to_funding,
      x_franchising_activity              => x_franchising_activity,
      x_nhs_funding_source                => x_nhs_funding_source,
      x_fe_program_marker                 => x_fe_program_marker,
      x_fee_band                          => x_fee_band,
      x_fundability                       => x_fundability,
      x_fte_intensity                     => x_fte_intensity,
      x_teach_period_start_dt             => x_teach_period_start_dt,
      x_teach_period_end_dt               => x_teach_period_end_dt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_implied_fund_rate                 => x_implied_fund_rate    ,
      x_gov_initiatives_cd                => x_gov_initiatives_cd   ,
      x_units_for_qual                    => x_units_for_qual       ,
      x_disadv_uplift_elig_cd             => x_disadv_uplift_elig_cd,
      x_franch_partner_cd                 => x_franch_partner_cd    ,
      x_franch_out_arr_cd                 => x_franch_out_arr_cd    ,
      x_exclude_flag                      => x_exclude_flag
    );

    UPDATE igs_he_st_prog_all
      SET
        course_cd                         = new_references.course_cd,
        version_number                    = new_references.version_number,
        teacher_train_prog_id             = new_references.teacher_train_prog_id,
        itt_phase                         = new_references.itt_phase,
        bilingual_itt_marker              = new_references.bilingual_itt_marker,
        teaching_qual_sought_sector       = new_references.teaching_qual_sought_sector,
        teaching_qual_sought_subj1        = new_references.teaching_qual_sought_subj1,
        teaching_qual_sought_subj2        = new_references.teaching_qual_sought_subj2,
        teaching_qual_sought_subj3        = new_references.teaching_qual_sought_subj3,
        location_of_study                 = new_references.location_of_study,
        other_inst_prov_teaching1         = new_references.other_inst_prov_teaching1,
        other_inst_prov_teaching2         = new_references.other_inst_prov_teaching2,
        prop_teaching_in_welsh            = new_references.prop_teaching_in_welsh,
        prop_not_taught                   = new_references.prop_not_taught,
        credit_transfer_scheme            = new_references.credit_transfer_scheme,
        return_type                       = new_references.return_type,
        default_award                     = new_references.default_award,
        program_calc                      = new_references.program_calc,
        level_applicable_to_funding       = new_references.level_applicable_to_funding,
        franchising_activity              = new_references.franchising_activity,
        nhs_funding_source                = new_references.nhs_funding_source,
        fe_program_marker                 = new_references.fe_program_marker,
        fee_band                          = new_references.fee_band,
        fundability                       = new_references.fundability,
        fte_intensity                     = new_references.fte_intensity,
        teach_period_start_dt             = new_references.teach_period_start_dt,
        teach_period_end_dt               = new_references.teach_period_end_dt,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        implied_fund_rate                 = new_references.implied_fund_rate    ,
        gov_initiatives_cd                = new_references.gov_initiatives_cd   ,
        units_for_qual                    = new_references.units_for_qual       ,
        disadv_uplift_elig_cd             = new_references.disadv_uplift_elig_cd,
        franch_partner_cd                 = new_references.franch_partner_cd    ,
        franch_out_arr_cd                 = new_references.franch_out_arr_cd    ,
        exclude_flag                      = new_references.exclude_flag
        WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_st_prog_id                   IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_teacher_train_prog_id             IN     VARCHAR2,
    x_itt_phase                         IN     VARCHAR2,
    x_bilingual_itt_marker              IN     VARCHAR2,
    x_teaching_qual_sought_sector       IN     VARCHAR2,
    x_teaching_qual_sought_subj1        IN     VARCHAR2,
    x_teaching_qual_sought_subj2        IN     VARCHAR2,
    x_teaching_qual_sought_subj3        IN     VARCHAR2,
    x_location_of_study                 IN     VARCHAR2,
    x_other_inst_prov_teaching1         IN     VARCHAR2,
    x_other_inst_prov_teaching2         IN     VARCHAR2,
    x_prop_teaching_in_welsh            IN     NUMBER,
    x_prop_not_taught                   IN     NUMBER,
    x_credit_transfer_scheme            IN     VARCHAR2,
    x_return_type                       IN     VARCHAR2,
    x_default_award                     IN     VARCHAR2,
    x_program_calc                      IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_nhs_funding_source                IN     VARCHAR2,
    x_fe_program_marker                 IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_fundability                       IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER  ,
    x_teach_period_start_dt             IN     DATE    ,
    x_teach_period_end_dt               IN     DATE    ,
    x_mode                              IN     VARCHAR2 ,
    x_implied_fund_rate                 IN     NUMBER    DEFAULT NULL,
    x_gov_initiatives_cd                IN     VARCHAR2  DEFAULT NULL,
    x_units_for_qual                    IN     NUMBER    DEFAULT NULL,
    x_disadv_uplift_elig_cd             IN     VARCHAR2  DEFAULT NULL,
    x_franch_partner_cd                 IN     VARCHAR2  DEFAULT NULL,
    x_franch_out_arr_cd                 IN     VARCHAR2  DEFAULT NULL,
    x_exclude_flag                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga        Apr-4-2002      Added 3 new parameters to the function
  ||                              i.e. x_fte_intensity,x_teach_period_start_dt
  ||                               and  x_teach_period_end_dt
  ||  (reverse chronological order - newest change first)
   */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_st_prog_all
      WHERE    hesa_st_prog_id                   = x_hesa_st_prog_id;

    l_mode VARCHAR2(1);

  BEGIN

    l_mode := NVL(x_mode,'R');

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_hesa_st_prog_id,
        x_org_id,
        x_course_cd,
        x_version_number,
        x_teacher_train_prog_id,
        x_itt_phase,
        x_bilingual_itt_marker,
        x_teaching_qual_sought_sector,
        x_teaching_qual_sought_subj1,
        x_teaching_qual_sought_subj2,
        x_teaching_qual_sought_subj3,
        x_location_of_study,
        x_other_inst_prov_teaching1,
        x_other_inst_prov_teaching2,
        x_prop_teaching_in_welsh,
        x_prop_not_taught,
        x_credit_transfer_scheme,
        x_return_type,
        x_default_award,
        x_program_calc,
        x_level_applicable_to_funding,
        x_franchising_activity,
        x_nhs_funding_source,
        x_fe_program_marker,
        x_fee_band,
        x_fundability,
        x_fte_intensity,
        x_teach_period_start_dt,
        x_teach_period_end_dt,
        l_mode,
        x_implied_fund_rate    ,
        x_gov_initiatives_cd   ,
        x_units_for_qual       ,
        x_disadv_uplift_elig_cd,
        x_franch_partner_cd    ,
        x_franch_out_arr_cd    ,
        x_exclude_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_hesa_st_prog_id,
      x_org_id,
      x_course_cd,
      x_version_number,
      x_teacher_train_prog_id,
      x_itt_phase,
      x_bilingual_itt_marker,
      x_teaching_qual_sought_sector,
      x_teaching_qual_sought_subj1,
      x_teaching_qual_sought_subj2,
      x_teaching_qual_sought_subj3,
      x_location_of_study,
      x_other_inst_prov_teaching1,
      x_other_inst_prov_teaching2,
      x_prop_teaching_in_welsh,
      x_prop_not_taught,
      x_credit_transfer_scheme,
      x_return_type,
      x_default_award,
      x_program_calc,
      x_level_applicable_to_funding,
      x_franchising_activity,
      x_nhs_funding_source,
      x_fe_program_marker,
      x_fee_band,
      x_fundability,
      x_fte_intensity,
      x_teach_period_start_dt,
      x_teach_period_end_dt,
      l_mode ,
      x_implied_fund_rate    ,
      x_gov_initiatives_cd   ,
      x_units_for_qual       ,
      x_disadv_uplift_elig_cd,
      x_franch_partner_cd    ,
      x_franch_out_arr_cd    ,
      x_exclude_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sgangise@oracle.com
  ||  Created On : 29-JAN-2002
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

    DELETE FROM igs_he_st_prog_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_st_prog_all_pkg;

/
