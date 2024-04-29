--------------------------------------------------------
--  DDL for Package Body IGS_TR_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_TR_ITEM_PKG" AS
/* $Header: IGSTI12B.pls 120.0 2005/06/01 21:06:26 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_tr_item_all%ROWTYPE;
  new_references igs_tr_item_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_tracking_status IN VARCHAR2 DEFAULT NULL,
    x_tracking_type IN VARCHAR2 DEFAULT NULL,
    x_source_person_id IN NUMBER DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_target_days IN NUMBER DEFAULT NULL,
    x_sequence_ind IN VARCHAR2 DEFAULT 'N',
    x_business_days_ind IN VARCHAR2 DEFAULT 'N',
    x_originator_person_id IN NUMBER DEFAULT NULL,
    x_s_created_ind IN VARCHAR2 DEFAULT 'N',
    x_override_offset_clc_ind IN VARCHAR2 DEFAULT 'N',
    x_completion_due_dt IN DATE DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_tr_item_all
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.tracking_id := x_tracking_id;
    new_references.tracking_status := x_tracking_status;
    new_references.tracking_type := x_tracking_type;
    new_references.source_person_id := x_source_person_id;
    new_references.start_dt := trunc(x_start_dt);
    new_references.target_days := x_target_days;
    new_references.sequence_ind := x_sequence_ind;
    new_references.business_days_ind := x_business_days_ind;
    new_references.originator_person_id := x_originator_person_id;
    new_references.s_created_ind := x_s_created_ind;
    new_references.override_offset_clc_ind := x_override_offset_clc_ind;
    new_references.completion_due_dt := trunc(x_completion_due_dt);
    new_references.publish_ind := x_publish_ind;
    new_references.org_id := x_org_id;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;

  END set_column_values;

  PROCEDURE beforerowinsertupdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
  ) AS

    v_message_name VARCHAR2(30);

  BEGIN

    -- Validate the tracking status.
    IF p_inserting OR (old_references.tracking_status <> new_references.tracking_status) THEN
      IF igs_tr_val_tri.trkp_val_tri_status (new_references.tracking_status,p_inserting,v_message_name) = FALSE THEN
        fnd_message.set_name('IGS',v_message_name);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    -- Validate the tracking type.
    IF p_inserting OR (old_references.tracking_type <> new_references.tracking_type) THEN
      IF igs_tr_val_tri.trkp_val_tri_type (new_references.tracking_type, v_message_name) = FALSE THEN
        fnd_message.set_name('IGS',v_message_name);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    -- Validate the start date.
    IF p_inserting OR (old_references.start_dt <> new_references.start_dt) THEN
      IF igs_tr_val_tri.trkp_val_tri_strt_dt ( new_references.start_dt, v_message_name) = FALSE THEN
        fnd_message.set_name('IGS',v_message_name);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    new_references.last_updated_by := fnd_global.user_id;
    new_references.last_update_date := SYSDATE;

  END beforerowinsertupdate1;

  PROCEDURE afterrowinsertupdatedelete2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
  ) AS

    v_message_name VARCHAR2(30);

  BEGIN

    IF p_inserting THEN
     igs_tr_gen_002.trkp_ins_dflt_trst ( new_references.tracking_id, v_message_name);
     IF v_message_name <> NULL THEN
       fnd_message.set_name('IGS',v_message_name);
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
     END IF;
    END IF;

  END afterrowinsertupdatedelete2;

  PROCEDURE check_constraints (
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value  IN VARCHAR2 DEFAULT NULL
  )AS

  BEGIN

    IF column_name IS NULL THEN
      NULL;

    ELSIF UPPER(column_name) = 'BUSINESS_DAYS_IND' THEN
      new_references.business_days_ind:= column_value ;

    ELSIF UPPER(column_name) = 'SEQUENCE_IND' THEN
      new_references.sequence_ind:= column_value ;

    ELSIF UPPER(column_name) = 'S_CREATED_IND' THEN
      new_references.s_created_ind:= column_value ;

    ELSIF UPPER(column_name) = 'TRACKING_STATUS' THEN
      new_references.tracking_status:= column_value ;

    ELSIF UPPER(column_name) = 'TRACKING_TYPE' THEN
      new_references.tracking_type:= column_value ;

    ELSIF UPPER(column_name) = 'TARGET_DAYS' THEN
      new_references.target_days:= igs_ge_number.to_num(column_value) ;

    ELSIF UPPER(column_name) = 'TRACKING_ID' THEN
      new_references.tracking_id:= igs_ge_number.to_num(column_value) ;

    ELSIF UPPER(column_name) = 'OVERRIDE_OFFSET_CLC_IND' THEN
      new_references.override_offset_clc_ind:= column_value ;

    ELSIF UPPER(column_name) = 'COMPLETION_DUE_DT' THEN
      new_references.completion_due_dt := column_value;

    ELSIF UPPER(column_name) = 'PUBLISH_IND' THEN
      new_references.publish_ind:= column_value ;

    END IF ;

    IF UPPER(column_name) = 'TRACKING_STATUS' OR column_name IS NULL THEN
      IF new_references.tracking_status<> UPPER(new_references.tracking_status) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception ;
      END IF;
    END IF ;

    IF UPPER(column_name) = 'TRACKING_TYPE' OR column_name IS NULL THEN
      IF new_references.tracking_type<> UPPER(new_references.tracking_type) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception ;
      END IF;
    END IF ;

    IF UPPER(column_name) = 'SEQUENCE_IND' OR column_name IS NULL THEN
      IF new_references.sequence_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception ;
      END IF;

    END IF ;
   --kumma, 2702342, Increased the value of constant from 999 to 9999
    IF UPPER(column_name) = 'TARGET_DAYS' OR column_name IS NULL THEN
      IF new_references.target_days < 0 OR new_references.target_days > 9999 THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception ;
      END IF;
    END IF ;

    IF UPPER(column_name) = 'TRACKING_ID' OR column_name IS NULL THEN
      IF new_references.tracking_id < 1 OR new_references.tracking_id > 999999999 THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception ;
      END IF;
    END IF ;

    IF UPPER(column_name) = 'BUSINESS_DAYS_IND' OR column_name IS NULL THEN
      IF new_references.business_days_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception ;
      END IF;
    END IF ;

    IF UPPER(column_name) = 'S_CREATED_IND' OR column_name IS NULL THEN
      IF new_references.s_created_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception ;
      END IF;
    END IF ;

    IF UPPER(column_name) = 'OVERRIDE_OFFSET_CLC_IND' OR column_name IS NULL THEN
      IF new_references.override_offset_clc_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'PUBLISH_IND' OR column_name IS NULL THEN
      IF new_references.publish_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF column_name IS NULL THEN
      IF (new_references.sequence_ind = 'Y' OR new_references.business_days_ind = 'Y') AND
         new_references.override_offset_clc_ind = 'Y' THEN
        fnd_message.set_name('IGS','IGS_TR_CANNOT_CHK_SEQ_OR_BD');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;

  PROCEDURE check_parent_existance AS
  BEGIN

    IF (((old_references.source_person_id = new_references.source_person_id)) OR
        ((new_references.source_person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_pe_person_pkg.get_pk_for_validation ( new_references.source_person_id ) THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (((old_references.originator_person_id = new_references.originator_person_id)) OR
        ((new_references.originator_person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_pe_person_pkg.get_pk_for_validation ( new_references.originator_person_id ) THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (((old_references.tracking_status = new_references.tracking_status)) OR
        ((new_references.tracking_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_tr_status_pkg.get_pk_for_validation ( new_references.tracking_status ) THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (((old_references.tracking_type = new_references.tracking_type)) OR
        ((new_references.tracking_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_tr_type_pkg.get_pk_for_validation ( new_references.tracking_type ) THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_parent_existance;

  PROCEDURE check_child_existance AS
  BEGIN

    igs_ad_ps_appl_inst_pkg.get_fk_igs_tr_item (
      old_references.tracking_id
    );

    igs_ad_ps_appl_inst_pkg.get_fk_igs_tr_item (
      old_references.tracking_id
    );

    igs_ad_ps_aplinstunt_pkg.get_fk_igs_tr_item (
      old_references.tracking_id
    );

    igs_as_su_atmpt_itm_pkg.get_fk_igs_tr_item (
      old_references.tracking_id
    );

    igs_re_thesis_exam_pkg.get_fk_igs_tr_item (
      old_references.tracking_id
    );

    igs_tr_group_member_pkg.get_fk_igs_tr_item (
      old_references.tracking_id
    );

    igs_tr_item_note_pkg.get_fk_igs_tr_item (
      old_references.tracking_id
    );

    igs_tr_step_pkg.get_fk_igs_tr_item (
      old_references.tracking_id
    );

  END check_child_existance;

  FUNCTION get_pk_for_validation (
    x_tracking_id IN NUMBER
  ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_tr_item_all
      WHERE    tracking_id = x_tracking_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN (TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN (FALSE);
    END IF;

  END get_pk_for_validation;

  PROCEDURE get_fk_igs_pe_person (
    x_person_id IN NUMBER
  ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_tr_item_all
      WHERE    source_person_id = x_person_id
      OR       originator_person_id = x_person_id ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_TR_TRI_PE_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_person;

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_tracking_status IN VARCHAR2 DEFAULT NULL,
    x_tracking_type IN VARCHAR2 DEFAULT NULL,
    x_source_person_id IN NUMBER DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_target_days IN NUMBER DEFAULT NULL,
    x_sequence_ind IN VARCHAR2 DEFAULT NULL,
    x_business_days_ind IN VARCHAR2 DEFAULT NULL,
    x_originator_person_id IN NUMBER DEFAULT NULL,
    x_s_created_ind IN VARCHAR2 DEFAULT NULL,
    x_override_offset_clc_ind IN VARCHAR2 DEFAULT NULL,
    x_completion_due_dt IN DATE DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_tracking_id,
      x_tracking_status,
      x_tracking_type,
      x_source_person_id,
      x_start_dt,
      x_target_days,
      x_sequence_ind,
      x_business_days_ind,
      x_originator_person_id,
      x_s_created_ind,
      x_override_offset_clc_ind,
      x_completion_due_dt,
      x_publish_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      beforerowinsertupdate1 ( p_inserting => TRUE );
      IF  get_pk_for_validation ( new_references.tracking_id ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;

    ELSIF (p_action = 'UPDATE') THEN
      beforerowinsertupdate1 ( p_updating => TRUE );
      check_constraints;
      check_parent_existance;

    ELSIF (p_action = 'DELETE') THEN
      check_child_existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
          beforerowinsertupdate1 ( p_inserting => TRUE );
      IF  get_pk_for_validation ( new_references.tracking_id ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      beforerowinsertupdate1 ( p_updating => TRUE );
      check_constraints;

    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;

    END IF;

  END before_dml;

  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      afterrowinsertupdatedelete2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      afterrowinsertupdatedelete2 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      afterrowinsertupdatedelete2 ( p_deleting => TRUE );
    END IF;

  END after_dml;

  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_status IN VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_source_person_id IN NUMBER,
    x_start_dt IN DATE,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_originator_person_id IN NUMBER,
    x_s_created_ind IN VARCHAR2,
    x_override_offset_clc_ind IN VARCHAR2 DEFAULT 'N',
    x_completion_due_dt IN DATE DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_org_id IN NUMBER
  ) AS

    CURSOR c IS
      SELECT ROWID
      FROM   igs_tr_item_all
      WHERE  tracking_id = x_tracking_id;

    x_last_update_date DATE;
    x_last_updated_by NUMBER;
    x_last_update_login NUMBER;
    x_request_id NUMBER;
    x_program_id NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date DATE;

  BEGIN

    x_last_update_date := SYSDATE;

    IF(x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;

    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;

      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;

      x_last_update_login :=fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;

      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id := NULL;
        x_program_id := NULL;
        x_program_application_id := NULL;
        x_program_update_date := NULL;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;

    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(p_action =>'INSERT',
      x_rowid =>x_rowid,
      x_tracking_id =>x_tracking_id,
      x_tracking_status=>x_tracking_status,
      x_tracking_type =>x_tracking_type,
      x_source_person_id=>x_source_person_id,
      x_start_dt=>x_start_dt,
      x_target_days =>x_target_days,
      x_sequence_ind=>NVL(x_sequence_ind,'N'),
      x_business_days_ind=>NVL(x_business_days_ind,'N'),
      x_originator_person_id=>x_originator_person_id,
      x_s_created_ind =>NVL(x_s_created_ind,'N'),
      x_override_offset_clc_ind => NVL(x_override_offset_clc_ind,'N'),
      x_completion_due_dt => x_completion_due_dt,
      x_publish_ind => NVL(x_publish_ind,'N'),
      x_creation_date => x_last_update_date,
      x_created_by => x_last_updated_by,
      x_last_update_date => x_last_update_date,
      x_last_updated_by => x_last_updated_by,
      x_last_update_login => x_last_update_login,
      x_org_id => igs_ge_gen_003.get_org_id
    );

    INSERT INTO igs_tr_item_all (
      tracking_id,
      tracking_status,
      tracking_type,
      source_person_id,
      start_dt,
      target_days,
      sequence_ind,
      business_days_ind,
      originator_person_id,
      s_created_ind,
      override_offset_clc_ind,
      completion_due_dt,
      publish_ind,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      new_references.tracking_id,
      new_references.tracking_status,
      new_references.tracking_type,
      new_references.source_person_id,
      new_references.start_dt,
      new_references.target_days,
      new_references.sequence_ind,
      new_references.business_days_ind,
      new_references.originator_person_id,
      new_references.s_created_ind,
      new_references.override_offset_clc_ind,
      new_references.completion_due_dt,
      new_references.publish_ind,
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE no_data_found;
    END IF;
    CLOSE c;

    after_dml(
      p_action =>'INSERT',
      x_rowid => x_rowid
    );

  END insert_row;

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_status IN VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_source_person_id IN NUMBER,
    x_start_dt IN DATE,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_originator_person_id IN NUMBER,
    x_s_created_ind IN VARCHAR2,
    x_override_offset_clc_ind IN VARCHAR2 DEFAULT 'N',
    x_completion_due_dt IN DATE DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N'
  ) AS

    CURSOR c1 IS
      SELECT  tracking_status, tracking_type, source_person_id, start_dt, target_days,
              sequence_ind, business_days_ind, originator_person_id, s_created_ind,
              override_offset_clc_ind, completion_due_dt, publish_ind
      FROM    igs_tr_item_all
      WHERE   ROWID = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF ( (tlinfo.tracking_status = x_tracking_status)
      AND (tlinfo.tracking_type = x_tracking_type)
      AND ((tlinfo.source_person_id = x_source_person_id)
           OR ((tlinfo.source_person_id IS NULL)
               AND (x_source_person_id IS NULL)))
      AND (trunc(tlinfo.start_dt) =trunc(x_start_dt))
      AND (tlinfo.target_days = x_target_days)
      AND (tlinfo.sequence_ind = x_sequence_ind)
      AND (tlinfo.business_days_ind = x_business_days_ind)
      AND (tlinfo.originator_person_id = x_originator_person_id)
      AND (tlinfo.s_created_ind = x_s_created_ind)
      AND ((tlinfo.override_offset_clc_ind = x_override_offset_clc_ind)
        OR ((tlinfo.override_offset_clc_ind IS NULL)
        AND (x_override_offset_clc_ind IS NULL)))
      AND ((tlinfo.publish_ind = x_publish_ind)
        OR ((tlinfo.publish_ind IS NULL)
        AND (x_publish_ind IS NULL)))
      AND ((trunc(tlinfo.completion_due_dt)= trunc(x_completion_due_dt))
        OR ((tlinfo.completion_due_dt IS NULL)
        AND (x_completion_due_dt IS NULL)))
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
    x_rowid IN VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_status IN VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_source_person_id IN NUMBER,
    x_start_dt IN DATE,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_originator_person_id IN NUMBER,
    x_s_created_ind IN VARCHAR2,
    x_override_offset_clc_ind IN VARCHAR2 DEFAULT 'N',
    x_completion_due_dt IN DATE DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS
    x_last_update_date DATE;
    x_last_updated_by NUMBER;
    x_last_update_login NUMBER;
    x_request_id NUMBER;
    x_program_id NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date DATE;

  BEGIN

    x_last_update_date := SYSDATE;

    IF(x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;

    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;

      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;

      x_last_update_login :=fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;

    ELSE
      fnd_message.set_name('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(p_action =>'UPDATE',
      x_rowid =>x_rowid,
      x_tracking_id =>x_tracking_id,
      x_tracking_status=>x_tracking_status,
      x_tracking_type =>x_tracking_type,
      x_source_person_id=>x_source_person_id,
      x_start_dt=>x_start_dt,
      x_target_days =>x_target_days,
      x_sequence_ind=>x_sequence_ind,
      x_business_days_ind=>x_business_days_ind,
      x_originator_person_id=>x_originator_person_id,
      x_s_created_ind =>x_s_created_ind,
      x_override_offset_clc_ind => x_override_offset_clc_ind,
      x_completion_due_dt => x_completion_due_dt,
      x_publish_ind => x_publish_ind,
      x_creation_date => x_last_update_date,
      x_created_by => x_last_updated_by,
      x_last_update_date => x_last_update_date,
      x_last_updated_by => x_last_updated_by,
      x_last_update_login => x_last_update_login
    );

    IF (x_mode = 'R') THEN
      x_request_id :=fnd_global.conc_request_id;
      x_program_id :=fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
      ELSE
      x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igs_tr_item_all SET
      tracking_status = new_references.tracking_status,
      tracking_type = new_references.tracking_type,
      source_person_id = new_references.source_person_id,
      start_dt = new_references.start_dt,
      target_days = new_references.target_days,
      sequence_ind = new_references.sequence_ind,
      business_days_ind = new_references.business_days_ind,
      originator_person_id = new_references.originator_person_id,
      s_created_ind = new_references.s_created_ind,
      override_offset_clc_ind = new_references.override_offset_clc_ind,
      completion_due_dt = new_references.completion_due_dt,
      publish_ind = new_references.publish_ind,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by,
      last_update_login = x_last_update_login,
      request_id = x_request_id,
      program_id = x_program_id,
      program_application_id = x_program_application_id,
      program_update_date = x_program_update_date
    WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

    after_dml(
      p_action =>'UPDATE',
      x_rowid => x_rowid
    );

  END update_row;

  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_status IN VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_source_person_id IN NUMBER,
    x_start_dt IN DATE,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_originator_person_id IN NUMBER,
    x_s_created_ind IN VARCHAR2,
    x_override_offset_clc_ind IN VARCHAR2 DEFAULT 'N',
    x_completion_due_dt IN DATE DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_org_id IN NUMBER
  ) AS

    CURSOR c1 IS
      SELECT ROWID
      FROM   igs_tr_item_all
      WHERE tracking_id = x_tracking_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;

    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_tracking_id,
        x_tracking_status,
        x_tracking_type,
        x_source_person_id,
        x_start_dt,
        x_target_days,
        x_sequence_ind,
        x_business_days_ind,
        x_originator_person_id,
        x_s_created_ind,
        x_override_offset_clc_ind,
        x_completion_due_dt,
        x_publish_ind,
        x_mode,
        x_org_id
       );
       RETURN;
     END IF;

     CLOSE c1;

     update_row (
       x_rowid,
       x_tracking_id,
       x_tracking_status,
       x_tracking_type,
       x_source_person_id,
       x_start_dt,
       x_target_days,
       x_sequence_ind,
       x_business_days_ind,
       x_originator_person_id,
       x_s_created_ind,
       x_override_offset_clc_ind,
       x_completion_due_dt,
       x_publish_ind,
       x_mode
     );

  END add_row;

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    before_dml(
      p_action =>'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igs_tr_item_all WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

    after_dml(
      p_action =>'DELETE',
      x_rowid => x_rowid
    );

  END delete_row;

END igs_tr_item_pkg;

/
