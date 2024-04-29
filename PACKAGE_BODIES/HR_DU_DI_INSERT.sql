--------------------------------------------------------
--  DDL for Package Body HR_DU_DI_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DU_DI_INSERT" AS
/* $Header: perduext.pkb 120.1 2005/06/27 02:51:04 mroberts noship $ */


-- --------------------- VALIDATE_SHEET_DESCRIPTORS -------------------------
-- Description: This procedure checks to make sure that there are no
-- two descriptors with the same name
--
--  Input Parameters
--       p_upload_id        : Identifies the upload
--
--	 p_upload_header_id : Identifies the individual header
-- -------------------------------------------------------------------------
PROCEDURE VALIDATE_SHEET_DESCRIPTORS (p_upload_id IN VARCHAR2,
                                p_upload_header_id IN NUMBER)
IS

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_counter_1		NUMBER;
  l_counter_2   	NUMBER;
  l_file_name		VARCHAR2(2000);

  CURSOR csr_unique_desc IS
  SELECT count (descriptor)
    FROM  hr_du_descriptors
    WHERE upload_id = p_upload_id
    AND   upload_header_id = p_upload_header_id;

  CURSOR csr_total_desc IS
  SELECT count(distinct descriptor)
    FROM  hr_du_descriptors
    WHERE upload_id = p_upload_id
    AND   upload_header_id = p_upload_header_id;

BEGIN
--
  hr_du_utility.message('ROUT',
        'entry:hr_du_di_insert.validate_sheet_descriptors', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id ||
	')(p_upload_header_id - ' || p_upload_header_id || ')' , 10);
--
  OPEN csr_total_desc;
    FETCH csr_total_desc INTO l_counter_1;
    IF csr_total_desc%NOTFOUND THEN
      l_file_name := hr_du_rules.RETURN_UPLOAD_HEADER_FILE(
                                                       p_upload_header_id);
      l_fatal_error_message := 'Error occured trying to count all of the '
                               || 'descriptors in the file ' || l_file_name;
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_total_desc;

  OPEN csr_unique_desc;
    FETCH csr_unique_desc INTO l_counter_2;
    IF csr_unique_desc%NOTFOUND THEN
      l_file_name := hr_du_rules.RETURN_UPLOAD_HEADER_FILE(
                                                       p_upload_header_id);
      l_fatal_error_message := 'Error occured trying to count all of the '
                     || 'distinct descriptors in the file ' || l_file_name;
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_unique_desc;

  IF l_counter_1 <> l_counter_2 THEN
    l_file_name := hr_du_rules.RETURN_UPLOAD_HEADER_FILE(p_upload_header_id);
    l_fatal_error_message := 'Two descriptors with the same name in ' ||
                             'the file ' || l_file_name;
    RAISE e_fatal_error;
  END IF;

--
  hr_du_utility.message('ROUT',
                     'exit:hr_du_di_insert.validate_sheet_descriptors', 15);
--
EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,
                     'hr_du_di_insert.validate_sheet_descriptors',
                     l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,'hr_du_di_insert.validate_sheet_descriptors'
                     ,'(none)', 'R');
    RAISE;
--
END VALIDATE_SHEET_DESCRIPTORS;


-- ----------------------VALIDATE_HEADER_DESCRIPTORS------------------------
-- Description: This procedure checks to make sure that there are no
-- two descriptors with the same name in the header section
--
--  Input Parameters
--       p_upload_id        : Identifies the upload to compare the headers
-- -------------------------------------------------------------------------
PROCEDURE VALIDATE_HEADER_DESCRIPTORS (p_upload_id IN VARCHAR2)
IS

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_counter_1		NUMBER;
  l_counter_2   	NUMBER;
  l_file_name		VARCHAR2(2000);

  --counts all headers
  CURSOR csr_unique_desc IS
  SELECT count (descriptor)
    FROM  hr_du_descriptors
    WHERE upload_id = p_upload_id
    AND   upload_header_id IS NULL;

  --counts all unique headers
  CURSOR csr_total_desc IS
  SELECT count(distinct descriptor)
    FROM  hr_du_descriptors
    WHERE upload_id = p_upload_id
    AND   upload_header_id IS NULL;

BEGIN
--
  hr_du_utility.message('ROUT',
                  'entry:hr_du_di_insert.validate_header_descriptors', 5);
  hr_du_utility.message('PARA',
                  '(p_upload_id - ' || p_upload_id || ')' , 10);

--
  OPEN csr_total_desc;
    FETCH csr_total_desc INTO l_counter_1;
    IF csr_total_desc%NOTFOUND THEN
      l_fatal_error_message := 'Error occured trying to count all of the '
                            || 'descriptors in the header file';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_total_desc;

  OPEN csr_unique_desc;
    FETCH csr_unique_desc INTO l_counter_2;
    IF csr_unique_desc%NOTFOUND THEN
      l_fatal_error_message := 'Error occured trying to count all of the '
                            || 'distinct descriptors in the header file';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_unique_desc;

  IF l_counter_1 <> l_counter_2 THEN
    l_fatal_error_message := 'There are descriptors with identical ' ||
                             'names on the header sheet';
    RAISE e_fatal_error;
  END IF;

--
  hr_du_utility.message('ROUT',
                    'exit:hr_du_di_insert.validate_header_descriptors', 15);
--
EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,
                        'hr_du_di_insert.validate_header_descriptors',
                        l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
                       'hr_du_di_insert.validate_header_descriptors',
                       '(none)', 'R');
    RAISE;
--
END VALIDATE_HEADER_DESCRIPTORS;

-- ------------------------- PARSE_LINE_TO_TABLE ---------------------------
-- Description: The procedure takes the data line then works through
-- stripping out the the data and placing it into the SQL array. When
-- all data has been removed the remainder of the array is filled with
-- nulls
--
--  Input Parameters
--       p_data_line  : The data line that's been read from the flat file
--
-- p_upload_header_id : Identifies the upload header so that the file name
--                      can be retrieved
--
--        p_line_type : Column or data line tag
-- -------------------------------------------------------------------------
PROCEDURE PARSE_LINE_TO_TABLE (p_data_line IN VARCHAR2,
                    p_upload_header_id IN NUMBER, p_line_type IN VARCHAR2)
IS

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_position		NUMBER;
  l_difference		NUMBER;
  l_next		NUMBER	:=1;
  l_section		VARCHAR2(2000);
  l_length		NUMBER;
  l_number_words	NUMBER;
  l_file_name		VARCHAR2(200);

BEGIN
--
  hr_du_utility.message('ROUT',
                        'entry:hr_du_di_insert.parse_line_to_table', 5);
  hr_du_utility.message('PARA', '(p_data_line - ' || p_data_line ||
		')(p_upload_header_id - ' || p_upload_header_id ||
		')(p_line_type - ' || p_line_type || ')' , 10);
--

  l_number_words := WORDS_ON_LINE(p_data_line);

  FOR i IN 1..l_number_words LOOP
  --
    l_position := INSTRB(p_data_line, g_current_delimiter, l_next, 1);
    IF l_position = 0 THEN
      l_length := LENGTHB(p_data_line);
      l_section := SUBSTRB(p_data_line, l_next, l_length);
      l_length := LENGTHB(l_section);
      IF l_length > 0 THEN
      --
        IF p_line_type = 'C' THEN
          --loops around to check for identical column names
          FOR j IN 1..(i - 1) LOOP
            IF g_line_table(j) = l_section THEN
              l_file_name :=
                  HR_DU_RULES.RETURN_UPLOAD_HEADER_FILE(p_upload_header_id);
              l_fatal_error_message := ' Two columns have the same name ' ||
                                       l_section || ' in file ' ||
                                       l_file_name;
              RAISE e_fatal_error;
            END IF;
          END LOOP;
        END IF;
        g_line_table(i) := l_section;
      --
      ELSE
        g_line_table(i) := NULL;
      END IF;
    ELSE
      l_difference := l_position - l_next;
      l_section := SUBSTRB(p_data_line, l_next, l_difference);
      l_length := LENGTHB(l_section);
      IF l_length IS NULL THEN
        l_section := NULL;
      END IF;

      IF p_line_type = 'C' THEN
        --loops around to check for identical column names
        FOR j IN 1..(i - 1) LOOP
          IF g_line_table(j) = l_section THEN
            l_file_name := HR_DU_RULES.RETURN_UPLOAD_HEADER_FILE
                                                (p_upload_header_id);
            l_fatal_error_message := ' Two columns have the same name ' ||
                                     l_section || ' in file ' ||
                                     l_file_name;
            RAISE e_fatal_error;
          END IF;
        END LOOP;
      END IF;

      g_line_table(i) := l_section;
    END IF;
    --sets the cursor positions up for the next pass
    l_next := l_position + 1;
    --
  END LOOP;

  --loops through the remaining 230 files in the array and fill with null
  FOR j IN (l_number_words + 1)..230 LOOP
    g_line_table(j) := NULL;
  END LOOP;

--
  hr_du_utility.message('ROUT',
                        'exit:hr_du_di_insert.parse_line_to_table', 15);
--
EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.parse_line_to_table',
                                  l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.parse_line_to_table',
                       '(none)', 'R');
    RAISE;
--
END PARSE_LINE_TO_TABLE;



-- ------------------------- CHECK_UNIQUE_FILES ---------------------------
-- Description: Checks to make sure that there are no two or more files
-- that have the same file name. It does this by counting the total files
-- in the descriptors and then the total of unique file name
--
--  Input Parameters
--     p_upload_id     - Identifies the upload associated with the files
-- -------------------------------------------------------------------------
PROCEDURE CHECK_UNIQUE_FILES (p_upload_id IN NUMBER)
IS

  l_counter_1		NUMBER;
  l_counter_2   	NUMBER;
  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);

  CURSOR csr_total_count IS
  SELECT count (value)
    FROM  hr_du_descriptors
    WHERE upload_id = p_upload_id
    AND   DESCRIPTOR_TYPE = 'F';

  CURSOR csr_file_count IS
  SELECT count(distinct value)
    FROM  hr_du_descriptors
    WHERE upload_id = p_upload_id
    AND   DESCRIPTOR_TYPE = 'F';

BEGIN
--
  hr_du_utility.message('ROUT',
                        'entry:hr_du_di_insert.check_unique_files', 5);
--

  OPEN csr_total_count;
    FETCH csr_total_count INTO l_counter_1;
    IF csr_total_count%NOTFOUND THEN
      l_fatal_error_message := 'Error occured trying to count all of the '
                               || 'files in the upload';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_total_count;

  OPEN csr_file_count;
    FETCH csr_file_count INTO l_counter_2;
    IF csr_file_count%NOTFOUND THEN
      l_fatal_error_message := 'Error occured trying to count all of the '
                               || 'distinct files in the upload';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_file_count;

  IF l_counter_1 <> l_counter_2 THEN
    l_fatal_error_message := 'There are APIs with identical file ' ||
                             'names on the header sheet';
    RAISE e_fatal_error;
  END IF;

--
  hr_du_utility.message('ROUT',
                        'exit:hr_du_di_insert.check_unique_files', 15);
--
EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.validate_api_ids',
                        l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.check_unique_files',
                       '(none)', 'R');
    RAISE;
--
END CHECK_UNIQUE_FILES;


-- ------------------------- POPULATE_DYNAMIC_TABLE ------------------------
-- Description: This procedure is called once and simply populates the
-- dynamic SQL table with the appropriate hr_du_utility.local_CHR(i) values.
-- The Upper case are in positions 1..26 and Lower case in 27..52
-- -------------------------------------------------------------------------
PROCEDURE POPULATE_DYNAMIC_TABLE
IS

  l_counter	NUMBER		:= 1;

BEGIN
--
  hr_du_utility.message('ROUT',
                        'entry:hr_du_di_insert.populate_dynamic_table', 5);
--

  --Loop around the upper case letters
  FOR i IN 65..90 LOOP
    Char_table(l_counter) := hr_du_utility.local_CHR(i);
    l_counter := l_counter + 1;
  END LOOP;

  --Loop around the lower case letters
  FOR i IN 97..122 LOOP
    Char_table(l_counter) := hr_du_utility.local_CHR(i);
    l_counter := l_counter + 1;
  END LOOP;

--
  hr_du_utility.message('ROUT',
                        'exit:hr_du_di_insert.populate_dynamic_table', 15);
--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.populate_dynamic_table',
                       '(none)', 'R');
    RAISE;
--
END POPULATE_DYNAMIC_TABLE;


-- -------------------------- VALIDATE_API_IDS ----------------------------
-- Description: This procedure simply finds out where the ID column is with
-- in the HR_DU_UPLOAD_LINES for a particular header and verfies that all
-- the values within that ID coulmn are unique.
--
--  Input Parameters
--     p_upload_header_id   - Identify the upload header
-- ------------------------------------------------------------------------
PROCEDURE VALIDATE_API_IDS(p_upload_header_id IN NUMBER)
IS

  CURSOR csr_line_id IS
  SELECT UPLOAD_LINE_ID
    FROM  hr_du_upload_lines
    WHERE upload_header_id = p_upload_header_id
    AND   LINE_TYPE = 'C';

  CURSOR csr_API_name IS
  SELECT upper(des.value)
    FROM  hr_du_upload_headers head,
          hr_api_modules api,
          hr_du_descriptors des
    WHERE head.upload_header_id = p_upload_header_id
    AND   head.upload_header_id = des.upload_header_id
    AND   head.api_module_id = api.api_module_id
    AND   upper(api.module_name) = upper(des.value);


  CURSOR csr_count IS
    Select count(PVAL001)
    FROM hr_du_upload_lines
    WHERE upload_header_id = p_upload_header_id;

  CURSOR csr_count_distinct IS
    Select count(DISTINCT PVAL001)
    FROM hr_du_upload_lines
    WHERE upload_header_id = p_upload_header_id;


  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_line_id		NUMBER;
  l_current_pval	VARCHAR2(10);
  l_pval_field		VARCHAR2(50);
  l_spaces		BOOLEAN;
  l_count1		NUMBER;
  l_count2		NUMBER;
  l_dynamic_string	VARCHAR2(2000);
  l_file		VARCHAR2(200);
  l_cursor_handle	INT;

BEGIN
--
  hr_du_utility.message('ROUT',
                        'entry:hr_du_di_insert.validate_api_ids', 5);
  hr_du_utility.message('PARA',
          '(p_upload_header_id - ' || p_upload_header_id || ')' , 10);
--

  OPEN csr_line_id;
    FETCH csr_line_id INTO l_line_id;
    IF csr_line_id%NOTFOUND THEN
      l_fatal_error_message := 'No appropriate column title row exists in '
                               || 'the HR_DU_UPLOAD_LINES';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_line_id;

  HR_DU_DO_DATAPUMP.STORE_COLUMN_HEADINGS(l_line_id);

  FOR i IN 1..230 LOOP
  --
    l_current_pval := LPAD(i,3,'0');
    l_current_pval := 'PVAL' || l_current_pval;

    --fetch the heading stored within the specified upload line
      l_pval_field   := HR_DU_DO_DATAPUMP.g_column_headings(i);

    hr_du_dp_pc_conversion.REMOVE_SPACES (l_pval_field, l_spaces);

    IF l_spaces = TRUE THEN
      hr_du_utility.message('INFO', 'Warning : l_pval_field (with ' ||
                            'spaces removed) : ' || l_pval_field , 20);
    END IF;
  --
  END LOOP;

  OPEN csr_count;
     FETCH csr_count INTO l_count1;
     IF csr_count%NOTFOUND THEN
       l_fatal_error_message := 'Unable to count the number of column Ids';
       RAISE e_fatal_error;
     END IF;
  CLOSE csr_count;

  OPEN csr_count_distinct;
     FETCH csr_count_distinct INTO l_count2;
     IF csr_count_distinct%NOTFOUND THEN
       l_fatal_error_message := 'Unable to count the number of distinct ' ||
                                'column Ids';
       RAISE e_fatal_error;
     END IF;
  CLOSE csr_count_distinct;

  IF l_count1 <> l_count2 THEN
  --
    OPEN csr_API_name;
      FETCH csr_API_name INTO l_file;
      IF csr_API_name%NOTFOUND THEN
        l_fatal_error_message := 'No appropriate API name exists.';
        RAISE e_fatal_error;
      END IF;
    CLOSE csr_API_name;

    l_fatal_error_message :='ID values are not unique with in the file '
                            || l_file;
    RAISE e_fatal_error;
  END IF;

--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.validate_api_ids', 15);
--
EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.validate_api_ids',
    l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.validate_api_ids',
                       '(none)', 'R');
    RAISE;
--
END VALIDATE_API_IDS;



-- ----------------------- SET_DElIMITER_STRING ----------------------------
-- Description: Sets the representation of the current global delimiter as
-- a string this allows special characters such as tabs to be visually
-- represented
-- ------------------------------------------------------------------------
PROCEDURE SET_DElIMITER_STRING IS

BEGIN

  IF g_current_delimiter = g_tab_delimiter THEN
    g_current_delimiter_string := '** ( tab ) **';
  ELSIF g_current_delimiter = g_carr_delimiter THEN
    g_current_delimiter_string := '** ( Carriage return ) **';
  ELSIF g_current_delimiter = g_linef_delimiter THEN
    g_current_delimiter_string := '** ( Line Feed ) **';
  ELSE
    g_current_delimiter_string := g_current_delimiter;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.set_delimiter_string',
                       '(none)', 'R');
    RAISE;
--
END SET_DElIMITER_STRING;


-- ------------------------- NUM_DELIMITERS ------------------------------
-- Description: Returns the number of delimiters within the line of text
--
--  Input Parameters
--        p_line        - line of text passed to be checked
--
--  Output Parameters
--        Num_Delimiters- the number of delimiters in the line
--
-- ------------------------------------------------------------------------
FUNCTION NUM_DELIMITERS (p_line IN VARCHAR2)
                         RETURN NUMBER
IS

--the position of the delimiter in the string
  l_position	NUMBER;
--this is the next cursor position to search from
  l_next	NUMBER	:=	1;
--the number of delimiters encountered so far
  l_count	NUMBER	:=	0;

BEGIN

  IF p_line IS null THEN
    l_count := 0;
  ELSE
    LOOP
      --
      l_position := INSTRB(p_line, g_current_delimiter, l_next, 1);
      EXIT WHEN l_position = 0;
      l_next := l_position + 1;
      l_count := l_count + 1;
      --
    END LOOP;
  END IF;

  RETURN l_count;

--error handling
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.num_delimiters',
                       '(none)', 'R');
    RAISE;
--
END NUM_DELIMITERS;


-- ----------------------------- WORDS_ON_LINE  ---------------------------
-- Description: Tells you how many words are on the line, for there's
-- a difference to the way comma and tab file lines end.
--
--  Input Parameters
--        p_line         - line of text passed to be checked
--
--  Output Parameters
--       l_number_del    - Number of words
--
-- ------------------------------------------------------------------------
FUNCTION WORDS_ON_LINE (p_line IN VARCHAR2)
                        RETURN NUMBER
IS
  l_number_del	NUMBER;
  l_section	VARCHAR2(2000);

BEGIN

  l_number_del := g_delimiter_count;
  l_section := Return_Word (p_line, (l_number_del + 1));

  IF l_section IS NOT NULL THEN
    l_number_del := l_number_del + 1;
  END IF;

  RETURN l_number_del;

--error handling
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.words_on_line','(none)',
                        'R');
    RAISE;
END WORDS_ON_LINE;



-- --------------------------- REMOVE_GARBAGE  ----------------------------
-- Description: Removes all the delimiters from the line of text.
--
--  Input Parameters
--        p_line         - line of text passed to be checked
--
--  Output Parameters
--       l_new_data_line - The new line with out the delimiters
--
-- ------------------------------------------------------------------------
FUNCTION REMOVE_GARBAGE (p_line IN VARCHAR2)
                         RETURN VARCHAR2
IS

  l_temp_line		VARCHAR2(32767);
  l_new_data_line	VARCHAR2(32767);

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.remove_garbage', 5);
  hr_du_utility.message('PARA', '(p_line - ' || p_line || ')' , 10);
--

--this loop handles removing i.e carrage returns from the line
  IF g_delimiter_count = 0 THEN
    l_new_data_line := p_line;
  ELSE
    FOR i IN 1..(g_delimiter_count + 1) LOOP
      l_temp_line := Return_Word(p_line, i);
      l_new_data_line := l_new_data_line || l_temp_line;
    END LOOP;
  END IF;
--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.remove_garbage', 15);
  hr_du_utility.message('PARA', '(l_new_data_line - ' || l_new_data_line
                        || ')' , 20);
--
  RETURN l_new_data_line;

--error handling
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.remove_garbage','(none)',
                        'R');
    RAISE;

END REMOVE_GARBAGE;


-- ------------------------- NEXT_LINE -----------------------------------
-- Description: Returns the next line from the flat file and calls
-- remove garbage to extract unwanted data.
--
--  Input Parameters
--      p_filehandle         - line of text passed to be checked
--
--      p_upload_header_id   - when NO_DATA_FOUND then this number is used
--                             to find out which API the problem is in.
--
--  Output Parameters
--      l_data_line 	     - new line with the removed articles
--                             passed back
-- ------------------------------------------------------------------------
FUNCTION NEXT_LINE (p_filehandle IN utl_file.file_type,
                    p_upload_header_id IN NUMBER ) RETURN VARCHAR2
IS

  l_data_line 		VARCHAR2(32767);
  l_api_name		VARCHAR2(50);
  l_string_length	NUMBER;

  CURSOR csr_api_name IS
  SELECT api.module_NAME
    FROM hr_api_modules api,
         hr_du_upload_headers head
    WHERE head.upload_header_id = p_upload_header_id
    AND   head.api_module_id = api.api_module_id;

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.next_line', 5);
  hr_du_utility.message('PARA', '(p_filehandle - Record type )' , 10);
--
  g_counter := g_counter + 1;
  utl_file.get_line(p_filehandle,l_data_line);
  l_string_length := LENGTH(l_data_line);
--
  hr_du_utility.message('INFO','Value of the line ' || l_data_line, 15);
--

  g_current_delimiter   := g_linef_delimiter;
  g_delimiter_count := Num_Delimiters(l_data_line);
  IF g_delimiter_count = 1 THEN
    l_data_line := SUBSTRB
                      (l_data_line, 1, l_string_length - g_length_linef);
  ELSIF g_delimiter_count > 1 THEN
    SET_DElIMITER_STRING;
    l_data_line := Remove_Garbage(l_data_line);
  END IF;

  g_current_delimiter   := g_carr_delimiter;
  g_delimiter_count := Num_Delimiters(l_data_line);
  IF g_delimiter_count = 1 THEN
    l_data_line := SUBSTRB
                       (l_data_line, 1, l_string_length - g_length_carr);
  ELSIF g_delimiter_count > 1 THEN
    SET_DElIMITER_STRING;
    l_data_line := Remove_Garbage(l_data_line);
  END IF;

  --general separator for the data file at the moment hard coded
  g_current_delimiter   := g_flat_file_delimiter;
  SET_DElIMITER_STRING;
  g_delimiter_count := Num_Delimiters(l_data_line);

--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.next_line', 20);
  hr_du_utility.message('PARA', '(l_data_line - ' || l_data_line || ')' ,
  25);
--

  RETURN l_data_line;

--error handling
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    OPEN csr_api_name;
      FETCH csr_api_name INTO l_api_name;
    CLOSE csr_api_name;
    hr_du_utility.error(SQLCODE, 'Problem at line ' || g_counter ||
              ' within the file relating to the API : '||
              l_api_name,'(none)', 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
                           'hr_du_di_insert.next_line','(none)', 'R');
    RAISE;
END NEXT_LINE;


-- ------------------------- RETURN_WORD ----------------------------------
-- Description: Returns the nth word in the line separated by delimiters
--
--  Input Parameters
--      p_line      - line of text passed to be worked on
--
--      p_word_num  - the nth word in the line that you want
--
--  Output Parameters
--      l_section   - the word that is removed from the line
--
--
-- ------------------------------------------------------------------------
FUNCTION RETURN_WORD (p_line IN VARCHAR2, p_word_num IN NUMBER)
                                                RETURN VARCHAR2
IS

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_position		NUMBER;
  l_difference		NUMBER;
  l_count		NUMBER	:=0;
  l_next		NUMBER	:=1;
  l_previous		NUMBER;
  l_section		VARCHAR2(2000);
  l_length		NUMBER;
  l_number_del		NUMBER;

BEGIN

  --check to catch a line with no delimiters in
  l_number_del := g_delimiter_count;
  l_length := LENGTHB(p_line);


  --catches one word on the line with no delimiters
  IF l_number_del = 0 THEN
    IF l_length > 0 THEN
      l_section := p_line;
    ELSIF p_line IS NULL THEN
      l_section := NULL;
    END IF;

  --catches first word with no delimiter before the word
  ELSIF p_word_num = 1 then
    l_position := 0;
    l_next := INSTRB(p_line, hr_du_di_insert.g_current_delimiter, 1, p_word_num);
    l_difference := (l_next - 1) - (l_position + 1);
    l_section := SUBSTRB(p_line, (l_position + 1) , (l_difference + 1));


  ELSIF p_word_num >= (l_number_del + 1) THEN
    --catches last word with no delimiter after the word
    IF p_word_num = (l_number_del + 1) THEN
      l_position := INSTRB(p_line, hr_du_di_insert.g_current_delimiter, 1, (p_word_num - 1));
      l_next := l_length;
      l_difference := l_next  - (l_position + 1);
      l_section := SUBSTRB(p_line, (l_position + 1) , (l_difference + 1));

    --requested words doesn't exist
    ELSE
      l_fatal_error_message :='Word number requested is greater' ||
                              ' than those on the line';
      RAISE e_fatal_error;
    END IF;

  --normal case
  ELSE
    l_position := INSTRB(p_line, hr_du_di_insert.g_current_delimiter, 1, (p_word_num - 1));
    l_next := INSTRB(p_line, hr_du_di_insert.g_current_delimiter, 1, p_word_num);
    l_difference := (l_next - 1) - (l_position + 1);
    l_section := SUBSTRB(p_line, (l_position + 1) , (l_difference + 1));
  END IF;


  RETURN l_section;

--error handling
EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.return_word',
    l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
                        'hr_du_di_insert.return_word','(none)', 'R');
    RAISE;
END RETURN_WORD;


-- ------------------------- GENERAL_EXTRACT ------------------------------
-- Description: This procedure updates the HR_DU_DESCRIPTORS tables
-- by storing the API names and locations into table
--
--  Input Parameters
--      p_filehandle      - the file to be worked on
--
--      p_upload_id       - HR_DU_UPLOAD_ID
--
--      p_upload_header_id- HR_DU_UPLOAD_HEADER_ID
--
--      p_string          - The word in column one of the spread sheet tag
--
--      p_descriptor_type - Either D or F inputted into the descriptor table
--
-- ------------------------------------------------------------------------

PROCEDURE GENERAL_EXTRACT (p_filehandle IN utl_file.file_type,
                 p_upload_id IN NUMBER,
                 p_upload_header_id IN NUMBER, p_string IN VARCHAR2,
		 p_descriptor_type IN VARCHAR)
IS

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_data_line		VARCHAR2(2000);
  l_Col_one		VARCHAR2(2000);
  l_Col_two		VARCHAR2(2000);
  l_file_name		VARCHAR2(2000);

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.general_extract', 5);
  hr_du_utility.message('PARA', '(p_filehandle - Record Type)' ||
		'(p_upload_id - ' || p_upload_id ||
		')(p_upload_header_id - ' || p_upload_header_id ||
		')(p_string - ' || p_string ||
		')(p_descriptor_type - ' || p_descriptor_type || ')' , 10);
--
  LOOP
    BEGIN
      l_data_line := next_line(p_filehandle, p_upload_header_id);
      hr_du_utility.message('INFO','Processing Line - ' || l_data_line, 15);
      --call return_word to get the first word which is the descriptor
      l_Col_one := upper(Return_Word (l_data_line, 1));
      l_Col_two := upper(Return_Word (l_data_line, 2));
      EXIT WHEN (l_Col_one = p_string)
      AND  (l_Col_two = 'START');

      --checks for syntax errors in the spreadsheet header
      IF (l_Col_one = p_string)  OR (l_Col_one = 'DATA')
      AND (l_Col_two = 'END') OR  (l_Col_two = 'START') THEN
        l_fatal_error_message := 'Syntax error File incorrectly ' ||
        'Started. START ' || p_string ||
        ' must be present in the flat file ';
        RAISE e_fatal_error;
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        l_fatal_error_message := 'Incorrect syntax for header' ||
        'Error occured at row ' || g_counter;
        RAISE e_fatal_error;
    END;
  END LOOP;
  --
  LOOP
    BEGIN
     l_data_line := next_line(p_filehandle, p_upload_header_id);
     hr_du_utility.message('INFO','Processing Line - ' || l_data_line, 20);
     IF l_data_line IS NULL THEN
         null;
      ELSE
        l_Col_one := Return_Word (l_data_line, 1);
        l_Col_two := Return_Word (l_data_line, 2);

        -- statement to catch for null values in the descriptors
        IF l_Col_two IS NULL THEN
          IF p_upload_header_id IS NOT NULL THEN
            l_file_name := HR_DU_RULES.RETURN_UPLOAD_HEADER_FILE
                                                  (p_upload_header_id);
            l_fatal_error_message := 'A value must be supplied for the ' ||
                                     l_Col_one || ' in the file ' ||
                                     l_file_name;
            RAISE e_fatal_error;
          ELSE
            l_fatal_error_message := 'A value must be supplied for the ' ||
                                     l_Col_one || ' in the header sheet';
            RAISE e_fatal_error;
          END IF;
        END IF;

        EXIT WHEN (UPPER(l_Col_one) = p_string)
        AND  (UPPER(l_Col_two) = 'END');

        --insert into the descriptors table the values
        hr_du_utility.message('INFO','Insert statement', 25);
        INSERT INTO HR_DU_DESCRIPTORS(
           DESCRIPTOR_ID, UPLOAD_ID, UPLOAD_HEADER_ID,
  	   DESCRIPTOR, VALUE, DESCRIPTOR_TYPE, LAST_UPDATE_DATE,
	   LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY,
	   CREATION_DATE)
        VALUES(
          HR_DU_DESCRIPTORS_S.nextval,
          p_upload_id,
          p_upload_header_id,
          UPPER(l_Col_one),
          l_Col_two,
          p_descriptor_type,
          sysdate,
          1,
          1,
          1,
          sysdate);
        COMMIT;
        --
        IF (UPPER(l_Col_one) = p_string OR UPPER(l_Col_one) =  'DATA' OR
            UPPER(l_Col_one) =  'FILES')
        AND (UPPER(l_Col_two) = 'START' OR UPPER(l_Col_two) =  'END' ) THEN
           l_fatal_error_message := 'Syntax error : Descriptor incorrectly '
           || 'terminated. - ' || p_string || ' END - Is not included.';
           RAISE e_fatal_error;
        END IF;
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        l_fatal_error_message := 'Data Incorrectly Terminated ' ||
        'Error occured at row ' || g_counter;
        RAISE e_fatal_error;
    END;
  END LOOP;
--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.general_extract', 30);
--

--error handling
EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.general_extract',
    l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
                    'hr_du_di_insert.general_extract','(none)', 'R');
    RAISE;

END GENERAL_EXTRACT;


-- ------------------------- EXTRACT_API_LOCATIONS ----------------------
-- Description: Calls General_extract with three extra variables to handle
-- removing the locations of the API files
--
--  Input Parameters
--      p_filehandle      - the file to be worked on
--
--      p_upload_id       - HR_DU_UPLOAD_ID
--
-- ------------------------------------------------------------------------
PROCEDURE EXTRACT_API_LOCATIONS (p_filehandle IN utl_file.file_type,
                                 p_upload_id  IN NUMBER)

IS
  l_file_descriptor	VARCHAR2(2000)	:='F';
  l_Column_one_header	VARCHAR2(2000)	:='FILES';
  l_upload_header_id    NUMBER		:= null;

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.extract_api_locations'
                        , 5);
--
  GENERAL_Extract (p_filehandle, p_upload_id, l_upload_header_id,
                   l_Column_one_header, l_file_descriptor);
--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.extract_api_locations'
                        , 10);
--

--error handling
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.extract_api_locations'
                        ,'(none)', 'R');
    RAISE;

END EXTRACT_API_LOCATIONS;


-- ------------------------- EXTRACT_HEADERS ------------------------------
-- Description: Calls General_extract with three extra variables to deal
-- with the headers of the file
--
--  Input Parameters
--      p_filehandle      - the file to be worked on
--
--      p_upload_id       - HR_DU_UPLOAD_ID
--
-- ------------------------------------------------------------------------
PROCEDURE EXTRACT_HEADERS (p_filehandle IN utl_file.file_type,
                           p_upload_id IN NUMBER)
IS
  l_file_descriptor	VARCHAR2(2000)	:='D';
  l_Column_one_header	VARCHAR2(2000)	:='HEADER';
  l_upload_header_id 	NUMBER		:= null;

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.extract_headers', 5);
--
  GENERAL_Extract(p_filehandle, p_upload_id, l_upload_header_id,
                  l_Column_one_header, l_file_descriptor);
  VALIDATE_HEADER_DESCRIPTORS(p_upload_id);
--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.extract_headers', 10);
--

--error handling
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.extract_headers',
                        '(none)', 'R');
    RAISE;

END EXTRACT_HEADERS;


-- ------------------------- EXTRACT_DESCRIPTORS -------------------------
-- Description: Calls General_extract with two extra variables to handle
-- the descriptor part of the input file. These are found at the top of
-- each API file. HR_DU_RULES is then called to validate the header's
-- set up.
--
--  Input Parameters
--      p_filehandle      - the file to be worked on
--
--      p_upload_id       - HR_DU_UPLOAD_ID
--
--     p_upload_header_id - HR_DU_UPLOAD_HEADER_ID
--
-- ------------------------------------------------------------------------
FUNCTION EXTRACT_DESCRIPTORS (p_filehandle IN utl_file.file_type,
                 p_upload_id IN NUMBER, p_upload_header_id IN NUMBER)
                 RETURN VARCHAR2
IS
  l_file_descriptor	VARCHAR2(2000)	:='D';
  l_Column_one_header	VARCHAR2(2000)	:='DESCRIPTOR';
  l_reference_type	VARCHAR2(100);

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.extract_descriptors',
                        5);
--
  GENERAL_Extract(p_filehandle, p_upload_id, p_upload_header_id,
                  l_Column_one_header, l_file_descriptor);
  VALIDATE_SHEET_DESCRIPTORS
                       (p_upload_id,p_upload_header_id);
  HR_DU_RULES.VALIDATE_USER_KEY_SETUP
                       (p_upload_header_id, p_upload_id);
  l_reference_type := HR_DU_RULES.VALIDATE_REFERENCING
                       (p_upload_header_id, p_upload_id);
  HR_DU_RULES.VALIDATE_STARTING_POINT
                       (p_upload_header_id, p_upload_id);
  HR_DU_RULES.PROCESS_ORDER_PRESENT
                       (p_upload_header_id);
  HR_DU_RULES.API_PRESENT_AND_CORRECT
                       (p_upload_header_id, p_upload_id);
--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.extract_descriptors',
                        10);
  hr_du_utility.message('PARA', '(l_reference_type - ' || l_reference_type
                        || ')' , 15);
--

  RETURN l_reference_type;

--error handling
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.extract_descriptors',
                      '(none)', 'R');
    RAISE;

END EXTRACT_DESCRIPTORS;


-- ------------------------- HANDLE_API_FILES ----------------------------
-- Description: This procedure loops around the number of API files to be
-- processed and imports all of the relevant data into the corresponding
-- ORACLE tables.
--
--  Input Parameters
--
--      p_Location        - The location of the directory where the files
--                          will be held
--
--      p_upload_id       - HR_DU_UPLOAD_ID
--
-- ------------------------------------------------------------------------
PROCEDURE HANDLE_API_FILES(p_Location IN VARCHAR2, p_upload_id IN NUMBER)
IS

--this cursor stores the API id, name and location, from the descriptor
--API table
  CURSOR csr_files IS
  SELECT des.descriptor_id, api.api_module_id, upper(api.module_NAME),
         des.VALUE
    FROM hr_api_modules api,
         hr_du_descriptors des
    WHERE upper(api.module_NAME) = upper(des.DESCRIPTOR)
      AND   des.DESCRIPTOR_TYPE = 'F'
      AND   des.upload_id = p_upload_id;


--This cursor identifies the api_names that aren't spelt correctly
--within the flat file.
  CURSOR csr_incorrect IS
  SELECT des.DESCRIPTOR
  FROM hr_du_descriptors des
  WHERE des.DESCRIPTOR_TYPE = 'F'
    AND   des.upload_id = p_upload_id
    AND upper(des.DESCRIPTOR) NOT IN (	SELECT upper(des.DESCRIPTOR)
    				FROM hr_api_modules api,
         			     hr_du_descriptors des
				WHERE upper(api.module_NAME) =
                                      upper(des.DESCRIPTOR)
      				  AND des.DESCRIPTOR_TYPE = 'F'
    				  AND des.upload_id = p_upload_id);


  e_fatal_error 		EXCEPTION;
  l_fatal_error_message		VARCHAR2(2000);
  l_file_record     		csr_files%ROWTYPE;
  l_filehandle    		UTL_FILE.FILE_TYPE;
  l_upload_header_id		NUMBER;
  l_reference_type		VARCHAR2(10);
  l_descriptor			VARCHAR2(50);
  l_table_size			NUMBER	:= 0;
  l_original_upload_header_id 	NUMBER;
  l_found_value			BOOLEAN;
  l_next_table_value		NUMBER;


BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.handle_api_files', 5);
  hr_du_utility.message('PARA', '(p_Location - ' || p_Location ||
       			  ')(p_upload_id - ' || p_upload_id || ')' , 10);
--
  g_header_table.delete;
  OPEN csr_incorrect;
  FETCH csr_incorrect INTO l_descriptor;
  IF csr_incorrect%FOUND THEN
     l_fatal_error_message := 'Unknown api name '|| l_descriptor ||
                              ' on header sheet ';
      RAISE e_fatal_error;
  END IF;
  CLOSE csr_incorrect;

  Update_Upload_table(p_upload_id);
  OPEN csr_files;
  LOOP
    FETCH csr_files INTO l_file_record;
    EXIT WHEN csr_files%NOTFOUND;

    SELECT HR_DU_UPLOAD_HEADERS_S.nextval
      INTO l_upload_header_id
      FROM dual;


    hr_du_utility.message('INFO','Insert statement', 15);
    --Creating upload_header
    INSERT INTO HR_DU_UPLOAD_HEADERS(
      UPLOAD_HEADER_ID, UPLOAD_ID, API_MODULE_ID, STATUS,
      LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
      CREATED_BY, CREATION_DATE)
    VALUES(
      l_upload_header_id,
      p_upload_id,
      l_file_record.API_MODULE_ID,
      'NS',
      sysdate,
      1,
      1,
      1,
      sysdate);
    COMMIT;


    l_original_upload_header_id := l_upload_header_id;
    -- open the new file relating to the current API
    l_filehandle := Open_file (p_Location, l_file_record.VALUE);
    hr_du_utility.message('INFO','File Opened', 20);

    l_reference_type := Extract_descriptors(l_filehandle, p_upload_id,
                                          l_upload_header_id);
    hr_du_utility.message('INFO','Extracted Descriptors;', 25);


    l_found_value := FALSE;
    l_table_size := g_header_table.count;
    hr_du_utility.message('INFO','l_table_size : ' || l_table_size , 30);


    --This statement loops around the table checking to see whether
    --the API_module_id has already been assigned to an upload_header
    --if so the header's id which has been assigned is taken.
    FOR i IN 1..l_table_size LOOP
    --
      IF g_header_table(i).r_api_module_id = l_file_record.API_MODULE_ID THEN
        l_upload_header_id := g_header_table(i).r_upload_header_id;
        l_found_value := TRUE;

        --Here I'll set the API value in the descriptor table to null
        --so that it isn't retrieved in later searches
        UPDATE hr_du_descriptors
        SET    value = NULL
        WHERE  upload_header_id = l_original_upload_header_id
	AND    descriptor = 'API';

        COMMIT;
        EXIT;
      END IF;
    END LOOP;

    --Adds the entry into the table for the next loop;
    l_next_table_value := l_table_size + 1;

    IF l_found_value = FALSE THEN
      g_header_table(l_next_table_value).r_api_module_id
                             := l_file_record.API_MODULE_ID;
      g_header_table(l_next_table_value).r_upload_header_id
      			     := l_upload_header_id;
    END IF;

    Extract_lines(l_filehandle, p_upload_id, l_original_upload_header_id,
                  l_reference_type, l_file_record.API_MODULE_ID,
                  l_upload_header_id);

    --Enter search to vaildate that no two identical API id's have
    --been entered in the flat file
    VALIDATE_API_IDS(l_upload_header_id);
  END LOOP;
  CLOSE csr_files;

--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.handle_api_files', 30);
--

--error handling
EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.handle_api_files',
                                  l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.handle_api_files',
                        '(none)', 'R');
    RAISE;

END HANDLE_API_FILES;


-- -------------------------- UPDATE_UPLOAD_TABLE  -------------------------
-- Description: This procedure updates the upload table from the information
-- that came in through the headers in the first file.
--
--  Input Parameters
--
--      p_upload_id       - HR_DU_UPLOAD_ID
-- ------------------------------------------------------------------------
PROCEDURE UPDATE_UPLOAD_TABLE (p_upload_id IN NUMBER)
IS

  e_fatal_error 		EXCEPTION;
  l_fatal_error_message		VARCHAR2(2000);
  l_business_group_file		VARCHAR2(2000);
  l_business_group_profile 	VARCHAR2(80);
  l_business_group_name		VARCHAR2(80);
  l_business_group_id	 	NUMBER;
  l_batch_name			VARCHAR2(200);
  l_global_data 		VARCHAR2(2000);

--This cursor extracts the business group name from the upload table
  CURSOR csr_business_group IS
  SELECT VALUE
    FROM hr_du_descriptors
    WHERE DESCRIPTOR = 'BUSINESS GROUP'
    AND UPLOAD_ID = p_upload_id;

--This cursor extracts the global data flag from the upload table
  CURSOR csr_global_data IS
  SELECT VALUE
    FROM hr_du_descriptors
    WHERE DESCRIPTOR = 'GLOBAL DATA'
    AND UPLOAD_ID = p_upload_id;

--This cursor extracts the batch name from the upload table
  CURSOR csr_batch_name IS
  SELECT VALUE
    FROM hr_du_descriptors
    WHERE DESCRIPTOR = 'BATCH NAME'
    AND UPLOAD_ID = p_upload_id;

--This cursor extracts the business group name from the id value
  CURSOR csr_business_group_lookup IS
  SELECT NAME
    FROM per_business_groups
    WHERE BUSINESS_GROUP_ID = l_business_group_id;

BEGIN
--
  hr_du_utility.message('ROUT',
                       'entry:hr_du_di_insert.update_upload_table', 5);
  hr_du_utility.message('PARA',
                        '(p_upload_id - ' || p_upload_id || ')' , 10);
--

  OPEN csr_batch_name;
    FETCH csr_batch_name INTO l_batch_name;
    IF csr_batch_name%NOTFOUND THEN
      l_fatal_error_message := 'Error BATCH NAME value not found in ' ||
                               'header file';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_batch_name;

-- get business group name from descriptors table
  OPEN csr_business_group;
  FETCH csr_business_group INTO l_business_group_file;
  CLOSE csr_business_group;

  -- get business group name from profile
  -- This should be set at the responsibility level if there are multiple
  -- business groups or at the site level for a single business group
  fnd_profile.get('PER_BUSINESS_GROUP_ID', l_business_group_id);
  OPEN csr_business_group_lookup;
    FETCH csr_business_group_lookup INTO l_business_group_profile;
  CLOSE csr_business_group_lookup;

-- validate business groups
  hr_du_utility.message('INFO','l_business_group_profile - ' ||
                        l_business_group_profile, 15);
  hr_du_utility.message('INFO','l_business_group_file - ' ||
                        l_business_group_file, 15);
  hr_du_rules.validate_business_group(l_business_group_profile,
                                      l_business_group_file);


-- see if we are uploading global data
  OPEN csr_global_data;
    FETCH csr_global_data INTO l_global_data;
  CLOSE csr_global_data;


  IF (UPPER(l_global_data) = 'Y')
    OR (UPPER(l_global_data) = 'YES') THEN
    l_business_group_name := NULL;
  ELSE
    l_business_group_name := l_business_group_profile;
  END IF;

  hr_du_utility.message('INFO','Using business group name - ' ||
                        NVL(l_business_group_name,'NULL'), 15);


  UPDATE hr_du_uploads
  SET   BUSINESS_GROUP_NAME = l_business_group_name
  WHERE UPLOAD_ID = p_upload_id;

-- update descriptors table to ensure that the correct value is used
  UPDATE hr_du_descriptors
  SET   VALUE = l_business_group_name
  WHERE DESCRIPTOR = 'BUSINESS GROUP'
    AND UPLOAD_ID = p_upload_id;

-- check if a row has been updated, otherwise insert a record
  IF SQL%ROWCOUNT = 0 THEN
    INSERT INTO HR_DU_DESCRIPTORS(
           DESCRIPTOR_ID, UPLOAD_ID, UPLOAD_HEADER_ID,
  	   DESCRIPTOR, VALUE, DESCRIPTOR_TYPE, LAST_UPDATE_DATE,
	   LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY,
	   CREATION_DATE)
        VALUES(
          HR_DU_DESCRIPTORS_S.nextval,
          p_upload_id,
          null,
          'BUSINESS GROUP',
          l_business_group_name,
          'D',
          sysdate,
          1,
          1,
          1,
          sysdate);
    hr_du_utility.message('INFO','Row inserted into descriptors table', 15);
    COMMIT;
  ELSE
    hr_du_utility.message('INFO','Row updated in descriptors table', 20);
  END IF;

--
  hr_du_utility.message('ROUT',
                        'exit:hr_du_di_insert.update_upload_table', 25);
--

--error handling
EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.update_upload_table',
                        l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.update_upload_table',
                        '(none)', 'R');
    RAISE;

END UPDATE_UPLOAD_TABLE;


-- ------------------------- RETURN_FILE_NAME -----------------------------
-- Description: This function takes a upload_id and returns the
-- HR_DU_UPLOAD.SOURCE value
--
--  Input Parameters
--
--      p_upload_id       - HR_DU_UPLOAD_ID
--
-- ------------------------------------------------------------------------
FUNCTION RETURN_FILE_NAME(p_upload_id IN NUMBER) RETURN VARCHAR2
IS

CURSOR csr_source IS
  SELECT SOURCE
  FROM hr_du_uploads
  WHERE UPLOAD_ID = p_upload_id;

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_source_name		VARCHAR2(50);

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.return_file_name', 5);
  hr_du_utility.message('PARA',
                              '(p_upload_id - ' || p_upload_id || ')' , 10);
--
  OPEN csr_source;
    FETCH csr_source INTO l_source_name;
    IF csr_source%NOTFOUND THEN
      l_fatal_error_message := 'Error File name not found in ' ||
                               'HR_DU_UPLOAD table.';
      RAISE e_fatal_error;
    END IF;
  CLOSE csr_source;
--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.return_file_name', 15);
  hr_du_utility.message('PARA', '(l_source_name - ' || l_source_name ||
                        ')' , 20);
--
  RETURN l_source_name;

--error handling
EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.return_file_name',
                        l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.return_file_name',
                        '(none)', 'R');
    RAISE;

END RETURN_FILE_NAME;


-- ------------------------- OPEN_FILE ------------------------------------
-- Description: Opens the specified file in the named location
--
--  Input Parameters
--      p_file_location   - the file to be worked on
--
--      p_file_name       - defines the character that separates the words
--
--  Output Parameters
--      l_filehandle      - handle to the file so it can be referenced later
--
-- ------------------------------------------------------------------------
FUNCTION OPEN_FILE (p_file_location IN varchar2, p_file_name IN varchar2)
                   RETURN utl_file.file_type
IS
--
CURSOR csr_valid_profile IS
SELECT value
FROM v$parameter
WHERE name='utl_file_dir';
--
  l_filehandle      UTL_FILE.FILE_TYPE;
  l_location        VARCHAR2(2000);
  l_valid_profile   VARCHAR2(2000);
--
BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.open_file', 5);
  hr_du_utility.message('PARA', '(p_file_location - ' || p_file_location ||
             ')(p_file_name - ' || p_file_name || ')' , 10);
--
OPEN csr_valid_profile;
FETCH csr_valid_profile INTO l_valid_profile;
CLOSE csr_valid_profile;
--
  fnd_profile.get('PER_DATA_EXCHANGE_DIR', l_location);
--
-- Output additional information to the log file concerning header file
--
  hr_du_utility.message('SUMM', 'File name ->' || p_file_name , 25);
  hr_du_utility.message('SUMM', 'File location/HR: Data Exchange Directory profile option->' || l_location , 30);
  hr_du_utility.message('SUMM', 'Valid options for HR: Data Exchange Directory profile ->' || l_valid_profile , 35);
--
  l_filehandle := utl_file.fopen(p_file_location, p_file_name, 'r', 32767);
  g_counter := 0;
--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.open_file', 15);
  hr_du_utility.message('PARA', '(l_filehandle -  File Type )' , 20);
--
  RETURN l_filehandle;
--error handling
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.Open_file',
           ' ERROR Opening - ' || p_file_name ||
           '. File may not exist or spelt incorrectly', 'R');
    RAISE;

END OPEN_FILE;


-- ------------------------- EXTRACT_LINES ------------------------------
-- Description: Takes the lines from the spreadsheet and inserts them in
-- the HR_DU_UPLOAD_LINES and takes into account the fact that all lines
-- must only have one header for one API. So if there are two headers with
-- the same API then all lines are placed into the first one.
--
--  Input Parameters
--      p_filehandle       	    - the file to be worked on
--
--      p_upload_id                 - HR_DU_UPLOAD_ID
--
--      p_original_upload_header_id - The original upload_header that this
--				      line is connected to
--
--      p_reference_type   	    - Either PC or CP
--
--      p_api_module_id		    - Identifies the API for this header
--
--      p_upload_header_id	    - The Header that the line is placed
--				      with so all the lines will be in a
--				      header with the ownership of the API
-- ------------------------------------------------------------------------
PROCEDURE EXTRACT_LINES(p_filehandle IN utl_file.file_type,
          p_upload_id IN NUMBER, p_original_upload_header_id IN NUMBER,
          p_reference_type IN VARCHAR2, p_api_module_id IN NUMBER,
          p_upload_header_id IN NUMBER)
IS

  e_fatal_error 	EXCEPTION;
  l_fatal_error_message	VARCHAR2(2000);
  l_Col_one		VARCHAR2(2000);
  l_Col_two		VARCHAR2(2000);
  l_data_line		VARCHAR2(32767);
  l_num_loop		NUMBER;
  l_line_id		NUMBER;
  l_line_type		VARCHAR2(2)		:='C';
  l_word		VARCHAR2(2000);
  l_none_blank		NUMBER;
  l_valid_column	VARCHAR2(200);
  l_chunk_size_master	NUMBER;
  l_chunk_size_slave	NUMBER;
  l_temp_number		NUMBER;
  l_header_file		VARCHAR2(200);

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.extract_lines', 5);
  hr_du_utility.message('ROUT', '(p_filehandle - File Type )'  ||
	 '(p_upload_id - ' || p_upload_id ||
  	 ')(p_original_upload_header_id - ' || p_original_upload_header_id ||
	 ')(p_reference_type - ' || p_reference_type ||
	 ')(p_api_module_id - ' || p_api_module_id ||
 	 ')(p_upload_header_id - ' || p_upload_header_id ||
         ')' , 10);
--
  l_chunk_size_master := hr_du_utility.chunk_size;

  LOOP
    BEGIN
      l_data_line := next_line(p_filehandle, p_original_upload_header_id);
      hr_du_utility.message('INFO',
                            'Data Line Header - ' || l_data_line , 15);
      --call return_word to get the first word which is the descriptor
      l_Col_one := Return_Word (l_data_line, 1);
      l_Col_two := Return_Word (l_data_line, 2);

      EXIT WHEN (UPPER(l_Col_one) = 'DATA')
      AND  (UPPER(l_Col_two) = 'START');

      --checks for syntax errors in the spreadsheet header
      IF (UPPER(l_Col_one) = 'DESCRIPTOR'  OR UPPER(l_Col_one) = 'FILES')
      AND (UPPER(l_Col_two) = 'END' OR  UPPER(l_Col_two) = 'START') THEN
        l_fatal_error_message := 'File incorrectly started ' ||
        'Encountered - ' || l_Col_one || ' ' || l_Col_two || ' tag' ||
        ' before DATA START ' ;
        RAISE e_fatal_error;
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        l_fatal_error_message := 'Incorrect syntax for header';
        RAISE e_fatal_error;
    END;
  END LOOP;
  --
  l_chunk_size_slave := l_chunk_size_master;
  LOOP
    BEGIN

      l_data_line := next_line(p_filehandle, p_original_upload_header_id);
      hr_du_utility.message('INFO','Data Line Data - ' || l_data_line , 20);

      --Add loop to check that there is valid data on the line and it
      --isn't just tabs and spaces.

      --Only looking for numbers
      FOR i IN 1..9 LOOP
        l_none_blank := INSTRB(l_data_line, to_char(i));
        IF l_none_blank > 0 THEN
          EXIT;
        END IF;
      END LOOP;
      --Only looking for upper case letters
      IF (l_none_blank = 0) THEN
        FOR i IN 1..26 LOOP
          l_none_blank := INSTRB(l_data_line, Char_table(i));
          IF l_none_blank > 0 THEN
            EXIT;
          END IF;
        END LOOP;
      END IF;

      --Only looking for lower case letters
      IF (l_none_blank = 0) THEN
        FOR i IN 27..52 LOOP
          l_none_blank := INSTRB(l_data_line, Char_table(i));
          IF l_none_blank > 0 THEN
            EXIT;
          END IF;
        END LOOP;
      END IF;

      IF (l_none_blank = 0) THEN
         null;
      ELSE
        l_num_loop := Words_On_Line (l_data_line);
        l_Col_one := Return_Word (l_data_line, 1);
        l_Col_two := Return_Word (l_data_line, 2);
        EXIT WHEN (UPPER(l_Col_one) = 'DATA')
        AND  (UPPER(l_Col_two) = 'END');

        --checks to see if the file has been terinated properly
        IF (UPPER(l_Col_one) = 'DESCRIPTOR' OR UPPER(l_Col_one) =  'FILES')
        AND (UPPER(l_Col_two) = 'START' OR UPPER(l_Col_one) =  'FILES') THEN
          l_fatal_error_message := 'Syntax error File incorrectly ' ||
          'terminated. Cause - ' || l_Col_one || ' ' || l_Col_two || ' tag.' ||
          ' Sholud have encountered the - DATA END - tag.';
          RAISE e_fatal_error;
        END IF;

        PARSE_LINE_TO_TABLE (l_data_line, p_original_upload_header_id, l_line_type);

        --Simple check of the column heading to make sure it's valid and
        --check that the user has not left out the column headings
        IF l_line_type = 'C' THEN
          l_word := Return_Word (l_data_line, 2);
          l_valid_column := hr_du_dp_pc_conversion.
                  GENERAL_REFERENCING_COLUMN(l_word, p_api_module_id, 'D');
          IF (l_word <> 'ID') AND (l_valid_column IS NULL) THEN
            l_fatal_error_message :=  l_word || ' is not a valid column ' ||
                                     ' heading';
            RAISE e_fatal_error;
          END IF;

         --Checks to make sure that the values in PVAL001 are all Numerical.
        ELSE
        --
	  BEGIN
	    l_temp_number := to_number(g_line_table(1));
	  EXCEPTION
	    WHEN value_error THEN
             l_header_file := hr_du_rules.RETURN_UPLOAD_HEADER_FILE
                              (p_original_upload_header_id);
             l_fatal_error_message :=  g_line_table(1) || ' is not a valid '
                                       || 'column id on line ' || g_counter
                                       || ' in the file ' || l_header_file ;
            RAISE e_fatal_error;
          END;
        END IF;

        --Makes sure that the column names are not duplicated if there
        --are two upload_headers with the same API
        IF (p_original_upload_header_id <> p_upload_header_id) AND
           (l_line_type = 'C') THEN
          null;
        ELSE
          hr_du_utility.message('INFO','Insert Statement Start ' , 25);

          INSERT INTO hr_du_upload_lines(
  	    UPLOAD_LINE_ID, UPLOAD_HEADER_ID, BATCH_LINE_ID,
  	    STATUS, REFERENCE_TYPE, LINE_TYPE, LAST_UPDATE_DATE,
            LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY,
            CREATION_DATE, DI_LINE_NUMBER, ORIGINAL_UPLOAD_HEADER_ID,
 	    PVAL001, PVAL002, PVAL003, PVAL004, PVAL005, PVAL006,
 	    PVAL007, PVAL008, PVAL009, PVAL010, PVAL011, PVAL012,
 	    PVAL013, PVAL014, PVAL015, PVAL016, PVAL017, PVAL018,
 	    PVAL019, PVAL020, PVAL021, PVAL022, PVAL023, PVAL024,
 	    PVAL025, PVAL026, PVAL027, PVAL028, PVAL029, PVAL030,
 	    PVAL031, PVAL032, PVAL033, PVAL034, PVAL035, PVAL036,
 	    PVAL037, PVAL038, PVAL039, PVAL040, PVAL041, PVAL042,
 	    PVAL043, PVAL044, PVAL045, PVAL046, PVAL047, PVAL048,
 	    PVAL049, PVAL050, PVAL051, PVAL052, PVAL053, PVAL054,
 	    PVAL055, PVAL056, PVAL057, PVAL058, PVAL059, PVAL060,
 	    PVAL061, PVAL062, PVAL063, PVAL064, PVAL065, PVAL066,
 	    PVAL067, PVAL068, PVAL069, PVAL070, PVAL071, PVAL072,
 	    PVAL073, PVAL074, PVAL075, PVAL076, PVAL077, PVAL078,
 	    PVAL079, PVAL080, PVAL081, PVAL082, PVAL083, PVAL084,
 	    PVAL085, PVAL086, PVAL087, PVAL088, PVAL089, PVAL090,
 	    PVAL091, PVAL092, PVAL093, PVAL094, PVAL095, PVAL096,
 	    PVAL097, PVAL098, PVAL099, PVAL100, PVAL101, PVAL102,
 	    PVAL103, PVAL104, PVAL105,PVAL106, PVAL107, PVAL108,
 	    PVAL109, PVAL110, PVAL111,PVAL112, PVAL113, PVAL114,
 	    PVAL115, PVAL116, PVAL117,PVAL118, PVAL119, PVAL120,
 	    PVAL121, PVAL122, PVAL123,PVAL124, PVAL125, PVAL126,
 	    PVAL127, PVAL128, PVAL129,PVAL130, PVAL131, PVAL132,
 	    PVAL133, PVAL134, PVAL135,PVAL136, PVAL137, PVAL138,
 	    PVAL139, PVAL140, PVAL141,PVAL142, PVAL143, PVAL144,
 	    PVAL145, PVAL146, PVAL147,PVAL148, PVAL149, PVAL150,
 	    PVAL151, PVAL152, PVAL153,PVAL154, PVAL155, PVAL156,
 	    PVAL157, PVAL158, PVAL159,PVAL160, PVAL161, PVAL162,
 	    PVAL163, PVAL164, PVAL165,PVAL166, PVAL167, PVAL168,
 	    PVAL169, PVAL170, PVAL171,PVAL172, PVAL173, PVAL174,
 	    PVAL175, PVAL176, PVAL177,PVAL178, PVAL179, PVAL180,
 	    PVAL181, PVAL182, PVAL183,PVAL184, PVAL185, PVAL186,
 	    PVAL187, PVAL188, PVAL189,PVAL190, PVAL191, PVAL192,
 	    PVAL193, PVAL194, PVAL195,PVAL196, PVAL197, PVAL198,
 	    PVAL199, PVAL200, PVAL201,PVAL202, PVAL203, PVAL204,
 	    PVAL205, PVAL206, PVAL207,PVAL208, PVAL209, PVAL210,
 	    PVAL211, PVAL212, PVAL213,PVAL214, PVAL215, PVAL216,
  	    PVAL217, PVAL218, PVAL219,PVAL220, PVAL221, PVAL222,
 	    PVAL223, PVAL224, PVAL225,PVAL226, PVAL227, PVAL228,
 	    PVAL229, PVAL230 )
          VALUES(
  	    HR_DU_UPLOAD_LINES_S.nextval, p_upload_header_id, null, 'NS',
  	    p_reference_type, l_line_type, sysdate,
	    1, 1, 1, sysdate, g_counter, p_original_upload_header_id,
 	    g_line_table(1), g_line_table(2), g_line_table(3),
     	    g_line_table(4), g_line_table(5), g_line_table(6),
 	    g_line_table(7), g_line_table(8), g_line_table(9),
 	    g_line_table(10), g_line_table(11), g_line_table(12),
 	    g_line_table(13), g_line_table(14), g_line_table(15),
 	    g_line_table(16), g_line_table(17), g_line_table(18),
 	    g_line_table(19), g_line_table(20), g_line_table(21),
 	    g_line_table(22), g_line_table(23), g_line_table(24),
 	    g_line_table(25), g_line_table(26), g_line_table(27),
 	    g_line_table(28), g_line_table(29), g_line_table(30),
 	    g_line_table(31), g_line_table(32), g_line_table(33),
 	    g_line_table(34), g_line_table(35), g_line_table(36),
 	    g_line_table(37), g_line_table(38), g_line_table(39),
 	    g_line_table(40), g_line_table(41), g_line_table(42),
 	    g_line_table(43), g_line_table(44), g_line_table(45),
 	    g_line_table(46), g_line_table(47), g_line_table(48),
 	    g_line_table(49), g_line_table(50), g_line_table(51),
 	    g_line_table(52), g_line_table(53), g_line_table(54),
 	    g_line_table(55), g_line_table(56), g_line_table(57),
 	    g_line_table(58), g_line_table(59), g_line_table(60),
 	    g_line_table(61), g_line_table(62), g_line_table(63),
 	    g_line_table(64), g_line_table(65), g_line_table(66),
 	    g_line_table(67), g_line_table(68), g_line_table(69),
 	    g_line_table(70), g_line_table(71), g_line_table(72),
 	    g_line_table(73), g_line_table(74), g_line_table(75),
 	    g_line_table(76), g_line_table(77), g_line_table(78),
 	    g_line_table(79), g_line_table(80), g_line_table(81),
 	    g_line_table(82), g_line_table(83), g_line_table(84),
 	    g_line_table(85), g_line_table(86), g_line_table(87),
 	    g_line_table(88), g_line_table(89), g_line_table(90),
 	    g_line_table(91), g_line_table(92), g_line_table(93),
 	    g_line_table(94), g_line_table(95), g_line_table(96),
 	    g_line_table(97), g_line_table(98), g_line_table(99),
 	    g_line_table(100),g_line_table(101),g_line_table(102),
 	    g_line_table(103),g_line_table(104),g_line_table(105),
 	    g_line_table(106),g_line_table(107),g_line_table(108),
 	    g_line_table(109),g_line_table(110),g_line_table(111),
 	    g_line_table(112),g_line_table(113),g_line_table(114),
 	    g_line_table(115),g_line_table(116),g_line_table(117),
 	    g_line_table(118),g_line_table(119),g_line_table(120),
 	    g_line_table(121),g_line_table(122),g_line_table(123),
 	    g_line_table(124),g_line_table(125),g_line_table(126),
 	    g_line_table(127),g_line_table(128),g_line_table(129),
 	    g_line_table(130),g_line_table(131),g_line_table(132),
 	    g_line_table(133),g_line_table(134),g_line_table(135),
 	    g_line_table(136),g_line_table(137),g_line_table(138),
 	    g_line_table(139),g_line_table(140),g_line_table(141),
 	    g_line_table(142),g_line_table(143),g_line_table(144),
 	    g_line_table(145),g_line_table(146),g_line_table(147),
 	    g_line_table(148),g_line_table(149),g_line_table(150),
 	    g_line_table(151),g_line_table(152),g_line_table(153),
 	    g_line_table(154),g_line_table(155),g_line_table(156),
 	    g_line_table(157),g_line_table(158),g_line_table(159),
 	    g_line_table(160),g_line_table(161),g_line_table(162),
 	    g_line_table(163),g_line_table(164),g_line_table(165),
 	    g_line_table(166),g_line_table(167),g_line_table(168),
 	    g_line_table(169),g_line_table(170),g_line_table(171),
 	    g_line_table(172),g_line_table(173),g_line_table(174),
 	    g_line_table(175),g_line_table(176),g_line_table(177),
 	    g_line_table(178),g_line_table(179),g_line_table(180),
 	    g_line_table(181),g_line_table(182),g_line_table(183),
 	    g_line_table(184),g_line_table(185),g_line_table(186),
 	    g_line_table(187),g_line_table(188),g_line_table(189),
 	    g_line_table(190),g_line_table(191),g_line_table(192),
 	    g_line_table(193),g_line_table(194),g_line_table(195),
 	    g_line_table(196),g_line_table(197),g_line_table(198),
 	    g_line_table(199),g_line_table(200),g_line_table(201),
 	    g_line_table(202),g_line_table(203),g_line_table(204),
 	    g_line_table(205),g_line_table(206),g_line_table(207),
 	    g_line_table(208),g_line_table(209),g_line_table(210),
 	    g_line_table(211),g_line_table(212),g_line_table(213),
 	    g_line_table(214),g_line_table(215),g_line_table(216),
 	    g_line_table(217),g_line_table(218),g_line_table(219),
 	    g_line_table(220),g_line_table(221),g_line_table(222),
 	    g_line_table(223),g_line_table(224),g_line_table(225),
 	    g_line_table(226),g_line_table(227),g_line_table(228),
 	    g_line_table(229),g_line_table(230));
          --
            COMMIT;
          --statement to commit every <CHUNK_SIZE>
          IF l_chunk_size_slave = 0 THEN
            COMMIT;
            l_chunk_size_slave := l_chunk_size_master;
          ELSE
            l_chunk_size_slave := l_chunk_size_slave - 1;
          END IF;
        END IF;
      hr_du_utility.message('INFO','Insert Statement End ' , 30);
      END IF;
      l_line_type := 'D';

    EXCEPTION
      WHEN no_data_found THEN
        l_fatal_error_message := 'Data Incorrectly Terminated ';
        RAISE e_fatal_error;
    END;
  END LOOP;
  --commit to make sure everything has been committed
  COMMIT;
--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.extract_lines', 35);
--

--error handling
EXCEPTION
 WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,
               'hr_du_di_insert.extract_lines',l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
               'hr_du_di_insert.extract_lines','(none)', 'R');
    RAISE;

END Extract_lines;




-- ------------------------- ORDERED_SEQUENCE ------------------------------
-- Description: This is the main procedure that controlls the follow of both
-- procedure and function calls to control the Input Porcess
--
--  Input Parameters
--      p_upload_id        - HR_DU_UPLOAD_ID to be used
--
-- ------------------------------------------------------------------------
PROCEDURE ORDERED_SEQUENCE(p_upload_id IN NUMBER)
IS

  l_filehandle    UTL_FILE.FILE_TYPE;
  l_data_line     VARCHAR2(2000);
  l_number        NUMBER;
  l_location      VARCHAR2(2000);
  l_file_name     VARCHAR2(2000);

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.ordered_sequence', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')',10);
--

  g_flat_file_delimiter	:= g_tab_delimiter;
  g_current_delimiter   := g_flat_file_delimiter;

  SET_DElIMITER_STRING;
  POPULATE_DYNAMIC_TABLE;

  fnd_profile.get('PER_DATA_EXCHANGE_DIR', l_location);
  l_file_name := Return_File_Name(p_upload_id);
  l_filehandle :=Open_file(l_location, l_file_name);
  Extract_headers(l_filehandle, p_upload_id);
  Extract_API_locations(l_filehandle, p_upload_id);

  --makes sure that there are not two API's with the same file
  Check_Unique_Files(p_upload_id);

  Handle_API_Files (l_location, p_upload_id);

--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.ordered_sequence', 15);
--

--error handling
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE,
                        'hr_du_di_insert.ordered_sequence','(none)', 'R');
    RAISE;

END ORDERED_SEQUENCE;

-- ------------------------- VALIDATE -----------------------------------
-- Description:
--
--  Input Parameters
--        p_upload_id   - The upload id to associate the procedure with
--                        correct table
--
-- ------------------------------------------------------------------------
PROCEDURE VALIDATE(p_upload_id IN NUMBER) IS

  l_temp  VARCHAR2(20);

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.validate', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')',
                        10);
--
  l_temp := null;
--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.validate', 15);
--

--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.validate',
                       '(none)', 'R');
    RAISE;
--
END VALIDATE;


-- ------------------------- ROLLBACK -----------------------------------
-- Description: This procedure is called when an error has occured so that
-- the database tables can be cleaned up to restart the input process again
--
--  Input Parameters
--        p_upload_id   - The upload id to associate the procedure with
--                        correct table
--
-- ------------------------------------------------------------------------
PROCEDURE ROLLBACK(p_upload_id IN NUMBER) IS

BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_di_insert.rollback', 5);
  hr_du_utility.message('PARA', '(p_upload_id - ' || p_upload_id || ')',
                         10);
--

  DELETE FROM HR_DU_DESCRIPTORS
  WHERE UPLOAD_ID = p_upload_id;
  COMMIT;

  DELETE FROM HR_DU_UPLOAD_LINES
  WHERE UPLOAD_HEADER_ID IN (SELECT upload_header_id
   			     FROM hr_du_upload_headers
			     WHERE upload_id = p_upload_id);
  COMMIT;

  DELETE FROM HR_DU_UPLOAD_HEADERS
  WHERE UPLOAD_ID = p_upload_id;
  COMMIT;

--
  hr_du_utility.message('ROUT','exit:hr_du_di_insert.rollback', 15);
--

--
EXCEPTION
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_di_insert.rollback',
                       '(none)', 'R');
    RAISE;
--
END ROLLBACK;


END HR_DU_DI_INSERT;

/
