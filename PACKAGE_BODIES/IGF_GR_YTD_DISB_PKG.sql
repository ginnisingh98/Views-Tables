--------------------------------------------------------
--  DDL for Package Body IGF_GR_YTD_DISB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_YTD_DISB_PKG" AS
/* $Header: IGFGI14B.pls 120.1 2006/04/06 06:09:01 veramach noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_gr_ytd_disb_all%ROWTYPE;
  new_references igf_gr_ytd_disb_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_ytdds_id                          IN     NUMBER      ,
    x_origination_id                    IN     VARCHAR2    ,
    x_inst_cross_ref_code               IN     VARCHAR2    ,
    x_action_code                       IN     VARCHAR2    ,
    x_disb_ref_num                      IN     VARCHAR2    ,
    x_disb_accpt_amt                    IN     NUMBER      ,
    x_db_cr_flag                        IN     VARCHAR2    ,
    x_disb_dt                           IN     DATE        ,
    x_pymt_prd_start_dt                 IN     DATE        ,
    x_disb_batch_id                     IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
 	  x_ci_cal_type                       IN     VARCHAR2    ,
 	  x_ci_sequence_number                IN     NUMBER      ,
 	  x_student_name                      IN     VARCHAR2    ,
 	  x_current_ssn_txt                   IN     VARCHAR2    ,
 	  x_student_birth_date                IN     DATE        ,
 	  x_disb_process_date                 IN     DATE        ,
 	  x_routing_id_txt                    IN     VARCHAR2    ,
 	  x_fin_award_year_num                IN     NUMBER      ,
 	  x_attend_entity_id_txt              IN     VARCHAR2    ,
 	  x_disb_seq_num                      IN     NUMBER      ,
 	  x_disb_rel_ind                      IN     VARCHAR2    ,
 	  x_prev_disb_seq_num                 IN     NUMBER
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
      FROM     igf_gr_ytd_disb_all
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
    new_references.ytdds_id                          := x_ytdds_id;
    new_references.origination_id                    := x_origination_id;
    new_references.inst_cross_ref_code               := x_inst_cross_ref_code;
    new_references.action_code                       := x_action_code;
    new_references.disb_ref_num                      := x_disb_ref_num;
    new_references.disb_accpt_amt                    := x_disb_accpt_amt;
    new_references.db_cr_flag                        := x_db_cr_flag;
    new_references.disb_dt                           := x_disb_dt;
    new_references.pymt_prd_start_dt                 := x_pymt_prd_start_dt;
    new_references.disb_batch_id                     := x_disb_batch_id;
	  new_references.ci_cal_type                       := x_ci_cal_type;
 	  new_references.ci_sequence_number                := x_ci_sequence_number;
 	  new_references.student_name                      := x_student_name;
 	  new_references.current_ssn_txt                   := x_current_ssn_txt;
 	  new_references.student_birth_date                := x_student_birth_date;
 	  new_references.disb_process_date                 := x_disb_process_date;
 	  new_references.routing_id_txt                    := x_routing_id_txt;
 	  new_references.fin_award_year_num                := x_fin_award_year_num;
 	  new_references.attend_entity_id_txt              := x_attend_entity_id_txt;
 	  new_references.disb_seq_num                      := x_disb_seq_num;
 	  new_references.disb_rel_ind                      := x_disb_rel_ind;
 	  new_references.prev_disb_seq_num                 := x_prev_disb_seq_num;

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
    x_ytdds_id                          IN     NUMBER
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
      FROM     igf_gr_ytd_disb_all
      WHERE    ytdds_id = x_ytdds_id
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
    x_ytdds_id                          IN     NUMBER      ,
    x_origination_id                    IN     VARCHAR2    ,
    x_inst_cross_ref_code               IN     VARCHAR2    ,
    x_action_code                       IN     VARCHAR2    ,
    x_disb_ref_num                      IN     VARCHAR2    ,
    x_disb_accpt_amt                    IN     NUMBER      ,
    x_db_cr_flag                        IN     VARCHAR2    ,
    x_disb_dt                           IN     DATE        ,
    x_pymt_prd_start_dt                 IN     DATE        ,
    x_disb_batch_id                     IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_ci_cal_type                       IN     VARCHAR2    ,
 	  x_ci_sequence_number                IN     NUMBER      ,
 	  x_student_name                      IN     VARCHAR2    ,
 	  x_current_ssn_txt                   IN     VARCHAR2    ,
 	  x_student_birth_date                IN     DATE        ,
 	  x_disb_process_date                 IN     DATE        ,
 	  x_routing_id_txt                    IN     VARCHAR2    ,
 	  x_fin_award_year_num                IN     NUMBER      ,
 	  x_attend_entity_id_txt              IN     VARCHAR2    ,
 	  x_disb_seq_num                      IN     NUMBER      ,
 	  x_disb_rel_ind                      IN     VARCHAR2    ,
 	  x_prev_disb_seq_num                 IN     NUMBER
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
      x_ytdds_id,
      x_origination_id,
      x_inst_cross_ref_code,
      x_action_code,
      x_disb_ref_num,
      x_disb_accpt_amt,
      x_db_cr_flag,
      x_disb_dt,
      x_pymt_prd_start_dt,
      x_disb_batch_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
 	    x_ci_cal_type,
 	    x_ci_sequence_number,
 	    x_student_name,
 	    x_current_ssn_txt,
 	    x_student_birth_date,
 	    x_disb_process_date,
 	    x_routing_id_txt,
 	    x_fin_award_year_num,
 	    x_attend_entity_id_txt,
 	    x_disb_seq_num,
 	    x_disb_rel_ind,
 	    x_prev_disb_seq_num
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ytdds_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.ytdds_id
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
    x_ytdds_id                          IN OUT NOCOPY NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_accpt_amt                    IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_pymt_prd_start_dt                 IN     DATE,
    x_disb_batch_id                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
 	  x_ci_cal_type                       IN     VARCHAR2,
 	  x_ci_sequence_number                IN     NUMBER,
 	  x_student_name                      IN     VARCHAR2,
 	  x_current_ssn_txt                   IN     VARCHAR2,
 	  x_student_birth_date                IN     DATE,
 	  x_disb_process_date                 IN     DATE,
 	  x_routing_id_txt                    IN     VARCHAR2,
 	  x_fin_award_year_num                IN     NUMBER,
 	  x_attend_entity_id_txt              IN     VARCHAR2,
 	  x_disb_seq_num                      IN     NUMBER,
 	  x_disb_rel_ind                      IN     VARCHAR2,
 	  x_prev_disb_seq_num                 IN     NUMBER
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
      FROM     igf_gr_ytd_disb_all
      WHERE    ytdds_id                          = x_ytdds_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_gr_ytd_disb_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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

		SELECT igf_gr_ytd_disb_s.nextval INTO x_ytdds_id FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ytdds_id                          => x_ytdds_id,
      x_origination_id                    => x_origination_id,
      x_inst_cross_ref_code               => x_inst_cross_ref_code,
      x_action_code                       => x_action_code,
      x_disb_ref_num                      => x_disb_ref_num,
      x_disb_accpt_amt                    => x_disb_accpt_amt,
      x_db_cr_flag                        => x_db_cr_flag,
      x_disb_dt                           => x_disb_dt,
      x_pymt_prd_start_dt                 => x_pymt_prd_start_dt,
      x_disb_batch_id                     => x_disb_batch_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
 	    x_ci_cal_type                       =>  x_ci_cal_type,
 	    x_ci_sequence_number                =>  x_ci_sequence_number,
 	    x_student_name                      =>  x_student_name,
 	    x_current_ssn_txt                   =>  x_current_ssn_txt,
 	    x_student_birth_date                =>  x_student_birth_date,
 	    x_disb_process_date                 =>  x_disb_process_date,
 	    x_routing_id_txt                    =>  x_routing_id_txt,
 	    x_fin_award_year_num                =>  x_fin_award_year_num,
 	    x_attend_entity_id_txt              =>  x_attend_entity_id_txt,
 	    x_disb_seq_num                      =>  x_disb_seq_num,
 	    x_disb_rel_ind                      =>  x_disb_rel_ind,
 	    x_prev_disb_seq_num                 =>  x_prev_disb_seq_num
    );

    INSERT INTO igf_gr_ytd_disb_all (
      ytdds_id,
      origination_id,
      inst_cross_ref_code,
      action_code,
      disb_ref_num,
      disb_accpt_amt,
      db_cr_flag,
      disb_dt,
      pymt_prd_start_dt,
      disb_batch_id,
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
 	    ci_sequence_number,
 	    student_name,
 	    current_ssn_txt,
 	    student_birth_date,
 	    disb_process_date,
 	    routing_id_txt,
 	    fin_award_year_num,
 	    attend_entity_id_txt,
 	    disb_seq_num,
 	    disb_rel_ind,
 	    prev_disb_seq_num
    ) VALUES (
      new_references.ytdds_id,
      new_references.origination_id,
      new_references.inst_cross_ref_code,
      new_references.action_code,
      new_references.disb_ref_num,
      new_references.disb_accpt_amt,
      new_references.db_cr_flag,
      new_references.disb_dt,
      new_references.pymt_prd_start_dt,
      new_references.disb_batch_id,
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
 	    new_references.ci_sequence_number,
 	    new_references.student_name,
 	    new_references.current_ssn_txt,
 	    new_references.student_birth_date,
 	    new_references.disb_process_date,
 	    new_references.routing_id_txt,
 	    new_references.fin_award_year_num,
 	    new_references.attend_entity_id_txt,
 	    new_references.disb_seq_num,
 	    new_references.disb_rel_ind,
 	    new_references.prev_disb_seq_num
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
    x_ytdds_id                          IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_accpt_amt                    IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_pymt_prd_start_dt                 IN     DATE,
    x_disb_batch_id                     IN     VARCHAR2,
 	  x_ci_cal_type                       IN     VARCHAR2,
 	  x_ci_sequence_number                IN     NUMBER,
 	  x_student_name                      IN     VARCHAR2,
 	  x_current_ssn_txt                   IN     VARCHAR2,
 	  x_student_birth_date                IN     DATE,
 	  x_disb_process_date                 IN     DATE,
 	  x_routing_id_txt                    IN     VARCHAR2,
 	  x_fin_award_year_num                IN     NUMBER,
 	  x_attend_entity_id_txt              IN     VARCHAR2,
 	  x_disb_seq_num                      IN     NUMBER,
 	  x_disb_rel_ind                      IN     VARCHAR2,
 	  x_prev_disb_seq_num                 IN     NUMBER
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
        inst_cross_ref_code,
        action_code,
        disb_ref_num,
        disb_accpt_amt,
        db_cr_flag,
        disb_dt,
        pymt_prd_start_dt,
        disb_batch_id,
 	      ci_cal_type,
 	      ci_sequence_number,
 	      student_name,
 	      current_ssn_txt,
 	      student_birth_date,
 	      disb_process_date,
 	      routing_id_txt,
 	      fin_award_year_num,
 	      attend_entity_id_txt,
 	      disb_seq_num,
 	      disb_rel_ind,
 	      prev_disb_seq_num
      FROM  igf_gr_ytd_disb_all
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
        AND ((tlinfo.inst_cross_ref_code = x_inst_cross_ref_code) OR ((tlinfo.inst_cross_ref_code IS NULL) AND (X_inst_cross_ref_code IS NULL)))
        AND ((tlinfo.action_code = x_action_code) OR ((tlinfo.action_code IS NULL) AND (X_action_code IS NULL)))
        AND (tlinfo.disb_ref_num = x_disb_ref_num)
        AND (tlinfo.disb_accpt_amt = x_disb_accpt_amt)
        AND ((tlinfo.db_cr_flag = x_db_cr_flag) OR ((tlinfo.db_cr_flag IS NULL) AND (X_db_cr_flag IS NULL)))
        AND ((tlinfo.disb_dt = x_disb_dt) OR ((tlinfo.disb_dt IS NULL) AND (X_disb_dt IS NULL)))
        AND (tlinfo.pymt_prd_start_dt = x_pymt_prd_start_dt)
        AND ((tlinfo.disb_batch_id = x_disb_batch_id) OR ((tlinfo.disb_batch_id IS NULL) AND (X_disb_batch_id IS NULL)))
	      AND ((tlinfo.ci_cal_type = x_ci_cal_type) OR ((tlinfo.ci_cal_type IS NULL) AND (X_ci_cal_type IS NULL)))
 	      AND ((tlinfo.ci_sequence_number = x_ci_sequence_number) OR ((tlinfo.ci_sequence_number IS NULL) AND (X_ci_sequence_number IS NULL)))
 	      AND ((tlinfo.student_name = x_student_name) OR ((tlinfo.student_name IS NULL) AND (X_student_name IS NULL)))
 	      AND ((tlinfo.current_ssn_txt = x_current_ssn_txt) OR ((tlinfo.current_ssn_txt IS NULL) AND (X_current_ssn_txt IS NULL)))
 	      AND ((tlinfo.student_birth_date = x_student_birth_date) OR ((tlinfo.student_birth_date IS NULL) AND (X_student_birth_date IS NULL)))
 	      AND ((tlinfo.disb_process_date = x_disb_process_date) OR ((tlinfo.disb_process_date IS NULL) AND (X_disb_process_date IS NULL)))
 	      AND ((tlinfo.routing_id_txt = x_routing_id_txt) OR ((tlinfo.routing_id_txt IS NULL) AND (X_routing_id_txt IS NULL)))
 	      AND ((tlinfo.fin_award_year_num = x_fin_award_year_num) OR ((tlinfo.fin_award_year_num IS NULL) AND (X_fin_award_year_num IS NULL)))
 	      AND ((tlinfo.attend_entity_id_txt = x_attend_entity_id_txt) OR ((tlinfo.attend_entity_id_txt IS NULL) AND (X_attend_entity_id_txt IS NULL)))
 	      AND ((tlinfo.disb_seq_num = x_disb_seq_num) OR ((tlinfo.disb_seq_num IS NULL) AND (X_disb_seq_num IS NULL)))
 	      AND ((tlinfo.disb_rel_ind = x_disb_rel_ind) OR ((tlinfo.disb_rel_ind IS NULL) AND (X_disb_rel_ind IS NULL)))
 	      AND ((tlinfo.prev_disb_seq_num = x_prev_disb_seq_num) OR ((tlinfo.prev_disb_seq_num IS NULL) AND (X_prev_disb_seq_num IS NULL)))
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
    x_ytdds_id                          IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_accpt_amt                    IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_pymt_prd_start_dt                 IN     DATE,
    x_disb_batch_id                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
 	  x_ci_cal_type                       IN     VARCHAR2,
 	  x_ci_sequence_number                IN     NUMBER,
 	  x_student_name                      IN     VARCHAR2,
 	  x_current_ssn_txt                   IN     VARCHAR2,
 	  x_student_birth_date                IN     DATE,
 	  x_disb_process_date                 IN     DATE,
 	  x_routing_id_txt                    IN     VARCHAR2,
 	  x_fin_award_year_num                IN     NUMBER,
 	  x_attend_entity_id_txt              IN     VARCHAR2,
 	  x_disb_seq_num                      IN     NUMBER,
 	  x_disb_rel_ind                      IN     VARCHAR2,
 	  x_prev_disb_seq_num                 IN     NUMBER
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
      x_ytdds_id                          => x_ytdds_id,
      x_origination_id                    => x_origination_id,
      x_inst_cross_ref_code               => x_inst_cross_ref_code,
      x_action_code                       => x_action_code,
      x_disb_ref_num                      => x_disb_ref_num,
      x_disb_accpt_amt                    => x_disb_accpt_amt,
      x_db_cr_flag                        => x_db_cr_flag,
      x_disb_dt                           => x_disb_dt,
      x_pymt_prd_start_dt                 => x_pymt_prd_start_dt,
      x_disb_batch_id                     => x_disb_batch_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
 	    x_ci_cal_type                       =>  x_ci_cal_type,
 	    x_ci_sequence_number                =>  x_ci_sequence_number,
 	    x_student_name                      =>  x_student_name,
 	    x_current_ssn_txt                   =>  x_current_ssn_txt,
 	    x_student_birth_date                =>  x_student_birth_date,
 	    x_disb_process_date                 =>  x_disb_process_date,
 	    x_routing_id_txt                    =>  x_routing_id_txt,
 	    x_fin_award_year_num                =>  x_fin_award_year_num,
 	    x_attend_entity_id_txt              =>  x_attend_entity_id_txt,
 	    x_disb_seq_num                      =>  x_disb_seq_num,
 	    x_disb_rel_ind                      =>  x_disb_rel_ind,
 	    x_prev_disb_seq_num                 =>  x_prev_disb_seq_num
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

    UPDATE igf_gr_ytd_disb_all
      SET
        origination_id                    = new_references.origination_id,
        inst_cross_ref_code               = new_references.inst_cross_ref_code,
        action_code                       = new_references.action_code,
        disb_ref_num                      = new_references.disb_ref_num,
        disb_accpt_amt                    = new_references.disb_accpt_amt,
        db_cr_flag                        = new_references.db_cr_flag,
        disb_dt                           = new_references.disb_dt,
        pymt_prd_start_dt                 = new_references.pymt_prd_start_dt,
        disb_batch_id                     = new_references.disb_batch_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
 	      ci_cal_type                       = new_references.ci_cal_type,
 	      ci_sequence_number                = new_references.ci_sequence_number,
 	      student_name                      = new_references.student_name,
 	      current_ssn_txt                   = new_references.current_ssn_txt,
 	      student_birth_date                = new_references.student_birth_date,
 	      disb_process_date                 = new_references.disb_process_date,
 	      routing_id_txt                    = new_references.routing_id_txt,
 	      fin_award_year_num                = new_references.fin_award_year_num,
 	      attend_entity_id_txt              = new_references.attend_entity_id_txt,
 	      disb_seq_num                      = new_references.disb_seq_num,
 	      disb_rel_ind                      = new_references.disb_rel_ind,
 	      prev_disb_seq_num                 = new_references.prev_disb_seq_num
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ytdds_id                          IN OUT NOCOPY NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_accpt_amt                    IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_pymt_prd_start_dt                 IN     DATE,
    x_disb_batch_id                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
 	  x_ci_cal_type                       IN     VARCHAR2,
 	  x_ci_sequence_number                IN     NUMBER,
 	  x_student_name                      IN     VARCHAR2,
 	  x_current_ssn_txt                   IN     VARCHAR2,
 	  x_student_birth_date                IN     DATE,
 	  x_disb_process_date                 IN     DATE,
 	  x_routing_id_txt                    IN     VARCHAR2,
 	  x_fin_award_year_num                IN     NUMBER,
 	  x_attend_entity_id_txt              IN     VARCHAR2,
 	  x_disb_seq_num                      IN     NUMBER,
 	  x_disb_rel_ind                      IN     VARCHAR2,
 	  x_prev_disb_seq_num                 IN     NUMBER
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
      FROM     igf_gr_ytd_disb_all
      WHERE    ytdds_id                          = x_ytdds_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ytdds_id,
        x_origination_id,
        x_inst_cross_ref_code,
        x_action_code,
        x_disb_ref_num,
        x_disb_accpt_amt,
        x_db_cr_flag,
        x_disb_dt,
        x_pymt_prd_start_dt,
        x_disb_batch_id,
        x_mode,
 	      x_ci_cal_type,
 	      x_ci_sequence_number,
 	      x_student_name,
 	      x_current_ssn_txt,
 	      x_student_birth_date,
 	      x_disb_process_date,
 	      x_routing_id_txt,
 	      x_fin_award_year_num,
 	      x_attend_entity_id_txt,
 	      x_disb_seq_num,
 	      x_disb_rel_ind,
 	      x_prev_disb_seq_num
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ytdds_id,
      x_origination_id,
      x_inst_cross_ref_code,
      x_action_code,
      x_disb_ref_num,
      x_disb_accpt_amt,
      x_db_cr_flag,
      x_disb_dt,
      x_pymt_prd_start_dt,
      x_disb_batch_id,
      x_mode,
 	    x_ci_cal_type,
 	    x_ci_sequence_number,
 	    x_student_name,
 	    x_current_ssn_txt,
 	    x_student_birth_date,
 	    x_disb_process_date,
 	    x_routing_id_txt,
 	    x_fin_award_year_num,
 	    x_attend_entity_id_txt,
 	    x_disb_seq_num,
 	    x_disb_rel_ind,
 	    x_prev_disb_seq_num
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

    DELETE FROM igf_gr_ytd_disb_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_gr_ytd_disb_pkg;

/
