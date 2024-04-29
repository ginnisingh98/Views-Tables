--------------------------------------------------------
--  DDL for Package Body IGS_HE_POOUS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_POOUS_ALL_PKG" AS
/* $Header: IGSWI17B.pls 120.1 2006/05/22 09:25:33 jchakrab noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_poous_all%ROWTYPE;
  new_references igs_he_poous_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_poous_id                     IN     NUMBER      ,
    x_org_id                            IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_crv_version_number                IN     NUMBER      ,
    x_cal_type                          IN     VARCHAR2    ,
    x_location_cd                       IN     VARCHAR2    ,
    x_attendance_mode                   IN     VARCHAR2    ,
    x_attendance_type                   IN     VARCHAR2    ,
    x_unit_set_cd                       IN     VARCHAR2    ,
    x_us_version_number                 IN     NUMBER      ,
    x_location_of_study                 IN     VARCHAR2    ,
    x_mode_of_study                     IN     VARCHAR2    ,
    x_ufi_place                         IN     VARCHAR2    ,
    x_franchising_activity              IN     VARCHAR2    ,
    x_type_of_year                      IN     VARCHAR2    ,
    x_leng_current_year                 IN     NUMBER      ,
    x_grading_schema_cd                 IN     VARCHAR2    ,
    x_gs_version_number                 IN     NUMBER      ,
    x_credit_value_yop1                 IN     NUMBER      ,
    x_level_credit1                     IN     VARCHAR2    ,
    x_credit_value_yop2                 IN     NUMBER      ,
    x_level_credit2                     IN     VARCHAR2    ,
    x_credit_value_yop3                 IN     NUMBER      ,
    x_level_credit3                     IN     VARCHAR2    ,
    x_credit_value_yop4                 IN     NUMBER      ,
    x_level_credit4                     IN     VARCHAR2    ,
    x_fte_intensity                     IN     NUMBER      ,
    x_fte_calc_type                     IN     VARCHAR2    ,
    x_teach_period_start_dt             IN     DATE        ,
    x_teach_period_end_dt               IN      DATE      ,
    x_other_instit_teach1               IN     VARCHAR2    ,
    x_other_instit_teach2               IN     VARCHAR2    ,
    x_prop_not_taught                   IN     NUMBER      ,
    x_fundability_cd                    IN     VARCHAR2    ,
    x_fee_band                          IN     VARCHAR2    ,
    x_level_applicable_to_funding       IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_funding_source                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 26-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga        27-Mar-2002     Renamed column fte_pc_override as fte_itensity
  ||                                and added 3 new parameters x_fte_calc_type,x_teach_period_start_dt
  ||                                and x_teach_period_end_dt  as part of #2278825
  ||  (reverse chronological order - newest change first)
  || smaddali 20-aug-03   Added new field funding_source for hefd208 bug#2717751
  || jchakrab      15-Sep-2004      Added 4 new columns - CREDIT_VALUE_YOP3, LEVEL_CREDIT3,
  ||                                CREDIT_VALUE_YOP4 and LEVEL_CREDIT4 as part of HEFD350
  ||
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_POOUS_ALL
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
    new_references.hesa_poous_id                     := x_hesa_poous_id;
    new_references.org_id                            := x_org_id;
    new_references.course_cd                         := x_course_cd;
    new_references.crv_version_number                := x_crv_version_number;
    new_references.cal_type                          := x_cal_type;
    new_references.location_cd                       := x_location_cd;
    new_references.attendance_mode                   := x_attendance_mode;
    new_references.attendance_type                   := x_attendance_type;
    new_references.unit_set_cd                       := x_unit_set_cd;
    new_references.us_version_number                 := x_us_version_number;
    new_references.location_of_study                 := x_location_of_study;
    new_references.mode_of_study                     := x_mode_of_study;
    new_references.ufi_place                         := x_ufi_place;
    new_references.franchising_activity              := x_franchising_activity;
    new_references.type_of_year                      := x_type_of_year;
    new_references.leng_current_year                 := x_leng_current_year;
    new_references.grading_schema_cd                 := x_grading_schema_cd;
    new_references.gs_version_number                 := x_gs_version_number;
    new_references.credit_value_yop1                 := x_credit_value_yop1;
    new_references.level_credit1                     := x_level_credit1;
    new_references.credit_value_yop2                 := x_credit_value_yop2;
    new_references.level_credit2                     := x_level_credit2;
    new_references.credit_value_yop3                 := x_credit_value_yop3;
    new_references.level_credit3                     := x_level_credit3;
    new_references.credit_value_yop4                 := x_credit_value_yop4;
    new_references.level_credit4                     := x_level_credit4;
    new_references.fte_intensity                     := x_fte_intensity;
    new_references.fte_calc_type                     := x_fte_calc_type;
    new_references.teach_period_start_dt             := x_teach_period_start_dt;
    new_references.teach_period_end_dt               := x_teach_period_end_dt;
    new_references.other_instit_teach1               := x_other_instit_teach1;
    new_references.other_instit_teach2               := x_other_instit_teach2;
    new_references.prop_not_taught                   := x_prop_not_taught;
    new_references.fundability_cd                    := x_fundability_cd;
    new_references.fee_band                          := x_fee_band;
    new_references.level_applicable_to_funding       := x_level_applicable_to_funding;
    new_references.funding_source                    := x_funding_source;

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
  ||  Created On : 26-JAN-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.course_cd,
           new_references.crv_version_number,
           new_references.cal_type,
           new_references.location_cd,
           new_references.attendance_mode,
           new_references.attendance_type,
           new_references.unit_set_cd,
           new_references.us_version_number
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
  ||  Created On : 26-JAN-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || jchakrab    03-May-2006     Added check for parent unitsets in IGS_PS_OFR_OPT_UNIT_SET_V
  || smaddali added new parent check for funding_source for hefd208 bug#2717751
  ||
  */

    CURSOR cur_unitset_check(cp_course_cd igs_ps_ofr_opt_unit_set_v.course_cd%TYPE,
                     cp_crv_version_number igs_ps_ofr_opt_unit_set_v.crv_version_number%TYPE,
                     cp_cal_type igs_ps_ofr_opt_unit_set_v.cal_type%TYPE,
                     cp_location_cd igs_ps_ofr_opt_unit_set_v.location_cd%TYPE,
                     cp_attendance_mode igs_ps_ofr_opt_unit_set_v.attendance_mode%TYPE,
                     cp_attendance_type igs_ps_ofr_opt_unit_set_v.attendance_type%TYPE,
                     cp_unit_set_cd igs_ps_ofr_opt_unit_set_v.unit_set_cd%TYPE,
                     cp_us_version_number igs_ps_ofr_opt_unit_set_v.us_version_number%TYPE) IS
      SELECT 'X'
      FROM   IGS_PS_OFR_OPT_UNIT_SET_V
      WHERE  COURSE_CD = cp_course_cd
      AND    CRV_VERSION_NUMBER = cp_crv_version_number
      AND    CAL_TYPE = cp_cal_type
      AND    LOCATION_CD = cp_location_cd
      AND    ATTENDANCE_MODE = cp_attendance_mode
      AND    ATTENDANCE_TYPE = cp_attendance_type
      AND    UNIT_SET_CD = cp_unit_set_cd
      AND    US_VERSION_NUMBER = cp_us_version_number;

      l_c_var VARCHAR2(1);


  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.crv_version_number = new_references.crv_version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.location_cd = new_references.location_cd) AND
         (old_references.attendance_mode = new_references.attendance_mode) AND
         (old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.crv_version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.location_cd IS NULL) OR
         (new_references.attendance_mode IS NULL) OR
         (new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_ofr_opt_pkg.get_pk_for_validation (
                new_references.course_cd,
                new_references.crv_version_number,
                new_references.cal_type,
                new_references.location_cd,
                new_references.attendance_mode,
                new_references.attendance_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.us_version_number = new_references.us_version_number)) OR
        ((new_references.unit_set_cd IS NULL) OR
         (new_references.us_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_unit_set_pkg.get_pk_for_validation (
                new_references.unit_set_cd,
                new_references.us_version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    -- smaddali added parent check for funding_source field
    IF (old_references.funding_source = new_references.funding_source)  OR
        (new_references.funding_source IS NULL)  THEN
      NULL;
    ELSIF NOT igs_fi_fund_src_pkg.get_pk_for_validation (
                new_references.funding_source
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    --Added this check for unit sets in IGS_PS_OFR_OPT_UNIT_SET_V view
    OPEN cur_unitset_check( new_references.course_cd,
                    new_references.crv_version_number,
                    new_references.cal_type,
                    new_references.location_cd,
                    new_references.attendance_mode,
                    new_references.attendance_type,
                    new_references.unit_set_cd,
                    new_references.us_version_number);
    FETCH cur_unitset_check INTO l_c_var;
    IF cur_unitset_check%NOTFOUND THEN
        CLOSE cur_unitset_check;
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    END IF;
    CLOSE cur_unitset_check;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_hesa_poous_id                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 26-JAN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_poous_all
      WHERE    hesa_poous_id = x_hesa_poous_id
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
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 26-JAN-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_poous_all
      WHERE    course_cd = x_course_cd
      AND      crv_version_number = x_crv_version_number
      AND      cal_type = x_cal_type
      AND      location_cd = x_location_cd
      AND      attendance_mode = x_attendance_mode
      AND      attendance_type = x_attendance_type
      AND      unit_set_cd = x_unit_set_cd
      AND      us_version_number = x_us_version_number
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


  PROCEDURE get_fk_igs_ps_ofr_opt_all (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 26-JAN-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_poous_all
      WHERE   ((attendance_mode = x_attendance_mode) AND
               (attendance_type = x_attendance_type) AND
               (cal_type = x_cal_type) AND
               (course_cd = x_course_cd) AND
               (crv_version_number = x_version_number) AND
               (location_cd = x_location_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HPUD_UOO_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_ofr_opt_all;


  PROCEDURE get_fk_igs_en_unit_set_all (
    x_unit_set_cd                       IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 26-JAN-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_poous_all
      WHERE   ((unit_set_cd = x_unit_set_cd) AND
               (us_version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HPUD_US_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_unit_set_all;

  PROCEDURE get_fk_igs_ps_ofr_unit_set (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_unit_set_cd IN VARCHAR2,
    x_us_version_number IN NUMBER
    ) AS
  /*************************************************************
  Created By :jchakrab
  Date Created By :03-MAY-2006
  Purpose : To be called by parent TBH to check child existence
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_HE_POOUS_ALL
      WHERE    COURSE_CD = x_course_cd
      AND      CRV_VERSION_NUMBER = x_version_number
      AND      CAL_TYPE = x_cal_type
      AND      UNIT_SET_CD = x_unit_set_cd
      AND      US_VERSION_NUMBER = x_us_version_number ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_HE_HPUD_US_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END get_fk_igs_ps_ofr_unit_set;


  PROCEDURE check_spa_exists AS
    CURSOR cur_stdnt(cp_course_cd  igs_en_stdnt_ps_att.course_cd%TYPE,
                     cp_version    igs_en_stdnt_ps_att.version_number%TYPE,
                     cp_cal_type   igs_en_stdnt_ps_att.cal_type%TYPE,
                     cp_location_cd igs_en_stdnt_ps_att.location_cd%TYPE,
                     cp_attendance_mode  igs_en_stdnt_ps_att.attendance_mode%TYPE,
                     cp_attendance_type  igs_en_stdnt_ps_att.attendance_type%TYPE) IS
    SELECT 'X' FROM igs_en_stdnt_ps_att
    WHERE course_cd =   cp_course_cd
      AND version_number = cp_version
      AND cal_type       = cp_cal_type
      AND location_cd    = cp_location_cd
      AND attendance_mode = cp_attendance_mode
      AND attendance_type =cp_attendance_type;

      l_stdnt VARCHAR2(1);

  BEGIN
     OPEN cur_stdnt (new_references.course_cd,
                     new_references.crv_version_number,
                     new_references.cal_type,
                     new_references.location_cd,
                     new_references.attendance_mode,
                     new_references.attendance_type);
     FETCH cur_stdnt INTO l_stdnt;
     IF cur_stdnt%FOUND THEN
        CLOSE cur_stdnt;
        fnd_message.set_name ('IGS', 'IGS_HE_CANT_DEL_POP_EXIST');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
        RETURN;
     END IF;
     CLOSE cur_stdnt;

  END check_spa_exists;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_hesa_poous_id                     IN     NUMBER      ,
    x_org_id                            IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_crv_version_number                IN     NUMBER      ,
    x_cal_type                          IN     VARCHAR2    ,
    x_location_cd                       IN     VARCHAR2    ,
    x_attendance_mode                   IN     VARCHAR2    ,
    x_attendance_type                   IN     VARCHAR2    ,
    x_unit_set_cd                       IN     VARCHAR2    ,
    x_us_version_number                 IN     NUMBER      ,
    x_location_of_study                 IN     VARCHAR2    ,
    x_mode_of_study                     IN     VARCHAR2    ,
    x_ufi_place                         IN     VARCHAR2    ,
    x_franchising_activity              IN     VARCHAR2    ,
    x_type_of_year                      IN     VARCHAR2    ,
    x_leng_current_year                 IN     NUMBER      ,
    x_grading_schema_cd                 IN     VARCHAR2    ,
    x_gs_version_number                 IN     NUMBER      ,
    x_credit_value_yop1                 IN     NUMBER      ,
    x_level_credit1                     IN     VARCHAR2    ,
    x_credit_value_yop2                 IN     NUMBER      ,
    x_level_credit2                     IN     VARCHAR2    ,
    x_credit_value_yop3                 IN     NUMBER      ,
    x_level_credit3                     IN     VARCHAR2    ,
    x_credit_value_yop4                 IN     NUMBER      ,
    x_level_credit4                     IN     VARCHAR2    ,
    x_fte_intensity                     IN     NUMBER      ,
    x_fte_calc_type                     IN     VARCHAR2    ,
    x_teach_period_start_dt             IN     DATE        ,
    x_teach_period_end_dt               IN      DATE      ,
    x_other_instit_teach1               IN     VARCHAR2    ,
    x_other_instit_teach2               IN     VARCHAR2    ,
    x_prop_not_taught                   IN     NUMBER      ,
    x_fundability_cd                    IN     VARCHAR2    ,
    x_fee_band                          IN     VARCHAR2    ,
    x_level_applicable_to_funding       IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_funding_source                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 26-JAN-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who        When            What
  || pmarada    20-may-2003     While delete a record checking whether any student program
  ||                            attempt exist as per the bug 2932025.
  || sbaliga    27-Mar-2002     Renamed column fte_pc_override as fte_itensity
  ||                            and added 3 new parameters x_fte_calc_type,x_teach_period_start_dt
  ||                            and x_teach_period_end_dt  as part of #2278825
  ||  (reverse chronological order - newest change first)
  || smaddali 20-aug-03   Added new field funding_source for hefd208 bug#2717751
  || jchakrab  15-Sep-2004      Added 4 new columns - CREDIT_VALUE_YOP3, LEVEL_CREDIT3,
  ||                            CREDIT_VALUE_YOP4 and LEVEL_CREDIT4 as part of HEFD350
  ||
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_hesa_poous_id,
      x_org_id,
      x_course_cd,
      x_crv_version_number,
      x_cal_type,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_unit_set_cd,
      x_us_version_number,
      x_location_of_study,
      x_mode_of_study,
      x_ufi_place,
      x_franchising_activity,
      x_type_of_year,
      x_leng_current_year,
      x_grading_schema_cd,
      x_gs_version_number,
      x_credit_value_yop1,
      x_level_credit1,
      x_credit_value_yop2,
      x_level_credit2,
      x_credit_value_yop3,
      x_level_credit3,
      x_credit_value_yop4,
      x_level_credit4,
      x_fte_intensity,
      x_fte_calc_type,
      x_teach_period_start_dt,
      x_teach_period_end_dt,
      x_other_instit_teach1,
      x_other_instit_teach2,
      x_prop_not_taught,
      x_fundability_cd,
      x_fee_band,
      x_level_applicable_to_funding,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_funding_source
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.hesa_poous_id
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
       check_spa_exists;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.hesa_poous_id
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
        check_spa_exists;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_poous_id                     IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_location_of_study                 IN     VARCHAR2,
    x_mode_of_study                     IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_type_of_year                      IN     VARCHAR2,
    x_leng_current_year                 IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_credit_value_yop1                 IN     NUMBER,
    x_level_credit1                     IN     VARCHAR2,
    x_credit_value_yop2                 IN     NUMBER,
    x_level_credit2                     IN     VARCHAR2,
    x_credit_value_yop3                 IN     NUMBER,
    x_level_credit3                     IN     VARCHAR2,
    x_credit_value_yop4                 IN     NUMBER,
    x_level_credit4                     IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER   ,
    x_fte_calc_type                     IN     VARCHAR2    ,
    x_teach_period_start_dt             IN     DATE        ,
    x_teach_period_end_dt               IN      DATE      ,
    x_other_instit_teach1               IN     VARCHAR2,
    x_other_instit_teach2               IN     VARCHAR2,
    x_prop_not_taught                   IN     NUMBER,
    x_fundability_cd                    IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_funding_source                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 26-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga          27-Mar-2002     Renamed column fte_pc_override as fte_intensity
  ||                                  and added 3 new parameters x_fte_calc_type,x_teach_period_start_dt
  ||                                  and x_teach_period_end_dt as part of #2278825
  ||  smvk            13-Feb-2002     Call to igs_ge_gen_003.get_org_id
  ||                                  w.r.t. SWCR006
  ||  (reverse chronological order - newest change first)
  || smaddali 20-aug-03   Added new field funding_source for hefd208 bug#2717751
  || jchakrab         15-Sep-2004     Added 4 new columns - CREDIT_VALUE_YOP3, LEVEL_CREDIT3,
  ||                                  CREDIT_VALUE_YOP4 and LEVEL_CREDIT4 as part of HEFD350
  ||
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_poous_all
      WHERE    hesa_poous_id                     = x_hesa_poous_id;

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

    SELECT    igs_he_poous_all_s.NEXTVAL
    INTO      x_hesa_poous_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_hesa_poous_id                     => x_hesa_poous_id,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_course_cd                         => x_course_cd,
      x_crv_version_number                => x_crv_version_number,
      x_cal_type                          => x_cal_type,
      x_location_cd                       => x_location_cd,
      x_attendance_mode                   => x_attendance_mode,
      x_attendance_type                   => x_attendance_type,
      x_unit_set_cd                       => x_unit_set_cd,
      x_us_version_number                 => x_us_version_number,
      x_location_of_study                 => x_location_of_study,
      x_mode_of_study                     => x_mode_of_study,
      x_ufi_place                         => x_ufi_place,
      x_franchising_activity              => x_franchising_activity,
      x_type_of_year                      => x_type_of_year,
      x_leng_current_year                 => x_leng_current_year,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_gs_version_number                 => x_gs_version_number,
      x_credit_value_yop1                 => x_credit_value_yop1,
      x_level_credit1                     => x_level_credit1,
      x_credit_value_yop2                 => x_credit_value_yop2,
      x_level_credit2                     => x_level_credit2,
      x_credit_value_yop3                 => x_credit_value_yop3,
      x_level_credit3                     => x_level_credit3,
      x_credit_value_yop4                 => x_credit_value_yop4,
      x_level_credit4                     => x_level_credit4,
      x_fte_intensity                     => x_fte_intensity,
      x_fte_calc_type                     => x_fte_calc_type,
      x_teach_period_start_dt             => x_teach_period_start_dt,
      x_teach_period_end_dt               => x_teach_period_end_dt,
      x_other_instit_teach1               => x_other_instit_teach1,
      x_other_instit_teach2               => x_other_instit_teach2,
      x_prop_not_taught                   => x_prop_not_taught,
      x_fundability_cd                    => x_fundability_cd,
      x_fee_band                          => x_fee_band,
      x_level_applicable_to_funding       => x_level_applicable_to_funding,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_funding_source                    => x_funding_source
    );

    INSERT INTO igs_he_poous_all (
      hesa_poous_id,
      org_id,
      course_cd,
      crv_version_number,
      cal_type,
      location_cd,
      attendance_mode,
      attendance_type,
      unit_set_cd,
      us_version_number,
      location_of_study,
      mode_of_study,
      ufi_place,
      franchising_activity,
      type_of_year,
      leng_current_year,
      grading_schema_cd,
      gs_version_number,
      credit_value_yop1,
      level_credit1,
      credit_value_yop2,
      level_credit2,
      credit_value_yop3,
      level_credit3,
      credit_value_yop4,
      level_credit4,
      fte_intensity,
      fte_calc_type,
      teach_period_start_dt,
      teach_period_end_dt,
      other_instit_teach1,
      other_instit_teach2,
      prop_not_taught,
      fundability_cd,
      fee_band,
      level_applicable_to_funding,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      funding_source
    ) VALUES (
      new_references.hesa_poous_id,
      new_references.org_id,
      new_references.course_cd,
      new_references.crv_version_number,
      new_references.cal_type,
      new_references.location_cd,
      new_references.attendance_mode,
      new_references.attendance_type,
      new_references.unit_set_cd,
      new_references.us_version_number,
      new_references.location_of_study,
      new_references.mode_of_study,
      new_references.ufi_place,
      new_references.franchising_activity,
      new_references.type_of_year,
      new_references.leng_current_year,
      new_references.grading_schema_cd,
      new_references.gs_version_number,
      new_references.credit_value_yop1,
      new_references.level_credit1,
      new_references.credit_value_yop2,
      new_references.level_credit2,
      new_references.credit_value_yop3,
      new_references.level_credit3,
      new_references.credit_value_yop4,
      new_references.level_credit4,
      new_references.fte_intensity,
      new_references.fte_calc_type,
      new_references.teach_period_start_dt,
      new_references.teach_period_end_dt,
      new_references.other_instit_teach1,
      new_references.other_instit_teach2,
      new_references.prop_not_taught,
      new_references.fundability_cd,
      new_references.fee_band,
      new_references.level_applicable_to_funding,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.funding_source
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
    x_hesa_poous_id                     IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_location_of_study                 IN     VARCHAR2,
    x_mode_of_study                     IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_type_of_year                      IN     VARCHAR2,
    x_leng_current_year                 IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_credit_value_yop1                 IN     NUMBER,
    x_level_credit1                     IN     VARCHAR2,
    x_credit_value_yop2                 IN     NUMBER,
    x_level_credit2                     IN     VARCHAR2,
    x_credit_value_yop3                 IN     NUMBER,
    x_level_credit3                     IN     VARCHAR2,
    x_credit_value_yop4                 IN     NUMBER,
    x_level_credit4                     IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER     ,
    x_fte_calc_type                     IN     VARCHAR2    ,
    x_teach_period_start_dt             IN     DATE        ,
    x_teach_period_end_dt               IN      DATE      ,
    x_other_instit_teach1               IN     VARCHAR2,
    x_other_instit_teach2               IN     VARCHAR2,
    x_prop_not_taught                   IN     NUMBER,
    x_fundability_cd                    IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_funding_source                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 26-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga          27-Mar-2002     Renamed column fte_pc_override as fte_intensity
  ||                                  and added 3 new parameters x_fte_calc_type,x_teach_period_start_dt
  ||                                  and x_teach_period_end_dt as part  of #2278825
  ||  smvk            13-Feb-2002     Removed org_id from cursor
  ||                                  declaration and conditional checking
  ||                                  w.r.t. SWCR006
  ||  (reverse chronological order - newest change first)
  || smaddali 20-aug-03   Added new field funding_source for hefd208 bug#2717751
  || jchakrab         15-Sep-2004     Added 4 new columns - CREDIT_VALUE_YOP3, LEVEL_CREDIT3,
  ||                                  CREDIT_VALUE_YOP4 and LEVEL_CREDIT4 as part of HEFD350
  ||
  */
    CURSOR c1 IS
      SELECT
        course_cd,
        crv_version_number,
        cal_type,
        location_cd,
        attendance_mode,
        attendance_type,
        unit_set_cd,
        us_version_number,
        location_of_study,
        mode_of_study,
        ufi_place,
        franchising_activity,
        type_of_year,
        leng_current_year,
        grading_schema_cd,
        gs_version_number,
        credit_value_yop1,
        level_credit1,
        credit_value_yop2,
        level_credit2,
        credit_value_yop3,
        level_credit3,
        credit_value_yop4,
        level_credit4,
        fte_intensity,
        fte_calc_type,
        teach_period_start_dt,
        teach_period_end_dt,
        other_instit_teach1,
        other_instit_teach2,
        prop_not_taught,
        fundability_cd,
        fee_band,
        level_applicable_to_funding,
        funding_source
      FROM  igs_he_poous_all
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
        AND (tlinfo.crv_version_number = x_crv_version_number)
        AND (tlinfo.cal_type = x_cal_type)
        AND (tlinfo.location_cd = x_location_cd)
        AND (tlinfo.attendance_mode = x_attendance_mode)
        AND (tlinfo.attendance_type = x_attendance_type)
        AND (tlinfo.unit_set_cd = x_unit_set_cd)
        AND (tlinfo.us_version_number = x_us_version_number)
        AND ((tlinfo.location_of_study = x_location_of_study) OR ((tlinfo.location_of_study IS NULL) AND (X_location_of_study IS NULL)))
        AND ((tlinfo.mode_of_study = x_mode_of_study) OR ((tlinfo.mode_of_study IS NULL) AND (X_mode_of_study IS NULL)))
        AND ((tlinfo.ufi_place = x_ufi_place) OR ((tlinfo.ufi_place IS NULL) AND (X_ufi_place IS NULL)))
        AND ((tlinfo.franchising_activity = x_franchising_activity) OR ((tlinfo.franchising_activity IS NULL) AND (X_franchising_activity IS NULL)))
        AND ((tlinfo.type_of_year = x_type_of_year) OR ((tlinfo.type_of_year IS NULL) AND (X_type_of_year IS NULL)))
        AND ((tlinfo.leng_current_year = x_leng_current_year) OR ((tlinfo.leng_current_year IS NULL) AND (X_leng_current_year IS NULL)))
        AND ((tlinfo.grading_schema_cd = x_grading_schema_cd) OR ((tlinfo.grading_schema_cd IS NULL) AND (X_grading_schema_cd IS NULL)))
        AND ((tlinfo.gs_version_number = x_gs_version_number) OR ((tlinfo.gs_version_number IS NULL) AND (X_gs_version_number IS NULL)))
        AND ((tlinfo.credit_value_yop1 = x_credit_value_yop1) OR ((tlinfo.credit_value_yop1 IS NULL) AND (X_credit_value_yop1 IS NULL)))
        AND ((tlinfo.level_credit1 = x_level_credit1) OR ((tlinfo.level_credit1 IS NULL) AND (X_level_credit1 IS NULL)))
        AND ((tlinfo.credit_value_yop2 = x_credit_value_yop2) OR ((tlinfo.credit_value_yop2 IS NULL) AND (X_credit_value_yop2 IS NULL)))
        AND ((tlinfo.level_credit2 = x_level_credit2) OR ((tlinfo.level_credit2 IS NULL) AND (X_level_credit2 IS NULL)))
                AND ((tlinfo.credit_value_yop3 = x_credit_value_yop3) OR ((tlinfo.credit_value_yop3 IS NULL) AND (x_credit_value_yop3 IS NULL)))
        AND ((tlinfo.level_credit3 = x_level_credit3) OR ((tlinfo.level_credit3 IS NULL) AND (x_level_credit3 IS NULL)))
        AND ((tlinfo.credit_value_yop4 = x_credit_value_yop4) OR ((tlinfo.credit_value_yop4 IS NULL) AND (x_credit_value_yop4 IS NULL)))
        AND ((tlinfo.level_credit4 = x_level_credit4) OR ((tlinfo.level_credit4 IS NULL) AND (x_level_credit4 IS NULL)))
                AND ((tlinfo.fte_intensity = x_fte_intensity) OR ((tlinfo.fte_intensity IS NULL) AND (X_fte_intensity IS NULL)))
        AND ((tlinfo.fte_calc_type = x_fte_calc_type) OR ((tlinfo.fte_calc_type IS NULL) AND (X_fte_calc_type IS NULL)))
        AND ((tlinfo.teach_period_start_dt = x_teach_period_start_dt) OR ((tlinfo.teach_period_start_dt IS NULL) AND (X_teach_period_start_dt IS NULL)))
        AND ((tlinfo.teach_period_end_dt = x_teach_period_end_dt) OR ((tlinfo.teach_period_end_dt IS NULL) AND (X_teach_period_end_dt IS NULL)))
        AND ((tlinfo.other_instit_teach1 = x_other_instit_teach1) OR ((tlinfo.other_instit_teach1 IS NULL) AND (X_other_instit_teach1 IS NULL)))
        AND ((tlinfo.other_instit_teach2 = x_other_instit_teach2) OR ((tlinfo.other_instit_teach2 IS NULL) AND (X_other_instit_teach2 IS NULL)))
        AND ((tlinfo.prop_not_taught = x_prop_not_taught) OR ((tlinfo.prop_not_taught IS NULL) AND (X_prop_not_taught IS NULL)))
        AND ((tlinfo.fundability_cd = x_fundability_cd) OR ((tlinfo.fundability_cd IS NULL) AND (X_fundability_cd IS NULL)))
        AND ((tlinfo.fee_band = x_fee_band) OR ((tlinfo.fee_band IS NULL) AND (X_fee_band IS NULL)))
        AND ((tlinfo.level_applicable_to_funding = x_level_applicable_to_funding) OR ((tlinfo.level_applicable_to_funding IS NULL) AND (X_level_applicable_to_funding IS NULL)))
        AND ((tlinfo.funding_source = x_funding_source) OR ((tlinfo.funding_source IS NULL) AND (x_funding_source IS NULL)))
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
    x_hesa_poous_id                     IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_location_of_study                 IN     VARCHAR2,
    x_mode_of_study                     IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_type_of_year                      IN     VARCHAR2,
    x_leng_current_year                 IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_credit_value_yop1                 IN     NUMBER,
    x_level_credit1                     IN     VARCHAR2,
    x_credit_value_yop2                 IN     NUMBER,
    x_level_credit2                     IN     VARCHAR2,
    x_credit_value_yop3                 IN     NUMBER,
    x_level_credit3                     IN     VARCHAR2,
    x_credit_value_yop4                 IN     NUMBER,
    x_level_credit4                     IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER   ,
    x_fte_calc_type                     IN     VARCHAR2    ,
    x_teach_period_start_dt             IN     DATE        ,
    x_teach_period_end_dt               IN     DATE      ,
    x_other_instit_teach1               IN     VARCHAR2,
    x_other_instit_teach2               IN     VARCHAR2,
    x_prop_not_taught                   IN     NUMBER,
    x_fundability_cd                    IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_funding_source                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 26-JAN-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga        27-Mar-2002     Renamed column fte_pc_override as fte_intensity
  ||                                  and added 3 new parameters x_fte_calc_type,x_teach_period_start_dt
  ||                                  and x_teach_period_end_dt as part of #2278825
  ||  (reverse chronological order - newest change first)
  || smaddali 20-aug-03   Added new field funding_source for hefd208 bug#2717751
  || jchakrab         15-Sep-2004     Added 4 new columns - CREDIT_VALUE_YOP3, LEVEL_CREDIT3,
  ||                                  CREDIT_VALUE_YOP4 and LEVEL_CREDIT4 as part of HEFD350
  ||
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
      x_hesa_poous_id                     => x_hesa_poous_id,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_course_cd                         => x_course_cd,
      x_crv_version_number                => x_crv_version_number,
      x_cal_type                          => x_cal_type,
      x_location_cd                       => x_location_cd,
      x_attendance_mode                   => x_attendance_mode,
      x_attendance_type                   => x_attendance_type,
      x_unit_set_cd                       => x_unit_set_cd,
      x_us_version_number                 => x_us_version_number,
      x_location_of_study                 => x_location_of_study,
      x_mode_of_study                     => x_mode_of_study,
      x_ufi_place                         => x_ufi_place,
      x_franchising_activity              => x_franchising_activity,
      x_type_of_year                      => x_type_of_year,
      x_leng_current_year                 => x_leng_current_year,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_gs_version_number                 => x_gs_version_number,
      x_credit_value_yop1                 => x_credit_value_yop1,
      x_level_credit1                     => x_level_credit1,
      x_credit_value_yop2                 => x_credit_value_yop2,
      x_level_credit2                     => x_level_credit2,
      x_credit_value_yop3                 => x_credit_value_yop3,
      x_level_credit3                     => x_level_credit3,
      x_credit_value_yop4                 => x_credit_value_yop4,
      x_level_credit4                     => x_level_credit4,
      x_fte_intensity                     => x_fte_intensity,
      x_fte_calc_type                     => x_fte_calc_type,
      x_teach_period_start_dt             => x_teach_period_start_dt,
      x_teach_period_end_dt              => x_teach_period_end_dt,
      x_other_instit_teach1               => x_other_instit_teach1,
      x_other_instit_teach2               => x_other_instit_teach2,
      x_prop_not_taught                   => x_prop_not_taught,
      x_fundability_cd                    => x_fundability_cd,
      x_fee_band                          => x_fee_band,
      x_level_applicable_to_funding       => x_level_applicable_to_funding,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_funding_source                    => x_funding_source
    );

    UPDATE igs_he_poous_all
      SET
        course_cd                         = new_references.course_cd,
        crv_version_number                = new_references.crv_version_number,
        cal_type                          = new_references.cal_type,
        location_cd                       = new_references.location_cd,
        attendance_mode                   = new_references.attendance_mode,
        attendance_type                   = new_references.attendance_type,
        unit_set_cd                       = new_references.unit_set_cd,
        us_version_number                 = new_references.us_version_number,
        location_of_study                 = new_references.location_of_study,
        mode_of_study                     = new_references.mode_of_study,
        ufi_place                         = new_references.ufi_place,
        franchising_activity              = new_references.franchising_activity,
        type_of_year                      = new_references.type_of_year,
        leng_current_year                 = new_references.leng_current_year,
        grading_schema_cd                 = new_references.grading_schema_cd,
        gs_version_number                 = new_references.gs_version_number,
        credit_value_yop1                 = new_references.credit_value_yop1,
        level_credit1                     = new_references.level_credit1,
        credit_value_yop2                 = new_references.credit_value_yop2,
        level_credit2                     = new_references.level_credit2,
        credit_value_yop3                 = new_references.credit_value_yop3,
        level_credit3                     = new_references.level_credit3,
        credit_value_yop4                 = new_references.credit_value_yop4,
        level_credit4                     = new_references.level_credit4,
        fte_intensity                     = new_references.fte_intensity,
        fte_calc_type                     = new_references.fte_calc_type,
        teach_period_start_dt             = new_references.teach_period_start_dt,
        teach_period_end_dt               = new_references.teach_period_end_dt,
        other_instit_teach1               = new_references.other_instit_teach1,
        other_instit_teach2               = new_references.other_instit_teach2,
        prop_not_taught                   = new_references.prop_not_taught,
        fundability_cd                    = new_references.fundability_cd,
        fee_band                          = new_references.fee_band,
        level_applicable_to_funding       = new_references.level_applicable_to_funding,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        funding_source                    = x_funding_source
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_poous_id                     IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_location_of_study                 IN     VARCHAR2,
    x_mode_of_study                     IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_type_of_year                      IN     VARCHAR2,
    x_leng_current_year                 IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_credit_value_yop1                 IN     NUMBER,
    x_level_credit1                     IN     VARCHAR2,
    x_credit_value_yop2                 IN     NUMBER,
    x_level_credit2                     IN     VARCHAR2,
    x_credit_value_yop3                 IN     NUMBER,
    x_level_credit3                     IN     VARCHAR2,
    x_credit_value_yop4                 IN     NUMBER,
    x_level_credit4                     IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER   ,
    x_fte_calc_type                     IN     VARCHAR2    ,
    x_teach_period_start_dt             IN     DATE        ,
    x_teach_period_end_dt               IN      DATE      ,
    x_other_instit_teach1               IN     VARCHAR2,
    x_other_instit_teach2               IN     VARCHAR2,
    x_prop_not_taught                   IN     NUMBER,
    x_fundability_cd                    IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_funding_source                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 26-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || sbaliga         27-Mar-2002     Renamed column fte_pc_override as fte_intensity
  ||                                  and added 3 new parameters x_fte_calc_type,x_teach_period_start_dt
  ||                                  and x_teach_period_end_dt as part of #2278825
  ||  (reverse chronological order - newest change first)
  || smaddali 20-aug-03   Added new field funding_source for hefd208 bug#2717751
  || jchakrab        15-Sep-2004     Added 4 new columns - CREDIT_VALUE_YOP3, LEVEL_CREDIT3,
  ||                                 CREDIT_VALUE_YOP4 and LEVEL_CREDIT4 as part of HEFD350
  ||
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_poous_all
      WHERE    hesa_poous_id                     = x_hesa_poous_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_hesa_poous_id,
        x_org_id,
        x_course_cd,
        x_crv_version_number,
        x_cal_type,
        x_location_cd,
        x_attendance_mode,
        x_attendance_type,
        x_unit_set_cd,
        x_us_version_number,
        x_location_of_study,
        x_mode_of_study,
        x_ufi_place,
        x_franchising_activity,
        x_type_of_year,
        x_leng_current_year,
        x_grading_schema_cd,
        x_gs_version_number,
        x_credit_value_yop1,
        x_level_credit1,
        x_credit_value_yop2,
        x_level_credit2,
        x_credit_value_yop3,
        x_level_credit3,
        x_credit_value_yop4,
        x_level_credit4,
        x_fte_intensity,
        x_fte_calc_type,
        x_teach_period_start_dt,
        x_teach_period_end_dt,
        x_other_instit_teach1,
        x_other_instit_teach2,
        x_prop_not_taught,
        x_fundability_cd,
        x_fee_band,
        x_level_applicable_to_funding,
        x_mode,
        x_funding_source
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_hesa_poous_id,
      x_org_id,
      x_course_cd,
      x_crv_version_number,
      x_cal_type,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_unit_set_cd,
      x_us_version_number,
      x_location_of_study,
      x_mode_of_study,
      x_ufi_place,
      x_franchising_activity,
      x_type_of_year,
      x_leng_current_year,
      x_grading_schema_cd,
      x_gs_version_number,
      x_credit_value_yop1,
      x_level_credit1,
      x_credit_value_yop2,
      x_level_credit2,
      x_credit_value_yop3,
      x_level_credit3,
      x_credit_value_yop4,
      x_level_credit4,
      x_fte_intensity,
      x_fte_calc_type,
      x_teach_period_start_dt,
      x_teach_period_end_dt,
      x_other_instit_teach1,
      x_other_instit_teach2,
      x_prop_not_taught,
      x_fundability_cd,
      x_fee_band,
      x_level_applicable_to_funding,
      x_mode,
      x_funding_source
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 26-JAN-2002
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

    DELETE FROM igs_he_poous_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_poous_all_pkg;

/
