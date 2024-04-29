--------------------------------------------------------
--  DDL for Package Body IGS_PE_SRC_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_SRC_TYPES_PKG" AS
/* $Header: IGSNI65B.pls 120.0 2005/06/01 12:36:23 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_pe_src_types_all%RowType;
  new_references igs_pe_src_types_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_source_type_id IN NUMBER DEFAULT NULL,
    x_source_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_system_source_type IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_person_type_code IN VARCHAR2 DEFAULT NULL,
    x_enquiry_source_type IN VARCHAR2 DEFAULT NULL,
    x_funnel_status IN VARCHAR2 DEFAULT NULL,
    x_inq_entry_stat_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    X_ORG_ID in NUMBER default NULL,
    X_INQUIRY_TYPE_ID IN NUMBER DEFAULT NULL
  ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  pbondugu  26-Feb-2003   new_references. admission_Cat  is set to NULL
***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_src_types_all
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
    new_references.source_type_id := x_source_type_id;
    new_references.source_type := x_source_type;
    new_references.description := x_description;
    new_references.system_source_type := x_system_source_type;
    new_references.admission_cat := NULL;
    new_references.closed_ind := x_closed_ind;
    new_references.person_type_code := x_person_type_code;
    new_references.enquiry_source_type := x_enquiry_source_type;
    new_references.funnel_status := x_funnel_status ;
    new_references.inq_entry_stat_id := x_inq_entry_stat_id ;
    new_references.org_id := x_org_id;
    new_references.inquiry_type_id := X_INQUIRY_TYPE_ID;
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
    Column_Name IN VARCHAR2  DEFAULT NULL,
    Column_Value IN VARCHAR2  DEFAULT NULL ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
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
        IF NOT (new_references.closed_ind IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;
  END Check_Constraints;



  FUNCTION Get_PK_For_Validation (
    x_source_type_id IN NUMBER
    ) RETURN BOOLEAN AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_src_types_all
      WHERE    source_type_id = x_source_type_id
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

  PROCEDURE BEFORE_UPDATE_DELETE AS

  /*************************************************************
  Created By :amuthu
  Date Created By :19-MAY-2000
  Purpose : To delete the rows that where add during
            insert through IGS_AD_SRC_CAT_INSERT.

  Know limitations, enhancements or remarks
  Change History

  Who             When            What
rasingh		  19-JUL-2001	  DLD: Interface to Academic History:
				  'TRANSCRIPT' added to the list of system_source_type
rghosh           14-Feb-2003    removed the source type SS_ADM_APPL for bug #2422183
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c_asc IS
      SELECT rowid
      FROM IGS_AD_SOURCE_CAT
      WHERE source_type_id = old_references.source_type_id;
  BEGIN
    IF old_references.system_source_type in ('APPLICATION',
					     'TEST_RESULTS',
					     'PROSPECT_LIST',
					     'PROSPECT_SS_WEB_INQUIRY',
                                             'TRANSCRIPT') THEN   -- removed the source type SS_ADM_APPL for bug #2422183 (rghosh)
      FOR c_asc_rec IN c_asc
      LOOP
        IGS_AD_SOURCE_CAT_PKG.DELETE_ROW(
          c_asc_rec.rowid
        );
      END LOOP;
    END IF;

  END BEFORE_UPDATE_DELETE;

  PROCEDURE Check_Child_Existance AS
 /*************************************************************
  Created By :SVISWEAS
  Date Created By :27-MAY-2000
  Purpose : Check_Child_Existance
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  Aiyer           04-Feb-2003     Modified for the bug 2664699
                                  Replaced call to IGS_AD_I_ENTRY_STATS_PKG.GET_FK_FOR_VALIDATION
	                 			  with IGS_RC_I_ENT_STATS_PKG.GET_FK_FOR_VALIDATION
  pkpatel         10-JUN-2003     Bug 2996726
                                  Added the call igs_pe_match_sets_pkg.get_fk_igs_pe_src_types
  (reverse chronological order - newest change first)

 ***************************************************************/
 BEGIN
    igs_ad_interface_ctl_pkg.get_fk_igs_pe_src_types (
      old_references.source_type_id
    );

    IF NVL(fnd_profile.value('IGS_RECRUITING_ENABLED'), 'N') = 'Y' THEN
      EXECUTE IMMEDIATE
      'begin igr_i_inquiry_types_pkg.get_fk_igs_pe_src_types  ( :1 ); end;'
      USING old_references.source_type_id;
    END IF;

	igs_pe_match_sets_pkg.get_fk_igs_pe_src_types (
      old_references.source_type_id
    );
  END Check_Child_Existance;


  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/05/13
  Purpose : To check the master records exists before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  pbondugu  26_feb-2003      Nullified
  ***************************************************************/

  BEGIN
    NULL;
    /*******  Commented as part of bug 2422183
    IF (((old_references.admission_cat = new_references.admission_cat)) OR
        ((new_references.admission_cat IS NULL))) THEN
       NULL;
    ELSIF NOT Igs_Ad_Cat_pkg.Get_PK_For_Validation (
	new_references.admission_cat
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;
    Commented as part of bug 2422183 *******/
  END Check_Parent_Existance;


 FUNCTION Get_UK_For_Validation (
    x_source_type IN VARCHAR2
    ) RETURN BOOLEAN AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :27-MAY-2000
  Purpose : Get_UK_For_Validation
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_src_types_all
      WHERE    source_type = x_source_type
      and      ((l_rowid is null) or (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        Return (TRUE);
        ELSE
       close cur_rowid;
      return(false);
    END IF;

  END Get_UK_For_Validation ;


   FUNCTION Get_Description (
     x_inquiry_type_id IN NUMBER
   ) RETURN VARCHAR2 AS
/*************************************************************
  Created By :askapoor
  Date Created By :11-March-2005
  Purpose : Called from IGSPE021.pld to get the inquiry type code
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
***************************************************************/

  TYPE inquiry_csr_type IS REF CURSOR;
  l_inquiry_csr inquiry_csr_type;

  l_query VARCHAR2(1000);
  l_inq_type_dsp VARCHAR2(40);

  BEGIN

  l_query := 'select INQUIRY_TYPE_CD from igr_i_inquiry_types where INQUIRY_TYPE_ID = :1';

   OPEN l_inquiry_csr FOR l_query USING x_inquiry_type_id;
      LOOP
        FETCH l_inquiry_csr INTO l_inq_type_dsp;
        EXIT WHEN l_inquiry_csr%NOTFOUND;
     END LOOP;
      CLOSE l_inquiry_csr;

 RETURN l_inq_type_dsp;


END Get_Description;

PROCEDURE Check_Uniqueness as
/*************************************************************
  Created By :SVISWEAS
  Date Created By :27-MAY-2000
  Purpose : Check_Uniqueness
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
***************************************************************/
   Begin
     IF Get_Uk_For_Validation (
        new_references.source_type
        ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
	app_exception.raise_exception;
    	END IF;
 END Check_Uniqueness ;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_source_type_id IN NUMBER DEFAULT NULL,
    x_source_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_system_source_type IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_person_type_code IN VARCHAR2 DEFAULT NULL,
    x_enquiry_source_type IN VARCHAR2 DEFAULT NULL,
    x_funnel_status IN VARCHAR2 DEFAULT NULL,
    x_inq_entry_stat_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER default NULL,
    X_INQUIRY_TYPE_ID IN NUMBER DEFAULT NULL
  ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  | asbala          18-JUL-03        2885709, made l_rowid := null at the end of before_dml
***************************************************************/
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_source_type_id,
      x_source_type,
      x_description,
      x_system_source_type,
      x_admission_cat,
      x_closed_ind,
      x_person_type_code ,
      x_enquiry_source_type ,
      x_funnel_status,
      x_inq_entry_stat_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id,
      X_INQUIRY_TYPE_ID
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
       Null;
       IF Get_Pk_For_Validation(
     	  new_references.source_type_id)  THEN
	    Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
       END IF;
       Check_Constraints;
       Check_Uniqueness;
       Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       IF old_references.system_source_type
          <> new_references.system_source_type THEN
          BEFORE_UPDATE_DELETE;
       END IF;
       Check_Constraints;
       Check_Uniqueness;
       Check_Parent_Existance;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
	  Check_Child_Existance;
      BEFORE_UPDATE_DELETE;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
      	 new_references.source_type_id)  THEN
	    Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;

      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;

      Check_Parent_Existance;

    ELSIF (p_action = 'VALIDATE_DELETE') THEN
   	  Check_Child_Existance;
    END IF;
 l_rowid:=null;
  END Before_DML;


  PROCEDURE AFTER_UPDATE_INSERT AS

  /*************************************************************
  Created By :amuthu
  Date Created By :19-MAY-2000
  Purpose : Insert records into the IGS_AD_SOURCE_CAT table
            when the SYSTEM SOURCE TYPE of the inserted record
            is IN ('TEST_RESULTS','PROSPECT_LIST','APPLICATION',
            'PROSPECT_SS_WEB_INQUIRY')

  Know limitations, enhancements or remarks

  Change History

  Who             When            What
 pkpatel         21-JUN-2001     DLD:Modelling and Forecasting-SDQ
				To make the default DISCREPANCY RULE as 'I'
				i.e. 'Updating Existing Values With Imported Values'.
				And include DETAIL_LEVEL_IND, AD_TAB_NAME and INT_TAB_NAME columns
				in the call to Igs_Ad_Source_Cat_Pkg.Insert_Row.
 rasingh	19-JUL-2001	DLD: Interface to Academic History.
				Ssytem Source Type of Transcript added to the list of
				system_source_types.
rghosh           14-Feb-2003    removed the source type SS_ADM_APPL for bug #2422183
  (reverse chronological order - newest change first)
  pbondugu   26-Feb-2003   Cursor c_sysc is change (condition for closed_ind is adde
  ***************************************************************/
    CURSOR c_sysc IS
      SELECT *
      FROM IGS_AD_SYSSRC_CAT
      WHERE system_source_type = new_references.system_source_type
      AND      NVL(closed_ind,'N') = 'N';

    lv_rowid  		VARCHAR2(25);
    lv_src_cat_id	NUMBER;
    l_org_id 		NUMBER(15);
  BEGIN
    IF new_references.system_source_type in ('APPLICATION',
					     'TEST_RESULTS',
					     'PROSPECT_LIST',
					     'PROSPECT_SS_WEB_INQUIRY',
                                             'TRANSCRIPT') THEN  -- removed the source type SS_ADM_APPL for bug #2422183 (rghosh)
      FOR c_sysc_rec in c_sysc
      LOOP

        l_org_id 		:= igs_ge_gen_003.get_org_id;
        IGS_AD_SOURCE_CAT_PKG.INSERT_ROW (
          X_ROWID 		=> lv_rowid,
          x_SRC_CAT_ID 		=> lv_src_cat_id,
          x_SOURCE_TYPE_ID	=> new_references.source_type_id,
          x_CATEGORY_NAME 	=> c_sysc_rec.category_name,
          x_MANDATORY_IND 	=> c_sysc_rec.mandatory_ind,
          x_INCLUDE_IND 	=> c_sysc_rec.mandatory_ind,
          x_SS_MANDATORY_IND 	=> c_sysc_rec.mandatory_ind,
          x_ORG_ID 		=> l_org_id,
          x_DISCREPANCY_RULE_CD => 'I', -- To make the default DISCREPANCY RULE as 'I'
        				-- i.e.  'Updating Existing Values With Imported Values'.
          x_SS_IND		=> c_sysc_rec.ss_ind,
          x_DISPLAY_SEQUENCE	=> c_sysc_rec.display_sequence,
          x_DETAIL_LEVEL_IND    => NULL,
          x_AD_TAB_NAME         => c_sysc_rec.ad_tab_name,
          x_INT_TAB_NAME        => c_sysc_rec.int_tab_name,
          X_MODE 		=> 'R'
        );

      END LOOP;
    END IF;
  END AFTER_UPDATE_INSERT;


  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 asbala          21-JUL-03      2885709: made l_rowid:=null in the end
  (reverse chronological order - newest change first)
***************************************************************/
  BEGIN

    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AFTER_UPDATE_INSERT;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      IF old_references.system_source_type
         <> new_references.system_source_type THEN
        AFTER_UPDATE_INSERT;
      END IF;
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;
    l_rowid:=null;
  END After_DML;

  procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_SOURCE_TYPE_ID IN OUT NOCOPY NUMBER,
    x_SOURCE_TYPE IN VARCHAR2,
    x_DESCRIPTION IN VARCHAR2,
    x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
 x_ADMISSION_CAT IN VARCHAR2 ,
    x_CLOSED_IND IN VARCHAR2,
    x_PERSON_TYPE_CODE IN VARCHAR2 DEFAULT NULL,
    x_ENQUIRY_SOURCE_TYPE IN VARCHAR2 DEFAULT NULL,
    x_FUNNEL_STATUS IN VARCHAR2 DEFAULT NULL,
    x_INQ_ENTRY_STAT_ID IN NUMBER DEFAULT NULL,
    X_MODE in VARCHAR2 default 'R'  ,
    X_ORG_ID in NUMBER,
    X_INQUIRY_TYPE_ID IN NUMBER DEFAULT NULL
  ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 sbaliga	13-feb-2002	Assigned igs_ge_gen_003.get_org_id to x_org_id
 				in call to before_dml as part of SWCR006 build.
  (reverse chronological order - newest change first)
  pbondugu 26-Feb-2003   admission_Cat is assigned with  Null
***************************************************************/
    cursor C is
      select ROWID
      from igs_pe_src_types_all
      where  SOURCE_TYPE_ID= X_SOURCE_TYPE_ID;

    X_LAST_UPDATE_DATE DATE ;
    X_LAST_UPDATED_BY NUMBER ;
    X_LAST_UPDATE_LOGIN NUMBER ;
  begin
    X_LAST_UPDATE_DATE := SYSDATE;
    IF(X_MODE = 'I') THEN
       X_LAST_UPDATED_BY := 1;
       X_LAST_UPDATE_LOGIN := 0;
    ELSIF (X_MODE = 'R') THEN
       X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
       IF X_LAST_UPDATED_BY is NULL THEN
          X_LAST_UPDATED_BY := -1;
       END IF;
          X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
       if X_LAST_UPDATE_LOGIN is NULL THEN
          X_LAST_UPDATE_LOGIN := -1;
       END IF;
    ELSE
       FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
       IGS_GE_MSG_STACK.ADD;
       app_exception.raise_exception;
    END IF;

    SELECT IGS_PE_SRC_TYPES_S.NEXTVAL
    INTO X_SOURCE_TYPE_ID
    FROM DUAL;

    Before_DML(
      p_action=>'INSERT',
      x_rowid=>X_ROWID,
      x_source_type_id=>X_SOURCE_TYPE_ID,
      x_source_type=>X_SOURCE_TYPE,
      x_description=>X_DESCRIPTION,
      x_system_source_type=>X_SYSTEM_SOURCE_TYPE,
      x_admission_cat=>NULL,
      x_closed_ind=>X_CLOSED_IND,
      x_person_type_code => X_PERSON_TYPE_CODE,
      x_enquiry_source_type => X_ENQUIRY_SOURCE_TYPE,
      x_funnel_status => X_FUNNEL_STATUS ,
      x_inq_entry_stat_id => X_INQ_ENTRY_STAT_ID ,
      x_creation_date=>X_LAST_UPDATE_DATE,
      x_created_by=>X_LAST_UPDATED_BY,
      x_last_update_date=>X_LAST_UPDATE_DATE,
      x_last_updated_by=>X_LAST_UPDATED_BY,
      x_last_update_login=>X_LAST_UPDATE_LOGIN,
      x_org_id=>igs_ge_gen_003.get_org_id,
      x_inquiry_type_id => X_INQUIRY_TYPE_ID
           );

INSERT INTO igs_pe_src_types_all (
        SOURCE_TYPE_ID
        ,SOURCE_TYPE
        ,DESCRIPTION
        ,SYSTEM_SOURCE_TYPE
        ,ADMISSION_CAT
        ,CLOSED_IND
        ,PERSON_TYPE_CODE
	,ENQUIRY_SOURCE_TYPE
	,FUNNEL_STATUS
	,INQ_ENTRY_STAT_ID
	,CREATION_DATE
	,CREATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,ORG_ID
	,INQUIRY_TYPE_ID
    ) values  (
	NEW_REFERENCES.SOURCE_TYPE_ID
	,NEW_REFERENCES.SOURCE_TYPE
	,NEW_REFERENCES.DESCRIPTION
	,NEW_REFERENCES.SYSTEM_SOURCE_TYPE
	,NULL -- NEW_REFERENCES.ADMISSION_CAT
	,NEW_REFERENCES.CLOSED_IND
	,NEW_REFERENCES.PERSON_TYPE_CODE
	,NEW_REFERENCES.ENQUIRY_SOURCE_TYPE
	,NEW_REFERENCES.FUNNEL_STATUS
	,NEW_REFERENCES.INQ_ENTRY_STAT_ID
	,X_LAST_UPDATE_DATE
	,X_LAST_UPDATED_BY
	,X_LAST_UPDATE_DATE
	,X_LAST_UPDATED_BY
	,X_LAST_UPDATE_LOGIN,
	NEW_REFERENCES.ORG_ID,
	NEW_REFERENCES.INQUIRY_TYPE_ID
    );
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
     x_SOURCE_TYPE_ID IN NUMBER,
     x_SOURCE_TYPE IN VARCHAR2,
     x_DESCRIPTION IN VARCHAR2,
     x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
     x_ADMISSION_CAT IN VARCHAR2,
     x_CLOSED_IND IN VARCHAR2,
     x_PERSON_TYPE_CODE IN VARCHAR2 DEFAULT NULL,
     x_ENQUIRY_SOURCE_TYPE IN VARCHAR2 DEFAULT NULL,
     x_FUNNEL_STATUS IN VARCHAR2 DEFAULT NULL,
     x_INQ_ENTRY_STAT_ID IN NUMBER DEFAULT NULL,
     X_INQUIRY_TYPE_ID IN NUMBER DEFAULT NULL
  ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  pbondugu    26-FEb-2003 Condition for admission_cat is removed
  askapoor    14-Mar-2005 Removed reference of INQ_ENTRY_STAT_ID in the AND condition
***************************************************************/
    cursor c1 is select
       SOURCE_TYPE
      ,DESCRIPTION
      ,SYSTEM_SOURCE_TYPE
      ,ADMISSION_CAT
      ,CLOSED_IND
      ,PERSON_TYPE_CODE
      ,ENQUIRY_SOURCE_TYPE
      ,FUNNEL_STATUS
      ,INQ_ENTRY_STAT_ID
      ,INQUIRY_TYPE_ID
    FROM igs_pe_src_types_all
    WHERE ROWID = X_ROWID
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

     if ( (  tlinfo.SOURCE_TYPE = X_SOURCE_TYPE)
	  AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
 	    OR ((tlinfo.DESCRIPTION is null)
		AND (X_DESCRIPTION is null)))
	  AND (tlinfo.SYSTEM_SOURCE_TYPE = X_SYSTEM_SOURCE_TYPE)
	   AND ((tlinfo.CLOSED_IND = X_CLOSED_IND)
 	    OR ((tlinfo.CLOSED_IND is null)
		AND (X_CLOSED_IND is null)))
	AND ((tlinfo.PERSON_TYPE_CODE = X_PERSON_TYPE_CODE)
 	    OR ((tlinfo.PERSON_TYPE_CODE is null)
		AND (X_PERSON_TYPE_CODE is null)))
	AND ((tlinfo.ENQUIRY_SOURCE_TYPE = X_ENQUIRY_SOURCE_TYPE)
 	    OR ((tlinfo.ENQUIRY_SOURCE_TYPE is null)
		AND (X_ENQUIRY_SOURCE_TYPE is null)))
	AND ((tlinfo.FUNNEL_STATUS = X_FUNNEL_STATUS)
 	    OR ((tlinfo.FUNNEL_STATUS is null)
		AND (X_FUNNEL_STATUS is null)))
	AND ((tlinfo.INQUIRY_TYPE_ID = X_INQUIRY_TYPE_ID)
 	    OR ((tlinfo.INQUIRY_TYPE_ID is null)
		AND (X_INQUIRY_TYPE_ID is null)))
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
      x_SOURCE_TYPE_ID IN NUMBER,
      x_SOURCE_TYPE IN VARCHAR2,
      x_DESCRIPTION IN VARCHAR2,
      x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
      x_ADMISSION_CAT IN VARCHAR2,
      x_CLOSED_IND IN VARCHAR2,
      x_PERSON_TYPE_CODE IN VARCHAR2 DEFAULT NULL,
      x_ENQUIRY_SOURCE_TYPE IN VARCHAR2 DEFAULT NULL,
      x_FUNNEL_STATUS IN VARCHAR2 DEFAULT NULL,
      x_INQ_ENTRY_STAT_ID IN NUMBER DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'  ,
      X_INQUIRY_TYPE_ID IN NUMBER DEFAULT NULL
    ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  pbondugu 26-FEb-2003    admission_Cat is made to null
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
 	 x_source_type_id=>X_SOURCE_TYPE_ID,
 	 x_source_type=>X_SOURCE_TYPE,
 	 x_description=>X_DESCRIPTION,
 	 x_system_source_type=>X_SYSTEM_SOURCE_TYPE,
         x_admission_cat=>NULL,
 	 x_closed_ind=>X_CLOSED_IND,
	 x_person_type_code => X_PERSON_TYPE_CODE,
         x_enquiry_source_type => X_ENQUIRY_SOURCE_TYPE,
         x_funnel_status => X_FUNNEL_STATUS ,
	 x_inq_entry_stat_id => X_INQ_ENTRY_STAT_ID ,
	 x_creation_date=>X_LAST_UPDATE_DATE,
         x_created_by=>X_LAST_UPDATED_BY,
         x_last_update_date=>X_LAST_UPDATE_DATE,
         x_last_updated_by=>X_LAST_UPDATED_BY,
         x_last_update_login=>X_LAST_UPDATE_LOGIN,
	 x_inquiry_type_id => X_INQUIRY_TYPE_ID
     );

      UPDATE igs_pe_src_types_all SET
        SOURCE_TYPE = NEW_REFERENCES.SOURCE_TYPE,
        DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
        SYSTEM_SOURCE_TYPE =  NEW_REFERENCES.SYSTEM_SOURCE_TYPE,
        ADMISSION_CAT =  NULL, --NEW_REFERENCES.ADMISSION_CAT,
        CLOSED_IND =  NEW_REFERENCES.CLOSED_IND,
	PERSON_TYPE_CODE = NEW_REFERENCES.PERSON_TYPE_CODE,
	ENQUIRY_SOURCE_TYPE = NEW_REFERENCES.ENQUIRY_SOURCE_TYPE,
	FUNNEL_STATUS =	NEW_REFERENCES.FUNNEL_STATUS ,
	INQ_ENTRY_STAT_ID = NEW_REFERENCES.INQ_ENTRY_STAT_ID ,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	INQUIRY_TYPE_ID = X_INQUIRY_TYPE_ID
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
     x_SOURCE_TYPE_ID IN OUT NOCOPY NUMBER,
     x_SOURCE_TYPE IN VARCHAR2,
     x_DESCRIPTION IN VARCHAR2,
     x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
     x_ADMISSION_CAT IN VARCHAR2,
     x_CLOSED_IND IN VARCHAR2,
     x_PERSON_TYPE_CODE IN VARCHAR2 DEFAULT NULL,
     x_ENQUIRY_SOURCE_TYPE IN VARCHAR2 DEFAULT NULL,
     x_FUNNEL_STATUS IN VARCHAR2 DEFAULT NULL,
     x_INQ_ENTRY_STAT_ID IN NUMBER DEFAULT NULL,
     X_MODE in VARCHAR2 default 'R'  ,
     X_ORG_ID in NUMBER,
     X_INQUIRY_TYPE_ID IN NUMBER DEFAULT NULL
   ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
***************************************************************/
    CURSOR c1 is
       SELECT ROWID
       FROM igs_pe_src_types_all
       WHERE     SOURCE_TYPE_ID= X_SOURCE_TYPE_ID;

   begin
     open c1;
     fetch c1 into X_ROWID;
     if (c1%notfound) then
	close c1;
     INSERT_ROW (
       X_ROWID,
       X_SOURCE_TYPE_ID,
       X_SOURCE_TYPE,
       X_DESCRIPTION,
       X_SYSTEM_SOURCE_TYPE,
       X_ADMISSION_CAT,
       X_CLOSED_IND,
       X_PERSON_TYPE_CODE ,
       X_ENQUIRY_SOURCE_TYPE ,
       X_FUNNEL_STATUS,
       X_INQ_ENTRY_STAT_ID,
       X_MODE ,
       x_org_id,
       X_INQUIRY_TYPE_ID
     );
     return;
   end if;
   close c1;

   UPDATE_ROW (
      X_ROWID,
      X_SOURCE_TYPE_ID,
      X_SOURCE_TYPE,
      X_DESCRIPTION,
      X_SYSTEM_SOURCE_TYPE,
      X_ADMISSION_CAT,
      X_CLOSED_IND,
      X_PERSON_TYPE_CODE ,
      X_ENQUIRY_SOURCE_TYPE ,
      X_FUNNEL_STATUS,
      X_INQ_ENTRY_STAT_ID,
      X_MODE,
      X_INQUIRY_TYPE_ID
    );

   end ADD_ROW;

  procedure DELETE_ROW (
     X_ROWID in VARCHAR2
  ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
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

   delete from igs_pe_src_types_all
   where ROWID = X_ROWID;
   if (sql%notfound) then
       raise no_data_found;
   end if;

   After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
    );

  end DELETE_ROW;

END igs_pe_src_types_pkg;

/
