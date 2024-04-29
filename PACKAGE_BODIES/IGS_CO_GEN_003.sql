--------------------------------------------------------
--  DDL for Package Body IGS_CO_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_GEN_003" AS
/* $Header: IGSCO20B.pls 120.1 2006/01/18 22:30:08 skpandey noship $ */

  FUNCTION get_per_addr_for_corr (
    p_person_id                    IN     NUMBER,
    p_case_type                    IN     VARCHAR2
  ) RETURN VARCHAR2 AS

    /*******************************************************************************
    Created by   : rbezawad
    Date created : 04-Feb-2002
    Purpose      : Function to Get Person Name and Address for Correspondence.

    Known limitations/enhancements/remarks:

    Change History: (who, when, what: NO CREATION RECORDS HERE!)
    Who             When            What
    asbala          15-JAN-2004     3349171: Incorrect usage of fnd_lookup_values view
    *******************************************************************************/
    --Local variable to Identify the the Line Break Character.
    l_line_break VARCHAR2(10);

    --
    -- Cursor for selection of the person name in seperate parts to allow construction based on the user preferences.
    --
    CURSOR cur_person_name ( cp_person_id IN NUMBER,
			     cp_lookup_type fnd_lookup_values.lookup_type%TYPE,
			     cp_view_application_id fnd_lookup_values.view_application_id%TYPE,
			     cp_security_group_id fnd_lookup_values.security_group_id%TYPE) IS
      SELECT   NVL (lkup.meaning, per.person_title) ||
               DECODE (per.person_first_name, NULL, NULL, ' ' ||
                       per.person_first_name) ||
               DECODE (per.person_middle_name, NULL, NULL, ' ' ||
                       per.person_middle_name) ||
               DECODE (per.person_last_name, NULL, NULL, ' ' ||
                       per.person_last_name) ||
               DECODE (per.person_name_suffix, NULL, NULL, ' ' ||
                       per.person_name_suffix) person_name
      FROM     hz_parties per,
               fnd_lookup_values lkup
      WHERE    per.party_id = cp_person_id
      AND      per.person_pre_name_adjunct = lkup.lookup_code (+)
      AND      lkup.lookup_type (+) = cp_lookup_type
      AND      lkup.language(+) = USERENV('LANG')
      AND      lkup.view_application_id(+) = cp_view_application_id
      AND      lkup.security_group_id(+) = cp_security_group_id;

    --
    -- Cursor for selection of the person address for Correspondence from HZ_PARTIES.
    --
    CURSOR cur_person_address (
      cp_person_id                   IN NUMBER
    ) IS
      SELECT   addr.address1 ||
               DECODE (addr.address2, NULL, NULL, l_line_break || addr.address2) ||
               DECODE (addr.address3, NULL, NULL, l_line_break || addr.address3) ||
               DECODE (addr.address4, NULL, NULL, l_line_break || addr.address4) ||
               DECODE (addr.city,  NULL, NULL, l_line_break || addr.city) ||
               DECODE (addr.state, NULL, NULL, l_line_break || addr.state) ||
               DECODE (addr.postal_code, NULL, NULL, ' ' || addr.postal_code) ||
               DECODE (tr.territory_short_name, NULL, NULL, l_line_break ||
                       tr.territory_short_name) person_address
      FROM     hz_parties addr,
               fnd_territories_vl tr
      WHERE    addr.party_id = cp_person_id
      AND      addr.country = tr.territory_code(+);

    --
    -- Local Variables
    --
    l_name VARCHAR2(1000) ;
    l_address VARCHAR2(1500) ;

    --
    -- Local Record Variables
    --
    l_person_rec cur_person_name%ROWTYPE;
    l_person_address_rec cur_person_address%ROWTYPE;

  BEGIN
    l_name := NULL;
    l_address := NULL;
    -- Check if the required parameter values are passed as Null.  If any of these are null then return NULL value
    IF (p_person_id IS NULL) THEN
      RETURN NULL;
    END IF;

    OPEN cur_person_name (p_person_id,'CONTACT_TITLE',222,0);
    FETCH cur_person_name INTO l_person_rec;

    IF (cur_person_name%NOTFOUND) THEN
      CLOSE cur_person_name;
      RETURN NULL;
    ELSE
      CLOSE cur_person_name;
      -- Get the Name details for the person.
      l_name := l_person_rec.person_name;

      l_line_break := '<BR>';

      -- Get the Address details of the Student for Correspondence purposes.
      OPEN cur_person_address (p_person_id);
      FETCH cur_person_address INTO l_person_address_rec;

      IF (cur_person_address%NOTFOUND) THEN
        l_address := ' ';
      ELSE
        l_address := l_person_address_rec.person_address;
      END IF;
      CLOSE cur_person_address;

    END IF;

    -- Return the concatenated value of Name and Address.
    IF (p_case_type = 'UPPER') THEN
      RETURN UPPER (l_name || l_line_break || l_address);
    ELSIF (p_case_type = 'LOWER') THEN
      RETURN LOWER (l_name || l_line_break || l_address);
    ELSE
      RETURN INITCAP (l_name || l_line_break || l_address);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (cur_person_name%ISOPEN) THEN
        CLOSE cur_person_name;
      ELSIF (cur_person_address%ISOPEN) THEN
        CLOSE cur_person_address;
      END IF;

      RETURN NULL;

  END get_per_addr_for_corr;


  FUNCTION get_prg_appl_inst_dff_values (
    p_person_id IN NUMBER,
    p_admission_appl_number IN NUMBER,
    p_nominated_course_cd IN VARCHAR2,
    p_sequence_number IN NUMBER
  ) RETURN VARCHAR2 IS

    /*******************************************************************************
    Created by   : rbezawad
    Date created : 04-Feb-2002
    Purpose      : Function to get Application Instance Descriptive Flex-Field values.

    Known limitations/enhancements/remarks:

    Change History: (who, when, what: NO CREATION RECORDS HERE!)
    Who             When            What
    skpandey        12-JAN-2006     Bug#4937960
                                    Added application_id in query of cur_enabled_attributes cursor to optimize query
    *******************************************************************************/
    --
    -- Cursor to fetch the Columns and Prompts for the Columns which are
    --  registered for the Application Instance Descriptive Flex Field
    --
    CURSOR cur_enabled_attributes IS
      SELECT   usg.form_left_prompt form_left_prompt,
               usg.application_column_name application_column_name
      FROM     fnd_descr_flex_col_usage_vl usg
      WHERE    usg.descriptive_flexfield_name = 'IGS_AD_APPL_INST_FLEX'
      AND      usg.enabled_flag = 'Y'
      AND      usg.application_id = 8405;

    l_return_value VARCHAR2(6000);
    l_column_value igs_ad_ps_appl_inst_all.attribute1%TYPE;

  BEGIN

    -- Check if the required parameter values are passed as Null.  If any of these are null then return NULL value
    IF ( p_person_id IS NULL OR p_admission_appl_number IS NULL OR p_nominated_course_cd IS NULL OR p_sequence_number IS NULL ) THEN
      RETURN NULL;
    END IF;

    l_return_value := '';

    FOR rec_cur_enabled_attributes IN cur_enabled_attributes LOOP
      -- Get the registered flex filed Column values for the Admission Application Instance
      EXECUTE IMMEDIATE ' SELECT '|| rec_cur_enabled_attributes.application_column_name||
                        ' FROM   igs_ad_ps_appl_inst_all '||
                        ' WHERE  person_id = :1' ||
                        ' AND    admission_appl_number = :2'||
                        ' AND    nominated_course_cd = :3' ||
                        ' AND    sequence_number = :4'
      INTO l_column_value
      USING p_person_id, p_admission_appl_number, p_nominated_course_cd, p_sequence_number;

      IF l_column_value IS NOT NULL THEN
        -- Concatenate the Flex filed column values populated with the Prompts registered for that columns.
        l_return_value := l_return_value || rec_cur_enabled_attributes.form_left_prompt || ': ' || l_column_value || ' <BR> ';
      END IF;
    END LOOP;

    RETURN l_return_value;

  EXCEPTION
    WHEN OTHERS THEN
      IF (cur_enabled_attributes%ISOPEN) THEN
        CLOSE cur_enabled_attributes;
      END IF;

      RETURN NULL;

  END get_prg_appl_inst_dff_values;


  FUNCTION get_program_completion_dt (
    p_course_cd IN igs_ad_ps_appl_inst_aplinst_v.course_cd%TYPE,
    p_version_number IN igs_ad_ps_appl_inst_aplinst_v.crv_version_number%TYPE,
    p_acad_cal_type  IN igs_ad_ps_appl_inst_aplinst_v.acad_cal_type%TYPE,
    p_adm_cal_type   IN igs_ad_ps_appl_inst_aplinst_v.adm_cal_type%TYPE,
    p_adm_ci_sequence_number IN igs_ad_ps_appl_inst_aplinst_v.adm_ci_sequence_number%TYPE,
    p_attendance_type IN igs_ad_ps_appl_inst_aplinst_v.attendance_type%TYPE,
    p_attendance_mode IN igs_ad_ps_appl_inst_aplinst_v.attendance_mode%TYPE,
    p_location_cd IN igs_ad_ps_appl_inst_aplinst_v.location_cd%TYPE
  ) RETURN DATE IS

    /*******************************************************************************
    Created by   : rbezawad
    Date created : 04-Feb-2002
    Purpose      : Function to get Expected Program Completion Date.

    Known limitations/enhancements/remarks:

    Change History: (who, when, what: NO CREATION RECORDS HERE!)
    Who             When            What
    knag            29-OCT-2002     For bug 2647482 Added parameters
                                    p_attendance_type and p_location_cd
    *******************************************************************************/

    l_expected_completion_yr   igs_ad_ps_appl_inst.expected_completion_yr%TYPE;
    l_expected_completion_perd igs_ad_ps_appl_inst.expected_completion_perd%TYPE;
    l_completion_dt DATE;
    l_course_start_dt DATE;
  BEGIN

    -- Check if the required parameter values are passed as Null.  If any of these are null then return NULL value
    IF ( p_course_cd IS NULL OR p_version_number IS NULL OR p_adm_cal_type IS NULL OR  p_adm_ci_sequence_number IS NULL) THEN
      RETURN NULL;
    END IF;

    --Calculating the Program Version Start Date.
    l_course_start_dt := igs_ad_gen_005.admp_get_crv_strt_dt ( p_adm_cal_type => p_adm_cal_type,
                                                               p_adm_ci_sequence_number => p_adm_ci_sequence_number);

    --Calculating the Projected Program Version Completion Date.
    igs_ad_gen_004.admp_get_crv_comp_dt (p_course_cd                 => p_course_cd ,
                                         p_crv_version_number        => p_version_number,
                                         p_cal_type                  => p_acad_cal_type ,
                                         p_attendance_type           => p_attendance_type,
                                         p_start_dt                  => l_course_start_dt,
                                         p_expected_completion_yr    => l_expected_completion_yr,
                                         p_expected_completion_perd  => l_expected_completion_perd,
                                         p_completion_dt             => l_completion_dt,
                                         p_attendance_mode           => p_attendance_mode,
                                         p_location_cd               => p_location_cd);

    RETURN l_completion_dt;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

  END get_program_completion_dt;


  FUNCTION get_residency_dff_values (
    p_resident_details_id IN NUMBER
  ) RETURN VARCHAR2 IS

    /*******************************************************************************
    Created by   : rbezawad
    Date created : 04-Feb-2002
    Purpose      : Function to get the Residency Descriptive Flex-Field values.

    Known limitations/enhancements/remarks:

    Change History: (who, when, what: NO CREATION RECORDS HERE!)
    Who             When            What

    *******************************************************************************/
    --
    -- Cursor to fetch the Columns and Prompts for the Columns which are
    --  registered for the Residency Details Descriptive Flex Field
    --
    CURSOR cur_enabled_attributes IS
      SELECT usg.form_left_prompt form_left_prompt,
             usg.application_column_name application_column_name
      FROM   fnd_descr_flex_col_usage_vl usg
      WHERE  usg.descriptive_flexfield_name = 'IGS_PE_PERS_RESIDENCY_FLEX'
      AND    usg.enabled_flag = 'Y'
      AND    usg.application_id = 8405;

    l_return_value VARCHAR2(6000);
    l_column_value igs_pe_res_dtls_all.attribute1%TYPE;

  BEGIN

    -- Check if the required parameter values are passed as Null.  If any of these are null then return NULL value
    IF ( p_resident_details_id IS NULL) THEN
      RETURN NULL;
    END IF;

    l_return_value := '';

    FOR rec_cur_enabled_attributes IN cur_enabled_attributes LOOP
      -- Get the registered flex filed Column values for the Resident Details
      EXECUTE IMMEDIATE ' SELECT   ' || rec_cur_enabled_attributes.application_column_name ||
                        ' FROM     igs_pe_res_dtls_all '||
                        ' WHERE    resident_details_id = :1'
      INTO l_column_value
      USING p_resident_details_id;

      IF l_column_value IS NOT NULL THEN
        -- Concatenate the Flex filed column values populated with the Prompts registered for that columns.
        l_return_value := l_return_value || rec_cur_enabled_attributes.form_left_prompt || ': ' || l_column_value || ' <BR> ';
      END IF;
    END LOOP;

    RETURN l_return_value;

  EXCEPTION
    WHEN OTHERS THEN
      IF (cur_enabled_attributes%ISOPEN) THEN
        CLOSE cur_enabled_attributes;
      END IF;

      RETURN NULL;

  END get_residency_dff_values;


  FUNCTION get_student_citizenship_status(
    p_person_id IN NUMBER
  ) RETURN  VARCHAR2 IS

    /*******************************************************************************
    Created by   : rbezawad
    Date created : 04-Feb-2002
    Purpose      : Function to get the Student Citizenship Status.

    Known limitations/enhancements/remarks:

    Change History: (who, when, what: NO CREATION RECORDS HERE!)
    Who             When            What

    *******************************************************************************/
    --
    --Cursor to get the Student Citizenship Status.
    --
    CURSOR cur_citizenship IS
      SELECT peit.pei_information1 restatus_code, pecc.meaning restatus_desc
      FROM   igs_pe_eit peit,
             igs_lookups_view pecc
      WHERE  peit.pei_information1 = pecc.lookup_code
      AND    peit.person_id = p_person_id
      AND    peit.start_date <= SYSDATE
      AND    NVL(peit.end_date,SYSDATE) >= SYSDATE
      AND    pecc.lookup_type='PE_CITI_STATUS'
      AND    ENABLED_FLAG = 'Y';

    l_restatus_code igs_pe_eit.pei_information1%TYPE;
    l_restatus_desc igs_lookups_view.meaning%TYPE;

  BEGIN

    -- Check if the required parameter values are passed as Null.  If any of these are null then return NULL value
    IF (p_person_id IS NULL) THEN
      RETURN NULL;
    END IF;

    --Get the Student Citizenship Status and return the status description.
    OPEN cur_citizenship;
    FETCH cur_citizenship INTO l_restatus_code, l_restatus_desc;

    IF cur_citizenship%FOUND THEN
      CLOSE cur_citizenship;
      RETURN l_restatus_desc;
    END IF;

    CLOSE cur_citizenship;
    RETURN NULL;

  EXCEPTION
    WHEN OTHERS THEN
      IF (cur_citizenship%ISOPEN) THEN
        CLOSE cur_citizenship;
      END IF;

      RETURN NULL;

  END get_student_citizenship_status;

END igs_co_gen_003;

/
