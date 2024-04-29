--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPLACEMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPLACEMENTS_API" AS
/* $Header: IGSENB0B.pls 120.2 2005/10/02 23:47:37 appldev ship $ */

--cursor to retrieve rowid forgiven SplacementId and SupervisorId
Cursor cur_sp(c_splacement_id NUMBER, c_supervisor_id NUMBER) IS
                 Select rowid from IGS_EN_SPLACE_SUPS where Splacement_id=c_splacement_id
				 and supervisor_id=c_supervisor_id;


FUNCTION create_plcmnt_sup (
p_person_id IN NUMBER,
p_last_name IN VARCHAR2,
p_first_name IN VARCHAR2,
p_title IN VARCHAR2,
p_employment_history_id IN OUT NOCOPY NUMBER,
p_email_address IN VARCHAR2,
p_email_id IN NUMBER,
p_email_ovn IN NUMBER,
p_phone IN VARCHAR2,
p_phone_id IN NUMBER,
p_phone_ovn IN NUMBER,
p_ignore_duplicate IN VARCHAR2 ,
p_party_number IN OUT NOCOPY VARCHAR2,
p_empl_ovn IN OUT NOCOPY HZ_EMPLOYMENT_HISTORY.OBJECT_VERSION_NUMBER%TYPE) RETURN NUMBER
IS
-------------------------------------------------------------------
--  rvangala    28-OCT-2003    Created
--                             Saves placement supervisor information
--
--
-- ssaleem     01-DEC-2003     Bug : 3223943 Added Object version Number as parameter
--skpandey     01-OCT-2005     Bug: 3663505
--                             Description: Added ATTRIBUTES 21 TO 24 TO STORE ADDITIONAL INFORMATION
---------------------------------------------------------------------


        Cursor cur_c1(c_person_id IN NUMBER, c_emp_hist_id IN NUMBER) IS SELECT *  FROM IGS_AD_EMP_DTL
	WHERE person_id=c_person_id
	AND employment_history_id=c_emp_hist_id;

	Cursor cur_c2 IS SELECT *
	FROM IGS_PE_CONTACTS_V
	WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
	AND OWNER_TABLE_ID = P_PERSON_ID
	AND CONTACT_POINT_ID = P_PHONE_ID
	AND CONTACT_POINT_TYPE = 'PHONE'
	FOR UPDATE NOWAIT;

	Cursor cur_c3 IS SELECT *
	FROM IGS_PE_CONTACTS_V
	WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
	AND OWNER_TABLE_ID = P_PERSON_ID
	AND CONTACT_POINT_ID = P_EMAIL_ID
	AND CONTACT_POINT_TYPE = 'EMAIL'
	FOR UPDATE NOWAIT;

	Cursor cur_c4(c_person_id IN NUMBER) IS SELECT party_number
	FROM HZ_PARTIES
	WHERE HZ_PARTIES.PARTY_ID=c_person_id;

	l_profile_id VARCHAR2(60) :=NULL;
	l_dup_found VARCHAR2(1) :=NULL;
	l_dup_where_clause VARCHAR2(2000) :=NULL;
	l_partial VARCHAR2(1) :=NULL;
	l_rowid VARCHAR2(25) :=NULL;
	l_msg_data VARCHAR2(2000) :=NULL;
	l_msg_count NUMBER :=NULL;
	l_return_status VARCHAR2(10) :=NULL;
	l_person_id IGS_PE_PERSON.PERSON_ID%TYPE :=P_PERSON_ID;
	l_person_number IGS_PE_PERSON.PERSON_NUMBER%TYPE :=NULL;
	l_hz_parties_ovn  NUMBER(10);
	l_last_update_date HZ_CONTACT_POINTS.LAST_UPDATE_DATE%TYPE :=NULL;
	l_contact_point_id HZ_CONTACT_POINTS.CONTACT_POINT_ID%TYPE :=NULL;
	l_contact_point_ovn HZ_CONTACT_POINTS.OBJECT_VERSION_NUMBER%TYPE :=NULL;
        l_phone HZ_CONTACT_POINTS.PHONE_NUMBER%TYPE := P_PHONE;
	l_phone_id HZ_CONTACT_POINTS.CONTACT_POINT_ID%TYPE := P_PHONE_ID;
	l_phone_ovn HZ_CONTACT_POINTS.OBJECT_VERSION_NUMBER%TYPE := P_PHONE_OVN;
        l_email_address IGS_PE_CONTACTS_V.EMAIL_ADDRESS%TYPE := P_EMAIL_ADDRESS;
	l_email_id IGS_PE_CONTACTS_V.EMAIL_ADDRESS%TYPE := P_EMAIL_ID;
	l_email_ovn HZ_CONTACT_POINTS.OBJECT_VERSION_NUMBER%TYPE := P_EMAIL_OVN;
	l_employment_history_id IGS_AD_EMP_DTL.EMPLOYMENT_HISTORY_ID%TYPE := P_EMPLOYMENT_HISTORY_ID;

	l_emp_obj_ver_no IGS_AD_EMP_DTL.OBJECT_VERSION_NUMBER%TYPE;
	v_emp_hist_rec cur_c1%ROWTYPE;
	v_phone_update_rec cur_c2%ROWTYPE;
	v_email_update_rec cur_c3%ROWTYPE;
BEGIN

IF P_PERSON_ID IS NULL AND P_LAST_NAME IS NOT NULL THEN
  IF NVL(P_IGNORE_DUPLICATE,'N') = 'N' THEN
    l_profile_id := FND_PROFILE.VALUE('IGS_PE_DUP_MATCH_CRITERIA');

    IGS_PE_DUP_PERSON.FIND_DUPLICATES(
      X_MATCH_SET_ID => l_profile_id,
      X_SURNAME => P_LAST_NAME,
      X_GIVEN_NAMES => P_FIRST_NAME,
      X_BIRTH_DT => NULL,
      X_SEX => NULL,
      X_DUP_FOUND => l_dup_found,
      X_WHERE_CLAUSE => l_dup_where_clause,
      X_EXACT_PARTIAL => l_partial,
      X_PREF_ALTERNATE_ID => NULL
      );

      IF l_dup_found = 'Y' THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PLCMNT_SUP_DUP');
        FND_MESSAGE.SET_TOKEN('PERSON_NAME',P_LAST_NAME || ', ' || P_FIRST_NAME);
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
   END IF;

    IGS_PE_PERSON_PKG.INSERT_ROW(
    X_ROWID                => l_rowid,
    X_MSG_DATA             => L_MSG_DATA,
    X_MSG_COUNT            => L_MSG_COUNT,
    X_RETURN_STATUS        => L_RETURN_STATUS,
    X_PERSON_ID            => L_PERSON_ID,
    X_PERSON_NUMBER        => L_PERSON_NUMBER,
    X_SURNAME              => P_LAST_NAME,
    X_MIDDLE_NAME          => NULL,
    X_GIVEN_NAMES          => P_FIRST_NAME,
    X_SEX                  => NULL,
    X_TITLE                => NULL,
    X_STAFF_MEMBER_IND     => NULL,
    X_DECEASED_IND         => NULL,
    X_SUFFIX               => NULL,
    X_PRE_NAME_ADJUNCT     => NULL,
    X_ARCHIVE_EXCLUSION_IND=> NULL,
    X_ARCHIVE_DT           => NULL,
    X_PURGE_EXCLUSION_IND  => NULL,
    X_PURGE_DT             => NULL,
    X_DECEASED_DATE        => NULL,
    X_PROOF_OF_INS         => NULL,
    X_PROOF_OF_IMMU        => NULL,
    X_BIRTH_DT             => NULL,
    X_SALUTATION           => NULL,
    X_ORACLE_USERNAME      => NULL,
    X_PREFERRED_GIVEN_NAME => NULL,
    X_EMAIL_ADDR           => NULL,
    X_LEVEL_OF_QUAL_ID     => NULL,
    X_MILITARY_SERVICE_REG => NULL,
    X_VETERAN              => NULL,
    X_HZ_PARTIES_OVN       => l_hz_parties_ovn,
    X_ATTRIBUTE_CATEGORY   => NULL,
    X_ATTRIBUTE1           => NULL,
    X_ATTRIBUTE2           => NULL,
    X_ATTRIBUTE3           => NULL,
    X_ATTRIBUTE4           => NULL,
    X_ATTRIBUTE5           => NULL,
    X_ATTRIBUTE6           => NULL,
    X_ATTRIBUTE7           => NULL,
    X_ATTRIBUTE8           => NULL,
    X_ATTRIBUTE9           => NULL,
    X_ATTRIBUTE10          => NULL,
    X_ATTRIBUTE11          => NULL,
    X_ATTRIBUTE12          => NULL,
    X_ATTRIBUTE13          => NULL,
    X_ATTRIBUTE14          => NULL,
    X_ATTRIBUTE15          => NULL,
    X_ATTRIBUTE16          => NULL,
    X_ATTRIBUTE17          => NULL,
    X_ATTRIBUTE18          => NULL,
    X_ATTRIBUTE19          => NULL,
    X_ATTRIBUTE20          => NULL,
    X_PERSON_ID_TYPE       => NULL,
    X_API_PERSON_ID        => NULL,
    X_MODE                 => 'S',
    X_ATTRIBUTE21          => NULL,
    X_ATTRIBUTE22          => NULL,
    X_ATTRIBUTE23          => NULL,
    X_ATTRIBUTE24          => NULL);

  IF l_return_status IN ('E','U') THEN
      FND_MESSAGE.SET_ENCODED(l_msg_data);
      APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

END IF;

-- if phone number is not null but phone_id is null, new entry insert
IF P_PHONE IS NOT NULL AND P_PHONE_ID IS NULL THEN
       IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKP(
         P_ACTION               => 'INSERT',
         P_ROWID                => l_rowid,
         P_STATUS               => 'A',
         P_OWNER_TABLE_NAME     => 'HZ_PARTIES',
         P_OWNER_TABLE_ID       => L_PERSON_ID,
         P_PRIMARY_FLAG         => 'Y',
         P_PHONE_COUNTRY_CODE   => NULL,
         P_PHONE_AREA_CODE      => NULL,
         P_PHONE_NUMBER         => P_PHONE,
         P_PHONE_EXTENSION      => NULL,
         P_PHONE_LINE_TYPE      => 'GEN',
         P_RETURN_STATUS        => l_return_status,
         P_MSG_DATA             => l_msg_data,
         P_LAST_UPDATE_DATE     => l_last_update_date,
         P_CONTACT_POINT_ID     => L_CONTACT_POINT_ID,
         P_CONTACT_POINT_OVN    => L_CONTACT_POINT_OVN,
         P_ATTRIBUTE_CATEGORY   => NULL,
         P_ATTRIBUTE1           => NULL,
         P_ATTRIBUTE2           => NULL,
         P_ATTRIBUTE3           => NULL,
         P_ATTRIBUTE4           => NULL,
         P_ATTRIBUTE5           => NULL,
         P_ATTRIBUTE6           => NULL,
         P_ATTRIBUTE7           => NULL,
         P_ATTRIBUTE8           => NULL,
         P_ATTRIBUTE9           => NULL,
         P_ATTRIBUTE10          => NULL,
         P_ATTRIBUTE11          => NULL,
         P_ATTRIBUTE12          => NULL,
         P_ATTRIBUTE13          => NULL,
         P_ATTRIBUTE14          => NULL,
         P_ATTRIBUTE15          => NULL,
         P_ATTRIBUTE16          => NULL,
         P_ATTRIBUTE17          => NULL,
         P_ATTRIBUTE18          => NULL,
         P_ATTRIBUTE19          => NULL,
         P_ATTRIBUTE20          => NULL);

 ELSE -- if phone id is not null, it is an existing record, so update

  --Select all the details of the PHONE record using a cursor based on the  PERSON_ID, OBJECT VERSION NUMBER AND PHONE_ID
 OPEN cur_c2;
 FETCH cur_c2 INTO v_phone_update_rec;

 IF cur_c2%FOUND THEN
  IF v_phone_update_rec.OBJECT_VERSION_NUMBER <> P_PHONE_OVN THEN
-- the record was updated by some other user hence the object version number is not matching.
   CLOSE cur_c2;
   FND_MESSAGE.SET_NAME ('FND',' FORM_RECORD_DELETED');
   IGS_GE_MSG_STACK.ADD;
   APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
 END IF;


--Call the IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKP with the action as updated
 IF cur_c2%FOUND AND (nvl(v_phone_update_rec.phone_number,'null')<>nvl(p_phone,'null')) THEN
   IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKP (
        P_ACTION            =>'UPDATE',
        P_ROWID             => V_PHONE_UPDATE_REC.ROW_ID,
        P_STATUS            => 'A',
        P_OWNER_TABLE_NAME  => 'HZ_PARTIES',
        P_OWNER_TABLE_ID    => P_PERSON_ID,
        P_PRIMARY_FLAG      => 'Y',
        P_PHONE_COUNTRY_CODE   => V_PHONE_UPDATE_REC.PHONE_COUNTRY_CODE,
        P_PHONE_AREA_CODE      => V_PHONE_UPDATE_REC.PHONE_AREA_CODE,
        P_PHONE_NUMBER         => P_PHONE,
        P_PHONE_EXTENSION      => V_PHONE_UPDATE_REC.PHONE_EXTENSION,
        P_PHONE_LINE_TYPE      => V_PHONE_UPDATE_REC.PHONE_LINE_TYPE,
        P_RETURN_STATUS     => l_return_status,
        P_MSG_DATA          => l_msg_data,
        P_LAST_UPDATE_DATE  => V_PHONE_UPDATE_REC.LAST_UPDATE_DATE,
        P_CONTACT_POINT_ID  => l_phone_id,
        P_CONTACT_POINT_OVN => l_phone_ovn,
        P_ATTRIBUTE_CATEGORY=> V_PHONE_UPDATE_REC. ATTRIBUTE_CATEGORY,
        P_ATTRIBUTE1        => V_PHONE_UPDATE_REC.ATTRIBUTE1,
        P_ATTRIBUTE2        => V_PHONE_UPDATE_REC.ATTRIBUTE2,
        P_ATTRIBUTE3        => V_PHONE_UPDATE_REC.ATTRIBUTE3,
        P_ATTRIBUTE4        => V_PHONE_UPDATE_REC.ATTRIBUTE4,
        P_ATTRIBUTE5        => V_PHONE_UPDATE_REC.ATTRIBUTE5,
        P_ATTRIBUTE6        => V_PHONE_UPDATE_REC.ATTRIBUTE6,
        P_ATTRIBUTE7        => V_PHONE_UPDATE_REC.ATTRIBUTE7,
        P_ATTRIBUTE8        => V_PHONE_UPDATE_REC.ATTRIBUTE8,
        P_ATTRIBUTE9        => V_PHONE_UPDATE_REC.ATTRIBUTE9,
        P_ATTRIBUTE10       => V_PHONE_UPDATE_REC.ATTRIBUTE10,
        P_ATTRIBUTE12       => V_PHONE_UPDATE_REC.ATTRIBUTE12,
        P_ATTRIBUTE13       => V_PHONE_UPDATE_REC.ATTRIBUTE13,
        P_ATTRIBUTE14       => V_PHONE_UPDATE_REC.ATTRIBUTE14,
        P_ATTRIBUTE15       => V_PHONE_UPDATE_REC.ATTRIBUTE15,
        P_ATTRIBUTE16       => V_PHONE_UPDATE_REC.ATTRIBUTE16,
        P_ATTRIBUTE17       => V_PHONE_UPDATE_REC.ATTRIBUTE17,
        P_ATTRIBUTE18       => V_PHONE_UPDATE_REC.ATTRIBUTE18,
        P_ATTRIBUTE19       => V_PHONE_UPDATE_REC.ATTRIBUTE19,
        P_ATTRIBUTE20       => V_PHONE_UPDATE_REC.ATTRIBUTE20);
   END IF;
   CLOSE cur_c2;

    IF l_return_status IN ('E', 'U') THEN
     FND_MESSAGE.SET_ENCODED (l_msg_data);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
END IF;

-- if email address is not null but email id is null, new record - insert
IF P_EMAIL_ADDRESS IS NOT NULL AND P_EMAIL_ID IS NULL THEN

     IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKE(
        P_ACTION            =>'INSERT',
        P_ROWID             => l_rowid,
        P_STATUS            => 'A',
        P_OWNER_TABLE_NAME  => 'HZ_PARTIES',
        P_OWNER_TABLE_ID    =>  L_PERSON_ID,
        P_PRIMARY_FLAG      => 'Y',
        P_EMAIL_FORMAT      => 'MAILTEXT',
        P_EMAIL_ADDRESS     => P_EMAIL_ADDRESS,
        P_RETURN_STATUS     => l_return_status,
        P_MSG_DATA          => l_msg_data,
        P_LAST_UPDATE_DATE  => L_LAST_UPDATE_DATE,
        P_CONTACT_POINT_ID  => l_email_id,
  	P_CONTACT_POINT_OVN => L_CONTACT_POINT_OVN,
        P_ATTRIBUTE_CATEGORY=> NULL,
        P_ATTRIBUTE1        => NULL,
        P_ATTRIBUTE2        => NULL,
        P_ATTRIBUTE3        => NULL,
        P_ATTRIBUTE4        => NULL,
        P_ATTRIBUTE5        => NULL,
        P_ATTRIBUTE6        => NULL,
        P_ATTRIBUTE7        => NULL,
        P_ATTRIBUTE8        => NULL,
        P_ATTRIBUTE9        => NULL,
        P_ATTRIBUTE10       => NULL,
        P_ATTRIBUTE11       => NULL,
        P_ATTRIBUTE12       => NULL,
        P_ATTRIBUTE13       => NULL,
        P_ATTRIBUTE14       => NULL,
        P_ATTRIBUTE15       => NULL,
        P_ATTRIBUTE16       => NULL,
        P_ATTRIBUTE17       => NULL,
        P_ATTRIBUTE18       => NULL,
        P_ATTRIBUTE19       => NULL,
        P_ATTRIBUTE20       => NULL);

ELSE --if email id is not null, existing record - so update email details

  --Select all the details of the email record using a cursor based on the  PERSON_ID, OBJECT VERSION NUMBER AND EMAIL_ID
  OPEN cur_c3;
  FETCH cur_c3 INTO v_email_update_rec;

 IF cur_c3%FOUND THEN
 IF V_EMAIL_UPDATE_REC.OBJECT_VERSION_NUMBER <> l_EMAIL_OVN THEN
-- the record was updated by some other user hence the object version number is not matching.
  CLOSE cur_c3;
  FND_MESSAGE.SET_NAME('FND',' FORM_RECORD_DELETED');
  IGS_GE_MSG_STACK.ADD;
  APP_EXCEPTION.RAISE_EXCEPTION;
 END IF;
 END IF;

IF p_email_address IS NULL THEN
  l_email_address:=' ';
ELSE
  l_email_address:=p_email_address;
END IF;

--Call the IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKE with the action as updated
IF cur_c3%FOUND AND (nvl(v_email_update_rec.email_address,'null')<>nvl(l_email_address,'null')) THEN
   IGS_PE_CONTACT_POINT_PKG.HZ_CONTACT_POINTS_AKE(
        P_ACTION            => 'UPDATE',
        P_ROWID             =>  V_EMAIL_UPDATE_REC.ROW_ID,
        P_STATUS            => 'A',
        P_OWNER_TABLE_NAME  => 'HZ_PARTIES',
        P_OWNER_TABLE_ID    =>  P_PERSON_ID,
        P_PRIMARY_FLAG      => 'Y',
        P_EMAIL_FORMAT      => V_EMAIL_UPDATE_REC.EMAIL_FORMAT,
        P_EMAIL_ADDRESS     => l_EMAIL_ADDRESS,
        P_RETURN_STATUS     => l_RETURN_STATUS,
        P_MSG_DATA          => l_MSG_DATA,
        P_LAST_UPDATE_DATE  => V_EMAIL_UPDATE_REC.LAST_UPDATE_DATE,
        P_CONTACT_POINT_ID  => L_EMAIL_ID,
  	P_CONTACT_POINT_OVN => L_EMAIL_OVN,
        P_ATTRIBUTE_CATEGORY=> V_EMAIL_UPDATE_REC.ATTRIBUTE_CATEGORY,
        P_ATTRIBUTE1        => V_EMAIL_UPDATE_REC.ATTRIBUTE1,
        P_ATTRIBUTE2        => V_EMAIL_UPDATE_REC.ATTRIBUTE2,
        P_ATTRIBUTE3        => V_EMAIL_UPDATE_REC.ATTRIBUTE3,
        P_ATTRIBUTE4        => V_EMAIL_UPDATE_REC.ATTRIBUTE4,
        P_ATTRIBUTE5        => V_EMAIL_UPDATE_REC.ATTRIBUTE5,
        P_ATTRIBUTE6        => V_EMAIL_UPDATE_REC.ATTRIBUTE6,
        P_ATTRIBUTE7        => V_EMAIL_UPDATE_REC.ATTRIBUTE7,
        P_ATTRIBUTE8        => V_EMAIL_UPDATE_REC.ATTRIBUTE8,
        P_ATTRIBUTE9        => V_EMAIL_UPDATE_REC.ATTRIBUTE9,
        P_ATTRIBUTE10       => V_EMAIL_UPDATE_REC.ATTRIBUTE10,
        P_ATTRIBUTE12       => V_EMAIL_UPDATE_REC.ATTRIBUTE12,
        P_ATTRIBUTE13       => V_EMAIL_UPDATE_REC.ATTRIBUTE13,
        P_ATTRIBUTE14       => V_EMAIL_UPDATE_REC.ATTRIBUTE14,
        P_ATTRIBUTE15       => V_EMAIL_UPDATE_REC.ATTRIBUTE15,
        P_ATTRIBUTE16       => V_EMAIL_UPDATE_REC.ATTRIBUTE16,
        P_ATTRIBUTE17       => V_EMAIL_UPDATE_REC.ATTRIBUTE17,
        P_ATTRIBUTE18       => V_EMAIL_UPDATE_REC.ATTRIBUTE18,
        P_ATTRIBUTE19       => V_EMAIL_UPDATE_REC.ATTRIBUTE19,
        P_ATTRIBUTE20       => V_EMAIL_UPDATE_REC.ATTRIBUTE20);
	END IF;
	CLOSE cur_c3;

        -- CHECK FOR THE V_RETURN_STATUS
    IF l_RETURN_STATUS IN ( 'E' , 'U' ) THEN
       FND_MESSAGE.SET_ENCODED(L_MSG_DATA);
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END IF;


IF P_TITLE IS NOT NULL THEN

    OPEN cur_c1(l_person_id,p_employment_history_id);
	FETCH cur_c1 INTO v_emp_hist_rec;

	IF cur_c1%FOUND THEN
    IGS_AD_EMP_DTL_PKG.UPDATE_ROW (
      X_ROWID                             => V_EMP_HIST_REC.ROW_ID,
      X_EMPLOYMENT_HISTORY_ID             => V_EMP_HIST_REC.EMPLOYMENT_HISTORY_ID,
      X_PERSON_ID                         => l_PERSON_ID,
      X_START_DT                          => V_EMP_HIST_REC.START_DT,
      X_END_DT                            => V_EMP_HIST_REC.END_DT,
      X_TYPE_OF_EMPLOYMENT                => V_EMP_HIST_REC.TYPE_OF_EMPLOYMENT,
      X_FRACTION_OF_EMPLOYMENT            => V_EMP_HIST_REC.FRACTION_OF_EMPLOYMENT,
      X_TENURE_OF_EMPLOYMENT              => V_EMP_HIST_REC.TENURE_OF_EMPLOYMENT,
      X_POSITION                          => p_title,
      X_OCCUPATIONAL_TITLE_CODE           => V_EMP_HIST_REC.OCCUPATIONAL_TITLE_CODE,
      X_OCCUPATIONAL_TITLE                => V_EMP_HIST_REC.OCCUPATIONAL_TITLE,
      X_WEEKLY_WORK_HOURS                 => V_EMP_HIST_REC.WEEKLY_WORK_HOURS,
      X_COMMENTS                          => V_EMP_HIST_REC.COMMENTS,
      X_EMPLOYER                          => V_EMP_HIST_REC.EMPLOYER,
      X_EMPLOYED_BY_DIVISION_NAME         => V_EMP_HIST_REC.EMPLOYED_BY_DIVISION_NAME,
      X_BRANCH                            => V_EMP_HIST_REC.BRANCH,
      X_MILITARY_RANK                     => V_EMP_HIST_REC.MILITARY_RANK,
      X_SERVED                            => V_EMP_HIST_REC.SERVED,
      X_STATION                           => V_EMP_HIST_REC.STATION,
      X_CONTACT                           => V_EMP_HIST_REC.CONTACT,
      X_MSG_DATA                          => L_MSG_DATA,
      X_RETURN_STATUS                     => L_RETURN_STATUS,
      X_OBJECT_VERSION_NUMBER             => p_empl_ovn,
      X_EMPLOYED_BY_PARTY_ID              => V_EMP_HIST_REC.EMPLOYED_BY_PARTY_ID,
      X_REASON_FOR_LEAVING                => V_EMP_HIST_REC.REASON_FOR_LEAVING
      );
	  p_employment_history_id :=v_emp_hist_rec.EMPLOYMENT_HISTORY_ID;
      CLOSE cur_c1;

   ELSE
    IGS_AD_EMP_DTL_PKG.INSERT_ROW (
      X_ROWID                             => L_ROWID,
      X_EMPLOYMENT_HISTORY_ID             => l_EMPLOYMENT_HISTORY_ID,
      X_PERSON_ID                         => l_PERSON_ID,
      X_START_DT                          => SYSDATE,
      X_END_DT                            => NULL,
      X_TYPE_OF_EMPLOYMENT                => NULL,
      X_FRACTION_OF_EMPLOYMENT            => NULL,
      X_TENURE_OF_EMPLOYMENT              => NULL,
      X_POSITION                          => P_TITLE,
      X_OCCUPATIONAL_TITLE_CODE           => NULL,
      X_OCCUPATIONAL_TITLE                => NULL,
      X_WEEKLY_WORK_HOURS                 => NULL,
      X_COMMENTS                          => NULL,
      X_EMPLOYER                          => NULL,
      X_EMPLOYED_BY_DIVISION_NAME         => NULL,
      X_BRANCH                            => NULL,
      X_MILITARY_RANK                     => NULL,
      X_SERVED                            => NULL,
      X_STATION                           => NULL,
      X_CONTACT                           => NULL,
      X_MSG_DATA                          => L_MSG_DATA,
      X_RETURN_STATUS                     => L_RETURN_STATUS,
      X_OBJECT_VERSION_NUMBER             => L_EMP_OBJ_VER_NO,
      X_EMPLOYED_BY_PARTY_ID              => NULL,
      X_REASON_FOR_LEAVING                => NULL
    );
	 p_employment_history_id :=l_employment_history_id;

	  CLOSE cur_c1;
    IF L_RETURN_STATUS IN ('E','U') THEN
      FND_MESSAGE.SET_ENCODED(L_MSG_DATA);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

 END IF;
END IF;

    IF (p_party_number IS NULL and l_person_id IS NOT NULL) THEN
	 OPEN cur_c4(l_person_id);
	 FETCH cur_c4 INTO p_party_number;
	 CLOSE cur_c4;
	END IF;

    RETURN l_person_id;
END create_plcmnt_sup;

FUNCTION get_splacement_id RETURN NUMBER
IS
-------------------------------------------------------------------
--  rvangala    28-OCT-2003    Created
--                             Gets splacement_id from igs_en_splacements_s sequence


---------------------------------------------------------------------
  Cursor cur_s1 IS Select IGS_EN_Splacements_S.nextVal from dual;
  l_splacement_id NUMBER(15);
BEGIN
  OPEN cur_s1;
  FETCH cur_s1 INTO l_splacement_id;
  CLOSE cur_s1;
  RETURN l_splacement_id;

END get_splacement_id;

PROCEDURE delete_supervisor_info(p_splacement_id IN NUMBER, p_supervisor_id IN NUMBER)
IS
/*--------------------------------------------------------------
-- rvangala       01-NOV-2003          Created
--                                     Deletes supervisor from IGS_EN_SPLACE_SUPS
--
--
----------------------------------------------------------------
*/
 l_row_id VARCHAR2(30);
BEGIN
 OPEN cur_sp(p_splacement_id,p_supervisor_id);
 FETCH cur_sp INTO l_row_id;
 IF cur_sp%FOUND THEN
  igs_en_splace_sups_pkg.DELETE_ROW(l_row_id);
 END IF;
 CLOSE cur_sp;
END delete_supervisor_info;

/*--------------------------------------------------------------
-- rvangala       01-NOV-2003          Created
--                                     Processes creation/updation of placement information
--                                     Returns PersonId, which is new Id for a new person
--                                     and old Id for an existing person
--
--ssaleem          01-DEC-2003          Bug : 3223943 Added Object version Number as parameter
----------------------------------------------------------------
*/
FUNCTION process_supervisor_info(p_splacement_id IN NUMBER,
p_person_id IN NUMBER,
p_last_name IN VARCHAR2,
p_first_name IN VARCHAR2,
p_title IN VARCHAR2,
p_employment_history_id IN OUT NOCOPY NUMBER,
p_email_address IN VARCHAR2,
p_email_id IN NUMBER,
p_email_ovn IN NUMBER,
p_phone IN VARCHAR2,
p_phone_id IN NUMBER,
p_phone_ovn IN NUMBER,
p_ignore_duplicate IN VARCHAR2,
p_party_number IN OUT NOCOPY VARCHAR2,
p_object_version_number IN OUT  NOCOPY HZ_EMPLOYMENT_HISTORY.OBJECT_VERSION_NUMBER%TYPE) RETURN NUMBER
IS
 l_rowid VARCHAR2(25);
 l_mode VARCHAR2(1) :='R';
 l_person_id NUMBER(15);
BEGIN

	l_person_id := create_plcmnt_sup (p_person_id => p_person_id,
					   p_last_name   => p_last_name,
					   p_first_name => p_first_name,
					   p_title => p_title,
					   p_employment_history_id => p_employment_history_id,
					   p_email_address => p_email_address,
					   p_email_id => p_email_id,
					   p_email_ovn => p_email_ovn,
					   p_phone => p_phone,
					   p_phone_id => p_phone_id,
					   p_phone_ovn => p_phone_ovn,
					   p_ignore_duplicate => p_ignore_duplicate,
					   p_party_number => p_party_number,
					   p_empl_ovn => p_object_version_number);

	OPEN cur_sp(p_splacement_id,p_person_id);
	FETCH cur_sp INTO l_rowid;

	IF cur_sp%NOTFOUND THEN
	  igs_en_splace_sups_pkg.INSERT_ROW(
	  									x_rowid         => l_rowid,
										x_splacement_id => p_splacement_id,
										x_supervisor_id => l_person_id,
										x_mode          => l_mode);
	END IF;
	CLOSE cur_sp;
	RETURN l_person_id;
END process_supervisor_info;


END igs_en_splacements_api;

/
