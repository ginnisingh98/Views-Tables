--------------------------------------------------------
--  DDL for Package HR_GENERAL_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GENERAL_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: hrgenutw.pkh 115.13 2002/12/11 11:35:14 hjonnala ship $*/
-- ----------------------------------------------------------------------------
-- |--< comments >------------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- NOTE:
-- This package must not have any print calls (to htp.p or procedures that
-- contain it, or anything else, such as javascript alert);
-- errors (as exceptions) must be handled in the packages which called the
-- function (or the parent of that package if it is a child).
-- package prepared in part from: (comments and dates remain in the code for
-- cross-referencing)
--   hr_util_web 	Header: hrutlweb.pkb 110.16 97/12/05
--   per_cm_util_web	Header: pecmuweb.pkb 110.19 97/11/19
-- ----------------------------------------------------------------------------
-- |--< Types >---------------------------------------------------------------|
-- ----------------------------------------------------------------------------
TYPE g_varchar2_tab_type
IS TABLE OF
	VARCHAR2 (2000)
INDEX BY BINARY_INTEGER;
--
TYPE g_vc32k_tab_type
IS TABLE OF
	VARCHAR2 (32000)
INDEX BY BINARY_INTEGER;
--
TYPE g_number_tab_type
IS TABLE OF
	NUMBER
INDEX BY BINARY_INTEGER;
--
TYPE r_column_data_rec
IS RECORD
  ( f_precision	NUMBER
  , f_datatype	VARCHAR2 (200)
  );
--
TYPE g_lookup_values_rec_type
IS RECORD
  ( lookup_type		VARCHAR2 (100)
  , lookup_code		VARCHAR2 (200)
  , meaning		VARCHAR2 (2000)
  );
--
TYPE g_person_details_rec_type
IS RECORD
  ( last_name		per_all_people_f.last_name%TYPE
  , first_name		per_all_people_f.first_name%TYPE
  , full_name		per_all_people_f.full_name%TYPE
  , middle_names    per_all_people_f.middle_names%TYPE
  , previous_last_name per_all_people_f.previous_last_name%TYPE
  , suffix          per_all_people_f.suffix%TYPE
  , title           per_all_people_f.title%TYPE
  , business_group_id per_all_people_f.business_group_id%TYPE
  );
--
TYPE g_lookup_values_tab_type
IS TABLE OF
  g_lookup_values_rec_type
INDEX BY BINARY_INTEGER;
--
TYPE r_error_msg_txt_number_rec
IS RECORD
  ( error_text		VARCHAR2 (2000)
  , error_number	NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |--< GLOBALS >-------------------------------------------------------------|
-- ----------------------------------------------------------------------------
g_package 			VARCHAR2 (200) := 'HR_GENERAL_UTILITIES';
g_separator			VARCHAR2 (2) := '!#';
g_sysdate_char        		VARCHAR2(200) :=
				  to_char(trunc(sysdate), 'YYYY-MM-DD');
g_current_yr_char     		VARCHAR2(4)   := substr(g_sysdate_char, 1, 4);
g_sample_date_char    		VARCHAR2(200) := g_current_yr_char || '-12-31';
g_sample_date         		DATE :=
                                  to_date(g_sample_date_char, 'YYYY-MM-DD');
g_date_format			VARCHAR2 (200)
				  := hr_session_utilities.get_user_date_format;
g_attribute_application_id	NUMBER := 800;
d_varchar2_tab_type		g_varchar2_tab_type;
d_number_tab_type		g_number_tab_type;
--
-- ----------------------------------------------------------------------------
-- |--< reset_globals >-------------------------------------------------------|
-- |  This procedure will be called at the end of rendering the work space    |
-- |  frame so that the global variables will have the initialized values in  |
-- |  WebDB stateful connection.                                              |
-- ----------------------------------------------------------------------------
PROCEDURE reset_globals;
--
-- ----------------------------------------------------------------------------
-- |--< Get_Person_Record >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- get the person record at the given date. This method uses the secured view
-- per_people_f which requires us to do an insert and delete of sessionId in
-- FND_SESSIONS
--
-- Prerequisites:
-- person must exist
--
-- Post Success:
-- the person record is returned
--
-- Post Failure:
-- an error is raised
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_Person_Record
  ( p_person_id 	IN per_people_f.person_id%TYPE
  , p_effective_date 	IN DATE DEFAULT SYSDATE
  )
RETURN per_people_f%ROWTYPE;
-- ----------------------------------------------------------------------------
-- |--< Get_Person_Details >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- get the person details record at the given date. we go to the base table
-- per_all_people_f to get the information. This method is faster than using
-- Get_person_record which uses the secured view per_people_f which also has
-- an overhead of inserting and deleting row from FND_SESSIONS
--
-- Prerequisites:
-- person must exist
--
-- Post Success:
-- the person details record is returned
--
-- Post Failure:
-- an error is raised
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_Person_Details
  ( p_person_id 	IN per_all_people_f.person_id%TYPE
  , p_effective_date 	IN DATE DEFAULT SYSDATE
  )
RETURN g_person_details_rec_type;

-- ----------------------------------------------------------------------------
-- |--< Get_Business_Group >--------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- returns the business group of the currently logged in user (the session
-- business group)
--
-- Prerequisites:
-- person must exist and be logged in
--
-- Post Success:
-- the business group id is returned
--
-- Post Failure:
-- an error is raised
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_Business_Group
RETURN per_people_f.business_group_id%TYPE;
-- ----------------------------------------------------------------------------
-- |--< Use_Message >---------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- sets a message on the stack and retrieves it.  requires the FND message_name
--
-- Prerequisites:
--
--
-- Post Success:
-- the text of the message is returned
--
-- Post Failure:
-- the message name is returned
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Use_Message
  ( p_message_name 	IN VARCHAR2
  , p_application_id 	IN VARCHAR2 DEFAULT 'PER'
  )
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< IFNOTNULL >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- if str1 is null returns str2, else str1 (from htf)
--
-- Prerequisites:
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION IFNOTNULL
  ( str1	IN VARCHAR2
  , str2	IN VARCHAR2)
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< Substitute_Value >----------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- substitutes a value if the new value is not null compared to a not null
-- original value
--
-- Prerequisites:
-- none
--
-- Post Success:
-- the new value is substituted for the old value if the new value was not
-- null
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE Substitute_Value
  ( p_new 	IN VARCHAR2 DEFAULT NULL
  , p_current 	IN OUT NOCOPY VARCHAR2
  , p_force 	IN BOOLEAN DEFAULT FALSE
  );
-- |--< overloaded >----------------------------------------------------------|
PROCEDURE Substitute_Value
  ( p_new 	IN NUMBER DEFAULT NULL
  , p_current 	IN OUT NOCOPY NUMBER
  , p_force IN BOOLEAN DEFAULT FALSE
  );
-- |--< overloaded >----------------------------------------------------------|
FUNCTION Substitute_Value
  ( p_new 	IN VARCHAR2 DEFAULT NULL
  , p_current 	IN VARCHAR2 DEFAULT NULL
  , p_force 	IN BOOLEAN DEFAULT FALSE
  )
RETURN VARCHAR2;
-- |--< overloaded >----------------------------------------------------------|
FUNCTION Substitute_Value
  ( p_new 	IN BOOLEAN DEFAULT NULL
  , p_current 	IN BOOLEAN DEFAULT NULL
  , p_force 	IN BOOLEAN DEFAULT FALSE
  )
RETURN BOOLEAN;
-- ----------------------------------------------------------------------------
-- |--< date2char >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- converts a date to character representation, using the default date format
-- if none specified
--
-- Prerequisites:
-- none
--
-- Post Success:
-- the date is formatted
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION date2char
  ( p_date		IN DATE
  , p_date_format	IN VARCHAR2 DEFAULT g_date_format
  )
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< char2date >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- converts text date in the given date format to date datatype
--
-- Prerequisites:
-- none
--
-- Post Success:
-- the text is converted to date datatype
--
-- Post Failure:
-- an error is raised
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION char2date
  ( p_char_date		IN VARCHAR2
  , p_date_format	IN VARCHAR2
  )
RETURN date;
-- ----------------------------------------------------------------------------
-- |--< IsDateValid >---------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- tests whether a character format of a date can be converted to date
-- datatype (using the default date format)
--
-- Prerequisites:
-- none
--
-- Post Success:
-- returns true
--
-- Post Failure:
-- returns false
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION IsDateValid
  ( p_string IN VARCHAR2
  )
RETURN BOOLEAN;
-- ----------------------------------------------------------------------------
-- |--< Validate_Between_Dates >----------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- determines whether date 1 is lower than date 2
--
-- Prerequisites:
-- none
--
-- Post Success:
-- returns true if date 1 < date 2
--
-- Post Failure:
-- returns false
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Validate_Between_Dates
  ( p_date1	IN DATE
  , p_date2 	IN DATE
  )
RETURN BOOLEAN;
-- ----------------------------------------------------------------------------
-- |--< Force_Date_Format >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- forces a valid date as text string (checks if valid date) to the current
-- g_date_format (as text_string)
--
-- Prerequisites:
-- none
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Force_Date_Format
  ( p_char_date 	IN VARCHAR2
  )
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< Get_Column_Length >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- returns the column length available for the given column / table
--
-- Prerequisites:
-- table / column must exist
--
-- Post Success:
-- a value is returned
--
-- Post Failure:
-- an error is raised
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_Column_Data
  ( p_table_name 	VARCHAR2
  , p_column_name 	VARCHAR2
  )
RETURN r_column_data_rec;
-- ----------------------------------------------------------------------------
-- |--< Get_lookup_Meaning >--------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- returns a lookup meaning for the given type / code
--
-- Prerequisites:
--
--
-- Post Success:
-- a value is returned
--
-- Post Failure:
-- no value is returned
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_lookup_Meaning
  ( p_lookup_type	IN VARCHAR2
  , p_lookup_code	IN VARCHAR2
  , p_schema		IN VARCHAR2 DEFAULT 'HR'
  )
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< Get_lookup_values >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- returns the lookup codes for the given lookup type
--
-- Prerequisites:
--
--
-- Post Success:
-- values are returned
--
-- Post Failure:
-- no value are returned
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_lookup_values
  ( p_lookup_type 	IN VARCHAR2
  , p_schema		IN VARCHAR2 DEFAULT 'HR'
  )
RETURN g_lookup_values_tab_type;
-- ----------------------------------------------------------------------------
-- |--< DoLookupsExist >------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- tests whether a lookup type exists
--
-- Prerequisites:
--
--
-- Post Success:
-- returns true
--
-- Post Failure:
-- returns false
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION DoLookupsExist
  ( p_lookup_type 	IN VARCHAR2
  , p_schema		IN VARCHAR2 DEFAULT 'HR'
  )
RETURN BOOLEAN;
-- ----------------------------------------------------------------------------
-- |--< ScriptOpen >----------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- writes out the html tag <SCRIPT>
--
-- Prerequisites:
--
--
-- Post Success:
-- tag is printed
--
-- Post Failure:
--
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE ScriptOpen
  ( p_js_library	IN VARCHAR2 DEFAULT NULL
  );
-- ----------------------------------------------------------------------------
-- |--< ScriptOpen >----------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- writes out the html tag </SCRIPT>
--
-- Prerequisites:
--
--
-- Post Success:
-- tag is printed
--
-- Post Failure:
--
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE ScriptClose;
-- ----------------------------------------------------------------------------
-- |--< Add_Separators >------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- adds separators to a string to create e.g. !#12345!#.  Note an error is not
-- raised if the string is the empty string.  However, this may raise an error
-- later if trying extract an item from a separated string that has successive
-- separators (e.g. !#!#)
--
-- Prerequisites:
-- separator must be defined
--
-- Post Success:
-- separator is appended to the start (p_start is true) or to the end of
-- the string
--
-- Post Failure:
--
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Add_Separators
  ( p_instring IN VARCHAR2
  , p_start IN BOOLEAN DEFAULT FALSE
  , p_separator IN VARCHAR2 DEFAULT hr_general_utilities.g_separator
  )
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< Locate_Item_In_Separated_Str >----------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- returns the character position of an item in a separated string
--
-- Prerequisites:
--
--
-- Post Success:
-- the character position is returned
--
-- Post Failure:
--
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Locate_Item_In_Separated_Str
  ( p_string	IN VARCHAR2
  , p_item	IN NUMBER
  , p_separator	IN VARCHAR2  	DEFAULT hr_general_utilities.g_separator
  )
RETURN NUMBER;
-- ----------------------------------------------------------------------------
-- |--< Find_Item_In_String >-------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- returns the contents of an item in a separated string e.g. !#12345!#
-- returns 12345
--
-- Prerequisites:
--
--
-- Post Success:
-- the string is returned
--
-- Post Failure:
-- returns null
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Find_Item_In_String
  ( p_item 	IN NUMBER
  , p_string 	IN VARCHAR2
  , p_separator	IN VARCHAR2 	DEFAULT hr_general_utilities.g_separator
  )
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< Trim_Separator >------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- trims a separator from a given string
--
-- Prerequisites:
--
--
-- Post Success:
-- the string is returned without the separator
--
-- Post Failure:
-- returns null
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Trim_Separator
  ( p_string	IN VARCHAR2
  , p_end	IN VARCHAR2 	DEFAULT 'RIGHT'
  , p_separator	IN VARCHAR2 	DEFAULT hr_general_utilities.g_separator
  )
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< BPFD >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- (build parameters from decryption) takes a separated string and extracts
-- the items to create a dynamic sql executable string
--
-- Prerequisites:
--
--
-- Post Success:
-- the string is converted to a string which can be executed in dynamic sql
--
-- Post Failure:
-- returns null
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION BPFD
  ( p_string IN VARCHAR2
  )
RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |--< BPFD >-----------------------------------------------------------------|
-- | This function is overloaded.  We keep the same name as BPFD because we    |
-- | want to make it easier to associate the code to the original BPFD.        |
-- | However, this function will replace all hard-coded literals in the parm   |
-- | values with bind variables for scalability.  The bind values are stored in|
-- | in the output parameter p_bind_values_tab of this overloaded function.    |
-- | So, the procedure invocation will look like this:                         |
-- |   per_appraisal_display_web.aprp01(parm1=> :1, parm2 => :2, ....);        |
-- ----------------------------------------------------------------------------
FUNCTION BPFD
  ( p_string              IN VARCHAR2
   ,p_bind_values_tab     out nocopy hr_general_utilities.g_vc32k_tab_type
   ,p_use_bind_values     out nocopy boolean
  )
RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |--< Get_Date_Hint >-------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- returns the date hint (e.g. 31-DEC-1998) in user_date format
--
-- Prerequisites:
--
--
-- Post Success:
-- the date is returned in the correct format
--
-- Post Failure:
--
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_Date_Hint
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< ASEI >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- (add to sql execution index) adds an index to the stack of dynamic sql
-- indices (encrypted handles) which need to be executed. i.e. is a container
-- array of pointers to encrypted sql strings
--
-- Prerequisites:
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE ASEI
  ( p_text_id 	IN VARCHAR2
  );
-- ----------------------------------------------------------------------------
-- |--< CCEI >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- (combine execution indices (encrypted handles)) combines the encryption
-- handles of all execution statements on the stack into one index.  This takes
-- all of the indices created by ASEI and combines them into one encryption id;
-- subsequent decoding of this id will eventually lead to the execution of all
-- the combined sql statements
--
-- Prerequisites:
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION CCEI
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< EPFS >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- (encrypt parameters for storage [originally]) : encrypts a string, using
-- multiple encryption handles if the text length is > than 2000 (max length in
-- icx_text); encoding types are :
-- S - eventually will be executed (when decrypted)
-- G - eventually will be placed in the global cache (when decrypted)
--
-- Prerequisites:
--
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION EPFS
  ( p_string	IN VARCHAR2
  , p_type	IN VARCHAR2 DEFAULT 'S'
  )
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< DExL >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- (decrypt and execute link [originally]) decrypts an encryption handle and
-- determines what to do with the returned string
-- C - indicates that there is a combination of events (created with CCEI) and
-- DEXL must deal with these one at a time.
-- for each string in a string (including C string from CCEI) the types are :
-- S - the string is passed to dynamic sql and executed
-- G - the string is placed on the stack
--
-- Prerequisites:
-- the encryption link must be in a recognizable form
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE DExL
 ( i	IN VARCHAR2
 );
-- ----------------------------------------------------------------------------
-- |--< SDER >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- (standard decrypt execute route) returns the value
-- 'hr_general_utilities.dexl?i='
--
-- Prerequisites:
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION SDER
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< EXPD >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- (expand parameters from decrypt [originally]) rebuilds strings which needed
-- to be broken dowm into strings of 2000 in length.  dexl (see above) may
-- encounter the S command followed by the number 3 followed by three numbers;
-- dexl knows that the eventual string needs to be executed dynamically (S),
-- and that the string needs to be rebuilt from 3 encrypted strings.  EXPD
-- decrypts and concatenates the three numbers (text ids in icx_text) to
-- generate the complete string to pass to the dexl execution routine
--
-- Prerequisites:
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION EXPD
  ( p_id	IN VARCHAR2 DEFAULT NULL
  , p_string	IN VARCHAR2 DEFAULT NULL
  )
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< REGS >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- (retrieve from global stack) retrieves the p_item item from the global stack
-- items are placed onto a global stack in the order received via one or more
-- dexl executions (i.e. when dexl encounters G).  REGS just retrieves the
-- string from the cache.  The stack is NOT cleared.  It is the
-- responsibility of the coder to know the order the strings were placed onto
-- the cache.  It is advised to clear the stack (e.g. this may not be the first
-- call to dexl [which adds to the stack], so the current indexing sequence
-- may not be as expected)
--
-- Prerequisites:
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION REGS
  ( p_index	IN NUMBER
  )
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< Reset_G_Cache >-------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- clears the global stack
--
-- Prerequisites:
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE Reset_G_Cache;
-- ----------------------------------------------------------------------------
-- |--< Locate_Text >---------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- locates the starting position of the text according to the criteria
-- requested
--
-- Prerequisites:
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Locate_Text
  ( p_search_in		IN VARCHAR2
  , p_search_for	IN VARCHAR2
  , p_search_after	IN NUMBER DEFAULT 1
  , p_second_instance	IN BOOLEAN DEFAULT FALSE
  , p_end_position	IN BOOLEAN DEFAULT FALSE
  , p_ignore_case	IN BOOLEAN DEFAULT TRUE
  , p_reverse		IN BOOLEAN DEFAULT FALSE
  )
RETURN NUMBER;
-- ----------------------------------------------------------------------------
-- |--< Count_Instances >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- counts the number of instances of a string within a string; note, in a
-- spearated string, the number of items the string contains is
-- count_instances - 1.
--
-- Prerequisites:
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Count_Instances
  ( p_search_in		IN VARCHAR2
  , p_search_for	IN VARCHAR2
  , p_ignore_case	IN BOOLEAN DEFAULT TRUE
  )
RETURN NUMBER;
-- ----------------------------------------------------------------------------
-- |--< Execute_Dynamic_SQL >-------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- parses and executes the string passed in
--
-- Prerequisites:
--
-- Post Success:
--
-- Post Failure:
-- raises an exception
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE Execute_Dynamic_SQL
  ( p_sql_string	IN VARCHAR2
  );
-- ----------------------------------------------------------------------------
-- |--< Set_Message_Txt_And_Number >------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- can be used either to set a known message on the stack and retrieve the
-- error message text and number into the record data structure
-- OR can be used to retrieve an existing message on the stack and set
-- the message text and number
--
-- Prerequisites:
--
-- Post Success:
--
-- Post Failure:
-- raises an exception
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Set_Message_Txt_And_Number
  ( p_application_id 	IN VARCHAR2 DEFAULT 'PER'
  , p_message_name 	IN VARCHAR2 DEFAULT NULL
  )
RETURN r_error_msg_txt_number_rec;
-- ----------------------------------------------------------------------------
-- |--< Set_Workflow_Section_Attribute >--------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- returns the set value for the web section (e.g. PERFORMANCE_DETAILS) e.g.
-- HIDE / VIEW
--
-- Prerequisites:
--
-- Post Success:
--
-- Post Failure:
-- raises an exception
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Set_Workflow_Section_Attribute
  ( p_item_type 		IN wf_items.item_type%TYPE DEFAULT NULL
  , p_item_key 			IN wf_items.item_key%TYPE DEFAULT NULL
  , p_actid			IN NUMBER DEFAULT NULL
  , p_web_page_section_code 	IN VARCHAR2
  )
RETURN VARCHAR2;

END HR_GENERAL_UTILITIES;

 

/
