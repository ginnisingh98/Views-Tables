--------------------------------------------------------
--  DDL for Package Body IGS_RE_CANDIDATURE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_CANDIDATURE_PKG" as
/* $Header: IGSRI01B.pls 120.1 2005/07/04 00:40:40 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_re_val_ca.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_RE_CANDIDATURE_ALL%RowType;
  new_references IGS_RE_CANDIDATURE_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action                            IN VARCHAR2,
    x_rowid                             IN VARCHAR2,
    x_industry_links                    IN VARCHAR2 ,
    x_person_id                         IN NUMBER ,
    x_sequence_number                   IN NUMBER ,
    x_sca_course_cd                     IN VARCHAR2 ,
    x_acai_admission_appl_number        IN NUMBER ,
    x_acai_nominated_course_cd          IN VARCHAR2 ,
    x_acai_sequence_number              IN NUMBER ,
    x_attendance_percentage             IN NUMBER ,
    x_govt_type_of_activity_cd          IN VARCHAR2 ,
    x_max_submission_dt                 IN DATE ,
    x_min_submission_dt                 IN DATE ,
    x_research_topic                    IN VARCHAR2 ,
    x_creation_date                     IN DATE ,
    x_created_by                        IN NUMBER ,
    x_last_update_date                  IN DATE ,
    x_last_updated_by                   IN NUMBER ,
    x_last_update_login                 IN NUMBER  ,
    x_org_id                            IN NUMBER
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_CANDIDATURE_ALL
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
    new_references.industry_links := x_industry_links;
    new_references.person_id := x_person_id;
    new_references.sequence_number := x_sequence_number;
    new_references.sca_course_cd := x_sca_course_cd;
    new_references.acai_admission_appl_number := x_acai_admission_appl_number;
    new_references.acai_nominated_course_cd := x_acai_nominated_course_cd;
    new_references.acai_sequence_number := x_acai_sequence_number;
    new_references.attendance_percentage := x_attendance_percentage;
    new_references.govt_type_of_activity_cd := x_govt_type_of_activity_cd;
    new_references.max_submission_dt := x_max_submission_dt;
    new_references.min_submission_dt := x_min_submission_dt;
    new_references.research_topic := x_research_topic;
    new_references.org_id := x_org_id ;

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
    p_inserting  IN BOOLEAN,
    p_updating   IN BOOLEAN,
    p_deleting   IN BOOLEAN
    ) AS
        v_sequence_number       NUMBER;
  BEGIN
        -- Log an entry in the IGS_PE_STD_TODO table, indicating that a fee re-assessment
        -- is required.
        IF p_updating THEN
                -- Indicate fee assessment if attendance percentage has changed
                -- and the IGS_RE_CANDIDATURE is linked to a student IGS_PS_COURSE attempt
                IF (NVL(old_references.attendance_percentage,-1) <> NVL(new_references.attendance_percentage,-1))
                        AND
                        (new_references.sca_course_cd IS NOT NULL) THEN
                        v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(
                                                new_references.person_id,
                                                'FEE_RECALC',
                                                SYSDATE,
                                                'Y');
                END IF;
        END IF;
  END BeforeRowInsertUpdate1;

  PROCEDURE BeforeRowInsertUpdateDelete2(
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN
    ) AS
        v_message_name                          VARCHAR2(30);
        v_old_sca_course_cd                     IGS_RE_CANDIDATURE.sca_course_cd%TYPE;
        v_old_acai_admission_appl_num           IGS_RE_CANDIDATURE.acai_admission_appl_number%TYPE;
        v_old_acai_nominated_course_cd          IGS_RE_CANDIDATURE.acai_nominated_course_cd%TYPE;
        v_old_acai_sequence_number              IGS_RE_CANDIDATURE.acai_sequence_number%TYPE;
   BEGIN
        IF p_inserting OR
                p_updating THEN
                IF p_inserting THEN
                        v_old_sca_course_cd := NULL;
                        v_old_acai_admission_appl_num := NULL;
                        v_old_acai_nominated_course_cd := NULL;
                        v_old_acai_sequence_number := NULL;
                ELSE
                        v_old_sca_course_cd := old_references.sca_course_cd;
                        v_old_acai_admission_appl_num := old_references.acai_admission_appl_number;
                        v_old_acai_nominated_course_cd := old_references.acai_nominated_course_cd;
                        v_old_acai_sequence_number := old_references.acai_sequence_number;
                END IF;
                -- Validate that one of SCA or ACAI links exist, and that
                -- the details match their parent(s)
                IF p_inserting OR
                        (p_updating AND
                        (NVL(old_references.sca_course_cd,'NULL') <>
                                NVL(new_references.sca_course_cd,'NULL')) OR
                        (NVL(old_references.acai_admission_appl_number,0) <>
                                NVL(new_references.acai_admission_appl_number,0)) OR
                        (NVL(old_references.acai_nominated_course_cd,'NULL') <>
                                NVL(new_references.acai_nominated_course_cd,'NULL')) OR
                        (NVL(old_references.acai_sequence_number,0) <>
                                NVL(new_references.acai_sequence_number,0))) THEN
                        IF IGS_RE_VAL_CA.resp_val_ca_sca_acai (
                                new_references.person_id,
                                new_references.sca_course_cd,
                                new_references.acai_admission_appl_number,
                                new_references.acai_nominated_course_cd,
                                new_references.acai_sequence_number,
                                v_message_name) = FALSE THEN
                                        Fnd_Message.Set_Name ('IGS', v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        App_Exception.Raise_Exception;
                        END IF;
                END IF;
                IF p_updating AND
                        new_references.sca_course_cd IS NOT NULL THEN
                        -- Validate that updates are allowed
                        IF IGS_RE_VAL_CA.resp_val_ca_upd(
                                new_references.person_id,
                                new_references.sca_course_cd,
                                v_message_name) = FALSE THEN
                                        Fnd_Message.Set_Name ('IGS', v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Validation of submission dates can only be done in before row trigger
                -- if p_inserting, or
                -- p_updating and either:
                --      attendance percentage has not been changed, or
                --      both submission dates are set
                -- If this is not the case, validation is in the after statement trigger.
                IF p_inserting OR
                        (p_updating AND
                        (NVL(old_references.attendance_percentage,0) = NVL(new_references.attendance_percentage,0) OR
                        (new_references.min_submission_dt IS NOT NULL AND
                        new_references.max_submission_dt IS NOT NULL))) THEN
                        -- Validate minimum submission date
                        IF (p_inserting AND
                                new_references.min_submission_dt IS NOT NULL) OR
                                (p_updating AND
                                NVL(old_references.min_submission_dt,igs_ge_date.igsdate('1900/01/01')) <>
                                NVL(new_references.min_submission_dt,igs_ge_date.igsdate('1900/01/01')) ) THEN
                                IF IGS_RE_VAL_CA.resp_val_ca_minsbmsn (
                                        new_references.person_id,
                                        new_references.sca_course_cd,
                                        new_references.acai_admission_appl_number,
                                        new_references.acai_nominated_course_cd,
                                        new_references.acai_sequence_number,
                                        new_references.min_submission_dt,
                                        new_references.max_submission_dt,
                                        new_references.attendance_percentage,
                                        NULL, -- commencement date should already be updated
                                        v_message_name,
                                        'N') = FALSE THEN
                                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                                IGS_GE_MSG_STACK.ADD;
                                                App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                        -- Validate maximum submission date
                        IF (p_inserting AND
                                new_references.max_submission_dt IS NOT NULL) OR
                                (p_updating AND
                                NVL(old_references.max_submission_dt,igs_ge_date.igsdate('1900/01/01')) <>
                                NVL(new_references.max_submission_dt,igs_ge_date.igsdate('1900/01/01')) ) THEN
                                IF IGS_RE_VAL_CA.resp_val_ca_maxsbmsn (
                                        new_references.person_id,
                                        new_references.sca_course_cd,
                                        new_references.acai_admission_appl_number,
                                        new_references.acai_nominated_course_cd,
                                        new_references.acai_sequence_number,
                                        new_references.min_submission_dt,
                                        new_references.max_submission_dt,
                                        new_references.attendance_percentage,
                                        NULL, -- commencement date should already be updated
                                        v_message_name,
                                        'N') = FALSE THEN
                                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                                IGS_GE_MSG_STACK.ADD;
                                                App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                END IF;
                -- Validate govt type of activity code
                IF (p_inserting AND
                        new_references.govt_type_of_activity_cd IS NOT NULL) OR
                        (p_updating AND
                        NVL(old_references.govt_type_of_activity_cd,'NULL') <>
                                NVL(new_references.govt_type_of_activity_cd,'NULL')) THEN
                        IF IGS_RE_VAL_CA.resp_val_gtcc_closed (
                                new_references.govt_type_of_activity_cd,
                                v_message_name) = FALSE THEN
                                        Fnd_Message.Set_Name ('IGS', v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Validate research topic
                IF  p_inserting  OR
                        (p_updating AND
                        NVL(old_references.research_topic,'NULL') <> NVL(new_references.research_topic,'NULL')) THEN
                        IF IGS_RE_VAL_CA.resp_val_ca_topic (
                                new_references.person_id,
                                new_references.sca_course_cd,
                                new_references.acai_admission_appl_number,
                                new_references.acai_nominated_course_cd,
                                new_references.acai_sequence_number,
                                new_references.research_topic,
                                v_message_name,
                                'N') = FALSE THEN
                                        Fnd_Message.Set_Name ('IGS', v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        App_Exception.Raise_Exception;
                        END IF;
                END IF;
        END IF;

        IF p_deleting  THEN
                -- Validate SCA link.
                IF IGS_RE_VAL_CA.resp_val_ca_sca_del (
                        old_references.person_id,
                        old_references.sca_course_cd,
                        v_message_name) = FALSE THEN
                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
                -- Validate ACAI link.
                IF IGS_RE_VAL_CA.resp_val_ca_acai_del (
                        old_references.person_id,
                        old_references.acai_admission_appl_number,
                        old_references.acai_nominated_course_cd,
                        old_references.acai_sequence_number,
                        v_message_name) = FALSE THEN
                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;
  END BeforeRowInsertUpdateDelete2;

 PROCEDURE AfterRowInsertUpdate3(
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN
    ) AS
        v_message_name                          VARCHAR2(30);
        v_old_sca_course_cd                     IGS_RE_CANDIDATURE.sca_course_cd%TYPE;
        v_old_acai_admission_appl_num           IGS_RE_CANDIDATURE.acai_admission_appl_number%TYPE;
        v_old_acai_nominated_course_cd          IGS_RE_CANDIDATURE.acai_nominated_course_cd%TYPE;
        v_old_acai_sequence_number              IGS_RE_CANDIDATURE.acai_sequence_number%TYPE;
  BEGIN

        IF p_inserting OR
                p_updating THEN

                IF p_inserting THEN
                        v_old_sca_course_cd := NULL;
                        v_old_acai_admission_appl_num := NULL;
                        v_old_acai_nominated_course_cd := NULL;
                        v_old_acai_sequence_number := NULL;
                ELSE
                        v_old_sca_course_cd := old_references.sca_course_cd;
                        v_old_acai_admission_appl_num := old_references.acai_admission_appl_number;
                        v_old_acai_nominated_course_cd := old_references.acai_nominated_course_cd;
                        v_old_acai_sequence_number := old_references.acai_sequence_number;
                END IF;

                -- Validate that SCA and ACAI links
                IF  p_inserting  OR
                        (p_updating AND
                        NVL(old_references.sca_course_cd,'NULL') <> NVL(new_references.sca_course_cd,'NULL')) OR
                        (p_updating AND
                        (NVL(old_references.acai_admission_appl_number,0) <>
                                NVL(new_references.acai_admission_appl_number,0)) OR
                        (NVL(old_references.acai_nominated_course_cd,'NULL') <>
                                NVL(new_references.acai_nominated_course_cd,'NULL')) OR
                        (NVL(old_references.acai_sequence_number,0) <>
                                NVL(new_references.acai_sequence_number,0))) THEN
                                        NULL;
                END IF;

    -- Bug # 2829275 . UK Correspondence.The research topic event is raised when there is either a change or a research topic is created.

               IF (p_inserting AND new_references.research_topic IS NOT NULL ) THEN

                 igs_re_workflow.retopic_event (
                                              p_personid        => new_references.person_id,
                                              p_programcd       => new_references.sca_course_cd,
                                              p_restopic        => new_references.research_topic
                                                );

               ELSIF ( p_updating AND ((new_references.research_topic IS NULL AND old_references.research_topic IS NOT NULL) OR
                                       (new_references.research_topic IS NOT NULL AND old_references.research_topic IS NULL)
                                       OR new_references.research_topic <> old_references.research_topic) )  THEN

                 igs_re_workflow.retopic_event (
                                              p_personid        => new_references.person_id,
                                              p_programcd       => new_references.sca_course_cd,
                                              p_restopic        => new_references.research_topic
                                                );

               END IF;

         END IF;
  END AfterRowInsertUpdate3;

  PROCEDURE AfterRowUpdateDelete4(
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN
    ) AS
  BEGIN
        IF p_updating THEN
                -- create a history
                IGS_RE_GEN_002.RESP_INS_CA_HIST( old_references.person_id,
                        old_references.sequence_number,
                        old_references.sca_course_cd,
                        new_references.sca_course_cd,
                        old_references.acai_admission_appl_number,
                        new_references.acai_admission_appl_number,
                        old_references.acai_nominated_course_cd,
                        new_references.acai_nominated_course_cd,
                        old_references.acai_sequence_number,
                        new_references.acai_sequence_number,
                        old_references.attendance_percentage,
                        new_references.attendance_percentage,
                        old_references.govt_type_of_activity_cd,
                        new_references.govt_type_of_activity_cd,
                        old_references.max_submission_dt,
                        new_references.max_submission_dt,
                        old_references.min_submission_dt,
                        new_references.min_submission_dt,
                        old_references.research_topic,
                        new_references.research_topic,
                        old_references.industry_links,
                        new_references.industry_links,
                        old_references.last_updated_by,
                        new_references.last_updated_by,
                        old_references.last_update_date,
                        new_references.last_update_date);
        END IF;
  END AfterRowUpdateDelete4;

  PROCEDURE AfterStmtInsertUpdate5(
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN
    ) AS
        v_message_name                          VARCHAR2(30);

  BEGIN
        -- If trigger has not been disabled, perform required processing
        IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_RE_CANDIDATURE_ALL') THEN
                -- Insert IGS_RE_CANDIDATURE attendance history from row ids saved
                -- when IGS_RE_CANDIDATURE attendance percentage changed

                -- Mutation logic pasted
                -- Insert IGS_RE_CANDIDATURE attendance history
                IF IGS_RE_GEN_002.RESP_INS_CA_CAH(
                        New_References.person_id,
                        New_References.sequence_number,
                        New_References.sca_course_cd,
                        New_References.attendance_percentage,
                        v_message_name) = FALSE THEN
                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                   FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,'igs.plsql.igs_re_candidature_pkg.AfterStmtInsertUpdate5.ERR',FALSE);
                                END IF;
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
                IF p_updating THEN
                        IF New_References.min_submission_dt IS NULL THEN
                                -- Validate derived minimum submission date
                                IF IGS_RE_VAL_CA.resp_val_ca_minsbmsn (
                                        New_References.person_id,
                                        New_References.sca_course_cd,
                                        New_References.acai_admission_appl_number,
                                        New_References.acai_nominated_course_cd,
                                        New_References.acai_sequence_number,
                                        New_References.min_submission_dt,
                                        New_References.max_submission_dt,
                                        New_References.attendance_percentage,
                                        NULL, -- commencement date
                                        v_message_name,
                                        'N') = FALSE THEN
                                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                                IGS_GE_MSG_STACK.ADD;
                                                App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                        IF New_References.max_submission_dt IS NULL THEN
                                -- Validate derived maximum submission date
                                IF IGS_RE_VAL_CA.resp_val_ca_maxsbmsn (
                                        New_References.person_id,
                                        New_References.sca_course_cd,
                                        New_References.acai_admission_appl_number,
                                        New_References.acai_nominated_course_cd,
                                        New_References.acai_sequence_number,
                                        New_References.min_submission_dt,
                                        New_References.max_submission_dt,
                                        New_References.attendance_percentage,
                                        NULL, -- commencement date
                                        v_message_name,
                                        'N') = FALSE THEN
                                                Fnd_Message.Set_Name ('IGS', v_message_name);
                                                IGS_GE_MSG_STACK.ADD;
                                                App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                END IF;
                -- Validate SCA and ACAI links
                -- Comment out NOCOPY for now until resolved

                -- Mutation logic pasted
                -- Validate SCA link
                IF  p_inserting  OR
                        (p_updating AND
                        NVL(Old_References.sca_course_cd,'NULL') <>
                                 NVL(New_References.sca_course_cd,'NULL')) THEN
                        IF IGS_RE_VAL_CA.resp_val_ca_sca(
                                New_References.person_id,
                                New_References.sequence_number,
                                Old_References.sca_course_cd,
                                New_References.sca_course_cd,
                                New_References.acai_admission_appl_number,
                                New_References.acai_nominated_course_cd,
                                New_References.acai_sequence_number,
                                v_message_name) = FALSE THEN
                                        Fnd_Message.Set_Name ('IGS', v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Validate ACAI  link
                IF p_inserting OR
                        (p_updating AND
                        (NVL(Old_References.acai_admission_appl_number,0) <>
                                NVL(New_References.acai_admission_appl_number,0)) OR
                        (NVL(Old_References.acai_nominated_course_cd,'NULL') <>
                                NVL(New_References.acai_nominated_course_cd,'NULL')) OR
                        (NVL(Old_References.acai_sequence_number,0) <>
                                NVL(New_References.acai_sequence_number,0))) THEN
                        IF IGS_RE_VAL_CA.resp_val_ca_acai(
                                New_References.person_id,
                                New_References.sequence_number,
                                New_References.sca_course_cd,
                                Old_References.acai_admission_appl_number,
                                Old_References.acai_nominated_course_cd,
                                Old_References.acai_sequence_number,
                                New_References.acai_admission_appl_number,
                                New_References.acai_nominated_course_cd,
                                New_References.acai_sequence_number,
                                v_message_name) = FALSE THEN
                                        Fnd_Message.Set_Name ('IGS', v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        App_Exception.Raise_Exception;
                        END IF;
                END IF;
        END IF;
  END AfterStmtInsertUpdate5;

 PROCEDURE Check_Constraints (
  Column_Name  IN VARCHAR2,
  Column_Value IN VARCHAR2
  ) AS
 BEGIN
 IF Column_Name is null then
   NULL;
 ELSIF upper(Column_name) = 'ACAI_NOMINATED_COURSE_CD' THEN
   new_references.ACAI_NOMINATED_COURSE_CD := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'GOVT_TYPE_OF_ACTIVITY_CD' THEN
   new_references.GOVT_TYPE_OF_ACTIVITY_CD := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'SCA_COURSE_CD' THEN
   new_references.SCA_COURSE_CD := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' THEN
   new_references.SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'ACAI_SEQUENCE_NUMBER' THEN
   new_references.ACAI_SEQUENCE_NUMBER := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 ELSIF upper(Column_name) = 'ATTENDANCE_PERCENTAGE' THEN
   new_references.ATTENDANCE_PERCENTAGE := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
 END IF;

  IF upper(column_name) = 'ACAI_NOMINATED_COURSE_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.ACAI_NOMINATED_COURSE_CD <> upper(NEW_REFERENCES.ACAI_NOMINATED_COURSE_CD) then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
  IF upper(column_name) = 'GOVT_TYPE_OF_ACTIVITY_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.GOVT_TYPE_OF_ACTIVITY_CD <> upper(NEW_REFERENCES.GOVT_TYPE_OF_ACTIVITY_CD) then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
  IF upper(column_name) = 'SCA_COURSE_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.SCA_COURSE_CD <> upper(NEW_REFERENCES.SCA_COURSE_CD) then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
  IF upper(column_name) = 'SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.SEQUENCE_NUMBER < 1 OR  new_references.SEQUENCE_NUMBER > 999999 then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
  IF upper(column_name) = 'ACAI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.ACAI_SEQUENCE_NUMBER < 1  OR new_references.ACAI_SEQUENCE_NUMBER > 999999 then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
  IF upper(column_name) = 'ATTENDANCE_PERCENTAGE' OR COLUMN_NAME IS NULL THEN
    IF new_references.ATTENDANCE_PERCENTAGE < 1 OR new_references.ATTENDANCE_PERCENTAGE > 100 then
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception ;
        END IF;
  END IF;
 END Check_Constraints ;


  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.acai_admission_appl_number = new_references.acai_admission_appl_number) AND
         (old_references.acai_nominated_course_cd = new_references.acai_nominated_course_cd) AND
         (old_references.acai_sequence_number = new_references.acai_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.acai_admission_appl_number IS NULL) OR
         (new_references.acai_nominated_course_cd IS NULL) OR
         (new_references.acai_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_PS_APPL_INST_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.acai_admission_appl_number,
        new_references.acai_nominated_course_cd,
        new_references.acai_sequence_number
        ) THEN
              Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
        END IF;
    END IF;

    IF (((old_references.govt_type_of_activity_cd = new_references.govt_type_of_activity_cd)) OR
        ((new_references.govt_type_of_activity_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_GV_TOA_CLS_CD_PKG.Get_PK_For_Validation (
        new_references.govt_type_of_activity_cd
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
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.sca_course_cd = new_references.sca_course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.sca_course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.sca_course_cd
        ) THEN
              Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
        END IF;
    END IF;
  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_RE_CDT_ATT_HIST_PKG.GET_FK_IGS_RE_CANDIDATURE (
      old_references.person_id,
      old_references.sequence_number
      );
    IGS_RE_CDT_FLD_OF_SY_PKG.GET_FK_IGS_RE_CANDIDATURE (
      old_references.person_id,
      old_references.sequence_number
      );
    IGS_RE_CAND_SEO_CLS_PKG.GET_FK_IGS_RE_CANDIDATURE (
      old_references.person_id,
      old_references.sequence_number
      );
    IGS_PR_MILESTONE_PKG.GET_FK_IGS_RE_CANDIDATURE (
      old_references.person_id,
      old_references.sequence_number
      );
    IGS_RE_SPRVSR_PKG.GET_FK_IGS_RE_CANDIDATURE (
      old_references.person_id,
      old_references.sequence_number
      );
    IGS_RE_SCHOLARSHIP_PKG.GET_FK_IGS_RE_CANDIDATURE (
      old_references.person_id,
      old_references.sequence_number
      );
    IGS_RE_THESIS_PKG.GET_FK_IGS_RE_CANDIDATURE (
      old_references.person_id,
      old_references.sequence_number
      );
  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    )
   RETURN BOOLEAN
   AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_CANDIDATURE_ALL
      WHERE    person_id = x_person_id
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

  PROCEDURE GET_FK_IGS_AD_PS_APPL_INST (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_CANDIDATURE_ALL
      WHERE    person_id = x_person_id
      AND      acai_admission_appl_number = x_admission_appl_number
      AND      acai_nominated_course_cd = x_nominated_course_cd
      AND      acai_sequence_number = x_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_CA_ACAI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_PS_APPL_INST;

  PROCEDURE GET_FK_IGS_RE_GV_TOA_CLS_CD (
    x_govt_toa_class_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_CANDIDATURE_ALL
      WHERE    govt_type_of_activity_cd = x_govt_toa_class_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_CA_GTCC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_RE_GV_TOA_CLS_CD;
  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_CANDIDATURE_ALL
      WHERE    person_id = x_person_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_CA_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_CANDIDATURE_ALL
      WHERE    person_id = x_person_id
      AND      sca_course_cd = x_course_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_CA_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE Before_DML (
    p_action                            IN VARCHAR2,
    x_rowid                             IN VARCHAR2 ,
    x_industry_links                    IN VARCHAR2 ,
    x_person_id                         IN NUMBER ,
    x_sequence_number                   IN NUMBER ,
    x_sca_course_cd                     IN VARCHAR2 ,
    x_acai_admission_appl_number        IN NUMBER ,
    x_acai_nominated_course_cd          IN VARCHAR2 ,
    x_acai_sequence_number              IN NUMBER ,
    x_attendance_percentage             IN NUMBER ,
    x_govt_type_of_activity_cd          IN VARCHAR2 ,
    x_max_submission_dt                 IN DATE ,
    x_min_submission_dt                 IN DATE ,
    x_research_topic                    IN VARCHAR2 ,
    x_creation_date                     IN DATE ,
    x_created_by                        IN NUMBER ,
    x_last_update_date                  IN DATE ,
    x_last_updated_by                   IN NUMBER ,
    x_last_update_login                 IN NUMBER ,
    x_org_id                            IN NUMBER
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_industry_links,
      x_person_id,
      x_sequence_number,
      x_sca_course_cd,
      x_acai_admission_appl_number,
      x_acai_nominated_course_cd,
      x_acai_sequence_number,
      x_attendance_percentage,
      x_govt_type_of_activity_cd,
      x_max_submission_dt,
      x_min_submission_dt,
      x_research_topic,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting    => TRUE,
                               p_updating     => FALSE,
                               p_deleting     => FALSE );
      BeforeRowInsertUpdateDelete2 ( p_inserting    => TRUE,
                                     p_updating     => FALSE,
                                     p_deleting     => FALSE );

      IF Get_PK_For_Validation (
            new_references.person_id,
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
      BeforeRowInsertUpdate1 (p_inserting     => FALSE,
                              p_updating      => TRUE,
                              p_deleting      => FALSE);
      BeforeRowInsertUpdateDelete2 ( p_inserting     => FALSE,
                                     p_updating      => TRUE,
                                     p_deleting      => FALSE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete2 ( p_inserting     => FALSE,
                                     p_updating      => FALSE,
                                     p_deleting      => TRUE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
            new_references.person_id,
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
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate3 ( p_inserting    => TRUE,
                              p_updating     => FALSE,
                              p_deleting     => FALSE );
      AfterStmtInsertUpdate5 (p_inserting    => TRUE,
                              p_updating     => FALSE,
                              p_deleting     => FALSE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate3 ( p_inserting     => FALSE,
                              p_updating      => TRUE,
                              p_deleting      => FALSE);
      AfterRowUpdateDelete4 ( p_inserting     => FALSE,
                              p_updating      => TRUE,
                              p_deleting      => FALSE);
      AfterStmtInsertUpdate5 (p_inserting     => FALSE,
                              p_updating      => TRUE,
                              p_deleting      => FALSE);
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowUpdateDelete4 ( p_inserting     => FALSE,
                              p_updating      => FALSE,
                              p_deleting      => TRUE );
    END IF;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_ACAI_ADMISSION_APPL_NUMBER in NUMBER,
  X_ACAI_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_PERCENTAGE in NUMBER,
  X_GOVT_TYPE_OF_ACTIVITY_CD in VARCHAR2,
  X_MAX_SUBMISSION_DT in DATE,
  X_MIN_SUBMISSION_DT in DATE,
  X_RESEARCH_TOPIC in VARCHAR2,
  X_INDUSTRY_LINKS in VARCHAR2,
  X_MODE in VARCHAR2,
  X_ORG_ID in NUMBER
  ) as
    cursor C is select ROWID from IGS_RE_CANDIDATURE_ALL
      where PERSON_ID = X_PERSON_ID
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_industry_links => X_INDUSTRY_LINKS,
    x_person_id => X_PERSON_ID,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_sca_course_cd => X_SCA_COURSE_CD,
    x_acai_admission_appl_number => X_ACAI_ADMISSION_APPL_NUMBER,
    x_acai_nominated_course_cd => X_ACAI_NOMINATED_COURSE_CD,
    x_acai_sequence_number => X_ACAI_SEQUENCE_NUMBER,
    x_attendance_percentage => X_ATTENDANCE_PERCENTAGE,
    x_govt_type_of_activity_cd => X_GOVT_TYPE_OF_ACTIVITY_CD,
    x_max_submission_dt => X_MAX_SUBMISSION_DT,
    x_min_submission_dt => X_MIN_SUBMISSION_DT,
    x_research_topic => X_RESEARCH_TOPIC,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
  ) ;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_RE_CANDIDATURE_ALL (
    PERSON_ID,
    SEQUENCE_NUMBER,
    SCA_COURSE_CD,
    ACAI_ADMISSION_APPL_NUMBER,
    ACAI_NOMINATED_COURSE_CD,
    ACAI_SEQUENCE_NUMBER,
    ATTENDANCE_PERCENTAGE,
    GOVT_TYPE_OF_ACTIVITY_CD,
    MAX_SUBMISSION_DT,
    MIN_SUBMISSION_DT,
    RESEARCH_TOPIC,
    INDUSTRY_LINKS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    ORG_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.SCA_COURSE_CD,
    NEW_REFERENCES.ACAI_ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.ACAI_NOMINATED_COURSE_CD,
    NEW_REFERENCES.ACAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ATTENDANCE_PERCENTAGE,
    NEW_REFERENCES.GOVT_TYPE_OF_ACTIVITY_CD,
    NEW_REFERENCES.MAX_SUBMISSION_DT,
    NEW_REFERENCES.MIN_SUBMISSION_DT,
    NEW_REFERENCES.RESEARCH_TOPIC,
    NEW_REFERENCES.INDUSTRY_LINKS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
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
    x_rowid => 'X_ROWID'
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_ACAI_ADMISSION_APPL_NUMBER in NUMBER,
  X_ACAI_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_PERCENTAGE in NUMBER,
  X_GOVT_TYPE_OF_ACTIVITY_CD in VARCHAR2,
  X_MAX_SUBMISSION_DT in DATE,
  X_MIN_SUBMISSION_DT in DATE,
  X_RESEARCH_TOPIC in VARCHAR2,
  X_INDUSTRY_LINKS in VARCHAR2
) as
  cursor c1 is select
      SCA_COURSE_CD,
      ACAI_ADMISSION_APPL_NUMBER,
      ACAI_NOMINATED_COURSE_CD,
      ACAI_SEQUENCE_NUMBER,
      ATTENDANCE_PERCENTAGE,
      GOVT_TYPE_OF_ACTIVITY_CD,
      MAX_SUBMISSION_DT,
      MIN_SUBMISSION_DT,
      RESEARCH_TOPIC,
      INDUSTRY_LINKS
    from IGS_RE_CANDIDATURE_ALL
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
      if ( ((tlinfo.SCA_COURSE_CD = X_SCA_COURSE_CD)
           OR ((tlinfo.SCA_COURSE_CD is null)
               AND (X_SCA_COURSE_CD is null)))
      AND ((tlinfo.ACAI_ADMISSION_APPL_NUMBER = X_ACAI_ADMISSION_APPL_NUMBER)
           OR ((tlinfo.ACAI_ADMISSION_APPL_NUMBER is null)
               AND (X_ACAI_ADMISSION_APPL_NUMBER is null)))
      AND ((tlinfo.ACAI_NOMINATED_COURSE_CD = X_ACAI_NOMINATED_COURSE_CD)
           OR ((tlinfo.ACAI_NOMINATED_COURSE_CD is null)
               AND (X_ACAI_NOMINATED_COURSE_CD is null)))
      AND ((tlinfo.ACAI_SEQUENCE_NUMBER = X_ACAI_SEQUENCE_NUMBER)
           OR ((tlinfo.ACAI_SEQUENCE_NUMBER is null)
               AND (X_ACAI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.ATTENDANCE_PERCENTAGE = X_ATTENDANCE_PERCENTAGE)
           OR ((tlinfo.ATTENDANCE_PERCENTAGE is null)
               AND (X_ATTENDANCE_PERCENTAGE is null)))
      AND ((tlinfo.GOVT_TYPE_OF_ACTIVITY_CD = X_GOVT_TYPE_OF_ACTIVITY_CD)
           OR ((tlinfo.GOVT_TYPE_OF_ACTIVITY_CD is null)
               AND (X_GOVT_TYPE_OF_ACTIVITY_CD is null)))
      AND ((tlinfo.MAX_SUBMISSION_DT = X_MAX_SUBMISSION_DT)
           OR ((tlinfo.MAX_SUBMISSION_DT is null)
               AND (X_MAX_SUBMISSION_DT is null)))
      AND ((tlinfo.MIN_SUBMISSION_DT = X_MIN_SUBMISSION_DT)
           OR ((tlinfo.MIN_SUBMISSION_DT is null)
               AND (X_MIN_SUBMISSION_DT is null)))
      AND ((tlinfo.RESEARCH_TOPIC = X_RESEARCH_TOPIC)
           OR ((tlinfo.RESEARCH_TOPIC is null)
               AND (X_RESEARCH_TOPIC is null)))
      AND ((tlinfo.INDUSTRY_LINKS = X_INDUSTRY_LINKS)
           OR ((tlinfo.INDUSTRY_LINKS is null)
               AND (X_INDUSTRY_LINKS is null)))
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_ACAI_ADMISSION_APPL_NUMBER in NUMBER,
  X_ACAI_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_PERCENTAGE in NUMBER,
  X_GOVT_TYPE_OF_ACTIVITY_CD in VARCHAR2,
  X_MAX_SUBMISSION_DT in DATE,
  X_MIN_SUBMISSION_DT in DATE,
  X_RESEARCH_TOPIC in VARCHAR2,
  X_INDUSTRY_LINKS in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
    x_industry_links => X_INDUSTRY_LINKS,
    x_person_id => X_PERSON_ID,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_sca_course_cd => X_SCA_COURSE_CD,
    x_acai_admission_appl_number => X_ACAI_ADMISSION_APPL_NUMBER,
    x_acai_nominated_course_cd => X_ACAI_NOMINATED_COURSE_CD,
    x_acai_sequence_number => X_ACAI_SEQUENCE_NUMBER,
    x_attendance_percentage => X_ATTENDANCE_PERCENTAGE,
    x_govt_type_of_activity_cd => X_GOVT_TYPE_OF_ACTIVITY_CD,
    x_max_submission_dt => X_MAX_SUBMISSION_DT,
    x_min_submission_dt => X_MIN_SUBMISSION_DT,
    x_research_topic => X_RESEARCH_TOPIC,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  ) ;
  if (X_MODE IN ('R', 'S')) then
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID =  -1) then
      X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
      X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
      X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
      X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  end if;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_RE_CANDIDATURE_ALL set
    SCA_COURSE_CD = NEW_REFERENCES.SCA_COURSE_CD,
    ACAI_ADMISSION_APPL_NUMBER = NEW_REFERENCES.ACAI_ADMISSION_APPL_NUMBER,
    ACAI_NOMINATED_COURSE_CD = NEW_REFERENCES.ACAI_NOMINATED_COURSE_CD,
    ACAI_SEQUENCE_NUMBER = NEW_REFERENCES.ACAI_SEQUENCE_NUMBER,
    ATTENDANCE_PERCENTAGE = NEW_REFERENCES.ATTENDANCE_PERCENTAGE,
    GOVT_TYPE_OF_ACTIVITY_CD = NEW_REFERENCES.GOVT_TYPE_OF_ACTIVITY_CD,
    MAX_SUBMISSION_DT = NEW_REFERENCES.MAX_SUBMISSION_DT,
    MIN_SUBMISSION_DT = NEW_REFERENCES.MIN_SUBMISSION_DT,
    RESEARCH_TOPIC = NEW_REFERENCES.RESEARCH_TOPIC,
    INDUSTRY_LINKS = NEW_REFERENCES.INDUSTRY_LINKS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
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
    p_action => 'UPDATE',
    x_rowid => 'X_ROWID'
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_ACAI_ADMISSION_APPL_NUMBER in NUMBER,
  X_ACAI_NOMINATED_COURSE_CD in VARCHAR2,
  X_ACAI_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_PERCENTAGE in NUMBER,
  X_GOVT_TYPE_OF_ACTIVITY_CD in VARCHAR2,
  X_MAX_SUBMISSION_DT in DATE,
  X_MIN_SUBMISSION_DT in DATE,
  X_RESEARCH_TOPIC in VARCHAR2,
  X_INDUSTRY_LINKS in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ORG_ID in NUMBER
  ) as
  cursor c1 is select rowid from IGS_RE_CANDIDATURE_ALL
     where PERSON_ID = X_PERSON_ID
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
     X_SEQUENCE_NUMBER,
     X_SCA_COURSE_CD,
     X_ACAI_ADMISSION_APPL_NUMBER,
     X_ACAI_NOMINATED_COURSE_CD,
     X_ACAI_SEQUENCE_NUMBER,
     X_ATTENDANCE_PERCENTAGE,
     X_GOVT_TYPE_OF_ACTIVITY_CD,
     X_MAX_SUBMISSION_DT,
     X_MIN_SUBMISSION_DT,
     X_RESEARCH_TOPIC,
     X_INDUSTRY_LINKS,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_SEQUENCE_NUMBER,
   X_SCA_COURSE_CD,
   X_ACAI_ADMISSION_APPL_NUMBER,
   X_ACAI_NOMINATED_COURSE_CD,
   X_ACAI_SEQUENCE_NUMBER,
   X_ATTENDANCE_PERCENTAGE,
   X_GOVT_TYPE_OF_ACTIVITY_CD,
   X_MAX_SUBMISSION_DT,
   X_MIN_SUBMISSION_DT,
   X_RESEARCH_TOPIC,
   X_INDUSTRY_LINKS,
   X_MODE );
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
  delete from IGS_RE_CANDIDATURE_ALL
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
end IGS_RE_CANDIDATURE_PKG;

/
