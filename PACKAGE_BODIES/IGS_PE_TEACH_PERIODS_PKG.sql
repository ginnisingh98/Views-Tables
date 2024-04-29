--------------------------------------------------------
--  DDL for Package Body IGS_PE_TEACH_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_TEACH_PERIODS_PKG" AS
/* $Header: IGSNI49B.pls 120.3 2005/10/17 02:20:50 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_teach_periods_all%RowType;
  new_references igs_pe_teach_periods_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,--DEFAULT NULL,
    x_teaching_period_id IN NUMBER ,--DEFAULT NULL,
    x_person_id IN NUMBER ,--DEFAULT NULL,
    x_teach_period_resid_stat_cd IN VARCHAR2,-- DEFAULT NULL,
    x_cal_type IN VARCHAR2 ,--DEFAULT NULL,
    x_sequence_number IN NUMBER ,--DEFAULT NULL,
    x_creation_date IN DATE ,--DEFAULT NULL,
    x_created_by IN NUMBER ,--DEFAULT NULL,
    x_last_update_date IN DATE ,--DEFAULT NULL,
    x_last_updated_by IN NUMBER ,--DEFAULT NULL,
    x_last_update_login IN NUMBER ,--DEFAULT NULL,
    x_org_id IN NUMBER -- DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         30-Jun-2005     Bug 4327807 (Person SS Enhancement)
                                  Added the cal_type_cur to populate new_references.cal_type. The x_cal_type will come as NULL
								  when called from self-service
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_teach_periods_all
      WHERE    rowid = x_rowid;

    CURSOR cal_type_cur (cp_sequence_number NUMBER) IS
	SELECT cal_type
	FROM igs_ca_inst_all
	WHERE sequence_number = cp_sequence_number;

    cal_type_rec cal_type_cur%ROWTYPE;
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
    new_references.teaching_period_id := x_teaching_period_id;
    new_references.person_id := x_person_id;
    new_references.teach_period_resid_stat_cd := x_teach_period_resid_stat_cd;

	IF (x_cal_type IS NOT NULL) THEN
      new_references.cal_type := x_cal_type;
    ELSE
	  OPEN cal_type_cur (x_sequence_number);
	  FETCH cal_type_cur INTO cal_type_rec;
	  CLOSE cal_type_cur;
      new_references.cal_type := cal_type_rec.cal_type;
	END IF;
    new_references.sequence_number := x_sequence_number;
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
    new_references.org_id := x_org_id;

  END Set_Column_Values;

 PROCEDURE Check_Uniqueness AS
 /***********************************************************

 Created By : gmaheswa

 Date Created By : 2004/10/11

 Purpose : check uniqueness on the table

 Know limitations, enhancements or remarks

 Change History

 Who      When     What

 ****************************************************************/

 BEGIN
     IF Get_Uk_For_Validation (
     	new_references.cal_type,
   	new_references.sequence_number,
	new_references.person_id)
     THEN
 	Fnd_Message.Set_Name ('IGS', 'IGS_PE_HOU_STAT_DUP_EXISTS');
        IGS_GE_MSG_STACK.ADD;
	app_exception.raise_exception;
     END IF;
 END Check_Uniqueness ;


  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  ,
		 Column_Value IN VARCHAR2  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
        NULL;
      END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.teach_period_resid_stat_cd = new_references.teach_period_resid_stat_cd)) OR
        ((new_references.teach_period_resid_stat_cd IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Lookups_View_Pkg.Get_PK_For_Validation (
        		'PE_TEA_PER_RES',new_references.teach_period_resid_stat_cd
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
    x_teaching_period_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_teach_periods_all
      WHERE    teaching_period_id = x_teaching_period_id
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

  FUNCTION Get_UK_For_Validation (
	  x_cal_type IN VARCHAR2,
	  x_sequence_number IN NUMBER,
          x_person_id IN NUMBER
  ) RETURN BOOLEAN AS
  /***********************************************************

  Created By : gmaheswa

  Date Created By : 2004/11/4

  Purpose : check uniqueness on the table

  Know limitations, enhancements or remarks

  Change History

  Who      When     What
  ****************************************************************/

  CURSOR cur_rowid (cp_cal_type varchar2,cp_person_id number,cp_seq_number number)IS
  SELECT   load.rowid
  FROM     igs_pe_teach_periods_all load
  WHERE    load.person_id = cp_person_id
  AND      load.cal_type = cp_cal_type
  AND      load.sequence_number = cp_seq_number
  AND      ((l_rowid is null) or (rowid <> l_rowid));
  lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid(x_cal_type,x_person_id,x_sequence_number);
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN TRUE;
    ELSE
      CLOSE cur_rowid;
      RETURN FALSE;
    END IF;

  END Get_UK_For_Validation ;

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_teach_periods_all
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PPT_PP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,--DEFAULT NULL,
    x_teaching_period_id IN NUMBER ,--DEFAULT NULL,
    x_person_id IN NUMBER ,--DEFAULT NULL,
    x_teach_period_resid_stat_cd IN VARCHAR2 ,--DEFAULT NULL,
    x_cal_type IN VARCHAR2 ,--DEFAULT NULL,
    x_sequence_number IN NUMBER,-- DEFAULT NULL,
    x_creation_date IN DATE ,--DEFAULT NULL,
    x_created_by IN NUMBER ,--DEFAULT NULL,
    x_last_update_date IN DATE ,--DEFAULT NULL,
    x_last_updated_by IN NUMBER ,--DEFAULT NULL,
    x_last_update_login IN NUMBER ,--DEFAULT NULL,
    x_org_id IN NUMBER-- DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
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
      x_teaching_period_id,
      x_person_id,
      x_teach_period_resid_stat_cd,
      x_cal_type,
      x_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
        IF Get_Pk_For_Validation(new_references.teaching_period_id)  THEN
	    Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
            IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
        Check_Constraints;
	Check_Uniqueness;
	Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (new_references.teaching_period_id)  THEN
          Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
   	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Uniqueness;
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
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  gmaheswa      2-nov-2004    added a call to afterrowinsertupdate for date overlap check in case of insert/update and
                              added call out for processing FA todo items process in case of insert/update.
                              added a call to workflow package to raise an event in case of insert/update.
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := NULL;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
       IGS_PE_GEN_003.PROCESS_HOUSING_DTLS(
	  P_ACTION  	=> 'I',
          P_OLD_RECORD  => old_references,
  	  P_NEW_RECORD	=> new_references
	) ;

       IGS_PE_WF_GEN.change_housing_status(
	  P_PERSON_ID	=>	new_references.person_id,
          P_HOUSING_STATUS =>	new_references.teach_period_resid_stat_cd,
	  P_CALENDER_TYPE  =>	new_references.cal_type,
	  P_CAL_SEQ_NUM    =>	new_references.sequence_number,
	  P_TEACHING_PERIOD_ID =>new_references.teaching_period_id,
	  P_ACTION         =>    'I'
	);

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
       IF(  new_references.teach_period_resid_stat_cd <>  old_references.teach_period_resid_stat_cd)
       THEN

	  IGS_PE_WF_GEN.change_housing_status(
	         P_PERSON_ID	=>	new_references.person_id,
                 P_HOUSING_STATUS =>	new_references.teach_period_resid_stat_cd,
		 P_CALENDER_TYPE  =>	new_references.cal_type,
		 P_CAL_SEQ_NUM    =>	new_references.sequence_number,
		 P_TEACHING_PERIOD_ID =>new_references.teaching_period_id,
		 P_ACTION         =>    'U'
	  );

	  IGS_PE_GEN_003.PROCESS_HOUSING_DTLS(
		 P_ACTION  	=> 'U',
	         P_OLD_RECORD  => old_references,
  		 P_NEW_RECORD	=> new_references
	  ) ;

       END IF;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_TEACHING_PERIOD_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TEACH_PERIOD_RESID_STAT_CD IN VARCHAR2,
       x_CAL_TYPE IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
      X_MODE in VARCHAR2,-- default 'R',
      X_ORG_ID in NUMBER
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from igs_pe_teach_periods_all
             where
		TEACHING_PERIOD_ID= X_TEACHING_PERIOD_ID;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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
      select igs_pe_teach_periods_s.nextval into x_teaching_period_id from dual;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_teaching_period_id=>X_TEACHING_PERIOD_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_teach_period_resid_stat_cd=>X_TEACH_PERIOD_RESID_STAT_CD,
 	       x_cal_type=>X_CAL_TYPE,
 	       x_sequence_number=>X_SEQUENCE_NUMBER,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_org_id=>igs_ge_gen_003.get_org_id
	  );

      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_teach_periods_all (
		TEACHING_PERIOD_ID
		,PERSON_ID
		,TEACH_PERIOD_RESID_STAT_CD
		,CAL_TYPE
		,SEQUENCE_NUMBER
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,ORG_ID
     ) VALUES  (
	        NEW_REFERENCES.TEACHING_PERIOD_ID
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.TEACH_PERIOD_RESID_STAT_CD
	        ,NEW_REFERENCES.CAL_TYPE
	        ,NEW_REFERENCES.SEQUENCE_NUMBER
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
	        ,NEW_REFERENCES.ORG_ID
     );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

     OPEN c;
     FETCH c INTO X_ROWID;
     IF (c%NOTFOUND) THEN
	CLOSE c;
 	RAISE no_data_found;
     END IF;
     CLOSE c;
     After_DML (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID );
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

END INSERT_ROW;

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_TEACHING_PERIOD_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TEACH_PERIOD_RESID_STAT_CD IN VARCHAR2,
       x_CAL_TYPE IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER
     ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   CURSOR c1 IS
   SELECT
      PERSON_ID,
      TEACH_PERIOD_RESID_STAT_CD,
      CAL_TYPE,
      SEQUENCE_NUMBER
   FROM igs_pe_teach_periods_all
   WHERE ROWID = X_ROWID
   FOR UPDATE NOWAIT;
   tlinfo c1%rowtype;

BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    CLOSE c1;
    app_exception.raise_exception;
    RETURN;
  END IF;
  CLOSE c1;

  IF ( (  tlinfo.PERSON_ID = X_PERSON_ID)
     AND ((tlinfo.TEACH_PERIOD_RESID_STAT_CD = X_TEACH_PERIOD_RESID_STAT_CD)
         OR ((tlinfo.TEACH_PERIOD_RESID_STAT_CD is null)
            AND (X_TEACH_PERIOD_RESID_STAT_CD is null)))
     AND ((tlinfo.CAL_TYPE = X_CAL_TYPE)
         OR ((tlinfo.CAL_TYPE is null)
             AND (X_CAL_TYPE is null)))
     AND ((tlinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
 	    OR ((tlinfo.SEQUENCE_NUMBER is null)
		AND (X_SEQUENCE_NUMBER is null)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
       X_ROWID in  VARCHAR2,
       x_TEACHING_PERIOD_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TEACH_PERIOD_RESID_STAT_CD IN VARCHAR2,
       x_CAL_TYPE IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       X_MODE in VARCHAR2 --default 'R'
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 BEGIN
     X_LAST_UPDATE_DATE := SYSDATE;
     IF(X_MODE = 'I') THEN
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
     ELSIF (X_MODE IN ('R', 'S')) THEN
        X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        IF X_LAST_UPDATED_BY IS NULL THEN
            X_LAST_UPDATED_BY := -1;
        END IF;
        X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
        IF X_LAST_UPDATE_LOGIN IS NULL THEN
            X_LAST_UPDATE_LOGIN := -1;
        END IF;
     ELSE
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
        IGS_GE_MSG_STACK.ADD;
        app_exception.raise_exception;
     END IF;
   Before_DML(
 	       p_action=>'UPDATE',
 	       x_rowid=>X_ROWID,
 	       x_teaching_period_id=>X_TEACHING_PERIOD_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_teach_period_resid_stat_cd=>X_TEACH_PERIOD_RESID_STAT_CD,
 	       x_cal_type=>X_CAL_TYPE,
 	       x_sequence_number=>X_SEQUENCE_NUMBER,
 	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);

    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_teach_periods_all
   SET PERSON_ID =  NEW_REFERENCES.PERSON_ID,
       TEACH_PERIOD_RESID_STAT_CD =  NEW_REFERENCES.TEACH_PERIOD_RESID_STAT_CD,
       CAL_TYPE =  NEW_REFERENCES.CAL_TYPE,
       SEQUENCE_NUMBER =  NEW_REFERENCES.SEQUENCE_NUMBER,
       LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
       LAST_UPDATED_BY = X_LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
   WHERE ROWID = X_ROWID;

   IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


   After_DML (
	p_action => 'UPDATE' ,
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

END UPDATE_ROW;

PROCEDURE ADD_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_TEACHING_PERIOD_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TEACH_PERIOD_RESID_STAT_CD IN VARCHAR2,
       x_CAL_TYPE IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       X_MODE in VARCHAR2 ,--default 'R',
       X_ORG_ID in NUMBER
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR c1 IS
  SELECT ROWID
  FROM igs_pe_teach_periods_all
  WHERE TEACHING_PERIOD_ID= X_TEACHING_PERIOD_ID;

BEGIN
	OPEN c1;
	FETCH c1 INTO X_ROWID;
	IF (c1%NOTFOUND) THEN
  	   CLOSE c1;
           INSERT_ROW (
	       X_ROWID,
	       X_TEACHING_PERIOD_ID,
	       X_PERSON_ID,
	       X_TEACH_PERIOD_RESID_STAT_CD,
	       X_CAL_TYPE,
	       X_SEQUENCE_NUMBER,
 	       X_MODE,
	       X_ORG_ID );
	   RETURN;
	END IF;
        CLOSE c1;
	UPDATE_ROW (
	       X_ROWID,
	       X_TEACHING_PERIOD_ID,
	       X_PERSON_ID,
	       X_TEACH_PERIOD_RESID_STAT_CD,
	       X_CAL_TYPE,
	       X_SEQUENCE_NUMBER,
	       X_MODE );
END ADD_ROW;
PROCEDURE DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
    Before_DML (
      p_action => 'DELETE',
      x_rowid => X_ROWID
    );
     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from igs_pe_teach_periods_all
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
END DELETE_ROW;
END igs_pe_teach_periods_pkg;

/
