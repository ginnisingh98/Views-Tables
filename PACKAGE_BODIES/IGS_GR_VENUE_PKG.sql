--------------------------------------------------------
--  DDL for Package Body IGS_GR_VENUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_VENUE_PKG" as
/* $Header: IGSGI19B.pls 115.10 2003/10/30 13:28:59 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GR_VENUE_ALL%RowType;
  new_references IGS_GR_VENUE_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_venue_cd IN VARCHAR2 DEFAULT NULL,
    x_exam_location_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_number_of_seats IN NUMBER DEFAULT NULL,
    x_booking_cost IN NUMBER DEFAULT NULL,
    x_priority_cd IN NUMBER DEFAULT NULL,
    x_supervisor_limit IN NUMBER DEFAULT NULL,
    x_coord_person_id IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_resources_available IN VARCHAR2 DEFAULT NULL,
    x_announcements IN VARCHAR2 DEFAULT NULL,
    x_booking_information IN VARCHAR2 DEFAULT NULL,
    x_seating_information IN VARCHAR2 DEFAULT NULL,
    x_instructions IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_VENUE_ALL
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
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.venue_cd := x_venue_cd;
    new_references.exam_location_cd := x_exam_location_cd;
    new_references.description := x_description;
    new_references.number_of_seats := x_number_of_seats;
    new_references.booking_cost := x_booking_cost;
    new_references.priority_cd := x_priority_cd;
    new_references.supervisor_limit := x_supervisor_limit;
    new_references.coord_person_id := x_coord_person_id;
    new_references.closed_ind := x_closed_ind;
    new_references.comments := x_comments;
    new_references.resources_available := x_resources_available;
    new_references.announcements := x_announcements;
    new_references.booking_information := x_booking_information;
    new_references.seating_information := x_seating_information;
    new_references.instructions := x_instructions;
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

  -- Trigger description :-
  -- "OSS_TST".trg_ve_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_GR_VENUE_ALL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name VARCHAR2(30);
  BEGIN
	-- Validate that inserts are allowed
	IF  p_inserting THEN
		-- <ve1>
		-- Cannot create against location with s_location_type <> 'EXAM_CTR'
		IF  IGS_AS_VAL_VE.assp_val_ve_lot (
						new_references.exam_location_cd,
						v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
  				App_Exception.Raise_Exception;
		END IF;
		-- <ve2>
		-- Cannot created against closed exam_location
		IF  IGS_AS_VAL_ELS.ORGP_VAL_LOC_CLOSED (
						new_references.exam_location_cd,
						v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
  				App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
		-- <ve3>
		-- Cannot re-open against closed exam_location
		IF  IGS_AS_VAL_VE.assp_val_ve_reopen (
						new_references.exam_location_cd,
						new_references.closed_ind,
						v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
  				App_Exception.Raise_Exception;
		END IF;
		-- <ve4>
		-- Validate co-ordinator is a valid person
		IF  (new_references.coord_person_id IS NOT NULL and
				new_references.coord_person_id <> old_references.coord_person_id) THEN
			IF  IGS_CO_VAL_OC.genp_val_prsn_id (
						new_references.coord_person_id,
						v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS', v_message_name);
  				App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.exam_location_cd = new_references.exam_location_cd)) OR
        ((new_references.exam_location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.exam_location_cd,
        'N'
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.coord_person_id = new_references.coord_person_id)) OR
        ((new_references.coord_person_id IS NULL))) THEN
      NULL;
    ELSE
     IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.coord_person_id
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AS_EXAM_INSTANCE_PKG.GET_FK_IGS_GR_VENUE (
      old_references.venue_cd
      );

    IGS_AS_EXMVNU_SESAVL_PKG.GET_FK_IGS_GR_VENUE (
      old_references.venue_cd
      );

    IGS_GR_CRMN_PKG.GET_FK_IGS_GR_VENUE (
      old_references.venue_cd
      );


    /*IGS_GR_VENUE_ADDR_PKG.GET_FK_IGS_GR_VENUE (
      old_references.venue_cd
      );
*/
  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_venue_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_VENUE_ALL
      WHERE    venue_cd = x_venue_cd
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    	IF (cur_rowid%FOUND) THEN
		Close cur_rowid;
		Return (TRUE);
	ELSE
		Close cur_rowid;
		Return (FALSE);
	END IF;

  END Get_PK_For_Validation;

  PROCEDURE CHECK_CONSTRAINTS(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
  BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'SUPERVISOR_LIMIT' THEN
  new_references.SUPERVISOR_LIMIT:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'CLOSED_IND' THEN
  new_references.CLOSED_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'EXAM_LOCATION_CD' THEN
  new_references.EXAM_LOCATION_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'VENUE_CD' THEN
  new_references.VENUE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'BOOKING_COST' THEN
  new_references.BOOKING_COST:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'NUMBER_OF_SEATS' THEN
  new_references.NUMBER_OF_SEATS:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'PRIORITY_CD' THEN
  new_references.PRIORITY_CD:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'SUPERVISOR_LIMIT' OR COLUMN_NAME IS NULL THEN
  IF new_references.SUPERVISOR_LIMIT < 0 or new_references.SUPERVISOR_LIMIT > 99 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'CLOSED_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.CLOSED_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'EXAM_LOCATION_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.EXAM_LOCATION_CD<> upper(new_references.EXAM_LOCATION_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'VENUE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.VENUE_CD<> upper(new_references.VENUE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'BOOKING_COST' OR COLUMN_NAME IS NULL THEN
  IF new_references.BOOKING_COST < 0 or new_references.BOOKING_COST > 99999.99 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'NUMBER_OF_SEATS' OR COLUMN_NAME IS NULL THEN
  IF new_references.NUMBER_OF_SEATS < 0 or new_references.NUMBER_OF_SEATS > 9999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRIORITY_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRIORITY_CD < 0 or new_references.PRIORITY_CD > 999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
  END CHECK_CONSTRAINTS;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_VENUE_ALL
      WHERE    exam_location_cd = x_location_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_VE_LOC_FK');
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_VENUE_ALL
      WHERE    coord_person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_VE_PE_FK');
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_venue_cd IN VARCHAR2 DEFAULT NULL,
    x_exam_location_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_number_of_seats IN NUMBER DEFAULT NULL,
    x_booking_cost IN NUMBER DEFAULT NULL,
    x_priority_cd IN NUMBER DEFAULT NULL,
    x_supervisor_limit IN NUMBER DEFAULT NULL,
    x_coord_person_id IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_resources_available IN VARCHAR2 DEFAULT NULL,
    x_announcements IN VARCHAR2 DEFAULT NULL,
    x_booking_information IN VARCHAR2 DEFAULT NULL,
    x_seating_information IN VARCHAR2 DEFAULT NULL,
    x_instructions IN VARCHAR2 DEFAULT NULL,
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
      x_venue_cd,
      x_exam_location_cd,
      x_description,
      x_number_of_seats,
      x_booking_cost,
      x_priority_cd,
      x_supervisor_limit,
      x_coord_person_id,
      x_closed_ind,
      x_comments,
      x_resources_available,
      x_announcements,
      x_booking_information,
      x_seating_information,
      x_instructions,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF GET_PK_FOR_VALIDATION(NEW_REFERENCES.venue_cd) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );

	check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(NEW_REFERENCES.venue_cd) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN

	check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
	check_child_existance;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_VENUE_CD in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_NUMBER_OF_SEATS in NUMBER,
  X_BOOKING_COST in NUMBER,
  X_PRIORITY_CD in NUMBER,
  X_SUPERVISOR_LIMIT in NUMBER,
  X_COORD_PERSON_ID in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_RESOURCES_AVAILABLE in VARCHAR2,
  X_ANNOUNCEMENTS in VARCHAR2,
  X_BOOKING_INFORMATION in VARCHAR2,
  X_SEATING_INFORMATION in VARCHAR2,
  X_INSTRUCTIONS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_GR_VENUE_ALL
      where VENUE_CD = X_VENUE_CD;
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
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID,
    x_venue_cd => X_VENUE_CD,
    x_exam_location_cd => X_EXAM_LOCATION_CD,
    x_description => X_DESCRIPTION,
    x_number_of_seats => X_NUMBER_OF_SEATS,
    x_booking_cost => X_BOOKING_COST,
    x_priority_cd => X_PRIORITY_CD,
    x_supervisor_limit => X_SUPERVISOR_LIMIT,
    x_coord_person_id => X_COORD_PERSON_ID,
    x_closed_ind => NVL(X_CLOSED_IND, 'N'),
    x_comments => X_COMMENTS,
    x_resources_available => X_RESOURCES_AVAILABLE,
    x_announcements => X_ANNOUNCEMENTS,
    x_booking_information => X_BOOKING_INFORMATION,
    x_seating_information => X_SEATING_INFORMATION,
    x_instructions => X_INSTRUCTIONS,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN,
     x_org_id => igs_ge_gen_003.get_org_id
  );

  insert into IGS_GR_VENUE_ALL (
    VENUE_CD,
    EXAM_LOCATION_CD,
    DESCRIPTION,
    NUMBER_OF_SEATS,
    BOOKING_COST,
    PRIORITY_CD,
    SUPERVISOR_LIMIT,
    COORD_PERSON_ID,
    CLOSED_IND,
    COMMENTS,
    RESOURCES_AVAILABLE,
    ANNOUNCEMENTS,
    BOOKING_INFORMATION,
    SEATING_INFORMATION,
    INSTRUCTIONS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.VENUE_CD,
    NEW_REFERENCES.EXAM_LOCATION_CD,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.NUMBER_OF_SEATS,
    NEW_REFERENCES.BOOKING_COST,
    NEW_REFERENCES.PRIORITY_CD,
    NEW_REFERENCES.SUPERVISOR_LIMIT,
    NEW_REFERENCES.COORD_PERSON_ID,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.COMMENTS,
    NEW_REFERENCES.RESOURCES_AVAILABLE,
    NEW_REFERENCES.ANNOUNCEMENTS,
    NEW_REFERENCES.BOOKING_INFORMATION,
    NEW_REFERENCES.SEATING_INFORMATION,
    NEW_REFERENCES.INSTRUCTIONS,
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
  X_VENUE_CD in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_NUMBER_OF_SEATS in NUMBER,
  X_BOOKING_COST in NUMBER,
  X_PRIORITY_CD in NUMBER,
  X_SUPERVISOR_LIMIT in NUMBER,
  X_COORD_PERSON_ID in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_RESOURCES_AVAILABLE in VARCHAR2,
  X_ANNOUNCEMENTS in VARCHAR2,
  X_BOOKING_INFORMATION in VARCHAR2,
  X_SEATING_INFORMATION in VARCHAR2,
  X_INSTRUCTIONS in VARCHAR2
) AS
  cursor c1 is select
      EXAM_LOCATION_CD,
      DESCRIPTION,
      NUMBER_OF_SEATS,
      BOOKING_COST,
      PRIORITY_CD,
      SUPERVISOR_LIMIT,
      COORD_PERSON_ID,
      CLOSED_IND,
      COMMENTS,
      RESOURCES_AVAILABLE,
      ANNOUNCEMENTS,
      BOOKING_INFORMATION,
      SEATING_INFORMATION,
      INSTRUCTIONS
    from IGS_GR_VENUE_ALL
    where ROWID = X_ROWID for update nowait;
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

  if ( (tlinfo.EXAM_LOCATION_CD = X_EXAM_LOCATION_CD)
      AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.NUMBER_OF_SEATS = X_NUMBER_OF_SEATS)
      AND ((tlinfo.BOOKING_COST = X_BOOKING_COST)
           OR ((tlinfo.BOOKING_COST is null)
               AND (X_BOOKING_COST is null)))
      AND ((tlinfo.PRIORITY_CD = X_PRIORITY_CD)
           OR ((tlinfo.PRIORITY_CD is null)
               AND (X_PRIORITY_CD is null)))
      AND ((tlinfo.SUPERVISOR_LIMIT = X_SUPERVISOR_LIMIT)
           OR ((tlinfo.SUPERVISOR_LIMIT is null)
               AND (X_SUPERVISOR_LIMIT is null)))
      AND ((tlinfo.COORD_PERSON_ID = X_COORD_PERSON_ID)
           OR ((tlinfo.COORD_PERSON_ID is null)
               AND (X_COORD_PERSON_ID is null)))
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
      AND ((tlinfo.RESOURCES_AVAILABLE = X_RESOURCES_AVAILABLE)
           OR ((tlinfo.RESOURCES_AVAILABLE is null)
               AND (X_RESOURCES_AVAILABLE is null)))
      AND ((tlinfo.ANNOUNCEMENTS = X_ANNOUNCEMENTS)
           OR ((tlinfo.ANNOUNCEMENTS is null)
               AND (X_ANNOUNCEMENTS is null)))
      AND ((tlinfo.BOOKING_INFORMATION = X_BOOKING_INFORMATION)
           OR ((tlinfo.BOOKING_INFORMATION is null)
               AND (X_BOOKING_INFORMATION is null)))
      AND ((tlinfo.SEATING_INFORMATION = X_SEATING_INFORMATION)
           OR ((tlinfo.SEATING_INFORMATION is null)
               AND (X_SEATING_INFORMATION is null)))
      AND ((tlinfo.INSTRUCTIONS = X_INSTRUCTIONS)
           OR ((tlinfo.INSTRUCTIONS is null)
               AND (X_INSTRUCTIONS is null)))

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
  X_VENUE_CD in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_NUMBER_OF_SEATS in NUMBER,
  X_BOOKING_COST in NUMBER,
  X_PRIORITY_CD in NUMBER,
  X_SUPERVISOR_LIMIT in NUMBER,
  X_COORD_PERSON_ID in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_RESOURCES_AVAILABLE in VARCHAR2,
  X_ANNOUNCEMENTS in VARCHAR2,
  X_BOOKING_INFORMATION in VARCHAR2,
  X_SEATING_INFORMATION in VARCHAR2,
  X_INSTRUCTIONS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
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
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
    x_venue_cd => X_VENUE_CD,
    x_exam_location_cd => X_EXAM_LOCATION_CD,
    x_description => X_DESCRIPTION,
    x_number_of_seats => X_NUMBER_OF_SEATS,
    x_booking_cost => X_BOOKING_COST,
    x_priority_cd => X_PRIORITY_CD,
    x_supervisor_limit => X_SUPERVISOR_LIMIT,
    x_coord_person_id => X_COORD_PERSON_ID,
    x_closed_ind => X_CLOSED_IND,
    x_comments => X_COMMENTS,
    x_resources_available => X_RESOURCES_AVAILABLE,
    x_announcements => X_ANNOUNCEMENTS,
    x_booking_information => X_BOOKING_INFORMATION,
    x_seating_information => X_SEATING_INFORMATION,
    x_instructions => X_INSTRUCTIONS,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_GR_VENUE_ALL set
    EXAM_LOCATION_CD = NEW_REFERENCES.EXAM_LOCATION_CD,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    NUMBER_OF_SEATS = NEW_REFERENCES.NUMBER_OF_SEATS,
    BOOKING_COST = NEW_REFERENCES.BOOKING_COST,
    PRIORITY_CD = NEW_REFERENCES.PRIORITY_CD,
    SUPERVISOR_LIMIT = NEW_REFERENCES.SUPERVISOR_LIMIT,
    COORD_PERSON_ID = NEW_REFERENCES.COORD_PERSON_ID,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    RESOURCES_AVAILABLE = NEW_REFERENCES.RESOURCES_AVAILABLE,
    ANNOUNCEMENTS = NEW_REFERENCES.ANNOUNCEMENTS,
    BOOKING_INFORMATION = NEW_REFERENCES.BOOKING_INFORMATION,
    SEATING_INFORMATION = NEW_REFERENCES.SEATING_INFORMATION,
    INSTRUCTIONS = NEW_REFERENCES.INSTRUCTIONS,
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
  X_VENUE_CD in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_NUMBER_OF_SEATS in NUMBER,
  X_BOOKING_COST in NUMBER,
  X_PRIORITY_CD in NUMBER,
  X_SUPERVISOR_LIMIT in NUMBER,
  X_COORD_PERSON_ID in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_RESOURCES_AVAILABLE in VARCHAR2,
  X_ANNOUNCEMENTS in VARCHAR2,
  X_BOOKING_INFORMATION in VARCHAR2,
  X_SEATING_INFORMATION in VARCHAR2,
  X_INSTRUCTIONS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_GR_VENUE_ALL
     where VENUE_CD = X_VENUE_CD
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_VENUE_CD,
     X_EXAM_LOCATION_CD,
     X_DESCRIPTION,
     X_NUMBER_OF_SEATS,
     X_BOOKING_COST,
     X_PRIORITY_CD,
     X_SUPERVISOR_LIMIT,
     X_COORD_PERSON_ID,
     X_CLOSED_IND,
     X_COMMENTS,
     X_RESOURCES_AVAILABLE,
     X_ANNOUNCEMENTS,
     X_BOOKING_INFORMATION,
     X_SEATING_INFORMATION,
     X_INSTRUCTIONS,
     X_MODE,
      x_org_id
);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_VENUE_CD,
   X_EXAM_LOCATION_CD,
   X_DESCRIPTION,
   X_NUMBER_OF_SEATS,
   X_BOOKING_COST,
   X_PRIORITY_CD,
   X_SUPERVISOR_LIMIT,
   X_COORD_PERSON_ID,
   X_CLOSED_IND,
   X_COMMENTS,
   X_RESOURCES_AVAILABLE,
   X_ANNOUNCEMENTS,
   X_BOOKING_INFORMATION,
   X_SEATING_INFORMATION,
   X_INSTRUCTIONS,
   X_MODE
);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

 Before_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );

  delete from IGS_GR_VENUE_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_GR_VENUE_PKG;

/
