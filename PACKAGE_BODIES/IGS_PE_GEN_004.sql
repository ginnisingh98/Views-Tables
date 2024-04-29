--------------------------------------------------------
--  DDL for Package Body IGS_PE_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_GEN_004" AS
/* $Header: IGSPE20B.pls 120.2 2005/10/06 01:28:07 appldev noship $ */

/* +=======================================================================+
   |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
   |                         All rights reserved.                          |
   +=======================================================================+
   |  NAME                                                                 |
   |    IGSVTFPB.pls                                                       |
   |                                                                       |
   |  DESCRIPTION                                                          |
   |    This package provides service functions and procedures to          |
   |    print hte text file from the EDS system definition   .             |
   |                                                                       |
   |  NOTES                                                                |
   |                                                                       |
   |  DEPENDENCIES                                                         |
   |                                                                       |
   |  USAGE                                                                |
   |                                                                       |
   |  HISTORY                                                              |
   +=======================================================================+ */

FUNCTION GET_RACE_DTLS(P_PERSON_ID IN NUMBER)
RETURN VARCHAR2 IS
/*
Purpose: This function returns a concatendated string of all the Races the person
         has. Each of the value is concatenated with a comma (,)
		 Used in PersBiographicsVO.xml
Change History:
Who         When            What

*/
 CURSOR race_dtls_cur (cp_person_id igs_pe_hz_parties.party_id%TYPE,
                       cp_lookup_type igs_lookup_values.lookup_type%TYPE) IS
 SELECT lk.meaning
 FROM igs_lookup_values lk, igs_pe_race race
 WHERE race.person_id = cp_person_id AND
 lk.lookup_type = cp_lookup_type AND
 lk.lookup_code = race.race_cd;

 race_dtls_rec race_dtls_cur%ROWTYPE;
 l_concat_race VARCHAR2(2000);
BEGIN
 l_concat_race := NULL;

  OPEN race_dtls_cur(p_person_id, 'PE_RACE');
  FETCH race_dtls_cur INTO race_dtls_rec;
   IF (race_dtls_cur%FOUND) THEN
     l_concat_race := race_dtls_rec.meaning;
    LOOP
      FETCH race_dtls_cur INTO race_dtls_rec;
      EXIT WHEN race_dtls_cur%NOTFOUND;
      l_concat_race := l_concat_race ||', ' ||race_dtls_rec.meaning;
    END LOOP;
   END IF;

  CLOSE race_dtls_cur;

    RETURN l_concat_race;

END GET_RACE_DTLS;

FUNCTION PERM_RES_COUNTRY_DTL (
 P_PERSON_ID IN VARCHAR2,
 P_DETAIL IN VARCHAR2)
 RETURN VARCHAR2 IS
/*
Purpose: This function checks for the current active record from the IGS_PE_EIT table for the information type = 'PE_INT_PERM_RES' and
         country as setup in the profile OSS_COUNTRY_CODE.
         For P_DETAIL = 'COUNTRY', It returns Y if there is a record. Returns N if there is a record for any other country. Else
	 checks whether any active citizenship record exists with country other than the one in the profile OSS_COUNTRY_CODE if
         there is a record then returns 'N' Else returns NULL.
	 For P_DETAIL = 'REGNO', returns the pei_information2 (registration number)
	 Used in the ApplCitizensVO.xml
Change History:
Who         When            What

*/

 CURSOR check_eit_cur (cp_person_id  NUMBER,
                       cp_information_type VARCHAR2,
                       cp_country_code VARCHAR2) IS
 SELECT PEI_INFORMATION2, START_DATE
 FROM IGS_PE_EIT
 WHERE PERSON_ID = cp_person_id AND
 INFORMATION_TYPE = cp_information_type AND
 PEI_INFORMATION1= cp_country_code AND
 SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);

 CURSOR check_eit_exists_cur (cp_person_id  NUMBER,
                              cp_information_type VARCHAR2) IS
 SELECT PEI_INFORMATION2, START_DATE
 FROM IGS_PE_EIT
 WHERE PERSON_ID = cp_person_id AND
 INFORMATION_TYPE = cp_information_type;

  CURSOR active_ctzn_cur (cp_person_id NUMBER,
                          cp_country_code FND_TERRITORIES_VL.TERRITORY_CODE%TYPE)
  IS
  SELECT 'Y'
  FROM hz_citizenship
  WHERE country_code <> cp_country_code AND
        party_id = cp_person_id AND
        SYSDATE BETWEEN NVL(DATE_RECOGNIZED,SYSDATE) AND NVL(END_DATE,SYSDATE);

 check_eit_exists_rec check_eit_exists_cur%ROWTYPE;
 check_eit_rec check_eit_cur%ROWTYPE;
 l_fnd_country_code  FND_TERRITORIES_VL.TERRITORY_CODE%TYPE;
 l_per_country_code  VARCHAR2(30);
 l_oth_ctzn_exists   VARCHAR2(1);
BEGIN
 l_fnd_country_code := FND_PROFILE.VALUE('OSS_COUNTRY_CODE');
 l_per_country_code := convert_country_code (l_fnd_country_code);

 OPEN check_eit_cur(p_person_id, 'PE_INT_PERM_RES', l_per_country_code);
 FETCH check_eit_cur INTO check_eit_rec;
 CLOSE check_eit_cur;

 IF P_DETAIL = 'COUNTRY' THEN

   IF check_eit_rec.start_date IS NOT NULL THEN
     RETURN 'Y';
   ELSE
     OPEN check_eit_exists_cur(p_person_id, 'PE_INT_PERM_RES');
     FETCH check_eit_exists_cur INTO check_eit_exists_rec;
     CLOSE check_eit_exists_cur;

     IF check_eit_exists_rec.start_date IS NOT NULL THEN
         RETURN 'N';
     ELSE
         OPEN active_ctzn_cur(p_person_id, l_fnd_country_code);
         FETCH active_ctzn_cur INTO l_oth_ctzn_exists;
         CLOSE active_ctzn_cur;

         IF l_oth_ctzn_exists = 'Y' THEN
            RETURN 'N';
         ELSE
            RETURN NULL;
         END IF;
     END IF;
   END IF;

 ELSIF P_DETAIL = 'REGNO' THEN

   RETURN check_eit_rec.pei_information2;

 END IF;

END PERM_RES_COUNTRY_DTL;

FUNCTION perm_res_reg_date (
 P_PERSON_ID IN VARCHAR2
 )
 RETURN DATE IS
/*
Purpose: This function checks for the current active record from the IGS_PE_EIT table for the information type = 'PE_INT_PERM_RES' and
         country as setup in the profile OSS_COUNTRY_CODE.
         Returns the start_date (registration date)
		 Used in the ApplCitizensVO.xml
Change History:
Who         When            What

*/
 CURSOR check_eit_cur (cp_person_id  NUMBER,
                       cp_information_type VARCHAR2,
                       cp_country_code VARCHAR2) IS
 SELECT PEI_INFORMATION2, START_DATE
 FROM IGS_PE_EIT
 WHERE PERSON_ID = cp_person_id AND
 INFORMATION_TYPE = cp_information_type AND -- 'PE_INT_PERM_RES' AND
 PEI_INFORMATION1= cp_country_code AND
 SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);

 check_eit_rec check_eit_cur%ROWTYPE;
 l_fnd_country_code  FND_TERRITORIES_VL.TERRITORY_CODE%TYPE;
 l_per_country_code  VARCHAR2(30);
BEGIN

 l_fnd_country_code := FND_PROFILE.VALUE('OSS_COUNTRY_CODE');
 l_per_country_code := convert_country_code (l_fnd_country_code);

 OPEN check_eit_cur(p_person_id, 'PE_INT_PERM_RES', l_per_country_code);
 FETCH check_eit_cur INTO check_eit_rec;
 CLOSE check_eit_cur;

 RETURN check_eit_rec.start_date;

END perm_res_reg_date;

FUNCTION CONVERT_COUNTRY_CODE (
P_COUNTRY_CODE IN VARCHAR2)
RETURN VARCHAR2 IS
/*
Purpose: This function takes the Country code defined in FND_TERRITORIES_VL as an input and returns the
         corresponding mapping value as defined the lookup type PER_US_COUNTRY_CODE

Change History:
Who         When            What

*/
  CURSOR country_cur (cp_country_code VARCHAR2,
                      cp_lookup_type  VARCHAR2) IS
  SELECT SUBSTR(meaning,5,2)
  FROM hr_lookups
  WHERE lookup_type = cp_lookup_type
   AND lookup_code= cp_country_code;

  l_country_code VARCHAR2(80);
BEGIN
  IF p_country_code = 'US' THEN

    l_country_code := 'US';

  ELSE

	OPEN country_cur(P_COUNTRY_CODE, 'PQP_US_COUNTRY_TRANSLATE');
	FETCH country_cur INTO l_country_code;
	CLOSE country_cur;

  END IF;

  RETURN l_country_code;

END CONVERT_COUNTRY_CODE;

PROCEDURE PROCESS_APPLCITIZEN (
P_PERSON_ID        IN  NUMBER,
P_HAS_CITIZEN      IN  VARCHAR2,
P_CITIZEN_COUNTRY  IN  VARCHAR2,
P_PERM_RES         IN  VARCHAR2,
P_REG_NUMBER       IN  VARCHAR2,
P_REG_DATE         IN  DATE,
P_MSG_DATA         OUT NOCOPY VARCHAR2
) IS
/*
Purpose: This procedure is used to process records in the Applicant Citizenship component.
		 PersApplCtznRN.xml
Change History:
Who         When            What

*/
  CURSOR student_check_cur (cp_person_id NUMBER,
                            cp_system_type VARCHAR2)
  IS
  SELECT 1
  FROM igs_pe_typ_instances_all inst,
       igs_pe_person_types typ
  WHERE inst.person_type_code = typ.person_type_code AND
       inst.person_id = cp_person_id AND
       typ.system_type = cp_system_type AND
       SYSDATE BETWEEN start_date AND NVL(end_date, SYSDATE);

  CURSOR ctzn_country_cur (cp_person_id NUMBER,
                           cp_country_code FND_TERRITORIES_VL.TERRITORY_CODE%TYPE)
  IS
  SELECT citizenship_id, country_code, object_version_number, date_recognized, end_date, document_reference,
         document_type, birth_or_selected
  FROM hz_citizenship
  WHERE country_code = cp_country_code AND
        party_id = cp_person_id;

  ctzn_country_rec  ctzn_country_cur%ROWTYPE;

  CURSOR active_ctzn_cur (cp_person_id NUMBER,
                          cp_country_code FND_TERRITORIES_VL.TERRITORY_CODE%TYPE)
  IS
  SELECT birth_or_selected, country_code, date_recognized, document_reference, document_type,
        citizenship_id, object_version_number
  FROM hz_citizenship
  WHERE country_code <> cp_country_code AND
        party_id = cp_person_id AND
        SYSDATE BETWEEN NVL(DATE_RECOGNIZED,SYSDATE) AND NVL(END_DATE,SYSDATE);

  CURSOR active_permres_cur(cp_person_id NUMBER,
                            cp_country_code VARCHAR2)
  IS
  SELECT rowid, pe_eit_id, pei_information1, pei_information2, start_date, end_date
  FROM igs_pe_eit
  WHERE information_type = 'PE_INT_PERM_RES' AND
        pei_information1 = cp_country_code AND
		person_id = cp_person_id AND
		SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);

  CURSOR oth_active_permres_cur(cp_person_id NUMBER,
                                cp_country_code VARCHAR2)
  IS
  SELECT rowid, pe_eit_id, pei_information1, pei_information2, start_date, end_date
  FROM igs_pe_eit
  WHERE information_type = 'PE_INT_PERM_RES' AND
        pei_information1 <> cp_country_code AND
		person_id = cp_person_id AND
		SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);

  CURSOR permres_cur(cp_person_id NUMBER,
                     cp_country_code VARCHAR2)
  IS
  SELECT rowid, pe_eit_id, pei_information1, pei_information2, start_date, end_date
  FROM igs_pe_eit
  WHERE information_type = 'PE_INT_PERM_RES' AND
        pei_information1 = cp_country_code AND
		person_id = cp_person_id;

  permres_rec permres_cur%ROWTYPE;

  l_count NUMBER(1);
  l_fnd_country_code  FND_TERRITORIES_VL.TERRITORY_CODE%TYPE;
  l_per_country_code  VARCHAR2(30);
  l_object_version_number hz_citizenship.object_version_number%TYPE;
  l_last_update_date hz_citizenship.last_update_date%TYPE;
  l_citizenship_id   hz_citizenship.citizenship_id%TYPE;
  l_rowid            ROWID;
  l_pe_eit_id        igs_pe_eit.pe_eit_id%TYPE;
  l_message          VARCHAR2(2000);
  l_return_status    VARCHAR2(10);
  l_msg_count        NUMBER(2);
BEGIN

  -- If the person is a Student then don't allow him to update any data
  OPEN student_check_cur (p_person_id, 'STUDENT');
  FETCH student_check_cur INTO l_count;
   IF student_check_cur%FOUND THEN
     CLOSE student_check_cur;
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PE_SS_CTZN_UPD_INST');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
  CLOSE student_check_cur;

  l_fnd_country_code := FND_PROFILE.VALUE('OSS_COUNTRY_CODE');
  l_per_country_code := convert_country_code (l_fnd_country_code);

  /* Logic if p_has_citizen = 'Y' THEN
  -- Check whether in HZ_CITIZENSHIP the person has any record with the Country as in the profile OSS_COUNTRY_CODE.
   If there is no record create a record in HZ_CITIZENSHIP passing the Country as in the profile OSS_COUNTRY_CODE
   and DATE_RECOGNIZED as the Current Date.
  -- If there is already a Record with the Country as in the profile OSS_COUNTRY_CODE then update the record with end date as NULL.
  -- In both the above scnerios if there is any other Active record with country other than the Country as in the
   profile OSS_COUNTRY_CODE, then make them inactive (set the end date of those records as current date).
  -- If there is any active record in IGS_PE_EIT for INFORMATION_TYPE = 'PE_INT_PERM_RES' and Country = as in profile
   OSS_COUNTRY_CODE then update the record with end date as Current Date.
  */

  IF p_has_citizen = 'Y' THEN
   OPEN ctzn_country_cur(p_person_id, l_fnd_country_code);
   FETCH ctzn_country_cur INTO ctzn_country_rec;
   CLOSE ctzn_country_cur;

   IF ctzn_country_rec.citizenship_id IS NULL THEN

      IGS_PE_CITIZENSHIPS_PKG.CITIZENSHIP(
            p_action            => 'INSERT',
            P_birth_or_selected => NULL,
            P_country_code      => l_fnd_country_code,
            p_date_disowned     => NULL,
            p_date_recognized   => TRUNC(SYSDATE),
            p_DOCUMENT_REFERENCE => NULL,
            p_DOCUMENT_TYPE      => NULL,
            p_PARTY_ID           => P_PERSON_ID,
            p_END_DATE           => NULL,
            p_TERRITORY_SHORT_NAME  => NULL,
            p_last_update_date   => l_last_update_date,
            P_citizenship_id     => l_citizenship_id,
            p_return_status      => l_return_status,
            p_msg_count          => l_msg_count,
            p_msg_data           => p_msg_data,
            p_object_version_number => l_object_version_number
      );

   ELSE -- citizenship_id is NULL

	 IF ctzn_country_rec.end_date IS NOT NULL THEN

		IGS_PE_CITIZENSHIPS_PKG.CITIZENSHIP(
                p_action            => 'UPDATE',
                P_birth_or_selected => NULL,
                P_country_code      => l_fnd_country_code,
                p_date_disowned     => NULL,
                p_date_recognized   => ctzn_country_rec.date_recognized,
                p_document_reference => ctzn_country_rec.document_reference,
                p_document_type      => ctzn_country_rec.document_type,
                p_party_id           => p_person_id,
                p_end_date           => NULL,
                p_territory_short_name  => NULL,
                p_last_update_date   => l_last_update_date,
                P_citizenship_id     => ctzn_country_rec.citizenship_id,
                p_return_status      => l_return_status,
                p_msg_count          => l_msg_count,
                p_msg_data           => p_msg_data,
                p_object_version_number => ctzn_country_rec.object_version_number
        );

     END IF;
   END IF;

		 IF l_return_status IS NULL OR l_return_status = 'S' THEN
			 FOR active_ctzn_rec IN active_ctzn_cur(p_person_id, l_fnd_country_code) LOOP

				IGS_PE_CITIZENSHIPS_PKG.CITIZENSHIP(
						p_action            => 'UPDATE',
						P_birth_or_selected => active_ctzn_rec.birth_or_selected,
						P_country_code      => active_ctzn_rec.country_code,
						p_date_disowned     => NULL,
						p_date_recognized   => active_ctzn_rec.date_recognized,
						p_document_reference => active_ctzn_rec.document_reference,
						p_document_type      => active_ctzn_rec.document_type,
						p_party_id           => p_person_id,
						p_end_date           => TRUNC(SYSDATE),
						p_territory_short_name  => NULL,
						p_last_update_date   => l_last_update_date,
						P_citizenship_id     => active_ctzn_rec.citizenship_id,
						p_return_status      => l_return_status,
						p_msg_count          => l_msg_count,
						p_msg_data           => p_msg_data,
						p_object_version_number => active_ctzn_rec.object_version_number
				);
		     END LOOP;
         END IF;

		 IF l_return_status IS NULL OR l_return_status = 'S' THEN
			   FOR active_permres_rec IN active_permres_cur(p_person_id, l_per_country_code) LOOP

				  igs_pe_eit_pkg.update_row (
					 X_ROWID     => active_permres_rec.rowid,
					 X_PE_EIT_ID => active_permres_rec.pe_eit_id,
					 X_PERSON_ID => p_person_id,
					 X_INFORMATION_TYPE => 'PE_INT_PERM_RES',
					 X_PEI_INFORMATION1 => active_permres_rec.pei_information1,
					 X_PEI_INFORMATION2 => active_permres_rec.pei_information2,
					 X_PEI_INFORMATION3 => NULL,
					 X_PEI_INFORMATION4 => NULL,
					 X_PEI_INFORMATION5 => NULL,
					 X_START_DATE => active_permres_rec.start_date,
					 X_END_DATE   => TRUNC(SYSDATE)
				 );

			   END LOOP;
		 END IF;

  /* Logic if p_has_citizen = 'N' THEN
   -- Check whether in HZ_CITIZENSHIP the person has any record with the country as in P_CITIZEN_COUNTRY. If there is no record
   create a record in HZ_CITIZENSHIP passing the Country as in P_CITIZEN_COUNTRY and DATE_RECOGNIZED as the Current Date.
   -- If there is already a Record with the country as in P_CITIZEN_COUNTRY then update the record with the end date as NULL.
   -- In both the above scnerios if there is any other Active record (Current Date between Start Date and End Date) with country
   other than P_CITIZEN_COUNTRY, then make them inactive (set the end date of those records as current date).
  */
  ELSIF p_has_citizen = 'N' THEN
    IF p_citizen_country IS NULL THEN
	   RETURN;
    END IF;

	   OPEN ctzn_country_cur(p_person_id, p_citizen_country);
	   FETCH ctzn_country_cur INTO ctzn_country_rec;
	   CLOSE ctzn_country_cur;

    IF ctzn_country_rec.citizenship_id IS NULL THEN

		  igs_pe_citizenships_pkg.citizenship(
				p_action            => 'INSERT',
				P_birth_or_selected => NULL,
				P_country_code      => p_citizen_country,
				p_date_disowned     => NULL,
				p_date_recognized   => TRUNC(SYSDATE),
				p_DOCUMENT_REFERENCE => NULL,
				p_DOCUMENT_TYPE      => NULL,
				p_PARTY_ID           => P_PERSON_ID,
				p_END_DATE           => NULL,
				p_TERRITORY_SHORT_NAME  => NULL,
				p_last_update_date   => l_last_update_date,
				P_citizenship_id     => l_citizenship_id,
				p_return_status      => l_return_status,
				p_msg_count          => l_msg_count,
				p_msg_data           => p_msg_data,
				p_object_version_number => l_object_version_number
		  );

    ELSE
 	  IF ctzn_country_rec.end_date IS NOT NULL THEN

			IGS_PE_CITIZENSHIPS_PKG.CITIZENSHIP(
					p_action            => 'UPDATE',
					P_birth_or_selected => NULL,
					P_country_code      => p_citizen_country,
					p_date_disowned     => NULL,
					p_date_recognized   => ctzn_country_rec.date_recognized,
					p_document_reference => ctzn_country_rec.document_reference,
					p_document_type      => ctzn_country_rec.document_type,
					p_party_id           => p_person_id,
					p_end_date           => NULL,
					p_territory_short_name  => NULL,
					p_last_update_date   => l_last_update_date,
					P_citizenship_id     => ctzn_country_rec.citizenship_id,
					p_return_status      => l_return_status,
					p_msg_count          => l_msg_count,
					p_msg_data           => p_msg_data,
					p_object_version_number => ctzn_country_rec.object_version_number
			);

	  END IF;

	END IF; -- citizenship_id

		 IF l_return_status IS NULL OR l_return_status = 'S' THEN

			 FOR active_ctzn_rec IN active_ctzn_cur(p_person_id, p_citizen_country) LOOP

				IGS_PE_CITIZENSHIPS_PKG.CITIZENSHIP(
						p_action            => 'UPDATE',
						P_birth_or_selected => active_ctzn_rec.birth_or_selected,
						P_country_code      => active_ctzn_rec.country_code,
						p_date_disowned     => NULL,
						p_date_recognized   => active_ctzn_rec.date_recognized,
						p_document_reference => active_ctzn_rec.document_reference,
						p_document_type      => active_ctzn_rec.document_type,
						p_party_id           => p_person_id,
						p_end_date           => TRUNC(SYSDATE),
						p_territory_short_name  => NULL,
						p_last_update_date   => l_last_update_date,
						P_citizenship_id     => active_ctzn_rec.citizenship_id,
						p_return_status      => l_return_status,
						p_msg_count          => l_msg_count,
						p_msg_data           => p_msg_data,
						p_object_version_number => active_ctzn_rec.object_version_number
				);

			 END LOOP;
		 END IF;
  /*
   If P_PERM_RES = YES, then
   -- Check whether in IGS_PE_EIT for INFORMATION_TYPE = 'PE_INT_PERM_RES' there is any record.
   Since in IGS_PE_EIT the country is stored from the lookup PER_US_COUNTRY_CODE, call the Function CONVERT_COUNTRY_CODE
   to get the proper Country Code for the value set in the profile OSS_COUNTRY_CODE.
   -- If there is no record then insert a new record in the table IGS_PE_EIT,
   -- If there is already a record then check whether any record present with Country as in the profile OSS_COUNTRY_CODE.
   If there is already a record present then Update the start date with P_REG_DATE and Registration Number as P_REG_NUMBER.
   -- If the existing record's Country Code is different from the profile OSS_COUNTRY_CODE then end date any active record
   with end date = P_REG_DATE - 1 and create a new record as above.
  */

     IF P_PERM_RES = 'Y' THEN
        OPEN permres_cur(p_person_id, l_per_country_code);
		FETCH permres_cur INTO permres_rec;
		CLOSE permres_cur;

		IF permres_rec.pe_eit_id IS NULL THEN

		  igs_pe_eit_pkg.insert_row (
			 X_ROWID     => l_rowid,
			 X_PE_EIT_ID => l_pe_eit_id,
			 X_PERSON_ID => p_person_id,
			 X_INFORMATION_TYPE => 'PE_INT_PERM_RES',
			 X_PEI_INFORMATION1 => l_per_country_code,
			 X_PEI_INFORMATION2 => p_reg_number,
			 X_PEI_INFORMATION3 => NULL,
			 X_PEI_INFORMATION4 => NULL,
			 X_PEI_INFORMATION5 => NULL,
			 X_START_DATE => p_reg_date,
			 X_END_DATE   => NULL
		 );

		ELSE
		  igs_pe_eit_pkg.update_row (
			 X_ROWID     => permres_rec.rowid,
			 X_PE_EIT_ID => permres_rec.pe_eit_id,
			 X_PERSON_ID => p_person_id,
			 X_INFORMATION_TYPE => 'PE_INT_PERM_RES',
			 X_PEI_INFORMATION1 => permres_rec.pei_information1,
			 X_PEI_INFORMATION2 => p_reg_number,
			 X_PEI_INFORMATION3 => NULL,
			 X_PEI_INFORMATION4 => NULL,
			 X_PEI_INFORMATION5 => NULL,
			 X_START_DATE => p_reg_date,
			 X_END_DATE   => NULL
		 );

		END IF;

	   FOR oth_active_permres_rec IN oth_active_permres_cur(p_person_id, l_per_country_code) LOOP

		  igs_pe_eit_pkg.update_row (
			 X_ROWID     => oth_active_permres_rec.rowid,
			 X_PE_EIT_ID => oth_active_permres_rec.pe_eit_id,
			 X_PERSON_ID => p_person_id,
			 X_INFORMATION_TYPE => 'PE_INT_PERM_RES',
			 X_PEI_INFORMATION1 => oth_active_permres_rec.pei_information1,
			 X_PEI_INFORMATION2 => oth_active_permres_rec.pei_information2,
			 X_PEI_INFORMATION3 => NULL,
			 X_PEI_INFORMATION4 => NULL,
			 X_PEI_INFORMATION5 => NULL,
			 X_START_DATE => oth_active_permres_rec.start_date,
			 X_END_DATE   => p_reg_date - 1
		 );

	   END LOOP;

  /*
   If P_PERM_RES = NO, then
   Check if there is any active record in IGS_PE_EIT for INFORMATION_TYPE = 'PE_INT_PERM_RES' and Country = as in profile
   OSS_COUNTRY_CODE then update the record with end date as Current Date.
  */
	 ELSIF P_PERM_RES = 'N' THEN

	   FOR active_permres_rec IN active_permres_cur(p_person_id, l_per_country_code) LOOP

		  igs_pe_eit_pkg.update_row (
			 X_ROWID     => active_permres_rec.rowid,
			 X_PE_EIT_ID => active_permres_rec.pe_eit_id,
			 X_PERSON_ID => p_person_id,
			 X_INFORMATION_TYPE => 'PE_INT_PERM_RES',
			 X_PEI_INFORMATION1 => active_permres_rec.pei_information1,
			 X_PEI_INFORMATION2 => active_permres_rec.pei_information2,
			 X_PEI_INFORMATION3 => NULL,
			 X_PEI_INFORMATION4 => NULL,
			 X_PEI_INFORMATION5 => NULL,
			 X_START_DATE => active_permres_rec.start_date,
			 X_END_DATE   => TRUNC(SYSDATE)
		 );

	   END LOOP;

	 END IF;

  END IF; -- P_HAS_CITIZEN

EXCEPTION
  WHEN OTHERS THEN
    l_message := FND_MESSAGE.GET;

	IF l_message IS NOT NULL THEN
      p_msg_data := l_message;
	ELSE
   	  p_msg_data := SQLERRM;
	END IF;
END PROCESS_APPLCITIZEN;


FUNCTION VALIDATE_FELONY (
 P_PERSON_ID IN NUMBER,
 P_EVER_FELONY_CONVICTED IN VARCHAR2)
RETURN VARCHAR2 IS
/*
Purpose: This procedure is used to validate the Felony details.
         If P_EVER_FELONY_CONVICTED IS NULL then there should not be any records in the Child table.
         If P_EVER_FELONY_CONVICTED = 'N' then there should not be any records in the child table with CONVICT_IND = 'Y'

Change History:
Who         When            What

*/
 CURSOR records_null_dtls_cur (cp_person_id igs_pe_felony_dtls.person_id%TYPE) IS
		SELECT 'X'
		FROM igs_pe_felony_dtls
		WHERE person_id=cp_person_id;

 CURSOR records_no_dtls_cur (cp_person_id igs_pe_felony_dtls.person_id%TYPE) IS
		SELECT 'X'
		FROM igs_pe_felony_dtls
		WHERE person_id=cp_person_id
		AND convict_ind='Y';

	l_race_null_dtls_rec VARCHAR2(1);
	l_race_no_dtls_rec VARCHAR2(1);
	l_message varchar2(35):=NULL;
BEGIN

	IF P_EVER_FELONY_CONVICTED IS NULL THEN
		OPEN records_null_dtls_cur (P_PERSON_ID);
		FETCH records_null_dtls_cur INTO l_race_null_dtls_rec;
		IF records_null_dtls_cur%FOUND THEN
	        l_message:= 'IGS_PE_SS_FLNY_CONVICT_NOBLANK';
		END IF;
		CLOSE records_null_dtls_cur;

	ELSIF P_EVER_FELONY_CONVICTED = 'N' THEN
		OPEN records_no_dtls_cur (P_PERSON_ID);
		FETCH records_no_dtls_cur INTO l_race_no_dtls_rec;
		IF records_no_dtls_cur%FOUND THEN
			l_message:= 'IGS_PE_SS_FLNY_CONVICT_NOTNO';
		END IF;
		CLOSE records_no_dtls_cur;
	END IF;

	RETURN l_message;
END VALIDATE_FELONY;

FUNCTION get_load_teach_concat(
p_teach_cal_type IN VARCHAR2,
p_teach_seq_number IN NUMBER
) RETURN VARCHAR2 IS
/*
Purpose: This function returns the concatenation of the teach_description ||'/'||load_description for the latest load calendar

Change History:
Who         When            What

*/
CURSOR cur_cal_desc (cp_teach_cal_type VARCHAR2, cp_teach_seq_no VARCHAR2)IS
SELECT teach_description ||'/'||load_description
FROM igs_ca_teach_to_load_v
WHERE teach_cal_type =  cp_teach_cal_type
AND teach_ci_sequence_number = cp_teach_seq_no
ORDER BY load_start_dt DESC;

l_cal_desc VARCHAR2(60);
BEGIN

OPEN cur_cal_desc(p_teach_cal_type, p_teach_seq_number);
FETCH cur_cal_desc INTO l_cal_desc;
CLOSE cur_cal_desc;

RETURN l_cal_desc;

END get_load_teach_concat;

FUNCTION get_start_term (
p_acad_cal_type IN VARCHAR2 ,
p_prog_commencement_dt IN VARCHAR2
) RETURN VARCHAR2 AS
/*
Purpose: This function returns the term in which the program was started by the student.
         Used in PeProgramAttemptsVO.xml
Change History:
Who         When            What

*/
l_load_cal_type   IGS_CA_INST_ALL.CAL_TYPE%TYPE;
l_load_seq_number IGS_CA_INST_ALL.SEQUENCE_NUMBER%TYPE;
l_load_alt_code   IGS_CA_INST_ALL.ALTERNATE_CODE%TYPE;
l_load_start_dt   IGS_CA_INST_ALL.START_DT%TYPE;
l_load_end_dt     IGS_CA_INST_ALL.END_DT%TYPE;
l_message_name    VARCHAR2(30);
l_load_cal_desc   IGS_CA_INST_ALL.DESCRIPTION%TYPE;

CURSOR cur_cal_desc(cp_load_cal_typ igs_ca_inst.cal_type%TYPE,
		    cp_cal_seq_no igs_ca_inst.sequence_number%TYPE) IS
SELECT description
FROM igs_ca_inst_all
WHERE cal_type = cp_load_cal_typ
AND sequence_number = cp_cal_seq_no;

BEGIN

  IGS_EN_GEN_015.GET_CURR_ACAD_TERM_CAL(
	P_ACAD_CAL_TYPE		 => p_acad_cal_type,
	P_EFFECTIVE_DT		 => p_prog_commencement_dt,
	P_LOAD_CAL_TYPE          => l_load_cal_type,
	P_LOAD_CI_SEQ_NUM	 => l_load_seq_number,
	P_LOAD_CI_ALT_CODE	 => l_load_alt_code,
	P_LOAD_CI_START_DT	 => l_load_start_dt,
	P_LOAD_CI_END_DT	 => l_load_end_dt,
	P_MESSAGE_NAME		 => l_message_name
  );

  IF l_message_name IS NOT NULL THEN
     RETURN NULL;
  ELSE
     OPEN cur_cal_desc(l_load_cal_type, l_load_seq_number);
     FETCH cur_cal_desc INTO l_load_cal_desc;
     CLOSE cur_cal_desc;
     RETURN l_load_cal_desc;
  END IF;
END get_start_term;

FUNCTION GET_OTHER_NAMES (
P_PERSON_ID IN NUMBER
) RETURN VARCHAR2 AS
/*
Purpose: This function returns a string with concatenated values of alias type, surname and given name.
         Used in FindPersonSearchResultsVO.xml
Change History:
Who         When            What

*/
CURSOR cur_alias_type(cp_person_id NUMBER) IS
SELECT MEANING||': '||ALIAS.SURNAME||' '||ALIAS.GIVEN_NAMES OTHER_NAMES
FROM IGS_PE_PERSON_ALIAS ALIAS, IGS_LOOKUP_VALUES LKUP
WHERE ALIAS.ALIAS_TYPE = LKUP.LOOKUP_CODE
AND LKUP.LOOKUP_TYPE = 'PE_ALIAS_TYPE'
AND ALIAS.PERSON_ID = cp_person_id;

L_OTHER_NAMES VARCHAR2(4000);
BEGIN

FOR REC_ALIAS_TYPE IN cur_alias_type(P_PERSON_ID)
LOOP
  IF L_OTHER_NAMES IS NOT NULL THEN
     L_OTHER_NAMES := L_OTHER_NAMES||';<BR>'||REC_ALIAS_TYPE.OTHER_NAMES;
  ELSE
     L_OTHER_NAMES := REC_ALIAS_TYPE.OTHER_NAMES;
  END IF;
END LOOP;

RETURN L_OTHER_NAMES;

END GET_OTHER_NAMES;

PROCEDURE SKIP_MAND_DATA_VAL AS
/*
Purpose: This procedure is to set the Global variable that will be called before the call of the API that creates
Student/Applicant person type in Self-service. If the Global variable is set to Y then in the TBH the Mandatory
Data by person type validation will be skipped.

Change History:
Who         When            What

*/
BEGIN

  G_SKIP_MAND_DATA_VAL := 'Y';

END SKIP_MAND_DATA_VAL;

PROCEDURE add_attachment(
 P_PERSON_ID  IN NUMBER,
 P_CRED_TYPE_ID IN NUMBER,
 P_FILE_NAME  IN VARCHAR2,
 P_FILE_CONTENT_TYPE  IN VARCHAR2,
 P_FILE_FORMAT IN VARCHAR2,
 P_FILE_ID OUT NOCOPY NUMBER,
 P_MSG_DATA OUT NOCOPY VARCHAR2
) IS
/*
Purpose: This procedure inserts record in the Credential and Fnd_Lobs table.
After the successful insertion of these records it calls the FND_WEBATTCH API to create the link in the
attachment tables for the Entity IGS_PE_CREDENTIALS

Change History:
Who         When            What

*/
  l_fileid NUMBER;
  lv_rowid  ROWID;
  l_credential_id NUMBER;
  l_category_id NUMBER;

  CURSOR cat_cur(cp_name VARCHAR2) IS
  SELECT category_id
  FROM fnd_document_categories_tl
  WHERE name = cp_name;

  CURSOR fileid_cur IS
  SELECT FND_LOBS_S.NEXTVAL FROM dual;

BEGIN
  -- Insert data in the fnd_lobs table
  OPEN fileid_cur;
  FETCH fileid_cur INTO l_fileid;
  CLOSE fileid_cur;

  INSERT INTO FND_LOBS(
  FILE_ID,
  FILE_NAME,
  FILE_CONTENT_TYPE,
  UPLOAD_DATE,
  EXPIRATION_DATE,
  PROGRAM_NAME,
  PROGRAM_TAG,
  LANGUAGE,
  ORACLE_CHARSET,
  FILE_FORMAT
  ) VALUES
  (
  l_fileid,
  P_FILE_NAME,
  P_FILE_CONTENT_TYPE,
  SYSDATE,
  NULL,
  NULL,
  NULL,
  USERENV('LANG'),
  NULL,
  P_FILE_FORMAT
  );

  P_FILE_ID := l_fileid;

    igs_pe_credentials_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => lv_rowid,
      x_credential_id                     => l_credential_id,
      x_person_id                         => P_PERSON_ID,
      x_credential_type_id                => P_CRED_TYPE_ID,
      x_date_received                     => TO_DATE(NULL),
      x_reviewer_id                       => TO_NUMBER(NULL),
      x_reviewer_notes                    => NULL,
      x_recommender_name                  => NULL,
      x_recommender_title                 => NULL,
      x_recommender_organization          => NULL,
      x_rating_code                       => NULL
    );

  OPEN cat_cur('CUSTOM1499');
  FETCH cat_cur INTO l_category_id;
  CLOSE cat_cur;

  FND_WEBATTCH.Add_Attachment (
    seq_num			=> '1',
	category_id		=> 	l_category_id,
	document_description	=> NULL,
	datatype_id	=> 6,
	text		=> NULL,
	file_name	=> 	P_FILE_NAME,
	url			=> NULL,
	function_name => NULL,
	entity_name	  => 'IGS_PE_CREDENTIALS',
	pk1_value	  => l_credential_id,
	pk2_value	  => NULL,
	pk3_value	  => NULL,
	pk4_value	  => NULL,
	pk5_value	  => NULL,
	media_id	  => l_fileid,
	user_id		  => FND_GLOBAL.USER_ID
  );

EXCEPTION
 WHEN OTHERS THEN
   P_MSG_DATA := SQLERRM;
END add_attachment;

PROCEDURE delete_attachment(
 P_CREDENTIAL_ID IN NUMBER,
 P_DOCUMENT_ID IN NUMBER,
 P_MSG_DATA OUT NOCOPY VARCHAR2
) IS
/*
Purpose: This procedure first removes the link for the attachment created and then deletes the record
from the IGS_PE_CREDENTIALS table

Change History:
Who         When            What

*/
 l_rowid ROWID;
BEGIN

 FND_DOCUMENTS_PKG.DELETE_ROW(
 x_document_id => P_DOCUMENT_ID,
 x_datatype_id => 6,
 delete_ref_Flag => 'Y'
 );

 SELECT ROWID INTO l_rowid
 FROM igs_pe_credentials
 WHERE credential_id = P_CREDENTIAL_ID;

 igs_pe_credentials_pkg.delete_row(
  x_rowid => l_rowid
  );

EXCEPTION
 WHEN OTHERS THEN
   P_MSG_DATA := SQLERRM;
END delete_attachment;

FUNCTION get_deceased_indicator (
p_person_id IN NUMBER
) RETURN VARCHAR2 AS
/*
Purpose: This functions returns the deceased indicator.
         First it checks whether whether date_od_death is present in HZ_PERSON_PROFILES
		 If not then check whether deceased_ind is set in the IGS_PE_HZ_PARTIES table.

Change History:
Who         When            What

*/

 CURSOR hz_dod_cur(cp_person_id NUMBER) IS
 SELECT date_of_death
 FROM igs_pe_person_base_v
 WHERE person_id = cp_person_id;

 CURSOR igs_dod_cur(cp_person_id NUMBER) IS
 SELECT deceased_ind
 FROM igs_pe_hz_parties
 WHERE party_id = cp_person_id;

 l_date_of_death DATE;
 l_deceased_ind VARCHAR2(1);
BEGIN
 OPEN hz_dod_cur(p_person_id);
 FETCH hz_dod_cur INTO l_date_of_death;
 CLOSE hz_dod_cur;

 IF l_date_of_death IS NOT NULL THEN
   RETURN 'Y';
 ELSE

   OPEN igs_dod_cur(p_person_id);
   FETCH igs_dod_cur INTO l_deceased_ind;
   CLOSE igs_dod_cur;

   IF l_deceased_ind IS NOT NULL THEN
     RETURN l_deceased_ind;
   ELSE
     RETURN 'N';
   END IF;

 END IF;

END get_deceased_indicator;

END igs_pe_gen_004;

/
