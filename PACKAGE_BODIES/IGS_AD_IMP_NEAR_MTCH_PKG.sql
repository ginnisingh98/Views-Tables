--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_NEAR_MTCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_NEAR_MTCH_PKG" AS
/* $Header: IGSAIB2B.pls 115.19 2003/05/22 13:17:56 npalanis ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_imp_near_mtch_all%RowType;
  new_references igs_ad_imp_near_mtch_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_near_mtch_id IN NUMBER DEFAULT NULL,
    x_interface_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_match_ind IN VARCHAR2 DEFAULT NULL,
    x_action IN VARCHAR2 DEFAULT NULL,
    x_addr_type IN VARCHAR2 DEFAULT NULL,
    x_person_id_type IN VARCHAR2 DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_party_site_id IN NUMBER DEFAULT NULL ,
    X_INTERFACE_RELATIONS_ID IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_IMP_NEAR_MTCH_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.near_mtch_id := x_near_mtch_id;
    new_references.org_id := x_org_id;
    new_references.interface_id := x_interface_id;
    new_references.person_id := x_person_id;
    new_references.match_ind := x_match_ind;
    new_references.action := x_action;
    new_references.addr_type := x_addr_type;
    new_references.person_id_type := x_person_id_type;
    new_references.match_set_id := x_match_set_id;
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
    new_references.party_site_id := x_party_site_id;
    new_references.interface_relations_id := x_interface_relations_id;

  END Set_Column_Values;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF column_name IS NULL THEN
      NULL;
    ELSIF  UPPER(column_name) = 'MATCH_IND'  THEN
      new_references.match_ind := column_value;
    ELSIF  UPPER(column_name) = 'ACTION'  THEN
      new_references.action := column_value;
    END IF;



  -- The following code checks for check constraints on the Columns.
    IF Upper(Column_Name) = 'ACTION' OR
      Column_Name IS NULL THEN
      IF NOT (new_references.action IN ('I','D'))  THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.interface_id = new_references.interface_id)) OR
        ((new_references.interface_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Interface_Pkg.Get_PK_For_Validation (
        		new_references.interface_id
							  )  THEN
      Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.person_id_type = new_references.person_id_type)) OR
        ((new_references.person_id_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Id_Typ_Pkg.Get_PK_For_Validation (
        		new_references.person_id_type
        )  THEN
      Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;

/*    IF (((old_references.addr_type = new_references.addr_type)) OR
        ((new_references.addr_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Co_Addr_Type_Pkg.Get_PK_For_Validation (
        		new_references.addr_type
        )  THEN
      Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
*/
    IF (((old_references.match_set_id = new_references.match_set_id)) OR
        ((new_references.match_set_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Match_Sets_Pkg.Get_PK_For_Validation (
        		new_references.match_set_id
        )  THEN
      Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;

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

  FUNCTION Get_PK_For_Validation (
    x_near_mtch_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_imp_near_mtch_all
      WHERE    near_mtch_id = x_near_mtch_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;
  END Get_PK_For_Validation;


  PROCEDURE Get_FK_Igs_Ad_Interface (
    x_interface_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_imp_near_mtch_all
      WHERE    interface_id = x_interface_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AINM_AINT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Interface;

  PROCEDURE Get_FK_Igs_Co_Addr_Type (
    x_addr_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_imp_near_mtch_all
      WHERE    addr_type = x_addr_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AINM_ADT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Co_Addr_Type;

  PROCEDURE Get_FK_Igs_Pe_Match_Sets (
    x_match_set_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_imp_near_mtch_all
      WHERE    match_set_id = x_match_set_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AINM_PMS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Match_Sets;

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_imp_near_mtch_all
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AINM_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_near_mtch_id IN NUMBER DEFAULT NULL,
    x_interface_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_match_ind IN VARCHAR2 DEFAULT NULL,
    x_action IN VARCHAR2 DEFAULT NULL,
    x_addr_type IN VARCHAR2 DEFAULT NULL,
    x_person_id_type IN VARCHAR2 DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_party_site_id IN NUMBER DEFAULT NULL,
    X_INTERFACE_RELATIONS_ID IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_near_mtch_id,
      x_interface_id,
      x_person_id,
      x_match_ind,
      x_action,
      x_addr_type,
      x_person_id_type,
      x_match_set_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_party_site_id,
      x_interface_relations_id

    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_Pk_For_Validation(new_references.near_mtch_id)  THEN
        Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.near_mtch_id)  THEN
        Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

  procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    X_ORG_ID in NUMBER,
    x_NEAR_MTCH_ID IN OUT NOCOPY NUMBER,
    x_INTERFACE_ID IN NUMBER,
    x_PERSON_ID IN NUMBER,
    x_MATCH_IND IN VARCHAR2,
    x_ACTION IN VARCHAR2,
    x_ADDR_TYPE IN VARCHAR2,
    x_PERSON_ID_TYPE IN VARCHAR2,
    x_MATCH_SET_ID IN NUMBER,
    X_MODE in VARCHAR2 default 'R',
    X_PARTY_SITE_ID IN NUMBER ,
    X_INTERFACE_RELATIONS_ID IN NUMBER
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sbaliga        12-feb-2002      Modified call to before_dml by assigning
                                  igs_ge_gen_003.get_org_id to x_org_id as part of
                                  SWCR006 build.

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_IMP_NEAR_MTCH_ALL
              where NEAR_MTCH_ID= X_NEAR_MTCH_ID;
    X_LAST_UPDATE_DATE DATE ;
    X_LAST_UPDATED_BY NUMBER ;
    X_LAST_UPDATE_LOGIN NUMBER ;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
      X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      if (X_REQUEST_ID =  -1) then
        X_REQUEST_ID := NULL;
        X_PROGRAM_ID := NULL;
        X_PROGRAM_APPLICATION_ID := NULL;
        X_PROGRAM_UPDATE_DATE := NULL;
      else
        X_PROGRAM_UPDATE_DATE := SYSDATE;
      end if;
    else
      FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    end if;

    X_NEAR_MTCH_ID := -1;
    Before_DML(
      p_action=>'INSERT',
      x_org_id=>igs_ge_gen_003.get_org_id,
      x_rowid=>X_ROWID,
      x_near_mtch_id=>X_NEAR_MTCH_ID,
      x_interface_id=>X_INTERFACE_ID,
      x_person_id=>X_PERSON_ID,
      x_match_ind=>X_MATCH_IND,
      x_action=>X_ACTION,
      x_addr_type=>X_ADDR_TYPE,
      x_person_id_type=>X_PERSON_ID_TYPE,
      x_match_set_id=>X_MATCH_SET_ID,
      x_creation_date=>X_LAST_UPDATE_DATE,
      x_created_by=>X_LAST_UPDATED_BY,
      x_last_update_date=>X_LAST_UPDATE_DATE,
      x_last_updated_by=>X_LAST_UPDATED_BY,
      x_last_update_login=>X_LAST_UPDATE_LOGIN,
      x_party_site_id => X_PARTY_SITE_ID,
      x_interface_relations_id => X_INTERFACE_RELATIONS_ID);

    insert into IGS_AD_IMP_NEAR_MTCH_ALL (
      NEAR_MTCH_ID
      ,INTERFACE_ID
      ,PERSON_ID
      ,ORG_ID
      ,MATCH_IND
      ,ACTION
      ,ADDR_TYPE
      ,PERSON_ID_TYPE
      ,MATCH_SET_ID
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,REQUEST_ID
      ,PROGRAM_ID
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_UPDATE_DATE
      ,PARTY_SITE_ID
      ,INTERFACE_RELATIONS_ID

    ) values  (
      IGS_AD_IMP_NEAR_MTCH_S.NEXTVAL
      ,NEW_REFERENCES.INTERFACE_ID
      ,NEW_REFERENCES.PERSON_ID
      ,NEW_REFERENCES.ORG_ID
      ,NEW_REFERENCES.MATCH_IND
      ,NEW_REFERENCES.ACTION
      ,NEW_REFERENCES.ADDR_TYPE
      ,NEW_REFERENCES.PERSON_ID_TYPE
      ,NEW_REFERENCES.MATCH_SET_ID
      ,X_LAST_UPDATE_DATE
      ,X_LAST_UPDATED_BY
      ,X_LAST_UPDATE_DATE
      ,X_LAST_UPDATED_BY
      ,X_LAST_UPDATE_LOGIN
      ,X_REQUEST_ID
      ,X_PROGRAM_ID
      ,X_PROGRAM_APPLICATION_ID
      ,X_PROGRAM_UPDATE_DATE
      ,NEW_REFERENCES.PARTY_SITE_ID
      ,NEW_REFERENCES.INTERFACE_RELATIONS_ID )RETURNING NEAR_MTCH_ID INTO X_NEAR_MTCH_ID;

    open c;
    fetch c into X_ROWID;
    if (c%notfound) then
      close c;
      raise no_data_found;
    end if;
    close c;

    After_DML (
      p_action => 'INSERT' ,
      x_rowid => X_ROWID );

  end INSERT_ROW;


  procedure LOCK_ROW (
    X_ROWID in  VARCHAR2,
    x_NEAR_MTCH_ID IN NUMBER,
    x_INTERFACE_ID IN NUMBER,
    x_PERSON_ID IN NUMBER,
    x_MATCH_IND IN VARCHAR2,
    x_ACTION IN VARCHAR2,
    x_ADDR_TYPE IN VARCHAR2,
    x_PERSON_ID_TYPE IN VARCHAR2,
    x_MATCH_SET_ID IN NUMBER,
    X_PARTY_SITE_ID IN NUMBER,
    X_INTERFACE_RELATIONS_ID IN NUMBER  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select
      INTERFACE_ID,
      PERSON_ID,
      MATCH_IND,
      ACTION,
      ADDR_TYPE,
      PERSON_ID_TYPE,
      MATCH_SET_ID,
      PARTY_SITE_ID,
      INTERFACE_RELATIONS_ID
    from IGS_AD_IMP_NEAR_MTCH_ALL
    where ROWID = X_ROWID
    for update nowait;

    tlinfo c1%rowtype;
  begin
    open c1;
    fetch c1 into tlinfo;
    if (c1%notfound) then
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      close c1;
      app_exception.raise_exception;
      return;
    end if;
    close c1;
    if ( (  tlinfo.INTERFACE_ID = X_INTERFACE_ID)
      AND (tlinfo.PERSON_ID = X_PERSON_ID)
      AND ((tlinfo.MATCH_IND = X_MATCH_IND)
      OR ((tlinfo.MATCH_IND is null)
      AND (X_MATCH_IND is null)))
      AND ((tlinfo.ACTION = X_ACTION)
      OR ((tlinfo.ACTION is null)
      AND (X_ACTION is null)))
      AND (tlinfo.ADDR_TYPE = X_ADDR_TYPE OR (tlinfo.ADDR_TYPE IS NULL AND X_ADDR_TYPE IS NULL ))
      AND (tlinfo.PERSON_ID_TYPE = X_PERSON_ID_TYPE OR (tlinfo.PERSON_ID_TYPE IS NULL AND X_PERSON_ID_TYPE IS NULL ) )
      AND (tlinfo.MATCH_SET_ID = X_MATCH_SET_ID)
      AND (tlinfo.PARTY_SITE_ID = X_PARTY_SITE_ID OR (tlinfo.PARTY_SITE_ID IS NULL AND X_PARTY_SITE_ID IS NULL ) )
      AND (tlinfo.INTERFACE_RELATIONS_ID = X_INTERFACE_RELATIONS_ID OR (tlinfo.INTERFACE_RELATIONS_ID IS NULL AND X_INTERFACE_RELATIONS_ID IS NULL ) )
    ) then
      NULL;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    end if;
    return;

  end LOCK_ROW;
 Procedure UPDATE_ROW (
   X_ROWID in  VARCHAR2,
   x_NEAR_MTCH_ID IN NUMBER,
   x_INTERFACE_ID IN NUMBER,
   x_PERSON_ID IN NUMBER,
   x_MATCH_IND IN VARCHAR2,
   x_ACTION IN VARCHAR2,
   x_ADDR_TYPE IN VARCHAR2,
   x_PERSON_ID_TYPE IN VARCHAR2,
   x_MATCH_SET_ID IN NUMBER,
   X_MODE in VARCHAR2 default 'R',
   X_PARTY_SITE_ID IN NUMBER  ,
   X_INTERFACE_RELATIONS_ID IN NUMBER
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    X_LAST_UPDATE_DATE DATE ;
    X_LAST_UPDATED_BY NUMBER ;
    X_LAST_UPDATE_LOGIN NUMBER ;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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

    Before_DML(
      p_action=>'UPDATE',
      x_rowid=>X_ROWID,
      x_near_mtch_id=>X_NEAR_MTCH_ID,
      x_interface_id=>X_INTERFACE_ID,
      x_person_id=>X_PERSON_ID,
      x_match_ind=>X_MATCH_IND,
      x_action=>X_ACTION,
      x_addr_type=>X_ADDR_TYPE,
      x_person_id_type=>X_PERSON_ID_TYPE,
      x_match_set_id=>X_MATCH_SET_ID,
      x_creation_date=>X_LAST_UPDATE_DATE,
      x_created_by=>X_LAST_UPDATED_BY,
      x_last_update_date=>X_LAST_UPDATE_DATE,
      x_last_updated_by=>X_LAST_UPDATED_BY,
      x_last_update_login=>X_LAST_UPDATE_LOGIN,
      x_party_site_id => X_PARTY_SITE_ID,
      x_interface_relations_id => X_INTERFACE_RELATIONS_ID);

    if (X_MODE = 'R') then
      X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      if (X_REQUEST_ID = -1) then
        X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
        X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
        X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
        X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
      else
        X_PROGRAM_UPDATE_DATE := SYSDATE;
      end if;
    end if;

    update IGS_AD_IMP_NEAR_MTCH_ALL set
      INTERFACE_ID =  NEW_REFERENCES.INTERFACE_ID,
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      MATCH_IND =  NEW_REFERENCES.MATCH_IND,
      ACTION =  NEW_REFERENCES.ACTION,
      ADDR_TYPE =  NEW_REFERENCES.ADDR_TYPE,
      PERSON_ID_TYPE =  NEW_REFERENCES.PERSON_ID_TYPE,
      MATCH_SET_ID =  NEW_REFERENCES.MATCH_SET_ID,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      REQUEST_ID = X_REQUEST_ID,
      PROGRAM_ID = X_PROGRAM_ID,
      PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
      PARTY_SITE_ID = X_PARTY_SITE_ID,
      INTERFACE_RELATIONS_ID = X_INTERFACE_RELATIONS_ID
    where ROWID = X_ROWID;

    if (sql%notfound) then
      raise no_data_found;
    end if;

    After_DML (
      p_action => 'UPDATE' ,
      x_rowid => X_ROWID
      );
  end UPDATE_ROW;


  procedure ADD_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    X_ORG_ID in NUMBER,
    x_NEAR_MTCH_ID IN OUT NOCOPY NUMBER,
    x_INTERFACE_ID IN NUMBER,
    x_PERSON_ID IN NUMBER,
    x_MATCH_IND IN VARCHAR2,
    x_ACTION IN VARCHAR2,
    x_ADDR_TYPE IN VARCHAR2,
    x_PERSON_ID_TYPE IN VARCHAR2,
    x_MATCH_SET_ID IN NUMBER,
    X_MODE in VARCHAR2 default 'R',
    x_PARTY_SITE_ID IN NUMBER  ,
    X_INTERFACE_RELATIONS_ID IN NUMBER
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_IMP_NEAR_MTCH_ALL
      where NEAR_MTCH_ID= X_NEAR_MTCH_ID;
  begin
    open c1;
    fetch c1 into X_ROWID;
    if (c1%notfound) then
      close c1;
      INSERT_ROW (
	X_ROWID,
	X_ORG_ID,
	X_NEAR_MTCH_ID,
	X_INTERFACE_ID,
	X_PERSON_ID,
	X_MATCH_IND,
	X_ACTION,
	X_ADDR_TYPE,
	X_PERSON_ID_TYPE,
	X_MATCH_SET_ID,
	X_MODE,
	X_PARTY_SITE_ID ,
        X_INTERFACE_RELATIONS_ID);
      return;
    end if;
    close c1;
    UPDATE_ROW (
      X_ROWID,
      X_NEAR_MTCH_ID,
      X_INTERFACE_ID,
      X_PERSON_ID,
      X_MATCH_IND,
      X_ACTION,
      X_ADDR_TYPE,
      X_PERSON_ID_TYPE,
      X_MATCH_SET_ID,
      X_MODE,
      X_PARTY_SITE_ID,
      X_INTERFACE_RELATIONS_ID );

  end ADD_ROW;


  procedure DELETE_ROW (
    X_ROWID in VARCHAR2
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  begin
    Before_DML (
      p_action => 'DELETE',
      x_rowid => X_ROWID
    );

    delete from IGS_AD_IMP_NEAR_MTCH_ALL
    where ROWID = X_ROWID;
    if (sql%notfound) then
      raise no_data_found;
    end if;

    After_DML (
      p_action => 'DELETE',
      x_rowid => X_ROWID
    );

  end DELETE_ROW;

END igs_ad_imp_near_mtch_pkg;

/
