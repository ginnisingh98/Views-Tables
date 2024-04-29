--------------------------------------------------------
--  DDL for Package Body IGS_AD_TST_RSLT_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_TST_RSLT_DTLS_PKG" AS
/* $Header: IGSAI80B.pls 120.4 2005/08/22 04:45:30 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_tst_rslt_dtls%RowType;
  new_references igs_ad_tst_rslt_dtls%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tst_rslt_dtls_id IN NUMBER DEFAULT NULL,
    x_test_results_id IN NUMBER DEFAULT NULL,
    x_test_segment_id IN NUMBER DEFAULT NULL,
    x_test_score IN NUMBER DEFAULT NULL,
    x_percentile IN NUMBER DEFAULT NULL,
    x_national_percentile IN NUMBER DEFAULT NULL,
    x_state_percentile IN NUMBER DEFAULT NULL,
    x_percentile_year_rank IN NUMBER DEFAULT NULL,
    x_score_band_lower IN NUMBER DEFAULT NULL,
    x_score_band_upper IN NUMBER DEFAULT NULL,
    x_irregularity_code_id IN NUMBER DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
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

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_TST_RSLT_DTLS
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
    new_references.tst_rslt_dtls_id := x_tst_rslt_dtls_id;
    new_references.test_results_id := x_test_results_id;
    new_references.test_segment_id := x_test_segment_id;
    new_references.test_score := x_test_score;
    new_references.percentile := x_percentile;
    new_references.national_percentile := x_national_percentile;
    new_references.state_percentile := x_state_percentile;
    new_references.percentile_year_rank := x_percentile_year_rank;
    new_references.score_band_lower := x_score_band_lower;
    new_references.score_band_upper := x_score_band_upper;
    new_references.irregularity_code_id := x_irregularity_code_id;
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
      ELSIF  UPPER(column_name) = 'STATE_PERCENTILE'  THEN
        new_references.state_percentile := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'PERCENTILE_YEAR_RANK'  THEN
        new_references.percentile_year_rank := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'SCORE_BAND_LOWER'  THEN
        new_references.score_band_lower := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'SCORE_BAND_UPPER'  THEN
        new_references.score_band_upper := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'NATIONAL_PERCENTILE'  THEN
        new_references.national_percentile := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'TEST_SCORE'  THEN
        new_references.test_score := IGS_GE_NUMBER.TO_NUM(column_value);
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'STATE_PERCENTILE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.state_percentile>=0  and  new_references.state_percentile<=100)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_PCTL_NOT_GT_100_OR_LT_0');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'PERCENTILE_YEAR_RANK' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.percentile_year_rank>=0)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_PCTLYR_RANK_NOT_LT_0');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'SCORE_BAND_LOWER' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.score_band_lower>=0
              OR new_references.score_band_lower IS NULL)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_SB_NOT_LT_0');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'SCORE_BAND_UPPER' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.score_band_upper>=0
              OR new_references.score_band_upper IS NULL)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_SB_NOT_LT_0');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'PERCENTILE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.percentile>=0 and new_references.percentile<=100)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_PCTL_NOT_GT_100_OR_LT_0');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'NATIONAL_PERCENTILE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.national_percentile>=0 and new_references.national_percentile<=100)  THEN
           Fnd_Message.Set_Name('IGS','IGS_IGS_AD_PCTL_NOT_GT_100_OR_LT_0');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'TEST_SCORE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.test_score>=0)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_SCORE_NOT_LT_ZERO');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.test_results_id
    		,new_references.test_segment_id
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
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

    IF (((old_references.irregularity_code_id = new_references.irregularity_code_id)) OR
        ((new_references.irregularity_code_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.irregularity_code_id,
                        'IRREGULARITY_CODE',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_IRREGULARITY'));
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.test_results_id = new_references.test_results_id)) OR
        ((new_references.test_results_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Test_Results_Pkg.Get_PK_For_Validation (
        		new_references.test_results_id
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TEST_RESULT'));
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.test_segment_id = new_references.test_segment_id)) OR
        ((new_references.test_segment_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Test_Segments_Pkg.Get_PK_For_Validation (
        		new_references.test_segment_id,
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TEST_SEGMNT'));
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_tst_rslt_dtls_id IN NUMBER
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
      FROM     igs_ad_tst_rslt_dtls
      WHERE    tst_rslt_dtls_id = x_tst_rslt_dtls_id
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
    x_test_results_id IN NUMBER,
    x_test_segment_id IN NUMBER
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
      FROM     igs_ad_tst_rslt_dtls
      WHERE    test_results_id = x_test_results_id
      AND      test_segment_id = x_test_segment_id 	and      ((l_rowid is null) or (rowid <> l_rowid))

      ;
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

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
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
      FROM     igs_ad_tst_rslt_dtls
      WHERE    irregularity_code_id = x_code_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATRD_ACDC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Code_Classes;

  PROCEDURE Get_FK_Igs_Ad_Test_Results (
    x_test_results_id IN NUMBER
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
      FROM     igs_ad_tst_rslt_dtls
      WHERE    test_results_id = x_test_results_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATRD_ATR_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Test_Results;

  PROCEDURE Get_FK_Igs_Ad_Test_Segments (
    x_test_segment_id IN NUMBER
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
      FROM     igs_ad_tst_rslt_dtls
      WHERE    test_segment_id = x_test_segment_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATRD_ATS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Test_Segments;

  PROCEDURE Check_Child_Existance AS
  BEGIN
    -- Next part of code has been added as per bug# 2401170
    -- Start of new code.
    igs_av_stnd_unit_pkg.get_fk_igs_ad_tst_rslt_dtls (
      old_references.tst_rslt_dtls_id
      );
    igs_av_stnd_unit_lvl_pkg.get_fk_igs_ad_tst_rslt_dtls (
      old_references.tst_rslt_dtls_id
      );
    -- End of new code. Bug# 2401170
  END Check_Child_Existance;

PROCEDURE update_parent_composite_score(p_test_results_id IN NUMBER)
 AS

	 CURSOR c_calc_comp_score(cp_test_results_id IN NUMBER) IS
	 SELECT SUM(test_score)
	 FROM IGS_AD_TST_RSLT_DTLS A,
		  IGS_AD_TEST_SEGMENTS B
	 WHERE A.TEST_results_ID = cp_test_results_id
	 AND A.TEST_SEGMENT_ID =  B.test_segment_id
	 AND B.INCLUDE_IN_COMP_SCORE = 'Y';

	 l_comp_score  NUMBER;
	 l_test_result_id NUMBER(15);

	 CURSOR c_get_test_score_record(cp_test_results_id IN NUMBER) IS
	 SELECT rowid,A.*
	 FROM IGS_AD_TEST_RESULTS A
	 WHERE test_results_id = cp_test_results_id
	 FOR UPDATE NOWAIT;

     l_test_result c_get_test_score_record%ROWTYPE;
     e_resource_busy_exception       EXCEPTION;
     PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
	 testResult    VARCHAR2(100);
 BEGIN

 OPEN c_calc_comp_score(p_test_results_id);
 FETCH c_calc_comp_score INTO l_comp_score;
 CLOSE c_calc_comp_score;

 OPEN c_get_test_score_record(p_test_results_id);
 FETCH c_get_test_score_record INTO l_test_result;
 CLOSE c_get_test_score_record;

Igs_Ad_Test_Results_Pkg.Update_Row (
     X_Mode                              => 'R',
     X_RowId                             => l_test_result.ROWID,
     X_Test_Results_Id                   => l_test_result.Test_Results_Id,
     X_Person_Id                         => l_test_result.Person_Id,
     X_Admission_Test_Type               => l_test_result.Admission_Test_Type,
     X_Test_Date                         => l_test_result.Test_Date,
     X_Score_Report_Date                 => l_test_result.Score_Report_Date,
     X_Edu_Level_Id                      => l_test_result.Edu_Level_Id,
     X_Score_Type                        => l_test_result.Score_Type,
     X_Score_Source_Id                   => l_test_result.Score_Source_Id,
     X_Non_Standard_Admin                => l_test_result.Non_Standard_Admin,
     X_Comp_Test_Score                   => l_comp_score,
     X_Special_Code                      => l_test_result.Special_Code,
     X_Registration_Number               => l_test_result.Registration_Number,
     X_Grade_Id                          => l_test_result.Grade_Id,
     X_Attribute_Category                => l_test_result.Attribute_Category,
     X_Attribute1                        => l_test_result.Attribute1,
     X_Attribute2                        => l_test_result.Attribute2,
     X_Attribute3                        => l_test_result.Attribute3,
     X_Attribute4                        => l_test_result.Attribute4,
     X_Attribute5                        => l_test_result.Attribute5,
     X_Attribute6                        => l_test_result.Attribute6,
     X_Attribute7                        => l_test_result.Attribute7,
     X_Attribute8                        => l_test_result.Attribute8,
     X_Attribute9                        => l_test_result.Attribute9,
     X_Attribute10                       => l_test_result.Attribute10,
     X_Attribute11                       => l_test_result.Attribute11,
     X_Attribute12                       => l_test_result.Attribute12,
     X_Attribute13                       => l_test_result.Attribute13,
     X_Attribute14                       => l_test_result.Attribute14,
     X_Attribute15                       => l_test_result.Attribute15,
     X_Attribute16                       => l_test_result.Attribute16,
     X_Attribute17                       => l_test_result.Attribute17,
     X_Attribute18                       => l_test_result.Attribute18,
     X_Attribute19                       => l_test_result.Attribute19,
     X_Attribute20                       => l_test_result.Attribute20,
     X_Active_Ind                        => l_test_result.Active_Ind
   );

 EXCEPTION
   WHEN e_resource_busy_exception THEN
     fnd_message.set_name ('IGS', 'IGS_AD_TSTRESULT');
	 testResult := fnd_message.get();
     fnd_message.set_name ('IGS', 'IGS_PR_LOCK_DETECTED');
     fnd_message.set_token('RECORD',testResult);
     igs_ge_msg_stack.add;
     App_Exception.Raise_Exception;
 END update_parent_composite_score;

PROCEDURE validate_record(p_error OUT NOCOPY BOOLEAN,
                          p_message OUT NOCOPY VARCHAR2,
                          p_entity1 OUT NOCOPY VARCHAR2,
                          p_entity2 OUT NOCOPY VARCHAR2,
						  p_entity3 OUT NOCOPY VARCHAR2)
IS
CURSOR c_test_ind_cur(cp_test_segment_id igs_ad_test_segments.test_segment_id%TYPE) IS
SELECT
  include_in_comp_score,
  score_ind,
  percentile_ind,
  irregularity_code_ind,
  percentile_year_rank_ind,
  national_percentile_ind,
  state_percentile_ind,
  score_band_upper_ind,
  score_band_lower_ind
FROM
  IGS_AD_TEST_SEGMENTS
WHERE
  test_segment_id = cp_test_segment_id ;


CURSOR c_admission_test_type IS
  SELECT admission_test_type
  FROM  igs_ad_test_results
  WHERE test_results_id = new_references.test_results_id;

 CURSOR c_val_test_seg_cur (cp_admission_test_type igs_ad_test_results.admission_test_type%TYPE)IS
  SELECT 'x'
  FROM
    igs_ad_test_segments
  WHERE
    test_segment_id  =  new_references.test_segment_id
    AND ADMISSION_TEST_TYPE = cp_admission_test_type
    AND closed_ind = 'N';

    CURSOR
      c_test_score_range_cur
    IS
    SELECT
      min_score,
      max_score,
	  description
    FROM
      igs_ad_test_segments
    WHERE
      TEST_SEGMENT_ID = new_references.test_segment_id ;

   c_test_ind_rec c_test_ind_cur%ROWTYPE;
   c_val_test_seg_rec c_val_test_seg_cur%ROWTYPE;
   l_admission_test_type igs_ad_test_results.admission_test_type%TYPE;

BEGIN

   l_admission_test_type := NULL;
   OPEN  c_admission_test_type;
   FETCH c_admission_test_type INTO l_admission_test_type;
   CLOSE c_admission_test_type;

   IF  l_admission_test_type IS NOT NULL THEN
     OPEN c_val_test_seg_cur(l_admission_test_type);
     FETCH c_val_test_seg_cur INTO c_val_test_seg_rec;
     IF c_val_test_seg_cur%NOTFOUND THEN
       p_message := 'IGS_AD_TST_TYP_SEG_COM_NOT_EXT';
       p_error := TRUE;
       CLOSE c_val_test_seg_cur;
       RETURN;
     END IF;
     CLOSE c_val_test_seg_cur;
   ELSE
     p_message := 'IGS_AD_TST_TYP_SEG_COM_NOT_EXT';
     p_error := TRUE;
     RETURN;
   END IF;


IF (((old_references.test_score IS NOT NULL AND new_references.test_score IS NULL)) OR
    ((old_references.test_score IS NULL AND new_references.test_score IS NOT NULL)) OR
    ((old_references.test_score <> new_references.test_score))) THEN
   FOR c_test_score_range_rec IN c_test_score_range_cur
   LOOP
     IF (new_references.test_score < c_test_score_range_rec.min_score  OR
         new_references.test_score > c_test_score_range_rec.max_score) THEN
          p_error := TRUE;
          p_message := 'IGS_AD_OUT_OF_RANGE';
          p_entity1 := c_test_score_range_rec.min_score;
          p_entity2 := c_test_score_range_rec.max_score;
          p_entity3 := c_test_score_range_rec.description;
        RETURN;
     END IF;
   END LOOP;
END IF;

  OPEN c_test_ind_cur(new_references.test_segment_id);
  FETCH c_test_ind_cur INTO c_test_ind_rec;
  CLOSE c_test_ind_cur;

IF (((old_references.test_score IS NOT NULL AND new_references.test_score IS NULL)) OR
    ((old_references.test_score IS NULL AND new_references.test_score IS NOT NULL)) OR
    ((old_references.test_score <> new_references.test_score))) THEN
   IF c_test_ind_rec.score_ind = 'N' AND new_references.test_score IS NOT NULL THEN
   p_error := TRUE;
   p_message :='IGS_AD_NOT_APL_ATTR_TST_SEG';
   p_entity1 := 'Test Score';
   RETURN;
  END IF;
END IF;

IF (((old_references.percentile IS NOT NULL AND new_references.percentile IS NULL)) OR
    ((old_references.percentile IS NULL AND new_references.percentile IS NOT NULL)) OR
    ((old_references.percentile <> new_references.percentile))) THEN
   IF c_test_ind_rec.percentile_ind = 'N' AND new_references.percentile IS NOT NULL THEN
   p_error := TRUE;
   p_message :='IGS_AD_NOT_APL_ATTR_TST_SEG';
   p_entity1 := 'Percentile';
   RETURN;
  END IF;
END IF;

IF (((old_references.irregularity_code_id IS NOT NULL AND new_references.irregularity_code_id IS NULL)) OR
    ((old_references.irregularity_code_id IS NULL AND new_references.irregularity_code_id IS NOT NULL)) OR
    ((old_references.irregularity_code_id <> new_references.irregularity_code_id))) THEN
  IF c_test_ind_rec.irregularity_code_ind = 'N' AND new_references.irregularity_code_id IS NOT NULL THEN
   p_error := TRUE;
   p_message :='IGS_AD_NOT_APL_ATTR_TST_SEG';
   p_entity1 := 'Rrregularity Code';
   RETURN;
  END IF;
END IF;


IF (((old_references.percentile_year_rank IS NOT NULL AND new_references.percentile_year_rank IS NULL)) OR
    ((old_references.percentile_year_rank IS NULL AND new_references.percentile_year_rank IS NOT NULL)) OR
    ((old_references.percentile_year_rank <> new_references.percentile_year_rank))) THEN
  IF c_test_ind_rec.percentile_year_rank_ind = 'N' AND new_references.percentile_year_rank IS NOT NULL THEN
   p_error := TRUE;
   p_message :='IGS_AD_NOT_APL_ATTR_TST_SEG';
   p_entity1 := 'Percentile Year Rank';
   RETURN;
  END IF;
END IF;

IF (((old_references.national_percentile IS NOT NULL AND new_references.national_percentile IS NULL)) OR
    ((old_references.national_percentile IS NULL AND new_references.national_percentile IS NOT NULL)) OR
    ((old_references.national_percentile <> new_references.national_percentile)) ) THEN
  IF c_test_ind_rec.national_percentile_ind = 'N' AND new_references.national_percentile IS NOT NULL THEN
   p_error := TRUE;
   p_message :='IGS_AD_NOT_APL_ATTR_TST_SEG';
   p_entity1 := 'National Percentile';
   RETURN;
  END IF;
END IF;


IF (((old_references.state_percentile IS NOT NULL AND new_references.state_percentile IS NULL)) OR
    ((old_references.state_percentile IS NULL AND new_references.state_percentile IS NOT NULL)) OR
    ((old_references.state_percentile <> new_references.state_percentile)) ) THEN
  IF c_test_ind_rec.state_percentile_ind = 'N' AND new_references.state_percentile IS NOT NULL THEN
   p_error := TRUE;
   p_message :='IGS_AD_NOT_APL_ATTR_TST_SEG';
   p_entity1 := 'State Percentile';
   RETURN;
  END IF;
END IF;

IF (((old_references.score_band_upper IS NOT NULL AND new_references.score_band_upper IS NULL)) OR
    ((old_references.score_band_upper IS NULL AND new_references.score_band_upper IS NOT NULL)) OR
    ((old_references.score_band_upper <> new_references.score_band_upper))) THEN

  IF c_test_ind_rec.score_band_upper_ind = 'N' AND new_references.score_band_upper IS NOT NULL THEN
   p_error := TRUE;
   p_message :='IGS_AD_NOT_APL_ATTR_TST_SEG';
   p_entity1 := 'Score Band Upper';
   RETURN;
  END IF;
END IF;

IF (((old_references.score_band_lower IS NOT NULL AND new_references.score_band_lower IS NULL)) OR
    ((old_references.score_band_lower IS NULL AND new_references.score_band_lower IS NOT NULL)) OR
    ((old_references.score_band_lower <> new_references.score_band_lower))) THEN
  IF c_test_ind_rec.score_band_lower_ind = 'N' AND new_references.score_band_lower IS NOT NULL THEN
   p_error := TRUE;
   p_message :='IGS_AD_NOT_APL_ATTR_TST_SEG';
   p_entity1 := 'Score Band Lower';
   RETURN;
  END IF;
END IF;

  p_error := FALSE;
  p_entity1 := NULL;
  p_entity2 := NULL;
  p_entity3 := NULL;
  p_message := NULL;
END validate_record;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tst_rslt_dtls_id IN NUMBER DEFAULT NULL,
    x_test_results_id IN NUMBER DEFAULT NULL,
    x_test_segment_id IN NUMBER DEFAULT NULL,
    x_test_score IN NUMBER DEFAULT NULL,
    x_percentile IN NUMBER DEFAULT NULL,
    x_national_percentile IN NUMBER DEFAULT NULL,
    x_state_percentile IN NUMBER DEFAULT NULL,
    x_percentile_year_rank IN NUMBER DEFAULT NULL,
    x_score_band_lower IN NUMBER DEFAULT NULL,
    x_score_band_upper IN NUMBER DEFAULT NULL,
    x_irregularity_code_id IN NUMBER DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
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
  l_error BOOLEAN := FALSE;
  l_message_name VARCHAR2(30);
  l_entity1 VARCHAR2(100);
  l_entity2 VARCHAR2(100);
  l_entity3 VARCHAR2(100);

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_tst_rslt_dtls_id,
      x_test_results_id,
      x_test_segment_id,
      x_test_score,
      x_percentile,
      x_national_percentile,
      x_state_percentile,
      x_percentile_year_rank,
      x_score_band_lower,
      x_score_band_upper,
      x_irregularity_code_id,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    l_entity1 :=NULL;
    l_message_name :=NULL;
    l_error := FALSE;
    l_entity2 := NULL;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
     IF Get_Pk_For_Validation(
	new_references.tst_rslt_dtls_id)  THEN
        Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;

    validate_record(l_error,l_message_name,l_entity1,l_entity2,l_entity3);

      IF l_error = TRUE THEN
        IF l_message_name = 'IGS_AD_NOT_APL_ATTR_TST_SEG' THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_AD_NOT_APL_ATTR_TST_SEG');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_entity1);
        ELSIF l_message_name = 'IGS_AD_TST_TYP_SEG_COM_NOT_EXT' THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_AD_TST_TYP_SEG_COM_NOT_EXT');
        ELSIF l_message_name = 'IGS_AD_OUT_OF_RANGE' THEN
		 FND_MESSAGE.SET_NAME('IGS','IGS_AD_OUT_OF_RANGE');
         FND_MESSAGE.SET_TOKEN('TEST_SEGMENT',l_entity3);
         FND_MESSAGE.SET_TOKEN('MIN_SCORE',l_entity1);
         FND_MESSAGE.SET_TOKEN('MAX_SCORE',l_entity2);
        END IF;
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
     Null;

     validate_record(l_error,l_message_name,l_entity1,l_entity2,l_entity3);
     IF l_error = TRUE THEN
        IF l_message_name = 'IGS_AD_NOT_APL_ATTR_TST_SEG' THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_AD_NOT_APL_ATTR_TST_SEG');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_entity1);
        ELSIF l_message_name = 'IGS_AD_TST_TYP_SEG_COM_NOT_EXT' THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_AD_TST_TYP_SEG_COM_NOT_EXT');
        ELSIF l_message_name = 'IGS_AD_OUT_OF_RANGE' THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_AD_OUT_OF_RANGE');
         FND_MESSAGE.SET_TOKEN('MIN_SCORE',l_entity1);
         FND_MESSAGE.SET_TOKEN('MAX_SCORE',l_entity2);
         FND_MESSAGE.SET_TOKEN('TEST_SEGMENT',l_entity3);
        END IF;
         IGS_GE_MSG_STACK.ADD;
 	     App_Exception.Raise_Exception;
      END IF;

      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
	       new_references.tst_rslt_dtls_id)  THEN
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

  END Before_DML;

 PROCEDURE After_DML (
    p_action                  IN VARCHAR2,
    x_rowid                   IN VARCHAR2
  ) AS
  -------------------------------------------------------------------------------
  -- Bug ID : 1818617
  -- who              when                  what
  -- sjadhav          jun 28,2001           this procedure is modified to trigger
  --                                        a Concurrent Request (IGFAPJ10) which
  --                                        will create a new record in IGF To
  --                                        Do table
  -------------------------------------------------------------------------------
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
   CURSOR c_person_id IS
   SELECT person_id
   FROM IGS_AD_TEST_RESULTS
   WHERE TEST_RESULTS_ID = new_references.test_results_id;

   CURSOR test_comb_score_cur(cp_test_segment_id igs_ad_test_segments.test_segment_id%TYPE) IS
   SELECT include_in_comp_score
   FROM igs_ad_test_segments
   WHERE test_segment_id = cp_test_segment_id;

   test_comb_score_rec test_comb_score_cur%ROWTYPE;

   l_person_id  hz_parties.party_id%TYPE;
  BEGIN
    l_rowid := x_rowid;
   OPEN c_person_id;
   FETCH c_person_id INTO l_person_id;
   CLOSE c_person_id;


    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      OPEN test_comb_score_cur(new_references.test_segment_id);
      FETCH test_comb_score_cur INTO test_comb_score_rec;
      CLOSE test_comb_score_cur;

	  IF (test_comb_score_rec.include_in_comp_score = 'Y' AND new_references.test_score IS NOT NULL) THEN
         update_parent_composite_score(new_references.test_results_id);
      END IF;

      --Raise the buisness event
      igs_ad_wf_001.TESTSEG_CRT_EVENT
      (
        P_TEST_RESULTS_ID       =>    new_references.test_results_id,
        P_TST_RSLT_DTLS_ID      =>    new_references.tst_rslt_dtls_id,
        P_TEST_SEGMENT_ID       =>    new_references.test_segment_id,
        P_PERSON_ID             =>    l_person_id
      );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.

	  IF (NVL(new_references.test_score,-1) <> NVL(old_references.test_score,-1)) THEN
        update_parent_composite_score(new_references.test_results_id);
	  END IF;

      --Raise the buisness event
      igs_ad_wf_001.TESTSEG_UPD_EVENT
      (
          P_TEST_RESULTS_ID	 =>   new_references.test_results_id,
          P_TST_RSLT_DTLS_ID     =>   new_references.tst_rslt_dtls_id,
          P_TEST_SEGMENT_ID	 =>   new_references.test_segment_id,
          P_PERSON_ID	         =>   l_person_id,
    	  P_TEST_SCORE_NEW	 =>   new_references.test_score,
	      P_TEST_SCORE_OLD	 =>   old_references.test_score
       );

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
	  IF (old_references.test_score IS NOT NULL) THEN
         update_parent_composite_score(old_references.test_results_id);
      END IF;
    END IF;

  l_rowid:=NULL;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_TST_RSLT_DTLS_ID IN OUT NOCOPY NUMBER,
       x_TEST_RESULTS_ID IN NUMBER,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_TEST_SCORE IN NUMBER,
       x_PERCENTILE IN NUMBER,
       x_NATIONAL_PERCENTILE IN NUMBER,
       x_STATE_PERCENTILE IN NUMBER,
       x_PERCENTILE_YEAR_RANK IN NUMBER,
       x_SCORE_BAND_LOWER IN NUMBER,
       x_SCORE_BAND_UPPER IN NUMBER,
       x_IRREGULARITY_CODE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  RAVISHAR        Feb,25 2005     Removed the default value of X_MODE parameter from
                                  body of this package for bug 4163319
  				  GSCC standard says that default value should be
				  present only in specification

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_TST_RSLT_DTLS
             where                 TST_RSLT_DTLS_ID= X_TST_RSLT_DTLS_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
     L_MODE VARCHAR2(1);
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

   X_TST_RSLT_DTLS_ID := -1;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_tst_rslt_dtls_id=>X_TST_RSLT_DTLS_ID,
 	       x_test_results_id=>X_TEST_RESULTS_ID,
 	       x_test_segment_id=>X_TEST_SEGMENT_ID,
 	       x_test_score=>X_TEST_SCORE,
 	       x_percentile=>X_PERCENTILE,
 	       x_national_percentile=>X_NATIONAL_PERCENTILE,
 	       x_state_percentile=>X_STATE_PERCENTILE,
 	       x_percentile_year_rank=>X_PERCENTILE_YEAR_RANK,
 	       x_score_band_lower=>X_SCORE_BAND_LOWER,
 	       x_score_band_upper=>X_SCORE_BAND_UPPER,
 	       x_irregularity_code_id=>X_IRREGULARITY_CODE_ID,
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
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_AD_TST_RSLT_DTLS (
		TST_RSLT_DTLS_ID
		,TEST_RESULTS_ID
		,TEST_SEGMENT_ID
		,TEST_SCORE
		,PERCENTILE
		,NATIONAL_PERCENTILE
		,STATE_PERCENTILE
		,PERCENTILE_YEAR_RANK
		,SCORE_BAND_LOWER
		,SCORE_BAND_UPPER
		,IRREGULARITY_CODE_ID
		,ATTRIBUTE_CATEGORY
		,ATTRIBUTE1
		,ATTRIBUTE2
		,ATTRIBUTE3
		,ATTRIBUTE4
		,ATTRIBUTE5
		,ATTRIBUTE6
		,ATTRIBUTE7
		,ATTRIBUTE8
		,ATTRIBUTE9
		,ATTRIBUTE10
		,ATTRIBUTE11
		,ATTRIBUTE12
		,ATTRIBUTE13
		,ATTRIBUTE14
		,ATTRIBUTE15
		,ATTRIBUTE16
		,ATTRIBUTE17
		,ATTRIBUTE18
		,ATTRIBUTE19
		,ATTRIBUTE20
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,REQUEST_ID
		,PROGRAM_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_UPDATE_DATE
        ) values  (
	        IGS_AD_TST_RSLT_DTLS_S.NEXTVAL
	        ,NEW_REFERENCES.TEST_RESULTS_ID
	        ,NEW_REFERENCES.TEST_SEGMENT_ID
	        ,NEW_REFERENCES.TEST_SCORE
	        ,NEW_REFERENCES.PERCENTILE
	        ,NEW_REFERENCES.NATIONAL_PERCENTILE
	        ,NEW_REFERENCES.STATE_PERCENTILE
	        ,NEW_REFERENCES.PERCENTILE_YEAR_RANK
	        ,NEW_REFERENCES.SCORE_BAND_LOWER
	        ,NEW_REFERENCES.SCORE_BAND_UPPER
	        ,NEW_REFERENCES.IRREGULARITY_CODE_ID
	        ,NEW_REFERENCES.ATTRIBUTE_CATEGORY
	        ,NEW_REFERENCES.ATTRIBUTE1
	        ,NEW_REFERENCES.ATTRIBUTE2
	        ,NEW_REFERENCES.ATTRIBUTE3
	        ,NEW_REFERENCES.ATTRIBUTE4
	        ,NEW_REFERENCES.ATTRIBUTE5
	        ,NEW_REFERENCES.ATTRIBUTE6
	        ,NEW_REFERENCES.ATTRIBUTE7
	        ,NEW_REFERENCES.ATTRIBUTE8
	        ,NEW_REFERENCES.ATTRIBUTE9
	        ,NEW_REFERENCES.ATTRIBUTE10
	        ,NEW_REFERENCES.ATTRIBUTE11
	        ,NEW_REFERENCES.ATTRIBUTE12
	        ,NEW_REFERENCES.ATTRIBUTE13
	        ,NEW_REFERENCES.ATTRIBUTE14
	        ,NEW_REFERENCES.ATTRIBUTE15
	        ,NEW_REFERENCES.ATTRIBUTE16
	        ,NEW_REFERENCES.ATTRIBUTE17
	        ,NEW_REFERENCES.ATTRIBUTE18
	        ,NEW_REFERENCES.ATTRIBUTE19
	        ,NEW_REFERENCES.ATTRIBUTE20
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,X_REQUEST_ID
		,X_PROGRAM_ID
		,X_PROGRAM_APPLICATION_ID
		,X_PROGRAM_UPDATE_DATE
)RETURNING TST_RSLT_DTLS_ID INTO X_TST_RSLT_DTLS_ID ;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


      NEW_REFERENCES.TST_RSLT_DTLS_ID := X_TST_RSLT_DTLS_ID;

		open c;
		 fetch c into X_ROWID;
 		if (c%notfound) then
		close c;
 	     raise no_data_found;
		end if;
 		close c;
    After_DML (
		p_action            => 'INSERT' ,
		x_rowid             => X_ROWID
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
      X_ROWID in  VARCHAR2,
       x_TST_RSLT_DTLS_ID IN NUMBER,
       x_TEST_RESULTS_ID IN NUMBER,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_TEST_SCORE IN NUMBER,
       x_PERCENTILE IN NUMBER,
       x_NATIONAL_PERCENTILE IN NUMBER,
       x_STATE_PERCENTILE IN NUMBER,
       x_PERCENTILE_YEAR_RANK IN NUMBER,
       x_SCORE_BAND_LOWER IN NUMBER,
       x_SCORE_BAND_UPPER IN NUMBER,
       x_IRREGULARITY_CODE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      TEST_RESULTS_ID
,      TEST_SEGMENT_ID
,      TEST_SCORE
,      PERCENTILE
,      NATIONAL_PERCENTILE
,      STATE_PERCENTILE
,      PERCENTILE_YEAR_RANK
,      SCORE_BAND_LOWER
,      SCORE_BAND_UPPER
,      IRREGULARITY_CODE_ID
,      ATTRIBUTE_CATEGORY
,      ATTRIBUTE1
,      ATTRIBUTE2
,      ATTRIBUTE3
,      ATTRIBUTE4
,      ATTRIBUTE5
,      ATTRIBUTE6
,      ATTRIBUTE7
,      ATTRIBUTE8
,      ATTRIBUTE9
,      ATTRIBUTE10
,      ATTRIBUTE11
,      ATTRIBUTE12
,      ATTRIBUTE13
,      ATTRIBUTE14
,      ATTRIBUTE15
,      ATTRIBUTE16
,      ATTRIBUTE17
,      ATTRIBUTE18
,      ATTRIBUTE19
,      ATTRIBUTE20
    from IGS_AD_TST_RSLT_DTLS
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
if ( (  tlinfo.TEST_RESULTS_ID = X_TEST_RESULTS_ID)
  AND (tlinfo.TEST_SEGMENT_ID = X_TEST_SEGMENT_ID)
  AND ((tlinfo.TEST_SCORE = X_TEST_SCORE)
 	    OR ((tlinfo.TEST_SCORE is null)
		AND (X_TEST_SCORE is null)))
  AND ((tlinfo.PERCENTILE = X_PERCENTILE)
 	    OR ((tlinfo.PERCENTILE is null)
		AND (X_PERCENTILE is null)))
  AND ((tlinfo.NATIONAL_PERCENTILE = X_NATIONAL_PERCENTILE)
 	    OR ((tlinfo.NATIONAL_PERCENTILE is null)
		AND (X_NATIONAL_PERCENTILE is null)))
  AND ((tlinfo.STATE_PERCENTILE = X_STATE_PERCENTILE)
 	    OR ((tlinfo.STATE_PERCENTILE is null)
		AND (X_STATE_PERCENTILE is null)))
  AND ((tlinfo.PERCENTILE_YEAR_RANK = X_PERCENTILE_YEAR_RANK)
 	    OR ((tlinfo.PERCENTILE_YEAR_RANK is null)
		AND (X_PERCENTILE_YEAR_RANK is null)))
  AND ((tlinfo.SCORE_BAND_LOWER = X_SCORE_BAND_LOWER)
 	    OR ((tlinfo.SCORE_BAND_LOWER is null)
		AND (X_SCORE_BAND_LOWER is null)))
  AND ((tlinfo.SCORE_BAND_UPPER = X_SCORE_BAND_UPPER)
 	    OR ((tlinfo.SCORE_BAND_UPPER is null)
		AND (X_SCORE_BAND_UPPER is null)))
  AND ((tlinfo.IRREGULARITY_CODE_ID = X_IRREGULARITY_CODE_ID)
 	    OR ((tlinfo.IRREGULARITY_CODE_ID is null)
		AND (X_IRREGULARITY_CODE_ID is null)))
  AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
 	    OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
		AND (X_ATTRIBUTE_CATEGORY is null)))
  AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
 	    OR ((tlinfo.ATTRIBUTE1 is null)
		AND (X_ATTRIBUTE1 is null)))
  AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
 	    OR ((tlinfo.ATTRIBUTE2 is null)
		AND (X_ATTRIBUTE2 is null)))
  AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
 	    OR ((tlinfo.ATTRIBUTE3 is null)
		AND (X_ATTRIBUTE3 is null)))
  AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
 	    OR ((tlinfo.ATTRIBUTE4 is null)
		AND (X_ATTRIBUTE4 is null)))
  AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
 	    OR ((tlinfo.ATTRIBUTE5 is null)
		AND (X_ATTRIBUTE5 is null)))
  AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
 	    OR ((tlinfo.ATTRIBUTE6 is null)
		AND (X_ATTRIBUTE6 is null)))
  AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
 	    OR ((tlinfo.ATTRIBUTE7 is null)
		AND (X_ATTRIBUTE7 is null)))
  AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
 	    OR ((tlinfo.ATTRIBUTE8 is null)
		AND (X_ATTRIBUTE8 is null)))
  AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
 	    OR ((tlinfo.ATTRIBUTE9 is null)
		AND (X_ATTRIBUTE9 is null)))
  AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
 	    OR ((tlinfo.ATTRIBUTE10 is null)
		AND (X_ATTRIBUTE10 is null)))
  AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
 	    OR ((tlinfo.ATTRIBUTE11 is null)
		AND (X_ATTRIBUTE11 is null)))
  AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
 	    OR ((tlinfo.ATTRIBUTE12 is null)
		AND (X_ATTRIBUTE12 is null)))
  AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
 	    OR ((tlinfo.ATTRIBUTE13 is null)
		AND (X_ATTRIBUTE13 is null)))
  AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
 	    OR ((tlinfo.ATTRIBUTE14 is null)
		AND (X_ATTRIBUTE14 is null)))
  AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
 	    OR ((tlinfo.ATTRIBUTE15 is null)
		AND (X_ATTRIBUTE15 is null)))
  AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
 	    OR ((tlinfo.ATTRIBUTE16 is null)
		AND (X_ATTRIBUTE16 is null)))
  AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
 	    OR ((tlinfo.ATTRIBUTE17 is null)
		AND (X_ATTRIBUTE17 is null)))
  AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
 	    OR ((tlinfo.ATTRIBUTE18 is null)
		AND (X_ATTRIBUTE18 is null)))
  AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
 	    OR ((tlinfo.ATTRIBUTE19 is null)
		AND (X_ATTRIBUTE19 is null)))
  AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
 	    OR ((tlinfo.ATTRIBUTE20 is null)
		AND (X_ATTRIBUTE20 is null)))
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
       x_TST_RSLT_DTLS_ID IN NUMBER,
       x_TEST_RESULTS_ID IN NUMBER,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_TEST_SCORE IN NUMBER,
       x_PERCENTILE IN NUMBER,
       x_NATIONAL_PERCENTILE IN NUMBER,
       x_STATE_PERCENTILE IN NUMBER,
       x_PERCENTILE_YEAR_RANK IN NUMBER,
       x_SCORE_BAND_LOWER IN NUMBER,
       x_SCORE_BAND_UPPER IN NUMBER,
       x_IRREGULARITY_CODE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  RAVISHAR        Feb,25 2005     Removed the default value of X_MODE parameter from
                                  body of this package for bug 4163319
  				  GSCC standard says that default value should be
				  present only in specification

  (reverse chronological order - newest change first)
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
    else
      FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    end if;
   Before_DML(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_tst_rslt_dtls_id=>X_TST_RSLT_DTLS_ID,
 	       x_test_results_id=>X_TEST_RESULTS_ID,
 	       x_test_segment_id=>X_TEST_SEGMENT_ID,
 	       x_test_score=>X_TEST_SCORE,
 	       x_percentile=>X_PERCENTILE,
 	       x_national_percentile=>X_NATIONAL_PERCENTILE,
 	       x_state_percentile=>X_STATE_PERCENTILE,
 	       x_percentile_year_rank=>X_PERCENTILE_YEAR_RANK,
 	       x_score_band_lower=>X_SCORE_BAND_LOWER,
 	       x_score_band_upper=>X_SCORE_BAND_UPPER,
 	       x_irregularity_code_id=>X_IRREGULARITY_CODE_ID,
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
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);

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
 update IGS_AD_TST_RSLT_DTLS set
      TEST_RESULTS_ID =  NEW_REFERENCES.TEST_RESULTS_ID,
      TEST_SEGMENT_ID =  NEW_REFERENCES.TEST_SEGMENT_ID,
      TEST_SCORE =  NEW_REFERENCES.TEST_SCORE,
      PERCENTILE =  NEW_REFERENCES.PERCENTILE,
      NATIONAL_PERCENTILE =  NEW_REFERENCES.NATIONAL_PERCENTILE,
      STATE_PERCENTILE =  NEW_REFERENCES.STATE_PERCENTILE,
      PERCENTILE_YEAR_RANK =  NEW_REFERENCES.PERCENTILE_YEAR_RANK,
      SCORE_BAND_LOWER =  NEW_REFERENCES.SCORE_BAND_LOWER,
      SCORE_BAND_UPPER =  NEW_REFERENCES.SCORE_BAND_UPPER,
      IRREGULARITY_CODE_ID =  NEW_REFERENCES.IRREGULARITY_CODE_ID,
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
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
,	REQUEST_ID = X_REQUEST_ID,
	PROGRAM_ID = X_PROGRAM_ID,
	PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID,
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
        	p_action            => 'UPDATE',
	        x_rowid             => X_ROWID

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
       x_TST_RSLT_DTLS_ID IN OUT NOCOPY NUMBER,
       x_TEST_RESULTS_ID IN NUMBER,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_TEST_SCORE IN NUMBER,
       x_PERCENTILE IN NUMBER,
       x_NATIONAL_PERCENTILE IN NUMBER,
       x_STATE_PERCENTILE IN NUMBER,
       x_PERCENTILE_YEAR_RANK IN NUMBER,
       x_SCORE_BAND_LOWER IN NUMBER,
       x_SCORE_BAND_UPPER IN NUMBER,
       x_IRREGULARITY_CODE_ID IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  RAVISHAR        Feb,25 2005     Removed the default value of X_MODE parameter from
                                  body of this package for bug 4163319
  				  GSCC standard says that default value should be
				  present only in specification

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_TST_RSLT_DTLS
             where     TST_RSLT_DTLS_ID= X_TST_RSLT_DTLS_ID
;
  L_MODE VARCHAR2(1);
begin
  L_MODE := NVL(X_MODE,'R');
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_TST_RSLT_DTLS_ID,
       X_TEST_RESULTS_ID,
       X_TEST_SEGMENT_ID,
       X_TEST_SCORE,
       X_PERCENTILE,
       X_NATIONAL_PERCENTILE,
       X_STATE_PERCENTILE,
       X_PERCENTILE_YEAR_RANK,
       X_SCORE_BAND_LOWER,
       X_SCORE_BAND_UPPER,
       X_IRREGULARITY_CODE_ID,
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
      L_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_TST_RSLT_DTLS_ID,
       X_TEST_RESULTS_ID,
       X_TEST_SEGMENT_ID,
       X_TEST_SCORE,
       X_PERCENTILE,
       X_NATIONAL_PERCENTILE,
       X_STATE_PERCENTILE,
       X_PERCENTILE_YEAR_RANK,
       X_SCORE_BAND_LOWER,
       X_SCORE_BAND_UPPER,
       X_IRREGULARITY_CODE_ID,
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
      L_MODE );
end ADD_ROW;
procedure DELETE_ROW (
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

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_AD_TST_RSLT_DTLS
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
                p_action            => 'DELETE',
                x_rowid             => X_ROWID
);

END DELETE_ROW;

END igs_ad_tst_rslt_dtls_pkg;

/
