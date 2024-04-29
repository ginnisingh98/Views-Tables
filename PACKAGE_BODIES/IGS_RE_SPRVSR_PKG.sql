--------------------------------------------------------
--  DDL for Package Body IGS_RE_SPRVSR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_SPRVSR_PKG" as
/* $Header: IGSRI13B.pls 120.1 2005/07/04 00:42:01 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_re_val_rsup.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_RE_SPRVSR%RowType;
  new_references IGS_RE_SPRVSR%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_ca_person_id IN NUMBER ,
    x_ca_sequence_number IN NUMBER ,
    x_person_id IN NUMBER ,
    x_sequence_number IN NUMBER ,
    x_start_dt IN DATE ,
    x_end_dt IN DATE ,
    x_research_supervisor_type IN VARCHAR2 ,
    x_supervisor_profession IN VARCHAR2 ,
    x_supervision_percentage IN NUMBER ,
    x_funding_percentage IN NUMBER ,
    x_org_unit_cd IN VARCHAR2 ,
    x_ou_start_dt IN DATE ,
    x_replaced_person_id IN NUMBER ,
    x_replaced_sequence_number IN NUMBER ,
    x_comments IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_SPRVSR
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
    new_references.ca_person_id := x_ca_person_id;
    new_references.ca_sequence_number := x_ca_sequence_number;
    new_references.person_id := x_person_id;
    new_references.sequence_number := x_sequence_number;
    new_references.start_dt := x_start_dt;
    new_references.end_dt := x_end_dt;
    new_references.research_supervisor_type := x_research_supervisor_type;
    new_references.supervisor_profession := x_supervisor_profession;
    new_references.supervision_percentage := x_supervision_percentage;
    new_references.funding_percentage := x_funding_percentage;
    new_references.org_unit_cd := x_org_unit_cd;
    new_references.ou_start_dt := x_ou_start_dt;
    new_references.replaced_person_id := x_replaced_person_id;
    new_references.replaced_sequence_number := x_replaced_sequence_number;
    new_references.comments := x_comments;
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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name		VARCHAR2(30);
	p_legacy VARCHAR2(1);
  BEGIN
       	p_legacy := 'N';

	-- Turn off trigger validation when performing insert of IGS_RE_CANDIDATURE details
	-- as a result of IGS_PS_COURSE transfer
	IF igs_as_val_suaap.genp_val_sdtt_sess('ENRP_INS_CA_TRNSFR') THEN
		IF p_inserting OR
			(p_updating AND
			(new_references.start_dt <> old_references.start_dt) OR
			(NVL(new_references.end_dt,igs_ge_date.igsdate('9999/01/01')) <>
			NVL(old_references.end_dt,igs_ge_date.igsdate('9999/01/01'))) OR
			(NVL(new_references.supervision_percentage,-1) <>
			NVL(old_references.supervision_percentage,-1)) OR
			(new_references.research_supervisor_type <>
			old_references.research_supervisor_type) OR
			(NVL(new_references.funding_percentage,-1) <>
			NVL(old_references.funding_percentage,-1)) OR
			(NVL(new_references.org_unit_cd,'NULL') <>
			NVL(old_references.org_unit_cd,'NULL')) OR
			(NVL(new_references.replaced_person_id,-1) <>
			NVL(old_references.replaced_person_id,-1))) THEN
			-- Validate changes are allowed to be made
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Changed the reference of "IGS_RE_VAL_RSUP.RESP_VAL_CA_CHILDUPD" to program unit "IGS_RE_VAL_CAH.RESP_VAL_CA_CHILDUPD". -- kdande
*/
			IF IGS_RE_VAL_CAH.resp_val_ca_childupd(
				new_references.ca_person_id,
				new_references.ca_sequence_number,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name ('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
			END IF;
		END IF;
		IF p_inserting THEN
			-- Validate IGS_PE_PERSON
			IF IGS_RE_VAL_RSUP.resp_val_rsup_person(
				new_references.ca_person_id,
				new_references.person_id,
				p_legacy,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name ('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
			END IF;
		END IF;
		IF p_inserting OR
			p_updating THEN
			-- Validate that research supervisor type
			IF p_inserting OR
				(p_updating AND
				new_references.research_supervisor_type <> old_references.research_supervisor_type) THEN
				IF IGS_RE_VAL_RSUP.resp_val_rst_closed (
					new_references.research_supervisor_type,
					v_message_name) = FALSE THEN
					Fnd_Message.Set_Name ('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
				END IF;
			END IF;
			-- Validate funding percentage
			IF p_inserting OR
				(p_updating AND
				((NVL(new_references.funding_percentage,-1) <> NVL(old_references.funding_percentage,-1)) OR
				new_references.org_unit_cd IS NULL)) THEN
/*
				IF IGS_RE_VAL_RSUP.resp_val_rsup_fund(
					new_references.person_id,
					new_references.org_unit_cd,
					new_references.ou_start_dt,
					new_references.funding_percentage,
					NULL, -- staff member indicator
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name ('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;

				END IF;
*/
			-- This code has been commented because the validation has
			-- been taken care at the library at the event ON_COMMIT.
			NULL;
			END IF;

			-- Validate Organisational IGS_PS_UNIT
			IF new_references.org_unit_cd IS NOT NULL THEN
				IF p_inserting OR
					(p_updating AND
					NVL(new_references.funding_percentage,-1) = NVL(old_references.funding_percentage,-1) AND
					((NVL(new_references.org_unit_cd,'NULL') <> NVL(old_references.org_unit_cd,'NULL')) OR
					(NVL(new_references.ou_start_dt,igs_ge_date.igsdate('9999/01/01')) <>
					NVL(old_references.ou_start_dt,igs_ge_date.igsdate('9999/01/01'))))) THEN

					IF IGS_RE_VAL_RSUP.resp_val_rsup_ou(
						new_references.person_id,
						new_references.org_unit_cd,
						new_references.ou_start_dt,
						NULL, -- staff member indicator
						p_legacy,
						v_message_name) = FALSE THEN
							Fnd_Message.Set_Name ('IGS', v_message_name);
							IGS_GE_MSG_STACK.ADD;
							App_Exception.Raise_Exception;
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
	IF p_deleting THEN
		-- Validate deletes are allowed
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Changed the reference of "IGS_RE_VAL_RSUP.RESP_VAL_CA_CHILDUPD" to program unit "IGS_RE_VAL_CAH.RESP_VAL_CA_CHILDUPD". -- kdande
*/
		IF IGS_RE_VAL_CAH.resp_val_ca_childupd(
			old_references.ca_person_id,
			old_references.ca_sequence_number,
			v_message_name) = FALSE THEN
				Fnd_Message.Set_Name ('IGS', v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name				VARCHAR2(30);
	v_supervision_start_dt			DATE;
        p_legacy VARCHAR2(1);
  BEGIN
        p_legacy  := 'N';

	-- Turn off trigger validation when performing insert of IGS_RE_CANDIDATURE details
	-- as a result of IGS_PS_COURSE transfer
	IF igs_as_val_suaap.genp_val_sdtt_sess('ENRP_INS_CA_TRNSFR') THEN
		IF p_inserting OR
			p_updating THEN
			-- Set rowid


			--Validate research supervisor end date
  			IF (NVL( NEW_REFERENCES.end_dt,igs_ge_date.igsdate('9999/01/01')) <>
  			NVL(OLD_REFERENCES.end_dt,igs_ge_date.igsdate('9999/01/01')))
  			THEN
  				IF IGS_RE_VAL_RSUP.resp_val_rsup_end_dt(
	  				NEW_REFERENCES.ca_person_id,
  					NEW_REFERENCES.ca_sequence_number,
  					NEW_REFERENCES.person_id,
  					NEW_REFERENCES.sequence_number,
  					NEW_REFERENCES.start_dt,
	  				NEW_REFERENCES.end_dt,
					p_legacy,
  					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name ('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
  				END IF;
  			END IF;

  			-- Validate research supervisor overlapping periods
  			IF p_inserting OR
  				(p_updating AND
  				(NEW_REFERENCES.start_dt  <> OLD_REFERENCES.start_dt) OR
  				(NVL(NEW_REFERENCES.end_dt,igs_ge_date.igsdate('9999/01/01')) <>
  		NVL(OLD_REFERENCES.end_dt,igs_ge_date.igsdate('9999/01/01'))))
  			THEN
  				IF IGS_RE_VAL_RSUP.resp_val_rsup_ovrlp(
  				NEW_REFERENCES.ca_person_id,
  					NEW_REFERENCES.ca_sequence_number,
  					NEW_REFERENCES.person_id,
  					NEW_REFERENCES.sequence_number,
  					NEW_REFERENCES.start_dt,
  					NEW_REFERENCES.end_dt,
					p_legacy,
  					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name ('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
  				END IF;
  			END IF;

  			-- Validate replaced supervisor
  			IF NEW_REFERENCES.replaced_person_id IS NOT NULL THEN
  				IF p_inserting OR
  					(p_updating AND
  					(NEW_REFERENCES.replaced_person_id <>
  					NVL(OLD_REFERENCES.replaced_person_id,0)) OR
  					(NEW_REFERENCES.replaced_sequence_number <>
  					NVL(OLD_REFERENCES.replaced_sequence_number,0)) OR
  					(NEW_REFERENCES.start_dt <> OLD_REFERENCES.start_dt)) THEN
  					IF IGS_RE_VAL_RSUP.resp_val_rsup_repl(
  						NEW_REFERENCES.ca_person_id,
  						NEW_REFERENCES.ca_sequence_number,
  						NEW_REFERENCES.person_id,
  						NEW_REFERENCES.start_dt,
  						NEW_REFERENCES.replaced_person_id,
  						NEW_REFERENCES.replaced_sequence_number,
						p_legacy,
  						v_message_name) = FALSE THEN
							Fnd_Message.Set_Name ('IGS', v_message_name);
							IGS_GE_MSG_STACK.ADD;
							App_Exception.Raise_Exception;
  					END IF;
  				END IF;
  			END IF;

  			-- Do not validate at database level  if being updated via form RESF3250
  			IF igs_as_val_suaap.genp_val_sdtt_sess('RESP_VAL_RSUP_PERC') THEN
  			     -- Validate supervision and funding percentage
  			     IF p_inserting OR
  				(p_updating AND
  				(NEW_REFERENCES.start_dt <> OLD_REFERENCES.start_dt) OR
  				(NVL(NEW_REFERENCES.end_dt,igs_ge_date.igsdate('9999/01/01')) <>
  				NVL(OLD_REFERENCES.end_dt,
  					igs_ge_date.igsdate('9999/01/01'))) OR
  				(NVL(NEW_REFERENCES.supervision_percentage,-1) <>
  				NVL(OLD_REFERENCES.supervision_percentage,-1)) OR
  				(NVL(NEW_REFERENCES.funding_percentage,-1) <>
  				NVL(OLD_REFERENCES.funding_percentage,-1))) THEN
/*
  				IF IGS_RE_VAL_RSUP.resp_val_rsup_perc(
  					NEW_REFERENCES.ca_person_id,
  					NEW_REFERENCES.ca_sequence_number,
  					NULL, -- sca_course_cd
  					NULL, -- acai_admission_appl_number
  					NULL, -- acai_nominated_course_cd
  					NULL, -- acai_sequence_number,
  					'Y', -- Validate supervision percentage
  					'Y', -- Validate funding percentage
  					'RSUP',
  					V_supervision_start_dt,
  					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name ('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
  				END IF;
*/
				NULL;
		-- This code has been commented out NOCOPY because the validations have
		-- been taken care at the library.
  			    END IF;
  			END IF;
		END IF;
	END IF;


 		IF p_deleting THEN
  			-- Do not validate at database level  if being updated via form RESF3250
  			IF igs_as_val_suaap.genp_val_sdtt_sess('RESP_VAL_RSUP_PERC') THEN
  				-- Validate supervision and funding percentage
/*
  				IF IGS_RE_VAL_RSUP.resp_val_rsup_perc(
  					OLD_REFERENCES.ca_person_id,
  					OLD_REFERENCES.ca_sequence_number,
  					NULL, -- sca_course_cd
  					NULL, -- acai_admission_appl_number
  					NULL, -- acai_nominated_course_cd
  					NULL, -- acai_sequence_number,
  					'Y', -- Validate supervision percentage
  					'Y', -- Validate funding percentage
  					'RSUP',
  					v_supervision_start_dt,
  					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name ('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
  				END IF;*/
			-- This code has been commented out NOCOPY because this
			-- validation is done at the library .
                                NULL;
  			END IF;
  		END IF;

-- Bug # 2829275 . UK Correspondence.The TBH needs to be modified to invoke the supervision  event is raised when supervisor attributes of a student changes.


    IF (p_inserting
         OR(p_updating AND ((new_references.start_dt  <> old_references.start_dt )OR
                            ((new_references.end_dt  <> old_references.end_dt ) OR (old_references.end_dt IS NULL AND new_references.end_dt IS NOT NULL) OR (new_references.end_dt IS NULL AND old_references.end_dt IS NOT NULL)) OR
                            (new_references.research_supervisor_type  <> old_references.research_supervisor_type)   OR
                            ((new_references.supervision_percentage   <> old_references.supervision_percentage) OR (old_references.supervision_percentage IS NULL AND new_references.supervision_percentage IS NOT NULL)
			    OR (old_references.supervision_percentage IS NOT NULL AND new_references.supervision_percentage IS NULL)) OR
                            ((new_references.org_unit_cd  <> old_references.org_unit_cd) OR (old_references.org_unit_cd IS NULL AND new_references.org_unit_cd IS NOT NULL)
			    OR (old_references.org_unit_cd IS NOT NULL AND new_references.org_unit_cd IS NULL) ) OR
                            ((new_references.replaced_person_id  <> old_references.replaced_person_id )OR (old_references.replaced_person_id IS NULL AND new_references.replaced_person_id IS NOT NULL)
			    OR (old_references.replaced_person_id IS NOT NULL AND new_references.replaced_person_id IS NULL))))) THEN

                   igs_re_workflow.supervision_event (
					p_personid	=> new_references.ca_person_id,
					p_ca_seq_num	=> new_references.ca_sequence_number,
					p_supervisorid	=> new_references.person_id,
					p_startdt	=> new_references.start_dt,
					p_enddt	        => new_references.end_dt,
					p_spr_percent	=> new_references.supervision_percentage,
					p_spr_type	=> new_references.research_supervisor_type,
					p_fund_percent	=> new_references.funding_percentage,
					p_org_unit_cd	=> new_references.org_unit_cd,
					p_rep_person_id	=> new_references.replaced_person_id,
					p_rep_seq_num	=> new_references.replaced_sequence_number
					) ;

    END IF;

  END AfterRowInsertUpdate2;

  -- Trigger description :-
  -- "OSS_TST".trg_rsup_as_iud
  -- AFTER INSERT OR DELETE OR UPDATE
  -- ON IGS_RE_SPRVSR

  PROCEDURE Check_Constraints (
    Column_Name in VARCHAR2  ,
    Column_Value in VARCHAR2
  ) AS
 BEGIN

 IF Column_Name is null then
   NULL;
 ELSIF upper(Column_name) = 'CA_SEQUENCE_NUMBER' THEN
   new_references.CA_SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'SUPERVISION_PERCENTAGE' THEN
   new_references.SUPERVISION_PERCENTAGE := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'REPLACED_SEQUENCE_NUMBER' THEN
   new_references.REPLACED_SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'FUNDING_PERCENTAGE' THEN
   new_references.FUNDING_PERCENTAGE := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' THEN
   new_references.SEQUENCE_NUMBER := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'ORG_UNIT_CD' THEN
   new_references.ORG_UNIT_CD := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'RESEARCH_SUPERVISOR_TYPE' THEN
   new_references.RESEARCH_SUPERVISOR_TYPE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'SUPERVISOR_PROFESSION' THEN
   new_references.SUPERVISOR_PROFESSION := COLUMN_VALUE ;
 END IF;

  IF upper(column_name) = 'CA_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.CA_SEQUENCE_NUMBER < 1 OR new_references.CA_SEQUENCE_NUMBER > 999999 then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'SUPERVISION_PERCENTAGE' OR COLUMN_NAME IS NULL THEN
    IF new_references.SUPERVISION_PERCENTAGE < 0 OR new_references.SUPERVISION_PERCENTAGE > 100 then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'REPLACED_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.REPLACED_SEQUENCE_NUMBER < 1 OR new_references.REPLACED_SEQUENCE_NUMBER > 999999 then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'FUNDING_PERCENTAGE' OR COLUMN_NAME IS NULL THEN
    IF new_references.FUNDING_PERCENTAGE < 0 OR new_references.FUNDING_PERCENTAGE > 100 then
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

  IF upper(column_name) = 'RESEARCH_SUPERVISOR_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.RESEARCH_SUPERVISOR_TYPE <> upper(NEW_REFERENCES.RESEARCH_SUPERVISOR_TYPE) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'SUPERVISOR_PROFESSION' OR COLUMN_NAME IS NULL THEN
    IF new_references.SUPERVISOR_PROFESSION <> upper(NEW_REFERENCES.SUPERVISOR_PROFESSION) then
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
 END Check_Constraints ;

  PROCEDURE Check_Uniqueness AS
  BEGIN
	IF Get_UK1_For_Validation (
		new_references.ca_person_id,
		new_references.ca_sequence_number,
		new_references.person_id,
		new_references.start_dt
	) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	        IGS_GE_MSG_STACK.ADD;
        	App_Exception.Raise_Exception;
	END IF;

  END Check_Uniqueness;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.ca_person_id = new_references.ca_person_id) AND
         (old_references.ca_sequence_number = new_references.ca_sequence_number)) OR
        ((new_references.ca_person_id IS NULL) OR
         (new_references.ca_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_CANDIDATURE_PKG.Get_PK_For_Validation (
        new_references.ca_person_id,
        new_references.ca_sequence_number
        ) THEN
     	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	     IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF (((old_references.org_unit_cd = new_references.org_unit_cd) AND
         (old_references.ou_start_dt = new_references.ou_start_dt)) OR
        ((new_references.org_unit_cd IS NULL) OR
         (new_references.ou_start_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.org_unit_cd,
        new_references.ou_start_dt
        ) THEN
     	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	     IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        ) THEN
     	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	     IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF (((old_references.research_supervisor_type = new_references.research_supervisor_type)) OR
        ((new_references.research_supervisor_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_SPRVSR_TYPE_PKG.Get_PK_For_Validation (
        new_references.research_supervisor_type
        ) THEN
     	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	     IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF (((old_references.ca_person_id = new_references.ca_person_id) AND
         (old_references.ca_sequence_number = new_references.ca_sequence_number) AND
         (old_references.replaced_person_id = new_references.replaced_person_id) AND
         (old_references.replaced_sequence_number = new_references.replaced_sequence_number)) OR
        ((new_references.ca_person_id IS NULL) OR
         (new_references.ca_sequence_number IS NULL) OR
         (new_references.replaced_person_id IS NULL) OR
         (new_references.replaced_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_SPRVSR_PKG.Get_PK_For_Validation (
        new_references.ca_person_id,
        new_references.ca_sequence_number,
        new_references.replaced_person_id,
        new_references.replaced_sequence_number
        ) THEN
     	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	     IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
       END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_RE_SPRVSR_PKG.GET_FK_IGS_RE_SPRVSR (
      old_references.ca_person_id,
      old_references.ca_sequence_number,
      old_references.person_id,
      old_references.sequence_number
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_ca_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    )
   RETURN BOOLEAN
   AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SPRVSR
      WHERE    ca_person_id = x_ca_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      person_id = x_person_id
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

  FUNCTION Get_UK1_For_Validation (
    x_ca_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_person_id IN NUMBER,
    x_start_dt IN DATE
    )
   RETURN BOOLEAN
   AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SPRVSR
      WHERE    ca_person_id = x_ca_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      person_id = x_person_id
      AND      start_dt = x_start_dt
      AND ((l_rowid is null) or (rowid <> l_rowid))
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

  END Get_UK1_For_Validation;

  PROCEDURE GET_FK_IGS_RE_CANDIDATURE (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SPRVSR
      WHERE    ca_person_id = x_person_id
      AND      ca_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_RSUP_CA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RE_CANDIDATURE;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SPRVSR
      WHERE    org_unit_cd = x_org_unit_cd
      AND      ou_start_dt = x_start_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_RSUP_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_UNIT;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SPRVSR
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_RSUP_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_RE_SPRVSR_TYPE (
    x_research_supervisor_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SPRVSR
      WHERE    research_supervisor_type = x_research_supervisor_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_RSUP_RST_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RE_SPRVSR_TYPE;

  PROCEDURE GET_FK_IGS_RE_SPRVSR (
    x_ca_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SPRVSR
      WHERE    ca_person_id = x_ca_person_id
      AND      ca_sequence_number = x_ca_sequence_number
      AND      replaced_person_id = x_person_id
      AND      replaced_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_RSUP_RSUP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RE_SPRVSR;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_ca_person_id IN NUMBER ,
    x_ca_sequence_number IN NUMBER ,
    x_person_id IN NUMBER ,
    x_sequence_number IN NUMBER ,
    x_start_dt IN DATE ,
    x_end_dt IN DATE ,
    x_research_supervisor_type IN VARCHAR2 ,
    x_supervisor_profession IN VARCHAR2 ,
    x_supervision_percentage IN NUMBER ,
    x_funding_percentage IN NUMBER ,
    x_org_unit_cd IN VARCHAR2 ,
    x_ou_start_dt IN DATE ,
    x_replaced_person_id IN NUMBER ,
    x_replaced_sequence_number IN NUMBER ,
    x_comments IN VARCHAR2 ,
    x_creation_date IN DATE  ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_ca_person_id,
      x_ca_sequence_number,
      x_person_id,
      x_sequence_number,
      x_start_dt,
      x_end_dt,
      x_research_supervisor_type,
      x_supervisor_profession,
      x_supervision_percentage,
      x_funding_percentage,
      x_org_unit_cd,
      x_ou_start_dt,
      x_replaced_person_id,
      x_replaced_sequence_number,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,
                                     p_updating => FALSE,
                                     p_deleting => FALSE
                                   );
      IF Get_PK_For_Validation (
	    new_references.ca_person_id,
    	    new_references.ca_sequence_number,
    	    new_references.person_id,
    	    new_references.sequence_number
      ) THEN
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	 IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 (  p_inserting => FALSE,
                                      p_updating => TRUE,
                                      p_deleting => FALSE
                                   );
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 (  p_inserting => FALSE,
				      p_updating => FALSE,
				      p_deleting => TRUE
				    );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
	    new_references.ca_person_id,
    	    new_references.ca_sequence_number,
    	    new_references.person_id,
    	    new_references.sequence_number
      ) THEN
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE,
			      p_updating => FALSE,
			      p_deleting => FALSE
			    );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_inserting => FALSE,
			      p_updating => TRUE,
			      p_deleting => FALSE
			    );
    END IF;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_RESEARCH_SUPERVISOR_TYPE in VARCHAR2,
  X_SUPERVISOR_PROFESSION in VARCHAR2,
  X_SUPERVISION_PERCENTAGE in NUMBER,
  X_FUNDING_PERCENTAGE in NUMBER,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_REPLACED_PERSON_ID in NUMBER,
  X_REPLACED_SEQUENCE_NUMBER in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_RE_SPRVSR
      where CA_PERSON_ID = X_CA_PERSON_ID
      and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
      and PERSON_ID = X_PERSON_ID
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
    x_ca_person_id => X_CA_PERSON_ID,
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_person_id => X_PERSON_ID,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_start_dt => X_START_DT,
    x_end_dt => X_END_DT,
    x_research_supervisor_type => X_RESEARCH_SUPERVISOR_TYPE,
    x_supervisor_profession => X_SUPERVISOR_PROFESSION,
    x_supervision_percentage => X_SUPERVISION_PERCENTAGE,
    x_funding_percentage => X_FUNDING_PERCENTAGE,
    x_org_unit_cd => X_ORG_UNIT_CD,
    x_ou_start_dt => X_OU_START_DT,
    x_replaced_person_id => X_REPLACED_PERSON_ID,
    x_replaced_sequence_number => X_REPLACED_SEQUENCE_NUMBER,
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
  insert into IGS_RE_SPRVSR (
    CA_PERSON_ID,
    CA_SEQUENCE_NUMBER,
    PERSON_ID,
    SEQUENCE_NUMBER,
    START_DT,
    END_DT,
    RESEARCH_SUPERVISOR_TYPE,
    SUPERVISOR_PROFESSION,
    SUPERVISION_PERCENTAGE,
    FUNDING_PERCENTAGE,
    ORG_UNIT_CD,
    OU_START_DT,
    REPLACED_PERSON_ID,
    REPLACED_SEQUENCE_NUMBER,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.CA_PERSON_ID,
    NEW_REFERENCES.CA_SEQUENCE_NUMBER,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.RESEARCH_SUPERVISOR_TYPE,
    NEW_REFERENCES.SUPERVISOR_PROFESSION,
    NEW_REFERENCES.SUPERVISION_PERCENTAGE,
    NEW_REFERENCES.FUNDING_PERCENTAGE,
    NEW_REFERENCES.ORG_UNIT_CD,
    NEW_REFERENCES.OU_START_DT,
    NEW_REFERENCES.REPLACED_PERSON_ID,
    NEW_REFERENCES.REPLACED_SEQUENCE_NUMBER,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
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
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_RESEARCH_SUPERVISOR_TYPE in VARCHAR2,
  X_SUPERVISOR_PROFESSION in VARCHAR2,
  X_SUPERVISION_PERCENTAGE in NUMBER,
  X_FUNDING_PERCENTAGE in NUMBER,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_REPLACED_PERSON_ID in NUMBER,
  X_REPLACED_SEQUENCE_NUMBER in NUMBER,
  X_COMMENTS in VARCHAR2
) as
  cursor c1 is select
      START_DT,
      END_DT,
      RESEARCH_SUPERVISOR_TYPE,
      SUPERVISOR_PROFESSION,
      SUPERVISION_PERCENTAGE,
      FUNDING_PERCENTAGE,
      ORG_UNIT_CD,
      OU_START_DT,
      REPLACED_PERSON_ID,
      REPLACED_SEQUENCE_NUMBER,
      COMMENTS
    from IGS_RE_SPRVSR
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.START_DT = X_START_DT)
      AND ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
      AND (tlinfo.RESEARCH_SUPERVISOR_TYPE = X_RESEARCH_SUPERVISOR_TYPE)
      AND ((tlinfo.SUPERVISOR_PROFESSION = X_SUPERVISOR_PROFESSION)
           OR ((tlinfo.SUPERVISOR_PROFESSION is null)
               AND (X_SUPERVISOR_PROFESSION is null)))
      AND ((tlinfo.SUPERVISION_PERCENTAGE = X_SUPERVISION_PERCENTAGE)
           OR ((tlinfo.SUPERVISION_PERCENTAGE is null)
               AND (X_SUPERVISION_PERCENTAGE is null)))
      AND ((tlinfo.FUNDING_PERCENTAGE = X_FUNDING_PERCENTAGE)
           OR ((tlinfo.FUNDING_PERCENTAGE is null)
               AND (X_FUNDING_PERCENTAGE is null)))
      AND ((tlinfo.ORG_UNIT_CD = X_ORG_UNIT_CD)
           OR ((tlinfo.ORG_UNIT_CD is null)
               AND (X_ORG_UNIT_CD is null)))
      AND ((tlinfo.OU_START_DT = X_OU_START_DT)
           OR ((tlinfo.OU_START_DT is null)
               AND (X_OU_START_DT is null)))
      AND ((tlinfo.REPLACED_PERSON_ID = X_REPLACED_PERSON_ID)
           OR ((tlinfo.REPLACED_PERSON_ID is null)
               AND (X_REPLACED_PERSON_ID is null)))
      AND ((tlinfo.REPLACED_SEQUENCE_NUMBER = X_REPLACED_SEQUENCE_NUMBER)
           OR ((tlinfo.REPLACED_SEQUENCE_NUMBER is null)
               AND (X_REPLACED_SEQUENCE_NUMBER is null)))
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
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_RESEARCH_SUPERVISOR_TYPE in VARCHAR2,
  X_SUPERVISOR_PROFESSION in VARCHAR2,
  X_SUPERVISION_PERCENTAGE in NUMBER,
  X_FUNDING_PERCENTAGE in NUMBER,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_REPLACED_PERSON_ID in NUMBER,
  X_REPLACED_SEQUENCE_NUMBER in NUMBER,
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
    x_ca_person_id => X_CA_PERSON_ID,
    x_ca_sequence_number => X_CA_SEQUENCE_NUMBER,
    x_person_id => X_PERSON_ID,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_start_dt => X_START_DT,
    x_end_dt => X_END_DT,
    x_research_supervisor_type => X_RESEARCH_SUPERVISOR_TYPE,
    x_supervisor_profession => X_SUPERVISOR_PROFESSION,
    x_supervision_percentage => X_SUPERVISION_PERCENTAGE,
    x_funding_percentage => X_FUNDING_PERCENTAGE,
    x_org_unit_cd => X_ORG_UNIT_CD,
    x_ou_start_dt => X_OU_START_DT,
    x_replaced_person_id => X_REPLACED_PERSON_ID,
    x_replaced_sequence_number => X_REPLACED_SEQUENCE_NUMBER,
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
  update IGS_RE_SPRVSR set
    START_DT = NEW_REFERENCES.START_DT,
    END_DT = NEW_REFERENCES.END_DT,
    RESEARCH_SUPERVISOR_TYPE = NEW_REFERENCES.RESEARCH_SUPERVISOR_TYPE,
    SUPERVISOR_PROFESSION = NEW_REFERENCES.SUPERVISOR_PROFESSION,
    SUPERVISION_PERCENTAGE = NEW_REFERENCES.SUPERVISION_PERCENTAGE,
    FUNDING_PERCENTAGE = NEW_REFERENCES.FUNDING_PERCENTAGE,
    ORG_UNIT_CD = NEW_REFERENCES.ORG_UNIT_CD,
    OU_START_DT = NEW_REFERENCES.OU_START_DT,
    REPLACED_PERSON_ID = NEW_REFERENCES.REPLACED_PERSON_ID,
    REPLACED_SEQUENCE_NUMBER = NEW_REFERENCES.REPLACED_SEQUENCE_NUMBER,
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
  X_CA_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_RESEARCH_SUPERVISOR_TYPE in VARCHAR2,
  X_SUPERVISOR_PROFESSION in VARCHAR2,
  X_SUPERVISION_PERCENTAGE in NUMBER,
  X_FUNDING_PERCENTAGE in NUMBER,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_REPLACED_PERSON_ID in NUMBER,
  X_REPLACED_SEQUENCE_NUMBER in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
  cursor c1 is
 select rowid from IGS_RE_SPRVSR
     where CA_PERSON_ID = X_CA_PERSON_ID
     and CA_SEQUENCE_NUMBER = X_CA_SEQUENCE_NUMBER
     and PERSON_ID = X_PERSON_ID
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_CA_PERSON_ID,
     X_CA_SEQUENCE_NUMBER,
     X_PERSON_ID,
     X_SEQUENCE_NUMBER,
     X_START_DT,
     X_END_DT,
     X_RESEARCH_SUPERVISOR_TYPE,
     X_SUPERVISOR_PROFESSION,
     X_SUPERVISION_PERCENTAGE,
     X_FUNDING_PERCENTAGE,
     X_ORG_UNIT_CD,
     X_OU_START_DT,
     X_REPLACED_PERSON_ID,
     X_REPLACED_SEQUENCE_NUMBER,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_CA_PERSON_ID,
   X_CA_SEQUENCE_NUMBER,
   X_PERSON_ID,
   X_SEQUENCE_NUMBER,
   X_START_DT,
   X_END_DT,
   X_RESEARCH_SUPERVISOR_TYPE,
   X_SUPERVISOR_PROFESSION,
   X_SUPERVISION_PERCENTAGE,
   X_FUNDING_PERCENTAGE,
   X_ORG_UNIT_CD,
   X_OU_START_DT,
   X_REPLACED_PERSON_ID,
   X_REPLACED_SEQUENCE_NUMBER,
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
  delete from IGS_RE_SPRVSR
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

end DELETE_ROW;

end IGS_RE_SPRVSR_PKG;

/
