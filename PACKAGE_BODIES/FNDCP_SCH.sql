--------------------------------------------------------
--  DDL for Package Body FNDCP_SCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FNDCP_SCH" as
/* $Header: AFCPSCHB.pls 115.6 99/08/08 20:20:07 porting ship $ */

/* Exceptions */
bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501); -- program error

/* Flag for datamerge or customer data */
who_mode VARCHAR2(20) := 'customer_data';  /* customer_data or seed_data */

/* Message buffer */
internal_messages VARCHAR2(10000);

--
-- Set the contents of the message buffer */
--
PROCEDURE message(msg VARCHAR2) IS
BEGIN
   internal_messages := internal_messages || msg || fnd_global.newline;
END;

--
-- Clear the message buffer.
--
PROCEDURE message_init IS
BEGIN
   internal_messages := '';
END;


/* ------------------------------------------------------------ */
/*  who information functions                                   */
/* ------------------------------------------------------------ */

FUNCTION customer_mode RETURN BOOLEAN IS
BEGIN
   IF(who_mode = 'customer_data') THEN
      RETURN TRUE;
    ELSIF(who_mode = 'seed_data') THEN
      RETURN FALSE;
    ELSE
      message('bad session mode:' || who_mode);
      message('use set_session_mode to specify');
      RAISE bad_parameter;
   END IF;
END;


FUNCTION created_by_f RETURN NUMBER IS
BEGIN
   IF(customer_mode) THEN
      RETURN 0;
    ELSE
      RETURN 1;
   END IF;
END;

FUNCTION creation_date_f RETURN DATE IS
BEGIN
   IF(customer_mode) THEN
      RETURN Sysdate;
    ELSE
      RETURN To_date('01011980', 'MMDDYYYY');
   END IF;
END;

FUNCTION last_updated_by_f RETURN NUMBER IS
BEGIN
   RETURN created_by_f;
END;

FUNCTION last_update_date_f RETURN DATE IS
BEGIN
   RETURN creation_date_f;
END;

FUNCTION last_update_login_f RETURN NUMBER IS
BEGIN
   return 0;
END;

/* ------------------------------------------------------------ */
PROCEDURE check_notnull(val IN VARCHAR2) IS
BEGIN
   IF(val IS NULL) THEN
      message('A NULL value was specified for a NOT NULL parameter.');
      RAISE bad_parameter;
   END IF;
END;

PROCEDURE check_notnull(val IN NUMBER) IS
BEGIN
   IF(val IS NULL) THEN
      message('A NULL value was specified for a NOT NULL parameter.');
      RAISE bad_parameter;
   END IF;
END;

PROCEDURE check_notnull(val IN DATE) IS
BEGIN
   IF(val IS NULL) THEN
      message('A NULL value was specified for a NOT NULL parameter.');
      RAISE bad_parameter;
   END IF;
END;
/* ------------------------------------------------------------ */


--
-- get the application id, given the name (or short name)
--
FUNCTION application_id_f(application_name_in IN VARCHAR2)
  RETURN fnd_application.application_id%TYPE
  IS
     application_id_ret fnd_application.application_id%TYPE;
BEGIN
   IF(application_name_in IS NULL) THEN
      message('A null application_name was specified.');
      RAISE bad_parameter;
   END IF;
   /* Check the short name first. */
   SELECT application_id
     INTO application_id_ret
     FROM fnd_application
     WHERE application_short_name = application_name_in;
   RETURN application_id_ret;
EXCEPTION
   WHEN no_data_found THEN  /* Try the translated name. */
     BEGIN
       SELECT application_id
         INTO application_id_ret
         FROM fnd_application_tl
        WHERE application_name = application_name_in
          AND rownum = 1;
       RETURN application_id_ret;
     EXCEPTION
       when NO_DATA_FOUND then
         message('Invalid application name: ' || application_name_in);
         RAISE bad_parameter;
     END;
END;


--
-- Get a class ID given appl ID and name
--
FUNCTION class_id_f(	class_application_id number,
                        class_name varchar2) return number is

class_id number;

BEGIN
  SELECT Release_Class_id
    INTO class_id
    FROM fnd_conc_release_classes
   WHERE application_id = class_application_id
     AND class_name = release_class_name;

  RETURN class_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find class: '||class_name);
    RAISE bad_parameter;
END;


--
-- Get a disj ID given appl ID and name
--
FUNCTION disj_id_f(	disj_application_id number,
                        disj_name varchar2) return number is

disj_id number;

BEGIN
  SELECT Disjunction_id
    INTO disj_id FROM fnd_conc_release_Disjs
   WHERE application_id = disj_application_id
     AND disj_name = Disjunction_name;

  RETURN disj_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find disjunction: '||disj_name);
    RAISE bad_parameter;
END;


--
-- Get a period ID given appl ID and name
--
FUNCTION period_id_f(	period_application_id number,
                        period_name varchar2) return number is

period_id number;

BEGIN
  SELECT Concurrent_Period_id
    INTO period_id
    FROM fnd_conc_release_periods
   WHERE application_id = period_application_id
     AND period_name = Concurrent_Period_name;

  RETURN period_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find period: '||period_name);
    RAISE bad_parameter;
END;


--
-- Get a state ID given appl ID and name
--
FUNCTION state_id_f(	state_application_id number,
                        state_name varchar2) return number is

state_id number;

BEGIN
  SELECT concurrent_state_id
    INTO state_id
    FROM fnd_conc_release_states
   WHERE application_id = state_application_id
     AND state_name = Concurrent_state_name;

  RETURN state_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find state: '||state_name);
    RAISE bad_parameter;
END;


--
-- Get a val_set ID given name
--
FUNCTION val_set_id_f( val_set_name varchar2) return number is

val_set_id number;

BEGIN
  SELECT LOOKUP_TYPE_ID
    INTO val_set_id
    FROM FND_CONC_STATE_LOOKUP_TYPES
   WHERE val_set_name = LOOKUP_TYPE_NAME;

  RETURN val_set_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find value set: '||val_set_name);
    RAISE bad_parameter;
END;

--
-- Get a value ID given name and value set name or id
--
FUNCTION val_id_f( val_set_name varchar2 DEFAULT NULL,
		       value_name IN  varchar2,
		       value_set_id IN number DEFAULT NULL) return number is

val_id number;
set_id number;

BEGIN

  if value_set_id is NULL then
   set_id := val_set_id_f(val_set_name);
  else
   set_id := value_set_id;
  end if;

  SELECT LOOKUP_VALUE
    INTO val_id
    FROM FND_CONC_STATE_LOOKUPS_TL L
    WHERE L.LOOKUP_TYPE_ID = set_id
         and L.MEANING = value_name
         and rownum = 1;

  RETURN val_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find value: '||value_name);
    RAISE bad_parameter;
END;


--
-- Procedure
--   SET_SESSION_MODE
--
-- Purpose
--   Sets the package mode for the current session.
--
-- Arguments:
--   session_mode - 'seed_data' if new data is for Datamerge.
--                  'customer_data' is the default.
--
PROCEDURE set_session_mode(session_mode IN VARCHAR2) IS
BEGIN
   IF(lower(session_mode) NOT IN ('customer_data', 'seed_data')) THEN
      message('bad mode:'|| session_mode);
      message('valid values are: customer_data, seed_data');
      RAISE bad_parameter;
   END IF;
   who_mode := lower(session_mode);
END;


-- Function
--   MESSAGE
--
-- Purpose
--   Return an error message.  Messages are set when
--   validation (program) errors occur.
--
FUNCTION message RETURN VARCHAR2 IS
BEGIN
   RETURN internal_messages;
END;

-- Procedure
--   LOCK_SCH;
--
-- Lock the Master state row to prevent deadlock and notify runtime that
-- it needs to reload cache.
--

PROCEDURE LOCK_SCH IS
  my_last_update_login number := last_update_login_f;
  my_last_update_date date    := last_update_date_f;
  my_last_updated_by number   := last_updated_by_f;
  my_creation_date date       := creation_date_f;
  my_created_by number        := created_by_f;

Begin
  update FND_CONC_RELEASE_STATES
        SET STATUS = 1,
        LAST_UPDATE_DATE = my_last_update_date,
	last_updated_by = my_last_updated_by,
	last_update_login = my_last_update_login,
	creation_date = my_creation_date,
	created_by = my_created_by
        WHERE APPLICATION_ID = 0
        AND CONCURRENT_STATE_NAME = 'AFPSCHED_STATUS';

end LOCK_SCH;

--
-- Commit changes
--

PROCEDURE COMMIT_CHANGES is

BEGIN
   LOCK_SCH;
   commit;
END;


--
-- Function
--   Class_Enable
--
-- Purpose
--   Sets enabled flag for Concurrent Release Class.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Class_Name            - Class Name
--
PROCEDURE Class_Enable(Application   IN Varchar2,
                       Class_Name      IN Varchar2
                       ) is
appl_id number;
obj_id  number;
l_last_update_login number := last_update_login_f;
l_last_update_date date    := last_update_date_f;
l_last_updated_by number   := last_updated_by_f;

cur_lang fnd_languages.language_code%TYPE;

  CURSOR lang_cur IS
    SELECT language_code
      FROM fnd_languages
     WHERE installed_flag IN ('I', 'B');

begin
  message_init;

  check_notnull(Application);
  check_notnull(Class_Name);

  if  NOT Class_Exists(Application,
                         Class_Name) then
      message('Submitted Class does not exist.');
      raise bad_parameter;
      return;
  end if;

  appl_id := application_id_f(application);

  /* Do the update */
  update fnd_conc_release_classes c
            set c.enabled_flag  = 'Y',
                c.last_update_date  = l_last_update_date,
		c.last_updated_by   = l_last_updated_by,
		c.last_update_login = l_last_update_login
          where c.application_id = appl_id
	    and c.release_class_name = Class_Name;
end;

--
-- Function
--   Class_Disable
--
-- Purpose
--   Reset enabled flag for Concurrent Release Class.
--
-- Arguments:
--   Class_Name            - Class Name
--
PROCEDURE Class_Disable(Application   IN Varchar2,
                       Class_Name      IN Varchar2
                       ) is
appl_id number;
obj_id  number;
l_last_update_login number := last_update_login_f;
l_last_update_date date    := last_update_date_f;
l_last_updated_by number   := last_updated_by_f;

cur_lang fnd_languages.language_code%TYPE;

  CURSOR lang_cur IS
    SELECT language_code
      FROM fnd_languages
     WHERE installed_flag IN ('I', 'B');

begin
  message_init;

  check_notnull(Application);
  check_notnull(Class_Name);

  if  NOT Class_Exists(Application,
                         Class_Name) then
      message('Submitted Class does not exist.');
      raise bad_parameter;
      return;
  end if;

  appl_id := application_id_f(application);

  /* Do the update */
 update fnd_conc_release_classes c
                set c.enabled_flag  = 'N',
                c.last_update_date  = l_last_update_date,
		c.last_updated_by   = l_last_updated_by,
		c.last_update_login = l_last_update_login
         where c.application_id = appl_id
		and c.release_class_name = Class_Name;
end;

-- Purpose
--   Reset enabled flag for Concurrent Release Class.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Class_Name      - Class Name
--
--   Resub_Interval  - How long of a delay for resubmission
--
--   Resub_Int_Unit_Code - Units for Resub_Interval
--                      (MINUTES, HOURS, DAYS, MONTHS,SMART)
--
--   Resub_Int_Type_Code - Offset from start or end of request?
--                      (START, END)
--
PROCEDURE Set_Class_Resub(Application   IN Varchar2,
                        Class_Name      IN Varchar2,
                        Resub_Interval  IN Number,
                        Resub_Int_Unit_Code IN Varchar,
                        Resub_Int_Type_Code IN Varchar
                       ) is
appl_id number;
obj_id  number;
l_last_update_login number := last_update_login_f;
l_last_update_date date    := last_update_date_f;
l_last_updated_by number   := last_updated_by_f;

cur_lang fnd_languages.language_code%TYPE;

  CURSOR lang_cur IS
    SELECT language_code
      FROM fnd_languages
     WHERE installed_flag IN ('I', 'B');

begin
  message_init;

  check_notnull(Application);
  check_notnull(Class_Name);

  if  NOT Class_Exists(Application,
                         Class_Name) then
      message('Submitted Class does not exist.');
      raise bad_parameter;
      return;
  end if;

  if (Resub_Interval is null) then
      message('Resubmission interval must be not null');
      raise bad_parameter;
      return;
  end if;

  if (Resub_Interval <= 0) then
      message('Resubmission interval must be Greater than 0');
      raise bad_parameter;
      return;
  end if;

  if ((Resub_Int_Unit_Code <> 'MINUTES') and
      (Resub_Int_Unit_Code <> 'HOURS') and
      (Resub_Int_Unit_Code <> 'SMART') and
      (Resub_Int_Unit_Code <> 'DAYS') and
      (Resub_Int_Unit_Code <> 'MONTHS')) then
      message('Resubmission Unit code must be MINUTES, HOURS, DAYS, MONTHS, or SMART');
      raise bad_parameter;
      return;
  end if;

  if ((Resub_Int_Type_code <> 'START') and (Resub_Int_Type_code <> 'END')) then
      message('Resubmission Type code must be START, or END');
      raise bad_parameter;
      return;
  end if;

  appl_id := application_id_f(application);

  /* Do the update */
 update fnd_conc_release_classes c
                set RESUBMIT_INTERVAL= Resub_Interval,
		RESUBMIT_INTERVAL_UNIT_CODE = Resub_Int_Unit_Code,
                RESUBMIT_INTERVAL_TYPE_CODE = Resub_Int_Type_Code,
                c.last_update_date  = l_last_update_date,
                c.last_updated_by   = l_last_updated_by,
                c.last_update_login = l_last_update_login
         where c.application_id = appl_id
                and c.release_class_name = Class_Name;
end;


--
-- Procedure
--   Class
--
-- Purpose
--   Register a Concurrent Release Class.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Class_Name	     - Class Name
--
--   User_Class_Name - User Class Name
--
--   Description     - Description
--
PROCEDURE	Class(	Application 	IN Varchar2,
			Class_Name      IN Varchar2,
			User_Class_Name IN Varchar2,
			Description	IN Varchar2	Default NULL,
			Lang_CODE       IN Varchar2) IS

appl_id number;
obj_id  number;
last_update_login number := last_update_login_f;
last_update_date date    := last_update_date_f;
last_updated_by number   := last_updated_by_f;
creation_date date       := creation_date_f;
created_by number        := created_by_f;

cur_lang fnd_languages.language_code%TYPE;

  CURSOR lang_cur IS
    SELECT language_code
      FROM fnd_languages
     WHERE installed_flag IN ('I', 'B');

begin
  message_init;

  check_notnull(Application);
  check_notnull(Class_Name);
  check_notnull(User_Class_Name);

  -- Set the language for the seed data
  if (lang_code is not null) then
    cur_lang := upper(lang_code);
  else
    cur_lang := USERENV('LANG');
    if (cur_lang is null) then
      message('Could not find current language.');
      raise bad_parameter;
    end if;
  end if;

  /* Get new ID */
    select fnd_conc_release_classes_s.nextval
      into obj_id
      from sys.dual;

  appl_id := application_id_f(application);

    /* Do the insert */
  insert into fnd_conc_release_classes
		(application_id, release_class_id, release_class_name,
		 enabled_flag, class_type,
                 last_update_date, last_updated_by, last_update_login,
                 creation_date, created_by, updated_flag)
	values
		(appl_id, obj_id,  Class_Name,
		 'Y', 'X',
		 last_update_date, last_updated_by, last_update_login,
		 creation_date, created_by, 'Y');

  --   insert rows for each installed language into the tl table
  for lang_rec in lang_cur loop
    insert into fnd_conc_release_classes_tl
                (application_id, release_class_id, language,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, user_release_class_name, source_lang)
           values
                (appl_id, obj_id, lang_rec.language_code,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, User_Class_Name, cur_lang);
  end loop;
end Class;

--
-- Function
--   Class_Exists
--
-- Purpose
--   Determine Existence of Concurrent Release Class.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Class_Name	     - Class Name
--
FUNCTION Class_Exists (	Application 	IN Varchar2,
			Class_Name      IN Varchar2
			) Return Boolean is
  appl_id number;
  dummy varchar2(4);
begin
  message_init;
  appl_id := application_id_f(Application);

  select 'Y'
  into dummy
  from fnd_conc_release_classes
  where application_id = appl_id
  and release_class_name = Class_Name
  and rownum = 1;

  return TRUE;
exception
  when others then
    return FALSE;
end Class_Exists;


-- Procedure
--   Class_Member
-- Purpose
--   Add Disjunction to a Concurrent Release Class.
--
-- Arguments:
--   Class Application - Application Short Name
--
--   Class_Name      - Class Name
--
--   Disjunction_Application - Application Short Name
--
--   Disjunction_Name      - Disjunction Name
--
PROCEDURE Class_Member(	Class_Application 	IN Varchar2,
			Class_Name      IN Varchar2,
			Disjunction_Application IN Varchar2,
			Disjunction_Name IN Varchar2
			) IS

c_app_id number;
c_id number;
d_app_id number;
d_id number;

last_update_login number := last_update_login_f;
last_update_date date    := last_update_date_f;
last_updated_by number   := last_updated_by_f;
creation_date date       := creation_date_f;
created_by number        := created_by_f;

begin
  message_init;

  check_notnull(Class_Application);
  check_notnull(Class_Name);
  check_notnull(Disjunction_Application);
  check_notnull(Disjunction_Name);

  c_app_id := application_id_f(Class_Application);
  c_id := Class_id_f(c_app_id, Class_Name);
  d_app_id := application_id_f(Disjunction_Application);
  d_id := Disj_id_f(d_app_id, Disjunction_Name);


  insert into FND_CONC_REL_CONJ_MEMBERS
	(CLASS_APPLICATION_ID, RELEASE_CLASS_ID, DISJUNCTION_APPLICATION_ID,
	 DISJUNCTION_ID, created_by, last_update_login,
	 last_update_date, last_updated_by, creation_date)
	Values
	(c_app_id, c_id, d_app_id, d_id, created_by, last_update_login,
	 last_update_date, last_updated_by, creation_date);

  update FND_CONC_RELEASE_CLASSES
  set updated_flag = 'Y'
  where APPLICATION_ID = c_app_id
    and RELEASE_CLASS_ID = c_id;

end Class_Member;

-- Procedure
--   Class_DisMember
--
-- Purpose
--   Remove Disjunction from a Concurrent Release Class.
--
-- Arguments:
--   Class Application - Application Short Name
--
--   Class_Name      - Class Name
--
--   Disjunction_Application - Application Short Name
--
--   Disjunction_Name      - Disjunction Name
--
PROCEDURE Class_DisMember(Class_Application 	IN Varchar2,
			Class_Name      IN Varchar2,
			Disjunction_Application IN Varchar2,
			Disjunction_Name IN Varchar2
			) IS

c_app_id number;
c_id number;
d_app_id number;
d_id number;

begin
  message_init;

  /* Error checks params as well as the described membership */
  if  NOT Class_Member_Exists(Class_Application,
			 Class_Name,
			 Disjunction_Application,
			 Disjunction_Name) then
      message('Submitted Membership does not exist.');
      raise bad_parameter;
      return;
  end if;


  c_app_id := application_id_f(Class_Application);
  c_id := Class_id_f(c_app_id,Class_Name);
  d_app_id := application_id_f(Disjunction_Application);
  d_id := Disj_id_f(d_app_id,Disjunction_Name);


  DELETE FROM FND_CONC_REL_CONJ_MEMBERS
  WHERE CLASS_APPLICATION_ID = c_app_id
    AND RELEASE_CLASS_ID = c_id
    AND DISJUNCTION_APPLICATION_ID = d_app_id
    AND DISJUNCTION_ID = d_id;

end Class_DisMember;



-- Function
--   Class_Member_Exists
--
-- Purpose
--   Check Membership in a Concurrent Release Class.
--
-- Arguments:
--   Class Application - Application Short Name
--
--   Class_Name      - Class Name
--
--   Disjunction_Application - Application Short Name
--
--   Disjunction_Name      - Disjunction Name
--
Function Class_Member_Exists(Class_Application 	IN Varchar2,
			Class_Name      IN Varchar2,
			Disjunction_Application IN Varchar2,
			Disjunction_Name IN Varchar2
			)return Boolean IS

  c_id number;
  c_appl_id number;
  d_id number;
  d_appl_id number;
  dummy varchar2(4);
begin
  message_init;

  check_notnull(Class_Application);
  check_notnull(Class_Name);
  check_notnull(Disjunction_Application);
  check_notnull(Disjunction_Name);

  c_appl_id := application_id_f(Class_Application);
  d_appl_id := application_id_f(Disjunction_Application);
  c_id      := class_id_f(c_appl_id, Class_Name);
  d_id      := disj_id_f(d_appl_id, Disjunction_Name);

  begin
    select 'Y'
    into dummy
    from fnd_conc_rel_conj_members
    where CLASS_APPLICATION_ID = c_appl_id
      and RELEASE_CLASS_ID = c_id
      and DISJUNCTION_APPLICATION_ID = d_appl_id
      and DISJUNCTION_ID = d_id
      and rownum = 1;

    return TRUE;
  exception
  when others then
    return FALSE;
  end;
end Class_Member_Exists;

-- Procedure
--   Disjunction
--
-- Purpose
--   Register a Concurrent Release Disjunction.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Disj_Name       - Disjunction Name
--
--   User_Disj_Name  - User Disjunction Name
--
--   Description     - Description
--
PROCEDURE       Disjunction(  	Application     IN Varchar2,
                        	Disj_Name      	IN Varchar2,
                        	User_Disj_Name	IN Varchar2,
                        	Description     IN Varchar2 DEFAULT NULL,
                        	Lang_CODE       IN Varchar2
                        ) IS

appl_id number;
obj_id  number;
last_update_login number := last_update_login_f;
last_update_date date    := last_update_date_f;
last_updated_by number   := last_updated_by_f;
creation_date date       := creation_date_f;
created_by number        := created_by_f;

cur_lang fnd_languages.language_code%TYPE;

  CURSOR lang_cur IS
    SELECT language_code
      FROM fnd_languages
     WHERE installed_flag IN ('I', 'B');
begin
  message_init;

  check_notnull(Application);
  check_notnull(Disj_Name);
  check_notnull(User_Disj_Name);

  -- Set the language for the seed data
  if (lang_code is not null) then
    cur_lang := upper(lang_code);
  else
    cur_lang := USERENV('LANG');
    if (cur_lang is null) then
      message('Could not find current language.');
      raise bad_parameter;
    end if;
  end if;

  /* Get new ID */
    select fnd_conc_release_disjs_s.nextval
      into obj_id
      from sys.dual;

  appl_id := application_id_f(application);

    /* Do the insert */
  insert into fnd_conc_release_disjs
                (application_id, disjunction_id, disjunction_name,
                 enabled_flag,
                 last_update_date, last_updated_by, last_update_login,
                 creation_date, created_by, updated_flag)
        values
                (appl_id, obj_id,  Disj_Name,
                 'Y',
                 last_update_date, last_updated_by, last_update_login,
                 creation_date, created_by, 'Y');


  --   insert rows for each installed language into the tl table
  for lang_rec in lang_cur loop
    insert into fnd_conc_release_disjs_tl
                (application_id, disjunction_id, language,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, user_disjunction_name, source_lang)
           values
                (appl_id, obj_id, lang_rec.language_code,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, User_Disj_Name, cur_lang);
  end loop;
end Disjunction;

-- Function
--   Disjunction_Exists
--
-- Purpose
--   Determine Existence of a Concurrent Release Disjunction.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Disj_Name       - Disjunction Name
--
FUNCTION Disjunction_Exists(  	Application     IN Varchar2,
                        	Disj_Name      	IN Varchar2
                        ) Return Boolean is
  appl_id number;
  dummy varchar2(4);
begin
  message_init;
  appl_id := application_id_f(Application);

  select 'Y'
  into dummy
  from fnd_conc_release_Disjs
  where application_id = appl_id
  and Disjunction_name = Disj_Name
  and rownum = 1;

  return TRUE;
exception
  when others then
    return FALSE;
end Disjunction_Exists;




-- Procedure
--   Disj_Member_S
--
-- Purpose
--   Add State to a Concurrent Release Disjunction.
--
-- Arguments:
--   Disj Application - Application Short Name
--
--   Disj_Name      - Disj Name
--
--   State_Application - Application Short Name
--
--   State_Name      - State Name
--
--   State_Value      - Value Name
--
--   Negation Flag    - 'Y' or 'N'
--
PROCEDURE Disj_Member_S(Disj_Application 	IN Varchar2,
			Disj_Name      IN Varchar2,
			State_Application IN Varchar2,
			State_Name IN Varchar2,
			State_Value IN Varchar2,
			Negation_Flag IN Varchar2 DEFAULT 'N'
			)IS

s_app_id number;
s_id number;
d_app_id number;
d_id number;
t_id number;
v_id number;

last_update_login number := last_update_login_f;
last_update_date date    := last_update_date_f;
last_updated_by number   := last_updated_by_f;
creation_date date       := creation_date_f;
created_by number        := created_by_f;

begin
  message_init;

  check_notnull(State_Application);
  check_notnull(State_Name);
  check_notnull(State_Value);
  check_notnull(Disj_Application);
  check_notnull(Disj_Name);

  s_app_id := application_id_f(State_Application);
  s_id := State_id_f(s_app_id,State_Name);
  d_app_id := application_id_f(Disj_Application);
  d_id := Disj_id_f(d_app_id,Disj_Name);

  SELECT lookup_type_id
  into t_id
  from fnd_CONC_RELEASE_STATES
  where CONCURRENT_STATE_ID = s_id
  and application_id = s_app_id;

  v_id := Val_id_f(null,State_Value,t_id);


  insert into FND_CONC_REL_DISJ_MEMBERS
        (DISJUNCTION_APPLICATION_ID, DISJUNCTION_ID, STATE_APPLICATION_ID,
         STATE_ID, STATUS_VALUE, NEGATION_FLAG,
         PERIOD_OR_STATE_FLAG, created_by,
	 last_update_login, last_update_date, last_updated_by, creation_date)
        Values
        (d_app_id, d_id, s_app_id, s_id, v_id, Negation_Flag,
	 'S', created_by,
	 last_update_login, last_update_date, last_updated_by, creation_date);

  update FND_CONC_RELEASE_DISJS
  set updated_flag = 'Y'
  where APPLICATION_ID = d_app_id
    and DISJUNCTION_ID = d_id;

end Disj_Member_S;


-- Procedure
--   Disj_Member_P
--
-- Purpose
--   Add Period to a Concurrent Release Disjunction.
--
-- Arguments:
--   Disj Application - Application Short Name
--
--   Disj_Name      - Disj Name
--
--   Period_Application - Application Short Name
--
--   Period_Name      - Period Name
--
--   Negation Flag    - 'Y' or 'N'
--
PROCEDURE Disj_Member_P(Disj_Application 	IN Varchar2,
			Disj_Name      IN Varchar2,
			Period_Application IN Varchar2,
			Period_Name IN Varchar2,
			Negation_Flag IN Varchar2 DEFAULT 'N'
			) IS


p_app_id number;
p_id number;
d_app_id number;
d_id number;

last_update_login number := last_update_login_f;
last_update_date date    := last_update_date_f;
last_updated_by number   := last_updated_by_f;
creation_date date       := creation_date_f;
created_by number        := created_by_f;

begin
  message_init;

  check_notnull(Period_Application);
  check_notnull(Period_Name);
  check_notnull(Disj_Application);
  check_notnull(Disj_Name);

  p_app_id := application_id_f(Period_Application);
  p_id := Period_id_f(p_app_id,Period_Name);
  d_app_id := application_id_f(Disj_Application);
  d_id := Disj_id_f(d_app_id,Disj_Name);


  insert into FND_CONC_REL_DISJ_MEMBERS
        (DISJUNCTION_APPLICATION_ID, DISJUNCTION_ID, PERIOD_APPLICATION_ID,
         PERIOD_ID,PERIOD_OR_STATE_FLAG,NEGATION_FLAG,created_by,
	last_update_login, last_update_date, last_updated_by, creation_date)
        Values
        (d_app_id, d_id, p_app_id, p_id, 'P', Negation_Flag, created_by,
	 last_update_login, last_update_date, last_updated_by, creation_date);

  update FND_CONC_RELEASE_DISJS
  set updated_flag = 'Y'
  where APPLICATION_ID = d_app_id
    and DISJUNCTION_ID = d_id;

end Disj_Member_P;

-- Procedure
--   Disj_DisMember
--
-- Purpose
--   Remove State or Period from a Concurrent Release Disjunction.
--
-- Arguments:
--   Disj_Application - Application Short Name
--
--   Disj_Name          - Disjunction Name
--
--   Member_Application - Application Short Name
--
--   Member_Name      - Member Name
--
--   Member_Type      - 'S' or 'P'
--
PROCEDURE Disj_DisMember(Disj_Application 	IN Varchar2,
			Disj_Name      IN Varchar2,
			Member_Application IN Varchar2,
			Member_Name IN Varchar2,
			Member_Type IN Varchar2
			) is
m_app_id number;
m_id number;
d_app_id number;
d_id number;

begin
  message_init;

  /* Error checks params as well as the described membership */
  if NOT Disj_Member_Exists(Disj_Application,
                         Disj_Name,
			 Member_Application,
			 Member_Name,
                         Member_Type) then
      message('Submitted Membership does not exist.');
      raise bad_parameter;
      return;
  end if;

  m_app_id := application_id_f(Member_Application);

  if (Member_Type = 'S') then
     m_id := State_id_f(m_app_id,Member_Name);
  else
     m_id := Period_id_f(m_app_id,Member_Name);
  end if;

  d_app_id := application_id_f(Disj_Application);
  d_id := Disj_id_f(d_app_id,Disj_Name);


  DELETE FROM FND_CONC_REL_DISJ_MEMBERS
  WHERE DISJUNCTION_APPLICATION_ID = d_app_id
    AND DISJUNCTION_ID = d_id
    AND PERIOD_OR_STATE_FLAG = Member_Type
    AND DECODE(Member_Type, 'S', STATE_APPLICATION_ID,
				 PERIOD_APPLICATION_ID) = m_app_id
    AND DECODE(Member_Type, 'S', STATE_ID,
                                 PERIOD_ID) = m_id;

end Disj_DisMember;



-- Function
--   Disj_Member_Exists
--
-- Purpose
--   Check Membership in a Concurrent Release Disjunction.
--
-- Arguments:
--   Class Application - Application Short Name
--
--   Class_Name      - Class Name
--
--   Member_Application - Application Short Name
--
--   Member_Name      - Member Name
--
--   Member_Type      - 'S' or 'P'
--
FUNCTION Disj_Member_Exists(Disj_Application       IN Varchar2,
                        Disj_Name      IN Varchar2,
                        Member_Application IN Varchar2,
                        Member_Name IN Varchar2,
                        Member_Type IN Varchar2
			)return Boolean IS

  m_id number;
  m_app_id number;
  d_id number;
  d_app_id number;
  dummy varchar2(4);
begin
  message_init;

  check_notnull(Member_Application);
  check_notnull(Member_Name);
  check_notnull(Member_Type);
  check_notnull(Disj_Application);
  check_notnull(Disj_Name);

  m_app_id := application_id_f(Member_Application);

  if (Member_Type = 'S') then
     m_id := State_id_f(m_app_id,Member_Name);
  else
     m_id := Period_id_f(m_app_id,Member_Name);
  end if;

  d_app_id := application_id_f(Disj_Application);
  d_id := Disj_id_f(d_app_id,Disj_Name);

  begin
    select 'Y'
    into dummy
    from fnd_conc_rel_disj_members
    where DISJUNCTION_APPLICATION_ID = d_app_id
      and DISJUNCTION_ID = d_id
      and PERIOD_OR_STATE_FLAG = Member_Type
      AND DECODE(Member_Type, 'S', STATE_APPLICATION_ID,
                                 PERIOD_APPLICATION_ID) = m_app_id
      AND DECODE(Member_Type, 'S', STATE_ID,
                                 PERIOD_ID) = m_id
      and rownum = 1;

    return TRUE;
  exception
  when others then
    return FALSE;
  end;
end Disj_Member_Exists;

-- Function
--   Period_Exists
--
-- Purpose
--   Determine Existence of a Concurrent Release Period.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Period_Name     - Period Name
--
FUNCTION Period_Exists     (    Application     IN Varchar2,
                                Period_Name     IN Varchar2
                        ) return Boolean is
  appl_id number;
  dummy varchar2(4);
begin
  message_init;
  appl_id := application_id_f(Application);

  select 'Y'
  into dummy
  from fnd_conc_release_periods
  where application_id = appl_id
  and Concurrent_period_name = Period_Name
  and rownum = 1;

  return TRUE;
exception
  when others then
    return FALSE;
end Period_Exists;


-- Procedure
--   Period
--
-- Purpose
--   Register a Concurrent Release Period.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Period_Name     - Period Name
--
--   User_Period_Name - User Period Name
--
--   Description     - Description
--
--   Period_Type     - Day, Month, Year, or Reverse Month
--
--   Period_Length   - Length of period in terms of Period_Type
--
--   Period_Start    - Start point of a period
--
--   Period_Stop     - Stop point of a period

PROCEDURE       Period	   (    Application     IN Varchar2,
                                Period_Name     IN Varchar2,
                                User_Period_Name IN Varchar2,
                                Description     IN Varchar2,
				Period_Type	IN Varchar2,
				Period_Length   IN Number,
				Period_Start    IN Date,
				Period_Stop     IN Date,
                        	Lang_CODE       IN Varchar2
                        ) IS

appl_id number;
obj_id  number;
last_update_login number := last_update_login_f;
last_update_date date    := last_update_date_f;
last_updated_by number   := last_updated_by_f;
creation_date date       := creation_date_f;
created_by number        := created_by_f;

cur_lang fnd_languages.language_code%TYPE;

  CURSOR lang_cur IS
    SELECT language_code
      FROM fnd_languages
     WHERE installed_flag IN ('I', 'B');

begin
  message_init;

  check_notnull(Application);
  check_notnull(Period_Name);
  check_notnull(User_Period_Name);
  check_notnull(Period_Type);
  check_notnull(Period_Length);
  check_notnull(Period_Start);
  check_notnull(Period_Stop);

  -- Set the language for the seed data
  if (lang_code is not null) then
    cur_lang := upper(lang_code);
  else
    cur_lang := USERENV('LANG');
    if (cur_lang is null) then
      message('Could not find current language.');
      raise bad_parameter;
    end if;
  end if;

  /* Get new ID */
    select fnd_conc_release_periods_s.nextval
      into obj_id
      from sys.dual;

  appl_id := application_id_f(application);

    /* Do the insert */
  insert into fnd_conc_release_periods
                (application_id, concurrent_period_id,
                 concurrent_period_name, enabled_flag, Periodicity_code,
                 Period_Length, Period_Start_time, Period_Stop_time,
                 last_update_date, last_updated_by, last_update_login,
                 creation_date, created_by, updated_flag)
        values
                (appl_id, obj_id,  Period_Name, 'Y', Period_Type,
		 Period_Length, Period_Start, Period_Stop,
                 last_update_date, last_updated_by, last_update_login,
                 creation_date, created_by, 'Y');


  --   insert rows for each installed language into the tl table
  for lang_rec in lang_cur loop
    insert into fnd_conc_release_periods_tl
                (application_id, concurrent_period_id, language,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, user_concurrent_period_name, source_lang)
           values
                (appl_id, obj_id, lang_rec.language_code,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, User_period_Name, cur_lang);
  end loop;
end Period;


-- Procedure
--   State_Value_Set
--
-- Purpose
--   Register a Concurrent Release State Value Set
--
-- Arguments:
--   Set_Name        - SetName
--
--   User_Set_Name   - User Set Name
--
--   Description     - Description
--
PROCEDURE       State_Value_Set(Set_Name        IN Varchar2,
                                User_Set_Name   IN Varchar2,
                                Description     IN Varchar2  Default null,
                        	Lang_CODE       IN Varchar2
                        )  IS

obj_id  number;
last_update_login number := last_update_login_f;
last_update_date date    := last_update_date_f;
last_updated_by number   := last_updated_by_f;
creation_date date       := creation_date_f;
created_by number        := created_by_f;

cur_lang fnd_languages.language_code%TYPE;

  CURSOR lang_cur IS
    SELECT language_code
      FROM fnd_languages
     WHERE installed_flag IN ('I', 'B');

begin
  message_init;

  check_notnull(set_Name);
  check_notnull(User_set_Name);

  -- Set the language for the seed data
  if (lang_code is not null) then
    cur_lang := upper(lang_code);
  else
    cur_lang := USERENV('LANG');
    if (cur_lang is null) then
      message('Could not find current language.');
      raise bad_parameter;
    end if;
  end if;

  /* Get new ID */
    select FND_CONC_STATE_LOOKUP_TYPES_S.nextval
      into obj_id
      from sys.dual;

    /* Do the insert */
  insert into FND_CONC_STATE_LOOKUP_TYPES
                (LOOKUP_TYPE_ID, LOOKUP_TYPE_NAME, enabled_flag,
                 last_update_date, last_updated_by, last_update_login,
                 creation_date, created_by)
        values
                (obj_id,  Set_Name, 'Y',
                 last_update_date, last_updated_by, last_update_login,
                 creation_date, created_by);

  --   insert rows for each installed language into the tl table
  for lang_rec in lang_cur loop
    insert into FND_CONC_STATE_LOOKUP_TYPES_TL
                (LOOKUP_TYPE_ID, language,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, USER_LOOKUP_TYPE_NAME, source_lang)
           values
                (obj_id, lang_rec.language_code,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, User_set_Name, cur_lang);
  end loop;
end State_Value_Set;

-- Procedure
--   State_Value
--
-- Purpose
--   Register a Concurrent Release State Value
--
-- Arguments:
--   Value_Name      - Value Name
--
--   Value_Set_Name  - Set Name
--
PROCEDURE       State_Value(	Value_Name     IN Varchar2,
				Value_Set_Name IN Varchar2,
				DESCRIPTION IN VARCHAR2 DEFAULT NULL,
                        	Lang_CODE       IN Varchar2
                        ) IS

t_id number;
obj_id  number;
last_update_login number := last_update_login_f;
last_update_date date    := last_update_date_f;
last_updated_by number   := last_updated_by_f;
creation_date date       := creation_date_f;
created_by number        := created_by_f;

cur_lang fnd_languages.language_code%TYPE;

  CURSOR lang_cur IS
    SELECT language_code
      FROM fnd_languages
     WHERE installed_flag IN ('I', 'B');

begin
  message_init;

  check_notnull(Value_Name);
  check_notnull(Value_Set_Name);

  t_id := Val_set_id_f(Value_Set_Name);

  -- Set the language for the seed data
  if (lang_code is not null) then
    cur_lang := upper(lang_code);
  else
    cur_lang := USERENV('LANG');
    if (cur_lang is null) then
      message('Could not find current language.');
      raise bad_parameter;
    end if;
  end if;

  /* Get new ID */
    select FND_CONC_STATE_LOOKUPS_S.nextval
      into obj_id
      from sys.dual;

    /* Do the insert */
  insert into FND_CONC_STATE_LOOKUPS
                (LOOKUP_TYPE_ID, LOOKUP_VALUE, enabled_flag,
                 last_update_date, last_updated_by, last_update_login,
                 creation_date, created_by)
        values
                (t_id,  obj_id, 'Y',
                 last_update_date, last_updated_by, last_update_login,
                 creation_date, created_by);

  --   insert rows for each installed language into the tl table
  for lang_rec in lang_cur loop
    insert into FND_CONC_STATE_LOOKUPS_TL
                (LOOKUP_TYPE_ID, LOOKUP_VALUE, language, MEANING,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, source_lang)
           values
                (t_id, obj_id, lang_rec.language_code, Value_Name,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, cur_lang);
  end loop;
end State_Value;

-- Function
--   State_Value_Set_Exists
--
-- Purpose
--   Determine Existence of a Concurrent Release State Value Set
--
-- Arguments:
--   Set_Name        - SetName
--
FUNCTION State_Value_Set_Exists(Set_Name        IN Varchar2
                        	) return Boolean is
  dummy varchar2(4);
begin
  message_init;

  select 'Y'
  into dummy
  from fnd_conc_state_lookup_types
  where LOOKUP_TYPE_NAME= Set_Name
  and rownum = 1;

  return TRUE;
exception
  when others then
    return FALSE;
end State_Value_Set_Exists;


-- Function
--   State_Value_Exists
--
-- Purpose
--   Determine Existence of a Concurrent Release State Value
--
-- Arguments:
--   Value_Name      - Value Name
--
--   Value_Set_Name  - Set Name
--
FUNCTION State_Value_Exists(	Value_Name     IN Varchar2,
				Value_Set_Name IN Varchar2
                        ) return Boolean  is
  dummy varchar2(4);
  t_id number;
begin
  message_init;

  t_id := Val_set_id_f(Value_Set_Name);

  select 'Y'
  into dummy
  from fnd_conc_state_lookups_tl
  where meaning=Value_Name
  and LOOKUP_TYPE_ID = t_id
  and rownum = 1;

  return TRUE;
exception
  when others then
    return FALSE;
end State_Value_Exists;



-- Procedure
--   State
--
-- Purpose
--   Register a Concurrent Release State
--
-- Arguments:
--   Application     - Application Short Name
--
--   State_Name      - Period Name
--
--   User_State_Name - User Period Name
--
--   Description     - Description
--
--   Value_Name      - Value Name of initial value
--
--   Value_Set_Name  - Set Name used by this state
--
PROCEDURE       State(   	Application     IN Varchar2,
                                State_Name      IN Varchar2,
                                User_State_Name IN Varchar2,
                                Description     IN Varchar2 DEFAULT NULL,
				Value_Set_Name  IN Varchar2,
				Value_Name      IN Varchar2,
                        	Lang_CODE       IN Varchar2
                        ) is
appl_id number;
obj_id  number;
t_id number;
v_id number;
last_update_login number := last_update_login_f;
last_update_date date    := last_update_date_f;
last_updated_by number   := last_updated_by_f;
creation_date date       := creation_date_f;
created_by number        := created_by_f;

cur_lang fnd_languages.language_code%TYPE;

  CURSOR lang_cur IS
    SELECT language_code
      FROM fnd_languages
     WHERE installed_flag IN ('I', 'B');

begin
  message_init;

  check_notnull(Application);
  check_notnull(State_Name);
  check_notnull(Value_Set_Name);
  check_notnull(Value_Name);
  check_notnull(User_State_Name);

  t_id := val_set_id_f(Value_Set_Name);
  v_id := val_id_f(Value_Set_Name, Value_Name, null);

  -- Set the language for the seed data
  if (lang_code is not null) then
    cur_lang := upper(lang_code);
  else
    cur_lang := USERENV('LANG');
    if (cur_lang is null) then
      message('Could not find current language.');
      raise bad_parameter;
    end if;
  end if;

  /* Get new ID */
    select fnd_conc_release_states_s.nextval
      into obj_id
      from sys.dual;

  appl_id := application_id_f(application);

    /* Do the insert */
  insert into fnd_conc_release_states
                (application_id, concurrent_state_id,
                 concurrent_state_name, enabled_flag, LOOKUP_TYPE_ID, STATUS,
                 last_update_date, last_updated_by, last_update_login,
                 creation_date, created_by, updated_flag)
        values
                (appl_id, obj_id,  State_Name, 'Y', t_id, v_id,
                 last_update_date, last_updated_by, last_update_login,
                 creation_date, created_by, 'Y');


  --   insert rows for each installed language into the tl table
  for lang_rec in lang_cur loop
    insert into fnd_conc_release_states_tl
                (application_id, concurrent_state_id, language,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, USER_CONCURRENT_STATE_NAME, source_lang)
           values
                (appl_id, obj_id, lang_rec.language_code,
                 creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login,
                 description, User_state_Name, cur_lang);
  end loop;
end State;

-- Function
--   State_Exists
--
-- Purpose
--   Determine Existence of a Concurrent Release State
--
-- Arguments:
--   Application     - Application Short Name
--
--   State_Name      - Period Name
--
FUNCTION State_Exists(   	Application     IN Varchar2,
                                State_Name      IN Varchar2
                        ) return Boolean is
  appl_id number;
  dummy varchar2(4);
begin
  message_init;
  appl_id := application_id_f(Application);

  select 'Y'
  into dummy
  from fnd_conc_release_States
  where application_id = appl_id
  and Concurrent_state_name = state_Name
  and rownum = 1;

  return TRUE;
exception
  when others then
    return FALSE;
end state_Exists;


end FNDCP_SCH;

/
