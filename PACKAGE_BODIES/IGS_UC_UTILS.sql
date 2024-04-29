--------------------------------------------------------
--  DDL for Package Body IGS_UC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_UTILS" AS
-- $Header: IGSUC26B.pls 120.0 2005/06/01 12:58:05 appldev noship $


  PROCEDURE format_app_no (p_app_no              IN     NUMBER,
                           p_check_digit         IN     NUMBER,
                           r_app_no_9            OUT NOCOPY    CHAR,
                           r_app_no_11           OUT NOCOPY    CHAR) IS

   BEGIN

     IF p_app_no IS NOT NULL AND
          LENGTH(TO_CHAR(p_app_no)) < 9 AND
          p_app_no >= 0 THEN

          --- Format App No (no check digit)

         r_app_no_9 := SUBSTR(LTRIM(TO_CHAR(p_app_no,'09999999')),1,2)
                       || '-' ||
                       SUBSTR(LTRIM(TO_CHAR(p_app_no,'09999999')),3,6);


        IF p_check_digit IS NOT NULL AND
           LENGTH(TO_CHAR(p_check_digit)) = 1 AND
           p_check_digit >= 0 THEN

        --- Format App No (with check digit)

        r_app_no_11 := SUBSTR(LTRIM(TO_CHAR(p_app_no,'09999999')),1,2)
                       || '-' ||
                       SUBSTR(LTRIM(TO_CHAR(p_app_no,'09999999')),3,6)
                       || '-' ||
                       TO_CHAR(p_check_digit);


        END IF; ---Check Digit Validation

     END IF; --- App No Validation

  END format_app_no;


  PROCEDURE generate_pers_no (r_person_number OUT NOCOPY CHAR)
  IS
  BEGIN
    r_person_number := NULL;
  END generate_pers_no;


  FUNCTION is_ucas_hesa_enabled RETURN BOOLEAN IS
  /******************************************************************
     Created By      : L SILVEIRA
     Date Created By : 14-JAN-2002
     Purpose         :
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     ayedubat  03-DEC-2002  Changed the cursor,c_country_code to remove the UPPER
                            Clause on the profile_option_name column for bug # 2577640
  ***************************************************************** */

  l_country_code      VARCHAR2(2) := '';
  l_user_id           NUMBER      := FND_GLOBAL.User_Id;
  l_responsibility_id NUMBER      := FND_GLOBAL.Resp_Id;
  l_application_id    NUMBER      := FND_GLOBAL.Resp_Appl_Id;
  l_site_id           NUMBER      := 0;

  CURSOR c_country_code(p_level_id    fnd_profile_option_values.level_id%TYPE
                       ,p_level_value fnd_profile_option_values.level_value%TYPE) IS
    SELECT profile_option_value
    FROM   fnd_profile_option_values fpov
          ,fnd_profile_options       fpo
    WHERE  fpo.profile_option_name = 'OSS_COUNTRY_CODE'
    AND    fpov.profile_option_id  = fpo.profile_option_id
    AND    fpov.level_id = p_level_id
    AND    fpov.level_value = p_level_value;

  BEGIN

    -- Fetch user level
    OPEN c_country_code(10004, l_user_id);
    FETCH c_country_code INTO l_country_code;
    CLOSE c_country_code;

    IF l_country_code IS NULL THEN
      -- Fetch responsibility level
      OPEN c_country_code(10003, l_responsibility_id);
      FETCH c_country_code INTO l_country_code;
      CLOSE c_country_code;

      IF l_country_code IS NULL THEN
        -- Fetch application level
        OPEN c_country_code(10002, l_application_id);
        FETCH c_country_code INTO l_country_code;
        CLOSE c_country_code;

        IF l_country_code IS NULL THEN
          -- Fetch site level
          OPEN c_country_code(10001, l_site_id);
          FETCH c_country_code INTO l_country_code;
          CLOSE c_country_code;
        END IF;
      END IF;
    END IF;

    IF l_country_code IS NULL THEN
      RETURN FALSE;
    ELSIF l_country_code = 'GB' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      IF c_country_code%ISOPEN THEN
        CLOSE c_country_code;
      END IF;
      RETURN FALSE;

  END is_ucas_hesa_enabled;

  PROCEDURE admission_residency_dtls (
     p_interface_res_id       IN  NUMBER
    ,p_residency_status_cd    IN  CHAR
    ,p_residency_class_cd     IN  CHAR
    ,p_start_dt               IN  DATE
    ,p_person_id              IN  NUMBER
    ,p_process_residency_status OUT NOCOPY CHAR ) IS
  /******************************************************************
   Created By      : Ayedubat
   Date Created By :
   Purpose         : User Hook calling from Person Residency Import Process to do the
                     extra validations for UCAS Applicants.
                     p_process_residency_status : Y means Continue the processing of interface record
                                                  N means Stop the processing of interface record
                                                  W means Raise the workflow event as the Residentcy
                                                    details are updated and stop further processing.
   Known limitations,enhancements,remarks:
   Change History
   Who       When          What
   smaddali  27-aug-03   Modified procedure for bug#3114604 , to consider other possibel cases for date overlapping
   pkpatel   9-Nov-2004  Bug 3993967 (Stubbed the procedure since Start/End date of Residency is no longer needed)
  ***************************************************************** */
  BEGIN
    NULL;
  END admission_residency_dtls ;

PROCEDURE cvname_references(p_type      IN VARCHAR2,
                            p_appno     IN NUMBER,
			    p_surname   IN VARCHAR2,
			    p_birthdate IN DATE,
			    l_result   OUT NOCOPY igs_uc_utils.cur_step_def) IS

  /******************************************************************
   Created By      : pmarada
   Date Created By :
   Purpose         : This procedure returns the cursor values to the IGSUC009 pld.

   Known limitations,enhancements,remarks:
   Change History
   Who       When          What
  pmarada    14-jul-2003   Removed the cvname_references procedure from
                                this pls.
  ***************************************************************** */

BEGIN
   NULL;
END cvname_references;


END igs_uc_utils;

/
