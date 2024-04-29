--------------------------------------------------------
--  DDL for Package Body IGS_GE_MNT_SDTT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_MNT_SDTT" AS
/* $Header: IGSGE06B.pls 120.2 2006/01/20 05:49:59 skpandey ship $ */

L_ROWID VARCHAR2(25);

 -- Delete a record in the table s_disable_table_trigger.
  PROCEDURE GENP_DEL_SDTT(
  p_table_name IN VARCHAR2 )
  AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE

  	--- Delete a record from the s_disable_table_trigger
  	--- database table.
	CURSOR CUR_DISB_TAB_TRG IS
	SELECT ROWID , IGS_GE_S_DSB_TAB_TRG.*
  	FROM	IGS_GE_S_DSB_TAB_TRG
  	WHERE	table_name = p_table_name	AND
  		session_id = (
  			SELECT	userenv('SESSIONID')
  			FROM	dual );
  BEGIN
	for DISB_TAB_TRG_REC IN CUR_DISB_TAB_TRG loop
		IGS_GE_S_DSB_TAB_TRG_PKG.DELETE_ROW(X_ROWID => DISB_TAB_TRG_REC.ROWID );
	end loop;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception ;
  END genp_del_sdtt;

-- to validate whether the person is a staff member
FUNCTION pid_val_staff
(p_person_id IN NUMBER,
 p_preferred_name OUT NOCOPY VARCHAR2
 )
RETURN BOOLEAN IS

	l_is_staff VARCHAR2(25);
	l_all_person VARCHAR2(25);

	CURSOR C_STAFF (cp_staff_var VARCHAR2) IS
		SELECT 'X'
		FROM igs_pe_per_type_map
		WHERE system_type = cp_staff_var;

	CURSOR C_ALLPERSON (cp_person_id VARCHAR2) IS
	SELECT 'X'
	FROM per_all_people_f
	WHERE party_id = cp_person_id;

	CURSOR C_OSSUSER (cp_staff_var VARCHAR2, cp_person_id VARCHAR2) IS
		SELECT NVL(HZ.KNOWN_AS, SUBSTR (HZ.PERSON_FIRST_NAME, 1, DECODE(INSTR(HZ.PERSON_FIRST_NAME, ' '),
			0, LENGTH(HZ.PERSON_FIRST_NAME), (INSTR(HZ.PERSON_FIRST_NAME, ' ')-1)))) || ' ' || HZ.PERSON_LAST_NAME
			PREFERRED_NAME
		FROM  IGS_PE_PERSON_TYPES PT,IGS_PE_TYP_INSTANCES_ALL PTI,HZ_PARTIES HZ
		WHERE HZ.PARTY_ID = PTI.PERSON_ID
		     AND HZ.PARTY_ID = cp_person_id
		     AND PTI.PERSON_TYPE_CODE = PT.PERSON_TYPE_CODE
		     AND PT.SYSTEM_TYPE = cp_staff_var
		     AND TRUNC(SYSDATE) BETWEEN TRUNC(PTI.START_DATE) AND TRUNC(NVL(PTI.END_DATE,SYSDATE))
		     AND HZ.STATUS = 'A';

--skpandey, Bug#4937960: Changed C_HRUSER cursor definition to optimize query
	CURSOR C_HRUSER (cp_staff_var VARCHAR2, cp_person_id VARCHAR2) IS
		SELECT  NVL(HZ.KNOWN_AS, SUBSTR (HZ.PERSON_FIRST_NAME, 1, DECODE(INSTR(HZ.PERSON_FIRST_NAME, ' '),
			0, LENGTH(HZ.PERSON_FIRST_NAME), (INSTR(HZ.PERSON_FIRST_NAME, ' ')-1)))) || ' ' || HZ.PERSON_LAST_NAME
			PREFERRED_NAME
	       FROM PER_PERSON_TYPE_USAGES_F USG,PER_ALL_PEOPLE_F PEO,IGS_PE_PER_TYPE_MAP MAP,HZ_PARTIES HZ
	       WHERE HZ.PARTY_ID = peo.party_id
		     AND USG.PERSON_ID = PEO.PERSON_ID
		     AND HZ.PARTY_ID = cp_person_id
		     AND USG.PERSON_TYPE_ID = MAP.PER_PERSON_TYPE_ID
		     AND MAP.SYSTEM_TYPE = cp_staff_var AND
		     TRUNC(SYSDATE) BETWEEN TRUNC(PEO.EFFECTIVE_START_DATE) AND TRUNC(PEO.EFFECTIVE_END_DATE)
		     AND TRUNC(SYSDATE) BETWEEN TRUNC(USG.EFFECTIVE_START_DATE) AND TRUNC(USG.EFFECTIVE_END_DATE)
		     AND HZ.STATUS = 'A';


BEGIN
	 OPEN c_staff ('STAFF');
	 FETCH c_staff INTO l_is_staff;
	 CLOSE c_staff;
	 OPEN c_allperson (p_person_id);
	 FETCH c_allperson INTO l_all_person;
	 CLOSE c_allperson;
	 IF l_is_staff IS NOT NULL AND l_all_person IS NOT NULL THEN

		 OPEN c_hruser ('STAFF', p_person_id);
		 FETCH c_hruser INTO p_preferred_name;
		 CLOSE c_hruser;
		 IF p_preferred_name IS NOT NULL THEN
			RETURN TRUE;
		 ELSE
			RETURN FALSE;
		 END IF;
	 ELSE

		 OPEN c_ossuser ('STAFF', p_person_id);
		 FETCH c_ossuser INTO p_preferred_name;
		 CLOSE c_ossuser;
		 IF p_preferred_name IS NOT NULL THEN
			RETURN TRUE;
		 ELSE
			RETURN FALSE;
		 END IF;
	END IF;

END;

-- This function takes a varchar string and a format mask and checks whether the string is in the passed format or not. Bug : 2325141
FUNCTION check_format_mask(s IN VARCHAR2, t IN VARCHAR2) RETURN BOOLEAN IS
  l_str_len  NUMBER  := LENGTH(s);
  l_trans_s  IGS_PE_PERSON_ID_TYP.FORMAT_MASK%TYPE := NULL;
  l_chr      VARCHAR2(1);
BEGIN
  FOR i IN 1..l_str_len LOOP
    l_chr := SUBSTR(s,i,1);
    IF l_chr IN ('0','1','2','3','4','5','6','7','8','9') THEN
      l_trans_s :=l_trans_s||'9';
    ELSIF l_chr IN (' ','-','_','+','=',')','(','*','&','^','%','$','#','','!','`','~','/','\')
    THEN
      l_trans_s :=l_trans_s||l_chr;
    ELSE
      l_trans_s:=l_trans_s||'X';
    END IF;
  END LOOP;
  IF t = l_trans_s THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END check_format_mask;

END IGS_GE_MNT_SDTT;

/
