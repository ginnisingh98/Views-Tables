--------------------------------------------------------
--  DDL for Package Body IGS_SS_TST_RSLT_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SS_TST_RSLT_DTLS_PKG" AS
/* $Header: IGSSS07B.pls 115.6 2003/10/30 13:32:33 rghosh noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ss_tst_rslt_dtls%RowType;
  new_references igs_ss_tst_rslt_dtls%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tst_rslt_dtls_id IN NUMBER DEFAULT NULL,
    x_test_results_id IN NUMBER DEFAULT NULL,
    x_test_segment_id IN NUMBER DEFAULT NULL,
    x_test_score IN NUMBER DEFAULT NULL,
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
  Nishikant       13jun2002       the message IGS_AD_SCORE_NOT_LT_ZERO was being
                                  set with FND application, which got modified to IGS.
                                  as per bug#2413811.
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_SS_TST_RSLT_DTLS
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      --Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
-- bug#2413811 - Nishikant - 13jun2002
-- The below message was being set with FND application, which got modified to IGS.
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SCORE_NOT_LT_ZERO');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.ss_tst_rslt_dtls_id := x_tst_rslt_dtls_id;
    new_references.ss_test_results_id := x_test_results_id;
    new_references.test_segment_id := x_test_segment_id;
    new_references.test_score := x_test_score;
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
      ELSIF  UPPER(column_name) = 'TEST_SCORE'  THEN
        new_references.test_score := IGS_GE_NUMBER.TO_NUM(column_value);
        NULL;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'TEST_SCORE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.test_score>=0)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_SCORE_NOT_LT_ZERO');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
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
    		new_references.ss_test_results_id
    		,new_references.test_segment_id
    		) THEN
 		         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                 FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
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

    IF (((old_references.ss_test_results_id = new_references.SS_test_results_id)) OR
        ((new_references.SS_test_results_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Test_Results_Pkg.Get_PK_For_Validation (
        		new_references.SS_test_results_id
        )  THEN
	       Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (((old_references.test_segment_id = new_references.test_segment_id)) OR
        ((new_references.test_segment_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Test_Segments_Pkg.Get_PK_For_Validation (
        		new_references.test_segment_id,
            'N'
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
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
      FROM     igs_ss_tst_rslt_dtls
      WHERE    ss_tst_rslt_dtls_id = x_tst_rslt_dtls_id
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
      FROM     igs_ss_tst_rslt_dtls
      WHERE    ss_test_results_id = x_test_results_id
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
      FROM     igs_ss_tst_rslt_dtls
      WHERE    ss_test_results_id = x_test_results_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATRD_ATR_FK');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
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
      FROM     igs_ss_tst_rslt_dtls
      WHERE    test_segment_id = x_test_segment_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATRD_ATS_FK');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Test_Segments;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tst_rslt_dtls_id IN NUMBER DEFAULT NULL,
    x_test_results_id IN NUMBER DEFAULT NULL,
    x_test_segment_id IN NUMBER DEFAULT NULL,
    x_test_score IN NUMBER DEFAULT NULL,
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

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_tst_rslt_dtls_id,
      x_test_results_id,
      x_test_segment_id,
      x_test_score,
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
    		new_references.ss_tst_rslt_dtls_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
     FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
      --Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Uniqueness;
      Check_Constraints;
      --Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.ss_tst_rslt_dtls_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
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
       x_TST_RSLT_DTLS_ID IN OUT NOCOPY NUMBER,
       x_TEST_RESULTS_ID IN NUMBER,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_TEST_SCORE IN NUMBER,
      X_MODE in VARCHAR2 default 'I'
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

    cursor C is select ROWID from IGS_SS_TST_RSLT_DTLS
             where                 SS_TST_RSLT_DTLS_ID= X_TST_RSLT_DTLS_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 begin
    X_LAST_UPDATE_DATE := SYSDATE;
    if(X_MODE = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    else
      FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
      SELECT IGS_SS_TST_RSLT_DTLS_S.NEXTVAL  INTO X_TST_RSLT_DTLS_ID  FROM DUAL;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_tst_rslt_dtls_id=>X_TST_RSLT_DTLS_ID,
 	       x_test_results_id=>X_TEST_RESULTS_ID,
 	       x_test_segment_id=>X_TEST_SEGMENT_ID,
 	       x_test_score=>X_TEST_SCORE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_SS_TST_RSLT_DTLS (
		SS_TST_RSLT_DTLS_ID
		,SS_TEST_RESULTS_ID
		,TEST_SEGMENT_ID
		,TEST_SCORE
        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.SS_TST_RSLT_DTLS_ID
	        ,NEW_REFERENCES.SS_TEST_RESULTS_ID
	        ,NEW_REFERENCES.TEST_SEGMENT_ID
	        ,NEW_REFERENCES.TEST_SCORE
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
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
       x_TST_RSLT_DTLS_ID IN NUMBER,
       x_TEST_RESULTS_ID IN NUMBER,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_TEST_SCORE IN NUMBER
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

   cursor c1 is select
      SS_TEST_RESULTS_ID
,      TEST_SEGMENT_ID
,      TEST_SCORE
    from IGS_SS_TST_RSLT_DTLS
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      FND_MSG_PUB.ADD;

    close c1;
     RAISE FND_API.G_EXC_ERROR;
    return;
  end if;
  close c1;
if ( (  tlinfo.SS_TEST_RESULTS_ID = X_TEST_RESULTS_ID)
  AND (tlinfo.TEST_SEGMENT_ID = X_TEST_SEGMENT_ID)
  AND ((tlinfo.TEST_SCORE = X_TEST_SCORE)
 	    OR ((tlinfo.TEST_SCORE is null)
		AND (X_TEST_SCORE is null)))
  ) then
    null;
  else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  end if;
  return;
end LOCK_ROW;
 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_TST_RSLT_DTLS_ID IN NUMBER,
       x_TEST_RESULTS_ID IN NUMBER,
       x_TEST_SEGMENT_ID IN NUMBER,
       x_TEST_SCORE IN NUMBER,
      X_MODE in VARCHAR2 default 'I'
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
 begin
    X_LAST_UPDATE_DATE := SYSDATE;
    if(X_MODE = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    else
      FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;
   Before_DML(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_tst_rslt_dtls_id=>X_TST_RSLT_DTLS_ID,
 	       x_test_results_id=>X_TEST_RESULTS_ID,
 	       x_test_segment_id=>X_TEST_SEGMENT_ID,
 	       x_test_score=>X_TEST_SCORE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);


   update IGS_SS_TST_RSLT_DTLS set
      SS_TEST_RESULTS_ID =  NEW_REFERENCES.SS_TEST_RESULTS_ID,
      TEST_SEGMENT_ID =  NEW_REFERENCES.TEST_SEGMENT_ID,
      TEST_SCORE =  NEW_REFERENCES.TEST_SCORE,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
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
        X_ROWID             IN OUT NOCOPY VARCHAR2,
        x_TST_RSLT_DTLS_ID  IN OUT NOCOPY NUMBER,
        x_TEST_RESULTS_ID   IN NUMBER,
        x_TEST_SEGMENT_ID   IN NUMBER,
        x_TEST_SCORE        IN NUMBER,
        X_MODE              in VARCHAR2 default 'I',
        x_return_status		OUT NOCOPY     VARCHAR2,
        x_msg_count			OUT NOCOPY     NUMBER,
        x_msg_data			OUT NOCOPY     VARCHAR2
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
    l_api_name      	        CONSTANT VARCHAR2(30) := 'update_test_result_details';
    l_api_version           	CONSTANT  NUMBER       := 1.0;
	l_count				        NUMBER;

    cursor c1 is select ROWID
                    from IGS_SS_TST_RSLT_DTLS
                    where     SS_TST_RSLT_DTLS_ID= X_TST_RSLT_DTLS_ID;
begin

    --Standard start of API savepoint
        SAVEPOINT update_test_result_details;

    --Initialize message list if p_init_msg_list is set to TRUE.
       -- IF FND_API.to_Boolean(p_init_msg_list) THEN
       --         FND_MSG_PUB.initialize;
       -- END IF;

    --Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

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
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
        X_ROWID,
       X_TST_RSLT_DTLS_ID,
       X_TEST_RESULTS_ID,
       X_TEST_SEGMENT_ID,
       X_TEST_SCORE,
      X_MODE );

--Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
       		ROLLBACK TO update_test_result_details;
	        x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
				p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO update_test_result_details;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
				p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
		ROLLBACK TO update_test_result_details;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MESSAGE.SET_NAME('IGS', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
				p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
end ADD_ROW;
END IGS_SS_TST_RSLT_DTLS_PKG;

/
