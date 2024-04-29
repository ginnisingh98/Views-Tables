--------------------------------------------------------
--  DDL for Package Body IGF_GR_YTD_ORIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_YTD_ORIG_PKG" AS
/* $Header: IGFGI13B.pls 120.1 2006/04/06 06:08:20 veramach noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_gr_ytd_orig_all%ROWTYPE;
  new_references igf_gr_ytd_orig_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_ytdor_id                          IN     NUMBER      ,
    x_origination_id                    IN     VARCHAR2    ,
    x_original_ssn                      IN     VARCHAR2    ,
    x_original_name_cd                  IN     VARCHAR2    ,
    x_attend_pell_id                    IN     VARCHAR2    ,
    x_ed_use                            IN     VARCHAR2    ,
    x_inst_cross_ref_code               IN     VARCHAR2    ,
    x_action_code                       IN     VARCHAR2    ,
    x_accpt_awd_amt                     IN     NUMBER      ,
    x_accpt_disb_dt1                    IN     DATE        ,
    x_accpt_disb_dt2                    IN     DATE        ,
    x_accpt_disb_dt3                    IN     DATE        ,
    x_accpt_disb_dt4                    IN     DATE        ,
    x_accpt_disb_dt5                    IN     DATE        ,
    x_accpt_disb_dt6                    IN     DATE        ,
    x_accpt_disb_dt7                    IN     DATE        ,
    x_accpt_disb_dt8                    IN     DATE        ,
    x_accpt_disb_dt9                    IN     DATE        ,
    x_accpt_disb_dt10                   IN     DATE        ,
    x_accpt_disb_dt11                   IN     DATE        ,
    x_accpt_disb_dt12                   IN     DATE        ,
    x_accpt_disb_dt13                   IN     DATE        ,
    x_accpt_disb_dt14                   IN     DATE        ,
    x_accpt_disb_dt15                   IN     DATE        ,
    x_accpt_enrl_dt                     IN     DATE        ,
    x_accpt_low_tut_flg                 IN     VARCHAR2    ,
    x_accpt_ver_stat_flg                IN     VARCHAR2    ,
    x_accpt_incr_pell_cd                IN     VARCHAR2    ,
    x_accpt_tran_num                    IN     VARCHAR2    ,
    x_accpt_efc                         IN     NUMBER      ,
    x_accpt_sec_efc                     IN     VARCHAR2    ,
    x_accpt_acad_cal                    IN     VARCHAR2    ,
    x_accpt_pymt_method                 IN     VARCHAR2    ,
    x_accpt_coa                         IN     NUMBER      ,
    x_accpt_enrl_stat                   IN     VARCHAR2    ,
    x_accpt_wks_inst_pymt               IN     VARCHAR2    ,
    x_wk_inst_time_calc_pymt            IN     NUMBER      ,
    x_accpt_wks_acad                    IN     VARCHAR2    ,
    x_accpt_cr_acad_yr                  IN     VARCHAR2    ,
    x_inst_seq_num                      IN     VARCHAR2    ,
    x_sch_full_time_pell                IN     NUMBER      ,
    x_stud_name                         IN     VARCHAR2    ,
    x_ssn                               IN     VARCHAR2    ,
    x_stud_dob                          IN     DATE        ,
    x_cps_ver_sel_cd                    IN     VARCHAR2    ,
    x_ytd_disb_amt                      IN     NUMBER      ,
    x_batch_id                          IN     VARCHAR2    ,
    x_process_date                      IN     DATE        ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
 	  x_ci_cal_type                       IN     VARCHAR2    ,
 	  x_ci_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 21-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_gr_ytd_orig_all
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
    new_references.ytdor_id                          := x_ytdor_id;
    new_references.origination_id                    := x_origination_id;
    new_references.original_ssn                      := x_original_ssn;
    new_references.original_name_cd                  := x_original_name_cd;
    new_references.attend_pell_id                    := x_attend_pell_id;
    new_references.ed_use                            := x_ed_use;
    new_references.inst_cross_ref_code               := x_inst_cross_ref_code;
    new_references.action_code                       := x_action_code;
    new_references.accpt_awd_amt                     := x_accpt_awd_amt;
    new_references.accpt_disb_dt1                    := x_accpt_disb_dt1;
    new_references.accpt_disb_dt2                    := x_accpt_disb_dt2;
    new_references.accpt_disb_dt3                    := x_accpt_disb_dt3;
    new_references.accpt_disb_dt4                    := x_accpt_disb_dt4;
    new_references.accpt_disb_dt5                    := x_accpt_disb_dt5;
    new_references.accpt_disb_dt6                    := x_accpt_disb_dt6;
    new_references.accpt_disb_dt7                    := x_accpt_disb_dt7;
    new_references.accpt_disb_dt8                    := x_accpt_disb_dt8;
    new_references.accpt_disb_dt9                    := x_accpt_disb_dt9;
    new_references.accpt_disb_dt10                   := x_accpt_disb_dt10;
    new_references.accpt_disb_dt11                   := x_accpt_disb_dt11;
    new_references.accpt_disb_dt12                   := x_accpt_disb_dt12;
    new_references.accpt_disb_dt13                   := x_accpt_disb_dt13;
    new_references.accpt_disb_dt14                   := x_accpt_disb_dt14;
    new_references.accpt_disb_dt15                   := x_accpt_disb_dt15;
    new_references.accpt_enrl_dt                     := x_accpt_enrl_dt;
    new_references.accpt_low_tut_flg                 := x_accpt_low_tut_flg;
    new_references.accpt_ver_stat_flg                := x_accpt_ver_stat_flg;
    new_references.accpt_incr_pell_cd                := x_accpt_incr_pell_cd;
    new_references.accpt_tran_num                    := x_accpt_tran_num;
    new_references.accpt_efc                         := x_accpt_efc;
    new_references.accpt_sec_efc                     := x_accpt_sec_efc;
    new_references.accpt_acad_cal                    := x_accpt_acad_cal;
    new_references.accpt_pymt_method                 := x_accpt_pymt_method;
    new_references.accpt_coa                         := x_accpt_coa;
    new_references.accpt_enrl_stat                   := x_accpt_enrl_stat;
    new_references.accpt_wks_inst_pymt               := x_accpt_wks_inst_pymt;
    new_references.wk_inst_time_calc_pymt            := x_wk_inst_time_calc_pymt;
    new_references.accpt_wks_acad                    := x_accpt_wks_acad;
    new_references.accpt_cr_acad_yr                  := x_accpt_cr_acad_yr;
    new_references.inst_seq_num                      := x_inst_seq_num;
    new_references.sch_full_time_pell                := x_sch_full_time_pell;
    new_references.stud_name                         := x_stud_name;
    new_references.ssn                               := x_ssn;
    new_references.stud_dob                          := x_stud_dob;
    new_references.cps_ver_sel_cd                    := x_cps_ver_sel_cd;
    new_references.ytd_disb_amt                      := x_ytd_disb_amt;
    new_references.batch_id                          := x_batch_id;
    new_references.process_date                      := x_process_date;
	  new_references.ci_cal_type                       := x_ci_cal_type;
 	  new_references.ci_sequence_number                := x_ci_sequence_number;

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


  FUNCTION get_pk_for_validation (
    x_ytdor_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 21-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_ytd_orig_all
      WHERE    ytdor_id = x_ytdor_id
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_ytdor_id                          IN     NUMBER      ,
    x_origination_id                    IN     VARCHAR2    ,
    x_original_ssn                      IN     VARCHAR2    ,
    x_original_name_cd                  IN     VARCHAR2    ,
    x_attend_pell_id                    IN     VARCHAR2    ,
    x_ed_use                            IN     VARCHAR2    ,
    x_inst_cross_ref_code               IN     VARCHAR2    ,
    x_action_code                       IN     VARCHAR2    ,
    x_accpt_awd_amt                     IN     NUMBER      ,
    x_accpt_disb_dt1                    IN     DATE        ,
    x_accpt_disb_dt2                    IN     DATE        ,
    x_accpt_disb_dt3                    IN     DATE        ,
    x_accpt_disb_dt4                    IN     DATE        ,
    x_accpt_disb_dt5                    IN     DATE        ,
    x_accpt_disb_dt6                    IN     DATE        ,
    x_accpt_disb_dt7                    IN     DATE        ,
    x_accpt_disb_dt8                    IN     DATE        ,
    x_accpt_disb_dt9                    IN     DATE        ,
    x_accpt_disb_dt10                   IN     DATE        ,
    x_accpt_disb_dt11                   IN     DATE        ,
    x_accpt_disb_dt12                   IN     DATE        ,
    x_accpt_disb_dt13                   IN     DATE        ,
    x_accpt_disb_dt14                   IN     DATE        ,
    x_accpt_disb_dt15                   IN     DATE        ,
    x_accpt_enrl_dt                     IN     DATE        ,
    x_accpt_low_tut_flg                 IN     VARCHAR2    ,
    x_accpt_ver_stat_flg                IN     VARCHAR2    ,
    x_accpt_incr_pell_cd                IN     VARCHAR2    ,
    x_accpt_tran_num                    IN     VARCHAR2    ,
    x_accpt_efc                         IN     NUMBER      ,
    x_accpt_sec_efc                     IN     VARCHAR2    ,
    x_accpt_acad_cal                    IN     VARCHAR2    ,
    x_accpt_pymt_method                 IN     VARCHAR2    ,
    x_accpt_coa                         IN     NUMBER      ,
    x_accpt_enrl_stat                   IN     VARCHAR2    ,
    x_accpt_wks_inst_pymt               IN     VARCHAR2    ,
    x_wk_inst_time_calc_pymt            IN     NUMBER      ,
    x_accpt_wks_acad                    IN     VARCHAR2    ,
    x_accpt_cr_acad_yr                  IN     VARCHAR2    ,
    x_inst_seq_num                      IN     VARCHAR2    ,
    x_sch_full_time_pell                IN     NUMBER      ,
    x_stud_name                         IN     VARCHAR2    ,
    x_ssn                               IN     VARCHAR2    ,
    x_stud_dob                          IN     DATE        ,
    x_cps_ver_sel_cd                    IN     VARCHAR2    ,
    x_ytd_disb_amt                      IN     NUMBER      ,
    x_batch_id                          IN     VARCHAR2    ,
    x_process_date                      IN     DATE        ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
 	  x_ci_cal_type                       IN     VARCHAR2    ,
 	  x_ci_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 21-DEC-2000
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
      x_ytdor_id,
      x_origination_id,
      x_original_ssn,
      x_original_name_cd,
      x_attend_pell_id,
      x_ed_use,
      x_inst_cross_ref_code,
      x_action_code,
      x_accpt_awd_amt,
      x_accpt_disb_dt1,
      x_accpt_disb_dt2,
      x_accpt_disb_dt3,
      x_accpt_disb_dt4,
      x_accpt_disb_dt5,
      x_accpt_disb_dt6,
      x_accpt_disb_dt7,
      x_accpt_disb_dt8,
      x_accpt_disb_dt9,
      x_accpt_disb_dt10,
      x_accpt_disb_dt11,
      x_accpt_disb_dt12,
      x_accpt_disb_dt13,
      x_accpt_disb_dt14,
      x_accpt_disb_dt15,
      x_accpt_enrl_dt,
      x_accpt_low_tut_flg,
      x_accpt_ver_stat_flg,
      x_accpt_incr_pell_cd,
      x_accpt_tran_num,
      x_accpt_efc,
      x_accpt_sec_efc,
      x_accpt_acad_cal,
      x_accpt_pymt_method,
      x_accpt_coa,
      x_accpt_enrl_stat,
      x_accpt_wks_inst_pymt,
      x_wk_inst_time_calc_pymt,
      x_accpt_wks_acad,
      x_accpt_cr_acad_yr,
      x_inst_seq_num,
      x_sch_full_time_pell,
      x_stud_name,
      x_ssn,
      x_stud_dob,
      x_cps_ver_sel_cd,
      x_ytd_disb_amt,
      x_batch_id,
      x_process_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
 	    x_ci_cal_type,
 	    x_ci_sequence_number
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ytdor_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.ytdor_id
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
    x_ytdor_id                          IN OUT NOCOPY NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_original_ssn                      IN     VARCHAR2,
    x_original_name_cd                  IN     VARCHAR2,
    x_attend_pell_id                    IN     VARCHAR2,
    x_ed_use                            IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_accpt_awd_amt                     IN     NUMBER,
    x_accpt_disb_dt1                    IN     DATE,
    x_accpt_disb_dt2                    IN     DATE,
    x_accpt_disb_dt3                    IN     DATE,
    x_accpt_disb_dt4                    IN     DATE,
    x_accpt_disb_dt5                    IN     DATE,
    x_accpt_disb_dt6                    IN     DATE,
    x_accpt_disb_dt7                    IN     DATE,
    x_accpt_disb_dt8                    IN     DATE,
    x_accpt_disb_dt9                    IN     DATE,
    x_accpt_disb_dt10                   IN     DATE,
    x_accpt_disb_dt11                   IN     DATE,
    x_accpt_disb_dt12                   IN     DATE,
    x_accpt_disb_dt13                   IN     DATE,
    x_accpt_disb_dt14                   IN     DATE,
    x_accpt_disb_dt15                   IN     DATE,
    x_accpt_enrl_dt                     IN     DATE,
    x_accpt_low_tut_flg                 IN     VARCHAR2,
    x_accpt_ver_stat_flg                IN     VARCHAR2,
    x_accpt_incr_pell_cd                IN     VARCHAR2,
    x_accpt_tran_num                    IN     VARCHAR2,
    x_accpt_efc                         IN     NUMBER,
    x_accpt_sec_efc                     IN     VARCHAR2,
    x_accpt_acad_cal                    IN     VARCHAR2,
    x_accpt_pymt_method                 IN     VARCHAR2,
    x_accpt_coa                         IN     NUMBER,
    x_accpt_enrl_stat                   IN     VARCHAR2,
    x_accpt_wks_inst_pymt               IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_accpt_wks_acad                    IN     VARCHAR2,
    x_accpt_cr_acad_yr                  IN     VARCHAR2,
    x_inst_seq_num                      IN     VARCHAR2,
    x_sch_full_time_pell                IN     NUMBER,
    x_stud_name                         IN     VARCHAR2,
    x_ssn                               IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_cps_ver_sel_cd                    IN     VARCHAR2,
    x_ytd_disb_amt                      IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_process_date                      IN     DATE,
    x_mode                              IN     VARCHAR2,
 	  x_ci_cal_type                       IN     VARCHAR2,
 	  x_ci_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 21-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_gr_ytd_orig_all
      WHERE    ytdor_id                          = x_ytdor_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_gr_ytd_orig_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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

	  SELECT igf_gr_ytd_orig_s.nextval INTO x_ytdor_id FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ytdor_id                          => x_ytdor_id,
      x_origination_id                    => x_origination_id,
      x_original_ssn                      => x_original_ssn,
      x_original_name_cd                  => x_original_name_cd,
      x_attend_pell_id                    => x_attend_pell_id,
      x_ed_use                            => x_ed_use,
      x_inst_cross_ref_code               => x_inst_cross_ref_code,
      x_action_code                       => x_action_code,
      x_accpt_awd_amt                     => x_accpt_awd_amt,
      x_accpt_disb_dt1                    => x_accpt_disb_dt1,
      x_accpt_disb_dt2                    => x_accpt_disb_dt2,
      x_accpt_disb_dt3                    => x_accpt_disb_dt3,
      x_accpt_disb_dt4                    => x_accpt_disb_dt4,
      x_accpt_disb_dt5                    => x_accpt_disb_dt5,
      x_accpt_disb_dt6                    => x_accpt_disb_dt6,
      x_accpt_disb_dt7                    => x_accpt_disb_dt7,
      x_accpt_disb_dt8                    => x_accpt_disb_dt8,
      x_accpt_disb_dt9                    => x_accpt_disb_dt9,
      x_accpt_disb_dt10                   => x_accpt_disb_dt10,
      x_accpt_disb_dt11                   => x_accpt_disb_dt11,
      x_accpt_disb_dt12                   => x_accpt_disb_dt12,
      x_accpt_disb_dt13                   => x_accpt_disb_dt13,
      x_accpt_disb_dt14                   => x_accpt_disb_dt14,
      x_accpt_disb_dt15                   => x_accpt_disb_dt15,
      x_accpt_enrl_dt                     => x_accpt_enrl_dt,
      x_accpt_low_tut_flg                 => x_accpt_low_tut_flg,
      x_accpt_ver_stat_flg                => x_accpt_ver_stat_flg,
      x_accpt_incr_pell_cd                => x_accpt_incr_pell_cd,
      x_accpt_tran_num                    => x_accpt_tran_num,
      x_accpt_efc                         => x_accpt_efc,
      x_accpt_sec_efc                     => x_accpt_sec_efc,
      x_accpt_acad_cal                    => x_accpt_acad_cal,
      x_accpt_pymt_method                 => x_accpt_pymt_method,
      x_accpt_coa                         => x_accpt_coa,
      x_accpt_enrl_stat                   => x_accpt_enrl_stat,
      x_accpt_wks_inst_pymt               => x_accpt_wks_inst_pymt,
      x_wk_inst_time_calc_pymt            => x_wk_inst_time_calc_pymt,
      x_accpt_wks_acad                    => x_accpt_wks_acad,
      x_accpt_cr_acad_yr                  => x_accpt_cr_acad_yr,
      x_inst_seq_num                      => x_inst_seq_num,
      x_sch_full_time_pell                => x_sch_full_time_pell,
      x_stud_name                         => x_stud_name,
      x_ssn                               => x_ssn,
      x_stud_dob                          => x_stud_dob,
      x_cps_ver_sel_cd                    => x_cps_ver_sel_cd,
      x_ytd_disb_amt                      => x_ytd_disb_amt,
      x_batch_id                          => x_batch_id,
      x_process_date                      => x_process_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
 	    x_ci_cal_type                       => x_ci_cal_type,
 	    x_ci_sequence_number                => x_ci_sequence_number
    );

    INSERT INTO igf_gr_ytd_orig_all (
      ytdor_id,
      origination_id,
      original_ssn,
      original_name_cd,
      attend_pell_id,
      ed_use,
      inst_cross_ref_code,
      action_code,
      accpt_awd_amt,
      accpt_disb_dt1,
      accpt_disb_dt2,
      accpt_disb_dt3,
      accpt_disb_dt4,
      accpt_disb_dt5,
      accpt_disb_dt6,
      accpt_disb_dt7,
      accpt_disb_dt8,
      accpt_disb_dt9,
      accpt_disb_dt10,
      accpt_disb_dt11,
      accpt_disb_dt12,
      accpt_disb_dt13,
      accpt_disb_dt14,
      accpt_disb_dt15,
      accpt_enrl_dt,
      accpt_low_tut_flg,
      accpt_ver_stat_flg,
      accpt_incr_pell_cd,
      accpt_tran_num,
      accpt_efc,
      accpt_sec_efc,
      accpt_acad_cal,
      accpt_pymt_method,
      accpt_coa,
      accpt_enrl_stat,
      accpt_wks_inst_pymt,
      wk_inst_time_calc_pymt,
      accpt_wks_acad,
      accpt_cr_acad_yr,
      inst_seq_num,
      sch_full_time_pell,
      stud_name,
      ssn,
      stud_dob,
      cps_ver_sel_cd,
      ytd_disb_amt,
      batch_id,
      process_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id,
 	    ci_cal_type,
 	    ci_sequence_number
    ) VALUES (
      new_references.ytdor_id,
      new_references.origination_id,
      new_references.original_ssn,
      new_references.original_name_cd,
      new_references.attend_pell_id,
      new_references.ed_use,
      new_references.inst_cross_ref_code,
      new_references.action_code,
      new_references.accpt_awd_amt,
      new_references.accpt_disb_dt1,
      new_references.accpt_disb_dt2,
      new_references.accpt_disb_dt3,
      new_references.accpt_disb_dt4,
      new_references.accpt_disb_dt5,
      new_references.accpt_disb_dt6,
      new_references.accpt_disb_dt7,
      new_references.accpt_disb_dt8,
      new_references.accpt_disb_dt9,
      new_references.accpt_disb_dt10,
      new_references.accpt_disb_dt11,
      new_references.accpt_disb_dt12,
      new_references.accpt_disb_dt13,
      new_references.accpt_disb_dt14,
      new_references.accpt_disb_dt15,
      new_references.accpt_enrl_dt,
      new_references.accpt_low_tut_flg,
      new_references.accpt_ver_stat_flg,
      new_references.accpt_incr_pell_cd,
      new_references.accpt_tran_num,
      new_references.accpt_efc,
      new_references.accpt_sec_efc,
      new_references.accpt_acad_cal,
      new_references.accpt_pymt_method,
      new_references.accpt_coa,
      new_references.accpt_enrl_stat,
      new_references.accpt_wks_inst_pymt,
      new_references.wk_inst_time_calc_pymt,
      new_references.accpt_wks_acad,
      new_references.accpt_cr_acad_yr,
      new_references.inst_seq_num,
      new_references.sch_full_time_pell,
      new_references.stud_name,
      new_references.ssn,
      new_references.stud_dob,
      new_references.cps_ver_sel_cd,
      new_references.ytd_disb_amt,
      new_references.batch_id,
      new_references.process_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      l_org_id,
 	    new_references.ci_cal_type,
 	    new_references.ci_sequence_number
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
    x_ytdor_id                          IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_original_ssn                      IN     VARCHAR2,
    x_original_name_cd                  IN     VARCHAR2,
    x_attend_pell_id                    IN     VARCHAR2,
    x_ed_use                            IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_accpt_awd_amt                     IN     NUMBER,
    x_accpt_disb_dt1                    IN     DATE,
    x_accpt_disb_dt2                    IN     DATE,
    x_accpt_disb_dt3                    IN     DATE,
    x_accpt_disb_dt4                    IN     DATE,
    x_accpt_disb_dt5                    IN     DATE,
    x_accpt_disb_dt6                    IN     DATE,
    x_accpt_disb_dt7                    IN     DATE,
    x_accpt_disb_dt8                    IN     DATE,
    x_accpt_disb_dt9                    IN     DATE,
    x_accpt_disb_dt10                   IN     DATE,
    x_accpt_disb_dt11                   IN     DATE,
    x_accpt_disb_dt12                   IN     DATE,
    x_accpt_disb_dt13                   IN     DATE,
    x_accpt_disb_dt14                   IN     DATE,
    x_accpt_disb_dt15                   IN     DATE,
    x_accpt_enrl_dt                     IN     DATE,
    x_accpt_low_tut_flg                 IN     VARCHAR2,
    x_accpt_ver_stat_flg                IN     VARCHAR2,
    x_accpt_incr_pell_cd                IN     VARCHAR2,
    x_accpt_tran_num                    IN     VARCHAR2,
    x_accpt_efc                         IN     NUMBER,
    x_accpt_sec_efc                     IN     VARCHAR2,
    x_accpt_acad_cal                    IN     VARCHAR2,
    x_accpt_pymt_method                 IN     VARCHAR2,
    x_accpt_coa                         IN     NUMBER,
    x_accpt_enrl_stat                   IN     VARCHAR2,
    x_accpt_wks_inst_pymt               IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_accpt_wks_acad                    IN     VARCHAR2,
    x_accpt_cr_acad_yr                  IN     VARCHAR2,
    x_inst_seq_num                      IN     VARCHAR2,
    x_sch_full_time_pell                IN     NUMBER,
    x_stud_name                         IN     VARCHAR2,
    x_ssn                               IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_cps_ver_sel_cd                    IN     VARCHAR2,
    x_ytd_disb_amt                      IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_process_date                      IN     DATE,
 	  x_ci_cal_type                       IN     VARCHAR2,
 	  x_ci_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 21-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        origination_id,
        original_ssn,
        original_name_cd,
        attend_pell_id,
        ed_use,
        inst_cross_ref_code,
        action_code,
        accpt_awd_amt,
        accpt_disb_dt1,
        accpt_disb_dt2,
        accpt_disb_dt3,
        accpt_disb_dt4,
        accpt_disb_dt5,
        accpt_disb_dt6,
        accpt_disb_dt7,
        accpt_disb_dt8,
        accpt_disb_dt9,
        accpt_disb_dt10,
        accpt_disb_dt11,
        accpt_disb_dt12,
        accpt_disb_dt13,
        accpt_disb_dt14,
        accpt_disb_dt15,
        accpt_enrl_dt,
        accpt_low_tut_flg,
        accpt_ver_stat_flg,
        accpt_incr_pell_cd,
        accpt_tran_num,
        accpt_efc,
        accpt_sec_efc,
        accpt_acad_cal,
        accpt_pymt_method,
        accpt_coa,
        accpt_enrl_stat,
        accpt_wks_inst_pymt,
        wk_inst_time_calc_pymt,
        accpt_wks_acad,
        accpt_cr_acad_yr,
        inst_seq_num,
        sch_full_time_pell,
        stud_name,
        ssn,
        stud_dob,
        cps_ver_sel_cd,
        ytd_disb_amt,
        batch_id,
        process_date,
 	      ci_cal_type,
 	      ci_sequence_number
      FROM  igf_gr_ytd_orig_all
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
        ((tlinfo.origination_id = x_origination_id) OR ((tlinfo.origination_id IS NULL) AND (X_origination_id IS NULL)))
        AND ((tlinfo.original_ssn = x_original_ssn) OR ((tlinfo.original_ssn IS NULL) AND (X_original_ssn IS NULL)))
        AND ((tlinfo.original_name_cd = x_original_name_cd) OR ((tlinfo.original_name_cd IS NULL) AND (X_original_name_cd IS NULL)))
        AND ((tlinfo.attend_pell_id = x_attend_pell_id) OR ((tlinfo.attend_pell_id IS NULL) AND (X_attend_pell_id IS NULL)))
        AND ((tlinfo.ed_use = x_ed_use) OR ((tlinfo.ed_use IS NULL) AND (X_ed_use IS NULL)))
        AND ((tlinfo.inst_cross_ref_code = x_inst_cross_ref_code) OR ((tlinfo.inst_cross_ref_code IS NULL) AND (X_inst_cross_ref_code IS NULL)))
        AND ((tlinfo.action_code = x_action_code) OR ((tlinfo.action_code IS NULL) AND (X_action_code IS NULL)))
        AND ((tlinfo.accpt_awd_amt = x_accpt_awd_amt) OR ((tlinfo.accpt_awd_amt IS NULL) AND (X_accpt_awd_amt IS NULL)))
        AND ((tlinfo.accpt_disb_dt1 = x_accpt_disb_dt1) OR ((tlinfo.accpt_disb_dt1 IS NULL) AND (X_accpt_disb_dt1 IS NULL)))
        AND ((tlinfo.accpt_disb_dt2 = x_accpt_disb_dt2) OR ((tlinfo.accpt_disb_dt2 IS NULL) AND (X_accpt_disb_dt2 IS NULL)))
        AND ((tlinfo.accpt_disb_dt3 = x_accpt_disb_dt3) OR ((tlinfo.accpt_disb_dt3 IS NULL) AND (X_accpt_disb_dt3 IS NULL)))
        AND ((tlinfo.accpt_disb_dt4 = x_accpt_disb_dt4) OR ((tlinfo.accpt_disb_dt4 IS NULL) AND (X_accpt_disb_dt4 IS NULL)))
        AND ((tlinfo.accpt_disb_dt5 = x_accpt_disb_dt5) OR ((tlinfo.accpt_disb_dt5 IS NULL) AND (X_accpt_disb_dt5 IS NULL)))
        AND ((tlinfo.accpt_disb_dt6 = x_accpt_disb_dt6) OR ((tlinfo.accpt_disb_dt6 IS NULL) AND (X_accpt_disb_dt6 IS NULL)))
        AND ((tlinfo.accpt_disb_dt7 = x_accpt_disb_dt7) OR ((tlinfo.accpt_disb_dt7 IS NULL) AND (X_accpt_disb_dt7 IS NULL)))
        AND ((tlinfo.accpt_disb_dt8 = x_accpt_disb_dt8) OR ((tlinfo.accpt_disb_dt8 IS NULL) AND (X_accpt_disb_dt8 IS NULL)))
        AND ((tlinfo.accpt_disb_dt9 = x_accpt_disb_dt9) OR ((tlinfo.accpt_disb_dt9 IS NULL) AND (X_accpt_disb_dt9 IS NULL)))
        AND ((tlinfo.accpt_disb_dt10 = x_accpt_disb_dt10) OR ((tlinfo.accpt_disb_dt10 IS NULL) AND (X_accpt_disb_dt10 IS NULL)))
        AND ((tlinfo.accpt_disb_dt11 = x_accpt_disb_dt11) OR ((tlinfo.accpt_disb_dt11 IS NULL) AND (X_accpt_disb_dt11 IS NULL)))
        AND ((tlinfo.accpt_disb_dt12 = x_accpt_disb_dt12) OR ((tlinfo.accpt_disb_dt12 IS NULL) AND (X_accpt_disb_dt12 IS NULL)))
        AND ((tlinfo.accpt_disb_dt13 = x_accpt_disb_dt13) OR ((tlinfo.accpt_disb_dt13 IS NULL) AND (X_accpt_disb_dt13 IS NULL)))
        AND ((tlinfo.accpt_disb_dt14 = x_accpt_disb_dt14) OR ((tlinfo.accpt_disb_dt14 IS NULL) AND (X_accpt_disb_dt14 IS NULL)))
        AND ((tlinfo.accpt_disb_dt15 = x_accpt_disb_dt15) OR ((tlinfo.accpt_disb_dt15 IS NULL) AND (X_accpt_disb_dt15 IS NULL)))
        AND ((tlinfo.accpt_enrl_dt = x_accpt_enrl_dt) OR ((tlinfo.accpt_enrl_dt IS NULL) AND (X_accpt_enrl_dt IS NULL)))
        AND ((tlinfo.accpt_low_tut_flg = x_accpt_low_tut_flg) OR ((tlinfo.accpt_low_tut_flg IS NULL) AND (X_accpt_low_tut_flg IS NULL)))
        AND ((tlinfo.accpt_ver_stat_flg = x_accpt_ver_stat_flg) OR ((tlinfo.accpt_ver_stat_flg IS NULL) AND (X_accpt_ver_stat_flg IS NULL)))
        AND ((tlinfo.accpt_incr_pell_cd = x_accpt_incr_pell_cd) OR ((tlinfo.accpt_incr_pell_cd IS NULL) AND (X_accpt_incr_pell_cd IS NULL)))
        AND ((tlinfo.accpt_tran_num = x_accpt_tran_num) OR ((tlinfo.accpt_tran_num IS NULL) AND (X_accpt_tran_num IS NULL)))
        AND ((tlinfo.accpt_efc = x_accpt_efc) OR ((tlinfo.accpt_efc IS NULL) AND (X_accpt_efc IS NULL)))
        AND ((tlinfo.accpt_sec_efc = x_accpt_sec_efc) OR ((tlinfo.accpt_sec_efc IS NULL) AND (X_accpt_sec_efc IS NULL)))
        AND ((tlinfo.accpt_acad_cal = x_accpt_acad_cal) OR ((tlinfo.accpt_acad_cal IS NULL) AND (X_accpt_acad_cal IS NULL)))
        AND ((tlinfo.accpt_pymt_method = x_accpt_pymt_method) OR ((tlinfo.accpt_pymt_method IS NULL) AND (X_accpt_pymt_method IS NULL)))
        AND ((tlinfo.accpt_coa = x_accpt_coa) OR ((tlinfo.accpt_coa IS NULL) AND (X_accpt_coa IS NULL)))
        AND ((tlinfo.accpt_enrl_stat = x_accpt_enrl_stat) OR ((tlinfo.accpt_enrl_stat IS NULL) AND (X_accpt_enrl_stat IS NULL)))
        AND ((tlinfo.accpt_wks_inst_pymt = x_accpt_wks_inst_pymt) OR ((tlinfo.accpt_wks_inst_pymt IS NULL) AND (X_accpt_wks_inst_pymt IS NULL)))
        AND ((tlinfo.wk_inst_time_calc_pymt = x_wk_inst_time_calc_pymt) OR ((tlinfo.wk_inst_time_calc_pymt IS NULL) AND (X_wk_inst_time_calc_pymt IS NULL)))
        AND ((tlinfo.accpt_wks_acad = x_accpt_wks_acad) OR ((tlinfo.accpt_wks_acad IS NULL) AND (X_accpt_wks_acad IS NULL)))
        AND ((tlinfo.accpt_cr_acad_yr = x_accpt_cr_acad_yr) OR ((tlinfo.accpt_cr_acad_yr IS NULL) AND (X_accpt_cr_acad_yr IS NULL)))
        AND ((tlinfo.inst_seq_num = x_inst_seq_num) OR ((tlinfo.inst_seq_num IS NULL) AND (X_inst_seq_num IS NULL)))
        AND ((tlinfo.sch_full_time_pell = x_sch_full_time_pell) OR ((tlinfo.sch_full_time_pell IS NULL) AND (X_sch_full_time_pell IS NULL)))
        AND ((tlinfo.stud_name = x_stud_name) OR ((tlinfo.stud_name IS NULL) AND (X_stud_name IS NULL)))
        AND ((tlinfo.ssn = x_ssn) OR ((tlinfo.ssn IS NULL) AND (X_ssn IS NULL)))
        AND ((tlinfo.stud_dob = x_stud_dob) OR ((tlinfo.stud_dob IS NULL) AND (X_stud_dob IS NULL)))
        AND ((tlinfo.cps_ver_sel_cd = x_cps_ver_sel_cd) OR ((tlinfo.cps_ver_sel_cd IS NULL) AND (X_cps_ver_sel_cd IS NULL)))
        AND ((tlinfo.ytd_disb_amt = x_ytd_disb_amt) OR ((tlinfo.ytd_disb_amt IS NULL) AND (X_ytd_disb_amt IS NULL)))
        AND ((tlinfo.batch_id = x_batch_id) OR ((tlinfo.batch_id IS NULL) AND (X_batch_id IS NULL)))
        AND ((tlinfo.process_date = x_process_date) OR ((tlinfo.process_date IS NULL) AND (X_process_date IS NULL)))
	      AND ((tlinfo.ci_cal_type = x_ci_cal_type) OR ((tlinfo.ci_cal_type IS NULL) AND (X_ci_cal_type IS NULL)))
 	      AND ((tlinfo.ci_sequence_number = x_ci_sequence_number) OR ((tlinfo.ci_sequence_number IS NULL) AND (X_ci_sequence_number IS NULL)))
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
    x_ytdor_id                          IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_original_ssn                      IN     VARCHAR2,
    x_original_name_cd                  IN     VARCHAR2,
    x_attend_pell_id                    IN     VARCHAR2,
    x_ed_use                            IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_accpt_awd_amt                     IN     NUMBER,
    x_accpt_disb_dt1                    IN     DATE,
    x_accpt_disb_dt2                    IN     DATE,
    x_accpt_disb_dt3                    IN     DATE,
    x_accpt_disb_dt4                    IN     DATE,
    x_accpt_disb_dt5                    IN     DATE,
    x_accpt_disb_dt6                    IN     DATE,
    x_accpt_disb_dt7                    IN     DATE,
    x_accpt_disb_dt8                    IN     DATE,
    x_accpt_disb_dt9                    IN     DATE,
    x_accpt_disb_dt10                   IN     DATE,
    x_accpt_disb_dt11                   IN     DATE,
    x_accpt_disb_dt12                   IN     DATE,
    x_accpt_disb_dt13                   IN     DATE,
    x_accpt_disb_dt14                   IN     DATE,
    x_accpt_disb_dt15                   IN     DATE,
    x_accpt_enrl_dt                     IN     DATE,
    x_accpt_low_tut_flg                 IN     VARCHAR2,
    x_accpt_ver_stat_flg                IN     VARCHAR2,
    x_accpt_incr_pell_cd                IN     VARCHAR2,
    x_accpt_tran_num                    IN     VARCHAR2,
    x_accpt_efc                         IN     NUMBER,
    x_accpt_sec_efc                     IN     VARCHAR2,
    x_accpt_acad_cal                    IN     VARCHAR2,
    x_accpt_pymt_method                 IN     VARCHAR2,
    x_accpt_coa                         IN     NUMBER,
    x_accpt_enrl_stat                   IN     VARCHAR2,
    x_accpt_wks_inst_pymt               IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_accpt_wks_acad                    IN     VARCHAR2,
    x_accpt_cr_acad_yr                  IN     VARCHAR2,
    x_inst_seq_num                      IN     VARCHAR2,
    x_sch_full_time_pell                IN     NUMBER,
    x_stud_name                         IN     VARCHAR2,
    x_ssn                               IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_cps_ver_sel_cd                    IN     VARCHAR2,
    x_ytd_disb_amt                      IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_process_date                      IN     DATE,
    x_mode                              IN     VARCHAR2,
 	  x_ci_cal_type                       IN     VARCHAR2,
 	  x_ci_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 21-DEC-2000
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
      x_ytdor_id                          => x_ytdor_id,
      x_origination_id                    => x_origination_id,
      x_original_ssn                      => x_original_ssn,
      x_original_name_cd                  => x_original_name_cd,
      x_attend_pell_id                    => x_attend_pell_id,
      x_ed_use                            => x_ed_use,
      x_inst_cross_ref_code               => x_inst_cross_ref_code,
      x_action_code                       => x_action_code,
      x_accpt_awd_amt                     => x_accpt_awd_amt,
      x_accpt_disb_dt1                    => x_accpt_disb_dt1,
      x_accpt_disb_dt2                    => x_accpt_disb_dt2,
      x_accpt_disb_dt3                    => x_accpt_disb_dt3,
      x_accpt_disb_dt4                    => x_accpt_disb_dt4,
      x_accpt_disb_dt5                    => x_accpt_disb_dt5,
      x_accpt_disb_dt6                    => x_accpt_disb_dt6,
      x_accpt_disb_dt7                    => x_accpt_disb_dt7,
      x_accpt_disb_dt8                    => x_accpt_disb_dt8,
      x_accpt_disb_dt9                    => x_accpt_disb_dt9,
      x_accpt_disb_dt10                   => x_accpt_disb_dt10,
      x_accpt_disb_dt11                   => x_accpt_disb_dt11,
      x_accpt_disb_dt12                   => x_accpt_disb_dt12,
      x_accpt_disb_dt13                   => x_accpt_disb_dt13,
      x_accpt_disb_dt14                   => x_accpt_disb_dt14,
      x_accpt_disb_dt15                   => x_accpt_disb_dt15,
      x_accpt_enrl_dt                     => x_accpt_enrl_dt,
      x_accpt_low_tut_flg                 => x_accpt_low_tut_flg,
      x_accpt_ver_stat_flg                => x_accpt_ver_stat_flg,
      x_accpt_incr_pell_cd                => x_accpt_incr_pell_cd,
      x_accpt_tran_num                    => x_accpt_tran_num,
      x_accpt_efc                         => x_accpt_efc,
      x_accpt_sec_efc                     => x_accpt_sec_efc,
      x_accpt_acad_cal                    => x_accpt_acad_cal,
      x_accpt_pymt_method                 => x_accpt_pymt_method,
      x_accpt_coa                         => x_accpt_coa,
      x_accpt_enrl_stat                   => x_accpt_enrl_stat,
      x_accpt_wks_inst_pymt               => x_accpt_wks_inst_pymt,
      x_wk_inst_time_calc_pymt            => x_wk_inst_time_calc_pymt,
      x_accpt_wks_acad                    => x_accpt_wks_acad,
      x_accpt_cr_acad_yr                  => x_accpt_cr_acad_yr,
      x_inst_seq_num                      => x_inst_seq_num,
      x_sch_full_time_pell                => x_sch_full_time_pell,
      x_stud_name                         => x_stud_name,
      x_ssn                               => x_ssn,
      x_stud_dob                          => x_stud_dob,
      x_cps_ver_sel_cd                    => x_cps_ver_sel_cd,
      x_ytd_disb_amt                      => x_ytd_disb_amt,
      x_batch_id                          => x_batch_id,
      x_process_date                      => x_process_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
 	    x_ci_cal_type                       => x_ci_cal_type,
 	    x_ci_sequence_number                => x_ci_sequence_number
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

    UPDATE igf_gr_ytd_orig_all
      SET
        origination_id                    = new_references.origination_id,
        original_ssn                      = new_references.original_ssn,
        original_name_cd                  = new_references.original_name_cd,
        attend_pell_id                    = new_references.attend_pell_id,
        ed_use                            = new_references.ed_use,
        inst_cross_ref_code               = new_references.inst_cross_ref_code,
        action_code                       = new_references.action_code,
        accpt_awd_amt                     = new_references.accpt_awd_amt,
        accpt_disb_dt1                    = new_references.accpt_disb_dt1,
        accpt_disb_dt2                    = new_references.accpt_disb_dt2,
        accpt_disb_dt3                    = new_references.accpt_disb_dt3,
        accpt_disb_dt4                    = new_references.accpt_disb_dt4,
        accpt_disb_dt5                    = new_references.accpt_disb_dt5,
        accpt_disb_dt6                    = new_references.accpt_disb_dt6,
        accpt_disb_dt7                    = new_references.accpt_disb_dt7,
        accpt_disb_dt8                    = new_references.accpt_disb_dt8,
        accpt_disb_dt9                    = new_references.accpt_disb_dt9,
        accpt_disb_dt10                   = new_references.accpt_disb_dt10,
        accpt_disb_dt11                   = new_references.accpt_disb_dt11,
        accpt_disb_dt12                   = new_references.accpt_disb_dt12,
        accpt_disb_dt13                   = new_references.accpt_disb_dt13,
        accpt_disb_dt14                   = new_references.accpt_disb_dt14,
        accpt_disb_dt15                   = new_references.accpt_disb_dt15,
        accpt_enrl_dt                     = new_references.accpt_enrl_dt,
        accpt_low_tut_flg                 = new_references.accpt_low_tut_flg,
        accpt_ver_stat_flg                = new_references.accpt_ver_stat_flg,
        accpt_incr_pell_cd                = new_references.accpt_incr_pell_cd,
        accpt_tran_num                    = new_references.accpt_tran_num,
        accpt_efc                         = new_references.accpt_efc,
        accpt_sec_efc                     = new_references.accpt_sec_efc,
        accpt_acad_cal                    = new_references.accpt_acad_cal,
        accpt_pymt_method                 = new_references.accpt_pymt_method,
        accpt_coa                         = new_references.accpt_coa,
        accpt_enrl_stat                   = new_references.accpt_enrl_stat,
        accpt_wks_inst_pymt               = new_references.accpt_wks_inst_pymt,
        wk_inst_time_calc_pymt            = new_references.wk_inst_time_calc_pymt,
        accpt_wks_acad                    = new_references.accpt_wks_acad,
        accpt_cr_acad_yr                  = new_references.accpt_cr_acad_yr,
        inst_seq_num                      = new_references.inst_seq_num,
        sch_full_time_pell                = new_references.sch_full_time_pell,
        stud_name                         = new_references.stud_name,
        ssn                               = new_references.ssn,
        stud_dob                          = new_references.stud_dob,
        cps_ver_sel_cd                    = new_references.cps_ver_sel_cd,
        ytd_disb_amt                      = new_references.ytd_disb_amt,
        batch_id                          = new_references.batch_id,
        process_date                      = new_references.process_date,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
 	      ci_cal_type                       = x_ci_cal_type,
 	      ci_sequence_number                = x_ci_sequence_number
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ytdor_id                          IN OUT NOCOPY NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_original_ssn                      IN     VARCHAR2,
    x_original_name_cd                  IN     VARCHAR2,
    x_attend_pell_id                    IN     VARCHAR2,
    x_ed_use                            IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_accpt_awd_amt                     IN     NUMBER,
    x_accpt_disb_dt1                    IN     DATE,
    x_accpt_disb_dt2                    IN     DATE,
    x_accpt_disb_dt3                    IN     DATE,
    x_accpt_disb_dt4                    IN     DATE,
    x_accpt_disb_dt5                    IN     DATE,
    x_accpt_disb_dt6                    IN     DATE,
    x_accpt_disb_dt7                    IN     DATE,
    x_accpt_disb_dt8                    IN     DATE,
    x_accpt_disb_dt9                    IN     DATE,
    x_accpt_disb_dt10                   IN     DATE,
    x_accpt_disb_dt11                   IN     DATE,
    x_accpt_disb_dt12                   IN     DATE,
    x_accpt_disb_dt13                   IN     DATE,
    x_accpt_disb_dt14                   IN     DATE,
    x_accpt_disb_dt15                   IN     DATE,
    x_accpt_enrl_dt                     IN     DATE,
    x_accpt_low_tut_flg                 IN     VARCHAR2,
    x_accpt_ver_stat_flg                IN     VARCHAR2,
    x_accpt_incr_pell_cd                IN     VARCHAR2,
    x_accpt_tran_num                    IN     VARCHAR2,
    x_accpt_efc                         IN     NUMBER,
    x_accpt_sec_efc                     IN     VARCHAR2,
    x_accpt_acad_cal                    IN     VARCHAR2,
    x_accpt_pymt_method                 IN     VARCHAR2,
    x_accpt_coa                         IN     NUMBER,
    x_accpt_enrl_stat                   IN     VARCHAR2,
    x_accpt_wks_inst_pymt               IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_accpt_wks_acad                    IN     VARCHAR2,
    x_accpt_cr_acad_yr                  IN     VARCHAR2,
    x_inst_seq_num                      IN     VARCHAR2,
    x_sch_full_time_pell                IN     NUMBER,
    x_stud_name                         IN     VARCHAR2,
    x_ssn                               IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_cps_ver_sel_cd                    IN     VARCHAR2,
    x_ytd_disb_amt                      IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_process_date                      IN     DATE,
    x_mode                              IN     VARCHAR2,
 	  x_ci_cal_type                       IN     VARCHAR2,
 	  x_ci_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 21-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_gr_ytd_orig_all
      WHERE    ytdor_id                          = x_ytdor_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ytdor_id,
        x_origination_id,
        x_original_ssn,
        x_original_name_cd,
        x_attend_pell_id,
        x_ed_use,
        x_inst_cross_ref_code,
        x_action_code,
        x_accpt_awd_amt,
        x_accpt_disb_dt1,
        x_accpt_disb_dt2,
        x_accpt_disb_dt3,
        x_accpt_disb_dt4,
        x_accpt_disb_dt5,
        x_accpt_disb_dt6,
        x_accpt_disb_dt7,
        x_accpt_disb_dt8,
        x_accpt_disb_dt9,
        x_accpt_disb_dt10,
        x_accpt_disb_dt11,
        x_accpt_disb_dt12,
        x_accpt_disb_dt13,
        x_accpt_disb_dt14,
        x_accpt_disb_dt15,
        x_accpt_enrl_dt,
        x_accpt_low_tut_flg,
        x_accpt_ver_stat_flg,
        x_accpt_incr_pell_cd,
        x_accpt_tran_num,
        x_accpt_efc,
        x_accpt_sec_efc,
        x_accpt_acad_cal,
        x_accpt_pymt_method,
        x_accpt_coa,
        x_accpt_enrl_stat,
        x_accpt_wks_inst_pymt,
        x_wk_inst_time_calc_pymt,
        x_accpt_wks_acad,
        x_accpt_cr_acad_yr,
        x_inst_seq_num,
        x_sch_full_time_pell,
        x_stud_name,
        x_ssn,
        x_stud_dob,
        x_cps_ver_sel_cd,
        x_ytd_disb_amt,
        x_batch_id,
        x_process_date,
        x_mode,
 	      x_ci_cal_type,
 	      x_ci_sequence_number
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ytdor_id,
      x_origination_id,
      x_original_ssn,
      x_original_name_cd,
      x_attend_pell_id,
      x_ed_use,
      x_inst_cross_ref_code,
      x_action_code,
      x_accpt_awd_amt,
      x_accpt_disb_dt1,
      x_accpt_disb_dt2,
      x_accpt_disb_dt3,
      x_accpt_disb_dt4,
      x_accpt_disb_dt5,
      x_accpt_disb_dt6,
      x_accpt_disb_dt7,
      x_accpt_disb_dt8,
      x_accpt_disb_dt9,
      x_accpt_disb_dt10,
      x_accpt_disb_dt11,
      x_accpt_disb_dt12,
      x_accpt_disb_dt13,
      x_accpt_disb_dt14,
      x_accpt_disb_dt15,
      x_accpt_enrl_dt,
      x_accpt_low_tut_flg,
      x_accpt_ver_stat_flg,
      x_accpt_incr_pell_cd,
      x_accpt_tran_num,
      x_accpt_efc,
      x_accpt_sec_efc,
      x_accpt_acad_cal,
      x_accpt_pymt_method,
      x_accpt_coa,
      x_accpt_enrl_stat,
      x_accpt_wks_inst_pymt,
      x_wk_inst_time_calc_pymt,
      x_accpt_wks_acad,
      x_accpt_cr_acad_yr,
      x_inst_seq_num,
      x_sch_full_time_pell,
      x_stud_name,
      x_ssn,
      x_stud_dob,
      x_cps_ver_sel_cd,
      x_ytd_disb_amt,
      x_batch_id,
      x_process_date,
      x_mode,
 	    x_ci_cal_type,
 	    x_ci_sequence_number
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 21-DEC-2000
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

    DELETE FROM igf_gr_ytd_orig_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_gr_ytd_orig_pkg;

/
