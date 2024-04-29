--------------------------------------------------------
--  DDL for Package Body IGF_GR_MRR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_MRR_PKG" AS
/* $Header: IGFGI12B.pls 115.7 2002/11/28 14:18:06 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_gr_mrr_all%ROWTYPE;
  new_references igf_gr_mrr_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_mrr_id                            IN     NUMBER  ,
    x_record_type                       IN     VARCHAR2,
    x_req_inst_pell_id                  IN     VARCHAR2,
    x_mrr_code1                         IN     VARCHAR2,
    x_mrr_code2                         IN     VARCHAR2,
    x_mr_stud_id                        IN     VARCHAR2,
    x_mr_inst_pell_id                   IN     VARCHAR2,
    x_stud_orig_ssn                     IN     VARCHAR2,
    x_orig_name_cd                      IN     VARCHAR2,
    x_inst_pell_id                      IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_addr1                        IN     VARCHAR2,
    x_inst_addr2                        IN     VARCHAR2,
    x_inst_city                         IN     VARCHAR2,
    x_inst_state                        IN     VARCHAR2,
    x_zip_code                          IN     VARCHAR2,
    x_faa_name                          IN     VARCHAR2,
    x_faa_tel                           IN     VARCHAR2,
    x_faa_fax                           IN     VARCHAR2,
    x_faa_internet_addr                 IN     VARCHAR2,
    x_schd_pell_grant                   IN     NUMBER  ,
    x_orig_awd_amt                      IN     NUMBER  ,
    x_tran_num                          IN     VARCHAR2,
    x_efc                               IN     NUMBER  ,
    x_enrl_dt                           IN     DATE    ,
    x_orig_creation_dt                  IN     DATE    ,
    x_disb_accepted_amt                 IN     NUMBER  ,
    x_last_active_dt                    IN     DATE    ,
    x_next_est_disb_dt                  IN     DATE    ,
    x_eligibility_used                  IN     NUMBER  ,
    x_ed_use_flags                      IN     VARCHAR2,
    x_stud_last_name                    IN     VARCHAR2,
    x_stud_first_name                   IN     VARCHAR2,
    x_stud_middle_name                  IN     VARCHAR2,
    x_stud_dob                          IN     DATE    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_current_ssn                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_gr_mrr_all
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
    new_references.mrr_id                            := x_mrr_id;
    new_references.record_type                       := x_record_type;
    new_references.req_inst_pell_id                  := x_req_inst_pell_id;
    new_references.mrr_code1                         := x_mrr_code1;
    new_references.mrr_code2                         := x_mrr_code2;
    new_references.mr_stud_id                        := x_mr_stud_id;
    new_references.mr_inst_pell_id                   := x_mr_inst_pell_id;
    new_references.stud_orig_ssn                     := x_stud_orig_ssn;
    new_references.orig_name_cd                      := x_orig_name_cd;
    new_references.inst_pell_id                      := x_inst_pell_id;
    new_references.inst_name                         := x_inst_name;
    new_references.inst_addr1                        := x_inst_addr1;
    new_references.inst_addr2                        := x_inst_addr2;
    new_references.inst_city                         := x_inst_city;
    new_references.inst_state                        := x_inst_state;
    new_references.zip_code                          := x_zip_code;
    new_references.faa_name                          := x_faa_name;
    new_references.faa_tel                           := x_faa_tel;
    new_references.faa_fax                           := x_faa_fax;
    new_references.faa_internet_addr                 := x_faa_internet_addr;
    new_references.schd_pell_grant                   := x_schd_pell_grant;
    new_references.orig_awd_amt                      := x_orig_awd_amt;
    new_references.tran_num                          := x_tran_num;
    new_references.efc                               := x_efc;
    new_references.enrl_dt                           := x_enrl_dt;
    new_references.orig_creation_dt                  := x_orig_creation_dt;
    new_references.disb_accepted_amt                 := x_disb_accepted_amt;
    new_references.last_active_dt                    := x_last_active_dt;
    new_references.next_est_disb_dt                  := x_next_est_disb_dt;
    new_references.eligibility_used                  := x_eligibility_used;
    new_references.ed_use_flags                      := x_ed_use_flags;
    new_references.stud_last_name                    := x_stud_last_name;
    new_references.stud_first_name                   := x_stud_first_name;
    new_references.stud_middle_name                  := x_stud_middle_name;
    new_references.stud_dob                          := x_stud_dob;

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
    new_references.current_ssn                       := x_current_ssn;

  END set_column_values;


  FUNCTION get_pk_for_validation (
    x_mrr_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_mrr_all
      WHERE    mrr_id = x_mrr_id
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
    x_rowid                             IN     VARCHAR2,
    x_mrr_id                            IN     NUMBER  ,
    x_record_type                       IN     VARCHAR2,
    x_req_inst_pell_id                  IN     VARCHAR2,
    x_mrr_code1                         IN     VARCHAR2,
    x_mrr_code2                         IN     VARCHAR2,
    x_mr_stud_id                        IN     VARCHAR2,
    x_mr_inst_pell_id                   IN     VARCHAR2,
    x_stud_orig_ssn                     IN     VARCHAR2,
    x_orig_name_cd                      IN     VARCHAR2,
    x_inst_pell_id                      IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_addr1                        IN     VARCHAR2,
    x_inst_addr2                        IN     VARCHAR2,
    x_inst_city                         IN     VARCHAR2,
    x_inst_state                        IN     VARCHAR2,
    x_zip_code                          IN     VARCHAR2,
    x_faa_name                          IN     VARCHAR2,
    x_faa_tel                           IN     VARCHAR2,
    x_faa_fax                           IN     VARCHAR2,
    x_faa_internet_addr                 IN     VARCHAR2,
    x_schd_pell_grant                   IN     NUMBER  ,
    x_orig_awd_amt                      IN     NUMBER  ,
    x_tran_num                          IN     VARCHAR2,
    x_efc                               IN     NUMBER  ,
    x_enrl_dt                           IN     DATE    ,
    x_orig_creation_dt                  IN     DATE    ,
    x_disb_accepted_amt                 IN     NUMBER  ,
    x_last_active_dt                    IN     DATE    ,
    x_next_est_disb_dt                  IN     DATE    ,
    x_eligibility_used                  IN     NUMBER  ,
    x_ed_use_flags                      IN     VARCHAR2,
    x_stud_last_name                    IN     VARCHAR2,
    x_stud_first_name                   IN     VARCHAR2,
    x_stud_middle_name                  IN     VARCHAR2,
    x_stud_dob                          IN     DATE    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_current_ssn                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 14-DEC-2000
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
      x_mrr_id,
      x_record_type,
      x_req_inst_pell_id,
      x_mrr_code1,
      x_mrr_code2,
      x_mr_stud_id,
      x_mr_inst_pell_id,
      x_stud_orig_ssn,
      x_orig_name_cd,
      x_inst_pell_id,
      x_inst_name,
      x_inst_addr1,
      x_inst_addr2,
      x_inst_city,
      x_inst_state,
      x_zip_code,
      x_faa_name,
      x_faa_tel,
      x_faa_fax,
      x_faa_internet_addr,
      x_schd_pell_grant,
      x_orig_awd_amt,
      x_tran_num,
      x_efc,
      x_enrl_dt,
      x_orig_creation_dt,
      x_disb_accepted_amt,
      x_last_active_dt,
      x_next_est_disb_dt,
      x_eligibility_used,
      x_ed_use_flags,
      x_stud_last_name,
      x_stud_first_name,
      x_stud_middle_name,
      x_stud_dob,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_current_ssn
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.mrr_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.mrr_id
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
    x_mrr_id                            IN OUT NOCOPY NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_req_inst_pell_id                  IN     VARCHAR2,
    x_mrr_code1                         IN     VARCHAR2,
    x_mrr_code2                         IN     VARCHAR2,
    x_mr_stud_id                        IN     VARCHAR2,
    x_mr_inst_pell_id                   IN     VARCHAR2,
    x_stud_orig_ssn                     IN     VARCHAR2,
    x_orig_name_cd                      IN     VARCHAR2,
    x_inst_pell_id                      IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_addr1                        IN     VARCHAR2,
    x_inst_addr2                        IN     VARCHAR2,
    x_inst_city                         IN     VARCHAR2,
    x_inst_state                        IN     VARCHAR2,
    x_zip_code                          IN     VARCHAR2,
    x_faa_name                          IN     VARCHAR2,
    x_faa_tel                           IN     VARCHAR2,
    x_faa_fax                           IN     VARCHAR2,
    x_faa_internet_addr                 IN     VARCHAR2,
    x_schd_pell_grant                   IN     NUMBER,
    x_orig_awd_amt                      IN     NUMBER,
    x_tran_num                          IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_enrl_dt                           IN     DATE,
    x_orig_creation_dt                  IN     DATE,
    x_disb_accepted_amt                 IN     NUMBER,
    x_last_active_dt                    IN     DATE,
    x_next_est_disb_dt                  IN     DATE,
    x_eligibility_used                  IN     NUMBER,
    x_ed_use_flags                      IN     VARCHAR2,
    x_stud_last_name                    IN     VARCHAR2,
    x_stud_first_name                   IN     VARCHAR2,
    x_stud_middle_name                  IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_mode                              IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_gr_mrr_all
      WHERE    mrr_id                            = x_mrr_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

    l_org_id                     igf_gr_mrr_all.org_id%TYPE;

  BEGIN

    l_org_id                     := igf_aw_gen.get_org_id;

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

    SELECT igf_gr_mrr_s.nextval INTO x_mrr_id FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_mrr_id                            => x_mrr_id,
      x_record_type                       => x_record_type,
      x_req_inst_pell_id                  => x_req_inst_pell_id,
      x_mrr_code1                         => x_mrr_code1,
      x_mrr_code2                         => x_mrr_code2,
      x_mr_stud_id                        => x_mr_stud_id,
      x_mr_inst_pell_id                   => x_mr_inst_pell_id,
      x_stud_orig_ssn                     => x_stud_orig_ssn,
      x_orig_name_cd                      => x_orig_name_cd,
      x_inst_pell_id                      => x_inst_pell_id,
      x_inst_name                         => x_inst_name,
      x_inst_addr1                        => x_inst_addr1,
      x_inst_addr2                        => x_inst_addr2,
      x_inst_city                         => x_inst_city,
      x_inst_state                        => x_inst_state,
      x_zip_code                          => x_zip_code,
      x_faa_name                          => x_faa_name,
      x_faa_tel                           => x_faa_tel,
      x_faa_fax                           => x_faa_fax,
      x_faa_internet_addr                 => x_faa_internet_addr,
      x_schd_pell_grant                   => x_schd_pell_grant,
      x_orig_awd_amt                      => x_orig_awd_amt,
      x_tran_num                          => x_tran_num,
      x_efc                               => x_efc,
      x_enrl_dt                           => x_enrl_dt,
      x_orig_creation_dt                  => x_orig_creation_dt,
      x_disb_accepted_amt                 => x_disb_accepted_amt,
      x_last_active_dt                    => x_last_active_dt,
      x_next_est_disb_dt                  => x_next_est_disb_dt,
      x_eligibility_used                  => x_eligibility_used,
      x_ed_use_flags                      => x_ed_use_flags,
      x_stud_last_name                    => x_stud_last_name,
      x_stud_first_name                   => x_stud_first_name,
      x_stud_middle_name                  => x_stud_middle_name,
      x_stud_dob                          => x_stud_dob,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_current_ssn                       => x_current_ssn
      );

    INSERT INTO igf_gr_mrr_all (
      mrr_id,
      record_type,
      req_inst_pell_id,
      mrr_code1,
      mrr_code2,
      mr_stud_id,
      mr_inst_pell_id,
      stud_orig_ssn,
      orig_name_cd,
      inst_pell_id,
      inst_name,
      inst_addr1,
      inst_addr2,
      inst_city,
      inst_state,
      zip_code,
      faa_name,
      faa_tel,
      faa_fax,
      faa_internet_addr,
      schd_pell_grant,
      orig_awd_amt,
      tran_num,
      efc,
      enrl_dt,
      orig_creation_dt,
      disb_accepted_amt,
      last_active_dt,
      next_est_disb_dt,
      eligibility_used,
      ed_use_flags,
      stud_last_name,
      stud_first_name,
      stud_middle_name,
      stud_dob,
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
      current_ssn
    ) VALUES (
      new_references.mrr_id,
      new_references.record_type,
      new_references.req_inst_pell_id,
      new_references.mrr_code1,
      new_references.mrr_code2,
      new_references.mr_stud_id,
      new_references.mr_inst_pell_id,
      new_references.stud_orig_ssn,
      new_references.orig_name_cd,
      new_references.inst_pell_id,
      new_references.inst_name,
      new_references.inst_addr1,
      new_references.inst_addr2,
      new_references.inst_city,
      new_references.inst_state,
      new_references.zip_code,
      new_references.faa_name,
      new_references.faa_tel,
      new_references.faa_fax,
      new_references.faa_internet_addr,
      new_references.schd_pell_grant,
      new_references.orig_awd_amt,
      new_references.tran_num,
      new_references.efc,
      new_references.enrl_dt,
      new_references.orig_creation_dt,
      new_references.disb_accepted_amt,
      new_references.last_active_dt,
      new_references.next_est_disb_dt,
      new_references.eligibility_used,
      new_references.ed_use_flags,
      new_references.stud_last_name,
      new_references.stud_first_name,
      new_references.stud_middle_name,
      new_references.stud_dob,
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
      new_references.current_ssn
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
    x_mrr_id                            IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_req_inst_pell_id                  IN     VARCHAR2,
    x_mrr_code1                         IN     VARCHAR2,
    x_mrr_code2                         IN     VARCHAR2,
    x_mr_stud_id                        IN     VARCHAR2,
    x_mr_inst_pell_id                   IN     VARCHAR2,
    x_stud_orig_ssn                     IN     VARCHAR2,
    x_orig_name_cd                      IN     VARCHAR2,
    x_inst_pell_id                      IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_addr1                        IN     VARCHAR2,
    x_inst_addr2                        IN     VARCHAR2,
    x_inst_city                         IN     VARCHAR2,
    x_inst_state                        IN     VARCHAR2,
    x_zip_code                          IN     VARCHAR2,
    x_faa_name                          IN     VARCHAR2,
    x_faa_tel                           IN     VARCHAR2,
    x_faa_fax                           IN     VARCHAR2,
    x_faa_internet_addr                 IN     VARCHAR2,
    x_schd_pell_grant                   IN     NUMBER,
    x_orig_awd_amt                      IN     NUMBER,
    x_tran_num                          IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_enrl_dt                           IN     DATE,
    x_orig_creation_dt                  IN     DATE,
    x_disb_accepted_amt                 IN     NUMBER,
    x_last_active_dt                    IN     DATE,
    x_next_est_disb_dt                  IN     DATE,
    x_eligibility_used                  IN     NUMBER,
    x_ed_use_flags                      IN     VARCHAR2,
    x_stud_last_name                    IN     VARCHAR2,
    x_stud_first_name                   IN     VARCHAR2,
    x_stud_middle_name                  IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_current_ssn                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        record_type,
        req_inst_pell_id,
        mrr_code1,
        mrr_code2,
        mr_stud_id,
        mr_inst_pell_id,
        stud_orig_ssn,
        orig_name_cd,
        inst_pell_id,
        inst_name,
        inst_addr1,
        inst_addr2,
        inst_city,
        inst_state,
        zip_code,
        faa_name,
        faa_tel,
        faa_fax,
        faa_internet_addr,
        schd_pell_grant,
        orig_awd_amt,
        tran_num,
        efc,
        enrl_dt,
        orig_creation_dt,
        disb_accepted_amt,
        last_active_dt,
        next_est_disb_dt,
        eligibility_used,
        ed_use_flags,
        stud_last_name,
        stud_first_name,
        stud_middle_name,
        stud_dob,
        current_ssn
      FROM  igf_gr_mrr_all
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
        ((tlinfo.record_type = x_record_type) OR ((tlinfo.record_type IS NULL) AND (X_record_type IS NULL)))
        AND ((tlinfo.req_inst_pell_id = x_req_inst_pell_id) OR ((tlinfo.req_inst_pell_id IS NULL) AND (X_req_inst_pell_id IS NULL)))
        AND ((tlinfo.mrr_code1 = x_mrr_code1) OR ((tlinfo.mrr_code1 IS NULL) AND (X_mrr_code1 IS NULL)))
        AND ((tlinfo.mrr_code2 = x_mrr_code2) OR ((tlinfo.mrr_code2 IS NULL) AND (X_mrr_code2 IS NULL)))
        AND ((tlinfo.mr_stud_id = x_mr_stud_id) OR ((tlinfo.mr_stud_id IS NULL) AND (X_mr_stud_id IS NULL)))
        AND ((tlinfo.mr_inst_pell_id = x_mr_inst_pell_id) OR ((tlinfo.mr_inst_pell_id IS NULL) AND (X_mr_inst_pell_id IS NULL)))
        AND ((tlinfo.stud_orig_ssn = x_stud_orig_ssn) OR ((tlinfo.stud_orig_ssn IS NULL) AND (X_stud_orig_ssn IS NULL)))
        AND ((tlinfo.orig_name_cd = x_orig_name_cd) OR ((tlinfo.orig_name_cd IS NULL) AND (X_orig_name_cd IS NULL)))
        AND ((tlinfo.inst_pell_id = x_inst_pell_id) OR ((tlinfo.inst_pell_id IS NULL) AND (X_inst_pell_id IS NULL)))
        AND ((tlinfo.inst_name = x_inst_name) OR ((tlinfo.inst_name IS NULL) AND (X_inst_name IS NULL)))
        AND ((tlinfo.inst_addr1 = x_inst_addr1) OR ((tlinfo.inst_addr1 IS NULL) AND (X_inst_addr1 IS NULL)))
        AND ((tlinfo.inst_addr2 = x_inst_addr2) OR ((tlinfo.inst_addr2 IS NULL) AND (X_inst_addr2 IS NULL)))
        AND ((tlinfo.inst_city = x_inst_city) OR ((tlinfo.inst_city IS NULL) AND (X_inst_city IS NULL)))
        AND ((tlinfo.inst_state = x_inst_state) OR ((tlinfo.inst_state IS NULL) AND (X_inst_state IS NULL)))
        AND ((tlinfo.zip_code = x_zip_code) OR ((tlinfo.zip_code IS NULL) AND (X_zip_code IS NULL)))
        AND ((tlinfo.faa_name = x_faa_name) OR ((tlinfo.faa_name IS NULL) AND (X_faa_name IS NULL)))
        AND ((tlinfo.faa_tel = x_faa_tel) OR ((tlinfo.faa_tel IS NULL) AND (X_faa_tel IS NULL)))
        AND ((tlinfo.faa_fax = x_faa_fax) OR ((tlinfo.faa_fax IS NULL) AND (X_faa_fax IS NULL)))
        AND ((tlinfo.faa_internet_addr = x_faa_internet_addr) OR ((tlinfo.faa_internet_addr IS NULL) AND (X_faa_internet_addr IS NULL)))
        AND ((tlinfo.schd_pell_grant = x_schd_pell_grant) OR ((tlinfo.schd_pell_grant IS NULL) AND (X_schd_pell_grant IS NULL)))
        AND ((tlinfo.orig_awd_amt = x_orig_awd_amt) OR ((tlinfo.orig_awd_amt IS NULL) AND (X_orig_awd_amt IS NULL)))
        AND ((tlinfo.tran_num = x_tran_num) OR ((tlinfo.tran_num IS NULL) AND (X_tran_num IS NULL)))
        AND ((tlinfo.efc = x_efc) OR ((tlinfo.efc IS NULL) AND (X_efc IS NULL)))
        AND ((tlinfo.enrl_dt = x_enrl_dt) OR ((tlinfo.enrl_dt IS NULL) AND (X_enrl_dt IS NULL)))
        AND ((tlinfo.orig_creation_dt = x_orig_creation_dt) OR ((tlinfo.orig_creation_dt IS NULL) AND (X_orig_creation_dt IS NULL)))
        AND ((tlinfo.disb_accepted_amt = x_disb_accepted_amt) OR ((tlinfo.disb_accepted_amt IS NULL) AND (X_disb_accepted_amt IS NULL)))
        AND ((tlinfo.last_active_dt = x_last_active_dt) OR ((tlinfo.last_active_dt IS NULL) AND (X_last_active_dt IS NULL)))
        AND ((tlinfo.next_est_disb_dt = x_next_est_disb_dt) OR ((tlinfo.next_est_disb_dt IS NULL) AND (X_next_est_disb_dt IS NULL)))
        AND ((tlinfo.eligibility_used = x_eligibility_used) OR ((tlinfo.eligibility_used IS NULL) AND (X_eligibility_used IS NULL)))
        AND ((tlinfo.ed_use_flags = x_ed_use_flags) OR ((tlinfo.ed_use_flags IS NULL) AND (X_ed_use_flags IS NULL)))
        AND ((tlinfo.stud_last_name = x_stud_last_name) OR ((tlinfo.stud_last_name IS NULL) AND (X_stud_last_name IS NULL)))
        AND ((tlinfo.stud_first_name = x_stud_first_name) OR ((tlinfo.stud_first_name IS NULL) AND (X_stud_first_name IS NULL)))
        AND ((tlinfo.stud_middle_name = x_stud_middle_name) OR ((tlinfo.stud_middle_name IS NULL) AND (X_stud_middle_name IS NULL)))
        AND ((tlinfo.stud_dob = x_stud_dob) OR ((tlinfo.stud_dob IS NULL) AND (X_stud_dob IS NULL)))
        AND ((tlinfo.current_ssn = x_current_ssn) OR ((tlinfo.current_ssn IS NULL) AND (x_current_ssn IS NULL)))
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
    x_mrr_id                            IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_req_inst_pell_id                  IN     VARCHAR2,
    x_mrr_code1                         IN     VARCHAR2,
    x_mrr_code2                         IN     VARCHAR2,
    x_mr_stud_id                        IN     VARCHAR2,
    x_mr_inst_pell_id                   IN     VARCHAR2,
    x_stud_orig_ssn                     IN     VARCHAR2,
    x_orig_name_cd                      IN     VARCHAR2,
    x_inst_pell_id                      IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_addr1                        IN     VARCHAR2,
    x_inst_addr2                        IN     VARCHAR2,
    x_inst_city                         IN     VARCHAR2,
    x_inst_state                        IN     VARCHAR2,
    x_zip_code                          IN     VARCHAR2,
    x_faa_name                          IN     VARCHAR2,
    x_faa_tel                           IN     VARCHAR2,
    x_faa_fax                           IN     VARCHAR2,
    x_faa_internet_addr                 IN     VARCHAR2,
    x_schd_pell_grant                   IN     NUMBER,
    x_orig_awd_amt                      IN     NUMBER,
    x_tran_num                          IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_enrl_dt                           IN     DATE,
    x_orig_creation_dt                  IN     DATE,
    x_disb_accepted_amt                 IN     NUMBER,
    x_last_active_dt                    IN     DATE,
    x_next_est_disb_dt                  IN     DATE,
    x_eligibility_used                  IN     NUMBER,
    x_ed_use_flags                      IN     VARCHAR2,
    x_stud_last_name                    IN     VARCHAR2,
    x_stud_first_name                   IN     VARCHAR2,
    x_stud_middle_name                  IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_mode                              IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 14-DEC-2000
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
      x_mrr_id                            => x_mrr_id,
      x_record_type                       => x_record_type,
      x_req_inst_pell_id                  => x_req_inst_pell_id,
      x_mrr_code1                         => x_mrr_code1,
      x_mrr_code2                         => x_mrr_code2,
      x_mr_stud_id                        => x_mr_stud_id,
      x_mr_inst_pell_id                   => x_mr_inst_pell_id,
      x_stud_orig_ssn                     => x_stud_orig_ssn,
      x_orig_name_cd                      => x_orig_name_cd,
      x_inst_pell_id                      => x_inst_pell_id,
      x_inst_name                         => x_inst_name,
      x_inst_addr1                        => x_inst_addr1,
      x_inst_addr2                        => x_inst_addr2,
      x_inst_city                         => x_inst_city,
      x_inst_state                        => x_inst_state,
      x_zip_code                          => x_zip_code,
      x_faa_name                          => x_faa_name,
      x_faa_tel                           => x_faa_tel,
      x_faa_fax                           => x_faa_fax,
      x_faa_internet_addr                 => x_faa_internet_addr,
      x_schd_pell_grant                   => x_schd_pell_grant,
      x_orig_awd_amt                      => x_orig_awd_amt,
      x_tran_num                          => x_tran_num,
      x_efc                               => x_efc,
      x_enrl_dt                           => x_enrl_dt,
      x_orig_creation_dt                  => x_orig_creation_dt,
      x_disb_accepted_amt                 => x_disb_accepted_amt,
      x_last_active_dt                    => x_last_active_dt,
      x_next_est_disb_dt                  => x_next_est_disb_dt,
      x_eligibility_used                  => x_eligibility_used,
      x_ed_use_flags                      => x_ed_use_flags,
      x_stud_last_name                    => x_stud_last_name,
      x_stud_first_name                   => x_stud_first_name,
      x_stud_middle_name                  => x_stud_middle_name,
      x_stud_dob                          => x_stud_dob,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_current_ssn                       => x_current_ssn
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

    UPDATE igf_gr_mrr_all
      SET
        record_type                       = new_references.record_type,
        req_inst_pell_id                  = new_references.req_inst_pell_id,
        mrr_code1                         = new_references.mrr_code1,
        mrr_code2                         = new_references.mrr_code2,
        mr_stud_id                        = new_references.mr_stud_id,
        mr_inst_pell_id                   = new_references.mr_inst_pell_id,
        stud_orig_ssn                     = new_references.stud_orig_ssn,
        orig_name_cd                      = new_references.orig_name_cd,
        inst_pell_id                      = new_references.inst_pell_id,
        inst_name                         = new_references.inst_name,
        inst_addr1                        = new_references.inst_addr1,
        inst_addr2                        = new_references.inst_addr2,
        inst_city                         = new_references.inst_city,
        inst_state                        = new_references.inst_state,
        zip_code                          = new_references.zip_code,
        faa_name                          = new_references.faa_name,
        faa_tel                           = new_references.faa_tel,
        faa_fax                           = new_references.faa_fax,
        faa_internet_addr                 = new_references.faa_internet_addr,
        schd_pell_grant                   = new_references.schd_pell_grant,
        orig_awd_amt                      = new_references.orig_awd_amt,
        tran_num                          = new_references.tran_num,
        efc                               = new_references.efc,
        enrl_dt                           = new_references.enrl_dt,
        orig_creation_dt                  = new_references.orig_creation_dt,
        disb_accepted_amt                 = new_references.disb_accepted_amt,
        last_active_dt                    = new_references.last_active_dt,
        next_est_disb_dt                  = new_references.next_est_disb_dt,
        eligibility_used                  = new_references.eligibility_used,
        ed_use_flags                      = new_references.ed_use_flags,
        stud_last_name                    = new_references.stud_last_name,
        stud_first_name                   = new_references.stud_first_name,
        stud_middle_name                  = new_references.stud_middle_name,
        stud_dob                          = new_references.stud_dob,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        current_ssn                       = x_current_ssn
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_mrr_id                            IN OUT NOCOPY NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_req_inst_pell_id                  IN     VARCHAR2,
    x_mrr_code1                         IN     VARCHAR2,
    x_mrr_code2                         IN     VARCHAR2,
    x_mr_stud_id                        IN     VARCHAR2,
    x_mr_inst_pell_id                   IN     VARCHAR2,
    x_stud_orig_ssn                     IN     VARCHAR2,
    x_orig_name_cd                      IN     VARCHAR2,
    x_inst_pell_id                      IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_addr1                        IN     VARCHAR2,
    x_inst_addr2                        IN     VARCHAR2,
    x_inst_city                         IN     VARCHAR2,
    x_inst_state                        IN     VARCHAR2,
    x_zip_code                          IN     VARCHAR2,
    x_faa_name                          IN     VARCHAR2,
    x_faa_tel                           IN     VARCHAR2,
    x_faa_fax                           IN     VARCHAR2,
    x_faa_internet_addr                 IN     VARCHAR2,
    x_schd_pell_grant                   IN     NUMBER,
    x_orig_awd_amt                      IN     NUMBER,
    x_tran_num                          IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_enrl_dt                           IN     DATE,
    x_orig_creation_dt                  IN     DATE,
    x_disb_accepted_amt                 IN     NUMBER,
    x_last_active_dt                    IN     DATE,
    x_next_est_disb_dt                  IN     DATE,
    x_eligibility_used                  IN     NUMBER,
    x_ed_use_flags                      IN     VARCHAR2,
    x_stud_last_name                    IN     VARCHAR2,
    x_stud_first_name                   IN     VARCHAR2,
    x_stud_middle_name                  IN     VARCHAR2,
    x_stud_dob                          IN     DATE,
    x_mode                              IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_gr_mrr_all
      WHERE    mrr_id                            = x_mrr_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_mrr_id,
        x_record_type,
        x_req_inst_pell_id,
        x_mrr_code1,
        x_mrr_code2,
        x_mr_stud_id,
        x_mr_inst_pell_id,
        x_stud_orig_ssn,
        x_orig_name_cd,
        x_inst_pell_id,
        x_inst_name,
        x_inst_addr1,
        x_inst_addr2,
        x_inst_city,
        x_inst_state,
        x_zip_code,
        x_faa_name,
        x_faa_tel,
        x_faa_fax,
        x_faa_internet_addr,
        x_schd_pell_grant,
        x_orig_awd_amt,
        x_tran_num,
        x_efc,
        x_enrl_dt,
        x_orig_creation_dt,
        x_disb_accepted_amt,
        x_last_active_dt,
        x_next_est_disb_dt,
        x_eligibility_used,
        x_ed_use_flags,
        x_stud_last_name,
        x_stud_first_name,
        x_stud_middle_name,
        x_stud_dob,
        x_mode,
        x_current_ssn
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_mrr_id,
      x_record_type,
      x_req_inst_pell_id,
      x_mrr_code1,
      x_mrr_code2,
      x_mr_stud_id,
      x_mr_inst_pell_id,
      x_stud_orig_ssn,
      x_orig_name_cd,
      x_inst_pell_id,
      x_inst_name,
      x_inst_addr1,
      x_inst_addr2,
      x_inst_city,
      x_inst_state,
      x_zip_code,
      x_faa_name,
      x_faa_tel,
      x_faa_fax,
      x_faa_internet_addr,
      x_schd_pell_grant,
      x_orig_awd_amt,
      x_tran_num,
      x_efc,
      x_enrl_dt,
      x_orig_creation_dt,
      x_disb_accepted_amt,
      x_last_active_dt,
      x_next_est_disb_dt,
      x_eligibility_used,
      x_ed_use_flags,
      x_stud_last_name,
      x_stud_first_name,
      x_stud_middle_name,
      x_stud_dob,
      x_mode,
      x_current_ssn
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 14-DEC-2000
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

    DELETE FROM igf_gr_mrr_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_gr_mrr_pkg;

/
