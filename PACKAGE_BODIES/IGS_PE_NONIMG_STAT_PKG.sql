--------------------------------------------------------
--  DDL for Package Body IGS_PE_NONIMG_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_NONIMG_STAT_PKG" AS
/* $Header: IGSNIA9B.pls 120.2 2006/02/17 06:56:30 gmaheswa ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_nonimg_stat%ROWTYPE;
  new_references igs_pe_nonimg_stat%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_nonimg_stat_id                    IN     NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_print_flag			IN     VARCHAR2,
    x_cancel_flag			IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_nonimg_stat
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
    new_references.nonimg_stat_id                    := x_nonimg_stat_id;
    new_references.nonimg_form_id                    := x_nonimg_form_id;
    new_references.action_date                       := x_action_date;
    new_references.action_type                       := x_action_type;
    new_references.prgm_start_date                   := x_prgm_start_date;
    new_references.prgm_end_date                     := x_prgm_end_date;
    new_references.remarks                           := x_remarks;
    new_references.termination_reason                := x_termination_reason;

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
    new_references.print_flag	                     := x_print_flag;
    new_references.cancel_flag	                     := x_cancel_flag;
  END set_column_values;


  PROCEDURE upd_form_stat( p_action_type  VARCHAR2) AS
  /*************************************************************
  Created By : masehgal.
  Date Created By : 07/Dec/2002
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  kumma           08-JAN-2003     2739579, Added a parameter of visa_type to igs_pe_nonimg_form_pkg.update_row
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
       DECLARE

         CURSOR person_type(l_person_id  igs_pe_ev_form.person_id%TYPE) IS
            SELECT typ.rowid,typ.*
            FROM   igs_pe_typ_instances_all typ , igs_pe_person_types per_typ
            WHERE  typ.person_id = l_person_id
            AND    per_typ.system_type = 'NONIMG_STUDENT'
            AND    typ.person_type_code = per_typ.person_type_code
            AND    typ.end_date IS NULL ;


         CURSOR c_get_form_values ( cp_nonimg_form_id     igs_pe_nonimg_form.nonimg_form_id%TYPE ) IS
            SELECT form.rowid,form.*
            FROM   igs_pe_nonimg_form form
            WHERE  form.nonimg_form_id = cp_nonimg_form_id ;

            l_form         c_get_form_values%ROWTYPE;
            l_form_status  igs_pe_nonimg_form.form_status%TYPE;
            l_end_date     DATE;
            l_end_method   igs_pe_typ_instances_all.end_method%TYPE;
            lv_userid      NUMBER;
            l_person_type  person_type%ROWTYPE;



       BEGIN
          OPEN  c_get_form_values ( new_references.nonimg_form_id );
          FETCH c_get_form_values INTO l_form;
          CLOSE c_get_form_values;

          IF new_references.action_type = 'C' THEN
             l_form_status := 'C';
          ELSIF new_references.action_type = 'T' THEN
             l_form_status := 'T';
	  ELSIF new_references.action_type = 'CP' THEN
             l_form_status := 'E';
          END IF;
          igs_pe_nonimg_form_pkg.update_row (
                            x_rowid                   => l_form.rowid ,
                            x_nonimg_form_id          => l_form.nonimg_form_id ,
                            x_person_id               => l_form.person_id ,
                            x_print_form              => l_form.print_form ,
                            x_form_effective_date     => l_form.form_effective_date ,
                            x_form_status             => l_form_status ,
                            x_acad_term_length        => l_form.acad_term_length,
                            x_tuition_amt             => l_form.tuition_amt,
                            x_living_exp_amt          => l_form.living_exp_amt,
                            x_personal_funds_amt      => l_form.personal_funds_amt,
                            x_issue_reason            => l_form.issue_reason,
                            x_commuter_ind            => l_form.commuter_ind,
                            x_english_reqd            => l_form.english_reqd,
                            x_length_of_study         => l_form.length_of_study,
                            x_prgm_start_date         => l_form.prgm_start_date,
                            x_prgm_end_date           => l_form.prgm_end_date,
                            x_primary_major           => l_form.primary_major,
                            x_education_level         => l_form.education_level,
                            x_educ_lvl_remarks        => l_form.educ_lvl_remarks,
                            x_depdnt_exp_amt          => l_form.depdnt_exp_amt,
                            x_other_exp_amt           => l_form.other_exp_amt,
                            x_other_exp_desc          => l_form.other_exp_desc,
                            x_school_funds_amt        => l_form.school_funds_amt,
                            x_school_funds_desc       => l_form.school_funds_desc,
                            x_other_funds_amt         => l_form.other_funds_amt,
                            x_other_funds_desc        => l_form.other_funds_desc,
                            x_empl_funds_amt          => l_form.empl_funds_amt,
                            x_remarks                 => l_form.remarks,
			    x_visa_type               => l_form.visa_type,
                            x_curr_session_end_date   => l_form.curr_session_end_date,
                            x_next_session_start_date => l_form.next_session_start_date,
                            x_transfer_from_school    => l_form.transfer_from_school,
                            x_other_reason            => l_form.other_reason,
                            x_last_reprint_date       => l_form.last_reprint_date,
                            x_reprint_reason          => l_form.reprint_reason,
                            x_reprint_remarks         => l_form.reprint_remarks,
                            x_secondary_major         => l_form.secondary_major,
                            x_minor                   => l_form.minor,
                            x_english_reqd_met        => l_form.english_reqd_met,
                            x_not_reqd_reason         => l_form.not_reqd_reason,
                            x_mode                    => 'R',
			    x_last_session_flag       => l_form.last_session_flag,
			    x_adjudicated_flag        => l_form.adjudicated_flag,
			    x_sevis_school_id        =>  l_form.SEVIS_SCHOOL_IDENTIFIER
                            );

          OPEN  person_type(l_form.person_id);
          FETCH person_type INTO l_person_type;
          CLOSE person_type;

          l_end_date   := new_references.action_date;
	       l_end_method := 'END_NONIMG_STUDENT';
          lv_userid    := fnd_global.user_id;

                 igs_pe_typ_instances_pkg.update_row
                 (
                 x_rowid                        => l_person_type.rowid,
                 x_person_id                    => l_person_type.person_id,
                 x_course_cd                    => l_person_type.course_cd,
                 x_type_instance_id             => l_person_type.type_instance_id,
                 x_person_type_code             => l_person_type.person_type_code,
                 x_cc_version_number            => l_person_type.cc_version_number,
                 x_funnel_status                => l_person_type.funnel_status,
                 x_admission_appl_number        => l_person_type.admission_appl_number,
                 x_nominated_course_cd          => l_person_type.nominated_course_cd,
                 x_ncc_version_number           => l_person_type.ncc_version_number,
                 x_sequence_number              => l_person_type.sequence_number,
                 x_start_date                   => l_form.form_effective_date,
                 x_end_date                     => l_end_date ,
                 x_create_method                => l_person_type.create_method,
                 x_ended_by                     => lv_userid,
                 x_end_method                   => l_end_method,
                 x_emplmnt_category_code        => l_person_type.emplmnt_category_code
                 ) ;

       END ;
  END upd_form_stat;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation ( new_references.nonimg_form_id,
                                 new_references.action_type,
                                 new_references.action_date
                               ) ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.nonimg_form_id = new_references.nonimg_form_id)) OR
        ((new_references.nonimg_form_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_nonimg_form_pkg.get_pk_for_validation ( new_references.nonimg_form_id ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation ( x_nonimg_stat_id    IN     NUMBER   ) RETURN BOOLEAN AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_nonimg_stat
      WHERE    nonimg_stat_id = x_nonimg_stat_id
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


  FUNCTION get_uk_for_validation ( x_nonimg_form_id                    IN     NUMBER,
                                   x_action_type                       IN     VARCHAR2,
                                   x_action_date                       IN     DATE
                                 ) RETURN BOOLEAN AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_nonimg_stat
      WHERE    nonimg_form_id = x_nonimg_form_id
      AND      action_type = x_action_type
      AND      action_date = x_action_date
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


  PROCEDURE get_fk_igs_pe_nonimg_form ( x_nonimg_form_id     IN     NUMBER  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_nonimg_stat
      WHERE   ((nonimg_form_id = x_nonimg_form_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_PENST_PENIF_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_nonimg_form;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_nonimg_stat_id                    IN     NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_print_flag			IN     VARCHAR2,
    x_cancel_flag			IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
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
      x_nonimg_stat_id,
      x_nonimg_form_id,
      x_action_date,
      x_action_type,
      x_prgm_start_date,
      x_prgm_end_date,
      x_remarks,
      x_termination_reason,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_print_flag,
      x_cancel_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation( new_references.nonimg_stat_id ) ) THEN
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
      IF ( get_pk_for_validation ( new_references.nonimg_stat_id ) ) THEN
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
    x_nonimg_stat_id                    IN OUT NOCOPY NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_print_flag                        IN     VARCHAR2,
    x_cancel_flag                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_nonimg_stat_id                    => x_nonimg_stat_id,
      x_nonimg_form_id                    => x_nonimg_form_id,
      x_action_date                       => x_action_date,
      x_action_type                       => x_action_type,
      x_prgm_start_date                   => x_prgm_start_date,
      x_prgm_end_date                     => x_prgm_end_date,
      x_remarks                           => x_remarks,
      x_termination_reason                => x_termination_reason,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_print_flag			  => x_print_flag,
      x_cancel_flag			  => x_cancel_flag
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_nonimg_stat (
      nonimg_stat_id,
      nonimg_form_id,
      action_date,
      action_type,
      prgm_start_date,
      prgm_end_date,
      remarks,
      termination_reason,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      print_flag,
      cancel_flag
    ) VALUES (
      igs_pe_nonimg_stat_s.NEXTVAL,
      new_references.nonimg_form_id,
      new_references.action_date,
      new_references.action_type,
      new_references.prgm_start_date,
      new_references.prgm_end_date,
      new_references.remarks,
      new_references.termination_reason,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.print_flag,
      new_references.cancel_flag
    ) RETURNING ROWID, nonimg_stat_id INTO x_rowid, x_nonimg_stat_id;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    IF new_references.action_type IN ('C','T','CP') THEN
       upd_form_stat (new_references.action_type)  ;
    END IF ;


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
    x_nonimg_stat_id                    IN     NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_print_flag			IN     VARCHAR2,
    x_cancel_flag			IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        nonimg_form_id,
        action_date,
        action_type,
        prgm_start_date,
        prgm_end_date,
        remarks,
        termination_reason,
	print_flag,
	cancel_flag
      FROM  igs_pe_nonimg_stat
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
        (tlinfo.nonimg_form_id = x_nonimg_form_id)
        AND (tlinfo.action_date = x_action_date)
        AND (tlinfo.action_type = x_action_type)
        AND ((tlinfo.prgm_start_date = x_prgm_start_date) OR ((tlinfo.prgm_start_date IS NULL) AND (X_prgm_start_date IS NULL)))
        AND ((tlinfo.prgm_end_date = x_prgm_end_date) OR ((tlinfo.prgm_end_date IS NULL) AND (X_prgm_end_date IS NULL)))
        AND ((tlinfo.remarks = x_remarks) OR ((tlinfo.remarks IS NULL) AND (X_remarks IS NULL)))
        AND ((tlinfo.termination_reason = x_termination_reason) OR ((tlinfo.termination_reason IS NULL) AND (X_termination_reason IS NULL)))
        AND ((tlinfo.print_flag = x_print_flag) OR ((tlinfo.print_flag IS NULL) AND (X_print_flag IS NULL)))
	AND ((tlinfo.cancel_flag = x_cancel_flag) OR ((tlinfo.cancel_flag IS NULL) AND (X_cancel_flag IS NULL)))
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
    x_nonimg_stat_id                    IN     NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_print_flag                        IN     VARCHAR2,
    x_cancel_flag                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
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
      x_nonimg_stat_id                    => x_nonimg_stat_id,
      x_nonimg_form_id                    => x_nonimg_form_id,
      x_action_date                       => x_action_date,
      x_action_type                       => x_action_type,
      x_prgm_start_date                   => x_prgm_start_date,
      x_prgm_end_date                     => x_prgm_end_date,
      x_remarks                           => x_remarks,
      x_termination_reason                => x_termination_reason,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_print_flag			  => x_print_flag,
      x_cancel_flag			  => x_cancel_flag
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_nonimg_stat
      SET
        nonimg_form_id                    = new_references.nonimg_form_id,
        action_date                       = new_references.action_date,
        action_type                       = new_references.action_type,
        prgm_start_date                   = new_references.prgm_start_date,
        prgm_end_date                     = new_references.prgm_end_date,
        remarks                           = new_references.remarks,
        termination_reason                = new_references.termination_reason,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
	print_flag			  = x_print_flag,
	cancel_flag			  = x_cancel_flag
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
    x_nonimg_stat_id                    IN OUT NOCOPY NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_print_flag			IN     VARCHAR2,
    x_cancel_flag			IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_nonimg_stat
      WHERE    nonimg_stat_id    = x_nonimg_stat_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_nonimg_stat_id,
        x_nonimg_form_id,
        x_action_date,
        x_action_type,
        x_prgm_start_date,
        x_prgm_end_date,
        x_remarks,
        x_termination_reason,
        x_mode ,
	x_print_flag,
	x_cancel_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_nonimg_stat_id,
      x_nonimg_form_id,
      x_action_date,
      x_action_type,
      x_prgm_start_date,
      x_prgm_end_date,
      x_remarks,
      x_termination_reason,
      x_mode ,
      x_print_flag,
      x_cancel_flag
    );

  END add_row;


  PROCEDURE delete_row ( x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2   ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
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
 DELETE FROM igs_pe_nonimg_stat
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


END igs_pe_nonimg_stat_pkg;

/
