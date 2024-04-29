--------------------------------------------------------
--  DDL for Package Body IGS_AD_TRANSCRIPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_TRANSCRIPT_PKG" AS
/* $Header: IGSAI82B.pls 120.2 2005/10/01 21:47:23 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_transcript%RowType;
  new_references igs_ad_transcript%RowType;
  l_transcript_id  igs_ad_transcript.transcript_id%TYPE;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : ravi.s.sharma@oracle.com
  ||  Created On : 29-OCT-2004
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
 CURSOR check_issuedate(cp_education_id IN NUMBER,cp_date_of_issue IN DATE) IS
    SELECT 'A' FROM IGS_AD_TRANSCRIPT_V TRANS WHERE EDUCATION_ID = cp_education_id
    AND DATE_OF_ISSUE =  cp_date_of_issue
    AND (new_references.transcript_id IS NULL OR new_references.transcript_id <>  trans.transcript_id);
 l_temp VARCHAR2(1);

  BEGIN
   l_temp := NULL;
   OPEN check_issuedate(new_references.education_id,new_references.date_of_issue);
   FETCH check_issuedate INTO l_temp;
   CLOSE check_issuedate;
   IF l_temp IS NOT NULL THEN
      Fnd_Message.Set_Name('IGS','IGS_AD_DUP_DATE_OF_ISSUE');
      IGS_GE_MSG_STACK.ADD;
      app_Exception.Raise_Exception;
   END IF;

  END check_uniqueness;

  PROCEDURE Check_Status AS

  /*
  ||  Created By : jchin
  ||  Created On : 29-SEP-2005
  ||  Purpose : Check whether transcript is associated with an academic record
  ||  which is INACTIVE  If so, throw an error
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  CURSOR check_status(cp_education_id IN NUMBER) IS
    SELECT DISTINCT 1
    FROM igs_ad_acad_history_v hist
    WHERE hist.education_id = cp_education_id
    AND hist.status = 'I';

  l_temp NUMBER;

  BEGIN

   l_temp := NULL;

   OPEN check_status(new_references.education_id);
   FETCH check_status INTO l_temp;
   CLOSE check_status;

   IF l_temp IS NOT NULL THEN
      Fnd_Message.Set_Name('IGS','IGS_AD_INACTIVE_ACAD_HIST');
      IGS_GE_MSG_STACK.ADD;
      app_Exception.Raise_Exception;
   END IF;

  END Check_Status;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_quintile_rank IN NUMBER DEFAULT NULL,
    x_percentile_rank IN NUMBER DEFAULT NULL,
    x_transcript_id IN NUMBER DEFAULT NULL,
    x_education_id IN NUMBER DEFAULT NULL,
    x_transcript_status IN VARCHAR2 DEFAULT NULL,
    x_transcript_source IN NUMBER DEFAULT NULL,
    x_date_of_receipt IN DATE DEFAULT NULL,
    x_entered_gpa IN VARCHAR2 DEFAULT NULL,
    x_entered_gs_id IN NUMBER DEFAULT NULL,
    x_conv_gpa IN VARCHAR2 DEFAULT NULL,
    x_conv_gs_id IN NUMBER DEFAULT NULL,
    x_term_type IN VARCHAR2 DEFAULT NULL,
    x_rank_in_class IN NUMBER DEFAULT NULL,
    x_class_size IN NUMBER DEFAULT NULL,
    x_approximate_rank IN VARCHAR2 DEFAULT NULL,
    x_weighted_rank IN VARCHAR2 DEFAULT NULL,
    x_decile_rank IN NUMBER DEFAULT NULL,
    x_quartile_rank IN NUMBER DEFAULT NULL,
    x_transcript_type  IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_override IN VARCHAR2 DEFAULT NULL,
    x_override_id IN NUMBER DEFAULT NULL,
    x_override_date IN DATE DEFAULT NULL,
       X_DATE_OF_ISSUE IN DATE DEFAULT NULL,
--   Added for new field   Ravishar / 14-sep-2004
    x_CORE_CURRICULUM_VALUE IN VARCHAR2 DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)

  vdixit.in	      23-JULY-2001      Added new column transcript_type
					to the tbh calls
 rboddu               12-NOV-2001       Added new columns oevrride,
                                         override_id and override_date.
                                        End Bug No : 2097333
***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_TRANSCRIPT
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
    new_references.quintile_rank := x_quintile_rank;
    new_references.percentile_rank := x_percentile_rank;
    new_references.transcript_id := x_transcript_id;
    new_references.education_id := x_education_id;
    new_references.transcript_status := x_transcript_status;
    new_references.transcript_source := x_transcript_source;
    new_references.date_of_receipt := TRUNC(x_date_of_receipt);
    new_references.entered_gpa := x_entered_gpa;
    new_references.entered_gs_id := x_entered_gs_id;
    new_references.conv_gpa := x_conv_gpa;
    new_references.conv_gs_id := x_conv_gs_id;
    new_references.term_type := x_term_type;
    new_references.rank_in_class := x_rank_in_class;
    new_references.class_size := x_class_size;
    new_references.approximate_rank := x_approximate_rank;
    new_references.weighted_rank := x_weighted_rank;
    new_references.decile_rank := x_decile_rank;
    new_references.quartile_rank := x_quartile_rank;
    new_references.transcript_type := x_transcript_type;
    new_references.override := x_override;
    new_references.override_id := x_override_id;
    new_references.override_date := TRUNC(x_override_Date);
    new_references.date_of_issue := TRUNC(x_date_of_issue);
--   Added for new field   Ravishar / 14-sep-2004
    new_references.core_curriculum_value := x_core_curriculum_value;


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
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  vdixit.in	      23-JULY-2001      Added new column transcript_type
					to the tbh calls
  rboddu              12-NOV-2001        Added the new columns override,
                                         override_id and override_date
                                         Bug No : 2097333
  kamohan	      30-NOV-2001	Added the check for date of
					issue column
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'PERCENTILE_RANK'  THEN
        new_references.percentile_rank := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'QUARTILE_RANK'  THEN
        new_references.quartile_rank := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'QUINTILE_RANK'  THEN
        new_references.quintile_rank := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'DECILE_RANK'  THEN
        new_references.decile_rank := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'APPROXIMATE_RANK'  THEN
        new_references.approximate_rank := column_value;
      ELSIF  UPPER(column_name) = 'WEIGHTED_RANK'  THEN
        new_references.weighted_rank := column_value;
      ELSIF  UPPER(column_name) = 'RANK_IN_CLASS'  THEN
        new_references.rank_in_class := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'CLASS_SIZE'  THEN
        new_references.class_size := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'TRANSCRIPT_TYPE'  THEN
        new_references.transcript_type := column_value;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'PERCENTILE_RANK' OR
      	Column_Name IS NULL THEN
        IF NOT ( (new_references.percentile_rank >= 0) AND (new_references.percentile_rank <= 100) )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERCENTILE_RANK'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'QUARTILE_RANK' OR
      	Column_Name IS NULL THEN
        IF NOT ( (new_references.quartile_rank >0) AND (new_references.quartile_rank <= 4)  )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_QUARTILE_RANK'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'QUINTILE_RANK' OR
      	Column_Name IS NULL THEN
        IF NOT ( (new_references.quintile_rank > 0)  AND (new_references.quintile_rank <= 5) )   THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_QUINTILE_RANK'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'DECILE_RANK' OR
      	Column_Name IS NULL THEN
        IF NOT ( (new_references.decile_rank > 0)  AND (new_references.decile_rank <= 10)  ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DECILE_RANK'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'APPROXIMATE_RANK' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.approximate_rank in ('Y','N'))  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPROXIMATE_RANK'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'WEIGHTED_RANK' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.weighted_rank in ('Y','N'))  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_WEIGHTED_RANK'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'RANK_IN_CLASS' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.rank_in_class > 0)  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_SS_DSRD_RANK_NONEGATE');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'CLASS_SIZE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.class_size > 0)  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_AD_CLASS_SIZE');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF Upper(Column_Name) = 'TRANSCRIPT_TYPE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.transcript_type in ('OFFICIAL','UNOFFICIAL'))  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TRANSCRIPT_TYPE'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'OVERRIDE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.override in ('Y','N'))  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_OVERRIDE'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'DATE_OF_ISSUE' OR
      	Column_Name IS NULL THEN
        IF (new_references.date_of_issue > SYSDATE )  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_SYS_DATOFISSUE');
	   IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
	END IF;
	IF (new_references.date_of_issue > new_references.date_of_receipt )  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_INV_DATOFISSUE');
	   IGS_GE_MSG_STACK.ADD;
	   app_Exception.Raise_Exception;
	END IF;
      END IF;
  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
 /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  vdixit.in	      23-JULY-2001      Added new column transcript_type
					to the tbh calls

  ***************************************************************/

  BEGIN

    IF (((old_references.education_id = new_references.education_id)) OR
        ((new_references.education_id IS NULL))) THEN
      NULL;

/*    ELSIF NOT Igs_Ad_Acad_History_Pkg.Get_PK_For_Validation (
        		new_references.education_id
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;*/ -- not needed after TCA changes
    END IF;

    IF (((old_references.conv_gs_id = new_references.conv_gs_id)) OR
        ((new_references.conv_gs_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_uk2_For_Validation (
        		new_references.conv_gs_id,
                        'GRADING_SCALE_TYPES',
                        'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CONV_GRAD_SCALE'));
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.transcript_source = new_references.transcript_source)) OR
        ((new_references.transcript_source IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.transcript_source,
                        'TRANSCRIPT_SOURCE',
                        'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TRANSCRIPT_SOURCE'));
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.entered_gs_id = new_references.entered_gs_id)) OR
        ((new_references.entered_gs_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_uk2_For_Validation (
        		new_references.entered_gs_id,
                        'GRADING_SCALE_TYPES',
                        'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENTERED_GRAD_SCALE'));
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.term_type = new_references.term_type)) OR
        ((new_references.term_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_LookUps_View_Pkg.Get_PK_For_Validation (
                       'TERM_TYPE',
        		new_references.term_type
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TERM_TYPE'));
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

        IF (((old_references.transcript_status = new_references.transcript_status)) OR
        ((new_references.transcript_status IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_LookUps_View_Pkg.Get_PK_For_Validation (
                       'TRANSCRIPT_STATUS',
        		new_references.transcript_status
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TRANSCRIPT_STATUS'));
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;


   IF (((old_references.transcript_type = new_references.transcript_type)) OR
       ((new_references.transcript_type IS NULL))) THEN
         NULL;
   ELSIF NOT Igs_LookUps_View_Pkg.Get_PK_For_Validation (
                       'TRANSCRIPT_TYPE',
        		new_references.transcript_type
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TRANSCRIPT_TYPE'));
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
 /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Ad_Term_Details_Pkg.Get_FK_Igs_Ad_Transcript (
      old_references.transcript_id
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_transcript_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_transcript
      WHERE    transcript_id = x_transcript_id
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

  PROCEDURE Get_FK_Igs_Ad_Hz_Acad_History (
    x_education_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_transcript
      WHERE    education_id = x_education_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATRN_AAHST_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Hz_Acad_History;


  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_transcript
      WHERE    conv_gs_id = x_code_id ;

    lv_rowid cur_rowid%RowType;

    CURSOR cur_rowid2 IS
      SELECT   rowid
      FROM     igs_ad_transcript
      WHERE    transcript_source = x_code_id ;

    lv_rowid2 cur_rowid2%RowType;

    CURSOR cur_rowid3 IS
      SELECT   rowid
      FROM     igs_ad_transcript
      WHERE    entered_gs_id = x_code_id ;

    lv_rowid3 cur_rowid3%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATRN_ACDC_FK1');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
    Open cur_rowid2;
    Fetch cur_rowid2 INTO lv_rowid2;
    IF (cur_rowid2%FOUND) THEN
      Close cur_rowid2;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATRN_ACDC_FK3');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid2;
    Open cur_rowid3;
    Fetch cur_rowid3 INTO lv_rowid3;
    IF (cur_rowid3%FOUND) THEN
      Close cur_rowid3;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATRN_ACDC_FK2');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid3;
  END Get_FK_Igs_Ad_Code_Classes;



  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_quintile_rank IN NUMBER DEFAULT NULL,
    x_percentile_rank IN NUMBER DEFAULT NULL,
    x_transcript_id IN NUMBER DEFAULT NULL,
    x_education_id IN NUMBER DEFAULT NULL,
    x_transcript_status IN VARCHAR2 DEFAULT NULL,
    x_transcript_source IN NUMBER DEFAULT NULL,
    x_date_of_receipt IN DATE DEFAULT NULL,
    x_entered_gpa IN VARCHAR2 DEFAULT NULL,
    x_entered_gs_id IN NUMBER DEFAULT NULL,
    x_conv_gpa IN VARCHAR2 DEFAULT NULL,
    x_conv_gs_id IN NUMBER DEFAULT NULL,
    x_term_type IN VARCHAR2 DEFAULT NULL,
    x_rank_in_class IN NUMBER DEFAULT NULL,
    x_class_size IN NUMBER DEFAULT NULL,
    x_approximate_rank IN VARCHAR2 DEFAULT NULL,
    x_weighted_rank IN VARCHAR2 DEFAULT NULL,
    x_decile_rank IN NUMBER DEFAULT NULL,
    x_quartile_rank IN NUMBER DEFAULT NULL,
    x_transcript_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_override IN VARCHAR2 DEFAULT NULL,
    x_override_id IN NUMBER DEFAULT NULL,
    x_override_date IN DATE DEFAULT NULL,
       X_DATE_OF_ISSUE IN DATE DEFAULT NULL,
--   Added for new field   Ravishar / 14-sep-2004
    x_CORE_CURRICULUM_VALUE IN VARCHAR2 DEFAULT NULL

  ) AS
 /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  vdixit.in	      23-JULY-2001      Added new column transcript_type
					to the tbh calls
   rboddu              12-NOV-2001        Added the new columns override,
                                         override_id and override_date
                                          Bug No: 2097333
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_quintile_rank,
      x_percentile_rank,
      x_transcript_id,
      x_education_id,
      x_transcript_status,
      x_transcript_source,
      x_date_of_receipt,
      x_entered_gpa,
      x_entered_gs_id,
      x_conv_gpa,
      x_conv_gs_id,
      x_term_type,
      x_rank_in_class,
      x_class_size,
      x_approximate_rank,
      x_weighted_rank,
      x_decile_rank,
      x_quartile_rank,
      x_transcript_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_override,
      x_override_id,
      x_override_date,
      x_date_of_issue,
--   Added for new field   Ravishar / 14-sep-2004
     x_core_curriculum_value
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		 new_references.transcript_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
               IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Parent_Existance;
      check_uniqueness;
      Check_Status;   --jchin Bug 4629226
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Parent_Existance;
      check_uniqueness;
      Check_Status;    --jchin Bug 4629226
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.transcript_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
               IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c_person_id( p_education_id  hz_education.education_id%TYPE)  IS
    SELECT party_id  person_id
    FROM HZ_EDUCATION
    WHERE education_id = p_education_id;
    person_id_rec   c_person_id%ROWTYPE;
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
       IF IGS_AD_TRANSCRIPT_PKG.TRN_CRT_MODE = 'NI'  THEN
         OPEN c_person_id(new_references.education_id);
         FETCH c_person_id INTO person_id_rec;
         CLOSE c_person_id;
           igs_ad_wf_001.transcript_entrd_event(
           person_id_rec.person_id,
           new_references.education_id,
           l_transcript_id
             );
        END IF;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update. desc
      --Raise the buisness event
       OPEN c_person_id(new_references.education_id);
       FETCH c_person_id INTO person_id_rec;
       CLOSE c_person_id;

      igs_ad_wf_001.TRANSCRIPT_UPD_EVENT
      (
      P_TRANSCRIPT_ID			=>   new_references.transcript_id,
      P_EDUCATION_ID			=>   new_references.education_id,
      P_PERSON_ID			=>   person_id_rec.person_id,
      P_TRANSCRIPT_STATUS_OLD		=>   old_references.transcript_status,
      P_TRANSCRIPT_STATUS_NEW		=>   new_references.transcript_status,
      P_TRANSCRIPT_TYPE_OLD		=>   old_references.transcript_type,
      P_TRANSCRIPT_TYPE_NEW		=>   new_references.transcript_type
      );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_QUINTILE_RANK IN NUMBER,
       x_PERCENTILE_RANK IN NUMBER,
       x_TRANSCRIPT_ID IN OUT NOCOPY NUMBER,
       x_EDUCATION_ID IN NUMBER,
       x_TRANSCRIPT_STATUS IN VARCHAR2,
       x_TRANSCRIPT_SOURCE IN NUMBER,
       x_DATE_OF_RECEIPT IN DATE,
       x_ENTERED_GPA IN VARCHAR2,
       x_ENTERED_GS_ID IN NUMBER,
       x_CONV_GPA IN VARCHAR2,
       x_CONV_GS_ID IN NUMBER,
       x_TERM_TYPE IN VARCHAR2,
       x_RANK_IN_CLASS IN NUMBER,
       x_CLASS_SIZE IN NUMBER,
       x_APPROXIMATE_RANK IN VARCHAR2,
       x_WEIGHTED_RANK IN VARCHAR2,
       x_DECILE_RANK IN NUMBER,
       x_QUARTILE_RANK IN NUMBER,
       x_TRANSCRIPT_TYPE IN VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 DEFAULT NULL,
       x_OVERRIDE IN VARCHAR2 DEFAULT NULL,
       x_OVERRIDE_ID IN NUMBER DEFAULT NULL,
       x_OVERRIDE_DATE IN DATE DEFAULT NULL,
       X_DATE_OF_ISSUE IN DATE DEFAULT NULL,
--     Added for new field   Ravishar / 14-sep-2004
       x_CORE_CURRICULUM_VALUE IN VARCHAR2 DEFAULT NULL

  ) AS
  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  vdixit.in	      23-JULY-2001      Added new column transcript_type
					to the tbh calls
  rboddu              12-NOV-2001        Added the new columns override,
                                         override_id and override_date
                                         Bug No : 2097333
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_TRANSCRIPT
             where                 TRANSCRIPT_ID= X_TRANSCRIPT_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;

     L_MODE  VARCHAR2(1);
 begin

    L_MODE := NVL(X_MODE,'R');
    X_LAST_UPDATE_DATE := SYSDATE;
    if(L_MODE = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    elsif (L_MODE IN ('R','S')) then
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
--   X_TRANSCRIPT_ID := -1;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_quintile_rank=>X_QUINTILE_RANK,
 	       x_percentile_rank=>X_PERCENTILE_RANK,
 	       x_transcript_id=>X_TRANSCRIPT_ID,
 	       x_education_id=>X_EDUCATION_ID,
 	       x_transcript_status=>X_TRANSCRIPT_STATUS,
 	       x_transcript_source=>X_TRANSCRIPT_SOURCE,
 	       x_date_of_receipt=>X_DATE_OF_RECEIPT,
 	       x_entered_gpa=>X_ENTERED_GPA,
 	       x_entered_gs_id=>X_ENTERED_GS_ID,
 	       x_conv_gpa=>X_CONV_GPA,
 	       x_conv_gs_id=>X_CONV_GS_ID,
 	       x_term_type=>X_TERM_TYPE,
 	       x_rank_in_class=>X_RANK_IN_CLASS,
 	       x_class_size=>X_CLASS_SIZE,
 	       x_approximate_rank=>X_APPROXIMATE_RANK,
 	       x_weighted_rank=>X_WEIGHTED_RANK,
 	       x_decile_rank=>X_DECILE_RANK,
 	       x_quartile_rank=>X_QUARTILE_RANK,
      	       x_transcript_type=>X_TRANSCRIPT_TYPE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_override=>X_OVERRIDE,
               x_override_id=>X_OVERRIDE_ID,
               x_override_date=>X_OVERRIDE_DATE,
	       x_date_of_issue => x_date_of_issue,
       --   Added for new field   Ravishar / 14-sep-2004
               x_core_curriculum_value => X_CORE_CURRICULUM_VALUE
);

     IF X_TRANSCRIPT_ID IS NOT NULL THEN
      L_TRANSCRIPT_ID:= X_TRANSCRIPT_ID;
     ELSE
      SELECT IGS_AD_TRANSCRIPT_S.NEXTVAL INTO L_TRANSCRIPT_ID FROM DUAL;
     END IF;

      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_AD_TRANSCRIPT (
		QUINTILE_RANK
		,PERCENTILE_RANK
		,TRANSCRIPT_ID
		,EDUCATION_ID
		,TRANSCRIPT_STATUS
		,TRANSCRIPT_SOURCE
		,DATE_OF_RECEIPT
		,ENTERED_GPA
		,ENTERED_GS_ID
		,CONV_GPA
		,CONV_GS_ID
		,TERM_TYPE
		,RANK_IN_CLASS
		,CLASS_SIZE
		,APPROXIMATE_RANK
		,WEIGHTED_RANK
		,DECILE_RANK
		,QUARTILE_RANK
 	        ,TRANSCRIPT_TYPE
                ,OVERRIDE
                ,OVERRIDE_ID
                ,OVERRIDE_DATE
		,DATE_OF_ISSUE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,REQUEST_ID
		,PROGRAM_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_UPDATE_DATE,
       --   Added for new field   Ravishar / 14-sep-2004
                core_curriculum_value

        ) values  (
	        NEW_REFERENCES.QUINTILE_RANK
	        ,NEW_REFERENCES.PERCENTILE_RANK
	        ,L_TRANSCRIPT_ID --IGS_AD_TRANSCRIPT_S.NEXTVAL
	        ,NEW_REFERENCES.EDUCATION_ID
	        ,NEW_REFERENCES.TRANSCRIPT_STATUS
	        ,NEW_REFERENCES.TRANSCRIPT_SOURCE
	        ,NEW_REFERENCES.DATE_OF_RECEIPT
	        ,NEW_REFERENCES.ENTERED_GPA
	        ,NEW_REFERENCES.ENTERED_GS_ID
	        ,NEW_REFERENCES.CONV_GPA
	        ,NEW_REFERENCES.CONV_GS_ID
	        ,NEW_REFERENCES.TERM_TYPE
	        ,NEW_REFERENCES.RANK_IN_CLASS
	        ,NEW_REFERENCES.CLASS_SIZE
	        ,NEW_REFERENCES.APPROXIMATE_RANK
	        ,NEW_REFERENCES.WEIGHTED_RANK
	        ,NEW_REFERENCES.DECILE_RANK
	        ,NEW_REFERENCES.QUARTILE_RANK
       	        ,NEW_REFERENCES.TRANSCRIPT_TYPE
                ,NEW_REFERENCES.OVERRIDE
                ,NEW_REFERENCES.OVERRIDE_ID
                ,NEW_REFERENCES.OVERRIDE_DATE
		,NEW_REFERENCES.DATE_OF_ISSUE
	        ,X_LAST_UPDATE_DATE
	        ,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,X_REQUEST_ID
		,X_PROGRAM_ID
		,X_PROGRAM_APPLICATION_ID
		,X_PROGRAM_UPDATE_DATE
        --   Added for new field   Ravishar / 14-sep-2004
                ,NEW_REFERENCES.CORE_CURRICULUM_VALUE

)RETURNING TRANSCRIPT_ID INTO X_TRANSCRIPT_ID;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

  l_transcript_id := X_TRANSCRIPT_ID;
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
      X_ROWID in  VARCHAR2,
       x_QUINTILE_RANK IN NUMBER,
       x_PERCENTILE_RANK IN NUMBER,
       x_TRANSCRIPT_ID IN NUMBER,
       x_EDUCATION_ID IN NUMBER,
       x_TRANSCRIPT_STATUS IN VARCHAR2,
       x_TRANSCRIPT_SOURCE IN NUMBER,
       x_DATE_OF_RECEIPT IN DATE,
       x_ENTERED_GPA IN VARCHAR2,
       x_ENTERED_GS_ID IN NUMBER,
       x_CONV_GPA IN VARCHAR2,
       x_CONV_GS_ID IN NUMBER,
       x_TERM_TYPE IN VARCHAR2,
       x_RANK_IN_CLASS IN NUMBER,
       x_CLASS_SIZE IN NUMBER,
       x_APPROXIMATE_RANK IN VARCHAR2,
       x_WEIGHTED_RANK IN VARCHAR2,
       x_DECILE_RANK IN NUMBER,
       x_QUARTILE_RANK IN NUMBER ,
       x_TRANSCRIPT_TYPE IN VARCHAR2,
       x_OVERRIDE IN VARCHAR2 DEFAULT NULL,
       x_OVERRIDE_ID IN NUMBER DEFAULT NULL,
       x_OVERRIDE_DATE IN DATE DEFAULT NULL,
       X_DATE_OF_ISSUE IN DATE DEFAULT NULL,
--   Added for new field   Ravishar / 14-sep-2004
    x_CORE_CURRICULUM_VALUE IN VARCHAR2 DEFAULT NULL
       ) AS
  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  vdixit.in	      23-JULY-2001      Added new column transcript_type
					to the tbh calls
  rboddu              12-NOV-2001        Added the new columns override,
                                         override_id and override_date
                                         Bug No : 2097333

  ***************************************************************/

   cursor c1 is select
      QUINTILE_RANK
,      PERCENTILE_RANK
,      EDUCATION_ID
,      TRANSCRIPT_STATUS
,      TRANSCRIPT_SOURCE
,      DATE_OF_RECEIPT
,      ENTERED_GPA
,      ENTERED_GS_ID
,      CONV_GPA
,      CONV_GS_ID
,      TERM_TYPE
,      RANK_IN_CLASS
,      CLASS_SIZE
,      APPROXIMATE_RANK
,      WEIGHTED_RANK
,      DECILE_RANK
,      QUARTILE_RANK
,      TRANSCRIPT_TYPE
,      OVERRIDE
,      OVERRIDE_ID
,      OVERRIDE_DATE
,      DATE_OF_ISSUE
--   Added for new field   Ravishar / 14-sep-2004
,      CORE_CURRICULUM_VALUE

    from IGS_AD_TRANSCRIPT
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
if ( (  (tlinfo.QUINTILE_RANK = X_QUINTILE_RANK)
 	    OR ((tlinfo.QUINTILE_RANK is null)
		AND (X_QUINTILE_RANK is null)))
  AND ((tlinfo.PERCENTILE_RANK = X_PERCENTILE_RANK)
 	    OR ((tlinfo.PERCENTILE_RANK is null)
		AND (X_PERCENTILE_RANK is null)))
  AND (tlinfo.EDUCATION_ID = X_EDUCATION_ID)
  AND (tlinfo.TRANSCRIPT_STATUS = X_TRANSCRIPT_STATUS)
  AND (tlinfo.TRANSCRIPT_SOURCE = X_TRANSCRIPT_SOURCE)
  AND ((TRUNC(tlinfo.DATE_OF_RECEIPT) = TRUNC(X_DATE_OF_RECEIPT))
 	    OR ((tlinfo.DATE_OF_RECEIPT is null)
		AND (X_DATE_OF_RECEIPT is null)))
  AND ((tlinfo.ENTERED_GPA = X_ENTERED_GPA)
 	    OR ((tlinfo.ENTERED_GPA is null)
		AND (X_ENTERED_GPA is null)))
  AND (tlinfo.ENTERED_GS_ID = X_ENTERED_GS_ID)
  AND ((tlinfo.CONV_GPA = X_CONV_GPA)
 	    OR ((tlinfo.CONV_GPA is null)
		AND (X_CONV_GPA is null)))
  AND (tlinfo.CONV_GS_ID = X_CONV_GS_ID)
  AND (tlinfo.TERM_TYPE = X_TERM_TYPE)
  AND ((tlinfo.RANK_IN_CLASS = X_RANK_IN_CLASS)
 	    OR ((tlinfo.RANK_IN_CLASS is null)
		AND (X_RANK_IN_CLASS is null)))
  AND ((tlinfo.CLASS_SIZE = X_CLASS_SIZE)
 	    OR ((tlinfo.CLASS_SIZE is null)
		AND (X_CLASS_SIZE is null)))
  AND ((tlinfo.APPROXIMATE_RANK = X_APPROXIMATE_RANK)
 	    OR ((tlinfo.APPROXIMATE_RANK is null)
		AND (X_APPROXIMATE_RANK is null)))
  AND ((tlinfo.WEIGHTED_RANK = X_WEIGHTED_RANK)
 	    OR ((tlinfo.WEIGHTED_RANK is null)
		AND (X_WEIGHTED_RANK is null)))
  AND ((tlinfo.DECILE_RANK = X_DECILE_RANK)
 	    OR ((tlinfo.DECILE_RANK is null)
		AND (X_DECILE_RANK is null)))
  AND ((tlinfo.QUARTILE_RANK = X_QUARTILE_RANK)
 	    OR ((tlinfo.QUARTILE_RANK is null)
		AND (X_QUARTILE_RANK is null)))
  AND (tlinfo.TRANSCRIPT_TYPE = X_TRANSCRIPT_TYPE)
  )
  AND ((tlinfo.OVERRIDE = X_OVERRIDE)
            OR ((tlinfo.OVERRIDE is null)
                AND (X_OVERRIDE is null)))
  AND ((tlinfo.OVERRIDE_ID = X_OVERRIDE_ID)
            OR ((tlinfo.OVERRIDE_ID is null)
                AND (X_OVERRIDE_ID is null)))
  AND ((TRUNC(tlinfo.OVERRIDE_DATE) = TRUNC(X_OVERRIDE_DATE))
            OR ((tlinfo.OVERRIDE_DATE is null)
                AND (X_OVERRIDE_DATE is null)))
  AND ((TRUNC(tlinfo.DATE_OF_ISSUE) = TRUNC(X_DATE_OF_ISSUE))
            OR ((tlinfo.DATE_OF_ISSUE is null)
                AND (X_DATE_OF_ISSUE is null)))
--   Added for new field   Ravishar / 14-sep-2004
  AND ((tlinfo.CORE_CURRICULUM_VALUE = X_CORE_CURRICULUM_VALUE)
            OR ((tlinfo.CORE_CURRICULUM_VALUE is null)
                AND (X_CORE_CURRICULUM_VALUE is null)))
  then null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_QUINTILE_RANK IN NUMBER,
       x_PERCENTILE_RANK IN NUMBER,
       x_TRANSCRIPT_ID IN NUMBER,
       x_EDUCATION_ID IN NUMBER,
       x_TRANSCRIPT_STATUS IN VARCHAR2,
       x_TRANSCRIPT_SOURCE IN NUMBER,
       x_DATE_OF_RECEIPT IN DATE,
       x_ENTERED_GPA IN VARCHAR2,
       x_ENTERED_GS_ID IN NUMBER,
       x_CONV_GPA IN VARCHAR2,
       x_CONV_GS_ID IN NUMBER,
       x_TERM_TYPE IN VARCHAR2,
       x_RANK_IN_CLASS IN NUMBER,
       x_CLASS_SIZE IN NUMBER,
       x_APPROXIMATE_RANK IN VARCHAR2,
       x_WEIGHTED_RANK IN VARCHAR2,
       x_DECILE_RANK IN NUMBER,
       x_QUARTILE_RANK IN NUMBER,
       x_TRANSCRIPT_TYPE IN VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 DEFAULT NULL,
       x_OVERRIDE IN VARCHAR2 DEFAULT NULL,
       x_OVERRIDE_ID IN NUMBER DEFAULT NULL,
       x_OVERRIDE_DATE IN DATE DEFAULT NULL,
       X_DATE_OF_ISSUE IN DATE DEFAULT NULL,
--   Added for new field   Ravishar / 14-sep-2004
       x_CORE_CURRICULUM_VALUE IN VARCHAR2 DEFAULT NULL
  ) AS
 /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  vdixit.in	      23-JULY-2001      Added new column transcript_type
					to the tbh calls
  rboddu              12-NOV-2001        Added the new columns override,
                                         override_id and override_date
                                         Bug No : 2097333
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
     L_MODE VARCHAR2(1);
 begin

   L_MODE := NVL(X_MODE, 'R');

    X_LAST_UPDATE_DATE := SYSDATE;
    if(L_MODE = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    elsif (L_MODE IN ('R','S')) then
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
 	       x_quintile_rank=>X_QUINTILE_RANK,
 	       x_percentile_rank=>X_PERCENTILE_RANK,
 	       x_transcript_id=>X_TRANSCRIPT_ID,
 	       x_education_id=>X_EDUCATION_ID,
 	       x_transcript_status=>X_TRANSCRIPT_STATUS,
 	       x_transcript_source=>X_TRANSCRIPT_SOURCE,
 	       x_date_of_receipt=>X_DATE_OF_RECEIPT,
 	       x_entered_gpa=>X_ENTERED_GPA,
 	       x_entered_gs_id=>X_ENTERED_GS_ID,
 	       x_conv_gpa=>X_CONV_GPA,
 	       x_conv_gs_id=>X_CONV_GS_ID,
 	       x_term_type=>X_TERM_TYPE,
 	       x_rank_in_class=>X_RANK_IN_CLASS,
 	       x_class_size=>X_CLASS_SIZE,
 	       x_approximate_rank=>X_APPROXIMATE_RANK,
 	       x_weighted_rank=>X_WEIGHTED_RANK,
 	       x_decile_rank=>X_DECILE_RANK,
 	       x_quartile_rank=>X_QUARTILE_RANK,
 	       x_transcript_type=>X_TRANSCRIPT_TYPE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_override=>X_OVERRIDE,
               x_override_id=>X_OVERRIDE_ID,
               x_override_date=>X_OVERRIDE_DATE,
	       x_date_of_issue => x_date_of_issue,
       --   Added for new field   Ravishar / 14-sep-2004
               x_core_curriculum_value => X_CORE_CURRICULUM_VALUE
             );

    if (L_MODE IN ('R','S')) then
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

    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_AD_TRANSCRIPT set
      QUINTILE_RANK =  NEW_REFERENCES.QUINTILE_RANK,
      PERCENTILE_RANK =  NEW_REFERENCES.PERCENTILE_RANK,
      EDUCATION_ID =  NEW_REFERENCES.EDUCATION_ID,
      TRANSCRIPT_STATUS =  NEW_REFERENCES.TRANSCRIPT_STATUS,
      TRANSCRIPT_SOURCE =  NEW_REFERENCES.TRANSCRIPT_SOURCE,
      DATE_OF_RECEIPT =  NEW_REFERENCES.DATE_OF_RECEIPT,
      ENTERED_GPA =  NEW_REFERENCES.ENTERED_GPA,
      ENTERED_GS_ID =  NEW_REFERENCES.ENTERED_GS_ID,
      CONV_GPA =  NEW_REFERENCES.CONV_GPA,
      CONV_GS_ID =  NEW_REFERENCES.CONV_GS_ID,
      TERM_TYPE =  NEW_REFERENCES.TERM_TYPE,
      RANK_IN_CLASS =  NEW_REFERENCES.RANK_IN_CLASS,
      CLASS_SIZE =  NEW_REFERENCES.CLASS_SIZE,
      APPROXIMATE_RANK =  NEW_REFERENCES.APPROXIMATE_RANK,
      WEIGHTED_RANK =  NEW_REFERENCES.WEIGHTED_RANK,
      DECILE_RANK =  NEW_REFERENCES.DECILE_RANK,
      QUARTILE_RANK =  NEW_REFERENCES.QUARTILE_RANK,
      TRANSCRIPT_TYPE =  NEW_REFERENCES.TRANSCRIPT_TYPE,
      OVERRIDE = NEW_REFERENCES.OVERRIDE,
      OVERRIDE_ID = NEW_REFERENCES.OVERRIDE_ID,
      OVERRIDE_DATE = NEW_REFERENCES.OVERRIDE_DATE,
      DATE_OF_ISSUE = NEW_REFERENCES.DATE_OF_ISSUE,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
,	REQUEST_ID = X_REQUEST_ID,
	PROGRAM_ID = X_PROGRAM_ID,
	PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID,
	PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
       --   Added for new field   Ravishar / 14-sep-2004
        CORE_CURRICULUM_VALUE = X_CORE_CURRICULUM_VALUE
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

end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_QUINTILE_RANK IN NUMBER,
       x_PERCENTILE_RANK IN NUMBER,
       x_TRANSCRIPT_ID IN OUT NOCOPY NUMBER,
       x_EDUCATION_ID IN NUMBER,
       x_TRANSCRIPT_STATUS IN VARCHAR2,
       x_TRANSCRIPT_SOURCE IN NUMBER,
       x_DATE_OF_RECEIPT IN DATE,
       x_ENTERED_GPA IN VARCHAR2,
       x_ENTERED_GS_ID IN NUMBER,
       x_CONV_GPA IN VARCHAR2,
       x_CONV_GS_ID IN NUMBER,
       x_TERM_TYPE IN VARCHAR2,
       x_RANK_IN_CLASS IN NUMBER,
       x_CLASS_SIZE IN NUMBER,
       x_APPROXIMATE_RANK IN VARCHAR2,
       x_WEIGHTED_RANK IN VARCHAR2,
       x_DECILE_RANK IN NUMBER,
       x_QUARTILE_RANK IN NUMBER,
       x_TRANSCRIPT_TYPE IN VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 DEFAULT NULL,
       x_OVERRIDE IN VARCHAR2 DEFAULT NULL,
       x_OVERRIDE_ID IN NUMBER DEFAULT NULL,
       X_OVERRIDE_DATE IN DATE DEFAULT NULL,
       X_DATE_OF_ISSUE IN DATE DEFAULT NULL,
       --   Added for new field   Ravishar / 14-sep-2004
       X_CORE_CURRICULUM_VALUE IN VARCHAR2 DEFAULT NULL

  ) AS
  /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  vdixit.in	      23-JULY-2001      Added new column transcript_type
					to the tbh calls
  rboddu              10-NOV-2001       Added new columns override,
                                        override_id and override_Date
                                        Bug No: 2097333

  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_TRANSCRIPT
             where     TRANSCRIPT_ID= X_TRANSCRIPT_ID
;
   L_MODE VARCHAR2(1);
begin
    L_MODE := NVL(X_MODE, 'R');

	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_QUINTILE_RANK,
       X_PERCENTILE_RANK,
       X_TRANSCRIPT_ID,
       X_EDUCATION_ID,
       X_TRANSCRIPT_STATUS,
       X_TRANSCRIPT_SOURCE,
       X_DATE_OF_RECEIPT,
       X_ENTERED_GPA,
       X_ENTERED_GS_ID,
       X_CONV_GPA,
       X_CONV_GS_ID,
       X_TERM_TYPE,
       X_RANK_IN_CLASS,
       X_CLASS_SIZE,
       X_APPROXIMATE_RANK,
       X_WEIGHTED_RANK,
       X_DECILE_RANK,
       X_QUARTILE_RANK,
       X_TRANSCRIPT_TYPE,
      L_MODE,
       X_OVERRIDE,
       X_OVERRIDE_ID,
       X_OVERRIDE_DATE,
       X_DATE_OF_ISSUE,
       --   Added for new field   Ravishar / 14-sep-2004
       X_CORE_CURRICULUM_VALUE
       );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_QUINTILE_RANK,
       X_PERCENTILE_RANK,
       X_TRANSCRIPT_ID,
       X_EDUCATION_ID,
       X_TRANSCRIPT_STATUS,
       X_TRANSCRIPT_SOURCE,
       X_DATE_OF_RECEIPT,
       X_ENTERED_GPA,
       X_ENTERED_GS_ID,
       X_CONV_GPA,
       X_CONV_GS_ID,
       X_TERM_TYPE,
       X_RANK_IN_CLASS,
       X_CLASS_SIZE,
       X_APPROXIMATE_RANK,
       X_WEIGHTED_RANK,
       X_DECILE_RANK,
       X_QUARTILE_RANK,
       X_TRANSCRIPT_TYPE,
      L_MODE,
       X_OVERRIDE,
       X_OVERRIDE_ID,
       X_OVERRIDE_DATE,
       X_DATE_OF_ISSUE,
       --   Added for new field   Ravishar / 14-sep-2004
       X_CORE_CURRICULUM_VALUE
);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
 /*************************************************************
  Created By : Kamalakar N.
  Date Created By : 15/May/2000
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
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_AD_TRANSCRIPT
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
END igs_ad_transcript_pkg;

/
