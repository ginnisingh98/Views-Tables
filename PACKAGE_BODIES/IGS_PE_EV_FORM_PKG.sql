--------------------------------------------------------
--  DDL for Package Body IGS_PE_EV_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_EV_FORM_PKG" AS
/* $Header: IGSNI51B.pls 120.2 2006/02/17 06:54:11 gmaheswa ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_ev_form%ROWTYPE;
  new_references igs_pe_ev_form%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ev_form_id                        IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_create_reason                     IN     VARCHAR2,
    x_is_valid                          IN     VARCHAR2,
    x_prgm_sponsor_amt                  IN     NUMBER,
    x_govt_org1_amt                     IN     NUMBER,
    x_govt_org1_code                    IN     VARCHAR2,
    x_govt_org2_amt                     IN     NUMBER,
    x_govt_org2_code                    IN     VARCHAR2,
    x_intl_org1_amt                     IN     NUMBER,
    x_intl_org1_code                    IN     VARCHAR2,
    x_intl_org2_amt                     IN     NUMBER,
    x_intl_org2_code                    IN     VARCHAR2,
    x_ev_govt_amt                       IN     NUMBER,
    x_bi_natnl_com_amt                  IN     NUMBER,
    x_other_govt_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_ev_form_number                    IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_position_code                     IN     NUMBER,
    x_position_remarks                  IN     VARCHAR2,
    x_subject_field_code                IN     VARCHAR2,
    x_subject_field_remarks             IN     VARCHAR2,
    x_matriculation                     IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_category_code                     IN     VARCHAR2,
    x_init_prgm_start_date              IN     DATE,
    x_govt_org1_othr_name               IN     VARCHAR2,
    x_govt_org2_othr_name               IN     VARCHAR2 ,
    x_intl_org1_othr_name               IN     VARCHAR2 ,
    x_intl_org2_othr_name               IN     VARCHAR2 ,
    x_no_show_flag			IN     VARCHAR2 ,
    x_other_govt_name			IN     VARCHAR2 ,
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
      FROM     igs_pe_ev_form
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
    new_references.ev_form_id                        := x_ev_form_id;
    new_references.person_id                         := x_person_id;
    new_references.print_form                        := x_print_form;
    new_references.form_effective_date               := x_form_effective_date;
    new_references.form_status                       := x_form_status;
    new_references.create_reason                     := x_create_reason;
    new_references.is_valid                          := x_is_valid;
    new_references.prgm_sponsor_amt                  := x_prgm_sponsor_amt;
    new_references.govt_org1_amt                     := x_govt_org1_amt;
    new_references.govt_org1_code                    := x_govt_org1_code;
    new_references.govt_org2_amt                     := x_govt_org2_amt;
    new_references.govt_org2_code                    := x_govt_org2_code;
    new_references.intl_org1_amt                     := x_intl_org1_amt;
    new_references.intl_org1_code                    := x_intl_org1_code;
    new_references.intl_org2_amt                     := x_intl_org2_amt;
    new_references.intl_org2_code                    := x_intl_org2_code;
    new_references.ev_govt_amt                       := x_ev_govt_amt;
    new_references.bi_natnl_com_amt                  := x_bi_natnl_com_amt;
    new_references.other_govt_amt                    := x_other_govt_amt;
    new_references.personal_funds_amt                := x_personal_funds_amt;
    new_references.ev_form_number                    := x_ev_form_number;
    new_references.prgm_start_date                   := x_prgm_start_date;
    new_references.prgm_end_date                     := x_prgm_end_date;
    new_references.last_reprint_date                 := x_last_reprint_date;
    new_references.reprint_reason                    := x_reprint_reason;
    new_references.reprint_remarks                   := x_reprint_remarks;
    new_references.position_code                     := x_position_code;
    new_references.position_remarks                  := x_position_remarks;
    new_references.subject_field_code                := x_subject_field_code;
    new_references.subject_field_remarks             := x_subject_field_remarks;
    new_references.matriculation                     := x_matriculation;
    new_references.remarks                           := x_remarks;
    new_references.category_code                     := x_category_code;
    new_references.init_prgm_start_date              := x_init_prgm_start_date;
    new_references.govt_org1_othr_name               := x_govt_org1_othr_name;
    new_references.govt_org2_othr_name               := x_govt_org2_othr_name;
    new_references.intl_org1_othr_name               := x_intl_org1_othr_name;
    new_references.intl_org2_othr_name               := x_intl_org2_othr_name;
    new_references.no_show_flag			     := x_no_show_flag;
    new_references.other_govt_name                   := x_other_govt_name;
    new_references.SEVIS_SCHOOL_IDENTIFIER                   := x_sevis_school_id;

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

  PROCEDURE afterrowinsertupdatedel(p_insert BOOLEAN ,p_update BOOLEAN,p_delete BOOLEAN) AS

   CURSOR per_type(cp_system_type IGS_PE_PERSON_TYPES.system_type%TYPE,cp_closed_ind igs_pe_person_types.closed_ind%TYPE) IS
   SELECT person_type_code FROM
   IGS_PE_PERSON_TYPES
   WHERE system_type = cp_system_type
   AND closed_ind = cp_closed_ind;

   CURSOR person_type (cp_system_type igs_pe_person_types.system_type%TYPE)IS
   SELECT typ.rowid,typ.* FROM
   igs_pe_typ_instances_all typ , igs_pe_person_types per_typ
   WHERE
   typ.person_id = old_references.person_id AND
   per_typ.system_type = cp_system_type AND
   typ.person_type_code = per_typ.person_type_code AND
   typ.end_date IS NULL ;

   l_person_type person_type%ROWTYPE;
   l_per_type per_type%ROWTYPE;
   lv_rowid VARCHAR2(25);
   l_type_instance_id NUMBER(15);

  BEGIN
   OPEN per_type('EXCHG_VISITOR','N');
   FETCH per_type INTO l_per_type;
   IF per_type%FOUND THEN
     IF p_insert = TRUE THEN
         igs_pe_typ_instances_pkg.insert_row
                (
                 X_ROWID                        => lv_rowid,
                 X_PERSON_ID                    => new_references.person_id,
                 X_COURSE_CD                    => null,
                 X_TYPE_INSTANCE_ID             => l_type_instance_id,
                 X_PERSON_TYPE_CODE             => l_per_type.person_type_code,
                 X_CC_VERSION_NUMBER            => null,
                 X_FUNNEL_STATUS                => null,
                 X_ADMISSION_APPL_NUMBER        => null,
                 X_NOMINATED_COURSE_CD          => null,
                 X_NCC_VERSION_NUMBER           => null,
                 X_SEQUENCE_NUMBER              => null,
                 X_START_DATE                   => new_references.form_effective_date,
                 X_END_DATE                     => null,
                 X_CREATE_METHOD                => 'CREATE_EXCHG_VISITOR',
                 X_ENDED_BY                     => null,
                 X_END_METHOD                   => null,
                 X_ORG_ID                       => null,
                 X_EMPLMNT_CATEGORY_CODE        => null
                 );

     ELSIF p_update = TRUE THEN

	 IF (new_references.form_effective_date <> old_references.form_effective_date ) THEN
         OPEN person_type('EXCHG_VISITOR');
	 FETCH person_type INTO l_person_type;
         CLOSE person_type;

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
                 X_START_DATE                   => new_references.form_effective_date,
                 X_END_DATE                     => l_person_type.end_date,
                 X_CREATE_METHOD                => l_person_type.create_method,
                 X_ENDED_BY                     => l_person_type.ended_by,
                 X_END_METHOD                   => l_person_type.end_method,
                 X_EMPLMNT_CATEGORY_CODE        => l_person_type.emplmnt_category_code
		 );
         END IF;
     ELSIF p_delete = TRUE THEN
         OPEN person_type('EXCHG_VISITOR');
	 FETCH person_type INTO l_person_type;
         CLOSE person_type;
               igs_pe_typ_instances_pkg.DELETE_ROW(l_person_type.rowid);
     END IF;
   CLOSE per_type;
   END IF;
 END afterrowinsertupdatedel;

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

    igs_pe_ev_form_stat_pkg.get_fk_igs_pe_ev_form (
      old_references.ev_form_id
    );

  END check_child_existance;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : npalanis.
  Date Created By : 29/Nov/2002
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
     IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.Get_PK_For_Validation (
                        new_references.person_id
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;


  END Check_Parent_Existance;

  FUNCTION get_pk_for_validation (
    x_ev_form_id                        IN     NUMBER
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
      FROM     igs_pe_ev_form
      WHERE    ev_form_id = x_ev_form_id
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
    x_ev_form_id                        IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_create_reason                     IN     VARCHAR2,
    x_is_valid                          IN     VARCHAR2,
    x_prgm_sponsor_amt                  IN     NUMBER,
    x_govt_org1_amt                     IN     NUMBER,
    x_govt_org1_code                    IN     VARCHAR2,
    x_govt_org2_amt                     IN     NUMBER,
    x_govt_org2_code                    IN     VARCHAR2,
    x_intl_org1_amt                     IN     NUMBER,
    x_intl_org1_code                    IN     VARCHAR2,
    x_intl_org2_amt                     IN     NUMBER,
    x_intl_org2_code                    IN     VARCHAR2,
    x_ev_govt_amt                       IN     NUMBER,
    x_bi_natnl_com_amt                  IN     NUMBER,
    x_other_govt_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_ev_form_number                    IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_position_code                     IN     NUMBER,
    x_position_remarks                  IN     VARCHAR2,
    x_subject_field_code                IN     VARCHAR2,
    x_subject_field_remarks             IN     VARCHAR2,
    x_matriculation                     IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER ,
    x_category_code                     IN     VARCHAR2,
    x_init_prgm_start_date              IN     DATE,
    x_govt_org1_othr_name               IN     VARCHAR2,
    x_govt_org2_othr_name               IN     VARCHAR2 ,
    x_intl_org1_othr_name               IN     VARCHAR2 ,
    x_intl_org2_othr_name               IN     VARCHAR2 ,
    x_no_show_flag  			IN     VARCHAR2 ,
    x_other_govt_name			IN     VARCHAR2 ,
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
      x_ev_form_id,
      x_person_id,
      x_print_form,
      x_form_effective_date,
      x_form_status,
      x_create_reason,
      x_is_valid,
      x_prgm_sponsor_amt,
      x_govt_org1_amt,
      x_govt_org1_code,
      x_govt_org2_amt,
      x_govt_org2_code,
      x_intl_org1_amt,
      x_intl_org1_code,
      x_intl_org2_amt,
      x_intl_org2_code,
      x_ev_govt_amt,
      x_bi_natnl_com_amt,
      x_other_govt_amt,
      x_personal_funds_amt,
      x_ev_form_number,
      x_prgm_start_date,
      x_prgm_end_date,
      x_last_reprint_date,
      x_reprint_reason,
      x_reprint_remarks,
      x_position_code,
      x_position_remarks,
      x_subject_field_code,
      x_subject_field_remarks,
      x_matriculation,
      x_remarks,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_category_code,
      x_init_prgm_start_date,
      x_govt_org1_othr_name,
      x_govt_org2_othr_name,
      x_intl_org1_othr_name,
      x_intl_org2_othr_name,
      x_no_show_flag,
      x_other_govt_name,
      x_sevis_school_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ev_form_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.ev_form_id
           )
         ) THEN
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
    x_ev_form_id                        IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_create_reason                     IN     VARCHAR2,
    x_is_valid                          IN     VARCHAR2,
    x_prgm_sponsor_amt                  IN     NUMBER,
    x_govt_org1_amt                     IN     NUMBER,
    x_govt_org1_code                    IN     VARCHAR2,
    x_govt_org2_amt                     IN     NUMBER,
    x_govt_org2_code                    IN     VARCHAR2,
    x_intl_org1_amt                     IN     NUMBER,
    x_intl_org1_code                    IN     VARCHAR2,
    x_intl_org2_amt                     IN     NUMBER,
    x_intl_org2_code                    IN     VARCHAR2,
    x_ev_govt_amt                       IN     NUMBER,
    x_bi_natnl_com_amt                  IN     NUMBER,
    x_other_govt_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_ev_form_number                    IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_position_code                     IN     NUMBER,
    x_position_remarks                  IN     VARCHAR2,
    x_subject_field_code                IN     VARCHAR2,
    x_subject_field_remarks             IN     VARCHAR2,
    x_matriculation                     IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_category_code                     IN     VARCHAR2,
    x_init_prgm_start_date              IN     DATE,
    x_govt_org1_othr_name               IN     VARCHAR2,
    x_govt_org2_othr_name               IN     VARCHAR2 ,
    x_intl_org1_othr_name               IN     VARCHAR2 ,
    x_intl_org2_othr_name               IN     VARCHAR2 ,
    x_no_show_flag			IN     VARCHAR2 ,
    x_other_govt_name			IN     VARCHAR2 ,
    x_sevis_school_id                   IN     NUMBER
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
      x_ev_form_id                        => x_ev_form_id,
      x_person_id                         => x_person_id,
      x_print_form                        => x_print_form,
      x_form_effective_date               => x_form_effective_date,
      x_form_status                       => x_form_status,
      x_create_reason                     => x_create_reason,
      x_is_valid                          => x_is_valid,
      x_prgm_sponsor_amt                  => x_prgm_sponsor_amt,
      x_govt_org1_amt                     => x_govt_org1_amt,
      x_govt_org1_code                    => x_govt_org1_code,
      x_govt_org2_amt                     => x_govt_org2_amt,
      x_govt_org2_code                    => x_govt_org2_code,
      x_intl_org1_amt                     => x_intl_org1_amt,
      x_intl_org1_code                    => x_intl_org1_code,
      x_intl_org2_amt                     => x_intl_org2_amt,
      x_intl_org2_code                    => x_intl_org2_code,
      x_ev_govt_amt                       => x_ev_govt_amt,
      x_bi_natnl_com_amt                  => x_bi_natnl_com_amt,
      x_other_govt_amt                    => x_other_govt_amt,
      x_personal_funds_amt                => x_personal_funds_amt,
      x_ev_form_number                    => x_ev_form_number,
      x_prgm_start_date                   => x_prgm_start_date,
      x_prgm_end_date                     => x_prgm_end_date,
      x_last_reprint_date                 => x_last_reprint_date,
      x_reprint_reason                    => x_reprint_reason,
      x_reprint_remarks                   => x_reprint_remarks,
      x_position_code                     => x_position_code,
      x_position_remarks                  => x_position_remarks,
      x_subject_field_code                => x_subject_field_code,
      x_subject_field_remarks             => x_subject_field_remarks,
      x_matriculation                     => x_matriculation,
      x_remarks                           => x_remarks,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_category_code                     => x_category_code,
      x_init_prgm_start_date              => x_init_prgm_start_date,
      x_govt_org1_othr_name               => x_govt_org1_othr_name,
      x_govt_org2_othr_name               => x_govt_org2_othr_name,
      x_intl_org1_othr_name               => x_intl_org1_othr_name,
      x_intl_org2_othr_name               => x_intl_org2_othr_name,
      x_no_show_flag			  => x_no_show_flag,
      x_other_govt_name			  => x_other_govt_name,
      x_sevis_school_id			  => x_sevis_school_id
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_ev_form (
      ev_form_id,
      person_id,
      print_form,
      form_effective_date,
      form_status,
      create_reason,
      is_valid,
      prgm_sponsor_amt,
      govt_org1_amt,
      govt_org1_code,
      govt_org2_amt,
      govt_org2_code,
      intl_org1_amt,
      intl_org1_code,
      intl_org2_amt,
      intl_org2_code,
      ev_govt_amt,
      bi_natnl_com_amt,
      other_govt_amt,
      personal_funds_amt,
      ev_form_number,
      prgm_start_date,
      prgm_end_date,
      last_reprint_date,
      reprint_reason,
      reprint_remarks,
      position_code,
      position_remarks,
      subject_field_code,
      subject_field_remarks,
      matriculation,
      remarks,
      govt_org1_othr_name,
      govt_org2_othr_name,
      intl_org1_othr_name,
      intl_org2_othr_name,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      category_code,
      init_prgm_start_date,
      no_show_flag,
      other_govt_name,
      SEVIS_SCHOOL_IDENTIFIER
    ) VALUES (
      igs_pe_ev_form_s.NEXTVAL,
      new_references.person_id,
      new_references.print_form,
      new_references.form_effective_date,
      new_references.form_status,
      new_references.create_reason,
      new_references.is_valid,
      new_references.prgm_sponsor_amt,
      new_references.govt_org1_amt,
      new_references.govt_org1_code,
      new_references.govt_org2_amt,
      new_references.govt_org2_code,
      new_references.intl_org1_amt,
      new_references.intl_org1_code,
      new_references.intl_org2_amt,
      new_references.intl_org2_code,
      new_references.ev_govt_amt,
      new_references.bi_natnl_com_amt,
      new_references.other_govt_amt,
      new_references.personal_funds_amt,
      new_references.ev_form_number,
      new_references.prgm_start_date,
      new_references.prgm_end_date,
      new_references.last_reprint_date,
      new_references.reprint_reason,
      new_references.reprint_remarks,
      new_references.position_code,
      new_references.position_remarks,
      new_references.subject_field_code,
      new_references.subject_field_remarks,
      new_references.matriculation,
      new_references.remarks,
      new_references.govt_org1_othr_name,
      new_references.govt_org2_othr_name,
      new_references.intl_org1_othr_name,
      new_references.intl_org2_othr_name,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      new_references.category_code,
      new_references.init_prgm_start_date,
      new_references.no_show_flag,
      new_references.other_govt_name,
      new_references.SEVIS_SCHOOL_IDENTIFIER
    ) RETURNING ROWID, ev_form_id INTO x_rowid, x_ev_form_id;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


   afterrowinsertupdatedel(TRUE,FALSE,FALSE);


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
    x_ev_form_id                        IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_create_reason                     IN     VARCHAR2,
    x_is_valid                          IN     VARCHAR2,
    x_prgm_sponsor_amt                  IN     NUMBER,
    x_govt_org1_amt                     IN     NUMBER,
    x_govt_org1_code                    IN     VARCHAR2,
    x_govt_org2_amt                     IN     NUMBER,
    x_govt_org2_code                    IN     VARCHAR2,
    x_intl_org1_amt                     IN     NUMBER,
    x_intl_org1_code                    IN     VARCHAR2,
    x_intl_org2_amt                     IN     NUMBER,
    x_intl_org2_code                    IN     VARCHAR2,
    x_ev_govt_amt                       IN     NUMBER,
    x_bi_natnl_com_amt                  IN     NUMBER,
    x_other_govt_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_ev_form_number                    IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_position_code                     IN     NUMBER,
    x_position_remarks                  IN     VARCHAR2,
    x_subject_field_code                IN     VARCHAR2,
    x_subject_field_remarks             IN     VARCHAR2,
    x_matriculation                     IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_category_code                     IN     VARCHAR2,
    x_init_prgm_start_date              IN     DATE,
    x_govt_org1_othr_name               IN     VARCHAR2,
    x_govt_org2_othr_name               IN     VARCHAR2,
    x_intl_org1_othr_name               IN     VARCHAR2 ,
    x_intl_org2_othr_name               IN     VARCHAR2 ,
    x_no_show_flag			IN     VARCHAR2,
    x_other_govt_name			IN     VARCHAR2,
    x_sevis_school_id                   IN     NUMBER
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
        create_reason,
        is_valid,
        prgm_sponsor_amt,
        govt_org1_amt,
        govt_org1_code,
        govt_org2_amt,
        govt_org2_code,
        intl_org1_amt,
        intl_org1_code,
        intl_org2_amt,
        intl_org2_code,
        ev_govt_amt,
        bi_natnl_com_amt,
        other_govt_amt,
        personal_funds_amt,
        ev_form_number,
        prgm_start_date,
        prgm_end_date,
        last_reprint_date,
        reprint_reason,
        reprint_remarks,
        position_code,
        position_remarks,
        subject_field_code,
        subject_field_remarks,
        matriculation,
        remarks,
        category_code,
        init_prgm_start_date,
	govt_org1_othr_name,
        govt_org2_othr_name,
        intl_org1_othr_name,
        intl_org2_othr_name,
	no_show_flag,
	other_govt_name,
	SEVIS_SCHOOL_IDENTIFIER
      FROM  igs_pe_ev_form
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
        AND (tlinfo.create_reason = x_create_reason)
        AND (tlinfo.is_valid = x_is_valid)
        AND ((tlinfo.prgm_sponsor_amt = x_prgm_sponsor_amt) OR ((tlinfo.prgm_sponsor_amt IS NULL) AND (X_prgm_sponsor_amt IS NULL)))
        AND ((tlinfo.govt_org1_amt = x_govt_org1_amt) OR ((tlinfo.govt_org1_amt IS NULL) AND (X_govt_org1_amt IS NULL)))
        AND ((tlinfo.govt_org1_code = x_govt_org1_code) OR ((tlinfo.govt_org1_code IS NULL) AND (X_govt_org1_code IS NULL)))
        AND ((tlinfo.govt_org2_amt = x_govt_org2_amt) OR ((tlinfo.govt_org2_amt IS NULL) AND (X_govt_org2_amt IS NULL)))
        AND ((tlinfo.govt_org2_code = x_govt_org2_code) OR ((tlinfo.govt_org2_code IS NULL) AND (X_govt_org2_code IS NULL)))
        AND ((tlinfo.intl_org1_amt = x_intl_org1_amt) OR ((tlinfo.intl_org1_amt IS NULL) AND (X_intl_org1_amt IS NULL)))
        AND ((tlinfo.intl_org1_code = x_intl_org1_code) OR ((tlinfo.intl_org1_code IS NULL) AND (X_intl_org1_code IS NULL)))
        AND ((tlinfo.intl_org2_amt = x_intl_org2_amt) OR ((tlinfo.intl_org2_amt IS NULL) AND (X_intl_org2_amt IS NULL)))
        AND ((tlinfo.intl_org2_code = x_intl_org2_code) OR ((tlinfo.intl_org2_code IS NULL) AND (X_intl_org2_code IS NULL)))
        AND ((tlinfo.ev_govt_amt = x_ev_govt_amt) OR ((tlinfo.ev_govt_amt IS NULL) AND (X_ev_govt_amt IS NULL)))
        AND ((tlinfo.bi_natnl_com_amt = x_bi_natnl_com_amt) OR ((tlinfo.bi_natnl_com_amt IS NULL) AND (X_bi_natnl_com_amt IS NULL)))
        AND ((tlinfo.other_govt_amt = x_other_govt_amt) OR ((tlinfo.other_govt_amt IS NULL) AND (X_other_govt_amt IS NULL)))
        AND ((tlinfo.personal_funds_amt = x_personal_funds_amt) OR ((tlinfo.personal_funds_amt IS NULL) AND (X_personal_funds_amt IS NULL)))
        AND ((tlinfo.ev_form_number = x_ev_form_number) OR ((tlinfo.ev_form_number IS NULL) AND (X_ev_form_number IS NULL)))
        AND (tlinfo.prgm_start_date = x_prgm_start_date)
        AND (tlinfo.prgm_end_date = x_prgm_end_date)
        AND ((tlinfo.last_reprint_date = x_last_reprint_date) OR ((tlinfo.last_reprint_date IS NULL) AND (X_last_reprint_date IS NULL)))
        AND ((tlinfo.reprint_reason = x_reprint_reason) OR ((tlinfo.reprint_reason IS NULL) AND (X_reprint_reason IS NULL)))
        AND ((tlinfo.reprint_remarks = x_reprint_remarks) OR ((tlinfo.reprint_remarks IS NULL) AND (X_reprint_remarks IS NULL)))
        AND (tlinfo.position_code = x_position_code)
        AND ((tlinfo.position_remarks = x_position_remarks) OR ((tlinfo.position_remarks IS NULL) AND (X_position_remarks IS NULL)))
        AND (tlinfo.subject_field_code = x_subject_field_code)
        AND ((tlinfo.subject_field_remarks = x_subject_field_remarks) OR ((tlinfo.subject_field_remarks IS NULL) AND (X_subject_field_remarks IS NULL)))
        AND ((tlinfo.matriculation = x_matriculation) OR ((tlinfo.matriculation IS NULL) AND (X_matriculation IS NULL)))
        AND ((tlinfo.remarks = x_remarks) OR ((tlinfo.remarks IS NULL) AND (X_remarks IS NULL)))
        AND ((tlinfo.category_code = x_category_code) OR ((tlinfo.category_code IS NULL) AND (x_category_code IS NULL)))
        AND ((tlinfo.init_prgm_start_date = x_init_prgm_start_date) OR ((tlinfo.init_prgm_start_date IS NULL) AND (x_init_prgm_start_date IS NULL )))
        AND ((tlinfo.govt_org1_othr_name = x_govt_org1_othr_name) OR ((tlinfo.govt_org1_othr_name IS NULL) AND (x_govt_org1_othr_name IS NULL )))
	AND ((tlinfo.govt_org2_othr_name = x_govt_org2_othr_name) OR ((tlinfo.govt_org2_othr_name IS NULL) AND (x_govt_org2_othr_name IS NULL )) )
	AND ((tlinfo.intl_org1_othr_name = x_intl_org1_othr_name) OR ((tlinfo.intl_org1_othr_name IS NULL) AND (x_intl_org1_othr_name IS NULL )))
	AND ((tlinfo.intl_org2_othr_name = x_intl_org2_othr_name) OR ((tlinfo.intl_org2_othr_name IS NULL) AND (x_intl_org2_othr_name IS NULL )))
        AND ((tlinfo.no_show_flag = x_no_show_flag) OR ((tlinfo.no_show_flag IS NULL) AND (x_no_show_flag IS NULL )))
	AND ((tlinfo.other_govt_name = x_other_govt_name)  OR ((tlinfo.other_govt_name IS NULL) AND (x_other_govt_name IS NULL )))
        AND ((tlinfo.SEVIS_SCHOOL_IDENTIFIER = x_sevis_school_id) OR ((tlinfo.SEVIS_SCHOOL_IDENTIFIER IS NULL) AND (x_sevis_school_id IS NULL )))
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
    x_ev_form_id                        IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_create_reason                     IN     VARCHAR2,
    x_is_valid                          IN     VARCHAR2,
    x_prgm_sponsor_amt                  IN     NUMBER,
    x_govt_org1_amt                     IN     NUMBER,
    x_govt_org1_code                    IN     VARCHAR2,
    x_govt_org2_amt                     IN     NUMBER,
    x_govt_org2_code                    IN     VARCHAR2,
    x_intl_org1_amt                     IN     NUMBER,
    x_intl_org1_code                    IN     VARCHAR2,
    x_intl_org2_amt                     IN     NUMBER,
    x_intl_org2_code                    IN     VARCHAR2,
    x_ev_govt_amt                       IN     NUMBER,
    x_bi_natnl_com_amt                  IN     NUMBER,
    x_other_govt_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_ev_form_number                    IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_position_code                     IN     NUMBER,
    x_position_remarks                  IN     VARCHAR2,
    x_subject_field_code                IN     VARCHAR2,
    x_subject_field_remarks             IN     VARCHAR2,
    x_matriculation                     IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_category_code                     IN     VARCHAR2,
    x_init_prgm_start_date              IN     DATE,
    x_govt_org1_othr_name               IN     VARCHAR2,
    x_govt_org2_othr_name               IN     VARCHAR2 ,
    x_intl_org1_othr_name               IN     VARCHAR2 ,
    x_intl_org2_othr_name               IN     VARCHAR2 ,
    x_no_show_flag			IN     VARCHAR2 ,
    x_other_govt_name			IN     VARCHAR2 ,
    x_sevis_school_id                   IN     NUMBER
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
      x_ev_form_id                        => x_ev_form_id,
      x_person_id                         => x_person_id,
      x_print_form                        => x_print_form,
      x_form_effective_date               => x_form_effective_date,
      x_form_status                       => x_form_status,
      x_create_reason                     => x_create_reason,
      x_is_valid                          => x_is_valid,
      x_prgm_sponsor_amt                  => x_prgm_sponsor_amt,
      x_govt_org1_amt                     => x_govt_org1_amt,
      x_govt_org1_code                    => x_govt_org1_code,
      x_govt_org2_amt                     => x_govt_org2_amt,
      x_govt_org2_code                    => x_govt_org2_code,
      x_intl_org1_amt                     => x_intl_org1_amt,
      x_intl_org1_code                    => x_intl_org1_code,
      x_intl_org2_amt                     => x_intl_org2_amt,
      x_intl_org2_code                    => x_intl_org2_code,
      x_ev_govt_amt                       => x_ev_govt_amt,
      x_bi_natnl_com_amt                  => x_bi_natnl_com_amt,
      x_other_govt_amt                    => x_other_govt_amt,
      x_personal_funds_amt                => x_personal_funds_amt,
      x_ev_form_number                    => x_ev_form_number,
      x_prgm_start_date                   => x_prgm_start_date,
      x_prgm_end_date                     => x_prgm_end_date,
      x_last_reprint_date                 => x_last_reprint_date,
      x_reprint_reason                    => x_reprint_reason,
      x_reprint_remarks                   => x_reprint_remarks,
      x_position_code                     => x_position_code,
      x_position_remarks                  => x_position_remarks,
      x_subject_field_code                => x_subject_field_code,
      x_subject_field_remarks             => x_subject_field_remarks,
      x_matriculation                     => x_matriculation,
      x_remarks                           => x_remarks,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_category_code                     => x_category_code,
      x_init_prgm_start_date              => x_init_prgm_start_date,
      x_govt_org1_othr_name               => x_govt_org1_othr_name,
      x_govt_org2_othr_name               => x_govt_org2_othr_name,
      x_intl_org1_othr_name               => x_intl_org1_othr_name,
      x_intl_org2_othr_name               => x_intl_org2_othr_name,
      x_no_show_flag			  => x_no_show_flag,
      x_other_govt_name			  => x_other_govt_name,
      x_sevis_school_id			  => x_sevis_school_id
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_ev_form
      SET
        person_id                         = new_references.person_id,
        print_form                        = new_references.print_form,
        form_effective_date               = new_references.form_effective_date,
        form_status                       = new_references.form_status,
        create_reason                     = new_references.create_reason,
        is_valid                          = new_references.is_valid,
        prgm_sponsor_amt                  = new_references.prgm_sponsor_amt,
        govt_org1_amt                     = new_references.govt_org1_amt,
        govt_org1_code                    = new_references.govt_org1_code,
        govt_org2_amt                     = new_references.govt_org2_amt,
        govt_org2_code                    = new_references.govt_org2_code,
        intl_org1_amt                     = new_references.intl_org1_amt,
        intl_org1_code                    = new_references.intl_org1_code,
        intl_org2_amt                     = new_references.intl_org2_amt,
        intl_org2_code                    = new_references.intl_org2_code,
        ev_govt_amt                       = new_references.ev_govt_amt,
        bi_natnl_com_amt                  = new_references.bi_natnl_com_amt,
        other_govt_amt                    = new_references.other_govt_amt,
        personal_funds_amt                = new_references.personal_funds_amt,
        ev_form_number                    = new_references.ev_form_number,
        prgm_start_date                   = new_references.prgm_start_date,
        prgm_end_date                     = new_references.prgm_end_date,
        last_reprint_date                 = new_references.last_reprint_date,
        reprint_reason                    = new_references.reprint_reason,
        reprint_remarks                   = new_references.reprint_remarks,
        position_code                     = new_references.position_code,
        position_remarks                  = new_references.position_remarks,
        subject_field_code                = new_references.subject_field_code,
        subject_field_remarks             = new_references.subject_field_remarks,
        matriculation                     = new_references.matriculation,
        remarks                           = new_references.remarks,
	govt_org1_othr_name               = new_references.govt_org1_othr_name,
        govt_org2_othr_name               = new_references.govt_org2_othr_name,
        intl_org1_othr_name               = new_references.intl_org1_othr_name,
        intl_org2_othr_name               = new_references.intl_org2_othr_name,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        category_code                     = x_category_code,
        init_prgm_start_date              = x_init_prgm_start_date,
	no_show_flag			  = x_no_show_flag,
	other_govt_name			  = new_references.other_govt_name,
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


    afterrowinsertupdatedel(FALSE,TRUE,FALSE);


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
    x_ev_form_id                        IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_create_reason                     IN     VARCHAR2,
    x_is_valid                          IN     VARCHAR2,
    x_prgm_sponsor_amt                  IN     NUMBER,
    x_govt_org1_amt                     IN     NUMBER,
    x_govt_org1_code                    IN     VARCHAR2,
    x_govt_org2_amt                     IN     NUMBER,
    x_govt_org2_code                    IN     VARCHAR2,
    x_intl_org1_amt                     IN     NUMBER,
    x_intl_org1_code                    IN     VARCHAR2,
    x_intl_org2_amt                     IN     NUMBER,
    x_intl_org2_code                    IN     VARCHAR2,
    x_ev_govt_amt                       IN     NUMBER,
    x_bi_natnl_com_amt                  IN     NUMBER,
    x_other_govt_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_ev_form_number                    IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_position_code                     IN     NUMBER,
    x_position_remarks                  IN     VARCHAR2,
    x_subject_field_code                IN     VARCHAR2,
    x_subject_field_remarks             IN     VARCHAR2,
    x_matriculation                     IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_category_code                     IN     VARCHAR2,
    x_init_prgm_start_date              IN     DATE,
    x_govt_org1_othr_name               IN     VARCHAR2,
    x_govt_org2_othr_name               IN     VARCHAR2 ,
    x_intl_org1_othr_name               IN     VARCHAR2 ,
    x_intl_org2_othr_name               IN     VARCHAR2 ,
    x_no_show_flag			IN     VARCHAR2 ,
    x_other_govt_name			IN     VARCHAR2,
    x_sevis_school_id                   IN     NUMBER
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
      FROM     igs_pe_ev_form
      WHERE    ev_form_id                        = x_ev_form_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ev_form_id,
        x_person_id,
        x_print_form,
        x_form_effective_date,
        x_form_status,
        x_create_reason,
        x_is_valid,
        x_prgm_sponsor_amt,
        x_govt_org1_amt,
        x_govt_org1_code,
        x_govt_org2_amt,
        x_govt_org2_code,
        x_intl_org1_amt,
        x_intl_org1_code,
        x_intl_org2_amt,
        x_intl_org2_code,
        x_ev_govt_amt,
        x_bi_natnl_com_amt,
        x_other_govt_amt,
        x_personal_funds_amt,
        x_ev_form_number,
        x_prgm_start_date,
        x_prgm_end_date,
        x_last_reprint_date,
        x_reprint_reason,
        x_reprint_remarks,
        x_position_code,
        x_position_remarks,
        x_subject_field_code,
        x_subject_field_remarks,
        x_matriculation,
        x_remarks,
        x_mode ,
        x_category_code,
        x_init_prgm_start_date,
	x_govt_org1_othr_name,
	x_govt_org2_othr_name,
	x_intl_org1_othr_name,
	x_intl_org2_othr_name,
	x_no_show_flag,
	x_other_govt_name,
	x_sevis_school_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ev_form_id,
      x_person_id,
      x_print_form,
      x_form_effective_date,
      x_form_status,
      x_create_reason,
      x_is_valid,
      x_prgm_sponsor_amt,
      x_govt_org1_amt,
      x_govt_org1_code,
      x_govt_org2_amt,
      x_govt_org2_code,
      x_intl_org1_amt,
      x_intl_org1_code,
      x_intl_org2_amt,
      x_intl_org2_code,
      x_ev_govt_amt,
      x_bi_natnl_com_amt,
      x_other_govt_amt,
      x_personal_funds_amt,
      x_ev_form_number,
      x_prgm_start_date,
      x_prgm_end_date,
      x_last_reprint_date,
      x_reprint_reason,
      x_reprint_remarks,
      x_position_code,
      x_position_remarks,
      x_subject_field_code,
      x_subject_field_remarks,
      x_matriculation,
      x_remarks,
      x_mode ,
      x_category_code,
      x_init_prgm_start_date,
      x_govt_org1_othr_name,
      x_govt_org2_othr_name,
      x_intl_org1_othr_name,
      x_intl_org2_othr_name,
      x_no_show_flag,
      x_other_govt_name,
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
 DELETE FROM igs_pe_ev_form
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


    afterrowinsertupdatedel(FALSE,FALSE,TRUE);

  END delete_row;


END igs_pe_ev_form_pkg;

/
