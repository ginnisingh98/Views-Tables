--------------------------------------------------------
--  DDL for Package Body IGS_PE_HZ_CONT_PREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_HZ_CONT_PREF_PKG" AS
/* $Header: IGSNIB2B.pls 115.1 2003/06/17 09:03:18 ssawhney noship $ */

g_error_msg VARCHAR2(2000);

PROCEDURE date_validate
(p_start_date IN hz_contact_preferences.PREFERENCE_START_DATE%TYPE,
 p_end_date IN hz_contact_preferences.PREFERENCE_END_DATE%TYPE,
 p_person_id IN hz_parties.party_id%TYPE,
 x_msg_data OUT NOCOPY varchar2,
 p_mode IN VARCHAR2)
AS
/*
||  Created By : SSAWHNEY@oracle.com
||  Created On : 5-JUN-2003
||  Purpose : checking for start date <= end date and start date >= birth date
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/
CURSOR c_person_db (cp_person_id HZ_PARTIES.PARTY_ID%TYPE)IS
SELECT birth_date FROM igs_pe_person_base_v
WHERE person_id = cp_person_id;
l_date DATE := null;

BEGIN

    IF p_start_date > NVL(p_end_date,TO_DATE('4712/12/31','YYYY/MM/DD')) THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_PE_FROM_DT_GRT_TO_DATE');
       x_msg_data := 'IGS_PE_FROM_DT_GRT_TO_DATE';
       IGS_GE_MSG_STACK.ADD;

	   IF p_mode = 'R' THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
	   ELSE
         RETURN;
	   END IF;

    END IF;

    OPEN c_person_db(p_person_id);
    FETCH c_person_db INTO l_date;
    CLOSE c_person_db;

    IF p_start_date < NVL(l_date, p_start_date) THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_STRT_DT_LESS_BIRTH_DT');
       x_msg_data := 'IGS_AD_STRT_DT_LESS_BIRTH_DT';
       IGS_GE_MSG_STACK.ADD;

	   IF p_mode = 'R' THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
	   ELSE
         RETURN;
	   END IF;

    END IF;

END date_validate;

--Local procedure to check for duplicate records


 PROCEDURE val_overlap_api(
  p_person_id   hz_contact_preferences.CONTACT_LEVEL_TABLE_ID%TYPE,
  p_start_date  DATE,
  p_end_date    DATE,
  p_cpid NUMBER,
  x_msg_data OUT NOCOPY varchar2,
  p_mode IN VARCHAR2
  )
   AS
  /*
  ||  Created By : VRATHI@oracle.com
  ||  Created On : 10-JUN-2003
  ||  Purpose : checking for duplicate office hours records
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first) */

    --l_nvl_end DATE := NVL(p_END_DATE,TO_DATE('4712/12/31','YYYY/MM/DD'));

    CURSOR c_validate_overlap_dates ( cp_person_id hz_contact_preferences.CONTACT_LEVEL_TABLE_ID%TYPE,
     cp_start_date  DATE,
     cp_end_date    DATE,
     cp_cpid NUMBER)
    IS
    SELECT 1
    FROM   hz_contact_preferences
    WHERE  contact_level_table_id   =  cp_person_id
    AND    contact_type = 'VISIT'
    AND    ( cp_cpid IS NULL OR contact_preference_id <> cp_cpid)
    AND  (NVL(preference_END_DATE,TO_DATE('4712/12/31','YYYY/MM/DD')) >= cp_start_date OR
          NVL(preference_END_DATE,TO_DATE('4712/12/31','YYYY/MM/DD')) >= cp_end_date)
    AND  (preference_START_DATE <= cp_start_date OR  preference_START_DATE <= cp_end_date);

    l_count NUMBER := 0;

   BEGIN

        OPEN c_validate_overlap_dates ( p_person_id,p_start_date,p_end_date,p_cpid);
        FETCH c_validate_overlap_dates INTO l_count;
        IF c_validate_overlap_dates%FOUND THEN
		--overlap exists
           CLOSE c_validate_overlap_dates;
    	   FND_MESSAGE.SET_NAME('IGS','IGS_GE_DATES_OVERLAP');
	       x_msg_data :='IGS_GE_DATES_OVERLAP';
	       IGS_GE_MSG_STACK.ADD;

		   IF p_mode = 'R' THEN
			 APP_EXCEPTION.RAISE_EXCEPTION;
		   ELSE
			 RETURN;
		   END IF;

        END IF;

        CLOSE c_validate_overlap_dates;

  END val_overlap_api;

 procedure INSERT_ROW (
       X_MSG_COUNT OUT NOCOPY NUMBER,
       X_MSG_DATA  OUT NOCOPY VARCHAR2,
       X_RETURN_STATUS OUT NOCOPY VARCHAR2,
       X_ROWID in out NOCOPY VARCHAR2,
       x_CONTACT_PREFERENCE_ID IN OUT NOCOPY NUMBER,
       x_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
       X_CONTACT_LEVEL_TABLE  IN  VARCHAR2,
       X_CONTACT_LEVEL_TABLE_ID IN  NUMBER,
       X_CONTACT_TYPE  IN  VARCHAR2,
       X_PREFERENCE_CODE  IN  VARCHAR2,
       X_PREFERENCE_START_DATE  IN  DATE,
       X_PREFERENCE_END_DATE IN  DATE,
       X_REQUESTED_BY IN  VARCHAR2,
       X_REASON_CODE IN  VARCHAR2,
       X_STATUS IN  VARCHAR2,
       X_MODE in VARCHAR2 default 'R'
  ) AS

  l_cont_pref_rec_type  HZ_CONTACT_PREFERENCE_V2PUB.contact_preference_rec_type;
  l_init_msg_list VARCHAR2(1) := FND_API.G_FALSE;

  tmp_var   VARCHAR2(2000);
  tmp_var1  VARCHAR2(2000);
  BEGIN


  l_cont_pref_rec_type.contact_level_table	        :=      NVL(X_CONTACT_LEVEL_TABLE,'HZ_PARTIES');
  l_cont_pref_rec_type.contact_level_table_id	    :=      X_CONTACT_LEVEL_TABLE_ID;
  l_cont_pref_rec_type.contact_type		            :=      X_CONTACT_TYPE;
  l_cont_pref_rec_type.preference_code		        :=      X_PREFERENCE_CODE;
  l_cont_pref_rec_type.preference_start_date	    :=      X_PREFERENCE_START_DATE;
  l_cont_pref_rec_type.preference_end_date	        :=      X_PREFERENCE_END_DATE;
  l_cont_pref_rec_type.requested_by		            :=      NVL(X_REQUESTED_BY,'PARTY');
  l_cont_pref_rec_type.reason_code		            :=      X_REASON_CODE;
  l_cont_pref_rec_type.status		                :=      'A';
  l_cont_pref_rec_type.created_by_module            :=      'IGS';


  -- perform validations
  x_return_status := 'E';
  x_msg_count :=1;

  date_validate(
  x_preference_start_date,
  x_preference_end_date,
  x_contact_level_table_id,
  x_msg_data,
  x_mode);

  IF x_msg_data IS NOT NULL THEN
     RETURN;
  END IF;

  -- check for date overlap.
  x_return_status := 'E';
  x_msg_count := 1;

   val_overlap_api(
   x_contact_level_table_id,
   x_preference_start_date,
   NVL(x_preference_end_date,TO_DATE('4712/12/31','YYYY/MM/DD')),
   x_contact_preference_id,
   x_msg_data,
   x_mode);

  IF x_msg_data IS NOT NULL THEN
     RETURN;
  END IF;


  x_return_status := null;
  x_msg_count  := null;

  HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference (
    p_init_msg_list             	=> l_init_msg_list,
	p_contact_preference_rec    	=> l_cont_pref_rec_type,
	x_contact_preference_id     	=> x_contact_preference_id,
	x_return_status             	=> x_return_status,
	x_msg_count                 	=> x_msg_count ,
	x_msg_data                  	=> x_msg_data );


     IF x_return_status IN ('E','U') THEN

      IF x_msg_count > 1 THEN
		FOR i IN 1..x_msg_count  LOOP
		  tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
		  tmp_var1 := tmp_var1 || ' '|| tmp_var;
		END LOOP;
		x_msg_data := tmp_var1;
      END IF;
      RETURN;
     END IF;


	-- after successful insert, pass OVN out as 1.
	 x_OBJECT_VERSION_NUMBER :=1;

  END INSERT_ROW;


 procedure UPDATE_ROW (
       X_MSG_COUNT OUT NOCOPY NUMBER,
       X_MSG_DATA  OUT NOCOPY VARCHAR2,
       X_RETURN_STATUS OUT NOCOPY VARCHAR2,
       X_ROWID in out NOCOPY VARCHAR2,
       x_CONTACT_PREFERENCE_ID IN OUT NOCOPY NUMBER,
       x_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
       X_CONTACT_LEVEL_TABLE  IN  VARCHAR2,
       X_CONTACT_LEVEL_TABLE_ID IN  NUMBER,
       X_CONTACT_TYPE  IN  VARCHAR2,
       X_PREFERENCE_CODE  IN  VARCHAR2,
       X_PREFERENCE_START_DATE  IN  DATE,
       X_PREFERENCE_END_DATE IN  DATE,
       X_REQUESTED_BY IN  VARCHAR2,
       X_REASON_CODE IN  VARCHAR2,
       X_STATUS IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R'
  ) AS
  l_cont_pref_rec_type  HZ_CONTACT_PREFERENCE_V2PUB.contact_preference_rec_type;
  l_init_msg_list VARCHAR2(1) := FND_API.G_FALSE;
  tmp_var   VARCHAR2(2000);
  tmp_var1  VARCHAR2(2000);

  BEGIN


   -- perform validations
   -- perform this before setting the G_MISS_DATE.
  x_return_status := 'E';
  x_msg_count :=1;

  date_validate(
  x_preference_start_date,
  x_preference_end_date,
  x_contact_level_table_id,
  x_msg_data,
  x_mode);

  IF x_msg_data IS NOT NULL THEN
     RETURN;
  END IF;
   -- check for date overlap.
   x_return_status := 'E';
   x_msg_count  := 1;

   val_overlap_api(
   x_contact_level_table_id,
   x_preference_start_date,
   NVL(x_preference_end_date,TO_DATE('4712/12/31','YYYY/MM/DD')) ,
   x_contact_preference_id,
   x_msg_data,
   x_mode);

   IF x_msg_data IS NOT NULL THEN
     RETURN;
   END IF;

  x_return_status := null;
  x_msg_data := null;
  l_cont_pref_rec_type.contact_preference_id       :=	   x_CONTACT_PREFERENCE_ID;
  l_cont_pref_rec_type.contact_level_table	       :=      NVL(X_CONTACT_LEVEL_TABLE,'HZ_PARTIES');
  l_cont_pref_rec_type.contact_level_table_id	   :=      X_CONTACT_LEVEL_TABLE_ID;
  l_cont_pref_rec_type.contact_type		           :=      X_CONTACT_TYPE;
  l_cont_pref_rec_type.preference_code		       :=      X_PREFERENCE_CODE;
  l_cont_pref_rec_type.preference_start_date	   :=      X_PREFERENCE_START_DATE;
  l_cont_pref_rec_type.preference_end_date	       :=      NVL(X_PREFERENCE_END_DATE,FND_API.G_MISS_DATE);-- this is a nullable col
  l_cont_pref_rec_type.requested_by		           :=      NVL(X_REQUESTED_BY,'PARTY');
  l_cont_pref_rec_type.reason_code		           :=      NVL(X_REASON_CODE,FND_API.G_MISS_CHAR);  -- this is a nullable col
  l_cont_pref_rec_type.status		               :=      'A';



  HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference  (
    p_init_msg_list             	=> l_init_msg_list,
	p_contact_preference_rec    	=> l_cont_pref_rec_type,
	p_object_version_number     	=> x_object_version_number,
	x_return_status             	=> x_return_status,
	x_msg_count                 	=> x_msg_count ,
	x_msg_data                  	=> x_msg_data );

    IF x_return_status IN ('E','U') THEN

	 IF x_msg_count > 1 THEN
		FOR i IN 1..x_msg_count  LOOP
		  tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
		  tmp_var1 := tmp_var1 || ' '|| tmp_var;
		END LOOP;
		x_msg_data := tmp_var1;
	 END IF;
	 RETURN;
    END IF;



END UPDATE_ROW;
END IGS_PE_HZ_CONT_PREF_PKG;

/
