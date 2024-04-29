--------------------------------------------------------
--  DDL for Package Body IGS_PE_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_GEN_001" AS
/* $Header: IGSPE12B.pls 120.7 2006/05/30 09:57:10 vskumar ship $ */
/* Change Hisotry
   Who          When        What
   ------------------------------
   pkpatel     30-SEP-2002    Bug No: 2600842
                              Added the functions get_hold_auth, validate_hold_desp and release_hold
  ssawhney    17-feb-2003     Bug 2758856  external holds design change, ENCUMB TBH parameter added.
  pkpatel      5-FEB-2003     Bug 2683186
                              Modify the error message from 'IGS_PE_HOLD_AUTH_REL' to l_message_name in validate_hold_resp procedure.
  pkpatel      8-APR-2003     Bug 2804863
                              Modified the procedures validate_hold_resp and release_hold
  ssaleem     13-OCT-2003     modified the cursor query in get_person_encumb and included
                              Inactive condition
  asbala     26-dec-03        3304598, added date check in cursor c1 of get_privacy_lvl_format_str
  prbhardw   18-Aug-2005      Bug No: 3690826 Changed use of IGS_PE_PRIV_LEVEL_V to IGS_PE_PRIV_LEVEL
  ssawhney   30-Aug-2005      Added function Get_Hold_Count
  pkpatel     8-Sep-2005      Bug No: 3690826 (removed the cursor c2 in Get_Privacy_Lvl_Format_Str)
*/
  FUNCTION  Get_Privacy_Lvl_Format_Str (
                p_person_id igs_pe_priv_level.person_id%TYPE
                  ) RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : kumma , Oracle India
  --Date created: 04-JUN-2002
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --asbala     26-dec-03     3304598, added date check in cursor c1
  -------------------------------------------------------------------
    lvcDisplayLevel VARCHAR2(1) := 'Y';
    lnLevel     NUMBER(10);
    lvcLevelDes VARCHAR2(30);
    lvcPrivacyLevel VARCHAR2(80);
    lvcPersonPrivacyLevel   VARCHAR2(200) := '';
    ln_data_Group_Id NUMBER(15);

    cursor c1 (lnpersonid number) is
    SELECT  max(dg.lvl) Max_Level, lvl.data_group_id, lvl_description
    FROM IGS_PE_PRIV_LEVEL lvl, IGS_PE_DATA_GROUPS DG
    WHERE lvl.person_id =  lnpersonid
    AND TRUNC(SYSDATE) BETWEEN lvl.start_date AND NVL(lvl.end_date,TRUNC(SYSDATE))
    and lvl.DATA_GROUP_ID = DG.DATA_GROUP_ID
    GROUP BY lvl.data_group_id, lvl_description
    ORDER BY 1 desc;

    cursor c3(cp_lookup_type VARCHAR2, cp_lookup_code VARCHAR2) is
    SELECT meaning
	FROM igs_lookup_values
    WHERE  lookup_type = cp_lookup_type AND lookup_code = cp_lookup_code;

    lvlinfo c1%rowtype;
    plinfo c3%rowtype;

   BEGIN

  OPEN c1(p_person_id);
  FETCH c1 INTO lvlinfo;

  LOOP
  IF (c1%NOTFOUND) THEN
    lvcDisplayLevel := 'N';
  ELSE
    lnLevel := lvlInfo.Max_Level;
    ln_data_Group_Id := lvlInfo.Data_Group_Id;
    lvcLevelDes := lvlInfo.lvl_description;
  END IF;
  EXIT;
  END LOOP;
  CLOSE c1;

  IF lvcDisplayLevel = 'Y' THEN
    OPEN c3('PRIVACY_LEVEL', 'LEVEL') ;
    FETCH c3 INTO plinfo;
    IF (c3%NOTFOUND) THEN
      lvcDisplayLevel := 'N';
    ELSE
      lvcPrivacyLevel := plinfo.meaning;
    END IF;
    CLOSE c3;
  END IF;

  IF lvcDisplayLevel = 'Y' THEN
    lvcPersonPrivacyLevel := '*' || lvcLevelDes || ' ' || TO_CHAR(lnLevel) || ' - ' || SUBSTR(lvcPrivacyLevel, 1, 7);
  END IF;

  RETURN lvcPersonPrivacyLevel;

  EXCEPTION
    WHEN OTHERS THEN
    return '';
  END Get_Privacy_Lvl_Format_Str;

  FUNCTION get_person_encumb(p_person_id igs_pe_person.person_id%TYPE) RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : rboddu , Oracle India
  --Date created: 16-JUL-2002
  --
  --Purpose: 2403680
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ssaleem     13-OCT-2003     modified the cursor query and included
  --                            Inactive condition
  -------------------------------------------------------------------

  cursor cur_deceased_hold(cp_person_id NUMBER) is
    SELECT DECODE(pp.date_of_death, NULL,NVL(pd.deceased_ind,'N'),'Y') deceased_flag,
           igs_en_gen_003.enrp_get_encmbrd_ind(p.party_id)  encumbered_ind,
       p.status status
    FROM   hz_parties p,
           igs_pe_hz_parties pd,
           hz_person_profiles pp
    WHERE  p.party_id = pp.party_id AND
           p.party_id = pd.party_id (+) AND
           sysdate between  pp.effective_start_date AND
                        NVL(pp.effective_end_date,sysdate) AND
       p.party_id = cp_person_id;

  rec_deceased_hold cur_deceased_hold%ROWTYPE;

  BEGIN
    OPEN cur_deceased_hold(p_person_id);
    FETCH cur_deceased_hold INTO rec_deceased_hold;
    CLOSE cur_deceased_hold;

    IF NVL(rec_deceased_hold.status,'Z') = 'I' THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_PS_INACTIVE');
        RETURN FND_MESSAGE.GET;
    ELSIF NVL(rec_deceased_hold.deceased_flag, 'Z') = 'Y' THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_FI_PER_DECEASED');
        RETURN FND_MESSAGE.GET;
    ELSIF NVL(rec_deceased_hold.encumbered_ind, 'Z') = 'Y' THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_FI_PER_ENC');
        RETURN FND_MESSAGE.GET;
    END IF;

    RETURN '';

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
  END get_person_encumb;

PROCEDURE get_hold_auth
            (p_fnd_user_id IN fnd_user.user_id%TYPE,
             p_person_id   OUT NOCOPY hz_parties.party_id%TYPE,
             p_person_number OUT NOCOPY hz_parties.party_number%TYPE,
             p_person_name OUT NOCOPY hz_person_profiles.person_name%TYPE,
             p_message_name OUT NOCOPY fnd_new_messages.message_name%TYPE
            ) IS
/*
  ||  Created By : pkpatel
  ||  Created On : 27-SEP-2002
  ||  Purpose : This Procedure will get hold Authorizer Information
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/
  -- Cursor to find the Person ID of the user logged in
  CURSOR person_cur IS
  SELECT person_party_id
  FROM   fnd_user
  WHERE  user_id = p_fnd_user_id AND
  SYSDATE between start_date AND NVL(end_date,SYSDATE);

  -- Cursor to find the full name of the user logged in
  CURSOR person_name_cur(cp_person_id hz_parties.party_id%TYPE) IS
  SELECT person_number,full_name
  FROM   igs_pe_person_base_v
  WHERE  person_id = cp_person_id;

  l_staff VARCHAR2(1);
BEGIN
  -- Check whether the User has a party account
  OPEN person_cur;
  FETCH person_cur INTO p_person_id;
    IF person_cur%NOTFOUND THEN
       CLOSE person_cur;
       p_message_name := 'IGS_PE_HOLD_AUTH_CR';
       RETURN;
    END IF;
  CLOSE person_cur;

  IF p_person_id IS NULL THEN  -- If no party account then RETURN
     p_message_name := 'IGS_PE_HOLD_AUTH_CR';
     RETURN;
  ELSE
     -- If party account is present then
     -- check whether the person is an Active Staff.
     -- If not then RETURN with setting the message
     l_staff := igs_en_gen_003.get_staff_ind(p_person_id);

     IF l_staff = 'N' THEN
        p_message_name := 'IGS_PE_HOLD_AUTH_CR';
        RETURN;
     END IF;

     -- Find the full name of the person
     OPEN person_name_cur(p_person_id);
     FETCH person_name_cur INTO p_person_number,p_person_name;
     CLOSE person_name_cur;

  END IF;

    p_message_name := NULL;

END get_hold_auth;


PROCEDURE validate_hold_resp
            (p_resp_id     IN fnd_responsibility.responsibility_id%TYPE,
             p_fnd_user_id IN fnd_user.user_id%TYPE,
             p_person_id   IN hz_parties.party_id%TYPE,
             p_encumbrance_type IN igs_pe_pers_encumb.encumbrance_type%TYPE,
             p_start_dt    IN igs_pe_pers_encumb.start_dt%TYPE,
             p_message_name OUT NOCOPY fnd_new_messages.message_name%TYPE
            ) IS
/*
  ||  Created By : pkpatel
  ||  Created On : 27-SEP-2002
  ||  Purpose : This Procedure will validate whether the Responsibility passed can release the hold applied on the person
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel         5-FEB-2003      Bug 2683186
  ||                                  Modify the error message from 'IGS_PE_HOLD_AUTH_REL' to l_message_name.
  ||  pkpatel         8-APR-2003      Bug 2804863
  ||                                  Added the check with igs_pe_gen_001.g_hold_validation for calling igs_pe_gen_001.get_hold_auth
  ||  (reverse chronological order - newest change first)
*/
  CURSOR hold_cur IS
  SELECT auth_resp_id
  FROM   igs_pe_pers_encumb
  WHERE  person_id  = p_person_id AND
         encumbrance_type = p_encumbrance_type AND
         start_dt = p_start_dt;

  hold_rec hold_cur%ROWTYPE;

  l_person_id    hz_parties.party_id%TYPE;
  l_person_number hz_parties.party_number%TYPE;
  l_person_name   hz_person_profiles.person_name%TYPE;
  l_message_name  fnd_new_messages.message_name%TYPE;

BEGIN

  -- Validate that the person who has logged in has a party account and
  -- is a STAFF. If he fails any of the above then is not authorized to release the hold.
  IF igs_pe_gen_001.g_hold_validation = 'Y' THEN

      --when processing for a batch of persons the validation should not happen for each record.
      --instead the validation should be done at the beginning. Hance the value of the variable
      --igs_pe_gen_001.g_hold_validation should be 'N' for batch processing.

      get_hold_auth(p_fnd_user_id,
                    l_person_id,
                    l_person_number,
                    l_person_name,
                    l_message_name);

      IF l_message_name IS NOT NULL THEN
           p_message_name := l_message_name;
           RETURN;
      END IF;

  END IF;

  --  Check that the data passed for the Hold is valid.
  OPEN   hold_cur;
  FETCH  hold_cur INTO hold_rec;
  IF hold_cur%NOTFOUND THEN
     CLOSE hold_cur;
     p_message_name := 'IGS_PE_HOLD_AUTH_REL';
     RETURN;
  END IF;
  CLOSE hold_cur;

  -- Check that the responsibility of the person logged in and that of the authoriser are same.
  -- If not then he is not allowed to release the hold.
  IF p_resp_id <> hold_rec.auth_resp_id THEN
     p_message_name := 'IGS_PE_HOLD_AUTH_REL';
     RETURN;
  END IF;

   p_message_name := NULL;


END validate_hold_resp;

PROCEDURE release_hold
            (p_resp_id     IN fnd_responsibility.responsibility_id%TYPE,
             p_fnd_user_id IN fnd_user.user_id%TYPE,
             p_person_id   IN hz_parties.party_id%TYPE,
             p_encumbrance_type IN igs_pe_pers_encumb.encumbrance_type%TYPE,
             p_start_dt    IN igs_pe_pers_encumb.start_dt%TYPE,
             p_expiry_dt   IN igs_pe_pers_encumb.expiry_dt%TYPE,
             p_override_resp IN VARCHAR2,
             p_comments IN igs_pe_pers_encumb.comments%TYPE,
             p_message_name OUT NOCOPY fnd_new_messages.message_name%TYPE
            ) IS
/*
  ||  Created By : pkpatel
  ||  Created On : 27-SEP-2002
  ||  Purpose : This Procedure will be the API that will be used to release the hold applied on the person.
  ||            For p_override_resp = 'Y' the validation of security as per authorizing responsibility will not happen
  ||                                  'N' validation will happen
  ||                                  'X' external holds, security check will not happen
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pkpatel         5-FEB-2003    Bug 2683186
  ||                                Passed proper value to the out parameter p_message_name
  ||  ssawhney        17-feb-2003   Bug 2758856 - external holds new validations
  ||  pkpatel         8-APR-2003    Bug 2804863
  ||                                Replaced the message IGS_PE_NOT_REL_HOLD with IGS_PE_CANT_REL_HOLD,IGS_PE_PERS_ENCUMB_NOTEXIST
*/

  CURSOR hold_cur IS
  SELECT ROWID,pen.*
  FROM   igs_pe_pers_encumb pen
  WHERE  pen.person_id  = p_person_id AND
         pen.encumbrance_type = p_encumbrance_type AND
     pen.start_dt = p_start_dt;

  hold_rec hold_cur%ROWTYPE;
  l_message_name  VARCHAR2(30);
BEGIN
   IF p_override_resp = 'X' THEN

   -- external holds design, do not validate the resp/auth id for external holds.
      IF p_person_id IS NULL OR p_encumbrance_type IS NULL OR p_start_dt IS NULL OR p_expiry_dt IS NULL THEN
           p_message_name := 'IGS_AD_INVALID_PARAM_COMB';
           FND_MESSAGE.SET_NAME('IGS','IGS_AD_INVALID_PARAM_COMB');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
   ELSE
      IF p_resp_id IS NULL OR p_fnd_user_id IS NULL OR p_person_id IS NULL OR p_encumbrance_type IS NULL OR p_start_dt IS NULL
         OR ( p_expiry_dt IS NULL AND p_comments IS NULL )  THEN
           p_message_name := 'IGS_AD_INVALID_PARAM_COMB';
           FND_MESSAGE.SET_NAME('IGS','IGS_AD_INVALID_PARAM_COMB');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
   END IF;


   OPEN hold_cur;
   FETCH hold_cur INTO hold_rec;
     IF hold_cur%NOTFOUND THEN
       CLOSE hold_cur;
           p_message_name := 'IGS_PE_PERS_ENCUMB_NOTEXIST';
           FND_MESSAGE.SET_NAME('IGS','IGS_PE_PERS_ENCUMB_NOTEXIST');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
     ELSE
     -- if cursor found, and external hold is NOT NULL then raise error
        IF ( p_override_resp <> 'X' AND hold_rec.external_reference IS NOT NULL) THEN
           -- called internally and trying to release an external hold.
           p_message_name := 'IGS_PE_CANT_REL_HOLD';
           CLOSE hold_cur;
           FND_MESSAGE.SET_NAME('IGS','IGS_PE_CANT_REL_HOLD');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
     END IF;
     IF hold_cur%ISOPEN THEN
        CLOSE hold_cur;
     END IF;

    IF  p_override_resp = 'N' THEN

                   igs_pe_gen_001.validate_hold_resp
                                    (p_resp_id     => p_resp_id,
                                     p_fnd_user_id => p_fnd_user_id,
                                     p_person_id   => p_person_id,
                                     p_encumbrance_type => p_encumbrance_type,
                                     p_start_dt     => p_start_dt,
                                     p_message_name => l_message_name);

           IF l_message_name IS NOT NULL THEN
                p_message_name := l_message_name;
                FND_MESSAGE.SET_NAME('IGS',l_message_name);
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
           END IF;
    END IF;


        igs_pe_pers_encumb_pkg.update_row(
                                x_rowid        => hold_rec.rowid   ,
                                x_person_id    => hold_rec.person_id,
                                x_encumbrance_type => hold_rec.encumbrance_type   ,
                                x_start_dt     => hold_rec.start_dt,
                                x_expiry_dt    => p_expiry_dt   ,
                                x_authorising_person_id => hold_rec.authorising_person_id ,
                                x_comments     => NVL(p_comments, hold_rec.comments) ,
                                x_spo_course_cd => hold_rec.spo_course_cd,
                                x_spo_sequence_number => hold_rec.spo_sequence_number,
                                x_auth_resp_id => hold_rec.auth_resp_id,
                                x_external_reference => hold_rec.external_reference,
                                x_mode         =>  'R' );

   -- There is no exception section for this. If any error occured then that will be handled in the the respective calling procedures
END release_hold;

FUNCTION  Get_Res_Status (
                p_person_id hz_parties.party_id%TYPE,
        p_residency_class igs_pe_res_dtls_all.residency_class_cd%TYPE,
        p_cal_type igs_ca_inst.cal_type%TYPE,
        p_sequence_number igs_ca_inst.sequence_number%TYPE
                  ) RETURN VARCHAR2 AS
/*
  ||  Created By : ssawhney
  ||  Created On : 8-nov-2004
  ||  Purpose : This function would get the res status of the person passed...for the term/or nearest term residency for term passed.

  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vskumar	      25-May-2006     Xbuild3 performance fix. Replace c_gap_res cursor query.
*/
CURSOR c_residency ( cp_person_id  hz_parties.party_id%TYPE,
             cp_residency_class igs_pe_res_dtls_all.residency_class_cd%TYPE,
             cp_cal_type igs_ca_inst.cal_type%TYPE,
             cp_sequence_number igs_ca_inst.sequence_number%TYPE
                  ) IS
SELECT residency_status_cd
FROM igs_pe_res_dtls_all
WHERE person_id      = cp_person_id AND
residency_class_cd   = cp_residency_class AND
cal_type             = cp_cal_type AND
sequence_number      = cp_sequence_number;
residency_rec c_residency%ROWTYPE;


CURSOR c_ca (    cp_cal_type igs_ca_inst.cal_type%TYPE,
         cp_sequence_number igs_ca_inst.sequence_number%TYPE
                        ) IS
SELECT cal.start_dt, cal.end_dt FROM igs_ca_inst cal
WHERE  cal.cal_type             = cp_cal_type AND
       cal.sequence_number      = cp_sequence_number;
ca_rec c_ca%ROWTYPE;


CURSOR c_gap_res  (  cp_person_id  hz_parties.party_id%TYPE,
             cp_residency_class igs_pe_res_dtls_all.residency_class_cd%TYPE,
             cp_start_dt DATE)   IS
SELECT res.residency_status_cd, ci.start_dt
FROM igs_pe_res_dtls_all res,IGS_CA_INST_ALL ci
WHERE  res.person_id  = cp_person_id AND
res.residency_class_cd = cp_residency_class AND
res.start_dt <= cp_start_dt AND
res.CAL_TYPE = CI.CAL_TYPE AND
res.SEQUENCE_NUMBER = CI.SEQUENCE_NUMBER
ORDER BY res.start_dt desc;


gap_rec c_gap_res%ROWTYPE;

l_prog_label  VARCHAR2(200);
l_label VARCHAR2(200);
l_debug_str VARCHAR2(2000);

BEGIN
  l_prog_label := 'igs.plsql.igs_pe_gen_001.get_res_status';

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
    l_label := 'igs.plsql.igs_pe_gen_001.get_res_status.begin';
    l_debug_str := 'start of proc get_res_status. Parameters p_person_id/p_residency_class/p_cal_type/p_sequence_number: '||
                   p_person_id||'/'||p_residency_class||'/'||p_cal_type||'/'||p_sequence_number;
    fnd_log.string_with_context(fnd_log.level_procedure, l_label,l_debug_str,NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;

--check all parameters passed.
IF ( p_person_id IS NULL OR p_residency_class IS NULL OR p_cal_type IS NULL OR p_sequence_number IS NULL ) THEN
   RETURN NULL;
END IF;

OPEN c_residency(p_person_id,p_residency_class ,p_cal_type , p_sequence_number);
FETCH c_residency INTO residency_rec;
IF c_residency%FOUND THEN
   CLOSE c_residency;
   RETURN residency_rec.residency_status_cd;  --return record if direct found for the term.
ELSE
   CLOSE c_residency;

   -- if direct term record not found, then check for gaps, get the most nearest term record
   -- for which residency is defined...
   OPEN c_ca(p_cal_type , p_sequence_number);
   FETCH c_ca INTO ca_rec;
   IF c_ca%FOUND THEN

		  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_pe_gen_001.get_res_status.Nearest Term1';
            l_debug_str := 'No Residency Status defined for the Term passed. Returning the Status defined for the Nearest Term.';
            fnd_log.string_with_context(fnd_log.level_procedure, l_label,l_debug_str,NULL,NULL,NULL,NULL,NULL,NULL);
          END IF;

      CLOSE c_ca;
      OPEN c_gap_res(p_person_id, p_residency_class, ca_rec.start_dt);
      FETCH c_gap_res INTO gap_rec;
      IF c_gap_res%FOUND THEN

          IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_pe_gen_001.get_res_status.Nearest Term2';
            l_debug_str := 'Residency Status: '||gap_rec.residency_status_cd;
            fnd_log.string_with_context(fnd_log.level_procedure, l_label,l_debug_str,NULL,NULL,NULL,NULL,NULL,NULL);
          END IF;

         CLOSE c_gap_res;
         RETURN gap_rec.residency_status_cd;
      ELSE
         -- no residency defined for the term or below..
         CLOSE c_gap_res;
         RETURN NULL;
      END IF; -- c_gap
   ELSE
      CLOSE c_ca;
      RETURN NULL;
   END IF; --c_ca
END IF; --c_res

END Get_Res_Status;

FUNCTION GET_SS_PRIVACY_LVL (
	P_person_id igs_pe_priv_level.person_id%TYPE )
RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : gmaheswa , Oracle India
  --Date created: 29-JUN-2005
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
    lvcDisplayLevel VARCHAR2(1) := 'Y';
    lnLevel     NUMBER(10);
    lvcLevelDes VARCHAR2(30);
    lvcPrivacyLevel VARCHAR2(80);
    lvcPersonPrivacyLevel   VARCHAR2(200) := '';
    ln_data_Group_Id NUMBER(15);

    CURSOR cur_lvl_data_group (lnpersonid number) IS
    SELECT  max(dg.lvl) Max_Level, lvl.DATA_GROUP_ID , dg.lvl_description
    FROM IGS_PE_PRIV_LEVEL lvl, IGS_PE_DATA_GROUPS DG
    WHERE lvl.person_id =  lnpersonid
    AND TRUNC(SYSDATE) BETWEEN lvl.start_date AND NVL(lvl.end_date,TRUNC(SYSDATE))
    and lvl.DATA_GROUP_ID = DG.DATA_GROUP_ID
    GROUP BY lvl.data_group_id ,dg.lvl_description
    ORDER BY 1 desc;

    lvlinfo cur_lvl_data_group%ROWTYPE;

   BEGIN

  OPEN cur_lvl_data_group(p_person_id);
  FETCH cur_lvl_data_group INTO lvlinfo;

  LOOP
  IF (cur_lvl_data_group%NOTFOUND) THEN
    lvcDisplayLevel := 'N';
  ELSE
    lnLevel := lvlInfo.Max_Level;
    ln_data_Group_Id := lvlInfo.Data_Group_Id;
    lvcLevelDes := lvlInfo.lvl_description;
  END IF;
  EXIT;
  END LOOP;
  CLOSE cur_lvl_data_group;

  IF lvcDisplayLevel = 'Y' THEN
    lvcPersonPrivacyLevel := lvcLevelDes || ', ' || TO_CHAR(lnLevel);
  END IF;

  RETURN lvcPersonPrivacyLevel;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN '';
  END GET_SS_PRIVACY_LVL;



FUNCTION Get_Hold_Count (p_person_id IN hz_parties.party_id%TYPE )
RETURN NUMBER AS
/*
  ||  Created By : ssawhney
  ||  Created On : 27-SEP-2002
  ||  Purpose : Function returns the count of no. of active holds on the passed person as of sysdate.
  ||  Who             When            What
*/

-- future dated holds are NOT active as of sysdate.
-- and holds are not valid as on the expiry date...so we need the exp_dt -1 logic.

  CURSOR  c_prsn_encumb_cnt
                (cp_person_id IN hz_parties.party_id%TYPE,
                 cp_sysdate DATE) IS
                SELECT  count(*)
                FROM    IGS_PE_PERS_ENCUMB
                WHERE   person_id = cp_person_id AND
                        (cp_sysdate BETWEEN start_dt AND (expiry_dt - 1) OR
                        (expiry_dt IS NULL AND start_dt <= cp_sysdate));

l_count  NUMBER  :=0;
l_sysdate       DATE := TRUNC(SYSDATE);

BEGIN

OPEN c_prsn_encumb_cnt(p_person_id, l_sysdate);
FETCH c_prsn_encumb_cnt INTO l_count;
CLOSE c_prsn_encumb_cnt;

RETURN l_count;

EXCEPTION
WHEN OTHERS THEN
  RETURN l_count;
END Get_Hold_Count ;


END igs_pe_gen_001;

/
