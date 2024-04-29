--------------------------------------------------------
--  DDL for Package Body HR_GENERAL_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GENERAL_UTILITIES" AS
/* $Header: hrgenutw.pkb 115.34 2004/03/18 01:35:54 rmoolave ship $*/
-- ----------------------------------------------------------------------------
-- |--< VARIABLES >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
l_status    varchar2(50);
l_industry  varchar2(50);
l_per_owner     varchar2(30);
l_ret       boolean := FND_INSTALLATION.GET_APP_INFO ('PER', l_status,
                                                      l_industry, l_per_owner);
g_fatal_error			EXCEPTION;
PRAGMA EXCEPTION_INIT(g_fatal_error, -20001);
l_val_person_id		per_people_f.person_id%TYPE;
g_replace_string	VARCHAR2 (2) := '!#';
g_space                 varchar2(1) := ' ';
g_src_attribute		VARCHAR2 (200) := ' SRC="'
						|| g_replace_string || '"';
g_type_attribute	VARCHAR2 (200) := ' TYPE="'
						|| g_replace_string || '"';
g_language_attribute	VARCHAR2 (200) := ' LANGUAGE="'
						|| g_replace_string || '"';
g_execute_handles	g_varchar2_tab_type;
g_debug boolean := hr_utility.debug_enabled;
g_string_cache		g_vc32k_tab_type;
c_error_msg varchar2 (2000);
c_login_msg varchar2 (2000);
--
-------------------------------------------------------------------------------
-- 04/08/2001 Bug 1713366 Fix:
-- The following global constant is for testing the old BPFD and the new BPFD (
-- which has an output parameter).  This constant will indicate that beyond
-- certain number of parameters, the old BPFD which will create dynamic SQL with
-- literal will be used. For example, set g_num_dynamic_sql_parms to -1 will
-- force to use Execute_Dynamic_SQL procedure which uses dbms_sql package.
-------------------------------------------------------------------------------
g_num_dynamic_sql_parms  constant number := 15;
--
-- ----------------------------------------------------------------------------
-- |--< reset_globals >-------------------------------------------------------|
-- |  This procedure will be called at the end of rendering the work space    |
-- |  frame so that the global variables will have the initialized values in  |
-- |  WebDB stateful connection.                                              |
-- ----------------------------------------------------------------------------
PROCEDURE reset_globals
IS
  l_reset g_vc32k_tab_type;

BEGIN
  l_val_person_id := null;
  g_replace_string := '!#';
  g_space := ' ';
  g_src_attribute := ' SRC="' || g_replace_string || '"';
  g_type_attribute := ' TYPE="' || g_replace_string || '"';
  g_language_attribute := ' LANGUAGE="' || g_replace_string || '"';
  g_execute_handles.delete;
  g_string_cache.delete;
  hr_general_utilities.g_separator := '!#';
  hr_general_utilities.g_sysdate_char := to_char(trunc(sysdate), 'YYYY-MM-DD');
  hr_general_utilities.g_current_yr_char :=
      substr(hr_general_utilities.g_sysdate_char, 1, 4);
  hr_general_utilities.g_sample_date_char :=
      hr_general_utilities.g_current_yr_char || '-12-31';
  hr_general_utilities.g_sample_date :=
      to_date(hr_general_utilities.g_sample_date_char, 'YYYY-MM-DD');
  hr_general_utilities.g_date_format :=
      hr_session_utilities.get_user_date_format;
  hr_general_utilities.g_attribute_application_id := 800;

--
END reset_globals;
--
--
-- ----------------------------------------------------------------------------
-- |--< Get_Person_Record >---------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Person_Record
  ( p_person_id 	IN per_people_f.person_id%TYPE
  , p_effective_date 	IN DATE DEFAULT SYSDATE
  )
RETURN per_people_f%ROWTYPE
IS
  l_person_rec	per_people_f%ROWTYPE;
  l_proc	VARCHAR2 (72);

  l_all_person_rec	per_all_people_f%ROWTYPE;
--
  CURSOR csr_people_rec (p_person_id per_people_f.person_id%TYPE)
  IS
    SELECT *
    FROM per_all_people_f	-- Fix 2082000
    WHERE person_id = p_person_id
    AND trunc(p_effective_date)
    BETWEEN trunc(effective_start_date) AND trunc(effective_end_date);
BEGIN

g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Get_Person_Record';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


  OPEN csr_people_rec (p_person_id);
  FETCH csr_people_rec INTO l_all_person_rec;
    IF csr_people_rec%FOUND THEN
      CLOSE csr_people_rec;


IF g_debug THEN
      hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;


-- Fix 2082000 start

      l_person_rec.PERSON_ID                      := l_all_person_rec.PERSON_ID                     	;
      l_person_rec.EFFECTIVE_START_DATE           := l_all_person_rec.EFFECTIVE_START_DATE          	;
      l_person_rec.EFFECTIVE_END_DATE             := l_all_person_rec.EFFECTIVE_END_DATE            	;
      l_person_rec.BUSINESS_GROUP_ID              := l_all_person_rec.BUSINESS_GROUP_ID             	;
      l_person_rec.PERSON_TYPE_ID                 := l_all_person_rec.PERSON_TYPE_ID                	;
      l_person_rec.LAST_NAME                      := l_all_person_rec.LAST_NAME                     	;
      l_person_rec.START_DATE                     := l_all_person_rec.START_DATE                    	;
      l_person_rec.APPLICANT_NUMBER               := l_all_person_rec.APPLICANT_NUMBER              	;
      l_person_rec.COMMENT_ID                     := l_all_person_rec.COMMENT_ID                    	;
      l_person_rec.CURRENT_APPLICANT_FLAG         := l_all_person_rec.CURRENT_APPLICANT_FLAG        	;
      l_person_rec.CURRENT_EMP_OR_APL_FLAG        := l_all_person_rec.CURRENT_EMP_OR_APL_FLAG       	;
      l_person_rec.CURRENT_EMPLOYEE_FLAG          := l_all_person_rec.CURRENT_EMPLOYEE_FLAG         	;
      l_person_rec.DATE_EMPLOYEE_DATA_VERIFIED    := l_all_person_rec.DATE_EMPLOYEE_DATA_VERIFIED   	;
      l_person_rec.DATE_OF_BIRTH                  := l_all_person_rec.DATE_OF_BIRTH                 	;
      l_person_rec.EMAIL_ADDRESS                  := l_all_person_rec.EMAIL_ADDRESS                 	;
      l_person_rec.EMPLOYEE_NUMBER                := l_all_person_rec.EMPLOYEE_NUMBER               	;
      l_person_rec.EXPENSE_CHECK_SEND_TO_ADDRESS  := l_all_person_rec.EXPENSE_CHECK_SEND_TO_ADDRESS 	;
      l_person_rec.FAST_PATH_EMPLOYEE             := l_all_person_rec.FAST_PATH_EMPLOYEE            	;
      l_person_rec.FIRST_NAME                     := l_all_person_rec.FIRST_NAME                    	;
      l_person_rec.FULL_NAME                      := l_all_person_rec.FULL_NAME                     	;
      l_person_rec.ORDER_NAME                     := l_all_person_rec.ORDER_NAME                    	;
      l_person_rec.KNOWN_AS                       := l_all_person_rec.KNOWN_AS                      	;
      l_person_rec.MARITAL_STATUS                 := l_all_person_rec.MARITAL_STATUS                	;
      l_person_rec.MIDDLE_NAMES                   := l_all_person_rec.MIDDLE_NAMES                  	;
      l_person_rec.NATIONALITY                    := l_all_person_rec.NATIONALITY                   	;
      l_person_rec.NATIONAL_IDENTIFIER            := l_all_person_rec.NATIONAL_IDENTIFIER           	;
      l_person_rec.PREVIOUS_LAST_NAME             := l_all_person_rec.PREVIOUS_LAST_NAME            	;
      l_person_rec.REGISTERED_DISABLED_FLAG       := l_all_person_rec.REGISTERED_DISABLED_FLAG      	;
      l_person_rec.SEX                            := l_all_person_rec.SEX                           	;
      l_person_rec.TITLE                          := l_all_person_rec.TITLE                         	;
      l_person_rec.VENDOR_ID                      := l_all_person_rec.VENDOR_ID                     	;
      l_person_rec.WORK_TELEPHONE                 := l_all_person_rec.WORK_TELEPHONE                	;
      l_person_rec.REQUEST_ID                     := l_all_person_rec.REQUEST_ID                    	;
      l_person_rec.PROGRAM_APPLICATION_ID         := l_all_person_rec.PROGRAM_APPLICATION_ID        	;
      l_person_rec.PROGRAM_ID                     := l_all_person_rec.PROGRAM_ID                    	;
      l_person_rec.PROGRAM_UPDATE_DATE            := l_all_person_rec.PROGRAM_UPDATE_DATE           	;
      l_person_rec.ATTRIBUTE_CATEGORY             := l_all_person_rec.ATTRIBUTE_CATEGORY            	;
      l_person_rec.ATTRIBUTE1                     := l_all_person_rec.ATTRIBUTE1                    	;
      l_person_rec.ATTRIBUTE2                     := l_all_person_rec.ATTRIBUTE2                    	;
      l_person_rec.ATTRIBUTE3                     := l_all_person_rec.ATTRIBUTE3                    	;
      l_person_rec.ATTRIBUTE4                     := l_all_person_rec.ATTRIBUTE4                    	;
      l_person_rec.ATTRIBUTE5                     := l_all_person_rec.ATTRIBUTE5                    	;
      l_person_rec.ATTRIBUTE6                     := l_all_person_rec.ATTRIBUTE6                    	;
      l_person_rec.ATTRIBUTE7                     := l_all_person_rec.ATTRIBUTE7                    	;
      l_person_rec.ATTRIBUTE8                     := l_all_person_rec.ATTRIBUTE8                    	;
      l_person_rec.ATTRIBUTE9                     := l_all_person_rec.ATTRIBUTE9                    	;
      l_person_rec.ATTRIBUTE10                    := l_all_person_rec.ATTRIBUTE10                   	;
      l_person_rec.ATTRIBUTE11                    := l_all_person_rec.ATTRIBUTE11                   	;
      l_person_rec.ATTRIBUTE12                    := l_all_person_rec.ATTRIBUTE12                   	;
      l_person_rec.ATTRIBUTE13                    := l_all_person_rec.ATTRIBUTE13                   	;
      l_person_rec.ATTRIBUTE14                    := l_all_person_rec.ATTRIBUTE14                   	;
      l_person_rec.ATTRIBUTE15                    := l_all_person_rec.ATTRIBUTE15                   	;
      l_person_rec.ATTRIBUTE16                    := l_all_person_rec.ATTRIBUTE16                   	;
      l_person_rec.ATTRIBUTE17                    := l_all_person_rec.ATTRIBUTE17                   	;
      l_person_rec.ATTRIBUTE18                    := l_all_person_rec.ATTRIBUTE18                   	;
      l_person_rec.ATTRIBUTE19                    := l_all_person_rec.ATTRIBUTE19                   	;
      l_person_rec.ATTRIBUTE20                    := l_all_person_rec.ATTRIBUTE20                   	;
      l_person_rec.ATTRIBUTE21                    := l_all_person_rec.ATTRIBUTE21                   	;
      l_person_rec.ATTRIBUTE22                    := l_all_person_rec.ATTRIBUTE22                   	;
      l_person_rec.ATTRIBUTE23                    := l_all_person_rec.ATTRIBUTE23                   	;
      l_person_rec.ATTRIBUTE24                    := l_all_person_rec.ATTRIBUTE24                   	;
      l_person_rec.ATTRIBUTE25                    := l_all_person_rec.ATTRIBUTE25                   	;
      l_person_rec.ATTRIBUTE26                    := l_all_person_rec.ATTRIBUTE26                   	;
      l_person_rec.ATTRIBUTE27                    := l_all_person_rec.ATTRIBUTE27                   	;
      l_person_rec.ATTRIBUTE28                    := l_all_person_rec.ATTRIBUTE28                   	;
      l_person_rec.ATTRIBUTE29                    := l_all_person_rec.ATTRIBUTE29                   	;
      l_person_rec.ATTRIBUTE30                    := l_all_person_rec.ATTRIBUTE30                   	;
      l_person_rec.LAST_UPDATE_DATE               := l_all_person_rec.LAST_UPDATE_DATE              	;
      l_person_rec.LAST_UPDATED_BY                := l_all_person_rec.LAST_UPDATED_BY               	;
      l_person_rec.LAST_UPDATE_LOGIN              := l_all_person_rec.LAST_UPDATE_LOGIN             	;
      l_person_rec.CREATED_BY                     := l_all_person_rec.CREATED_BY                    	;
      l_person_rec.CREATION_DATE                  := l_all_person_rec.CREATION_DATE                 	;
      l_person_rec.PER_INFORMATION_CATEGORY       := l_all_person_rec.PER_INFORMATION_CATEGORY      	;
      l_person_rec.PER_INFORMATION1               := l_all_person_rec.PER_INFORMATION1              	;
      l_person_rec.PER_INFORMATION2               := l_all_person_rec.PER_INFORMATION2              	;
      l_person_rec.PER_INFORMATION3               := l_all_person_rec.PER_INFORMATION3              	;
      l_person_rec.PER_INFORMATION4               := l_all_person_rec.PER_INFORMATION4              	;
      l_person_rec.PER_INFORMATION5               := l_all_person_rec.PER_INFORMATION5              	;
      l_person_rec.PER_INFORMATION6               := l_all_person_rec.PER_INFORMATION6              	;
      l_person_rec.PER_INFORMATION7               := l_all_person_rec.PER_INFORMATION7              	;
      l_person_rec.PER_INFORMATION8               := l_all_person_rec.PER_INFORMATION8              	;
      l_person_rec.PER_INFORMATION9               := l_all_person_rec.PER_INFORMATION9              	;
      l_person_rec.PER_INFORMATION10              := l_all_person_rec.PER_INFORMATION10             	;
      l_person_rec.PER_INFORMATION11              := l_all_person_rec.PER_INFORMATION11             	;
      l_person_rec.PER_INFORMATION12              := l_all_person_rec.PER_INFORMATION12             	;
      l_person_rec.PER_INFORMATION13              := l_all_person_rec.PER_INFORMATION13             	;
      l_person_rec.PER_INFORMATION14              := l_all_person_rec.PER_INFORMATION14             	;
      l_person_rec.PER_INFORMATION15              := l_all_person_rec.PER_INFORMATION15             	;
      l_person_rec.PER_INFORMATION16              := l_all_person_rec.PER_INFORMATION16             	;
      l_person_rec.PER_INFORMATION17              := l_all_person_rec.PER_INFORMATION17             	;
      l_person_rec.PER_INFORMATION18              := l_all_person_rec.PER_INFORMATION18             	;
      l_person_rec.PER_INFORMATION19              := l_all_person_rec.PER_INFORMATION19             	;
      l_person_rec.PER_INFORMATION20              := l_all_person_rec.PER_INFORMATION20             	;
      l_person_rec.PER_INFORMATION21              := l_all_person_rec.PER_INFORMATION21             	;
      l_person_rec.PER_INFORMATION22              := l_all_person_rec.PER_INFORMATION22             	;
      l_person_rec.PER_INFORMATION23              := l_all_person_rec.PER_INFORMATION23             	;
      l_person_rec.PER_INFORMATION24              := l_all_person_rec.PER_INFORMATION24             	;
      l_person_rec.PER_INFORMATION25              := l_all_person_rec.PER_INFORMATION25             	;
      l_person_rec.PER_INFORMATION26              := l_all_person_rec.PER_INFORMATION26             	;
      l_person_rec.PER_INFORMATION27              := l_all_person_rec.PER_INFORMATION27             	;
      l_person_rec.PER_INFORMATION28              := l_all_person_rec.PER_INFORMATION28             	;
      l_person_rec.PER_INFORMATION29              := l_all_person_rec.PER_INFORMATION29             	;
      l_person_rec.PER_INFORMATION30              := l_all_person_rec.PER_INFORMATION30             	;
      l_person_rec.OBJECT_VERSION_NUMBER          := l_all_person_rec.OBJECT_VERSION_NUMBER         	;
      l_person_rec.DATE_OF_DEATH                  := l_all_person_rec.DATE_OF_DEATH                 	;
      l_person_rec.SUFFIX                         := l_all_person_rec.SUFFIX                        	;
      l_person_rec.WORK_SCHEDULE                  := l_all_person_rec.WORK_SCHEDULE                 	;
      l_person_rec.CORRESPONDENCE_LANGUAGE        := l_all_person_rec.CORRESPONDENCE_LANGUAGE       	;
      l_person_rec.STUDENT_STATUS                 := l_all_person_rec.STUDENT_STATUS                	;
      l_person_rec.FTE_CAPACITY                   := l_all_person_rec.FTE_CAPACITY                  	;
      l_person_rec.ON_MILITARY_SERVICE            := l_all_person_rec.ON_MILITARY_SERVICE           	;
      l_person_rec.SECOND_PASSPORT_EXISTS         := l_all_person_rec.SECOND_PASSPORT_EXISTS        	;
      l_person_rec.BACKGROUND_CHECK_STATUS        := l_all_person_rec.BACKGROUND_CHECK_STATUS       	;
      l_person_rec.BACKGROUND_DATE_CHECK          := l_all_person_rec.BACKGROUND_DATE_CHECK         	;
      l_person_rec.BLOOD_TYPE                     := l_all_person_rec.BLOOD_TYPE                    	;
      l_person_rec.LAST_MEDICAL_TEST_DATE         := l_all_person_rec.LAST_MEDICAL_TEST_DATE        	;
      l_person_rec.LAST_MEDICAL_TEST_BY           := l_all_person_rec.LAST_MEDICAL_TEST_BY          	;
      l_person_rec.REHIRE_RECOMMENDATION          := l_all_person_rec.REHIRE_RECOMMENDATION         	;
      l_person_rec.REHIRE_AUTHORIZOR              := l_all_person_rec.REHIRE_AUTHORIZOR             	;
      l_person_rec.REHIRE_REASON                  := l_all_person_rec.REHIRE_REASON                 	;
      l_person_rec.RESUME_EXISTS                  := l_all_person_rec.RESUME_EXISTS                 	;
      l_person_rec.RESUME_LAST_UPDATED            := l_all_person_rec.RESUME_LAST_UPDATED           	;
      l_person_rec.OFFICE_NUMBER                  := l_all_person_rec.OFFICE_NUMBER                 	;
      l_person_rec.INTERNAL_LOCATION              := l_all_person_rec.INTERNAL_LOCATION             	;
      l_person_rec.MAILSTOP                       := l_all_person_rec.MAILSTOP                      	;
      l_person_rec.PROJECTED_START_DATE           := l_all_person_rec.PROJECTED_START_DATE          	;
      l_person_rec.HONORS                         := l_all_person_rec.HONORS                        	;
      l_person_rec.PRE_NAME_ADJUNCT               := l_all_person_rec.PRE_NAME_ADJUNCT              	;
      l_person_rec.HOLD_APPLICANT_DATE_UNTIL      := l_all_person_rec.HOLD_APPLICANT_DATE_UNTIL     	;
      l_person_rec.COORD_BEN_MED_PLN_NO           := l_all_person_rec.COORD_BEN_MED_PLN_NO          	;
      l_person_rec.COORD_BEN_NO_CVG_FLAG          := l_all_person_rec.COORD_BEN_NO_CVG_FLAG         	;
      l_person_rec.DPDNT_ADOPTION_DATE            := l_all_person_rec.DPDNT_ADOPTION_DATE           	;
      l_person_rec.DPDNT_VLNTRY_SVCE_FLAG         := l_all_person_rec.DPDNT_VLNTRY_SVCE_FLAG        	;
      l_person_rec.RECEIPT_OF_DEATH_CERT_DATE     := l_all_person_rec.RECEIPT_OF_DEATH_CERT_DATE    	;
      l_person_rec.USES_TOBACCO_FLAG              := l_all_person_rec.USES_TOBACCO_FLAG             	;
      l_person_rec.BENEFIT_GROUP_ID               := l_all_person_rec.BENEFIT_GROUP_ID              	;
      l_person_rec.ORIGINAL_DATE_OF_HIRE          := l_all_person_rec.ORIGINAL_DATE_OF_HIRE         	;
      l_person_rec.TOWN_OF_BIRTH                  := l_all_person_rec.TOWN_OF_BIRTH                 	;
      l_person_rec.REGION_OF_BIRTH                := l_all_person_rec.REGION_OF_BIRTH               	;
      l_person_rec.COUNTRY_OF_BIRTH               := l_all_person_rec.COUNTRY_OF_BIRTH              	;
      l_person_rec.GLOBAL_PERSON_ID               := l_all_person_rec.GLOBAL_PERSON_ID              	;
      l_person_rec.PARTY_ID                       := l_all_person_rec.PARTY_ID                      	;
      l_person_rec.COORD_BEN_MED_EXT_ER           := l_all_person_rec.COORD_BEN_MED_EXT_ER          	;
      l_person_rec.COORD_BEN_MED_PL_NAME          := l_all_person_rec.COORD_BEN_MED_PL_NAME         	;
      l_person_rec.COORD_BEN_MED_INSR_CRR_NAME    := l_all_person_rec.COORD_BEN_MED_INSR_CRR_NAME   	;
      l_person_rec.COORD_BEN_MED_INSR_CRR_IDENT   := l_all_person_rec.COORD_BEN_MED_INSR_CRR_IDENT  	;
      l_person_rec.COORD_BEN_MED_CVG_STRT_DT      := l_all_person_rec.COORD_BEN_MED_CVG_STRT_DT     	;
      l_person_rec.COORD_BEN_MED_CVG_END_DT       := l_all_person_rec.COORD_BEN_MED_CVG_END_DT      	;
      l_person_rec.NPW_NUMBER                     := l_all_person_rec.NPW_NUMBER                    	;
      l_person_rec.CURRENT_NPW_FLAG               := l_all_person_rec.CURRENT_NPW_FLAG              	;

      -- Fix 2082000 End.

      RETURN l_person_rec;
    ELSE
      CLOSE csr_people_rec;

      RAISE hr_session_utilities.g_fatal_error;
    END IF;
    --
EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_message
    ( hr_session_utilities.g_PER_application_id
    , 'HR_52214_CM_NO_PERSON_DATA'
    );
  RAISE ;
END Get_Person_Record;
-- ----------------------------------------------------------------------------
-- |--< Get_Person_Details >---------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Person_Details
  ( p_person_id 	IN per_all_people_f.person_id%TYPE
  , p_effective_date 	IN DATE DEFAULT SYSDATE
  )
RETURN g_person_details_rec_type
IS
  l_person_rec	g_person_details_rec_type;
  l_proc	VARCHAR2 (72);
--
  CURSOR csr_people_rec (p_person_id per_all_people_f.person_id%TYPE)
  IS
-- fix 2209594
    SELECT last_name
           ,first_name
           ,full_name
           ,middle_names
           ,previous_last_name
           ,suffix
           ,title
           ,business_group_id
    FROM per_all_people_f
    WHERE person_id = p_person_id
    AND trunc(p_effective_date)
    BETWEEN trunc(effective_start_date) AND trunc(effective_end_date);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Get_Person_Record';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


  OPEN csr_people_rec (p_person_id);
  FETCH csr_people_rec INTO l_person_rec;
    IF csr_people_rec%FOUND THEN
      CLOSE csr_people_rec;

IF g_debug THEN
      hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

      RETURN l_person_rec;
    ELSE
      CLOSE csr_people_rec;
      RAISE hr_session_utilities.g_fatal_error;
    END IF;
--
EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_message
    ( hr_session_utilities.g_PER_application_id
    , 'HR_52214_CM_NO_PERSON_DATA'
    );
  RAISE ;
END Get_Person_Details;
-- ----------------------------------------------------------------------------
-- |--< Get_Business_Group >--------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Business_Group
RETURN per_people_f.business_group_id%TYPE
IS
BEGIN
  RETURN hr_util_misc_web.get_business_group_id;
END Get_Business_Group;
-- ----------------------------------------------------------------------------
-- |--< Use_Message >---------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Use_Message
  ( p_message_name 	IN VARCHAR2
  ,  p_application_id 	IN VARCHAR2 DEFAULT 'PER'
  )
RETURN VARCHAR2
IS
--
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Use_Message';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  fnd_message.set_name (p_application_id, p_message_name);
  RETURN fnd_message.get;
--
-- just returns null if not found
--
END Use_Message;
-- ----------------------------------------------------------------------------
-- |--< IFNOTNULL >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- a private procedure in htf/htp
-- ----------------------------------------------------------------------------
FUNCTION IFNOTNULL
  ( str1	IN VARCHAR2
  , str2	IN VARCHAR2
  )
RETURN VARCHAR2
IS
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' IFNOTNULL';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  IF (str1 is NULL) THEN
    RETURN (NULL);
  ELSE
    RETURN (str2);
  END IF;
END IFNOTNULL;
-- ----------------------------------------------------------------------------
-- |--< Substitute_Value >----------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Substitute_Value
  ( p_new	IN VARCHAR2 DEFAULT NULL
  , p_current	IN VARCHAR2 DEFAULT NULL
  , p_force	IN BOOLEAN DEFAULT FALSE
  )
RETURN VARCHAR2
IS
  l_return_val	VARCHAR2 (32000);
--
BEGIN


  IF p_force THEN
    l_return_val := p_new;
  ELSE
    IF p_new IS NOT NULL THEN
      l_return_val := p_new;
    ELSE
      l_return_val :=  p_current;
    END IF;
  END IF;
--


  RETURN l_return_val;
END Substitute_Value;
-- ----------------------------------------------------------------------------
-- |--< Substitute_Value  >---------------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Substitute_Value
  ( p_new 	IN VARCHAR2 DEFAULT NULL
  , p_current	IN OUT NOCOPY VARCHAR2
  , p_force 	IN BOOLEAN DEFAULT FALSE
  )
IS
  l_current	VARCHAR2 (32000);
--
--
BEGIN


  l_current :=
    Substitute_Value
      ( p_new 		=> p_new
      , p_current 	=> p_current
      , p_force 	=> p_force
      );
  p_current := l_current;


END Substitute_Value;
-- ----------------------------------------------------------------------------
-- |--< Substitute_Value  >---------------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Substitute_Value
  (  p_new 	IN NUMBER DEFAULT NULL
  , p_current 	IN OUT NOCOPY NUMBER
  , p_force 	IN BOOLEAN DEFAULT FALSE
  )
IS
  l_current VARCHAR2 (2000) := to_char(p_current);
--
--
BEGIN

  Substitute_Value
    ( p_current	=> l_current
    , p_new 	=> to_char(p_new)
    , p_force 	=> p_force
    );
  p_current := to_number(l_current);

END Substitute_Value;
-- ----------------------------------------------------------------------------
-- |--< Substitute_Value  >---------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Substitute_Value
  ( p_new 	IN BOOLEAN DEFAULT NULL
  , p_current 	IN BOOLEAN DEFAULT NULL
  , p_force 	IN BOOLEAN DEFAULT FALSE
  )
RETURN BOOLEAN
IS
  l_return_val	BOOLEAN;
--

BEGIN


  IF p_force THEN
    l_return_val := p_new;
  ELSE
    IF p_new IS NOT NULL THEN
      l_return_val := p_new;
    ELSE
      l_return_val :=  p_current;
    END IF;
  END IF;
--

  RETURN l_return_val;
END Substitute_Value;
-- ----------------------------------------------------------------------------
-- |--< date2char >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   date2char
--
-- description:
--   This function returns a varchar2 date in user preference date
--   format.
-- ----------------------------------------------------------------------------
FUNCTION date2char
  ( p_date		IN DATE
   ,p_date_format 	IN VARCHAR2 DEFAULT g_date_format
  )
RETURN VARCHAR2
IS
--
--
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' date2char';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN to_char(trunc(p_date), p_date_format);
--
-- will fail when trying to get g_date_format
-- no exception necessary
--
END date2char;
-- ----------------------------------------------------------------------------
-- |--< char2date >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   char2date
--
-- description:
--   This function converts a varchar2 date data to date data type using
--   passed in date format mask.
-- ----------------------------------------------------------------------------
FUNCTION char2date
  ( p_char_date		IN VARCHAR2
  , p_date_format 	IN VARCHAR2
  )
RETURN date
IS
--
--
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' char2date';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN
    TRUNC
      ( TO_DATE
          ( p_char_date, p_date_format
          )
      );
EXCEPTION
  WHEN OTHERS THEN
  RAISE;
END char2date;
-- ----------------------------------------------------------------------------
-- |--< IsDateValid >---------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- attempts to to_date a text string
-- returns tru if succeeds
--
FUNCTION IsDateValid
  ( p_string IN VARCHAR2
  )
RETURN BOOLEAN
IS
  l_date        DATE;
  l_boolean	boolean;
--
--
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' IsDateValid';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  l_date := to_date (p_string, g_date_format);

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
--
END IsDateValid;
-- ----------------------------------------------------------------------------
-- |--< Convert_To_Date >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
-- if converting to date fails (date is not valid), then value returned is null
-- logic in calling code can handle this better than raising an exception
-- e.g. hr_general_utilities.IFNOTNULL(hr_general_utlities.ConvertToDate(...)..
--
FUNCTION Convert_To_Date
  ( p_date_string IN VARCHAR2
  )
RETURN DATE
IS
--
--
  l_proc	VARCHAR2 (72);
BEGIN

IF g_debug THEN
  l_proc := g_package || ' Convert_To_Date';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  IF IsDateValid (p_date_string) THEN
    RETURN
      char2date
        ( p_char_date 	=> p_date_string
	, p_date_format	=> g_date_format
        );
  ELSE
    RETURN NULL;
  END IF;
--
EXCEPTION
  WHEN OTHERS THEN
  RAISE;
END Convert_To_Date;
-- ----------------------------------------------------------------------------
-- |--< Validate_Between_Dates >----------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Validate_Between_Dates
  ( p_date1 	IN DATE
  , p_date2 	IN DATE
  )
RETURN BOOLEAN
IS
--
--
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Validate_Between_Dates';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  IF p_date2 >= p_date1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  RAISE;
END Validate_Between_Dates;
-- ----------------------------------------------------------------------------
-- |--< Get_Column_Data >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Column_Data
  ( p_table_name 	VARCHAR2
  , p_column_name 	VARCHAR2
  )
RETURN r_column_data_rec
IS
--
  TYPE col_data
  IS RECORD
    ( c_length		NUMBER
    , c_precision	NUMBER
    , c_datatype	VARCHAR2 (2000)
    );
  l_hold_data	col_data;
  l_data	r_column_data_rec;
--
  l_proc	VARCHAR2 (72) := g_package || ' Get_Column_Data';
--
  CURSOR csr_col_data
    ( p_table_name VARCHAR2
    , p_column_name VARCHAR2
    )
  IS
    SELECT data_length, data_precision, data_type
    FROM all_tab_columns
    WHERE table_name = p_table_name
    AND column_name = p_column_name
    AND owner = l_per_owner;
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


  OPEN csr_col_data
    ( p_table_name => UPPER(p_table_name)
    , p_column_name => UPPER(p_column_name)
    );
  FETCH csr_col_data INTO l_hold_data;
  CLOSE csr_col_data;
--
  IF INSTR(l_hold_data.c_datatype, 'CHAR') > 0 THEN
    l_data.f_precision := l_hold_data.c_length;
  ELSE
     l_data.f_precision := l_hold_data.c_precision;
  END IF;
--
  l_data.f_datatype := l_hold_data.c_datatype ;
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;


  RETURN l_data;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_coding_error;
END Get_Column_Data;
-- ----------------------------------------------------------------------------
-- |--< Get_lookup_Meaning >--------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_lookup_Meaning
  ( p_lookup_type	IN VARCHAR2
  , p_lookup_code	IN VARCHAR2
  , p_schema		IN VARCHAR2 DEFAULT 'HR'
  )
RETURN VARCHAR2
IS
  l_record	g_lookup_values_rec_type;
  l_meaning	VARCHAR2 (2000);
  l_proc	VARCHAR2 (72);
--
  CURSOR csr_hr_lookup
    ( p_lookup_type 	VARCHAR2
    , p_lookup_code	VARCHAR2
    )
  IS
    SELECT lookup_type, lookup_code, meaning
    FROM hr_lookups
    WHERE lookup_type = p_lookup_type
    AND lookup_code = p_lookup_code
    AND enabled_flag = 'Y'
    AND sysdate between NVL(start_date_active, hr_api.g_sot)
      AND NVL(end_date_active, hr_api.g_eot);
--
  CURSOR csr_fnd_lookup
    ( p_lookup_type 	VARCHAR2
    , p_lookup_code	VARCHAR2
    )
  IS
    SELECT lookup_type, lookup_code, meaning
    FROM fnd_lookups
    WHERE lookup_type = p_lookup_type
    AND lookup_code = p_lookup_code
    AND enabled_flag = 'Y'
    AND sysdate between NVL(start_date_active, hr_api.g_sot)
      AND NVL(end_date_active, hr_api.g_eot);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Get_lookup_Meaning';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  IF p_schema = 'HR' THEN
  OPEN csr_hr_lookup
    ( p_lookup_type => p_lookup_type
    , p_lookup_code => p_lookup_code
    );
  FETCH csr_hr_lookup INTO l_record;
  IF csr_hr_lookup%FOUND THEN
    l_meaning := l_record.meaning;
  ELSE
    NULL;
  END IF;
--
  CLOSE csr_hr_lookup;
  ELSIF p_schema = 'FND' THEN
  OPEN csr_fnd_lookup
    ( p_lookup_type => p_lookup_type
    , p_lookup_code => p_lookup_code
    );
  FETCH csr_fnd_lookup INTO l_record;
  IF csr_fnd_lookup%FOUND THEN
    l_meaning := l_record.meaning;
  ELSE
    NULL;
  END IF;
--
  CLOSE csr_fnd_lookup;
  ELSE
    NULL;
  END IF;
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN l_meaning;
END Get_lookup_Meaning;
-- ----------------------------------------------------------------------------
-- |--< Get_lookup_values >---------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_lookup_values
  ( p_lookup_type 	IN VARCHAR2
  , p_schema		IN VARCHAR2 DEFAULT 'HR'
  )
RETURN g_lookup_values_tab_type
IS
  l_array	g_lookup_values_tab_type;
--
  l_proc	VARCHAR2 (72) := g_package || ' Get_lookup_values';
--
  CURSOR csr_hr_lookup
    ( p_lookup_type 	VARCHAR2
    )
  IS
    SELECT lookup_type, lookup_code, meaning
    FROM hr_lookups
    WHERE lookup_type = p_lookup_type
    AND enabled_flag = 'Y'
    AND sysdate between NVL(start_date_active, hr_api.g_sot)
    AND NVL(end_date_active, hr_api.g_eot)
    ORDER by meaning;

--
  CURSOR csr_fnd_lookup
    ( p_lookup_type 	VARCHAR2
    )
  IS
    SELECT lookup_type, lookup_code, meaning
    FROM fnd_lookups
    WHERE lookup_type = p_lookup_type
    AND enabled_flag = 'Y'
    AND sysdate between NVL(start_date_active, hr_api.g_sot)
    AND NVL(end_date_active, hr_api.g_eot)
    ORDER by meaning;

BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  l_proc := g_package || ' Get_lookup_values';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  IF p_schema = 'HR' THEN
    FOR CursorRecord
    IN csr_hr_lookup
         ( p_lookup_type => p_lookup_type
         )
    LOOP
      l_array(csr_hr_lookup%ROWCOUNT).lookup_type
        := CursorRecord.lookup_type;
      l_array(csr_hr_lookup%ROWCOUNT).lookup_code
        := CursorRecord.lookup_code;
      l_array(csr_hr_lookup%ROWCOUNT).meaning
        := CursorRecord.meaning;
    END LOOP;
  ELSIF p_schema = 'FND' THEN
    FOR CursorRecord
    IN csr_fnd_lookup
         ( p_lookup_type => p_lookup_type
         )
    LOOP
      l_array(csr_hr_lookup%ROWCOUNT).lookup_type
        := CursorRecord.lookup_type;
      l_array(csr_hr_lookup%ROWCOUNT).lookup_code
        := CursorRecord.lookup_code;
      l_array(csr_hr_lookup%ROWCOUNT).meaning
        := CursorRecord.meaning;
    END LOOP;
  ELSE
    NULL;
  END IF;
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN l_array;
END Get_lookup_values;
-- ----------------------------------------------------------------------------
-- |--< DoLookupsExist >------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION DoLookupsExist
  ( p_lookup_type 	IN VARCHAR2
  , p_schema		IN VARCHAR2 DEFAULT 'HR'
  )
RETURN BOOLEAN
IS
  l_array	g_lookup_values_tab_type;
--
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' DoLookupsExist';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  l_array :=
    Get_Lookup_Values
      ( p_lookup_type 	=> p_lookup_type
      , p_schema	=> p_schema
      );
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN l_array.count > 0;
--
--exception not necessary
--
END DoLookupsExist;
-- ----------------------------------------------------------------------------
-- |--< Force_Date_Format >---------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Force_Date_Format
  ( p_char_date 	IN VARCHAR2
  )
RETURN VARCHAR2
IS
--
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Force_Date_Format';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  IF IsDateValid
       ( p_string => p_char_date
       )
  THEN
    RETURN
      date2char
        ( p_date =>
            char2date
              ( p_char_date 	=> p_char_date
              , p_date_format 	=> g_date_format
              )
        , p_date_format => g_date_format
        );
  ELSE
    RETURN p_char_date; --NULL;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Force_Date_Format;
-- ----------------------------------------------------------------------------
-- |--< ScriptOpen >----------------------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ScriptOpen
  ( p_js_library	IN VARCHAR2 DEFAULT NULL
  )
IS
  l_attributes	VARCHAR2 (2000);
  l_lang_type	VARCHAR2 (20) := 'javascript';
--
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' ScriptOpen';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  IF p_js_library IS NOT NULL THEN
    l_attributes :=
      l_attributes
      || REPLACE
           ( g_src_attribute
           , g_replace_string
           , p_js_library
           );
  ELSE
    NULL;
  END IF;
--
    htp.p ('<SCRIPT ' || l_attributes || '>');
    htp.p ('<!--  start hiding');
--
--exception not necessary
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

END ScriptOpen;
-- ----------------------------------------------------------------------------
-- |--< ScriptClose >---------------------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ScriptClose
IS
--
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' ScriptClose';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  htp.p ('<!--  end hiding -->');
  htp.p ('</SCRIPT>');
--
--exception not necessary
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

END ScriptClose;
-- ----------------------------------------------------------------------------
-- |--< Add_Separators >------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Add_Separators
  ( p_instring 	IN VARCHAR2
  , p_start	IN BOOLEAN DEFAULT FALSE
  , p_separator	IN VARCHAR2 DEFAULT hr_general_utilities.g_separator
  )
RETURN VARCHAR2
IS
  l_t_str	VARCHAR2 (32000);
  l_ret_string	VARCHAR2 (32000);

BEGIN


--
--
-- need to encode tab, eol and cr
-- leave these lines exactly as they are
l_t_str := REPLACE (p_instring, '
', '%$*');
--
-- Replaced CHR(13) with the hr_util_misc_web.g_carriage_return
l_t_str := REPLACE (l_t_str, hr_util_misc_web.g_carriage_return, '&@~');
l_t_str := REPLACE (l_t_str, '	', ']@*');

  IF p_start THEN
    l_ret_string :=
      p_separator
       || l_t_str
       || p_separator;
  ELSE
    l_ret_string :=
      l_t_str
        || p_separator;
  END IF;
--


  RETURN l_ret_string;
--
--exception not necessary
--
END Add_Separators;
-- ----------------------------------------------------------------------------
-- |--< Locate_Item_In_Separated_Str  >---------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Locate_Item_In_Separated_Str
  ( p_string	IN VARCHAR2
  , p_item	IN NUMBER
  , p_separator	IN VARCHAR2  	DEFAULT hr_general_utilities.g_separator
  )
RETURN NUMBER
IS
--
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Find_Item_In_String';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN
    INSTR
      ( p_string, p_separator, 1, p_item
      );
END Locate_Item_In_Separated_Str;
-- ----------------------------------------------------------------------------
-- |--< Find_Item_In_String >-------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Find_Item_In_String
  ( p_item 	IN NUMBER
  , p_string 	IN VARCHAR2
  , p_separator	IN VARCHAR2 	DEFAULT hr_general_utilities.g_separator
  )
RETURN VARCHAR2
IS
  BeginSep      INTEGER;
  Endsep        INTEGER;
  l_returnstr	VARCHAR2 (32000);
  l_reduceval  	NUMBER := 2; -- needs to be 1 if the space character is used
--

BEGIN

  BeginSep :=
    Locate_Item_In_Separated_Str
      ( p_string	=> p_string
      , p_item		=> p_item
      , p_separator	=> p_separator
      );
  EndSep :=
    Locate_Item_In_Separated_Str
      ( p_string	=> p_string
      , p_item		=> p_item + 1
      , p_separator	=> p_separator
      );
--
  IF p_separator = g_space THEN
    l_reduceval := 1;
  ELSE
    NULL;
  END IF;
--
  l_returnstr :=
    SUBSTR
      ( p_string
      , BeginSep + length (p_separator)
      , EndSep - BeginSep - l_reduceval
      );
--
-- convert back to line feed, carriage return, tab
-- do not modify these lines
  l_returnstr :=
    REPLACE (l_returnstr, '%$*', '
');

  l_returnstr :=
    REPLACE (l_returnstr, '&@~', hr_util_misc_web.g_carriage_return); -- chr(13)

  l_returnstr :=
    REPLACE (l_returnstr, ']@*', '	');

--
  IF p_separator <> g_space THEN
--
-- trim if the separator is not the space character
--
    l_returnstr :=
      RTRIM
        ( LTRIM
           ( l_returnstr
           )
        );
  ELSE
    NULL;
  END IF;
--

--
  RETURN l_returnstr;
--
--exception not necessary
--
END Find_Item_In_String ;
-- ----------------------------------------------------------------------------
-- |--< Trim_Separator  >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Trim_Separator
  ( p_string	IN VARCHAR2
  , p_end	IN VARCHAR2 	DEFAULT 'RIGHT'
  , p_separator	IN VARCHAR2 	DEFAULT hr_general_utilities.g_separator
  )
RETURN VARCHAR2
IS
  l_returnval		VARCHAR2 (32000);
  l_separator_length	NUMBER := LENGTH( p_separator);
  l_chk_string		VARCHAR2 (200);
  l_string_length	NUMBER := LENGTH(p_string);
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Trim_Separator';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

--
  IF p_string IS NOT NULL THEN
    IF UPPER(p_end) = 'RIGHT' THEN
      l_chk_string :=
        SUBSTR
          ( p_string
          , l_string_length - l_separator_length + 1
          , l_separator_length
          );
    ELSE
      l_chk_string :=
        SUBSTR
          ( p_string
          , 1
          , l_separator_length
          );
     END IF;
--
    IF l_chk_string = p_separator THEN
      IF UPPER(p_end) = 'RIGHT' THEN
        l_returnval :=
          SUBSTR
            ( p_string
            , 1
            , l_string_length - l_separator_length
            );
      ELSE
        l_returnval :=
          SUBSTR
            ( p_string
            , l_separator_length + 1
            , l_string_length - l_separator_length
            );
      END IF;
    ELSE
      NULL;
    END IF;
  ELSE
    NULL;
  END IF;
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN l_returnval;
END Trim_Separator;
-- ----------------------------------------------------------------------------
-- |--< BPFD  >---------------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION BPFD
  ( p_string IN VARCHAR2
  )
RETURN VARCHAR2
IS
  l_icx_string	VARCHAR2 (32000) := p_string;
  l_package	VARCHAR2 (32000);
  l_procedure	VARCHAR2 (32000);
  l_count	NUMBER;
  l_sql_string	VARCHAR2 (32000);
  l_offset	NUMBER := 3; -- i.e. the number of fields before the list
			     -- of parameter / values
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' BPFD';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  l_package :=
    hr_general_utilities.Find_Item_In_String
      ( p_item => 1
      , p_string => l_icx_string
      );
  l_procedure :=
    hr_general_utilities.Find_Item_In_String
      ( p_item => 2
      , p_string => l_icx_string
      );
  l_count :=
    to_number
      ( hr_general_utilities.Find_Item_In_String
          ( p_item => 3
          , p_string => l_icx_string
          )
      );
  l_sql_string :=
    l_package
    || '.'
    || l_procedure
    || '(';
--
  FOR Counter IN 1 .. 2 * l_count
  LOOP
    -- i.e. is an odd number, therefore ignore (equivalent to step)
    IF MOD (counter, 2) <> 0
    THEN
      IF Counter <> 1 THEN
        l_sql_string := l_sql_string || ',';
      ELSE
        NULL;
      END IF;
--
      l_sql_string :=
        l_sql_string
        || hr_general_utilities.Find_Item_In_String
             ( p_item => Counter + l_offset
             , p_string => l_icx_string
             );
      BEGIN
        l_sql_string :=
          l_sql_string
          || '=>'
          || to_number
               ( hr_general_utilities.Find_Item_In_String
                   ( p_item => Counter + l_offset + 1
                   , p_string => l_icx_string
                   )
               );
      EXCEPTION
        WHEN OTHERS THEN
        -- cannot convert a text string
        l_sql_string :=
          l_sql_string
          || '=>'
          || ''''
          || hr_general_utilities.Find_Item_In_String
               ( p_item => Counter + l_offset + 1
               , p_string => l_icx_string
               )
          || '''';
--
-- make sure that reserved words are transcribed correctly
--
        l_sql_string :=
          REPLACE
            ( l_sql_string
            , '''NULL'''
            , 'NULL'
            );
      END;
        l_sql_string :=
          REPLACE
            ( l_sql_string
            , '''NULL'''
            , 'NULL'
            );
        l_sql_string :=
          REPLACE
            ( l_sql_string
            , '''TRUE'''
            , 'TRUE'
            );
        l_sql_string :=
          REPLACE
            ( l_sql_string
            , '''FALSE'''
            , 'FALSE'
            );

    ELSE
      NULL;
    END IF;
  END LOOP;
--
-- close the opening parenthesis
--
  l_sql_string := l_sql_string || ')';

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN  l_sql_string;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END BPFD;
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
RETURN VARCHAR2
IS

  l_icx_string	VARCHAR2 (32000) := p_string;
  l_package	VARCHAR2 (32000);
  l_procedure	VARCHAR2 (32000);
  l_count	NUMBER;
  l_sql_string	VARCHAR2 (32000);
  l_tmp_string  VARCHAR2 (32000);
  l_offset	NUMBER := 3; -- i.e. the number of fields before the list
			     -- of parameter / values
  l_proc	VARCHAR2 (72) := g_package || ' build_proc_from_decryption';
  l_bind_values_tab_out       hr_general_utilities.g_vc32k_tab_type;
  l_bind_values_count         integer := 0;
  l_empty_values_tab          hr_general_utilities.g_vc32k_tab_type;
  l_use_bind_values           boolean default null;
--
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  l_package :=
    hr_general_utilities.Find_Item_In_String
      ( p_item => 1
      , p_string => l_icx_string
      );
  l_procedure :=
    hr_general_utilities.Find_Item_In_String
      ( p_item => 2
      , p_string => l_icx_string
      );
  l_count :=
    to_number
      ( hr_general_utilities.Find_Item_In_String
          ( p_item => 3
          , p_string => l_icx_string
          )
      );
  l_sql_string :=
    l_package
    || '.'
    || l_procedure
    || '(';

-------------------------------------------------------------------------------
-- 04/08/2001 Bug 1713366 Fix:
-- We will compare the l_count which is the number of parameters for the
-- dynamic SQL invocation with the global constant g_num_dynamic_sql_parms.  If
-- the l_count is > g_num_dynamic_sql_parms, we will use the old BPFD function,
-- The dynamic SQL created will have literal values in it, e.g.
-- per_appraisal_display_web.aprp07(p_appraisal_id =>4368,p_appraisee_id=>1234).
--
-- If the l_count is <= g_num_dynamic_sql_parms, then this BPFD will be used
-- which will create a dynamic SQL with bind variables to hold the arguments,
-- e.g. per_appraisal_display_web.aprp07(p_appraisal_id=>:1,p_appraisee_id=>:2).
--
-- If for some reason we want to revert to the old BPFD code, we can set the
-- g_num_dynamic_sql_parms global constant to -1.  This approach can be used for
-- debugging when we suspect that Native Dynamic SQL is causing some obscure
-- errors.
-------------------------------------------------------------------------------
--
  IF l_count > g_num_dynamic_sql_parms
  THEN
     -- Do the old BPFD way
     l_use_bind_values := false;
     FOR Counter IN 1 .. 2 * l_count
     LOOP
        -- i.e. is an odd number, therefore ignore (equivalent to step)
        IF MOD (counter, 2) <> 0
        THEN
          IF Counter <> 1 THEN
            l_sql_string := l_sql_string || ',';
          ELSE
            NULL;
          END IF;
          --
          l_sql_string := l_sql_string ||
            hr_general_utilities.Find_Item_In_String
             ( p_item => Counter + l_offset
             , p_string => l_icx_string
             );
          --
          BEGIN
             l_sql_string := l_sql_string || '=>' ||
                to_number ( hr_general_utilities.Find_Item_In_String
                              ( p_item => Counter + l_offset + 1
                              , p_string => l_icx_string
                               )
                           );
          EXCEPTION
            WHEN OTHERS THEN
               -- cannot convert a text string
               l_sql_string := l_sql_string || '=>' || ''''
                  || hr_general_utilities.Find_Item_In_String
                    ( p_item => Counter + l_offset + 1
                    , p_string => l_icx_string
                    ) || '''';
               --
               -- make sure that reserved words are transcribed correctly
               --
               l_sql_string := REPLACE ( l_sql_string , '''NULL''' , 'NULL');
          END;
          -- Don't know why the old BPFD checks for ''NULL'' again.  Keep it
          -- here just in case.
          l_sql_string := REPLACE ( l_sql_string , '''NULL''' , 'NULL');
          --
          l_sql_string := REPLACE ( l_sql_string , '''TRUE''' , 'TRUE');
          --
          l_sql_string := REPLACE ( l_sql_string , '''FALSE''' , 'FALSE');
          --
        ELSE
          NULL;
        END IF;
     END LOOP;
  ELSE
     -- l_count is less than or equal to g_num_dynamic_sql_parms
     l_use_bind_values := true;
     FOR Counter IN 1 .. 2 * l_count
     LOOP
       -- i.e. is an odd number, therefore ignore (equivalent to step)
       IF MOD (counter, 2) <> 0
       THEN
         IF Counter <> 1 THEN
           l_sql_string := l_sql_string || ',';
         ELSE
           NULL;
         END IF;
         --
         l_tmp_string := null;

         l_sql_string := l_sql_string ||
             hr_general_utilities.Find_Item_In_String
             ( p_item => Counter + l_offset
             , p_string => l_icx_string
             );

         l_sql_string := l_sql_string || '=>';

         -----------------------------------------------------------------------
         -- Bug 1713366 Fix:
         -- Literal SQL statement will not scale.  Therefore, we need to convert
         -- all literal values to bind variables in the dynamic sql statement
         -- to improve performance.
         -- We replace the parameter values with bind variables and store the
         -- bind values in a table.
         -----------------------------------------------------------------------
         BEGIN
           --
           l_tmp_string := to_number
               ( hr_general_utilities.Find_Item_In_String
                   ( p_item => Counter + l_offset + 1
                   , p_string => l_icx_string
                   )
               );

           -- The dynamic sql will use bind variables for scalability
           -- E.g. per_appraisal_display_web.aprp07(p_appraisee_id  => :1, ....)
           -- Increment the counter if it is a number
           l_bind_values_count := l_bind_values_count + 1;
           l_sql_string := l_sql_string || ':' || l_bind_values_count;
           l_bind_values_tab_out(l_bind_values_count) := l_tmp_string;

         EXCEPTION
         WHEN OTHERS THEN
           -- cannot convert a text string
           -- We are going to use Native Dynamic SQL instead of placing the
           -- literal values in the parm, so we don't need to wrap the string
           -- with quotes around it.
           -- E.g. Literal SQL:
           --   per_appraisal_display_web.aprp07(p_calltype => 'PAGE', ...)
           --   Bind Variable SQL:
           --   per_appraisal_display_web.aprp07(p_calltype => :1, ...); --> The
           --   bind value for :1 will be stored in a variable as PAGE and thus
           --   no quotes are needed in the bind value.
           --
           l_tmp_string :=  hr_general_utilities.Find_Item_In_String
               ( p_item => Counter + l_offset + 1
               , p_string => l_icx_string);

           -- Bug fix for 2061027 starts
           -- OTA uses the encryption function in which they pass String with
           -- quotes in them, we handle these quotes by enclosing them in
           -- escape character which again is a quote and store them in the
           -- ICX table, when the values are read back here we need to do the
           -- reverese so that the quotes don't cause an issue

           l_tmp_string := REPLACE (l_tmp_string, '''''', '''');

           -- bug fix 2061027 ends

           -- make sure that reserved words are transcribed correctly
           -- For reserved words like NULL, TRUE and FALSE, we won't use
           -- the bind variables because Native Dynamic SQL does not support
           -- these values.
           --
           IF instr(l_tmp_string, 'NULL') > 0 OR
              instr(l_tmp_string, 'TRUE') > 0 OR
              instr(l_tmp_string, 'FALSE') > 0
           THEN
              IF instr(l_tmp_string, 'NULL') > 0
              THEN
                 l_sql_string := l_sql_string || l_tmp_string;
              END IF;
              --
              IF instr(l_tmp_string, 'TRUE') > 0
              THEN
                 l_sql_string := l_sql_string || l_tmp_string;
              END IF;
              --
              IF instr(l_tmp_string, 'FALSE') > 0
              THEN
                 l_sql_string := l_sql_string || l_tmp_string;
              END IF;
              --
           ELSE
              -- The text is not one of the reserved values, thus we need to
              -- use the bind values.
              l_bind_values_count := l_bind_values_count + 1;
              l_sql_string := l_sql_string || ':' || l_bind_values_count;
              l_bind_values_tab_out(l_bind_values_count) := l_tmp_string;
           END IF;
         END;
       ELSE
         -- an even number, that means it is the parameter name, no special
         -- processing.
         NULL;
       END IF;
     END LOOP;
  END IF;  -- end the g_num_dynamic_sql_parms check
--
-- close the opening parenthesis
--
  l_sql_string := l_sql_string || ')';

  p_bind_values_tab := l_bind_values_tab_out;
  p_use_bind_values := l_use_bind_values;

  return l_sql_string;

EXCEPTION
  WHEN OTHERS THEN
    p_bind_values_tab := l_empty_values_tab;
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_coding_error;

END BPFD;
--
-- ----------------------------------------------------------------------------
-- |--< Get_Date_Hint >-------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Date_Hint
RETURN VARCHAR2
IS
  c_prompts       icx_util.g_prompts_table;
  c_title         VARCHAR2 (200);
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Get_Date_Hint';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  -- Bug #1200894 fix
  icx_util.getPrompts(601,'HR_PERSONAL_INFORMATION',c_title,c_prompts);

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN
    '('
    ||
    c_prompts (61)   -- e.g.
    || ' '
    ||
    date2char
      ( p_date		=> g_sample_date
      )
    || ')';
END Get_Date_Hint;
-- ----------------------------------------------------------------------------
-- |--< EPFS >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION EPFS
  ( p_string	IN VARCHAR2
  , p_type	IN VARCHAR2 DEFAULT 'S'
  )
RETURN VARCHAR2
IS
  l_max_length	NUMBER := 1000;
  l_rows	NUMBER;
  l_str_length	NUMBER;
  l_str_start	NUMBER := 1;
  l_sep_start	BOOLEAN;
  l_icx_ids	VARCHAR2 (2000);
  l_icx_count	NUMBER := 0;
  l_tmp_id	VARCHAR2 (2000);
  l_string 	VARCHAR2 (2000);
  l_code	VARCHAR2 (2000);
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' EPFS';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

--
-- this breaks a long string up to 32k into l_max_length bits
-- encrypts it and returns the encryption id
-- the ids are built into a string and then encrypted
-- the index string format is
-- !# S !# 3 !# 1001 !# 1002 !# 1003 !#
--  exec   rows  r1      r2      r3
-- S - single execute
-- G - global cache (i.e. ends up stored)
-- start the string
--
  l_code :=
    l_code
    || hr_general_utilities.Add_Separators
         ( p_instring => p_type
         , p_start => TRUE
         );
--
  l_str_length := LENGTH(p_string);
  l_rows :=
    CEIL
      ( l_str_length
      / l_max_length
      );
  FOR Counter in 1 .. l_rows
  LOOP
    IF Counter = l_rows THEN
      l_string :=
        SUBSTR
          ( p_string
          , l_str_start
          , l_str_length - l_str_start + 1
          );
    ELSE
      l_string :=
        SUBSTR
          ( p_string
          , l_str_start
          , l_max_length
          );
      l_str_start := l_str_start + l_max_length;
    END IF;
--
-- encrypt the string
--
    l_tmp_id :=
      icx_call.encrypt2
        ( c_string => l_string
        );
--
-- store the row index
--
    l_icx_ids :=
      l_icx_ids
      || hr_general_utilities.Add_Separators
           ( p_instring => l_tmp_id
           );
--
-- count the number of icx rows
--
    l_icx_count := l_icx_count + 1;
  END LOOP;
--
-- add the number of rows
--
    l_icx_ids :=
      l_code
      || hr_general_utilities.Add_Separators
           ( p_instring => to_char(l_icx_count)
           )
      || l_icx_ids;
--
-- now encrypt the index values themselves
--
  l_tmp_id :=
    icx_call.encrypt2
      ( c_string => l_icx_ids
      );
--
-- return this value

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN l_tmp_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END EPFS;
-- ----------------------------------------------------------------------------
-- |--< ASEI >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ASEI
  ( p_text_id 	IN VARCHAR2
  )
IS
  l_proc	VARCHAR2 (72) := g_package || ' ASEI';
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' ASEI';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  g_execute_handles (g_execute_handles.count + 1) := p_text_id;
END ASEI;
-- ----------------------------------------------------------------------------
-- |--< CCEI >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION CCEI
RETURN VARCHAR2
IS
  l_string 	VARCHAR2 (2000);
  l_proc	VARCHAR2 (72) := g_package || ' CCEI';
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  IF g_execute_handles.count > 0 THEN
    l_string :=
      l_string
      || hr_general_utilities.Add_Separators
           ( p_instring => 'C'
           , p_start => TRUE
           );
    l_string :=
      l_string
      || hr_general_utilities.Add_Separators
           ( p_instring => to_char(g_execute_handles.count)
           );
    FOR Counter IN 1 .. g_execute_handles.count
    LOOP
      l_string :=
        l_string
        || hr_general_utilities.Add_Separators
             ( p_instring => g_execute_handles(Counter)
             );
    END LOOP;
  ELSE
    RAISE hr_session_utilities.g_coding_error;
  END IF;
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN
    icx_call.encrypt2
       ( c_string => l_string
       );
EXCEPTION
  WHEN OTHERS THEN
--
-- vc2 length may exceed 2000;
-- this must be a coding error
-- mechanism not really suitable for executing so many sql statements
--
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_coding_error;
END CCEI;
-- ----------------------------------------------------------------------------
-- |--< EXPD >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION EXPD
  ( p_id	IN VARCHAR2 DEFAULT NULL
  , p_string	IN VARCHAR2 DEFAULT NULL
  )
RETURN VARCHAR2
IS
  l_index_string	VARCHAR2 (32000);
  l_item2		NUMBER;
  l_offset		NUMBER := 2;
  l_string		VARCHAR2 (32000);
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' EXPD';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


  IF p_string IS NULL THEN
    l_index_string :=
      icx_call.decrypt2
        ( c_text_id => p_id
        );
  ELSE
    l_index_string := p_string;
  END IF;
--
  l_item2 :=
    to_number
      ( hr_general_utilities.Find_Item_In_String
          ( p_item 		=> 2
          , p_string 		=> l_index_string
          )
      );
--
    FOR RowCounter IN 1 .. l_item2
    LOOP
      l_string :=
        l_string
        ||  icx_call.decrypt2
              ( c_text_id =>
                  hr_general_utilities.Find_Item_In_String
                    ( p_item 		=> RowCounter + l_offset
                    , p_string 		=> l_index_string
                    )
               );
     END LOOP;
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN l_string;
END EXPD;
-- ----------------------------------------------------------------------------
-- |--< DExL >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE DExL
 ( i		IN VARCHAR2
 )
IS
err_mesg varchar2 (2000);
  l_sql_string	VARCHAR2 (32000);
  l_index_string	VARCHAR2 (32000);
  l_item1		VARCHAR2 (2000);
  l_item2		NUMBER;
  l_proc	VARCHAR2 (72):= g_package || ' DExL';
  l_bind_values_count   integer default 0;
  l_bind_values_tab     hr_general_utilities.g_vc32k_tab_type;
  l_bind_values_list    varchar2(32000) default null;
  l_use_bind_values     boolean default null;

BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

--hrhtml2.debug('entered dex;');
--
-- reset the cache
--
--  hr_general_utilities.reset_g_cache;
--
-- decrypt the index string
--
  l_index_string :=
    icx_call.decrypt2
      ( c_text_id => to_number(i)
      );
--
-- decrypt2 returns -1 if the session is invalid
--
  IF l_index_string = '-1' THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'PER_DEXL_SESSION_FAIL'
      );
    RAISE g_fatal_error;
  ELSE
--
-- extract the first two items to see which process to follow (S, G, C)
--
    l_item1 :=
       hr_general_utilities.Find_Item_In_String
          ( p_item 		=> 1
          , p_string 		=> l_index_string
          );
--
    l_item2 :=
      to_number
        ( hr_general_utilities.Find_Item_In_String
            ( p_item 		=> 2
            , p_string 		=> l_index_string
            )
        );
--
-- switch accordingly
--
    IF l_item1 = 'C'  THEN
      FOR Counter IN 1 .. l_item2
      LOOP
        hr_general_utilities.DEXL
          ( i =>
            hr_general_utilities.Find_Item_In_String
              ( p_item 		=> Counter + 2
              , p_string 		=> l_index_string
              )
          );
      END LOOP;
    ELSIF l_item1 = 'G' THEN
--
-- store the string in the global cache variable for later retrieval
--------------------------------------------------------------------------------
-- Bug 1615428:
-- Need to clear g_cache global array for R11i WebDB stateful mode.  Otherwise,
-- g_string_cache will retain previous value and cause obscure error when
-- clicking CANCEL button in MEE pages.
-------------------------------------------------------------------------------
--
-- bug 1911463
-- commenting the call to delete as this is causing errors in appraisels
--    hr_general_utilities.g_string_cache.delete;

      g_string_cache (g_string_cache.count + 1) :=
        EXPD
          ( p_string => l_index_string
          );
    ELSIF l_item1 = 'S' THEN
       --
       -- Build the executable link
       --
       -------------------------------------------------------------------------
       -- Bug 1713366:
       --   The l_sql_string results in literal SQL statement which makes it
       --   unreusable, especially in Appraisal.
       --   Will call an overloaded BPFD which will pass back 2 output parms:
       --   one is table records which contain values of the bind variables and
       --   the other output parm will indicate whether bind variable algorithm
       --   was used or not.
       --   NOTE: When the count of l_bind_values_tab output parm is zero, it
       --         does not mean that bind variable algorithm was not used, e.g.
       --         hr_mee_person_search_tree_web.display_container_bottom_frame()
       --         We can use Native Dynamic SQL to make the above invocation.
       ------------------------------------------------------------------------
       l_sql_string := hr_general_utilities.BPFD
                         ( p_string => EXPD ( p_string => l_index_string)
                          ,p_bind_values_tab => l_bind_values_tab
                          ,p_use_bind_values => l_use_bind_values
                         );
       --
       l_sql_string := 'begin ' || l_sql_string || '; end;';

       l_bind_values_count := l_bind_values_tab.count;

       IF l_bind_values_count = 0 and l_use_bind_values = TRUE
       THEN
          -- Use Native Dynamic SQL call
          -- No parameters, does not need to pass bind values
          EXECUTE IMMEDIATE l_sql_string;
       ELSIF l_bind_values_count = 1
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1);
       ELSIF l_bind_values_count = 2
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2);
       ELSIF l_bind_values_count = 3
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3);
       ELSIF l_bind_values_count = 4
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4);
       ELSIF l_bind_values_count = 5
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4)
                                              ,l_bind_values_tab(5);
       ELSIF l_bind_values_count = 6
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4)
                                              ,l_bind_values_tab(5)
                                              ,l_bind_values_tab(6);
       ELSIF l_bind_values_count = 7
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4)
                                              ,l_bind_values_tab(5)
                                              ,l_bind_values_tab(6)
                                              ,l_bind_values_tab(7);
       ELSIF l_bind_values_count = 8
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4)
                                              ,l_bind_values_tab(5)
                                              ,l_bind_values_tab(6)
                                              ,l_bind_values_tab(7)
                                              ,l_bind_values_tab(8);
       ELSIF l_bind_values_count = 9
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4)
                                              ,l_bind_values_tab(5)
                                              ,l_bind_values_tab(6)
                                              ,l_bind_values_tab(7)
                                              ,l_bind_values_tab(8)
                                              ,l_bind_values_tab(9);
       ELSIF l_bind_values_count = 10
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4)
                                              ,l_bind_values_tab(5)
                                              ,l_bind_values_tab(6)
                                              ,l_bind_values_tab(7)
                                              ,l_bind_values_tab(8)
                                              ,l_bind_values_tab(9)
                                              ,l_bind_values_tab(10);
       ELSIF l_bind_values_count = 11
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4)
                                              ,l_bind_values_tab(5)
                                              ,l_bind_values_tab(6)
                                              ,l_bind_values_tab(7)
                                              ,l_bind_values_tab(8)
                                              ,l_bind_values_tab(9)
                                              ,l_bind_values_tab(10)
                                              ,l_bind_values_tab(11);
       ELSIF l_bind_values_count = 12
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4)
                                              ,l_bind_values_tab(5)
                                              ,l_bind_values_tab(6)
                                              ,l_bind_values_tab(7)
                                              ,l_bind_values_tab(8)
                                              ,l_bind_values_tab(9)
                                              ,l_bind_values_tab(10)
                                              ,l_bind_values_tab(11)
                                              ,l_bind_values_tab(12);
       ELSIF l_bind_values_count = 13
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4)
                                              ,l_bind_values_tab(5)
                                              ,l_bind_values_tab(6)
                                              ,l_bind_values_tab(7)
                                              ,l_bind_values_tab(8)
                                              ,l_bind_values_tab(9)
                                              ,l_bind_values_tab(10)
                                              ,l_bind_values_tab(11)
                                              ,l_bind_values_tab(13);
       ELSIF l_bind_values_count = 14
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4)
                                              ,l_bind_values_tab(5)
                                              ,l_bind_values_tab(6)
                                              ,l_bind_values_tab(7)
                                              ,l_bind_values_tab(8)
                                              ,l_bind_values_tab(9)
                                              ,l_bind_values_tab(10)
                                              ,l_bind_values_tab(11)
                                              ,l_bind_values_tab(14);
       ELSIF l_bind_values_count = 15
       THEN
          EXECUTE IMMEDIATE l_sql_string USING l_bind_values_tab(1)
                                              ,l_bind_values_tab(2)
                                              ,l_bind_values_tab(3)
                                              ,l_bind_values_tab(4)
                                              ,l_bind_values_tab(5)
                                              ,l_bind_values_tab(6)
                                              ,l_bind_values_tab(7)
                                              ,l_bind_values_tab(8)
                                              ,l_bind_values_tab(9)
                                              ,l_bind_values_tab(10)
                                              ,l_bind_values_tab(11)
                                              ,l_bind_values_tab(14)
                                              ,l_bind_values_tab(15);
       ELSE
          -- either the parameters are greater than 15 or the num of parameters
          -- are greater than the global constant g_num_dynamic_sql_parms, then
          -- use dbms_sql package by calling Execute_Dynamic_SQL procedure.
          -- From old code which uses literal SQL statement

IF g_debug THEN
          hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

          Execute_Dynamic_SQL
              ( p_sql_string => l_sql_string
              );
       END IF;  -- end of l_bind_values_count check
      -- end of bug 1713366
    END IF;  -- end of l_item1 = 'S'
  end if;
EXCEPTION
  WHEN g_fatal_error THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    htp.p (fnd_message.get);
--
-- do not re-raise otherwise fails; nowhere to raise to (may be calling itself)
--
  WHEN OTHERS THEN
--
-- an error trying to decode the string
--
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_coding_error;
END DexL;
-- ----------------------------------------------------------------------------
-- |--< SDER >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION SDER
RETURN VARCHAR2
IS
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' SDER';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN 'hr_general_utilities.DEXL?i=';
END SDER;
-- ----------------------------------------------------------------------------
-- |--< REGS >----------------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION REGS
  ( p_index	IN NUMBER
  )
RETURN VARCHAR2
IS
  l_string	VARCHAR2 (32000);
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' REGS';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  IF g_string_cache.exists (p_index) THEN
    l_string :=  g_string_cache(p_index);
  ELSE
    NULL;
  END IF;
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN l_string;
END REGS;
-- ----------------------------------------------------------------------------
-- |--< Reset_G_Cache >--------------------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Reset_G_Cache
IS
  l_reset g_vc32k_tab_type;
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Reset_G_Cache';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  g_string_cache := l_reset;

END Reset_G_Cache;
-- ----------------------------------------------------------------------------
-- |--< Locate_Text >---------------------------------------------------------|
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
RETURN NUMBER
IS
  l_start_pos		NUMBER;
  l_instance		NUMBER := 1;
  l_returnval		NUMBER;
  l_search_after	NUMBER;
  l_search_in		VARCHAR2 (32000);
  l_search_for		VARCHAR2 (32000);
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Locate_Text';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  IF p_second_instance THEN
     l_instance := 2;
  ELSE
    NULL;
  END IF;
--
  IF p_ignore_case THEN
    l_search_in := UPPER (p_search_in);
    l_search_for := UPPER (p_search_for);
  ELSE
    l_search_in := p_search_in;
    l_search_for := p_search_for;
  END IF;
--
  IF p_reverse THEN
    l_search_after := -1 * (LENGTH (l_search_in) - p_search_after +1);
  ELSE
    l_search_after := p_search_after;
  END IF;
--
  l_start_pos :=
    INSTR
      ( l_search_in
      , l_search_for
      , l_search_after
      , l_instance
      );
--
  IF l_start_pos <> 0 THEN
    IF p_end_position THEN
      l_returnval := l_start_pos + LENGTH (p_search_for);
    ELSE
      l_returnval := l_start_pos;
    END IF;
  ELSE
    l_returnval := l_start_pos;
  END IF;
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN l_returnval;
END Locate_Text;
-- ----------------------------------------------------------------------------
-- |--< Count_Instances >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Count_Instances
  ( p_search_in		IN VARCHAR2
  , p_search_for	IN VARCHAR2
  , p_ignore_case	IN BOOLEAN DEFAULT TRUE
  )
RETURN NUMBER
IS
  l_search_in		VARCHAR2 (32000);
  l_search_for		VARCHAR2 (200);
  l_position		NUMBER := 0;
  l_counter		NUMBER := 1;
  l_returnval		NUMBER := 0;
  l_proc	VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Count_Instances';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  IF p_ignore_case THEN
    l_search_in := UPPER ( p_search_in);
    l_search_for := UPPER (p_search_for);
  ELSE
    l_search_in := p_search_in;
    l_search_for := p_search_for;
  END IF;
--
  LOOP
    l_position :=
      INSTR
        ( l_search_in
        , l_search_for
        , 1
        , l_counter
        );
    EXIT WHEN l_position = 0;
    l_counter := l_counter + 1;
  END LOOP;

--
  l_returnval := l_counter -1;
--

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  RETURN l_returnval;
END Count_Instances;
-- ----------------------------------------------------------------------------
-- |--< Execute_Dynamic_SQL >-------------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Execute_Dynamic_SQL
  ( p_sql_string	IN VARCHAR2
  )
IS
  l_cursor_handle	NUMBER;
  l_exec		NUMBER;
  l_proc	VARCHAR2 (72) := g_package || ' Execute_Dynamic_SQL';
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  l_cursor_handle := dbms_sql.open_cursor;
  dbms_sql.parse
    ( l_cursor_handle
    , p_sql_string
    , dbms_sql.v7
    );
  l_exec := dbms_sql.execute (l_cursor_handle);
  dbms_sql.close_cursor(l_cursor_handle);

IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_coding_error;
END Execute_Dynamic_SQL;
-- ----------------------------------------------------------------------------
-- |--< Set_Message_Txt_And_Number >------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Set_Message_Txt_And_Number
  ( p_application_id 	IN VARCHAR2 DEFAULT 'PER'
  , p_message_name 	IN VARCHAR2 DEFAULT NULL
  )
RETURN r_error_msg_txt_number_rec
IS
  l_record 	r_error_msg_txt_number_rec;
  l_get_encoded	VARCHAR2 (2000);
  l_short_name	VARCHAR2 (2000);
  l_msg_name	VARCHAR2 (2000);
  l_proc	VARCHAR2 (72) := g_package || ' Get_Print_Action';
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;


IF g_debug THEN
  hr_utility.set_location('Leaving : ' || l_proc, 10);
END IF;

  IF p_message_name IS NOT NULL THEN
  fnd_message.set_name
     ( APPLICATION => p_application_id
     , NAME => p_message_name
     );
  ELSE
    NULL;
  END IF;
  l_get_encoded := fnd_message.get_encoded;
  fnd_message.parse_encoded
    ( ENCODED_MESSAGE => l_get_encoded
    , APP_SHORT_NAME  => l_short_name
    , MESSAGE_NAME => l_msg_name
    );
  l_record.error_text :=
    hr_general_utilities.Use_Message
      ( p_message_name => l_msg_name
      , p_application_id => l_short_name
      );
  l_record.error_number :=
    fnd_message.get_number
      ( APPIN => l_short_name
      , NAMEIN => l_msg_name
      );
  RETURN l_record;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message
      ( hr_session_utilities.g_PER_application_id
      , 'HR_6153_ALL_PROCEDURE_FAIL'
      );
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', sqlerrm);
    RAISE hr_session_utilities.g_coding_error;
END Set_Message_Txt_And_Number;
-- ----------------------------------------------------------------------------
-- |--< Set_Workflow_Section_Attribute >--------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Set_Workflow_Section_Attribute
  ( p_item_type 		IN wf_items.item_type%TYPE DEFAULT NULL
  , p_item_key 			IN wf_items.item_key%TYPE DEFAULT NULL
  , p_actid			IN NUMBER DEFAULT NULL
  , p_web_page_section_code 	IN VARCHAR2
  )
RETURN VARCHAR2
IS
  l_string	VARCHAR2 (2000);
  l_proc VARCHAR2 (72);
BEGIN
g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  l_proc := g_package || ' Set_Workflow_Section_Attribute';
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  IF hr_workflow_service.check_web_page_code
    ( p_item_type => p_item_type
    , p_item_key => p_item_key
    , p_actid => p_actid
    , p_web_page_section_code => p_web_page_section_code
    )
  THEN
    l_string :=
      hr_workflow_service.get_web_page_code
        ( p_item_type => p_item_type
        , p_item_key  => p_item_key
        , p_actid => p_actid
        , p_web_page_section_code => p_web_page_section_code
        );
  ELSE
    NULL;
  END IF;

IF g_debug THEN
  hr_utility.set_location('Entering : ' || l_proc, 5);
END IF;

  RETURN
    l_string;
END Set_Workflow_Section_Attribute;
--
-- bug 748569 fix: validate_session package initialization code eliminated
-- handled by frame drawing procedures only
--
END HR_GENERAL_UTILITIES;

/
