--------------------------------------------------------
--  DDL for Package Body PER_ES_UPDATE_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ES_UPDATE_PERSON" AS
/* $Header: peesperp.pkb 120.6 2006/09/14 16:35:03 mgettins noship $ */

PROCEDURE update_es_person (p_person_id           NUMBER
                           ,p_effective_date      DATE
                           ,p_last_name           VARCHAR2
                           ,p_first_name          VARCHAR2
                           ,p_national_identifier VARCHAR2
                           ,p_per_information1    VARCHAR2
                           ,p_per_information2    VARCHAR2
                           ,p_per_information3    VARCHAR2) IS

CURSOR get_lookup_type(p_per_information2 VARCHAR2) IS
    SELECT lookup_code
    FROM   hr_lookups
    WHERE  lookup_type='ES_IDENTIFIER_TYPE'
    AND    lookup_code=p_per_information2;

CURSOR csr_person_type IS
    SELECT  'Y' FROM DUAL
    WHERE   EXISTS(SELECT  ppt.system_person_type
                  FROM  per_person_types ppt
                       ,per_person_type_usages_f ptu
	               ,fnd_sessions ses
                  WHERE   ptu.person_id = p_person_id
                  AND     ppt.person_type_id = ptu.person_type_id
              	  AND     ses.session_id=userenv('sessionid')
                  AND     ses.effective_date BETWEEN ptu.effective_start_date AND ptu.effective_end_date
                  AND     ppt.system_person_type IN ('EMP','EX_EMP','CWK','EX_CWK'));
    --
    CURSOR get_identifier_type (p_person_id      VARCHAR2
                               ,p_effective_date DATE) IS
    SELECT per_information2
    FROM   per_all_people_f
    WHERE  person_id=p_person_id
    AND    p_effective_date BETWEEN effective_start_date
                            AND     effective_end_date;

    CURSOR get_identifier_value (p_person_id      VARCHAR2
                                ,p_effective_date DATE) IS
    SELECT p_per_information3
    FROM   per_all_people_f
    WHERE  person_id=p_person_id
    AND    p_effective_date BETWEEN effective_start_date
                            AND     effective_end_date;

    CURSOR get_national_ident (p_person_id      VARCHAR2
                               ,p_effective_date DATE) IS
    SELECT national_identifier
    FROM   per_all_people_f
    WHERE  person_id=p_person_id
    AND    p_effective_date BETWEEN effective_start_date
                            AND     effective_end_date;
    --

    l_person_type       per_person_types.system_person_type%TYPE;
    l_seed_person_type  per_person_types.seeded_person_type_key%TYPE;
    l_chk               VARCHAR2(1);
    l_chk_identifier    VARCHAR2(1);
--
    l_identifier_type   hr_lookups.lookup_code%TYPE;
    l_identifier_value  per_all_people_f.per_information3%TYPE;
    l_proc              VARCHAR2(72);
    l_national_identifier per_all_people_f.national_identifier%TYPE;
    l_check_val         VARCHAR2(1);
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
    --
    l_proc  := 'PER_ES_UPDATE_PERSON.UPDATE_ES_PERSON';
    OPEN csr_person_type;
    FETCH csr_person_type into l_chk;
    CLOSE csr_person_type;

    --
    --IF l_person_type <> 'OTHER' AND l_seed_person_type <> 'CONTACT' THEN
        -- Validate identifier Type
    l_identifier_type  := p_per_information2;
    l_identifier_value := p_per_information3;
    -- p_per_information2 and p_per_information3 will be passed as NULL wen called
    --from ppl mgt template and would be defaulted to g_varchar2 wen called from self service
    --the below condition handles both the scenarios
    IF p_per_information2 = hr_api.g_varchar2 AND p_per_information3 = hr_api.g_varchar2 THEN
        null;
    ELSE
        l_identifier_type  := p_per_information2;
        l_identifier_value := p_per_information3;
        --

        IF p_per_information2 = hr_api.g_varchar2 THEN
            OPEN get_identifier_type(p_person_id,p_effective_date);
            FETCH get_identifier_type INTO l_identifier_type;
            CLOSE get_identifier_type;
        ELSIF p_per_information3 = hr_api.g_varchar2 THEN
            OPEN get_identifier_value(p_person_id,p_effective_date);
            FETCH get_identifier_value INTO l_identifier_value;
            CLOSE get_identifier_value;
        END IF;
        --

        IF l_identifier_type IS NOT NULL AND
           l_identifier_value IS NULL THEN
                OPEN get_lookup_type(l_identifier_type);
                 FETCH get_lookup_type into l_identifier_type;
           	 IF  get_lookup_type%NOTFOUND THEN
            	    hr_utility.set_message(800,'HR_ES_INVALID_VALUE');
             	    hr_utility.set_message_token(800,'FIELD',hr_general.decode_lookup('ES_FORM_LABELS','IDENTIFIER_TYPE'));
              	    hr_utility.raise_error;
	         END IF;
 	        CLOSE get_lookup_type;

                hr_utility.set_message(800,'HR_ES_INVALID_VALUE');
                hr_utility.set_message_token(800,'FIELD',hr_general.decode_lookup('ES_IDENTIFIER_TYPE',l_identifier_type));
                hr_utility.raise_error;
        END IF;
        --
        IF  l_identifier_type IS NULL AND
            l_identifier_value IS NOT NULL THEN
                hr_utility.set_message(800,'HR_ES_INVALID_VALUE');
                hr_utility.set_message_token(800,'FIELD',hr_general.decode_lookup('ES_FORM_LABELS','IDENTIFIER_TYPE'));
                hr_utility.raise_error;
        END IF;
        --
        IF  FND_PROFILE.VALUE('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'NONE'  AND ---Bug No 4718049
	        l_identifier_type IS NOT NULL AND l_identifier_value IS NOT NULL THEN
	        l_chk_identifier := hr_es_utility.validate_identifier(l_identifier_type,l_identifier_value);
        END IF;
        --
    END IF;
    --
    IF p_national_identifier = hr_api.g_varchar2 AND l_identifier_value = hr_api.g_varchar2 THEN
        null;
    ELSE
        l_national_identifier := p_national_identifier;
        IF p_national_identifier = hr_api.g_varchar2 THEN
            OPEN get_national_ident(p_person_id,p_effective_date);
            FETCH get_national_ident INTO l_national_identifier;
            CLOSE get_national_ident;
        END IF;
        IF l_identifier_value = hr_api.g_varchar2 THEN
            OPEN get_identifier_value(p_person_id,p_effective_date);
            FETCH get_identifier_value INTO l_identifier_value;
            CLOSE get_identifier_value;
        END IF;
        IF l_chk = 'Y' THEN
            IF FND_PROFILE.VALUE('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'NONE'  AND --- Bug No 4718049
               l_national_identifier IS NULL AND l_identifier_value IS NULL THEN
			   hr_utility.set_message(800, 'HR_ES_REQ_NIF_IDT_MISSING');
			   hr_utility.raise_error;
            END IF;
        END IF;
        /*IF p_national_identifier is not null THEN
           l_national_identifier := hr_es_utility.check_NIF(p_national_identifier);
        END IF;*/
        IF  l_national_identifier IS NOT NULL AND l_identifier_value IS NOT NULL THEN
            IF  FND_PROFILE.VALUE('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'NONE'  AND --- Bug No 4718049
                substr(l_national_identifier,1,8) <> l_identifier_value AND
                l_identifier_type = 'DNI' THEN
                hr_utility.set_message(800,'HR_ES_INVALID_DNI_NIF');
                hr_utility.raise_error;
             END IF;
        END IF;
	END IF;
    --
    hr_api.mandatory_arg_error
               (p_api_name         => l_proc,
                p_argument         => hr_general.decode_lookup('ES_FORM_LABELS','LAST_NAME_1'),
                p_argument_value   => p_last_name
               );
    --
    IF  length(p_last_name)>40 THEN
        hr_utility.set_message(800, 'HR_289712_UTF8_LENGTH_EXCEEDED');
        hr_utility.set_message_token('COLUMN_NAME',hr_general.decode_lookup('ES_FORM_LABELS','LAST_NAME_1'));
        hr_utility.set_message_token('COLUMN_VALUE',p_last_name);
        hr_utility.set_message_token('MAX_LENGTH','40');
        hr_utility.raise_error;
    END IF;
    --
    --
    IF  p_per_information1 is not null THEN
        IF  length(p_per_information1)>40 THEN
            hr_utility.set_message(800, 'HR_289712_UTF8_LENGTH_EXCEEDED');
            hr_utility.set_message_token('COLUMN_NAME',hr_general.decode_lookup('ES_FORM_LABELS','LAST_NAME_2'));
            hr_utility.set_message_token('COLUMN_VALUE',p_per_information1);
            hr_utility.set_message_token('MAX_LENGTH','40');
            hr_utility.raise_error;
        END IF;
    END IF;
    --
    IF  p_first_name is not null THEN
        IF  length(p_first_name)>40 THEN
            hr_utility.set_message(800, 'HR_289712_UTF8_LENGTH_EXCEEDED');
            hr_utility.set_message_token('COLUMN_NAME',hr_general.decode_lookup('ES_FORM_LABELS','NAME'));
            hr_utility.set_message_token('COLUMN_VALUE',p_first_name);
            hr_utility.set_message_token('MAX_LENGTH','40');
            hr_utility.raise_error;
        END IF;
    END IF;
  END IF;
END update_es_person;
--
END PER_ES_UPDATE_PERSON;

/
