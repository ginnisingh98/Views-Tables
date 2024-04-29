--------------------------------------------------------
--  DDL for Package Body IGS_RE_THESIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_THESIS_PKG" AS
/* $Header: IGSRI15B.pls 120.1 2005/07/04 00:42:16 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --Nishikant   19NOV2002       Bug#2661533. In the procedure BeforeRowInsertUpdate1 the calls of the functions
  --                            igs_re_val_the.resp_val_the_expct, igs_re_val_the.resp_val_the_embrg,
  --                            igs_re_val_the.resp_val_the_thr got modified to add one more parameer p_legacy.
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_re_val_the.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_RE_THESIS_ALL%RowType;
  new_references IGS_RE_THESIS_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER,
    x_title IN VARCHAR2,
    x_final_title_ind IN VARCHAR2,
    x_short_title IN VARCHAR2,
    x_abbreviated_title IN VARCHAR2,
    x_thesis_result_cd IN VARCHAR2,
    x_expected_submission_dt IN DATE,
    x_library_lodgement_dt IN DATE,
    x_library_catalogue_number IN VARCHAR2,
    x_embargo_expiry_dt IN DATE,
    x_thesis_format IN VARCHAR2,
    x_logical_delete_dt IN DATE,
    x_embargo_details IN VARCHAR2,
    x_thesis_topic IN VARCHAR2,
    x_citation IN VARCHAR2,
    x_comments IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER  ,
    x_org_id IN NUMBER
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_THESIS_ALL
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.ca_sequence_number := x_ca_sequence_number;
    new_references.sequence_number := x_sequence_number;
    new_references.title := x_title;
    new_references.final_title_ind := x_final_title_ind;
    new_references.short_title := x_short_title;
    new_references.abbreviated_title := x_abbreviated_title;
    new_references.thesis_result_cd := x_thesis_result_cd;
    new_references.expected_submission_dt := x_expected_submission_dt;
    new_references.library_lodgement_dt := x_library_lodgement_dt;
    new_references.library_catalogue_number := x_library_catalogue_number;
    new_references.embargo_expiry_dt := x_embargo_expiry_dt;
    new_references.thesis_format := x_thesis_format;
    new_references.logical_delete_dt := x_logical_delete_dt;
    new_references.embargo_details := x_embargo_details;
    new_references.thesis_topic := x_thesis_topic;
    new_references.citation := x_citation;
    new_references.comments := x_comments;
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
  END Set_Column_Values;
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
        v_message_name  VARCHAR2(30);
        v_thesis_status IGS_RE_THESIS_V.thesis_status%TYPE;
  BEGIN
        -- Turn off trigger validation when performing insert of IGS_RE_CANDIDATURE details
        -- as a result of IGS_PS_COURSE transfer
        IF igs_as_val_suaap.genp_val_sdtt_sess('ENRP_INS_CA_TRNSFR') THEN
                IF p_inserting THEN
                        -- Call function to get the status to stop mutating trigger.
                        v_thesis_status := IGS_RE_GEN_002.resp_get_the_status(  new_references.person_id,
                                                                new_references.ca_sequence_number,
                                                                new_references.sequence_number,
                                                                'Y',
                                                                new_references.logical_delete_dt,
                                                                new_references.thesis_result_cd);
                ELSIF p_updating THEN
                        -- Call function with old values as most validations are based
                        -- on the status on the screen.
                        v_thesis_status := IGS_RE_GEN_002.resp_get_the_status(  new_references.person_id,
                                                                new_references.ca_sequence_number,
                                                                new_references.sequence_number,
                                                                'Y',
                                                                old_references.logical_delete_dt,
                                                                old_references.thesis_result_cd);
                END IF;
                IF p_updating THEN
                        -- If any field except logical deletion date is changing then validate
                        -- whether update is possible.
                        IF old_references.title <> new_references.title OR
                         old_references.final_title_ind <> new_references.final_title_ind OR
                          NVL(old_references.short_title,' ') <> NVL(new_references.short_title,' ') OR
                          NVL(old_references.abbreviated_title,' ') <> NVL(new_references.abbreviated_title,' ') OR
                          NVL(old_references.thesis_result_cd,' ') <> NVL(new_references.thesis_result_cd,' ') OR
                          NVL(old_references.expected_submission_dt,igs_ge_date.igsdate('1900/01/01')) <>
                                        NVL(new_references.expected_submission_dt,igs_ge_date.igsdate('1900/01/01')) OR
                           NVL(old_references.library_lodgement_dt,igs_ge_date.igsdate('1900/01/01')) <>
                                        NVL(new_references.library_lodgement_dt,igs_ge_date.igsdate('1900/01/01')) OR
                          NVL(old_references.library_catalogue_number,' ') <>
                                        NVL(new_references.library_catalogue_number,' ') OR
                           NVL(old_references.embargo_expiry_dt,igs_ge_date.igsdate('1900/01/01')) <>
                           NVL(new_references.embargo_expiry_dt,igs_ge_date.igsdate('1900/01/01')) OR
                           NVL(old_references.thesis_format,' ') <> NVL(new_references.thesis_format,' ') OR
                           NVL(old_references.embargo_details,' ') <> NVL(new_references.embargo_details,' ') OR
                           NVL(old_references.thesis_topic,' ') <> NVL(new_references.thesis_topic,' ') OR
                           NVL(old_references.citation,' ') <> NVL(new_references.citation,' ') OR
                           NVL(old_references.comments,' ') <> NVL(new_references.comments,' ') THEN
                                IF IGS_RE_VAL_THE.resp_val_the_upd(new_references.logical_delete_dt,
                                                        v_message_name) = FALSE THEN
                                                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                                                IGS_GE_MSG_STACK.ADD;
                                                                App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                END IF;
                IF p_updating THEN
                        -- Validate the IGS_RE_THESIS final title indicator.
                        IF old_references.final_title_ind <> new_references.final_title_ind THEN
                                IF IGS_RE_VAL_THE.resp_val_the_fnl(     new_references.person_id,
                                                                new_references.ca_sequence_number,
                                                                new_references.sequence_number,
                                                                new_references.final_title_ind,
                                                                v_thesis_status,
                                                                v_message_name) = FALSE THEN
                                                                        Fnd_Message.Set_Name ('IGS', v_message_name);
                                                                        IGS_GE_MSG_STACK.ADD;
                                                                        App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                        -- Validate the IGS_RE_THESIS IGS_PE_TITLE
                        IF old_references.title <> new_references.title THEN
                                IF IGS_RE_VAL_THE.resp_val_the_ttl(     old_references.title,
                                                                new_references.title,
                                                                old_references.thesis_result_cd,
                                                                v_message_name) = FALSE THEN
                                                                        Fnd_Message.Set_Name ('IGS', v_message_name);
                                                                        IGS_GE_MSG_STACK.ADD;
                                                                        App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                END IF;
                IF p_inserting OR
                   ( p_updating AND
                         NVL(old_references.embargo_details,' ') <> NVL(new_references.embargo_details,' ') OR
                         NVL(old_references.embargo_expiry_dt,igs_ge_date.igsdate('1900/01/01')) <>
                                        NVL(new_references.embargo_expiry_dt,igs_ge_date.igsdate('1900/01/01'))) THEN
                        -- Validate embargo details
                        IF IGS_RE_VAL_THE.resp_val_the_embrg(   new_references.embargo_details,
                                                        old_references.embargo_expiry_dt,
                                                        new_references.embargo_expiry_dt,
                                                        v_thesis_status,
                                                        'N', --p_legacy parameter
                                                        v_message_name) = FALSE THEN
                                                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                                                IGS_GE_MSG_STACK.ADD;
                                                                App_Exception.Raise_Exception;
                        END IF;
                END IF;
                IF p_inserting OR
                   ( p_updating AND
                        NVL(old_references.citation,' ') <> NVL(new_references.citation,' ')) THEN
                        -- Validate citation
                        IF IGS_RE_VAL_THE.resp_val_the_ctn(     v_thesis_status,
                                                        new_references.citation,
                                                        v_message_name) = FALSE THEN
                                                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                                                IGS_GE_MSG_STACK.ADD;
                                                                App_Exception.Raise_Exception;
                        END IF;
                END IF;
                IF p_inserting OR
                   ( p_updating AND
                         NVL(old_references.library_catalogue_number,' ') <>
                                        NVL(new_references.library_catalogue_number,' ') OR
                         NVL(old_references.library_lodgement_dt,igs_ge_date.igsdate('1900/01/01')) <>
                                        NVL(new_references.library_lodgement_dt,igs_ge_date.igsdate('1900/01/01'))) THEN
                        -- Validate library details
                        IF IGS_RE_VAL_THE.resp_val_the_lbry(    new_references.person_id,
                                                        new_references.ca_sequence_number,
                                                        new_references.sequence_number,
                                                        new_references.library_catalogue_number,
                                                        new_references.library_lodgement_dt,
                                                        v_thesis_status,
                                                        v_message_name) = FALSE THEN
                                                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                                                IGS_GE_MSG_STACK.ADD;
                                                                App_Exception.Raise_Exception;
                        END IF;
                END IF;
                IF p_inserting OR
                   (p_updating AND
                        NVL(old_references.thesis_result_cd,' ') <> NVL(new_references.thesis_result_cd,' ')) THEN
                        -- Validate IGS_RE_THESIS result code
                        IF IGS_RE_VAL_THE.resp_val_the_thr(     new_references.person_id,
                                                        new_references.ca_sequence_number,
                                                        new_references.sequence_number,
                                                        new_references.thesis_result_cd,
                                                        v_thesis_status,
                                                        'N', --p_legacy parameter
                                                        v_message_name) = FALSE THEN
                                                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                                                IGS_GE_MSG_STACK.ADD;
                                                                App_Exception.Raise_Exception;
                        END IF;
                END IF;
                IF p_updating THEN
                        IF old_references.logical_delete_dt IS NULL AND new_references.logical_delete_dt IS NOT NULL THEN
                                IF IGS_RE_VAL_THE.resp_val_the_del(     new_references.person_id,
                                                                new_references.ca_sequence_number,
                                                                new_references.sequence_number,
                                                                new_references.logical_delete_dt,
                                                                v_thesis_status,
                                                                v_message_name) = FALSE THEN
                                                                        Fnd_Message.Set_Name ('IGS', v_message_name);
                                                                        IGS_GE_MSG_STACK.ADD;
                                                                        App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                END IF;
                IF p_updating AND
                    ( NVL(old_references.logical_delete_dt,igs_ge_date.igsdate('1900/01/01')) <>
                                NVL(new_references.logical_delete_dt,igs_ge_date.igsdate('1900/01/01'))) THEN
                        IF IGS_RE_VAL_THE.resp_val_the_del_dt(  old_references.logical_delete_dt,
                                                        new_references.logical_delete_dt,
                                                        v_message_name) = FALSE THEN
                                                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                                                IGS_GE_MSG_STACK.ADD;
                                                                App_Exception.Raise_Exception;
                        END IF;
                END IF;
                IF p_inserting OR
                   ( p_updating AND
                     ( new_references.expected_submission_dt IS NOT NULL AND
                           NVL(old_references.expected_submission_dt,igs_ge_date.igsdate('1900/01/01')) <>
                                                                                        new_references.expected_submission_dt)) THEN
                        IF IGS_RE_VAL_THE.resp_val_the_expct(   new_references.person_id,
                                                                new_references.ca_sequence_number,
                                                                new_references.expected_submission_dt,
                                                                'N', --p_legacy
                                                                v_message_name) = FALSE THEN
                                                                        Fnd_Message.Set_Name ('IGS', v_message_name);
                                                                        IGS_GE_MSG_STACK.ADD;
                                                                        App_Exception.Raise_Exception;
                        END IF;
                END IF;
        END IF;
  END BeforeRowInsertUpdate1;
  PROCEDURE AfterRowUpdateDelete2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS

  l_deleted igs_re_thesis.final_title_ind%TYPE;

  BEGIN
        IF p_updating OR p_deleting THEN
                IGS_RE_GEN_003.RESP_INS_THE_HIST(old_references.person_id,
                        old_references.ca_sequence_number,
                        old_references.sequence_number,
                        old_references.title,
                        new_references.title,
                        old_references.final_title_ind,
                        new_references.final_title_ind,
                        old_references.short_title,
                        new_references.short_title,
                        old_references.abbreviated_title,
                        new_references.abbreviated_title,
                        old_references.thesis_result_cd,
                        new_references.thesis_result_cd,
                        old_references.expected_submission_dt,
                        new_references.expected_submission_dt,
                        old_references.library_lodgement_dt,
                        new_references.library_lodgement_dt,
                        old_references.library_catalogue_number,
                        new_references.library_catalogue_number,
                        old_references.embargo_expiry_dt,
                        new_references.embargo_expiry_dt,
                        old_references.thesis_format,
                        new_references.thesis_format,
                        old_references.logical_delete_dt,
                        new_references.logical_delete_dt,
                        old_references.embargo_details,
                        new_references.embargo_details,
                        old_references.thesis_topic,
                        new_references.thesis_topic,
                        old_references.citation,
                        new_references.citation,
                        old_references.comments,
                        new_references.comments,
                        old_references.last_updated_by,
                        new_references.last_updated_by,
                        old_references.last_update_date,
                        new_references.last_update_date);
        END IF;


   --   Bug # 2829275 . UK Correspondence.The thesis event is raised when there is a change in thesis attributes.


	  IF new_references.logical_delete_dt IS NOT NULL THEN
                  l_deleted := 'Y';
          ELSIF new_references.logical_delete_dt IS NULL THEN
                  l_deleted := 'N';
          END IF;

	IF p_inserting
	  OR (p_updating AND (
	      (new_references.title <> old_references.title
	       OR (new_references.thesis_topic <> old_references.thesis_topic)
	       OR (new_references.thesis_topic IS NULL AND old_references.thesis_topic IS NOT NULL)
	       OR (new_references.thesis_topic IS NOT NULL AND old_references.thesis_topic IS NULL)
	      )
  	  OR (new_references.final_title_ind <> old_references.final_title_ind AND new_references.final_title_ind = 'Y')
	  OR ( old_references.logical_delete_dt IS NULL AND new_references.logical_delete_dt IS NOT NULL)
	  OR ( old_references.logical_delete_dt IS NOT NULL AND new_references.logical_delete_dt IS NULL) )) THEN


	    igs_re_workflow.rethesis_event (
				p_personid      => new_references.person_id,
				p_ca_seq_num    => new_references.ca_sequence_number,
				p_thesistopic   => new_references.thesis_topic,
				p_thesistitle	=> new_references.title,
				p_approved	=> new_references.final_title_ind,
				p_deleted	=> l_deleted
                                   );

  	END IF;

  END AfterRowUpdateDelete2;
  PROCEDURE Check_Constraints (
    Column_Name in VARCHAR2 ,
    Column_Value in VARCHAR2
  ) AS
 BEGIN
 IF Column_Name is null then
   NULL;
 ELSIF upper(Column_name) = 'CA_SEQUENCE_NUMBER' THEN
   new_references.CA_SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'FINAL_TITLE_IND' THEN
   new_references.FINAL_TITLE_IND := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' THEN
   new_references.SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'LIBRARY_CATALOGUE_NUMBER' THEN
   new_references.LIBRARY_CATALOGUE_NUMBER := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'THESIS_FORMAT' THEN
   new_references.THESIS_FORMAT := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'THESIS_RESULT_CD' THEN
   new_references.THESIS_RESULT_CD := COLUMN_VALUE ;
 END IF;
  IF upper(column_name) = 'CA_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.CA_SEQUENCE_NUMBER < 1 OR new_references.CA_SEQUENCE_NUMBER > 999999 then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
  IF upper(column_name) = 'FINAL_TITLE_IND' OR COLUMN_NAME IS NULL THEN
    IF new_references.FINAL_TITLE_IND <> upper(NEW_REFERENCES.FINAL_TITLE_IND) OR
        new_references.FINAL_TITLE_IND NOT IN ('Y', 'N') then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
  IF upper(column_name) = 'SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.SEQUENCE_NUMBER < 1 OR new_references.SEQUENCE_NUMBER > 999999 then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
  IF upper(column_name) = 'LIBRARY_CATALOGUE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.LIBRARY_CATALOGUE_NUMBER <> NEW_REFERENCES.LIBRARY_CATALOGUE_NUMBER then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
  IF upper(column_name) = 'THESIS_FORMAT' OR COLUMN_NAME IS NULL THEN
    IF new_references.THESIS_FORMAT <> NEW_REFERENCES.THESIS_FORMAT then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
  IF upper(column_name) = 'THESIS_RESULT_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.THESIS_RESULT_CD <> upper(NEW_REFERENCES.THESIS_RESULT_CD) then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
 END Check_Constraints ;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.ca_sequence_number = new_references.ca_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.ca_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_CANDIDATURE_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.ca_sequence_number
        ) THEN
             Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
       END IF;
    END IF;
    IF (((old_references.thesis_result_cd = new_references.thesis_result_cd)) OR
        ((new_references.thesis_result_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_THESIS_RESULT_PKG.Get_PK_For_Validation (
        new_references.thesis_result_cd
        ) THEN
             Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
       END IF;
    END IF;
  END Check_Parent_Existance;
  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_RE_THESIS_EXAM_PKG.GET_FK_IGS_RE_THESIS (
      old_references.person_id,
      old_references.ca_sequence_number,
      old_references.sequence_number
      );
  END Check_Child_Existance;
  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THESIS_ALL
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      sequence_number = x_sequence_number
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
        RETURN(TRUE);
    ELSE
        Close cur_rowid;
        RETURN(FALSE);
    END IF;
  END Get_PK_For_Validation;
  PROCEDURE GET_FK_IGS_RE_CANDIDATURE (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THESIS_ALL
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_THE_CA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_RE_CANDIDATURE;
  PROCEDURE GET_FK_IGS_RE_THESIS_RESULT (
    x_thesis_result_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THESIS_ALL
      WHERE    thesis_result_cd = x_thesis_result_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_THE_THR_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_RE_THESIS_RESULT;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER,
    x_title IN VARCHAR2,
    x_final_title_ind IN VARCHAR2,
    x_short_title IN VARCHAR2,
    x_abbreviated_title IN VARCHAR2,
    x_thesis_result_cd IN VARCHAR2,
    x_expected_submission_dt IN DATE,
    x_library_lodgement_dt IN DATE,
    x_library_catalogue_number IN VARCHAR2,
    x_embargo_expiry_dt IN DATE,
    x_thesis_format IN VARCHAR2,
    x_logical_delete_dt IN DATE,
    x_embargo_details IN VARCHAR2,
    x_thesis_topic IN VARCHAR2,
    x_citation IN VARCHAR2,
    x_comments IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_org_id IN NUMBER
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_ca_sequence_number,
      x_sequence_number,
      x_title,
      x_final_title_ind,
      x_short_title,
      x_abbreviated_title,
      x_thesis_result_cd,
      x_expected_submission_dt,
      x_library_lodgement_dt,
      x_library_catalogue_number,
      x_embargo_expiry_dt,
      x_thesis_format,
      x_logical_delete_dt,
      x_embargo_details,
      x_thesis_topic,
      x_citation,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE,
                               p_updating  => FALSE,
                               p_deleting  => FALSE);
      IF Get_PK_For_Validation (
            new_references.person_id,
            new_references.ca_sequence_number,
            new_references.sequence_number
      ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_inserting => FALSE,
                               p_updating  => TRUE,
                               p_deleting  => FALSE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
            new_references.person_id,
            new_references.ca_sequence_number,
            new_references.sequence_number
      ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;
  END Before_DML;
  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdateDelete2 ( p_inserting => FALSE,
                              p_updating  => TRUE,
                              p_deleting  => FALSE);
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowUpdateDelete2 ( p_inserting => FALSE,
                              p_updating  => FALSE,
                              p_deleting  => TRUE);
    ELSIF (p_action = 'INSERT') THEN

     AfterRowUpdateDelete2 (  p_inserting => TRUE,
                              p_updating  => FALSE,
                              p_deleting  => FALSE);

    END IF;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_LIBRARY_LODGEMENT_DT in DATE,
  X_LIBRARY_CATALOGUE_NUMBER in VARCHAR2,
  X_EMBARGO_EXPIRY_DT in DATE,
  X_THESIS_FORMAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_EMBARGO_DETAILS in VARCHAR2,
  X_THESIS_TOPIC in VARCHAR2,
  X_CITATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ORG_ID in NUMBER
  ) as
    cursor C is select ROWID from IGS_RE_THESIS_ALL
      where PERSON_ID = X_PERSON_ID
      and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_title => X_TITLE,
    x_final_title_ind => NVL(X_FINAL_TITLE_IND, 'N'),
    x_short_title => X_SHORT_TITLE,
    x_abbreviated_title => X_ABBREVIATED_TITLE,
    x_thesis_result_cd => X_THESIS_RESULT_CD,
    x_expected_submission_dt => X_EXPECTED_SUBMISSION_DT,
    x_library_lodgement_dt => X_LIBRARY_LODGEMENT_DT,
    x_library_catalogue_number => X_LIBRARY_CATALOGUE_NUMBER,
    x_embargo_expiry_dt => X_EMBARGO_EXPIRY_DT,
    x_thesis_format => X_THESIS_FORMAT,
    x_logical_delete_dt => X_LOGICAL_DELETE_DT,
    x_embargo_details => X_EMBARGO_DETAILS,
    x_thesis_topic => X_THESIS_TOPIC,
    x_citation => X_CITATION,
    x_comments => X_COMMENTS,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
 );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_RE_THESIS_ALL (
    PERSON_ID,
    CA_SEQUENCE_NUMBER,
    SEQUENCE_NUMBER,
    TITLE,
    FINAL_TITLE_IND,
    SHORT_TITLE,
    ABBREVIATED_TITLE,
    THESIS_RESULT_CD,
    EXPECTED_SUBMISSION_DT,
    LIBRARY_LODGEMENT_DT,
    LIBRARY_CATALOGUE_NUMBER,
    EMBARGO_EXPIRY_DT,
    THESIS_FORMAT,
    LOGICAL_DELETE_DT,
    EMBARGO_DETAILS,
    THESIS_TOPIC,
    CITATION,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.CA_SEQUENCE_NUMBER,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.TITLE,
    NEW_REFERENCES.FINAL_TITLE_IND,
    NEW_REFERENCES.SHORT_TITLE,
    NEW_REFERENCES.ABBREVIATED_TITLE,
    NEW_REFERENCES.THESIS_RESULT_CD,
    NEW_REFERENCES.EXPECTED_SUBMISSION_DT,
    NEW_REFERENCES.LIBRARY_LODGEMENT_DT,
    NEW_REFERENCES.LIBRARY_CATALOGUE_NUMBER,
    NEW_REFERENCES.EMBARGO_EXPIRY_DT,
    NEW_REFERENCES.THESIS_FORMAT,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
    NEW_REFERENCES.EMBARGO_DETAILS,
    NEW_REFERENCES.THESIS_TOPIC,
    NEW_REFERENCES.CITATION,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

After_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID
  );


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

end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_LIBRARY_LODGEMENT_DT in DATE,
  X_LIBRARY_CATALOGUE_NUMBER in VARCHAR2,
  X_EMBARGO_EXPIRY_DT in DATE,
  X_THESIS_FORMAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_EMBARGO_DETAILS in VARCHAR2,
  X_THESIS_TOPIC in VARCHAR2,
  X_CITATION in VARCHAR2,
  X_COMMENTS in VARCHAR2
) as
  cursor c1 is select
      TITLE,
      FINAL_TITLE_IND,
      SHORT_TITLE,
      ABBREVIATED_TITLE,
      THESIS_RESULT_CD,
      EXPECTED_SUBMISSION_DT,
      LIBRARY_LODGEMENT_DT,
      LIBRARY_CATALOGUE_NUMBER,
      EMBARGO_EXPIRY_DT,
      THESIS_FORMAT,
      LOGICAL_DELETE_DT,
      EMBARGO_DETAILS,
      THESIS_TOPIC,
      CITATION,
      COMMENTS
    from IGS_RE_THESIS_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    return;
  end if;
  close c1;
  if ( (tlinfo.TITLE = X_TITLE)
      AND (tlinfo.FINAL_TITLE_IND = X_FINAL_TITLE_IND)
      AND ((tlinfo.SHORT_TITLE = X_SHORT_TITLE)
           OR ((tlinfo.SHORT_TITLE is null)
               AND (X_SHORT_TITLE is null)))
      AND ((tlinfo.ABBREVIATED_TITLE = X_ABBREVIATED_TITLE)
           OR ((tlinfo.ABBREVIATED_TITLE is null)
               AND (X_ABBREVIATED_TITLE is null)))
      AND ((tlinfo.THESIS_RESULT_CD = X_THESIS_RESULT_CD)
           OR ((tlinfo.THESIS_RESULT_CD is null)
               AND (X_THESIS_RESULT_CD is null)))
      AND ((tlinfo.EXPECTED_SUBMISSION_DT = X_EXPECTED_SUBMISSION_DT)
           OR ((tlinfo.EXPECTED_SUBMISSION_DT is null)
               AND (X_EXPECTED_SUBMISSION_DT is null)))
      AND ((tlinfo.LIBRARY_LODGEMENT_DT = X_LIBRARY_LODGEMENT_DT)
           OR ((tlinfo.LIBRARY_LODGEMENT_DT is null)
               AND (X_LIBRARY_LODGEMENT_DT is null)))
      AND ((tlinfo.LIBRARY_CATALOGUE_NUMBER = X_LIBRARY_CATALOGUE_NUMBER)
           OR ((tlinfo.LIBRARY_CATALOGUE_NUMBER is null)
               AND (X_LIBRARY_CATALOGUE_NUMBER is null)))
      AND ((tlinfo.EMBARGO_EXPIRY_DT = X_EMBARGO_EXPIRY_DT)
           OR ((tlinfo.EMBARGO_EXPIRY_DT is null)
               AND (X_EMBARGO_EXPIRY_DT is null)))
      AND ((tlinfo.THESIS_FORMAT = X_THESIS_FORMAT)
           OR ((tlinfo.THESIS_FORMAT is null)
               AND (X_THESIS_FORMAT is null)))
      AND ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
      AND ((tlinfo.EMBARGO_DETAILS = X_EMBARGO_DETAILS)
           OR ((tlinfo.EMBARGO_DETAILS is null)
               AND (X_EMBARGO_DETAILS is null)))
      AND ((tlinfo.THESIS_TOPIC = X_THESIS_TOPIC)
           OR ((tlinfo.THESIS_TOPIC is null)
               AND (X_THESIS_TOPIC is null)))
      AND ((tlinfo.CITATION = X_CITATION)
           OR ((tlinfo.CITATION is null)
               AND (X_CITATION is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_LIBRARY_LODGEMENT_DT in DATE,
  X_LIBRARY_CATALOGUE_NUMBER in VARCHAR2,
  X_EMBARGO_EXPIRY_DT in DATE,
  X_THESIS_FORMAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_EMBARGO_DETAILS in VARCHAR2,
  X_THESIS_TOPIC in VARCHAR2,
  X_CITATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_title => X_TITLE,
    x_final_title_ind => X_FINAL_TITLE_IND,
    x_short_title => X_SHORT_TITLE,
    x_abbreviated_title => X_ABBREVIATED_TITLE,
    x_thesis_result_cd => X_THESIS_RESULT_CD,
    x_expected_submission_dt => X_EXPECTED_SUBMISSION_DT,
    x_library_lodgement_dt => X_LIBRARY_LODGEMENT_DT,
    x_library_catalogue_number => X_LIBRARY_CATALOGUE_NUMBER,
    x_embargo_expiry_dt => X_EMBARGO_EXPIRY_DT,
    x_thesis_format => X_THESIS_FORMAT,
    x_logical_delete_dt => X_LOGICAL_DELETE_DT,
    x_embargo_details => X_EMBARGO_DETAILS,
    x_thesis_topic => X_THESIS_TOPIC,
    x_citation => X_CITATION,
    x_comments => X_COMMENTS,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_RE_THESIS_ALL set
    TITLE = NEW_REFERENCES.TITLE,
    FINAL_TITLE_IND = NEW_REFERENCES.FINAL_TITLE_IND,
    SHORT_TITLE = NEW_REFERENCES.SHORT_TITLE,
    ABBREVIATED_TITLE = NEW_REFERENCES.ABBREVIATED_TITLE,
    THESIS_RESULT_CD = NEW_REFERENCES.THESIS_RESULT_CD,
    EXPECTED_SUBMISSION_DT = NEW_REFERENCES.EXPECTED_SUBMISSION_DT,
    LIBRARY_LODGEMENT_DT = NEW_REFERENCES.LIBRARY_LODGEMENT_DT,
    LIBRARY_CATALOGUE_NUMBER = NEW_REFERENCES.LIBRARY_CATALOGUE_NUMBER,
    EMBARGO_EXPIRY_DT = NEW_REFERENCES.EMBARGO_EXPIRY_DT,
    THESIS_FORMAT = NEW_REFERENCES.THESIS_FORMAT,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
    EMBARGO_DETAILS = NEW_REFERENCES.EMBARGO_DETAILS,
    THESIS_TOPIC = NEW_REFERENCES.THESIS_TOPIC,
    CITATION = NEW_REFERENCES.CITATION,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

 After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID
  );
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

end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_LIBRARY_LODGEMENT_DT in DATE,
  X_LIBRARY_CATALOGUE_NUMBER in VARCHAR2,
  X_EMBARGO_EXPIRY_DT in DATE,
  X_THESIS_FORMAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_EMBARGO_DETAILS in VARCHAR2,
  X_THESIS_TOPIC in VARCHAR2,
  X_CITATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ORG_ID in NUMBER
  ) as
  cursor c1 is select rowid from IGS_RE_THESIS_ALL
     where PERSON_ID = X_PERSON_ID
     and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_CA_SEQUENCE_NUMBER,
     X_SEQUENCE_NUMBER,
     X_TITLE,
     X_FINAL_TITLE_IND,
     X_SHORT_TITLE,
     X_ABBREVIATED_TITLE,
     X_THESIS_RESULT_CD,
     X_EXPECTED_SUBMISSION_DT,
     X_LIBRARY_LODGEMENT_DT,
     X_LIBRARY_CATALOGUE_NUMBER,
     X_EMBARGO_EXPIRY_DT,
     X_THESIS_FORMAT,
     X_LOGICAL_DELETE_DT,
     X_EMBARGO_DETAILS,
     X_THESIS_TOPIC,
     X_CITATION,
     X_COMMENTS,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_CA_SEQUENCE_NUMBER,
   X_SEQUENCE_NUMBER,
   X_TITLE,
   X_FINAL_TITLE_IND,
   X_SHORT_TITLE,
   X_ABBREVIATED_TITLE,
   X_THESIS_RESULT_CD,
   X_EXPECTED_SUBMISSION_DT,
   X_LIBRARY_LODGEMENT_DT,
   X_LIBRARY_CATALOGUE_NUMBER,
   X_EMBARGO_EXPIRY_DT,
   X_THESIS_FORMAT,
   X_LOGICAL_DELETE_DT,
   X_EMBARGO_DETAILS,
   X_THESIS_TOPIC,
   X_CITATION,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
  ) as
begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
   );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_RE_THESIS_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

 After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
end DELETE_ROW;
end IGS_RE_THESIS_PKG;

/
