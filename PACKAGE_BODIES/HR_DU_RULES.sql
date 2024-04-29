--------------------------------------------------------
--  DDL for Package Body HR_DU_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DU_RULES" AS
/* $Header: perdurul.pkb 120.0 2005/05/31 17:22:43 appldev noship $ */


-- ------------------------- API_PRESENT_AND_CORRECT -----------------------
-- Description: Double checks that the API name exists in the
-- HR_DU_DESCRIPTORS table, and is matched to the api name in header sheet
--
--  Input Parameters
--
--	p_upload_header_id - Identifies the API's file for which the process
--			     order will be retrieved
--
-- -------------------------------------------------------------------------
PROCEDURE API_PRESENT_AND_CORRECT(p_upload_header_id IN NUMBER,
				p_upload_id IN NUMBER) IS

--This cursor extracts the api name from the descriptors
  CURSOR csr_api_name IS
  SELECT upper(VALUE)
    FROM hr_du_descriptors
    WHERE upper(DESCRIPTOR) = 'API'
    AND UPLOAD_HEADER_ID = p_upload_header_id;

--checks the header descriptors to check that the API name matches
  CURSOR csr_api_header IS
  SELECT upper(DESCRIPTOR)
    FROM hr_du_descriptors
    WHERE DESCRIPTOR_TYPE = 'F'
    AND UPLOAD_ID = p_upload_id
    AND upload_header_id IS NULL;


  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_api_name		VARCHAR2(2000);
  l_file_name		VARCHAR2(2000);
  l_api_header		VARCHAR2(2000);


BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_rules.api_present_and_correct', 5);
  hr_du_utility.message('PARA', '(p_upload_header_id - ' || p_upload_header_id || ')' , 10);
--

  OPEN csr_api_name;
    FETCH csr_api_name INTO l_api_name;
    IF csr_api_name%NOTFOUND THEN
    --
      l_file_name := RETURN_UPLOAD_HEADER_FILE(p_upload_header_id);
      l_fatal_error_message := 'Unable to retieve the API name from the ' ||
                               'file ' || l_file_name;
      RAISE e_fatal_error;
    --
    ELSE
      OPEN csr_api_header;
      LOOP
        FETCH csr_api_header INTO l_api_header;
        IF csr_api_header%NOTFOUND THEN
        --
          l_file_name := RETURN_UPLOAD_HEADER_FILE(p_upload_header_id);
          l_fatal_error_message := 'Unable to match api name ' || l_api_name ||
                                   ' in the file ' || l_file_name || ' to an' ||
                                   ' API name on the header sheet';
          RAISE e_fatal_error;
        --
        ELSIF l_api_header = l_api_name THEN
          EXIT;
        END IF;
      END LOOP;
      CLOSE csr_api_header;
    END IF;
  CLOSE csr_api_name;

--
  hr_du_utility.message('ROUT','exit:hr_du_rules.api_present_and_correct', 15);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.api_present_and_correct',
    l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.api_present_and_correct',
                       '(none)', 'R');
    RAISE;
--
END API_PRESENT_AND_CORRECT;


-- ------------------------- PROCESS_ORDER_PRESENT ------------------------
-- Description: Double checks that the process order exists in the
-- HR_DU_DESCRIPTORS table.
--
--  Input Parameters
--
--	p_upload_header_id - Identifies the API's file for which the process
--			     order will be retrieved
--
-- ------------------------------------------------------------------------
PROCEDURE PROCESS_ORDER_PRESENT(p_upload_header_id IN NUMBER) IS

--This cursor extracts the Process Order from the descriptors
  CURSOR csr_process_order IS
  SELECT VALUE
    FROM hr_du_descriptors
    WHERE upper(DESCRIPTOR) = 'PROCESS ORDER'
    AND UPLOAD_HEADER_ID = p_upload_header_id;

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_process_order	VARCHAR2(2000);
  l_file_name		VARCHAR2(2000);


BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_rules.PROCESS_ORDER_PRESENT', 5);
  hr_du_utility.message('PARA', '(p_upload_header_id - ' || p_upload_header_id || ')' , 10);
--

  OPEN csr_process_order;
    FETCH csr_process_order INTO l_process_order;
    IF csr_process_order%NOTFOUND THEN
    --
      l_file_name := RETURN_UPLOAD_HEADER_FILE(p_upload_header_id);
      l_fatal_error_message := 'Unable to retieve the Process Order from the ' ||
                               'file ' || l_file_name;
      RAISE e_fatal_error;
    --
    END IF;
  CLOSE csr_process_order;

--
  hr_du_utility.message('ROUT','exit:hr_du_rules.process_order_present', 15);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.process_order_present',
    l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.process_order_present',
                       '(none)', 'R');
    RAISE;
--
END PROCESS_ORDER_PRESENT;


-- ----------------------- RETURN_UPLOAD_HEADER_FILE -----------------------
-- Description: Simply takes an upload_header_id and figure out the file
-- name associated with the API file to infor the user.
--
--  Input Parameters
--
--	p_upload_header_id - Identifies the API's file for which the file
--			     name will be retrieved
--
-- ------------------------------------------------------------------------
FUNCTION RETURN_UPLOAD_HEADER_FILE(p_upload_header_id IN NUMBER)
				    RETURN VARCHAR2
IS

  CURSOR csr_api_file IS
  SELECT des2.value
  FROM   hr_du_descriptors     des1,
         hr_du_descriptors     des2,
         hr_du_upload_headers  head,
         hr_du_uploads	       uplo
  WHERE  head.upload_header_id = p_upload_header_id
  AND    head.upload_id = uplo.upload_id
  AND    head.upload_header_id = des1.upload_header_id
  AND    des1.descriptor = 'API'
  AND    uplo.upload_id = des2.upload_id
  AND    upper(des2.descriptor) = upper(des1.value);


  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_file_name	 	VARCHAR2(2000);


BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_rules.return_upload_header_file', 5);
  hr_du_utility.message('PARA', '(p_upload_header_id - ' || p_upload_header_id || ')' , 10);
--

  OPEN csr_api_file;
    FETCH csr_api_file INTO l_file_name;
    IF csr_api_file%NOTFOUND THEN
      l_fatal_error_message := 'Unable to retieve the file name for the ' ||
			       'UPLOAD HEADER ' || p_upload_header_id ||
			       ' Possible API name mismatch';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_api_file;

  RETURN l_file_name;

--
  hr_du_utility.message('ROUT','exit:hr_du_rules.return_upload_header_file', 15);
  hr_du_utility.message('PARA', '(l_file_name - ' || l_file_name || ')'
                        , 20);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.return_upload_header_file',
    l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.return_upload_header_file',
                       '(none)', 'R');
    RAISE;
--
END RETURN_UPLOAD_HEADER_FILE;



-- ------------------------ VALIDATE_USER_KEY_SETUP -----------------------
-- Description: This function validates the user key supplied with each
-- API file, the user key has set properties which must all be checked here.
--
--  Input Parameters
--
--	p_upload_header_id - Identifies the API's file where the user key
--			     will be validated.
--
-- ------------------------------------------------------------------------
PROCEDURE VALIDATE_USER_KEY_SETUP(p_upload_header_id IN NUMBER, p_upload_id IN NUMBER)
IS


--This cursor extracts the user key from the upload table
  CURSOR csr_user_key IS
  SELECT VALUE
    FROM hr_du_descriptors
    WHERE upper(DESCRIPTOR) = 'USER KEY'
    AND UPLOAD_HEADER_ID = p_upload_header_id;

  e_fatal_error EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_user_key	 	VARCHAR2(2000);
  l_file_name		VARCHAR2(2000);


BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_rules.validate_user_key_setup', 5);
  hr_du_utility.message('PARA', '(p_upload_header_id - ' || p_upload_header_id || ')' , 10);
--

  OPEN csr_user_key;
    FETCH csr_user_key INTO l_user_key;
    IF csr_user_key%NOTFOUND THEN
    --
      INSERT INTO HR_DU_DESCRIPTORS(
           DESCRIPTOR_ID, UPLOAD_ID, UPLOAD_HEADER_ID,
  	   DESCRIPTOR, VALUE, DESCRIPTOR_TYPE, LAST_UPDATE_DATE,
	   LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY,
	   CREATION_DATE)
      VALUES(
          HR_DU_DESCRIPTORS_S.nextval,
          p_upload_id,
          p_upload_header_id,
          'USER KEY',
          '%NONE%',
          'D',
          sysdate,
          1,
          1,
          1,
          sysdate);
      COMMIT;
    --
    ELSE
      PERFORM_USER_KEY_CHECKS(l_user_key, p_upload_header_id);
    END IF;
  CLOSE csr_user_key;

--
  hr_du_utility.message('ROUT','exit:hr_du_rules.validate_user_key_setup', 15);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.validate_user_key_setup',
    l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.validate_user_key_setup',
                       '(none)', 'R');
    RAISE;
--
END VALIDATE_USER_KEY_SETUP;


-- ------------------------ PERFORM_USER_KEY_CHECKS -----------------------
-- Description: Holds all the checks that are run on the user key to make
-- sure its valid. The main points are no user keys, user keys pointing
-- to descriptors, and text and normal column headings
--
--  Input Parameters
--
--	p_user_key         - Actual string stored in the flat file
--
--	p_upload_header_id - Identifies the correct upload_header the
--                           user_key is associated with so that the
--			     appropriate area of the column_mappings
--			     is checked.
-- ------------------------------------------------------------------------
PROCEDURE PERFORM_USER_KEY_CHECKS(p_user_key IN VARCHAR2,
                                  p_upload_header_id IN NUMBER)
IS

 e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_number_keys 	NUMBER;
  l_pval_value		VARCHAR2(2000);
  l_position		NUMBER;
  l_temp		VARCHAR2(2000);

--Cursor compares the user key word to HR_DU_COLUMN_MAPPINGS
--in the main header for all API's
  CURSOR csr_dollar_key IS
  SELECT des.VALUE
  FROM 	 hr_du_descriptors     des,
         hr_du_upload_headers  head
  WHERE  head.upload_header_id = p_upload_header_id
    AND  head.upload_id = des.upload_id
    AND  des.upload_header_id IS NULL
    AND  upper(des.descriptor) = upper(l_pval_value);

--Cursor compares the user key word to HR_DU_COLUMN_MAPPINGS
--in the specific API header
  CURSOR csr_dollar_key_api IS
  SELECT VALUE
  FROM 	 hr_du_descriptors
  WHERE  upload_header_id = p_upload_header_id
    AND  upper(descriptor) = upper(l_pval_value);


--Cursor compares the user key word to HR_DU_COLUMN_MAPPINGS
  CURSOR csr_user_key IS
  SELECT column_name
  FROM hr_du_column_mappings  col,
       hr_du_upload_headers   head
  WHERE upper(col.column_name) = upper(l_pval_value)
    AND head.upload_header_id = p_upload_header_id
    AND head.api_module_id = col.api_module_id;

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_rules.perform_user_key_checks', 5);
  hr_du_utility.message('PARA', '(p_user_key  - ' || p_user_key ||
 		         ')(p_upload_header_id - ' || p_upload_header_id || ')'
                              , 10);

--
  IF upper(p_user_key) <> 'NONE' THEN
  --
    hr_du_di_insert.g_current_delimiter   := ':';
    hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(p_user_key);
    l_number_keys := hr_du_di_insert.WORDS_ON_LINE(p_user_key);

    FOR j IN 1..l_number_keys LOOP
    --
      hr_du_di_insert.g_current_delimiter   := ':';
      l_pval_value := hr_du_di_insert.Return_Word(p_user_key, j);

      l_position := INSTRB(l_pval_value, '%');

      IF l_position = 0 THEN
        --Not quoted string so it's will be treated as a column heading
        --checks this against the HR_DU_COLUMN_MAPPINGS
        OPEN csr_user_key;
          FETCH csr_user_key INTO l_temp;
          IF csr_user_key%NOTFOUND THEN
            l_fatal_error_message := 'Column on user key does not exist in '||
                                     'HR_DU_COLUMN_MAPPINGS';
            RAISE e_fatal_error;
          END IF;
        CLOSE csr_user_key;
      --
      ELSIF l_position > 1 THEN
        --Error the first quote should be at position one
        l_fatal_error_message := 'First Quote on the User Key is in the wrong position';
        RAISE e_fatal_error;
      ELSE
        --check is made to find the closing quote
        l_position := INSTRB(l_pval_value, '%', (l_position + 1));
        IF l_position = 0 THEN
          --Error the second quote should be present
          l_fatal_error_message := 'End Quote on the User Key is not present ';
          RAISE e_fatal_error;
        ELSE
          hr_du_di_insert.g_current_delimiter   := '%';
          hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(p_user_key);
          l_pval_value := hr_du_di_insert.Return_Word(l_pval_value, 2);

          --Checks begin to see if there are any pointers to DESCRIPTORS
          l_position := INSTRB(l_pval_value, '$');
          --
          IF l_position = 1 THEN
          --
            hr_du_di_insert.g_current_delimiter   := '$';
            hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(p_user_key);
            l_pval_value := hr_du_di_insert.Return_Word(l_pval_value, 2);
            OPEN csr_dollar_key;
              FETCH csr_dollar_key INTO l_temp;
              IF csr_dollar_key%NOTFOUND THEN
              --
                --this checks the specific headers for the API
                OPEN csr_dollar_key_api;
                  FETCH csr_dollar_key_api INTO l_temp;
                  IF csr_dollar_key_api%NOTFOUND THEN
                    l_fatal_error_message := 'User key $ is not a valid descriptor';
                    RAISE e_fatal_error;
                  END IF;
                CLOSE csr_dollar_key_api;
              END IF;
            --
            CLOSE csr_dollar_key;
          --
          END IF;
        END IF;
      END IF;
    --
    END LOOP;
  --
  END IF;

--
  hr_du_utility.message('ROUT','exit:hr_du_rules.perform_user_key_checks', 15);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.perform_user_key_checks',
    l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.perform_user_key_checks',
                       '(none)', 'R');
    RAISE;
--
END PERFORM_USER_KEY_CHECKS;
--


-- ------------------------ VALIDATE_STARTING_POINT ----------------------
-- Description: Holds all the checks that are run on the referencing type
-- to make ensure their validity.
--
--  Input Parameters
--	p_upload_header_id    -
--
--	p_upload_id    -
-- ------------------------------------------------------------------------
PROCEDURE VALIDATE_STARTING_POINT(p_upload_header_id IN NUMBER,
				  p_upload_id IN NUMBER)
IS

--This cursor extracts the starting point from the descriptors if its
--present
  CURSOR csr_starting_point IS
  SELECT VALUE
    FROM hr_du_descriptors
    WHERE upper(DESCRIPTOR) = 'STARTING POINT'
    AND UPLOAD_header_ID = p_upload_header_id;


--exception to raise
  e_fatal_error EXCEPTION;
--string to input the error message
  l_fatal_error_message		VARCHAR2(2000);
  l_starting_point		VARCHAR(2000);
  l_file_name			VARCHAR2(2000);

BEGIN
--
hr_du_utility.message('ROUT','entry:hr_du_rules.validate_starting_point', 5);
hr_du_utility.message('PARA', '(p_upload_header_id  - ' ||
                      p_upload_header_id || ')', 10);
--
  OPEN csr_starting_point;
  FETCH csr_starting_point INTO l_starting_point;
  IF csr_starting_point%NOTFOUND THEN
  --
    INSERT INTO HR_DU_DESCRIPTORS(
           DESCRIPTOR_ID, UPLOAD_ID, UPLOAD_HEADER_ID,
  	   DESCRIPTOR, VALUE, DESCRIPTOR_TYPE, LAST_UPDATE_DATE,
	   LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY,
	   CREATION_DATE)
        VALUES(
          HR_DU_DESCRIPTORS_S.nextval,
          p_upload_id,
          p_upload_header_id,
          'STARTING POINT',
          'NO',
          'D',
          sysdate,
          1,
          1,
          1,
          sysdate);
    COMMIT;
  --
  ELSIF (upper(l_starting_point) <> 'YES') AND (upper(l_starting_point) <> 'NO') THEN
    l_file_name := RETURN_UPLOAD_HEADER_FILE(p_upload_header_id);
    l_fatal_error_message := 'The Starting Point Value is not ' ||
			'YES or NO in the file ' || l_file_name;
    RAISE e_fatal_error;
  END IF;
  CLOSE csr_starting_point;

--
hr_du_utility.message('ROUT','exit:hr_du_rules.validate_starting_point', 15);
hr_du_utility.message('PARA','(none)', 30);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.validate_starting_point',
    l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.validate_starting_point',
                       '(none)', 'R');
    RAISE;
--
END VALIDATE_STARTING_POINT;
--




-- ------------------------ VALIDATE_REFERENCING -----------------------
-- Description: Holds all the checks that are run on the referencing type
-- to make ensure their validity.
--
--  Input Parameters
--	p_upload_header_id    -
-- ------------------------------------------------------------------------
FUNCTION VALIDATE_REFERENCING(p_upload_header_id IN NUMBER,
				  p_upload_id IN NUMBER)
				  RETURN VARCHAR2
IS

--This cursor extracts the Referencing value from the descriptors if its
--present
  CURSOR csr_referencing IS
  SELECT VALUE
    FROM hr_du_descriptors
    WHERE upper(DESCRIPTOR) = 'REFERENCING'
    AND UPLOAD_header_ID = p_upload_header_id;

--exception to raise
  e_fatal_error EXCEPTION;
--string to input the error message
  l_fatal_error_message		VARCHAR2(2000);
  l_referencing			VARCHAR(2000);
  l_file_name			VARCHAR2(2000);

BEGIN
--
hr_du_utility.message('ROUT','entry:hr_du_rules.validate_referencing', 5);
hr_du_utility.message('PARA', '(p_upload_header_id  - ' ||
                      p_upload_header_id || ')', 10);
--

  OPEN csr_referencing;
  FETCH csr_referencing INTO l_referencing;
  IF csr_referencing%NOTFOUND THEN
  --
    INSERT INTO HR_DU_DESCRIPTORS(
           DESCRIPTOR_ID, UPLOAD_ID, UPLOAD_HEADER_ID,
  	   DESCRIPTOR, VALUE, DESCRIPTOR_TYPE, LAST_UPDATE_DATE,
	   LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY,
	   CREATION_DATE)
        VALUES(
          HR_DU_DESCRIPTORS_S.nextval,
          p_upload_id,
          p_upload_header_id,
          'REFERENCING',
          'CP',
          'D',
          sysdate,
          1,
          1,
          1,
          sysdate);
    COMMIT;
    l_referencing := 'CP';
  --
  ELSIF (upper(l_referencing) <> 'PC') AND (upper(l_referencing) <> 'CP') THEN
    l_file_name := RETURN_UPLOAD_HEADER_FILE(p_upload_header_id);
    l_fatal_error_message := 'The Referencing Descriptor is not ' ||
			'PC or CP in the file ' || l_file_name;
    RAISE e_fatal_error;
  END IF;
  CLOSE csr_referencing;

--
hr_du_utility.message('ROUT','exit:hr_du_rules.validate_referencing', 15);
hr_du_utility.message('PARA','(none)', 30);
--

  RETURN l_referencing;

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.validate_referencing',
    l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.validate_referencing',
                       '(none)', 'R');
    RAISE;
--
END VALIDATE_REFERENCING;
--



-- ------------------------ VALIDATE_BUSINESS_GROUP -----------------------
-- Description: Holds all the checks that are run on the business group
-- names to make ensure their validity.
--
--  Input Parameters
--
--	p_business_group_profile - value read from profile
--
--	p_business_group_file    - value read from file
-- ------------------------------------------------------------------------
PROCEDURE VALIDATE_BUSINESS_GROUP(p_business_group_profile IN VARCHAR2,
                                  p_business_group_file IN VARCHAR2)
IS

--exception to raise
  e_fatal_error EXCEPTION;
--string to input the error message
  l_fatal_error_message		VARCHAR2(2000);

BEGIN
--
hr_du_utility.message('ROUT','entry:hr_du_rules.validate_business_group', 5);
hr_du_utility.message('PARA', '(p_business_group_profile  - ' ||
                      p_business_group_profile ||
 	              ')(p_business_group_file - ' || p_business_group_file
                      || ')', 10);
--

IF p_business_group_profile IS NULL THEN
  l_fatal_error_message := 'Error the HR:BUSINESS GROUP profile option ' ||
                           'has not been set';
  RAISE e_fatal_error;
END IF;

IF p_business_group_profile <>
                     NVL(p_business_group_file, 'HRDU null value')
  AND p_business_group_file is not null THEN
  l_fatal_error_message := 'Error the BUSINESS GROUP value supplied in ' ||
                           'the file does not match the value read from' ||
                           ' the HR:BUSINESS GROUP profile option.';
  RAISE e_fatal_error;
END IF;


--
hr_du_utility.message('INFO','Business group names validated', 15);
hr_du_utility.message('SUMM','Business group names validated', 20);
hr_du_utility.message('ROUT','exit:hr_du_rules.validate_business_group', 15);
hr_du_utility.message('PARA','(none)', 30);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.validate_business_group',
    l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_rules.validate_business_group',
                       '(none)', 'R');
    RAISE;
--
END VALIDATE_BUSINESS_GROUP;
--



END HR_DU_RULES;

/
