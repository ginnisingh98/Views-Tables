--------------------------------------------------------
--  DDL for Package Body IGS_AD_CODE_CLASSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_CODE_CLASSES_PKG" AS
/* $Header: IGSAI75B.pls 120.3 2005/09/21 07:03:17 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_code_classes%RowType;
  new_references igs_ad_code_classes%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_code_id IN NUMBER,
    x_name IN VARCHAR2,
    x_description IN VARCHAR2,
    x_class IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_system_status IN VARCHAR2,
    x_system_default IN VARCHAR2,
    x_class_type_code  IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  samaresh	  28-dec-2001	  Bug Number  2158524. Two columns
				  SYSTEM_STATUS and SYSTEM_DEFAULT
				  have been added
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_CODE_CLASSES
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
    new_references.code_id := x_code_id;
    new_references.name := x_name;
    new_references.description := x_description;
    new_references.class := x_class;
    new_references.closed_ind := x_closed_ind;
    new_references.system_status := x_system_status;
    new_references.system_default := x_system_default;
    new_references.class_type_code := x_class_type_code;
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
		 Column_Name IN VARCHAR2,
		 Column_Value IN VARCHAR2) AS
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
      ELSIF  UPPER(column_name) = 'CLOSED_IND'  THEN
        new_references.closed_ind := column_value;
        NULL;
      END IF;

      -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'CLOSED_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.closed_ind IN ('Y','N'))  THEN
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
 rrengara       9-APR-2002      Bugno : 2309311 - Added check for SYS_APPL_SOURCE.
 pkpatel        20-JUL-2001     Bug no. 1890270 Admissions Standards and Rules Dld_adsr_setup
                                Added code to check for the existence of new lookup_type 'PROBABILITY_DETAILS'
 samaresh       28-dec-2001	Modified the function lookup_thru_lookup_type to add another parameter
		                Bug Number  2158524. Two columns SYSTEM_STATUS and SYSTEM_DEFAULT have been added
				Added call to igs_lookups_view_pkg.get_pk_for_validation for the column
				system_status
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    IF (old_references.class = new_references.class OR
        new_references.class IS NULL) THEN
      NULL;
    ELSIF NOT (Igs_Lookups_view_pkg.Get_PK_For_Validation ('ADM_CODE_CLASSES',new_references.class)OR
	    Igs_Lookups_view_pkg.Get_PK_For_Validation ('IGS_AD_QUAL_TYPE',new_references.class) OR
	    Igs_Lookups_view_pkg.Get_PK_For_Validation (new_references.class_type_code,new_references.class)) THEN
      Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END IF;

    IF (old_references.system_status = new_references.system_status OR
        new_references.system_status IS NULL) THEN
      NULL;
    ELSIF NOT (Igs_Lookups_view_pkg.Get_PK_For_Validation (new_references.class,new_references.system_status)) THEN
      Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
  END Check_Parent_Existance;

 PROCEDURE Check_Uniqueness AS
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
     		IF Get_Uk_For_Validation (
    		new_references.name
    		,new_references.class
		,new_references.class_type_code
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;

 PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : amuthu
  Date Created On : 15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  nshee           07-feb-2001     Changed the call of IGS_AD_CREDENTIALS
                                  as part of Bug#2177686 to IGS_PE_CREDENTIALS
 agairola      09-AUG-2001    Added the code for Foreign Key with Statistics and IGS_PE_HZ_PARTIES
                              for Bug No. 1872994
 pkpatel       19-JUL-2001    Bug no. 1890270 Admissions Standards and Rules Dld_adsr_setup
                              Added the call igs_ad_recruit_pi_pkg.get_fk_igs_ad_code_classes for
                              checking child existence in igs_ad_recruit_pi table
 nsinha        Aug 01, 2001     Bug enh no : 1905651 changes.
                                Added Igs_Ad_Appl_Pkg.Get_FK_Igs_Ad_Code_Classes
 rboddu        Oct 10, 2001    Bug no: 2019075 changes
                                Added  Igs_Ad_Acad_Honors_Pkg..Get_FK_Igs_Ad_Cod
  npalanis     OCT 31 2002     Bug : 2608360
                               remove get fk for code classes migrated to lookups e_classes for checking
			       child existence in igs_ad_acad_honors table which was missed out NOCOPY earlier from the Check_Child_Existence procedure.
  Aiyer         04-feb-2003   Bug : 2664699  Removed get_fk for code classes with IGS_AD_I_ENTRY_STATS_PKG (test_source_id column)


  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Ad_Adv_Placement_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_Appl_Eval_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_App_Intent_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_App_Req_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_Conv_Gs_Types_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_Edugoal_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );


    Igs_Ad_Past_History_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_Ps_Appl_Inst_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_Spl_Talents_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_Term_Unitdtls_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_Test_Results_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_Transcript_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_Tst_Rslt_Dtls_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );

    Igs_Ad_Appqual_Code_Pkg.Get_FK_Igs_Ad_Code_Classes(
      old_references.code_id
      );

    IF NVL(fnd_profile.value('IGS_RECRUITING_ENABLED'), 'N') = 'Y' THEN
      EXECUTE IMMEDIATE
      'begin Igr_I_Appl_Pkg.Get_FK_Igs_Ad_Code_Classes (:1); end;'
      USING old_references.code_id;
    END IF;

    igs_ad_recruit_pi_pkg.get_fk_igs_ad_code_classes (
      old_references.code_id
      );

     Igs_Ad_Appl_Pkg.Get_FK_Igs_Ad_Code_Classes (
      old_references.code_id
      );


     IGS_PE_HZ_PARTIES_PKG.Get_Fk_IGS_AD_CODE_CLASSES1(
      old_references.code_id
      );


    IGS_UC_DEFAULTS_PKG.GET_FK_IGS_AD_CODE_CLASSES(
      old_references.code_id
      );

    IGS_AD_PANEL_DTLS_PKG.GET_UFK_IGS_AD_CODE_CLASSES(
      old_references.name,
      old_references.class
      );

    IGS_AD_PNMEMBR_DTLS_PKG.GET_UFK_IGS_AD_CODE_CLASSES(
      old_references.name,
      old_references.class
      );

    IGS_AD_PNL_HIS_DTLS_PKG.GET_UFK_IGS_AD_CODE_CLASSES(
      old_references.name,
      old_references.class
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_code_id IN NUMBER,
    x_closed_ind IN VARCHAR2
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
      FROM     igs_ad_code_classes
      WHERE    code_id = x_code_id AND
               closed_ind = NVL(x_closed_ind,closed_ind);

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
    x_name IN VARCHAR2,
    x_class IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_class_type_code  IN VARCHAR2 DEFAULT NULL
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
    l_class_type_code  VARCHAR2(30);

    CURSOR cur_rowid(cp_class_type_code IN VARCHAR2) IS
      SELECT   rowid
      FROM     igs_ad_code_classes
      WHERE    name = x_name  AND
               class = x_class AND
	       class_type_code = cp_class_type_code AND
               ((l_rowid is null) or (rowid <> l_rowid)) AND
               closed_ind = NVL(x_closed_ind,closed_ind);

    lv_rowid cur_rowid%RowType;


  BEGIN
   l_class_type_code :=NVL(x_class_type_code,'ADM_CODE_CLASSES');

    Open cur_rowid(l_class_type_code);
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK_For_Validation ;

FUNCTION Get_UK2_For_Validation (
    x_code_id IN NUMBER,
    x_class IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_class_type_code  IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : akadam
  Date Created On : 11-Nov-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    l_class_type_code  VARCHAR2(30);

    CURSOR cur_rowid(cp_class_type_code IN VARCHAR2) IS
      SELECT   rowid
      FROM     igs_ad_code_classes
      WHERE    code_id = x_code_id  AND
               class = x_class AND
	       class_type_code = cp_class_type_code AND
               ((l_rowid is null) or (rowid <> l_rowid)) AND
               closed_ind = NVL(x_closed_ind,closed_ind);

    lv_rowid cur_rowid%RowType;

  BEGIN
   l_class_type_code :=NVL(x_class_type_code,'ADM_CODE_CLASSES');

    Open cur_rowid(l_class_type_code);
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK2_For_Validation ;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_code_id IN NUMBER,
    x_name IN VARCHAR2,
    x_description IN VARCHAR2,
    x_class IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_system_status IN VARCHAR2,
    x_system_default IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_class_type_code  IN VARCHAR2 DEFAULT NULL
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
      x_code_id,
      x_name,
      x_description,
      x_class,
      x_closed_ind,
      x_system_status,
      x_system_default,
      x_class_type_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.code_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Parent_Existance;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Uniqueness;
      Check_Parent_Existance;
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.code_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

    l_rowid := NULL;
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

  l_rowid:=NULL;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_CODE_ID IN OUT NOCOPY NUMBER,
       x_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLASS IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_system_status IN VARCHAR2,
       x_system_default IN VARCHAR2,
       X_MODE in VARCHAR2,
       x_class_type_code  IN VARCHAR2 DEFAULT NULL
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

    cursor C is select ROWID from IGS_AD_CODE_CLASSES
             where                 CODE_ID= X_CODE_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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

   X_CODE_ID := -1;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_code_id=>X_CODE_ID,
 	       x_name=>X_NAME,
 	       x_description=>X_DESCRIPTION,
 	       x_class=>X_CLASS,
 	       x_closed_ind=>X_CLOSED_IND,
               x_system_status => X_SYSTEM_STATUS,
               x_system_default => X_SYSTEM_DEFAULT,
               x_class_type_code  => x_class_type_code,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_AD_CODE_CLASSES (
		CODE_ID
		,NAME
		,DESCRIPTION
		,CLASS
		,CLOSED_IND
		,SYSTEM_STATUS
		,SYSTEM_DEFAULT
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,class_type_code
        ) values  (
	         IGS_AD_CODE_CLASSES_S.NEXTVAL
	        ,NEW_REFERENCES.NAME
	        ,NEW_REFERENCES.DESCRIPTION
	        ,NEW_REFERENCES.CLASS
	        ,NEW_REFERENCES.CLOSED_IND
		,NEW_REFERENCES.SYSTEM_STATUS
		,NEW_REFERENCES.SYSTEM_DEFAULT
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,NEW_REFERENCES.class_type_code
)RETURNING CODE_ID INTO X_CODE_ID ;
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
       x_CODE_ID IN NUMBER,
       x_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLASS IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_system_status IN VARCHAR2 ,
       x_system_default IN VARCHAR2,
      x_class_type_code  IN VARCHAR2 DEFAULT NULL
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

   cursor c1 is select
      NAME
,      DESCRIPTION
,      CLASS
,      CLOSED_IND
,      SYSTEM_STATUS
,      SYSTEM_DEFAULT
,      class_type_code
    from IGS_AD_CODE_CLASSES
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
if ( (  tlinfo.NAME = X_NAME)
  AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
  AND (tlinfo.CLASS = X_CLASS)
  AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
  AND ((tlinfo.SYSTEM_STATUS = x_system_status)
 	OR ((tlinfo.system_status is null)
		AND (x_system_status is null)))
  AND ((tlinfo.SYSTEM_DEFAULT = x_system_default)
 	OR ((tlinfo.system_default is null)
		AND (x_system_default is null)))
  AND ((tlinfo.class_type_code = x_class_type_code)
 	OR ((tlinfo.class_type_code is null)
		AND (x_class_type_code is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_CODE_ID IN NUMBER,
       x_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLASS IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_SYSTEM_STATUS IN VARCHAR2,
       x_SYSTEM_DEFAULT IN VARCHAR2,
       X_MODE in VARCHAR2,
       x_class_type_code  IN VARCHAR2 DEFAULT NULL
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
 	       x_code_id=>X_CODE_ID,
 	       x_name=>X_NAME,
 	       x_description=>X_DESCRIPTION,
 	       x_class=>X_CLASS,
 	       x_closed_ind=>X_CLOSED_IND,
	       x_system_status=>X_SYSTEM_STATUS,
	       x_system_default=>X_SYSTEM_DEFAULT,
               x_class_type_code  =>  x_class_type_code,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_AD_CODE_CLASSES set
      NAME =  NEW_REFERENCES.NAME,
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      CLASS =  NEW_REFERENCES.CLASS,
      CLOSED_IND =  NEW_REFERENCES.CLOSED_IND,
      SYSTEM_STATUS = NEW_REFERENCES.SYSTEM_STATUS,
      SYSTEM_DEFAULT = NEW_REFERENCES.SYSTEM_DEFAULT,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	class_type_code = x_class_type_code
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
       x_CODE_ID IN OUT NOCOPY NUMBER,
       x_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLASS IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_SYSTEM_STATUS IN VARCHAR2,
       x_SYSTEM_DEFAULT IN VARCHAR2,
       X_MODE in VARCHAR2,
       x_class_type_code  IN VARCHAR2 DEFAULT NULL
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

    cursor c1 is select ROWID from IGS_AD_CODE_CLASSES
             where     CODE_ID= X_CODE_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_CODE_ID,
       X_NAME,
       X_DESCRIPTION,
       X_CLASS,
       X_CLOSED_IND,
       X_SYSTEM_STATUS,
       X_SYSTEM_DEFAULT,
       x_class_type_code,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_CODE_ID,
       X_NAME,
       X_DESCRIPTION,
       X_CLASS,
       X_CLOSED_IND,
       X_SYSTEM_STATUS,
       X_SYSTEM_DEFAULT,
       x_class_type_code,
      X_MODE );
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
 delete from IGS_AD_CODE_CLASSES
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ad_code_classes_pkg;

/
