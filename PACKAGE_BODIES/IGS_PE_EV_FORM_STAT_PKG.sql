--------------------------------------------------------
--  DDL for Package Body IGS_PE_EV_FORM_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_EV_FORM_STAT_PKG" AS
/* $Header: IGSNIA6B.pls 120.2 2006/02/17 06:57:13 gmaheswa ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_ev_form_stat%ROWTYPE;
  new_references igs_pe_ev_form_stat%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ev_form_stat_id                   IN     NUMBER,
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_end_program_reason                IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
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
      FROM     igs_pe_ev_form_stat
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
    new_references.ev_form_stat_id                   := x_ev_form_stat_id;
    new_references.ev_form_id                        := x_ev_form_id;
    new_references.action_date                       := x_action_date;
    new_references.action_type                       := x_action_type;
    new_references.prgm_start_date                   := x_prgm_start_date;
    new_references.prgm_end_date                     := x_prgm_end_date;
    new_references.remarks                           := x_remarks;
    new_references.termination_reason                := x_termination_reason;
    new_references.end_program_reason                := x_end_program_reason;

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

   CURSOR person_type(l_person_id  igs_pe_ev_form.person_id%TYPE) IS
   SELECT typ.rowid,typ.* FROM
   igs_pe_typ_instances_all typ , igs_pe_person_types per_typ
   WHERE
   typ.person_id = l_person_id AND
   per_typ.system_type = 'EXCHG_VISITOR' AND
   typ.person_type_code = per_typ.person_type_code AND
   typ.end_date IS NULL ;

   l_person_type person_type%ROWTYPE;
   l_end_date DATE;
   l_end_method igs_pe_typ_instances_all.end_method%TYPE;
   lv_userid NUMBER := NULL;

  BEGIN
     IF p_insert = TRUE THEN
          IF new_references.action_type IN ('ED','TR') THEN
             DECLARE
             CURSOR ev_form IS
             SELECT a.rowid,a.* FROM IGS_PE_EV_FORM a
             WHERE a.ev_form_id = new_references.ev_form_id;
             l_ev_form ev_form%ROWTYPE;
             l_form_status igs_pe_ev_form.form_status%TYPE;
             BEGIN
                OPEN ev_form;
                FETCH ev_form INTO l_ev_form;
                CLOSE ev_form;
                IF new_references.action_type = 'ED' THEN
                   l_form_status := 'C';
                ELSIF new_references.action_type = 'TR' THEN
                   l_form_status := 'T';
                END IF;
                igs_pe_ev_form_pkg.update_row (
                    x_rowid                          => l_ev_form.rowid ,
                    x_ev_form_id                     => l_ev_form.ev_form_id ,
                    x_person_id                      => l_ev_form.person_id ,
                    x_print_form                     => l_ev_form.print_form ,
                    x_form_effective_date            => l_ev_form.form_effective_date ,
                    x_form_status                    => l_form_status ,
                    x_create_reason                  => l_ev_form.create_reason ,
                    x_is_valid                       => l_ev_form.is_valid ,
                    x_prgm_sponsor_amt               => l_ev_form.prgm_sponsor_amt ,
                    x_govt_org1_amt                  => l_ev_form.govt_org1_amt ,
                    x_govt_org1_code                 => l_ev_form.govt_org1_code ,
                    x_govt_org2_amt                  => l_ev_form.govt_org2_amt ,
                    x_govt_org2_code                 => l_ev_form.govt_org2_code ,
                    x_intl_org1_amt                  => l_ev_form.intl_org1_amt  ,
                    x_intl_org1_code                 => l_ev_form.intl_org1_code ,
                    x_intl_org2_amt                  => l_ev_form.intl_org2_amt  ,
                    x_intl_org2_code                 => l_ev_form.intl_org2_code ,
                    x_ev_govt_amt                    => l_ev_form.ev_govt_amt ,
                    x_bi_natnl_com_amt               => l_ev_form.bi_natnl_com_amt ,
                    x_other_govt_amt                 => l_ev_form.other_govt_amt ,
                    x_personal_funds_amt             => l_ev_form.personal_funds_amt ,
                    x_ev_form_number                 => l_ev_form.ev_form_number ,
                    x_prgm_start_date                => l_ev_form.prgm_start_date ,
                    x_prgm_end_date                  => l_ev_form.prgm_end_date  ,
                    x_last_reprint_date              => l_ev_form.last_reprint_date ,
                    x_reprint_reason                 => l_ev_form.reprint_reason ,
                    x_reprint_remarks                => l_ev_form.reprint_remarks ,
                    x_position_code                  => l_ev_form.position_code ,
                    x_position_remarks               => l_ev_form.position_remarks ,
                    x_subject_field_code             => l_ev_form.subject_field_code ,
                    x_subject_field_remarks          => l_ev_form.subject_field_remarks ,
                    x_matriculation                  => l_ev_form.matriculation  ,
                    x_remarks                        => l_ev_form.remarks  ,
                    x_mode                           => 'R',
                    x_category_code                  => l_ev_form.category_code,
                    x_init_prgm_start_date           => l_ev_form.init_prgm_start_date,
		    x_govt_org1_othr_name	     => l_ev_form.govt_org1_othr_name,
		    x_govt_org2_othr_name            => l_ev_form.govt_org2_othr_name,
		    x_intl_org1_othr_name            => l_ev_form.intl_org1_othr_name,
		    x_intl_org2_othr_name            => l_ev_form.intl_org2_othr_name,
		    x_no_show_flag		     => l_ev_form.no_show_flag,
		    x_other_govt_name		     => l_ev_form.other_govt_name,
		    x_sevis_school_id		     => l_ev_form.SEVIS_SCHOOL_IDENTIFIER
                    );

               OPEN person_type(l_ev_form.person_id);
               FETCH person_type INTO l_person_type;
               CLOSE person_type;

               l_end_date := new_references.action_date;
	       l_end_method := 'END_EXCHG_VISITOR';
               lv_userid := fnd_global.user_id;

                 igs_pe_typ_instances_pkg.UPDATE_ROW
                 (
                 X_ROWID                        => l_person_type.rowid,
                 X_PERSON_ID                    => l_person_type.person_id,
                 X_COURSE_CD                    => l_person_type.course_cd,
                 X_TYPE_INSTANCE_ID             => l_person_type.type_instance_id,
                 X_PERSON_TYPE_CODE             => l_person_type.person_type_code,
                 X_CC_VERSION_NUMBER            => l_person_type.cc_version_number,
                 X_FUNNEL_STATUS                => l_person_type.funnel_status,
                 X_ADMISSION_APPL_NUMBER        => l_person_type.admission_appl_number,
                 X_NOMINATED_COURSE_CD          => l_person_type.nominated_course_cd,
                 X_NCC_VERSION_NUMBER           => l_person_type.ncc_version_number,
                 X_SEQUENCE_NUMBER              => l_person_type.sequence_number,
                 X_START_DATE                   => l_ev_form.form_effective_date,
                 X_END_DATE                     => l_end_date ,
                 X_CREATE_METHOD                => l_person_type.create_method,
                 X_ENDED_BY                     => lv_userid,
                 X_END_METHOD                   => l_end_method,
                 X_EMPLMNT_CATEGORY_CODE        => l_person_type.emplmnt_category_code
		 );

                 END ;
          END IF;

     ELSIF p_update = TRUE THEN
           null;
     END IF;
  END afterrowinsertupdate;


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

    IF ( get_uk_for_validation (
           new_references.ev_form_id,
           new_references.action_date,
           new_references.action_type
         )
       ) THEN
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

    IF (((old_references.ev_form_id = new_references.ev_form_id)) OR
        ((new_references.ev_form_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_ev_form_pkg.get_pk_for_validation (
                new_references.ev_form_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_ev_form_stat_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
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
      FROM     igs_pe_ev_form_stat
      WHERE    ev_form_stat_id = x_ev_form_stat_id
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
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2
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
      FROM     igs_pe_ev_form_stat
      WHERE    ev_form_id = x_ev_form_id
      AND      action_date = x_action_date
      AND      action_type = x_action_type
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


  PROCEDURE get_fk_igs_pe_ev_form (
    x_ev_form_id                        IN     NUMBER
  ) AS
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
      FROM     igs_pe_ev_form_stat
      WHERE   ((ev_form_id = x_ev_form_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_PEFMS_PEVF_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_ev_form;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ev_form_stat_id                   IN     NUMBER,
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_end_program_reason                IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
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
      x_ev_form_stat_id,
      x_ev_form_id,
      x_action_date,
      x_action_type,
      x_prgm_start_date,
      x_prgm_end_date,
      x_remarks,
      x_termination_reason,
      x_end_program_reason,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ev_form_stat_id
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
             new_references.ev_form_stat_id
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
    x_ev_form_stat_id                   IN OUT NOCOPY NUMBER,
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_end_program_reason                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
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
      x_ev_form_stat_id                   => x_ev_form_stat_id,
      x_ev_form_id                        => x_ev_form_id,
      x_action_date                       => x_action_date,
      x_action_type                       => x_action_type,
      x_prgm_start_date                   => x_prgm_start_date,
      x_prgm_end_date                     => x_prgm_end_date,
      x_remarks                           => x_remarks,
      x_termination_reason                => x_termination_reason,
      x_end_program_reason                => x_end_program_reason,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_ev_form_stat (
      ev_form_stat_id,
      ev_form_id,
      action_date,
      action_type,
      prgm_start_date,
      prgm_end_date,
      remarks,
      termination_reason,
      end_program_reason,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_pe_ev_form_stat_s.NEXTVAL,
      new_references.ev_form_id,
      new_references.action_date,
      new_references.action_type,
      new_references.prgm_start_date,
      new_references.prgm_end_date,
      new_references.remarks,
      new_references.termination_reason,
      new_references.end_program_reason,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, ev_form_stat_id INTO x_rowid, x_ev_form_stat_id;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    afterrowinsertupdate(p_insert => TRUE, p_update => FALSE);


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
    x_ev_form_stat_id                   IN     NUMBER,
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_end_program_reason                IN     VARCHAR2
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
        ev_form_id,
        action_date,
        action_type,
        prgm_start_date,
        prgm_end_date,
        remarks,
        termination_reason,
        end_program_reason
      FROM  igs_pe_ev_form_stat
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
        (tlinfo.ev_form_id = x_ev_form_id)
        AND (tlinfo.action_date = x_action_date)
        AND (tlinfo.action_type = x_action_type)
        AND ((tlinfo.prgm_start_date = x_prgm_start_date) OR ((tlinfo.prgm_start_date IS NULL) AND (X_prgm_start_date IS NULL)))
        AND ((tlinfo.prgm_end_date = x_prgm_end_date) OR ((tlinfo.prgm_end_date IS NULL) AND (X_prgm_end_date IS NULL)))
        AND ((tlinfo.remarks = x_remarks) OR ((tlinfo.remarks IS NULL) AND (X_remarks IS NULL)))
        AND ((tlinfo.termination_reason = x_termination_reason) OR ((tlinfo.termination_reason IS NULL) AND (X_termination_reason IS NULL)))
        AND ((tlinfo.end_program_reason = x_end_program_reason) OR ((tlinfo.end_program_reason IS NULL) AND (X_end_program_reason IS NULL)))
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
    x_ev_form_stat_id                   IN     NUMBER,
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_end_program_reason                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
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
      x_ev_form_stat_id                   => x_ev_form_stat_id,
      x_ev_form_id                        => x_ev_form_id,
      x_action_date                       => x_action_date,
      x_action_type                       => x_action_type,
      x_prgm_start_date                   => x_prgm_start_date,
      x_prgm_end_date                     => x_prgm_end_date,
      x_remarks                           => x_remarks,
      x_termination_reason                => x_termination_reason,
      x_end_program_reason                => x_end_program_reason,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_ev_form_stat
      SET
        ev_form_id                        = new_references.ev_form_id,
        action_date                       = new_references.action_date,
        action_type                       = new_references.action_type,
        prgm_start_date                   = new_references.prgm_start_date,
        prgm_end_date                     = new_references.prgm_end_date,
        remarks                           = new_references.remarks,
        termination_reason                = new_references.termination_reason,
        end_program_reason                = new_references.end_program_reason,
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
    x_ev_form_stat_id                   IN OUT NOCOPY NUMBER,
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_end_program_reason                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
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
      FROM     igs_pe_ev_form_stat
      WHERE    ev_form_stat_id                   = x_ev_form_stat_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ev_form_stat_id,
        x_ev_form_id,
        x_action_date,
        x_action_type,
        x_prgm_start_date,
        x_prgm_end_date,
        x_remarks,
        x_termination_reason,
        x_end_program_reason,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ev_form_stat_id,
      x_ev_form_id,
      x_action_date,
      x_action_type,
      x_prgm_start_date,
      x_prgm_end_date,
      x_remarks,
      x_termination_reason,
      x_end_program_reason,
      x_mode
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
 DELETE FROM igs_pe_ev_form_stat
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


END igs_pe_ev_form_stat_pkg;

/
