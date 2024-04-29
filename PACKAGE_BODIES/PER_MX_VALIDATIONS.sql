--------------------------------------------------------
--  DDL for Package Body PER_MX_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MX_VALIDATIONS" AS
/* $Header: permxval.pkb 120.2.12000000.4 2007/09/13 05:58:55 srikared noship $ */

--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_RFC                                           --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate RFC ID                        --
-- Parameters     :                                                     --
--             IN : p_rfc_id            VARCHAR2                        --
--                  p_person_id         NUMBER                          --
--                  p_business_group_id NUMBER                          --
--            OUT : p_warning           VARCHAR2                        --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE check_RFC( p_rfc_id            IN VARCHAR2,
                     p_person_id         IN NUMBER,
                     p_business_group_id IN NUMBER,
                     p_warning           OUT NOCOPY VARCHAR2,
                     p_valid_rfc         OUT NOCOPY VARCHAR2) AS

  l_valid            VARCHAR2(30);
  l_status           VARCHAR2(1);
  l_warning          VARCHAR2(1);
  l_chk_unique       BOOLEAN;
BEGIN
--

   -- Initialization of variables.
   --
   p_valid_rfc  := p_rfc_id;
   l_chk_unique := TRUE;
   l_valid      := p_rfc_id;
   l_warning    := 'N';

   IF fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <>'NONE' THEN

           IF p_rfc_id IS NOT NULL THEN

                -- Call the core package to perform the format check on the RFC ID
                -- Added format mask (Bug 3566864)
                -- Last character to allow alpha-numerics (Bug 4033022)
                --
                l_valid := hr_ni_chk_pkg.chk_nat_id_format( p_rfc_id, 'AAAA-DDDDDD-XXX');

                IF l_valid = '0' THEN

               	        IF fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <>'WARN' THEN
                    	        hr_utility.set_message(800,'HR_MX_INVALID_RFC');
                            	hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'ERROR'));
                                hr_utility.raise_error;
                        --        p_warning := l_warning;
               	        ELSE
                                hr_utility.set_message(800,'HR_MX_INVALID_RFC');
                                hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'WARN'));
                                l_warning := 'Y';

                        END IF;

                        p_warning := l_warning;

                        -- Uniqueness need not be verified, since the RFC ID is invalid
                        --
                        l_chk_unique := FALSE;
                END IF;

        END IF;

   END IF;

   IF (l_chk_unique and p_rfc_id IS NOT NULL) THEN

        -- Check for uniqueness of RFC ID
        --
        BEGIN
       	        SELECT 'Y'
                INTO   l_status
                FROM   sys.dual
                WHERE  exists(SELECT /*+index(pp)*/'1'
                              FROM   per_all_people_f pp
                              WHERE (p_person_id IS NULL
                                  OR  p_person_id <> pp.person_id)
                                AND  translate(l_valid, '1-', '1') = translate(pp.per_information2, '1-', '1')
                                AND  pp.business_group_id +0 = p_business_group_id);

                IF fnd_profile.value('PER_NI_UNIQUE_ERROR_WARNING') = 'ERROR' THEN
       	                hr_utility.set_message(800,'HR_MX_RFC_UNIQUE_ERROR');
                        hr_utility.set_message_token( 'ACTION', ' ');
                                 hr_utility.raise_error;
               	ELSE
       	                hr_utility.set_message(800,'HR_MX_RFC_UNIQUE_ERROR');
                        hr_utility.set_message_token( 'ACTION',  hr_general.decode_lookup('MX_ACTION_TOKEN', 'WARN'));
                        l_warning := 'Y';
               	END IF;
       	        p_warning := l_warning;

       	EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    p_valid_rfc := l_valid;
        END;

   END IF;

   EXCEPTION
          WHEN VALUE_ERROR THEN
               hr_utility.set_message(800,'HR_MX_INVALID_RFC');
               hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'ERROR'));
               hr_utility.raise_error;
--
END check_RFC;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_SS                                            --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate Social Security ID            --
-- Parameters     :                                                     --
--             IN : p_ss_id             VARCHAR2                        --
--                  p_person_id         NUMBER                          --
--                  p_business_group_id NUMBER                          --
--            OUT : p_warning           VARCHAR2                        --
--                  p_valid_ss          VARCHAR2                        --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE check_SS( p_ss_id             IN VARCHAR2,
                    p_person_id         IN NUMBER,
                    p_business_group_id IN NUMBER,
                    p_warning           OUT NOCOPY VARCHAR2,
                    p_valid_ss          OUT NOCOPY VARCHAR2) AS

  l_valid            VARCHAR2(30);
  l_status           VARCHAR2(1);
  l_warning          VARCHAR2(1);
  l_chk_unique       BOOLEAN;

BEGIN

   -- Initialization of variables.
   --
   p_valid_ss   := p_ss_id;
   l_chk_unique := TRUE;
   l_valid      := p_ss_id;
   l_warning    := 'N';


   IF fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'NONE' THEN

           IF p_ss_id IS NOT NULL THEN

                -- Call the core package to perform the format check on the SS ID
                --
                l_valid := hr_ni_chk_pkg.chk_nat_id_format( p_ss_id, 'DD-DD-DD-DDDD-D');

                IF l_valid = '0' THEN

               	        IF fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'WARN' THEN
                    	        hr_utility.set_message(800,'HR_MX_INVALID_SS');
                    	        hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'ERROR'));
                                hr_utility.raise_error;
               	        ELSE
                    	        hr_utility.set_message(800,'HR_MX_INVALID_SS');
                    	        hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'WARN'));
		                l_warning := 'Y';

               	        END IF;

                        -- Uniqueness need not be verified, since the SS ID is invalid
                        --
                        p_warning := l_warning;
                        l_chk_unique := FALSE;

                END IF;

        END IF;

   END IF;

   IF (l_chk_unique and p_ss_id IS NOT NULL) THEN

        -- Check for uniqueness of SS ID. The format characters
        -- will be removed before comparison.
        --
        BEGIN
       	        SELECT 'Y'
                 INTO   l_status
       	              FROM   sys.dual
           	WHERE  exists(SELECT /*+INDEX(pp)*/'1'
                              FROM   per_all_people_f pp
                      	      WHERE (p_person_id IS NULL
                               	 OR  p_person_id <> pp.person_id)
                                AND  translate(l_valid, '1-', '1') = translate(pp.per_information3, '1-', '1')
                                AND  pp.business_group_id +0 = p_business_group_id);

                IF fnd_profile.value('PER_NI_UNIQUE_ERROR_WARNING') = 'ERROR' THEN
       	                hr_utility.set_message(800,'HR_MX_SS_UNIQUE_ERROR');
                        hr_utility.set_message_token( 'ACTION', ' ');
          	       	hr_utility.raise_error;
               	ELSE
      	                hr_utility.set_message(800,'HR_MX_SS_UNIQUE_ERROR');
                        hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'WARN'));
                        l_warning := 'Y';
               	END IF;
       	        p_warning := l_warning;

       	EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    p_valid_ss := l_valid;

        END;

   END IF;

   EXCEPTION
          WHEN VALUE_ERROR THEN
               hr_utility.set_message(800,'HR_MX_INVALID_SS');
               hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'ERROR'));
               hr_utility.raise_error;

--
END check_SS;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_MS                                            --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate Military Service ID           --
-- Parameters     :                                                     --
--             IN : p_ms_id             VARCHAR2                        --
--                  p_person_id         NUMBER                          --
--                  p_business_group_id NUMBER                          --
--            OUT : p_warning           VARCHAR2                        --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE check_MS( p_ms_id             IN VARCHAR2,
                    p_person_id         IN NUMBER,
                    p_business_group_id IN NUMBER,
                    p_warning           OUT NOCOPY VARCHAR2) AS

  l_valid            VARCHAR2(11);
  l_status           VARCHAR2(1);
  l_warning          VARCHAR2(1);

BEGIN

   -- Initialization of variables.
   --
   l_valid      := '1';
   l_warning    := 'N';

   IF fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <>'NONE' THEN

   	IF p_ms_id IS NOT NULL THEN

        --
        -- Check if Military Service ID is 13 characters long
        --
                IF length(p_ms_id) <> 13 THEN

               	        IF fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'WARN' THEN
                    	        hr_utility.set_message(800,'HR_MX_INVALID_MS');
                    	        hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'ERROR'));
                                hr_utility.raise_error;
               	        ELSE
                    	        hr_utility.set_message(800,'HR_MX_INVALID_MS');
                    	        hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'WARN'));

                                l_warning := 'Y';

               	        END IF;

                        p_warning := l_warning;
                        l_valid := '0';
                END IF;

        END IF;

   END IF;

   IF l_valid = '1' THEN

     	-- Check for uniqueness of Military Service ID
        --
                BEGIN
       	                SELECT 'Y'
                        INTO   l_status
                       	FROM   sys.dual
                        WHERE  exists(SELECT '1'
                                      FROM   per_all_people_f pp
                                      WHERE (p_person_id IS NULL
                                         OR  p_person_id <> pp.person_id)
                                        AND    p_ms_id = pp.per_information6
                                        AND    pp.business_group_id  = p_business_group_id);

                        IF fnd_profile.value('PER_NI_UNIQUE_ERROR_WARNING') = 'ERROR' THEN
                               hr_utility.set_message(800,'HR_MX_MS_UNIQUE_ERROR');
                               hr_utility.set_message_token( 'ACTION', ' ');
                               hr_utility.raise_error;
                       	ELSE
                                hr_utility.set_message(800,'HR_MX_MS_UNIQUE_ERROR');
                                hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'WARN'));
                                l_warning := 'Y';
               	        END IF;
                       	p_warning := l_warning;

                EXCEPTION
                      	WHEN NO_DATA_FOUND THEN null;
           	END;

   END IF;

--
END check_MS;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_FGA                                           --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate Federal Gov. Affiliation ID   --
-- Parameters     :                                                     --
--             IN : p_fga_id            VARCHAR2                        --
--                  p_person_id         NUMBER                          --
--                  p_business_group_id NUMBER                          --
--            OUT : p_warning           VARCHAR2                        --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE check_FGA( p_fga_id            IN VARCHAR2,
                     p_person_id         IN NUMBER,
                     p_business_group_id IN NUMBER,
                     p_warning           OUT NOCOPY VARCHAR2) AS

  l_valid            VARCHAR2(11);
  l_status           VARCHAR2(1);
  l_warning          VARCHAR2(1);

BEGIN

   -- Initialization of variables.
   --
   l_valid      := '1';
   l_warning    := 'N';

   IF fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <>'NONE' THEN

           IF p_fga_id IS NOT NULL THEN

        --
        -- Check if Federal Government Affiliation ID is 13 characters long
        --
                IF length(p_fga_id) <> 13 THEN

                       	IF fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'WARN' THEN
                            	hr_utility.set_message(800,'HR_MX_INVALID_FGA');
                            	hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'ERROR'));
                            	hr_utility.raise_error;
                       	ELSE
                            	hr_utility.set_message(800,'HR_MX_INVALID_FGA');
                            	hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'WARN'));
                                l_warning := 'Y';

                       	END IF;

                        p_warning := l_warning;
                        l_valid   := '0';
                END IF;

        END IF;

   END IF;

   IF l_valid = '1' THEN

     	-- Check for uniqueness of Federal Government Affiliation ID
        --
                BEGIN
                       	SELECT 'Y'
                        INTO   l_status
                       	FROM   sys.dual
                        WHERE  exists(SELECT '1'
                                      FROM   per_all_people_f pp
                                      WHERE (p_person_id IS NULL
                                         OR  p_person_id <> pp.person_id)
                                      AND    p_fga_id = pp.per_information5
                                      AND    pp.business_group_id  = p_business_group_id);

                        IF fnd_profile.value('PER_NI_UNIQUE_ERROR_WARNING') = 'ERROR' THEN
                              hr_utility.set_message(800,'HR_MX_FGA_UNIQUE_ERROR');
                              hr_utility.set_message_token( 'ACTION', ' ');
                              hr_utility.raise_error;
                        ELSE
                              hr_utility.set_message(800,'HR_MX_FGA_UNIQUE_ERROR');
                              hr_utility.set_message_token( 'ACTION', hr_general.decode_lookup('MX_ACTION_TOKEN', 'WARN'));
                              l_warning := 'Y';
                        END IF;
                       	p_warning := l_warning;

                EXCEPTION
              	        WHEN NO_DATA_FOUND THEN null;
           	END;

   END IF;

--
END check_FGA;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_IMC                                           --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the IMSS Medical Center       --
-- Parameters     :                                                     --
--             IN : p_imc_id            VARCHAR2                        --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE check_IMC( p_imc_id     IN VARCHAR2) AS

BEGIN
--
    BEGIN
    --
        IF p_imc_id IS NOT NULL THEN
        --
        -- Check if IMSS Medical Center is upto 3 digits long
        --
                IF to_number(p_imc_id) > 999 OR to_number(p_imc_id) < 0 THEN

                       	hr_utility.set_message(800,'HR_MX_INVALID_IMC');
                        hr_utility.raise_error;

                END IF;
        END IF;

    EXCEPTION

       WHEN VALUE_ERROR THEN
       --
       -- Raise error when non-numeric characters are present in the IMSS Medical Center
       --
            hr_utility.set_message(800,'HR_MX_INVALID_IMC');
       	    hr_utility.raise_error;

    END;

--
END check_IMC;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_regstrn_ID                                    --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the Disability (Registration) --
--                  ID.                                                 --
-- Parameters     :                                                     --
--             IN : p_disab_id            VARCHAR2                      --
--                  p_regstrn_id          VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE check_regstrn_id( p_regstrn_id        IN VARCHAR2,
                            p_disab_id          IN NUMBER) AS

  l_valid            VARCHAR2(30);
  l_status           VARCHAR2(1);

BEGIN

   IF p_regstrn_id IS NOT NULL THEN

       	-- Call the core package to perform the format check on the Registration ID
        --
       	l_valid := hr_ni_chk_pkg.chk_nat_id_format( p_regstrn_id, 'AADDDDDD');

       	IF l_valid = '0' THEN

               	hr_utility.set_message(800,'HR_MX_INVALID_DISAB_ID');
                hr_utility.raise_error;

        END IF;

        -- Check for uniqueness of Registration ID.
        --
        BEGIN
       	        SELECT 'Y'
               	INTO   l_status
       	      	FROM   sys.dual
                WHERE  exists(SELECT /*+index(pdf per_disabilities_f_pk)*/'1'
                       	      FROM   per_disabilities_f pdf
                      	      WHERE (p_disab_id IS NULL
                               	 OR  p_disab_id <> pdf.disability_id)
                                AND  l_valid = pdf.registration_id
                             );

                hr_utility.set_message(800,'HR_MX_DISAB_ID_UNIQUE_ERROR');
               	hr_utility.raise_error;

       	EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    null;

        END;

   END IF;

--
END check_regstrn_id;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_SS_Leaving_Reason                             --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the SS Leaving Reason lookup  --
--                  code.                                               --
-- Parameters     :                                                     --
--             IN : p_ss_leaving_reason     VARCHAR2                    --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE check_SS_Leaving_Reason( p_ss_leaving_reason  IN VARCHAR2) AS

BEGIN
--
        IF p_ss_leaving_reason IS NOT NULL THEN
        --
        -- Check if the lookup_code for leaving reason exists in the lookup
        --
                IF hr_general.decode_lookup('MX_STAT_IMSS_LEAVING_REASON', p_ss_leaving_reason) IS NULL THEN

                       	hr_utility.set_message(800,'HR_MX_INVALID_LOOKUP_CODE');
                        hr_utility.set_message_token( 'LOOKUP_TYPE', 'MX_STAT_IMSS_LEAVING_REASON');
                        hr_utility.set_message_token( 'LOOKUP_CODE', p_ss_leaving_reason);
                        hr_utility.raise_error;

                END IF;
        END IF;
--
END check_SS_Leaving_Reason;

--
END per_mx_validations;

/
