--------------------------------------------------------
--  DDL for Package Body IGS_EN_STDNT_PS_INTM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_STDNT_PS_INTM_PKG" AS
/* $Header: IGSEI18B.pls 120.4 2006/04/16 23:49:10 smaddali ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_EN_STDNT_PS_INTM%RowType;
  new_references IGS_EN_STDNT_PS_INTM%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_person_id IN NUMBER ,
    x_course_cd IN VARCHAR2 ,
    x_start_dt IN DATE ,
    x_logical_delete_date IN DATE,
    x_end_dt IN DATE ,
    x_voluntary_ind IN VARCHAR2 ,
    x_comments IN VARCHAR2 ,
    X_INTERMISSION_TYPE in VARCHAR2 ,
    X_APPROVED in  VARCHAR2 ,
    X_INSTITUTION_NAME  in VARCHAR2 ,
    X_MAX_CREDIT_PTS  in  NUMBER ,
    X_MAX_TERMS in   NUMBER ,
    X_ANTICIPATED_CREDIT_POINTS in  NUMBER ,
    X_APPROVER_ID  in  NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2 ,
    x_attribute11 IN VARCHAR2 ,
    x_attribute12 IN VARCHAR2 ,
    x_attribute13 IN VARCHAR2 ,
    x_attribute14 IN VARCHAR2 ,
    x_attribute15 IN VARCHAR2 ,
    x_attribute16 IN VARCHAR2 ,
    x_attribute17 IN VARCHAR2 ,
    x_attribute18 IN VARCHAR2 ,
    x_attribute19 IN VARCHAR2 ,
    x_attribute20 IN VARCHAR2 ,
    x_COND_RETURN_FLAG IN VARCHAR2
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_STDNT_PS_INTM
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
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.start_dt := x_start_dt;
    new_references.logical_delete_date := x_logical_delete_date;
    new_references.end_dt := x_end_dt;
    new_references.voluntary_ind := x_voluntary_ind;
    new_references.comments := x_comments;
   NEW_REFERENCES.INTERMISSION_TYPE :=X_INTERMISSION_TYPE ;
   NEW_REFERENCES.APPROVED := X_APPROVED;
   NEW_REFERENCES.INSTITUTION_NAME := X_INSTITUTION_NAME;
   NEW_REFERENCES.MAX_CREDIT_PTS := X_MAX_CREDIT_PTS ;
   NEW_REFERENCES.MAX_TERMS := X_MAX_TERMS;
   NEW_REFERENCES.ANTICIPATED_CREDIT_POINTS:= X_ANTICIPATED_CREDIT_POINTS ;
   NEW_REFERENCES.APPROVER_ID := X_APPROVER_ID;
   new_references.attribute_category := x_attribute_category;
   new_references.attribute1 := x_attribute1;
   new_references.attribute2 := x_attribute2;
   new_references.attribute3 := x_attribute3;
   new_references.attribute4 := x_attribute4;
   new_references.attribute5 := x_attribute5;
   new_references.attribute6 := x_attribute6;
   new_references.attribute7 := x_attribute7;
   new_references.attribute8 := x_attribute8;
   new_references.attribute9 := x_attribute9;
   new_references.attribute10 := x_attribute10;
   new_references.attribute11 := x_attribute11;
   new_references.attribute12 := x_attribute12;
   new_references.attribute13 := x_attribute13;
   new_references.attribute14 := x_attribute14;
   new_references.attribute15 := x_attribute15;
   new_references.attribute16 := x_attribute16;
   new_references.attribute17 := x_attribute17;
   new_references.attribute18 := x_attribute18;
   new_references.attribute19 := x_attribute19;
   new_references.attribute20 := x_attribute20;
   new_references.COND_RETURN_FLAG := x_COND_RETURN_FLAG;

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
  -- TRG_SCI_BR_IUD
  -- BEFORE  INSERT  OR UPDATE  OR DELETE  ON IGS_EN_STDNT_PS_INTM
  -- REFERENCING
  --  NEW AS NEW
  --  OLD AS OLD
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- If trigger has not been disabled, perform required processing
	IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_STDNT_PS_INTM') THEN
		IF p_inserting OR p_updating THEN
			-- Validate that the IGS_PS_COURSE attempt status allows p_inserting/p_updating of
			-- intermission details.
			IF IGS_EN_VAL_SCI.enrp_val_sci_alwd (
				 	new_references.person_id,
				 	new_references.course_cd,
				 	v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
			END IF;
			-- Validate for start_dt > end_dt
			IF igs_ad_val_edtl.genp_val_strt_end_dt (
					new_references.start_dt,
					new_references.end_dt,
					v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
			END IF;
		END IF;
	END IF;

  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_sci_ar_iud
  -- AFTER INSERT OR DELETE OR UPDATE
  -- ON IGS_EN_STDNT_PS_INTM
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdateDelete2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name varchar2(30);
	--v_rowid_saved	BOOLEAN := FALSE;
  BEGIN
	-- If trigger has not been disabled, perform required processing
	IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_STDNT_PS_INTM') THEN
		-- Validate for date overlaps.
		IF p_inserting OR (NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
				 NVL(new_references.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN

  		           -- Validate IGS_EN_STDNTPSHECSOP date overlaps.
  		              	IF IGS_EN_VAL_SCI.enrp_val_sci_ovrlp (
  			                                	NEW_REFERENCES.person_id,
  								NEW_REFERENCES.course_cd,
  								NEW_REFERENCES.start_dt,
  								NEW_REFERENCES.end_dt,
  								v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
  				END IF;
		END IF;
	END IF;

  --   Bug # 2829275 . UK Correspondence.Intermission business event is raised when an intermission record is created or if approved or end_date fields are changed.

   IF( p_inserting  OR ( p_updating AND ((new_references.approved <> old_references.approved AND new_references.approved = 'Y')
              OR (new_references.end_dt <> old_references.end_dt )))) THEN


       igs_en_workflow.intermission_event(
                                            p_personid	    => new_references.person_id,
					    p_program_cd    => new_references.course_cd,
					    p_intmtype	    => new_references.intermission_type,
					    p_startdt	    => new_references.start_dt,
					    p_enddt	    => new_references.end_dt ,
					    p_inst_name	    => new_references.institution_name,
					    p_max_cp	    => new_references.max_credit_pts ,
					    p_max_term	    => new_references.max_terms ,
					    p_anti_cp	    => new_references.anticipated_credit_points ,
					    p_approver	    => new_references.approver_id
                                          );
    END IF ;

  END AfterRowInsertUpdateDelete2;

  PROCEDURE AfterRowInsertUpdateDelete3(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
    CURSOR c_spi_rconds ( cp_person_id igs_en_spi_rconds.person_id%TYPE,
                          cp_course_cd igs_en_spi_rconds.course_cd%TYPE,
                          cp_start_dt igs_en_spi_rconds.start_dt%TYPE,
                          cp_logical_delete_date igs_en_spi_rconds.logical_delete_date%TYPE) IS
    SELECT rowid, rc.*
      FROM igs_en_spi_rconds rc
     WHERE rc.person_id = cp_person_id
       AND rc.course_cd =  cp_course_cd
       AND rc.start_dt = cp_start_dt
       AND rc.logical_delete_date = cp_logical_delete_date;

  BEGIN

  IF p_updating THEN
     IF old_references.logical_delete_date <> new_references.logical_delete_date THEN
        -- when the intermission record is being logically deleted, all the child return conditions
        -- should also be logically deleted.
         FOR c_spi_rconds_rec IN c_spi_rconds(old_references.person_id, old_references.course_cd,
                                old_references.start_dt, old_references.logical_delete_date) LOOP
           igs_en_spi_rconds_pkg.update_row( x_rowid               =>  c_spi_rconds_rec.rowid,
                                         x_person_id           =>   c_spi_rconds_rec.person_id,
                                         x_course_cd           =>   c_spi_rconds_rec.course_cd,
                                         x_start_dt            =>   c_spi_rconds_rec.start_dt,
                                         x_logical_delete_date => new_references.logical_delete_date,
                                         x_return_condition    => c_spi_rconds_rec.return_condition,
                                         x_status_code         => c_spi_rconds_rec.status_code,
                                         x_approved_dt         => c_spi_rconds_rec.approved_dt,
                                         x_approved_by         => c_spi_rconds_rec.approved_by,
                                         x_mode                => 'R' ) ;

         END LOOP;

     END IF;
   END IF;

  END AfterRowInsertUpdateDelete3;

procedure Check_constraints(
	column_name IN VARCHAR2 ,
	column_value IN VARCHAR2
   ) AS
begin
	IF column_name is NULL then
		NULL;
	ELSIF upper(column_name) = 'VOLUNTARY_IND' then
	  new_references.voluntary_ind := column_value;
	ELSIF upper(column_name) = 'COURSE_CD' then
	   new_references.course_cd := column_value;
	ELSIF upper(column_name) = 'APPROVED' then
	   new_references.approved := column_value;
	END IF;

	IF upper(column_name) = 'VOLUNTARY_IND' OR
	 column_name is null then
	   if new_references.voluntary_ind not IN ('Y','N') OR
	    new_references.voluntary_ind <> upper(new_references.voluntary_ind) then
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		 IGS_GE_MSG_STACK.ADD;
          	 App_Exception.Raise_Exception;
	    end if;
	end if;

    IF upper(column_name) = 'COND_RETURN_FLAG' OR
     column_name is null THEN
      IF new_references.COND_RETURN_FLAG NOT IN ('Y','N')
      AND new_references.COND_RETURN_FLAG IS NOT NULL THEN
        --
    	  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
    	  IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
    END IF;

	IF upper(column_name) = 'APPROVED' OR
	 column_name is null then
	   if new_references.approved NOT IN ('Y','N') THEN
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		 IGS_GE_MSG_STACK.ADD;
          	 App_Exception.Raise_Exception;
	    end if;
	end if;

	IF upper(column_name) = 'COURSE_CD'  OR
	 column_name is null then
	   if new_references.course_cd <> upper(new_references.course_cd) then
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		 IGS_GE_MSG_STACK.ADD;
          	 App_Exception.Raise_Exception;
	    end if;
	end if;
END check_constraints;

  PROCEDURE Check_Parent_Existance AS

      CURSOR cur_rowid_HP IS
      SELECT   rowid
      FROM     HZ_PARTIES hp
      WHERE    hp.party_id = NEW_REFERENCES.APPROVER_ID;

      CURSOR cur_exists_ioie IS
      SELECT 'X'
      FROM hz_parties hp, igs_pe_hz_parties  ihp
      WHERE hp.party_id = ihp.party_id and ihp.inst_org_ind = 'I' AND
            ihp.oi_govt_institution_cd IS NOT NULL
            AND IHP.OSS_ORG_UNIT_CD = NEW_REFERENCES.INSTITUTION_NAME
      UNION ALL
      SELECT 'X'
      FROM  igs_lookup_values lk
      WHERE lk.lookup_type = 'OR_INST_EXEMPTIONS' AND
          lk.enabled_flag = 'Y' AND
          lookup_code = NEW_REFERENCES.INSTITUTION_NAME ;

      l_exists VARCHAR2(1);

  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd
        ) Then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      end if;
    END IF;

   IF ((old_references.intermission_type =  new_references.intermission_type) OR
        (new_references.intermission_type IS NULL)) THEN
      NULL;
    ELSE
      IF  NOT IGS_EN_INTM_TYPES_PKG.Get_UK_For_Validation (
        new_references.intermission_type
        ) Then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      end if;
    END IF;

    IF ((old_references.APPROVER_ID = new_references.APPROVER_ID) OR
        (new_references.APPROVER_ID IS NULL)) THEN
      NULL;
    ELSE
         Open cur_rowid_HP;
         Fetch cur_rowid_HP INTO l_rowid;
         IF (cur_rowid_HP%FOUND) THEN
            Close cur_rowid_HP;
         ELSE
            Close cur_rowid_HP;
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
         END IF;
    END IF;

    IF ((old_references.INSTITUTION_NAME =  new_references.INSTITUTION_NAME) OR
        (new_references.INSTITUTION_NAME IS NULL)) THEN
      NULL;
    ELSE
         Open cur_exists_ioie;
         Fetch cur_exists_ioie INTO l_exists;
         IF (cur_exists_ioie%FOUND) THEN
            Close cur_exists_ioie;
         ELSE
            Close cur_exists_ioie;
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
         END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_start_dt IN DATE,
    x_logical_delete_date IN DATE
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_STDNT_PS_INTM
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      start_dt = x_start_dt
      AND      logical_delete_date = x_logical_delete_date
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	 Close cur_rowid;
	 return(TRUE);
    else
     Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;


  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_STDNT_PS_INTM
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCI_SCA_FK');
IGS_GE_MSG_STACK.ADD;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_STDNT_PS_ATT;

       PROCEDURE Check_Child_Existance AS
     /*
       ||  Created By : Susmitha Tutta
       ||  Created On : 20-Mar-2006
       ||  Purpose : Checking for child existance
       ||  Known limitations, enhancements or remarks :
       ||  Change History :
       ||  Who             When            What
       ||  (reverse chronological order - newest change first)
       */
       BEGIN
         IGS_EN_SPI_RCONDS_PKG.get_fk_igs_en_stdnt_ps_intm(
             old_references.person_id,
             old_references.course_cd,
             old_references.start_dt,
     	old_references.logical_delete_date
          );
       END Check_Child_Existance;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 ,
    x_person_id IN NUMBER ,
    x_course_cd IN VARCHAR2 ,
    x_start_dt IN DATE ,
    x_logical_delete_date IN DATE,
    x_end_dt IN DATE ,
    x_voluntary_ind IN VARCHAR2 ,
    x_comments IN VARCHAR2 ,
    X_INTERMISSION_TYPE in VARCHAR2 ,
    X_APPROVED in  VARCHAR2 ,
    X_INSTITUTION_NAME  in VARCHAR2 ,
    X_MAX_CREDIT_PTS  in  NUMBER ,
    X_MAX_TERMS in   NUMBER ,
    X_ANTICIPATED_CREDIT_POINTS in  NUMBER ,
    X_APPROVER_ID  in  NUMBER ,
    x_creation_date IN DATE  ,
    x_created_by IN NUMBER  ,
    x_last_update_date IN DATE  ,
    x_last_updated_by IN NUMBER  ,
    x_last_update_login IN NUMBER  ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2 ,
    x_attribute11 IN VARCHAR2 ,
    x_attribute12 IN VARCHAR2 ,
    x_attribute13 IN VARCHAR2 ,
    x_attribute14 IN VARCHAR2 ,
    x_attribute15 IN VARCHAR2 ,
    x_attribute16 IN VARCHAR2 ,
    x_attribute17 IN VARCHAR2 ,
    x_attribute18 IN VARCHAR2 ,
    x_attribute19 IN VARCHAR2 ,
    x_attribute20 IN VARCHAR2 ,
    x_COND_RETURN_FLAG IN VARCHAR2
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_start_dt,
      x_logical_delete_date,
      x_end_dt,
      x_voluntary_ind,
      x_comments,
      X_INTERMISSION_TYPE,
      X_APPROVED,
      X_INSTITUTION_NAME,
      X_MAX_CREDIT_PTS ,
      X_MAX_TERMS,
      X_ANTICIPATED_CREDIT_POINTS,
      X_APPROVER_ID,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1,
      X_ATTRIBUTE2,
      X_ATTRIBUTE3,
      X_ATTRIBUTE4,
      X_ATTRIBUTE5,
      X_ATTRIBUTE6,
      X_ATTRIBUTE7,
      X_ATTRIBUTE8,
      X_ATTRIBUTE9,
      X_ATTRIBUTE10,
      X_ATTRIBUTE11,
      X_ATTRIBUTE12,
      X_ATTRIBUTE13,
      X_ATTRIBUTE14,
      X_ATTRIBUTE15,
      X_ATTRIBUTE16,
      X_ATTRIBUTE17,
      X_ATTRIBUTE18,
      X_ATTRIBUTE19,
      X_ATTRIBUTE20,
      x_COND_RETURN_FLAG
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,
                               p_updating  => FALSE,
			       p_deleting  => FALSE);

     IF	Get_PK_For_Validation (
	    new_references.person_id  ,
	    new_references.course_cd ,
	    new_references.start_dt,
	    new_references.logical_delete_date
     	) THEN
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     end if;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
				     p_updating => TRUE,
        			     p_deleting  => FALSE
				   );
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      check_child_existance;
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
				     p_updating  => FALSE,
				     p_deleting => TRUE
				   );
   ELSIF (p_action = 'VALIDATE_INSERT') then
	 IF	Get_PK_For_Validation (
	    new_references.person_id,
	    new_references.course_cd,
	    new_references.start_dt,
	    new_references.logical_delete_date
     	) THEN
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     end if;
      Check_constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_constraints;
   ELSIF (p_action = 'VALIDATE_DELETE') THEN
	    check_child_existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdateDelete2 ( p_inserting => TRUE,
				    p_updating  => FALSE,
			            p_deleting  => FALSE
				  );

     -- AfterStmtInsertUpdateDelete3 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN

      -- Call all the procedures related to After Update.
      AfterRowInsertUpdateDelete2 (  p_inserting => FALSE,
				     p_updating => TRUE,
        			     p_deleting  => FALSE
				  );

     AfterRowInsertUpdateDelete3 (  p_inserting => FALSE,
                                    p_updating => TRUE,
                                    p_deleting  => FALSE
                                  );


     -- AfterStmtInsertUpdateDelete3 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowInsertUpdateDelete2 (  p_inserting => FALSE,
				     p_updating  => FALSE,
				     p_deleting => TRUE
    				  );
     -- AfterStmtInsertUpdateDelete3 ( p_deleting => TRUE );
    END IF;

  END After_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_START_DT in DATE,
  X_LOGICAL_DELETE_DATE in DATE,
  X_END_DT in DATE,
  X_VOLUNTARY_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_INTERMISSION_TYPE in VARCHAR2 ,
  X_APPROVED in  VARCHAR2 ,
  X_INSTITUTION_NAME  in VARCHAR2 ,
  X_MAX_CREDIT_PTS  in  NUMBER ,
  X_MAX_TERMS in   NUMBER ,
  X_ANTICIPATED_CREDIT_POINTS in  NUMBER ,
  X_APPROVER_ID  in  NUMBER ,
  X_MODE in VARCHAR2 ,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2 ,
  x_COND_RETURN_FLAG IN VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_EN_STDNT_PS_INTM
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and START_DT = X_START_DT
      and LOGICAL_DELETE_DATE = X_LOGICAL_DELETE_DATE;
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

Before_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID,
  x_person_id => X_PERSON_ID,
  x_course_cd => X_COURSE_CD,
  x_start_dt => X_START_DT,
  x_logical_delete_date => X_LOGICAL_DELETE_DATE,
  x_end_dt => X_END_DT,
  x_voluntary_ind => X_VOLUNTARY_IND,
  x_comments => X_COMMENTS,
  X_INTERMISSION_TYPE =>X_INTERMISSION_TYPE,
  X_APPROVED =>X_APPROVED,
  X_INSTITUTION_NAME => X_INSTITUTION_NAME,
  X_MAX_CREDIT_PTS => X_MAX_CREDIT_PTS,
  X_MAX_TERMS => X_MAX_TERMS,
  X_ANTICIPATED_CREDIT_POINTS => X_ANTICIPATED_CREDIT_POINTS,
  X_APPROVER_ID => X_APPROVER_ID,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_attribute_category=>X_ATTRIBUTE_CATEGORY,
  x_attribute1=>X_ATTRIBUTE1,
  x_attribute2=>X_ATTRIBUTE2,
  x_attribute3=>X_ATTRIBUTE3,
  x_attribute4=>X_ATTRIBUTE4,
  x_attribute5=>X_ATTRIBUTE5,
  x_attribute6=>X_ATTRIBUTE6,
  x_attribute7=>X_ATTRIBUTE7,
  x_attribute8=>X_ATTRIBUTE8,
  x_attribute9=>X_ATTRIBUTE9,
  x_attribute10=>X_ATTRIBUTE10,
  x_attribute11=>X_ATTRIBUTE11,
  x_attribute12=>X_ATTRIBUTE12,
  x_attribute13=>X_ATTRIBUTE13,
  x_attribute14=>X_ATTRIBUTE14,
  x_attribute15=>X_ATTRIBUTE15,
  x_attribute16=>X_ATTRIBUTE16,
  x_attribute17=>X_ATTRIBUTE17,
  x_attribute18=>X_ATTRIBUTE18,
  x_attribute19=>X_ATTRIBUTE19,
  x_attribute20=>X_ATTRIBUTE20,
  x_COND_RETURN_FLAG => x_COND_RETURN_FLAG
);

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_EN_STDNT_PS_INTM (
    PERSON_ID,
    COURSE_CD,
    START_DT,
    LOGICAL_DELETE_DATE,
    END_DT,
    VOLUNTARY_IND,
    COMMENTS,
    INTERMISSION_TYPE ,
    APPROVED ,
    INSTITUTION_NAME,
    MAX_CREDIT_PTS  ,
    MAX_TERMS ,
    ANTICIPATED_CREDIT_POINTS ,
    APPROVER_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    COND_RETURN_FLAG
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.LOGICAL_DELETE_DATE,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.VOLUNTARY_IND,
    NEW_REFERENCES.COMMENTS,
    NEW_REFERENCES.INTERMISSION_TYPE ,
    NEW_REFERENCES.APPROVED ,
    NEW_REFERENCES.INSTITUTION_NAME,
    NEW_REFERENCES.MAX_CREDIT_PTS  ,
    NEW_REFERENCES.MAX_TERMS ,
    NEW_REFERENCES.ANTICIPATED_CREDIT_POINTS ,
    NEW_REFERENCES.APPROVER_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    NEW_REFERENCES.ATTRIBUTE1,
    NEW_REFERENCES.ATTRIBUTE2,
    NEW_REFERENCES.ATTRIBUTE3,
    NEW_REFERENCES.ATTRIBUTE4,
    NEW_REFERENCES.ATTRIBUTE5,
    NEW_REFERENCES.ATTRIBUTE6,
    NEW_REFERENCES.ATTRIBUTE7,
    NEW_REFERENCES.ATTRIBUTE8,
    NEW_REFERENCES.ATTRIBUTE9,
    NEW_REFERENCES.ATTRIBUTE10,
    NEW_REFERENCES.ATTRIBUTE11,
    NEW_REFERENCES.ATTRIBUTE12,
    NEW_REFERENCES.ATTRIBUTE13,
    NEW_REFERENCES.ATTRIBUTE14,
    NEW_REFERENCES.ATTRIBUTE15,
    NEW_REFERENCES.ATTRIBUTE16,
    NEW_REFERENCES.ATTRIBUTE17,
    NEW_REFERENCES.ATTRIBUTE18,
    NEW_REFERENCES.ATTRIBUTE19,
    NEW_REFERENCES.ATTRIBUTE20,
    NEW_REFERENCES.COND_RETURN_FLAG
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

After_DML(
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
  X_COURSE_CD in VARCHAR2,
  X_START_DT in DATE,
  X_LOGICAL_DELETE_DATE in DATE,
  X_END_DT in DATE,
  X_VOLUNTARY_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
   X_INTERMISSION_TYPE in VARCHAR2 ,
  X_APPROVED in  VARCHAR2 ,
  X_INSTITUTION_NAME  in VARCHAR2 ,
  X_MAX_CREDIT_PTS  in  NUMBER ,
  X_MAX_TERMS in   NUMBER ,
  X_ANTICIPATED_CREDIT_POINTS in  NUMBER ,
  X_APPROVER_ID  in  NUMBER ,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2 ,
  X_COND_RETURN_FLAG IN VARCHAR2
)AS
  cursor c1 is select
      LOGICAL_DELETE_DATE,
      END_DT,
      VOLUNTARY_IND,
      COMMENTS,
      INTERMISSION_TYPE,
      APPROVED,
      INSTITUTION_NAME,
      MAX_CREDIT_PTS,
      MAX_TERMS,
      ANTICIPATED_CREDIT_POINTS,
      APPROVER_ID,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     ATTRIBUTE16,
     ATTRIBUTE17,
     ATTRIBUTE18,
     ATTRIBUTE19,
     ATTRIBUTE20,
     COND_RETURN_FLAG
    from IGS_EN_STDNT_PS_INTM
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.LOGICAL_DELETE_DATE = X_LOGICAL_DELETE_DATE)
      AND (tlinfo.END_DT = X_END_DT)
      AND (tlinfo.VOLUNTARY_IND = X_VOLUNTARY_IND)
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
      AND ((tlinfo.INTERMISSION_TYPE = X_INTERMISSION_TYPE)
           OR ((tlinfo.INTERMISSION_TYPE is null)
               AND (X_INTERMISSION_TYPE is null)))
	AND ((tlinfo.APPROVED = X_APPROVED)
           OR ((tlinfo.APPROVED is null)
               AND (X_APPROVED is null)))
	AND ((tlinfo.INSTITUTION_NAME = X_INSTITUTION_NAME)
           OR ((tlinfo.INSTITUTION_NAME is null)
               AND (X_INSTITUTION_NAME is null)))
	AND ((tlinfo.MAX_CREDIT_PTS = X_MAX_CREDIT_PTS)
           OR ((tlinfo.MAX_CREDIT_PTS is null)
               AND (X_MAX_CREDIT_PTS is null)))
	AND ((tlinfo.MAX_TERMS = X_MAX_TERMS)
           OR ((tlinfo.MAX_TERMS is null)
               AND (X_MAX_TERMS is null)))
	AND ((tlinfo.ANTICIPATED_CREDIT_POINTS = X_ANTICIPATED_CREDIT_POINTS)
           OR ((tlinfo.ANTICIPATED_CREDIT_POINTS is null)
               AND (X_ANTICIPATED_CREDIT_POINTS is null)))
	AND ((tlinfo.APPROVER_ID = X_APPROVER_ID)
           OR ((tlinfo.APPROVER_ID is null)
               AND (X_APPROVER_ID is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY IS NULL)
               AND (X_ATTRIBUTE_CATEGORY IS NULL)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 IS NULL)
               AND (X_ATTRIBUTE1 IS NULL)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 IS NULL)
               AND (X_ATTRIBUTE2 IS NULL)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 IS NULL)
               AND (X_ATTRIBUTE3 IS NULL)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 IS NULL)
               AND (X_ATTRIBUTE4 IS NULL)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 IS NULL)
               AND (X_ATTRIBUTE5 IS NULL)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 IS NULL)
               AND (X_ATTRIBUTE6 IS NULL)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 IS NULL)
               AND (X_ATTRIBUTE7 IS NULL)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 IS NULL)
               AND (X_ATTRIBUTE8 IS NULL)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 IS NULL)
               AND (X_ATTRIBUTE9 IS NULL)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 IS NULL)
               AND (X_ATTRIBUTE10 IS NULL)))
      AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 IS NULL)
               AND (X_ATTRIBUTE11 IS NULL)))
      AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 IS NULL)
               AND (X_ATTRIBUTE12 IS NULL)))
      AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 IS NULL)
               AND (X_ATTRIBUTE13 IS NULL)))
      AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 IS NULL)
               AND (X_ATTRIBUTE14 IS NULL)))
      AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 IS NULL)
               AND (X_ATTRIBUTE15 IS NULL)))
      AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((tlinfo.ATTRIBUTE16 IS NULL)
               AND (X_ATTRIBUTE16 IS NULL)))
      AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR ((tlinfo.ATTRIBUTE17 IS NULL)
               AND (X_ATTRIBUTE17 IS NULL)))
      AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR ((tlinfo.ATTRIBUTE18 IS NULL)
               AND (X_ATTRIBUTE18 IS NULL)))
      AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR ((tlinfo.ATTRIBUTE19 IS NULL)
               AND (X_ATTRIBUTE19 IS NULL)))
      AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
           OR ((tlinfo.ATTRIBUTE20 IS NULL)
               AND (X_ATTRIBUTE20 IS NULL)))
      AND (tlinfo.COND_RETURN_FLAG = X_COND_RETURN_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_START_DT in DATE,
  X_LOGICAL_DELETE_DATE in DATE,
  X_END_DT in DATE,
  X_VOLUNTARY_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
   X_INTERMISSION_TYPE in VARCHAR2 ,
  X_APPROVED in  VARCHAR2 ,
  X_INSTITUTION_NAME  in VARCHAR2 ,
  X_MAX_CREDIT_PTS  in  NUMBER ,
  X_MAX_TERMS in   NUMBER ,
  X_ANTICIPATED_CREDIT_POINTS in  NUMBER ,
  X_APPROVER_ID  in  NUMBER ,
  X_MODE in VARCHAR2 ,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2 ,
  X_COND_RETURN_FLAG IN VARCHAR2
  ) AS
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

Before_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID,
  x_person_id => X_PERSON_ID,
  x_course_cd => X_COURSE_CD,
  x_start_dt => X_START_DT,
  x_logical_delete_date =>  X_LOGICAL_DELETE_DATE,
  x_end_dt => X_END_DT,
  x_voluntary_ind => X_VOLUNTARY_IND,
  x_comments => X_COMMENTS,
    X_INTERMISSION_TYPE =>X_INTERMISSION_TYPE,
  X_APPROVED =>X_APPROVED,
  X_INSTITUTION_NAME => X_INSTITUTION_NAME,
  X_MAX_CREDIT_PTS => X_MAX_CREDIT_PTS,
  X_MAX_TERMS => X_MAX_TERMS,
  X_ANTICIPATED_CREDIT_POINTS => X_ANTICIPATED_CREDIT_POINTS,
  X_APPROVER_ID => X_APPROVER_ID,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_attribute_category=>X_ATTRIBUTE_CATEGORY,
  x_attribute1=>X_ATTRIBUTE1,
  x_attribute2=>X_ATTRIBUTE2,
  x_attribute3=>X_ATTRIBUTE3,
  x_attribute4=>X_ATTRIBUTE4,
  x_attribute5=>X_ATTRIBUTE5,
  x_attribute6=>X_ATTRIBUTE6,
  x_attribute7=>X_ATTRIBUTE7,
  x_attribute8=>X_ATTRIBUTE8,
  x_attribute9=>X_ATTRIBUTE9,
  x_attribute10=>X_ATTRIBUTE10,
  x_attribute11=>X_ATTRIBUTE11,
  x_attribute12=>X_ATTRIBUTE12,
  x_attribute13=>X_ATTRIBUTE13,
  x_attribute14=>X_ATTRIBUTE14,
  x_attribute15=>X_ATTRIBUTE15,
  x_attribute16=>X_ATTRIBUTE16,
  x_attribute17=>X_ATTRIBUTE17,
  x_attribute18=>X_ATTRIBUTE18,
  x_attribute19=>X_ATTRIBUTE19,
  x_attribute20=>X_ATTRIBUTE20,
  X_COND_RETURN_FLAG => X_COND_RETURN_FLAG
);

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_EN_STDNT_PS_INTM set
    LOGICAL_DELETE_DATE = NEW_REFERENCES.LOGICAL_DELETE_DATE,
    END_DT = NEW_REFERENCES.END_DT,
    VOLUNTARY_IND = NEW_REFERENCES.VOLUNTARY_IND,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    INTERMISSION_TYPE = NEW_REFERENCES.INTERMISSION_TYPE,
    APPROVED = NEW_REFERENCES.APPROVED,
    INSTITUTION_NAME= NEW_REFERENCES.INSTITUTION_NAME,
    MAX_CREDIT_PTS = NEW_REFERENCES.MAX_CREDIT_PTS ,
    MAX_TERMS = NEW_REFERENCES.MAX_TERMS,
    ANTICIPATED_CREDIT_POINTS = NEW_REFERENCES.ANTICIPATED_CREDIT_POINTS,
    APPROVER_ID= NEW_REFERENCES.APPROVER_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY =  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 =  NEW_REFERENCES.ATTRIBUTE1,
    ATTRIBUTE2 =  NEW_REFERENCES.ATTRIBUTE2,
    ATTRIBUTE3 =  NEW_REFERENCES.ATTRIBUTE3,
    ATTRIBUTE4 =  NEW_REFERENCES.ATTRIBUTE4,
    ATTRIBUTE5 =  NEW_REFERENCES.ATTRIBUTE5,
    ATTRIBUTE6 =  NEW_REFERENCES.ATTRIBUTE6,
    ATTRIBUTE7 =  NEW_REFERENCES.ATTRIBUTE7,
    ATTRIBUTE8 =  NEW_REFERENCES.ATTRIBUTE8,
    ATTRIBUTE9 =  NEW_REFERENCES.ATTRIBUTE9,
    ATTRIBUTE10 =  NEW_REFERENCES.ATTRIBUTE10,
    ATTRIBUTE11 =  NEW_REFERENCES.ATTRIBUTE11,
    ATTRIBUTE12 =  NEW_REFERENCES.ATTRIBUTE12,
    ATTRIBUTE13 =  NEW_REFERENCES.ATTRIBUTE13,
    ATTRIBUTE14 =  NEW_REFERENCES.ATTRIBUTE14,
    ATTRIBUTE15 =  NEW_REFERENCES.ATTRIBUTE15,
    ATTRIBUTE16 =  NEW_REFERENCES.ATTRIBUTE16,
    ATTRIBUTE17 =  NEW_REFERENCES.ATTRIBUTE17,
    ATTRIBUTE18 =  NEW_REFERENCES.ATTRIBUTE18,
    ATTRIBUTE19 =  NEW_REFERENCES.ATTRIBUTE19,
    ATTRIBUTE20 =  NEW_REFERENCES.ATTRIBUTE20,
    COND_RETURN_FLAG = NEW_REFERENCES.COND_RETURN_FLAG
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



After_DML(
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
  X_COURSE_CD in VARCHAR2,
  X_START_DT in DATE,
  X_LOGICAL_DELETE_DATE in DATE,
  X_END_DT in DATE,
  X_VOLUNTARY_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
   X_INTERMISSION_TYPE in VARCHAR2 ,
  X_APPROVED in  VARCHAR2 ,
  X_INSTITUTION_NAME  in VARCHAR2 ,
  X_MAX_CREDIT_PTS  in  NUMBER ,
  X_MAX_TERMS in   NUMBER ,
  X_ANTICIPATED_CREDIT_POINTS in  NUMBER ,
  X_APPROVER_ID  in  NUMBER ,
  X_MODE in VARCHAR2 ,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2 ,
  X_COND_RETURN_FLAG IN VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_EN_STDNT_PS_INTM
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and START_DT = X_START_DT
     and LOGICAL_DELETE_DATE = X_LOGICAL_DELETE_DATE
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_START_DT,
     X_LOGICAL_DELETE_DATE,
     X_END_DT,
     X_VOLUNTARY_IND,
     X_COMMENTS,
     X_INTERMISSION_TYPE,
     X_APPROVED,
     X_INSTITUTION_NAME,
     X_MAX_CREDIT_PTS,
     X_MAX_TERMS,
     X_ANTICIPATED_CREDIT_POINTS,
     X_APPROVER_ID,
     X_MODE,
     X_ATTRIBUTE_CATEGORY,
     X_ATTRIBUTE1,
     X_ATTRIBUTE2,
     X_ATTRIBUTE3,
     X_ATTRIBUTE4,
     X_ATTRIBUTE5,
     X_ATTRIBUTE6,
     X_ATTRIBUTE7,
     X_ATTRIBUTE8,
     X_ATTRIBUTE9,
     X_ATTRIBUTE10,
     X_ATTRIBUTE11,
     X_ATTRIBUTE12,
     X_ATTRIBUTE13,
     X_ATTRIBUTE14,
     X_ATTRIBUTE15,
     X_ATTRIBUTE16,
     X_ATTRIBUTE17,
     X_ATTRIBUTE18,
     X_ATTRIBUTE19,
     X_ATTRIBUTE20,
     X_COND_RETURN_FLAG
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_START_DT,
   X_LOGICAL_DELETE_DATE,
   X_END_DT,
   X_VOLUNTARY_IND,
   X_COMMENTS,
   X_INTERMISSION_TYPE,
   X_APPROVED,
   X_INSTITUTION_NAME,
   X_MAX_CREDIT_PTS,
   X_MAX_TERMS,
   X_ANTICIPATED_CREDIT_POINTS,
   X_APPROVER_ID,
   X_MODE,
   X_ATTRIBUTE_CATEGORY,
   X_ATTRIBUTE1,
   X_ATTRIBUTE2,
   X_ATTRIBUTE3,
   X_ATTRIBUTE4,
   X_ATTRIBUTE5,
   X_ATTRIBUTE6,
   X_ATTRIBUTE7,
   X_ATTRIBUTE8,
   X_ATTRIBUTE9,
   X_ATTRIBUTE10,
   X_ATTRIBUTE11,
   X_ATTRIBUTE12,
   X_ATTRIBUTE13,
   X_ATTRIBUTE14,
   X_ATTRIBUTE15,
   X_ATTRIBUTE16,
   X_ATTRIBUTE17,
   X_ATTRIBUTE18,
   X_ATTRIBUTE19,
   X_ATTRIBUTE20,
   X_COND_RETURN_FLAG
   );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
begin

Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
);

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_EN_STDNT_PS_INTM
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



After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
);


end DELETE_ROW;

end IGS_EN_STDNT_PS_INTM_PKG;

/
