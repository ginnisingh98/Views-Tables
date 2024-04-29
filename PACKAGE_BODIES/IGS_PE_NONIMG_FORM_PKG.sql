--------------------------------------------------------
--  DDL for Package Body IGS_PE_NONIMG_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_NONIMG_FORM_PKG" AS
/* $Header: IGSNIA7B.pls 120.2 2006/02/17 06:56:03 gmaheswa ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_nonimg_form%ROWTYPE;
  new_references igs_pe_nonimg_form%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_nonimg_form_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_acad_term_length                  IN     VARCHAR2,
    x_tuition_amt                       IN     NUMBER,
    x_living_exp_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_issue_reason                      IN     VARCHAR2,
    x_commuter_ind                      IN     VARCHAR2,
    x_english_reqd                      IN     VARCHAR2,
    x_length_of_study                   IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_primary_major                     IN     VARCHAR2,
    x_education_level                   IN     VARCHAR2,
    x_educ_lvl_remarks                  IN     VARCHAR2,
    x_depdnt_exp_amt                    IN     NUMBER,
    x_other_exp_amt                     IN     NUMBER,
    x_other_exp_desc                    IN     VARCHAR2,
    x_school_funds_amt                  IN     NUMBER,
    x_school_funds_desc                 IN     VARCHAR2,
    x_other_funds_amt                   IN     NUMBER,
    x_other_funds_desc                  IN     VARCHAR2,
    x_empl_funds_amt                    IN     NUMBER,
    x_remarks                           IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_curr_session_end_date             IN     DATE,
    x_next_session_start_date           IN     DATE,
    x_transfer_from_school              IN     VARCHAR2,
    x_other_reason                      IN     VARCHAR2,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_secondary_major                   IN     VARCHAR2,
    x_minor                             IN     VARCHAR2,
    x_english_reqd_met                  IN     VARCHAR2,
    x_not_reqd_reason                   IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_last_session_flag                 IN     VARCHAR2,
    x_adjudicated_flag                  IN     VARCHAR2,
    x_sevis_school_id                   IN     NUMBER
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
      FROM     igs_pe_nonimg_form
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
    new_references.nonimg_form_id                    := x_nonimg_form_id;
    new_references.person_id                         := x_person_id;
    new_references.print_form                        := x_print_form;
    new_references.form_effective_date               := x_form_effective_date;
    new_references.form_status                       := x_form_status;
    new_references.acad_term_length                  := x_acad_term_length;
    new_references.tuition_amt                       := x_tuition_amt;
    new_references.living_exp_amt                    := x_living_exp_amt;
    new_references.personal_funds_amt                := x_personal_funds_amt;
    new_references.issue_reason                      := x_issue_reason;
    new_references.commuter_ind                      := x_commuter_ind;
    new_references.english_reqd                      := x_english_reqd;
    new_references.length_of_study                   := x_length_of_study;
    new_references.prgm_start_date                   := x_prgm_start_date;
    new_references.prgm_end_date                     := x_prgm_end_date;
    new_references.primary_major                     := x_primary_major;
    new_references.education_level                   := x_education_level;
    new_references.educ_lvl_remarks                  := x_educ_lvl_remarks;
    new_references.depdnt_exp_amt                    := x_depdnt_exp_amt;
    new_references.other_exp_amt                     := x_other_exp_amt;
    new_references.other_exp_desc                    := x_other_exp_desc;
    new_references.school_funds_amt                  := x_school_funds_amt;
    new_references.school_funds_desc                 := x_school_funds_desc;
    new_references.other_funds_amt                   := x_other_funds_amt;
    new_references.other_funds_desc                  := x_other_funds_desc;
    new_references.empl_funds_amt                    := x_empl_funds_amt;
    new_references.remarks                           := x_remarks;
    new_references.visa_type                         := x_visa_type;
    new_references.curr_session_end_date             := x_curr_session_end_date;
    new_references.next_session_start_date           := x_next_session_start_date;
    new_references.transfer_from_school              := x_transfer_from_school;
    new_references.other_reason                      := x_other_reason;
    new_references.last_reprint_date                 := x_last_reprint_date;
    new_references.reprint_reason                    := x_reprint_reason;
    new_references.reprint_remarks                   := x_reprint_remarks;
    new_references.secondary_major                   := x_secondary_major;
    new_references.minor                             := x_minor;
    new_references.english_reqd_met                  := x_english_reqd_met;
    new_references.not_reqd_reason                   := x_not_reqd_reason;
    new_references.last_session_flag                 := x_last_session_flag;
    new_references.adjudicated_flag		     :=	x_adjudicated_flag;
    new_references.SEVIS_SCHOOL_IDENTIFIER                   :=	x_sevis_school_id;

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


  PROCEDURE afterrowinsertupdate(p_insert BOOLEAN ,p_update BOOLEAN) AS
  /*************************************************************
  Created By : masehgal.
  Date Created By : 07/Dec/2002
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     CURSOR per_type(cp_system_type igs_pe_person_types.system_type%TYPE,cp_closed_ind igs_pe_person_types.closed_ind%TYPE)IS
        SELECT person_type_code
        FROM   igs_pe_person_types
        WHERE  system_type = cp_system_type                                        --'NONIMG_STUDENT'
        AND    closed_ind = cp_closed_ind;                                         --'N';

     CURSOR person_type(cp_system_type igs_pe_person_types.system_type%TYPE)IS
        SELECT typ.rowid,typ.*
        FROM   igs_pe_typ_instances_all typ , igs_pe_person_types per_typ
        WHERE  per_typ.system_type = cp_system_type                               --'NONIMG_STUDENT'
        AND    typ.person_id = new_references.person_id
        AND    typ.person_type_code = per_typ.person_type_code
        AND    typ.end_date IS NULL ;

   l_person_type       person_type%ROWTYPE;
   l_per_type          per_type%ROWTYPE;
   lv_rowid            VARCHAR2(25);
   l_type_instance_id  NUMBER(15);

  BEGIN
   OPEN  per_type('NONIMG_STUDENT','N');
   FETCH per_type INTO l_per_type;
   IF per_type%FOUND THEN
      IF p_insert = TRUE THEN
         igs_pe_typ_instances_pkg.insert_row
                (
                 x_rowid                        => lv_rowid,
                 x_person_id                    => new_references.person_id,
                 x_course_cd                    => null,
                 x_type_instance_id             => l_type_instance_id,
                 x_person_type_code             => l_per_type.person_type_code,
                 x_cc_version_number            => null,
                 x_funnel_status                => null,
                 x_admission_appl_number        => null,
                 x_nominated_course_cd          => null,
                 x_ncc_version_number           => null,
                 x_sequence_number              => null,
                 x_start_date                   => new_references.form_effective_date,
                 x_end_date                     => null,
                 x_create_method                => 'CREATE_NONIMG_STUDENT',
                 x_ended_by                     => null,
                 x_end_method                   => null,
                 x_org_id                       => null,
                 x_emplmnt_category_code        => null
                 );

      ELSIF p_update = TRUE THEN
         IF     (new_references.form_effective_date <> old_references.form_effective_date )  THEN
                 OPEN  person_type('NONIMG_STUDENT');
                 FETCH person_type INTO l_person_type;
                 CLOSE person_type;
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
                   x_start_date                   => new_references.form_effective_date,
                   x_end_date                     => l_person_type.end_date,
                   x_create_method                => l_person_type.create_method,
                   x_ended_by                     => l_person_type.ended_by,
                   x_end_method                   => l_person_type.end_method,
                   x_emplmnt_category_code        => l_person_type.emplmnt_category_code
                 );
         END IF;
      END IF;
      CLOSE per_type;
   END IF;
 END afterrowinsertupdate;


 PROCEDURE del_per_inst AS
  /*************************************************************
  Created By : masehgal.
  Date Created By : 07/Dec/2002
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     CURSOR c_per_inst_rowids ( cp_person_id   igs_pe_typ_instances_all.person_ID%TYPE,cp_create_method igs_pe_typ_instances_all.create_method%TYPE ) IS
        SELECT rowid
        FROM   igs_pe_typ_instances_all
        WHERE  person_id = cp_person_id
        AND    create_method = cp_create_method      --'CREATE_NONIMG_STUDENT'
        AND    end_method IS NULL ;

     l_per_inst_rowid      c_per_inst_rowids%ROWTYPE ; --igs_pe_typ_instances_all.row_id%TYPE;

  BEGIN

     FOR l_per_inst_rowid IN c_per_inst_rowids ( old_references.person_id,'CREATE_NONIMG_STUDENT')
     LOOP

         igs_pe_typ_instances_pkg.delete_row ( x_rowid => l_per_inst_rowid.rowid ) ;

     END LOOP ;
  END del_per_inst;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_pe_nonimg_empl_pkg.get_fk_igs_pe_nonimg_form ( old_references.nonimg_form_id );

    igs_pe_nonimg_stat_pkg.get_fk_igs_pe_nonimg_form ( old_references.nonimg_form_id );

  END check_child_existance;


  PROCEDURE check_parent_existance AS
  /*************************************************************
  Created By : masehgal.
  Date Created By : 07/Dec/2002
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
     IF    (((old_references.person_id = new_references.person_id))
        OR ((new_references.person_id IS NULL))) THEN
           NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.Get_PK_For_Validation ( new_references.person_id )  THEN
        FND_MESSAGE.SET_NAME ('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation ( x_nonimg_form_id    IN     NUMBER   ) RETURN BOOLEAN AS
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
      FROM     igs_pe_nonimg_form
      WHERE    nonimg_form_id = x_nonimg_form_id
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
    x_nonimg_form_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_acad_term_length                  IN     VARCHAR2,
    x_tuition_amt                       IN     NUMBER,
    x_living_exp_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_issue_reason                      IN     VARCHAR2,
    x_commuter_ind                      IN     VARCHAR2,
    x_english_reqd                      IN     VARCHAR2,
    x_length_of_study                   IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_primary_major                     IN     VARCHAR2,
    x_education_level                   IN     VARCHAR2,
    x_educ_lvl_remarks                  IN     VARCHAR2,
    x_depdnt_exp_amt                    IN     NUMBER,
    x_other_exp_amt                     IN     NUMBER,
    x_other_exp_desc                    IN     VARCHAR2,
    x_school_funds_amt                  IN     NUMBER,
    x_school_funds_desc                 IN     VARCHAR2,
    x_other_funds_amt                   IN     NUMBER,
    x_other_funds_desc                  IN     VARCHAR2,
    x_empl_funds_amt                    IN     NUMBER,
    x_remarks                           IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_curr_session_end_date             IN     DATE,
    x_next_session_start_date           IN     DATE,
    x_transfer_from_school              IN     VARCHAR2,
    x_other_reason                      IN     VARCHAR2,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_secondary_major                   IN     VARCHAR2,
    x_minor                             IN     VARCHAR2,
    x_english_reqd_met                  IN     VARCHAR2,
    x_not_reqd_reason                   IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_last_session_flag			IN     VARCHAR2,
    x_adjudicated_flag			IN     VARCHAR2,
    x_sevis_school_id                   IN     NUMBER
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
      x_nonimg_form_id,
      x_person_id,
      x_print_form,
      x_form_effective_date,
      x_form_status,
      x_acad_term_length,
      x_tuition_amt,
      x_living_exp_amt,
      x_personal_funds_amt,
      x_issue_reason,
      x_commuter_ind,
      x_english_reqd,
      x_length_of_study,
      x_prgm_start_date,
      x_prgm_end_date,
      x_primary_major,
      x_education_level,
      x_educ_lvl_remarks,
      x_depdnt_exp_amt,
      x_other_exp_amt,
      x_other_exp_desc,
      x_school_funds_amt,
      x_school_funds_desc,
      x_other_funds_amt,
      x_other_funds_desc,
      x_empl_funds_amt,
      x_remarks,
      x_visa_type,
      x_curr_session_end_date,
      x_next_session_start_date,
      x_transfer_from_school,
      x_other_reason,
      x_last_reprint_date,
      x_reprint_reason,
      x_reprint_remarks,
      x_secondary_major,
      x_minor,
      x_english_reqd_met,
      x_not_reqd_reason,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_last_session_flag,
      x_adjudicated_flag,
      x_sevis_school_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation( new_references.nonimg_form_id ) ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation ( new_references.nonimg_form_id ) ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_nonimg_form_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_acad_term_length                  IN     VARCHAR2,
    x_tuition_amt                       IN     NUMBER,
    x_living_exp_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_issue_reason                      IN     VARCHAR2,
    x_commuter_ind                      IN     VARCHAR2,
    x_english_reqd                      IN     VARCHAR2,
    x_length_of_study                   IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_primary_major                     IN     VARCHAR2,
    x_education_level                   IN     VARCHAR2,
    x_educ_lvl_remarks                  IN     VARCHAR2,
    x_depdnt_exp_amt                    IN     NUMBER,
    x_other_exp_amt                     IN     NUMBER,
    x_other_exp_desc                    IN     VARCHAR2,
    x_school_funds_amt                  IN     NUMBER,
    x_school_funds_desc                 IN     VARCHAR2,
    x_other_funds_amt                   IN     NUMBER,
    x_other_funds_desc                  IN     VARCHAR2,
    x_empl_funds_amt                    IN     NUMBER,
    x_remarks                           IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_curr_session_end_date             IN     DATE,
    x_next_session_start_date           IN     DATE,
    x_transfer_from_school              IN     VARCHAR2,
    x_other_reason                      IN     VARCHAR2,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_secondary_major                   IN     VARCHAR2,
    x_minor                             IN     VARCHAR2,
    x_english_reqd_met                  IN     VARCHAR2,
    x_not_reqd_reason                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_last_session_flag			IN     VARCHAR2,
    x_adjudicated_flag			IN     VARCHAR2,
    x_sevis_school_id			IN     NUMBER
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
      x_nonimg_form_id                    => x_nonimg_form_id,
      x_person_id                         => x_person_id,
      x_print_form                        => x_print_form,
      x_form_effective_date               => x_form_effective_date,
      x_form_status                       => x_form_status,
      x_acad_term_length                  => x_acad_term_length,
      x_tuition_amt                       => x_tuition_amt,
      x_living_exp_amt                    => x_living_exp_amt,
      x_personal_funds_amt                => x_personal_funds_amt,
      x_issue_reason                      => x_issue_reason,
      x_commuter_ind                      => x_commuter_ind,
      x_english_reqd                      => x_english_reqd,
      x_length_of_study                   => x_length_of_study,
      x_prgm_start_date                   => x_prgm_start_date,
      x_prgm_end_date                     => x_prgm_end_date,
      x_primary_major                     => x_primary_major,
      x_education_level                   => x_education_level,
      x_educ_lvl_remarks                  => x_educ_lvl_remarks,
      x_depdnt_exp_amt                    => x_depdnt_exp_amt,
      x_other_exp_amt                     => x_other_exp_amt,
      x_other_exp_desc                    => x_other_exp_desc,
      x_school_funds_amt                  => x_school_funds_amt,
      x_school_funds_desc                 => x_school_funds_desc,
      x_other_funds_amt                   => x_other_funds_amt,
      x_other_funds_desc                  => x_other_funds_desc,
      x_empl_funds_amt                    => x_empl_funds_amt,
      x_remarks                           => x_remarks,
      x_visa_type                         => x_visa_type,
      x_curr_session_end_date             => x_curr_session_end_date,
      x_next_session_start_date           => x_next_session_start_date,
      x_transfer_from_school              => x_transfer_from_school,
      x_other_reason                      => x_other_reason,
      x_last_reprint_date                 => x_last_reprint_date,
      x_reprint_reason                    => x_reprint_reason,
      x_reprint_remarks                   => x_reprint_remarks,
      x_secondary_major                   => x_secondary_major,
      x_minor                             => x_minor,
      x_english_reqd_met                  => x_english_reqd_met,
      x_not_reqd_reason                   => x_not_reqd_reason,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_last_session_flag		  => x_last_session_flag,
      x_adjudicated_flag		  => x_adjudicated_flag,
      x_sevis_school_id			  => x_sevis_school_id
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_nonimg_form (
      nonimg_form_id,
      person_id,
      print_form,
      form_effective_date,
      form_status,
      acad_term_length,
      tuition_amt,
      living_exp_amt,
      personal_funds_amt,
      issue_reason,
      commuter_ind,
      english_reqd,
      length_of_study,
      prgm_start_date,
      prgm_end_date,
      primary_major,
      education_level,
      educ_lvl_remarks,
      depdnt_exp_amt,
      other_exp_amt,
      other_exp_desc,
      school_funds_amt,
      school_funds_desc,
      other_funds_amt,
      other_funds_desc,
      empl_funds_amt,
      remarks,
      visa_type,
      curr_session_end_date,
      next_session_start_date,
      transfer_from_school,
      other_reason,
      last_reprint_date,
      reprint_reason,
      reprint_remarks,
      secondary_major,
      minor,
      english_reqd_met,
      not_reqd_reason,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      last_session_flag,
      adjudicated_flag,
      SEVIS_SCHOOL_IDENTIFIER
    ) VALUES (
      igs_pe_nonimg_form_s.NEXTVAL,
      new_references.person_id,
      new_references.print_form,
      new_references.form_effective_date,
      new_references.form_status,
      new_references.acad_term_length,
      new_references.tuition_amt,
      new_references.living_exp_amt,
      new_references.personal_funds_amt,
      new_references.issue_reason,
      new_references.commuter_ind,
      new_references.english_reqd,
      new_references.length_of_study,
      new_references.prgm_start_date,
      new_references.prgm_end_date,
      new_references.primary_major,
      new_references.education_level,
      new_references.educ_lvl_remarks,
      new_references.depdnt_exp_amt,
      new_references.other_exp_amt,
      new_references.other_exp_desc,
      new_references.school_funds_amt,
      new_references.school_funds_desc,
      new_references.other_funds_amt,
      new_references.other_funds_desc,
      new_references.empl_funds_amt,
      new_references.remarks,
      new_references.visa_type,
      new_references.curr_session_end_date,
      new_references.next_session_start_date,
      new_references.transfer_from_school,
      new_references.other_reason,
      new_references.last_reprint_date,
      new_references.reprint_reason,
      new_references.reprint_remarks,
      new_references.secondary_major,
      new_references.minor,
      new_references.english_reqd_met,
      new_references.not_reqd_reason,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.last_session_flag,
      new_references.adjudicated_flag,
      new_references.SEVIS_SCHOOL_IDENTIFIER
    ) RETURNING ROWID, nonimg_form_id INTO x_rowid, x_nonimg_form_id;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


   afterrowinsertupdate(TRUE,FALSE);


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
    x_nonimg_form_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_acad_term_length                  IN     VARCHAR2,
    x_tuition_amt                       IN     NUMBER,
    x_living_exp_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_issue_reason                      IN     VARCHAR2,
    x_commuter_ind                      IN     VARCHAR2,
    x_english_reqd                      IN     VARCHAR2,
    x_length_of_study                   IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_primary_major                     IN     VARCHAR2,
    x_education_level                   IN     VARCHAR2,
    x_educ_lvl_remarks                  IN     VARCHAR2,
    x_depdnt_exp_amt                    IN     NUMBER,
    x_other_exp_amt                     IN     NUMBER,
    x_other_exp_desc                    IN     VARCHAR2,
    x_school_funds_amt                  IN     NUMBER,
    x_school_funds_desc                 IN     VARCHAR2,
    x_other_funds_amt                   IN     NUMBER,
    x_other_funds_desc                  IN     VARCHAR2,
    x_empl_funds_amt                    IN     NUMBER,
    x_remarks                           IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_curr_session_end_date             IN     DATE,
    x_next_session_start_date           IN     DATE,
    x_transfer_from_school              IN     VARCHAR2,
    x_other_reason                      IN     VARCHAR2,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_secondary_major                   IN     VARCHAR2,
    x_minor                             IN     VARCHAR2,
    x_english_reqd_met                  IN     VARCHAR2,
    x_not_reqd_reason                   IN     VARCHAR2,
    x_last_session_flag			IN     VARCHAR2,
    x_adjudicated_flag			IN     VARCHAR2,
    x_sevis_school_id			IN     NUMBER
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
        person_id,
        print_form,
        form_effective_date,
        form_status,
        acad_term_length,
        tuition_amt,
        living_exp_amt,
        personal_funds_amt,
        issue_reason,
        commuter_ind,
        english_reqd,
        length_of_study,
        prgm_start_date,
        prgm_end_date,
        primary_major,
        education_level,
        educ_lvl_remarks,
        depdnt_exp_amt,
        other_exp_amt,
        other_exp_desc,
        school_funds_amt,
        school_funds_desc,
        other_funds_amt,
        other_funds_desc,
        empl_funds_amt,
        remarks,
	visa_type,
        curr_session_end_date,
        next_session_start_date,
        transfer_from_school,
        other_reason,
        last_reprint_date,
        reprint_reason,
        reprint_remarks,
        secondary_major,
        minor,
        english_reqd_met,
        not_reqd_reason,
	last_session_flag,
	adjudicated_flag,
	SEVIS_SCHOOL_IDENTIFIER
      FROM  igs_pe_nonimg_form
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
        AND (tlinfo.print_form = x_print_form)
        AND (tlinfo.form_effective_date = x_form_effective_date)
        AND (tlinfo.form_status = x_form_status)
        AND (tlinfo.acad_term_length = x_acad_term_length)
        AND (tlinfo.tuition_amt = x_tuition_amt)
        AND (tlinfo.living_exp_amt = x_living_exp_amt)
        AND (tlinfo.personal_funds_amt = x_personal_funds_amt)
        AND (tlinfo.issue_reason = x_issue_reason)
        AND ((tlinfo.commuter_ind = x_commuter_ind) OR ((tlinfo.commuter_ind IS NULL) AND (X_commuter_ind IS NULL)))
        AND (tlinfo.english_reqd = x_english_reqd)
        AND (tlinfo.length_of_study = x_length_of_study)
        AND (tlinfo.prgm_start_date = x_prgm_start_date)
        AND (tlinfo.prgm_end_date = x_prgm_end_date)
        AND (tlinfo.primary_major = x_primary_major)
        AND (tlinfo.education_level = x_education_level)
        AND ((tlinfo.educ_lvl_remarks = x_educ_lvl_remarks) OR ((tlinfo.educ_lvl_remarks IS NULL) AND (X_educ_lvl_remarks IS NULL)))
        AND ((tlinfo.depdnt_exp_amt = x_depdnt_exp_amt) OR ((tlinfo.depdnt_exp_amt IS NULL) AND (X_depdnt_exp_amt IS NULL)))
        AND ((tlinfo.other_exp_amt = x_other_exp_amt) OR ((tlinfo.other_exp_amt IS NULL) AND (X_other_exp_amt IS NULL)))
        AND ((tlinfo.other_exp_desc = x_other_exp_desc) OR ((tlinfo.other_exp_desc IS NULL) AND (X_other_exp_desc IS NULL)))
        AND ((tlinfo.school_funds_amt = x_school_funds_amt) OR ((tlinfo.school_funds_amt IS NULL) AND (X_school_funds_amt IS NULL)))
        AND ((tlinfo.school_funds_desc = x_school_funds_desc) OR ((tlinfo.school_funds_desc IS NULL) AND (X_school_funds_desc IS NULL)))
        AND ((tlinfo.other_funds_amt = x_other_funds_amt) OR ((tlinfo.other_funds_amt IS NULL) AND (X_other_funds_amt IS NULL)))
        AND ((tlinfo.other_funds_desc = x_other_funds_desc) OR ((tlinfo.other_funds_desc IS NULL) AND (X_other_funds_desc IS NULL)))
        AND ((tlinfo.empl_funds_amt = x_empl_funds_amt) OR ((tlinfo.empl_funds_amt IS NULL) AND (X_empl_funds_amt IS NULL)))
        AND ((tlinfo.remarks = x_remarks) OR ((tlinfo.remarks IS NULL) AND (X_remarks IS NULL)))
        AND ((tlinfo.visa_type = x_visa_type))
        AND ((tlinfo.curr_session_end_date = x_curr_session_end_date) OR ((tlinfo.curr_session_end_date IS NULL) AND (X_curr_session_end_date IS NULL)))
        AND ((tlinfo.next_session_start_date = x_next_session_start_date) OR ((tlinfo.next_session_start_date IS NULL) AND (X_next_session_start_date IS NULL)))
        AND ((tlinfo.transfer_from_school = x_transfer_from_school) OR ((tlinfo.transfer_from_school IS NULL) AND (X_transfer_from_school IS NULL)))
        AND ((tlinfo.other_reason = x_other_reason) OR ((tlinfo.other_reason IS NULL) AND (X_other_reason IS NULL)))
        AND ((tlinfo.last_reprint_date = x_last_reprint_date) OR ((tlinfo.last_reprint_date IS NULL) AND (X_last_reprint_date IS NULL)))
        AND ((tlinfo.reprint_reason = x_reprint_reason) OR ((tlinfo.reprint_reason IS NULL) AND (X_reprint_reason IS NULL)))
        AND ((tlinfo.reprint_remarks = x_reprint_remarks) OR ((tlinfo.reprint_remarks IS NULL) AND (X_reprint_remarks IS NULL)))
        AND ((tlinfo.secondary_major = x_secondary_major) OR ((tlinfo.secondary_major IS NULL) AND (X_secondary_major IS NULL)))
        AND ((tlinfo.minor = x_minor) OR ((tlinfo.minor IS NULL) AND (X_minor IS NULL)))
        AND ((tlinfo.english_reqd_met = x_english_reqd_met) OR ((tlinfo.english_reqd_met IS NULL) AND (X_english_reqd_met IS NULL)))
        AND ((tlinfo.not_reqd_reason = x_not_reqd_reason) OR ((tlinfo.not_reqd_reason IS NULL) AND (X_not_reqd_reason IS NULL)))
        AND ((tlinfo.last_session_flag = x_last_session_flag) OR ((tlinfo.last_session_flag IS NULL) AND (X_last_session_flag IS NULL)))
	AND ((tlinfo.adjudicated_flag = x_adjudicated_flag) OR ((tlinfo.adjudicated_flag IS NULL) AND (X_adjudicated_flag IS NULL)))
        AND ((tlinfo.SEVIS_SCHOOL_IDENTIFIER = x_sevis_school_id) OR ((tlinfo.SEVIS_SCHOOL_IDENTIFIER IS NULL) AND (X_sevis_school_id IS NULL)))
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
    x_nonimg_form_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_acad_term_length                  IN     VARCHAR2,
    x_tuition_amt                       IN     NUMBER,
    x_living_exp_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_issue_reason                      IN     VARCHAR2,
    x_commuter_ind                      IN     VARCHAR2,
    x_english_reqd                      IN     VARCHAR2,
    x_length_of_study                   IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_primary_major                     IN     VARCHAR2,
    x_education_level                   IN     VARCHAR2,
    x_educ_lvl_remarks                  IN     VARCHAR2,
    x_depdnt_exp_amt                    IN     NUMBER,
    x_other_exp_amt                     IN     NUMBER,
    x_other_exp_desc                    IN     VARCHAR2,
    x_school_funds_amt                  IN     NUMBER,
    x_school_funds_desc                 IN     VARCHAR2,
    x_other_funds_amt                   IN     NUMBER,
    x_other_funds_desc                  IN     VARCHAR2,
    x_empl_funds_amt                    IN     NUMBER,
    x_remarks                           IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_curr_session_end_date             IN     DATE,
    x_next_session_start_date           IN     DATE,
    x_transfer_from_school              IN     VARCHAR2,
    x_other_reason                      IN     VARCHAR2,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_secondary_major                   IN     VARCHAR2,
    x_minor                             IN     VARCHAR2,
    x_english_reqd_met                  IN     VARCHAR2,
    x_not_reqd_reason                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_last_session_flag			IN     VARCHAR2,
    x_adjudicated_flag 			IN     VARCHAR2,
    x_sevis_school_id			IN     NUMBER
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
      x_nonimg_form_id                    => x_nonimg_form_id,
      x_person_id                         => x_person_id,
      x_print_form                        => x_print_form,
      x_form_effective_date               => x_form_effective_date,
      x_form_status                       => x_form_status,
      x_acad_term_length                  => x_acad_term_length,
      x_tuition_amt                       => x_tuition_amt,
      x_living_exp_amt                    => x_living_exp_amt,
      x_personal_funds_amt                => x_personal_funds_amt,
      x_issue_reason                      => x_issue_reason,
      x_commuter_ind                      => x_commuter_ind,
      x_english_reqd                      => x_english_reqd,
      x_length_of_study                   => x_length_of_study,
      x_prgm_start_date                   => x_prgm_start_date,
      x_prgm_end_date                     => x_prgm_end_date,
      x_primary_major                     => x_primary_major,
      x_education_level                   => x_education_level,
      x_educ_lvl_remarks                  => x_educ_lvl_remarks,
      x_depdnt_exp_amt                    => x_depdnt_exp_amt,
      x_other_exp_amt                     => x_other_exp_amt,
      x_other_exp_desc                    => x_other_exp_desc,
      x_school_funds_amt                  => x_school_funds_amt,
      x_school_funds_desc                 => x_school_funds_desc,
      x_other_funds_amt                   => x_other_funds_amt,
      x_other_funds_desc                  => x_other_funds_desc,
      x_empl_funds_amt                    => x_empl_funds_amt,
      x_remarks                           => x_remarks,
      x_visa_type                         => x_visa_type,
      x_curr_session_end_date             => x_curr_session_end_date,
      x_next_session_start_date           => x_next_session_start_date,
      x_transfer_from_school              => x_transfer_from_school,
      x_other_reason                      => x_other_reason,
      x_last_reprint_date                 => x_last_reprint_date,
      x_reprint_reason                    => x_reprint_reason,
      x_reprint_remarks                   => x_reprint_remarks,
      x_secondary_major                   => x_secondary_major,
      x_minor                             => x_minor,
      x_english_reqd_met                  => x_english_reqd_met,
      x_not_reqd_reason                   => x_not_reqd_reason,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_last_session_flag		  => x_last_session_flag,
      x_adjudicated_flag		  => x_adjudicated_flag,
      x_sevis_school_id			  => x_sevis_school_id
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_nonimg_form
      SET
        person_id                         = new_references.person_id,
        print_form                        = new_references.print_form,
        form_effective_date               = new_references.form_effective_date,
        form_status                       = new_references.form_status,
        acad_term_length                  = new_references.acad_term_length,
        tuition_amt                       = new_references.tuition_amt,
        living_exp_amt                    = new_references.living_exp_amt,
        personal_funds_amt                = new_references.personal_funds_amt,
        issue_reason                      = new_references.issue_reason,
        commuter_ind                      = new_references.commuter_ind,
        english_reqd                      = new_references.english_reqd,
        length_of_study                   = new_references.length_of_study,
        prgm_start_date                   = new_references.prgm_start_date,
        prgm_end_date                     = new_references.prgm_end_date,
        primary_major                     = new_references.primary_major,
        education_level                   = new_references.education_level,
        educ_lvl_remarks                  = new_references.educ_lvl_remarks,
        depdnt_exp_amt                    = new_references.depdnt_exp_amt,
        other_exp_amt                     = new_references.other_exp_amt,
        other_exp_desc                    = new_references.other_exp_desc,
        school_funds_amt                  = new_references.school_funds_amt,
        school_funds_desc                 = new_references.school_funds_desc,
        other_funds_amt                   = new_references.other_funds_amt,
        other_funds_desc                  = new_references.other_funds_desc,
        empl_funds_amt                    = new_references.empl_funds_amt,
        remarks                           = new_references.remarks,
	visa_type                         = new_references.visa_type,
        curr_session_end_date             = new_references.curr_session_end_date,
        next_session_start_date           = new_references.next_session_start_date,
        transfer_from_school              = new_references.transfer_from_school,
        other_reason                      = new_references.other_reason,
        last_reprint_date                 = new_references.last_reprint_date,
        reprint_reason                    = new_references.reprint_reason,
        reprint_remarks                   = new_references.reprint_remarks,
        secondary_major                   = new_references.secondary_major,
        minor                             = new_references.minor,
        english_reqd_met                  = new_references.english_reqd_met,
        not_reqd_reason                   = new_references.not_reqd_reason,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
	last_session_flag		  = x_last_session_flag,
	adjudicated_flag		  = new_references.adjudicated_flag,
	SEVIS_SCHOOL_IDENTIFIER			  = new_references.SEVIS_SCHOOL_IDENTIFIER
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


    afterrowinsertupdate(FALSE,TRUE);


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
    x_nonimg_form_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_acad_term_length                  IN     VARCHAR2,
    x_tuition_amt                       IN     NUMBER,
    x_living_exp_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_issue_reason                      IN     VARCHAR2,
    x_commuter_ind                      IN     VARCHAR2,
    x_english_reqd                      IN     VARCHAR2,
    x_length_of_study                   IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_primary_major                     IN     VARCHAR2,
    x_education_level                   IN     VARCHAR2,
    x_educ_lvl_remarks                  IN     VARCHAR2,
    x_depdnt_exp_amt                    IN     NUMBER,
    x_other_exp_amt                     IN     NUMBER,
    x_other_exp_desc                    IN     VARCHAR2,
    x_school_funds_amt                  IN     NUMBER,
    x_school_funds_desc                 IN     VARCHAR2,
    x_other_funds_amt                   IN     NUMBER,
    x_other_funds_desc                  IN     VARCHAR2,
    x_empl_funds_amt                    IN     NUMBER,
    x_remarks                           IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_curr_session_end_date             IN     DATE,
    x_next_session_start_date           IN     DATE,
    x_transfer_from_school              IN     VARCHAR2,
    x_other_reason                      IN     VARCHAR2,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_secondary_major                   IN     VARCHAR2,
    x_minor                             IN     VARCHAR2,
    x_english_reqd_met                  IN     VARCHAR2,
    x_not_reqd_reason                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_last_session_flag			IN     VARCHAR2,
    x_adjudicated_flag			IN     VARCHAR2,
    x_sevis_school_id			IN     NUMBER
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
      FROM     igs_pe_nonimg_form
      WHERE    nonimg_form_id                    = x_nonimg_form_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_nonimg_form_id,
        x_person_id,
        x_print_form,
        x_form_effective_date,
        x_form_status,
        x_acad_term_length,
        x_tuition_amt,
        x_living_exp_amt,
        x_personal_funds_amt,
        x_issue_reason,
        x_commuter_ind,
        x_english_reqd,
        x_length_of_study,
        x_prgm_start_date,
        x_prgm_end_date,
        x_primary_major,
        x_education_level,
        x_educ_lvl_remarks,
        x_depdnt_exp_amt,
        x_other_exp_amt,
        x_other_exp_desc,
        x_school_funds_amt,
        x_school_funds_desc,
        x_other_funds_amt,
        x_other_funds_desc,
        x_empl_funds_amt,
        x_remarks,
	x_visa_type,
        x_curr_session_end_date,
        x_next_session_start_date,
        x_transfer_from_school,
        x_other_reason,
        x_last_reprint_date,
        x_reprint_reason,
        x_reprint_remarks,
        x_secondary_major,
        x_minor,
        x_english_reqd_met,
        x_not_reqd_reason,
        x_mode,
	x_last_session_flag,
	x_adjudicated_flag,
	x_sevis_school_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_nonimg_form_id,
      x_person_id,
      x_print_form,
      x_form_effective_date,
      x_form_status,
      x_acad_term_length,
      x_tuition_amt,
      x_living_exp_amt,
      x_personal_funds_amt,
      x_issue_reason,
      x_commuter_ind,
      x_english_reqd,
      x_length_of_study,
      x_prgm_start_date,
      x_prgm_end_date,
      x_primary_major,
      x_education_level,
      x_educ_lvl_remarks,
      x_depdnt_exp_amt,
      x_other_exp_amt,
      x_other_exp_desc,
      x_school_funds_amt,
      x_school_funds_desc,
      x_other_funds_amt,
      x_other_funds_desc,
      x_empl_funds_amt,
      x_remarks,
      x_visa_type,
      x_curr_session_end_date,
      x_next_session_start_date,
      x_transfer_from_school,
      x_other_reason,
      x_last_reprint_date,
      x_reprint_reason,
      x_reprint_remarks,
      x_secondary_major,
      x_minor,
      x_english_reqd_met,
      x_not_reqd_reason,
      x_mode,
      x_last_session_flag,
      x_adjudicated_flag,
      x_sevis_school_id
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
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
 DELETE FROM igs_pe_nonimg_form
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


    del_per_inst ;

  END delete_row;


END igs_pe_nonimg_form_pkg;

/
