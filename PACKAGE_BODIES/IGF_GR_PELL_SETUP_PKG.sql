--------------------------------------------------------
--  DDL for Package Body IGF_GR_PELL_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_PELL_SETUP_PKG" AS
/* $Header: IGFGI02B.pls 120.1 2006/04/18 04:45:13 akomurav noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_gr_pell_setup_all%ROWTYPE;
  new_references igf_gr_pell_setup_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_pell_seq_id                       IN     NUMBER  ,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_rep_pell_id                       IN     VARCHAR2,
    x_pell_profile                      IN     VARCHAR2,
    x_branch_campus                     IN     VARCHAR2,
    x_attend_campus_id                  IN     VARCHAR2,
    x_use_census_dts                    IN     VARCHAR2,
    x_funding_method                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_academic_cal                      IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER  ,
    x_wk_int_time_prg_def_yr            IN     NUMBER  ,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER  ,
    x_cr_clk_hrs_acad_yr                IN     NUMBER  ,
    x_alt_coa_limit                     IN     NUMBER  ,
    x_efc_max                           IN     NUMBER  ,
    x_pell_alt_exp_max                  IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER  ,
    x_payment_periods_num               IN     NUMBER  ,
    x_enr_before_ts_code                IN     VARCHAR2,
    x_enr_in_mt_code                    IN     VARCHAR2,
    x_enr_after_tc_code                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_response_option_code              IN     VARCHAR2,
    x_term_start_offset_num             IN     NUMBER

  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_GR_PELL_SETUP_ALL
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
    new_references.pell_seq_id                       := x_pell_seq_id;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.rep_pell_id                       := x_rep_pell_id;
    new_references.pell_profile                      := x_pell_profile;
    new_references.branch_campus                     := x_branch_campus;
    new_references.attend_campus_id                  := x_attend_campus_id;
    new_references.use_census_dts                    := x_use_census_dts;
    new_references.funding_method                    := x_funding_method;
    new_references.inst_cross_ref_code               := x_inst_cross_ref_code;
    new_references.low_tution_fee                    := x_low_tution_fee;
    new_references.academic_cal                      := x_academic_cal;
    new_references.payment_method                    := x_payment_method;
    new_references.wk_inst_time_calc_pymt            := x_wk_inst_time_calc_pymt;
    new_references.wk_int_time_prg_def_yr            := x_wk_int_time_prg_def_yr;
    new_references.cr_clk_hrs_prds_sch_yr            := x_cr_clk_hrs_prds_sch_yr;
    new_references.cr_clk_hrs_acad_yr                := x_cr_clk_hrs_acad_yr;
    new_references.alt_coa_limit                     := x_alt_coa_limit;
    new_references.efc_max                           := x_efc_max;
    new_references.pell_alt_exp_max                  := x_pell_alt_exp_max;

    new_references.course_cd                         := x_course_cd;
    new_references.version_number                    := x_version_number;
    new_references.payment_periods_num               := x_payment_periods_num;
    new_references.enr_before_ts_code                := x_enr_before_ts_code;
    new_references.enr_in_mt_code                    := x_enr_in_mt_code;
    new_references.enr_after_tc_code                 := x_enr_after_tc_code;
    new_references.rep_entity_id_txt                 := x_rep_entity_id_txt;
    new_references.response_option_code              := x_response_option_code;
    new_references.term_start_offset_num             := x_term_start_offset_num;

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
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        24-NOV-2003     Bug 3252832. FA 131 - COD Updates
  ||                                  Added two new params in cal to get_uk2_for_validation.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF ( get_uk2_for_validation (
           new_references.ci_cal_type,
           new_references.ci_sequence_number,
           new_references.rep_pell_id,
           new_references.course_cd,
           new_references.version_number,
           new_references.rep_entity_id_txt
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        24-NOV-2003     Bug 3252832. FA 131 - COD Updates
  ||                                  Added code to check for parent in IGS_PS_VER_ALL table.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN



    IF (((old_references.rep_pell_id = new_references.rep_pell_id)) OR
        ((new_references.rep_pell_id IS NULL))) THEN
      NULL;
    END IF;

    IF (((old_references.ci_cal_type = new_references.ci_cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.ci_cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.ci_cal_type,
                new_references.ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

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
    x_pell_seq_id                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_pell_setup_all
      WHERE    pell_seq_id = x_pell_seq_id
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


  FUNCTION get_uk2_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_rep_entity_id_txt                 IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ugummall        24-NOV-2003     Bug 3252832. FA 131 - COD Updates
  ||                                  1. Added two new params x_course_cd and x_version_number
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_pell_setup_all
      WHERE    ci_cal_type = x_ci_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      AND      NVL(rep_pell_id,-1) = NVL(x_rep_pell_id,-1)
      AND      NVL(rep_entity_id_txt,-1) = NVL(x_rep_entity_id_txt,-1)
      AND      NVL(course_cd,':*:') = NVL(x_course_cd,':*:')
      AND      NVL(version_number,-1) = NVL(x_version_number,-1);

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

  END get_uk2_for_validation ;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_pell_setup_all
      WHERE   ((ci_cal_type = x_cal_type) AND
               (ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_GR_PELL_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;

  PROCEDURE get_fk_igs_ps_ver (
    x_course_cd                          IN     VARCHAR2,
    x_version_number                     IN     NUMBER
  ) AS
  /*
  ||  Created By : ugummall
  ||  Created On : 24-NOV-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_pell_setup_all
      WHERE   ((course_cd = x_course_cd) AND
               (version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_GR_PELL_PSV_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_ver;

  PROCEDURE get_fk_igf_gr_report_pell (
   x_rep_pell_cd                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : pssahni
  ||  Created On : 8-Nov-2004
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_pell_setup_all
      WHERE    rep_pell_id = x_rep_pell_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_GR_CANT_DEL_REP_PELL_ST');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_gr_report_pell;

  PROCEDURE get_fk_igf_gr_report_ent (
     x_rep_entity_id_txt                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : pssahni
  ||  Created On : 8-Nov-2004
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_pell_setup_all
      WHERE   rep_entity_id_txt = x_rep_entity_id_txt;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_GR_CANT_DEL_REP_ENT_ST');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_gr_report_ent;

 PROCEDURE check_child ( p_rep_pell_id        IN VARCHAR2,
                         p_ci_cal_type        IN VARCHAR2,
                         p_ci_sequence_number IN NUMBER)
  AS
   /*
  ||  Created By : rasahoo
  ||  Created On : 13-Feb-2004
  ||  Purpose : Checks for the existence of Child Record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  -- Get the number of record present in Pell setup table for
  -- the corresponding Reporting pell id and award year.
  CURSOR cur_get_child(p_rep_pell_id  VARCHAR2,
                          p_ci_cal_type  VARCHAR2,
                          p_ci_sequence_number NUMBER) IS
      SELECT   COUNT(*) num_of_rec
      FROM     igf_gr_pell_setup_all
      WHERE    REP_PELL_ID =  p_rep_pell_id
        AND    CI_CAL_TYPE = p_ci_cal_type
        AND    CI_SEQUENCE_NUMBER =  p_ci_sequence_number;

  rec_get_child cur_get_child%ROWTYPE;

  BEGIN

  -- Get the number of record present in Pell setup table for
  -- the corresponding Reporting pell id and award year.
   rec_get_child := NULL; -- Initializes the cursor.
   OPEN cur_get_child(p_rep_pell_id,p_ci_cal_type,p_ci_sequence_number);
   FETCH cur_get_child INTO rec_get_child;
   -- If record count is greater than one that implies child record exists.
   -- Therfore do not allow to delete record and show error message.
   IF rec_get_child.num_of_rec >1 THEN
     fnd_message.set_name ('IGS', 'IGS_SS_INQ_DELETE_RECORD_INSTR');
      igs_ge_msg_stack.add;
      CLOSE cur_get_child;
      app_exception.raise_exception;
   END IF;
   CLOSE cur_get_child;
  END check_child;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_pell_seq_id                       IN     NUMBER  ,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER  ,
    x_rep_pell_id                       IN     VARCHAR2,
    x_pell_profile                      IN     VARCHAR2,
    x_branch_campus                     IN     VARCHAR2,
    x_attend_campus_id                  IN     VARCHAR2,
    x_use_census_dts                    IN     VARCHAR2,
    x_funding_method                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_academic_cal                      IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER  ,
    x_wk_int_time_prg_def_yr            IN     NUMBER  ,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER  ,
    x_cr_clk_hrs_acad_yr                IN     NUMBER  ,
    x_alt_coa_limit                     IN     NUMBER  ,
    x_efc_max                           IN     NUMBER  ,
    x_pell_alt_exp_max                  IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER  ,
    x_payment_periods_num               IN     NUMBER  ,
    x_enr_before_ts_code                IN     VARCHAR2,
    x_enr_in_mt_code                    IN     VARCHAR2,
    x_enr_after_tc_code                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_response_option_code              IN     VARCHAR2,
    x_term_start_offset_num             IN     NUMBER

  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
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
      x_pell_seq_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_rep_pell_id,
      x_pell_profile,
      x_branch_campus,
      x_attend_campus_id,
      x_use_census_dts,
      x_funding_method,
      x_inst_cross_ref_code,
      x_low_tution_fee,
      x_academic_cal,
      x_payment_method,
      x_wk_inst_time_calc_pymt,
      x_wk_int_time_prg_def_yr,
      x_cr_clk_hrs_prds_sch_yr,
      x_cr_clk_hrs_acad_yr,
      x_alt_coa_limit,
      x_efc_max,
      x_pell_alt_exp_max,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_course_cd,
      x_version_number,
      x_payment_periods_num,
      x_enr_before_ts_code,
      x_enr_in_mt_code,
      x_enr_after_tc_code,
      x_rep_entity_id_txt,
      x_response_option_code,
      x_term_start_offset_num
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.pell_seq_id
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
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
    -- Call all the procedures related to Before delete.
    -- Checks for existence of child record
    -- If child record present Then it raises exception
      check_child(x_rep_pell_id,x_ci_cal_type,x_ci_sequence_number);
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.pell_seq_id
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
    x_pell_seq_id                       IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_pell_profile                      IN     VARCHAR2,
    x_branch_campus                     IN     VARCHAR2,
    x_attend_campus_id                  IN     VARCHAR2,
    x_use_census_dts                    IN     VARCHAR2,
    x_funding_method                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_academic_cal                      IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_alt_coa_limit                     IN     NUMBER,
    x_efc_max                           IN     NUMBER,
    x_pell_alt_exp_max                  IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER  ,
    x_payment_periods_num               IN     NUMBER  ,
    x_enr_before_ts_code                IN     VARCHAR2,
    x_enr_in_mt_code                    IN     VARCHAR2,
    x_enr_after_tc_code                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_response_option_code              IN     VARCHAR2,
    x_term_start_offset_num             IN     NUMBER

  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_gr_pell_setup_all
      WHERE    pell_seq_id                       = x_pell_seq_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_org_id			 igf_gr_pell_setup_all.org_id%TYPE;

  BEGIN

    l_org_id			 := igf_aw_gen.get_org_id;

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

		SELECT igf_gr_pell_setup_s.nextval INTO x_pell_seq_id FROM dual;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_pell_seq_id                       => x_pell_seq_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_rep_pell_id                       => x_rep_pell_id,
      x_pell_profile                      => x_pell_profile,
      x_branch_campus                     => x_branch_campus,
      x_attend_campus_id                  => x_attend_campus_id,
      x_use_census_dts                    => x_use_census_dts,
      x_funding_method                    => x_funding_method,
      x_inst_cross_ref_code               => x_inst_cross_ref_code,
      x_low_tution_fee                    => x_low_tution_fee,
      x_academic_cal                      => x_academic_cal,
      x_payment_method                    => x_payment_method,
      x_wk_inst_time_calc_pymt            => x_wk_inst_time_calc_pymt,
      x_wk_int_time_prg_def_yr            => x_wk_int_time_prg_def_yr,
      x_cr_clk_hrs_prds_sch_yr            => x_cr_clk_hrs_prds_sch_yr,
      x_cr_clk_hrs_acad_yr                => x_cr_clk_hrs_acad_yr,
      x_alt_coa_limit                     => x_alt_coa_limit,
      x_efc_max                           => x_efc_max,
      x_pell_alt_exp_max                  => x_pell_alt_exp_max,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_payment_periods_num               => x_payment_periods_num,
      x_enr_before_ts_code                => x_enr_before_ts_code,
      x_enr_in_mt_code                    => x_enr_in_mt_code,
      x_enr_after_tc_code                 => x_enr_after_tc_code,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_response_option_code              => x_response_option_code,
      x_term_start_offset_num             => x_term_start_offset_num

    );

    INSERT INTO igf_gr_pell_setup_all (
      pell_seq_id,
      ci_cal_type,
      ci_sequence_number,
      rep_pell_id,
      branch_campus,
      attend_campus_id,
      funding_method,
      inst_cross_ref_code,
      academic_cal,
      payment_method,
      wk_inst_time_calc_pymt,
      wk_int_time_prg_def_yr,
      cr_clk_hrs_prds_sch_yr,
      cr_clk_hrs_acad_yr,
      alt_coa_limit,
      efc_max,
      pell_alt_exp_max,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id,
      course_cd,
      version_number,
      payment_periods_num,
      enr_before_ts_code,
      enr_in_mt_code,
      enr_after_tc_code,
      rep_entity_id_txt,
      response_option_code,
      term_start_offset_num

    ) VALUES (
      new_references.pell_seq_id,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      new_references.rep_pell_id,
      new_references.branch_campus,
      new_references.attend_campus_id,
      new_references.funding_method,
      new_references.inst_cross_ref_code,
      new_references.academic_cal,
      new_references.payment_method,
      new_references.wk_inst_time_calc_pymt,
      new_references.wk_int_time_prg_def_yr,
      new_references.cr_clk_hrs_prds_sch_yr,
      new_references.cr_clk_hrs_acad_yr,
      new_references.alt_coa_limit,
      new_references.efc_max,
      new_references.pell_alt_exp_max ,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      l_org_id,
      new_references.course_cd,
      new_references.version_number,
      new_references.payment_periods_num,
      new_references.enr_before_ts_code,
      new_references.enr_in_mt_code,
      new_references.enr_after_tc_code,
      new_references.rep_entity_id_txt,
      new_references.response_option_code,
      new_references.term_start_offset_num

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
    x_pell_seq_id                       IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_pell_profile                      IN     VARCHAR2,
    x_branch_campus                     IN     VARCHAR2,
    x_attend_campus_id                  IN     VARCHAR2,
    x_use_census_dts                    IN     VARCHAR2,
    x_funding_method                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_academic_cal                      IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_alt_coa_limit                     IN     NUMBER,
    x_efc_max                           IN     NUMBER,
    x_pell_alt_exp_max                  IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER  ,
    x_payment_periods_num               IN     NUMBER  ,
    x_enr_before_ts_code                IN     VARCHAR2,
    x_enr_in_mt_code                    IN     VARCHAR2,
    x_enr_after_tc_code                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_response_option_code              IN     VARCHAR2,
    x_term_start_offset_num             IN     NUMBER

  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        ci_cal_type,
        ci_sequence_number,
        rep_pell_id,
        branch_campus,
        attend_campus_id,
        funding_method,
        inst_cross_ref_code,
        academic_cal,
        payment_method,
        wk_inst_time_calc_pymt,
        wk_int_time_prg_def_yr,
        cr_clk_hrs_prds_sch_yr,
        cr_clk_hrs_acad_yr,
        alt_coa_limit,
	      efc_max,
	      pell_alt_exp_max,
        course_cd,
        version_number,
        payment_periods_num,
        enr_before_ts_code,
        enr_in_mt_code,
        enr_after_tc_code,
        rep_entity_id_txt,
        response_option_code,
	term_start_offset_num

      FROM  igf_gr_pell_setup_all
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
        (tlinfo.ci_cal_type = x_ci_cal_type)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND ((tlinfo.rep_pell_id = x_rep_pell_id) OR ((tlinfo.rep_pell_id IS NULL) AND (X_rep_pell_id IS NULL)))
--        AND (tlinfo.branch_campus = x_branch_campus) OR ((tlinfo.branch_campus IS NULL) AND (x_branch_campus IS NULL))
  --      AND (tlinfo.attend_campus_id = x_attend_campus_id) OR ((tlinfo.attend_campus_id IS NULL) AND (x_attend_campus_id IS NULL))
        AND ((tlinfo.funding_method = x_funding_method)  OR ((tlinfo.funding_method IS NULL) AND (X_funding_method IS NULL)))
        AND ((tlinfo.inst_cross_ref_code = x_inst_cross_ref_code) OR ((tlinfo.inst_cross_ref_code IS NULL) AND (X_inst_cross_ref_code IS NULL)))
        AND (tlinfo.academic_cal = x_academic_cal)
        AND (tlinfo.payment_method = x_payment_method)
        AND ((tlinfo.wk_inst_time_calc_pymt = x_wk_inst_time_calc_pymt) OR ((tlinfo.wk_inst_time_calc_pymt IS NULL) AND (X_wk_inst_time_calc_pymt IS NULL)))
        AND ((tlinfo.wk_int_time_prg_def_yr = x_wk_int_time_prg_def_yr) OR ((tlinfo.wk_int_time_prg_def_yr IS NULL) AND (X_wk_int_time_prg_def_yr IS NULL)))
        AND ((tlinfo.cr_clk_hrs_prds_sch_yr = x_cr_clk_hrs_prds_sch_yr) OR ((tlinfo.cr_clk_hrs_prds_sch_yr IS NULL) AND (X_cr_clk_hrs_prds_sch_yr IS NULL)))
        AND ((tlinfo.cr_clk_hrs_acad_yr = x_cr_clk_hrs_acad_yr) OR ((tlinfo.cr_clk_hrs_acad_yr IS NULL) AND (X_cr_clk_hrs_acad_yr IS NULL)))
        AND ((tlinfo.alt_coa_limit = x_alt_coa_limit) OR ((tlinfo.alt_coa_limit IS NULL) AND (X_alt_coa_limit IS NULL)))
        AND ((tlinfo.efc_max = x_efc_max) OR ((tlinfo.efc_max IS NULL) AND (X_efc_max IS NULL)))
        AND ((tlinfo.pell_alt_exp_max = x_pell_alt_exp_max) OR ((tlinfo.pell_alt_exp_max IS NULL) AND (X_pell_alt_exp_max IS NULL)))
        AND ((tlinfo.course_cd = x_course_cd) OR ((tlinfo.course_cd IS NULL) AND (x_course_cd IS NULL)))
        AND ((tlinfo.version_number = x_version_number) OR ((tlinfo.version_number IS NULL) AND (x_version_number IS NULL)))
        AND ((tlinfo.payment_periods_num = x_payment_periods_num) OR ((tlinfo.payment_periods_num IS NULL) AND (x_payment_periods_num IS NULL)))
        AND ((tlinfo.enr_before_ts_code = x_enr_before_ts_code) OR ((tlinfo.enr_before_ts_code IS NULL) AND (x_enr_before_ts_code IS NULL)))
        AND ((tlinfo.enr_in_mt_code = x_enr_in_mt_code) OR ((tlinfo.enr_in_mt_code IS NULL) AND (x_enr_in_mt_code IS NULL)))
        AND ((tlinfo.enr_after_tc_code = x_enr_after_tc_code) OR ((tlinfo.enr_after_tc_code IS NULL) AND (x_enr_after_tc_code IS NULL)))
        AND ((tlinfo.rep_entity_id_txt = x_rep_entity_id_txt) OR ((tlinfo.rep_entity_id_txt IS NULL) AND (x_rep_entity_id_txt IS NULL)))
        AND ((tlinfo.response_option_code = x_response_option_code) OR ((tlinfo.response_option_code IS NULL) AND (x_response_option_code IS NULL)))
	AND ((tlinfo.term_start_offset_num = x_term_start_offset_num) OR ((tlinfo.term_start_offset_num IS NULL) AND (x_term_start_offset_num IS NULL)))

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
    x_pell_seq_id                       IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_pell_profile                      IN     VARCHAR2,
    x_branch_campus                     IN     VARCHAR2,
    x_attend_campus_id                  IN     VARCHAR2,
    x_use_census_dts                    IN     VARCHAR2,
    x_funding_method                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_academic_cal                      IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_alt_coa_limit                     IN     NUMBER,
    x_efc_max                           IN     NUMBER,
    x_pell_alt_exp_max                  IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER  ,
    x_payment_periods_num               IN     NUMBER  ,
    x_enr_before_ts_code                IN     VARCHAR2,
    x_enr_in_mt_code                    IN     VARCHAR2,
    x_enr_after_tc_code                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_response_option_code              IN     VARCHAR2,
    x_term_start_offset_num             IN     NUMBER

  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
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
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_pell_seq_id                       => x_pell_seq_id,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_rep_pell_id                       => x_rep_pell_id,
      x_pell_profile                      => x_pell_profile,
      x_branch_campus                     => x_branch_campus,
      x_attend_campus_id                  => x_attend_campus_id,
      x_use_census_dts                    => x_use_census_dts,
      x_funding_method                    => x_funding_method,
      x_inst_cross_ref_code               => x_inst_cross_ref_code,
      x_low_tution_fee                    => x_low_tution_fee,
      x_academic_cal                      => x_academic_cal,
      x_payment_method                    => x_payment_method,
      x_wk_inst_time_calc_pymt            => x_wk_inst_time_calc_pymt,
      x_wk_int_time_prg_def_yr            => x_wk_int_time_prg_def_yr,
      x_cr_clk_hrs_prds_sch_yr            => x_cr_clk_hrs_prds_sch_yr,
      x_cr_clk_hrs_acad_yr                => x_cr_clk_hrs_acad_yr,
      x_alt_coa_limit                     => x_alt_coa_limit,
      x_efc_max                           => x_efc_max ,
      x_pell_alt_exp_max                  => x_pell_alt_exp_max,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_payment_periods_num               => x_payment_periods_num,
      x_enr_before_ts_code                => x_enr_before_ts_code,
      x_enr_in_mt_code                    => x_enr_in_mt_code,
      x_enr_after_tc_code                 => x_enr_after_tc_code,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_response_option_code              => x_response_option_code,
      x_term_start_offset_num             => x_term_start_offset_num

    );

    UPDATE igf_gr_pell_setup_all
      SET
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        rep_pell_id                       = new_references.rep_pell_id,
        branch_campus                     = new_references.branch_campus,
        attend_campus_id                  = new_references.attend_campus_id,
        funding_method                    = new_references.funding_method,
        inst_cross_ref_code               = new_references.inst_cross_ref_code,
        academic_cal                      = new_references.academic_cal,
        payment_method                    = new_references.payment_method,
        wk_inst_time_calc_pymt            = new_references.wk_inst_time_calc_pymt,
        wk_int_time_prg_def_yr            = new_references.wk_int_time_prg_def_yr,
        cr_clk_hrs_prds_sch_yr            = new_references.cr_clk_hrs_prds_sch_yr,
        cr_clk_hrs_acad_yr                = new_references.cr_clk_hrs_acad_yr,
        alt_coa_limit                     = new_references.alt_coa_limit,
        efc_max                           = new_references.efc_max ,
        pell_alt_exp_max                  = new_references.pell_alt_exp_max ,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        course_cd                         = x_course_cd,
        version_number                    = x_version_number,
        payment_periods_num               = x_payment_periods_num,
        enr_before_ts_code                = x_enr_before_ts_code,
        enr_in_mt_code                    = x_enr_in_mt_code,
        enr_after_tc_code                 = x_enr_after_tc_code,
        rep_entity_id_txt                 = new_references.rep_entity_id_txt,
        response_option_code              = new_references.response_option_code,
	term_start_offset_num             = new_references.term_start_offset_num

      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pell_seq_id                       IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_pell_profile                      IN     VARCHAR2,
    x_branch_campus                     IN     VARCHAR2,
    x_attend_campus_id                  IN     VARCHAR2,
    x_use_census_dts                    IN     VARCHAR2,
    x_funding_method                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_academic_cal                      IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_alt_coa_limit                     IN     NUMBER,
    x_efc_max                           IN     NUMBER,
    x_pell_alt_exp_max                  IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER  ,
    x_payment_periods_num               IN     NUMBER  ,
    x_enr_before_ts_code                IN     VARCHAR2,
    x_enr_in_mt_code                    IN     VARCHAR2,
    x_enr_after_tc_code                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_response_option_code              IN     VARCHAR2,
    x_term_start_offset_num             IN     NUMBER

  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_gr_pell_setup_all
      WHERE    pell_seq_id                       = x_pell_seq_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_pell_seq_id,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_rep_pell_id,
        x_pell_profile,
        x_branch_campus,
        x_attend_campus_id,
        x_use_census_dts,
        x_funding_method,
        x_inst_cross_ref_code,
        x_low_tution_fee,
        x_academic_cal,
        x_payment_method,
        x_wk_inst_time_calc_pymt,
        x_wk_int_time_prg_def_yr,
        x_cr_clk_hrs_prds_sch_yr,
        x_cr_clk_hrs_acad_yr,
        x_alt_coa_limit,
	x_efc_max,
        x_pell_alt_exp_max,
        x_mode,
        x_course_cd,
        x_version_number,
        x_payment_periods_num,
        x_enr_before_ts_code,
        x_enr_in_mt_code,
        x_enr_after_tc_code,
        x_rep_entity_id_txt,
        x_response_option_code,
        x_term_start_offset_num
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_pell_seq_id,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_rep_pell_id,
      x_pell_profile,
      x_branch_campus,
      x_attend_campus_id,
      x_use_census_dts,
      x_funding_method,
      x_inst_cross_ref_code,
      x_low_tution_fee,
      x_academic_cal,
      x_payment_method,
      x_wk_inst_time_calc_pymt,
      x_wk_int_time_prg_def_yr,
      x_cr_clk_hrs_prds_sch_yr,
      x_cr_clk_hrs_acad_yr,
      x_alt_coa_limit,
      x_efc_max,
      x_pell_alt_exp_max,
      x_mode,
      x_course_cd,
      x_version_number,
      x_payment_periods_num,
      x_enr_before_ts_code,
      x_enr_in_mt_code,
      x_enr_after_tc_code,
      x_rep_entity_id_txt,
      x_response_option_code,
      x_term_start_offset_num

    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 04-JAN-2001
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

    DELETE FROM igf_gr_pell_setup_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_gr_pell_setup_pkg;

/
