--------------------------------------------------------
--  DDL for Package Body IGS_PT_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PT_GEN_PKG" AS
/* $Header: IGSPT01B.pls 115.4 2003/12/11 16:03:12 amuthu noship $ */

-------------------------------------------------------------------------------
  --Created by  : msrinivi ( Oracle IDC)
  --Date created: 29-Jun-2002
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --stutta      27-NOV-2003     Modified call to igs_ss_enr_details.enrp_get_prgm_for_career
  --                            in function get_program_info by passing in two new parameters
  --                            term_cal_type, term_sequence_number. term record build 2829263
  --amuthu      11-dec-2003     replaced IGS_SS_ENR_DETAILS1 with IGS_SS_ENR_DETAILS
  ------------------------------------------------------------------------------
/*
   This function returns the enrolled program info for a student in a term as a concat string.
  This is used in portal where only the first 5 enrolled units are displayed
  Career info sets to be set in the session so that when the user navigates
  to the SS screen, the schedule is queried already.
  The logic to find the pri prog for the first 5 enrolled units is as follows :

  1. Select list of programs with units for the displayed term in the portlet
  2. If single program
        a. Always use it
     else
        b. If key program in the list
                - Use it
          else
                - Use the program from the list with the latest commencement date
*/

FUNCTION get_program_info(
                             p_person_id               IN VARCHAR2,
                             p_load_cal_type           IN VARCHAR2,
                             p_load_sequence_number    IN VARCHAR2,
                             p_num_units               IN NUMBER DEFAULT 5
) RETURN VARCHAR2 AS

-- This cursor is to be used if the career_centric model is enabled

CURSOR c_enr_progs_in_prog_cntr IS
       SELECT course_cd
       FROM igs_en_su_attempt
       WHERE person_id = p_person_id
       AND unit_attempt_status = 'ENROLLED'
       AND (cal_type,ci_sequence_number) IN
           (
             SELECT teach_cal_type,teach_ci_sequence_number  FROM
             igs_ca_load_to_teach_v  where load_cal_type = p_load_cal_type
             AND load_ci_sequence_number = p_load_sequence_number
            )
        AND rownum <= p_num_units
        ORDER BY unit_cd;

-- This cursor is to be used if the career_centric model is enabled
-- It has the additional check to fetch enrolled units from Pri Prog

CURSOR c_enr_progs_in_car_cntr IS
       SELECT course_cd
       FROM igs_en_su_attempt
       WHERE person_id = p_person_id
       AND unit_attempt_status = 'ENROLLED'
       AND (cal_type,ci_sequence_number) IN
           (
             SELECT teach_cal_type,teach_ci_sequence_number  FROM
             igs_ca_load_to_teach_v  where load_cal_type = p_load_cal_type
             AND load_ci_sequence_number = p_load_sequence_number
            )
        AND course_cd IN (
                             SELECT course_cd FROM igs_en_stdnt_ps_att
                             WHERE  primary_program_type = 'PRIMARY'
                             AND    person_id = p_person_id
                             AND course_attempt_status  IN ('INACTIVE','ENROLLED')
                         )
        AND rownum <= p_num_units
        ORDER BY unit_cd;

CURSOR c_key_program(p_prog_cd VARCHAR2) IS
      SELECT NVL(key_program,'N') , version_number, title
      FROM igs_en_sca_v
      WHERE COURSE_CD      = p_prog_cd
      AND PERSON_ID        = p_person_id
      ORDER BY commencement_dt DESC;

 CURSOR c_career(p_prog_cd igs_ps_ver_all.course_cd%TYPE,p_ver_num igs_ps_ver_all.version_number%TYPE) IS
 SELECT course_type
 FROM igs_ps_ver_all
 WHERE course_cd = p_prog_cd
 AND version_number = p_ver_num ;


l_key_prog_cd igs_en_stdnt_ps_att_all.course_cd%TYPE;
l_key_prog_ind igs_en_stdnt_ps_att_all.key_program%TYPE DEFAULT 'N';
l_single_prog_exists BOOLEAN DEFAULT TRUE;
l_curr_prog_cd igs_en_stdnt_ps_att_all.course_cd%TYPE;

l_primary_program igs_en_stdnt_ps_att_all.course_cd%TYPE;
l_primary_program_version igs_en_stdnt_ps_att_all.version_number%TYPE;
l_programlist VARCHAR2(2000);

p_program_cd              igs_en_stdnt_ps_att_all.course_cd%TYPE;
p_program_ver             igs_en_stdnt_ps_att_all.version_number%TYPE;
p_career                  igs_ps_ver.course_type%TYPE;
p_program_list            VARCHAR2(2000);
p_program_title           VARCHAR2(200);
l_curr_prog_cd_tmp        igs_en_stdnt_ps_att_all.course_cd%TYPE;

BEGIN

  IF fnd_profile.value('CAREER_MODEL_ENABLED') = 'Y' THEN
    FOR c_enr_progs_in_term_rec IN c_enr_progs_in_car_cntr  LOOP  -- If career centric model
      EXIT WHEN c_enr_progs_in_car_cntr%NOTFOUND;

      IF c_enr_progs_in_car_cntr%rowcount = 1 THEN
        -- Storing the first prog in a var
        l_curr_prog_cd := c_enr_progs_in_term_rec.course_cd;
      END IF;

      OPEN  c_key_program(c_enr_progs_in_term_rec.course_cd);
      FETCH c_key_program INTO l_key_prog_ind, p_program_ver,p_program_title;
        IF l_key_prog_ind = 'Y' THEN
           l_key_prog_cd := c_enr_progs_in_term_rec.course_cd;
        END IF;
      CLOSE c_key_program;
    END LOOP;

  ELSE  -- If program centric model
    FOR c_enr_progs_in_term_rec IN c_enr_progs_in_prog_cntr  LOOP
      EXIT WHEN c_enr_progs_in_prog_cntr%NOTFOUND;

      IF c_enr_progs_in_prog_cntr%rowcount = 1 THEN
        -- Storing the first prog in a var
        l_curr_prog_cd := c_enr_progs_in_term_rec.course_cd;
      END IF;

      OPEN  c_key_program(c_enr_progs_in_term_rec.course_cd);
      FETCH c_key_program INTO l_key_prog_ind, p_program_ver,p_program_title;
        IF l_key_prog_ind = 'Y' THEN
           l_key_prog_cd := c_enr_progs_in_term_rec.course_cd;
        END IF;
      CLOSE c_key_program;
    END LOOP;
  END IF;

    IF l_key_prog_cd IS NOT NULL THEN
      p_program_cd := l_key_prog_cd;
    ELSE
      p_program_cd := l_curr_prog_cd;
    END IF;

    IF p_program_cd IS NOT NULL THEN
      -- to get the program version number
      OPEN  c_key_program(p_program_cd);
      FETCH c_key_program INTO l_curr_prog_cd_tmp, p_program_ver, p_program_title;
      CLOSE c_key_program ;
    END IF;

    IF NVL(fnd_profile.value('CAREER_MODEL_ENABLED'),'N') = 'Y' THEN

      --To get career information
      OPEN c_career(p_program_cd,p_program_ver);
      FETCH c_career INTO p_career;
      CLOSE c_career;

      IF p_career IS NOT NULL THEN
        IGS_SS_ENR_DETAILS.ENRP_GET_PRGM_FOR_CAREER(
        p_primary_program         => p_program_cd,
        p_primary_program_version => p_program_ver,
        p_programlist             => p_program_list,
        p_person_id               => p_person_id,
        p_carrer                  => p_career,
        p_term_cal_type           => p_load_cal_type,
        p_term_sequence_number    => p_load_sequence_number
      );
      END IF;
    END IF;
     RETURN NVL(p_program_cd,'') ||'*'||  NVL(p_program_ver,'') ||  '*'|| NVL(p_program_title,'') || '*'|| NVL(p_career,'') || '*'|| NVL(p_program_list,'') ;

  END get_program_info;



END igs_pt_gen_pkg ;

/
