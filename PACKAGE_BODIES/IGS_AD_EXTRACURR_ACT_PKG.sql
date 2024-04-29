--------------------------------------------------------
--  DDL for Package Body IGS_AD_EXTRACURR_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_EXTRACURR_ACT_PKG" AS
/* $Header: IGSAI85B.pls 115.18 2003/11/27 13:25:18 gmaheswa ship $ */
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_interest_id                OUT NOCOPY     NUMBER,
    x_person_id                         IN     NUMBER,
    x_interest_type_code                IN     VARCHAR2,
    x_comments                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_level_of_interest                 IN     VARCHAR2,
    x_level_of_participation            IN     VARCHAR2,
    x_sport_indicator                   IN     VARCHAR2,
    x_sub_interest_type_code            IN     VARCHAR2,
    x_interest_name                     IN     VARCHAR2,
    x_team                              IN     VARCHAR2,
    x_wh_update_date                    IN     DATE,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL,
    x_last_update_date                  OUT NOCOPY    DATE,
    x_msg_Data                          OUT NOCOPY    VARCHAR2,
    x_return_Status                     OUT NOCOPY    VARCHAR2,
    x_object_version_number             IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
          p_per_interest_rec Hz_Person_Info_V2Pub.person_interest_rec_type;
          l_return_status     VARCHAR2(1);
          l_msg_count         NUMBER;
          l_msg_Data         VARCHAR2(200);
          l_person_interest_id        NUMBER;
          l_RowId                    VARCHAR2(25);
          l_hz_extracurr_act_id        NUMBER;

    tmp_var1          VARCHAR2(2000);
    tmp_var           VARCHAR2(2000);
         CURSOR c_birth_date_val is SELECT date_of_birth FROM HZ_PERSON_PROFILES
         WHERE party_id = x_person_id AND effective_end_Date is null;
	 l_date_of_birth HZ_PERSON_PROFILES.DATE_OF_BIRTH%TYPE;


  BEGIN

  		-- A few validation that need to be done
		-- added by amuthu during ID prospective applicant part 2 of 1 build

        IF NOT (x_start_date <= x_end_date)  THEN
          Fnd_Message.Set_Name('IGS','IGS_FI_ST_DT_LE_END_DT');
          IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  l_msg_count :=1;
		  x_return_status := 'E';
          RETURN;
        ELSIF NOT (x_start_date <= SYSDATE ) THEN
          Fnd_Message.Set_Name('IGS','IGS_AD_ST_DT_LT_SYS_DT');
          IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  l_msg_count :=1;
		  x_return_status := 'E';
		  RETURN;
        END IF;

	IF x_start_date IS NULL AND x_end_date IS NOT NULL THEN
		  Fnd_Message.Set_Name('IGS','IGS_EN_TS_SDT');
                  IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  x_return_status := 'E';
		  l_msg_count :=1;
		  RETURN;
        END IF;

        IF NOT (x_end_date >= x_start_date OR x_end_date IS NULL)  THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_END_DT_GE_ST_DATE');
          IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  x_return_status := 'E';
		  l_msg_count :=1;
		  RETURN;
        END IF;

        IF NOT (x_hours_per_week >= 0
            AND x_hours_per_week <= 168 )  THEN
          Fnd_Message.Set_Name('IGS','IGS_AD_HRS_PER_WEEK');
          IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  x_return_status := 'E';
		  l_msg_count :=1;
		  RETURN;
        END IF;

        IF NOT (x_weeks_per_year >= 0
              AND x_weeks_per_year <= 52 )  THEN
          Fnd_Message.Set_Name('IGS','IGS_AD_WKS_PER_YEAR');
          IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  x_return_status := 'E';
		  l_msg_count :=1;
		  RETURN;
        END IF;
	OPEN c_birth_date_val; FETCH c_birth_date_val INTO l_date_of_birth; CLOSE c_birth_date_val;
	IF(x_start_date IS NOT NULL AND l_Date_of_birth IS NOT NULL) THEN
	 IF(x_start_date < l_date_of_birth) THEN
	    Fnd_Message.Set_Name('IGS','IGS_PE_DREC_GT_BTDT');
            IGS_GE_MSG_STACK.ADD;
	    x_msg_data := FND_MESSAGE.GET;
	    x_return_status := 'E';
	    l_msg_count :=1;
	    RETURN;
	 END IF;
	END IF;

        p_per_interest_rec.level_of_interest          := x_level_of_interest;
        p_per_interest_rec.level_of_participation     := x_level_of_Participation;
        p_per_interest_rec.interest_type_code         := x_interest_type_code;
        p_per_interest_rec.party_id                   := x_person_id;
        p_per_interest_rec.sport_indicator            := x_Sport_Indicator;
        p_per_interest_rec.interest_name              := x_Interest_Name;
        p_per_interest_rec.comments                   := x_Comments;
        p_per_interest_rec.sub_interest_type_code     := x_Sub_Interest_Type_Code;
        p_per_interest_rec.team                       := x_team;
        p_per_interest_rec.since                      := x_Start_Date;
        p_per_interest_rec.created_by_module          := 'IGS';
        p_per_interest_rec.application_id             := 8405;
        -- initialize message count.

        l_msg_count :=0;
	--gmaheswa: HZ_API ia changed to HZ_PERSON_INFOR_V2PUB from HZ_PER_INFO_PUB.
	    Hz_Person_Info_V2Pub.create_person_interest(
                        p_init_msg_list    => FND_API.G_TRUE,
                        p_person_interest_rec => p_per_interest_rec,
			x_person_interest_id    => l_person_interest_id,
                        x_return_status    => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data    => l_msg_data

		);


        x_return_status := l_return_Status;

        IF l_return_status IN ('E','U') THEN
          IF l_msg_count > 1 THEN
		FOR i IN 1..l_msg_count  LOOP
		 tmp_var := fnd_msg_pub.get(p_msg_index =>i, p_encoded => fnd_api.g_false);
		 tmp_var1 := tmp_var1 || ' '|| tmp_var;
	        END LOOP;
                x_msg_data := tmp_var1;
          ELSE
	        x_msg_data := l_msg_data;
	  END IF;

	  RETURN;

        ELSE

		  x_person_interest_id := l_person_interest_id;
                  x_object_version_number := 1;
          -- selecting the value of the last_update_date ot pass
          -- it back to the calling form to enable locking when the record
          -- is updated immediately after inserting.

          Igs_Ad_Hz_Extracurr_Act_Pkg.Insert_Row(
                        x_rowid  => l_rowId,
                        x_hz_extracurr_act_id => l_hz_extracurr_act_id,
                        x_person_interest_id  => x_person_interest_id,
                        x_end_date => x_End_Date,
                        x_hours_per_week => x_Hours_per_Week,
                        x_weeks_per_year => x_Weeks_Per_Year,
                        x_activity_source_cd => x_activity_source_cd,
                        x_mode => 'R') ;
          x_rowid := l_rowId;
        END IF;

  END insert_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_interest_id                IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_interest_type_code                IN     VARCHAR2,
    x_comments                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_level_of_interest                 IN     VARCHAR2,
    x_level_of_participation            IN     VARCHAR2,
    x_sport_indicator                   IN     VARCHAR2,
    x_sub_interest_type_code            IN     VARCHAR2,
    x_interest_name                     IN     VARCHAR2,
    x_team                              IN     VARCHAR2,
    x_wh_update_date                    IN     DATE,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL,
    x_last_update_date                  IN OUT NOCOPY DATE,
    x_msg_Data                            OUT NOCOPY    VARCHAR2,
    x_return_Status                        OUT NOCOPY    VARCHAR2,
    x_object_version_number             IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@oracle.com
  ||  Created On : 07-SEP-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
          p_per_interest_rec Hz_Person_Info_V2Pub.person_interest_rec_type;
          l_return_status     VARCHAR2(1);
          l_msg_count         NUMBER;
          l_msg_Data         VARCHAR2(200);
          l_person_interest_id        NUMBER;
          l_RowId                    VARCHAR2(25);
          l_hz_extracurr_act_id        NUMBER;
          lv_Last_Update_Date        DATE;
          CURSOR C1 IS
                SELECT
                        ROWID, HZ_EXTRACURR_ACT_ID
                FROM
                        IGS_AD_HZ_EXTRACURR_ACT
                WHERE
                         PERSON_INTEREST_ID = x_person_interest_id;
	tmp_var1          VARCHAR2(2000);
	tmp_var           VARCHAR2(2000);

	 CURSOR c_birth_date_val is SELECT date_of_birth FROM HZ_PERSON_PROFILES
         WHERE party_id = x_person_id AND effective_end_Date is null;
	 l_date_of_birth HZ_PERSON_PROFILES.DATE_OF_BIRTH%TYPE;


  BEGIN

		-- A few validation that need to be done

        -- The following code checks for check constraints on the Columns.

        IF NOT (x_start_date <= x_end_date)  THEN
          Fnd_Message.Set_Name('IGS','IGS_FI_ST_DT_LE_END_DT');
          IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  x_return_status := 'E';
          RETURN;
        ELSIF NOT (x_start_date <= SYSDATE ) THEN
          Fnd_Message.Set_Name('IGS','IGS_AD_ST_DT_LT_SYS_DT');
          IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  x_return_status := 'E';
		  RETURN;
        END IF;

		IF x_start_date IS NULL AND x_end_date IS NOT NULL THEN
		  Fnd_Message.Set_Name('IGS','IGS_EN_TS_SDT');
          IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  x_return_status := 'E';
		  RETURN;
        END IF;

        IF NOT (x_end_date >= x_start_date OR x_end_date IS NULL)  THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_END_DT_GE_ST_DATE');
          IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  x_return_status := 'E';
		  RETURN;
        END IF;

        IF NOT (x_hours_per_week >= 0
            AND x_hours_per_week <= 168 )  THEN
          Fnd_Message.Set_Name('IGS','IGS_AD_HRS_PER_WEEK');
          IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  x_return_status := 'E';
		  RETURN;
        END IF;

        IF NOT (x_weeks_per_year >= 0
              AND x_weeks_per_year <= 52 )  THEN
          Fnd_Message.Set_Name('IGS','IGS_AD_WKS_PER_YEAR');
          IGS_GE_MSG_STACK.ADD;
		  x_msg_data := FND_MESSAGE.GET;
		  x_return_status := 'E';
		  RETURN;
        END IF;
	OPEN c_birth_date_val; FETCH c_birth_date_val INTO l_date_of_birth; CLOSE c_birth_date_val;
	IF(x_start_date IS NOT NULL AND l_Date_of_birth IS NOT NULL) THEN
	 IF(x_start_date < l_date_of_birth) THEN
	    Fnd_Message.Set_Name('IGS','IGS_PE_DREC_GT_BTDT');
            IGS_GE_MSG_STACK.ADD;
	    x_msg_data := FND_MESSAGE.GET;
	    x_return_status := 'E';
	    l_msg_count :=1;
	    RETURN;
	 END IF;
	END IF;


        p_per_interest_rec.person_interest_id          := x_person_interest_id;
        p_per_interest_rec.level_of_interest           := NVL(x_level_of_interest,FND_API.G_MISS_CHAR);
        p_per_interest_rec.level_of_participation      := NVL(x_level_of_Participation,FND_API.G_MISS_CHAR);
        p_per_interest_rec.interest_type_code          := NVL(x_interest_type_code,FND_API.G_MISS_CHAR);
        p_per_interest_rec.party_id                    := x_person_id;
        p_per_interest_rec.sport_indicator             := NVL(x_Sport_Indicator,FND_API.G_MISS_CHAR);
        p_per_interest_rec.interest_name               := NVL(x_Interest_Name,FND_API.G_MISS_CHAR);
        p_per_interest_rec.comments                    := NVL(x_Comments,FND_API.G_MISS_CHAR);
        p_per_interest_rec.sub_interest_type_code      := NVL(x_Sub_Interest_Type_Code,FND_API.G_MISS_CHAR);
        p_per_interest_rec.team                        := NVL(x_team,FND_API.G_MISS_CHAR);
        p_per_interest_rec.since                       := NVL(x_Start_Date,FND_API.G_MISS_DATE);

	--gmaheswa: HZ_API ia changed to HZ_PERSON_INFOR_V2PUB from HZ_PER_INFO_PUB.
	Hz_Person_Info_V2Pub.Update_person_interest(
                        p_init_msg_list    => FND_API.G_TRUE,
		        p_person_interest_rec => p_per_interest_rec,
			p_object_version_number  => x_object_version_number,
                        x_return_status    => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data    => l_msg_data

		);

        x_return_status := l_return_Status;

        IF l_return_status IN ('E','U') THEN

	  IF l_msg_count > 1 THEN
             FOR i IN 1..l_msg_count  LOOP
               tmp_var := fnd_msg_pub.get(p_msg_index =>i, p_encoded => fnd_api.g_false);
               tmp_var1 := tmp_var1 || ' '|| tmp_var;
             END LOOP;
             x_msg_data := tmp_var1;
          ELSE
	     x_msg_data := l_msg_data;
	  END IF;
          RETURN;

        ELSE

          OPEN C1;
          FETCH C1 INTO l_RowId, l_hz_ExtraCurr_Act_Id;
          CLOSE C1;
          Igs_Ad_Hz_Extracurr_Act_Pkg.Update_Row(
                        x_rowid  => l_rowId,
                        x_hz_extracurr_act_id => l_hz_ExtraCurr_Act_Id,
                        x_person_interest_id  => x_person_interest_id,
                        x_end_date => x_End_Date,
                        x_hours_per_week => x_Hours_per_Week,
                        x_weeks_per_year => x_Weeks_Per_Year,
                        x_activity_source_cd => x_activity_source_cd,
                        x_mode => 'R') ;
        END IF;
  END update_row;


END Igs_Ad_Extracurr_Act_Pkg;

/
