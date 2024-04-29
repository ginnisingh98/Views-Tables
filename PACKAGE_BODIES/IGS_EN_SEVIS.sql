--------------------------------------------------------
--  DDL for Package Body IGS_EN_SEVIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SEVIS" AS
/* $Header: IGSEN97B.pls 120.5 2006/06/19 11:54:53 amuthu noship $ */


   FUNCTION enrf_chk_sevis_auth_req ( p_person_id    NUMBER,
                                      p_cal_type VARCHAR2,
                                      p_ci_sequence_number NUMBER,
                                      p_elgb_step VARCHAR2
                                    ) RETURN BOOLEAN  IS
 /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || ckasu       13-JUN-2006 modified as a part of bug 5300119 inorder to
                 not consider SEVIS functionality for Exchange visitor Person Type.
                 by modifying the cursor c_sevis_person_type.
     ckasu       13-JUN-2006   modified as a prt of bug 5248531 inorder to not consider non -imgrant
                               student as SEVIS student even when his start date is greater than sysdate
  */

     -- Cursor to check whether active sevis person type exists for that person
     -- modified by ckasu as a part of bug 5300119
     CURSOR c_sevis_person_type IS
       SELECT 'X'
       FROM igs_pe_typ_instances_all pti,
            igs_pe_person_types pt
       WHERE pt.person_type_code = pti.person_type_code
       AND system_type IN ('NONIMG_STUDENT')
       AND person_id = p_person_id
       AND NVL(end_date, SYSDATE) >= SYSDATE;

    -- Cursor to check whether authorisation exists or not.
  CURSOR c_authorisation_exists (cp_person_id HZ_PARTIES.PARTY_ID%TYPE,
                                 cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                                 cp_ci_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
      SELECT 'X' FROM igs_en_svs_auth esa
                 WHERE person_id  = cp_person_id
                 AND NVL(esa.end_dt, SYSDATE) >= SYSDATE
                 AND exists (select 'x'
                             from igs_en_svs_auth_cal sac
                             where sac.sevis_auth_id = esa.sevis_auth_id
                             and cal_type = cp_cal_type
                             and ci_sequence_number = cp_ci_sequence_number);

    l_authorisation_exists  c_authorisation_exists%ROWTYPE;
    l_sevis_person_type  c_sevis_person_type%ROWTYPE;

   BEGIN

     -- Check whether sevis profile is set or not
     IF FND_PROFILE.VALUE('IGS_SV_ENABLED') = 'N' THEN
        RETURN FALSE;
     ELSE
        IF p_elgb_step NOT IN ('FATD_TYPE','FMIN_CRDT') THEN
           RETURN FALSE;
        ELSE

          -- Check whether the person has active sevis person type
          OPEN c_sevis_person_type;
          FETCH c_sevis_person_type INTO l_sevis_person_type;

          IF c_sevis_person_type%NOTFOUND THEN
             RETURN FALSE;
          ELSE

             -- Check whether active authorisation exists for that person
             OPEN c_authorisation_exists(p_person_id, p_cal_type, p_ci_sequence_number);
             FETCH c_authorisation_exists INTO l_authorisation_exists;

             IF c_authorisation_exists%FOUND THEN
                RETURN FALSE;
             ELSE
                RETURN TRUE;
             END IF;
             CLOSE c_authorisation_exists;

         END IF;
         CLOSE c_sevis_person_type;
       END IF;
    END IF;

  END enrf_chk_sevis_auth_req;


  PROCEDURE stud_ret_to_ft_load ( p_begin_cal_inst IN VARCHAR2,
                                  p_return_cal_inst IN VARCHAR2,
                                  p_log_creation_dt OUT NOCOPY DATE) is


    -- Cursor to get the authorized persons for the passed calander.
    CURSOR c_auth_person(l_cal_type igs_ca_inst_all.cal_type%TYPE, l_sequence_number igs_ca_inst_all.sequence_number%TYPE) IS
     SELECT  person_id, SEVIS_AUTHORIZATION_CODE
      FROM   igs_en_svs_auth auth,
             igs_en_svs_auth_cal sac
      WHERE auth.sevis_auth_id = sac.sevis_auth_id
          AND sac.cal_type = l_cal_type
      AND sac.ci_sequence_number = l_sequence_number;


   -- Cursor to get the course code for the authorised persons
   CURSOR c_sca (l_person_id hz_parties.party_id%TYPE) IS
     SELECT course_cd
     FROM   igs_en_stdnt_ps_att
     WHERE  person_id = l_person_id;

   -- Get person related details
   CURSOR c_person_name (l_person_id hz_parties.party_id%TYPE) IS
     SELECT party_number, person_first_name||' '||person_middle_name||' '||person_last_name full_name
     FROM hz_parties
     WHERE party_id = l_person_id;

   CURSOR c_cal_type(l_cal_type igs_ca_inst_all.cal_type%TYPE, l_sequence_number igs_ca_inst_all.sequence_number%TYPE) IS
     SELECT alternate_code, start_dt, end_dt
     FROM igs_ca_inst_all
     WHERE cal_type = l_cal_type
     AND sequence_number = l_sequence_number;

  CURSOR c_cal_cat(l_cal_type igs_ca_inst_all.cal_type%TYPE) IS
    SELECT s_cal_cat
    FROM igs_ca_type
    WHERE cal_type = l_cal_type;


   -- Get the sevis meaning for the passed sevis lookup code
   CURSOR c_sevis_meaning (l_lookup_code igs_lookups_view.lookup_code%TYPE) IS
     SELECT  meaning
     FROM igs_lookups_view
     WHERE lookup_type =  'IGS_EN_SEVIS_AUTH_CODES'
     AND lookup_code = l_lookup_code;

   -- Get the preferred alternate person id
  CURSOR c_api_person(l_person_id hz_parties.party_id%TYPE) IS
    SELECT api_person_id
    FROM igs_pe_person_id_type_v
    WHERE pe_person_id = l_person_id;

  -- Cursor to get the corresponding load calander for the passed teaching calander
  CURSOR cur_teach_to_load(p_cal_type IGS_CA_INST.cal_type%TYPE,
                           p_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
   SELECT load_cal_type,load_ci_sequence_number
   FROM   IGS_CA_TEACH_TO_LOAD_V
   WHERE  teach_cal_type = p_cal_type AND
          teach_ci_sequence_number = p_sequence_number AND
          load_end_dt >= TRUNC(SYSDATE)
   ORDER BY load_start_dt asc;


  -- Cursor to get the attendance type for the maximum enrollment load
  CURSOR c_att_type(l_cal_type igs_ca_inst_all.cal_type%TYPE) IS
    SELECT attendance_type FROM igs_en_atd_type_load
    WHERE  cal_type = l_cal_type
    AND    lower_enr_load_range = (SELECT MAX(lower_enr_load_range)
                                  FROM  igs_en_atd_type_load
                                  WHERE cal_type = l_cal_type);

   rec_teach_to_load cur_teach_to_load%ROWTYPE;
   v_begin_cal_type  igs_ca_inst_all.cal_type%TYPE;
   v_begin_ci_seq_number  igs_ca_inst_all.sequence_number%TYPE;
   v_begin_term_cal_type  igs_ca_inst_all.cal_type%TYPE;
   v_begin_term_ci_seq_number  igs_ca_inst_all.sequence_number%TYPE;
   v_return_cal_type   igs_ca_inst_all.cal_type%TYPE;
   v_return_ci_seq_number   igs_ca_inst_all.sequence_number%TYPE;
   l_attendance_type  igs_en_stdnt_ps_att.attendance_type%TYPE;
   l_credit_points  igs_en_su_attempt.override_achievable_cp%TYPE;
   l_fte  igs_en_su_attempt.override_achievable_cp%TYPE;
   l_person_name_row c_person_name%ROWTYPE;
   l_cal_type_row c_cal_type%ROWTYPE;
   l_sevis_meaning igs_lookups_view.meaning%TYPE;
   v_creation_dt DATE;
   l_api_person_id igs_pe_alt_pers_id_v.api_person_id%TYPE;
   l_description igs_ca_inst_all.description%TYPE;
   l_cal_cat igs_ca_type.s_cal_cat%TYPE;
   l_att_type igs_en_atd_type_load.attendance_type%TYPE;


   BEGIN

     v_begin_cal_type := RTRIM(SUBSTR(p_begin_cal_inst,101,10));
     v_begin_ci_seq_number := TO_NUMBER(RTRIM(SUBSTR(p_begin_cal_inst,112,6)));

     IF p_return_cal_inst is null then

        -- Get the current term calander if it is not passed as paramter.
        Igs_As_Ss_Doc_Request.get_as_current_term (
          v_return_cal_type        ,
          v_return_ci_seq_number ,
          l_description
        );

     ELSE

        v_return_cal_type := RTRIM(SUBSTR(p_return_cal_inst,101,10));
        v_return_ci_seq_number := TO_NUMBER(RTRIM(SUBSTR(p_return_cal_inst,112,6)));

        OPEN c_cal_cat(v_return_cal_type);
        FETCH c_cal_cat INTO l_cal_cat;
        CLOSE c_cal_cat;

        -- Get the load calander type and sequence number for the passed
        -- teaching calander.
        IF l_cal_cat = 'TEACHING' THEN

          OPEN cur_teach_to_load(v_return_cal_type, v_return_ci_seq_number);
          FETCH cur_teach_to_load INTO rec_teach_to_load;
          CLOSE cur_teach_to_load;

          v_return_cal_type := rec_teach_to_load.load_cal_type;
          v_return_ci_seq_number := rec_teach_to_load.load_ci_sequence_number;

       END IF;

     END IF;

     IGS_GE_GEN_003.GENP_INS_LOG (
        'EN-RET-FT',
         p_begin_cal_inst||','||p_return_cal_inst||','||p_log_creation_dt,
         v_creation_dt
         );

      p_log_creation_dt := v_creation_dt;

      -- Check whether the passed begin calander is teaching or not.
      -- If it is teaching then get the corresponding load calander
      -- and calculate the attendance type.

      OPEN c_cal_cat(v_begin_cal_type);
      FETCH c_cal_cat INTO l_cal_cat;
      CLOSE c_cal_cat;

      IF l_cal_cat = 'TEACHING' THEN

          OPEN cur_teach_to_load(v_begin_cal_type, v_begin_ci_seq_number);
          FETCH cur_teach_to_load INTO rec_teach_to_load;
          CLOSE cur_teach_to_load;

          v_begin_term_cal_type := rec_teach_to_load.load_cal_type;
          v_begin_term_ci_seq_number := rec_teach_to_load.load_ci_sequence_number;

       ELSE

          v_begin_term_cal_type := v_begin_cal_type;
          v_begin_term_ci_seq_number := v_begin_ci_seq_number;

       END IF;


      -- Loop thru all the authorised persons
      FOR i IN c_auth_person(v_begin_cal_type, v_begin_ci_seq_number)  LOOP

         -- Calulate the attendance type for the passed calander.
         igs_en_prc_load.enrp_get_inst_latt(
                 i.person_id ,
                 v_begin_term_cal_type ,
                 v_begin_term_ci_seq_number,
                 l_attendance_type,
                 l_credit_points,
                 l_fte
                 );

        -- If the attendance type is not equal to Full Time then get the attendance type
        -- of the return cal type and if it is equal to Full time then log the details
        -- of that person in the log table, which will be displayed in the report.

        OPEN c_att_type(v_begin_term_cal_type);
        FETCH c_att_type INTO l_att_type;
        CLOSE c_att_type;

        IF l_attendance_type <> l_att_type THEN

           igs_en_prc_load.enrp_get_inst_latt(
                 i.person_id ,
                 v_return_cal_type ,
                 v_return_ci_seq_number,
                 l_attendance_type,
                 l_credit_points,
                 l_fte
                 );


           OPEN c_att_type(v_return_cal_type);
           FETCH c_att_type INTO l_att_type;
           CLOSE c_att_type;

          -- Check if the derived attendance type is equal to Full Time or not.
          IF l_attendance_type = l_att_type THEN

            OPEN c_person_name(i.person_id);
            FETCH c_person_name INTO l_person_name_row;
            CLOSE c_person_name;

            OPEN  c_cal_type(v_return_cal_type, v_return_ci_seq_number);
            FETCH c_cal_type INTO l_cal_type_row;
            CLOSE c_cal_type;

            -- To get the sevis meaning
            OPEN c_sevis_meaning(i.SEVIS_AUTHORIZATION_CODE);
            FETCH c_sevis_meaning INTO l_sevis_meaning;
            CLOSE c_sevis_meaning;

            -- Get the alternate person id
            OPEN c_api_person(i.person_id);
            FETCH c_api_person INTO l_api_person_id;
            CLOSE c_api_person;


            -- Loop thru all the Student Program attempt
            FOR sca IN c_sca(i.person_id) LOOP

              -- Log all the parametes and other details in log entry table.
              IGS_GE_GEN_003.GENP_INS_LOG_ENTRY( 'EN-RET-FT',
                                   p_log_creation_dt ,
                                   to_char(i.person_id) || ',' ||
                                   UPPER(l_person_name_row.party_number)  || ',' ||
                                   sca.course_cd || ',' ||
                                   UPPER(l_person_name_row.full_name)|| ',' ||
                                   l_api_person_id || ',' ||
                                   UPPER(l_sevis_meaning) || ',' ||
                                   v_return_cal_type  || ',' ||
                                   to_char(v_return_ci_seq_number) || ',' ||
                                   l_cal_type_row.alternate_code || ',' ||
                                   to_char(l_cal_type_row.start_dt)||','||
                                   to_char(l_cal_type_row.end_dt),
                                   '',
                                   NULL);
            END LOOP;

          END IF;

        END IF;

      END LOOP;

   END stud_ret_to_ft_load;

FUNCTION enrf_get_sevis_auth_details(
        p_person_id     IN         NUMBER,
        p_auth_code     OUT NOCOPY VARCHAR2,
        p_auth_start_dt OUT NOCOPY DATE,
        p_auth_end_dt   OUT NOCOPY DATE,
        p_comments      OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
/*
||  Created By : nbehera
||  Created On : 28NOV2002
||  Purpose    : Obsolete
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/

BEGIN
    --Initializing NULL to all the OUT parameters
    p_auth_code     := NULL;
    p_auth_start_dt := NULL;
    p_auth_end_dt   := NULL;
    p_comments      := NULL;

--------------------------------------------------------------
--function is obsolete
--------------------------------------------------------------
    RETURN FALSE;
--------------------------------------------------------------
END enrf_get_sevis_auth_details;

FUNCTION enrf_get_ret_ft_note_details(
        p_person_id     IN  NUMBER,
        p_note_text     OUT NOCOPY VARCHAR2,
        p_note_start_dt OUT NOCOPY DATE,
        p_note_end_dt   OUT NOCOPY DATE,
        p_note_type     OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
/*
||  Created By : nbehera
||  Created On : 03DEC2002
||  Purpose    : Person ID would be passed to this API. Based on the Person ID, the API
||               must retrieve the Return to Full Time Load Notes and the related data from
||               the Person Notes table and pass it back to the calling procedure/function.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)

*/

--Cursor to get whether the person is of International Student Type
CURSOR c_int_per_type IS
SELECT 'X'
FROM   igs_pe_typ_instances_all pti,
       igs_pe_person_types pt
WHERE  pt.person_type_code = pti.person_type_code
AND    pt.system_type = 'NONIMG_STUDENT'
AND    pti.person_id = p_person_id
AND    NVL(pti.end_date, SYSDATE) >= SYSDATE;
l_int_per_type     VARCHAR2(1);

--Cursor to retrieve the Active Note details for the person,
--Where Person note is of type Return to Full Time Load.
--Start date of the person note should be more or same as the Term start date,
--And if End date exists for the person note then it should be less or same as
--the End date of the term.
CURSOR c_ret_to_ft_note_dtls ( p_cal_type igs_ca_inst_all.cal_type%TYPE,
                               p_seq_num  igs_ca_inst_all.sequence_number%TYPE ) IS
SELECT gn.note_text,
       pn.start_date,
       pn.end_date,
       pn.pe_note_type
FROM   igs_pe_pers_note pn,
       igs_ge_note gn,
       igs_ca_inst ci
WHERE  ci.cal_type = p_cal_type
AND    ci.sequence_number = p_seq_num
AND    pn.person_id = p_person_id
AND    pn.pe_note_type = 'RET_FULL_LOAD'
AND    pn.reference_number = gn.reference_number
AND    ci.start_dt <= pn.start_date
AND    NVL (pn.end_date, ci.end_dt) <= ci.end_dt
ORDER BY pn.start_date DESC;
l_ret_to_ft_note_dtls  c_ret_to_ft_note_dtls%ROWTYPE;

--Cursor to get the Full Time Attendance Type
--This is the way to get the Attendance Type for the Maximum lower enrollment load range
--in the provided load calendar, Which will be treated as the Full Time Attendance Type
CURSOR c_att_type ( p_cal_type igs_ca_inst_all.cal_type%TYPE ) IS
SELECT attendance_type
FROM   igs_en_atd_type_load
WHERE  cal_type = p_cal_type
AND    lower_enr_load_range = ( SELECT MAX(lower_enr_load_range)
                                FROM   igs_en_atd_type_load
                                WHERE  cal_type = p_cal_type );
l_attendance_type  igs_en_atd_type_load.attendance_type%TYPE;

l_cal_type         igs_ca_inst_all.cal_type%TYPE;
l_sequence_number  igs_ca_inst_all.sequence_number%TYPE;
l_description      igs_ca_inst_all.description%TYPE;
l_att_type         igs_en_atd_type_load.attendance_type%TYPE;
l_credit_points    NUMBER;
l_fte              NUMBER;


BEGIN
    --Initializing NULL to all the OUT parameters
    p_note_text     := NULL;
    p_note_start_dt := NULL;
    p_note_end_dt   := NULL;
    p_note_type     := NULL;

    --If the IN parameter p_person_id is NULL then return FALSE
    IF p_person_id IS NULL THEN
         RETURN FALSE;
    END IF;

    --Check to see if there is an active International Person Type Associated with the Person ID
    OPEN c_int_per_type;
    FETCH c_int_per_type INTO l_int_per_type;
    IF c_int_per_type%NOTFOUND THEN
         --If not any International Person Type Associated with the Person ID then return FALSE
         CLOSE c_int_per_type;
         RETURN FALSE;
    END IF;
    CLOSE c_int_per_type;

    --Derive the Current Term Calendar using the assessment procedure
    igs_as_ss_doc_request.get_as_current_term(
         p_cal_type        => l_cal_type,
         p_sequence_number => l_sequence_number,
         p_description     => l_description );
    IF l_cal_type IS NULL AND l_sequence_number IS NULL THEN
         --If the above procedure returns Cal Type and Sequence Number as NULL then return false
         RETURN FALSE;
    END IF;

    --Call to the below procedure, to get the attendance type for the Person in the Current Term Calendar
    igs_en_prc_load.enrp_get_inst_latt (
         p_person_id       => p_person_id,
         p_load_cal_type   => l_cal_type,
         p_load_seq_number => l_sequence_number,
         p_attendance      => l_att_type,
         p_credit_points   => l_credit_points,
         p_fte             => l_fte );

    --Get the attendance type from the cursor which will be treated as Full Time Attendance Type
    OPEN  c_att_type ( l_cal_type );
    FETCH c_att_type INTO l_attendance_type;

    --If the above cursor doesn't retrieve any record then return FALSE
    IF c_att_type%NOTFOUND THEN
        CLOSE c_att_type;
        RETURN FALSE;
    END IF;
    CLOSE c_att_type;

    --If the Attendance Type for the person is not same as the FT Attendance Type for the Load Calendar
    --Then Return FALSE. Else Get the Note details from the cursor. If more than one notes exist  then
    --Return the note details of the latest start date.
    IF l_attendance_type <> l_att_type THEN
        RETURN FALSE;
    ELSE
        OPEN c_ret_to_ft_note_dtls ( l_cal_type, l_sequence_number );
        FETCH c_ret_to_ft_note_dtls INTO l_ret_to_ft_note_dtls;

	--If note details not found for the person then return FALSE
        IF c_ret_to_ft_note_dtls%NOTFOUND THEN
             CLOSE c_ret_to_ft_note_dtls;
             RETURN FALSE;
        END IF;
        CLOSE c_ret_to_ft_note_dtls;

    END IF;

    --Return the Note Details for the person
    p_note_text     := l_ret_to_ft_note_dtls.note_text;
    p_note_start_dt := l_ret_to_ft_note_dtls.start_date;
    p_note_end_dt   := l_ret_to_ft_note_dtls.end_date;
    p_note_type     := l_ret_to_ft_note_dtls.pe_note_type;
    RETURN TRUE;

END enrf_get_ret_ft_note_details;


FUNCTION get_visa_type(p_person_id IN NUMBER,
                       p_no_of_months OUT NOCOPY NUMBER ) RETURN VARCHAR2 AS
  l_person_id NUMBER;

  CURSOR c_nonimig_visa_type  IS
	  SELECT visa_type
	  FROM igs_pe_nonimg_form
	  WHERE person_id = p_person_id
	  AND form_status = 'A';

  CURSOR c_visa_type IS
	    SELECT visa_type
	    FROM   igs_pe_visa_v
	    WHERE  person_id = p_person_id
	    AND visa_issue_date <= sysdate
	    AND sysdate <= visa_expiry_date ;

l_visa_type  igs_pe_visa_v.visa_type%TYPE;

BEGIN

    l_visa_type := NULL;
    OPEN c_nonimig_visa_type;
    FETCH c_nonimig_visa_type INTO l_visa_type;
    IF c_nonimig_visa_type%NOTFOUND THEN

      FOR l_visa_type_rec in c_visa_type LOOP

        IF l_visa_type_rec.visa_type = 'F-1' THEN
          l_visa_type :=  l_visa_type_rec.visa_type;
          EXIT;
        ELSIF l_visa_type_rec .visa_type = 'M-1' THEN
          l_visa_type :=  l_visa_type_rec.visa_type;
        END IF;-- end of IF ELSEIF l_visa_type_rec .visa_type = 'F-1'

      END LOOP;-- end of For l_visa_type_rec in c_visa_type Loop

    END IF; -- end of c_nonimig_visa_type%NOTFOUND THEN
    CLOSE c_nonimig_visa_type;

    IF l_visa_type  = 'M-1' THEN
        p_no_of_months := 5;
    ELSIF l_visa_type  = 'F-1' THEN
        p_no_of_months := 12;
    END IF;
    RETURN l_visa_type;

END get_visa_type;



FUNCTION is_auth_rec_duration_exceeds(
                                     p_person_id  IN NUMBER,
                                      p_start_date IN  DATE,
                                      p_end_date IN  DATE,
                                      p_no_of_months OUT NOCOPY NUMBER)  RETURN BOOLEAN AS

CURSOR  c_get_auth_rec_dur(cp_no_of_months NUMBER) IS
        SELECT add_months(TRUNC(p_start_date ),cp_no_of_months) final_dt
        FROM DUAL;
c_get_auth_rec_dur_rec  c_get_auth_rec_dur%ROWTYPE;
l_visa_type IGS_PE_VISA_V.VISA_TYPE%TYPE;
l_status BOOLEAN;

BEGIN

 l_status := FALSE;
 l_visa_type := get_visa_type(p_person_id, p_no_of_months);

 OPEN c_get_auth_rec_dur(p_no_of_months);
 FETCH c_get_auth_rec_dur INTO c_get_auth_rec_dur_rec;

  IF TRUNC(p_end_date)  >  c_get_auth_rec_dur_rec.final_dt THEN
    l_status := TRUE;

  END IF;

  RETURN l_status;

 CLOSE c_get_auth_rec_dur;

END is_auth_rec_duration_exceeds;

PROCEDURE insert_auth_cal_rec(
      p_sevis_auth_id                     IN NUMBER,
      p_cal_type                          IN VARCHAR2,
      p_ci_sequence_number                IN NUMBER) AS

   CURSOR c_auth_cal_exists IS
   SELECT 'X'
   FROM IGS_EN_SVS_AUTH_CAL
   WHERE SEVIS_AUTH_ID = p_sevis_auth_id
   AND cal_type = p_cal_type
   AND ci_sequence_number = p_ci_sequence_number;

   l_dummy VARCHAR2(1);
   lv_rowid VARCHAR2(25);

BEGIN

  OPEN c_auth_cal_exists;
  FETCH c_auth_cal_exists INTO l_dummy;

  IF c_auth_cal_exists%FOUND THEN
    CLOSE c_auth_cal_exists;
    RETURN;

  ELSE
    CLOSE c_auth_cal_exists;
    igs_en_svs_auth_cal_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => lv_rowid,
      x_sevis_auth_id                     => p_sevis_auth_id,
      x_cal_type                          => p_cal_type,
      x_ci_sequence_number                => p_ci_sequence_number);

  END If;


END insert_auth_cal_rec;

PROCEDURE insert_authorization_rec(
      p_sevis_authorization_code            IN VARCHAR2,
      p_start_dt                          IN DATE,
      p_end_dt                            IN DATE,
      p_comments                          IN VARCHAR2,
      p_sevis_auth_id                     IN OUT NOCOPY NUMBER,
      p_sevis_authorization_no            IN OUT NOCOPY NUMBER,
      p_person_id                         IN NUMBER,
      p_cancel_flag                        IN VARCHAR2) AS


    lv_rowid VARCHAR2(25) ;
    l_sevis_authorization_no  igs_en_svs_auth.SEVIS_AUTHORIZATION_NO%TYPE;

   CURSOR c_authorization_exists IS
   SELECT sevis_auth_id
   FROM igs_en_svs_auth
   WHERE person_id = p_person_id
   AND sevis_authorization_code = p_sevis_authorization_code
   AND start_dt = p_start_dt
   AND NVL(cancel_flag,'N') = 'N';


BEGIN

  OPEN c_authorization_exists;
  FETCH c_authorization_exists INTO p_sevis_auth_id;

  IF c_authorization_exists%FOUND THEN

    CLOSE c_authorization_exists;
    RETURN;

  ELSE

    CLOSE c_authorization_exists;

    igs_en_svs_auth_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => lv_rowid,
      x_sevis_authorization_code          => p_sevis_authorization_code,
      x_start_dt                          => p_start_dt,
      x_end_dt                            => p_end_dt,
      x_comments                          => p_comments,
      x_sevis_auth_id                     => p_sevis_auth_id,
      x_sevis_authorization_no            => l_sevis_authorization_no,
      x_person_id                         => p_person_id,
      x_cancel_flag                       => p_cancel_flag);

  END IF;

END insert_authorization_rec;


PROCEDURE create_auth_cal_row (
      p_sevis_authorization_code            IN VARCHAR2,
      p_start_dt                          IN DATE,
      p_end_dt                            IN DATE,
      p_comments                          IN VARCHAR2,
      p_sevis_auth_id                     IN OUT NOCOPY NUMBER,
      p_sevis_authorization_no            IN OUT NOCOPY NUMBER,
      p_person_id                         IN NUMBER,
      p_cal_type                          IN VARCHAR2,
      p_ci_sequence_number                IN NUMBER,
      p_cancel_flag                        IN VARCHAR2) AS

BEGIN

  IF p_person_id IS NULL OR
     p_sevis_authorization_code IS NULL OR
     p_cal_type IS NULL OR
     p_ci_sequence_number IS NULL OR
     p_start_dt IS NULL OR
     p_end_dt IS NULL THEN

    Fnd_Message.Set_Name('IGS' , 'IGS_GE_INSUFFICIENT_PARAMETER');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;

  END IF;



  IF p_sevis_auth_id IS NULL THEN
   -- authorization does not exist create it first.

   insert_authorization_rec(
      p_sevis_authorization_code ,
      p_start_dt               ,
      p_end_dt                 ,
      p_comments               ,
      p_sevis_auth_id          ,
      p_sevis_authorization_no ,
      p_person_id              ,
      p_cancel_flag);

   insert_auth_cal_rec(p_sevis_auth_id, p_cal_type, p_ci_sequence_number);
  ELSE
   -- authorization exists create the calendar record.

   insert_auth_cal_rec(p_sevis_auth_id, p_cal_type, p_ci_sequence_number);

  END IF;

END create_auth_cal_row;

PROCEDURE enrp_sevis_auth_dflt_dt(p_person_id          IN NUMBER,
                                  p_cal_type           IN VARCHAR2,
                                  p_ci_sequence_number IN NUMBER,
                                  p_dflt_auth_start_dt OUT NOCOPY DATE,
                                  p_dflt_auth_end_dt   OUT NOCOPY DATE) IS
  CURSOR c_cal_dates IS
  SELECT start_dt, end_dt
  FROM IGS_CA_INST
  WHERE cal_type = p_cal_type
  AND sequence_number = p_ci_sequence_number;


    l_no_of_months NUMBER;
    l_visa_type IGS_PE_VISA_V.VISA_TYPE%TYPE;
    l_ci_start_Dt DATE;
    l_ci_end_dt DATE;
    l_duration_dt DATE;
    l_temp_date DATE;
    l_prgm_start_date  IGS_EN_SVS_AUTH.START_DT%TYPE;
    l_prgm_end_date    IGS_EN_SVS_AUTH.END_DT%TYPE;

    l_interval INTERVAL YEAR TO MONTH;

BEGIN

   OPEN c_cal_dates;
   FETCH c_cal_Dates INTO l_ci_start_dt, l_ci_end_dt;
   CLOSE c_cal_dates;

   l_visa_type := get_visa_type(p_person_id, l_no_of_months);
   l_interval := NUMTOYMINTERVAL(l_no_of_months,'month');

   igs_sv_util.get_program_dates(p_person_id,l_prgm_end_date,l_prgm_start_date);


   IF l_prgm_start_date IS NOT NULL AND  l_prgm_end_date IS NOT NULL
     AND trunc(l_prgm_start_date) >= trunc(sysdate) THEN

     IF trunc(l_prgm_end_date) < trunc(l_ci_end_dt) OR
        trunc(l_prgm_start_date) >= trunc(l_ci_end_dt) THEN
       p_dflt_auth_start_dt := NULL ;
       p_dflt_auth_end_dt := NULL;
       RETURN;
     END IF;

     IF months_between(trunc(l_ci_end_dt),trunc(l_prgm_start_date)) <= l_no_of_months THEN
       p_dflt_auth_start_dt := trunc(l_prgm_start_date) ;
       p_dflt_auth_end_dt := trunc(l_ci_end_dt);
     ELSE
       l_temp_date := l_ci_end_dt - l_interval;
       IF trunc(l_temp_date) >= trunc(l_prgm_start_date) THEN
         p_dflt_auth_start_dt := l_temp_date ;
         p_dflt_auth_end_dt := l_ci_end_dt;
       END IF;
     END IF;

   ELSE

     IF (l_prgm_end_date IS NOT NULL  AND trunc(l_prgm_end_date) < trunc(l_ci_end_dt))
        OR (trunc(sysdate) >= trunc(l_ci_end_dt) )THEN
         p_dflt_auth_start_dt := NULL ;
         p_dflt_auth_end_dt := NULL;
         RETURN;
     END IF;

     IF months_between(trunc(l_ci_end_dt),trunc(sysdate)) <= l_no_of_months THEN
       p_dflt_auth_start_dt := trunc(sysdate) ;
       p_dflt_auth_end_dt := trunc(l_ci_end_dt);
     ELSE
       l_temp_date := l_ci_end_dt - l_interval;
       IF trunc(l_temp_date) >= trunc(sysdate) THEN
         p_dflt_auth_start_dt := trunc(l_temp_date);
         p_dflt_auth_end_dt := trunc(l_ci_end_dt);
       ELSE
         p_dflt_auth_start_dt := NULL ;
         p_dflt_auth_end_dt := NULL;
         RETURN;
       END IF;
     END IF;

   END IF;

   IF p_dflt_auth_start_dt IS NOT NULL and p_dflt_auth_end_dt IS NOT NULL THEN
     IF is_auth_rec_duration_exceeds(
                                      p_person_id,
                                      p_dflt_auth_start_dt,
                                      p_dflt_auth_end_dt,
                                      l_no_of_months) THEN

         p_dflt_auth_start_dt := NULL ;
         p_dflt_auth_end_dt := NULL;
         RETURN;
     END IF;
   END IF;

END enrp_sevis_auth_dflt_dt;



FUNCTION is_auth_records_overlap(p_person_id IN NUMBER) RETURN BOOLEAN IS

        CURSOR c_chk_for_auth_rec_overlap (cp_person_id HZ_PARTIES.PARTY_ID%TYPE) IS
                        SELECT 'x'
                        FROM igs_en_svs_auth F,
                             igs_en_svs_auth S
                        WHERE f.person_id =cp_person_id
                        AND   s.person_id =cp_person_id
                        AND   f.ROWID    <> s.ROWID
                        AND   f.end_dt BETWEEN s.start_dt AND s.end_dt;

       l_val VARCHAR2(1);

BEGIN

  OPEN c_chk_for_auth_rec_overlap(p_person_id);
  FETCH c_chk_for_auth_rec_overlap INTO l_val;
    IF c_chk_for_auth_rec_overlap%FOUND THEN
       CLOSE c_chk_for_auth_rec_overlap;
       RETURN TRUE;
    END IF;
  CLOSE c_chk_for_auth_rec_overlap;
  RETURN FALSE;
END is_auth_records_overlap;

END igs_en_sevis;

/
