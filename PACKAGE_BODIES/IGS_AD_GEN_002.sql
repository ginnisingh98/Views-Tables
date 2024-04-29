--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_002" AS
/* $Header: IGSAD02B.pls 120.11 2006/01/16 20:23:16 rghosh ship $ */
 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --nshee       20-Mar-02       Bug# 2128153
  --                            Description: After rollover Admission Calendar Code not getting
  --                            displayed in the Admission Calendar LOV of deferement Tab in Admission Offer Response
  --                            Change: Changed the cursor c_cir. Selected additional column ci.start_dt to enable
  --                            order by start_dt clause.
  --                            Reason: This cursor may return more than one row because when we rollover
  --                            Admission Calendar , it is not ensured that the alternate code will be unique
  --                            for the particular Calendar Type and the sequence   number. Rather, the calendar type and
  --                            sequence number remains the same and also the alternate code.However, the start date of
  --                            the last rollover should be taken into consideration and hence the
  --                            results should be sorted by the descending order of start date. This will ensure
  --                            that the first record is picked up which is the latest rollover.
  --prchandr    08-Jan-01       Enh Bug No: 2174101, As the Part of Change in IGSEN18B
  --                            Passing NULL as parameters  to ENRP_CLC_SUA_EFTSU
  --                            ENRP_CLC_EFTSU_TOTAL for Key course cd and version number
  --knag        04-Oct-02       Bug 2602096 : Created the function Admp_Get_Appl_ID to return Application ID
  --                                          and the function Admp_Get_Fee_Status to return Appl Fee Status
  --hreddych    22-oct-2002     Bug:2602077 : SF Integration  modified the function Admp_Get_Aa_Aas
  --                                          to include the new offer deferment status of confirm
  -- pradhakr   15-Jan-2003     Added one more paramter no_assessment_ind to the
  --                            call enrp_get_load_apply as an impact, following
  --                            the modification of the package Igs_En_Prc_Load.
  --                            Changes wrt ENCR026. Bug# 2743459
  -- anwest     20-Jul-2004     IGS.M ADTD003
  --                            Added the res_pending_fee_status function to enable
  --                            finer derivation of the PENDING fee status by
  --                            the Submitted Applications Reusable Component
  -- anwest		03-Nov-05		IGS.M ADTD002:Created function Is_EntQualCode_Allowed
  -------------------------------------------------------------------------------------------
Procedure Admp_Ext_Tac_Arts(
  p_input_file IN VARCHAR2 ,
  p_output_file IN VARCHAR2 ,
  p_directory IN VARCHAR2 )
IS
BEGIN -- admp_ext_tac_arts
  -- This program reads a decrypted request file from the TAC (Tertiary
  -- Admissions Centre) ARTS (Automated Results Transfer System). It
  -- then validates and interprets each student header record and
  -- endeavours to match the input file record to a IGS_PE_PERSON record on
  -- the database. If successful it writes academic details for the
  -- matching people to the result file, which will then be encrypted
  -- and retured to the TAC.
DECLARE
  fp_input      UTL_FILE.FILE_TYPE;
  fp_output     UTL_FILE.FILE_TYPE;
  cst_enrolled  CONSTANT  IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE :=
            'ENROLLED';
  cst_sus_srvc  CONSTANT  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE :=
            'SUS_SRVC';
  cst_rvk_srvc  CONSTANT  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE :=
            'RVK_SRVC';
  v_record_type     VARCHAR2(1);
  v_input_string      VARCHAR2(158);
  v_previous_name_records_cnt NUMBER(2);
  v_number_of_matches   NUMBER(4);
  TYPE r_record_type_h IS RECORD (
    record_type   VARCHAR2(1),
    institution_code  NUMBER(4),
    return_ip_addr    VARCHAR2(40),
    request_dt    VARCHAR2(6),
    request_time    VARCHAR2(6),
    request_cd    VARCHAR2(10),
    matching_level    VARCHAR2(10),
    applicant_id    VARCHAR2(10),
    campus_cd   NUMBER(4),
    student_id    VARCHAR2(10),
    family_name   VARCHAR2(20),
    first_name    VARCHAR2(15),
    second_name   VARCHAR2(15),
    sex     VARCHAR2(1),
    dob     VARCHAR2(6));
  r_header_rec    r_record_type_h;
  -- Table of previous names
  TYPE r_record_type_p IS RECORD (
    record_type   VARCHAR2(1),
    family_name   VARCHAR2(20),
    first_name    VARCHAR2(15),
    second_name   VARCHAR2(15));
  r_previous_name_rec   r_record_type_p;
  TYPE t_previous_name_type IS TABLE OF r_previous_name_rec%TYPE
    INDEX BY BINARY_INTEGER;
  t_previous_name   t_previous_name_type;
  t_previous_name_clear t_previous_name_type;
  -- Table of Matched ID's
  TYPE r_matched_id_rec_type IS RECORD (
    person_id   IGS_PE_PERSON.person_id%TYPE,
    basis_of_match    VARCHAR2(3),
    reason_code   VARCHAR2(1));
  r_matched_id_rec  r_matched_id_rec_type;
  TYPE t_matched_id_type IS TABLE OF r_matched_id_rec%TYPE
    INDEX BY BINARY_INTEGER;
  t_matched_ids   t_matched_id_type;
  t_matched_ids_clear t_matched_id_type;
---------------
---------------
  FUNCTION admpl_chk_non_num (
    p_input_string    IN  VARCHAR2)
  RETURN BOOLEAN
  IS
    v_string_length     NUMBER(3);
    v_character     VARCHAR2(1);
  BEGIN -- admpl_chk_non_num
    -- Check if the input string contains any non-numeric characters
    v_string_length := LENGTH(p_input_string);
    IF (v_string_length > 0) THEN
      FOR i IN 1..v_string_length LOOP
        v_character := SUBSTR(p_input_string, i, 1);
        IF (v_character NOT IN ('0', '1', '2', '3',
              '4', '5', '6', '7',
              '8', '9')) THEN
          RETURN TRUE;
        END IF;
      END LOOP;
    END IF;
    RETURN FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_chk_non_num');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END admpl_chk_non_num;
---------------
---------------
  FUNCTION admpl_strip_non_alpha (
    p_input_string    IN  VARCHAR2)
  RETURN VARCHAR2
  IS
    v_string_length   NUMBER(3);
    v_output_string   VARCHAR2(255);
    v_character   VARCHAR2(1);
  BEGIN -- admpl_strip_non_alpha
    -- Remove non-alpha characters from input string
    v_string_length := LENGTH(p_input_string);
    IF (v_string_length > 0) THEN
      FOR i IN 1..v_string_length LOOP
        v_character := SUBSTR(p_input_string, i, 1);
        IF (UPPER(v_character) IN ('A', 'B', 'C', 'D', 'E',
              'F', 'G', 'H', 'I', 'J', 'K',
              'L', 'M', 'N', 'O', 'P', 'Q',
              'R', 'S', 'T', 'U', 'V', 'W',
              'X', 'Y', 'Z')) THEN
          v_output_string := v_output_string || v_character;
        END IF;
      END LOOP;
    END IF;
    RETURN v_output_string;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_strip_non_alpha');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_strip_non_alpha;
---------------
---------------
  FUNCTION admpl_strip_spaces (
    p_input_string    IN  VARCHAR2)
  RETURN VARCHAR2
  IS
    v_string_length   NUMBER(3);
    v_output_string   VARCHAR2(255);
    v_character   VARCHAR2(1);
  BEGIN -- admpl_strip_spaces
    -- Remove spaces from input string
    v_string_length := LENGTH(p_input_string);
    IF (v_string_length > 0) THEN
      FOR i IN 1..v_string_length LOOP
        v_character := SUBSTR(p_input_string, i, 1);
        IF (v_character <> ' ') THEN
          v_output_string := v_output_string || v_character;
        END IF;
      END LOOP;
    END IF;
    RETURN v_output_string;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_strip_spaces');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_strip_spaces;
---------------
---------------
  PROCEDURE admpl_store_matched_table (
    p_target_person_id  IN  IGS_PE_PERSON.person_id%TYPE,
    p_basis_of_match  IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    cst_result_blk  CONSTANT  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE :=
              'RESULT_BLK';
    v_number_of_matches   NUMBER(4);
    v_person_id     IGS_PE_PERSENC_EFFCT.person_id%TYPE;
    v_reason_code     VARCHAR2(1);
    CURSOR c_pee IS
      SELECT  pee.person_id
      FROM  IGS_PE_PERSENC_EFFCT  pee
      WHERE pee.person_id = p_target_person_id AND
        pee.s_encmb_effect_type IN (
              cst_result_blk,
              cst_sus_srvc,
              cst_rvk_srvc) AND
        SYSDATE BETWEEN pee.pee_start_dt AND
            DECODE (pee.expiry_dt,
              NULL,
              IGS_GE_DATE.IGSDATE('9999/12/31'),--TO_DATE('31/12/9999', 'DD/MM/YYYY'),
              pee.expiry_dt);
    CURSOR c_sua IS
      SELECT  sua.person_id
      FROM  IGS_EN_SU_ATTEMPT sua
      WHERE sua.person_id = p_target_person_id AND
        sua.unit_attempt_status = cst_enrolled;
  BEGIN -- admpl_store_matched_table (10)
    -- This will add the matched ID number along with the basis
    -- of match and reason code to the PLSQL table of matched ID's.
    -- The matching criteria number that the match was successful
    -- against should be passed as a parameter to this procedure
    -- along with the target person ID.
    -- We don't want to store the same person ID more than once.
    FOR i IN 1..p_number_of_matches LOOP
      r_matched_id_rec := t_matched_ids(i);
      IF (r_matched_id_rec.person_id = p_target_person_id) THEN
        RETURN;
      END IF;
    END LOOP;
    -- Increment the number of matches
    p_number_of_matches := p_number_of_matches + 1;
    -- If the students results are not released due to an encumbrance
    -- then reason_code = 0
    OPEN c_pee;
    FETCH c_pee INTO v_person_id;
    IF (c_pee%FOUND) THEN
      CLOSE c_pee;
      v_reason_code := 'O';
      r_matched_id_rec.person_id := p_target_person_id;
      r_matched_id_rec.basis_of_match := p_basis_of_match;
      r_matched_id_rec.reason_code := v_reason_code;
      t_matched_ids(p_number_of_matches) := r_matched_id_rec;
      RETURN;
    END IF;
    CLOSE c_pee;
    -- If student is currently enrolled then reason_code = C
    OPEN c_sua;
    FETCH c_sua INTO v_person_id;
    IF (c_sua%FOUND) THEN
      CLOSE c_sua;
      v_reason_code := 'C';
      r_matched_id_rec.person_id := p_target_person_id;
      r_matched_id_rec.basis_of_match := p_basis_of_match;
      r_matched_id_rec.reason_code := v_reason_code;
      t_matched_ids(p_number_of_matches) := r_matched_id_rec;
      RETURN;
    END IF;
    CLOSE c_sua;
    -- If we have reached this far then there are no special circumstances.
    v_reason_code := ' ';
    r_matched_id_rec.person_id := p_target_person_id;
    r_matched_id_rec.basis_of_match := p_basis_of_match;
    r_matched_id_rec.reason_code := v_reason_code;
    t_matched_ids(p_number_of_matches) := r_matched_id_rec;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_store_matched_table');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_store_matched_table;
---------------
---------------
  PROCEDURE admpl_match_criteria11 (
    p_convert_birth_dt    IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_number_of_matches   IN OUT NOCOPY NUMBER)
  IS
    cst_match11 CONSTANT  VARCHAR2(3) := 'PFB';
    v_number_of_matches   NUMBER(4);
    CURSOR c_pe (
      cp_previous_family_name   IGS_PE_PERSON.surname%TYPE) IS
      SELECT  pe.person_id
      FROM  igs_pe_person_base_v pe   /* Replaced IGS_PE_PERSON with HZ tables Bug 3150054 */
      WHERE pe.last_name = cp_previous_family_name AND
        pe.birth_date = p_convert_birth_dt;
  BEGIN -- admpl_match_criteria11
    -- Find match on previous family name and date of birth
    FOR i IN 1..v_previous_name_records_cnt LOOP
      r_previous_name_rec := t_previous_name(i);
      FOR v_pe_rec IN c_pe(r_previous_name_rec.family_name) LOOP
        -- We have a match
        admpl_store_matched_table(
              v_pe_rec.person_id,
              cst_match11,
              p_number_of_matches);
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria11');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria11;
---------------
---------------
  PROCEDURE admpl_match_criteria10 (
    p_convert_family_name   IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_birth_dt    IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_number_of_matches   IN OUT NOCOPY NUMBER)
  IS
    cst_match10 CONSTANT  VARCHAR2(3) := 'CFB';
    v_number_of_matches   NUMBER(4);
    CURSOR c_pe IS
      SELECT  pe.person_id
      FROM  igs_pe_person_base_v pe   /* Replaced IGS_PE_PERSON with HZ tables Bug 3150054 */
      WHERE pe.last_name = p_convert_family_name AND
        pe.birth_date = p_convert_birth_dt;
  BEGIN -- admpl_match_criteria10
    -- Find match on current family name and date of birth
    FOR v_pe_rec IN c_pe LOOP
      -- We have a match
      admpl_store_matched_table(
            v_pe_rec.person_id,
            cst_match10,
            p_number_of_matches);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria10');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria10;
---------------
---------------
  PROCEDURE admpl_match_criteria9 (
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    cst_match9  CONSTANT  VARCHAR2(3) := 'P';
    v_number_of_matches   NUMBER(4);
    v_db_given_name     IGS_PE_PERSON.given_names%TYPE;
    v_other_names     IGS_PE_PERSON.given_names%TYPE;
    CURSOR c_pe (
      cp_previous_family_name   IGS_PE_PERSON.surname%TYPE) IS
      SELECT  hz.party_id person_id /* Replaced IGS_PE_PERSON with HZ tables Bug 3150054 */
      FROM  hz_parties hz
      WHERE hz.person_last_name = cp_previous_family_name;
  BEGIN -- admpl_match_criteria9
    -- Find match on previous family name and a given name
    FOR i IN 1..v_previous_name_records_cnt LOOP
      r_previous_name_rec := t_previous_name(i);
      FOR v_pe_rec IN c_pe(r_previous_name_rec.family_name) LOOP
        -- Truncate name
        IGS_ST_GEN_003.stap_get_prsn_names(
            v_pe_rec.person_id,
            v_db_given_name,  -- out NOCOPY
            v_other_names);   -- out NOCOPY
        IF (r_previous_name_rec.first_name IS NOT NULL OR
            r_previous_name_rec.second_name IS NOT NULL) THEN
          -- We want to match the first given
          -- name from the database against either
          -- previous given name provided in the file
          IF (v_db_given_name = r_previous_name_rec.first_name OR
              v_db_given_name = r_previous_name_rec.second_name) THEN
            -- We have a match
            admpl_store_matched_table(
                  v_pe_rec.person_id,
                  cst_match9,
                  p_number_of_matches);
          END IF;
        ELSE
          -- Previous given names are blank
          -- so use current given names
          IF (v_db_given_name = p_convert_first_name OR
              v_db_given_name = p_convert_second_name) THEN
            -- We have a match
            admpl_store_matched_table(
                  v_pe_rec.person_id,
                  cst_match9,
                  p_number_of_matches);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria9');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria9;
---------------
---------------
  PROCEDURE admpl_match_criteria8 (
    p_convert_family_name IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    cst_match8  CONSTANT  VARCHAR2(3) := 'C';
    v_number_of_matches   NUMBER(4);
    v_db_given_name     IGS_PE_PERSON.given_names%TYPE;
    v_other_names     IGS_PE_PERSON.given_names%TYPE;
    CURSOR c_pe IS
      SELECT  hz.party_id person_id
      FROM  hz_parties hz
      WHERE hz.person_last_name = p_convert_family_name;
  BEGIN   -- p_convert_family_name
    -- Find match on current family name and a given name
    FOR v_pe_rec IN c_pe LOOP
      -- We want to match the first given name from the database
      -- against either given name provided in the file
      -- Truncate name
      IGS_ST_GEN_003.stap_get_prsn_names(
            v_pe_rec.person_id,
            v_db_given_name,  -- out NOCOPY
            v_other_names);   -- out NOCOPY
      IF (v_db_given_name = p_convert_first_name OR
          v_db_given_name  = p_convert_second_name) THEN
        -- We have a match
        admpl_store_matched_table(
              v_pe_rec.person_id,
              cst_match8,
              p_number_of_matches);
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria8');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria8;
---------------
---------------
  PROCEDURE admpl_match_criteria7 (
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    cst_match7  CONSTANT  VARCHAR2(3) := 'PB';
    v_number_of_matches   NUMBER(4);
    v_db_given_name     IGS_PE_PERSON.given_names%TYPE;
    v_other_names     IGS_PE_PERSON.given_names%TYPE;
    CURSOR c_pe (
      cp_previous_family_name   IGS_PE_PERSON.surname%TYPE) IS
      SELECT  pe.person_id
      FROM  igs_pe_person_base_v pe   /* Replaced IGS_PE_PERSON with HZ tables Bug 3150054 */
      WHERE pe.last_name = cp_previous_family_name AND
        pe.birth_date = p_convert_birth_dt;
  BEGIN -- admpl_match_criteria7
    -- Find match on previous family name, a given name and date of birth
    FOR i IN 1..v_previous_name_records_cnt LOOP
      r_previous_name_rec := t_previous_name(i);
      FOR v_pe_rec IN c_pe(r_previous_name_rec.family_name) LOOP
        -- Truncate name
        IGS_ST_GEN_003.stap_get_prsn_names(
            v_pe_rec.person_id,
            v_db_given_name,  -- out NOCOPY
            v_other_names);   -- out NOCOPY
        IF (r_previous_name_rec.first_name IS NOT NULL OR
            r_previous_name_rec.second_name IS NOT NULL) THEN
          -- We want to match the first given name
          -- from the database against either previous
          -- given name provided in the file
          IF (v_db_given_name = r_previous_name_rec.first_name OR
              v_db_given_name = r_previous_name_rec.second_name) THEN
            -- We have a match
            admpl_store_matched_table(
                  v_pe_rec.person_id,
                  cst_match7,
                  p_number_of_matches);
          END IF;
        ELSE
          -- Previous given names are blank so use current given names
          IF (v_db_given_name = p_convert_first_name OR
              v_db_given_name = p_convert_second_name) THEN
            -- We have a match
            admpl_store_matched_table(
                  v_pe_rec.person_id,
                  cst_match7,
                  p_number_of_matches);
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria7');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria7;
---------------
---------------
  PROCEDURE admpl_match_criteria6 (
    p_convert_family_name IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    cst_match6  CONSTANT  VARCHAR2(3) := 'CB';
    v_number_of_matches   NUMBER(4);
    v_db_given_name     IGS_PE_PERSON.given_names%TYPE;
    v_other_names     IGS_PE_PERSON.given_names%TYPE;
    CURSOR c_pe IS
      SELECT  pe.person_id
      FROM  igs_pe_person_base_v pe   /* Replaced IGS_PE_PERSON with HZ tables Bug 3150054 */
      WHERE pe.last_name = p_convert_family_name AND
        pe.birth_date = p_convert_birth_dt;
  BEGIN -- admpl_match_criteria6
    -- Find match on current family name, a given name and date of birth
    FOR v_pe_rec IN c_pe LOOP
      -- We want to match the first given name from
      -- the database against either given name
      -- provided in the file
      -- Truncate name
      IGS_ST_GEN_003.stap_get_prsn_names(
            v_pe_rec.person_id,
            v_db_given_name,  -- out NOCOPY
            v_other_names);   -- out NOCOPY
      IF (v_db_given_name = p_convert_first_name OR
          v_db_given_name = p_convert_second_name) THEN
        -- We have a match
        admpl_store_matched_table(
              v_pe_rec.person_id,
              cst_match6,
              p_number_of_matches);
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria6');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria6;
---------------
---------------
  PROCEDURE admpl_match_criteria5 (
    p_convert_id    IN  IGS_PE_PERSON.person_id%TYPE,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    cst_match5  CONSTANT  VARCHAR2(3) := 'S';
    v_number_of_matches   NUMBER(4);
    v_person_id     IGS_PE_PERSON.person_id%TYPE;
    CURSOR c_pe IS
      SELECT  hz.party_id person_id /* Replaced IGS_PE_PERSON with HZ tables Bug 3150054 */
      FROM  hz_parties hz
      WHERE hz.party_id = p_convert_id;
  BEGIN -- admpl_match_criteria5
    -- Find match on person ID only
    OPEN c_pe;
    FETCH c_pe INTO v_person_id;
    IF (c_pe%FOUND) THEN
      CLOSE c_pe;
      -- We have a match
      admpl_store_matched_table(
            v_person_id,
            cst_match5,
            p_number_of_matches);
    ELSE
      CLOSE c_pe;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria5');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria5;
---------------
---------------
  PROCEDURE admpl_match_criteria4a (
    p_convert_id    IN  IGS_PE_PERSON.person_id%TYPE,
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    cst_match4a CONSTANT  VARCHAR2(3) := 'SB';
    v_number_of_matches   NUMBER(4);
    v_person_id     IGS_PE_PERSON.person_id%TYPE;
    CURSOR c_pe IS
      SELECT  pe.person_id
      FROM  igs_pe_person_base_v pe   /* Replaced IGS_PE_PERSON with HZ tables Bug 3150054 */
      WHERE pe.person_id =  p_convert_id AND
        pe.birth_date = p_convert_birth_dt;
  BEGIN -- admpl_match_criteria4a
    -- Find match on person ID and date of birth
    OPEN c_pe;
    FETCH c_pe INTO v_person_id;
    IF (c_pe%FOUND) THEN
      CLOSE c_pe;
      -- We have a match
      admpl_store_matched_table(
            v_person_id,
            cst_match4a,
            p_number_of_matches);
    ELSE
      CLOSE c_pe;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria4a');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria4a;
---------------
---------------
  PROCEDURE admpl_match_criteria4 (
    p_convert_id    IN  IGS_PE_PERSON.person_id%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    cst_match4  CONSTANT  VARCHAR2(3) := 'SP';
    v_number_of_matches   NUMBER(4);
    v_person_id     IGS_PE_PERSON.person_id%TYPE;
    v_db_given_name     IGS_PE_PERSON.given_names%TYPE;
    v_other_names     IGS_PE_PERSON.given_names%TYPE;
    CURSOR c_pe (
      cp_previous_family_name   IGS_PE_PERSON.surname%TYPE) IS
                        SELECT  hz.party_id person_id
      FROM  hz_parties hz   /* Replaced IGS_PE_PERSON with HZ tables Bug 3150054 */
      WHERE hz.party_id = p_convert_id AND
                                hz.person_last_name = cp_previous_family_name;
  BEGIN -- admpl_match_criteria4
    -- Find match on person_id, previous family name and a given name
    FOR i IN 1..v_previous_name_records_cnt LOOP
      r_previous_name_rec := t_previous_name(i);
      OPEN c_pe(r_previous_name_rec.family_name);
      FETCH c_pe INTO v_person_id;
      IF (c_pe%FOUND) THEN
        CLOSE c_pe;
        -- Trancate name
        IGS_ST_GEN_003.stap_get_prsn_names(
            v_person_id,
            v_db_given_name,  -- out NOCOPY
            v_other_names);   -- out NOCOPY
        IF (r_previous_name_rec.first_name IS NOT NULL OR
            r_previous_name_rec.second_name IS NOT NULL) THEN
          -- We want to match the first given name
          -- from the database against either previous
          -- given name provided in the file
          IF (v_db_given_name = r_previous_name_rec.first_name OR
              v_db_given_name = r_previous_name_rec.second_name) THEN
            -- We have a match
            admpl_store_matched_table(
                  v_person_id,
                  cst_match4,
                  p_number_of_matches);
          END IF;
        ELSE
          -- Previous given names are blank
          -- so use current given names
          IF (v_db_given_name = p_convert_first_name OR
              v_db_given_name = p_convert_second_name) THEN
            -- We have a match
            admpl_store_matched_table(
                  v_person_id,
                  cst_match4,
                  p_number_of_matches);
          END IF;
        END IF;
      ELSE
        CLOSE c_pe;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria4');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria4;
---------------
---------------
  PROCEDURE admpl_match_criteria3 (
    p_convert_id    IN  IGS_PE_PERSON.person_id%TYPE,
    p_convert_family_name IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    cst_match3  CONSTANT  VARCHAR2(3) := 'SC';
    v_number_of_matches   NUMBER(4);
    v_person_id     IGS_PE_PERSON.person_id%TYPE;
    v_db_given_name     IGS_PE_PERSON.given_names%TYPE;
    v_other_names     IGS_PE_PERSON.given_names%TYPE;
    CURSOR c_pe IS
                        SELECT  hz.party_id person_id
      FROM  hz_parties hz   /* Replaced IGS_PE_PERSON with HZ tables Bug 3150054 */
      WHERE hz.party_id = p_convert_id AND
              hz.person_last_name = p_convert_family_name;
  BEGIN -- admpl_match_criteria3
    -- Find match on person ID, current family name and a given name
    OPEN c_pe;
    FETCH c_pe INTO v_person_id;
    IF (c_pe%FOUND) THEN
      CLOSE c_pe;
      -- We want to match the first given name
      -- from the database against either given
      -- name provided in the file
      -- Truncate given name
      IGS_ST_GEN_003.stap_get_prsn_names(
            v_person_id,
            v_db_given_name,  -- out NOCOPY
            v_other_names);   -- out NOCOPY
      IF (v_db_given_name = p_convert_first_name OR
          v_db_given_name = p_convert_second_name) THEN
        -- We have a match
        admpl_store_matched_table(
            v_person_id,
            cst_match3,
            p_number_of_matches);
      END IF;
    ELSE
      CLOSE c_pe;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria3');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria3;
---------------
---------------
  PROCEDURE admpl_match_criteria2 (
    p_convert_id    IN  IGS_PE_PERSON.person_id%TYPE,
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    cst_match2  CONSTANT  VARCHAR2(3) := 'SPB';
    v_number_of_matches   NUMBER(4);
    v_person_id     IGS_PE_PERSON.person_id%TYPE;
    v_db_given_name     IGS_PE_PERSON.given_names%TYPE;
    v_other_names     IGS_PE_PERSON.given_names%TYPE;
    CURSOR c_pe (
      cp_previous_family_name   IGS_PE_PERSON.surname%TYPE) IS
      SELECT  pe.person_id
      FROM  igs_pe_person_base_v pe   /* Replaced IGS_PE_PERSON with HZ tables Bug 3150054 */
      WHERE pe.person_id = p_convert_id AND
              pe.last_name = cp_previous_family_name AND
        pe.birth_date = p_convert_birth_dt;
  BEGIN -- admpl_match_criteria2
    -- Find match on person ID, previous family name,
    -- a given name and date of birth
    FOR i IN 1..v_previous_name_records_cnt LOOP
      r_previous_name_rec := t_previous_name(i);
      OPEN c_pe(r_previous_name_rec.family_name);
      FETCH c_pe INTO v_person_id;
      IF (c_pe%FOUND) THEN
        CLOSE c_pe;
        -- truncate name
        IGS_ST_GEN_003.stap_get_prsn_names(
            v_person_id,
            v_db_given_name,  -- out NOCOPY
            v_other_names);   -- out NOCOPY
        IF (r_previous_name_rec.first_name IS NOT NULL OR
            r_previous_name_rec.second_name IS NOT NULL) THEN
          -- We want to match the first given name from
          -- the database against either previous given
          -- name provided in the file
          IF (v_db_given_name = r_previous_name_rec.first_name OR
              v_db_given_name = r_previous_name_rec.second_name) THEN
            -- We have a match
            admpl_store_matched_table(
                  v_person_id,
                  cst_match2,
                  p_number_of_matches);
          END IF;
        ELSE
          -- Previous given names are blank
          -- so use current given names
          IF (v_db_given_name = p_convert_first_name OR
              v_db_given_name = p_convert_second_name) THEN
            -- We have a match
            admpl_store_matched_table(
                  v_person_id,
                  cst_match2,
                  p_number_of_matches);
          END IF;
        END IF;
      ELSE
        CLOSE c_pe;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria2');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria2;
---------------
---------------
  PROCEDURE admpl_match_criteria1 (
    p_convert_id    IN  IGS_PE_PERSON.person_id%TYPE,
    p_convert_family_name IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    cst_match1  CONSTANT  VARCHAR2(3) := 'SCB';
    v_number_of_matches   NUMBER(4);
    v_person_id     IGS_PE_PERSON.person_id%TYPE;
    v_db_given_name     IGS_PE_PERSON.given_names%TYPE;
    v_other_names     IGS_PE_PERSON.given_names%TYPE;
    CURSOR c_pe IS
      SELECT  pe.person_id
      FROM  igs_pe_person_base_v pe   /* Replaced IGS_PE_PERSON with HZ tables Bug 3150054 */
      WHERE pe.person_id = p_convert_id AND
              pe.last_name = p_convert_family_name AND
        pe.birth_date = p_convert_birth_dt;
  BEGIN -- admpl_match_criteria1
    -- Find match on person ID, current family name,
    -- a given name and date of birth.
    OPEN c_pe;
    FETCH c_pe INTO v_person_id;
    IF (c_pe%FOUND) THEN
      CLOSE c_pe;
      -- We want to match the first given name from the database
      -- against either given name provided in the file
      IGS_ST_GEN_003.stap_get_prsn_names(
            v_person_id,
            v_db_given_name,  -- out NOCOPY
            v_other_names);   -- out NOCOPY
      IF (v_db_given_name = p_convert_first_name OR
          v_db_given_name = p_convert_second_name) THEN
        -- we have a match
        admpl_store_matched_table(
              v_person_id,
              cst_match1,
              p_number_of_matches);
      END IF;
    ELSE
      CLOSE c_pe;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_criteria1');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_criteria1;
---------------
---------------
  PROCEDURE admpl_match_any_name (
    p_convert_family_name IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    v_number_of_matches   NUMBER(4);
  BEGIN -- admpl_match_any_name (9)
    -- Step 1 Attempt a match using criterion 6
    admpl_match_criteria6(
          p_convert_family_name,
          p_convert_birth_dt,
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
    -- Step 2 Attempt a match using criterion 7
    admpl_match_criteria7(
          p_convert_birth_dt,
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      RETURN;
    END IF;
    -- Step 3 Attempt a match using criterion 8
    admpl_match_criteria8(
          p_convert_family_name,
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
    -- Step 4 Attempt a match using criterion 9
    admpl_match_criteria9(
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      RETURN;
    END IF;
    -- Step 5 Attempt a match using criterion 10
    admpl_match_criteria10(
          p_convert_family_name,
          p_convert_birth_dt,
          p_number_of_matches);
    -- Step 6 Attempt a match using criterion 11
    admpl_match_criteria11(
          p_convert_birth_dt,
          p_number_of_matches);
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_any_name');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_any_name;
---------------
---------------
  PROCEDURE admpl_match_loose_name (
    p_convert_family_name IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    v_number_of_matches   NUMBER(4);
  BEGIN -- admpl_match_loose_name (8)
    -- Step 1 Attempt a match using criterion 6
    admpl_match_criteria6(
          p_convert_family_name,
          p_convert_birth_dt,
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      RETURN;
    END IF;
    -- Step 2 Attempt a match using criterion 8
    admpl_match_criteria8(
          p_convert_family_name,
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      RETURN;
    END IF;
    -- Step 3 Attempt a match using criterion 10
    admpl_match_criteria10(
          p_convert_family_name,
          p_convert_birth_dt,
          p_number_of_matches);
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_loose_name');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_loose_name;
---------------
---------------
  PROCEDURE admpl_match_exact_name (
    p_convert_family_name IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    v_number_of_matches   NUMBER(4);
  BEGIN -- admpl_match_exact_name (7)
    -- Step 1 Attempt a match using criterion 6
    admpl_match_criteria6(
          p_convert_family_name,
          p_convert_birth_dt,
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_exact_name');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_exact_name;
---------------
---------------
  PROCEDURE admpl_match_any_id (
    p_convert_id    IN  IGS_PE_PERSON.person_id%TYPE,
    p_convert_family_name IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    v_number_of_matches   NUMBER(4);
  BEGIN -- admpl_match_any_id (6)
    -- Step 1 Attempt a match using criterion 1
    admpl_match_criteria1(
          p_convert_id,
          p_convert_family_name,
          p_convert_birth_dt,
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
    -- Step 2 Attempt a match using criteria 2
    admpl_match_criteria2(
          p_convert_id,
          p_convert_birth_dt,
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      RETURN;
    END IF;
    -- Step 3 Attempt a match using criterion 3
    admpl_match_criteria3(
          p_convert_id,
          p_convert_family_name,
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
    -- Step 4 Attempt a match using criterion 4
    admpl_match_criteria4(
          p_convert_id,
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      RETURN;
    END IF;
    -- Step 4a Attempt a match using criterion 4a.
    admpl_match_criteria4a(
          p_convert_id,
          p_convert_birth_dt,
          p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      RETURN;
    END IF;
    -- Step 5 Attempt a match using criterion 5
    admpl_match_criteria5(
          p_convert_id,
          p_number_of_matches);
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_any_id');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_any_id;
---------------
---------------
  PROCEDURE admpl_match_exact_id (
    p_convert_id    IN  IGS_PE_PERSON.person_id%TYPE,
    p_convert_family_name IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    v_number_of_matches   NUMBER(4);
  BEGIN -- admpl_match_exact_id (5)
    -- Step 1 Attempt a match using criterion 1.
    admpl_match_criteria1(
        p_convert_id,
        p_convert_family_name,
        p_convert_birth_dt,
        p_convert_first_name,
        p_convert_second_name,
        p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      RETURN;
    END IF;
    -- Step 2 Attempt a match using criterion 3
    admpl_match_criteria3(
        p_convert_id,
        p_convert_family_name,
        p_convert_first_name,
        p_convert_second_name,
        p_number_of_matches);
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_exact_id');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_exact_id;
---------------
---------------
  PROCEDURE admpl_match_standard_6 (
    p_convert_family_name IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    v_number_of_matches   NUMBER(4);
  BEGIN
    -- Step 6 Attempt a match using criterion 6. (17)
    admpl_match_criteria6(
        p_convert_family_name,
        p_convert_birth_dt,
        p_convert_first_name,
        p_convert_second_name,
        p_number_of_matches);
    -- Step 7 Attempt a match using criterion 7. (18)
    admpl_match_criteria7(
        p_convert_birth_dt,
        p_convert_first_name,
        p_convert_second_name,
        p_number_of_matches);
    -- If one or more new matches are found
    IF (p_number_of_matches > 0) THEN
      RETURN;
    END IF;
    -- Step 8 Attempt a match using criterion 8. (19)
    admpl_match_criteria8(
        p_convert_family_name,
        p_convert_first_name,
        p_convert_second_name,
        p_number_of_matches);
    -- Step 9 Attempt a match using criterion 9. (20)
    admpl_match_criteria9(
        p_convert_first_name,
        p_convert_second_name,
        p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      RETURN;
    END IF;
    -- Step 10 Attempt a match using criterion 10. (21)
    admpl_match_criteria10(
        p_convert_family_name,
        p_convert_birth_dt,
        p_number_of_matches);
    -- Step 11 Attempt a match using criterion 11. (22)
    admpl_match_criteria11(
        p_convert_birth_dt,
        p_number_of_matches);
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_standard_6');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_standard_6;
  PROCEDURE admpl_match_standard (
    p_convert_id    IN  IGS_PE_PERSON.person_id%TYPE,
    p_convert_family_name IN  IGS_PE_PERSON.surname%TYPE,
    p_convert_birth_dt  IN  IGS_PE_PERSON.birth_dt%TYPE,
    p_convert_first_name  IN  VARCHAR2,
    p_convert_second_name IN  VARCHAR2,
    p_number_of_matches IN OUT NOCOPY NUMBER)
  IS
    v_number_of_matches   NUMBER(4);
  BEGIN -- admpl_match_standard (4)
    -- Standard matching algorithm
    -- Step 1 Attempt a match using criterion 1. (11)
    admpl_match_criteria1(
        p_convert_id,
        p_convert_family_name,
        p_convert_birth_dt,
        p_convert_first_name,
        p_convert_second_name,
        p_number_of_matches);
    -- Step 2 Attempt a match using criterion 2. (12)
    admpl_match_criteria2(
        p_convert_id,
        p_convert_birth_dt,
        p_convert_first_name,
        p_convert_second_name,
        p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      -- Go to Step 6
      admpl_match_standard_6(
            p_convert_family_name,
            p_convert_birth_dt,
            p_convert_first_name,
            p_convert_second_name,
            p_number_of_matches);
      RETURN;
    END IF;
    -- Step 3 Attempt a match using criterion 3. (13)
    admpl_match_criteria3(
        p_convert_id,
        p_convert_family_name,
        p_convert_first_name,
        p_convert_second_name,
        p_number_of_matches);
    -- Step 4 Attempt a match using criterion 4. (14)
    admpl_match_criteria4(
        p_convert_id,
        p_convert_first_name,
        p_convert_second_name,
        p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      -- Go to Step 6
      admpl_match_standard_6(
            p_convert_family_name,
            p_convert_birth_dt,
            p_convert_first_name,
            p_convert_second_name,
            p_number_of_matches);
      RETURN;
    END IF;
    -- Step 4a Attempt a match using criterion 4a. (15)
    admpl_match_criteria4a(
        p_convert_id,
        p_convert_birth_dt,
        p_number_of_matches);
    IF (p_number_of_matches > 0) THEN
      -- Go to Step 6
      admpl_match_standard_6(
            p_convert_family_name,
            p_convert_birth_dt,
            p_convert_first_name,
            p_convert_second_name,
            p_number_of_matches);
      RETURN;
    END IF;
    -- Step 5 Attempt a match using criterion 5. (16)
    admpl_match_criteria5(
        p_convert_id,
        p_number_of_matches);
    admpl_match_standard_6(
          p_convert_family_name,
          p_convert_birth_dt,
          p_convert_first_name,
          p_convert_second_name,
          p_number_of_matches);
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_match_standard');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_match_standard;
---------------
---------------
  PROCEDURE admpl_write_course_header (
    p_course_cd     IN  IGS_PS_VER.course_cd%TYPE,
    p_course_title      IN  IGS_PS_VER.title%TYPE,
    p_govt_field_of_study   IN  IGS_PS_FLD_OF_STUDY.govt_field_of_study%TYPE,
    p_govt_course_type    IN  IGS_PS_TYPE.govt_course_type%TYPE,
    p_honours_flag      IN  IGS_GR_HONOURS_LEVEL.govt_honours_level%TYPE,
    p_exclusion_flag    IN  VARCHAR2,
    p_all_subjects_inc_flag   IN  VARCHAR2,
    p_course_completed_flag   IN  VARCHAR2,
    p_course_year_first_enr   IN  NUMBER,
    p_course_year_last_enr    IN  NUMBER,
    p_course_sem_first_enr    IN  NUMBER,
    p_course_sem_last_enr   IN  NUMBER,
    p_equiv_full_time_enr   IN  NUMBER) -- sca_total_eftsu
  IS
    cst_course_rec_type   CONSTANT VARCHAR2(1) := 'C';
    v_output_course     VARCHAR2(106);
  BEGIN
    -- Write out NOCOPY the details of the course attempt record
    v_output_course := cst_course_rec_type ||
        RPAD(p_course_cd, 10) ||
        RPAD(p_course_title, 72) ||
        LTRIM(TO_CHAR(IGS_GE_NUMBER.TO_NUM(p_govt_field_of_study), '000000')) ||
        LTRIM(TO_CHAR(p_govt_course_type, '00')) ||
        NVL(p_honours_flag, '0') ||
        RPAD(NVL(p_exclusion_flag, ' '), 1) ||
        RPAD(NVL(p_all_subjects_inc_flag, ' '), 1) ||
        RPAD(NVL(p_course_completed_flag, ' '), 1) ||
        TO_CHAR(TO_DATE(p_course_year_first_enr, 'YYYY'), 'YY') ||
        LTRIM(TO_CHAR(p_course_sem_first_enr, '0'));
    IF (p_course_year_last_enr = 0) THEN
      v_output_course := v_output_course ||
          '00';
    ELSE
      v_output_course := v_output_course ||
          TO_CHAR(TO_DATE(p_course_year_last_enr, 'YYYY'), 'YY');
    END IF;
    v_output_course := v_output_course ||
        LTRIM(TO_CHAR(p_course_sem_last_enr, '0')) ||
        LTRIM(TO_CHAR(p_equiv_full_time_enr, '00V00')) ||
        fnd_global.newline;
    UTL_FILE.PUT(fp_output, v_output_course);
    UTL_FILE.FFLUSH(fp_output);
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_write_course_header');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_write_course_header;
  PROCEDURE admpl_write_student_details (
    p_matched_id    IN  r_matched_id_rec.person_id%TYPE,
    p_basis_of_match  IN  r_matched_id_rec.basis_of_match%TYPE,
    p_reason_code   IN  r_matched_id_rec.reason_code%TYPE)
  IS
    --
    -- Who         When            What
    -- knaraset  29-Apr-03   passed uoo_id in call of IGS_AS_GEN_003.assp_get_sua_grade, as part of MUS build bug 2829262
    --
    cst_discontin   CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE :=
            'DISCONTIN';
    cst_completed   CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE :=
            'COMPLETED';
    cst_exc_course    CONSTANT IGS_PE_COURSE_EXCL.s_encmb_effect_type%TYPE :=
            'EXC_COURSE';
    cst_exc_crs_gp    CONSTANT IGS_PE_CRS_GRP_EXCL.s_encmb_effect_type%TYPE :=
            'EXC_CRS_GP';
    cst_sus_course    CONSTANT IGS_PE_COURSE_EXCL.s_encmb_effect_type%TYPE :=
            'SUS_COURSE';
    cst_academic    CONSTANT IGS_CA_TYPE.s_cal_cat%TYPE := 'ACADEMIC';
    cst_load    CONSTANT IGS_CA_TYPE.s_cal_cat%TYPE := 'LOAD';
    cst_student_rec_type  CONSTANT VARCHAR2(1) := 'M';
    cst_subject_rec_type  CONSTANT VARCHAR2(1) := 'S';
    cst_withdrawn   CONSTANT IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE :=
            'WITHDRAWN';
    cst_fail    CONSTANT IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE := 'FAIL';
    cst_pass    CONSTANT IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE := 'PASS';
    v_person_id     IGS_PE_PERSON.person_id%TYPE;
    v_surname     IGS_PE_PERSON.surname%TYPE;
    v_given_names     IGS_PE_PERSON.given_names%TYPE;
    v_birth_dt      IGS_PE_PERSON.birth_dt%TYPE;
    v_birth_dt_str      VARCHAR2(6);
    v_space_pos     VARCHAR2(2);
    v_first_name      IGS_PE_PERSON.given_names%TYPE;
    v_second_name     IGS_PE_PERSON.given_names%TYPE;
    v_course_year_first_enr   NUMBER(4);
    v_course_year_last_enr    NUMBER(4);
    v_course_sem_first_enr    NUMBER(1);
    v_course_sem_last_enr   NUMBER(1);
    v_sca_total_eftsu   NUMBER;
    v_output_student    VARCHAR2(71);
    v_output_subject    VARCHAR2(69);
    v_last_course_cd    IGS_PS_VER.course_cd%TYPE;
    v_course_title      IGS_PS_VER.title%TYPE;
    v_govt_field_of_study   IGS_PS_FLD_OF_STUDY.govt_field_of_study%TYPE;
    v_govt_course_type    IGS_PS_TYPE.govt_course_type%TYPE;
    v_honours_flag      IGS_GR_HONOURS_LEVEL.govt_honours_level%TYPE;
    v_exclusion_flag    VARCHAR2(1);
    v_s_encmb_effect_type   IGS_PE_COURSE_EXCL.s_encmb_effect_type%TYPE;
    v_course_completed_flag   VARCHAR2(1);
    v_all_subjects_inc_flag   VARCHAR2(1);
    v_subject_code      IGS_PS_UNIT_VER.unit_cd%TYPE;
    v_subject_title     IGS_PS_UNIT_VER.title%TYPE;
    v_year_enrolled     IGS_EN_SUA_V.acad_alternate_code%TYPE;
    v_arts_teaching_cal_type_cd IGS_CA_TYPE.arts_teaching_cal_type_cd%TYPE;
    v_semester_enrolled   NUMBER(1);
    v_grade       IGS_AS_GRD_SCH_GRADE.grade%TYPE;
    v_s_result_type     IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
    v_subject_completion_code NUMBER(1);
    v_govt_discipline_group_cd  IGS_PS_DSCP.govt_discipline_group_cd%TYPE;
    v_subject_discipline_group  NUMBER(4);
    v_number_ind      BOOLEAN;
    v_credit_points     NUMBER(6);
    v_sua_eftsu     NUMBER;
    v_grading_schema_cd   IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
    v_gs_version_number   IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
    v_subject_cnt     NUMBER(3);
    TYPE t_subject_type IS TABLE OF v_output_subject%TYPE
      INDEX BY BINARY_INTEGER;
    t_subject   t_subject_type;
    t_subject_clear   t_subject_type;
    CURSOR c_pe IS
            SELECT pe.person_id person_id,
        pe.last_name surname,
        pe.first_name given_names,
        pe.birth_date birth_dt
      FROM igs_pe_person_base_v pe /* Replaced IGS_PE_PERSON with igs_pe_person_base_v Bug 3150054 */
      WHERE pe.person_id = p_matched_id;
    CURSOR c_sua_sca IS
      SELECT sca.course_rqrmnt_complete_ind,
                    sca.person_id,
                    crv.course_cd,
                    crv.version_number course_version_number,
                    crv.course_type,
                    crv.title course_title,
                    uv.unit_cd,
                    sua.version_number unit_version_number,
                    uv.title unit_title,
                    IGS_EN_GEN_014.enrs_get_acad_alt_cd(sua.cal_type,sua.ci_sequence_number) acad_alternate_code,
                    sua.cal_type,
                    sua.ci_sequence_number,
                    sua.uoo_id,
                    sua.discontinued_dt,
                    sua.administrative_unit_status,
                    sua.override_enrolled_cp,
                    sua.override_eftsu,
                    sua.unit_attempt_status,
                    sua.no_assessment_ind
	FROM IGS_EN_SU_ATTEMPT  sua,
                    IGS_EN_STDNT_PS_ATT sca,
                    IGS_PS_VER crv,
                    IGS_PS_UNIT_VER uv
	WHERE sua.person_id = p_matched_id AND
                    sua.unit_attempt_status IN (
                                cst_enrolled,
                                cst_completed,
                                cst_discontin) AND
                    sca.person_id = sua.person_id AND
                    sca.course_cd = sua.course_cd AND
                    uv.unit_cd = sua.unit_cd AND
                    uv.version_number = sua.version_number AND
                    crv.course_cd = sca.course_cd AND
                    crv.version_number = sca.version_number
	ORDER BY sua.course_cd,
		sua.ci_start_dt;
    CURSOR c_fos_cfos (
      cp_course_cd    IGS_PS_VER.course_cd%TYPE,
      cp_version_number IGS_PS_VER.version_number%TYPE) IS
      SELECT  fos.govt_field_of_study
      FROM  IGS_PS_FLD_OF_STUDY   fos,
        IGS_PS_FIELD_STUDY  cfos
      WHERE cfos.course_cd = cp_course_cd AND
        cfos.version_number = cp_version_number AND
        cfos.major_field_ind = 'Y' AND
        fos.field_of_study = cfos.field_of_study;
    CURSOR c_cty (
      cp_course_type    IGS_PS_VER.course_type%TYPE) IS
      SELECT  cty.govt_course_type
      FROM  IGS_PS_TYPE cty
      WHERE cty.course_type = cp_course_type;
    CURSOR c_pee (
      cp_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE) IS
      SELECT  pee.s_encmb_effect_type
      FROM  IGS_PE_PERSENC_EFFCT  pee
      WHERE pee.person_id = cp_person_id AND
        pee.s_encmb_effect_type IN (
              cst_sus_srvc,
              cst_rvk_srvc);
    CURSOR c_pce (
      cp_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
      cp_course_cd    IGS_PS_VER.course_cd%TYPE) IS
      SELECT  pce.s_encmb_effect_type
      FROM  IGS_PE_COURSE_EXCL  pce
      WHERE pce.person_id = cp_person_id AND
        pce.s_encmb_effect_type IN (
              cst_exc_course,
              cst_sus_course) AND
        pce.course_cd = cp_course_cd;
    CURSOR c_pcge_cgr_cgm (
      cp_person_id    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
      cp_course_cd    IGS_PS_VER.course_cd%TYPE) IS
      SELECT  pcge.s_encmb_effect_type
      FROM  IGS_PE_CRS_GRP_EXCL pcge,
        IGS_PS_GRP      cgr,
        IGS_PS_GRP_MBR    cgm
      WHERE pcge.person_id = cp_person_id AND
        pcge.s_encmb_effect_type = cst_exc_crs_gp AND
        pcge.course_group_cd = cgr.course_group_cd AND
        cgr.course_group_cd = cgm.course_group_cd AND
        cgm.course_cd = cp_course_cd;
    CURSOR c_cat (
      cp_cal_type   IGS_CA_TYPE.cal_type%TYPE) IS
      SELECT  cat.arts_teaching_cal_type_cd
      FROM  IGS_CA_TYPE cat
      WHERE cat.cal_type = cp_cal_type;
    CURSOR c_cir_cat (
      cp_teach_cal_type   IGS_CA_INST_REL.sub_cal_type%TYPE,
      cp_teach_ci_sequence_number
            IGS_CA_INST_REL.sub_ci_sequence_number%TYPE) IS
      SELECT  cir2.sub_cal_type,
        cir2.sub_ci_sequence_number
      FROM  IGS_CA_INST_REL cir1,
        IGS_CA_INST_REL cir2,
        IGS_CA_TYPE     cat1,
        IGS_CA_TYPE     cat2
      WHERE cir1.sup_cal_type = cat1.cal_type AND
        cat1.s_cal_cat = cst_academic AND
        cir1.sub_cal_type = cp_teach_cal_type AND
        cir1.sub_ci_sequence_number = cp_teach_ci_sequence_number AND
        cir2.sub_cal_type = cat2.cal_type AND
        cat2.s_cal_cat = cst_load AND
        cir1.sup_cal_type = cir2.sup_cal_type AND
        cir1.sup_ci_sequence_number = cir2.sup_ci_sequence_number;
    CURSOR c_di_ud (
      cp_unit_cd      IGS_PS_UNIT_VER.unit_cd%TYPE,
      cp_unit_version_number    IGS_PS_UNIT_VER.version_number%TYPE) IS
      SELECT  di.govt_discipline_group_cd
      FROM  IGS_PS_DSCP di,
        IGS_PS_UNIT_DSCP  ud
      WHERE di.discipline_group_cd = ud.discipline_group_cd AND
        ud.unit_cd = cp_unit_cd AND
        ud.version_number = cp_unit_version_number;
  BEGIN
    OPEN c_pe;
    FETCH c_pe INTO v_person_id,
        v_surname,
        v_given_names,
        v_birth_dt;
    CLOSE c_pe;
    -- Change birth_dt to DDMMYY format
    v_birth_dt_str := TO_CHAR(v_birth_dt, 'DDMMYY');
    -- If the birth date is NULL then write it as 6 spaces.
    IF (v_birth_dt IS NULL) THEN
      v_birth_dt_str := '      ';
    END IF;
    -- If the birth date is before 1/1/1900 then write it as 000000
    IF (v_birth_dt < IGS_GE_DATE.IGSDATE('1900/01/01')) THEN --TO_DATE('1/1/1900', 'DD/MM/YYYY')) THEN
      v_birth_dt_str := '000000';
    END IF;
    v_space_pos := INSTR(v_given_names, ' ');
    IF (v_space_pos = 0) THEN
      -- Only one name
      v_first_name := v_given_names;
    ELSE
      v_first_name := SUBSTR(v_given_names, 1, v_space_pos - 1);
      v_given_names := SUBSTR(v_given_names, v_space_pos + 1);
      v_space_pos := INSTR(v_given_names, ' ');
      IF (v_space_pos = 0) THEN
        -- Only one middle name exists
        v_second_name := v_given_names;
      ELSE
        v_second_name := SUBSTR(v_given_names, 1, v_space_pos - 1);
      END IF;
    END IF;
    v_output_student := cst_student_rec_type ||
        RPAD(NVL(p_basis_of_match, ' '), 3) ||
        RPAD(IGS_GE_NUMBER.TO_CANN(p_matched_id), 10) ||
        RPAD(NVL(v_surname, ' '), 20) ||
        RPAD(NVL(v_first_name, ' '), 15) ||
        RPAD(NVL(v_second_name, ' '), 15) ||
        RPAD(NVL(v_birth_dt_str, ' '), 6) ||
        fnd_global.newline;
    UTL_FILE.PUT(fp_output, v_output_student);
    UTL_FILE.FFLUSH(fp_output);
    v_course_year_first_enr := 9999;
    v_course_year_last_enr := 0;
    v_course_sem_first_enr := 9;
    v_course_sem_last_enr := 0;
    v_sca_total_eftsu := 0.00;
    -- Find any IGS_EN_STDNT_PS_ATT records that have
    -- IGS_EN_SU_ATTEMPT records for this student
    FOR v_sua_sca_rec IN c_sua_sca LOOP
      -- We can't write the subject record until we have
      -- all the details for the course attempt record.
      IF (v_last_course_cd <> v_sua_sca_rec.course_cd OR
          v_last_course_cd IS NULL) THEN
        IF (v_last_course_cd IS NOT NULL) THEN
          -- A different course was found
          -- so write out NOCOPY the details for
          -- the last one.
          admpl_write_course_header(
                v_last_course_cd,
                v_course_title,
                v_govt_field_of_study,
                v_govt_course_type,
                v_honours_flag,
                v_exclusion_flag,
                v_all_subjects_inc_flag,
                v_course_completed_flag,
                v_course_year_first_enr,
                v_course_year_last_enr,
                v_course_sem_first_enr,
                v_course_sem_last_enr,
                v_sca_total_eftsu);
          FOR i IN 1..v_subject_cnt LOOP
            UTL_FILE.PUT(fp_output, t_subject(i));
            UTL_FILE.FFLUSH(fp_output);
          END LOOP;
          v_course_year_first_enr := 9999;
          v_course_year_last_enr := 0;
          v_course_sem_first_enr := 9;
          v_course_sem_last_enr := 0;
          v_sca_total_eftsu := 0.00;
        END IF;
        -- reset subject table
        t_subject := t_subject_clear;
        v_subject_cnt := 0;
        v_last_course_cd := v_sua_sca_rec.course_cd;
        v_course_title := v_sua_sca_rec.course_title;
        -- Find Field of study code
        OPEN c_fos_cfos (
            v_sua_sca_rec.course_cd,
            v_sua_sca_rec.course_version_number);
        FETCH c_fos_cfos INTO v_govt_field_of_study;
        CLOSE c_fos_cfos;
        IF (v_govt_field_of_study IS NULL) THEN
          v_govt_field_of_study := ' ';
        END IF;
        -- Find course type code
        OPEN c_cty(v_sua_sca_rec.course_type);
        FETCH c_cty INTO v_govt_course_type;
        CLOSE c_cty;
        -- Find honours flag
        v_honours_flag := IGS_GR_GEN_001.grdp_get_gr_ghl (  v_sua_sca_rec.person_id,
                v_sua_sca_rec.course_cd);
        -- Find Exclusion Flag
        -- We just want to find if an exclusion has
        -- ever existed. Therfore we can ignore the
        -- effective date against encumbrances.
        v_exclusion_flag := 'N';
        -- Check if completely excluded from all services
        OPEN c_pee(v_sua_sca_rec.person_id);
        FETCH c_pee INTO v_s_encmb_effect_type;
        IF (c_pee%FOUND) THEN
          v_exclusion_flag := 'Y';
        END IF;
        CLOSE c_pee;
        -- Check if excluded from this course
        IF (v_exclusion_flag = 'N') THEN
          OPEN c_pce(
            v_sua_sca_rec.person_id,
            v_sua_sca_rec.course_cd);
          FETCH c_pce INTO v_s_encmb_effect_type;
          IF (c_pce%FOUND) THEN
            v_exclusion_flag := 'Y';
          END IF;
          CLOSE c_pce;
        END IF;
        -- Also check for an exclusion from
        -- a course within a course group
        IF (v_exclusion_flag = 'N') THEN
          OPEN c_pcge_cgr_cgm(
              v_sua_sca_rec.person_id,
              v_sua_sca_rec.course_cd);
          FETCH c_pcge_cgr_cgm INTO v_s_encmb_effect_type;
          IF (c_pcge_cgr_cgm%FOUND) THEN
            v_exclusion_flag := 'Y';
          END IF;
          CLOSE c_pcge_cgr_cgm;
        END IF;
        -- FInd the course completed flag
        IF (v_sua_sca_rec.course_rqrmnt_complete_ind = 'Y') THEN
          v_course_completed_flag := 'Y';
        ELSE
          v_course_completed_flag := 'N';
        END IF;
        -- The All subjects included flag
        -- will always be set to 'Y'
        v_all_subjects_inc_flag := 'Y';
      END IF;
      -- Find the elements that need to be stored
      -- in the subject record PLSQL table.
      v_subject_code := v_sua_sca_rec.unit_cd;
      v_subject_title := v_sua_sca_rec.unit_title;
      v_year_enrolled := v_sua_sca_rec.acad_alternate_code;
      OPEN c_cat(v_sua_sca_rec.cal_type);
      FETCH c_cat INTO v_arts_teaching_cal_type_cd;
      CLOSE c_cat;
      IF (SUBSTR(v_arts_teaching_cal_type_cd, 1, 1) IN
          ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')) THEN
        v_semester_enrolled := IGS_GE_NUMBER.TO_NUM(SUBSTR(v_arts_teaching_cal_type_cd, 1, 1));
      ELSE
        v_semester_enrolled := NULL;
      END IF;
      -- Work out NOCOPY course record fields as we loop through all the units
      IF (v_year_enrolled <= v_course_year_first_enr) THEN
        IF (v_year_enrolled <> v_course_year_first_enr) THEN
          v_course_year_first_enr := v_year_enrolled;
          v_course_sem_first_enr := v_semester_enrolled;
        ELSE
          IF (v_semester_enrolled < v_course_sem_first_enr) THEN
            v_course_sem_first_enr := v_semester_enrolled;
          END IF;
        END IF;
      END IF;
      IF (v_year_enrolled >= v_course_year_last_enr) THEN
        IF (v_year_enrolled <> v_course_year_last_enr) THEN
          v_course_year_last_enr := v_year_enrolled;
          v_course_sem_last_enr := v_semester_enrolled;
        ELSE
          IF (v_semester_enrolled > v_course_sem_last_enr) THEN
            v_course_sem_last_enr := v_semester_enrolled;
          END IF;
        END IF;
      END IF;
      -- Subject Weighting
      --------------------
      v_sua_eftsu := 0.000;
      -- We need to find the load calendars that should be
      -- used against the teaching calendars we have from
      -- the IGS_EN_SU_ATTEMPT records.
      FOR v_cir_cat_rec IN c_cir_cat(
            v_sua_sca_rec.cal_type,
            v_sua_sca_rec.ci_sequence_number) LOOP
        IF (IGS_EN_PRC_LOAD.enrp_get_load_incur(
              v_sua_sca_rec.cal_type,
              v_sua_sca_rec.ci_sequence_number,
              v_sua_sca_rec.discontinued_dt,
              v_sua_sca_rec.administrative_unit_status,
              v_sua_sca_rec.unit_attempt_status,
                            v_sua_sca_rec.no_assessment_ind,
              v_cir_cat_rec.sub_cal_type,
              v_cir_cat_rec.sub_ci_sequence_number,
              -- anilk, Audit special fee
              NULL, -- for p_uoo_id
              'N') = 'Y') THEN
          v_sua_eftsu := v_sua_eftsu +
              IGS_EN_PRC_LOAD.enrp_clc_sua_eftsu(
                  v_sua_sca_rec.person_id,
                  v_sua_sca_rec.course_cd,
                  v_sua_sca_rec.course_version_number,
                  v_sua_sca_rec.unit_cd,
                  v_sua_sca_rec.unit_version_number,
                  v_sua_sca_rec.cal_type,
                  v_sua_sca_rec.ci_sequence_number,
                  v_sua_sca_rec.uoo_id,
                  v_cir_cat_rec.sub_cal_type,
                  v_cir_cat_rec.sub_ci_sequence_number,
                  v_sua_sca_rec.override_enrolled_cp,
                  v_sua_sca_rec.override_eftsu,
                  'Y',
                  NULL,
                                                                        NULL,
                                                                        NULL,
                  v_credit_points,
                  -- anilk, Audit special fee build
                  'N'); -- out NOCOPY
        END IF;
      END LOOP;
      -- Add the EFTSU for the sua to the total for the sca.
      v_sca_total_eftsu := v_sca_total_eftsu + v_sua_eftsu;
      v_s_result_type := IGS_AS_GEN_003.assp_get_sua_grade(
                v_sua_sca_rec.person_id,
                v_sua_sca_rec.course_cd,
                v_sua_sca_rec.unit_cd,
                v_sua_sca_rec.cal_type,
                v_sua_sca_rec.ci_sequence_number,
                v_sua_sca_rec.unit_attempt_status,
                'Y',
                v_grading_schema_cd,  -- out NOCOPY
                v_gs_version_number,  -- out NOCOPY
                v_grade,
                                v_sua_sca_rec.uoo_id);    -- out NOCOPY
      IF (v_s_result_type IS NOT NULL AND
          v_s_result_type = cst_withdrawn) THEN
        v_subject_completion_code := 1;
      ELSIF (v_s_result_type IS NOT NULL AND
          v_s_result_type = cst_fail) THEN
        v_subject_completion_code := 2;
      ELSIF (v_s_result_type IS NOT NULL AND
          v_s_result_type = cst_pass) THEN
        v_subject_completion_code := 3;
      ELSE
        v_subject_completion_code := 4;
      END IF;
      -- Subject grade comes from v_grade from IGS_AS_GEN_003.assp_get_sua_grade() above.
      OPEN c_di_ud(
        v_sua_sca_rec.unit_cd,
        v_sua_sca_rec.unit_version_number);
      FETCH c_di_ud INTO v_govt_discipline_group_cd;
      CLOSE c_di_ud;
      IF (v_govt_discipline_group_cd IS NOT NULL) THEN
        v_number_ind := TRUE;
        FOR i IN 1..LENGTH(v_govt_discipline_group_cd) LOOP
          IF (SUBSTR(v_govt_discipline_group_cd, i, 1) NOT IN
              ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')) THEN
            v_number_ind := FALSE;
          END IF;
        END LOOP;
        IF (v_number_ind = TRUE) THEN
          -- v_govt_discipline_group_cd is a number
          v_subject_discipline_group := IGS_GE_NUMBER.TO_NUM(v_govt_discipline_group_cd);
        ELSE
          -- v_govt_discipline_group_cd is not a number
          v_subject_discipline_group := NULL;
        END IF;
      END IF;
      v_output_subject := cst_subject_rec_type ||
          RPAD(v_sua_sca_rec.unit_cd, 10) ||
          RPAD(v_sua_sca_rec.unit_title, 36) ||
          TO_CHAR(TO_DATE(v_year_enrolled, 'YYYY'), 'YY') ||
          ' ' || -- unused space
          LTRIM(TO_CHAR(v_semester_enrolled, '0')) || -- should not be null
          LTRIM(TO_CHAR(v_sua_eftsu, '000V000')) ||
          RPAD(NVL(v_grade, ' '), 6) ||
          IGS_GE_NUMBER.TO_CANN(v_subject_completion_code) ||
          LTRIM(TO_CHAR(NVL(v_subject_discipline_group, 0), '0000')) ||
          fnd_global.newline;
      v_subject_cnt := v_subject_cnt + 1;
      t_subject(v_subject_cnt) := v_output_subject;
    END LOOP;
    -- Write course header only if student is enrolled in a course
    IF (v_last_course_cd IS NOT NULL) THEN
      admpl_write_course_header(
            v_last_course_cd,
            v_course_title,
            v_govt_field_of_study,
            v_govt_course_type,
            v_honours_flag,
            v_exclusion_flag,
            v_all_subjects_inc_flag,
            v_course_completed_flag,
            v_course_year_first_enr,
            v_course_year_last_enr,
            v_course_sem_first_enr,
            v_course_sem_last_enr,
            v_sca_total_eftsu);
      FOR i IN 1..v_subject_cnt LOOP
        UTL_FILE.PUT(fp_output, t_subject(i));
        UTL_FILE.FFLUSH(fp_output);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_write_student_details');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_write_student_details;
  FUNCTION admpl_prc_previous_header (
    p_previous_name_records_cnt IN  NUMBER,
    p_number_of_matches   IN OUT NOCOPY NUMBER)
  RETURN BOOLEAN
  IS
    cst_standard      CONSTANT  VARCHAR2(10) := 'STANDARD';
    cst_exact_id      CONSTANT  VARCHAR2(10) := 'EXACT_ID';
    cst_any_id      CONSTANT  VARCHAR2(10) := 'ANY_ID';
    cst_exact_name      CONSTANT  VARCHAR2(10) := 'EXACT_NAME';
    cst_loose_name      CONSTANT  VARCHAR2(10) := 'LOOSE_NAME';
    cst_any_name      CONSTANT  VARCHAR2(10) := 'ANY_NAME';
    v_number_of_matches   NUMBER(4);
    v_matching_level    VARCHAR2(10);
    v_convert_id      VARCHAR2(10);
    v_convert_birth_dt      DATE;
    v_tmp_birth_dt      VARCHAR2(8);
    v_convert_family_name   VARCHAR2(20);
    v_convert_first_name    VARCHAR2(15);
    v_convert_second_name   VARCHAR2(15);
    v_output_header_reason_code VARCHAR2(2);
    v_reason_C_exists   BOOLEAN;
    v_reason_O_exists   BOOLEAN;
    v_output_header     VARCHAR2(83);
  BEGIN -- admpl_prc_previous_header
    -- Process previous header (3)
    -- Convert data to match against
    v_convert_id := admpl_strip_spaces(r_header_rec.student_id);
    -- Check if convert_id contains non-numeric characters
    IF (admpl_chk_non_num(v_convert_id) = TRUE) THEN
      v_convert_id := 9999999999;
      -- we still need to keep processing the student as
      -- it does not need to match the ID in all cases.
    END IF;
    -- Check if birth_dt contains non-numeric characters
    IF (admpl_chk_non_num(r_header_rec.dob) = TRUE) THEN
      v_tmp_birth_dt := '01/01/01';
    ELSE
      v_tmp_birth_dt := SUBSTR(r_header_rec.dob, 1, 2) || '/' ||
          SUBSTR(r_header_rec.dob, 3, 2) || '/' ||
          SUBSTR(r_header_rec.dob, 5, 2);
    END IF;
    -- At present, we can only convert this with a 2 digit year
    -- as the TAC has only given us 2 digits.
    v_convert_birth_dt := TO_DATE(v_tmp_birth_dt, 'DD/MM/YY'); --??
    v_convert_family_name := admpl_strip_non_alpha(r_header_rec.family_name);
    v_convert_first_name := admpl_strip_non_alpha(r_header_rec.first_name);
    v_convert_second_name := admpl_strip_non_alpha(r_header_rec.second_name);
    IF (p_previous_name_records_cnt > 0) THEN
      FOR i IN 1..p_previous_name_records_cnt LOOP
        r_previous_name_rec := t_previous_name(i);
        r_previous_name_rec.family_name := admpl_strip_non_alpha(
                  r_previous_name_rec.family_name);
        r_previous_name_rec.first_name := admpl_strip_non_alpha(
                  r_previous_name_rec.first_name);
        r_previous_name_rec.second_name := admpl_strip_non_alpha(
                  r_previous_name_rec.second_name);
        t_previous_name(i) := r_previous_name_rec;
        END LOOP;
    END IF;
    -- Match student records
    ------------------------
    -- Clear PLSQL table of matched ID's.
    t_matched_ids := t_matched_ids_clear;
    p_number_of_matches := 0;
    v_matching_level := admpl_strip_spaces(r_header_rec.matching_level);
    IF (v_matching_level = cst_standard) THEN
      -- Call match_standard
      admpl_match_standard(
          v_convert_id,
          v_convert_family_name,
          v_convert_birth_dt,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = cst_exact_id) THEN
      -- Call match_exact_id
      admpl_match_exact_id(
          v_convert_id,
          v_convert_family_name,
          v_convert_birth_dt,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = cst_any_id) THEN
      -- Call match_any_id
      admpl_match_any_id(
          v_convert_id,
          v_convert_family_name,
          v_convert_birth_dt,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = cst_exact_name) THEN
      -- Call match_exact_name
      admpl_match_exact_name(
          v_convert_family_name,
          v_convert_birth_dt,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = cst_loose_name) THEN
      -- Call match_loose_name
      admpl_match_loose_name(
          v_convert_family_name,
          v_convert_birth_dt,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = cst_any_name) THEN
      -- Call match_any_name
      admpl_match_any_name(
          v_convert_family_name,
          v_convert_birth_dt,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = '1') THEN
      -- Call match_criteria1
      admpl_match_criteria1(
          v_convert_id,
          v_convert_family_name,
          v_convert_birth_dt,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = '2') THEN
      -- Call match_criteria2
      admpl_match_criteria2(
          v_convert_id,
          v_convert_birth_dt,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = '3') THEN
      -- Call match_criteria3
      admpl_match_criteria3(
          v_convert_id,
          v_convert_family_name,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = '4') THEN
      -- Call match_criteria4
      admpl_match_criteria4(
          v_convert_id,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = '4a') THEN
      -- Call match_criteria4a
      admpl_match_criteria4a(
          v_convert_id,
          v_convert_birth_dt,
          p_number_of_matches);
    ELSIF (v_matching_level = '5') THEN
      -- Call match_criteria5
      admpl_match_criteria5(
          v_convert_id,
          p_number_of_matches);
    ELSIF (v_matching_level = '6') THEN
      -- Call match_criteria6
      admpl_match_criteria6(
          v_convert_family_name,
          v_convert_birth_dt,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = '7') THEN
      -- Call match_criteria7
      admpl_match_criteria7(
          v_convert_birth_dt,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = '8') THEN
      -- Call match_criteria8
      admpl_match_criteria8(
          v_convert_family_name,
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = '9') THEN
      -- Call match_criteria9
      admpl_match_criteria9(
          v_convert_first_name,
          v_convert_second_name,
          p_number_of_matches);
    ELSIF (v_matching_level = '10') THEN
      -- Call match_criteria10
      admpl_match_criteria10(
          v_convert_family_name,
          v_convert_birth_dt,
          p_number_of_matches);
    ELSIF (v_matching_level = '11') THEN
      -- Call match_criteria11
      admpl_match_criteria11(
          v_convert_birth_dt,
          p_number_of_matches);
    ELSE
      Fnd_Message.Set_Name('IGS','IGS_AD_UNEXPECTED_MATCH_LEVEL');
      IGS_GE_MSG_STACK.ADD;
      RETURN FALSE;
    END IF;
    -- Now we have to work out NOCOPY te number_of_matches.
    -- Using the matching routines above, we can write
    -- out NOCOPY the details for the header record in the output file
    -- Set the output_header.reason_code
    -- NB: More than one reason code may exist so we will take the
    -- one with the highest precedence once we find out NOCOPY which ones exist
    v_reason_C_exists := FALSE;
    v_reason_O_exists := FALSE;
    IF (p_number_of_matches > 0) THEN
      FOR i IN 1..p_number_of_matches LOOP
        r_matched_id_rec := t_matched_ids(i);
        IF (r_matched_id_rec.reason_code = 'C') THEN
          v_reason_C_exists := TRUE;
        ELSIF (r_matched_id_rec.reason_code = 'O') THEN
          v_reason_O_exists := TRUE;
        END IF;
      END LOOP;
      IF (v_reason_O_exists = TRUE) THEN
        v_output_header_reason_code := 'O';
      ELSIF (v_reason_C_exists = TRUE) THEN
        v_output_header_reason_code := 'C';
      ELSE
        -- note: Blank is valid and will occur often
        v_output_header_reason_code := ' ';
      END IF;
    ELSE
      v_output_header_reason_code := 'X';
    END IF;
    -- Write out NOCOPY the header record to the output file
    v_output_header := r_header_rec.record_type ||
        LTRIM(TO_CHAR(r_header_rec.institution_code, '0000')) ||
        RPAD(' ', 40) || -- sending IP address is currently not used
        r_header_rec.request_dt ||
        r_header_rec.request_time ||
        r_header_rec.request_cd ||
        r_header_rec.applicant_id ||
        LTRIM(TO_CHAR(r_header_rec.campus_cd, '0000')) ||
        RPAD(v_output_header_reason_code, 2) ||
        fnd_global.newline;
    UTL_FILE.PUT(fp_output, v_output_header);
    UTL_FILE.FFLUSH(fp_output);
    -- Now we need to loop through the PLSQL table of matched ID's again
    -- and write out NOCOPY all the details for each matched student.
    FOR i IN 1..p_number_of_matches LOOP
      r_matched_id_rec := t_matched_ids(i);
      admpl_write_student_details(
            r_matched_id_rec.person_id,
            r_matched_id_rec.basis_of_match,
            r_matched_id_rec.reason_code);
    END LOOP;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_prc_previous_header');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_prc_previous_header;
---------------
---------------
  PROCEDURE admpl_store_rec (
    p_record_type     IN  VARCHAR2,
    p_input_string      IN  VARCHAR2,
    p_previous_name_records_cnt IN OUT NOCOPY NUMBER)
  IS
    v_previous_name_records_cnt   NUMBER(2);
  BEGIN -- admpl_store_rec
    -- Store records in structures
    IF (p_record_type = 'H') THEN
      -- Breack v_input_string up and store in
      -- structure based on input file header record.
      r_header_rec.record_type := p_record_type;
      r_header_rec.institution_code := SUBSTR(p_input_string, 2, 4);
      r_header_rec.return_ip_addr := SUBSTR(p_input_string, 6, 40);
      r_header_rec.request_dt := SUBSTR(p_input_string, 46, 6);
      r_header_rec.request_time := SUBSTR(p_input_string, 52, 6);
      r_header_rec.request_cd := SUBSTR(p_input_string, 58, 10);
      r_header_rec.matching_level := SUBSTR(p_input_string, 68, 10);
      r_header_rec.applicant_id := SUBSTR(p_input_string, 78, 9);
      r_header_rec.campus_cd := SUBSTR(p_input_string, 87, 4);
      r_header_rec.student_id := SUBSTR(p_input_string, 91, 10);
      r_header_rec.family_name := SUBSTR(p_input_string, 101, 20);
      r_header_rec.first_name := SUBSTR(p_input_string, 121, 15);
      r_header_rec.second_name := SUBSTR(p_input_string, 136, 15);
      r_header_rec.sex := SUBSTR(p_input_string, 151, 1);
      r_header_rec.dob := SUBSTR(p_input_string, 152, 6);
    ELSIF (p_record_type = 'P') THEN
      -- Breack v_input_string up and store in
      -- structure based on input file previous name record.
      r_previous_name_rec.record_type := p_record_type;
      r_previous_name_rec.family_name := SUBSTR(p_input_string, 2, 20);
      r_previous_name_rec.first_name := SUBSTR(p_input_string, 22, 15);
      r_previous_name_rec.second_name := SUBSTR(p_input_string, 37, 15);
      p_previous_name_records_cnt := p_previous_name_records_cnt + 1;
      t_previous_name(p_previous_name_records_cnt) := r_previous_name_rec;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_store_rec');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_store_rec;
---------------
---------------
  PROCEDURE admpl_read_rec (
    p_record_type   OUT NOCOPY  VARCHAR2,
    p_input_string    OUT NOCOPY  VARCHAR2)
  IS
    v_input_string    VARCHAR2(158);
    v_first_char    VARCHAR2(1);
  BEGIN -- admpl_read_rec
    -- Read record from input file and return record type.
    UTL_FILE.GET_LINE(fp_input, v_input_string);
    p_input_string := v_input_string;
    -- Get the first character from v_input_string
    v_first_char := SUBSTR(v_input_string, 1, 1);
    IF (v_first_char = 'H') THEN
      p_record_type := 'H';
      IF (LENGTH(v_input_string) <> 157) THEN
        Fnd_Message.Set_Name('IGS','IGS_AD_HDR_REC_LEN_NOT_CORRECT');
        IGS_GE_MSG_STACK.ADD;
        p_record_type := 'X';
      END IF;
    ELSIF (v_first_char = 'P') THEN
      p_record_type := 'P';
      IF (LENGTH(v_input_string) <> 51) THEN
        Fnd_Message.Set_Name('IGS','IGS_AD_PRE_NM_REC_LEN_NOT_CRCT');
        IGS_GE_MSG_STACK.ADD;
        p_record_type:= 'X';
      END IF;
    ELSE
      Fnd_Message.Set_Name('IGS','IGS_GE_UNKNOWN_REC_TYPE');
      IGS_GE_MSG_STACK.ADD;
      p_record_type := 'X';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_record_type := 'F';
      RETURN;
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admpl_read_rec');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END admpl_read_rec;
---------------
---------------
BEGIN
  -- initialise variables
  v_previous_name_records_cnt := 0;
  t_previous_name := t_previous_name_clear;
  v_number_of_matches := 0;
  t_matched_ids := t_matched_ids_clear;
  -- Validate parameters and open files.
  IF (p_input_file IS NULL) THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    RETURN;
  END IF;
  IF (p_output_file IS NULL) THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    RETURN;
  END IF;
  IF (p_directory IS NULL) THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    RETURN;
  END IF;
  -- Open input file
  BEGIN
    fp_input := UTL_FILE.FOPEN(p_directory, p_input_file, 'R');
  EXCEPTION
    WHEN UTL_FILE.INVALID_OPERATION THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNABLE_READ_FILE');
      IGS_GE_MSG_STACK.ADD;
      RETURN;
  END;
  -- Open output file
  BEGIN
    fp_output := UTL_FILE.FOPEN(p_directory, p_output_file, 'W');
  EXCEPTION
    WHEN UTL_FILE.INVALID_OPERATION THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_FAILED_TO_CREATE_FILE');
      IGS_GE_MSG_STACK.ADD;
      RETURN;
  END;
  -- Call to function to read from file and return record type.
  admpl_read_rec(
      v_record_type,
      v_input_string);
  IF (v_record_type = 'X') THEN
    UTL_FILE.FCLOSE(fp_input);
    UTL_FILE.FCLOSE(fp_output);
    RETURN;
  ELSIF (v_record_type <> 'H') THEN
    Fnd_Message.Set_Name('IGS','IGS_AD_FIRST_REC_MUST HDR_REC');
    IGS_GE_MSG_STACK.ADD;
    UTL_FILE.FCLOSE(fp_input);
    UTL_FILE.FCLOSE(fp_output);
    RETURN;
  ELSE
    admpl_store_rec(
        v_record_type,
        v_input_string,
        v_previous_name_records_cnt);
  END IF;
  LOOP
    -- Call to function to read from file and return record type (1)
    admpl_read_rec(
        v_record_type,
        v_input_string);
    IF (v_record_type = 'H') THEN
      -- Process previous header (3)
      IF (admpl_prc_previous_header(
            v_previous_name_records_cnt,
            v_number_of_matches) = FALSE) THEN
        RETURN;
      END IF;
      -- Store new header record in structure (2)
      admpl_store_rec(
          v_record_type,
          v_input_string,
          v_previous_name_records_cnt);
      v_previous_name_records_cnt := 0;
    ELSIF (v_record_type = 'P') THEN
      -- Store previous name record in structure (2)
      admpl_store_rec(
          v_record_type,
          v_input_string,
          v_previous_name_records_cnt);
      IF (v_previous_name_records_cnt >= 20) THEN
        Fnd_Message.Set_Name('IGS','IGS_AD_TOO_MANY_PRE_NM_REC');
        IGS_GE_MSG_STACK.ADD;
        EXIT;
      END IF;
    ELSIF (v_record_type = 'F') THEN
      -- Process previous header (3)
      IF (admpl_prc_previous_header(
            v_previous_name_records_cnt,
            v_number_of_matches) = FALSE) THEN
        RETURN;
      END IF;
      EXIT;
    ELSIF (v_record_type = 'X') THEN
      EXIT;
    ELSE
      Fnd_Message.Set_Name('IGS','IGS_GE_UNKNOWN_REC_TYPE');
      IGS_GE_MSG_STACK.ADD;
      EXIT;
    END IF;
  END LOOP;
  UTL_FILE.FCLOSE(fp_input);
  UTL_FILE.FCLOSE(fp_output);
END;
EXCEPTION
  WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admp_ext_tac_arts');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
END admp_ext_tac_arts;
Procedure Admp_Ext_Vtac_Return(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY NUMBER,
  p_acad_perd IN VARCHAR2,
  p_input_file IN VARCHAR2,
  p_org_id IN NUMBER)
IS
  p_acad_cal_type   igs_ca_inst.cal_type%type;
  p_acad_ci_sequence_number   igs_ca_inst.sequence_number%type ;
BEGIN -- admp_ext_vtac_return
  --Block for Parameter Validation/Splitting of Parameters

    -- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
    igs_ge_gen_003.set_org_id(null);

    retcode:=0;
  DECLARE
    invalid_parameter   EXCEPTION;
  BEGIN
    p_acad_cal_type          := RTRIM(SUBSTR(p_acad_perd, 101, 10));
    p_acad_ci_sequence_number := IGS_GE_NUMBER.TO_NUM(RTRIM(SUBSTR(p_acad_perd, 112, 6)));
  END;
  --End of Block for Parameter Validation/Splitting of Parameters
  --This module will read the VTAC enrolment return file, retrieve enrolment
  --information for the student by calling IGS_AD_GEN_010.ADMP_GET_TAC_RETURN and then write
  --out the new details to a new file in the required TAC format
DECLARE
  fp_input    UTL_FILE.FILE_TYPE;
  v_tmp_dir   VARCHAR2(80);
  v_message_name      VARCHAR2(30);
  --Vars to hold the respective components of the input string
  v_vtac_number   VARCHAR2(9);
  v_surname   VARCHAR2(24);
  v_gname1    VARCHAR2(17);
  v_gname2    VARCHAR2(17);
  v_category    VARCHAR2(3);
  v_vtac_course_cd  VARCHAR2(5);
  v_street    VARCHAR2(25);
  v_suburb    VARCHAR2(25);
  v_state     VARCHAR2(3);
  v_postcode    VARCHAR2(4);
  v_country   VARCHAR2(14);
  v_enrol_ind   VARCHAR2(1);
  v_round_no    VARCHAR2(1);
  v_accept_ind    VARCHAR2(1);
  v_birth_date    VARCHAR2(8);
  --Variables to pass to external functions OUT NOCOPY vars
  v_offer_response  VARCHAR2(10);
  v_enrol_status    VARCHAR2(10);
  v_attendance_type IGS_EN_ATD_TYPE.govt_attendance_type%TYPE;
  v_attendance_mode IGS_EN_ATD_MODE.govt_attendance_mode%TYPE;
  --Define a function for reading the input file. This needs to
  --handle the exception when end of file is reached
  FUNCTION admpl_read_input
  RETURN BOOLEAN
  IS
    v_input_string    VARCHAR2(255);
  BEGIN --admpl_read_input
        --this sub program reads the input file and splits up the
        --input string into the required components
    UTL_FILE.GET_LINE(fp_input, v_input_string);
        --split up the input string into its respective components
    v_vtac_number   := RTRIM(SUBSTR(v_input_string, 1, 9));
    v_surname   := RTRIM(SUBSTR(v_input_string, 10, 24));
    v_gname1    := RTRIM(SUBSTR(v_input_string, 34, 17));
    v_gname2    := RTRIM(SUBSTR(v_input_string, 51, 17));
    v_category    := RTRIM(SUBSTR(v_input_string, 68, 3));
    v_vtac_course_cd  := RTRIM(SUBSTR(v_input_string, 71, 5));
    v_street      := RTRIM(SUBSTR(v_input_string, 76, 25));
    v_suburb      := RTRIM(SUBSTR(v_input_string, 101, 25));
    v_state     := RTRIM(SUBSTR(v_input_string, 126, 3));
    v_postcode    := RTRIM(SUBSTR(v_input_string, 129, 4));
    v_country   := RTRIM(SUBSTR(v_input_string, 133, 14));
    v_enrol_ind   := RTRIM(SUBSTR(v_input_string, 147, 1));
    v_round_no    := RTRIM(SUBSTR(v_input_string, 148, 1));
    v_accept_ind    := RTRIM(SUBSTR(v_input_string, 149, 1));
    v_birth_date    := SUBSTR(v_input_string, 150, 8);
    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      UTL_FILE.FCLOSE(fp_input);
      RETURN FALSE;
    WHEN UTL_FILE.READ_ERROR THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNABLE_READ_FILE');
        IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN FALSE;
  END admpl_read_input;
  -- Define a procedure for writing the output file.
  -- The output file format is the same
  --as the input file. We only need to change the value of one field,
  -- enrol_ind.  All other fields can be copied directly from the input file.
  PROCEDURE admpl_write_output (v_new_enrol_ind VARCHAR2)
  IS
    v_output_string   VARCHAR2(255);
  BEGIN --admpl_write_output
    --Create the output string
    v_output_string :=
      RPAD(NVL(v_vtac_number, ' '), 9)  ||
      RPAD(NVL(v_surname, ' '), 24) ||
      RPAD(NVL(v_gname1, ' '), 17)    ||
      RPAD(NVL(v_gname2, ' '), 17)    ||
      RPAD(NVL(v_category, ' '), 3)   ||
      RPAD(NVL(v_vtac_course_cd, ' '), 5) ||
      RPAD(NVL(v_street, ' '), 25)    ||
      RPAD(NVL(v_suburb, ' '), 25)    ||
      RPAD(NVL(v_state, ' '), 3)    ||
      RPAD(NVL(v_postcode, ' '), 4)   ||
      RPAD(NVL(v_country, ' '), 14)   ||
      RPAD(NVL(v_new_enrol_ind, ' '), 1)  ||
      RPAD(NVL(v_round_no, ' '), 1)   ||
      RPAD(NVL(v_accept_ind, ' '), 1) ||
      RPAD(NVL(v_birth_date, ' '), 8);
    --Write the output string to file
    FND_FILE.PUT_LINE( FND_FILE.OUTPUT, v_output_string);
  END admpl_write_output;
BEGIN
  --Validate parameters (all must have values)
  IF (p_acad_cal_type IS NULL OR
      p_acad_ci_sequence_number IS NULL OR
      p_input_file      IS NULL) THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
  END IF;
  fnd_profile.get('IGS_IN_FILE_PATH',v_tmp_dir);
  --Open input file
  BEGIN
    fp_input := UTL_FILE.FOPEN(v_tmp_dir, p_input_file, 'R');
  EXCEPTION
    WHEN UTL_FILE.INVALID_OPERATION THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNABLE_READ_FILE');
        IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    WHEN UTL_FILE.INVALID_PATH THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNABLE_READ_FILE');
        IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END;
  WHILE admpl_read_input LOOP
    IF (v_vtac_number IS NULL OR
        v_vtac_course_cd IS NULL) THEN
      admpl_write_output('X');
    ELSIF (IGS_AD_GEN_010.ADMP_GET_TAC_RETURN(
        v_vtac_number,
        v_surname,
        v_gname1,
        v_gname2,
        v_vtac_course_cd,
        p_acad_cal_type,
        p_acad_ci_sequence_number,
        v_offer_response,
        v_enrol_status,
        v_attendance_type,
        v_attendance_mode,
        v_message_name) = FALSE) THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, v_vtac_number ||' '|| v_vtac_course_cd ||' '||
      fnd_message.get_string('IGS',v_message_name));
      admpl_write_output('X');
    ELSE
      IF (v_enrol_status = 'ENROLLED') THEN
        IF (v_attendance_type = '1') THEN
          admpl_write_output('F');
        ELSE
          admpl_write_output('P');
        END IF;
      ELSIF (v_enrol_status = 'NOT-ENROL') THEN
        IF (v_offer_response = 'DFR-GRANT') THEN
          admpl_write_output('D');
        ELSE
          admpl_write_output('X');
        END IF;
      ELSIF (v_enrol_status = 'INTERMIT') THEN
        IF (v_attendance_type = '1') THEN
          admpl_write_output('F');
        ELSIF (v_attendance_type = '2') THEN
          admpl_write_output('P');
        ELSE
          admpl_write_output('E');
        END IF;
      ELSIF(v_enrol_status = 'DISCONTIN') THEN
        IF (v_attendance_type = '1') THEN
          admpl_write_output('F');
        ELSIF (v_attendance_type = '2') THEN
          admpl_write_output('P');
        ELSE
          admpl_write_output('E');
        END IF;
      ELSE
        admpl_write_output('X');
      END IF;
    END IF;
  END LOOP;
  --Close all files
  UTL_FILE.FCLOSE_ALL;
  RETURN;
END;
EXCEPTION
  WHEN OTHERS THEN
    Retcode := 2;
    errbuf  :=  fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END admp_ext_vtac_return;
Function Admp_Get_Aal_Sent_Dt(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER )
RETURN DATE IS
BEGIN -- This module retrieves the issue date for an Admission Application
  -- Letter
  -- admp_get_aal_sent_dt
DECLARE
  cst_spl_seqnum    CONSTANT VARCHAR2(10) := 'SPL_SEQNUM';
  v_spl_sequence_number IGS_AD_APPL_LTR.spl_sequence_number%TYPE;
  v_issue_dt    IGS_CO_OU_CO_REF.issue_dt%TYPE;
  CURSOR c_aal IS
    SELECT  spl_sequence_number
    FROM  IGS_AD_APPL_LTR
    WHERE person_id     = p_person_id AND
      admission_appl_number   = p_admission_appl_number AND
      correspondence_type   = p_correspondence_type AND
      sequence_number   = p_sequence_number;
  CURSOR c_ocr (
    p_person_id   IGS_AD_APPL_LTR.person_id%TYPE,
    p_correspondence_type IGS_AD_APPL_LTR.correspondence_type%TYPE,
    cp_spl_sequence_number  IGS_AD_APPL_LTR.spl_sequence_number%TYPE) IS
    SELECT  issue_dt
    FROM  IGS_CO_OU_CO_REF
    WHERE person_id     = p_person_id AND
      correspondence_type   = p_correspondence_type AND
      s_other_reference_type  = cst_spl_seqnum AND
      other_reference   = IGS_GE_NUMBER.TO_CANN(cp_spl_sequence_number);
BEGIN
  OPEN c_aal;
  FETCH c_aal INTO v_spl_sequence_number;
  IF  (c_aal%FOUND) THEN
    CLOSE c_aal;
    IF v_spl_sequence_number IS NULL THEN
      RETURN NULL;
    ELSE
      OPEN c_ocr(
        p_person_id,
        p_correspondence_type,
        v_spl_sequence_number);
      FETCH c_ocr INTO v_issue_dt;
      IF (c_ocr%NOTFOUND) THEN
        CLOSE c_ocr;
        RETURN NULL;
      ELSE
        CLOSE c_ocr;
        v_issue_dt := TRUNC(v_issue_dt);
        RETURN v_issue_dt;
      END IF;
    END IF;
  END IF;
  CLOSE c_aal;
  RETURN NULL;
END;
EXCEPTION
  WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admp_get_aal_sent_dt');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
END admp_get_aal_sent_dt;
Function Admp_Get_Aa_Aas(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_adm_appl_status IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN -- admp_get_aa_aas
  -- Return the derived admission application status
  -- for an admission application.
  -- Navin Sinha 18-Feb-2002, corrected the datatype of v_s_adm_outcome_status.
  -- Arvind S. This function is modified as a part of igs.m
  -- The overall derviation logic is modified. Withdrawn status is now always a derived value
DECLARE
  CURSOR c_aca IS
    SELECT  --aca.req_for_reconsideration_ind,
      acai.adm_outcome_status,
      acai.adm_offer_resp_status,
      acai.adm_offer_dfrmnt_status,
      acai.appl_inst_status,
      acai.def_term_adm_appl_num,
      acai.def_appl_sequence_num
    FROM  --IGS_AD_PS_APPL    aca,
      IGS_AD_PS_APPL_INST   acai
    WHERE acai.person_id      = p_person_id AND
      acai.admission_appl_number  = p_admission_appl_number;
      --AND aca.person_id     = acai.person_id AND
      --aca.admission_appl_number   = acai.admission_appl_number AND
      --aca.nominated_course_cd   = acai.nominated_course_cd;
  cst_withdrawn   CONSTANT VARCHAR2(10) := 'WITHDRAWN';
  cst_received    CONSTANT VARCHAR2(10) := 'RECEIVED';
  cst_offer   CONSTANT VARCHAR2(10) := 'OFFER';
  cst_cond_offer    CONSTANT VARCHAR2(10) := 'COND-OFFER';
  cst_accepted    CONSTANT VARCHAR2(10) := 'ACCEPTED';
  cst_rejected    CONSTANT VARCHAR2(10) := 'REJECTED';
  cst_lapsed    CONSTANT VARCHAR2(10) := 'LAPSED';
  cst_completed   CONSTANT VARCHAR2(10) := 'COMPLETED';
  cst_voided    CONSTANT VARCHAR2(10) := 'VOIDED';
  cst_no_quota    CONSTANT VARCHAR2(10) := 'NO-QUOTA';
  cst_deferral            CONSTANT VARCHAR2(10) := 'DEFERRAL';
  cst_confirm             CONSTANT VARCHAR2(10) := 'CONFIRM';
  cst_approved    CONSTANT VARCHAR2(10) := 'APPROVED';
        cst_cancelled           CONSTANT VARCHAR2(10) := 'CANCELLED';
  cst_notapplic   CONSTANT VARCHAR2(10) := 'NOT-APPLIC';
  v_received_appl   BOOLEAN DEFAULT FALSE;
  v_withdrawn_appl  BOOLEAN DEFAULT FALSE;
  v_completed_appl  BOOLEAN DEFAULT FALSE;
  v_acai_records_found  BOOLEAN DEFAULT FALSE;
  v_rej_lap   BOOLEAN DEFAULT FALSE;
  v_s_appl_inst_stat    igs_ad_ps_appl_inst.appl_inst_status%TYPE;
  v_s_adm_appl_status     igs_ad_appl_stat.s_adm_appl_status%TYPE;
  v_s_adm_outcome_status    igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  v_s_adm_offer_resp_status igs_ad_ofr_resp_stat.s_adm_offer_resp_status%TYPE;
  -- v_exit_loop      NUMBER DEFAULT 0;
  v_s_adm_offer_dfrmnt_status igs_ad_ofrdfrmt_stat.s_adm_offer_dfrmnt_status%TYPE;
BEGIN
  -- Determine the system admission application status.
  v_s_adm_appl_status := IGS_AD_GEN_007.ADMP_GET_SAAS(p_adm_appl_status);
  -- Derive the admission application status.
    IF v_s_adm_appl_status IN (
          cst_received,
          cst_withdrawn,
          cst_completed) THEN
      -- To decide if the system Applicatiom Status(APS) can be derived to 'WITHDRAWN'
      FOR v_acai_rec IN c_aca LOOP
        IF IGS_AD_GEN_008.ADMP_GET_SAOS(v_acai_rec.adm_outcome_status) IN (cst_offer, cst_cond_offer)
          AND
        IGS_AD_GEN_008.ADMP_GET_SAORS(v_acai_rec.adm_offer_resp_status) NOT IN (cst_rejected, cst_lapsed, cst_notapplic) THEN
          v_rej_lap := TRUE;
          EXIT;
        END IF;
      END LOOP;
      -- Retrieve admission course application instance details.
      FOR v_aca_rec IN c_aca LOOP
        v_acai_records_found := TRUE;
        v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS(
                  v_aca_rec.adm_outcome_status);
        v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS(
                  v_aca_rec.adm_offer_resp_status);
        v_s_adm_offer_dfrmnt_status := IGS_AD_GEN_008.ADMP_GET_SAODS(
                  v_aca_rec.adm_offer_dfrmnt_status);
        v_s_appl_inst_stat := NVL(IGS_AD_GEN_007.ADMP_GET_SAAS(v_aca_rec.appl_inst_status),'-1');
        -- Check if the outcome of the admission course
        -- application instance is complete or has been resolved.
        IF NOT(   v_s_adm_outcome_status IN (cst_cancelled, cst_voided, cst_withdrawn,cst_no_quota, cst_rejected)
            OR
                  (  v_s_adm_outcome_status IN (cst_offer, cst_cond_offer)
               AND
                       (  v_s_adm_offer_resp_status IN (cst_accepted, cst_rejected, cst_lapsed)
                              OR
                        (  v_s_adm_offer_resp_status IN (cst_deferral)
               AND
                                   v_s_adm_offer_dfrmnt_status IN (cst_confirm)
                     OR
                     (  v_s_adm_offer_dfrmnt_status IN  (cst_approved)
                  AND
                  (  v_aca_rec.def_term_adm_appl_num IS NOT NULL
                     OR
                     v_aca_rec.def_appl_sequence_num IS NOT NULL
                  )
                     )


                                                )
                     )
                 )
           OR
           (  v_s_appl_inst_stat = cst_withdrawn
           )
              )  THEN
          -- Set a flag indicating that at least one admission
          -- course application instance would make the admission
          -- application not complete, so exit.
          -- Else need to continue looping through all the remaining
          -- admission course application records.
          v_received_appl := TRUE;
        ELSIF (v_s_appl_inst_stat = cst_withdrawn AND v_rej_lap = FALSE) THEN
          v_withdrawn_appl := TRUE;
        ELSE
          v_completed_appl := TRUE;
        END IF;
      END LOOP;
      -- If at least one admission course application instance is in a state that
      -- will make the application received, then return a value of received.
      -- Or if no admission course application instance records exist for the
      -- admission application then also return a value of received.
      IF v_acai_records_found = TRUE THEN
        IF v_received_appl THEN
                IF v_s_adm_appl_status <> cst_received THEN
            RETURN IGS_AD_GEN_008.ADMP_GET_SYS_AAS(cst_received);
                            ELSE
                  RETURN p_adm_appl_status;
                            END IF;
        ELSIF v_withdrawn_appl THEN
          IF v_s_adm_appl_status <> cst_withdrawn THEN
            RETURN IGS_AD_GEN_008.ADMP_GET_SYS_AAS(cst_withdrawn);
          ELSE
            RETURN p_adm_appl_status;
          END IF;
        ELSIF v_completed_appl THEN
          -- If this point is reached then all admission course application
          -- instances must have a resolved outcome or withdrawn and therefore the application
          -- is complete.
                IF v_s_adm_appl_status <> cst_completed THEN
              RETURN IGS_AD_GEN_008.ADMP_GET_SYS_AAS(cst_completed);
                            ELSE
                  RETURN p_adm_appl_status;
          END IF;
        END IF;
                        ELSE
        RETURN p_adm_appl_status; -- no acai record found
      END IF;
    ELSE
      RETURN p_adm_appl_status;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF c_aca%ISOPEN THEN
      CLOSE c_aca;
    END IF;
    App_Exception.Raise_Exception;
END;
EXCEPTION
  WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admp_get_aa_aas');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
END admp_get_aa_aas;
Procedure Admp_Get_Aa_Created(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_create_who OUT NOCOPY VARCHAR2 ,
  p_create_on OUT NOCOPY DATE )
IS
BEGIN -- admp_get_aa_created
  -- Routine to return the date an admission application was created
  -- and the Oracle user name of  the IGS_PE_PERSON that created the admission
  -- application.
DECLARE
  v_create_who  IGS_AD_APPL.LAST_UPDATED_BY%TYPE  DEFAULT NULL;
  v_create_on IGS_AD_APPL.LAST_UPDATE_DATE%TYPE DEFAULT NULL;
  CURSOR c_aah IS
    SELECT  aah.hist_who,
      aah.hist_start_dt
    FROM  IGS_AD_APPL_HIST  aah
    WHERE person_id     = p_person_id AND
      admission_appl_number = p_admission_appl_number
    ORDER BY
      hist_start_dt ASC;
  CURSOR c_aa IS
    SELECT  LAST_UPDATED_BY,
      LAST_UPDATE_DATE
    FROM  IGS_AD_APPL
    WHERE person_id     = p_person_id AND
      admission_appl_number = p_admission_appl_number;
BEGIN
  -- Determine who the admission application was created by and on what date.
  OPEN c_aah;
  FETCH c_aah INTO  v_create_who,
        v_create_on;
  IF (c_aah%NOTFOUND) THEN
    OPEN c_aa;
    FETCH c_aa INTO v_create_who,
        v_create_on;
    CLOSE c_aa;
  END IF;
  CLOSE c_aah;
  p_create_who := v_create_who;
  p_create_on := v_create_on;
END;
EXCEPTION
  WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admp_get_aa_created');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
END admp_get_aa_created;
Procedure Admp_Get_Aa_Dtl(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_admission_cat OUT NOCOPY VARCHAR2 ,
  p_s_admission_process_type OUT NOCOPY VARCHAR2 ,
  p_acad_cal_type OUT NOCOPY VARCHAR2 ,
  p_acad_ci_sequence_number OUT NOCOPY NUMBER ,
  p_adm_cal_type OUT NOCOPY VARCHAR2 ,
  p_adm_ci_sequence_number OUT NOCOPY NUMBER ,
  p_appl_dt OUT NOCOPY DATE ,
  p_adm_appl_status OUT NOCOPY VARCHAR2 ,
  p_adm_fee_status OUT NOCOPY VARCHAR2 )
IS
BEGIN --admp_get_aa_dtl
  --Return admission application details
DECLARE
  v_admission_cat     IGS_AD_APPL.admission_cat%TYPE;
  v_s_admission_process_type  IGS_AD_APPL.s_admission_process_type%TYPE;
  v_acad_cal_type     IGS_AD_APPL.acad_cal_type%TYPE;
  v_acad_ci_sequence_number IGS_AD_APPL.acad_ci_sequence_number%TYPE;
  v_adm_cal_type      IGS_AD_APPL.adm_cal_type%TYPE;
  v_adm_ci_sequence_number  IGS_AD_APPL.adm_ci_sequence_number%TYPE;
  v_appl_dt       IGS_AD_APPL.appl_dt%TYPE;
  v_adm_appl_status   IGS_AD_APPL.adm_appl_status%TYPE;
  v_adm_fee_status      IGS_AD_APPL.adm_fee_status%TYPE;
  CURSOR c_aa IS
    SELECT  aa.admission_cat,
      aa.s_admission_process_type,
      aa.acad_cal_type,
      aa.acad_ci_sequence_number,
      aa.adm_cal_type,
      aa.adm_ci_sequence_number,
      aa.appl_dt,
      aa.adm_appl_status,
      aa.adm_fee_status
    FROM  IGS_AD_APPL aa
    WHERE aa.person_id      = p_person_id AND
      aa.admission_appl_number  = p_admission_appl_number;
BEGIN
  OPEN c_aa;
  FETCH c_aa INTO v_admission_cat,
      v_s_admission_process_type,
      v_acad_cal_type,
      v_acad_ci_sequence_number,
      v_adm_cal_type,
      v_adm_ci_sequence_number,
      v_appl_dt,
      v_adm_appl_status,
      v_adm_fee_status;
  IF (c_aa%NOTFOUND) THEN
    p_admission_cat       := NULL;
    p_s_admission_process_type  := NULL;
    p_acad_cal_type     := NULL;
    p_acad_ci_sequence_number := NULL;
    p_adm_cal_type      := NULL;
    p_adm_ci_sequence_number  := NULL;
    p_appl_dt     := NULL;
    p_adm_appl_status   := NULL;
    p_adm_fee_status      := NULL;
  ELSE
    p_admission_cat     := v_admission_cat;
    p_s_admission_process_type  := v_s_admission_process_type;
    p_acad_cal_type     := v_acad_cal_type;
    p_acad_ci_sequence_number := v_acad_ci_sequence_number;
    p_adm_cal_type      := v_adm_cal_type;
    p_adm_ci_sequence_number  := v_adm_ci_sequence_number;
    p_appl_dt     := v_appl_dt;
    p_adm_appl_status   := v_adm_appl_status;
    p_adm_fee_status      := v_adm_fee_status;
  END IF;
  CLOSE c_aa;
END;
EXCEPTION
  WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admp_get_aa_dtl');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
END admp_get_aa_dtl;
Function Admp_Get_Acai_Acadcd(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER )
RETURN VARCHAR2 IS
BEGIN -- admp_get_acai_acadcd
  -- routine to return the academic alternate code of the Admission Application
  -- relating  the Admission course Application Instance admission period.
DECLARE
  CURSOR c_aa IS
    SELECT  aa.acad_cal_type
    FROM  IGS_AD_APPL aa
    WHERE person_id       = p_person_id AND
      admission_appl_number = p_admission_appl_number;
  CURSOR c_cir (
      cp_acad_cal_type  IN  IGS_AD_APPL.acad_cal_type%TYPE,
      cp_adm_cal_type   IN  IGS_AD_PS_APPL_INST.adm_cal_type%TYPE,
      cp_adm_ci_sequence_number IN
        IGS_AD_PS_APPL_INST.adm_ci_sequence_number%TYPE) IS
    SELECT  ci.alternate_code, ci.start_dt
    FROM  IGS_CA_INST_REL cir,
      IGS_CA_INST ci
    WHERE cir.sup_cal_type    = cp_acad_cal_type AND
      cir.sub_cal_type    = cp_adm_cal_type AND
      cir.sub_ci_sequence_number  = cp_adm_ci_sequence_number AND
      cir.sup_cal_type    = ci.cal_type AND
      cir.sup_ci_sequence_number  = ci.sequence_number
                ORDER BY ci.start_dt;
  v_acad_cal_type   IGS_AD_APPL.acad_cal_type%TYPE;
  v_alternate_code  IGS_CA_INST.alternate_code%TYPE;
        v_start_dt              IGS_CA_INST.start_dt%TYPE;
BEGIN
  IF p_acad_cal_type IS NULL THEN
    OPEN c_aa;
    FETCH c_aa INTO v_acad_cal_type;
    IF (c_aa%NOTFOUND) THEN
      CLOSE c_aa;
      RETURN NULL;
    END IF;
    CLOSE c_aa;
  ELSE
    v_acad_cal_type := p_acad_cal_type;
  END IF;
  OPEN c_cir (  v_acad_cal_type,
      p_adm_cal_type,
      p_adm_ci_sequence_number);
  FETCH c_cir INTO v_alternate_code,v_start_dt;
  IF (c_cir%NOTFOUND) THEN
    CLOSE c_cir;
    RETURN NULL;
  ELSE
    CLOSE c_cir;
    RETURN v_alternate_code;
  END IF;
END;
EXCEPTION
  WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admp_get_acai_acadcd');
END admp_get_acai_acadcd;
Function Admp_Get_Acai_Aos_Dt(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN DATE IS
BEGIN -- admp_get_acai_aos_dt
  -- This module gets the date that the current
  -- IGS_AD_PS_APPL_INST.adm_outcome_status was set.
DECLARE
        v_decision_date IGS_AD_PS_APPL_INST.decision_date%TYPE;
  CURSOR c_acai IS
    SELECT  acai.decision_date
    FROM  IGS_AD_PS_APPL_INST acai
    WHERE acai.person_id      = p_person_id AND
      acai.admission_appl_number  = p_admission_appl_number AND
      acai.nominated_course_cd  = p_nominated_course_cd AND
      acai.sequence_number    = p_acai_sequence_number AND
      acai.adm_outcome_status IS NOT NULL
    ORDER BY acai.decision_date DESC;
BEGIN
  OPEN c_acai;
  FETCH c_acai INTO v_decision_date;
  CLOSE c_acai;
    RETURN v_decision_date;
END;
EXCEPTION
  WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.admp_get_acai_aos_dt');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
END admp_get_acai_aos_dt;
Procedure ADMS_EXT_TAC_ARTS  (
             errbuf          out NOCOPY  varchar2,
             retcode         out NOCOPY  number,
             p_input_file    IN VARCHAR2,
             p_org_id        IN NUMBER )
IS
v_dir_path    VARCHAR2(255);
v_output_file           VARCHAR2(100);
v_log_message           VARCHAR2(200);
v_length                NUMBER(2);
v_input_file            varchar2(100);
v_last_char             VARCHAR2(1);
BEGIN

-- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
igs_ge_gen_003.set_org_id(null);

retcode  := 0;
v_length := 0;
--Get the In_file_Directory Path
v_dir_path   := nvl(RTRIM(FND_PROFILE.VALUE('IGS_IN_FILE_PATH')),' ');
v_last_char  := SUBSTR(v_dir_path,LENGTH(v_dir_path),1);
IF v_last_char IN ('/','\') THEN    -- '/' To match UNIX & '\' for NT
   v_dir_path := SUBSTR(v_dir_path,1,LENGTH(v_dir_path)-1);
END IF;
--Prepare the Output file name
v_length     := INSTR(p_input_file,'.');
v_input_file := ltrim(rtrim(p_input_file));
IF v_length > 0 THEN
     v_output_file := substr(v_input_file,1,v_length-1);
ELSE
     v_output_file := v_input_file;
END IF;
v_output_file := v_output_file||'.out';
--Now call ADMP_EXT_TAC_ARTS with parameters
IGS_AD_GEN_002.admp_ext_tac_arts(
                           v_input_file ,
                           v_output_file ,
                           v_dir_path );
Exception
     WHEN OTHERS THEN
               ERRBUF:= FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
               IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
               retcode:=2;
END ADMS_EXT_TAC_ARTS;
Function Admp_Get_Appl_ID(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER)
RETURN NUMBER IS
/*******************************************************************************
Created by  : Kedarnath Nag
Date created: 04 OCT 2002
Purpose:
  To get application ID
Known limitations/enhancements and/or remarks:
Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
  CURSOR c_application_id IS
    SELECT application_id
    FROM   igs_ad_appl_all
    WHERE  person_id = p_person_id
    AND    admission_appl_number = p_admission_appl_number;
  l_application_id igs_ad_appl_all.application_id%TYPE;
BEGIN
  IF p_person_id IS NOT NULL AND
     p_admission_appl_number IS NOT NULL THEN
    FOR c_application_id_rec IN c_application_id
    LOOP
      l_application_id := c_application_id_rec.application_id;
    END LOOP;
  END IF;
  RETURN l_application_id;
END Admp_Get_Appl_ID;
Function Admp_Get_Fee_Status(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER)
RETURN VARCHAR2 IS
/*******************************************************************************
Created by  : Kedarnath Nag
Date created: 04 OCT 2002
Modified completely as a part of IGS.M -- arvsrini
Purpose:
  To get application fee status, return Pending if appl fee status not in Paid,Waived,Partial
Known limitations/enhancements and/or remarks:
Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
  l_FeeAmt    igs_ad_appl_all.appl_fee_amt%TYPE :=0;
  l_TotalRemitt   igs_ad_app_req.fee_amount%TYPE :=0;
  l_WaivedTemp    igs_ad_app_req.fee_amount%TYPE :=0;
  lOverallStatus  igs_lookup_values.meaning%TYPE;
CURSOR c_adm_fee_amt IS
  SELECT  appl_fee_amt
  FROM  igs_ad_appl_all
  WHERE person_id = p_person_id
  AND admission_appl_number = p_admission_appl_number;
CURSOR c_appl_fee_status_meaning (p_sys_fee_status igs_ad_code_classes.class%TYPE) IS
  SELECT  meaning
  FROM  igs_lookup_values
  WHERE lookup_type = 'SYS_FEE_STATUS'
  AND lookup_code = p_sys_fee_status;
CURSOR c_fee_amount IS
  SELECT  req.fee_amount,
    cc.system_status fee_status
  FROM  igs_ad_app_req req,
    igs_ad_code_classes cc
  WHERE req.person_id = p_person_id
  AND req.admission_appl_number = p_admission_appl_number
  AND cc.CLASS = 'SYS_FEE_STATUS'
  AND cc.CODE_ID = req.applicant_fee_status
  AND EXISTS (SELECT 'x'
      FROM igs_ad_code_classes
      WHERE class = 'SYS_FEE_TYPE'
      AND system_status = 'APPL_FEE'
      AND req.applicant_fee_type = code_id)
  ORDER BY req.fee_date;
BEGIN
  /* the logic of this function was changed as a part of IGS.M -- arvsrini */
  /* initializing variables*/
  OPEN  c_adm_fee_amt;
  FETCH c_adm_fee_amt INTO l_FeeAmt;
  CLOSE c_adm_fee_amt;
  FOR c_fee_amount_rec IN c_fee_amount LOOP
    l_TotalRemitt:= l_TotalRemitt+ c_fee_amount_rec.fee_amount;
  END LOOP;
  FOR c_fee_amount_rec IN c_fee_amount LOOP
    IF c_fee_amount_rec.fee_status <> 'WAIVED' THEN
      EXIT;
    END IF;
    l_WaivedTemp:= l_WaivedTemp + c_fee_amount_rec.fee_amount;
  END LOOP;
  /*determining status*/
  IF l_FeeAmt= 0 THEN
    lOverallStatus:='PENDING';
  ELSIF l_TotalRemitt >= l_FeeAmt THEN
    IF l_WaivedTemp < l_FeeAmt THEN
        --the sum of fee amount of all WAIVED records
        --before the first record with status <> WAIVED
      lOverallStatus:= 'PAID';
        --this includes cases where full payment was made or cases
        --where a partial payment was made before the rest was waived
    ELSE
      lOverallStatus:='WAIVED';
    END IF;
  ELSE
    lOverallStatus:='PENDING';
  END IF;
  /*obtaining meaning of fee status*/
  IF lOverallStatus IS NOT NULL THEN
    OPEN c_appl_fee_status_meaning (lOverallStatus);
    FETCH c_appl_fee_status_meaning INTO lOverallStatus;
    CLOSE c_appl_fee_status_meaning;
  END IF;
  RETURN lOverallStatus;
END Admp_Get_Fee_Status;
PROCEDURE check_adm_appl_inst_stat(
  p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
  p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
  p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE  DEFAULT NULL,
  p_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE DEFAULT NULL,
  p_updateable VARCHAR2 DEFAULT 'N'                                                 -- apadegal - TD001 - IGS.M.
  ) IS
/*******************************************************************************
Created by  : Kedarnath Nag
Date created: 11 MAR 2003
Purpose:
  To check whether the application details can be added/modified/deleted and
  raise appropriate error incase of failure
Known limitations/enhancements and/or remarks:
Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
  l_adm_outcome_status    igs_ad_ps_appl_inst.adm_outcome_status%TYPE;
  l_adm_appl_status_old   igs_ad_appl.adm_appl_status%TYPE;
  l_adm_appl_status_new   igs_ad_appl.adm_appl_status%TYPE;
  l_appl_inst_status    igs_ad_ps_appl_inst.appl_inst_status%TYPE;
  cst_withdrawn           CONSTANT VARCHAR2(10) := 'WITHDRAWN';
  cst_completed           CONSTANT VARCHAR2(10) := 'COMPLETED';
  cst_cancelled           CONSTANT VARCHAR2(10) := 'CANCELLED';
  CURSOR c_adm_appl_status (cp_person_id igs_ad_appl.person_id%TYPE,
                            cp_admission_appl_number igs_ad_appl.admission_appl_number%TYPE) IS
    SELECT adm_appl_status
    FROM   igs_ad_appl
    WHERE  person_id = cp_person_id
    AND    admission_appl_number = cp_admission_appl_number;
  CURSOR c_adm_outcome_status (cp_person_id igs_ad_ps_appl_inst.person_id%TYPE,
                               cp_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                               cp_nominated_course_cd igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
             cp_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE) IS
    SELECT adm_outcome_status,
     appl_inst_status,              --arvsrini
     def_term_adm_appl_num,
     def_appl_sequence_num
    FROM   igs_ad_ps_appl_inst
    WHERE  person_id = cp_person_id
    AND    admission_appl_number= cp_admission_appl_number
    AND    nominated_course_cd = cp_nominated_course_cd
    AND    sequence_number = cp_sequence_number;

    l_offer_inst      VARCHAR2(1) DEFAULT 'N';
    l_is_inst_complete BOOLEAN     DEFAULT  FALSE  ;
    l_def_term_adm_appl_num  igs_ad_ps_appl_inst.def_term_adm_appl_num%TYPE DEFAULT NULL;
    l_def_appl_sequence_num  igs_ad_ps_appl_inst.def_term_adm_appl_num%TYPE DEFAULT NULL;
BEGIN

  OPEN c_adm_appl_status (p_person_id,
                          p_admission_appl_number
                         );
  FETCH c_adm_appl_status INTO l_adm_appl_status_old;
  CLOSE c_adm_appl_status;
  IF p_nominated_course_cd IS NOT NULL AND
     p_sequence_number IS NOT NULL THEN
    OPEN c_adm_outcome_status (p_person_id,
                               p_admission_appl_number,
                               p_nominated_course_cd,
                               p_sequence_number
                              );
    FETCH c_adm_outcome_status INTO l_adm_outcome_status,l_appl_inst_status,l_def_term_adm_appl_num,l_def_appl_sequence_num;
    CLOSE c_adm_outcome_status;
  END IF;
  -- The Admission Application Status may have been re-derived
  l_adm_appl_status_new := IGS_AD_GEN_002.ADMP_GET_AA_AAS(
                                 p_person_id,
                                 p_admission_appl_number,
                                 l_adm_appl_status_old);

   -------begin  APADEGAL - ADTD001 RE-OPEN BUILD- IGS.M

   IF (check_any_offer_inst (p_person_id,
                             p_admission_appl_number,
                             p_nominated_course_cd,   -- Null if invoked from Appl Instance and its Child TBHS
                             p_sequence_number )      -- Null if invoked from Appl Instance and its Child TBHS

                            )
   THEN
          l_offer_inst := 'Y';           -- Offered/Cond offered instance exists - for data in proceed phase
   END IF;

   IF (p_nominated_course_cd IS NOT NULL and p_sequence_number IS NOT NULL)
   THEN

       IF NVL(IGS_AD_GEN_007.ADMP_GET_SAAS(l_appl_inst_status),'-1') = cst_withdrawn THEN
     fnd_message.set_name('IGS','IGS_AD_APPL_INST_WITHD');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;     -- application instance is withdrawn
       END IF;

       IF Is_App_Inst_Complete( p_person_id,
                                p_admission_appl_number,
                                p_nominated_course_cd,
                                p_sequence_number) = 'Y'              -- application instance is resolved  (logically complete)
       THEN
            l_is_inst_complete := TRUE;
       END IF;

       -- if instance is closed and offered, also new appl is created in Deffered term
       -- then none of the instance's and its child's attributes can be udpated.

       IF ( l_offer_inst = 'Y' AND l_is_inst_complete)
            AND
    (l_def_term_adm_appl_num IS NOT NULL OR  l_def_appl_sequence_num IS NOT NULL)
       THEN
     fnd_message.set_name('IGS','IGS_AD_APPL_INST_COMPL');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
       END IF;

   END IF;
   -------end  APADEGAL - ADTD001 RE-OPEN BUILD- IGS.M



  -- the variable g_pkg_cst_completed_chk is getting populated to a value of 'N' from the package igs_ad_app_req_pkg. So if the package
  -- igs_ad_app_req_pkg calls this procedure the variable g_pkg_cst_completed_chk will be 'N' . For all other cases it will be 'Y'.
  --If this procedure is called from igs_ad_app_req_pkg then the check for complete application should not be performed. -- rghosh(bug#2901627)

  IF NVL(igs_ad_app_req_pkg.g_pkg_cst_completed_chk,'Y') = 'Y'  THEN  -- modified igsm 5301 arvsrini
  IF ( IGS_AD_GEN_007.ADMP_GET_SAAS(l_adm_appl_status_new)  IN (cst_completed, cst_withdrawn)
       OR                                               -- added OR condition for re-open build - ADTD001 - IGS.M
       l_is_inst_complete                   -- appilcation instance is resolved ( logically completed)
     )
     AND                                                -- added AND condition for re-open build - ADTD001 - IGS.M
     ( p_updateable = 'N'  OR  l_offer_inst <> 'Y')     -- either not in proceed phase or not offered/cond offered.

  THEN
     IF (p_nominated_course_cd IS  NULL and p_sequence_number IS NULL)
     THEN
       fnd_message.set_name('IGS','IGS_AD_CANNOT_CHG_APPL_DTL');
     ELSE
         fnd_message.set_name('IGS','IGS_AD_APPL_INST_COMPL');
     END IF;

     igs_ge_msg_stack.add;
     app_exception.raise_exception;
  END IF;
  ELSE
      IF  IGS_AD_GEN_007.ADMP_GET_SAAS(l_adm_appl_status_new) = cst_withdrawn THEN
        fnd_message.set_name('IGS','IGS_AD_CANNOT_CHG_APPL_DTL');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
  END IF;

 END check_adm_appl_inst_stat;


FUNCTION   valid_ofr_resp_status(
                                       p_person_id igs_ad_ps_appl_inst.person_id%TYPE ,
               p_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE)
               RETURN BOOLEAN IS
CURSOR c_ofr_resp_status (cp_person_id igs_ad_ps_appl_inst.person_id%TYPE,
                                                      cp_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE) IS
/*******************************************************************************
Created by  : Rishi Ghosh
Date created: 17-Apr-2003
Purpose:
 This function will return true if  for this application at least one application instance has an application offer response
 status of 'Accepted' OR the offer response status is 'Deffered' with the deferment status as 'Confirmed'. For all other
 cases it will return false.   (bug#2901627)
Known limitations/enhancements and/or remarks:
Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
     SELECT count(*)
      FROM   igs_ad_ps_appl_inst
      WHERE  person_id = cp_person_id AND
              admission_appl_number =cp_admission_appl_number AND
             (( adm_offer_resp_status IN ( SELECT adm_offer_resp_status
                                         FROM   igs_ad_ofr_resp_stat
                   WHERE  s_adm_offer_resp_status = 'ACCEPTED')) OR
            ( adm_offer_resp_status IN ( SELECT adm_offer_resp_status
                                         FROM   igs_ad_ofr_resp_stat
                   WHERE  s_adm_offer_resp_status = 'DEFERRAL' ) AND
              adm_offer_dfrmnt_status IN (SELECT aods.adm_offer_dfrmnt_status
                                FROM   igs_ad_ofrdfrmt_stat   aods
                                WHERE  aods.s_adm_offer_dfrmnt_status ='CONFIRM')));
     l_count NUMBER;
BEGIN
OPEN c_ofr_resp_status(p_person_id,p_admission_appl_number);
FETCH c_ofr_resp_status INTO l_count;
CLOSE c_ofr_resp_status;
IF l_count >0 THEN
   RETURN TRUE;
 ELSE
   RETURN FALSE;
 END IF;
 END valid_ofr_resp_status;
FUNCTION res_pending_fee_status
(
    p_application_id IN NUMBER
)
RETURN VARCHAR2
IS
/*******************************************************************************
Created by  : ANWEST
Date created: 20-Jul-2005
Purpose:
This function has been created as part of the ADTD003 in the IGS.M build.  It is
used by the Submitted Applications Reusable Component to derive the exact nature
of the PENDING fee status, thus allowing a decision to made on navigation.  The
function can return 4 values:
    NULL
    NOFEEDUE
    PENDING
    PARTIAL
Known limitations/enhancements and/or remarks:
Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
BEGIN
DECLARE
    l_fee_exists    VARCHAR2(1);
    CURSOR c_igs_ad_appl_all (cp_application_id igs_ad_appl_all.application_id%TYPE) IS
        SELECT  person_id, admission_appl_number, appl_fee_amt
        FROM    igs_ad_appl_all
        WHERE   application_id = cp_application_id;
    rec_igs_ad_appl_all c_igs_ad_appl_all%ROWTYPE;
    CURSOR c_igs_ad_app_req (cp_person_id igs_ad_app_req.person_id%TYPE,
                             cp_admission_appl_number igs_ad_app_req.admission_appl_number%TYPE) IS
        SELECT  'X'
        FROM    igs_ad_app_req
        WHERE   person_id = cp_person_id
        AND     admission_appl_number = cp_admission_appl_number;
BEGIN
    IF p_application_id IS NULL THEN
        RETURN NULL;
    ELSE
        OPEN c_igs_ad_appl_all(p_application_id);
        FETCH c_igs_ad_appl_all INTO rec_igs_ad_appl_all;
        CLOSE c_igs_ad_appl_all;
        IF (rec_igs_ad_appl_all.appl_fee_amt is NULL OR
            rec_igs_ad_appl_all.appl_fee_amt = 0) THEN
            RETURN 'NOFEEDUE';
        ELSE
            OPEN c_igs_ad_app_req(rec_igs_ad_appl_all.person_id, rec_igs_ad_appl_all.admission_appl_number);
            FETCH c_igs_ad_app_req INTO l_fee_exists;
            CLOSE c_igs_ad_app_req;
            IF l_fee_exists is NULL THEN
                RETURN 'PENDING';
            ELSE
                RETURN 'PARTIAL';
            END IF;
        END IF;
    END IF;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_002.res_pending_fee_status');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END res_pending_fee_status;

PROCEDURE Admp_resub_inst(
  p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
  p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
  p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
  p_acai_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE,
  p_do_commit VARCHAR2 DEFAULT NULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
/*******************************************************************************
Created by  : Arvind Srinivasamoorthy
Date created: 19 Jul 2005
Purpose:
  To resubmit a withdrawn application instance
Known limitations/enhancements and/or remarks:
Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
CURSOR  c_acai IS
  SELECT  ROWID, acai.*
  FROM    IGS_AD_PS_APPL_INST acai
  WHERE   acai.person_id = p_person_id AND
          acai.admission_appl_number = p_admission_appl_number AND
          acai.nominated_course_cd= p_nominated_course_cd AND
    acai.sequence_number = p_acai_sequence_number;
acai_rec c_acai%ROWTYPE;
l_msg_at_index      NUMBER;
l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
BEGIN
  l_msg_at_index := igs_ge_msg_stack.count_msg;
  OPEN c_acai;
  FETCH c_acai INTO acai_rec;
  IF (c_acai%FOUND) THEN
    -- Call to tbh to insert null values for Application instance status. This will resubmit the application instance.
    IGS_AD_PS_APPL_Inst_Pkg.update_row(
    X_ROWID       => acai_rec.ROWID,
    x_PERSON_ID     => acai_rec.PERSON_ID,
    x_ADMISSION_APPL_NUMBER   => acai_rec.ADMISSION_APPL_NUMBER,
    x_NOMINATED_COURSE_CD   => acai_rec.NOMINATED_COURSE_CD,
    x_SEQUENCE_NUMBER   => acai_rec.SEQUENCE_NUMBER,
    x_PREDICTED_GPA     => acai_rec.PREDICTED_GPA,
    x_ACADEMIC_INDEX    => acai_rec.ACADEMIC_INDEX,
    x_ADM_CAL_TYPE      => acai_rec.ADM_CAL_TYPE,
    x_APP_FILE_LOCATION   => acai_rec.APP_FILE_LOCATION,
    x_ADM_CI_SEQUENCE_NUMBER  => acai_rec.ADM_CI_SEQUENCE_NUMBER,
    x_COURSE_CD     => acai_rec.COURSE_CD,
    x_APP_SOURCE_ID     => acai_rec.APP_SOURCE_ID,
    x_CRV_VERSION_NUMBER    => acai_rec.CRV_VERSION_NUMBER,
    x_WAITLIST_RANK     => acai_rec.WAITLIST_RANK,
    x_LOCATION_CD     => acai_rec.LOCATION_CD,
    x_ATTENT_OTHER_INST_CD    => acai_rec.ATTENT_OTHER_INST_CD,
    x_ATTENDANCE_MODE   => acai_rec.ATTENDANCE_MODE,
    x_EDU_GOAL_PRIOR_ENROLL_ID  => acai_rec.EDU_GOAL_PRIOR_ENROLL_ID,
    x_ATTENDANCE_TYPE   => acai_rec.ATTENDANCE_TYPE,
    x_DECISION_MAKE_ID    => acai_rec.DECISION_MAKE_ID,
    x_UNIT_SET_CD     => acai_rec.UNIT_SET_CD,
    x_DECISION_DATE     => acai_rec.DECISION_DATE,
    x_ATTRIBUTE_CATEGORY    => acai_rec.ATTRIBUTE_CATEGORY,
    x_ATTRIBUTE1      => acai_rec.ATTRIBUTE1,
    x_ATTRIBUTE2      => acai_rec.ATTRIBUTE2,
    x_ATTRIBUTE3      => acai_rec.ATTRIBUTE3,
    x_ATTRIBUTE4      => acai_rec.ATTRIBUTE4,
    x_ATTRIBUTE5      => acai_rec.ATTRIBUTE5,
    x_ATTRIBUTE6      => acai_rec.ATTRIBUTE6,
    x_ATTRIBUTE7      => acai_rec.ATTRIBUTE7,
    x_ATTRIBUTE8      => acai_rec.ATTRIBUTE8,
    x_ATTRIBUTE9      => acai_rec.ATTRIBUTE9,
    x_ATTRIBUTE10     => acai_rec.ATTRIBUTE10,
    x_ATTRIBUTE11     => acai_rec.ATTRIBUTE11,
    x_ATTRIBUTE12     => acai_rec.ATTRIBUTE12,
    x_ATTRIBUTE13     => acai_rec.ATTRIBUTE13,
    x_ATTRIBUTE14     => acai_rec.ATTRIBUTE14,
    x_ATTRIBUTE15     => acai_rec.ATTRIBUTE15,
    x_ATTRIBUTE16     => acai_rec.ATTRIBUTE16,
    x_ATTRIBUTE17     => acai_rec.ATTRIBUTE17,
    x_ATTRIBUTE18     => acai_rec.ATTRIBUTE18,
    x_ATTRIBUTE19     => acai_rec.ATTRIBUTE19,
    x_ATTRIBUTE20     => acai_rec.ATTRIBUTE20,
    x_DECISION_REASON_ID    => acai_rec.DECISION_REASON_ID,
    x_US_VERSION_NUMBER   => acai_rec.US_VERSION_NUMBER,
    x_DECISION_NOTES    => acai_rec.DECISION_NOTES,
    x_PENDING_REASON_ID   => acai_rec.PENDING_REASON_ID,
    x_PREFERENCE_NUMBER   => acai_rec.PREFERENCE_NUMBER,
    x_ADM_DOC_STATUS    => acai_rec.ADM_DOC_STATUS,
    x_ADM_ENTRY_QUAL_STATUS   => acai_rec.ADM_ENTRY_QUAL_STATUS,
    x_DEFICIENCY_IN_PREP    => acai_rec.DEFICIENCY_IN_PREP,
    x_LATE_ADM_FEE_STATUS   => acai_rec.LATE_ADM_FEE_STATUS,
    x_SPL_CONSIDER_COMMENTS   => acai_rec.SPL_CONSIDER_COMMENTS,
    x_APPLY_FOR_FINAID    => acai_rec.APPLY_FOR_FINAID,
    x_FINAID_APPLY_DATE   => acai_rec.FINAID_APPLY_DATE,
    x_ADM_OUTCOME_STATUS    => acai_rec.ADM_OUTCOME_STATUS,
    x_adm_otcm_stat_auth_per_id => acai_rec.adm_otcm_status_auth_person_id,
    x_ADM_OUTCOME_STATUS_AUTH_DT  => acai_rec.ADM_OUTCOME_STATUS_AUTH_DT,
    x_ADM_OUTCOME_STATUS_REASON => acai_rec.ADM_OUTCOME_STATUS_REASON,
    x_OFFER_DT      => acai_rec.OFFER_DT,
    x_OFFER_RESPONSE_DT   => acai_rec.OFFER_RESPONSE_DT,
    x_PRPSD_COMMENCEMENT_DT   => acai_rec.PRPSD_COMMENCEMENT_DT,
    x_ADM_CNDTNL_OFFER_STATUS => acai_rec.ADM_CNDTNL_OFFER_STATUS,
    x_CNDTNL_OFFER_SATISFIED_DT => acai_rec.CNDTNL_OFFER_SATISFIED_DT,
    x_cndnl_ofr_must_be_stsfd_ind => acai_rec.cndtnl_offer_must_be_stsfd_ind,
    x_ADM_OFFER_RESP_STATUS   => acai_rec.ADM_OFFER_RESP_STATUS,
    x_ACTUAL_RESPONSE_DT    => acai_rec.ACTUAL_RESPONSE_DT,
    x_ADM_OFFER_DFRMNT_STATUS => acai_rec.ADM_OFFER_DFRMNT_STATUS,
    x_DEFERRED_ADM_CAL_TYPE   => acai_rec.DEFERRED_ADM_CAL_TYPE,
    x_DEFERRED_ADM_CI_SEQUENCE_NUM  => acai_rec.DEFERRED_ADM_CI_SEQUENCE_NUM,
    x_DEFERRED_TRACKING_ID    => acai_rec.DEFERRED_TRACKING_ID,
    x_ASS_RANK      => acai_rec.ASS_RANK,
    x_SECONDARY_ASS_RANK    => acai_rec.SECONDARY_ASS_RANK,
    x_intr_accept_advice_num  => acai_rec.intrntnl_acceptance_advice_num,
    x_ASS_TRACKING_ID   => acai_rec.ASS_TRACKING_ID,
    x_FEE_CAT     => acai_rec.FEE_CAT,
    x_HECS_PAYMENT_OPTION   => acai_rec.HECS_PAYMENT_OPTION,
    x_EXPECTED_COMPLETION_YR  => acai_rec.EXPECTED_COMPLETION_YR,
    x_EXPECTED_COMPLETION_PERD  => acai_rec.EXPECTED_COMPLETION_PERD,
    x_CORRESPONDENCE_CAT    => acai_rec.CORRESPONDENCE_CAT,
    x_ENROLMENT_CAT     => acai_rec.ENROLMENT_CAT,
    x_FUNDING_SOURCE    => acai_rec.FUNDING_SOURCE,
    x_APPLICANT_ACPTNCE_CNDTN => acai_rec.APPLICANT_ACPTNCE_CNDTN,
    x_CNDTNL_OFFER_CNDTN    => acai_rec.CNDTNL_OFFER_CNDTN,
    X_MODE        => 'R',
    X_SS_APPLICATION_ID   => acai_rec.SS_APPLICATION_ID,
    X_SS_PWD      => acai_rec.SS_PWD,
    X_AUTHORIZED_DT     => acai_rec.AUTHORIZED_DT,
    X_AUTHORIZING_PERS_ID   => acai_rec.AUTHORIZING_PERS_ID,
    x_entry_status      => acai_rec.entry_status,
    x_entry_level     => acai_rec.entry_level,
    x_sch_apl_to_id     => acai_rec.sch_apl_to_id,
    x_idx_calc_date     => acai_rec.idx_calc_date,
    x_waitlist_status   => acai_rec.waitlist_status,
    x_ATTRIBUTE21     => acai_rec.ATTRIBUTE21,
    x_ATTRIBUTE22     => acai_rec.ATTRIBUTE22,
    x_ATTRIBUTE23     => acai_rec.ATTRIBUTE23,
    x_ATTRIBUTE24     => acai_rec.ATTRIBUTE24,
    x_ATTRIBUTE25     => acai_rec.ATTRIBUTE25,
    x_ATTRIBUTE26     => acai_rec.ATTRIBUTE26,
    x_ATTRIBUTE27     => acai_rec.ATTRIBUTE27,
    x_ATTRIBUTE28     => acai_rec.ATTRIBUTE28,
    x_ATTRIBUTE29     => acai_rec.ATTRIBUTE29,
    x_ATTRIBUTE30     => acai_rec.ATTRIBUTE30,
    x_ATTRIBUTE31     => acai_rec.ATTRIBUTE31,
    x_ATTRIBUTE32     => acai_rec.ATTRIBUTE32,
    x_ATTRIBUTE33     => acai_rec.ATTRIBUTE33,
    x_ATTRIBUTE34     => acai_rec.ATTRIBUTE34,
    x_ATTRIBUTE35     => acai_rec.ATTRIBUTE35,
    x_ATTRIBUTE36     => acai_rec.ATTRIBUTE36,
    x_ATTRIBUTE37     => acai_rec.ATTRIBUTE37,
    x_ATTRIBUTE38     => acai_rec.ATTRIBUTE38,
    x_ATTRIBUTE39     => acai_rec.ATTRIBUTE39,
    x_ATTRIBUTE40     => acai_rec.ATTRIBUTE40,
    x_fut_acad_cal_type   => acai_rec.future_acad_cal_type,
    x_fut_acad_ci_sequence_number => acai_rec.future_acad_ci_sequence_number,
    x_fut_adm_cal_type    => acai_rec.future_adm_cal_type,
    x_fut_adm_ci_sequence_number  => acai_rec.future_adm_ci_sequence_number,
    x_prev_term_adm_appl_number => acai_rec.previous_term_adm_appl_number,
    x_prev_term_sequence_number => acai_rec.previous_term_sequence_number,
    x_fut_term_adm_appl_number  => acai_rec.future_term_adm_appl_number,
    x_fut_term_sequence_number  => acai_rec.future_term_sequence_number,
    x_def_acad_cal_type   => acai_rec.def_acad_cal_type,
    x_def_acad_ci_sequence_num  => acai_rec.def_acad_ci_sequence_num,
    x_def_prev_term_adm_appl_num  => acai_rec.def_prev_term_adm_appl_num,
    x_def_prev_appl_sequence_num  => acai_rec.def_prev_appl_sequence_num,
    x_def_term_adm_appl_num   => acai_rec.def_term_adm_appl_num,
    x_def_appl_sequence_num   => acai_rec.def_appl_sequence_num,
    x_appl_inst_status    => NULL,
    x_ais_reason      => NULL,
    x_decline_ofr_reason    => acai_rec.decline_ofr_reason
    );
  END IF;
  CLOSE c_acai;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_do_commit = 'Y' THEN
    COMMIT;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
  igs_ad_gen_016.extract_msg_from_stack (
                          p_msg_at_index                => l_msg_at_index,
                          p_return_status               => x_return_status,
                          p_msg_count                   => x_msg_count,
                          p_msg_data                    => x_msg_data,
                          p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
  IF l_hash_msg_name_text_type_tab(x_msg_count-1).name <>  'ORA'  THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
  ELSE
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;
        IF c_acai%ISOPEN THEN
        CLOSE c_acai;
  END IF;
END Admp_resub_inst;



-- begin arvsrini - ADTD001 RE-OPEN BUILD- IGS.M
FUNCTION check_any_offer_inst
                (p_person_id  IGS_AD_PS_APPL_INST.person_id%TYPE,
                 p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                 p_nominated_course_cd IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE DEFAULT NULL,
                 p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE DEFAULT NULL
                 )
RETURN BOOLEAN IS
-- created for IGS.M arvsrini
  --Cursor to fetch the desired records.
  Cursor c_aca ( cp_person_id  IGS_AD_PS_APPL_INST.person_id%TYPE,
                        cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                        cp_nominated_course_cd IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
                        cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE
                      ) IS
  SELECT acai.adm_outcome_status outcome_status
  FROM IGS_AD_PS_APPL_INST   acai
  WHERE acai.person_id = cp_person_id AND
        acai.admission_appl_number = cp_admission_appl_number AND
        acai.nominated_course_cd = NVL(cp_nominated_course_cd,acai.nominated_course_cd) AND
        acai.sequence_number= NVL(cp_sequence_number,acai.sequence_number)  ;
  l_instance_found BOOLEAN DEFAULT FALSE;
  cst_offer CONSTANT VARCHAR2(10) := 'OFFER';
  cst_cond_offer CONSTANT VARCHAR2(10) := 'COND-OFFER';
BEGIN
  --Loop through the record set; if an instance with outcome 'Offer' or  'Conditional Offer' is found set the flag to TRUE and exit.
  FOR c_aca_rec IN c_aca(p_person_id, p_admission_appl_number, p_nominated_course_cd, p_sequence_number) LOOP
      IF IGS_AD_GEN_008.ADMP_GET_SAOS(c_aca_rec.outcome_status) IN (cst_offer, cst_cond_offer) THEN
    l_instance_found := TRUE;
    EXIT;
      END IF;
  END LOOP;
  RETURN l_instance_found;
END check_any_offer_inst;





FUNCTION Is_App_Inst_Complete (
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2,
  p_sequence_number IN NUMBER)
RETURN VARCHAR2 IS
-- created for IGS.M arvsrini
CURSOR c_acai IS
  SELECT  acai.adm_outcome_status,
    acai.adm_offer_resp_status,
    acai.adm_offer_dfrmnt_status,
    acai.def_term_adm_appl_num,
    acai.def_appl_sequence_num
  FROM  IGS_AD_PS_APPL_INST   acai
  WHERE acai.person_id      = p_person_id AND
    acai.admission_appl_number  = p_admission_appl_number AND
    acai.nominated_course_cd  = p_nominated_course_cd AND
    acai.sequence_number            = p_sequence_number;
  cst_withdrawn   CONSTANT VARCHAR2(10) := 'WITHDRAWN';
  cst_received    CONSTANT VARCHAR2(10) := 'RECEIVED';
  cst_offer   CONSTANT VARCHAR2(10) := 'OFFER';
  cst_cond_offer    CONSTANT VARCHAR2(10) := 'COND-OFFER';
  cst_accepted    CONSTANT VARCHAR2(10) := 'ACCEPTED';
  cst_rejected    CONSTANT VARCHAR2(10) := 'REJECTED';
  cst_lapsed    CONSTANT VARCHAR2(10) := 'LAPSED';
  cst_completed   CONSTANT VARCHAR2(10) := 'COMPLETED';
  cst_voided    CONSTANT VARCHAR2(10) := 'VOIDED';
  cst_no_quota    CONSTANT VARCHAR2(10) := 'NO-QUOTA';
  cst_deferral            CONSTANT VARCHAR2(10) := 'DEFERRAL';
  cst_confirm           CONSTANT VARCHAR2(10) := 'CONFIRM';
  cst_approved    CONSTANT VARCHAR2(10) := 'APPROVED';
  cst_cancelled           CONSTANT VARCHAR2(10) := 'CANCELLED';
  v_completed_appl  VARCHAR2(1) DEFAULT 'N';
  v_aca_rec   c_acai%ROWTYPE;
  v_s_adm_outcome_status    igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  v_s_adm_offer_resp_status igs_ad_ofr_resp_stat.s_adm_offer_resp_status%TYPE;
  v_s_adm_offer_dfrmnt_status igs_ad_ofrdfrmt_stat.s_adm_offer_dfrmnt_status%TYPE;
BEGIN
  OPEN c_acai;
  FETCH c_acai INTO v_aca_rec;
  IF (c_acai%FOUND) THEN
    v_s_adm_outcome_status := Igs_Ad_Gen_008.Admp_Get_Saos(v_aca_rec.adm_outcome_status);
    v_s_adm_offer_resp_status := Igs_Ad_Gen_008.Admp_Get_Saors(v_aca_rec.adm_offer_resp_status);
        v_s_adm_offer_dfrmnt_status := Igs_Ad_Gen_008.Admp_Get_Saods(v_aca_rec.adm_offer_dfrmnt_status);
    -- Check if the outcome of the admission course
    -- application instance is complete or has been resolved.
    IF  (  v_s_adm_outcome_status IN (cst_cancelled, cst_voided, cst_withdrawn,cst_no_quota,cst_rejected)
           OR
           (  v_s_adm_outcome_status IN (cst_offer, cst_cond_offer)
        AND
              (   v_s_adm_offer_resp_status IN (cst_accepted, cst_rejected, cst_lapsed)
            OR
            (   v_s_adm_offer_resp_status IN (cst_deferral)
          AND
                (  v_s_adm_offer_dfrmnt_status IN (cst_confirm)
                   OR
                   (   v_s_adm_offer_dfrmnt_status IN  (cst_approved)
                 AND
                 (  v_aca_rec.def_term_adm_appl_num IS NOT NULL
                    OR
                    v_aca_rec.def_appl_sequence_num IS NOT NULL
                 )
                     )
                )
            )
                    )
           )
        )
                THEN
      v_completed_appl:= 'Y';
    END IF;
  END IF;
  CLOSE c_acai;
  RETURN v_completed_appl;
END Is_App_Inst_Complete;
-- END arvsrini - ADTD001 RE-OPEN BUILD- IGS.M

-- begin APADEGAL - ADTD001 RE-OPEN BUILD- IGS.M
---------------------------***************Is_inst_recon_allowed (PROCEDURE)**************-------------------------
PROCEDURE Is_inst_recon_allowed ( p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
          p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
          p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
          p_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE,
          p_success out nocopy varchar2,
                                  p_message_name out nocopy varchar2
        ) IS
        cst_accepted    CONSTANT VARCHAR2(10) := 'ACCEPTED';
  cst_rejected    CONSTANT VARCHAR2(10) := 'REJECTED';
  cst_lapsed    CONSTANT VARCHAR2(10) := 'LAPSED';

  cst_deferral            CONSTANT VARCHAR2(10) := 'DEFERRAL';
  cst_confirm           CONSTANT VARCHAR2(10) := 'CONFIRM';

 CURSOR c_aa_acaiv IS
                SELECT  acaiv.adm_cal_type,
                        acaiv.adm_ci_sequence_number,
                        acaiv.course_cd,
                        acaiv.crv_version_number,
                        acaiv.location_cd,
                        acaiv.attendance_mode,
                        acaiv.attendance_type ,
      acaiv.future_term_adm_appl_number,
      acaiv.future_term_sequence_number,
      acaiv.def_term_adm_appl_num,
      acaiv.def_appl_sequence_num
                FROM    igs_ad_ps_appl_inst   acaiv
                WHERE   acaiv.person_id                 = p_person_id                   AND
                        acaiv.admission_appl_number     = p_admission_appl_number       AND
                        acaiv.nominated_course_cd       = p_nominated_course_cd         AND
                        acaiv.sequence_number           = p_sequence_number;
v_aa_acaiv_rec          c_aa_acaiv%ROWTYPE;
CURSOR  c_other_offer_inst IS
                SELECT  1  CNT
          FROM    igs_ad_ps_appl_inst   acaiv
          WHERE   acaiv.person_id                 = p_person_id                   AND
            acaiv.admission_appl_number     = p_admission_appl_number       AND
            acaiv.nominated_course_cd       = p_nominated_course_cd         AND
            acaiv.sequence_number           <> p_sequence_number       AND
            IGS_AD_GEN_008.ADMP_GET_SAOS(acaiv.adm_outcome_status) IN ('OFFER','COND-OFFER')
      AND (   IGS_AD_GEN_008.ADMP_GET_SAORS(acaiv.adm_offer_resp_status) IN (cst_accepted,cst_rejected,cst_lapsed)
              OR
        (IGS_AD_GEN_008.ADMP_GET_SAORS(acaiv.adm_offer_resp_status) IN (cst_deferral)
         AND
         IGS_AD_GEN_008.ADMP_GET_SAODS(acaiv.adm_offer_dfrmnt_status) IN (cst_confirm)
        )
          )
      AND rownum <= 1  ;
CURSOR c_aa IS
    SELECT  aa.admission_cat,
      aa.s_admission_process_type
    FROM  IGS_AD_APPL aa
    WHERE aa.person_id      = p_person_id AND
      aa.admission_appl_number  = p_admission_appl_number;
CURSOR c_apcs ( cp_admission_cat              IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
                cp_s_admission_process_type   IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE
        ) IS
        SELECT '1'
        FROM   IGS_AD_PRCS_CAT_STEP
        WHERE  admission_cat = cp_admission_cat AND
         s_admission_process_type = cp_s_admission_process_type AND
         s_admission_step_type = 'RECONSIDER' AND
         step_group_type <> 'TRACK' ;
l_other_offer_inst_cnt  NUMBER DEFAULT 0;
l_admission_cat     IGS_AD_APPL.admission_cat%TYPE;
l_s_admission_process_type  IGS_AD_APPL.s_admission_process_type%TYPE;
l_is_reconisder_allowed  BOOLEAN DEFAULT FALSE;
l_dummy varchar2(30) DEFAULT NULL;
BEGIN
OPEN   c_other_offer_inst ;
FETCH  c_other_offer_inst  INTO  l_other_offer_inst_cnt;
CLOSE  c_other_offer_inst;
OPEN c_aa;
FETCH c_aa INTO l_admission_cat, l_s_admission_process_type;
CLOSE  c_aa;
OPEN c_apcs(l_admission_cat, l_s_admission_process_type);
FETCH c_apcs INTO l_dummy;
    IF ( NVL(l_dummy,'X') = '1' )
    THEN
        l_is_reconisder_allowed := TRUE;
    END IF;
CLOSE c_apcs;
OPEN c_aa_acaiv;
FETCH c_aa_acaiv INTO v_aa_acaiv_rec;
CLOSE c_aa_acaiv;

  IF  igs_ad_gen_002.is_app_inst_complete(p_person_id,p_admission_appl_number,p_nominated_course_cd,p_sequence_number) = 'Y'
  THEN
       IF (NOT l_is_reconisder_allowed ) -- APC step not allowed
       THEN
            p_message_name := 'IGS_AD_NO_RECONSIDERATION';
            p_success  := 'N';
            RETURN;
       ELSE
           IF ( v_aa_acaiv_rec.future_term_adm_appl_number   IS NOT NULL OR
          v_aa_acaiv_rec.future_term_sequence_number   IS NOT NULL OR
          v_aa_acaiv_rec.def_term_adm_appl_num IS NOT NULL  OR
          v_aa_acaiv_rec.def_appl_sequence_num IS NOT NULL
        )
            THEN
             p_message_name := 'IGS_AD_NO_RECONSIDERATION';  -- cannot be reconsidered as a future/deferred application exists.
             p_success  := 'N';
             RETURN;
            END IF;
            IF  (igs_ad_gen_002.check_any_offer_inst (p_person_id, p_admission_appl_number, p_nominated_course_cd, p_sequence_number ) )
            THEN
             p_success  := 'Y';
             RETURN;   -- can be reconsiderd, as this is an offered instance
            ELSE
              IF   (l_other_offer_inst_cnt <> 0) -- TO Check if there exists other instance(s) with offer/cond offer
                THEN
            p_message_name := 'IGS_AD_INST_NO_RECON'; --cant be reconsidered, as there exits another intance with offer
            p_success  := 'N';
            RETURN;
              ELSE
            p_success  := 'Y'; -- can be reconsidered, as no other offered instance exists
            RETURN;
              END IF;
           END IF;
        END IF;
  ELSE    -- Instance not yet resolved, cannot be reconsidered
     p_message_name := 'IGS_AD_NO_RECONSIDERATION';
     p_success  := 'N'; RETURN;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  p_message_name := 'IGS_GE_UNHANDLED_EXP';
  p_success := 'N';
  RETURN;
END Is_inst_recon_allowed;
---------------------------***************Is_inst_recon_allowed (overloaded function)**************-------------------------
FUNCTION Is_inst_recon_allowed (  p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
          p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
          p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
          p_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE
             )
RETURN VARCHAR2 IS
p_message_name  VARCHAR2(40) DEFAULT NULL;
p_success VARCHAR2(1) DEFAULT NULL;
BEGIN
  igs_ad_gen_002.Is_inst_recon_allowed ( p_person_id,p_admission_appl_number,p_nominated_course_cd, p_sequence_number,p_success,p_message_name);
      RETURN p_success;
END Is_inst_recon_allowed;

---------------------------**************Reconsider_Appl_Inst***************-------------------------

PROCEDURE Reconsider_Appl_Inst (
        p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
        p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
        p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
        p_acai_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE,
        p_interface           VARCHAR2  -- Interface which has raised reconsideration ( Forms,Self service, Import process)
                          )
IS

/*******************************************************************************
Created by  : apadegal, Oracle IDC
Date created: 18-August-2005

Usage: (e.g. restricted, unrestricted, where to call from)
1. Thie procedure would reset the outcome status to pending for all the applciation insatnces of the given program ,
except the pending instances or instances which have have reference to futuer term or deferred term applications.
2. It would set the other fields (like offer reponse, decision maker id, decision date...etc) accordingly.
3. Once the update is done, corresponding business event (for outcome/decision change) will be raised.
4. This procedure is invoked from the
                      a) IGSAD092.pld ( Outcome Form) and
                      b) IGSPAPPB.pls ( Public API - used in Decision import process)  and
          c) EnterDecisionDetailsEOImpl.java ( Enter deicsions page - Self Service)

Known limitations/enhancements/remarks:
   -

Change History: (who, when, what: NO CREATION RECORDS HERE!)
Who             When            What
*******************************************************************************/

CURSOR  c_aca IS
  SELECT      rowid,acai.*
  FROM         IGS_AD_PS_APPL_INST_ALL  acai
  WHERE          acai.person_id             = p_person_id AND
           acai.admission_appl_number   = p_admission_appl_number AND
           acai.nominated_course_cd       = p_nominated_course_cd AND
                       acai.future_term_adm_appl_number IS NULL  AND
                       acai.future_term_sequence_number IS NULL AND
                       acai.def_term_adm_appl_num IS NULL AND
                       acai.def_appl_sequence_num IS NULL AND
           IGS_AD_GEN_008.ADMP_GET_SAOS(acai.ADM_OUTCOME_STATUS)  <>  'PENDING'
  FOR UPDATE NOWAIT;


CURSOR  cur_ad_ps_appl (      cur_person_id         IGS_AD_PS_APPL.person_id%TYPE ,
                                 cur_admission_appl_number   IGS_AD_PS_APPL.admission_appl_number%TYPE ,
                                 cur_nominated_course_cd     IGS_AD_PS_APPL.nominated_course_cd%TYPE ) IS
         SELECT  rowid , IGS_AD_PS_APPL.*
         FROM    IGS_AD_PS_APPL
         WHERE   person_id = CUR_person_id   AND
                 admission_appl_number = CUR_admission_appl_number AND
                 nominated_course_cd = CUR_nominated_course_cd;
cur_ad_ps_appl_rec        cur_ad_ps_appl%ROWTYPE ;



CURSOR c_get_applicant(cp_person_id igs_pe_typ_instances_all.person_id%TYPE,
           cp_admission_appl_number  igs_pe_typ_instances_all.admission_appl_number%TYPE,
           cp_nominated_course_cd igs_pe_typ_instances_all.nominated_course_cd%TYPE) IS
        SELECT pti.rowid,pti.*
        FROM   igs_pe_typ_instances_all pti
        WHERE   pti.person_type_code IN  (SELECT  pt.person_type_code FROM Igs_pe_person_types pt WHERE pt.system_type = 'APPLICANT')
            AND pti.person_id = cp_person_id
      AND pti.admission_appl_number = cp_admission_appl_number
            AND pti.nominated_course_cd = cp_nominated_course_cd
            AND pti.end_date IS NOT NULL
      AND pti.end_method = 'CREATE_STUDENT'
      FOR UPDATE NOWAIT;




x_msg_data varchar2(2000);

BEGIN


-- call the below procedure to generate dummy history records for currently  PENDING application isntances of the program

ins_dummy_pend_hist_rec ( p_person_id,
        p_admission_appl_number,
        p_nominated_course_cd
           );

FOR  c_aca_rec IN c_aca
 LOOP


   igs_ad_wf_001.APP_RECONSIDER_REQUEST_EVENT
          (
    P_PERSON_ID     => c_aca_rec.person_id,
    P_ADMISSION_APPL_NUMBER => c_aca_rec.admission_appl_number,
    P_NOMINATED_COURSE_CD         => c_aca_rec.nominated_course_cd,
    P_SEQUENCE_NUMBER   => c_aca_rec.sequence_number,
    P_ADM_OUTCOME_STATUS          => c_aca_rec.adm_outcome_status,
    P_ADM_OFFER_RESP_STATUS       => c_aca_rec.adm_offer_resp_status
  );


   IF ( NVL(IGS_AD_GEN_008.ADMP_GET_SAORS(c_aca_rec.Adm_Offer_Resp_Status), 'NULL') = 'ACCEPTED' )
    THEN
    -- UNCONFIRM the Student PROGRAM ATTEMPTS.   (api would be provided by enrolments team)

    IF NOT IGS_EN_VAL_SCA.handle_rederive_prog_att (p_person_id          =>  c_aca_rec.PERSON_ID ,
                p_admission_appl_number    =>  c_aca_rec.ADMISSION_APPL_NUMBER ,
                p_nominated_course_cd      =>  c_aca_rec.NOMINATED_COURSE_CD ,
                p_sequence_number        =>  c_aca_rec.SEQUENCE_NUMBER ,
                p_message          =>  x_msg_data
                                                   )
   THEN


    App_Exception.Raise_Exception;
    ELSE

     -- Re-open the related Application Person Types - nullify the 'End'fields.

     FOR c_appl_rec IN  c_get_applicant(p_person_id,p_admission_appl_number,p_nominated_course_cd)
     LOOP

       igs_pe_typ_instances_pkg.update_row(
            X_ROWID  => c_appl_rec.rowid,
            X_PERSON_ID => c_appl_rec.PERSON_ID,
            X_COURSE_CD => c_appl_rec.COURSE_CD,
            X_TYPE_INSTANCE_ID => c_appl_rec.TYPE_INSTANCE_ID,
            X_PERSON_TYPE_CODE => c_appl_rec.PERSON_TYPE_CODE,
            X_CC_VERSION_NUMBER => c_appl_rec.CC_VERSION_NUMBER,
            X_FUNNEL_STATUS => c_appl_rec.FUNNEL_STATUS,
            X_ADMISSION_APPL_NUMBER => c_appl_rec.ADMISSION_APPL_NUMBER,
            X_NOMINATED_COURSE_CD => c_appl_rec.NOMINATED_COURSE_CD,
            X_NCC_VERSION_NUMBER => c_appl_rec.NCC_VERSION_NUMBER,
            X_SEQUENCE_NUMBER => c_appl_rec.SEQUENCE_NUMBER,
            X_START_DATE => c_appl_rec.START_DATE,
            X_END_DATE => NULL,                                     -- nullified this field
            X_CREATE_METHOD => c_appl_rec.CREATE_METHOD,
            X_ENDED_BY => NULL,                                      -- nullified this field
            X_END_METHOD => NULL,                                    -- nullified this field
            X_MODE => 'R',
            X_EMPLMNT_CATEGORY_CODE => c_appl_rec.EMPLMNT_CATEGORY_CODE);



     END LOOP;
          END IF;

    END IF;

   IGS_AD_PS_APPL_INST_PKG.UPDATE_ROW (X_ROWID                       =>  c_aca_rec.ROWID ,
               x_PERSON_ID               =>  c_aca_rec.PERSON_ID ,
               x_ADMISSION_APPL_NUMBER           =>  c_aca_rec.ADMISSION_APPL_NUMBER ,
               x_NOMINATED_COURSE_CD             =>  c_aca_rec.NOMINATED_COURSE_CD ,
               x_SEQUENCE_NUMBER             =>  c_aca_rec.SEQUENCE_NUMBER ,
               x_PREDICTED_GPA             =>  c_aca_rec.PREDICTED_GPA ,
               x_ACADEMIC_INDEX              =>  c_aca_rec.ACADEMIC_INDEX,
               x_ADM_CAL_TYPE              =>  c_aca_rec.ADM_CAL_TYPE,
               x_APP_FILE_LOCATION             =>  c_aca_rec.APP_FILE_LOCATION,
               x_ADM_CI_SEQUENCE_NUMBER            =>  c_aca_rec.ADM_CI_SEQUENCE_NUMBER,
               x_COURSE_CD               =>  c_aca_rec.COURSE_CD,
               x_APP_SOURCE_ID             =>  c_aca_rec.APP_SOURCE_ID ,
               x_CRV_VERSION_NUMBER              =>  c_aca_rec.CRV_VERSION_NUMBER ,
               x_WAITLIST_RANK             =>  NULL,
               x_LOCATION_CD               =>  c_aca_rec.LOCATION_CD,
               x_ATTENT_OTHER_INST_CD            =>  NULL,
               x_ATTENDANCE_MODE             =>  c_aca_rec.ATTENDANCE_MODE,
               x_EDU_GOAL_PRIOR_ENROLL_ID            =>  c_aca_rec.EDU_GOAL_PRIOR_ENROLL_ID,
               x_ATTENDANCE_TYPE             =>  c_aca_rec.ATTENDANCE_TYPE,
               x_DECISION_MAKE_ID              =>  NULL,
               x_UNIT_SET_CD               =>  c_aca_rec.UNIT_SET_CD,
               x_DECISION_DATE             =>  NULL,
               x_ATTRIBUTE_CATEGORY              =>  c_aca_rec.ATTRIBUTE_CATEGORY,
               x_ATTRIBUTE1                =>  c_aca_rec.ATTRIBUTE1,
               x_ATTRIBUTE2                =>  c_aca_rec.ATTRIBUTE2,
               x_ATTRIBUTE3                =>  c_aca_rec.ATTRIBUTE3,
               x_ATTRIBUTE4                =>  c_aca_rec.ATTRIBUTE4,
               x_ATTRIBUTE5                =>  c_aca_rec.ATTRIBUTE5,
               x_ATTRIBUTE6                =>  c_aca_rec.ATTRIBUTE6,
               x_ATTRIBUTE7                =>  c_aca_rec.ATTRIBUTE7,
               x_ATTRIBUTE8                =>  c_aca_rec.ATTRIBUTE8,
               x_ATTRIBUTE9                =>  c_aca_rec.ATTRIBUTE9,
               x_ATTRIBUTE10               =>  c_aca_rec.ATTRIBUTE10,
               x_ATTRIBUTE11               =>  c_aca_rec.ATTRIBUTE11,
               x_ATTRIBUTE12               =>  c_aca_rec.ATTRIBUTE12,
               x_ATTRIBUTE13               =>  c_aca_rec.ATTRIBUTE13,
               x_ATTRIBUTE14               =>  c_aca_rec.ATTRIBUTE14,
               x_ATTRIBUTE15               =>  c_aca_rec.ATTRIBUTE15,
               x_ATTRIBUTE16               =>  c_aca_rec.ATTRIBUTE16,
               x_ATTRIBUTE17               =>  c_aca_rec.ATTRIBUTE17,
               x_ATTRIBUTE18               =>  c_aca_rec.ATTRIBUTE18,
               x_ATTRIBUTE19               =>  c_aca_rec.ATTRIBUTE19,
               x_ATTRIBUTE20               =>  c_aca_rec.ATTRIBUTE20,
               x_DECISION_REASON_ID              =>  NULL,
               x_US_VERSION_NUMBER             =>  c_aca_rec.US_VERSION_NUMBER,
               x_DECISION_NOTES              =>  c_aca_rec.DECISION_NOTES,
               x_PENDING_REASON_ID             =>  c_aca_rec.PENDING_REASON_ID,
               x_PREFERENCE_NUMBER             =>  c_aca_rec.PREFERENCE_NUMBER,
               x_ADM_DOC_STATUS              =>  c_aca_rec.ADM_DOC_STATUS,
               x_ADM_ENTRY_QUAL_STATUS           =>  c_aca_rec.ADM_ENTRY_QUAL_STATUS,
               x_DEFICIENCY_IN_PREP              =>  c_aca_rec.DEFICIENCY_IN_PREP,
               x_LATE_ADM_FEE_STATUS             =>  c_aca_rec.LATE_ADM_FEE_STATUS,
               x_SPL_CONSIDER_COMMENTS           =>  c_aca_rec.SPL_CONSIDER_COMMENTS,
               x_APPLY_FOR_FINAID              =>  c_aca_rec.APPLY_FOR_FINAID,
               x_FINAID_APPLY_DATE             =>  c_aca_rec.FINAID_APPLY_DATE,
               x_ADM_OUTCOME_STATUS              =>  IGS_AD_GEN_009.ADMP_GET_SYS_AOS('PENDING'),
               x_adm_otcm_stat_auth_per_id          =>  c_aca_rec.ADM_OTCM_STATUS_AUTH_PERSON_ID,
               x_ADM_OUTCOME_STATUS_AUTH_DT                 =>  c_aca_rec.ADM_OUTCOME_STATUS_AUTH_DT,
               x_ADM_OUTCOME_STATUS_REASON           =>  c_aca_rec.ADM_OUTCOME_STATUS_REASON ,
               x_OFFER_DT                =>  NULL,
               x_OFFER_RESPONSE_DT             =>  NULL,
               x_PRPSD_COMMENCEMENT_DT           =>  NULL,
               x_ADM_CNDTNL_OFFER_STATUS           =>  IGS_AD_GEN_009.ADMP_GET_SYS_ACOS('NOT-APPLIC'),
               x_CNDTNL_OFFER_SATISFIED_DT           =>  NULL,
               x_cndnl_ofr_must_be_stsfd_ind           =>  NULL,
               x_ADM_OFFER_RESP_STATUS           =>  IGS_AD_GEN_009.ADMP_GET_SYS_AORS('NOT-APPLIC'),
               x_ACTUAL_RESPONSE_DT              =>  NULL,
               x_ADM_OFFER_DFRMNT_STATUS           =>  IGS_AD_GEN_009.ADMP_GET_SYS_AODS('NOT-APPLIC'),
               x_DEFERRED_ADM_CAL_TYPE           =>  NULL,
               x_DEFERRED_ADM_CI_SEQUENCE_NUM          =>  NULL,
               x_DEFERRED_TRACKING_ID            =>  c_aca_rec.DEFERRED_TRACKING_ID,
               x_ASS_RANK                =>  c_aca_rec.ASS_RANK,
               x_SECONDARY_ASS_RANK              =>  c_aca_rec.SECONDARY_ASS_RANK,
               x_intr_accept_advice_num            =>  c_aca_rec.INTRNTNL_ACCEPTANCE_ADVICE_NUM  ,
               x_ASS_TRACKING_ID             =>  c_aca_rec.ASS_TRACKING_ID ,
               x_FEE_CAT               =>  c_aca_rec.FEE_CAT,
               x_HECS_PAYMENT_OPTION             =>  c_aca_rec.HECS_PAYMENT_OPTION,
               x_EXPECTED_COMPLETION_YR            =>  c_aca_rec.EXPECTED_COMPLETION_YR,
               x_EXPECTED_COMPLETION_PERD            =>  c_aca_rec.EXPECTED_COMPLETION_PERD,
               x_CORRESPONDENCE_CAT              =>  c_aca_rec.CORRESPONDENCE_CAT,
               x_ENROLMENT_CAT             =>  c_aca_rec.ENROLMENT_CAT,
               x_FUNDING_SOURCE              =>  c_aca_rec.FUNDING_SOURCE,
               x_APPLICANT_ACPTNCE_CNDTN           =>  NULL ,
               x_CNDTNL_OFFER_CNDTN              =>  NULL,
               X_MODE                =>  'S',
               X_SS_APPLICATION_ID             =>  c_aca_rec.SS_APPLICATION_ID,
               X_SS_PWD                    =>  c_aca_rec.SS_PWD,
               X_AUTHORIZED_DT             =>  c_aca_rec.AUTHORIZED_DT,
               X_AUTHORIZING_PERS_ID             =>  c_aca_rec.AUTHORIZING_PERS_ID,
               x_entry_status              =>  c_aca_rec.entry_status,
               x_entry_level               =>  c_aca_rec.entry_level,
               x_sch_apl_to_id             =>  c_aca_rec.sch_apl_to_id,
               x_idx_calc_date             =>  c_aca_rec.IDX_CALC_DATE,
               x_waitlist_status             =>  NULL,
               x_ATTRIBUTE21               =>  c_aca_rec.ATTRIBUTE21,
               x_ATTRIBUTE22               =>  c_aca_rec.ATTRIBUTE22,
               x_ATTRIBUTE23               =>  c_aca_rec.ATTRIBUTE23,
               x_ATTRIBUTE24               =>  c_aca_rec.ATTRIBUTE24,
               x_ATTRIBUTE25               =>  c_aca_rec.ATTRIBUTE25,
               x_ATTRIBUTE26               =>  c_aca_rec.ATTRIBUTE26,
               x_ATTRIBUTE27               =>  c_aca_rec.ATTRIBUTE27,
               x_ATTRIBUTE28               =>  c_aca_rec.ATTRIBUTE28,
               x_ATTRIBUTE29               =>  c_aca_rec.ATTRIBUTE29,
               x_ATTRIBUTE30               =>  c_aca_rec.ATTRIBUTE30,
               x_ATTRIBUTE31               =>  c_aca_rec.ATTRIBUTE31,
               x_ATTRIBUTE32               =>  c_aca_rec.ATTRIBUTE32,
               x_ATTRIBUTE33               =>  c_aca_rec.ATTRIBUTE33,
               x_ATTRIBUTE34               =>  c_aca_rec.ATTRIBUTE34,
               x_ATTRIBUTE35               =>  c_aca_rec.ATTRIBUTE35,
               x_ATTRIBUTE36               =>  c_aca_rec.ATTRIBUTE36,
               x_ATTRIBUTE37               =>  c_aca_rec.ATTRIBUTE37,
               x_ATTRIBUTE38               =>  c_aca_rec.ATTRIBUTE38,
               x_ATTRIBUTE39               =>  c_aca_rec.ATTRIBUTE39,
               x_ATTRIBUTE40               =>  c_aca_rec.ATTRIBUTE40,
               x_fut_acad_cal_type                     =>  NULL,
               x_fut_acad_ci_sequence_number           =>  NULL,
               x_fut_adm_cal_type                      =>  NULL,
               x_fut_adm_ci_sequence_number            =>  NULL,
               x_prev_term_adm_appl_number             =>  c_aca_rec.previous_term_adm_appl_number,
               x_prev_term_sequence_number             =>  c_aca_rec.previous_term_sequence_number,
               x_fut_term_adm_appl_number              =>  c_aca_rec.future_term_adm_appl_number,
               x_fut_term_sequence_number              =>  c_aca_rec.future_term_sequence_number,
               x_def_acad_cal_type             =>  NULL,
               x_def_acad_ci_sequence_num              =>  NULL,
               x_def_prev_term_adm_appl_num            =>  c_aca_rec.def_prev_term_adm_appl_num,
               x_def_prev_appl_sequence_num            =>  c_aca_rec.def_prev_appl_sequence_num,
               x_def_term_adm_appl_num               =>  c_aca_rec.def_term_adm_appl_num,
               x_def_appl_sequence_num               =>  c_aca_rec.def_appl_sequence_num,
               x_appl_inst_status            =>  c_aca_rec.appl_inst_status,
               x_ais_reason              =>  c_aca_rec.ais_reason,
               x_decline_ofr_reason          =>  NULL
                      );



    IF p_interface = 'FORM' OR p_interface = 'SS' THEN
  -- Raises  oracle.apps.igs.pe.rescal.os Business event for Self service and forms
        igs_ad_wf_001.wf_raise_event ( p_person_id             => c_aca_rec.Person_Id,
                                       p_raised_for            => 'AOD',
                                       p_admission_appl_number => c_aca_rec.Admission_Appl_Number,
                                       p_nominated_course_cd   => c_aca_rec.Nominated_Course_cd,
               p_sequence_number       => c_aca_rec.Sequence_Number,
               p_old_outcome_status    => c_aca_rec.adm_outcome_status,
               p_new_outcome_status    => IGS_AD_GEN_009.ADMP_GET_SYS_AOS('PENDING')
                                     );


    ELSIF p_interface = 'IMPORT' THEN
       --Raise  oracle.apps.igs.pe.rescal.io Business event   for Decision Import process
        igs_ad_wf_001.wf_raise_event ( p_person_id             => c_aca_rec.Person_Id,
                                       p_raised_for            => 'IOD',
                                       p_admission_appl_number => c_aca_rec.Admission_Appl_Number,
                                       p_nominated_course_cd   => c_aca_rec.Nominated_Course_cd,
               p_sequence_number       => c_aca_rec.Sequence_Number,
                             p_old_outcome_status    => c_aca_rec.adm_outcome_status,
                           p_new_outcome_status    => IGS_AD_GEN_009.ADMP_GET_SYS_AOS('PENDING')
                                     );
    END IF;

END LOOP;

END Reconsider_Appl_Inst ;


-- following function would be invoked only  from Admin Dashboard for reconsideration
PROCEDURE Recon_Appl_inst (
                           p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
         p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
         p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
         p_acai_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE,
         p_interface            VARCHAR2  -- Interface which has raised reconsideration ( Forms,Self service, Import process)
      )
IS

  CURSOR  cur_ad_ps_appl  (cur_person_id         IGS_AD_PS_APPL.person_id%TYPE ,
                         cur_admission_appl_number   IGS_AD_PS_APPL.admission_appl_number%TYPE ,
                         cur_nominated_course_cd     IGS_AD_PS_APPL.nominated_course_cd%TYPE ) IS
         SELECT  rowid , IGS_AD_PS_APPL.*
         FROM    IGS_AD_PS_APPL
         WHERE   person_id = CUR_person_id   AND
                 admission_appl_number = CUR_admission_appl_number AND
                 nominated_course_cd = CUR_nominated_course_cd;

cur_ad_ps_appl_rec        cur_ad_ps_appl%ROWTYPE ;



BEGIN


  OPEN   cur_ad_ps_appl(p_person_id ,p_ADMISSION_APPL_NUMBER,p_NOMINATED_COURSE_CD);
  FETCH cur_ad_ps_appl INTO   cur_ad_ps_appl_rec;
         IGS_AD_PS_APPL_PKG.UPDATE_ROW (
           X_ROWID                       =>  cur_ad_ps_appl_rec.ROWID     ,
           X_PERSON_ID                   =>  cur_ad_ps_appl_rec.PERSON_ID  ,
           X_ADMISSION_APPL_NUMBER       =>  cur_ad_ps_appl_rec.ADMISSION_APPL_NUMBER ,
           X_NOMINATED_COURSE_CD         =>  cur_ad_ps_appl_rec.NOMINATED_COURSE_CD   ,
           X_TRANSFER_COURSE_CD          =>  cur_ad_ps_appl_rec.transfer_course_cd,
           X_BASIS_FOR_ADMISSION_TYPE    =>  cur_ad_ps_appl_rec.basis_for_admission_type,
           X_ADMISSION_CD                =>  cur_ad_ps_appl_rec.admission_cd,
           X_COURSE_RANK_SET             =>  cur_ad_ps_appl_rec.course_rank_set,
           X_COURSE_RANK_SCHEDULE        =>  cur_ad_ps_appl_rec.course_rank_schedule,
           X_REQ_FOR_RECONSIDERATION_IND =>  'Y',
           X_REQ_FOR_ADV_STANDING_IND    =>  cur_ad_ps_appl_rec.req_for_adv_standing_ind ,
           X_MODE                        =>  'S' ) ;

  CLOSE  cur_ad_ps_appl;

   Reconsider_Appl_Inst (  p_person_id,
         p_admission_appl_number,
         p_nominated_course_cd,
         p_acai_sequence_number,
           p_interface
                  );

END  Recon_Appl_inst;

-----------------***************** check_adm_appl_inst_stat  overloaded function to invoke in Selfservice ***------------------------------------
FUNCTION  check_adm_appl_inst_stat(
  p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
  p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
  p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE  DEFAULT NULL,
  p_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE DEFAULT NULL,
  p_updateable VARCHAR2 DEFAULT 'N'                                                 -- apadegal - TD001 - IGS.M.
  )
  RETURN VARCHAR2
  IS

  l_status  VARCHAR2(1):= 'N';

BEGIN

   check_adm_appl_inst_stat( p_person_id,
                             p_admission_appl_number,
                             p_nominated_course_cd,
                             p_sequence_number,
                             p_updateable);
   RETURN 'Y';

EXCEPTION
   WHEN OTHERS THEN
     RETURN 'N';
END check_adm_appl_inst_stat;

PROCEDURE ins_dummy_pend_hist_rec ( p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
            p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
            p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE
          )
IS

CURSOR c_inst IS
          SELECT rowid,acai.*
    FROM  igs_ad_ps_appl_inst_all acai
    WHERE        acai.person_id             =  p_person_id AND
           acai.admission_appl_number   =  p_admission_appl_number AND
           acai.nominated_course_cd       =  p_nominated_course_cd AND
           acai.future_term_adm_appl_number IS NULL  AND
                       acai.future_term_sequence_number IS NULL AND
                       acai.def_term_adm_appl_num IS NULL AND
                       acai.def_appl_sequence_num IS NULL AND
           NVL(IGS_AD_GEN_007.ADMP_GET_SAAS(acai.APPL_INST_STATUS),'NULL') <> 'WITHDRAWN' AND
                       IGS_AD_GEN_008.ADMP_GET_SAOS(acai.ADM_OUTCOME_STATUS) =  'PENDING'
           FOR UPDATE NOWAIT;

c_inst_rec c_inst%ROWTYPE;

CURSOR c_inst_last_who ( cp_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
             cp_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
             cp_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
             cp_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE
           )
    IS
       SELECT    last_update_date
       FROM      igs_ad_ps_appl_inst_all   acinst
       WHERE     acinst.person_id     =  cp_person_id AND
           acinst.admission_appl_number   =  cp_admission_appl_number AND
           acinst.nominated_course_cd       =  cp_nominated_course_cd AND
           acinst.sequence_number           =  cp_sequence_number;

c_inst_last_who_rec  c_inst_last_who%ROWTYPE;


 CURSOR c_old_hist_dt ( cp_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
            cp_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
            cp_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
            cp_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE,
            cp_old_update_on DATE)
   IS
             SELECT 'x'
             FROM IGS_AD_PS_APLINSTHST   ahist
             WHERE person_id = cp_person_id
             AND   admission_appl_number = cp_admission_appl_number
             AND   nominated_course_cd = cp_nominated_course_cd
             AND   sequence_number = cp_sequence_number
             AND   hist_start_dt = cp_old_update_on;

CURSOR  cur_ad_ps_appl (  cp_person_id         igs_ad_ps_appl.person_id%type ,
                          cp_admission_appl_number   igs_ad_ps_appl.admission_appl_number%type ,
                          cp_nominated_course_cd     igs_ad_ps_appl.nominated_course_cd%type )
IS
     SELECT req_for_reconsideration_ind
     FROM   igs_ad_ps_appl
           WHERE  person_id = cp_person_id   and
      admission_appl_number = cp_admission_appl_number and
                  nominated_course_cd = cp_nominated_course_cd;


hist_rec     IGS_AD_PS_APLINSTHST%ROWTYPE;

l_dummy         VARCHAR2(1);
lv_rowid        VARCHAR2(25);


BEGIN

      IF ( p_person_id             IS NOT NULL   AND
     p_admission_appl_number IS NOT NULL   AND
     p_nominated_course_cd   IS NOT NULL
   )
      THEN
          FOR c_inst_rec IN c_inst --
          LOOP

                            --calling INSTANCE TBH, but not updating anything.. this is just to create a dummy history record.

          IGS_AD_PS_APPL_INST_PKG.UPDATE_ROW
                  (
                  X_Mode                              => 'S',
                  X_RowId                             => c_inst_rec.rowid,
                  X_Person_Id                         => c_inst_rec.Person_Id,
                  X_Admission_Appl_Number             => c_inst_rec.Admission_Appl_Number,
                  X_Nominated_Course_Cd               => c_inst_rec.Nominated_Course_Cd,
                  X_Sequence_Number                   => c_inst_rec.Sequence_Number,
                  X_Predicted_Gpa                     => c_inst_rec.Predicted_Gpa,
                  X_Academic_Index                    => c_inst_rec.Academic_Index,
                  X_Adm_Cal_Type                      => c_inst_rec.Adm_Cal_Type,
                  X_App_File_Location                 => c_inst_rec.App_File_Location,
                  X_Adm_Ci_Sequence_Number            => c_inst_rec.Adm_Ci_Sequence_Number,
                  X_Course_Cd                         => c_inst_rec.Course_Cd,
                  X_App_Source_Id                     => c_inst_rec.App_Source_Id,
                  X_Crv_Version_Number                => c_inst_rec.Crv_Version_Number,
                  X_Waitlist_Rank                     => c_inst_rec.Waitlist_Rank,
                  X_Location_Cd                       => c_inst_rec.Location_Cd,
                  X_Attent_Other_Inst_Cd              => c_inst_rec.Attent_Other_Inst_Cd,
                  X_Attendance_Mode                   => c_inst_rec.Attendance_Mode,
                  X_Edu_Goal_Prior_Enroll_Id          => c_inst_rec.Edu_Goal_Prior_Enroll_Id,
                  X_Attendance_Type                   => c_inst_rec.Attendance_Type,
                  X_Decision_Make_Id                  => c_inst_rec.Decision_Make_Id,
                  X_Unit_Set_Cd                       => c_inst_rec.Unit_Set_Cd,
                  X_Decision_Date                     => c_inst_rec.Decision_Date,
                  X_Attribute_Category                => c_inst_rec.Attribute_Category,
                  X_Attribute1                        => c_inst_rec.Attribute1,
                  X_Attribute2                        => c_inst_rec.Attribute2,
                  X_Attribute3                        => c_inst_rec.Attribute3,
                  X_Attribute4                        => c_inst_rec.Attribute4,
                  X_Attribute5                        => c_inst_rec.Attribute5,
                  X_Attribute6                        => c_inst_rec.Attribute6,
                  X_Attribute7                        => c_inst_rec.Attribute7,
                  X_Attribute8                        => c_inst_rec.Attribute8,
                  X_Attribute9                        => c_inst_rec.Attribute9,
                  X_Attribute10                       => c_inst_rec.Attribute10,
                  X_Attribute11                       => c_inst_rec.Attribute11,
                  X_Attribute12                       => c_inst_rec.Attribute12,
                  X_Attribute13                       => c_inst_rec.Attribute13,
                  X_Attribute14                       => c_inst_rec.Attribute14,
                  X_Attribute15                       => c_inst_rec.Attribute15,
                  X_Attribute16                       => c_inst_rec.Attribute16,
                  X_Attribute17                       => c_inst_rec.Attribute17,
                  X_Attribute18                       => c_inst_rec.Attribute18,
                  X_Attribute19                       => c_inst_rec.Attribute19,
                  X_Attribute20                       => c_inst_rec.Attribute20,
                  X_Decision_Reason_Id                => c_inst_rec.Decision_Reason_Id,
                  X_Us_Version_Number                 => c_inst_rec.Us_Version_Number,
                  X_Decision_Notes                    => c_inst_rec.Decision_Notes,
                  X_Pending_Reason_Id                 => c_inst_rec.Pending_Reason_Id,
                  X_Preference_Number                 => c_inst_rec.Preference_Number,
                  X_Adm_Doc_Status                    => c_inst_rec.Adm_Doc_Status,
                  X_Adm_Entry_Qual_Status             => c_inst_rec.Adm_Entry_Qual_Status,
                  X_Deficiency_In_Prep                => c_inst_rec.Deficiency_In_Prep,
                  X_Late_Adm_Fee_Status               => c_inst_rec.Late_Adm_Fee_Status,
                  X_Spl_Consider_Comments             => c_inst_rec.Spl_Consider_Comments,
                  X_Apply_For_Finaid                  => c_inst_rec.Apply_For_Finaid,
                  X_Finaid_Apply_Date                 => c_inst_rec.Finaid_Apply_Date,
                  X_Adm_Outcome_Status                => c_inst_rec.Adm_Outcome_Status,
                  X_Adm_Otcm_Stat_Auth_Per_Id         => c_inst_rec.Adm_Otcm_Status_Auth_Person_Id,
                  X_Adm_Outcome_Status_Auth_Dt        => c_inst_rec.Adm_Outcome_Status_Auth_Dt,
                  X_Adm_Outcome_Status_Reason         => c_inst_rec.Adm_Outcome_Status_Reason,
                  X_Offer_Dt                          => c_inst_rec.Offer_Dt,
                  X_Offer_Response_Dt                 => c_inst_rec.Offer_Response_Dt,
                  X_Prpsd_Commencement_Dt             => c_inst_rec.Prpsd_Commencement_Dt,
                  X_Adm_Cndtnl_Offer_Status           => c_inst_rec.Adm_Cndtnl_Offer_Status,
                  X_Cndtnl_Offer_Satisfied_Dt         => c_inst_rec.Cndtnl_Offer_Satisfied_Dt,
                  X_Cndnl_Ofr_Must_Be_Stsfd_Ind       => c_inst_rec.Cndtnl_Offer_Must_Be_Stsfd_Ind,
                  X_Adm_Offer_Resp_Status             => c_inst_rec.Adm_Offer_Resp_Status,
                  X_Actual_Response_Dt                => c_inst_rec.Actual_Response_Dt,
                  X_Adm_Offer_Dfrmnt_Status           =>  c_inst_rec.Adm_Offer_Dfrmnt_Status,
                  X_Deferred_Adm_Cal_Type             =>  c_inst_rec.Deferred_Adm_Cal_Type,
                  X_Deferred_Adm_Ci_Sequence_Num      => c_inst_rec.Deferred_Adm_Ci_Sequence_Num,
                  X_Deferred_Tracking_Id              => c_inst_rec.Deferred_Tracking_Id,
                  X_Ass_Rank                          => c_inst_rec.Ass_Rank,
                  X_Secondary_Ass_Rank                => c_inst_rec.Secondary_Ass_Rank,
                  X_Intr_Accept_Advice_Num            => c_inst_rec.Intrntnl_Acceptance_Advice_Num,
                  X_Ass_Tracking_Id                   => c_inst_rec.Ass_Tracking_Id,
                  X_Fee_Cat                           =>  c_inst_rec.Fee_Cat,
                  X_Hecs_Payment_Option               =>  c_inst_rec.Hecs_Payment_Option,
                  X_Expected_Completion_Yr            => c_inst_rec.Expected_Completion_Yr,
                  X_Expected_Completion_Perd          =>  c_inst_rec.Expected_Completion_Perd,
                  X_Correspondence_Cat                =>  c_inst_rec.Correspondence_Cat,
                  X_Enrolment_Cat                     =>  c_inst_rec.Enrolment_Cat,
                  X_Funding_Source                    =>  c_inst_rec.Funding_Source,
                  X_Applicant_Acptnce_Cndtn           =>  c_inst_rec.Applicant_Acptnce_Cndtn,
                  X_Cndtnl_Offer_Cndtn                =>  c_inst_rec.Cndtnl_Offer_Cndtn,
                  X_SS_APPLICATION_ID                 =>  c_inst_rec.SS_APPLICATION_ID,
                  X_SS_PWD                            =>  c_inst_rec.SS_PWD,
                  X_AUTHORIZED_DT                     =>  c_inst_rec.Authorized_dt,
                  X_AUTHORIZING_PERS_ID               => c_inst_rec.authorizing_pers_id,
                  X_ENTRY_STATUS                      =>  c_inst_rec.entry_status,
                  X_ENTRY_LEVEL                       =>  c_inst_rec.entry_level,
                  X_SCH_APL_TO_ID                     =>  c_inst_rec.sch_apl_to_id,
                  X_IDX_CALC_DATE                     =>  c_inst_rec.IDX_CALC_DATE,
                  X_WAITLIST_STATUS                   =>  c_inst_rec.Waitlist_Status,
                  X_Attribute21                        =>  c_inst_rec.Attribute21,
                  X_Attribute22                        =>  c_inst_rec.Attribute22,
                  X_Attribute23                        =>  c_inst_rec.Attribute23,
                  X_Attribute24                        =>  c_inst_rec.Attribute24,
                  X_Attribute25                        =>  c_inst_rec.Attribute25,
                  X_Attribute26                        =>  c_inst_rec.Attribute26,
                  X_Attribute27                        =>  c_inst_rec.Attribute27,
                  X_Attribute28                        =>  c_inst_rec.Attribute28,
                  X_Attribute29                        =>  c_inst_rec.Attribute29,
                  X_Attribute30                       =>  c_inst_rec.Attribute30,
                  X_Attribute31                       =>  c_inst_rec.Attribute31,
                  X_Attribute32                       =>  c_inst_rec.Attribute32,
                  X_Attribute33                       =>  c_inst_rec.Attribute33,
                  X_Attribute34                       =>  c_inst_rec.Attribute34,
                  X_Attribute35                       =>  c_inst_rec.Attribute35,
                  X_Attribute36                       =>  c_inst_rec.Attribute36,
                  X_Attribute37                       =>  c_inst_rec.Attribute37,
                  X_Attribute38                       =>  c_inst_rec.Attribute38,
                  X_Attribute39                       =>  c_inst_rec.Attribute39,
                  X_Attribute40                       =>  c_inst_rec.Attribute40,
                  x_fut_acad_cal_type                 =>  c_inst_rec.future_acad_cal_type,
                  x_fut_acad_ci_sequence_number       =>  c_inst_rec.future_acad_ci_sequence_number,
                  x_fut_adm_cal_type                  =>  c_inst_rec.future_adm_cal_type,
                  x_fut_adm_ci_sequence_number        =>  c_inst_rec.future_adm_ci_sequence_number,
                  x_prev_term_adm_appl_number         =>  c_inst_rec.previous_term_adm_appl_number,
                  x_prev_term_sequence_number         =>  c_inst_rec.previous_term_sequence_number,
                  x_fut_term_adm_appl_number          =>  c_inst_rec.future_term_adm_appl_number,
                  x_fut_term_sequence_number          =>  c_inst_rec.future_term_sequence_number,
                  x_def_acad_cal_type                           =>c_inst_rec.def_acad_cal_type,
                  x_def_acad_ci_sequence_num           =>c_inst_rec.def_acad_ci_sequence_num,
                  x_def_prev_term_adm_appl_num    =>c_inst_rec.def_prev_term_adm_appl_num,
                  x_def_prev_appl_sequence_num      =>c_inst_rec.def_prev_appl_sequence_num,
                  x_def_term_adm_appl_num              =>c_inst_rec.def_term_adm_appl_num,
                  x_def_appl_sequence_num                =>c_inst_rec.def_appl_sequence_num,
                  x_appl_inst_status    =>c_inst_rec.APPL_INST_STATUS,  --apadegal adtd001 IGS.m
                  x_ais_reason      =>c_inst_rec.AIS_REASON,       --apadegal adtd001 IGS.m
                  x_decline_ofr_reason    =>c_inst_rec.DECLINE_OFR_REASON --apadegal adtd001 IGS.m
                  );


                  -- Fetch New Who column values
                  hist_rec.person_id             := c_inst_rec.person_id;
                  hist_rec.admission_appl_number := c_inst_rec.admission_appl_number;
                  hist_rec.nominated_course_cd   := c_inst_rec.nominated_course_cd;
                  hist_rec.sequence_number       := c_inst_rec.sequence_number;
                  hist_rec.hist_start_dt         := c_inst_rec.last_update_date;
                  hist_rec.hist_who              := c_inst_rec.last_updated_by;


                  OPEN cur_ad_ps_appl (c_inst_rec.person_id,
                                       c_inst_rec.admission_appl_number,
                     c_inst_rec.nominated_course_cd);
                    FETCH cur_ad_ps_appl INTO hist_rec.RECONSIDER_FLAG ;
                  CLOSE cur_ad_ps_appl;

                 -- to get the end date for history record
                  OPEN c_inst_last_who (c_inst_rec.person_id,
                      c_inst_rec.admission_appl_number,
                      c_inst_rec.nominated_course_cd,
                      c_inst_rec.sequence_number
                     );
                  FETCH c_inst_last_who INTO c_inst_last_who_rec;
                  CLOSE c_inst_last_who;

                  hist_rec.hist_end_dt           := c_inst_last_who_rec.last_update_date ;

                  l_dummy := NULL;
                  OPEN c_old_hist_dt (c_inst_rec.person_id,
                                      c_inst_rec.admission_appl_number,
                    c_inst_rec.nominated_course_cd,
                    c_inst_rec.sequence_number,
                    hist_rec.hist_start_dt);
                  FETCH c_old_hist_dt INTO l_dummy;
                  CLOSE c_old_hist_dt;
                  IF l_dummy IS NOT NULL THEN
                -- add one second from the hist_start_dt value
                -- to avoid a primary key constraint from occurring
                -- when saving the record.  Modified as part of Bug:2315674
                hist_rec.hist_start_dt := hist_rec.hist_start_dt +1 / (60*24*60);
                hist_rec.hist_end_dt   := hist_rec.hist_end_dt +1 / (60*24*60);
                  END IF;

                  -- call History TBH
                  lv_rowid := NULL;
                  IGS_AD_PS_APLINSTHST_Pkg.Insert_Row (
                        X_Mode                              => 'R',
                        X_RowId                             => lv_rowid,
                        X_Person_Id                         => hist_rec.person_id,
                        X_Admission_Appl_Number             => hist_rec.admission_appl_number,
                        X_Nominated_Course_Cd               => hist_rec.nominated_course_cd,
                        X_Sequence_Number                   => hist_rec.sequence_number,
                        X_Hist_Start_Dt                     => hist_rec.hist_start_dt,
                        X_Hist_End_Dt                       => hist_rec.hist_end_dt,
                        X_Hist_Who                          => hist_rec.hist_who,
                        X_Hist_Offer_Round_Number           => Null,
                        X_Adm_Cal_Type                      => hist_rec.adm_cal_type,
                        X_Adm_Ci_Sequence_Number            => hist_rec.adm_ci_sequence_number,
                        X_Course_Cd                         => hist_rec.course_cd,
                        X_Crv_Version_Number                => hist_rec.crv_version_number,
                        X_Location_Cd                       => hist_rec.location_cd,
                        X_Attendance_Mode                   => hist_rec.attendance_mode,
                        X_Attendance_Type                   => hist_rec.attendance_type,
                        X_Unit_Set_Cd                       => hist_rec.unit_set_cd,
                        X_Us_Version_Number                 => hist_rec.us_version_number,
                        X_Preference_Number                 => hist_rec.preference_number,
                        X_Adm_Doc_Status                    => hist_rec.adm_doc_status,
                        X_Adm_Entry_Qual_Status             => hist_rec.adm_entry_qual_status,
                        X_Late_Adm_Fee_Status               => hist_rec.late_adm_fee_status,
                        X_Adm_Outcome_Status                => hist_rec.adm_outcome_status,
                        X_ADM_OTCM_STATUS_AUTH_PER_ID       => hist_rec.adm_otcm_status_auth_person_id,
                        X_Adm_Outcome_Status_Auth_Dt        => hist_rec.adm_outcome_status_auth_dt,
                        X_Adm_Outcome_Status_Reason         => hist_rec.adm_outcome_status_reason,
                        X_Offer_Dt                          => hist_rec.offer_dt,
                        X_Offer_Response_Dt                 => hist_rec.offer_response_dt,
                        X_Prpsd_Commencement_Dt             => hist_rec.prpsd_commencement_dt,
                        X_Adm_Cndtnl_Offer_Status           => hist_rec.adm_cndtnl_offer_status,
                        X_Cndtnl_Offer_Satisfied_Dt         => hist_rec.cndtnl_offer_satisfied_dt,
                        X_CNDTNL_OFR_MUST_BE_STSFD_IND      => hist_rec.cndtnl_offer_must_be_stsfd_ind,
                        X_Adm_Offer_Resp_Status             => hist_rec.adm_offer_resp_status,
                        X_Actual_Response_Dt                => hist_rec.actual_response_dt,
                        X_Adm_Offer_Dfrmnt_Status           => hist_rec.adm_offer_dfrmnt_status,
                        X_Deferred_Adm_Cal_Type             => hist_rec.deferred_adm_cal_type,
                        X_Deferred_Adm_Ci_Sequence_Num      => hist_rec.deferred_adm_ci_sequence_num,
                        X_Deferred_Tracking_Id              => hist_rec.deferred_tracking_id,
                        X_Ass_Rank                          => hist_rec.ass_rank,
                        X_Secondary_Ass_Rank                => hist_rec.secondary_ass_rank,
                        X_INTRNTNL_ACCEPT_ADVICE_NUM        => hist_rec.intrntnl_acceptance_advice_num,
                        X_Ass_Tracking_Id                   => hist_rec.ass_tracking_id,
                        X_Fee_Cat                           => hist_rec.fee_cat,
                        X_Hecs_Payment_Option               => hist_rec.hecs_payment_option,
                        X_Expected_Completion_Yr            => hist_rec.expected_completion_yr,
                        X_Expected_Completion_Perd          => hist_rec.expected_completion_perd,
                        X_Correspondence_Cat                => hist_rec.correspondence_cat,
                        X_Enrolment_Cat                     => hist_rec.enrolment_cat,
                        X_Funding_Source                    => hist_rec.funding_source,
                        X_Applicant_Acptnce_Cndtn           => hist_rec.applicant_acptnce_cndtn,
                        X_Cndtnl_Offer_Cndtn                => hist_rec.cndtnl_offer_cndtn,
                        X_Org_Id        => igs_ge_gen_003.get_org_id,
                        X_Appl_inst_status      => hist_rec.appl_inst_status,
                        X_DECISION_DATE                     => hist_rec.DECISION_DATE,
                        X_DECISION_MAKE_ID                  => hist_rec.DECISION_MAKE_ID,
                        X_DECISION_REASON_ID                => hist_rec.DECISION_REASON_ID,
                        X_PENDING_REASON_ID                 => hist_rec.PENDING_REASON_ID,
                        X_WAITLIST_STATUS                   => hist_rec.WAITLIST_STATUS,
                        X_WAITLIST_RANK                     => hist_rec.WAITLIST_RANK,
                        X_FUTURE_ACAD_CAL_TYPE              => hist_rec.FUTURE_ACAD_CAL_TYPE,
                        X_FUTURE_ACAD_CI_SEQUENCE_NUM       => hist_rec.FUTURE_ACAD_CI_SEQUENCE_NUM,
                        X_FUTURE_ADM_CAL_TYPE               => hist_rec.FUTURE_ADM_CAL_TYPE,
                        X_FUTURE_ADM_CI_SEQUENCE_NUM        => hist_rec.FUTURE_ADM_CI_SEQUENCE_NUM,
                        X_DEF_ACAD_CAL_TYPE                 => hist_rec.DEF_ACAD_CAL_TYPE,
                        X_DEF_ACAD_CI_SEQUENCE_NUM          => hist_rec.DEF_ACAD_CI_SEQUENCE_NUM,
                        X_RECONSIDER_FLAG                   => hist_rec.RECONSIDER_FLAG,
                        X_DECLINE_OFR_REASON                => hist_rec.DECLINE_OFR_REASON

                    );

               END LOOP;
  END IF;
END  ins_dummy_pend_hist_rec;


-- End apadegal  TD001 build.


-- 02-NOV-05 ANWEST Created for IGS.M ADTD002 AT Testing Issue #327
FUNCTION Is_EntQualCode_Allowed (p_person_id IN NUMBER ,
                                 p_admission_appl_number IN NUMBER ,
                                 p_nominated_course_cd IN VARCHAR2,
                                 p_sequence_number IN NUMBER)
RETURN VARCHAR2 IS

  CURSOR c_aa_acaiv IS
    SELECT  acaiv.future_term_adm_appl_number,
            acaiv.future_term_sequence_number,
            acaiv.def_term_adm_appl_num,
            acaiv.def_appl_sequence_num
    FROM    igs_ad_ps_appl_inst   acaiv
    WHERE   acaiv.person_id             = p_person_id             AND
            acaiv.admission_appl_number = p_admission_appl_number AND
            acaiv.nominated_course_cd   = p_nominated_course_cd   AND
            acaiv.sequence_number       = p_sequence_number;

  v_aa_acaiv_rec    c_aa_acaiv%ROWTYPE;
  v_ent_qual_codes  VARCHAR2(1) DEFAULT 'N';

BEGIN

  OPEN c_aa_acaiv;
  FETCH c_aa_acaiv INTO v_aa_acaiv_rec;
  IF c_aa_acaiv%FOUND THEN

    IF ( v_aa_acaiv_rec.future_term_adm_appl_number IS NULL AND
         v_aa_acaiv_rec.future_term_sequence_number IS NULL AND
         v_aa_acaiv_rec.def_term_adm_appl_num       IS NULL AND
         v_aa_acaiv_rec.def_appl_sequence_num       IS NULL) THEN

      v_ent_qual_codes := 'Y';

    END IF;
    CLOSE c_aa_acaiv;

  ELSE

    CLOSE c_aa_acaiv;

  END IF;

  RETURN v_ent_qual_codes;

EXCEPTION
WHEN OTHERS THEN
  IF c_aa_acaiv%ISOPEN THEN
    CLOSE c_aa_acaiv;
  END IF;
  v_ent_qual_codes := 'N';
  RETURN v_ent_qual_codes;
END Is_EntQualCode_Allowed;

END igs_ad_gen_002;




/
