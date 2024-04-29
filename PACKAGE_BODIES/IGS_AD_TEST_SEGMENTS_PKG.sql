--------------------------------------------------------
--  DDL for Package Body IGS_AD_TEST_SEGMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_TEST_SEGMENTS_PKG" AS
/* $Header: IGSAI78B.pls 120.1 2005/06/28 04:38:35 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_test_segments%RowType;
  new_references igs_ad_test_segments%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_min_score IN NUMBER DEFAULT NULL,
    x_max_score IN NUMBER DEFAULT NULL,
    x_include_in_comp_score IN VARCHAR2 DEFAULT NULL,
    x_score_ind IN VARCHAR2 DEFAULT NULL,
    x_percentile_ind IN VARCHAR2 DEFAULT NULL,
    x_national_percentile_ind IN VARCHAR2 DEFAULT NULL,
    x_state_percentile_ind IN VARCHAR2 DEFAULT NULL,
    x_percentile_year_rank_ind IN VARCHAR2 DEFAULT NULL,
    x_score_band_upper_ind IN VARCHAR2 DEFAULT NULL,
    x_score_band_lower_ind IN VARCHAR2 DEFAULT NULL,
    x_irregularity_code_ind IN VARCHAR2 DEFAULT NULL,
    x_test_segment_id IN NUMBER DEFAULT NULL,
    x_admission_test_type IN VARCHAR2 DEFAULT NULL,
    x_test_segment_name IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_segment_type IN VARCHAR2 DEFAULT NULL,
    x_segment_group IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_TEST_SEGMENTS
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
    new_references.min_score := x_min_score;
    new_references.max_score := x_max_score;
    new_references.include_in_comp_score := x_include_in_comp_score;
    new_references.score_ind := x_score_ind;
    new_references.percentile_ind := x_percentile_ind;
    new_references.national_percentile_ind := x_national_percentile_ind;
    new_references.state_percentile_ind := x_state_percentile_ind;
    new_references.percentile_year_rank_ind := x_percentile_year_rank_ind;
    new_references.score_band_upper_ind := x_score_band_upper_ind;
    new_references.score_band_lower_ind := x_score_band_lower_ind;
    new_references.irregularity_code_ind := x_irregularity_code_ind;
    new_references.test_segment_id := x_test_segment_id;
    new_references.admission_test_type := x_admission_test_type;
    new_references.test_segment_name := x_test_segment_name;
    new_references.description := x_description;
    new_references.closed_ind := x_closed_ind;
    new_references.segment_type := x_segment_type;
    new_references.segment_group := x_segment_group;
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
  Created By :samaresh.in
  Date Created By :15-May-2000
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
      ELSIF  UPPER(column_name) = 'PERCENTILE_YEAR_RANK_IND'  THEN
        new_references.percentile_year_rank_ind := column_value;
      ELSIF  UPPER(column_name) = 'PERCENTILE_IND'  THEN
        new_references.percentile_ind := column_value;
      ELSIF  UPPER(column_name) = 'SCORE_BAND_LOWER_IND'  THEN
        new_references.score_band_lower_ind := column_value;
      ELSIF  UPPER(column_name) = 'MIN_SCORE'  THEN
        new_references.min_score := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'INCLUDE_IN_COMP_SCORE'  THEN
        new_references.include_in_comp_score := column_value;
      ELSIF  UPPER(column_name) = 'STATE_PERCENTILE_IND'  THEN
        new_references.state_percentile_ind := column_value;
      ELSIF  UPPER(column_name) = 'IRREGULARITY_CODE_IND'  THEN
        new_references.irregularity_code_ind := column_value;
      ELSIF  UPPER(column_name) = 'SCORE_IND'  THEN
        new_references.score_ind := column_value;
      ELSIF  UPPER(column_name) = 'MAX_SCORE'  THEN
        new_references.max_score := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'NATIONAL_PERCENTILE_IND'  THEN
        new_references.national_percentile_ind := column_value;
      ELSIF  UPPER(column_name) = 'SCORE_BAND_UPPER_IND'  THEN
        new_references.score_band_upper_ind := column_value;
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

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'PERCENTILE_YEAR_RANK_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.percentile_year_rank_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'PERCENTILE_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.percentile_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'SCORE_BAND_LOWER_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.score_band_lower_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'MIN_SCORE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.min_score >= 0)  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'INCLUDE_IN_COMP_SCORE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.include_in_comp_score IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'STATE_PERCENTILE_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.state_percentile_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'IRREGULARITY_CODE_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.irregularity_code_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'SCORE_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.score_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'MAX_SCORE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.max_score >=0 and new_references.max_score > new_references.min_score)  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'NATIONAL_PERCENTILE_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.national_percentile_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'SCORE_BAND_UPPER_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.score_band_upper_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.admission_test_type
    		,new_references.test_segment_name
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;

      END IF;

      IF  new_references.segment_type = 'SCORE' THEN
          IF  Get_UK2_For_Validation (
                  new_references.admission_test_type,
                  new_references.segment_group
               ) THEN
     	  	   FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_UNIQUE_SEG_GRP');
            IGS_GE_MSG_STACK.ADD;
			         app_exception.raise_exception;
          END IF;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Ad_Tst_Rslt_Dtls_Pkg.Get_FK_Igs_Ad_Test_Segments (
      old_references.test_segment_id
      );

    Igs_Ad_Up_Header_Pkg.Get_FK_Igs_Ad_Test_Segments (
      old_references.test_segment_id
      );

  END Check_Child_Existance;

  PROCEDURE GET_FK_IGS_TEST_TYPE (
    x_admission_test_type IN VARCHAR2
    ) AS
  /***************************************************************
  Created By      :rboddu
  Date Created By :12-Oct-2001
  Purpose : When record is deleted from the master table IGS_AD_TEST_TYPE
            The corresponding detail IGS_AD_TEST_SEGMENTS are not checked
            for dependency. To implement the dependency check this procedure
            is added here and is being called from IGS_AD_TEST_TYPE_PKG.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TEST_SEGMENTS
      WHERE    admission_test_type = x_admission_test_type ;


    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ADTT_ADTS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;

    Close cur_rowid;

  END GET_FK_IGS_TEST_TYPE;

  FUNCTION Get_PK_For_Validation (
    x_test_segment_id IN NUMBER,
    x_closed_ind IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_test_segments
      WHERE    test_segment_id = x_test_segment_id AND
               closed_ind = NVL(x_closed_ind,closed_ind)
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
    x_admission_test_type IN VARCHAR2,
    x_test_segment_name IN VARCHAR2,
    x_closed_ind IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_test_segments
      WHERE    admission_test_type = x_admission_test_type
      AND      test_segment_name = x_test_segment_name 	AND
              ((l_rowid is null) or (rowid <> l_rowid)) AND
               closed_ind = NVL(x_closed_ind,closed_ind) ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
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
    x_admission_test_type IN VARCHAR2,
    x_segment_group IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_unique_rowid IS
      SELECT   rowid
      FROM     igs_ad_test_segments
      WHERE    admission_test_type = x_admission_test_type AND
               ((l_rowid is null) or (rowid <> l_rowid)) AND
               segment_group = x_segment_group AND
               segment_type = 'SCORE' ;

    lv_unique_rowid cur_unique_rowid%RowType;

  BEGIN

    Open cur_unique_rowid;
    Fetch cur_unique_rowid INTO lv_unique_rowid;
    IF (cur_unique_rowid%FOUND) THEN
      Close cur_unique_rowid;
        return (true);
        ELSE
       close cur_unique_rowid;
      return(false);
    END IF;
  END Get_UK2_For_Validation ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_min_score IN NUMBER DEFAULT NULL,
    x_max_score IN NUMBER DEFAULT NULL,
    x_include_in_comp_score IN VARCHAR2 DEFAULT NULL,
    x_score_ind IN VARCHAR2 DEFAULT NULL,
    x_percentile_ind IN VARCHAR2 DEFAULT NULL,
    x_national_percentile_ind IN VARCHAR2 DEFAULT NULL,
    x_state_percentile_ind IN VARCHAR2 DEFAULT NULL,
    x_percentile_year_rank_ind IN VARCHAR2 DEFAULT NULL,
    x_score_band_upper_ind IN VARCHAR2 DEFAULT NULL,
    x_score_band_lower_ind IN VARCHAR2 DEFAULT NULL,
    x_irregularity_code_ind IN VARCHAR2 DEFAULT NULL,
    x_test_segment_id IN NUMBER DEFAULT NULL,
    x_admission_test_type IN VARCHAR2 DEFAULT NULL,
    x_test_segment_name IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_segment_type IN VARCHAR2 DEFAULT NULL,
    x_segment_group IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
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
      x_min_score,
      x_max_score,
      x_include_in_comp_score,
      x_score_ind,
      x_percentile_ind,
      x_national_percentile_ind,
      x_state_percentile_ind,
      x_percentile_year_rank_ind,
      x_score_band_upper_ind,
      x_score_band_lower_ind,
      x_irregularity_code_ind,
      x_test_segment_id,
      x_admission_test_type,
      x_test_segment_name,
      x_description,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_segment_type,
      x_segment_group
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.test_segment_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.test_segment_id)  THEN
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
  Created By :samaresh.in
  Date Created By :15-May-2000
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
       x_MIN_SCORE IN NUMBER,
       x_MAX_SCORE IN NUMBER,
       x_INCLUDE_IN_COMP_SCORE IN VARCHAR2,
       x_SCORE_IND IN VARCHAR2,
       x_PERCENTILE_IND IN VARCHAR2,
       x_NATIONAL_PERCENTILE_IND IN VARCHAR2,
       x_STATE_PERCENTILE_IND IN VARCHAR2,
       x_PERCENTILE_YEAR_RANK_IND IN VARCHAR2,
       x_SCORE_BAND_UPPER_IND IN VARCHAR2,
       x_SCORE_BAND_LOWER_IND IN VARCHAR2,
       x_IRREGULARITY_CODE_IND IN VARCHAR2,
       x_TEST_SEGMENT_ID IN OUT NOCOPY NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       X_MODE in VARCHAR2,
       X_SEGMENT_TYPE IN VARCHAR2 ,
       X_SEGMENT_GROUP IN NUMBER
  ) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR c IS
      SELECT ROWID
      FROM IGS_AD_TEST_SEGMENTS
      WHERE TEST_SEGMENT_ID= X_TEST_SEGMENT_ID;

    X_LAST_UPDATE_DATE DATE ;
    X_LAST_UPDATED_BY NUMBER ;
    X_LAST_UPDATE_LOGIN NUMBER ;
    l_mode        VARCHAR2(1);

 BEGIN

    l_mode := NVL(x_mode, 'R');
    X_LAST_UPDATE_DATE := SYSDATE;

    IF(l_MODE = 'I') THEN
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (l_MODE IN ('R','S') ) then
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

   X_TEST_SEGMENT_ID := -1;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_min_score=>X_MIN_SCORE,
 	       x_max_score=>X_MAX_SCORE,
 	       x_include_in_comp_score=>NVL(X_INCLUDE_IN_COMP_SCORE,'N' ),
 	       x_score_ind=>NVL(X_SCORE_IND,'N' ),
 	       x_percentile_ind=>NVL(X_PERCENTILE_IND,'N' ),
 	       x_national_percentile_ind=>NVL(X_NATIONAL_PERCENTILE_IND,'N' ),
 	       x_state_percentile_ind=>NVL(X_STATE_PERCENTILE_IND,'N' ),
 	       x_percentile_year_rank_ind=>NVL(X_PERCENTILE_YEAR_RANK_IND,'N' ),
 	       x_score_band_upper_ind=>NVL(X_SCORE_BAND_UPPER_IND,'N' ),
 	       x_score_band_lower_ind=>NVL(X_SCORE_BAND_LOWER_IND,'N' ),
 	       x_irregularity_code_ind=>NVL(X_IRREGULARITY_CODE_IND,'N' ),
 	       x_test_segment_id=>X_TEST_SEGMENT_ID,
 	       x_admission_test_type=>X_ADMISSION_TEST_TYPE,
 	       x_test_segment_name=>X_TEST_SEGMENT_NAME,
 	       x_description=>X_DESCRIPTION,
 	       x_closed_ind=>NVL(X_CLOSED_IND,'N' ),
 	       x_creation_date=>X_LAST_UPDATE_DATE,
	        x_created_by=>X_LAST_UPDATED_BY,
	        x_last_update_date=>X_LAST_UPDATE_DATE,
	        x_last_updated_by=>X_LAST_UPDATED_BY,
	        x_last_update_login=>X_LAST_UPDATE_LOGIN,
         x_segment_type => x_segment_type,
         x_segment_group => x_segment_group);

      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO IGS_AD_TEST_SEGMENTS (
       		MIN_SCORE
      		,MAX_SCORE
    				,INCLUDE_IN_COMP_SCORE
    				,SCORE_IND
    				,PERCENTILE_IND
    				,NATIONAL_PERCENTILE_IND
    				,STATE_PERCENTILE_IND
    				,PERCENTILE_YEAR_RANK_IND
    				,SCORE_BAND_UPPER_IND
    				,SCORE_BAND_LOWER_IND
    				,IRREGULARITY_CODE_IND
    				,TEST_SEGMENT_ID
    				,ADMISSION_TEST_TYPE
    				,TEST_SEGMENT_NAME
    				,DESCRIPTION
    				,CLOSED_IND
	       ,CREATION_DATE
      		,CREATED_BY
      		,LAST_UPDATE_DATE
      		,LAST_UPDATED_BY
      		,LAST_UPDATE_LOGIN
        ,SEGMENT_TYPE
        ,SEGMENT_GROUP
        ) values  (
	       	NEW_REFERENCES.MIN_SCORE
	       ,NEW_REFERENCES.MAX_SCORE
	       ,NEW_REFERENCES.INCLUDE_IN_COMP_SCORE
	       ,NEW_REFERENCES.SCORE_IND
	       ,NEW_REFERENCES.PERCENTILE_IND
	       ,NEW_REFERENCES.NATIONAL_PERCENTILE_IND
	       ,NEW_REFERENCES.STATE_PERCENTILE_IND
	       ,NEW_REFERENCES.PERCENTILE_YEAR_RANK_IND
	       ,NEW_REFERENCES.SCORE_BAND_UPPER_IND
	       ,NEW_REFERENCES.SCORE_BAND_LOWER_IND
	       ,NEW_REFERENCES.IRREGULARITY_CODE_IND
	       ,IGS_AD_TEST_SEGMENTS_S.NEXTVAL
	       ,NEW_REFERENCES.ADMISSION_TEST_TYPE
	       ,NEW_REFERENCES.TEST_SEGMENT_NAME
	       ,NEW_REFERENCES.DESCRIPTION
	       ,NEW_REFERENCES.CLOSED_IND
	       ,X_LAST_UPDATE_DATE
      		,X_LAST_UPDATED_BY
      		,X_LAST_UPDATE_DATE
      		,X_LAST_UPDATED_BY
      		,X_LAST_UPDATE_LOGIN
        ,NEW_REFERENCES.SEGMENT_TYPE
        ,NEW_REFERENCES.SEGMENT_GROUP
      )RETURNING TEST_SEGMENT_ID INTO X_TEST_SEGMENT_ID;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  	OPEN c;
		 FETCH c INTO X_ROWID;

 		IF (c%NOTFOUND) THEN
   		CLOSE c;
     RAISE NO_DATA_FOUND;
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

end INSERT_ROW;


procedure LOCK_ROW (
       X_ROWID in  VARCHAR2,
       x_MIN_SCORE IN NUMBER,
       x_MAX_SCORE IN NUMBER,
       x_INCLUDE_IN_COMP_SCORE IN VARCHAR2,
       x_SCORE_IND IN VARCHAR2,
       x_PERCENTILE_IND IN VARCHAR2,
       x_NATIONAL_PERCENTILE_IND IN VARCHAR2,
       x_STATE_PERCENTILE_IND IN VARCHAR2,
       x_PERCENTILE_YEAR_RANK_IND IN VARCHAR2,
       x_SCORE_BAND_UPPER_IND IN VARCHAR2,
       x_SCORE_BAND_LOWER_IND IN VARCHAR2,
       x_IRREGULARITY_CODE_IND IN VARCHAR2,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       X_SEGMENT_TYPE IN VARCHAR2 ,
       X_SEGMENT_GROUP IN NUMBER   ) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
       MIN_SCORE
,      MAX_SCORE
,      INCLUDE_IN_COMP_SCORE
,      SCORE_IND
,      PERCENTILE_IND
,      NATIONAL_PERCENTILE_IND
,      STATE_PERCENTILE_IND
,      PERCENTILE_YEAR_RANK_IND
,      SCORE_BAND_UPPER_IND
,      SCORE_BAND_LOWER_IND
,      IRREGULARITY_CODE_IND
,      ADMISSION_TEST_TYPE
,      TEST_SEGMENT_NAME
,      DESCRIPTION
,      CLOSED_IND
,      SEGMENT_TYPE
,      SEGMENT_GROUP
    from IGS_AD_TEST_SEGMENTS
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
if (  (tlinfo.MIN_SCORE = X_MIN_SCORE)
  AND (tlinfo.MAX_SCORE = X_MAX_SCORE)
  AND (tlinfo.INCLUDE_IN_COMP_SCORE = X_INCLUDE_IN_COMP_SCORE)
  AND (tlinfo.SCORE_IND = X_SCORE_IND)
  AND (tlinfo.PERCENTILE_IND = X_PERCENTILE_IND)
  AND (tlinfo.NATIONAL_PERCENTILE_IND = X_NATIONAL_PERCENTILE_IND)
  AND (tlinfo.STATE_PERCENTILE_IND = X_STATE_PERCENTILE_IND)
  AND (tlinfo.PERCENTILE_YEAR_RANK_IND = X_PERCENTILE_YEAR_RANK_IND)
  AND (tlinfo.SCORE_BAND_UPPER_IND = X_SCORE_BAND_UPPER_IND)
  AND (tlinfo.SCORE_BAND_LOWER_IND = X_SCORE_BAND_LOWER_IND)
  AND (tlinfo.IRREGULARITY_CODE_IND = X_IRREGULARITY_CODE_IND)
  AND (tlinfo.ADMISSION_TEST_TYPE = X_ADMISSION_TEST_TYPE)
  AND (tlinfo.TEST_SEGMENT_NAME = X_TEST_SEGMENT_NAME)
  AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
  AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
  AND (tlinfo.SEGMENT_TYPE = X_SEGMENT_TYPE)
  AND (tlinfo.SEGMENT_GROUP = X_SEGMENT_GROUP)
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
       x_MIN_SCORE IN NUMBER,
       x_MAX_SCORE IN NUMBER,
       x_INCLUDE_IN_COMP_SCORE IN VARCHAR2,
       x_SCORE_IND IN VARCHAR2,
       x_PERCENTILE_IND IN VARCHAR2,
       x_NATIONAL_PERCENTILE_IND IN VARCHAR2,
       x_STATE_PERCENTILE_IND IN VARCHAR2,
       x_PERCENTILE_YEAR_RANK_IND IN VARCHAR2,
       x_SCORE_BAND_UPPER_IND IN VARCHAR2,
       x_SCORE_BAND_LOWER_IND IN VARCHAR2,
       x_IRREGULARITY_CODE_IND IN VARCHAR2,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       X_MODE in VARCHAR2,
       X_SEGMENT_TYPE IN VARCHAR2 ,
       X_SEGMENT_GROUP IN NUMBER
  ) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     l_mode        VARCHAR2(1);

begin
      l_mode := NVL(x_mode, 'R');
      X_LAST_UPDATE_DATE := SYSDATE;
      if(l_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (l_MODE IN ('R','S')) then
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
 	       x_min_score=>X_MIN_SCORE,
 	       x_max_score=>X_MAX_SCORE,
 	       x_include_in_comp_score=>NVL(X_INCLUDE_IN_COMP_SCORE,'N' ),
 	       x_score_ind=>NVL(X_SCORE_IND,'N' ),
 	       x_percentile_ind=>NVL(X_PERCENTILE_IND,'N' ),
 	       x_national_percentile_ind=>NVL(X_NATIONAL_PERCENTILE_IND,'N' ),
 	       x_state_percentile_ind=>NVL(X_STATE_PERCENTILE_IND,'N' ),
 	       x_percentile_year_rank_ind=>NVL(X_PERCENTILE_YEAR_RANK_IND,'N' ),
 	       x_score_band_upper_ind=>NVL(X_SCORE_BAND_UPPER_IND,'N' ),
 	       x_score_band_lower_ind=>NVL(X_SCORE_BAND_LOWER_IND,'N' ),
 	       x_irregularity_code_ind=>NVL(X_IRREGULARITY_CODE_IND,'N' ),
 	       x_test_segment_id=>X_TEST_SEGMENT_ID,
 	       x_admission_test_type=>X_ADMISSION_TEST_TYPE,
 	       x_test_segment_name=>X_TEST_SEGMENT_NAME,
 	       x_description=>X_DESCRIPTION,
 	       x_closed_ind=>NVL(X_CLOSED_IND,'N' ),
	        x_creation_date=>X_LAST_UPDATE_DATE,
	        x_created_by=>X_LAST_UPDATED_BY,
	        x_last_update_date=>X_LAST_UPDATE_DATE,
	        x_last_updated_by=>X_LAST_UPDATED_BY,
	        x_last_update_login=>X_LAST_UPDATE_LOGIN,
         x_segment_type=>X_SEGMENT_TYPE,
         x_segment_group=>X_SEGMENT_GROUP);

    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_AD_TEST_SEGMENTS set
      MIN_SCORE =  NEW_REFERENCES.MIN_SCORE,
      MAX_SCORE =  NEW_REFERENCES.MAX_SCORE,
      INCLUDE_IN_COMP_SCORE =  NEW_REFERENCES.INCLUDE_IN_COMP_SCORE,
      SCORE_IND =  NEW_REFERENCES.SCORE_IND,
      PERCENTILE_IND =  NEW_REFERENCES.PERCENTILE_IND,
      NATIONAL_PERCENTILE_IND =  NEW_REFERENCES.NATIONAL_PERCENTILE_IND,
      STATE_PERCENTILE_IND =  NEW_REFERENCES.STATE_PERCENTILE_IND,
      PERCENTILE_YEAR_RANK_IND =  NEW_REFERENCES.PERCENTILE_YEAR_RANK_IND,
      SCORE_BAND_UPPER_IND =  NEW_REFERENCES.SCORE_BAND_UPPER_IND,
      SCORE_BAND_LOWER_IND =  NEW_REFERENCES.SCORE_BAND_LOWER_IND,
      IRREGULARITY_CODE_IND =  NEW_REFERENCES.IRREGULARITY_CODE_IND,
      ADMISSION_TEST_TYPE =  NEW_REFERENCES.ADMISSION_TEST_TYPE,
      TEST_SEGMENT_NAME =  NEW_REFERENCES.TEST_SEGMENT_NAME,
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      CLOSED_IND =  NEW_REFERENCES.CLOSED_IND,
     	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
     	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
     	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      SEGMENT_TYPE   = X_SEGMENT_TYPE,
      SEGMENT_GROUP  = X_SEGMENT_GROUP
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
       x_MIN_SCORE IN NUMBER,
       x_MAX_SCORE IN NUMBER,
       x_INCLUDE_IN_COMP_SCORE IN VARCHAR2,
       x_SCORE_IND IN VARCHAR2,
       x_PERCENTILE_IND IN VARCHAR2,
       x_NATIONAL_PERCENTILE_IND IN VARCHAR2,
       x_STATE_PERCENTILE_IND IN VARCHAR2,
       x_PERCENTILE_YEAR_RANK_IND IN VARCHAR2,
       x_SCORE_BAND_UPPER_IND IN VARCHAR2,
       x_SCORE_BAND_LOWER_IND IN VARCHAR2,
       x_IRREGULARITY_CODE_IND IN VARCHAR2,
       x_TEST_SEGMENT_ID IN OUT NOCOPY NUMBER,
       x_ADMISSION_TEST_TYPE IN VARCHAR2,
       x_TEST_SEGMENT_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       X_MODE in VARCHAR2,
       X_SEGMENT_TYPE IN VARCHAR2 ,
       X_SEGMENT_GROUP IN NUMBER
  ) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_TEST_SEGMENTS
             where     TEST_SEGMENT_ID= X_TEST_SEGMENT_ID;
    l_mode        VARCHAR2(1);

begin

 l_mode := NVL(x_mode, 'R');
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
       X_ROWID,
       X_MIN_SCORE,
       X_MAX_SCORE,
       X_INCLUDE_IN_COMP_SCORE,
       X_SCORE_IND,
       X_PERCENTILE_IND,
       X_NATIONAL_PERCENTILE_IND,
       X_STATE_PERCENTILE_IND,
       X_PERCENTILE_YEAR_RANK_IND,
       X_SCORE_BAND_UPPER_IND,
       X_SCORE_BAND_LOWER_IND,
       X_IRREGULARITY_CODE_IND,
       X_TEST_SEGMENT_ID,
       X_ADMISSION_TEST_TYPE,
       X_TEST_SEGMENT_NAME,
       X_DESCRIPTION,
       X_CLOSED_IND,
       l_MODE,
       X_SEGMENT_TYPE,
       X_SEGMENT_GROUP);
     return;
	end if;
	   close c1;
UPDATE_ROW (
       X_ROWID,
       X_MIN_SCORE,
       X_MAX_SCORE,
       X_INCLUDE_IN_COMP_SCORE,
       X_SCORE_IND,
       X_PERCENTILE_IND,
       X_NATIONAL_PERCENTILE_IND,
       X_STATE_PERCENTILE_IND,
       X_PERCENTILE_YEAR_RANK_IND,
       X_SCORE_BAND_UPPER_IND,
       X_SCORE_BAND_LOWER_IND,
       X_IRREGULARITY_CODE_IND,
       X_TEST_SEGMENT_ID,
       X_ADMISSION_TEST_TYPE,
       X_TEST_SEGMENT_NAME,
       X_DESCRIPTION,
       X_CLOSED_IND,
       l_MODE,
       X_SEGMENT_TYPE,
       X_SEGMENT_GROUP);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
  /*************************************************************
  Created By :samaresh.in
  Date Created By :15-May-2000
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
 delete from IGS_AD_TEST_SEGMENTS
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
END igs_ad_test_segments_pkg;

/
