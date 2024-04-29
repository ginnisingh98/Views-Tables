--------------------------------------------------------
--  DDL for Package Body IGS_RE_THESIS_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_THESIS_HIST_PKG" as
/* $Header: IGSRI17B.pls 115.6 2002/11/29 03:36:11 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_RE_THESIS_HIST_ALL%RowType;
  new_references IGS_RE_THESIS_HIST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_final_title_ind IN VARCHAR2 DEFAULT NULL,
    x_short_title IN VARCHAR2 DEFAULT NULL,
    x_abbreviated_title IN VARCHAR2 DEFAULT NULL,
    x_thesis_result_cd IN VARCHAR2 DEFAULT NULL,
    x_expected_submission_dt IN DATE DEFAULT NULL,
    x_date_of_library_lodgement IN DATE DEFAULT NULL,
    x_library_catalogue_number IN VARCHAR2 DEFAULT NULL,
    x_embargo_expiry_dt IN DATE DEFAULT NULL,
    x_thesis_format IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_embargo_details IN VARCHAR2 DEFAULT NULL,
    x_thesis_topic IN VARCHAR2 DEFAULT NULL,
    x_citation IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_THESIS_HIST_ALL
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
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.title := x_title;
    new_references.final_title_ind := x_final_title_ind;
    new_references.short_title := x_short_title;
    new_references.abbreviated_title := x_abbreviated_title;
    new_references.thesis_result_cd := x_thesis_result_cd;
    new_references.expected_submission_dt := x_expected_submission_dt;
    new_references.date_of_library_lodgement := x_date_of_library_lodgement;
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

  PROCEDURE Check_Constraints (
    Column_Name in VARCHAR2 DEFAULT NULL ,
    Column_Value in VARCHAR2 DEFAULT NULL
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
  IF upper(column_name)= 'THESIS_FORMAT' OR COLUMN_NAME IS NULL THEN
    IF new_references.THESIS_FORMAT <> NEW_REFERENCES.THESIS_FORMAT then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'THESIS_RESULT_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.THESIS_RESULT_CD <> upper(NEW_REFERENCES.THESIS_RESULT_CD) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
 END Check_Constraints ;


  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER,
    x_hist_start_dt IN DATE
    )
   RETURN BOOLEAN
   AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_THESIS_HIST_ALL
      WHERE    person_id = x_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      sequence_number = x_sequence_number
      AND      hist_start_dt = x_hist_start_dt
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_final_title_ind IN VARCHAR2 DEFAULT NULL,
    x_short_title IN VARCHAR2 DEFAULT NULL,
    x_abbreviated_title IN VARCHAR2 DEFAULT NULL,
    x_thesis_result_cd IN VARCHAR2 DEFAULT NULL,
    x_expected_submission_dt IN DATE DEFAULT NULL,
    x_date_of_library_lodgement IN DATE DEFAULT NULL,
    x_library_catalogue_number IN VARCHAR2 DEFAULT NULL,
    x_embargo_expiry_dt IN DATE DEFAULT NULL,
    x_thesis_format IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_embargo_details IN VARCHAR2 DEFAULT NULL,
    x_thesis_topic IN VARCHAR2 DEFAULT NULL,
    x_citation IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_ca_sequence_number,
      x_sequence_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_title,
      x_final_title_ind,
      x_short_title,
      x_abbreviated_title,
      x_thesis_result_cd,
      x_expected_submission_dt,
      x_date_of_library_lodgement,
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
      IF Get_PK_For_Validation (
	    new_references.person_id,
	    new_references.ca_sequence_number,
	    new_references.sequence_number,
	    new_references.hist_start_dt
      ) THEN
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	 IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
	    new_references.person_id,
	    new_references.ca_sequence_number,
	    new_references.sequence_number,
	    new_references.hist_start_dt
      ) THEN
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	 IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    END IF;
  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_DATE_OF_LIBRARY_LODGEMENT in DATE,
  X_LIBRARY_CATALOGUE_NUMBER in VARCHAR2,
  X_EMBARGO_EXPIRY_DT in DATE,
  X_THESIS_FORMAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_EMBARGO_DETAILS in VARCHAR2,
  X_THESIS_TOPIC in VARCHAR2,
  X_CITATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
    cursor C is select ROWID from IGS_RE_THESIS_HIST_ALL
      where PERSON_ID = X_PERSON_ID
      and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
      and HIST_START_DT = X_HIST_START_DT;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
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
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_title => X_TITLE,
    x_final_title_ind => X_FINAL_TITLE_IND,
    x_short_title => X_SHORT_TITLE,
    x_abbreviated_title => X_ABBREVIATED_TITLE,
    x_thesis_result_cd => X_THESIS_RESULT_CD,
    x_expected_submission_dt => X_EXPECTED_SUBMISSION_DT,
    x_date_of_library_lodgement => X_DATE_OF_LIBRARY_LODGEMENT,
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


  insert into IGS_RE_THESIS_HIST_ALL (
    PERSON_ID,
    CA_SEQUENCE_NUMBER,
    SEQUENCE_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    TITLE,
    FINAL_TITLE_IND,
    SHORT_TITLE,
    ABBREVIATED_TITLE,
    THESIS_RESULT_CD,
    EXPECTED_SUBMISSION_DT,
    DATE_OF_LIBRARY_LODGEMENT,
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
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.TITLE,
    NEW_REFERENCES.FINAL_TITLE_IND,
    NEW_REFERENCES.SHORT_TITLE,
    NEW_REFERENCES.ABBREVIATED_TITLE,
    NEW_REFERENCES.THESIS_RESULT_CD,
    NEW_REFERENCES.EXPECTED_SUBMISSION_DT,
    NEW_REFERENCES.DATE_OF_LIBRARY_LODGEMENT,
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

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_DATE_OF_LIBRARY_LODGEMENT in DATE,
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
      HIST_END_DT,
      HIST_WHO,
      TITLE,
      FINAL_TITLE_IND,
      SHORT_TITLE,
      ABBREVIATED_TITLE,
      THESIS_RESULT_CD,
      EXPECTED_SUBMISSION_DT,
      DATE_OF_LIBRARY_LODGEMENT,
      LIBRARY_CATALOGUE_NUMBER,
      EMBARGO_EXPIRY_DT,
      THESIS_FORMAT,
      LOGICAL_DELETE_DT,
      EMBARGO_DETAILS,
      THESIS_TOPIC,
      CITATION,
      COMMENTS
    from IGS_RE_THESIS_HIST_ALL
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

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.TITLE = X_TITLE)
           OR ((tlinfo.TITLE is null)
               AND (X_TITLE is null)))
      AND ((tlinfo.FINAL_TITLE_IND = X_FINAL_TITLE_IND)
           OR ((tlinfo.FINAL_TITLE_IND is null)
               AND (X_FINAL_TITLE_IND is null)))
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
      AND ((tlinfo.DATE_OF_LIBRARY_LODGEMENT = X_DATE_OF_LIBRARY_LODGEMENT)
           OR ((tlinfo.DATE_OF_LIBRARY_LODGEMENT is null)
               AND (X_DATE_OF_LIBRARY_LODGEMENT is null)))
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
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_DATE_OF_LIBRARY_LODGEMENT in DATE,
  X_LIBRARY_CATALOGUE_NUMBER in VARCHAR2,
  X_EMBARGO_EXPIRY_DT in DATE,
  X_THESIS_FORMAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_EMBARGO_DETAILS in VARCHAR2,
  X_THESIS_TOPIC in VARCHAR2,
  X_CITATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
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
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_title => X_TITLE,
    x_final_title_ind => X_FINAL_TITLE_IND,
    x_short_title => X_SHORT_TITLE,
    x_abbreviated_title => X_ABBREVIATED_TITLE,
    x_thesis_result_cd => X_THESIS_RESULT_CD,
    x_expected_submission_dt => X_EXPECTED_SUBMISSION_DT,
    x_date_of_library_lodgement => X_DATE_OF_LIBRARY_LODGEMENT,
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

  update IGS_RE_THESIS_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    TITLE = NEW_REFERENCES.TITLE,
    FINAL_TITLE_IND = NEW_REFERENCES.FINAL_TITLE_IND,
    SHORT_TITLE = NEW_REFERENCES.SHORT_TITLE,
    ABBREVIATED_TITLE = NEW_REFERENCES.ABBREVIATED_TITLE,
    THESIS_RESULT_CD = NEW_REFERENCES.THESIS_RESULT_CD,
    EXPECTED_SUBMISSION_DT = NEW_REFERENCES.EXPECTED_SUBMISSION_DT,
    DATE_OF_LIBRARY_LODGEMENT = NEW_REFERENCES.DATE_OF_LIBRARY_LODGEMENT,
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
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_DATE_OF_LIBRARY_LODGEMENT in DATE,
  X_LIBRARY_CATALOGUE_NUMBER in VARCHAR2,
  X_EMBARGO_EXPIRY_DT in DATE,
  X_THESIS_FORMAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_EMBARGO_DETAILS in VARCHAR2,
  X_THESIS_TOPIC in VARCHAR2,
  X_CITATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
  cursor c1 is select rowid from IGS_RE_THESIS_HIST_ALL
     where PERSON_ID = X_PERSON_ID
     and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
     and HIST_START_DT = X_HIST_START_DT
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
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_TITLE,
     X_FINAL_TITLE_IND,
     X_SHORT_TITLE,
     X_ABBREVIATED_TITLE,
     X_THESIS_RESULT_CD,
     X_EXPECTED_SUBMISSION_DT,
     X_DATE_OF_LIBRARY_LODGEMENT,
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
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_TITLE,
   X_FINAL_TITLE_IND,
   X_SHORT_TITLE,
   X_ABBREVIATED_TITLE,
   X_THESIS_RESULT_CD,
   X_EXPECTED_SUBMISSION_DT,
   X_DATE_OF_LIBRARY_LODGEMENT,
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
  X_ROWID in VARCHAR2
  ) as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
   );

  delete from IGS_RE_THESIS_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_RE_THESIS_HIST_PKG;

/
