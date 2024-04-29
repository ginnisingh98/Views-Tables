--------------------------------------------------------
--  DDL for Package Body IGS_AD_EMP_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_EMP_DTL_PKG" AS
/* $Header: IGSAI33B.pls 120.1 2005/07/16 02:01:07 appldev ship $ */
/* Change History
    Who        When         What
    Bug : 2037512
    avenkatr   08-OCT-2001  Added column 'Contact' to Insert_row and   Update_row procedures

    ssawhney  7 may 2002      Bug 2338473 -- allow for more than one HZ error to appear.
    gmaheswa  6 Nov 2003      HZ.K Impact Changes.
	pkpatel   14 Jul 2005     Bug 4327807 (Person SS Enhancement)
	                          Called the igs_ad_hz_emp_dtl_pkg.add_row instead of update_row as per value in
							  Occupitional Title Code
*/
  l_rowid VARCHAR2(25);
  l_msg_data  VARCHAR2(25);
  l_return_status  VARCHAR2(1);

  procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      x_employment_history_id OUT NOCOPY NUMBER,
      x_PERSON_ID IN NUMBER ,
      x_START_DT  IN DATE,
      x_END_DT  IN DATE,
      x_TYPE_OF_EMPLOYMENT  IN VARCHAR2,
      x_FRACTION_OF_EMPLOYMENT IN NUMBER,
      x_TENURE_OF_EMPLOYMENT IN VARCHAR2,
      x_POSITION IN VARCHAR2,
      x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
      x_OCCUPATIONAL_TITLE IN VARCHAR2,
      x_WEEKLY_WORK_HOURS  IN NUMBER,
      x_COMMENTS IN VARCHAR2,
      x_EMPLOYER IN VARCHAR2,
      x_EMPLOYED_BY_DIVISION_NAME IN VARCHAR2,
      x_BRANCH IN VARCHAR2,
      x_MILITARY_RANK IN VARCHAR2,
      x_SERVED IN VARCHAR2,
      x_STATION IN VARCHAR2,
      x_CONTACT IN VARCHAR2,     --Bug : 2037512
      x_msg_data OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2,
      x_object_version_number IN OUT NOCOPY NUMBER,
      x_employed_by_party_id IN NUMBER,
      x_reason_for_leaving IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
    CURSOR c2 IS
      SELECT ROWID
      FROM  hz_employment_history
      WHERE party_id = x_person_id;

    X_CREATED_BY  NUMBER;
    X_CREATION_DATE DATE;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
    X_LAST_UPDATE_DATE DATE ;
    X_LAST_UPDATED_BY NUMBER ;
    X_LAST_UPDATE_LOGIN NUMBER ;

    x_hz_emp_dtl_id igs_ad_hz_emp_dtl.hz_emp_dtl_id%TYPE;
    x_rowid1 VARCHAR2(25);
    l_emp_history_rec HZ_PERSON_INFO_V2PUB.employment_history_rec_type;
    l_msg_count      NUMBER;
    lrow_id varchar2(30);
    tmp_var1          VARCHAR2(2000);
    tmp_var           VARCHAR2(2000);
         CURSOR c_birth_date_val is SELECT date_of_birth FROM HZ_PERSON_PROFILES
         WHERE party_id = x_person_id AND effective_end_Date is null;
         l_date_of_birth HZ_PERSON_PROFILES.DATE_OF_BIRTH%TYPE;

  BEGIN
    x_PROGRAM_UPDATE_DATE    :=  SYSDATE;
    x_PROGRAM_ID             :=  0;
    X_PROGRAM_APPLICATION_ID :=  0;
    x_REQUEST_ID             :=  0;
    X_CREATED_BY             :=  FND_GLOBAL.USER_ID;
    X_CREATION_DATE          :=  SYSDATE;
    X_LAST_UPDATE_DATE       :=  SYSDATE;

    IF (X_MODE = 'I') THEN
       X_LAST_UPDATED_BY   :=  1;
       X_LAST_UPDATE_LOGIN :=  0;

    ELSIF (X_MODE = 'R') THEN
       X_LAST_UPDATED_BY    :=  FND_GLOBAL.USER_ID;
       IF (X_LAST_UPDATED_BY is NULL) THEN
	  X_LAST_UPDATED_BY := -1;
       END IF;
       X_LAST_UPDATE_LOGIN  :=  FND_GLOBAL.LOGIN_ID;
       IF (X_LAST_UPDATE_LOGIN is NULL) THEN
          X_LAST_UPDATE_LOGIN := -1;
       END IF;

    ELSE
       FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
       IGS_GE_MSG_STACK.ADD;
       app_exception.raise_exception;
    END IF;
    OPEN c_birth_date_val;
    FETCH c_birth_date_val INTO l_date_of_birth; CLOSE c_birth_date_val;
    IF(x_start_dt IS NOT NULL AND l_Date_of_birth IS NOT NULL) THEN
      IF(x_start_dt < l_date_of_birth) THEN
          Fnd_Message.Set_Name('IGS','IGS_PE_DREC_GT_BTDT');
          IGS_GE_MSG_STACK.ADD;
          x_msg_data := FND_MESSAGE.GET;
          x_return_status := 'E';
          l_msg_count :=1;
          RETURN;
      END IF;
    END IF;

    --If any of the fields tenure of employment or fraction of employment is not null
    --then faculty position flag is set to 'Y'
    IF x_tenure_of_employment IS NOT NULL OR x_fraction_of_employment IS NOT NULL THEN
      L_EMP_HISTORY_REC.FACULTY_POSITION_FLAG := 'Y';
    ELSE
      L_EMP_HISTORY_REC.FACULTY_POSITION_FLAG := 'N';
    END IF;

    IF x_employed_by_party_id IS NOT NULL AND x_employer IS NOT NULL THEN
        Fnd_Message.Set_Name('IGS','IGS_PE_EMP_MUT_EXCL');
        IGS_GE_MSG_STACK.ADD;
        x_msg_data := FND_MESSAGE.GET;
        x_return_status := 'E';
        l_msg_count :=1;
        RETURN;
    END IF;

    --Branch,Military_rank,serverd and station fields are obsoleted.
    L_EMP_HISTORY_REC.EMPLOYMENT_HISTORY_ID        :=  x_employment_history_id;
    L_EMP_HISTORY_REC.BEGIN_DATE                   :=  x_start_dt;
    L_EMP_HISTORY_REC.EMPLOYED_AS_TITLE            :=  x_position;
    L_EMP_HISTORY_REC.EMPLOYED_BY_DIVISION_NAME    :=  x_employed_by_division_name;
    L_EMP_HISTORY_REC.EMPLOYED_BY_NAME_COMPANY     :=  x_employer;
    L_EMP_HISTORY_REC.END_DATE                     :=  x_end_dt;
    L_EMP_HISTORY_REC.SUPERVISOR_NAME              :=  x_contact;	--Bug :2037512
    L_EMP_HISTORY_REC.PARTY_ID                     :=  x_person_id;
    L_EMP_HISTORY_REC.EMPLOYMENT_TYPE_CODE         :=  x_type_of_employment;
    L_EMP_HISTORY_REC.FRACTION_OF_TENURE           :=  x_fraction_of_employment;
    L_EMP_HISTORY_REC.TENURE_CODE                  :=  x_tenure_of_employment;
    L_EMP_HISTORY_REC.WEEKLY_WORK_HOURS            :=  x_weekly_work_hours;
    L_EMP_HISTORY_REC.COMMENTS                     :=  x_comments;
    L_EMP_HISTORY_REC.RESPONSIBILITY               :=  NULL;
    L_EMP_HISTORY_REC.CREATED_BY_MODULE            :=  'IGS';
    L_EMP_HISTORY_REC.APPLICATION_ID               :=  8405;
    L_EMP_HISTORY_REC.EMPLOYED_BY_PARTY_ID         :=  x_employed_by_party_id;
    L_EMP_HISTORY_REC.REASON_FOR_LEAVING           :=  x_reason_for_leaving;

    --HZ_API is changed from HZ_PER_INFO_PUB to HZ_PERSON_INFO_V2PUB
    HZ_PERSON_INFO_V2PUB.create_employment_history(
                 P_INIT_MSG_LIST		=> FND_API.G_TRUE,
                 P_EMPLOYMENT_HISTORY_REC	=> l_EMP_HISTORY_REC,
		 X_EMPLOYMENT_HISTORY_ID        => x_employment_history_id,
 	         X_RETURN_STATUS      		=> x_return_status,
	         X_MSG_COUNT              	=> l_msg_count,
 	         X_MSG_DATA                    	=> x_msg_data

	);


    IF x_RETURN_STATUS IN ('E','U') THEN
       IF l_msg_count > 1 THEN
         FOR i IN 1..l_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
         END LOOP;
         x_msg_data := tmp_var1;
        END IF;
        RETURN;
    END IF;

    OPEN c2;
    FETCH c2 INTO X_ROWID;
    IF (c2%notfound) THEN
       CLOSE c2;
       RAISE no_data_found;
    END  IF;
    CLOSE c2;

    x_object_version_number := 1;

    --Type_pf_employment,fraction_of_employment,tenure_of_employment,weekly_work_hours,comments are mde obsolete
    -- as they are passed to HZ_API's
    igs_ad_hz_emp_dtl_pkg.insert_row(
	       X_ROWID			 => lrow_id,
	       X_HZ_EMP_DTL_ID		 => x_hz_emp_dtl_id,
	       X_EMPLOYMENT_HISTORY_ID	 => x_employment_history_id,
	       X_TYPE_OF_EMPLOYMENT	 => null,
	       X_FRACION_OF_EMPLOYMENT	 => null,
	       X_TENURE_OF_EMPLOYMENT 	 => null,
	       X_OCCUPATIONAL_TITLE_CODE => x_occupational_title_code,
	       X_WEEKLY_WORK_HOURS	 => null,
	       X_COMMENTS		 => null,
	       X_MODE			 => x_mode
	);


  END INSERT_ROW;



  procedure UPDATE_ROW (
         X_ROWID in  VARCHAR2,
         x_employment_history_id IN NUMBER,
         x_PERSON_ID IN NUMBER,
         x_START_DT IN DATE,
         x_END_DT IN DATE,
         x_TYPE_OF_EMPLOYMENT IN VARCHAR2,
         x_FRACTION_OF_EMPLOYMENT IN NUMBER,
         x_TENURE_OF_EMPLOYMENT IN VARCHAR2,
         x_POSITION IN VARCHAR2,
         x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
         x_OCCUPATIONAL_TITLE IN VARCHAR2,
         x_WEEKLY_WORK_HOURS IN NUMBER,
         x_COMMENTS IN VARCHAR2,
         x_EMPLOYER IN VARCHAR2,
         x_EMPLOYED_BY_DIVISION_NAME IN VARCHAR2,
         x_BRANCH IN VARCHAR2,
         x_MILITARY_RANK IN VARCHAR2,
         x_SERVED IN VARCHAR2,
         x_STATION IN VARCHAR2,
         x_CONTACT IN VARCHAR2,      -- Bug : 2037512
         x_msg_data OUT NOCOPY VARCHAR2,
         x_return_status OUT NOCOPY VARCHAR2,
	 x_object_version_number IN OUT NOCOPY NUMBER,
         x_employed_by_party_id IN NUMBER,
         x_reason_for_leaving IN VARCHAR2,
         X_MODE in VARCHAR2 default 'R'
  ) AS

    l_hz_emp_dtl_id igs_ad_hz_emp_dtl.hz_emp_dtl_id%TYPE;
    l_LAST_UPDATED_BY NUMBER ;
    l_LAST_UPDATE_LOGIN NUMBER ;
    l_msg_count NUMBER;
    l_emp_history_rec HZ_PERSON_INFO_V2PUB.employment_history_rec_type;
    lv_rowid VARCHAR2(25);
	l_occupational_title_code igs_ad_emp_dtl.occupational_title_code%TYPE;

    tmp_var1          VARCHAR2(2000);
    tmp_var           VARCHAR2(2000);

    CURSOR C2  is
    SELECT rowid,hz_emp_dtl_id, occupational_title_code
    FROM igs_ad_hz_emp_dtl
    WHERE employment_history_id = x_employment_history_id;

    CURSOR c_birth_date_val is SELECT date_of_birth FROM HZ_PERSON_PROFILES
         WHERE party_id = x_person_id AND effective_end_Date is null;
         l_date_of_birth HZ_PERSON_PROFILES.DATE_OF_BIRTH%TYPE;


  BEGIN

    IF (X_MODE = 'I') THEN
       l_LAST_UPDATED_BY   :=  1;
       l_LAST_UPDATE_LOGIN :=  0;

    ELSIF (X_MODE = 'R') THEN
       l_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
       IF  (l_LAST_UPDATED_BY is NULL) THEN
           l_LAST_UPDATED_BY := -1;
       END IF;
       l_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
       IF  (l_LAST_UPDATE_LOGIN is NULL) THEN
           l_LAST_UPDATE_LOGIN := -1;
       END IF;

    ELSE
       FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
       IGS_GE_MSG_STACK.ADD;
       app_exception.raise_exception;
    END IF;
    OPEN c_birth_date_val; FETCH c_birth_date_val INTO l_date_of_birth; CLOSE c_birth_date_val;
    IF(x_start_dt IS NOT NULL AND l_Date_of_birth IS NOT NULL) THEN
      IF(x_start_dt < l_date_of_birth) THEN
          Fnd_Message.Set_Name('IGS','IGS_PE_DREC_GT_BTDT');
          IGS_GE_MSG_STACK.ADD;
          x_msg_data := FND_MESSAGE.GET;
          x_return_status := 'E';
          l_msg_count :=1;
          RETURN;
      END IF;
    END IF;

    --If any of the fields tenure of employment or fraction of employment is not null
    --then faculty position flag is set to 'Y'

    IF x_tenure_of_employment IS NOT NULL OR x_fraction_of_employment IS NOT NULL THEN
      L_EMP_HISTORY_REC.FACULTY_POSITION_FLAG := 'Y';
    ELSE
      L_EMP_HISTORY_REC.FACULTY_POSITION_FLAG := 'N';
    END IF;

    IF x_employed_by_party_id IS NOT NULL AND x_employer IS NOT NULL THEN
        Fnd_Message.Set_Name('IGS','IGS_PE_EMP_MUT_EXCL');
        IGS_GE_MSG_STACK.ADD;
        x_msg_data := FND_MESSAGE.GET;
        x_return_status := 'E';
        l_msg_count :=1;
        RETURN;
    END IF;

    --Branch,Military_rank,serverd and station fields are obsoleted.
    L_EMP_HISTORY_REC.EMPLOYMENT_HISTORY_ID       :=  x_employment_history_id;
    L_EMP_HISTORY_REC.BEGIN_DATE                  :=  x_start_dt;
    L_EMP_HISTORY_REC.EMPLOYED_AS_TITLE           :=  NVL(x_position,FND_API.G_MISS_CHAR);
    L_EMP_HISTORY_REC.EMPLOYED_BY_DIVISION_NAME   :=  NVL(x_employed_by_division_name,FND_API.G_MISS_CHAR);
    L_EMP_HISTORY_REC.EMPLOYED_BY_NAME_COMPANY    :=  NVL(x_employer,FND_API.G_MISS_CHAR);
    L_EMP_HISTORY_REC.END_DATE                    :=  NVL(x_end_dt,FND_API.G_MISS_DATE);
    L_EMP_HISTORY_REC.SUPERVISOR_NAME             :=  NVL(x_contact,FND_API.G_MISS_CHAR);	--Bug :2037512
    L_EMP_HISTORY_REC.PARTY_ID                    :=  x_person_id;
    L_EMP_HISTORY_REC.EMPLOYMENT_TYPE_CODE        :=  NVL(x_type_of_employment,FND_API.G_MISS_CHAR);
    L_EMP_HISTORY_REC.FRACTION_OF_TENURE          :=  NVL(x_fraction_of_employment,FND_API.G_MISS_NUM);
    L_EMP_HISTORY_REC.TENURE_CODE                 :=  NVL(x_tenure_of_employment,FND_API.G_MISS_CHAR);
    L_EMP_HISTORY_REC.WEEKLY_WORK_HOURS           :=  NVL(x_weekly_work_hours,FND_API.G_MISS_NUM);
    L_EMP_HISTORY_REC.COMMENTS                    :=  NVL(x_comments,FND_API.G_MISS_CHAR);
    L_EMP_HISTORY_REC.RESPONSIBILITY              :=  NULL;
    L_EMP_HISTORY_REC.EMPLOYED_BY_PARTY_ID        :=  NVL(x_employed_by_party_id,FND_API.G_MISS_NUM);
    L_EMP_HISTORY_REC.REASON_FOR_LEAVING          :=  NVL(x_reason_for_leaving,FND_API.G_MISS_CHAR);

    --HZ_API is changed from HZ_PER_INFO_PUB to HZ_PERSON_INFO_V2PUB
    HZ_PERSON_INFO_V2PUB.update_employment_history(
           P_INIT_MSG_LIST      => FND_API.G_TRUE,
           P_EMPLOYMENT_HISTORY_REC    => l_EMP_HISTORY_REC,
		   P_OBJECT_VERSION_NUMBER => x_object_version_number,
           X_RETURN_STATUS      => x_return_status,
           X_MSG_COUNT          => l_msg_count,
		   X_MSG_DATA           => x_msg_data
          );

    IF  (x_RETURN_STATUS NOT IN ('E','U')) THEN

      OPEN C2;
      FETCH C2 INTO lv_rowid,l_hz_emp_dtl_id, l_occupational_title_code;
      CLOSE C2;


         --Type_pf_employment,fraction_of_employment,tenure_of_employment,weekly_work_hours,comments are mde obsolete
         -- as they are passed to HZ_API's
      IF NVL(l_occupational_title_code, '-1') <> NVL(x_occupational_title_code, '-1') THEN
         igs_ad_hz_emp_dtl_pkg.add_row(
	        X_ROWID                   => lv_rowid,
	        X_HZ_EMP_DTL_ID           => l_hz_emp_dtl_id,
	        X_EMPLOYMENT_HISTORY_ID   => x_employment_history_id,
	        X_TYPE_OF_EMPLOYMENT      => null, --x_type_of_employment,
	        X_FRACION_OF_EMPLOYMENT   => null, --x_fraction_of_employment,
	        X_TENURE_OF_EMPLOYMENT    => null, --x_tenure_of_employment,
	        X_OCCUPATIONAL_TITLE_CODE => x_occupational_title_code,
	        X_WEEKLY_WORK_HOURS       => null, --x_weekly_work_hours,
	        X_COMMENTS                => null, --x_comments,
	        X_MODE                    => x_mode
	        );
      END  IF;


    ELSE
       -- this means that the HZ record update gave an error
        IF l_msg_count > 1 THEN
         FOR i IN 1..l_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
         END LOOP;
         x_msg_data := tmp_var1;
        END IF;
    RETURN;
    END IF;

  END  UPDATE_ROW;

  procedure DELETE_ROW (
      X_ROWID in VARCHAR2
  ) AS
  Begin
       igs_ad_hz_emp_dtl_pkg.delete_row(x_rowid);
  end DELETE_ROW;


END igs_ad_emp_dtl_pkg;

/
