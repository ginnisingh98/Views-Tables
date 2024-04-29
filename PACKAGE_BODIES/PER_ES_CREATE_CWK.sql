--------------------------------------------------------
--  DDL for Package Body PER_ES_CREATE_CWK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ES_CREATE_CWK" as
/* $Header: peescwkp.pkb 120.3 2006/09/14 13:24:43 mgettins noship $ */
g_package   VARCHAR2(30) := 'PER_ES_CREATE_CWK.';

--         p_first_last_name           p_last_name
--         p_identifier_type           p_per_information2
--         p_identifier_value          p_per_information3

PROCEDURE create_es_cwk (p_last_name           VARCHAR2
                        ,p_first_name          VARCHAR2
                        ,p_national_identifier VARCHAR2
                        ,p_per_information1    VARCHAR2
                        ,p_per_information2    VARCHAR2
                        ,p_per_information3    VARCHAR2
                        ) is

Cursor get_lookup_type(p_per_information2 varchar2) is
       select lookup_code from hr_lookups where
       lookup_type='ES_IDENTIFIER_TYPE'
       and  lookup_code=p_per_information2;

l_identifier_type   hr_lookups.lookup_code%TYPE;
l_identifier_value  VARCHAR2(10);
l_proc              VARCHAR2(72) := g_package||'CREATE_ES_CWK';
l_national_identifier per_all_people_f.national_identifier%TYPE;
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
        hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => hr_general.decode_lookup('ES_FORM_LABELS','LAST_NAME_1'),
            p_argument_value   => p_last_name
           );

	IF  p_per_information3 IS NOT NULL AND
            p_per_information2 IS NULL THEN
                hr_utility.set_message(800,'HR_ES_INVALID_VALUE');
                hr_utility.set_message_token(800,'FIELD',hr_general.decode_lookup('ES_FORM_LABELS','IDENTIFIER_TYPE'));
                hr_utility.raise_error;
	ELSIF  p_per_information2 IS NOT NULL AND
		p_per_information3 IS NULL THEN
                 OPEN get_lookup_type(p_per_information2);
                 FETCH get_lookup_type into l_identifier_type;
           	 IF  get_lookup_type%NOTFOUND THEN
            	    hr_utility.set_message(800,'HR_ES_INVALID_VALUE');
             	    hr_utility.set_message_token(800,'FIELD',hr_general.decode_lookup('ES_FORM_LABELS','IDENTIFIER_TYPE'));
              	    hr_utility.raise_error;
	         END IF;
 	        CLOSE get_lookup_type;
                hr_utility.set_message(800,'HR_ES_INVALID_VALUE');
                hr_utility.set_message_token(800,'FIELD',hr_general.decode_lookup('ES_IDENTIFIER_TYPE',p_per_information2));
                hr_utility.raise_error;
	END IF;
	--

    IF FND_PROFILE.VALUE('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'NONE' THEN --- Bug No 4718049
		IF  p_national_identifier IS NULL THEN
			IF  p_per_information3 IS NULL THEN
				hr_utility.set_message(800, 'HR_ES_REQ_NIF_IDT_MISSING');
				hr_utility.raise_error;
			END IF;
		ELSE
			l_national_identifier := hr_es_utility.check_NIF(p_national_identifier);
			IF l_national_identifier = 'N' THEN  ---- Bug No 4718049
			    hr_utility.set_message(800, 'HR_ES_INVALID_NIF');
			    hr_utility.raise_error;
			END IF;
		END IF;
	END IF;


        IF  p_per_information2 IS NOT NULL THEN
            OPEN get_lookup_type(p_per_information2);
            FETCH get_lookup_type into l_identifier_type;
            IF  get_lookup_type%NOTFOUND THEN
                hr_utility.set_message(800,'HR_ES_INVALID_VALUE');
                hr_utility.set_message_token(800,'FIELD',hr_general.decode_lookup('ES_FORM_LABELS','IDENTIFIER_TYPE'));
                hr_utility.raise_error;
            ELSIF FND_PROFILE.VALUE('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'NONE' THEN ---- Bug No 4718049
                l_identifier_value := hr_es_utility.validate_identifier(p_per_information2,p_per_information3);
            END IF;
            CLOSE get_lookup_type;
        END IF;

        IF  FND_PROFILE.VALUE('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'NONE' AND ---- Bug No 4718049
	    p_per_information2 IS NOT NULL and p_per_information3 IS NOT NULL and p_national_identifier is not null THEN

			OPEN get_lookup_type(p_per_information2);
            FETCH get_lookup_type into l_identifier_type;

            IF l_identifier_type='DNI' then
               If substr(p_national_identifier,1,8) <> p_per_information3 then
		   hr_utility.set_message(800,'HR_ES_INVALID_DNI_NIF');
		   hr_utility.raise_error;
	       end if;
            end if;

	    CLOSE get_lookup_type;
        end if;

       IF  length(p_last_name)>40 THEN
         hr_utility.set_message(800, 'HR_289712_UTF8_LENGTH_EXCEEDED');
         hr_utility.set_message_token('COLUMN_NAME',hr_general.decode_lookup('ES_FORM_LABELS','LAST_NAME_1'));
         hr_utility.set_message_token('COLUMN_VALUE',p_last_name);
         hr_utility.set_message_token('MAX_LENGTH','40');
         hr_utility.raise_error;
       END IF;

       IF  length(p_first_name)>40 THEN
         hr_utility.set_message(800, 'HR_289712_UTF8_LENGTH_EXCEEDED');
         hr_utility.set_message_token('COLUMN_NAME',hr_general.decode_lookup('ES_FORM_LABELS','NAME'));
         hr_utility.set_message_token('COLUMN_VALUE',p_first_name);
         hr_utility.set_message_token('MAX_LENGTH','40');
         hr_utility.raise_error;
       END IF;

       IF  length(p_per_information1)>40 THEN
         hr_utility.set_message(800, 'HR_289712_UTF8_LENGTH_EXCEEDED');
         hr_utility.set_message_token('COLUMN_NAME',hr_general.decode_lookup('ES_FORM_LABELS','LAST_NAME_2'));
         hr_utility.set_message_token('COLUMN_VALUE',p_per_information1);
         hr_utility.set_message_token('MAX_LENGTH','40');
         hr_utility.raise_error;
       END IF;
  END IF;
END create_es_cwk;

END PER_ES_CREATE_CWK;

/
