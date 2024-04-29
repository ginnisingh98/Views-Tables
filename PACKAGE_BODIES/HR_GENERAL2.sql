--------------------------------------------------------
--  DDL for Package Body HR_GENERAL2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GENERAL2" AS
/* $Header: hrgenrl2.pkb 120.12.12010000.3 2008/08/06 06:29:29 ubhat ship $ */
------------------------------------------------------------------------------
/*
+==========================================================================+
|                       Copyright (c) 1994 Oracle Corporation              |
|                          Redwood Shores, California, USA                 |
|                               All rights reserved.                       |
+==========================================================================+
Name
        General2 HR utilities
Purpose
        To provide widely used functions in a single shared area
History
        stlocke  08-FEB-2001 115.00	Created.
        ekim     20-JUN-2001 115.1      Added mask_characters function.
        asahay   18-JUL-2001 115.3      Added is_person_type function.
        wstallar 28-SEP-2001 115.4      Added functions to support duplicate
                                        person checking
        wstalar  30-SEP-2001 115.5      Added funciotn to derive full name for
                                        display in duplicate checks
        wstallar 03-OCT-2001 115.6      Fixed GET_DUP_NO_SECURITY_STATUS
                                        bug 2028926
        wstallar 26-OCT-2001 115.7      Fixed bug 2059163 - handle fact
                                        TCA records null name as '**********'
        gperry   08-JAN-2002 115.8      Fixed bug 2163957
        gperry   09-JAN-2002 115.9      Added dbdrv commands.
        acowan   27-FEB-2002 115.10     Added functions to return
                                        assignments status usages
        dcasemor 19-MAR-2002 115.13     Added chk_utf8_col_length.
        dcasemor 22-MAR-2002 115.14     Added address_line1, 2 and 3 to
                                        chk_utf8_col_length because
                                        per_addresses has no underscore.
        dcasemor 26-MAR-2002 115.15     Scaled down use of
                                        chk_utf8_col_length because this
                                        has been replaced by
                                        hr_utf8_triggers.
        dcasemor 15-MAR-2002 115.16     Removed chk_utf8_col_length.  This
                                        now resides in a separate package
                                        (hr_utf8_triggers).
        acowan   16-MAY-2002 115.17     Added validate_upload procedure
                                        to handle date checking during
                                        ldt upload.
        acowan   24-MAY-2002 115.18     Removed debug lines.
        acowan   24-MAY-2002 115.19     Added error handling.
        dcasemor 06-JUN-2002 115.20     Consolidated is_person_type
                                        functions by calling the function
                                        in the PTU utility package instead
                                        of having duplicated code.
	skota    20-AUG-2002 115.21     GSCC Changes
	skota    16-SEP-2002 115.22     Moved validate_upload function code to
				        pespt01t.pkb. validate_upload now
					refers to the function in pespt01t.pkb
        pkakar   15-OCT-2002 115.24     Added is_bg function for checking
                                        the business_group_id is valid for
                                        a specific legislation_code
					(same as 115.23)
        pkakar   16-OCT-2002 115.26     Added is_legislation_install for
                                        checking to see if a certain
                                        legislation has been installed
					(same as 115.25)
	prsundar 28-NOV-2002 115.27     Added overloaded procedure for
					init_fndload
	gperry   10-DEC-2002 115.28     Fixed WWBUG 2687564.
        mbocutt  16-Dec-2002 115.29     Fixed bug 2690302. Add join to
                                        HZ_PARTIES so the person_last_name
                                        index can be used when duplicate
                                        checking.
        dharris  06-Jan-2003 115.30     Added the PRIVATE global var
                                        g_oracle_version and PUBLIC
                                        function get_oracle_db_version
                                        Also added the g_debug and
                                        g_package private globals
        pattwood 17-JAN-2003 115.31     Bug 2651140. Added set_ovn procedure
                                        for populating the
                                        object_version_number column value
                                        when this column has been added to
                                        an existing table. Initial version
                                        of code is based on hrsetovn.sql
                                        version 115.2.
        fsheikh  30-JAN-2003 115.32     Bug 2706637. Added 3 JP legislation
                                        specific parameter to retieve full
                                        name as per JP format.
        dharris  30-Jan-2003 115.33     Modified get_oracle_db_version to
                                        place a format model on the
                                        returning number for wwbug 2772209.
                                        Also removed the raising of an
                                        error and replaced by returning
                                        NULL.
        divicker 07-APR-2003 115.36     Defaulted get_dup_full_name 3 JP param
        divicker 07-APR-2003 115.37     Changed from default to overload
                                        defaulting compiles forms but forms
                                        that call with 5 params fail at RT
        fsheikh  01-Sep-2003 115.38     Wrapped first and last name with
					upper function so as to make duplicate
					person search case insensitive.
ASahay   09-Sep-2003 115.39     Added function is_location_legal_adr
sgudiwad 25-Sep-2003 115.40   3136986   Added function decode_vendor for Refresh
                                        attributes
njaladi  30-dec-2003 115.41   3257115   Added overloaded function is_duplicate_person
                                        for JP legislation
dcasemor 01-Mar-2004 115.42   3346940   Added supervisor_assignments_in_use.
dcasemor 11-Mar-2004 115.43   3346940   Changed supervisor_assignments_in_use
                                        so it references a new profile option.
alogue   31-Mar-2004 115.44   3544109   Changed all_triggers to user_triggers.
kramajey 13-Jun-2005 115.45   4341787   Changed the join in the sql statement
                                        in is_duplicate_person procedure
					 for performance in JP Legislation.
sgelvi   31-May-2006 115.46             Added hrms_efc_column function
risgupta 13-OCT-2006 115.47   5599043  modified is_duplicate_person and removed logic
                                       written for JP localization. Modified the other
                                       SQL to join HZ_PARTIES so that index on last_name
                                       can be used.
risgupta 27-NOV-2006 115.51   3988762  Added two overloaded function for is_duplicate_person
                                       and also defined a global PL/SQL table to hold
                                       duplicate records for the fix of enh duplicate person.
pchowdav 14-MAR-2007 115.52   5930576  Modified the procedures is_duplicate_person to
                                       perform duplicate check when the profile option
				       HR:Cross BG Duplicate Person Check is null.
pchowdav 15-MAR-2007 115.53   5923547  Modified the procedures is_duplicate_person to
                                       perform duplicate check and return duplicate records
				       for SSHR ,when the profile option
				       HR:Cross Business Group is set to No.
pchowdav 16-MAR-2007 115.54   5933115  Modified the alias of business group id
				       from "BgId" to "BusinessGroupId" in cursor rc
				       in procedure is_duplicate_person.
pchowdav 21-MAR-2007 115.55   5946126  Modified the procedures is_duplicate_person
                                       to exclude displaying of tca records when
				       the profile 'HR:Cross business group' is set to 'No'
				       in sshr duplicate page.
ande     24-MAY-2007 115.56            Modified the size of the varchar2 local variables
                                       in is_duplicate_person.
pchowdav 23-JAN-2008 115.57   6748256  Modified the cursor c_duplicate_people in
                                       function is_duplicate_person and
				       cursor fetching duplicate persons in
				       procedure is_duplicate_person.
ktithy   17-APR-2008 115.58   6961892  Added new procedure
                                       SERVER_SIDE_PROFILE_PUT
				       which assigns a value to a profile
				       at Server Side.
--------------------------------------------------------------------------
*/

g_userenv_lang VARCHAR2(4):=NULL;
g_dup_external_name VARCHAR2(2000):=NULL;
g_dup_no_match VARCHAR2(2000):=NULL;
g_dup_no_security_char VARCHAR2(2000):=NULL;
g_oracle_version       NUMBER; -- holds the oracle version number and is
                               -- set by get_oracle_db_version
g_package              VARCHAR2(12)   := 'hr_general2.';
g_debug                BOOLEAN;
-- --------------------------------------------------------------------------
-- |----------------------< init_fndload procedure >------------------------|
-- --------------------------------------------------------------------------

PROCEDURE init_fndload(
  p_resp_appl_id IN NUMBER
  ) IS

  BEGIN
    Fnd_Global.apps_initialize
      (user_id          => 1
      ,resp_id          => 0
      ,resp_appl_id     => p_resp_appl_id );

  END init_fndload;


--Overloaded procedure for init_fndload
PROCEDURE init_fndload(p_resp_appl_id IN NUMBER
		      ,p_user_id      IN NUMBER
		      ) IS
  BEGIN
    Fnd_Global.apps_initialize
      (user_id          => p_user_id
      ,resp_id          => 0
      ,resp_appl_id     => p_resp_appl_id );

  END init_fndload;


-- --------------------------------------------------------------------------
-- |----------------------< mask_characters function >----------------------|
-- --------------------------------------------------------------------------

FUNCTION mask_characters(p_number IN VARCHAR2) RETURN VARCHAR2 IS

l_mask VARCHAR2(50) := '';
l_mask_size NUMBER;
l_length_number NUMBER := LENGTH(p_number);
l_show_digit NUMBER;

BEGIN
--
  IF (p_number IS NOT NULL) THEN

     l_mask_size := Fnd_Profile.value_wnps('HR_MASK_CHARACTERS');

     IF (ABS(l_mask_size) > LENGTH(p_number)) THEN
          l_mask_size := LENGTH(p_number);
     END IF;

     l_show_digit := -1 * l_mask_size;

     IF l_mask_size > 0 THEN

       l_mask := LPAD(SUBSTR(p_number, l_show_digit),
                           LENGTH(p_number),
                           'X');
     ELSIF l_mask_size < 0 THEN

       l_mask := RPAD(SUBSTR(p_number, 1, l_show_digit),
                           LENGTH(p_number),
                           'X');
     END IF;

  ELSE
    NULL;
  -- If no account number exists, do nothing.
  END IF;

  RETURN l_mask;
END mask_characters;

-- --------------------------------------------------------------------------
-- |------------------------< is_person_type function >-----------------------|
-- --------------------------------------------------------------------------

FUNCTION is_person_type
		(p_person_id 		IN NUMBER,
		 p_person_type		IN VARCHAR2,
		 p_effective_date	IN DATE
		)
RETURN BOOLEAN IS

l_exists BOOLEAN;

BEGIN

  --
  -- Call the PTU consolidated function.
  --
  l_exists := hr_person_type_usage_info.is_person_of_type
               (p_effective_date      => p_effective_date
               ,p_person_id           => p_person_id
               ,p_system_person_type  => p_person_type);

  RETURN l_exists;

END is_person_type;
--Added for fix 0f #3257115 start
-- --------------------------------------------------------------------------
-- |--------------< is_duplicate_person function (Legislation)>--------------|
-- --------------------------------------------------------------------------

FUNCTION is_duplicate_person(p_first_name IN VARCHAR2
                            ,p_last_name IN VARCHAR2
                            ,p_national_identifier IN VARCHAR2
                            ,p_date_of_birth IN DATE
                            ,p_leg_code IN VARCHAR2
                            ,p_first_name_phonetic IN VARCHAR2
                            ,p_last_name_phonetic IN VARCHAR2)
                        RETURN BOOLEAN
IS
 l_duplicate_found BOOLEAN:=FALSE;
 l_session_date DATE;
 l_dummy varchar2(1);
BEGIN
  --
  hr_utility.set_location('11',10);
  if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' then
    return l_duplicate_found;
  end if;
  -- Get the session date
  SELECT se.effective_date
  INTO   l_session_date
  FROM   fnd_sessions se
  WHERE  se.session_id =USERENV('sessionid');

  -- Query to detect duplicate person
  -- Use where exists for performance reasons
  hr_utility.set_location('12',10);
 -- commented for bug 5530099
/* if p_leg_code = 'JP' then
  BEGIN
   SELECT null
   INTO   l_dummy
     FROM dual
    WHERE EXISTS
       (SELECT 1
          FROM per_all_people_f per
 		 WHERE l_session_date BETWEEN per.effective_start_date
                                AND    per.effective_end_date
		   AND per.national_identifier=p_national_identifier)
       or EXISTS
       (SELECT 1
          from hz_parties hzp,hz_person_profiles pro
	 where UPPER(hzp.person_last_name_phonetic)=UPPER(p_last_name_phonetic)
	   AND hzp.party_id = pro.party_id
	   AND pro.effective_end_date is NULL
           AND
	      (  UPPER(pro.person_first_name)=UPPER(p_first_name)
	       OR pro.person_first_name is null
	       OR p_first_name IS NULL)
           AND
	      (  UPPER(pro.Person_first_name_phonetic)=UPPER(p_first_name_phonetic)
	       OR pro.person_first_name_phonetic is null
	       OR p_first_name_phonetic IS NULL)
           AND
              (  UPPER(pro.person_last_name)=UPPER(p_last_name)
               OR pro.person_last_name is null
	       OR p_last_name IS NULL)
	   AND
	      (   pro.date_of_birth=p_date_of_birth
	       OR pro.date_of_birth IS NULL
	       OR p_date_of_birth IS NULL)
       );
     --Row returned, duplicate exists
  hr_utility.set_location('13',10);
	 l_duplicate_found:=TRUE;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
	  --No row returned, no duplicate exists
  hr_utility.set_location('15',10);
	  l_duplicate_found:=FALSE;
    END;
  ELSE */
   BEGIN
    SELECT null
    INTO   l_dummy
    FROM dual
    WHERE EXISTS
       (SELECT 1
          FROM per_all_people_f per
 		 WHERE l_session_date BETWEEN per.effective_start_date
                                AND    per.effective_end_date
		   AND per.national_identifier=p_national_identifier)
       or EXISTS
       (SELECT 1
          from hz_person_profiles pro,
	       hz_parties pty
	 where UPPER(pty.person_last_name)=UPPER(p_last_name)
	   AND pty.party_id = pro.party_id
	   AND pro.effective_end_date is NULL
           AND
	      (  UPPER(pro.Person_first_name)=UPPER(p_first_name)
	       OR pro.person_first_name is null
	       OR p_first_name IS NULL)
	   AND
	      (   pro.date_of_birth=p_date_of_birth
	       OR pro.date_of_birth IS NULL
	       OR p_date_of_birth IS NULL)
       );
     --Row returned, duplicate exists
    hr_utility.set_location('23',10);
    l_duplicate_found:=TRUE;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
	  --No row returned, no duplicate exists
       hr_utility.set_location('25',10);
	  l_duplicate_found:=FALSE;
    END;
--  END IF;
  hr_utility.set_location('14',10);
  RETURN l_duplicate_found;
END;
--Added for fix 0f #3257115 end

-- --------------------------------------------------------------------------
-- |--------------------< is_duplicate_person function >---------------------|
-- --------------------------------------------------------------------------
FUNCTION is_duplicate_person(p_first_name IN VARCHAR2
                            ,p_last_name IN VARCHAR2
                            ,p_national_identifier IN VARCHAR2
                            ,p_date_of_birth IN DATE)
		 RETURN BOOLEAN
IS
 l_duplicate_found BOOLEAN:=FALSE;
 l_session_date DATE;
 l_dummy varchar2(1);
BEGIN
  --
  hr_utility.set_location('1',10);
  if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' then
    return l_duplicate_found;
  end if;
  -- Get the session date
  SELECT se.effective_date
  INTO   l_session_date
  FROM   fnd_sessions se
  WHERE  se.session_id =USERENV('sessionid');

  -- Query to detect duplicate person
  -- Use where exists for performance reasons
  hr_utility.set_location('2',10);
  --
  -- Fix for 2687564.
  -- Join was wrong before.
  --
  BEGIN
   SELECT null
   INTO   l_dummy
     FROM dual
    WHERE EXISTS
       (SELECT 1
          FROM per_all_people_f per
 		 WHERE l_session_date BETWEEN per.effective_start_date
                                AND    per.effective_end_date
		   AND per.national_identifier=p_national_identifier)
       or EXISTS
       (SELECT 1
          from hz_person_profiles pro,
	       hz_parties pty
	 where UPPER(pty.person_last_name)=UPPER(p_last_name)
	   AND pty.party_id = pro.party_id
	   AND pro.effective_end_date is NULL
           AND
	      (  UPPER(pro.Person_first_name)=UPPER(p_first_name)
	       OR pro.person_first_name is null
	       OR p_first_name IS NULL)
	   AND
	      (   pro.date_of_birth=p_date_of_birth
	       OR pro.date_of_birth IS NULL
	       OR p_date_of_birth IS NULL)
       );
     --Row returned, duplicate exists
  hr_utility.set_location('3',10);
	 l_duplicate_found:=TRUE;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
	  --No row returned, no duplicate exists
  hr_utility.set_location('5',10);
	  l_duplicate_found:=FALSE;
    END;
  hr_utility.set_location('4',10);
  RETURN l_duplicate_found;
END;
-- --------------------------------------------------------------------------
-- |-------------------< get_dup_external_name function >--------------------|
-- --------------------------------------------------------------------------
FUNCTION get_dup_external_name
  RETURN VARCHAR2
IS
BEGIN
 IF (g_dup_external_name IS NULL OR g_userenv_lang<>USERENV('LANG')) THEN
   g_dup_external_name:=Fnd_Message.get_string('PER','PER_289350_DUP_PER_EXT_NAME');
   g_userenv_lang:=USERENV('LANG');
 END IF;
 RETURN g_dup_external_name;
END;

-- --------------------------------------------------------------------------
-- |---------------------< get_dup_no_match function >-----------------------|
-- --------------------------------------------------------------------------
FUNCTION get_dup_no_match
  RETURN VARCHAR2
IS
BEGIN
  IF (g_dup_no_match IS NULL OR g_userenv_lang<>USERENV('LANG')) THEN
      g_dup_no_match:=Fnd_Message.get_string('PER','PER_289352_DUP_PER_NO_MATCH');
  END IF;
 RETURN g_dup_no_match;
END;

-- --------------------------------------------------------------------------
-- |------------------< get_dup_no_security_char function >------------------|
-- --------------------------------------------------------------------------
FUNCTION get_dup_no_security_char
  RETURN VARCHAR2
IS
BEGIN
 IF (g_dup_no_security_char IS NULL )THEN
   g_dup_no_security_char:='*';
 END IF;
 RETURN g_dup_no_security_char;
END;

-- --------------------------------------------------------------------------
-- |-----------------< get_dup_no_security_status function >-----------------|
-- --------------------------------------------------------------------------
FUNCTION get_dup_security_status(p_party_id IN NUMBER
                                ,p_business_group_id IN NUMBER)
RETURN VARCHAR2
IS
 return_value VARCHAR2(2000):=NULL;
 dummy_value NUMBER;
BEGIN
 BEGIN
  SELECT 1
   INTO dummy_value
   FROM dual
   WHERE EXISTS (SELECT 1
                   FROM PER_ALL_PEOPLE_F per
                  WHERE per.party_id=p_party_id
                    AND per.business_group_id=Hr_General.get_business_Group_id);
  return_value:=get_dup_no_security_char;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
   return_value:=null;
 END;

/*
   BEGIN
	 SELECT per.party_id
	   INTO dummy_value
	   FROM PER_PEOPLE_F per
	  WHERE per.party_id=p_party_id;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
 	  return_value:=get_dup_no_security_char;
   END;
*/

 RETURN return_value;
END;

-- --------------------------------------------------------------------------
-- |---------------------< get_dup_full_name function >----------------------|
-- --------------------------------------------------------------------------
-- 5 parameter version
FUNCTION get_dup_full_name(p_title IN VARCHAR2
                          ,p_first_name in VARCHAR2
                          ,p_middle_name in VARCHAR2
                          ,p_last_name  in VARCHAR2
                          ,p_suffix in VARCHAR2)
RETURN VARCHAR2
IS
  l_full_name hz_person_profiles.person_name%TYPE;
BEGIN
  if p_title is not null
   and p_title<>fnd_api.g_miss_char then
    l_full_name:=l_full_name||p_title;
  end if;

  if p_first_name is not null
   and p_first_name<>fnd_api.g_miss_char then
    l_full_name:=l_full_name||' '||p_first_name;
  end if;

  if p_middle_name is not null
   and p_middle_name<>fnd_api.g_miss_char then
    l_full_name:=l_full_name||' '||p_middle_name;
  end if;

  if p_last_name is not null
   and p_last_name<>fnd_api.g_miss_char then
    l_full_name:=l_full_name||' '||p_last_name;
  end if;

  if p_suffix is not null
   and p_suffix<>fnd_api.g_miss_char then
    l_full_name:=l_full_name||' '||p_suffix;
  end if;

  return l_full_name;
end;

-- 8 parameter version
FUNCTION get_dup_full_name(p_title IN VARCHAR2
                          ,p_first_name in VARCHAR2
                          ,p_middle_name in VARCHAR2
                          ,p_last_name  in VARCHAR2
                          ,p_suffix in VARCHAR2
                          ,p_leg_code in varchar2
                          ,p_jp_fname varchar2
                          ,p_jp_lname varchar2)
RETURN VARCHAR2
IS
  l_full_name hz_person_profiles.person_name%TYPE;
BEGIN
IF (p_leg_code = 'JP') THEN
   IF (p_last_name is not null
   and p_last_name<>fnd_api.g_miss_char) THEN
      l_full_name := l_full_name || p_last_name ;
   END IF;

   if (p_first_name is not null
   and p_first_name<>fnd_api.g_miss_char) then
       l_full_name:=l_full_name||' '||p_first_name;
   end if;

   IF (p_last_name is not null ) or (p_first_name is not null) THEN
      l_full_name := l_full_name ||' /';
   END IF;

   IF (p_jp_lname is not null
   and p_jp_lname <> fnd_api.g_miss_char) THEN
      l_full_name := l_full_name ||' '|| p_jp_lname ;
   END IF;

   IF (p_jp_fname is not null
   and p_jp_fname <> fnd_api.g_miss_char) THEN
      l_full_name := l_full_name ||' '|| p_jp_fname ;
   END IF;


ELSE

  if p_title is not null
   and p_title<>fnd_api.g_miss_char then
    l_full_name:=l_full_name||p_title;
  end if;

  if p_first_name is not null
   and p_first_name<>fnd_api.g_miss_char then
    l_full_name:=l_full_name||' '||p_first_name;
  end if;

  if p_middle_name is not null
   and p_middle_name<>fnd_api.g_miss_char then
    l_full_name:=l_full_name||' '||p_middle_name;
  end if;

  if p_last_name is not null
   and p_last_name<>fnd_api.g_miss_char then
    l_full_name:=l_full_name||' '||p_last_name;
  end if;

  if p_suffix is not null
   and p_suffix<>fnd_api.g_miss_char then
    l_full_name:=l_full_name||' '||p_suffix;
  end if;

END IF;
  return l_full_name;
end;
------------------------------------------------------------------------------

procedure return_status_assignment_type
                              (p_status   in varchar2
                              ,p_Current_flag out nocopy varchar2
                              ,p_past_flag out nocopy varchar2
                              ,p_cwk_flag out nocopy varchar2
                              ,p_emp_flag out nocopy varchar2
                              ,p_apl_flag out nocopy varchar2) is
begin
p_Current_flag  :='N';
p_past_flag :='N';
p_cwk_flag :='N';
p_emp_flag :='N';
p_apl_flag :='N';

if p_status = 'END' then
p_past_flag := 'Y';
p_cwk_flag :='Y';
p_emp_flag :='Y';
p_apl_flag :='Y';
elsif p_status IN ('ACCEPTED','ACTIVE_APL','INTERVIEW1','INTERVIEW2','OFFER') then
p_apl_flag :='Y';
p_current_flag :='Y';
elsif p_status IN ('TERM_APL', 'END') then
p_apl_flag :='Y';
p_past_flag :='Y';
elsif p_status IN ('ACTIVE_ASSIGN','SUSP_ASSIGN') then
p_emp_flag :='Y';
p_current_flag :='Y';
elsif p_status IN ('TERM_ASSIGN', 'END') then
p_emp_flag :='Y';
p_past_flag :='Y';
elsif p_status IN ('ACTIVE_CWK','SUSP_CWK_ASG')  then
p_cwk_flag :='Y';
p_current_flag :='Y';
elsif p_status IN ('TERM_CWK', 'END') then
p_cwk_flag :='Y';
p_past_flag :='Y';
end if;
end return_status_assignment_type;

function return_status_types(p_show_emp_flag in varchar2
                     ,p_show_apl_flag in varchar2
                     ,p_show_cwk_flag in varchar2
                     ,p_show_current_flag in varchar2)
RETURN varchar2
is
cursor csr_status_types is
    select distinct per_system_status from per_assignment_status_Types
    where active_flag ='Y';
in_stmt varchar2(3000);
begin
in_stmt := '(''''';
for c_rec in csr_status_types loop
if show_status_type(p_status => c_rec.per_system_status
                   ,p_show_emp_flag => p_show_emp_flag
                   ,p_show_apl_flag => p_show_apl_flag
                   ,p_show_cwk_flag => p_show_cwk_flag
                   ,p_show_current_flag => p_show_current_flag) then
if length(in_stmt) >1 then
  	 in_stmt:=in_stmt||',';
       end if;
in_stmt :=in_stmt||''''||c_rec.per_system_status||'''';
end if;
end loop;
in_stmt :=in_stmt||')';
return in_stmt;

end;

function return_assignment_type_text(p_status in varchar2)
return varchar2
is
out_text Varchar2(60);
cwk_flag varchar2(1);
emp_flag varchar2(1);
apl_flag varchar2(1);
current_flag varchar2(1);
past_flag varchar2(1);
begin
return_status_assignment_type(p_status  => p_status
                              ,p_Current_flag =>current_flag
                              ,p_past_flag =>past_flag
                              ,p_cwk_flag => cwk_flag
                              ,p_emp_flag => emp_flag
                              ,p_apl_flag => apl_flag);

if cwk_flag = 'Y' then
  out_text := out_text||'Contingent Worker';
end if;
if emp_flag = 'Y' then
  if length(out_text) > 0 then
    out_text := out_text||'.';
  end if;
  out_text := out_text||'Employee';
end if;
if apl_flag = 'Y' then
  if length(out_text) > 0 then
    out_text := out_text||'.';
  end if;
  out_text := out_text||'Applicant';
end if;
return out_text;
end;

function show_status_type(p_status IN Varchar2
                     ,p_show_emp_flag in varchar2
                     ,p_show_apl_flag in varchar2
                     ,p_show_cwk_flag in varchar2
                     ,p_show_current_flag in varchar2)
RETURN Boolean
is
ass_types varchar2(10);
cwk_flag varchar2(1);
emp_flag varchar2(1);
apl_flag varchar2(1);
current_flag varchar2(1);
past_flag varchar2(1);
begin

return_status_assignment_type(p_status  => p_status
                              ,p_Current_flag =>current_flag
                              ,p_past_flag =>past_flag
                              ,p_cwk_flag => cwk_flag
                              ,p_emp_flag => emp_flag
                              ,p_apl_flag => apl_flag);


if ((p_show_emp_flag = 'Y' and emp_flag ='Y')
or (p_show_apl_flag = 'Y' and apl_flag ='Y')
or (p_show_cwk_flag = 'Y' and cwk_flag ='Y'))
and (p_show_current_flag = 'A' or
         (p_show_current_flag ='Y' and current_flag ='Y')
      or (p_show_current_flag ='N' and past_flag='Y')) then
   Return true;
 else
   return false;
end if;
end show_status_type;
--
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------*
-----------------------VALIDATE_UPLOAD---------------------------------------*
-----------------------------------------------------------------------------*
-- This procedure returns true or false whether an entity should be uploaded
-- (Called from UPLOAD_ROW in table handlers)
-- In Parameters:
--  Upload_mode: if this is force then always returns true
--  Table Name: The base table for this entity type
--  Table_key_name: The column that holds the key (defined in the lct)
--  Table_key_value: The value identifying this entity.
--
function validate_upload (
p_Upload_mode		in varchar2,
p_Table_name		in varchar2,
p_new_row_updated_by	in varchar2,
p_new_row_update_date	in date,
p_Table_key_name	in varchar2,
p_table_key_value	in varchar2)
return boolean
is
  l_result boolean;
begin
  l_result := PER_STARTUP_PERSON_TYPES_PKG.validate_upload(
	p_Upload_mode  =>  p_Upload_mode,
	p_Table_name   =>  p_Table_name,
	p_new_row_updated_by  =>  p_new_row_updated_by,
	p_new_row_update_date => p_new_row_update_date,
	p_Table_key_name  => p_Table_key_name,
	p_table_key_value => p_table_key_value);
  return l_result;
end;

-- --------------------------------------------------------------------------
-- |----------------------< IS_BG FUNCTION >--------------------------------|
-- --------------------------------------------------------------------------

--
-- This function checks to see if the business_group_id given is a valid id
-- for the legislation code. If it is valid, then true is returned
--

FUNCTION is_bg(
p_business_group_id in number,
p_legislation_code in varchar2)
return boolean
is

cursor csr_bg is
 select 'Y'
 from per_business_groups pbg
 where pbg.business_group_id = p_business_group_id
 and pbg.legislation_code = p_legislation_code;

l_exists       varchar2(1);

BEGIN
--
open csr_bg;
--
 fetch csr_bg into l_exists;
    --
	if csr_bg%notfound then
	  return false;
	else
	 return true;
	end if;
   --
end;

-- --------------------------------------------------------------------------
-- |---------------< IS_LEGISLATION_INTSALL FUNCTION >----------------------|
-- --------------------------------------------------------------------------

--
-- This function checks to see if the legislation_code given has been
-- installed on the application
--

FUNCTION is_legislation_install(
p_application_short_name in varchar2,
p_legislation_code in varchar2)
return boolean
is

cursor csr_legislation_install is
 select 'Y'
 from hr_legislation_installations hli
 where hli.application_short_name = p_application_short_name
 and hli.legislation_code = p_legislation_code
 and hli.status = 'I';

l_exists       varchar2(1);

BEGIN
--
open csr_legislation_install;
--
 fetch csr_legislation_install into l_exists;
    --
	if csr_legislation_install%notfound then
	  return false;
	else
	 return true;
	end if;
   --
end;
-- --------------------------------------------------------------------------
-- |-------------------< get_oracle_db_version >----------------------------|
-- --------------------------------------------------------------------------
-- This function returns the current (major) ORACLE version number in the
-- format x.x (where x is a number):
-- e.g. 8.0, 8.1, 9.0, 9.1
-- If for any reason the version number cannot be identified, NULL is
-- returned
FUNCTION get_oracle_db_version RETURN NUMBER IS
  l_proc          VARCHAR2(72);
  l_version       VARCHAR2(30);
  l_compatibility VARCHAR2(30);
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'get_oracle_db_version';
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;
  -- check to see if the g_oracle_version already exists
  IF g_oracle_version IS NULL THEN
    -- get the current ORACLE version and compatibility values
    dbms_utility.db_version(l_version, l_compatibility);
    -- the oracle version number is held in the format:
    -- x.x.x.x.x
    -- set the version number to the first decimal position
    -- e.g. 9.1.2.0.0 returns 9.1
    --      9.0.1.2.0 returns 9.0
    --      8.1.7.3.0 returns 8.1
    --      8.0.2.1.0 returns 8.0
    --
    -- modified line below to include a NUMBER format model to get
    -- around, numeric format problems which have been identified
    -- in wwbug 2772209
    -- note: an important assumption is made here; the oracle
    -- version is always returned with a period '.' as a seperator
    -- regardless of NLS.
    g_oracle_version :=
      TO_NUMBER(SUBSTRB(l_version,1,INSTRB(l_version,'.',1,2)-1),'99.99');
  END IF;
  IF g_debug THEN
    hr_utility.set_location('Leaving:'||l_proc, 10);
  END IF;
  -- return the value
  RETURN(g_oracle_version);
EXCEPTION
  WHEN OTHERS THEN
    -- an unexpected error was raised and is most probably caused by
    -- the TO_NUMBER conversion. Because of this, return NULL
    -- indicating that the Oracle Version number could NOT be assertained
    IF g_debug THEN
      hr_utility.set_location('Leaving:'||l_proc, 15);
    END IF;
    RETURN(NULL);
END get_oracle_db_version;
--
-- --------------------------------------------------------------------------
-- |---------------------------------< set_ovn >----------------------------|
-- --------------------------------------------------------------------------
--
procedure set_ovn
  (p_account_owner                 in     varchar2
  ,p_table_name                    in     varchar2
  ) is
  --
  cursor cur_tab_sel (p_owner VARCHAR2, p_table VARCHAR2) is
    select distinct atc.table_name table_name
      from all_tab_columns atc
	 , user_synonyms   usy
     where atc.column_name = 'OBJECT_VERSION_NUMBER'
       and atc.nullable    = 'Y'
       and ( ( substr(atc.table_name,1,3) in
	      ('BEN','DT_','FF_','PER','PAY','HR_'
              ,'OTA', 'SSP', 'GHR', 'HXT')
             and substr(atc.table_name,1,5) <> 'HR_S_'
             and p_table = 'ALL'  )
           or ( atc.table_name = p_table and p_table <> 'ALL' )
           )
       and atc.owner       = p_owner
       and atc.table_name  = usy.table_name
       and atc.owner       = usy.table_owner
       and not exists
           (select 1
              from all_views uv
             where uv.view_name = atc.table_name
               and uv.owner     = p_owner)
     order by 1;
  --
  l_ovn_trigger all_triggers.trigger_name%TYPE := null;
  l_proc        varchar2(72);
  --
  -- Local function establishes for a single database table
  -- if an OVN trigger exists and the full trigger name.
  --
  function get_ovn_trigger
    (p_table_name in varchar2)
    return varchar2 is
    l_ovn_trigger_name all_triggers.trigger_name%TYPE := null;
  begin
    select alt.trigger_name
      into l_ovn_trigger_name
      from user_triggers alt
     where alt.table_name = p_table_name
       and alt.trigger_name like '%_OVN';
    --
    return l_ovn_trigger_name;
  exception
    when no_data_found then
      return null;
  end get_ovn_trigger;
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'set_ovn';
    hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  -- Loop for all tables which match the given parameter criteria
  --
  for trec in cur_tab_sel(upper(p_account_owner)
                         ,upper(p_table_name)
                         ) Loop
    --
    -- Establish if an _OVN trigger exists and it's name.
    --
    l_ovn_trigger := get_ovn_trigger(trec.table_name);
    --
    -- If an _OVN trigger exists then disable it.
    --
    if l_ovn_trigger is not null then
       execute immediate 'alter trigger ' || l_ovn_trigger || ' disable';
    end if;
    --
    -- Update existing rows where the object_version_number
    -- is currently null.
    --
    execute immediate 'update ' || trec.table_name || ' set '  ||
                      'object_version_number = 1 where '  ||
                      'object_version_number is null';
    --
    -- If an _OVN trigger exists then re-enable it.
    --
    if l_ovn_trigger is not null then
      execute immediate 'alter trigger ' || l_ovn_trigger || ' enable';
    end if;
  End Loop;
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;
end set_ovn;
--
-- --------------------------------------------------------------------------
-- |----------------< IS_LOCATION_LEGAL_ADR FUNCTION >----------------------|
-- --------------------------------------------------------------------------
--
-- This function checks to see if the location is defined as a legal address
--

FUNCTION is_location_legal_adr(
p_location_id in NUMBER)
return boolean
is

cursor csr_location_legal_adr is
 select 'Y'
 from  hr_locations_all loc
 where loc.location_id = p_location_id
 and   nvl(loc.legal_address_flag,'N') = 'Y';

l_exists       varchar2(1);

BEGIN
--
open csr_location_legal_adr;
--
 fetch csr_location_legal_adr into l_exists;
    --
	if csr_location_legal_adr%NOTFOUND then
	  return false;
	else
	 return true;
	end if;
   --
end is_location_legal_adr;


-- newly added vendor_id attribute decode function and fix for Bug#3136986
-----------------------------------------------------------------------
function DECODE_VENDOR (

--
         p_vendor_id      number) return varchar2 is
--
cursor csr_lookup is
         select    vendor_name
         from      po_vendors
         where     vendor_id      = p_vendor_id;
--
v_meaning          po_vendors.vendor_name%TYPE := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_vendor_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
--
return v_meaning;
end DECODE_VENDOR;

-- --------------------------------------------------------------------------
-- |---------------< SUPERVISOR_ASSIGNMENTS_IN_USE >------------------------|
-- --------------------------------------------------------------------------

function supervisor_assignments_in_use
return VARCHAR2 is

begin

  --
  -- If the profile restricts by assignment-based supervisor hierarchies,
  -- return true.
  --
  IF NVL(fnd_profile.value('HR_SUPERVISOR_HIERARCHY_USAGE'), 'P') = 'A' THEN
      RETURN 'TRUE';
  ELSE
      RETURN 'FALSE';
  END IF;

end supervisor_assignments_in_use;

-- --------------------------------------------------------------------------
-- |----------------------< HRMS_EFC_COLUMN >-------------------------------|
-- --------------------------------------------------------------------------
--
-- This function determines whether the column sent as parameter
-- is a candidate for EFC
--
function hrms_efc_column (p_table_name IN VARCHAR2,p_column_name in varchar2 )
return varchar2 is
--
   l_efc_flag VARCHAR2(10);
   cursor efc_col(table_name IN VARCHAR2, column_name IN VARCHAR2) is
    select 'TRUE' from sys.dual where
    (column_name like '%AMOUNT%' or column_name like '%AMT%' or
     column_name like '%VAL%' or column_name like '%COST%' or
     column_name like '%PRICE%' or column_name like '%FEE%' or
     column_name like '%MIN%' or column_name like '%MAX%' or
     column_name like '%COMPENSATION%' or column_name like '%COMPNSTN%' or
     column_name like '%CURRENCY%' or column_name like '%PAY%' or
     column_name like '%SAL%' or column_name like '%RATE%' or
     column_name like '%LIMIT') and
    (column_name not like '%CD' and column_name not like '%ID' and
     column_name not like '%ID_' and
     column_name not like '%RL' and column_name not like '%FLAG' and
     column_name not like '%APPROVAL%' and
     column_name not like '%DATE%' and column_name not like '%NUMBER' and
     column_name not like '%NAME' and
     column_name not like '%REASON%' and column_name not like '%TERMINATION%' and
     column_name not like '%FROM' and
     column_name not like '%TO' and column_name not like '%DESCRIPTION%' and
     column_name not like '%COMMENTS%' and
     column_name not like '%FORMULA%' and column_name not like '%PERIOD' and
     column_name not like '%PERIODS' and
     column_name not like '%FREQUENCY' and column_name not like '%APPRAISAL%' and
     column_name not like 'AGE%' and
     column_name not like '%\_AGE%' ESCAPE '\' and column_name not like '% AGE' and
     column_name not like '%TYPE' and
     column_name not like '%STATUS%' and column_name not like '%INDICATOR' and
     column_name not like '%IDENTIFIER' and
     column_name not like '%DAYS' and column_name not like '%WEEKS' and
     column_name not like '%WEEK' and
     column_name not like '%VALUE_SET' and column_name not like '%VALUESET' and
     column_name not like '%VALUE SET' and
     column_name not like '%CATEGORY' and column_name not like '%KEY%' and
     column_name not like '%PARAMETER%' and
     column_name not like '%MULTIPLE' and column_name not like '%METHOD' and
     column_name not like '%CENTER' and
     column_name not like '%PLAN' and column_name not like '%DURATION%' and
     column_name not like '%YEARS' and
     column_name not like '%YEAR' and column_name not like '%IDENTIFICATION') and
     ((instr(column_name,'CODE')>0 and column_name like '%CURRENCY%CODE') or
     (instr(column_name,'CODE')=0));

   cursor efc_col_ben(table_name IN VARCHAR2, column_name IN VARCHAR2) is
    select 'TRUE' from sys.dual where
    (column_name like '%AMOUNT%' or column_name like '%AMT%' or
     column_name like '%VAL%' or column_name like '%COST%' or
     column_name like '%PRICE%' or column_name like '%FEE%' or
     column_name like '%MIN%' or column_name like '%MAX%' or
     column_name like '%COMPENSATION%' or column_name like '%COMPNSTN%' or
     column_name like '%CURRENCY%' or column_name like '%UOM%' or
     column_name like '%CRN%' or column_name like '%PAY%' or
     column_name like '%SAL%' or column_name like '%RATE%' or
     column_name like 'MX%' or column_name like 'MN%' or
     column_name like '%LIMIT') and
    (column_name not like '%CD' and column_name not like '%ID' and
     column_name not like '%ID_' and column_name not like '%RL' and
     column_name not like '%FLAG' and column_name not like '%APPROVAL%' and
     column_name not like '%DATE%' and column_name not like '%NUMBER' and
     column_name not like '%NAME' and column_name not like '%REASON%' and
     column_name not like '%TERMINATION%' and column_name not like '%FROM' and
     column_name not like '%TO' and column_name not like '%DESCRIPTION%' and
     column_name not like '%COMMENTS%' and column_name not like '%FORMULA%' and
     column_name not like '%PERIOD' and column_name not like '%PERIODS' and
     column_name not like '%FREQUENCY' and column_name not like '%APPRAISAL%' and
     column_name not like 'AGE%' and column_name not like '%\_AGE%' ESCAPE '\' and
     column_name not like '% AGE' and column_name not like '%TYPE' and
     column_name not like '%STATUS%' and column_name not like '%INDICATOR' and
     column_name not like '%IDENTIFIER' and column_name not like '%DAYS' and
     column_name not like '%WEEKS' and column_name not like '%WEEK' and
     column_name not like '%VALUE_SET' and column_name not like '%VALUESET' and
     column_name not like '%VALUE SET' and column_name not like '%CATEGORY' and
     column_name not like '%KEY%' and column_name not like '%PARAMETER%' and
     column_name not like '%MULTIPLE' and column_name not like '%METHOD' and
     column_name not like '%PLAN' and column_name not like '%CENTER'and
     column_name not like '%DURATION%' and column_name not like '%YEARS' and
     column_name not like '%YEAR' and column_name not like '%IDENTIFICATION' and
     column_name not like '%\_NUM' ESCAPE '\') and
    ((instr(column_name,'CODE')>0 and column_name like '%CURRENCY%CODE')
     or (instr(column_name,'CODE')=0));
begin

    if(instr(p_table_name,'BEN') = 1)then
       open efc_col_ben(p_table_name, p_column_name);
       fetch efc_col_ben into l_efc_flag;
       close efc_col_ben;
    else
       open efc_col(p_table_name,p_column_name);
       fetch efc_col into l_efc_flag;
       close efc_col;
    end if;

    if(l_efc_flag = 'TRUE') then
        return l_efc_flag;
    else
        return NULL;
    end if;
end hrms_efc_column;

-- --------------------------------------------------------------------------
-- |--------------------< is_duplicate_person function ( uses global_name>--|
-- --------------------------------------------------------------------------
FUNCTION is_duplicate_person(p_first_name IN VARCHAR2
                            ,p_last_name IN VARCHAR2
                            ,p_national_identifier IN VARCHAR2
                            ,p_date_of_birth IN DATE
                            ,p_global_name IN VARCHAR2
                            ,p_dup_tbl OUT nocopy hr_general2.party_id_tbl
                            )
RETURN BOOLEAN
IS
  l_session_date date;
  l_duplicate_found BOOLEAN:=FALSE;
  l_ul_check     varchar2(30);
  l_lu_check     varchar2(30);
  l_uu_check     varchar2(30);
  l_ll_check     varchar2(30);
  l_first_char   VARCHAR2(10);
  l_second_char  varchar2(10);

  -- Bug 3988762
	-- cursor c_duplicate_people introduced for duplicate person check enhancement
	-- this will be used in is_duplicate_person overloaded function
	-- 1) For PUI the cursor will be fetched in a PL/SQL table
	-- 2) For SSHR the cursor will be feteched and returned as XML CLOB
	-- NOTE : Any changes made to the below cursor MUST also be made to the cursor used for SSHR
	cursor c_duplicate_people ( p_session_date date,p_ni varchar2,p_global_name varchar2,p_dob date,p_last_name varchar2
	                             ,p_first_name varchar2,l_ul_check varchar2,l_lu_check varchar2,l_uu_check varchar2
	                             ,l_ll_check varchar2 ) is
	    SELECT per.party_id party_id
	          ,per.person_id person_id
	          ,hr_general2.get_dup_security_status ( per.party_id
	                                                ,per.business_group_id
	                                               ) security_status
	          ,per.global_name person_name
	          ,nvl(bg.name,hr_general2.get_dup_external_name) bg_name
	          ,loc.location_code location_code
	          ,org.NAME org_name
	          ,adr.postal_code postal_code
	          ,SUBSTR(per.national_identifier,-4,4) national_identifier
	          ,per.business_group_id bg_id
	     FROM per_all_people_f per
	         ,per_all_assignments_f ass
	         ,per_business_groups_perf bg
	         ,hr_locations_all loc
	         ,hr_all_organization_units org
	         ,per_addresses adr
	    WHERE ass.person_id(+) = per.person_id
	      AND NVL(ass.primary_flag(+),'Y') = 'Y'
	      AND NVL(ass.assignment_type(+),'E') = 'E'
	      AND p_session_date BETWEEN NVL(ass.effective_start_date(+),p_session_date) AND NVL(ass.effective_end_date(+),p_session_date)
	      AND bg.business_group_id = per.business_Group_id
	      AND loc.location_id(+) = ass.location_id
	      AND org.organization_id(+) = ass.organization_id
	      AND adr.person_id(+) = per.person_id
	      AND NVL(adr.primary_flag(+),'Y') = 'Y'
	      AND p_session_date BETWEEN NVL(adr.date_from(+),p_session_date) AND NVL(adr.date_to(+),p_session_date)--fix for bug 6748256.
	      AND p_session_date BETWEEN NVL(per.effective_start_date,p_session_date) AND NVL(per.effective_end_date,p_session_date)
	      AND (
	            per.national_identifier = p_ni
	            OR
	            (
	              global_name = p_global_name
	              -- added conditions to use index
	              AND
	              (
	                global_name like l_ul_check OR
	                global_name like l_lu_check OR
	                global_name like l_uu_check OR
	                global_name like l_ll_check
	              )
	              AND
	              (
	                per.date_of_birth = p_dob
	                OR per.date_of_birth IS NULL OR p_dob IS NULL
	              )
	           )
	        )
	    UNION
	    SELECT pty.party_id party_id
	          ,to_number(NULL) person_id
	          ,NULL security_status
	          ,hr_general2.get_dup_full_name
	                       (pty.person_title
						             ,pty.person_first_name
						             ,pty.person_middle_name
						             ,pty.person_last_name
						             ,pty.person_name_suffix
				                 ) person_name
	          ,hr_general2.get_dup_external_name bg_name
	          ,NULL location_code
	          ,NULL org_name
	          ,NULL postal_code
	          ,NULL national_identifier
	          ,NULL bg_id
	     FROM hz_person_profiles pty,
	          hz_parties par
	    WHERE pty.party_id = par.party_id
	      AND par.orig_system_reference NOT LIKE 'PER%'
		    AND par.party_type = 'PERSON'
	      AND pty.effective_end_date is NULL
	      AND (
	          (
	            (
	              UPPER(par.person_last_name) = UPPER(p_last_name)
	              --OR par.person_last_name is null
	            )
	            AND
	            (
	              UPPER(par.person_first_name) = UPPER(p_first_name)
	              OR par.person_first_name IS NULL OR p_first_name IS NULL
	            )
	            AND
	            (
	              pty.date_of_birth = p_dob
	              OR pty.date_of_birth IS NULL OR p_dob IS NULL
	            )
	          )
          );

begin

  hr_utility.set_location('1',10);

	if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' then
	  hr_utility.set_location('2',10);
	  return l_duplicate_found;
	else
	if nvl(fnd_profile.value('HR_DUPLICATE_PERSON_CHECK'),'Y')  = 'Y' then --fix for bug 5930576
	    hr_utility.set_location('3',10);
	    -- Get the session date
	    SELECT se.effective_date
	      INTO l_session_date
	      FROM fnd_sessions se
	     WHERE se.session_id =USERENV('sessionid');

	    -- Query to detect duplicate person
	    -- Use where exists for performance reasons
      hr_utility.set_location('4',10);

      -- Global name variable for index usage
	    l_first_char  := substr( p_global_name , 1 , 1 ) ;
	    l_second_char := substr( p_global_name , 2 , 1 ) ;

	    l_ul_check := upper(l_first_char)||lower(l_second_char)||'%';
	    l_lu_check := lower(l_first_char)||upper(l_second_char)||'%';
	    l_uu_check := upper(l_first_char)||upper(l_second_char)||'%';
	    l_ll_check := lower(l_first_char)||lower(l_second_char)||'%';

	    hr_utility.set_location('5',10);

	    -- Open, fetch and close cursor c_duplicate_people
	    open c_duplicate_people
      ( l_session_date, p_national_identifier, p_global_name, p_date_of_birth, p_last_name, p_first_name,l_ul_check,l_lu_check,l_uu_check,l_ll_check );

	    fetch c_duplicate_people bulk collect
	    into p_dup_tbl;

	    close c_duplicate_people;

	    l_duplicate_found := TRUE;
      hr_utility.set_location('5',10);
    else
      l_duplicate_found := FALSE;
    end if;
  end if;
  RETURN l_duplicate_found;
end is_duplicate_person;

-- --------------------------------------------------------------------------
-- |---------< is_duplicate_person function ( FOR SSHR returns XML CLOB) >--|
-- --------------------------------------------------------------------------

procedure is_duplicate_person(
                             p_business_group_id in per_all_people_f.business_group_id%TYPE
                            ,p_first_name IN VARCHAR2
                            ,p_last_name IN VARCHAR2
                            ,p_national_identifier IN VARCHAR2
                            ,p_date_of_birth IN DATE
                            ,p_per_information1 VARCHAR2 DEFAULT NULL
                            ,p_per_information2 VARCHAR2 DEFAULT NULL
                            ,p_per_information3 VARCHAR2 DEFAULT NULL
                            ,p_per_information4 VARCHAR2 DEFAULT NULL
                            ,p_per_information5 VARCHAR2 DEFAULT NULL
                            ,p_per_information6 VARCHAR2 DEFAULT NULL
                            ,p_per_information7 VARCHAR2 DEFAULT NULL
                            ,p_per_information8 VARCHAR2 DEFAULT NULL
                            ,p_per_information9 VARCHAR2 DEFAULT NULL
                            ,p_per_information10 VARCHAR2 DEFAULT NULL
                            ,p_per_information11 VARCHAR2 DEFAULT NULL
                            ,p_per_information12 VARCHAR2 DEFAULT NULL
                            ,p_per_information13 VARCHAR2 DEFAULT NULL
                            ,p_per_information14 VARCHAR2 DEFAULT NULL
                            ,p_per_information15 VARCHAR2 DEFAULT NULL
                            ,p_per_information16 VARCHAR2 DEFAULT NULL
                            ,p_per_information17 VARCHAR2 DEFAULT NULL
                            ,p_per_information18 VARCHAR2 DEFAULT NULL
                            ,p_per_information19 VARCHAR2 DEFAULT NULL
                            ,p_per_information20 VARCHAR2 DEFAULT NULL
                            ,p_per_information21 VARCHAR2 DEFAULT NULL
                            ,p_per_information22 VARCHAR2 DEFAULT NULL
                            ,p_per_information23 VARCHAR2 DEFAULT NULL
                            ,p_per_information24 VARCHAR2 DEFAULT NULL
                            ,p_per_information25 VARCHAR2 DEFAULT NULL
                            ,p_per_information26 VARCHAR2 DEFAULT NULL
                            ,p_per_information27 VARCHAR2 DEFAULT NULL
                            ,p_per_information28 VARCHAR2 DEFAULT NULL
                            ,p_per_information29 VARCHAR2 DEFAULT NULL
                            ,p_per_information30 VARCHAR2 DEFAULT NULL
                            ,p_duplicate_exists out nocopy integer
                            ,p_dup_clob OUT nocopy CLOB
                            )
IS
  l_session_date date;
  l_duplicate_found BOOLEAN:=FALSE;
  l_ul_check     varchar2(30);
  l_lu_check     varchar2(30);
  l_uu_check     varchar2(30);
  l_ll_check     varchar2(30);
  l_first_char   VARCHAR2(10);
  l_second_char  varchar2(10);
  qryCtx DBMS_XMLGEN.ctxHandle;

  rc SYS_REFCURSOR;

  l_full_name varchar2(2000);
  l_order_name varchar2(2000);
  l_global_name varchar2(2000);
  l_local_name varchar2(2000);
  l_duplicate_name varchar2(1);

begin

 -- get the global name
  hr_person_name.derive_person_names
                           (p_format_name => 'LIST_NAME'
                            ,p_business_group_id => p_business_group_id
                            ,p_first_name => p_first_name
                            ,p_middle_names => null
                            ,p_last_name => p_last_name
                            ,p_known_as => null
                            ,p_title => null
                            ,p_suffix => null
                            ,p_pre_name_adjunct => null
                            ,p_date_of_birth => p_date_of_birth
                            ,p_previous_last_name => null
                            ,p_email_address => null
                            ,p_employee_number => null
                            ,p_applicant_number => null
                            ,p_npw_number => null
                            ,p_per_information1 => p_per_information1
                            ,p_per_information2 => p_per_information2
                            ,p_per_information3 => p_per_information3
                            ,p_per_information4 => p_per_information4
                            ,p_per_information5 => p_per_information5
                            ,p_per_information6 => p_per_information6
                            ,p_per_information7 => p_per_information7
                            ,p_per_information8 => p_per_information8
                            ,p_per_information9 => p_per_information9
                            ,p_per_information10 => p_per_information10
                            ,p_per_information11 => p_per_information11
                            ,p_per_information12 => p_per_information12
                            ,p_per_information13 => p_per_information13
                            ,p_per_information14 => p_per_information14
                            ,p_per_information15 => p_per_information15
                            ,p_per_information16 => p_per_information16
                            ,p_per_information17 => p_per_information17
                            ,p_per_information18 => p_per_information18
                            ,p_per_information19 => p_per_information19
                            ,p_per_information20 => p_per_information20
                            ,p_per_information21 => p_per_information21
                            ,p_per_information22 => p_per_information22
                            ,p_per_information23 => p_per_information23
                            ,p_per_information24 => p_per_information24
                            ,p_per_information25 => p_per_information25
                            ,p_per_information26 => p_per_information26
                            ,p_per_information27 => p_per_information27
                            ,p_per_information28 => p_per_information28
                            ,p_per_information29 => p_per_information29
                            ,p_per_information30 => p_per_information30
                            ,p_full_name     => l_full_name
                            ,p_order_name    => l_order_name
                            ,p_global_name   => l_global_name
                            ,p_local_name    => l_local_name
                            );
  hr_utility.set_location(l_global_name || ' SSHR',11);


		-- Get the session date
		SELECT se.effective_date
		  INTO l_session_date
		  FROM fnd_sessions se
		 WHERE se.session_id = USERENV('sessionid');


  hr_utility.set_location('SSHR',10);

  if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' then
		hr_utility.set_location('SSHR',10.1);
		--fix for bug 5923547 starts here.
  hr_person_name.derive_person_names
                            (p_format_name       => null
                            ,p_business_group_id => p_business_group_id
                            ,p_person_id         =>  null
                            ,p_first_name        => p_first_name
                            ,p_middle_names      => null
                            ,p_last_name         => p_last_name
                            ,p_known_as          => null
                            ,p_title             => null
                            ,p_suffix            => null
                            ,p_pre_name_adjunct  => null
                            ,p_date_of_birth     => p_date_of_birth
                            ,p_previous_last_name=> null
                            ,p_email_address     => null
                            ,p_employee_number   => null
                            ,p_applicant_number  => null
                            ,p_npw_number        => null
                            ,p_per_information1 => p_per_information1
                            ,p_per_information2 => p_per_information2
                            ,p_per_information3 => p_per_information3
                            ,p_per_information4 => p_per_information4
                            ,p_per_information5 => p_per_information5
                            ,p_per_information6 => p_per_information6
                            ,p_per_information7 => p_per_information7
                            ,p_per_information8 => p_per_information8
                            ,p_per_information9 => p_per_information9
                            ,p_per_information10 => p_per_information10
                            ,p_per_information11 => p_per_information11
                            ,p_per_information12 => p_per_information12
                            ,p_per_information13 => p_per_information13
                            ,p_per_information14 => p_per_information14
                            ,p_per_information15 => p_per_information15
                            ,p_per_information16 => p_per_information16
                            ,p_per_information17 => p_per_information17
                            ,p_per_information18 => p_per_information18
                            ,p_per_information19 => p_per_information19
                            ,p_per_information20 => p_per_information20
                            ,p_per_information21 => p_per_information21
                            ,p_per_information22 => p_per_information22
                            ,p_per_information23 => p_per_information23
                            ,p_per_information24 => p_per_information24
                            ,p_per_information25 => p_per_information25
                            ,p_per_information26 => p_per_information26
                            ,p_per_information27 => p_per_information27
                            ,p_per_information28 => p_per_information28
                            ,p_per_information29 => p_per_information29
                            ,p_per_information30 => p_per_information30
                            ,p_full_name     => l_full_name
                            ,p_order_name    => l_order_name
                            ,p_global_name   => l_global_name
                            ,p_local_name    => l_local_name
			    ,p_duplicate_flag     => l_duplicate_name
                            );

 hr_utility.set_location('SSHR',10.2);
 if l_duplicate_name = 'Y' then
 open rc for
      select  per.party_id "PartyId",
      per.person_id "PersonId",
      hr_general2.get_dup_security_status(per.party_id,per.business_group_id) "SecurityStatus",
      hr_general2.get_dup_full_name(hr_general.decode_lookup('TITLE',per.title),per.first_name, per.middle_names,per.last_name,per.suffix,hr_api.return_legislation_code(per.business_group_id),per.per_information19,per.per_information18) "PersonName",
      NVL(bg.name,hr_general2.get_dup_external_name) "BgName",
      loc.location_code "LocationCode",
      org.name "OrgName",
      adr.postal_code "PostalCode",
      SUBSTR(per.national_identifier,-4,4) "NationalIdentifier",
      per.business_group_id "BusinessGroupId"
from per_all_people_f per
    ,per_all_assignments_f ass
    ,hr_all_organization_units_tl bg
    ,hr_locations_all_tl loc
    ,hr_all_organization_units_tl org
    ,per_addresses adr
where ass.person_id(+) = per.person_id
  and ass.primary_flag(+) = 'Y'
  and ass.assignment_type(+) = 'E'
  and per.business_group_id = p_business_group_id
  and l_session_date between nvl(ass.effective_start_date(+),l_session_date) and nvl(ass.effective_end_date(+),l_session_date)
  and bg.organization_id = per.business_Group_id
  and bg.language = userenv('LANG')
  and loc.location_id (+) = ass.location_id
  and loc.language (+) = userenv('LANG')
  and org.organization_id(+) = ass.organization_id
  and org.language(+) = userenv('LANG')
  and adr.person_id(+) = per.person_id
  and nvl(adr.primary_flag(+),'Y')='Y'
  and l_session_date between nvl(adr.date_from(+),l_session_date) and nvl(adr.date_to(+),l_session_date)
  and l_session_date between nvl(per.effective_start_date,l_session_date) and nvl(per.effective_end_date,l_session_date)
  and ((per.national_identifier=p_national_identifier)
      or ((per.last_name=p_last_name) and
          (per.first_name=p_first_name or per.first_name is null or p_first_name is null)
      and (per.date_of_birth=p_date_of_birth or per.date_of_birth is null or p_date_of_birth is null)));
--fix for bug 5946126.
/*union
select pty.party_id "PartyId"
      ,to_number(null) "PersonId"
      ,null "SecurityStatus"
      ,hr_general2.get_dup_full_name(pty.person_title
      ,pty.person_first_name,pty.person_middle_name ,pty.person_last_name,pty.person_name_suffix,null,null,null) "PersonName"
      ,hr_general2.get_dup_external_name "BgName"
      ,null "LocationCode"
      ,null "OrgName"
      ,null "PostalCode"
      ,null "NationalIdentifier",
      to_number(null) "BusinessGroupId"
from  hz_person_profiles pty
     ,hz_parties p
where p.party_id = pty.party_id
  and p.person_last_name=p_last_name
  and (p.person_first_name=p_first_name or p.person_first_name is null or p_first_name is null)
  and (pty.date_of_birth=p_date_of_birth or pty.date_of_birth is null or p_date_of_birth is null)
  and l_session_date between nvl(pty.effective_start_date,l_session_date) and nvl(pty.effective_end_date,l_session_date)
  and not exists (select 'x' from per_all_people_f per
                   where per.party_id = p.party_id
                   and l_session_date between nvl(per.effective_start_date,l_session_date) and nvl(per.effective_end_date,l_session_date) );*/

           qryCtx := dbms_xmlgen.newContext(rc);
	   DBMS_XMLGEN.setRowTag(qryCtx, 'MatchingPersonListVORow');
	   DBMS_XMLGEN.setRowSetTag(qryCtx, 'MatchingPersonListVO');

   hr_utility.set_location('SSHR',10.3);

  p_dup_clob:= DBMS_XMLGEN.getXML( qryCtx );

   hr_utility.set_location('SSHR',10.4);

	   DBMS_XMLGEN.closeContext( qryCtx );

   hr_utility.set_location('SSHR',10.5);

   l_duplicate_found := TRUE;

else
   l_duplicate_found := FALSE;
end if;
--fix for bug 5923547 ends here.
	else
 if nvl(fnd_profile.value('HR_DUPLICATE_PERSON_CHECK'),'Y')  = 'Y' then --fix for bug 5930576
	    hr_utility.set_location('SSHR',20);


		 -- Query to detect duplicate person
		 -- Use where exists for performance reasons
	   hr_utility.set_location('SSHR',30);

	  -- Global name variable for index usage
		 l_first_char  := substr( l_global_name , 1 , 1 ) ;
		 l_second_char := substr( l_global_name , 2 , 1 ) ;

		 l_ul_check := upper(l_first_char)||lower(l_second_char)||'%';
		 l_lu_check := lower(l_first_char)||upper(l_second_char)||'%';
		 l_uu_check := upper(l_first_char)||upper(l_second_char)||'%';
		 l_ll_check := lower(l_first_char)||lower(l_second_char)||'%';

	   hr_utility.set_location('SSHR',40);
     -- NOTE : Any changes made to the below cursor MUST also be made to the cursor used for PUI
     open rc for
       SELECT per.party_id "PartyId"
             ,per.person_id "PersonId"
             ,hr_general2.get_dup_security_status ( per.party_id
                                                   ,per.business_group_id
                                                  ) "SecurityStatus"
             ,per.global_name "PersonName"
             ,nvl(bg.name,hr_general2.get_dup_external_name) "BgName"
             ,loc.location_code "LocationCode"
             ,org.NAME "OrgName"
             ,adr.postal_code "PostalCode"
             ,SUBSTR(per.national_identifier,-4,4) "NationalIdentifier"
             ,per.business_group_id "BusinessGroupId"
        FROM per_all_people_f per
            ,per_all_assignments_f ass
            ,per_business_groups_perf bg
            ,hr_locations_all loc
            ,hr_all_organization_units org
            ,per_addresses adr
      WHERE ass.person_id(+) = per.person_id
        AND NVL(ass.primary_flag(+),'Y') = 'Y'
        AND NVL(ass.assignment_type(+),'E') = 'E'
        AND l_session_date BETWEEN NVL(ass.effective_start_date(+),l_session_date) AND NVL(ass.effective_end_date(+),l_session_date)
        AND bg.business_group_id = per.business_Group_id
        AND loc.location_id(+) = ass.location_id
        AND org.organization_id(+) = ass.organization_id
        AND adr.person_id(+) = per.person_id
        AND NVL(adr.primary_flag(+),'Y') = 'Y'
        AND l_session_date BETWEEN NVL(adr.date_from(+),l_session_date) AND NVL(adr.date_to(+),l_session_date)--fix for bug6748256
        AND l_session_date BETWEEN NVL(per.effective_start_date,l_session_date) AND NVL(per.effective_end_date,l_session_date)
        AND (
              per.national_identifier = p_national_identifier
              OR
              (
                global_name = l_global_name
                -- added conditions to use index
                AND
                (
                  global_name like l_ul_check OR
                  global_name like l_lu_check OR
                  global_name like l_uu_check OR
                  global_name like l_ll_check
                )
                AND
                (
                  per.date_of_birth = p_date_of_birth
                  OR per.date_of_birth IS NULL OR p_date_of_birth IS NULL
                )
             )
           )
    UNION
    SELECT pty.party_id "PartyId"
          ,to_number(NULL) "PersonId"
          ,NULL "SecurityStatus"
          ,hr_general2.get_dup_full_name
                       (pty.person_title
					             ,pty.person_first_name
					             ,pty.person_middle_name
					             ,pty.person_last_name
					             ,pty.person_name_suffix
			                 ) "PersonName"
          ,hr_general2.get_dup_external_name "BgName"
          ,NULL "LocationCode"
          ,NULL "OrgName"
          ,NULL "PostalCode"
          ,NULL "NationalIdentifier"
          ,NULL "BusinessGroupId"
     FROM hz_person_profiles pty,
          hz_parties par
    WHERE pty.party_id = par.party_id
      AND par.orig_system_reference NOT LIKE 'PER%'
	    AND par.party_type = 'PERSON'
      AND pty.effective_end_date is NULL
      AND (
          (
            (
              UPPER(par.person_last_name) = UPPER(p_last_name)
              --OR par.person_last_name is null
            )
            AND
            (
              UPPER(par.person_first_name) = UPPER(p_first_name)
              OR par.person_first_name IS NULL OR p_first_name IS NULL
            )
            AND
            (
              pty.date_of_birth = p_date_of_birth
              OR pty.date_of_birth IS NULL OR p_date_of_birth IS NULL
            )
          )
          );

	   qryCtx := dbms_xmlgen.newContext(rc);
	   DBMS_XMLGEN.setRowTag(qryCtx, 'MatchingPersonListVORow');
	   DBMS_XMLGEN.setRowSetTag(qryCtx, 'MatchingPersonListVO');

	   hr_utility.set_location('SSHR',50);

	   p_dup_clob:= DBMS_XMLGEN.getXML( qryCtx );

	   hr_utility.set_location('SSHR',60);

	   DBMS_XMLGEN.closeContext( qryCtx );

	   hr_utility.set_location('SSHR',70);

      l_duplicate_found := TRUE;
    else
      l_duplicate_found := FALSE;
    end if;
  end if;

  p_duplicate_exists := hr_java_conv_util_ss.get_number(l_duplicate_found);

end is_duplicate_person;



-- --------------------------------------------------------------------------
-- |----------------------< SERVER_SIDE_PROFILE_PUT >----------------------|
-- --------------------------------------------------------------------------


procedure SERVER_SIDE_PROFILE_PUT(
   NAME in varchar2,
   VAL in varchar2)
is

begin

hr_utility.set_location('Before: FND PROFILE CALL', 13163);

fnd_profile.put(NAME,VAL);

hr_utility.set_location('After: FND PROFILE CALL', 13163);

end SERVER_SIDE_PROFILE_PUT;



END    Hr_General2;

/
