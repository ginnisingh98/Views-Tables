--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPL_PERM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPL_PERM_PKG" AS
/* $Header: IGSEI53B.pls 120.3 2005/08/12 05:14:36 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_spl_perm%ROWTYPE;
  new_references igs_en_spl_perm%ROWTYPE;

  FUNCTION get_hz_pk_for_validation (
    x_party_id               IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  This checks the primary coloumn AR table from IGS table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     hz_parties
      WHERE    party_id = x_party_id
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

  END get_hz_pk_for_validation;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_spl_perm_request_id               IN     NUMBER  ,
    x_student_person_id                 IN     NUMBER  ,
    x_uoo_id                            IN     NUMBER  ,
    x_date_submission                   IN     DATE    ,
    x_audit_the_course                  IN     VARCHAR2,
    x_instructor_person_id              IN     NUMBER  ,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Nishikant       13JUN2002       -- some commented codes were present here and removed as per bug#2413811
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_SPL_PERM
      WHERE    rowid = x_rowid;

 /*  ltranstype    igs_en_spl_perm.transaction_type%TYPE;
   lapprovstatus igs_en_spl_perm.approval_status%TYPE;*/

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

    --The following lines have code have been commented as this kind of
    --validations may not be required now but may be at a Later point of time.
    --Commented the Code as instructed by the DM.

    --Based on Insert /Update we need to set the Transaction Type and Approval Status
    --We have used another variable  (lapprovstatus) for approval as we cannot assign
    --a value to an Input Parameter.

  -- some commented codes were present here and removed as per bug#2413811

    -- Populate New Values.
    new_references.spl_perm_request_id               := x_spl_perm_request_id;
    new_references.student_person_id                 := x_student_person_id;
    new_references.uoo_id                            := x_uoo_id;
    new_references.date_submission                   := x_date_submission;
    new_references.audit_the_course                  := x_audit_the_course;
    new_references.instructor_person_id              := x_instructor_person_id;
    new_references.approval_status                   := x_approval_status;
    new_references.reason_for_request                := x_reason_for_request;
    new_references.instructor_more_info              := x_instructor_more_info;
    new_references.instructor_deny_info              := x_instructor_deny_info;
    new_references.student_more_info                 := x_student_more_info;
    new_references.transaction_type                  := x_transaction_type;
    new_references.request_type                      := x_request_type;
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


  PROCEDURE beforerowinsertupdatedelete1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  (reverse chronological order - newest change first)
  *************************************************************************/
  l_message_name VARCHAR2(30);
  l_return_type VARCHAR2(1);
  l_spl_perm_request_id   igs_en_spl_perm.spl_perm_request_id%TYPE;
  l_date_submission       igs_en_spl_perm.date_submission%TYPE;
  l_audit_the_course      igs_en_spl_perm.audit_the_course%TYPE;
  l_approval_status       igs_en_spl_perm.approval_status%TYPE;
  l_reason_for_request    igs_en_spl_perm.reason_for_request%TYPE;
  l_instructor_more_info  igs_en_spl_perm.instructor_more_info%TYPE;
  l_instructor_deny_info  igs_en_spl_perm.instructor_deny_info%TYPE;
  l_student_more_info     igs_en_spl_perm.student_more_info%TYPE;
  l_transaction_type      igs_en_spl_perm.transaction_type%TYPE;
  l_rowid VARCHAR2(20);
  l_spl_perm_request_h_id igs_en_spl_perm_h.spl_perm_request_h_id%TYPE;

  CURSOR splh_cur IS
  SELECT ROWID
  FROM igs_en_spl_perm_h
  WHERE spl_perm_request_id  = old_references.spl_perm_request_id;


  BEGIN


  IF p_updating THEN

    --Updating either Student More Information or Instructor More Information involves
    --Concatenating the existing data with new data.

    -- updating all the faculty and student comments first in the faculty
    -- more info field, once that field is filled up then starting filling up
    -- the student more info field, once that is also filled up then show
    -- the error messages that the maximum field has been exceeded


    -- it is assumed here that the faculty more information and the student more
    -- information update cannot happen in a singled call to the update row

    IF new_references.instructor_more_info IS NOT NULL AND
       ( old_references.instructor_more_info IS NULL OR
         new_references.instructor_more_info <> old_references.instructor_more_info ) THEN
      IF old_references.student_more_info IS NOT NULL THEN
        IF LENGTH(old_references.student_more_info || new_references.instructor_more_info ) <= 4000 THEN
          new_references.student_more_info := old_references.student_more_info || new_references.instructor_more_info;
          new_references.instructor_more_info := old_references.instructor_more_info;
        ELSE
          FND_MESSAGE.SET_NAME('IGS','IGS_HE_FIELD_LENGTH_GREATER');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
      ELSE
        IF LENGTH(old_references.instructor_more_info || new_references.instructor_more_info ) <= 4000 THEN
          new_references.instructor_more_info := old_references.instructor_more_info|| new_references.instructor_more_info;
          new_references.student_more_info :=  null;
        ELSE
          IF LENGTH(old_references.student_more_info || new_references.instructor_more_info ) <= 4000 THEN
            new_references.student_more_info := old_references.student_more_info || new_references.instructor_more_info;
            new_references.instructor_more_info := old_references.instructor_more_info;
          ELSE
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_FIELD_LENGTH_GREATER');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
        END IF;
      END IF;

    ELSIF new_references.student_more_info IS NOT NULL AND
          ( new_references.student_more_info <> old_references.student_more_info
            OR old_references.student_more_info IS NULL  )THEN
      IF old_references.student_more_info IS NOT NULL THEN
        IF LENGTH(old_references.student_more_info || new_references.student_more_info ) <= 4000 THEN
          new_references.student_more_info:= old_references.student_more_info || new_references.student_more_info;
          new_references.instructor_more_info := old_references.instructor_more_info;
        ELSE
          FND_MESSAGE.SET_NAME('IGS','IGS_HE_FIELD_LENGTH_GREATER');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
      ELSE
        IF LENGTH(old_references.instructor_more_info || new_references.student_more_info ) <= 4000 THEN
          new_references.instructor_more_info := old_references.instructor_more_info|| new_references.student_more_info;
          new_references.student_more_info :=  null;
        ELSE
          IF LENGTH(old_references.student_more_info || new_references.student_more_info ) <= 4000 THEN
            new_references.student_more_info := old_references.student_more_info || new_references.student_more_info;
            new_references.instructor_more_info := old_references.instructor_more_info;
          ELSE
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_FIELD_LENGTH_GREATER');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
         END IF;
      END IF;

    END IF;


  END IF;

   -- Store IGS_EN_SPL_PERM Version History
  IF p_updating THEN
    IF old_references.spl_perm_request_id <> new_references.spl_perm_request_id OR
       old_references.date_submission <> new_references.date_submission OR
       old_references.audit_the_course  <> new_references.audit_the_course  OR
       old_references.approval_status <> new_references.approval_status OR
       old_references.reason_for_request <> new_references.reason_for_request OR
       old_references.instructor_more_info <> new_references.instructor_more_info OR
       old_references.instructor_deny_info <> new_references.instructor_deny_info OR
       old_references.student_more_info <> new_references.student_more_info OR
       old_references.transaction_type <> new_references.transaction_type THEN

       SELECT
       decode(old_references.spl_perm_request_id,new_references.spl_perm_request_id,
       NULL,old_references.spl_perm_request_id),
       decode(old_references.date_submission,new_references.date_submission,
       NULL,old_references.date_submission),
       decode(old_references.audit_the_course,new_references.audit_the_course,
       NULL,old_references.audit_the_course),
       decode(old_references.approval_status,new_references.approval_status,
       NULL,old_references.approval_status),
       decode(old_references.reason_for_request,new_references.reason_for_request,
       NULL,old_references.reason_for_request),
       decode(old_references.instructor_more_info,new_references.instructor_more_info,
       NULL,old_references.instructor_more_info),
       decode(old_references.instructor_deny_info,new_references.instructor_deny_info,
       NULL,old_references.instructor_deny_info),
       decode(old_references.student_more_info,new_references.student_more_info,
       NULL,old_references.student_more_info),
       decode(old_references.transaction_type,new_references.transaction_type,
       NULL,old_references.transaction_type)

       INTO
        l_spl_perm_request_id,
        l_date_submission,
        l_audit_the_course,
        l_approval_status,
        l_reason_for_request,
        l_instructor_more_info,
        l_instructor_deny_info,
        l_student_more_info,
        l_transaction_type
       FROM dual;

     -- Create history record for update
       igs_en_spl_perm_h_pkg.insert_row(
          l_rowid,
          l_spl_perm_request_h_id,
          l_spl_perm_request_id,
          l_date_submission,
          l_audit_the_course,
          l_approval_status ,
          l_reason_for_request,
          l_instructor_more_info,
          l_instructor_deny_info,
          l_student_more_info,
          l_transaction_type,
          old_references.last_update_date,
          new_references.last_update_date,
          old_references.last_updated_by
          );

        END IF;
      END IF;

      IF p_deleting THEN
        BEGIN
        FOR splh_rec IN splh_cur
           LOOP
              igs_en_spl_perm_h_pkg.delete_row(x_rowid  => splh_rec.rowid);
           END LOOP;
        END;
      END IF;

  END beforerowinsertupdatedelete1;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.student_person_id = new_references.student_person_id)) OR
        ((new_references.student_person_id IS NULL))) THEN
      NULL;
   ELSIF NOT get_hz_pk_for_validation (
                new_references.student_person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ofr_opt_pkg.get_uk_For_validation (
                new_references.uoo_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.instructor_person_id = new_references.instructor_person_id)) OR
        ((new_references.instructor_person_id IS NULL))) THEN
      NULL;
    ELSIF NOT get_hz_pk_for_validation (
                new_references.instructor_person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.transaction_type =
           new_references.transaction_type)) OR
        ((new_references.transaction_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation ('SPL_PERM_TRANSCTION_TYPE',
         new_references.transaction_type) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception;
      END IF;

    END IF;


  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_en_spl_perm_h_pkg.get_fk_igs_en_spl_perm (
      old_references.spl_perm_request_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_spl_perm_request_id               IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spl_perm
      WHERE    spl_perm_request_id = x_spl_perm_request_id
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


  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spl_perm
      WHERE   ((student_person_id = x_party_id))
      OR      ((instructor_person_id = x_party_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_SPLP_HZ_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_parties;


  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spl_perm
      WHERE   ((uoo_id = x_uoo_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_SPLP_UOO_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ps_unit_ofr_opt;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_spl_perm_request_id               IN     NUMBER  ,
    x_student_person_id                 IN     NUMBER  ,
    x_uoo_id                            IN     NUMBER  ,
    x_date_submission                   IN     DATE    ,
    x_audit_the_course                  IN     VARCHAR2,
    x_instructor_person_id              IN     NUMBER  ,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
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
      x_spl_perm_request_id,
      x_student_person_id,
      x_uoo_id,
      x_date_submission,
      x_audit_the_course,
      x_instructor_person_id,
      x_approval_status,
      x_reason_for_request,
      x_instructor_more_info,
      x_instructor_deny_info,
      x_student_more_info,
      x_transaction_type,
      x_request_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.spl_perm_request_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      beforerowinsertupdatedelete1 ( p_inserting => FALSE,
                                     p_updating  => TRUE ,
                                     p_deleting  => FALSE);
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      beforerowinsertupdatedelete1 ( p_inserting => FALSE,
                                     p_updating  => FALSE ,
                                     p_deleting  => TRUE);
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.spl_perm_request_id
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

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    IF (p_action IN ('INSERT','UPDATE')) THEN

      IF new_references.transaction_type IN ('STD_REQ','STD_AU_REQ','STD_MI') THEN
         igs_en_workflow.inform_instruct_stdnt_petition( p_student_id       => new_references.student_person_id,
                                                         p_instructor_id    => new_references.instructor_person_id,
                                                         p_uoo_id           => new_references.uoo_id,
                                                         p_date_submission  => new_references.date_submission,
                                                         p_transaction_type => new_references.transaction_type,
                                                         p_request_type     => new_references.request_type
                                                       );
      ELSIF new_references.transaction_type IN ('INS_DENY','INS_MI','SPL_APRV','AUDIT_APRV') AND
            new_references.transaction_type <> old_references.transaction_type THEN

              igs_en_workflow.inform_stdnt_instruct_action( p_student_id       => new_references.student_person_id,
                                                           p_instructor_id    => new_references.instructor_person_id,
                                                           p_uoo_id           => new_references.uoo_id,
                                                           p_approval_status  => new_references.approval_status,
                                                           p_date_submission  => new_references.date_submission,
                                                           p_request_type     => new_references.request_type
                                                         );
      END IF;

    END IF;

  END After_DML;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_spl_perm_request_id               IN OUT NOCOPY NUMBER,
    x_student_person_id                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_instructor_person_id              IN     NUMBER,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - nbabyewest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_en_spl_perm
      WHERE    spl_perm_request_id               = x_spl_perm_request_id;

    CURSOR c_spl_perm IS
    SELECT rowid, approval_status, transaction_type FROM igs_en_spl_perm
    WHERE student_person_id = x_student_person_id AND
          uoo_id = x_uoo_id AND
          request_type = x_request_type;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_perm_row c_spl_perm%ROWTYPE;
    l_approval_status igs_en_spl_perm.approval_status%TYPE;
    l_transaction_type igs_en_spl_perm.transaction_type%TYPE;


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

    SELECT    igs_en_spl_perm_s.NEXTVAL
    INTO      x_spl_perm_request_id
    FROM      dual;


    OPEN c_spl_perm;
    FETCH c_spl_perm INTO x_rowid,l_approval_status, l_transaction_type;
    IF c_spl_perm%FOUND THEN
      CLOSE c_spl_perm;
      IF l_approval_status='W' and l_transaction_type='WITHDRAWN' THEN
            update_row (
              x_rowid,
              x_spl_perm_request_id,
              x_student_person_id,
              x_uoo_id,
              x_date_submission,
              x_audit_the_course,
              x_instructor_person_id,
              x_approval_status,
              x_reason_for_request,
              x_instructor_more_info,
              x_instructor_deny_info,
              x_student_more_info,
              x_transaction_type,
              x_request_type,
              x_mode
            );
        RETURN;
      ELSE
        fnd_message.set_name ('IGS', 'IGS_EN_REC_EXST_APRV_MORE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSE
      CLOSE c_spl_perm;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_spl_perm_request_id               => x_spl_perm_request_id,
      x_student_person_id                 => x_student_person_id,
      x_uoo_id                            => x_uoo_id,
      x_date_submission                   => x_date_submission,
      x_audit_the_course                  => x_audit_the_course,
      x_instructor_person_id              => x_instructor_person_id,
      x_approval_status                   => x_approval_status,
      x_reason_for_request                => x_reason_for_request,
      x_instructor_more_info              => x_instructor_more_info,
      x_instructor_deny_info              => x_instructor_deny_info,
      x_student_more_info                 => x_student_more_info,
      x_transaction_type                  => x_transaction_type,
      x_request_type                      => x_request_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_spl_perm (
      spl_perm_request_id,
      student_person_id,
      uoo_id,
      date_submission,
      audit_the_course,
      instructor_person_id,
      approval_status,
      reason_for_request,
      instructor_more_info,
      instructor_deny_info,
      student_more_info,
      transaction_type,
      request_type,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.spl_perm_request_id,
      new_references.student_person_id,
      new_references.uoo_id,
      new_references.date_submission,
      new_references.audit_the_course,
      new_references.instructor_person_id,
      new_references.approval_status,
      new_references.reason_for_request,
      new_references.instructor_more_info,
      new_references.instructor_deny_info,
      new_references.student_more_info,
      new_references.transaction_type,
      new_references.request_type,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  After_DML (
    p_action =>'INSERT',
    x_rowid => X_ROWID
  );

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_spl_perm_request_id               IN     NUMBER,
    x_student_person_id                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_instructor_person_id              IN     NUMBER,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        student_person_id,
        uoo_id,
        date_submission,
        audit_the_course,
        instructor_person_id,
        approval_status,
        reason_for_request,
        instructor_more_info,
        instructor_deny_info,
        student_more_info,
        transaction_type,
        request_type
      FROM  igs_en_spl_perm
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
        (tlinfo.student_person_id = x_student_person_id)
        AND (tlinfo.uoo_id = x_uoo_id)
        AND (tlinfo.date_submission = x_date_submission)
        AND (tlinfo.audit_the_course = x_audit_the_course)
        AND (tlinfo.instructor_person_id = x_instructor_person_id)
        AND (tlinfo.approval_status = x_approval_status)
        AND (tlinfo.reason_for_request = x_reason_for_request)
        AND ((tlinfo.instructor_more_info = x_instructor_more_info) OR ((tlinfo.instructor_more_info IS NULL) AND (X_instructor_more_info IS NULL)))
        AND ((tlinfo.instructor_deny_info = x_instructor_deny_info) OR ((tlinfo.instructor_deny_info IS NULL) AND (X_instructor_deny_info IS NULL)))
        AND ((tlinfo.student_more_info = x_student_more_info) OR ((tlinfo.student_more_info IS NULL) AND (X_student_more_info IS NULL)))
        AND ((tlinfo.transaction_type = x_transaction_type) OR ((tlinfo.transaction_type IS NULL) AND (X_transaction_type IS NULL)))
        AND ((tlinfo.request_type = x_request_type) OR ((tlinfo.request_type IS NULL) AND (X_request_type IS NULL)))
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
    x_spl_perm_request_id               IN     NUMBER,
    x_student_person_id                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_instructor_person_id              IN     NUMBER,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
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
      x_spl_perm_request_id               => x_spl_perm_request_id,
      x_student_person_id                 => x_student_person_id,
      x_uoo_id                            => x_uoo_id,
      x_date_submission                   => x_date_submission,
      x_audit_the_course                  => x_audit_the_course,
      x_instructor_person_id              => x_instructor_person_id,
      x_approval_status                   => x_approval_status,
      x_reason_for_request                => x_reason_for_request,
      x_instructor_more_info              => x_instructor_more_info,
      x_instructor_deny_info              => x_instructor_deny_info,
      x_student_more_info                 => x_student_more_info,
      x_transaction_type                  => x_transaction_type,
      x_request_type                      => x_request_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );


    UPDATE igs_en_spl_perm
      SET
        student_person_id                 = new_references.student_person_id,
        uoo_id                            = new_references.uoo_id,
        date_submission                   = new_references.date_submission,
        audit_the_course                  = new_references.audit_the_course,
        instructor_person_id              = new_references.instructor_person_id,
        approval_status                   = new_references.approval_status,
        reason_for_request                = new_references.reason_for_request,
        instructor_more_info              = new_references.instructor_more_info,
        instructor_deny_info              = new_references.instructor_deny_info,
        student_more_info                 = new_references.student_more_info,
        transaction_type                  = new_references.transaction_type,
        request_type                      = new_references.request_type,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  After_DML (
    p_action =>'UPDATE',
    x_rowid => X_ROWID
  );

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_spl_perm_request_id               IN OUT NOCOPY NUMBER,
    x_student_person_id                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_instructor_person_id              IN     NUMBER,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_request_type                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_spl_perm
      WHERE    spl_perm_request_id               = x_spl_perm_request_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_spl_perm_request_id,
        x_student_person_id,
        x_uoo_id,
        x_date_submission,
        x_audit_the_course,
        x_instructor_person_id,
        x_approval_status,
        x_reason_for_request,
        x_instructor_more_info,
        x_instructor_deny_info,
        x_student_more_info,
        x_transaction_type,
        x_request_type,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_spl_perm_request_id,
      x_student_person_id,
      x_uoo_id,
      x_date_submission,
      x_audit_the_course,
      x_instructor_person_id,
      x_approval_status,
      x_reason_for_request,
      x_instructor_more_info,
      x_instructor_deny_info,
      x_student_more_info,
      x_transaction_type,
      x_request_type,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
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

    DELETE FROM igs_en_spl_perm
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_spl_perm_pkg;

/
